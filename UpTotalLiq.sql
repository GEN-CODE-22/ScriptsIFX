DROP PROCEDURE UpTotalLiq;
CREATE PROCEDURE UpTotalLiq(
	paramCompany		CHAR(2),					
	paramBranch			CHAR(2),
	paramLiq 			INTEGER,					
	paramRoute 			CHAR(4),
	paramEco 			CHAR(7),
	paramFecate 		DATE,
	paramLin 			DECIMAL,
	paramLfi 			DECIMAL,
	paramLdif 			DECIMAL,
	paramPin 			DECIMAL,
	paramPfi 			DECIMAL,
	paramPdi 			DECIMAL,
	paramTot 			DECIMAL,
	paramImp 			DECIMAL,
	paramLtsCre 		DECIMAL,
	paramSaleCre 		DECIMAL,
	paramLtsCash 		DECIMAL,
	paramSaleCash		DECIMAL,
	paramLtsPar 		DECIMAL,
	paramUser 			CHAR(8),
	paramNotesNumber 	INTEGER	
	)

	RETURNING
		CHAR(7);		
		
			
	DEFINE control		CHAR(7);			
	DEFINE minDate		CHAR(5);			
	DEFINE maxDate		CHAR(5);				
	DEFINE fesDate 		DATE;			
	DEFINE vimp_erup	DECIMAL;
	DEFINE vvcre_erup	DECIMAL;
	DEFINE vvefe_erup	DECIMAL;
	DEFINE vobser		CHAR(500);
	DEFINE vpend		CHAR(1);
	DEFINE vusrliq		CHAR(8);
	DEFINE vfusrliq		CHAR(8);
	DEFINE vcusrliq		INT;
	DEFINE vtusrliq		INT;
	DEFINE vfolnvtate	INT;
	DEFINE vtltsnvtate	DECIMAL;
	DEFINE vimptnvtate	DECIMAL;
	DEFINE vimptasist	DECIMAL;
	DEFINE vimptasistc	DECIMAL;
	DEFINE vimptotasis	DECIMAL;
	DEFINE vimptasisto	DECIMAL;
	DEFINE vtpanvtate	CHAR(1);
	DEFINE vtltsotr		DECIMAL;
	DEFINE vvtaotr		DECIMAL;
	DEFINE vfolenr		CHAR(16);
	DEFINE vnorefbanco	INT;
	DEFINE vvuelta  	SMALLINT;	
	
	LET control = 'X';
	LET vnorefbanco = 0;
	
	SELECT	NVL(MIN(fol_nvta),0)
	INTO	vnorefbanco
	FROM	nota_vta 
	WHERE 	tpdo_nvta = 'A' and tpa_nvta in('R','B') and (observ_nvta is null or observ_nvta = '')
			AND cia_nvta	= paramCompany
			AND pla_nvta	= paramBranch
			AND ruta_nvta	= paramRoute
			AND fliq_nvta	= paramLiq;
			
	IF vnorefbanco = 0 THEN	
		SELECT	MIN(SUBSTR(fecate_enr, 10,5)) AS fecini,
				MAX(SUBSTR(fecate_enr, 10,5)) AS fecMax
		INTO	minDate,
				maxDate
		FROM	enruta
		WHERE	SUBSTR(fecate_enr,1,8) = TO_CHAR(paramFecate, '%Y%m%d')
		AND		(ruta_enr = paramRoute
		OR		 eco_enr = paramEco)
		AND		edovta_enr = 'l';
		
		UPDATE	empxrutp
		SET		lin_erup = paramLin,
				lfi_erup = paramLfi,
				ldi_erup = paramLdif,
				pin_erup = paramPin,
				pfi_erup = paramPfi,
				pdi_erup = paramPdi,
				tot_erup = paramTot,
				imp_erup = paramImp,
				lcre_erup = paramLtsCre,
				vcre_erup = paramSaleCre,
				lefe_erup = paramLtsCash,
				vefe_erup = paramSaleCash,
				lpar_erup = paramLtsPar,
				usr_erup = paramUser,
				nnv_erup = paramNotesNumber,
				fyh_erup = CURRENT,
				hini_erup = minDate,
				hfin_erup = maxDate
		WHERE	fliq_erup = paramLiq
		AND		cia_erup = paramCompany
		AND		pla_erup = paramBranch
		AND		rut_erup = paramRoute
		AND		uni_erup = paramEco;
		
		UPDATE	enruta
		SET		edovta_enr = 'f'
		WHERE	SUBSTR(fecate_enr,1,8) = TO_CHAR(paramFecate, '%Y%m%d')
		AND		(ruta_enr = paramRoute
		OR		 eco_enr = paramEco)
		AND		edovta_enr = 'l';
		
		SELECT	fec_erup
		INTO	fesDate
		FROM	empxrutp
		WHERE	fliq_erup 		= paramLiq
				AND	cia_erup 	= paramCompany
				AND	pla_erup 	= paramBranch
				AND	rut_erup 	= paramRoute
				AND	uni_erup 	= paramEco;
		
		UPDATE	nota_vta
		SET		fes_nvta		= fesDate
		WHERE	cia_nvta 		= paramCompany
				AND pla_nvta	= paramBranch
				AND ruta_nvta	= paramRoute
				AND fliq_nvta	= paramLiq;
		
		UPDATE	nota_vta
		SET		impt_nvta		= pru_nvta * tlts_nvta,
				simp_nvta		= (pru_nvta * tlts_nvta) / (1 + (ivap_nvta / 100)),
				iva_nvta		= ((pru_nvta * tlts_nvta) / (1 + (ivap_nvta / 100))) * (ivap_nvta / 100)
		WHERE	cia_nvta 		= paramCompany
				AND pla_nvta	= paramBranch
				AND ruta_nvta	= paramRoute
				AND fliq_nvta	= paramLiq;	
				
		SELECT	SUM(NVL(impt_nvta,0)),SUM(NVL(impasi_nvta,0))
		INTO	vvcre_erup,vimptasistc
		FROM	nota_vta
		WHERE	cia_nvta 		= paramCompany
				AND pla_nvta	= paramBranch
				AND ruta_nvta	= paramRoute
				AND fliq_nvta	= paramLiq
				AND tpa_nvta	IN('C','G');
				
		SELECT	SUM(NVL(impt_nvta,0)), SUM(NVL(impasi_nvta,0))
		INTO	vvefe_erup, vimptasist
		FROM	nota_vta
		WHERE	cia_nvta 		= paramCompany
				AND pla_nvta	= paramBranch
				AND ruta_nvta	= paramRoute
				AND fliq_nvta	= paramLiq
				AND tpa_nvta	IN('E');
		
		SELECT	SUM(NVL(impt_nvta,0)), SUM(NVL(tlts_nvta,0)), SUM(NVL(impasi_nvta,0))
		INTO	vvtaotr, vtltsotr,vimptasisto
		FROM	nota_vta
		WHERE	cia_nvta 		= paramCompany
				AND pla_nvta	= paramBranch
				AND ruta_nvta	= paramRoute
				AND fliq_nvta	= paramLiq
				AND tpa_nvta	NOT IN('E','C','G','T','P','F','I');	
				
		LET vimptotasis = NVL(vimptasist,0) + NVL(vimptasistc,0) + NVL(vimptasisto,0);		
		LET vimp_erup = NVL(vvcre_erup,0) + NVL(vvefe_erup,0) + NVL(vvtaotr,0);
			
		UPDATE	empxrutp
		SET		imp_erup 		= vimp_erup,
				vcre_erup		= NVL(vvcre_erup,0),
				vefe_erup		= NVL(vvefe_erup,0),
				impase_erup		= NVL(vimptasist,0),
				impasc_erup		= NVL(vimptasistc,0),
				impaso_erup		= NVL(vimptasisto,0),
				impasi_erup 	= vimptotasis,
				lotr_erup		= NVL(vtltsotr,0),
				votr_erup		= NVL(vvtaotr,0),
				fyh_erup		= CURRENT
		WHERE	fliq_erup 		= paramLiq
				AND cia_erup 	= paramCompany
				AND pla_erup	= paramBranch
				AND rut_erup    = paramRoute;
			
		LET vpend = Ins_PendingS(paramFecate,paramRoute,paramLiq);
		
		LET vfolenr = '';
		FOREACH cursorNotasEnr FOR
			SELECT	cia_nvta || pla_nvta || LPAD(fol_nvta,6,'0')
			INTO	vfolenr
			FROM	nota_vta
			WHERE	fliq_nvta		= paramLiq
					AND cia_nvta	= paramCompany
					AND pla_nvta	= paramBranch
					AND ruta_nvta 	= paramRoute
			
			UPDATE	enruta
			SET		edovta_enr = 'f'
			WHERE	fol_enr = vfolenr;
		END FOREACH; 
		
		LET vtusrliq = 0;
		FOREACH cursorNotas FOR
			SELECT	usr_nvta,COUNT(usr_nvta)
			INTO	vusrliq,vcusrliq
			FROM	nota_vta
			WHERE	fliq_nvta		= paramLiq
					AND cia_nvta	= paramCompany
					AND pla_nvta	= paramBranch
					AND ruta_nvta 	= paramRoute
			GROUP BY usr_nvta
			
			IF vcusrliq > vtusrliq THEN
				LET vtusrliq = vcusrliq;
				LET vfusrliq = vusrliq;
			END IF;	
		END FOREACH; 
		
		UPDATE	empxrutp
		SET		urea_erup		= vfusrliq
		WHERE	fliq_erup 		= paramLiq
				AND cia_erup 	= paramCompany
				AND pla_erup	= paramBranch
				AND rut_erup    = paramRoute;
	
		LET vtltsnvtate	= 0;
		LET vimptnvtate	= 0;
		LET vtpanvtate = '';
		LET vobser = 'ANTES error  tipo = T y el pago = E Cia: ' || paramCompany || ' Pla: ' || paramBranch || ' Ruta: ' || paramRoute || ' Liq: ' || paramLiq || ' Lefe_erup: ' || paramLtsCash || ' Vefe_erup: ' || paramSaleCash || ' Lpar_erup: ' || paramLtsPar;
		INSERT INTO log
		VALUES(CURRENT,vobser,'errorTE');
		FOREACH cursorNotasTE FOR
			SELECT	fol_nvta, tlts_nvta, impt_nvta, tpa_nvta, vuelta_nvta		
			INTO	vfolnvtate, vtltsnvtate, vimptnvtate, vtpanvtate, vvuelta
			FROM	nota_vta
			WHERE	fliq_nvta		= paramLiq
					AND cia_nvta	= paramCompany
					AND pla_nvta	= paramBranch
					AND ruta_nvta 	= paramRoute
					AND tip_nvta 	= 'T'
	  				AND tpa_nvta 	= 'E'
			UPDATE 	nota_vta
	        SET 	tpa_nvta  		= 'T'
	        WHERE 	fol_nvta	 	= vfolnvtate 
	                AND cia_nvta 	= paramCompany
	                AND pla_nvta 	= paramBranch
	                AND vuelta_nvta = vvuelta;
	        IF vtpanvtate = 'E' THEN
	        	UPDATE	empxrutp
				SET		lefe_erup = paramLtsCash - vtltsnvtate,
						vefe_erup = paramSaleCash - vimptnvtate,
						lpar_erup = paramLtsPar + vtltsnvtate
				WHERE	fliq_erup = paramLiq
				AND		cia_erup = paramCompany
				AND		pla_erup = paramBranch
				AND		rut_erup = paramRoute
				AND		uni_erup = paramEco;
	        END IF;		
		END FOREACH; 
		LET vobser = 'error  tipo = E y el pago = T Cia: ' || paramCompany || ' Pla: ' || paramBranch || ' Ruta: ' || paramRoute || ' Liq: ' || paramLiq || ' Lefe_erup: ' || paramLtsCash - vtltsnvtate || ' Vefe_erup: ' || paramSaleCash - vimptnvtate || ' Lpar_erup: ' || paramLtsPar + vtltsnvtate;
		INSERT INTO log
		VALUES(CURRENT,vobser,'errorTE');
		
		FOREACH cursorNotasET FOR
			SELECT	fol_nvta, vuelta_nvta
			INTO	vfolnvtate, vvuelta
			FROM	nota_vta
			WHERE	fliq_nvta		= paramLiq
					AND cia_nvta	= paramCompany
					AND pla_nvta	= paramBranch
					AND ruta_nvta 	= paramRoute
					AND tip_nvta 	= 'E'
	  				AND tpa_nvta 	= 'T'
			UPDATE 	nota_vta
	        SET 	tip_nvta  		= 'T'
	        WHERE 	fol_nvta	 	= vfolnvtate 
	                AND cia_nvta 	= paramCompany
	                AND pla_nvta 	= paramBranch
	                AND vuelta_nvta = vvuelta;        
		END FOREACH; 
		LET vobser = 'error tipo = E y el pago = T Cia: ' || paramCompany || ' Pla: ' || paramBranch || ' Ruta: ' || paramRoute || ' Liq: ' || paramLiq || ' Lefe_erup: ' || paramLtsCash || ' Vefe_erup: ' || paramSaleCash || ' Lpar_erup: ' || paramLtsPar;
		INSERT INTO log
		VALUES(CURRENT,vobser,'errorTE');
					
		LET vobser = 'Update(Liquidaciones) Cia: ' || paramCompany || ' Pla: ' || paramBranch || ' Ruta: ' || paramRoute || ' Liq: ' || paramLiq || ' Nvv: ' || paramNotesNumber || ' LecI: ' || paramLin || ' LecF:' || paramLfi || ' PorI: ' || paramPin || ' PorF: ' || paramPfi || ' Usr: ' || paramUser;
		INSERT INTO log
		VALUES(CURRENT,vobser,'insrs');
		
		LET control = 'A';
	ELSE
		LET control = '' || LPAD(vnorefbanco,6,'0');
	END IF;
	
	RETURN	control;

