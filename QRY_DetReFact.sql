DROP PROCEDURE QRY_DetReFact;
EXECUTE PROCEDURE  QRY_DetReFact('216090','C','2','2024-03-13');

CREATE PROCEDURE QRY_DetReFact
(
	paramCia  CHAR(2),
	paramPla  CHAR(2),
	paramCte  CHAR(6),
	paramTpa  CHAR(1),
	paramTipo CHAR(1),  -- 2 refacturacion motivo 02, 1 refacturacion motivo 01
	paramFecha DATE
)

RETURNING  
 CHAR(2),
 CHAR(2),
 INT,
 CHAR(4), 
 SMALLINT,
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
 DATE,
 CHAR(40);

DEFINE vfolio 	INT;
DEFINE vserie   CHAR(4);
DEFINE vcia     CHAR(2);
DEFINE vpla     CHAR(2);
DEFINE vmov   	SMALLINT;
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
DEFINE vuuid	CHAR(40);

LET vfecha = null;

IF	paramTipo = '1' THEN
	FOREACH cFactura FOR
		SELECT	df.cia_dfac, df.pla_dfac, df.fol_dfac, df.ser_dfac, df.mov_dfac, df.tid_dfac, df.fnvta_dfac, df.ffis_dfac, df.tlts_dfac, 
				df.tpr_dfac, df.pru_dfac, df.ivap_dfac, df.simp_dfac, df.impasi_dfac, df.vuelta_dfac, df.pcre_dfac, f.uuid_fac
		INTO	vcia,vpla,vfolio,vserie,vmov,vtipo,vfnvta,vffis,vtlts,vtprd,vprecio,vivap,vsimp,vimpasi,vvuelta,vpcre,vuuid
		FROM	factura f, det_fac df
		WHERE	f.fol_fac = df.fol_dfac AND f.ser_fac = df.ser_dfac 
				AND edo_fac <> 'C' AND feccan_fac IS NULL
				AND cia_fac = paramCia AND pla_fac = paramPla
				AND numcte_fac = paramCte
				AND fec_fac > (TODAY - 60)
		IF vfnvta IS NOT NULL THEN
			IF EXISTS(SELECT 	1 
			  	FROM 	nota_vta 
			  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta AND tpa_nvta  = paramTpa) THEN
					SELECT 	fes_nvta
					INTO	vfecha
					FROM	nota_vta
					WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta;
			
			ELSE
				IF EXISTS(SELECT 	1 
			  		FROM 	rdnota_vta 
				  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta AND tpa_nvta  = paramTpa) THEN
						SELECT 	fes_nvta
						INTO	vfecha
						FROM	rdnota_vta
						WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta;
				ELSE
					IF EXISTS(SELECT 	1 
			  			FROM 	hnota_vta 
					  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta AND tpa_nvta  = paramTpa) THEN
							SELECT 	fes_nvta
							INTO	vfecha
							FROM	hnota_vta
							WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta;
					END IF;
				END IF;
			END IF;
		END IF;
		
		RETURN 	vcia,vpla,vfolio,vserie,vmov,vtipo,vfnvta,vffis,vtlts,vtprd,vprecio,vivap,vsimp,vimpasi,vvuelta,vpcre,vfecha,vuuid
		WITH RESUME;
	END FOREACH;
END IF;

