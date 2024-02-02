EXECUTE PROCEDURE RPT_FactRepCia(NULL,NULL,null,'2022-06-01','2023-06-30','G');
EXECUTE PROCEDURE RPT_FactRepCia(NULL,NULL,null,'2022-09-01','2022-09-30','D');
EXECUTE PROCEDURE RPT_FactRepCia(NULL,NULL,null,'2022-09-01','2022-09-30','F');
EXECUTE PROCEDURE RPT_FactRepCia(NULL,NULL,null,'2022-09-01','2022-09-30','C');
EXECUTE PROCEDURE RPT_FactRepCia(NULL,NULL,null,'2022-09-01','2022-09-30','R');
EXECUTE PROCEDURE RPT_FactRepCia(NULL,NULL,'054166','2023-12-18','2023-12-31','D');

DROP PROCEDURE RPT_FactRepCia;
CREATE PROCEDURE RPT_FactRepCia
(
	paramCia   	CHAR(2),
	paramPla   	CHAR(2),
	paramCte	CHAR(6),
	paramFecIni	DATE,
	paramFecFin	DATE,
	paramTipo	CHAR(1)
)

RETURNING  
 CHAR(2), 
 CHAR(2), 
 INT, 
 CHAR(4), 
 DATE,
 DECIMAL,
 CHAR(40),
 CHAR(6), 
 CHAR(80),
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL,
 DECIMAL;

DEFINE vcia    CHAR(2);
DEFINE vpla    CHAR(2);
DEFINE vfolfac INT;
DEFINE vserfac CHAR(4);
DEFINE vfecfac DATE;
DEFINE vimporte DECIMAL;
DEFINE vuuid	CHAR(40);
DEFINE vnumcte CHAR(6);
DEFINE vnomcte CHAR(80);
DEFINE vltsest DECIMAL;
DEFINE vimpest DECIMAL;
DEFINE vasiest DECIMAL;
DEFINE vltscar DECIMAL;
DEFINE vimpcar DECIMAL;
DEFINE vasicar DECIMAL;
DEFINE vkgscil DECIMAL;
DEFINE vimpcil DECIMAL;
DEFINE vasicil DECIMAL;

IF paramTipo = 'G' THEN
	FOREACH cFacturas FOR
		SELECT 	cia_fac, pla_fac, '', '', '', '', '', '', '' nom_pla,
		    sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
			sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
			sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
			sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
			sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
			sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
			sum(case when tid_dfac matches '[CD234]' THEN 
			(case when tid_dfac = 'C' THEN tlts_dfac ELSE
			(case when tid_dfac = 'D' THEN tlts_dfac ELSE
			(case when tid_dfac = '2' THEN tlts_dfac * 20 ELSE
			(case when tid_dfac = '3' THEN tlts_dfac * 30 ELSE
			(case when tid_dfac = '4' THEN tlts_dfac * 45 ELSE 0 END) END) END) END) END)
			ELSE 0 END) kgs_cil,
			sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
			sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
		INTO	
			vcia,
			vpla,
			vfolfac,
			vserfac,
			vfecfac,
			vimporte,
			vuuid,
			vnumcte,
			vnomcte,
			vltsest,
			vimpest,
			vasiest,
			vltscar,
			vimpcar,
			vasicar,
			vkgscil,
			vimpcil,
			vasicil
		FROM 	factura,det_fac
		WHERE 	fec_fac between paramFecIni and paramFecFin	
  				and tdoc_fac = 'I'
			  	and edo_fac <> 'C'
				and frf_fac is null
				and fol_fac = fol_dfac
				and ser_fac = ser_dfac
		GROUP BY 1,2,9
		ORDER BY 1,2 
		
		SELECT  nom_pla 
		INTO 	vnomcte
		FROM	planta 
		WHERE   cia_pla = vcia and cve_pla = vpla;
		
		RETURN 	vcia,
			vpla,
			vfolfac,
			vserfac,
			vfecfac,
			vimporte,
			vuuid,
			vnumcte,
			vnomcte,
			vltsest,
			vimpest,
			vasiest,
			vltscar,
			vimpcar,
			vasicar,
			vkgscil,
			vimpcil,
			vasicil
		WITH RESUME;
	END FOREACH;
