DROP PROCEDURE cxc_cancelapagdoc;
EXECUTE PROCEDURE  cxc_cancelapagdoc(562394,'15','41','','50','fuente',1,3,'');
EXECUTE PROCEDURE  cxc_cancelapagdoc(2033,'15','09','03','58','fuente',0,2,'BNT');

CREATE PROCEDURE cxc_cancelapagdoc
(
	paramFolDoc   	INT,
	paramCia		CHAR(2),
	paramPla		CHAR(2),
	paramTipo		CHAR(2),
	paramTipmov		CHAR(2),
	paramUsr		CHAR(8),
	paramVuelta		SMALLINT,
	paramNummov		SMALLINT,
	paramSer		CHAR(4)
)

RETURNING  
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100),	-- Mensaje
 DECIMAL;   -- Importe cancelado

DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(100);
DEFINE vctedoc 	CHAR(6);
DEFINE vcargo 	DECIMAL;
DEFINE vabono 	DECIMAL;
DEFINE vsaldo 	DECIMAL;
DEFINE vctecar 	DECIMAL;
DEFINE vcteabo 	DECIMAL;
DEFINE vctesal 	DECIMAL;
DEFINE vfecha 	DATE;
DEFINE vfechae 	DATE;
DEFINE vfechaub	DATE;
DEFINE vctefecu	DATE;
DEFINE vimppag  DECIMAL;

LET vproceso = 1;
LET vmsg = 'PAGO CANCELADO CORRECTAMENTE';
LET vsaldo = 0;
LET vimppag = 0;

IF EXISTS(SELECT 	1 
		  	FROM 	mov_cxc 
		  	WHERE 	doc_mcxc = paramFolDoc AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
		  			AND (vuelta_mcxc = paramVuelta OR (tip_mcxc = paramTipo AND ser_mcxc = paramSer)) AND tpm_mcxc = paramTipmov
		  			AND num_mcxc = paramNummov AND sta_mcxc = 'A') AND paramTipmov > '49' THEN	
	
	IF paramVuelta > 0 THEN
		SELECT	NVL(fec_mcxc,null), NVL(imp_mcxc,0)
		INTO	vfecha, vimppag
		FROM 	mov_cxc
		WHERE	doc_mcxc = paramFolDoc AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
			  			AND vuelta_mcxc = paramVuelta AND tpm_mcxc = paramTipmov AND num_mcxc = paramNummov;
	ELSE
		SELECT	NVL(fec_mcxc,null), NVL(imp_mcxc,0)
		INTO	vfecha, vimppag
		FROM 	mov_cxc
		WHERE	doc_mcxc = paramFolDoc AND ser_mcxc = paramSer AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
			  			AND tip_mcxc = paramTipo AND tpm_mcxc = paramTipmov	AND num_mcxc = paramNummov;
	END IF;			
	
	IF vfecha IS NOT NULL AND vimppag > 0 THEN
		IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = vfecha) THEN
		  	--CANCELA EL PAGO----------------------------------------------------------------------------
		  	IF paramVuelta > 0 THEN
		  		UPDATE	mov_cxc
		  		SET		sta_mcxc = 'C', usr_mcxc = paramUsr
			  	WHERE	doc_mcxc = paramFolDoc AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
			  			AND vuelta_mcxc = paramVuelta AND tpm_mcxc = paramTipmov AND num_mcxc = paramNummov;
			  	SELECT	NVL(MAX(fec_mcxc),null)
				INTO	vfechaub
				FROM 	mov_cxc
				WHERE	doc_mcxc = paramFolDoc AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
					  			AND vuelta_mcxc = paramVuelta AND sta_mcxc = 'A' AND tpm_mcxc > '49';
			  	SELECT  cte_doc, femi_doc, car_doc, abo_doc
				INTO	vctedoc,vfechae,vcargo, vabono
				FROM	doctos
				WHERE	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla 
						AND vuelta_doc = paramVuelta;
		  	ELSE
		  		UPDATE	mov_cxc
		  		SET		sta_mcxc = 'C', usr_mcxc = paramUsr
			  	WHERE	doc_mcxc = paramFolDoc AND ser_mcxc = paramSer AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
			  			AND tip_mcxc = paramTipo AND tpm_mcxc = paramTipmov	AND num_mcxc = paramNummov;
			  	SELECT	NVL(MAX(fec_mcxc),null)
				INTO	vfechaub
				FROM 	mov_cxc
				WHERE	doc_mcxc = paramFolDoc AND ser_mcxc = paramSer AND cia_mcxc = paramCia AND pla_mcxc = paramPla 
			  			AND tip_mcxc = paramTipo AND sta_mcxc = 'A' AND tpm_mcxc > '49';
			  	SELECT  cte_doc, femi_doc, car_doc, abo_doc
				INTO	vctedoc, vfechae, vcargo, vabono
				FROM	doctos
				WHERE	fol_doc = paramFolDoc AND ser_doc = paramSer AND cia_doc = paramCia AND pla_doc = paramPla 
						AND tip_doc = paramTipo;
		  	END IF;
		  	
		  	--ACTUALIZA SALDOS DE DOCUMENTO--------------------------------------------------------------
			LET vabono = vabono - vimppag;
			LET vsaldo = vcargo - vabono;
			IF	vfechaub IS NULL THEN
				LET vfechaub = vfechae;
			END IF;
			IF paramVuelta > 0 THEN
				UPDATE	doctos
				SET		abo_doc = vabono,
						sal_doc = vsaldo,
						fult_doc = vfechaub
				WHERE	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla 
						AND vuelta_doc = paramVuelta AND cte_doc = vctedoc;
			ELSE
				UPDATE	doctos
				SET		abo_doc = vabono,
						sal_doc = vsaldo,
						fult_doc = vfechaub
				WHERE	fol_doc = paramFolDoc AND ser_doc = paramSer AND cia_doc = paramCia AND pla_doc = paramPla 
						AND tip_doc = paramTipo AND cte_doc = vctedoc;
			END IF;
			--ACTUALIZA SALDOS DEL CLIENTE-----------------------------------------------------------------
			SELECT	saldo_cte, abono_cte, cargo_cte, fecuab_cte
			INTO	vctesal, vcteabo, vctecar, vctefecu
			FROM	cliente
			WHERE	num_cte = vctedoc;
			
			SELECT	NVL(MAX(fec_mcxc),null)
			INTO	vfechaub
			FROM 	mov_cxc
			WHERE	cte_mcxc = vctedoc AND sta_mcxc = 'A' AND tpm_mcxc > '49';
			
			LET vcteabo = vcteabo - vimppag;
			LET vctesal = vctecar - vcteabo;
			IF vfechaub IS NULL THEN
				LET vctefecu = vfechae;			
			END IF;
			
			UPDATE	cliente
			SET		saldo_cte = vctesal,
					abono_cte = vcteabo,
					fecuab_cte= vctefecu
			WHERE	num_cte = vctedoc;
		 ELSE
		 	LET vproceso = 0;
			LET vmsg = 'NO SE PUEDE CANCELAR EL PAGO, EL DIA YA ESTA CERRADO.';	
		 END IF;
	ELSE
		LET vproceso = 0;
		LET vmsg = 'NO EXISTE UN PAGO CON LOS CRITERIOS DE BUSQUEDA, FAVOR DE REVISAR.';
	END IF;		
