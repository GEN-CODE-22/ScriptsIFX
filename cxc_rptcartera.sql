DROP PROCEDURE cxc_rptcartera;
EXECUTE PROCEDURE cxc_rptcartera('','2023-01-04','','','086966');
EXECUTE PROCEDURE cxc_rptcartera('','2022-10-25','','','193109');
EXECUTE PROCEDURE cxc_rptcartera('','2022-11-07','','','065188');
EXECUTE PROCEDURE cxc_rptcartera('','2022-10-25','15','85','065188');
EXECUTE PROCEDURE cxc_rptcartera('','2022-10-25','15','09','065188');
EXECUTE PROCEDURE cxc_rptcartera('','2022-10-25','15','','065188');
CREATE PROCEDURE cxc_rptcartera
(
	paramTpa		CHAR(1),
	paramFecha   	DATE,
	paramCia		CHAR(2),
	paramPla		CHAR(18),
	paramCte		CHAR(6)	
)

RETURNING  
 CHAR(6),	-- No Cliente
 CHAR(80),  -- Nombre / Razon Social
 CHAR(2),   -- Uso
 CHAR(9),	-- Texto Factura o Remision
 INT,		-- Folio factura o remision
 CHAR(4),	-- Serie
 CHAR(2),	-- Cia
 CHAR(2),	-- Planta
 DATE,		-- Fecha emision
 DECIMAL,	-- Saldo
 DECIMAL,	-- Saldo 0-30 dias
 DECIMAL,	-- Saldo 31-60 dias
 DECIMAL,	-- Saldo 61-90 dias
 DECIMAL,	-- Saldo 91-180 dias
 DECIMAL;	-- Saldo +180 dias

DEFINE vcte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vtipdoc 	CHAR(2);
DEFINE vfolio   INT;
DEFINE vserie 	CHAR(4);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vtpa 	CHAR(1);
DEFINE vuso 	CHAR(2);
DEFINE vcargo 	DECIMAL;
DEFINE vabono 	DECIMAL;
DEFINE vsaldo 	DECIMAL;
DEFINE vfven 	DATE;
DEFINE vfemi 	DATE;
DEFINE vfult 	DATE;
DEFINE vtipo 	CHAR(1);
DEFINE vtext 	CHAR(9);
DEFINE vsaldo0 	DECIMAL;
DEFINE vsaldo30	DECIMAL;
DEFINE vsaldo60	DECIMAL;
DEFINE vsaldo90	DECIMAL;
DEFINE vsaldo180	DECIMAL;
DEFINE vfrf   	INT;
DEFINE vsrf 	CHAR(4);
DEFINE vvuelta 	SMALLINT;
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

