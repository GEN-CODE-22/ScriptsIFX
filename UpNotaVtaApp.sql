drop procedure UpNotaVtaApp;
CREATE PROCEDURE UpNotaVtaApp(
	paramFolio	INTEGER,
	paramFolEnr CHAR(12),
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramTqe	SMALLINT,
	paramRoute	CHAR(4),
	paramEco	CHAR(7),
	paramFecate DATE,
	paramHorSur DATETIME HOUR TO MINUTE,
	paramFliq	INTEGER,
	paramLts	DECIMAL,
	paramImpo	DECIMAL,
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
	DEFINE vivap			DECIMAL;
	DEFINE viva				DECIMAL;
	DEFINE vsubimporte		DECIMAL;
	DEFINE vprecio			DECIMAL;
	DEFINE vnorefbanco		INT;
	DEFINE vvuelta  		SMALLINT;	
	
	LET vnorefbanco = 0;
	LET nextFol = 0;
	
	SELECT  NVL(vuelta_enr,0)
	INTO	vvuelta
	FROM	enruta
	WHERE   fol_enr = paramFolEnr;
	IF	vvuelta = 0 THEN
		SELECT	NVL(vuelta_pla,0)
		INTO	vvuelta
		FROM	planta
		WHERE	cia_pla = paramCia
				AND cve_pla = paramPla;
	END IF;
	
	SELECT	tpdo_nvta
	INTO	tpdo
	FROM	nota_vta 
	WHERE 	fol_nvta 	= paramFolio
			AND cia_nvta	= paramCia
			AND pla_nvta	= paramPla
			AND vuelta_nvta = vvuelta;
	
	SELECT	NVL(MIN(fol_nvta),0)
	INTO	vnorefbanco
	FROM	nota_vta 
	WHERE 	tpdo_nvta = 'A' and tpa_nvta in('R','B') and (observ_nvta is null or observ_nvta = '')
			AND fol_nvta 	= paramFolio
			AND cia_nvta	= paramCia
			AND pla_nvta	= paramPla
			AND vuelta_nvta = vvuelta;
			
	SELECT	fec_erup
	INTO	vfecliq
	FROM	empxrutp
	WHERE	fliq_erup 	= paramFliq
			AND cia_erup = paramCia
			AND pla_erup = paramPla
			AND rut_erup = paramRoute;
	
	SELECT	NVL(asiste_enr,'N'),NVL(impasi_enr,0)
	INTO	vasiste,vimpasi
	FROM	enruta
	WHERE	fol_enr = paramFolEnr and eco_enr = paramEco;
	
	IF tpdo = 'A' THEN
		IF vnorefbanco = 0 THEN				
			
			IF EXISTS(SELECT 1 FROM nota_vta WHERE fol_nvta = paramFolio AND cia_nvta = paramCia AND pla_nvta = paramPla 
			and tpdo_nvta = 'A' AND vuelta_nvta = vvuelta) THEN
			
				SELECT	ped_nvta,
						numcte_nvta,
						ruta_nvta,
						edo_nvta,
						tpa_nvta,
						uso_nvta,
						tprd_nvta,
						numtqe_nvta,
						pru_nvta
				INTO	numped,
						numcte,
						ruta,
						edo,
						tpa,
						uso,
						tprd,
						numtqe, 
						vprecio
				FROM	nota_vta
				WHERE	fol_nvta = paramFolio
				AND		cia_nvta = paramCia
				AND		pla_nvta = paramPla
				AND 	vuelta_nvta = vvuelta;		
		
				IF edo = 'P' THEN		
					LET nextFol = 0;
					IF LENGTH(tpa) > 0 AND LENGTH(uso) > 0 AND LENGTH(tprd) > 0 AND vprecio > 0 THEN					
						SELECT	iva_mprc
						INTO	vivap
						FROM	mov_prc
						WHERE	tpr_mprc = tprd AND fei_mprc <= vfecliq AND fet_mprc >= vfecliq;
						LET vsubimporte = paramImpo / ((vivap / 100) + 1);
						LET viva = paramImpo - vsubimporte;
						LET vprecio = paramImpo / paramLts;
						
						UPDATE	nota_vta
						SET		fes_nvta = vfecliq,
								fliq_nvta = paramFliq,
								numcte_nvta = paramCte,
								numtqe_nvta = paramTqe,
								edo_nvta = 'S',
								napl_nvta = 'N',
								nept_nvta = 'S',
								tlts_nvta = paramLts,
								pru_nvta = vprecio,
								simp_nvta = vsubimporte,
								iva_nvta = viva,
								ivap_nvta = vivap,
								impt_nvta =  paramImpo,
								usr_nvta = paramUsr,
								asiste_nvta = vasiste,
								impasi_nvta = vimpasi
						WHERE	fol_nvta = paramFolio
						AND		cia_nvta = paramCia
						AND		pla_nvta = paramPla
						AND 	vuelta_nvta = vvuelta;
						
						UPDATE 	pedidos
						SET		edo_ped = 'S',
								numcte_ped = paramCte,
								numtqe_ped = paramTqe,
								fecrsur_ped = paramFecate,
								usrcan_ped = paramUsr,
								horrsur_ped = paramHorSur
						WHERE	num_ped = numped;	
						
						UPDATE	enruta
						SET		edovta_enr 		= 'l'
						WHERE	fol_enr 		= paramFolEnr
						   		AND	ruta_enr 	= paramRoute;				
						
						DELETE	
						FROM	hped_pen
						WHERE	fec_hppen 		= paramFecate
								AND ruta_hppen	= paramRoute
								AND nped_hppen	= numped;
								
						EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,paramCte,numtqe);
		                
		                LET control = 'A';
		            ELSE
		            	LET control = 'B';
		            END IF;
				ELSE		
					LET control = 'S'; 	
				END IF;			
			ELSE	
				LET control = 'N'; 
			END IF;	
		ELSE
			LET control = 'X';
		END IF;
	END IF;
	
	IF tpdo = 'W' THEN
		IF EXISTS(SELECT 1 FROM nota_vta WHERE fol_nvta = paramFolio AND cia_nvta = paramCia AND pla_nvta = paramPla 
			and tpdo_nvta = 'W' AND vuelta_nvta = vvuelta) THEN
			
				SELECT	ped_nvta,
						numcte_nvta,
						ruta_nvta,
						edo_nvta,
						tpa_nvta,
						uso_nvta,
						tprd_nvta,
						numtqe_nvta,
						pru_nvta
				INTO	numped,
						numcte,
						ruta,
						edo,
						tpa,
						uso,
						tprd,
						numtqe, 
						vprecio
				FROM	nota_vta
				WHERE	fol_nvta = paramFolio
				AND		cia_nvta = paramCia
				AND		pla_nvta = paramPla
				AND 	vuelta_nvta = vvuelta;		
		
				IF edo = 'P' THEN		
					LET nextFol = 0;
					IF LENGTH(tpa) > 0 AND LENGTH(uso) > 0 AND LENGTH(tprd) > 0 AND vprecio > 0 THEN					
						SELECT	iva_mprc
						INTO	vivap
						FROM	mov_prc
						WHERE	tpr_mprc = tprd AND fei_mprc <= vfecliq AND fet_mprc >= vfecliq;
						LET vsubimporte = paramImpo / ((vivap / 100) + 1);
						LET viva = paramImpo - vsubimporte;
						LET vprecio = paramImpo / paramLts;
						
						UPDATE	nota_vta
						SET		fes_nvta = vfecliq,
								fliq_nvta = paramFliq,
								numcte_nvta = paramCte,
								numtqe_nvta = paramTqe,
								edo_nvta = 'S',
								napl_nvta = 'N',
								nept_nvta = 'S',
								tlts_nvta = paramLts,
								pru_nvta = vprecio,
								simp_nvta = vsubimporte,
								iva_nvta = viva,
								ivap_nvta = vivap,
								impt_nvta =  paramImpo,
								usr_nvta = paramUsr,
								asiste_nvta = vasiste,
								impasi_nvta = vimpasi
						WHERE	fol_nvta = paramFolio
						AND		cia_nvta = paramCia
						AND		pla_nvta = paramPla
						AND 	vuelta_nvta = vvuelta;
						
						UPDATE 	pedidos
						SET		edo_ped = 'S',
								numcte_ped = paramCte,
								numtqe_ped = paramTqe,
								fecrsur_ped = paramFecate,
								usrcan_ped = paramUsr,
								horrsur_ped = paramHorSur
						WHERE	num_ped = numped;	
						
						UPDATE	enruta
						SET		edovta_enr 		= 'l'
						WHERE	fol_enr 		= paramFolEnr
						   		AND	ruta_enr 	= paramRoute;				
						
						DELETE	
						FROM	hped_pen
						WHERE	fec_hppen 		= paramFecate
								AND ruta_hppen	= paramRoute
								AND nped_hppen	= numped;
								
						EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,paramCte,numtqe);
		                
		                LET control = 'A';
		            ELSE
		            	LET control = 'B';
		            END IF;
				ELSE		
					LET control = 'S'; 	
				END IF;			
			ELSE	
				LET control = 'N'; 
			END IF;	
	END IF;
	RETURN	control,
			nextFol;

