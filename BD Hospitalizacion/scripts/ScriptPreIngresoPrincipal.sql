declare
 SUBTYPE MAXVARCHAR2 IS VARCHAR2(32000);
vPregIngresoId      HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE;  -- := 93;
vAdmisionId         HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISION_ID%TYPE; -- := 723;
vProcedenciaId      HOSPITALARIO.SNH_MST_PREG_INGRESOS.PROCEDENCIA_ID%TYPE;  -- := 2; 
vPerNominalId       CATALOGOS.SBC_MST_PERSONAS_NOMINAL.PER_NOMINAL_ID%TYPE;  -- := 9042788;
vCodExpElectronico  CATALOGOS.SBC_MST_PERSONAS_NOMINAL.CODIGO_EXPEDIENTE_ELECTRONICO%TYPE := '001FJMUM31037303';  --'0013103730030Q';  -- := '001FAHAM13099201';
vExpedienteId       HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE;  -- := 3168443;
vNombreCompleto     HOSPITALARIO.SNH_MST_PREG_INGRESOS.NOMBRE_COMPLETO_PX%TYPE;  -- := 'FABIO ALEXEIS HERNANDEZ ACOSTA';
vMedOrdenaIngId     HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE;  -- := 18778;
vUsalOrigenId       HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_ORIGEN_ID%TYPE;  -- := 1680;
vServProcedenId     HOSPITALARIO.SNH_MST_PREG_INGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE;  -- := 78;
vAdminSolicIngId    HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE;  -- := 19150;
vFecSolicitaIng     HOSPITALARIO.SNH_MST_PREG_INGRESOS.FECHA_SOLICITUD_INGRESO%TYPE;  -- := '08/10/2021';
vHrSolicitudIng     HOSPITALARIO.SNH_MST_PREG_INGRESOS.HORA_SOLICITUD_INGRESO%TYPE;  -- := '04:58';
vUsalDestinoId      HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE;  -- := 22;  -- := 1635;
vReferenciaId       HOSPITALARIO.SNH_MST_PREG_INGRESOS.REFERENCIA_ID%TYPE;  -- := 1;
vEspDestinoId       HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESPECIALIDAD_DESTINO_ID%TYPE;  -- := 86;
vEstadoPreIngId     HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PRE_INGRESO_ID%TYPE; -- := 7648;
vComentarios        HOSPITALARIO.SNH_MST_PREG_INGRESOS.COMENTARIOS%TYPE;  -- := 'Esto es una prueba';
vTipIdentiId        HOSPITALARIO.SNH_MST_PREG_INGRESOS.TIPO_IDENTIFICACION_ID%TYPE;  -- := 619;
vIdentificacion     HOSPITALARIO.SNH_MST_PREG_INGRESOS.IDENTIFICACION%TYPE; -- := '0011309920004J';
vEstadoPxId         HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PX_ID%TYPE; -- := 1984;
vUsuario            SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE := 'fsequeira';    
vAccionEstado       MAXVARCHAR2;
vTipoAccion         MAXVARCHAR2 := 'C';

vFecInicio          DATE;  -- := '15/01/2022';
vFecFin             DATE;  -- := '15/02/2022';   
                                 
vPgn             NUMBER := 1;
vPgnAct          NUMBER := 1;  
vPgnTmn          NUMBER := 10;
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
  HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_PRE_INGRESO (pPregIngresoId      => vPregIngresoId,           
                                                            pAdmisionId        => vAdmisionId,            
                                                            pProcedenciaId     => vProcedenciaId,         
                                                            pPerNominalId      => vPerNominalId,          
                                                            pCodExpElectronico => vCodExpElectronico,     
                                                            pExpedienteId      => vExpedienteId,          
                                                            pNomCompletoPx     => vNombreCompleto,        
                                                            pMedOrdenaIngId    => vMedOrdenaIngId,        
                                                            pUsalOrigenId      => vUsalOrigenId,          
                                                            pServProcedenId    => vServProcedenId,        
                                                            pAdminSolicIngId   => vAdminSolicIngId,       
                                                            pFecSolicitaIng    => vFecSolicitaIng,        
                                                            pHrSolicitudIng    => vHrSolicitudIng,        
                                                            pUsalDestinoId     => vUsalDestinoId,         
                                                            pReferenciaId      => vReferenciaId,          
                                                            pEspDestinoId      => vEspDestinoId,          
                                                            pEstadoPreIngId    => vEstadoPreIngId,        
                                                            pComentarios       => vComentarios,           
                                                            pTipIdentiId       => vTipIdentiId,           
                                                            pIdentificacion    => vIdentificacion,        
                                                            pEstadoPxId        => vEstadoPxId,            
                                                            pUsuario           => vUsuario,               
                                                            pFecInicio         => vFecInicio,             
                                                            pFecFin            => vFecFin,                
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
                                 DBMS_OUTPUT.PUT_LINE ('vPregIngresoId: '||vPregIngresoId);                                                
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
--                                INTO vPregIngresoId,       
--                                     vAdmisionId;
--                                     
--                          EXIT WHEN vRegistro%NOTFOUND;      
--                               
--                               DBMS_OUTPUT.PUT_LINE('vPregIngresoId: '|| vPregIngresoId);       
--                               DBMS_OUTPUT.PUT_LINE('vAdmisionId: '||vAdmisionId);
--                          END LOOP;
--                           CLOSE vRegistro;  
                   END CASE;
end;
         


select *
from hospitalario.SNH_MST_PREG_INGRESO