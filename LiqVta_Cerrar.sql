DROP PROCEDURE LiqVta_Cerrar;
EXECUTE PROCEDURE  LiqVta_Cerrar(2835, 'AP01','A','laura'); 	-- ANDEN
EXECUTE PROCEDURE  LiqVta_Cerrar(1562, 'B008','B','ivonn'); 	-- MEDIDOR
EXECUTE PROCEDURE  LiqVta_Cerrar(5273, 'M007','E','ivonn'); 	-- PIPA
EXECUTE PROCEDURE  LiqVta_Cerrar(7184, 'C001','C','ivonn'); 	-- CILINDRO

-- SJI 1562  B008
-- SJI 9640  B002
-- MOR 10712 A001

CREATE PROCEDURE LiqVta_Cerrar
(
	paramFolio  INT,
	paramRuta	CHAR(4),
	paramTipo	CHAR(1),
	paramUsr	CHAR(8)
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(255);		-- Mensaje error
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(255);
DEFINE vproceso INT;
DEFINE vmsg 	CHAR(100);
DEFINE vfecha	DATE;
DEFINE vtlts	DECIMAL;
DEFINE vstlts	DECIMAL;
DEFINE vtimpt	DECIMAL;
DEFINE vstimpt	DECIMAL;
DEFINE vtasist	DECIMAL;
DEFINE vdif		DECIMAL;

LET vresult = 1;
LET vmensaje = '';
LET vproceso = 1;
LET vmsg = '';

IF paramTipo = 'E' THEN
	SELECT	fec_erup, NVL(tot_erup,0), NVL(lcre_erup,0) + NVL(lefe_erup,0) + NVL(lpar_erup,0) + NVL(lotr_erup,0), NVL(imp_erup,0), 
			NVL(vcre_erup,0) + NVL(vefe_erup,0) + NVL(votr_erup,0), NVL(impasc_erup,0) + NVL(impase_erup,0) + NVL(impaso_erup,0),
			ldi_erup
	INTO	vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif
	FROM	empxrutp
	WHERE	fliq_erup = paramFolio AND rut_erup = paramRuta;
END IF;

IF paramTipo = 'B' THEN
	SELECT	fec_vmed, NVL(tlts_vmed,0), NVL(vefe_vmed,0) + NVL(vcrd_vmed,0) + NVL(votr_vmed,0) + NVL(cint_vmed,0), NVL(impt_vmed,0), 
			NVL(icrd_vmed,0) + NVL(iefe_vmed,0) + NVL(iotr_vmed,0) + NVL(icin_vmed,0), 
			NVL(impasc_vmed,0) + NVL(impase_vmed,0) + NVL(impaso_vmed,0), ldi_vmed
	INTO	vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif
	FROM	venxmed
	WHERE	fliq_vmed = paramFolio AND rut_vmed = paramRuta;
END IF;

IF paramTipo = 'D' THEN
	SELECT	fec_desd, NVL(tkgs_desd,0), NVL(kcrd_desd,0) + NVL(kefe_desd,0), NVL(impt_desd,0), 
			NVL(icrd_desd,0) + NVL(iefe_desd,0), NVL(impase_desd,0) + NVL(impasc_desd,0), lec_desd
	INTO	vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif
	FROM	des_dir
	WHERE	fliq_desd = paramFolio AND rut_desd = paramRuta;
END IF;

IF paramTipo = 'C' THEN
	SELECT	fec_eruc, NVL(tkgs_eruc,0), NVL(kefe_eruc,0) + NVL(kcrd_eruc,0) + NVL(kpar_eruc,0) +  + NVL(kotr_eruc,0), NVL(impt_eruc,0), 
			NVL(iefe_eruc,0) + NVL(icrd_eruc,0) + NVL(iotr_eruc,0), NVL(impasc_eruc,0) + NVL(impase_eruc,0) + NVL(impaso_eruc,0),
			tkgs_eruc
	INTO	vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif
	FROM	empxrutc
	WHERE	fliq_eruc = paramFolio AND rut_eruc = paramRuta;
END IF;

IF paramTipo = 'A' THEN
	SELECT	fec_vand, NVL(tkgs_vand, 0), NVL(kefe_vand,0) + NVL(kcrd_vand,0) + NVL(kpar_vand,0), NVL(impt_vand,0), 
			NVL(icrd_vand,0) + NVL(iefe_vand,0), NVL(impasc_vand,0) + NVL(impase_vand,0), NVL(tkgs_vand, 0)
	INTO	vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif
	FROM	venxand
	WHERE	fliq_vand = paramFolio AND rut_vand = paramRuta;
END IF;

IF paramTipo = 'G' THEN
	SELECT	fec_ggas, NVL(tlts_ggas,0) , NVL(tlts_ggas,0), NVL(impt_ggas, 0),  NVL(impt_ggas, 0), 0, NVL(tlts_ggas,0)
	INTO	vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif
	FROM	gto_gas
	WHERE	fliq_ggas = paramFolio AND rut_ggas = paramRuta;
END IF;

IF paramTipo = 'S' THEN
	SELECT	fec_gdie, NVL(tlts_gdie, 0), NVL(tlts_gdie, 0), NVL(impt_gdie, 0), NVL(impt_gdie, 0), 0, NVL(tlts_gdie, 0)
	INTO	vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif
	FROM	gto_die
	WHERE	fliq_gdie = paramFolio AND rut_gdie = paramRuta;
END IF;

IF EXISTS(SELECT 	1 
		  	FROM 	e_posaj e
		  	WHERE 	e.epo_fec = vfecha) THEN
	LET vresult = 0;
	LET vmensaje = 'NO SE PUEDE CERRAR LA LIQUIDACION, EL DIA YA ESTA CERRADO.';
	RETURN 	vresult,vmensaje;	
END IF;

IF paramTipo = 'E' THEN	
	LET vproceso,vmsg = LiqVta_Verif(paramFolio,paramRuta,'E',vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif);
	IF vproceso = 1 THEN
		UPDATE	empxrutp
		SET		edo_erup = 'C'
		WHERE	fliq_erup = paramFolio AND rut_erup = paramRuta;
		
		LET vproceso,vmsg = LiqVta_ProcNvta(paramFolio, paramRuta,'E',paramUsr);
		IF vproceso = 1 THEN
			IF vtlts > 0 THEN
				LET vproceso,vmsg = LiqVta_emperup(paramFolio, paramRuta);
			END IF;
			IF vproceso = 1 THEN
				LET vmensaje = 'OK';
			ELSE
				LET vmensaje = 'ERROR AL REGISTAR LA VENTA DEL EMPLEADO';
			END IF;
		ELSE
			LET vmensaje = 'ERROR AL PROCESAR NOTAS DE VENTA';
		END IF;
	END IF;
END IF;

IF paramTipo = 'B' THEN
	LET vproceso,vmsg = LiqVta_Verif(paramFolio,paramRuta,'B',vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif);
	IF vproceso = 1 THEN 
		UPDATE	venxmed
		SET		edo_vmed = 'C'
		WHERE	fliq_vmed = paramFolio AND rut_vmed = paramRuta;
		
		LET vproceso,vmsg = LiqVta_ProcNvta(paramFolio, paramRuta,'B',paramUsr);
		IF vproceso = 1 THEN
			LET vmensaje = 'OK';
		ELSE
			LET vmensaje = 'ERROR AL PROCESAR NOTAS DE VENTA';
		END IF;
	END IF;
END IF;

IF paramTipo = 'D' THEN
	LET vproceso,vmsg = LiqVta_Verif(paramFolio,paramRuta,'D',vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif);
	IF vproceso = 1 THEN 
		UPDATE	des_dir
		SET		edo_desd = 'C'
		WHERE	fliq_desd = paramFolio AND rut_desd = paramRuta;
		
		LET vproceso,vmsg = LiqVta_ProcNvta(paramFolio, paramRuta,'D',paramUsr);
		IF vproceso = 1 THEN
			LET vmensaje = 'OK';
		ELSE
			LET vmensaje = 'ERROR AL PROCESAR NOTAS DE VENTA';
		END IF;
	END IF;
END IF;

IF paramTipo = 'C' THEN
	LET vproceso,vmsg = LiqVta_Verif(paramFolio,paramRuta,'C',vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif);
	IF vproceso = 1 THEN 
		UPDATE	empxrutc
		SET		edo_eruc = 'C'
		WHERE	fliq_eruc = paramFolio AND rut_eruc = paramRuta;
		
		LET vproceso,vmsg = LiqVta_ProcNvta(paramFolio, paramRuta,'C',paramUsr);
		IF vproceso = 1 THEN
			IF vtlts > 0 THEN
				LET vproceso,vmsg = LiqVta_emperuc(paramFolio, paramRuta);
			END IF;
			IF vproceso = 1 THEN
				LET vmensaje = 'OK';
			ELSE
				LET vmensaje = 'ERROR AL REGISTAR LA VENTA DEL EMPLEADO';
			END IF;
		ELSE
			LET vmensaje = 'ERROR AL PROCESAR NOTAS DE VENTA';
		END IF;	
	END IF;
END IF;

IF paramTipo = 'A' THEN
	LET vproceso,vmsg = LiqVta_Verif(paramFolio,paramRuta,'A',vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif);
	IF vproceso = 1 THEN 
		UPDATE	venxand
		SET		edo_vand = 'C'
		WHERE	fliq_vand = paramFolio AND rut_vand = paramRuta;
		
		LET vproceso,vmsg = LiqVta_ProcNvta(paramFolio, paramRuta,'A',paramUsr);
		IF vproceso = 1 THEN
			LET vmensaje = 'OK';
		ELSE
			LET vmensaje = 'ERROR AL PROCESAR NOTAS DE VENTA';
		END IF;
	END IF;
END IF;

IF paramTipo = 'G' THEN
	LET vproceso,vmsg = LiqVta_Verif(paramFolio,paramRuta,'G',vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif);
	IF vproceso = 1 THEN 
		UPDATE	gto_gas
		SET		edo_ggas = 'C'
		WHERE	fliq_ggas = paramFolio AND rut_ggas = paramRuta;
		
		LET vproceso,vmsg = LiqVta_ProcNvta(paramFolio, paramRuta,'G',paramUsr);
		IF vproceso = 1 THEN
			LET vmensaje = 'OK';
		ELSE
			LET vmensaje = 'ERROR AL PROCESAR NOTAS DE VENTA';
		END IF;
	END IF;
END IF;

IF paramTipo = 'S' THEN
	LET vproceso,vmsg = LiqVta_Verif(paramFolio,paramRuta,'S',vfecha, vtlts, vstlts, vtimpt, vstimpt, vtasist, vdif);
	IF vproceso = 1 THEN 
		UPDATE	gto_die
		SET		edo_gdie = 'C'
		WHERE	fliq_gdie = paramFolio AND rut_gdie = paramRuta;
		
		LET vproceso,vmsg =  LiqVta_ProcNvta(paramFolio, paramRuta,'S',paramUsr);
		IF vproceso = 1 THEN
			LET vmensaje = 'OK';
		ELSE
			LET vmensaje = 'ERROR AL PROCESAR NOTAS DE VENTA';
		END IF;
	END IF;
END IF;

LET vresult = vproceso;
LET vmensaje = TRIM(vmensaje) || ' ' || TRIM(vmsg);

RETURN 	vresult,vmensaje;
END PROCEDURE; 

select	*
from	empxrutp
where	fec_erup >= '2023-05-16' and rut_erup = 'M007'

select * 
from	venxmed
where	fec_vmed >= '2023-05-20'

select * 
from	des_dir
where	fec_desd >= '2023-04-24'

select	*
from	empxrutc
where	fec_eruc = '2023-06-26' and rut_eruc = 'C008'

update	empxrutc
set		impasi_eruc = 5.80, impase_eruc = 5.80
where	fec_eruc = '2023-05-17' and rut_eruc = 'C048'

select * 
from	venxand
where	fec_vand = '2023-06-17'

update	venxand
set		edo_vand = 'P'
where	fliq_vand = 2827

select * 
from	gto_gas
where	fec_ggas >= '2023-04-24'

select * 
from	gto_die
where	fec_gdie >= '2023-04-24'

select	*
from	nota_vta
where	fliq_nvta = 506 and ruta_nvta = 'C002' and tpa_nvta = 'C'

select	tpa_nvta, sum(impt_nvta), sum(impasi_nvta)
from	nota_vta 
where	fliq_nvta = 8457 and ruta_nvta = 'M001'
group by 1

select	tpa_nvta, sum(tlts_nvta)
from	nota_vta --where edo_nvta = 'P' and fes_nvta = '2018-07-12' and ruta_nvta = 'M018'
where	fliq_nvta = 1562 and ruta_nvta = 'B008'
group by 1

select	*
from	movxnvta
where	fol_mnvta = 104467

select	*
from	tanque
where	numcte_tqe = '006092' and numtqe_tqe = 1

select	*
from	nota_vta
where	edo_nvta = 'S' and fliq_nvta > 0 and numcte_nvta is not null
order by fes_nvta

select 	*
from	e_posaj
where	epo_fec= '2023-05-01'

update	e_posaj
set		epo_fec= '2121-03-04'
where	epo_fec= '2021-03-04'

select	*
from	empxrutp
where	fliq_erup = 7564 and rut_erup = 'M003'

update	empxrutp
set		ldi_erup = 6503.00
where	fliq_erup = 7564 and rut_erup = 'M003'

select	*
from	pedidos
where 	num_ped in(3037046,3040507,3042730,3042238,3042257,3042261,3042874,3042915,3042922,3042924,3043004,3043010,3042239,3043037,
				3042643,3043133,3043185)

insert into pedidos
select	*
from	hpedidos
where 	num_ped in(2613277)

delete
from	hpedidos
where 	num_ped in(2613277)


update	pedidos
set		edo_ped = 'p'
where 	num_ped in(3037046,3040507,3042730,3042238,3042257,3042261,3042874,3042915,3042922,3042924,3043004,3043010,3042239,3043037,
				3042643,3043133,3043185)

select	*
from	doctos
where	fol_doc in(144364,144451,144700) and vuelta_doc = 3

select	*
from	mov_cxc
where	doc_mcxc in(144364,144451,144700) and vuelta_mcxc = 3

SELECT	fec_vand, NVL(tkgs_vand, 0), NVL(kefe_vand,0) + NVL(kcrd_vand,0) + NVL(kpar_vand,0), NVL(impt_vand,0), 
			NVL(icrd_vand,0) + NVL(iefe_vand,0), NVL(impasc_vand,0) + NVL(impase_vand,0), NVL(tkgs_vand, 0)
FROM	venxand
WHERE	fliq_vand = 2820 AND rut_vand = 'AP01';

Select  tid_dfac, SUM(impasi_dfac) imp_asi , sum(tlts_dfac) cantidad,  SUM(tlts_dfac*pru_dfac ) importe 
from  	factura, det_fac
where 	fec_fac  BETWEEN  '2023-03-01' and '2023-03-31' and tdoc_fac = 'I' and edo_fac <> 'C' 
		and  faccer_fac = 'N' and fol_dfac = fol_fac  and ser_dfac= ser_fac and tfac_fac <> 'O' 
		and (frf_fac is null or frf_fac = 0)
GROUP BY   tid_dfac  
order by tid_dfac

Select  tid_dfac, SUM(CASE WHEN tid_dfac = 'B' AND ruta_nvta[1] = 'M'  THEN 0 ELSE impasi_dfac END) imp_asi,		
		sum(tlts_dfac) cantidad,  SUM(tlts_dfac*pru_dfac ) importe 
from  	factura, det_fac, nota_vta
where 	fec_fac  BETWEEN  '2023-03-01' and '2023-03-31' and tdoc_fac = 'I' and edo_fac <> 'C' 
		and  faccer_fac = 'N' and fol_dfac = fol_fac  and ser_dfac= ser_fac and tfac_fac <> 'O' 
		and (frf_fac is null or frf_fac = 0)
		and fnvta_dfac = fol_nvta and vuelta_dfac = vuelta_nvta
GROUP BY   tid_dfac  
order by tid_dfac

select	sum(impasi_nvta)
from	nota_vta
where	fes_nvta between '2023-03-01' and '2023-03-31' and edo_nvta = 'A'
		and ruta_nvta[1] = 'M' and fac_nvta is not null

select sum(impasi_vmed) a_carb from venxmed where fec_vmed  between '2023/03/01' and '2023/03/31'
	
select	*
from	nota_vta
where	fol_nvta in(327559,329126)

select	*
from	empxrutp
where	fec_erup = '2020-05-11' and rut_erup in('MG04','MG05') and pcs_erup = 'A'

select	rowid,*
from	vtaxemp
where	ruta_vemp in('M007') and fec_vemp = '2023-05-16'

insert into vtaxemp values('2726','2020-04-29','46','CP13',16,450.00,'K',0)

delete
from	vtaxemp
where	rowid in(7551275,7551282,7551283,7551767)

select	*
from	empxrutc
where	fec_eruc >= '2023-05-29' and pcs_eruc = 'G'

SELECT	fec_vand, NVL(tkgs_vand, 0), NVL(kefe_vand,0) + NVL(kcrd_vand,0) + NVL(kpar_vand,0), NVL(impt_vand,0), 
		NVL(icrd_vand,0) + NVL(iefe_vand,0), NVL(impasc_vand,0) + NVL(impase_vand,0), NVL(tkgs_vand, 0)
FROM	venxand
WHERE	fliq_vand = 17786 AND rut_vand = 'A001';

select	*
from	nota_vta
where	fes_nvta = '2023-06-14' and edo_nvta = 'S'

update	nota_vta
set		edo_nvta = 'A'
where	pla_nvta = '40' and fol_nvta = 12550 and vuelta_nvta = 2


select	*
from	ruta
order by cve_rut