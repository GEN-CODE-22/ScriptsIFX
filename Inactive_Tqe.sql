CREATE PROCEDURE Inactive_Tqe
(
	paramNumTqe   	INT,
	paramUsuario	CHAR(8),
	paramCliente	CHAR(6),
	paramObser		CHAR(200)
)


UPDATE	tanque
SET		comoda_tqe =  'N',
		stat_tqe	= 'B'
WHERE	numcte_tqe = paramCliente
		AND numtqe_tqe = paramNumTqe;

INSERT INTO  mov_tqe
VALUES(CURRENT,paramNumTqe,paramUsuario,paramCliente,'','','B',paramObser);

END PROCEDURE;  