CREATE PROCEDURE ChangeClientNote(
	paramFolio	INTEGER,
	paramFolEnr CHAR(12),
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramCte	CHAR(6),
	paramTqe	INTEGER,
	paramNvoN   INTEGER,
	paramUsr	CHAR(8)
)

	RETURNING
		CHAR(1);			
		
			
	DEFINE control	CHAR(1);			
	
	DEFINE vcteori 		CHAR(6); 		
	DEFINE vnumped		INT;			
	DEFINE vfolnvta		INT;			
	DEFINE vcountnvta	INT;			
	DEFINE vcountenr	INT;			
	DEFINE vprecio		CHAR(3);		
	DEFINE vprcuni		DECIMAL;		
	DEFINE vregion		INT;			
	DEFINE vservtqe		CHAR(1);		
	DEFINE vtipcte		CHAR(1);		
	DEFINE vtipop		CHAR(1);		
	DEFINE vfliq		INTEGER;		
	DEFINE vcfolnvta	CHAR(10);		
	
	DEFINE vtipori		CHAR(1);
	DEFINE vrfaori		CHAR(1);
	DEFINE vusoori		CHAR(2);
	DEFINE vservori		CHAR(1);
	
	DEFINE vTipPed 		CHAR(1);
	DEFINE vNumCte 		CHAR(6); 
	DEFINE vLada 		SMALLINT;
	DEFINE vTel 		INTEGER; 
	DEFINE vNumTqe 		SMALLINT; 
	DEFINE vRuta 		CHAR(4); 
	DEFINE vRutaLiq		CHAR(4); 
	DEFINE vObserv 		CHAR(40); 
	DEFINE vReqFac 		CHAR(1); 

	DEFINE vFecSur 		DATE; 
	DEFINE vUsrPed 		CHAR(8); 
	DEFINE vEdoTx 		CHAR(1); 
	DEFINE vNumModif	SMALLINT; 
	DEFINE vNumTx 		SMALLINT; 
	DEFINE vTpdo 		CHAR(1);
	
	DEFINE vtipo	 	CHAR(1);
	DEFINE vtipserv		CHAR(1);
	DEFINE vuso		 	CHAR(2);
	DEFINE vrfa		 	CHAR(1);
	DEFINE vser		 	CHAR(4);
	DEFINE vtpa		 	CHAR(1);  
	DEFINE vnapl	 	CHAR(1); 
	DEFINE vnept	 	CHAR(1); 
	DEFINE vtprd 		CHAR(3);
	DEFINE vntpdo 		CHAR(1);
	DEFINE vpru 		DECIMAL;
	DEFINE vfep 		DATETIME YEAR TO MINUTE;
	DEFINE vfes 		DATE;
	DEFINE vusr 		CHAR(8);
	
	DEFINE vfolenr	CHAR(12);		
	DEFINE vnom		CHAR(50);		
	DEFINE vdir		CHAR(50);		
	DEFINE vtpgo	SMALLINT;		
	DEFINE vprc		CHAR(6);		
	DEFINE vrfc		CHAR(13);		
	DEFINE vfecreg	CHAR(6);		
	DEFINE veco		CHAR(6);		
	DEFINE prodType		CHAR(3);	
	DEFINE region		SMALLINT; 	
	
	DEFINE vsimpt_nvta	DECIMAL;
	DEFINE viva_nvta	DECIMAL;
	DEFINE vpru_mprc	DECIMAL;
	DEFINE viva_mprc	DECIMAL;
	DEFINE vtlts		DECIMAL;
	DEFINE vobserlog	CHAR(1500);
		
	LET control = 'A';
	LET vnumped = 0;
	LET vnom = '';
	LET vcfolnvta = paramFolio || '';
	LET vprc = '';
	
	
	SELECT	fliq_nvta,
			numcte_nvta,
			ped_nvta,
			tip_nvta,
			uso_nvta,
			rfa_nvta,
			ser_nvta,
			tpa_nvta,
			napl_nvta,
			nept_nvta,
			tprd_nvta,
			tpdo_nvta,
			pru_nvta,
			fep_nvta,
			fes_nvta,
			usr_nvta,
			ruta_nvta,
			tlts_nvta
	INTO	vfliq,
			vcteori,
			vnumped,
			vtipo,
			vuso,
			vrfa,
			vser,
			vtpa,
			vnapl,
			vnept,
			vtprd,		
			vntpdo,
			vpru,
			vfep,
			vfes,
			vusr,
			vRutaLiq,
			vtlts
	FROM	nota_vta
	WHERE	fol_nvta 		= paramFolio
			AND cia_nvta	= paramCia
			AND pla_nvta	= parampla;
			
	LET vobserlog = '1. OBTIENE DATOS DE NOTA DE VENTA';
	INSERT INTO log(fhpr_log, observ_log,usr_log)
	VALUES(CURRENT,vobserlog,'FUENTE');
			
	SELECT	tipo_ped,
			numcte_ped,
			lada_ped,
			tel_ped,
			numtqe_ped,
			ruta_ped,
			observ_ped,
			rfa_ped,
			fecsur_ped,
			usr_ped,
			edotx_ped,
			nmod_ped,
			nmtx_ped,
			tpdo_ped
	INTO	vTipPed,
			vNumCte,
			vLada,
			vTel,
			vNumTqe,
			vRuta,
			vObserv,
			vReqFac,
			vFecSur,
			vUsrPed,
			vEdoTx,
			vNumModif,
			vNumTx,
			vTpdo
	FROM	pedidos
	WHERE	num_ped 		= vnumped
			AND	numcte_ped 	= vcteori;
			--AND edo_ped		= 'p';
	LET vobserlog = '2. OBTIENE DATOS DE PEDIDO';
	INSERT INTO log(fhpr_log, observ_log,usr_log)
	VALUES(CURRENT,vobserlog,'FUENTE');
			
	SELECT	uso_cte,
			tip_cte
	INTO	vusoori,
			vtipcte
	FROM	cliente
	WHERE	num_cte = paramCte;
	
	LET vobserlog = '3. OBTIENE DATOS DE CLIENTE';
	INSERT INTO log(fhpr_log, observ_log,usr_log)
	VALUES(CURRENT,vobserlog,'FUENTE');
	
	SELECT	serv_tqe
	INTO	vtipserv
	FROM	tanque
	WHERE	numcte_tqe 		= paramCte
			AND numtqe_tqe  = paramTqe;	

	LET vtipo = vtipserv;
	IF vtipo = 'I' OR vtipo = 'F' OR vtipo = 'P' OR vtipo = 'T' THEN
        LET vtipo = vtipcte;
    END IF;
    
	LET vtipop = vtipcte;
	IF vtipo = 'F' OR vtipo = 'H' OR vtipo = 'I' OR vtipo = 'K' OR vtipo = 'O' OR vtipo = 'P' OR vtipo = 'Q' OR vtipo = 'T' THEN
        LET vtipop = vtipo;
    END IF;    
    
	
	IF control = 'A' THEN
		
		IF EXISTS(select 1 from tanque where numcte_tqe=paramCte and numtqe_tqe=paramTqe) THEN
			SELECT 	tpr_mprc, pru_mprc, iva_mprc
			INTO	prodType,vpru_mprc,viva_mprc
			FROM 	mov_prc
			WHERE 	tpr_mprc=(select precio_tqe from tanque where numcte_tqe=paramCte and numtqe_tqe=paramTqe)
					and fei_mprc<=date(current)
					and fet_mprc>=date(current);
		END IF;
		
		IF prodType IS NULL OR LENGTH(prodType) = 0 THEN
			IF EXISTS(SELECT 1 FROM ri505_neco WHERE ruta_rneco = vRutaLiq) THEN	
				SELECT	reg_rneco
				INTO	region
				FROM	ri505_neco
				WHERE	ruta_rneco = vRutaLiq;
				
				SELECT	tpr_prc
				INTO	prodType
				FROM	precios
				WHERE	reg_prc = region
				AND 	tid_prc = vtipo
				AND 	pri_prc = 'S';		
			ELSE						
				SELECT	polts_dat
				INTO	prodType
				FROM	datos;
			END IF;
			
			SELECT	NVL(pru_mprc,0), 
					NVL(iva_mprc,0)
			INTO	vpru_mprc, 
					viva_mprc
			FROM	mov_prc
			WHERE	tpr_mprc = prodType
			AND 	fei_mprc <= date(current)
			AND 	fet_mprc >= date(current);		
		END IF;	
		
		LET vobserlog = '3.1 OBTIENE PRODUCTO DE LA NOTA ' || NVL(prodType,'N/A');
		INSERT INTO log(fhpr_log, observ_log,usr_log)
		VALUES(CURRENT,vobserlog,'FUENTE');
		
		LET vsimpt_nvta = (vpru_mprc * vtlts) / ((viva_mprc / 100) + 1) ;
		LET viva_nvta 	= (vpru_mprc * vtlts) - vsimpt_nvta;
		
		UPDATE	nota_vta	
		SET		numcte_nvta 	= paramCte,
				numtqe_nvta 	= paramTqe,
				uso_nvta		= vusoori,
				tip_nvta		= vtipo,
				tprd_nvta		= prodType,
				pru_nvta		= vpru_mprc,					
				impt_nvta		= vsimpt_nvta + viva_nvta,
				simp_nvta		= vsimpt_nvta,
				iva_nvta		= viva_nvta,
				ivap_nvta		= viva_mprc,
				tpa_nvta		= vtipop
		WHERE	fol_nvta 		= paramFolio
				AND cia_nvta	= paramCia
				AND pla_nvta	= paramPla;
		
					
		
		LET vobserlog = 'CAMBIO CLIENTE EN NOTA DE VENTA CLIENTE ORIGINAL[' || vcteori || '] CLIENTE NUEVO[' || paramCte || ']';
		EXECUTE PROCEDURE InsChangeLiq(paramCia,paramPla,paramFolio,paramUsr,vobserlog);
		LET vobserlog = '4. ACTUALIZA NOTA DE VENTA';
		INSERT INTO log(fhpr_log, observ_log,usr_log)
		VALUES(CURRENT,vobserlog,'FUENTE');		
		
		EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,vcteori,vNumTqe);		
		
		EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,paramCte,paramTqe);
				
		IF vnumped > 0	THEN
			UPDATE  pedidos
			SET		edo_ped	= 'S'
			WHERE	num_ped = vnumped;
			
			LET vobserlog = 'ChangeClientNote:SE CANCELA EL PEDIDO ACTUAL DEL CLIENTE[' || vnumped || ']';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');			
			
		END IF;
		
		SELECT	NVL(fol_nvta,0),
				NVL(ped_nvta,0)
		INTO	vfolnvta,
				vnumped
		FROM	nota_vta
		WHERE	numcte_nvta	 	= paramCte
				AND numtqe_nvta	= paramTqe
				AND cia_nvta 	= paramCia
				AND pla_nvta 	= paramPla
				AND fes_nvta	= vfes
				AND edo_nvta 	= 'P';
		LET vobserlog = '6. BUSCA EL PEDIDO DEL CLIENTE NUEVO';
		INSERT INTO log(fhpr_log, observ_log,usr_log)
		VALUES(CURRENT,vobserlog,'FUENTE');
				
		IF vnumped > 0	THEN
			UPDATE	pedidos
			SET		edo_ped	= 'S'	
			WHERE	num_ped = vnumped;
			LET vobserlog = '6. ACTUALIZA A SURTIDO EL PEDIDO';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');
			
			UPDATE	nota_vta	
			SET		ped_nvta	= vnumped
			WHERE	fol_nvta 	= paramFolio
					AND cia_nvta= paramCia
					AND pla_nvta= paramPla;	
			LET vobserlog = '7. ACTUALIZA NOTA DE VENTA EN PEDIDO';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');
			
			SELECT	nom_enr,
	  				dir_enr,
		  			prc_enr,
		  			tippgo_enr,
		  			rfc_enr,
		  			fecreg_enr,
		  			eco_enr  		
		  	INTO	vnom,
		  			vdir,
		  			vprc,
		  			vtpgo,
		  			vrfc,
		  			vfecreg,
		  			veco
		  	FROM	enruta
		  	WHERE	fol_enr = paramCia || paramPla || LPAD(vfolnvta,6,'0');
		  	LET vobserlog = '8. OBTIENE DATOS DE ENRUTA';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');	
			
		END IF;
		
		IF vnom IS NULL OR LENGTH(vnom) = 0 THEN
			
			SELECT	CASE 
					WHEN TRIM(cliente.razsoc_cte) <> '' THEN
					   TRIM(cliente.razsoc_cte) 
					ELSE 
					   CASE
						  WHEN cliente.ali_cte <> '' THEN
							 TRIM(cliente.ali_cte) || ', ' 
						  ELSE
							 '' 
					   END || trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
					END,
					rfc_cte,
					tip_cte
			INTO	vnom,
					vrfc,
					vtipcte
			FROM	cliente		
			WHERE	num_cte	= vcteori;
			LET vobserlog = '10. OBTIENE DATOS DE CLIENTE';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');	
			
			SELECT	TRIM(tanque.dir_tqe) || ' ' || TRIM(tanque.col_tqe) || ' ' || TRIM(tanque.ciu_tqe),
					serv_tqe,
					NVL(precio_tqe,'')
			INTO	vdir,
					vservtqe,
					vprecio
			FROM	tanque		
			WHERE	numcte_tqe		= vcteori
					AND numtqe_tqe 	= vNumTqe;
			LET vobserlog = '11. OBTIENE DATOS DE TANQUE';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');	
					
			LET vfecreg = TO_CHAR(vfes, '%d%m%y');
			
			SELECT	eco_enr
			INTO	veco
			FROM	enruta
			WHERE	fol_enr = paramFolEnr;
			LET vobserlog = '12. OBTIENE ECONOMICO DE ENRUTA';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');	
			
			IF LENGTH(vprecio) = 0 THEN
				SELECT	reg_rneco
				INTO	vregion
				FROM	ri505_neco
				WHERE	ruta_rneco = vRuta;
				LET vobserlog = '13. OBTIENE REGION';
				INSERT INTO log(fhpr_log, observ_log,usr_log)
				VALUES(CURRENT,vobserlog,'FUENTE');	

				SELECT	tpr_prc
				INTO	vprecio
				FROM	precios
				WHERE	reg_prc = vregion
						AND tid_prc = vservtqe
						AND pri_prc = 'S';
				LET vobserlog = '14. OBTIENE PRODUCTO';
				INSERT INTO log(fhpr_log, observ_log,usr_log)
				VALUES(CURRENT,vobserlog,'FUENTE');	
	
				SELECT	NVL(pru_mprc,0)
				INTO	vprcuni
				FROM	mov_prc
				WHERE	tpr_mprc = vprecio
						AND fei_mprc <= vfes
						AND fet_mprc >= vfes;
				LET vobserlog = '15A. OBTIENE PRECIO UNITARIO';
				INSERT INTO log(fhpr_log, observ_log,usr_log)
				VALUES(CURRENT,vobserlog,'FUENTE');	
				
			ELSE 
				SELECT	NVL(pru_mprc,0)
				INTO	vprcuni
				FROM	mov_prc
				WHERE	tpr_mprc = vprecio
						AND fei_mprc <= vfes
						AND fet_mprc >= vfes;
				LET vobserlog = '15B. OBTIENE PRECIO UNITARIO';
				INSERT INTO log(fhpr_log, observ_log,usr_log)
				VALUES(CURRENT,vobserlog,'FUENTE');	
			END IF;
		END IF;
		LET vtpgo = get_tpgoenr(vtipcte);
		
		LET vobserlog = 'vprc: ' || vprc;
		INSERT INTO log(fhpr_log, observ_log,usr_log)
		VALUES(CURRENT,vobserlog,'FUENTE');
		LET vobserlog = 'vprcuni: ' || vprcuni;
		INSERT INTO log(fhpr_log, observ_log,usr_log)
		VALUES(CURRENT,vobserlog,'FUENTE');		
		IF vprc IS NULL OR LENGTH(vprc) = 0 THEN
			LET vprc = vprcuni || '';	
		END IF;
		UPDATE	enruta
		SET		numcte_enr  = paramCte,
				nom_enr		= vnom,
				dir_enr		= vdir,
				prc_enr		= vprc,
				tippgo_enr	= vtpgo,
				rfc_enr		= vrfc
		WHERE	fol_enr		= paramFolEnr;
		LET vobserlog = 'ChangeClientNote:SE ACTUALIZA EL CLIENTE EN ENRUTA[' || paramFolEnr || ']';
		INSERT INTO log(fhpr_log, observ_log,usr_log)
		VALUES(CURRENT,vobserlog,'FUENTE');
		LET vobserlog = '16. ACTUALIZA CLIENTE ENRUTA';
		INSERT INTO log(fhpr_log, observ_log,usr_log)
		VALUES(CURRENT,vobserlog,'FUENTE');	
		
		IF vfolnvta > 0 THEN
			UPDATE	nota_vta
			SET		edo_nvta 		= 'P', 	
					fliq_nvta 		= null, 
					tlts_nvta 		= null, 
					pru_nvta 		= null,	
					simp_nvta 		= null,	
					iva_nvta 		= null,
					ivap_nvta 		= null, 
					impt_nvta 		= null,	
					numcte_nvta		= null
		  	WHERE	fol_nvta 		= vfolnvta
		  			AND	cia_nvta 	= paramCia
		  			AND	pla_nvta 	= paramPla;
		  	LET vobserlog = 'ChangeClientNote:LA NOTA DE VENTA DEL CLIENTE NUEVO SE DEJA EN BLANCO SI ESTA PENDIENTE[' || vfolnvta || ']';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');
			LET vobserlog = '17. LA NOTA DE VENTA DEL CLIENTE NUEVO SE DEJA EN BLANCO SI ESTA PENDIENTE';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');	
	  	END IF;

	  	SELECT	NVL(fol_enr,'')
		INTO	vcountenr
		FROM	enruta
		WHERE	fol_enr	= paramCia || paramPla || vfolnvta
				AND edoreg_enr <> 'F';	
		LET vobserlog = '18. OBTIENE FOLIO ENRUTA';
		INSERT INTO log(fhpr_log, observ_log,usr_log)
		VALUES(CURRENT,vobserlog,'FUENTE');	
		IF	vcountenr > 0 THEN
	  		UPDATE	enruta
			SET		edovta_enr  = 'f',
					edoreg_enr	= 'F'
			WHERE	fol_enr		= paramCia || paramPla || vfolnvta;
			LET vobserlog = 'ChangeClientNote:REGISTRO DEL CLIENTE NUEVO SE FINALIZA EN ENRUTA SI ES QUE ESTA PENDIENTE[' || vfolnvta || ']';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');
			LET vobserlog = '19. ACTUALIZA ENRUTA';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');	
		END IF;
		IF paramNvoN = 1 THEN
			SELECT	COUNT(*)
			INTO	vcountnvta
			FROM	nota_vta
			WHERE	numcte_nvta		= vcteori
					AND numtqe_nvta = paramTqe
					AND fes_nvta	= vfes
					AND edo_nvta	IN('S','A')
		  			AND	cia_nvta 	= paramCia
		  			AND	pla_nvta 	= paramPla;
		  	LET vobserlog = '20. BUSCA SI SURTIO EL CLIENTE';
			INSERT INTO log(fhpr_log, observ_log,usr_log)
			VALUES(CURRENT,vobserlog,'FUENTE');	
		  	IF vcountnvta = 0 THEN	
		  		LET vnumped = InsertaPedidoEst(vTipPed, vcteori, vLada, vTel, vNumTqe, vRuta, vObserv, vReqFac, vFecSur, 'p', vUsrPed, vEdoTx, vNumModif, vNumTx, vTpdo);
		  		LET vobserlog = 'ChangeClientNote:INSERTA EL PEDIDO[' || vnumped || ']';
				INSERT INTO log(fhpr_log, observ_log,usr_log)
				VALUES(CURRENT,vobserlog,'FUENTE');
				LET vobserlog = '21. INSERTA PEDIDO';
				INSERT INTO log(fhpr_log, observ_log,usr_log)
				VALUES(CURRENT,vobserlog,'FUENTE');
		  		IF vnumped > 0 THEN
		  			LET	vfolnvta = next_fol_nvta(paramCia, paramPla);
					
					IF vfolnvta > 0 THEN
			  			INSERT INTO nota_vta(fol_nvta, cia_nvta, pla_nvta, ped_nvta, numcte_nvta, numtqe_nvta, ruta_nvta, tip_nvta, uso_nvta, 
											fep_nvta, fes_nvta, edo_nvta, rfa_nvta, tpa_nvta, napl_nvta, nept_nvta, tprd_nvta, pru_nvta, usr_nvta, 
											tpdo_nvta)
						        
						VALUES			  (vfolnvta, paramCia, paramPla, vnumped, vcteori, paramTqe, vRuta, vtipo, vuso, vfep, vfes, 'P',
											vrfa, vtpa, vnapl, vnept, vtprd, vpru, vusr, vntpdo);
						
						LET vobserlog = 'ChangeClientNote:INSERTA NOTA DE VENTA[' || vfolnvta || ']';
						INSERT INTO log(fhpr_log, observ_log,usr_log)
						VALUES(CURRENT,vobserlog,'FUENTE');	
						LET vobserlog = '22. INSERTA NOTA DE VENTA';
						INSERT INTO log(fhpr_log, observ_log,usr_log)
						VALUES(CURRENT,vobserlog,'FUENTE');
									
						LET vfolenr = paramCia || paramPla || LPAD(vfolnvta,6,'0');
						IF vprcuni = 0  THEN
							LET vprc = '0.0000';
						ELSE
							LET vprc = vprcuni || '';
						END IF;
			
			  			INSERT INTO enruta(fol_enr, numcte_enr, nom_enr, dir_enr, rfc_enr, fecreg_enr, prc_enr, eco_enr, ruta_enr, edovta_enr, 
										ltssur_enr, edoreg_enr, obser_enr, faccal_enr, tippgo_enr, com_enr)
						VALUES		(vfolenr, paramCte, vnom, vdir, vrfc, vfecreg, vprc, veco, vRuta, '0', '0', '0', ' ', '31',	vtpgo, ' ');
						
						LET vobserlog = 'ChangeClientNote:INSERTA EN ENRUTA[' || vfolenr || ']';
						INSERT INTO log(fhpr_log, observ_log,usr_log)
						VALUES(CURRENT,vobserlog,'FUENTE');	
						LET vobserlog = '23. INSERTA ENRUTA';
						INSERT INTO log(fhpr_log, observ_log,usr_log)
						VALUES(CURRENT,vobserlog,'FUENTE');
					END IF;
		  		END IF;
		  	END IF;
	  	END IF;
	  	
	  	UPDATE	nota_vta
		SET		impt_nvta		= pru_nvta * tlts_nvta,
				simp_nvta		= (pru_nvta * tlts_nvta) / (1 + (ivap_nvta / 100)),
				iva_nvta		= ((pru_nvta * tlts_nvta) / (1 + (ivap_nvta / 100))) * (ivap_nvta / 100)
		WHERE	cia_nvta 		= paramCia
				AND pla_nvta	= paramPla
				AND ruta_nvta	= vRutaLiq
				AND fliq_nvta	= vfliq;
	END IF;			  
	RETURN	control;
END PROCEDURE; 