CREATE PROCEDURE EdTankNextCharge
(	
	paramClient	CHAR(6),
	paramTank	INTEGER,
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramDlc	DATE,
	paramNc		DATE
)

	RETURNING 
		CHAR(1);		
		
	DEFINE 
		control	CHAR(1);	

	UPDATE	tanque
	SET		ultcar_tqe = paramDlc,
			proxca_tqe = paramNc
	WHERE	numcte_tqe = paramClient
	AND		numtqe_tqe = paramTank
	AND		cia_tqe = paramCia
	AND		pla_tqe = paramPla;
	
	LET control = 'A';
	
	RETURN control;
	

	
END PROCEDURE; 