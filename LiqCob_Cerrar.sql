DROP PROCEDURE LiqCob_Cerrar;
EXECUTE PROCEDURE  LiqCob_Cerrar(60396, 'fuente');

CREATE PROCEDURE LiqCob_Cerrar
(
	paramFolio   	INT,
	paramUsr		CHAR(8)
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(500),		-- Mensaje error
 DECIMAL;		-- Total aplicado
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(500);
DEFINE vfolliq 	INT;
DEFINE vnum 	INT;
DEFINE vfecha 	DATE;
DEFINE vedo		CHAR(1);
DEFINE vfom 	CHAR(1);
DEFINE vtipo 	CHAR(20);
DEFINE vdes 	CHAR(20);
DEFINE vfolio 	INT;
DEFINE vserie 	CHAR(4);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vtipmov 	CHAR(2);
DEFINE vvuelta 	INT;
DEFINE vnocte 	CHAR(6);
DEFINE vproceso INT;
DEFINE vmsg		CHAR(100);
DEFINE vsaldo   DECIMAL;
DEFINE vimppag  DECIMAL;
DEFINE vimptot  DECIMAL;
DEFINE vimp 	DECIMAL;
DEFINE vimpp 	DECIMAL;
DEFINE vimpr 	DECIMAL;
DEFINE vimpe 	DECIMAL;
DEFINE vimpc 	DECIMAL;
DEFINE vimpf 	DECIMAL;
DEFINE vsalfac 	DECIMAL;
DEFINE vcount 	INT;

LET vresult = 1;
LET vproceso = 0;
LET vmensaje = '';
LET vmsg = '';
LET vimptot = 0;
LET vimppag = 0;
LET vimpp = 0;
LET vimpr = 0;
LET vimpe = 0;
LET vimpc = 0;
LET vimpf = 0;
LET vsalfac = 0;

FOREACH cDetalleValidar FOR
	SELECT	fom_dlcob, fol_dlcob, ser_dlcob, count(*)
	INTO	vtipo, vfolio, vserie, vcount
	FROM	det_lcob 
	WHERE	fliq_dlcob = paramFolio
	GROUP BY  1,2,3
	HAVING   COUNT(*) > 1
	
	IF vcount > 1 THEN
		LET vresult = 0;
		IF vtipo = 'F' THEN
			LET vmensaje =  ' FACTURA: ' || vfolio || ' ' || vserie || ' ESTA MAS DE 1 VEZ EN LA LIQUIDACION.';
		ELSE
			LET vmensaje =  ' DOCUMENTO: ' || vfolio || ' ' || vserie || ' ESTA MAS DE 1 VEZ EN LA LIQUIDACION.';
		END IF;		
	END IF;
END FOREACH;
IF vresult = 0 THEN
	RETURN 	vresult,vmensaje,vimptot;
END IF;

IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj e, liq_cob l
		  	WHERE 	e.epo_fec = l.fec_lcob AND l.fliq_lcob = paramFolio) THEN
	FOREACH cLiquidacion FOR
		SELECT	l.fliq_lcob, 
				CASE WHEN d.edo_dlcob = 'C' AND l.fec_lcob < d.fec_dlcob THEN d.fec_dlcob ELSE l.fec_lcob END,
				d.num_dlcob, d.fom_dlcob, d.tip_dlcob, d.fol_dlcob, d.des_dlcob,
				NVL(d.ser_dlcob,''), d.cia_dlcob, d.pla_dlcob, d.edo_dlcob, d.imp_dlcob, d.vuelta_dlcob,
				CASE
					WHEN d.edo_dlcob = 'E' THEN '50'
					WHEN d.edo_dlcob = 'C' AND l.fec_lcob = d.fec_dlcob THEN '51'
					WHEN d.edo_dlcob = 'C' AND l.fec_lcob < d.fec_dlcob THEN '56'
					WHEN d.edo_dlcob MATCHES '[BDFHJMTV]' THEN '58'
					WHEN d.edo_dlcob = 'K' THEN '60'
					WHEN d.edo_dlcob = 'L' THEN '61'
					WHEN d.edo_dlcob = 'O' THEN '62'
					WHEN d.edo_dlcob = 'S' THEN '63'
					ELSE ''
				END
		INTO	vfolliq, vfecha, vnum, vfom, vtipo, vfolio, vdes, vserie, vcia, vpla, vedo, vimp, vvuelta, vtipmov
		FROM	liq_cob l, det_lcob d
		WHERE	l.fliq_lcob = d.fliq_dlcob
				AND l.fliq_lcob = paramFolio
		
		IF vtipmov IS NOT NULL AND vtipmov <> '' AND (vfom = 'F' OR vfom = 'D') AND vresult = 1 THEN			
			--DOCUMENTO O CHEQUE DEVUELTO------------------------------------------------------------------------------------------------
			IF vfom = 'D' AND (vtipo = '01' OR vtipo = '03' OR (vtipo >= '11' AND vtipo <= '99')) THEN			
				LET vproceso,vmsg,vimppag,vsaldo = LiqCob_PagoDoc(vfolliq,vfolio,vcia,vpla,vtipo,vtipmov,vimp,vfecha,vdes,paramUsr,vvuelta,vserie);
				LET vimptot = vimptot + vimppag;			
				IF vproceso = 0 THEN
					LET vresult = 0;
					LET vmensaje = 'ERROR AL PROCESAR LINEA: ' || vnum || ' ' || vmsg;				
				END IF;
			END IF;
			--FACTURA------------------------------------------------------------------------------------------------------------------
			IF vfom = 'F' AND vtipo = '00' AND vresult = 1 THEN		
				LET vproceso,vmsg,vimppag = LiqCob_PagoFac(vfolliq,vfolio,vserie,vcia,vpla,vtipmov,vimp,vfecha,vdes,vnum,paramUsr);
				LET vimptot = vimptot + vimppag;
				IF vproceso = 0 THEN
					LET vresult = 0;
					LET vmensaje = 'ERROR AL PROCESAR LINEA: ' || vnum || ' ' || vmsg;	
				ELSE
					SELECT  SUM(sal_doc) 
					INTO	vsalfac
					FROM 	doctos 
					WHERE   cia_doc = vcia AND pla_doc = vpla AND sta_doc = 'A' AND ffac_doc = vfolio AND sfac_doc = vserie
							AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');
					UPDATE  det_lcob
					SET		salini_dlcob = vimppag + vsalfac, salfin_dlcob = vsalfac
					WHERE	fliq_dlcob = paramFolio AND num_dlcob = vnum;			
				END IF;			
			END IF;	
			IF	vedo MATCHES '[BDFHJMTVKLOS]' THEN
				LET vimpf = vimpf + vimppag;
			END IF;
			IF	vedo = 'C' THEN
				LET vimpc = vimpc + vimppag;
			END IF;
			IF	vedo = 'E' THEN
				LET vimpe = vimpe + vimppag;
			END IF;		
		ELSE
			--CONTRARECIBO------------------------------------------------------------------------------------------------------------------
			IF vedo = 'R' THEN
				IF NOT EXISTS(	SELECT 	1 
	  						FROM 	contrare 
							WHERE 	fol_ctra = vfolio AND ser_ctra = vserie AND cia_ctra = vcia 
							  		AND pla_ctra = vpla AND tip_ctra = vtipo AND fom_ctra = vfom) THEN
					INSERT INTO contrare
					VALUES(vfom,vtipo,vfolio,vserie,vcia,vpla,vvuelta);
				END IF;
				LET vimpr = vimpr + vimp;
			END IF;
			IF vedo = 'P' THEN
				LET vimpp = vimpp + vimp;
			END IF;
		END IF;
	END FOREACH;

	IF vresult = 1 THEN
		UPDATE	liq_cob
		SET		edo_lcob = 'C', impp_lcob = vimpp, impr_lcob = vimpr, impe_lcob = vimpe, impc_lcob = vimpc, impf_lcob = vimpf,
				impt_lcob = vimptot
		WHERE	fliq_lcob = paramFolio;
	END IF;
