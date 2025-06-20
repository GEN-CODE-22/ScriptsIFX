DROP PROCEDURE cxc_transfersaldo;
EXECUTE PROCEDURE  cxc_transfersaldo('15','16',695,'08','AN',0,'15','16',253444,3,-29,'fuente');
EXECUTE PROCEDURE  cxc_transfersaldo(383996,'15','16','01','52','fuente',3,2,'');

CREATE PROCEDURE cxc_transfersaldo
(	
	paramCia		CHAR(2),
	paramPla		CHAR(2),
	paramFolDoc   	INT,
	paramTipo		CHAR(2),
	paramSerDoc		CHAR(4),
	paramVuelta		SMALLINT,
	paramCiad		CHAR(2),
	paramPlad		CHAR(2),
	paramFolDocd   	INT,
	paramVueltad	SMALLINT,
	paramImp		DECIMAL,
	paramFpago		CHAR(2),
	paramUsr		CHAR(8)
)

RETURNING  
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100),	-- Mensaje
 DECIMAL;   -- Importe cancelado

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
DEFINE vsaldod 	DECIMAL;
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
DEFINE vdesc 	CHAR(20);

LET vproceso = 1;
LET vmsg = 'PROCESO CORRECTO';
LET vsaldo = 0;
LET vimppag = 0;

IF	paramImp >= 0 THEN
	LET vproceso = 0;
	LET vmsg = 'EL IMPORTE A TRANSFERIR DEBE SER NEGATIVO';
	RETURN 	vproceso,vmsg,0.00;
END IF;

IF NOT EXISTS(SELECT 	1 
		  	FROM 	doctos
		  	WHERE 	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla 
		  			AND tip_doc = paramTipo AND ser_doc = paramSerDoc)  AND NOT EXISTS(SELECT 	1 
														FROM 	doctos
														WHERE 	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla 
																AND vuelta_doc = paramVuelta )THEN	
	LET vproceso = 0;
	LET vmsg = 'NO EXISTE EL DOCUMENTO DE ORIGEN.';
	RETURN 	vproceso,vmsg,0.00;
END IF;

IF NOT EXISTS(SELECT 	1 
			FROM 	doctos
			WHERE 	fol_doc = paramFolDocd AND cia_doc = paramCiad AND pla_doc = paramPlad
					AND vuelta_doc = paramVueltad )THEN		
	LET vproceso = 0;
	LET vmsg = 'NO EXISTE EL DOCUMENTO DE DESTINO.';
	RETURN 	vproceso,vmsg,0.00;
END IF;

