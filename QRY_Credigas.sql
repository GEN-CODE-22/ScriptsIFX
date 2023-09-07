DROP PROCEDURE QRY_Credigas;
EXECUTE PROCEDURE  QRY_Credigas('','','2022-11-04', '2022-11-04','D');
EXECUTE PROCEDURE  QRY_Credigas('','','2022-11-04', '2022-11-04','F');

CREATE PROCEDURE QRY_Credigas
(
	paramCia		CHAR(2),
	paramPla		CHAR(2),
	paramFecIni		DATE,
	paramFecFin		DATE,
	paramGrupo		CHAR(1)
)

RETURNING  
 CHAR(30),
 CHAR(20),
 CHAR(2),
 INT,
 CHAR(4),
 CHAR(2),
 CHAR(2),
 DATE,
 DECIMAL,
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
DEFINE vcargo   DECIMAL;
DEFINE vabono   DECIMAL;
DEFINE vnumcte 	CHAR(6);
DEFINE vnomcte  CHAR(80);

IF paramGrupo = 'D'	THEN
	IF paramCia <> '' AND paramPla <> '' THEN
		FOREACH cMovimientos FOR
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
					ELSE ''
				END,
				m.tpm_mcxc, desc_mcxc, tip_mcxc, doc_mcxc, ser_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00, m.imp_mcxc, c.num_cte,
				NVL(CASE 
						WHEN TRIM(c.razsoc_cte) <> '' THEN
						   TRIM(c.razsoc_cte) 
						ELSE 
						   CASE
							  WHEN c.ali_cte <> '' THEN
								 TRIM(c.ali_cte) || ', ' 
							  ELSE
								 '' 
						   END || trim(c.nom_cte) || ' ' || TRIM(c.ape_cte) 
						END,'')
			INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte
			FROM	mov_cxc m, cliente c
			WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND tpa_mcxc = 'G' AND m.tpm_mcxc > '49'
					AND m.cia_mcxc = paramCia AND m.pla_mcxc = paramPla AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
			ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte
				
			RETURN 	vmovdes, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte 
			WITH RESUME;
		END FOREACH;
			
	ELSE
		FOREACH cMovimientos FOR
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
					ELSE ''
				END,
				m.tpm_mcxc, desc_mcxc, tip_mcxc, doc_mcxc, ser_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00, m.imp_mcxc, c.num_cte,
				NVL(CASE 
						WHEN TRIM(c.razsoc_cte) <> '' THEN
						   TRIM(c.razsoc_cte) 
						ELSE 
						   CASE
							  WHEN c.ali_cte <> '' THEN
								 TRIM(c.ali_cte) || ', ' 
							  ELSE
								 '' 
						   END || trim(c.nom_cte) || ' ' || TRIM(c.ape_cte) 
						END,'')
			INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte
			FROM	mov_cxc m, cliente c
			WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND tpa_mcxc = 'G' AND m.tpm_mcxc > '49'
					AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
			ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte
				
			RETURN 	vmovdes, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte 
			WITH RESUME;
		END FOREACH;
	END IF;	
