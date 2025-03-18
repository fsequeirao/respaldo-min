declare
 SUBTYPE MAXVARCHAR2 IS VARCHAR2(32000);
vDetNotaId            HOSPITALARIO.SNH_MST_NOTAS.DET_NOTA_ID%TYPE;
vAdmServId            HOSPITALARIO.SNH_MST_NOTAS.ADMISION_SERVICIO_ID%TYPE;  -- := 3299;
vFecNota              HOSPITALARIO.SNH_MST_NOTAS.FECHA_NOTA%TYPE;
vHrNota               HOSPITALARIO.SNH_MST_NOTAS.HORA_NOTA%TYPE;
vTipNota              HOSPITALARIO.SNH_MST_NOTAS.TIPO_NOTA_ID%TYPE;
vMpersSaludPrincipal  HOSPITALARIO.SNH_MST_NOTAS.MPERS_SALUD_ID%TYPE;
vPerSaludEvoNotaId    HOSPITALARIO.SNH_DET_NOTAS.PERSALUD_EVO_NOTA_ID%TYPE;
vTipNotaDetId         HOSPITALARIO.SNH_DET_NOTAS.TIPO_DET_NOTA_ID%TYPE;
vCometario            HOSPITALARIO.SNH_DET_NOTAS.COMENTARIOS%TYPE;
vRelMperNotaId        HOSPITALARIO.SNH_REL_MPERS_NOTA.REL_MPERS_NOTA_ID%TYPE;
vMpersSaludNota       HOSPITALARIO.SNH_REL_MPERS_NOTA.MPERS_SALUD_ID%TYPE;
vEsPrincipal          HOSPITALARIO.SNH_REL_MPERS_NOTA.ES_PRINCIPAL%TYPE; 
vUsuario              SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE := 'fsequeira'; 
vAccionEstado         HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.MAXVARCHAR2;                                  
vFecInicio            DATE;
vFecFin               DATE; 
vJson                 HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.MAXVARCHAR2;
vTipoAccion           HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.MAXVARCHAR2 := 'D';
vPgn                  NUMBER := 1;
vPgnAct               NUMBER := 1; 
vPgnTmn               NUMBER := 5;
vDatosPaginacion      HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.var_refcursor;
vRegistro             HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.var_refcursor;                           
vResultado            HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.MAXVARCHAR2;                                
vMsgError             HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.MAXVARCHAR2;

vClob CLOB;
vCantRegistros    MAXVARCHAR2;
vPaginas          MAXVARCHAR2;
vPagPendientes    MAXVARCHAR2;
vExistePPagina    MAXVARCHAR2;
vExistePAnterior  MAXVARCHAR2;
vExistePSiguiente MAXVARCHAR2;
vExistePUltima    MAXVARCHAR2;

