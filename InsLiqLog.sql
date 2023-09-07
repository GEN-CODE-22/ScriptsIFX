CREATE PROCEDURE InsLiqLog(
	paramLiq	INTEGER,
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramNvta	CHAR(10),
	paramUser	CHAR(8),
	paramCom 	CHAR(100),
	paramEtp	CHAR(100),
	paramResult	CHAR(100)
	)

	RETURNING
		CHAR(1);		
		
			
	DEFINE control	CHAR(1);			
	
	
	INSERT INTO	liq_log (liq_liqlog,
						 cia_liqlog,
						 pla_liqlog,
						 nvta_liqlog,
						 usr_liqlog,
						 obser_liqlog,
						 etapa_liqlog,
						 res_liqlog
						  )
	VALUES				 (paramLiq,
						  paramCia,
						  paramPla,
						  paramNvta,
						  paramUser,
						  paramCom,
						  paramEtp,
						  paramResult
						  );
	LET control = 'A';
	
	
	RETURN	control;

END PROCEDURE;