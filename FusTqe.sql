CREATE PROCEDURE FusTqe
(
	paramCte		CHAR(6),
	paramTqeDup		INT,	
	paramTqeOri   	INT,
	paramUsrBaj		CHAR(8)		
)

UPDATE	nota_vta
SET		numtqe_nvta 	= paramTqeOri
WHERE	numcte_nvta 	= paramCte
		AND numtqe_nvta	= paramTqeDup;

UPDATE	rdnota_vta
SET		numtqe_nvta 	= paramTqeOri
WHERE	numcte_nvta 	= paramCte
		AND numtqe_nvta	= paramTqeDup;

UPDATE	hnota_vta
SET		numtqe_nvta 	= paramTqeOri
WHERE	numcte_nvta 	= paramCte
		AND numtqe_nvta	= paramTqeDup;

UPDATE	pedidos
SET		numtqe_ped 		= paramTqeOri
WHERE	numcte_ped 		= paramCte
		AND numtqe_ped 	= paramTqeDup;

UPDATE	hpedidos
SET		numtqe_ped 		= paramTqeOri
WHERE	numcte_ped 		= paramCte
		AND numtqe_ped 	= paramTqeDup;

UPDATE	tanque
SET		stat_tqe		= 'B',
		fecbaj_tqe  	= CURRENT,
		usrbaj_tqe  	= paramUsrBaj
WHERE	numcte_tqe		= paramCte
		AND numtqe_tqe	= paramTqeDup;

END PROCEDURE;