CREATE PROCEDURE Qry_MovInvTqe
(
	paramNumSerTqe	CHAR(20)
)
RETURNING 
 DATETIME YEAR TO MINUTE,
 INT, 
 CHAR(6),
 CHAR(40),
 CHAR(40),
 CHAR(70),
 CHAR(1), 
 CHAR(15),
 CHAR(200),
 CHAR(8),
 CHAR(40);

DEFINE vfecha_mtqe 		DATETIME YEAR TO MINUTE; 
DEFINE vnum_mtqe		INT; 
DEFINE vnumcte_mtqe		CHAR(6);
DEFINE vdir_mtqe		CHAR(40);
DEFINE vcol_mtqe		CHAR(40);
DEFINE vnomcte_mtqe		CHAR(70);
DEFINE vestatus_mqte	CHAR(1);
DEFINE vdestatus_mqte	CHAR(15);
DEFINE vobser_mtqe		CHAR(200);
DEFINE vusr_mtqe		CHAR(8);
DEFINE vnusr_mtqe		CHAR(40);

FOREACH cursorMovInv FOR
	SELECT	mov_tqe.fecha_mtqe,
			mov_tqe.num_mtqe,
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
			END AS nomcte_mtqe,
			mov_tqe.dir_mtqe,
			mov_tqe.col_mtqe,
			mov_tqe.estatus_mtqe,
			CASE
				WHEN mov_tqe.estatus_mtqe = 'A' THEN
				   'EN PLANTA'
				WHEN mov_tqe.estatus_mtqe = 'B' THEN
				   'BAJA'
				WHEN mov_tqe.estatus_mtqe = 'C' THEN
				   'COMODATADO'
				WHEN mov_tqe.estatus_mtqe = 'R' THEN
				   'REPARACION'
				ELSE
				   'NO DEFINIDO'
			END AS destatus_mqte,			
			mov_tqe.obser_mtqe,
			usr_cve.usr_ucve,
			NVL(usr_cve.nom_ucve,usr_cve.usr_ucve)
	INTO	vfecha_mtqe,
			vnum_mtqe,
			vnumcte_mtqe,
			vnomcte_mtqe,
			vdir_mtqe,
			vcol_mtqe,
			vestatus_mqte,
			vdestatus_mqte,
			vobser_mtqe,
			vusr_mtqe,
			vnusr_mtqe
	FROM	mov_tqe,
			inv_tqe,
			usr_cve,
			OUTER cliente
	WHERE	mov_tqe.num_mtqe 		= inv_tqe.num_itqe
			AND mov_tqe.numcte_mtqe	= cliente.num_cte
			AND usr_cve.usr_ucve	= mov_tqe.usr_mtqe
			AND inv_tqe.numser_itqe	= paramNumSerTqe
	ORDER BY fecha_mtqe DESC
	RETURN	vfecha_mtqe,
			vnum_mtqe,
			vnumcte_mtqe,
			vnomcte_mtqe,
			vdir_mtqe,
			vcol_mtqe,
			vestatus_mqte,
			vdestatus_mqte,
			vobser_mtqe,
			vusr_mtqe,
			vnusr_mtqe
	WITH RESUME;
END FOREACH; 

END PROCEDURE;