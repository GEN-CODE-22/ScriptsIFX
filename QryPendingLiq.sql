EXECUTE PROCEDURE QryPendingLiq('15','79','MP01')
EXECUTE PROCEDURE QryPendingLiq('15','02','M001')

CREATE PROCEDURE QryPendingLiq(paramCia char(2), 
								paramPla char(2),
								paramRoute char(4))
	RETURNING 
		INT,					
		CHAR(2),				
		CHAR(2),				
		CHAR(4),				
		CHAR(7),				
		DATE,					
		CHAR(1),				
		CHAR(1),				
		CHAR(4),				
		CHAR(4),				
		CHAR(4),				
		CHAR(1),
		CHAR(4),				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		DECIMAL,				
		CHAR(8),				
		CHAR(8),				
		SMALLINT,				
		INT,					
		DATETIME YEAR TO MINUTE,
		CHAR(5),				
		CHAR(5),				
		INT,		
		DECIMAL;					

	DEFINE 	fliq	INT;					
	DEFINE	cia		CHAR(2);				
	DEFINE	pla 	CHAR(2);				
	DEFINE	rut 	CHAR(4);				
	DEFINE	uni 	CHAR(7);				
	DEFINE	fec		DATE;				
	DEFINE	edo		CHAR(1);				
	DEFINE	npt		CHAR(1);			
	DEFINE	chf		CHAR(4);			
	DEFINE	ay1 	CHAR(4);				
	DEFINE	ay2 	CHAR(4);				
	DEFINE	pcs 	CHAR(1);			
	DEFINE	arut 	CHAR(4);				
	DEFINE	lin		DECIMAL;			
	DEFINE	lfi		DECIMAL;				
	DEFINE	ldi		DECIMAL;				
	DEFINE	pin		DECIMAL;				
	DEFINE	pfi		DECIMAL;				
	DEFINE	pdi		DECIMAL;				
	DEFINE	tot		DECIMAL;			
	DEFINE	imp		DECIMAL;			
	DEFINE	lcre	DECIMAL;				
	DEFINE	vcre	DECIMAL;				
	DEFINE	lefe	DECIMAL;				
	DEFINE	vefe	DECIMAL;				
	DEFINE	lpar	DECIMAL;				
	DEFINE	usr		CHAR(8);			
	DEFINE	urea	CHAR(8);			
	DEFINE	nnv		SMALLINT;			
	DEFINE	caj		INT;					
	DEFINE	fyh		DATETIME YEAR TO MINUTE;
	DEFINE	hini	CHAR(5);				
	DEFINE	hfin	CHAR(5);				
	DEFINE  vgini   INT;	
	DEFINE  vimpasi	DECIMAL;				
	
	FOREACH consorcanc FOR
		SELECT 	fliq_erup,
				cia_erup,
				pla_erup,
				rut_erup,
				uni_erup,
				fec_erup,
				edo_erup,
				npt_erup,
				chf_erup,
				ay1_erup,
				ay2_erup,
				pcs_erup,
				arut_erup,
				lin_erup,
				lfi_erup,
				ldi_erup,
				pin_erup,
				pfi_erup,
				pdi_erup,
				tot_erup,
				imp_erup,
				lcre_erup,
				vcre_erup,
				lefe_erup,
				vefe_erup,
				lpar_erup,
				usr_erup,
				urea_erup,
				nnv_erup,
				caj_erup,
				fyh_erup,
				hini_erup,
				hfin_erup,
				NVL(impasi_erup,0)			
		INTO   	fliq,
				cia,
				pla,
				rut,
				uni,
				fec,
				edo,
				npt,
				chf,
				ay1,
				ay2,
				pcs,
				arut,
				lin,
				lfi,
				ldi,
				pin,
				pfi,
				pdi,
				tot,
				imp,
				lcre,
				vcre,
				lefe,
				vefe,
				lpar,
				usr,
				urea,
				nnv,
				caj,
				fyh,
				hini,
				hfin,
				vimpasi
		FROM   	empxrutp
		WHERE  	rut_erup = paramRoute
		AND		cia_erup = paramCia
		AND		pla_erup = paramPla
		AND		edo_erup = 'P'
		AND		(caj_erup = 0 
		OR		 caj_erup IS NULL)
		AND     fec_erup = TODAY
		AND		fliq_erup = (SELECT	MIN(fliq_erup)
							FROM	empxrutp
							WHERE	rut_erup = paramRoute
									AND		cia_erup = paramCia
									AND		pla_erup = paramPla
									AND		edo_erup = 'P'
									AND		(caj_erup = 0 
									OR		 caj_erup IS NULL)
									AND     fec_erup = TODAY)
		ORDER BY fec_erup
		
		SELECT	NVL(MAX(bst_mnvta),0) + 1
		INTO	vgini
		FROM	nota_vta,
				movxnvta,
				empxrutp
		WHERE	nota_vta.cia_nvta 		= movxnvta.cia_mnvta 
				AND	nota_vta.pla_nvta 	= movxnvta.pla_mnvta 
				AND	nota_vta.fol_nvta 	= movxnvta.fol_mnvta
				AND nota_vta.fliq_nvta	= empxrutp.fliq_erup
				AND empxrutp.fliq_erup  < fliq
				AND empxrutp.fec_erup 	= fec
				AND empxrutp.cia_erup	= paramCia
				AND empxrutp.pla_erup	= paramPla
				AND empxrutp.rut_erup   = paramRoute;
		RETURN	fliq,
				cia,
				pla,
				rut,
				uni,
				fec,
				edo,
				npt,
				chf,
				ay1,
				ay2,
				pcs,
				arut,
				lin,
				lfi,
				ldi,
				pin,
				pfi,
				pdi,
				tot,
				imp,
				lcre,
				vcre,
				lefe,
				vefe,
				lpar,
				usr,
				urea,
				nnv,
				caj,
				fyh,
				hini,
				hfin,
				vgini,
				vimpasi
		WITH RESUME;		   
	END FOREACH;

