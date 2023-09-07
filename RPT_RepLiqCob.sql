DROP PROCEDURE RPT_RepLiqCob;
EXECUTE PROCEDURE  RPT_RepLiqCob(23625);

CREATE PROCEDURE RPT_RepLiqCob
(
	paramFolio   	INT
)

RETURNING  
 INT,
 DATE,
 INT,
 INT,
 CHAR(5),
 CHAR(80),
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 CHAR(1),
 CHAR(20),
 INT,
 CHAR(4),
 CHAR(2),
 CHAR(2),
 INT,
 CHAR(6),
 CHAR(80),
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL;

DEFINE vfolliq 	INT;
DEFINE vfecfac 	DATE;
DEFINE vncte	INT;
DEFINE vmcte	INT;
DEFINE vnoemp   CHAR(5);
DEFINE vnomemp  CHAR(80);
DEFINE vimpp 	DECIMAL;
DEFINE vimpr 	DECIMAL;
DEFINE vimpe 	DECIMAL;
DEFINE vimpc 	DECIMAL;
DEFINE vimpf 	DECIMAL;
DEFINE vimpt 	DECIMAL;
DEFINE vt 		CHAR(2);
DEFINE vtip 	CHAR(1);
DEFINE vtipo 	CHAR(20);
DEFINE vfolio 	INT;
DEFINE vserie 	CHAR(4);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vvuelta 	INT;
DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vpp	 	DECIMAL;
DEFINE vcr	 	DECIMAL;
DEFINE vpe	 	DECIMAL;
DEFINE vpc	 	DECIMAL;
DEFINE vpt	 	DECIMAL;
DEFINE vfecha 	DATE;

FOREACH cLiquidacion FOR
	SELECT	l.fliq_lcob, l.fec_lcob, l.ncte_lcob, l.mcte_lcob, l.emp_lcob, 
			l.impp_lcob, l.impr_lcob, l.impe_lcob, l.impc_lcob, NVL(l.impf_lcob,0.00), l.impt_lcob, d.fom_dlcob, d.tip_dlcob,
			CASE 
				WHEN d.fom_dlcob = 'F' THEN 'FACTURA' 
				WHEN d.fom_dlcob = 'D' AND (d.tip_dlcob = '01' OR  d.tip_dlcob >= '11' AND  d.tip_dlcob <= '99') THEN 'REMISION' 
				WHEN d.fom_dlcob = 'D' AND d.tip_dlcob = '03' THEN 'CHEQUE DEVUELTO' 
				WHEN d.fom_dlcob = 'A' THEN 'REMISION' 
				WHEN d.fom_dlcob = 'N' THEN 'NOTA DE CREDITO' 
			END,
			d.fol_dlcob, NVL(d.ser_dlcob,''), d.cia_dlcob, d.pla_dlcob, NVL(d.vuelta_dlcob,''),
			CASE
				WHEN d.edo_dlcob = 'P' THEN d.imp_dlcob ELSE 0.00
			END,
			CASE
				WHEN d.edo_dlcob = 'R' THEN d.imp_dlcob ELSE 0.00
			END,
			CASE
				WHEN d.edo_dlcob = 'E' THEN d.imp_dlcob ELSE 0.00
			END,
			CASE
				WHEN d.edo_dlcob MATCHES '[CNA]' THEN d.imp_dlcob ELSE 0.00
			END,
			CASE
				WHEN d.edo_dlcob NOT MATCHES '[PRECNA]' THEN d.imp_dlcob ELSE 0.00
			END
	INTO	vfolliq, vfecfac, vncte, vmcte, vnoemp, vimpp, vimpr, vimpe, vimpc, vimpf, vimpt, vtip,vt, vtipo, 
			vfolio, vserie, vcia, vpla, vvuelta, vpp, vcr, vpe, vpc, vpt
	FROM	liq_cob l, det_lcob d
	WHERE	l.fliq_lcob = d.fliq_dlcob
			AND l.fliq_lcob = paramFolio
	
	LET vnocte = '';
	
	SELECT 	trim(nom_emp) || ' ' || trim(ape_emp) 
	INTO    vnomemp
	FROM 	empleado 
	WHERE   cve_emp = vnoemp;
	
	IF vtip = 'F' THEN
		SELECT	numcte_fac
		INTO	vnocte
		FROM	factura
		WHERE	cia_fac = vcia AND pla_fac = vpla AND fol_fac = vfolio AND ser_fac = vserie;
	END IF;
	
	IF vtip = 'D' OR vtip = 'A' THEN
		IF (vt = '01' OR vt >= '11' AND vt <= '99') THEN
			SELECT	NVL(cte_doc,'')
			INTO	vnocte
			FROM	doctos
			WHERE	cia_doc = vcia AND pla_doc = vpla AND fol_doc = vfolio AND vuelta_doc = vvuelta;	
		END IF;	
		IF vt = '03' THEN
			SELECT	NVL(cte_doc,'')
			INTO	vnocte
			FROM	doctos
			WHERE	cia_doc = vcia AND pla_doc = vpla AND fol_doc = vfolio AND ser_doc = vserie AND tip_doc = vt;	
		END IF;	
	END IF;
	
	IF vtip = 'N' THEN
		SELECT	numcte_ncrd
		INTO	vnocte
		FROM	nota_crd
		WHERE	cia_ncrd = vcia AND pla_ncrd = vpla AND fol_ncrd = vfolio AND ser_ncrd = vserie;
	END IF;
	LET vnomcte = '';
	IF vnocte <> '' THEN
		SELECT	NVL(CASE 
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
				END,'')
		INTO	vnomcte
		FROM	cliente
		WHERE	num_cte = vnocte;
	END IF;
	
	RETURN 	vfolliq, vfecfac, vncte, vmcte, vnoemp, vnomemp, vimpp, vimpr, vimpe, vimpc, vimpf, vimpt, vtip, vtipo, 
			vfolio, vserie, vcia, vpla, vvuelta, vnocte, vnomcte, vpp, vcr, vpe, vpc, vpt
	WITH RESUME;
