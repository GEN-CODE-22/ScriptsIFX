DROP PROCEDURE fact_genera;
EXECUTE PROCEDURE fact_genera('','','2022-12-17','fuente');
EXECUTE PROCEDURE fact_genera('15','86','2022-12-16','fuente');
 
EXECUTE PROCEDURE fact_setnotarel(25600,'EAPH','C');

CREATE PROCEDURE fact_genera
(
	paramCia	CHAR(2),
	paramPla	CHAR(18),
	paramFecha	DATE,
	paramEmp	CHAR(5),
	paramUsr	CHAR(8)
)
RETURNING 
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(255),	-- Mensaje
 INT;		-- No de facturas generadas
 
DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(255);
DEFINE vcount 	INT;
DEFINE vfolfac	INT;
DEFINE vserfac 	CHAR(4);
DEFINE vedofac 	CHAR(1);
DEFINE vnumcte 	CHAR(6);
DEFINE vpagcte 	CHAR(1);
DEFINE vrfccte 	CHAR(13);
DEFINE vtipfact	CHAR(1);
DEFINE vpcre	CHAR(40);
DEFINE vnum 	INT;
DEFINE vrelnvta CHAR(1);
DEFINE vtip 	CHAR(1);
DEFINE vtprd 	CHAR(3);
DEFINE vpru 	DECIMAL;
DEFINE vtlts 	DECIMAL;
DEFINE vdif 	DECIMAL;
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vfolio	INT;
DEFINE vffis	DECIMAL;
DEFINE vvuelta 	INT;
DEFINE vruta	CHAR(4);
DEFINE vfolliq  INT;
DEFINE vfecha 	DATE;
DEFINE vtpa 	CHAR(1);
DEFINE vimpt 	DECIMAL;
DEFINE vsimpt 	DECIMAL;
DEFINE viva 	DECIMAL;
DEFINE vivap 	DECIMAL;
DEFINE vtotimpt DECIMAL;
DEFINE vtotsimp DECIMAL;
DEFINE vtotiva  DECIMAL;
DEFINE vasist 	DECIMAL;
DEFINE vtotasis	DECIMAL;
DEFINE vpla1 	CHAR(2);
DEFINE vpla2 	CHAR(2);
DEFINE vpla3 	CHAR(2);
DEFINE vpla4 	CHAR(2);
DEFINE vpla5 	CHAR(2);
DEFINE vpla6 	CHAR(2);
DEFINE vpla7 	CHAR(2);
DEFINE vpla8 	CHAR(2);
DEFINE vpla9 	CHAR(2);
DEFINE vfechah 	CHAR(19);

LET vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9 = get_plantas(paramPla);
LET vproceso = 1;
LET vmsg = 'OK';
LET vcount = 0;
LET vcia = '';
LET vpla = '';
LET vfolio = 0;
LET vffis = 0;
LET vvuelta = 0;
LET vruta = '';
LET vfolliq = 0;
LET vfecha = '';
LET vimpt = 0;
LET vtotimpt = 0;
LET vsimpt = 0;
LET vtotsimp = 0;
LET viva = 0;
LET vtotiva = 0;
LET vasist = 0;
LET vtotasis = 0;
LET vnum = 0;
LET vnumcte = 0;
LET vtipfact = 0;
LET vdif = 0;

FOREACH cNotasValidar FOR
	SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.impt_nvta, n.tlts_nvta, n.pru_nvta
	INTO	vcia,vpla,vfolio,vimpt,vtlts,vpru
	FROM 	nota_vta n, cte_fac cf
	WHERE	n.numcte_nvta = cf.numcte_cfac 
			AND (n.cia_nvta = paramCia OR paramCia = '')
			AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
			AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
			AND tip_nvta IN('B','C','D','E','2','3','4')
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND fac_nvta IS NULL
	ORDER BY n.pla_nvta, n.fol_nvta
	
	LET vdif = (vpru * vtlts) - vimpt;
	IF vdif < -0.1 OR vdif > 0.1 THEN
		LET vproceso = 0;
		LET vmsg = ' NOTA: ' || vcia || vpla || vfolio || ' IMPORTE: ' || vimpt || ' NO CORRRESPONDE AL PRECIO UNITARIO: ' || vpru || ' POR LOS LITROS: ' || vtlts;
	END IF;
