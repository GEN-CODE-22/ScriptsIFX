CREATE PROCEDURE QryHisOr
(	
	paramCia	CHAR(2),
	paramPla    CHAR(2),
	paramFechaI	CHAR(16),
	paramFechaF CHAR(16),
	paramRut	CHAR(4),
	paramEdo	CHAR(1),
	paramFormat CHAR(17)
)

	RETURNING 
		CHAR(12),				
		CHAR(4),					
		CHAR(7),					
		DATETIME YEAR TO MINUTE,	
		CHAR(25),					
		CHAR(30),				
		CHAR(6),				
		CHAR(50),				
		CHAR(80),				
		INT,						
		CHAR(6),					
		CHAR(6),					
		CHAR(17),				
		CHAR(34);					


	DEFINE	fol		CHAR(12);
	DEFINE	rut		CHAR(4);
	DEFINE	eco		CHAR(7);
	DEFINE  fec  	DATETIME YEAR TO MINUTE;
	DEFINE	edo		CHAR(25);
	DEFINE	obs		CHAR(30);
	DEFINE	cte		CHAR(6);
	DEFINE	nom		CHAR(50);
	DEFINE	dir		CHAR(80);
	DEFINE	nmo		INT;
	DEFINE	prc		CHAR(6);
	DEFINE	fre		CHAR(6);
	DEFINE	fat		CHAR(17);
	DEFINE	ubi		CHAR(34);
	


	FOREACH cCursorDef FOR

		SELECT		fol_henr,
					rut_henr,
					eco_henr,
					fec_henr,
					CASE 
						WHEN edo_henr = '0' THEN
							'LISTO A ENVIAR'
						WHEN edo_henr = 'C' THEN
							'CANCELADO'
						WHEN edo_henr = 'E' THEN
							'ERROR'
						WHEN edo_henr = 'F' THEN
							'FINALIZADO'
						WHEN edo_henr = 'N' THEN
							'FINALIZADO EN CALLE'
						WHEN edo_henr = 'O' THEN
							'REPROGRAMADO POR OPERADOR'
						WHEN edo_henr = 'P' THEN
							'PENDIENTE'
						WHEN edo_henr = 'f' THEN
							'LIQUIDADA'
						WHEN edo_henr = 'x' THEN
							'POR TRANSMITIR'
						ELSE
							'N/A'
					END AS edo_henr,
					obs_henr,
					cte_henr,
					nom_henr,
					dir_henr,
					nmo_henr,
					prc_henr,
					fre_henr,
					fat_henr,
					ubi_henr
		INTO		fol,
					rut,
					eco,
					fec,
					edo,
					obs,
					cte,
					nom,
					dir,
					nmo,
					prc,
					fre,
					fat,
					ubi		
		FROM		hismov_enr
		WHERE		fec_henr >= TO_DATE(paramFechaI, paramFormat)
		AND			fec_henr <= TO_DATE(paramFechaF, paramFormat)
		AND			(rut_henr = paramRut
		OR			 paramRut = '')		
		ORDER BY 	fol_henr, eco_henr, fec_henr
		RETURN 		fol,
					rut,
					eco,
					fec,
					edo,
					obs,
					cte,
					nom,
					dir,
					nmo,
					prc,
					fre,
					fat,
					ubi
		WITH RESUME;

	END FOREACH; 

END PROCEDURE;