DROP PROCEDURE rg_totalesp;

EXECUTE PROCEDURE rg_totalesp('2024-10-02','2024-10-02');

CREATE PROCEDURE rg_totalesp
(
	paramFecIni DATE,
	paramFecFin DATE
)
RETURNING 
	DECIMAL(16,2), -- TOTAL VENTA ESTACIONARIO
	DECIMAL(16,2), -- SUBTOTAL VENTA ESTACIONARIO
	DECIMAL(16,2), -- IVA VENTA ESTACIONARIO
	DECIMAL(16,2), -- TOTAL VENTA PORTATIL
	DECIMAL(16,2), -- SUBTOTAL VENTA PORTATIL
	DECIMAL(16,2), -- IVA VENTA PORTATIL
	DECIMAL(16,2), -- TOTAL VENTA CARBURACION
	DECIMAL(16,2), -- SUBTOTAL VENTA CARBURACION
	DECIMAL(16,2), -- IVA VENTA CARBURACION
	DECIMAL(16,2), -- TOTAL FACTURADO
	DECIMAL(16,2), -- SUBTOTAL FACTURADO
	DECIMAL(16,2), -- IVA FACTURADO	
	DECIMAL(16,2), -- TOTAL NOTAS DE CREDITO EFECTIVO
	DECIMAL(16,2), -- SUBTOTAL NOTAS DE CREDITO EFECTIVO
	DECIMAL(16,2), -- IVA NOTAS DE CREDITO EFECTIVO
	DECIMAL(16,2), -- TOTAL NOTAS DE CREDITO
	DECIMAL(16,2), -- SUBTOTAL NOTAS DE CREDITO
	DECIMAL(16,2), -- IVANOTAS DE CREDITO
	DECIMAL(16,2), -- TOTAL VENTA EFECTIVO
	DECIMAL(16,2), -- SUBTOTAL VENTA EFECTIVO
	DECIMAL(16,2), -- IVA VENTA EFECTIVO	
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
	DECIMAL(16,2), -- IVA DONATIVOS
	DECIMAL(16,2), -- TOTAL FACTURAS CANCELADAS
	DECIMAL(16,2), -- SUBTOTAL FACTURAS CANCELADAS
	DECIMAL(16,2); -- IVA FACTURAS CANCELADAS
	
DEFINE vtotvest    	DECIMAL(16,2); -- TOTAL VENTA ESTACIONARIO
DEFINE vstotvest   	DECIMAL(16,2); -- SUBTOTAL VENTA ESTACIONARIO
DEFINE vivavest     DECIMAL(16,2); -- IVA VENTA ESTACIONARIO
DEFINE vtotvcil    	DECIMAL(16,2); -- TOTAL VENTA PORTATIL
DEFINE vstotvcil   	DECIMAL(16,2); -- SUBTOTAL VENTA PORTATIL
DEFINE vivavcil    	DECIMAL(16,2); -- IVA VENTA PORTATIL
DEFINE vtotvcar    	DECIMAL(16,2); -- TOTAL VENTA CARBURACION
DEFINE vstotvcar   	DECIMAL(16,2); -- SUBTOTAL VENTA CARBURACION
DEFINE vivavcar    	DECIMAL(16,2); -- IVA VENTA CARBURACION
DEFINE vtotfac    	DECIMAL(16,2); -- TOTAL DE FACTURADO
DEFINE vstotfac   	DECIMAL(16,2); -- SUBTOTAL FACTURADO
DEFINE vivafac    	DECIMAL(16,2); -- IVA FACTURADO
DEFINE venctotefe  	DECIMAL(16,2); -- TOTAL NOTAS DE CREDITO EFECTIVO(BONIFICACION FECTIVO)
DEFINE vencstotefe 	DECIMAL(16,2); -- SUBTOTAL NOTAS DE CREDITO EFECTIVO
DEFINE vencivaefe  	DECIMAL(16,2); -- IVA NOTAS DE CREDITO EFECTIVO
DEFINE vcnctotcre  	DECIMAL(16,2); -- TOTAL NOTAS DE CREDITO A CREDITO(BONIFICACION CREDITO)
DEFINE vcncstotcre 	DECIMAL(16,2); -- SUBTOTALNOTAS DE CREDITO A CREDITO
DEFINE vcncivacre  	DECIMAL(16,2); -- IVA NOTAS DE CREDITO A CREDITO
DEFINE vvtotefe	  	DECIMAL(16,2); -- VENTA TOTAL EFECTIVO
DEFINE vvstotefe  	DECIMAL(16,2); -- VENTA SUBTOTAL EFECTIVO
DEFINE vvivaefe	  	DECIMAL(16,2); -- VENTA IVA EFECTIVO
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
DEFINE vtotfacc  	DECIMAL(16,2); -- TOTAL FACTURAS CANCELADAS
DEFINE vstotfacc  	DECIMAL(16,2); -- SUBTOTAL FACTURAS CANCELADAS
DEFINE vivafacc  	DECIMAL(16,2); -- IVA FACTURAS CANCELADAS
DEFINE vcreajutot  	DECIMAL(16,2); -- TOTAL VTA CREDITO AJU
DEFINE vcreajustot 	DECIMAL(16,2); -- TOTAL VTA CREDITO AJU
DEFINE vcreajuiva 	DECIMAL(16,2); -- IVA VTA CREDITO AJU

