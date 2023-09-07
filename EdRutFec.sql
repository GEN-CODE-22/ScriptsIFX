DROP PROCEDURE EdRutFec;
EXECUTE PROCEDURE EdRutFec('15', '02', 'M038', '2022-10-17', '1502208729  ', 'fuente')
CREATE PROCEDURE EdRutFec
(
	paramCia		CHAR(2),	
	paramPla		CHAR(2),
	paramRoute		CHAR(4),    	
	paramFecha		DATE,    	
	paramFolio		CHAR(12),	
	paramUsr		CHAR(8)		
)

	
	RETURNING	
		SMALLINT;		

	
	DEFINE edited   SMALLINT;
	DEFINE nvta		INT;		
	DEFINE ped 		INT; 		
	DEFINE edo		CHAR(1);	
	DEFINE vedoreg	CHAR(1);	
	DEFINE vprod	CHAR(3);	
	DEFINE vpru		DECIMAL;	
	DEFINE vreg		SMALLINT;	
	DEFINE vrut		CHAR(4);
	DEFINE unid		CHAR(7);	
	DEFINE vvuelta  SMALLINT;
	DEFINE vpla		CHAR(2);
	
	SELECT  NVL(vuelta_enr,0)
	INTO	vvuelta
	FROM	enruta
	WHERE   fol_enr = paramFolio;
	
	IF	vvuelta = 0 THEN
		SELECT	NVL(vuelta_pla,0)
		INTO	vvuelta
		FROM	planta
		WHERE	cia_pla = paramCia
				AND cve_pla = paramPla;
	END IF;
	
	SELECT	pla_rut
	INTO	vpla
	FROM	ruta
	WHERE	cve_rut = paramRoute;
		
	SELECT	fol_nvta,
			ped_nvta,
			edo_nvta,
			ruta_nvta,
			vuelta_nvta
	INTO	nvta,
			ped,
			edo,
			vrut,
			vvuelta
	FROM	nota_vta
	WHERE	cia_nvta = paramCia
	AND		pla_nvta = paramPla
	AND		fol_nvta = (paramFolio[5, 10] * 1)
	AND 	vuelta_nvta = vvuelta;
	
	SELECT	unid_rneco
	INTO	unid
	FROM	ri505_neco
	WHERE	ruta_rneco = paramRoute;
	
	IF unid is null THEN
		LET unid = "N/A";
	END IF;	

	SELECT	edoreg_enr
	INTO	vedoreg
	FROM	enruta
	WHERE	fol_enr = paramFolio;
	
	IF edo = 'P' AND vedoreg = 'O' AND paramRoute[1] = vrut[1] AND vpla = paramPla THEN		
		SELECT	NVL(tprd_nvta,''),
				ruta_nvta
		INTO	vprod,
				vrut
		FROM	nota_vta
		WHERE	fol_nvta = nvta
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla
		AND 	vuelta_nvta = vvuelta;
		
		IF LENGTH(vprod) = 0 THEN
			SELECT	reg_rut
			INTO	vreg
			FROM	ruta
			WHERE	cve_rut	= vrut;	
			
			SELECT	tpr_prc
			INTO	vprod
			FROM	precios
			WHERE	reg_prc = vreg
					AND tid_prc = 'E'  
					AND pri_prc = 'S';  
		END IF;
		
		SELECT	pru_mprc
		INTO	vpru
		FROM	mov_prc
		WHERE	tpr_mprc = vprod
				AND fei_mprc <= paramFecha
				AND fet_mprc >= paramFecha;
		
		UPDATE	pedidos
		SET     fecsur_ped = paramFecha,
				ruta_ped = paramRoute,
				usr_ped  = paramUsr,
				fhr_ped  = CURRENT,
				nmod_ped = NVL(nmod_ped,0) + 1,
				edotx_ped= 'N'
		WHERE	num_ped = ped;

		UPDATE 	nota_vta
		SET 	fes_nvta = paramFecha,
				ruta_nvta = paramRoute
		WHERE	fol_nvta = nvta
		AND		cia_nvta = paramCia
		AND		pla_nvta = paramPla
		AND 	vuelta_nvta = vvuelta;
		
		UPDATE	enruta
		SET     obser_enr = NULL			
		WHERE   fol_enr = paramFolio;	
		
		UPDATE	enruta
		SET     fecreg_enr = TO_CHAR(paramFecha, '%d%m%y'),
				ruta_enr = paramRoute,
				edoreg_enr = '0',
				eco_enr = unid,
				prc_enr = vpru || '',
				obser_enr = NULL,
				reccel_enr = 0			
		WHERE   fol_enr = paramFolio;		
		
		LET edited = 1;
	
	ELSE
	
		LET edited = 0;
		
	END IF
	
	RETURN edited;
	
END PROCEDURE; 

select	*
from	pedidos
where	num_ped = 12904908 

select	*
from	nota_vta
where	ped_nvta = 12904908 

select	*
from	nota_vta
where	fol_nvta = 209675

select	*
from	enruta
where	fol_enr = '1502209675'

update	enruta
set		edoreg_enr = 'O'
where	fol_enr = '1502209675'

SELECT  vuelta_enr
FROM	enruta
WHERE   fol_enr = '1502208729';

select	*
from	ruta
order by cve_rut