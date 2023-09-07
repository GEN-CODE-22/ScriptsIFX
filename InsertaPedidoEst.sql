CREATE PROCEDURE InsertaPedidoEst
(
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
	paramEdoTx 		CHAR(1), 
	paramNumModif 	SMALLINT, 
	paramNumTx 		SMALLINT, 
	paramTpdo 		CHAR(1)
)
RETURNING INTEGER;

DEFINE vpedidoExistente INT;
DEFINE numeroPedido INTEGER;
DEFINE fechaHoraPedido DATETIME YEAR TO MINUTE;

SELECT	COUNT(*)
INTO	vpedidoExistente
FROM	pedidos
WHERE	numcte_ped 		= paramNumCte
		AND numtqe_ped 	= paramNumTqe 
		AND edo_ped IN('p','P');
		


IF vpedidoExistente = 0 THEN
	LOCK TABLE datos IN EXCLUSIVE MODE;
	
	SELECT	numped_dat 
	INTO 	numeroPedido
	FROM 	datos;
	
	LET numeroPedido = numeroPedido + 1;
	
	UPDATE	datos
	SET 	numped_dat = numeroPedido;
	
	UNLOCK TABLE datos;
	
	SELECT	DBINFO('utc_to_datetime',sh_curtime)
	INTO 	fechaHoraPedido
	FROM 	sysmaster:'informix'.sysshmvals;
	
	INSERT INTO pedidos(
						num_ped, 
						fhr_ped, 
						tipo_ped, 
						numcte_ped, 
				        lada_ped, 
						tel_ped, 
						numtqe_ped, 
						ruta_ped,
						observ_ped, 
						rfa_ped, 
						fecsur_ped, 
						edo_ped,
						usr_ped, 
						edotx_ped, 
						nmod_ped, 
						fhrp_ped,
						usrrp_ped, 
						nmtx_ped, 
						tpdo_ped
						)
	VALUES			  (
						numeroPedido, 
						fechaHoraPedido, 
						paramTipPed,
						paramNumCte, 
						paramLada, 
						paramTel, 
						paramNumTqe, 
						paramRuta, 
						paramObserv,
						paramReqFac, 
						paramFecSur, 
						paramEdoPed, 
						paramUsrPed, 
						paramEdoTx, 
						paramNumModif,
						fechaHoraPedido, 
						paramUsrPed, 
						paramNumTx, 
						paramTpdo
						);
	
	RETURN numeroPedido;
ELSE
	LET vpedidoExistente = -1;
	RETURN vpedidoExistente;
END IF;

END PROCEDURE; 