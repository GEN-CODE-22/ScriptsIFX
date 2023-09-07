DROP PROCEDURE QRY_DetLiqCob;
EXECUTE PROCEDURE  QRY_DetLiqCob(23625);

CREATE PROCEDURE QRY_DetLiqCob
(
	paramFolio   	INT
)

RETURNING  
 INT,
 SMALLINT,
 CHAR(1),
 CHAR(2),
 INT,
 DECIMAL,
 CHAR(4),
 CHAR(2),
 CHAR(2),
 CHAR(1),
 DECIMAL,
 DATE,
 CHAR(1),
 CHAR(3),
 CHAR(18),
 CHAR(3),
 CHAR(18),
 CHAR(50),
 DECIMAL,
 DECIMAL,
 SMALLINT,
 INT,
 CHAR(4),
 DATE,
 SMALLINT,
 CHAR(6),
 CHAR(80);

DEFINE vfolliq 	INT;
DEFINE vnum     SMALLINT;
DEFINE vfom     CHAR(1);
DEFINE vtip     CHAR(2);
DEFINE vfolio   INT;
DEFINE vffis    INT;
DEFINE vserie   CHAR(4);
DEFINE vcia     CHAR(2);
DEFINE vpla     CHAR(2);
DEFINE vedo     CHAR(1);
DEFINE vimp     DECIMAL;
DEFINE vfec 	DATE;
DEFINE vver     CHAR(1);
DEFINE vbori    CHAR(3);
DEFINE vcori    CHAR(18);
DEFINE vbdes    CHAR(3);
DEFINE vcdes    CHAR(18);
DEFINE vdes     CHAR(50);
DEFINE vsalini  DECIMAL;
DEFINE vsalfin  DECIMAL;
DEFINE vnumpag  SMALLINT;
DEFINE vfacpag  INT;
DEFINE vserpag  CHAR(4);
DEFINE vfecdep  DATE;
DEFINE vvuelta  SMALLINT;
DEFINE vnocte 	CHAR(6);
DEFINE vnomcte 	CHAR(80);
DEFINE vfecha 	DATE;


FOREACH cLiquidacion FOR
	SELECT	fliq_dlcob, num_dlcob, fom_dlcob, tip_dlcob, fol_dlcob, ffis_dlcob, ser_dlcob, cia_dlcob, pla_dlcob,
			edo_dlcob, imp_dlcob, fec_dlcob, ver_dlcob, bori_dlcob, cori_dlcob, bdes_dlcob, cdes_dlcob, des_dlcob,
			salini_dlcob, salfin_dlcob, numpag_dlcob, facpag_dlcob, serpag_dlcob, fecdep_dlcob, vuelta_dlcob
	INTO	vfolliq, vnum, vfom, vtip, vfolio, vffis, vserie, vcia, vpla, vedo, vimp, vfec, vver, vbori, vcori, 
			vbdes, vcdes, vdes, vsalini, vsalfin, vnumpag, vfacpag, vserpag, vfecdep, vvuelta
	FROM	det_lcob
	WHERE	fliq_dlcob = paramFolio
	
	LET vnocte = 'F';
	
	IF vfom = 'F' THEN
		SELECT	numcte_fac
		INTO	vnocte
		FROM	factura
		WHERE	cia_fac = vcia AND pla_fac = vpla AND fol_fac = vfolio AND ser_fac = vserie;
	END IF;
	
	IF vfom = 'D' OR vfom = 'A' THEN
		IF (vtip = '01' OR vtip >= '11' AND vtip <= '99') THEN
			SELECT	NVL(cte_doc,'')
			INTO	vnocte
			FROM	doctos
			WHERE	cia_doc = vcia AND pla_doc = vpla AND fol_doc = vfolio AND vuelta_doc = vvuelta;	
		END IF;	
		IF vtip = '03' THEN
			SELECT	NVL(cte_doc,'')
			INTO	vnocte
			FROM	doctos
			WHERE	cia_doc = vcia AND pla_doc = vpla AND fol_doc = vfolio AND ser_doc = vserie AND tip_doc = vtip;	
		END IF;	
	END IF;
	
	IF vfom = 'N' THEN
		SELECT	numcte_ncrd
		INTO	vnocte
		FROM	nota_crd
		WHERE	cia_ncrd = vcia AND pla_ncrd = vpla AND fol_ncrd = vfolio AND ser_ncrd = vserie;
	END IF;
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
	
	RETURN 	vfolliq, vnum, vfom, vtip, vfolio, vffis, vserie, vcia, vpla, vedo, vimp, vfec, vver, vbori, vcori, 
			vbdes, vcdes, vdes, vsalini, vsalfin, vnumpag, vfacpag, vserpag, vfecdep, vvuelta, vnocte, vnomcte
	WITH RESUME;
END FOREACH;
END PROCEDURE; 

SELECT	*
FROM	doctos
WHERE	cia_doc = '15' AND pla_doc = '84' AND fol_doc = 203131 AND vuelta_doc = 1;	

select	*
from	nota_vta
where	fol_nvta = 203131

select	*
from	hnota_vta
where	fol_nvta = 203131