IF paramTpa <> '' THEN
	IF	paramCia <> '' AND paramPla <> '' THEN
		IF	paramCte <> '' THEN
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
				  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
				  LET vfrf = 0;
				  LET vsrf = '';
				  IF vtipo = 'F' THEN 
					LET vtext = 'FACTURA';
					SELECT 	frf_fac,srf_fac 
					INTO 	vfrf,vsrf 
					FROM 	factura
					WHERE fol_fac = vfolio
						  AND ser_fac = vserie
						  AND cia_fac = vcia
						  AND pla_fac = vpla;
					 IF vfrf IS NOT NULL AND vfrf > 0 THEN
						LET vtext = 'REFACTURA';
					 END IF;      	 	
				  ELSE
					LET vtext = 'REMISION';
				  END IF;
				  LET vnomcte = '';
					IF vcte <> '' THEN
						SELECT	NVL(CASE 
								WHEN TRIM(cliente.razsoc_cte) <> '' THEN
								   TRIM(cliente.razsoc_cte) 
								ELSE 
								   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
								END,'')
						INTO	vnomcte
						FROM	cliente
						WHERE	num_cte = vcte;
					END IF;
				  RETURN 	vcte,vnomcte,vuso,vtext,vfolio,vserie,vcia,vpla,vfemi,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
				  WITH RESUME;
			END FOREACH; 
		ELSE
			FOREACH cDocumentos FOR
				SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
					  tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
					  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
				INTO	vcte,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vuso,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
				FROM doctos
				WHERE cia_doc = paramCia
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
				  WHERE cia_doc = paramCia
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
				  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
				  LET vfrf = 0;
				  LET vsrf = '';
				  IF vtipo = 'F' THEN 
					LET vtext = 'FACTURA';
					SELECT 	frf_fac,srf_fac 
					INTO 	vfrf,vsrf 
					FROM 	factura
					WHERE fol_fac = vfolio
						  AND ser_fac = vserie
						  AND cia_fac = vcia
						  AND pla_fac = vpla;
					 IF vfrf IS NOT NULL AND vfrf > 0 THEN
						LET vtext = 'REFACTURA';
					 END IF;      	 	
				  ELSE
					LET vtext = 'REMISION';
				  END IF;
				  LET vnomcte = '';
					IF vcte <> '' THEN
						SELECT	NVL(CASE 
								WHEN TRIM(cliente.razsoc_cte) <> '' THEN
								   TRIM(cliente.razsoc_cte) 
								ELSE 
								   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
								END,'')
						INTO	vnomcte
						FROM	cliente
						WHERE	num_cte = vcte;
					END IF;
				  RETURN 	vcte,vnomcte,vuso,vtext,vfolio,vserie,vcia,vpla,vfemi,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
				  WITH RESUME;
			END FOREACH; 
		END IF;
	ELSE
		IF	paramCte <> '' THEN
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
				  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
				  LET vfrf = 0;
				  LET vsrf = '';
				  IF vtipo = 'F' THEN 
					LET vtext = 'FACTURA';
					SELECT 	frf_fac,srf_fac 
					INTO 	vfrf,vsrf 
					FROM 	factura
					WHERE fol_fac = vfolio
						  AND ser_fac = vserie
						  AND cia_fac = vcia
						  AND pla_fac = vpla;
					 IF vfrf IS NOT NULL AND vfrf > 0 THEN
						LET vtext = 'REFACTURA';
					 END IF;      	 	
				  ELSE
					LET vtext = 'REMISION';
				  END IF;
				  LET vnomcte = '';
					IF vcte <> '' THEN
						SELECT	NVL(CASE 
								WHEN TRIM(cliente.razsoc_cte) <> '' THEN
								   TRIM(cliente.razsoc_cte) 
								ELSE 
								   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
								END,'')
						INTO	vnomcte
						FROM	cliente
						WHERE	num_cte = vcte;
					END IF;
				  RETURN 	vcte,vnomcte,vuso,vtext,vfolio,vserie,vcia,vpla,vfemi,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
				  WITH RESUME;
			END FOREACH; 
		ELSE
			FOREACH cDocumentos FOR
				SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
					  tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
					  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
				INTO	vcte,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vuso,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
				FROM doctos
				WHERE tpa_doc = paramTpa
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
				  WHERE tpa_doc = paramTpa
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
				  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
				  LET vfrf = 0;
				  LET vsrf = '';
				  IF vtipo = 'F' THEN 
					LET vtext = 'FACTURA';
					SELECT 	frf_fac,srf_fac 
					INTO 	vfrf,vsrf 
					FROM 	factura
					WHERE fol_fac = vfolio
						  AND ser_fac = vserie
						  AND cia_fac = vcia
						  AND pla_fac = vpla;
					 IF vfrf IS NOT NULL AND vfrf > 0 THEN
						LET vtext = 'REFACTURA';
					 END IF;      	 	
				  ELSE
					LET vtext = 'REMISION';
				  END IF;
				  LET vnomcte = '';
					IF vcte <> '' THEN
						SELECT	NVL(CASE 
								WHEN TRIM(cliente.razsoc_cte) <> '' THEN
								   TRIM(cliente.razsoc_cte) 
								ELSE 
								   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
								END,'')
						INTO	vnomcte
						FROM	cliente
						WHERE	num_cte = vcte;
					END IF;
				  RETURN 	vcte,vnomcte,vuso,vtext,vfolio,vserie,vcia,vpla,vfemi,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
				  WITH RESUME;
			END FOREACH; 
		END IF;
	END IF;
