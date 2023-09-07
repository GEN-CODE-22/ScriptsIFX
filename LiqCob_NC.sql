DROP PROCEDURE LiqCob_NC;
EXECUTE PROCEDURE  LiqCob_NC(0,'2022-04-25','0029 ','fuente');

CREATE PROCEDURE LiqCob_NC
(
	paramFolliq		INT,
	paramFecha   	DATE,
	paramEmp		CHAR(5),
	paramUsr		CHAR(8)
)

RETURNING  
 INT, 		-- Resultado 1 = OK  0 = Error
 INT, 		-- Folio liquidacion de cobranza generada
 CHAR(500), -- Mensaje error
 DECIMAL;	-- Total aplicado
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(500);
DEFINE vmsg		CHAR(100);
DEFINE vproceso  INT;
DEFINE vfolliq 	INT;
DEFINE vimptot  DECIMAL;
DEFINE vnum 	INT;
DEFINE vfolio 	INT;
DEFINE vserie 	CHAR(4);
DEFINE vffac 	INT;
DEFINE vsfac 	CHAR(4);
DEFINE vsalfac  DECIMAL;
DEFINE vimptfac DECIMAL;
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vpru		DECIMAL;
DEFINE vtlts	DECIMAL;
DEFINE vimpt 	DECIMAL;
DEFINE vimpliq  DECIMAL;
DEFINE vdesc 	CHAR(50);
DEFINE vimp 	DECIMAL;
DEFINE vimppag  DECIMAL;
DEFINE vimppnc  DECIMAL;

LET vresult = 1;
LET vproceso = 1;
LET vfolliq = 0;
LET vmensaje = '';
LET vimptot = 0;
LET vimpliq = 0;
LET vimppnc = 0;
LET vnum = 1;

IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = paramFecha) THEN	

	IF paramFolliq = 0 THEN
		SELECT	SUM(impt_ncrd)
		INTO	vimpliq
		FROM	nota_crd 
		WHERE	fec_ncrd = paramFecha and tpa_ncrd IN ('C','G') and edo_ncrd <> 'C' 
				and tdoc_ncrd = 'E' and napl_ncrd = 'N' and impt_ncrd is not null and impt_ncrd > 0;
		
		IF vimpliq > 0 THEN
			LET vfolliq = GETVAL_EX_MODE(null,null,null,'numlcob_dat');
			IF vfolliq > 0 THEN				
				INSERT INTO liq_cob
				VALUES(vfolliq, paramEmp, paramFecha, 'C', 0.00, 0.00, 0.00, 0.00, 0.00, paramUsr, null, 0, 0, null, CURRENT, 'N');
				
				FOREACH cNotasCredito FOR
					SELECT	fol_ncrd, ser_ncrd, cia_ncrd, pla_ncrd, impt_ncrd, pru_ncrd
					INTO	vfolio, vserie, vcia, vpla, vimpt, vpru
					FROM	nota_crd 
					WHERE	fec_ncrd = paramFecha and tpa_ncrd IN ('C','G') and edo_ncrd <> 'C' 
							and tdoc_ncrd = 'E' and napl_ncrd = 'N' and impt_ncrd is not null and impt_ncrd > 0
						
					IF vresult = 1 THEN	
						LET vimptfac = 0;	
						FOREACH cFacturas FOR
							SELECT	fac_dncrd, serf_dncrd
							INTO	vffac, vsfac
							FROM	det_ncrd
							WHERE	fol_dncrd = vfolio and ser_dncrd = vserie
							
							SELECT  SUM(sal_doc) 
							INTO	vsalfac
							FROM 	doctos 
							WHERE   cia_doc = vcia AND pla_doc = vpla AND sta_doc = 'A' AND ffac_doc = vffac AND sfac_doc = vsfac
									AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');
							LET vimptfac = vimptfac + vsalfac;									
						END FOREACH;
						IF vimptfac >= vimpt THEN
							LET vdesc = 'NC' || LPAD(vfolio,6,'0');
							INSERT INTO det_lcob
							VALUES(vfolliq, vnum, 'N', '52', vfolio, null, vserie, vcia, vpla, 'N', vimpt, paramFecha, null, null, null, null, null, vdesc , null, null, 0, 0, null, paramFecha, null);
							LET vnum = vnum + 1;	
							LET vimppnc = 0;
							FOREACH cFacturasNC FOR
								SELECT	fac_dncrd, serf_dncrd, tlts_dncrd
								INTO	vffac, vsfac, vtlts
								FROM	det_ncrd
								WHERE	fol_dncrd = vfolio and ser_dncrd = vserie
								LET vimp = ROUND(vtlts * vpru,2);
								LET vresult,vmsg,vimppag = LiqCob_PagoFac(vfolliq,vffac,vsfac,vcia,vpla,'52',vimp,paramFecha,vdesc,vnum,paramUsr);
								LET vimptot = vimptot + vimppag;
								LET vimppnc = vimppnc + vimppag;
								IF vresult = 0 THEN
									LET vresult = 0;
									LET vmensaje = 'ERROR AL PROCESAR LINEA: ' || vnum || ' ' || vmsg;				
								END IF;
							END FOREACH;
								
						ELSE
							LET vresult = 0;
							LET vmensaje = 'SALDO DE LA FACTURA: ' || vffac || vsfac || ' ES MENOR AL IMPORTE DE LA NOTA DE CREDITO: ' || vfolio || vserie;
						END IF;		
						-- SI SE PAGO EL IMPORTE DE LA NOTA DE CREDITO SE ACTUALIZA TABLA nota_crd-----------------------------
						IF vimpt = vimppnc THEN
							UPDATE	nota_crd
							SET		apl_ncrd = 'S', napl_ncrd = 'S'
							WHERE	fol_ncrd = vfolio AND ser_ncrd = vserie;
						END IF;
					END IF;				
				END FOREACH;
				UPDATE  liq_cob
				SET		impc_lcob = vimptot, impt_lcob = vimptot
				WHERE	fliq_lcob = vfolliq;
			ELSE
				LET vresult = 0;
				LET vmensaje = 'ERROR AL OBTENER EL FOLIO DE LA LIQUIDACION';
			END IF;
		ELSE
			LET vresult = 0;
			LET vmensaje = 'NO SE ENCONTRARON NOTAS DE CREDITO EN LA FECHA SELECCIONADA';
		END IF;
	ELSE
		LET vfolliq = paramFolliq;
	END IF;
