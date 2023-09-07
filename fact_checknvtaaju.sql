DROP PROCEDURE fact_checknvtaaju;
EXECUTE PROCEDURE fact_checknvtaaju('2023-06-07','C');

CREATE PROCEDURE fact_checknvtaaju
(	paramFecha	DATE,
	paramTipo	CHAR(1)
)
RETURNING 
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100);	-- Mensaje

DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(100);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vciasr 	CHAR(2);
DEFINE vplasr 	CHAR(2);
DEFINE vfolio	INT;
DEFINE vvuelta 	INT;
DEFINE vimpt 	DECIMAL;
DEFINE vtlts 	DECIMAL;
DEFINE vtltsaj 	DECIMAL;
DEFINE vttlts 	DECIMAL;
DEFINE vtltsml 	DECIMAL;
DEFINE vimpcil 	DECIMAL;
DEFINE vasist 	DECIMAL;
DEFINE vtipo 	CHAR(1);
DEFINE vfolaju	INT;
DEFINE vvaju	INT;
DEFINE vcount	INT;

LET vproceso = 1;
LET vmsg = 'OK';
LET vcount = 0;
LET vttlts = 0;
LET vtltsml = 0;
LET vimpcil = 0;

IF paramTipo = 'C'THEN
	IF EXISTS (SELECT	1
			FROM 	nota_vta
			WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta IN('C','D','2','3','4')
					AND aju_nvta = 'S'
					AND fac_nvta IS NOT NULL) THEN
		FOREACH cNotas FOR
			SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta,n.impt_nvta,NVL(n.impasi_nvta, 0),tip_nvta,n.tlts_nvta
			INTO	vcia,vpla,vfolio,vvuelta,vimpt,vasist,vtipo,vtlts
			FROM 	nota_vta n
			WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
					AND aju_nvta = 'S'
					AND fac_nvta IS NOT NULL
					AND tip_nvta IN('C','D','2','3','4')
			ORDER BY 	tlts_nvta				
			IF	EXISTS(SELECT 1 
						FROM nota_vta
						WHERE fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
							AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E') THEN
				FOREACH cNotasAj FOR
					SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta	
					INTO	vciasr,vplasr,vfolaju,vvaju
					FROM 	nota_vta 
					WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
							AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E'
					IF vcount = 0 THEN 
						INSERT INTO fact_nvtaaju VALUES('C',paramFecha,vcia,vpla,vfolio,vvuelta,vciasr,vplasr,vfolaju,vvaju);
						UPDATE	nota_vta
						SET		fac_nvta = 0, ser_nvta = 'FACT'
						WHERE	cia_nvta = vciasr AND pla_nvta = vplasr AND fol_nvta = vfolaju AND vuelta_nvta = vvaju;
					END IF;
					LET vcount = vcount + 1;
				END FOREACH; 	
				LET vcount = 0;
			ELSE
				IF	EXISTS(SELECT 1 
						FROM nota_vta
						WHERE fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND impasi_nvta = vasist AND tip_nvta = vtipo AND tlts_nvta <= vtlts
							AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E') THEN
					LET vttlts = 0;
					LET vtltsml = 0;
					LET vimpcil = 0;
					IF MOD(vtlts,20.00) = 0 THEN
						LET vtltsml = 20.00;
						LET vimpcil = vimpt / (vtlts / 20.00);
					ELSE
						IF MOD(vtlts,30.00) = 0 THEN
							LET vtltsml = 30.00;
							LET vimpcil = vimpt / (vtlts / 30.00);
						ELSE
							IF MOD(vtlts,45.00) = 0 THEN
								LET vtltsml = 45.00;
								LET vimpcil = vimpt / (vtlts / 45.00);
							END IF;
						END IF;
					END IF;
					
					FOREACH cNotasAjj FOR
						SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta, tlts_nvta
						INTO	vciasr,vplasr,vfolaju,vvaju,vtltsaj
						FROM 	nota_vta 
						WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND impasi_nvta = vasist AND tip_nvta = vtipo AND tlts_nvta <= vtlts 
								AND ((tlts_nvta = vtltsml AND impt_nvta = vimpcil) OR vtltsml = 0)
								AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E'								
						ORDER BY tlts_nvta
						LET vttlts = vttlts + vtltsaj;
						IF vttlts <= vtlts THEN
							IF vcount = 0 THEN 
								INSERT INTO fact_nvtaaju VALUES('C',paramFecha,vcia,vpla,vfolio,vvuelta,vciasr,vplasr,vfolaju,vvaju);							
							END IF;
							UPDATE	nota_vta
							SET		fac_nvta = 0, ser_nvta = 'FACT'
							WHERE	cia_nvta = vciasr AND pla_nvta = vplasr AND fol_nvta = vfolaju AND vuelta_nvta = vvaju;
						END IF;
						LET vcount = vcount + 1;
					END FOREACH; 	
					IF (vtlts - vttlts) >= vtltsml THEN
						FOREACH cNotasAjjj FOR
							SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta, tlts_nvta
							INTO	vciasr,vplasr,vfolaju,vvaju,vtltsaj
							FROM 	nota_vta 
							WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
									AND impasi_nvta = vasist AND tip_nvta = vtipo AND tlts_nvta <= (vtlts - vttlts)									
									AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E'								
							ORDER BY tlts_nvta
							LET vttlts = vttlts + vtltsaj;
							IF vttlts <= vtlts THEN
								UPDATE	nota_vta
								SET		fac_nvta = 0, ser_nvta = 'FACT'
								WHERE	cia_nvta = vciasr AND pla_nvta = vplasr AND fol_nvta = vfolaju AND vuelta_nvta = vvaju;
							END IF;
							LET vcount = vcount + 1;
						END FOREACH; 
					END IF;
					LET vcount = 0;
				ELSE				
					LET vproceso = 0;
					LET vmsg = 'NO SE ENCONTRO UNA NOTA NO AJUSTADA EQUIVALENTE A LA NOTA AJUSTADA .' || vfolio;
					RETURN 	vproceso,vmsg;	
				END IF;		
			END IF;
		END FOREACH; 		
	END IF;
ELSE
	IF paramTipo = 'E' THEN
		IF EXISTS (SELECT	1
			FROM 	nota_vta
			WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta = paramTipo
					AND aju_nvta = 'S'
					AND fac_nvta IS NOT NULL) THEN
			FOREACH cNotas FOR
				SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta,n.impt_nvta,NVL(n.impasi_nvta, 0),tip_nvta
				INTO	vcia,vpla,vfolio,vvuelta,vimpt,vasist,vtipo
				FROM 	nota_vta n
				WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
						AND aju_nvta = 'S'
						AND fac_nvta IS NOT NULL
						AND tip_nvta = paramTipo
				IF	EXISTS(SELECT 1 
							FROM nota_vta
							WHERE fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
								AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E')	THEN
					FOREACH cNotasAj FOR
						SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta	
						INTO	vciasr,vplasr,vfolaju,vvaju	
						FROM 	nota_vta 
						WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
								AND cia_nvta = vcia /*AND pla_nvta = vpla*/ AND fac_nvta IS NULL AND tpa_nvta = 'E'
						IF vcount = 0 THEN 
							INSERT INTO fact_nvtaaju VALUES('C',paramFecha,vcia,vpla,vfolio,vvuelta,vciasr,vplasr,vfolaju,vvaju);
							UPDATE	nota_vta
							SET		fac_nvta = 0, ser_nvta = 'FACT'
							WHERE	cia_nvta = vciasr AND pla_nvta = vplasr AND fol_nvta = vfolaju AND vuelta_nvta = vvaju;
						END IF;
						LET vcount = vcount + 1;
					END FOREACH; 
					LET vcount = 0;	
				ELSE
					LET vproceso = 0;
					LET vmsg = 'NO SE ENCONTRO UNA NOTA NO AJUSTA EQUIVALENTE A LA NOTA AJUSTADA .' || vfolio;
					RETURN 	vproceso,vmsg;			
				END IF;
			END FOREACH; 		
		END IF;
	END IF;
END IF;
RETURN 	vproceso,vmsg;
END PROCEDURE;

select	rowid,*
from	fact_nvtaaju

insert into fact_nvtaaju
values('C','2023-06-05','15','09',540346,3,'15','09',529946,3)

UPDATE	nota_vta
SET		fac_nvta = null, ser_nvta = null
where	fac_nvta = 0 and ser_nvta = 'FACT'
WHERE	cia_nvta = '15' AND pla_nvta = '02' AND fol_nvta in(529953) AND vuelta_nvta = 3;

delete	
from	fact_nvtaaju
where	fec_naju = '2023-05-15'

update	fact_nvtaaju
set		vueltaf_naju = 3
where	rowid = 513

select	*
from	nota_vta
where	fac_nvta = 0 and ser_nvta = 'FACT'

select	*
from	nota_vta
where	fes_nvta = '2023-06-01' AND edo_nvta = 'A' AND impt_nvta > 0
							AND fac_nvta = 0 AND ser_nvta = 'FACT'
							AND tip_nvta IN('C','D','2','3','4');
							
update	nota_vta
set		aju_nvta = 'S'
where	pla_nvta = '14' and fol_nvta = 556931 and vuelta_nvta = 2
where	fac_nvta = 0 and ser_nvta = 'FACT'

where	fes_nvta = '2023-06-01' AND edo_nvta = 'A' AND impt_nvta > 0
							AND fac_nvta = 0 AND ser_nvta = 'FACT'
							AND tip_nvta IN('C','D','2','3','4');


select	*
from	det_fac
where	cia_dfac = '15' and pla_dfac = '13' and fnvta_dfac =  and vuelta_dfac = 

select	*
from	nota_vta
where	fes_nvta = '2023-06-10' and fac_nvta is not null and tip_nvta IN('C','D','2','3','4') and aju_nvta = 'S'

select	*
from	nota_vta
where	fes_nvta = '2023-06-09' and fac_nvta not in(199819) and tip_nvta IN('C','D','2','3','4') and aju_nvta = 'S'

update	nota_vta
set		fac_nvta = 157980, ser_nvta = 'EAM'
where	fes_nvta == '2023-06-04' and tip_nvta IN('C','D','2','3','4') and aju_nvta = 'S' and fac_nvta = 0

select	*
from	nota_vta
where	fes_nvta >= '2023-06-01' and aju_nvta = 'S' and tip_nvta = 'E' 

select	*
from	nota_vta
where	fes_nvta >= '2023-06-01' and fac_nvta not in(199296) and tip_nvta IN('C','D','2','3','4') and aju_nvta = 'S' and impasi_nvta > 0

select	*
from	nota_vta
where	fes_nvta = '2023-05-16' and impt_nvta = 372 and fac_nvta  is not null and impt_nvta > 0.00 and aju_nvta = 'S' 

select	*
from	nota_vta
where	fes_nvta = '2023-05-04' and fac_nvta <> 156994 and impt_nvta > 0.00 and aju_nvta = 'S' 

select	*
from	nota_vta
where	fes_nvta = '2023-05-09' and fac_nvta is not null and tip_nvta = 'C' and aju_nvta = 'S' 

update	nota_vta
set		fac_nvta = 157074, ser_nvta = 'EAM'
where	fes_nvta = '2023-05-07' and fac_nvta is null and aju_nvta = 'S' and tip_nvta IN('C','D','2','3','4')	

select	*
from	factura, det_fac
where	fol_fac = fol_dfac and ser_fac = ser_dfac and fec_fac >= '2023-05-01' and faccer_fac = 'S' and tid_dfac = 'B'
		and tlts_dfac = 0.00

SELECT	MIN(fol_nvta), MIN(vuelta_nvta), MIN(cia_nvta),MIN(pla_nvta)
FROM 	nota_vta 
WHERE	fes_nvta = '2023-06-01' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impt_nvta = 327.00 AND impasi_nvta = 5.80 AND tip_nvta = 'C'
		AND cia_nvta = '15'  AND fac_nvta IS NOT NULL AND tpa_nvta = 'E';
		
select	*
from	nota_vta
where	fol_nvta in(994586) 

select	*
from	nota_vta
where	edo_nvta = 'A' and impt_nvta = 190.47 and fes_nvta = '2023-06-04'
		and tpa_nvta = 'E' AND tip_nvta = 'C' 	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  AND fac_nvta IS NULL

select	*
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-05-06'
		AND tip_nvta = 'E' 	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta not  in(157069) and ser_nvta = 'EAM'
		
select	sum(impt_nvta)
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-06-01'
		AND tip_nvta in('B') 	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta not in(223532) and ser_nvta = 'EAM'
		
select	pla_nvta, fol_nvta, vuelta_nvta
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-06-05'
		AND tip_nvta in('E','B','C','D','2','3','4'	) 	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta is not null
order by 1,2,3

select	pla_dfac, fnvta_dfac, vuelta_dfac
from	factura, det_fac
where	fec_fac = '2023-06-05'  and tdoc_fac = 'I' and frf_fac is null and edo_fac <> 'C'
		and fol_fac = fol_dfac and ser_fac = ser_dfac
order by 1,2,3
	
select	sum(impt_nvta)
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-06-05'
		AND tip_nvta in('E','B','C','D','2','3','4'	) 	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta is not null not in(223531,223532) and fac_nvta is not null and ser_nvta = 'EAP'

-- CHEAR NOTAS CON FACTURA DE OTRO DIA-----------------------------------------------------------------------------------------------
select	*
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-06-11' AND tip_nvta in('E','B','C','D','2','3','4'	) 	
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		and fac_nvta not in(select fol_fac 
						from factura 
						where fec_fac = '2023-06-11' and tdoc_fac = 'I' )

select	*
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-06-11' AND tip_nvta in('E','B','C','D','2','3','4'	) 	
		--AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		and fac_nvta is not null and fac_nvta not in(select fol_fac 
													from factura 
													where fec_fac = '2023-06-11' and tdoc_fac = 'I')



select	sum(NVL(impasi_nvta,0))
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-06-01'
		AND tip_nvta in ('C','D','2','3','4') and aju_nvta = 'S'
		AND fac_nvta  in(199296) and ser_nvta = 'EAM'
		
select	SUM(tlts_dfac * pru_dfac), SUM(impasi_dfac)
from	det_fac
where	fol_dfac = 157071 and ser_dfac = 'EAM'

select	SUM(tlts_dfac * pru_dfac)
from	factura, det_fac
where   fec_fac >= '2023-06-01' and fec_fac <= '2023-06-01' and tdoc_fac = 'I' and faccer_fac = 'N'
		and fol_fac = fol_dfac and ser_fac = ser_dfac and frf_fac is null and edo_fac <> 'C'
group by 1,2,3
having   count(*) > 1

select	count(*)
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-05-06'
		AND tip_nvta in('C','D','2','3','4')	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta in(157071) and ser_nvta = 'EAM'

select	pla_dfac,fnvta_dfac
from	det_fac
where	fol_dfac = 157069 and ser_dfac = 'EAM'
order by pla_dfac,fnvta_dfac

select	pla_nvta, fol_nvta
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-05-06'
		AND tip_nvta = 'E' 	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta in(157069) and ser_nvta = 'EAM'
order by pla_nvta, fol_nvta

select	*
from	nota_vta
where	fol_nvta = 539197

select	*
from	factura
where	fec_fac > '2023-05-05' and tdoc_fac = 'I'
order by impt_fac

select	fec_fac, count(*)
from	factura
where	fec_fac > '2023-05-01' and tdoc_fac = 'I' and faccer_fac = 'N' and ser_fac[1] = 'P'-- and tfac_fac = 'S'
group by 1

select	*
from	factura
where	fec_fac = '2023-05-21' and tdoc_fac = 'I' and faccer_fac = 'N' 
order by impt_fac desc

select	*
from	deposito
where	cte_depo = '000612'


update	deposito
set		fec_depo = '2000-11-28'
where	cte_depo = '000612' and tpm_depo = '54'

select	*
from	nota_vta
where	tip_nvta = 'B' and ruta_nvta[1] = 'M' and impasi_nvta > 0 and edo_nvta in('S','A')

select	*
from	nota_vta
where	fes_nvta >= '2023-05-01' and edo_nvta = 'A' and tpa_nvta = 'C'  and fac_nvta is null and numcte_nvta = '035521'
		 fac_nvta in(select	fol_fac from factura where faccer_fac = 'S' and fec_fac >= '2023-05-01' and tfac_fac = 'S')
		 and numcte_nvta = '001012'
		 
SELECT * 
FROM 	nota_vta
WHERE 	fes_nvta = '2023-06-02' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impt_nvta = 668.80 AND impasi_nvta = 0.00 AND tip_nvta = 'C'
		AND cia_nvta = '15'  AND fac_nvta IS NULL AND tpa_nvta = 'E'
		
SELECT  * 
FROM 	nota_vta
WHERE 	fes_nvta = '2023-06-07' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impt_nvta = 519.60  AND impasi_nvta = 0.00 AND tip_nvta = 'C'
		AND cia_nvta = '15'  AND fac_nvta IS NULL AND tpa_nvta = 'E'
		AND pru_nvta = 18.0100000000
		
SELECT  * 
FROM 	nota_vta
WHERE 	fes_nvta = '2023-05-11' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tlts_nvta = 30.00  AND impasi_nvta = 0.00 AND tip_nvta = 'C'
		AND cia_nvta = '15'  AND fac_nvta IS NULL AND tpa_nvta = 'E'
		
SELECT  * 
FROM 	nota_vta
WHERE 	fes_nvta = '2023-05-15' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impasi_nvta = 0.00 AND tip_nvta = 'C'
		AND cia_nvta = '15'  AND fac_nvta IS NULL AND tpa_nvta = 'E'
		
SELECT  MOD(tlts_nvta,20.00),MOD(tlts_nvta,30.00), MOD(tlts_nvta,45.00), MOD(90,20.00)
FROM 	nota_vta
WHERE 	fol_nvta = 206822 and pla_nvta = '85'

SELECT  *
FROM 	nota_vta
WHERE 	fol_nvta = 206822 and pla_nvta = '85'

SELECT	cia_nvta,pla_nvta, fol_nvta, vuelta_nvta, tlts_nvta
INTO	vciasr,vplasr,vfolaju,vvaju,vtltsaj
FROM 	nota_vta 
WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impasi_nvta = vasist AND tip_nvta = vtipo AND tlts_nvta <= 90.00 
		AND ((tlts_nvta = 30.00 AND impt_nvta = vimpt) OR vtltsml = 0)
		AND cia_nvta = '15' AND fac_nvta IS NULL AND tpa_nvta = 'E'
