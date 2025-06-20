EXECUTE PROCEDURE obt_facturado('2025-05-01','2025-05-01');

CREATE PROCEDURE "fuente".obt_facturado(paramfec1 DATE,paramfec2 DATE)
RETURNING DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),
          DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),
          DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),
          DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2);
{ Obtiene lo factura del periodo }
   DEFINE ximp_est   DECIMAL(16,2);
   DEFINE ximp_suel  DECIMAL(16,2);
   DEFINE ximp_carb  DECIMAL(16,2);
   DEFINE ximp_asie  DECIMAL(16,2);
   DEFINE ximp_asic  DECIMAL(16,2);
   DEFINE xximp_asic DECIMAL(16,2);
   DEFINE ximp_asib  DECIMAL(16,2);
   DEFINE ximp_asid  DECIMAL(16,2);
   DEFINE ximp_asia  DECIMAL(16,2);
   DEFINE ximp_asis  DECIMAL(16,2);
   DEFINE ximpt_fac  DECIMAL(16,2);
   DEFINE ximpt_fas  DECIMAL(12,2);
   DEFINE ximpt_fasc DECIMAL(12,2);
   DEFINE ximp_ncrd  DECIMAL(16,2);
   DEFINE ximp_mnc   DECIMAL(16,2);
   DEFINE ximp_can   DECIMAL(16,2);
   DEFINE ximp_erup  DECIMAL(16,2);
   DEFINE ximp_eruc  DECIMAL(16,2);
   DEFINE ximp_vand  DECIMAL(16,2);
   DEFINE ximp_vmed  DECIMAL(16,2);
   DEFINE ximp_desd  DECIMAL(16,2);
   DEFINE ximpt_vta  DECIMAL(16,2);
   DEFINE ximp_chqi  DECIMAL(16,2);
   DEFINE ximp_chqc  DECIMAL(16,2);

   DEFINE ximp_comi  DECIMAL(16,2);
   DEFINE ximp_inte  DECIMAL(16,2);
   DEFINE ximp_bien  DECIMAL(16,2);
   DEFINE ximp_dona  DECIMAL(16,2);
   DEFINE ximp_anti  DECIMAL(16,2);
   DEFINE ximp_mant  DECIMAL(16,2);
   DEFINE xfecd      DATE;
   DEFINE xdia       SMALLINT;
   DEFINE xdia2      SMALLINT;
   DEFINE xmes1      SMALLINT;
   DEFINE xanio1     SMALLINT;
 

   LET xfecd  = TODAY;
   LET xmes1  = MONTH(xfecd);
   LET xanio1 = YEAR(xfecd);
   LET xdia   = DAY(xfecd);
   IF xmes1 = 1 or xmes1 = 3 or xmes1 = 5 or xmes1 = 7 or xmes1 = 8 or
      xmes1 = 10 or xmes1 = 12 THEN
      LET xdia2 = 31;
   ELSE 
      IF xmes1 = 4 or xmes1 = 6 or xmes1 = 9 or xmes1 = 11 THEN
         LET xdia2 = 30;
      ELSE
         IF xanio1 / 4 = 0 THEN
            LET xdia2 = 29;
         ELSE
            LET xdia2 = 28;
         END IF;
      END IF;
   END IF;
   LET xfecd  = xfecd - xdia2 - xdia + 1;

   {Obtiene lo facturado}
   LET ximpt_fac = 0;
   SELECT SUM(impt_fac)
      INTO ximpt_fac
   FROM factura
   WHERE fec_fac >= paramfec1 AND fec_fac <= paramfec2
     AND impr_fac = 'E'
     AND tdoc_fac IN('I','V')
     AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0);
   IF ximpt_fac IS NULL THEN LET ximpt_fac = 0; END IF;

   {Obtiene lo Asistenacio facturado}
   LET ximpt_fas = 0;
   SELECT SUM(impasi_dfac)
      INTO ximpt_fas
   FROM factura,det_fac
   WHERE fec_fac >= paramfec1 AND fec_fac <= paramfec2
     AND impr_fac = 'E'
     AND tdoc_fac IN('I','V')
  AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0)
     AND fol_fac = fol_dfac
     AND ser_fac = ser_dfac
     AND cia_fac = cia_dfac
     AND pla_fac = pla_dfac;
   IF ximpt_fas IS NULL
 THEN LET ximpt_fas = 0; END IF;
   LET ximpt_fac = ximpt_fac - ximpt_fas;

   {Obtiene lo facturas Canceladas de otros dias}
   LET ximp_can = 0;
   SELECT SUM(impt_fac)
      INTO ximp_can
   FROM factura
   WHERE feccan_fac >= paramfec1 AND feccan_fac <= paramfec2
     AND impr_fac = 'E'
     AND tdoc_fac IN('I','V')
     AND edo_fac  = 'C'
     AND faccer_fac = 'N'
     AND fec_fac <> feccan_fac
     AND (frf_fac IS NULL OR frf_fac = 0);
   IF ximp_can IS NULL THEN LET ximp_can = 0; END IF;

   {Obtiene lo Asistenacio facturado Canceladas de otros dias}
   LET ximpt_fasc = 0;
   SELECT SUM(impasi_dfac)
      INTO ximpt_fasc
   FROM factura,det_fac
   WHERE feccan_fac >= paramfec1 AND feccan_fac <= paramfec2
     AND impr_fac = 'E'
     AND tdoc_fac IN('I','V')  
