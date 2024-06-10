DROP PROCEDURE RPT_factlista;
EXECUTE PROCEDURE  RPT_factlista('','','','2023-10-16','2023-10-18','S','N');
EXECUTE PROCEDURE  RPT_factlista('15','08','','2023-01-12','2023-01-12');

CREATE PROCEDURE RPT_factlista
(
	paramCia   	CHAR(2),
	paramPla	CHAR(18),
	paramCte	CHAR(6),
	paramFecI   DATE,
	paramFecF   DATE,
	paramTipo	CHAR(1),
	paramCierre CHAR(1)
)

RETURNING 
 CHAR(2), 	-- Cia
 CHAR(2), 	-- Planta
 INT,		-- Folio
 CHAR(4),	-- Serie
 DATE,		-- Fecha
 CHAR(6),	-- No cliente
 CHAR(80),	-- Cliente
 CHAR(13),	-- RFC
 CHAR(1),	-- Estado
 CHAR(20),	-- Tipo pago
 DECIMAL;	-- Importe
 --CHAR(3),	-- Metodo Pago
 --CHAR(1);	-- Forma pago
 
DEFINE vcia		CHAR(2);	
DEFINE vpla		CHAR(2);
DEFINE vfolio 	INT;
DEFINE vserie 	CHAR(4);
DEFINE vfecha 	DATE;
DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vrfc 	CHAR(13);
DEFINE vedo 	CHAR(1);
DEFINE vtpa		CHAR(20);
DEFINE vimpt  	DECIMAL;
DEFINE vtipo 	CHAR(4);
--DEFINE vmpa		CHAR(3);
--DEFINE vfpa		CHAR(1);
DEFINE vpla1 	CHAR(2);
DEFINE vpla2 	CHAR(2);
DEFINE vpla3 	CHAR(2);
DEFINE vpla4 	CHAR(2);
DEFINE vpla5 	CHAR(2);
DEFINE vpla6 	CHAR(2);
DEFINE vpla7 	CHAR(2);
DEFINE vpla8 	CHAR(2);
DEFINE vpla9 	CHAR(2);

LET vtipo = '[' || paramTipo || ']';

IF paramTipo = 'S'	THEN
	LET vtipo = '[SY]';
END IF;

LET vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9 = get_plantas(paramPla);

FOREACH cFacturas FOR
	SELECT	numcte_fac, cia_fac, pla_fac, fol_fac, ser_fac, fec_fac, edo_fac, rfc_fac, tpa_fac, impt_fac--,
			--CASE WHEN tpa_fac IN('C','G') THEN 'PPD' ELSE 'PUE' END,
			--pago_cte
	INTO	vnocte, vcia, vpla, vfolio, vserie, vfecha, vedo, vrfc, vtpa, vimpt--, vmpa, vfpa
	FROM	factura, cliente
	WHERE	numcte_fac = num_cte AND (cia_fac = paramCia OR paramCia = '')
			AND (pla_fac in(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
			AND (numcte_fac = paramCte OR paramCte = '')
			AND fec_fac BETWEEN paramFecI AND paramFecF
			AND tdoc_fac = 'I' AND impr_fac = 'E' 
			AND (faccer_fac = paramCierre OR paramCierre = '')
			AND (feccan_fac is null OR feccan_fac <> fec_fac) 
			AND (frf_fac is null OR frf_fac = 0)
			AND (tfac_fac MATCHES vtipo OR paramTipo = '')
	ORDER BY fec_fac,cia_fac,pla_fac,fol_fac
	LET vnomcte = '';
	IF vnocte <> '' THEN
		SELECT	NVL(CASE 
				WHEN TRIM(cliente.razsoc_cte) <> '' THEN
				   TRIM(cliente.razsoc_cte) 
				ELSE 
				   trim(cliente.nom_cte) || ' ' || TRIM(cliente.ape_cte) 
				END,'')
		INTO	vnomcte
		FROM	cliente
		WHERE	num_cte = vnocte;
	END IF;
	/*IF EXISTS(SELECT 1 FROM cte_pue WHERE numcte_cpue = vnocte) THEN
		LET vmpa = 'PUE';
	END IF;*/
	IF vtpa = 'E' THEN
		LET vtpa = 'EFECTIVO';
	ELSE
		IF vtpa = 'C' THEN
			LET vtpa = 'CREDITO';
		ELSE
			IF vtpa = 'X' THEN
				LET vtpa = 'EXTERNA';
			END IF;
		END IF; 
	END IF;	

	RETURN 	vcia,vpla,vfolio,vserie,vfecha,vnocte,vnomcte,vrfc,vedo,vtpa,vimpt--,vmpa,vfpa
	WITH RESUME;
END FOREACH;
END PROCEDURE; 

select	*
from	planta

select	pago_cte,*
from	cliente
where	num_cte = '091724'

select	*
from	cte_pue
insert into cte_pue values('009431');
delete from cte_pue where numcte_cpue = '009431'

select	*
from	factura
where	tfac_fac = 'S'

select	*
from	factura
where	fol_fac = 16196 and ser_fac = 'EAPD'

select	*
from	factura
where	tdoc_fac = 'I' and fec_fac = '2022-12-15' and tfac_fac = 'A'

select	tfac_fac,count(*)
from	factura
where	tdoc_fac = 'I' and fec_fac >= '2020-01-01'
group by tfac_fac

select	fec_fac, sum(impt_fac)
from	factura 
where   fec_fac >='2023-01-01' AND tdoc_fac = 'I' AND impr_fac = 'E' AND faccer_fac = 'N' AND (feccan_fac is null OR feccan_fac <> fec_fac) 
			AND (frf_fac is null OR frf_fac = 0)
group by 1

select	fec_fac, sum(impt_fac)
from	factura 
where   tdoc_fac = 'I' 
	AND impr_fac = 'E'
     AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0)
     and fec_fac >= '2023-01-01'
group by 1

select	f.fec_fac, sum(n.impt_nvta)
from	factura f, det_fac d, nota_vta n
where	f.fec_fac = '2023-01-10' and f.fol_fac = d.fol_dfac and f.ser_fac = d.ser_dfac
		and f.fol_fac = n.fol_nvta and f.ser_fac = n.ser_nvta		 
		and tdoc_fac = 'I' and tfac_fac IN('M','P','A') and (frf_fac is null OR frf_fac = 0)
group by 1

SELECT SUM(impt_fac)
   FROM factura
   WHERE fec_fac >= '2023-01-07' AND fec_fac <= '2023-01-07'
     AND impr_fac = 'E'
     AND tdoc_fac = 'I'
     AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0);
     
SELECT fec_fac, SUM(impasi_dfac)
   FROM factura,det_fac
   WHERE fec_fac >= '2023-01-07' AND fec_fac <= '2023-01-07'
     AND impr_fac = 'E'
     AND tdoc_fac = 'I'   
  	AND faccer_fac = 'N'
     AND (feccan_fac is null OR feccan_fac <> fec_fac)
     AND (frf_fac IS NULL OR frf_fac = 0)
     AND fol_fac = fol_dfac
     AND ser_fac = ser_dfac
     AND cia_fac = cia_dfac
     AND pla_fac = pla_dfac
GROUP BY 1;
