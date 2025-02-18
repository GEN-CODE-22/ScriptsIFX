DROP PROCEDURE LiqCob_ANT;
EXECUTE PROCEDURE  LiqCob_ANT(0,'2022-01-14','0009','011516','fuente');

CREATE PROCEDURE LiqCob_ANT
(
    paramFolliq     INT,       -- Folio de liquidaciÃ³n (0 para generar uno nuevo)
    paramFecha      DATE,      -- Fecha de la operaciÃ³n
    paramEmp        CHAR(5),   -- CÃ³digo de la empresa
    paramCte        CHAR(6),   -- CÃ³digo del cliente
    paramCia        CHAR(2),   -- CompaÃ±Ã­a para filtrar documentos
    paramPla        CHAR(2),   -- Planta para filtrar documentos
    paramUsr        CHAR(8)    -- Usuario que realiza la operaciÃ³n
)

RETURNING  
 INT,         -- Resultado (1 = OK, 0 = Error)
 INT,         -- Folio de liquidaciÃ³n generado
 CHAR(100),   -- Mensaje de error
 DECIMAL;     -- Total aplicado

DEFINE vresult  INT;
DEFINE vmensaje CHAR(100);
DEFINE vmsg     CHAR(100);
DEFINE vproceso INT;
DEFINE vfolliq  INT;
DEFINE vsalcte  DECIMAL;
DEFINE vimptot  DECIMAL;
DEFINE vnum     INT;
DEFINE vdesc    CHAR(20);
DEFINE vsaldo   DECIMAL;
DEFINE vsalfin  DECIMAL;
DEFINE vfolant  INT;
DEFINE vserant  CHAR(4);
DEFINE vaboant  DECIMAL;
DEFINE vsalant  DECIMAL;
DEFINE vfecant  DATE;
DEFINE vdescant CHAR(20);
DEFINE vimpliq  DECIMAL;
DEFINE vimpmov  DECIMAL;
DEFINE vimppag  DECIMAL;
DEFINE vfoldoc  INT;
DEFINE vsaldoc  DECIMAL;
DEFINE vciaant  CHAR(2);
DEFINE vplaant  CHAR(2);
DEFINE vciadoc  CHAR(2);
DEFINE vpladoc  CHAR(2);
DEFINE vtipdoc  CHAR(2);
DEFINE vdescdoc CHAR(20);
DEFINE vtpadoc  CHAR(1);
DEFINE vusodoc  CHAR(1);
DEFINE vmovant  INT;
DEFINE vvuelta  INT;

LET vresult = 1;
LET vproceso = 1;
LET vfolliq = 0;
LET vmensaje = 'OK';
LET vimptot = 0;
LET vimpliq = 0;
LET vnum = 1;

