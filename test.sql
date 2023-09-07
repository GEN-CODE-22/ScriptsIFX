 SELECT * INTO rdoc.* FROM doctos
    WHERE fol_doc = rdfct[j].fnvta_dfac AND
          ser_doc = "  "                AND
          cia_doc = rfac.cia_fac        AND
          pla_doc = rfac.pla_fac        AND
          ffac_doc = rfac.fol_fac       AND
          sfac_doc = rfac.ser_fac       AND
          (tip_doc = "01"               OR
          tip_doc >= "11"               AND
          tip_doc <= "99")              AND
          sal_doc > 0.0
select	doc.*
from	factura f, det_lcob d, det_fac df, doctos doc
where	f.cia_fac = d.cia_dlcob and f.pla_fac = d.pla_dlcob and f.fol_fac = d.fol_dlcob and f.ser_fac = d.ser_dlcob
		and df.cia_dfac = f.cia_fac and df.pla_dfac = f.pla_fac and df.fol_dfac = f.fol_fac and df.ser_dfac = f.ser_fac
		and doc.cia_doc = df.cia_dfac and doc.pla_doc = df.pla_dfac  and doc.fol_doc = df.fnvta_dfac and
		(tip_doc = "01" OR  tip_doc >= "11"               AND
          tip_doc <= "99")              AND
          sal_doc > 0.0
		and d.fliq_dlcob = 48275
order  by doc.fol_doc 






select	*
from	doctos
where	fol_doc in(3519,3520,3523,3524,3525,3526,3527,3529,3531) and 
		(tip_doc = "01"               OR
          tip_doc >= "11"               AND
          tip_doc <= "99")              AND
          sal_doc > 0.0

where	fol_fac in(select *
from	det_lcob
where	fliq_dlcob = 48275)   

select	*
from	empxrutp
where   fec_erup = '2018-11-30'
order by rut_erup

update	empxrutp
set		imp_erup = null
where	fliq_erup = 8628 and rut_erup = 'M004'

select	f.fol_fac, f.ser_fac, f.impt_fac, sum(n.impt_nvta + nvl(n.impasi_nvta, 0)), f.impt_fac - sum(n.impt_nvta + nvl(n.impasi_nvta, 0))
from	factura f, det_fac df, nota_vta n
where   f.fec_fac >= '2019-06-01'
		and f.cia_fac = df.cia_dfac and f.pla_fac = df.pla_dfac and f.fol_fac = df.fol_dfac and f.ser_fac = df.ser_dfac
		and n.fol_nvta = df.fnvta_dfac and n.pla_nvta = df.pla_dfac 
group	by 1,2,3
having  f.impt_fac <> sum(n.impt_nvta + nvl(n.impasi_nvta, 0)) 
		

execute procedure UpTotalLiqNew('15','08',2082,'M035');

drop procedure UpTotalLiqNew;
CREATE PROCEDURE UpTotalLiqNew(
	paramCompany		CHAR(2),					
	paramBranch			CHAR(2),
	paramLiq 			INTEGER,					
	paramRoute 			CHAR(4)
	)

	RETURNING
		CHAR(1);		
		
			
	DEFINE control		CHAR(1);			
	DEFINE minDate		CHAR(5);			
	DEFINE maxDate		CHAR(5);				
	DEFINE fesDate 		DATE;			
	DEFINE vimp_erup	DECIMAL;
	DEFINE vvcre_erup	DECIMAL;
	DEFINE vvefe_erup	DECIMAL;
	DEFINE vobser		CHAR(500);
	DEFINE vpend		CHAR(1);
	DEFINE vusrliq		CHAR(8);
	DEFINE vfusrliq		CHAR(8);
	DEFINE vcusrliq		INT;
	DEFINE vtusrliq		INT;
	DEFINE vfolnvtate	INT;
	DEFINE vtltsnvtate	DECIMAL;
	DEFINE vimptnvtate	DECIMAL;
	DEFINE vimptasist	DECIMAL;
	DEFINE vimptasistc	DECIMAL;
	DEFINE vimptotasis	DECIMAL;
	DEFINE vtpanvtate	CHAR(1);
	
	
		
	SELECT	SUM(NVL(impt_nvta,0)),SUM(NVL(impasi_nvta,0))
	INTO	vvcre_erup,vimptasistc
	FROM	nota_vta
	WHERE	cia_nvta 		= paramCompany
			AND pla_nvta	= paramBranch
			AND ruta_nvta	= paramRoute
			AND fliq_nvta	= paramLiq
			AND tpa_nvta	IN('C','G');
			
	SELECT	SUM(NVL(impt_nvta,0)), SUM(NVL(impasi_nvta,0))
	INTO	vvefe_erup, vimptasist
	FROM	nota_vta
	WHERE	cia_nvta 		= paramCompany
			AND pla_nvta	= paramBranch
			AND ruta_nvta	= paramRoute
			AND fliq_nvta	= paramLiq
			AND tpa_nvta	IN('E');
			
	LET vimptotasis = NVL(vimptasist,0) + NVL(vimptasistc,0);		
	LET vimp_erup = NVL(vvcre_erup,0) + NVL(vvefe_erup,0) + NVL(vimptotasis,0);
		
	UPDATE	empxrutp
	SET		imp_erup 		= vimp_erup,
			vefe_erup 		= vvefe_erup,
			impase_erup		= NVL(vimptasist,0),
			impasc_erup		= NVL(vimptasistc,0),
			impasi_erup 	= vimptotasis
	WHERE	fliq_erup 		= paramLiq
			AND cia_erup 	= paramCompany
			AND pla_erup	= paramBranch
			AND rut_erup    = paramRoute;
		
	
	
	
	LET control = 'A';
	
	RETURN	control;

END PROCEDURE;	