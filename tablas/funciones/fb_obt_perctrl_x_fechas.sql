   FUNCTION FN_OBT_PERCTRL_X_FECHAS (pFechaInicio     IN DATE,
                                     pFechaFin        IN DATE,
                                     pPgnAct          IN NUMBER DEFAULT 1, 
                                     pPgnTmn          IN NUMBER DEFAULT 100,
                                     pTipoRegistro    IN VARCHAR2) RETURN var_refcursor AS
   vRegistro var_refcursor;
   vcontador simple_integer := 0;
   BEGIN
    --     select count (1)
    --     into vcontador
    --     from SVSC_CAPTACIONES_PAGINADAS_TMP;
    --     
    --     RAISE_APPLICATION_ERROR(-20000,'Error intencional: contador: '||vcontador);
   
        OPEN vRegistro FOR
             SELECT *
               FROM (
                    SELECT *
                     FROM SIPAI.SIPAI_CTRL_VAC_PAGINADAS_TMP A,(
                        SELECT ROW_NUMBER () OVER (ORDER BY CAPT_CAPTACION_ID ASC)
                               LINE_NUMBER,
                    CAPT_CAPTACION_ID,
                    NUM_DIAS_SIN_SEGUIMIENTO,
                    CAPT_IND_POSITIVO_EXTRANJERO,         
                    CAPT_EXPEDIENTE_ID, 
                    CAPT_PACIENTE_ID,
                    TEL_PACIENTE,
                    CAPT_COD_EXP_ELECTRONICO,  -- TIPO EXPEDIENTE
                    CAPT_CODEXP_CODIGO,
                    CAPT_CODEXP_VALOR,
                    CAPT_CODEXP_PASIVO,
                    CAPT_CODEXP_SISTEMA_ID,
                    CAPT_CODEXP_SIST_NOMBRE,
                    CAPT_CODEXP_SIST_DESCRIPCION,
                    CAPT_CODEXP_SIST_CODIGO,
                    CAPT_CODEXP_SIST_PASIVO,
                    CAPT_COD_EXP_UNSALUD_ID,
                    CAPT_CODEXP_US_NOMBRE, 
                    CAPT_CODEXP_US_CODIGO,
                    CAPT_CODEXP_US_RSOCIAL,
                    CAPT_CODEXP_US_DIREC,
                    CAPT_CODEXP_US_EMAIL,
                    CAPT_CODEXP_US_ABREV,
                    CAPT_CODEXP_US_ENTADMIN,
                    CAPT_CODEXP_US_PASIVO,
                    PER_PERSONA_ID,   -- datos de persona
                    PER_ES_DIFUNTO,
                    PER_CEDULA,
                    PER_CODIGOTIP_ID,
                    PER_CATID_ID,
                    PER_CATID_VALOR,
                    PER_CATID_DESCRIPCION,
                    PER_CATID_PASIVO,
                    PER_PRIMER_NOMBRE,
                    PER_SEGUNDO_NOMBRE,
                    PER_PRIMER_APELLIDO,
                    PER_SEGUNDO_APELLIDO, 
                    PER_CATSEXO_ID,          --- catalogo sexo. nuevo
                    PER_CATSEXO_CODIGO,           -- nuevo
                    PER_CATSEXO_VALOR,             -- nuevo
                    PER_CATSEXO_DESCRIPCION, -- nuevo
                    PER_CATSEXO_PASIVO,           -- nuevo
                    PER_FEC_NACIMIENTO,
                    PER_EDAD_ANIO, -- nuevo      NVL(vAnio, 'N/A') PER_EDAD_ANIO,           -- nuevo 
                    PER_EDAD_MES,  -- nuevo      NVL(vMes, 'N/A') PER_EDAD_MES,             -- nuevo
                    PER_EDAD_DIA,  -- nuevo      NVL(vDias, 'N/A') PER_EDAD_DIA, 
                    -- campos de dirección, comunidad y sector
                    PER_DIRECCION_DOMICILIO,
                    PER_COMUNIDAD_ID,          -- comunidad
                    PER_COMUNIDAD_NOMBRE,
                    PER_COMUNIDAD_CODIGO,
                    PER_COMUNIDAD_LATITUD,
                    PER_COMUNIDAD_LONGITUD,
                    PER_COMUNIDAD_PASIVO,
                    PER_COMUNIDAD_FEC_PASIVO,
                    PER_COM_MUNI_ID,            -- municipio
                    PER_COM_MUNI_NOMBRE,
                    PER_COM_MUN_CODIGO,
                    PER_COM_MUN_CODIGO_CSE,
                    PER_COM_MUN_CSEREG,
                    PER_COM_MUN_LATITUD,
                    PER_COM_MUN_LONGITUD,
                    PER_COM_MUN_PASIVO,
                    PER_COM_MUN_FEC_PASIVO,
                    PER_COM_MUN_DEP_ID,          -- departamento
                    PER_COM_MUN_DEP_NOMBRE,
                    PER_COM_MUN_DEP_CODIGO,
                    PER_COM_MUN_DEP_CODISO,
                    PER_COM_MUN_DEP_COD_CSE,
                    PER_COM_MUN_DEP_LATITUD,
                    PER_COM_MUN_DEP_LONGITUD,
                    PER_COM_MUN_DEP_PASIVO,
                    PER_COM_MUN_DEP_FEC_PASIVO,
                    PER_COM_MUN_DEP_PAIS_ID,      -- pais
                    PER_COM_MUN_DEP_PAIS_NOMBRE,
                    PER_COM_MUN_DEP_PAIS_COD,
                    PER_COM_MUN_DEP_PAIS_CODISO,
                    PER_COM_MUN_DEP_PAIS_CODALF,
                    PER_COM_MUN_DEP_PAIS_CODALFTR,
                    PER_COM_MUN_DEP_PAIS_PREFTELF,
                    PER_COM_MUN_DEP_PAIS_PASIVO, 
                    PER_COM_MUN_DEP_PAIS_FECPASIVO,
                    PER_COM_MUN_DEP_REG_ID,       -- region
                    PER_COM_MUN_DEP_REG_NOMBRE,
                    PER_COM_MUN_DEP_REG_CODIGO,
                    PER_COM_MUN_DEP_REG_PASIVO,
                    PER_COM_MUN_DEP_REG_FEC_PASIVO,
                    PER_COM_DIS_ID,               -- distrito
                    PER_COM_DIS_NOMBRE,
                    PER_COM_DIS_CODIGO,
                    PER_COM_DIS_PASIVO,
                    PER_COM_DIS_FEC_PASIVO,
                    PER_COM_DIS_MUN_ID,  --
                    PER_COM_DIS_MUN_NOMBRE,
                    PER_COM_DIS_MUN_CODIGO,
                    PER_COM_DIS_MUN_COD_CSE,
                    PER_COM_DIS_MUN_CODCSEREG,
                    PER_COM_DIS_MUN_LATITUD,
                    PER_COM_DIS_MUN_LONGITUD,
                    PER_COM_DIS_MUN_PASIVO,
                    PER_COM_DIS_MUN_FECPASIVO,
                    PER_COM_DIS_MUN_DEP_ID,     -- departamento
                    PER_COM_DIS_MUN_DEP_NOMBRE,
                    PER_COM_DIS_MUN_DEP_COD,
                    PER_COM_DIS_MUN_DEP_CODISO,
                    PER_COM_DIS_MUN_DEP_CODCSE,
                    PER_COM_DIS_MUN_DEP_LATITUD,
                    PER_COM_DIS_MUN_DEP_LONGITUD,
                    PER_COM_DIS_MUN_DEP_PASIVO,
                    PER_COM_DIS_MUN_DEP_FECPASIVO,
                    PER_COM_DIS_MUN_DEP_PA_ID,    -- pais
                    PER_COM_DIS_MUN_DEP_PA_NOMBRE,
                    PER_COM_DIS_MUN_DEP_PA_COD,
                    PER_COM_DIS_MUN_DEP_PA_CODISO,
                    PER_COM_DIS_MUN_DEP_PA_CODALFA,
                    PER_COM_DIS_MUN_DEP_PA_ALFTRES,
                    PER_COM_DIS_MUN_DEP_PA_PREFTEL,
                    PER_COM_DIS_MUN_DEP_PA_PASIVO,
                    PER_COM_DIS_MUN_DEP_PA_FECPASI,
                    PER_COM_DIS_MUN_DEP_REG_ID,   -- region
                    PER_COM_DIS_MUN_DEP_REG_NOMBRE,
                    PER_COM_DIS_MUN_DEP_REG_COD,
                    PER_COM_DIS_MUN_DEP_REG_PASIVO,
                    PER_COM_DIS_MUN_DEP_REG_FECPAS,
                    PER_COM_LOCALIDAD_ID,  -- localida
                    PER_COM_LOCALIDAD_CODIGO,
                    PER_COM_LOCALIDAD_VALOR,
                    PER_COM_LOCALIDAD_DESC,
                    PER_COM_LOCALIDAD_PASIVO,  
                    PER_SEC_ID,           -- sector
                    PER_SECNOMBRE,
                    PER_SEC_CODIGO, 
                    PER_SEC_PASIVO,        
                    PER_SEC_MUN_ID,       -- municipio
                    PER_SEC_MUN_NOMBRE,
                    PER_SEC_MUN_CODIGO,
                    PER_SEC_MUN_COD_CSE,
                    PER_SEC_MUN_CODCSEREG,
                    PER_SEC_MUN_LATITUD,
                    PER_SEC_MUN_LONGITUD,
                    PER_SEC_MUN_PASIVO,
                    PER_SEC_MUN_FECPASIVO,
                    PER_SEC_MUN_DEP_ID,   -- departamento
                    PER_SECMUN_DEP_NOMBRE,
                    PER_SECMUN_DEP_COD,
                    PER_SECMUN_DEP_CODISO,
                    PER_SECMUN_DEP_CODCSE,
                    PER_SECMUN_DEP_LATITUD,
                    PER_SECMUN_DEP_LONGITUD,
                    PER_SECMUN_DEP_PASIVO,
                    PER_SECMUN_DEP_FECPASIVO,
                    PER_SECMUNDEP_PA_ID,    -- pais
                    PER_SECMUNDEP_PA_NOMBRE,
                    PER_SECMUNDEP_PA_COD,
                    PER_SECMUNDEP_PA_CODISO,
                    PER_SECMUNDEP_PA_CODALFAD,
                    PER_SECMUNDEP_PA_ALFTRES,
                    PER_SECMUNDEP_PA_PREFTELF,
                    PER_SECMUNDEP_PA_PASIVO,
                    PER_SECMUNDEP_PA_FECPASI,
                    PER_SECMUNDEP_REG_ID,    -- region
                    PER_SECMUNDEP_REG_NOMBRE,
                    PER_SECMUNDEP_REG_COD,
                    PER_SECMUNDEP_REG_PASIVO,
                    PER_SECMUNDEP_REG_FECPAS, 
                    PER_SEC_USALUD_ID,                    
                    PER_SEC_USALUD_NOMBRE,                            
                    PER_SEC_USALUD_CODIGO,                            
                    PER_SEC_USALUD_RSOCIAL,                          
                    PER_SEC_USALUD_DIREC,                            
                    PER_SEC_USALUD_EMAIL,                            
                    PER_SEC_USALUD_ABREV,                            
                    PER_SEC_USALUD_PASIVO,                            
                    PER_SECUSALUD_ENTADMIN_ID,                     
                    PER_SECUSALUD_ENTADMIN_CODIGO,                    
                    PER_SECUSALUD_NOMBRE,                    
                    PER_SECUSALUD_PASIVO,                             
                    -- fin
                    CAPT_TIPO_CAPTACION_ID,   
                    TCAP_CODIGO,   -- catalogo de tipo de captacion
                    TCAP_VALOR,
                    TCAP_DESCRIPCION,
                    TCAP_PASIVO,
                    CAPT_ESTRATEGIA_ID,  
                    ESTRA_CODIGO,   -- catalogo de estrategia
                    ESTRA_VALOR,
                    ESTRA_DESCRIPCION,
                    ESTRA_PASIVO,            
                    CAPT_GRUPO_ETAREO_ID,
                    ETAREO_EDAD_MINIMA,
                    ETAREO_EDAD_MAXIMA,
                    ETAREO_UMINIMA_ID,
                    ETAREO_UMAXIMA_ID,
                    ETAREO_CODIGO,   -- catalogo de grupo etareo
                    ETAREO_VALOR,
                    ETAREO_DESCRIPCION,
                    ETAREO_PASIVO,                        
                    CAPT_GRUP_ETAREO_AGRUPACION_ID,
                    AGRUP_ETAREO_CODIGO,   -- catalogo de grupo etareo
                    AGRUP_ETAREO_VALOR,
                    AGRUP_ETAREO_DESCRIPCION,
                    AGRUP_ETAREO_PASIVO,                     
                    CAPT_FEC_CAPTACION,     
                    UND_SALUD_CAPTACION,  --- registro nuevo.    
                    USALCAPTACION_NOMBRE,             -- nuevo
                    USALCAPTACION_CODIGO,             -- nuevo
                    USALCAPTACION_RSOCIAL,      -- nuevo
                    USALCAPTACION_DIREC,           -- nuevo
                    USALCAPTACION_EMAIL,               -- nuevo
                    USALCAPTACION_ABREV,         -- nuevo
                    USALCAPTACION_PASIVO,             -- nuevo  
                    USALCAPTACION_ENTADMIN, -- nuevo
                    CPT_ENTADMIN_CODIGO,
                    CPT_ENTADMIN_NOMBRE,
                    CPT_ENTADMIN_PASIVO,                  
                    CAPT_FEC_SINTOMAS, 
                    CAPT_FEC_INICIO_TRATAMIENTO,
                    CAPT_FEC_FIN_TRATAMIENTO,    
                    CAPT_SITIO_INGRESO_ID, 
                    INGR_CODIGO,   -- catalogo de sitio de ingreso
                    INGR_VALOR,
                    INGR_DESCRIPCION,
                    INGR_PASIVO,              
                    CAPT_FEC_INGRESO_PAIS,  
                    CAPT_OBSERVACIONES,       
                    CAPT_ESTADO_REGISTRO_ID,
                    ESTADO_CODIGO,   -- catalogo de estado de registro
                    ESTADO_VALOR,
                    ESTADO_DESCRIPCION,
                    ESTADO_PASIVO,            
                    CAPT_USR_REGISTRO,    
                    CAPT_FEC_REGISTRO,      
                    CAPT_USR_MODIFICACION,
                    CAPT_FEC_MODIFICACION,  
                    CAPT_USR_PASIVO,      
                    CAPT_FEC_PASIVO,
                    CAPT_USR_ELIMINA,
                    CAPT_FEC_ELIMINADO,
                    NUM_DIA_SEGUIMIENTO,  -- Con la captación id se obtiene el primer dia del seguimiento para esa captación, con ese seguimiento, se obtiene la fecha seguimiento de ese seguimiento id. Luego se calcula el dia del seguimiento, usando como parámetro la fecha de seguimiento de la consulta principal
                    SEG_SEGUIMIENTO_ID,   ---  Aqui inician los datos del rel seguimiento.        
                    SEG_FEC_SEGUIMIENTO,        
                    ESTADO_SEGUIMIENTO_ID,
                    RELESTSEG_CODIGO,   -- catalogo de estado de seguimiento de registro
                    RELESTSEG_VALOR,
                    RELESTSEG_DESCRIPCION,
                    RELESTSEG_PASIVO,       
                    SEG_TIPO_SEGUIMIENTO_ID,   --iniciar tipo seguimiento     
                    CATTIPSEG_CODIGO,
                    CATTIPSEG_VALOR,
                    CATTIPSEG_DESCRIPCION,
                    CATTIPSEG_PASIVO,
                    SEG_FEC_TOMA,               
                    SEG_RESULTADO_ID,   
                    RELSEGTIPRESUL_CODIGO,   -- catalogo de estado de registro
                    RELSEGTIPRESUL_VALOR,
                    RELSEGTIPRESUL_DESCRIPCION,
                    RELSEGTIPRESUL_PASIVO,       
                    TIPO_ALTA_ID,         
                    RELSEGTIPALTA_CODIGO,   -- catalogo de estado de registro
                    RELSEGTIPALTA_VALOR,
                    RELSEGTIPALTA_DESCRIPCION,
                    RELSEGTIPALTA_PASIVO,                        
                    SEG_OBSERVACIONES,  
                    ESTADO_TRATAMIENTO_ID, 
                    RELSEGTRATAMIENTO_CODIGO,   -- catalogo de estado de tratamiento
                    RELSEGTRATAMIENTO_VALOR,
                    RELSEGTRATAMIENTO_DESCRIPCION,
                    RELSEGTRATAMIENTO_PASIVO,                    
                    RELSEG_ESTADOREG_ID,
                    RELSEGESTADO_CODIGO,   -- catalogo de estado de registro
                    RELSEGESTADO_VALOR,
                    RELSEGESTADO_DESCRIPCION,
                    RELSEGESTADO_PASIVO,          
                    SEG_USR_REGISTRO,         
                    SEG_FEC_REGISTRO,           
                    SEG_USR_MODIFICACION,     
                    SEG_FEC_MODIFICACION,       
                    SEG_USR_PASIVA,           
                    SEG_FEC_PASIVA,             
                    SEG_USR_ELIMINA,          
                    SEG_FEC_ELIMINADO,          
                    SEG_USALUD_ID,         
                    SEG_UND_SALUD_SEGUIMIENTO_ID, -- RELSEG.UND_SALUD_SEGUIMIENTO_ID SEG_UND_SALUD_SEGUIMIENTO_ID, 
                    USALSEG_NOMBRE,             -- nuevo
                    USALSEG_CODIGO,             -- nuevo
                    USALSEG_RSOCIAL,      -- nuevo
                    USALSEG_DIREC,           -- nuevo
                    USALSEG_EMAIL,               -- nuevo
                    USALSEG_ABREV,         -- nuevo
                    USALSEG_PASIVO,             -- nuevo   
                    USALSEG_ENTADMIN, -- nuevo
                    USEG_ENTADMIN_CODIGO,
                    USEG_ENTADMIN_NOMBRE,
                    USEG_ENTADMIN_PASIVO,                   
                    SEG_UND_SALUD_ACTUAL,  
                    USALACT_NOMBRE,             -- nuevo
                    USALACT_CODIGO,             -- nuevo
                    USALACT_RSOCIAL,      -- nuevo
                    USALACT_DIREC,           -- nuevo
                    USALACT_EMAIL,               -- nuevo
                    USALACT_ABREV,         -- nuevo
                    USALACT_ENTADMIN, -- nuevo
                    USALACT_PASIVO,             -- nuevo 
                    FECHA_TRASLADO,
                    SEGUSAL_ESTADO_REG_ID,
                    SEGUSAL_ESTADO_CODIGO,   -- catalogo de estado de registro
                    SEGUSAL_ESTADO_VALOR,
                    SEGUSAL_ESTADO_DESCRIPCION,
                    SEGUSAL_ESTADO_PASIVO,                   
                    SEG_TRABAJADOR_ID, -- RELSEG.TRABAJADOR_SEGUIMIENTO_ID SEG_TRABAJADOR_ID,
                    SEG_COD_EXP_ELECTRONICO,  -- TIPO EXPEDIENTE nuevo
                    SEG_CODEXP_CODIGO,       -- nuevo
                    SEG_CODEXP_VALOR,         -- nuevo
                    SEG_CODEXP_PASIVO,       -- nuevo  
                    SEG_PER_PERSONA_ID,   -- datos de persona
                    SEG_PER_CEDULA,
                    SEG_PER_CODIGOTIP_ID,   -- nuevo
                    SEG_PER_CATID_ID,
                    SEG_PER_CATID_VALOR,                -- nuevo
                    SEG_PER_CATID_DESCRIPCION,    -- nuevo
                    SEG_PER_CATID_PASIVO,
                    SEG_PER_PRIMER_NOMBRE,
                    SEG_PER_SEGUNDO_NOMBRE,
                    SEG_PER_PRIMER_APELLIDO,
                    SEG_PER_SEGUNDO_APELLIDO,
                    RELSEGUSAL_USR_REGISTRO,
                    RELSEGUSAL_FEC_REGISTRO,
                    RELSEGUSAL_USR_MODIFICACION,
                    RELSEGUSAL_FEC_MODIFICACION,
                    RELSEGUSAL_USR_PASIVA,
                    RELSEGUSAL_FEC_PASIVO,
                    RELSEGUSAL_USR_ELIMINA,
                    RELSEGUSAL_FEC_ELIMINA                      
                FROM
                (               
  SELECT A.CONTROL_VACUNA_ID                                                CTRL_VACUNA_ID, 
         A.EXPEDIENTE_ID                                                    CTRL_EXPEDIENTE_ID, 
         PER.PACIENTE_ID CAPT_PACIENTE_ID,
         SIPAI.FN_OBT_TELEFONO_PACIENTE (EXP.CODIGO_EXPEDIENTE_ELECTRONICO) TEL_PACIENTE,         
         EXP.CODIGO_EXPEDIENTE_ELECTRONICO                                  CTRL_COD_EXPEDIENTE_ELECTRONICO,
         TIPEXP.CODIGO                                                      CTRL_CODEXP_CODIGO,               -- catálogo codigo expediente
         TIPEXP.VALOR                                                       CTRL_CODEXP_VALOR,        
         TIPEXP.PASIVO                                                      CTRL_CODEXP_PASIVO,         
         EXP.SISTEMA_ID                                                     CTRL_CODEXP_SISTEMA_ID,           -- sistema de codigo de expediente
         SIST.NOMBRE                                                        CTRL_CODEXP_SIST_NOMBRE, 
         SIST.DESCRIPCION                                                   CTRL_CODEXP_SIST_DESCRIPCION, 
         SIST.CODIGO                                                        CTRL_CODEXP_SIST_CODIGO,     
         SIST.PASIVO                                                        CTRL_CODEXP_SIST_PASIVO,     
         EXP.UNIDAD_SALUD_ID                                                CTRL_COD_EXP_UNSALUD_ID,          -- unidad de salud de codigo de expediente
         USALUD.NOMBRE                                                      CTRL_CODEXP_US_NOMBRE,    
         USALUD.CODIGO                                                      CTRL_CODEXP_US_CODIGO,    
         USALUD.RAZON_SOCIAL                                                CTRL_CODEXP_US_RSOCIAL, 
         USALUD.DIRECCION                                                   CTRL_CODEXP_US_DIREC,   
         USALUD.EMAIL                                                       CTRL_CODEXP_US_EMAIL,   
         USALUD.ABREVIATURA                                                 CTRL_CODEXP_US_ABREV,   
         USALUD.ENTIDAD_ADTVA_ID                                            CTRL_CODEXP_US_ENTADMIN,
         USALUD.PASIVO                                                      CTRL_CODEXP_US_PASIVO,                       
         PER.PERSONA_ID                                                     PER_PERSONA_ID,   
         PER.IDENTIFICACION                                                 PER_IDENTIFICACION,
         PER.TIPO_IDENTIFICACION                                            PER_CODIGOTIP_ID,  
         CATID.CATALOGO_ID                                                  PER_CATID_ID,                     -- catálogo de tipo de identificación.
         CATID.CODIGO                                                       PER_CATID_CODIGO,
         CATID.VALOR                                                        PER_CATID_VALOR,          
         CATID.DESCRIPCION                                                  PER_CATID_DESCRIPCION,    
         CATID.PASIVO                                                       PER_CATID_PASIVO,
         PER.PRIMER_NOMBRE                                                  PER_PRIMER_NOMBRE,
         PER.SEGUNDO_NOMBRE                                                 PER_SEGUNDO_NOMBRE,
         PER.PRIMER_APELLIDO                                                PER_PRIMER_APELLIDO,
         PER.SEGUNDO_APELLIDO                                               PER_SEGUNDO_APELLIDO,   
         CATSEXO.CATALOGO_ID                                                PER_CATSEXO_ID,                   -- catálogo de sexo persona
         CATSEXO.CODIGO                                                     PER_CATSEXO_CODIGO,      
         CATSEXO.VALOR                                                      PER_CATSEXO_VALOR,       
         CATSEXO.DESCRIPCION                                                PER_CATSEXO_DESCRIPCION, 
         CATSEXO.PASIVO                                                     PER_CATSEXO_PASIVO,                         
         PER.FECHA_NACIMIENTO                                               PER_FEC_NACIMIENTO,
         SIPAI.FN_OBT_EDAD_PERSONA (A.CONTROL_VACUNA_ID, 'A')               PER_EDAD_ANIO, 
         SIPAI.FN_OBT_EDAD_PERSONA (A.CONTROL_VACUNA_ID, 'M')               PER_EDAD_MES,  
         SIPAI.FN_OBT_EDAD_PERSONA (A.CONTROL_VACUNA_ID, 'D')               PER_EDAD_DIA,   
         PER.DIRECCION_DOMICILIO                                            PER_DIRECCION_DOMICILIO,
                                                                         -- datos comunidad id
         PER.COMUNIDAD_ID                                                   PER_COMUNIDAD_ID,
         COMUS.NOMBRE                                                       PER_COMUNIDAD_NOMBRE,
         COMUS.CODIGO                                                       PER_COMUNIDAD_CODIGO,
         COMUS.LATITUD                                                      PER_COMUNIDAD_LATITUD,
         COMUS.LONGITUD                                                     PER_COMUNIDAD_LONGITUD,
         COMUS.PASIVO                                                       PER_COMUNIDAD_PASIVO,
         COMUS.FECHA_PASIVO                                                 PER_COMUNIDAD_FEC_PASIVO,
                                                                              
         COMUS.MUNICIPIO_ID                                                 PER_COM_MUNI_ID,
         MUNUS.NOMBRE                                                       PER_COM_MUNI_NOMBRE,
         MUNUS.CODIGO                                                       PER_COM_MUN_CODIGO,
         MUNUS.CODIGO_CSE                                                   PER_COM_MUN_CODIGO_CSE,
         MUNUS.CODIGO_CSE_REG                                               PER_COM_MUN_CSEREG,
         MUNUS.LATITUD                                                      PER_COM_MUN_LATITUD,
         MUNUS.LONGITUD                                                     PER_COM_MUN_LONGITUD,
         MUNUS.PASIVO                                                       PER_COM_MUN_PASIVO,
         MUNUS.FECHA_PASIVO                                                 PER_COM_MUN_FEC_PASIVO,
                                                                              
         MUNUS.DEPARTAMENTO_ID                                              PER_COM_MUN_DEP_ID,
         DEPUS.NOMBRE                                                       PER_COM_MUN_DEP_NOMBRE,
         DEPUS.CODIGO                                                       PER_COM_MUN_DEP_CODIGO,
         DEPUS.CODIGO_ISO                                                   PER_COM_MUN_DEP_CODISO,
         DEPUS.CODIGO_CSE                                                   PER_COM_MUN_DEP_COD_CSE,
         DEPUS.LATITUD                                                      PER_COM_MUN_DEP_LATITUD,
         DEPUS.LONGITUD                                                     PER_COM_MUN_DEP_LONGITUD,
         DEPUS.PASIVO                                                       PER_COM_MUN_DEP_PASIVO,
         DEPUS.FECHA_PASIVO                                                 PER_COM_MUN_DEP_FEC_PASIVO,
         DEPUS.PAIS_ID                                                      PER_COM_MUN_DEP_PAIS_ID,
         PAUS.NOMBRE                                                        PER_COM_MUN_DEP_PAIS_NOMBRE,
         PAUS.CODIGO                                                        PER_COM_MUN_DEP_PAIS_COD,
         PAUS.CODIGO_ISO                                                    PER_COM_MUN_DEP_PAIS_CODISO,
         PAUS.CODIGO_ALFADOS                                                PER_COM_MUN_DEP_PAIS_CODALF,
         PAUS.CODIGO_ALFATRES                                               PER_COM_MUN_DEP_PAIS_CODALFTR,
         PAUS.PREFIJO_TELF                                                  PER_COM_MUN_DEP_PAIS_PREFTELF,
         PAUS.PASIVO                                                        PER_COM_MUN_DEP_PAIS_PASIVO, 
         PAUS.FECHA_PASIVO                                                  PER_COM_MUN_DEP_PAIS_FECPASIVO,
         DEPUS.REGION_ID                                                    PER_COM_MUN_DEP_REG_ID,
         REGUS.NOMBRE                                                       PER_COM_MUN_DEP_REG_NOMBRE,
         REGUS.CODIGO                                                       PER_COM_MUN_DEP_REG_CODIGO,
         REGUS.PASIVO                                                       PER_COM_MUN_DEP_REG_PASIVO,
         REGUS.FECHA_PASIVO                                                 PER_COM_MUN_DEP_REG_FEC_PASIVO,
                                                                              
         COMUS.DISTRITO_ID                                                  PER_COM_DIS_ID,
         DISUS.NOMBRE                                                       PER_COM_DIS_NOMBRE,
         DISUS.CODIGO                                                       PER_COM_DIS_CODIGO,
         DISUS.PASIVO                                                       PER_COM_DIS_PASIVO,
         DISUS.FECHA_PASIVO                                                 PER_COM_DIS_FEC_PASIVO,
         DISUS.MUNICIPIO_ID                                                 PER_COM_DIS_MUN_ID,  --
         MUNUS1.NOMBRE                                                      PER_COM_DIS_MUN_NOMBRE,
         MUNUS1.CODIGO                                                      PER_COM_DIS_MUN_CODIGO,
         MUNUS1.CODIGO_CSE                                                  PER_COM_DIS_MUN_COD_CSE,
         MUNUS1.CODIGO_CSE_REG                                              PER_COM_DIS_MUN_CODCSEREG,
         MUNUS1.LATITUD                                                     PER_COM_DIS_MUN_LATITUD,
         MUNUS1.LONGITUD                                                    PER_COM_DIS_MUN_LONGITUD,
         MUNUS1.PASIVO                                                      PER_COM_DIS_MUN_PASIVO,
         MUNUS1.FECHA_PASIVO                                                PER_COM_DIS_MUN_FECPASIVO,
                                                                              
         MUNUS1.DEPARTAMENTO_ID                                             PER_COM_DIS_MUN_DEP_ID,
         DEPUS1.NOMBRE                                                      PER_COM_DIS_MUN_DEP_NOMBRE,
         DEPUS1.CODIGO                                                      PER_COM_DIS_MUN_DEP_COD,
         DEPUS1.CODIGO_ISO                                                  PER_COM_DIS_MUN_DEP_CODISO,
         DEPUS1.CODIGO_CSE                                                  PER_COM_DIS_MUN_DEP_CODCSE,
         DEPUS1.LATITUD                                                     PER_COM_DIS_MUN_DEP_LATITUD,
         DEPUS1.LONGITUD                                                    PER_COM_DIS_MUN_DEP_LONGITUD,
         DEPUS1.PASIVO                                                      PER_COM_DIS_MUN_DEP_PASIVO,
         DEPUS1.FECHA_PASIVO                                                PER_COM_DIS_MUN_DEP_FECPASIVO,
         DEPUS1.PAIS_ID                                                     PER_COM_DIS_MUN_DEP_PA_ID,
         PAUS1.NOMBRE                                                       PER_COM_DIS_MUN_DEP_PA_NOMBRE,
         PAUS1.CODIGO                                                       PER_COM_DIS_MUN_DEP_PA_COD,
         PAUS1.CODIGO_ISO                                                   PER_COM_DIS_MUN_DEP_PA_CODISO,
         PAUS1.CODIGO_ALFADOS                                               PER_COM_DIS_MUN_DEP_PA_CODALFA,
         PAUS1.CODIGO_ALFATRES                                              PER_COM_DIS_MUN_DEP_PA_ALFTRES,
         PAUS1.PREFIJO_TELF                                                 PER_COM_DIS_MUN_DEP_PA_PREFTEL,
         PAUS1.PASIVO                                                       PER_COM_DIS_MUN_DEP_PA_PASIVO,
         PAUS1.FECHA_PASIVO                                                 PER_COM_DIS_MUN_DEP_PA_FECPASI,
         DEPUS1.REGION_ID                                                   PER_COM_DIS_MUN_DEP_REG_ID,
         REGUS1.NOMBRE                                                      PER_COM_DIS_MUN_DEP_REG_NOMBRE,
         REGUS1.CODIGO                                                      PER_COM_DIS_MUN_DEP_REG_COD,
         REGUS1.PASIVO                                                      PER_COM_DIS_MUN_DEP_REG_PASIVO,
         REGUS1.FECHA_PASIVO                                                PER_COM_DIS_MUN_DEP_REG_FECPAS,  
         COMUS.LOCALIDAD_ID                                                 PER_COM_LOCALIDAD_ID, 
         Dd.CATALOGO_ID                                                     PER_COM_LOCALIDAD_ID,
         Dd.CODIGO                                                          PER_COM_LOCALIDAD_CODIGO,
         Dd.VALOR                                                           PER_COM_LOCALIDAD_VALOR,
         Dd.DESCRIPCION                                                     PER_COM_LOCALIDAD_DESC,
         Dd.PASIVO                                                          PER_COM_LOCALIDAD_PASIVO,                                
         
         A.PROGRAMA_VACUNA_ID                                               CTRL_PROGRAMA_VACUNA_ID,               -- catálogo de programa vacuna
         CATPROG.CODIGO                                                     CTRL_CATPROG_CODIGO,
         CATPROG.VALOR                                                      CTRL_CATPROG_VALOR,               
         CATPROG.DESCRIPCION                                                CTRL_CATPROG_DESCRIPCION,    
         CATPROG.PASIVO                                                     CTRL_CATPROG_PASIVO,
         A.GRUPO_PRIORIDAD_ID                                               CTRL_GRP_PRIORIDAD_ID,
         CATGRPPRIOR.CODIGO                                                 CTRL_CATGRPPRIOR_CODIGO,
         CATGRPPRIOR.VALOR                                                  CTRL_CATGRPPRIOR_VALOR,               
         CATGRPPRIOR.DESCRIPCION                                            CTRL_CATGRPPRIOR_DESCRIPCION,    
         CATGRPPRIOR.PASIVO                                                 CTRL_CCATGRPPRIOR_PASIVO,
         A.TIPO_VACUNA_ID                                                   CTRL_REL_TIP_VACUNA,                      -- catálogo de tipo vacuna
         RELTIP.TIPO_VACUNA_ID                                              RELTIP_TIPO_VACUNA_ID,
         CATTIPVAC.CODIGO                                                   CTRL_CATTIPVAC_CODIGO,
         CATTIPVAC.VALOR                                                    CTRL_CATTIPVAC_VALOR,          
         CATTIPVAC.DESCRIPCION                                              CTRL_CATTIPVAC_DESCRIPCION,    
         CATTIPVAC.PASIVO                                                   CTRL_CATTIPVAC_PASIVO,         
         RELTIP.FABRICANTE_VACUNA_ID                                        RELTIP_FABRICANTE_VACUNA_ID,               -- catálogo de fabricante vacuna
         CATFABVAC.CODIGO                                                   RELTIP_CATFABVAC_CODIGO,
         CATFABVAC.VALOR                                                    RELTIP_CATFABVAC_VALOR,         
         CATFABVAC.DESCRIPCION                                              RELTIP_CATFABVAC_DESCRIPCION,   
         CATFABVAC.PASIVO                                                   RELTIP_CATFABVAC_PASIVO,                  
         RELTIP.CANTIDAD_DOSIS                                              RELTIP_CANTIDAD_DOSIS,
         RELTIP.ESTADO_REGISTRO_ID                                          RELTIP_CATRELESTREG_ESTADO_ID,             -- catálogo de estado registro rel tipo vacuna dosis
         CATRELESTREG.CODIGO                                                RELTIP_CATRELESTREG_CODIGO,
         CATRELESTREG.VALOR                                                 RELTIP_CATRELESTREG_VALOR,        
         CATRELESTREG.DESCRIPCION                                           RELTIP_CATRELESTREG_DESCRIPCION,  
         CATRELESTREG.PASIVO                                                RELTIP_CATRELESTREG_PASIVO,             
         RELTIP.NUMERO_LOTE                                                 RELTIP_NUMERO_LOTE,
         RELTIP.FECHA_VENCIMIENTO                                           RELTIP_FECHA_VENCIMIENTO,
         RELTIP.USUARIO_REGISTRO                                            RELTIP_USUARIO_REGISTRO,
         RELTIP.FECHA_REGISTRO                                              RELTIP_FECHA_REGISTRO,
         RELTIP.SISTEMA_ID                                                  RELTIP_SISTEMA_ID,                          -- sistema rel tipo vacuna dosis
         RELTIPSIST.NOMBRE                                                  RELTIPSIST_NOMBRE, 
         RELTIPSIST.DESCRIPCION                                             RELTIPSIST_DESCRIPCION, 
         RELTIPSIST.CODIGO                                                  RELTIPSIST_CODIGO,     
         RELTIPSIST.PASIVO                                                  RELTIPSIST_PASIVO,  
         RELTIP.UNIDAD_SALUD_ID                                             RELTIP_UNIDAD_SALUD_ID,                     -- unidad salud tipo vacuna dosis
         RELTIPSALUD.NOMBRE                                                 RELTIPSALUD_US_NOMBRE,    
         RELTIPSALUD.CODIGO                                                 RELTIPSALUD_US_CODIGO,    
         RELTIPSALUD.RAZON_SOCIAL                                           RELTIPSALUD_US_RSOCIAL, 
         RELTIPSALUD.DIRECCION                                              RELTIPSALUD_US_DIREC,   
         RELTIPSALUD.EMAIL                                                  RELTIPSALUD_US_EMAIL,   
         RELTIPSALUD.ABREVIATURA                                            RELTIPSALUD_US_ABREV,   
         RELTIPSALUD.ENTIDAD_ADTVA_ID                                       RELTIPSALUD_US_ENTADMIN,
         RELTIPSALUD.PASIVO                                                 RELTIPSALUD_US_PASIVO, 
         A.ESTADO_REGISTRO_ID                                               CTRL_ESTADO_REGISTRO_ID,                     -- catálogo de estado registro de control vacuna
         CATCTRLESTREG.CODIGO                                               CATCTRLESTREG_CODIGO,
         CATCTRLESTREG.VALOR                                                CATCTRLESTREG_VALOR,              
         CATCTRLESTREG.DESCRIPCION                                          CATCTRLESTREG_DESCRIPCION,    
         CATCTRLESTREG.PASIVO                                               CATCTRLESTREG_PASIVO,           
         A.CANTIDAD_VACUNA_APLICADA                                         CTRL_CANTIDAD_VACUNA_APLICADA,
         A.CANTIDAD_VACUNA_PROGRAMADA                                       CTRL_CANTIDAD_VACUNA_PROGRAMADA, 
         A.FECHA_INICIO_VACUNA                                              CTRL_FECHA_INICIO_VACUNA,
         A.FECHA_FIN_VACUNA                                                 CTRL_FECHA_FIN_VACUNA,
         A.USUARIO_REGISTRO                                                 CTRL_USUARIO_REGISTRO,
         A.FECHA_REGISTRO                                                   CTRL_FECHA_REGISTRO,
         A.USUARIO_MODIFICACION                                             CTRL_USUARIO_MODIFICACION,
         A.FECHA_MODIFICACION                                               CTRL_FECHA_MODIFICACION,
         A.USUARIO_PASIVA                                                   CTRL_USUARIO_PASIVA,
         A.FECHA_PASIVO                                                     CTRL_FECHA_PASIVO,
         A.SISTEMA_ID                                                       CTRL_SISTEMA_ID,                              -- sistema de control de vacuna
         CTRLSIST.NOMBRE                                                    CTRLSIST_NOMBRE, 
         CTRLSIST.DESCRIPCION                                               CTRLSIST_DESCRIPCION, 
         CTRLSIST.CODIGO                                                    CTRLSIST_CODIGO,     
         CTRLSIST.PASIVO                                                    CTRLSIST_PASIVO,  
         A.UNIDAD_SALUD_ID                                                  CTRL_UNI_SALUD_ID,                            -- unidad de salud de control vacuna
         CTRLUSALUD.NOMBRE                                                  CTRLUSALUD_US_NOMBRE,    
         CTRLUSALUD.CODIGO                                                  CTRLUSALUD_US_CODIGO,    
         CTRLUSALUD.RAZON_SOCIAL                                            CTRLUSALUD_US_RSOCIAL, 
         CTRLUSALUD.DIRECCION                                               CTRLUSALUD_US_DIREC,   
         CTRLUSALUD.EMAIL                                                   CTRLUSALUD_US_EMAIL,   
         CTRLUSALUD.ABREVIATURA                                             CTRLUSALUD_US_ABREV,   
         CTRLUSALUD.ENTIDAD_ADTVA_ID                                        CTRLUSALUD_US_ENTADMIN,
         CTRLUSALUD.PASIVO                                                  CTRLUSALUD_US_PASIVO,  
         DETVAC.DET_VACUNACION_ID                                           DETVAC_ID,
         DETVAC.FECHA_VACUNACION                                            DETVAC_FEC_VACUNACION,
         DETVAC.HORA_VACUNACION                                             DETVAC_HORA_VACUNACION,
         DETVAC.NUMERO_LOTE                                                 DETVAC_NUM_LOTE,
         DETVAC.FECHA_VENCIMIENTO                                           DETVAC_FEC_VENCIMIENTO,
         DETVAC.PERSONAL_VACUNA_ID                                          DETVAC_PERSONAL_VACUNA_ID,
         DETPER.PRIMER_NOMBRE                                               DETPER_PRIMER_NOMBRE,
         DETPER.SEGUNDO_NOMBRE                                              DETPER_SEGUNDO_NOMBRE,
         DETPER.PRIMER_APELLIDO                                             DETPER_PRIMER_APELLIDO,
         DETPER.SEGUNDO_APELLIDO                                            DETPER_SEGUNDO_APELLIDO,
         DETPER.CODIGO                                                      DETPER_CODIGO,
         DETPER.ESTADO_REGISTRO_ID                                          DETPER_ESTADO_REG_ID,                             -- catalogo de estado de registro de detalle personal vacuna
         CATDETPER.CODIGO                                                   CATDETPER_CODIGO,
         CATDETPER.VALOR                                                    CATDETPER_VALOR,              
         CATDETPER.DESCRIPCION                                              CATDETPER_DESCRIPCION,    
         CATDETPER.PASIVO                                                   CATDETPER_PASIVO,               
         DETPER.USUARIO_REGISTRO                                            DETPER_USUARIO_REGISTRO,
         DETPER.FECHA_REGISTRO                                              DETPER_FECHA_REGISTRO,
         DETPER.SISTEMA_ID                                                  DETPER_SISTEMA_ID,                                -- sistema de detalle personal vacuna
         SISTDETPER.NOMBRE                                                  SISTDETPER_SIST_NOMBRE, 
         SISTDETPER.DESCRIPCION                                             SISTDETPER_SIST_DESCRIPCION, 
         SISTDETPER.CODIGO                                                  SISTDETPER_SIST_CODIGO,     
         SISTDETPER.PASIVO                                                  SISTDETPER_SIST_PASIVO, 
         DETPER.UNIDAD_SALUD_ID                                             DETPER_UNIDAD_SALUD_ID,                           -- unidad de salud de detalle personal vacuna
         DETPERUSALUD.NOMBRE                                                DETPERUSALUD_US_NOMBRE,    
         DETPERUSALUD.CODIGO                                                DETPERUSALUD_US_CODIGO,    
         DETPERUSALUD.RAZON_SOCIAL                                          DETPERUSALUD_US_RSOCIAL, 
         DETPERUSALUD.DIRECCION                                             DETPERUSALUD_US_DIREC,   
         DETPERUSALUD.EMAIL                                                 DETPERUSALUD_US_EMAIL,   
         DETPERUSALUD.ABREVIATURA                                           DETPERUSALUD_US_ABREV,   
         DETPERUSALUD.ENTIDAD_ADTVA_ID                                      DETPERUSALUD_US_ENTADMIN,
         DETPERUSALUD.PASIVO                                                DETPERUSALUD_US_PASIVO,  
         DETVAC.VIA_ADMINISTRACION_ID                                       DETVAC_VIA_ADMINISTRACION_ID,                     -- catálogo de vía administración
         CATVIAADMIN.CODIGO                                                 CATVIAADMIN_CODIGO,
         CATVIAADMIN.VALOR                                                  CATVIAADMIN_VALOR,              
         CATVIAADMIN.DESCRIPCION                                            CATVIAADMIN_DESCRIPCION,    
         CATVIAADMIN.PASIVO                                                 CATVIAADMIN_PASIVO,               
         DETVAC.ESTADO_REGISTRO_ID                                          DETVAC_ESTADO_REGISTRO_ID,                        -- catálogo de estado registro de detalle vacuna
         CATDETVACESTADO.CODIGO                                             CATDETVACESTADO_CODIGO,
         CATDETVACESTADO.VALOR                                              CATDETVACESTADO_VALOR,              
         CATDETVACESTADO.DESCRIPCION                                        CATDETVACESTADO_DESCRIPCION,    
         CATDETVACESTADO.PASIVO                                             CATDETVACESTADO_PASIVO,     
         DETVAC.USUARIO_REGISTRO                                            DETVAC_USUARIO_REGISTRO,
         DETVAC.FECHA_REGISTRO                                              DETVAC_FECHA_REGISTRO,
         DETVAC.SISTEMA_ID                                                  DETVAC_SISTEMA_ID,                                -- sistema de detalle vacuna
         DETVACSIST.NOMBRE                                                  DETVACSIST_NOMBRE, 
         DETVACSIST.DESCRIPCION                                             DETVACSIST_DESCRIPCION, 
         DETVACSIST.CODIGO                                                  DETVACSIST_CODIGO,     
         DETVACSIST.PASIVO                                                  DETVACSIST_PASIVO,         
         DETVAC.UNIDAD_SALUD_ID                                             DETVAC_UNIDAD_SALUD_ID,                           -- unidad de salud de detalle vacuna
         DETVACUSALUD.NOMBRE                                                DETVACUSALUD_US_NOMBRE,    
         DETVACUSALUD.CODIGO                                                DETVACUSALUD_US_CODIGO,    
         DETVACUSALUD.RAZON_SOCIAL                                          DETVACUSALUD_US_RSOCIAL, 
         DETVACUSALUD.DIRECCION                                             DETVACUSALUD_US_DIREC,   
         DETVACUSALUD.EMAIL                                                 DETVACUSALUD_US_EMAIL,   
         DETVACUSALUD.ABREVIATURA                                           DETVACUSALUD_US_ABREV,   
         DETVACUSALUD.ENTIDAD_ADTVA_ID                                      DETVACUSALUD_US_ENTADMIN,
         DETVACUSALUD.PASIVO                                                DETVACUSALUD_US_PASIVO          
    FROM SIPAI.SIPAI_MST_CONTROL_VACUNA A
    JOIN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE@dbsnh17 EXP
      ON EXP.EXPEDIENTE_ID = A.EXPEDIENTE_ID
      JOIN CATALOGOS.SBC_MST_PERSONAS@dbcat17 PER
        ON EXP.CODIGO_EXPEDIENTE_ELECTRONICO = PER.CODIGO_EXPEDIENTE
                 LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS TIPEXP
                      ON TIPEXP.CATALOGO_ID = PER.TIPO_EXPEDIENTE_ID
                 LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATID
                      ON CATID.CODIGO = PER.TIPO_IDENTIFICACION
              --nuevos join para comunidad persona
                         LEFT JOIN CATALOGOS.SBC_CAT_COMUNIDADES COMUS  --- fsequeira
                          ON COMUS.COMUNIDAD_ID = PER.COMUNIDAD_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_MUNICIPIOS MUNUS
                          ON MUNUS.MUNICIPIO_ID = COMUS.MUNICIPIO_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_DEPARTAMENTOS DEPUS
                          ON DEPUS.DEPARTAMENTO_ID = MUNUS.DEPARTAMENTO_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_PAISES PAUS
                          ON PAUS.PAIS_ID = DEPUS.PAIS_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_REGIONES REGUS
                          ON REGUS.REGION_ID = DEPUS.REGION_ID 
                        LEFT JOIN CATALOGOS.SBC_CAT_DISTRITOS DISUS
                         ON DISUS.DISTRITO_ID = COMUS.DISTRITO_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS Dd
                         ON  Dd.CATALOGO_ID = COMUS.LOCALIDAD_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_MUNICIPIOS MUNUS1
                          ON MUNUS1.MUNICIPIO_ID = DISUS.MUNICIPIO_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_DEPARTAMENTOS DEPUS1
                          ON DEPUS1.DEPARTAMENTO_ID = MUNUS1.DEPARTAMENTO_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_PAISES PAUS1
                          ON PAUS1.PAIS_ID = DEPUS1.PAIS_ID
                        LEFT JOIN CATALOGOS.SBC_CAT_REGIONES REGUS1
                          ON REGUS1.REGION_ID = DEPUS1.REGION_ID             
                         -- fin comunidades                      
                 LEFT JOIN SEGURIDAD.SCS_CAT_SISTEMAS SIST
                     ON SIST.SISTEMA_ID = EXP.SISTEMA_ID
                 LEFT JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALUD
                     ON USALUD.UNIDAD_SALUD_ID = EXP.UNIDAD_SALUD_ID 
                 LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATSEXO  -- NUEVO
                      ON  SUBSTR(CATSEXO.CODIGO,-1) = PER.SEXO_CODIGO
                      AND CATSEXO.CATALOGO_SUP =3780
                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATPROG
                      ON CATPROG.CATALOGO_ID = A.PROGRAMA_VACUNA_ID
                  JOIN CATALOGOS.SBC_CAT_CATALOGOS CATGRPPRIOR
                      ON CATGRPPRIOR.CATALOGO_ID = A.GRUPO_PRIORIDAD_ID                     
                 JOIN SIPAI_REL_TIP_VACUNACION_DOSIS RELTIP
                      ON RELTIP.REL_TIPO_VACUNA_ID = A.TIPO_VACUNA_ID
                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATTIPVAC
                      ON CATTIPVAC.CATALOGO_ID = RELTIP.TIPO_VACUNA_ID      
                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATFABVAC
                      ON CATFABVAC.CATALOGO_ID = RELTIP.FABRICANTE_VACUNA_ID   
                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATRELESTREG
                      ON CATRELESTREG.CATALOGO_ID = RELTIP.ESTADO_REGISTRO_ID   
                 JOIN SEGURIDAD.SCS_CAT_SISTEMAS RELTIPSIST
                      ON RELTIPSIST.SISTEMA_ID = RELTIP.SISTEMA_ID                      
                  JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD RELTIPSALUD
                     ON RELTIPSALUD.UNIDAD_SALUD_ID = RELTIP.UNIDAD_SALUD_ID                       
                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATCTRLESTREG
                      ON CATCTRLESTREG.CATALOGO_ID = A.ESTADO_REGISTRO_ID 
                   LEFT JOIN SEGURIDAD.SCS_CAT_SISTEMAS CTRLSIST
                     ON CTRLSIST.SISTEMA_ID = A.SISTEMA_ID
                 LEFT JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD CTRLUSALUD
                     ON CTRLUSALUD.UNIDAD_SALUD_ID = A.UNIDAD_SALUD_ID 
                 LEFT JOIN SIPAI_DET_VACUNACION DETVAC
                      ON DETVAC.CONTROL_VACUNA_ID = A.CONTROL_VACUNA_ID                                  
                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATVIAADMIN
                      ON CATVIAADMIN.CATALOGO_ID = DETVAC.VIA_ADMINISTRACION_ID 
                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATDETVACESTADO
                      ON CATDETVACESTADO.CATALOGO_ID = DETVAC.ESTADO_REGISTRO_ID 
                 LEFT JOIN SEGURIDAD.SCS_CAT_SISTEMAS DETVACSIST
                     ON DETVACSIST.SISTEMA_ID = DETVAC.SISTEMA_ID 
                 LEFT JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD DETVACUSALUD
                     ON DETVACUSALUD.UNIDAD_SALUD_ID = DETVAC.UNIDAD_SALUD_ID                                                                 
                 JOIN SIPAI_DET_PERSONAL_VACUNA DETPER
                      ON DETPER.PERSONAL_VACUNA_ID = DETVAC.PERSONAL_VACUNA_ID 
                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATDETPER
                      ON CATDETPER.CATALOGO_ID = DETPER.ESTADO_REGISTRO_ID 
                 LEFT JOIN SEGURIDAD.SCS_CAT_SISTEMAS SISTDETPER
                     ON SISTDETPER.SISTEMA_ID = DETPER.SISTEMA_ID   
                 LEFT JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD DETPERUSALUD
                     ON DETPERUSALUD.UNIDAD_SALUD_ID = DETPER.UNIDAD_SALUD_ID      
               WHERE A.CONTROL_VACUNA_ID IN (SELECT B.CONTROL_VACUNA_ID
                                               FROM SIPAI.SIPAI_DET_VACUNACION B
                                              WHERE B.CONTROL_VACUNA_ID = A.CONTROL_VACUNA_ID 
                                                AND B.FECHA_VACUNACION BETWEEN :pFechaInicio AND :pFechaFin)
                      )
                         )B
            WHERE A.CAPTACION_ID = B.CAPT_CAPTACION_ID
           ORDER BY LINE_NUMBER);
    RETURN vRegistro;
   END FN_OBT_PERCTRL_X_FECHAS;