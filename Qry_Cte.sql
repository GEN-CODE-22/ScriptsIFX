CREATE PROCEDURE Qry_Cte
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
	paramFechaInicial	DATE,
	paramFechaFinal		DATE
)

RETURNING 
 CHAR(6), 
 CHAR(70), 
 CHAR(20), 
 CHAR(110);
 
 --VARIABLES LOCALES--
DEFINE numcte CHAR(6);
DEFINE nomcte CHAR(70);
DEFINE telcte CHAR(15);
DEFINE dircte CHAR(110);

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
			TRIM(cliente.dir_cte) || ' ' || TRIM(cliente.col_cte) || ' ' || TRIM(cliente.ciu_cte) AS dir_cte	
	INTO	numcte, 
			nomcte, 
			telcte,
			dircte			
	FROM	cliente
	WHERE	cliente.cia_cte   				= paramCia
			AND cliente.pla_cte				= paramPla             
			AND (LENGTH(paramNumCte) 		= 0 	OR cliente.num_cte 		= paramNumCte)
			AND (paramTel 					= 0 	OR cliente.tel_cte 		= paramTel)
			AND (LENGTH(paramAlias) 		= 0 	OR cliente.ali_cte 		LIKE paramAlias)
			AND (LENGTH(paramRazonSocial) 	= 0 	OR cliente.razsoc_cte 	LIKE paramRazonSocial)
			AND (LENGTH(paramRfc) 			= 0 	OR cliente.rfc_cte 		LIKE paramRfc)
			AND (LENGTH(paramNombre) 		= 0 	OR cliente.nom_cte 		LIKE paramNombre)
			AND (LENGTH(paramApePat) 		= 0 	OR cliente.ape_cte 		LIKE paramApePat)
			AND (LENGTH(paramCalle) 		= 0 	OR cliente.dir_cte 		LIKE paramCalle)
			AND (paramFechaInicial    IS NULL   	OR cliente.fecalt_cte 	>= paramFechaInicial)
			AND (paramFechaFinal	  IS NULL       OR cliente.fecalt_cte 	<= paramFechaFinal)	
	RETURN 	numcte, 
			nomcte, 
			telcte,
			dircte	
	WITH RESUME;
	END FOREACH;     
END PROCEDURE; 