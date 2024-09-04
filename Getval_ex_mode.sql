DROP PROCEDURE GETVAL_EX_MODE;
EXECUTE PROCEDURE GETVAL_EX_MODE('15','09','','folfceg_pla');

select * from planta
update planta
set 	folfceg_pla = null 
where  cve_pla = '09'
CREATE PROCEDURE GETVAL_EX_MODE(
				paramCia   CHAR(2),
                paramPla   CHAR(2),
				paramRut   CHAR(4),
				paramValue CHAR(15)
                )

RETURNING 
        INTEGER; 

DEFINE valueReturn INTEGER; 
DEFINE valueVuelta INTEGER; 
DEFINE valueActual INTEGER; 

LET valueReturn=0;
LET valueVuelta=0;
LET valueActual=0;

IF paramValue=="numped_dat" THEN
	LOCK TABLE datos IN EXCLUSIVE MODE;
						
	SELECT numped_dat
	INTO   valueReturn
	FROM   datos;
					
	LET valueReturn = valueReturn + 1;
					
	UPDATE      datos
	SET         numped_dat = valueReturn;
				
	UNLOCK TABLE datos;
	
	RETURN valueReturn;
	
END IF;

IF paramValue=="numcte_dat" THEN

	LOCK TABLE datos IN EXCLUSIVE MODE;
						
	SELECT numcte_dat
	INTO   valueReturn
	FROM   datos;
					
	LET valueReturn = valueReturn + 1;
					
	UPDATE      datos
	SET         numcte_dat = valueReturn;
				
	UNLOCK TABLE datos;

	RETURN valueReturn;
END IF;

IF paramValue=="numlchq_dat" THEN

	LOCK TABLE datos IN EXCLUSIVE MODE;
						
	SELECT numlchq_dat
	INTO   valueReturn
	FROM   datos;
					
	LET valueReturn = valueReturn + 1;
					
	UPDATE      datos
	SET         numlchq_dat = valueReturn;
				
	UNLOCK TABLE datos;

	RETURN valueReturn;
END IF;

IF paramValue=="numlcob_dat" THEN
	
	LOCK TABLE datos IN EXCLUSIVE MODE;
						
	SELECT numlcob_dat
	INTO   valueActual
	FROM   datos;
					
	LET valueReturn = valueActual + 1;
					
	UPDATE      datos
	SET         numlcob_dat = valueReturn;
				
	UNLOCK TABLE datos;

	RETURN valueActual;
END IF;

IF paramValue=="folfug_dat" THEN
	
	LOCK TABLE datos IN EXCLUSIVE MODE;
						
	SELECT folfug_dat
	INTO   valueReturn
	FROM   datos;
					
	LET valueReturn = valueReturn + 1;
					
	UPDATE      datos
	SET         folfug_dat = valueReturn;
				
	UNLOCK TABLE datos;
	
	RETURN valueReturn;

END IF;

IF paramValue=="folqja_dat" THEN
	
	LOCK TABLE datos IN EXCLUSIVE MODE;
						
	SELECT folqja_dat
	INTO   valueReturn
	FROM   datos;
					
	LET valueReturn = valueReturn + 1;
					
	UPDATE      datos
	SET         folqja_dat = valueReturn;
				
	UNLOCK TABLE datos;

	RETURN valueReturn;

END IF;

