EXECUTE PROCEDURE QryNvaInLiq(3910,'15','02','M030');

DROP PROCEDURE QryNvaInLiq;

CREATE PROCEDURE qrynvainliq(
	paramFolio	INTEGER,
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramRoute	CHAR(4)
	)

	RETURNING
		INTEGER,					
		DECIMAL,					
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
		CHAR(30),				
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
		INT,
		CHAR(1),					
		DECIMAL;					
		
	
	DEFINE fol		INTEGER;					
	DEFINE ffis		DECIMAL;					
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
	DEFINE tpa		CHAR(30);	
	DEFINE tpacve	CHAR(1);			
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
	DEFINE golpe	INT;	
	DEFINE vasiste	CHAR(1);
	DEFINE vimpasi	DECIMAL;				
	
	FOREACH consorcanc FOR
	
		SELECT	fol_nvta,
				ffis_nvta,
				cia_nvta,
				pla_nvta,
				ped_nvta,
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
				fac_nvta,
				ser_nvta,
				CASE
					WHEN tpa_nvta = 'C' THEN
						'CREDITO'
					WHEN tpa_nvta = 'E'  THEN
						'EFECTIVO'
					WHEN tpa_nvta = 'B'  THEN

						'TARJETA DE DEBITO'
					WHEN tpa_nvta = 'B'  THEN
						'TARJETA DE CREDITO'
					WHEN tpa_nvta = 'F' THEN
						'FUGAS LTS'
					WHEN tpa_nvta = 'G' THEN
						'CREDIGAS'
					WHEN tpa_nvta = 'H' THEN
						'DIESEL'
					WHEN tpa_nvta = 'I' THEN
						'CONSUMO'
					WHEN tpa_nvta = 'K' THEN
						'DONACI?N KGS'
					WHEN tpa_nvta = 'O' THEN
						'GASOLINA'
					WHEN tpa_nvta = 'P' THEN
						'PARTICULAR'
					WHEN tpa_nvta = 'Q' THEN
						'FUGAS KGS'
					WHEN tpa_nvta = 'T' THEN
						'TRANSFERENCIA INVENT.'
				END AS tpa_nvta,
				tpa_nvta as cvetpa,				
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
				movxnvta.bst_mnvta,
				NVL(asiste_nvta,'N'),
				NVL(impasi_nvta,0)
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
				tpacve,
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
				golpe,
				vasiste,
				vimpasi
		FROM	nota_vta,
				movxnvta
		WHERE	nota_vta.fol_nvta 	=  movxnvta.fol_mnvta
				AND nota_vta.vuelta_nvta 	=  movxnvta.vuelta_mnvta
				AND fliq_nvta		= paramFolio
				AND	cia_nvta 		= paramCia
				AND	pla_nvta 		= paramPla
				AND	ruta_nvta 		= paramRoute
				AND movxnvta.cia_mnvta = paramCia
				AND movxnvta.pla_mnvta = paramPla
				AND	edo_nvta 	IN ('S', 'P')
		ORDER BY movxnvta.bst_mnvta
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
				tpacve,
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
				golpe,
				vasiste,
				vimpasi
		WITH RESUME;	
	END FOREACH;

END PROCEDURE;        