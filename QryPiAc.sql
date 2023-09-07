CREATE PROCEDURE QryPiAc(paramCia CHAR(2), 	
						 paramPla CHAR(5))	
	RETURNING	CHAR(19), 
				CHAR(7),
				SMALLINT;

	DEFINE 		fullName 	CHAR(19); 		
	DEFINE 		unitId 		CHAR(7);			
	DEFINE		ocup		SMALLINT;			
	DEFINE cvepla1		CHAR(2); 
	DEFINE cvepla2		CHAR(2); 

IF LENGTH(paramPla) = 2 THEN
	FOREACH cursorcanc FOR
		SELECT 	cve_uni || ' / ' || plc_uni AS name, 
				cve_uni,
				0 AS ocu_uni
		INTO 	fullName, 
				unitId,
				ocup
		FROM unidad
		WHERE edo_uni = 'A'
		AND cia_uni = paramCia
		AND pla_uni = paramPla
		AND cve_uni NOT IN(
							SELECT	eco_crut 
							FROM	corte_rut
							WHERE	sta_crut = 'A'
						   )
		UNION		
		SELECT	unidad.cve_uni || ' / ' || unidad.plc_uni AS name,
				unidad.cve_uni,
				1 AS ocu_uni
		FROM	unidad, corte_rut
		WHERE	unidad.cve_uni = corte_rut.eco_crut
		AND		unidad.cia_uni = corte_rut.cia_crut
		AND		unidad.pla_uni = corte_rut.pla_crut
		AND		unidad.cia_uni = paramCia
		AND		unidad.pla_uni = paramPla
		AND		corte_rut.sta_crut = 'A'		
		ORDER BY 2
		RETURN 	fullName, 
				unitId,
				ocup				
		WITH RESUME;
	END FOREACH;
ELSE
	LET cvepla1 = SUBSTR(paramPla, 1,2);
	LET cvepla2 = SUBSTR(paramPla, 4,2);
	FOREACH cursorcanc FOR
		SELECT 	cve_uni || ' / ' || plc_uni AS name, 
				cve_uni,
				0 AS ocu_uni
		INTO 	fullName, 
				unitId,
				ocup
		FROM unidad
		WHERE edo_uni = 'A'
		AND cia_uni = paramCia
		AND pla_uni = cvepla1
		AND cve_uni NOT IN(
							SELECT	eco_crut 
							FROM	corte_rut
							WHERE	sta_crut = 'A'
						   )
		UNION		
		SELECT	unidad.cve_uni || ' / ' || unidad.plc_uni AS name,
				unidad.cve_uni,
				1 AS ocu_uni
		FROM	unidad, corte_rut
		WHERE	unidad.cve_uni = corte_rut.eco_crut
		AND		unidad.cia_uni = corte_rut.cia_crut
		AND		unidad.pla_uni = corte_rut.pla_crut
		AND		unidad.cia_uni = paramCia
		AND		unidad.pla_uni = cvepla1
		AND		corte_rut.sta_crut = 'A'
		UNION
		SELECT 	cve_uni || ' / ' || plc_uni AS name, 
				cve_uni,
				0 AS ocu_uni
		FROM unidad
		WHERE edo_uni = 'A'
		AND cia_uni = paramCia
		AND pla_uni = cvepla2
		AND cve_uni NOT IN(
							SELECT	eco_crut 
							FROM	corte_rut
							WHERE	sta_crut = 'A'
						   )
		UNION		
		SELECT	unidad.cve_uni || ' / ' || unidad.plc_uni AS name,
				unidad.cve_uni,
				1 AS ocu_uni
		FROM	unidad, corte_rut
		WHERE	unidad.cve_uni = corte_rut.eco_crut
		AND		unidad.cia_uni = corte_rut.cia_crut
		AND		unidad.pla_uni = corte_rut.pla_crut
		AND		unidad.cia_uni = paramCia
		AND		unidad.pla_uni = cvepla2
		AND		corte_rut.sta_crut = 'A'			
		ORDER BY 2
		RETURN 	fullName, 
				unitId,
				ocup				
		WITH RESUME;
	END FOREACH;
END IF;
END PROCEDURE;