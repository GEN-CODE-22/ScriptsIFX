DROP PROCEDURE Upt_LiqCob;
EXECUTE PROCEDURE  Upt_LiqCob(60274,0);
			
CREATE PROCEDURE Upt_LiqCob
(
	paramFolio   	INT,
	paramAction		INT --0 = Agregar 1 = Eliminar 2 = Modificar
)

RETURNING  
 CHAR(1),
 INT,
 INT;

DEFINE vreturn 	CHAR(1);
DEFINE vmov 	INT;
DEFINE vnum 	INT;
DEFINE vncte	INT;
DEFINE vmcte 	INT;
DEFINE vfolio	INT;
DEFINE vserie 	CHAR(4);
DEFINE vcia 	CHAR(2);
DEFINE vpla 	CHAR(2);
DEFINE vnocte	CHAR(6);
DEFINE vtip 	CHAR(1);
DEFINE vfecha 	DATE;
DEFINE vfecdet 	DATE;
DEFINE vimp 	DECIMAL;
DEFINE vimpp 	DECIMAL;
DEFINE vimpr 	DECIMAL;
DEFINE vimpe 	DECIMAL;
DEFINE vimpc 	DECIMAL;
DEFINE vimpf 	DECIMAL;
DEFINE vimptot  DECIMAL;
DEFINE vedo		CHAR(1);

LET vncte = 0;	
LET vmov = 0;
LET vreturn = 'E';
LET vimptot = 0;
LET vimpp = 0;
LET vimpr = 0;
LET vimpe = 0;
LET vimpc = 0;
LET vimpf = 0;

IF paramAction = 0 OR paramAction = 1 THEN
	LET vreturn = 'R';
	FOREACH cLiquidacion FOR
		SELECT	DISTINCT f.numcte_fac
		INTO	vnocte
		FROM	det_lcob d, factura f
		WHERE	d.fol_dlcob = f.fol_fac and d.ser_dlcob = f.ser_fac
				and d.fliq_dlcob = paramFolio
		UNION
		SELECT	DISTINCT cte_doc			
		FROM	det_lcob d , doctos do
		WHERE	d.fol_dlcob = do.fol_doc AND d.cia_dlcob = do.cia_doc and pla_dlcob = do.pla_doc
				ANd d.tip_dlcob = do.tip_doc AND d.fliq_dlcob = paramFolio
		
		LET vncte = vncte + 1;
	END FOREACH;
	
	IF vncte > 0 THEN
		UPDATE	liq_cob
		SET		ncte_lcob = vncte
		WHERE	fliq_lcob = paramFolio;
		LET vreturn = 'N';
	END IF;
	
	IF paramAction = 1 THEN
			SELECT	fec_lcob
			INTO	vfecha
			FROM	liq_cob
			WHERE	fliq_lcob = paramFolio;
		FOREACH cDLiquidacion FOR
			SELECT	d.num_dlcob, d.fec_dlcob, d.edo_dlcob,d.imp_dlcob
			INTO	vnum, vfecdet,vedo,vimp
			FROM	det_lcob d
			WHERE	d.fliq_dlcob = paramFolio
		
			LET vmov = vmov + 1;			
			/*IF (vfecdet <> vfecha AND vedo <> 'C') OR (vfecdet <= vfecha AND vedo = 'C') THEN 
				LET vfecdet = vfecha;
			END IF;*/
			UPDATE	det_lcob	
			SET		num_dlcob = vmov, fec_dlcob = vfecha
			WHERE	fliq_dlcob = paramFolio and num_dlcob = vnum;
			LET vreturn = 'D';
			IF vedo = 'P' THEN
				LET vimpp = vimpp + vimp;
			END IF;
			IF vedo = 'R' THEN
				LET vimpr = vimpr + vimp;
			END IF;
			IF	vedo MATCHES '[BDFHJMTVKLOS]' THEN
				LET vimpf = vimpf + vimp;
				LET vimptot = vimptot + vimp;
			END IF;
			IF	vedo = 'C' THEN
				LET vimpc = vimpc + vimp;
				LET vimptot = vimptot + vimp;
			END IF;
			IF	vedo = 'E' THEN
				LET vimpe = vimpe + vimp;
				LET vimptot = vimptot + vimp;
			END IF;		
		END FOREACH;
		UPDATE	liq_cob
		SET		impp_lcob = vimpp, impr_lcob = vimpr, impe_lcob = vimpe, impc_lcob = vimpc, impf_lcob = vimpf,
				impt_lcob = vimptot
		WHERE	fliq_lcob = paramFolio;
	END IF;
END IF;

IF paramAction = 2 THEN
	UPDATE	liq_cob
	SET		mcte_lcob = mcte_lcob + 1
	WHERE	fliq_lcob = paramFolio;
	LET vreturn = 'M';
END IF;

SELECT	ncte_lcob, mcte_lcob
INTO	vncte,vmcte
FROM	liq_cob
WHERE	fliq_lcob = paramFolio;

RETURN vreturn,vncte,vmcte;
END PROCEDURE; 

select	*
from	liq_cob --where tip_lcob = 'A' order by fec_lcob desc
where	fliq_lcob = 60339

select	*
from	det_lcob
where   fliq_dlcob = 61858

update	det_lcob
set		fec_dlcob = '2022-07-26'
where   fliq_dlcob = 61858 and num_dlcob in(9)

select	distinct f.numcte_fac
from	det_lcob d, factura f
where	d.fol_dlcob = f.fol_fac and d.ser_dlcob = f.ser_fac
		and d.fliq_dlcob = 44917
union
select	distinct n.numcte_nvta
from	det_lcob d, nota_vta n
where	d.fol_dlcob = n.fol_nvta and d.cia_dlcob = n.cia_nvta and pla_dlcob = n.pla_nvta
		and d.fliq_dlcob = 44931
		


