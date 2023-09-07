DROP PROCEDURE RPT_nccia;
EXECUTE PROCEDURE  RPT_nccia('','','','2023-06-01','2023-06-30');
EXECUTE PROCEDURE  RPT_nccia('15','15','','2022-09-01','2022-09-26');
EXECUTE PROCEDURE  RPT_nccia('','','','2022-09-26','2022-09-26');
EXECUTE PROCEDURE  RPT_nccia('','','003593','2022-09-21','2022-09-26');

CREATE PROCEDURE RPT_nccia
(
	paramCia   	CHAR(2),
	paramPla   	CHAR(18),
	paramCte	CHAR(6),
	paramFecI   DATE,
	paramFecF   DATE
)

RETURNING  
 CHAR(40),
 CHAR(2),
 CHAR(2),
 DATE,
 INT,
 CHAR(4),
 CHAR(6),
 CHAR(80),
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL;

DEFINE vnompla 	CHAR(40);
DEFINE vcia     CHAR(2);
DEFINE vpla     CHAR(2);
DEFINE vfecha   DATE;
DEFINE vfolio   INT;
DEFINE vserie   CHAR(4);
DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vlitros  DECIMAL;
DEFINE vimplts  DECIMAL;
DEFINE vkilos   DECIMAL;
DEFINE vimpkgs  DECIMAL;
DEFINE vprecio  DECIMAL;
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

FOREACH cNotaCredito FOR
	SELECT	p.nom_pla, p.cia_pla, p.cve_pla, n.fec_ncrd, n.fol_ncrd, n.ser_ncrd, n.numcte_ncrd, n.pru_ncrd
	INTO	vnompla,vcia,vpla,vfecha,vfolio,vserie,vnocte,vprecio
	FROM	nota_crd n, planta p
	WHERE	n.cia_ncrd = p.cia_pla AND n.pla_ncrd = p.cve_pla AND (n.cia_ncrd = paramCia OR paramCia = '')
			AND (n.pla_ncrd in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
			AND (n.numcte_ncrd = paramCte OR paramCte = '')
			AND n.fec_ncrd BETWEEN paramFecI AND paramFecF
			AND tdoc_ncrd = 'E' AND edo_ncrd <> 'C'
			
	LET vlitros = 0.0;
	LET vimplts = 0.0;
	SELECT	NVL(SUM(tlts_dncrd),0)
	INTO	vlitros
	FROM	det_ncrd
	WHERE	fol_dncrd = vfolio AND ser_dncrd = vserie AND lok_dncrd = 'L';
	
	LET vimplts = vlitros * vprecio;
	
	LET vkilos = 0.0;
	LET vimpkgs = 0.0;
	SELECT	NVL(SUM(tlts_dncrd),0)
	INTO	vkilos
	FROM	det_ncrd
	WHERE	fol_dncrd = vfolio AND ser_dncrd = vserie AND lok_dncrd = 'K';
	
	LET vimpkgs = vkilos * vprecio;
		
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
	
	RETURN 	vnompla,vcia,vpla,vfecha,vfolio,vserie,vnocte,vnomcte,vlitros,vimplts,vkilos,vimpkgs
	WITH RESUME;
END FOREACH;
END PROCEDURE; 

select	*
from	planta

SELECT	p.nom_pla, p.cia_pla, p.cve_pla, n.fec_ncrd, n.fol_ncrd, n.ser_ncrd, n.numcte_ncrd, n.pru_ncrd
FROM	nota_crd n, planta p
WHERE	n.cia_ncrd = p.cia_pla and n.pla_ncrd = p.cve_pla --AND (n.cia_ncrd = paramCia OR paramCia = '')
		--AND (n.pla_ncrd in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
		--AND (n.numcte_ncrd = paramCte OR paramCte = '')
		AND n.fec_ncrd BETWEEN '2023-06-01' AND '2023-06-30'
		AND tdoc_ncrd = 'E' AND edo_ncrd <> 'C'