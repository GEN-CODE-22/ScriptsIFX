DROP PROCEDURE get_plantas;
EXECUTE PROCEDURE get_plantas('');

CREATE PROCEDURE get_plantas
(
	paramPla CHAR(18) -- 023233343536373839
)
RETURNING 
 CHAR(2),
 CHAR(2),
 CHAR(2),
 CHAR(2),
 CHAR(2),
 CHAR(2),
 CHAR(2),
 CHAR(2),
 CHAR(2);

DEFINE vpla1 	CHAR(2);
DEFINE vpla2 	CHAR(2);
DEFINE vpla3 	CHAR(2);
DEFINE vpla4 	CHAR(2);
DEFINE vpla5 	CHAR(2);
DEFINE vpla6 	CHAR(2);
DEFINE vpla7 	CHAR(2);
DEFINE vpla8 	CHAR(2);
DEFINE vpla9 	CHAR(2);
DEFINE longitud INT;
DEFINE i		INT;

LET vpla1 = '';
LET vpla2 = '';
LET vpla3 = '';
LET vpla4 = '';
LET vpla5 = '';
LET vpla6 = '';
LET vpla7 = '';
LET vpla8 = '';
LET vpla9 = '';

LET longitud = LENGTH(TRIM(paramPla));
FOR i = 1 TO longitud
	IF i = 1 THEN
		LET vpla1 = SUBSTR(paramPla, i,2);
	END IF;
	IF i = 3 THEN
		LET vpla2 = SUBSTR(paramPla, i,2);
	END IF;
	IF i = 5 THEN
		LET vpla3 = SUBSTR(paramPla, i,2);
	END IF;
	IF i = 7 THEN
		LET vpla4 = SUBSTR(paramPla, i,2);
	END IF;
	IF i = 9 THEN
		LET vpla5 = SUBSTR(paramPla, i,2);
	END IF;
	IF i = 11 THEN
		LET vpla6 = SUBSTR(paramPla, i,2);
	END IF;
	IF i = 13 THEN
		LET vpla7 = SUBSTR(paramPla, i,2);
	END IF;
	IF i = 15 THEN
		LET vpla8 = SUBSTR(paramPla, i,2);
	END IF;
	IF i = 17 THEN
		LET vpla8 = SUBSTR(paramPla, i,2);
	END IF;
END FOR

RETURN vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9;
END PROCEDURE; 