
select *
from HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
where cama_id = 141

select *
from HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS
where cama_id = 141

declare
 SUBTYPE MAXVARCHAR2 IS VARCHAR2(32000);
 
 
vIndCamaId          HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.INDISPONIBILIDAD_CAMA_ID%TYPE := 185;      
vCfgUsalServCamaId  HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE;
vCamaId             HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAMA_ID%TYPE := 141;       
vCausaId            HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAUSA_ID%TYPE := 7641;            
vUnidSsaludId       CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE;
vDescSalida         HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_SALIDA%TYPE :='descripcion salida';       
vDescRetorno        HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_RETORNO%TYPE := 'prueba retorno';      
vFecSalida          HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_SALIDA%TYPE := '04/02/2022';             
vHrSalida           HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_SALIDA%TYPE := '15:10';              
vFecRetorno         HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_RETORNO%TYPE := '04/02/2022';            
pHrRetorno          HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_RETORNO%TYPE := '04:00';            

vFecInicio date;
vFecFin    date;   

vUsuario           SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE := 'fsequeira';    
vAccionEstado      MAXVARCHAR2;
vTipoAccion        MAXVARCHAR2 := 'U';
 
                                 
vPgn             NUMBER := 0;
vPgnAct          NUMBER; --:= 1;  
vPgnTmn          NUMBER; --:= 15;
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
  HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_INDISP_CAMAS (pIndCamaId         => vIndCamaId,        
                                                              pCfgUsalServCamaId => vCfgUsalServCamaId,
                                                              pCamaId            => vCamaId,           
                                                              pCausaId           => vCausaId,          
                                                              pUnidSsaludId      => vUnidSsaludId,     
                                                              pDescSalida        => vDescSalida,       
                                                              pDescRetorno       => vDescRetorno,      
                                                              pFecSalida         => vFecSalida,        
                                                              pHrSalida          => vHrSalida,         
                                                              pFecRetorno        => vFecRetorno,       
                                                              pHrRetorno         => pHrRetorno,        
                                                              pUsuario           => vUsuario,       
                                                              pAccionEstado      => vAccionEstado,  
                                                              pFecInicio         => vFecInicio, 
                                                              pFecFin            => vFecFin,   
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
                                 DBMS_OUTPUT.PUT_LINE ('vIndCamaId: '||vIndCamaId);                                                
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
--                                INTO vIndCamaId,       
--                                     vCamaId;
--                                     
--                          EXIT WHEN vRegistro%NOTFOUND;      
--                               
--                               DBMS_OUTPUT.PUT_LINE('vIndCamaId: '|| vIndCamaId);       
--                               DBMS_OUTPUT.PUT_LINE('vCamaId: '||vCamaId);
--                          END LOOP;
--                           CLOSE vRegistro;  
                   END CASE;
end;
        


ALTER TABLE HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS
MODIFY(FECHA_RETORNO DATE)
/