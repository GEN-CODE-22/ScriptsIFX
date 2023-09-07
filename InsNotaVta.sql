DROP PROCEDURE insnotavta;

CREATE PROCEDURE insnotavta(
	paramFol	INT, 
	paramCia 	CHAR(2), 
	paramPla 	CHAR(2), 
	paramPed 	INT, 
	paramCte 	CHAR(6),
	paramTqe 	SMALLINT, 
	paramRuta 	CHAR(4), 
	paramTipo 	CHAR(1), 
	paramUso 	CHAR(2),
	paramFep 	DATETIME YEAR TO MINUTE, 
	paramFes 	DATE, 
	paramEdo 	CHAR(1), 
	paramRfa 	CHAR(1),
	paramTpa 	CHAR(1),  
	paramNapl 	CHAR(1), 
	paramNept 	CHAR(1), 
	paramUsr 	CHAR(8),
	paramNomCte CHAR(50),
	paramDirTqe	CHAR(80),
	paramRfc 	CHAR(13),
	paramTN   	CHAR(1),
	paramSurvey CHAR(8),
	paramObserv CHAR(40)
)


DEFINE fechaHoraPedido DATETIME YEAR TO MINUTE;

DEFINE preciotqe CHAR(3);
DEFINE precioUni DECIMAL;
DEFINE region    SMALLINT;

DEFINE folioenruta 	CHAR(10);
DEFINE ecoruta 		CHAR(7);
DEFINE prcenr 		CHAR
(6);
DEFINE fecregenr	CHAR(6);
DEFINE tcelrneco	CHAR(1);

DEFINE vobserlog	CHAR(1500);
DEFINE vcountenr	INT;
DEFINE vfaccal		CHAR(2);
DEFINE vcodri		CHAR(1);
DEFINE vtpgo		CHAR(1);
DEFINE vrefban		CHAR(40);
DEFINE vvuelta		INT;

LET vcountenr = 0;
LET vfaccal = '';

LET vcodri = '';

SELECT 	CURRENT
INTO 	fechaHoraPedido
FROM 	systables
WHERE 	tabid = 1;

SELECT 	NVL(precio_tqe,'')
INTO	preciotqe
FROM 	tanque
WHERE	numcte_tqe = paramCte AND numtqe_tqe = paramTqe;

SELECT	 vuelta_pla
INTO	 vvuelta
FROM	 planta 
WHERE	 cia_pla = paramCia and cve_pla = paramPla;

IF LENGTH(preciotqe) = 0 THEN
	SELECT	reg_rneco
	INTO	region
	FROM	ri505_neco
	WHERE	ruta_rneco = paramRuta;

	SELECT	tpr_prc
	INTO	preciotqe
	FROM	precios
	WHERE	reg_prc = region
			AND tid_prc = paramTipo
			AND pri_prc = 'S';
	
	SELECT	NVL(pru_mprc,0)
	INTO	precioUni
	FROM	mov_prc
	WHERE	tpr_mprc = preciotqe
			AND fei_mprc <= paramFes
			AND fet_mprc >= paramFes;
	
ELSE 
	SELECT	NVL(pru_mprc,0)
	INTO	precioUni
	FROM	mov_prc
	WHERE	tpr_mprc = preciotqe
			AND fei_mprc <= paramFes
			AND fet_mprc >= paramFes;
END IF;


IF NOT EXISTS(SELECT 	1 
			FROM 	nota_vta 
			WHERE  	fol_nvta 		= paramFol
					AND cia_nvta 	= paramCia
					AND pla_nvta 	= paramPla) THEN
INSERT INTO nota_vta(
					fol_nvta, 
					cia_nvta, 
					pla_nvta, 
					ped_nvta, 
					numcte_nvta, 
					numtqe_nvta, 
					ruta_nvta, 
					tip_nvta, 
					uso_nvta, 
					fep_nvta,
					fes_nvta, 
					edo_nvta, 
					rfa_nvta, 
					tpa_nvta, 
					napl_nvta, 
					nept_nvta, 
					tprd_nvta, 
					pru_nvta, 
					usr_nvta, 
					tpdo_nvta,
					vuelta_nvta)
			        
VALUES			  (
					paramFol, 
					paramCia, 
					paramPla, 
					paramPed, 
					paramCte, 
					paramTqe, 
					paramRuta, 
					paramTipo, 
					paramUso, 
					fechaHoraPedido,
					paramFes, 
					paramEdo, 
					paramRfa, 
					paramTpa, 
					paramNapl, 
					paramNept, 
					preciotqe, 
					precioUni, 
					paramUsr,
					paramTN,
					vvuelta);
END IF;
				   
IF EXISTS(SELECT 	1 
			FROM 	nota_vta 
			WHERE  	fol_nvta 		= paramFol
					AND cia_nvta 	= paramCia
					AND pla_nvta 	= paramPla
					AND numcte_nvta = paramCte
					AND ped_nvta 	= paramPed
					AND numtqe_nvta = paramTqe) THEN                 
    LET vobserlog = 'EXITO AL INSERTAR NOTA DE VENTA[' || paramFol || '] COMPA?IA[' || paramCia || '] PLANTA[' || paramPla || '] CLIENTE[' || paramCte || '] PEDIDO[' || paramPed || '] TANQUE[' || paramTqe || '] tpa_nvta[' || paramTpa ||  ']';

