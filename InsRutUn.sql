CREATE PROCEDURE InsRutUn
(
	paramRu 	CHAR(4), 
	paramUnit 	CHAR(7),
	paramReg 	SMALLINT,
	paramTCel	CHAR(1)
)
RETURNING SMALLINT;
DEFINE numRut 		SMALLINT;
DEFINE numRutUnid	SMALLINT;
DEFINE numUnid 		SMALLINT;

SELECT	COUNT(*) 
INTO   	numRut
FROM   	ri505_neco
WHERE  	ruta_rneco = paramRu;

SELECT	COUNT(*) 
INTO   	numRutUnid
FROM   	ri505_neco
WHERE  	ruta_rneco = paramRu
		AND unid_rneco = paramUnit 
		AND reg_rneco = paramReg;

SELECT	COUNT(*) 
INTO   	numUnid
FROM   	ri505_neco
WHERE  	unid_rneco = paramUnit;
		

IF numUnid > 0 AND numRutUnid = 0 THEN		
	DELETE	
	FROM	ri505_neco
	WHERE	unid_rneco 	= paramUnit;
END IF;
	
IF numRut = 0 THEN
	INSERT INTO ri505_neco
			(
				ruta_rneco,
				unid_rneco,
				reg_rneco,
				tcel_rneco
			) 
	VALUES (	
				paramRu, 
				paramUnit, 
				paramReg,
				paramTCel
			);
ELSE
		UPDATE	ri505_neco
		SET		tcel_rneco 		= paramTCel
		WHERE	ruta_rneco 		= paramRu 
				AND reg_rneco 	= paramReg; 

		UPDATE	ri505_neco
		SET		unid_rneco 		= paramUnit,
				reg_rneco 		= paramReg
		WHERE	ruta_rneco 		= paramRu; 
				
		UPDATE	ri505_dneco
		SET		unid_dneco		= paramUnit
		WHERE	ruta_dneco		= paramRu
				AND reg_dneco	= paramReg
				AND	ff_dneco	= '9998-12-31 00:00';
END IF;

RETURN paramReg;

END PROCEDURE;