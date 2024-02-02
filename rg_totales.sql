DROP PROCEDURE rg_totales;

EXECUTE PROCEDURE rg_totales('2024-01-01','2024-01-22');

CREATE PROCEDURE rg_totales
(
	paramFecIni DATE,
	paramFecFin DATE
)
RETURNING 
	DECIMAL(16,2), -- VENTA ESTACIONARIO
	DECIMAL(16,2), -- VENTA PORTATIL
	DECIMAL(16,2), -- VENTA CARBURACION
	DECIMAL(16,2), -- ASISTENCIA
	DECIMAL(16,2), -- TOTAL FACTURADO
	DECIMAL(16,2), -- SUBTOTAL FACTURADO
	DECIMAL(16,2), -- IVA FACTURADO
	DECIMAL(16,2), -- TOTAL ASISTENCIA FACTURADO
	DECIMAL(16,2), -- SUBTOTAL ASISTENCIA FACTURADO
	DECIMAL(16,2), -- IVA ASISTENCIA FACTURADO
	DECIMAL(16,2), -- TOTAL FACTURADO PUBLICO GENERAL
	DECIMAL(16,2), -- SUBTOTAL FACTURADO PUBLICO GENERAL
	DECIMAL(16,2), -- IVA FACTURADO PUBLICO GENERAL
	DECIMAL(16,2), -- TOTAL ASISTENCIA FACTURADO PUBLICO GENERAL
	DECIMAL(16,2), -- SUBTOTAL ASISTENCIA FACTURADO PUBLICO GENERAL
	DECIMAL(16,2), -- IVA ASISTENCIA FACTURADO PUBLICO GENERAL
	DECIMAL(16,2), -- TOTAL NOTAS DE CREDITO EFECTIVO
	DECIMAL(16,2), -- SUBTOTAL NOTAS DE CREDITO EFECTIVO
	DECIMAL(16,2), -- IVA NOTAS DE CREDITO EFECTIVO
	DECIMAL(16,2), -- TOTAL NOTAS DE CREDITO
	DECIMAL(16,2), -- SUBTOTAL NOTAS DE CREDITO
	DECIMAL(16,2), -- IVANOTAS DE CREDITO
	DECIMAL(16,2), -- TOTAL FACTURAS CANCELADAS
	DECIMAL(16,2), -- SUBTOTAL FACTURAS CANCELADAS
	DECIMAL(16,2), -- IVA FACTURAS CANCELADAS
	DECIMAL(16,2), -- TOTAL ASISTENCIA FACTURAS CANCELADAS
	DECIMAL(16,2), -- SUBTOTAL ASISTENCIA FACTURAS CANCELADAS
	DECIMAL(16,2), -- IVA ASISTENCIA FACTURAS CANCELADAS
	DECIMAL(16,2), -- TOTAL VENTA EFECTIVO
	DECIMAL(16,2), -- SUBTOTAL VENTA EFECTIVO
	DECIMAL(16,2), -- IVA VENTA EFECTIVO
	DECIMAL(16,2), -- TOTAL ASISTENCIA EFECTIVO
	DECIMAL(16,2), -- SUBTOTAL ASISTENCIA EFECTIVO
	DECIMAL(16,2), -- IVA ASISTENCIA EFECTIVO
	DECIMAL(16,2), -- TOTAL COBRANZA(PAGO BANCOS, CHEQUE, EFECTIVO)
	DECIMAL(16,2), -- TOTAL COBRANZA
	DECIMAL(16,2), -- SUBTOTAL COBRANZA
	DECIMAL(16,2), -- IVA COBRANZA
	DECIMAL(16,2), -- TOTAL COBRANZA CHEQUE DEVUELTO
	DECIMAL(16,2), -- SUBTOTAL COBRANZA CHEQUE DEVUELTO
	DECIMAL(16,2), -- IVA COBRANZA CHEQUE DEVUELTO
	DECIMAL(16,2), -- CREDITO INGRESADO
	DECIMAL(16,2), -- TOTAL CHEQUE DEVUELTO
	DECIMAL(16,2), -- SUBTOTAL CHEQUE DEVUELTO
	DECIMAL(16,2), -- IVA CHEQUE DEVUELTO	
	DECIMAL(16,2), -- TOTAL DEUDORES ABONO
	DECIMAL(16,2), -- SUBTOTAL DEUDORES ABONO
	DECIMAL(16,2), -- IVA DEUDORES ABONO	
	DECIMAL(16,2), -- TOTAL DEUDORES CREDITO
	DECIMAL(16,2), -- SUBTOTAL DEUDORES CREDITO
	DECIMAL(16,2), -- IVA DEUDORES CREDITO	
	DECIMAL(16,2), -- TOTAL COMISIONES PAGADAS
	DECIMAL(16,2), -- SUBTOTAL COMISIONES PAGADAS
	DECIMAL(16,2), -- IVA COMISIONES PAGADAS
	DECIMAL(16,2), -- TOTAL INTERESES PAGADOS
	DECIMAL(16,2), -- SUBTOTAL INTERESES PAGADOS
	DECIMAL(16,2), -- IVA INTERESES PAGADOS
	DECIMAL(16,2), -- TOTAL PAGO EN BIENES
	DECIMAL(16,2), -- SUBTOTAL PAGO EN BIENES
	DECIMAL(16,2), -- IVA PAGO EN BIENES
	DECIMAL(16,2), -- TOTAL ANTICIPOS RECIBIDOS
	DECIMAL(16,2), -- SUBTOTAL ANTICIPOS RECIBIDOS
	DECIMAL(16,2), -- IVA ANTICIPOS RECIBIDOS
	DECIMAL(16,2), -- TOTAL ANTICIPOS APLICADOS
	DECIMAL(16,2), -- SUBTOTAL ANTICIPOS APLICADOS
	DECIMAL(16,2), -- IVA ANTICIPOS APLICADOS
	DECIMAL(16,2), -- TOTAL DONATIVOS
	DECIMAL(16,2), -- SUBTOTAL DONATIVOS
	DECIMAL(16,2); -- IVA DONATIVOS
	
