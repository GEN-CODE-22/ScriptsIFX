CREATE PROCEDURE UpPaymntSaleNote(
	paramFolio	INTEGER,	
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramTqe	INTEGER,
	paramFliq	INTEGER,
	paramTpa	CHAR(1),
	paramTip	CHAR(1),
	paramTprd   CHAR(3),
	paramPrice  DECIMAL,
	paramUsr	CHAR(8)
	)

	RETURNING
		CHAR(1);		
		
			
	DEFINE control		CHAR(1);		
	DEFINE vtpa_nvta	CHAR(1);
	DEFINE vtpr_prc		CHAR(3);
	DEFINE vfes_nvta	DATE;
	DEFINE vtlts_nvta	DECIMAL;
	DEFINE vsimpt_nvta	DECIMAL;
	DEFINE viva_nvta	DECIMAL;
	DEFINE vpru_mprc	DECIMAL;
	DEFINE viva_mprc	DECIMAL;
	DEFINE vobserlog	CHAR(100);
		
	IF EXISTS(SELECT 1 FROM nota_vta WHERE fol_nvta = paramFolio AND cia_nvta = paramCia AND pla_nvta = paramPla AND fliq_nvta = paramFliq AND numcte_nvta = paramCte AND numtqe_nvta = paramTqe) THEN
	
		SELECT  tpa_nvta,
				fes_nvta,
				tlts_nvta
		INTO	vtpa_nvta,
				vfes_nvta,
				vtlts_nvta
		FROM	nota_vta
		WHERE 	fol_nvta 		= paramFolio 
			  	AND cia_nvta 	= paramCia 
			  	AND pla_nvta 	= paramPla 
			  	AND fliq_nvta 	= paramFliq 
			  	AND numcte_nvta = paramCte 
			  	AND numtqe_nvta = paramTqe;
			  	
		
		SELECT	NVL(pru_mprc,0), 
				NVL(iva_mprc,0)
		INTO	vpru_mprc, 
				viva_mprc
		FROM	mov_prc
		WHERE	tpr_mprc = paramTprd
		AND 	fei_mprc <= vfes_nvta
		AND 	fet_mprc >= vfes_nvta;
	
		LET vsimpt_nvta = (paramPrice * vtlts_nvta) / ((viva_mprc / 100) + 1) ;
		LET viva_nvta 	= (paramPrice * vtlts_nvta) - vsimpt_nvta;
		UPDATE	nota_vta
		SET		tip_nvta	= paramTip,
				tpa_nvta 	= paramTpa,
				tprd_nvta	= paramTprd,
				pru_nvta	= paramPrice,					
				impt_nvta	= vsimpt_nvta + viva_nvta,
				simp_nvta	= vsimpt_nvta,
				iva_nvta	= viva_nvta
		WHERE	fol_nvta 		= paramFolio
				AND	cia_nvta 	= paramCia
				AND	pla_nvta 	= paramPla
				AND	numcte_nvta = paramCte		
				AND	numtqe_nvta = paramTqe
				AND	fliq_nvta 	= paramFliq;

		LET vobserlog = 'CAMBIO TIPO DE PAGO EN NOTA DE VENTA TIPO PAGO ORIGINAL[' || vtpa_nvta || '] TIPO DE PAGO NUEVO[' || paramTpa || ']';
		EXECUTE PROCEDURE InsChangeLiq(paramCia,paramPla,paramFolio,paramUsr,vobserlog);
		
		LET control = 'A';
		
	ELSE	
		LET control = 'N'; 
	END IF;	
	
	RETURN	control;

END PROCEDURE;	