DROP PROCEDURE ConFactPag;
EXECUTE PROCEDURE ConFactPag('15','02','2018-06-07','2018-06-07');
CREATE PROCEDURE ConFactPag
(
	paramCia      		CHAR(2),
	paramPla      		CHAR(2),	
	paramFechaInicial	DATE,
	paramFechaFinal		DATE	
)

RETURNING 
 INT, 
 CHAR(4), 
 CHAR(10), 
 CHAR(100),
 CHAR(15), 
 CHAR(15),
 CHAR(100);
 
DEFINE v_folio 		INT;
DEFINE v_serie  	CHAR(4);
DEFINE v_fecha  	CHAR(10);
DEFINE v_cliente	CHAR(110);
DEFINE v_importe	CHAR(15);
DEFINE v_saldo 		CHAR(15);
DEFINE v_pago		CHAR(110);


FOREACH cFacturas FOR
	SELECT  f.fol_fac as v_folio, 
			f.ser_fac as v_serie, 
			TO_CHAR(f.fec_fac,'%d-%m-%Y'),
			CASE 
			WHEN TRIM(c.razsoc_cte) <> '' THEN
			   TRIM(c.razsoc_cte) 
			ELSE 
			   CASE
	
			  WHEN c.ali_cte <> '' THEN
					 TRIM(C.ali_cte) || ', ' 
				  ELSE
					 '' 
			   END || trim(c.nom_cte) || ' ' || TRIM(c.ape_cte) 
			END AS ncom_cte,
			LPAD(f.impt_fac,6,'0')
	INTO	v_folio,
			v_serie,
			v_fecha,
			v_cliente,
			v_importe
	FROM	factura f,
			cliente c
	WHERE	f.numcte_fac = c.num_cte
			and f.tpa_fac = 'C'
			and f.cia_fac = paramCia
			and f.pla_fac = paramPla
			and f.fec_fac >= paramFechaInicial	
			and f.fec_fac <= paramFechaFinal
			--and f.fol_fac = 534896	
	
	SELECT	NVL(SUM(sal_doc),0)
	INTO	v_saldo
	FROM	doctos
	WHERE	ffac_doc = v_folio and sfac_doc = v_serie and tip_doc = '01';
	LET v_pago = '';
	IF v_saldo = 0 THEN
		SELECT	ser_pfac || ' ' || fol_pfac || ' ' || fec_pfac || ' ' || imp_pfac
		INTO	v_pago
		FROM	pago_fac
		WHERE	ffac_pfac = v_folio and sfac_pfac = v_serie and numpag_pfac = 1;
	END IF;
			
	RETURN 	v_folio,
			v_serie,
			v_fecha,
			v_cliente,
			v_importe,	
			LPAD(v_saldo,6,'0'),
			v_pago			
	WITH RESUME;
END FOREACH;  
END PROCEDURE;    