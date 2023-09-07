CREATE PROCEDURE QryCom
(
	paramCia   		CHAR(2),
	paramPla   		CHAR(2),
	paramFechaI		DATETIME YEAR TO MINUTE,	
	paramFechaF   	DATETIME YEAR TO MINUTE,
	paramCarga		INT
)

RETURNING  
 CHAR(70), 
 CHAR(70),
 CHAR(110), 
 CHAR(6), 
 CHAR(20),
 DECIMAL,
 CHAR(7),
 DATE,
 DECIMAL,
 CHAR(15);
 
DEFINE vnomcte 	CHAR(70);
DEFINE valias 	CHAR(70);
DEFINE vdirtqe	CHAR(110);
DEFINE vnumcte	CHAR(6);
DEFINE vnumtqe  INT;
DEFINE vnumser	CHAR(20);
DEFINE vcaptqe 	DECIMAL;
DEFINE vfecfab	CHAR(7);
DEFINE vultcar	DATE;
DEFINE vcontqe	DECIMAL;
DEFINE vhcontqe	DECIMAL;
DEFINE vtel     CHAR(15);
DEFINE vRespCom INT;
LET vRespCom = 0;

IF paramCarga = 1 THEN
	FOREACH comdatos_cursor FOR
		SELECT	CASE
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   TRIM(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
				END AS ncom_cte,
				cliente.ali_cte AS alias,	        
				TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,				
				cliente.num_cte,	
				tanque.numser_tqe,
				tanque.capac_tqe,
				tanque.mesfab_tqe || '/' || tanque.anofab_tqe,	 
				'(' || cliente.lada_cte || ') ' || cliente.tel_cte as tel_cte,
				tanque.numtqe_tqe
		INTO	vnomcte,
				valias,
				vdirtqe,
				vnumcte,
				vnumser,
				vcaptqe,
				vfecfab,
				vtel,
				vnumtqe
		FROM	cliente,
				tanque
		WHERE	cliente.num_cte = tanque.numcte_tqe
				AND tanque.comoda_tqe = 'S'		
				AND 
				(cliente.num_cte	   IN 
											(
												SELECT  numcte_nvta
												FROM	nota_vta
												WHERE	nota_vta.numcte_nvta 		= cliente.num_cte
														AND nota_vta.numtqe_nvta   IN(
																						SELECT  numtqe_tqe
																						FROM	tanque
																						WHERE	numcte_tqe = cliente.num_cte
															
									AND comoda_tqe = 'S'
																					)
														AND nota_vta.fes_nvta	   >= DATE(paramFechaI)
														AND nota_vta.fes_nvta	   <= DATE(paramFechaF)			
														AND nota_vta.edo_nvta		IN('A','S')
										 	)	
				OR cliente.num_cte	       IN 

											(
												SELECT  numcte_nvta
												FROM	rdnota_vta
												WHERE	rdnota_vta.numcte_nvta		= cliente.num_cte
														AND rdnota_vta.numtqe_nvta   IN(
																						SELECT  numtqe_tqe
																						FROM	tanque
																						WHERE	numcte_tqe = cliente.num_cte
																								--AND comoda_tqe = 'S'
																					)
														AND rdnota_vta.fes_nvta	   >= DATE(paramFechaI)
														AND rdnota_vta.fes_nvta	   <= DATE(paramFechaF)			
														AND rdnota_vta.edo_nvta		IN('A','S')
											)							
				)
				AND cliente.cia_cte			= paramCia
				AND cliente.pla_cte			= paramPla		
		
		SELECT  COUNT(*)
		INTO	vRespCom
		FROM	cte_comodato
		WHERE	numcte_ccom 	= vnumcte
				AND nomcte_ccom IS NOT NULL
				AND LENGTH(nomcte_ccom) > 0;
		IF	vRespCom > 0 THEN
			SELECT  TRIM(nomcte_ccom) || ' ' || TRIM(apepcte_ccom) || ' ' || TRIM(apemcte_ccom) 
			INTO	vnomcte
			FROM	cte_comodato
			WHERE	numcte_ccom 	= vnumcte;
		END IF;		
		
		SELECT  MAX(fes_nvta)
		INTO	vultcar
		FROM	nota_vta
		WHERE   nota_vta.numcte_nvta 		= vnumcte
				AND nota_vta.edo_nvta		IN('A','S');
		
		IF 	vultcar IS NULL THEN
			SELECT  MAX(fes_nvta)
			INTO	vultcar
			FROM	rdnota_vta
			WHERE   rdnota_vta.numcte_nvta 		= vnumcte
					AND rdnota_vta.edo_nvta		IN('A','S');
		END IF;	
		
		SELECT  NVL(SUM(nota_vta.tlts_nvta),0)
		INTO	vcontqe
		FROM	nota_vta
		WHERE   nota_vta.numcte_nvta 		= vnumcte
				AND nota_vta.numtqe_nvta	= vnumtqe
				AND nota_vta.edo_nvta		IN('A','S')
				AND nota_vta.fes_nvta	   >= DATE(paramFechaI)
				AND nota_vta.fes_nvta	   <= DATE(paramFechaF);
				
		SELECT  NVL(SUM(rdnota_vta.tlts_nvta),0)
		INTO	vhcontqe
		FROM	rdnota_vta
		WHERE   rdnota_vta.numcte_nvta 		= vnumcte
				AND rdnota_vta.numtqe_nvta	= vnumtqe
				AND rdnota_vta.edo_nvta		IN('A','S')
				AND rdnota_vta.fes_nvta	   >= DATE(paramFechaI)
				AND rdnota_vta.fes_nvta	   <= DATE(paramFechaF);	
		LET 	vcontqe = vcontqe + vhcontqe;
		
		RETURN 	vnomcte,
				valias,
				vdirtqe,
				vnumcte,
				vnumser,
				vcaptqe,
				vfecfab,
				vultcar,
				vcontqe,
				vtel	
		WITH RESUME;
	END FOREACH;
END IF;

IF paramCarga = 0 THEN
	FOREACH comdatos_cursor FOR
		SELECT	CASE
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   TRIM(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
				END AS ncom_cte,
				cliente.ali_cte AS alias,	 	        
				TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,	
				cliente.num_cte,
				0,
				tanque.numser_tqe,
				tanque.capac_tqe,
				tanque.mesfab_tqe || '/' || tanque.anofab_tqe,
				'(' || cliente.lada_cte || ') ' || cliente.tel_cte as tel_cte,
				tanque.numtqe_tqe
		INTO	vnomcte,
				valias,
				vdirtqe,
				vnumcte,
				vcontqe,
				vnumser,
				vcaptqe,
				vfecfab,
				vtel,
				vnumtqe
		FROM	cliente,
				tanque							
		WHERE	cliente.num_cte = tanque.numcte_tqe
				AND tanque.comoda_tqe = 'S'		
				AND 
				cliente.num_cte	   NOT IN 
											(
												SELECT  numcte_nvta
												FROM	nota_vta
												WHERE	nota_vta.numcte_nvta 		= cliente.num_cte
														AND nota_vta.numtqe_nvta   IN(
																						SELECT  numtqe_tqe
																						FROM	tanque
																						WHERE	numcte_tqe = cliente.num_cte
																								--AND comoda_tqe = 'S'
																					)
														AND nota_vta.fes_nvta	   >= DATE(paramFechaI)
														AND nota_vta.fes_nvta	   <= DATE(paramFechaF)			
														AND nota_vta.edo_nvta		IN('A','S')
											)	
				AND cliente.num_cte	   NOT IN 
											(
									
			SELECT  numcte_nvta
												FROM	rdnota_vta
												WHERE	rdnota_vta.numcte_nvta		= cliente.num_cte
														AND rdnota_vta.numtqe_nvta   IN(
																						SELECT  numtqe_tqe
																						FROM	tanque
																						WHERE	numcte_tqe = cliente.num_cte
																								--AND comoda_tqe = 'S'
																						)
														AND rdnota_vta.fes_nvta	   >= DATE(paramFechaI)
														AND rdnota_vta.fes_nvta	   <= DATE(paramFechaF)			
														AND rdnota_vta.edo_nvta		IN('A','S')
											)							
				AND cliente.cia_cte			= paramCia
				AND cliente.pla_cte			= paramPla
		
		SELECT  COUNT(*)
		INTO	vRespCom
		FROM	cte_comodato
		WHERE	numcte_ccom 	= vnumcte
				AND nomcte_ccom IS NOT NULL
				AND LENGTH(nomcte_ccom) > 0;
	
		IF	vRespCom > 0 THEN
			SELECT  TRIM(nomcte_ccom) || ' ' || TRIM(apepcte_ccom) || ' ' || TRIM(apemcte_ccom) 
			INTO	vnomcte
			FROM	cte_comodato
			WHERE	numcte_ccom 	= vnumcte;
		END IF;
		
		SELECT  MAX(fes_nvta)
		INTO	vultcar
		FROM	nota_vta
		WHERE   nota_vta.numcte_nvta 		= vnumcte
				AND nota_vta.edo_nvta		IN('A','S');
		
		IF 	vultcar IS NULL THEN
			SELECT  MAX(fes_nvta)
			INTO	vultcar
			FROM	rdnota_vta
			WHERE   rdnota_vta.numcte_nvta 		= vnumcte
					AND rdnota_vta.edo_nvta		IN('A','S');
		END IF;	
				
		RETURN 	vnomcte,
				valias,
				vdirtqe,
				vnumcte,
				vnumser,
				vcaptqe,
				vfecfab,
				vultcar,
				vcontqe,
				vtel	
		WITH RESUME;		
	END FOREACH;
END IF;

IF paramCarga = 2 THEN
	FOREACH comdatos_cursor FOR
		SELECT	CASE
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   TRIM(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
				END AS ncom_cte,
				cliente.ali_cte AS alias,	 		        
				TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe) AS dir_tqe,	
				cliente.num_cte,
				tanque.numser_tqe,
				tanque.capac_tqe,
				tanque.mesfab_tqe || '/' || tanque.anofab_tqe,	 
				'(' || cliente.lada_cte || ') ' || cliente.tel_cte as tel_cte,
				tanque.numtqe_tqe
		INTO	vnomcte,
				valias,
				vdirtqe,				
				vnumcte,
				vnumser,
				vcaptqe,
				vfecfab,
				vtel,
				vnumtqe
		FROM	cliente,
				tanque
		WHERE	cliente.num_cte = tanque.numcte_tqe
				AND tanque.comoda_tqe = 'S'		
				AND cliente.cia_cte		= paramCia
				AND cliente.pla_cte		= paramPla
		
		SELECT  COUNT(*)
		INTO	vRespCom
		FROM	cte_comodato
		WHERE	numcte_ccom 	= vnumcte
				AND nomcte_ccom IS NOT NULL
				AND LENGTH(nomcte_ccom) > 0;
		IF	vRespCom > 0 THEN
			SELECT  TRIM(nomcte_ccom) || ' ' || TRIM(apepcte_ccom) || ' ' || TRIM(apemcte_ccom) 

			INTO	vnomcte
			FROM	cte_comodato
			WHERE	numcte_ccom 	= vnumcte;
		END IF;		
		
		SELECT  MAX(fes_nvta)
		INTO	vultcar
		FROM	nota_vta
		WHERE   nota_vta.numcte_nvta 		= vnumcte
				AND nota_vta.edo_nvta		IN('A','S');		
		IF 	vultcar IS NULL THEN
			SELECT  MAX(fes_nvta)
			INTO	vultcar
			FROM	rdnota_vta
			WHERE   rdnota_vta.numcte_nvta 		= vnumcte
					AND rdnota_vta.edo_nvta		IN('A','S');
		END IF;	
		
		SELECT  NVL(SUM(nota_vta.tlts_nvta),0)
		INTO	vcontqe
		FROM	nota_vta
		WHERE   nota_vta.numcte_nvta 		= vnumcte
				AND nota_vta.numtqe_nvta	= vnumtqe
				AND nota_vta.edo_nvta		IN('A','S')
				AND nota_vta.fes_nvta	   >= DATE(paramFechaI)
				AND nota_vta.fes_nvta	   <= DATE(paramFechaF);
				
		SELECT  NVL(SUM(rdnota_vta.tlts_nvta),0)
		INTO	vhcontqe
		FROM	rdnota_vta
		WHERE   rdnota_vta.numcte_nvta 		= vnumcte
				AND rdnota_vta.numtqe_nvta	= vnumtqe
				AND rdnota_vta.edo_nvta		IN('A','S')
				AND rdnota_vta.fes_nvta	   >= DATE(paramFechaI)
				AND rdnota_vta.fes_nvta	   <= DATE(paramFechaF);
		LET 	vcontqe = vcontqe + vhcontqe;
				
		RETURN 	vnomcte,
				valias,
				vdirtqe,
				vnumcte,
				vnumser,
				vcaptqe,
				vfecfab,
				vultcar,
				vcontqe,
				vtel	
		WITH RESUME;		
	END FOREACH;
END IF;

END PROCEDURE;  