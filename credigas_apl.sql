DROP PROCEDURE credigas_apl;
EXECUTE PROCEDURE credigas_apl('edith');

CREATE PROCEDURE credigas_apl
(
	paramUsr		CHAR(8)
)
RETURNING  
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100),	-- Mensaje
 DECIMAL;   -- importe pagado

DEFINE vproceso	INT;
DEFINE vmensaje	CHAR(100);
DEFINE vimptot  DECIMAL;
DEFINE vnocta 	CHAR(10);
DEFINE vfecha 	CHAR(8);
DEFINE vhora 	CHAR(6);
DEFINE vimporte DECIMAL;
DEFINE vnocte 	CHAR(6);
DEFINE vrem		CHAR(6);
DEFINE vsaldo 	DECIMAL;
DEFINE vctedoc 	CHAR(6);
DEFINE vtip 	CHAR(2);
DEFINE vfoldoc	INT;
DEFINE vffis 	INT;
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
DEFINE vsuc 	CHAR(5);
DEFINE vfi3 	CHAR(28);
DEFINE vfi4 	CHAR(1);
DEFINE vfi5 	CHAR(3);
DEFINE vfi6 	CHAR(15);
DEFINE vyear 	CHAR(4);
DEFINE vmes 	CHAR(2);
DEFINE vdia 	CHAR(2);
DEFINE vdate 	CHAR(10);

LET vimporte = 0;
LET vproceso = 1;
LET vmensaje = '';
LET vimptot = 0;
LET vimppag = 0;

IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = TODAY) THEN
	FOREACH cTransferencias FOR
		SELECT	cta_trf, fec_trf, hor_trf, suc_trf, imp_trf, fi3_trf, cte_trf, rem_trf, fi4_trf, fi5_trf, fi6_trf
		INTO	vnocta, vfecha, vhora, vsuc, vimporte, vfi3, vnocte, vrem, vfi4, vfi5, vfi6
		FROM 	tmp_trf
		
		LET vsaldo = 0;
		IF EXISTS(SELECT 	1 
			  	FROM 	doctos 
			  	WHERE 	fol_doc = vrem AND cte_doc = vnocte AND tpa_doc = 'G' AND sta_doc = 'A'
			  			AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0.0) THEN
			SELECT	sal_doc, vuelta_doc
			INTO	vsaldo, vvuelta
			FROM	doctos
			WHERE	fol_doc = vrem AND cte_doc = vnocte AND tpa_doc = 'G' AND sta_doc = 'A'
					AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0.0;
			IF vsaldo > 0 THEN
				SELECT  cte_doc, tip_doc, fol_doc, ffis_doc, ser_doc, cia_doc, pla_doc, ffac_doc, sfac_doc, sta_doc, tpa_doc, uso_doc,
						sal_doc, fven_doc,vuelta_doc, fult_doc, car_doc, abo_doc
				INTO	vctedoc, vtip, vfoldoc, vffis, vserie, vcia, vpla, vffac, vsfac, vsta, vtpa, vuso, vsaldo, vfechav, vvuelta,
						vfechaub, vcargo, vabono
				FROM	doctos
				WHERE	fol_doc = vrem AND vuelta_doc = vvuelta AND tpa_doc = 'G' AND sta_doc = 'A' AND sal_doc > 0.0;
				LET vsalini = vsaldo;
				SELECT	MAX(num_mcxc)
				INTO	vnummov
				FROM	mov_cxc
				WHERE	doc_mcxc = vfoldoc AND cia_mcxc = vcia AND pla_mcxc = vpla AND tpa_mcxc = 'G'
						AND vuelta_mcxc = vvuelta AND cte_mcxc = vctedoc;
				LET vnummov = vnummov + 1;	
				LET vimppag = vimporte;
				--INSERTA EN LA TABLA mov_cxc---------------------------------------------------------------
				INSERT INTO mov_cxc
				VALUES(vctedoc,'58',vtip,vfoldoc,vffis,vserie,vcia,vpla,vffac,vsfac,vnummov,vsta,vtpa,vuso,vimppag,TODAY,TODAY,vfechav,'APLICADO POR SISTEMA',paramUsr,NULL,vvuelta);
				--ACTUALIZA SALDOS DE DOCUMENTO--------------------------------------------------------------
				LET vabono = vabono + vimppag;
				LET vsaldo = vcargo - vabono;

				UPDATE	doctos
				SET		abo_doc = vabono,
						sal_doc = vsaldo,
						fult_doc = TODAY
				WHERE	fol_doc = vfoldoc AND cia_doc = vcia AND pla_doc = vpla 
						AND vuelta_doc = vvuelta AND cte_doc = vctedoc AND tpa_doc = 'G' AND sta_doc = 'A';
				--ACTUALIZA SALDOS DEL CLIENTE-----------------------------------------------------------------
				SELECT	saldo_cte, abono_cte, cargo_cte, fecuab_cte
				INTO	vctesal, vcteabo, vctecar, vctefecu
				FROM	cliente
				WHERE	num_cte = vctedoc;
				
				LET vcteabo = vcteabo + vimppag;
				LET vctesal = vctecar - vcteabo;
								
				UPDATE	cliente
				SET		saldo_cte = vctesal,
						abono_cte = vcteabo,
						fecuab_cte= TODAY
				WHERE	num_cte = vctedoc;
				
				--INSERTA EN LA TABLA cob_trf---------------------------------------------------------------
				LET vyear = SUBSTR(vfecha, 5,4);
				LET vmes = SUBSTR(vfecha, 3,2);
				LET vdia = SUBSTR(vfecha, 1,2);
				LET vdate =  vyear || '-' || vmes || '-' || vdia;
				INSERT INTO cob_trf
				VALUES(vnocta,vdate,vhora,vsuc,TODAY,vcia,vpla,'1',vimporte,vfi3,vnocte,vrem,vfi4,vfi5,vfi6);
				
				LET vimptot = vimptot + vimppag;
			END IF;
		END IF;
	END FOREACH; 
