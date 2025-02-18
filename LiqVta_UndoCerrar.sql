DROP PROCEDURE LiqVta_UndoCerrar;
EXECUTE PROCEDURE  LiqVta_UndoCerrar(8056,'M005','2025-01-09'); 	

CREATE PROCEDURE LiqVta_UndoCerrar
(
	paramFliq	INT,
	paramRuta	CHAR(4),
	paramFecha  DATE
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(255),		-- Mensaje error
 DECIMAL;		-- Monto dado de baja
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(255);
DEFINE vtotal   DECIMAL;
DEFINE vproceso INT;
DEFINE vmsg 	CHAR(100);
DEFINE vfolio	INT;
DEFINE vcia		CHAR(2);
DEFINE vpla		CHAR(2);
DEFINE vvuelta	INT;
DEFINE vcargo   DECIMAL;
DEFINE vmonto   DECIMAL;
DEFINE vtipo    CHAR(1);
DEFINE vtotliq  DECIMAL;
DEFINE vtotvta  DECIMAL;

LET vresult = 1;
LET vmensaje = '';
LET vtotal = 0;
LET vproceso = 1;
LET vmsg = '';
LET vmonto = 0;

IF NOT EXISTS(SELECT 	1 
				FROM 	e_posaj 
				WHERE 	epo_fec = paramFecha) THEN
	IF paramFliq > 0 THEN
		LET vtipo = paramRuta[1];
		FOREACH cDoctos FOR
			SELECT	cia_doc, pla_doc, fol_doc, vuelta_doc, car_doc
			INTO	vcia,vpla,vfolio,vvuelta,vcargo
			FROM	doctos, nota_vta
			WHERE	cia_doc = cia_nvta AND pla_doc = pla_nvta 
					AND fol_doc = fol_nvta AND  vuelta_doc = vuelta_nvta
					AND fes_nvta = paramFecha AND edo_nvta = 'A' 
					AND ruta_nvta = paramRuta 
					AND femi_doc = paramFecha 
			
			LET vproceso,vmsg,vmonto = cxc_bajadocumento(vfolio,vcia,vpla,vvuelta); 
			
			IF vproceso = 1 THEN
				UPDATE 	nota_vta
				SET		napl_nvta = 'N'
				WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
				
				LET vtotal = vtotal + vcargo;
			END IF;
		END FOREACH;	
					
		UPDATE	nota_vta
		SET		edo_nvta = 'S'
		WHERE	fes_nvta = paramFecha AND edo_nvta = 'A' AND ruta_nvta = paramRuta;
		
		IF	vtipo = 'M' THEN
			UPDATE  empxrutp
			SET 	edo_erup  = 'P'
			WHERE	fec_erup = paramFecha AND rut_erup = paramRuta;
		END IF;
		IF	vtipo = 'C' THEN
			UPDATE  empxrutc
			SET 	edo_eruc  = 'P'
			WHERE	fec_eruc = paramFecha AND rut_eruc = paramRuta;
		END IF;
		IF	vtipo = 'B' THEN
			UPDATE  venxmed
			SET 	edo_vmed  = 'P'
			WHERE	fec_vmed = paramFecha AND rut_vmed = paramRuta;
		END IF;
		IF	vtipo = 'A' THEN
			UPDATE  venxand
			SET 	edo_vand  = 'P'
			WHERE	fec_vand = paramFecha AND rut_vand = paramRuta;
		END IF;
		IF	vtipo = 'D' THEN
			UPDATE  des_dir
			SET 	edo_desd = 'P'
			WHERE	fec_desd = paramFecha AND rut_desd = paramRuta;
		END IF;
		IF	vtipo = 'O' THEN
			UPDATE  gto_gas
			SET 	edo_ggas = 'P'
			WHERE	fec_ggas = paramFecha AND rut_ggas = paramRuta;
		END IF;
		IF	vtipo = 'H' THEN
			UPDATE  gto_die
			SET 	edo_gdie = 'P'
			WHERE	fec_gdie = paramFecha AND rut_gdie = paramRuta;
		END IF;
		
		IF	vtipo = 'M' OR vtipo = 'C' OR vtipo = 'B' THEN
			DELETE
			FROM	vtaxemp
			WHERE	fec_vemp  = paramFecha AND ruta_vemp = paramRuta;
		END IF;
	ELSE
		FOREACH cDoctos FOR
			SELECT	cia_doc, pla_doc, fol_doc, vuelta_doc, car_doc
			INTO	vcia,vpla,vfolio,vvuelta,vcargo
			FROM	doctos 
			WHERE	femi_doc = paramFecha 
			
			LET vproceso,vmsg,vmonto = cxc_bajadocumento(vfolio,vcia,vpla,vvuelta); 
			
			IF vproceso = 1 THEN
				UPDATE 	nota_vta
				SET		napl_nvta = 'N'
				WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
				
				LET vtotal = vtotal + vcargo;
			END IF;
		END FOREACH;	
		
		UPDATE	nota_vta
		SET		edo_nvta = 'S'
		WHERE	fes_nvta = paramFecha AND edo_nvta = 'A';
		
		UPDATE  empxrutp
		SET 	edo_erup  = 'P'
		WHERE	fec_erup = paramFecha AND edo_erup = 'C';
		
		UPDATE 	empxrutc 
		SET 	edo_eruc = 'P' 
		WHERE   fec_eruc = paramFecha and edo_eruc = 'C';
		
		UPDATE  venxmed
		SET 	edo_vmed = 'P'
		WHERE	fec_vmed = paramFecha AND edo_vmed = 'C';
		
		UPDATE	des_dir
		SET		edo_desd = 'P'
		WHERE   fec_desd = paramFecha AND edo_desd = 'C';
		
		UPDATE	venxand
		SET		edo_vand = 'P'
		WHERE	fec_vand = paramFecha AND edo_vand = 'C';
		
		UPDATE	gto_die
		SET		edo_gdie = 'P'
		WHERE	fec_gdie = paramFecha AND edo_gdie = 'C';
		
		UPDATE	gto_gas
		SET		edo_ggas = 'P'
		WHERE	fec_ggas = paramFecha AND edo_ggas = 'C';
		
		DELETE
		FROM	vtaxemp
		WHERE	fec_vemp  = paramFecha;
	END IF;
ELSE
	LET vresult = 0;
	LET vmensaje = 'NO SE PUEDE REALIZAR EL PROCESO, EL DIA YA ESTA CERRADO.';	
	RETURN 	vresult,vmensaje,vtotal;
END IF;

LET vresult = vproceso;
LET vmensaje = vmsg;

RETURN 	vresult,vmensaje,vtotal;
END PROCEDURE; 

SELECT 	* 
FROM 	e_posaj 
WHERE 	epo_fec = '2022-05-30'

SELECT	cia_doc, pla_doc, fol_doc, vuelta_doc, car_doc
FROM	doctos 
WHERE	femi_doc = '2024-05-29' 

select	*
from	nota_vta
where	fes_nvta = '2024-06-27' and edo_nvta in('A','S') and tpa_nvta in('C','G') and napl_nvta = 'C'

select	*
from	nota_vta
where	fes_nvta = '2024-06-24' and edo_nvta in('A','S') and tpa_nvta in('C','G') and napl_nvta = 'C'

select	*
from	nota_vta
where	fes_nvta = '2024-09-05' and edo_nvta in('A','S') and tpa_nvta in('C','G') and napl_nvta = 'C'

select	*
from	doctos
where	femi_doc = '2024-06-24' and tpa_doc in('C','G')

select 	*
from	venxand
where	fliq_vand = 7422 and rut_vand = 'A001'

select *
from 	nota_vta 
where 	fliq_nvta = 8056 and ruta_nvta = 'M005'
