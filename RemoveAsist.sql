CREATE PROCEDURE RemoveAsist
(
	paramCia CHAR(2),
	paramPla CHAR(2),
	paramFolio INT,
	paramUsr CHAR(8)
)
RETURNING
		CHAR(1);

DEFINE vtpdo	CHAR(1);
DEFINE vfac		INT;

SELECT	tpdo_nvta, NVL(fac_nvta,0)
INTO	vtpdo, vfac
FROM	nota_vta
WHERE 	cia_nvta 		= paramCia
		AND	pla_nvta 	= paramPla
		AND fol_nvta	= paramFolio;
		
IF vtpdo <> 'A' AND vfac = 0 THEN
	UPDATE	nota_vta
	SET 	asiste_nvta		= 'N',
	     	impasi_nvta		= 0.00
	WHERE 	cia_nvta 		= paramCia
			AND	pla_nvta 	= paramPla
			AND fol_nvta	= paramFolio;
			
	EXECUTE PROCEDURE InsChangeLiq(paramCia,paramPla,paramFolio,paramUsr,'QUITO ASISTENCIA EN NOTA DE VENTA');
	RETURN	'A';

END IF;
RETURN	'B';
		
END PROCEDURE;

select	*
from	changes_liq
where	cambio_cliq like '%QUITO ASISTENCIA%' 
order by fecha_cliq desc