ELSE
	LET vresult = 0;
	LET vmensaje = 'NO SE PUEDE CERRAR LA LIQUIDACION, EL DIA YA ESTA CERRADO.';	
END IF;

RETURN 	vresult,vmensaje,vimptot;
END PROCEDURE; 

select	edo_dlcob, sum(imp_dlcob)
from	det_lcob 
where	fliq_dlcob = 63589     
group by edo_dlcob

select	tpm_mcxc, sum(imp_mcxc)
from	mov_cxc
where	fliq_mcxc = '63589' and sta_mcxc = 'A'
group by tpm_mcxc

select	ffac_mcxc, sum(imp_mcxc)
from	mov_cxc
where	fliq_mcxc = '63579'            --and sta_mcxc = 'A'
group by ffac_mcxc

select	sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc = '2022-04-21' and tpm_mcxc in('08')   --35624
group by tpm_mcxc

select	sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc = '2023-01-31'  

select	rowid,*
from	mov_cxc --where fec_mcxc >= '2022-04-21' and sta_mcxc = 'A' and tip_mcxc = '01' and tpm_mcxc = '60' and doc_mcxc = 8680 and cte_mcxc = '074664'
where	fliq_mcxc = 63589 and ffac_mcxc = 1095882 imp_mcxc < .10    ffac_mcxc in(60247) and pla_mcxc = '40' and num_mcxc = 2

