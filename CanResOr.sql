DROP PROCEDURE CanResOr;
EXECUTE PROCEDURE CanResOr('15', '41', '03', 'SURTIO CON LA COMPETENCIA', '1541596380', 'fuente')
EXECUTE PROCEDURE CanResOr('15', '01', '03', 'SURTIO CON LA COMPETENCIA', '1501960622', 'fuente')

CREATE PROCEDURE CanResOr
(
	paramCia		CHAR(2),	
	paramPla		CHAR(2),	
	paramTca		CHAR(2),  	
	paramMot		CHAR(50),	
	paramFolio		CHAR(12),	
	paramUsr		CHAR(8)		
)

	RETURNING	
		SMALLINT;		

	DEFINE edited   SMALLINT;	
		
	DEFINE nvta		INT;						
	DEFINE ped 		INT;
	DEFINE edo		CHAR(1);					
	DEFINE curDate	DATE;					
	DEFINE curHour	DATETIME hour to minute;	
	DEFINE vedoreg	CHAR(1);	
	DEFINE vvuelta  SMALLINT;	
	DEFINE vtpdo	CHAR(1);	
	DEFINE vtpa		CHAR(1);						

    SELECT	edoreg_enr, NVL(vuelta_enr,0)
	INTO	vedoreg, vvuelta
	FROM	enruta
	WHERE	fol_enr = paramFolio;
	
	SELECT	fol_nvta,
			ped_nvta,
			edo_nvta,
			tpdo_nvta,
			tpa_nvta
	INTO	nvta,
			ped,
			edo,
			vtpdo,
			vtpa
	FROM	nota_vta
	WHERE	cia_nvta = paramCia
	AND		pla_nvta = paramPla
	AND		fol_nvta = (paramFolio[5, 10] * 1)
	AND 	vuelta_nvta = vvuelta;	
	
	IF edo = 'P' AND vedoreg <> 'F' AND vedoreg <> 'f' AND ((vtpdo <> 'W' AND vtpdo <> 'A') OR 
			(vtpa NOT IN('R','B') AND (vtpdo = 'W' OR vtpdo = 'A')))  THEN 
	
		SELECT 	DBINFO('utc_to_datetime',sh_curtime) AS CurrentDate, 
	   			DBINFO('utc_to_datetime',sh_curtime) AS CurrentHour
	   	INTO	curDate,
	   			curHour  
		FROM 	sysmaster:'informix'.sysshmvals;

		UPDATE	pedidos
		SET     tmcan_ped = paramTca,
				motcan_ped = paramMot,
				fecrsur_ped = curDate,
				horrsur_ped = curHour,
				edo_ped = 'C',
				usrcan_ped = paramUsr
		WHERE	num_ped = ped;

		UPDATE 	nota_vta
		SET 	edo_nvta = 'C'
		WHERE	fol_nvta = nvta
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla
		AND 	vuelta_nvta = vvuelta;

		UPDATE	enruta
		SET     edoreg_enr = 'C',
				edovta_enr = 'f',
				obser_enr = TRIM(paramTca) || ' ' || TRIM(paramMot)
		WHERE   fol_enr = paramFolio;
		
		LET edited = 1;
		
	ELSE	
		LET edited = 0;	
	END IF;
	
	RETURN edited;

END PROCEDURE; 

select	*
from	nota_vta
where	tpdo_nvta IN('L') and edo_nvta = 'P' and tpa_nvta in('B','R')

select	*
from	nota_vta
where	fol_nvta = 596380

select	*
from	pedidos
where	num_ped = 2921890

select	*
from	enruta
where	fol_enr = '1541596380'