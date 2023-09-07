CREATE PROCEDURE Ins_MttoTqe
(
	paramFecha		DATE,
	paramUsuario	CHAR(8),
	paramObser		CHAR(500),
	paramNumSer		CHAR(20),
	paramArch		CHAR(200)
)

IF EXISTS(SELECT 	1 
			FROM 	mtto_tqe 
			WHERE  	numtqe_mtto = paramNumSer AND arch_mtto = paramArch) THEN
	UPDATE	mtto_tqe
	SET		usr_mtto = paramUsuario, obser_mtto = paramObser, arch_mtto = paramArch
	WHERE	numtqe_mtto = paramNumSer AND fecha_mtto = paramFecha;			
	
ELSE
	
	INSERT INTO  mtto_tqe(fecha_mtto,usr_mtto,obser_mtto,numtqe_mtto,arch_mtto)
	VALUES(paramFecha,paramUsuario,paramObser,paramNumSer,paramArch);
END IF;

END PROCEDURE; 