IF paramValue=="fnvta_pla" THEN
	
	LOCK TABLE planta IN EXCLUSIVE MODE;
	SELECT fnvta_pla, vuelta_pla
	INTO   valueReturn, valueVuelta
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

		IF valueReturn IS NOT NULL AND valueReturn > 0 THEN
					IF valueReturn >= 999999 THEN
						LET valueReturn = 2501;
						LET valueVuelta = valueVuelta + 1;
					ELSE
						LET valueReturn = valueReturn + 1;
					END IF;
		
			UPDATE  planta
			SET     fnvta_pla = valueReturn, vuelta_pla=valueVuelta
			WHERE   cia_pla = paramCia
			   AND  cve_pla = paramPla;		  
			
		ELSE
			LET valueReturn = 0;
		END IF;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="folfac_pla" THEN

	LOCK TABLE planta IN EXCLUSIVE MODE;
	
	SELECT folfac_pla 
	INTO   valueReturn 
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

	LET valueReturn = valueReturn + 1;

	UPDATE  planta
	SET     folfac_pla = valueReturn
	WHERE   cia_pla = paramCia
	   AND cve_pla = paramPla;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="folncd_pla" THEN

	LOCK TABLE planta IN EXCLUSIVE MODE;
	
	SELECT folncd_pla 
	INTO   valueReturn 
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

	LET valueReturn = valueReturn + 1;

	UPDATE  planta
	SET     folncd_pla = valueReturn
	WHERE   cia_pla = paramCia
	   AND cve_pla = paramPla;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="folfce_pla" THEN

	LOCK TABLE planta IN EXCLUSIVE MODE;
	
	SELECT folfce_pla 
	INTO   valueReturn 
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

	LET valueReturn = valueReturn + 1;

	UPDATE  planta
	SET     folfce_pla = valueReturn
	WHERE   cia_pla = paramCia
	   AND cve_pla = paramPla;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="folfceg_pla" THEN

	LOCK TABLE planta IN EXCLUSIVE MODE;
	
	SELECT NVL(folfceg_pla,0) 
	INTO   valueReturn 
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

	LET valueReturn = valueReturn + 1;

	UPDATE  planta
	SET     folfceg_pla = valueReturn
	WHERE   cia_pla = paramCia
	   AND cve_pla = paramPla;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="folfceo_pla" THEN

	LOCK TABLE planta IN EXCLUSIVE MODE;
	
	SELECT folfceo_pla 
	INTO   valueReturn 
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

	LET valueReturn = valueReturn + 1;

	UPDATE  planta
	SET     folfceo_pla = valueReturn
	WHERE   cia_pla = paramCia
	   AND cve_pla = paramPla;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="folcp_pla" THEN

	LOCK TABLE planta IN EXCLUSIVE MODE;
	
	SELECT folcp_pla 
	INTO   valueReturn 
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

	LET valueReturn = valueReturn + 1;

	UPDATE  planta
	SET     folcp_pla = valueReturn
	WHERE   cia_pla = paramCia
	   AND cve_pla = paramPla;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="folnce_pla" THEN
	
	LOCK TABLE planta IN EXCLUSIVE MODE;
	
	SELECT folnce_pla 
	INTO   valueReturn 
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

	LET valueReturn = valueReturn + 1;

	UPDATE  planta
	SET     folnce_pla = valueReturn
	WHERE   cia_pla = paramCia
	   AND cve_pla = paramPla;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="fliq_pla" THEN
	
	LOCK TABLE planta IN EXCLUSIVE MODE;
	
	SELECT fliq_pla 
	INTO   valueReturn 
	FROM   planta
	WHERE  cia_pla = paramCia 
	    AND cve_pla = paramPla;

	LET valueReturn = valueReturn + 1;

	UPDATE  planta
	SET     fliq_pla = valueReturn
	WHERE   cia_pla = paramCia	   AND cve_pla = paramPla;

	UNLOCK TABLE planta;
	
	RETURN valueReturn;

END IF;

IF paramValue=="fliq_rut" THEN
	
	LOCK TABLE ruta IN EXCLUSIVE MODE;
						
	SELECT  fliq_rut
	INTO     valueReturn
	FROM   ruta
	WHERE cve_rut=paramRut
	AND cia_rut=paramCia
	AND pla_rut=paramPla;
					
	LET valueReturn= valueReturn+ 1;
					
	UPDATE	ruta
	SET     fliq_rut= valueReturn
	WHERE cve_rut=paramRut
	AND cia_rut=paramCia
	AND pla_rut=paramPla;
				
	UNLOCK TABLE ruta;
	
	RETURN valueReturn;

END IF;

END PROCEDURE;       

select	*
from	datos

DROP PROCEDURE Prueba1;
EXECUTE PROCEDURE Prueba1('B');
CREATE PROCEDURE Prueba1(
				paramValue   CHAR(1)
                )

RETURNING 
        INTEGER,
        CHAR(2); 
        
DEFINE vvalue INT;
IF paramValue = 'A'	THEN
	LET vvalue = 1;
ELSE
	LET vvalue = 0;
END IF;

RETURN vvalue,'OK';
END PROCEDURE;  

EXECUTE PROCEDURE Prueba2('B');
DROP PROCEDURE Prueba2;
CREATE PROCEDURE Prueba2(
				paramValue   CHAR(1)
                )

RETURNING 
        CHAR(20); 
        
DEFINE vvalue CHAR(20);
DEFINE vok CHAR(2);
DEFINE vvalueI INT;
LET vvalueI,vok = Prueba1(paramValue);
IF vvalueI = 1 THEN
	LET vvalue = 'ES UNO' || vok;
ELSE
	LET vvalue = 'NO ES UNO' || vok;
END IF;

RETURN vvalue || vok;
END PROCEDURE;      