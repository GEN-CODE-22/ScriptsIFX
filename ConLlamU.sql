CREATE PROCEDURE ConLlamU
(
	paramCia   	CHAR(2),
	paramPla   	CHAR(2),
	paramUsr   	CHAR(40),
	paramFechaI	DATETIME YEAR TO MINUTE,
	paramFechaF DATETIME YEAR TO MINUTE
)
RETURNING
 CHAR(40),
 DATETIME YEAR TO MINUTE,
 CHAR(6),
 CHAR(70),
 CHAR(20), 
 CHAR(20);

 DEFINE lnomusr 	CHAR(40);
 DEFINE lfecllam	DATETIME YEAR TO MINUTE;
 DEFINE lnumcte 	CHAR(6);
 DEFINE lnomcte 	VARCHAR(70);
 DEFINE ltelcte 	CHAR(20);
 DEFINE ledollam  	CHAR(20);
 DEFINE lfolnvta  	INT;
 DEFINE lcveusr 	CHAR(8);
 DEFINE vsurvey_cfg CHAR(50);
 DEFINE vtpdopro 	CHAR(1);
 DEFINE vtpdosurvey	CHAR(1);

LET	vtpdopro = 'P';
LET	vtpdosurvey = '';

SELECT	value_cfg
INTO	vsurvey_cfg
FROM	cfg_llam
WHERE	key_cfg = 'ACTIVESURVEY_CFG';


LET lfolnvta = 0;

FOREACH cCursor FOR
	SELECT  detp_llam.usr_pllam,
			detp_llam.fh_pllam,
			cliente.num_cte, 
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
		    CASE
				WHEN detp_llam.edo_pllam = 'C' THEN
					'POR CONFIRMAR'
				WHEN detp_llam.edo_pllam = 'A' THEN
				   	'POSPUESTO'
				WHEN detp_llam.edo_pllam = 'X' THEN
				   	'SUSPENDIDO'
				WHEN detp_llam.edo_pllam = 'P' THEN
				   	'PENDIENTE'								
				ELSE
					'ABIERTO'
			END AS edocte
	INTO	lcveusr,
			lfecllam,
			lnumcte,
			lnomcte,
			ltelcte,
			ledollam	
	FROM	cliente,
		    detp_llam
	WHERE	detp_llam.numcte_pllam			= cliente.num_cte
			AND detp_llam.fh_pllam	   	   >= paramFechaI          		
		    AND detp_llam.fh_pllam 	   	   <= paramFechaF 
		    AND (UPPER(detp_llam.usr_pllam)	= UPPER(paramUsr) OR LENGTH(paramUsr) = 0)
	ORDER BY 2 DESC
	
 
	IF ledollam = 'PENDIENTE' THEN
		SELECT  NVL(fol_nvta,0)
		INTO	lfolnvta
		FROM	nota_vta
		WHERE	numcte_nvta	= lnumcte
				AND edo_nvta	IN('A','S')
			    AND cia_nvta	= paramCia
			   	AND pla_nvta	= paramPla
				AND fol_nvta =
				(
					SELECT  MAX(NVL(fol_nvta,0))			
					FROM	nota_vta
					WHERE	fep_nvta		= lfecllam
							AND numcte_nvta	= lnumcte
							AND edo_nvta	IN('A','S')
					    	AND cia_nvta	= paramCia
					   	    AND pla_nvta	= paramPla
						    AND (tpdo_nvta 	IN(vtpdopro) OR tpdo_nvta IN (vtpdosurvey))
						    AND (ped_nvta	IN (SELECT 	num_ped 
						   						FROM 	pedidos 
						   						WHERE 	num_ped = ped_nvta 
						   								AND (LENGTH(paramUsr) = 0 OR UPPER(usr_ped) = UPPER(paramUsr))
						   								AND (tpdo_nvta 	IN(vtpdopro) OR tpdo_nvta IN (vtpdosurvey)) 
						   								AND edo_ped 	= 'S')
					   		OR ped_nvta		IN (SELECT 	num_ped 
						   						FROM 	hpedidos 
						   						WHERE 	num_ped = ped_nvta  
						   								AND (LENGTH(paramUsr) = 0 OR UPPER(usr_ped) = UPPER(paramUsr))
						   								AND (tpdo_nvta 	IN(vtpdopro) OR tpdo_nvta IN (vtpdosurvey))
						   								AND edo_ped 	= 'S'))
				);
			
	END IF;
	
	IF ledollam = 'PENDIENTE' AND lfolnvta = 0  THEN
		SELECT  NVL(fol_nvta,0)
		INTO	lfolnvta
		FROM	rdnota_vta
		WHERE	numcte_nvta	= lnumcte
				AND edo_nvta	IN('A','S')
			    AND cia_nvta	= paramCia
			   	AND pla_nvta	= paramPla
				AND fol_nvta =
				(
					SELECT  MAX(NVL(fol_nvta,0))
					FROM	rdnota_vta
					WHERE	fep_nvta		= lfecllam
							AND numcte_nvta	= lnumcte
							AND edo_nvta	IN('A','S')
					    	AND cia_nvta	= paramCia
					   	    AND pla_nvta	= paramPla
						    AND (tpdo_nvta 	IN(vtpdopro) OR tpdo_nvta IN (vtpdosurvey))
						    AND ped_nvta	IN (SELECT 	num_ped 
						   						FROM 	hpedidos 
						   						WHERE 	num_ped = ped_nvta 
						   								AND (LENGTH(paramUsr) = 0 OR UPPER(usr_ped) = UPPER(paramUsr))
						   								AND (tpdo_nvta 	IN(vtpdopro) OR tpdo_nvta IN (vtpdosurvey))
						   								AND edo_ped 	= 'S')
				);
	END IF;
	
	IF lfolnvta > 0	THEN
		LET ledollam = 'SURTIDO';
	END IF;
	
	LET lfolnvta = 0;
	
	SELECT	UPPER(NVL(nom_ucve,''))
	INTO	lnomusr
	FROM	usr_cve
	WHERE	usr_ucve = lcveusr;
	
	IF LENGTH(lnomusr) = 0 OR lnomusr='' THEN
		LET lnomusr = UPPER(lcveusr);
	END IF;
	
	RETURN 	lnomusr,
			lfecllam,
			lnumcte,
			lnomcte,
			ltelcte,
			ledollam	
    WITH RESUME;
 END FOREACH;
 
END PROCEDURE;