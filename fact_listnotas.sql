DROP PROCEDURE fact_listnotas;
EXECUTE PROCEDURE fact_listnotas('','','2023-04-17');
EXECUTE PROCEDURE fact_listnotas('15','86','2022-12-16');

CREATE PROCEDURE fact_listnotas
(
	paramCia	CHAR(2),
	paramPla	CHAR(18),
	paramFecha	DATE
)
RETURNING 
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100),	-- Mensaje
 CHAR(2),	-- Cia
 CHAR(2),	-- Planta
 INT,		-- Folio
 SMALLINT,  -- Vuelta
 CHAR(4),	-- Ruta
 INT,		-- Folio liquidacion
 DATE,		-- Fecha surtido
 DECIMAL,	-- Importe
 DECIMAL,   -- Asistencia
 CHAR(6),	-- No de cliente
 CHAR(80),	-- Cliente
 CHAR(1),	-- Tipo facturacion clave
 CHAR(20);	-- Tipo facturacion

DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(100);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vfolio	INT;
DEFINE vvuelta 	INT;
DEFINE vruta	CHAR(4);
DEFINE vfolliq  INT;
DEFINE vfecha 	DATE;
DEFINE vimpt 	DECIMAL;
DEFINE vasist 	DECIMAL;
DEFINE vnumcte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vcvetfac	CHAR(1);
DEFINE vtipfact	CHAR(20);
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
LET vproceso = 1;
LET vmsg = '';
LET vcia = '';
LET vpla = '';
LET vfolio = 0;
LET vvuelta = 0;
LET vruta = '';
LET vfolliq = 0;
LET vfecha = '';
LET vimpt = 0;
LET vasist = 0;
LET vnumcte = '';
LET vnomcte = '';
LET vcvetfac = '';
LET vtipfact = '';

/*IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = paramFecha) THEN*/
	IF NOT EXISTS (SELECT 1 FROM empxrutp WHERE fec_erup = paramFecha and edo_erup <> 'C') AND
		NOT EXISTS (SELECT 1 FROM empxrutc WHERE fec_eruc = paramFecha and edo_eruc <> 'C')	AND
		NOT EXISTS (SELECT 1 FROM venxmed WHERE fec_vmed = paramFecha and edo_vmed <> 'C') AND
		NOT EXISTS (SELECT 1 FROM venxand WHERE fec_vand = paramFecha and edo_vand <> 'C') AND
		NOT EXISTS (SELECT 1 FROM des_dir WHERE fec_desd = paramFecha and edo_desd <> 'C') THEN		
			FOREACH cClientes FOR
			SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
					NVL(n.impasi_nvta, 0), n.numcte_nvta, cf.tipfac_cfac,
					CASE WHEN cf.tipfac_cfac = 'D' THEN 'POR DIA' WHEN cf.tipfac_cfac = 'N' THEN 'POR NOTA DE VENTA' END			
			INTO	vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vasist,vnumcte,vcvetfac,vtipfact
			FROM 	nota_vta n, cte_fac cf
			WHERE	n.numcte_nvta = cf.numcte_cfac 
					AND (n.cia_nvta = paramCia OR paramCia = '')
					AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
					AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')
					AND fac_nvta IS NULL
			ORDER BY n.numcte_nvta, n.pla_nvta
				
			SELECT	NVL(CASE 
					WHEN TRIM(cliente.razsoc_cte) <> '' THEN
					   TRIM(cliente.razsoc_cte) 
					ELSE 
					   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
					END,'')
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnumcte;
			LET vmsg = 'OK';
			RETURN 	vproceso,vmsg,vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vasist,vnumcte,vnomcte,vcvetfac,vtipfact
			WITH RESUME;
		END FOREACH; 
	ELSE
		LET vproceso = 0;
		LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS, NO SE HAN CERRADO TODAS LAS LIQUIDACIONES DE VENTA.';
		RETURN 	vproceso,vmsg,vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vasist,vnumcte,vnomcte,vcvetfac,vtipfact;
	END IF;
