DROP PROCEDURE cxc_rptcartgenuso;
EXECUTE PROCEDURE cxc_rptcartgenuso('','2022-08-31','','');
EXECUTE PROCEDURE cxc_rptcartgenuso('C','2022-07-13','15','13');
EXECUTE PROCEDURE cxc_rptcartgenuso('C','2022-07-13','15','79');
EXECUTE PROCEDURE cxc_rptcartgenuso('C','2022-07-21','','');
EXECUTE PROCEDURE cxc_rptcartgenuso('C','21/07/22','','');

CREATE PROCEDURE cxc_rptcartgenuso
(
	paramTpa		CHAR(1),
	paramFecha   	DATE,
	paramCia		CHAR(2),
	paramPla		CHAR(18)
)
RETURNING  
 CHAR(2),   -- Uso
 DECIMAL,	-- Saldo
 DECIMAL,	-- Saldo 0-30 dias
 DECIMAL,	-- Saldo 31-60 dias
 DECIMAL,	-- Saldo 61-90 dias
 DECIMAL,	-- Saldo 91-180 dias
 DECIMAL;	-- Saldo +180 dias


DEFINE vuso 	CHAR(2);
DEFINE vsaldo 	DECIMAL;
DEFINE vsaldo0 	DECIMAL;
DEFINE vsaldo30	DECIMAL;
DEFINE vsaldo60	DECIMAL;
DEFINE vsaldo90	DECIMAL;
DEFINE vsaldo180	DECIMAL;
DEFINE vpla1 	CHAR(2);
DEFINE vpla2 	CHAR(2);
DEFINE vpla3 	CHAR(2);
DEFINE vpla4 	CHAR(2);
DEFINE vpla5 	CHAR(2);
DEFINE vpla6 	CHAR(2);
DEFINE vpla7 	CHAR(2);
DEFINE vpla8 	CHAR(2);
DEFINE vpla9 	CHAR(2);

LET vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9 = get_plantas(paramPla);

LET vsaldo = 0;
LET vsaldo0 = 0;
LET vsaldo30 = 0;
LET vsaldo60 = 0;
LET vsaldo90 = 0;
LET vsaldo180 = 0;

IF paramTpa <> '' THEN
	IF	paramCia <> '' AND paramPla <> '' THEN
		FOREACH cUsos FOR
			SELECT uso_doc
			INTO   vuso
			FROM  doctos
			WHERE cia_doc = paramCia
				AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)
				AND tpa_doc = paramTpa
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )        
			  GROUP BY 1

			  LET vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_rptcartuso(paramTpa,paramFecha,paramCia,paramPla,vuso);           
			  
			  RETURN 	vuso,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
			  WITH RESUME;
		END FOREACH;   
	ELSE
		FOREACH cUsos FOR
			SELECT uso_doc
			INTO   vuso
			FROM  doctos
			WHERE tpa_doc = paramTpa
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )        
			  GROUP BY 1

			  LET vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_rptcartuso(paramTpa,paramFecha,paramCia,paramPla,vuso);           
			  
			  RETURN 	vuso,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
			  WITH RESUME;
		END FOREACH; 
	END IF;
ELSE
	IF	paramCia <> '' AND paramPla <> '' THEN
		FOREACH cUsos FOR
			SELECT uso_doc
			INTO   vuso
			FROM  doctos
			WHERE cia_doc = paramCia
				AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)				
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )        
			  GROUP BY 1

			  LET vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_rptcartuso(paramTpa,paramFecha,paramCia,paramPla,vuso);           
			  
			  RETURN 	vuso,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
			  WITH RESUME;
		END FOREACH;   
	ELSE
		FOREACH cUsos FOR
			SELECT uso_doc
			INTO   vuso
			FROM  doctos
			WHERE sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )        
			  GROUP BY 1

			  LET vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_rptcartuso(paramTpa,paramFecha,paramCia,paramPla,vuso);           
			  
			  RETURN 	vuso,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
			  WITH RESUME;
		END FOREACH; 
	END IF;
END IF;

END PROCEDURE;

SELECT uso_doc
FROM  doctos
WHERE sta_doc = 'A' 
    AND (sal_doc <> 0.0 
    AND fult_doc <= '2022-08-31'
    OR  fult_doc  > '2022-08-31' 
    AND femi_doc <= '2022-08-31' )        
  GROUP BY 1


SELECT *
      FROM doctos 
      WHERE cte_doc MATCHES '007232'
      order by femi_doc desc