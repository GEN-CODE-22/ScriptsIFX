CREATE PROCEDURE QryTankLiq(
	paramCli	CHAR(6),
	paramTank	SMALLINT,
	paramProg	CHAR(1),
	paramRoute	CHAR(4),
	paramAdd	CHAR(80),
	paramSub	CHAR(80),
	paramCity	CHAR(60)
	)

	RETURNING
		CHAR(6),
		CHAR(2), 
		CHAR(2), 
		CHAR(40),
		CHAR(40),
		CHAR(30),
		CHAR(40),
		CHAR(1),
		SMALLINT,
		DECIMAL, 
		DECIMAL,
		DECIMAL,
		CHAR(1),
		CHAR(20),
		SMALLINT,
		SMALLINT,
		DATE,
		SMALLINT,
		SMALLINT,
		DATE,
		CHAR(4),
		DECIMAL,
		CHAR(8),
		CHAR(1),
		CHAR(1),
		DATE,
		CHAR(8),
		CHAR(3),
		CHAR(30),
		DATE,
		CHAR(70),
		CHAR(10),
		CHAR(2),
		CHAR(10);
		
		
	DEFINE numcte 	CHAR(6);		
	DEFINE cia 		CHAR(2);		
	DEFINE pla 		CHAR(2);		
	DEFINE dir		CHAR(40);		
	DEFINE col		CHAR(40);		
	DEFINE ciu		CHAR(30);		
	DEFINE observ	CHAR(40);		
	DEFINE prg		CHAR(1);		
	DEFINE numtqe	SMALLINT;		
	DEFINE capac	DECIMAL;		
	DEFINE porll	DECIMAL;		
	DEFINE porva	DECIMAL;		
	DEFINE comoda	CHAR(1);		
	DEFINE numser	CHAR(20);		
	DEFINE mesfab	SMALLINT;		
	DEFINE anofab	SMALLINT;		
	DEFINE ultcar	DATE;			
	DEFINE diasca	SMALLINT;		
	DEFINE diasom	SMALLINT;		
	DEFINE proxca	DATE;			
	DEFINE ruta		CHAR(4);		
	DEFINE conprm	DECIMAL;		
	DEFINE usr		CHAR(8);		
	DEFINE serv		CHAR(1);		
	DEFINE stat		CHAR(1);		
	DEFINE fecbaj	DATE;			
	DEFINE usrbaj	CHAR(8);		
	DEFINE precio	CHAR(3);		
	DEFINE gps		CHAR(30);		
	DEFINE feccom	DATE;			
	DEFINE nomcom	CHAR(70);		
	DEFINE fecsur	CHAR(10);		
	DEFINE uso      CHAR(2);		
	DEFINE tip      CHAR(1);		
	
IF LENGTH(paramCli) > 0 THEN
	FOREACH consorclient FOR
	
		SELECT	tanque.numcte_tqe,
				tanque.cia_tqe,	
				tanque.pla_tqe,
				tanque.dir_tqe,
				tanque.col_tqe,
				tanque.ciu_tqe,
				tanque.observ_tqe,
				tanque.prg_tqe,
				tanque.numtqe_tqe,
				tanque.capac_tqe,
				tanque.porll_tqe,
				tanque.porva_tqe,
				tanque.comoda_tqe,
				tanque.numser_tqe,
				tanque.mesfab_tqe,
				tanque.anofab_tqe,
				tanque.ultcar_tqe,
				tanque.diasca_tqe,
				tanque.diasom_tqe,
				tanque.proxca_tqe,
				tanque.ruta_tqe,
				tanque.conprm_tqe,
				tanque.usr_tqe,
				tanque.serv_tqe,
				tanque.stat_tqe,
				tanque.fecbaj_tqe,
				tanque.usrbaj_tqe,
				tanque.precio_tqe,
				tanque.gps_tqe,
				tanque.feccom_tqe,
				case when trim(cliente.razsoc_cte) <> '' then trim(cliente.razsoc_cte) 
			    else case when cliente.ali_cte <> '' then trim(cliente.ali_cte) || ', '
			    else '' end || trim(cliente.nom_cte) || ' ' || trim(cliente.ape_cte) 
			    end AS nomcom_cte,
			    cliente.uso_cte,
			    cliente.tip_cte,
				NVL(pedidos.fecsur_ped, 'N/D')
		INTO	numcte,
				cia,	
				pla,
				dir,
				col,
				ciu,
				observ,
				prg,
				numtqe,
				capac,
				porll,
				porva,
				comoda,
				numser,
				mesfab,
				anofab,
				ultcar,
				diasca,
				diasom,
				proxca,
				ruta,
				conprm,
				usr,
				serv,
				stat,
				fecbaj,
				usrbaj,
				precio,
				gps,
				feccom,
				nomcom,
				uso,
				tip,
				fecsur
		FROM	tanque, cliente,
		OUTER	pedidos
		WHERE	(tanque.numcte_tqe = cliente.num_cte
		AND		 tanque.cia_tqe = cliente.cia_cte
		AND	     tanque.pla_tqe = cliente.pla_cte)
		AND		(tanque.numcte_tqe = pedidos.numcte_ped
		AND		 tanque.numtqe_tqe = pedidos.numtqe_ped)	
		AND     cliente.num_cte = 	paramCli	
		AND		pedidos.edo_ped = 'p'
		AND		tanque.serv_tqe IN ('B','E','I','T')
		AND 	tanque.stat_tqe = 'A'
		ORDER BY numtqe_tqe
		RETURN	numcte,
				cia,	
				pla,
				dir,
				col,
				ciu,
				observ,
				prg,
				numtqe,
				capac,
				porll,
				porva,
				comoda,
				numser,
				mesfab,
				anofab,
				ultcar,
				diasca,
				diasom,
				proxca,
				ruta,
				conprm,
				usr,
				serv,
				stat,
				fecbaj,
				usrbaj,
				precio,
				gps,
				feccom,
				nomcom,
				uso,
				tip,
				fecsur
		WITH RESUME;				
		
	END FOREACH;
