DROP PROCEDURE InsMovNvta;
CREATE PROCEDURE InsMovNvta(
	paramFolio	INTEGER,
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramLts	DECIMAL,
	paramImpo	DECIMAL,
	paramGolpe  INTEGER,
	paramHini	DATETIME HOUR TO MINUTE,
	paramHfin	DATETIME YEAR TO MINUTE,
	paramGPS	CHAR(30)
	)

	RETURNING
		CHAR(1);		
		
			
	DEFINE control	CHAR(1);			
	DEFINE move		INTEGER;			
	DEFINE vffis	DECIMAL;
	DEFINE vgps		CHAR(30);
	DEFINE vvuelta		INT;
	DEFINE vfolenr		CHAR(10);
	
	LET vvuelta = 0;
	LET vgps = '';	
	LET vfolenr = paramCia || paramPla || LPAD(paramFolio,6,'0');
	
	IF EXISTS(SELECT  1	FROM	enruta	WHERE   fol_enr = vfolenr) THEN
		SELECT  NVL(vuelta_enr,0)
		INTO	vvuelta
		FROM	enruta
		WHERE   fol_enr = vfolenr;
	END IF;
	
	IF	vvuelta = 0 THEN
		SELECT	NVL(vuelta_pla,0)
		INTO	vvuelta
		FROM	planta
		WHERE	cia_pla = paramCia
				AND cve_pla = paramPla;
	END IF;		

	SELECT	NVL(ffis_nvta,0)
	INTO	vffis
	FROM	nota_vta
	WHERE	fol_nvta = paramFolio
			AND		cia_nvta = paramCia
			AND		pla_nvta = paramPla
			AND 	vuelta_nvta = vvuelta;
			
	IF vffis > 0 THEN
		SELECT	NVL(ubicte_enr,'')
		INTO	vgps
		FROM 	enruta
		WHERE	fol_enr = vffis;
	ELSE
		SELECT	NVL(ubicte_enr,'')
		INTO	vgps
		FROM 	enruta
		WHERE	fol_enr = vfolenr;
	END IF;
	
	IF LENGTH(vgps) = 0 OR vgps IS NULL THEN
	 	LET vgps = paramGPS;
	END IF;

	LET move = 1;
	
	IF EXISTS(SELECT 1 FROM movxnvta WHERE fol_mnvta = paramFolio AND cia_mnvta = paramCia AND pla_mnvta = paramPla 
			AND vuelta_mnvta = vvuelta) THEN
	
			UPDATE	movxnvta 
			SET		lts_mnvta = paramLts,
					imp_mnvta = paramImpo,
					bst_mnvta = paramGolpe,
					hini_mnvta = paramHini,
					fhs_mnvta = paramHfin,
					gps_mnvta = vgps
			WHERE	fol_mnvta = paramFolio
			AND		cia_mnvta = paramCia
			AND		pla_mnvta = paramPla
			AND 	vuelta_mnvta = vvuelta;
			LET control = 'A';
		
		
	ELSE
	
			INSERT INTO	movxnvta (fol_mnvta,
							      cia_mnvta,
								  pla_mnvta,
								  mov_mnvta,
								  lts_mnvta,
								  imp_mnvta,
								  bst_mnvta,
								  hini_mnvta,
								  fhs_mnvta,
								  gps_mnvta,
								  vuelta_mnvta
							     )
			VALUES				 (paramFolio,
								  paramCia,
								  paramPla,
								  move,
								  paramLts,
								  paramImpo,
								  paramGolpe,
								  paramHini,
								  paramHfin,
								  vgps,
								  vvuelta
								 );
			LET control = 'A';
	
	
	END IF;	
	
	
	RETURN	control;

END PROCEDURE;

select	rowid,*
from	movxnvta
where	YEAR(fhs_mnvta) = 2023 and MONTH(fhs_mnvta) = 4 and vuelta_mnvta is null and pla_mnvta = '02'
fol_mnvta in(select	fol_nvta from nota_vta where fol_nvta = fol_mnvta 
	and pla_nvta = '02' and fes_nvta = '2023-03-31') and vuelta_mnvta is null
	
	
update  movxnvta
set		vuelta_mnvta  = 13
where  fol_mnvta in(select	fol_nvta from nota_vta where fol_nvta = fol_mnvta 
	and pla_nvta = '02' and fes_nvta = '2023-03-31') and vuelta_mnvta is null
	
update  movxnvta
set		vuelta_mnvta  = 13
where  rowid in(3287574)

update  movxnvta
set		vuelta_mnvta  = 13
where   fol_mnvta = 791576 and pla_mnvta = '02' and vuelta_mnvta is null
	
select	rowid,*
from	movxnvta
where   fol_mnvta = 791576 and pla_mnvta = '02' and vuelta_mnvta is null

select	*
from	nota_vta
where	fol_nvta = 794074 and pla_nvta = '02'

select	*
from	movxnvta
where   fol_mnvta = 794074 and pla_mnvta = '02' and vuelta_mnvta is null

delete
from 	movxnvta
where	fol_mnvta = 794074 and pla_mnvta = '02' and vuelta_mnvta is null

EXECUTE PROCEDURE InsMovNvta(794074,'15','02',152.00,1482.00,146,'09:23','2023-04-01 09:23','20.5374009 -100.4342123')


select	*
from	nota_vta
where   fliq_nvta = 8857   and ruta_nvta = 'M010'

SELECT  NVL(vuelta_enr,0)
FROM	enruta
WHERE   fol_enr = '1502793704';
	
SELECT	NVL(vuelta_pla,0)
FROM	planta
WHERE	cia_pla = '15'
		AND cve_pla = '02';
		
