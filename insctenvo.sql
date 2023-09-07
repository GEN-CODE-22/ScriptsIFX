CREATE PROCEDURE insctenvo(paramCia char(2), paramPla char(2),
paramRazSoc char(70), paramAp char(30),  paramNom char(20), 
paramDir char(40), paramCol char(40), paramCiu char(30),
paramCodPo char(6), paramLada smallint, paramTel integer, 
paramExt char(5), paramRFC char(15), paramSecof char(8),
paramUso char(2), paramNvta char(1), paramPitex char(1),
paramCont char(20), paramFechaCon date, paramDesc decimal(8, 2),
paramTip char(1), paramDcred smallint, paramReqFac char(1),
paramreqCor char(1), paramCor char(73), paramStatus char(1),
paramUsr char(8), paramAli char(15), paramGpo char(6), 
paramConCre char(1), paramLimCre decimal(10,2),
paramLimNotc smallint, paramLimCon decimal(12,2), paramNcont char(1))
RETURNING char(6);

DEFINE numeroCliente char(6);

DEFINE numeroClienteI integer;

DEFINE fechaAlta DATETIME year to day;

LOCK TABLE datos in EXCLUSIVE MODE;
SELECT numcte_dat INTO numeroClienteI
FROM datos;

UPDATE datos
SET numcte_dat = (numeroClienteI + 1);
UNLOCK TABLE datos;

LET numeroCliente = lpad(numeroClienteI, 6, '0');

SELECT DBINFO('utc_to_datetime',sh_curtime)
INTO fechaAlta
FROM sysmaster:'informix'.sysshmvals;

IF paramCont = 'N' THEN
	LET paramFechaCon = null;
END IF;


INSERT INTO cliente (num_cte, cia_cte, pla_cte, razsoc_cte,
					 ape_cte, nom_cte, dir_cte, col_cte, 
					 ciu_cte, codpo_cte, lada_cte, tel_cte, 
					 ext_cte, rfc_cte, secof_cte, uso_cte,
					 nvta_cte, pitex_cte, ntanq_cte, contr_cte, 					
 					 feccon_cte, descue_cte, tip_cte, 
					 dcred_cte, reqfac_cte, reqcor_cte, 
					 corele_cte, fecalt_cte, status_cte, 
					 usr_cte, ali_cte, gpo_cte, concre_cte, 
					 limcre_cte, limnotc_cte, limcon_Cte, 
					 ncont_cte)
VALUES 				(numeroCliente, paramCia, paramPla, 
					 paramRazSoc, paramAp, paramNom, paramDir, 
					 paramCol, paramCiu, paramCodPo, paramLada,
					 paramTel, paramExt, paramRFC, paramSecof, 
					 paramUso, paramNvta, paramPitex, 1,paramCont, 
					 paramFechaCon, paramDesc, paramTip, 
					 paramDcred, paramReqFac, paramreqCor, 
					 paramCor, fechaAlta, paramStatus, paramUsr, 
					 paramAli, paramGpo, paramConCre, 
					 paramLimCre, paramLimNotc, paramLimCon,
					 paramNcont);

RETURN numeroCliente;

END PROCEDURE;  