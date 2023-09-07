EXECUTE PROCEDURE QryRepLiq(6054,'15','02','M030')
DROP PROCEDURE QryRepLiq;

CREATE PROCEDURE qryrepliq(
	paramFolio	INTEGER,
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramRoute	CHAR(4)
)

	RETURNING
		INTEGER,						
		CHAR(4),						
		CHAR(7),						
		DATE,							
		CHAR(56),						
		CHAR(56),						
		CHAR(56),						
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
		SMALLINT,						
		DATETIME YEAR TO MINUTE,		
		CHAR(5),						
		CHAR(5),						
		INT,							
		CHAR(6),					
		SMALLINT,							
		CHAR(100),						
		CHAR(1),						
		DECIMAL,						
		CHAR(3),						
		DECIMAL,						
		DECIMAL,						
		DECIMAL,						
		DECIMAL,						
		SMALLINT,						
		CHAR(90),						
		INTEGER,						
		DECIMAL,						
		CHAR(2),						
		CHAR(2),						
		CHAR(50),						
		CHAR(1),						
		DECIMAL,
		DECIMAL,
		DECIMAL,		
		DECIMAL,
		DECIMAL,
		DECIMAL,
		DECIMAL,
		DECIMAL;	

	DEFINE	fliq 	INTEGER;						
	DEFINE 	rut		CHAR(4);						
	DEFINE  uni		CHAR(7);						
	DEFINE  fec 	DATE;							
	DEFINE	chf 	CHAR(56);						
	DEFINE	ay1 	CHAR(56);						
	DEFINE	ay2 	CHAR(56);						
	DEFINE	lin 	DECIMAL;						
	DEFINE	ldi 	DECIMAL;	
	DEFINE	pin 	DECIMAL;						
	DEFINE	pfi 	DECIMAL;					
	DEFINE	pdi 	DECIMAL;						
	DEFINE	tot 	DECIMAL;							
	DEFINE	imp 	DECIMAL;						
	DEFINE	lcre    DECIMAL;						
	DEFINE	vcre 	DECIMAL;						
	DEFINE	lefe 	DECIMAL;						
	DEFINE	vefe 	DECIMAL;						
	DEFINE	lpar 	DECIMAL;						
	DEFINE	nnv 	SMALLINT;						
	DEFINE	fyh 	DATETIME YEAR TO MINUTE;		
	DEFINE	hini	CHAR(5);						
	DEFINE	hfin	CHAR(5);						
	DEFINE	nump 	INT;							
	DEFINE	numc 	CHAR(6);						
	DEFINE	numtqe 	SMALLINT;	
	DEFINE	nom		CHAR(100);						
	DEFINE	tip 	CHAR(1);						
	DEFINE	tlts 	DECIMAL;						
	DEFINE	tprd 	CHAR(3);						
	DEFINE	pru 	DECIMAL;						
	DEFINE	simpt 	DECIMAL;						
	DEFINE	iva 	DECIMAL;						
	DEFINE	impt 	DECIMAL;						
	DEFINE	bst 	SMALLINT;						
	DEFINE	dir 	CHAR(90);						
	DEFINE	fol 	INTEGER;						
	DEFINE	folf 	DECIMAL;						
	DEFINE	cia 	CHAR(2);						
	DEFINE	cvepla 	CHAR(2);						
	DEFINE	pla 	CHAR(50);						
	DEFINE	tpa 	CHAR(1);
	DEFINE  lfi     DECIMAL;
	DEFINE  vimpasin DECIMAL;
	DEFINE  vimpasi	DECIMAL;
	DEFINE  vimpasie	DECIMAL;	
	DEFINE  vimpasic	DECIMAL;
	DEFINE  vimpasitot	DECIMAL;			
	DEFINE  vtltsotr	DECIMAL;
	DEFINE  vimpotr		DECIMAL;			
	DEFINE  vimpasio	DECIMAL;					
	
	FOREACH consorcanc FOR
	

		SELECT	empxrutp.fliq_erup, 
				empxrutp.rut_erup, 
				empxrutp.uni_erup, 
				empxrutp.fec_erup, 
				'(' || chofer.cve_emp || ') ' || TRIM(chofer.ape_emp) || ' ' || TRIM(chofer.nom_emp),
				'(' || ayuda1.cve_emp || ') ' || TRIM(ayuda1.ape_emp) || ' ' || TRIM(ayuda1.nom_emp),
				'(' || ayuda2.cve_emp || ') ' || TRIM(ayuda2.ape_emp) || ' ' || TRIM(ayuda2.nom_emp), 
				empxrutp.lin_erup, 
				empxrutp.ldi_erup, 
				empxrutp.pin_erup,
				empxrutp.pfi_erup, 
				empxrutp.pdi_erup, 
				empxrutp.tot_erup, 
				empxrutp.imp_erup, 
				empxrutp.lcre_erup,
				empxrutp.vcre_erup, 
				empxrutp.lefe_erup, 
				empxrutp.vefe_erup, 
				empxrutp.lpar_erup, 
				empxrutp.nnv_erup,
				empxrutp.fyh_erup, 
				empxrutp.hini_erup, 
				empxrutp.hfin_erup, 
				nota_vta.ped_nvta, 
				nota_vta.numcte_nvta, 
				nota_vta.numtqe_nvta, 
				case when trim(cliente.razsoc_cte) <> '' then trim(cliente.razsoc_cte) 
			    else case when cliente.ali_cte <> '' then trim(cliente.ali_cte) || ', '
			    else '' end || trim(cliente.nom_cte) || ' ' || trim(cliente.ape_cte) 
			    end AS ncom_cte, 
			    nota_vta.tip_nvta, 
			    nota_vta.tlts_nvta, 
			    nota_vta.tprd_nvta, 
			    nota_vta.pru_nvta,
			    nota_vta.simp_nvta,
			    nota_vta.iva_nvta,			
				nota_vta.impt_nvta, 
			    movxnvta.bst_mnvta, 
			    (TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe)) As dir_tqe,
			    nota_vta.fol_nvta,
			    nota_vta.ffis_nvta,  
			    empxrutp.cia_erup, 
			    nota_vta.pla_nvta,
			    planta.cve_pla || ' ' ||  planta.nom_pla, 		 
				nota_vta.tpa_nvta, 
			    empxrutp.lfi_erup,
			    NVL(nota_vta.impasi_nvta,0), 
			    NVL(empxrutp.impase_erup,0),		
			    NVL(empxrutp.impasc_erup,0),		
			    NVL(empxrutp.impasi_erup,0),
			    NVL(empxrutp.lotr_erup,0),		
			    NVL(empxrutp.votr_erup,0),
			    NVL(empxrutp.impaso_erup,0)		   
		INTO	fliq,
				rut,
				uni,	
				fec, 	
				chf,	
				ay1,	
				ay2, 	
				lin,
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
				nnv, 	
				fyh,	
				hini,	
				hfin,	
				nump, 	
				numc,	
				numtqe, 	
				nom,
				tip,
				tlts, 	
				tprd, 	
				pru, 
				simpt,
				iva,	
				impt, 	
				bst,
				dir, 	
				fol, 
				folf,	
				cia,
				cvepla, 	
				pla, 	
				tpa,
				lfi,
				vimpasin,
				vimpasie,
				vimpasic,
				vimpasitot,
				vtltsotr,
				vimpotr,
				vimpasio	
		FROM	empxrutp, 			  
				nota_vta, 
			    cliente, 
			    tanque, 
			    planta,
			    empleado chofer,
		OUTER  	movxnvta,
		OUTER	empleado ayuda1,
		OUTER	empleado ayuda2
		WHERE	(empxrutp.cia_erup 			= nota_vta.cia_nvta 
				AND	empxrutp.fliq_erup 		= nota_vta.fliq_nvta 
				AND	empxrutp.rut_erup 		= nota_vta.ruta_nvta)
				AND	(nota_vta.cia_nvta 		= cliente.cia_cte 
				AND	nota_vta.numcte_nvta	= cliente.num_cte)
				AND	(nota_vta.cia_nvta 		= tanque.cia_tqe 
				AND	nota_vta.numcte_nvta	= tanque.numcte_tqe 
				AND	nota_vta.numtqe_nvta	= tanque.numtqe_tqe)
				AND	(nota_vta.cia_nvta 		= movxnvta.cia_mnvta 
				AND	nota_vta.pla_nvta 		= movxnvta.pla_mnvta 
				AND	nota_vta.fol_nvta 		= movxnvta.fol_mnvta
				AND	nota_vta.vuelta_nvta 	= movxnvta.vuelta_mnvta)
				AND	empxrutp.chf_erup 		= chofer.cve_emp
				AND empxrutp.ay1_erup 		= ayuda1.cve_emp
				AND empxrutp.ay2_erup 		= ayuda2.cve_emp
				AND empxrutp.cia_erup 		= planta.cia_pla
				AND	empxrutp.pla_erup 		= planta.cve_pla		
				AND	empxrutp.cia_erup 		= paramCia
				AND	empxrutp.pla_erup 		= paramPla
				AND	empxrutp.rut_erup 		= paramRoute
				AND	empxrutp.fliq_erup 		= paramFolio
		ORDER BY movxnvta.bst_mnvta
		RETURN  fliq,
				rut,
				uni,	
				fec, 	
				chf,	
				ay1,	
				ay2, 	
				lin,
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
				nnv, 	
				fyh,	
				hini,	
				hfin,	
				nump, 	
				numc,	
				numtqe, 	
				nom,
				tip,
				tlts, 	
				tprd, 	
				pru, 
				simpt,
				iva,	
				impt, 	
				bst,
				dir, 	
				fol, 
				folf,	
				cia,
				cvepla, 	
				pla, 	
				tpa,
				lfi,
				vimpasin,
				vimpasie,
				vimpasic,
				vimpasitot,
				vtltsotr,
				vimpotr,
				vimpasio
		WITH RESUME;	
	END FOREACH;

