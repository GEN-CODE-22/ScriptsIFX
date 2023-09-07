execute PROCEDURE QryProType('15','02',764775,null,'2023-03-30')

DROP PROCEDURE QryProType;
CREATE PROCEDURE QryProType(
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramNVta	INTEGER,
	paramCte 	CHAR(6),
	paramDate	DATE
	)

	RETURNING
		CHAR(1),		
		DECIMAL,		
		DECIMAL,		
		CHAR(3);		
		
			
	DEFINE control	CHAR(1);			
	DEFINE pru		DECIMAL;			
	DEFINE iva		DECIMAL;			
	
	DEFINE tipo		CHAR(1);			
	DEFINE tprd		CHAR(3);			
	DEFINE numcte	CHAR(6);			
	DEFINE numtqe	INT;			    
	DEFINE ruta		CHAR(4);			
	DEFINE tpa		CHAR(1);	
	DEFINE vvuelta	INT;	
	DEFINE vfolenr	CHAR(10);
	
	LET vfolenr = paramCia || paramPla || LPAD(paramNVta,6,'0');
	
	SELECT  NVL(vuelta_enr,0)
	INTO	vvuelta
	FROM	enruta
	WHERE   fol_enr = vfolenr;
	
	IF	vvuelta = 0 THEN
		SELECT	NVL(vuelta_pla,0)
		INTO	vvuelta
		FROM	planta
		WHERE	cia_pla = paramCia
				AND cve_pla = paramPla;
	END IF;		
			
	IF EXISTS(SELECT 1 FROM nota_vta WHERE fol_nvta = paramNVta AND cia_nvta = paramCia AND pla_nvta = paramPla AND vuelta_nvta = vvuelta) THEN  
	
		SELECT	tprd_nvta,
				ruta_nvta,
				tip_nvta,
				numtqe_nvta,
				tpa_nvta
		INTO	tprd,
				ruta,
				tipo,
				numtqe,
				tpa
		FROM	nota_vta
		WHERE	fol_nvta = paramNVta
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla
		AND     vuelta_nvta = vvuelta;
		
		IF tprd IS NULL	AND tpa <> 'I' AND tpa <> 'F' AND tpa <> 'P' AND tpa <> 'T' THEN
		
			SELECT	precio_tqe
			INTO	tprd
			FROM	tanque
			WHERE	numcte_tqe = paramCte
			AND		numtqe_tqe = numtqe;
			
		END IF;
		
		IF tprd IS NULL THEN	
		
			SELECT	tpr_prc
			INTO	tprd
			FROM	precios
			WHERE	pri_prc = 'S'
			AND		tid_prc = tipo
			AND		reg_prc IN (SELECT	reg_rneco
								FROM	ri505_neco
								WHERE	ruta_rneco = ruta);								
			IF tprd IS NULL THEN
				SELECT	polts_dat
				INTO	tprd
				FROM	datos;
			END IF;		
			
			LET control = 'P'; 
		END IF; 
		
		IF EXISTS(SELECT 1 FROM mov_prc WHERE fei_mprc <= paramDate AND fet_mprc >= fei_mprc AND tpr_mprc = tprd) THEN
		
			
			SELECT	pru_mprc,
					iva_mprc
			INTO	pru,
					iva
			FROM	mov_prc
			WHERE	tpr_mprc = tprd
			AND		fei_mprc <= paramDate
			AND		fet_mprc >= paramDate;
			
			SELECT	numcte_nvta
			INTO	numcte
			FROM	nota_vta
			WHERE	cia_nvta = paramCia
			AND		pla_nvta = paramPla
			AND		fol_nvta = paramNVta
			AND     vuelta_nvta = vvuelta;
			
			IF (numcte = paramCte) THEN
				LET control = 'A';
			ELSE
				LET control = 'C';
			END IF;
		ELSE
			LET control = 'M';
			LET	iva = 0;
			LET pru = 0;
		END IF;	
			
	ELSE		
		LET control = 'N'; 
		LET	pru = 0;
		LET iva = 0;
	END IF;
	
	RETURN	control,
			pru,
			iva,
			tprd;

END PROCEDURE;