ELSE
	LET vobserlog = 'NO SE INSERTO CORRECTAMENTE LA NOTA DE VENTA[' || paramFol || '] COMPA?IA[' || paramCia || '] PLANTA[' || paramPla || '] CLIENTE[' || paramCte || '] PEDIDO[' || paramPed || '] TANQUE[' || paramTqe || ']';
END IF;

IF	paramSurvey IS NOT NULL AND LENGTH(paramSurvey) > 0	THEN
	INSERT INTO survey_vta(fol_survey,fol_nvta)
	VALUES(paramSurvey,paramFol);
END IF;

LET folioenruta = paramCia || paramPla || LPAD(paramFol,6,'0');
LET fecregenr = TO_CHAR(paramFes, '%d%m%y');

LET ecoruta = 'N/A';
IF paramFes <= TODAY THEN
	SELECT	NVL(unid_rneco,''),
			tcel_rneco
	INTO	ecoruta,

			tcelrneco
	FROM	ri505_neco
	WHERE	ruta_rneco = paramRuta;
END IF;

IF LENGTH(paramNomCte) = 0 THEN
	LET paramNomCte = 'PUBLICO EN GENERAL';
END IF;

IF LENGTH(paramDirTqe) = 0 THEN
	LET paramDirTqe = 'NO DISPONIBLE';
END IF;

IF LENGTH(paramRfc) = 0 THEN
	LET paramRfc = 'N/A';
END IF;

IF LENGTH(ecoruta) = 0 OR ecoruta IS NULL THEN
	LET ecoruta = 'N/A';
END IF;

IF precioUni = 0  THEN
	LET prcenr = '0.0000';
ELSE
	LET prcenr = precioUni || '';
END IF;

LET vtpgo = get_tpgoenr(paramTpa);


SELECT	COUNT(*)
INTO	vcountenr
FROM	enruta
WHERE	fol_enr = folioenruta;

IF paramFes <= TODAY AND ecoruta <> 'N/A' AND tcelrneco = 'S' AND vcountenr = 0 THEN
	
	LET vfaccal = get_faccal(paramCte);
	LET vrefban = get_refbanco(paramTpa,paramCte,paramFol,paramCia,paramPla);
	LET paramNomCte = REPLACE(paramNomCte,',',' ');
	INSERT INTO enruta(
						fol_enr, 
						numcte_enr, 
						nom_enr, 
						dir_enr, 
						rfc_enr, 
						fecreg_enr, 
						prc_enr, 
						eco_enr, 	
						ruta_enr, 
						edovta_enr, 
						ltssur_enr, 
						edoreg_enr, 
						obser_enr, 
						faccal_enr, 
						tippgo_enr, 
						com_enr,
						mens_enr,
						reccel_enr,
						ped_enr,
						asiste_enr,
						impasi_enr,
						vuelta_enr,
						tpr_enr,
						cupon_enr)
	VALUES		(		
						folioenruta, 
						paramCte, 
						paramNomCte, 
						paramDirTqe, 
						paramRfc, 
						fecregenr, 
						prcenr, 
						ecoruta,
						paramRuta, 
						'0',
						'0',
						'0',
						' ', 
						vfaccal,
						vtpgo,
						vrefban,
						paramObserv,
						0,
						paramPed,
						null,
						null,
						vvuelta,
						preciotqe,
						null);
END IF;

END PROCEDURE;     

select	fes_nvta, count(*)
from	nota_vta
where	fes_nvta >= '2023-06-01' and edo_nvta = 'A' and tpdo_nvta = 'P'     
group by 1   

select	*
from	nota_vta
where	fes_nvta = '2023-06-15' and edo_nvta = 'P' and tpdo_nvta = 'P'

select	*
from	nota_vta
where	fes_nvta = '2023-06-19' and fep_nvta between '2023-06-19 00:01' and '2023-06-19 23:59' and edo_nvta = 'P' and tpdo_nvta = 'P'

select	*
from	nota_vta
where	tpdo_nvta IN('P') and edo_nvta = 'P' and tpa_nvta in('B','R')

select	*
from	nota_vta
where	fol_nvta = 50836  

delete	
from 	nota_vta
where	fol_nvta = 385328

select	*
from	nota_vta
where	ped_nvta = 2760317

select	*
from	ruta
where	cve_rut = 'M001'

select	*
from	pedidos
where	num_ped = 13615483

delete
from	pedidos
where	num_ped = 2760318

select	*
from	enruta
where	fol_enr = '1502032963'

SELECT	*
FROM	ri505_neco
order by ruta_rneco

SELECT	NVL(unid_rneco,''),
		tcel_rneco
FROM	ri505_neco
WHERE	ruta_rneco = 'M001';

