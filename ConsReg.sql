CREATE PROCEDURE ConsReg()
RETURNING 
 SMALLINT, 
 CHAR(40);

DEFINE cve SMALLINT;     
DEFINE nom CHAR(40); 

FOREACH cursorReg FOR 
	SELECT 	reg_prc,
			(reg_prc || ' - ' || nom_prc) as nombre
	INTO   	cve, 
			nom
	FROM   	precios 	
	WHERE 	tid_prc = 'E'
  			AND pri_prc = 'S'
  	ORDER BY reg_prc
	RETURN 	cve, 
			nom
	WITH RESUME; 
END FOREACH;
END PROCEDURE;