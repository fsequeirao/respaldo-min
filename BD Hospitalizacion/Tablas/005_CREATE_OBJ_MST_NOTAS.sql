CREATE OR REPLACE TYPE HOSPITALARIO.OBJ_MST_NOTAS AS OBJECT
(
detNotaId          NUMBER(10),
AdminServId        NUMBER(10),     -- 
fechaNota          DATE,
mperSaludId        NUMBER(10),
persaludEvoNotaId  NUMBER (10),
tipoNotaId         NUMBER(10),
FecInicio          DATE,   
FecFin             DATE,
AdmisionId         NUMBER(19)
)
/
