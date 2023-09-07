CREATE PROCEDURE Posp_LlamP
(
	numcte_llamp CHAR(6),
	observ_llamp CHAR(1500),
	fhpr_llamp   DATETIME YEAR TO MINUTE,
	usr_llamp    CHAR(8)
)  

DEFINE fechahora DATETIME YEAR TO FRACTION;

SELECT	CURRENT
  INTO 	fechahora
  FROM 	systables
 WHERE 	tabid = 1;

IF EXISTS(SELECT 1 FROM prog_llam WHERE numcte_llam = numcte_llamp) THEN               
   UPDATE	prog_llam
      SET 	edo_llam    = 'A',           
			fhpr_llam   = fhpr_llamp,    
			fh_llam     = fechahora,
			observ_llam = observ_llamp,
			usr_llam    = usr_llamp
    WHERE 	numcte_llam = numcte_llamp;
ELSE
   INSERT INTO prog_llam
          (
           numcte_llam,
           fh_llam,
           fhpr_llam,
           edo_llam,
           observ_llam,
           usr_llam
          )
   VALUES (
           numcte_llamp,
           fechahora,
           fhpr_llamp,     
           'A',            
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
        'A',
        usr_llamp
       );

END PROCEDURE;                                                                            