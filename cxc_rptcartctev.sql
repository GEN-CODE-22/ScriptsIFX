DROP PROCEDURE cxc_rptcartctev;
EXECUTE PROCEDURE cxc_rptcartctev('','2021-12-31','','','028327');

CREATE PROCEDURE cxc_rptcartctev
(
	paramTpa		CHAR(1),
	paramFecha   	DATE,
	paramCia		CHAR(2),
	paramPla		CHAR(18),
	paramCte		CHAR(6)	
)
RETURNING   
 DECIMAL,	-- Saldo
 DECIMAL,	-- Saldo sin vencer
 DECIMAL,	-- Saldo 1-30 dias
 DECIMAL,	-- Saldo 31-60 dias
 DECIMAL,	-- Saldo 61-90 dias
 DECIMAL,	-- Saldo 91-120 dias
 DECIMAL,	-- Saldo 121-150 dias
 DECIMAL,	-- Saldo 151-180 dias
 DECIMAL,	-- Saldo 181-210 dias
 DECIMAL,	-- Saldo 211-240 dias
 DECIMAL,	-- Saldo 241-270 dias
 DECIMAL;	-- Saldo +270 dias

DEFINE vcte 	CHAR(6);
DEFINE vtipdoc 	CHAR(2);
DEFINE vfolio   INT;
DEFINE vserie 	CHAR(4);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vtpa 	CHAR(1);
DEFINE vuso 	CHAR(2);
DEFINE vtipo 	CHAR(1);
DEFINE vcargo 	DECIMAL;
DEFINE vabono 	DECIMAL;
DEFINE vsaldo 	DECIMAL;
DEFINE vsaltot 	DECIMAL;
DEFINE vfven 	DATE;
DEFINE vfemi 	DATE;
DEFINE vfult 	DATE;
DEFINE vsaldosv DECIMAL;
DEFINE vsaldo0 DECIMAL;
DEFINE vsaldo30	DECIMAL;
DEFINE vsaldo60	DECIMAL;
DEFINE vsaldo90	DECIMAL;
DEFINE vsaldo120	DECIMAL;
DEFINE vsaldo150	DECIMAL;
DEFINE vsaldo180	DECIMAL;
DEFINE vsaldo210	DECIMAL;
DEFINE vsaldo240	DECIMAL;
DEFINE vsaldo270	DECIMAL;
DEFINE vsaltotsv 	DECIMAL;
DEFINE vsaltot0 	DECIMAL;
DEFINE vsaltot30	DECIMAL;
DEFINE vsaltot60	DECIMAL;
DEFINE vsaltot90	DECIMAL;
DEFINE vsaltot120	DECIMAL;
DEFINE vsaltot150	DECIMAL;
DEFINE vsaltot180	DECIMAL;
DEFINE vsaltot210	DECIMAL;
DEFINE vsaltot240	DECIMAL;
DEFINE vsaltot270	DECIMAL;
DEFINE vvuelta 		SMALLINT;
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

LET vcargo = 0;
LET vabono = 0;
LET vsaldo = 0;
LET vsaldosv = 0;
LET vsaldo0 = 0;
LET vsaldo30 = 0;
LET vsaldo60 = 0;
LET vsaldo90 = 0;
LET vsaldo120 = 0;
LET vsaldo150 = 0;
LET vsaldo180 = 0;
LET vsaldo210 = 0;
LET vsaldo240 = 0;
LET vsaldo270 = 0;
LET vsaltotsv = 0;
LET vsaltot = 0;
LET vsaltot0 = 0;
LET vsaltot30 = 0;
LET vsaltot60 = 0;
LET vsaltot90 = 0;
LET vsaltot120 = 0;
LET vsaltot150 = 0;
LET vsaltot180 = 0;
LET vsaltot210 = 0;
LET vsaltot240 = 0;
LET vsaltot270 = 0;

