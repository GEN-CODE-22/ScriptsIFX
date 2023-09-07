CREATE PROCEDURE QryCliLiq(
	paramCli	CHAR(50),
	ParamCia	CHAR(2),
	paramPla	CHAR(2),
	paramPhone	INT,
	paramRazSoc CHAR(70),
	paramRFC	CHAR(30),
	paramLastN	CHAR(50),
	paramName	CHAR(50),
	paramAlias	CHAR(50),
	paramAdd	CHAR(80)	
	)

	RETURNING
		CHAR(6),
		CHAR(2), 
		CHAR(2),
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
		CHAR(8),
		CHAR(2),
		CHAR(1),
		CHAR(1),
		SMALLINT,
		CHAR(20),
		DATE,
		DECIMAL,
		CHAR(1),
		SMALLINT,
		CHAR(1),
		CHAR(1),
		CHAR(73),
		CHAR(1),
		CHAR(4),
		CHAR(3),
		CHAR(46),
		DATE,
		DATE,
		CHAR(1),
		DECIMAL,
		DECIMAL,
		DATE,
		DECIMAL,
		DATE,
		DECIMAL,
		CHAR(8),
		CHAR(15),
		CHAR(6),
		CHAR(1),
		DECIMAL,
		SMALLINT,
		SMALLINT,
		DECIMAL,
		CHAR(1);
		
	DEFINE cia 		CHAR(2);		
	DEFINE pla 		CHAR(2);		
	DEFINE num	 	CHAR(6);		
	DEFINE razsoc 	CHAR(70);		
	DEFINE ape		CHAR(30);		
	DEFINE nom		CHAR(20);		
	DEFINE dir 		CHAR(40);		
	DEFINE col 		CHAR(40);		
	DEFINE ciu 		CHAR(30);		
	DEFINE codpo	CHAR(6);		
	DEFINE lada 	SMALLINT;		
	DEFINE tel 		INT;			
	DEFINE ext 		CHAR(5);		
	DEFINE rfc    	CHAR(15);		
	DEFINE secof    CHAR(8);		
	DEFINE uso	 	CHAR(2);	
	DEFINE nvta 	CHAR(1);		
	DEFINE pitex	CHAR(1);		
	DEFINE ntanq	SMALLINT;		
	DEFINE contr	CHAR(20);			
	DEFINE feccon	DATE;			
	DEFINE descue	DECIMAL;		
	DEFINE tip 		CHAR(1);		
	DEFINE dcred	SMALLINT;		
	DEFINE reqfac	CHAR(1);		
	DEFINE reqcor	CHAR(1);		
	DEFINE corele   CHAR(73);		
	DEFINE pago     CHAR(1);		
	DEFINE cuenta   CHAR(4);	
	DEFINE banco    CHAR(3);		
	DEFINE men  	CHAR(46);		
	DEFINE fecalt	DATE;			
	DEFINE fecbaj	DATE;			
	DEFINE status	CHAR(1);		
	DEFINE salan	DECIMAL;		
	DEFINE cargo	DECIMAL;		
	DEFINE fecuca	DATE;			
	DEFINE abono	DECIMAL;		
	DEFINE fecuab	DATE;			
	DEFINE saldo	DECIMAL;		
	DEFINE usr		CHAR(8);		
	DEFINE ali		CHAR(15);		
	DEFINE gpo		CHAR(6);		
	DEFINE concre	CHAR(1);		
	DEFINE limcre   DECIMAL;		
	DEFINE limnotc 	SMALLINT;		
	DEFINE numnotc	SMALLINT;		
	DEFINE limcon	DECIMAL;		
	DEFINE ncont	CHAR(1);		
	
