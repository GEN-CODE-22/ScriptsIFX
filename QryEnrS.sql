DROP PROCEDURE QryEnrS;
EXECUTE PROCEDURE QryEnrS('15','02','2022-04-09','O');
CREATE PROCEDURE QryEnrS
(
	paramCia		CHAR(2),	
	paramPla		CHAR(2),	
	paramFecha		DATE,    	
	paramEdo		CHAR(1)		
)

RETURNING
	CHAR(12),		
	CHAR(6),		
	CHAR(50),		
	CHAR(80),		
	CHAR(13),		
	CHAR(6),		
	CHAR(6),		
	CHAR(6),		
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
	SMALLINT,		
	CHAR(1),		
	SMALLINT,
	SMALLINT;
	
	

DEFINE fol		CHAR(12);	
DEFINE numcte 	CHAR(6); 	
DEFINE nom   	CHAR(50);	
DEFINE dir 		CHAR(80);	
DEFINE rfc 		CHAR(13);	
DEFINE fecreg  	CHAR(6);	
DEFINE prc		CHAR(6);	
DEFINE eco		CHAR(6);	
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
DEFINE prgtqe	CHAR(1);	
DEFINE numtqe	SMALLINT;	
DEFINE folenr	INT;	
DEFINE diasca	SMALLINT;	
DEFINE diasom	SMALLINT;	
DEFINE vvuelta  SMALLINT;	

let prgtqe = 'N';
let numtqe = 1;
	
	FOREACH cCursorDef FOR
	
		SELECT  fol_enr,
				(fol_enr[5, 10] * 1),
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
				golpe_enr,
				vuelta_enr		
		INTO	fol,
				folenr,
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
				vvuelta
		FROM	enruta
		WHERE   fecreg_enr = TO_CHAR(paramFecha, '%d%m%y')
		AND		edoreg_enr = paramEdo	
		AND		edovta_enr <> 'f'
		AND     fol_enr[1,2] = paramCia
		AND 	fol_enr[3,4] = paramPla
		ORDER BY eco_enr, edoreg_enr, golpe_enr
		
		SELECT	nota_vta.numtqe_nvta,
				tanque.prg_tqe,
				tanque.diasca_tqe,
				tanque.diasom_tqe
		INTO	numtqe,
				prgtqe,
				diasca,
				diasom
		FROM	nota_vta,
				tanque
		WHERE	nota_vta.numtqe_nvta = tanque.numtqe_tqe
				AND nota_vta.numcte_nvta = tanque.numcte_tqe
				AND nota_vta.fol_nvta = folenr
				AND nota_vta.cia_nvta = paramCia
				AND nota_vta.pla_nvta = paramPla
				AND nota_vta.vuelta_nvta = vvuelta;
		
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
				numtqe,
				prgtqe,
				diasca,
				diasom
		WITH RESUME;
	
	END FOREACH; 

END PROCEDURE; 