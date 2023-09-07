CREATE PROCEDURE Qry_ServSurtido(
	paramFol	INT,
	paramCte	CHAR(6),
	paramTank	SMALLINT,
	paramCia	CHAR(2),
	paramPla	CHAR(2)
	)

	RETURNING
		INTEGER,					
		INTEGER,					
		CHAR(1),				
		DATE;					
		
	
	DEFINE fol		INTEGER;					
	DEFINE fliq		INTEGER;					
	DEFINE edo		CHAR(1);					
	DEFINE fecsur	DATE;						

	FOREACH cursorLNvta FOR
		SELECT	fol_nvta,
				fliq_nvta,
				edo_nvta,
				fes_nvta
		INTO	fol,
				fliq,
				edo,
				fecsur	
		FROM	nota_vta 
		WHERE	numcte_nvta = paramCte
		AND		numtqe_nvta = paramTank
		AND		edo_nvta IN('A','S')
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla
		AND		fes_nvta = TODAY
		AND		fol_nvta <> paramFol
		
	
		RETURN	fol,
				fliq,
				edo,
				fecsur
		WITH RESUME;
	END FOREACH; 
END PROCEDURE;	
