DROP PROCEDURE vol_qryventa;
EXECUTE PROCEDURE  vol_qryventa('N','E','2022-04-25','2022-04-30','2022-05-01','2022-05-10',18); 
EXECUTE PROCEDURE  vol_qryventa('P','E','2022-04-01','2022-04-30','2022-05-01','2022-05-10',18); 
EXECUTE PROCEDURE  vol_qryventa('C','E','2022-04-01','2022-04-30','2022-05-01','2022-05-10',18); 
EXECUTE PROCEDURE  vol_qryventa('M','E','2022-07-01','2022-07-28','2022-04-01','2022-02-05',18); 
EXECUTE PROCEDURE  vol_qryventa('S','E','2023-07-01','2023-07-31','2022-02-01','2022-02-05',20); 

CREATE PROCEDURE vol_qryventa
(
	paramTipo		CHAR(1),	-- N = Facturas cliente, P = Precierre, C = Cierre, M = Cierre Mensual sin precierre, S = Cierre diario
	paramTipSvr		CHAR(1),	-- E = Estacionario, B = Carburación, C = Cilindro
	paramFecIni 	DATE,
	paramFecFin 	DATE,
	paramFecIniC 	DATE,
	paramFecFinC 	DATE,
	paramIdSvr		INT
)

RETURNING  
 CHAR(1),					-- Tipo de servicio
 CHAR(1),					-- Tipo Pago
 DECIMAL,					-- Litros
 DECIMAL,					-- Importe
 DECIMAL,					-- Precio Unitario
 CHAR(4),					-- Ruta
 INT,						-- Folio Factura
 CHAR(4),					-- Serie Factura
 CHAR(40),					-- Permiso CRE
 DATE,						-- Fecha Surtido
 INT,						-- Folio Nota
 CHAR(40),					-- Folio Fiscal
 DATETIME YEAR TO SECOND,	-- Fecha y Hora Factura
 CHAR(13),					-- RFC
 CHAR(100),					-- Cliente
 CHAR(1),					-- Tipo N = Normal G = Global
 CHAR(1),					-- I = Ingreso
 DECIMAL,                   -- Total Litros Factura
 INT,						-- Id permiso
 INT;						-- Id Servidor

 
DEFINE vtipo 	CHAR(1);
DEFINE vtpa 	CHAR(1);
DEFINE vtlts	DECIMAL;
DEFINE vimpt	DECIMAL;
DEFINE vpru		DECIMAL;
DEFINE vruta 	CHAR(4);
DEFINE vfolfac  INT;
DEFINE vserfac 	CHAR(4);
DEFINE vpcre 	CHAR(40);
DEFINE vfecsur 	DATE;
DEFINE vfolio 	INT;
DEFINE vuuid	CHAR(40);
DEFINE vfyh		DATETIME YEAR TO SECOND;
DEFINE vrfc   	CHAR(13);
DEFINE vcliente	CHAR(100);
DEFINE vtipfac  CHAR(1);
DEFINE vtipcfd	CHAR(1);
DEFINE vtltsfac	DECIMAL;
DEFINE vidpcre  INT;
DEFINE vidsvr   INT;

DEFINE vnocte	CHAR(6);
DEFINE vtipsvr	CHAR(6);
DEFINE vfaccer	CHAR(1);

LET vidsvr = paramIdSvr;
LET vidpcre = 0;

LET vtipsvr = paramTipSvr;
IF paramTipSvr = 'C' THEN
	LET vtipsvr = '[CD234]';
END IF;

IF	paramTipo = 'N' THEN 
	LET vtipfac = 'N';
	LET vtipcfd = 'I';
	FOREACH cNotas FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,fac_nvta,ser_nvta,pcre_rut,fes_nvta,fol_nvta,numcte_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vfolfac,vserfac,vpcre,vfecsur,vfolio,vnocte
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta >= paramFecIni
				and fes_nvta <= paramFecFin
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is not null
				AND edo_nvta = 'A'	
		--ORDER BY fac_nvta, ser_nvta
		
		SELECT  TRIM(uuid_fac),fyh_fac, rfc_fac
		INTO	vuuid,vfyh,vrfc
		FROM 	factura
		WHERE	fol_fac = vfolfac and ser_fac = vserfac;
		
		SELECT  SUM(NVL(tlts_dfac,0))
		INTO	vtltsfac
		FROM 	factura, det_fac
		WHERE	fol_fac = vfolfac and ser_fac = vserfac
				and fol_fac = fol_dfac and ser_fac = ser_dfac;
		
		SELECT  CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(NVL(razsoc_cte,''))	ELSE TRIM(NVL(nom_cte,''))||' '|| TRIM(NVL(ape_cte,'')) end 
		INTO	vcliente
		FROM    cliente 
		WHERE 	num_cte = vnocte;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vidpcre,vidsvr
		WITH RESUME;
	END FOREACH;
END IF;

IF	paramTipo = 'P' THEN 
	LET vrfc = 'XAXX010101000';
	LET vcliente = 'PUBLICO EN GENERAL';
	LET vtipfac = 'G';
	LET vtipcfd = 'I';
	
	SELECT  fol_fac, ser_fac,TRIM(uuid_fac),fyh_fac
	INTO	vfolfac,vserfac,vuuid,vfyh
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac = paramFecFin
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	SELECT  SUM(NVL(tlts_dfac,0))
	INTO	vtltsfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac = paramFecFin
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	FOREACH cNotasP FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,pru_nvta,impt_nvta,ruta_nvta,pcre_rut,fes_nvta,fol_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vpcre,vfecsur,vfolio
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta >= paramFecIni
				and fes_nvta < paramFecFin
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is null
				AND edo_nvta = 'A'
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vidpcre,vidsvr
		WITH RESUME;
	END FOREACH;