ELSE
	LET vproceso = 0;
	LET vmensaje = 'NO SE PUEDEN APLICAR LOS PAGOS, EL DIA YA ESTA CERRADO.';	
END IF;
RETURN 	vproceso,vmensaje,vimptot;
END PROCEDURE;

select	*
from	tmp_trf

select	* 
from	cob_trf
where	fer_trf = '2022-11-11'
order by fec_trf desc

delete
from	cob_trf
where	fer_trf = '2022-11-11'

select	sta_trf, count(*) 
from	cob_trf
group by 1

SELECT 	*
FROM 	doctos 
WHERE 	fol_doc = 421690 AND cte_doc = '006028' AND tpa_doc = 'G' AND sta_doc = 'A'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')

SELECT 	*
FROM 	doctos 
WHERE 	tpa_doc = 'G' AND sta_doc = 'A' AND ((car_doc = 764.47 AND sal_doc > 0) OR sal_doc = 764.47) 
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')
		
SELECT 	*
FROM 	doctos 
WHERE 	tpa_doc = 'G' AND sta_doc = 'A' AND car_doc = 764.47  OR sal_doc = 764.47

SELECT 	*
FROM 	doctos 
WHERE 	tpa_doc = 'G' AND sta_doc = 'A' AND car_doc = 764.47 and femi_doc >= '2022-09-03' and femi_doc <= '2022-11-03'

select	*
from	doctos
where   fol_doc in(72056,72057,72058,72059,72060,72061,72062,72063,72067,72068) and pla_doc = '85'

update  doctos
set		sal_doc = car_doc, fult_doc = femi_doc, abo_doc = 0.00
where   fol_doc in(72056,72057,72058,72059,72060,72061,72062,72063,72067,72068) and pla_doc = '85'

select	*
from	mov_cxc 
where	doc_mcxc in (72056,72057,72058,72059,72060,72061,72062,72063,72067,72068) and pla_mcxc = '85'
		and pla_mcxc = '85' --and tip_mcxc = '01' and tpa_mcxc = 'G' and cte_mcxc = '010991'
				
delete  
from	mov_cxc
where	doc_mcxc in (72056,72057,72058,72059,72060,72061,72062,72063,72067,72068) and pla_mcxc = '85'
		and tpm_mcxc = '58'