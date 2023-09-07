CREATE PROCEDURE get_udigito
(
	dato CHAR(30)
)
RETURNING 
 CHAR(1);

DEFINE vval	CHAR(30);
DEFINE i	SMALLINT;
DEFINE j	SMALLINT;
DEFINE x	SMALLINT;
DEFINE y	SMALLINT;
DEFINE z	SMALLINT;
DEFINE vdig	CHAR(1);

LET vval = dato;
LET j = 2;
LET z = 0;
LET x = LENGTH(TRIM(vval));
FOR i = 1 TO x
  IF j = 2 THEN 
  	LET j = 1;
  ELSE 
  	LET j = 2 ;
  END IF;
  LET vdig = SUBSTR(vval,i,1);
  LET y = SUBSTR(vval,i,1) * 1;
  LET y = y * j;
  IF y > 9 THEN 
  	LET y = y - 9;
  END IF;
  LET z = z + y;
END FOR
LET z = MOD(z,10);
IF z <> 0 THEN 
	LET z = 10 - z;
END IF;
LET vdig = z || '';


RETURN vdig;
END PROCEDURE; 