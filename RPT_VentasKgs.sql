EXECUTE PROCEDURE RPT_VentasKgs('2024-07-21','2024-07-31');

DROP PROCEDURE RPT_VentasKgs;

CREATE PROCEDURE RPT_VentasKgs
(
	paramFecIni	DATE,
	paramFecFin	DATE
)

RETURNING  
 CHAR(6), 
 CHAR(80),
 CHAR(13), 
 CHAR(6), 
 DECIMAL,
 DECIMAL,
 DECIMAL,   
 DECIMAL;

DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vrfc    	CHAR(13);
DEFINE vuniop 	CHAR(6);
DEFINE vtotkgs 	DECIMAL;
DEFINE vvtaiva 	DECIMAL;
DEFINE vvtasimp	DECIMAL;
DEFINE vvtaimp 	DECIMAL;
DEFINE vtotest 	DECIMAL;
DEFINE vtotcar 	DECIMAL;
DEFINE vtotcil 	DECIMAL;
DEFINE vcount 	INT;
DEFINE vfecfin 	DATE;

LET vcount = 0;
LET vfecfin = paramFecIni + 3;

SELECT	COUNT(*)
INTO 	vcount
FROM	nota_vta
WHERE	fes_nvta BETWEEN paramFecIni AND vfecfin
		AND edo_nvta = 'A' AND tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impt_nvta > 0;
		
