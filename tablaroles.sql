CREATE TABLE sicogas:usr_rol
(
	usr_urol	CHAR(8) 	NOT NULL,
	rol_urol	SMALLINT	NOT NULL,	
	PRIMARY KEY(usr_urol,rol_urol)
)

insert into usr_rol values('pueblito',5)

select	*
from	usr_rol

delete
from	usr_rol 
where   usr_urol = 'pueblito'