DEFINE vvtaest    	DECIMAL(16,2); -- VENTA ESTACIONARIO
DEFINE vvtacil    	DECIMAL(16,2); -- VENTA PORTATIL
DEFINE vasiscil    	DECIMAL(16,2); -- ASISTENCIA CILINDRO
DEFINE vvtaand    	DECIMAL(16,2); -- VENTA ANDEN
DEFINE vvtadesd    	DECIMAL(16,2); -- VENTA ANDEN
DEFINE vvtacar    	DECIMAL(16,2); -- VENTA CARBURACION
DEFINE vvtamed    	DECIMAL(16,2); -- VENTA CARBURACION
DEFINE vasismed    	DECIMAL(16,2); -- ASISTENCIA MEDIDOR
DEFINE vtotasis   	DECIMAL(16,2); -- TOTAL ASISTENCIA
DEFINE vtotfac    	DECIMAL(16,2); -- TOTAL DE FACTURADO
DEFINE vstotfac   	DECIMAL(16,2); -- SUBTOTAL FACTURADO
DEFINE vivafac    	DECIMAL(16,2); -- IVA FACTURADO
DEFINE vatotfac   	DECIMAL(16,2); -- TOTAL ASISTENCIA DE FACTURADO
DEFINE vastotfac  	DECIMAL(16,2); -- SUBTOTAL ASISTENCIA FACTURADO
DEFINE vaivafac   	DECIMAL(16,2); -- IVA ASISTENCIA FACTURADO
DEFINE vptotfac   	DECIMAL(16,2); -- TOTAL DE FACTURADO PUBLICO GENERAL
DEFINE vpstotfac  	DECIMAL(16,2); -- SUBTOTAL FACTURADO PUBLICO GENERAL
DEFINE vpivafac   	DECIMAL(16,2); -- IVA FACTURADO PUBLICO GENERAL
DEFINE vpatotfac  	DECIMAL(16,2); -- TOTAL ASISTENCIA DE FACTURADO PUBLICO GENERAL
DEFINE vpastotfac 	DECIMAL(16,2); -- SUBTOTAL ASISTENCIA FACTURADO PUBLICO GENERAL
DEFINE vpaivafac  	DECIMAL(16,2); -- IVA ASISTENCIA FACTURADO PUBLICO GENERAL
DEFINE venctotefe  	DECIMAL(16,2); -- TOTAL NOTAS DE CREDITO EFECTIVO(BONIFICACION FECTIVO)
DEFINE vencstotefe 	DECIMAL(16,2); -- SUBTOTAL NOTAS DE CREDITO EFECTIVO
DEFINE vencivaefe  	DECIMAL(16,2); -- IVA NOTAS DE CREDITO EFECTIVO
DEFINE vcnctotcre  	DECIMAL(16,2); -- TOTAL NOTAS DE CREDITO A CREDITO(BONIFICACION CREDITO)
DEFINE vcncstotcre 	DECIMAL(16,2); -- SUBTOTALNOTAS DE CREDITO A CREDITO
DEFINE vcncivacre  	DECIMAL(16,2); -- IVA OTAS DE CREDITO A CREDITO
DEFINE vctotfac   	DECIMAL(16,2); -- TOTAL FACTURAS CANCELADAS
DEFINE vcstotfac  	DECIMAL(16,2); -- SUBTOTAL FACTURAS CANCELADAS
DEFINE vcivafac   	DECIMAL(16,2); -- IVA FACTURAS CANCELADAS
DEFINE vcatotfac  	DECIMAL(16,2); -- TOTAL ASISTENCIA DE FACTURAS CANCELADAS
DEFINE vcastotfac 	DECIMAL(16,2); -- SUBTOTAL ASISTENCIA FACTURAS CANCELADAS
DEFINE vcaivafac  	DECIMAL(16,2); -- IVA ASISTENCIA FACTURAS CANCELADAS	
DEFINE vvtotefe	  	DECIMAL(16,2); -- VENTA TOTAL EFECTIVO
DEFINE vvstotefe  	DECIMAL(16,2); -- VENTA SUBTOTAL EFECTIVO
DEFINE vvivaefe	  	DECIMAL(16,2); -- VENTA IVA EFECTIVO
DEFINE vatotefe  	DECIMAL(16,2); -- TOTAL ASISTENCIA EFECTIVO
DEFINE vastotefe  	DECIMAL(16,2); -- SUBTOTAL ASISTENCIA EFECTIVO
DEFINE vaivaefe  	DECIMAL(16,2); -- IVA ASISTENCIA EFECTIVO
DEFINE vcobtot  	DECIMAL(16,2); -- TOTAL COBRANZA(TODO)
DEFINE vcobrtot  	DECIMAL(16,2); -- TOTAL COBRANZA(PAGO BANCOS, CHEQUE, EFECTIVO)
DEFINE vcobrstot  	DECIMAL(16,2); -- SUBTOTAL COBRANZA
DEFINE vcobriva  	DECIMAL(16,2); -- IVA COBRANZA
DEFINE vcdcobrtot  	DECIMAL(16,2); -- TOTAL COBRANZA CHEQUE DEVUELTO
DEFINE vcdcobrstot  DECIMAL(16,2); -- SUBTOTAL COBRANZA CHEQUE DEVUELTO
DEFINE vcdcobriva  	DECIMAL(16,2); -- IVA COBRANZA CHEQUE DEVUELTO
DEFINE vcreding  	DECIMAL(16,2); -- CREDITO INGRESADO
DEFINE vcdingtot  	DECIMAL(16,2); -- TOTAL CHEQUE DEVUELTO
DEFINE vcdingstot   DECIMAL(16,2); -- SUBTOTAL CHEQUE DEVUELTO
DEFINE vcdingiva  	DECIMAL(16,2); -- IVA CHEQUE DEVUELTO
DEFINE vdatot  		DECIMAL(16,2); -- TOTAL DEUDORES ABONO
DEFINE vdastot  	DECIMAL(16,2); -- SUBTOTAL DEUDORES ABONO
DEFINE vdaiva	  	DECIMAL(16,2); -- IVA DEUDORES ABONO
DEFINE vdctot   	DECIMAL(16,2); -- TOTAL DEUDORES CREDITO
DEFINE vdcstot  	DECIMAL(16,2); -- SUBTOTAL DEUDORES CREDITO
DEFINE vdciva  	    DECIMAL(16,2); -- IVA DEUDORES CREDITO
DEFINE vcomptot  	DECIMAL(16,2); -- TOTAL COMISIONES PAGADAS
DEFINE vcompstot  	DECIMAL(16,2); -- SUBTOTAL COMISIONES PAGADAS
DEFINE vcompiva  	DECIMAL(16,2); -- IVA COMISIONES PAGADAS
DEFINE vintptot  	DECIMAL(16,2); -- TOTAL INTERESES PAGADOS
DEFINE vintpstot  	DECIMAL(16,2); -- SUBTOTAL INTERESES PAGADOS
DEFINE vintpiva  	DECIMAL(16,2); -- IVA INTERESES PAGADOS
DEFINE vpagbtot  	DECIMAL(16,2); -- TOTAL PAGO EN BIENES
DEFINE vpagbstot  	DECIMAL(16,2); -- SUBTOTAL PAGO EN BIENES
DEFINE vpagbiva  	DECIMAL(16,2); -- IVA PAGO EN BIENES
DEFINE vantrtot  	DECIMAL(16,2); -- TOTAL ANTICIPOS RECIBIDOS
DEFINE vantrsstot  	DECIMAL(16,2); -- SUBTOTAL ANTICIPOS RECIBIDOS
DEFINE vantriva  	DECIMAL(16,2); -- IVA ANTICIPOS RECIBIDOS
DEFINE vantatot  	DECIMAL(16,2); -- TOTAL ANTICIPOS APLICADOS
DEFINE vantastot  	DECIMAL(16,2); -- SUBTOTAL ANTICIPOS APLICADOS
DEFINE vantaiva  	DECIMAL(16,2); -- IVA ANTICIPOS APLICADOS
DEFINE vdonatot  	DECIMAL(16,2); -- TOTAL DONATIVOS
DEFINE vdonastot  	DECIMAL(16,2); -- SUBTOTAL DONATIVOS
DEFINE vdonaiva  	DECIMAL(16,2); -- IVA DONATIVOS

