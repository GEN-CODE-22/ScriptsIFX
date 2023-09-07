CREATE PROCEDURE QryEnrV(
	paramCia	char(2),
	paramPla	char(2),
	paramDate	char(6),
	paramFolio	char(250),
	paramCust	char(250),	
	paramRuta	char(4),
	paramEco	char(250),
	paramStat	char(1))

RETURNING
	CHAR(12),					
	CHAR(6),					
	CHAR(50),					
	CHAR(80),				
	CHAR(13),				
	CHAR(6),				
	CHAR(6),				
	CHAR(7),				
	CHAR(4),				
	CHAR(1),				
	SMALLINT,				
	CHAR(34),				
	CHAR(17),				
	CHAR(1),				
	CHAR(10),				
	CHAR(30),				
	SMALLINT,				
	CHAR(40),				
	SMALLINT,				
	INT,					
	DATETIME YEAR TO MINUTE;	
	
DEFINE fol		CHAR(12);					
DEFINE numcte 	CHAR(6); 					
DEFINE nom   	CHAR(50);					
DEFINE dir 		CHAR(80);					
DEFINE rfc 		CHAR(13);				
DEFINE fecreg  	CHAR(6);				
DEFINE prc		CHAR(6);				
DEFINE eco		CHAR(7);				
DEFINE ruta		CHAR(4);					
DEFINE edovta  	CHAR(1);				
DEFINE ltssur	SMALLINT;				
DEFINE ubicte	CHAR(34);				
DEFINE fecate	CHAR(17);				
DEFINE edoreg	CHAR(1);				
DEFINE totvta	CHAR(10);				
DEFINE obser	CHAR(30);				
DEFINE tippgo	SMALLINT;				
DEFINE com		CHAR(40);				
DEFINE golpe	SMALLINT;					
DEFINE ped		INT;						
DEFINE fhr		DATETIME YEAR TO MINUTE; 	

	FOREACH cCursorDef FOR
	
		SELECT  a.fol_enr,
				a.numcte_enr,
				a.nom_enr,
				a.dir_enr,
				a.rfc_enr,
				a.fecreg_enr,
				a.prc_enr,
				a.eco_enr,
				a.ruta_enr,
				a.edovta_enr,
				a.ltssur_enr,
				a.ubicte_enr,
				a.fecate_enr,
				a.edoreg_enr,
				a.totvta_enr,
				a.obser_enr,				
				a.tippgo_enr,
				a.com_enr,
				a.golpe_enr,
				c.num_ped,
				c.fhr_ped
		INTO	fol,
				numcte,
				nom,
				dir,
				rfc,
				fecreg,
				prc,
				eco,
				ruta,
				edovta,
				ltssur,
				ubicte,
				fecate,
				edoreg,
				totvta,
				obser,				
				tippgo,
				com,
				golpe,
				ped,
				fhr
		FROM	enruta a,
				nota_vta b,
				pedidos c
		WHERE   substr(a.fol_enr,5,6) = b.fol_nvta
		AND		b.ped_nvta = c.num_ped
		AND		(a.fecreg_enr = paramDate
		OR		 paramDate = '')
		AND		(a.fol_enr IN (paramFolio) 
		OR		 paramFolio = '')
		AND		(a.numcte_enr IN (paramCust)
		OR		 paramCust = '')
		AND		(a.ruta_enr = paramRuta
		OR		 paramRuta = '')
		AND	    (a.eco_enr = paramEco
		OR		 paramEco = '')
		AND		(a.edoreg_enr = paramStat
		OR		 paramStat = '')
		AND      b.cia_nvta = paramCia
		AND		 b.pla_nvta = paramPla
		AND 	 (a.edoreg_enr <> 'F' AND a.edoreg_enr <> 'N')
		ORDER BY a.eco_enr, a.edoreg_enr, a.golpe_enr
		RETURN	fol,
				numcte,
				nom,
				dir,
				rfc,
				fecreg,
				prc,
				eco,
				ruta,
				edovta,
				ltssur,
				ubicte,
				fecate,
				edoreg,
				totvta,
				obser,				
				tippgo,
				com,
				golpe,
				ped,
				fhr
		WITH RESUME;	
	END FOREACH;
END PROCEDURE;