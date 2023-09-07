CREATE PROCEDURE QryCanT
(	
)
	
	RETURNING	
		CHAR(2),		
		CHAR(50),		
		CHAR(52);		
	
	DEFINE cve	CHAR(2);	
	DEFINE detc CHAR(50);	
	DEFINE dtcc CHAR(54);	

	FOREACH CCancel FOR
	
		SELECT	cve_tcan,
				desc_tcan,
				cve_tcan || ' - ' || desc_tcan AS desccom
		INTO	cve,
				detc,
				dtcc
		FROM	tip_cancel
		RETURN	cve,
				detc,
				dtcc
		WITH RESUME;
	
	END FOREACH;

END PROCEDURE;