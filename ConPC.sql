CREATE PROCEDURE ConPC
(
	paramCia   	CHAR(2),
	paramPla   	CHAR(2),
	paramUsr	CHAR(8)
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
 
 --VARIABLES LOCALES--
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
			cte_histped.ruta_histped,
			TO_CHAR(cte_histped.fus_histped, '%d-%m-%Y %H:%M') as Fecha,
			tanque.numtqe_tqe,          
			TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,
			CASE
				WHEN prog_llam.edo_llam = 'A' THEN
				   'POSPUESTO'
				WHEN prog_llam.edo_llam = 'X' THEN
				   'SUSPENDIDO'
				WHEN prog_llam.edo_llam = 'C' THEN
				   'POR CONFIRMAR'
				WHEN prog_llam.edo_llam = 'S' THEN
				   'SURTIDO'
				WHEN prog_llam.edo_llam = 'P' THEN
				   'PENDIENTE'
				ELSE
				   'ABIERTO'
			END AS edocte,
			NVL(prog_llam.dias_llam, 0) AS dias_llam,
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
			prog_llam,
			cte_histped,
			tanque	
	WHERE	cliente.num_cte 				= prog_llam.numcte_llam
			AND cliente.num_cte      		= cte_histped.cte_histped
			AND cliente.num_cte      		= tanque.numcte_tqe
			AND cte_histped.tqe_histped		= tanque.numtqe_tqe
			AND cliente.tel_cte				IS NOT NULL
			AND cte_histped.cia_histped     = paramCia
			AND prog_llam.usr_llam		    = paramUsr
			AND prog_llam.edo_llam 		   IN ('C','P','S')
			AND prog_llam.fhpr_llam 	   <= CURRENT
			AND tanque.prg_tqe      		IN ('N','P')
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
		    tanque.ruta_tqe,
	        TO_CHAR(prog_llam.fhpr_llam, '%d-%m-%Y %H:%M') as Fecha,
	        tanque.numtqe_tqe,          
	        TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,
	        CASE
	        	WHEN prog_llam.edo_llam = 'A' THEN
		           'POSPUESTO'
		        WHEN prog_llam.edo_llam = 'X' THEN
		           'SUSPENDIDO'
		        WHEN prog_llam.edo_llam = 'C' THEN
		           'POR CONFIRMAR'
		        WHEN prog_llam.edo_llam = 'S' THEN
		           'SURTIDO'
		        WHEN prog_llam.edo_llam = 'P' THEN
		           'PENDIENTE'
		        ELSE
		           'ABIERTO'
	        END AS edocte ,
	        NVL(prog_llam.dias_llam, 0) AS dias_llam,
	        cliente.tip_cte,
	        cliente.uso_cte,
	        tanque.precio_tqe,
	        cliente.rfc_cte        
	FROM	cliente,
			prog_llam,		
			tanque	
	WHERE	cliente.num_cte 				= prog_llam.numcte_llam
			AND cliente.num_cte      		= tanque.numcte_tqe
			AND (cliente.tel_cte			IS NOT NULL OR cliente.tel_cte = 0)
			AND cliente.cia_cte     		= paramCia
	        AND prog_llam.usr_llam		    = paramUsr
			AND prog_llam.edo_llam 		   IN ('C','P','S')
	        AND prog_llam.fhpr_llam 	   <= CURRENT
	        AND tanque.prg_tqe      		IN ('N','P')
	        AND	cliente.num_cte				NOT IN(SELECT cte_histped FROM cte_histped)
	ORDER BY 4
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