-- Verifica si la fecha no estÃ¡ cerrada
IF NOT EXISTS(SELECT 1 FROM e_posaj e WHERE e.epo_fec = paramFecha) THEN   

    -- Si paramFolliq es 0, se genera un nuevo folio de liquidaciÃ³n
    IF paramFolliq = 0 AND vresult = 1 THEN
        -- Obtiene el monto total de anticipos del cliente (sin filtrar por compaÃ±Ã­a o planta)
        SELECT SUM(abo_ant)
        INTO vimpliq
        FROM anticipo 
        WHERE cte_ant = paramCte;

        IF vimpliq > 0 THEN
            -- Obtiene el saldo pendiente del cliente para la compaÃ±Ã­a y planta especificadas
            SELECT SUM(sal_doc)
            INTO vsalcte
            FROM doctos 
            WHERE cte_doc = paramCte 
                  AND cia_doc = paramCia 
                  AND pla_doc = paramPla 
                  AND sta_doc = 'A' 
                  AND (ffac_doc IS NULL OR ffac_doc = '') 
                  AND (sfac_doc IS NULL OR sfac_doc = '')
                  AND (tip_doc = '01' OR (tip_doc >= '11' AND tip_doc <= '99'));

            IF vimpliq >= vsalcte AND vsalcte > 0 THEN
                -- Genera un nuevo folio de liquidaciÃ³n
                LET vfolliq = GETVAL_EX_MODE(null, null, null, 'numlcob_dat');
                IF vfolliq > 0 THEN        
                    -- Inserta el registro en la tabla liq_cob
                    INSERT INTO liq_cob
                    VALUES(vfolliq, paramEmp, paramFecha, 'C', 0.00, 0.00, 0.00, 0.00, 0.00, paramUsr, null, 0, 0, 0.00, CURRENT, 'A');

                    -- Recorre los anticipos del cliente (sin filtrar por compaÃ±Ã­a o planta)
                    FOREACH cAnticipos FOR
                        SELECT cia_ant, pla_ant, fol_ant, ser_ant, abo_ant, sal_ant, fven_ant
                        INTO vciaant, vplaant, vfolant, vserant, vaboant, vsalant, vfecant
                        FROM anticipo 
                        WHERE cte_ant = paramCte AND abo_ant > 0

                        -- Inserta el registro en la tabla relacion_cfd
                        INSERT INTO relacion_cfd VALUES('07', vfolliq, 'ANT', vfolant, vserant, '');

                        -- Recorre los documentos del cliente para la compaÃ±Ã­a y planta especificadas
                        FOREACH cDoctos FOR
                            SELECT fol_doc, cia_doc, pla_doc, tip_doc, sal_doc, tpa_doc, uso_doc, vuelta_doc
                            INTO vfoldoc, vciadoc, vpladoc, vtipdoc, vsaldoc, vtpadoc, vusodoc, vvuelta
                            FROM doctos 
                            WHERE cte_doc = paramCte 
                                  AND cia_doc = paramCia 
                                  AND pla_doc = paramPla 
                                  AND sta_doc = 'A' 
                                  AND (ffac_doc IS NULL OR ffac_doc = '') 
                                  AND (sfac_doc IS NULL OR sfac_doc = '')
                                  AND (tip_doc = '01' OR (tip_doc >= '11' AND tip_doc <= '99'))
                                  AND sal_doc > 0.00

                            IF vproceso = 1 AND vaboant > 0 THEN
                                -- Calcula el monto a aplicar
                                IF vaboant > vsaldoc THEN
                                    LET vimpmov = vsaldoc;
                                ELSE
                                    LET vimpmov = vaboant;
                                END IF;                        

                                -- Inserta el detalle en la tabla det_lcob
                                LET vdesc = 'AN:' || vfoldoc;
                                LET vsalfin = vsaldoc - vimpmov;
                                INSERT INTO det_lcob
                                VALUES(vfolliq, vnum, 'A', vtipdoc, vfoldoc, null, '', vciadoc, vpladoc, 'A', vimpmov, paramFecha, null, null, null, null, null, vdesc, vsaldoc, vsalfin, 1, null, null, paramFecha, vvuelta);
                                LET vnum = vnum + 1;    

                                -- Aplica el pago al documento
                                LET vdescdoc = 'AN:08' || vciaant || vplaant || LPAD(vfolant, 7, '0') || vserant;
                                LET vproceso, vmsg, vimppag, vsaldo = LiqCob_PagoDoc(vfolliq, vfoldoc, vciadoc, vpladoc, vtipdoc, '55', vimpmov, paramFecha, vdescdoc, paramUsr, vvuelta, '');
                                IF vproceso = 1 THEN
                                    LET vaboant = vaboant - vimppag;
                                    LET vimptot = vimptot + vimppag;

                                    -- Actualiza el anticipo
                                    UPDATE anticipo
                                    SET abo_ant = abo_ant - vimppag, sal_ant = sal_ant + vimppag, fult_ant = TODAY
                                    WHERE cte_ant = paramCte AND fol_ant = vfolant AND ser_ant = vserant;    

                                    -- Inserta el movimiento en la tabla mov_ant
                                    SELECT MAX(num_mant)
                                    INTO vmovant
                                    FROM mov_ant
                                    WHERE cte_mant = paramCte AND doc_mant = vfolant AND ser_mant = vserant;

                                    LET vmovant = vmovant + 1;
                                    LET vdescant = 'DO:01' || vciadoc || vpladoc || LPAD(vfoldoc, 7, '0');
                                    LET vimppag = vimppag * -1;
                                    INSERT INTO mov_ant
                                    VALUES(paramCte, '99', '08', vfolant, null, vserant, vciadoc, vpladoc, null, null, vmovant, 'A', vtpadoc, vusodoc, vimppag, paramFecha, TODAY, vfecant, vdescant, paramUsr, vfolliq);            
                                ELSE
                                    LET vproceso = 0;
                                    LET vmensaje = 'ERROR AL PROCESAR: ' || vmsg;            
                                END IF;    
                            END IF;    
                        END FOREACH;                    
                    END FOREACH;

                    -- Actualiza el total aplicado en la tabla liq_cob
                    UPDATE liq_cob
                    SET impc_lcob = vimptot, impt_lcob = vimptot
                    WHERE fliq_lcob = vfolliq;

                    -- Genera la factura y nota de crÃ©dito
                    LET vproceso, vmensaje = ant_factnc(vfolliq, paramFecha, vfolant, vserant, paramUsr); 
                    IF vproceso = 0 THEN
                        LET vresult = 0;
                        LET vmensaje = 'ERROR AL GENERAR FACTURA Y NOTA DE CREDITO';
                        RETURN vresult, 0, vmensaje, 0;
                    END IF;
                ELSE
                    LET vresult = 0;
                    LET vmensaje = 'ERROR AL OBTENER EL FOLIO DE LA LIQUIDACION';
                END IF;
            ELSE
                LET vresult = 0;
                LET vmensaje = 'EL SALDO DEL CLIENTE ES MAYOR AL ANTICIPO O NO HAY DOCUMENTOS';
            END IF;        
        ELSE
            LET vresult = 0;
            LET vmensaje = 'EL CLIENTE NO TIENE SALDO EN ANTICIPOS';
        END IF;
    ELSE
        LET vfolliq = paramFolliq;
    END IF;
