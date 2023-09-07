CREATE PROCEDURE Del_MttoTqe
(
	paramNumSer		CHAR(20),
	paramArch		CHAR(200)
)


DELETE
FROM	mtto_tqe
WHERE	numtqe_mtto = paramNumSer AND arch_mtto = paramArch;

END PROCEDURE;

