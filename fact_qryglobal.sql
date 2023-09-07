DROP PROCEDURE fact_qryglobal;
EXECUTE PROCEDURE fact_qryglobal('2023-04-19');

CREATE PROCEDURE fact_qryglobal
(
	paramFecha	DATE
)
RETURNING 
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(255),	-- Mensaje
 DECIMAL,	-- Venta Estacionario
 DECIMAL,	-- Asistencia Estacionario
 DECIMAL,	-- Facturado Estacionario
 DECIMAL,	-- Asistencia Facturado Estacionario
 DECIMAL,	-- Importe Estacionario
 DECIMAL,	-- Importe Asistencia Estacionario
 DECIMAL,	-- Venta Carburacion
 DECIMAL,	-- Asistencia Carburacion
 DECIMAL,	-- Facturado Carburacion
 DECIMAL,	-- Asistencia Facturado Carburacion
 DECIMAL,	-- Importe Carburacion
 DECIMAL,	-- Importe Asistencia Carburacion
 DECIMAL,	-- Venta Cilindros
 DECIMAL,	-- Asistencia Cilindros
 DECIMAL,	-- Facturado Cilindros
 DECIMAL,	-- Asistencia Facturado Cilindros
 DECIMAL,	-- Importe Cilindros
 DECIMAL;	-- Importe Asistencia Cilindros

DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(255);
DEFINE vvest	DECIMAL;
DEFINE vvaest	DECIMAL;
DEFINE vfest	DECIMAL;
DEFINE vfaest	DECIMAL;
DEFINE vimpest	DECIMAL;
DEFINE vasisest	DECIMAL;
DEFINE vvcar	DECIMAL;
DEFINE vvacar	DECIMAL;
DEFINE vfcar	DECIMAL;
DEFINE vfacar	DECIMAL;
DEFINE vimpcar	DECIMAL;
DEFINE vasiscar	DECIMAL;
DEFINE vvcil	DECIMAL;
DEFINE vvacil	DECIMAL;
DEFINE vfcil	DECIMAL;
DEFINE vfacil	DECIMAL;
DEFINE vimpcil	DECIMAL;
DEFINE vasiscil	DECIMAL;
DEFINE vfolnvta	INT;

LET vproceso = 1;
LET vmsg = 'OK';
LET vfolnvta = 0;

IF EXISTS (SELECT	1
			FROM 	nota_vta n, cte_fac cf
			WHERE	n.numcte_nvta = cf.numcte_cfac 					
					AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
					AND tip_nvta IN('B','C','D','E','2','3','4')
					AND (aju_nvta IS NULL OR aju_nvta <> 'S')
					AND fac_nvta IS NULL) THEN
					LET vproceso = 0;
					LET vmsg = 'EXISTEN NOTAS SIN FACTURAR. EJECUTAR PROCESO DE FACTURACION AUTOMATICA.';
					RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
END IF;

SELECT	NVL(MIN(fol_nvta),0)
INTO	vfolnvta
FROM	nota_vta
WHERE	fes_nvta = paramFecha and edo_nvta in('A') 
		and ((impt_nvta - (tlts_nvta * pru_nvta) < -0.1) or  (impt_nvta - (tlts_nvta * pru_nvta) > 0.1))
		and tip_nvta in('C','D','2','3','4', 'E','B');

IF vfolnvta > 0 THEN
	LET vproceso = 0;
	LET vmsg = 'NOTA: ' || vfolnvta || ' TIENE PRECIO INCORRECTO';
	RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
END IF;


