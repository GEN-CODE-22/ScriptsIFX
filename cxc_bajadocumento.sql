DROP PROCEDURE cxc_bajadocumento;
EXECUTE PROCEDURE  cxc_bajadocumento(768,'15','15',3);

=CONCATENAR("EXECUTE PROCEDURE  cxc_bajadocumento(",B103,",'",C103,"','",TEXTO(D103,"00"),"',",E103,");")

select fol_doc, cia_doc, pla_doc, vuelta_doc
from   doctos
where  femi_doc = '2024-05-29'

select *
from   doctos where fol_doc in(71098,71099) and femi_doc = '2024-05-29'
where  femi_doc = '2024-05-29'

select *
from   mov_cxc 
where  fec_mcxc = '2024-05-29' 

select *
from   nota_vta
where  fes_nvta = '2024-05-29' and edo_nvta = 'A'  and napl_nvta = 'C'

update  nota_vta
set 	edo_nvta = 'S'--, napl_nvta = 'N'
where  fes_nvta = '2024-05-29' and edo_nvta = 'A' and napl_nvta = 'C'

CREATE PROCEDURE cxc_bajadocumento
(
	paramFol   		INT,
	paramCia		CHAR(2),
	paramPla		CHAR(2),	
	paramVuelta		SMALLINT
)

RETURNING  
 INT,		-- 0 = No proceso 1 = Proceso
 CHAR(100),	-- Mensaje
 DECIMAL;   -- Importe dado de baja

DEFINE vproceso	INT;
DEFINE vmsg 	CHAR(100);
DEFINE vfecha 	DATE;
DEFINE vcte 	CHAR(6);
DEFINE vimpt 	DECIMAL;
DEFINE vctecar 	DECIMAL;
DEFINE vcteabo 	DECIMAL;
DEFINE vctesal 	DECIMAL;
DEFINE vctefecu	DATE;

LET vproceso = 1;
LET vmsg = 'DOCUMENTO DADO DE BAJA CORRECTAMENTE';
LET vimpt = 0;

IF EXISTS(SELECT 	1 
		  	FROM 	nota_vta 
		  	WHERE 	fol_nvta = paramFol AND cia_nvta = paramCia AND pla_nvta = paramPla AND vuelta_nvta = paramVuelta
		  			AND tpa_nvta IN('C','G') AND edo_nvta in('S','A')) THEN		
	SELECT	numcte_nvta,impt_nvta,fes_nvta
	INTO	vcte,vimpt,vfecha
	FROM	nota_vta
	WHERE	fol_nvta = paramFol AND cia_nvta = paramCia AND pla_nvta = paramPla AND vuelta_nvta = paramVuelta;	
	IF NOT EXISTS(SELECT 	1 
	  	FROM 	e_posaj e
	  	WHERE 	e.epo_fec = vfecha) THEN
	  	IF EXISTS(SELECT 1 FROM doctos 
	  		WHERE fol_doc = paramFol AND cia_doc = paramCia AND pla_doc = paramPla AND vuelta_doc = paramVuelta) THEN
	  		IF NOT EXISTS(SELECT 1 FROM mov_cxc 
	  			WHERE doc_mcxc = paramFol AND cia_mcxc = paramCia AND pla_mcxc = paramPla AND vuelta_mcxc = paramVuelta 
	  					AND tpm_mcxc > '49' AND sta_mcxc = 'A') THEN
	  		
	  			--ELIMINA DOCUMENTO----------------------------------------------------------------------------
				IF NOT EXISTS(SELECT 1 FROM doctosbaj WHERE fol_doc = paramFol AND cia_doc = paramCia AND pla_doc = paramPla AND vuelta_doc = paramVuelta) THEN
					INSERT INTO doctosbaj
					SELECT	* FROM doctos WHERE fol_doc = paramFol AND cia_doc = paramCia AND pla_doc = paramPla AND vuelta_doc = paramVuelta;
				END IF;
		  		DELETE
		  		FROM	doctos
		  		WHERE 	fol_doc = paramFol AND cia_doc = paramCia AND pla_doc = paramPla AND vuelta_doc = paramVuelta;
	
			  	--ELIMINA EN LA TABLA mov_cxc---------------------------------------------------------------
				IF NOT EXISTS(SELECT 1 FROM mov_cxcbaj WHERE doc_mcxc = paramFol AND cia_mcxc = paramCia AND pla_mcxc = paramPla AND vuelta_mcxc = paramVuelta) THEN
					INSERT INTO mov_cxcbaj
					SELECT	* FROM mov_cxc WHERE doc_mcxc = paramFol AND cia_mcxc = paramCia AND pla_mcxc = paramPla AND vuelta_mcxc = paramVuelta;
				END IF;
				
				DELETE
				FROM	mov_cxc
				WHERE	doc_mcxc = paramFol AND cia_mcxc = paramCia AND pla_mcxc = paramPla AND vuelta_mcxc = paramVuelta;
			  	
				--ACTUALIZA SALDOS DEL CLIENTE-----------------------------------------------------------------
				SELECT	saldo_cte, abono_cte, cargo_cte, fecuab_cte
				INTO	vctesal, vcteabo, vctecar, vctefecu
				FROM	cliente
				WHERE	num_cte = vcte;		
				
				LET vctecar = vctecar - vimpt;
				LET vctesal = vctecar - vcteabo;
				SELECT	MAX(fult_doc)
				INTO	vctefecu
				FROM	doctos
				WHERE	cte_doc = vcte;
				
				UPDATE	cliente
				SET		saldo_cte = vctesal,
						cargo_cte = vctecar,
						fecuab_cte= vctefecu
				WHERE	num_cte = vcte;
			ELSE
				LET vproceso = 0;
				LET vmsg = 'NO SE PUEDE DAR DE BAJA EL DOCUMENTO, YA TIENE PAGOS REGISTRADOS.';	
			END IF;
		ELSE
			LET vproceso = 0;
			LET vmsg = 'NO SE PUEDE DAR DE BAJA EL DOCUMENTO, NO EXISTE EL DOCUMENTO.';	
		END IF;
	 ELSE
	 	LET vproceso = 0;
		LET vmsg = 'NO SE PUEDE DAR DE BAJA EL DOCUMENTO, EL DIA YA ESTA CERRADO.';	
	 END IF;
