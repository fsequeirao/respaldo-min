CREATE OR REPLACE TYPE HOSPITALARIO.OBJ_DIAGNOSTICOS AS OBJECT
(
diagnosticoId      NUMBER(10),
RelDxIngEgId       NUMBER(10),
IngresoId          NUMBER(10),
TrasladoId         NUMBER(10),
AdminServId        NUMBER(10),     -- 
mperSaludId        NUMBER(10),
fechaSolucion      DATE,
TipoDxId           NUMBER(10),
TipoDxIngEg        NUMBER(10),
FecInicio          DATE,   
FecFin             DATE
)
/
