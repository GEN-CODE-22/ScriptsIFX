DROP PROCEDURE fact_genglobalm;
EXECUTE PROCEDURE fact_genglobalm('15','16','999999','2024-04-01','2024-04-31','carmen','C');

CREATE PROCEDURE fact_genglobalm
(
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramFecIni	DATE,
	paramFecFin	DATE,
	paramUsr	CHAR(8),
	paramTipo	CHAR(1)
)
RETURNING 
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100),	-- Mensaje
 INT,		-- Folio 
 CHAR(4);	-- Serie


DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(100);
DEFINE vnum 	INT;
DEFINE vfolfac	INT;
DEFINE vserfac	CHAR(4);
DEFINE vtip 	CHAR(1);
DEFINE vtprd 	CHAR(3);
DEFINE vpru 	DECIMAL;
DEFINE vtlts 	DECIMAL;
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vfolio	INT;
DEFINE vffis	DECIMAL;
DEFINE vvuelta 	INT;
DEFINE vruta	CHAR(4);
DEFINE vfolliq  INT;
DEFINE vfecha 	DATE;
DEFINE vimpt 	DECIMAL;
DEFINE vsimpt 	DECIMAL;
DEFINE viva 	DECIMAL;
DEFINE vivap 	DECIMAL;
DEFINE vtotimpt DECIMAL;
DEFINE vtotsimp DECIMAL;
DEFINE vtotiva  DECIMAL;
DEFINE vpcre	CHAR(40);
DEFINE vrfc		CHAR(40);
DEFINE vrelnvta CHAR(1);
DEFINE vfechah 	CHAR(19);
DEFINE vimptotv DECIMAL(18,5);
DEFINE vimptota DECIMAL(18,5);
DEFINE vimptotf DECIMAL(18,5);
DEFINE vimptrgv DECIMAL(18,5);
DEFINE vimptrga DECIMAL(18,5);
DEFINE vimptrgf DECIMAL(18,5);
DEFINE vimptfac DECIMAL(18,5);
DEFINE vimpfaca DECIMAL(18,5);
DEFINE vtotrg	DECIMAL(18,5);
DEFINE vtotfac  DECIMAL(18,5);
DEFINE vfolnvta	INT;

LET vproceso = 1;
LET vmsg = 'OK';
LET vfolnvta = 0;

LET vtotimpt = 0;
LET vsimpt = 0;
LET vtotsimp = 0;
LET viva = 0;
LET vivap = 0;
LET vtotiva = 0;
LET vfolfac = 0;
LET vserfac = '';
LET vcia = '';
LET vpla = '';
LET vfolio = 0;
LET vffis = 0;
LET vvuelta = 0;
LET vruta = '';
LET vfolliq = 0;
LET vfecha = '';
LET vimpt = 0;

SELECT	rfc_cte
INTO	vrfc
FROM	cliente
WHERE	num_cte = paramCte;

IF paramTipo = 'E' THEN
	IF NOT EXISTS(SELECT	1
					FROM 	nota_vta n
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tip_nvta IN('E')) THEN
		LET vproceso = -1;
		LET vmsg = 'NO EXISTE VENTA DE ESTACIONARIO POR FACTURAR.';
		RETURN 	vproceso,vmsg,0,'';
	END IF;
END IF;

IF paramTipo = 'B' THEN
	IF NOT EXISTS(SELECT	1
					FROM 	nota_vta n
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tip_nvta IN('B')) THEN
		LET vproceso = -1;
		LET vmsg = 'NO EXISTE VENTA DE CARBURACION POR FACTURAR.';
		RETURN 	vproceso,vmsg,0,'';
	END IF;
END IF;


IF paramTipo = 'C' THEN
	IF NOT EXISTS(SELECT	1
					FROM 	nota_vta n
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tip_nvta IN('C','D','2','3','4')) THEN
		LET vproceso = -1;
		LET vmsg = 'NO EXISTE VENTA DE CILINDRO POR FACTURAR.';
		RETURN 	vproceso,vmsg,0,'';
	END IF;
END IF;

