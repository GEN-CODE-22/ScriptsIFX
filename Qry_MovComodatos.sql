CREATE PROCEDURE Qry_MovComodatos
( 
	paramCia   		CHAR(2),
	paramPla   		CHAR(2),
	paramFechaI		DATETIME YEAR TO MINUTE,	
	paramFechaF   	DATETIME YEAR TO MINUTE
)
RETURNING 
 DATETIME YEAR TO MINUTE, 
 CHAR(70), 
 CHAR(110), 
 INT,
 CHAR(6), 
 DECIMAL,
 DATE,
 DECIMAL,
 CHAR(200);

DEFINE vfecmov	DATETIME YEAR TO MINUTE;
DEFINE vnomcte 	CHAR(70);
DEFINE vdirtqe	CHAR(110);
DEFINE vnumtqe	INT;
DEFINE vnumcte	CHAR(6);
DEFINE vcaptqe 	DECIMAL;
DEFINE vultcar	DATE;
DEFINE vcontqe	DECIMAL;
DEFINE vhcontqe	DECIMAL;
DEFINE vobserv  CHAR(200);

FOREACH cursorComodatos FOR
	SELECT	mov_tqe.fecha_mtqe,
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
			TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,
			tanque.numtqe_tqe, 
			cliente.num_cte,
			tanque.capac_tqe,
			mov_tqe.obser_mtqe
	INTO	vfecmov,
			vnomcte,
			vdirtqe,
			vnumtqe,
			vnumcte,
			vcaptqe,
			vobserv
	FROM	cliente, 
			tanque,
			mov_tqe
	WHERE	cliente.num_cte			= tanque.numcte_tqe
			AND	cliente.cia_cte		= paramCia
			AND cliente.pla_cte		= paramPla
			AND mov_tqe.numcte_mtqe	= tanque.numcte_tqe
			AND mov_tqe.num_mtqe	= tanque.numtqe_tqe
			AND mov_tqe.estatus_mtqe= 'B'
			AND mov_tqe.fecha_mtqe  >= paramFechaI
			AND mov_tqe.fecha_mtqe  <= paramFechaF
	ORDER BY 1 DESC
	
	SELECT MAX(fes_nvta)
	INTO	vultcar
	FROM	nota_vta
	WHERE   nota_vta.numcte_nvta 		= vnumcte
			AND nota_vta.edo_nvta		IN('A','S');			
	
	IF 	vultcar IS NULL THEN
		SELECT  MAX(fes_nvta)
		INTO	vultcar
		FROM	hnota_vta
		WHERE   hnota_vta.numcte_nvta 		= vnumcte
				AND hnota_vta.edo_nvta		IN('A','S');
	END IF;	
	
	SELECT  NVL(SUM(nota_vta.tlts_nvta),0)
	INTO	vcontqe
	FROM	nota_vta
	WHERE   nota_vta.numcte_nvta 		= vnumcte
			AND nota_vta.edo_nvta		= 'A'
			AND nota_vta.fes_nvta	   >= paramFechaI
			AND nota_vta.fes_nvta	   <= paramFechaF	
			AND nota_vta.numtqe_nvta 	= vnumtqe;
				
	SELECT  NVL(SUM(rdnota_vta.tlts_nvta),0)
	INTO	vhcontqe
	FROM	rdnota_vta
	WHERE   rdnota_vta.numcte_nvta 		= vnumcte
			AND rdnota_vta.edo_nvta		= 'A'
			AND rdnota_vta.fes_nvta	   >= paramFechaI
			AND rdnota_vta.fes_nvta	   <= paramFechaF	
			AND rdnota_vta.numtqe_nvta 	= vnumtqe;
	LET 	vcontqe = vcontqe + vhcontqe;
			
	RETURN	vfecmov,
			vnomcte,
			vdirtqe,
			vnumtqe,
			vnumcte,
			vcaptqe,
			vultcar,
			vcontqe,
			vobserv	
	WITH RESUME;		
END FOREACH;

END PROCEDURE;