END FOREACH;
IF vproceso = 0 THEN
	RETURN 	vproceso,vmsg,vcount;
END IF;

IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = paramFecha) THEN
	IF NOT EXISTS (SELECT 1 FROM empxrutp WHERE fec_erup = paramFecha and edo_erup <> 'C') AND
		NOT EXISTS (SELECT 1 FROM empxrutc WHERE fec_eruc = paramFecha and edo_eruc <> 'C')	AND
		NOT EXISTS (SELECT 1 FROM venxmed WHERE fec_vmed = paramFecha and edo_vmed <> 'C') AND
		NOT EXISTS (SELECT 1 FROM venxand WHERE fec_vand = paramFecha and edo_vand <> 'C') AND
		NOT EXISTS (SELECT 1 FROM des_dir WHERE fec_desd = paramFecha and edo_desd <> 'C') THEN	
		
		-- NOTAS EFECTIVO---------------------------------------------------------------------------------------------------
		FOREACH cClientesE FOR
			SELECT	n.numcte_nvta, cf.tipfac_cfac
			INTO	vnumcte,vtipfact
			FROM 	nota_vta n, cte_fac cf
			WHERE	n.numcte_nvta = cf.numcte_cfac 
					AND (n.cia_nvta = paramCia OR paramCia = '')
					AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
					AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')
					AND fac_nvta IS NULL
					AND tpa_nvta NOT IN('C','G')
			GROUP BY 1,2
			ORDER BY n.numcte_nvta	
			
			IF	vtipfact = 'N' THEN -- FACTURA POR NOTA---------------------------------------------------------------------
				FOREACH cNotas FOR
					SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
							n.simp_nvta, n.iva_nvta, n.ivap_nvta / 100, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tpa_nvta, n.tlts_nvta,
							n.ffis_nvta, n.tprd_nvta, n.pru_nvta, pago_cte, NVL(rfc_cte,'XAXX010101000')	
					INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vasist,vtip,vtpa,vtlts,
							vffis,vtprd,vpru,vpagcte,vrfccte
					FROM 	nota_vta n, cliente c
					WHERE	c.num_cte = vnumcte AND n.numcte_nvta = c.num_cte  
							AND (n.cia_nvta = paramCia OR paramCia = '')
							AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
							AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							AND tip_nvta IN('B','C','D','E','2','3','4')
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tpa_nvta NOT IN('C','G')							
					ORDER BY n.pla_nvta
					
					LET vtotimpt = 0;
					LET vtotsimp = 0;
					LET vtotiva = 0;
					LET vtotasis = 0;
					LET vnum = 1;		
					LET vedofac = 'P';
					IF vtpa IN('C','G') THEN
						LET vedofac = 'X';
						LET vpagcte = NULL;
					END IF;
					
					LET vtotimpt = vtotimpt + vimpt;
					LET vtotsimp = vtotsimp + vsimpt;
					LET vtotiva = vtotiva + viva;
					IF vasist > 0 THEN
						LET vtotiva = vtotiva + (vasist * vivap / (1 + vivap));
						LET vtotsimp = vtotsimp + (vasist / (1 + vivap));
						LET vtotimpt = vtotimpt + vasist;
					END IF;
					
					SELECT	serfce_pla
					INTO	vserfac
					FROM	planta
					WHERE	cia_pla = vcia AND cve_pla = vpla;
					
					LET vfolfac = GETVAL_EX_MODE(vcia,vpla,null,'folfce_pla');
					LET vfechah = YEAR(paramFecha) || '-' || LPAD(MONTH(paramFecha),2,'0') || '-' || LPAD(DAY(paramFecha),2,'0') || ' 23:59:59';
					INSERT INTO factura
					VALUES('S',vfolfac,vserfac,vcia,vpla,paramFecha,vnumcte,vtpa,vedofac,'E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'N',null,null,null,'N','4','I',null,vrfccte,vpagcte,null,null,null,null,null);
					LET vpcre = fact_getpcre(vcia,vpla,vfolio,vruta,vfecha);
					INSERT INTO det_fac 
					VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,vasist,vvuelta,vpcre);
					LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
					IF vrelnvta <> 'A' THEN
						LET vproceso = 0;
						LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
						RETURN 	vproceso,vmsg,vcount;
					END IF;
					LET vcount = vcount + 1;
				END FOREACH;
			ELSE -- FACTURA POR DIA--------------------------------------------------------------------------------------------------------------
				FOREACH cNotasPlanta FOR
					SELECT	n.cia_nvta, n.pla_nvta	
					INTO	vcia,vpla
					FROM 	nota_vta n, cliente c
					WHERE	c.num_cte = vnumcte AND n.numcte_nvta = c.num_cte  
							AND (n.cia_nvta = paramCia OR paramCia = '')
							AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
							AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							AND tip_nvta IN('B','C','D','E','2','3','4')
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tpa_nvta NOT IN('C','G')
					GROUP BY 1,2
					ORDER BY n.pla_nvta
					
					LET vtotimpt = 0;
					LET vtotsimp = 0;
					LET vtotiva = 0;
					LET vtotasis = 0;
					LET vnum = 0;	
					
					SELECT	serfce_pla
					INTO	vserfac
					FROM	planta
					WHERE	cia_pla = vcia AND cve_pla = vpla;
					
					-- NOTAS VENTA EFECTIVO---------------------------------------------------------------------
					FOREACH cNotasEfectivo FOR
						SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
								n.simp_nvta, n.iva_nvta, n.ivap_nvta / 100, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tpa_nvta, n.tlts_nvta,
								n.ffis_nvta, n.tprd_nvta, n.pru_nvta, pago_cte, NVL(rfc_cte,'XAXX010101000')	
						INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vasist,vtip,vtpa,vtlts,
								vffis,vtprd,vpru,vpagcte,vrfccte
						FROM 	nota_vta n, cliente c
						WHERE	c.num_cte = vnumcte AND n.numcte_nvta = c.num_cte  
								AND n.cia_nvta = vcia
								AND n.pla_nvta  = vpla
								AND tpa_nvta NOT IN('C','G')
								AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
								AND tip_nvta IN('B','C','D','E','2','3','4')
								AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND fac_nvta IS NULL
								
						LET vedofac = 'P';
						
						LET vtotimpt = vtotimpt + vimpt;
						LET vtotsimp = vtotsimp + vsimpt;
						LET vtotiva = vtotiva + viva;
						IF vasist > 0 THEN
							LET vtotiva = vtotiva + (vasist * vivap / (1 + vivap));
							LET vtotsimp = vtotsimp + (vasist / (1 + vivap));
							LET vtotimpt = vtotimpt + vasist;
						END IF;	
						LET vnum = vnum + 1;
						IF vnum = 1 THEN
							LET vfolfac = GETVAL_EX_MODE(vcia,vpla,null,'folfce_pla');
						END IF;							
						LET vpcre = fact_getpcre(vcia,vpla,vfolio,vruta,vfecha);
						INSERT INTO det_fac 
						VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,vasist,vvuelta,vpcre);
					END FOREACH;
					IF vnum > 0 THEN
						LET vfechah = YEAR(paramFecha) || '-' || LPAD(MONTH(paramFecha),2,'0') || '-' || LPAD(DAY(paramFecha),2,'0') || ' 23:59:59';
						INSERT INTO factura
						VALUES('S',vfolfac,vserfac,vcia,vpla,paramFecha,vnumcte,vtpa,vedofac,'E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'N',null,null,null,'N','4','I',null,vrfccte,vpagcte,null,null,null,null,null);
						LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
						IF vrelnvta <> 'A' THEN
							LET vproceso = 0;
							LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
							RETURN 	vproceso,vmsg,vcount;
						END IF;
						LET vcount = vcount + 1;
					END IF;
				END FOREACH;
			END IF;
		END FOREACH; 
		
		-- NOTAS CREDITO-----------------------------------------------------------------------------------------------------
		FOREACH cClientesC FOR
			SELECT	n.numcte_nvta, cf.tipfac_cfac
			INTO	vnumcte,vtipfact
			FROM 	nota_vta n, cte_fac cf
			WHERE	n.numcte_nvta = cf.numcte_cfac 
					AND (n.cia_nvta = paramCia OR paramCia = '')
					AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
					AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')
					AND fac_nvta IS NULL
					AND tpa_nvta IN('C','G')
			GROUP BY 1,2
			ORDER BY n.numcte_nvta	
			
			IF	vtipfact = 'N' THEN -- FACTURA POR NOTA---------------------------------------------------------------------
				FOREACH cNotas FOR
					SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
							n.simp_nvta, n.iva_nvta, n.ivap_nvta / 100, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tpa_nvta, n.tlts_nvta,
							n.ffis_nvta, n.tprd_nvta, n.pru_nvta, pago_cte, NVL(rfc_cte,'XAXX010101000')	
					INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vasist,vtip,vtpa,vtlts,
							vffis,vtprd,vpru,vpagcte,vrfccte
					FROM 	nota_vta n, cliente c
					WHERE	c.num_cte = vnumcte AND n.numcte_nvta = c.num_cte  
							AND (n.cia_nvta = paramCia OR paramCia = '')
							AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
							AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							AND tip_nvta IN('B','C','D','E','2','3','4')
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tpa_nvta IN('C','G')							
					ORDER BY n.pla_nvta
					
					LET vtotimpt = 0;
					LET vtotsimp = 0;
					LET vtotiva = 0;
					LET vtotasis = 0;
					LET vnum = 1;		
					LET vedofac = 'P';
					IF vtpa IN('C','G') THEN
						LET vedofac = 'X';
						LET vpagcte = NULL;
					END IF;
					
					LET vtotimpt = vtotimpt + vimpt;
					LET vtotsimp = vtotsimp + vsimpt;
					LET vtotiva = vtotiva + viva;
					IF vasist > 0 THEN
						LET vtotiva = vtotiva + (vasist * vivap / (1 + vivap));
						LET vtotsimp = vtotsimp + (vasist / (1 + vivap));
						LET vtotimpt = vtotimpt + vasist;
					END IF;
					
					SELECT	serfce_pla
					INTO	vserfac
					FROM	planta
					WHERE	cia_pla = vcia AND cve_pla = vpla;
					
					LET vfolfac = GETVAL_EX_MODE(vcia,vpla,null,'folfce_pla');
					LET vfechah = YEAR(paramFecha) || '-' || LPAD(MONTH(paramFecha),2,'0') || '-' || LPAD(DAY(paramFecha),2,'0') || ' 23:59:59';
					INSERT INTO factura
					VALUES('S',vfolfac,vserfac,vcia,vpla,paramFecha,vnumcte,vtpa,vedofac,'E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'N',null,null,null,'N','4','I',null,vrfccte,vpagcte,null,null,null,null,null);
					LET vpcre = fact_getpcre(vcia,vpla,vfolio,vruta,vfecha);
					INSERT INTO det_fac 
					VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,vasist,vvuelta,vpcre);
					LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
					IF vrelnvta <> 'A' THEN
						LET vproceso = 0;
						LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
						RETURN 	vproceso,vmsg,vcount;
					END IF;
					LET vcount = vcount + 1;
				END FOREACH;
			ELSE -- FACTURA POR DIA--------------------------------------------------------------------------------------------------------------
				FOREACH cNotasPlanta FOR
					SELECT	n.cia_nvta, n.pla_nvta	
					INTO	vcia,vpla
					FROM 	nota_vta n, cliente c
					WHERE	c.num_cte = vnumcte AND n.numcte_nvta = c.num_cte  
							AND (n.cia_nvta = paramCia OR paramCia = '')
							AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
							AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							AND tip_nvta IN('B','C','D','E','2','3','4')
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND tpa_nvta IN('C','G')
					GROUP BY 1,2
					ORDER BY n.pla_nvta
					
					LET vtotimpt = 0;
					LET vtotsimp = 0;
					LET vtotiva = 0;
					LET vtotasis = 0;
					LET vnum = 0;	
					
					SELECT	serfce_pla
					INTO	vserfac
					FROM	planta
					WHERE	cia_pla = vcia AND cve_pla = vpla;
					-- NOTAS VENTA DE CREDITO---------------------------------------------------------------------
					FOREACH cNotasCredito FOR
						SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
								n.simp_nvta, n.iva_nvta, n.ivap_nvta / 100, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tpa_nvta, n.tlts_nvta,
								n.ffis_nvta, n.tprd_nvta, n.pru_nvta, pago_cte, NVL(rfc_cte,'XAXX010101000')	
						INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vsimpt,viva,vivap,vasist,vtip,vtpa,vtlts,
								vffis,vtprd,vpru,vpagcte,vrfccte
						FROM 	nota_vta n, cliente c
						WHERE	c.num_cte = vnumcte AND n.numcte_nvta = c.num_cte  
								AND n.cia_nvta = vcia
								AND n.pla_nvta  = vpla
								AND tpa_nvta IN('C','G')
								AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
								AND tip_nvta IN('B','C','D','E','2','3','4')
								AND (aju_nvta IS NULL OR aju_nvta <> 'S')
								AND fac_nvta IS NULL
								
						LET vedofac = 'X';
						LET vpagcte = NULL;
						
						LET vtotimpt = vtotimpt + vimpt;
						LET vtotsimp = vtotsimp + vsimpt;
						LET vtotiva = vtotiva + viva;
						IF vasist > 0 THEN
							LET vtotiva = vtotiva + (vasist * vivap / (1 + vivap));
							LET vtotsimp = vtotsimp + (vasist / (1 + vivap));
							LET vtotimpt = vtotimpt + vasist;
						END IF;	
						LET vnum = vnum + 1;
						IF vnum = 1 THEN
							LET vfolfac = GETVAL_EX_MODE(vcia,vpla,null,'folfce_pla');
						END IF;							
						LET vpcre = fact_getpcre(vcia,vpla,vfolio,vruta,vfecha);
						INSERT INTO det_fac 
						VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,vasist,vvuelta,vpcre);
					END FOREACH;
					IF vnum > 0 THEN
						LET vfechah = YEAR(paramFecha) || '-' || LPAD(MONTH(paramFecha),2,'0') || '-' || LPAD(DAY(paramFecha),2,'0') || ' 23:59:59';
						INSERT INTO factura
						VALUES('S',vfolfac,vserfac,vcia,vpla,paramFecha,vnumcte,vtpa,vedofac,'E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'N',null,null,null,'N','4','I',null,vrfccte,vpagcte,null,null,null,null,null);
						LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
						IF vrelnvta <> 'A' THEN
							LET vproceso = 0;
							LET vmsg = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
							RETURN 	vproceso,vmsg,vcount;
						END IF;
						LET vcount = vcount + 1;
					END IF;					
				END FOREACH;
			END IF;
		END FOREACH; 
		SELECT	COUNT(*)
		INTO	vcount
		FROM	factura
		WHERE	tfac_fac = 'S' AND fec_fac = paramFecha AND tdoc_fac = 'I' AND faccer_fac = 'N';	
		RETURN 	vproceso,vmsg,vcount;	
	ELSE 
		LET vproceso = 0;
		LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS, NO SE HAN CERRADO TODAS LAS LIQUIDACIONES DE VENTA.';
		RETURN 	vproceso,vmsg,vcount;
	END IF;
ELSE
	LET vproceso = 0;
	LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS, EL DIA YA ESTA CERRADO.';	
	RETURN 	vproceso,vmsg,vcount;
END IF;
END PROCEDURE;

SELECT	n.numcte_nvta, cf.tipfac_cfac
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 		
		AND fes_nvta = '2023-08-30' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
GROUP BY 1,2
ORDER BY n.numcte_nvta

SELECT	n.numcte_nvta, cf.tipfac_cfac
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 		
		AND fes_nvta = '2023-08-30' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		AND tpa_nvta NOT IN('C','G')
GROUP BY 1,2
ORDER BY n.numcte_nvta

SELECT	n.numcte_nvta, cf.tipfac_cfac
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 		
		AND fes_nvta = '2023-08-30' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		AND tpa_nvta IN('C','G')
GROUP BY 1,2
ORDER BY n.numcte_nvta

SELECT	n.cia_nvta, n.pla_nvta
FROM 	nota_vta n, cliente c
WHERE	c.num_cte = '009431' AND n.numcte_nvta = c.num_cte  		
		AND fes_nvta = '2022-12-16' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
GROUP BY 1,2
ORDER BY n.pla_nvta
			
SELECT	n.fes_nvta, count(*)
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 
		AND fes_nvta >= '2023-02-01' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
GROUP BY 1
ORDER BY 1
		
SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
		NVL(n.impasi_nvta, 0), n.numcte_nvta, 
		CASE WHEN cf.tipfac_cfac = 'D' THEN 'POR DIA' WHEN cf.tipfac_cfac = 'N' THEN 'POR NOTA DE VENTA' END			
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 
		AND fes_nvta = '2022-11-01' AND edo_nvta = 'A' AND impt_nvta > 0
		AND ruta_nvta[1] IN('M','B','C','D','A')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL

select	*
from	cte_fac

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
where	fec_vand = '2023-01-24'

select	*
from	des_dir
where	fec_desd = '2023-01-24'

SELECT 	sum(impt_eruc),sum(impasi_eruc)
FROM 	empxrutc
WHERE 	fec_eruc = '2023-01-16' 
		AND edo_eruc = 'C';
		
SELECT 	*
FROM 	venxand
WHERE 	fec_vand = '2023-01-16' 
		AND edo_vand = 'C';
		
SELECT 	sum(impt_desd)
FROM 	des_dir  
WHERE 	fec_desd = '2023-01-16' 
		AND edo_desd = 'C';

select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2022-11-01' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E','B','C','D')

