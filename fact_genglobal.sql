DROP PROCEDURE fact_genglobal;
EXECUTE PROCEDURE fact_genglobal('15','10','999999','2023-06-03','carmen','C');

CREATE PROCEDURE fact_genglobal
(
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramFecha	DATE,
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
DEFINE vasist 	DECIMAL;
DEFINE vtotasis	DECIMAL;
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
LET vasist = 0;
LET vtotasis = 0;
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

IF EXISTS (SELECT	1
			FROM 	nota_vta n, cte_fac cf
			WHERE	n.numcte_nvta = cf.numcte_cfac 					
					AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')
					AND fac_nvta IS NULL) THEN
					LET vproceso = 0;
					LET vmsg = 'EXISTEN NOTAS SIN FACTURAR. EJECUTAR PROCESO DE FACTURACION AUTOMATICA.';
					RETURN 	vproceso,vmsg,0,'';
END IF;

IF EXISTS (SELECT	1
			FROM 	nota_vta
			WHERE	fes_nvta = paramFecha AND edo_nvta = 'S' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')) THEN
					LET vproceso = 0;
					LET vmsg = 'EXISTEN NOTAS EN ESTATUS S';
					RETURN 	vproceso,vmsg,0,'';
END IF;

SELECT	NVL(MIN(fol_nvta),0)
INTO	vfolnvta
FROM	nota_vta
WHERE	fes_nvta = paramFecha and edo_nvta in('A') 
		and ((impt_nvta - (tlts_nvta * pru_nvta) < -0.1) or  (impt_nvta - (tlts_nvta * pru_nvta) > 0.1))
		and tip_nvta in('C','D','2','3','4', 'E','B');

IF vfolnvta > 0 THEN
	LET vproceso = 0;
	LET vmsg = 'NOTA: ' || vfolnvta || ' TIENE PRECIO INCORRECTO';
	RETURN 	vproceso,vmsg,0,'';
END IF;

IF EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = paramFecha) THEN
		  	
	SELECT	NVL(epo_impv,0),NVL(epo_asistencia,0),NVL(epo_fact,0)
			/*NVL((SELECT SUM(impt_fac) FROM factura 

			WHERE fec_fac = epo_fec AND faccer_fac = 'S' 
					AND tfac_fac = 'S'),0.00) fact*/
	INTO	vimptrgv,vimptrga,vimptrgf--,vimptfac--,vimpfaca
	FROM	e_posaj
	WHERE 	epo_fec = paramFecha;
	
	SELECT	NVL(SUM(impt_nvta),0)
	INTO	vimptotv
	FROM	nota_vta
	WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' 
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND tip_nvta IN('E','B','C','D','2','3','4');
			
	IF	vimptrgv <> vimptotv THEN
		LET vproceso = 0;
		LET vmsg = 'TOTAL DE VENTA: ' || vimptotv || ' NO COINCIDE CON EL IMPORTE EN REPORTE GERENCIAL: ' || vimptrgv;
		RETURN 	vproceso,vmsg,0,'';
	END IF;
	
	/*SELECT	NVL(SUM(impt_nvta),0)
	INTO	vimptotv
	FROM	nota_vta
	WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' 
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND fac_nvta IS NULL
			AND tip_nvta IN('E','B','C','D','2','3','4');
	
	SELECT	NVL(SUM(impasi_nvta),0)
	INTO	vimptota
	FROM	nota_vta
	WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' 
			AND fac_nvta IS NULL
			AND tip_nvta IN('E','B','C','D','2','3','4');
	
	LET vtotrg = vimptrgv + vimptrga;
	LET vtotfac = vimptotv + vimptota + vimptrgf + vimptfac + vimpfaca;
	
	IF	vtotrg <> vtotfac THEN
		LET vproceso = 0;
		LET vmsg = 'TOTAL GERENCIAL: ' || vtotrg || ' NO COINCIDE CON EL IMPORTE EN REPORTE GERENCIAL: ' || vtotfac;

		RETURN 	vproceso,vmsg,0,'';
	END IF;*/
	
	IF NOT EXISTS (SELECT 1 FROM empxrutp WHERE fec_erup = paramFecha and edo_erup <> 'C') AND
		NOT EXISTS (SELECT 1 FROM empxrutc WHERE fec_eruc = paramFecha and edo_eruc <> 'C')	AND
		NOT EXISTS (SELECT 1 FROM venxmed WHERE fec_vmed = paramFecha and edo_vmed <> 'C') AND
		NOT EXISTS (SELECT 1 FROM venxand WHERE fec_vand = paramFecha and edo_vand <> 'C') AND
		NOT EXISTS (SELECT 1 FROM des_dir WHERE fec_desd = paramFecha and edo_desd <> 'C') THEN	
		-- ESTACIONARIO------------------------------------
		IF paramTipo = 'E' THEN
			IF NOT EXISTS(SELECT 1 FROM factura, det_fac WHERE fec_fac = paramFecha  AND fol_fac = fol_dfac
				AND ser_fac = ser_dfac AND faccer_fac = 'S' AND tid_dfac = 'E' AND edo_fac <> 'C') THEN			

				LET vnum = 0;
				FOREACH cNotas FOR
					SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
							n.simp_nvta, n.iva_nvta, n.ivap_nvta, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
							n.tlts_nvta, n.ffis_nvta		
					INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vasist,vtip,vtprd,vpru,vtlts,vffis
					FROM 	nota_vta n
					WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tip_nvta IN('E')
									
					LET vtotasis = vtotasis + vasist;
					LET vtotimpt = vtotimpt + vimpt;
					LET vtotsimp = vtotsimp + vsimpt;
					LET vtotiva = vtotiva + viva;

					IF vasist > 0 THEN
						LET vtotiva = vtotiva + (vasist * (vivap / 100) / (1 + (vivap / 100)));
						LET vtotsimp = vtotsimp + (vasist / (1 + (vivap / 100)));
						LET vtotimpt = vtotimpt + vasist;
					END IF;	
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
					VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,vasist,vvuelta,vpcre);
				END FOREACH; 
				LET vtotasis = 0;
				FOREACH cNotasAsistencia FOR
					SELECT	NVL(n.impasi_nvta, 0), n.ivap_nvta	
					INTO	vasist,vivap
					FROM 	nota_vta n
					WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impasi_nvta > 0
							AND aju_nvta = 'S'
							--AND fac_nvta IS NULL
							AND tip_nvta IN('E')
						
					LET vtotasis = vtotasis + vasist;			
					LET vtotiva = vtotiva + (vasist * (vivap / 100) / (1 + (vivap / 100)));
					LET vtotsimp = vtotsimp + (vasist / (1 + (vivap / 100)));
					LET vtotimpt = vtotimpt + vasist;					
				END FOREACH; 
				LET vnum = vnum + 1;			
				SELECT	NVL(TRIM(pcre_pla), '')
				INTO	vpcre
				FROM	planta
				WHERE   cve_pla = paramPla;
				LET vpcre = TRIM(vpcre) || '-' || TO_CHAR(paramFecha, '%y%m%d') || paramCia || paramPla || LPAD(vfolfac,7,'0');
				INSERT INTO det_fac 
				VALUES(vfolfac,vserfac,vcia,vpla,vnum,'E',null,null,0.00,'',1.0000000000,null,0.00,vtotasis,null,vpcre);
				LET vfechah = YEAR(paramFecha) || '-' || LPAD(MONTH(paramFecha),2,'0') || '-' || LPAD(DAY(paramFecha),2,'0') || ' 23:59:59';
				INSERT INTO factura
				VALUES('S',vfolfac,vserfac,paramCia,paramPla,paramFecha,paramCte,'E','P','E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'S',null,null,null,'N','4','I',null,vrfc,'E',null,null,null,null,null);
				LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
				IF vrelnvta <> 'A' THEN
					LET vproceso = 0;
					LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
					RETURN 	vproceso,vmsg,vfolfac,vserfac;
				END IF;
				/*UPDATE	nota_vta
				SET		fac_nvta = vfolfac, ser_nvta = vserfac
				WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							--AND aju_nvta = 'S'
							AND fac_nvta IS NULL
							AND tip_nvta IN('E');*/
				RETURN 	vproceso,vmsg,vfolfac,vserfac;
			ELSE
				LET vproceso = 0;
				LET vmsg = 'YA EXISTE UNA FACTURA DE CIERRE DE ESTACIONARIO EN ESA FECHA.';
				RETURN 	vproceso,vmsg,0,'';
			END IF;	
		END IF;
		
		-- CARBURACION------------------------------------
		IF paramTipo = 'B' THEN
			IF NOT EXISTS(SELECT 1 FROM factura, det_fac WHERE fec_fac = paramFecha  AND fol_fac = fol_dfac
				AND ser_fac = ser_dfac AND faccer_fac = 'S' AND tid_dfac = 'B' AND edo_fac <> 'C') THEN			
				LET vnum = 0;
				FOREACH cNotas FOR
					SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
							n.simp_nvta, n.iva_nvta, n.ivap_nvta, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
							n.tlts_nvta, n.ffis_nvta		
					INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vasist,vtip,vtprd,vpru,vtlts,vffis
					FROM 	nota_vta n
					WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tip_nvta IN('B')
									
					LET vtotasis = vtotasis + vasist;
					LET vtotimpt = vtotimpt + vimpt;
					LET vtotsimp = vtotsimp + vsimpt;
					LET vtotiva = vtotiva + viva;
					IF vasist > 0 THEN
						LET vtotiva = vtotiva + (vasist * (vivap / 100) / (1 + (vivap / 100)));
						LET vtotsimp = vtotsimp + (vasist / (1 + (vivap / 100)));
						LET vtotimpt = vtotimpt + vasist;
					END IF;	
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
					VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,vasist,vvuelta,vpcre);
				END FOREACH; 
				LET vtotasis = 0;
				FOREACH cNotasAsistencia FOR
					SELECT	NVL(n.impasi_nvta, 0), n.ivap_nvta	
					INTO	vasist,vivap
					FROM 	nota_vta n
					WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impasi_nvta > 0
							AND aju_nvta = 'S'
							--AND fac_nvta IS NULL
							AND tip_nvta IN('B')
			
					LET vtotasis = vtotasis + vasist;					
					LET vtotiva = vtotiva + (vasist * (vivap / 100) / (1 + (vivap / 100)));
					LET vtotsimp = vtotsimp + (vasist / (1 + (vivap / 100)));
					LET vtotimpt = vtotimpt + vasist;					
				END FOREACH; 
				LET vnum = vnum + 1;			
				SELECT	NVL(TRIM(pcre_pla), '')
				INTO	vpcre
				FROM	planta
				WHERE   cve_pla = paramPla;
				LET vpcre = TRIM(vpcre) || '-' || TO_CHAR(paramFecha, '%y%m%d') || paramCia || paramPla || LPAD(vfolfac,7,'0');
				INSERT INTO det_fac 
				VALUES(vfolfac,vserfac,vcia,vpla,vnum,'B',null,null,0.00,'',1.0000000000,null,0.00,vtotasis,null,vpcre);
				LET vfechah = YEAR(paramFecha) || '-' || LPAD(MONTH(paramFecha),2,'0') || '-' || LPAD(DAY(paramFecha),2,'0') || ' 23:59:59';
				INSERT INTO factura
				VALUES('S',vfolfac,vserfac,paramCia,paramPla,paramFecha,paramCte,'E','P','E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'S',null,null,null,'N','4','I',null,vrfc,'E',null,null,null,null,null);
				LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
				IF vrelnvta <> 'A' THEN
					LET vproceso = 0;
					LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
					RETURN 	vproceso,vmsg,vfolfac,vserfac;
				END IF;
				/*UPDATE	nota_vta
				SET		fac_nvta = vfolfac, ser_nvta = vserfac
				WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							--AND aju_nvta = 'S'
							AND fac_nvta IS NULL
							AND tip_nvta IN('B');*/
				RETURN 	vproceso,vmsg,vfolfac,vserfac;
			ELSE
				LET vproceso = 0;
				LET vmsg = 'YA EXISTE UNA FACTURA DE CIERRE DE CARBURACION EN ESA FECHA.';
				RETURN 	vproceso,vmsg,0,'';
			END IF;	
		END IF;
		
		-- CILINDROS------------------------------------
		IF paramTipo = 'C' THEN
			IF NOT EXISTS(SELECT 1 FROM factura, det_fac WHERE fec_fac = paramFecha  AND fol_fac = fol_dfac
				AND ser_fac = ser_dfac AND faccer_fac = 'S' AND tid_dfac = 'C' AND edo_fac <> 'C') THEN	
				LET vproceso,vmsg = fact_checknvtaaju(paramFecha,'C');	
				IF 	vproceso = 1 THEN
					LET vnum = 0;
					FOREACH cNotas FOR
						SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
								n.simp_nvta, n.iva_nvta, n.ivap_nvta, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tprd_nvta, n.pru_nvta, 
								n.tlts_nvta, n.ffis_nvta		
						INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vasist,vtip,vtprd,vpru,vtlts,vffis
						FROM 	nota_vta n
						WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
								AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND fac_nvta IS NULL
								AND tip_nvta IN('C','D','2','3','4')
										
						LET vtotasis = vtotasis + vasist;
						LET vtotimpt = vtotimpt + vimpt;
						LET vtotsimp = vtotsimp + vsimpt;
						LET vtotiva = vtotiva + viva;
						IF vasist > 0 THEN
							LET vtotiva = vtotiva + (vasist * (vivap / 100) / (1 + (vivap / 100)));
							LET vtotsimp = vtotsimp + (vasist / (1 + (vivap / 100)));
							LET vtotimpt = vtotimpt + vasist;
						END IF;	
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
						VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,vasist,vvuelta,vpcre);
					END FOREACH; 
					LET vtotasis = 0;
					FOREACH cNotasAsistencia FOR
						SELECT	NVL(n.impasi_nvta, 0), n.ivap_nvta	
						INTO	vasist,vivap
						FROM 	nota_vta n
						WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impasi_nvta > 0
								AND aju_nvta = 'S'
								--AND fac_nvta IS NULL
								AND tip_nvta IN('C','D','2','3','4')
						LET vtotasis = vtotasis + vasist;		
						LET vtotiva = vtotiva + (vasist * (vivap / 100) / (1 + (vivap / 100)));
						LET vtotsimp = vtotsimp + (vasist / (1 + (vivap / 100)));
						LET vtotimpt = vtotimpt + vasist;					
					END FOREACH; 
					LET vnum = vnum + 1;			
					SELECT	NVL(TRIM(pcre_pla), '')
					INTO	vpcre
					FROM	planta
					WHERE   cve_pla = paramPla;
					LET vpcre = TRIM(vpcre) || '-' || TO_CHAR(paramFecha, '%y%m%d') || paramCia || paramPla || LPAD(vfolfac,7,'0');
					IF vfolfac = 0 THEN
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
					INSERT INTO det_fac 
					VALUES(vfolfac,vserfac,vcia,vpla,vnum,'C',null,null,0.00,'',1.0000000000,null,0.00,vtotasis,null,vpcre);
					LET vfechah = YEAR(paramFecha) || '-' || LPAD(MONTH(paramFecha),2,'0') || '-' || LPAD(DAY(paramFecha),2,'0') || ' 23:59:59';
					INSERT INTO factura
					VALUES('S',vfolfac,vserfac,paramCia,paramPla,paramFecha,paramCte,'E','P','E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'S',null,null,null,'N','4','I',null,vrfc,'E',null,null,null,null,null);
					LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
					IF vrelnvta <> 'A' THEN
						LET vproceso = 0;
						LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
						RETURN 	vproceso,vmsg,vfolfac,vserfac;
					END IF;
					UPDATE	nota_vta
					SET		fac_nvta = vfolfac, ser_nvta = vserfac
					WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
								--AND aju_nvta = 'S'
								AND fac_nvta IS NULL
								AND tip_nvta IN('C','D','2','3','4');
					UPDATE	nota_vta
					SET		fac_nvta = vfolfac, ser_nvta = vserfac
					WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
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
where	fes_nvta >= '2023-08-07' and fes_nvta <= '2023-08-07' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E')
		and fac_nvta is null
		
select	*
from	nota_vta
where	fes_nvta >= '2023-08-07' and fes_nvta <= '2023-08-07' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S') and impasi_nvta > 6 and fac_nvta not in(216040)
		AND tip_nvta IN('E')
		and fac_nvta is null
		
select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-05-01' and edo_nvta = 'A' 
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
where 	epo_fec = '2023-05-06'

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
		AND fes_nvta = '2023-06-01' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
					
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
WHERE	fes_nvta between '2023-05-02' and '2023-05-02' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','E','B');	
		
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
WHERE	fes_nvta = '2023-05-03' AND edo_nvta = 'A' AND impt_nvta > 0 --and impasi_nvta > 0
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
where	fes_nvta = '2023-05-05' and fac_nvta is not null and aju_nvta = 'S'

select	*
from	factura
where	fec_fac > '2073-05-04' and tdoc_fac = 'I' and frf_fac is null and tfac_fac = 'S'

Select *  from factura where fec_fac between  '2023/04/01' and '2023/04/30' and tdoc_fac ='A'

SELECT	1
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 					
		AND fes_nvta = '2023-05-13' AND edo_nvta = 'A' AND impt_nvta > 0
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
		AND fes_nvta = '2023-05-22' AND edo_nvta = 'A' AND impt_nvta > 0
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
	WHERE	fes_nvta = '2023-06-11' AND edo_nvta = 'A' 
			--AND (aju_nvta IS NULL OR aju_nvta <> 'S')
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

