EXECUTE PROCEDURE RPT_NCRepCM('2023-08-01','2023-08-31','T');
EXECUTE PROCEDURE RPT_NCRepCM('2023-08-01','2023-08-31','R');

DROP PROCEDURE RPT_NCRepCM;
CREATE PROCEDURE RPT_NCRepCM
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
DEFINE vfolnc 	INT;
DEFINE vfecnc 	DATE;
DEFINE vimporte DECIMAL;
DEFINE viva	    DECIMAL;
DEFINE vimpr    CHAR(1);
DEFINE vtdoc    CHAR(1);
DEFINE vfrnc	INT;
DEFINE vsrnc  	CHAR(4);
DEFINE vedo     CHAR(1);
DEFINE vcia     CHAR(2);
DEFINE vpla     CHAR(2);
DEFINE vuuid    CHAR(40);

IF paramTipo = 'T' THEN
	FOREACH cFacturas FOR
		SELECT 	rfc_ncrd, ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, iva_ncrd, edo_ncrd, frnc_ncrd, srnc_ncrd, cia_ncrd, pla_ncrd, impr_ncrd, tdoc_ncrd, uuid_ncrd
		INTO    vrfc,vserie,vfolnc,vfecnc,vimporte,viva,vedo,vfrnc,vsrnc,vcia,vpla,vimpr,vtdoc,vuuid
		FROM 	nota_crd,cliente
		WHERE 	numcte_ncrd = num_cte
				AND fec_ncrd BETWEEN paramFecIni AND paramFecFin
		UNION
		SELECT 	" ", ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, iva_ncrd, edo_ncrd, 0, " ", cia_ncrd, pla_ncrd, impr_ncrd, tdoc_ncrd, uuid_ncrd			
		FROM 	nota_crd
		WHERE 	numcte_ncrd IS NULL
				AND fec_ncrd BETWEEN paramFecIni AND paramFecFin
		ORDER BY 13,2,3 	
		
		LET vimpr = '1';
	
	    IF vedo = 'C' THEN
			LET vimporte = 0;
			LET viva = 0;
			LET vimpr = '0';
		END IF;
	
		RETURN 	vrfc,vserie,vfolnc,vfecnc,vimporte,viva,vimpr,vtdoc,vuuid
		WITH RESUME;
		
		IF vfrnc IS NOT NULL AND vfrnc > 0 THEN
			LET vimporte = vimporte * -1;
			LET viva = viva * -1;
			LET vimpr = '0';
			
			SELECT 	rfc_ncrd,ser_ncrd,fol_ncrd,fec_ncrd,tdoc_ncrd,uuid_ncrd
            INTO 	vrfc,vserie,vfolnc,vfecnc,vtdoc,vuuid
            FROM    nota_crd
            WHERE   fol_ncrd = vfrnc AND ser_ncrd = vsrnc;
           
			RETURN 	vrfc,vserie,vfolnc,vfecnc,vimporte,viva,vimpr,vtdoc,vuuid
			WITH RESUME;			
		END IF;
	END FOREACH;
ELSE
	IF paramTipo = 'R' THEN
		FOREACH cFacturas FOR
			SELECT 	rfc_ncrd, ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, iva_ncrd, edo_ncrd, frnc_ncrd, srnc_ncrd, cia_ncrd, pla_ncrd, impr_ncrd, tdoc_ncrd,uuid_ncrd
			INTO    vrfc,vserie,vfolnc,vfecnc,vimporte,viva,vedo,vfrnc,vsrnc,vcia,vpla,vimpr,vtdoc,vuuid
			FROM 	nota_crd,cliente
			WHERE 	numcte_ncrd = num_cte
					AND fec_ncrd BETWEEN paramFecIni AND paramFecFin
					AND frnc_ncrd IS NOT NULL
			UNION
			SELECT 	" ", ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, iva_ncrd, edo_ncrd, 0, " ", cia_ncrd, pla_ncrd, impr_ncrd, tdoc_ncrd, uuid_ncrd			
			FROM 	nota_crd
			WHERE 	numcte_ncrd IS NULL
					AND fec_ncrd BETWEEN paramFecIni AND paramFecFin
					AND frnc_ncrd IS NOT NULL
			ORDER BY 13,2,3 	
			
			LET vimpr = '1';			
			
			RETURN 	vrfc,vserie,vfolnc,vfecnc,vimporte,viva,vimpr,vtdoc,vuuid
			WITH RESUME;
			
			SELECT 	rfc_ncrd,ser_ncrd,fol_ncrd,fec_ncrd,tdoc_ncrd,uuid_ncrd
            INTO 	vrfc,vserie,vfolnc,vfecnc,vtdoc,vuuid
            FROM    nota_crd
            WHERE   fol_ncrd = vfrnc AND ser_ncrd = vsrnc;
			LET vimpr = '0';
			LET viva = viva * -1;
		    LET vimporte = vimporte * -1;
			LET vimpr = '0';	
			RETURN 	vrfc,vserie,vfolnc,vfecnc,vimporte,viva,vimpr,vtdoc,vuuid
			WITH RESUME;

		END FOREACH;
	END IF;
END IF;

END PROCEDURE; 

SELECT 	rfc_ncrd, ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, iva_ncrd, edo_ncrd, frnc_ncrd, srnc_ncrd, cia_ncrd, pla_ncrd, impr_ncrd, tdoc_ncrd
FROM 	nota_crd,cliente
WHERE 	numcte_ncrd = num_cte
		AND fec_ncrd BETWEEN '2024-01-01' AND '2024-01-31'
		
SELECT 	rfc_ncrd, ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, iva_ncrd, edo_ncrd, frnc_ncrd, srnc_ncrd, cia_ncrd, pla_ncrd, impr_ncrd, tdoc_ncrd
FROM 	nota_crd,cliente
WHERE 	numcte_ncrd = num_cte
		AND fec_ncrd BETWEEN '2024-01-01' AND '2024-01-31'
		and frnc_ncrd is not null