AND edo_fac  = 'C'
     AND faccer_fac = 'N'
     AND fec_fac <> feccan_fac
     AND (frf_fac IS NULL OR frf_fac = 0)
     AND fol_fac = fol_dfac
     AND ser_fac = ser_dfac
     AND cia_fac = cia_dfac
     AND pla_fac = pla_dfac;
   IF ximpt_fasc IS NULL 
THEN LET ximpt_fasc = 0; END IF;
   LET ximp_can = ximp_can - ximpt_fasc;

   {Obtiene las Notas de credito Efectivo}
   LET ximp_ncrd = 0;    
   SELECT sum(impt_ncrd)
      INTO ximp_ncrd
      FROM nota_crd
      WHERE fec_ncrd >= paramfec1 AND fec_ncrd <= paramfec2
        AND apl_ncrd = 'N'
        AnD edo_ncrd <> 'C'
        AND tdoc_ncrd = 'E'
        AND (tpa_ncrd = 'E'OR tpa_ncrd = 'X')
        AND impr_ncrd = 'E'
        AND (frnc_ncrd = 0 OR frnc_ncrd IS NULL);
   IF ximp_ncrd IS NULL THEN LET ximp_ncrd = 0; END IF;

   {Obtiene las Notas de credito a Credito}
   LET ximp_mnc = 0;
   SELECT SUM(imp_mcxc)
      INTO ximp_mnc
      FROM mov_cxc
      WHERE fec_mcxc >= paramfec1 AND fec_mcxc <= paramfec2
        AND (tpm_mcxc = '52' OR tpm_mcxc = '98')
        AND sta_mcxc <> 'C';
   IF ximp_mnc IS NULL THEN LET ximp_mnc = 0; END IF;
   {LET ximp_ncrd = ximp_ncrd + ximp_mnc;}

   {Obtiene Cheque Devuelto que ingresaron}
   LET ximp_chqi = 0;
   SELECT SUM(imp_mcxc)
      INTO ximp_chqi
      FROM mov_cxc
      WHERE fec_mcxc >= paramfec1 AND fec_mcxc <= paramfec2
        AND tip_mcxc = '03'
        AND tpm_mcxc = '03'
        AND sta_mcxc <> 'C';
   IF ximp_chqi IS NULL THEN LET ximp_chqi = 0; END IF;

   {Obtiene Cheque Devuelto que Cobrados}
   LET ximp_chqc = 0;
   SELECT SUM(imp_mcxc)
      INTO ximp_chqc
      FROM mov_cxc
      WHERE fec_mcxc >= paramfec1 AND fec_mcxc <= paramfec2
        AND tip_mcxc = '03'
        AND tpm_mcxc >= '50'
        AND sta_mcxc <> 'C';
   IF ximp_chqc IS NULL THEN LET ximp_chqc = 0; END IF;

   {Obtiene la Ventas de Pipas}
   LET ximp_est  = 0;
   LET ximp_carb = 0;
   LET ximp_asie = 0;
   IF paramfec1 < xfecd THEN
      SELECT SUM(CASE WHEN tip_nvta = 'E' THEN impt_nvta ELSE 0 END),
             SUM(CASE WHEN tip_nvta = 'B' THEN impt_nvta ELSE 0 END),
             SUM(CASE WHEN asiste_nvta = 'S' THEN impasi_nvta ELSE 0 END)
         INTO ximp_est,ximp_carb,ximp_asie
         FROM urdnota_vta
         WHERE fes_nvta >= paramfec1 AND fes_nvta <= paramfec2
           AND ruta_nvta[1] = 'M'
           AND edo_nvta = 'A'
           AND (aju_nvta IS NULL OR aju_nvta <> 'S');
   ELSE
      SELECT SUM(CASE WHEN tip_nvta = 'E' THEN impt_nvta ELSE 0 END),
             SUM(CASE WHEN tip_nvta = 'B' THEN impt_nvta ELSE 0 END),
    
         SUM(CASE WHEN asiste_nvta = 'S' THEN impasi_nvta ELSE 0 END)
         INTO ximp_est,ximp_carb,ximp_asie
         FROM nota_vta
         WHERE fes_nvta >= paramfec1 AND fes_nvta <= paramfec2
           AND ruta_nvta[1] = 'M'
           AND edo_nvta = 'A'
           AND (aju_nvta IS NULL OR aju_nvta <> 'S');
   END IF;
   IF ximp_est  IS NULL THEN LET ximp_est  = 0; END IF;
   IF ximp_carb IS NULL THEN LET ximp_carb = 0; END IF;
   IF ximp_asie IS NULL THEN LET ximp_asie = 0; END IF;

   {Obtiene la Ventas de Cilindros}
   LET ximp_eruc = 0;
   LET ximp_asic = 0;
   LET xximp_asic = 0;
   SELECT sum(impt_eruc),sum(impasi_eruc)
      INTO ximp_eruc,ximp_asic
      FROM empxrutc
      WHERE fec_eruc >= paramfec1 AND fec_eruc <= paramfec2
        AND edo_eruc = "C";
   SELECT sum(impasi_eruc)
      INTO xximp_asic
      FROM empxrutcbaj
      WHERE fec_eruc >= paramfec1 AND fec_eruc <= paramfec2
        AND edo_eruc = "C";
   IF ximp_eruc IS NULL THEN LET ximp_eruc = 0; END IF;
   IF ximp_asic IS NULL THEN LET ximp_asic = 0; END IF;
   IF xximp_asic IS NULL THEN LET xximp_asic = 0; END IF;
   LET ximp_asic = ximp_asic + xximp_asic;

   {Obtiene la Ventas de Anden}
   LET ximp_vand = 0;
   LET ximp_asia = 0;
   SELECT sum(impt_vand)
      INTO ximp_vand
   
   FROM venxand
      WHERE fec_vand >= paramfec1 AND fec_vand <= paramfec2
        AND edo_vand = "C";
   IF ximp_vand IS NULL THEN LET ximp_vand = 0; END IF;
   IF ximp_asia IS NULL THEN LET ximp_asia = 0; END IF;

   {Obtiene la Ventas de Contable de Medidor o Carburacion}
   LET ximp_vmed = 0;
   LET ximp_asib = 0;
   SELECT sum(impt_vmed),sum(impasi_vmed)
      INTO ximp_vmed,ximp_asib
      FROM venxmed
      WHERE fec_vmed >= paramfec1 AND fec_vmed <= paramfec2
        AND edo_vmed = "C";
   IF ximp_vmed IS NULL THEN LET ximp_vmed = 0; END IF;
   IF ximp_asib IS NULL THEN LET ximp_asib = 0; END IF;

   {Obtiene la Ventas de Descarga Directa}
   LET ximp_desd = 0;
   LET ximp_asid = 0;
   SELECT sum(impt_desd)
      INTO ximp_desd
      FROM des_dir  
    WHERE fec_desd >= paramfec1 AND fec_desd <= paramfec2
        AND edo_desd = "C";
   IF ximp_desd IS NULL THEN LET ximp_desd = 0; END IF;
   IF ximp_asid IS NULL THEN LET ximp_asid = 0; END IF;

   {Obtiene las ventas por rubros Estacionario, Kilos, Carburacion y Total}
   LET ximp_suel = ximp_eruc + ximp_vand + ximp_desd;
   LET ximp_carb = ximp_carb + ximp_vmed;
   LET ximpt_vta = ximp_est + ximp_suel + ximp_carb ;
   LET ximp_asis = ximp_asie + ximp_asic + ximp_asib;

   {Obtiene la Cobranza de Comisiones}
   LET ximp_comi = 0;
   SELECT sum(imp_mcxc)
      INTO ximp_comi
      FROM mov_cxc
      WHERE fec_mcxc >= paramfec1 AND fec_mcxc <= paramfec2
        AND sta_mcxc = "A"
        AND tpm_mcxc = "60";
   IF ximp_comi IS NULL THEN LET ximp_comi = 0;
 END IF;

   {Obtiene la Cobranza de Intereses}
   LET ximp_inte = 0;
   SELECT sum(imp_mcxc)
      INTO ximp_inte
      FROM mov_cxc
      WHERE fec_mcxc >= paramfec1 AND fec_mcxc <= paramfec2
        AND sta_mcxc = "A"
        AND tpm_mcxc = "61";
   IF ximp_inte IS NULL THEN LET ximp_inte = 0; END IF;

   {Obtiene la Cobranza de Pago Bienes}
   LET ximp_bien = 0;
   SELECT sum(imp_mcxc)
      INTO ximp_bien
      FROM mov_cxc
      WHERE fec_mcxc >= paramfec1 AND fec_mcxc <= paramfec2
        AND sta_mcxc = "A"
        AND tpm_mcxc = "62";
   IF ximp_bien IS NULL THEN LET ximp_bien = 0; END IF;

   {Obtiene la Cobranza de Donaciones}
   LET ximp_dona = 0;
   SELECT sum(imp_mcxc)
      INTO ximp_dona
      FROM mov_cxc
      WHERE fec_mcxc >= paramfec1 AND
 fec_mcxc <= paramfec2
        AND sta_mcxc = "A"
        AND tpm_mcxc = "63";
   IF ximp_dona IS NULL THEN LET ximp_dona = 0; END IF;

   {Obtiene la Anticipos Ingresados}
   LET ximp_anti = 0;
   SELECT sum(imp_mant)
      INTO ximp_anti
      FROM mov_ant
      WHERE fec_mant >= paramfec1 AND fec_mant <= paramfec2
        AND sta_mant = "A"
        AND tpm_mant = "53";
   IF ximp_anti IS NULL THEN LET ximp_anti = 0; END IF;

   {Obtiene la Anticipos Aplicados}
   LET ximp_mant = 0;
   SELECT sum(imp_mant)
      INTO ximp_mant
      FROM mov_ant
      WHERE fec_mant >= paramfec1 AND fec_mant <= paramfec2
        AND sta_mant = "A"
        AND tpm_mant = "99";
   IF ximp_mant IS NULL THEN LET ximp_mant = 0; END IF;

   RETURN ximp_est,ximp_suel,ximp_carb,ximpt_fac,ximp_can,ximp_mnc,ximp_ncrd,
          ximpt_vta,ximp_chqi,ximp_chqc,ximp_asis,ximpt_fas,ximp_comi,ximp_inte,
          ximp_bien,ximp_dona,ximp_anti,ximp_mant,ximpt_fasc
      WITH RESUME;

