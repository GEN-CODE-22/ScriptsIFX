DROP PROCEDURE FreeNoteInLiq;
CREATE PROCEDURE FreeNoteInLiq(

	paramFolio	INTEGER,
	paramFolEnr CHAR(12),
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramTqe	INTEGER,
	paramFliq	INTEGER,
	paramLts	DECIMAL,
	paramEco    CHAR(7),
	paramFecate CHAR(8)
	)
	RETURNING
		CHAR(1);				
		
			
	DEFINE control	CHAR(1);			
	
	DEFINE golpe 		INTEGER; 		
	DEFINE vnumped		INT;			
	DEFINE vruta		CHAR(4);		
	DEFINE vcountrenr	INT;			
	DEFINE vfolc		CHAR(12);		
	DEFINE vcountfolp	INT;			
	DEFINE vfact		INT;			
	
	LET control = '';
	LET vnumped = 0;	
	LET vfolc 	= '';
	LET vfact 	= 0;
	
	SELECT  COUNT(*)
	INTO	vfact
	FROM	nota_vta
	WHERE	fol_nvta 		= paramFolio
		  	AND	cia_nvta 	= paramCia
		  	AND	pla_nvta 	= paramPla
		  	AND	fac_nvta 	IS NOT NULL  AND fac_nvta > 0;
		  	
	IF vfact = 0 THEN	
		SELECT	COUNT(*)
		INTO	vcountrenr
		FROM	ref_enr
		WHERE	folp_menr = paramFolEnr;
		
		IF vcountrenr > 0  THEN
			SELECT	folc_menr
			INTO	vfolc
			FROM	ref_enr
			WHERE	folp_menr = paramFolEnr;
		END IF;
		
		SELECT	COUNT(*)
		INTO	vcountfolp
		FROM	enruta
		WHERE	fol_enr = paramFolEnr;

		DELETE
		FROM	changes_liq
		WHERE	cia_cliq 		= paramCia
				AND pla_cliq 	= paramPla
				AND liq_cliq	= paramFliq
				AND nvta_cliq	= paramFolio;

		IF EXISTS(SELECT 1 FROM enruta WHERE fol_enr = paramFolEnr /*AND numcte_enr = paramCte */
					AND edoreg_enr = 'F' AND edovta_enr IN ('f','l')) AND vcountrenr = 0 THEN
				SELECT  ped_nvta
				INTO	vnumped
				FROM	nota_vta
				WHERE	fol_nvta = paramFolio
						AND	cia_nvta = paramCia
						AND	pla_nvta = paramPla
						AND	fliq_nvta = paramFliq;
									
				UPDATE	pedidos
				SET		edo_ped = 'p',
			  			fecrsur_ped = null,
			  			horrsur_ped = null,
			  			usrcan_ped = null	  			
			  	WHERE	num_ped = vnumped;

			  UPDATE	nota_vta
			  SET		edo_nvta = 'P', 	
						fliq_nvta = null, 
						tlts_nvta = null, 	
						pru_nvta = null,	
						simp_nvta = null,	
						iva_nvta = null,	
						ivap_nvta = null, 	
						impt_nvta = null	
			  WHERE		fol_nvta = paramFolio
			  AND		cia_nvta = paramCia
			  AND		pla_nvta = paramPla
			  AND		fliq_nvta = paramFliq;
			  
			  UPDATE	enruta
			  SET		edovta_enr 	= '0'
			  WHERE		fol_enr = paramFolEnr;
			  
			  LET control = 'A';
			  
		END IF;
		

		IF EXISTS(SELECT 1 FROM enruta WHERE fol_enr = vfolc 
					AND edoreg_enr = 'N' AND edovta_enr IN ('f','l')) AND vcountfolp = 0 THEN

			  UPDATE	nota_vta
			  SET		edo_nvta = 'P', 	
						fliq_nvta = null, 	
						tlts_nvta = null, 	
						pru_nvta = null,	
						simp_nvta = null,	
						iva_nvta = null,	
						ivap_nvta = null, 	
						impt_nvta = null,	
						numcte_nvta = null, 
						numtqe_nvta = null  
			  WHERE		fol_nvta = paramFolio
			  AND		cia_nvta = paramCia
			  AND		pla_nvta = paramPla
			  AND		fliq_nvta = paramFliq;
			  
			  UPDATE	enruta
			  SET		edovta_enr 	= NULL
			  WHERE		fol_enr 	= vfolc;
			  
			  DELETE
			  FROM	ref_enr
			  WHERE folp_menr = paramCia || paramPla || LPAD(paramFolio,6,'0');
			  
			  LET control = 'A';
			  
		END IF;	
		
		IF EXISTS(SELECT 1 FROM enruta WHERE fol_enr = paramFolEnr AND numcte_enr = paramCte 
					AND edoreg_enr = 'F' AND edovta_enr IN ('f','l')) AND vcountfolp > 0 THEN
				
				SELECT  ped_nvta
				INTO	vnumped
				FROM	nota_vta
				WHERE	fol_nvta = paramFolio
						AND	cia_nvta = paramCia
						AND	pla_nvta = paramPla
						AND	fliq_nvta = paramFliq;	
						
				SELECT	ruta_ped
				INTO	vruta
				FROM	pedidos
				WHERE	num_ped = vnumped;
				
				UPDATE	pedidos
				SET		edo_ped = 'p',
			  			fecrsur_ped = null,
			  			horrsur_ped = null,
			  			usrcan_ped = null	  			
			  	WHERE	num_ped = vnumped;
		  
			   UPDATE	enruta
			  SET		edovta_enr 	= '0',
			  			edoreg_enr 	= '0',
			  			ruta_enr	= vruta
			  WHERE		fol_enr 	= paramFolEnr;
			  
			  UPDATE	enruta
			  SET		edovta_enr 	= NULL
			  WHERE		fol_enr 	= vfolc;
			  
			  UPDATE	nota_vta
			  SET		edo_nvta 	= 'P', 	
						fliq_nvta 	= null, 
						tlts_nvta 	= null, 
						pru_nvta 	= null,	
						simp_nvta 	= null,	
						iva_nvta 	= null,
						ivap_nvta 	= null, 
						impt_nvta 	= null,	
						ruta_nvta	= vruta
			  WHERE		fol_nvta 	= paramFolio
			  			AND	cia_nvta = paramCia
						AND	pla_nvta = paramPla
						AND	fliq_nvta = paramFliq;	
			  DELETE
			  FROM	ref_enr
			  WHERE folp_menr = paramCia || paramPla || LPAD(paramFolio,6,'0');
						
				LET control = 'A';	  
		END IF;
		
		IF vcountrenr = 0 AND vcountfolp = 0 THEN
			  UPDATE	nota_vta
			  SET		edo_nvta = 'P', 	
						fliq_nvta = null, 	
						tlts_nvta = null, 	
						pru_nvta = null,	
						simp_nvta = null,	
						iva_nvta = null,	
						ivap_nvta = null, 
						impt_nvta = null,	
						numcte_nvta = null,
						numtqe_nvta = null  
			  WHERE		fol_nvta = paramFolio
			  AND		cia_nvta = paramCia
			  AND		pla_nvta = paramPla
			  AND		fliq_nvta = paramFliq;
			LET control = 'A';	 
		END IF;	
		EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,paramCte,paramTqe);
	ELSE
		LET control = 'E';	 
	END IF;
	RETURN	control;

END PROCEDURE;	