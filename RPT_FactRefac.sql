EXECUTE PROCEDURE RPT_FactRefac('2024-11-01','2024-11-30','F');
EXECUTE PROCEDURE RPT_FactRefac('2024-11-01','2024-11-30','N');

DROP PROCEDURE RPT_FactRefac;
CREATE PROCEDURE RPT_FactRefac
(
	paramFecIni	DATE,
	paramFecFin	DATE,
	paramTipo	CHAR(1)
)

RETURNING  
 CHAR(10),
 CHAR(2), 
 CHAR(40), 
 CHAR(120),  
 CHAR(13),
 CHAR(4),
 INT,
 DATE,
 DECIMAL, 
 DECIMAL,
 CHAR(1),
 CHAR(1),
 CHAR(40),
 CHAR(60);

DEFINE vedosat  CHAR(10);
DEFINE vtiprel 	CHAR(2);
DEFINE vdescrel	CHAR(40);
DEFINE vuuidrel	CHAR(120);
DEFINE vuuidrlo	CHAR(120);
DEFINE vrfc		CHAR(13);
DEFINE vserie	CHAR(4);
DEFINE vfolfac 	INT;
DEFINE vfolpub 	INT;
DEFINE vsrffac	CHAR(4);
DEFINE vfrffac 	INT;
DEFINE vfecfac 	DATE;
DEFINE vimporte DECIMAL;
DEFINE viva	    DECIMAL;
DEFINE vie      CHAR(1);
DEFINE vtdoc    CHAR(1);
DEFINE vuuid    CHAR(40);
DEFINE vobserv  CHAR(60);

LET vdescrel = '' ;

IF paramTipo = 'F' THEN
	LET vobserv = 'REFACTURACIÓN A CLIENTE';
	LET vedosat = 'VIGENTE';
	LET vie = '1';
	FOREACH cFacturas FOR
		SELECT 	rfc_fac, ser_fac, fol_fac, fec_fac, impt_fac, iva_fac, tdoc_fac, uuid_fac, srf_fac, frf_fac
		INTO    vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vtdoc,vuuid,vsrffac,vfrffac
		FROM 	factura
		WHERE 	fec_fac BETWEEN paramFecIni AND paramFecFin
				AND tdoc_fac = 'I' AND edo_fac <> 'C'
				AND frf_fac in(select fol_fac from factura where faccer_fac = 'S')
				
		SELECT	uuid_fac, '04'
		INTO	vuuidrel, vtiprel
		FROM	factura
		WHERE	fol_fac = vfrffac AND ser_fac = vsrffac;
		
		IF vtiprel = '04' THEN 
			LET vdescrel = '04 SUSTITUCIÓN DE LOS CFDI PREVIOS' ;
		END IF;
		
		RETURN 	vedosat,vtiprel,vdescrel,vuuidrel,vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vie,vtdoc,vuuid,vobserv
		WITH RESUME;	
		
	END FOREACH;
ELSE
	IF paramTipo = 'N' THEN
		LET vobserv = 'NOTA DE CRÉDITO RELACIONADA A PÚBLICO EN GENERAL';
		LET vedosat = 'VIGENTE';
		LET vie = '1';
			
		FOREACH cNotasCrd FOR
			SELECT 	rfc_ncrd, ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, iva_ncrd, tdoc_ncrd, uuid_ncrd
			INTO    vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vtdoc,vuuid
			FROM 	nota_crd
			WHERE 	fec_ncrd BETWEEN paramFecIni AND paramFecFin
					AND tdoc_ncrd = 'C' AND edo_ncrd <> 'C'
			LET vfolpub = 0;
			LET vuuidrlo  = '';
			FOREACH cNotasCrd FOR
				SELECT	fac_dncrd, serf_dncrd
				INTO	vfrffac,vsrffac
				FROM	det_ncrd
				WHERE	fol_dncrd = vfolfac and ser_dncrd = vserie
				
				IF vfrffac <> vfolpub 	THEN
					SELECT	uuid_fac, '01'
					INTO	vuuidrel, vtiprel
					FROM	factura
					WHERE	fol_fac = vfrffac AND ser_fac = vsrffac;
					
					IF vuuidrlo = '' THEN
						LET vuuidrlo = vuuidrel;
					ELSE
						LET vuuidrlo = ',' || vuuidrel;
					END IF;
				END IF;
				LET vfolpub = vfrffac;
				
			END FOREACH;
			
			IF vtiprel = '01' THEN 
				LET vdescrel = '01 NOTA DE CRÉDITO DE LOS DOCUMENTOS RELACIONADOS' ;
			END IF;
			
			LET vuuidrel = TRIM(vuuidrlo);
			
			RETURN 	vedosat,vtiprel,vdescrel,vuuidrel,vrfc,vserie,vfolfac,vfecfac,vimporte,viva,vie,vtdoc,vuuid,vobserv
			WITH RESUME;	
			
		END FOREACH;
	END IF;
END IF;

END PROCEDURE; 

SELECT 	feccan_fac, rfc_fac, ser_fac, fol_fac, fec_fac, impt_fac, iva_fac, edo_fac, tdoc_fac, uuid_fac, srf_fac, frf_fac
FROM 	factura,cliente
WHERE 	fec_fac BETWEEN '2024-11-01' AND '2024-11-30'
		AND tdoc_fac = 'I'
		AND frf_fac in(select fol_fac from factura where faccer_fac = 'S')
		
SELECT 	rfc_ncrd, ser_ncrd, fol_ncrd, fec_ncrd, impt_ncrd, iva_ncrd, tdoc_ncrd, uuid_ncrd
FROM 	nota_crd
WHERE 	fec_ncrd BETWEEN '2024-11-01' AND '2024-11-30'
					AND tdoc_ncrd = 'C' AND edo_ncrd <> 'C'
		
select	*
from	nota_crd  
where	fec_ncrd BETWEEN '2024-11-01' AND '2024-11-30'
		AND tdoc_ncrd = 'C' AND edo_ncrd <> 'C'
		
select	*
from	det_ncrd 
where	fol_dncrd = 5244 and ser_dncrd = 'CAB'
		