END PROCEDURE; 

select	*
from	cartera 
where	fec_car >= '2023-12-02'

select	sum(epo_fact), sum(epo_impv)
from	e_posaj
where 	epo_fec between '2024-08-01'  and '2024-08-29'

select	epo_impv, epo_asistencia, epo_asistenciaa, epo_fact,*
from	e_posaj
where 	epo_fec = '2025-05-03'

select	epo_impv, epo_asistencia, epo_asistenciaa, epo_fact,*
from	e_posaj
where 	epo_fec >= '2025-05-01'
order by epo_fec

select	*
from	datos	

update	e_posaj
set		epo_fact = 241241.76
where	epo_fec = '2025-05-03'
1540630.69
--50588.57
select	*
from	nota_vta
where	fes_nvta between '2024-02-25' and '2024-02-25'  and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4')

update 	nota_vta
set 	fes_nvta = '2024-02-26'
where 	fol_nvta = 547298 and vuelta_nvta = 3
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2025-02-18' and edo_nvta IN('A') 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4','E','B')

SELECT	SUM(NVL(impasi_nvta,0))
FROM	nota_vta
WHERE	fes_nvta between '2023-03-01' and '2023-03-31' and edo_nvta = 'A' AND impt_nvta > 0				
		AND tip_nvta IN('C','D')

