CREATE PROCEDURE edtqe(
	paramCte char(6), 
	paramCia char(2),
	paramPla char(2), 
	paramDir char(40), 
	paramCol char(40),
	paramCiu char(30), 
	paramObserv char(40), 
	paramPrg char(1),
	paramNum int, 
	paramCapa decimal(10,2), 
	paramPorcLl decimal(10,2),
	paramPorcVa decimal(10,2), 
	paramMesfab smallint, 
	paramAnoFab smallint,
	paramUltcar date, 
	paramDiasCa smallint, 
	paramDiasom int, 
	paramProxCa date, 
	paramRuta char(4), 
	paramConp decimal(10,2),
	paramUsr char(8), 
	paramServ char(1), 
	paramStat char(1),
	paramFecBaj date, 
	paramUsrBaj char(8), 
	paramPrecio char(3),
	paramGps char(30))
RETURNING smallint;

UPDATE tanque SET dir_tqe = paramDir,
				  col_tqe = paramCol,
				  ciu_tqe = paramCiu,
				  observ_tqe = paramObserv,
				  prg_tqe = paramPrg,				  
				  capac_tqe = paramCapa,
				  porll_tqe = paramPorcLl,
				  porva_tqe = paramPorcVa,
				  mesfab_tqe = paramMesfab,
				  anofab_tqe = paramAnoFab,
				  ultcar_tqe = paramUltcar,
				  diasca_tqe = paramDiasCa,
				  diasom_tqe = paramDiasom,
				  proxca_tqe = paramProxCa,
				  ruta_tqe = paramRuta,
				  conprm_tqe = paramConp,
				  usr_tqe = paramUsr,
				  serv_tqe = paramServ, 
				  stat_tqe = paramStat, 
				  precio_tqe = paramPrecio, 
				  gps_tqe = paramGps
WHERE    		  numcte_tqe = paramCte
AND				  cia_tqe = paramCia
AND				  pla_tqe = paramPla
AND  			  numtqe_tqe = paramNum;

RETURN paramNum;
END PROCEDURE;                       