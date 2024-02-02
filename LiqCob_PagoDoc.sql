DROP PROCEDURE LiqCob_PagoDoc;
EXECUTE PROCEDURE  LiqCob_PagoDoc(44952,113995,'15','33','01','50',9452.50,'2021-10-22','EFECTIVO','fuente');
EXECUTE PROCEDURE  LiqCob_PagoDoc(44938,200499,'15','02','01','fuente');

CREATE PROCEDURE LiqCob_PagoDoc
(
	paramFolLiq   	INT,
	paramFolDoc   	INT,
	paramCia		CHAR(2),
	paramPla		CHAR(2),
	paramTipo		CHAR(2),
	paramTipmov		CHAR(2),
	paramImp		DECIMAL,
	paramFecLiq		DATE,
	paramDesc		CHAR(20),
	paramUsr		CHAR(8),
	paramVuelta		SMALLINT,
	paramSer		CHAR(4)
)

RETURNING  
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100),	-- Mensaje
 DECIMAL,   -- importe pagado
 DECIMAL;   -- saldo

DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(100);
DEFINE vctedoc 	CHAR(6);
DEFINE vtip 	CHAR(2);
DEFINE vfoldoc	INT;
DEFINE vffis 	DECIMAL;
DEFINE vserie 	CHAR(4);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vffac 	INT;
DEFINE vsfac 	CHAR(4);
DEFINE vsta 	CHAR(1);
DEFINE vtpa 	CHAR(1);
DEFINE vuso 	CHAR(1);
DEFINE vcargo 	DECIMAL;
DEFINE vabono 	DECIMAL;
DEFINE vsaldo 	DECIMAL;
DEFINE vctecar 	DECIMAL;
DEFINE vcteabo 	DECIMAL;
DEFINE vctesal 	DECIMAL;
DEFINE vsalini  DECIMAL;
DEFINE vfechav 	DATE;
DEFINE vfechaub	DATE;
DEFINE vctefecu	DATE;
DEFINE vvuelta 	INT;
DEFINE vnummov 	INT;
DEFINE vimppag  DECIMAL;

LET vproceso = 1;
LET vmsg = '';
LET vsaldo = 0;
LET vimppag = 0;

IF (NOT EXISTS(SELECT 	1 
		  	FROM 	mov_cxc 
		  	WHERE 	doc_mcxc = paramFolDoc AND cia_mcxc = paramCia AND pla_mcxc = paramPla AND sta_mcxc = 'A'
		  			AND (vuelta_mcxc = paramVuelta OR tip_mcxc = paramTipo) AND fliq_mcxc = paramFolLiq) OR paramTipmov = '55')
		  			AND paramImp > 0 THEN
	LET vproceso = 1;	
	IF paramVuelta > 0 THEN
		SELECT  cte_doc, tip_doc, fol_doc, ffis_doc, ser_doc, cia_doc, pla_doc, ffac_doc, sfac_doc, sta_doc, tpa_doc, uso_doc,
				sal_doc, fven_doc,vuelta_doc, fult_doc, car_doc, abo_doc
		INTO	vctedoc, vtip, vfoldoc, vffis, vserie, vcia, vpla, vffac, vsfac, vsta, vtpa, vuso, vsaldo, vfechav, vvuelta,
				vfechaub, vcargo, vabono
		FROM	doctos
		WHERE	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla 
				AND vuelta_doc = paramVuelta AND sal_doc > 0.0;
	ELSE
		SELECT  cte_doc, tip_doc, fol_doc, ffis_doc, ser_doc, cia_doc, pla_doc, ffac_doc, sfac_doc, sta_doc, tpa_doc, uso_doc,
				sal_doc, fven_doc,vuelta_doc, fult_doc, car_doc, abo_doc
		INTO	vctedoc, vtip, vfoldoc, vffis, vserie, vcia, vpla, vffac, vsfac, vsta, vtpa, vuso, vsaldo, vfechav, vvuelta,
				vfechaub, vcargo, vabono
		FROM	doctos	
		WHERE	fol_doc = paramFolDoc AND ser_doc = paramSer AND cia_doc = paramCia AND pla_doc = paramPla 
				AND tip_doc = paramTipo AND sal_doc > 0.0;
	END IF;			
	
	
	IF vfoldoc > 0 AND paramImp <= vsaldo THEN 
		LET vsalini = vsaldo;
		IF paramVuelta > 0 THEN
			SELECT	MAX(num_mcxc)
			INTO	vnummov
			FROM	mov_cxc
			WHERE	doc_mcxc = vfoldoc AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
					AND vuelta_mcxc = vvuelta AND cte_mcxc = vctedoc;
		ELSE
			SELECT	MAX(num_mcxc)
			INTO	vnummov
			FROM	mov_cxc
			WHERE	doc_mcxc = vfoldoc AND ser_mcxc = paramSer AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
					AND tip_mcxc = vtip AND cte_mcxc = vctedoc;
		END IF;
		LET vnummov = vnummov + 1;
			
		IF paramImp > vsaldo THEN
			LET vimppag = vsaldo;
		ELSE
			LET vimppag = paramImp;
		END IF;
		
		--INSERTA EN LA TABLA mov_cxc---------------------------------------------------------------
		INSERT INTO mov_cxc
		VALUES(vctedoc,paramTipmov,vtip,vfoldoc,vffis,vserie,vcia,vpla,vffac,vsfac,vnummov,vsta,vtpa,vuso,vimppag,paramFecLiq,TODAY,vfechav,paramDesc,paramUsr,paramFolLiq,vvuelta);
		
		--ACTUALIZA SALDOS DE DOCUMENTO--------------------------------------------------------------
		LET vabono = vabono + vimppag;
		LET vsaldo = vcargo - vabono;
		IF	paramFecLiq  > vfechaub THEN
			LET vfechaub = paramFecLiq;
		END IF;
		IF paramVuelta > 0 THEN
			UPDATE	doctos
			SET		abo_doc = vabono,
					sal_doc = vsaldo,
					fult_doc = vfechaub
			WHERE	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla 
					AND vuelta_doc = vvuelta AND cte_doc = vctedoc;
		ELSE
			UPDATE	doctos
			SET		abo_doc = vabono,
					sal_doc = vsaldo,
					fult_doc = vfechaub
			WHERE	fol_doc = paramFolDoc AND ser_doc = paramSer AND cia_doc = paramCia AND pla_doc = paramPla 
					AND tip_doc = vtip AND cte_doc = vctedoc;
		END IF;
		--ACTUALIZA SALDOS DEL CLIENTE-----------------------------------------------------------------
		SELECT	saldo_cte, abono_cte, cargo_cte, fecuab_cte
		INTO	vctesal, vcteabo, vctecar, vctefecu
		FROM	cliente
		WHERE	num_cte = vctedoc;
		
		LET vcteabo = vcteabo + vimppag;
		LET vctesal = vctecar - vcteabo;
		IF vctefecu IS NULL THEN
			LET vctefecu = paramFecLiq;
		ELSE
			IF vctefecu < paramFecLiq THEN
				LET vctefecu = paramFecLiq;
			END IF;
		END IF;
		
		UPDATE	cliente
		SET		saldo_cte = vctesal,
				abono_cte = vcteabo,
				fecuab_cte= vctefecu
		WHERE	num_cte = vctedoc;
		
	ELSE
		LET vmsg = 'EL IMPORTE ' || paramImp || ' ES MAYOR AL SALDO DEL DOCUMENTO' || vsaldo;	
		LET vproceso = 0;
	END IF;
