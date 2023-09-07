CREATE PROCEDURE Ins_InvTqe
(
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
RETURNING INTEGER;
DEFINE vnumitqe INTEGER;

INSERT INTO  inv_tqe
VALUES(0,paramCia,paramPla,paramMarca,paramCapac,paramNumSer,paramFecFab,paramLitros,paramRep,paramStat);

SELECT	MAX(num_itqe)
INTO	vnumitqe
FROM	inv_tqe;

RETURN vnumitqe;

END PROCEDURE; 