DEFINE xfecd      DATE;
DEFINE xdia       SMALLINT;
DEFINE xdia2      SMALLINT;
DEFINE xmes1      SMALLINT;
DEFINE xanio1     SMALLINT;
DEFINE viva  	  DECIMAL(16,2); -- IVA 
DEFINE vsiva  	  DECIMAL(16,2); -- SUBTOTAL IVA 

LET viva = 0.16;
LET vsiva = 1.16;

LET xfecd  = TODAY;
LET xmes1  = MONTH(xfecd);
LET xanio1 = YEAR(xfecd);
LET xdia   = DAY(xfecd);
IF xmes1 = 1 or xmes1 = 3 or xmes1 = 5 or xmes1 = 7 or xmes1 = 8 or
  xmes1 = 10 or xmes1 = 12 THEN
  LET xdia2 = 31;
ELSE 
  IF xmes1 = 4 or xmes1 = 6 or xmes1 = 9 or xmes1 = 11 THEN
     LET xdia2 = 30;
  ELSE
     IF xanio1 / 4 = 0 THEN
        LET xdia2 = 29;
     ELSE
        LET xdia2 = 28;
     END IF;
  END IF;
END IF;
LET xfecd  = xfecd - xdia2 - xdia + 1;

-- VENTA ESTACIONARIO
IF paramFecIni < xfecd THEN
  	SELECT	NVL(SUM(CASE WHEN tip_nvta = 'E' THEN impt_nvta ELSE 0 END),0.00),
         	NVL(SUM(CASE WHEN tip_nvta = 'B' THEN impt_nvta ELSE 0 END),0.00),
         	NVL(SUM(CASE WHEN asiste_nvta = 'S' THEN impasi_nvta ELSE 0 END),0.00)
    INTO 	vvtaest,vvtacar,vtotasis
    FROM 	urdnota_vta
    WHERE 	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin
       		AND ruta_nvta[1] = 'M'
	       	AND edo_nvta = 'A'
	       	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
