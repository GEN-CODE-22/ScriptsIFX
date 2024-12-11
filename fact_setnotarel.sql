DROP PROCEDURE fact_setnotarel;
EXECUTE PROCEDURE  fact_setnotarel(248145,'EAE','I');
EXECUTE PROCEDURE  fact_setnotarel(248145,'EAE','C');
			
CREATE PROCEDURE fact_setnotarel
(
	paramFolio   	INT,
	paramSerie		CHAR(4),
	paramAction		CHAR(1) --I = Agregar C = Cancelar
)

RETURNING  
 CHAR(1);

DEFINE vreturn 	CHAR(1);
DEFINE vfolfac	INT;
DEFINE vserfac 	CHAR(4);
DEFINE vfolio	INT;
DEFINE vfolrf	INT;
DEFINE vserrf 	CHAR(4);
DEFINE vcierre 	CHAR(1);
DEFINE vfolant	INT;
DEFINE vserant 	CHAR(4);
DEFINE vfolc	INT;
DEFINE vserc 	CHAR(4);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vnocte	CHAR(6);
DEFINE vtpa 	CHAR(1);
DEFINE vfaccer 	CHAR(1);
DEFINE vtfac 	CHAR(1);
DEFINE vvuelta	INT;

LET vreturn = 'E';

LET vfolfac = paramFolio;
LET vserfac = paramSerie;

SELECT	cia_fac, pla_fac, numcte_fac, NVL(frf_fac,0), NVL(srf_fac,''), NVL(folcan_fac,0), NVL(sercan_fac,''), tpa_fac,
		NVL(fant_fac,0), NVL(sant_fac,''), faccer_fac, tfac_fac
INTO	vcia,vpla,vnocte,vfolrf,vserrf,vfolc,vserc,vtpa,vfolant,vserant,vfaccer,vtfac
FROM	factura
WHERE	fol_fac = paramFolio and ser_fac = paramSerie;

IF paramAction = 'I' AND vfolrf = 0 AND vserrf = '' AND vfolc = 0 AND vserc = '' THEN
	IF EXISTS(	SELECT	1
				FROM	factura f, det_fac d
				WHERE	f.fol_fac <> paramFolio AND f.fol_fac = d.fol_dfac AND f.ser_fac = d.ser_dfac AND f.faccer_fac = 'N'
						AND f.fec_fac > TODAY - 7 AND d.fnvta_dfac IN(SELECT fnvta_dfac FROM det_fac 
										WHERE fol_dfac = paramFolio AND ser_dfac = paramSerie
												AND cia_dfac = d.cia_dfac AND pla_dfac = d.pla_dfac AND fnvta_dfac = d.fnvta_dfac 
												AND vuelta_dfac = d.vuelta_dfac)) THEN
		LET vreturn = 'D';
		RETURN vreturn;
	END IF;
END IF;

IF paramAction = 'C' THEN
	LET vfolfac = NULL;
	LET vserfac = NULL;
	IF vfolrf > 0 AND vserrf <> '' THEN 
		SELECT	NVL(faccer_fac,'')
		INTO	vcierre
		FROM	factura
		WHERE	fol_fac = vfolrf and ser_fac = vserrf;	
		IF vcierre = 'S' THEN
			LET vfolfac = vfolrf;
			LET vserfac = vserrf;
		END IF;
		
	END IF;
	IF vfolc > 0 AND vserc <> '' THEN 
		LET vfolfac = vfolc;
		LET vserfac = vserc;
	END IF;
END IF;

IF vcia <> '' AND vpla <> '' AND vnocte <> '' THEN
	FOREACH cDetalle FOR
		SELECT	cia_dfac, pla_dfac, fnvta_dfac, vuelta_dfac
		INTO	vcia,vpla,vfolio,vvuelta
		FROM	det_fac 
		WHERE	fol_dfac = paramFolio AND ser_dfac = paramSerie
		
		IF EXISTS(SELECT 	1 
		  	FROM 	nota_vta 
		  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta) THEN
			UPDATE  nota_vta
			SET		fac_nvta = vfolfac, ser_nvta = vserfac
			WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
		END IF;
		IF EXISTS(SELECT 	1 
		  	FROM 	rdnota_vta 
		  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta) THEN
			UPDATE  rdnota_vta
			SET		fac_nvta = vfolfac, ser_nvta = vserfac
			WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
		END IF;
		IF EXISTS(SELECT 	1 
		  	FROM 	hnota_vta 
		  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta) THEN
			UPDATE  hnota_vta
			SET		fac_nvta = vfolfac, ser_nvta = vserfac
			WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
		END IF;
		
		IF (vtpa = 'C' OR vtpa = 'G') OR (vfolant > 0 AND vserant <> '') THEN
			UPDATE	doctos
			SET		ffac_doc = vfolfac, sfac_doc = vserfac
			WHERE	cia_doc = vcia AND pla_doc = vpla AND fol_doc = vfolio AND vuelta_doc = vvuelta;
			
			UPDATE	mov_cxc
			SET		ffac_mcxc = vfolfac, sfac_mcxc = vserfac
			WHERE	cia_mcxc = vcia AND pla_mcxc = vpla AND doc_mcxc = vfolio AND vuelta_mcxc = vvuelta;
		END IF;

	END FOREACH;
	LET vreturn = 'A';
