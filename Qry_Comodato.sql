CREATE PROCEDURE Qry_Comodato
(
	paramCte	CHAR(6)
)
RETURNING 
 INT, 
 CHAR(50),
 CHAR(2), 
 CHAR(2),
 CHAR(70),
 CHAR(6),
 INT,
 CHAR(20),
 CHAR(50),
 INT,
 CHAR(40),
 CHAR(40),
 CHAR(30),
 CHAR(200),
 SMALLINT,
 SMALLINT,
 CHAR(8),
 DATE,
 CHAR(8),
 CHAR(1),
 DATE;

DEFINE vnumtip_com 	INT; 
DEFINE vtipo_com	CHAR(50); 
DEFINE vcia_com		CHAR(2);
DEFINE vpla_com		CHAR(2);
DEFINE vnomcte_com	CHAR(70);
DEFINE vnumcte_com	CHAR(6);
DEFINE vnumcom_com	INT;
DEFINE vnumser_com	CHAR(20);
DEFINE vmarca_com	CHAR(50);
DEFINE vcvemar_com	INT;
DEFINE vdir_com		CHAR(40);
DEFINE vcol_com		CHAR(40);
DEFINE vciu_com		CHAR(30);
DEFINE vobser_com	CHAR(200);
DEFINE vmesfab_com	SMALLINT;
DEFINE vanofab_com	SMALLINT;
DEFINE vusr_com		CHAR(8);
DEFINE vfecbaj_com	DATE;
DEFINE vusrbaj_com	CHAR(8);
DEFINE vstat_com	CHAR(1);
DEFINE vfecent_com	DATE;

FOREACH cursorComodatos FOR
	SELECT	comodatos.tipo_com,
			tipo_comoda.tipo_tcom,
			comodatos.cia_com,
			comodatos.pla_com,
			CASE 
			WHEN TRIM(cliente.razsoc_cte) <> '' THEN
			   TRIM(cliente.razsoc_cte) 
			ELSE 
			   CASE
				  WHEN cliente.ali_cte <> '' THEN
					 TRIM(cliente.ali_cte) || ', ' 
				  ELSE
					 '' 
			   END || trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
			END AS ncom_cte,
			comodatos.numcte_com,
			comodatos.numcom_com,
			comodatos.numser_com,
			marca_tqe.marca_mtqe,
			comodatos.marca_com,
			comodatos.dir_com,
			comodatos.col_com,
			comodatos.ciu_com,
			comodatos.obser_com,
			comodatos.mesfab_com,
			comodatos.anofab_com,
			comodatos.usr_com,
			comodatos.fecbaj_com,
			comodatos.usrbaj_com,
			comodatos.stat_com,
			comodatos.fecent_com
	INTO	vnumtip_com,
			vtipo_com,
			vcia_com,
			vpla_com,
			vnomcte_com,
			vnumcte_com,
			vnumcom_com,
			vnumser_com,
			vmarca_com,
			vcvemar_com,
			vdir_com,
			vcol_com,
			vciu_com,
			vobser_com,
			vmesfab_com,
			vanofab_com,
			vusr_com,
			vfecbaj_com,
			vusrbaj_com,
			vstat_com,
			vfecent_com
	FROM	comodatos,
			cliente,
			tipo_comoda,
			marca_tqe
	WHERE	comodatos.numcte_com 	= cliente.num_cte
			AND comodatos.tipo_com 	= tipo_comoda.cve_tcom
			AND comodatos.marca_com	= marca_tqe.cve_mtqe
			AND comodatos.numcte_com= paramCte
	ORDER BY comodatos.numser_com
	RETURN	vnumtip_com,
			vtipo_com,
			vcia_com,
			vpla_com,
			vnomcte_com,
			vnumcte_com,
			vnumcom_com,
			vnumser_com,
			vmarca_com,
			vcvemar_com,
			vdir_com,
			vcol_com,
			vciu_com,
			vobser_com,
			vmesfab_com,
			vanofab_com,
			vusr_com,
			vfecbaj_com,
			vusrbaj_com,
			vstat_com,
			vfecent_com
	WITH RESUME;
END FOREACH; 

END PROCEDURE;