delete
from	mov_cxc
where 	rowid = 135954962

update	mov_cxc
set		tpm_mcxc = '58', fec_mcxc = '2023-01-31'
where	fliq_mcxc = 15040  and tpm_mcxc = '58' and pla_mcxc = '03' and num_mcxc = 2 and doc_mcxc = 414209 and ffac_mcxc in(30346) and pla_mcxc = '91' and num_mcxc = 2

select	*
from	liq_cob --where fec_lcob = '2023-01-31' order by fliq_lcob
where   fliq_lcob = 63589

update	liq_cob
set		impf_lcob = 824971.15, impt_lcob =824971.15--= fec_lcob = '2022-09-28'--emp_lcob = 'C26'--impc_lcob = 90744.74, impt_lcob = 90744.74--,edo_lcob = 'P', fec_lcob = '2022-06-23'impf_lcob = 16020.03, 
where   fliq_lcob = 63589 

select	*
from	det_lcob --where fec_dlcob = '2022-07-14' and imp_dlcob = 0
where	fliq_dlcob in(60396) and fol_dlcob in(1074640,1078612)

SELECT	fom_dlcob, fol_dlcob, ser_dlcob, count(*)
FROM	det_lcob 
WHERE	fliq_dlcob in(60396) 
GROUP BY 1,2,3
HAVING   COUNT(*) > 1

order by imp_dlcob

delete
from	det_lcob
where	fliq_dlcob = 26321 and num_dlcob in(12,13)

update	det_lcob
set		fol_dlcob = 71427, salini_dlcob = 352.47, salfin_dlcob = 252.47, imp_dlcob = 100--fol_dlcob = 499412, salini_dlcob = 2230.77, salfin_dlcob = 1546.17 --imp_dlcob = 210.72, salini_dlcob = 210.72, salfin_dlcob = 0.00-- fom_dlcob = 'F', imp_dlcob = 1356.43, salini_dlcob = 1356.43, salfin_dlcob = 0.00, fec_lcob = '2022-06-23'
where	 fliq_dlcob = 60396 and num_dlcob in(3) 

insert into det_lcob
values(48779,43,'F','00',511304, null, 'EAA', '15','01','C',13488.84, '2023-01-09',4,null,null,null,null,'1',13488.84,0.00,1,null,null,'2023-01-01',null)


update	det_lcob
set		imp_dlcob = 0.00--fom_dlcob = 'F', tip_dlcob = '00'--fol_dlcob  = 507367,imp_dlcob = 4.00 ,salini_dlcob = 3640.80, salfin_dlcob = 3636.80 --salfin_dlcob = 1012.14, salini_dlcob = 1512.14--imp_dlcob = 1679.45, salini_dlcob = 1993.20, salfin_dlcob = 313.75
where	fliq_dlcob = 48779  and num_dlcob  in(43)
		
select  fliq_dlcob ,fol_dlcob, count(*)
from	det_lcob
where   fliq_dlcob in(select fliq_lcob from liq_cob where fec_lcob >= '2021-04-01' and tip_lcob = 'C')
group by fliq_dlcob ,fol_dlcob
having  count(*) > 1

select  *
from	liq_cob, det_lcob
where   fliq_dlcob  = fliq_lcob and fec_lcob >= '2022-03-01' and fec_dlcob > fec_lcob