ELSE
	LET vproceso = 0;
	LET vmsg = 'NO EXISTE DOCUMENTO VALIDO CON LOS CRITERIOS DE BUSQUEDA, FAVOR DE REVISAR.';
END IF;

RETURN 	vproceso,vmsg,vimpt;
END PROCEDURE; 
 

select	*
from	doctos 
where	fol_doc in(597604) and vuelta_doc = 5

delete
from	doctos
where	fol_doc in(491644) and  vuelta_doc = 1

select	*
from	mov_cxc
where	doc_mcxc in(383996) and vuelta_mcxc = 5 and cte_mcxc = '087996' and tpm_mcxc = '50'

delete
from	mov_cxc
where	doc_mcxc in(491646) and vuelta_mcxc = 1

update	mov_cxc
set		vuelta_mcxc = 3
where   doc_mcxc in(240454) and cte_mcxc = 000486

select	*
from	rdnota_vta
where	fol_nvta = 491646

update	mov_cxc
set		sta_mcxc = 'A'
where	doc_mcxc in(2033) and pla_mcxc ='09' and cte_mcxc = '061588' and tpm_mcxc = '58'

select	saldo_cte, abono_cte, cargo_cte, fecuab_cte, * 
from	cliente
where   num_cte = '000486'

update	cliente
set		cargo_cte = 710643488.30, saldo_cte = 12286837.68, abono_cte = 698356650.62--, abono_cte = 20116161.05--, fecuab_cte = '2022-09-20'
where   num_cte = '034178'

select	sum(abo_doc),sum(car_doc)
from	doctos
where	cte_doc in('078994') and sta_doc = 'A'

SELECT	NVL(MAX(fec_mcxc),null)
FROM 	mov_cxc
WHERE	cte_mcxc = '061588' AND sta_mcxc = 'A' AND tpm_mcxc > '49';

select	*
from	doctos
where	cte_doc in('047421') and sta_doc = 'A'

SELECT  SUM(sal_doc) 
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '33' AND sta_doc = 'A' AND ffac_doc = 25390 AND sfac_doc = 'EABC'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')
		
SELECT  fol_doc, cia_doc, pla_doc, tip_doc, sal_doc
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '33' AND sta_doc = 'A' AND ffac_doc = 587967 AND sfac_doc = 'EAB'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')

SELECT  COUNT(unique fec_mcxc)
FROM	mov_cxc
WHERE	ffac_mcxc = 689596 AND sfac_mcxc = 'EAB' AND cia_mcxc = '15' AND pla_mcxc = '02'
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99')

select	*
from	contrare
where	fol_ctra = 656566 AND ser_ctra = 'EAB'

select	tpm_mcxc, count(*)
from	mov_cxc
group by 1
order by 1

select *
from	mov_cxc
where	tpm_mcxc in('00')

select	fec_mcxc, sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc BETWEEN '2022-08-01' and '2022-08-11' and sta_mcxc = 'A'
		AND tpm_mcxc < '50'
group by fec_mcxc
order by fec_mcxc

select	fec_mcxc, sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc BETWEEN '2022-08-01' and '2022-08-11' and sta_mcxc = 'A'
		AND tpm_mcxc > '49'
group by fec_mcxc
order by fec_mcxc

select	fec_mcxc, sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc BETWEEN '2022-10-01' and '2022-10-10' and sta_mcxc = 'A' tpa_mcxc in('C')
        AND tpm_mcxc < '50'
group by fec_mcxc
order by fec_mcxc

select	cia_doc, pla_doc, fol_doc, ser_doc, vuelta_doc, count(*)
from	doctos
where	(tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')
group by 1,2,3,4,5
having count(*) > 1

select	*
from	doctos where tip_doc = '03' and femi_doc >= '2022-01-01'
where	fol_doc = 622382 and pla_doc = '15'

select	count(*)
from	doctos
where	tip_doc = '03' and vuelta_doc is null

update	doctos
set		vuelta_doc = -1
where	tip_doc = '03' and vuelta_doc is null

select	count(*)
from 	mov_cxc
where	vuelta_mcxc is null

update	mov_cxc
set		vuelta_mcxc = -1
where	tip_mcxc = '03' and vuelta_mcxc is null

update	e_posaj
set		epo_fec = '2121-02-17'
where	epo_fec = '2021-02-17'

delete
from	e_posaj
where 	epo_fec = '2020-10-02'

select	*
from	doctosbaj

select	*
from	mov_cxcbaj