END PROCEDURE;	

SELECT  NVL(vuelta_enr,0)
	FROM	enruta
	WHERE   fol_enr = '1502154135';

SELECT	tpdo_nvta
FROM	nota_vta 
WHERE 	fol_nvta 	= 154637
		AND cia_nvta	= '15'
		AND pla_nvta	= '02'
		AND vuelta_nvta = 13;
		
SELECT	NVL(MIN(fol_nvta),0)
FROM	nota_vta 
WHERE 	tpdo_nvta = 'A' and tpa_nvta in('R','B') and (observ_nvta is null or observ_nvta = '')
		AND fol_nvta 	= 154637
		AND cia_nvta	= '15'
		AND pla_nvta	= '02'
		AND vuelta_nvta = 13;
SELECT 1 FROM nota_vta WHERE fol_nvta = 154637 AND cia_nvta = '15' AND pla_nvta = '02' 
			and tpdo_nvta = 'W' AND vuelta_nvta = 13

SELECT	ped_nvta,
		numcte_nvta,
		ruta_nvta,
		edo_nvta,
		tpa_nvta,
		uso_nvta,
		tprd_nvta,
		numtqe_nvta,
		pru_nvta
FROM	nota_vta
WHERE	fol_nvta = 154637
AND		cia_nvta = '15'
AND		pla_nvta = '02'
AND 	vuelta_nvta = 13;	
							
select	*
from	enruta
where	fol_enr = '1502156641'

update	enruta
set		vuelta_enr = 13
where	fol_enr = '1502156915'

select	*
from	nota_vta
where	fol_nvta = 156641

select	*
from	nota_vta
where	tpdo_nvta = 'W' and edo_nvta = 'P' and fes_nvta = '2022-10-03' and tip_nvta = 'E'

select	*
from	enruta e, nota_vta n
where	fol_enr[5,10] = n.fol_nvta and edoreg_enr = 'F' and
		tpdo_nvta = 'W' and edo_nvta = 'S' and fes_nvta = '2022-10-03' and tip_nvta = 'E'