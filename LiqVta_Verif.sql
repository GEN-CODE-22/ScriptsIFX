DROP PROCEDURE LiqVta_Verif;

EXECUTE PROCEDURE  LiqVta_Verif(7564, 'M003','E','2023-05-15',5727.00,5727.00,53996.29,53996.29,13.92,6503.00);
EXECUTE PROCEDURE  LiqVta_Verif(7711, 'M004','E','2023-04-19',3733.00,3733.00,36824.37,36824.37,0.00,3733.00);
EXECUTE PROCEDURE  LiqVta_Verif(11441, 'B003','B','2023-07-22',1257.00,1257.00,10810.20,10810.20,00.00,1257.00);
EXECUTE PROCEDURE  LiqVta_Verif(7083, 'C014','C','2023-04-19',85.00,85.00,1556.35,1556.35,29.00,85.00);
EXECUTE PROCEDURE  LiqVta_Verif(17786, 'A001','A','2023-06-13',5.00,5.00,87.70,87.70,0.00,5.00);
EXECUTE PROCEDURE  LiqVta_Verif(2820, 'AP01','A','2023-04-19',70.00,70.00,1281.70,1281.70,0.00,70.00);
EXECUTE PROCEDURE  LiqVta_Verif(670, 'O001','G','2023-04-19',104.70,104.70,2564.10,2564.10,0.00,104.70);
EXECUTE PROCEDURE  LiqVta_Verif(14441, 'B003','S','2023-04-19',89.00,89.00,1013.71,1013.71,0.00,89.00);

SELECT	fec_erup, NVL(tot_erup,0), NVL(lcre_erup,0) + NVL(lefe_erup,0) + NVL(lpar_erup,0) + NVL(lotr_erup,0), NVL(imp_erup,0), 
			NVL(vcre_erup,0) + NVL(vefe_erup,0) + NVL(votr_erup,0), NVL(impasc_erup,0) + NVL(impase_erup,0) + NVL(impaso_erup,0),
			ldi_erup
	--INTO	vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif
	FROM	empxrutp
	WHERE	fliq_erup = 7564 AND rut_erup = 'M003';
	
