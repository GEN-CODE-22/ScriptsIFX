DROP PROCEDURE LiqVta_UndoCerrar;
EXECUTE PROCEDURE  LiqVta_UndoCerrar('2022-05-30'); 	

CREATE PROCEDURE LiqVta_UndoCerrar
(
	paramFecha  DATE
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(255),		-- Mensaje error
 DECIMAL;		-- Monto dado de baja
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(255);
DEFINE vtotal   DECIMAL;
DEFINE vproceso INT;
DEFINE vmsg 	CHAR(100);
DEFINE vfolio	INT;
DEFINE vcia		CHAR(2);
DEFINE vpla		CHAR(2);
DEFINE vvuelta	INT;
DEFINE vcargo   DECIMAL;

LET vresult = 1;
LET vmensaje = '';
LET vtotal = 0;
LET vproceso = 0;
LET vmsg = '';

IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj 
		  	WHERE 	epo_fec = paramFecha) THEN
			
	FOREACH cDoctos FOR
		SELECT	cia_doc, pla_doc, fol_doc, vuelta_doc, car_doc
		INTO	vcia,vpla,vfolio,vvuelta,vcargo
		FROM	doctos 
		WHERE	femi_doc = paramFecha 
		
		LET vproceso,vmsg = cxc_bajadocumento(vfolio,vcia,vpla,vvuelta); 
		
		IF vproceso = 1 THEN
			UPDATE 	nota_vta
			SET		napl_nvta = 'N'
			WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
			
			LET vtotal = vtotal + vcargo;
		END IF;
	END FOREACH;	
	
	UPDATE	nota_vta
	SET		edo_nvta = 'S'
	WHERE	fes_nvta = paramFecha AND edo_nvta = 'A';
	
	UPDATE  empxrutp
	SET 	edo_erup  = 'P'
	WHERE	fec_erup = paramFecha AND edo_erup = 'C';
	
	UPDATE 	empxrutc 
	SET 	edo_eruc = 'P' 
	WHERE   fec_eruc = paramFecha and edo_eruc = 'C';
	
	UPDATE  venxmed
	SET 	edo_vmed = 'P'
	WHERE	fec_vmed = paramFecha AND edo_vmed = 'C';
	
	UPDATE	des_dir
	SET		edo_desd = 'P'
	WHERE   fec_desd = paramFecha AND edo_desd = 'C';
	
	UPDATE	venxand
	SET		edo_vand = 'P'
	WHERE	fec_vand = paramFecha AND edo_vand = 'C';
	
	UPDATE	gto_die
	SET		edo_gdie = 'P'
	WHERE	fec_gdie = paramFecha AND edo_gdie = 'C';
	
	UPDATE	gto_gas
	SET		edo_ggas = 'P'
	WHERE	fec_ggas = paramFecha AND edo_ggas = 'C';
	
	DELETE
	FROM	vtaxemp
	WHERE	fec_vemp  = paramFecha;
	
ELSE
	LET vresult = 0;
	LET vmensaje = 'NO SE PUEDE REALIZAR EL PROCESO, EL DIA YA ESTA CERRADO.';	
	RETURN 	vresult,vmensaje,vtotal;
END IF;

LET vresult = vproceso;
LET vmensaje = vmsg;

RETURN 	vresult,vmensaje,vtotal;
END PROCEDURE; 

SELECT 	* 
FROM 	e_posaj 
WHERE 	epo_fec = '2022-05-30'