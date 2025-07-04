DROP PROCEDURE QRY_cxcpagos;
EXECUTE PROCEDURE  QRY_cxcpagos('','','2025-06-18', '2025-06-18');
EXECUTE PROCEDURE  QRY_cxcpagos('15','96','2023-01-01', '2023-01-31');

CREATE PROCEDURE QRY_cxcpagos
(
	paramCia		CHAR(2),
	paramPla		CHAR(18),	
	paramFecIni		DATE,
	paramFecFin		DATE
)

RETURNING  
 CHAR(6),	-- no cliente
 CHAR(80),	-- cliente
 CHAR(2),	-- cia
 CHAR(2),	-- planta
 CHAR(13),	-- rfc
 CHAR(6),	-- unidad operativa
 DATE,		-- fecha factura
 INT,		-- folio factura
 CHAR(4),	-- serie factura
 DECIMAL,	-- importe pago
 DATE;		-- fecha pago

DEFINE vnumcte 	CHAR(6);
DEFINE vnomcte  CHAR(80);
DEFINE vcia     CHAR(2);
DEFINE vpla     CHAR(2);
DEFINE vrfc     CHAR(13);
DEFINE vuoper 	CHAR(6);
DEFINE vfecfac 	DATE;
DEFINE vfolio   INT;
DEFINE vserie   CHAR(4);
DEFINE vimppag  DECIMAL;
DEFINE vfecpag  DATE;

DEFINE vpla1 	CHAR(2);
DEFINE vpla2 	CHAR(2);
DEFINE vpla3 	CHAR(2);
DEFINE vpla4 	CHAR(2);
DEFINE vpla5 	CHAR(2);
DEFINE vpla6 	CHAR(2);
DEFINE vpla7 	CHAR(2);
DEFINE vpla8 	CHAR(2);
DEFINE vpla9 	CHAR(2);

LET vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9 = get_plantas(paramPla);

IF paramCia = '' AND paramPla = '' THEN
	FOREACH cMovimientos FOR
		SELECT	c.num_cte, m.cia_mcxc, m.pla_mcxc, m.ffac_mcxc, m.sfac_mcxc, SUM(m.imp_mcxc), m.fec_mcxc
		INTO	vnumcte, vcia, vpla, vfolio, vserie, vimppag, vfecpag	
		FROM	mov_cxc m, cliente c
		WHERE	m.sta_mcxc = 'A' AND m.tpm_mcxc > '49' AND m.cte_mcxc = c.num_cte 
				AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
				AND ffac_mcxc IS NOT NULL AND sfac_mcxc IS NOT NULL
		GROUP BY 1,2,3,4,5,7
		ORDER BY m.fec_mcxc, m.ffac_mcxc ,m.sfac_mcxc
		
		LET vuoper = '';
		IF	EXISTS (SELECT 1 FROM plaxuope WHERE cia_plxuo = vcia AND pla_plxuo = vpla ) THEN
			SELECT	unio_plxuo
			INTO	vuoper
			FROM	plaxuope
			WHERE	cia_plxuo = vcia AND pla_plxuo = vpla;
		END IF;
		
		IF vnumcte <> '' THEN
			SELECT	NVL(CASE 
					WHEN TRIM(cliente.razsoc_cte) <> '' THEN
					   TRIM(cliente.razsoc_cte) 
					ELSE 
					   trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
					END,'')
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnumcte;
		END IF;	
		
		IF vfolio > 0 AND vserie <> '' THEN
			SELECT	rfc_fac, fec_fac
			INTO	vrfc, vfecfac
			FROM	factura
			WHERE   fol_fac = vfolio AND ser_fac = vserie;
		END IF;	
		
		RETURN 	vnumcte, vnomcte, vcia, vpla, vrfc, vuoper, vfecfac, vfolio, vserie, vimppag, vfecpag	
		WITH RESUME;
	END FOREACH;
ELSE
	FOREACH cMovimientos FOR
		SELECT	c.num_cte, m.cia_mcxc, m.pla_mcxc, m.ffac_mcxc, m.sfac_mcxc, SUM(m.imp_mcxc), m.fec_mcxc
		INTO	vnumcte, vcia, vpla, vfolio, vserie, vimppag, vfecpag	
		FROM	mov_cxc m, cliente c
		WHERE	m.sta_mcxc = 'A' AND m.tpm_mcxc > '49' AND m.cte_mcxc = c.num_cte 
				AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
				AND ffac_mcxc IS NOT NULL AND sfac_mcxc IS NOT NULL
				AND m.cia_mcxc = paramCia AND m.pla_mcxc IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)
		GROUP BY 1,2,3,4,5,7
		ORDER BY m.fec_mcxc, m.ffac_mcxc ,m.sfac_mcxc
		
		LET vuoper = '';
		IF	EXISTS (SELECT 1 FROM plaxuope WHERE cia_plxuo = vcia AND pla_plxuo = vpla ) THEN
			SELECT	unio_plxuo
			INTO	vuoper
			FROM	plaxuope
			WHERE	cia_plxuo = vcia AND pla_plxuo = vpla;
		END IF;
		
		IF vnumcte <> '' THEN
			SELECT	NVL(CASE 
					WHEN TRIM(cliente.razsoc_cte) <> '' THEN
					   TRIM(cliente.razsoc_cte) 
					ELSE 
					   trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
					END,'')
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnumcte;
		END IF;	
		
		IF vfolio > 0 AND vserie <> '' THEN
			SELECT	rfc_fac, fec_fac
			INTO	vrfc, vfecfac
			FROM	factura
			WHERE   fol_fac = vfolio AND ser_fac = vserie;
		END IF;	
		
		RETURN 	vnumcte, vnomcte, vcia, vpla, vrfc, vuoper, vfecfac, vfolio, vserie, vimppag, vfecpag	
		WITH RESUME;
	END FOREACH;
END IF;

END PROCEDURE; 