--ESTACIONARIO-----------------------------------------------------------------
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2024-09-01' and edo_nvta = 'A' 
		AND tip_nvta = 'E'
		AND ruta_nvta[1] = 'M'

SELECT SUM(CASE WHEN tip_nvta = 'E' THEN impt_nvta ELSE 0 END),
 SUM(CASE WHEN tip_nvta = 'B' THEN impt_nvta ELSE 0 END),
SUM(CASE WHEN asiste_nvta = 'S' THEN impasi_nvta ELSE 0 END)
FROM nota_vta
WHERE fes_nvta >= '2023-01-02' AND fes_nvta <= '2023-01-02'
AND ruta_nvta[1] = 'M'
AND edo_nvta = 'A'
AND (aju_nvta IS NULL OR aju_nvta <> 'S');

--CILINDRO-----------------------------------------------------------------
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-06-03' and edo_nvta = 'A' 
		AND ruta_nvta[1] = 'C'
		
SELECT sum(NVL(impt_eruc,0)),sum(nvl(impasi_eruc,0))
FROM   empxrutc
WHERE fec_eruc = '2023-06-03' AND edo_eruc = 'C';

SELECT *
FROM empxrutc
WHERE fec_eruc = '2023-06-03' AND edo_eruc = 'C';

select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-01-02' and edo_nvta = 'A' 
		AND ruta_nvta[1] = 'A'
		
