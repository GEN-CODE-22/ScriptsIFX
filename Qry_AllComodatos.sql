CREATE PROCEDURE Qry_AllComodatos
( 
	paramNumCte	CHAR(6)
)
RETURNING  
 CHAR(50),
 CHAR(30), 
 CHAR(30),
 CHAR(70),
 CHAR(6),
 CHAR(20),
 DATE,
 CHAR(7),
 CHAR(50),
 CHAR(110), 
 CHAR(200), 
 CHAR(20);

DEFINE vtipo 	CHAR(50); 
DEFINE vcia		CHAR(30); 
DEFINE vpla		CHAR(30);
DEFINE vnomcte	CHAR(70);
DEFINE vnumcte	CHAR(6);
DEFINE vnumser	CHAR(20);
DEFINE vfecent	DATE;
DEFINE vfecfab	CHAR(7);
DEFINE vmarca	CHAR(50);
DEFINE vdir		CHAR(110);
DEFINE vobser	CHAR(200);
DEFINE vestatus	CHAR(20);

FOREACH cursorComodatos FOR
	SELECT	CASE
			WHEN tanque.serv_tqe = 'E' THEN 'TANQUE ESTACIONARIO'
			WHEN tanque.serv_tqe = 'C' THEN 'CILINDRO'
			END AS tipo,
			cia.cve_cia || '-' || cia.nom_cia,
			planta.cve_pla || '-' || planta.nom_pla,
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
			cliente.num_cte,
			tanque.numser_tqe,
			tanque.feccom_tqe,
			LPAD(tanque.mesfab_tqe,2,'0') || '/' || tanque.anofab_tqe,
			'' as marca,
			tanque.dir_tqe || ' ' || tanque.col_tqe || ' ' || tanque.ciu_tqe,		
			tanque.observ_tqe,
			CASE
			WHEN tanque.stat_tqe = 'A' THEN 'ACTIVO'
			WHEN tanque.stat_tqe = 'B' THEN 'BAJA'
			END AS estatus
	INTO	vtipo,
			vcia,
			vpla,
			vnomcte,
			vnumcte,
			vnumser,
			vfecent,
			vfecfab,
			vmarca,
			vdir,			
			vobser,
			vestatus
	FROM	cliente,
			cia,
			planta,
			tanque		
	WHERE	cliente.num_cte			= tanque.numcte_tqe
			AND tanque.cia_tqe 		= cia.cve_cia	
			AND tanque.pla_tqe		= planta.cve_pla
			AND cia.cve_cia			= planta.cia_pla
			AND	cliente.num_cte		= paramNumCte
			AND tanque.serv_tqe		IN('E','C')
			AND tanque.comoda_tqe		= 'S'
	UNION ALL
	SELECT	tipo_comoda.tipo_tcom,
			cia.cve_cia || '-' || cia.nom_cia,
			planta.cve_pla || '-' || planta.nom_pla,
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
			comodatos.numser_com,
			comodatos.fecent_com,
			LPAD(comodatos.mesfab_com,2,'0') || '/' || comodatos.anofab_com,
			marca_tqe.marca_mtqe,
			comodatos.dir_com || ' ' || comodatos.col_com || ' ' || comodatos.ciu_com,
			comodatos.obser_com,
			CASE
			WHEN comodatos.stat_com = 'A' THEN 'ACTIVO'
			WHEN comodatos.stat_com = 'B' THEN 'BAJA'
			END AS estatus				
	FROM	comodatos,
			cia,
			planta,
			cliente,
			tipo_comoda,
			marca_tqe
	WHERE	comodatos.numcte_com 	= cliente.num_cte
			AND comodatos.cia_com	= cia.cve_cia
			AND comodatos.pla_com	= planta.cve_pla
			AND comodatos.tipo_com 	= tipo_comoda.cve_tcom
			AND comodatos.marca_com	= marca_tqe.cve_mtqe
			AND cia.cve_cia			= planta.cia_pla
			AND comodatos.numcte_com= paramNumCte
			AND cliente.secof_cte 	= 'COMODATO'
	ORDER BY 1			
	RETURN	vtipo,
			vcia,
			vpla,
			vnomcte,
			vnumcte,
			vnumser,
			vfecent,
			vfecfab,
			vmarca,
			vdir,			
			vobser,
			vestatus
	WITH RESUME;
END FOREACH; 

END PROCEDURE;