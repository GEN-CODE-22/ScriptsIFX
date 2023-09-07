CREATE PROCEDURE Ins_PendingS
(
	paramFecha	DATE,	
	paramRuta 	CHAR(4),
	paramFliq 	INT
)
RETURNING
		CHAR(1);

	DEFINE vcia		CHAR(2);	
	DEFINE vpla  	CHAR(2);	
	DEFINE vfolnvta	INT;		
	DEFINE vfolenr	CHAR(10);	
	DEFINE vnumped	INT;		
	DEFINE vnumcte  CHAR(6);	
	DEFINE vnumtqe  INT;		
	DEFINE vtpdo	CHAR(1);	
	DEFINE vmotcan  CHAR(40);	
	
	LET vcia = '';
	LET vpla = '';
	LET vfolnvta = 0;
	LET vfolenr = '';
	LET vmotcan = '';
	
	FOREACH cCPedidosP FOR
	
		SELECT  num_ped,
				numcte_ped,
				numtqe_ped,
				tpdo_ped
		INTO	vnumped,
				vnumcte,
				vnumtqe,
				vtpdo
		FROM	pedidos
		WHERE   ruta_ped		= paramRuta
				AND fecsur_ped	= paramFecha
				AND edo_ped     IN ('p','P')
				
		IF EXISTS(SELECT 1 	FROM nota_vta WHERE ped_nvta = vnumped) THEN
			SELECT	cia_nvta,
					pla_nvta,
					fol_nvta			
			INTO	vcia,
					vpla,
					vfolnvta
			FROM	nota_vta
			WHERE	ped_nvta = vnumped;
			
			LET	vfolenr = vcia || vpla || LPAD(vfolnvta,6,'0');
			
			SELECT	NVL(obser_enr,'')
			INTO	vmotcan
			FROM	enruta
			WHERE	fol_enr = vfolenr;
		END IF;
		
		IF NOT EXISTS(SELECT 1 	FROM hped_pen WHERE fec_hppen = TODAY  AND ruta_hppen = paramRuta
					AND nped_hppen =  vnumped) THEN
			INSERT INTO hped_pen
			VALUES(TODAY,paramFliq,paramRuta,vnumped,vnumcte,vnumtqe,vtpdo,vmotcan);
		END IF;
	END FOREACH; 
	RETURN	'A';
	
END PROCEDURE;