SELECT 	sum(impt_vand)
FROM 	venxand
WHERE 	fec_vand >= '2023-06-03' AND fec_vand <= '2023-06-03'
        AND edo_vand = 'C';
        
SELECT *
FROM  venxand
WHERE fec_vand >= '2023-07-14' AND fec_vand <= '2023-07-14'
        AND edo_vand = "C";
        
select	*
from	nota_vta 
where	fliq_nvta = 2817 and ruta_nvta = 'AP01'

select	*
from	nota_vta
where	fes_nvta = '2023-01-02' and edo_nvta = 'A' 
		AND ruta_nvta[1] = 'A'

--CARBURACION-----------------------------------------------------------------		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-10-16' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta = 'E'
		      
SELECT sum(impt_vmed),sum(impasi_vmed)
FROM 	venxmed
WHERE 	fec_vmed >= '2023-03-01' AND fec_vmed <= '2023-03-31'
		and edo_vmed = 'C'

SELECT 	*
FROM 	venxmed
WHERE   fec_vmed = '2023-03-09'

--DESCARGA DIRECTA-----------------------------------------------------------------
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-01-02' and edo_nvta = 'A' 
		AND ruta_nvta[1] = 'D'
		
SELECT sum(impt_desd)
FROM des_dir
WHERE fec_desd >= '2023-06-03' AND fec_desd <= '2023-06-03'
        AND edo_desd = "C";
        
select	*
from	nota_vta
where	fes_nvta = '2023-01-02' and edo_nvta = 'A' 
		AND ruta_nvta[1] = 'D'


select	*
from	factura
where	fec_fac = '2023-04-17' and tfac_fac = 'S'
5980
5983
5985
select	sum(impt_nvta), sum(impasi_nvta)
from	nota_vta
where	fes_nvta = '2023-10-18' and edo_nvta = 'S' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN ('E')
		and fac_nvta not in(401073,401074,401075,5981)
		
