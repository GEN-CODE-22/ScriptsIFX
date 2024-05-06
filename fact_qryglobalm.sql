DROP PROCEDURE fact_qryglobalm;
EXECUTE PROCEDURE fact_qryglobalm('2023-07-01','2023-07-31');

CREATE PROCEDURE fact_qryglobalm
(
	paramFecIni	DATE,   
	paramFecFin	DATE
)
RETURNING 
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(255),	-- Mensaje
 DECIMAL,	-- Venta Estacionario
 DECIMAL,	-- Facturado Estacionario
 DECIMAL,	-- Importe Estacionario
 DECIMAL,	-- Ajustado Estacionario
 DECIMAL,	-- Venta Carburacion
 DECIMAL,	-- Facturado Carburacion
 DECIMAL,	-- Importe Carburacion
 DECIMAL,	-- Ajustado Carburación
 DECIMAL,	-- Venta Cilindros
 DECIMAL,	-- Facturado Cilindros
 DECIMAL,	-- Ajustado Cilindros
 DECIMAL;	-- Importe Cilindros

DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(255);
DEFINE vvest	DECIMAL;
DEFINE vfest	DECIMAL;
DEFINE vimpest	DECIMAL;
DEFINE vajuest	DECIMAL;
DEFINE vvcar	DECIMAL;
DEFINE vfcar	DECIMAL;
DEFINE vimpcar	DECIMAL;
DEFINE vajucar	DECIMAL;
DEFINE vvcil	DECIMAL;
DEFINE vfcil	DECIMAL;
DEFINE vimpcil	DECIMAL;
DEFINE vajucil	DECIMAL;
DEFINE vfolnvta	INT;

LET vproceso = 1;
LET vmsg = 'OK';
LET vfolnvta = 0;

LET vajuest = 0;
LET vajucar = 0;
LET vajucil = 0;

/*IF EXISTS (SELECT	1
			FROM 	nota_vta n, cte_fac cf
			WHERE	n.numcte_nvta = cf.numcte_cfac 					
					AND fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')
					AND fac_nvta IS NULL) THEN
					LET vproceso = 0;
					LET vmsg = 'EXISTEN NOTAS SIN FACTURAR. EJECUTAR PROCESO DE FACTURACION AUTOMATICA.';
					RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0;
END IF;*/

/*SELECT	NVL(MIN(fol_nvta),0)
INTO	vfolnvta
FROM	nota_vta
WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta in('A') 
		and ((impt_nvta - (tlts_nvta * pru_nvta) < -0.1) or  (impt_nvta - (tlts_nvta * pru_nvta) > 0.1))
		and tip_nvta in('C','D','2','3','4', 'E','B');

IF vfolnvta > 0 THEN
	LET vproceso = 0;
	LET vmsg = 'NOTA: ' || vfolnvta || ' TIENE PRECIO INCORRECTO';
	RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0;
END IF;

IF EXISTS (SELECT	1
			FROM 	nota_vta
			WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin AND edo_nvta = 'S' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')) THEN
					LET vproceso = 0;
					LET vmsg = 'EXISTEN NOTAS EN ESTATUS S';
					RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0;
END IF;*/


/*IF EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = paramFecFin) THEN
	IF NOT EXISTS (SELECT 1 FROM empxrutp WHERE fec_erup BETWEEN paramFecIni AND paramFecFin and edo_erup <> 'C') AND
		NOT EXISTS (SELECT 1 FROM empxrutc WHERE fec_eruc BETWEEN paramFecIni AND paramFecFin and edo_eruc <> 'C')	AND
		NOT EXISTS (SELECT 1 FROM venxmed WHERE fec_vmed BETWEEN paramFecIni AND paramFecFin and edo_vmed <> 'C') AND
		NOT EXISTS (SELECT 1 FROM venxand WHERE fec_vand BETWEEN paramFecIni AND paramFecFin and edo_vand <> 'C') AND
		NOT EXISTS (SELECT 1 FROM des_dir WHERE fec_desd BETWEEN paramFecIni AND paramFecFin and edo_desd <> 'C') THEN	*/
			
		-- ESTACIONARIO------------------------------------
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vvest
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('E');
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vfest
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('E')
				AND fac_nvta IS NOT NULL;
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vimpest
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('E')
				AND fac_nvta IS NULL;
				
		SELECT	NVL(SUM(impt_nvta),0)
		INTO	vajuest
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND aju_nvta = 'S' 
				AND tip_nvta IN('E')
				AND fac_nvta IS NOT NULL;
				
		-- CARBURACION------------------------------------
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vvcar
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('B');
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vfcar
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('B')
				AND fac_nvta IS NOT NULL;
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vimpcar
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('B')
				AND fac_nvta IS NULL;
				
		SELECT	NVL(SUM(impt_nvta),0)
		INTO	vajucar
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND aju_nvta = 'S' 
				AND tip_nvta IN('B')
				AND fac_nvta IS NOT NULL;
				
		-- CILINDROS------------------------------------
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vvcil
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('C','D','2','3','4');
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vfcil
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('C','D','2','3','4')
				AND fac_nvta IS NOT NULL;
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vimpcil
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('C','D','2','3','4')
				AND fac_nvta IS NULL;
				
		SELECT	NVL(SUM(impt_nvta),0)
		INTO	vajucil
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin and edo_nvta = 'A' AND impt_nvta > 0
				AND aju_nvta = 'S' 
				AND tip_nvta IN('C','D','2','3','4')
				AND fac_nvta IS NOT NULL;
				
		RETURN 	vproceso,vmsg,vvest,vfest,vimpest,vajuest,vvcar,vfcar,vimpcar,vajucar,vvcil,vfcil,vimpcil,vajucil;
	/*ELSE 
		LET vproceso = 0;
		LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS GLOBALES, NO SE HAN CERRADO TODAS LAS LIQUIDACIONES DE VENTA.';
		RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0;
	END IF;
ELSE
	LET vproceso = 0;
	LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS GLOBALES, EL ULTIMO DIA NO ESTA CERRADO.';	
	RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0;
END IF;*/
END PROCEDURE;

SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' AND edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E');
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E')
		AND fac_nvta IS NOT NULL;
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E')
		AND fac_nvta IS NULL;
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' AND edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B');
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B')
		AND fac_nvta IS NOT NULL;
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B')
		AND fac_nvta IS NULL;
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' AND edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4');
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4')
		AND fac_nvta IS NOT NULL;
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta BETWEEN '2024-04-01' AND '2024-04-30' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4')
		AND fac_nvta IS NULL;
		