END PROCEDURE;	

SELECT	NVL(MIN(fol_nvta),0)
FROM	nota_vta 
WHERE 	tpdo_nvta = 'A' and tpa_nvta in('R','B') and (observ_nvta is null or observ_nvta = '')
		AND cia_nvta	= '15'
		AND pla_nvta	= '13'
		AND ruta_nvta	= 'M007'
		AND fliq_nvta	= 3777;
		
SELECT	*
FROM	nota_vta 
WHERE 	cia_nvta	= '15'
		AND pla_nvta	= '13'
		AND ruta_nvta	= 'M007'
		AND fliq_nvta	= 3777;
		
		
select	*
from	nota_vta
where	ped_nvta in(1486385,1486386,1488273,1487625,1487688,1487695)

SELECT	NVL(MIN(fol_nvta),0)
	FROM	nota_vta 
	WHERE 	tpdo_nvta = 'A' and tpa_nvta in('R','B') and (observ_nvta is null or observ_nvta = '')
			AND cia_nvta	= '15'
			AND pla_nvta	= '79'
			AND ruta_nvta	= 'MP05'
			AND fliq_nvta	= 3180;
			
SELECT	fec_erup
FROM	empxrutp
WHERE	fliq_erup 		= 3180
		AND	cia_erup 	= '15'
		AND	pla_erup 	= '79'
		AND	rut_erup 	= 'MP05'
		AND	uni_erup 	= 'QI-0173';
		
