DROP PROCEDURE FacTraxlixSicogas;
EXECUTE PROCEDURE FacTraxlixSicogas('15','15',199460,'EAQ',null,null,1275.00,1099.14,175.86,'048948','AIBM490622CW6','D60393B0-29F0-4F4B-8C09-48550BA0B13C',982429,0,0,0,0,0,0,0,0,0);

CREATE PROCEDURE FacTraxlixSicogas
(
	paramCia      		CHAR(2),
	paramPla      		CHAR(2),
	paramFolio      	INT,
	paramSerie      	CHAR(4),	
	paramReFolio      	INT,
	paramReSerie   		CHAR(4),
	paramImporte		DECIMAL,
	paramSubImporte		DECIMAL,
	paramIva			DECIMAL,
	paramNoCte      	CHAR(6),
	paramRfc      		CHAR(13),
	paramUiid      		CHAR(40),
	paramNota1      	INT,
	paramNota2      	INT,
	paramNota3      	INT,
	paramNota4      	INT,
	paramNota5      	INT,
	paramNota6      	INT,
	paramNota7     		INT,
	paramNota8      	INT,
	paramNota9      	INT,
	paramNota10      	INT
)

RETURNING 
 CHAR(1);

DEFINE v_regreso  	CHAR(1);
DEFINE v_folioNota	INT;
DEFINE v_tpaNota  	CHAR(1);
DEFINE v_tipNota  	CHAR(1);
DEFINE v_tprodNota	CHAR(3);
DEFINE v_tlts		DECIMAL;
DEFINE v_precio		DECIMAL;
DEFINE v_asistencia	DECIMAL;
DEFINE v_subImporte DECIMAL;
DEFINE i			SMALLINT;
DEFINE x			SMALLINT;
DEFINE j			SMALLINT;
DEFINE v_ruta		CHAR(4);
DEFINE v_pcre		CHAR(40);
DEFINE v_fecha		DATE;
DEFINE v_vuelta		INT;

LET v_regreso = 'A';
LET x = 10;
LET j = 0;
LET v_pcre = '';

--ACTUALIZA FACTURA----------------------------------------------------------------------------------------------------------
update	factura
set		simp_fac = paramSubImporte, iva_fac = paramIva , impt_fac = paramImporte, numcte_fac = paramNoCte, rfc_fac = paramRfc, uuid_fac = paramUiid
where   fol_fac = paramFolio  and ser_fac = paramSerie;
LET v_regreso = 'B';

--ACTUALIZA CFD----------------------------------------------------------------------------------------------------------
update  cfd
set		dif_cfd = 0.00
where	fol_cfd = paramFolio and ser_cfd = paramSerie;
LET v_regreso = 'C';

--ACTUALIZA NOTA VTA ANTERIOR----------------------------------------------------------------------------------------------------------
FOREACH cDetalle FOR
	SELECT  fnvta_dfac, vuelta_dfac
	INTO	v_folioNota, v_vuelta
	FROM	det_fac
	WHERE	fol_dfac = paramFolio  and ser_dfac = paramSerie
	
	UPDATE	nota_vta
	SET		fac_nvta = paramReFolio, ser_nvta = paramReSerie
	WHERE	fol_nvta = v_folioNota AND cia_nvta = paramCia and pla_nvta = paramPla AND vuelta_nvta = v_vuelta;
	
	SELECT  tpa_nvta
	INTO	v_tpaNota
	FROM	nota_vta
	WHERE	fol_nvta = v_folioNota AND cia_nvta = paramCia and pla_nvta = paramPla AND vuelta_nvta = v_vuelta;
	
	IF	v_tpaNota = 'C' or v_tpaNota = 'G' THEN
    	update	doctos
		set     ffac_doc = paramReFolio, sfac_doc = paramReSerie
		where	fol_doc = v_folioNota
			and   cia_doc = paramCia
	  		and   pla_doc = paramPla
	  		and   vuelta_doc = v_vuelta;
	  	
	  	update	mov_cxc
		set		ffac_mcxc = paramReFolio, sfac_mcxc = paramReSerie
		where	doc_mcxc = v_folioNota
		  and   cia_mcxc = paramCia
		  and   pla_mcxc = paramPla
		  and   vuelta_mcxc = v_vuelta;
    END IF;  
END FOREACH; 

LET v_regreso = 'D';

--ELIMINA DETALLE----------------------------------------------------------------------------------------------------------
delete
from	det_fac
where   fol_dfac = paramFolio  and ser_dfac = paramSerie;
LET v_regreso = 'E';

--INSERTA DETALLE y ACTUALIZA NOTAS NUEVAS----------------------------------------------------------------------------------------------------------
FOR i = 1 TO x
  IF i = 1 THEN 
  	LET v_folioNota = paramNota1;
  END IF;
  IF i = 2 THEN 
  	LET v_folioNota = paramNota2;
  END IF;
  IF i = 3 THEN 
  	LET v_folioNota = paramNota3;
  END IF;
  IF i = 4 THEN 
  	LET v_folioNota = paramNota4;
  END IF;
  IF i = 5 THEN 
  	LET v_folioNota = paramNota5;
  END IF;
  IF i = 6 THEN 
  	LET v_folioNota = paramNota6;
  END IF;
  IF i = 7 THEN 
  	LET v_folioNota = paramNota7;
  END IF;  
  IF i = 8 THEN 
  	LET v_folioNota = paramNota8;
  END IF;
  IF i = 9 THEN 
  	LET v_folioNota = paramNota9;
  END IF;
  IF i = 10 THEN 
  	LET v_folioNota = paramNota10;
  END IF;

  IF v_folioNota > 0 THEN
  	SELECT  tpa_nvta,tip_nvta, tlts_nvta, tprd_nvta, pru_nvta, simp_nvta,NVL(impasi_nvta,0), ruta_nvta, fes_nvta, vuelta_nvta
	INTO	v_tpaNota,v_tipNota,v_tlts,v_tprodNota,v_precio,v_subImporte,v_asistencia, v_ruta, v_fecha, v_vuelta
	FROM	nota_vta
	WHERE	fol_nvta = v_folioNota AND cia_nvta = paramCia and pla_nvta = paramPla;
	
	LET v_pcre = fact_getpcre(paramCia,paramPla,v_folioNota,v_ruta,v_fecha);
	insert into det_fac 
	values(paramFolio,paramSerie,paramCia,paramPla,i,v_tipNota,v_folioNota,null,v_tlts,v_tprodNota,v_precio,null,v_subImporte,v_asistencia,v_vuelta,v_pcre);
	
  	UPDATE	nota_vta
	SET		fac_nvta = paramFolio, ser_nvta = paramSerie
	WHERE	fol_nvta = v_folioNota AND cia_nvta = paramCia and pla_nvta = paramPla;
	
	IF	v_tpaNota = 'C' or v_tpaNota = 'G' THEN
    	update	doctos
		set     ffac_doc = paramFolio, sfac_doc = paramSerie
		where	fol_doc = v_folioNota
			and   cia_doc = paramCia
	  		and   pla_doc = paramPla
	  		and   vuelta_doc = v_vuelta;
	  	
	  	update	mov_cxc
		set		ffac_mcxc = paramFolio, sfac_mcxc = paramSerie
		where	doc_mcxc = v_folioNota
		  and   cia_mcxc = paramCia
		  and   pla_mcxc = paramPla
		  and   vuelta_mcxc = v_vuelta;
    END IF;  	
  END IF;
END FOR;

LET v_regreso = 'F';

RETURN 	v_regreso;
END PROCEDURE; 
