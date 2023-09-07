DROP PROCEDURE rpt_cte;
EXECUTE PROCEDURE rpt_cte('001234');
CREATE PROCEDURE rpt_cte
(
	paramCte      		CHAR(6)
)

RETURNING  INT,CHAR(1);
 --CHAR(6), 
 --CHAR(20), 
 --CHAR(20);
 
--DEFINE v_nocte 		CHAR(6);
DEFINE v_nombre  	CHAR(20);
DEFINE v_apellido  	CHAR(20);
DEFINE v_nocte 		CHAR(6);
DEFINE v_count  	INT;
DEFINE v_tipo  		CHAR(1);


FOREACH cCliente FOR
	SELECT  count(*), tip_cte
	INTO	v_count, v_tipo
	FROM	cliente			 
	group by 2
	RETURN 	v_count,
			v_tipo
	WITH RESUME;
END FOREACH;  
END PROCEDURE;   

SELECT  count(*), tip_cte
FROM	cliente			 
group by 2