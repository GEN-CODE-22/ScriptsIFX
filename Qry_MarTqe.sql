CREATE PROCEDURE Qry_MarTqe
(
	paramEstatus	CHAR(1)
)
RETURNING 
 INT, 
 CHAR(50), 
 CHAR(1);

DEFINE vcve_mtqe 	INT; 
DEFINE vmarca_mtqe	CHAR(50); 
DEFINE vstat_mtqe	CHAR(1);

FOREACH cursorMarcas FOR
	SELECT	cve_mtqe,
			marca_mtqe,
			stat_mtqe
	INTO	vcve_mtqe,
			vmarca_mtqe,
			vstat_mtqe
	FROM	marca_tqe
	WHERE	LENGTH(paramEstatus) = 0 OR stat_mtqe = paramEstatus
	ORDER BY cve_mtqe
	RETURN	vcve_mtqe,
			vmarca_mtqe,
			vstat_mtqe
	WITH RESUME;
END FOREACH; 

END PROCEDURE;


                                                                