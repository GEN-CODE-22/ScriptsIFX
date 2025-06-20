EXECUTE PROCEDURE RPT_FactRepCiaF('2023-09-01','2023-09-30');

DROP PROCEDURE RPT_FactRepCiaF;
CREATE PROCEDURE RPT_FactRepCiaF
(
	paramFecIni	DATE,
	paramFecFin	DATE
)

RETURNING 
 DATE,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL;

DEFINE vfecfac DATE;
DEFINE vltsest DECIMAL;
DEFINE vimpest DECIMAL;
DEFINE vasiest DECIMAL;
DEFINE vltscar DECIMAL;
DEFINE vimpcar DECIMAL;
DEFINE vasicar DECIMAL;
DEFINE vkgscil DECIMAL;
DEFINE vimpcil DECIMAL;
DEFINE vasicil DECIMAL;
DEFINE vtotvta DECIMAL;
DEFINE vrglest DECIMAL;
DEFINE vrgiest DECIMAL;
DEFINE vrgaest DECIMAL;
DEFINE vrglcar DECIMAL;
DEFINE vrgicar DECIMAL;
DEFINE vrgacar DECIMAL;
DEFINE vrglcil DECIMAL;
DEFINE vrgicil DECIMAL;
DEFINE vrgacil DECIMAL;
DEFINE vtotfac DECIMAL;

LET vrglest = 0;
LET vrgiest = 0;
LET vrgaest = 0;
LET vrglcar = 0;
LET vrgicar = 0;
LET vrgacar = 0;
LET vrglcil = 0;
LET vrgicil = 0;
LET vrgacil = 0;


FOREACH cFacturas FOR
		SELECT 	fec_fac,
	    sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
		sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
		sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
		sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
		sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
		sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
		sum(case when tid_dfac matches '[CD234]' THEN 
		(case when tid_dfac = 'C' THEN tlts_dfac ELSE
		(case when tid_dfac = 'D' THEN tlts_dfac ELSE
		(case when tid_dfac = '2' THEN tlts_dfac * 20 ELSE
		(case when tid_dfac = '3' THEN tlts_dfac * 30 ELSE
		(case when tid_dfac = '4' THEN tlts_dfac * 45 ELSE 0 END) END) END) END) END)
		ELSE 0 END) kgs_cil,
		sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
		sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
	INTO	
		vfecfac,
		vltsest,
		vimpest,
		vasiest,
		vltscar,
		vimpcar,
		vasicar,
		vkgscil,
		vimpcil,
		vasicil
	FROM 	factura,det_fac
	WHERE 	fec_fac between paramFecIni and paramFecFin	
			and tdoc_fac IN('I','V')
		  	and edo_fac <> 'C'
			and frf_fac is null
			and fol_fac = fol_dfac
			and ser_fac = ser_dfac
	GROUP BY 1
	ORDER BY 1	
	
	LET vtotfac = vimpest + vasiest + vimpcar + vasicar + vimpcil + vasicil;
	
	SELECT	SUM(NVL(impt_nvta,0)),SUM(NVL(tlts_nvta,0))
	INTO	vrgiest, vrglest
	FROM	nota_vta
	WHERE	fes_nvta = vfecfac and edo_nvta = 'A' AND impt_nvta > 0
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND tip_nvta IN('E');
	
	SELECT	SUM(NVL(impasi_nvta,0))
	INTO	vrgaest
	FROM	nota_vta
	WHERE	fes_nvta = vfecfac and edo_nvta = 'A' AND impt_nvta > 0				
			AND tip_nvta IN('E');
			
	SELECT	SUM(NVL(impt_nvta,0)),SUM(NVL(tlts_nvta,0))
	INTO	vrgicar, vrglcar
	FROM	nota_vta
	WHERE	fes_nvta = vfecfac and edo_nvta = 'A' AND impt_nvta > 0
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND tip_nvta IN('B');
	
	SELECT	SUM(NVL(impasi_nvta,0))
	INTO	vrgacar
	FROM	nota_vta
	WHERE	fes_nvta = vfecfac and edo_nvta = 'A' AND impt_nvta > 0				
			AND tip_nvta IN('B');
			
	SELECT	SUM(NVL(impt_nvta,0)),SUM(NVL(tlts_nvta,0))
	INTO	vrgicil, vrglcil
	FROM	nota_vta
	WHERE	fes_nvta = vfecfac and edo_nvta = 'A' AND impt_nvta > 0
			AND (aju_nvta IS NULL OR aju_nvta <> 'S')
			AND tip_nvta IN('C','D','2','3','4');
	
	SELECT	SUM(NVL(impasi_nvta,0))
	INTO	vrgacil
	FROM	nota_vta
	WHERE	fes_nvta = vfecfac and edo_nvta = 'A' AND impt_nvta > 0				
			AND tip_nvta IN('C','D','2','3','4');
			
	LET vtotvta = vrgiest + vrgaest + vrgicar + vrgacar + vrgicil + vrgacil;
	
	RETURN 	vfecfac,
		vltsest,
		vimpest,
		vasiest,
		vltscar,
		vimpcar,
		vasicar,
		vkgscil,
		vimpcil,
		vasicil,
		vtotfac,
		vrglest,
		vrgiest,
		vrgaest,
		vrglcar,
		vrgicar,
		vrgacar,
		vrglcil,
		vrgicil,
		vrgacil,
		vtotvta
	WITH RESUME;
END FOREACH;

END PROCEDURE; 

SELECT 	fec_fac, sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
		sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
		sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
		sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
		sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
		sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
		sum(case when tid_dfac matches '[CD234]' THEN 
		(case when tid_dfac = 'C' THEN tlts_dfac ELSE
		(case when tid_dfac = 'D' THEN tlts_dfac ELSE
		(case when tid_dfac = '2' THEN tlts_dfac*20 ELSE
		(case when tid_dfac = '3' THEN tlts_dfac*30 ELSE
		(case when tid_dfac = '4' THEN tlts_dfac*45 ELSE 0 END) END) END) END) END)
		ELSE 0 END) kgs_cil,
		sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
		sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
FROM 	factura,det_fac
WHERE 	fec_fac between '2023-09-01' and '2023-09-01'
  		and tdoc_fac = 'I'
	  	and edo_fac <> 'C'
		and frf_fac is null
		and fol_fac = fol_dfac
		and ser_fac = ser_dfac		
GROUP BY 1

SELECT	SUM(NVL(impt_nvta,0)),SUM(NVL(tlts_nvta,0))
FROM	nota_vta
WHERE	fes_nvta = '2023-09-01' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E');
		
SELECT	SUM(impt_nvta),SUM(tlts_nvta)
FROM	nota_vta
WHERE	fes_nvta = '2023-09-01' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E');
		