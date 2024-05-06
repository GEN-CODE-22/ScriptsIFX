DROP PROCEDURE fact_checknvtaajum;
EXECUTE PROCEDURE fact_checknvtaajum('2024-03-01','2024-03-01','E');

CREATE PROCEDURE fact_checknvtaajum
(	
	paramFecIni	DATE,
	paramFecFin	DATE,
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
			WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta IN('C','D','2','3','4')
					AND aju_nvta = 'S'
					AND fac_nvta IS NOT NULL) THEN
		FOREACH cNotas FOR
			SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta,n.impt_nvta,NVL(n.impasi_nvta, 0),tip_nvta,n.tlts_nvta
			INTO	vcia,vpla,vfolio,vvuelta,vimpt,vasist,vtipo,vtlts
			FROM 	nota_vta n
			WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
					AND aju_nvta = 'S'
					AND fac_nvta IS NOT NULL
					AND tip_nvta IN('C','D','2','3','4')
			ORDER BY 	tlts_nvta				
			IF	EXISTS(SELECT 1 
						FROM nota_vta
						WHERE fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
							AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E') THEN
				FOREACH cNotasAj FOR
					SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta	
					INTO	vciasr,vplasr,vfolaju,vvaju
					FROM 	nota_vta 
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
							AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E'
					IF vcount = 0 THEN 
						INSERT INTO fact_nvtaaju VALUES('C',paramFecFin,vcia,vpla,vfolio,vvuelta,vciasr,vplasr,vfolaju,vvaju);
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
						WHERE fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
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
						WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND impasi_nvta = vasist AND tip_nvta = vtipo AND tlts_nvta <= vtlts 
								AND ((tlts_nvta = vtltsml AND impt_nvta = vimpcil) OR vtltsml = 0)
								AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E'								
						ORDER BY tlts_nvta
						LET vttlts = vttlts + vtltsaj;
						IF vttlts <= vtlts THEN
							IF vcount = 0 THEN 
								INSERT INTO fact_nvtaaju VALUES('C',paramFecFin,vcia,vpla,vfolio,vvuelta,vciasr,vplasr,vfolaju,vvaju);							
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
							WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
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
			WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta = paramTipo
					AND aju_nvta = 'S'
					AND fac_nvta IS NOT NULL) THEN
			FOREACH cNotas FOR
				SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta,n.impt_nvta,NVL(n.impasi_nvta, 0),tip_nvta
				INTO	vcia,vpla,vfolio,vvuelta,vimpt,vasist,vtipo
				FROM 	nota_vta n
				WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
						AND aju_nvta = 'S'
						AND fac_nvta IS NOT NULL
						AND tip_nvta = paramTipo
				IF	EXISTS(SELECT 1 
							FROM nota_vta
							WHERE fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
								AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E')	THEN
					FOREACH cNotasAj FOR
						SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta	
						INTO	vciasr,vplasr,vfolaju,vvaju	
						FROM 	nota_vta 
						WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
								AND cia_nvta = vcia /*AND pla_nvta = vpla*/ AND fac_nvta IS NULL AND tpa_nvta = 'E'
						IF vcount = 0 THEN 
							INSERT INTO fact_nvtaaju VALUES('C',paramFecFin,vcia,vpla,vfolio,vvuelta,vciasr,vplasr,vfolaju,vvaju);
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
	ELSE
		IF paramTipo = 'B' THEN
			IF EXISTS (SELECT	1
				FROM 	nota_vta
				WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
						AND tip_nvta = paramTipo
						AND aju_nvta = 'S'
						AND fac_nvta IS NOT NULL) THEN
				FOREACH cNotas FOR
					SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta,n.impt_nvta,NVL(n.impasi_nvta, 0),tip_nvta
					INTO	vcia,vpla,vfolio,vvuelta,vimpt,vasist,vtipo
					FROM 	nota_vta n
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
							AND aju_nvta = 'S'
							AND fac_nvta IS NOT NULL
							AND tip_nvta = paramTipo
					IF	EXISTS(SELECT 1 
								FROM nota_vta
								WHERE fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
									AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
									AND cia_nvta = vcia AND fac_nvta IS NULL AND tpa_nvta = 'E')	THEN
						FOREACH cNotasAj FOR
							SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta	
							INTO	vciasr,vplasr,vfolaju,vvaju	
							FROM 	nota_vta 
							WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
									AND impt_nvta = vimpt AND impasi_nvta = vasist AND tip_nvta = vtipo
									AND cia_nvta = vcia /*AND pla_nvta = vpla*/ AND fac_nvta IS NULL AND tpa_nvta = 'E'
							IF vcount = 0 THEN 
								INSERT INTO fact_nvtaaju VALUES('C',paramFecFin,vcia,vpla,vfolio,vvuelta,vciasr,vplasr,vfolaju,vvaju);
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
WHERE	cia_nvta = '15' AND pla_nvta = '16' AND fol_nvta in(529953) AND vuelta_nvta = 3;

delete	
from	fact_nvtaaju
where	fec_naju = '2023-12-28'

update	fact_nvtaaju
set		vueltaf_naju = 3
where	rowid = 513

select	*
from	nota_vta
where	fac_nvta = 0 and ser_nvta = 'FACT'

SELECT	*
FROM 	nota_vta
WHERE	fes_nvta BETWEEN '2024-03-01' AND '2024-03-01' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta = 'E'
		AND aju_nvta = 'S'
		AND fac_nvta IS NOT NULL

select	pru_nvta, count(*)
from	nota_vta
where	fes_nvta = '2023-11-21' AND edo_nvta = 'A' AND impt_nvta > 0	
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')						
		AND tip_nvta IN('C','D','2','3','4')
group by 1
							
select	*
from	nota_vta
where	fes_nvta = '2023-11-21' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('C','D','2','3','4')
		AND pru_nvta = 17.5200000000;
							
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
from	nota_vta n, factura f
where	fes_nvta >= '2024-03-01' and fes_nvta <= '2024-03-31' and tip_nvta IN('C','D','2','3','4','E','B') and fac_nvta is not null 
		and edo_nvta in('A','S') and aju_nvta = 'S'
		and fac_nvta  in(select fol_fac from factura where fec_fac >= '2024-03-01' and faccer_fac = 'N' and ser_fac = n.ser_nvta)

select	*
from	nota_vta
where	fes_nvta = '2024-04-17' and fac_nvta is not null and tip_nvta IN('C','D','2','3','4') and aju_nvta = 'S'

select	*
from	nota_vta
where	fes_nvta = '2023-12-30' and fac_nvta not in(94695,94696,94697) and tip_nvta IN('C','D','2','3','4') and aju_nvta = 'S'

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
where	fes_nvta = '2023-11-18' and fac_nvta is not null and tip_nvta = 'C' and aju_nvta = 'S' and fac_nvta <> 555805

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
where	fol_nvta in(279374,279431,279508) 

select	*
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2024-02-02'
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')  AND fac_nvta IS NULL

select	sum(impt_nvta)
from	nota_vta
where	fac_nvta not in(124540,124541,124542) and fes_nvta ='2023-11-01' 
		AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
		
select	sum(impt_nvta)
from	nota_vta
where	fac_nvta not in(20395,20396,20397) and fes_nvta ='2023-11-01' 
		AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S') 

select	*
from	factura
where	frf_fac in(124540,124541,124542) and fec_fac >= '2023-11-01'



select	sum(impt_nvta), sum(impasi_nvta)
from	nota_vta
where	edo_nvta = 'A' and fes_nvta >= '2023-06-26' and fes_nvta <= '2023-05-31'
		AND tip_nvta = 'E' 	--AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta in (select fol_fac from factura where fec_fac >= '2023-05-01' and fec_fac <= '2023-05-31'
			and frf_fac is null and tdoc_fac = 'I' and faccer_fac = 'N' and feccan_fac is null and edo_fac <> 'C')
		AND fac_nvta not  in() --and ser_nvta = 'EAM'
		
select	sum(impt_nvta),sum(impasi_nvta)
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2023-08-04' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') AND tip_nvta in('C','D','2','3','4')	 and fac_nvta is not null
		AND fac_nvta in(145212) and ser_nvta = 'EBC'
		
