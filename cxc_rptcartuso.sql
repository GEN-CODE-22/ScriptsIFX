DROP PROCEDURE cxc_rptcartuso;
EXECUTE PROCEDURE cxc_rptcartuso('','2022-08-31','','','10');
EXECUTE PROCEDURE cxc_rptcartuso('C','2022-07-21','15','10','2');
EXECUTE PROCEDURE cxc_rptcartuso('C','2022-07-13','15','79','3');
EXECUTE PROCEDURE cxc_rptcartuso('C','2022-07-13','','','4');

CREATE PROCEDURE cxc_rptcartuso
(
	paramTpa		CHAR(1),
	paramFecha   	DATE,
	paramCia		CHAR(2),
	paramPla		CHAR(2),
	paramUso		CHAR(18)	
)
RETURNING   
 DECIMAL,	-- Saldo
 DECIMAL,	-- Saldo 0-30 dias
 DECIMAL,	-- Saldo 31-60 dias
 DECIMAL,	-- Saldo 61-90 dias
 DECIMAL,	-- Saldo 91-180 dias
 DECIMAL;	-- Saldo +180 dias

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
DEFINE vsaldo0 	DECIMAL;
DEFINE vsaldo30	DECIMAL;
DEFINE vsaldo60	DECIMAL;
DEFINE vsaldo90	DECIMAL;
DEFINE vsaldo180	DECIMAL;
DEFINE vsaltot0 	DECIMAL;
DEFINE vsaltot30	DECIMAL;
DEFINE vsaltot60	DECIMAL;
DEFINE vsaltot90	DECIMAL;
DEFINE vsaltot180	DECIMAL;
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
LET vsaldo0 = 0;
LET vsaldo30 = 0;
LET vsaldo60 = 0;
LET vsaldo90 = 0;
LET vsaldo180 = 0;
LET vsaltot = 0;
LET vsaltot0 = 0;
LET vsaltot30 = 0;
LET vsaltot60 = 0;
LET vsaltot90 = 0;
LET vsaltot180 = 0;