select	*
from	liq_cob
where 	fec_lcob = '2022-12-28' and impt_lcob <> (select	sum(imp_mcxc)
		from	mov_cxc
		where	fliq_mcxc = fliq_lcob)

update	det_lcob
set		edo_dlcob = 'C', fec_dlcob = '2022-02-19', fecdep_dlcob = '2022-02-19',
		salini_dlcob = 13632.00, salfin_dlcob = 0.00, des_dlcob = '190222', numpag_dlcob = 1 -- imp_dlcob = 331.77, salfin_dlcob = 13686.93
where	fliq_dlcob = 35630  and num_dlcob = 7

select	saldo_cte, abono_cte, cargo_cte, fecuab_cte, * 
from	cliente
where   num_cte = '163142'

update  cliente
set		saldo_cte = 3000.28, abono_cte = 791746.06
where   num_cte = '045935'

select	*
from	factura
where	fol_fac in (26962,26963) and ser_fac = 'EABC'

select	*
from	det_fac
where	fol_dfac in (61858) and ser_dfac = 'EABC'

SELECT 	*
FROM 	contrare 
WHERE 	fol_ctra = 27553 AND ser_ctra = 'EABC' 

SELECT  *
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '24' AND sta_doc = 'A' AND ffac_doc = 225616  AND sfac_doc = 'EAT'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')
		
SELECT  *
FROM 	mov_cxc 
WHERE   cia_mcxc = '15' AND pla_mcxc = '33' AND sta_mcxc = 'A' AND ffac_mcxc = 26484 AND sfac_mcxc = 'EABC'
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99')

SELECT  COUNT(unique fec_mcxc)
FROM	mov_cxc
WHERE	cia_mcxc = '15' AND pla_mcxc = '33' AND sta_mcxc = 'A' AND ffac_mcxc = 25390 AND sfac_mcxc = 'EABC'
		AND (tip_mcxc = '01' OR tip_mcxc >= '11' AND tip_mcxc <= '99')
		AND tpm_mcxc BETWEEN '50' AND '63' AND tpm_mcxc <> '52';

update	doctos
set     abo_doc = 602.49, sal_doc = 14.31--vuelta_doc = 12, tip_doc = '22'--,fult_doc = '2022-09-08'
where	fol_doc in(414209) and tip_doc = '01' and pla_doc = '17' AND vuelta_doc = 2 

insert into mov_cxc
select	cte_doc, '01','01', fol_doc,ffis_doc,ser_doc,cia_doc,pla_doc,ffac_doc,sfac_doc,1,sta_doc,tpa_doc,uso_doc, car_doc,
		femi_doc, femi_doc, fven_doc,'APLXSYS','pueblito',0,vuelta_doc
from	doctos
where 	fol_doc in(282763,282881,281872,281873,281735,281742,281743,281744,281746,281816,277960,277961,277962,277963,277964,281747,
	281757,281758,280935,281769,276903,276908,276909,276910,280964,280965,280966,280967,280968,276912,276913,276914,276915,276916,
	276917,276918,276919,276943,276944,276945,276946,276947,276948,283076,283096,283097,283121,283122,283123,283124,261985,261986,
	271910,284872,278090,276235,276236,282789,282963)  
	and pla_doc = '02' and tip_doc = '01' and vuelta_doc = 13

select	rowid, *
from	doctos
where 	fol_doc in(414209)  
	and pla_doc = '76' and tip_doc = '01' and vuelta_doc = 22 and cte_doc = '063606' 

select	rowid, *
from	mov_cxc
--where	tpm_mcxc = '56' and fec_mcxc >= '2022-03-01'
where	doc_mcxc in(322319) 
				and pla_mcxc= '21' and tip_mcxc = '01' and vuelta_mcxc = 22 and cte_mcxc = '021636' and tpm_mcxc = '50'
where   ffac_mcxc =63303 and sfac_mcxc = 'EAPG' doc_mcxc in (703406) 
	and pla_mcxc = '02' and tip_mcxc = '01' and num_mcxc = 2 and cte_mcxc = '035331'
	
select	rowid, *
from	mov_cxcbaj

delete
from	mov_cxc
where	rowid = 143753731