ELSE
	IF paramGrupo = 'F' THEN
		IF paramCia <> '' AND paramPla <> '' THEN
			FOREACH cMovimientos FOR
				SELECT	CASE			
							WHEN max(m.tpm_mcxc) = '50' THEN 'EFECTIVO'
							WHEN max(m.tpm_mcxc) = '51' THEN 'CHEQUE'
							WHEN max(m.tpm_mcxc) = '52' THEN 'NOTA CREDITO'
							WHEN max(m.tpm_mcxc) = '53' THEN 'ANTICIPO'
							WHEN max(m.tpm_mcxc) = '55' THEN 'PAGO CON ANTICIPO'
							WHEN max(m.tpm_mcxc) = '56' THEN 'CHEQUE POST'
							WHEN max(m.tpm_mcxc) = '58' THEN 'TRANSFERENCIA'
							WHEN max(m.tpm_mcxc) = '60' THEN 'COMPENSA COMIS'
							WHEN max(m.tpm_mcxc) = '61' THEN 'INTERESE PAG'
							WHEN max(m.tpm_mcxc) = '62' THEN 'PAGO EN BIENES'
							WHEN max(m.tpm_mcxc) = '63' THEN 'DONATIVO'
							WHEN max(m.tpm_mcxc) = '98' THEN 'CANCELACION(N CRED)'
							WHEN max(m.tpm_mcxc) = '99' THEN 'CANCELACION(AJUSTE)'
							ELSE ''
						END,
						max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, max(fec_mcxc), 0.00,
						sum(m.imp_mcxc), c.num_cte
				INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
				FROM	mov_cxc m, cliente c
				WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND tpa_mcxc = 'G' AND m.tpm_mcxc > '49'
						AND m.cia_mcxc = paramCia AND m.pla_mcxc = paramPla AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
						and ffac_mcxc is not null and sfac_mcxc is not null
				GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte			
				UNION
				SELECT	CASE
							WHEN m.tpm_mcxc = '50' THEN 'EFECTIVO'
							WHEN m.tpm_mcxc = '51' THEN 'CHEQUE'
							WHEN m.tpm_mcxc = '52' THEN 'NOTA CREDITO'
							WHEN m.tpm_mcxc = '53' THEN 'ANTICIPO'
							WHEN m.tpm_mcxc = '55' THEN 'PAGO CON ANTICIPO'
							WHEN m.tpm_mcxc = '56' THEN 'CHEQUE POST'
							WHEN m.tpm_mcxc = '58' THEN 'TRANSFERENCIA'
							WHEN m.tpm_mcxc = '60' THEN 'COMPENSA COMIS'
							WHEN m.tpm_mcxc = '61' THEN 'INTERESE PAG'
							WHEN m.tpm_mcxc = '62' THEN 'PAGO EN BIENES'
							WHEN m.tpm_mcxc = '63' THEN 'DONATIVO'
							WHEN m.tpm_mcxc = '98' THEN 'CANCELACION(N CRED)'
							WHEN m.tpm_mcxc = '99' THEN 'CANCELACION(AJUSTE)'
							ELSE ''
						END,
						m.tpm_mcxc, desc_mcxc, tip_mcxc, doc_mcxc, ser_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00, m.imp_mcxc, 
						c.num_cte			
				FROM	mov_cxc m, cliente c
				WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND tpa_mcxc = 'G' AND m.tpm_mcxc > '49'
						AND m.cia_mcxc = paramCia AND m.pla_mcxc = paramPla AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
						AND ffac_mcxc is null and sfac_mcxc is null
				ORDER BY 9,2,12
				IF vnumcte <> '' THEN
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
				RETURN 	vmovdes, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte 
				WITH RESUME;
			END FOREACH;
		ELSE
			FOREACH cMovimientos FOR
				SELECT	CASE			
							WHEN max(m.tpm_mcxc) = '50' THEN 'EFECTIVO'
							WHEN max(m.tpm_mcxc) = '51' THEN 'CHEQUE'
							WHEN max(m.tpm_mcxc) = '52' THEN 'NOTA CREDITO'
							WHEN max(m.tpm_mcxc) = '53' THEN 'ANTICIPO'
							WHEN max(m.tpm_mcxc) = '55' THEN 'PAGO CON ANTICIPO'
							WHEN max(m.tpm_mcxc) = '56' THEN 'CHEQUE POST'
							WHEN max(m.tpm_mcxc) = '58' THEN 'TRANSFERENCIA'
							WHEN max(m.tpm_mcxc) = '60' THEN 'COMPENSA COMIS'
							WHEN max(m.tpm_mcxc) = '61' THEN 'INTERESE PAG'
							WHEN max(m.tpm_mcxc) = '62' THEN 'PAGO EN BIENES'
							WHEN max(m.tpm_mcxc) = '63' THEN 'DONATIVO'
							WHEN max(m.tpm_mcxc) = '98' THEN 'CANCELACION(N CRED)'
							WHEN max(m.tpm_mcxc) = '99' THEN 'CANCELACION(AJUSTE)'
							ELSE ''
						END,
						max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, max(fec_mcxc), 0.00,
						sum(m.imp_mcxc), c.num_cte
				INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
				FROM	mov_cxc m, cliente c
				WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND tpa_mcxc = 'G' AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
						and ffac_mcxc is not null and sfac_mcxc is not null AND m.tpm_mcxc > '49'
				GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte			
				UNION
				SELECT	CASE
							WHEN m.tpm_mcxc = '50' THEN 'EFECTIVO'
							WHEN m.tpm_mcxc = '51' THEN 'CHEQUE'
							WHEN m.tpm_mcxc = '52' THEN 'NOTA CREDITO'
							WHEN m.tpm_mcxc = '53' THEN 'ANTICIPO'
							WHEN m.tpm_mcxc = '55' THEN 'PAGO CON ANTICIPO'
							WHEN m.tpm_mcxc = '56' THEN 'CHEQUE POST'
							WHEN m.tpm_mcxc = '58' THEN 'TRANSFERENCIA'
							WHEN m.tpm_mcxc = '60' THEN 'COMPENSA COMIS'
							WHEN m.tpm_mcxc = '61' THEN 'INTERESE PAG'
							WHEN m.tpm_mcxc = '62' THEN 'PAGO EN BIENES'
							WHEN m.tpm_mcxc = '63' THEN 'DONATIVO'
							WHEN m.tpm_mcxc = '98' THEN 'CANCELACION(N CRED)'
							WHEN m.tpm_mcxc = '99' THEN 'CANCELACION(AJUSTE)'
							ELSE ''
						END,
						m.tpm_mcxc, desc_mcxc, tip_mcxc, doc_mcxc, ser_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00, m.imp_mcxc, 
						c.num_cte			
				FROM	mov_cxc m, cliente c
				WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND tpa_mcxc = 'G' AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
						AND ffac_mcxc is null and sfac_mcxc is null AND m.tpm_mcxc > '49'
				ORDER BY 9,2,12
				IF vnumcte <> '' THEN
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
				RETURN 	vmovdes, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte 
				WITH RESUME;
			END FOREACH;
		END IF;
	END IF;
END IF;
END PROCEDURE; 