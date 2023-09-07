CREATE PROCEDURE Qry_DifLiq
(
	paramCia   CHAR(2),
	paramPla   CHAR(2),
	paramFecha DATE
)
RETURNING 
 INTEGER,
 CHAR(4), 
 CHAR(7), 
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL;

DEFINE vfliq		INTEGER; 
DEFINE vruta		CHAR(4); 
DEFINE vunidad		CHAR(7); 
DEFINE vemplei		DECIMAL; 
DEFINE vemplef		DECIMAL; 
DEFINE vemppti		DECIMAL; 
DEFINE vempptf		DECIMAL; 
DEFINE vcorlei		DECIMAL; 
DEFINE vcorlef		DECIMAL; 
DEFINE vcorpti		DECIMAL; 
DEFINE vcorptf		DECIMAL;  

FOREACH cursorLiq FOR
	SELECT	empxrutp.fliq_erup,
			empxrutp.rut_erup,
			empxrutp.uni_erup,
			empxrutp.lin_erup,
			empxrutp.lfi_erup,
			empxrutp.pin_erup,
			empxrutp.pfi_erup,
			corte_rut.lei_crut,
			corte_rut.cta_crut,
			corte_rut.pti_crut,
			corte_rut.ptf_crut
	INTO   	vfliq,
			vruta,
			vunidad,			
			vemplei,
			vemplef,
			vemppti,
			vempptf,
			vcorlei,
			vcorlef,
			vcorpti,
			vcorptf
	FROM   	empxrutp,
			corte_rut
	WHERE  	empxrutp.fliq_erup 			= corte_rut.fliq_crut
			AND empxrutp.cia_erup		= paramCia
			AND empxrutp.pla_erup		= paramPla
			AND empxrutp.fec_erup		= paramFecha
			AND empxrutp.fec_erup		= corte_rut.fec_crut
			AND (empxrutp.lin_erup 		<> corte_rut.lei_crut
				 OR empxrutp.lfi_erup	<> corte_rut.cta_crut
				 OR empxrutp.pin_erup	<> corte_rut.pti_crut
				 OR empxrutp.pfi_erup	<> corte_rut.ptf_crut)
	ORDER BY empxrutp.rut_erup
	
	RETURN	vfliq,
			vruta,
			vunidad,
			vemplei,
			vemplef,
			vemppti,
			vempptf,
			vcorlei,
			vcorlef,
			vcorpti,
			vcorpti
	WITH RESUME;
END FOREACH; 

END PROCEDURE;