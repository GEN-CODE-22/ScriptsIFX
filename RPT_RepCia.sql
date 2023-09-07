DROP PROCEDURE RPT_RepCia;
EXECUTE PROCEDURE  RPT_RepCia(null,null,null,'2020-03-01','2020-03-31');
EXECUTE PROCEDURE  RPT_RepCia(null,null,null,'2020-03-01','2020-03-31');
EXECUTE PROCEDURE RPT_FactRepCia('2020-03-01','2020-03-31');
CREATE PROCEDURE RPT_RepCia
(
	paramCia   	CHAR(2),
	paramPla   	CHAR(2),
	paramCte	CHAR(2),
	paramFecIni	DATE,
	paramFecFin	DATE
)

RETURNING  
 CHAR(2), 
 CHAR(2), 
 INT, 
 CHAR(4), 
 DATE,
 DECIMAL,
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

DEFINE v_cia   CHAR(2);
DEFINE v_pla   CHAR(2);
DEFINE vfolfac INT;
DEFINE vserfac CHAR(4);
DEFINE vfecfac DATE;
DEFINE vimporte DECIMAL;
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

FOREACH cFacturas FOR
	SELECT 	cia_fac, pla_fac,fol_fac,ser_fac,fec_fac, impt_fac, numcte_fac,
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
	INTO	vciapla,
			vfolfac,
			vserfac,
			vfecfac,
			vimporte,
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
			and cia_fac = cia_dfac
			and pla_fac = pla_dfac
			and numcte_fac = num_cte
	GROUP BY 1,2,3,4,5,6
	UNION
	SELECT 	cia_fac||pla_fac,fol_fac,ser_fac,fec_fac, impt_fac, numcte_fac,'C A N C E L A D O',
			0,0,0,0,0,0,0,0,0
	FROM 	factura
	WHERE 	fec_fac between paramFecIni and paramFecFin
			and (cia_fac = paramCia OR paramCia IS NULL)
			and (pla_fac = paramPla OR paramPla IS NULL)
			and (numcte_fac = paramCte OR paramCte IS NULL)
	  		and tdoc_fac = 'I'
		  	and edo_fac = 'C'
	UNION
	SELECT 	cia_fac||pla_fac,fol_fac,ser_fac,fec_fac, impt_fac, numcte_fac,('SUBTITUYE '||frf_fac||srf_fac),
			0,0,0,0,0,0,0,0,0
	FROM 	factura
	WHERE 	fec_fac between paramFecIni and paramFecFin
			and (cia_fac = paramCia OR paramCia IS NULL)
			and (pla_fac = paramPla OR paramPla IS NULL)
			and (numcte_fac = paramCte OR paramCte IS NULL)
	  		and tdoc_fac = 'I'
	  		and frf_fac is not null
	order by 1,2,3,4,5
	RETURN 	vciapla,
			vfolfac,
			vserfac,
			vfecfac,
			vimporte,
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
END PROCEDURE; 