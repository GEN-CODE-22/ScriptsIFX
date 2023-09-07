CREATE PROCEDURE EdOrPr
(	
	paramOr		INT,
	paramDate   DATE,
	paramCia	CHAR(2),
	paramPla	CHAR(2)
)

	RETURNING 
		SMALLINT;		

	DEFINE	folnvta INT;
	DEFINE  folenr  CHAR(10);
	DEFINE  edited  SMALLINT;
	DEFINE  cia 	CHAR(2);
	DEFINE	pla     CHAR(2); 
	DEFINE  edo		CHAR(1);     
	
	SELECT	fol_nvta,
			cia_nvta,
			pla_nvta,
			edo_nvta
	INTO	folnvta,
			cia,
			pla,
			edo
	FROM	nota_vta
	WHERE	ped_nvta = paramOr;
	
	IF edo = 'P' THEN

		LET folenr = cia || pla || LPAD(folnvta, 6, '0');

		UPDATE	pedidos
		SET     fecsur_ped = paramDate
		WHERE	num_ped = paramOr;
		
		UPDATE	nota_vta
		SET     fes_nvta = paramDate
		WHERE	fol_nvta = folnvta
		AND		cia_nvta = cia
		AND		pla_nvta = pla
		AND		edo_nvta = 'P';	

		UPDATE  enruta
		SET     fecreg_enr = TO_CHAR(paramDate, '%d%m%y'),
				edoreg_enr = '0',
				reccel_enr = 0		
		WHERE	fol_enr = folenr;

		LET edited = 1;
	ELSE
		
		LET edited = 0;
		
	END IF

	RETURN 	edited;

	
END PROCEDURE; 