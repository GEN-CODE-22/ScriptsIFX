CREATE PROCEDURE Qry_Catalog
(
	paramCat		CHAR(3),
	paramEstatus	CHAR(1)
)
RETURNING 
 CHAR(3),
 CHAR(3), 
 CHAR(30), 
 CHAR(1);

DEFINE vcat_cat		CHAR(3); 
DEFINE vcve_cat 	CHAR(3); 
DEFINE vnom_cat		CHAR(30); 
DEFINE vstat_cat	CHAR(1);

FOREACH cursorCatalogo FOR
	SELECT	cat_cat,
			cve_cat,
			nom_cat,
			stat_cat
	INTO	vcat_cat,
			vcve_cat,
			vnom_cat,
			vstat_cat
	FROM	catalogs
	WHERE	cat_cat = paramCat
			AND (paramEstatus IS NULL OR stat_cat = paramEstatus)
	RETURN	vcat_cat,
			vcve_cat,
			vnom_cat,
			vstat_cat
	WITH RESUME;
END FOREACH; 

END PROCEDURE;