DROP PROCEDURE LiqCob_UndoCerrar;
EXECUTE PROCEDURE  LiqCob_UndoCerrar(72663,'2023-08-02','fuente'); 	

CREATE PROCEDURE LiqCob_UndoCerrar
(
	paramFliq	INT,
	paramFecha  DATE,
	paramUsr	CHAR(8)
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
DEFINE vcte		CHAR(6);
DEFINE vfolio	INT;
DEFINE vcia		CHAR(2);
DEFINE vpla		CHAR(2);
DEFINE vser		CHAR(4);
DEFINE vnum		SMALLINT;
DEFINE vvuelta	SMALLINT;
DEFINE vfoldoc  INT;
DEFINE vmonto   DECIMAL;
DEFINE vtpm     CHAR(2);
DEFINE vtipo    CHAR(2);
DEFINE vtotliq  DECIMAL;


LET vresult = 1;
LET vmensaje = '';
LET vtotal = 0;
LET vproceso = 1;
LET vmsg = '';
LET vmonto = 0;


IF NOT EXISTS(SELECT 	1 
				FROM 	e_posaj 
				WHERE 	epo_fec = paramFecha) THEN
	FOREACH cMov FOR
		SELECT	cte_mcxc, tpm_mcxc, tip_mcxc, doc_mcxc, cia_mcxc, pla_mcxc, NVL(ser_mcxc,''), num_mcxc, NVL(vuelta_mcxc, 0)
		INTO	vcte,vtpm,vtipo,vfoldoc,vcia,vpla,vser,vnum,vvuelta
		FROM	mov_cxc 
		WHERE	fec_mcxc >= paramFecha AND fliq_mcxc = paramFliq AND sta_mcxc = 'A'
		
		IF vproceso = 1 THEN
			LET vproceso,vmsg,vmonto = cxc_cancelapagdoc(vfoldoc,vcia,vpla,vtipo,vtpm,paramUsr,vvuelta,vnum,vser);
			IF vproceso = 1 THEN
				LET vtotal = vtotal + vmonto;
			END IF;
		END IF;
	END FOREACH;	
	
	SELECT	NVL(impt_lcob,0)
	INTO	vtotliq
	FROM	liq_cob
	WHERE	fec_lcob = paramFecha AND fliq_lcob = paramFliq;
	
	IF vtotliq = vtotal	THEN
		UPDATE	liq_cob
		SET		edo_lcob = 'P'
		WHERE	fec_lcob = paramFecha AND fliq_lcob = paramFliq;
		
		LET vresult = 1;
		LET vmensaje = 'LIQUIDACIÓN ABIERTA.';	
		RETURN 	vresult,vmensaje,vtotal;
	ELSE
		LET vresult = 0;
		LET vmensaje = 'NO SE PUDO ABRIR LA LIQUIDACIÓN. NO SE CANCELARON TODOS LOS PAGOS. ' + vmsg;	
		RETURN 	vresult,vmensaje,vtotal;
	END IF;	
ELSE
	LET vresult = 0;
	LET vmensaje = 'NO SE PUEDE REALIZAR EL PROCESO, EL DIA YA ESTA CERRADO.';	
	RETURN 	vresult,vmensaje,vtotal;
END IF;

END PROCEDURE; 

SELECT	cte_mcxc, tpm_mcxc, tip_mcxc, doc_mcxc, cia_mcxc, pla_mcxc, NVL(ser_mcxc,''), num_mcxc, NVL(vuelta_mcxc, 0)
FROM	mov_cxc 
WHERE	fec_mcxc = '2023-11-29' AND fliq_mcxc = 73244 AND sta_mcxc = 'A'
		
select *
from   liq_cob
order by fliq_lcob desc

select  *
from 	liq_cob
where 	fliq_lcob = 72663

update 	liq_cob
set 	caj_lcob = null
where 	fliq_lcob = 72663

select  *
from 	det_lcob
where 	fliq_dlcob = 72663

select 	*
from 	mov_cxc 
where 	fliq_mcxc = '72663'

select  *
from 	det_lcob
where 	fom_dlcob = 'D' and edo_dlcob not in('P','R')
order by fec_dlcob desc

