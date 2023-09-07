DROP PROCEDURE QRY_EdoCuenta;
EXECUTE PROCEDURE  QRY_EdoCuenta('2023-07-01', '2023-08-29', '006756');

CREATE PROCEDURE QRY_EdoCuenta
(	
	paramFecIni		DATE,
	paramFecFin		DATE,
	paramCte		CHAR(6)
)

RETURNING  
 CHAR(30),
 CHAR(2),
 CHAR(20),
 CHAR(2),
 INT,
 CHAR(4),
 CHAR(2),
 CHAR(2),
 DATE,
 DECIMAL,
 CHAR(6),
 CHAR(80);
 
DEFINE vmov 	CHAR(2);
DEFINE vmovdes 	CHAR(30);
DEFINE vdes     CHAR(20);
DEFINE vtip     CHAR(2);
DEFINE vfolio   INT;
DEFINE vserie   CHAR(4);
DEFINE vcia     CHAR(2);
DEFINE vpla     CHAR(2);
DEFINE vfecha   DATE;
DEFINE vimp   	DECIMAL;
DEFINE vnumcte 	CHAR(6);
DEFINE vnomcte  CHAR(80);

FOREACH cMovimientos FOR
	SELECT	CASE
				WHEN max(m.tpm_mcxc) = '50' THEN 'EFECTIVO'
				WHEN max(m.tpm_mcxc) = '51' THEN 'CHEQUE'
				WHEN max(m.tpm_mcxc) = '52' THEN 'NOTA CREDITO'
				WHEN max(m.tpm_mcxc) = '53' THEN 'ANTICIPO'
				WHEN max(m.tpm_mcxc) = '55' THEN 'PAGO CON ANTICIPO'
				WHEN max(m.tpm_mcxc) = '56' THEN 'CHEQUE POST'
				WHEN max(m.tpm_mcxc) = '58' THEN 'PAGO POR BANCO'
				WHEN max(m.tpm_mcxc) = '60' THEN 'COMPENSA COMIS'
				WHEN max(m.tpm_mcxc) = '61' THEN 'INTERESE PAG'
				WHEN max(m.tpm_mcxc) = '62' THEN 'PAGO EN BIENES'
				WHEN max(m.tpm_mcxc) = '63' THEN 'DONATIVO'
				WHEN max(m.tpm_mcxc) = '98' THEN 'CANCELACION(N CRED)'
				WHEN max(m.tpm_mcxc) = '99' THEN 'CANCELACION(AJUSTE)'
				ELSE 'FACTURA'
			END,
			max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, max(fec_mcxc),
			sum(m.imp_mcxc), c.num_cte
	INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vimp, vnumcte
	FROM	mov_cxc m, cliente c
	WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND c.num_cte = paramCte
			and ffac_mcxc is not null and sfac_mcxc is not null
			AND fec_mcxc BETWEEN paramFecIni AND paramFecFin AND m.tpm_mcxc < '50'
	GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte		
	UNION ALL
	SELECT	CASE
				WHEN max(m.tpm_mcxc) = '50' THEN 'EFECTIVO'
				WHEN max(m.tpm_mcxc) = '51' THEN 'CHEQUE'
				WHEN max(m.tpm_mcxc) = '52' THEN 'NOTA CREDITO'
				WHEN max(m.tpm_mcxc) = '53' THEN 'ANTICIPO'
				WHEN max(m.tpm_mcxc) = '55' THEN 'PAGO CON ANTICIPO'
				WHEN max(m.tpm_mcxc) = '56' THEN 'CHEQUE POST'
				WHEN max(m.tpm_mcxc) = '58' THEN 'PAGO POR BANCO'
				WHEN max(m.tpm_mcxc) = '60' THEN 'COMPENSA COMIS'
				WHEN max(m.tpm_mcxc) = '61' THEN 'INTERESE PAG'
				WHEN max(m.tpm_mcxc) = '62' THEN 'PAGO EN BIENES'
				WHEN max(m.tpm_mcxc) = '63' THEN 'DONATIVO'
				WHEN max(m.tpm_mcxc) = '98' THEN 'CANCELACION(N CRED)'
				WHEN max(m.tpm_mcxc) = '99' THEN 'CANCELACION(AJUSTE)'
				ELSE 'FACTURA'
			END,
			max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, max(fec_mcxc),
			sum(m.imp_mcxc), c.num_cte
	FROM	mov_cxc m, cliente c
	WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND c.num_cte = paramCte
			and ffac_mcxc is not null and sfac_mcxc is not null
			AND fec_mcxc BETWEEN paramFecIni AND paramFecFin AND m.tpm_mcxc > '49'
	GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte	
	UNION ALL
	SELECT	CASE
				WHEN m.tpm_mcxc = '50' THEN 'EFECTIVO'
				WHEN m.tpm_mcxc = '51' THEN 'CHEQUE'
				WHEN m.tpm_mcxc = '52' THEN 'NOTA CREDITO'
				WHEN m.tpm_mcxc = '53' THEN 'ANTICIPO'
				WHEN m.tpm_mcxc = '55' THEN 'PAGO CON ANTICIPO'
				WHEN m.tpm_mcxc = '56' THEN 'CHEQUE POST'
				WHEN m.tpm_mcxc = '58' THEN 'PAGO POR BANCO'
				WHEN m.tpm_mcxc = '60' THEN 'COMPENSA COMIS'
				WHEN m.tpm_mcxc = '61' THEN 'INTERESE PAG'
				WHEN m.tpm_mcxc = '62' THEN 'PAGO EN BIENES'
				WHEN m.tpm_mcxc = '63' THEN 'DONATIVO'
				WHEN m.tpm_mcxc = '98' THEN 'CANCELACION(N CRED)'
				WHEN m.tpm_mcxc = '99' THEN 'CANCELACION(AJUSTE)'
				ELSE 'DOCUMENTO'
			END,
			m.tpm_mcxc, desc_mcxc, tip_mcxc, doc_mcxc, ser_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, m.imp_mcxc, 
			c.num_cte
	FROM	mov_cxc m, cliente c
	WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND c.num_cte = paramCte
			AND ffac_mcxc is null and sfac_mcxc is null
			AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
	ORDER BY 5,6,2
	IF vnumcte <> ''THEN
		SELECT	NVL(CASE 
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
				END,'')
		INTO	vnomcte
		FROM	cliente
		WHERE	num_cte = vnumcte;
	END IF;	
	RETURN 	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vimp, vnumcte,vnomcte
	WITH RESUME;
