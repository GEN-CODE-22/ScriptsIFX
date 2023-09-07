CREATE PROCEDURE IChangeClientNote(
	paramCia		CHAR(2),
	paramPla		CHAR(2),
	paramFolOri		INTEGER,
	paramFolEOri	CHAR(12),	
	paramCteOri		CHAR(6),
	paramTqeOri		INTEGER,
	paramFolDes		INTEGER,
	paramFolEDes	CHAR(12),	
	paramCteDes		CHAR(6),
	paramTqeDes		INTEGER,
	paramUsr		CHAR(8)	
)


	RETURNING
		CHAR(1);		
			
	DEFINE control		CHAR(1);		
	
	DEFINE vpedori		INTEGER;		
	DEFINE vpeddes		INTEGER;		
	DEFINE vtipori		CHAR(1);		
	DEFINE vtipdes		CHAR(1);		
	DEFINE vtipvtaori	CHAR(1);		
	DEFINE vtipvtades	CHAR(1);		
	DEFINE vprodori		CHAR(3);		
	DEFINE vproddes		CHAR(3);		
	DEFINE vnomori		CHAR(50);		
	DEFINE vnomdes		CHAR(50);		
	DEFINE vdirori		CHAR(50);		
	DEFINE vdirdes		CHAR(50);		
	DEFINE vtpgoori		SMALLINT;		
	DEFINE vtpgodes		SMALLINT;		
	DEFINE vprcori		CHAR(6);		
	DEFINE vprcdes		CHAR(6);		
	DEFINE vrfcori		CHAR(13);		
	DEFINE vrfcdes		CHAR(13);		
	DEFINE vcfolnvta	CHAR(10);		
	DEFINE vfliq		INTEGER;		
	
	DEFINE vobserlog	CHAR(100);
	
	LET control = '';
	
	SELECT	fliq_nvta,
			ped_nvta,
			tip_nvta,
			tprd_nvta
	INTO	vfliq,
			vpedori,
			vtipvtaori,
			vprodori
	FROM	nota_vta
	WHERE	fol_nvta 		= paramFolOri
			AND cia_nvta	= paramCia
			AND pla_nvta	= paramPla;
			
	SELECT	tip_cte
	INTO	vtipori
	FROM	cliente
	WHERE	num_cte = paramCteOri;
			
	SELECT	ped_nvta,
			tip_nvta,
			tprd_nvta
	INTO	vpeddes,
			vtipvtades,
			vproddes
	FROM	nota_vta
	WHERE	fol_nvta 		= paramFolDes
			AND cia_nvta	= paramCia
			AND pla_nvta	= paramPla;
			
	SELECT	tip_cte
	INTO	vtipdes
	FROM	cliente
	WHERE	num_cte = paramCteDes;
	
	UPDATE	nota_vta	
	SET		numcte_nvta 	= paramCteDes,
			numtqe_nvta 	= paramTqeDes,
			ped_nvta		= vpeddes			
	WHERE	fol_nvta 		= paramFolOri
			AND cia_nvta	= paramCia
			AND pla_nvta	= paramPla;
	LET control = UpPaymntSaleNote(paramFolOri,paramCia,paramPla,paramCteDes,paramTqeDes,vfliq,vtipori,vtipvtaori,'FUENTE');
	LET vobserlog = 'CAMBIO CLIENTE EN NOTA DE VENTA CLIENTE ORIGINAL[' || paramCteOri || '] CLIENTE NUEVO[' || paramCteDes || ']';
	EXECUTE PROCEDURE InsChangeLiq(paramCia,paramPla,paramFolOri,paramUsr,vobserlog);
			
	UPDATE	nota_vta	
	SET		numcte_nvta 	= paramCteOri,
			numtqe_nvta 	= paramTqeOri,
			ped_nvta		= vpedori
	WHERE	fol_nvta 		= paramFolDes
			AND cia_nvta	= paramCia
			AND pla_nvta	= parampla;
	LET control = UpPaymntSaleNote(paramFolOri,paramCia,paramPla,paramCteDes,paramTqeDes,vfliq,vtipdes,vtipvtades,'FUENTE');
	LET vobserlog = 'CAMBIO CLIENTE EN NOTA DE VENTA CLIENTE ORIGINAL[' || paramCteDes || '] CLIENTE NUEVO[' || paramCteOri || ']';
	EXECUTE PROCEDURE InsChangeLiq(paramCia,paramPla,paramFolOri,paramUsr,vobserlog);
	
  	SELECT	nom_enr,
  			dir_enr,
  			prc_enr,
  			tippgo_enr,
  			rfc_enr  		
  	INTO	vnomori,
  			vdirori,
  			vprcori,
  			vtpgoori,
  			vrfcori
  	FROM	enruta
  	WHERE	fol_enr = paramFolEOri;
  	
  	SELECT	nom_enr,
  			dir_enr,
  			prc_enr,
  			tippgo_enr,
  			rfc_enr 		
  	INTO	vnomdes,
  			vdirdes,
  			vprcdes,
  			vtpgodes,
  			vrfcdes
  	FROM	enruta
  	WHERE	fol_enr = paramFolEDes;
  	
  	UPDATE	enruta
  	SET		nom_enr 	= vnomdes,
  			dir_enr 	= vdirdes,
  			prc_enr 	= vprcdes,
  			tippgo_enr	= vtpgodes,
  			rfc_enr		= vrfcdes
  	WHERE	fol_enr = paramFolEOri;
  	
  	UPDATE	enruta
  	SET		nom_enr 	= vnomori,
  			dir_enr 	= vdirori,
  			prc_enr 	= vprcori,
  			tippgo_enr	= vtpgoori,
  			rfc_enr		= vrfcori
  	WHERE	fol_enr = paramFolEDes;
  	
	EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,paramCteOri,paramTqeOri);
	
	EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,paramCteDes,paramTqeDes);
	
	LET control = 'A';	  

	RETURN	control;

END PROCEDURE;	