ELSE
	LET vproceso = 0;
	LET vmsg = 'NO EXISTE UN PAGO CON LOS CRITERIOS DE BUSQUEDA, FAVOR DE REVISAR.';
END IF;

RETURN 	vproceso,vmsg,vimppag;
END PROCEDURE; 
 
SELECT  cte_doc, tip_doc, fol_doc, ffis_doc, ser_doc, cia_doc, pla_doc, ffac_doc, sfac_doc, sta_doc, tpa_doc, uso_doc,
			sal_doc, fven_doc,vuelta_doc, fult_doc, car_doc, abo_doc
	FROM	doctos
	WHERE	fol_doc = 489540 AND cia_doc = '15' AND pla_doc = '03' AND vuelta_doc = 2
			(vuelta_doc = is null OR tip_doc = '03') AND sal_doc > 0.0;
	
select	*
from	doctos
where	fol_doc in(2033) and cte_doc = '047421'

select	*
from	mov_cxc
where	doc_mcxc in(562394) and pla_mcxc ='41' and cte_mcxc = '047421' and tpm_mcxc = '50'

update	mov_cxc
set		sta_mcxc = 'A'
where	doc_mcxc in(2033) and pla_mcxc ='09' and cte_mcxc = '061588' and tpm_mcxc = '58'

select	saldo_cte, abono_cte, cargo_cte, fecuab_cte, * 
from	cliente
where   num_cte = '034178'

update	cliente
set		cargo_cte = 710643488.30, saldo_cte = 12286837.68, abono_cte = 698356650.62--, abono_cte = 20116161.05--, fecuab_cte = '2022-09-20'
where   num_cte = '034178'

select	sum(abo_doc),sum(car_doc)
from	doctos
where	cte_doc in('034178') and sta_doc = 'A'

SELECT	NVL(MAX(fec_mcxc),null)
FROM 	mov_cxc
WHERE	cte_mcxc = '061588' AND sta_mcxc = 'A' AND tpm_mcxc > '49';

select	*
from	doctos
where	cte_doc in('047421') and sta_doc = 'A'

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

select	count(*)
from	doctos
where	tip_doc = '03' and vuelta_doc is null

update	doctos
set		vuelta_doc = -1
where	tip_doc = '03' and vuelta_doc is null

select	count(*)
from 	mov_cxc
where	vuelta_mcxc is null

update	mov_cxc
set		vuelta_mcxc = -1
where	tip_mcxc = '03' and vuelta_mcxc is null