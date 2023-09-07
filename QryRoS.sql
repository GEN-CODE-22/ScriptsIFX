CREATE PROCEDURE QryRoS(
	paramCia	char(2),
	paramPla	char(2),
	paramRuta	char(4))

RETURNING
	CHAR(2),					
	CHAR(2),					
	DATE,						
	INT,						
	CHAR(4),					
	CHAR(7),					
	CHAR(4),					
	CHAR(4),					
	CHAR(4),					
	DECIMAL,					
	DECIMAL,					
	DATETIME HOUR TO SECOND,	
	DECIMAL,					
	DATETIME HOUR TO SECOND,
	INT,						
	DECIMAL,					
	DECIMAL,					
	DECIMAL,					
	CHAR(1);

DEFINE cia		CHAR(2);		
DEFINE pla		CHAR(2);		
DEFINE fec		DATE;			
DEFINE con		INT;			
DEFINE rut 		CHAR(4); 		
DEFINE eco		CHAR(7);		
DEFINE emc  	CHAR(4);		
DEFINE ema	    CHAR(4);		
DEFINE ems		CHAR(4);		
DEFINE lei		DECIMAL;		
DEFINE pti		DECIMAL;		
DEFINE hoi		DATETIME HOUR TO SECOND; 
DEFINE ptf		DECIMAL;		
DEFINE hof 		DATETIME HOUR TO SECOND; 
DEFINE ton		INT;			
DEFINE tol	    DECIMAL;		
DEFINE vta 		DECIMAL;		
DEFINE cta		DECIMAL;		
DEFINE sta		CHAR(1);		

FOREACH cEcoRuta FOR 

	SELECT		cia_crut,
				pla_crut,
				fec_crut,
				con_crut,
				rut_crut,
				eco_crut,
				emc_crut,
				ema_crut,
				ems_crut,
				lei_crut,
				pti_crut,
				hoi_crut,
				ptf_crut,
				hof_crut,
				ton_crut,
				tol_crut,
				vta_crut,
				cta_crut,
				sta_crut
	INTO		cia,
				pla,
				fec,
				con,
				rut,
				eco,
				emc,
				ema,
				ems,
				lei,
				pti,
				hoi,
				ptf,
				hof,
				ton,
				tol,
				vta,
				cta,
				sta
	FROM		corte_rut
	WHERE		sta_crut = 'A'						
	AND			cia_crut = paramCia					
	AND			pla_crut = paramPla					
	AND			rut_crut = paramRuta				
	RETURN		cia,
				pla,
				fec,
				con,
				rut,
				eco,
				emc,
				ema,
				ems,
				lei,
				pti,
				hoi,
				ptf,
				hof,
				ton,
				tol,
				vta,
				cta,
				sta
	WITH RESUME;	
END FOREACH;
END PROCEDURE;