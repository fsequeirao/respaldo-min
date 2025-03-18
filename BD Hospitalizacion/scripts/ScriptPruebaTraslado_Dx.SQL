declare
SUBTYPE vMAXVAR IS VARCHAR2(32000);
vTrasladoId      HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS.TRASLADO_ID%TYPE;
vIngresoId       HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE;
vAdminServId     HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE;
vUsuario         SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE := 'fsequeira';
vAccionEstado    vMAXVAR;                                
vFecInicio       vMAXVAR;                                    
vFecFin          vMAXVAR;                                    
vTipoAccion      vMAXVAR := 'C';          
vPgn             vMAXVAR;            
vPgnAct          NUMBER := 1;  
vPgnTmn          NUMBER := 100;
vDatosPaginacion HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.var_refcursor;    
vRegistro        HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.var_refcursor;    
vResultado       vMAXVAR;         
vMsgError        vMAXVAR;


vClob CLOB;
vCantRegistros    vMAXVAR;
vPaginas          vMAXVAR;
vPagPendientes    vMAXVAR;
vExistePPagina    vMAXVAR;
vExistePAnterior  vMAXVAR;
vExistePSiguiente vMAXVAR;
vExistePUltima    vMAXVAR;

vJson4  vMAXVAR :=' {
      "ingreso": {
        "id": 250
      }
    }';

vJson3 vMAXVAR :='{
"id": null,
"fecha":null,
"servicioDestino": {
"id": 6
},
"cnfServicioCamasOrigen": {
"id": 369
},
"motivo": null,
"cnfServicioCamasDestino": {
"id": 370
},
"ingreso": {
"admisionServicio": {
"id": 3296
},
"id": 195
},
"servicioOrigen": {
"id": 17
},
"hora": null,
"medico": {
"id": 31396
},
"observaciones": null,
"diagnosticos": [
{
"id":2493, 
"relDiagnostico": {
"tipoDxIngEgreso": {
"codigo": "DXTSR",
"id": 8257
}
},
"activar": false,
"tipoDiagnostico": {
"codigo": "TDIAGNOSTICOING|PRINCIPAL",
"id": 1214
},
"diagnostico": "Enfermedad simulada 1 fsequeira",
"pasivar": false,
"mperSalud": {
"id": 31396
},
"usuarioCodifica": {
"id": 40975
},
"cie": {
"id": 239787
}
},
{
"id":2494,
"relDiagnostico": {
"tipoDxIngEgreso": {
"codigo": "DXTSR",
"id": 8257
}
},
"activar": false,
"tipoDiagnostico": {
"codigo": "TDIAGNOSTICOING|COMPLEMENTARIO",
"id": 1213
},
"diagnostico": "Enfermedad simulada 2 fsequeira",
"pasivar": false,
"mperSalud": {
"id": 31396
},
"usuarioCodifica": {
"id": 40975
},
"cie": {
"id": 239787
}
}
]
}';

vJson2 vMAXVAR :='{
"id": 22,
"fecha": "2022-03-16",
"servicioDestino": {
"id": 6
},
"cnfServicioCamasOrigen": {
"id": 369
},
"motivo": "Esto es una simulación de traslado entre servicios fsequeira",
"cnfServicioCamasDestino": {
"id": 370
},
"ingreso": {
"admisionServicio": {
"id": 3296
},
"id": 195
},
"servicioOrigen": {
"id": 17
},
"hora": "14:22:09",
"medico": {
"id": 31396
},
"observaciones": "Mi primer traslado exitoso! fsequeira",
"diagnosticos": [
{
"id":2493, 
"relDiagnostico": {
"tipoDxIngEgreso": {
"codigo": "DXTSR",
"id": 8257
}
},
"activar": false,
"tipoDiagnostico": {
"codigo": "TDIAGNOSTICOING|PRINCIPAL",
"id": 1214
},
"diagnostico": "Enfermedad simulada 1 fsequeira",
"pasivar": false,
"mperSalud": {
"id": 31396
},
"usuarioCodifica": {
"id": 40975
},
"cie": {
"id": 239787
}
},
{
"id":2494,
"relDiagnostico": {
"tipoDxIngEgreso": {
"codigo": "DXTSR",
"id": 8257
}
},
"activar": false,
"tipoDiagnostico": {
"codigo": "TDIAGNOSTICOING|COMPLEMENTARIO",
"id": 1213
},
"diagnostico": "Enfermedad simulada 2 fsequeira",
"pasivar": false,
"mperSalud": {
"id": 31396
},
"usuarioCodifica": {
"id": 40975
},
"cie": {
"id": 239787
}
}
]
}';

