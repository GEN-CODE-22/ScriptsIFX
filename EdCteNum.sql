CREATE PROCEDURE EdCteNum(
	paramCia char(2), 
	paramPla char(2),
	paramRazSoc char(70), 
	paramAp char(30),  
	paramNom char(20), 
	paramDir char(40), 
	paramCol char(40), 
	paramCiu char(30),
	paramCodPo char(6), 
	paramLada smallint, 
	paramTel integer, 
	paramExt char(5), 
	paramRFC char(15), 
	paramSecof char(8),
	paramUso char(2), 
	paramNvta char(1), 
	paramPitex char(1),
	paramCont char(20), 
	paramFechaCon date, 
	paramDesc decimal(8, 2),
	paramTip char(1), 
	paramDcred smallint, 
	paramReqFac char(1),
	paramreqCor char(1), 
	paramCor char(73), 
	paramStatus char(1),
	paramUsr char(8), 
	paramAli char(15), 
	paramGpo char(6), 
	paramConCre char(1), 
	paramLimCre decimal(10,2),
	paramLimNotc smallint, 
	paramLimCon decimal(12,2), 
	paramNcont char(1),
	paramNCte  CHAR(6))
RETURNING char(6);



	IF paramCont = 'N' THEN
		LET paramFechaCon = null;
	END IF;

	UPDATE	cliente
	SET		razsoc_cte = paramRazSoc,
			ape_cte = paramAp,
			nom_cte = paramNom,
			dir_cte = paramDir,
			col_cte = paramCol,
			ciu_cte = paramCiu,
			codpo_cte = paramCodPo,
			lada_cte = paramLada,
			tel_cte = paramTel,
			ext_cte = paramExt,
			rfc_cte = paramRFC,
			secof_cte = paramSecof,
			uso_cte = paramUso,
			nvta_cte = paramNvta,
			pitex_cte = paramPitex,
			contr_cte = paramCont,
			feccon_cte = paramFechaCon,
			descue_cte = paramDesc,
			tip_cte = paramTip,
			dcred_cte = paramDcred,
			reqfac_cte = paramReqFac,
			reqcor_cte = paramreqCor,
			corele_cte = paramCor,			
			status_cte = paramStatus,
			usr_cte = paramUsr,
			ali_cte = paramAli, 
			gpo_cte = paramGpo,
			concre_cte = paramConCre,
			limcre_cte = paramLimCre,
			limnotc_cte = paramLimNotc, 
			limcon_Cte = paramLimCon,
			ncont_cte = paramNcont
	WHERE	num_cte = paramNCte
	AND		cia_cte = paramCia
	AND		pla_cte = paramPla;


RETURN paramNCte;

END PROCEDURE;