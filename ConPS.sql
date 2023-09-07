CREATE PROCEDURE ConPS
(
	paramCia   CHAR(2),
	paramPla   CHAR(2),
	paramRuta  CHAR(4),
	paramUsr   CHAR(40),
	paramAnio  INT,
	paramMes   INT
)
RETURNING
 CHAR(6),
 CHAR(70),
 CHAR(20),
 DATE,
 DECIMAL,
 DECIMAL,
 INT,
 CHAR(4);

 DEFINE lnumcte 	CHAR(6);
 DEFINE lnomcte 	VARCHAR(70);
 DEFINE ltelcte 	CHAR(20);
 DEFINE lfecha  	DATE;
 DEFINE ltotlts 	DECIMAL;
 DEFINE ltotpes 	DECIMAL;
 DEFINE lnota 		DECIMAL;
 DEFINE lruta 		CHAR(4);
 DEFINE vsurvey_cfg CHAR(50);
 DEFINE vtpdopro 	CHAR(1);
 DEFINE vtpdosurvey	CHAR(1);

LET	vtpdopro = 'P';
LET	vtpdosurvey = '';

SELECT	value_cfg
INTO	vsurvey_cfg
FROM	cfg_llam
WHERE	key_cfg = 'ACTIVESURVEY_CFG';

IF	vsurvey_cfg = '1'	THEN
	LET	vtpdosurvey = 'E';
END IF;

FOREACH cCursor FOR
	SELECT	cliente.num_cte, 
			CASE 
				   WHEN TRIM(cliente.razsoc_cte) <> '' THEN
		  
			 TRIM(cliente.razsoc_cte) 
				ELSE 
				   CASE
					  WHEN cliente.ali_cte <> '' THEN
						 TRIM(cliente.ali_cte) || ', ' 
					  ELSE
						 '' 
				   END || trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
			 END AS nom_cte,
		   '(' || cliente.lada_cte || ') ' || cliente.tel_cte tel_cte,		
		   nota_vta.fes_nvta fecha,
		   nota_vta.tlts_nvta,
		   nota_vta.impt_nvta,
		   nota_vta.fol_nvta,
		   nota_vta.ruta_nvta
	INTO   lnumcte,
		   lnomcte,
		   ltelcte,
		   lfecha,
		   ltotlts,
		   ltotpes,
		   lnota,       
		   lruta
	FROM   cliente,
		   nota_vta 
	WHERE  nota_vta.numcte_nvta         = cliente.num_cte			
		   AND YEAR(nota_vta.fes_nvta)  = paramAnio          		
		   AND MONTH(nota_vta.fes_nvta) = paramMes            		
		   AND nota_vta.edo_nvta		IN('A','S')
		   AND nota_vta.cia_nvta      	= paramCia  
		   AND nota_vta.pla_nvta      	= paramPla
		   AND (nota_vta.ruta_nvta      = paramRuta OR LENGTH(paramRuta) = 0 )
		   AND (nota_vta.ped_nvta		IN (SELECT 	num_ped 
		   									FROM	pedidos  
		   									WHERE  	num_ped = nota_vta.ped_nvta 
		   											AND (tpdo_ped IN (vtpdopro) OR  tpdo_ped IN (vtpdosurvey))
		   											AND edo_ped = 'S'
		   									       	AND (LENGTH(paramUsr) = 0 OR UPPER(usrrp_ped) = UPPER(paramUsr)))
		   OR nota_vta.ped_nvta		    IN (SELECT 	num_ped 
		   									FROM 	hpedidos  
		   									WHERE  	num_ped = nota_vta.ped_nvta 
		   											AND (tpdo_ped IN (vtpdopro) OR  tpdo_ped IN (vtpdosurvey))
		   											AND edo_ped = 'S'
		   									       	AND (LENGTH(paramUsr) = 0 OR UPPER(usrrp_ped) = UPPER(paramUsr))))  
	UNION
	SELECT	cliente.num_cte, 
			CASE 
				   WHEN TRIM(cliente.razsoc_cte) <> '' THEN
		  
			 TRIM(cliente.razsoc_cte) 
				ELSE 
				   CASE
					  WHEN cliente.ali_cte <> '' THEN
						 TRIM(cliente.ali_cte) || ', ' 
					  ELSE
						 '' 
				   END || trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
			 END AS nom_cte,
		   '(' || cliente.lada_cte || ') ' || cliente.tel_cte tel_cte,		
		   rdnota_vta.fes_nvta fecha,
		   rdnota_vta.tlts_nvta,
		   rdnota_vta.impt_nvta,
		   rdnota_vta.fol_nvta,
		   rdnota_vta.ruta_nvta	
	FROM   cliente,
		   rdnota_vta 
	WHERE  rdnota_vta.numcte_nvta         	= cliente.num_cte			
		   AND YEAR(rdnota_vta.fes_nvta)  	= paramAnio          		
		   AND MONTH(rdnota_vta.fes_nvta) 	= paramMes            		
		   AND rdnota_vta.edo_nvta			IN('A','S')
		   AND rdnota_vta.cia_nvta      	= paramCia  
		   AND rdnota_vta.pla_nvta      	= paramPla
		   AND (rdnota_vta.ruta_nvta      	= paramRuta OR LENGTH(paramRuta) = 0 )
		   AND (rdnota_vta.ped_nvta			IN (SELECT 	num_ped 
		   										FROM	pedidos  
			   									WHERE  	num_ped = rdnota_vta.ped_nvta 
			   											AND (tpdo_ped IN (vtpdopro) OR  tpdo_ped IN (vtpdosurvey))
			   											AND edo_ped = 'S'
			   									       	AND (LENGTH(paramUsr) = 0 OR UPPER(usrrp_ped) = UPPER(paramUsr)))
		   OR rdnota_vta.ped_nvta		    IN (SELECT 	num_ped 
		   									FROM 	hpedidos  
		   									WHERE  	num_ped = rdnota_vta.ped_nvta 
		   											AND (tpdo_ped IN (vtpdopro) OR  tpdo_ped IN (vtpdosurvey))
		   											AND edo_ped = 'S'
		   									       	AND (LENGTH(paramUsr) = 0 OR UPPER(usrrp_ped) = UPPER(paramUsr))))  
	ORDER BY 4 DESC
	RETURN 	 lnumcte,
			 lnomcte,
			 ltelcte,
			 lfecha,
			 ltotlts,
			 ltotpes,
			 lnota,
			 lruta
    WITH RESUME;
 END FOREACH; 
 
END PROCEDURE;                                                                                                                               */