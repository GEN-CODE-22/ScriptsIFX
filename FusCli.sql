CREATE PROCEDURE FusCli
(
	paramCteDup		CHAR(6),	
	paramCteOri   	CHAR(6)		
)

DEFINE vfolio_doc 	INT;
DEFINE vcargo_doc	DECIMAL;
DEFINE vabono_doc 	DECIMAL;
DEFINE vsaldo_doc 	DECIMAL;

DEFINE vfolio_fac	INT;
DEFINE vfncd1_fac	INT;
DEFINE vfncd2_fac	INT;

FOREACH docs_cursor FOR
	
	SELECT	fol_doc,
			NVL(car_doc,0),
			NVL(abo_doc,0),
			NVL(sal_doc,0) 
	INTO 	vfolio_doc,
			vcargo_doc,
			vabono_doc,
			vsaldo_doc
	FROM 	doctos 
    WHERE 	cte_doc = paramCteDup
    		AND (
    			fol_doc IN (SELECT 	fol_nvta 
    						FROM	nota_vta 
    						WHERE	edo_nvta = 'A'
    								AND numcte_nvta = paramCteDup
    								AND tip_nvta IN('C','G'))
    			OR
    			fol_doc IN (SELECT 	fol_nvta 
    						FROM	hnota_vta 
    						WHERE	edo_nvta = 'A'
    	    						AND numcte_nvta = paramCteDup
    								AND tip_nvta IN('C','G'))
    		)
    							
  	UPDATE	cliente 
  	SET 	cargo_cte 	= cargo_cte - vcargo_doc,
  			abono_cte 	= abono_cte - vabono_doc,
  			saldo_cte 	= saldo_cte - vsaldo_doc
    WHERE 	num_cte		= paramCteDup;  	
    
    UPDATE	cliente 
  	SET 	cargo_cte 	= cargo_cte + vcargo_doc,
  			abono_cte 	= abono_cte + vabono_doc,
  			saldo_cte 	= saldo_cte + vsaldo_doc
    WHERE 	num_cte		= paramCteOri;
   
	UPDATE	mov_cxc
	SET		cte_mcxc 		= paramCteOri
	WHERE	doc_mcxc 		= vfolio_doc
			AND cte_mcxc 	= paramCteDup;
    
END FOREACH;

FOREACH facs_cursor FOR
	
	SELECT	fol_fac,
			NVL(fncd_fac,0),
			NVL(fnc2_fac,0)
	INTO 	vfolio_fac,
			vfncd1_fac,
			vfncd2_fac
	FROM 	factura 
    WHERE 	numcte_fac = paramCteDup  
    
    IF	vfncd1_fac > 0 THEN
    	UPDATE	nota_crd 
  		SET 	numcte_ncrd 	= paramCteOri
	    WHERE 	fol_ncrd		= vfncd1_fac
	    		AND numcte_ncrd	= paramCteDup;
    END IF;
    IF	vfncd2_fac > 0 THEN
    	UPDATE	nota_crd 
  		SET 	numcte_ncrd 	= paramCteOri
	    WHERE 	fol_ncrd		= vfncd2_fac
	    		AND numcte_ncrd	= paramCteDup;
    END IF;    
    
END FOREACH;

UPDATE	nota_vta
SET		numcte_nvta = paramCteOri
WHERE	numcte_nvta = paramCteDup;

UPDATE	rdnota_vta
SET		numcte_nvta = paramCteOri
WHERE	numcte_nvta = paramCteDup;

UPDATE	hnota_vta
SET		numcte_nvta = paramCteOri
WHERE	numcte_nvta = paramCteDup;

UPDATE	pedidos
SET		numcte_ped = paramCteOri
WHERE	numcte_ped = paramCteDup;

UPDATE	hpedidos
SET		numcte_ped = paramCteOri
WHERE	numcte_ped = paramCteDup;

UPDATE	doctos
SET		cte_doc = paramCteOri
WHERE	cte_doc = paramCteDup;

UPDATE	mov_cxc
SET		cte_mcxc = paramCteOri
WHERE	cte_mcxc = paramCteDup;

UPDATE	factura 
SET 	numcte_fac 	= paramCteOri
WHERE 	numcte_fac 	= paramCteDup;

UPDATE	cliente
SET		status_cte  = 'B',
		fecbaj_cte  = CURRENT
WHERE	num_cte		= paramCteDup;

UPDATE	tanque
SET		stat_tqe	= 'B',
		fecbaj_tqe  = CURRENT
WHERE	numcte_tqe	= paramCteDup;

END PROCEDURE; 