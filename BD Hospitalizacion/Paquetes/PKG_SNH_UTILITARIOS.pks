CREATE OR REPLACE PACKAGE HOSPITALARIO.PKG_SNH_UTILITARIOS
AUTHID CURRENT_USER
AS

SUBTYPE vMAX_VARCHAR2 IS VARCHAR2(32767);

TYPE var_refcursor IS REF CURSOR;
  eRegistroExiste      EXCEPTION;
  eRegistroNoExiste    EXCEPTION;
  eParametrosInvalidos EXCEPTION;
  eParametroNull       EXCEPTION;
  eSalidaConError      EXCEPTION;
  ePasivarInvalido     EXCEPTION;
  eUpdateInvalido      EXCEPTION;
  eCoincidencia        EXCEPTION;
  
  NULL_VALUE_NOT_NULL   EXCEPTION;
  PRAGMA EXCEPTION_INIT (NULL_VALUE_NOT_NULL, -01400);
   
  VALUE_ERROR_CONVERT    EXCEPTION;
  PRAGMA EXCEPTION_INIT (VALUE_ERROR_CONVERT, -06502);
   
  K_CODE_CUSTOM_EXCEPTION   NUMBER := -20990;
  MINSA_CUSTOM_EXCEPTION    EXCEPTION;
  PRAGMA EXCEPTION_INIT (MINSA_CUSTOM_EXCEPTION, -20990);
   
  K_STRG_COMODIN_EXCEPTION CHAR(3 char)     := '\-\';  
  
  kSoloTexto VARCHAR2 (26 char) := '[^A-Za-záéíóúÁÉÍÓÚñÑÜü'' ]';
  
  K_VAL_CAT_CHIELD_ID     CHAR(5)     := 'CHLID';
  K_VAL_CAT_CHIELD        CHAR(3)     := 'CHL';
  K_VAL_CAT_PARENT        CHAR(3)     := 'PRN';
  K_VAL_CAT               CHAR(4)     := 'UNKW';
  K_ID             VARCHAR2(10)        := 'ID';
  K_EXP_BASE       VARCHAR2(10)        := 'EXP_BASE';
  K_TYPE_EXP_BASE  VARCHAR2(10)        := 'T_EXP_BASE';
  K_CODE_EXP       VARCHAR2(10)        := 'CODE_EXP';
  K_TYPE_CODE_EXP  VARCHAR2(10)        := 'T_CODE_EXP';     
  K_LKUSR_USERNAME      VARCHAR2(10)   := 'USRNM';
  K_LKSYS_CODE          VARCHAR2(10)   := 'SYS_CODE';
  
  --Cat Values -> State
  K_CAT_REG_ACT                    VARCHAR2 (6) := 'ACTREG';
  K_CAT_REG_PAS                    VARCHAR2 (6) := 'PASREG';
  K_CAT_REG_DEL                    VARCHAR2 (6) := 'DELREG';
  K_STATE_REG                      VARCHAR2 (5) := 'STREG';
  
  --TypesEntity
  K_CFG_EXP_BASE       VARCHAR2(20) := 'CFG_EXP_BASE';
  K_MST_COD_EXP        VARCHAR2(20) := 'CPDE_EXP_ID';
  K_HST_COD_EXP        VARCHAR2(20) := 'CPDE_HST_EXP_ID';
  K_MST_PACIENTES      VARCHAR2(20) := 'MST_PX';
  
  K_MST_USUARIOS       VARCHAR2(20) := 'SCS_USRS';
  K_MST_SISTEMAS       VARCHAR2(20) := 'SCS_SYS';
  K_SYS_CD_PX          VARCHAR2(20) := 'PA';
 
  K_DET_EXP_LOC        VARCHAR2(20) := 'EXP_LOC';
  K_DET_PROGRAM        VARCHAR2(20) := 'PROGRAMA';
  K_DET_PX_CRCT        VARCHAR2(20) := 'PX_CRCTR';--Caracterísitcas
  K_DET_PX_CNCT        VARCHAR2(20) := 'PX_CNCT';--Contactos
  K_DET_PX_FNMC        VARCHAR2(20) := 'PX_FNCM';--Financiamientos
  K_DET_PX_IDNT        VARCHAR2(20) := 'PX_IDNT';--Identificaciones
  K_DET_XP_IDNT        VARCHAR2(20) := 'XP_IDNT';--Identificaciones  
  K_DET_PX_RSDN        VARCHAR2(20) := 'PX_RSDN';--Residencias
  
  K_FNMC_CODE          VARCHAR2(20) := 'FNMC_CODE';
  K_IDNTF_CODE         VARCHAR2(20) := 'IDNTF_CODE';
   
  K_VLD_ID             VARCHAR2(20) := 'ID';
  K_VLD_CODE           VARCHAR2(20) := 'CODE';
  K_VLD_CODE_CHILD     VARCHAR2(20) := 'CODE_C';
  K_VLD_CODE_PARENT    VARCHAR2(20) := 'CODE_P'; 
 
 
  K_CAT_C_EXP           VARCHAR2(10) := 'CODEXP';
  K_CAT_C_EXP_UNC       VARCHAR2(10) := 'UNC';
  K_CAT_C_EXP_RCN       VARCHAR2(10) := 'RNC';
  K_CAT_C_EXP_DSC       VARCHAR2(10) := 'DSC';
    
  K_CAT_C_GSANGUINEO    VARCHAR2(10) := 'GSANG';
  K_CAT_C_ETNIA         VARCHAR2(10) := 'ETNIA';
  --K_CAT_C_RELIGIONES    VARCHAR2(10) := 'RELIGIONES';
  K_CAT_C_RELIGIONES    VARCHAR2(10) := 'HSF_RELIG';  

  --K_CAT_C_ST_CIVIL      VARCHAR2(20) := 'ESTADO CIVIL';
  K_CAT_C_ST_CIVIL      VARCHAR2(20) := 'ESTCV';
  --K_CAT_C_OCUPACION     VARCHAR2(10) := 'HSF_OCUPA';
  K_CAT_C_OCUPACION     VARCHAR2(15) := 'OCUPACIONES';
  K_CAT_C_ESCOLARIDAD   VARCHAR2(15) := 'ESCOLARIDAD';
  
  
  K_CAT_C_EST_PRCS   VARCHAR2(10) := 'ESTADOS';
  K_CAT_C_EST_PRCS_INICIADO VARCHAR2(5) := 'I';
  K_CAT_C_EST_PRCS_PROGRAMADO VARCHAR2(5) := 'P';
  K_CAT_C_EST_PRCS_FINALIZADO VARCHAR2(5) := 'F';
  
  K_LKPX_EXP_ELT        VARCHAR2(10) := 'EXPELCT';
  K_LKPX_CED_NIC        VARCHAR2(10) := 'CEDNCRG';
  K_LKPX_EXP_LOC        VARCHAR2(10) := 'EXPLCLS';
  
  K_LKPX_TP_IDNT        VARCHAR2(11) := 'PXSRCHDCTPS'; 
  
  K_CAT_UND_SLD         VARCHAR2(20) := 'UND_SALUD'; 
  
  K_CAT_PROGRAMS        VARCHAR2(20) := 'PRGRM';
  K_CAT_CRCT            VARCHAR2(10)  := 'CRCPX';
  K_CAT_FINANCIAMIENTO  VARCHAR2(20) := 'FINANCIAMNTOS';
  K_CAT_IDNTF_PX        VARCHAR2(10) := 'IDNPX';
  K_CAT_IDNTF_PRS        VARCHAR2(10) := 'TPIDNTF';
  K_CAT_TPO_RESIDENCIA  VARCHAR2(20) := 'TPRESIDENC';
  K_CAT_TPO_CONTACTOS   VARCHAR2(20) := 'TPRELACION';

  kIDENTIF_CEDULA_NIC   CHAR(3) := 'CED';
  kIDENTIF_PASPORTE     CHAR(3) := 'PAS';
  
 PROCEDURE PR_GENERATE_CUSTOM_ERROR (pMsg VARCHAR2,  
                                     pMsgDev VARCHAR2 );
 PROCEDURE PR_GENERATE_ERROR (pMsg VARCHAR2);
 PROCEDURE PR_GET_CUSTOM_ERROR (pMsg OUT VARCHAR2,  
                                pMsgDev OUT VARCHAR2 );
 FUNCTION FN_VAL_CAT_BY_CODE_ID (pName VARCHAR2, 
                                 pCrto VARCHAR2, 
                                 pCodeParent VARCHAR2, 
                                 pTypeValidation VARCHAR2, 
                                 pMsgDev OUT VARCHAR2, 
                                 pMsg OUT VARCHAR2) RETURN CATALOGOS.SBC_CAT_CATALOGOS%ROWTYPE;
 FUNCTION FN_H_VAL_CAT_BY_CODE_ID (
                                  pName                     VARCHAR2,
                                  pCrto                     VARCHAR2,
                                  pCodeParent               VARCHAR2,
                                  pTypeValidation           VARCHAR2,
                                  pMsgDev                   OUT VARCHAR2,
                                  pMsg                      OUT VARCHAR2
                                 ) RETURN HOSPITALARIO.SNH_CAT_CATALOGOS%ROWTYPE;
                                 
 FUNCTION FN_ALLOW_ACTION_STATE (pName VARCHAR2, 
                                 pTypeRow VARCHAR2, 
                                 pStateRow NUMBER, 
                                 pAction VARCHAR2, 
                                 pMsgDev OUT VARCHAR2, 
                                 pMsg OUT VARCHAR2) RETURN BOOLEAN;
 FUNCTION VALIDATE_EXIST_ROW (pCodeEntity VARCHAR2, 
                              pTypeValidate VARCHAR2, 
                              pArg1 VARCHAR2, 
                              pArg2 VARCHAR2, 
                              pArg3 VARCHAR2,
                              pArg4 VARCHAR2, 
                              pArg5 VARCHAR2, 
                              pArg6 VARCHAR2, 
                              pMsgDev OUT VARCHAR2, 
                              pMsg OUT VARCHAR2) RETURN BOOLEAN; 
 FUNCTION VALIDATE_EXIST_ROW_SEGURIDAD (pCodeEntity VARCHAR2, 
                              pTypeValidate VARCHAR2, 
                              pArg1 VARCHAR2, 
                              pArg2 VARCHAR2, 
                              pArg3 VARCHAR2,
                              pArg4 VARCHAR2, 
                              pArg5 VARCHAR2, 
                              pArg6 VARCHAR2, 
                              pMsgDev OUT VARCHAR2, 
                              pMsg OUT VARCHAR2) RETURN BOOLEAN;
  
 FUNCTION FN_OBT_ESTADO_REGISTRO (pValor IN CATALOGOS.SBC_CAT_CATALOGOS.VALOR%TYPE) RETURN NUMBER;
 FUNCTION FN_OBTENER_ESTADO_REG(pCodeParent IN VARCHAR2, pCodigoHijo IN VARCHAR2) RETURN NUMBER;
 
 FUNCTION FN_OBT_TIPO_PERSONA (pValor IN CATALOGOS.SBC_CAT_CATALOGOS.VALOR%TYPE) RETURN NUMBER;
 
 FUNCTION FN_VALIDAR_USUARIO (pUsuario IN VARCHAR2) RETURN BOOLEAN;
 FUNCTION FN_OBT_TIP_IDENT (pTipoIdentificacion IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_SEXO_ID (pSexo IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_TIPO_PERSONA_ID (pTipoPersona IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_TIPO_CODEXPID (pTipoCodExpediente IN VARCHAR2) RETURN NUMBER; 
 FUNCTION FN_OBT_TIPO_CODEXPID_DE_EXPID (pExpedienteId IN NUMBER) RETURN NUMBER; 
 FUNCTION FN_OBT_ETNIA_ID (pEtnia IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_TIPO_SANGRE_ID (pTipoSangre IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_ESTADO_CIVIL_ID (pEstadoCivil IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_RELIGION_ID (pReligion IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_OCUPACION_ID (pOcupacion IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_TIPO_RESIDENCIA_ID (pTipoResidencia IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_ESCOLARIDAD (pTipEscolaridad IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_TIPO_TELEFONO_ID (pTipoTelefono IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_VALOR_CATALOGO (pCodigo IN VARCHAR2) RETURN VARCHAR2; 
 FUNCTION FN_OBT_TIPO_RELACION (pTipoRelacion IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_PARENTESCO (pParentesco IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_TIP_UNIFICACION (pTipoUnificacion IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_TIP_CONTACTO_PX (pTipoContacto IN VARCHAR2) RETURN NUMBER;
 FUNCTION FN_OBT_ESTADO_PREINGRESO (pCodigo IN VARCHAR2) RETURN VARCHAR2;  
 FUNCTION FN_OBT_ESTADO_CAMA (pCodigo IN VARCHAR2) RETURN VARCHAR2; 
 FUNCTION FN_OBT_TIPO_NOTA (pTipoNota IN VARCHAR2) RETURN NUMBER; 
 FUNCTION FN_OBT_TIPO_NOTA_EVO_TRATA (pTipoNota IN VARCHAR2) RETURN NUMBER; 
  FUNCTION FN_OBT_CATALOGO_ID (pCodPadre IN VARCHAR2,
                               pCodHijo  IN VARCHAR2) RETURN NUMBER; 
FUNCTION FN_OBT_DATOS_PAGINACION (pDatosPaginacion IN HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos ) RETURN var_refcursor;                               
 --FUNCTION FN_EXISTE_CATALOGO (pId IN NUMBER, pCodigo VARCHAR2) RETURN BOOLEAN;
 PROCEDURE PR_FORMATEAR_PARAMETROS (pExpedienteId          IN SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE DEFAULT NULL,
                                    pIdentificacion        IN OUT VARCHAR2,
                                    pTipoIdentificacion    IN CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                    pTipoPersona           IN VARCHAR2 default null,
                                    pPaisOrigenId          IN CATALOGOS.SBC_CAT_PAISES.PAIS_ID%TYPE DEFAULT NULL,
                                    pNombreCompleto        IN OUT VARCHAR2,
                                    pPrimerNombre          IN OUT VARCHAR2,
                                    pSegundoNombre         IN OUT VARCHAR2,
                                    pPrimerApellido        IN OUT VARCHAR2,
                                    pSegundoApellido       IN OUT VARCHAR2,
                                    pMunicipioNacimientoId IN CATALOGOS.SBC_MST_PERSONAS.MUNICIPIO_NACIMIENTO_ID%TYPE,
                                    pFechaNacimiento       IN CATALOGOS.SBC_MST_PERSONAS.FECHA_NACIMIENTO%TYPE,
                                    pResultado             OUT VARCHAR2,
                                    pMsgError              OUT VARCHAR2);   
 FUNCTION FN_VALIDA_NUMERO (pNombre      IN VARCHAR2,
                            pValor       IN NUMBER,
                            pValMin      IN NUMBER := NULL,
                            pValMax      IN NUMBER := NULL,
                            pRequired    IN BOOLEAN := TRUE) RETURN VARCHAR2;
 
 
 FUNCTION FN_GET_UNIDAD_SALUD(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN CATALOGOS.SBC_CAT_UNIDADES_SALUD%ROWTYPE; 
 FUNCTION FN_GET_USER(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN SEGURIDAD.SCS_MST_USUARIOS%ROWTYPE;
 FUNCTION FN_GET_SYSTEM(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN SEGURIDAD.SCS_CAT_SISTEMAS%ROWTYPE;
 FUNCTION FN_GET_COMUNIDAD(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN CATALOGOS.SBC_CAT_COMUNIDADES%ROWTYPE;
 FUNCTION FN_GET_FEC_NACIMIENTO_PERSONA (pPerNominalId IN CATALOGOS.SBC_MST_PERSONAS_NOMINAL.PER_NOMINAL_ID%TYPE) RETURN DATE;
 PROCEDURE PR_GRUPO_ETAREO (pCodEventoId   IN NUMBER,
                            pFecNacimiento IN DATE,
                            pCodigo        IN VARCHAR2,
                            pGrupoEtareoId OUT NUMBER,
                            pResultado     OUT VARCHAR2,
                            pMsgError      OUT VARCHAR2);
 FUNCTION FN_OBT_EDAD_EN_BASE_A_FECHA (pFechaNacimiento IN DATE,
                                       pFechaBase IN DATE,
                                       pHoraBase IN VARCHAR2) RETURN VARCHAR2;
END PKG_SNH_UTILITARIOS;
/