ELSE
  	SELECT  NVL(SUM(CASE WHEN tip_nvta = 'E' THEN impt_nvta ELSE 0 END),0.00),
         	NVL(SUM(CASE WHEN tip_nvta = 'B' THEN impt_nvta ELSE 0 END),0.00),
     		NVL(SUM(CASE WHEN asiste_nvta = 'S' THEN impasi_nvta ELSE 0 END),0.00)
    INTO 	vvtaest,vvtacar,vtotasis
    FROM 	nota_vta
    WHERE 	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin
       		AND ruta_nvta[1] = 'M'
       		AND edo_nvta = 'A'
       		AND (aju_nvta IS NULL OR aju_nvta <> 'S');
END IF;

-- VENTA PORTATIL
SELECT	NVL(SUM(impt_eruc),0.00),NVL(SUM(impasi_eruc),0.00)
INTO 	vvtacil, vasiscil
FROM 	empxrutc
WHERE 	fec_eruc >= paramFecIni AND fec_eruc <= paramFecFin
		AND edo_eruc = 'C';
		
SELECT 	NVL(SUM(impasi_eruc),0.00)
INTO 	vasiscil
FROM 	empxrutcbaj
WHERE 	fec_eruc >= paramFecIni AND fec_eruc <= paramFecFin
		AND edo_eruc = 'C';

