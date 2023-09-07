CREATE PROCEDURE QryProgLlam
(
	paramCte	CHAR(6)
)

RETURNING  
 CHAR(6), 
 CHAR(8), 
 INT;  

DEFINE vnumcte	CHAR(6);
DEFINE vusuario CHAR(70);
DEFINE vdias 	CHAR(15);

FOREACH cLlamada FOR
	SELECT  prog_llam.numcte_llam,
			prog_llam.usr_llam,
			prog_llam.pdias_llam
	INTO	vnumcte,
			vusuario,
			vdias
	FROM	prog_llam
	WHERE	numcte_llam = paramCte
	RETURN 	vnumcte, 
			vusuario, 
			vdias
	WITH RESUME;
END FOREACH;
END PROCEDURE;                                                                            