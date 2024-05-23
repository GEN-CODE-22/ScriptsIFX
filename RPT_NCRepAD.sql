EXECUTE PROCEDURE RPT_NCRepAD('2023-01-01','2023-01-31','T');
EXECUTE PROCEDURE RPT_NCRepAD('2024-01-01','2024-01-31','R');

DROP PROCEDURE RPT_NCRepAD;
CREATE PROCEDURE RPT_NCRepAD
(
	paramFecIni	DATE,
	paramFecFin	DATE,
	paramTipo	CHAR(1)
)

RETURNING  
 CHAR(13), 
 CHAR(80),
 CHAR(4), 
 INT, 
 CHAR(18),
 DECIMAL,
 DECIMAL,
 DECIMAL,
 CHAR(1), 
 CHAR(1),
 CHAR(500);
 
DEFINE vrfc    	CHAR(13);
DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vserie  	CHAR(4);
DEFINE vfolnc	INT;
DEFINE vfecnc 	CHAR(18);
DEFINE vtlts    DECIMAL;
DEFINE vsimpt   DECIMAL;
DEFINE vprecio  DECIMAL;
DEFINE vimpr    CHAR(1);
DEFINE vtdoc    CHAR(1);
DEFINE vuuid    CHAR(500);
DEFINE vuuidfac CHAR(40);
DEFINE vfrnc	INT;
DEFINE vsrnc  	CHAR(4);
DEFINE vserfac 	CHAR(4);
DEFINE vfolfac	INT;

IF paramTipo = 'T' THEN
	FOREACH cNotasCredito FOR
		SELECT 	rfc_ncrd,numcte_ncrd,ser_ncrd,fol_ncrd,fec_ncrd||' '||
				extend(fyh_ncrd,HOUR TO SECOND),
				SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE tlts_dncrd END),
				SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE simp_dncrd END),
				SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE simp_dncrd END)/
				SUM(CASE WHEN edo_ncrd = 'C' THEN 1 ELSE tlts_dncrd END),
				(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE 1 END),tdoc_ncrd,
				uuid_ncrd,frnc_ncrd,srnc_ncrd
		INTO    vrfc,vnocte,vserie,vfolnc,vfecnc,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid,vfrnc,vsrnc
		FROM 	nota_crd, OUTER det_ncrd
		WHERE 	fec_ncrd BETWEEN paramFecIni AND paramFecFin
				AND impr_ncrd = 'E'
				AND tdoc_ncrd = 'E'
				AND fol_ncrd = fol_dncrd
				AND ser_ncrd = ser_dncrd				
				AND (tpa_ncrd = 'E' OR tpa_ncrd = 'X' OR (tpa_ncrd = 'C' OR tpa_ncrd = 'G') AND napl_ncrd = 'S')
		GROUP BY 1,2,3,4,5,9,10,11,12,13
		ORDER BY 3,4
		 
		SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
				ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
		INTO	vnomcte
		FROM	cliente
		WHERE	num_cte = vnocte;
		
		FOREACH cDNotasCredito FOR
			SELECT  serf_dncrd,fac_dncrd
			INTO 	vserfac,vfolfac
			FROM	det_ncrd
			WHERE	ser_dncrd = vserie AND fol_dncrd = vfolnc
			
			SELECT	uuid_fac
			INTO	vuuidfac
			FROM	factura
			WHERE	ser_fac = vserfac AND fol_fac = vfolfac;
			
			LET vuuid = TRIM(vuuid) || '|' || TRIM(vuuidfac);
			
		END FOREACH;
		
		LET vuuid = TRIM(vuuid) || '|' ;
		
		RETURN 	vrfc,vnomcte,vserie,vfolnc,vfecnc,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
		WITH RESUME;
		
		IF vfrnc IS NOT NULL AND vsrnc > 0 THEN
			LET vsimpt = vsimpt * -1;
			LET vtlts = vtlts * -1;
			LET vimpr = '0';
			LET vuuid = '' ;
			
			SELECT 	rfc_ncrd,numcte_ncrd,ser_ncrd,fol_ncrd,fec_ncrd ||' '|| extend(fyh_ncrd,HOUR TO SECOND),tdoc_ncrd,uuid_ncrd
            INTO 	vrfc,vnocte,vserie,vfolnc,vfecnc,vtdoc,vuuid
            FROM    nota_crd
            WHERE   fol_ncrd = vfrnc AND ser_ncrd = vsrnc;
			
			SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
					ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnocte;
			
			FOREACH cDNotasCredito FOR
				SELECT  serf_dncrd,fac_dncrd
				INTO 	vserfac,vfolfac
				FROM	det_ncrd
				WHERE	ser_dncrd = vserie AND fol_dncrd = vfolnc
				
				SELECT	uuid_fac
				INTO	vuuidfac
				FROM	factura
				WHERE	ser_fac = vserfac AND fol_fac = vfolfac;
				
				LET vuuid = TRIM(vuuid) || '|' || TRIM(vuuidfac);
				
			END FOREACH;
			
			LET vuuid = TRIM(vuuid) || '|' ;
			RETURN 	vrfc,vnomcte,vserie,vfolfac,vfecnc,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
			WITH RESUME;
			
		END IF;
	END FOREACH;