SELECT 	NVL(SUM(impt_vand),0.00)
INTO 	vvtaand
FROM 	venxand
WHERE 	fec_vand >= paramFecIni AND fec_vand <= paramFecFin
		AND edo_vand = 'C';

SELECT  NVL(SUM(impt_desd),0.00)
INTO    vvtadesd
FROM 	des_dir  
WHERE 	fec_desd >= paramFecIni AND fec_desd <= paramFecFin
		AND edo_desd = 'C';
		
LET vvtacil = vvtacil + vvtaand + vvtadesd;		
        
-- VENTA CARBURACION
SELECT 	NVL(SUM(impt_vmed),0.00),NVL(SUM(impasi_vmed),0.00)
INTO 	vvtamed,vasismed
FROM 	venxmed
WHERE 	fec_vmed >= paramFecIni AND fec_vmed <= paramFecFin
		AND edo_vmed = 'C';

LET vvtacar = vvtacar + vvtamed;

-- TOTAL ASISTENCIA	
LET vtotasis = vtotasis + vasiscil + vasismed;

-- TOTAL FACTURACION
SELECT	NVL(SUM(impt_fac),0), NVL(SUM(simp_fac),0), NVL(SUM(iva_fac),0)
INTO    vtotfac,vstotfac,vivafac
FROM	factura
WHERE	fec_fac >= paramFecIni and fec_fac <= paramFecFin
		AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND faccer_fac = 'N'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0);
     	
-- TOTAL ASISTENCIA FACTURADA 	
SELECT 	NVL(SUM(NVL(impasi_dfac,0.00)),0.00), NVL(SUM(NVL(impasi_dfac,0.00) / vsiva),0.00), 
		NVL(SUM(NVL(impasi_dfac,0.00) / vsiva) * viva,0.00)
INTO    vatotfac,vastotfac,vaivafac
FROM 	factura,det_fac
WHERE 	fec_fac >= paramFecIni AND fec_fac <= paramFecFin
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'   
  		AND faccer_fac = 'N'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	AND fol_fac = fol_dfac
     	AND ser_fac = ser_dfac
     	AND cia_fac = cia_dfac
     	AND pla_fac = pla_dfac;

-- SE QUITA LA ASISTENCIA DE LA FACTURACION
LET vtotfac = vtotfac -  vatotfac;
LET vstotfac = vstotfac - vastotfac;
LET vivafac = vivafac - vaivafac;

-- TOTAL FACTURACION PUBLICO EN GENERAL
SELECT	NVL(SUM(impt_fac),0.00), NVL(SUM(simp_fac),0.00), NVL(SUM(iva_fac),0.00)
INTO    vptotfac,vpstotfac,vpivafac
FROM	factura
WHERE	fec_fac >= paramFecIni and fec_fac <= paramFecFin
		AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND faccer_fac = 'S'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0);

-- TOAL ASISTENCIA FACTURADA PUBLICO EN GENERAl
SELECT 	NVL(SUM(NVL(impasi_dfac,0.00)),0.00), NVL(SUM(NVL(impasi_dfac,0.00) / vsiva),0.00),
		NVL(SUM(NVL(impasi_dfac,0.00) / vsiva) * viva,0.00)
INTO    vpatotfac,vpastotfac,vpaivafac
FROM 	factura,det_fac
WHERE 	fec_fac >= paramFecIni AND fec_fac <= paramFecFin
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'   
  		AND faccer_fac = 'S'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	AND fol_fac = fol_dfac
     	AND ser_fac = ser_dfac
     	AND cia_fac = cia_dfac
     	AND pla_fac = pla_dfac;   
 
