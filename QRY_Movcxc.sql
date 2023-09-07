DROP PROCEDURE QRY_Movcxc;
EXECUTE PROCEDURE  QRY_Movcxc('','',0,'2023-01-31', '2023-01-31', '','','D');
EXECUTE PROCEDURE  QRY_Movcxc('','',0,'2022-11-01', '2022-11-17', '','','F');
EXECUTE PROCEDURE  QRY_Movcxc('','',33775,'2022-10-17', '2022-10-17', '','','D');

CREATE PROCEDURE QRY_Movcxc
(
	paramCia		CHAR(2),
	paramPla		CHAR(18),
	paramFolio   	CHAR(10),
	paramFecIni		DATE,
	paramFecFin		DATE,
	paramMov		CHAR(2),
	paramCte		CHAR(6),
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
DEFINE vpla1 	CHAR(2);
DEFINE vpla2 	CHAR(2);
DEFINE vpla3 	CHAR(2);
DEFINE vpla4 	CHAR(2);
DEFINE vpla5 	CHAR(2);
DEFINE vpla6 	CHAR(2);
DEFINE vpla7 	CHAR(2);
DEFINE vpla8 	CHAR(2);
DEFINE vpla9 	CHAR(2);

LET vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9 = get_plantas(paramPla);

IF paramFolio <> '0' THEN
	IF paramGrupo = 'D'	THEN
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
			WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.fliq_mcxc = paramFolio
			ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte
				
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
			WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.fliq_mcxc = paramFolio
					and ffac_mcxc is not null and sfac_mcxc is not null
			GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte			
			UNION ALL
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
			WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.fliq_mcxc = paramFolio
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
	END IF;
ELSE
	IF paramFecIni <> '' AND paramFecFin <> '' AND paramCia = '' AND paramPla = '' AND paramMov = '' AND paramCte = '' THEN
		IF paramGrupo = 'D'	THEN
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
				WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49' AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
				ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte
					
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
				WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49' AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
						and ffac_mcxc is not null and sfac_mcxc is not null
				GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte			
				UNION ALL
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
				WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49' AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
		END IF;
	ELSE	
		IF paramGrupo = 'D'	THEN
			IF paramCia <> '' AND paramPla <> '' THEN
				IF paramMov <> '' THEN
					IF paramCte <> '' THEN
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
							WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov AND m.cte_mcxc = paramCte
									AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
							WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov 
									AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
							ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte
								
							RETURN 	vmovdes, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte 
							WITH RESUME;
						END FOREACH;
					END IF;
				ELSE
					IF paramCte <> '' THEN
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
							WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.cte_mcxc = paramCte AND m.tpm_mcxc > '49'
									AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
							WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) 
									AND fec_mcxc BETWEEN paramFecIni AND paramFecFin AND m.tpm_mcxc > '49'
							ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte
								
							RETURN 	vmovdes, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte 
							WITH RESUME;
						END FOREACH;
					END IF;
				END IF;
			ELSE
				IF paramMov <> '' THEN
					IF paramCte <> '' THEN
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
							WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov AND m.cte_mcxc = paramCte
									AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
							WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov 
									AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
							ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte
								
							RETURN 	vmovdes, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte 
							WITH RESUME;
						END FOREACH;
					END IF;
				ELSE
					IF paramCte <> '' THEN
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
							WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.cte_mcxc = paramCte AND m.tpm_mcxc > '49'
									AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
							WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND fec_mcxc BETWEEN paramFecIni AND paramFecFin AND m.tpm_mcxc > '49'
							ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte
								
							RETURN 	vmovdes, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte, vnomcte 
							WITH RESUME;
						END FOREACH;
					END IF;
				END IF;
			END IF;	
		ELSE
			IF paramGrupo = 'F' THEN
				IF paramCia <> '' AND paramPla <> '' THEN
					IF paramMov <> '' THEN
						IF paramCte <> '' THEN
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
										max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
										sum(m.imp_mcxc), c.num_cte
								INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
								FROM	mov_cxc m, cliente c
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov AND m.cte_mcxc = paramCte
										AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
										and ffac_mcxc is not null and sfac_mcxc is not null
								GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc			
								UNION ALL
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
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov AND m.cte_mcxc = paramCte
										AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
										max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
										sum(m.imp_mcxc), c.num_cte
								INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
								FROM	mov_cxc m, cliente c
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov 
										AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
										and ffac_mcxc is not null and sfac_mcxc is not null
								GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc, m.sfac_mcxc, c.num_cte, fec_mcxc			
								UNION ALL
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
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov
										AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
						END IF;
					ELSE
						IF paramCte <> '' THEN
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
										max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
										sum(m.imp_mcxc), c.num_cte
								INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
								FROM	mov_cxc m, cliente c
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.cte_mcxc = paramCte AND m.tpm_mcxc > '49'
										AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
										and ffac_mcxc is not null and sfac_mcxc is not null
								GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc			
								UNION ALL
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
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.cte_mcxc = paramCte AND m.tpm_mcxc > '49'
										AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
										max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
										sum(m.imp_mcxc), c.num_cte
								INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
								FROM	mov_cxc m, cliente c
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49' 
										AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
										and ffac_mcxc is not null and sfac_mcxc is not null
								GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc			
								UNION ALL
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
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49' 
										AND m.cia_mcxc = paramCia AND m.pla_mcxc in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
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
						END IF;
					END IF;
				ELSE
					IF paramMov <> '' THEN
						IF paramCte <> '' THEN
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
										max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
										sum(m.imp_mcxc), c.num_cte
								INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
								FROM	mov_cxc m, cliente c
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov AND m.cte_mcxc = paramCte
										AND fec_mcxc BETWEEN paramFecIni AND paramFecFin
										and ffac_mcxc is not null and sfac_mcxc is not null
								GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc			
								UNION ALL
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
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov AND m.cte_mcxc = paramCte
										AND fec_mcxc BETWEEN paramFecIni AND paramFecFin AND ffac_mcxc is null and sfac_mcxc is null
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
										max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
										sum(m.imp_mcxc), c.num_cte
								INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
								FROM	mov_cxc m, cliente c
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov 
										AND fec_mcxc BETWEEN paramFecIni AND paramFecFin and ffac_mcxc is not null and sfac_mcxc is not null
								GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc		
								UNION ALL
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
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc = paramMov 
										AND fec_mcxc BETWEEN paramFecIni AND paramFecFin AND ffac_mcxc is null and sfac_mcxc is null
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
					ELSE
						IF paramCte <> '' THEN
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
										max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
										sum(m.imp_mcxc), c.num_cte
								INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
								FROM	mov_cxc m, cliente c
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.cte_mcxc = paramCte AND m.tpm_mcxc > '49'
										AND fec_mcxc BETWEEN paramFecIni AND paramFecFin and ffac_mcxc is not null and sfac_mcxc is not null
								GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc			
								UNION ALL
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
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.cte_mcxc = paramCte AND m.tpm_mcxc > '49'
										AND fec_mcxc BETWEEN paramFecIni AND paramFecFin AND ffac_mcxc is null and sfac_mcxc is null
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
										max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
										sum(m.imp_mcxc), c.num_cte
								INTO	vmovdes, vmov, vdes, vtip, vfolio, vserie, vcia, vpla, vfecha, vcargo, vabono, vnumcte					
								FROM	mov_cxc m, cliente c
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49'
										AND fec_mcxc BETWEEN paramFecIni AND paramFecFin and ffac_mcxc is not null and sfac_mcxc is not null
								GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc		
								UNION ALL
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
								WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49'
										AND fec_mcxc BETWEEN paramFecIni AND paramFecFin AND ffac_mcxc is null and sfac_mcxc is null
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
			END IF;
		END IF;
	END IF;
