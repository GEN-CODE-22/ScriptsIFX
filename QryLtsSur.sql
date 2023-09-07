CREATE PROCEDURE QryLtsSur
(
	paramCia   CHAR(2),
	paramPla   CHAR(2),
	paramRuta  CHAR(4),
	paramAnio  INT
)
RETURNING
 INT,
 INT,
 DECIMAL,
 DECIMAL,
 INT,
 INT;

 DEFINE vannio 		INT;
 DEFINE vmes	 	INT;
 DEFINE vtotal 		DECIMAL;
 DEFINE vtotalrd	DECIMAL;
 DEFINE vtotalp  	DECIMAL;
 DEFINE vtotalprd 	DECIMAL;
 DEFINE vsurvey_cfg CHAR(50);
 DEFINE vtpdopro 	CHAR(1);
 DEFINE vtpdosurvey	CHAR(1);
 DEFINE vannioa		INT;
 DEFINE vmesa		INT;
 DEFINE vcte		INT;
 DEFINE vctenva		INT;
 DEFINE vcterd		INT;
 DEFINE vctenvard	INT;


LET	vtpdopro = 'P';
LET	vtpdosurvey = '';
LET vmesa = MONTH(CURRENT) - 2;
LET vannioa = YEAR(CURRENT);
IF vmesa <= 0 THEN
	LET vmesa = vmesa + 12;
	LET vannioa = vannioa - 1;
END IF;

SELECT	value_cfg
INTO	vsurvey_cfg
FROM	cfg_llam
WHERE	key_cfg = 'ACTIVESURVEY_CFG';

IF	vsurvey_cfg = '1'	THEN
	LET	vtpdosurvey = 'E';
END IF;

