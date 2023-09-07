CREATE PROCEDURE ConCP
(
	paramCia   	CHAR(2),
	paramPla   	CHAR(2),
	paramRuta  	CHAR(4)
)
RETURNING
 CHAR(6),
 CHAR(40),
 CHAR(20),
 CHAR(4),
 DATE,
 CHAR(70);

 DEFINE lnumcte 	CHAR(6);
 DEFINE ldirtqe		CHAR(40);
 DEFINE ltelcte 	CHAR(20);
 DEFINE lruta 		CHAR(4);
 DEFINE lfecsur 	DATE;
 DEFINE lnomcte  	CHAR(70);
 DEFINE lnumtqe  	INT;
 DEFINE lhist   	INT;
 DEFINE lfolnvta   	INT;
 DEFINE vsurvey_cfg CHAR(50);
 DEFINE vtpdopro 	CHAR(1);
 DEFINE vtpdosurvey	CHAR(1);

LET	vtpdopro = 'P';
LET	vtpdosurvey = '';

SELECT	value_cfg
INTO	vsurvey_cfg
FROM	cfg_llam
WHERE	key_cfg = 'ACTIVESURVEY_CFG';
 
FOREACH cClientes FOR	
	SELECT  cliente.num_cte,
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
			END AS ncom_cte,
			'(' || cliente.lada_cte || ') ' || cliente.tel_cte tel_cte
	INTO	lnumcte,
			lnomcte,
			ltelcte
	FROM	cliente
	WHERE	cliente.num_cte IN(
								SELECT 	nota_vta.numcte_nvta 
								FROM	nota_vta
								WHERE	nota_vta.cia_nvta 		= paramCia
										AND nota_vta.pla_nvta 	= paramPla
										AND nota_vta.edo_nvta	IN('A','S')
										AND (nota_vta.tpdo_nvta 	IN(vtpdopro) OR nota_vta.tpdo_nvta IN (vtpdosurvey))
										AND tip_nvta = 'E'
										AND (nota_vta.ruta_nvta = paramRuta OR LENGTH(paramRuta) = 0 )
							)
			OR cliente.num_cte IN(
								SELECT 	rdnota_vta.numcte_nvta 
								FROM	rdnota_vta
								WHERE	rdnota_vta.cia_nvta 		= paramCia
										AND rdnota_vta.pla_nvta 	= paramPla
										AND rdnota_vta.edo_nvta		IN('A','S')
										AND (rdnota_vta.tpdo_nvta 	IN(vtpdopro) OR rdnota_vta.tpdo_nvta IN (vtpdosurvey))
										AND tip_nvta = 'E'
										AND (rdnota_vta.ruta_nvta = paramRuta OR LENGTH(paramRuta) = 0 )
							)
	
	LET lfecsur = NULL;
	LET	lhist = 0;
	SELECT  MAX(fes_nvta)
	INTO	lfecsur
	FROM	nota_vta
	WHERE   nota_vta.numcte_nvta 		= lnumcte
			AND nota_vta.edo_nvta		IN('A','S')
			AND nota_vta.cia_nvta   	= paramCia
			AND nota_vta.pla_nvta   	= paramPla
			AND (nota_vta.tpdo_nvta 	IN(vtpdopro) OR nota_vta.tpdo_nvta IN (vtpdosurvey))
			AND (nota_vta.ruta_nvta 	= paramRuta OR LENGTH(paramRuta) = 0 );
	
	IF 	lfecsur IS NULL THEN
		SELECT  MAX(fes_nvta)
		INTO	lfecsur
		FROM	rdnota_vta
		WHERE   rdnota_vta.numcte_nvta 		= lnumcte
				AND rdnota_vta.edo_nvta		IN('A','S')
				AND rdnota_vta.cia_nvta   	= paramCia
				AND rdnota_vta.pla_nvta   	= paramPla
				AND (rdnota_vta.tpdo_nvta 	IN(vtpdopro) OR rdnota_vta.tpdo_nvta IN (vtpdosurvey))
				AND (rdnota_vta.ruta_nvta = paramRuta OR LENGTH(paramRuta) = 0 );
		LET	lhist = 1;
	END IF;	

	IF lhist = 0 THEN
		SELECT	MAX(fol_nvta)
		INTO	lfolnvta
		FROM	nota_vta
		WHERE	nota_vta.numcte_nvta 	= lnumcte
				AND nota_vta.edo_nvta	IN('A','S')
				AND nota_vta.cia_nvta   = paramCia
				AND nota_vta.pla_nvta   = paramPla
				AND (nota_vta.tpdo_nvta 	IN(vtpdopro) OR nota_vta.tpdo_nvta IN (vtpdosurvey))
				AND nota_vta.fes_nvta   = lfecsur
				AND (nota_vta.ruta_nvta = paramRuta OR LENGTH(paramRuta) = 0 );
		
		SELECT	nota_vta.ruta_nvta,
				nota_vta.numtqe_nvta
		INTO	lruta,
				lnumtqe 
		FROM	nota_vta
		WHERE   fol_nvta = lfolnvta
				AND nota_vta.numcte_nvta	= lnumcte
				AND nota_vta.edo_nvta		IN('A','S')
				AND nota_vta.cia_nvta   	= paramCia
				AND nota_vta.pla_nvta   	= paramPla
				AND tip_nvta 				= 'E'
				AND (nota_vta.tpdo_nvta 	IN(vtpdopro) OR nota_vta.tpdo_nvta IN (vtpdosurvey))
				AND (nota_vta.ruta_nvta 	= paramRuta OR LENGTH(paramRuta) = 0 );
	END IF;
	
	IF	lhist = 1 THEN
		SELECT	MAX(fol_nvta)
		INTO	lfolnvta
		FROM	rdnota_vta
		WHERE	rdnota_vta.numcte_nvta 		= lnumcte
				AND rdnota_vta.edo_nvta		IN('A','S')
				AND rdnota_vta.cia_nvta   	= paramCia
				AND rdnota_vta.pla_nvta   	= paramPla
				AND (rdnota_vta.tpdo_nvta 	IN(vtpdopro) OR rdnota_vta.tpdo_nvta IN (vtpdosurvey))
				AND rdnota_vta.fes_nvta   	= lfecsur
				AND (rdnota_vta.ruta_nvta 	= paramRuta OR LENGTH(paramRuta) = 0 );
				
		SELECT	rdnota_vta.ruta_nvta,
				rdnota_vta.numtqe_nvta
		INTO	lruta,
				lnumtqe
		FROM	rdnota_vta
		WHERE   fol_nvta = lfolnvta
				AND rdnota_vta.numcte_nvta	= lnumcte
				AND rdnota_vta.edo_nvta		IN('A','S')
				AND rdnota_vta.cia_nvta   	= paramCia
				AND rdnota_vta.pla_nvta   	= paramPla
				AND tip_nvta 				= 'E'
				AND (rdnota_vta.tpdo_nvta 	IN(vtpdopro) OR rdnota_vta.tpdo_nvta IN (vtpdosurvey))
				AND (rdnota_vta.ruta_nvta 	= paramRuta OR LENGTH(paramRuta) = 0 );
	END IF;
	
	SELECT	TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe
	INTO	ldirtqe
	FROM	tanque
	WHERE	tanque.numcte_tqe		= lnumcte
			AND tanque.numtqe_tqe 	= lnumtqe;
			
		
		
	RETURN 	lnumcte,
			ldirtqe,
			ltelcte,
			lruta,
			lfecsur,
			lnomcte	
    WITH RESUME;
 END FOREACH;
 
END PROCEDURE;