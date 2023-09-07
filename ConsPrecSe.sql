CREATE PROCEDURE ConsPrecSe
(
	paramTip CHAR(1)
)
RETURNING 	
 CHAR(3), 
 CHAR(1), 
 SMALLINT, 
 CHAR(30),
 CHAR(1), 
 CHAR(46);
 
DEFINE tpr CHAR(3); 
DEFINE tid CHAR(1); 
DEFINE reg SMALLINT; 
DEFINE nom CHAR(30);
DEFINE pri CHAR(1); 
DEFINE usr CHAR(8);
DEFINE des CHAR(46);

DEFINE 	fechaPrecio DATETIME YEAR TO DAY;

SELECT 	DBINFO('utc_to_datetime',sh_curtime)
INTO 	fechaPrecio
FROM 	sysmaster:'informix'.sysshmvals;

FOREACH cursorcanc FOR 
	SELECT 	precios.tpr_prc, 
			precios.tid_prc, 
			precios.reg_prc,
	       	precios.nom_prc, 
			precios.pri_prc, 
			precios.usr_prc, 
			(precios.tpr_prc || ' - ' || 
		    precios.nom_prc || ' - ' || mov_prc.pru_mprc) AS com 
	INTO  	tpr, 
			tid, 
			reg, 
			nom, 
			pri, 
			usr, 
			des
	FROM   	precios, 
			mov_prc 
    WHERE  	precios.tpr_prc = mov_prc.tpr_mprc	
			AND    mov_prc.fei_mprc <= fechaPrecio
			AND    mov_prc.fet_mprc >= fechaPrecio
		    AND    precios.tid_prc = paramTip
	ORDER BY precios.tpr_prc
	RETURN 	tpr, 
			tid, 
			reg, 
			nom, 
			pri, 
			des
    WITH RESUME; 
END FOREACH;
END PROCEDURE;               