select	*
from	nota_vta
where	edo_nvta = 'S' and fes_nvta = '2023-09-13'
		AND tip_nvta in('C','D','2','3','4'	) 	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
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
where	edo_nvta = 'A' and fes_nvta = '2024-04-17' AND tip_nvta in('E','B','C','D','2','3','4'	) 	
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		and fac_nvta not in(select fol_fac 
						from factura 
						where fec_fac = '2024-04-17' and tdoc_fac = 'I' and frf_fac is null)

-- CHEAR FACTURA DE OTRO DIA-----------------------------------------------------------------------------------------------
select	*
from	factura, det_fac, nota_vta
where	pla_fac = pla_dfac and fol_fac = fol_dfac and ser_fac = ser_dfac 
		and pla_nvta = pla_dfac and fol_nvta = fnvta_dfac and vuelta_nvta = vuelta_dfac
		and fes_nvta <> '2024-04-17' and fec_fac = '2024-04-17'
		and frf_fac is null

-- BUSCAR NOTA FACTURADA NO LIGADA EN TABLA NOTA_VTA----------------------------------------------------------------------
select  *
from	factura, det_fac d
where	tdoc_fac = 'I' and fec_fac = '2024-04-17'  and faccer_fac = 'N'
		and fol_fac = d.fol_dfac and ser_fac = d.ser_dfac
		and fnvta_dfac in(select fol_nvta from nota_vta 
				where fes_nvta = '2024-04-17'and edo_nvta in('A') and fac_nvta is null
						and vuelta_nvta = d.vuelta_dfac and tip_nvta = d.tid_dfac)
						
