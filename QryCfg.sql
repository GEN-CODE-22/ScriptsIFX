CREATE PROCEDURE QryCfg
(

)
RETURNING 
 CHAR(20), 
 CHAR(50);
 
DEFINE vllave 	CHAR(20); 
DEFINE vvalor 	CHAR(50);

FOREACH cursorcanc FOR

	SELECT 	TRIM(key_cfg), 
			value_cfg
	INTO   	vllave, 
			vvalor
	FROM 	cfg_llam
	RETURN 	vllave, 
			vvalor
	WITH RESUME;
END FOREACH;
END PROCEDURE; 