-- SE QUITA LA ASISTENCIA DE LA FACTURACION PUBLICO EN GENERAL
LET vptotfac = vptotfac -  vpatotfac;
LET vpstotfac = vpstotfac - vpastotfac;
LET vpivafac = vpivafac - vpaivafac;

-- NOTAS CREDITO EFECTIVO
SELECT	NVL(SUM(impt_ncrd),0.00), NVL(SUM(simp_ncrd),0.00), NVL(SUM(iva_ncrd),0.00)
INTO 	venctotefe,vencstotefe,vencivaefe
FROM 	nota_crd
WHERE 	fec_ncrd >= paramFecIni AND fec_ncrd <= paramFecFin
		AND apl_ncrd = 'N'
		AnD edo_ncrd <> 'C'
		AND tdoc_ncrd = 'E'
		AND (tpa_ncrd = 'E' OR tpa_ncrd = 'X')
		AND impr_ncrd = 'E'
		AND (frnc_ncrd = 0 OR frnc_ncrd IS NULL);

-- NOTAS CREDITO A CREDITO
SELECT 	NVL(SUM(imp_mcxc),0.00), NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),	NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO 	vcnctotcre,vcncstotcre,vcncivacre
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
        AND (tpm_mcxc = '52' OR tpm_mcxc = '98')
        AND sta_mcxc <> 'C';
        
-- FACTURAS CANCELADAS 
SELECT 	NVL(SUM(impt_fac),0.00), NVL(SUM(simp_fac),0.00), NVL(SUM(iva_fac),0.00)
INTO	vctotfac,vcstotfac,vcivafac
FROM 	factura
WHERE 	feccan_fac >= paramFecIni  AND feccan_fac <= paramFecFin
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND edo_fac  = 'C'
     	AND faccer_fac = 'N'
     	AND fec_fac <> feccan_fac
     	AND (frf_fac IS NULL OR frf_fac = 0);

-- ASISTENCIA FACTURAS CANCELADAS
SELECT 	NVL(SUM(NVL(impasi_dfac,0.00)),0.00), NVL(SUM(NVL(impasi_dfac,0.00) / vsiva),0.00),
		NVL(SUM(NVL(impasi_dfac,0.00)) / vsiva * viva, 0.00)
INTO	vcatotfac,vcastotfac,vcaivafac
FROM 	factura,det_fac
WHERE 	feccan_fac >= paramFecIni AND feccan_fac <= paramFecFin
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'     
		AND edo_fac  = 'C'
     	AND faccer_fac = 'N'
     	AND fec_fac <> feccan_fac
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	AND fol_fac = fol_dfac
     	AND ser_fac = ser_dfac
     	AND cia_fac = cia_dfac
        AND pla_fac = pla_dfac;

--  COBRANZA(PAGO BANCOS, CHEQUE , EFECTIVO)
SELECT 	NVL(SUM(imp_mcxc),0.00)
INTO	vcobtot
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc >= '50';

--  COBRANZA(PAGO BANCOS, CHEQUE , EFECTIVO)
SELECT 	NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO	vcobrtot,vcobrstot,vcobriva
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc IN('50','51','58');

-- COBRANZA CHEQUES DEVUELTOS
SELECT  NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO	vcdcobrtot,vcdcobrstot,vcdcobriva
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND tip_mcxc = '03'
		AND tpm_mcxc >= '50'
		AND sta_mcxc <> 'C';

-- CREDITO INGRESADO
SELECT 	NVL(SUM(imp_mcxc),0.00)
INTO	vcreding
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni  AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tip_mcxc = '01'
		AND tpm_mcxc < '50';
		
-- CHEQUE DEVUELTO INGRESADO		
SELECT  NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO 	vcdingtot,vcdingstot,vcdingiva
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni  AND fec_mcxc <= paramFecFin
		AND tip_mcxc = '03'
		AND tpm_mcxc = '03'
		AND sta_mcxc <> 'C';
		
/*LET vvtotefe = 0.00;
LET vvstotefe = 0.00;
LET vvivaefe = 0.00;
LET vatotefe = 0.00;
LET vastotefe = 0.00;
LET vaivaefe = 0.00;*/

-- VENTAS EN EFECTIVO Y ASISTENCIA
LET vvtotefe = (vvtaest + vvtacar + vvtacil) - (vcreding + vcdingtot); 
LET vvstotefe =  vvtotefe / vsiva;
LET vvivaefe =  vvtotefe / vsiva * viva;