IF EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = paramFecha) THEN
	IF NOT EXISTS (SELECT 1 FROM empxrutp WHERE fec_erup = paramFecha and edo_erup <> 'C') AND
		NOT EXISTS (SELECT 1 FROM empxrutc WHERE fec_eruc = paramFecha and edo_eruc <> 'C')	AND
		NOT EXISTS (SELECT 1 FROM venxmed WHERE fec_vmed = paramFecha and edo_vmed <> 'C') AND
		NOT EXISTS (SELECT 1 FROM venxand WHERE fec_vand = paramFecha and edo_vand <> 'C') AND
		NOT EXISTS (SELECT 1 FROM des_dir WHERE fec_desd = paramFecha and edo_desd <> 'C') THEN	
			
		-- ESTACIONARIO------------------------------------
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vvest
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('E');
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vvaest
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0				
				AND tip_nvta IN('E');
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vfest
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('E')
				AND fac_nvta IS NOT NULL;
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vfaest
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('E')
				AND fac_nvta IS NOT NULL;
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vimpest
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('E')
				AND fac_nvta IS NULL;
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vasisest
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0				
				AND tip_nvta IN('E')
				AND fac_nvta IS NULL;
				
		-- CARBURACION------------------------------------
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vvcar
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('B');
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vvacar
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('B');
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vfcar
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('B')
				AND fac_nvta IS NOT NULL;
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vfacar
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('B')
				AND fac_nvta IS NOT NULL;
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vimpcar
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('B')
				AND fac_nvta IS NULL;
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vasiscar
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('B')
				AND fac_nvta IS NULL;
				
		-- CILINDROS------------------------------------
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vvcil
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('C','D','2','3','4');
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vvacil
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('C','D','2','3','4');
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vfcil
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('C','D','2','3','4')
				AND fac_nvta IS NOT NULL;
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vfacil
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('C','D','2','3','4')
				AND fac_nvta IS NOT NULL;
				
		SELECT	SUM(NVL(impt_nvta,0))
		INTO	vimpcil
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND (aju_nvta IS NULL OR aju_nvta <> 'S')
				AND tip_nvta IN('C','D','2','3','4')
				AND fac_nvta IS NULL;
		SELECT	SUM(NVL(impasi_nvta,0))
		INTO	vasiscil
		FROM	nota_vta
		WHERE	fes_nvta = paramFecha and edo_nvta = 'A' AND impt_nvta > 0
				AND tip_nvta IN('C','D','2','3','4')
				AND fac_nvta IS NULL;
				
		RETURN 	vproceso,vmsg,vvest,vvaest,vfest,vfaest,vimpest,vasisest,vvcar,vvacar,vfcar,vfacar,vimpcar,vasiscar,vvcil,vvacil,vfcil,vfacil,vimpcil,vasiscil;
	ELSE 
		LET vproceso = 0;
		LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS GLOBALES, NO SE HAN CERRADO TODAS LAS LIQUIDACIONES DE VENTA.';
		RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
	END IF;
ELSE
	LET vproceso = 0;
	LET vmsg = 'NO SE PUEDEN GENERAR LAS FACTURAS GLOBALES, EL DIA NO ESTA CERRADO.';	
	RETURN 	vproceso,vmsg,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
END IF;
END PROCEDURE;

select	*
from	empxrutp
where	fec_erup = '2023-04-04'

select	*
from	empxrutc
where	fec_eruc = '2023-04-04'

select	*
from	venxmed
where	fec_vmed = '2023-04-04'

select	*
from	venxand
where	fec_vand >= '2023-04-01'

select	*
from	des_dir
where	fec_desd = '2023-01-24'

select	*
from	gto_gas
where	fec_ggas = '2023-01-24'

select	*
from	gto_die
where	fec_gdie = '2023-01-24'

SELECT 	sum(impt_eruc),sum(impasi_eruc)
FROM 	empxrutc
WHERE 	fec_eruc = '2023-01-16' 
		AND edo_eruc = 'C';
		
SELECT 	*
FROM 	venxand
WHERE 	fec_vand >= '2023-03-10' 
		AND edo_vand = 'C';
		
SELECT 	sum(impt_desd)
FROM 	des_dir  
WHERE 	fec_desd = '2023-01-16' 
		AND edo_desd = 'C';

select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta >= '2023-01-01' and fes_nvta <= '2023-01-31' and edo_nvta = 'A' 
		--AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E')
		
select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-05-02' and edo_nvta = 'A' 
		--AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B','C','D','E')
		
Select  tid_dfac, SUM(impasi_dfac) imp_asi , sum(tlts_dfac) cantidad,  SUM(tlts_dfac*pru_dfac ) importe 
from    factura, det_fac 
where   fec_fac  BETWEEN  '2023/03/01' and '2023/03/31' and tdoc_fac = 'I' 
		and edo_fac <> 'C' and  faccer_fac = 'N' and fol_dfac = fol_fac  and ser_dfac= ser_fac 
		and tfac_fac <> 'O' and (frf_fac is null or frf_fac = 0) 
GROUP BY   tid_dfac  
order by tid_dfac

select	sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-02-10' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('E')

select	sum(simp_nvta), sum(iva_nvta), sum(impt_nvta), sum(NVL(impasi_nvta,0))
from	nota_vta
where	fes_nvta = '2023-01-16' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null
		AND tip_nvta IN('E','B')
		
select	epo_impv,*
from	e_posaj
where 	epo_fec = '2023-05-02'

update	e_posaj
set		epo_fec = '2024-12-16'
where 	epo_fec = '2021-12-16'

select	*
from	factura
where	fol_fac = 87717 and ser_fac = 'EAK'

delete	
from	factura
where	fol_fac = 87717 and ser_fac = 'EAK' 

select	*
from	det_fac
where	fol_dfac = 87717 and ser_dfac = 'EAK'
order by mov_dfac

select	count(*)
from	det_fac
where	fol_dfac = 6000000 and ser_dfac = 'EAB'

