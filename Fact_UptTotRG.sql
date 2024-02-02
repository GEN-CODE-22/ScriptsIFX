DROP PROCEDURE fact_upttotrg;
EXECUTE PROCEDURE fact_upttotrg('2024-12-02');

CREATE PROCEDURE fact_upttotrg
(	
	paramFecha	DATE
)
RETURNING 
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100);	-- Mensaje

DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(100);
DEFINE vtfact 	DECIMAL;

LET vproceso = 1;
LET vmsg = 'OK';

IF EXISTS(SELECT 1 FROM e_posaj WHERE epo_fec = paramFecha ) THEN		
	SELECT 	NVL(SUM(impt_fac),0.00)
    INTO 	vtfact
   	FROM 	factura
   	WHERE	fec_fac = paramFecha
     		AND impr_fac = 'E'
     		AND tdoc_fac = 'I'
     		AND faccer_fac = 'N'
    		AND (feccan_fac is null OR feccan_fac <> fec_fac)
     		AND (frf_fac IS NULL OR frf_fac = 0);
     
    UPDATE	e_posaj
	SET		epo_fact = vtfact
	WHERE	epo_fec = paramFecha;
ELSE
	LET vproceso = 0;
	LET vmsg = 'NO SE HA CERRADO EL REPORTE GERENCIAL';
END IF;

RETURN 	vproceso,vmsg;
END PROCEDURE;

select	epo_impv, epo_asistencia, epo_asistenciaa, epo_fact,*
from	e_posaj
where 	epo_fec = '2022-12-02'

SELECT 	NVL(SUM(impt_fac),0.00)
FROM 	factura
WHERE	fec_fac = '2022-12-02'
		AND impr_fac = 'E'
		AND tdoc_fac = 'I'
		AND faccer_fac = 'N'
	AND (feccan_fac is null OR feccan_fac <> fec_fac)
		AND (frf_fac IS NULL OR frf_fac = 0);

update	e_posaj
set		epo_fact = 24920.63 --epo_fact = 1207721.51--epo_fact = 260489.06-- epo_impv = 911081.00, epo_impva = 911081.00,epo_vcre = 213953.90 epo_vcrea = 213953.90--epo_fact = 418173.97
where	epo_fec = '2022-12-02'		
		