SELECT SUM(impt_fac)
FROM factura
WHERE fec_fac  = '2023-09-01' 
     AND impr_fac = 'E'
     AND tdoc_fac = 'I'
     AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0)
     AND tfac_fac <> 'S'
     
SELECT SUM(impasi_dfac)
FROM factura,det_fac
WHERE fec_fac = '2023-08-07'
  AND impr_fac = 'E'
  AND tdoc_fac = 'I'   
  AND faccer_fac = 'N'
  AND (feccan_fac is null OR feccan_fac <> fec_fac)
  AND (frf_fac IS NULL OR frf_fac = 0)
  AND fol_fac = fol_dfac
  AND ser_fac = ser_dfac
  AND cia_fac = cia_dfac
  AND pla_fac = pla_dfac;
  
  SELECT *
FROM factura,det_fac
WHERE fec_fac = '2023-05-10'
  AND impr_fac = 'E'
  AND tdoc_fac = 'I'   
  AND faccer_fac = 'N'
  AND (feccan_fac is null OR feccan_fac <> fec_fac)
  AND (frf_fac IS NULL OR frf_fac = 0)
  AND fol_fac = fol_dfac
  AND ser_fac = ser_dfac
  AND cia_fac = cia_dfac
  AND pla_fac = pla_dfac
  AND impasi_dfac > 0;
     
SELECT 		sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
			sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
			sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
			sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
			sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
			sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
			sum(case when tid_dfac matches '[CD234]' THEN 
			(case when tid_dfac = 'C' THEN tlts_dfac ELSE
			(case when tid_dfac = 'D' THEN tlts_dfac ELSE
			(case when tid_dfac = '2' THEN tlts_dfac*20 ELSE
			(case when tid_dfac = '3' THEN tlts_dfac*30 ELSE
			(case when tid_dfac = '4' THEN tlts_dfac*45 ELSE 0 END) END) END) END) END)
			ELSE 0 END) kgs_cil,
			sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
			sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
	FROM 	factura,det_fac
	WHERE 	fec_fac between '2023-05-04' and '2023-05-04'			
	  		and tdoc_fac = 'I'
		  	and edo_fac <> 'C'
			and frf_fac is null
			and faccer_fac = 'N'
			and fol_fac = fol_dfac
			and ser_fac = ser_dfac
			and cia_fac = cia_dfac
			and pla_fac = pla_dfac
			
SELECT 		*
	FROM 	factura,det_fac d
	WHERE 	fec_fac between '2023-05-06' and '2023-05-06'			
	  		and tdoc_fac = 'I'
		  	and edo_fac <> 'C'
			--and frf_fac is null
			and faccer_fac = 'N'
			and fol_fac = fol_dfac
			and ser_fac = ser_dfac
			and cia_fac = cia_dfac
			and pla_fac = pla_dfac
			and impasi_dfac > 0
			and tid_dfac matches '[E]'
			
select	*
from	factura
where	fol_fac = 1882 and ser_fac = 'PAMB'

select	*
from	det_fac
where	fol_dfac = 3125 and ser_dfac = 'PAM'

select	*
from	nota_vta
where	fol_nvta in(132582,136726,136727,136728,132582,136493,135993,136830,133272,135439,135440,136095,135443,135441,132055,
					132056,136724)

select	*
from	nota_vta
where	fes_nvta = '2023-06-26' and fac_nvta is null and edo_nvta in('S','A') and impt_nvta > 0 and  aju_nvta = 'S' 

select	*
from	nota_vta
where	fes_nvta = '2023-05-03' and  ruta_nvta[1] = 'M' and tip_nvta = 'B'

SELECT 	sum(imp_mant)
FROM 	mov_ant
WHERE 	fec_mant >= '2023-04-01' AND fec_mant <= '2023-04-30'
--AND 	sta_mant = "A"
AND 	tpm_mant = "53";

SELECT *
FROM 	mov_ant
WHERE 	fec_mant >= '2023-04-01' AND fec_mant <= '2023-04-30'
--AND 	sta_mant = "A"
AND 	tpm_mant = "53";

