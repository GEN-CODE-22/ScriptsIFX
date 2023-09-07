CREATE PROCEDURE Qry_InvTqe
(
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramFechaI	DATETIME YEAR TO MINUTE,
	paramFechaF	DATETIME YEAR TO MINUTE,
	paramStat	CHAR(1)
)
RETURNING 
 INT, 
 INT,
 CHAR(50),
 DECIMAL,
 CHAR(20),
 DATETIME YEAR TO MINUTE,
 DECIMAL,
 CHAR(1),
 CHAR(6),
 CHAR(70),
 CHAR(40),
 CHAR(40),
 DATETIME YEAR TO MINUTE,
 CHAR(1),
 CHAR(15),
 CHAR(200);
 
DEFINE vnum_mtqe 		INT; 
DEFINE vmarca_mtqe		CHAR(50); 
DEFINE vcve_mtqe		INT; 
DEFINE vcapac_itqe		DECIMAL;
DEFINE vnumser_itqe 	CHAR(20);
DEFINE vfecfab_itqe		DATETIME YEAR TO MINUTE;
DEFINE vlts_itqe		DECIMAL;
DEFINE vrepos_itqe		CHAR(1);
DEFINE vestatus_itqe	CHAR(1);
DEFINE vedo_itqe		CHAR(15);
DEFINE vfecha_mtqe		DATETIME YEAR TO MINUTE;
DEFINE vnumcte_mtqe		CHAR(6);
DEFINE vnomcte_mtqe		CHAR(70);
DEFINE vdir_mtqe		CHAR(40);
DEFINE vcol_mtqe		CHAR(40);
DEFINE vobser_mtqe		CHAR(200);

FOREACH cursorInventario FOR
	SELECT	mov_tqe.num_mtqe,
			mov_tqe.fecha_mtqe,
			mov_tqe.numcte_mtqe,			
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
			mov_tqe.dir_mtqe,
			mov_tqe.col_mtqe,	
			mov_tqe.obser_mtqe
	INTO	vnum_mtqe,
			vfecha_mtqe,
			vnumcte_mtqe,
			vnomcte_mtqe,
			vdir_mtqe,
			vcol_mtqe,
			vobser_mtqe
	FROM	mov_tqe,
			OUTER cliente
	WHERE	mov_tqe.numcte_mtqe		= cliente.num_cte
			AND (mov_tqe.fecha_mtqe >= paramFechaI OR paramFechaI IS NULL)
			AND (mov_tqe.fecha_mtqe <= paramFechaF OR paramFechaI IS NULL)
			AND (mov_tqe.estatus_mtqe = paramStat OR paramStat IS NULL)
			AND mov_tqe.num_mtqe   IN (SELECT	num_itqe
									   FROM		inv_tqe
									   WHERE	cia_itqe 		= paramCia
									   			AND pla_itqe 	= paramPla)
			AND mov_tqe.fecha_mtqe = (
										SELECT 	MAX(fecha_mtqe)
										FROM	mov_tqe m
										WHERE	m.num_mtqe = mov_tqe.num_mtqe
									)
	ORDER BY mov_tqe.fecha_mtqe ASC
	
	SELECT	marca_tqe.cve_mtqe,
			marca_tqe.marca_mtqe,
			inv_tqe.capac_itqe,
			inv_tqe.numser_itqe,
			inv_tqe.fecfab_itqe,
			inv_tqe.lts_itqe,
			inv_tqe.repos_itqe,
			inv_tqe.estatus_itqe,
			CASE
				WHEN inv_tqe.estatus_itqe = 'A' THEN
				   'EN PLANTA'
				WHEN inv_tqe.estatus_itqe = 'B' THEN
				   'BAJA'
				WHEN inv_tqe.estatus_itqe = 'C' THEN
				   'COMODATADO'
				WHEN inv_tqe.estatus_itqe = 'R' THEN
				   'REPARACION'
				ELSE
				   'NO DEFINIDO'
			END AS edo_itqe
	INTO	vcve_mtqe,
			vmarca_mtqe,
			vcapac_itqe,
			vnumser_itqe,
			vfecfab_itqe,
			vlts_itqe,
			vrepos_itqe,			
			vestatus_itqe,
			vedo_itqe
	FROM	inv_tqe,
			marca_tqe
	WHERE	inv_tqe.num_itqe = vnum_mtqe
			AND inv_tqe.marca_itqe = marca_tqe.cve_mtqe;
	RETURN	vnum_mtqe,
			vcve_mtqe,
			vmarca_mtqe,
			vcapac_itqe,
			vnumser_itqe,
			vfecfab_itqe,
			vlts_itqe,
			vrepos_itqe,
			vnumcte_mtqe,
			vnomcte_mtqe,
			vdir_mtqe,
			vcol_mtqe,
			vfecha_mtqe,			
			vestatus_itqe,
			vedo_itqe,
			vobser_mtqe
	WITH RESUME;
END FOREACH; 

END PROCEDURE;