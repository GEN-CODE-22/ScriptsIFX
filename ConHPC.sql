CREATE PROCEDURE ConHPC
(
	paramCte   	CHAR(6),
	paramTqe	INT
)
RETURNING
 DATE,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 CHAR(110);

DEFINE fes  DATE;
DEFINE tlts DECIMAL;
DEFINE impt DECIMAL;
DEFINE pru  DECIMAL;
DEFINE dir  CHAR(110);

FOREACH cPedidos FOR
	SELECT	nota_vta.fes_nvta,
       	 	nota_vta.tlts_nvta,
     		nota_vta.impt_nvta, 
	     	nota_vta.pru_nvta,
	     	(TRIM(tanque.dir_tqe) || ', ' || TRIM(tanque.col_tqe) || ', ' || TRIM(tanque.ciu_tqe)) AS direccion
	INTO 	fes, tlts, impt, pru, dir
	FROM 	nota_vta,
     		tanque
	WHERE 	nota_vta.numcte_nvta 		= tanque.numcte_tqe     
	 		AND nota_vta.numtqe_nvta 	= tanque.numtqe_tqe   
	 		AND nota_vta.edo_nvta		IN('A','S')
	 		AND nota_vta.tlts_nvta		> 0
 			AND nota_vta.impt_nvta		> 0
	 		AND nota_vta.numcte_nvta 	= paramCte
	 		AND nota_vta.numtqe_nvta	= paramTqe
	UNION
	SELECT	rdnota_vta.fes_nvta,
       	 	rdnota_vta.tlts_nvta,
     		rdnota_vta.impt_nvta, 
	     	rdnota_vta.pru_nvta,
	     	(TRIM(tanque.dir_tqe) || ', ' || TRIM(tanque.col_tqe) || ', ' || TRIM(tanque.ciu_tqe)) AS direccion
	FROM 	rdnota_vta,
     		tanque
	WHERE 	rdnota_vta.numcte_nvta 		= tanque.numcte_tqe     
	 		AND rdnota_vta.numtqe_nvta 	= tanque.numtqe_tqe     
	 		AND rdnota_vta.edo_nvta		= 'A'
	 		AND rdnota_vta.tlts_nvta	> 0
 			AND rdnota_vta.impt_nvta	> 0
	 		AND rdnota_vta.numcte_nvta 	= paramCte
	 		AND rdnota_vta.numtqe_nvta	= paramTqe
	UNION
	SELECT	nota_vta.fes_nvta,
       	 	enruta.ltssur_enr * 1,
	    	enruta.totvta_enr * 1, 
	     	NVL(nota_vta.pru_nvta,0),
	     	(TRIM(tanque.dir_tqe) || ', ' || TRIM(tanque.col_tqe) || ', ' || TRIM(tanque.ciu_tqe)) AS direccion
	FROM 	nota_vta,
     		tanque,
     		enruta
	WHERE 	nota_vta.numcte_nvta 		= tanque.numcte_tqe     
	 		AND nota_vta.numtqe_nvta 	= tanque.numtqe_tqe     
	 		AND nota_vta.numcte_nvta 	= paramCte
	 		AND nota_vta.numtqe_nvta	= paramTqe
	 		AND enruta.ltssur_enr		> 0
 			AND enruta.totvta_enr		> 0
 			AND nota_vta.cia_nvta || nota_vta.pla_nvta || LPAD(nota_vta.fol_nvta,6,'0') = enruta.fol_enr		 			
			AND enruta.edoreg_enr		= 'F'
	UNION
	SELECT	rdnota_vta.fes_nvta,
	       	enruta.ltssur_enr * 1,
	    	enruta.totvta_enr * 1, 
	     	NVL(rdnota_vta.pru_nvta,0),
	     	(TRIM(tanque.dir_tqe) || ', ' || TRIM(tanque.col_tqe) || ', ' || TRIM(tanque.ciu_tqe)) AS direccion
	FROM 	rdnota_vta,
	 		tanque,
	 		enruta
	WHERE 	rdnota_vta.numcte_nvta 		= tanque.numcte_tqe     
	 		AND rdnota_vta.numtqe_nvta 	= tanque.numtqe_tqe     
	 		AND rdnota_vta.numcte_nvta 	= paramCte
	 		AND rdnota_vta.numtqe_nvta 	= paramTqe
	 		AND enruta.ltssur_enr		> 0
 			AND enruta.totvta_enr		> 0
 			AND rdnota_vta.cia_nvta || rdnota_vta.pla_nvta || LPAD(rdnota_vta.fol_nvta,6,'0') = enruta.fol_enr	
			AND enruta.edoreg_enr		= 'F'
	ORDER BY 1 DESC
    RETURN 	fes,
			tlts,
			impt,
			pru,
			dir
    WITH RESUME;
END FOREACH;
END PROCEDURE;