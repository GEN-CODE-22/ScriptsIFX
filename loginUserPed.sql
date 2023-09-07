CREATE PROCEDURE loginUserPed
(
	paramNombre CHAR(8), 
	paramPass 	CHAR(8)
)
RETURNING INTEGER;

DEFINE autent INTEGER;
DEFINE pass CHAR(8);

SELECT	TRIM(pas_ucve) AS pas_ucve 
INTO 	pass 
FROM 	usr_cve 
WHERE	usr_ucve = paramNombre;

IF pass = paramPass THEN
	LET autent = 1;
ELSE
	LET autent = 0;
END IF;

RETURN autent;
END PROCEDURE;