CREATE PROCEDURE DelPedEn 
(
	paramFolio		INT,		
	paramCia		CHAR(2),	
	paramPla		CHAR(2),	
	paramTca		CHAR(2),	
	paramMot		CHAR(50),	
	paramUsr		CHAR(8)		
)

RETURNING 
	INT;			

DEFINE edo			CHAR(1);					
DEFINE fol          CHAR(10);  					
DEFINE ped  		INT;						
DEFINE curDate		DATE;						
DEFINE curHour		DATETIME hour to minute;	

DEFINE updatedRows	INT;						

	SELECT	edo_nvta, 
			ped_nvta
	INTO	edo, 
			ped
	FROM	nota_vta
	WHERE	fol_nvta = paramFolio
	AND		cia_nvta = paramCia
	AND		pla_nvta = paramPla;

	IF edo = "P" THEN

		SELECT 	DBINFO('utc_to_datetime',sh_curtime) AS CurrentDate, 
	   			DBINFO('utc_to_datetime',sh_curtime) AS CurrentHour
	   	INTO	curDate,
	   			curHour  
		FROM 	sysmaster:'informix'.sysshmvals;

		UPDATE	edo_nvta
		SET		edo_nvta = 'C'
		WHERE   fol_nvta = paramFolio
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla;

		LET fol = paramCia || paramPla || paramFolio;

		UPDATE  enruta
		SET     edoreg_enr = 'C'
		WHERE   fol_enr  = fol;

		UPDATE	pedidos
		SET     edo_ped = 'C',
				motcan_ped = paramMot,
				tmcan_ped = paramTca,
				fecrsur_ped = curDate,
				horrsur_ped = curHour,
				usrcan_ped = paramUsr
		WHERE	num_ped = ped;

		LET updatedRows = 1;

	ELSE

		LET updatedRows = 0;

	END IF;	

END PROCEDURE;