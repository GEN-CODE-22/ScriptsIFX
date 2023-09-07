CREATE PROCEDURE ConsTqeC
(
	paramCte CHAR(6)
)

RETURNING 
 CHAR(2), 
 CHAR(2), 
 CHAR(40), 
 CHAR(40),
 CHAR(30), 
 CHAR(40), 
 CHAR(1), 
 SMALLINT,
 DECIMAL(10,2), 
 DECIMAL(10,2), 
 DECIMAL(10,2),
 SMALLINT, 
 SMALLINT, 
 DATE, 
 SMALLINT, 
 SMALLINT, 
 DATE,
 CHAR(4), 
 DECIMAL(10,2), 
 CHAR(8), 
 CHAR(1), 
 CHAR(1),
 DATE, 
 CHAR(8),
 CHAR(3), 
 CHAR(30),
 CHAR(20),
 CHAR(1),
 DATE;

DEFINE numcte 	CHAR(6); 
DEFINE cia 		CHAR(2); 
DEFINE pla 		CHAR(2);
DEFINE dir 		CHAR(40); 
DEFINE col 		CHAR(40); 
DEFINE ciu 		CHAR(30);
DEFINE observ 	CHAR(40); 
DEFINE prg 		CHAR(1); 
DEFINE numtqe 	SMALLINT;
DEFINE capac 	DECIMAL(10,2); 
DEFINE porll 	DECIMAL(10, 2);
DEFINE porva 	DECIMAL(10,2); 
DEFINE mesfab 	SMALLINT;
DEFINE anofab 	SMALLINT; 
DEFINE ultcar 	DATE; 
DEFINE diasca 	SMALLINT;
DEFINE diasom 	SMALLINT; 
DEFINE proxca 	DATE; 
DEFINE ruta 	CHAR(4);
DEFINE conprm 	DECIMAL(10,2); 
DEFINE usr 		CHAR(8);
DEFINE serv 	CHAR(1); 
DEFINE stat 	CHAR(1);
DEFINE fecbaj 	DATE;
DEFINE usrbaj 	CHAR(8); 
DEFINE precio 	DECIMAL(10,2);
DEFINE gps 		CHAR(30);
DEFINE numserie	CHAR(20);
DEFINE comodato	CHAR(1);
DEFINE feccom	DATE;

FOREACH cursorcanc FOR
	SELECT	cia_tqe, 
			pla_tqe, 
			dir_tqe,
			col_tqe, 
			ciu_tqe, 
			observ_tqe, 
			prg_tqe,
            numtqe_tqe, 
            capac_tqe, 
            porll_tqe,
            porva_tqe, 
            mesfab_tqe, 
            anofab_tqe,
            ultcar_tqe, 
            diasca_tqe, 
            diasom_tqe,
            proxca_tqe, 
            ruta_tqe, 
            conprm_tqe,            
       		usr_tqe, 
       		serv_tqe, 
       		stat_tqe, 
       		fecbaj_tqe,
            usrbaj_tqe, 
            precio_tqe, 
            gps_tqe,
            numser_tqe,
            comoda_tqe,
            feccom_tqe            
	INTO	cia, 
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
            numserie,
            comodato,
            feccom
	FROM	tanque
    WHERE	numcte_tqe = paramCte
    ORDER BY numtqe_tqe
    RETURN	cia, 
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
            numserie,
            comodato,
            feccom
	WITH RESUME;
END FOREACH;       
END PROCEDURE;