-- {"datos":

begin
-- consulta
--vJson := 
--'
--{
--"admisionServicio": {"id": 3299}
--}';
--
--'
--{
--"datos": {
--"all": 0,
--"entity": {
--"admisionServicio": {"id": 3299}
--}
--}
--}';
--INSERT
--vJson := 
--'{"id":0,"admisionServicio":{"id":3258},"tipoNota":{"id":8184,"codigo":"TPINSTNTENF"},"servicio":{"id":null},"personalSalud":{"id":1},"detalleNotas":[{"id":null,"descripcionNota":{"id":8186,"codigo":"NTENFOBS"},"comentarios":"LIMPIAR HERIDA"}],"fecha":"2022-03-08","hora":"00:15:31"}';
--'{"id":null,"admisionServicio":{"id":3258},"tipoNota":{"id":8184,"codigo":"TPINSTNTEVT"},"servicio":{"id":null},"personalSalud":{"id":18776},"detalleNotas":[{"id":null,"descripcionNota":{"id":8187,"codigo":"NTEVTPRBEV"},"comentarios":"DOLOR DE ARTICULACIONES"},{"id":null,"descripcionNota":{"id":8188,"codigo":"NTEVTPLNS"},"comentarios":"IBUPROFENO CADA 8 HORAS"}],"fecha":"2022-03-07","hora":"00:39:58"}';
-- UPDATE
vJson := 
--'{"id":0,"admisionServicio":{"id":3258},"tipoNota":{"id":8184,"codigo":"TPINSTNTENF"},"servicio":{"id":null},"personalSalud":{"id":1},"detalleNotas":[{"id":null,"descripcionNota":{"id":8186,"codigo":"NTENFOBS"},"comentarios":"LIMPIAR HERIDA"}],"fecha":"2022-03-08","hora":"00:15:31"}';
 '{"id":119,"admisionServicio":{"id":3258},"tipoNota":{"id":8184,"codigo":"TPINSTNTEVT"},"servicio":{"id":null},"personalSalud":{"id":18776},"detalleNotas":[{"id":151,"descripcionNota":{"id":8187,"codigo":"NTEVTPRBEV"},"comentarios":"DOLOR DE ARTICULACIONES PRUEBA"},{"id":152,"descripcionNota":{"id":8188,"codigo":"NTEVTPLNS"},"comentarios":"IBUPROFENO CADA 7 HORAS"}],"fecha":"2022-03-07","hora":"00:39:58"}';

--'
--    {
--      "id" :63,
--      "admisionServicio" :
--      {
--        "id" : 605
--      },
--      "fecha" : "2022-03-01",
--      "hora" : "17:40",
--      "personalSalud" :
--      {
--        "id" : 1321
--      },
--      "tipoNota" :
--      {
--        "id" : 8184,
--        "codigo" : "TPINSTNTENF",
--        "valor" : "NOTA DE ENFERMERIA",
--        "descripcion" : "INSTRUMENTO DE NOTAS DE ENFEMERIA"
--      },
--      "detalleNotas" :
--      [
--        {
--          "id" : null,
--          "descripcionNota" :
--          {
--            "id" : 8184,
--            "codigo" : "TPINSTNTENF",
--            "valor" : "NOTA DE ENFERMERIA",
--            "descripcion" : "INSTRUMENTO DE NOTAS DE ENFEMERIA"
--          },
--          "comentario" : "PRUEBA"
--        },
--        {
--          "id" : null,
--          "descripcionNota" :
--          {
--            "id" : 8184,
--            "codigo" : "TPINSTNTENF",
--            "valor" : "NOTA DE ENFERMERIA",
--            "descripcion" : "INSTRUMENTO DE NOTAS DE ENFEMERIA"
--          },
--          "comentario" : "PRUEBA 2"
--        }
--      ],
--      "estadoRegId" : 6869,
--      "estadoRegistro" :
--      {
--        "id" : 6869,
--        "codigo" : "ACTREG",
--        "valor" : "Activo",
--        "descripcion" : "Registro Activo"
--      },
--      "usrRegistro" : "fsequeira",
--      "fechaRegistro" : "2022-02-21T13:36:46",
--      "usrModificacion" : null,
--      "fechaModificacion" : null,
--      "usrPasiva" : null,
--      "fechaPasiva" : null,
--      "usrElimina" : null,
--      "fechaElimina" : null
--    }
--';

--
--'{
--      "id" : null,
--      "hora": "15:40",
--      "fecha": "2022-02-28",
--      "tipoNota": 8184,
--      "personalSalud" : {
--                         "id": 1321,
--                         "codigo": "5124",
--                         "registroSanitario":null,
--                         "persona":null  
--                        },
--      "admisionServicio" : {
--                            "id": 2938,
--                            "admision": null
--                           },
--      "detalleNotas" : [
--                        {
--                         "id" : null,
--                         "nota" :{
--                                  "id" : null
--                                 },
--                         "descripcionNota" :"prueba",
--                         "comentarios" : "prueba"
--                        },
--                        {
--                         "id" : null,
--                         "nota" :{
--                                  "id" : null
--                                 },
--                         "descripcionNota" :"prueba",
--                         "comentarios" : "prueba"
--                        },
--                       ]                  
--    }';

HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.PR_CRUD_MST_NOTAS (pDetNotaId           => vDetNotaId,                
                                                         pAdmServId           => vAdmServId,         
                                                         pFecNota             => vFecNota,            
                                                         pHrNota              => vHrNota,             
                                                         pTipNota             => vTipNota,            
                                                         pMpersSaludPrincipal => vMpersSaludPrincipal,
                                                         pPerSaludEvoNotaId   => vPerSaludEvoNotaId,  
                                                         pTipNotaDetId        => vTipNotaDetId,       
                                                         pCometario           => vCometario,          
                                                         pUsuario             => vUsuario,            
                                                         pAccionEstado        => vAccionEstado,       
                                                         pFecInicio           => vFecInicio,          
                                                         pFecFin              => vFecFin,             
                                                         pJson                => vJson,               
                                                         pTipoAccion          => vTipoAccion,         
                                                         pPgn                 => vPgn,                
                                                         pPgnAct              => vPgnAct,             
                                                         pPgnTmn              => vPgnTmn,             
                                                         pDatosPaginacion     => vDatosPaginacion,    
                                                         pRegistro            => vRegistro,           
                                                         pResultado           => vResultado,          
                                                         pMsgError            => vMsgError);   
                                                      
                                      CASE
                                      WHEN vMsgError IS NOT NULL THEN
                                           DBMS_OUTPUT.PUT_LINE ('error: '||vMsgError);
                                      ELSE DBMS_OUTPUT.PUT_LINE ('proceso exitoso');
                                            DBMS_OUTPUT.PUT_LINE ('vResultado: '||vResultado);
                                           dbms_output.put_line ('id notas: '||vDetNotaId);
--                                           FETCH vDatosPaginacion
--                                           INTO vCantRegistros,    
--                                                vPaginas,         
--                                                vPagPendientes,   
--                                                vExistePPagina,   
--                                                vExistePAnterior, 
--                                                vExistePSiguiente,
--                                                vExistePUltima;
--                                                DBMS_OUTPUT.PUT_LINE('vCantRegistros: '|| vCantRegistros);       
--                                                DBMS_OUTPUT.PUT_LINE('vPaginas: '|| vPaginas);       
--                                                DBMS_OUTPUT.PUT_LINE('vPagPendientes: '|| vPagPendientes);       
--                                                DBMS_OUTPUT.PUT_LINE('vExistePPagina: '|| vExistePPagina);       
--                                                DBMS_OUTPUT.PUT_LINE('vExistePAnterior: '|| vExistePAnterior);     
--                                                DBMS_OUTPUT.PUT_LINE('vExistePSiguiente: '|| vExistePSiguiente); 
--                                                DBMS_OUTPUT.PUT_LINE('vExistePUltima: '|| vExistePUltima);
--                                                          LOOP
--                                                               FETCH vRegistro
--                                                                INTO vClob;
--                                                                     --vIngresoId,       
--                                                                     --vPregIngresoId;
--                                                                                                 
--                                                          EXIT WHEN vRegistro%NOTFOUND;      
--                                                               DBMS_OUTPUT.PUT_LINE ('vClob: '||vClob);
--                                                             --  DBMS_OUTPUT.PUT_LINE('vIngresoId: '|| vIngresoId);         
--                                                             --  DBMS_OUTPUT.PUT_LINE('vPregIngresoId: '||vPregIngresoId);
--                                                          END LOOP;
--                                                           CLOSE vRegistro;  

                                      END CASE;  
                                      

end;

28/2/2022 00:00:00    15:40


select ROWID,A.*
from hospitalario.snh_mst_notas A
where -- admision_servicio_id = 3299
det_nota_id = 119

122

