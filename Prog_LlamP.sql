CREATE PROCEDURE Prog_LlamP
(
	numcte_llamp CHAR(6),
	numdias_ped  INT
)

UPDATE 	prog_llam
   SET 	dias_llam = numdias_ped
 WHERE 	numcte_llam = numcte_llamp;

END PROCEDURE;                                                                                                                                                                        