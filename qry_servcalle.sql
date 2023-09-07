EXECUTE PROCEDURE qry_servcalle('211030017909');
CREATE PROCEDURE qry_servcalle(
	paramFol	CHAR(12)
)
RETURNING 
 CHAR(12),
 CHAR(40),
 CHAR(60),
 CHAR(10);

DEFINE vfolio	CHAR(12); 
DEFINE vcte		CHAR(40);
DEFINE vdir		CHAR(60); 
DEFINE vtel		CHAR(10);

FOREACH cursorServCalle FOR
	SELECT	fol_usc,
			cte_usc,
			dir_usc,
			tel_usc
	INTO	vfolio,
			vcte,
			vdir,
			vtel
	FROM	ubi_servcalle			
	WHERE	fol_usc = paramFol
	RETURN	vfolio,
			vcte,
			vdir,
			vtel
	WITH RESUME;
END FOREACH; 
END PROCEDURE; 

SELECT	*
FROM	ubi_servcalle			
WHERE	fol_usc = '211030213002'                                            