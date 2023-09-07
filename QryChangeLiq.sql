CREATE PROCEDURE QryChangeLiq
(
	paramLiq   INTEGER,
	paramCia   CHAR(2),
	paramPla   CHAR(2),
	paramRuta  CHAR(4)
)
RETURNING 
 DATETIME YEAR TO SECOND,
 CHAR(10), 
 CHAR(100), 
 CHAR(50);

DEFINE vfecha		DATETIME YEAR TO SECOND; 
DEFINE vnota		INTEGER; 
DEFINE vcambio		CHAR(100); 
DEFINE vusrliq		CHAR(8);
DEFINE vusr			CHAR(50); 

FOREACH cursorLiq FOR
	SELECT	changes_liq.fecha_cliq,
			changes_liq.cia_cliq || changes_liq.pla_cliq || changes_liq.nvta_cliq,
			changes_liq.cambio_cliq,
			changes_liq.usr_cliq
	INTO   	vfecha,
			vnota,
			vcambio,			
			vusrliq
	FROM   	changes_liq			
	WHERE  	changes_liq.liq_cliq		= paramLiq
			AND changes_liq.cia_cliq	= paramCia
			AND changes_liq.pla_cliq	= paramPla
			AND changes_liq.ruta_cliq	= paramRuta			
	ORDER BY changes_liq.fecha_cliq DESC
	
	SELECT	UPPER(NVL(usr_cve.nom_ucve,usr_cve.usr_ucve))
	INTO	vusr
	FROM	usr_cve
	WHERE	UPPER(usr_cve.usr_ucve) = UPPER(vusrliq);
	
	RETURN	vfecha,
			vnota,
			vcambio,			
			vusr
	WITH RESUME;
END FOREACH; 

END PROCEDURE;