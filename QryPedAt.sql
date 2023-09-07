CREATE PROCEDURE QryPedAt(paramRuta char(4),		
						  paramFecate char(8))							  
	
	RETURNING	char(7),									
				int,										
				int,										
				decimal,									
				char(8),								
				char(8);								
	
	DEFINE 		ecoParent char(6);						
				
	DEFINE		eco char(7);								
	DEFINE		lts int;								
	DEFINE		service int;								
	DEFINE		totalc decimal;								
	DEFINE		firstServ char(8);							
	DEFINE		lastServ char(8);							
	
	
	FOREACH cursorEco FOR
	
		SELECT DISTINCT eco_enr									
		INTO  ecoParent												 
		FROM  enruta
		WHERE ruta_enr = paramRuta
		AND substr(fecate_enr, 1, 8) = paramFecate
		AND edoreg_enr IN ('F', 'N')
				
		FOREACH cursorcanc FOR					  
							  
			SELECT 	 eco_enr, 										
					 SUM(ltssur_enr * 1) AS lts, 					
					 COUNT(eco_enr) AS services, 					
					 SUM(totvta_enr * 1) AS total,					
					 MIN(substr(fecate_enr, 10, 8)) initialHour, 	
					 MAX(substr(fecate_enr,10, 8)) finalHour		
			INTO	 eco,
					 lts,
					 service,
					 totalc,
					 firstServ,
					 lastServ
			FROM  	 enruta
			WHERE 	 substr(fecate_enr, 1, 8) = paramFecate			
			AND   	 edoreg_enr IN ('F' , 'N')						
			AND   	 (ruta_enr = paramRuta							
			OR		  eco_enr = ecoParent)							
			GROUP BY eco_enr
			RETURN 	 eco,
					 lts,
					 service,
					 totalc,
					 firstServ,
					 lastServ
			WITH RESUME;
			
		END FOREACH;						  						  
	
	END FOREACH;
END PROCEDURE;