ELSE
    LET vresult = 0;
    LET vmensaje = 'NO SE PUEDE APLICAR EL ANTICIPO, EL DIA YA ESTA CERRADO.';    
END IF;

LET vmensaje = TRIM(vmensaje);
RETURN vresult, vfolliq, vmensaje, vimptot;
END PROCEDURE;


SELECT  pla_doc
FROM 	doctos 
WHERE   cte_doc = '038571' AND sta_doc = 'A' AND (ffac_doc IS NULL OR ffac_doc = '') AND (sfac_doc IS NULL OR sfac_doc = '')		
	AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') and sal_doc > 0
GROUP BY pla_doc

SELECT  *
FROM 	doctos 
WHERE   cte_doc = '038571' AND sta_doc = 'A' AND (ffac_doc IS NULL OR ffac_doc = '') AND (sfac_doc IS NULL OR sfac_doc = '')		
	AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') and sal_doc > 0
	
update	doctos
set		ffac_doc = null, sfac_doc = null
where	fol_doc in(712920,712921,712922,712923,712924) and pla_doc = '69' and vuelta_doc = 1 and cte_doc = '038571'

select	*
from	datos

select	*
from	liq_cob 
where   fec_lcob >= '2024-12-06' and tip_lcob = 'A' order by fliq_lcob desc

-- SAN JOSE ITURBIDE 15403
select	*
from	liq_cob --order by fec_lcob desc
where	fliq_lcob in(28856)

delete
from	liq_cob --order by fec_lcob desc
where	fliq_lcob in(48037)

update	liq_cob --order by fec_lcob desc
set		fec_lcob = '2022-07-01'
where	fliq_lcob in(61730)

select	*
from	det_lcob 
where	fliq_dlcob in(28856)


delete
from	det_lcob 
where	fliq_dlcob in(48037)

update	det_lcob 
set		fecdep_dlcob = '2022-07-01'
where	fliq_dlcob in(61730)

select	saldo_cte, abono_cte, cargo_cte, fecuab_cte, * 
from	cliente
where   num_cte = '059208'

select	*
from	cliente
where	saldo_cte < 0
		
SELECT  SUM(sal_doc) 
FROM 	doctos 
WHERE   cte_doc = '008777' AND sta_doc = 'A' AND (ffac_doc IS NULL OR ffac_doc = '') AND (sfac_doc IS NULL OR sfac_doc = '')
			AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99')	

		
SELECT  *
FROM 	doctos where fol_doc in(539461) and cte_doc = '033781'
WHERE   cte_doc = '247537' AND sta_doc = 'A' --AND (ffac_doc IS NULL OR ffac_doc = '') AND (sfac_doc IS NULL OR sfac_doc = '')
			AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0.00