ELSE
	LET vresult = 0;
	LET vmensaje = 'NO SE PUEDE APLICAR EL ANTICIPO, EL DIA YA ESTA CERRADO.';
END IF;

RETURN 	vresult,vfolliq,vmensaje,vimptot;
END PROCEDURE; 

SELECT	fol_ncrd, ser_ncrd, cia_ncrd, pla_ncrd, impt_ncrd
FROM	nota_crd 
WHERE	fec_ncrd = '2022-07-22' and tpa_ncrd IN ('C','G') and edo_ncrd <> 'C' 
		and tdoc_ncrd = 'E' and napl_ncrd = 'S' and impt_ncrd is not null and impt_ncrd > 0
		
SELECT	fac_dncrd, serf_dncrd
FROM	det_ncrd
WHERE	fol_dncrd = 16415 and ser_dncrd = 'NAI'

SELECT  SUM(sal_doc) 
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '08' AND sta_doc = 'A' AND ffac_doc = 435254 AND sfac_doc = 'EAI'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');
select	*
from	nota_crd
where	fec_ncrd >= '2019-11-08' and tpa_ncrd = 'C' and tdoc_ncrd = 'E'

update	nota_crd
set		fec_ncrd = '2022-04-25', apl_ncrd = 'N', napl_ncrd = 'N'
where	fol_ncrd = 13491 and ser_ncrd = 'NAP'

select	*
from	nota_crd
where	fol_ncrd in (13491) and ser_ncrd = 'NAP'

select	*
from	det_ncrd
where	fol_dncrd in (13491) and ser_dncrd = 'NAP'

SELECT  SUM(sal_doc) 
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '09' AND sta_doc = 'A' AND ffac_doc = 205673 AND sfac_doc = 'EAP'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');

select	*
from	det_fac
where	fol_dfac = 200601 and ser_dfac = 'EAP'

select	rowid,*
from	mov_cxc 
where 	fliq_mcxc = 44110

select	*
from	liq_cob 
where   fec_lcob >= '2022-08-01' and tip_lcob = 'N' order by fec_lcob desc

-- SAN JOSE ITURBIDE 12490
-- MOPRELIA 52286
select	*
from	liq_cob
where	fliq_lcob IN(43766,43947)  

delete
from	liq_cob
where	fliq_lcob IN(60521)  

select	*
from	det_lcob 
where	fliq_dlcob IN(44171)  


select	*
from	det_lcob 
where	tip_dlcob = '52' and fec_dlcob between '2022-05-01' and '2022-05-31'

delete
from	det_lcob 
where	fliq_dlcob IN(60521)     

SELECT  *
FROM 	doctos where fol_doc in(565784) and cte_doc = '163142' 

update	doctos
set		abo_doc = 460.02, sal_doc = 12934.68
where 	fol_doc in(565784) and cte_doc = '163142'

select	*
from	mov_cxc
where 	doc_mcxc in(565784) and cte_mcxc = '163142'

delete
from    mov_cxc
where 	doc_mcxc in(565784) and cte_mcxc = '163142' and num_mcxc >= 3

select	*
from	mov_cxc
where 	desc_mcxc like '%VIENE%' and fec_mcxc >= '2021-05-01'

select  * 
from	doctos d
where 	d.pla_doc = '08' and d.tip_doc = '01'
		and d.fol_doc in(select fol_doc from doctos where pla_doc = '08' and tip_doc = '18' and abo_doc = d.abo_doc)
		
		