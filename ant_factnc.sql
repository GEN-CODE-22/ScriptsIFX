DROP PROCEDURE ant_factnc;
EXECUTE PROCEDURE  ant_factnc(60398,188076,'EAP','fuente');

CREATE PROCEDURE ant_factnc
(
	paramFolliq		INT,
	paramFecha		DATE,
	paramFolAnt		INT,
	paramSerAnt		CHAR(4),
	paramUsr		CHAR(8)
)

RETURNING  
 INT, 		-- Resultado 1 = OK  0 = Error
 CHAR(100); -- Mensaje error
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(100);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vpcre	CHAR(40);
DEFINE vuuid	CHAR(40);
DEFINE vnumcte 	CHAR(6);
DEFINE vpagcte 	CHAR(1);
DEFINE vrfccte 	CHAR(13);
DEFINE vfolio	INT;
DEFINE vvuelta 	INT;
DEFINE vimpl	DECIMAL;
DEFINE vtotnc	DECIMAL;
DEFINE vtltsnc	DECIMAL;
DEFINE vnum 	INT;
DEFINE vfolfac	INT;
DEFINE vserfac	CHAR(4);
DEFINE vfolnc	INT;
DEFINE vfolant	INT;
DEFINE vserant	CHAR(4);
DEFINE vsernc	CHAR(4);
DEFINE vtpa 	CHAR(1);
DEFINE vtip 	CHAR(1);
DEFINE vtprd 	CHAR(3);
DEFINE vpru 	DECIMAL;
DEFINE vtlts 	DECIMAL;
DEFINE vffis	DECIMAL;
DEFINE vruta	CHAR(4);
DEFINE vimpt 	DECIMAL;
DEFINE vsimpt 	DECIMAL;
DEFINE viva 	DECIMAL;
DEFINE vivap 	DECIMAL;
DEFINE vasist 	DECIMAL;
DEFINE vtotasis	DECIMAL;
DEFINE vtotimpt DECIMAL;
DEFINE vtotsimp DECIMAL;
DEFINE vtotiva  DECIMAL;
DEFINE vfecha 	DATE;
DEFINE vrelnvta CHAR(1);
DEFINE vfechah 	CHAR(19);

LET vresult = 1;
LET vmensaje = 'OK';
LET vtotimpt = 0;
LET vsimpt = 0;
LET vtotsimp = 0;
LET viva = 0;
LET vivap = 0;
LET vtotiva = 0;
LET vasist = 0;
LET vtotasis = 0;
LET vimpt = 0;
LET vtltsnc = 0;
LET vtotnc = 0;

IF NOT EXISTS(SELECT 	1 
		  	FROM 	liq_cob 
		  	WHERE 	fliq_lcob = paramFolliq AND tip_lcob = 'A')  THEN	
	LET vresult = 0;
	LET vmensaje = 'NO EXISTE LA LIQUIDACION DE ANTICIPO';
	RETURN 	vresult,vmensaje;
END IF;

IF EXISTS(SELECT 	1 
		  	FROM 	doctos, det_lcob
		  	WHERE 	cia_doc = cia_dlcob AND pla_doc = pla_dlcob AND fol_doc = fol_dlcob 
		  			AND vuelta_doc = vuelta_dlcob AND ffac_doc IS NOT NULL AND fliq_dlcob = paramFolliq)  THEN	
	LET vresult = 0;
	LET vmensaje = 'EXISTEN DOCUMENTOS YA FACTURADOS';
	RETURN 	vresult,vmensaje;
END IF;

LET vnum = 0;

