CREATE PROCEDURE MatchLiq(
	paramLiq	INT,
	paramCia   	CHAR(2),
	paramPla   	CHAR(2),	
	paramRuta  	CHAR(4),
	paramFecha 	DATE,
	paramlin  	DECIMAL,
	paramlfi 	DECIMAL,
	parampin	DECIMAL,
	parampfi	DECIMAL,
	paramUsr	CHAR(8)
)

DEFINE vobserlog	CHAR(1500);

UPDATE	empxrutp
SET		lin_erup 		= paramlin,
		lfi_erup 		= paramlfi,
		pin_erup 		= parampin,
		pfi_erup 		= parampfi
WHERE	cia_erup 		= paramCia
		AND pla_erup	= paramPla
		AND rut_erup	= paramRuta
		AND fec_erup	= paramFecha
		AND fliq_erup	= paramLiq;
		
UPDATE	corte_rut
SET		lei_crut		= paramlin,
		cta_crut		= paramlfi,
		pti_crut		= parampin,
		ptf_crut 		= parampfi
WHERE	cia_crut		= paramCia
		AND pla_crut	= paramPla
		AND rut_crut	= paramRuta
		AND fec_crut	= paramFecha
		AND fliq_crut	= paramLiq;
		
LET vobserlog = 'MatchLiq SE ACTUALIZARON LECTURAS Y PORCENTAJES INICIALES Y FINALES DE LA LIQUIDACION[' || paramLiq || ']';
INSERT INTO log 
VALUES(CURRENT,vobserlog,paramUsr);


END PROCEDURE;			