DROP PROCEDURE LiqChed_Cerrar;
EXECUTE PROCEDURE  LiqChed_Cerrar(2598, 'fuente');

CREATE PROCEDURE LiqChed_Cerrar
(
	paramFolio   	INT,
	paramUsr		CHAR(8)
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(500),		-- Mensaje error
 DECIMAL;		-- Total liquidacion
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(500);
DEFINE vfolliq 	INT;
DEFINE vnum 	INT;
DEFINE vnumc 	INT;
DEFINE vfecha 	DATE;
DEFINE vfechav 	DATE;
DEFINE vtipo 	CHAR(20);
DEFINE vuso 	CHAR(1);
DEFINE vfolio 	INT;
DEFINE vserie 	CHAR(4);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vnocte 	CHAR(6);
DEFINE vproceso INT;
DEFINE vmsg		CHAR(100);
DEFINE vdcre    SMALLINT;
DEFINE vimptot  DECIMAL;
DEFINE vimp 	DECIMAL;

LET vresult = 1;
LET vmensaje = '';
LET vimptot = 0;
LET vnumc = 0;

IF NOT EXISTS(SELECT 	1 
		  	FROM 	e_posaj e, che_dev c
		  	WHERE 	e.epo_fec = c.fec_ched AND c.fliq_ched = paramFolio) THEN
	IF NOT EXISTS(	SELECT	1
					FROM	det_ched d
					WHERE	fliq_dched = paramFolio 
							AND fol_dched in(SELECT fol_doc 
											FROM doctos 
											WHERE cia_doc = d.cia_dched AND pla_doc = d.pla_dched AND tip_doc = '03' 
												AND ser_doc = d.ser_dched))	THEN
		FOREACH cLiquidacion FOR
			SELECT	l.fliq_ched, l.fec_ched, d.num_dched, d.tip_dched, d.fol_dched,	NVL(d.ser_dched,''), 
					d.cia_dched, d.pla_dched, d.cte_dched, d.imp_dched
			INTO	vfolliq, vfecha, vnum, vtipo, vfolio, vserie, vcia, vpla, vnocte, vimp
			FROM	che_dev l, det_ched d
			WHERE	l.fliq_ched = d.fliq_dched
					AND l.fliq_ched = paramFolio
			
			LET vnumc = vnumc + 1;
			UPDATE	det_ched
			SET		num_dched = vnumc
			WHERE	fliq_dched = paramFolio and num_dched = vnum;
			
			IF vtipo = '03' AND vresult = 1 THEN
				--CHEQUE DEVUELTO-----------------------------------------------------------------------------------------------------------------
				SELECT	uso_cte, NVL(dcred_cte,0)
				INTO	vuso, vdcre
				FROM	cliente
				WHERE	num_cte = vnocte;
				
				LET vfechav = vfecha + vdcre;
				
				--INSERTA EN LA TABLA doctos---------------------------------------------------------------
				INSERT INTO doctos
				VALUES(vnocte,vtipo,vfolio,null,vserie,vcia,vpla,null,null,'A','C',vuso,vimp,0.00,vimp,vfechav,vfecha,vfecha,paramUsr,null);
				
				--INSERTA EN LA TABLA mov_cxc---------------------------------------------------------------
				INSERT INTO mov_cxc
				VALUES(vnocte,vtipo,vtipo,vfolio,null,vserie,vcia,vpla,null,null,1,'A','C',vuso,vimp,vfecha,TODAY,vfechav,null,paramUsr,null,null);
				
				LET vimptot = vimptot + vimp;
				
			END IF;
		END FOREACH;
	
		IF vresult = 1 THEN
			UPDATE	che_dev
			SET		edo_ched = 'C', impt_ched = vimptot
			WHERE	fliq_ched = paramFolio;
		END IF;
	ELSE
		LET vresult = 0;
		LET vmensaje = 'NO SE PUEDE CERRAR LA LIQUIDACION, HAY CHEQUES QUE YA EXISTEN. CAMBIE EL FOLIO O LA SERIE DEL CHEQUE';	
	END IF;
ELSE
	LET vresult = 0;
	LET vmensaje = 'NO SE PUEDE CERRAR LA LIQUIDACION, EL DIA YA ESTA CERRADO.';	
END IF;
RETURN 	vresult,vmensaje,vimptot;
END PROCEDURE; 

select	*
from	cliente 
where   num_cte = '077070'

delete
from	che_dev
where   fliq_ched = 2610 

select	*
from	che_dev --order by fec_ched desc
where	fliq_ched = 1289 

insert into che_dev values(1203,'2022-02-25','P',0.00,0.00,25000.00,'cristina',7448,'2022-02-26 09:54')

update	che_dev	
set		impt_ched = 755.42 --fec_ched = '2022-08-23'--,edo_ched = 'P', caj_ched = 2598
where	fliq_ched = 3621

select	*
from	det_ched --where fol_dched = 71168
where	fliq_dched in(2615)

update	det_ched
set		imp_dched = 755.42
where	fliq_dched in(3621)

delete
from	det_ched
where	fliq_dched in(2610)

insert into det_ched values(1203,1,'08',415460, 'EAI', '15','08','065546', 25000.00)


select	rowid,*
from	doctos where fol_doc in(2022) and tip_doc = '03'  and cte_doc = '077070'
delete from doctos where fol_doc in(1184) and tip_doc = '03' and cte_doc = '039904'

delete from doctos where rowid = 12236300
update doctos 
set		ser_doc = ''--car_doc = 755.42, sal_doc = 755.42--femi_doc = '2022-06-17', fult_doc = '2022-06-17', fven_doc = '2022-07-02'
where fol_doc in(876) and tip_doc = '11' and cte_doc = '001691'

select	*
from	mov_cxc where doc_mcxc in (876,877) and tip_mcxc = '03' and cte_mcxc = '234686'
where	fec_mcxc = '2022-02-17' and tpm_mcxc = '99'

delete from mov_cxc where doc_mcxc in (1184) and tip_mcxc = '03' and cte_mcxc = '039904'

update	mov_cxc
set		ser_mcxc = 'OLD'--imp_mcxc = 755.42--fec_mcxc = '2022-06-17', fven_mcxc = '2022-07-02'
where   doc_mcxc in (877) and tip_mcxc = '03' and cte_mcxc = '008904'

SELECT  fol_doc,ser_doc,cia_doc,pla_doc, fec_ched, 
		SUM(sal_doc) saldo,MAX(femi_doc), MAX(num_cte) numcte, MAX(ape_cte) apecte, MAX(nom_cte) nomcte, 
		MAX(razsoc_cte)  raszoc                                                
FROM doctos, det_ched, che_dev, cliente
WHERE  fliq_ched = fliq_dched and cte_dched = num_cte AND fol_dched = fol_doc and ser_dched = ser_doc and sta_doc = 'A' 
		AND fol_doc = 1006 AND ser_doc = 'BNM' AND cte_doc = '000486' AND cia_doc = '15' AND pla_doc = '09' AND sal_doc > 0
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2

SELECT  fol_doc,ser_doc,cia_doc,pla_doc, fec_ched, 
		SUM(sal_doc) saldo,MAX(femi_doc), MAX(num_cte) numcte, MAX(ape_cte) apecte, MAX(nom_cte) nomcte, 
		MAX(razsoc_cte)  raszoc                                                
FROM doctos, det_ched, che_dev, cliente
WHERE  fliq_ched = fliq_dched and cte_dched = num_cte AND fol_dched = fol_doc and ser_dched = ser_doc and sta_doc = 'A' 
		AND cte_doc = '000486' AND sal_doc > 0
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2

SELECT  fol_doc,ser_doc,cia_doc,pla_doc, fec_ched, 
	SUM(sal_doc) saldo,MAX(femi_doc), MAX(num_cte) numcte, MAX(ape_cte) apecte, MAX(nom_cte) nomcte, 
    MAX(razsoc_cte)  raszoc                                                
FROM doctos, det_ched, che_dev, cliente
WHERE  fliq_ched = fliq_dched and cte_dched = num_cte AND fol_dched = fol_doc and ser_dched = ser_doc and
    sta_doc = 'A' AND cte_doc = '000486' 
    AND cia_doc = '15' AND pla_doc = '09' AND sal_doc > 0
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2

select	dcred_cte,*
from	cliente
where	num_cte in('068375','039904')

select	tpm_mcxc, desc_mcxc, tip_mcxc, doc_mcxc, ser_mcxc, cia_mcxc, pla_mcxc, imp_mcxc, num_cte, 
        razsoc_cte, ape_cte, nom_cte
from	mov_cxc, cliente
where	cte_mcxc = num_cte and fec_mcxc = '2022-06-17' and tpa_mcxc in('C') and sta_mcxc = 'A'

SELECT  fol_doc,ser_doc,cia_doc,pla_doc, fec_ched, 
        SUM(sal_doc) saldo,MAX(femi_doc), MAX(num_cte) numcte, MAX(ape_cte) apecte, MAX(nom_cte) nomcte, 
        MAX(razsoc_cte)  raszoc                                                
FROM 	doctos, det_ched, che_dev, cliente
WHERE  fliq_ched = fliq_dched and cte_dched = num_cte AND fol_dched = fol_doc and ser_dched = ser_doc and
        sta_doc = 'A' AND fol_doc = 71168 AND ser_doc = '' AND cte_doc = '009431' AND cte_dched = '009431'
        AND cia_doc = '15' AND pla_doc = '85' AND tip_doc = '03' AND sal_doc > 0
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2

SELECT  fol_doc,ser_doc,cia_doc,pla_doc, fec_ched, 
        SUM(sal_doc) saldo,MAX(femi_doc), MAX(num_cte) numcte, MAX(ape_cte) apecte, MAX(nom_cte) nomcte, 
        MAX(razsoc_cte)  raszoc                                                
FROM doctos, det_ched, che_dev, cliente
WHERE  fliq_ched = fliq_dched and cte_dched = num_cte AND fol_dched = fol_doc and ser_dched = ser_doc and
        sta_doc = 'A' AND fol_doc = 71168 AND ser_doc = '' AND cte_doc = '009134' AND cte_dched = '009134'
        AND cia_doc = '15' AND pla_doc = '85' AND tip_doc = '03' AND sal_doc > 0
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2

SELECT 	1 
FROM 	e_posaj e, che_dev c
WHERE 	c.fliq_ched = 2612 AND e.epo_fec = c.fec_ched

select	*
from	doctos
where	cia_doc = '15' and pla_doc = '16' and fol_doc = 696 and ser_doc = 'INB'
		and tip_doc = '03'
		
select	1
from	doctos d
where	tip_doc = '03' and fol_doc in(select fol_dched from det_ched where fliq_dched = 1289 and ser_dched = d.ser_doc)

select	1
from	det_ched d
where	fliq_dched = 1289 and fol_dched in(select fol_doc from doctos where tip_doc = '03' and ser_doc = d.ser_dched)