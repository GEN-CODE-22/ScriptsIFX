execute PROCEDURE QryServOrNote('070615',1,'15','08');
CREATE PROCEDURE QryServOrNote(
	paramCte	CHAR(6),
	paramTank	SMALLINT,
	paramCia	CHAR(2),
	paramPla	CHAR(2)
	)


	RETURNING
		INTEGER,					
		DATETIME YEAR TO MINUTE,	
		CHAR(1),					
		CHAR(40),				
		DATE,						
		INTEGER,					
		INTEGER,					
		CHAR(1);					
	
	DEFINE num		INTEGER;					
	DEFINE fhr		DATETIME YEAR TO MINUTE;	
	DEFINE tipo		CHAR(1);					
	DEFINE observ	CHAR(40);					
	DEFINE fecsur	DATE;						
	DEFINE fol		INTEGER;					
	DEFINE fliq		INTEGER;					
	DEFINE edo		CHAR(1);					
	

	SELECT	num_ped,
			fhr_ped,
			tipo_ped,
			observ_ped,
			fecsur_ped
	INTO	num,
			fhr,
			tipo,
			observ,
			fecsur
	FROM 	pedidos
	WHERE	numcte_ped = paramCte
	AND		numtqe_ped = paramTank
	AND		edo_ped IN ('P', 'p')
	AND		ruta_ped IS NOT NULL
	AND		tipo_ped <> 'C' AND tipo_ped IS NOT NULL;

	SELECT	fol_nvta,
			fliq_nvta,
			edo_nvta
	INTO	fol,
			fliq,
			edo		
	FROM	nota_vta 
	WHERE	numcte_nvta = paramCte
	AND		numtqe_nvta = paramTank
	AND		edo_nvta = 'P'
	--AND     ped_nvta = num
	AND		cia_nvta = paramCia
	AND		pla_nvta = paramPla
	AND		ruta_nvta IS NOT NULL
	AND		tip_nvta <> 'C' AND tip_nvta IS NOT NULL;
	
	
	RETURN	num,
			fhr,			
			tipo,
			observ,
			fecsur,
			fol,
			fliq,
			edo;	

END PROCEDURE;	

SELECT	num_ped,
			fhr_ped,
			tipo_ped,
			observ_ped,
			fecsur_ped
	FROM 	pedidos
	WHERE	numcte_ped = '070615'
	AND		numtqe_ped = 1
	AND		edo_ped IN ('P', 'p')
	AND		ruta_ped IS NOT NULL
	AND		tipo_ped <> 'C' AND tipo_ped IS NOT NULL;
	
SELECT	fol_nvta,
			fliq_nvta,
			edo_nvta
	FROM	nota_vta 
	WHERE	numcte_nvta = '070615'
	AND		numtqe_nvta = 1
	AND		edo_nvta = 'P'
	--AND     ped_nvta = num
	AND		cia_nvta = '15'
	AND		pla_nvta = '08'
	AND		ruta_nvta IS NOT NULL
	AND		tip_nvta <> 'C' AND tip_nvta IS NOT NULL;
	