select ROWID,A.*
from hospitalario.snh_det_notas A
where -- persalud_evo_nota_id = 156
det_nota_id = 119

156

122


delete hospitalario.snh_det_notas A
where det_nota_id = 45;



delete hospitalario.snh_mst_notas A
where det_nota_id = 45;

SELECT ROWID,A.*
FROM hospitalario.SNH_JSON_DATA a



SELECT json_serialize(a.info PRETTY) info
FROM hospitalario.SNH_JSON_DATA a
WHERE ID = 49     ;   
        


DECLARE
vIdMstNotas     NUMBER;
vId             NUMBER;
vIdNotas        NUMBER;
vDescripcion    varchar2(500);
vComentario     varchar2(500);
vIdTipoNota     number;
vRegDetNotas    HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.refDetNotas;
vVarRegDetNotas HOSPITALARIO.PKG_SNH_INGRESO_EGRESO_1.detNotas;

CURSOR CDATOS IS
WITH jdata AS (
SELECT json_serialize(a.info PRETTY) info
FROM hospitalario.SNH_JSON_DATA a
--WHERE ID = 81
)
SELECT t.*
FROM jdata, json_table (
    INFO, '$'
    COLUMNS (
      idMstNotas number path '$.id',
      NESTED  PATH '$.detalleNotas[*]' 
      COLUMNS (
        idDetNota       number   PATH '$.id',
        descripcionNota varchar2 PATH '$.descripcionNota',
        comentarios     varchar2 PATH '$.comentario',
        NESTED  PATH '$.tipoDetNota[*]' 
                                  COLUMNS (
                                           idTipoDetNota number PATH '$.id'
                                           )        
      )
    )
  ) t;

BEGIN
                 OPEN CDATOS;
                -- LOOP
                 FETCH CDATOS
                  INTO vIdMstNotas,
                       vId,          
                       vDescripcion,
                       vComentario,
                       vIdNotas; 
                       
                 -- EXIT WHEN CDATOS%NOTFOUND; 
                 dbms_output.put_line ('contador: '||CDATOS%ROWCOUNT);                       
                       dbms_output.put_line ('prueba vVarRegDetNotas.id: '||vId);
                       dbms_output.put_line ('prueba vVarRegDetNotas.descripcionNota: '||vDescripcion);
                       dbms_output.put_line ('prueba vVarRegDetNotas.comentario: '||vComentario);
                       dbms_output.put_line ('prueba vVarRegDetNotas.tipNotaDetId: '||vIdNotas); 
                 --END LOOP;    
                 CLOSE CDATOS;
  
END;



