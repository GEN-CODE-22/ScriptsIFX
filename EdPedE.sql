CREATE PROCEDURE EdPedE
(
	paramNumPed		INTEGER, 
	paramTipPed 	CHAR(1), 
	paramNumCte 	CHAR(6), 
	paramLada 		SMALLINT, 
	paramTel 		INTEGER, 
	paramNumTqe 	SMALLINT, 
	paramRuta 		CHAR(4), 
	paramObserv 	CHAR(40), 
	paramReqFac 	CHAR(1), 
	paramFecSur 	DATE, 
	paramEdoPed 	CHAR(1), 
	paramUsrPed 	CHAR(8), 
	paramEdoTx  	CHAR(1), 
	paramNumModif	SMALLINT, 
	paramNumTx 		SMALLINT
)
RETURNING INTEGER;

DEFINE fechaHoraPedido DATETIME YEAR TO MINUTE;

SELECT	DBINFO('utc_to_datetime',sh_curtime)
INTO 	fechaHoraPedido
FROM 	sysmaster:'informix'.sysshmvals;

UPDATE 	pedidos 
SET 	fhr_ped = fechaHoraPedido ,
		tipo_ped = paramTipPed    ,
		numcte_ped = paramNumCte  ,
		lada_ped = paramLada  	 ,
		tel_ped = paramTel		 ,
		numtqe_ped = paramNumTqe  ,
		ruta_ped = paramRuta      ,
		observ_ped = paramObserv  ,
		rfa_ped = paramReqFac     ,
		fecsur_ped = paramFecSur  ,
		edo_ped = paramEdoPed     ,
		usr_ped = paramUsrPed     ,
		edotx_ped = paramEdoTx    ,
		nmod_ped = paramNumModif  ,
		nmtx_ped = paramNumTx
WHERE 	num_ped = paramNumPed;

RETURN 1;
END PROCEDURE;                                                      