FOREACH cCursorLitros FOR
	SELECT	YEAR(nota_vta.fes_nvta),
		   	MONTH(nota_vta.fes_nvta)
	INTO	vannio,
			vmes			
	FROM	cliente,
		   	nota_vta 
	WHERE  	nota_vta.numcte_nvta         = cliente.num_cte			
		   	AND YEAR(nota_vta.fes_nvta)  = paramAnio       		
		   	AND nota_vta.edo_nvta		 IN('A','S')
		   	AND nota_vta.cia_nvta      	 = paramCia  
		   	AND nota_vta.pla_nvta      	 = paramPla
		   	AND nota_vta.ruta_nvta 		 = paramRuta
	GROUP BY 1,2
		  
	UNION
	
	SELECT	YEAR(rdnota_vta.fes_nvta),
		   	MONTH(rdnota_vta.fes_nvta)
	FROM	cliente,
		   	rdnota_vta 
	WHERE  	rdnota_vta.numcte_nvta        = cliente.num_cte			
		   	AND YEAR(rdnota_vta.fes_nvta) = paramAnio       		
		   	AND rdnota_vta.edo_nvta		  IN('A','S')
		   	AND rdnota_vta.cia_nvta       = paramCia  
		   	AND rdnota_vta.pla_nvta       = paramPla
		   	AND rdnota_vta.ruta_nvta 	  = paramRuta
	GROUP BY 1,2	
	ORDER BY 1,2
	
	LET vtotal = 0;
	LET vtotalrd = 0;
	LET vtotalp = 0;
	LET vtotalprd = 0;
	LET vcte = 0;
	LET vctenva = 0;
	LET vcterd = 0;
	LET vctenvard = 0;
	
	IF  (vannioa = vannio AND vmes >= vmesa) OR (vannio = YEAR(CURRENT)) THEN
		SELECT 	SUM(NVL(nota_vta.tlts_nvta,0))
		INTO	vtotal
		FROM   	cliente,
			   	nota_vta 
		WHERE  	nota_vta.numcte_nvta        = cliente.num_cte			
			   	AND YEAR(nota_vta.fes_nvta)	= vannio 
			   	AND MONTH(nota_vta.fes_nvta)= vmes            		
			   	AND nota_vta.edo_nvta		IN('A','S')
			   	AND nota_vta.cia_nvta      	= paramCia 
			   	AND nota_vta.pla_nvta      	= paramPla
			   	AND nota_vta.ruta_nvta 	    = paramRuta;
			   	
		SELECT 	SUM(NVL(nota_vta.tlts_nvta,0))
		INTO	vtotalp
		FROM   	cliente,
			   	nota_vta 
		WHERE  	nota_vta.numcte_nvta        = cliente.num_cte			
			   	AND YEAR(nota_vta.fes_nvta)	= vannio 
			   	AND MONTH(nota_vta.fes_nvta)= vmes            		
			   	AND nota_vta.edo_nvta		IN('A','S')
			   	AND nota_vta.cia_nvta      	= paramCia 
			   	AND nota_vta.pla_nvta      	= paramPla
			   	AND nota_vta.ruta_nvta 		= paramRuta
			   	AND (nota_vta.tpdo_nvta 	IN(vtpdopro) OR nota_vta.tpdo_nvta IN(vtpdosurvey));
			   	
		SELECT	COUNT(*)
		INTO	vctenva
		FROM	cliente c, nota_vta n
		WHERE	c.num_cte 				= n.numcte_nvta	
				AND YEAR(n.fes_nvta)	= vannio 
			   	AND MONTH(n.fes_nvta)	= vmes       
				AND n.edo_nvta 			IN('A','S')
				AND n.cia_nvta    		= paramCia 
				AND n.pla_nvta    		= paramPla
				AND n.ruta_nvta 		= paramRuta
				AND (n.tpdo_nvta 		IN(vtpdopro) OR n.tpdo_nvta IN(vtpdosurvey))	
				AND n.fes_nvta = 		NVL(
										(SELECT 	MIN(fes_nvta) 
										FROM 	hnota_vta 
										WHERE 	numcte_nvta 	= c.num_cte
												AND edo_nvta 	IN('A','S')										
												AND cia_nvta    = paramCia 
							   					AND pla_nvta    = paramPla
												AND ruta_nvta 	= paramRuta									
												AND (tpdo_nvta 	IN(vtpdopro) OR tpdo_nvta IN(vtpdosurvey))),
										(SELECT 	MIN(fes_nvta) 
										FROM 	nota_vta 
										WHERE 	numcte_nvta 	= c.num_cte
												AND edo_nvta 	IN('A','S')										
												AND cia_nvta    = paramCia 
							   					AND pla_nvta    = paramPla
												AND ruta_nvta 	= paramRuta
												AND (tpdo_nvta 	IN(vtpdopro) OR tpdo_nvta IN(vtpdosurvey)))
										);
	
		SELECT	COUNT(*)
		INTO	vcte
		FROM	cliente c, nota_vta n
		WHERE	c.num_cte 				= n.numcte_nvta	
				AND YEAR(n.fes_nvta)	= vannio 
			   	AND MONTH(n.fes_nvta)	= vmes       
				AND n.edo_nvta 			IN('A','S')
				AND n.cia_nvta    		= paramCia 
				AND n.pla_nvta    		= paramPla
				AND n.ruta_nvta 		= paramRuta
				AND (n.tpdo_nvta 		IN(vtpdopro) OR n.tpdo_nvta IN(vtpdosurvey));
	END IF;
	IF  (vannioa = vannio AND vmes <= vmesa) OR (vannioa <> vannio) THEN
		SELECT	SUM(NVL(rdnota_vta.tlts_nvta,0))
		INTO	vtotalrd
		FROM   	cliente,
			   	rdnota_vta 
		WHERE  	rdnota_vta.numcte_nvta         	= cliente.num_cte			
			   	AND YEAR(rdnota_vta.fes_nvta)	= vannio 
			   	AND MONTH(rdnota_vta.fes_nvta)  = vmes       		
			   	AND rdnota_vta.edo_nvta			IN('A','S')
			   	AND rdnota_vta.cia_nvta      	= paramCia  
			   	AND rdnota_vta.pla_nvta      	= paramPla
			   	AND rdnota_vta.ruta_nvta        = paramRuta;
			   	
		SELECT	SUM(NVL(rdnota_vta.tlts_nvta,0))
		INTO	vtotalprd
		FROM   	cliente,
			   	rdnota_vta 
		WHERE  	rdnota_vta.numcte_nvta         	= cliente.num_cte			
			   	AND YEAR(rdnota_vta.fes_nvta)	= vannio 
			   	AND MONTH(rdnota_vta.fes_nvta)  = vmes       		
			   	AND rdnota_vta.edo_nvta			IN('A','S')
			   	AND rdnota_vta.cia_nvta      	= paramCia  
			   	AND rdnota_vta.pla_nvta      	= paramPla
			   	AND rdnota_vta.ruta_nvta        = paramRuta 
			   	AND (rdnota_vta.tpdo_nvta 		IN(vtpdopro) OR rdnota_vta.tpdo_nvta IN(vtpdosurvey));
			   	
		SELECT	COUNT(*)
		INTO	vctenvard
		FROM	cliente c, rdnota_vta n
		WHERE	c.num_cte 				= n.numcte_nvta	
				AND YEAR(n.fes_nvta)	= vannio 
			   	AND MONTH(n.fes_nvta)	= vmes       
				AND n.edo_nvta 			IN('A','S')
				AND n.cia_nvta    		= paramCia 
				AND n.pla_nvta    		= paramPla
				AND n.ruta_nvta 		= paramRuta
				AND (n.tpdo_nvta 		IN(vtpdopro) OR n.tpdo_nvta IN(vtpdosurvey))	
				AND n.fes_nvta = 		(SELECT 	MIN(fes_nvta) 
										FROM 	hnota_vta 
										WHERE 	numcte_nvta 	= c.num_cte
												AND edo_nvta 	IN('A','S')										
												AND cia_nvta    = paramCia 
							   					AND pla_nvta    = paramPla
												AND hnota_vta.ruta_nvta = paramRuta								
												AND (tpdo_nvta 	IN(vtpdopro) OR tpdo_nvta IN(vtpdosurvey)));
	
		SELECT	COUNT(*)
		INTO	vcterd
		FROM	cliente c, rdnota_vta n
		WHERE	c.num_cte 				= n.numcte_nvta	
				AND YEAR(n.fes_nvta)	= vannio 
			   	AND MONTH(n.fes_nvta)	= vmes       
				AND n.edo_nvta 			IN('A','S')
				AND n.cia_nvta    		= paramCia 
				AND n.pla_nvta    		= paramPla
				AND n.ruta_nvta 		= paramRuta
				AND (n.tpdo_nvta 		IN(vtpdopro) OR n.tpdo_nvta IN(vtpdosurvey));	   	
		
	END IF;
	LET vtotal = NVL(vtotal,0) + NVL(vtotalrd,0);
	LET vtotalp = NVL(vtotalp,0) + NVL(vtotalprd,0);
	LET vcte = NVL(vcte,0) + NVL(vcterd,0);
	LET vctenva = NVL(vctenva,0) + NVL(vctenvard,0);
	RETURN 	vannio,
			vmes,
			vtotal,
			vtotalp,
			vcte,
			vctenva
    WITH RESUME;
 END FOREACH; 
 
END PROCEDURE;   