IF LENGTH(paramCli) > 0 THEN
	FOREACH consorclient FOR
	
		SELECT	num_cte,
				cia_cte,
				pla_cte,
				case when trim(razsoc_cte) <> '' then trim(razsoc_cte) 
			    else case when ali_cte <> '' then trim(ali_cte) || ', '
			    else '' end || trim(nom_cte) || ' ' || trim(ape_cte) 
			    end AS ncom_cte,
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
				secof_cte,
				uso_cte,
				nvta_cte,
				pitex_cte,				
				ntanq_cte,
				contr_cte,
				feccon_cte,
				descue_cte,				
				tip_cte,
				dcred_cte,
				reqfac_cte,
				reqcor_cte,
				corele_cte,
				pago_cte,
				cuenta_cte,
				banco_cte,
				men_cte,
				fecalt_cte,
				fecbaj_cte,
				status_cte,
				salan_cte,
				cargo_cte,
				fecuca_cte,
				abono_cte,
				fecuab_cte,
				saldo_cte,
				usr_cte,
				ali_cte,
				gpo_cte,
				concre_cte,
				limcre_cte,
				limnotc_cte,
				numnotc_cte,
				limcon_cte,
				ncont_cte
		INTO	num,
				cia,
				pla,
				razsoc,
				ape,
				nom,
				dir,
				col,
				ciu,
				codpo,	
				lada,
				tel,
				ext,
				rfc,
				secof,
				uso,
				nvta,
				pitex,				
				ntanq,
				contr,
				feccon,
				descue,				
				tip,
				dcred,
				reqfac,
				reqcor,
				corele,
				pago,
				cuenta,
				banco,
				men,
				fecalt,
				fecbaj,
				status,
				salan,
				cargo,
				fecuca,
				abono,
				fecuab,
				saldo,
				usr,
				ali,
				gpo,
				concre,
				limcre,
				limnotc,
				numnotc,
				limcon,
				ncont
		FROM	cliente
		WHERE	(num_cte MATCHES paramCli)
		AND		(cia_cte = paramCia OR paramCia = '')
		AND		(pla_cte = paramPla OR paramPla = '')		
		ORDER BY num_cte
		RETURN	num,
				cia,
				pla,
				razsoc,
				ape,
				nom,
				dir,
				col,
				ciu,
				codpo,	
				lada,
				tel,
				ext,
				rfc,
				secof,
				uso,
				nvta,
				pitex,				
				ntanq,
				contr,
				feccon,
				descue,				
				tip,
				dcred,
				reqfac,
				reqcor,
				corele,
				pago,
				cuenta,
				banco,
				men,
				fecalt,
				fecbaj,
				status,
				salan,
				cargo,
				fecuca,
				abono,
				fecuab,
				saldo,
				usr,
				ali,
				gpo,
				concre,
				limcre,
				limnotc,
				numnotc,
				limcon,
				ncont
		WITH RESUME;				
		
	END FOREACH;
ELSE
	FOREACH consorclient FOR
	
		SELECT	num_cte,
				cia_cte,
				pla_cte,
				case when trim(razsoc_cte) <> '' then trim(razsoc_cte) 
			    else case when ali_cte <> '' then trim(ali_cte) || ', '
			    else '' end || trim(nom_cte) || ' ' || trim(ape_cte) 
			    end AS ncom_cte,
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
				secof_cte,
				uso_cte,
				nvta_cte,
				pitex_cte,				
				ntanq_cte,
				contr_cte,
				feccon_cte,
				descue_cte,				
				tip_cte,
				dcred_cte,
				reqfac_cte,
				reqcor_cte,
				corele_cte,
				pago_cte,
				cuenta_cte,
				banco_cte,
				men_cte,
				fecalt_cte,
				fecbaj_cte,
				status_cte,
				salan_cte,
				cargo_cte,
				fecuca_cte,
				abono_cte,
				fecuab_cte,
				saldo_cte,
				usr_cte,
				ali_cte,
				gpo_cte,
				concre_cte,
				limcre_cte,
				limnotc_cte,
				numnotc_cte,
				limcon_cte,
				ncont_cte
		INTO	num,
				cia,
				pla,
				razsoc,
				ape,
				nom,
				dir,
				col,
				ciu,
				codpo,	
				lada,
				tel,
				ext,
				rfc,
				secof,
				uso,
				nvta,
				pitex,				
				ntanq,
				contr,
				feccon,
				descue,				
				tip,
				dcred,
				reqfac,
				reqcor,
				corele,
				pago,
				cuenta,
				banco,
				men,
				fecalt,
				fecbaj,
				status,
				salan,
				cargo,
				fecuca,
				abono,
				fecuab,
				saldo,
				usr,
				ali,
				gpo,
				concre,
				limcre,
				limnotc,
				numnotc,
				limcon,
				ncont
		FROM	cliente
		WHERE	(num_cte MATCHES paramCli OR paramCli = '')
		AND		(cia_cte = paramCia OR paramCia = '')
		AND		(pla_cte = paramPla OR paramPla = '')
		AND 	(tel_cte = paramPhone OR paramPhone = 0)
		AND		(razsoc_cte MATCHES paramRazSoc OR paramRazSoc = '')
		AND		(rfc_cte MATCHES paramRFC OR paramRFC = '')
		AND		(ape_cte MATCHES paramLastN OR paramLastN = '')
		AND		(ali_cte MATCHES paramAlias OR paramAlias = '')
		AND		(nom_cte MATCHES paramName OR paramName = '')
		AND		(dir_cte MATCHES paramAdd OR paramAdd = '')
		ORDER BY num_cte
		RETURN	num,
				cia,
				pla,
				razsoc,
				ape,
				nom,
				dir,
				col,
				ciu,
				codpo,	
				lada,
				tel,
				ext,
				rfc,
				secof,
				uso,
				nvta,
				pitex,				
				ntanq,
				contr,
				feccon,
				descue,				
				tip,
				dcred,
				reqfac,
				reqcor,
				corele,
				pago,
				cuenta,
				banco,
				men,
				fecalt,
				fecbaj,
				status,
				salan,
				cargo,
				fecuca,
				abono,
				fecuab,
				saldo,
				usr,
				ali,
				gpo,
				concre,
				limcre,
				limnotc,
				numnotc,
				limcon,
				ncont
		WITH RESUME;				
		
	END FOREACH;
END IF;	
	
END PROCEDURE;	