ELSE
	IF	paramCia <> '' AND paramPla <> '' THEN
		IF	paramCte <> '' THEN
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
				  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
				  LET vfrf = 0;
				  LET vsrf = '';
				  IF vtipo = 'F' THEN 
					LET vtext = 'FACTURA';
					SELECT 	frf_fac,srf_fac 
					INTO 	vfrf,vsrf 
					FROM 	factura
					WHERE fol_fac = vfolio
						  AND ser_fac = vserie
						  AND cia_fac = vcia
						  AND pla_fac = vpla;
					 IF vfrf IS NOT NULL AND vfrf > 0 THEN
						LET vtext = 'REFACTURA';
					 END IF;      	 	
				  ELSE
					LET vtext = 'REMISION';
				  END IF;
				  LET vnomcte = '';
					IF vcte <> '' THEN
						SELECT	NVL(CASE 
								WHEN TRIM(cliente.razsoc_cte) <> '' THEN
								   TRIM(cliente.razsoc_cte) 
								ELSE 
								   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
								END,'')
						INTO	vnomcte
						FROM	cliente
						WHERE	num_cte = vcte;
					END IF;
				  RETURN 	vcte,vnomcte,vuso,vtext,vfolio,vserie,vcia,vpla,vfemi,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
				  WITH RESUME;
			END FOREACH; 
		ELSE
			FOREACH cDocumentos FOR
				SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
					  tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
					  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
				INTO	vcte,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vuso,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
				FROM doctos
				WHERE cia_doc = paramCia
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
				  WHERE cia_doc = paramCia
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
				  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
				  LET vfrf = 0;
				  LET vsrf = '';
				  IF vtipo = 'F' THEN 
					LET vtext = 'FACTURA';
					SELECT 	frf_fac,srf_fac 
					INTO 	vfrf,vsrf 
					FROM 	factura
					WHERE fol_fac = vfolio
						  AND ser_fac = vserie
						  AND cia_fac = vcia
						  AND pla_fac = vpla;
					 IF vfrf IS NOT NULL AND vfrf > 0 THEN
						LET vtext = 'REFACTURA';
					 END IF;      	 	
				  ELSE
					LET vtext = 'REMISION';
				  END IF;
				  LET vnomcte = '';
					IF vcte <> '' THEN
						SELECT	NVL(CASE 
								WHEN TRIM(cliente.razsoc_cte) <> '' THEN
								   TRIM(cliente.razsoc_cte) 
								ELSE 
								   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
								END,'')
						INTO	vnomcte
						FROM	cliente
						WHERE	num_cte = vcte;
					END IF;
				  RETURN 	vcte,vnomcte,vuso,vtext,vfolio,vserie,vcia,vpla,vfemi,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
				  WITH RESUME;
			END FOREACH; 
		END IF;
	ELSE
		IF	paramCte <> '' THEN
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
				  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
				  LET vfrf = 0;
				  LET vsrf = '';
				  IF vtipo = 'F' THEN 
					LET vtext = 'FACTURA';
					SELECT 	frf_fac,srf_fac 
					INTO 	vfrf,vsrf 
					FROM 	factura
					WHERE fol_fac = vfolio
						  AND ser_fac = vserie
						  AND cia_fac = vcia
						  AND pla_fac = vpla;
					 IF vfrf IS NOT NULL AND vfrf > 0 THEN
						LET vtext = 'REFACTURA';
					 END IF;      	 	
				  ELSE
					LET vtext = 'REMISION';
				  END IF;
				  LET vnomcte = '';
					IF vcte <> '' THEN
						SELECT	NVL(CASE 
								WHEN TRIM(cliente.razsoc_cte) <> '' THEN
								   TRIM(cliente.razsoc_cte) 
								ELSE 
								   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
								END,'')
						INTO	vnomcte
						FROM	cliente
						WHERE	num_cte = vcte;
					END IF;
				  RETURN 	vcte,vnomcte,vuso,vtext,vfolio,vserie,vcia,vpla,vfemi,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
				  WITH RESUME;
			END FOREACH; 
		ELSE
			FOREACH cDocumentos FOR
				SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
					  tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
					  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
				INTO	vcte,vtipdoc,vfolio,vserie,vcia,vpla,vtpa,vuso,vvuelta,vcargo,vabono,vsaldo,vfven,vfemi,vfult,vtipo
				FROM doctos
				WHERE sta_doc = 'A' 
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
				  WHERE sta_doc = 'A' 
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
				  LET vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180 = cxc_saldorango(paramFecha,vfemi,30,60,90,180,vsaldo);
				  LET vfrf = 0;
				  LET vsrf = '';
				  IF vtipo = 'F' THEN 
					LET vtext = 'FACTURA';
					SELECT 	frf_fac,srf_fac 
					INTO 	vfrf,vsrf 
					FROM 	factura
					WHERE fol_fac = vfolio
						  AND ser_fac = vserie
						  AND cia_fac = vcia
						  AND pla_fac = vpla;
					 IF vfrf IS NOT NULL AND vfrf > 0 THEN
						LET vtext = 'REFACTURA';
					 END IF;      	 	
				  ELSE
					LET vtext = 'REMISION';
				  END IF;
				  LET vnomcte = '';
					IF vcte <> '' THEN
						SELECT	NVL(CASE 
								WHEN TRIM(cliente.razsoc_cte) <> '' THEN
								   TRIM(cliente.razsoc_cte) 
								ELSE 
								   trim(cliente.ape_cte) || ' ' || TRIM(cliente.nom_cte) 
								END,'')
						INTO	vnomcte
						FROM	cliente
						WHERE	num_cte = vcte;
					END IF;
				  RETURN 	vcte,vnomcte,vuso,vtext,vfolio,vserie,vcia,vpla,vfemi,vsaldo,vsaldo0,vsaldo30,vsaldo60,vsaldo90,vsaldo180
				  WITH RESUME;
			END FOREACH; 
		END IF;
	END IF;
END IF; 
END PROCEDURE;

SELECT cte_doc,tip_doc,ffac_doc,sfac_doc,cia_doc,pla_doc,
	  tpa_doc,uso_doc,0,SUM(car_doc),SUM(abo_doc),SUM(sal_doc),
	  MAX(fven_doc),MIN(femi_doc),MAX(fult_doc),'F' 
FROM doctos
WHERE cte_doc = '086966'
	AND sta_doc = 'A' 
	AND (sal_doc <> 0.0 
	AND (fult_doc <= '2023-01-04'
	OR  fult_doc  >  '2023-01-04' 
	AND femi_doc <=  '2023-01-04' ))
	AND ffac_doc IS NOT NULL
  GROUP BY 1,2,3,4,5,6,7,8,9,16
