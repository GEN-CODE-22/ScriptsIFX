CREATE PROCEDURE EdRoOr
(
	paramCia		CHAR(2),	
	paramPla		CHAR(2),	
	paramRoute		CHAR(4),    
	paramFolio		CHAR(12),	
	paramUsr		CHAR(8)		
)

	
	RETURNING	
		SMALLINT;		

	
	DEFINE edited   SMALLINT;	
		
	DEFINE nvta		INT;		
	DEFINE ped 		INT; 		
	DEFINE edo		CHAR(1);	
	DEFINE unid		CHAR(7);	
	DEFINE vedoreg	CHAR(1);	

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
	
	SELECT	unid_rneco
	INTO	unid
	FROM	ri505_neco
	WHERE	ruta_rneco = paramRoute;
	
	IF unid is null THEN
		LET unid = "N/A";
	END IF;	

	SELECT	edoreg_enr
	INTO	vedoreg
	FROM	enruta
	WHERE	fol_enr = paramFolio;
		
	IF edo = 'P' and vedoreg = 'O' THEN

		UPDATE	pedidos
		SET     ruta_ped = paramRoute,
				usr_ped  = paramUsr,
				fhr_ped  = CURRENT,
				nmod_ped = NVL(nmod_ped,0) + 1,
			    edotx_ped= 'N'
		WHERE	num_ped = ped;

		UPDATE 	nota_vta
		SET 	ruta_nvta = paramRoute
		WHERE	fol_nvta = nvta
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla;
		
		UPDATE	enruta
		SET     obser_enr = NULL			
		WHERE   fol_enr = paramFolio;
		
	
			UPDATE	enruta
			SET     eco_enr = unid,
					ruta_enr = paramRoute,
					edoreg_enr = '0',
					obser_enr = NULL,
					reccel_enr = 0		
			WHERE   fol_enr = paramFolio;
	END IF;

END PROCEDURE; 