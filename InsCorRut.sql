CREATE PROCEDURE InsCorRut(paramCia	char(2),					
						   paramPla	char(2),					
						   paramFec	date,						
						   paramRut	char(4),					
						   paramEco	char(6),					
						   paramHoi	datetime hour to second,	
						   paramHof	datetime hour to second,	
						   paramTon	integer,					
						   paramTol	decimal(12,2),				
						   paramPti	decimal(12,2),				
						   paramPtf	decimal(12,2),				
						   paramCta	decimal(12,2))				

	

	DEFINE Consecutivo integer; 
	
	SELECT 	COUNT(con_crut) INTO Consecutivo
	FROM 	corte_rut
	WHERE 	cia_crut = paramCia
	AND		pla_crut = paramPla
	AND		fec_crut = paramFec
	AND		rut_crut = paramRut;
	
	INSERT INTO corte_rut 
	VALUES		(paramCia, 
				 paramPla,
				 paramFec,
				 consecutivo,
				 paramRut,
				 paramEco,
				 paramHoi,
				 paramHof,
				 paramTon,
				 paramTol,
				 paramPti,
				 paramPtf,
				 paramCta,
				 'A'
				);
						
END PROCEDURE;