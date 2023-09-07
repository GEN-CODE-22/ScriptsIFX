CREATE PROCEDURE getUser
(
	paramNombre CHAR(8)
)
RETURNING 
	CHAR(8),
	CHAR(2),
	CHAR(2),
	CHAR(4),
	CHAR(1),
	CHAR(2),
	CHAR(40),
	CHAR(8);

DEFINE vcve CHAR(8);
DEFINE vcia CHAR(2);
DEFINE vpla CHAR(2);
DEFINE vlada CHAR(4);
DEFINE vtip CHAR(1);
DEFINE vtpu CHAR(2);
DEFINE vnom CHAR(40);
DEFINE vpass CHAR(8);

FOREACH cursorUser FOR
	SELECT	usr_ucve,
			cia_ucve,
			pla_ucve,
			lada_ucve,
			tip_ucve,
			tpu_ucve,
			nom_ucve,
			pas_ucve
	INTO 	vcve,
			vcia,
			vpla,
			vlada,
			vtip,
			vtpu,
			vnom,
			vpass
	FROM 	usr_cve 
	WHERE	usr_ucve = paramNombre
	RETURN	vcve,
			vcia,
			vpla,
			vlada,
			vtip,
			vtpu,
			vnom,
			vpass
	WITH RESUME;
END FOREACH;

END PROCEDURE;