END IF;
IF paramTipo = 'D' THEN
	FOREACH cFacturas FOR
		SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, NVL(impt_fac,0), uuid_fac, numcte_fac,
				(case when trim(razsoc_cte) > '' THEN razsoc_cte 
				ELSE trim(nom_cte)||" "||trim(ape_cte) END),
				sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
				sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
				sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
				sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
				sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
				sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
				sum(case when tid_dfac matches '[CD234]' THEN 
				(case when tid_dfac = 'C' THEN tlts_dfac ELSE
				(case when tid_dfac = 'D' THEN tlts_dfac ELSE
				(case when tid_dfac = '2' THEN tlts_dfac*20 ELSE
				(case when tid_dfac = '3' THEN tlts_dfac*30 ELSE
				(case when tid_dfac = '4' THEN tlts_dfac*45 ELSE 0 END) END) END) END) END)
				ELSE 0 END) kgs_cil,
				sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
				sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
		INTO	vcia,
				vpla,
				vfolfac,
				vserfac,
				vfecfac,
				vimporte,
				vuuid,
				vnumcte,
				vnomcte,
				vltsest,
				vimpest,
				vasiest,
				vltscar,
				vimpcar,
				vasicar,
				vkgscil,
				vimpcil,
				vasicil
		FROM 	factura,det_fac,cliente
		WHERE 	fec_fac between paramFecIni and paramFecFin
				and (cia_fac = paramCia OR paramCia IS NULL)
				and (pla_fac = paramPla OR paramPla IS NULL)
				and (numcte_fac = paramCte OR paramCte IS NULL)
		  		and tdoc_fac = 'I'
			  	and edo_fac <> 'C'
				and frf_fac is null
				and fol_fac = fol_dfac
				and ser_fac = ser_dfac
				--and cia_fac = cia_dfac
				--and pla_fac = pla_dfac
				and numcte_fac = num_cte
		GROUP BY 1,2,3,4,5,6,7,8,9		
		UNION ALL
		SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, NVL(impt_fac,0), uuid_fac, numcte_fac,'CANCELADO ' || 
				(case when trim(razsoc_cte) > '' THEN razsoc_cte 
				ELSE trim(nom_cte)||" "||trim(ape_cte) END),
				0,0,0,0,0,0,0,0,0
		FROM 	factura, cliente
		WHERE 	fec_fac between paramFecIni and paramFecFin
				and (cia_fac = paramCia OR paramCia IS NULL)
				and (pla_fac = paramPla OR paramPla IS NULL)
				and (numcte_fac = paramCte OR paramCte IS NULL)
		  		and tdoc_fac = 'I'
			  	and edo_fac = 'C'
			  	and numcte_fac = num_cte
		UNION ALL
		SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, NVL(impt_fac,0), uuid_fac, numcte_fac,('SUSTITUYE '||frf_fac||srf_fac || ' '||
				(case when trim(razsoc_cte) > '' THEN razsoc_cte 
				ELSE trim(nom_cte)||" "||trim(ape_cte) END)),
				0,0,0,0,0,0,0,0,0
		FROM 	factura, cliente
		WHERE 	fec_fac between paramFecIni and paramFecFin
				and (cia_fac = paramCia OR paramCia IS NULL)
				and (pla_fac = paramPla OR paramPla IS NULL)
				and (numcte_fac = paramCte OR paramCte IS NULL)
		  		and tdoc_fac = 'I'
		  		and frf_fac is not null
		  		and numcte_fac = num_cte
		order by 1,2,3,4,5,6,7,8
		RETURN 	vcia,
				vpla,
				vfolfac,
				vserfac,
				vfecfac,
				vimporte,
				vuuid,
				vnumcte,
				vnomcte,
				vltsest,
				vimpest,
				vasiest,
				vltscar,
				vimpcar,
				vasicar,
				vkgscil,
				vimpcil,
				vasicil
		WITH RESUME;
	END FOREACH;
