CREATE PROCEDURE Upt_InvTqe
(
	paramNumInv		INT,
	paramCia		CHAR(2),
	paramPla   		CHAR(2),
	paramMarca		INT,
	paramCapac		DECIMAL,
	paramNumSer		CHAR(20),
	paramFecFab		DATE,
	paramLitros		DECIMAL,	
	paramRep		CHAR(1),
	paramStat		CHAR(1)
)

UPDATE  inv_tqe
SET 	cia_itqe 	= paramCia,
		pla_itqe 	= paramPla,
		marca_itqe	= paramMarca,
		capac_itqe	= paramCapac,
		numser_itqe	= paramNumSer,
		fecfab_itqe	= paramFecFab,
		lts_itqe	= paramLitros,
		repos_itqe	= paramRep,
		estatus_itqe= paramStat
WHERE	num_itqe	= paramNumInv;

END PROCEDURE; 
