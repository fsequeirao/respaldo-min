declare
 SUBTYPE MAXVARCHAR2 IS VARCHAR2(32000);
vIngresoId          HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE; -- := 186;  -- := 18;                          
vPregIngresoId      HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PREG_INGRESO_ID%TYPE; -- := 235;  -- := 231;  -- := 231;             
vPerNominalId       HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PER_NOMINAL_ID%TYPE; -- := 3311883; -- := 3311884;              
vProcedenciaId      HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PROCEDENCIA_ID%TYPE; -- := 1206;             
vAdmisionId         HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISION_SERVICIO_ID%TYPE; -- := 2938;       
vEdadExactaIng      HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.EDAD_EXACTA_INGRESO%TYPE; -- := '054021800'; -- := '062 anios, 05 meses, 08 días, 00 seg';        
vGrupoEtareoId      HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.GRUPO_ETAREO_ID%TYPE; -- := 37; -- := 79;            
vMedicoIngId        HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_INGRESO_ID%TYPE; -- := 18776;          
vAdminSolicIngId    HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_SOLICITA_INGR_ID%TYPE; -- := 1;
vAdmisionistaIngId  HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_INGRESO_ID%TYPE; -- := 1;    
vMedOrdenaIngId     HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_ORDENA_INGRESO_ID%TYPE; -- := 18776;   
vServProcedenId     HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE;  -- := 3; -- := 74;    
vReingreso          HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO%TYPE; -- := 0;                  
vReingresoId        HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO_ID%TYPE;               
vFecSolicitaIng     HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_SOLICITUD_INGRESO%TYPE; -- := '02/02/2022'; -- := '28/01/2022';    
vHrSolicitudIng     HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_SOLICITUD_INGRESO%TYPE; -- := '18:23:23';     
vFecInicioIngreso   HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_INICIO_INGRESO%TYPE; -- := '02/02/2022';            
vHrInicioIngreso    HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_INICIO_INGRESO%TYPE; -- := '18:25:49';              
vUsalIngresoId      HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.UNIDAD_SALUD_INGRESO%TYPE; -- := 22;             
vServIngresoId      HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_INGRESO_ID%TYPE; -- := 3;              
vEstadoIngId        HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_INGRESO_ID%TYPE := 7649; -- := 7649;                
vTipoEgresoId       HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.TIPO_EGRESO_ID%TYPE; -- := 1218;                   
vFecFinIngreso      HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_FIN_INGRESO%TYPE; -- := '16/02/2022';                
vHrFinIngreso       HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_FIN_INGRESO%TYPE; -- := '11:20';                 
vServEgresoId       HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_EGRESO_ID%TYPE; -- := 13;               
vMedicoEgresoId     HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_EGRESO_ID%TYPE; -- := 18776;                 
vReferenciaId       HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REFERENCIA_ID%TYPE; --;                    
vEsContraferido     HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ES_CONTRAFERIDO%TYPE; -- := 0;                  
vEnvContrareferId   HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ENVIO_CONTRAREFERENCIA_ID%TYPE;        
vDiasEstancia       HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.DIAS_ESTANCIA%TYPE;                    
vEstadoPxId         HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_ID%TYPE; -- := 1280;                     
vEstadoPxEgresoId   HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_EGRESO_ID%TYPE; -- := 1984;              
vComentarios        HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.COMENTARIOS%TYPE; -- := 'Ingresando y enviando el ID del Evento, en este caso corresponde al ID 79';                      
 
vUsuario         SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE := 'fsequeira';  
vAccionEstado    VARCHAR2 (1000);
vTipoAccion      VARCHAR2 (1000) := 'C';                                  
vPgn             NUMBER := 0;
vPgnAct          NUMBER := 1;  
vPgnTmn          NUMBER := 5;
vDatosPaginacion HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.var_refcursor;                              
vRegistro        HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.var_refcursor; 

-- {"datos":{"inicio":"2022-02-09","fin":"2022-03-09","tipoBusqueda":"I","entity":{"estadoIngreso":{"id":7649,"codigo":"STSLPRG|ING"}}},"paginacion":{"pagina":1,"paginaRegistros":5}}

