CREATE PROCEDURE QryCli
(
	paramCia      		CHAR(2),
	paramPla      		CHAR(2),
	paramNumCte   		CHAR(6),
	paramTel			INT,  
	paramAlias   		CHAR(15),
	paramRazonSocial	CHAR(70),
	paramRfc   			CHAR(15),
	paramNombre   		CHAR(20),
	paramApePat   		CHAR(30),
	paramCalle			CHAR(40),
	paramFechaInicial	DATE,
	paramFechaFinal		DATE
)

RETURNING 
 CHAR(2), 
 CHAR(2), 
 CHAR(6), 
 CHAR(70),
 CHAR(30),
 CHAR(20), 
 CHAR(40),
 CHAR(40),
 CHAR(30),
 CHAR(6), 
 SMALLINT,
 INT,
 CHAR(5),
 CHAR(15),
 CHAR(73),
 CHAR(15),
 CHAR(8),
 CHAR(1),
 CHAR(6),
 CHAR(2),
 CHAR(1),
 CHAR(1),
 CHAR(20),
 DATE,
 CHAR(1),
 DECIMAL,
 DECIMAL,
 CHAR(1),
 SMALLINT,
 CHAR(1),
 CHAR(1),
 CHAR(1),
 CHAR(4),
 CHAR(3),
 CHAR(46),
 CHAR(1),
 DECIMAL,
 SMALLINT,
 DATE,
 DATE,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DATE,
 DATE,
 CHAR(30),
 CHAR(20),
 CHAR(20);
 
DEFINE cia 		CHAR(2);
DEFINE pla 		CHAR(2);
DEFINE numcte 	CHAR(6);
DEFINE razsoc 	CHAR(70);
DEFINE apellido CHAR(30);
DEFINE nombre	CHAR(20);
DEFINE apepresp CHAR(20);
DEFINE apemresp CHAR(20);
DEFINE nomresp	CHAR(30);
DEFINE dir 		CHAR(40);
DEFINE col 		CHAR(40);
DEFINE ciu 		CHAR(30);
DEFINE cp 		CHAR(6);
DEFINE lada 	SMALLINT;
DEFINE tel 		INT;
DEFINE ext 		CHAR(5);
DEFINE rfc    	CHAR(15);
DEFINE correo   CHAR(73);
DEFINE alias    CHAR(15);
DEFINE secof    CHAR(8);
DEFINE status	CHAR(1);
DEFINE gpofact	CHAR(6);
DEFINE uso	 	CHAR(2);
DEFINE nvta 	CHAR(1);
DEFINE pitex	CHAR(1);
DEFINE contrato	CHAR(20);
DEFINE feccont	DATE;
DEFINE firmcont	CHAR(1);
DEFINE pagare   DECIMAL;
DEFINE descto 	DECIMAL;
DEFINE tipo 	CHAR(1);
DEFINE diascre	SMALLINT;
DEFINE reqfact 	CHAR(1);
DEFINE reqcor  	CHAR(1);
DEFINE pago     CHAR(1);
DEFINE cuenta   CHAR(4);
DEFINE banco    CHAR(3);
DEFINE msg  	CHAR(46);
DEFINE ctrlcre  CHAR(1);
DEFINE limcre   DECIMAL;
DEFINE limnvta  SMALLINT;
DEFINE fecalt  	DATE;
DEFINE fecbaj   DATE;
DEFINE salant   DECIMAL;
DEFINE cargos   DECIMAL;
DEFINE abonos  	DECIMAL;
DEFINE saldo	DECIMAL;
DEFINE fecultc  DATE;
DEFINE feculta  DATE;

IF LENGTH(paramNumCte) > 0 THEN
FOREACH cClientes FOR
	SELECT  cia_cte,
			pla_cte,
			num_cte,
			razsoc_cte,
			ape_cte,
			nom_cte,
			dir_cte,
			col_cte,
			ciu_cte,
			codpo_cte,
			lada_cte,
			tel_cte,
			ext_cte,
			rfc_cte,
			corele_cte,
			ali_cte,
			CASE 
				WHEN	secof_cte = 'COMODATO'	THEN
		  		'S'
		  		ELSE
		  		'N'
			END AS secof_cte,
			status_cte,
			gpo_cte,
			uso_cte,
			nvta_cte,
			pitex_cte,
			contr_cte,
			feccon_cte,
			ncont_cte,
			limcon_cte,
			descue_cte,
			tip_cte,
			dcred_cte,
			reqfac_cte,
			reqcor_cte,
			pago_cte,
			cuenta_cte,
			banco_cte,
			men_cte,
			concre_cte,
			limcre_cte,
			limnotc_cte,
			fecalt_cte,
			fecbaj_cte,
			salan_cte,
			cargo_cte,
			abono_cte,
			saldo_cte,
			fecuca_cte,
			fecuab_cte,
			cte_comodato.nomcte_ccom,
			cte_comodato.apepcte_ccom,	
			cte_comodato.apemcte_ccom	
	INTO	cia, 
			pla, 
			numcte,
			razsoc,
			apellido,
			nombre,
			dir,
			col,
			ciu,
			cp,
			lada,
			tel,
			ext,
			rfc,
			correo,
			alias,
			secof,
			status,
			gpofact,
			uso,
			nvta,
			pitex,
			contrato,
			feccont,
			firmcont,
			pagare,
			descto,
			tipo,
			diascre,
			reqfact,
			reqcor,
			pago,
			cuenta,
			banco,
			msg,
			ctrlcre,
			limcre,
			limnvta,
			fecalt,
			fecbaj,
			salant,
			cargos,
			abonos,
			saldo,
			fecultc,
			feculta,
			nomresp,
			apepresp,
			apemresp
	FROM	cliente,
	OUTER	cte_comodato
	WHERE	cia_cte 			= paramCia
			AND pla_cte 		= paramPla
			AND cliente.num_cte = paramNumCte	
			AND cliente.num_cte = cte_comodato.numcte_ccom	
	RETURN 	cia, 
			pla, 
			numcte,
			razsoc,
			apellido,
			nombre,
			dir,
			col,
			ciu,
			cp,
			lada,
			tel,
			ext,
			rfc,
			correo,
			alias,
			secof,
			status,
			gpofact,
			uso,
			nvta,
			pitex,
			contrato,
			feccont,
			firmcont,
			pagare,
			descto,
			tipo,
			diascre,
			reqfact,
			reqcor,
			pago,
			cuenta,
			banco,
			msg,
			ctrlcre,
			limcre,
			limnvta,
			fecalt,
			fecbaj,
			salant,
			cargos,
			abonos,
			saldo,
			fecultc,
			feculta,
			nomresp,
			apepresp,
			apemresp
	WITH RESUME;
	END FOREACH;     
