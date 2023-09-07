DROP PROCEDURE LiqCob_PagoFac;
EXECUTE PROCEDURE  LiqCob_PagoFac(48121,499412,'EAA','15','01','58',684.60,'2022-09-03','847867',3,'lucia');

CREATE PROCEDURE LiqCob_PagoFac
(
	paramFolLiq   	INT,
	paramFolio  	INT,
	paramSerie		CHAR(4),
	paramCia		CHAR(2),
	paramPla		CHAR(2),
	paramTipmov		CHAR(2),
	paramImp		DECIMAL,
	paramFecLiq		DATE,
	paramDesc		CHAR(20),
	paramLinea		INT,
	paramUsr		CHAR(8)	
)

RETURNING  
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100),	-- Mensaje
 DECIMAL;   -- importe pagado

DEFINE vproceso	INT;
DEFINE vmensaje	CHAR(100);
DEFINE vmsg		CHAR(100);
DEFINE vsaldo   DECIMAL;
DEFINE vimppag  DECIMAL;
DEFINE vsalfac  DECIMAL;
DEFINE vimpfac  DECIMAL;
DEFINE vfoldoc 	INT;
DEFINE vsaldoc  DECIMAL;
DEFINE vciadoc 	CHAR(2);
DEFINE vpladoc 	CHAR(2);
DEFINE vtipdoc 	CHAR(2);
DEFINE vdescdoc	CHAR(20);
DEFINE vimpmov  DECIMAL;
DEFINE vimptot  DECIMAL;
DEFINE vcountp 	INT;
DEFINE vvuelta 	INT;

LET vproceso = 1;
LET vmensaje = '';
LET vsaldo = 0;
LET vimppag = 0;
LET vimptot = 0;

IF (NOT EXISTS(	SELECT 	1 
					FROM 	mov_cxc 
					WHERE 	cia_mcxc = paramCia AND pla_mcxc = paramPla AND sta_mcxc = 'A' AND ffac_mcxc = paramFolio 
							AND sfac_mcxc = paramSerie AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99') 
							AND fliq_mcxc = paramFolLiq) OR paramTipmov = '52') THEN
			
	SELECT  SUM(sal_doc) 
	INTO	vsalfac
	FROM 	doctos 
	WHERE   cia_doc = paramCia AND pla_doc = paramPla AND sta_doc = 'A' AND ffac_doc = paramFolio AND sfac_doc = paramSerie
			AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');
	IF paramImp <= vsalfac	THEN		
		LET vimpfac = paramImp;
		FOREACH cFactura FOR
			SELECT  fol_doc, cia_doc, pla_doc, tip_doc, sal_doc, vuelta_doc
			INTO	vfoldoc, vciadoc, vpladoc, vtipdoc, vsaldoc, vvuelta
			FROM 	doctos 
			WHERE   cia_doc = paramCia AND pla_doc = paramPla AND sta_doc = 'A' AND ffac_doc = paramFolio AND sfac_doc = paramSerie
					AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0.00
					
			IF vproceso = 1 AND vimpfac > 0 THEN
				IF vimpfac > vsaldoc THEN
					LET vimpmov = vsaldoc;
				ELSE
					LET vimpmov = vimpfac;
				END IF;	
				LET vdescdoc = 'AxF' || paramFolio || TRIM(paramSerie) || paramDesc;
				LET vproceso,vmsg,vimppag,vsaldo = LiqCob_PagoDoc(paramFolLiq,vfoldoc,vciadoc,vpladoc,vtipdoc,paramTipmov,vimpmov,paramFecLiq,vdescdoc,paramUsr,vvuelta,'');
				IF vproceso = 1 THEN
					LET vimpfac = vimpfac - vimppag;
					LET vimptot = vimptot + vimppag;							
				ELSE
					LET vproceso = 0;
					LET vmensaje = 'ERROR AL PROCESAR: ' || vmsg;			
				END IF;
			END IF;					
		END FOREACH;
		-- SE APLICO EL PAGO A LA FACTURA CORRECTAMENTE--------------------------------------------------------------------
		IF vimpfac = 0 THEN
			-- SI SE PAGO EL SALDO TOTAL DE LA FACTURA, SE ACTUALIZA A PAGADA EN TABLA factura-----------------------------
			IF paramImp = vsalfac THEN
				UPDATE	factura
				SET		edo_fac = 'P'
				WHERE	fol_fac = paramFolio AND ser_fac = paramSerie AND cia_fac = paramCia AND pla_fac = paramPla;
			END IF;
			-- SE ELIMINA EL REGISTRO DE LA TABLA contrare-----------------------------------------------------------------
			IF EXISTS(	SELECT 	1 
  						FROM 	contrare 
						WHERE 	fol_ctra = paramFolio AND ser_ctra = paramSerie AND cia_ctra = paramCia 
						  		AND pla_ctra = paramPla AND tip_ctra = '00' AND fom_ctra = 'F') THEN
				DELETE FROM contrare
				WHERE 	fol_ctra = paramFolio AND ser_ctra = paramSerie AND cia_ctra = paramCia 
						AND pla_ctra = paramPla AND tip_ctra = '00' AND fom_ctra = 'F';
			END IF;
			-- SE ACTUALIZA EL numpag_dlcob EN EL DETALLE DE LA LIQUIDACION-------------------------------------------------
			SELECT  COUNT(unique fliq_mcxc)
			INTO    vcountp
			FROM	mov_cxc
			WHERE	ffac_mcxc = paramFolio AND sfac_mcxc = paramSerie AND cia_mcxc = paramCia AND pla_mcxc = paramPla
					AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99')
					AND tpm_mcxc BETWEEN '50' AND '63' AND tpm_mcxc <> '52' and sta_mcxc = 'A';
			UPDATE  det_lcob
			SET		numpag_dlcob = vcountp
			WHERE	fliq_dlcob = paramFolLiq AND num_dlcob = paramLinea;
		END IF;		
	ELSE
		LET vproceso = 0;
		LET vmensaje = 'ERROR AL PROCESAR: EL IMPORTE ' || NVL(paramImp,0) || ' ES MAYOR AL SALDO DE LA FACTURA ' || NVL(vsalfac,0);			
	END IF;
