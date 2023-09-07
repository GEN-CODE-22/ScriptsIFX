CREATE PROCEDURE RecTipCan()
RETURNING 
 CHAR(2), 
 CHAR(50);

DEFINE tipCan CHAR(2);
DEFINE desCan CHAR(50);

FOREACH cursorcanc FOR
	SELECT	cve_tcan, 
			desc_tcan 
	INTO 	tipCan, 
			desCan 
	FROM 	tip_cancel
	RETURN 	tipCan, 
			desCan 
	WITH RESUME;
END FOREACH;
END PROCEDURE; 