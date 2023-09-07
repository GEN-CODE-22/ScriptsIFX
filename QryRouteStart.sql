CREATE PROCEDURE QryRouteStart(
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramFecha	CHAR(10),
	paramFormat CHAR(8),
	paramFecate CHAR(8))

	RETURNING
		CHAR(12),		
		CHAR(6),		
		CHAR(6),		
		CHAR(7),		
		CHAR(4),		
		CHAR(6),		
		CHAR(10),		
		SMALLINT,		
		INTEGER,		
		INTEGER,		
		CHAR(34),		
		CHAR(17);		
		
	DEFINE fol		CHAR(12);			
	DEFINE numcte	CHAR(6);			
	DEFINE prc		CHAR(6);			
	DEFINE eco		CHAR(7);			
	DEFINE ruta		CHAR(4);			
	DEFINE ltssur	CHAR(6);			
	DEFINE totvta	CHAR(10);			
	DEFINE tippgo	SMALLINT;			
	DEFINE fliq		INTEGER;			
	DEFINE golpe	INTEGER;			
	DEFINE ubicte	CHAR(34);			
	DEFINE fecate   CHAR(17);			
	
	DEFINE rutInt	CHAR(4);
	DEFINE ecoInt	CHAR(6);
	DEFINE fliqInt	INTEGER;
	
	FOREACH cursorcanc FOR
	
		SELECT	rut_crut,
				eco_crut,
				fliq_crut
		INTO	rutInt,
				ecoInt,
				fliqInt
		FROM	corte_rut
		WHERE	cia_crut = paramCia
		AND		pla_crut = paramPla
		AND		fec_crut = TO_DATE(paramFecha, paramFormat)
		AND		sta_crut = 'A'
		AND		fliq_crut NOT IN (SELECT 	fliq_renuso
								  FROM  	ruta_enuso
								  WHERE 	ruta_renuso = rut_crut)
		
		FOREACH cCursorDef FOR
		
			SELECT	fol_enr,
					numcte_enr,
					prc_enr,
					eco_enr,
					ruta_enr,
					ltssur_enr,
					totvta_enr,
					tippgo_enr,
					golpe_enr,
					ubicte_enr,
					fecate_enr
			INTO	fol,
					numcte,
					prc,
					eco,
					ruta,
					ltssur,
					totvta,
					tippgo,
					golpe,
					ubicte,
					fecate
			FROM	enruta
			WHERE	SUBSTR(fecate_enr, 1, 8) = paramFecate
			AND		edoreg_enr IN ('F', 'N')
			AND		edovta_enr NOT IN ('f', 'l')
			AND		(ruta_enr = rutInt 
			OR		eco_enr = ecoInt)
			ORDER BY golpe_enr
			RETURN	fol,
					numcte,
					prc,
					eco,
					ruta,
					ltssur,
					totvta,
					tippgo,
					fliqInt,
					golpe,
					ubicte,
					fecate
			WITH RESUME;
		
		END FOREACH;
		
	
	END FOREACH;

END PROCEDURE;						