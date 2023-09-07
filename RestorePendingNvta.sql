CREATE PROCEDURE RestorePendingNvta(
	paramFolio	INTEGER,
	paramFolEnr CHAR(12),
	paramCia	CHAR(2),
	paramPla	CHAR(2),	
	paramUsr	CHAR(8)
	)


	RETURNING
		CHAR(1);			
			
	DEFINE control	CHAR(1);	
	
	DEFINE vnumped			INTEGER;
	DEFINE vcenr			INTEGER;	
	
	SELECT	COUNT(*)
	INTO	vcenr
	FROM	enruta
	WHERE	fol_enr			= paramFolEnr
			AND	edoreg_enr	= 'F'; 
	
	IF EXISTS(SELECT 1 FROM nota_vta WHERE fol_nvta = paramFolio AND cia_nvta = paramCia AND pla_nvta = paramPla AND edo_nvta = 'C') AND vcenr > 0 THEN
	
		SELECT	ped_nvta
		INTO	vnumped
		FROM	nota_vta
		WHERE	fol_nvta = paramFolio
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla;
		
		UPDATE	nota_vta 
		SET		edo_nvta = 'P'
		WHERE	fol_nvta = paramFolio
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla;
		
		UPDATE	pedidos
		SET		edo_ped 	= 'P'
		WHERE	num_ped 	= vnumped;		

		LET control = 'A';	

	ELSE	
		LET control = 'N'; 
	END IF;	
	
	RETURN	control;

END PROCEDURE;	