DROP PROCEDURE FacDoctos;
EXECUTE PROCEDURE FacDoctos('15','02',544346,'EAB','111419','01');
CREATE PROCEDURE FacDoctos
(
	paramCia      		CHAR(2),
	paramPla      		CHAR(2),
	paramFolio      	INT,
	paramSerie      	CHAR(4),
	paramCte      		CHAR(6),		
	paramTipo			CHAR(2)
	
)

RETURNING 
 CHAR(3);

DEFINE v_regreso  	CHAR(3);
DEFINE v_folioNota	INT;
DEFINE x			INT;

LET v_regreso = 'A';
LET x = 0;


--ACTUALIZA DOCTOS y MOVCXC ----------------------------------------------------------------------------------------------------------
FOREACH cDetalle FOR
	SELECT  fnvta_dfac
	INTO	v_folioNota
	FROM	det_fac
	WHERE	fol_dfac = paramFolio  and ser_dfac = paramSerie
	
	UPDATE	doctos
	SET     ffac_doc = paramFolio, sfac_doc = paramSerie
	WHERE	fol_doc = v_folioNota
			and   cia_doc = paramCia
  			and   pla_doc = paramPla
  			and   tip_doc = paramTipo
  			and   cte_doc = paramCte;
  	
  	update	mov_cxc
	set		ffac_mcxc = paramFolio, sfac_mcxc = paramSerie
	where	doc_mcxc = v_folioNota
 	 		and   cia_mcxc = paramCia 
  			and   pla_mcxc = paramPla
  			and   tip_mcxc = paramTipo
  			and   cte_mcxc = paramCte;	
  	LET x = x + 1;
END FOREACH; 

LET v_regreso = LPAD(x,3,'0');

RETURN 	v_regreso;
END PROCEDURE;    