DEFINE xfecd      DATE;
DEFINE xdia       SMALLINT;
DEFINE xdia2      SMALLINT;
DEFINE xndias     SMALLINT;
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
--LET xndias = DAY(TODAY - xdia);
LET xfecd  = xfecd - xdia2 - xdia + 1;
--LET xfecd  = xfecd - xndias - xdia + 1;

-- VENTA ESTACIONARIO
IF paramFecIni < xfecd THEN
  	SELECT	NVL(SUM(impt_nvta),0.00)
    INTO 	vtotvest
    FROM 	urdnota_vta
    WHERE 	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin
			AND tip_nvta = 'E'
	       	AND edo_nvta = 'A'
	       	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
ELSE
  	SELECT  NVL(SUM(impt_nvta),0.00)
    INTO 	vtotvest
    FROM 	nota_vta
    WHERE 	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin
       		AND tip_nvta = 'E'
	       	AND edo_nvta = 'A'
	       	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
END IF;

LET vivavest = NVL((vtotvest / vsiva * viva),0.00);
LET vstotvest = vtotvest - vivavest;

-- VENTA PORTATIL
IF paramFecIni < xfecd THEN
  	SELECT	NVL(SUM(impt_nvta),0.00)
    INTO 	vtotvcil
    FROM 	urdnota_vta
    WHERE 	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin
			AND tip_nvta IN('C','D','2','3','4')
	       	AND edo_nvta = 'A'
	       	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
ELSE
  	SELECT  NVL(SUM(impt_nvta),0.00)
    INTO 	vtotvcil
    FROM 	nota_vta
    WHERE 	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin
       		AND tip_nvta IN('C','D','2','3','4')
	       	AND edo_nvta = 'A'
	       	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
END IF;

LET vivavcil = NVL((vtotvcil / vsiva * viva),0.00);
LET vstotvcil = vtotvcil - vivavcil;
        
-- VENTA CARBURACION
IF paramFecIni < xfecd THEN
  	SELECT	NVL(SUM(impt_nvta),0.00)
    INTO 	vtotvcar
    FROM 	urdnota_vta
    WHERE 	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin
			AND tip_nvta IN('B')
	       	AND edo_nvta = 'A'
	       	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
ELSE
  	SELECT  NVL(SUM(impt_nvta),0.00)
    INTO 	vtotvcar
    FROM 	nota_vta
    WHERE 	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin
       		AND tip_nvta IN('B')
	       	AND edo_nvta = 'A'
	       	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
END IF;

LET vivavcar = NVL((vtotvcar / vsiva * viva),0.00);
LET vstotvcar = vtotvcar - vivavcar;

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
SELECT 	NVL(SUM(imp_mcxc),0.00)
INTO 	vcnctotcre
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
        AND (tpm_mcxc = '52' OR tpm_mcxc = '98')
        AND sta_mcxc <> 'C';
        
LET vcncivacre = NVL((vcnctotcre / vsiva * viva),0.00);
LET vcncstotcre = vcnctotcre - vcncivacre;

--  COBRANZA(TOTAL)
SELECT 	NVL(SUM(imp_mcxc),0.00)
INTO	vcobtot
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc >= '50';

--  COBRANZA(PAGO BANCOS, CHEQUE , EFECTIVO, ANTICIPOS, CHEQUE POSFECHADO, COMPENSACIONES)
SELECT 	NVL(SUM(imp_mcxc),0.00)
INTO	vcobrtot
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tip_mcxc = '01'
		AND tpm_mcxc IN('50','51','55','56','58','60','61','62','63');
		
LET vcobriva = NVL((vcobrtot / vsiva * viva),0.00);
LET vcobrstot = vcobrtot - vcobriva;

