DROP PROCEDURE vol_qryventa;
--PRECIERRE Y CIERRE -----------------------------------------------------------
EXECUTE PROCEDURE  vol_qryventa('N','E','2022-01-01','2022-01-02','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('P','E','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('C','E','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('N','B','2022-01-01','2022-01-02','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('P','B','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('C','B','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('N','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('P','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('C','C','2022-02-01','2022-02-28','2022-03-01','2022-03-10',18); 
EXECUTE PROCEDURE  vol_qryventa('T','T','2022-04-01','2022-04-30','2022-05-01','2022-05-10',18); 
EXECUTE PROCEDURE  vol_qryventa('A','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('D','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('F','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('I','C','2022-01-01','2022-01-01','2022-02-01','2022-02-10',18); 
--CIERRE -----------------------------------------------------------
EXECUTE PROCEDURE  vol_qryventa('N','E','2022-01-01','2022-01-02','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('M','E','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('N','B','2022-01-01','2022-01-02','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('M','B','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('N','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('M','C','2022-02-01','2022-02-28','2022-03-01','2022-03-10',18); 
EXECUTE PROCEDURE  vol_qryventa('T','T','2022-04-01','2022-04-30','2022-05-01','2022-05-10',18); 
EXECUTE PROCEDURE  vol_qryventa('A','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('D','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('F','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('I','C','2022-01-01','2022-01-01','2022-02-01','2022-02-10',18); 
--CIERRE DIARIO-----------------------------------------------------------
EXECUTE PROCEDURE  vol_qryventa('S','E','2022-01-01','2022-01-02','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('S','B','2022-01-01','2022-01-02','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('S','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('T','T','2022-04-01','2022-04-30','2022-05-01','2022-05-10',18); 
EXECUTE PROCEDURE  vol_qryventa('A','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('D','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('F','C','2022-01-01','2022-01-31','2022-02-01','2022-02-10',18); 
EXECUTE PROCEDURE  vol_qryventa('I','C','2022-01-01','2022-01-01','2022-02-01','2022-02-10',18); 


CREATE PROCEDURE vol_qryventa
(
	paramTipo		CHAR(1),	-- N = Facturas cliente, P = Precierre, C = Cierre, M = Cierre Mensual sin precierre, S = Cierre diario, T = Traslados
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
 CHAR(1),					-- Tipo Ruta
 INT,						-- Folio Factura
 CHAR(4),					-- Serie Factura
 --CHAR(40),				-- Permiso CRE
 DATE,						-- Fecha Surtido
 INT,						-- Folio Nota
 CHAR(1),					-- Uso nota venta
 DATETIME YEAR TO SECOND,	-- Fecha y Hora Nota
 CHAR(40),					-- Folio Fiscal
 DATETIME YEAR TO SECOND,	-- Fecha y Hora Factura
 CHAR(13),					-- RFC
 CHAR(100),					-- Cliente
 CHAR(1),					-- Tipo N = Normal G = Global
 CHAR(1),					-- I = Ingreso
 DECIMAL,                   -- Total Litros Factura
 DECIMAL,                   -- Importe factura
 INT,						-- Id permiso 
 INT,						-- Id Servidor
 INT,						-- Id permiso Destino
 DECIMAL;					-- Kilos a litros

 
DEFINE vtipo 	CHAR(1);
DEFINE vtpa 	CHAR(1);
DEFINE vtlts	DECIMAL;
DEFINE vimpt	DECIMAL;
DEFINE vpru		DECIMAL;
DEFINE vruta 	CHAR(4);
DEFINE vtiprut 	CHAR(1);
DEFINE vfolfac  INT;
DEFINE vserfac 	CHAR(4);
DEFINE vpcre 	CHAR(40);
DEFINE vpcred 	CHAR(40);
DEFINE vfecsur 	DATE;
DEFINE vfolio 	INT;
DEFINE vuso 	CHAR(1);
DEFINE vfyhn	DATETIME YEAR TO SECOND;
DEFINE vuuid	CHAR(40);
DEFINE vfyh		DATETIME YEAR TO SECOND;
DEFINE vrfc   	CHAR(13);
DEFINE vcliente	CHAR(100);
DEFINE vtipfac  CHAR(1);
DEFINE vtipcfd	CHAR(1);
DEFINE vtltsfac	DECIMAL;
DEFINE vimptfac	DECIMAL;
DEFINE vidpcre  INT;
DEFINE vidsvr   INT;
DEFINE vidpcred INT;
DEFINE vtkgs	DECIMAL;
DEFINE vtkgspre	DECIMAL;

DEFINE vnocte	CHAR(6);
DEFINE vtipsvr	CHAR(6);
DEFINE vfaccer	CHAR(1);
DEFINE vcia		CHAR(2);
DEFINE vpla		CHAR(2);
DEFINE vvuelta	INT;
DEFINE vtotvand	DECIMAL;
DEFINE vnvtvand	DECIMAL;
DEFINE vtkgsvand	DECIMAL;
DEFINE vnkgvand	DECIMAL;
DEFINE vfecvta  DECIMAL;
DEFINE vltsfac	DECIMAL;
DEFINE vtkgsfac  DECIMAL;
DEFINE vconkl  DECIMAL;

LET vidsvr = paramIdSvr;
LET vidpcre = 0;
LET vidpcred = 0;
LET vconkl = 0.54;

LET vtipsvr = paramTipSvr;
IF paramTipSvr = 'C' THEN
	LET vtipsvr = '[CD234]';
END IF;

--NOTAS DEL MES(SE EJECUTA SIEMPRE) -----------------------------------------------------------
IF	paramTipo = 'N' THEN 
	LET vtipfac = 'N';
	LET vtipcfd = 'I';
	FOREACH cNotas FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,ruta_nvta[1],fac_nvta,ser_nvta,pcre_rut,fes_nvta,fol_nvta,NVL(uso_nvta,''),numcte_nvta,
				cia_nvta,pla_nvta,vuelta_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vnocte,vcia,vpla,vvuelta
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta >= paramFecIni
				and fes_nvta <= paramFecFin
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is not null
				AND edo_nvta = 'A'	
				AND tlts_nvta > 0
				 
		--ORDER BY fac_nvta, ser_nvta
		LET vtkgs = vtlts;
		IF	paramTipSvr = 'C' THEN
			LET vtlts = vtkgs / vconkl;
		END IF;
		
		SELECT  TRIM(uuid_fac),fyh_fac, rfc_fac, impt_fac
		INTO	vuuid,vfyh,vrfc,vimptfac
		FROM 	factura
		WHERE	fol_fac = vfolfac and ser_fac = vserfac;
		
		LET vltsfac = 0;
		LET vtkgsfac = 0;
		
		SELECT  NVL(SUM(tlts_dfac),0)
		INTO	vltsfac
		FROM 	factura, det_fac
		WHERE	fol_fac = vfolfac and ser_fac = vserfac
				and fol_fac = fol_dfac and ser_fac = ser_dfac
				and tid_dfac NOT IN('C','D','2','3','4');
				
		SELECT  NVL(SUM(tlts_dfac),0)
		INTO	vtkgsfac
		FROM 	factura, det_fac
		WHERE	fol_fac = vfolfac and ser_fac = vserfac
				and fol_fac = fol_dfac and ser_fac = ser_dfac
				and tid_dfac IN('C','D','2','3','4');
				
		IF vtkgsfac > 0 THEN
			LET vtkgsfac = vtkgsfac / vconkl;
		END IF;
				
		LET  vtltsfac = vltsfac + vtkgsfac;
		
		SELECT  CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(NVL(razsoc_cte,''))	ELSE TRIM(NVL(nom_cte,''))||' '|| TRIM(NVL(ape_cte,'')) end 
		INTO	vcliente
		FROM    cliente 
		WHERE 	num_cte = vnocte;
		
		SELECT	MAX(fhs_mnvta)
		INTO	vfyhn
		FROM	hmovxnvta
		WHERE	cia_mnvta = vcia
			    AND  pla_mnvta = vpla
			    AND  fol_mnvta = vfolio
			    AND  vuelta_mnvta = vvuelta;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		--RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
		WITH RESUME;
	END FOREACH;
END IF;

--NOTAS DEL MES(SE EJECUTA SOLO PARA PRECIERRE Y CIERRE) -----------------------------------------------------------
IF	paramTipo = 'P' THEN 
	LET vrfc = 'XAXX010101000';
	LET vcliente = 'PUBLICO EN GENERAL';
	LET vtipfac = 'G';
	LET vtipcfd = 'I';
	
	SELECT  fol_fac, ser_fac,TRIM(uuid_fac),fyh_fac, impt_fac
	INTO	vfolfac,vserfac,vuuid,vfyh,vimptfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac = paramFecFin
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	SELECT  NVL(SUM(tlts_dfac),0)
	INTO	vtltsfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac = paramFecFin
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
	
	IF paramTipSvr = 'C' AND vtltsfac > 0 THEN
		LET vtltsfac = vtltsfac / vconkl;
	END IF;
			
	FOREACH cNotasP FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,ruta_nvta[1],pcre_rut,fes_nvta,fol_nvta,NVL(uso_nvta,''),
				cia_nvta,pla_nvta,vuelta_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vpcre,vfecsur,vfolio,vuso,vcia,vpla,vvuelta
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta >= paramFecIni
				and fes_nvta < paramFecFin				
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is null
				AND edo_nvta = 'A'
				AND tlts_nvta > 0
		
		LET vtkgs = vtlts;
		IF	paramTipSvr = 'C' THEN
			LET vtlts = vtkgs / vconkl;
		END IF;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);

		SELECT	MAX(fhs_mnvta)
		INTO	vfyhn
		FROM	hmovxnvta
		WHERE	cia_mnvta = vcia
			    AND  pla_mnvta = vpla
			    AND  fol_mnvta = vfolio
			    AND  vuelta_mnvta = vvuelta;		
		
		--RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
		WITH RESUME;
	END FOREACH;
END IF;

--NOTAS DEL MES(SE EJECUTA SOLO PARA PRECIERRE Y CIERRE) -----------------------------------------------------------
IF	paramTipo = 'C' THEN 
	LET vrfc = 'XAXX010101000';
	LET vcliente = 'PUBLICO EN GENERAL';
	LET vtipfac = 'G';
	LET vtipcfd = 'I';
	
	SELECT  fol_fac, ser_fac,TRIM(uuid_fac),fyh_fac, impt_fac
	INTO	vfolfac,vserfac,vuuid,vfyh,vimptfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	SELECT  NVL(SUM(tlts_dfac),0)
	INTO	vtltsfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	IF paramTipSvr = 'C' AND vtltsfac > 0 THEN
		LET vtltsfac = vtltsfac / vconkl;
	END IF;
	
	FOREACH cNotasC FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,ruta_nvta[1],pcre_rut,fes_nvta,fol_nvta,NVL(uso_nvta,''),
				cia_nvta,pla_nvta,vuelta_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vpcre,vfecsur,vfolio,vuso,vcia,vpla,vvuelta
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta = paramFecFin				
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is null
				AND edo_nvta = 'A'
				AND tlts_nvta > 0
		
		LET vtkgs = vtlts;
		IF	paramTipSvr = 'C' THEN
			LET vtlts = vtkgs / vconkl;
		END IF;
		
		SELECT	MAX(fhs_mnvta)
		INTO	vfyhn
		FROM	hmovxnvta
		WHERE	cia_mnvta = vcia
			    AND  pla_mnvta = vpla
			    AND  fol_mnvta = vfolio
			    AND  vuelta_mnvta = vvuelta;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		--RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
		WITH RESUME;
	END FOREACH;
END IF;

--NOTAS DEL MES(SE EJECUTA SOLO PARA CIERRE) -----------------------------------------------------------
IF	paramTipo = 'M' THEN 
	LET vrfc = 'XAXX010101000';
	LET vcliente = 'PUBLICO EN GENERAL';
	LET vtipfac = 'G';
	LET vtipcfd = 'I';
	
	SELECT  fol_fac, ser_fac,TRIM(uuid_fac),fyh_fac,impt_fac
	INTO	vfolfac,vserfac,vuuid,vfyh,vimptfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	SELECT  NVL(SUM(tlts_dfac),0)
	INTO	vtltsfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	IF paramTipSvr = 'C' AND vtltsfac > 0 THEN
		LET vtltsfac = vtltsfac / vconkl;
	END IF;
				
	FOREACH cNotasM FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,ruta_nvta[1],pcre_rut,fes_nvta,fol_nvta,NVL(uso_nvta,''),
				cia_nvta,pla_nvta,vuelta_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vpcre,vfecsur,vfolio,vuso,vcia,vpla,vvuelta
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta >= paramFecIni
				and fes_nvta <= paramFecFin
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is null
				AND edo_nvta = 'A'
				AND tlts_nvta > 0
				
		LET vtkgs = vtlts;
		IF	paramTipSvr = 'C' THEN
			LET vtlts = vtkgs / vconkl;
		END IF;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		SELECT	MAX(fhs_mnvta)
		INTO	vfyhn
		FROM	hmovxnvta
		WHERE	cia_mnvta = vcia
			    AND  pla_mnvta = vpla
			    AND  fol_mnvta = vfolio
			    AND  vuelta_mnvta = vvuelta;
		
		--RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
		WITH RESUME;
	END FOREACH;
END IF;

--NOTAS DEL MES(SE EJECUTA SOLO PARA CIERRE DIARIO) -----------------------------------------------------------
IF	paramTipo = 'S' THEN 
	
	FOREACH cNotasS FOR	
		SELECT 	tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,ruta_nvta[1],fac_nvta,ser_nvta,pcre_rut,fes_nvta,fol_nvta,NVL(uso_nvta,''),numcte_nvta,
				cia_nvta,pla_nvta,vuelta_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vnocte,vcia,vpla,vvuelta
		FROM 	znota_vta,ruta 
		WHERE 	fes_nvta >= paramFecIni
				and fes_nvta <= paramFecFin
				and tip_nvta MATCHES vtipsvr 
				and ruta_nvta = cve_rut
				and (aju_nvta is null or aju_nvta = "")
				AND fac_nvta is not null
				AND edo_nvta = 'A'	
				AND tlts_nvta > 0
		ORDER BY fac_nvta, ser_nvta
		
		LET vtkgs = vtlts;
		IF	paramTipSvr = 'C' THEN
			LET vtlts = vtkgs / vconkl;
		END IF;
		
		SELECT  TRIM(uuid_fac),fyh_fac, rfc_fac, faccer_fac, impt_fac
		INTO	vuuid,vfyh,vrfc,vfaccer,vimptfac
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

		/*SELECT  SUM(NVL(tlts_dfac,0))
		INTO	vtltsfac
		FROM 	factura, det_fac
		WHERE	fol_fac = vfolfac and ser_fac = vserfac
				and fol_fac = fol_dfac and ser_fac = ser_dfac;*/
		
		LET vltsfac = 0;
		LET vtkgsfac = 0;
		
		SELECT  NVL(SUM(tlts_dfac),0)
		INTO	vltsfac
		FROM 	factura, det_fac
		WHERE	fol_fac = vfolfac and ser_fac = vserfac
				and fol_fac = fol_dfac and ser_fac = ser_dfac
				and tid_dfac NOT IN('C','D','2','3','4');
				
		SELECT  NVL(SUM(tlts_dfac),0)
		INTO	vtkgsfac
		FROM 	factura, det_fac
		WHERE	fol_fac = vfolfac and ser_fac = vserfac
				and fol_fac = fol_dfac and ser_fac = ser_dfac
				and tid_dfac IN('C','D','2','3','4');
				
		IF vtkgsfac > 0 THEN
			LET vtkgsfac = vtkgsfac / vconkl;
		END IF;
				
		LET  vtltsfac = vltsfac + vtkgsfac;
				
		SELECT	MAX(fhs_mnvta)
		INTO	vfyhn
		FROM	hmovxnvta
		WHERE	cia_mnvta = vcia
			    AND  pla_mnvta = vpla
			    AND  fol_mnvta = vfolio
			    AND  vuelta_mnvta = vvuelta;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);	
		
		--RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
		WITH RESUME;
	END FOREACH;
END IF;

-- TRASLADO NOTAS DEL MES(SE EJECUTA SIEMPRE) -----------------------------------------------------------
IF	paramTipo = 'T' THEN 
	LET vrfc = 'GEN700527K14';
	LET vcliente = 'GAS EXPRESS NIETO';
	LET vtipfac = 'T';
	LET vtipcfd = 'T';
	LET vimptfac = 0;
	LET vtkgs = 0;
	FOREACH cNotasT FOR	
		SELECT	n.tip_nvta,n.tpa_nvta,n.tlts_nvta,n.impt_nvta,n.pru_nvta,n.ruta_nvta,ruta_nvta[1], NVL(ep.ffac_erup,0), NVL(ep.sfac_erup,''), r.pcre_rut, 
				n.fes_nvta, n.fol_nvta, n.uso_nvta, ep.tot_erup,a.permiso_alm,cia_nvta,pla_nvta,vuelta_nvta
		INTO	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vtltsfac,vpcred,vcia,vpla,vvuelta
		FROM	znota_vta n,
				empxrutp ep,
				ruta r,
				fuente.almacen a
		WHERE
			   tip_nvta MATCHES vtipsvr 
			   AND n.edo_nvta = 'A'
			   AND  n.fes_nvta >= paramFecIni
			   AND  n.fes_nvta <= paramFecFin			   
			   AND  n.fliq_nvta = ep.fliq_erup
			   AND  n.ruta_nvta = ep.rut_erup 
			   AND  n.ruta_nvta =  r.cve_rut
			   --AND  f.fol_fac = ep.ffac_erup
			   --AND  f.ser_fac = ep.sfac_erup
			   AND  numcte_nvta = a.num_cte 
			   AND tlts_nvta > 0
		
		LET vfyh = null;
		LET vuuid = '';
		IF  vfolfac > 0 THEN
			SELECT  TRIM(uuid_fac),fyh_fac
			INTO	vuuid,vfyh
			FROM 	factura
			WHERE	fol_fac = vfolfac and ser_fac = vserfac;
		END IF;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);

		LET vidpcred = vol_getpcre(vidsvr,vpcred);		

		SELECT	MAX(fhs_mnvta)
		INTO	vfyhn
		FROM	hmovxnvta
		WHERE	cia_mnvta = vcia
			    AND  pla_mnvta = vpla
			    AND  fol_mnvta = vfolio
			    AND  vuelta_mnvta = vvuelta;
		
		--RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
		WITH RESUME;
	END FOREACH;
END IF;

--NOTAS DEL MES(SE EJECUTA SIEMPRE) -----------------------------------------------------------
IF	paramTipo = 'A' THEN 
	LET vrfc = 'GEN700527K14';
	LET vcliente = 'GAS EXPRESS NIETO';
	LET vtipfac = 'G';
	LET vtipcfd = 'I';
	LET vimptfac = 0;
	LET vtipo = 'A';
	LET vtpa = 'E';
	LET vtiprut = 'A';
	LET vuso = '1';
	
	SELECT  fol_fac, ser_fac,TRIM(uuid_fac),fyh_fac, impt_fac
	INTO	vfolfac,vserfac,vuuid,vfyh,vimptfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac = paramFecFin
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	SELECT  NVL(SUM(tlts_dfac),0)
	INTO	vtltsfac
	FROM 	factura, det_fac
	WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
			and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac = paramFecFin
			and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
			
	IF paramTipSvr = 'C' AND vtltsfac > 0 THEN
		LET vtltsfac = vtltsfac / vconkl;
	END IF;
	
	FOREACH cNotasA FOR	
		SELECT  TRIM(pcre_rut), fec_vand, SUM(impt_vand),SUM(tkgs_vand)
		INTO    vpcre,vfecvta, vtotvand,vtkgsvand
		FROM    venxand, ruta
		WHERE 	rut_vand = cve_rut AND fec_vand BETWEEN paramFecIni AND paramFecFin AND edo_vand = 'C'
		GROUP   BY pcre_rut, fec_vand
		ORDER   BY fec_vand

		SELECT	NVL(SUM(tlts_nvta),0), NVL(SUM(impt_nvta),0)
		INTO    vnkgvand,vnvtvand
		FROM	znota_vta, ruta
		WHERE	ruta_nvta = cve_rut AND pcre_rut = vpcre
				AND ruta_nvta[1] = 'A'
				AND fes_nvta = vfecvta AND edo_nvta = 'A' 				
				AND tip_nvta = paramTipSvr
				AND (aju_nvta IS NULL OR aju_nvta <> 'S');
				
		LET vtlts = vtkgsvand - vnkgvand;
		LET vimpt = vtotvand - vnvtvand;
		IF  vimpt > 0 AND vtlts > 0 THEN
			LET vtkgs = vtlts;
			IF	paramTipSvr = 'C' THEN
				LET vtlts = vtkgs / vconkl;
			END IF;
			LET vpru = vimpt / vtlts;		
			
			SELECT  MAX(fliq_vand),MAX(rut_vand), MAX(fyh_vand)
			INTO    vfolio,vruta,vfyhn
			FROM    venxand, ruta
			WHERE 	rut_vand = cve_rut AND pcre_rut = vpcre AND fec_vand = vfecvta AND edo_vand = 'C';
		
			IF vfecvta = paramFecFin THEN
				SELECT  fol_fac, ser_fac,TRIM(uuid_fac),fyh_fac, impt_fac
				INTO	vfolfac,vserfac,vuuid,vfyh,vimptfac
				FROM 	factura, det_fac
				WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
						and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
						and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';
						
				SELECT  NVL(SUM(tlts_dfac),0)
				INTO	vtltsfac
				FROM 	factura, det_fac
				WHERE	fol_fac = fol_dfac and ser_fac = ser_dfac
						and tid_dfac MATCHES vtipsvr and faccer_fac = 'S' and fec_fac between paramFecIniC and paramFecFinC
						and impasi_dfac = 0 and tlts_dfac > 0 and edo_fac <> 'C' and tfac_fac = 'M';	
				
				IF paramTipSvr = 'C' AND vtltsfac > 0 THEN
					LET vtltsfac = vtltsfac / vconkl;
				END IF;
			END IF;		
			
			LET vfecsur = vfecvta;
			
			LET vidpcre = vol_getpcre(vidsvr,vpcre);
			
			RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
			WITH RESUME;
		END IF;
	END FOREACH;
END IF;

--DONACIONES (SE EJECUTA SIEMPRE)-----------------------------------------------------------
IF	paramTipo = 'D' THEN 
	LET vrfc = '';
	LET vtipfac = 'N';
	LET vtipcfd = 'I';
	LET vimptfac = 0;
	LET vfyh = '';
	LET vfyhn = '';
	LET vuuid = '';
	LET vtltsfac = 0;
	LET vidpcred = 0;

	FOREACH cNotasD FOR	
		SELECT  tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,ruta_nvta[1],fac_nvta,ser_nvta,pcre_rut,fes_nvta,fol_nvta,NVL(uso_nvta,''),numcte_nvta,
				cia_nvta,pla_nvta,vuelta_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vnocte,vcia,vpla,vvuelta
		FROM	znota_vta,ruta 
		WHERE   fes_nvta >= paramFecIni
				AND  fes_nvta <= paramFecFin	
				AND  (tip_nvta = 'P' or tip_nvta = 'F') 
				AND  ruta_nvta = cve_rut AND (aju_nvta is null or aju_nvta = '') 	

		SELECT  CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(NVL(razsoc_cte,''))	ELSE TRIM(NVL(nom_cte,''))||' '|| TRIM(NVL(ape_cte,'')) end 
		INTO	vcliente
		FROM    cliente 
		WHERE 	num_cte = vnocte;
			
		LET vtkgs = vtlts;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);
		
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
		WITH RESUME;
	END FOREACH;
END IF;

--FUGAS (SE JECUTA SIEMPRE)-----------------------------------------------------------
IF	paramTipo = 'F' THEN 
	LET vrfc = '';
	LET vtipfac = 'N';
	LET vtipcfd = 'I';
	LET vimptfac = 0;
	LET vfyhn = '';
	LET vfyh = '';
	LET vuuid = '';	
	LET vtltsfac = 0;
	LET vidpcred = 0;

	FOREACH cNotasF FOR	
		SELECT  tip_nvta,tpa_nvta,tlts_nvta,impt_nvta,pru_nvta,ruta_nvta,ruta_nvta[1],fac_nvta,ser_nvta,pcre_rut,fes_nvta,fol_nvta,NVL(uso_nvta,''),numcte_nvta,
				cia_nvta,pla_nvta,vuelta_nvta
		INTO    vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vpcre,vfecsur,vfolio,vuso,vnocte,vcia,vpla,vvuelta
		FROM	znota_vta,ruta 
		WHERE   fes_nvta >= paramFecIni
				AND  fes_nvta <= paramFecFin	
				AND  (tip_nvta = 'K' or tip_nvta = 'Q') 
				AND  ruta_nvta = cve_rut AND (aju_nvta is null or aju_nvta = '') 	

		SELECT  CASE WHEN razsoc_cte IS NOT NULL THEN TRIM(NVL(razsoc_cte,''))	ELSE TRIM(NVL(nom_cte,''))||' '|| TRIM(NVL(ape_cte,'')) end 
		INTO	vcliente
		FROM    cliente 
		WHERE 	num_cte = vnocte;
		
		LET vtkgs = vtlts;
		IF	paramTipSvr = 'C' THEN
			LET vtlts = vtkgs / vconkl;
		END IF;
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);
		
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs
		WITH RESUME;
	END FOREACH;
END IF;

--CONSUMO INTERNO (SE EJECUTA SIEMPRE)-----------------------------------------------------------
IF	paramTipo = 'I' THEN 
	LET vrfc = '';
	LET vcliente = '';
	LET vtipfac = 'N';
	LET vtipcfd = 'I';
	LET vimptfac = 0;
	LET vtipo = 'I';
	LET vtpa = 'E';
	LET vtiprut = 'I';
	LET vuso = '1';
	LET vfyh = '';
	LET vfyhn = '';
	LET vuuid = '';
	LET vtltsfac = 0;
	LET vidpcred = 0;
	LET vfolfac = 0;
	LET vserfac = '';
	LET vtiprut = 'I';
	LET vruta = '';
	LET vpru = 0.00;
	LET vimpt = 0.00;
	LET vfecsur = paramFecFin;
	LET vtkgs = 0;
	LET vtkgspre = 0;
	  
	SELECT  NVL(SUM(epo_coni),0) 
	INTO    vtkgs
	FROM	e_posaj 
	WHERE   epo_fec >= paramFecIni AND epo_fec <= paramFecFin;
	
	SELECT  NVL(SUM(epr_coni),0) 
	INTO    vtkgspre
	FROM	e_preaj 
	WHERE   epr_fec >= paramFecIni AND epr_fec <= paramFecFin;
	
	IF vtkgs > 0 AND vtkgspre > 0 THEN
		IF	paramTipSvr = 'C' THEN
			LET vtlts = (vtkgspre - vtkgs) * 0.9 / vconkl;
		END IF;
		
		SELECT	MIN(pcre_rut)
		INTO	vpcre
		FROM	ruta
		WHERE   pcre_rut IS NOT NULL 
				AND pla_rut IN (SELECT cve_pla FROM planta WHERE cia_pla = '15' AND LENGTH(serfce_pla) = 3);
		
		LET vpcre = TRIM(vpcre);
		
		LET vidpcre = vol_getpcre(vidsvr,vpcre);
		
		LET vfolio = YEAR(paramFecIni) || MONTH(paramFecIni) || DAY(paramFecIni);
		RETURN 	vtipo,vtpa,vtlts,vimpt,vpru,vruta,vtiprut,vfolfac,vserfac,vfecsur,vfolio,vuso,vfyhn,vuuid,vfyh,vrfc,vcliente,vtipfac,vtipcfd,vtltsfac,vimptfac,vidpcre,vidsvr,vidpcred,vtkgs;
				
	END IF;	
END IF;

END PROCEDURE; 

SELECT  pcre_rut, fec_vand, SUM(impt_vand),SUM(tkgs_vand)
FROM    venxand, ruta
WHERE 	rut_vand = cve_rut AND fec_vand BETWEEN '2022-01-01' AND '2022-01-31' AND edo_vand = 'C'
GROUP   BY pcre_rut, fec_vand
ORDER   BY fec_vand

select 	*
from 	znota_vta
where	ruta_nvta[1] = 'A'
		and fes_nvta between '2022-01-01' and '2022-01-31' AND edo_nvta = 'A' 				
		AND tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')

SELECT	NVL(SUM(tlts_nvta),0), NVL(SUM(impt_nvta),0)
FROM	znota_vta, ruta
WHERE	ruta_nvta = cve_rut AND pcre_rut = 'LP/14462/DIST/PLA/2016   '
		AND ruta_nvta[1] = 'A'
		AND fes_nvta = '2022-01-03' AND edo_nvta = 'A' 				
		AND tip_nvta in('C')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S');

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
WHERE	fes_nvta between '2022-01-01' and '2022-04-30' AND edo_nvta = 'A' 				
		AND tip_nvta IN('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is not null

SELECT	*--count(*)
FROM 	znota_vta n
WHERE	fes_nvta between  '2022-01-01' and '2022-01-31' AND edo_nvta = 'A' 				
		AND tip_nvta IN('T') and numcte_nvta not in(select num_cte from almacen)
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null	
		
SELECT	count(*)
FROM	znota_vta n,
				empxrutp ep,
				ruta r,
				fuente.almacen a
		WHERE
			   tip_nvta MATCHES 'T' 
			   AND n.edo_nvta = 'A'
			   AND  n.fes_nvta >= '2022-01-01'
			   AND  n.fes_nvta <= '2022-04-30'			   
			   AND  n.fliq_nvta = ep.fliq_erup
			   AND  n.ruta_nvta = ep.rut_erup
			   AND  n.ruta_nvta =  r.cve_rut
			   AND  numcte_nvta = a.num_cte 
			   
select *
from 	almacen

select 	*
from 	empxrutp

SELECT 	count(*)
FROM 	znota_vta  z ,ruta 
		leFt JOIN  hmovxnvta h on z.cia_nvta = h.cia_mnvta
	    AND  z.pla_nvta = h.pla_mnvta
	    AND  z.fol_nvta = h.fol_mnvta
	    AND  z.vuelta_nvta = h.vuelta_mnvta
WHERE 	fes_nvta >= '2022-01-01'
		and fes_nvta < '2022-01-31'		
		and tip_nvta MATCHES 'B' 
		and ruta_nvta = cve_rut
		and (aju_nvta is null or aju_nvta = "")
		AND fac_nvta is null
		AND edo_nvta = 'A'
		
select  cia_mnvta, pla_mnvta, fol_mnvta, vuelta_mnvta, count(*)
from 	hmovxnvta
where 	fol_mnvta in(select fol_nvta znota_vta from znota_vta where cia_nvta = cia_mnvta and pla_nvta = pla_mnvta 
								and fol_nvta = fol_mnvta and vuelta_nvta = vuelta_mnvta and fes_nvta >= '2022-01-01'
		and fes_nvta < '2022-01-31'		
		and tip_nvta MATCHES 'B' AND fac_nvta is null
		AND edo_nvta = 'A')
group by 1,2,3,4
having  count(*) > 1 


select  *
from    vol_ventas
where 	tip_vta = 'B'
group by 1
having  count(*) > 1

select  pcre_rut, fec_vand, sum(impt_vand)
from    venxand, ruta
where 	rut_vand = cve_rut and fec_vand between '2022-01-01' and '2022-01-31' and edo_vand = 'C'
group   by pcre_rut, fec_vand
order by fec_vand

select  *
from 	fuente.ruta
where 	cve_rut[1] = 'A'

select  *
from    venxand
where 	fec_vand between '2022-01-01' and '2022-01-31' and edo_vand = 'C'

select 	*
from 	znota_vta
where	ruta_nvta[1] = 'A'
		and fes_nvta between '2022-01-01' and '2022-01-31' AND edo_nvta = 'A' 				
		AND tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')

select  *
from 	znota_vta
where 	fes_nvta between '2022-01-01' and '2022-01-31' AND edo_nvta = 'A' 				
		AND tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and fol_nvta not in(select folnvta_vta from vol_ventas_n where 	id_serv = 18 
				and fecha_vta between '2022-01-01' and '2022-01-31')

select  *
from    vol_ventas_n
where 	folnvta_vta = 321902

select  *
from 	znota_vta
where 	fol_nvta = 327927

select *
from 	fuente.mov_prc 
where 	tpr_mprc = '005'
order by fei_mprc desc

select  *
from    vol_ventas_n
where 	folnvta_vta = 321902 and tlts_vta > 0 and ((impt_vta - (tlts_vta * pru_vta) < -0.05) or (impt_vta - (tlts_vta * pru_vta) > 0.05))

select  count(*)
from    vol_ventas_n --where tip_fac = 'G' and tip_ruta = 'A'
where 	tlts_vta > 0 and ((impt_vta - (tlts_vta * pru_vta) < -0.10) or (impt_vta - (tlts_vta * pru_vta) > 0.10))

update  vol_ventas_n
set 	pru_vta = impt_vta / tlts_vta
where 	tlts_vta > 0 and ((impt_vta - (tlts_vta * pru_vta) < -0.10) or (impt_vta - (tlts_vta * pru_vta) > 0.10))

select  count(*)
from    vol_ventas_n
where 	id_serv = 18 and fecha_vta between '2022-04-01' and '2022-04-30'

 enero 3
 feb 1
 mar 4

select  *
from 	hmovxnvta
where   fol_mnvta = 157604

select *
from 	ruta    
where 	cve_rut in('M001','M031','M067')

select  rowid,folnvta_vta
from    vol_ventas
where   idsys_vta = 1

select  count(*)
from 	nota_vta 
where   fes_nvta between  '2024-06-01' and '2024-06-30' AND edo_nvta = 'A' 				
		AND tip_nvta IN('B') 
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta is null	
		
SELECT	pcre_rut,sum(tlts_nvta)
FROM	znota_vta n,
		empxrutp ep,
		ruta r,
		fuente.almacen a
WHERE
	   tip_nvta MATCHES 'T' 
	   AND n.edo_nvta = 'A'
	   AND  n.fes_nvta >= '2022-02-01'
	   AND  n.fes_nvta <= '2022-02-28'			   
	   AND  n.fliq_nvta = ep.fliq_erup
	   AND  n.ruta_nvta = ep.rut_erup 
	   AND  n.ruta_nvta =  r.cve_rut
	   --AND  f.fol_fac = ep.ffac_erup
	   --AND  f.ser_fac = ep.sfac_erup
	   AND  numcte_nvta = a.num_cte 
	   AND tlts_nvta > 0
group by pcre_rut

select  count(*)
from	vol_ventas_n
where 	tip_vta <> 'T'

SELECT	count(*)
FROM 	znota_vta n
WHERE	fes_nvta between '2022-01-01' and '2022-04-30' AND edo_nvta = 'A' AND tlts_nvta > 0		
		AND tip_nvta in('E','B','C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		
SELECT	count(*)
FROM 	znota_vta n
WHERE	fes_nvta between '2022-01-31' and '2022-01-31' AND edo_nvta = 'A' 				
		AND tip_nvta in('C','D','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		and fac_nvta is null

SELECT	count(*)
FROM	znota_vta n,
		empxrutp ep,
		ruta r,
		fuente.almacen a
WHERE
	   tip_nvta MATCHES 'T' 
	   AND n.edo_nvta = 'A'
	   AND  n.fes_nvta >= '2022-01-01'
	   AND  n.fes_nvta <= '2022-04-30'					   
	   AND  n.fliq_nvta = ep.fliq_erup
	   AND  n.ruta_nvta = ep.rut_erup 
	   AND  n.ruta_nvta =  r.cve_rut
	   --AND  f.fol_fac = ep.ffac_erup
	   --AND  f.ser_fac = ep.sfac_erup
	   AND  numcte_nvta = a.num_cte 
	   AND tlts_nvta > 0
	   

select *
from   znota_vta n,ruta
where  fes_nvta >= '2022-01-01'
	   AND  n.fes_nvta <= '2022-01-31'
	   AND  (tip_nvta = 'P' or tip_nvta = 'F') 
		AND  ruta_nvta = cve_rut AND (aju_nvta is null or aju_nvta = '') 	
		
select tip_nvta,tpa_nvta,(tlts_nvta),impt_nvta,ruta_nvta,fac_nvta,ser_nvta,pcre_rut,fes_nvta,fol_nvta 
from znota_vta,ruta 
Where month(fes_nvta) =  1 and year(fes_nvta) = 2022 and  (tip_nvta = 'P' or tip_nvta = 'F') 
     and ruta_nvta = cve_rut --and (aju_nvta is null or aju_nvta = '') 
     order by pcre_rut
     
select 	sum(epr_coni)
from 	e_preaj
where 	epr_fec >= '2022-01-01' AND epr_fec <= '2022-01-31';

select 	sum(epo_coni)
from 	e_posaj
where 	epo_fec >= '2022-01-01' AND epo_fec <= '2022-01-31';
