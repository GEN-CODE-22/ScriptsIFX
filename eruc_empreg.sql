DROP PROCEDURE eruc_empreg;
EXECUTE PROCEDURE  eruc_empreg(6891,'C005','2022-01-12','365','01','23','N');
EXECUTE PROCEDURE  eruc_empreg(6891,'C005','2022-01-14','398','01','','S');

CREATE PROCEDURE eruc_empreg
(
	paramFolio	INT,
	paramRuta	CHAR(4),
	paramFecha	DATE,
	paramEmp	CHAR(5),
	paramTipo	CHAR(2),
	paramTipoa	CHAR(2),
	paramApy	CHAR(1),
	paramKpar	DECIMAL,
	paramc20b	DECIMAL,
	paramc30b	DECIMAL,
	paramc45b	DECIMAL,
	paramtkgs	DECIMAL,
	paramnanf	DECIMAL,
	paramPcs	CHAR(1)
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(30);		-- Mensaje error
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(30);
DEFINE vgpaemp	CHAR(4);
/*DEFINE vpcs		CHAR(1);
DEFINE vtkgs	DECIMAL;
DEFINE vkpar	DECIMAL;
DEFINE vc20b	SMALLINT;
DEFINE vc30b	SMALLINT;
DEFINE vc45b	SMALLINT;*/
DEFINE vncon	SMALLINT;
DEFINE vncone	SMALLINT;
DEFINE vtaemp	DECIMAL;
--DEFINE vnanf	SMALLINT;
DEFINE vnanfe	SMALLINT;
--DEFINE varuta	CHAR(4);

LET vresult= 1;
LET vmensaje = '';
LET vncon = 0;

SELECT	NVL(gpa_emp,'')
INTO	vgpaemp
FROM 	empleado
WHERE	cve_emp = paramEmp;

/*SELECT	pcs_eruc,NVL(kpar_eruc,0), NVL(c20b_eruc,0), NVL(c30b_eruc,0), NVL(c45b_eruc,0), NVL(tkgs_eruc,0), NVL(nanf_eruc,0),arut_eruc
INTO	vpcs,vkpar,vc20b,vc30b,vc45b,vtkgs,vnanf,varuta
FROM	empxrutc
WHERE	fliq_eruc = paramFolio AND rut_eruc = paramRuta;*/

IF paramApy = 'N' THEN
	IF paramKpar > 0 AND (vgpaemp = 'G33' OR vgpaemp = 'G34') THEN
		LET vncon = paramKpar / 30;
	END IF;
	
	SELECT	NVL(ncon_vemp,0), NVL(vta_vemp,0), NVL(nanf_vemp,0)
	INTO	vncone,vtaemp,vnanfe
	FROM	vtaxemp
	WHERE   emp_vemp = paramEmp AND fec_vemp = paramFecha AND  ruta_vemp = paramRuta AND coa_vemp = paramTipo;
		
	IF	EXISTS(SELECT 1 
				FROM vtaxemp 
				WHERE emp_vemp = paramEmp AND fec_vemp = paramFecha AND  ruta_vemp = paramRuta AND coa_vemp = paramTipo) THEN		
		
		LET vncone = vncone + paramc20b + paramc30b + paramc45b - vncon;
		LET vtaemp = vtaemp + paramtkgs;
		LET vnanfe = vnanfe + paramnanf;
		UPDATE	vtaxemp
		SET		ncon_vemp = vncone,
				vta_vemp = vtaemp,
				nanf_vemp = vnanfe
		WHERE	emp_vemp = paramEmp AND fec_vemp = paramFecha AND  ruta_vemp = paramRuta AND coa_vemp = paramTipo;
		LET vresult = 2;
		LET vmensaje = 'ACTUALIZO VENTA';
	ELSE
		LET vncone = paramc20b + paramc30b + paramc45b - vncon;
		LET vtaemp = paramtkgs;
		LET vnanfe = paramnanf;
		INSERT INTO vtaxemp VALUES(paramEmp,paramFecha,paramTipo,paramRuta,vncone,vtaemp,'K',vnanfe);
		LET vresult = 1;
		LET vmensaje = 'INSERTO VENTA';
	END IF;
	
	IF paramPcs = 'G' THEN
		IF	EXISTS(SELECT 1 
				FROM vtaxemp 
				WHERE emp_vemp = paramEmp AND fec_vemp = paramFecha AND  ruta_vemp = paramRuta AND coa_vemp = paramTipoa) THEN
			SELECT	NVL(ncon_vemp,0), NVL(vta_vemp,0), NVL(nanf_vemp,0)
			INTO	vncone,vtaemp,vnanfe
			FROM	vtaxemp
			WHERE   emp_vemp = paramEmp AND fec_vemp = paramFecha AND  ruta_vemp = paramRuta AND coa_vemp = paramTipoa;
			LET vncone = vncone + paramc20b + paramc30b + paramc45b - vncon;
			LET vtaemp = vtaemp + paramtkgs;
			LET vnanfe = vnanfe + paramnanf;
			UPDATE	vtaxemp
			SET		ncon_vemp = vncone,
					vta_vemp = vtaemp,
					nanf_vemp = vnanfe
			WHERE	emp_vemp = paramEmp AND fec_vemp = paramFecha AND  ruta_vemp = paramRuta AND coa_vemp = paramTipoa;	
			LET vresult = 5;
		LET vmensaje = 'ACTUALIZO VENTA G';
		ELSE
			LET vncone = paramc20b + paramc30b + paramc45b - vncon;
			LET vtaemp = paramtkgs;
			LET vnanfe = paramnanf;
			INSERT INTO vtaxemp VALUES(paramEmp,paramFecha,paramTipoa,paramRuta,vncone,vtaemp,'K',vnanfe);
			LET vresult = 4;
		LET vmensaje = 'INSERTO VENTA G';
		END IF;
	END IF;
ELSE
	IF	NOT EXISTS(SELECT 1 
				FROM vtaxemp 
				WHERE emp_vemp = paramEmp AND fec_vemp = paramFecha AND  ruta_vemp = paramRuta AND coa_vemp = paramTipo) THEN
		LET vnanfe = paramnanf;
		INSERT INTO vtaxemp VALUES(paramEmp,paramFecha,paramTipo,paramRuta,0,0.00,'K',vnanfe);
		LET vresult = 3;
		LET vmensaje = 'INSERTO VENTA APOYO';
	END IF;
END IF;

RETURN 	vresult,vmensaje;
END PROCEDURE; 


SELECT	pcs_eruc,NVL(kpar_eruc,0), NVL(c20b_eruc,0), NVL(c30b_eruc,0), NVL(c45b_eruc,0), NVL(tkgs_eruc,0), NVL(nanf_eruc,0)
FROM	empxrutc
WHERE	fliq_eruc = 1065 AND rut_eruc = 'C086';

select	*
from	vtaxemp
where	fec_vemp = '2021-03-04' and ruta_vemp = 'C020'

delete
from	vtaxemp
where	fec_vemp = '2022-01-12' and ruta_vemp = 'C005'

select	*
from	empxrutc
where	pcs_eruc = 'G'rut_eruc = 'CP12'
order by fec_eruc desc

select	*
from	vtaxemp
where 	lok_vemp = 'K' and fec_vemp >= '2022-01-01'
order by fec_vemp desc

select	*	
from	vtaxemp
where	emp_vemp = '365' and fec_vemp = '2022-01-12' and ruta_vemp = 'C005' and coa_vemp = '01'

delete	
from	vtaxemp
where	emp_vemp = '365' and fec_vemp = '2022-01-12' and ruta_vemp = 'C005' and coa_vemp = '01' and ncon_vemp = 0
