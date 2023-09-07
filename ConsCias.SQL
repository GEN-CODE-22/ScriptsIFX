CREATE PROCEDURE ConsCias()
RETURNING 
 CHAR(2), 
 CHAR(40), 
 CHAR(40),
 CHAR(40), 
 CHAR(30), 
 CHAR(15), 
 CHAR(8),
 CHAR(45);

DEFINE cve 			CHAR(2);     
DEFINE nom 			CHAR(40); 
DEFINE dir 			CHAR(40);    
DEFINE col 			CHAR(40);
DEFINE ciu 			CHAR(30);    
DEFINE rfc 			CHAR(15);
DEFINE usr 			CHAR(8);     
DEFINE nombreComp 	CHAR(45); 

FOREACH cursorcanc FOR 
	SELECT 	cve_cia, nom_cia, dir_cia, col_cia, ciu_cia,
			rfc_cia, usr_cia, 
			(cve_cia || ' - ' || nom_cia) AS nombre
	INTO   	cve, 
			nom, 
			dir, 
			col, 
			ciu, 
			rfc, 
			usr, 
			nombreComp
	FROM   	cia 	
	WHERE  	cve_cia IN (SELECT cia_dat FROM datos)
	RETURN 	cve, 
			nom, 
			dir, 
			col, 
			ciu, 
			rfc, 
			usr, 
			nombreComp
	WITH RESUME; 
END FOREACH;
END PROCEDURE;
                                                                