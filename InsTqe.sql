CREATE PROCEDURE InsTqe(
	paramCte 		CHAR(6), 
	paramCia 		CHAR(2),
	paramPla 		CHAR(2), 
	paramDir 		CHAR(40), 
	paramCol 		CHAR(40),
	paramCiu 		CHAR(30), 
	paramObserv 	CHAR(40), 
	paramPrg 		CHAR(1),
	paramCapa 		DECIMAL(10,2), 
	paramPorcLl 	DECIMAL(10,2),
	paramPorcVa 	DECIMAL(10,2), 
	paramComodato	CHAR(1),
	paraNoSerie		CHAR(20),
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
	paramPrecio 	CHAR(3),
	paramGps 		CHAR(30),
	paramFecCom 	DATE
)

DEFINE vnumtqe SMALLINT;
DEFINE vcantidad INT;

SELECT	NVL(MAX(numtqe_tqe),0)
INTO	vnumtqe
FROM	tanque
WHERE	numcte_tqe	= paramCte;

LET vnumtqe = vnumtqe + 1;

INSERT INTO tanque(
					numcte_tqe, 
					cia_tqe, 
					pla_tqe, 
					dir_tqe, 
					col_tqe,
				   	ciu_tqe, 
				   	observ_tqe, 
				   	prg_tqe, 
				   	numtqe_tqe, 
				   	capac_tqe, 
				   	porll_tqe, 
				   	porva_tqe, 
				   	comoda_tqe,
				   	numser_tqe,
				   	mesfab_tqe, 
				   	anofab_tqe, 
				   	ultcar_tqe, 
				   	diasca_tqe, 
				   	diasom_tqe, 
				   	proxca_tqe, 
				   	ruta_tqe, 
				   	conprm_tqe, 
				   	usr_tqe, 
				   	serv_tqe, 
				   	stat_tqe,
				   	fecbaj_tqe,
				   	usrbaj_tqe, 
				   	precio_tqe, 
				   	gps_tqe,
				   	feccom_tqe
				   )
VALUES			  (
					paramCte, 
					paramCia, 
					paramPla, 
					paramDir, 
					paramCol,
				   	paramCiu, 
				   	paramObserv, 
				   	paramPrg,
					vnumtqe, 
					paramCapa,
				   	paramPorcLl, 
				   	paramPorcVa, 
				   	paramComodato,
				   	paraNoSerie,
				   	paramMesfab, 
				   	paramAnoFab,
				   	paramUltcar, 
				   	paramDiasCa, 
				   	paramDiasom, 
				   	paramProxCa, 
				   	paramRuta, 
				   	paramConp, 
				   	paramUsr, 
				   	paramServ,
				   	paramStat,
				   	NULL,
				   	NULL,
				   	paramPrecio, 
				   	paramGps,
				   	paramFecCom
				   );
				   
SELECT	COUNT(*)
INTO	vcantidad
FROM	tanque
WHERE	numcte_tqe  = paramCte;

UPDATE	cliente
SET		ntanq_cte = vcantidad
WHERE	num_cte = paramCte;

END PROCEDURE;