SELECT	SUM(NVL(impt_nvta,0)),SUM(NVL(impasi_nvta,0))
FROM	nota_vta
WHERE	cia_nvta 		= '15'
		AND pla_nvta	= '79'
		AND ruta_nvta	= 'MP05'
		AND fliq_nvta	= 3180
		AND tpa_nvta	IN('C','G');
		
SELECT	SUM(NVL(impt_nvta,0)), SUM(NVL(impasi_nvta,0))
FROM	nota_vta
WHERE	cia_nvta 		= '15'
		AND pla_nvta	= '79'
		AND ruta_nvta	= 'MP05'
		AND fliq_nvta	= 3180
		AND tpa_nvta	IN('E');

SELECT	SUM(NVL(impt_nvta,0)), SUM(NVL(tlts_nvta,0)), SUM(NVL(impasi_nvta,0))
FROM	nota_vta
WHERE	cia_nvta 		= '15'
		AND pla_nvta	= '79'
		AND ruta_nvta	= 'MP05'
		AND fliq_nvta	= 3180
		AND tpa_nvta	NOT IN('E','C','G','T','P','F','I');	
		
select	*
from	log
where   observ_log like '%ANTES error%'
order by fhpr_log desc

SELECT	cia_nvta || pla_nvta || LPAD(fol_nvta,6,'0')
FROM	nota_vta
WHERE	fliq_nvta		= 3180
		AND cia_nvta	= '15'
		AND pla_nvta	= '79'
		AND ruta_nvta 	= 'MP05'
		
SELECT	usr_nvta,COUNT(usr_nvta)
FROM	nota_vta
WHERE	fliq_nvta		= 3180
		AND cia_nvta	= '15'
		AND pla_nvta	= '79'
		AND ruta_nvta 	= 'MP05'
GROUP BY usr_nvta

select	*
from	planta