CREATE PROCEDURE ConPPP
(
 paramCia      		CHAR(2),
 paramPla      		CHAR(2),
 paramRuta     		CHAR(4),
 paramFecha			DATE
)

RETURNING 
 CHAR(6), 
 CHAR(70), 
 CHAR(20), 
 CHAR(4),
 CHAR(25), 
 INT,
 CHAR(110),
 CHAR(15),
 INT,
 CHAR(1),
 CHAR(2),
 CHAR(3),
 CHAR(15);
 
DEFINE numcte CHAR(6);
DEFINE nomcte CHAR(70);
DEFINE telcte CHAR(15);
DEFINE rutped CHAR(4);
DEFINE fecsur CHAR(25);
DEFINE numtqe SMALLINT;
DEFINE dirtqe CHAR(110);
DEFINE edocte CHAR(15);
DEFINE dias   INT;
DEFINE tPago  CHAR(1);
DEFINE usocte CHAR(2);
DEFINE tprod  CHAR(3);
DEFINE rfc    CHAR(15);
DEFINE vsurvey_cfg CHAR(50);
DEFINE vtpdopro 	CHAR(1);
DEFINE vtpdosurvey	CHAR(1);
DEFINE vhayubica	CHAR(1);

LET	vtpdopro = 'P';
LET	vtpdosurvey = '';

SELECT	value_cfg
INTO	vsurvey_cfg
FROM	cfg_llam
WHERE	key_cfg = 'ACTIVESURVEY_CFG';

FOREACH cClientes FOR
	SELECT  cliente.num_cte,
			CASE 
			WHEN TRIM(cliente.razsoc_cte) <> '' THEN
			   TRIM(cliente.razsoc_cte) 
			ELSE 
			   CASE
				  WHEN cliente.ali_cte <> '' THEN
					 TRIM(cliente.ali_cte) || ', ' 
				  ELSE
					 '' 
			   END || trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
			END AS ncom_cte,
			'(' || cliente.lada_cte || ') ' || cliente.tel_cte as tel_cte,
			nota_vta.ruta_nvta,
			nota_vta.fes_nvta,
			tanque.numtqe_tqe,       
			TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,   
			"SURTIDO" edocte,        
			0 dias_llam,
			cliente.tip_cte,
			cliente.uso_cte,
			tanque.precio_tqe,
			cliente.rfc_cte
	INTO	numcte, 
			nomcte,
			telcte,
			rutped,
			fecsur,
			numtqe,
			dirtqe,
			edocte,
			dias,
			tPago,
			usocte,
			tprod,
			rfc
	FROM	cliente,
			nota_vta,
			tanque					
	WHERE	cliente.num_cte     		= tanque.numcte_tqe
			AND nota_vta.numtqe_nvta	= tanque.numtqe_tqe
			AND nota_vta.numcte_nvta	= cliente.num_cte
			AND nota_vta.cia_nvta   	= paramCia
			AND nota_vta.pla_nvta	    = paramPla
			AND nota_vta.ruta_nvta		= paramRuta
			AND nota_vta.fes_nvta 		<= paramFecha
			AND tanque.prg_tqe      	IN ('N','P')
			AND nota_vta.edo_nvta		= 'P'
			AND (nota_vta.tpdo_nvta 	IN(vtpdopro) OR nota_vta.tpdo_nvta IN (vtpdosurvey)   )
	ORDER BY 5 DESC
	RETURN 	numcte, 
			nomcte,  
			telcte,
			rutped,
			fecsur,
			numtqe,
			dirtqe,
			edocte,
			dias,
			tPago,
			usocte,
			tprod,
			rfc
	WITH RESUME;
END FOREACH;
END PROCEDURE; 