IF EXISTS (SELECT	1
		FROM 	nota_vta n, cte_fac cf
		WHERE	n.numcte_nvta = cf.numcte_cfac 					
				AND fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('B','C','D','E','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND fac_nvta IS NULL) THEN
				LET vproceso = 0;
				LET vmsg = 'EXISTEN NOTAS SIN FACTURAR. EJECUTAR PROCESO DE FACTURACION AUTOMATICA.';
				RETURN 	vproceso,vmsg,0,'';
END IF;


IF EXISTS (SELECT	1
			FROM 	nota_vta
			WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'S' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')) THEN
					LET vproceso = 0;
					LET vmsg = 'EXISTEN NOTAS EN ESTATUS S';
					RETURN 	vproceso,vmsg,0,'';
END IF;

SELECT	NVL(MIN(fol_nvta),0)
INTO	vfolnvta
FROM	nota_vta
WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta in('A') 
		and ((impt_nvta - (tlts_nvta * pru_nvta) < -0.1) or  (impt_nvta - (tlts_nvta * pru_nvta) > 0.1))
		and tip_nvta in('C','D','2','3','4', 'E','B');

IF vfolnvta > 0 THEN
	LET vproceso = 0;
	LET vmsg = 'NOTA: ' || vfolnvta || ' TIENE PRECIO INCORRECTO';
	RETURN 	vproceso,vmsg,0,'';
END IF;

IF EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = paramFecFin) THEN
		  	
	SELECT	NVL(SUM(epo_impv),0)	
	INTO	vimptrgv
	FROM	e_posaj
	WHERE 	epo_fec BETWEEN paramFecIni AND paramFecFin;
	
	SELECT	NVL(SUM(impt_nvta),0)
	INTO	vimptotv
	FROM	nota_vta
	WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' 
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND tip_nvta IN('E','B','C','D','2','3','4');
			
	IF	vimptrgv <> vimptotv AND paramPla <> '26' AND paramPla <> '27' THEN
		LET vproceso = 0;
		LET vmsg = 'TOTAL DE VENTA: ' || vimptotv || ' NO COINCIDE CON EL IMPORTE EN REPORTE GERENCIAL: ' || vimptrgv;
		RETURN 	vproceso,vmsg,0,'';
	END IF;
	
	IF NOT EXISTS (SELECT 1 FROM empxrutp WHERE fec_erup BETWEEN paramFecIni AND paramFecFin AND edo_erup <> 'C') AND
		NOT EXISTS (SELECT 1 FROM empxrutc WHERE fec_eruc BETWEEN paramFecIni AND paramFecFin AND edo_eruc <> 'C')	AND
		NOT EXISTS (SELECT 1 FROM venxmed WHERE fec_vmed BETWEEN paramFecIni AND paramFecFin and edo_vmed <> 'C') AND
		NOT EXISTS (SELECT 1 FROM venxand WHERE fec_vand BETWEEN paramFecIni AND paramFecFin and edo_vand <> 'C') AND
		NOT EXISTS (SELECT 1 FROM des_dir WHERE fec_desd BETWEEN paramFecIni AND paramFecFin and edo_desd <> 'C') THEN	
		-- ESTACIONARIO------------------------------------
		IF paramTipo = 'E' THEN
			IF NOT EXISTS(SELECT 1 FROM factura, det_fac WHERE fec_fac = paramFecFin  AND fol_fac = fol_dfac
				AND ser_fac = ser_dfac AND faccer_fac = 'S' AND tid_dfac = 'E' AND edo_fac <> 'C') THEN			
				LET vproceso,vmsg = fact_checknvtaajum(paramFecIni,paramFecFin,'E');	
				IF 	vproceso = 1 THEN		
					LET vnum = 0;
					FOREACH cNotas FOR
						SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
								n.simp_nvta, n.iva_nvta, n.ivap_nvta, n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
								n.tlts_nvta, n.ffis_nvta		
						INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vtip,vtprd,vpru,vtlts,vffis
						FROM 	nota_vta n
						WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
								AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND fac_nvta IS NULL
								AND tip_nvta IN('E')
										
						LET vtotimpt = vtotimpt + vimpt;
						LET vtotsimp = vtotsimp + vsimpt;
						LET vtotiva = vtotiva + viva;
	
						IF vnum = 0 THEN
							SELECT	serfce_pla				
							INTO	vserfac
							FROM	planta
							WHERE	cia_pla = paramCia AND cve_pla = paramPla;
							LET vfolfac = GETVAL_EX_MODE(paramCia,paramPla,null,'folfce_pla');
							IF vfolfac <= 0 THEN
								LET vproceso = 0;
								LET vmsg = 'NO SE PUDO OBTENER EL FOLIO PARA LA FACURA GLOBAL DEL DIA DE ESTACIONARIO.';	
								RETURN vproceso,vmsg,0,'';
							END IF;
						END IF;	
						LET vnum = vnum + 1;
						LET vpcre = fact_getpcre(paramCia,paramPla,vfolio,vruta,vfecha);
						INSERT INTO det_fac 
						VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,0.00,vvuelta,vpcre);
					END FOREACH; 
					
     				LET vfechah = YEAR(paramFecFin) || '-' || LPAD(MONTH(paramFecFin),2,'0') || '-' || LPAD(DAY(paramFecFin),2,'0') || ' 23:59:59';
					INSERT INTO factura
					VALUES('Y',vfolfac,vserfac,paramCia,paramPla,paramFecFin,paramCte,'E','P','E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'S',null,null,null,'N','4','I',null,vrfc,'E',null,null,null,null,null);
					LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
					IF vrelnvta <> 'A' THEN
						LET vproceso = 0;
						LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
						RETURN 	vproceso,vmsg,vfolfac,vserfac;
					END IF;
					UPDATE	nota_vta
					SET		fac_nvta = vfolfac, ser_nvta = vserfac
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
								--AND aju_nvta = 'S'
								AND fac_nvta IS NULL
								AND tip_nvta IN('E');
					UPDATE	nota_vta
					SET		fac_nvta = vfolfac, ser_nvta = vserfac
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
							AND fac_nvta = 0 AND ser_nvta = 'FACT'
							AND tip_nvta IN('E');
					RETURN 	vproceso,vmsg,vfolfac,vserfac;
				END IF;
			ELSE
				LET vproceso = 0;
				LET vmsg = 'YA EXISTE UNA FACTURA DE CIERRE DE ESTACIONARIO EN ESA FECHA.';
				RETURN 	vproceso,vmsg,0,'';
			END IF;	
		END IF;
		
		-- CARBURACION------------------------------------
		IF paramTipo = 'B' THEN
			IF NOT EXISTS(SELECT 1 FROM factura, det_fac WHERE fec_fac = paramFecFin  AND fol_fac = fol_dfac
				AND ser_fac = ser_dfac AND faccer_fac = 'S' AND tid_dfac = 'B' AND edo_fac <> 'C') THEN	
				LET vproceso,vmsg = fact_checknvtaajum(paramFecIni,paramFecFin,'B');	
				IF 	vproceso = 1 THEN		
					LET vnum = 0;
					FOREACH cNotas FOR
						SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
								n.simp_nvta, n.iva_nvta, n.ivap_nvta, n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
								n.tlts_nvta, n.ffis_nvta		
						INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vtip,vtprd,vpru,vtlts,vffis
						FROM 	nota_vta n
						WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
								AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND fac_nvta IS NULL
								AND tip_nvta IN('B')
										
						LET vtotimpt = vtotimpt + vimpt;
						LET vtotsimp = vtotsimp + vsimpt;
						LET vtotiva = vtotiva + viva;
						
						IF vnum = 0 THEN
							SELECT	serfce_pla				
							INTO	vserfac
							FROM	planta
							WHERE	cia_pla = paramCia AND cve_pla = paramPla;
							LET vfolfac = GETVAL_EX_MODE(paramCia,paramPla,null,'folfce_pla');
							IF vfolfac <= 0 THEN
								LET vproceso = 0;
								LET vmsg = 'NO SE PUDO OBTENER EL FOLIO PARA LA FACURA GLOBAL DEL DIA DE CARBURACION.';	
								RETURN vproceso,vmsg,0,'';
							END IF;
						END IF;			
			
						LET vnum = vnum + 1;
						LET vpcre = fact_getpcre(paramCia,paramPla,vfolio,vruta,vfecha);
						INSERT INTO det_fac 
						VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,0.00,vvuelta,vpcre);
					END FOREACH; 
					
					LET vfechah = YEAR(paramFecFin) || '-' || LPAD(MONTH(paramFecFin),2,'0') || '-' || LPAD(DAY(paramFecFin),2,'0') || ' 23:59:59';
					INSERT INTO factura
					VALUES('S',vfolfac,vserfac,paramCia,paramPla,paramFecFin,paramCte,'E','P','E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'S',null,null,null,'N','4','I',null,vrfc,'E',null,null,null,null,null);
					LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
					IF vrelnvta <> 'A' THEN
						LET vproceso = 0;
						LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
						RETURN 	vproceso,vmsg,vfolfac,vserfac;
					END IF;
					UPDATE	nota_vta
					SET		fac_nvta = vfolfac, ser_nvta = vserfac
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
								--AND aju_nvta = 'S'
								AND fac_nvta IS NULL
								AND tip_nvta IN('B');
					UPDATE	nota_vta
					SET		fac_nvta = vfolfac, ser_nvta = vserfac
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
							AND fac_nvta = 0 AND ser_nvta = 'FACT'
							AND tip_nvta IN('B');
					RETURN 	vproceso,vmsg,vfolfac,vserfac;
				END IF;
			ELSE
				LET vproceso = 0;
				LET vmsg = 'YA EXISTE UNA FACTURA DE CIERRE DE CARBURACION EN ESA FECHA.';
				RETURN 	vproceso,vmsg,0,'';
			END IF;	
		END IF;
		
		-- CILINDROS------------------------------------
		IF paramTipo = 'C' THEN
			IF NOT EXISTS(SELECT 1 FROM factura, det_fac WHERE fec_fac = paramFecFin  AND fol_fac = fol_dfac
				AND ser_fac = ser_dfac AND faccer_fac = 'S' AND tid_dfac = 'C' AND edo_fac <> 'C') THEN	
				LET vproceso,vmsg = fact_checknvtaajum(paramFecIni,paramFecFin,'C');	
				IF 	vproceso = 1 THEN
					LET vnum = 0;
					FOREACH cNotas FOR
						SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
								n.simp_nvta, n.iva_nvta, n.ivap_nvta, n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
								n.tlts_nvta, n.ffis_nvta		
						INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vtip,vtprd,vpru,vtlts,vffis
						FROM 	nota_vta n
						WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
								AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND fac_nvta IS NULL
								AND tip_nvta IN('C','D','2','3','4')
										
						LET vtotimpt = vtotimpt + vimpt;
						LET vtotsimp = vtotsimp + vsimpt;
						LET vtotiva = vtotiva + viva;
						
						IF vnum = 0 THEN
							SELECT	serfce_pla				
							INTO	vserfac
							FROM	planta
							WHERE	cia_pla = paramCia AND cve_pla = paramPla;
							LET vfolfac = GETVAL_EX_MODE(paramCia,paramPla,null,'folfce_pla');
							IF vfolfac <= 0 THEN
								LET vproceso = 0;
								LET vmsg = 'NO SE PUDO OBTENER EL FOLIO PARA LA FACURA GLOBAL DEL DIA DE CILINDRO.';	
								RETURN vproceso,vmsg,0,'';
							END IF;
						END IF;			
						LET vnum = vnum + 1;
						LET vpcre = fact_getpcre(paramCia,paramPla,vfolio,vruta,vfecha);
						INSERT INTO det_fac 
						VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,0.00,vvuelta,vpcre);
					END FOREACH; 
										
					LET vfechah = YEAR(paramFecFin) || '-' || LPAD(MONTH(paramFecFin),2,'0') || '-' || LPAD(DAY(paramFecFin),2,'0') || ' 23:59:59';
					INSERT INTO factura
					VALUES('S',vfolfac,vserfac,paramCia,paramPla,paramFecFin,paramCte,'E','P','E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'S',null,null,null,'N','4','I',null,vrfc,'E',null,null,null,null,null);
					LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
					IF vrelnvta <> 'A' THEN
						LET vproceso = 0;
						LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
						RETURN 	vproceso,vmsg,vfolfac,vserfac;
					END IF;
					UPDATE	nota_vta
					SET		fac_nvta = vfolfac, ser_nvta = vserfac
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
								--AND aju_nvta = 'S'
								AND fac_nvta IS NULL
								AND tip_nvta IN('C','D','2','3','4');
					UPDATE	nota_vta
					SET		fac_nvta = vfolfac, ser_nvta = vserfac
					WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
							AND fac_nvta = 0 AND ser_nvta = 'FACT'
							AND tip_nvta IN('C','D','2','3','4');
					RETURN 	vproceso,vmsg,vfolfac,vserfac;
				ELSE
					RETURN 	vproceso,vmsg,0,'';
				END IF;			
			ELSE
				LET vproceso = 0;
				LET vmsg = 'YA EXISTE UNA FACTURA DE CIERRE DE CILINDRO EN ESA FECHA.';
				RETURN 	vproceso,vmsg,0,'';
			END IF;	
		END IF;
	ELSE 
		LET vproceso = 0;
		LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS GLOBALES, NO SE HAN CERRADO TODAS LAS LIQUIDACIONES DE VENTA.';
		RETURN 	vproceso,vmsg,0,'';
	END IF;
ELSE
	LET vproceso = 0;
	LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS GLOBALES, EL DIA NO ESTA CERRADO.';	
	RETURN 	vproceso,vmsg,0,'';
END IF;
END PROCEDURE;              

select	*
from	factura
where	tfac_fac = 'S'  AND faccer_fac = 'S'

SELECT * 
FROM factura, det_fac 
WHERE fec_fac = '2023-02-26'  AND fol_fac = fol_dfac
	AND ser_fac = ser_dfac AND faccer_fac = 'S' AND tid_dfac = 'C' AND edo_fac <> 'C'
				
SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
		n.simp_nvta, n.iva_nvta, n.ivap_nvta, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
		n.tlts_nvta, n.ffis_nvta		
FROM 	nota_vta n
WHERE	fes_nvta = '2023-02-26' AND edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		AND tip_nvta IN('C','D')

SELECT	serfce_pla	
FROM	planta
WHERE	cia_pla = '15' AND cve_pla = '09';
						
select	*
from	empxrutp
where	fec_erup = '2023-01-24'

select	*
from	empxrutc
where	fec_eruc = '2023-01-24'

select	*
from	venxmed
where	fec_vmed = '2023-01-24'

select	*
from	venxand
where	fec_vand = '2023-06-03'

select	*
from	des_dir
where	fec_desd = '2023-01-24'

SELECT 	sum(impt_eruc),sum(impasi_eruc)
FROM 	empxrutc
WHERE 	fec_eruc = '2023-01-16' 
		AND edo_eruc = 'C';
		
SELECT 	*
FROM 	venxand
WHERE 	fec_vand = '2023-02-10' 
		AND edo_vand = 'C';
		
SELECT 	sum(impt_desd)
FROM 	des_dir  
WHERE 	fec_desd = '2023-01-16' 
		AND edo_desd = 'C';

select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2024-02-27' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4')
		and fac_nvta is null
		
select	*
from	nota_vta
where	fes_nvta >= '2024-02-27' and fes_nvta <= '2024-02-27' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
		AND tip_nvta IN('C','D','2','3','4')
		and fac_nvta is null
		
		
select	*
from	nota_vta n
where	fes_nvta >= '2024-02-27' and fes_nvta <= '2024-02-27' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
		AND tip_nvta IN('C','D','2','3','4')
		and fol_nvta not in (select fnvta_dfac from det_fac where fnvta_dfac = n.fol_nvta and pla_dfac = n.pla_nvta
		and vuelta_dfac = n.vuelta_nvta and fol_dfac = 216819 and ser_dfac = 'EAJ')
		
select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta n
where	fes_nvta = '2024-02-27' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
		AND tip_nvta IN('C','D','2','3','4')
		and fac_nvta is null
		and fol_nvta not in (select fnvta_dfac from det_fac where fnvta_dfac = n.fol_nvta and pla_dfac = n.pla_nvta
		and vuelta_dfac = n.vuelta_nvta and fol_dfac = 216819 and ser_dfac = 'EAJ')

update  nota_vta n
set 	fac_nvta = null, ser_nvta = null
where 	fes_nvta = '2024-02-27' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
		AND tip_nvta IN('C','D','2','3','4')
		and fol_nvta not in (select fnvta_dfac from det_fac where fnvta_dfac = n.fol_nvta and pla_dfac = n.pla_nvta
		and vuelta_dfac = n.vuelta_nvta and fol_dfac = 216819 and ser_dfac = 'EAJ')
		
select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta n
where	fes_nvta = '2024-02-27'and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
		AND tip_nvta IN('C','D','2','3','4')
		and fac_nvta not in (216819)
		
select	*
from	nota_vta n
where	fes_nvta = '2024-02-27'and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
		AND tip_nvta IN('C','D','2','3','4')
		and fac_nvta not in (216819)
		
select  pla_nvta, fol_nvta, vuelta_nvta, impt_nvta
from 	nota_vta
where 	fac_nvta = 216819 and fes_nvta = '2024-02-27'
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
order by 1,2,3

select *
from   nota_vta
where  fes_nvta = '2024-02-27' and aju_nvta = 'S'
		and fac_nvta not in(216817,216818,216819)

update  nota_vta
set 	fac_nvta = null, ser_nvta = null
where fol_nvta in(913859,913860,913861,913862) and pla_nvta = '34'

select	pla_dfac, fnvta_dfac, vuelta_dfac, simp_dfac
from	det_fac --where tid_dfac = 'A' order by rowid desc
where	fol_dfac in(216819) and ser_dfac = 'EAJ' and fnvta_dfac is not null
order by 1,2,3

		
select	pla_nvta, fol_nvta, vuelta_nvta, fac_nvta, ser_nvta
from	nota_vta n
where	fes_nvta = '2024-02-27'and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') 
		AND tip_nvta IN('C','D','2','3','4')
		and fac_nvta not in (216819)
order by pla_nvta, fac_nvta, ser_nvta
		
		
select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-05-01' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and fac_nvta is null
		AND tip_nvta IN('B','C','D','E')
		
select	*
from	nota_vta
where	fes_nvta = '2024-02-27' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and fac_nvta is null
		AND tip_nvta IN('B','C','D','E')

select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-02-10' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E')

