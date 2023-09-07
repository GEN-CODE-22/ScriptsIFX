CREATE PROCEDURE QryDP(
	paramNumCte		CHAR(6),
	paramTqe		INT,
	paramCia		CHAR(2),
	paramPla		CHAR(2)
)

	
	RETURNING 
		SMALLINT,				
		SMALLINT,				
		CHAR(1);				

	DEFINE	diasca SMALLINT;	
	DEFINE	diasom SMALLINT;	
	DEFINE  prg    CHAR(1);		

	FOREACH cCursorCan FOR

		SELECT 	diasca_tqe,
				diasom_tqe,
				prg_tqe
		INTO	diasca,
				diasom,
				prg
		FROM 	tanque
		WHERE	numcte_tqe = paramNumCte		
		AND		numtqe_tqe = paramTqe
		RETURN  diasca,
				diasom,
				prg
		WITH RESUME;

	END FOREACH;

END PROCEDURE;   