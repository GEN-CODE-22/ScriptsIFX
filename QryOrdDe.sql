CREATE PROCEDURE QryOrdDe
(
	paramCia		CHAR(2),	
	paramPla		CHAR(2),	
	paramFecha		DATE,    	
	paramRoute		CHAR(4)		
)


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
	SMALLINT;		
	
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


DEFINE ecoInt	CHAR(6);					
DEFINE rutaInt  CHAR(4);					
DEFINE fhiInt 	CHAR(14);					
DEFINE fhfInt	CHAR(14);				

FOREACH cEcoRuta FOR 

	SELECT	rut_crut,
			eco_crut,
			TO_CHAR(fec_crut, '%Y%m%d') || ' ' || TO_CHAR(hoi_crut, '%H:%M') AS fhi,
			(CASE
				WHEN TO_CHAR(hof_crut, '%H:%M') = '00:00' THEN
					TO_CHAR(fec_crut, '%Y%m%d') || ' 23:59'
				ELSE
					TO_CHAR(fec_crut, '%Y%m%d') || ' ' || TO_CHAR(hof_crut, '%H:%M')
				END
			) AS fhf
	INTO	rutaInt,
			ecoInt,
			fhiInt,
			fhfInt			
	FROM	corte_rut
	WHERE	fec_crut = paramFecha
	AND		sta_crut IN ('C', 'A')
	AND		rut_crut = paramRoute
	ORDER BY rut_crut
	
	FOREACH cCursorDef FOR
	
		SELECT  fol_enr,
				numcte_enr,
				nom_enr,
				dir_enr,
				rfc_enr,
				fecreg_enr,
				prc_enr,
				eco_enr,
				ruta_enr,
				edovta_enr,
				ltssur_enr,
				ubicte_enr,
				fecate_enr,
				edoreg_enr,
				totvta_enr,
				obser_enr,				
				tippgo_enr,
				com_enr,
				golpe_enr			
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
				golpe
		FROM	enruta
		WHERE   fecreg_enr = TO_CHAR(paramFecha, '%d%m%y')
		AND    (ruta_enr = rutaInt
		OR		eco_enr = ecoInt)
		AND    (fecate_enr >= fhiInt
		AND     fecate_enr <= fhfInt
		OR		fecate_enr = ''
		OR		fecate_enr IS NULL)
		ORDER BY eco_enr, edoreg_enr, golpe_enr
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
				golpe
		WITH RESUME;
	
	END FOREACH; 	

END FOREACH; 

END PROCEDURE;