END IF;

IF paramTipo = 'F' THEN
	FOREACH cFacturas FOR
		SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, NVL(impt_fac,0), uuid_fac, numcte_fac,'CANCELADO ' || 
				(case when trim(razsoc_cte) > '' THEN razsoc_cte 
				ELSE trim(nom_cte)||" "||trim(ape_cte) END),
				0,0,0,0,0,0,0,0,0
		INTO	vcia,
				vpla,
				vfolfac,
				vserfac,
				vfecfac,
				vimporte,
				vuuid,
				vnumcte,
				vnomcte,
				vltsest,
				vimpest,
				vasiest,
				vltscar,
				vimpcar,
				vasicar,
				vkgscil,
				vimpcil,
				vasicil
		FROM 	factura, cliente
		WHERE 	fec_fac between paramFecIni and paramFecFin
				and (cia_fac = paramCia OR paramCia IS NULL)
				and (pla_fac = paramPla OR paramPla IS NULL)
				and (numcte_fac = paramCte OR paramCte IS NULL)
		  		and tdoc_fac = 'I'
			  	and edo_fac = 'C'
			  	and numcte_fac = num_cte
		UNION ALL		
		SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, NVL(impt_fac,0), uuid_fac, numcte_fac,('SUSTITUYE '||frf_fac||srf_fac || ' '||
				(case when trim(razsoc_cte) > '' THEN razsoc_cte 
				ELSE trim(nom_cte)||" "||trim(ape_cte) END)),
				0,0,0,0,0,0,0,0,0		
		FROM 	factura, cliente
		WHERE 	fec_fac between paramFecIni and paramFecFin
				and (cia_fac = paramCia OR paramCia IS NULL)
				and (pla_fac = paramPla OR paramPla IS NULL)
				and (numcte_fac = paramCte OR paramCte IS NULL)
		  		and tdoc_fac = 'I'
		  		and frf_fac is not null
		  		and numcte_fac = num_cte
		RETURN 	vcia,
				vpla,
				vfolfac,
				vserfac,
				vfecfac,
				vimporte,
				vuuid,
				vnumcte,
				vnomcte,
				vltsest,
				vimpest,
				vasiest,
				vltscar,
				vimpcar,
				vasicar,
				vkgscil,
				vimpcil,
				vasicil
		WITH RESUME;
	END FOREACH;
END IF;
IF paramTipo = 'C' THEN
	FOREACH cFacturas FOR
		SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, NVL(impt_fac,0), uuid_fac, numcte_fac,'CANCELADO ' || 
				(case when trim(razsoc_cte) > '' THEN razsoc_cte 
				ELSE trim(nom_cte)||" "||trim(ape_cte) END),
				0,0,0,0,0,0,0,0,0
		INTO	vcia,
				vpla,
				vfolfac,
				vserfac,
				vfecfac,
				vimporte,
				vuuid,
				vnumcte,
				vnomcte,
				vltsest,
				vimpest,
				vasiest,
				vltscar,
				vimpcar,
				vasicar,
				vkgscil,
				vimpcil,
				vasicil
		FROM 	factura, cliente
		WHERE 	fec_fac between paramFecIni and paramFecFin
				and (cia_fac = paramCia OR paramCia IS NULL)
				and (pla_fac = paramPla OR paramPla IS NULL)
				and (numcte_fac = paramCte OR paramCte IS NULL)
		  		and tdoc_fac = 'I'
			  	and edo_fac = 'C'
			  	and numcte_fac = num_cte
		order by 8
		RETURN 	vcia,
				vpla,
				vfolfac,
				vserfac,
				vfecfac,
				vimporte,
				vuuid,
				vnumcte,
				vnomcte,
				vltsest,
				vimpest,
				vasiest,
				vltscar,
				vimpcar,
				vasicar,
				vkgscil,
				vimpcil,
				vasicil
		WITH RESUME;
	END FOREACH;
