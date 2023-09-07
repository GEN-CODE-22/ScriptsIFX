DROP PROCEDURE LiqVta_emperuc;
EXECUTE PROCEDURE  LiqVta_emperuc(3684, 'CP13');

CREATE PROCEDURE LiqVta_emperuc
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
DEFINE vay3		CHAR(5);
DEFINE vay4		CHAR(5);
DEFINE vcia		CHAR(2);
DEFINE vpla		CHAR(2);
DEFINE vruta	CHAR(4);
DEFINE varuta	CHAR(4);
DEFINE vfecha	DATE;
DEFINE vtot		DECIMAL;
DEFINE vkgsu	DECIMAL;
DEFINE vnnv     INT;
DEFINE vc20b	SMALLINT;
DEFINE vc30b	SMALLINT;
DEFINE vc45b	SMALLINT;
DEFINE vnanf	SMALLINT;
DEFINE vgpaemp	CHAR(4);
DEFINE vtkgs	DECIMAL;
DEFINE vkpar	DECIMAL;

LET vresult= 1;
LET vmensaje = '';
LET vproceso = 1;
LET vmsg = '';

SELECT	cia_eruc, pla_eruc, rut_eruc, pcs_eruc, chf_eruc, NVL(ay1_eruc,''), NVL(ay2_eruc,''), NVL(ay3_eruc,''), 
		NVL(ay4_eruc,''), arut_eruc, fec_eruc, tkgs_eruc, nnv_eruc, NVL(c20b_eruc,0), NVL(c30b_eruc,0), NVL(c45b_eruc,0), 
		NVL(nanf_eruc,0), NVL(kgsu_eruc,0), NVL(kpar_eruc,0), NVL(tkgs_eruc,0)		
INTO	vcia,vpla,vruta,vpcs,vchf,vay1,vay2,vay3,vay4,varuta,vfecha,vtot,vnnv,vc20b,vc30b,vc45b,vnanf,vkgsu,vkpar,vtkgs
FROM	empxrutc
WHERE	fliq_eruc = paramFolio AND rut_eruc = paramRuta;

IF vpla = '28' AND vruta[1,2] <> 'CZ' THEN
	LET vc45b = vc45b * 2;
END IF;

IF vpla = '24' OR vpla = '26' OR vpla = '27' OR vpla = '48' OR vpla = '49' THEN
	LET vc20b = vc20b + vnanf;
END IF;

IF vpla = '02' OR vpla = '03' OR vpla = '13' OR vpla = '32' OR vpla = '33' OR vpla = '78' OR vpla = '79' THEN
	LET vc20b = vc20b + (vkgsu / 20 + 0.5);
END IF;

IF vpcs = 'A' OR vpcs = 'S' THEN
	LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vchf,'29','','S',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	IF vay1 <> '' THEN
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vay1,'29','','S',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
	IF vay2 <> '' THEN
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vay2,'29','','S',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
	IF vay3 <> '' THEN
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vay3,'29','','S',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
	IF vay4 <> '' THEN
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vay4,'29','','S',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
	IF vpcs = 'A' THEN
		SELECT  UNIQUE chf_eruc, NVL(ay1_eruc,''), NVL(ay2_eruc,''), NVL(ay3_eruc,''), NVL(ay4_eruc,'')
		INTO	vchf,vay1,vay2,vay3,vay4
		FROM	empxrutc
		WHERE	rut_eruc = varuta AND fec_eruc = vfecha;
		
		SELECT  MIN(fliq_eruc)
		INTO	paramFolio
		FROM	empxrutc
		WHERE	rut_eruc = varuta AND fec_eruc = vfecha;
		
		LET vruta = varuta;

	END IF;
END IF;

IF vpcs = 'A' OR vpcs = 'C' OR vpcs = 'D' OR vpcs = 'G' THEN
	IF vpcs = 'D' THEN
		SELECT	NVL(gpa_emp,'')
		INTO	vgpaemp
		FROM 	empleado
		WHERE	cve_emp = vchf;
		
		IF (vpla = '01' OR vpla = '17') AND (vgpaemp = 'G41' OR vgpaemp = 'G42' OR vgpaemp = 'G43' OR vgpaemp = 'G44') OR
		   vpla = '02' OR vpla = '32' OR vpla = '04' OR vpla = '05' OR vpla = '10' AND vgpaemp = 'G89' OR vpla = '12' OR
		   vpla = '13' OR vpla = '14' OR vpla = '45' OR vpla = '78' OR vpla = '79' OR vpla = '23' OR (vpla = '18' OR 
		   vpla = '37' OR vpla = '39' OR vpla = '91') AND (vgpaemp = 'G71' OR vgpaemp = 'G73' OR vgpaemp = 'G75' OR vgpaemp = 'G105' 
		   OR vgpaemp = 'G108') OR vpla = '24' OR vpla = '27' AND vgpaemp = 'G11' OR vpla = '76' OR vpla = '81' OR vpla = '82'
		   OR vpla = '84' OR vpla = '87' OR vpla = '92' THEN
		   LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vchf,'46','23','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
		ELSE
			IF vpla = '15' OR vpla = '56' OR vpla = '62' OR vpla = '63' OR vpla = '64' THEN
				IF vruta = 'C005' OR vruta = 'C008' OR vruta = 'C011' OR vruta = 'C016' OR vruta = 'C019' OR vruta = 'C020' OR
				vruta = 'C021' OR vruta = 'C027' OR vruta = 'C037' OR vruta = 'C038' THEN
					LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vchf,'46','23','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
				ELSE
					IF vruta = 'C013' OR vruta = 'C023' OR vruta = 'C025' OR vruta = 'C026' OR vruta = 'C028' OR vruta = 'C029' OR
						vruta = 'C030' OR vruta = 'C031' OR vruta = 'C032' OR vruta = 'C033' OR vruta = 'C034' OR vruta = 'C035' OR 
						vruta = 'C036' THEN
						LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vchf,'22','23','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
					ELSE
						LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vchf,'01','23','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
						LET vay1 = vchf;
					END IF;
				END IF;
			ELSE
				LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vchf,'01','23','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
				LET vay1 = vchf;
			END IF;
		END IF;	
	ELSE
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vchf,'01','23','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
	
	IF vay1 <> '' THEN
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vay1,'02','24','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
	IF vay2 <> '' THEN
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vay2,'02','24','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
	IF vay3 <> '' THEN
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vay3,'02','24','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
	IF vay4 <> '' THEN
		LET vproceso,vmsg = eruc_empreg(paramFolio,vruta,vfecha,vay4,'02','24','N',vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,vpcs);
	END IF;
END IF;

RETURN 	vresult,vmensaje;
END PROCEDURE; 

select	*
from	empleado

select	*
from	empxrutc
where	fec_eruc >= '2022-01-01' and pcs_eruc = 'G'

select * 
from	venxmed

select * 
from	des_dir

select	*
from	empxrutc

select * 
from	venxand

select * 
from	gto_gas


select * 
from	gto_die

SELECT 	NVL(SUM(tlts_nvta),0), NVL(count(*),0)
FROM	nota_vta
where 	fes_nvta = '2023-03-29'