-- CHECAR NOTAS CON ESTATUS S -----------------------------------------------------------------------------------------------
select	*
from	nota_vta 
where   fes_nvta = '2024-04-19' and edo_nvta = 'S' and tpa_nvta = 'C'
		
update	nota_vta
set		edo_nvta = 'A'
where	fes_nvta = '2024-04-09' and edo_nvta = 'S'


-- CHECAR NOTAS CON PRECIO INCORRECTO-----------------------------------------------------------------------------------------------
select	pla_nvta, fol_nvta, impt_nvta, pru_nvta, tlts_nvta, pru_dfac, tlts_dfac, impt_nvta, tlts_dfac * pru_dfac
from	det_fac, nota_vta
where	fnvta_dfac = fol_nvta and vuelta_dfac = vuelta_nvta and pla_dfac = pla_nvta
		and fol_dfac = 137785 and ser_dfac = 'EAR' and impt_nvta <> (tlts_dfac * pru_dfac)
		
select	*
from	nota_vta
where	fes_nvta = '2024-04-17' and edo_nvta in('A')  --and impt_nvta = 183.68
		and ((impt_nvta - (tlts_nvta * pru_nvta) < -0.01) or  (impt_nvta - (tlts_nvta * pru_nvta) > 0.01))
		and tip_nvta in('C','D','2','3','4', 'E','B')
		
select	*
from	nota_vta
where	edo_nvta = 'A' and fes_nvta = '2024-02-19' AND tip_nvta in('E','B','C','D','2','3','4'	) 	
		--AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		and fac_nvta is null and fac_nvta not in(select fol_fac 
													from factura 
													where fec_fac = '2024-02-19' and tdoc_fac = 'I')

													
