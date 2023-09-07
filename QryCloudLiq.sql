CREATE PROCEDURE QryCloudLiq
(
	paramFolio INTEGER,
	paramCia   CHAR(2),
	paramPla   CHAR(2),
	paramRuta  CHAR(4)
)
RETURNING 
 INTEGER,
 CHAR(2), 
 CHAR(2), 
 CHAR(57),
 CHAR(40),
 CHAR(30),
 CHAR(57),
 INTEGER,
 CHAR(51),
 CHAR(51),
 CHAR(51),
 DATE,
 DECIMAL,
 DECIMAL,
 CHAR(5),
 CHAR(1);

DEFINE vfolio		INTEGER; 
DEFINE vcia			CHAR(2); 
DEFINE vpla			CHAR(2); 
DEFINE vruta		CHAR(57);
DEFINE veco			CHAR(40);
DEFINE vtpago		CHAR(30);
DEFINE vrutaa		CHAR(57);
DEFINE vregion		INTEGER;
DEFINE vchofer		CHAR(51);
DEFINE vayu1		CHAR(51);
DEFINE vayu2		CHAR(51);
DEFINE vfecha		DATE;
DEFINE vlecini		DECIMAL;
DEFINE vporini		DECIMAL;
DEFINE vhorini		CHAR(5);
DEFINE vestatus		CHAR(1);

FOREACH cursorLiq FOR
	SELECT	e.fliq_erup,
			e.cia_erup,
			e.pla_erup,
			(r.cve_rut || ' - ' || 
			r.cia_rut || ' - ' || r.pla_rut || ' - ' || 
			CASE 
				WHEN TRIM(r.desc_rut) <> '' THEN TRIM(r.desc_rut) 
				ELSE 'N/D' 
			END) AS rut_erup,
			u.cve_uni || ' / ' || u.plc_uni AS uni_erup,
			TRIM(c.cve_cat) || ' - ' || c.nom_cat AS pcs_erup,
			NVL((ra.cve_rut || ' - ' || 
			ra.cia_rut || ' - ' || ra.pla_rut || ' - ' || 
			CASE 
				WHEN TRIM(ra.desc_rut) <> '' THEN TRIM(ra.desc_rut) 
				ELSE 'N/D' 
			END),'0') AS arut_erup,
			r.reg_rut,
			substr(cho.cat_emp,8,4) || ' - ' || trim(cho.ape_emp) || ' ' || trim(cho.nom_emp) AS chf_erup,			 
			NVL(substr(ayu1.cat_emp,8,4) || ' - ' || trim(ayu1.ape_emp) || ' ' || trim(ayu1.nom_emp),'0') AS ay1_erup,
			e.ay2_erup,
			e.fec_erup,
			e.lin_erup,
			e.pin_erup,
			NVL(e.hini_erup,'0'),
			cl.stat_cliq
	INTO   	vfolio,
			vcia,
			vpla,
			vruta,
			veco,
			vtpago,
			vrutaa,
			vregion,
			vchofer,
			vayu1,
			vayu2,
			vfecha,
			vlecini,
			vporini,
			vhorini,
			vestatus
	FROM   	empxrutp e,
			cloud_liq cl,
			ruta r,
			unidad u,
			catalogs c,			
			OUTER ruta ra,
			empleado cho,
			OUTER empleado ayu1
	WHERE  	e.fliq_erup			= cl.liq_cliq
			AND e.rut_erup		= cl.ruta_cliq
			AND e.uni_erup		= u.cve_uni
			AND (e.pcs_erup		= c.cve_cat AND c.cat_cat = 'TPR')
			AND e.arut_erup		= ra.cve_rut
			AND e.chf_erup		= cho.cat_emp[8,11]
			AND e.ay1_erup		= ayu1.cat_emp[8,11]
			AND cl.ruta_cliq	= r.cve_rut
			AND (cl.liq_cliq	= paramFolio OR paramFolio = 0)
			AND cl.cia_cliq		= paramCia
			AND cl.pla_cliq 	= paramPla
			AND cl.ruta_cliq	= paramRuta	
			AND cl.odate_cliq	>= CURRENT - 7 UNITS DAY
			AND cl.liq_cliq		= (SELECT	MAX(fliq_erup)
								   FROM		empxrutp
								   WHERE	rut_erup = paramRuta)
	
				
	IF LENGTH(vayu1) = 0 THEN
		LET vayu1 = '0';
	END IF;	
	IF LENGTH(vayu2) > 0 THEN
		SELECT	substr(cat_emp,8,4) || ' - ' || trim(ape_emp) || ' ' || trim(nom_emp)
		INTO	vayu2
		FROM	empleado
		WHERE	cat_emp[8,11] = vayu2;		
	END IF;
	IF LENGTH(vayu2) = 0 THEN
		LET vayu2 = '0';
	END IF;						
	IF LENGTH(vrutaa) = 0 THEN
		LET vrutaa = '0';
	END IF;	
	
	RETURN	vfolio,
			vcia,
			vpla,
			vruta,
			veco,
			vtpago,
			vrutaa,
			vregion,
			vchofer,
			vayu1,
			vayu2,
			vfecha,
			vlecini,
			vporini,
			vhorini,
			vestatus
	WITH RESUME;
END FOREACH; 

END PROCEDURE;