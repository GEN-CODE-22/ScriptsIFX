DROP PROCEDURE credigas_verif;
EXECUTE PROCEDURE credigas_verif();

CREATE PROCEDURE credigas_verif
(
	
)
RETURNING  
 CHAR(10),	-- No Cuenta
 CHAR(8),   -- Fecha
 CHAR(6),   -- Hora
 DECIMAL,	-- Importe
 CHAR(6),	-- No cliente
 CHAR(80),	-- Nombre cliente
 CHAR(6),	-- Remision
 DECIMAL,	-- Saldo
 SMALLINT,	-- Estatus
 CHAR(120);	-- Observaciones

DEFINE vnocta 	CHAR(10);
DEFINE vfecha 	CHAR(8);
DEFINE vhora 	CHAR(6);
DEFINE vimporte DECIMAL;
DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vrem		CHAR(6);
DEFINE vestatus	SMALLINT;
DEFINE vobser 	CHAR(120);
DEFINE vsaldo 	DECIMAL;

LET vimporte = 0;

FOREACH cTransferencias FOR
	SELECT	cta_trf, fec_trf, hor_trf, imp_trf, cte_trf, rem_trf
	INTO	vnocta, vfecha, vhora, vimporte, vnocte, vrem
	FROM 	tmp_trf
	ORDER BY fec_trf
	SELECT	NVL(CASE 
			WHEN TRIM(cliente.razsoc_cte) <> '' THEN
			   TRIM(cliente.razsoc_cte) 
			ELSE 
			   trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
			END,'')
	INTO	vnomcte
	FROM	cliente
	WHERE	num_cte = vnocte;
	LET vsaldo = 0;
	IF EXISTS(SELECT 	1 
		  	FROM 	doctos 
		  	WHERE 	fol_doc = vrem AND cte_doc = vnocte AND tpa_doc = 'G' AND sta_doc = 'A'
		  			AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')) THEN
		SELECT	sal_doc
		INTO	vsaldo
		FROM	doctos
		WHERE	fol_doc = vrem AND cte_doc = vnocte AND tpa_doc = 'G' AND sta_doc = 'A'
				AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');
		IF vsaldo > 0 THEN
			IF vimporte <= vsaldo THEN
				LET vestatus = 1;
				LET vobser = '';
			ELSE
				LET vestatus = 1;
				LET vobser = 'IMPORTE MAYOR A SALDO REMISION: '|| vrem || ' TIENE SALDO = ' || vsaldo;
			END IF;
		ELSE
			LET vestatus = 3;
			LET vobser = 'SALDO MENOR O IGUAL A 0.00 REMISION: '|| vrem || ' TIENE SALDO = ' || vsaldo;
		END IF;
	ELSE
		LET vestatus = 2;
		LET vobser = 'NO SE ENCONTRO LA REMISION';
	END IF;
	  
	RETURN 	vnocta, vfecha, vhora, vimporte, vnocte, vnomcte, vrem, vsaldo, vestatus, vobser
    WITH RESUME;
END FOREACH; 
END PROCEDURE;

select	*
from	tmp_trf

SELECT 	*
FROM 	doctos 
WHERE 	fol_doc = 421690 AND cte_doc = '006028' AND tpa_doc = 'G' AND sta_doc = 'A'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')