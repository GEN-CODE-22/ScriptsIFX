CREATE PROCEDURE InsDRutUn
(
	paramRuta 	CHAR(4), 
	paramUnit 	CHAR(7),
	paramReg 	SMALLINT, 
	paramFi 	DATETIME YEAR TO MINUTE, 
	paramFf 	DATETIME YEAR TO MINUTE,
	paramMaxF 	DATETIME YEAR TO MINUTE,
	paramInsert CHAR(1)
)


DEFINE numReg SMALLINT;
DEFINE vobserlog	CHAR(1500);
DEFINE fechaHoralog DATETIME YEAR TO MINUTE;

SELECT 	CURRENT
INTO 	fechaHoralog
FROM 	systables
WHERE 	tabid = 1;

SELECT	COUNT(ruta_dneco) 
INTO   	numReg
FROM   	ri505_dneco
WHERE  	ruta_dneco = paramRuta;

IF numReg > 0 THEN
	UPDATE	ri505_dneco 
	SET 	ff_dneco = paramFf
	WHERE 	ruta_dneco = paramRuta
			AND ff_dneco =  paramMaxF;	
END IF;

IF paramInsert = "I" AND
	NOT EXISTS( SELECT	1
				FROM	ri505_dneco
				WHERE	ruta_dneco 		=  paramRuta
						AND ff_dneco 	=  paramMaxF) THEN
	INSERT INTO	ri505_dneco (
					ruta_dneco, 
					unid_dneco, 
					reg_dneco, 
					fi_dneco, 
					ff_dneco
					)
	VALUES      (
					paramRuta, 
					paramUnit,
					paramReg, 
					paramFi, 
					paramFf
				);		

END IF;	
	
END PROCEDURE;   