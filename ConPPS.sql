CREATE PROCEDURE ConPPS
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
 DATE, 
 DECIMAL,
 INT, 
 CHAR(110);
 
DEFINE vnumcte CHAR(6);
DEFINE vnomcte CHAR(70);
DEFINE vtelcte CHAR(25);
DEFINE vrutped CHAR(4);
DEFINE vfecsur CHAR(25);
DEFINE vltssur DECIMAL;
DEFINE vnumtqe INT;
DEFINE vdirtqe CHAR(110);
DEFINE vsurvey_cfg CHAR(50);
DEFINE vtpdopro 	CHAR(1);
DEFINE vtpdosurvey	CHAR(1);

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
			enruta.ltssur_enr,
			tanque.numtqe_tqe,          
			TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe
	INTO	vnumcte, 
			vnomcte,
			vtelcte,
			vrutped,
			vfecsur,
			vltssur,
			vnumtqe,
			vdirtqe
	FROM	cliente,
			nota_vta,
			tanque,
			enruta	
	WHERE	cliente.num_cte     		= tanque.numcte_tqe
			AND nota_vta.numtqe_nvta	= tanque.numtqe_tqe
			AND nota_vta.numcte_nvta	= cliente.num_cte
			AND nota_vta.cia_nvta   	= paramCia
			AND nota_vta.pla_nvta	    = paramPla
			AND nota_vta.ruta_nvta		= paramRuta
			AND nota_vta.fes_nvta 		= paramFecha
			AND tanque.prg_tqe      	IN ('N','P')  
			AND (nota_vta.tpdo_nvta 	IN(vtpdopro) OR nota_vta.tpdo_nvta IN (vtpdosurvey))
			AND nota_vta.cia_nvta || nota_vta.pla_nvta || LPAD(nota_vta.fol_nvta,6,'0') = enruta.fol_enr	
			AND enruta.edoreg_enr		= 'F'
	UNION
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
			rdnota_vta.ruta_nvta,
			rdnota_vta.fes_nvta,
			enruta.ltssur_enr,
			tanque.numtqe_tqe,          
			TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe
	FROM	cliente,
			rdnota_vta,
			tanque,
			enruta	
	WHERE	cliente.num_cte     		= tanque.numcte_tqe
			AND rdnota_vta.numtqe_nvta	= tanque.numtqe_tqe
			AND rdnota_vta.numcte_nvta	= cliente.num_cte
			AND rdnota_vta.cia_nvta   	= paramCia
			AND rdnota_vta.pla_nvta	    = paramPla
			AND rdnota_vta.ruta_nvta	= paramRuta
			AND rdnota_vta.fes_nvta 	= paramFecha
			AND tanque.prg_tqe      	IN ('N','P')  
			AND (rdnota_vta.tpdo_nvta 	IN(vtpdopro) OR rdnota_vta.tpdo_nvta IN (vtpdosurvey))
			AND rdnota_vta.cia_nvta || rdnota_vta.pla_nvta || LPAD(rdnota_vta.fol_nvta,6,'0') = enruta.fol_enr	
			AND enruta.edoreg_enr		= 'F'
	RETURN 	vnumcte, 
			vnomcte,
			vtelcte,
			vrutped,
			vfecsur,
			vltssur,
			vnumtqe,
			vdirtqe
	WITH RESUME;
END FOREACH;
END PROCEDURE;