select A.INFO.detalleNotas
from HOSPITALARIO.SNH_JSON_DATA A




            SELECT JSON_SERIALIZE (
                                  JSON_OBJECT (
                                                KEY 'Notas' VALUE (
                                                                    SELECT  JSON_SERIALIZE (JSON_ARRAYAGG 
                                                                                                        (JSON_OBJECT (
                                                                                                                     KEY 'id' VALUE A.DET_NOTA_ID,
                                                                                                                     KEY 'admisionServicio' VALUE (
                                                                                                                                                   JSON_OBJECT ( 
                                                                                                                                                               KEY 'id' VALUE A.ADMISION_SERVICIO_ID
                                                                                                                                                               )
                                                                                                                                                   ),
                                                                                                                     KEY 'fecha' VALUE A.FECHA_NOTA,
                                                                                                                     KEY 'hora' VALUE A.HORA_NOTA,
                                                                                                                     KEY 'personalSalud' VALUE (     
                                                                                                                                              JSON_OBJECT ( 
                                                                                                                                                            KEY 'id' VALUE A.MPERS_SALUD_ID
                                                                                                                                                           )
                                                                                                                                                ),
                                                                                                                     KEY 'tipoNota' VALUE (
                                                                                                                                           JSON_OBJECT ( KEY 'id' VALUE TIPNOTCAT.CATALOGO_ID,
                                                                                                                                                         KEY 'codigo' VALUE TIPNOTCAT.CODIGO,
                                                                                                                                                         KEY 'valor' VALUE TIPNOTCAT.VALOR,
                                                                                                                                                         KEY 'descripcion' VALUE TIPNOTCAT.DESCRIPCION
                                                                                                                                                        )
                                                                                                                                          ),
                                                                                                                     ---------
                                                                                                                     KEY 'detalleNotas' VALUE (
                                                                                                                                             SELECT JSON_ARRAYAGG (
                                                                                                                                                                    JSON_OBJECT (
                                                                                                                                                                                 KEY 'id' VALUE DETNOTAS.PERSALUD_EVO_NOTA_ID,
                                                                                                                                                                                 KEY 'tipoDetNota' VALUE(
                                                                                                                                                                                                         JSON_OBJECT ( KEY 'id' VALUE CATTIPDETNOTA.CATALOGO_ID,
                                                                                                                                                                                                                       KEY 'codigo' VALUE CATTIPDETNOTA.CODIGO,
                                                                                                                                                                                                                       KEY 'valor' VALUE CATTIPDETNOTA.VALOR,
                                                                                                                                                                                                                       KEY 'descripcion' VALUE CATTIPDETNOTA.DESCRIPCION
                                                                                                                                                                                                                      )
                                                                                                                                                                                                            ),
                                                                                                                                                                                  KEY 'comentario' VALUE DETNOTAS.COMENTARIOS
                                                                                                                                                                                )
                                                                                                                                                                                
                                                                                                                                                                    )
                                                                                                                                               FROM HOSPITALARIO.SNH_DET_NOTAS DETNOTAS
                                                                                                                                               LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATTIPDETNOTA
                                                                                                                                                 ON CATTIPDETNOTA.CATALOGO_ID = DETNOTAS.TIPO_DET_NOTA_ID
                                                                                                                                               WHERE DETNOTAS.DET_NOTA_ID = A.DET_NOTA_ID  
                                                                                                                                                ),  
                                                                                                                     ---------                     
                                                                                                                     KEY 'estadoRegId' VALUE A.ESTADO_REGISTRO_ID,
                                                                                                                     KEY 'estadoRegistro' VALUE (
                                                                                                                                                 JSON_OBJECT ( KEY 'id' VALUE ESTREGCAT.CATALOGO_ID,
                                                                                                                                                               KEY 'codigo' VALUE ESTREGCAT.CODIGO,
                                                                                                                                                               KEY 'valor' VALUE ESTREGCAT.VALOR,
                                                                                                                                                               KEY 'descripcion' VALUE ESTREGCAT.DESCRIPCION
                                                                                                                                                              )
                                                                                                                                                 ),                                                       
                                                                                                                     KEY 'usrRegistro' VALUE A.USUARIO_REGISTRO,
                                                                                                                     KEY 'fechaRegistro' VALUE A.FECHA_REGISTRO,
                                                                                                                     KEY 'usrModificacion' VALUE A.USUARIO_MODIFICACION,
                                                                                                                     KEY 'fechaModificacion' VALUE A.FECHA_MODIFICACION,
                                                                                                                     KEY 'usrPasiva' VALUE A.USUARIO_PASIVA,
                                                                                                                     KEY 'fechaPasiva' VALUE A.FECHA_PASIVA,
                                                                                                                     KEY 'usrElimina' VALUE A.USUARIO_ELIMINA,
                                                                                                                     KEY 'fechaElimina' VALUE A.FECHA_ELIMINA
                                                                                                                                            
                                                                                                                      ) RETURNING  CLOB
                                                                                                         )RETURNING  CLOB NULL ON EMPTY
                                                                                            ) JSONDATA
                                                                    FROM HOSPITALARIO.SNH_MST_NOTAS A
                                                                    JOIN HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP TMP
                                                                     ON TMP.ID = A.DET_NOTA_ID
                                                                    JOIN CATALOGOS.SBC_CAT_CATALOGOS TIPNOTCAT
                                                                      ON TIPNOTCAT.CATALOGO_ID = A.TIPO_NOTA_ID
                                                                    JOIN CATALOGOS.SBC_CAT_CATALOGOS ESTREGCAT
                                                                      ON ESTREGCAT.CATALOGO_ID = A.ESTADO_REGISTRO_ID
                                                                --   WHERE ESTADO_REGISTRO_ID != :vGLOBAL_ESTADO_ELIMINADO 
                                         )
                    )
            PRETTY) AS notas
            FROM DUAL;




