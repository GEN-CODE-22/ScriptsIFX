CREATE PROCEDURE Upt_TipComoda
(
	paramCveTCom	INT,
	paramTipCom		CHAR(50),
	paramEstatus	CHAR(1)
)

UPDATE	tipo_comoda
SET		tipo_tcom   = paramTipCom,
		stat_tcom   = paramEstatus
WHERE	cve_tcom	= paramCveTCom;

END PROCEDURE;
                                                                