select	sum(simp_nvta), sum(iva_nvta), sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-02-26' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null
		AND tip_nvta IN('C')
		
select	epo_impv,epo_fact,epo_asistencia,epo_asistenciaa,*
from	e_posaj
where 	epo_fec = '2023-08-31'

update	e_posaj
set		epo_fec = '2024-12-16'
where 	epo_fec = '2021-12-16'

Select  tid_dfac, SUM(impasi_dfac) imp_asi , sum(tlts_dfac) cantidad,  SUM(tlts_dfac*pru_dfac ) importe 
from  factura, det_fac 
where fec_fac  BETWEEN  '2023-05-02' and '2023-05-02' and tdoc_fac = 'I' and edo_fac <> 'C' 
		and	faccer_fac = 'N' 
		and fol_dfac = fol_fac  and ser_dfac= ser_fac and tfac_fac <> 'O' and (frf_fac is null or frf_fac = 0) 
		GROUP BY   tid_dfac  order by tid_dfac

select	*
from	factura
where	fol_fac in(27365) and ser_fac = 'EAPC'

update	factura
set		uuid_fac = 'EB614423-3DE5-4270-90BE-5D1B6DA945B9'
where	fol_fac in(202227) and ser_fac = 'EAP'

update	cliente
set		rfc_cte = 'VASD791006RW8', razsoc_cte='ACME', codpo_cte = '76000'
where	num_cte = '100797'

