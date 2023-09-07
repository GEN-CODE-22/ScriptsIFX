DROP PROCEDURE cxc_saldorangov;
EXECUTE PROCEDURE cxc_saldorangov('2023-03-14','2022-12-14',30,60,90,120,150,180,210,240,270,8544);
CREATE PROCEDURE cxc_saldorangov
(
	paramFecha   	DATE,
	paramFecVen		DATE,
	paramR1			SMALLINT,
	paramR2			SMALLINT,
	paramR3			SMALLINT,
	paramR4			SMALLINT,
	paramR5			SMALLINT,
	paramR6			SMALLINT,
	paramR7			SMALLINT,
	paramR8			SMALLINT,
	paramR9			SMALLINT,
	paramSaldo		DECIMAL
)
RETURNING  
 DECIMAL,	--Saldo -0 dias
 DECIMAL,	--Saldo 1-30 dias
 DECIMAL,	--Saldo 31-60 dias
 DECIMAL,	--Saldo 61-90 dias
 DECIMAL,	--Saldo 91-120 dias
 DECIMAL,	--Saldo 121-150 dias
 DECIMAL,	--Saldo 151-180 dias
 DECIMAL,	--Saldo 181-210 dias
 DECIMAL,	--Saldo 211-240 dias
 DECIMAL,	--Saldo 241-270 dias
 DECIMAL;	--Saldo +270 dias

DEFINE vsaldosinv 	DECIMAL;
DEFINE vsaldo1 		DECIMAL;
DEFINE vsal30 		DECIMAL;
DEFINE vsal60 		DECIMAL;
DEFINE vsal90 		DECIMAL;
DEFINE vsal120 		DECIMAL;
DEFINE vsal150 		DECIMAL;
DEFINE vsal180 		DECIMAL;
DEFINE vsal210 		DECIMAL;
DEFINE vsal240 		DECIMAL;
DEFINE vsal270 		DECIMAL;

LET vsaldosinv = 0;
LET vsaldo1 = 0;
LET vsal30 = 0;
LET vsal60 = 0;
LET vsal90 = 0;
LET vsal120 = 0;
LET vsal150 = 0;
LET vsal180 = 0;
LET vsal210 = 0;
LET vsal240 = 0;
LET vsal270 = 0;

IF paramFecVen >= paramFecha THEN
  LET vsaldosinv = paramSaldo;
END IF;
IF paramFecVen < paramFecha AND paramFecVen > (paramFecha - paramR1) THEN
  LET vsaldo1 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR1) AND paramFecVen > (paramFecha-paramR2) THEN
  LET vsal30 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR2) AND paramFecVen > (paramFecha-paramR3) THEN
  LET vsal60 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR3) AND paramFecVen > (paramFecha-paramR4) THEN
  LET vsal90 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR4) AND paramFecVen > (paramFecha-paramR5) THEN
  LET vsal120 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR5) AND paramFecVen > (paramFecha-paramR6) THEN
  LET vsal150 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR6) AND paramFecVen > (paramFecha-paramR7) THEN
  LET vsal180 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR7) AND paramFecVen > (paramFecha-paramR8) THEN
  LET vsal210 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR8) AND paramFecVen > (paramFecha-paramR9) THEN
  LET vsal240 = paramSaldo;
END IF;
IF paramFecVen <= (paramFecha-paramR9) THEN
  LET vsal270 = paramSaldo;
END IF;

RETURN 	vsaldosinv,vsaldo1,vsal30,vsal60,vsal90,vsal120,vsal150,vsal180,vsal210,vsal240,vsal270;
END PROCEDURE;