IF vcount > 50 THEN
	FOREACH cVenta FOR
		SELECT	num_cte, CASE 
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   CASE
					  WHEN cliente.ali_cte <> '' THEN
						 TRIM(cliente.ali_cte) || ', ' 
					  ELSE
						 '' 
				   END || trim(NVL(cliente.nom_cte,'PUBLICO')) || ' ' || TRIM(NVL(cliente.ape_cte,'EN GENERAL')) 
				END AS ncom_cte,
				NVL(rfc_cte,'XAXX010101000'),
				NVL(cat_rut, 'planta'),
				SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
				SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
				SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
					(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
					(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
					(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
					ELSE 0 END) kgs_cil,
				SUM(iva_nvta),
				SUM(simp_nvta),
				SUM(impt_nvta)
		INTO 	vnocte,vnomcte,vrfc,vuniop,vtotest,vtotcar,vtotcil,vvtaiva,vvtasimp,vvtaimp
		FROM	nota_vta, cliente, ruta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin
				AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND impt_nvta > 0
				AND numcte_nvta = num_cte
				AND ruta_nvta = cve_rut
				AND ruta_nvta NOT IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
				AND num_cte <> '' AND num_cte IS NOT NULL
		GROUP BY 1,2,3,4
		
		UNION
		
		SELECT	num_cte, CASE 
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   CASE
					  WHEN cliente.ali_cte <> '' THEN
						 TRIM(cliente.ali_cte) || ', ' 
					  ELSE
						 '' 
				   END || trim(NVL(cliente.nom_cte,'PUBLICO')) || ' ' || TRIM(NVL(cliente.ape_cte,'EN GENERAL')) 
				END AS ncom_cte,
				NVL(rfc_cte,'XAXX010101000'),
				NVL(cat_rut, 'planta'),
				SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
				SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
				SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
					(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
					(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
					(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
					ELSE 0 END) kgs_cil,
				SUM(iva_nvta),
				SUM(simp_nvta),
				SUM(impt_nvta)
		FROM	nota_vta, cliente, ruta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin
				AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND impt_nvta > 0
				AND numcte_nvta = num_cte
				AND ruta_nvta = cve_rut
				AND ruta_nvta IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
				AND num_cte <> '' AND num_cte IS NOT NULL
		GROUP BY 1,2,3,4
		
		UNION 
		
		SELECT	'000000', 'PUBLICO EN GENERAL', 'XAXX010101000',
				NVL(cat_rut, 'planta'),
				SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
				SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
				SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
					(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
					(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
					(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
				ELSE 0 END) kgs_cil,
				SUM(iva_nvta),
				SUM(simp_nvta),
				SUM(impt_nvta)
		FROM	nota_vta, ruta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin
				AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND impt_nvta > 0
				AND ruta_nvta = cve_rut
				AND ruta_nvta NOT IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
				AND (numcte_nvta = '' OR numcte_nvta IS NULL OR numcte_nvta NOT IN (SELECT num_cte FROM cliente))		
		GROUP BY 1,2,3,4
		
		UNION
		
		SELECT	'000000', 'PUBLICO EN GENERAL', 'XAXX010101000',
				NVL(cat_rut, 'planta'),
				SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
				SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
				SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
					(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
					(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
					(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
				ELSE 0 END) kgs_cil,
				SUM(iva_nvta),
				SUM(simp_nvta),
				SUM(impt_nvta)
		FROM	nota_vta, ruta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin
				AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND impt_nvta > 0
				AND ruta_nvta = cve_rut
				AND ruta_nvta IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
				AND (numcte_nvta = '' OR numcte_nvta IS NULL OR numcte_nvta NOT IN (SELECT num_cte FROM cliente))			
		GROUP BY 1,2,3,4
		
		ORDER BY 4,1
	
		IF vuniop =  'planta' THEN
			SELECT	cve_unidad
			INTO	vuniop
			FROM	unidades_operativa
			WHERE	principal = 1;
		END IF;
		LET vtotkgs = NVL(vtotest,0) + NVL(vtotcar,0) + NVL(vtotcil,0);
		
		IF vrfc = '' THEN
			LET vrfc = 'XAXX010101000';
		END IF;
		
		RETURN 	vnocte,vnomcte,vrfc,vuniop,vtotkgs,vvtaiva,vvtasimp,vvtaimp
		WITH RESUME;
	END FOREACH;
ELSE
	FOREACH cVentaHist FOR
		SELECT	num_cte, CASE 
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   CASE
					  WHEN cliente.ali_cte <> '' THEN
						 TRIM(cliente.ali_cte) || ', ' 
					  ELSE
						 '' 
				   END || trim(NVL(cliente.nom_cte,'PUBLICO')) || ' ' || TRIM(NVL(cliente.ape_cte,'EN GENERAL')) 
				END AS ncom_cte,
				NVL(rfc_cte,'XAXX010101000'),
				NVL(cat_rut, 'planta'),
				SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
				SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
				SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
					(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
					(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
					(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
					ELSE 0 END) kgs_cil,
				SUM(iva_nvta),
				SUM(simp_nvta),
				SUM(impt_nvta)
		INTO 	vnocte,vnomcte,vrfc,vuniop,vtotest,vtotcar,vtotcil,vvtaiva,vvtasimp,vvtaimp
		FROM	rdnota_vta, cliente, ruta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin
				AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND impt_nvta > 0
				AND numcte_nvta = num_cte
				AND ruta_nvta = cve_rut
				AND ruta_nvta NOT IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
				AND num_cte <> '' AND num_cte IS NOT NULL
		GROUP BY 1,2,3,4
		
		UNION
		
		SELECT	num_cte, CASE 
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   CASE
					  WHEN cliente.ali_cte <> '' THEN
						 TRIM(cliente.ali_cte) || ', ' 
					  ELSE
						 '' 
				   END || trim(NVL(cliente.nom_cte,'PUBLICO')) || ' ' || TRIM(NVL(cliente.ape_cte,'EN GENERAL')) 
				END AS ncom_cte,
				NVL(rfc_cte,'XAXX010101000'),
				NVL(cat_rut, 'planta'),
				SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
				SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
				SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
					(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
					(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
					(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
					ELSE 0 END) kgs_cil,
				SUM(iva_nvta),
				SUM(simp_nvta),
				SUM(impt_nvta)
		FROM	rdnota_vta, cliente, ruta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin
				AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND impt_nvta > 0
				AND numcte_nvta = num_cte
				AND ruta_nvta = cve_rut
				AND ruta_nvta IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
				AND num_cte <> '' AND num_cte IS NOT NULL
		GROUP BY 1,2,3,4
		
		UNION 
		
		SELECT	'000000', 'PUBLICO EN GENERAL', 'XAXX010101000',
				NVL(cat_rut, 'planta'),
				SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
				SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
				SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
					(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
					(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
					(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
				ELSE 0 END) kgs_cil,
				SUM(iva_nvta),
				SUM(simp_nvta),
				SUM(impt_nvta)
		FROM	rdnota_vta, ruta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin
				AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND impt_nvta > 0
				AND ruta_nvta = cve_rut
				AND ruta_nvta NOT IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
				AND (numcte_nvta = '' OR numcte_nvta IS NULL OR numcte_nvta NOT IN (SELECT num_cte FROM cliente))		
		GROUP BY 1,2,3,4
		
		UNION
		
		SELECT	'000000', 'PUBLICO EN GENERAL', 'XAXX010101000',
				NVL(cat_rut, 'planta'),
				SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
				SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
				SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
					(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
					(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
					(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
					(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
				ELSE 0 END) kgs_cil,
				SUM(iva_nvta),
				SUM(simp_nvta),
				SUM(impt_nvta)
		FROM	rdnota_vta, ruta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin
				AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND impt_nvta > 0
				AND ruta_nvta = cve_rut
				AND ruta_nvta IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
				AND (numcte_nvta = '' OR numcte_nvta IS NULL OR numcte_nvta NOT IN (SELECT num_cte FROM cliente))		
		GROUP BY 1,2,3,4
		
		ORDER BY 4,1
	
		LET vtotkgs = NVL(vtotest,0) + NVL(vtotcar,0) + NVL(vtotcil,0);
		IF vuniop =  'planta' THEN
			SELECT	cve_unidad
			INTO	vuniop
			FROM	unidades_operativa
			WHERE	principal = 1;
		END IF;
		
		IF vrfc = '' THEN
			LET vrfc = 'XAXX010101000';
		END IF;
		RETURN 	vnocte,vnomcte,vrfc,vuniop,vtotkgs,vvtaiva,vvtasimp,vvtaimp
		WITH RESUME;
	END FOREACH;
END IF;

END PROCEDURE; 

select	*
from	unidades_operativa

insert into unidades_operativa values(4,'descripcion','GGE30',1,CURRENT)

select	*
from	planta

select *
from	ruta
where 	tip_rut = 'E'

select	num_cte, CASE 
			WHEN TRIM(cliente.razsoc_cte) <> '' THEN
			   TRIM(cliente.razsoc_cte) 
			ELSE 
			   CASE
				  WHEN cliente.ali_cte <> '' THEN
					 TRIM(cliente.ali_cte) || ', ' 
				  ELSE
					 '' 
			   END || trim(NVL(cliente.nom_cte,'PUBLICO')) || ' ' || TRIM(NVL(cliente.ape_cte,'EN GENERAL')) 
			END AS ncom_cte,
		NVL(rfc_cte,'XAXX010101000'),
		NVL(cat_rut, 'planta'),
		sum(case when tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
		sum(case when tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
		sum(case when tip_nvta matches '[CD234]' THEN 
			(case when tip_nvta = 'C' THEN tlts_nvta ELSE
			(case when tip_nvta = 'D' THEN tlts_nvta ELSE
			(case when tip_nvta = '2' THEN tlts_nvta * 20 ELSE
			(case when tip_nvta = '3' THEN tlts_nvta * 30 ELSE
			(case when tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
			ELSE 0 END) kgs_cil,
		sum(impt_nvta)
from	nota_vta, cliente, ruta
where	fes_nvta between '2024-09-01' and '2024-09-30'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		and numcte_nvta = num_cte
		and ruta_nvta = cve_rut
		and ruta_nvta in(select cve_rut from ruta where tip_rut = 'E')
		and num_cte <> '' and num_cte is not null		
group by 1,2,3,4
order by 4,1

select	'000000', 'PUBLICO EN GENERAL', 'XAXX010101000',
		NVL(cat_rut, 'planta'),
		sum(case when tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
		sum(case when tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
		sum(case when tip_nvta matches '[CD234]' THEN 
			(case when tip_nvta = 'C' THEN tlts_nvta ELSE
			(case when tip_nvta = 'D' THEN tlts_nvta ELSE
			(case when tip_nvta = '2' THEN tlts_nvta * 20 ELSE
			(case when tip_nvta = '3' THEN tlts_nvta * 30 ELSE
			(case when tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
			ELSE 0 END) kgs_cil,
		sum(impt_nvta)
from	nota_vta, cliente, ruta
where	fes_nvta between '2024-09-01' and '2024-09-30'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		and numcte_nvta = num_cte
		and ruta_nvta = cve_rut
		and ruta_nvta in(select cve_rut from ruta where tip_rut = 'E')
		and (num_cte = '' OR num_cte is null)		
group by 1,2,3,4
order by 4,1

SELECT	'000000', 'PUBLICO EN GENERAL', 'XAXX010101000',
		NVL(cat_rut, 'planta'),
		SUM(CASE WHEN tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
		SUM(CASE WHEN tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
		SUM(CASE WHEN tip_nvta matches '[CD234]' THEN 
			(CASE WHEN tip_nvta = 'C' THEN tlts_nvta ELSE
			(CASE WHEN tip_nvta = 'D' THEN tlts_nvta ELSE
			(CASE WHEN tip_nvta = '2' THEN tlts_nvta * 20 ELSE
			(CASE WHEN tip_nvta = '3' THEN tlts_nvta * 30 ELSE
			(CASE WHEN tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
		ELSE 0 END) kgs_cil,
		SUM(impt_nvta)
FROM	rdnota_vta, ruta
WHERE	fes_nvta BETWEEN '2024-03-01' AND '2024-03-31'
		AND edo_nvta = 'A' AND tip_nvta IN('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND impt_nvta > 0
		AND ruta_nvta = cve_rut
		AND ruta_nvta NOT IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
		AND (numcte_nvta = '' OR numcte_nvta IS NULL)		
GROUP BY 1,2,3,4

select	*
from	nota_vta
where	fes_nvta between '2024-09-01' and '2024-09-30'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		and impt_nvta > 0
		and numcte_nvta = '000100'
		
SELECT	*
FROM	cliente
where	num_cte = ''

select	sum(impt_nvta)
from	rdnota_vta
where	fes_nvta between '2024-07-01' and '2024-07-31'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		and numcte_nvta = '000175'
		
select	sum(impt_nvta)
from	rdnota_vta
where	fes_nvta between '2024-02-01' and '2024-02-29'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		and ruta_nvta in(select cve_rut from ruta where tip_rut = 'E')

select	numcte_nvta, sum(impt_nvta)
from	rdnota_vta
where	fes_nvta between '2024-03-01' and '2024-03-31'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		--AND ruta_nvta IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
		AND numcte_nvta <> '' AND numcte_nvta IS NOT NULL
group by  numcte_nvta

select	numcte_nvta, sum(impt_nvta)
from	rdnota_vta
where	fes_nvta between '2024-03-01' and '2024-03-31'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		--AND ruta_nvta IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
		AND (numcte_nvta = '' OR numcte_nvta IS null)
group by  numcte_nvta

select	*
from	rdnota_vta
where	fes_nvta between '2024-03-01' and '2024-03-31'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		AND ruta_nvta IN(SELECT cve_rut FROM ruta WHERE tip_rut = 'E')
		AND (numcte_nvta = '' OR numcte_nvta IS null)
group by  numcte_nvta

select	sum(tlts_nvta)
from	nota_vta
where	fes_nvta between '2024-09-01' and '2024-09-30'
		and edo_nvta = 'A' and tip_nvta in('C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		
		
select	cat_rut,pcre_rut,*
from	ruta
where	tip_rut = 'E'
order by 1

select	cat_rut, count(*)
from	ruta
where	tip_rut = 'E'
group by cat_rut

select	cat_rut,pcre_rut, count(*)
from	ruta
where	tip_rut = 'E'
group by 1,2

select	num_cte,
		NVL(rfc_cte,'XAXX010101000'),
		NVL(cat_rut, 'planta'),
		sum(case when tip_nvta = 'E' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_est,
		sum(case when tip_nvta = 'B' THEN tlts_nvta * 0.54 ELSE 0 END) kgs_carb,
		sum(case when tip_nvta matches '[CD234]' THEN 
			(case when tip_nvta = 'C' THEN tlts_nvta ELSE
			(case when tip_nvta = 'D' THEN tlts_nvta ELSE
			(case when tip_nvta = '2' THEN tlts_nvta * 20 ELSE
			(case when tip_nvta = '3' THEN tlts_nvta * 30 ELSE
			(case when tip_nvta = '4' THEN tlts_nvta * 45 ELSE 0 END) END) END) END) END)
			ELSE 0 END) kgs_cil,
		sum(impt_nvta)
from	nota_vta, cliente, ruta
where	fes_nvta between '2024-09-01' and '2024-09-30'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		and numcte_nvta = num_cte
		and ruta_nvta = cve_rut
		and ruta_nvta not in(select cve_rut from ruta where tip_rut = 'E')
		and num_cte = '000100'
group by 1,2,3
order by 1

select *
from   cliente
where  num_cte = '071862'

select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2024-10-24'
		and edo_nvta = 'A' and tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and impt_nvta > 0
		and ruta_nvta in(select cve_rut from ruta where tip_rut = 'E')