delete	
from	factura
where	fol_fac = 0 and ser_fac = 'EAP' 

select	*
from	det_fac
where	fol_dfac = 27365 and ser_dfac = 'EAPC' and fnvta_dfac = 477283
order by mov_dfac

select	count(*)
from	det_fac
where	fol_dfac = 0 and ser_dfac = 'EAP'

delete
from	det_fac
where	fol_dfac = 0 and ser_dfac = 'EAP'

select	sum(simp_dfac), sum(impasi_dfac)
from	det_fac
where	fol_dfac = 202206 and ser_dfac = 'EAP'

select	*
from	cfd
where	fol_cfd = 202203 and ser_cfd = 'EAP'

delete
from	cfd
where	fol_cfd = 202214 and ser_cfd = 'EAP'

select	*
from	nota_vta where fac_nvta = 1000000
where	fol_nvta = 570065

select	*
from	nota_vta
where	fes_nvta between '2023-01-01' and '2023-01-30'
		and numcte_nvta is not null

select	*
from	nota_vta
where	fes_nvta between '2023-01-01' and '2023-01-30'
		and numcte_nvta = '100797' and fac_nvta in(27365)
		
select	numcte_nvta
from	nota_vta 
where 	fes_nvta = '2023-01-02' and fac_nvta = 202226
		and numcte_nvta in (select	numcte_nvta
							from	nota_vta 
							where 	fes_nvta = '2023-01-04' and fac_nvta = 202227)

