CREATE PROCEDURE Upt_Comodato
(
	paramTipo	INT,
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramNumCom	INT,
	paramNumSer	CHAR(20),
	paramMarca	INT,
	paramDir	CHAR(40),
	paramCol	CHAR(40),
	paramCiu	CHAR(30),
	paramObser	CHAR(200),
	paramMesFab SMALLINT,
	paramAnoFab SMALLINT,
	paramUsr	CHAR(8),
	paramStat	CHAR(1),
	paramFecEnt DATE
)

DEFINE	vusrbaj_com CHAR(8);
DEFINE	vfecbaj_com DATE;

LET	vusrbaj_com = NULL;
LET vfecbaj_com = NULL;

IF paramStat = 'B'THEN
	LET	vusrbaj_com = paramUsr;
	LET vfecbaj_com = TODAY;
END IF;

UPDATE	comodatos
SET		tipo_com 	= paramTipo,
		cia_com		= paramCia,
		pla_com		= paramPla,
		numser_com	= paramNumSer,
		marca_com	= paramMarca,
		dir_com		= paramDir,
		col_com		= paramCol,
		ciu_com		= paramCiu,
		obser_com	= paramObser,
		mesfab_com	= paramMesFab,
		anofab_com	= paramAnoFab,
		usr_com		= paramUsr,
		fecbaj_com	= vfecbaj_com,
		usrbaj_com	= vusrbaj_com,
		stat_com	= paramStat,
		fecent_com	= paramFecEnt
WHERE	numcom_com = paramNumCom AND numcte_com = paramCte;

END PROCEDURE;


