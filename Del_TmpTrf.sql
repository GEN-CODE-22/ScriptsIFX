/* *****************************************************************************************************************************************
Gas Express Nieto� 2013      
Sistema:                  Pagos
Caso de Uso:              Eliminas Pagos
Nombre:                   Del_TmpTrf
Descripci�n:              Elimina todos los registros de la tabla tmp_trf
                           

*******************************************************************************************************************************************
                                                      Historial de cambios  
*******************************************************************************************************************************************
                                     NOMBRE                       FECHA                             ACCIONES
                          Daniel Vanegas S�nchez              19/Novimenbre/2015             	Creaci�n del procedimiento
						dvanegas@gasexpressnieto.com.mx										
******************************************************************************************************************************************/
DROP PROCEDURE Del_TmpTrf;
CREATE PROCEDURE Del_TmpTrf
(
	
)


DELETE	
FROM 	tmp_trf;


END PROCEDURE;

EXECUTE PROCEDURE tmp_trf();

select	*
from	tmp_trf

select	count(*)
from	tmp_trf
                                                                