select	numcte_nvta, tpa_nvta, count(*)
from	nota_vta
where	fes_nvta = '2022-12-19' and edo_nvta = 'A' 		
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null
		AND tip_nvta IN('C','D''E','B')
		AND numcte_nvta is not null
group by 1,2
		
select	*
from	nota_vta --where edo_nvta = 'A' order by fes_nvta 
where	fes_nvta = '2022-11-01' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null
		AND tip_nvta IN('C','D''E','B')
ORDER BY pla_nvta, numcte_nvta
		
select	sum(simp_nvta), sum(iva_nvta), sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-01-16' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null
		AND tip_nvta IN('E','B')
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-01-16' and edo_nvta = 'A' 
		AND ruta_nvta[1] in('M','B','C','D','A')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null

select	*
from	nota_vta
where	fes_nvta = '2023-01-25' 
		and (aju_nvta IS NOT NULL OR aju_nvta = 'S')
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-01-16' 
		and (aju_nvta IS NOT NULL OR aju_nvta = 'S')
		and ruta_nvta <> 'M099'
		
select	epo_impv,*
from	e_posaj
where 	epo_fec = '2023-03-20'

select	*
from	factura
where	fol_fac = 16197 and ser_fac = 'EAPD'

delete	
from	factura
where	fol_fac = 5000000 and ser_fac = 'EAB' 