ELSE
	FOREACH consorclient FOR
	
		SELECT	tanque.numcte_tqe,
				tanque.cia_tqe,	
				tanque.pla_tqe,
				tanque.dir_tqe,
				tanque.col_tqe,
				tanque.ciu_tqe,
				tanque.observ_tqe,
				tanque.prg_tqe,
				tanque.numtqe_tqe,
				tanque.capac_tqe,
				tanque.porll_tqe,
				tanque.porva_tqe,
				tanque.comoda_tqe,
				tanque.numser_tqe,
				tanque.mesfab_tqe,
				tanque.anofab_tqe,
				tanque.ultcar_tqe,
				tanque.diasca_tqe,
				tanque.diasom_tqe,
				tanque.proxca_tqe,
				tanque.ruta_tqe,
				tanque.conprm_tqe,
				tanque.usr_tqe,
				tanque.serv_tqe,
				tanque.stat_tqe,
				tanque.fecbaj_tqe,
				tanque.usrbaj_tqe,
				tanque.precio_tqe,
				tanque.gps_tqe,
				tanque.feccom_tqe,
				case when trim(cliente.razsoc_cte) <> '' then trim(cliente.razsoc_cte) 
			    else case when cliente.ali_cte <> '' then trim(cliente.ali_cte) || ', '
			    else '' end || trim(cliente.nom_cte) || ' ' || trim(cliente.ape_cte) 
			    end AS nomcom_cte,
			    cliente.uso_cte,
			    cliente.tip_cte,
				NVL(pedidos.fecsur_ped, 'N/D')
		INTO	numcte,
				cia,	
				pla,
				dir,
				col,
				ciu,
				observ,
				prg,
				numtqe,
				capac,
				porll,
				porva,
				comoda,
				numser,
				mesfab,
				anofab,
				ultcar,
				diasca,
				diasom,
				proxca,
				ruta,
				conprm,
				usr,
				serv,
				stat,
				fecbaj,
				usrbaj,
				precio,
				gps,
				feccom,
				nomcom,
				uso,
				tip,
				fecsur
		FROM	tanque, cliente,
		OUTER	pedidos
		WHERE	(tanque.numcte_tqe = cliente.num_cte
		AND		 tanque.cia_tqe = cliente.cia_cte
		AND	     tanque.pla_tqe = cliente.pla_cte)
		AND		(tanque.numcte_tqe = pedidos.numcte_ped
		AND		 tanque.numtqe_tqe = pedidos.numtqe_ped)
		AND		(tanque.numcte_tqe MATCHES paramCli OR paramCli = '')
		AND		(tanque.numtqe_tqe = paramTank OR paramTank = 0)
		AND		(tanque.prg_tqe = paramProg OR paramProg = '')
		AND		(tanque.ruta_tqe = paramRoute OR paramRoute = '')
		AND		(tanque.dir_tqe MATCHES paramAdd OR paramAdd = '')
		AND		(tanque.col_tqe MATCHES paramSub OR paramSub = '')
		AND		(tanque.ciu_tqe MATCHES paramCity OR paramCity = '')		
		AND		pedidos.edo_ped = 'p'
		AND		tanque.serv_tqe IN ('B','E','I','T')
		AND 	tanque.stat_tqe = 'A'
		ORDER BY numtqe_tqe
		RETURN	numcte,
				cia,	
				pla,
				dir,
				col,
				ciu,
				observ,
				prg,
				numtqe,
				capac,
				porll,
				porva,
				comoda,
				numser,
				mesfab,
				anofab,
				ultcar,
				diasca,
				diasom,
				proxca,
				ruta,
				conprm,
				usr,
				serv,
				stat,
				fecbaj,
				usrbaj,
				precio,
				gps,
				feccom,
				nomcom,
				uso,
				tip,
				fecsur
		WITH RESUME;				
		
	END FOREACH;
END IF;	
		
	
END PROCEDURE;	