-- COBRANZA CHEQUES DEVUELTOS
SELECT  NVL(SUM(imp_mcxc),0.00)
INTO	vcdcobrtot
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND tip_mcxc = '03'
		AND tpm_mcxc >= '50'
		AND sta_mcxc <> 'C';

LET vcdcobriva = NVL((vcdcobrtot / vsiva * viva),0.00);
LET vcdcobrstot = vcdcobrtot - vcdcobriva;

-- CREDITO INGRESADO
SELECT 	NVL(SUM(imp_mcxc),0.00)
INTO	vcreding
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni  AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tip_mcxc = '01'
		AND tpm_mcxc < '50';
		
-- CHEQUE DEVUELTO INGRESADO		
SELECT  NVL(SUM(imp_mcxc),0.00)
INTO 	vcdingtot
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni  AND fec_mcxc <= paramFecFin
		AND tip_mcxc = '03'
		AND tpm_mcxc = '03'
		AND sta_mcxc <> 'C';
		
LET vcdingiva = NVL((vcdingtot / vsiva * viva),0.00);
LET vcdingstot = vcdingtot - vcdingiva;
		
-- VENTAS EN EFECTIVO Y ASISTENCIA
IF paramFecIni < xfecd THEN
  	SELECT	NVL(SUM(impt_nvta),0.00),NVL(SUM(simp_nvta),0.00), NVL(SUM(iva_nvta),0.00)
	INTO	vvtotefe,vvstotefe,vvivaefe
	FROM    urdnota_vta
	WHERE	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin AND edo_nvta = 'A' 
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND tip_nvta IN('B','C','D','E','2','3','4') AND tpa_nvta NOT IN('C','G');
			
	SELECT	NVL(SUM(impt_nvta),0.00), NVL(SUM(simp_nvta),0.00), NVL(SUM(iva_nvta),0.00)
	INTO	vcreajutot,vcreajustot,vcreajuiva
	FROM    urdnota_vta
	WHERE	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin AND edo_nvta = 'A' 
			AND aju_nvta='S'
			AND tip_nvta IN('B','C','D','E','2','3','4') AND tpa_nvta IN('C','G');
ELSE
  	SELECT	NVL(SUM(impt_nvta),0.00),NVL(SUM(simp_nvta),0.00), NVL(SUM(iva_nvta),0.00)
	INTO	vvtotefe,vvstotefe,vvivaefe
	FROM    nota_vta
	WHERE	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin AND edo_nvta = 'A' 
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND tip_nvta IN('B','C','D','E','2','3','4') AND tpa_nvta NOT IN('C','G');
			
	SELECT	NVL(SUM(impt_nvta),0.00), NVL(SUM(simp_nvta),0.00), NVL(SUM(iva_nvta),0.00)
	INTO	vcreajutot,vcreajustot,vcreajuiva
	FROM    nota_vta
	WHERE	fes_nvta >= paramFecIni AND fes_nvta <= paramFecFin AND edo_nvta = 'A' 
			AND aju_nvta='S'
			AND tip_nvta IN('B','C','D','E','2','3','4') AND tpa_nvta IN('C','G');
END IF;
LET vvtotefe = vvtotefe - vcreajutot;
LET vvstotefe = vvstotefe - vcreajustot;
LET vvivaefe = vvivaefe - vcreajuiva;

--LET vvivaefe = NVL((vvtotefe / vsiva * viva),0.00);
--LET vvstotefe = vvtotefe - vvivaefe;

-- DEUDORES ABONO Y CREDITO
SELECT  SUM(epo_cded),SUM(epo_crdd)
INTO	vdatot,vdctot
FROM	e_posaj
WHERE   epo_fec >= paramFecIni and epo_fec <= paramFecFin;

LET vdaiva = NVL((vdatot / vsiva * viva),0.00);
LET vdastot = vdatot - vdaiva;

LET vdciva = NVL((vdctot / vsiva * viva),0.00);
LET vdcstot = vdctot - vdciva;

-- COMISIONES PAGADAS
SELECT  NVL(SUM(imp_mcxc),0.00)
INTO 	vcomptot
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '60';

LET vcompiva = NVL((vcomptot / vsiva * viva),0.00);
LET vcompstot = vcomptot - vcompiva;
		
-- INTERESES PAGADOS
SELECT  NVL(SUM(imp_mcxc),0.00)
INTO 	vintptot
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '61';
		
LET vintpiva = NVL((vintptot / vsiva * viva),0.00);
LET vintpstot = vintptot - vintpiva;
		
