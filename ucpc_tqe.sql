EXECUTE PROCEDURE ucpc_tqe('2023-04-02','006092',1);
DROP PROCEDURE ucpc_tqe;

CREATE PROCEDURE ucpc_tqe
(
	paramFecha  DATE,
	paramCte    CHAR(6),
	paramTqe	SMALLINT
)
RETURNING  
 DATE,		-- Ultima carga
 SMALLINT,	-- Dias carga
 DATE;		-- Proxima carga

DEFINE xdia		SMALLINT;
DEFINE xmes 	SMALLINT;
DEFINE xanio 	SMALLINT;
DEFINE xx		SMALLINT;
DEFINE vultcar	DATE;
DEFINE vultcarr	DATE;
DEFINE vproxcar	DATE;
DEFINE vprg		CHAR(1);
DEFINE vdiasca	SMALLINT;
DEFINE vdiasom	SMALLINT;

LET vproxcar = NULL;

SELECT	ultcar_tqe, prg_tqe, diasca_tqe, diasom_tqe
INTO	vultcar,vprg,vdiasca,vdiasom
FROM	tanque
WHERE	numcte_tqe = paramCte AND numtqe_tqe = paramTqe;

LET vultcarr = paramFecha;
IF vultcar IS NOT NULL AND vultcar > paramFecha THEN
     LET vultcarr = vultcar;
END IF;

IF vprg MATCHES '[FMS]' THEN
	IF	vprg = 'F' THEN
		LET vproxcar = vultcarr + vdiasca;
        IF vdiasom IS NOT NULL THEN
           LET xdia = WEEKDAY(vproxcar);
           LET xdia = vdiasom - xdia;
           LET vproxcar = vproxcar + xdia;
        END IF;
	END IF;
	IF	vprg = 'M' THEN
		LET xmes  = MONTH(vultcarr) + (vdiasca / 30);
        LET xanio = YEAR(vultcarr);
        IF xmes > 12 THEN
           LET xmes = xmes - 12;
           LET xanio = xanio + 1;
        END IF;
        IF xmes = 2 AND vdiasom > 28 THEN
           IF MOD(xanio,4) = 0 THEN
              LET xdia = 29;
           ELSE
              LET xdia = 28;
           END IF;
        ELSE
           LET xdia = vdiasom;
        END IF;
        LET vproxcar = MDY(xmes,xdia,xanio);
        LET xx = vproxcar - vultcarr - vdiasca;
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
           END IF;
           LET vproxcar = MDY(xmes,xdia,xanio);
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
              END IF
              LET vproxcar = MDY(xmes,xdia,xanio);
           END IF;
        END IF;
	END IF;
	IF vprg = 'S' THEN
		LET xdia = WEEKDAY(vultcarr);
        LET xdia = vdiasca - xdia + vdiasom;
        LET xx = xdia - vdiasca;
        IF xx > 3 THEN
           LET xdia = xdia - 7;
        END IF
        LET vproxcar = vultcarr + xdia;
	END IF;
END IF;
RETURN vultcarr,vdiasca,vproxcar;
END PROCEDURE;

FUNCTION ucpc_tqe(xultcar_tqe)
   DEFINE
      xultcar_tqe     LIKE tanque.ultcar_tqe,
      xproxca_tqe     LIKE tanque.proxca_tqe,
      xdia,xmes,xanio SMALLINT,
      xx              SMALLINT

   INITIALIZE xproxca_tqe TO NULL
   IF rtqe.ultcar_tqe IS NOT NULL AND rtqe.ultcar_tqe > xultcar_tqe THEN
      LET xultcar_tqe = rtqe.ultcar_tqe
   END IF

   IF rtqe.prg_tqe MATCHES "[FMS]" THEN
      CASE rtqe.prg_tqe
         WHEN "F"
            LET xproxca_tqe = xultcar_tqe + rtqe.diasca_tqe
            IF rtqe.diasom_tqe IS NOT NULL THEN
               LET xdia = WEEKDAY(xproxca_tqe)
               LET xdia = rtqe.diasom_tqe - xdia
               LET xproxca_tqe = xproxca_tqe + xdia
            END IF
         WHEN "M"
            LET xmes  = MONTH(xultcar_tqe) + (rtqe.diasca_tqe / 30)
            LET xanio = YEAR(xultcar_tqe)
            IF xmes > 12 THEN
               LET xmes = xmes - 12
               LET xanio = xanio + 1
            END IF
            IF xmes = 2 AND rtqe.diasom_tqe > 28 THEN
               IF (xanio MOD 4) = 0 THEN
                  LET xdia = 29
               ELSE
                  LET xdia = 28
               END IF
            ELSE
               LET xdia = rtqe.diasom_tqe
            END IF
            LET xproxca_tqe = MDY(xmes,xdia,xanio)
            LET xx = xproxca_tqe - xultcar_tqe - rtqe.diasca_tqe
            IF xx > 10 THEN
               IF xmes = 1 THEN
                  LET xmes = 12
                  LET xanio = xanio - 1
               END IF
               IF xmes = 2 AND rtqe.diasom_tqe > 28 THEN
                  IF (xanio MOD 4) = 0 THEN
                     LET xdia = 29
                  ELSE
                     LET xdia = 28
                  END IF
               ELSE
                  LET xdia = rtqe.diasom_tqe
               END IF
               LET xproxca_tqe= MDY(xmes,xdia,xanio)
            ELSE
               IF xx < -20 THEN
                  IF xmes > 12 THEN
                     LET xmes = xmes - 12
                     LET xanio = xanio + 1
                  END IF
                  IF xmes = 2 AND rtqe.diasom_tqe > 28 THEN
                     IF MOD(xanio,4) = 0 THEN
                        LET xdia = 29
                     ELSE
                        LET xdia = 28
                     END IF
                  ELSE
                     LET xdia = rtqe.diasom_tqe
                  END IF
                  LET xproxca_tqe= MDY(xmes,xdia,xanio)
               END IF
            END IF
         WHEN "S"
            LET xdia = WEEKDAY(xultcar_tqe)
            LET xdia = rtqe.diasca_tqe - xdia + rtqe.diasom_tqe
            LET xx = xdia - rtqe.diasca_tqe
            IF xx > 3 THEN
               LET xdia = xdia - 7
            END IF
            LET xproxca_tqe = xultcar_tqe + xdia
      END CASE
   END IF
   RETURN xultcar_tqe,rtqe.diasca_tqe,xproxca_tqe
END FUNCTION

select MDY(3,30,2023),WEEKDAY(fes_nvta), MOD(2018,4),* 
from	nota_vta
where	fol_nvta = 383856

select	*
from	tanque
where	numcte_tqe = '033781' and numtqe_tqe = 9

select	*
from	tanque
where 	prg_tqe MATCHES '[FMS]'