-- TRANSFERIR ANTICIPO------------------------------------------------------------------------------------
-- SE CANCELA EL IMPORTE DEL ANTICIPO Y SE APLICA EL PAGO AL DOCUMENTO DESTINO
IF	paramTipo = '08' THEN
	SELECT	sal_doc
	INTO	vsaldo
	FROM	doctos
	WHERE	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla
		  	AND tip_doc = paramTipo AND ser_doc = paramSerDoc;
	
	SELECT	sal_doc
	INTO	vsaldod
	FROM	doctos
	WHERE	fol_doc = paramFolDocd AND cia_doc = paramCiad AND pla_doc = paramPlad
		  	AND vuelta_doc = paramVueltad;
			
	IF	vsaldo >= 0 THEN
		LET vproceso = 0;
		LET vmsg = 'SALDO DOCUMENTO ORIGEN DEBE SER NEGATIVO';
		RETURN 	vproceso,vmsg,0.00;
	END IF;
	
	IF	vsaldo > paramImp THEN
		LET vproceso = 0;
		LET vmsg = 'IMPORTE A TRANFERIR ES MAYOR AL SALDO DEL DOCUMENTO ORIGEN';
		RETURN 	vproceso,vmsg,0.00;
	END IF;
	
	LET vimppag = paramImp * -1;		
	IF	vsaldod < vimppag THEN
		LET vproceso = 0;
		LET vmsg = 'IMPORTE A TRANFERIR ES MAYOR AL SALDO DEL DOCUMENTO ORIGEN O DESTINO';
		RETURN 	vproceso,vmsg,0.00;
	END IF;
	
	-- CANCELAR IMPORTE
	SELECT  cte_doc, tip_doc, fol_doc, ffis_doc, ser_doc, cia_doc, pla_doc, ffac_doc, sfac_doc, sta_doc, tpa_doc, uso_doc,
			sal_doc, fven_doc,vuelta_doc, fult_doc, car_doc, abo_doc
	INTO	vctedoc, vtip, vfoldoc, vffis, vserie, vcia, vpla, vffac, vsfac, vsta, vtpa, vuso, vsaldo, vfechav, vvuelta,
			vfechaub, vcargo, vabono
	FROM	doctos
	WHERE	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla 
			AND tip_doc = paramTipo  AND ser_doc = paramSerDoc AND sal_doc < 0.00;
			
	IF vfoldoc > 0 THEN
		SELECT	MAX(num_mcxc)
		INTO	vnummov
		FROM	mov_cxc
		WHERE	doc_mcxc = vfoldoc AND cia_mcxc = vcia AND pla_mcxc = vpla 
					AND tip_mcxc = vtip  AND ser_mcxc = vserie AND cte_mcxc = vctedoc;
		LET vnummov = vnummov + 1;			
		LET vdesc = 'PASA A ' || paramFolDocd;
		--INSERTA EN LA TABLA mov_cxc---------------------------------------------------------------
		INSERT INTO mov_cxc
		VALUES(vctedoc,'99',vtip,vfoldoc,vffis,vserie,vcia,vpla,vffac,vsfac,vnummov,vsta,vtpa,vuso,paramImp,TODAY,TODAY,vfechav, vdesc,paramUsr,NULL,vvuelta);
		
		--ACTUALIZA SALDOS DE DOCUMENTO--------------------------------------------------------------
		LET vabono = vabono - vimppag;
		LET vsaldo = vabono * -1;
		IF	TODAY  > vfechaub THEN
			LET vfechaub = TODAY;
		END IF;
		UPDATE	doctos
		SET		abo_doc = vabono,
				sal_doc = vsaldo,
				fult_doc = vfechaub
		WHERE	fol_doc = vfoldoc AND ser_doc = vserie AND cia_doc = vcia AND pla_doc = vpla 
				AND tip_doc = vtip AND cte_doc = vctedoc;
				
		--ACTUALIZA SALDOS DEL CLIENTE-----------------------------------------------------------------
		SELECT	saldo_cte, abono_cte, cargo_cte, fecuab_cte
		INTO	vctesal, vcteabo, vctecar, vctefecu
		FROM	cliente
		WHERE	num_cte = vctedoc;
		
		LET vcteabo = vcteabo - vimppag;
		LET vctesal = vctecar - vcteabo;
		IF vctefecu IS NULL THEN
			LET vctefecu = TODAY;
		ELSE
			IF vctefecu < TODAY THEN
				LET vctefecu = TODAY;
			END IF;
		END IF;
		
		UPDATE	cliente
		SET		saldo_cte = vctesal,
				abono_cte = vcteabo,
				fecuab_cte= vctefecu
		WHERE	num_cte = vctedoc;
	END IF;
END IF;

