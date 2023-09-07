CREATE PROCEDURE get_faccal
(
	paramCte CHAR(6)
)
RETURNING 
 CHAR(2);
{ 

}

DEFINE vfaccal		CHAR(2);
DEFINE vcodri		CHAR(1);

LET vfaccal = '';
LET vcodri = '';

IF EXISTS( SELECT 1 FROM ri505_ctes WHERE LPAD(TRIM(cve_ri),6,'0') = paramCte) THEN
	SELECT	codigo_ri
	INTO	vcodri
	FROM	ri505_ctes
	WHERE	LPAD(TRIM(cve_ri),6,'0') = paramCte;
	
	IF vcodri = 'P' THEN
		SELECT	efip_dat
		INTO	vfaccal
		FROM	datos;		
	END IF;
	IF vcodri = 'T' THEN
		LET vfaccal = '00';		
	END IF;
	IF vcodri = 'A' THEN
		SELECT	factor_ri
		INTO	vfaccal
		FROM	ri505_ctes
		WHERE 	LPAD(TRIM(cve_ri),6,'0') = paramCte;		
	END IF;		
ELSE
	SELECT	efin_dat
	INTO	vfaccal
	FROM	datos;	
END IF;


RETURN vfaccal;
END PROCEDURE;