insert into HOSPITALARIO.SNH_JSON_DATA (info)
          values(
'
    {
      "id" : null,
      "admisionServicio" :
      {
        "id" : 605
      },
      "fecha" : "2022-02-28",
      "hora" : "15:40",
      "personalSalud" :
      {
        "id" : 1321
      },
      "tipoNota" :
      {
        "id" : 8184,
        "codigo" : "TPINSTNTENF",
        "valor" : "NOTA DE ENFERMERIA",
        "descripcion" : "INSTRUMENTO DE NOTAS DE ENFEMERIA"
      },
      "detalleNotas" :
      [
        {
          "id" : null,
          "tipoDetNota" :
          {
            "id" : 8184,
            "codigo" : "TPINSTNTENF",
            "valor" : "NOTA DE ENFERMERIA",
            "descripcion" : "INSTRUMENTO DE NOTAS DE ENFEMERIA"
          },
          "comentario" : "PRUEBA"
        },
        {
          "id" : null,
          "tipoDetNota" :
          {
            "id" : 8184,
            "codigo" : "TPINSTNTENF",
            "valor" : "NOTA DE ENFERMERIA",
            "descripcion" : "INSTRUMENTO DE NOTAS DE ENFEMERIA"
          },
          "comentario" : "PRUEBA 2"
        }
      ],
      "estadoRegId" : 6869,
      "estadoRegistro" :
      {
        "id" : 6869,
        "codigo" : "ACTREG",
        "valor" : "Activo",
        "descripcion" : "Registro Activo"
      },
      "usrRegistro" : "fsequeira",
      "fechaRegistro" : "2022-02-21T13:36:46",
      "usrModificacion" : null,
      "fechaModificacion" : null,
      "usrPasiva" : null,
      "fechaPasiva" : null,
      "usrElimina" : null,
      "fechaElimina" : null
    }
');
    
    
insert into HOSPITALARIO.SNH_JSON_DATA (info)
          values(
'{
      "id" : null,
      "hora": "15:40",
      "fecha": "2022-02-28",
      "tipoNota": 12,
      "personalSalud" : {
                         "id": 1321,
                         "codigo": "5124",
                         "registroSanitario":null,
                         "persona":null  
                        },
      "admisionServicio" : {
                            "id": 12121,
                            "admision": null
                           },                    
      "detalleNotas" : 
      [
            {
             "id" : null,
             "nota" :{
                      "id" : null
                     },
             "descripcionNota" :"prueba1",        
             "comentarios" : "prueba"
            },
            {
             "id" : null,
             "nota" :{
                      "id" : null
                     },
             "descripcionNota" :"prueba1",        
             "comentarios" : "prueba"
            }
       ]                  
  }')
  
  
  
  
  
  
  
  
  
  
  
  
{"id" : null,"hora": "15:40","fecha": "2022-02-28","tipoNota": 8184,"personalSalud" : {"id": 1321,"codigo": "5124","registroSanitario":null,"persona":null},"admisionServicio" : {"id": 2938,"admision": null},"detalleNotas" : [{"id" : null,"nota" :{"id" : null},"descripcionNota" :"prueba","comentarios" : "prueba"},{"id" : null,"nota" :{"id" : null},"descripcionNota" :"prueba","comentarios" : "prueba"},]}  