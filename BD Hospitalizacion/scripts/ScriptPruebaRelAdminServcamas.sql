
declare
 SUBTYPE MAXVARCHAR2 IS VARCHAR2(32000);
 
vAdminServCamaId   HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SRV_CAMA_ID%TYPE;  -- := 24;
vCfgUsalServCamaId HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE := 343; -- := 27;
vAdminServId       HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE := 2938; -- := 2241; 
vFechaInicio       HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE := '07/02/2022';  -- := '26/11/2021';
vHoraInicio        HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE := '09:00';  -- := '09:34'; 
vFechaFin          HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE;
vHoraFin           HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE;
vIsLast            HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.IS_LAST%TYPE;  
vUsalud            CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE;
vUsuario           SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE := 'fsequeira';    
vAccionEstado      MAXVARCHAR2;
vTipoAccion        MAXVARCHAR2 := 'I';
 
                                 
vPgn             NUMBER := 1;
vPgnAct          NUMBER := 1;  
vPgnTmn          NUMBER := 15;
vDatosPaginacion HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.var_refcursor;                              
vRegistro        HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.var_refcursor; 
                          
vResultado       VARCHAR2 (1000);                               
vMsgError        VARCHAR2 (1000); 

 
vCantRegistros    MAXVARCHAR2;
vPaginas          MAXVARCHAR2;
vPagPendientes    MAXVARCHAR2;
vExistePPagina    MAXVARCHAR2;
vExistePAnterior  MAXVARCHAR2;
vExistePSiguiente MAXVARCHAR2;
vExistePUltima    MAXVARCHAR2;



begin 
  HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.PR_CRUD_REL_ADMSRV_CAMAS (pAdminServCamaId   => vAdminServCamaId,      
                                                                  pCfgUsalServCamaId => vCfgUsalServCamaId,
                                                                  pAdminServId       => vAdminServId,      
                                                                  pFechaInicio       => vFechaInicio,      
                                                                  pHoraInicio        => vHoraInicio,       
                                                                  pFechaFin          => vFechaFin,         
                                                                  pHoraFin           => vHoraFin,          
                                                                  pIsLast            => vIsLast,           
                                                                  pUsalud            => vUsalud,           
                                                                  pUsuario           => vUsuario,          
                                                                  pAccionEstado      => vAccionEstado,     
                                                                  pTipoAccion        => vTipoAccion,                        
                                                                  pPgn               => vPgn,             
                                                                  pPgnAct            => vPgnAct,          
                                                                  pPgnTmn            => vPgnTmn,          
                                                                  pDatosPaginacion   => vDatosPaginacion, 
                                                                  pRegistro          => vRegistro,                           
                                                                  pResultado         => vResultado,                              
                                                                  pMsgError          => vMsgError);
                   CASE
                   WHEN vMsgError IS NOT NULL THEN
                        DBMS_OUTPUT.PUT_LINE ('Error: '||vMsgError);      
                        DBMS_OUTPUT.PUT_LINE ('vResultado: '||vResultado);
                   ELSE          DBMS_OUTPUT.PUT_LINE ('Resultado exitoso: '||vResultado); 
                                 DBMS_OUTPUT.PUT_LINE ('vAdminServCamaId: '||vAdminServCamaId);                                                
                          FETCH vDatosPaginacion
                           INTO vCantRegistros,    
                                vPaginas,         
                                vPagPendientes,   
                                vExistePPagina,   
                                vExistePAnterior, 
                                vExistePSiguiente,
                                vExistePUltima;
                                DBMS_OUTPUT.PUT_LINE('vCantRegistros: '|| vCantRegistros);       
                                DBMS_OUTPUT.PUT_LINE('vPaginas: '|| vPaginas);       
                                DBMS_OUTPUT.PUT_LINE('vPagPendientes: '|| vPagPendientes);       
                                DBMS_OUTPUT.PUT_LINE('vExistePPagina: '|| vExistePPagina);       
                                DBMS_OUTPUT.PUT_LINE('vExistePAnterior: '|| vExistePAnterior);       
                                DBMS_OUTPUT.PUT_LINE('vExistePSiguiente: '|| vExistePSiguiente); 
                                DBMS_OUTPUT.PUT_LINE('vExistePUltima: '|| vExistePUltima);
                          LOOP
                               FETCH vRegistro
                                INTO vAdminServCamaId,       
                                     vCfgUsalServCamaId;
                                     
                          EXIT WHEN vRegistro%NOTFOUND;      
                               
                               DBMS_OUTPUT.PUT_LINE('vAdminServCamaId: '|| vAdminServCamaId);       
                               DBMS_OUTPUT.PUT_LINE('vCfgUsalServCamaId: '||vCfgUsalServCamaId);
                          END LOOP;
                           CLOSE vRegistro;  
                   END CASE;
