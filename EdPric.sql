CREATE PROCEDURE EdPric
(	
	paramFecha		DATE    	
)

RETURNING
	CHAR(10),		
	CHAR(3),		
	CHAR(6),		
	CHAR(6);		
	
DEFINE fol		CHAR(10);	
DEFINE tprd 	CHAR(3); 	
DEFINE preco    CHAR(6);	
DEFINE precn 	CHAR(6);	
DEFINE pru		DECIMAL;	

DEFINE ecoInt	CHAR(6);					
DEFINE rutaInt  CHAR(4);					
DEFINE fhiInt 	CHAR(14);	
DEFINE fhfInt	CHAR(14);	


FOREACH cEcoRuta FOR 


	SELECT	a.fol_enr, 
			b.tprd_nvta,
			a.prc_enr,
			SUBSTRING(('' || c.pru_mprc) FROM 1 FOR 6),
			c.pru_mprc
	INTO	fol,
			tprd,
			preco,
			precn,
			pru
	FROM	enruta a, 
			nota_vta b,
			mov_prc c
	WHERE	a.fol_enr[5, 10] = b.fol_nvta
	AND		b.tprd_nvta = c.tpr_mprc
	AND		a.fecreg_enr = TO_CHAR(paramFecha, '%d%m%y')
	AND		a.edoreg_enr IN ('0', 'O', 'E')
	AND		b.edo_nvta = 'P'
	AND		MONTH(c.fei_mprc) = MONTH(paramFecha)
	AND		YEAR(c.fei_mprc) = YEAR(paramFecha)
	AND		a.prc_enr <> SUBSTRING(('' || pru_mprc) FROM 1 FOR 6)
	
	
		UPDATE	enruta
		SET		prc_enr = precn
		WHERE	fol_enr = fol
		AND		prc_enr = preco;
		
		UPDATE	nota_vta
		SET		pru_nvta = pru
		WHERE	fol_nvta = fol[5, 10]
		AND		tprd_nvta = tprd;
		
		RETURN	fol,
				tprd,					
				preco,
				precn
		WITH RESUME;

END FOREACH; 

END PROCEDURE; 