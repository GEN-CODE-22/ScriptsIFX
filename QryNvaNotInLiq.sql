EXECUTE PROCEDURE QryNvaNotInLiq('20221031','M077','QI-1396');
DROP PROCEDURE QryNvaNotInLiq;
CREATE PROCEDURE QryNvaNotInLiq
(
	paramFecate CHAR(8),
	paramRoute  CHAR(4),	
	paramEco	CHAR(7)
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
		CHAR(6),								
		CHAR(34),								
		CHAR(17),								
		CHAR(1),								
		CHAR(10),								
		CHAR(30),								
		CHAR(2),								
		SMALLINT,								
		CHAR(40),	
		INTEGER,
		CHAR(1),					
		DECIMAL,
		CHAR(1);								
		
	
	DEFINE fol		CHAR(12);					
	DEFINE numcte 	CHAR(6);					
	DEFINE nom		CHAR(50);					
	DEFINE dir		CHAR(80);					
	DEFINE rfc		CHAR(13);					
	DEFINE fecreg	CHAR(6);					
	DEFINE prc		CHAR(6);					
	DEFINE eco		CHAR(7);					
	DEFINE ruta		CHAR(4);					
	DEFINE edovta	CHAR(1);					
	DEFINE ltssur	CHAR(6);					
	DEFINE ubicte	CHAR(34);					
	DEFINE fecate	CHAR(17);					
	DEFINE edoreg	CHAR(1);					
	DEFINE totvta	CHAR(10);				
	DEFINE obser	CHAR(30);					
	DEFINE faccal	CHAR(2);					
	DEFINE tippgo	SMALLINT;					
	DEFINE com		CHAR(40);					
	DEFINE golpe	INTEGER;	
	DEFINE vasiste	CHAR(1);
	DEFINE vimpasi	DECIMAL;
	DEFINE vtpdo	CHAR(1);
	DEFINE vvuelta	SMALLINT;							
	
	LET vtpdo = '';
	
	
FOREACH consorcanc FOR
	
		SELECT	fol_enr,
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
				faccal_enr,
				tippgo_enr,
				com_enr,
				golpe_enr,
				NVL(asiste_enr,'N'),
				NVL(impasi_enr,0),
				NVL(vuelta_enr,0)
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
				faccal,	
				tippgo,
				com,
				golpe,
				vasiste,
				vimpasi,
				vvuelta
		FROM	enruta
		WHERE	SUBSTR(fecate_enr,1,8) = paramFecate
				AND
				((ruta_enr = paramRoute
				AND	eco_enr	= paramEco)
				OR	(eco_enr = paramEco
				AND	ruta_enr IS NULL))
				AND	((edoreg_enr = 'F' 
				AND	edovta_enr = '0')
				OR	(edoreg_enr = 'N'
				AND	edovta_enr IS NULL))		
		ORDER BY fecate_enr
		IF LENGTH(fol) = 10 THEN
			
		SELECT	tpdo_nvta
			INTO	vtpdo
			FROM	nota_vta
			WHERE	cia_nvta = fol[1,2] and pla_nvta = fol[3,4] and fol_nvta = fol[5,10] and vuelta_nvta = vvuelta ;
		ELSE
			LET vtpdo = 'C';		
		END IF;
		
		RETURN  fol,
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
				faccal,	
				tippgo,
				com,
				golpe,
				vasiste,
				vimpasi,
				vtpdo
		WITH RESUME;	
	END FOREACH;

END PROCEDURE;  