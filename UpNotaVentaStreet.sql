CREATE PROCEDURE UpNotaVentaStreet
(
	paramFolio	CHAR(12),
	paramFec	CHAR(6),
	paramEco	CHAR(7),
	paramLts	CHAR(6),
	paramFecate CHAR(17),
	paramServ	INTEGER,
	paramFolP	CHAR(10)
)

	RETURNING
		CHAR(1);				
		
	DEFINE control	CHAR(1);	
	DEFINE vcia		CHAR(2);	
	DEFINE vpla		CHAR(2);	
	DEFINE vfolp	CHAR(10);	

	UPDATE	enruta
	SET		edovta_enr = 'l'
	WHERE	fol_enr = paramFolio
	AND		fecreg_enr = paramFec
	AND		eco_enr = paramEco
	AND		ltssur_enr = paramLts
	AND		fecate_enr = paramFecate
	AND		golpe_enr = paramServ;

	IF LENGTH(paramFolP) < 10 THEN
		LET vfolp = LPAD(paramFolP,6,'0');
	END IF;
	
	INSERT INTO ref_enr
    VALUES(paramFolP,paramFolio);
    
    UPDATE	nota_vta
    SET		ffis_nvta		= paramFolio * 1.0
    WHERE	fol_nvta 		= SUBSTR(paramFolP, 5,6)
			AND	cia_nvta 	= SUBSTR(paramFolP, 1,2)  
			AND	pla_nvta 	= SUBSTR(paramFolP, 3,2) ;
	
	LET	control = 'A';

	RETURN control;
	
END PROCEDURE;