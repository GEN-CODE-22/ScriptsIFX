CREATE PROCEDURE Ins_Comodato
(
	paramTipo	INT,
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramNumSer	CHAR(20),
	paramMarca	INT,
	paramDir	CHAR(40),
	paramCol	CHAR(40),
	paramCiu	CHAR(30),
	paramObser	CHAR(200),
	paramMesFab SMALLINT,
	paramAnoFab SMALLINT,
	paramUsr	CHAR(8),	
	paramFecEnt DATE
)

DEFINE vnumcom_com	INT;

SELECT	NVL(MAX(numcom_com),0) + 1
INTO	vnumcom_com
FROM	comodatos
WHERE	numcte_com = paramCte;

INSERT INTO  
	comodatos(	tipo_com,
				cia_com,
				pla_com,
				numcte_com,
				numcom_com,
				numser_com,
				marca_com,
				dir_com,
				col_com,
				ciu_com,
				obser_com,
				mesfab_com,
				anofab_com,
				usr_com,
				stat_com,
				fecent_com)
VALUES(			paramTipo,
				paramCia,
				paramPla,
				paramCte,
				vnumcom_com,
				paramNumSer,
				paramMarca,
				paramDir,
				paramCol,
				paramCiu,
				paramObser,
				paramMesFab,
				paramAnoFab,
				paramUsr,
				'A',
				paramFecEnt);

END PROCEDURE; 