select	sum(impt_fac)
from	factura
where	fol_fac in(156873,156874,156875,156912,156913,156914,156957,156958,156959,156992,156993,156994,157030,157031,
		157032,157069,157070,157071,157072,157073,157074,157104,157105,157106,157151,157152,157153,157178,157179,157180,157212,
		157213,157214,157241,157242,157243,157267,157268,157269,157270,157271,157272,157330,157331,157332,157375,157376,157377,
		157409,157410,157411,157455,157456,157457,157483,157484,157485,157506,157507,157508,157526,157527,157528,157545,157546,
		157547,157598,157599,157600,157630,157631,157632,157666,157667,157668,157704,157705,157706,157730,157731,157732,157733,
		157795,157796,157797,157835,157836,157837,157866,157867,157868) and ser_fac = 'EAM'

select	*
from	nota_vta
where	fes_nvta = '2023-06-17' and edo_nvta = 'S'

update	nota_vta
set		edo_nvta = 'A'
where	fol_nvta = 999881 and vuelta_nvta = 1

select	sum(impt_fac)
from	factura
where	fec_fac between '2023-06-01' and '2023-06-30' and tdoc_fac = 'I' and tfac_fac = 'S' and faccer_fac = 'S'

Select  tid_dfac, SUM(impasi_dfac) imp_asi , sum(tlts_dfac) cantidad,  SUM(tlts_dfac*pru_dfac ) importe
 from  factura, det_fac 
 where fec_fac  BETWEEN  '2023/06/01' and '2023/06/30' and tdoc_fac = 'I' and edo_fac <> 'C' and  faccer_fac = 'S' and fol_dfac = fol_fac  and ser_dfac= ser_fac and tfac_fac <> 'O' and (frf_fac is null or frf_fac = 0) 
GROUP BY   tid_dfac  order by tid_dfac


SELECT SUM(CASE WHEN tip_nvta = 'E' THEN impt_nvta ELSE 0 END),
     SUM(CASE WHEN tip_nvta = 'B' THEN impt_nvta ELSE 0 END),

 SUM(CASE WHEN asiste_nvta = 'S' THEN impasi_nvta ELSE 0 END)
 FROM nota_vta
 WHERE fes_nvta >= '2023-07-01' AND fes_nvta <= '2023-07-01'
   AND ruta_nvta[1] = 'M'
   AND edo_nvta = 'A'
   AND (aju_nvta IS NULL OR aju_nvta <> 'S');
   
 SELECT sum(impt_eruc),sum(impasi_eruc)
      FROM empxrutc
      WHERE fec_eruc >= '2023-09-07' AND fec_eruc <= '2023-09-07'
        AND edo_eruc = "C";   
        
 SELECT sum(impt_vand)
   FROM venxand
      WHERE fec_vand >= '2023-09-07' AND fec_vand <= '2023-09-07'
        AND edo_vand = "C";
        
 SELECT sum(impt_desd)
      FROM des_dir  
    WHERE fec_desd >= '2023-07-01' AND fec_desd <= '2023-07-01'
        AND edo_desd = "C";
        
 SELECT sum(impt_vmed),sum(impasi_vmed)
      FROM venxmed
      WHERE fec_vmed >= '2023-07-01' AND fec_vmed <= '2023-07-01'
        AND edo_vmed = "C";

-- VENTA POR ESTACION DE CARBURACION-----------------------------------------------------------------------------------------------
select	*
from	ruta
where	cve_rut[1] = 'B'

select	tip_rut,count(*)
from	ruta
where	cve_rut[1] = 'B'
group by 1

select	pcre_rut, cat_rut,count(*)
from	ruta
where	tip_rut = 'E' 
group by 1,2

select	cat_rut,count(*)
from	ruta
where	tip_rut = 'E' 
group by 1


select	pcre_rut, count(*)
from	ruta
where	tip_rut = 'E' 
group by 1

select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2024-01-08' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E')
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2024-01-08' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4')
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2024-01-08' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B')
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2024-01-08' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B')
		AND ruta_nvta NOT IN(select cve_rut from ruta where cve_rut[1] = 'B' and tip_rut = 'E' )	
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2024-09-25' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E','B','C','D','2','3','4')	


