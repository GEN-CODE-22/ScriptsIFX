EXECUTE PROCEDURE RPT_FactRepTopF('2024-07-01','2024-07-31',100);

DROP PROCEDURE RPT_FactRepTopF;

CREATE PROCEDURE RPT_FactRepTopF
(
	paramFecIni	DATE,
	paramFecFin	DATE,
	paramTop	INT
)

RETURNING  
 CHAR(13), 
 CHAR(80), 
 CHAR(40), 
 CHAR(40), 
 CHAR(30),
 CHAR(6), 
 INT,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL;

DEFINE vrfc    	CHAR(13);
DEFINE vnomcte 	CHAR(80);
DEFINE vdir	   	CHAR(40);
DEFINE vcol		CHAR(40);
DEFINE vciu 	CHAR(40);
DEFINE vcodpos 	CHAR(6);
DEFINE vtel  	INT;
DEFINE vsimp    DECIMAL;
DEFINE vsimpnc  DECIMAL;
DEFINE vdif     DECIMAL;
DEFINE vtlts 	DECIMAL;
DEFINE vcount 	DECIMAL;

LET vsimp = 0;
LET vsimpnc = 0;
LET vdif = 0;
LET vtlts = 0;
LET vcount = 0;

FOREACH cFacturas FOR
	SELECT  rfc_fac, SUM(simp_fac)
	INTO	vrfc,vsimp
	FROM 	factura
	WHERE 	fec_fac BETWEEN paramFecIni AND paramFecFin AND tdoc_fac IN('I','V') AND edo_fac <> 'C'
			AND (frf_fac  IS NULL OR frf_fac = 0) AND rfc_fac IS NOT NULL AND LENGTH(rfc_fac) > 0
			AND rfc_fac <> 'XAXX010101000' 
	GROUP BY 1
	ORDER BY 2 DESC
	
	LET vsimpnc = 0;
	LET vdif = 0;
	LET vtlts = 0;
	
	IF vrfc <> '' THEN
		SELECT	MAX(NVL(CASE 
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
				END,'')), MAX(dir_cte), MAX(col_cte), MAX(ciu_cte), MAX(NVL(codpo_cte,'')), MAX(NVL(tel_cte,0))
		INTO	vnomcte,vdir,vcol,vciu,vcodpos,vtel
		FROM	cliente
		WHERE	rfc_cte = vrfc;
	END IF;
	
	SELECT  NVL(SUM(simp_ncrd),0)
	INTO	vsimpnc
	FROM 	nota_crd
	WHERE 	fec_ncrd BETWEEN paramFecIni AND paramFecFin AND tdoc_ncrd = 'E' AND edo_ncrd <> 'C'
			AND (frnc_ncrd  IS NULL OR frnc_ncrd = 0) AND rfc_ncrd = vrfc;
	
	LET vdif = vsimp - vsimpnc;

	SELECT SUM(tlts_nvta)
	INTO	vtlts
	FROM    nota_vta n, cliente c
	WHERE   fes_nvta BETWEEN paramFecIni AND paramFecIni AND edo_nvta = 'A'
		    AND (aju_nvta IS NULL OR aju_nvta <> 'S')  
		    AND n.numcte_nvta = c.num_cte
		    AND c.rfc_cte = vrfc;
			
	LET vcount = vcount + 1;
	
	--IF vcount <= paramTop THEN
		RETURN 	vrfc,vnomcte,vdir,vcol,vciu,vcodpos,vtel,vsimp,vsimpnc,vdif,vtlts
		--RETURN 	vrfc,vnomcte,vdir,vcol,vciu,vcodpos,vtel,vsimp,vsimpnc,vdif
		WITH RESUME;
	--END IF;
	
END FOREACH;

END PROCEDURE; 

select  first 10 rfc_fac, sum(simp_fac)
from 	factura
where 	fec_fac between '2024-07-01' and '2024-07-31' and tdoc_fac = 'I' and edo_fac <> 'C'
		and (frf_fac  is null or frf_fac = 0) --and rfc_fac = 'PPR910701LEA'
group by 1
order by 2 desc

select  rfc_ncrd, sum(simp_ncrd)
from 	nota_crd
where 	fec_ncrd between '2024-07-01' and '2024-07-31' and tdoc_ncrd = 'E' and edo_ncrd <> 'C'
		and (frnc_ncrd  is null or frnc_ncrd = 0) and rfc_ncrd = 'PPR910701LEA'
group by 1
order by 2 desc

select sum(tlts_nvta)
from   nota_vta n, cliente c
where  fes_nvta between '2024-07-01' and '2024-07-31' and edo_nvta = 'A'
	   and (aju_nvta IS NULL OR aju_nvta <> 'S')  
	   and n.numcte_nvta = c.num_cte
	   and c.rfc_cte = 'PPR910701LEA'
	   
select  first 10 *
from 	factura
where 	fec_fac between '2024-07-01' and '2024-07-31'  and tdoc_fac = 'I'