CREATE PROCEDURE get_refbanco
(
	tpago 	CHAR(1),
	numcte	CHAR(6),
	folnvta INT,
	cia		CHAR(2),
	planta  CHAR(2)
)
RETURNING 
 CHAR(40);

DEFINE vrefban	CHAR(40);
DEFINE vimpcod	CHAR(1);
DEFINE vbitalp	CHAR(5);
DEFINE vbancre	CHAR(30);
DEFINE vdatdig	CHAR(30);
DEFINE vdigitov	CHAR(1);

LET vrefban = '';

SELECT	impcod_dat,
		bancre_dat
INTO	vimpcod,
		vbancre
FROM	datos;

SELECT	bital_pla
INTO	vbitalp
FROM	planta
WHERE	cia_pla = cia
		AND cve_pla = planta;


IF tpago = "G" THEN
	IF vimpcod = "P" THEN
    	LET vdatdig 	= "0" || vbitalp || numcte || LPAD(folnvta,6,'0');
    	LET vdigitov 	= get_udigito(vdatdig);
	    LET vrefban 	= "Pague en: " || vbancre[1,10] || vbitalp || "R:" || numcte || LPAD(folnvta,6,'0') || vdigitov;
 	ELSE
    	IF vimpcod = "S" THEN
	       LET vdatdig 	= vbitalp || "0" ||  numcte || LPAD(folnvta,6,'0');
	       LET vdigitov = get_udigito(vdatdig);
	       LET vrefban 	= "Pague en: " || vbancre[1,10] || vbitalp[3,5] || " REF" || numcte || LPAD(folnvta,6,'0') || vdigitov;
	    ELSE
	       LET vrefban = "Pague en: " || vbancre;
	    END IF;
 END IF;
END IF;

RETURN vrefban;
END PROCEDURE;  