CREATE OR REPLACE TYPE HOSPITALARIO.OBJ_ADMSRV_CAMAS AS OBJECT
(
AdminServCamaId    NUMBER(10),
CfgUsalServCamaId  NUMBER(10),
AdminServId        NUMBER(10),     -- 
IsLast             NUMBER(10),
UnidadSaludId      NUMBER(10),  
FecInicio          DATE,   
FecFin             DATE
)
/