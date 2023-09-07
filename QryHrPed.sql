CREATE PROCEDURE QryHrPed
(
	paramFec	DATE,
	paramCia	CHAR(2),
	paramPla	CHAR(2),	
	paramRuta 	CHAR(4) 
)
RETURNING 
 DATE, 
 SMALLINT,  
 CHAR(2),
 CHAR(2), 
 CHAR(4),
 CHAR(6);

DEFINE vfecha 	DATE; 
DEFINE vhora 	SMALLINT;
DEFINE vcia 	CHAR(2);
DEFINE vplanta  CHAR(2);
DEFINE vruta	CHAR(4);
DEFINE vcte		CHAR(6);

FOREACH cursorHRped FOR

	SELECT 	fec_hped,
			hr_hped,
			cia_hped,
			pla_hped,
			ruta_hped,
			cte_hped
	INTO   	vfecha,
			vhora,
			vcia,
			vplanta,
			vruta,
			vcte
	FROM 	hr_ped	
	WHERE 	fec_hped		= paramFec
			AND cia_hped 	= paramCia
			AND pla_hped	= paramPla
			AND ruta_hped	= paramRuta
	ORDER BY hr_hped
	RETURN 	vfecha,
			vhora,
			vcia,
			vplanta,
			vruta,
			vcte
	WITH RESUME;
END FOREACH;

END PROCEDURE;  