LET vatotefe = vtotasis;
LET vastotefe = NVL((NVL(vtotasis,0.00) / vsiva),0.00);
LET vaivaefe = NVL((NVL(vtotasis,0.00) / vsiva) * viva,0.00);

-- VENTAS EN EFECTIVO Y ASISTENCIA
/*SELECT	SUM(impt_nvta), SUM(simp_nvta), SUM(iva_nvta), SUM(impasi_nvta),NVL(SUM(NVL(impasi_nvta,0.00) / vsiva),0.00),
		NVL(SUM(NVL(impasi_nvta,0.00) / vsiva) * viva,0.00)
INTO	vvtotefe,vvstotefe,vvivaefe,vatotefe,vastotefe,vaivaefe
FROM	nota_vta
WHERE	fes_nvta >= paramFecIni and fes_nvta <= paramFecFin
		AND edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tpa_nvta NOT IN('C','G')
		AND tip_nvta IN('E','B','C','D','2','3','4');*/
		
-- DEUDORES ABONO Y CREDITO
SELECT  SUM(epo_cded), SUM(NVL(epo_cded,0.00) / vsiva), SUM(NVL(epo_cded,0.00) / vsiva) * viva,
		SUM(epo_crdd), SUM(NVL(epo_crdd,0.00) / vsiva), SUM(NVL(epo_crdd,0.00) / vsiva) * viva
INTO	vdatot,vdastot,vdaiva,vdctot,vdcstot,vdciva
FROM	e_posaj
WHERE   epo_fec >= paramFecIni and epo_fec <= paramFecFin;

-- COMISIONES PAGADAS
SELECT  NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO 	vcomptot,vcompstot,vcompiva
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '60';
		
-- INTERESES PAGADOS
SELECT  NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO 	vintptot,vintpstot,vintpiva
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '61';
		
-- PAGO EN BIENES
SELECT  NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO 	vpagbtot,vpagbstot,vpagbiva
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '62';

-- ANTICIPOS RECIBIDOS
SELECT 	NVL(SUM(imp_mant),0.00),NVL(SUM(NVL(imp_mant,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mant,0.00) / vsiva) * viva,0.00)
INTO 	vantrtot,vantrsstot,vantriva
FROM 	mov_ant
WHERE 	fec_mant >= paramFecIni AND fec_mant <= paramFecFin
		AND sta_mant = 'A'
		AND tpm_mant = '53';

-- ANTICIPOS APLICADOS
SELECT 	NVL(SUM(imp_mant),0.00),NVL(SUM(NVL(imp_mant,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mant,0.00) / vsiva) * viva,0.00)
INTO 	vantatot,vantastot,vantaiva
FROM 	mov_ant
WHERE 	fec_mant >= paramFecIni AND fec_mant <= paramFecFin
		AND sta_mant = 'A'
		AND tpm_mant = '99';

-- DONATIVOS
SELECT  NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO 	vdonatot,vdonastot,vdonaiva
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '63';	
		
RETURN  vvtaest,vvtacil,vvtacar,vtotasis,vtotfac,vstotfac,vivafac,vatotfac,vastotfac,vaivafac,
		vptotfac,vpstotfac,vpivafac,vpatotfac,vpastotfac,vpaivafac,venctotefe,vencstotefe,vencivaefe,vcnctotcre,
		vcncstotcre,vcncivacre,vctotfac,vcstotfac,vcivafac,vcatotfac,vcastotfac,vcaivafac,vvtotefe,vvstotefe,
		vvivaefe,vatotefe,vastotefe,vaivaefe,vcobtot,vcobrtot,vcobrstot,vcobriva,vcdcobrtot,vcdcobrstot,
		vcdcobriva,vcreding,vcdingtot,vcdingstot,vcdingiva,vdatot,vdastot,vdaiva,vdctot,vdcstot,
		vdciva,vcomptot,vcompstot,vcompiva,vintptot,vintpstot,vintpiva,vpagbtot,vpagbstot,vpagbiva,
		vantrtot,vantrsstot,vantriva,vantatot,vantastot,vantaiva,vdonatot,vdonastot,vdonaiva;

END PROCEDURE; 

SELECT	SUM(impt_nvta)
FROM	nota_vta
WHERE	fes_nvta >= '2024-01-01' and fes_nvta <= '2024-01-22' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E');