end;
         


select *
from hospitalario.SNH_MST_PREG_INGRESO;


select *
from hospitalario.SNH_REL_ADMSRV_CAMAS;


select *
from HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
WHERE CFG_USLD_SERVICIO_CAMA_ID = 28

SELECT *
FROM CATALOGOS.SBC_CAT_CATALOGOS
WHERE CATALOGO_ID = 1349



                   SELECT ADSERVAMAS.ADMISION_SRV_CAMA_ID        ADMISION_SRV_CAMA_ID,
                           ADSERVAMAS.CFG_USLD_SERVICIO_CAMA_ID   CFG_USLD_SERVICIO_CAMA_ID,
                           CFG.UND_SALUD_SERVICIO_ID              CFGUND_SALUD_SERVICIO_ID, 
                           RELUSALSERV.UNIDAD_SALUD_ID            CFG_RELUSALSERV_USALUD_ID,
                           USALSERV.NOMBRE                        CFG_USALSERV_NOMBRE,
                           USALSERV.CODIGO                        CFG_USALSERV_CODIGO,
                           USALSERV.DIRECCION                     CFG_USALSERV_DIRECCION,
                           USALSERV.ENTIDAD_ADTVA_ID              CFG_USALSERV_ENTIDAD_ADTVA_ID,
                           ENTADMINSERV.NOMBRE                    CFG_ENTADMINSERV_NOMBRE,
                           ENTADMINSERV.CODIGO                    CFG_ENTADMINSERV_CODIGO,
                           ENTADMINSERV.TELEFONO                  CFG_ENTADMINSERV_TELEFONO,
                           ENTADMINSERV.EMAIL                     CFG_ENTADMINSERV_EMAIL,
                           ENTADMINSERV.DIRECCION                 CFG_ENTADMINSERV_DIRECCION,
                           RELUSALSERV.SERVICIO_ID                CFG_RELUSALSERV_SERVICIO_ID,
                           CATSERV.CODIGO                         CFG_CATSERV_CODIGO,
                           CATSERV.NOMBRE                         CFG_CATSERV_NOMBRE,
                           CATSERV.DESCRIPCION                    CFG_CATSERV_DESCRIPCION,
                           CATSERV.PASIVO                         CFG_CATSERV_PASIVO,
                           RELUSALSERV.ESTADO_REGISTRO            CFG_RELUSALSERV_ESTADO_REGISTRO,
                           CATESTREGUSALSERV.CODIGO               CFG_CATESTREGUSALSERV_CODIGO,
                           CATESTREGUSALSERV.VALOR                CFG_CATESTREGUSALSERV_VALOR,
                           CATESTREGUSALSERV.DESCRIPCION          CFG_CATESTREGUSALSERV_DESCRIPCION,
                           RELUSALSERV.USUARIO_REGISTRO           CFG_RELUSALSERV_USR_SERVICIO,
                           RELUSALSERV.FECHA_REGISTRO             CFG_RELUSALSERV_FEC_REGISTRO, 
                           CFG.CODIGO_ASISTENCIAL                 CFG_CODIGO_ASISTENCIAL,       
                           CFG.SALA_ID                            CFG_SALA_ID,                  
                           CFG.HABITACION_ID                      CFG_HABITACION_ID,            
                           CFG.CAMA_ID                            CFG_CAMA_ID,
                           CATCAMAS.NOMBRE                        CFG_CATCAMAS_NOMBRE,
                           CATCAMAS.CODIGO_ADMINISTRATIVO         CFG_CATCAMAS_COD_ADMINISTRATIVO,
                           CATCAMAS.ESTADO_CAMA                   CFG_CATCAMAS_ESTADO_CAMA,
                           CATCAMAS.NO_SERIE                      CFG_CATCAMAS_NO_SERIE,
                           CATCAMAS.ESTADO_REGISTRO_ID            CFG_CATCAMAS_ESTADO_REGISTRO_ID,
                           CATESTREGCAMAS.CODIGO                  CFG_CATESTREGCAMAS_CODIGO,    
                           CATESTREGCAMAS.VALOR                   CFG_CATESTREGCAMAS_VALOR,
                           CATESTREGCAMAS.DESCRIPCION             CFG_CATESTREGCAMAS_DESCRIPCION,
                           CATCAMAS.USUARIO_REGISTRO              CFG_CATCAMAS_USR_REGISTRO,
                           CATCAMAS.FECHA_REGISTRO                CFG_CATCAMAS_FEC_REGISTRO,       
                           CFG.DISPONIBLE                         CFG_DISPONIBLE,                
                           CFG.CENSABLE                           CFG_CENSABLE,       
                           CFG.ESTADO_CAMA_ID                     CFG_ESTADO_CAMA_ID, 
                           CATESTCAMA.CODIGO                      CFG_CATESTCAMA_CODIGO,
                           CATESTCAMA.VALOR                       CFG_CATESTCAMA_VALOR,
                           CATESTCAMA.DESCRIPCION                 CFG_CATESTCAMA_DESCRIPCION,
                           CFG.IS_LAST                            CFG_IS_LAST,                  
                           CFG.ESTADO_REGISTRO_ID                 CFG_ESTADO_REGISTRO_ID,  
                           CATESREG.CODIGO                        CFG_CATESREG_CODIGO,
                           CATESREG.VALOR                         CFG_CATESREG_VALOR,
                           CATESREG.DESCRIPCION                   CFG_CATESREG_DESCRIPCION,
                           CFG.USUARIO_REGISTRO                   CFG_USUARIO_REGISTRO,            
                           CFG.FECHA_REGISTRO                     CFG_FECHA_REGISTRO,      
                           ADSERVAMAS.ADMISION_SERVICIO_ID        ADMISION_SERVICIO_ID,
                           ADSERVAMAS.FECHA_INI                   FECHA_INI,
                           ADSERVAMAS.HORA_INI                    HORA_INI,
                           ADSERVAMAS.FECHA_FIN                   FECHA_FIN,
                           ADSERVAMAS.HORA_FIN                    HORA_FIN,
                           ADSERVAMAS.IS_LAST                     IS_LAST,
                           ADSERVAMAS.ESTADO_REGISTRO_ID          ESTADO_REGISTRO_ID, 
                           CATESREGADM.CODIGO                     CATESREG_CODIGO,
                           CATESREGADM.VALOR                      CATESREG_VALOR,
                           CATESREGADM.DESCRIPCION                CATESREG_DESCRIPCION,
                           ADSERVAMAS.USUARIO_REGISTRO            USUARIO_REGISTRO,
                           ADSERVAMAS.FECHA_REGISTRO              FECHA_REGISTRO,
                           ADSERVAMAS.USUARIO_MODIFICACION        USUARIO_MODIFICACION,
                           ADSERVAMAS.FECHA_MODIFICACION          FECHA_MODIFICACION,
                           ADSERVAMAS.USUARIO_PASIVA              USUARIO_PASIVA,
                           ADSERVAMAS.FECHA_PASIVA                FECHA_PASIVA,
                           ADSERVAMAS.USUARIO_ELIMINA             USUARIO_ELIMINA,
                           ADSERVAMAS.FECHA_ELIMINA               FECHA_ELIMINA
                    FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS ADSERVAMAS
                    LEFT JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFG
                      ON ADSERVAMAS.CFG_USLD_SERVICIO_CAMA_ID = CFG.CFG_USLD_SERVICIO_CAMA_ID
                      AND CFG.IS_LAST = 1
                    JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS RELUSALSERV
                      ON RELUSALSERV.UND_SALUD_SERVICIO_ID = CFG.UND_SALUD_SERVICIO_ID
                    JOIN HOSPITALARIO.SNH_CAT_SERVICIOS CATSERV
                      ON CATSERV.SERVICIO_ID = RELUSALSERV.SERVICIO_ID
                    JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGUSALSERV
                      ON CATESTREGUSALSERV.CATALOGO_ID = RELUSALSERV.ESTADO_REGISTRO
                    JOIN HOSPITALARIO.SNH_CAT_CAMAS CATCAMAS
                      ON CATCAMAS.CAMA_ID = CFG.CAMA_ID
                    JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGCAMAS  
                      ON CATESTREGCAMAS.CATALOGO_ID = CATCAMAS.ESTADO_REGISTRO_ID 
                    JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTCAMA
                      ON CATESTCAMA.CATALOGO_ID = CFG.ESTADO_CAMA_ID
                    JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESREG
                      ON CATESREG.CATALOGO_ID = CFG.ESTADO_REGISTRO_ID
                    JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALSERV
                      ON USALSERV.UNIDAD_SALUD_ID = RELUSALSERV.UNIDAD_SALUD_ID
                    JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADMINSERV
                      ON ENTADMINSERV.ENTIDAD_ADTVA_ID = USALSERV.ENTIDAD_ADTVA_ID
                    JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESREGADM
                      ON CATESREGADM.CATALOGO_ID = ADSERVAMAS.ESTADO_REGISTRO_ID  
                    WHERE ADSERVAMAS.ADMISION_SRV_CAMA_ID = 24;
                    
                    
SELECT *
FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
WHERE 

SELECT *
FROM HOSPITALARIO.SNH_CAT_CAMAS
WHERE CAMA_ID = 9

SELECT *
FROM HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS
WHERE UND_SALUD_SERVICIO_ID = 179;


SELECT *
FROM HOSPITALARIO.SNH_CAT_SERVICIOS
WHERE SERVICIO_ID = 2