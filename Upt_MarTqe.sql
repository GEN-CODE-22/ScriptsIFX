CREATE PROCEDURE Upt_MarTqe
(
	paramCveTqe		INT,
	paramMarca		CHAR(50),
	paramEstatus	CHAR(1)
)

UPDATE	marca_tqe
SET		marca_mtqe  = paramMarca,
		stat_mtqe   = paramEstatus
WHERE	cve_mtqe	= paramNumTqe;

END PROCEDURE;
                                                                