vJson vMAXVAR := '{
"fecha": "2022-03-16",
"servicioDestino": {
"id": 6
},
"cnfServicioCamasOrigen": {
"id": 369
},
"motivo": "Esto es una simulación de traslado entre servicios fsequeira",
"cnfServicioCamasDestino": {
"id": 370
},
"ingreso": {
"admisionServicio": {
"id": 3296
},
"id": 195
},
"servicioOrigen": {
"id": 17
},
"hora": "14:22:09",
"medico": {
"id": 31396
},
"observaciones": "Mi primer traslado exitoso fsequeira!",
"diagnosticos": [
{
"relDiagnostico": {
"tipoDxIngEgreso": {
"codigo": "DXTSR",
"id": 8257
}
},
"activar": false,
"tipoDiagnostico": {
"codigo": "TDIAGNOSTICOING|PRINCIPAL",
"id": 1214
},
"diagnostico": "Enfermedad simulada 1 fsequeira",
"pasivar": false,
"mperSalud": {
"id": 31396
},
"usuarioCodifica": {
"id": 40975
},
"cie": {
"id": 239787
}
},
{
"relDiagnostico": {
"tipoDxIngEgreso": {
"codigo": "DXTSR",
"id": 8257
}
},
"activar": false,
"tipoDiagnostico": {
"codigo": "TDIAGNOSTICOING|COMPLEMENTARIO",
"id": 1213
},
"diagnostico": "Enfermedad simulada 2",
"pasivar": false,
"mperSalud": {
"id": 31396
},
"usuarioCodifica": {
"id": 40975
},
"cie": {
"id": 239787
}
}
]
}';

begin
HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.PR_CRUD_TRASLADO_DX (pTrasladoId      => vTrasladoId,     
                                                           pIngresoId       => vIngresoId,      
                                                           pAdminServId     => vAdminServId,    
                                                           pUsuario         => vUsuario,        
                                                           pAccionEstado    => vAccionEstado,   
                                                           pFecInicio       => vFecInicio,      
                                                           pFecFin          => vFecFin,         
                                                           pJson            => vJson4,           
                                                           pTipoAccion      => vTipoAccion,     
                                                           pPgn             => vPgn,            
                                                           pPgnAct          => vPgnAct,         
                                                           pPgnTmn          => vPgnTmn,         
                                                           pDatosPaginacion => vDatosPaginacion,
                                                           pRegistro        => vRegistro,       
                                                           pResultado       => vResultado,      
                                                           pMsgError        => vMsgError);
                                      CASE
                                      WHEN vMsgError IS NOT NULL THEN
                                           DBMS_OUTPUT.PUT_LINE ('error: '||vMsgError);
                                      ELSE DBMS_OUTPUT.PUT_LINE ('proceso exitoso');
                                            DBMS_OUTPUT.PUT_LINE ('vResultado: '||vResultado);
                                          -- dbms_output.put_line ('id notas: '||vDetNotaId);
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
                                                                INTO vClob;
                                                                     --vIngresoId,       
                                                                     --vPregIngresoId;
                                                                                                 
                                                          EXIT WHEN vRegistro%NOTFOUND;      
                                                               DBMS_OUTPUT.PUT_LINE ('vClob: '||vClob);
                                                             --  DBMS_OUTPUT.PUT_LINE('vIngresoId: '|| vIngresoId);         
                                                             --  DBMS_OUTPUT.PUT_LINE('vPregIngresoId: '||vPregIngresoId);
                                                          END LOOP;
                                                           CLOSE vRegistro;  

                                      END CASE;                                                                   

end;




select ROWID,A.*
from HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS A;


select *
from HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG
where traslado_id= 22

13

= 2397

traslado_id in (5,6)


select *
from hospitalario.snh_mst_diagnosticos
where admision_servicio_id = 3296
and diagnostico_id in (2493,
2494)