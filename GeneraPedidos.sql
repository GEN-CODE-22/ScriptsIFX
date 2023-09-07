CREATE PROCEDURE GeneraPedidos
(
	paramCia	CHAR(2),
 	paramPla	CHAR(2)
)

RETURNING 
 INT;
 

DEFINE vruta 	CHAR(4);
DEFINE vnumcte 	CHAR(6);
DEFINE vnomcte 	CHAR(70);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vnumped 	INT;
DEFINE vtipped 	CHAR(1);
DEFINE vtanque 	SMALLINT;
DEFINE vrutaped	CHAR(4);
DEFINE vuso 	CHAR(2);
DEFINE vfecsur 	DATE;
DEFINE vtpa 	CHAR(1);
DEFINE vtprd 	CHAR(1);
DEFINE vprecio 	DECIMAL;
DEFINE vusr 	CHAR(8);
DEFINE vtpdo 	CHAR(1);
DEFINE vtipo 	CHAR(1);
DEFINE vobserv	CHAR(40);
DEFINE vdir		CHAR(40);
DEFINE vrfc		CHAR(13);
DEFINE vfolnvta	INT;

FOREACH cRutas FOR
	SELECT	cve_rut
	INTO	vruta
	FROM	ruta r,
			ri505_neco ri
	WHERE	r.cve_rut			= ri.ruta_rneco
			AND	cve_rut[1,1] 	= 'M'
			AND cia_rut 		= paramCia
			AND pla_rut 		= paramPla
			AND ri.tcel_rneco	= 'S'
	IF vruta IS NOT NULL THEN
		FOREACH cPedidos FOR
			SELECT  num_ped,
					tipo_ped,
					numcte_ped,
					numtqe_ped,
					ruta_ped,
					fecsur_ped,
					usr_ped,
					tpdo_ped,
					observ_ped
			INTO	vnumped,
					vtipped,
					vnumcte,
					vtanque,
					vrutaped,
					vfecsur,
					vusr,
					vtpdo,
					vobserv
			FROM	pedidos
			WHERE	edo_ped 		= 'P'
					AND ruta_ped 	= vruta
					AND fecsur_ped  <= TODAY
			
			IF	vnumped > 0 THEN
				SELECT	uso_cte,
						tip_cte,
						rfc_cte,
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
						END
				INTO	vuso,
						vtpa,
						vrfc,
						vnomcte
				FROM	cliente
				WHERE	num_cte = vnumcte;
				
				SELECT	serv_tqe,
						TRIM(REPLACE(tanque.dir_tqe,',',' ')) || ',' || TRIM(REPLACE(tanque.col_tqe,',',' ')) || ',' || TRIM(REPLACE(tanque.ciu_tqe,',',' '))
				INTO	vtipo,
						vdir
				FROM	tanque
				WHERE	numcte_tqe 		= vnumcte
						AND numtqe_tqe 	= vtanque;				

				LET	vfolnvta = next_fol_nvta(paramCia, paramPla);
				IF vfolnvta > 0 THEN
					EXECUTE PROCEDURE InsNotaVta
					(
						vfolnvta,
						paramCia,
						paramPla,
						vnumped,
						vnumcte,
						vtanque,
						vruta,
						vtipo,
						vuso,
						CURRENT,
						vfecsur,
						'P',
						'N',
						vtpa,
						'N',
						'N',
						vusr,
						vnomcte,
						vdir,
						vrfc,
						vtpdo,
						NULL,
						vobserv
					);	
					UPDATE	pedidos
					SET		edo_ped = 'p'
					WHERE	num_ped = vnumped;	
			
				END IF;
			END IF;
		END FOREACH;
	END IF;
END FOREACH;
RETURN 0;
END PROCEDURE;