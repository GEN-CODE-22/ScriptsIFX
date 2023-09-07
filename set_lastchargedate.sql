CREATE PROCEDURE set_lastchargedate
(
	paramCia CHAR(2),
	paramPla CHAR(2),
	paramCte CHAR(6),
	paramTqe INT
)

DEFINE  xultcar_tqe	DATE;
DEFINE  xdiasca_tqe SMALLINT;
DEFINE  xproxca_tqe DATE;
DEFINE  xdia        SMALLINT;
DEFINE  xmes        SMALLINT;
DEFINE  xanio       SMALLINT;
DEFINE  xx          SMALLINT;
DEFINE  vprg        CHAR(1);
DEFINE  vdiasom     SMALLINT;

LET	xdiasca_tqe = NULL;
LET	xproxca_tqe = NULL;
LET xultcar_tqe = NULL;

SELECT	prg_tqe,
		diasom_tqe,
		diasca_tqe,
		proxca_tqe
INTO	vprg,
		vdiasom,
		xdiasca_tqe,
		xproxca_tqe
FROM	tanque
WHERE	numcte_tqe		= paramCte
		AND numtqe_tqe	= paramTqe;
		
SELECT	MAX(fes_nvta)
INTO	xultcar_tqe
FROM	nota_vta
WHERE	cia_nvta 		= paramCia
		AND pla_nvta	= paramPla
		AND numcte_nvta = paramCte
		AND numtqe_nvta = paramTqe
		AND edo_nvta 	IN('S','A');
		
IF xultcar_tqe IS NULL THEN
	SELECT	MAX(fes_nvta)
	INTO	xultcar_tqe
	FROM	rdnota_vta
	WHERE	cia_nvta 		= paramCia
			AND pla_nvta	= paramPla
			AND numcte_nvta = paramCte
			AND numtqe_nvta = paramTqe
			AND edo_nvta 	IN('S','A');
END IF;

IF vprg = 'F' OR vprg = 'M' OR vprg = 'S' THEN
	IF vprg = 'F' THEN
        LET xproxca_tqe = xultcar_tqe + xdiasca_tqe;
    	IF vdiasom IS NOT NULL THEN
	       LET xdia = WEEKDAY(xproxca_tqe);
	       LET xdia = vdiasom - xdia;
	       LET xproxca_tqe = xproxca_tqe + xdia;
	    END IF;
	END IF;
	IF vprg = 'M' THEN
		LET xmes  = MONTH(xultcar_tqe) + (xdiasca_tqe / 30);
        LET xanio = YEAR(xultcar_tqe);
        IF xmes > 12 THEN
           LET xmes = xmes - 12;
           LET xanio = xanio + 1;
        END IF
        IF xmes = 2 AND vdiasom > 28 THEN
           IF MOD(xanio,4) = 0 THEN
              LET xdia = 29;
           ELSE
              LET xdia = 28;
           END IF;
        ELSE
           LET xdia = vdiasom;
        END IF;
        LET xproxca_tqe= MDY(xmes,xdia,xanio);
        LET xx = xproxca_tqe - xultcar_tqe - xdiasca_tqe;
        IF xx > 10 THEN
           IF xmes = 1 THEN
              LET xmes = 12;
              LET xanio = xanio - 1;
           END IF;
           IF xmes = 2 AND vdiasom > 28 THEN
              IF MOD(xanio,4) = 0 THEN
                 LET xdia = 29;
              ELSE
                 LET xdia = 28;
              END IF;
           ELSE
              LET xdia = vdiasom;
           END IF
           LET xproxca_tqe= MDY(xmes,xdia,xanio);
        ELSE
           IF xx < -20 THEN
              IF xmes > 12 THEN
                 LET xmes = xmes - 12;
                 LET xanio = xanio + 1;
              END IF
              IF xmes = 2 AND vdiasom > 28 THEN
                 IF MOD(xanio,4) = 0 THEN
                    LET xdia = 29;
                 ELSE
                    LET xdia = 28;
                 END IF;
              ELSE
                 LET xdia = vdiasom;
              END IF;
              LET xproxca_tqe= MDY(xmes,xdia,xanio);
           END IF;
        END IF;
	END IF;
    IF vprg = 'S' THEN
    	LET xdia = WEEKDAY(xultcar_tqe);
        LET xdia = xdiasca_tqe - xdia + vdiasom;
        LET xx = xdia - xdiasca_tqe;
        IF xx > 3 THEN
           LET xdia = xdia - 7;
        END IF
        LET xproxca_tqe = xultcar_tqe + xdia;
    END IF;
  
	
  
END IF;

UPDATE	tanque
SET 	ultcar_tqe 		= xultcar_tqe,
     	proxca_tqe 		= xproxca_tqe
WHERE 	numcte_tqe 		= paramCte
		AND	numtqe_tqe 	= paramTqe;
		
UPDATE 	cliente
SET 	fecuca_cte 	= xultcar_tqe
WHERE 	num_cte 	= paramCte;

END PROCEDURE;