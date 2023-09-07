CREATE PROCEDURE ConCN
(
	paramCia      		CHAR(2),
	paramPla      		CHAR(2),
	paramNumCte   		CHAR(6),
	paramTel			INT,
	paramAlias   		CHAR(15),
	paramRazonSocial	CHAR(70),
	paramRfc   			CHAR(15),
	paramNombre   		CHAR(20),
	paramApePat   		CHAR(30),
	paramCalle			CHAR(40),
	paramCol			CHAR(30),
	paramFechaInicial	DATE,
	paramFechaFinal		DATE	
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

IF LENGTH(paramNumCte) > 0 THEN
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
			TO_CHAR(nota_vta.fes_nvta, '%d-%m-%Y %H:%M') as Fecha,
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
	WHERE	cliente.num_cte      			= tanque.numcte_tqe
			AND nota_vta.numtqe_nvta		= tanque.numtqe_tqe
			AND nota_vta.numcte_nvta		= cliente.num_cte
			AND nota_vta.edo_nvta			IN('A','S')
			AND tanque.prg_tqe      		IN ('N','P')
			AND cliente.tel_cte				IS NOT NULL
			AND nota_vta.cia_nvta   		= paramCia
			AND nota_vta.pla_nvta			= paramPla             
			AND cliente.num_cte 			= paramNumCte	
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
			TO_CHAR(rdnota_vta.fes_nvta, '%d-%m-%Y %H:%M') as Fecha,
			tanque.numtqe_tqe,          
			TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,
			"SURTIDO" edocte,        
			0 dias_llam,			
			cliente.tip_cte,
			cliente.uso_cte,
			tanque.precio_tqe,
			cliente.rfc_cte
	FROM	cliente,		
			rdnota_vta,
			tanque	
	WHERE	cliente.num_cte      			= tanque.numcte_tqe
			AND rdnota_vta.numtqe_nvta		= tanque.numtqe_tqe
			AND rdnota_vta.numcte_nvta		= cliente.num_cte
			AND rdnota_vta.edo_nvta			IN('A','S')
			AND tanque.prg_tqe      		IN ('N','P')
			AND cliente.tel_cte				IS NOT NULL
			AND rdnota_vta.cia_nvta   		= paramCia
			AND rdnota_vta.pla_nvta			= paramPla             
			AND cliente.num_cte 			= paramNumCte	
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
ELSE

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
			TO_CHAR(nota_vta.fes_nvta, '%d-%m-%Y %H:%M') as Fecha,
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
	WHERE	cliente.num_cte      			= tanque.numcte_tqe
			AND nota_vta.numtqe_nvta		= tanque.numtqe_tqe
			AND nota_vta.numcte_nvta		= cliente.num_cte
			AND nota_vta.edo_nvta			IN('A','S')
			AND tanque.prg_tqe      		IN ('N','P')
			AND cliente.tel_cte				IS NOT NULL
			AND nota_vta.cia_nvta   		= paramCia
			AND nota_vta.pla_nvta			= paramPla             
			AND (paramTel 					= 0 	OR cliente.tel_cte 		= paramTel)
			AND (LENGTH(paramAlias) 		= 0 	OR cliente.ali_cte 		LIKE paramAlias)
			AND (LENGTH(paramRazonSocial) 	= 0 	OR cliente.razsoc_cte 	LIKE paramRazonSocial)
			AND (LENGTH(paramRfc) 			= 0 	OR cliente.rfc_cte 		LIKE paramRfc)
			AND (LENGTH(paramNombre) 		= 0 	OR cliente.nom_cte 		LIKE paramNombre)
			AND (LENGTH(paramApePat) 		= 0 	OR cliente.ape_cte 		LIKE paramApePat)
			AND (LENGTH(paramCalle) 		= 0 	OR tanque.dir_tqe 		LIKE paramCalle)
			AND (LENGTH(paramCol) 			= 0 	OR tanque.col_tqe 		LIKE paramCol)
			AND (paramFechaInicial    IS NULL   	OR cliente.fecalt_cte 	>= paramFechaInicial)
			AND (paramFechaFinal	  IS NULL       OR cliente.fecalt_cte 	<= paramFechaFinal)
			AND cliente.num_cte			NOT IN(SELECT numcte_llam	FROM prog_llam)
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
			TO_CHAR(rdnota_vta.fes_nvta, '%d-%m-%Y %H:%M') as Fecha,
			tanque.numtqe_tqe,          
			TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,
			"SURTIDO" edocte,        
			0 dias_llam,
			cliente.tip_cte,
			cliente.uso_cte,
			tanque.precio_tqe,
			cliente.rfc_cte
	FROM	cliente,		
			rdnota_vta,
			tanque	
	WHERE	cliente.num_cte      			= tanque.numcte_tqe
			AND rdnota_vta.numtqe_nvta		= tanque.numtqe_tqe
			AND rdnota_vta.numcte_nvta		= cliente.num_cte
			AND rdnota_vta.edo_nvta			IN('A','S')
			AND tanque.prg_tqe      		IN ('N','P')
			AND cliente.tel_cte				IS NOT NULL
			AND rdnota_vta.cia_nvta   		= paramCia
			AND rdnota_vta.pla_nvta			= paramPla             
			AND (paramTel 					= 0 	OR cliente.tel_cte 		= paramTel)
			AND (LENGTH(paramAlias) 		= 0 	OR cliente.ali_cte 		LIKE paramAlias)
			AND (LENGTH(paramRazonSocial) 	= 0 	OR cliente.razsoc_cte 	LIKE paramRazonSocial)
			AND (LENGTH(paramRfc) 			= 0 	OR cliente.rfc_cte 		LIKE paramRfc)
			AND (LENGTH(paramNombre) 		= 0 	OR cliente.nom_cte 		LIKE paramNombre)
			AND (LENGTH(paramApePat) 		= 0 	OR cliente.ape_cte 		LIKE paramApePat)
			AND (LENGTH(paramCalle) 		= 0 	OR tanque.dir_tqe 		LIKE paramCalle)
			AND (LENGTH(paramCol) 			= 0 	OR tanque.col_tqe 		LIKE paramCol)
			AND (paramFechaInicial    IS NULL   	OR cliente.fecalt_cte 	>= paramFechaInicial)
			AND (paramFechaFinal	  IS NULL       OR cliente.fecalt_cte 	<= paramFechaFinal)		
			AND cliente.num_cte			NOT IN(SELECT numcte_llam	FROM prog_llam) 
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
END IF;   
END PROCEDURE;