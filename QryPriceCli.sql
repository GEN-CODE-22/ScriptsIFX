CREATE PROCEDURE QryPriceCli(
	paramDate	DATE,
	paramTpr	CHAR(3),
	paramCli	CHAR(6),
	paramTank	SMALLINT,
	paramRuta	CHAR(4),
	paramTpa	CHAR(1)
	)

	
	RETURNING
		CHAR(3),			
		DECIMAL,			
		DATE,				
		DATE,				
		DECIMAL;			
		
	DEFINE tpr	CHAR(3);	
	DEFINE pru	DECIMAL;	
	DEFINE fei	DATE;		
	DEFINE fet	DATE;		
	DEFINE iva	DECIMAL;	
	DEFINE qpr	CHAR(3);	
	DEFINE vreg SMALLINT;
	
	LET qpr = NULL;
	
	IF LENGTH(paramTpr) = 0 THEN
		LET paramTpr = NULL;
	END IF;
	
	IF paramTpa <> 'I' AND paramTpa <> 'F' AND paramTpa <> 'P' AND paramTpa <> 'T' THEN
		LET qpr = paramTpr;
	END IF;
	
	IF paramCli IS NOT NULL AND paramTank IS NOT NULL AND paramTpr IS NULL
		AND paramTpa <> 'I' AND paramTpa <> 'F' AND paramTpa <> 'P' AND paramTpa <> 'T' THEN
	
		SELECT	precio_tqe
		INTO	qpr
		FROM	tanque
		WHERE	numcte_tqe = paramCli
		AND		numtqe_tqe = paramTank;
		
	END IF;
	
	IF qpr IS NULL THEN	
		SELECT	reg_rut
		INTO	vreg
		FROM	ruta
		WHERE	cve_rut = paramRuta;
		
		SELECT	MIN(tpr_prc)
		INTO	qpr
		FROM	precios
		WHERE	tid_prc = paramTpa
				AND reg_prc = vreg
				AND ((pri_prc = 'S' AND paramTpa IN('E','C')) OR pri_prc = 'N');
	END IF;
	
	FOREACH consorcanc FOR	
		SELECT	tpr_mprc,
				pru_mprc,
				fei_mprc,
				fet_mprc,
				iva_mprc
		INTO	tpr,
				pru,
				fei,
				fet,
				iva
		FROM	mov_prc
		WHERE	fei_mprc <= paramDate
		AND		fet_mprc >= paramDate
		AND		(tpr_mprc = qpr OR qpr IS NULL)
		ORDER BY tpr_mprc
		RETURN	tpr,
				pru,
				fei,
				fet,
				iva
		WITH RESUME;		
	END FOREACH;	
	
END PROCEDURE;	