ELSE
	LET vmensaje = 'YA EXISTE UN PAGO REGISTRADO A LA FACTURA DE ESA LIQUIDACION ' || paramFolio || ' ' || paramSerie;
END IF;

RETURN 	vproceso,vmensaje,vimptot;
END PROCEDURE; 

SELECT  SUM(sal_doc) 
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '09' AND sta_doc = 'A' AND ffac_doc = 194151   AND sfac_doc = 'EAP'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');
		
SELECT  *
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '85' AND sta_doc = 'A' AND ffac_doc in(14820)   AND sfac_doc = 'EAPH'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0.00
		
SELECT  COUNT(unique fec_mcxc)
FROM	mov_cxc
WHERE	ffac_mcxc = 69975 AND sfac_mcxc = 'EAOA' AND cia_mcxc = '15' AND pla_mcxc = '55'
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99')
		AND tpm_mcxc BETWEEN '50' AND '63' AND tpm_mcxc <> '52';
		
select	*
from	mov_cxc
where	fliq_mcxc = 65173   

SELECT  SUM(sal_doc),sum(car_doc), sum(abo_doc) 
FROM 	doctos 
WHERE   sta_doc = 'A' AND cte_doc = '00618' and femi_doc <= '2022-05-10'
		AND (tip_doc in ('01','03') OR tip_doc >= '11' AND tip_doc <= '99');  
		
SELECT  *
FROM 	doctos 
WHERE   sta_doc = 'A' AND cte_doc = '000618' 
		AND tip_doc in ('01','03') and sal_doc > 0
		
SELECT  COUNT(unique fec_mcxc)
FROM	mov_cxc
WHERE	ffac_mcxc = 64427 AND sfac_mcxc = 'EAL' AND cia_mcxc = '15' AND pla_mcxc = '18'
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99')
		AND tpm_mcxc BETWEEN '50' AND '63' AND tpm_mcxc <> '52' and sta_mcxc = 'A';
		
select	rowid,* 
from	doctos d
where	ffac_doc is not null and tip_doc = '11' and pla_doc = '84'
		and fol_doc in(select fol_doc from doctos where pla_doc = '84' and tip_doc = '01' and ffac_doc = d.ffac_doc )
		
update  doctos
set		ffac_doc = null, sfac_doc = null
where	rowid in(1344531,1476358,1476360,1539842,1539851,1558545,1595912,1617923,1617924,1632783,1632784,1635595,1635596,1635598,
			1635600,1644811,1646344,1673223,1675013,1675537,1675538,1676810,1691155,1691156,1699347,1699349,1699350,1699589,1711367,
		1723146,1724942,1735435)

select	rowid,* 
from	mov_cxc m
where	ffac_mcxc is not null and tip_mcxc= '11' and pla_mcxc= '84'
		and doc_mcxc in(select doc_mcxc from mov_cxc where pla_mcxc = '84' and tip_mcxc = '01' and ffac_mcxc = m.ffac_mcxc )

select	*
from	mov_cxc
where 	pla_mcxc = '85' and doc_mcxc = 29800


update	mov_cxc
set		ffac_mcxc = null, sfac_mcxc = null
where	rowid in(3413267,3510804,3734542,3734544,3782420,3887368,3887377,3915029,3938307,3956491,3961611,4024578,4079363,4080905,4080906,
		4093959,4117266,4117267,4124929,4124930,4124932,4124934,4146194,4148232,4158219,4158220,4158222,4158224,4177420,4177421,4180228,
		4197897,4215826,4218888,4221703,4221704,4223497,4233740,4261134,4261135,4270084,4270085,4279051,4279053,4279054,4279060,4281098,
		4288527,4289812,4292366,4297987,4301062,4306196,4307969,4311052,4339713,4343048,4346121,4364560,4407559,4414229,4415492,4458500,
		4560403,4812556,4812558,4812559,21096210)
				