CREATE PROCEDURE DelLiquidaInUse(paramLiq	INT, 
								 paramRout 	CHAR(4),
								 paramUser 	CHAR(8))
	RETURNING 
		INT;				
	
	DEFINE	reserved	INT;
	

	IF EXISTS(SELECT 1 FROM ruta_enuso WHERE fliq_renuso = paramLiq AND ruta_renuso = paramRout AND usr_renuso = paramUser) THEN
		
			DELETE FROM	ruta_enuso
			WHERE		fliq_renuso = paramLiq
			AND			ruta_renuso = paramRout
			AND			usr_renuso = paramUser;
					   
			LET reserved = 1;	
	ELSE	
			LET reserved = 0;
	END IF;
	
	RETURN reserved;	

END PROCEDURE;                                                       