IF paramTpa <> '' THEN
	IF	paramCia <> '' AND paramPla <> '' THEN
		FOREACH cDocumentos FOR
			SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
		          tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
		          MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
		    INTO	vcte,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vuso,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
		    FROM doctos
		    WHERE cte_doc = paramCte
		        AND cia_doc = paramCia
		        AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)
		        AND tpa_doc = paramTpa
		        AND sta_doc = 'A' 
		        AND (sal_doc <> 0.0 
		        AND fult_doc <= paramFecha
		        OR  fult_doc  > paramFecha 
		        AND femi_doc <= paramFecha )
		        AND ffac_doc IS NOT NULL
		      GROUP BY 1,2,3,4,5,6,7,8,9,16
		   UNION
		   SELECT cte_doc,tip_doc,fol_doc,ser_doc,cia_doc,pla_doc,
		          tpa_doc,uso_doc,vuelta_doc,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
		          MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'N'
		      FROM doctos
		      WHERE cte_doc = paramCte
		        AND cia_doc = paramCia
		        AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)
		        AND tpa_doc = paramTpa
		        AND sta_doc = 'A' 
		        AND (sal_doc <> 0.0 
		        AND fult_doc <= paramFecha
		        OR  fult_doc  > paramFecha 
		        AND femi_doc <= paramFecha )
		        AND ffac_doc IS NULL
		      GROUP BY 1,2,3,4,5,6,7,8,9,16
		      
		      IF vfult >  paramFecha AND vfemi <= paramFecha THEN
		      	IF vtipo = 'F' THEN
		         	LET vsaldo = cxc_saldo(vtpa,vtipdoc,paramFecha,vcia,vpla,vcte,0,vfolio,vserie,vvuelta);
		        ELSE
		        	LET vsaldo = cxc_saldo(vtpa,vtipdoc,paramFecha,vcia,vpla,vcte,vfolio,0,vserie,vvuelta);
		        END IF;
		      END IF;
			  LET vsaldosv,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo120,vsaldo150,vsaldo180,vsaldo210,vsaldo240,vsaldo270 = cxc_saldorangov(paramFecha,vfven,30,60,90,120,150,180,210,240,270,vsaldo);
		      LET vsaltot = vsaltot + vsaldo; 
			  LET vsaltotsv = vsaltotsv + vsaldosv;			  
		      LET vsaltot0 = vsaltot0 + vsaldo0; 
		      LET vsaltot30 = vsaltot30 + vsaldo30; 
		      LET vsaltot60 = vsaltot60 + vsaldo60; 
		      LET vsaltot90 = vsaltot90 + vsaldo90; 
			  LET vsaltot120 = vsaltot120 + vsaldo120;  
			  LET vsaltot150 = vsaltot150 + vsaldo150;  
		      LET vsaltot180 = vsaltot180 + vsaldo180;  
			  LET vsaltot210 = vsaltot210 + vsaldo210;  	
			  LET vsaltot240 = vsaltot240 + vsaldo240; 
              LET vsaltot270 = vsaltot270 + vsaldo270;  			  
		END FOREACH;   
	ELSE
		FOREACH cDocumentos FOR
			SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
		          tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
		          MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
		    INTO	vcte,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vuso,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
		    FROM doctos
		    WHERE cte_doc = paramCte		        
		        AND tpa_doc = paramTpa
		        AND sta_doc = 'A' 
		        AND (sal_doc <> 0.0 
		        AND fult_doc <= paramFecha
		        OR  fult_doc  > paramFecha 
		        AND femi_doc <= paramFecha )
		        AND ffac_doc IS NOT NULL
		      GROUP BY 1,2,3,4,5,6,7,8,9,16
		   UNION
		   SELECT cte_doc,tip_doc,fol_doc,ser_doc,cia_doc,pla_doc,
		          tpa_doc,uso_doc,vuelta_doc,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
		          MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'N'
		      FROM doctos
		      WHERE cte_doc = paramCte		        
		        AND tpa_doc = paramTpa
		        AND sta_doc = 'A' 
		        AND (sal_doc <> 0.0 
		        AND fult_doc <= paramFecha
		        OR  fult_doc  > paramFecha 
		        AND femi_doc <= paramFecha )
		        AND ffac_doc IS NULL
		      GROUP BY 1,2,3,4,5,6,7,8,9,16
		      
		      IF vfult >  paramFecha AND vfemi <= paramFecha THEN
		      	IF vtipo = 'F' THEN
		         	LET vsaldo = cxc_saldo(vtpa,vtipdoc,paramFecha,vcia,vpla,vcte,0,vfolio,vserie,vvuelta);
		        ELSE
		        	LET vsaldo = cxc_saldo(vtpa,vtipdoc,paramFecha,vcia,vpla,vcte,vfolio,0,vserie,vvuelta);
		        END IF;
		      END IF;
		      LET vsaldosv,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo120,vsaldo150,vsaldo180,vsaldo210,vsaldo240,vsaldo270 = cxc_saldorangov(paramFecha,vfven,30,60,90,120,150,180,210,240,270,vsaldo);
		      LET vsaltot = vsaltot + vsaldo; 
			  LET vsaltotsv = vsaltotsv + vsaldosv;			  
		      LET vsaltot0 = vsaltot0 + vsaldo0; 
		      LET vsaltot30 = vsaltot30 + vsaldo30; 
		      LET vsaltot60 = vsaltot60 + vsaldo60; 
		      LET vsaltot90 = vsaltot90 + vsaldo90; 
			  LET vsaltot120 = vsaltot120 + vsaldo120;  
			  LET vsaltot150 = vsaltot150 + vsaldo150;  
		      LET vsaltot180 = vsaltot180 + vsaldo180;  
			  LET vsaltot210 = vsaltot210 + vsaldo210;  	
			  LET vsaltot240 = vsaltot240 + vsaldo240; 
              LET vsaltot270 = vsaltot270 + vsaldo270;        
		END FOREACH;   
	END IF;