IF	paramTipo = '2' THEN
	FOREACH cFactura FOR
		SELECT	df.cia_dfac, df.pla_dfac, df.fol_dfac, df.ser_dfac, df.mov_dfac, df.tid_dfac, df.fnvta_dfac, df.ffis_dfac, df.tlts_dfac, 
				df.tpr_dfac, df.pru_dfac, df.ivap_dfac, df.simp_dfac, df.impasi_dfac, df.vuelta_dfac, df.pcre_dfac, f.uuid_fac
		INTO	vcia,vpla,vfolio,vserie,vmov,vtipo,vfnvta,vffis,vtlts,vtprd,vprecio,vivap,vsimp,vimpasi,vvuelta,vpcre,vuuid
		FROM	factura f, det_fac df
		WHERE	f.fol_fac = df.fol_dfac AND f.ser_fac = df.ser_dfac 
				AND edo_fac <> 'C' AND feccan_fac > fec_fac AND feccan_fac > (TODAY - 365)
				AND cia_fac = paramCia AND pla_fac = paramPla
				AND numcte_fac = paramCte
				AND df.fnvta_dfac NOT IN(	SELECT 	NVL(fnvta_dfac,0) 
												FROM 	factura, det_fac
												WHERE 	fol_fac = fol_dfac AND ser_fac = ser_dfac
														AND edo_fac <> 'C' AND feccan_fac IS NULL and frf_fac IS NOT NULL 
														AND cia_fac = paramCia AND pla_fac = paramPla
														AND fec_fac > (TODAY - 365) and vuelta_dfac = df.vuelta_dfac)
		IF vfnvta IS NOT NULL THEN
			IF EXISTS(SELECT 	1 
			  	FROM 	nota_vta 
			  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta AND tpa_nvta  = paramTpa) THEN
					SELECT 	fes_nvta
					INTO	vfecha
					FROM	nota_vta
					WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta;
			
			ELSE
				IF EXISTS(SELECT 	1 
			  		FROM 	rdnota_vta 
				  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta AND tpa_nvta  = paramTpa) THEN
						SELECT 	fes_nvta
						INTO	vfecha
						FROM	rdnota_vta
						WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta;
				ELSE
					IF EXISTS(SELECT 	1 
			  			FROM 	hnota_vta 
					  	WHERE 	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta AND tpa_nvta  = paramTpa) THEN
							SELECT 	fes_nvta
							INTO	vfecha
							FROM	hnota_vta
							WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfnvta AND vuelta_nvta = vvuelta;
					END IF;
				END IF;
			END IF;
		END IF;
		
		RETURN 	vcia,vpla,vfolio,vserie,vmov,vtipo,vfnvta,vffis,vtlts,vtprd,vprecio,vivap,vsimp,vimpasi,vvuelta,vpcre,vfecha,vuuid
		WITH RESUME;
	END FOREACH;
END IF;
END PROCEDURE; 

select	df.fol_dfac, df.ser_dfac, df.cia_dfac, df.pla_dfac, df.mov_dfac, df.tid_dfac, df.fnvta_dfac, df.ffis_dfac,
		df.tlts_dfac, df.tpr_dfac, df.pru_dfac, df.ivap_dfac, df.simp_dfac, df.impasi_dfac, df.vuelta_dfac, df.pcre_dfac
from	factura f, det_fac df
where	f.fol_fac = df.fol_dfac and f.ser_fac = df.ser_dfac 
		and edo_fac <> 'C' and feccan_fac > fec_fac
		AND cia_fac = '15' AND pla_fac = '02'
		and numcte_fac = '216090' and feccan_fac > (TODAY - 365)
		and df.fnvta_dfac not in(select NVL(fnvta_dfac,0) 
								from factura, det_fac
								where fol_fac = fol_dfac and ser_fac = ser_dfac
										and edo_fac <> 'C' and feccan_fac is null and frf_fac is not null 
										AND cia_fac = '15' AND pla_fac = '02'
										and fec_fac > (TODAY - 365) and vuelta_dfac = df.vuelta_dfac)
										
SELECT	df.cia_dfac, df.pla_dfac, df.fol_dfac, df.ser_dfac, df.mov_dfac, df.tid_dfac, df.fnvta_dfac, df.ffis_dfac, df.tlts_dfac, 
		df.tpr_dfac, df.pru_dfac, df.ivap_dfac, df.simp_dfac, df.impasi_dfac, df.vuelta_dfac, df.pcre_dfac, f.uuid_fac
FROM	factura f, det_fac df
WHERE	f.fol_fac = df.fol_dfac AND f.ser_fac = df.ser_dfac 
		AND edo_fac <> 'C' AND feccan_fac > fec_fac 
		AND numcte_fac = '188519' AND feccan_fac > (TODAY - 365)
		AND df.fnvta_dfac NOT IN(	SELECT 	NVL(fnvta_dfac,0) 
										FROM 	factura, det_fac
										WHERE 	fol_fac = fol_dfac AND ser_fac = ser_dfac
												AND edo_fac <> 'C' AND feccan_fac IS NULL and frf_fac IS NOT NULL
												AND fec_fac > (TODAY - 365))

147725
172156	
095103
000236
167211
select fol_fac,ser_fac, fec_fac
from factura
where edo_fac <> 'C' and feccan_fac is null and frf_fac is not null 
			and numcte_fac = '000236'
order by fol_fac

select fnvta_dfac 
from factura, det_fac
where fol_fac = fol_dfac and ser_fac = ser_dfac
		and edo_fac <> 'C' and feccan_fac is null and frf_fac is not null 
			and numcte_fac = '147725'
order by 1
	
select	*
from	det_fac
where	fol_dfac = 74090 and ser_dfac = 'EABC'
										
										