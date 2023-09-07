CREATE PROCEDURE QryEKey(
	paramCve	CHAR(5),	
	paramNom	CHAR(51) 
)

	RETURNING
		CHAR(5);		
		
	DEFINE cve		CHAR(5);	

	FOREACH cEcoRuta FOR 

		SELECT		cve_emp
		INTO		cve
		FROM		empleado
		WHERE		substr(cat_emp,7,5) = paramCve		
		AND			trim(ape_emp) || ' ' || trim(nom_emp) = paramNom
		AND			edo_emp = 'A'						
		AND			tip_emp = 'S'						
		RETURN		cve
		WITH RESUME;	

	END FOREACH; 

END PROCEDURE; 