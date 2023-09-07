CREATE PROCEDURE UptTqe
(	
	paramCte 		CHAR(6), 
	paramCia 		CHAR(2),
	paramPla 		CHAR(2), 
	paramDir 		CHAR(40), 
	paramCol 		CHAR(40),
	paramCiu 		CHAR(30), 
	paramObserv 	CHAR(40), 
	paramPrg 		CHAR(1),
	paramNumtqe		SMALLINT,
	paramCapa 		DECIMAL(10,2), 
	paramPorcLl 	DECIMAL(10,2),
	paramPorcVa 	DECIMAL(10,2), 
	paramComodato	CHAR(1),
	paramNoSerie	CHAR(20),
	paramMesfab 	SMALLINT, 
	paramAnoFab 	SMALLINT,
	paramUltcar 	DATE, 
	paramDiasCa 	SMALLINT, 
	paramDiasom 	SMALLINT, 
	paramProxCa 	DATE, 
	paramRuta 		CHAR(4), 
	paramConp 		DECIMAL(10,2),
	paramUsr 		CHAR(8), 
	paramServ 		CHAR(1), 
	paramStat 		CHAR(1),
	paramUsrBaj 	CHAR(8), 
	paramPrecio 	CHAR(3),
	paramGps 		CHAR(30),
	paramFecCom 	DATE
)
DEFINE vcantidad INT;

UPDATE	tanque
SET		dir_tqe		= paramDir,
		col_tqe		= paramCol,
		ciu_tqe		= paramCiu,
		observ_tqe	= paramObserv,
		prg_tqe	    = paramPrg,
		capac_tqe	= paramCapa,
		porll_tqe	= paramPorcLl,
		porva_tqe	= paramPorcVa,
		comoda_tqe	= paramComodato,
		numser_tqe	= paramNoSerie,
		mesfab_tqe	= paramMesFab,
		anofab_tqe	= paramAnoFab,
		ultcar_tqe	= paramUltcar,
		diasca_tqe	= paramDiasCa,
		diasom_tqe	= paramDiasom,
		proxca_tqe	= paramProxCa,		
		ruta_tqe	= paramRuta,
		conprm_tqe	= paramConp,
		usr_tqe		= paramUsr,
		serv_tqe	= paramServ,
		stat_tqe	= paramStat,
		fecbaj_tqe	= NULL,
		usrbaj_tqe	= NULL,
		precio_tqe	= paramPrecio,
		gps_tqe		= paramGps,
		feccom_tqe	= paramFecCom,
		cia_tqe 	= paramCia,
		pla_tqe		= paramPla
WHERE	numcte_tqe		= paramCte
		AND numtqe_tqe 	= paramNumTqe;
		
IF	paramStat = 'B' THEN
	UPDATE	tanque
	SET		fecbaj_tqe	= TODAY,
			usrbaj_tqe	= paramUsrBaj
	WHERE	numcte_tqe		= paramCte
			AND cia_tqe 	= paramCia
			AND	pla_tqe		= paramPla
			AND numtqe_tqe 	= paramNumTqe;
END IF;

SELECT	COUNT(*)
INTO	vcantidad
FROM	tanque
WHERE	numcte_tqe  = paramCte;

UPDATE	cliente
SET		ntanq_cte = vcantidad
WHERE	num_cte = paramCte;

END PROCEDURE; 