-- PAGO EN BIENES
SELECT  NVL(SUM(imp_mcxc),0.00)
INTO 	vpagbtot
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '62';
		
LET vpagbiva = NVL((vpagbtot / vsiva * viva),0.00);
LET vpagbstot = vpagbtot - vpagbiva;

-- ANTICIPOS RECIBIDOS
SELECT 	NVL(SUM(imp_mant),0.00)
INTO 	vantrtot
FROM 	mov_ant
WHERE 	fec_mant >= paramFecIni AND fec_mant <= paramFecFin
		AND sta_mant = 'A'
		AND tpm_mant = '53';
		
LET vantriva = NVL((vantrtot / vsiva * viva),0.00);
LET vantrsstot = vantrtot - vantriva;

-- ANTICIPOS APLICADOS
SELECT 	NVL(SUM(imp_mant),0.00)
INTO 	vantatot
FROM 	mov_ant
WHERE 	fec_mant >= paramFecIni AND fec_mant <= paramFecFin
		AND sta_mant = 'A'
		AND tpm_mant = '99';
		
LET vantaiva = NVL((vantatot / vsiva * viva),0.00);
LET vantastot = vantatot - vantaiva;

-- DONATIVOS
SELECT  NVL(SUM(imp_mcxc),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva),0.00),NVL(SUM(NVL(imp_mcxc,0.00) / vsiva) * viva,0.00)
INTO 	vdonatot,vdonastot,vdonaiva
FROM 	mov_cxc
WHERE 	fec_mcxc >= paramFecIni AND fec_mcxc <= paramFecFin
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '63';	
		
LET vdonaiva = NVL((vdonatot / vsiva * viva),0.00);
LET vdonastot = vdonatot - vdonaiva;

-- FACTURAS CANCELADAS
SELECT 	NVL(SUM(impt_fac),0), NVL(SUM(simp_fac),0), NVL(SUM(iva_fac),0)
INTO    vtotfacc,vstotfacc,vivafacc
FROM 	factura
WHERE 	feccan_fac >= paramFecIni AND feccan_fac <= paramFecFin
     	AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND edo_fac  = 'C'
     	AND faccer_fac = 'N'
     	AND fec_fac <> feccan_fac
     	AND (frf_fac IS NULL OR frf_fac = 0);

RETURN  vtotvest,vstotvest,vivavest,vtotvcil,vstotvcil,vivavcil,vtotvcar,vstotvcar,vivavcar,vtotfac,
		vstotfac,vivafac,venctotefe,vencstotefe,vencivaefe,vcnctotcre,vcncstotcre,vcncivacre,vvtotefe,vvstotefe,
		vvivaefe,vcobtot,vcobrtot,vcobrstot,vcobriva,vcdcobrtot,vcdcobrstot,vcdcobriva,vcreding,vcdingtot,
		vcdingstot,vcdingiva,vdatot,vdastot,vdaiva,vdctot,vdcstot,vdciva,vcomptot,vcompstot,
		vcompiva,vintptot,vintpstot,vintpiva,vpagbtot,vpagbstot,vpagbiva,vantrtot,vantrsstot,vantriva,
		vantatot,vantastot,vantaiva,vdonatot,vdonastot,vdonaiva,vtotfacc,vstotfacc,vivafacc;
		
END PROCEDURE; 

SELECT  NVL(SUM(CASE WHEN tip_nvta = 'E' THEN impt_nvta ELSE 0 END),0.00),
     	NVL(SUM(CASE WHEN tip_nvta = 'B' THEN impt_nvta ELSE 0 END),0.00),
 		NVL(SUM(CASE WHEN asiste_nvta = 'S' THEN impasi_nvta ELSE 0 END),0.00)
FROM 	nota_vta
WHERE 	fes_nvta >= '2024-01-01' AND fes_nvta <= '2024-01-22'
   		AND ruta_nvta[1] = 'M'
   		AND edo_nvta = 'A'
   		AND (aju_nvta IS NULL OR aju_nvta <> 'S');
       		
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
     	
SELECT	NVL(SUM(impt_eruc),0.00),NVL(SUM(impasi_eruc),0.00)
FROM 	empxrutc
WHERE 	fec_eruc >= '2024-01-01' AND fec_eruc <= '2024-01-22'
		AND edo_eruc = 'C';
		
SELECT 	NVL(SUM(impasi_eruc),0.00)
FROM 	empxrutcbaj
WHERE 	fec_eruc >= '2024-01-01' AND fec_eruc <= '2024-01-22'
		AND edo_eruc = 'C';

