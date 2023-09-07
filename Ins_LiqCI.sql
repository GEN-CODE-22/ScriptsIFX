CREATE PROCEDURE Ins_LiqCI
(
	paramFolio	INT,	
	paramCia 	CHAR(2),
	paramPla 	CHAR(2),
	paramOdom 	DECIMAL,
	paramEco 	CHAR(7),
	paramUsr    CHAR(8)
)
RETURNING
		CHAR(1);

	DEFINE vmov		SMALLINT;	
	DEFINE veco  	CHAR(6);	
	DEFINE vcte  	CHAR(6);	
	DEFINE vobserlog	CHAR(100);
	DEFINE vcontrol		CHAR(1);		
	
	LET veco = '';
	LET vmov = 0;
	LET vcte = '';
	
	SELECT	numcte_nvta
	INTO	vcte
	FROM	nota_vta
	WHERE	fol_nvta 		= paramFolio
			AND cia_nvta	= paramCia
			AND pla_nvta	= paramPla;		
	
	SELECT	MAX(mov_mnvta)
	INTO	vmov
	FROM	movxnvta
	WHERE	fol_mnvta 		= paramFolio
			AND cia_mnvta	= paramCia
			AND pla_mnvta	= paramPla;
	
	INSERT INTO det_odom
	VALUES(paramFolio,paramCia,paramPla,vmov,paramEco,paramOdom);
	
	LET vobserlog = 'CONSUMO INTERNO NOTA[' || paramFolio || '] CLIENTE [' || vcte || '] ODOM [' || paramOdom || ']';
	EXECUTE PROCEDURE InsChangeLiq(paramCia,paramPla,paramFolio,paramUsr,vobserlog);	
	
	RETURN	'A';
	
END PROCEDURE;