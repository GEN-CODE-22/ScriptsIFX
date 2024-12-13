EXECUTE PROCEDURE RPT_FactRepAD('2023-07-01','2023-07-31','T');
EXECUTE PROCEDURE RPT_FactRepAD('2024-01-01','2024-01-31','R');
EXECUTE PROCEDURE RPT_FactRepAD('2023-09-01','2023-09-30','C');


DROP PROCEDURE RPT_FactRepAD;
CREATE PROCEDURE RPT_FactRepAD
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
                AND simp_dfac > 0				
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
					AND simp_dfac > 0
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
						SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(tlts_dfac,0) END) tlts,
						SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(simp_dfac,0) END) simpt,
						NVL(SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END) / SUM(CASE WHEN edo_fac = 'C' THEN 1 ELSE tlts_dfac END),0) precio,
						(CASE WHEN edo_fac = 'C' THEN 0 ELSE 1 END) edo,
						tdoc_fac, uuid_fac, frf_fac, srf_fac
				INTO    vrfc,vnocte,vserie,vfolfac,vfecfac,vtlts,vsimpt,vprecio,vimpr,vtdoc,vuuid,vfrf,vsrf
				FROM 	factura,OUTER det_fac
				WHERE 	fec_fac BETWEEN paramFecIni AND paramFecFin
						AND impr_fac = 'E'
						AND tdoc_fac IN('I','V')
						AND fol_fac = fol_dfac
						AND ser_fac = ser_dfac						
						AND faccer_fac = 'S'
						AND simp_dfac > 0
				GROUP BY 1,2,3,4,5,9,10,11,12,13
				ORDER BY 3,4
				
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
WHERE 	fec_fac BETWEEN '2023-07-31' AND '2023-07-31'
		AND impr_fac = 'E'
		AND tdoc_fac = 'I'
		and cia_fac = cia_dfac
		and pla_fac = pla_dfac
		AND fol_fac = fol_dfac
		AND ser_fac = ser_dfac		
		--AND faccer_fac = 'S'
		AND simp_dfac > 0
		--and fol_fac = 85672
GROUP BY 1,2,3,4,5,9,10,11,12,13
ORDER BY 3,4

SELECT 	rfc_fac, numcte_fac, ser_fac,fol_fac,fec_fac ||' '||
		extend(fyh_fac,HOUR TO SECOND),
		SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(tlts_dfac,0) END) tlts,
		SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE NVL(simp_dfac,0) END) simpt,
		NVL(SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END) / SUM(CASE WHEN edo_fac = 'C' THEN 1 ELSE tlts_dfac END),0) precio,
		(CASE WHEN edo_fac = 'C' THEN 0 ELSE 1 END) edo,
		tdoc_fac, uuid_fac, frf_fac, srf_fac
FROM 	factura, outer det_fac
WHERE 	fec_fac BETWEEN '2023-08-01' AND '2023-08-31'
		AND impr_fac = 'E'
		AND tdoc_fac = 'I'
		and cia_fac = cia_dfac
		and pla_fac = pla_dfac
		AND fol_fac = fol_dfac
		AND ser_fac = ser_dfac		
		AND faccer_fac = 'S'
		AND simp_dfac > 0
		--and fol_fac = 85672
GROUP BY 1,2,3,4,5,9,10,11,12,13
ORDER BY 3,4

select * from	 ruta

SELECT 	pcre_rut,fol_fac,ser_fac,rfc_fac, 'N',
		(CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(razsoc_cte)	ELSE TRIM(nom_cte)||' '|| TRIM(ape_cte) end) cliente,
		'I',uuid_fac,
		NVL(SUM(CASE WHEN edo_fac = 'C' THEN 0 ELSE simp_dfac END) / SUM(CASE WHEN edo_fac = 'C' THEN 1 ELSE tlts_dfac END),0) precio,				
		fec_fac ||' '||	extend(fyh_fac,HOUR TO SECOND)
FROM 	factura, det_fac, hnota_vta, cliente,ruta
WHERE 	fec_fac BETWEEN '2022-01-01' AND '2022-01-31'
		AND impr_fac = 'E'
		AND tdoc_fac = 'I'
		AND fol_fac = fol_dfac
		AND ser_fac = ser_dfac		
		AND faccer_fac = 'N'
		AND simp_dfac > 0
		and fnvta_dfac = fol_nvta and vuelta_dfac = vuelta_nvta
		and fol_dfac = fac_nvta
		and ruta_nvta = cve_rut
		and numcte_fac = num_cte
		and pla_fac = '01'
GROUP BY 1,2,3,4,5,6,7,8,10
ORDER BY 1,2,3

SELECT 	fol_fac,ser_fac
FROM 	factura, det_fac, hnota_vta, cliente,ruta
WHERE 	fec_fac BETWEEN '2022-01-01' AND '2022-01-31'
		AND impr_fac = 'E'
		AND tdoc_fac = 'I'
		AND fol_fac = fol_dfac
		AND ser_fac = ser_dfac	
		and pla_fac = '01'
		AND faccer_fac = 'N'
		AND simp_dfac > 0
		and numcte_fac = num_cte
		and pla_dfac = pla_nvta and fnvta_dfac = fol_nvta and vuelta_dfac = vuelta_nvta
		and fol_dfac = fac_nvta
		and ruta_nvta = cve_rut
		and numcte_fac = num_cte
		


select *
from   fuente.factura , det_fac,hnota_vta
where  fec_fac BETWEEN '2022-01-01' AND '2022-01-31'
		AND impr_fac = 'E'
		AND tdoc_fac = 'I'
		AND (fol_fac = fol_dfac
		AND ser_fac = ser_dfac	
		and pla_fac = pla_dfac
		and pla_nvta = pla_fac and fol_nvta = fnvta_dfac and vuelta_dfac = vuelta_nvta)
		and pla_fac = '01'
ORDER BY 1,2,3
