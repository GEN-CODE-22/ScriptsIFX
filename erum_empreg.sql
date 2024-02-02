DROP PROCEDURE erum_empreg;
EXECUTE PROCEDURE  erum_empreg('M002','2022-01-15','656',10,2197,'04','N');
EXECUTE PROCEDURE  erum_empreg('M002','2022-01-15','656',10,2197,'04','S');

CREATE PROCEDURE erum_empreg
(
	paramFolio	INT,
	paramRuta	CHAR(4),
	paramFecha	DATE,
	paramEmp	CHAR(5),
	paramNcant	INT,
	paramVta	DECIMAL,
	paramTipo	CHAR(2)
)

RETURNING  
 INT,			-- Resultado 1 = OK  0 = Error
 CHAR(30);		-- Mensaje error
 
DEFINE vresult  INT;
DEFINE vmensaje CHAR(30);

LET vresult = 1;
LET vmensaje = '';

IF	NOT EXISTS(SELECT 1 
		FROM vtaxemp 
		WHERE emp_vemp = paramEmp AND fec_vemp = paramFecha /*AND  ruta_vemp = paramRuta*/ AND coa_vemp = paramTipo) THEN
	INSERT INTO vtaxemp VALUES(paramEmp,paramFecha,paramTipo,paramRuta,0,0.00,'L',0);
	LET vresult = 1;
	LET vmensaje = 'INSERTO VENTA';
END IF;

RETURN 	vresult,vmensaje;
END PROCEDURE; 

select	*
from	empleado
where	cve_emp = '91'

select	*
from	venxmed where fec_vmed = '2024-01-13' order by rut_vmed

select	*
from	vtaxemp
where	fec_vemp = '2024-01-13' and emp_vemp = '443' ruta_vemp = 'M030'

delete
from	vtaxemp
where	fec_vemp = '2024-01-13' and emp_vemp = '443' and ruta_vemp = 'M030'

select	*
from	vtaxemp
where 	lok_vemp = 'L' and fec_vemp >= '2022-01-01'
order by fec_vemp desc

select	*	
from	vtaxemp
where	emp_vemp = '656' and fec_vemp = '2022-01-15' and ruta_vemp = 'M002' and coa_vemp = '04'

delete	
from	vtaxemp
where	emp_vemp = '656' and fec_vemp = '2022-01-15' and ruta_vemp = 'M002' and coa_vemp = '04' and ncon_vemp = 0
