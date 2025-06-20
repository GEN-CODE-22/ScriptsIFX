EXECUTE PROCEDURE RPT_FactRepADN('2023-01-01','2023-01-31','T');
EXECUTE PROCEDURE RPT_FactRepADN('2024-01-01','2024-01-31','R');
EXECUTE PROCEDURE RPT_FactRepADN('2023-08-01','2023-08-31','C');


DROP PROCEDURE RPT_FactRepADN;
CREATE PROCEDURE RPT_FactRepADN
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
 DECIMAL(10,6),
 CHAR(1), 
 CHAR(1),
 CHAR(40);

DEFINE vrfc    	CHAR(13);
DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vserie  	CHAR(4);
DEFINE vfolfac 	INT;
DEFINE vfecfac 	CHAR(18);
DEFINE vtlts    DECIMAL;
DEFINE vsimpt   DECIMAL;
DEFINE vprecio  DECIMAL;
DEFINE vimpr    CHAR(1);
DEFINE vtdoc    CHAR(1);
DEFINE vuuid    CHAR(40);
DEFINE vfrf		INT;
DEFINE vsrf  	CHAR(4);
DEFINE vfaccer  CHAR(1);
DEFINE vedo     CHAR(1);


IF paramTipo = 'T' THEN
	FOREACH cFacturas FOR
		SELECT 	rfc_fac,numcte_fac,ser_fac,fol_fac,fec_fac ||' '|| extend(fyh_fac,HOUR TO SECOND),
				SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(tlts_dfac,0) END) tlts,
				SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(simp_dfac,0) END) simpt,
				NVL(SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END) / SUM(CASE WHEN edo_fac = 'C' THEN 1 ELSE tlts_dfac END),0) precio,
				(CASE WHEN edo_fac = 'C' THEN 0 ELSE 1 END) edo,
				tdoc_fac, uuid_fac, frf_fac, srf_fac, faccer_fac
		INTO    vrfc,vnocte,vserie,vfolfac,vfecfac,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid,vfrf,vsrf,vfaccer
		FROM 	factura, OUTER det_fac
		WHERE 	fec_fac BETWEEN paramFecIni AND paramFecFin
				AND impr_fac = 'E'
				AND tdoc_fac IN('I','V')
				AND fol_fac = fol_dfac
				AND ser_fac = ser_dfac				
		GROUP BY 1,2,3,4,5,9,10,11,12,13,14
		ORDER BY 3,4
		
		SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
				ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
		INTO	vnomcte
		FROM	cliente
		WHERE	num_cte = vnocte;
		
		RETURN 	vrfc,vnomcte,vserie,vfolfac,vfecfac,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
		WITH RESUME;
		
		IF vfrf IS NOT NULL AND vfrf > 0 AND vfaccer = 'N' THEN
			LET vsimpt = vsimpt * -1;
			LET vtlts = vtlts * -1;
			LET vimpr = '0';
		    LET vuuid = ''; 
			
			SELECT 	rfc_fac,numcte_fac,ser_fac,fol_fac,fec_fac ||' '|| extend(fyh_fac,HOUR TO SECOND),tdoc_fac,uuid_fac
            INTO 	vrfc,vnocte,vserie,vfolfac,vfecfac,vtdoc,vuuid
            FROM    factura
            WHERE   fol_fac = vfrf AND ser_fac = vsrf;
			
			SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
					ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnocte;
           
			RETURN 	vrfc,vnomcte,vserie,vfolfac,vfecfac,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
			WITH RESUME;			
		END IF;
		
	END FOREACH;
