DROP PROCEDURE cxc_saldo;
EXECUTE PROCEDURE cxc_saldo('C','01','2022-07-13','15','13','007290',0,143474,'EAM');
EXECUTE PROCEDURE cxc_saldo('C','01','2022-07-12','15','85','007290',899330,0,'');

CREATE PROCEDURE cxc_saldo
(
	paramTpa		CHAR(1),
	paramTipo		CHAR(2),
	paramFecha   	DATE,
	paramCia		CHAR(2),
	paramPla		CHAR(2),
	paramCte		CHAR(6),
	paramFolio		INT,
	paramFfac		INT,
	paramSerie		CHAR(4),
	paramVuelta		SMALLINT
)
RETURNING  
 DECIMAL;	-- Saldo
 
DEFINE vcargo DECIMAL;
DEFINE vabono DECIMAL;
DEFINE vsaldo DECIMAL;

LET vcargo = 0;
LET vabono = 0;
LET vsaldo = 0;

IF paramFolio > 0 THEN
	IF paramVuelta > 0 THEN
		SELECT NVL(SUM(imp_mcxc),0)
		  INTO vcargo
		  FROM mov_cxc
		  WHERE doc_mcxc = paramFolio
			AND ser_mcxc = paramSerie
			AND cia_mcxc = paramCia
			AND pla_mcxc = paramPla
			AND vuelta_mcxc = paramVuelta
			AND cte_mcxc = paramCte
			AND sta_mcxc = 'A'
			AND tpa_mcxc = paramTpa
			AND fec_mcxc <= paramFecha
			AND tpm_mcxc < '50';

	   SELECT NVL(SUM(imp_mcxc),0)
		 INTO vabono
		 FROM mov_cxc
		  WHERE doc_mcxc = paramFolio
			AND ser_mcxc = paramSerie
			AND cia_mcxc = paramCia
			AND pla_mcxc = paramPla
			AND vuelta_mcxc = paramVuelta
			AND cte_mcxc = paramCte
			AND sta_mcxc = 'A'
			AND tpa_mcxc = paramTpa
			AND fec_mcxc <= paramFecha
			AND tpm_mcxc > '49';

	   LET vsaldo = vcargo - vabono;
   ELSE
	   	SELECT NVL(SUM(imp_mcxc),0)
		  INTO vcargo
		  FROM mov_cxc
		  WHERE doc_mcxc = paramFolio
			AND ser_mcxc = paramSerie
			AND cia_mcxc = paramCia
			AND pla_mcxc = paramPla
			AND tip_mcxc = paramTipo
			AND cte_mcxc = paramCte
			AND sta_mcxc = 'A'
			AND tpa_mcxc = paramTpa
			AND fec_mcxc <= paramFecha
			AND tpm_mcxc < '50';

	   SELECT NVL(SUM(imp_mcxc),0)
		 INTO vabono
		 FROM mov_cxc
		  WHERE doc_mcxc = paramFolio
			AND ser_mcxc = paramSerie
			AND cia_mcxc = paramCia
			AND pla_mcxc = paramPla
			AND tip_mcxc = paramTipo
			AND cte_mcxc = paramCte
			AND sta_mcxc = 'A'
			AND tpa_mcxc = paramTpa
			AND fec_mcxc <= paramFecha
			AND tpm_mcxc > '49';

	   LET vsaldo = vcargo - vabono;
   END IF;
	
ELSE
	SELECT NVL(SUM(imp_mcxc),0)
		  INTO vcargo
		  FROM mov_cxc
		  WHERE ffac_mcxc = paramFfac
			AND sfac_mcxc = paramSerie
			AND cia_mcxc = paramCia
			AND pla_mcxc = paramPla
			AND tip_mcxc = paramTipo
			AND cte_mcxc = paramCte
			AND sta_mcxc = 'A'
			AND tpa_mcxc = paramTpa
			AND fec_mcxc <= paramFecha
			AND tpm_mcxc < '50';

	   SELECT NVL(SUM(imp_mcxc),0)
		  INTO vabono
		  FROM mov_cxc
		  WHERE ffac_mcxc = paramFfac
			AND sfac_mcxc = paramSerie
			AND cia_mcxc = paramCia
			AND pla_mcxc = paramPla
			AND tip_mcxc = paramTipo
			AND cte_mcxc = paramCte
			AND sta_mcxc = 'A'
			AND tpa_mcxc = paramTpa
			AND fec_mcxc <= paramFecha
			AND tpm_mcxc > '49';

	   LET vsaldo = vcargo - vabono;
END IF;
   
RETURN 	vsaldo;
END PROCEDURE;

SELECT SUM(imp_mcxc) 
      FROM mov_cxc
      WHERE ffac_mcxc = 147747
        AND sfac_mcxc = 'EAM'
        AND cia_mcxc = '15'
        AND pla_mcxc = '13'
        AND tip_mcxc = '01'
        AND cte_mcxc = '007290'
        AND sta_mcxc = 'A'
        AND tpa_mcxc = 'C'
        AND fec_mcxc <= '2022-07-20'
        AND tpm_mcxc < '50';

   SELECT SUM(imp_mcxc) 
      FROM mov_cxc
      WHERE ffac_mcxc = 147747
        AND sfac_mcxc = 'EAM'
        AND cia_mcxc = '15'
        AND pla_mcxc = '13'
        AND tip_mcxc = '01'
        AND cte_mcxc = '007290'
        AND sta_mcxc = 'A'
        AND tpa_mcxc = 'C'
        AND fec_mcxc <= '2022-07-20'
        AND tpm_mcxc > '49';
        
        SELECT SUM(imp_mcxc) 
      FROM mov_cxc
      WHERE cia_mcxc = '15'
        AND pla_mcxc = '13'
        AND tip_mcxc = '01'
        AND cte_mcxc = '006774'
        AND sta_mcxc = 'A'
        AND tpa_mcxc = 'C'
        AND fec_mcxc <= '2022-07-20'
        AND tpm_mcxc > '50';
        
SELECT SUM(imp_mcxc) 
      FROM mov_cxc
      WHERE cia_mcxc = '15'
        AND pla_mcxc = '13'
        AND tip_mcxc = '01'
        AND cte_mcxc = '006774'
        AND sta_mcxc = 'A'
        AND tpa_mcxc = 'C'
        AND fec_mcxc <= '2022-07-20'
        AND tpm_mcxc < '50';