/*ELSE
	LET vproceso = 0;
	LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS, EL DIA YA ESTA CERRADO.';	
	RETURN 	vproceso,vmsg,vcia,vpla,vfolio,vvuelta,vruta,vfolliq,vfecha,vimpt,vasist,vnumcte,vnomcte,vcvetfac,vtipfact;
END IF;*/
END PROCEDURE;

select	fec_fac, count(*)
from	factura
where	fec_fac >= '2023-03-01' and tdoc_fac = 'I'  
group by 1

SELECT	n.fes_nvta, count(*)
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 
		AND fes_nvta >= '2023-03-09' AND edo_nvta = 'S' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
GROUP BY 1
		
SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fliq_nvta, n.fes_nvta, n.impt_nvta,
		NVL(n.impasi_nvta, 0), n.numcte_nvta, 
		CASE WHEN cf.tipfac_cfac = 'D' THEN 'POR DIA' WHEN cf.tipfac_cfac = 'N' THEN 'POR NOTA DE VENTA' END			
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 
		AND fes_nvta = '2022-12-16' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL

select	*
from	cte_fac
order by numcte_cfac

select	*
from	empxrutp
where	fec_erup = '2023-01-24'

select	*
from	empxrutc
where	fec_eruc = '2023-01-24'

select	*
from	venxmed
where	fec_vmed = '2023-01-24'

select	*
from	venxand
where	fec_vand = '2023-01-16'

select	*
from	des_dir
where	fec_desd = '2023-01-24'

SELECT 	sum(impt_eruc),sum(impasi_eruc)
FROM 	empxrutc
WHERE 	fec_eruc = '2023-01-16' 
		AND edo_eruc = 'C';
		
SELECT 	*
FROM 	venxand
WHERE 	fec_vand = '2023-01-25' 
		AND edo_vand = 'C';
		
SELECT 	sum(impt_desd)
FROM 	des_dir  
WHERE 	fec_desd = '2023-01-16' 
		AND edo_desd = 'C';

select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-01-16' and edo_nvta = 'A' 
		AND ruta_nvta[1] in('B')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta = 'B'

select	count(*)
from	nota_vta
where	fes_nvta = '2023-01-16' and edo_nvta = 'A' 
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null
		
select	fes_nvta, count(*)
from	nota_vta
where	fes_nvta >= '2023-02-01' and edo_nvta = 'A' 
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null
group by 1
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-02-22' and edo_nvta = 'A' 
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null

select	*
from	nota_vta
where	fes_nvta = '2023-01-25' 
		and (aju_nvta IS NOT NULL OR aju_nvta = 'S')
		
select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-01-16' 
		and (aju_nvta IS NOT NULL OR aju_nvta = 'S')
		and ruta_nvta <> 'M099'
		
select	tip_nvta,count(*)
from	nota_vta
where	fes_nvta >= '2023-01-01'  and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
group by 1

select	*
from	nota_vta
where  fes_nvta >= '2023-01-01'  and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta = ''

select	sum(impt_nvta)
from	nota_vta
where  fes_nvta = '2023-01-16'  and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B','C','D','E')

		
select	epo_impv,*
from	e_posaj
where 	epo_fec = '2023-04-25'

select	*
from	nota_vta
where	fes_nvta = '2023-02-14' 
		and tpa_nvta = 'C' and edo_nvta = 'S'
		and numcte_nvta not in(select num_cte from cliente)
		and numcte_nvta || numtqe_nvta not in(select numcte_tqe || numtqe_tqe
			                                    from	tanque)

select	fol_nvta, count(*)
from	nota_vta
where	fes_nvta = '2023-02-14' 
		and tpa_nvta = 'C' and edo_nvta = 'S'
group by fol_nvta
having count(*) > 1

select	*
from	nota_vta
where	fes_nvta = '2023-05-01' and edo_nvta = 'A'