END IF;

RETURN vreturn;
END PROCEDURE; 

select	*
from	nota_vta
where	fac_nvta is null and edo_nvta in('A','S') and tpa_nvta = 'C'
order by fes_nvta desc

select	*
from	factura
where	fec_fac = '2020-10-07'
order by fyh_fac desc

select	*
from	factura
where	fol_fac in(25599) and ser_fac = 'EAPH'

update	factura
set		feccan_fac = '2022-09-05'
where	fol_fac = 27163 and ser_fac = 'EAB'

select	rowid,*
from	det_fac --where tid_dfac = 'A' order by rowid desc
where	fol_dfac in(157630)  and ser_dfac = 'EAM' 

select	rowid,*
from	cfd --where tid_dfac = 'A' order by rowid desc
where	fol_cfd in(4230)  and ser_cfd = 'PAF' 

update	cfd --where tid_dfac = 'A' order by rowid desc
set		est_cfd = 'C'
where	fol_cfd in(27163)  and ser_cfd = 'EAPC' 

select	*
from	nota_vta
where	fac_nvta = 157666 and tpa_nvta = 'C'

select	*
from	nota_vta
where	fol_nvta in(148389)

update	nota_vta
set		fac_nvta = null, ser_nvta = null
where	fol_nvta in(72173,72157,72174,72172,72170,72171)

update	nota_vta
set		fes_nvta = '2022-09-04'
where	fol_nvta in(376411)

select	*
from	doctos
where	fol_doc in(148389) 
			and pla_doc='13' 
			
update	doctos
set		abo_doc = 0.00, sal_doc = car_doc, ffac_doc = null, sfac_doc = null
where	fol_doc in(72173,72157,72174,72172,72170,72171) 
			and pla_doc='85'

select	rowid,*
from	mov_cxc 
where	doc_mcxc in(148389)
		and pla_mcxc ='13' 


delete
from	mov_cxc 
where	doc_mcxc in(72173,72157,72174,72172,72170,72171)	
		and pla_mcxc = '85' and fliq_mcxc = 60419
		
update	mov_cxc 
set		ffac_mcxc = null, sfac_mcxc = null
where	doc_mcxc in(72173,72157,72174,72172,72170,72171)	
		and pla_mcxc = '85' and fliq_mcxc = 604023 
		
select	*
from	doctos
where	ffac_doc = 157732 and sfac_doc = 'EAM'

update	doctos
set		ffac_doc = null, sfac_doc = null
where	ffac_doc = 157706 and sfac_doc = 'EAM'

select	*
from	mov_cxc
where	ffac_mcxc = 157706 and sfac_mcxc = 'EAM'


update	mov_cxc
set		ffac_mcxc = NULL, sfac_mcxc = null
where	ffac_mcxc = 157706 and sfac_mcxc = 'EAM'

select	*
from	factura f, det_fac d
where	f.fol_fac <> 1161324 and f.fol_fac = d.fol_dfac and f.ser_fac = d.ser_dfac AND f.faccer_fac = 'N'
		and f.fec_fac > TODAY - 6 and d.fnvta_dfac in(select fnvta_dfac from det_fac where fol_dfac = 1161324 and ser_dfac = 'EAB'
							and cia_dfac = d.cia_dfac and pla_dfac = d.pla_dfac and fnvta_dfac = d.fnvta_dfac 
							and vuelta_dfac = d.vuelta_dfac)
							
select	*
from	factura
where	tdoc_fac = 'I' and fec_fac >= '2023-09-01' and faccer_fac = 'S'

select	*
from	factura
where	frf_fac = 404109

select	*
from	changes_liq
where	nvta_cliq = 287311
