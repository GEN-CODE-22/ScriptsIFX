CREATE PROCEDURE InsHrPed
(
	paramFec	DATE,
	paramHr		SMALLINT,
	paramCia	CHAR(2),
	paramPla	CHAR(2),	
	paramRu 	CHAR(4),
	paramCte	CHAR(6)
)


INSERT INTO hr_ped
VALUES(paramFec,paramHr,paramCia,paramPla,paramRu,paramCte);

END PROCEDURE;                     