update	mov_cxc 
set		tip_mcxc = '01', vuelta_mcxc = 5--tip_mcxc = '22', vuelta_mcxc = 12--,fliq_mcxc = null cte_mcxc = '140819'--fec_mcxc = '2022-10-03'--vuelta_mcxc = 12--tip_mcxc = '21'
where   doc_mcxc in(239385,191880) 
		and pla_mcxc= '20' and tip_mcxc = '01' and vuelta_mcxc = 0

SELECT  fol_doc, cia_doc, pla_doc, tip_doc, sal_doc
FROM 	doctos 
WHERE   cia_doc = '15' AND pla_doc = '33' AND sta_doc = 'A' AND ffac_doc = 24896 AND sfac_doc = 'EABC'
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0.00

INSERT INTO mov_cxc
VALUES('278401','58','01',269155,null,' ','15','02',1076321,'EAB' ,2,'A','C',5,187.85,'2022-11-08','2022-11-09','2022-11-12','AxF1076321EAB1','pueblito',62758,13);

update doctos
set		abo_doc = 602.49, sal_doc = tip_doc = '22', vuelta_doc = 12 --abo_doc = 0.00, sal_doc = 3459.12, fult_doc = '2022-09-26'
where 	rowid in(3449607) 
		and tip_doc = '01' and cte_doc = '063606' and pla_doc = '24'