ELSE
	IF	paramCia <> '' AND paramPla <> '' THEN
		FOREACH cDocumentos FOR
			SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
		          tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
		          MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
		    INTO	vcte,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vuso,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
		    FROM doctos
		    WHERE cte_doc = paramCte
		        AND cia_doc = paramCia
		        AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)		       
		        AND sta_doc = 'A' 
		        AND (sal_doc <> 0.0 
		        AND fult_doc <= paramFecha
		        OR  fult_doc  > paramFecha 
		        AND femi_doc <= paramFecha )
		        AND ffac_doc IS NOT NULL
		      GROUP BY 1,2,3,4,5,6,7,8,9,16
		   UNION
		   SELECT cte_doc,tip_doc,fol_doc,ser_doc,cia_doc,pla_doc,
		          tpa_doc,uso_doc,vuelta_doc,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
		          MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'N'
		      FROM doctos
		      WHERE cte_doc = paramCte
		        AND cia_doc = paramCia
		        AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)		       
		        AND sta_doc = 'A' 
		        AND (sal_doc <> 0.0 
		        AND fult_doc <= paramFecha
		        OR  fult_doc  > paramFecha 
		        AND femi_doc <= paramFecha )
		        AND ffac_doc IS NULL
		      GROUP BY 1,2,3,4,5,6,7,8,9,16
		      
		      IF vfult >  paramFecha AND vfemi <= paramFecha THEN
		      	IF vtipo = 'F' THEN
		         	LET vsaldo = cxc_saldo(vtpa,vtipdoc,paramFecha,vcia,vpla,vcte,0,vfolio,vserie,vvuelta);
		        ELSE
		        	LET vsaldo = cxc_saldo(vtpa,vtipdoc,paramFecha,vcia,vpla,vcte,vfolio,0,vserie,vvuelta);
		        END IF;
		      END IF;
		      LET vsaldosv,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo120,vsaldo150,vsaldo180,vsaldo210,vsaldo240,vsaldo270 = cxc_saldorangov(paramFecha,vfven,30,60,90,120,150,180,210,240,270,vsaldo);
		      LET vsaltot = vsaltot + vsaldo; 
			  LET vsaltotsv = vsaltotsv + vsaldosv;			  
		      LET vsaltot0 = vsaltot0 + vsaldo0; 
		      LET vsaltot30 = vsaltot30 + vsaldo30; 
		      LET vsaltot60 = vsaltot60 + vsaldo60; 
		      LET vsaltot90 = vsaltot90 + vsaldo90; 
			  LET vsaltot120 = vsaltot120 + vsaldo120;  
			  LET vsaltot150 = vsaltot150 + vsaldo150;  
		      LET vsaltot180 = vsaltot180 + vsaldo180;  
			  LET vsaltot210 = vsaltot210 + vsaldo210;  	
			  LET vsaltot240 = vsaltot240 + vsaldo240; 
              LET vsaltot270 = vsaltot270 + vsaldo270;  
		END FOREACH;   
	ELSE
		FOREACH cDocumentos FOR
			SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
		          tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
		          MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
		    INTO	vcte,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vuso,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
		    FROM doctos
		    WHERE cte_doc = paramCte		        
		        AND sta_doc = 'A' 
		        AND (sal_doc <> 0.0 
		        AND fult_doc <= paramFecha
		        OR  fult_doc  > paramFecha 
		        AND femi_doc <= paramFecha )
		        AND ffac_doc IS NOT NULL
		      GROUP BY 1,2,3,4,5,6,7,8,9,16
		   UNION
		   SELECT cte_doc,tip_doc,fol_doc,ser_doc,cia_doc,pla_doc,
		          tpa_doc,uso_doc,vuelta_doc,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
		          MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'N'
		      FROM doctos
		      WHERE cte_doc = paramCte		        
		        AND sta_doc = 'A' 
		        AND (sal_doc <> 0.0 
		        AND fult_doc <= paramFecha
		        OR  fult_doc  > paramFecha 
		        AND femi_doc <= paramFecha )
		        AND ffac_doc IS NULL
		      GROUP BY 1,2,3,4,5,6,7,8,9,16
		      
		      IF vfult >  paramFecha AND vfemi <= paramFecha THEN
		      	IF vtipo = 'F' THEN
		         	LET vsaldo = cxc_saldo(vtpa,vtipdoc,paramFecha,vcia,vpla,vcte,0,vfolio,vserie,vvuelta);
		        ELSE
		        	LET vsaldo = cxc_saldo(vtpa,vtipdoc,paramFecha,vcia,vpla,vcte,vfolio,0,vserie,vvuelta);
		        END IF;
		      END IF;
		      LET vsaldosv,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo120,vsaldo150,vsaldo180,vsaldo210,vsaldo240,vsaldo270 = cxc_saldorangov(paramFecha,vfven,30,60,90,120,150,180,210,240,270,vsaldo);
		      LET vsaltot = vsaltot + vsaldo; 
			  LET vsaltotsv = vsaltotsv + vsaldosv;			  
		      LET vsaltot0 = vsaltot0 + vsaldo0; 
		      LET vsaltot30 = vsaltot30 + vsaldo30; 
		      LET vsaltot60 = vsaltot60 + vsaldo60; 
		      LET vsaltot90 = vsaltot90 + vsaldo90; 
			  LET vsaltot120 = vsaltot120 + vsaldo120;  
			  LET vsaltot150 = vsaltot150 + vsaldo150;  
		      LET vsaltot180 = vsaltot180 + vsaldo180;  
			  LET vsaltot210 = vsaltot210 + vsaldo210;  	
			  LET vsaltot240 = vsaltot240 + vsaldo240; 
              LET vsaltot270 = vsaltot270 + vsaldo270;    
		END FOREACH;   
	END IF;
END IF;

RETURN 	vsaltot,vsaltotsv,vsaltot0,vsaltot30,vsaltot60,vsaltot90,vsaltot120,vsaltot150,vsaltot180,vsaltot210,vsaltot240,vsaltot270;
END PROCEDURE;
