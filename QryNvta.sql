CREATE PROCEDURE QryNvta(
	paramFolio	INTEGER,
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramRoute	CHAR(4)
	)

	RETURNING
		INTEGER,					
		INTEGER,					
		CHAR(2),					
		CHAR(2),					
		INTEGER,					
		CHAR(6),					
		SMALLINT,					
		CHAR(4),					
		CHAR(1),					
		CHAR(2),					
		DATETIME YEAR TO MINUTE,	
		DATE,						
		INT,						
		CHAR(1),					
		CHAR(1),					
		INT,						
		CHAR(4),					
		CHAR(1),					
		CHAR(1),					
		CHAR(1),					
		DECIMAL,					
		CHAR(3),					
		DECIMAL,					
		DECIMAL,					
		DECIMAL,					
		DECIMAL,					
		DECIMAL,					
		CHAR(8),						
		CHAR(1),					
		CHAR(100);					
		
	
	DEFINE fol		INTEGER;					
	DEFINE ffis		INTEGER;					
	DEFINE cia		CHAR(2);					
	DEFINE pla		CHAR(2);					
	DEFINE ped		INTEGER;					
	DEFINE numcte	CHAR(6);					
	DEFINE numtqe	SMALLINT;					
	DEFINE ruta		CHAR(4);					
	DEFINE tip		CHAR(1);					
	DEFINE uso		CHAR(2);					
	DEFINE fep		DATETIME YEAR TO MINUTE;	
	DEFINE fes		DATE;						
	DEFINE fliq		INT;						
	DEFINE edo		CHAR(1);					
	DEFINE rfa		CHAR(1);					
	DEFINE fac		INT;						
	DEFINE ser		CHAR(4);					
	DEFINE tpa		CHAR(1);					
	DEFINE napl		CHAR(1);					
	DEFINE nept 	CHAR(1);					
	DEFINE tlts		DECIMAL;					
	DEFINE tprd		CHAR(3);					
	DEFINE pru		DECIMAL;					
	DEFINE simp		DECIMAL;					
	DEFINE iva		DECIMAL;
	DEFINE ivap		DECIMAL;					
	DEFINE impt		DECIMAL;					
	DEFINE usr		CHAR(8);					
	DEFINE tpdo		CHAR(1);					
	DEFINE nom		CHAR(100);					
	
	FOREACH consorcanc FOR
	
		SELECT	nota_vta.fol_nvta,
				nota_vta.ffis_nvta,
				nota_vta.cia_nvta,
				nota_vta.pla_nvta,
				nota_vta.ped_nvta,
				nota_vta.numcte_nvta,
				nota_vta.numtqe_nvta,
				nota_vta.ruta_nvta,
				nota_vta.tip_nvta,
				nota_vta.uso_nvta,
				nota_vta.fep_nvta,
				nota_vta.fes_nvta,
				nota_vta.fliq_nvta,
				nota_vta.edo_nvta,
				nota_vta.rfa_nvta,
				nota_vta.fac_nvta,
				nota_vta.ser_nvta,
				nota_vta.tpa_nvta,				
				nota_vta.napl_nvta,
				nota_vta.nept_nvta,
				nota_vta.tlts_nvta,
				nota_vta.tprd_nvta,
				nota_vta.pru_nvta,
				nota_vta.simp_nvta,
				nota_vta.iva_nvta,
				nota_vta.ivap_nvta,
				nota_vta.impt_nvta,
				nota_vta.usr_nvta,
				nota_vta.tpdo_nvta,
				case when trim(cliente.razsoc_cte) <> '' then trim(cliente.razsoc_cte) 
			    else case when cliente.ali_cte <> '' then trim(cliente.ali_cte) || ', '
			    else '' end || trim(cliente.nom_cte) || ' ' || trim(cliente.ape_cte) 
			    end AS ncom_cte
		INTO	fol,
				ffis,
				cia,
				pla,
				ped,
				numcte,
				numtqe,
				ruta,
				tip,
				uso,
				fep,
				fes,
				fliq,
				edo,
				rfa,
				fac,
				ser,
				tpa,
				napl,
				nept,
				tlts,
				tprd,
				pru,
				simp,
				iva,
				ivap,
				impt,
				usr,
				tpdo,
				nom
		FROM	nota_vta,
		OUTER	cliente
		WHERE	(nota_vta.cia_nvta = cliente.cia_cte AND
				 nota_vta.pla_nvta = cliente.pla_cte AND
				 nota_vta.numcte_nvta = cliente.num_cte)
		AND		fol_nvta = paramFolio
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla
		AND		ruta_nvta = paramRoute		
		ORDER BY edo_nvta
		RETURN	fol,
				ffis,
				cia,
				pla,
				ped,
				numcte,
				numtqe,
				ruta,
				tip,
				uso,
				fep,
				fes,
				fliq,
				edo,
				rfa,
				fac,
				ser,
				tpa,
				napl,
				nept,
				tlts,
				tprd,
				pru,
				simp,
				iva,
				ivap,
				impt,
				usr,
				tpdo,
				nom
		WITH RESUME;	
	END FOREACH;

END PROCEDURE;	