-- TRANSFERIR SALDO------------------------------------------------------------------------------------
-- SE CANCELA EL IMPORTE DEL DOCUMENTO ORIGEN Y SE APLICA EL PAGO AL DOCUMENTO DESTINO
IF	paramVuelta > 0 THEN
	SELECT	sal_doc
	INTO	vsaldo
	FROM	doctos
	WHERE	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla
		  	AND vuelta_doc = paramVuelta;
	
	SELECT	sal_doc
	INTO	vsaldod
	FROM	doctos
	WHERE	fol_doc = paramFolDocd AND cia_doc = paramCiad AND pla_doc = paramPlad
		  	AND vuelta_doc = paramVueltad;
			
	IF	vsaldo >= 0 THEN
		LET vproceso = 0;
		LET vmsg = 'SALDO DOCUMENTO ORIGEN DEBE SER NEGATIVO';
		RETURN 	vproceso,vmsg,0.00;
	END IF;
	
	IF	vsaldo > paramImp THEN
		LET vproceso = 0;
		LET vmsg = 'IMPORTE A TRANFERIR ES MAYOR AL SALDO DEL DOCUMENTO ORIGEN';
		RETURN 	vproceso,vmsg,0.00;
	END IF;
	
	LET vimppag = paramImp * -1;		
	IF	vsaldod < vimppag THEN
		LET vproceso = 0;
		LET vmsg = 'IMPORTE A TRANFERIR ES MAYOR AL SALDO DEL DOCUMENTO ORIGEN O DESTINO';
		RETURN 	vproceso,vmsg,0.00;
	END IF;

	-- CANCELAR IMPORTE
	SELECT  cte_doc, tip_doc, fol_doc, ffis_doc, ser_doc, cia_doc, pla_doc, ffac_doc, sfac_doc, sta_doc, tpa_doc, uso_doc,
			sal_doc, fven_doc,vuelta_doc, fult_doc, car_doc, abo_doc
	INTO	vctedoc, vtip, vfoldoc, vffis, vserie, vcia, vpla, vffac, vsfac, vsta, vtpa, vuso, vsaldo, vfechav, vvuelta,
			vfechaub, vcargo, vabono
	FROM	doctos
	WHERE	fol_doc = paramFolDoc AND cia_doc = paramCia AND pla_doc = paramPla 
			AND vuelta_doc = paramVuelta AND sal_doc < 0.00;
			
	IF vfoldoc > 0 THEN
		SELECT	MAX(num_mcxc)
		INTO	vnummov
		FROM	mov_cxc
		WHERE	doc_mcxc = vfoldoc AND cia_mcxc = vcia AND pla_mcxc = vpla 
					AND vuelta_mcxc = vvuelta AND cte_mcxc = vctedoc;
		
		LET vnummov = vnummov + 1;			
		LET vdesc = 'PASA A ' || paramFolDocd;
		--INSERTA EN LA TABLA mov_cxc---------------------------------------------------------------
		INSERT INTO mov_cxc
		VALUES(vctedoc,'99',vtip,vfoldoc,vffis,vserie,vcia,vpla,vffac,vsfac,vnummov,vsta,vtpa,vuso,paramImp,TODAY,TODAY,vfechav, vdesc,paramUsr,NULL,vvuelta);
		
		--ACTUALIZA SALDOS DE DOCUMENTO--------------------------------------------------------------
		LET vabono = vabono - vimppag;
		LET vsaldo = vcargo - vabono;
		IF	TODAY  > vfechaub THEN
			LET vfechaub = TODAY;
		END IF;
		UPDATE	doctos
		SET		abo_doc = vabono,
				sal_doc = vsaldo,
				fult_doc = vfechaub
		WHERE	fol_doc = vfoldoc AND ser_doc = vserie AND cia_doc = vcia AND pla_doc = vpla 
				AND tip_doc = vtip AND cte_doc = vctedoc;
				
		--ACTUALIZA SALDOS DEL CLIENTE-----------------------------------------------------------------
		SELECT	saldo_cte, abono_cte, cargo_cte, fecuab_cte
		INTO	vctesal, vcteabo, vctecar, vctefecu
		FROM	cliente
		WHERE	num_cte = vctedoc;
		
		LET vcteabo = vcteabo - vimppag;
		LET vctesal = vctecar - vcteabo;
		IF vctefecu IS NULL THEN
			LET vctefecu = TODAY;
		ELSE
			IF vctefecu < TODAY THEN
				LET vctefecu = TODAY;
			END IF;
		END IF;
		
		UPDATE	cliente
		SET		saldo_cte = vctesal,
				abono_cte = vcteabo,
				fecuab_cte= vctefecu
		WHERE	num_cte = vctedoc;
	END IF;
END IF;

