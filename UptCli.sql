CREATE PROCEDURE UptCli
(
	paramCia		CHAR(2),
	paramPla   		CHAR(2),
	paramNumCte		CHAR(6),
	paramRazSoc		CHAR(70),	
	paramApe		CHAR(30),
	paramNom   		CHAR(20),
	paramDir		CHAR(40),
	paramCol		CHAR(40),
	paramCiu		CHAR(30),
	paramCP			CHAR(6),	
	paramLada		SMALLINT,
	paramTel		INT,	
	paramExt		CHAR(5),
	paramRFC		CHAR(15),
	paramCorreo		CHAR(73),
	paramAlias      CHAR(15),
	paramSecof		CHAR(8),
	paramStatus		CHAR(1),
	paramGpoFac		CHAR(6),
	paramUso		CHAR(2),
	paramNvta		CHAR(1),
	paramPitex		CHAR(1),
	paramCont		CHAR(20),
	paramFecCont	DATE,
	paramFirCont	CHAR(1),
	paramPagare		DECIMAL,
	paramDescto		DECIMAL,
	paramTipo		CHAR(1),
	paramDiasCre	SMALLINT,
	paramReqFac		CHAR(1),
	paramReqCe		CHAR(1),
	paramPago		CHAR(1),
	paramCuenta		CHAR(4),
	paramBanco		CHAR(3),
	paramMsg		CHAR(46),
	paramCtrlCre	CHAR(1),
	paramLimCre		DECIMAL,
	paramLimNvta	SMALLINT,
	paramNomR   	CHAR(30),
	paramApePR		CHAR(20),
	paramApeMR		CHAR(20),
	paramUsr		CHAR(8)
)
DEFINE vRespCom INT;

LET vRespCom = 0;

IF	paramSecof = 'S' THEN
	LET	paramSecof = 'COMODATO';
END IF;

IF	LENGTH(paramRazSoc) = 0 THEN
	LET	paramRazSoc = NULL;
END IF;

UPDATE	cliente
SET		razsoc_cte 	= paramRazSoc,
		ape_cte		= paramApe,
		nom_cte		= paramNom,
		dir_cte		= paramDir,
		col_cte		= paramCol,
		ciu_cte		= paramCiu,
		codpo_cte	= paramCP,
		lada_cte	= paramLada,
		tel_cte		= paramTel,
		ext_cte		= paramExt,
		rfc_cte		= paramRFC,
		corele_cte	= paramCorreo,
		ali_cte		= paramAlias,
		secof_cte	= paramSecof,
		status_cte	= paramStatus,
		gpo_cte		= paramGpoFac,
		uso_cte		= paramUso,
		nvta_cte	= paramNvta,
		pitex_cte	= paramPitex,
		contr_cte	= paramCont,
		feccon_cte	= paramFecCont,
		ncont_cte	= paramFirCont,
		limcon_cte	= paramPagare,
		descue_cte	= paramDescto,
		tip_cte		= paramTipo,
		dcred_cte	= paramDiasCre,
		reqfac_cte	= paramReqFac,
		reqcor_cte	= paramReqCe,
		pago_cte	= paramPago,
		cuenta_cte	= paramCuenta,
		banco_cte	= paramBanco,
		men_cte		= paramMsg,
		concre_cte	= paramCtrlCre,
		limcre_cte	= paramLimCre,
		limnotc_cte	= paramLimNvta,
		usr_cte 	= paramUsr,
		fecbaj_cte	= NULL
WHERE	cia_cte 	= paramCia
		AND pla_cte = paramPla
		AND num_cte = paramNumCte;

IF	paramStatus = 'B' THEN
	UPDATE	cliente
	SET		fecbaj_cte 	= TODAY
	WHERE	cia_cte 	= paramCia
			AND pla_cte = paramPla
			AND num_cte = paramNumCte;
END IF;

SELECT  COUNT(*)
INTO	vRespCom
FROM	cte_comodato
WHERE	numcte_ccom 	= paramNumCte;

IF	vRespCom = 0 THEN
	INSERT INTO cte_comodato
	VALUES(paramNumCte,paramNomR,paramApePR,paramApeMR);
ELSE
	UPDATE	cte_comodato
	SET		nomcte_ccom 	= paramNomR,
			apepcte_ccom 	= paramApePR,
			apemcte_ccom 	= paramApeMR
	WHERE	numcte_ccom 	= paramNumCte;
END IF;

END PROCEDURE;