-- FACTURADO DEL DIA
SELECT SUM(impt_fac)
   FROM factura
   WHERE fec_fac >= '2023-02-28' AND fec_fac <= '2023-02-28'
     AND impr_fac = 'E'
     AND tdoc_fac = 'I'
     AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0);
     
SELECT	NVL(SUM(impt_fac),0), NVL(SUM(simp_fac),0), NVL(SUM(iva_fac),0)
FROM	factura
WHERE	fec_fac = '2023-02-28'
		AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND faccer_fac = 'N'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0);
     	
select	sum(impt_nvta), sum(simp_nvta), sum(iva_nvta)
from	nota_vta, factura
where	fes_nvta = '2023-02-28'and edo_nvta = 'A' AND tip_nvta IN('E','B', 'C','D','2','3','4')
		and fac_nvta = fol_fac and ser_nvta = ser_fac 
		and tdoc_fac = 'I' 
		AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND faccer_fac = 'N'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0) 

-- ASISTENCIA FACTURADA
	
SELECT 	NVL(SUM(NVL(impasi_dfac,0)),0), NVL(SUM(NVL(impasi_dfac,0) / 1.16),0), NVL(SUM(NVL(impasi_dfac,0) / 1.16) * 0.16,0)
FROM 	factura,det_fac
WHERE 	fec_fac >= '2023-02-28' AND fec_fac <= '2023-02-28'
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'   
  		AND faccer_fac = 'N'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	AND fol_fac = fol_dfac
     	AND ser_fac = ser_dfac
     	AND cia_fac = cia_dfac
     	AND pla_fac = pla_dfac;
     	
-- FACTURADO PUBLICO EN GENERAL DEL DIA 	
SELECT	NVL(SUM(impt_fac),0), NVL(SUM(simp_fac),0), NVL(SUM(iva_fac),0)
FROM	factura
WHERE	fec_fac = '2024-01-22' and tdoc_fac = 'I' 
		AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND faccer_fac = 'S'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0);

-- ASISTENCIA FACTURADA PUBLICO EN GENERAL

SELECT 	NVL(SUM(NVL(impasi_dfac,0) / 1.16),0),NVL(SUM(NVL(impasi_dfac,0) / 1.16) * 0.16,0)
FROM 	factura,det_fac
WHERE 	fec_fac >= '2024-01-22' AND fec_fac <= '2024-01-22'
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'   
  		AND faccer_fac = 'S'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	AND fol_fac = fol_dfac
     	AND ser_fac = ser_dfac
     	AND cia_fac = cia_dfac
     	AND pla_fac = pla_dfac;

-- CANCELADAS 

SELECT 	NVL(sum(impt_fac),0), NVL(sum(simp_fac),0), NVL(sum(iva_fac),0)
FROM 	factura
WHERE 	feccan_fac >= '2024-01-22'  AND feccan_fac <= '2024-01-22' 
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND edo_fac  = 'C'
     	AND faccer_fac = 'N'
     	AND fec_fac <> feccan_fac
     	AND (frf_fac IS NULL OR frf_fac = 0);

-- ASISTENCIA CANCELADA 
SELECT 	NVL(SUM(NVL(impasi_dfac,0) / 1.16),0),NVL(SUM(NVL(impasi_dfac,0)) / 1.16 * 0.16, 0)
FROM 	factura,det_fac
WHERE 	feccan_fac >= '2024-01-22' AND feccan_fac <= '2024-01-22'
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'     
		AND edo_fac  = 'C'
     	AND faccer_fac = 'N'
     	AND fec_fac <> feccan_fac
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	AND fol_fac = fol_dfac
     	AND ser_fac = ser_dfac
     	AND cia_fac = cia_dfac
        AND pla_fac = pla_dfac;

SELECT 	sum(imp_mcxc)
FROM 	mov_cxc
WHERE 	fec_mcxc >= '2024-01-22' AND fec_mcxc <= '2024-01-22'
		AND sta_mcxc = 'A'
		AND tpm_mcxc IN('50','51','58');