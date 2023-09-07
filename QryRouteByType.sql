CREATE PROCEDURE QryRouteByType(paramCia char(2), 
								paramPla char(2),
								paramType char(10))
	RETURNING 
		char(4),	
		char(40), 	
		char(2),	
		char(2),	
		char(57);	

	DEFINE cve char(4); 	
	DEFINE descr char(40);	
	DEFINE cia char(2); 	
	DEFINE pla char(2);		
	DEFINE nomComp char(57);

	FOREACH consorcanc FOR
		SELECT cve_rut, desc_rut, cia_rut,
			   pla_rut, (cve_rut || ' - ' || 
			   cia_rut || ' - ' || pla_rut || ' - ' || 
			   CASE WHEN TRIM(desc_rut) <> '' THEN TRIM(desc_rut) 
			   ELSE 'N/D' END) AS nombreCompleto
		INTO   cve, descr, cia, pla, nomComp
		FROM   ruta
		WHERE  edo_rut = 'A'
		AND    cia_rut = paramCia
		AND    pla_rut = paramPla
		AND	   SUBSTR(cve_rut,1,1) IN (paramType)
		ORDER BY cve_rut
		RETURN cve, descr, cia, pla, nomComp
		WITH RESUME;		   
	END FOREACH;

END PROCEDURE;  