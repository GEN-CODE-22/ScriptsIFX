CREATE PROCEDURE Qry_Banco
(

)
RETURNING 
 CHAR(4), 
 CHAR(30);

DEFINE vcve_ban 	CHAR(4); 
DEFINE vdesc_ban	CHAR(30);

FOREACH cursorBancos FOR
	SELECT	cve_ban,
			des_ban
	INTO	vcve_ban,
			vdesc_ban
	FROM	banco
	ORDER BY des_ban
	RETURN	vcve_ban,
			vdesc_ban
	WITH RESUME;
END FOREACH; 

END PROCEDURE;