vExpedienteId      NUMBER;       
vNombreCompleto    MAXVARCHAR2;
vCodExpElectronico MAXVARCHAR2;
vIdentificacion    MAXVARCHAR2;
vUsalProcedeId     NUMBER;
vFecInicio         DATE := '09/02/2022';
vFecFin            DATE := '09/03/2022';
vTipIngEgr         MAXVARCHAR2 := 'I';

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
  HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.PR_CRUD_INGRESO_EGRESO (pIngresoId         => vIngresoId,                   
                                                              pPregIngresoId     => vPregIngresoId,               
                                                              pPerNominalId      => vPerNominalId,                
                                                              pProcedenciaId     => vProcedenciaId,               
                                                              pAdmisionId        => vAdmisionId,                  
                                                              pEdadExactaIng     => vEdadExactaIng,               
                                                              pGrupoEtareoId     => vGrupoEtareoId,               
                                                              pMedicoIngId       => vMedicoIngId,                 
                                                              pAdminSolicIngId   => vAdminSolicIngId,             
                                                              pAdmisionistaIngId => vAdmisionistaIngId,           
                                                              pMedOrdenaIngId    => vMedOrdenaIngId,              
                                                              pServProcedenId    => vServProcedenId,              
                                                              pReingreso         => vReingreso,                   
                                                              pReingresoId       => vReingresoId,                 
                                                              pFecSolicitaIng    => vFecSolicitaIng,              
                                                              pHrSolicitudIng    => vHrSolicitudIng,              
                                                              pFecInicioIngreso  => vFecInicioIngreso,            
                                                              pHrInicioIngreso   => vHrInicioIngreso,             
                                                              pUsalIngresoId     => vUsalIngresoId,               
                                                              pServIngresoId     => vServIngresoId,               
                                                              pEstadoIngId       => vEstadoIngId,                 
                                                              pTipoEgresoId      => vTipoEgresoId,                
                                                              pFecFinIngreso     => vFecFinIngreso,               
                                                              pHrFinIngreso      => vHrFinIngreso,                
                                                              pServEgresoId      => vServEgresoId,                
                                                              pMedicoEgresoId    => vMedicoEgresoId,              
                                                              pReferenciaId      => vReferenciaId,                
                                                              pEsContraferido    => vEsContraferido,              
                                                              pEnvContrareferId  => vEnvContrareferId,            
                                                              pDiasEstancia      => vDiasEstancia,                
                                                              pEstadoPxId        => vEstadoPxId,                  
                                                              pEstadoPxEgresoId  => vEstadoPxEgresoId,            
                                                              pComentarios       => vComentarios,                 
                                                              pUsuario           => vUsuario,                     
                                                              pExpedienteId      => vExpedienteId,                
                                                              pNombreCompleto    => vNombreCompleto,       
                                                              pCodExpElectronico => vCodExpElectronico,
                                                              pIdentificacion    => vIdentificacion,   
                                                              pUsalProcedeId     => vUsalProcedeId,   
                                                              pFecInicio         => vFecInicio,                                           
                                                              pFecFin            => vFecFin,                                           
                                                              pTipIngEgr         => vTipIngEgr,                                    
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
--                          LOOP
--                               FETCH vRegistro
--                                INTO vIngresoId,       
--                                     vPregIngresoId;
--                                     
--                          EXIT WHEN vRegistro%NOTFOUND;      
--                               
--                               DBMS_OUTPUT.PUT_LINE('vIngresoId: '|| vIngresoId);         
--                               DBMS_OUTPUT.PUT_LINE('vPregIngresoId: '||vPregIngresoId);
--                          END LOOP;
--                           CLOSE vRegistro;  
                   END CASE;
end;




SELECT *
FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
WHERE INGRESO_ID = 178;

SELECT *
FROM CATALOGOS.SBC_CAT_CATALOGOS
WHERE CATALOGO_ID = 6871

{pProcedenciaId=null, 
pHrSolicitudIng=null, 
pFecSolicitaIng=null, 
pTipoEgresoId=null, 
pIngresoId=18, 
pPregIngresoId=null, 
pAdmisionId=null, 
pAccionEstado=null, 
pAdmisionistaIngId=null, 
pUsuario=jmairena01, 
pPgnTmn=10, 
pAdminSolicIngId=null, 
pReferenciaId=null, 
pTipoAccion=C, 
pPgnAct=1, 
pFecInicioIngreso=null, 
pServIngresoId=null, 
pEstadoPxId=null, 
pEdadExactaIng=null, 
pServProcedenId=null, 
pMedOrdenaIngId=null, 
pHrFinIngreso=null, 
pEnvContrareferId=null, 
pEstadoPxEgresoId=null, 
pReingreso=null, 
pMedicoEgresoId=null, 
pEsContraferido=null, 
pGrupoEtareoId=null, 
pHrInicioIngreso=null, 
pDiasEstancia=null, 
pComentarios=null, 
pPgn=0, 
pServEgresoId=null, 
pEstadoIngId=null, 
pMedicoIngId=null, 
pPerNominalId=null, 
pReingresoId=null, 
pUsalIngresoId=null, 
pFecFinIngreso=null}