SELECT	SUM(impasi_nvta)
FROM	nota_vta
WHERE	fes_nvta >= '2024-01-01' and fes_nvta <= '2024-01-22' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S');
				
SELECT SUM(CASE WHEN tip_nvta = 'E' THEN impt_nvta ELSE 0 END),
     SUM(CASE WHEN tip_nvta = 'B' THEN impt_nvta ELSE 0 END),
     SUM(CASE WHEN asiste_nvta = 'S' THEN impasi_nvta ELSE 0 END)
 FROM nota_vta
 WHERE fes_nvta >= '2024-01-22' AND fes_nvta <= '2024-01-22'
   AND ruta_nvta[1] = 'M'
   AND edo_nvta = 'A'
   AND (aju_nvta IS NULL OR aju_nvta <> 'S');
		
SELECT 	NVL(SUM(NVL(impasi_dfac,0)),0), NVL(SUM(NVL(impasi_dfac,0) / 1.16),0),NVL(SUM(NVL(impasi_dfac,0) / 1.16) * 0.16,0)
FROM 	factura,det_fac
WHERE 	fec_fac >= '2024-01-22' AND fec_fac <= '2024-01-22'
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'   
  		AND faccer_fac = 'S'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	AND fol_fac = fol_dfac
     	AND ser_fac = ser_dfac
     	AND cia_fac = cia_dfac
     	AND pla_fac = pla_dfac; 
     	
SELECT 	NVL(SUM(impasi_dfac),0), NVL(SUM(impasi_dfac / 1.16),0),NVL(SUM(impasi_dfac / 1.16) * 0.16,0)
FROM 	factura,det_fac
WHERE 	fec_fac >= '2024-01-22' AND fec_fac <= '2024-01-22'
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'   
  		AND faccer_fac = 'S'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	AND fol_fac = fol_dfac
     	AND ser_fac = ser_dfac
     	AND cia_fac = cia_dfac
     	AND pla_fac = pla_dfac; 
     	
 
SELECT	SUM(impt_nvta), SUM(impasi_nvta)
FROM	nota_vta
WHERE	fes_nvta >= '2024-01-22' and fes_nvta <= '2024-01-22' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tpa_nvta NOT IN('C','G')
		AND tip_nvta IN('E','B','C','D','2','3','4');
		
SELECT	SUM(impt_nvta), SUM(simp_nvta), SUM(iva_nvta), SUM(impasi_nvta),NVL(SUM(NVL(impasi_nvta,0.00) / 1.16),0.00),
		NVL(SUM(NVL(impasi_nvta,0.00) / 1.16) * 0.16,0.00)
FROM	nota_vta
WHERE	fes_nvta >= '2024-01-01' and fes_nvta <= '2024-01-22'
		AND edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tpa_nvta NOT IN('C','G')
		AND tip_nvta IN('E','B','C','D','2','3','4');
		
select	*
from	empxrutp
where	fec_erup  >= '2024-01-01' and fes_nvta <= '2024-01-22'

		
SELECT 	NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / 1.16),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / 1.16) * 0.16,0.00)
FROM 	mov_cxc
WHERE 	fec_mcxc >= '2024-01-21' AND fec_mcxc <= '2024-01-21'
		AND sta_mcxc = 'A'
		AND tpm_mcxc IN('50','51','58');

SELECT SUM(imp_mcxc)
FROM mov_cxc
WHERE fec_mcxc >= '2023-01-21' AND fec_mcxc <= '2024-01-21'
AND tip_mcxc = '03'
AND tpm_mcxc >= '50'
AND sta_mcxc <> 'C';

SELECT 	NVL(SUM(imp_mcxc),0.00)
FROM 	mov_cxc
WHERE 	fec_mcxc >= '2024-01-22'  AND fec_mcxc <= '2024-01-22' 
		AND sta_mcxc = 'A'
		AND tip_mcxc = '01'
		AND tpm_mcxc < '50';
		
SELECT sum(imp_mcxc)
INTO 	ximp_comi
FROM 	mov_cxc
WHERE 	fec_mcxc >= '2024-01-22' AND fec_mcxc <= '2024-01-22'
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '60';	 
		
		
select	15892367.47, 15892367.47 / 1.16, 15892367.47 / 1.16 * 0.16
from    datos