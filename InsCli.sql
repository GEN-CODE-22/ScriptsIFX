CREATE PROCEDURE InsCli
(
	paramCia		CHAR(2),
	paramPla   		CHAR(2),
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
RETURNING CHAR(6);

DEFINE vNumCte CHAR(6);

DEFINE vNumCteI INTEGER;

LOCK TABLE datos IN EXCLUSIVE MODE;
SELECT 	numcte_dat 
INTO 	vNumCteI
FROM 	datos;

UPDATE 	datos
SET 	numcte_dat = (vNumCteI + 1);
UNLOCK TABLE datos;

LET vNumCte = LPAD(vNumCteI, 6, '0');


IF	paramSecof = 'S' THEN
	LET	paramSecof = 'COMODATO';
END IF;

IF paramCont = 'N' THEN
	LET paramFecCont = null;
END IF;

IF	LENGTH(paramRazSoc) = 0 THEN
	LET	paramRazSoc = NULL;
END IF;

INSERT INTO	cliente(cia_cte,
					pla_cte,
					num_cte,
					razsoc_cte,
					ape_cte,
					nom_cte,
					dir_cte,
					col_cte,
					ciu_cte,
					codpo_cte,
					lada_cte,
					tel_cte,
					ext_cte,
					rfc_cte,
					corele_cte,
					ali_cte,
					secof_cte,
					status_cte,
					gpo_cte,
					uso_cte,
					nvta_cte,
					pitex_cte,
					contr_cte,
					feccon_cte,
					ncont_cte,
					limcon_cte,
					descue_cte,
					tip_cte,
					dcred_cte,
					reqfac_cte,
					reqcor_cte,
					pago_cte,
					cuenta_cte,
					banco_cte,
					men_cte,
					concre_cte,
					limcre_cte,
					limnotc_cte,
					fecalt_cte,
					usr_cte)
VALUES( paramCia,
		paramPla,
		vNumCte,
		paramRazSoc,
		paramApe,
		paramNom,
		paramDir,
		paramCol,
		paramCiu,
		paramCP,
		paramLada,
		paramTel,
		paramExt,
		paramRFC,
		paramCorreo,
		paramAlias,
		paramSecof,
		paramStatus,
		paramGpoFac,
		paramUso,
		paramNvta,
		paramPitex,
		paramCont,
		paramFecCont,
		paramFirCont,
		paramPagare,
		paramDescto,
		paramTipo,
		paramDiasCre,
		paramReqFac,
		paramReqCe,
		paramPago,
		paramCuenta,
		paramBanco,
		paramMsg,
		paramCtrlCre,
		paramLimCre,
		paramLimNvta,
		TODAY,
		paramUsr
);

INSERT INTO cte_comodato
VALUES(vNumCte,paramNomR,paramApePR,paramApeMR);

RETURN vNumCte;

END PROCEDURE; 