select	*
from	factura, det_fac, nota_vta
where	fec_fac = '2023-12-05' and tdoc_fac = 'I' and faccer_fac = 'N'
		and fol_fac = fol_dfac and ser_fac = ser_dfac
		and pla_dfac = pla_nvta and fnvta_dfac = fol_nvta and vuelta_dfac = vuelta_nvta
		and fes_nvta <> '2023-12-05'
		
select	*
from	nota_vta
where	fes_nvta = '2023-12-05'
		AND tip_nvta in ('C','D','2','3','4','E','B')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta is null
		and fol_nvta in(select fnvta_dfac from factura, det_fac where fec_fac = '2023-12-05' and fol_fac = fol_dfac 
						and ser_fac = ser_dfac and fnvta_dfac = fol_nvta and vuelta_nvta = vuelta_dfac)

select pla_dfac, fnvta_dfac, vuelta_dfac
from factura, det_fac 
where fec_fac = '2023-12-05' and fol_fac = fol_dfac 
		and ser_fac = ser_dfac 
		AND (frf_fac IS NULL OR frf_fac = 0)
		AND faccer_fac = 'N'
order by 1,2,3

select	pla_nvta, fol_nvta, vuelta_nvta
from	nota_vta
where	fes_nvta = '2023-12-05'
		AND tip_nvta in ('C','D','2','3','4','E','B')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta is not null		
order by 1,2,3

update  nota_vta
set	 	edo_nvta = 'A'
where	fol_nvta in(425002,425003,425004,425005,425006,425007,425008) and vuelta_nvta = 2 and pla_nvta = '88'

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
where	edo_nvta = 's' and fes_nvta = '2023-07-01'
		AND tip_nvta = 'E' 	AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		AND fac_nvta in(157069) and ser_nvta = 'EAM'
order by pla_nvta, fol_nvta

select	*
from	nota_vta
where	fol_nvta in(539197) and vuelta_nvta =

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
WHERE 	fes_nvta = '2023-09-09' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impt_nvta = 1543.50  AND impasi_nvta = 0.00 AND tip_nvta = 'C'
		AND cia_nvta = '15'  AND fac_nvta IS NULL AND tpa_nvta = 'E'
		AND pru_nvta = 18.0100000000
		
SELECT  *
FROM 	nota_vta
WHERE 	fes_nvta = '2023-09-07' 
		AND impt_nvta = 1496.70
group by 1,2
order by 1,2

SELECT  * 
FROM 	nota_vta
WHERE 	fes_nvta >= '2023-09-09' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tlts_nvta = 90.00   AND tip_nvta = 'C'
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
FROM 	nota_vta where fes_nvta = '2023-08-07' and impasi_nvta = 13.92 and tip_nvta = 'B'
WHERE 	fol_nvta = 206822 and pla_nvta = '85'

SELECT	cia_nvta,pla_nvta, fol_nvta, vuelta_nvta, tlts_nvta
INTO	vciasr,vplasr,vfolaju,vvaju,vtltsaj
FROM 	nota_vta 
WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impasi_nvta = vasist AND tip_nvta = vtipo AND tlts_nvta <= 90.00 
		AND ((tlts_nvta = 30.00 AND impt_nvta = vimpt) OR vtltsml = 0)
		AND cia_nvta = '15' AND fac_nvta IS NULL AND tpa_nvta = 'E'
		
select	count(*)
from	det_fac
where	fol_dfac in(select fol_fac from factura where fec_fac between '2023-05-01' and '2023-05-31' and tdoc_fac = 'I' 
					and tfac_fac = 'S' and faccer_fac = 'S')
		and pla_dfac <> '13'
		
select	sum(tlts_dfac*pru_dfac)
from	det_fac
where	fol_dfac in(select fol_fac from factura where fec_fac between '2023-05-01' and '2023-05-31' and tdoc_fac = 'I' 
					and tfac_fac = 'S' and faccer_fac = 'S')
		and pla_dfac = '79'	
		
