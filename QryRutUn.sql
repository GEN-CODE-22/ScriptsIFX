CREATE PROCEDURE QryRutUn
(
	paramCia_rut CHAR(2), 
	paramPla_rut CHAR(2)
)
RETURNING 
 CHAR(4), 
 CHAR(7),  
 DATETIME YEAR TO MINUTE,
 DATETIME YEAR TO MINUTE, 
 SMALLINT,
 SMALLINT;

DEFINE ruta 	CHAR(4); 
DEFINE unidad 	CHAR(7);
DEFINE fi 		DATETIME YEAR TO MINUTE;
DEFINE ff 		DATETIME YEAR TO MINUTE;
DEFINE reg		SMALLINT;
DEFINE tcel		SMALLINT;

FOREACH cursorcanc FOR

	SELECT 	ri505_dneco.ruta_dneco, 
			ri505_dneco.unid_dneco,
			ri505_dneco.fi_dneco, 
			ri505_dneco.ff_dneco,
			ri505_dneco.reg_dneco,
			CASE
			WHEN ri505_neco.tcel_rneco = 'S' THEN
			1
			ELSE
			0
			END AS tcel_rneco
	INTO   	ruta, 
			unidad, 
			fi, 
			ff,
			reg,
			tcel
	FROM 	ri505_dneco, 
			ruta,
			ri505_neco
	WHERE 	ff_dneco 					= '9998-12-31 00:00'
			AND ri505_dneco.ruta_dneco 	= ruta.cve_rut
			AND ruta.cia_rut 			= paramCia_rut
			AND ruta.pla_rut 			= paramPla_rut
			AND ri505_dneco.ruta_dneco 	= ri505_neco.ruta_rneco
			AND ri505_dneco.unid_dneco 	= ri505_neco.unid_rneco
			AND ri505_dneco.reg_dneco 	= ri505_neco.reg_rneco
	ORDER BY ri505_dneco.ruta_dneco
	RETURN 	ruta, 
			unidad, 
			fi, 
			ff,
			reg,
			tcel
	WITH RESUME;
END FOREACH;
END PROCEDURE;  