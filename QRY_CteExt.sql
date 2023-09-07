DROP PROCEDURE QRY_CteExt;
EXECUTE PROCEDURE  QRY_CteExt(4);

CREATE PROCEDURE QRY_CteExt
(
	paramTipo   	SMALLINT-- 1- Metodo PUE, 2- UsoCFDI, 3- Regimen Fiscal, 4-Tipo Facturacion 
)

RETURNING  
 CHAR(6),
 CHAR(80),
 CHAR(4);

DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vdato 	CHAR(4);

IF paramTipo = 1 THEN
	FOREACH cCliente FOR
		SELECT	c.num_cte, NVL(CASE 
				WHEN TRIM(c.razsoc_cte) <> '' THEN
				   TRIM(c.razsoc_cte) 
				ELSE 
				   trim(c.nom_cte) || ' ' || TRIM(c.ape_cte) 
				END,'')
		INTO	vnocte, vnomcte
		FROM	cte_pue , cliente c
		WHERE	numcte_cpue = c.num_cte
		
		LET vdato = '';
	RETURN 	vnocte, vnomcte, vdato
	WITH RESUME;
	END FOREACH;	
END IF;

IF paramTipo = 2 THEN
	FOREACH cCliente FOR
		SELECT	c.num_cte, NVL(CASE 
				WHEN TRIM(c.razsoc_cte) <> '' THEN
				   TRIM(c.razsoc_cte) 
				ELSE 
				   trim(c.nom_cte) || ' ' || TRIM(c.ape_cte) 
				END,''),
				uso_cucfdi
		INTO	vnocte, vnomcte, vdato
		FROM	cte_ucfdi , cliente c
		WHERE	cte_cucfdi = c.num_cte

	RETURN 	vnocte, vnomcte, vdato
	WITH RESUME;
	END FOREACH;
END IF;

IF paramTipo = 3 THEN
	FOREACH cCliente FOR
		SELECT	c.num_cte, NVL(CASE 
				WHEN TRIM(c.razsoc_cte) <> '' THEN
				   TRIM(c.razsoc_cte) 
				ELSE 
				   trim(c.nom_cte) || ' ' || TRIM(c.ape_cte) 
				END,''),
				regfis_crf
		INTO	vnocte, vnomcte, vdato
		FROM	cte_regfiscal , cliente c
		WHERE	numcte_crf = c.num_cte

	RETURN 	vnocte, vnomcte, vdato
	WITH RESUME;
	END FOREACH;
END IF;

IF paramTipo = 4 THEN
	FOREACH cCliente FOR
		SELECT	c.num_cte, NVL(CASE 
				WHEN TRIM(c.razsoc_cte) <> '' THEN
				   TRIM(c.razsoc_cte) 
				ELSE 
				   trim(c.nom_cte) || ' ' || TRIM(c.ape_cte) 
				END,''),
				tipfac_cfac
		INTO	vnocte, vnomcte, vdato
		FROM	cte_fac , cliente c
		WHERE	numcte_cfac = c.num_cte

	RETURN 	vnocte, vnomcte, vdato
	WITH RESUME;
	END FOREACH;
END IF;

END PROCEDURE; 