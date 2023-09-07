CREATE PROCEDURE QryEmp()

RETURNING
	CHAR(5),			
	CHAR(30),		
	CHAR(20),		
	CHAR(51),		
	SMALLINT;		
	
DEFINE cve		CHAR(5);	
DEFINE ape	 	CHAR(30); 
DEFINE nom	    CHAR(20);	
DEFINE nomcom   CHAR(51);   
DEFINE ocu		SMALLINT;

FOREACH cEcoRuta FOR 

	SELECT		cve_emp,
				ape_emp,
				nom_emp,
				substr(cat_emp,7,5) || ' - ' || trim(ape_emp) || ' ' || trim(nom_emp) AS com,
				0 AS ocu_emp
	INTO		cve,
				ape,
				nom,
				nomcom,
				ocu
	FROM		empleado
	WHERE		edo_emp = 'A'						
	AND			tip_emp = 'S'						
	AND			cve_emp NOT IN (
								 SELECT emc_crut
								 FROM	corte_rut
								 WHERE	sta_crut = 'A'
							   )
	AND			cve_emp NOT IN (
								 SELECT ema_crut
								 FROM	corte_rut
								 WHERE	sta_crut = 'A'
							   )
	AND			cve_emp NOT IN (
								 SELECT ems_crut
								 FROM	corte_rut
								 WHERE	sta_crut = 'A'
							   )
							   
	UNION
	
	SELECT		empleado.cve_emp,
				empleado.ape_emp,
				empleado.nom_emp,
				substr(empleado.cat_emp,7,5) || ' - ' || trim(empleado.ape_emp) || ' ' || trim(empleado.nom_emp) AS com,
				1 AS ocu_emp
	FROM		empleado, corte_rut
	WHERE		(empleado.cve_emp = corte_rut.emc_crut
	OR		 	 empleado.cve_emp = corte_rut.ema_crut
	OR		 	 empleado.cve_emp = corte_rut.ems_crut
				)
	AND			corte_rut.sta_crut = 'A'		
	
	
	
	ORDER BY 	4
	
	RETURN		cve,
				ape,
				nom,
				nomcom,
				ocu
	WITH RESUME;		
	

END FOREACH; 

END PROCEDURE; 