SELECT  *
FROM 	doctos where fol_doc in(887260,887261)
		 --and cte_doc = '078157'
WHERE   cte_doc = '033781' AND sta_doc = 'A' 
			AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0.00
			
update	doctos
set		abo_doc = 0.00, sal_doc = 427.68
where 	fol_doc in(033781) and cte_doc = '033781' and pla_doc = '09'

select	*
from	mov_cxc
where	fliq_mcxc = 28562 

select	*
from	mov_cxc --where tpm_mcxc = '55' and fec_mcxc >= '2021-01-31'
where 	doc_mcxc in(887260,887261) and cte_mcxc = '059208'

update	mov_cxc 
set		fec_mcxc = '2022-07-01', fer_mcxc = '2022-07-01'
where 	doc_mcxc in(77878,77879,77880,77881,77881,77882,77913,77914,77957,77958,77980,77981,77982,77983,77983,78818,78819,79365,
				79366,79367,79368,79773,80160,80161,80162,80651,80652,80653,80964,80965) and fliq_mcxc = 61730      and num_mcxc = 50

delete
from    mov_cxc
where 	doc_mcxc in(80691,80692,80731) and cte_mcxc = '000486' and num_mcxc >= 2

SELECT	*
FROM	anticipo 
WHERE	abo_ant > 0


SELECT	*--SUM(abo_ant)
FROM	anticipo 
WHERE	cte_ant = '079965'

select	*
from	anticipo --where fol_ant = 212731
where	cte_ant = '165079'

update	anticipo
set		abo_ant = 7126.13, sal_ant = -7126.13--fven_ant = '2022-11-11', fult_ant = '2022-11-11', femi_ant = '2022-11-11' --abo_ant = 60.01, sal_ant = -60.01
where	cte_ant = '165079' and fol_ant in (579320)	

select	f.ser_fac, f.fol_fac, cl.num_cte,f.fec_fac, f.uuid_fac, f.impt_fac, f.edo_fac, f.pago_fac, c.est_cfd,
            (select max(fliq_dlcob) from det_lcob where facpag_dlcob = f.fol_fac and serpag_dlcob = f.ser_fac),
            f.fant_fac , f.sant_fac, cl.razsoc_cte, cl.ape_cte, cl.nom_cte
from	factura f, cfd c, cliente cl
where   f.numcte_fac = cl.num_cte and f.tdoc_fac = 'I' and f.fec_fac >= '2022-04-20' and f.fec_fac <= '2022-04-30'		        
        and fant_fac in (select fol_fac from factura where tdoc_fac = 'A') 
        and f.fol_fac = c.fol_cfd and f.ser_fac = c.ser_cfd 
order by cl.num_cte desc

select	*
from	mov_ant where fec_mant >= '2025-02-10' and cte_mant = '079965' and doc_mant = '579320'
where	fliq_mant = 65290  

insert into mov_ant
values('000488','99','08',197616,null,'EAO','15','16', null, null, 2, 'A', 'C', '5', 1740.94, '2022-10-10', '2022-10-10', '2022-10-08', null, 'paulina',null)
    
SELECT distinct cia_dlcob, pla_dlcob,fol_dlcob,vuelta_dlcob
                    FROM det_lcob WHERE fliq_dlcob = 16084 and fom_dlcob = 'A' and tip_dlcob= '01'
                    
delete
from	mov_ant --where doc_mant = 323590
where	fliq_mant = 48037   and  doc_mant = 579320 and cte_mant = '165079' 

update	mov_ant
set		fec_mant = '2022-11-11', fer_mant = '2022-11-11', fven_mant = '2022-11-11'
where	 cte_mant = '017218' and  doc_mant = 18399 and num_mant in(1)

select	*
from	che_dev order by fec_ched desc
where	fliq_ched = 1318

insert into che_dev values(2109,'2022-12-06','C',0.00,0.00,30312.15,'yanet',null,'2023-12-06 13:25')

delete
from	che_dev
where 	fliq_ched = 2178
19025
update	che_dev	
set		fec_ched = '2024-02-02'--, edo_ched = 'P', impt_ched = 30312.15, usr_ched = 'yanet'
where	fliq_ched = 958

select	*
from	det_ched 
where	fliq_dched = 958

