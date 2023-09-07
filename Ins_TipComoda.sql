CREATE PROCEDURE Ins_TipComoda
(
	paramTipo		CHAR(50),
	paramEstatus	CHAR(1)
)

INSERT INTO tipo_comoda
VALUES(0,paramTipo, paramEstatus);

END PROCEDURE;
                                                                