CREATE PROCEDURE Ins_MarTqe
(
	paramMarca		CHAR(50),
	paramEstatus	CHAR(1)
)

INSERT INTO marca_tqe
VALUES(0,paramMarca, paramEstatus);

END PROCEDURE;
                                                                