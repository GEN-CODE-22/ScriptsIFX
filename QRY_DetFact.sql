DROP PROCEDURE QRY_DetFact;
EXECUTE PROCEDURE  QRY_DetFact('15','09',241359,'EAP');

CREATE PROCEDURE QRY_DetFact
(
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramFolio  INT,
	paramSerie	CHAR(4)
)

RETURNING  
 CHAR(2),
 CHAR(2),
 INT,
 CHAR(4), 
 INT,
 CHAR(1),
 INT,
 DECIMAL,
 DECIMAL,
 CHAR(3),
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 SMALLINT,
 CHAR(40),
 DATE;

DEFINE vfolio 	INT;
DEFINE vserie   CHAR(4);
DEFINE vcia     CHAR(2);
DEFINE vpla     CHAR(2);
DEFINE vmov   	INT;
DEFINE vtipo    CHAR(1);
DEFINE vfnvta   INT;
DEFINE vffis    DECIMAL;
DEFINE vtlts    DECIMAL;
DEFINE vtprd    CHAR(3);
DEFINE vprecio  DECIMAL;
DEFINE vivap    DECIMAL;
DEFINE vsimp    DECIMAL;
DEFINE vimpasi  DECIMAL;
DEFINE vvuelta  SMALLINT;
DEFINE vpcre	CHAR(40);
DEFINE vfecha   DATE;

LET vfecha = null;

FOREACH cFactura FOR
	SELECT	cia_dfac, pla_dfac, fol_dfac, ser_dfac, mov_dfac, tid_dfac, fnvta_dfac, ffis_dfac, tlts_dfac, tpr_dfac,
			pru_dfac, ivap_dfac, simp_dfac, impasi_dfac, NVL(vuelta_dfac,0), pcre_dfac
	INTO	vcia,vpla,vfolio,vserie,vmov,vtipo,vfnvta,vffis,vtlts,vtprd,vprecio,vivap,vsimp,vimpasi,vvuelta,vpcre
	FROM	det_fac
	WHERE	fol_dfac = paramFolio AND ser_dfac = paramSerie --AND cia_dfac = paramCia AND pla_dfac = paramPla
	
	IF vfnvta IS NOT NULL THEN
		IF EXISTS(SELECT 	1 
		  	FROM 	nota_vta 
		  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta) THEN
				SELECT 	fes_nvta
				INTO	vfecha
				FROM	nota_vta
				WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta;
		
		ELSE
			IF EXISTS(SELECT 	1 
		  		FROM 	rdnota_vta 
			  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta) THEN
					SELECT 	fes_nvta
					INTO	vfecha
					FROM	rdnota_vta
					WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta;
			END IF;
		END IF;
	END IF;
	
	RETURN 	vcia,vpla,vfolio,vserie,vmov,vtipo,vfnvta,vffis,vtlts,vtprd,vprecio,vivap,vsimp,vimpasi,vvuelta,vpcre,vfecha
	WITH RESUME;
END FOREACH;
END PROCEDURE; 

select	*
from	factura
where	fol_fac = 190356 and ser_fac = 'EAP'

select	*
from	det_fac
where	fol_dfac = 190356 and ser_dfac = 'EAP'

SELECT  cia_dfac, pla_dfac, fol_dfac, ser_dfac, mov_dfac, tid_dfac, fnvta_dfac, ffis_dfac, tlts_dfac, tpr_dfac,
		pru_dfac, ivap_dfac, simp_dfac, impasi_dfac, NVL(vuelta_dfac,0), pcre_dfac
FROM	det_fac
WHERE	fol_dfac = 5000000 AND ser_dfac = 'EAB' --AND cia_dfac = paramCia AND pla_dfac = paramPla


select	*
from	rdnota_vta
where	fol_nvta = 309657