CREATE PROCEDURE ConUS
(

)

RETURNING  
 CHAR(8), 
 CHAR(40);
 
DEFINE cveusr CHAR(8);
DEFINE nomusr CHAR(40);

FOREACH cClientes FOR
	SELECT	usr_ucve, 
			CASE
			WHEN TRIM(nom_ucve) <> '' THEN
				UPPER(nom_ucve)
			ELSE 
				UPPER(usr_ucve)
			END AS 	nom_ucve		
	INTO	cveusr,nomusr
	FROM	usr_cve
	ORDER BY 2
	RETURN	cveusr, 
			nomusr
	WITH RESUME;
END FOREACH;
END PROCEDURE;




