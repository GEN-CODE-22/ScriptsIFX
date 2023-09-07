CREATE PROCEDURE CheckDF
(	
	paramFi		DATE,
	paramFf     DATE	
)
	RETURNING 
		INT;		

	DEFINE	vfol		INT;
	FOREACH cNota FOR

		SELECT	COUNT(*)
		INTO	vfol
		FROM	empxrutp
		WHERE	fec_erup >= paramFi
		AND		fec_erup <= paramFf
		
		RETURN 		vfol
		WITH RESUME;

	END FOREACH; 

END PROCEDURE;