IF paramTpa <> '' THEN
	IF	paramCia <> '' AND paramPla <> '' THEN
		FOREACH cDocumentos FOR
			SELECT uso_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
				  tpa_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
				  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
			INTO	vuso,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
			FROM doctos
			WHERE uso_doc = paramUso
				AND cia_doc = paramCia
				AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)
				AND tpa_doc = paramTpa
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )
				AND ffac_doc IS NOT NULL
			  GROUP BY 1,2,3,4,5,6,7,8,15
		   UNION
		   SELECT uso_doc,tip_doc,fol_doc,ser_doc,cia_doc,pla_doc,
				  tpa_doc,NVL(vuelta_doc,0),SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
				  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'N'
			  FROM doctos
			  WHERE uso_doc = paramUso
				AND cia_doc = paramCia
				AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)
				AND tpa_doc = paramTpa
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )
				AND ffac_doc IS NULL
			  GROUP BY 1,2,3,4,5,6,7,8,15
			  
			  IF vfult >  paramFecha AND vfemi <= paramFecha THEN
				IF vtipo = 'F' THEN
					SELECT NVL(SUM(imp_mcxc),0)		
					  INTO vcargo
					  FROM mov_cxc
					  WHERE ffac_mcxc = vfolio
						AND sfac_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc < '50';
				
				   SELECT NVL(SUM(imp_mcxc),0)
					  INTO vabono
					  FROM mov_cxc
					  WHERE ffac_mcxc = vfolio
						AND sfac_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc > '49';
				
				   LET vsaldo = vcargo - vabono;
				ELSE
					SELECT NVL(SUM(imp_mcxc),0)
					INTO vcargo
					  FROM mov_cxc
					  WHERE doc_mcxc = vfolio
						AND ser_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND (vuelta_mcxc = vvuelta OR (tip_mcxc = vtipdoc AND vtipdoc = '03'))
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc < '50';
				
				   SELECT NVL(SUM(imp_mcxc),0)
					 INTO vabono
					 FROM mov_cxc
					  WHERE doc_mcxc = vfolio
						AND ser_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND (vuelta_mcxc = vvuelta OR (tip_mcxc = vtipdoc AND vtipdoc = '03'))
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc > '49';
				
				   LET vsaldo = vcargo - vabono;
				END IF;
			  END IF;
			  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
			  LET vsaltot = vsaltot + vsaldo; 
			  LET vsaltot0 = vsaltot0 + vsaldo0; 
			  LET vsaltot30 = vsaltot30 + vsaldo30; 
			  LET vsaltot60 = vsaltot60 + vsaldo60; 
			  LET vsaltot90 = vsaltot90 + vsaldo90; 
			  LET vsaltot180 = vsaltot180 + vsaldo180;       
		END FOREACH;   
	ELSE
		FOREACH cDocumentos FOR
			SELECT uso_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
				  tpa_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
				  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
			INTO	vuso,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
			FROM doctos
			WHERE uso_doc = paramUso
				AND tpa_doc = paramTpa
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )
				AND ffac_doc IS NOT NULL
			  GROUP BY 1,2,3,4,5,6,7,8,15
		   UNION
		   SELECT uso_doc,tip_doc,fol_doc,ser_doc,cia_doc,pla_doc,
				  tpa_doc,NVL(vuelta_doc,0),SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
				  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'N'
			  FROM doctos
			  WHERE uso_doc = paramUso				
				AND tpa_doc = paramTpa
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )
				AND ffac_doc IS NULL
			  GROUP BY 1,2,3,4,5,6,7,8,15
			  
			  IF vfult >  paramFecha AND vfemi <= paramFecha THEN
				IF vtipo = 'F' THEN
					SELECT NVL(SUM(imp_mcxc),0)		
					  INTO vcargo
					  FROM mov_cxc
					  WHERE ffac_mcxc = vfolio
						AND sfac_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc < '50';
				
				   SELECT NVL(SUM(imp_mcxc),0)
					  INTO vabono
					  FROM mov_cxc
					  WHERE ffac_mcxc = vfolio
						AND sfac_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc > '49';
				
				   LET vsaldo = vcargo - vabono;
				ELSE
					SELECT NVL(SUM(imp_mcxc),0)
					INTO vcargo
					  FROM mov_cxc
					  WHERE doc_mcxc = vfolio
						AND ser_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND (vuelta_mcxc = vvuelta OR (tip_mcxc = vtipdoc AND vtipdoc = '03'))
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc < '50';
				
				   SELECT NVL(SUM(imp_mcxc),0)
					 INTO vabono
					 FROM mov_cxc
					  WHERE doc_mcxc = vfolio
						AND ser_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND (vuelta_mcxc = vvuelta OR (tip_mcxc = vtipdoc AND vtipdoc = '03'))
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc > '49';
				
				   LET vsaldo = vcargo - vabono;
				END IF;
			  END IF;
			  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
			  LET vsaltot = vsaltot + vsaldo; 
			  LET vsaltot0 = vsaltot0 + vsaldo0; 
			  LET vsaltot30 = vsaltot30 + vsaldo30; 
			  LET vsaltot60 = vsaltot60 + vsaldo60; 
			  LET vsaltot90 = vsaltot90 + vsaldo90; 
			  LET vsaltot180 = vsaltot180 + vsaldo180;       
		END FOREACH;   
	END IF;
