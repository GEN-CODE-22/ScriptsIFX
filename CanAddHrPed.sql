CREATE PROCEDURE CanAddHrPed
(
	paramFec	DATE,
	paramHr		SMALLINT,
	paramCia	CHAR(2),
	paramPla	CHAR(2),	
	paramRu 	CHAR(4)
)
RETURNING INTEGER;

DEFINE vcaninsert 		INTEGER;
DEFINE vpedidos			INTEGER;
DEFINE vhrped_cfg 		CHAR(1);
DEFINE vhrpedlim_cfg 	CHAR(2);

LET vcaninsert = 0;

SELECT	value_cfg
INTO	vhrped_cfg
FROM	cfg_llam
WHERE	key_cfg = 'HRPED_CFG';

IF vhrped_cfg  = '1' THEN
	SELECT	value_cfg
	INTO	vhrpedlim_cfg
	FROM	cfg_llam
	WHERE	key_cfg = 'HRPEDLIM_CFG';
	
	SELECT	COUNT(*)
	INTO	vpedidos
	FROM	hr_ped
	WHERE	fec_hped		= paramFec
			AND hr_hped 	= paramHr
			AND cia_hped	= paramCia
			AND pla_hped	= paramPla
			AND ruta_hped	= paramRu;
			
	IF vpedidos >= vhrpedlim_cfg  THEN
		LET vcaninsert = vpedidos;
	END IF;
END IF;

RETURN vcaninsert;

END PROCEDURE;