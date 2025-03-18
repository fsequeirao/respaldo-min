CREATE OR REPLACE TYPE HOSPITALARIO.OBJ_INDISPONIBILIDAD_CAMAS AS OBJECT
(
IndCamaId         NUMBER(10),      
CfgUsalServCamaId NUMBER(10),
CamaId            NUMBER(10),
CausaId           NUMBER(10),
UnidSsaludId      NUMBER(10),
FecSalidaInicio   DATE,
FecSalidaFin      DATE
)
/