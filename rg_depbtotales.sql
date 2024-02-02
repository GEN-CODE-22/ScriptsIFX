DROP PROCEDURE rg_depbtotales;

EXECUTE PROCEDURE rg_depbtotales('2024-01-01','2024-01-22');

CREATE PROCEDURE rg_depbtotales
(
	paramFecIni DATE,
	paramFecFin DATE
)
RETURNING 
	DECIMAL(16,2), 	-- TOTAL DEPOSITO BANCARIO
	DECIMAL(16,2), 	-- SUBTOTAL DEPOSITO BANCARIO
	DECIMAL(16,2), 	-- IVA DEPOSITO BANCARIO
	CHAR(15), 		-- NO DE CUENTA
	INT;			-- TOTAL DEPOSITOS
	
DEFINE vdepbantot  	DECIMAL(16,2);  -- TOTAL DEPOSITO BANCARIO
DEFINE vdepbanstot 	DECIMAL(16,2);  -- SUBTOTAL DEPOSITO BANCARIO
DEFINE vdepbaniva  	DECIMAL(16,2);  -- IVA DEPOSITO BANCARIO
DEFINE vdepbancta  	CHAR(15); 		-- NO DE CUENTA
DEFINE vtotdep    	INT; 			-- TOTAL DEPOSITOS

DEFINE viva  	  DECIMAL(16,2); -- IVA 
DEFINE vsiva  	  DECIMAL(16,2); -- SUBTOTAL IVA 

LET viva = 0.16;
LET vsiva = 1.16;

-- DEPOSITO BANCARIO
FOREACH cDepositos FOR
	SELECT 	SUM(imp_dddep), NVL(SUM(imp_dddep / vsiva),0.00),NVL(SUM(imp_dddep / vsiva) * viva,0.00), nct_dddep, COUNT(*) 
	INTO	vdepbantot,vdepbanstot,vdepbaniva,vdepbancta,vtotdep
	FROM	caja_dddep, caja_dep,caja_ddep,caja_dcon 
	WHERE	cia_dep = '15' AND  unn_dep = '0' 
			AND fec_dep >= paramFecIni AND fec_dep <= paramFecFin
			AND num_dep = rep_ddep AND cia_dep = cia_ddep  
			AND	pla_dep = pla_ddep AND unn_dep = unn_ddep
			AND con_ddep = cve_con AND rep_ddep = rep_dddep 
			AND cia_ddep = cia_dddep AND pla_ddep = pla_dddep 
			AND unn_ddep = unn_dddep and num_ddep = ndd_dddep 
			AND tip_ddep = tip_dddep and (tip_ddep <> 'S' AND tip_ddep <> '0') 
			AND imp_dddep <> 0 
	GROUP BY nct_dddep 
	ORDER BY nct_dddep
	
	RETURN  vdepbantot,vdepbanstot,vdepbaniva,vdepbancta,vtotdep
	WITH RESUME;
END FOREACH;

END PROCEDURE; 

SELECT 	SUM(imp_dddep), NVL(SUM(imp_dddep / 1.16),0.00), NVL(SUM(imp_dddep / 1.16) * 0.16,0.00), nct_dddep, COUNT(*) 
FROM	caja_dddep, caja_dep,caja_ddep,caja_dcon 
WHERE	cia_dep = '15' AND  unn_dep = '0' 
		AND fec_dep >= '2024-01-01' AND fec_dep <= '2024-01-22'
		AND num_dep = rep_ddep AND cia_dep = cia_ddep  
		AND	pla_dep = pla_ddep AND unn_dep = unn_ddep
		AND con_ddep = cve_con AND rep_ddep = rep_dddep 
		AND cia_ddep = cia_dddep AND pla_ddep = pla_dddep 
		AND unn_ddep = unn_dddep and num_ddep = ndd_dddep 
		AND tip_ddep = tip_dddep and (tip_ddep <> 'S' AND tip_ddep <> '0') 
		AND imp_dddep <> 0 
GROUP BY nct_dddep 
ORDER BY nct_dddep

