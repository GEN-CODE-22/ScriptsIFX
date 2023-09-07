CREATE PROCEDURE Qry_RutaUso
(

)
RETURNING 
 INTEGER,
 CHAR(4), 
 DATETIME YEAR TO MINUTE,
 CHAR(8);

DEFINE vfliq		INTEGER; 
DEFINE vruta		CHAR(4); 
DEFINE vfecha		DATETIME YEAR TO MINUTE; 
DEFINE vuser		CHAR(8);

FOREACH cursorRutaUso FOR
	SELECT	fliq_renuso,
			ruta_renuso,
			fyh_renuso,
			usr_renuso			
	INTO   	vfliq,
			vruta,
			vfecha,
			vuser
	FROM   	ruta_enuso
	ORDER BY ruta_renuso

	RETURN	vfliq,
			vruta,
			vfecha,
			vuser
	WITH RESUME;
END FOREACH; 

END PROCEDURE;                               