END IF;

IF	paramTipo = 'C' THEN 
	LET vrfc = 'XAXX010101000';
	LET vcliente = 'PUBLICO EN GENERAL';
	LET vtipfac = 'G';
	LET vtipcfd = 'I';
	
	SELECT  fol_fac, ser_fac,TRIM(uuid_fac),fyh_fac
	INTO	vfolfac,vserfac,vuuid,vfyh
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	SELECT  SUM(NVL(tlts_dfac,0))
	INTO	vtltsfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	FOREACH cNotasC FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,pcre_rut,fes_nvta,fol_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vpcre,vfecsur,vfolio
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta = paramFecFin
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is null
				AND edo_nvta = 'A'
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vidpcre,vidsvr
		WITH RESUME;
	END FOREACH;
END IF;

	
IF	paramTipo = 'M' THEN 
	LET vrfc = 'XAXX010101000';
	LET vcliente = 'PUBLICO EN GENERAL';
	LET vtipfac = 'G';
	LET vtipcfd = 'I';
	
	SELECT  fol_fac, ser_fac,TRIM(uuid_fac),fyh_fac
	INTO	vfolfac,vserfac,vuuid,vfyh
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	SELECT  SUM(NVL(tlts_dfac,0))
	INTO	vtltsfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
				
	FOREACH cNotasM FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,pcre_rut,fes_nvta,fol_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vpcre,vfecsur,vfolio
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta >= paramFecIni
				and fes_nvta <= paramFecFin
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is null
				AND edo_nvta = 'A'
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vidpcre,vidsvr
		WITH RESUME;
	END FOREACH;
END IF;


IF	paramTipo = 'S' THEN 
	
	FOREACH cNotasS FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,fac_nvta,ser_nvta,pcre_rut,fes_nvta,fol_nvta,numcte_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vfolfac,vserfac,vpcre,vfecsur,vfolio,vnocte
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta >= paramFecIni
				and fes_nvta <= paramFecFin
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is not null
				AND edo_nvta = 'A'	
		ORDER BY fac_nvta, ser_nvta
		
		SELECT  TRIM(uuid_fac),fyh_fac, rfc_fac, faccer_fac
		INTO	vuuid,vfyh,vrfc,vfaccer
		FROM 	factura
		WHERE	fol_fac = vfolfac and ser_fac = vserfac;
		
		IF 	vfaccer = 'S' THEN
			LET vrfc = 'XAXX010101000';
			LET vcliente = 'PUBLICO EN GENERAL';
			LET vtipfac = 'G';
			LET vtipcfd = 'I';
		ELSE
			SELECT  CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(NVL(razsoc_cte,''))	ELSE TRIM(NVL(nom_cte,''))||' '|| TRIM(NVL(ape_cte,'')) end 
			INTO	vcliente
			FROM    cliente 
			WHERE 	num_cte = vnocte;
			LET vtipfac = 'N';
			LET vtipcfd = 'I';
		END IF;	

		SELECT  SUM(NVL(tlts_dfac,0))
		INTO	vtltsfac
		FROM 	factura, det_fac
		WHERE	fol_fac = vfolfac and ser_fac = vserfac
				and fol_fac = fol_dfac and ser_fac = ser_dfac;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vidpcre,vidsvr
		WITH RESUME;
	END FOREACH;
END IF;

END PROCEDURE; 

select max(fes_nvta)
from   znota_vta

SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,fac_nvta,ser_nvta,pcre_rut,fes_nvta,fol_nvta,numcte_nvta
FROM 	znota_vta,ruta 
WHERE 	fes_nvta >= '2022-04-01'
		and fes_nvta <= '2022-04-30'
		and tip_nvta MATCHES 'E' 
		and ruta_nvta = cve_rut
		and (aju_nvta is null or aju_nvta = "")
		AND fac_nvta is not null
		AND edo_nvta = 'A'	
ORDER BY fac_nvta, ser_nvta

SELECT	count(*)
FROM 	znota_vta n
WHERE	fes_nvta between '2022-01-01' and '2022-01-07' AND edo_nvta = 'A' 				
		AND tip_nvta IN('B')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is not null

SELECT	count(*)
FROM 	znota_vta n
WHERE	fes_nvta between  '2022-03-01' and '2022-03-31' AND edo_nvta = 'A' 				
		AND tip_nvta IN('E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null	
		
SELECT	count(*)
FROM 	znota_vta n
WHERE	fes_nvta between '2022-04-01' and '2022-04-30' AND edo_nvta = 'A' 				
		AND tip_nvta IN('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null

select 	*
from 	znota_vta

select 	*
from 	ruta where pcre_rut = 'LP/23615/DIST/PLA/2020'
where 	cve_rut = 'B040'

B056   116
BG08
H002
ME01
ME50
ME03
ME73
CE30
CE88
BE01
DE01
HE01
CE52

SELECT	count(*)
FROM 	znota_vta n
WHERE	fes_nvta between '2022-01-01' and '2022-04-30' AND edo_nvta = 'A' 	
		and ruta_nvta in('BG08','H002','ME01','ME50','ME03','ME73','CE30','CE88','BE01','DE01','HE01','CE52')


