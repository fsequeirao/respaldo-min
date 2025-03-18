CREATE OR REPLACE TYPE HOSPITALARIO.OBJ_INGRESO_EGRESO AS OBJECT
(
IngresoId          NUMBER(10),     --
PregIngresoId      NUMBER(10),
PerNominalId       NUMBER(10),     --
ExpedienteId       NUMBER(10),     --
NombreCompleto     VARCHAR2 (500), --
ProcedenciaId      NUMBER(10),     -- 
CodExpElectronico  VARCHAR2(50),
Identificacion     VARCHAR2(50),
AdmisionId         NUMBER(10),
MedicoIngId        NUMBER(10),      
AdminSolicIngId    NUMBER(10),
AdmisionistaIngId  NUMBER(10),
MedOrdenaIngId     NUMBER(10),
ServProcedenId     NUMBER(10),
Reingreso          NUMBER(1),
FecInicio          DATE,   
FecFin             DATE,
UsalProcedeId      NUMBER(10), 
UsalIngresoId      NUMBER(10),    
ServIngresoId      NUMBER(10),   
EstadoIngId        NUMBER(10),
TipoEgresoId       NUMBER(10),
ServEgresoId       NUMBER(10),     
MedicoEgresoId     NUMBER(10),
EsContraferido     NUMBER(1),   
EstadoPxId         NUMBER(10),       
EstadoPxEgresoId   NUMBER(10)
)
/