select	*
from	nota_vta
where	fes_nvta = '2023-09-09' AND edo_nvta = 'A' and fac_nvta is null AND aju_nvta = 'S'-- (aju_nvta IS NULL OR aju_nvta <> 'S')	
		AND tip_nvta in('C','D','2','3','4') 	and impasi_nvta > 0	
		
		
select	fec_fac, count(*)
from	factura
where	fec_fac between '2023-06-01' and '2023-06-30' and faccer_fac = 'N' and tdoc_fac ='I' and tfac_fac = 'S'
group by 1
order by 1

select	*
from	factura
where	fec_fac between '2023-06-28' and '2023-06-30' and faccer_fac = 'N' and tdoc_fac ='I' and tfac_fac = 'S'
					
select	sum(impt_fac)
from	factura
where	fec_fac between '2023-06-01' and '2023-06-30' and faccer_fac = 'S' and tdoc_fac ='I' and tfac_fac = 'S'		

select	*
from	factura
where	fec_fac = '2023-07-05'	and tdoc_fac = 'I' and impt_fac = 1001.08	

select	sum(tlts_dfac * pru_dfac), sum(impasi_dfac)
from	det_fac
where	fol_dfac = 159552 and ser_dfac = 'EAM'

select	*
from	det_fac
where	fol_dfac = 159552 and ser_dfac = 'EAM'

select	sum(impt_nvta), sum(impasi_nvta)
from	nota_vta
where	fes_nvta = '2023-08-14' and edo_nvta = 'A' 
		and (aju_nvta IS NULL OR aju_nvta <> 'S')	
		and tip_nvta in('B')
		and fac_nvta is not null not in(137584)

select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2024-01-11' and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		and (aju_nvta IS NULL OR aju_nvta <> 'S')	
		and fac_nvta is not null  137584 and ser_nvta = 'EAJ'
		
select	sum(impt_nvta), sum(impasi_nvta)
from	nota_vta
where	fes_nvta = '2023-09-05' and edo_nvta = 'A' and fac_nvta is not null and tip_nvta = 'E' 
		and fac_nvta not in (203509) and ser_nvta = 'EAM'

select	pla_nvta, fol_nvta
from	nota_vta
where	fes_nvta = '2023-08-14' and edo_nvta = 'A' and (aju_nvta IS NULL OR aju_nvta <> 'S')	and tip_nvta in('B')
		and fac_nvta is not null
order by pla_nvta, fol_nvta

select	pla_dfac, fnvta_dfac
from	factura, det_fac
where	pla_fac = pla_dfac and fol_fac = fol_dfac and ser_fac = ser_dfac
		and fec_fac = '2023-08-14' and tdoc_fac = 'I'
		and tid_dfac = 'B'
order by pla_dfac, fnvta_dfac

select	*
from	nota_vta
where	fes_nvta = '2024-02-27' and edo_nvta in('A') 
		and impt_nvta  = 1575.2
		and pru_nvta = 17.54
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and tip_nvta in('C','D','2','3','4')
		
select	*
from	nota_vta
where	fes_nvta = '2023-09-09' and edo_nvta in('A')  and tip_nvta not in('C','D','2','3','4', 'E','B') and impt_nvta > 0.00
		and fac_nvta is null
		
select	NVL(MIN(fol_nvta),0)
from	nota_vta
where	fes_nvta = '2023-08-19' and edo_nvta in('A') 
		and ((impt_nvta - (tlts_nvta * pru_nvta) < -0.1) or  (impt_nvta - (tlts_nvta * pru_nvta) > 0.1))
		and tip_nvta in('C','D','2','3','4', 'E','B')

select	fec_fac, count(*)
from	factura
where	fec_fac >= '2023-12-01' and fec_fac <= '2023-12-31' and frf_fac is null and edo_fac <> 'C' and tdoc_fac = 'I' and faccer_fac = 'N'
group by 1
	
