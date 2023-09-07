CREATE PROCEDURE Qry_LiqCI
(
	paramCte	CHAR(6),	
	paramCia 	CHAR(2),
	paramPla 	CHAR(2),
	paramTip    CHAR(1),
	paramTpa	CHAR(1)
)
RETURNING
		CHAR(6);

	DEFINE veco  	CHAR(6);	
	LET veco = '';

	IF paramPla = '02' OR paramPla = '30' OR paramPla = "32" THEN		
		IF paramCte = "049728" OR paramCte = "072863" OR paramCte = "087179" OR paramCte = "125842" THEN
			SELECT	razsoc_cte[1,6]
			INTO	veco
			FROM	cliente
			WHERE	num_cte = paramCte;
		END IF;
	END IF;
	IF veco = '' THEN 
		IF paramTip = 'I' AND paramTpa = 'I' THEN
			SELECT	razsoc_cte[1,6]
			INTO	veco
			FROM	cliente
			WHERE	num_cte = paramCte;
		END IF;	
	END IF;
	
	RETURN	veco;
	
END PROCEDURE;