END FOREACH;
END PROCEDURE; 

SELECT	CASE
			WHEN max(m.tpm_mcxc) = '50' THEN 'EFECTIVO'
			WHEN max(m.tpm_mcxc) = '51' THEN 'CHEQUE'
			WHEN max(m.tpm_mcxc) = '52' THEN 'NOTA CREDITO'
			WHEN max(m.tpm_mcxc) = '53' THEN 'ANTICIPO'
			WHEN max(m.tpm_mcxc) = '55' THEN 'PAGO CON ANTICIPO'
			WHEN max(m.tpm_mcxc) = '56' THEN 'CHEQUE POST'
			WHEN max(m.tpm_mcxc) = '58' THEN 'PAGO POR BANCO'
			WHEN max(m.tpm_mcxc) = '60' THEN 'COMPENSA COMIS'
			WHEN max(m.tpm_mcxc) = '61' THEN 'INTERESE PAG'
			WHEN max(m.tpm_mcxc) = '62' THEN 'PAGO EN BIENES'
			WHEN max(m.tpm_mcxc) = '63' THEN 'DONATIVO'
			WHEN max(m.tpm_mcxc) = '98' THEN 'CANCELACION(N CRED)'
			WHEN max(m.tpm_mcxc) = '99' THEN 'CANCELACION(AJUSTE)'
			ELSE 'FACTURA'
		END,
		max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, max(fec_mcxc), 
		sum(m.imp_mcxc), c.num_cte	
FROM	mov_cxc m, cliente c
WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND c.num_cte = '000199'
		and ffac_mcxc is not null and sfac_mcxc is not null
		AND fec_mcxc BETWEEN '2023-08-01' AND '2023-08-29'
GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte	
	
UNION ALL
SELECT	CASE
			WHEN m.tpm_mcxc = '50' THEN 'EFECTIVO'
			WHEN m.tpm_mcxc = '51' THEN 'CHEQUE'
			WHEN m.tpm_mcxc = '52' THEN 'NOTA CREDITO'
			WHEN m.tpm_mcxc = '53' THEN 'ANTICIPO'
			WHEN m.tpm_mcxc = '55' THEN 'PAGO CON ANTICIPO'
			WHEN m.tpm_mcxc = '56' THEN 'CHEQUE POST'
			WHEN m.tpm_mcxc = '58' THEN 'PAGO POR BANCO'
			WHEN m.tpm_mcxc = '60' THEN 'COMPENSA COMIS'
			WHEN m.tpm_mcxc = '61' THEN 'INTERESE PAG'
			WHEN m.tpm_mcxc = '62' THEN 'PAGO EN BIENES'
			WHEN m.tpm_mcxc = '63' THEN 'DONATIVO'
			WHEN m.tpm_mcxc = '98' THEN 'CANCELACION(N CRED)'
			WHEN m.tpm_mcxc = '99' THEN 'CANCELACION(AJUSTE)'
			ELSE 'DOCUMENTO'
		END,
		m.tpm_mcxc, desc_mcxc, tip_mcxc, doc_mcxc, ser_mcxc, cia_mcxc, pla_mcxc, fec_mcxc,  m.imp_mcxc, 
		c.num_cte	
FROM	mov_cxc m, cliente c
WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND c.num_cte = '000199'
		AND ffac_mcxc is null and sfac_mcxc is null
		AND fec_mcxc BETWEEN '2023-08-01' AND '2023-08-29'
ORDER BY 9,2,11