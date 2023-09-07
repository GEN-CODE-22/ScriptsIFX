DROP PROCEDURE CheckNoteDone;
EXECUTE PROCEDURE CheckNoteDone('15','01');

CREATE PROCEDURE CheckNoteDone
(
	paramCia CHAR(2),
	paramPla CHAR(2)
)

	RETURNING
		CHAR(10);				
	
	DEFINE control	CHAR(10);
	DEFINE vfolenr  CHAR(12);	
	DEFINE vfolnvta INT;	
	DEFINE vvuelta  SMALLINT;	
	DEFINE vedo_nvta CHAR(1);	
	DEFINE vlts_nvta DECIMAL;	
	DEFINE vedovtaenr CHAR(1);	
	DEFINE vciaplanta CHAR(4);	
	LET	control = 'A';
	LET vciaplanta = paramCia || paramPla;
	
	FOREACH cCursorFolios FOR
	
		SELECT  fol_enr,
				(fol_enr[5, 10] * 1),
				edovta_enr,
				vuelta_enr
		INTO	vfolenr,
				vfolnvta,
				vedovtaenr,
				vvuelta
		FROM	enruta
		WHERE   edoreg_enr IN('0','C','E','O')
				AND fol_enr[1,4] = vciaplanta
		ORDER BY fol_enr
				
	
		SELECT	nota_vta.edo_nvta,
				NVL(nota_vta.tlts_nvta,0)
		INTO	vedo_nvta,
				vlts_nvta
		FROM	nota_vta
		WHERE	nota_vta.fol_nvta 	= vfolnvta
				AND nota_vta.cia_nvta = paramCia
				AND nota_vta.pla_nvta = paramPla
				AND nota_vta.vuelta_nvta = vvuelta;
		
		IF vedo_nvta IN('S','A')  AND  vlts_nvta > 0 THEN
			UPDATE	enruta
			SET		edoreg_enr = 'F'
			WHERE	fol_enr = vfolenr					
					AND edoreg_enr IN('0','C','E','O');
			LET control = vfolenr;
		END IF;
		IF vedo_nvta IN('P') AND vedovtaenr <> '0' THEN
			UPDATE	enruta
			SET		edovta_enr = '0'
			WHERE	fol_enr = vfolenr
					AND edoreg_enr IN('0','C','E','O');
			LET control = vfolenr;
		END IF;
		IF vedo_nvta IN('C') AND vedovtaenr <> 'f' THEN
			UPDATE	enruta
			SET		edoreg_enr = 'C',
					edovta_enr = 'f'
			WHERE	fol_enr = vfolenr
					AND edoreg_enr IN('0','C','E','O');
			LET control = vfolenr;
		END IF;
	END FOREACH; 

	RETURN control;
	
END PROCEDURE;

select	count(*)
from	nota_vta
where	fol_nvta in(SELECT  (fol_enr[5, 10] * 1)
		FROM	enruta
		WHERE   edoreg_enr IN('0','C','E','O')
				AND fol_enr[1,4] = '1502')

SELECT  fol_enr,
				(fol_enr[5, 10] * 1),
				edovta_enr	
		FROM	enruta
		WHERE   edoreg_enr IN('0','C','E','O')
				AND fol_enr[1,4] = '1502'
		ORDER BY fol_enr
SELECT  *
FROM	enruta
WHERE   edoreg_enr IN('0','C','E','O')
		AND fol_enr[1,4] = '1502'	
		
SELECT  count(*)
FROM	enruta
WHERE   edoreg_enr IN('0','C','E','O')
		AND fol_enr[1,4] = '1502'

SELECT  fol_enr, count(*)
FROM	enruta
WHERE   edoreg_enr IN('0','C','E','O')
		AND fol_enr[1,4] = '1502'	
group by fol_enr
having count(*) > 1

select	fol_nvta, count(*)
from	nota_vta
where	pla_nvta = '01'
group by fol_nvta
having count(*) > 1

select	*
from	nota_vta
where	fol_nvta in(750399,765212,765214,768372,769157,772785,772786,774748,774749,783691,785675,792411,792412,795719)

select	*
from	enruta
where	fol_enr in('1502500610','1502500696','1502500696','1502505809')
		