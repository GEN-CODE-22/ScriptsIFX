CREATE PROCEDURE next_fol_nvta
(
	xcia_nvta CHAR(2),
	xpla_nvta CHAR(2)
)
RETURNING 
 INTEGER;
{ 

}

DEFINE xerr      CHAR(1);
DEFINE xfol_nvta INTEGER;

LET xerr = 0;

LOCK TABLE planta IN EXCLUSIVE MODE;
SELECT	fnvta_pla 
INTO 	xfol_nvta 
FROM 	planta
WHERE 	cia_pla = xcia_nvta 
		AND cve_pla = xpla_nvta;

IF xfol_nvta IS NOT NULL AND xfol_nvta > 0 THEN
	IF xfol_nvta >= 999999 THEN
		LET xfol_nvta = 2501;
	ELSE
        LET xfol_nvta = xfol_nvta + 1;
    END IF;
    UPDATE	planta
    SET 	fnvta_pla = xfol_nvta
    WHERE 	cia_pla = xcia_nvta
			AND cve_pla = xpla_nvta;
ELSE
	LET xfol_nvta = 0;
    LET xerr = 1;
END IF;

UNLOCK TABLE planta;

RETURN xfol_nvta;
END PROCEDURE;