insert into det_ched values(1272,1,'03',1004,'AA','15','01','051543',1976.20)

update	det_ched
set		imp_dched = 3750.60
where	fliq_dched = 979

delete
from	det_ched 
where	fliq_dched = 931 

select	*
from	doctos
where	fol_doc = 44425 and tip_doc = '03' and ser_doc = 'DICD' and tip_doc = '03'

update	doctos
set		femi_doc  = '2024-02-02', fult_doc = '2024-02-02'
where	fol_doc = 44425 and ser_doc = 'EACA' and tip_doc = '03'


select	*
from	mov_cxc where doc_mcxc = 44425  and cte_mcxc = '003308'
where	fec_mcxc = '2022-02-17' and tpm_mcxc = '99'

update	mov_cxc
set		fec_mcxc = '2024-02-02'
where	doc_mcxc = 44425  and cte_mcxc = '003308'

SELECT  fol_doc, cia_doc, pla_doc, tip_doc, sal_doc, tpa_doc, uso_doc
FROM 	doctos 
WHERE   cte_doc = '000072' AND sta_doc = 'A' AND (ffac_doc IS NULL OR ffac_doc = '') 
		AND (sfac_doc IS NULL OR sfac_doc = '')AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') 
		AND sal_doc > 0.00
		
select	*
from	nota_vta
where	fol_nvta in(316950,316951,318102,318106,318103,318105,319351,319352,320372,320374,320377,318619,321552,321553,323860)

select	c.num_cte, c.nom_cte, c.ape_cte, c.razsoc_cte, c.dir_cte, c.col_cte, c.ciu_cte, sum(sal_ant), min(femi_ant), max(fult_ant) 
from	anticipo a , cliente c
where	a.cte_ant = c.num_cte and sta_ant = 'A' and sal_ant < 0
group by 1,2,3,4,5,6,7

select	c.num_cte, c.nom_cte, c.ape_cte, c.razsoc_cte, a.cia_ant, a.pla_ant, a.fol_ant, a.ser_ant, sal_ant, femi_ant, fult_ant
from	anticipo a , cliente c
where	a.cte_ant = c.num_cte and sta_ant = 'A' and sal_ant < 0

select	a.uso_ant, sum(sal_ant), min(femi_ant), max(fult_ant) 
from	anticipo a , cliente c
where	a.cte_ant = c.num_cte and sta_ant = 'A' and sal_ant < 0
group by 1

select	a.cia_ant, a.pla_ant, p.nom_pla, sum(sal_ant), min(femi_ant), max(fult_ant) 
from	anticipo a , cliente c, planta p
where	a.cte_ant = c.num_cte and a.cia_ant = p.cia_pla and  a.pla_ant = p.cve_pla and sta_ant = 'A' and sal_ant < 0
group by 1,2,3


select	*
from	mov_cxc
where	doc_mcxc = 557953

SELECT  pla_doc
FROM 	doctos 
WHERE   cte_doc = '105827' AND sta_doc = 'A' AND (ffac_doc IS NULL OR ffac_doc = '') AND (sfac_doc IS NULL OR sfac_doc = '')		
	AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0
GROUP BY pla_doc
LET vcpla = vcpla + 1;

SELECT  SUM(sal_doc) --SALDO DEL CLIENTE NO FACTURADO
	FROM 	doctos 
	WHERE   cte_doc = '105827' AND sta_doc = 'A' AND (ffac_doc IS NULL OR ffac_doc = '') AND (sfac_doc IS NULL OR sfac_doc = '')		
		AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99');

SELECT	SUM(abo_ant) -- SALDO ANTICIPOS
		FROM	anticipo 
		WHERE	cte_ant = '105827';

SELECT  pla_doc
		FROM 	doctos 
		WHERE   cte_doc = '165079' AND sta_doc = 'A' AND (ffac_doc IS NULL OR ffac_doc = '') AND (sfac_doc IS NULL OR sfac_doc = '')		
			AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0
		GROUP BY pla_doc
		
SELECT  *
		FROM 	doctos 
		WHERE   cte_doc = '165079'
				AND (ffac_doc IS NULL OR ffac_doc = '') AND (sfac_doc IS NULL OR sfac_doc = '')	
				AND (tip_doc = '01' OR tip_doc >= '11' AND tip_doc <= '99') AND sal_doc > 0