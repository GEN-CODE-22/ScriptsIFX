CREATE PROCEDURE InsChangeLiq(
	paramCia	CHAR(2),
	paramPla	CHAR(2),
	paramFol	INTEGER,		
	paramUsr	CHAR(8),
	paramCbo	CHAR(100)
)
DEFINE vfliq INTEGER;
DEFINE vruta CHAR(4);

SELECT	fliq_nvta,
		ruta_nvta
INTO	vfliq,
		vruta
FROM	nota_vta
WHERE	cia_nvta 		= paramCia
		AND pla_nvta 	= paramPla
		AND fol_nvta	= paramFol;
		

INSERT INTO changes_liq(liq_cliq,cia_cliq,pla_cliq,ruta_cliq,nvta_cliq,usr_cliq,cambio_cliq,fecha_cliq)
VALUES(vfliq,paramCia,paramPla,vruta,paramFol,paramUsr,paramCbo,CURRENT);	

END PROCEDURE;	

						