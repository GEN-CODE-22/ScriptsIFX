DROP PROCEDURE UpNotaVta;
CREATE PROCEDURE UpNotaVta(
	paramFolio	INTEGER,
	paramFolEnr CHAR(12),
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramRoute	CHAR(4),
	paramEco	CHAR(7),
	paramFecate DATE,
	paramHorSur DATETIME HOUR TO MINUTE,
	paramFliq	INTEGER,
	paramLts	DECIMAL,
	paramPru	DECIMAL,
	paramSimp	DECIMAL,
	paramIVA	DECIMAL,
	paramPIVA	DECIMAL,
	paramImpo	DECIMAL,
	paramTprd   CHAR(3),
	paramUsr	CHAR(8)
	)

	RETURNING
		CHAR(1),		
		INTEGER;		
		
			
	DEFINE control	CHAR(1);			
	
	DEFINE numped			INTEGER;
	DEFINE numcte			CHAR(6);
	DEFINE ruta				CHAR(4);
	DEFINE edo 				CHAR(1);	
	DEFINE fol				INTEGER;
	DEFINE numtqe			SMALLINT;
	DEFINE tip				CHAR(1);
	DEFINE uso				CHAR(2);
	DEFINE rfa				CHAR(1);
	DEFINE tpa				CHAR(1);
	DEFINE tprd				CHAR(3);
	DEFINE nextFol			INTEGER;
	DEFINE tpdo				CHAR(1);
	DEFINE aux				CHAR(1);
    DEFINE xFolEnr			CHAR(12);
	DEFINE fliq				INTEGER;
	DEFINE vfecliq			DATE;
	DEFINE vasiste			CHAR(1);
	DEFINE vimpasi			DECIMAL;
	DEFINE vvuelta  		SMALLINT;	
	
	SELECT	fec_erup
	INTO	vfecliq
	FROM	empxrutp
	WHERE	fliq_erup 	= paramFliq
			AND cia_erup = paramCia
			AND pla_erup = paramPla
			AND rut_erup = paramRoute;
			
	SELECT	NVL(asiste_enr,'N'),NVL(impasi_enr,0), NVL(vuelta_enr,0)
	INTO	vasiste,vimpasi,vvuelta
	FROM	enruta
	WHERE	fol_enr = paramFolEnr and eco_enr = paramEco;
	
	IF	vvuelta = 0 THEN
		SELECT	NVL(vuelta_pla,0)
		INTO	vvuelta
		FROM	planta
		WHERE	cia_pla = paramCia
				AND cve_pla = paramPla;
	END IF;
			
	IF EXISTS(SELECT 1 FROM nota_vta WHERE fol_nvta = paramFolio AND cia_nvta = paramCia AND pla_nvta = paramPla
			AND vuelta_nvta = vvuelta) THEN
	
		SELECT	ped_nvta,
				numcte_nvta,
				ruta_nvta,
				edo_nvta,
				tpa_nvta,
				uso_nvta,
				tprd_nvta,
				numtqe_nvta
		INTO	numped,
				numcte,
				ruta,
				edo,
				tpa,
				uso,
				tprd,
				numtqe
		FROM	nota_vta
		WHERE	fol_nvta = paramFolio
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla
		AND     vuelta_nvta = vvuelta;		

		IF edo = 'P' THEN		
			LET nextFol = 0;
			
			IF paramCte = numcte THEN
			
				IF ruta <> paramRoute THEN					
					
					UPDATE	nota_vta 
					SET		ruta_nvta = paramRoute
					WHERE	fol_nvta = paramFolio
					AND		cia_nvta = paramCia
					AND		pla_nvta = paramPla
					AND		ruta_nvta = ruta
					AND 	vuelta_nvta = vvuelta;
					
					UPDATE	pedidos
					SET		ruta_ped = paramRoute
					WHERE	num_ped = numped
					AND		ruta_ped = ruta;
					
					UPDATE	enruta
					SET		ruta_enr = paramRoute
					WHERE	fol_enr = paramFolEnr;	
					
				END IF;					
				
				IF LENGTH(tpa) > 0 AND LENGTH(uso) > 0 AND LENGTH(paramTprd) > 0 THEN					
						
					UPDATE	nota_vta
					SET		fes_nvta = vfecliq,
							fliq_nvta = paramFliq,
							edo_nvta = 'S',
							napl_nvta = 'N',
							nept_nvta = 'S',
							tlts_nvta = paramLts,
							tprd_nvta = paramTprd,
							pru_nvta = paramPru,
							simp_nvta = paramSimp,
							iva_nvta = paramIVA,
							ivap_nvta = paramPIVA,
							impt_nvta =  paramImpo,
							usr_nvta = paramUsr,
							asiste_nvta = vasiste,
							impasi_nvta = vimpasi
					WHERE	fol_nvta = paramFolio
					AND		cia_nvta = paramCia
					AND		pla_nvta = paramPla
					AND 	vuelta_nvta = vvuelta;
					
					
					EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,paramCte,numtqe);					
					
					UPDATE 	pedidos
					SET		edo_ped = 'S',
							fecrsur_ped = paramFecate,
							usrcan_ped = paramUsr,
							horrsur_ped = paramHorSur
					WHERE	num_ped = numped;	
					
					
					DELETE	
					FROM	hped_pen
					WHERE	fec_hppen 		= paramFecate
							AND ruta_hppen	= paramRoute
							AND nped_hppen	= numped;
					
	                LET xFolEnr = paramCia || paramPla || LPAD(paramFolio,6,'0');
					IF paramFolEnr <> xFolEnr THEN
	  				   UPDATE	enruta
					   SET		edovta_enr = 'l'
					   WHERE	fol_enr 	= paramFolEnr
					   			AND	ruta_enr = paramRoute;	
					   
					   UPDATE	enruta
					   SET		edoreg_enr 	= 'F',
					            edovta_enr 	= 'f'
					   WHERE	fol_enr = xFolEnr;				   
					   
					   INSERT INTO ref_enr
					   VALUES(xFolEnr,paramFolEnr );
					   
					   UPDATE	nota_vta
					   SET		ffis_nvta		= paramFolEnr  * 1.0
					   WHERE	fol_nvta 		= paramFolio
								AND	cia_nvta 	= paramCia
								AND	pla_nvta 	= paramPla
								AND vuelta_nvta = vvuelta;					   
					ELSE
					   UPDATE	enruta
					   SET		edovta_enr 		= 'l'
					   WHERE	fol_enr 		= paramFolEnr
					   			AND	ruta_enr 	= paramRoute;
	
	                END IF;
	                LET control = 'A';
	            ELSE
	            	LET control = 'B';
                END IF;
			ELSE		
				LET control = 'C'; 	
			END IF;			
		ELSE
		
			SELECT	fol_nvta,
					numtqe_nvta,
					tip_nvta,
					uso_nvta,
					rfa_nvta,
					tpa_nvta,
					tprd_nvta,
					tpdo_nvta,
					fliq_nvta
			INTO	fol,
					numtqe,
					tip,
					uso,
					rfa,
					tpa,
					tprd,
					tpdo,
					fliq
			FROM	nota_vta
			WHERE	fol_nvta = paramFolio
			AND		cia_nvta = paramCia
			AND		pla_nvta = paramPla
			AND 	vuelta_nvta = vvuelta;			
			
			IF (fliq <> paramFliq) THEN
				LET	nextFol = next_fol_nvta(paramCia, paramPla);				

				IF nextFol > 0 THEN
					LET aux = InsNotaVtaNoServ(nextFol,
													   paramCia,
													   paramPla,
													   paramCte,
													   numtqe,
													   paramRoute,
													   tip,
													   uso,
													   vfecliq,
													   vfecliq,
													   paramFliq,
													   'S',
													   rfa,
													   tpa,
													   'N',
													   'N',
													   paramLts,
													   paramPru,
													   paramImpo,
													   paramUsr,
													   tpdo,
													   'N/A',
													   paramFolEnr,
													   'N');
					LET aux = InsLiqLog(paramFliq,
												paramCia,
												paramPla,
												nextFol,
												paramUsr,
												paramFolio,
												'Nota de Venta',
												'cancelada o surtida'
												);
					UPDATE	enruta
					SET		edovta_enr = 'l',
							obser_enr = nextFol
					WHERE	fol_enr = paramFolEnr
					AND		ruta_enr = paramRoute;
					
				ELSE
					LET nextFol = 0; 
				END IF;
											 
				LET control = 'S';
			ELSE
				LET control = 'A';
				LET nextFol = 0;
			END IF;
		END IF;
	ELSE	
		LET control = 'N'; 
	END IF;	
	
	RETURN	control,
			nextFol;

END PROCEDURE;	

SELECT	ped_nvta,
		numcte_nvta,
		ruta_nvta,
		edo_nvta,
		tpa_nvta,
		uso_nvta,
		tprd_nvta,
		numtqe_nvta
FROM	nota_vta
WHERE	fol_nvta = 562857
AND		cia_nvta = '15'
AND		pla_nvta = '02';