select	fec_fac, count(*)
from	factura
where	fec_fac >= '2024-01-01' and fec_fac <= '2024-01-31' and tdoc_fac = 'I' and tfac_fac = 'S' and faccer_fac = 'N' and frf_fac is null and edo_fac <> 'C' 
group by 1

select	count(*)
from	factura
where	fec_fac >= '2024-03-01' and fec_fac <= '2024-03-31' and frf_fac is null and edo_fac <> 'C' and tdoc_fac = 'I' and faccer_fac = 'N'
	
select	count(*)
from	factura
where	fec_fac >= '2024-03-01' and fec_fac <= '2024-03-31' and tdoc_fac = 'I' and tfac_fac = 'S' and faccer_fac = 'N' and frf_fac is null and edo_fac <> 'C' 


select	*
from	factura, det_fac
where	fec_fac = '2023-08-02' and tdoc_fac = 'I'  and faccer_fac = 'N'
		and fol_dfac = fol_fac and ser_fac = ser_dfac and fnvta_dfac is null

select	*
from	factura
where	fec_fac = '2023-08-02' and faccer_fac = 'N' and tdoc_fac= 'I' and frf_fac is null

select	*
from	det_fac
where	fol_dfac = 137294 and ser_dfac = 'EAR' and fnvta_dfac = 588848

update	det_fac
set		pru_dfac = 9.3900000000
where	fol_dfac = 137785 and ser_dfac = 'EAR' and fnvta_dfac = 595338 and vuelta_dfac = 2

select	*
from	nota_vta 
where   fes_nvta = '2023-09-15' and edo_nvta = 'S' 
		and numcte_nvta in(select numcte_nvta from nota_vta where fes_nvta >= '2023-08-18' and edo_nvta = 'A' )

update	nota_vta
set		pru_nvta = 9.4700000000, tprd_nvta = '007'
where	fol_nvta in(624536) 
		and pla_nvta = '02' and vuelta_nvta = 14

select	*
from	nota_vta
where	numcte_nvta = '999999' and fes_nvta >= '2023-08-18'

select	*
from	nota_vta
where	fac_nvta = 160117 and ser_nvta = 'EAM'

select	*
from	precios
where	tpr_prc = '223'

select	*
from	mov_prc
where	tpr_mprc = '007'
order by fei_mprc desc

select	*
from	nota_vta
where	fol_nvta in(566705,566706,566682,566683,566684,566685,566686,566687,566688,566689,566690,566691,566692,566693,
					566694,566695,566696,566697,566698,566859,566810,566811,566812,566822,566832,566842,566849,566865,
					566866,566867,566868) and pla_nvta = '39' and vuelta_nvta = 1
					
update	nota_vta
set		pru_nvta = 10.2700000000
where	fol_nvta in(462846,462880,462881) and pla_nvta = '23' and vuelta_nvta = 3

select	*
from	precios
where	tpr_prc = '001'	

select	*
from	mov_prc
where	tpr_mprc = '001' and fei_mprc >= '2024-02-01'
order by 	fei_mprc desc		
						
select	*
from	nota_vta
where	fes_nvta = '2023-09-04' and impt_nvta = 1466.10
			
SELECT  *
FROM 	nota_vta
WHERE 	fes_nvta = '2024-04-10' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impt_nvta = 585.30 and impasi_nvta = 0.00 AND tip_nvta = 'C'
		AND cia_nvta = '15' AND fac_nvta IS NULL AND tpa_nvta = 'E'		
		
SELECT 	*
FROM 	nota_vta
WHERE 	fes_nvta = '2023-11-21' AND edo_nvta = 'A' AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impasi_nvta = 0.00 AND tip_nvta = 'C' AND tlts_nvta <= 120
		AND cia_nvta = '15' AND fac_nvta IS NULL AND tpa_nvta = 'E'
		
SELECT	*
FROM 	nota_vta
WHERE	fes_nvta = '2024-01-19' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta = 'C'
		AND aju_nvta = 'S'
		AND fac_nvta IS NOT NULL
		
