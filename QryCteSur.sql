CREATE PROCEDURE QryCteSur
(
	paramCia   CHAR(2),
	paramPla   CHAR(2),
	paramRuta  CHAR(4),
	paramAnio  INT
)
RETURNING
 INT,
 INT,
 DECIMAL;

 DEFINE vannio 		INT;
 DEFINE vmes	 	INT;
 DEFINE vcant		DECIMAL;
 DEFINE vcantdrd	DECIMAL;
 DEFINE vsurvey_cfg CHAR(50);
 DEFINE vtpdopro 	CHAR(1);
 DEFINE vtpdosurvey	CHAR(1);

LET	vtpdopro = 'P';
LET	vtpdosurvey = '';

SELECT	value_cfg
INTO	vsurvey_cfg
FROM	cfg_llam
WHERE	key_cfg = 'ACTIVESURVEY_CFG';

IF	vsurvey_cfg = '1'	THEN
	LET	vtpdosurvey = 'E';
END IF;

FOREACH cCursorCte FOR
	SELECT	YEAR(nota_vta.fes_nvta),
	   		MONTH(nota_vta.fes_nvta),
	   		COUNT(nota_vta.numcte_nvta)
	INTO	vannio,
			vmes,
			vcant
	FROM	nota_vta 
	WHERE  	YEAR(nota_vta.fes_nvta)  = paramAnio       		
		   	AND nota_vta.edo_nvta	 = 'A' 
		   	AND nota_vta.cia_nvta    = paramCia  
		   	AND nota_vta.pla_nvta    = paramPla
		   	AND nota_vta.ruta_nvta   = paramRuta
		   	AND (nota_vta.tpdo_nvta  IN(vtpdopro) OR nota_vta.tpdo_nvta IN(vtpdosurvey))
	GROUP BY 1,2
 	UNION 
	SELECT	YEAR(rdnota_vta.fes_nvta),
	   		MONTH(rdnota_vta.fes_nvta),
	   		COUNT(rdnota_vta.numcte_nvta)
	FROM	rdnota_vta 
	WHERE  	YEAR(rdnota_vta.fes_nvta)	= paramAnio       		
		   	AND rdnota_vta.edo_nvta	 	= 'A' 
		   	AND rdnota_vta.cia_nvta    	= paramCia  
		   	AND rdnota_vta.pla_nvta    	= paramPla
		   	AND rdnota_vta.ruta_nvta   	= paramRuta
		   	AND (rdnota_vta.tpdo_nvta  IN(vtpdopro) OR rdnota_vta.tpdo_nvta IN(vtpdosurvey))
	GROUP BY 1,2	
	
	RETURN 	vannio,
			vmes,
			vcant
    WITH RESUME;
 END FOREACH; 
 
END PROCEDURE; 