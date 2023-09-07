DROP PROCEDURE LiqVta_emperup;
EXECUTE PROCEDURE  LiqVta_emperup(327, 'M030');

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
DEFINE vcia		CHAR(2);
DEFINE vpla		CHAR(2);
DEFINE vruta	CHAR(4);
DEFINE varuta	CHAR(4);
DEFINE vfecha	DATE;
DEFINE vtot		DECIMAL;
DEFINE vnnv     INT;

LET vresult = 1;
LET vmensaje = '';
LET vproceso = 1;
LET vmsg = '';

SELECT	cia_erup, pla_erup, rut_erup, pcs_erup, chf_erup, NVL(ay1_erup,''), NVL(ay2_erup,''), arut_erup, fec_erup, 
		NVL(tot_erup,0), NVL(nnv_erup,0)
INTO	vcia,vpla,vruta,vpcs,vchf,vay1,vay2,varuta,vfecha,vtot,vnnv
FROM	empxrutp
WHERE	fliq_erup = paramFolio AND rut_erup = paramRuta;

IF vpcs = 'A' OR vpcs = 'S' THEN
	LET vproceso,vmsg = erup_empreg(vruta,vfecha,vchf,vnnv,vtot,'29','S');
	IF vay1 <> '' THEN
		LET vproceso,vmsg = erup_empreg(vruta,vfecha,vay1,vnnv,vtot,'29','S');
	END IF;
	IF vay2 <> '' THEN
		LET vproceso,vmsg = erup_empreg(vruta,vfecha,vay2,vnnv,vtot,'29','S');
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

IF	vpla = '04' OR vpla = '05' OR vpla = '08' OR vpla = '10' OR vpla = '15' OR vpla = '20' OR vpla = '21' OR vpla = '28'
	OR vpla = '65' AND vruta <> 'M001' AND vruta <> 'M008' OR vpla = '67' THEN
	IF vpla = '10' AND (vruta = 'M014' OR vruta = 'M015')THEN
		SELECT 	NVL(SUM(tlts_nvta),0), NVL(count(*),0)
		INTO	vtot,vnnv
		FROM	nota_vta
		WHERE	fliq_nvta = paramFolio AND ruta_nvta = vruta AND tip_nvta <> 'I' AND tip_nvta <> 'P' AND tip_nvta <> 'F';
	ELSE
		SELECT 	NVL(SUM(tlts_nvta),0), NVL(count(*),0)
		INTO	vtot,vnnv
		FROM	nota_vta
		WHERE	fliq_nvta = paramFolio AND ruta_nvta = vruta AND tip_nvta <> 'I' 
				AND tip_nvta <> 'P' AND tip_nvta <> 'F' AND tip_nvta <> 'T';
	END IF;
END IF;

IF vpcs = 'C' OR vpcs = 'A' OR vpcs = 'D' THEN
	IF vtot > 0THEN
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
where	fec_erup >= '2018-01-01' and pcs_erup = 'S'

select	*
from	empxrutp
where	fec_erup >= '2018-01-01' and edo_erup = 'P'

select	*
from	nota_vta
where	fliq_nvta = 425 and ruta_nvta = 'M032'


SELECT 	NVL(SUM(tlts_nvta),0), NVL(count(*),0)
FROM	nota_vta
where 	fes_nvta = '2023-03-29'