delete
from	det_fac
where	fol_dfac = 87717 and ser_dfac = 'EAK'

select	sum(simp_dfac), sum(impasi_dfac)
from	det_fac
where	fol_dfac = 6000000 and ser_dfac = 'EAB'

select	*
from	cfd
where	fol_cfd = 87717

delete
from	cfd
where	fol_cfd = 87717 and ser_cfd = 'EAK'

select	*
from	nota_vta where fes_nvta = '2023-05-02' and edo_nvta = 'S'
where	fol_nvta = 504338

select	fes_nvta, count(*)
from	nota_vta 
where	fac_nvta is null
group by 1
order by fes_nvta

update	nota_vta
set		fac_nvta = null, ser_nvta = null
where	fac_nvta in(202214) and ser_nvta = 'EAP'


INSERT INTO factura
VALUES('M',1000000,'EAB','15','02','2022-02-15','999999','E','P','E', 693.94, 111.03, 804.97, null, 'suleima',null,null,null,null,null,null,'N','N','2022-02-15 08:57:52','N',null,null,'A7F10A01-9F3F-4F3E-9151-06C8EE198735','N','3','I',null,'ISI860319MW0','E',null,null,null,null,null);	

INSERT INTO det_fac 
VALUES(1000000,'EAB','15','02',1,'E',321531,null,65.00,'001',12.1700000000,null,681.94,13.92,12,'LP/14462/DIST/PLA/2016-2202141502321531');	

SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta = '2023-06-01' and edo_nvta = 'A' 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D','2','3','4','E','B')
		AND fac_nvta IS NOT NULL
		AND fac_nvta not in (223531,223532);
		
SELECT	*
FROM	nota_vta
WHERE	fes_nvta = '2023-05-02' and edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('C','D','E','B') 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS  NULL
		and impasi_nvta > 0		

SELECT	SUM(NVL(impasi_nvta,0))
FROM	nota_vta
WHERE	fes_nvta between '2023-05-02' and '2023-05-02' and edo_nvta = 'A' AND impt_nvta > 0				
		AND tip_nvta IN('C','D')
		AND fac_nvta IS NULL;

SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta between '2023-03-01' and '2023-03-31' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('C','D');	

SELECT	SUM(NVL(impasi_nvta,0))
FROM	nota_vta
WHERE	fes_nvta between '2023-03-01' and '2023-03-31' and edo_nvta = 'A' AND impt_nvta > 0				
		AND tip_nvta IN('E')
		AND fac_nvta IS NULL;
		
SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta between '2023-05-02' and '2023-05-02' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and fac_nvta is not null
		--AND tip_nvta IN('B')
		--AND fac_nvta = 156913;	

SELECT	SUM(NVL(impasi_nvta,0))
FROM	nota_vta
WHERE	fes_nvta between '2023-05-02' and '2023-05-02' and edo_nvta = 'A' AND impt_nvta > 0				
		AND tip_nvta IN('B')
		AND fac_nvta IS NULL;

select	*
from	factura
where	frf_fac = 156913 and fec_fac >= '2023-05-02'

select	*
from	det_fac
where	fol_dfac = 72662 and ser_dfac = 'EAMB'

select	*
from	nota_vta
where	fol_nvta = 289363
		
SELECT	*
FROM	nota_vta
WHERE	fes_nvta between '2023-03-01' and '2023-03-31' and edo_nvta = 'A' AND impt_nvta > 0				
		AND tip_nvta IN('B') and impasi_nvta > 0 and ruta_nvta[1] = 'M'
		
SELECT	*
FROM	nota_vta
WHERE	fes_nvta between '2023-03-01' and '2023-03-31' and edo_nvta = 'S'

select	aju_nvta, sum(impasi_nvta)
from	nota_vta
where	fes_nvta = '2023-05-01' and edo_nvta = 'A' and impasi_nvta > 0
		and tip_nvta  IN('C','D')
group by 1

select	*
from	nota_vta
where	fes_nvta = '2023-05-02' and edo_nvta = 'A' and impasi_nvta > 0
		and tip_nvta  IN('B')
		and fac_nvta not in(156913)
group by 1

SELECT	SUM(NVL(impasi_nvta,0))
FROM	nota_vta
WHERE	fes_nvta = '2023-05-02' and edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('C','D');

select	*
from	deposito
order by fec_depo desc

SELECT	SUM(NVL(impt_nvta,0))
FROM	nota_vta
WHERE	fes_nvta = '2023-05-04' and edo_nvta = 'A' AND impt_nvta > 0
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND tip_nvta IN('B')
		AND fac_nvta IS NOT NULL;
		
SELECT	*
FROM 	nota_vta n, cte_fac cf
WHERE	n.numcte_nvta = cf.numcte_cfac 					
		AND fes_nvta = '2023-06-04' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		