SELECT	fol_dlcob, imp_dlcob, (SELECT   SUM(sal_doc) 
								FROM 	doctos 
								WHERE   cia_doc = '15' AND pla_doc = '33' AND sta_doc = 'A' AND ffac_doc = 25410 AND sfac_doc = 'EABC'
										AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')) saldo
FROM	det_lcob
WHERE   tip_dlcob = '00' and fom_dlcob = 'F' and edo_dlcob not in('P','R') 
        and imp_dlcob > (SELECT  SUM(sal_doc) 
						FROM 	doctos 
						WHERE   cia_doc = '15' AND pla_doc = '33' AND sta_doc = 'A' AND ffac_doc = 25410 AND sfac_doc = 'EABC'
								AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99'))
        and fliq_dlcob = 44963
        
select	*
from	empleado
where	cve_emp in('1000','9999','0026','0032')

select	rowid,*
from	mov_cxc --where rowid = 128975880
where	fec_mcxc >= '2022-08-01' and  tpm_mcxc = '56' 
order by fec_mcxc desc

select	sum(imp_mcxc)
from	mov_cxc
where	tpm_mcxc not in ('01','03') and fec_mcxc between '2022-03-01' and '2022-03-10'

select	*
from	doctos
where	femi_doc = '2022-08-04' and tpa_doc in('C','G')
order by fol_doc, pla_doc

select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-01-07' and edo_nvta in('A') and tpa_nvta in('C','G') and pla_nvta = '88'

select	sum(car_doc)
from	doctos
where	femi_doc = '2023-01-07' and tpa_doc in('C','G') and sta_doc = 'A' and pla_doc = '88'

select	sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc = '2023-01-07' and tpa_mcxc in('C','G') and sta_mcxc = 'A' and tpm_mcxc = '01'

select	tpm_mcxc, desc_mcxc, tip_mcxc, doc_mcxc, ser_mcxc, cia_mcxc, pla_mcxc, imp_mcxc, num_cte, razsoc_cte, ape_cte, nom_cte
from	mov_cxc, cliente
where	cte_mcxc = num_cte and fec_mcxc = '2022-04-21' and tpa_mcxc in('C','G') and sta_mcxc = 'A' and tpm_mcxc = '01'

select	*
from	nota_vta
where	fes_nvta = '2022-06-15' and edo_nvta in('A') and tpa_nvta in('C','G')
order by pla_nvta, fol_nvta

select	*
from	doctos 
where	femi_doc = '2022-09-23' and tpa_doc in('C','G') and sta_doc = 'A' and pla_doc = '88'
order by pla_doc, fol_doc

select	*
from	nota_vta
where	fes_nvta = '2022-10-15' and edo_nvta in('A') and tpa_nvta in('C','G')
		and pla_nvta || fol_nvta not in(select	pla_doc || fol_doc
						from	doctos
						where	femi_doc = '2022-10-15' and tpa_doc in('C','G') and sta_doc = 'A')

select	sum(impt_nvta)
from	nota_vta
where	fes_nvta = '2023-01-07' and edo_nvta in('A') and tpa_nvta in('C','G')	
					
select	sum(car_doc)
from	doctos
where	femi_doc = '2023-01-07' and tpa_doc in('C','G') and sta_doc = 'A'

select	*
from	doctos
where	femi_doc = '2022-11-16' and tpa_doc in('C','G') and sta_doc = 'A' and car_doc = 634.80 and pla_doc = '88' and cte_doc = '000377'

select	sum(imp_mcxc)
from	mov_cxc
where	fec_mcxc = '2023-01-07' and tpa_mcxc in('C','G') and sta_mcxc = 'A' and tpm_mcxc = '01'

select	fol_doc
from	doctos
where	femi_doc = '2022-11-08' and tpa_doc in('C','G') and sta_doc = 'A'
		and fol_doc not in (select	doc_mcxc
						from	mov_cxc
						where	fec_mcxc = '2022-11-08' and tpa_mcxc in('C','G') and sta_mcxc = 'A' and tpm_mcxc = '01')
select	fol_doc
from	doctos
where	femi_doc between '2020-05-01' and '2020-08-31' and tpa_doc in('C','G') and sta_doc = 'A' and tip_doc = '01'
		and fol_doc not in (select	 doc_mcxc
						from	mov_cxc
						where	fec_mcxc between '2020-05-01' and '2020-08-31' and tpa_mcxc in('C','G') and sta_mcxc = 'A'
						 and tpm_mcxc = '01' and tip_mcxc = '01' and pla_mcxc = pla_doc)	 			

						
select  *
from	doctos, mov_cxc
where	cte_doc = cte_mcxc and fol_doc = doc_mcxc and tip_doc = '01' and tip_mcxc = '21'
		and pla_doc = '02' and pla_mcxc = '02' and femi_doc = fec_mcxc and car_doc = imp_mcxc
order by fol_doc		

select	rowid,*
from	lcob_enuso

delete from	lcob_enuso
where rowid = 257

insert into lcob_enuso values(60388,'2022-10-19 16:31','fuente')

update	lcob_enuso
set		usr_lenuso = 'fuente'
where rowid = 257

select	rowid,*
from	mov_cxc 
where	rowid in(130656011,130656778,130656779,131006730,132376844)

select	count(*)
from	mov_cxc
where	tpa_mcxc in('C','G') and sta_mcxc = 'A' 
		and tip_mcxc = '01'
		and doc_mcxc in(select fol_doc from doctos 
			where fol_doc = doc_mcxc and cte_doc = cte_mcxc 
							and tip_doc = '21' 
							and pla_doc = pla_mcxc)
		and pla_mcxc = '02'
		
update	mov_cxc
set		tip_mcxc = '21'
where	rowid = 134303242

select	count(*)
from	mov_cxc
where	tpa_mcxc in('C','G') and sta_mcxc = 'A' 
and tip_mcxc = '01'
and doc_mcxc in(select fol_doc from doctos 
where fol_doc = doc_mcxc 
	and cte_doc = cte_mcxc 	
	and tip_doc = '21' 
	and pla_doc = pla_mcxc)
and pla_mcxc = '02'
and fec_mcxc > '2021-12-31' and fec_mcxc <= '2022-04-30'

select	rowid,*
from	mov_cxc where fliq_mcxc = 0 and fec_mcxc >= '2022-01-01'
where 	doc_mcxc in (7254,7255,5888,8045,8164,8165,8166,8168,8169,8170,2629,2630,2631,2632,2633,2634,2640,2647,2654,2552,2554,9364,
				4481,4482,8302,8303,8056,8057,8161)
		and pla_mcxc = '02'
		and tpa_mcxc in('C','G') 
		and sta_mcxc = 'A' 
		and tip_mcxc = '01'
where	rowid in(134092303,134590482)

delete
from	mov_cxc
where	rowid = 25896971

update mov_cxc
set		fliq_mcxc = null
where	doc_mcxc in (282763,282881,281872,281873,281735,281742,281743,281744,281746,281816,277960,277961,277962,277963,277964,281747,
	281757,281758,280935,281769,276903,276908,276909,276910,280964,280965,280966,280967,280968,276912,276913,276914,276915,276916,
	276917,276918,276919,276943,276944,276945,276946,276947,276948,283076,283096,283097,283121,283122,283123,283124,261985,261986,
	271910,284872,278090,276235,276236,282789,282963)
		and pla_mcxc = '02'
		and tpa_mcxc in('C','G') 
		and sta_mcxc = 'A' 
		and tip_mcxc = '01'
		and num_mcxc = 1
		and vuelta_mcxc = 13
		and fec_mcxc <= '2021-12-31'
		
select	rowid,*
from	mov_cxc
where	doc_mcxc in (940556 )
		and pla_mcxc = '02'
		and tpa_mcxc in('C','G') 
		and sta_mcxc = 'A' 
		and tip_mcxc = '01'
		and fec_mcxc <= '2021-12-31'
order by fec_mcxc desc

select	*
from	mov_cxc
where	pla_mcxc = '02'
		and tpa_mcxc in('C','G') 
		and sta_mcxc = 'A' 
		and tip_mcxc = '21'
		and num_mcxc = 3
order by fec_mcxc desc

select	*
from	doctos --where tip_doc =  '11'
where	fol_doc in(262041 )
		and pla_doc = '09' and tip_doc = '01'

update	doctos
set		vuelta_doc = 1
where	fol_doc in(262059,262065,262041,262046,250561,261863,262036,262037,262759,263156,263158,251144,261845,262027,257161,257162,
		257163,261939,261940,261941,261942,261943,261944,261948,261951,261952,261953,261954,261955,261956,261957,261965,261966,
		261967,261968,261969,261970,261972,261979,261980,261981,261982,261988,261994,261995,261996,261848,261849,261862,261880,
		261882,261884,261886) and vuelta_doc  = 13
		and pla_doc = '02' and tip_doc = '01'

select	rowid,*
from	mov_cxc --where imp_mcxc = 354.54 and fec_mcxc >= '2022-01-01' and tip_mcxc = '01' and ffac_mcxc = 1037761
where	doc_mcxc in(501369)
		and pla_mcxc = '03' and tip_mcxc = '01'
		
update	mov_cxc 
set		vuelta_mcxc = 1--tpm_mcxc = '51', fec_mcxc = '2022-08-31'--, tip_mcxc = '21'
where   rowid in(104453391) 
				
delete
from	mov_cxc
where	rowid = 5610001
	
select	*
from	doctos
where	fol_doc in (570370) and tip_doc = '01' and pla_doc = '08'
order by femi_doc desc

select	*
from	mov_cxc m
where	m.tip_mcxc = '01'  
		and m.pla_mcxc = '02' and m.num_mcxc > 1
		and m.doc_mcxc 
		in(select doc_mcxc 
		from mov_cxc 
		where pla_mcxc = m.pla_mcxc 
		and cte_mcxc = m.cte_mcxc 
		and tip_mcxc = '21' 
		and num_mcxc = 1
		and fven_mcxc = m.fven_mcxc)


		
select	*
from	datos

update	datos
set		numlcob_dat =  29804
where	cia_dat = '15'

   SELECT cte_mcxc,doc_mcxc,ser_mcxc,cia_mcxc,pla_mcxc,tip_mcxc,MIN(fec_mcxc)
      FROM mov_cxc
      WHERE cte_mcxc MATCHES '000486'
        AND fec_mcxc >= '2022-06-01'
        AND fec_mcxc <= '2022-06-23'
        AND cia_mcxc MATCHES '15'
        AND pla_mcxc MATCHES '44'
        AND tpa_mcxc MATCHES 'C'
        AND sta_mcxc = 'A'
      GROUP BY 1,2,3,4,5,6 
      ORDER BY 1,7,2,3,4 
      
         SELECT cte_mcxc,ffac_mcxc doc_mcxc,sfac_mcxc ser_mcxc,
      cia_mcxc,pla_mcxc,tip_mcxc,MIN(fec_mcxc), 'F'
      FROM mov_cxc
      WHERE cte_mcxc MATCHES '000486'
        AND fec_mcxc >= '2022-06-01'
        AND fec_mcxc <= '2022-06-23'
        AND cia_mcxc MATCHES '15'
        AND pla_mcxc MATCHES '44'
        AND tpa_mcxc MATCHES 'C'
        AND sta_mcxc = 'A'
        AND ffac_mcxc IS NOT NULL
      GROUP BY 1,2,3,4,5,6,8
   UNION
   SELECT cte_mcxc,doc_mcxc,ser_mcxc,cia_mcxc,pla_mcxc,
      tip_mcxc,MIN(fec_mcxc), 'N'
      FROM mov_cxc 
      WHERE cte_mcxc MATCHES '000486'
        AND fec_mcxc >= '2022-06-01'
        AND fec_mcxc <= '2022-06-23'
        AND cia_mcxc MATCHES '15'
        AND pla_mcxc MATCHES '44'
        AND tpa_mcxc MATCHES 'C'
        AND sta_mcxc = 'A'
        AND ffac_mcxc IS NULL
   GROUP BY 1,2,3,4,5,6,8
   ORDER BY 1,7,2,3,4,5

SELECT  fol_doc,ser_doc,cia_doc,pla_doc, fec_ched, 
    SUM(sal_doc) saldo,MAX(femi_doc), MAX(num_cte) numcte, MAX(ape_cte) apecte, MAX(nom_cte) nomcte, 
    MAX(razsoc_cte)  raszoc                                                
FROM doctos, det_ched, che_dev, cliente
WHERE  fliq_ched = fliq_dched and cte_dched = num_cte AND fol_dched = fol_doc and ser_dched = ser_doc and
    sta_doc = 'A' AND fol_doc = 2010 AND ser_doc = '' AND cte_doc = '000486' AND cte_dched = '000486'
    AND cia_doc = '15' AND pla_doc = '09' AND sal_doc > 0
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2


select	*
from	doctos d
where	d.vuelta_doc = 1 and sal_doc > 0
		and d.fol_doc in(select doc_mcxc from mov_cxc where doc_mcxc = d.fol_doc and pla_mcxc = d.pla_doc 
						and cte_mcxc = d.cte_doc and num_mcxc = 1 and imp_mcxc = d.car_doc and vuelta_mcxc = 2)
						
select *
from	liq_cob 
where	fliq_lcob = 66356

select	*
from	mov_cxc
where 	ffac_mcxc in(select	fol_dlcob from det_lcob where |) and sfac_mcxc = 'EAB'

select	*
from	det_lcob 
where 	fliq_dlcob = 62758 and pla_dlcob = '02'
		and fol_dlcob in
		(select ffac_mcxc from mov_cxc where cia_mcxc = '15' and pla_mcxc = '02' and fliq_mcxc = 62758 and  tpm_mcxc = '58')


select	*
from	det_lcob 
where   fliq_dlcob = 62758 and num_dlcob in(7,13,14,15,21,22,23,24,25,27,31,32,33,34,35,46,47,53,66.69,74,75)
		and pla_dlcob = '02'
		
select	count(*)
from	doctos
where 	vuelta_doc = 22 and tip_doc ='01' and pla_doc = '02'

update	doctos
set		tip_doc = '22', vuelta_doc = 12
where 	vuelta_doc = 22 
		and tip_doc ='01' 
		and pla_doc = '02'

select	count(*)
from	mov_cxc
where	tip_mcxc = '01' and vuelta_mcxc = 22 and pla_mcxc = '02'

update  mov_cxc
set		tip_mcxc = '22', vuelta_mcxc = 12
where	pla_mcxc = '02' 
		and tip_mcxc = '01' 
		and vuelta_mcxc = 22
		
select 	*
from	mov_cxc
where   tpm_mcxc > '49' and fec_mcxc = '2022-11-01'

select	*
from	liq_cob l, det_lcob dl, factura f, cliente c
where   l.fliq_lcob = dl.fliq_dlcob and dl.fol_dlcob = f.fol_fac 
		and dl.ser_dlcob = f.ser_fac and f.numcte_fac = c.num_cte
		and l.edo_lcob = 'C'
		and dl.edo_dlcob not in('P','R') and dl.fec_dlcob >= '2017-01-01' 
		and c.num_cte = '035085'
		
select	*
from	liq_cob
where	emp_lcob not in(select cve_emp from empleado)

update	liq_cob
set		emp_lcob = '0309'
where	fliq_lcob in(10247)
		
select	*
from	empleado where cve_emp = '0351'
order by cve_emp
from