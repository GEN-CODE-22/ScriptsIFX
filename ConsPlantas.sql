CREATE PROCEDURE ConsPlantas
(
	paramCia CHAR(2)
)
RETURNING 
 CHAR(2), 
 CHAR(2), 
 CHAR(40), 
 CHAR(45);

DEFINE cia 			CHAR(2);		
DEFINE pla 			CHAR(2);
DEFINE nom 			CHAR(40);    
DEFINE nombreComp 	CHAR(45);

FOREACH cursorcanc FOR
	SELECT	cia_pla, 
			cve_pla, 
			nom_pla,
			(cve_pla || ' - ' || nom_pla) AS nombre
	INTO   	cia, pla, nom, nombreComp
	FROM   	planta
	WHERE  	cia_pla = paramCia
	RETURN 	cia, 
			pla, 
			nom, 
			nombreComp 
	WITH RESUME;
END FOREACH;
END PROCEDURE;   