END IF;

END PROCEDURE; 

SELECT	m.fliq_mcxc, CASE
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
FROM	mov_cxc m, cliente c
WHERE	m.cte_mcxc = c.num_cte AND m.fliq_mcxc = 10385 --and tpm_mcxc = '58'
--group by m.ffac_mcxc ,m.sfac_mcxc
ORDER BY m.fec_mcxc, m.tpm_mcxc, c.num_cte


SELECT	max(m.fliq_mcxc), CASE
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
		max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, max(fec_mcxc), 0.00, sum(m.imp_mcxc), 
		c.num_cte
FROM	mov_cxc m, cliente c
WHERE	m.cte_mcxc = c.num_cte AND m.fliq_mcxc = 10377 and ffac_mcxc is not null and sfac_mcxc is not null
group by cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte
UNION ALL
SELECT	m.fliq_mcxc, CASE
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
WHERE	m.cte_mcxc = c.num_cte AND m.fliq_mcxc = 10377 and ffac_mcxc is null and sfac_mcxc is null
ORDER BY c.num_cte

select	m.tpm_mcxc
from	mov_cxc m
group by m.tpm_mcxc
order by m.tpm_mcxc

select	*
from	mov_cxc
where 	fliq_mcxc = 57521

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
		max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
		sum(m.imp_mcxc), c.num_cte			
FROM	mov_cxc m, cliente c
WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49'
		AND fec_mcxc BETWEEN '2022-11-01' AND '2022-11-22' and ffac_mcxc is not null and sfac_mcxc is not null
		and c.num_cte = '128335'
GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc	

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
FROM	mov_cxc m, cliente c
WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.fliq_mcxc = 63589
		and ffac_mcxc is not null and sfac_mcxc is not null
GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte	

select	sum(imp_mcxc)
from 	mov_cxc
where	fec_mcxc = '2023-01-31' and tpm_mcxc > '49' and sta_mcxc = 'A'

select	ffac_mcxc, sfac_mcxc, sum(imp_mcxc)
from 	mov_cxc
where	fec_mcxc = '2023-01-31' and tpm_mcxc > '49' and sta_mcxc = 'A'
		and ffac_mcxc is not null and sfac_mcxc is not null
group by 1,2

select	doc_mcxc, ser_mcxc, imp_mcxc
from 	mov_cxc
where	fec_mcxc = '2023-01-31' and tpm_mcxc > '49' and sta_mcxc = 'A'
		and ffac_mcxc is null and sfac_mcxc is null
		
select	*
from	mov_cxc
where	doc_mcxc = 17690 and fec_mcxc = '2023-01-31'

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
		max(m.tpm_mcxc), max(desc_mcxc), max(tip_mcxc), ffac_mcxc, sfac_mcxc, cia_mcxc, pla_mcxc, fec_mcxc, 0.00,
		sum(m.imp_mcxc), c.num_cte	
FROM	mov_cxc m, cliente c
WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49'
		AND fec_mcxc BETWEEN '2023-01-31' AND '2023-01-31' and ffac_mcxc is not null and sfac_mcxc is not null
GROUP BY cia_mcxc, pla_mcxc, m.ffac_mcxc ,m.sfac_mcxc, c.num_cte, fec_mcxc		
UNION ALL ALL
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
WHERE	m.sta_mcxc = 'A' AND m.cte_mcxc = c.num_cte AND m.tpm_mcxc > '49'
		AND fec_mcxc BETWEEN '2023-01-31' AND '2023-01-31' AND ffac_mcxc is null and sfac_mcxc is null
ORDER BY 9,2,12	
		
		