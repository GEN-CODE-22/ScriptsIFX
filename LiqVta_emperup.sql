DROP PROCEDURE LiqVta_emperup;
EXECUTE PROCEDURE  LiqVta_emperup(805, 'M030');

CREATE PROCEDURE LiqVta_emperup
(
	paramFolio  INT,
	paramRuta	CHAR(4)
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(100);		-- Mensaje error
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(100);
DEFINE vproceso INT;
DEFINE vmsg	    CHAR(30);
DEFINE vpcs		CHAR(1);
DEFINE vchf		CHAR(5);
DEFINE vay1		CHAR(5);
DEFINE vay2		CHAR(5);
DEFINE vchfo	CHAR(5);
DEFINE vay1o	CHAR(5);
DEFINE vay2o	CHAR(5);
DEFINE vcia		CHAR(2);
DEFINE vpla		CHAR(2);
DEFINE vruta	CHAR(4);
DEFINE varuta	CHAR(4);
DEFINE vfecha	DATE;
DEFINE vtot		DECIMAL;
DEFINE vnnv     INT;
DEFINE vnnve    INT;
DEFINE vnnveo   INT;

LET vresult = 1;
LET vmensaje = '';
LET vproceso = 1;
LET vmsg = '';
LET vchfo = '';
LET vay1o = '';
LET vay2o = '';

SELECT	cia_erup, pla_erup, rut_erup, pcs_erup, chf_erup, NVL(ay1_erup,''), NVL(ay2_erup,''), arut_erup, fec_erup, 
		NVL(tot_erup,0), NVL(nnv_erup,0)
INTO	vcia,vpla,vruta,vpcs,vchf,vay1,vay2,varuta,vfecha,vtot,vnnv
FROM	empxrutp
WHERE	fliq_erup = paramFolio AND rut_erup = paramRuta;

IF vpla = '04' OR vpla = '05' OR vpla = '10'  OR vpla = '34' OR vpla = '15' OR vpla = '20' OR vpla = '25' OR vpla = '21' OR
   vpla = '28' OR vpla = '46' OR vpla = '50' OR vpla = '51' OR vpla = '52' OR vpla = '53' OR vpla = '54' OR
   vpla = '98' OR vpla = '65' OR vpla = '06' OR vpla = '88' OR vpla = '09' OR vpla = '40' OR vpla = '41'
   OR vpla = '42' OR vpla = '43' OR vpla = '44' OR vpla = '85' OR vpla = '86' OR vpla = '19' AND (vruta <> 'M001' OR vruta <> 'M004' OR vruta <> 'M008') 
   OR vpla = '67' THEN
	IF vpla = '25' OR vpla = '46' THEN
	     SELECT NVL(SUM(tlts_nvta),0), NVL(count(*),0)
	     INTO	vtot,vnnv
	     FROM 	nota_vta
	     WHERE  fliq_nvta = paramFolio AND ruta_nvta = vruta
	            AND tip_nvta  <> 'I' AND tip_nvta  <> 'P' AND tip_nvta  <> 'F' AND tip_nvta <> 'T';
  	ELSE
		IF vpla = '10' OR vpla = '34' OR vpla = '50' OR vpla = '51' OR vpla = '52' OR vpla = '53' OR vpla = '54' OR vpla = '98' THEN
			SELECT NVL(SUM(tlts_nvta),0), NVL(count(*),0)
			INTO	vtot,vnnv
			FROM	nota_vta
			WHERE	fliq_nvta = paramFolio AND ruta_nvta = vruta AND tip_nvta <> 'I' 
					AND tip_nvta <> 'P' AND tip_nvta <> 'F' AND (tip_nvta <> 'T' OR (tip_nvta = 'T' AND numcte_nvta IN('080683','080684','080685','080686','080687','080687','080688','080689','080690','080691','080692','080693','080694','080695','080696')));
		ELSE
			SELECT NVL(SUM(tlts_nvta),0), NVL(count(*),0)
			INTO	vtot,vnnv
			FROM	nota_vta
			WHERE	fliq_nvta = paramFolio AND ruta_nvta = vruta AND tip_nvta <> 'I' 
					AND tip_nvta <> 'P' AND tip_nvta <> 'F' AND tip_nvta <> 'T';
		END IF;
  END IF;
END IF;
   
IF vpla = '01' OR vpla = '93' THEN
  /*SELECT COUNT(*), ((SUM(CASE WHEN tpa_nvta = 'C' AND tlts_nvta <= 50 
 		 THEN tlts_nvta ELSE 0 END) / 50) + 
 		 (SUM(CASE WHEN tpa_nvta = 'E' AND impt_nvta <= 300 
 		 THEN impt_nvta ELSE 0 END) / 300) + 0.5) 
  INTO	 vnnve,vnnveo
  FROM 	 nota_vta 
  WHERE  fes_nvta = vfecha
  		 AND edo_nvta = 'A'
		 AND (tpa_nvta = 'C' and tlts_nvta <= 50
		 OR   tpa_nvta = 'E' and impt_nvta <= 300)
		 AND fliq_nvta = paramFolio
		 AND ruta_nvta = paramRuta;*/
  SELECT COUNT(*), ((SUM(CASE WHEN tpa_nvta = 'C' AND tlts_nvta <= 50 
 		 THEN tlts_nvta ELSE 0 END) / 50) + 
 		 (SUM(CASE WHEN tpa_nvta = 'E' AND impt_nvta <= 300 AND numcte_nvta NOT IN('000001','008090','064721','064722')
 		 THEN impt_nvta ELSE 0 END) / 300) + 0.5 +
 		 (SUM(CASE WHEN tpa_nvta = 'E' AND tlts_nvta <= 50 AND numcte_nvta IN('000001','008090','064721','064722')
 		 THEN tlts_nvta ELSE 0 END) / 50))
  INTO	 vnnve,vnnveo
  FROM 	 nota_vta 
  WHERE  fes_nvta = vfecha
  		 AND edo_nvta = 'A'
		 AND (tpa_nvta = 'C' and tlts_nvta <= 50
		 OR   tpa_nvta = 'E' and impt_nvta <= 300 AND numcte_nvta NOT IN ('000001','008090','064721','064722')
		 OR   tpa_nvta = 'E' and tlts_nvta <= 50 AND numcte_nvta IN ('000001','008090','064721','064722'))
		 AND fliq_nvta = paramFolio
		 AND ruta_nvta = paramRuta;
  LET vnnv = vnnv - NVL(vnnve,0) + NVL(vnnveo,0);
ELSE
  IF vpla = '12' OR vpla = '17' OR vpla = '84' OR vpla = '87' OR vpla = '92' THEN
    SELECT 	COUNT(*),((SUM(CASE WHEN tpa_nvta='E' AND 
    		tlts_nvta<=50 THEN tlts_nvta ELSE 0 END)/50)+0.5)
    INTO	 vnnve,vnnveo
    FROM 	nota_vta 
    WHERE	fes_nvta = vfecha
     		AND edo_nvta = 'A'
		    AND tpa_nvta = 'E' and tlts_nvta <= 50
		    AND fliq_nvta = paramFolio
		    AND ruta_nvta = paramRuta;
    LET vnnv = vnnv - NVL(vnnve,0) + NVL(vnnveo,0);
  END IF;
END IF;

IF vpcs = 'A' OR vpcs = 'S' THEN
  	 IF (vpla = '10' OR vpla = '34' OR vpla = '50' OR vpla = '51' OR vpla = '52' OR vpla = '53' OR vpla = '54' OR vpla = '98') THEN
     	 IF vpcs = 'A' THEN
        	SELECT  UNIQUE chf_erup, NVL(ay1_erup,''), NVL(ay2_erup,'')
			INTO	vchfo,vay1o,vay2o
			FROM	empxrutp
			WHERE	rut_erup = varuta AND fec_erup = vfecha
					AND pcs_erup = 'C' AND fliq_erup <> paramFolio;
			LET vruta = varuta;
	     END IF;

     	 IF vchf <> vchfo THEN
	     	LET vproceso,vmsg = erup_empreg(vruta,vfecha,vchf,vnnv,vtot,'37','S');
	     END IF;
	
	     IF vay1 IS NOT NULL AND LENGTH(vay1) > 0 THEN
	        IF vay1 <> vay1o THEN
	        	LET vproceso,vmsg = erup_empreg(vruta,vfecha,vay1,vnnv,vtot,'37','S');
	        END IF;
	     END IF;
		
		IF vay2 IS NOT NULL AND LENGTH(vay2) > 0 THEN
	        IF vay2 <> vay2o THEN
	        	LET vproceso,vmsg = erup_empreg(vruta,vfecha,vay2,vnnv,vtot,'37','S');
	        END IF;
	     END IF;     
  ELSE
     LET vproceso,vmsg = erup_empreg(vruta,vfecha,vchf,vnnv,vtot,'29','S');
	 IF vay1 <> '' THEN
		LET vproceso,vmsg = erup_empreg(vruta,vfecha,vay1,vnnv,vtot,'29','S');
	 END IF;
	 IF vay2 <> '' THEN
		LET vproceso,vmsg = erup_empreg(vruta,vfecha,vay2,vnnv,vtot,'29','S');
	 END IF;
  END IF;

  IF vpcs = 'A' THEN
     SELECT  UNIQUE chf_erup, NVL(ay1_erup,''), NVL(ay2_erup,'')
			INTO	vchf,vay1,vay2
			FROM	empxrutp
			WHERE	rut_erup = varuta AND fec_erup = vfecha
					AND pcs_erup = 'C' AND fliq_erup <> paramFolio;
	 LET vruta = varuta;
  END IF;
END IF;


IF vpcs = 'C' OR vpcs = 'A' OR vpcs = 'D' THEN
	IF vtot > 0 THEN
		LET vproceso,vmsg = erup_empreg(vruta,vfecha,vchf,vnnv,vtot,'03','N');
		IF vpcs = 'D' THEN
			LET vay1 = vchf;
		END IF;
		IF vay1 <> '' THEN
			LET vproceso,vmsg = erup_empreg(vruta,vfecha,vay1,vnnv,vtot,'04','N');
		END IF;
		IF vay2 <> '' THEN
			LET vproceso,vmsg = erup_empreg(vruta,vfecha,vay2,vnnv,vtot,'04','N');
		END IF;
	END IF;
END IF;

RETURN 	vresult,vmensaje;
END PROCEDURE; 
 
select	*
from	empxrutp
where	fec_erup = '2024-06-25' and pcs_erup = 'S'

select	*
from	empxrutp
where	fec_erup >= '2018-01-01' and edo_erup = 'P'

select	*
from	nota_vta
where	fliq_nvta = 4586 and ruta_nvta = 'C049'


SELECT 	NVL(SUM(tlts_nvta),0), NVL(count(*),0)
FROM	nota_vta
where 	fes_nvta = '2023-03-29'

SELECT 	tip_nvta, NVL(SUM(tlts_nvta),0)
FROM	nota_vta
where 	fliq_nvta = 3826 and ruta_nvta = 'M018'
group by 1

select *
from   planta

SELECT  UNIQUE chf_eruc, NVL(ay1_eruc,''), NVL(ay2_eruc,''), NVL(ay3_eruc,''), NVL(ay4_eruc,'')
FROM	empxrutc
WHERE	rut_eruc = 'C049' AND fec_eruc = '2024-10-03';

SELECT  MIN(fliq_eruc)
FROM	empxrutc
WHERE	rut_eruc = 'C049' AND fec_eruc = '2024-10-03';

SELECT	NVL(gpa_emp,'')
FROM 	empleado
WHERE	cve_emp = '0493';

SELECT	*
	FROM	vtaxemp
	WHERE   emp_vemp = '0491' AND fec_vemp = '2024-10-03' AND  ruta_vemp = 'C049' 

SELECT	NVL(ncon_vemp,0), NVL(vta_vemp,0), NVL(nanf_vemp,0)
	FROM	vtaxemp
	WHERE   emp_vemp = '0491' AND fec_vemp = '2024-10-03' AND  ruta_vemp = 'C049' AND coa_vemp = '02';
	
SELECT NVL(SUM(tlts_nvta),0), NVL(count(*),0)
FROM	nota_vta
WHERE	fliq_nvta = 805 AND ruta_nvta = 'M030' AND tip_nvta <> 'I' 
		AND tip_nvta <> 'P' AND tip_nvta <> 'F' AND tip_nvta <> 'T';

SELECT NVL(SUM(tlts_nvta),0), NVL(count(*),0)
FROM	nota_vta
WHERE	fliq_nvta = 805 AND ruta_nvta = 'M030' AND tip_nvta <> 'I' 
		AND tip_nvta <> 'P' AND tip_nvta <> 'F' AND (tip_nvta <> 'T' or (tip_nvta = 'T' and numcte_nvta = '000001'));

select 	fes_nvta, count(*)
from 	nota_vta
where 	fes_nvta between '2025-01-01' and '2025-01-25'
		and edo_nvta = 'A' and numcte_nvta = '000001'
group by 1