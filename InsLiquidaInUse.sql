CREATE PROCEDURE InsLiquidaInUse(paramLiq	INT, 
								 paramRout 	CHAR(4),
								 paramUser 	CHAR(8))
	RETURNING 
		INT;				

	DEFINE 	reserved	INT;					 
	DEFINE 	currentDT	DATETIME YEAR TO MINUTE; 
	
	SELECT 	DBINFO('utc_to_datetime',sh_curtime)
	INTO 	currentDT
	FROM 	sysmaster:'informix'.sysshmvals;
	

	IF EXISTS(SELECT 1 FROM ruta_enuso WHERE fliq_renuso = paramLiq AND ruta_renuso = paramRout) THEN --Significa que ya existe y no se puede marcar de nuevo
		
		LET reserved = 0;
		
	ELSE
	
			INSERT INTO ruta_enuso
					   (fliq_renuso,
						ruta_renuso,
						fyh_renuso,
						usr_renuso
					   )
			VALUES	   (paramLiq,
						paramRout,
						currentDT,
						paramUser
					   );
					   
			LET reserved = 1;
								   
	
	END IF;
	
	RETURN reserved;	

END PROCEDURE;                                                       