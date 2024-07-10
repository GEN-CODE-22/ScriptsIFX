DROP PROCEDURE cxc_rptcartrfcg;
EXECUTE PROCEDURE  cxc_rptcartrfcg('T',2024,6,'2024-06-01','2024-06-30'); 
EXECUTE PROCEDURE  cxc_rptcartrfcg('C',2024,5,'2024-06-01','2024-06-30'); 

CREATE PROCEDURE cxc_rptcartrfcg
(
	paramTipo  		CHAR(1),	-- T = Todo, C = Sin cartera
	paramAnnio		INT,		-- Año
	paramMes 		INT,		-- Mes
	paramFecIni 	DATE,		-- Fecha Inicial
	paramFecFin 	DATE		-- Fecha Final
)

RETURNING  
 CHAR(13),					-- Tipo de servicio
 CHAR(6),					-- No Cliente
 CHAR(80),					-- Cliente
 INT,						-- Días crédito
 DECIMAL,					-- Límite crédito
 DECIMAL,					-- Saldo por vencer
 DECIMAL,					-- Saldo 0 -30 días
 DECIMAL,					-- Saldo 30 -60 días
 DECIMAL,					-- Saldo 60 -90 días
 DECIMAL,					-- Saldo 90 -120 días
 DECIMAL,					-- Saldo 120 -150 días
 DECIMAL,					-- Saldo 150 -180 días
 DECIMAL,					-- Saldo 180 -210 días
 DECIMAL,					-- Saldo 210 -240 días
 DECIMAL,					-- Saldo 240 -270 días
 DECIMAL,					-- Saldo mas 270 días
 DECIMAL,					-- Saldo Total
 DECIMAL,					-- Ventas en el mes
 DECIMAL;					-- Cobranza en el mes

 
DEFINE vrfc 	CHAR(13);
DEFINE vnocte 	CHAR(6);
DEFINE vcte 	CHAR(80);
DEFINE vdcre	INT;
DEFINE vlimcre	DECIMAL;
DEFINE vssven	DECIMAL;
DEFINE vs00		DECIMAL;
DEFINE vs30		DECIMAL;
DEFINE vs60		DECIMAL;
DEFINE vs90		DECIMAL;
DEFINE vs120	DECIMAL;
DEFINE vs150	DECIMAL;
DEFINE vs180	DECIMAL;
DEFINE vs210	DECIMAL;
DEFINE vs240	DECIMAL;
DEFINE vs270	DECIMAL;
DEFINE vstotal	DECIMAL;
DEFINE vventas	DECIMAL;
DEFINE vcobr	DECIMAL;

LET vventas = 0;
LET vcobr = 0;

FOREACH cCartera FOR	
	SELECT 	rfc_cmcte,numcte_cmcte,nomcte_cmcte,NVL(diacre_cmcte, 0),NVL(limcon_cmcte, 0),ssvencer_cmcte,s000_030_cmcte,s030_060_cmcte,s060_090_cmcte,s090_120_cmcte,s120_150_cmcte,s150_180_cmcte,
			s180_210_cmcte,s210_240_cmcte,s240_270_cmcte,smas_270_cmcte,stotal_cmcte
	INTO    vrfc,vnocte,vcte,vdcre,vlimcre,vssven,vs00,vs30,vs60,vs90,vs120,vs150,vs180,vs210,vs240,vs270,vstotal
	FROM 	cart_mes_cte
	WHERE 	anio_cmcte = paramAnnio AND mes_cmcte = paramMes
			 
	IF paramTipo = 'T' THEN	
		SELECT	NVL(SUM(impt_nvta),0)
		INTO	vventas
		FROM	nota_vta
		WHERE	fes_nvta BETWEEN paramFecIni AND paramFecFin 
				AND numcte_nvta = vnocte AND edo_nvta = 'A'
				AND (aju_nvta IS NULL OR aju_nvta <> 'S');
				
		SELECT  NVL(SUM(imp_mcxc),0)
		INTO	vcobr
		FROM	mov_cxc
		WHERE	fec_mcxc BETWEEN paramFecIni AND paramFecFin 
				AND cte_mcxc = vnocte AND sta_mcxc = 'A'
				AND tpm_mcxc > '49';
	END IF;
	
	RETURN 	vrfc,vnocte,vcte,vdcre,vlimcre,vssven,vs00,vs30,vs60,vs90,vs120,vs150,vs180,vs210,vs240,vs270,vstotal,vventas,vcobr
	WITH RESUME;
END FOREACH;

END PROCEDURE; 