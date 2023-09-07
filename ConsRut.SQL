CREATE PROCEDURE ConsRut
(
	paramCia CHAR(2), 
	paramPla CHAR(5)
)
RETURNING 
 CHAR(4), 
 CHAR(40), 
 CHAR(2), 
 CHAR(2), 
 CHAR(57);

DEFINE cve		CHAR(4); 
DEFINE descr 	CHAR(40);
DEFINE cia 		CHAR(2); 
DEFINE pla 		CHAR(2);
DEFINE nomComp 	CHAR(57);
DEFINE cvepla1	CHAR(2); 
DEFINE cvepla2	CHAR(2); 

IF LENGTH(paramPla) = 2 THEN
	FOREACH consorcanc FOR
		SELECT	cve_rut, 
				desc_rut, 
				cia_rut,
				pla_rut, (cve_rut || ' - ' || 
				cia_rut || ' - ' || pla_rut || ' - ' || 
				CASE 
					WHEN TRIM(desc_rut) <> '' THEN TRIM(desc_rut) 
					ELSE 'N/D' 
				END) AS nombreCompleto
		INTO   	cve, 
				descr, 
				cia, 
				pla, 
				nomComp
		FROM   	ruta
		WHERE  	edo_rut = 'A'
				AND cia_rut = paramCia
				AND pla_rut = paramPla
		ORDER BY cve_rut
		RETURN 	cve, 
				descr, 
				cia, 
				pla, 
				nomComp
		WITH RESUME;		   
	END FOREACH;
ELSE
	LET cvepla1 = SUBSTR(paramPla, 1,2);
	LET cvepla2 = SUBSTR(paramPla, 4,2);
	FOREACH consorcanc FOR
		SELECT	cve_rut, 
				desc_rut, 
				cia_rut,
				pla_rut, (cve_rut || ' - ' || 
				cia_rut || ' - ' || pla_rut || ' - ' || 
				CASE 
					WHEN TRIM(desc_rut) <> '' THEN TRIM(desc_rut) 
					ELSE 'N/D' 
				END) AS nombreCompleto
		INTO   	cve, 
				descr, 
				cia, 
				pla, 
				nomComp
		FROM   	ruta
		WHERE  	edo_rut = 'A'
				AND cia_rut = paramCia
				AND pla_rut = cvepla1
		UNION 
		SELECT	cve_rut, 
				desc_rut, 
				cia_rut,
				pla_rut, (cve_rut || ' - ' || 
				cia_rut || ' - ' || pla_rut || ' - ' || 
				CASE 
					WHEN TRIM(desc_rut) <> '' THEN TRIM(desc_rut) 
					ELSE 'N/D' 
				END) AS nombreCompleto		
		FROM   	ruta
		WHERE  	edo_rut = 'A'
				AND cia_rut = paramCia
				AND pla_rut = cvepla2
		ORDER BY 1
		RETURN 	cve, 
				descr, 
				cia, 
				pla, 
				nomComp
		WITH RESUME;		   
	END FOREACH;
END IF;
END PROCEDURE;