select	*
from	det_fac
where	fol_dfac = 5000000 and ser_dfac = 'EAB'
order by mov_dfac

select	count(*)
from	det_fac
where	fol_dfac = 5000000 and ser_dfac = 'EAB'

delete
from	det_fac
where	fol_dfac = 5000000 and ser_dfac = 'EAB'

delete
from	cfd
where	fol_cfd = 5000000 and ser_cfd = 'EAB'

select	sum(simp_dfac)
from	det_fac
where	fol_dfac = 5000000 and ser_dfac = 'EAB'

select	*
from	rdnota_vta where fac_nvta = 1000000
where	fol_nvta = 570065

INSERT INTO factura
VALUES('M',1000000,'EAB','15','02','2022-02-15','999999','E','P','E', 693.94, 111.03, 804.97, null, 'suleima',null,null,null,null,null,null,'N','N','2022-02-15 08:57:52','N',null,null,'A7F10A01-9F3F-4F3E-9151-06C8EE198735','N','3','I',null,'ISI860319MW0','E',null,null,null,null,null);	

INSERT INTO det_fac 
VALUES(1000000,'EAB','15','02',1,'E',321531,null,65.00,'001',12.1700000000,null,681.94,13.92,12,'LP/14462/DIST/PLA/2016-2202141502321531');	


