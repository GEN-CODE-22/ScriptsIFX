DROP PROCEDURE InsNotaVtaNoServ
CREATE PROCEDURE InsNotaVtaNoServ
(
	paramFol	INT, 
	paramCia 	CHAR(2), 
	paramPla 	CHAR(2), 	
	paramCte 	CHAR(6),
	paramTqe 	SMALLINT, 
	paramRuta 	CHAR(4), 
	paramTipo 	CHAR(1), 
	paramUso 	CHAR(2),
	paramFep 	DATETIME YEAR TO MINUTE, 
	paramFes 	DATE,	
	paramFliq	INTEGER,
	paramEdo 	CHAR(1), 
	paramRfa 	CHAR(1),
	paramTpa 	CHAR(1),  
	paramNapl 	CHAR(1), 
	paramNept 	CHAR(1),
	paramTlts	DECIMAL,
	paramPru	DECIMAL,
	paramImpt	DECIMAL,	
	paramUsr 	CHAR(8),
	paramTpdo	CHAR(1),
	paramProd 	CHAR(3),
	paramFolEnr CHAR(12),
	paramAsiste CHAR(1)
)

	RETURNING
		CHAR(1);				

	DEFINE control		CHAR(1);	
	DEFINE prodType		CHAR(3);	
	DEFINE ivaPer		DECIMAL;	
	DEFINE ivaSale		DECIMAL;	
	DEFINE subImp		DECIMAL;	
    DEFINE region		SMALLINT; 	
	DEFINE price		DECIMAL;	
	DEFINE totalImp		DECIMAL;	
	DEFINE vfolenr		CHAR(12);  
	DEFINE vasiste		CHAR(1);
	DEFINE vimpasi		DECIMAL; 
	DEFINE vimpasidat	DECIMAL; 
	DEFINE vvuelta		INT;
	
	LET vasiste = 'N';
	LET vimpasi = 0;
	LET vimpasidat = 0;
	
	SELECT	 vuelta_pla
    INTO	 vvuelta
    FROM	 planta 
    WHERE	 cia_pla = paramCia and cve_pla = paramPla;

	IF paramAsiste = 'S' THEN
		SELECT	NVL(impest_dat,0)
		INTO	vimpasidat
		FROM	datos;
		IF vimpasidat > 0 THEN
			LET vasiste = 'S';
			LET vimpasi = vimpasidat;
		END IF;		
	ELSE
		IF LENGTH(paramFolEnr) > 0 THEN
			SELECT	NVL(asiste_enr,'N'),NVL(impasi_enr,0)
			INTO	vasiste,vimpasi
			FROM	enruta
			WHERE	fol_enr = paramFolEnr and ruta_enr = paramRuta;
		END IF;
	END IF;		
	
	LET control = 'A'; 

	IF	paramProd = 'N/A' OR paramProd IS NULL OR LENGTH(paramProd) = 0 THEN
	
		SELECT 	NVL(precio_tqe,'')
		INTO	prodType
		FROM 	tanque
		WHERE	numcte_tqe = paramCte AND numtqe_tqe = paramTqe;
	
	
		IF LENGTH(prodType) = 0 THEN
			
			IF EXISTS(SELECT 1 FROM ri505_neco WHERE ruta_rneco = paramRuta) THEN		
			
				SELECT	reg_rneco
				INTO	region
				FROM	ri505_neco
				WHERE	ruta_rneco = paramRuta;
				
				SELECT	tpr_prc
				INTO	prodType
				FROM	precios
				WHERE	reg_prc = region
				AND 	tid_prc = paramTipo
				AND 	pri_prc = 'S';
				
				LET control = 'R'; 
			
			ELSE		
				
				SELECT	polts_dat
				INTO	prodType
				FROM	datos;
				
				LET control = 'D'; 
						
			END IF;		
		
		END IF;
	ELSE
		LET prodType = paramProd;
	END IF;
	
	SELECT	NVL(pru_mprc,0), 
			NVL(iva_mprc,0)
	INTO	price, 
			ivaPer
	FROM	mov_prc
	WHERE	tpr_mprc = prodType
	AND 	fei_mprc <= paramFes
	AND 	fet_mprc >= paramFes;	

	LET	totalImp = (price * paramTlts);
	LET subImp = totalImp / ((ivaPer / 100) + 1);
	LET ivaSale = totalImp - subImp;
	
	INSERT INTO nota_vta(
						fol_nvta, 
						cia_nvta, 
						pla_nvta, 						
						numcte_nvta, 
						numtqe_nvta, 
						ruta_nvta, 
						tip_nvta, 
						uso_nvta, 
						fep_nvta,
						fes_nvta,
						fliq_nvta,
						edo_nvta, 
						rfa_nvta, 
						tpa_nvta, 
						napl_nvta, 
						nept_nvta, 
						tlts_nvta,
						tprd_nvta,
						pru_nvta,
						simp_nvta,
						iva_nvta,
						ivap_nvta,
						impt_nvta,						
						usr_nvta, 
						tpdo_nvta,
						asiste_nvta,
						impasi_nvta,
						vuelta_nvta
						)						
	VALUES			  (
						paramFol, 
						paramCia, 
						paramPla, 						
						paramCte, 
						paramTqe, 
						paramRuta, 
						paramTipo, 
						paramUso, 
						paramFep,
						paramFes, 
						paramFliq,
						paramEdo, 
						paramRfa, 
						paramTpa, 			
						paramNapl,					
						'S',
						paramTlts,
						prodType,
						price,
						subImp,
						ivaSale,
						ivaPer,
						totalImp,						
						paramUsr,
						paramTpdo,
						vasiste,
						vimpasi,
						vvuelta);		
	EXECUTE PROCEDURE set_lastchargedate(paramCia,paramPla,paramCte,paramTqe);
	
	RETURN control;
	
END PROCEDURE;

select	*
from	precios

select	*
from	mov_prc
where	tpr_mprc = '001'
order by fei_mprc desc