FOREACH cDetalle FOR
	SELECT	cia_dlcob, pla_dlcob, fol_dlcob, vuelta_dlcob, sum(imp_dlcob)
	INTO	vcia, vpla, vfolio, vvuelta, vimpl
	FROM	det_lcob
	WHERE	fliq_dlcob = paramFolliq
	GROUP BY 1,2,3,4
	
	LET vtotnc = vtotnc + vimpl;
	IF vnum = 0 THEN
		SELECT	serfce_pla				
		INTO	vserfac
		FROM	planta
		WHERE	cia_pla = vcia AND cve_pla = vpla;
		LET vfolfac = GETVAL_EX_MODE(vcia,vpla,null,'folfce_pla');
		IF vfolfac <= 0 THEN
			LET vresult = 0;
			LET vmensaje = 'NO SE PUDO OBTENER EL FOLIO PARA LA FACTURA DE APLICACION DE ANTICIPO.';	
			RETURN vresult,vmensaje;
		END IF;
	END IF;	
	
	SELECT	n.cia_nvta, n.pla_nvta, n.fol_nvta, n.vuelta_nvta, n.ruta_nvta, n.fes_nvta, n.impt_nvta, n.simp_nvta, n.iva_nvta, 
			n.ivap_nvta, NVL(n.impasi_nvta, 0), n.tip_nvta, n.tprd_nvta, n.pru_nvta, n.tlts_nvta, n.ffis_nvta, n.numcte_nvta	
	INTO	vcia,vpla,vfolio,vvuelta,vruta,vfecha,vimpt,vsimpt,viva,vivap,vasist,vtip,vtprd,vpru,vtlts,vffis,vnumcte
	FROM 	nota_vta n
	WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
	
	LET vtltsnc = vtltsnc + vtlts;
	LET vtotasis = vtotasis + vasist;
	LET vtotimpt = vtotimpt + vimpt;
	LET vtotsimp = vtotsimp + vsimpt;
	LET vtotiva = vtotiva + viva;
	IF vasist > 0 THEN
		LET vtotiva = vtotiva + (vasist * (vivap / 100) / (1 + (vivap / 100)));
		LET vtotsimp = vtotsimp + (vasist / (1 + (vivap / 100)));
		LET vtotimpt = vtotimpt + vasist;
	END IF;	
					
	LET vnum = vnum + 1;
	LET vpcre = fact_getpcre(vcia,vpla,vfolio,vruta,vfecha);
	INSERT INTO det_fac 
	VALUES(vfolfac,vserfac,vcia,vpla,vnum,vtip,vfolio,vffis,vtlts,vtprd,vpru,null,vsimpt,vasist,vvuelta,vpcre);	
END FOREACH;
LET vtotasis = 0;
FOREACH cDetalleAsistencia FOR
	SELECT	NVL(impasi_dfac, 0)
	INTO	vasist
	FROM 	det_fac 
	WHERE	fol_dfac = vfolfac AND ser_dfac = vserfac
		
	LET vtotasis = vtotasis + vasist;			
	LET vtotiva = vtotiva + (vasist * (vivap / 100) / (1 + (vivap / 100)));
	LET vtotsimp = vtotsimp + (vasist / (1 + (vivap / 100)));
	LET vtotimpt = vtotimpt + vasist;					
END FOREACH; 
SELECT	pago_cte, rfc_cte	
INTO	vpagcte,vrfccte
FROM	cliente
WHERE	num_cte = vnumcte;

LET vfechah = YEAR(paramFecha) || '-' || LPAD(MONTH(paramFecha),2,'0') || '-' || LPAD(DAY(paramFecha),2,'0') || ' 07:59:59';
INSERT INTO factura
VALUES('M',vfolfac,vserfac,vcia,vpla,paramFecha,vnumcte,'E','P','E', vtotsimp, vtotiva, vtotimpt, null, paramUsr,null,null,null,null,null,null,'N','N',vfechah,'N',null,null,null,'N','4','I',null,vrfccte,vpagcte,paramFolAnt,paramSerAnt,null,null,null);

LET vrelnvta = fact_setnotarel(vfolfac,vserfac,'I');
IF vrelnvta <> 'A' THEN
	LET vresult = 0;
	LET vmensaje = 'ERROR AL RELACIONAR NOTAS, FACTURA: ' || vfolfac || ' SERIE: ' || vserfac;
	RETURN vresult,vmensaje;
END IF;
				
FOREACH cFacturaAnt FOR
	SELECT  fr_rcfd, sr_rcfd
	INTO	vfolant,vserant
	FROM	relacion_cfd
	WHERE	fol_rcfd = paramFolliq AND ser_rcfd = 'ANT'
	
	SELECT	uuid_fac
	INTO	vuuid
	FROM	factura
	WHERE	fol_fac = vfolant AND ser_fac = vserant;
	
	UPDATE	relacion_cfd
	SET		fol_rcfd = vfolfac, ser_rcfd = vserfac, uuid_rcfd = vuuid
	WHERE	fol_rcfd = paramFolliq AND ser_rcfd = 'ANT' AND fr_rcfd = vfolant AND sr_rcfd = vserant;
END FOREACH;

