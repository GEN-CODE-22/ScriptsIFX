CREATE PROCEDURE Susp_LlamP
(
	numcte_llamp CHAR(6),
	observ_llamp CHAR(1500),
	usr_llamp    CHAR(8)
)

DEFINE fechahora DATETIME YEAR TO FRACTION;

SELECT 	CURRENT
  INTO 	fechahora
  FROM 	systables
 WHERE 	tabid = 1;

IF EXISTS(SELECT 1 FROM prog_llam WHERE numcte_llam = numcte_llamp) THEN            
   UPDATE 	prog_llam
      SET 	edo_llam    = 'X',           
			fhpr_llam   = NULL,
			fh_llam     = fechahora,
			observ_llam = observ_llamp,
			usr_llam    = usr_llamp
    WHERE 	numcte_llam = numcte_llamp;
ELSE
   INSERT INTO prog_llam
          (
           numcte_llam,
           fh_llam,
           edo_llam,
           observ_llam,           
			usr_llam
          )
   VALUES (
           numcte_llamp,
           fechahora,
           'X',               
           observ_llamp,
           usr_llamp
          );   
END IF;

INSERT INTO detp_llam
       (
        numcte_pllam,
        fh_pllam,
        observ_pllam,
        edo_pllam,
        usr_pllam
       )
VALUES (
        numcte_llamp,
        fechahora,
        observ_llamp,
        'X',
        usr_llamp
       );

END PROCEDURE;                                      