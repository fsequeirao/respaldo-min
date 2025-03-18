CREATE OR REPLACE TYPE HOSPITALARIO.OBJ_PRE_INGRESO AS OBJECT
(
PregIngresoId      NUMBER(10),              
AdmisionId         NUMBER(10),
ProcedenciaId      NUMBER(10),     -- 
PerNominalId       NUMBER(10),     --
ExpedienteId       NUMBER(10),     --
NombreCompleto     VARCHAR2 (500), --
CodExpElectronico  VARCHAR2(50),
Identificacion     VARCHAR2(50),
MedOrdenaIngId     NUMBER(10),
ServProcedenId     NUMBER(10),
AdminSolicIngId    NUMBER(10),
FecInicio          DATE,   
FecFin             DATE,
UsalIngresoId      NUMBER(10),
UsalProcedeId      NUMBER(10),
ReferenciaId       NUMBER(10),
EstadoPreIngId     NUMBER(10),
EstadoPxId         NUMBER(10)  --,
--Reingreso          NUMBER(1)
)
/