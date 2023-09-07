DROP PROCEDURE InsRS;
CREATE PROCEDURE InsRS(
	paramCia	char(2),
	paramPla	char(2),
	paramFecha	date,
	paramRuta	char(4),
	paramEco	char(7),
	paramChof	char(5),
	paramAyud	char(5),
	paramSegA	char(5),
	paramLecI	decimal,	
	paramPtajeI decimal,
	paramHini	datetime year to minute,
	paramPtajeF decimal,
	paramHfin	datetime year to minute,
	paramTon	int,
	paramLtsv	decimal,
	paramTotV	decimal,
	paramContLt	decimal,
	paramUsr	char(8),
	paramTPgo	char(1),
	paramArut	char(4),
	paramReg	int,
	paramCel	char(1),
	paramFol	int 
)

RETURNING
	INT;							

DEFINE regreso	INT;		

DEFINE	cap				DECIMAL; 
DEFINE	fliq			INTEGER; 
DEFINE	consec			INTEGER;
DEFINE	fechaLiquida 	DATE;
DEFINE 	ltsCred			DECIMAL; 
DEFINE	totCred			DECIMAL; 
DEFINE	ltsEfe			DECIMAL; 
DEFINE	totEfe			DECIMAL; 
DEFINE	ltsPar			DECIMAL; 
DEFINE	hini			CHAR(5); 
DEFINE	hfin			CHAR(5); 
DEFINE 	fechaHoraActual DATETIME year to minute;
DEFINE 	fechaHoraMaxima DATETIME year to minute;
DEFINE  vobser			CHAR(500);
DEFINE	vcliq			INT;
DEFINE	maxlecfliq		DECIMAL;
DEFINE	maxfecliq	 	DATE;

SELECT 	DBINFO('utc_to_datetime',sh_curtime)
INTO 	fechaHoraActual
FROM 	sysmaster:'informix'.sysshmvals;

IF EXISTS(SELECT 1 FROM empxrutp WHERE rut_erup = paramRuta AND cia_erup = paramCia AND pla_erup = paramPla AND fliq_erup = paramFol) THEN 
	

	SELECT	cap_uni
	INTO  	cap
	FROM	unidad
	WHERE	cve_uni = paramEco
	AND		cia_uni = paramCia
	AND		pla_uni = paramPla;
	
	SELECT	SUM(CASE
					WHEN tpa_nvta IN ('C', 'G') THEN
						tlts_nvta
					ELSE
						0
					END
				) AS ltsCreditoCredigas,
			SUM(CASE
					WHEN tpa_nvta IN ('C', 'G') THEN
						impt_nvta
					ELSE
						0
					END
				) AS impCreditoCredigas,
			SUM(CASE
					WHEN tpa_nvta IN ('E') THEN
						tlts_nvta
					ELSE
						0
					END
				) AS ltsEfectivo,
			SUM(CASE
					WHEN tpa_nvta IN ('E') THEN
						impt_nvta
					ELSE
						0
						END
				) AS impEfectivo,
			SUM(CASE
					WHEN tpa_nvta IN ('T', 'K', 'I', 'F') THEN
						tlts_nvta
					ELSE
						0
					END
				) AS ltsPar,
			TO_CHAR(MIN(fep_nvta), '%H:%M') AS primerNotaVta,
			TO_CHAR(MAX(fep_nvta), '%H:%M') AS ultimaNotaVta
	INTO	ltsCred,
			totCred,
			ltsEfe,
			totEfe,
			ltsPar,
			hini,
			hfin			
	FROM	nota_vta
	WHERE	cia_nvta = paramCia
	AND		pla_nvta = paramPla
	AND		ruta_nvta = paramRuta
	AND		fliq_nvta = paramFol
	AND		edo_nvta = 'S';
	
	IF (ltsCred IS NOT NULL OR 		
		ltsEfe	IS NOT NULL OR		
		ltsPar	IS NOT NULL) THEN
	
		UPDATE	empxrutp
		SET		pfi_erup = paramPtajeF,
				pdi_erup = ((paramPtajeI - paramPtajeF) * cap)/100,				
				usr_erup = paramUsr,
				fyh_erup = fechaHoraActual,
				hini_erup = hini,
				hfin_erup = hfin
		WHERE	fliq_erup = paramFol
		AND		cia_erup = paramCia
		AND		pla_erup = paramPla
		AND		rut_erup = paramRuta;	
	
	END IF;

	LET vobser = 'Update Fliq: ' || paramFol || ' Cia: ' || paramCia || ' Pla: ' || paramPla || ' Ruta: ' || paramRuta || ' Liq: ' || paramFol || ' LecIni: ' || paramLecI || ' LecFin: ' || paramContLt || ' Uni: ' || paramEco || ' Nvv: ' || paramTon || ' PorF: ' || paramPtajeF || ' Usr: ' || paramUsr;
	INSERT INTO log
	VALUES(CURRENT,vobser,'insrs');
	
	UPDATE	cloud_liq
	SET		stat_cliq 	= 'C',
			cdate_cliq	= CURRENT
	WHERE	liq_cliq		= paramFol
			AND cia_cliq	= paramCia
			AND pla_cliq	= paramPla
			AND ruta_cliq	= paramRuta;
			
	LET		regreso = paramFol;
	