ELSE
	IF paramTipo = 'R' THEN
		FOREACH cFacturas FOR
			SELECT 	rfc_fac,numcte_fac,ser_fac,fol_fac,fec_fac ||' '||
					extend(fyh_fac,HOUR TO SECOND),
					SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(tlts_dfac,0) END) tlts,
					SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(simp_dfac,0) END) simpt,
					NVL(SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END) / SUM(CASE WHEN edo_fac = 'C' THEN 1 ELSE tlts_dfac END),0) precio,
					(CASE WHEN edo_fac = 'C' THEN 0 ELSE 1 END) edo,
					tdoc_fac, uuid_fac, frf_fac, srf_fac
			INTO    vrfc,vnocte,vserie,vfolfac,vfecfac,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid,vfrf,vsrf
			FROM 	factura, OUTER det_fac
			WHERE 	fec_fac BETWEEN paramFecIni AND paramFecFin
					AND impr_fac = 'E'
					AND tdoc_fac IN('I','V')
					AND fol_fac = fol_dfac
					AND ser_fac = ser_dfac					
					AND frf_fac IS NOT NULL
			GROUP BY 1,2,3,4,5,9,10,11,12,13
			ORDER BY 3,4
			
			SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
					ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnocte;
		
			RETURN 	vrfc,vnomcte,vserie,vfolfac,vfecfac,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
			WITH RESUME;
			
			SELECT 	rfc_fac,numcte_fac,ser_fac,fol_fac,fec_fac ||' '|| extend(fyh_fac,HOUR TO SECOND),tdoc_fac,uuid_fac
            INTO 	vrfc,vnocte,vserie,vfolfac,vfecfac,vtdoc,vuuid
            FROM    factura
            WHERE   fol_fac = vfrf AND ser_fac = vsrf;
			
			SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
					ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
			INTO	vnomcte
			FROM	cliente
			WHERE	num_cte = vnocte;
			
			LET vimpr = '0';
		    LET vsimpt = vsimpt * -1;
			LET vtlts = vtlts * -1;
			RETURN 	vrfc,vnomcte,vserie,vfolfac,vfecfac,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
			WITH RESUME;

		END FOREACH;	
	ELSE
		IF paramTipo = 'C' THEN
			FOREACH cFacturas FOR
				SELECT 	rfc_fac, numcte_fac, ser_fac,fol_fac,fec_fac ||' '||
						extend(fyh_fac,HOUR TO SECOND),						
						(CASE WHEN edo_fac = 'C' THEN 0 ELSE 1 END) edo,
						tdoc_fac, uuid_fac, frf_fac, srf_fac, edo_fac
				INTO    vrfc,vnocte,vserie,vfolfac,vfecfac,vimpr,vtdoc,vuuid,vfrf,vsrf,vedo
				FROM 	factura
				WHERE 	fec_fac BETWEEN paramFecIni AND paramFecFin
						AND impr_fac = 'E'
						AND tdoc_fac IN('I','V')							
						AND faccer_fac = 'S'						
				ORDER BY 3,4
				
				IF vedo = 'C' THEN 
					let vtlts = 0;
					let vsimpt = 0;
					let vprecio = 0;
				else 
					SELECT	SUM(NVL(tlts_dfac,0)) tlts,
							SUM(NVL(simp_dfac,0)) simpt,
						    NVL(SUM(simp_dfac) / SUM(tlts_dfac),0) precio
					INTO    vtlts,vsimpt,vprecio
					FROM	det_fac
					WHERE	fol_dfac = vfolfac AND ser_dfac = vserie;
				end if;
				
				
				SELECT 	CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
						ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END
				INTO	vnomcte
				FROM	cliente
				WHERE	num_cte = vnocte;
			
			
				
				RETURN 	vrfc,vnomcte,vserie,vfolfac,vfecfac,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid
				WITH RESUME;
			END FOREACH;	
		END IF;
	END IF;
END IF;

END PROCEDURE; 

SELECT rfc_fac,(SELECT (CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)
       ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) END) FROM cliente
       WHERE numcte_fac = num_cte),ser_fac,fol_fac,fec_fac||' '||
       extend(fyh_fac,HOUR TO SECOND),
       SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE tlts_dfac END),
       SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END),
       SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END)/
       SUM(CASE WHEN edo_fac = 'C' THEN 1 ELSE tlts_dfac END),
       (CASE WHEN edo_fac = 'C' THEN 0 ELSE 1 END),tdoc_fac,
       uuid_fac,frf_fac,srf_fac
FROM factura,det_fac
WHERE fec_fac BETWEEN '2023-05-01' AND '2023-05-31'
  AND impr_fac = 'E'
  AND tdoc_fac = 'I'
  AND fol_fac = fol_dfac
  AND ser_fac = ser_dfac
  AND cia_fac = cia_dfac
  AND pla_fac = pla_dfac
  and faccer_fac = 'S'
GROUP BY 1,2,3,4,5,9,10,11,12,13
ORDER BY 3,4

SELECT 	rfc_fac, numcte_fac, ser_fac,fol_fac,fec_fac ||' '||
	extend(fyh_fac,HOUR TO SECOND),
	SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE tlts_dfac END) tlts,
	SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END) simpt,
	NVL(SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END),0)/ NVL(SUM(CASE WHEN edo_fac = 'C' THEN 1 ELSE tlts_dfac END),1) precio,
	(CASE WHEN edo_fac = 'C' THEN 0 ELSE 1 END) edo,
		tdoc_fac, uuid_fac, frf_fac, srf_fac
FROM 	factura,det_fac
WHERE 	fec_fac BETWEEN '2023-05-01' AND '2023-05-31'
		AND impr_fac = 'E'
	AND tdoc_fac = 'I'
	AND fol_fac = fol_dfac
	AND ser_fac = ser_dfac
	AND cia_fac = cia_dfac
	AND pla_fac = pla_dfac
	AND faccer_fac = 'S'
	and simp_dfac > 0
GROUP BY 1,2,3,4,5,9,10,11,12,13
ORDER BY 3,4

select *
from fuente.factura 
where fec_fac between '2023-04-01' and '2023-04-30' and faccer_fac = 'S'


select * from det_fac 
where fol_dfac in(332763,332764,332765,334885,334886,334887) and ser_dfac = 'EAC'

SELECT 	rfc_fac, numcte_fac, ser_fac,fol_fac,fec_fac ||' '||
		extend(fyh_fac,HOUR TO SECOND),
		SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(tlts_dfac,0) END) tlts,
		SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(simp_dfac,0) END) simpt,
		NVL(SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END) / SUM(CASE WHEN edo_fac = 'C' THEN 1 ELSE tlts_dfac END),0) precio,
		(CASE WHEN edo_fac = 'C' THEN 0 ELSE 1 END) edo,
		tdoc_fac, uuid_fac, frf_fac, srf_fac
FROM 	factura,outer det_fac
WHERE 	fec_fac BETWEEN '2023-07-01' AND '2023-07-31'
		AND impr_fac = 'E'
		AND tdoc_fac = 'I'
		AND fol_fac = fol_dfac
		AND ser_fac = ser_dfac
		AND faccer_fac = 'S'
		AND simp_dfac > 0
		--and fol_fac = 338973
GROUP BY 1,2,3,4,5,9,10,11,12,13
ORDER BY 3,4