END IF;

IF paramTipo = 'R' THEN
	FOREACH cFacturas FOR
		SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, NVL(impt_fac,0), uuid_fac, numcte_fac,('SUSTITUYE '||frf_fac||srf_fac || ' '||
				(case when trim(razsoc_cte) > '' THEN razsoc_cte 
				ELSE trim(nom_cte)||" "||trim(ape_cte) END)),
				0,0,0,0,0,0,0,0,0
		INTO	vcia,
				vpla,
				vfolfac,
				vserfac,
				vfecfac,
				vimporte,
				vuuid,
				vnumcte,
				vnomcte,
				vltsest,
				vimpest,
				vasiest,
				vltscar,
				vimpcar,
				vasicar,
				vkgscil,
				vimpcil,
				vasicil
		FROM 	factura, cliente
		WHERE 	fec_fac between paramFecIni and paramFecFin
				and (cia_fac = paramCia OR paramCia IS NULL)
				and (pla_fac = paramPla OR paramPla IS NULL)
				and (numcte_fac = paramCte OR paramCte IS NULL)
		  		and tdoc_fac = 'I'
		  		and frf_fac is not null
		  		and numcte_fac = num_cte
		order by 8
		RETURN 	vcia,
				vpla,
				vfolfac,
				vserfac,
				vfecfac,
				vimporte,
				vuuid,
				vnumcte,
				vnomcte,
				vltsest,
				vimpest,
				vasiest,
				vltscar,
				vimpcar,
				vasicar,
				vkgscil,
				vimpcil,
				vasicil
		WITH RESUME;
	END FOREACH;
END IF;

END PROCEDURE; 


SELECT 	cia_fac, pla_fac, sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
		sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
		sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
		sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
		sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
		sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
		sum(case when tid_dfac matches '[CD234]' THEN 
		(case when tid_dfac = 'C' THEN tlts_dfac ELSE
		(case when tid_dfac = 'D' THEN tlts_dfac ELSE
		(case when tid_dfac = '2' THEN tlts_dfac*20 ELSE
		(case when tid_dfac = '3' THEN tlts_dfac*30 ELSE
		(case when tid_dfac = '4' THEN tlts_dfac*45 ELSE 0 END) END) END) END) END)
		ELSE 0 END) kgs_cil,
		sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
		sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
FROM 	factura,det_fac
WHERE 	fec_fac between '2023-05-01' and '2023-05-31'
  		and tdoc_fac = 'I'
	  	and edo_fac <> 'C'
		and frf_fac is null
		and fol_fac = fol_dfac
		and ser_fac = ser_dfac		
  		and tdoc_fac = 'I'
	  	and edo_fac <> 'C'
		and frf_fac is null
		and fol_fac = fol_dfac
		and ser_fac = ser_dfac
		and cia_fac = cia_dfac
		and pla_fac = pla_dfac
GROUP BY 1,2

SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, NVL(impt_fac,0), numcte_fac,'CANCELADO ' || 
		(case when trim(razsoc_cte) > '' THEN razsoc_cte 
		ELSE trim(nom_cte)||" "||trim(ape_cte) END),
		0,0,0,0,0,0,0,0,0
FROM 	factura, cliente
WHERE 	fec_fac between '2023-09-01' and '2023-09-30'		
  		and tdoc_fac = 'I'
	  	and edo_fac = 'C'
	  	and numcte_fac = num_cte
	  	
SELECT 	cia_fac, pla_fac, (select nom_pla from planta where cia_pla = cia_fac and cve_pla = pla_fac) nom_pla, 
		sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
		sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
		sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
		sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
		sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
		sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
		sum(case when tid_dfac matches '[CD234]' THEN 
		(case when tid_dfac = 'C' THEN tlts_dfac ELSE
		(case when tid_dfac = 'D' THEN tlts_dfac ELSE
		(case when tid_dfac = '2' THEN tlts_dfac * 20 ELSE
		(case when tid_dfac = '3' THEN tlts_dfac * 30 ELSE
		(case when tid_dfac = '4' THEN tlts_dfac * 45 ELSE 0 END) END) END) END) END)
		ELSE 0 END) kgs_cil,
		sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
		sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
