DROP PROCEDURE fact_generaant;
EXECUTE PROCEDURE fact_generaant('','','2022-01-24');
EXECUTE PROCEDURE fact_generaant('15','86','2022-12-16','fuente');

CREATE PROCEDURE fact_generaant
(
	paramCia	CHAR(2),
	paramPla	CHAR(18),
	paramFecha	DATE
)
RETURNING 
 CHAR(6);		-- No de cliente
 
DEFINE vnumcte 	CHAR(6);
DEFINE vpla1 	CHAR(2);
DEFINE vpla2 	CHAR(2);
DEFINE vpla3 	CHAR(2);
DEFINE vpla4 	CHAR(2);
DEFINE vpla5 	CHAR(2);
DEFINE vpla6 	CHAR(2);
DEFINE vpla7 	CHAR(2);
DEFINE vpla8 	CHAR(2);
DEFINE vpla9 	CHAR(2);

LET vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9 = get_plantas(paramPla);

IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = paramFecha) THEN
	IF NOT EXISTS (SELECT 1 FROM empxrutp WHERE fec_erup = paramFecha and edo_erup <> 'C') AND
		NOT EXISTS (SELECT 1 FROM empxrutc WHERE fec_eruc = paramFecha and edo_eruc <> 'C')	AND
		NOT EXISTS (SELECT 1 FROM venxmed WHERE fec_vmed = paramFecha and edo_vmed <> 'C') AND
		NOT EXISTS (SELECT 1 FROM venxand WHERE fec_vand = paramFecha and edo_vand <> 'C') AND
		NOT EXISTS (SELECT 1 FROM des_dir WHERE fec_desd = paramFecha and edo_desd <> 'C') THEN	
		--REVISA QUE EXISTAN NOTAS DE CLIENTES CON ANTICIPO----------------------------------------------------
		IF	EXISTS (SELECT	1
					FROM 	nota_vta n, cliente c
					WHERE	n.numcte_nvta = c.num_cte  
							AND (n.cia_nvta = paramCia OR paramCia = '')
							AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
							AND tpa_nvta IN('C','G')
							AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							AND tip_nvta IN('B','C','D','E','2','3','4')
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND n.numcte_nvta IN(SELECT	num_cte
												FROM	cliente, anticipo, cte_fac 
												WHERE   num_cte = cte_ant
														AND numcte_nvta = numcte_cfac 
														AND abo_ant > 0))THEN
				FOREACH cClientes FOR
					SELECT	n.numcte_nvta
					INTO	vnumcte
					FROM 	nota_vta n, cliente c
					WHERE	n.numcte_nvta = c.num_cte  
							AND (n.cia_nvta = paramCia OR paramCia = '')
							AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
							AND tpa_nvta IN('C','G')
							AND fes_nvta = paramFecha AND edo_nvta = 'A' AND impt_nvta > 0
							AND tip_nvta IN('B','C','D','E','2','3','4')
							AND (aju_nvta IS NULL OR aju_nvta <> 'S')
							AND fac_nvta IS NULL
							AND n.numcte_nvta IN(SELECT	num_cte
												FROM	cliente, anticipo, cte_fac 
												WHERE   num_cte = cte_ant
														AND numcte_nvta = numcte_cfac 
														AND abo_ant > 0)
					GROUP BY 1
					RETURN 	vnumcte
					WITH RESUME;
				END FOREACH;	
		END IF;		
	END IF;
END IF;
END PROCEDURE;

select	*
from	cte_fac

SELECT	*
FROM 	nota_vta n, cliente c
WHERE	n.numcte_nvta = c.num_cte  
		AND tpa_nvta IN('C','G')
		AND fes_nvta = '2022-01-14' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		and n.numcte_nvta in(select	num_cte
						from	cliente, anticipo, cte_fac 
						where   num_cte = cte_ant
								AND n.numcte_nvta = numcte_cfac 
								and abo_ant > 0)
SELECT	n.numcte_nvta
FROM 	nota_vta n, cliente c
WHERE	n.numcte_nvta = c.num_cte  
		AND tpa_nvta IN('C','G')
		AND fes_nvta = '2023-03-15' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		AND n.numcte_nvta IN(SELECT	num_cte
							FROM	cliente, anticipo, cte_fac 
							WHERE   num_cte = cte_ant
									AND numcte_nvta = numcte_cfac 
									AND abo_ant > 0)
GROUP BY 1
												
select	*
from	cliente, anticipo
where   num_cte = cte_ant
		and abo_ant > 0
		
select	*
from	doctos
where	cte_doc = '011516' and sal_doc > 0
order by femi_doc desc


select	*
from	doctos
where	fol_doc = 72151

select	*
from	doctos
where  sal_doc > 0 and ffac_doc is null
order by femi_doc desc

select	*
from	cte_fac

insert into cte_fac values('001432','D');

delete from cte_fac where numcte_cfac = '095022'
 

select	*
from	nota_vta
where	fol_nvta = 72171

select	*
from	nota_vta
where	tpa_nvta = 'C' and fes_nvta = '2023-01-05' and edo_nvta = 'A' and fac_nvta is null

update	nota_vta
set		fac_nvta = 1000000
where   fol_nvta in(72151,72152,72153,72154,72155,72156) and pla_nvta = 85

select	*
from	factura
where	fec_fac = '2022-01-14' and tfac_fac = 'S'

select	*
from	factura
where	fol_fac in(25301) and ser_fac = 'EAPH'

delete
from  	factura
where	fol_fac in(25598) and ser_fac = 'EAPH'

select	*
from	det_fac 
where	fol_dfac in(25598) and ser_dfac = 'EAPH'

delete
from	det_fac 
where	fol_dfac in(25598) and ser_dfac = 'EAPH'


SELECT	*
FROM 	nota_vta n, cliente c
WHERE	n.numcte_nvta = c.num_cte  
		--AND (n.cia_nvta = paramCia OR paramCia = '')
		--AND (n.pla_nvta IN(vpla1,vpla2,vpla3,vpla4,vpla5,vpla6,vpla7,vpla8,vpla9) OR paramPla = '')
		AND tpa_nvta IN('C','G')
		AND fes_nvta = '2023-06-11' AND edo_nvta = 'A' AND impt_nvta > 0
		AND tip_nvta IN('B','C','D','E','2','3','4')
		AND (aju_nvta IS NULL OR aju_nvta <> 'S')
		AND fac_nvta IS NULL
		AND n.numcte_nvta IN(SELECT	num_cte
							FROM	cliente, anticipo, cte_fac 
							WHERE   num_cte = cte_ant
									AND numcte_nvta = numcte_cfac 
									AND abo_ant > 0)
									