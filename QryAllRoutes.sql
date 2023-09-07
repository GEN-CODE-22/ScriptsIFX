CREATE PROCEDURE QryAllRoutes()

	RETURNING 
		CHAR(4), 		
		CHAR(40), 		
		CHAR(2), 		
		CHAR(2), 		
		CHAR(60);		

	DEFINE cve		CHAR(4); 	
	DEFINE descr 	CHAR(40);
	DEFINE cia 		CHAR(2); 
	DEFINE pla 		CHAR(2);
	DEFINE nomComp 	char(60);	

	FOREACH consorcanc FOR
	
		SELECT cve_rut, 
			   desc_rut, 
			   cia_rut,
			   pla_rut, (cve_rut || ' - ' || 
			   cia_rut || ' - ' || pla_rut || ' - ' || 
			   CASE WHEN TRIM(desc_rut) <> '' THEN TRIM(desc_rut) 
			   ELSE 'N/D' END) AS nombreCompleto
		INTO   cve, 
			   descr, 
			   cia, 
			   pla, 
			   nomComp
		FROM   ruta
		WHERE  edo_rut = 'A'
		ORDER BY cve_rut
		RETURN cve, 
			   descr, 
			   cia, 
			   pla, 
			   nomComp
		WITH RESUME;
		
	END FOREACH;
	
END PROCEDURE;