EXECUTE PROCEDURE eruc_empkgs('2024-03-26','2023-04-11',2023,3,1)
DROP PROCEDURE eruc_empkgs;

CREATE PROCEDURE eruc_empkgs
(
	paramFecIni	DATE,
	paramFecFin	DATE,
	paramAnio	SMALLINT,
	paramMes	SMALLINT,
	paramQuin   SMALLINT
)
RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(100);		-- Mensaje error

DEFINE vresult  INT;
DEFINE vmensaje CHAR(100);
DEFINE vruta   	CHAR(4);
DEFINE vemp  	CHAR(5);
DEFINE vkgs 	DECIMAL;
DEFINE vtotkgs 	DECIMAL;
DEFINE vkgsbaj 	DECIMAL;
DEFINE vtotkgsb	DECIMAL;
DEFINE vtotal 	DECIMAL(6,2);
DEFINE vtotpen 	DECIMAL(6,2);
DEFINE vtotpena	DECIMAL(6,2);
DEFINE vfecham  DATE;
DEFINE vcoa     CHAR(2);

LET vresult = 0;
LET vmensaje = 'NO HAY  INFORMACIÓN EN EL PERIODO';

IF EXISTS(SELECT 1 FROM vta_empkgs WHERE quit_vempkgs = paramQuin AND anio_vempkgs = paramAnio AND mes_vempkgs = paramMes) THEN
	LET vresult = 0;
	LET vmensaje = 'YA EXISTE EL PERIODO AÑO: ' || paramAnio || ' MES: ' || paramMes || ' QUINCENA: ' || paramQuin;
	RETURN 	vresult,vmensaje;
END IF;

FOREACH cRutas FOR
	
	SELECT 	rut_eruc,chf_eruc
	INTO    vruta,vemp
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
	LET vtotal = 0;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND chf_eruc = vemp AND rut_eruc = vruta;
	
	LET vtotkgs = vtotkgs + vkgs;

	SELECT  NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay1_eruc = vemp AND rut_eruc = vruta;
	
	LET vtotkgs = vtotkgs + vkgs;

	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay2_eruc = vemp AND rut_eruc = vruta;

	LET vtotkgs = vtotkgs + vkgs;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND	edo_eruc = 'C'
			AND ay3_eruc = vemp AND rut_eruc = vruta;

	LET vtotkgs = vtotkgs + vkgs;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgs
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay4_eruc = vemp AND rut_eruc = vruta;
	
	LET vtotkgs = vtotkgs + vkgs;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND chf_eruc = vemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	SELECT  NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay1_eruc = vemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay2_eruc = vemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
			AND edo_eruc = 'C'
			AND ay3_eruc = vemp AND rut_eruc = vruta;
	
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	SELECT 	NVL(SUM(kgsu_eruc),0)
	INTO	vkgsbaj
	FROM 	empxrutcbaj
	WHERE 	fec_eruc BETWEEN paramFecIni AND paramFecFin
	  		AND edo_eruc = 'C'
	  		AND ay4_eruc = vemp AND rut_eruc = vruta;
			
	LET vtotkgsb = vtotkgsb + vkgsbaj;
	
	/*SELECT	SUM(vtapen_vempks)
	INTO	vtotpena
	FROM	vta_empksp
	WHERE	apl_vempks = 0;
	LET vtotal = vtotal + vtotpena;*/
		
	LET vtotal = (vtotkgs + vtotkgsb) / 20;
	--LET vtotpen = MOD(vtotkgs + vtotkgsb) > 0;
	 
	IF vtotal < 1 THEN 
		LET vtotal = 0;
	ELSE
		IF	vtotal - TRUNC(vtotal,0) <= 0.5 THEN
			LET vtotal = TRUNC(vtotal,0);
		ELSE 
			LET vtotal = TRUNC(vtotal,0) + 1;
		END IF;
	END IF;
	
	SELECT  MAX(fec_vemp),MAX(coa_vemp)
	INTO	vfecham,vcoa
	FROM	vtaxemp
	WHERE 	ruta_vemp = vruta AND emp_vemp = vemp
			AND fec_vemp BETWEEN paramFecIni AND paramFecFin;

	IF vtotal > 0 THEN		
		INSERT INTO vtaxemp VALUES(vemp,paramFecFin,vcoa,vruta,vtotal,0,'K',0);
	END IF;
	
	LET vresult = vresult + 1;
END FOREACH;

IF vresult > 0 THEN
	INSERT INTO vta_empkgs
	VALUES(paramQuin,paramMes,paramAnio,paramFecIni,paramFecFin);
	LET vmensaje = 'OK PERIODO AÑO: ' || paramAnio || ' MES: ' || paramMes || ' QUINCENA: ' || paramQuin;
END IF;

RETURN 	vresult,vmensaje;
END PROCEDURE; 


select *
from   empxrutc 
where  fec_eruc BETWEEN '2024-02-12' AND '2024-02-25' and rut_eruc = 'C064'

select  *
from	vtaxemp
where 	ruta_vemp = 'C010' 
        and fec_vemp BETWEEN '2024-02-12' AND '2024-02-25'
        
update  vtaxemp
set 	vta_vemp = 1140
where 	ruta_vemp = 'C010' and fec_vemp = '2024-02-24'

select  MAX(fec_vemp)
from	vtaxemp
where 	ruta_vemp = 'C064' and emp_vemp = '0884'
		and fec_vemp BETWEEN '2024-02-12' AND '2024-02-25'
		
select *
from 	vta_empkgs

delete 
from 	vta_empkgs
where 	quit_vempkgs = 1 and mes_vempkgs = 4 and anio_vempkgs = 2024

update  vta_empkgs
set 	quit_vempkgs = 2
where 	quit_vempkgs = 1 and mes_vempkgs = 5 and anio_vempkgs = 2024

SELECT 	rut_eruc,chf_eruc,SUM(kgsu_eruc),(SUM(kgsu_eruc)/20)
	FROM 	empxrutc
	WHERE 	fec_eruc BETWEEN '2024-02-12' AND '2024-02-25'
	  		AND edo_eruc = 'C'
AND chf_eruc IS NOT NULL AND LENGTH(chf_eruc) > 0
GROUP BY 1,2
HAVING 	SUM(kgsu_eruc) > 0


select *
from   vtaxemp
where  fec_vemp = '2023-02-15' and ncon_vemp = 0 and nanf_vemp = 0 and ruta_vemp[1] = 'C'
order by ruta_vemp

select *
from   vtaxemp
where  fec_vemp = '2023-02-15' and ruta_vemp = 'C002'
order by ruta_vemp
