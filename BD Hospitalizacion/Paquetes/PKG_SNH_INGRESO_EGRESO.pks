CREATE OR REPLACE PACKAGE HOSPITALARIO.PKG_SNH_INGRESO_EGRESO
   AUTHID CURRENT_USER
AS
   SUBTYPE MAXVARCHAR2 IS VARCHAR2(32000);
   kPAQUETE_FIRMA MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.';
   --Declaración Constantes
   -- --------------------
   vDncQry                   VARCHAR2 (32000);
   kTextoReemplazar          VARCHAR2 (50) := ';|\$|%|\*|/|#|´|!|\\|\&|\''';
--   

   TYPE array_str_data_persona IS TABLE OF VARCHAR2 (1250)
       INDEX BY PLS_INTEGER;
   TYPE array_ids IS TABLE OF INTEGER INDEX BY PLS_INTEGER;

   -- Cursores
-- fsequeira
   TYPE var_refcursor IS REF CURSOR;

   TYPE refIngEgreso IS REF CURSOR RETURN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS%ROWTYPE; 
   TYPE refPregIngresos IS REF CURSOR RETURN HOSPITALARIO.SNH_MST_PREG_INGRESOS%ROWTYPE;     
   TYPE refCadminRelCamaServ IS REF CURSOR RETURN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS%ROWTYPE;
   TYPE refCatCamas IS REF CURSOR RETURN HOSPITALARIO.SNH_CAT_CAMAS%ROWTYPE;
   TYPE refCfgCamas IS REF CURSOR RETURN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS%ROWTYPE;
   TYPE refIndispCamas IS REF CURSOR RETURN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS%ROWTYPE;   
   
   TYPE mstNotas IS RECORD (
                           id                 HOSPITALARIO.SNH_MST_NOTAS.DET_NOTA_ID%TYPE, 
                           admisionServicioId HOSPITALARIO.SNH_MST_NOTAS.ADMISION_SERVICIO_ID%TYPE, 
                           fecha              VARCHAR2(15),  -- HOSPITALARIO.SNH_MST_NOTAS.FECHA_NOTA%TYPE, 
                           hora               HOSPITALARIO.SNH_MST_NOTAS.HORA_NOTA%TYPE, 
                           mPersSaludId       HOSPITALARIO.SNH_MST_NOTAS.MPERS_SALUD_ID%TYPE, 
                           tipoNotaId         HOSPITALARIO.SNH_MST_NOTAS.TIPO_NOTA_ID%TYPE,
                           codigo             CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE
                           );
    TYPE refMstNotas IS REF CURSOR RETURN mstNotas;

   TYPE detNotas IS RECORD (
                           idMstNotas      HOSPITALARIO.SNH_MST_NOTAS.DET_NOTA_ID%TYPE, 
                           id              HOSPITALARIO.SNH_DET_NOTAS.PERSALUD_EVO_NOTA_ID%TYPE,
                           descripcionNota VARCHAR2(500),
                           comentario      HOSPITALARIO.SNH_DET_NOTAS.COMENTARIOS%TYPE,
                           tipNotaDetId    HOSPITALARIO.SNH_DET_NOTAS.TIPO_DET_NOTA_ID%TYPE,
                           codigo          CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE 
                           );    
   TYPE refDetNotas IS REF CURSOR RETURN detNotas;   
    
   TYPE DIAGNOSTICOS_REL_ING_EGR IS RECORD (ingresoId         HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG.INGRESO_ID%TYPE,  
                                            admisionServId    HOSPITALARIO.SNH_MST_DIAGNOSTICOS.ADMISION_SERVICIO_ID%TYPE,
                                            diagnosticoId     HOSPITALARIO.SNH_MST_DIAGNOSTICOS.DIAGNOSTICO_ID%TYPE,
                                            mpersSaludId      HOSPITALARIO.SNH_MST_DIAGNOSTICOS.MPERS_SALUD_ID%TYPE,
                                           --evolucionNotaId  HOSPITALARIO.SNH_MST_DIAGNOSTICOS.EVOLUCION_NOTA_ID%TYPE,
                                            cieId             HOSPITALARIO.SNH_MST_DIAGNOSTICOS.CIE_ID%TYPE,
                                            usrCodificaCie    HOSPITALARIO.SNH_MST_DIAGNOSTICOS.USR_CODIFICA_CIE%TYPE,
                                            RelDxIngEgId      HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG.REL_DX_ING_EG_ID%TYPE,
                                            tipoDxCodigo      CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                            TipoDiagnostico   CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                            diagnostico       HOSPITALARIO.SNH_MST_DIAGNOSTICOS.DIAGNOSTICO%TYPE  --,
                                --fechaSolucion   HOSPITALARIO.SNH_MST_DIAGNOSTICOS.FECHA_SOLUCION%TYPE
                                            );
   TYPE refDxRelIngEg IS REF CURSOR RETURN DIAGNOSTICOS_REL_ING_EGR;             
       
    
   TYPE TRASLADO_ENTRE_SERV IS RECORD (TrasladoId                HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.TRASLADO_ID%TYPE,
                                       ServicioOrgId             HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.SERVICIO_ORG_ID%TYPE,
                                       ServicioDestId            HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.SERVICIO_DEST_ID%TYPE,
                                       CfgUsldServicioCamaOrgId  HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.CFG_USLD_SERVICIO_CAMA_ORG_ID%TYPE,
                                       CfgUsldServicioCamaDestId HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.CFG_USLD_SERVICIO_CAMA_DEST_ID%TYPE,
                                       MedicoOrdenaTrasladoId    HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.MEDICO_ORDENA_TRASLADO_ID%TYPE,
                                       MotivoTraslado            HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.MOTIVO_TRASLADO%TYPE,
                                       FechaTraslado             HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.FECHA_TRASLADO%TYPE,
                                       HoraTraslado              HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.HORA_TRASLADO%TYPE,
                                       EstadoTraslado_Id         HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.ESTADO_TRASLADO_ID%TYPE,
                                       Observaciones             HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.OBSERVACIONES%TYPE,
                                       ingresoId                 HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG.INGRESO_ID%TYPE,  
                                       admisionServId            HOSPITALARIO.SNH_MST_DIAGNOSTICOS.ADMISION_SERVICIO_ID%TYPE,
                                       diagnosticoId             HOSPITALARIO.SNH_MST_DIAGNOSTICOS.DIAGNOSTICO_ID%TYPE,
                                       mpersSaludId              HOSPITALARIO.SNH_MST_DIAGNOSTICOS.MPERS_SALUD_ID%TYPE,
                                       relDxIngEgId              HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG.REL_DX_ING_EG_ID%TYPE,
                                       tipoDxCodigo              CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                       TipoDiagnostico           CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                       diagnostico               HOSPITALARIO.SNH_MST_DIAGNOSTICOS.DIAGNOSTICO%TYPE,
                                       cieId                     HOSPITALARIO.SNH_MST_DIAGNOSTICOS.CIE_ID%TYPE,
                                       usrCodificaCie            HOSPITALARIO.SNH_MST_DIAGNOSTICOS.USR_CODIFICA_CIE%TYPE
                               );                                         
   
   TYPE refTrasEntreServ IS REF CURSOR RETURN TRASLADO_ENTRE_SERV;    
   
   kINSERT              CONSTANT CHAR (1) := 'I';
   kUPDATE              CONSTANT CHAR (1) := 'U';
   kDELETE              CONSTANT CHAR (1) := 'D';
   kCONSULTAR           CONSTANT CHAR (1) := 'C';  
   kCONSULTAR_UNIFICADO CONSTANT CHAR (2) := 'CU';  -- tipo consulta para que devuelva la persona Activa, que queda luego de unificación.
   kCONSULTARID         CONSTANT CHAR (2) := 'CI';
   K_CAT_REG_ACT        CHAR (6) := 'ACTREG';
   K_CAT_REG_PAS        CHAR (6) := 'PASREG';
   K_CAT_REG_DEL        CHAR (6) := 'DELREG';
   K_STATE_REG          CHAR (5) := 'STREG';
   kFUENTE_PERSONA      CHAR (1) := 'P';
   kFUENTE_PERSONA_PREG CHAR (2) := 'PR';
   kES_PRINCIPAL        SIMPLE_INTEGER := 1;
   kNICARAGUA           CHAR(3) := '558';
   kCOMODIN_RNAC        CHAR(4) := '9999';
   kINGRESO             CHAR(1) := 'I';
   kEGRESO              CHAR(1) := 'E';
   
   kORIGEN_CONSULTA     CHAR(1) := 'R';  -- Relación persona
   kCAT_GRUPETNIA        CONSTANT VARCHAR2(15 CHAR) := 'CNF_CATSISTEMAS';    

  eRegistroExiste      EXCEPTION;
  eRegistroNoExiste    EXCEPTION;
  eParametrosInvalidos EXCEPTION;
  eParametroNull       EXCEPTION;
  eSalidaConError      EXCEPTION;
  ePasivarInvalido     EXCEPTION;
  eUpdateInvalido      EXCEPTION;    
  
  kACCIONESTADO_PASIVO_TRUE CONSTANT NUMBER := 1;
  vGLOBAL_MSGERROR          varchar2(1000);
  vGLOBAL_ESTADO_ACTIVO     CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_REGISTRO ('Activo');  -- fs
  vGLOBAL_ESTADO_ELIMINADO  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_REGISTRO ('Eliminado'); 
  vGLOBAL_ESTADO_PASIVO     CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_REGISTRO ('Pasivo'); 
  vGLOBAL_ESTADO_PRECARGADO CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_REGISTRO ('Precargado');
  vGLOBAL_ESTADO_UNIFICADO  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_REGISTRO ('Unificado'); 
  
  vGLOBAL_ESTPREING_INGRESADO  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_PREINGRESO ('STSLPRG|ING');
  vGLOBAL_ESTPREING_EGRESADO  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_PREINGRESO ('STSLPRG|EGR');
  
  vGLOBAL_ESTCAMA_DISPONIBLE    CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_CAMA ('ESTADOCAMA|DISPONIBLE'); 
  vGLOBAL_ESTCAMA_OCUPADA       CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_CAMA ('ESTADOCAMA|OCUPADA');  
  vGLOBAL_ESTCAMA_NO_DISPONIBLE CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE := HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_ESTADO_CAMA ('ESTADOCAMA|NO_DISPONIBLE');  
  
  -- FUNCTION json return JSON_OBJECT_T;
  PROCEDURE PR_CRUD_PRE_INGRESO (pPregIngresoId      IN OUT HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE,               
                                 pAdmisionId         IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISION_ID%TYPE,
                                 pProcedenciaId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PROCEDENCIA_ID%TYPE,
                                 pPerNominalId       IN CATALOGOS.SBC_MST_PERSONAS_NOMINAL.PER_NOMINAL_ID%TYPE,
                                 pCodExpElectronico  IN CATALOGOS.SBC_MST_PERSONAS_NOMINAL.CODIGO_EXPEDIENTE_ELECTRONICO%TYPE,
                                 pExpedienteId       IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE,
                                 pNomCompletoPx      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.NOMBRE_COMPLETO_PX%TYPE,
                                 pMedOrdenaIngId     IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE,
                                 pUsalOrigenId       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_ORIGEN_ID%TYPE,
                                 pServProcedenId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE,
                                 pAdminSolicIngId    IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE,
                                 pFecSolicitaIng     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.FECHA_SOLICITUD_INGRESO%TYPE,
                                 pHrSolicitudIng     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.HORA_SOLICITUD_INGRESO%TYPE,
                                 pUsalDestinoId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE,
                                 pReferenciaId       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.REFERENCIA_ID%TYPE,
                                 pEspDestinoId       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESPECIALIDAD_DESTINO_ID%TYPE,
                                 pEstadoPreIngId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PRE_INGRESO_ID%TYPE,
                                 pComentarios        IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.COMENTARIOS%TYPE,
                                 pTipIdentiId        IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.TIPO_IDENTIFICACION_ID%TYPE,
                                 pIdentificacion     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.IDENTIFICACION%TYPE,
                                 pEstadoPxId         IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PX_ID%TYPE,
                                 pUsuario            IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                 pFecInicio          IN DATE,
                                 pFecFin             IN DATE,
                                 pAccionEstado       IN VARCHAR2,
                                 pTipoAccion         IN VARCHAR2,
                                 pPgn                IN NUMBER,
                                 pPgnAct             IN NUMBER default 1,  
                                 pPgnTmn             IN NUMBER default 100,
                                 pDatosPaginacion    OUT var_refcursor,
                                 --pJson               IN VARCHAR2,
                                 pRegistro           OUT var_refcursor,
                                 pResultado          OUT VARCHAR2,
                                 pMsgError           OUT VARCHAR2);
                                   
  PROCEDURE PR_CRUD_INGRESO_EGRESO (pIngresoId          IN OUT SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE,                                         
                                    pPregIngresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PREG_INGRESO_ID%TYPE,                     
                                    pPerNominalId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PER_NOMINAL_ID%TYPE,                
                                    pProcedenciaId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PROCEDENCIA_ID%TYPE,                
                                    pAdmisionId         IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISION_SERVICIO_ID%TYPE,                     
                                    pEdadExactaIng      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.EDAD_EXACTA_INGRESO%TYPE,           
                                    pGrupoEtareoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.GRUPO_ETAREO_ID%TYPE,               
                                    pMedicoIngId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_INGRESO_ID%TYPE,             
                                    pAdminSolicIngId    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_SOLICITA_INGR_ID%TYPE, 
                                    pAdmisionistaIngId  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_INGRESO_ID%TYPE,       
                                    pMedOrdenaIngId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_ORDENA_INGRESO_ID%TYPE,      
                                    pServProcedenId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE,       
                                    pReingreso          IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO%TYPE,                     
                                    pReingresoId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO_ID%TYPE,                  
                                    pFecSolicitaIng     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_SOLICITUD_INGRESO%TYPE,       
                                    pHrSolicitudIng     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_SOLICITUD_INGRESO%TYPE,        
                                    pFecInicioIngreso   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_INICIO_INGRESO%TYPE,          
                                    pHrInicioIngreso    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_INICIO_INGRESO%TYPE,           
                                    pUsalIngresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.UNIDAD_SALUD_INGRESO%TYPE,          
                                    pServIngresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_INGRESO_ID%TYPE,           
                                    pEstadoIngId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_INGRESO_ID%TYPE,             
                                    pTipoEgresoId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.TIPO_EGRESO_ID%TYPE,                
                                    pFecFinIngreso      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_FIN_INGRESO%TYPE,             
                                    pHrFinIngreso       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_FIN_INGRESO%TYPE,              
                                    pServEgresoId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_EGRESO_ID%TYPE,            
                                    pMedicoEgresoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_EGRESO_ID%TYPE,              
                                    pReferenciaId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REFERENCIA_ID%TYPE,                 
                                    pEsContraferido     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ES_CONTRAFERIDO%TYPE,               
                                    pEnvContrareferId   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ENVIO_CONTRAREFERENCIA_ID%TYPE,     
                                    pDiasEstancia       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.DIAS_ESTANCIA%TYPE,                 
                                    pEstadoPxId         IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_ID%TYPE,                  
                                    pEstadoPxEgresoId   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_EGRESO_ID%TYPE,           
                                    pComentarios        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.COMENTARIOS%TYPE,                   
                                    pUsuario            IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                    pExpedienteId       IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE,
                                    pNombreCompleto     IN CATALOGOS.SBC_MST_PERSONAS_NOMINAL.NOMBRE_COMPLETO%TYPE,
                                    pCodExpElectronico  IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.CODIGO_EXPEDIENTE_ELECTRONICO%TYPE,
                                    pIdentificacion     IN CATALOGOS.SBC_MST_PERSONAS.IDENTIFICACION%TYPE,
                                    pUsalProcedeId      IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,                                    
                                    pFecInicio          IN DATE,
                                    pFecFin             IN DATE,
                                    pTipIngEgr          IN VARCHAR2,                                    
                                    pAccionEstado       IN VARCHAR2,                                  
                                    pTipoAccion         IN VARCHAR2, 
                                    pPgn                IN NUMBER,
                                    pPgnAct             IN NUMBER default 1, 
                                    pPgnTmn             IN NUMBER default 100,
                                    pDatosPaginacion    OUT var_refcursor,                                   
                                   -- pJson               IN VARCHAR2,                                  
                                    pRegistro           OUT var_refcursor,                           
                                    pResultado          OUT VARCHAR2,                                
                                    pMsgError           OUT VARCHAR2);   
                                    
 PROCEDURE PR_CRUD_CAT_CAMAS (pCamaId          IN OUT HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE,
                              pNombre          IN HOSPITALARIO.SNH_CAT_CAMAS.NOMBRE%TYPE,
                              pCodAdmin        IN HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE,
                              pNoSerie         IN HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE,
                              pEstadoCama      IN HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_CAMA%TYPE,
                              pUsuario         IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                              pAccionEstado    IN VARCHAR2,                                  
                              pCamaAsignada    IN NUMBER, 
                              pTipoAccion      IN VARCHAR2,                                  
                              pPgn             IN NUMBER,
                              pPgnAct          IN NUMBER default 1, 
                              pPgnTmn          IN NUMBER default 100,
                              pDatosPaginacion OUT var_refcursor,
                              pRegistro        OUT var_refcursor,                           
                              pResultado       OUT VARCHAR2,                                
                              pMsgError        OUT VARCHAR2);  
                              
 PROCEDURE PR_CRUD_CFG_USERVICIOS_CAMAS (pCfgUsalServCamaId IN OUT HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                         pUsalServId        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.UND_SALUD_SERVICIO_ID%TYPE,
                                         pServicioId        IN HOSPITALARIO.SNH_CAT_SERVICIOS.SERVICIO_ID%TYPE,
                                         pCodAsistencial    IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CODIGO_ASISTENCIAL%TYPE,
                                         pSalaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.SALA_ID%TYPE,
                                         pHabitacionId      IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.HABITACION_ID%TYPE,
                                         pCamaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CAMA_ID%TYPE,
                                         pDisponible        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.DISPONIBLE%TYPE,
                                         pCensable          IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CENSABLE%TYPE,
                                         pEstadoCama        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.ESTADO_CAMA_ID%TYPE,
                                         pIslast            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.IS_LAST%TYPE,
                                         pUsalud            IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,
                                         pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                         pAccionEstado      IN VARCHAR2,                                  
                                         pTipoAccion        IN VARCHAR2,                                  
                                         pPgn               IN NUMBER,
                                         pPgnAct            IN NUMBER default 1, 
                                         pPgnTmn            IN NUMBER default 100,
                                         pDatosPaginacion   OUT var_refcursor,
                                         pRegistro          OUT var_refcursor,                           
                                         pResultado         OUT VARCHAR2,                                
                                         pMsgError          OUT VARCHAR2);  
                                                                                               
 PROCEDURE PR_CRUD_REL_ADMSRV_CAMAS (pAdminServCamaId   IN OUT HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SRV_CAMA_ID%TYPE,
                                     pCfgUsalServCamaId IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                     pAdminServId       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE,
                                     pFechaInicio       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE,
                                     pHoraInicio        IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE,  
                                     pFechaFin          IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE,
                                     pHoraFin           IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE, 
                                     pIsLast            IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.IS_LAST%TYPE,   
                                     pUsalud            IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,
                                     pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                     pAccionEstado      IN VARCHAR2,                                  
                                     pTipoAccion        IN VARCHAR2,                                  
                                     pPgn               IN NUMBER,
                                     pPgnAct            IN NUMBER default 1,  
                                     pPgnTmn            IN NUMBER default 100,
                                     pDatosPaginacion   OUT var_refcursor,
                                     pRegistro          OUT var_refcursor,                           
                                     pResultado         OUT VARCHAR2,                                
                                     pMsgError          OUT VARCHAR2); 

 PROCEDURE PR_CRUD_INDISP_CAMAS (pIndCamaId         IN OUT HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.INDISPONIBILIDAD_CAMA_ID%TYPE, 
                                 pCfgUsalServCamaId IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                 pCamaId            IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAMA_ID%TYPE,                  
                                 pCausaId           IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAUSA_ID%TYPE,                 
                                 pUnidSsaludId      IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,
                                 pDescSalida        IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_SALIDA%TYPE,       
                                 pDescRetorno       IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_RETORNO%TYPE,      
                                 pFecSalida         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_SALIDA%TYPE,             
                                 pHrSalida          IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_SALIDA%TYPE,              
                                 pFecRetorno        IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_RETORNO%TYPE,            
                                 pHrRetorno         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_RETORNO%TYPE,             
                                 pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE, 
                                 pAccionEstado      IN VARCHAR2,                                  
                                 pFecInicio         IN DATE,
                                 pFecFin            IN DATE, 
                                 pTipoAccion        IN VARCHAR2,                                  
                                 pPgn               IN NUMBER,
                                 pPgnAct            IN NUMBER default 1, 
                                 pPgnTmn            IN NUMBER default 100,
                                 pDatosPaginacion   OUT var_refcursor,
                                 pRegistro          OUT var_refcursor,                           
                                 pResultado         OUT VARCHAR2,                                
                                 pMsgError          OUT VARCHAR2);      
                                 
 PROCEDURE PR_CRUD_MST_NOTAS (pDetNotaId           IN OUT HOSPITALARIO.SNH_MST_NOTAS.DET_NOTA_ID%TYPE,
                              pAdmServId           IN HOSPITALARIO.SNH_MST_NOTAS.ADMISION_SERVICIO_ID%TYPE,
                              pFecNota             IN HOSPITALARIO.SNH_MST_NOTAS.FECHA_NOTA%TYPE,
                              pHrNota              IN HOSPITALARIO.SNH_MST_NOTAS.HORA_NOTA%TYPE,
                              pTipNota             IN HOSPITALARIO.SNH_MST_NOTAS.TIPO_NOTA_ID%TYPE,
                              pMpersSaludPrincipal IN HOSPITALARIO.SNH_MST_NOTAS.MPERS_SALUD_ID%TYPE,
                              pPerSaludEvoNotaId   IN OUT HOSPITALARIO.SNH_DET_NOTAS.PERSALUD_EVO_NOTA_ID%TYPE,
                              pTipNotaDetId        IN HOSPITALARIO.SNH_DET_NOTAS.TIPO_DET_NOTA_ID%TYPE,
                              pCometario           IN HOSPITALARIO.SNH_DET_NOTAS.COMENTARIOS%TYPE,
                              pUsuario             IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE, 
                              pAccionEstado        IN VARCHAR2,                                  
                              pFecInicio           IN DATE,
                              pFecFin              IN DATE, 
                              pJson                IN VARCHAR2,
                              pTipoAccion          IN VARCHAR2,                                  
                              pPgn                 IN NUMBER,
                              pPgnAct              IN NUMBER default 1, 
                              pPgnTmn              IN NUMBER default 100,
                              pDatosPaginacion     OUT var_refcursor,
                              pRegistro            OUT var_refcursor,                           
                              pResultado           OUT VARCHAR2,                                
                              pMsgError            OUT VARCHAR2);  
                              
 PROCEDURE PR_C_JSON_DATA_DETNOTAS (pIdJson    IN HOSPITALARIO.SNH_JSON_DATA.ID%TYPE,
                                    pRegistro  OUT refDetNotas,
                                    pResultado OUT VARCHAR2,     
                                    pMsgError  OUT VARCHAR2);
                                     
 PROCEDURE PR_CRUD_DET_NOTAS (pPerSaludEvoNotaId   IN OUT HOSPITALARIO.SNH_DET_NOTAS.PERSALUD_EVO_NOTA_ID%TYPE,        
                              pDetNotaId           IN HOSPITALARIO.SNH_DET_NOTAS.DET_NOTA_ID%TYPE,                     
                              pTipNotaDetId        IN HOSPITALARIO.SNH_DET_NOTAS.TIPO_DET_NOTA_ID%TYPE,                
                              pComentario            IN HOSPITALARIO.SNH_DET_NOTAS.COMENTARIOS%TYPE,                   
                              pUsuario             IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,                        
                              pAccionEstado        IN VARCHAR2,                                                        
                              pFecInicio           IN DATE,                                                            
                              pFecFin              IN DATE,                                                            
                              pJson                IN VARCHAR2,                                                        
                              pTipoAccion          IN VARCHAR2,                                                        
                              pPgn                 IN NUMBER,                                                          
                              pPgnAct              IN NUMBER default 1,                                                
                              pPgnTmn              IN NUMBER default 100,                                              
                              pDatosPaginacion     OUT var_refcursor,                                                  
                              pRegistro            OUT var_refcursor,                                                  
                              pResultado           OUT VARCHAR2,                                                       
                              pMsgError            OUT VARCHAR2);   
                               
 PROCEDURE PR_CRUD_DIAGNOSTICO (pIngresoId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE,
                                pAdminServId     IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE,
                                pTipoDiagnostico IN CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                pUsuario         IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                                pAccionEstado    IN VARCHAR2,                                
                                pFecInicio       IN DATE,                                    
                                pFecFin          IN DATE,                                    
                                pJson            IN VARCHAR2,          
                                pTipoAccion      IN VARCHAR2,          
                                pPgn             IN NUMBER,            
                                pPgnAct          IN NUMBER default 1,  
                                pPgnTmn          IN NUMBER default 100,
                                pDatosPaginacion OUT var_refcursor,    
                                pRegistro        OUT var_refcursor,    
                                pResultado       OUT VARCHAR2,         
                                pMsgError        OUT VARCHAR2);
 
 PROCEDURE PR_CRUD_REL_DX_ING_EG (pRelDxIngEgId    IN OUT SNH_REL_DIAGNOSTICOS_ING_EG.REL_DX_ING_EG_ID%TYPE,  
                                  pIngresoId       IN SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE,       
                                  pTipoDxIngEg     IN CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE, 
                                  pDxId            IN HOSPITALARIO.SNH_MST_DIAGNOSTICOS.DIAGNOSTICO_ID%TYPE,
                                  pTrasladoId      IN HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG.TRASLADO_ID%TYPE,
                                  pUsuario         IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                                  pAccionEstado    IN VARCHAR2,                                
                                  pFecInicio       IN DATE,                                    
                                  pFecFin          IN DATE,                                    
                                  pJson            IN VARCHAR2,          
                                  pTipoAccion      IN VARCHAR2,          
                                  pPgn             IN NUMBER,            
                                  pPgnAct          IN NUMBER default 1,  
                                  pPgnTmn          IN NUMBER default 100,
                                  pDatosPaginacion OUT var_refcursor,    
                                  pRegistro        OUT var_refcursor,    
                                  pResultado       OUT VARCHAR2,         
                                  pMsgError        OUT VARCHAR2);                                                        
                                     
 PROCEDURE PR_CRUD_TRASLADO_DX (pTrasladoId      IN OUT HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.TRASLADO_ID%TYPE,
                                pIngresoId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE,
                                pAdminServId     IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE,
                                pTipoDiagnostico IN CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                pUsuario         IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                                pAccionEstado    IN VARCHAR2,                                
                                pFecInicio       IN DATE,                                    
                                pFecFin          IN DATE,                                    
                                pJson            IN VARCHAR2,          
                                pTipoAccion      IN VARCHAR2,          
                                pPgn             IN NUMBER,            
                                pPgnAct          IN NUMBER default 1,  
                                pPgnTmn          IN NUMBER default 100,
                                pDatosPaginacion OUT var_refcursor,    
                                pRegistro        OUT var_refcursor,    
                                pResultado       OUT VARCHAR2,         
                                pMsgError        OUT VARCHAR2);
END PKG_SNH_INGRESO_EGRESO;
/