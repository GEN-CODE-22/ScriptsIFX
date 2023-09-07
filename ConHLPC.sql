CREATE PROCEDURE ConHLPC
(
	paramCte CHAR(6)
)
RETURNING
 DATETIME YEAR TO MINUTE,
 CHAR(1500), 
 CHAR(15),
 CHAR(8),
 CHAR(1),
 DATETIME YEAR TO MINUTE;


DEFINE fh     DATETIME YEAR TO MINUTE;
DEFINE observ CHAR(1500);
DEFINE edo    CHAR(15);
DEFINE usr    CHAR(8);
DEFINE edol   CHAR(8);
DEFINE fp     DATETIME YEAR TO MINUTE;


FOREACH cLlamadas FOR
	SELECT	fh_pllam,
			observ_pllam,
			CASE
				WHEN detp_llam.edo_pllam = 'A' THEN
					'POSPUESTO'
				WHEN detp_llam.edo_pllam = 'X' THEN
					'SUSPENDIDO'
				WHEN detp_llam.edo_pllam = 'C' THEN
					'POR CONFIRMAR'
				WHEN detp_llam.edo_pllam = 'S' THEN
					'SURTIDO'
				WHEN detp_llam.edo_pllam = 'N' THEN
					'CANCELADO'
				WHEN detp_llam.edo_pllam = 'P' THEN
					'PENDIENTE'
				ELSE
					'ABIERTO'
			END AS edo_pllam,
			usr_pllam, 
			edo_pllam AS edo,
			prog_llam.fhpr_llam
	INTO	fh, observ, edo, usr, edol,fp
    FROM 	detp_llam, prog_llam
    WHERE 	prog_llam.numcte_llam 	= detp_llam.numcte_pllam
            AND numcte_pllam 		= paramCte
	RETURN 	fh,
			observ,
			edo,
			usr,
			edol,
			fp
    WITH RESUME;
END FOREACH;

END PROCEDURE;