ELSE
FOREACH cClientes FOR
	SELECT  cia_cte,
			pla_cte,
			num_cte,
			razsoc_cte,
			ape_cte,
			nom_cte,
			dir_cte,
			col_cte,
			ciu_cte,
			codpo_cte,
			lada_cte,
			tel_cte,
			ext_cte,
			rfc_cte,
			corele_cte,
			ali_cte,
			CASE 
				WHEN	secof_cte = 'COMODATO'	THEN
		  		'S'
		  		ELSE
		  		'N'
			END AS secof_cte,
			status_cte,
			gpo_cte,
			uso_cte,
			nvta_cte,
			pitex_cte,
			contr_cte,
			feccon_cte,
			ncont_cte,
			limcon_cte,
			descue_cte,
			tip_cte,
			dcred_cte,
			reqfac_cte,
			reqcor_cte,
			pago_cte,
			cuenta_cte,
			banco_cte,
			men_cte,
			concre_cte,
			limcre_cte,
			limnotc_cte,
			fecalt_cte,
			fecbaj_cte,
			salan_cte,
			cargo_cte,
			abono_cte,
			saldo_cte,
			fecuca_cte,
			fecuab_cte,
			cte_comodato.nomcte_ccom,
			cte_comodato.apepcte_ccom,	
			cte_comodato.apemcte_ccom		
	INTO	cia, 
			pla, 
			numcte,
			razsoc,
			apellido,
			nombre,
			dir,
			col,
			ciu,
			cp,
			lada,
			tel,
			ext,
			rfc,
			correo,
			alias,
			secof,
			status,
			gpofact,
			uso,
			nvta,
			pitex,
			contrato,
			feccont,
			firmcont,
			pagare,
			descto,
			tipo,
			diascre,
			reqfact,
			reqcor,
			pago,
			cuenta,
			banco,
			msg,
			ctrlcre,
			limcre,
			limnvta,
			fecalt,
			fecbaj,
			salant,
			cargos,
			abonos,
			saldo,
			fecultc,
			feculta,
			nomresp,
			apepresp,
			apemresp
	FROM	cliente,
	OUTER	cte_comodato
	WHERE	cia_cte 						= paramCia
			AND pla_cte 					= paramPla
			AND (paramTel 					= 0 	OR cliente.tel_cte 		= paramTel)
			AND (LENGTH(paramAlias) 		= 0 	OR cliente.ali_cte 		LIKE paramAlias)
			AND (LENGTH(paramRazonSocial) 	= 0 	OR cliente.razsoc_cte 	LIKE paramRazonSocial)
			AND (LENGTH(paramRfc) 			= 0 	OR cliente.rfc_cte 		LIKE paramRfc)
			AND (LENGTH(paramNombre) 		= 0 	OR cliente.nom_cte 		LIKE paramNombre)
			AND (LENGTH(paramApePat) 		= 0 	OR cliente.ape_cte 		LIKE paramApePat)
			AND (LENGTH(paramCalle) 		= 0 	OR cliente.dir_cte 		LIKE paramCalle)
			AND (paramFechaInicial    IS NULL   	OR cliente.fecalt_cte 	>= paramFechaInicial)
			AND (paramFechaFinal	  IS NULL       OR cliente.fecalt_cte 	<= paramFechaFinal)
			AND cliente.num_cte = cte_comodato.numcte_ccom		
	RETURN 	cia, 
			pla, 
			numcte,
			razsoc,
			apellido,
			nombre,
			dir,
			col,
			ciu,
			cp,
			lada,
			tel,
			ext,
			rfc,
			correo,
			alias,
			secof,
			status,
			gpofact,
			uso,
			nvta,
			pitex,
			contrato,
			feccont,
			firmcont,
			pagare,
			descto,
			tipo,
			diascre,
			reqfact,
			reqcor,
			pago,
			cuenta,
			banco,
			msg,
			ctrlcre,
			limcre,
			limnvta,
			fecalt,
			fecbaj,
			salant,
			cargos,
			abonos,
			saldo,
			fecultc,
			feculta,
			nomresp,
			apepresp,
			apemresp
	WITH RESUME;
	END FOREACH; 
END IF;
END PROCEDURE;