CREATE PROCEDURE QryDash
(
	paramCia		CHAR(2),	
	paramPla		CHAR(2),	
	paramFecha		DATE    	
)

RETURNING
	CHAR(6),			
	CHAR(4),		
	SMALLINT,		
	SMALLINT,		
	SMALLINT,		
	SMALLINT,		
	SMALLINT,		
	SMALLINT,		
	DECIMAL,		
	DECIMAL,		
	CHAR(8);		
	
DEFINE eco		CHAR(6);	
DEFINE ruta 	CHAR(4); 	
DEFINE pedTot   SMALLINT;	
DEFINE surtidos SMALLINT;	
DEFINE pedCalle SMALLINT;	
DEFINE pedPend  SMALLINT;	
DEFINE pedCan	SMALLINT;	
DEFINE pedRep	SMALLINT;	
DEFINE totLts	DECIMAL;	
DEFINE totPes  	DECIMAL;	
DEFINE ultSur	CHAR(8);	

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
	ORDER BY rut_crut
	
	FOREACH cCursorDef FOR
	
		SELECT  eco_enr,					
				COUNT(eco_enr) AS PedTotales,  
				SUM(CASE 
						WHEN edoreg_enr IN  ('F', 'f') THEN 
							1
						ELSE
							0
						END
					) AS Surtidos,
				SUM(CASE
						WHEN edoreg_enr IN ('N') THEN
							1
						ELSE
							0
						END
					) AS Calle,
				SUM(CASE
						WHEN edoreg_enr IN ('P') THEN
							1
						ELSE
							0
						END
					) AS Pendientes,
				SUM(CASE
						WHEN edoreg_enr IN ('C') THEN
							1
						ELSE
							0
						END
					)AS Cancelados,
				SUM(CASE
						WHEN edoreg_enr IN ('O') THEN
							1
						ELSE
							0
						END
					)AS Reprogramados,
				SUM(ltssur_enr * 1) AS totLitros,
				SUM(totvta_enr * 1) AS totVenta,
				MAX(SUBSTR(fecate_enr, 9, 8)) AS UltSurt
		INTO	eco,								
				pedTot,
				surtidos,
				pedCalle,
				pedPend,
				pedCan,
				pedRep,
				totLts,
				totPes,
				ultSur
		FROM	enruta
		WHERE   fecreg_enr = TO_CHAR(paramFecha, '%d%m%y')
		AND    (ruta_enr = rutaInt
		OR		eco_enr = ecoInt)
		AND    (fecate_enr >= fhiInt
		AND     fecate_enr <= fhfInt
		OR		fecate_enr = ''
		OR		fecate_enr IS NULL)
		GROUP BY eco_enr
		RETURN	eco,
				rutaInt,					
				pedTot,
				surtidos,
				pedCalle,
				pedPend,
				pedCan,
				pedRep,
				totLts,
				totPes,
				ultSur
		WITH RESUME;
	
	END FOREACH; 

END FOREACH; 

END PROCEDURE; 
