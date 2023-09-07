CREATE PROCEDURE EdResOr
(
	paramCia		CHAR(2),	
	paramPla		CHAR(2),	
	paramFecha		DATE,    	
	paramFolio		CHAR(12),	
	paramUsr		CHAR(8)		
)

	
	RETURNING	
		SMALLINT;		

	
	DEFINE edited   SMALLINT;
	DEFINE nvta		INT;		
	DEFINE ped 		INT; 		
	DEFINE edo		CHAR(1);	
	DEFINE vedoreg	CHAR(1);	
	DEFINE vprod	CHAR(3);	
	DEFINE vpru		DECIMAL;	
	DEFINE vreg		SMALLINT;	
	DEFINE vrut		CHAR(4);	

	SELECT	fol_nvta,
			ped_nvta,
			edo_nvta
	INTO	nvta,
			ped,
			edo
	FROM	nota_vta
	WHERE	cia_nvta = paramCia
	AND		pla_nvta = paramPla
	AND		fol_nvta = (paramFolio[5, 10] * 1);
	
	SELECT	edoreg_enr
	INTO	vedoreg
	FROM	enruta
	WHERE	fol_enr = paramFolio;
	
	IF edo = 'P' and vedoreg = 'O' THEN		
		SELECT	NVL(tprd_nvta,''),
				ruta_nvta
		INTO	vprod,
				vrut
		FROM	nota_vta
		WHERE	fol_nvta = nvta
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla;
		
		IF LENGTH(vprod) = 0 THEN
			SELECT	reg_rut
			INTO	vreg
			FROM	ruta
			WHERE	cve_rut	= vrut;	
			
			SELECT	tpr_prc
			INTO	vprod
			FROM	precios
			WHERE	reg_prc = vreg
					AND tid_prc = 'E'  
					AND pri_prc = 'S';  
		END IF;
		
		SELECT	pru_mprc
		INTO	vpru
		FROM	mov_prc
		WHERE	tpr_mprc = vprod
				AND fei_mprc <= paramFecha
				AND fet_mprc >= paramFecha;
		
		UPDATE	pedidos
		SET     fecsur_ped = paramFecha,
				usr_ped  = paramUsr,
				fhr_ped  = CURRENT,
				nmod_ped = NVL(nmod_ped,0) + 1
		WHERE	num_ped = ped;

		UPDATE 	nota_vta
		SET 	fes_nvta = paramFecha
		WHERE	fol_nvta = nvta
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla;			
		
		UPDATE	enruta
		SET     obser_enr = NULL			
		WHERE   fol_enr = paramFolio;		
		
		UPDATE	enruta
		SET     fecreg_enr = TO_CHAR(paramFecha, '%d%m%y'),
				edoreg_enr = '0',
				eco_enr = 'N/A',
				prc_enr = vpru || '',
				obser_enr = NULL,
				reccel_enr = 0			
		WHERE   fol_enr = paramFolio;
		LET edited = 1;
	
	ELSE
	
		LET edited = 0;
		
	END IF
	
	RETURN edited;
	
END PROCEDURE; 

SELECT	*			
FROM	precios
WHERE	reg_prc = 78
		AND tid_prc = 'E'  
		AND pri_prc = 'S'; 
		

SELECT	tid_prc			
FROM	precios
group by 1 