CREATE PROCEDURE LiqVta_Verif
(
	paramFolio  INT,
	paramRuta	CHAR(4),
	paramTipo	CHAR(1),
	paramFecha  DATE,
	paramTlts	DECIMAL,
	paramStlts	DECIMAL,
	paramImpt	DECIMAL,
	paramSimpt	DECIMAL,
	paramTotA	DECIMAL,
	paramDif	DECIMAL
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(100);		-- Mensaje error
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(100);
DEFINE vusr 	CHAR(8);
DEFINE vdiaant 	INT;
DEFINE vdiaa 	INT;
DEFINE vdif 	INT;
DEFINE vtserv 	CHAR(6);
DEFINE vtservo 	CHAR(6);
DEFINE vimporte DECIMAL;
DEFINE vtlts 	DECIMAL;
DEFINE vimptot  DECIMAL;
DEFINE vimpasis DECIMAL;
DEFINE vtcel 	CHAR(1);
DEFINE vcount 	INT;
DEFINE vfolio 	INT;

LET vresult = 1;
LET vmensaje = '';
LET vtserv = '*';
LET vtservo = '*';
LET vusr = '';

IF	paramTipo = 'E' THEN
	LET vtserv = '[FIPT]';
END IF;
IF	paramTipo = 'B' THEN
	LET vtserv = '[FIPT]';
END IF;
IF	paramTipo = 'C' THEN
	LET vtserv = '[KQ]';
END IF;
IF	paramTipo = 'A' THEN
	LET vtserv = '[KQ]'; 
	--LET vtservo = '[CGKQ]';
END IF;

--REVISA SI LA LIQUIDACION ESTA EN USO ----------------------------------------------------------------------------------------
IF EXISTS(SELECT 1 FROM ruta_enuso WHERE fliq_renuso = paramFolio AND ruta_renuso = paramRuta) THEN
	SELECT	NVL(usr_renuso,'')
	INTO	vusr
	FROM	ruta_enuso
	WHERE	fliq_renuso = paramFolio AND ruta_renuso = paramRuta;
	
	LET vresult = 0;
	LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' OCUPADA POR EL USUARIO: ' || vusr;
	RETURN 	vresult,vmensaje;
END IF;

--REVISA SI LA FECHA DE LA LIQUIDACION TIENE MAS DE 5 DIAS-----------------------------------------------------------------------
IF	paramTipo = 'E' THEN
	LET vdiaant = DAY(paramFecha);
	LET vdiaa = DAY(TODAY);
	LET vdif = paramFecha - TODAY;	
	IF (vdif > 0 OR vdif < -5 OR (vdiaa = 4 OR vdiaa = 5) AND vdiaant > 25) THEN
		LET vresult = 0; 
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE MAS DE 5 DIAS';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA SI LAS NOTAS TIENEN FOLIO FISICO Y SE REQUIERE-----------------------------------------------------------------------
IF	EXISTS(SELECT 1 FROM nota_vta, datos 
	WHERE fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta IN('A','S') AND ffis_nvta IS NULL AND ffis_dat = 'S') THEN
	LET vresult = 0;
	LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE NOTAS SIN FOLIO FISICO';
	RETURN 	vresult,vmensaje;
END IF;

--REVISA SI LAS NOTAS TIENEN NO DE CLIENTE-------------------------------------------------------------------------------------
IF	paramTipo NOT IN('C') THEN
	IF	EXISTS(SELECT 1 FROM nota_vta 
		WHERE fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
		AND (numcte_nvta IS NULL OR numcte_nvta = '')) THEN
		LET vresult = 0;
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE NOTAS SIN NO DE CLIENTE';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA LAS NOTAS TIENEN TIPO DE SERVICIO-------------------------------------------------------------------------------------
IF	EXISTS(SELECT 1 FROM nota_vta 
	WHERE fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
	AND (tip_nvta IS NULL OR tip_nvta = '')) THEN
	LET vresult = 0;
	LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE NOTAS SIN TIPO DE SERVICIO';
	RETURN 	vresult,vmensaje;
END IF;

--REVISA SI HAY ALGUNA NOTA CON PRECIO INCORRCTO-------------------------------------------------------------------------------------
IF	EXISTS(SELECT 1 FROM nota_vta 
	WHERE fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
	AND ((impt_nvta - (tlts_nvta * pru_nvta) < -0.1) OR  (impt_nvta - (tlts_nvta * pru_nvta) > 0.1))) THEN
	
	SELECT  MIN(fol_nvta)
	INTO   	vfolio
	FROM 	nota_vta 
	WHERE 	fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
			AND ((impt_nvta - (tlts_nvta * pru_nvta) < -0.1) OR  (impt_nvta - (tlts_nvta * pru_nvta) > 0.1));
	LET vresult = 0;
	LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE NOTAS CON PRECIO INCORRECTO. NOTA: ' || vfolio ;
	RETURN 	vresult,vmensaje;
END IF;

--REVISA ASISTENCIA TIPO SERVICIO CARBURACION EN ESTACIONARIO-----------------------------------------------------------------------
IF	paramTipo = 'E' THEN
	IF	EXISTS(SELECT 1 FROM nota_vta 
		WHERE fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
		AND tip_nvta = 'B' AND impasi_nvta > 0.00) THEN
		LET vresult = 0;
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE NOTAS TIPO CARBURACION CON ASISTENCIA';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA TIPO SERVICIO ESTACIONARIO EN CARBURACION-----------------------------------------------------------------------
IF	paramTipo = 'B' THEN
	IF	EXISTS(SELECT 1 FROM nota_vta 
		WHERE fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
		AND tip_nvta = 'E') THEN
		LET vresult = 0;
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE NOTAS TIPO ESTACIONARIO';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA SI HAY NOTAS CON IMPORTE DE CONSUMO INTERNO, FUGAS, DONACION Y TRANSFERENCIA---------------------------------------
IF	paramTipo IN('E','B','C','A') THEN
	SELECT	NVL(SUM(impt_nvta),0)
	INTO	vimporte
	FROM	nota_vta
	WHERE	fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
			AND tpa_nvta MATCHES vtserv;
	IF	vimporte > 0 THEN
		LET vresult = 0;
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE NOTAS COM IMPORTE QUE NO DEBEN DE TENER';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA LOS LITROS E IMPORTE POR NOTA CON LO CONTABILIZADO-------------------------------------------------------------------------
SELECT	NVL(SUM(tlts_nvta),0), NVL(SUM(impt_nvta),0)
INTO	vtlts,vimptot
FROM	nota_vta
WHERE	fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
		AND tip_nvta MATCHES vtservo;
IF	paramTlts <> vtlts THEN
	LET vresult = 0;
	LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' NO CONCUERDAN LOS LITROS DE LAS NOTAS CON LO CONTABILIZADO';
	RETURN 	vresult,vmensaje;
END IF;
IF	paramImpt <> vimptot THEN
	LET vresult = 0;
	LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' NO CONCUERDAN LOS IMPORTES DE LAS NOTAS CON LO CONTABILIZADO';
	RETURN 	vresult,vmensaje;
END IF;

--REVISA SI HAY NOTAS CON ASISTENCIA-----------------------------------------------------------------------------------------------------
IF	paramTipo IN('E','B','C','A') THEN
	SELECT	NVL(SUM(impasi_nvta),0)
	INTO	vimpasis
	FROM	nota_vta
	WHERE	fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
			AND asiste_nvta = 'S';
	IF	paramTotA <> vimpasis THEN
		LET vresult = 0;
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' NO CONCUERDA LA ASISTENCIA CON LO CONTABILIZADO';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA SI HAY DIFERENCIA ENTRE LAS LECTURAS Y LO CONTABILIZADO---------------------------------------------------------------
IF	paramTipo IN('E','B','C','G','S') THEN
	IF	paramDif <> paramTlts THEN
		LET vresult = 0;
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' TIENE DIFERENCIA EN LITROS';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA SI HAY DIFERENCIA LITROS TOTAL CONTRA LA SUMA DE LOS LITROS-----------------------------------------------------------
IF	paramTipo IN('E','B','C','D','A') THEN
	IF	paramTlts <> paramStlts THEN
		LET vresult = 0;
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' NO CONCUERDAN LOS LITROS TOTALES CON LA SUMA DE LOS LITROS DE CADA TIPO DE PAGO';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA SI HAY DIFERENCIA IMPOTE TOTAL CONTRA LA SUMA DE LOS IMPORTES-----------------------------------------------------------
IF	paramTipo IN('E','B','C','A') THEN
	IF	paramImpt <> paramSimpt THEN
		LET vresult = 0;
		LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' NO CONCUERDAN EL IMPORTE TOTAL CON LA SUMA DE LOS IMPORTES DE CADA TIPO DE PAGO';
		RETURN 	vresult,vmensaje;
	END IF;
END IF;

--REVISA SI HAY INFORMACION SIN GUARDAR EN LA LIQUIDACION-----------------------------------------------------------
IF	paramTipo IN('E','B','C') THEN
	SELECT	NVL(tcel_rneco,'N')
	INTO 	vtcel
	FROM	ri505_neco
	WHERE	ruta_rneco = paramRuta;
	IF vtcel = 'S' THEN
		SELECT	COUNT(*)
		INTO	vcount
		FROM	nota_vta, enruta
		WHERE	fliq_nvta = paramFolio AND ruta_nvta = paramRuta AND edo_nvta in('A','S') 
				AND (tip_nvta = '' OR tip_nvta IS NULL)
				AND (ffis_nvta IS NULL AND fol_nvta = fol_enr[5,10] AND cia_nvta = fol_enr[1,2] AND pla_nvta = fol_enr[3,4] OR
				ffis_nvta IS NOT NULL AND ffis_nvta = fol_enr) AND edovta_enr = 'l';
		IF	vcount > 0	THEN
			LET vresult = 0;
			LET vmensaje = 'LIQUIDACION: ' || paramFolio || ' RUTA: ' || paramRuta || ' NO ESTA GUARDADA LA LIQUIDACION AUTOMATICA';
			RETURN 	vresult,vmensaje;
		END IF;
	END IF;
END IF;

RETURN 	vresult,vmensaje;
END PROCEDURE; 

SELECT	NVL(usr_renuso,'')
FROM	ruta_enuso
WHERE	fliq_renuso = 7318 AND ruta_renuso = 'C025';

select	*
from	ruta_enuso

delete
from	ruta_enuso
where	fliq_renuso = 7318 AND ruta_renuso = 'C025';

insert	into ruta_enuso VALUES (7318,'C025',CURRENT,'fuente')

select	*
from	datos

select	*
from	nota_vta
where	fes_nvta = '2023-03-27' and edo_nvta = 'S' and fliq_nvta = 1011 and ruta_nvta = 'M021'

select	*
from	nota_vta
where	fes_nvta = '2023-03-27' and edo_nvta = 'S' and fliq_nvta = 1011 and ruta_nvta = 'M021' and tpa_nvta MATCHES '*'

SELECT	SUM(tlts_nvta), SUM(impt_nvta)
FROM	nota_vta
WHERE	fliq_nvta = 3089 AND ruta_nvta = 'M005' AND edo_nvta in('A','S') 

SELECT	NVL(SUM(impasi_nvta),0)
FROM	nota_vta
WHERE	fliq_nvta = 3089 AND ruta_nvta = 'M005' AND edo_nvta in('A','S') 
		AND asiste_nvta = 'S';
		
select	*
from	nota_vta
where	impasi_nvta > 0.00 and edo_nvta in('A','S') and tip_nvta = 'B' and ruta_nvta[1] = 'M'

SELECT	NVL(SUM(tlts_nvta),0), NVL(SUM(impt_nvta),0)
FROM	nota_vta
WHERE	fliq_nvta = 11441 AND ruta_nvta = 'B003' AND edo_nvta in('A','S') 
		AND tip_nvta MATCHES vtservo;
		
SELECT  MIN(fol_nvta)
FROM 	nota_vta 
WHERE 	fliq_nvta = 11441 AND ruta_nvta = 'B003' AND edo_nvta in('A','S') 
		AND (pru_nvta * tlts_nvta) <> impt_nvta;
		
SELECT *
FROM nota_vta 
	WHERE fliq_nvta = 670 AND ruta_nvta = 'O001' AND edo_nvta in('A','S') 	
	AND ((impt_nvta - (tlts_nvta * pru_nvta) < -0.01) OR  (impt_nvta - (tlts_nvta * pru_nvta) > 0.01))
			AND ((pru_nvta * tlts_nvta) <> impt_nvta)