select	*
from	factura where fec_fac = '2022-11-01' and faccer_fac = 'S' 


select	fes_nvta, count(*)
from	nota_vta 
where	fac_nvta is null
group by 1
order by fes_nvta

select	*
from	nota_vta 
where	fac_nvta is null and fes_nvta = '2023-05-01' and edo_nvta = 'A'
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B','C','D','E')
		AND fac_nvta is null

SELECT	*
from	nota_vta
WHERE	fes_nvta = '2023-06-03' AND edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		AND tip_nvta IN('C','D','2','3','4')
		
select	*
from	nota_vta
where	fac_nvta in(975413,975935)
		and tpa_nvta = 'C'
		
select	*
from	nota_vta
where	fol_nvta in(975413,975935)

select	*
from	doctos
where	fol_doc in(975413,975935)


select	*
from	mov_cxc
where	doc_mcxc in(975413,975935)

select	CURRENT,TODAY - 1 
from 	datos

select	epo_impv, epo_asistencia, epo_fact, *
from	e_posaj e
where	epo_fec >= '2023-04-01' 

SELECT	*
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 					
		AND fes_nvta = '2024-02-01' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		
select	*
from	cte_fac
where	numcte_cfac = '109284'
					
select	epo_impv, epo_asistencia, epo_fact, 
		NVL((SELECT SUM(impasi_dfac)  FROM factura,det_fac
  		 WHERE fec_fac = epo_fec
     AND impr_fac = 'E'
     AND tdoc_fac = 'I'     
     AND faccer_fac = 'N'
    AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0)
     AND fol_fac = fol_dfac
     AND ser_fac = ser_dfac
     AND cia_fac = cia_dfac
     AND pla_fac = pla_dfac),0.00),
		NVL((select sum(impt_fac) from factura where fec_fac = epo_fec and faccer_fac = 'S' and tfac_fac = 'S'),0.00)
