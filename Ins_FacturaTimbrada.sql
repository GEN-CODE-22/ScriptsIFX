select	*
from	ruta
order by cve_rut
DROP PROCEDURE Ins_FacturaTim;
EXECUTE PROCEDURE Ins_FacturaTim(954047,'EAB',null,null,'D23DFFC2-9EBA-4587-A4D6-47853B3E518B','LP/15322/EXP/ES/2016-');

CREATE PROCEDURE Ins_FacturaTim
(
	paramFolio      	INT,
	paramSerie      	CHAR(4),	
	paramReFolio      	INT,
	paramReSerie   		CHAR(4),	
	paramUuid      		CHAR(40),
	paramCre      		CHAR(40)
)

RETURNING 
 CHAR(1);

DEFINE v_regreso  	CHAR(1);
DEFINE v_cia    	CHAR(2);
DEFINE v_pla    	CHAR(2);
DEFINE v_nocte  	CHAR(6);
DEFINE v_rfc		CHAR(15);
DEFINE v_folioNota	INT;
DEFINE v_ffisNota	INT;
DEFINE v_tpaNota  	CHAR(1);
DEFINE v_tipNota  	CHAR(1);
DEFINE v_tprodNota	CHAR(3);
DEFINE v_tlts		DECIMAL;
DEFINE v_precio		DECIMAL;
DEFINE v_asistencia	DECIMAL;
DEFINE v_subimporte DECIMAL;
DEFINE v_importe 	DECIMAL;
DEFINE v_iva        DECIMAL;
DEFINE v_nsubimp    DECIMAL;
DEFINE v_nimporte 	DECIMAL;
DEFINE v_niva       DECIMAL;
DEFINE v_pcre		CHAR(40);
DEFINE v_nfecha		DATE;
DEFINE v_vuelta		INT;
DEFINE v_countvta	INT;
DEFINE v_fecha		DATETIME YEAR TO MINUTE;
DEFINE v_usr		CHAR(8);
DEFINE v_annio		INT;
DEFINE v_mes		CHAR(2);
DEFINE v_dia		CHAR(2);
DEFINE i			SMALLINT;

LET v_regreso = 'A';
LET i = 1;
LET v_pcre = '';

--REVISA SI HAY NOTAS LIGADAS A LA FACTURA--------------------------------------------------------------------------------------------
select	count(*)
into 	v_countvta
from	nota_vta
where   fac_nvta = paramFolio and ser_nvta = paramSerie;

IF	v_countvta > 0 THEN
	LET v_regreso = 'B';
	FOREACH cNotas FOR
		SELECT  fol_nvta, ffis_nvta, cia_nvta, pla_nvta, numcte_nvta, tip_nvta, tpa_nvta, tlts_nvta, pru_nvta, tprd_nvta, 
				simp_nvta, iva_nvta, impt_nvta, impasi_nvta, vuelta_nvta, fes_nvta
		INTO	v_folioNota, v_ffisNota, v_cia, v_pla, v_nocte, v_tipNota, v_tpaNota, v_tlts, v_precio, v_tprodNota,
				v_nsubimp, v_niva, v_nimporte, v_asistencia, v_vuelta,v_nfecha
		FROM	nota_vta
		WHERE	fac_nvta = paramFolio  and ser_nvta = paramSerie
		
		IF i = 1 THEN
			select	fec_cfd, usr_cfd, rfc_cfd
			into	v_fecha, v_usr,v_rfc
			from	cfd
			where	fol_cfd = paramFolio and ser_cfd = paramSerie;
			
			SELECT  SUM(simp_nvta), SUM(iva_nvta), SUM(impt_nvta)
			INTO	v_subimporte, v_iva, v_importe
			FROM	nota_vta
			WHERE	fac_nvta = paramFolio  and ser_nvta = paramSerie;
			IF	v_tpaNota = 'C' OR v_tpaNota = 'G' THEN
				insert into factura
				values('M',paramFolio,paramSerie,v_cia,v_pla,v_fecha,v_nocte,'C','X','E',v_subimporte,v_iva,v_importe, null, v_usr,null,null,null,null,paramReFolio,paramReSerie,'N','N',v_fecha,'N',null,paramUuid,null,'N','3','I',null,v_rfc,'',null,null);
			ELSE
				insert into factura
				values('M',paramFolio,paramSerie,v_cia,v_pla,v_fecha,v_nocte,'E','P','E',v_subimporte,v_iva,v_importe, null, v_usr,null,null,null,null,paramReFolio,paramReSerie,'N','N',v_fecha,'N',null,paramUuid,null,'N','3','I',null,v_rfc,v_tpaNota,null,null);
			END IF;
			LET v_regreso = 'C';
		END IF;
		LET v_annio = YEAR(v_nfecha) - 2000;
		IF MONTH(v_nfecha) < 10 THEN
			LET v_mes = '0' || MONTH(v_nfecha);
		ELSE
			LET v_mes = MONTH(v_nfecha);
		END IF;
		IF DAY(v_nfecha) < 10 THEN
			LET v_dia = '0' || DAY(v_nfecha);
		ELSE
			LET v_dia = DAY(v_nfecha);
		END IF;
		LET v_pcre = TRIM(paramCre) || v_annio || v_mes || v_dia || v_cia || v_pla || v_folioNota;
		insert into det_fac 
		values(paramFolio,paramSerie,v_cia,v_pla,i,v_tipNota,v_folioNota,v_ffisNota,v_tlts,v_tprodNota,v_precio,null, v_nsubimp, v_asistencia,v_vuelta, v_pcre);
		
		LET i = i + 1;
	END FOREACH; 
END IF;

RETURN 	v_regreso;
END PROCEDURE; 

select	count(*)
from	nota_vta
where   fac_nvta = 950009 and ser_nvta = 'EAB';

SELECT  SUM(simp_nvta), SUM(iva_nvta), SUM(impt_nvta)
FROM	nota_vta
WHERE	fac_nvta = 950009  and ser_nvta = 'EAB';