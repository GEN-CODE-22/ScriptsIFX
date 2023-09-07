CREATE PROCEDURE CalifCliente
(
	
)

RETURNING 
 INT;

DEFINE v_anio	  	INT;
DEFINE v_mes	 	INT;
DEFINE v_regreso  	INT;
DEFINE v_cia		CHAR(2);
DEFINE v_pla		CHAR(2);
DEFINE v_numcte		CHAR(6);
DEFINE v_contrato  	CHAR(1);
DEFINE v_pagare  	CHAR(1);
DEFINE v_tipo  		CHAR(3);
DEFINE v_rfc  		CHAR(15);
DEFINE v_doctos  	INT;
DEFINE v_docto  	INT;
DEFINE v_comodato  	INT;
DEFINE v_imppagare	DECIMAL;
DEFINE v_saldo		DECIMAL;
DEFINE v_saldosv	DECIMAL;
DEFINE v_saldo030	DECIMAL;
DEFINE v_saldo060	DECIMAL;
DEFINE v_saldo090	DECIMAL;
DEFINE v_saldo120	DECIMAL;
DEFINE v_saldo150	DECIMAL;
DEFINE v_saldo180	DECIMAL;
DEFINE v_saldo210	DECIMAL;
DEFINE v_saldo240	DECIMAL;
DEFINE v_saldo270	DECIMAL;
DEFINE v_saldomas	DECIMAL;
DEFINE v_diacre		SMALLINT;
DEFINE v_diaprom	SMALLINT;
DEFINE v_estrellas	SMALLINT;
DEFINE v_calif		SMALLINT;

LET v_regreso = 0;
LET v_calif = 0;
LET v_estrellas = 0;

SELECT	MAX(anio_cmcte)
INTO	v_anio
FROM	cart_mes_cte;

SELECT	MAX(mes_cmcte)
INTO	v_mes
FROM	cart_mes_cte
WHERE	anio_cmcte = v_anio;


FOREACH cCliente FOR
	SELECT  cia_cmcte, pla_cmcte, numcte_cmcte,ncont_cmcte, ncont_cmcte, limcon_cmcte, stotal_cmcte, ssvencer_cmcte, 
			s000_030_cmcte, s030_060_cmcte, s060_090_cmcte, s090_120_cmcte, s120_150_cmcte, s150_180_cmcte, s180_210_cmcte, 
			s210_240_cmcte, s240_270_cmcte, smas_270_cmcte, diacre_cmcte, diapro_cmcte
	INTO	v_cia, v_pla,v_numcte,v_contrato, v_pagare, v_imppagare, v_saldo, v_saldosv, v_saldo030, v_saldo060, v_saldo090,
			v_saldo120, v_saldo150, v_saldo180, v_saldo210, v_saldo240, v_saldo270, v_saldomas, v_diacre, v_diaprom
	FROM	cart_mes_cte
	WHERE	mes_cmcte = v_mes  and anio_cmcte = v_anio --and numcte_cmcte = '000166'
	
	SELECT	TRIM(rfc_cte)
	INTO	v_rfc
	FROM	cliente
	WHERE	num_cte = v_numcte;
	
	SELECT	tipo_crcte
	INTO	v_tipo
	FROM	cte_credito
	WHERE	numcte_crcte = v_numcte;
	
	LET v_docto = 0;
	SELECT COUNT(*)
	INTO	v_doctos
	FROM	cte_doctos
	WHERE	numcte_cdoc = v_numcte and tip_cdoc <> 'LIC';
	
	IF v_tipo = 'CCC' THEN				
		IF (LENGTH(v_rfc) = 13 and v_doctos = 11) or (LENGTH(v_rfc) = 12 and v_doctos = 14) THEN
			LET v_docto = 1;
		END IF;	
	END IF;
	IF v_tipo = 'CCR' THEN		
		IF (LENGTH(v_rfc) = 13 and v_doctos = 8) or (LENGTH(v_rfc) = 12 and v_doctos = 11) THEN
			LET v_docto = 1;
		END IF;	
	END IF;
	IF v_tipo = 'CCM' THEN		
		IF (LENGTH(v_rfc) = 13 and v_doctos = 8) or  (LENGTH(v_rfc) = 12 and v_doctos = 11) THEN
			LET v_docto = 1;
		END IF;	
	END IF;
	IF v_tipo = 'CSM' THEN		
		IF (LENGTH(v_rfc) = 13 and v_doctos = 5) or  (LENGTH(v_rfc) = 12 and v_doctos = 8) THEN
			LET v_docto = 1;
		END IF;	
	END IF;
	
	SELECT  count(*)
	INTO	v_comodato
	FROM	tanque
	WHERE	numcte_tqe = v_numcte and stat_tqe = 'A' AND comoda_tqe = 'S';
	
	IF v_contrato = 'S' THEN
		LET v_calif = v_calif + 10;
	END IF;
	IF v_pagare = 'S' THEN
		LET v_calif = v_calif + 10;
	END IF;
	IF v_docto > 0 THEN
		LET v_calif = v_calif + 10;
	END IF;
	IF v_imppagare >= v_saldo THEN
		LET v_calif = v_calif + 10;
	END IF;
	IF v_saldo - v_saldosv <= 10 THEN
		LET v_calif = v_calif + 25;
	END IF;
	IF v_diaprom <= v_diacre THEN
		LET v_calif = v_calif + 25;
	END IF;
	IF v_comodato > 0 THEN
		LET v_calif = v_calif + 10;
	END IF;	
	IF v_calif <= 20 THEN
		LET v_estrellas = 1;
	END IF;
	IF v_calif > 20 and v_calif <= 40 THEN
		LET v_estrellas = 2;
	END IF;
	IF v_calif > 40 and v_calif <= 60 THEN
		LET v_estrellas = 3;
	END IF;
	IF v_calif > 60 and v_calif <= 80 THEN
		LET v_estrellas = 4;
	END IF;
	IF v_calif > 80 and v_calif <= 100 THEN
		LET v_estrellas = 5;
	END IF;
	
	IF EXISTS(SELECT 1 FROM cte_credito WHERE numcte_crcte = v_numcte) THEN 
		UPDATE	cte_credito
		SET		calif_crcte = v_calif, estrellas_crcte = v_estrellas
		WHERE 	numcte_crcte = v_numcte;	
	ELSE
		INSERT INTO cte_credito
		VALUES(v_numcte,'N','N',0,'',v_calif,v_estrellas,'','','',null,'',null,null,null,null);
	END IF;
	LET v_calif = 0;
	LET v_estrellas = 0;
	LET v_regreso = v_regreso + 1;
	
END FOREACH; 
RETURN 	v_regreso;
END PROCEDURE;  
