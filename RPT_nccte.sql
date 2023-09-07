DROP PROCEDURE RPT_nccte;
EXECUTE PROCEDURE  RPT_nccte('15','79','001224','2022-11-01','2022-11-16');
EXECUTE PROCEDURE  RPT_nccte('15','15','','2022-09-01','2022-09-26');
EXECUTE PROCEDURE  RPT_nccte('','','','2022-09-26','2022-09-26');
EXECUTE PROCEDURE  RPT_nccte('','','003593','2022-09-21','2022-09-26');

CREATE PROCEDURE RPT_nccte
(
	paramCia   	CHAR(2),
	paramPla   	CHAR(18),
	paramCte	CHAR(6),
	paramFecI   DATE,
	paramFecF   DATE
)

RETURNING 
 CHAR(6),
 CHAR(80),
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL;

DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vdescl	DECIMAL;
DEFINE vdesck	DECIMAL;
DEFINE vlitros  DECIMAL;
DEFINE vimplts  DECIMAL;
DEFINE vkilos   DECIMAL;
DEFINE vimpkgs  DECIMAL;
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

FOREACH cClientes FOR
	SELECT	n.numcte_ncrd
	INTO	vnocte
	FROM	nota_crd n
	WHERE	(n.cia_ncrd = paramCia OR paramCia = '')
			AND (n.pla_ncrd in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
			AND (n.numcte_ncrd = paramCte OR paramCte = '')
			AND n.fec_ncrd BETWEEN paramFecI AND paramFecF
			AND tdoc_ncrd = 'E' AND edo_ncrd <> 'C'
	GROUP BY 1
	ORDER bY 1
			
	SELECT	NVL(SUM(tlts_dncrd),0.0), NVL(SUM(n.impt_ncrd),0.0), NVL(MAX(pru_ncrd),0.0)
	INTO	vlitros, vimplts, vdescl
	FROM	det_ncrd d, nota_crd n
	WHERE	d.fol_dncrd = n.fol_ncrd AND d.ser_dncrd = n.ser_ncrd AND(n.cia_ncrd = paramCia OR paramCia = '')
			AND (n.pla_ncrd in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
			AND n.numcte_ncrd = vnocte
			AND n.fec_ncrd BETWEEN paramFecI AND paramFecF
			AND tdoc_ncrd = 'E' AND lok_dncrd = 'L' AND edo_ncrd <> 'C';	
	

	SELECT	NVL(SUM(tlts_dncrd),0.0), NVL(SUM(n.impt_ncrd),0.0), NVL(MAX(pru_ncrd),0.0)
	INTO	vkilos, vimpkgs, vdesck
	FROM	det_ncrd d, nota_crd n
	WHERE	d.fol_dncrd = n.fol_ncrd AND d.ser_dncrd = n.ser_ncrd AND(n.cia_ncrd = paramCia OR paramCia = '')
			AND (n.pla_ncrd in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
			AND n.numcte_ncrd = vnocte
			AND n.fec_ncrd BETWEEN paramFecI AND paramFecF
			AND tdoc_ncrd = 'E' AND lok_dncrd = 'K' AND edo_ncrd <> 'C';
	
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
	
	RETURN 	vnocte,vnomcte,vdescl, vdesck,vlitros,vimplts,vkilos,vimpkgs
	WITH RESUME;
END FOREACH;
END PROCEDURE; 

select	*
from	planta

SELECT	n.numcte_ncrd
FROM	nota_crd n
WHERE	n.numcte_ncrd = '001224' 
		AND n.fec_ncrd BETWEEN '2022-11-01' AND '2022-11-16'
		AND tdoc_ncrd = 'E'
GROUP BY 1
ORDER bY 1