from	e_posaj e
where	epo_fec >= '2023-05-06' 

SELECT SUM(impt_fac)
   FROM factura
   WHERE fec_fac >= '2023-05-02' AND fec_fac <= '2023-05-02'
     AND impr_fac = 'E'
     AND tdoc_fac = 'I'
     AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0);
     
SELECT SUM(impasi_dfac)
   FROM factura,det_fac
   WHERE fec_fac >= '2023-05-02' AND fec_fac <= '2023-05-02'
     AND impr_fac = 'E'
     AND tdoc_fac = 'I'   
  	-- AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0)
     AND fol_fac = fol_dfac
     AND ser_fac = ser_dfac
     AND cia_fac = cia_dfac
     AND pla_fac = pla_dfac;
     
select	aju_nvta, sum(impasi_nvta)
from	nota_vta
where	edo_nvta = 'A'
		AND impt_nvta > 0
		AND tip_nvta in('E','B','C','D')
		AND fes_nvta = '2023-05-02'
group by 1

EXECUTE PROCEDURE obt_facturado('2023-05-02','2023-05-02');

select	sum(simp_nvta), sum(iva_nvta), sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-05-02' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta  not in(156912,156913,156914)
		AND tip_nvta IN('E')
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta = '2023-09-28' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4')
		AND fac_nvta not in(210364)
		
SELECT	*
FROM	nota_vta
WHERE	fes_nvta = '2023-05-02' and edo_nvta = 'A' AND impt_nvta > 0 and impasi_nvta > 0
		--AND aju_nvta = 'S'
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta in(1882,156914)
		AND tip_nvta IN('C','D')
order by fol_nvta;
		
