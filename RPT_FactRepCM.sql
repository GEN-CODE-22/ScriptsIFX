EXECUTE PROCEDURE RPT_FactRepCM('2023-08-01','2023-08-31','T');
EXECUTE PROCEDURE RPT_FactRepCM('2023-08-01','2023-08-31','R');

DROP PROCEDURE RPT_FactRepCM;
CREATE PROCEDURE RPT_FactRepCM
(
	paramFecIni	DATE,
	paramFecFin	DATE,
	paramTipo	CHAR(1)
)

RETURNING  
 CHAR(13), 
 CHAR(4), 
 INT, 
 DATE,
 DECIMAL,
 DECIMAL,
 CHAR(1), 
 CHAR(1),
 CHAR(40);

DEFINE vrfc    	CHAR(13);
DEFINE vserie  	CHAR(4);
DEFINE vfolfac 	INT;
DEFINE vfecfac 	DATE;
DEFINE vimporte DECIMAL;
DEFINE viva	    DECIMAL;
DEFINE vimpr    CHAR(1);
DEFINE vtdoc    CHAR(1);
DEFINE vfrf		INT;
DEFINE vsrf  	CHAR(4);
DEFINE vedo     CHAR(1);
DEFINE vcia     CHAR(2);
DEFINE vpla     CHAR(2);
DEFINE vfaccer  CHAR(1);
DEFINE vuuid    CHAR(40);

IF paramTipo = 'T' THEN
	FOREACH cFacturas FOR
		SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, impt_fac, iva_fac, edo_fac, frf_fac, srf_fac, cia_fac, pla_fac, impr_fac, tdoc_fac, faccer_fac, uuid_fac
		INTO    vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vedo,vfrf,vsrf,vcia,vpla,vimpr,vtdoc,vfaccer,vuuid
		FROM 	factura,cliente
		WHERE 	numcte_fac = num_cte
				AND fec_fac BETWEEN paramFecIni AND paramFecFin
				AND tdoc_fac <> 'T'
		UNION
		SELECT 	" ",ser_fac,fol_fac,fec_fac,impt_fac,iva_fac,edo_fac,0," ",cia_fac,pla_fac,impr_fac,tdoc_fac,faccer_fac, uuid_fac
		FROM 	factura
		WHERE 	numcte_fac IS NULL
				AND fec_fac BETWEEN paramFecIni AND paramFecFin
				AND tdoc_fac <> 'T'
		ORDER BY 13,2,3 	
		
		LET vimpr = '1';
		
		IF vedo = 'C' THEN
			LET vimporte = 0;
			LET viva = 0;
			LET vimpr = '0';
		END IF;
		
		RETURN 	vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vimpr,vtdoc,vuuid
		WITH RESUME;
		
		IF vfrf IS NOT NULL AND vfrf > 0 AND vfaccer = 'N' THEN
			LET vimporte = vimporte * -1;
			LET viva = viva * -1;
			LET vimpr = '0';
			
			SELECT 	rfc_fac,ser_fac,fol_fac,fec_fac,tdoc_fac,uuid_fac
            INTO 	vrfc,vserie,vfolfac,vfecfac,vtdoc,vuuid
            FROM    factura
            WHERE   fol_fac = vfrf AND ser_fac = vsrf;
           
			RETURN 	vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vimpr,vtdoc,vuuid
			WITH RESUME;			
		END IF;
	END FOREACH;
ELSE
	IF paramTipo = 'R' THEN
		FOREACH cFacturas FOR
			SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, impt_fac, iva_fac, edo_fac, frf_fac, srf_fac, cia_fac, pla_fac, impr_fac, tdoc_fac, faccer_fac, uuid_fac
			INTO    vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vedo,vfrf,vsrf,vcia,vpla,vimpr,vtdoc,vfaccer,vuuid
			FROM 	factura,cliente
			WHERE 	numcte_fac = num_cte
					AND fec_fac BETWEEN paramFecIni AND paramFecFin
					AND tdoc_fac <> 'T'
					AND frf_fac IS NOT NULL
			UNION
			SELECT 	" ",ser_fac,fol_fac,fec_fac,impt_fac,iva_fac,edo_fac,0," ",cia_fac,pla_fac,impr_fac,tdoc_fac,faccer_fac, uuid_fac
			FROM 	factura
			WHERE 	numcte_fac IS NULL
					AND fec_fac BETWEEN paramFecIni AND paramFecFin
					AND tdoc_fac <> 'T'
					AND frf_fac IS NOT NULL
			ORDER BY 13,2,3 	
			
			LET vimpr = '1';
			
			
			RETURN 	vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vimpr,vtdoc,vuuid
			WITH RESUME;
			
			SELECT 	rfc_fac,ser_fac,fol_fac,fec_fac,tdoc_fac,uuid_fac
            INTO 	vrfc,vserie,vfolfac,vfecfac,vtdoc,vuuid
            FROM    factura
            WHERE   fol_fac = vfrf AND ser_fac = vsrf;
			LET vimpr = '0';
		    LET vimporte = vimporte * -1;
			LET viva = viva * -1;
			LET vimpr = '0';	
			RETURN 	vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vimpr,vtdoc,vuuid
			WITH RESUME;

		END FOREACH;	
	END IF;
END IF;

END PROCEDURE; 

SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, impt_fac, iva_fac, edo_fac, frf_fac, srf_fac, cia_fac, pla_fac, impr_fac, tdoc_fac, faccer_fac
FROM 	factura,cliente
WHERE 	numcte_fac = num_cte
		AND fec_fac BETWEEN '2024-01-01' AND '2024-01-31'
		AND tdoc_fac = 'I'
		

SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, impt_fac, iva_fac, edo_fac, frf_fac, srf_fac, cia_fac, pla_fac, impr_fac, tdoc_fac, faccer_fac
FROM 	factura,cliente
WHERE 	numcte_fac = num_cte
		AND fec_fac BETWEEN '2024-01-01' AND '2024-01-31'
		AND tdoc_fac = 'I'
		and frf_fac is not null