END FOREACH;
END PROCEDURE; 

SELECT	l.fliq_lcob, l.fec_lcob, l.ncte_lcob, l.mcte_lcob, l.emp_lcob, 
			l.impp_lcob, l.impr_lcob, l.impe_lcob, l.impc_lcob, NVL(l.impf_lcob,0.00), l.impt_lcob, d.fom_dlcob, d.tip_dlcob,
			CASE 
				WHEN d.fom_dlcob = 'F' THEN 'FACTURA' 
				WHEN d.fom_dlcob = 'D' THEN 'REMISION' 
				WHEN d.fom_dlcob = 'A' THEN 'REMISION' 
				WHEN d.fom_dlcob = 'N' THEN 'NOTA DE CREDITO' 
			END,
			d.fol_dlcob, NVL(d.ser_dlcob,''), d.cia_dlcob, d.pla_dlcob, NVL(d.vuelta_dlcob,''),
			CASE
				WHEN d.edo_dlcob = 'P' THEN d.imp_dlcob ELSE 0.00
			END,
			CASE
				WHEN d.edo_dlcob = 'R' THEN d.imp_dlcob ELSE 0.00
			END,
			CASE
				WHEN d.edo_dlcob = 'E' THEN d.imp_dlcob ELSE 0.00
			END,
			CASE
				WHEN d.edo_dlcob MATCHES '[CNA]' THEN d.imp_dlcob ELSE 0.00
			END,
			CASE
				WHEN d.edo_dlcob NOT MATCHES '[PRECNA]' THEN d.imp_dlcob ELSE 0.00
			END
	FROM	liq_cob l, det_lcob d
	WHERE	l.fliq_lcob = d.fliq_dlcob
			AND l.fliq_lcob = 60275
	