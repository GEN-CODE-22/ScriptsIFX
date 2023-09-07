DROP PROCEDURE fact_getpcre;
EXECUTE PROCEDURE fact_getpcre('15','85',566075,'BP01','2022-11-01');

CREATE PROCEDURE fact_getpcre
(
	paramCia      CHAR(2),
	paramPla      CHAR(2),
	paramFolio    INT,
	paramRuta     CHAR(4),
	paramFecha    DATE
)

RETURNING 
 CHAR(40);

DEFINE v_pcre	CHAR(40);
LET v_pcre = '';

SELECT	NVL(TRIM(pcre_rut), '')
INTO	v_pcre
FROM	ruta
WHERE   cve_rut = paramRuta;

IF LENGTH(v_pcre) = 0 THEN
	SELECT	NVL(TRIM(pcre_pla), '')
	INTO	v_pcre
	FROM	planta
	WHERE   cve_pla = paramPla;
END IF;

LET v_pcre = TRIM(v_pcre) || '-' || TO_CHAR(paramFecha, '%y%m%d') || paramCia || paramPla || LPAD(paramFolio,6,'0');
RETURN 	v_pcre;
END PROCEDURE; 

select	*
from	nota_vta
where	fes_nvta = '2022-11-01'