END PROCEDURE;       

SELECT	empxrutp.fliq_erup, 
		empxrutp.rut_erup, 
		empxrutp.uni_erup, 
		empxrutp.fec_erup, 
		'(' || chofer.cve_emp || ') ' || TRIM(chofer.ape_emp) || ' ' || TRIM(chofer.nom_emp),
		'(' || ayuda1.cve_emp || ') ' || TRIM(ayuda1.ape_emp) || ' ' || TRIM(ayuda1.nom_emp),
		'(' || ayuda2.cve_emp || ') ' || TRIM(ayuda2.ape_emp) || ' ' || TRIM(ayuda2.nom_emp), 
		empxrutp.lin_erup, 
		empxrutp.ldi_erup, 
		empxrutp.pin_erup,
		empxrutp.pfi_erup, 
		empxrutp.pdi_erup, 
		empxrutp.tot_erup, 
		empxrutp.imp_erup, 
		empxrutp.lcre_erup,
		empxrutp.vcre_erup, 
		empxrutp.lefe_erup, 
		empxrutp.vefe_erup, 
		empxrutp.lpar_erup, 
		empxrutp.nnv_erup,
		empxrutp.fyh_erup, 
		empxrutp.hini_erup, 
		empxrutp.hfin_erup, 
		nota_vta.ped_nvta, 
		nota_vta.numcte_nvta, 
		nota_vta.numtqe_nvta, 
		case when trim(cliente.razsoc_cte) <> '' then trim(cliente.razsoc_cte) 
	    else case when cliente.ali_cte <> '' then trim(cliente.ali_cte) || ', '
	    else '' end || trim(cliente.nom_cte) || ' ' || trim(cliente.ape_cte) 
	    end AS ncom_cte, 
	    nota_vta.tip_nvta, 
	    nota_vta.tlts_nvta, 
	    nota_vta.tprd_nvta, 
	    nota_vta.pru_nvta,
	    nota_vta.simp_nvta,
	    nota_vta.iva_nvta,			
		nota_vta.impt_nvta, 
	    movxnvta.bst_mnvta, 
	    (TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe)) As dir_tqe,
	    nota_vta.fol_nvta,
	    nota_vta.ffis_nvta,  
	    empxrutp.cia_erup, 
	    nota_vta.pla_nvta,
	    planta.cve_pla || ' ' ||  planta.nom_pla, 		 
		nota_vta.tpa_nvta, 
	    empxrutp.lfi_erup,
	    NVL(nota_vta.impasi_nvta,0), 
	    NVL(empxrutp.impase_erup,0),		
	    NVL(empxrutp.impasc_erup,0),		
	    NVL(empxrutp.impasi_erup,0)	