FROM 	factura ,det_fac--, planta
WHERE 	fec_fac between '2023-06-01' and '2023-06-30'		
  		and tdoc_fac = 'I'
	  	and edo_fac <> 'C'
		and frf_fac is null
		and fol_fac = fol_dfac
		and ser_fac = ser_dfac
		--and cia_pla = cia_fac
		--and cve_pla = pla_fac
		--and cia_dfac = cia_pla
		--and pla_dfac = cve_pla
		--and cia_dfac = cia_pla
		--and pla_dfac = cve_pla
GROUP BY 1,2,3

SELECT 	cia_dfac, pla_dfac, nom_pla, sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
		sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
		sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
		sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
		sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
		sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
		sum(case when tid_dfac matches '[CD234]' THEN 
		(case when tid_dfac = 'C' THEN tlts_dfac ELSE
		(case when tid_dfac = 'D' THEN tlts_dfac ELSE
		(case when tid_dfac = '2' THEN tlts_dfac * 20 ELSE
		(case when tid_dfac = '3' THEN tlts_dfac * 30 ELSE
		(case when tid_dfac = '4' THEN tlts_dfac * 45 ELSE 0 END) END) END) END) END)
		ELSE 0 END) kgs_cil,
		sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
		sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
FROM 	det_fac, planta
WHERE 	exists (select fol_fac from factura where fec_fac between '2023-05-01' and '2023-05-31'		
  		and tdoc_fac = 'I'
	  	and edo_fac <> 'C'
		and frf_fac is null
		and fol_fac = fol_dfac
		and ser_fac = ser_dfac)
		and cia_dfac = cia_pla
		and pla_dfac = cve_pla
GROUP BY 1,2,3

SELECT 	cia_dfac, pla_dfac, nom_pla, sum(case when tid_dfac = 'E' THEN tlts_dfac ELSE 0 END) lts_est,
		sum(case when tid_dfac = 'E' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_est,
		sum(case when tid_dfac = 'E' THEN impasi_dfac ELSE 0 END) asi_est,
		sum(case when tid_dfac = 'B' THEN tlts_dfac ELSE 0 END) lts_carb,
		sum(case when tid_dfac = 'B' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_carb,
		sum(case when tid_dfac = 'B' THEN impasi_dfac ELSE 0 END) asi_carb,
		sum(case when tid_dfac matches '[CD234]' THEN 
		(case when tid_dfac = 'C' THEN tlts_dfac ELSE
		(case when tid_dfac = 'D' THEN tlts_dfac ELSE
		(case when tid_dfac = '2' THEN tlts_dfac * 20 ELSE
		(case when tid_dfac = '3' THEN tlts_dfac * 30 ELSE
		(case when tid_dfac = '4' THEN tlts_dfac * 45 ELSE 0 END) END) END) END) END)
		ELSE 0 END) kgs_cil,
		sum(case when tid_dfac matches '[CD234]' THEN tlts_dfac*pru_dfac ELSE 0 END) imp_cil,
		sum(case when tid_dfac matches '[CD234]' THEN impasi_dfac ELSE 0 END) asi_cil
FROM 	det_fac, planta, (select fol_fac from factura where fec_fac between '2023-05-01' and '2023-05-31'
		and tdoc_fac = 'I'
	  	and edo_fac <> 'C'
		and frf_fac is null
		and fol_fac = fol_dfac
		and ser_fac = ser_dfac)		
WHERE 	fol_dfac  = fol_fac	
		and cia_dfac = cia_pla
		and pla_dfac = cve_pla
GROUP BY 1,2,3

select	*
from	planta