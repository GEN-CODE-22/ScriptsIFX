CREATE PROCEDURE get_tpgoenr
(
	paramTpa CHAR(1)
)
RETURNING 
 CHAR(1);
{ 

}

DEFINE vtpgo		CHAR(1);

LET vtpgo = '1';
IF paramTpa = 'E' THEN
	LET vtpgo = 1;
ELSE
	IF paramTpa = 'C' THEN
		LET vtpgo = 2;
	ELSE
		IF paramTpa = 'G' THEN
			LET vtpgo = 3;
		ELSE
			IF paramTpa = 'T'THEN				
				LET vtpgo = 8;
			END IF;
		END IF;
	END IF;
END IF;

RETURN vtpgo ;
END PROCEDURE;