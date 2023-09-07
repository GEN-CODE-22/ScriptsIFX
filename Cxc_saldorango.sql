DROP PROCEDURE cxc_saldorango;
EXECUTE PROCEDURE cxc_saldorango('2022-07-13','2022-05-28',30,60,90,180,1501.92);
CREATE PROCEDURE cxc_saldorango
(
	paramFecha   	DATE,
	paramFecEmi		DATE,
	paramR1			SMALLINT,
	paramR2			SMALLINT,
	paramR3			SMALLINT,
	paramR4			SMALLINT,
	paramSaldo		DECIMAL
)
RETURNING  
 DECIMAL,	--Saldo 0-30 dias
 DECIMAL,	--Saldo 31-60 dias
 DECIMAL,	--Saldo 61-90 dias
 DECIMAL,	--Saldo 91 -180 dias
 DECIMAL;	--Saldo +180 dias

DEFINE vsaldo DECIMAL;
DEFINE vsal30 DECIMAL;
DEFINE vsal60 DECIMAL;
DEFINE vsal90 DECIMAL;
DEFINE vsal180 DECIMAL;

LET vsaldo = 0;
LET vsal30 = 0;
LET vsal60 = 0;
LET vsal90 = 0;
LET vsal180 = 0;

IF paramFecEmi > (paramFecha-paramR1) THEN
  LET vsaldo = paramSaldo;
END IF;
IF paramFecEmi <= (paramFecha-paramR1) AND paramFecEmi > (paramFecha-paramR2) THEN
  LET vsal30 = paramSaldo;
END IF;
IF paramFecEmi <= (paramFecha-paramR2) AND paramFecEmi > (paramFecha-paramR3) THEN
  LET vsal60 = paramSaldo;
END IF;
IF paramFecEmi <= (paramFecha-paramR3) AND paramFecEmi > (paramFecha-paramR4) THEN
  LET vsal90 = paramSaldo;
END IF;
IF paramFecEmi <= (paramFecha-paramR4) THEN
  LET vsal180 = paramSaldo;
END IF;

RETURN 	vsaldo,vsal30,vsal60,vsal90,vsal180;
END PROCEDURE;

select	*
from	doctos
where 	fol_doc in(174323) 

FUNCTION leecardet7(xfec,ran1,ran2,ran3,ran4,xkk)
   DEFINE
      xfec   DATE,
      ran1   SMALLINT,
      ran2   SMALLINT,
      ran3   SMALLINT,
      ran4   SMALLINT

   LET xdoc.tip_doc  = rdoc.tip_doc
   LET xdoc.fol_doc  = rdoc.fol_doc
   LET xdoc.ser_doc  = rdoc.ser_doc
   LET xdoc.cia_doc  = rdoc.cia_doc
   LET xdoc.pla_doc  = rdoc.pla_doc
   LET xdoc.fven_doc = rdoc.fven_doc
   LET xdoc.sal_doc = rdoc.sal_doc
   LET xdoc.sv1_doc = 0.0
   LET xdoc.sv2_doc = 0.0
   LET xdoc.sv3_doc = 0.0
   LET xdoc.sv4_doc = 0.0
   LET xdoc.sv5_doc = 0.0

   IF rdoc.femi_doc > (xfec-ran1) THEN
      LET xdoc.sv1_doc = rdoc.sal_doc
   END IF
   IF rdoc.femi_doc <= (xfec-ran1) AND rdoc.femi_doc > (xfec-ran2) THEN
      LET xdoc.sv2_doc = rdoc.sal_doc
   END IF
   IF rdoc.femi_doc <= (xfec-ran2) AND rdoc.femi_doc > (xfec-ran3) THEN
      LET xdoc.sv3_doc = rdoc.sal_doc
   END IF
   IF rdoc.femi_doc <= (xfec-ran3) AND rdoc.femi_doc > (xfec-ran4) THEN
      LET xdoc.sv4_doc = rdoc.sal_doc
   END IF
   IF rdoc.femi_doc <= (xfec-ran4) THEN
      LET xdoc.sv5_doc = rdoc.sal_doc
   END IF

END FUNCTION
