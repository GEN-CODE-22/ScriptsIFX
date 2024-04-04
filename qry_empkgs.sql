EXECUTE PROCEDURE qry_empkgs('2024-02-26','2024-03-11');
DROP PROCEDURE qry_empkgs;

CREATE PROCEDURE qry_empkgs
(
	paramFecIni	DATE,
	paramFecFin	DATE
)
RETURNING  
 CHAR(4),		-- Ruta
 CHAR(11),		-- Clave Chofer
 CHAR(50),		-- Nombre Chofer
 DECIMAL,		-- Kilos Sueltos
 DECIMAL(6,2);	-- Kilos Sueltos / 20
 --DECIMAL(6,2);	-- Kilos Sueltos Pendientes

DEFINE vruta	CHAR(4);
DEFINE vcveemp 	CHAR(5);
DEFINE vcatemp 	CHAR(11);
DEFINE vemp   	CHAR(50);
DEFINE vkgs 	DECIMAL;
DEFINE vtotkgs 	DECIMAL;
DEFINE vkgsbaj 	DECIMAL;
DEFINE vtotkgsb	DECIMAL;
DEFINE vtottalk	DECIMAL;
DEFINE vtotal 	DECIMAL(6,2);
DEFINE vtotpen  DECIMAL(6,2);

LET vtotkgs = 0;
LET vtotkgsb = 0;
LET vtottalk = 0;
LET vtotal = 0;

FOREACH cRuta FOR
    SELECT 	rut_eruc,chf_eruc
	INTO    vruta,vcveemp
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
				AND edo_eruc = 'C'
			AND chf_eruc IS NOT NULL AND LENGTH(chf_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0 
	UNION
	SELECT 	rut_eruc,chf_eruc
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND chf_eruc IS NOT NULL AND LENGTH(chf_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0
	UNION
	SELECT 	rut_eruc,ay1_eruc
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay1_eruc IS NOT NULL AND LENGTH(ay1_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0 
	UNION
	SELECT 	rut_eruc,ay1_eruc
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay1_eruc IS NOT NULL AND LENGTH(ay1_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0
	UNION
	SELECT 	rut_eruc,ay2_eruc
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay2_eruc IS NOT NULL AND LENGTH(ay2_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0 
	UNION
	SELECT 	rut_eruc,ay2_eruc
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay2_eruc IS NOT NULL AND LENGTH(ay2_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0
	UNION
	SELECT 	rut_eruc,ay3_eruc
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay3_eruc IS NOT NULL AND LENGTH(ay3_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0 
	UNION
	SELECT 	rut_eruc,ay3_eruc
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay3_eruc IS NOT NULL AND LENGTH(ay3_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0
	UNION
	SELECT 	rut_eruc,ay4_eruc
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay4_eruc IS NOT NULL AND LENGTH(ay4_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0 
	UNION
	SELECT 	rut_eruc,ay4_eruc
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay4_eruc IS NOT NULL AND LENGTH(ay4_eruc) > 0
	GROUP BY 1,2
	HAVING 	SUM(kgsu_eruc) > 0
	ORDER BY 1,2
	
	LET vtotkgs = 0;
	LET vtotkgsb = 0;
	LET vtottalk = 0;
	LET vtotal = 0;

	SELECT  cat_emp,TRIM(ape_emp) || ' ' || TRIM(nom_emp)
	INTO	vcatemp, vemp
	FROM	empleado
	WHERE 	cve_emp = vcveemp;

	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND chf_eruc = vcveemp AND rut_eruc = vruta;
	
	LET vtotkgs = vtotkgs + vkgs;

	SELECT  NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay1_eruc = vcveemp AND rut_eruc = vruta;
	
	LET vtotkgs = vtotkgs + vkgs;

	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay2_eruc = vcveemp AND rut_eruc = vruta;

	LET vtotkgs = vtotkgs + vkgs;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND	edo_eruc = 'C'
			AND ay3_eruc = vcveemp AND rut_eruc = vruta;

	LET vtotkgs = vtotkgs + vkgs;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay4_eruc = vcveemp AND rut_eruc = vruta;
	
	LET vtotkgs = vtotkgs + vkgs;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND chf_eruc = vcveemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	SELECT  NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay1_eruc = vcveemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay2_eruc = vcveemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay3_eruc = vcveemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay4_eruc = vcveemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	LET vtottalk = vtotkgs + vtotkgsb;
	
	LET vtotal = vtottalk / 20;
	
	 
	IF vtotal < 1 THEN 
		LET vtotal = 0;
	ELSE
		IF	vtotal - TRUNC(vtotal,0) <= 0.5 THEN
			LET vtotal = TRUNC(vtotal,0);
		ELSE 
			LET vtotal = TRUNC(vtotal,0) + 1;
		END IF;
	END IF;
	
	/*SELECT	SUM(vtapen_vempks)
	INTO	vtotpen
	FROM	vta_empksp
	WHERE	apl_vempks = 0;*/
	
	RETURN 	vruta,vcatemp,vemp,vtottalk,vtotal--,vtotpen
	WITH RESUME;
END FOREACH;

END PROCEDURE; 

select *
from   empxrutc 
where  fec_eruc BETWEEN '2023-02-26' AND '2023-03-11' and rut_eruc = 'C002'

select *
from   empxrutcbaj
where  fec_eruc BETWEEN '2023-02-26' AND '2023-03-11' and rut_eruc = 'C002'

select  *
from 	vtaxemp
where   ruta_vemp = 'C002' 
	and fec_vemp BETWEEN '2023-02-26' AND '2023-03-11'

select  MAX(fec_vemp)
from	vtaxemp
where 	ruta_vemp = 'C010' and emp_vemp = '0514'
		and fec_vemp BETWEEN '2024-02-12' AND '2024-02-25'
		
select *
from 	vta_empkgs

select  trunc(3.5,0),trunc(3.6,0), round(3.5,0), round(3.6,1)
from 	datos

SELECT 	rut_eruc,chf_eruc,SUM(kgsu_eruc),(SUM(kgsu_eruc)/20)
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN '2024-02-26' AND '2024-03-11'
	  		AND edo_eruc = 'C'
	  		AND chf_eruc IS NOT NULL AND LENGTH(chf_eruc) > 0
	  		and rut_eruc = 'C055'
	  		
	  		GROUP BY 1,2
	  		
SELECT 	rut_eruc,chf_eruc,SUM(kgsu_eruc),(SUM(kgsu_eruc)/20)
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN '2024-02-26' AND '2024-03-11'
	  		AND edo_eruc = 'C'
	  		AND chf_eruc IS NOT NULL AND LENGTH(chf_eruc) > 0
	  		and rut_eruc = 'C055'
	  		
	  		GROUP BY 1,2
	  		
SELECT 	rut_eruc,chf_eruc
FROM 	empxrutc
WHERE 	fec_eruc BETWEEN '2024-02-26' AND '2024-03-11'
	  		AND edo_eruc = 'C'
AND chf_eruc IS NOT NULL AND LENGTH(chf_eruc) > 0
GROUP BY 1,2
HAVING 	SUM(kgsu_eruc) > 0 --order by 1,2
UNION
SELECT 	rut_eruc,chf_eruc
FROM 	empxrutcbaj
WHERE 	fec_eruc BETWEEN '2024-02-26' AND '2024-03-11'
  		AND edo_eruc = 'C'
  		AND chf_eruc IS NOT NULL AND LENGTH(chf_eruc) > 0
GROUP BY 1,2
HAVING 	SUM(kgsu_eruc) > 0
order by 1,2