select	*
from	catalogs
where	cat_cat = 'TPF'

select	*
from	nota_vta
where	fes_nvta = '2022-12-16' and edo_nvta = 'A' and tpa_nvta = 'E'		
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null
		AND tip_nvta IN('C','D','E','B')
		AND numcte_nvta = '091724'

delete from factura
where	fec_fac = '2022-12-16'	

select	*
from	factura
where	fec_fac = '2022-12-16'

select	*
from	det_fac
where	fol_dfac = 25506  and ser_dfac = 'EAPH'

select	*
from	cfd
where	fec_cfd >= '2022-12-17 00:01:00' and fec_cfd <= '2022-12-17 23:01:00'

delete
from	cfd
where	fol_cfd = 16189 and ser_cfd = 'EAPD'

select	*
from	nota_vta
where	fol_nvta in(575593)

update	nota_vta
set		pru_nvta = 10.6500000000
where	fol_nvta in(156523)
--156523 10.6500000000 575593 10.6500000000
select	*
from	doctos
where	fol_doc in(575591,575594)

select	*
from	mov_cxc
where	doc_mcxc in(575591,575594)

update	nota_vta
set		fac_nvta = null, ser_nvta = null
where	fac_nvta > 16000 and fes_nvta = '2022-11-01' and pla_nvta = '85'

select	*
from	cte_fac

SELECT	COUNT(*)
FROM	liq_cob
WHERE	tip_lcob = 'A' AND fec_lcob = '2022-01-14' AND edo_lcob = 'A';

SELECT	n.numcte_nvta, cf.tipfac_cfac
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 		
		AND fes_nvta = '2023-08-02' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		--AND fac_nvta IS NULL
GROUP BY 1,2
ORDER BY n.numcte_nvta	

SELECT	n.numcte_nvta, cf.tipfac_cfac, n.tpa_nvta, n.ruta_nvta
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 
		--AND (n.cia_nvta = paramCia OR paramCia = '')
		--AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
		AND fes_nvta = '2023-08-07' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		--AND fac_nvta IS NULL
GROUP BY 1,2,3,4
order by 1,2,3,4
order by n.tpa_nvta, n.ruta_nvta
ORDER BY n.numcte_nvta	

select	*
from	factura
where	tfac_fac = 'S' and fec_fac = '2023-09-02'
