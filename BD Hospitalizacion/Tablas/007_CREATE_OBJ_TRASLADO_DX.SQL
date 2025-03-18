CREATE OR REPLACE
TYPE              HOSPITALARIO.OBJ_TRASLADO_DX AS OBJECT
(
TrasladoId                NUMBER(10),
ServicioOrgId             NUMBER(10),
ServicioDestId            NUMBER(10),
CfgUsldServicioCamaOrgId  NUMBER(10),
CfgUsldServicioCamaDestId NUMBER(10),
mperSaludId               NUMBER(10),   -- MedicoOrdenaTrasladoId    NUMBER(10),
ingresoId                 NUMBER(10),
AdminServId               NUMBER(10),
TipoDxIngEg               NUMBER(10),
TipoDxId                  NUMBER(10),    
FecInicio                 DATE,   
FecFin                    DATE
)
/










