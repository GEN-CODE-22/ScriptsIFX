CREATE PROCEDURE QryEcoRu(paramRuta char(4),		
						  paramFecate char(8))						  
	
	RETURNING	char(7);									
				
	DEFINE		eco char(7);								
				
	FOREACH cursorcanc FOR					  
						  
		SELECT 	 DISTINCT eco_enr										 
		INTO	 eco
		FROM  	 enruta
		WHERE 	 substr(fecate_enr, 1, 8) = paramFecate			
		AND   	 edoreg_enr IN ('F' , 'N')						
		AND   	 ruta_enr = paramRuta										
		RETURN 	 eco
		WITH RESUME;
		
	END FOREACH;						  						  
						  
END PROCEDURE;