SELECT	sernce_pla				
INTO	vsernc
FROM	planta
WHERE	cia_pla = vcia AND cve_pla = vpla;
LET vfolnc = GETVAL_EX_MODE(vcia,vpla,null,'folnce_pla');
IF vfolnc <= 0 THEN
	LET vresult = 0;
	LET vmensaje = 'NO SE PUDO OBTENER EL FOLIO PARA LA NOTA DE CREDITO DE APLICACION DE ANTICIPO.';	
	RETURN vresult,vmensaje;
END IF;

LET vtotsimp = vtotnc  / (1 + (vivap / 100));
LET vtotiva = vtotsimp * (vivap / 100);
INSERT INTO nota_crd
VALUES(vfolnc,vsernc,vcia,vpla,paramFecha,'N','N',vnumcte,'E','X','E',null,null,null,vtotsimp,vtotiva,vtotnc,paramUsr,null,null,vfechah, null,null,null,'N','4','A',null,vrfccte,vpagcte);

INSERT INTO det_ncrd
VALUES(vfolnc,vsernc,vcia,vpla,1,vfolfac,vserfac,'L', vtltsnc,vtotsimp);

UPDATE  factura
SET		fnc2_fac = vfolnc, snc2_fac = vsernc
WHERE	fol_fac = vfolfac AND ser_fac = vserfac;

LET vmensaje = 'SE GENERO FACTURA: ' || vfolfac || ' ' || vserfac || ' Y NOTA DE CREDITO: ' || vfolnc || ' ' || vsernc;
LET vmensaje = TRIM(vmensaje);
RETURN 	vresult,vmensaje;
END PROCEDURE; 

select	cia_dlcob, pla_dlcob, fol_dlcob, vuelta_dlcob, sum(imp_dlcob)
from	det_lcob
where	fliq_dlcob = 58672
group by 1,2,3,4

select	*
from	det_lcob
where	fliq_dlcob = 58672

update	det_lcob
set		vuelta_dlcob = 3
where	fliq_dlcob = 58672

SELECT 	1
FROM 	doctos, det_lcob
WHERE 	cia_doc = cia_dlcob AND pla_doc = pla_dlcob AND fol_doc = fol_dlcob 
		AND vuelta_doc = vuelta_dlcob AND ffac_doc IS NOT NULL AND fliq_dlcob = 58672
		
select	*
from	nota_vta
where	fol_nvta in(316950,316951,318102,318106,318103,318105,319351,319352,320372,320374,320377,318619,321552,321553,323860)

update	nota_vta
set		fac_nvta = null, ser_nvta = null
where	fol_nvta in(316950,316951,318102,318106,318103,318105,319351,319352,320372,320374,320377,318619,321552,321553,323860)

select	*
from	doctos
where	fol_doc in(316950,316951,318102,318106,318103,318105,319351,319352,320372,320374,320377,318619,321552,321553,323860)
		and tip_doc = '01'
		
update	doctos
set		ffac_doc = null, sfac_doc = null
where	fol_doc in(316950,316951,318102,318106,318103,318105,319351,319352,320372,320374,320377,318619,321552,321553,323860)
		and tip_doc = '01'
		
select	*
from	factura
where	fol_fac in(192840,202231) and ser_fac = 'EAP'

update	factura
set		uuid_fac = 'D6F3CC61-4DBE-4A0B-8C47-D05E3E4216EC'
where	fol_fac in(25614) and ser_fac = 'EAPH'

delete
from	factura
where	fol_fac in(202232) and ser_fac = 'EAP'
		
select	*
from	det_fac
where	fol_dfac in(192840,202231) and ser_dfac = 'EAP'

delete	
from	det_fac
where	fol_dfac in(202232) and ser_dfac = 'EAP'

select	*
from	nota_crd 
where	fol_ncrd in(12742,13514) and ser_ncrd = 'NAP'

delete
from	nota_crd 
where	fol_ncrd in(13515) and ser_ncrd = 'NAP'

select	*
from	det_ncrd 
where	fol_dncrd in(12742,13514) and ser_dncrd = 'NAP'

delete
from	det_ncrd
where	fol_dncrd in(13515) and ser_dncrd = 'NAP'

select	*
from	cfd
where   fol_cfd in(13514) and ser_cfd = 'NAP'

update	cfd
set		est_cfd = 'I'
where   fol_cfd in(25614) and ser_cfd = 'EAPH'