ELSE
	IF	paramCia <> '' AND paramPla <> '' THEN
		FOREACH cDocumentos FOR
			SELECT uso_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
				  tpa_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
				  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
			INTO	vuso,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
			FROM doctos
			WHERE uso_doc = paramUso
				AND cia_doc = paramCia
				AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )
				AND ffac_doc IS NOT NULL
			  GROUP BY 1,2,3,4,5,6,7,8,15
		   UNION
		   SELECT uso_doc,tip_doc,fol_doc,ser_doc,cia_doc,pla_doc,
				  tpa_doc,NVL(vuelta_doc,0),SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
				  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'N'
			  FROM doctos
			  WHERE uso_doc = paramUso
				AND cia_doc = paramCia
				AND pla_doc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9)
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )
				AND ffac_doc IS NULL
			  GROUP BY 1,2,3,4,5,6,7,8,15
			  
			  IF vfult >  paramFecha AND vfemi <= paramFecha THEN
				IF vtipo = 'F' THEN
					SELECT NVL(SUM(imp_mcxc),0)		
					  INTO vcargo
					  FROM mov_cxc
					  WHERE ffac_mcxc = vfolio
						AND sfac_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc < '50';
				
				   SELECT NVL(SUM(imp_mcxc),0)
					  INTO vabono
					  FROM mov_cxc
					  WHERE ffac_mcxc = vfolio
						AND sfac_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc > '49';
				
				   LET vsaldo = vcargo - vabono;
				ELSE
					SELECT NVL(SUM(imp_mcxc),0)
					INTO vcargo
					  FROM mov_cxc
					  WHERE doc_mcxc = vfolio
						AND ser_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND (vuelta_mcxc = vvuelta OR (tip_mcxc = vtipdoc AND vtipdoc = '03'))
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc < '50';
				
				   SELECT NVL(SUM(imp_mcxc),0)
					 INTO vabono
					 FROM mov_cxc
					  WHERE doc_mcxc = vfolio
						AND ser_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND (vuelta_mcxc = vvuelta OR (tip_mcxc = vtipdoc AND vtipdoc = '03'))
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc > '49';
				
				   LET vsaldo = vcargo - vabono;
				END IF;
			  END IF;
			  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
			  LET vsaltot = vsaltot + vsaldo; 
			  LET vsaltot0 = vsaltot0 + vsaldo0; 
			  LET vsaltot30 = vsaltot30 + vsaldo30; 
			  LET vsaltot60 = vsaltot60 + vsaldo60; 
			  LET vsaltot90 = vsaltot90 + vsaldo90; 
			  LET vsaltot180 = vsaltot180 + vsaldo180;       
		END FOREACH;   
	ELSE
		FOREACH cDocumentos FOR
			SELECT uso_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
				  tpa_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
				  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
			INTO	vuso,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
			FROM doctos
			WHERE uso_doc = paramUso
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )
				AND ffac_doc IS NOT NULL
			  GROUP BY 1,2,3,4,5,6,7,8,15
		   UNION
		   SELECT uso_doc,tip_doc,fol_doc,ser_doc,cia_doc,pla_doc,
				  tpa_doc,NVL(vuelta_doc,0),SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
				  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'N'
			  FROM doctos
			  WHERE uso_doc = paramUso				
				AND sta_doc = 'A' 
				AND (sal_doc <> 0.0 
				AND fult_doc <= paramFecha
				OR  fult_doc  > paramFecha 
				AND femi_doc <= paramFecha )
				AND ffac_doc IS NULL
			  GROUP BY 1,2,3,4,5,6,7,8,15
			  
			  IF vfult >  paramFecha AND vfemi <= paramFecha THEN
				IF vtipo = 'F' THEN
					SELECT NVL(SUM(imp_mcxc),0)		
					  INTO vcargo
					  FROM mov_cxc
					  WHERE ffac_mcxc = vfolio
						AND sfac_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc < '50';
				
				   SELECT NVL(SUM(imp_mcxc),0)
					  INTO vabono
					  FROM mov_cxc
					  WHERE ffac_mcxc = vfolio
						AND sfac_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc > '49';
				
				   LET vsaldo = vcargo - vabono;
				ELSE
					SELECT NVL(SUM(imp_mcxc),0)
					INTO vcargo
					  FROM mov_cxc
					  WHERE doc_mcxc = vfolio
						AND ser_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND (vuelta_mcxc = vvuelta OR (tip_mcxc = vtipdoc AND vtipdoc = '03'))
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc < '50';
				
				   SELECT NVL(SUM(imp_mcxc),0)
					 INTO vabono
					 FROM mov_cxc
					  WHERE doc_mcxc = vfolio
						AND ser_mcxc = vserie
						AND cia_mcxc = vcia
						AND pla_mcxc = vpla
						AND tip_mcxc = vtipdoc
						AND (vuelta_mcxc = vvuelta OR (tip_mcxc = vtipdoc AND vtipdoc = '03'))
						AND uso_mcxc = vuso
						AND sta_mcxc = 'A'
						AND tpa_mcxc = vtpa
						AND fec_mcxc <= paramFecha
						AND tpm_mcxc > '49';
				
				   LET vsaldo = vcargo - vabono;
				END IF;
			  END IF;
			  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
			  LET vsaltot = vsaltot + vsaldo; 
			  LET vsaltot0 = vsaltot0 + vsaldo0; 
			  LET vsaltot30 = vsaltot30 + vsaldo30; 
			  LET vsaltot60 = vsaltot60 + vsaldo60; 
			  LET vsaltot90 = vsaltot90 + vsaldo90; 
			  LET vsaltot180 = vsaltot180 + vsaldo180;       
		END FOREACH;   
	END IF;
END IF;

RETURN 	vsaltot,vsaltot0,vsaltot30,vsaltot60,vsaltot90,vsaltot180;
END PROCEDURE;

SELECT NVL(SUM(imp_mcxc),0)
  FROM mov_cxc
  WHERE 
     uso_mcxc = '10'
     AND cte_mcxc = '000618'
    AND sta_mcxc = 'A'
    AND tpa_mcxc = 'C'
    AND fec_mcxc <= '2022-08-31'
    AND tpm_mcxc < '50';

SELECT NVL(SUM(imp_mcxc),0)
  FROM mov_cxc
  WHERE  uso_mcxc = '10'
    AND sta_mcxc = 'A'
    AND tpa_mcxc = 'C'
    AND fec_mcxc <= '2022-08-11'
    AND tpm_mcxc > '49';
