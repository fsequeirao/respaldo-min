declare
 SUBTYPE MAXVARCHAR2 IS VARCHAR2(32000);
vPregIngresoId      HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE; -- :=103;
vAdmisionId         HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISION_ID%TYPE; -- := 723;
vProcedenciaId      HOSPITALARIO.SNH_MST_PREG_INGRESOS.PROCEDENCIA_ID%TYPE;  -- := 3;  -- := 2; 
vPerNominalId       CATALOGOS.SBC_MST_PERSONAS_NOMINAL.PER_NOMINAL_ID%TYPE;  -- := 5506464;  -- := 9042788;
vCodExpElectronico  CATALOGOS.SBC_MST_PERSONAS_NOMINAL.CODIGO_EXPEDIENTE_ELECTRONICO%TYPE;  -- := '001EAMAF01079306 ';  -- := '001FAHAM13099201';
vExpedienteId       HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE;  -- := 4026753;  -- := 3168443;
vNombreCompleto     HOSPITALARIO.SNH_MST_PREG_INGRESOS.NOMBRE_COMPLETO_PX%TYPE := 'arick roque';  -- 'EMMA DE LOS ANGELES MORALES ALFARO';  -- := 'ARICK ROQUE';
vMedOrdenaIngId     HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE;  -- := 20405;  -- := 18778;
vUsalOrigenId       HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_ORIGEN_ID%TYPE;  -- := 1680;
vServProcedenId     HOSPITALARIO.SNH_MST_PREG_INGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE; -- := 3;  -- := 78;
vAdminSolicIngId    HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE;  -- := 48781;  -- := 19150;
vFecSolicitaIng     HOSPITALARIO.SNH_MST_PREG_INGRESOS.FECHA_SOLICITUD_INGRESO%TYPE;  -- := '22/02/2022'; -- := '07/12/2021';
vHrSolicitudIng     HOSPITALARIO.SNH_MST_PREG_INGRESOS.HORA_SOLICITUD_INGRESO%TYPE;  -- := '13:52:08';  -- := '04:58';
vUsalDestinoId      HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE;  -- := 22;  -- := 1635;
vReferenciaId       HOSPITALARIO.SNH_MST_PREG_INGRESOS.REFERENCIA_ID%TYPE;  -- := 1;
vEspDestinoId       HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESPECIALIDAD_DESTINO_ID%TYPE;  -- := 3;  -- := 86;
vEstadoPreIngId     HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PRE_INGRESO_ID%TYPE;  -- := 7648;  -- := 7648;
vComentarios        HOSPITALARIO.SNH_MST_PREG_INGRESOS.COMENTARIOS%TYPE;  -- := 'ritmo cardiaco alto<[mtv-beging]>taquicardia<[mtv-end]>';  -- := 'Esto es una prueba';
vTipIdentiId        HOSPITALARIO.SNH_MST_PREG_INGRESOS.TIPO_IDENTIFICACION_ID%TYPE;  -- := 619;
vIdentificacion     HOSPITALARIO.SNH_MST_PREG_INGRESOS.IDENTIFICACION%TYPE; -- := '0010107930037A';
vEstadoPxId         HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PX_ID%TYPE;  -- := 1280;  -- := 1984;
vUsuario            SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE;  -- := 'fsequeira';    
 vFecInicio date := '28/01/2022';
 vFecFin    date := '28/02/2022';     
vAccionEstado       MAXVARCHAR2;
vTipoAccion         MAXVARCHAR2 := 'C';
 
                                 
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
  HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.PR_CRUD_PRE_INGRESO (pPregIngresoId     => vPregIngresoId,    
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
                          LOOP
                               FETCH vRegistro
                                INTO vPregIngresoId,       
                                     vAdmisionId;
                                     
                          EXIT WHEN vRegistro%NOTFOUND;      
                               
                               DBMS_OUTPUT.PUT_LINE('vPregIngresoId: '|| vPregIngresoId);       
                               DBMS_OUTPUT.PUT_LINE('vAdmisionId: '||vAdmisionId);
                          END LOOP;
                           CLOSE vRegistro;  
                   END CASE;
end;
         

select *
from HOSPITALARIO.SNH_MST_PREG_INGRESOS
WHERE PREG_INGRESO_ID = 133


SNH_MST_PREG_INGRESOS