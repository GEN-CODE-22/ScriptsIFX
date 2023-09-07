CREATE PROCEDURE QryUnitDet(
	paramCve	CHAR(7),
	paramStatus CHAR(1)
	)
	
	RETURNING
		CHAR(7),			
		CHAR(10),			
		CHAR(2),			
		CHAR(2),			
		CHAR(1),			
		DECIMAL,			
		CHAR(1),			
		DATE,				
		DATE,				
		CHAR(1),			
		CHAR(20);			

	DEFINE cve 	CHAR(7);	
	DEFINE plc  CHAR(10);	
	DEFINE cia 	CHAR(2);	
	DEFINE pla  CHAR(2);	
	DEFINE tip 	CHAR(1);	
	DEFINE cap  DECIMAL;	
	DEFINE edo  CHAR(1);	
	DEFINE falt DATE;		
	DEFINE fbaj DATE;		
	DEFINE tcom CHAR(1);	
	DEFINE mode CHAR(20);	

	
	FOREACH consorcanc FOR
	
		SELECT	cve_uni,
				plc_uni,
				cia_uni,
				pla_uni,
				tip_uni,
				cap_uni,
				edo_uni,
				falt_uni,
				fbaj_uni,
				tcom_uni,
				mode_uni
		INTO	cve,
				plc,
				cia,
				pla,
				tip,
				cap,
				edo,
				falt,
				fbaj,
				tcom,
				mode
		FROM 	unidad
		WHERE	cve_uni = paramCve
		AND		edo_uni = paramStatus
		RETURN	cve,
				plc,
				cia,
				pla,
				tip,
				cap,
				edo,
				falt,
				fbaj,
				tcom,
				mode
		WITH RESUME;	
	END FOREACH;

END PROCEDURE;						