SELECT	sum(impt_nvta), sum(nvl(impasi_nvta,0))
FROM 	nota_vta n
WHERE	fes_nvta = '2023-09-28' AND edo_nvta = 'A' AND impt_nvta > 0 --and impasi_nvta > 0
		--AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		--AND fac_nvta in (156914)
		AND tip_nvta matches '[CD234]'

select	*
from factura
where	frf_fac in(156914)

select	*
from	factura, det_fac, nota_vta
where	fol_fac = fol_dfac and ser_fac  = ser_dfac and fol_nvta = fnvta_dfac and vuelta_nvta = vuelta_dfac
		and fec_fac = '2023-06-02' and tdoc_fac = 'I' and fes_nvta <> '2023-06-02'
		
select	sum(impt_fac), sum(impt_nvta) + sum(nvl(impasi_nvta,0))
from	factura, det_fac, nota_vta
where	fol_fac = fol_dfac and ser_fac  = ser_dfac and fol_nvta = fnvta_dfac and vuelta_nvta = vuelta_dfac
		and fec_fac <> '2023-05-20' and tdoc_fac = 'I' and fes_nvta = '2023-05-20'

select	*
from	factura
where	fec_fac = '2023-05-02' and tdoc_fac = 'I'

SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
		n.simp_nvta, n.iva_nvta, n.ivap_nvta, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
		n.tlts_nvta, n.ffis_nvta		
FROM 	nota_vta n
WHERE	fes_nvta = '2023-05-02' AND edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta not in(156914)
		AND tip_nvta IN('C','D')
		
select	*
from	nota_vta
where	fes_nvta = '2024-04-07' and fac_nvta is not null AND (aju_nvta IS NULL OR aju_nvta <> 'S') and tip_nvta = 'C' and edo_nvta = 'A'

select	*
from	factura
where	fec_fac > '2073-05-04' and tdoc_fac = 'I' and frf_fac is null and tfac_fac = 'S'

Select *  from factura where fec_fac between  '2023/04/01' and '2023/04/30' and tdoc_fac ='A'

SELECT	*
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 					
		AND fes_nvta = '2024-05-02' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		
SELECT	NVL(epo_impv,0)
FROM	e_posaj
WHERE 	epo_fec >= '2023-05-21';

SELECT	NVL(SUM(impt_nvta),0)
FROM	nota_vta
WHERE	fes_nvta = '2023-05-21' AND edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E','B','C','D','2','3','4')
		
SELECT	NVL(epo_impv,0),NVL(epo_asistencia,0),NVL(epo_fact,0),
	NVL((SELECT SUM(impt_fac) FROM factura WHERE fec_fac = epo_fec AND faccer_fac = 'S' AND edo_fac <> 'C' AND tfac_fac = 'S'),0.00),
	NVL((SELECT SUM(impasi_dfac)  FROM factura,det_fac
	 		WHERE fec_fac = epo_fec
     AND impr_fac = 'E'
     AND tdoc_fac = 'I'     
     AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0)
     AND fol_fac = fol_dfac
     AND ser_fac = ser_dfac
     AND cia_fac = cia_dfac
     AND pla_fac = pla_dfac),0.00)
FROM	e_posaj
WHERE 	epo_fec = '2023-05-18';

SELECT	*
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 					
		AND fes_nvta = '2024-03-30' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		
SELECT	*
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 					
		AND fes_nvta = '2023-07-17' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL

SELECT	NVL(SUM(impt_nvta),0)
	FROM	nota_vta
	WHERE	fes_nvta = '2023-10-30' AND edo_nvta = 'A' 
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND tip_nvta IN('E','B','C','D','2','3','4');
			
select	count(*)
from	cte_fac
			
select	*
from	factura
where	fyh_fac >= '2023-06-06 00:00:01' and fec_fac = '2023-06-05' and tdoc_fac = 'I'
		
select	*
from	factura
where	frf_fac = 156873

select	fec_fac, count(*)
from	factura
where	tfac_fac = 'S' and tdoc_fac = 'I' and fec_fac between '2023-07-01' and '2023-07-17' and faccer_fac = 'N'
group by 1
order by 1


SELECT	*
FROM 	nota_vta n
WHERE	fes_nvta = '2023-10-15' AND edo_nvta = 'A' AND impasi_nvta > 0							
		AND fac_nvta IS NULL
		AND tip_nvta IN('C','D','2','3','4')
		
SELECT	sum(*)
FROM 	nota_vta n
WHERE	fes_nvta = '2023-09-24' AND edo_nvta = 'A' AND impasi_nvta > 0							
		AND fac_nvta IS NULL
		AND tip_nvta IN('C','D','2','3','4')
		
select	*
from	det_fac
where	fol_dfac = 210364 and ser_dfac = 'EAQ' and fnvta_dfac = 95927 order by mov_dfac

update	det_fac
set		tlts_dfac = 8.00
where	fol_dfac = 210364 and ser_dfac = 'EAQ'  and mov_dfac = 1
		