FROM	empxrutp, 			  
		nota_vta, 
	    cliente, 
	    tanque, 
	    planta,
	    empleado chofer,
OUTER  	movxnvta,
OUTER	empleado ayuda1,
OUTER	empleado ayuda2
WHERE	(empxrutp.cia_erup 			= nota_vta.cia_nvta 
		AND	empxrutp.fliq_erup 		= nota_vta.fliq_nvta 
		AND	empxrutp.rut_erup 		= nota_vta.ruta_nvta)
		AND	(nota_vta.cia_nvta 		= cliente.cia_cte 
		AND	nota_vta.numcte_nvta	= cliente.num_cte)
		AND	(nota_vta.cia_nvta 		= tanque.cia_tqe 
		AND	nota_vta.numcte_nvta	= tanque.numcte_tqe 
		AND	nota_vta.numtqe_nvta	= tanque.numtqe_tqe)
		AND	(nota_vta.cia_nvta 		= movxnvta.cia_mnvta 
		AND	nota_vta.pla_nvta 		= movxnvta.pla_mnvta 
		AND	nota_vta.fol_nvta 		= movxnvta.fol_mnvta)
		AND	empxrutp.chf_erup 		= chofer.cve_emp
		AND empxrutp.ay1_erup 		= ayuda1.cve_emp
		AND empxrutp.ay2_erup 		= ayuda2.cve_emp
		AND empxrutp.cia_erup 		= planta.cia_pla
		AND	empxrutp.pla_erup 		= planta.cve_pla		
		AND	empxrutp.cia_erup 		= '15'
		AND	empxrutp.pla_erup 		= '02'
		AND	empxrutp.rut_erup 		= 'M006'
		AND	empxrutp.fliq_erup 		= 8568
ORDER BY movxnvta.bst_mnvta