SELECT 	NVL(SUM(impt_vand),0.00)
FROM 	venxand
WHERE 	fec_vand >= '2024-01-01' AND fec_vand <= '2024-01-22'
		AND edo_vand = 'C';

SELECT  NVL(SUM(impt_desd),0.00)
FROM 	des_dir  
WHERE 	fec_desd >= '2024-01-01' AND fec_desd <= '2024-01-22'
		AND edo_desd = 'C';
		
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
FROM 	mov_cxc
WHERE 	fec_mcxc >= '2024-01-01' AND fec_mcxc <= '2024-01-22'
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '63';	 
		
SELECT  *
FROM 	mov_cxc
WHERE 	fec_mcxc >= '2023-01-01' AND fec_mcxc <= '2024-02-14'
		AND sta_mcxc = 'A'
		AND tpm_mcxc = '56';	
	
SELECT  *
FROM 	mov_cxc
WHERE 	fec_mcxc >= '2023-01-01' AND fec_mcxc <= '2024-02-14'
		AND sta_mcxc = 'A'
		and tpm_mcxc  = '03'
		AND tpm_mcxc = '56';	
		
select	15892367.47, 15892367.47 / 1.16, 15892367.47 / 1.16 * 0.16
from    datos

SELECT  NVL(SUM(impt_nvta),0.00),NVL(SUM(simp_nvta),0.00), NVL(SUM(iva_nvta),0.00)
	    FROM 	nota_vta
	    WHERE 	fes_nvta >= '2024-01-01' AND fes_nvta <= '2024-01-31'
	       		AND tip_nvta = 'E'
	AND edo_nvta = 'A'
	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
	
select *
from   nota_vta
where  fes_nvta >= '2024-01-01' AND fes_nvta <= '2024-01-31'
	       		AND tip_nvta = 'E'
	AND edo_nvta = 'A'
	AND (aju_nvta IS NULL OR aju_nvta <> 'S')
	and (simp_nvta + iva_nvta) <> impt_nvta;
	
SELECT	*
FROM	factura
WHERE	fec_fac >= '2024-01-01' and fec_fac <= '2024-01-31'
		AND impr_fac = 'E'
     	AND tdoc_fac = 'I'
     	AND faccer_fac = 'N'
     	AND (feccan_fac is null OR feccan_fac <> fec_fac)
     	AND (frf_fac IS NULL OR frf_fac = 0)
     	and (simp_fac + iva_fac) <> impt_fac;
     
 select *
 from 	fuente.factura 
 where 	fec_fac between '2020-01-01' and '2020-01-31'
 		and edo_fac = 'C' and tdoc_fac = 'I'
 		AND (frf_fac IS NULL OR frf_fac = 0)
 		
 SELECT 	NVL(SUM(imp_mant),0.00)
FROM 	mov_ant
WHERE 	fec_mant >= '2024-08-01' AND fec_mant <= '2024-08-01'
		AND sta_mant = 'A'
		AND tpm_mant = '99';
	
select TODAY - 31 - 10 + 1
from   datos

select TODAY - 30 - 10 + 1
from   datos

select TODAY - 2 units month
from   datos

select (TODAY - 40) 
from   datos

select TODAY - 39
from   datos

SELECT  NVL(SUM(impt_nvta),0.00)
    FROM 	nota_vta
    WHERE 	fes_nvta >= '2024-09-01' AND fes_nvta <= '2024-09-01'
       		AND tip_nvta = 'E'
	       	AND edo_nvta = 'A'
	       	AND (aju_nvta IS NULL OR aju_nvta <> 'S');
	       
SELECT	*
FROM 	nota_crd
WHERE 	fec_ncrd >= '2024-09-06' AND fec_ncrd <= '2024-09-06'
		AND apl_ncrd = 'N'
		AnD edo_ncrd <> 'C'
		AND tdoc_ncrd = 'E'
		AND (tpa_ncrd = 'E' OR tpa_ncrd = 'X')
		AND impr_ncrd = 'E'
		AND (frnc_ncrd = 0 OR frnc_ncrd IS NULL);
	
SELECT	NVL(SUM(impt_nvta),0.00), NVL(SUM(simp_nvta),0.00), NVL(SUM(iva_nvta),0.00)
	FROM    nota_vta
	WHERE	fes_nvta = '2024-10-02'  AND edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B','C','D','E','2','3','4') AND tpa_nvta not IN('C','G');
	
     	