IF vproceso = 1 THEN
	-- PAGAR IMPORTE
	SELECT  cte_doc, tip_doc, fol_doc, ffis_doc, ser_doc, cia_doc, pla_doc, ffac_doc, sfac_doc, sta_doc, tpa_doc, uso_doc,
			sal_doc, fven_doc,vuelta_doc, fult_doc, car_doc, abo_doc
	INTO	vctedoc, vtip, vfoldoc, vffis, vserie, vcia, vpla, vffac, vsfac, vsta, vtpa, vuso, vsaldo, vfechav, vvuelta,
			vfechaub, vcargo, vabono
	FROM	doctos
	WHERE	fol_doc = paramFolDocd AND cia_doc = paramCiad AND pla_doc = paramPlad
			AND vuelta_doc = paramVueltad AND sal_doc > 0.00;
	IF vfoldoc > 0 THEN
		SELECT	MAX(num_mcxc)
		INTO	vnummov
		FROM	mov_cxc
		WHERE	doc_mcxc = vfoldoc AND cia_mcxc = vcia AND pla_mcxc = vpla 
					AND vuelta_mcxc = vvuelta AND cte_mcxc = vctedoc;
		--INSERTA EN LA TABLA mov_cxc---------------------------------------------------------------
		LET vnummov = vnummov + 1;
		LET vdesc = 'VIENE DE ' || paramFolDoc || ' ' || NVL(paramSerDoc,'');
		INSERT INTO mov_cxc
		VALUES(vctedoc,paramFpago,vtip,vfoldoc,vffis,vserie,vcia,vpla,vffac,vsfac,vnummov,vsta,vtpa,vuso,vimppag,TODAY,TODAY,vfechav, vdesc,paramUsr,NULL,vvuelta);
		
		--ACTUALIZA SALDOS DE DOCUMENTO--------------------------------------------------------------
		LET vabono = vabono + vimppag;
		LET vsaldo = vcargo - vabono;
		IF	TODAY  > vfechaub THEN
			LET vfechaub = TODAY;
		END IF;
		UPDATE	doctos
		SET		abo_doc = vabono,
				sal_doc = vsaldo,
				fult_doc = vfechaub
		WHERE	fol_doc = vfoldoc AND cia_doc = vcia AND pla_doc = vpla 
				AND vuelta_doc = vvuelta AND cte_doc = vctedoc;
				
		--ACTUALIZA SALDOS DEL CLIENTE-----------------------------------------------------------------
		SELECT	saldo_cte, abono_cte, cargo_cte, fecuab_cte
		INTO	vctesal, vcteabo, vctecar, vctefecu
		FROM	cliente
		WHERE	num_cte = vctedoc;
		
		LET vcteabo = vcteabo + vimppag;
		LET vctesal = vctecar - vcteabo;
		IF vctefecu IS NULL THEN
			LET vctefecu = TODAY;
		ELSE
			IF vctefecu < TODAY THEN
				LET vctefecu = TODAY;
			END IF;
		END IF;
		
		UPDATE	cliente
		SET		saldo_cte = vctesal,
				abono_cte = vcteabo,
				fecuab_cte= vctefecu
		WHERE	num_cte = vctedoc;	

	END IF;
END IF;

RETURN 	vproceso,vmsg,vimppag;
END PROCEDURE; 

select	*
from	doctos
where	tip_doc = '08' and sal_doc <> 0

select	*
from	doctos
where	sal_doc < 0 and tip_doc = '01'

select	*
from	doctos
where	ffac_doc = 78009 and sfac_doc = 'EAPG'

update  doctos
set		abo_doc = 0, sal_doc = 1999.41
where	ffac_doc = 216406 and sfac_doc = 'EAO' and fol_doc = 255075

select	rowid,*
from	mov_cxc
where	ffac_mcxc = 78009 and sfac_mcxc = 'EAPG' and doc_mcxc = 664211 order by num_mcxc

update  mov_cxc
set		tpm_mcxc = '50'
where	ffac_mcxc = 216406 and sfac_mcxc = 'EAO' and imp_mcxc = 2

select	*
from	doctos
where	fol_doc = 695 and tip_doc = '08'

select	*
from	doctos
where	pla_doc = '09' and fol_doc = 303299 and ffac_doc = '116137' and sfac_doc = 'AP'

update  doctos
set		abo_doc = 173.10, sal_doc = 0
where	pla_doc = '09' and fol_doc = 303299 and ffac_doc = '116137' and sfac_doc = 'AP'

select	rowid,*
from	mov_cxc
where	doc_mcxc = 695 and cte_mcxc = '011516'

select	rowid,*
from	mov_cxc
where	pla_mcxc = '09' and doc_mcxc = 303299 and ffac_mcxc = '116137' and sfac_mcxc = 'AP'

delete
from	mov_cxc
where	rowid = 34073352

select	cargo_cte, abono_cte, saldo_cte, *
from	cliente
where	num_cte = '011516'

update 	cliente
set		abono_cte = 25437.78, saldo_cte = -199.51
where	num_cte = '022181'

select	cargo_cte, abono_cte, saldo_cte, *
from	cliente
where	num_cte = '035834'

update 	cliente
set		abono_cte = 1368101.95, saldo_cte = 4998.98
where	num_cte = '000006'

SELECT	sal_doc
FROM	doctos
WHERE	fol_doc = 695 AND cia_doc = '15' AND pla_doc = '16'
		  	AND tip_doc = '08';
	
SELECT	sal_doc
FROM	doctos
WHERE	fol_doc = 255075 AND cia_doc = '15' AND pla_doc = '16'
	  	AND vuelta_doc = 3;