END PROCEDURE; 

SELECT 	fliq_erup,
				cia_erup,
				pla_erup,
				rut_erup,
				uni_erup,
				fec_erup,
				edo_erup,
				npt_erup,
				chf_erup,
				ay1_erup,
				ay2_erup,
				pcs_erup,
				arut_erup,
				lin_erup,
				lfi_erup,
				ldi_erup,
				pin_erup,
				pfi_erup,
				pdi_erup,
				tot_erup,
				imp_erup,
				lcre_erup,
				vcre_erup,
				lefe_erup,
				vefe_erup,
				lpar_erup,
				usr_erup,
				urea_erup,
				nnv_erup,
				caj_erup,
				fyh_erup,
				hini_erup,
				hfin_erup,
				NVL(impasi_erup,0)			
		INTO   	fliq,
				cia,
				pla,
				rut,
				uni,
				fec,
				edo,
				npt,
				chf,
				ay1,
				ay2,
				pcs,
				arut,
				lin,
				lfi,
				ldi,
				pin,
				pfi,
				pdi,
				tot,
				imp,
				lcre,
				vcre,
				lefe,
				vefe,
				lpar,
				usr,
				urea,
				nnv,
				caj,
				fyh,
				hini,
				hfin,
				vimpasi
		FROM   	empxrutp
		WHERE  	rut_erup = paramRoute
		AND		cia_erup = paramCia
		AND		pla_erup = paramPla
		AND		edo_erup = 'P'
		AND		(caj_erup = 0 
		OR		 caj_erup IS NULL)
		AND     fec_erup = TODAY
		AND		fliq_erup = (SELECT	MIN(fliq_erup)
							FROM	empxrutp
							WHERE	rut_erup = paramRoute
									AND		cia_erup = paramCia
									AND		pla_erup = paramPla
									AND		edo_erup = 'P'
									AND		(caj_erup = 0 
									OR		 caj_erup IS NULL)
									AND     fec_erup = TODAY) 
									
									
SELECT 	*
FROM   	empxrutp
WHERE  	rut_erup = 'MP01'
AND		cia_erup = '15'
AND		pla_erup = '79'
AND     fec_erup = TODAY
AND		edo_erup = 'P'
AND		(caj_erup = 0 
OR		 caj_erup IS NULL)

AND		fliq_erup = (SELECT	MIN(fliq_erup)
					FROM	empxrutp
					WHERE	rut_erup = paramRoute
							AND		cia_erup = paramCia
							AND		pla_erup = paramPla
							AND		edo_erup = 'P'
							AND		(caj_erup = 0 
							OR		 caj_erup IS NULL)
							AND     fec_erup = TODAY) 