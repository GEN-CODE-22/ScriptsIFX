CREATE PROCEDURE Qry_TipComoda
(
	paramEstatus	CHAR(1)
)
RETURNING 
 INT, 
 CHAR(50), 
 CHAR(1);

DEFINE vcve_tcom 	INT; 
DEFINE vtipo_tcom	CHAR(50); 
DEFINE vstat_tcom	CHAR(1);

FOREACH cursorMarcas FOR
	SELECT	cve_tcom,
			tipo_tcom,
			stat_tcom
	INTO	vcve_tcom,
			vtipo_tcom,
			vstat_tcom
	FROM	tipo_comoda
	WHERE	LENGTH(paramEstatus) = 0 OR stat_tcom = paramEstatus
	ORDER BY cve_tcom
	RETURN	vcve_tcom,
			vtipo_tcom,
			vstat_tcom
	WITH RESUME;
END FOREACH; 

END PROCEDURE;