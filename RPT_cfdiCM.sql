EXECUTE PROCEDURE RPT_cfdiCM('2025-01-01','2025-01-31','F');
EXECUTE PROCEDURE RPT_cfdiCM('2025-01-01','2025-01-31','N');

DROP PROCEDURE RPT_cfdiCM;
CREATE PROCEDURE RPT_cfdiCM
(
	paramFecIni	DATE,
	paramFecFin	DATE,
	paramTipo	CHAR(1)
)

RETURNING  
 CHAR(40),		-- UUID
 CHAR(2), 		-- TIPO RELACION CHAR(40), 		-- UUID RELACIONADO
 CHAR(13),		-- RFC
 INT,			-- FOLIO
 CHAR(4),		-- SERIE
 DATE,			-- FECHA
 DECIMAL, 		-- BASE 
 DECIMAL,		-- IVA
 DECIMAL,		-- TOTAL
 CHAR(1),		-- ESTADO
 CHAR(1);		-- TIPO

DEFINE vuuid    CHAR(40);
DEFINE vuuidrel	CHAR(120);
DEFINE vtiprel 	CHAR(2);
DEFINE vrfc		CHAR(13);
DEFINE vfolio 	INT;
DEFINE vserie	CHAR(4);
DEFINE vfecha 	DATE;
DEFINE vbase	DECIMAL(12,2);
DEFINE viva	    DECIMAL(10,2);
DEFINE vimporte DECIMAL(12,2);
DEFINE vtdoc    CHAR(1);
DEFINE vedo     CHAR(1);
DEFINE vimpr    CHAR(1);
DEFINE vdescrel	CHAR(40);
DEFINE vsrffac	CHAR(4);
DEFINE vfrffac 	INT;

LET vdescrel = '' ;

IF paramTipo = 'F' THEN
	FOREACH cFacturas FOR
		/*SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, tdoc_fac, uuid_fac, edo_fac, srf_fac, frf_fac,
				SUM(tlts_dfac * pru_dfac / 1.16) simpt,
				SUM(tlts_dfac * pru_dfac / 1.16 * 0.16) iva	
		INTO    vrfc,vserie,vfolio,vfecha,vtdoc,vuuid,vedo,vsrffac,vfrffac,vbase,viva
		FROM 	factura f, det_fac df
		WHERE 	fec_fac BETWEEN paramFecIni AND paramFecFin
				AND tdoc_fac IN('I','V') 
				AND fol_fac = fol_dfac
				and ser_fac = ser_dfac
		GROUP BY 1,2,3,4,5,6,7,8,9
		ORDER BY fec_fac, ser_fac*/
		
		SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, tdoc_fac, uuid_fac, edo_fac, srf_fac, frf_fac,
				simp_fac,iva_fac, impt_fac	
		INTO    vrfc,vserie,vfolio,vfecha,vtdoc,vuuid,vedo,vsrffac,vfrffac,vbase,viva,vimporte
		FROM 	factura f
		WHERE 	fec_fac BETWEEN paramFecIni AND paramFecFin
				AND tdoc_fac IN('I','V') 
		ORDER BY fec_fac
		
		--LET	vimporte = vbase + viva;				

		LET vtiprel = '';
		LET vdescrel = '' ;
		LET vuuidrel = '';
		LET vimpr = '1';
		
		IF vedo = 'C' THEN
			LET vimpr = '0';
		END IF;		
		
		IF vfrffac IS NOT NULL AND vfrffac > 0 THEN
			SELECT	uuid_fac, '04'
			INTO	vuuidrel, vtiprel
			FROM	factura
			WHERE	fol_fac = vfrffac AND ser_fac = vsrffac;
			
			IF vtiprel = '04' THEN 
				LET vdescrel = '04 SUSTITUCIÓN DE LOS CFDI PREVIOS' ;
			END IF;			
		END IF;
		
		RETURN 	vuuid,vdescrel,vuuidrel,vrfc,vfolio,vserie,vfecha,vbase,viva,vimporte,vimpr,vtdoc
		WITH RESUME;	
		
	END FOREACH;
ELSE
	IF paramTipo = 'N' THEN		
		FOREACH cNotasCrd FOR
			SELECT 	rfc_ncrd, ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, simp_ncrd,iva_ncrd, tdoc_ncrd, uuid_ncrd, edo_ncrd, frnc_ncrd, srnc_ncrd
			INTO    vrfc,vserie,vfolio,vfecha,vimporte,vbase,viva,vtdoc,vuuid,vedo,vsrffac,vfrffac
			FROM 	nota_crd
			WHERE 	fec_ncrd BETWEEN paramFecIni AND paramFecFin
					AND tdoc_ncrd IN('E','C') 
			ORDER BY fec_ncrd
			
			LET vtiprel = '';
			LET vdescrel = '' ;
			LET vuuidrel = '';
			LET vimpr = '1';
		
			IF vedo = 'C' THEN
				LET vimpr = '0';
			END IF;		
			
			IF vfrffac IS NOT NULL AND vfrffac > 0 THEN
				SELECT	uuid_ncrd, '04'
				INTO	vuuidrel, vtiprel
				FROM	nota_crd
				WHERE	fol_ncrd = vfrffac AND ser_ncrd = vsrffac;
				
				IF vtiprel = '04' THEN 
					LET vdescrel = '04 SUSTITUCIÓN DE LOS CFDI PREVIOS' ;
				END IF;			
			END IF;
			
			RETURN 	vuuid,vdescrel,vuuidrel,vrfc,vfolio,vserie,vfecha,vbase,viva,vimporte,vimpr,vtdoc
			WITH RESUME;	
			
		END FOREACH;
	END IF;
END IF;

END PROCEDURE; 

SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, impt_fac, simp_fac, iva_fac, tdoc_fac, uuid_fac, edo_fac, srf_fac, frf_fac
FROM 	factura f
WHERE 	fec_fac BETWEEN '2025-01-01' AND '2025-01-31'
		AND tdoc_fac IN('I','V') 
ORDER BY fec_fac

SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, tdoc_fac, uuid_fac, edo_fac, srf_fac, frf_fac,
		sum(tlts_dfac * pru_dfac / 1.16) simpt,
		sum(tlts_dfac * pru_dfac / 1.16 * 0.16) iva		
FROM 	factura f, det_fac df
WHERE 	fec_fac BETWEEN '2025-01-01' AND '2025-01-31'
		AND tdoc_fac IN('I','V') 
		AND fol_fac = fol_dfac
		and ser_fac = ser_dfac
		and frf_fac is null
GROUP BY 1,2,3,4,5,6,7,8,9
ORDER BY fec_fac

196733
197458