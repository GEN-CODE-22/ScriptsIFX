CREATE PROCEDURE Ins_MovInvTqe
(
	paramFecha		DATETIME YEAR TO MINUTE,
	paramNumTqe   	INT,
	paramUsuario	CHAR(8),
	paramCliente	CHAR(6),
	paramDir		CHAR(40),
	paramCol		CHAR(40),	
	paramStat		CHAR(1),
	paramObser		CHAR(200)
)
DEFINE vcia			CHAR(2);
DEFINE vpla 		CHAR(2);
DEFINE vnumtqe 		INTEGER;
DEFINE vcapactqe	DECIMAL;
DEFINE vnumtsertqe 	CHAR(20);
DEFINE vfecfabtqe 	DATETIME YEAR TO MINUTE;
DEFINE vmonthfab 	INTEGER;
DEFINE vyearfab 	INTEGER;
DEFINE vstaactual 	CHAR(1);

INSERT INTO  mov_tqe
VALUES(paramFecha,paramNumTqe,paramUsuario,paramCliente,paramDir,paramCol,paramStat,paramObser);

SELECT	estatus_itqe
INTO	vstaactual
FROM	inv_tqe
WHERE	num_itqe = paramNumTqe;

IF paramStat = 'C'	THEN
	SELECT	MAX(numtqe_tqe)
	INTO	vnumtqe
	FROM	tanque
	WHERE	numcte_tqe	= paramCliente;
	
	SELECT	cia_cte,
			pla_cte
	INTO	vcia,
			vpla
	FROM	cliente
	WHERE	num_cte	= paramCliente;

	SELECT	capac_itqe,
			numser_itqe,
			fecfab_itqe
	INTO	vcapactqe,
			vnumtsertqe,
			vfecfabtqe
	FROM	inv_tqe
	WHERE	num_itqe = paramNumTqe;
	
	UPDATE	tanque
	SET		comoda_tqe = 'N', stat_tqe='B'
	WHERE	numser_tqe = vnumtsertqe;
		
	LET vnumtqe 	= vnumtqe + 1;
	LET vmonthfab 	= MONTH(vfecfabtqe);
	LET vyearfab	= YEAR(vfecfabtqe);
	
	INSERT INTO tanque
	(
		numcte_tqe,
		cia_tqe,
		pla_tqe,
		dir_tqe,
		col_tqe,
		numtqe_tqe,
		capac_tqe,
		comoda_tqe,
		numser_tqe,
		mesfab_tqe,
		anofab_tqe,
		usr_tqe,
		stat_tqe,
		feccom_tqe,
		serv_tqe
	)
	VALUES
	(
		paramCliente,
		vcia,
		vpla,
		paramDir,
		paramCol,
		vnumtqe,
		vcapactqe,
		'S',
		vnumtsertqe,
		vmonthfab,
		vyearfab,
		paramUsuario,
		'A',
		paramFecha,
		'E'
	);
END IF;

IF vstaactual = 'C' AND paramStat <> 'C' THEN
	UPDATE	tanque
	SET		comoda_tqe = 'N'
	WHERE	numser_tqe = vnumtsertqe;
END IF;

END PROCEDURE; 