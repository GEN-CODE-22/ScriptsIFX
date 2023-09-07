/* *****************************************************************************************************************************************
Gas Express Nieto© 2013      
Sistema:                  Pagos
Caso de Uso:              Inserta Pagos
Nombre:                   Ins_TmpTrf
Descripción:              Inserta un registro en la tabla tmp_trf
                           

*******************************************************************************************************************************************
                                                      Historial de cambios  
*******************************************************************************************************************************************
                                     NOMBRE                       FECHA                             ACCIONES
                          Daniel Vanegas Sánchez              19/Novimenbre/2015             	Creación del procedimiento
						dvanegas@gasexpressnieto.com.mx										
******************************************************************************************************************************************/
DROP PROCEDURE Ins_TmpTrf;
CREATE PROCEDURE Ins_TmpTrf
(
	paramCta 	CHAR(10),
	paramFec 	CHAR(8),
	paramHora	CHAR(6),
	paramImp 	DECIMAL,
	paramCte 	CHAR(6),
	paramRem	CHAR(6)
)


INSERT INTO	tmp_trf(cta_trf,fec_trf,hor_trf,imp_trf,cte_trf,rem_trf)
VALUES(paramCta,paramFec,paramHora,paramImp,paramCte,paramRem);


END PROCEDURE;

EXECUTE PROCEDURE Ins_TmpTrf();

select	*
from	tmp_trf

select	count(*)
from	tmp_trf

select	*
from	nota_vta
where	edo_nvta is null
                                                                