select	sum(tlts_dfac * pru_dfac) + sum(impasi_dfac), sum(simp_dfac) + 5, 
		sum(tlts_dfac * pru_dfac) + sum(impasi_dfac)  -  (sum(simp_dfac) + 5)
from	det_fac
where	fol_dfac = 210364 and ser_dfac = 'EAQ'

select	count(*)
from	det_fac
where	fol_dfac = 210364 and ser_dfac = 'EAQ'

select	sum(impt_nvta), sum(impasi_nvta)
from	nota_vta
where	fac_nvta = 210364 and ser_nvta = 'EAQ'

select	count(*)
from	nota_vta
where	fac_nvta = 210364 and ser_nvta = 'EAQ'

select	*
from	nota_vta
where	fac_nvta = 210364 and ser_nvta = 'EAQ' and impasi_nvta > 0
		and fol_nvta not in(select fnvta_dfac from det_fac 
		where fol_dfac = 210364 and ser_dfac = 'EAQ' and pla_dfac = pla_nvta and vuelta_dfac = vuelta_nvta)
		
select	simp_nvta, pru_nvta, tlts_nvta, simp_dfac, pru_dfac, tlts_dfac
from	nota_vta, det_fac
where	fac_nvta = 210364 and ser_nvta = 'EAQ'
		and pla_dfac = pla_nvta and fnvta_dfac = fol_nvta and vuelta_dfac = vuelta_nvta


insert into det_fac
values(210364,'EAQ','15','15',542,'C',96334,null,30.00,'055',18.4300000000,null,127.10,0.00,3,'LP/14460/DIST/PLA/2016-2309281515096334')

SELECT	1
		FROM 	nota_vta n, cte_fac cf
		WHERE	n.numcte_nvta = cf.numcte_cfac 					
				AND fes_nvta = '2023-11-01' AND edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('B','C','D','E','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND fac_nvta IS NULL
				
SELECT	1
			FROM 	nota_vta
			WHERE	fes_nvta = '2023-11-01' AND edo_nvta = 'S' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')
					
SELECT	NVL(MIN(fol_nvta),0)
FROM	nota_vta
WHERE	fes_nvta = '2023-11-01' and edo_nvta in('A') 
		and ((impt_nvta - (tlts_nvta * pru_nvta) < -0.1) or  (impt_nvta - (tlts_nvta * pru_nvta) > 0.1))
		and tip_nvta in('C','D','2','3','4', 'E','B')
		
SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
		n.simp_nvta, n.iva_nvta, n.ivap_nvta, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
		n.tlts_nvta, n.ffis_nvta		
FROM 	nota_vta n
WHERE	fes_nvta = '2023-11-01' AND edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		AND tip_nvta IN('E')
		
SELECT	*
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 					
		AND fes_nvta = '2024-01-19' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		
SELECT	cia_nvta, pla_nvta, fol_nvta, tpa_nvta, impt_nvta, numcte_nvta, NVL(CASE 
				WHEN TRIM(c.razsoc_cte) <> '' THEN
				   TRIM(c.razsoc_cte) 
				ELSE 
				   trim(c.nom_cte) || ' ' || TRIM(c.ape_cte) 
				END,''), rfc_cte, ruta_nvta, fliq_nvta
FROM 	nota_vta n, cliente c
WHERE	n.numcte_nvta = c.num_cte		
		AND fes_nvta = '2023-11-28' AND edo_nvta IN ('A','S') AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')		
		AND fac_nvta IS NULL
		AND rfc_cte IS NOT NULL AND LENGTH(rfc_cte) > 0
		AND num_cte NOT IN (select numcte_cfac from cte_fac)
		AND numcte_nvta <> '999999'
		AND numtqe_nvta > 1
order by numcte_nvta

SELECT	numcte_nvta, count(*)
FROM 	nota_vta n, cliente c
WHERE	n.numcte_nvta = c.num_cte		
		AND fes_nvta = '2023-11-28' AND edo_nvta ('A','S') AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')		
		AND fac_nvta IS NULL
		AND rfc_cte IS NOT NULL
		AND num_cte NOT IN (select numcte_cfac from cte_fac)
		AND numcte_nvta <> '999999'
		AND numtqe_nvta > 1
group by 1
order by numcte_nvta

select  d.pla_dfac, d.fnvta_dfac, d.vuelta_dfac
from	factura, det_fac d
where	tdoc_fac = 'I' and fec_fac = '2023-12-09'  and faccer_fac = 'N'
		and fol_fac = d.fol_dfac and ser_fac = d.ser_dfac
		and frf_fac is null
group by 1,2,3
order by 1,2,3
		

SELECT	n.pla_nvta, n.fol_nvta, n.vuelta_nvta
FROM 	nota_vta n
WHERE	fes_nvta = '2024-01-03' AND edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NOT NULL
		AND tip_nvta IN('B','C','D','E','2','3','4')	
group by 1,2,3
order by 1,2,3

select	*
from	cliente
where	num_cte = '002166'

select	*
from	cte_fac
where	numcte_cfac = '002166'