ELSE
	LET		regreso = 0;
	LET hini = TO_CHAR(paramHini,'%H:%M');
	LET hfin = TO_CHAR(paramHfin,'%H:%M');
	
	IF paramRuta <> 'M040' THEN
		SELECT  COUNT(*)
		INTO	vcliq
		FROM	empxrutp
		WHERE	rut_erup 		= paramRuta 
				AND cia_erup 	= paramCia 
				AND pla_erup 	= paramPla
				AND fec_erup 	= paramFecha
				AND ((caj_erup	= 0 OR caj_erup IS NULL) AND (lfi_erup = 0 OR lfi_erup IS NULL));
	ELSE
		LET vcliq = 0;
	END IF;
		
	IF paramFol = 0 THEN
		IF vcliq = 0 THEN
			LOCK TABLE ruta IN EXCLUSIVE MODE;	
				SELECT	(fliq_rut + 1)
				INTO	fliq
				FROM	ruta
				WHERE	cve_rut = paramRuta
				AND		cia_rut = paramCia
				AND		pla_rut = paramPla;
				
				UPDATE	ruta
				SET	   	fliq_rut = fliq
				WHERE	cve_rut = paramRuta
				AND		cia_rut = paramCia
				AND		pla_rut = paramPla;
			UNLOCK TABLE ruta;
			
			SELECT	MAX(fec_erup) 
			INTO 	maxfecliq
			FROM 	empxrutp
            WHERE	empxrutp.uni_erup = paramEco;
            
            SELECT 	NVL(MAX(lfi_erup),0)
            INTO 	maxlecfliq
            FROM 	empxrutp
            WHERE 	empxrutp.uni_erup = paramEco 
            		AND empxrutp.fec_erup = maxfecliq;

			IF maxlecfliq = 0 THEN
				LET maxlecfliq = paramLecI;
			END IF;
			
			INSERT INTO		empxrutp
						   (fliq_erup,
							cia_erup,
							pla_erup,
							rut_erup,
							uni_erup,
							fec_erup,
							edo_erup,
							npt_erup,
							chf_erup,
							ay1_erup,
							ay2_erup,
							pcs_erup,
							arut_erup,
							lin_erup,
							pin_erup,
							usr_erup,
							caj_erup,
							fyh_erup,
							fini_erup,
							ffin_erup,
							hini_erup,
							hfin_erup
						   )
			VALUES		   (fliq,
							paramCia,
							paramPla,
							paramRuta,
							paramEco,
							fechaHoraActual,
							'P',
							'S',
							paramChof,
							paramAyud,
							paramSegA,
							paramTPgo,
							paramArut,
							maxlecfliq,
							paramPtajeI,
							paramUsr,
							0,
							fechaHoraActual,
							fechaHoraActual,
							fechaHoraActual,
							hini,
							hfin
						   );
			
			LET vobser = 'Insert Cia: ' || paramCia || ' Pla: ' || paramPla || ' Ruta: ' || paramRuta || ' Liq: ' || fliq || ' MaxLecIni: ' || maxlecfliq || ' Uni: ' || paramEco;
			INSERT INTO log
			VALUES(CURRENT,vobser,'insrs');
			
			INSERT INTO cloud_liq
			VALUES(fliq,paramCia,paramPla,paramRuta,'A',CURRENT,NULL);
			
			LET		regreso = fliq; 
		ELSE
			LET 	regreso = -1;
		END IF;
	END IF;
END IF;
		
RETURN regreso;

END PROCEDURE;

select *
from	empleado