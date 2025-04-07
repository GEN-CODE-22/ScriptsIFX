DROP PROCEDURE LiqCob_PagoFac;
EXECUTE PROCEDURE  LiqCob_PagoFac(37737,236262,'EAQ','15','15','50',2632.50,'2025-03-10','EFECTIVO',25,'laura');


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
					WHERE 	sta_mcxc = 'A' AND ffac_mcxc = paramFolio 
							AND sfac_mcxc = paramSerie AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99') 
							AND fliq_mcxc = paramFolLiq) OR paramTipmov = '52') THEN
	
	SELECT  SUM(sal_doc) 
	INTO	vsalfac
	FROM 	doctos 
	WHERE   sta_doc = 'A' AND ffac_doc = paramFolio AND sfac_doc = paramSerie
			AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');
	IF paramImp <= vsalfac	THEN		
		LET vimpfac = paramImp;
		FOREACH cFactura FOR
			SELECT  fol_doc, cia_doc, pla_doc, tip_doc, sal_doc, vuelta_doc
			INTO	vfoldoc, vciadoc, vpladoc, vtipdoc, vsaldoc, vvuelta
			FROM 	doctos 
			WHERE   sta_doc = 'A' AND ffac_doc = paramFolio AND sfac_doc = paramSerie
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
				WHERE	fol_fac = paramFolio AND ser_fac = paramSerie; 
			END IF;
			-- SE ELIMINA EL REGISTRO DE LA TABLA contrare-----------------------------------------------------------------
			IF EXISTS(	SELECT 	1 
  						FROM 	contrare 
						WHERE 	fol_ctra = paramFolio AND ser_ctra = paramSerie AND tip_ctra = '00' AND fom_ctra = 'F') THEN
				DELETE FROM contrare
				WHERE 	fol_ctra = paramFolio AND ser_ctra = paramSerie AND tip_ctra = '00' AND fom_ctra = 'F';
			END IF;
			-- SE ACTUALIZA EL numpag_dlcob EN EL DETALLE DE LA LIQUIDACION-------------------------------------------------
			SELECT  COUNT(unique fliq_mcxc)
			INTO    vcountp
			FROM	mov_cxc
			WHERE	ffac_mcxc = paramFolio AND sfac_mcxc = paramSerie 
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
WHERE   cia_doc = '15' AND pla_doc = '10' AND sta_doc = 'A' AND ffac_doc  in(235637)   AND sfac_doc = 'EAQ'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');
	
SELECT  fol_doc, cia_doc, pla_doc, tip_doc, sal_doc, vuelta_doc
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '02' AND sta_doc = 'A' AND ffac_doc = 73 AND sfac_doc = 'EAQF'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0.01374540

SELECT  *
FROM 	doctos 
WHERE   cia_doc = '15' AND sta_doc = 'A' AND ffac_doc in(585519) AND sfac_doc = 'EAI'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') and femi_doc >= '2023-06-01' 

update	doctos
set		abo_doc = 4.35, sal_doc = 4002.45, fult_doc = '2023-12-28'
where	cia_doc = '15' AND pla_doc = '34' AND sta_doc = 'A' AND fol_doc = 26243 and vuelta_doc = 2
		
		
SELECT  rowid,*
FROM 	mov_cxc 
WHERE   cia_mcxc = '15' AND sta_mcxc = 'A' AND ffac_mcxc in(239576)   AND sfac_mcxc = 'EAJ'
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99') and fec_mcxc >= '2023-06-01'
		
update  mov_cxc 
set		fliq_mcxc = 67917   
WHERE   rowid = 160105986--cia_mcxc = '15' AND pla_mcxc = '54' AND sta_mcxc = 'A' AND doc_mcxc = 131192 and tpm_mcxc  = '58' and num_mcxc = 2
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99') and fec_mcxc >= '2023-06-01'
		
		
SELECT  COUNT(unique fec_mcxc)
FROM	mov_cxc
WHERE	ffac_mcxc = 1078612 AND sfac_mcxc = 'EAB' AND cia_mcxc = '15' AND pla_mcxc = '02'
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99')
		AND tpm_mcxc BETWEEN '50' AND '63' AND tpm_mcxc <> '52';
		
select	*
from	mov_cxc
where	fliq_mcxc = 65173 

select	*
from	mov_cxc
where	ffac_mcxc = 30842 and sfac_mcxc = 'EAPH' and tpm_mcxc > '49'

select	*
from	mov_cxc
where	fec_mcxc = '2023-01-06' and tpm_mcxc >= '50' 

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
where	rowid in()

select	rowid,* 
from	mov_cxc m
where	ffac_mcxc is not null and tip_mcxc= '11' and pla_mcxc= '84'
		and doc_mcxc in(select doc_mcxc from mov_cxc where pla_mcxc = '84' and tip_mcxc = '01' and ffac_mcxc = m.ffac_mcxc )

select	*
from	doctos
where	fol_doc in(453747) and vuelta_Doc = 2 and cte_doc = '003076'

update	doctos
set		car_doc = 698.28, sal_doc = 698.28
where	fol_doc in(57868) and pla_doc = '03' and vuelta_doc = 3


select	car_doc - (select sum(imp_mcxc) 
						from mov_cxc 
						where doc_mcxc = fol_doc and cia_mcxc = cia_doc and pla_mcxc = pla_doc and vuelta_mcxc = vuelta_doc
								and tpm_mcxc > '49')
from	doctos
where	fol_doc in(177381) and tip_doc = '01'

select	*
from	doctos
where	fol_doc in (select doc_mcxc from mov_cxc 
					where doc_mcxc = fol_doc and cia_mcxc = cia_doc and pla_mcxc = pla_doc and vuelta_mcxc = vuelta_doc
							and fec_mcxc = '2023-03-09')
		and sal_doc <> (car_doc - (select sum(imp_mcxc) 
						from mov_cxc 
						where doc_mcxc = fol_doc and cia_mcxc = cia_doc and pla_mcxc = pla_doc and vuelta_mcxc = vuelta_doc
								and tpm_mcxc > '49'))
		

update	doctos
set		fult_doc = '2022-10-31'
where	fol_doc in(332710) and cte_doc = '174021'

select	rowid,*
from	mov_cxc
where 	doc_mcxc in(453747) and tip_mcxc = '08' and pla_mcxc = '96' and cte_mcxc = '075092'

insert into mov_cxc
values('128576','58','01',421178,null,'','15','02',1167055,'EAB',2,'A','C','4',1391.20,'2023-11-16','2023-11-17','2023-11-20','AxF1167055EAB10','pueblito',66323,14)


update	mov_cxc
set		imp_mcxc = 698.28 --doc_mcxc = 26243, uso_mcxc = 7, cte_mcxc = '050660', ffac_mcxc = 107480
where 	rowid = 17793296 --doc_mcxc in(712257,712258,712259) and cte_mcxc = '216701' and num_mcxc = 2

select	*
from	mov_cxc
where	rowid = 33555977

select	*
from	mov_cxc
where	desc_mcxc like '%PASA A%' and fec_mcxc >= '2022-06-01'



update	mov_cxc
set		doc_mcxc = 376794, ffac_mcxc = 172778, desc_mcxc = 'AxF172778EABA1'     
where	rowid in(132925700)
				