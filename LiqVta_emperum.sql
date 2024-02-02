DROP PROCEDURE LiqVta_emperum;
EXECUTE PROCEDURE  LiqVta_emperum(52, 'BUC2');

CREATE PROCEDURE LiqVta_emperum
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
DEFINE vdesp	CHAR(5);
DEFINE vay1		CHAR(5);
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
LET vdesp = '';
LET vay1 = '';

SELECT	cia_vmed, pla_vmed, rut_vmed, pcs_vmed, NVL(desp_vmed,''), NVL(ayu1_vmed,''), fec_vmed, 
		NVL(tlts_vmed,0)
INTO	vcia,vpla,vruta,vpcs,vdesp,vay1,vfecha,vtot
FROM	venxmed
WHERE	fliq_vmed = paramFolio AND rut_vmed = paramRuta;

IF vdesp <> '' THEN
	IF vpcs = 'S' THEN
		LET vproceso,vmsg = erum_empreg(paramFolio,vruta,vfecha,vdesp,0.00,0.00,'27');
	ELSE
	 IF vpcs = 'O' THEN
	    LET vproceso,vmsg = erum_empreg(paramFolio,vruta,vfecha,vdesp,0.00,0.00,'17');
	 ELSE
	    IF vpcs = 'P' THEN
	       LET vproceso,vmsg = erum_empreg(paramFolio,vruta,vfecha,vdesp,0.00,0.00,'05');
	    ELSE
	       LET vproceso,vmsg = erum_empreg(paramFolio,vruta,vfecha,vdesp,0.00,0.00,'06');
	    END IF;
	 END IF;
	END IF;
END IF;

IF vay1 <> '' THEN
	IF vpcs = 'S' THEN
		LET vproceso,vmsg = erum_empreg(paramFolio,vruta,vfecha,vay1,0.00,0.00,'27');
	ELSE
	 IF vpcs = 'O' THEN
	    LET vproceso,vmsg = erum_empreg(paramFolio,vruta,vfecha,vay1,0.00,0.00,'17');
	 ELSE
	    IF vpcs = 'P' THEN
	       LET vproceso,vmsg = erum_empreg(paramFolio,vruta,vfecha,vay1,0.00,0.00,'05');
	    ELSE
	       LET vproceso,vmsg = erum_empreg(paramFolio,vruta,vfecha,vay1,0.00,0.00,'06');
	    END IF;
	 END IF;
	END IF;
END IF;

RETURN 	vresult,vmensaje;
END PROCEDURE; 

select	*
from	venxmed
where	fec_vmed >= '2018-01-01' and pcs_vmed = 'S'

select	*
from	empxrutp
where	fec_erup >= '2018-01-01' and edo_erup = 'P'

select	*
from	nota_vta
where	fliq_nvta = 425 and ruta_nvta = 'M032'


SELECT 	NVL(SUM(tlts_nvta),0), NVL(count(*),0)
FROM	nota_vta
where 	fes_nvta = '2023-03-29'
