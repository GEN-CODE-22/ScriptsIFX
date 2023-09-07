CREATE PROCEDURE QryAcPi
(
	paramCia CHAR(2), 
	paramPla CHAR(2)
)

RETURNING 
 CHAR(19), 
 CHAR(7);

DEFINE fullName CHAR(19); 
DEFINE unitId 	CHAR(7);


FOREACH cursorcanc FOR
	SELECT 	cve_uni || ' / ' || plc_uni AS name, 
			cve_uni
	INTO 	fullName, 
			unitId
	FROM 	unidad
	WHERE 	edo_uni = 'A'
			AND cia_uni = paramCia
			AND pla_uni = paramPla
			AND cve_uni <> '0'
	ORDER BY 1
	RETURN 	fullName, unitId
	WITH RESUME;	
END FOREACH;
END PROCEDURE;  