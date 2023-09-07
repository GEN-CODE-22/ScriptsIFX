CREATE PROCEDURE UptDetLlam
(
	paramCte 	CHAR(6),
	paramFecha	DATETIME YEAR TO MINUTE, 
	paramEdo	CHAR(1),
	paramObser	CHAR(1500),
	paramUsr	CHAR(8)
)

UPDATE 	detp_llam
SET		observ_pllam = paramObser, usr_pllam = paramUsr
WHERE	numcte_pllam = paramCte AND fh_pllam = paramFecha AND edo_pllam = paramEdo;      

END PROCEDURE;