CREATE PROCEDURE Qry_MttoTqe
(
	paramNumSer	CHAR(20)
)
RETURNING 
 DATE,
 CHAR(8),
 CHAR(500),
 CHAR(20),
 CHAR(200);

DEFINE vfecha_mtto 		DATE; 
DEFINE vusr_mtto		CHAR(8); 
DEFINE vobser_mtto		CHAR(500);
DEFINE vnumtqe_mtto		CHAR(20);
DEFINE varch_mtto		CHAR(200);


FOREACH cursorMttoTqe FOR
	SELECT	mtto_tqe.fecha_mtto,
			usr_mtto,
			mtto_tqe.obser_mtto,
			mtto_tqe.numtqe_mtto,
			mtto_tqe.arch_mtto		
	INTO	vfecha_mtto,
			vusr_mtto,
			vobser_mtto,
			vnumtqe_mtto,
			varch_mtto
	FROM	mtto_tqe
	WHERE	mtto_tqe.numtqe_mtto	= paramNumSer
	ORDER BY fecha_mtto DESC
	RETURN	vfecha_mtto,
			vusr_mtto,
			vobser_mtto,
			vnumtqe_mtto,
			varch_mtto
	WITH RESUME;
END FOREACH; 

END PROCEDURE;