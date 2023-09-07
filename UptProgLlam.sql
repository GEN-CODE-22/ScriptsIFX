CREATE PROCEDURE UptProgLlam
(
	paramCte	CHAR(6),
	paramDias 	INT,
	paramUsr    CHAR(8)
)  

DEFINE fechahora DATETIME YEAR TO FRACTION;

SELECT	CURRENT
  INTO 	fechahora
  FROM 	systables
 WHERE 	tabid = 1;

UPDATE	prog_llam
SET 	pdias_llam  = paramDias,           		
		usr_llam    = paramUsr,
		fh_llam     = fechahora
WHERE 	numcte_llam = paramCte;

END PROCEDURE;   

                                                                        