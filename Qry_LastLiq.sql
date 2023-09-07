CREATE PROCEDURE Qry_LastLiq
(
	paramCia   CHAR(2),
	paramPla   CHAR(5)
)
RETURNING 
 CHAR(4), 
 CHAR(7), 
 INTEGER,
 CHAR(5),
 CHAR(5),
 CHAR(5),
 CHAR(1),
 DECIMAL;

DEFINE vruta		CHAR(4); 
DEFINE vunidad		CHAR(7); 
DEFINE vregion		INTEGER;
DEFINE vchofer		CHAR(5); 
DEFINE vayud1		CHAR(5); 
DEFINE vayud2		CHAR(5); 
DEFINE vtpago		CHAR(1); 
DEFINE vlastfol		INT; 
DEFINE vlastdate1	DATE; 
DEFINE vlfi			DECIMAL; 
DEFINE vlastliq		DECIMAL; 
DEFINE cvepla1		CHAR(2); 
DEFINE cvepla2		CHAR(2); 

IF LENGTH(paramPla) = 2 THEN
	FOREACH cursorRuta FOR
		SELECT	DISTINCT cve_rut,
				reg_rut			
		INTO   	vruta,
				vregion
		FROM   	ruta,
				empxrutp
		WHERE  	edo_rut = 'A'
				AND cia_rut 	= paramCia
				AND pla_rut 	= paramPla
				AND cve_rut[1] 	= 'M'
				AND ruta.cve_rut = empxrutp.rut_erup
		ORDER BY cve_rut
	
		IF LENGTH(vruta) > 0 AND vregion > 0   THEN	
					
			SELECT	MAX(fec_erup)
			INTO	vlastdate1
			FROM	empxrutp
			WHERE	rut_erup = vruta
					AND	edo_erup = 'C';
					
			SELECT	MAX(fliq_erup)
			INTO	vlastfol
			FROM	empxrutp
			WHERE	rut_erup 		= vruta
					AND fec_erup 	= vlastdate1
					AND	edo_erup 	= 'C';
		
			SELECT	rut_erup,	
					uni_erup,
					NVL(substr(chofer.cat_emp,7,5),'0'),
					CASE 
						WHEN TRIM(empxrutp.ay1_erup) <> '' THEN
				   			substr(ayud1.cat_emp,7,5) 
						ELSE
							'0'
					END AS ay1_erup,
					CASE 
						WHEN TRIM(empxrutp.ay2_erup) <> '' THEN
				   			substr(ayud2.cat_emp,7,5) 
						ELSE
							'0'
					END AS ay2_erup,
					pcs_erup
			INTO	vruta,
					vunidad,
					vchofer,
					vayud1,
					vayud2,
					vtpago
			FROM	empxrutp,
					empleado chofer,
					OUTER empleado ayud1,
					OUTER empleado ayud2
			WHERE	rut_erup 		= vruta
					AND fliq_erup 	= vlastfol
					AND fec_erup	= vlastdate1
					AND	edo_erup 	= 'C'
					AND empxrutp.chf_erup = chofer.cve_emp
					AND empxrutp.ay1_erup = ayud1.cve_emp
					AND empxrutp.ay2_erup = ayud2.cve_emp;	
			
				
			SELECT 	MAX(fec_erup) 
			INTO 	vlastdate1 
			FROM 	empxrutp
			WHERE 	empxrutp.uni_erup = vunidad
					AND	edo_erup = 'C';
				
			SELECT 	MAX(lfi_erup) 
			INTO   	vlfi
			FROM 	empxrutp
			WHERE 	empxrutp.uni_erup = vunidad 
					AND	empxrutp.fec_erup = vlastdate1;
			
			RETURN	vruta,
				vunidad,
				vregion,
				vchofer,
				vayud1,
				vayud2,
				vtpago,
				vlfi
			WITH RESUME;
	
		END IF;
		
	END FOREACH; 
ELSE
	LET cvepla1 = SUBSTR(paramPla, 1,2);
	LET cvepla2 = SUBSTR(paramPla, 4,2);
	FOREACH cursorRuta FOR
		SELECT	DISTINCT cve_rut,
				reg_rut			
		INTO   	vruta,
				vregion
		FROM   	ruta,
				empxrutp
		WHERE  	edo_rut = 'A'
				AND cia_rut 	= paramCia
				AND pla_rut 	= cvepla1
				AND cve_rut[1] 	= 'M'
				AND ruta.cve_rut = empxrutp.rut_erup
		UNION
		SELECT	DISTINCT cve_rut,
				reg_rut	
		FROM   	ruta,
				empxrutp
		WHERE  	edo_rut = 'A'
				AND cia_rut 	= paramCia
				AND pla_rut 	= cvepla2
				AND cve_rut[1] 	= 'M'
				AND ruta.cve_rut = empxrutp.rut_erup
		ORDER BY 1
	
		IF LENGTH(vruta) > 0 AND vregion > 0   THEN	
					
			SELECT	MAX(fec_erup)
			INTO	vlastdate1
			FROM	empxrutp
			WHERE	rut_erup = vruta
					AND	edo_erup = 'C';
					
			SELECT	MAX(fliq_erup)
			INTO	vlastfol
			FROM	empxrutp
			WHERE	rut_erup 		= vruta
					AND fec_erup 	= vlastdate1
					AND	edo_erup 	= 'C';
		
			SELECT	rut_erup,	
					uni_erup,
					NVL(substr(chofer.cat_emp,7,5),'0'),
					CASE 
						WHEN TRIM(empxrutp.ay1_erup) <> '' THEN
				   			substr(ayud1.cat_emp,7,5) 
						ELSE
							'0'
					END AS ay1_erup,
					CASE 
						WHEN TRIM(empxrutp.ay2_erup) <> '' THEN
				   			substr(ayud2.cat_emp,7,5) 
						ELSE
							'0'
					END AS ay2_erup,
					pcs_erup
			INTO	vruta,
					vunidad,
					vchofer,
					vayud1,
					vayud2,
					vtpago
			FROM	empxrutp,
					empleado chofer,
					OUTER empleado ayud1,
					OUTER empleado ayud2
			WHERE	rut_erup 		= vruta
					AND fliq_erup 	= vlastfol
					AND fec_erup	= vlastdate1
					AND	edo_erup 	= 'C'
					AND empxrutp.chf_erup = chofer.cve_emp
					AND empxrutp.ay1_erup = ayud1.cve_emp
					AND empxrutp.ay2_erup = ayud2.cve_emp;	
			
				
			SELECT 	MAX(fec_erup) 
			INTO 	vlastdate1 
			FROM 	empxrutp
			WHERE 	empxrutp.uni_erup = vunidad
					AND	edo_erup = 'C';
				
			SELECT 	MAX(lfi_erup) 
			INTO   	vlfi
			FROM 	empxrutp
			WHERE 	empxrutp.uni_erup = vunidad 
					AND	empxrutp.fec_erup = vlastdate1;
			
			RETURN	vruta,
				vunidad,
				vregion,
				vchofer,
				vayud1,
				vayud2,
				vtpago,
				vlfi
			WITH RESUME;
	
		END IF;
		
	END FOREACH; 
END IF;
END PROCEDURE;