ELSE
	LET vmsg = 'YA EXISTE UN PAGO REGISTRADO AL DOCUMENTO DE ESA LIQUIDACION O IMPORTE 0' || paramFolDoc;
END IF;

RETURN 	vproceso,vmsg,vimppag,vsaldo;
END PROCEDURE;                    
-- NO PAGADO 113578 
-- 

SELECT  cte_doc, tip_doc, fol_doc, ffis_doc, ser_doc, cia_doc, pla_doc, ffac_doc, sfac_doc, sta_doc, tpa_doc, uso_doc,
			sal_doc, fven_doc,vuelta_doc, fult_doc, car_doc, abo_doc
	FROM	doctos
	WHERE	fol_doc = 489540 AND cia_doc = '15' AND pla_doc = '03' AND vuelta_doc = 2
			(vuelta_doc = is null OR tip_doc = '03') AND sal_doc > 0.0;
	
select	*
from	doctos
where	fol_doc in(962227) and cte_doc = '08869'

select	*
from	mov_cxc
where	doc_mcxc in(964517) and pla_mcxc ='23' and cte_mcxc = '061549' and tpm_mcxc = '50'

select	saldo_cte, abono_cte, cargo_cte, fecuab_cte, * 
from	cliente
where   num_cte = '086579'

update	cliente
set		cargo_cte = 4799607.49, saldo_cte = 44182.17, abono_cte = 4755425.32--, abono_cte = 20116161.05--, fecuab_cte = '2022-09-20'
where   num_cte = '011516'


select	sum(abo_doc),sum(car_doc)
from	doctos
where	cte_doc in('086579') and sta_doc = 'A'

select	*
from	doctos
where	cte_doc in('060284') and sta_doc = 'A'

SELECT  SUM(sal_doc) 
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '33' AND sta_doc = 'A' AND ffac_doc = 25390 AND sfac_doc = 'EABC'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')
		
SELECT  fol_doc, cia_doc, pla_doc, tip_doc, sal_doc
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '33' AND sta_doc = 'A' AND ffac_doc = 587967 AND sfac_doc = 'EAB'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')

SELECT  COUNT(unique fec_mcxc)
FROM	mov_cxc
WHERE	ffac_mcxc = 689596 AND sfac_mcxc = 'EAB' AND cia_mcxc = '15' AND pla_mcxc = '02'
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99')

select	*
from	contrare
where	fol_ctra = 656566 AND ser_ctra = 'EAB'

select	tpm_mcxc, count(*)
from	mov_cxc
group by 1
order by 1

select *
from	mov_cxc
where	tpm_mcxc in('00')

select	fec_mcxc, sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc BETWEEN '2022-08-01' and '2022-08-11' and sta_mcxc = 'A'
		AND tpm_mcxc < '50'
group by fec_mcxc
order by fec_mcxc

select	fec_mcxc, sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc BETWEEN '2022-08-01' and '2022-08-11' and sta_mcxc = 'A'
		AND tpm_mcxc > '49'
group by fec_mcxc
order by fec_mcxc

select	fec_mcxc, sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc BETWEEN '2022-10-01' and '2022-10-10' and sta_mcxc = 'A' tpa_mcxc in('C')
        AND tpm_mcxc < '50'
group by fec_mcxc
order by fec_mcxc

select	cia_doc, pla_doc, fol_doc, ser_doc, vuelta_doc, count(*)
from	doctos
where	(tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')
group by 1,2,3,4,5
having count(*) > 1

select	*
from	doctos where tip_doc = '03' and femi_doc >= '2022-01-01'
where	fol_doc = 622382 and pla_doc = '15'