ELSE
	IF paramTipo = 'R' THEN
		FOREACH cNotasCredito FOR
			SELECT 	rfc_ncrd,numcte_ncrd,ser_ncrd,fol_ncrd,fec_ncrd||' '||
				extend(fyh_ncrd,HOUR TO SECOND),
				SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE NVL(tlts_dncrd,0) END),
				SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE NVL(simp_dncrd,0) END),
				NVL(SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE simp_dncrd END)/
					SUM(CASE WHEN edo_ncrd = 'C' THEN 1 ELSE tlts_dncrd END),0),
				(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE 1 END),tdoc_ncrd,
					uuid_ncrd,frnc_ncrd,srnc_ncrd
			INTO    vrfc,vnocte,vserie,vfolnc,vfecnc,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid,vfrnc,vsrnc
			FROM 	nota_crd,OUTER det_ncrd
			WHERE 	fec_ncrd BETWEEN paramFecIni AND paramFecFin
					AND impr_ncrd = 'E'
					AND tdoc_ncrd = 'E'
					AND fol_ncrd = fol_dncrd
					AND ser_ncrd = ser_dncrd					
					AND frnc_ncrd IS NOT NULL
					AND (tpa_ncrd = 'E' OR tpa_ncrd = 'X' OR (tpa_ncrd = 'C' OR tpa_ncrd = 'G') AND napl_ncrd = 'S')
			GROUP BY 1,2,3,4,5,9,10,11,12,13
			ORDER BY 3,4
			
			SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
					ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnocte;
			
			FOREACH cDNotasCredito FOR
				SELECT  serf_dncrd,fac_dncrd
				INTO 	vserfac,vfolfac
				FROM	det_ncrd
				WHERE	ser_dncrd = vserie AND fol_dncrd = vfolnc
				
				SELECT	uuid_fac
				INTO	vuuidfac
				FROM	factura
				WHERE	ser_fac = vserfac AND fol_fac = vfolfac;
				
				LET vuuid = TRIM(vuuid) || '|' || TRIM(vuuidfac);
				
			END FOREACH;
			
			LET vuuid = TRIM(vuuid) || '|' ;
			
			RETURN 	vrfc,vnomcte,vserie,vfolnc,vfecnc,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
			WITH RESUME;
			
			SELECT 	rfc_ncrd,numcte_ncrd,ser_ncrd,fol_ncrd,fec_ncrd ||' '|| extend(fyh_ncrd,HOUR TO SECOND),tdoc_ncrd,uuid_ncrd
            INTO 	vrfc,vnocte,vserie,vfolnc,vfecnc,vtdoc,vuuid
            FROM    nota_crd
            WHERE   fol_ncrd = vfrnc AND ser_ncrd = vsrnc;
			
			SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
					ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnocte;
			
			LET vuuid = '';
			LET vimpr = '0';
		    LET vsimpt = vsimpt * -1;
			LET vtlts = vtlts * -1;			
		
			FOREACH cDNotasCredito FOR
				SELECT  serf_dncrd,fac_dncrd
				INTO 	vserfac,vfolfac
				FROM	det_ncrd
				WHERE	ser_dncrd = vserie AND fol_dncrd = vfolnc
				
				SELECT	uuid_fac
				INTO	vuuidfac
				FROM	factura
				WHERE	ser_fac = vserfac AND fol_fac = vfolfac;
				
				LET vuuid = TRIM(vuuid) || '|' || TRIM(vuuidfac);
				
			END FOREACH;
			
			LET vuuid = TRIM(vuuid) || '|' ;
			RETURN 	vrfc,vnomcte,vserie,vfolfac,vfecnc,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
			WITH RESUME;

		END FOREACH;
	END IF;
END IF;

END PROCEDURE; 

SELECT rfc_ncrd,(SELECT (CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
       ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END) FROM cliente
       WHERE numcte_ncrd = num_cte),ser_ncrd,fol_ncrd,fec_ncrd||' '||
       extend(fyh_ncrd,HOUR TO SECOND),
       SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE NVL(tlts_dncrd,0) END),
	   SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE NVL(simp_dncrd,0) END),
	   NVL(SUM(CASE WHEN edo_ncrd = 'C' THEN 0 ELSE simp_dncrd END)/
			SUM(CASE WHEN edo_ncrd = 'C' THEN 1 ELSE tlts_dncrd END),0),
       (CASE WHEN edo_ncrd = 'C' THEN 0 ELSE 1 END),tdoc_ncrd,
       uuid_ncrd,frnc_ncrd,srnc_ncrd
FROM nota_crd,det_ncrd
WHERE fec_ncrd BETWEEN '2023-01-01' AND '2023-01-31'
  AND impr_ncrd = 'E'
  AND tdoc_ncrd = 'E'
  AND fol_ncrd = fol_dncrd
  AND ser_ncrd = ser_dncrd
  AND cia_ncrd = cia_dncrd
  AND pla_ncrd = pla_dncrd
GROUP BY 1,2,3,4,5,9,10,11,12,13
ORDER BY 3,4
