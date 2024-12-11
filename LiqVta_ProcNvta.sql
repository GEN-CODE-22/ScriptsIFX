DROP PROCEDURE LiqVta_ProcNvta;
EXECUTE PROCEDURE  LiqVta_ProcNvta(4347, 'B021','B','edith');

CREATE PROCEDURE LiqVta_ProcNvta
(
	paramFolio  INT,
	paramRuta	CHAR(4),
	paramTipo	CHAR(1),
	paramUsr	CHAR(8)
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(100);		-- Mensaje error
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(100);
DEFINE vimpasi	DECIMAL;
DEFINE vfolio	INT;
DEFINE vfecha	DATE;
DEFINE vcia		CHAR(2);
DEFINE vpla		CHAR(2);
DEFINE vvuelta	INT;
DEFINE vnapl	CHAR(1);
DEFINE vtpa		CHAR(1);  
DEFINE vimpt	DECIMAL;
DEFINE vimpta	DECIMAL;
DEFINE vnocte	CHAR(6);
DEFINE vnotqe	SMALLINT;
DEFINE vtipcte	CHAR(1);
DEFINE vgps		CHAR(30);
DEFINE vusr		CHAR(8);
DEFINE vhoras	DATETIME HOUR TO MINUTE;
DEFINE vpedido  INT;
DEFINE vultcar	DATE;
DEFINE vproxcar	DATE;
DEFINE vdiasca	SMALLINT;

LET vresult= 1;
LET vmensaje = '';
LET vgps = '';

FOREACH cNotas FOR
	SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta, NVL(impasi_nvta, 0), napl_nvta, tpa_nvta, impt_nvta, 
			NVL(numtqe_nvta,0), numcte_nvta, usr_nvta, NVL(ped_nvta,0), fes_nvta
	INTO	vcia,vpla,vfolio,vvuelta,vimpasi,vnapl,vtpa,vimpt,vnotqe,vnocte,vusr,vpedido,vfecha
	FROM	nota_vta 
	WHERE	fliq_nvta = paramFolio AND ruta_nvta = paramRuta
	
	--ACTUALIZA CXC--------------------------------------------------------------------------------------------------------------
	IF vnapl <> 'C' AND (vtpa = 'C' OR vtpa = 'G') THEN	
		SELECT	tip_cte
		INTO	vtipcte
		FROM	cliente
		WHERE	num_cte = vnocte;
		
		IF vtipcte = 'A' OR vtipcte = 'S' THEN
			LET vtpa = vtipcte;
		END IF;
		
		UPDATE	nota_vta
		SET		tpa_nvta = vtpa, fes_nvta = vfecha
		WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
		
		LET vresult,vmensaje,vimpta = cxc_altadocumento(vfolio,vcia,vpla,vvuelta,'01','',paramUsr);
		
		IF	vresult = 1 THEN
			UPDATE	nota_vta
			SET		napl_nvta = 'C'
			WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
		END IF;		
	END IF;
	
	UPDATE	nota_vta
	SET		edo_nvta = 'A'
	WHERE	cia_nvta = vcia AND pla_nvta = vpla AND fol_nvta = vfolio AND vuelta_nvta = vvuelta;
	
	--ACTUALIZA TANQUE---------------------------------------------------------------------------------------------------
	IF vnotqe > 0 THEN
		SELECT	NVL(gps_mnvta,'')
		INTO	vgps
		FROM	movxnvta
		WHERE	cia_mnvta = vcia AND pla_mnvta = vpla AND fol_mnvta = vfolio AND vuelta_mnvta = vvuelta and mov_mnvta = 1;
		
		IF vgps = '' OR vgps IS NULL THEN
			SELECT	NVL(gps_tqe,'')
			INTO	vgps
			FROM	tanque
			WHERE	numcte_tqe = vnocte AND numtqe_tqe = vnotqe;
		END IF;
		
		LET vultcar,vdiasca,vproxcar = ucpc_tqe(vfecha,vnocte,vnotqe);
		UPDATE	tanque
		SET		gps_tqe = vgps, ultcar_tqe = vultcar, diasca_tqe = vdiasca, proxca_tqe = vproxcar
		WHERE	numcte_tqe = vnocte AND numtqe_tqe = vnotqe;
	END IF;
	
	--ACTUALIZA PEDIDO---------------------------------------------------------------------------------------------------
	IF vpedido > 0	THEN
		SELECT	EXTEND(fhs_mnvta, HOUR TO MINUTE)
		INTO	vhoras
		FROM	movxnvta
		WHERE	cia_mnvta = vcia AND pla_mnvta = vpla AND fol_mnvta = vfolio AND vuelta_mnvta = vvuelta and mov_mnvta = 1;
		
		UPDATE	pedidos
		SET		edo_ped = 'S',
				fecrsur_ped = vfecha,
				horrsur_ped = vhoras,
				usrcan_ped = vusr
		WHERE	num_ped = vpedido;
	END IF;
END FOREACH;

RETURN 	vresult,vmensaje;
END PROCEDURE; 

select	*
from	empxrutp

select * 
from	venxmed

select * 
from	des_dir

select	*
from	empxrutc

select * 
from	venxand

select * 
from	gto_gas


select * 
from	gto_die

SELECT	cia_nvta, pla_nvta, fol_nvta, vuelta_nvta, NVL(impasi_nvta, 0), napl_nvta, tpa_nvta, impt_nvta, 
		NVL(numtqe_nvta,0), numcte_nvta, usr_nvta, NVL(ped_nvta,0), fes_nvta
FROM	nota_vta 
WHERE	fliq_nvta = 4347 AND ruta_nvta = 'B021'

execute procedure ucpc_tqe('2023-11-05',091723,4);

SELECT	*
FROM	movxnvta
WHERE	cia_mnvta = '15' AND pla_mnvta ='44' AND fol_mnvta = 311174 AND vuelta_mnvta = 1 and mov_mnvta = 1;

SELECT	NVL(gps_mnvta,'')
FROM	movxnvta
WHERE	cia_mnvta = '15' AND pla_mnvta = '44' AND fol_mnvta = 311174 AND vuelta_mnvta = 1 and mov_mnvta = 1;
select	*
from	pedidos
where   num_ped = 3281223
311174
311176
