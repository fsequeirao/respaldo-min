SELECT JSON_SERIALIZE (
                      JSON_OBJECT (
                                    KEY 'Notas' VALUE (
                                                    SELECT JSON_ARRAYAGG (
                                                    JSON_OBJECT (
                                                                   KEY 'detNotaId' VALUE A.DET_NOTA_ID,
                                                                   KEY 'admisionServicioId' VALUE A.ADMISION_SERVICIO_ID,
                                                                   KEY 'fechaNota' VALUE A.FECHA_NOTA,
                                                                   KEY 'horaNota' VALUE A.HORA_NOTA,
                                                                   KEY 'mperSaludId' VALUE A.MPERS_SALUD_ID,
                                                                   KEY 'tipoNotaId' VALUE A.TIPO_NOTA_ID,
                                                                   KEY 'tipoNota' VALUE (
                                                                                           JSON_OBJECT ( KEY 'tipNotId' VALUE TIPNOTCAT.CATALOGO_ID,
                                                                                                         KEY 'tipNotCodigo' VALUE TIPNOTCAT.CODIGO,
                                                                                                         KEY 'tipNotValor' VALUE TIPNOTCAT.VALOR,
                                                                                                         KEY 'tipoNotDesc' VALUE TIPNOTCAT.DESCRIPCION
                                                                                                       )
                                                                                        ),
                                                                   KEY 'estadoRegId' VALUE A.ESTADO_REGISTRO_ID,
                                                                   KEY 'estadoRegistro' VALUE (
                                                                                           JSON_OBJECT ( KEY 'estRegId' VALUE ESTREGCAT.CATALOGO_ID,
                                                                                                         KEY 'estRegCodigo' VALUE ESTREGCAT.CODIGO,
                                                                                                         KEY 'estRegValor' VALUE ESTREGCAT.VALOR,
                                                                                                         KEY 'estRegDesc' VALUE ESTREGCAT.DESCRIPCION
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
                                                                 )--RETURNING  CLOB
                                                         ) --JSONDATA
                            FROM HOSPITALARIO.SNH_MST_NOTAS A
                            JOIN CATALOGOS.SBC_CAT_CATALOGOS TIPNOTCAT
                              ON TIPNOTCAT.CATALOGO_ID = A.TIPO_NOTA_ID
                            JOIN CATALOGOS.SBC_CAT_CATALOGOS ESTREGCAT
                              ON ESTREGCAT.CATALOGO_ID = A.ESTADO_REGISTRO_ID 
--                           WHERE A.DET_NOTA_ID = :pDetNotaId AND
--                                 ESTADO_REGISTRO_ID != :vGLOBAL_ESTADO_ELIMINADO
                             )
        )--RETURNING  CLOB NULL ON EMPTY   
PRETTY) AS notas
FROM DUAL;






SELECT  JSON_SERIALIZE (JSON_ARRAYAGG (JSON_OBJECT (                       
                       KEY 'ADMISION_ID' VALUE  persona_id
                        )RETURNING  CLOB)RETURNING  CLOB NULL ON EMPTY ) JSONDATA
  from catalogos.sbc_mst_personas
  where expediente_id = 22022
  
  select *
  from catalogos.sbc_mst_Personas
  where identificacion = '5610709810004U'


SELECT JSON_SERIALIZE (
                      JSON_OBJECT (
                                    KEY 'Notas' VALUE (
                                                        SELECT  JSON_SERIALIZE (JSON_ARRAYAGG 
                                                                                            (JSON_OBJECT (
                                                                                                         KEY 'detNotaId' VALUE A.DET_NOTA_ID,
                                                                                                         KEY 'admisionServicioId' VALUE A.ADMISION_SERVICIO_ID,
                                                                                                         KEY 'fechaNota' VALUE A.FECHA_NOTA,
                                                                                                         KEY 'horaNota' VALUE A.HORA_NOTA,
                                                                                                         KEY 'mperSaludId' VALUE A.MPERS_SALUD_ID,
                                                                                                         KEY 'tipoNotaId' VALUE A.TIPO_NOTA_ID,
                                                                                                         KEY 'tipoNota' VALUE (
                                                                                                                               JSON_OBJECT ( KEY 'tipNotId' VALUE TIPNOTCAT.CATALOGO_ID,
                                                                                                                                             KEY 'tipNotCodigo' VALUE TIPNOTCAT.CODIGO,
                                                                                                                                             KEY 'tipNotValor' VALUE TIPNOTCAT.VALOR,
                                                                                                                                             KEY 'tipoNotDesc' VALUE TIPNOTCAT.DESCRIPCION
                                                                                                                                            )
                                                                                                                              ),
                                                                                                         KEY 'estadoRegId' VALUE A.ESTADO_REGISTRO_ID,
                                                                                                         KEY 'estadoRegistro' VALUE (
                                                                                                                                     JSON_OBJECT ( KEY 'estRegId' VALUE ESTREGCAT.CATALOGO_ID,
                                                                                                                                                   KEY 'estRegCodigo' VALUE ESTREGCAT.CODIGO,
                                                                                                                                                   KEY 'estRegValor' VALUE ESTREGCAT.VALOR,
                                                                                                                                                   KEY 'estRegDesc' VALUE ESTREGCAT.DESCRIPCION
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
                                                        JOIN CATALOGOS.SBC_CAT_CATALOGOS TIPNOTCAT
                                                          ON TIPNOTCAT.CATALOGO_ID = A.TIPO_NOTA_ID
                                                        JOIN CATALOGOS.SBC_CAT_CATALOGOS ESTREGCAT
                                                          ON ESTREGCAT.CATALOGO_ID = A.ESTADO_REGISTRO_ID 
                             )
        )
PRETTY) AS notas
FROM DUAL;



SELECT *
FROM HOSPITALARIO.SNH_MST_NOTAS A


SELECT  JSON_SERIALIZE (JSON_ARRAYAGG (JSON_OBJECT (  
                                    KEY 'Notas' VALUE (
                                                    SELECT JSON_ARRAYAGG (
                                                    JSON_OBJECT (
                                                                   KEY 'detNotaId' VALUE A.DET_NOTA_ID,
                                                                   KEY 'admisionServicioId' VALUE A.ADMISION_SERVICIO_ID,
                                                                   KEY 'fechaNota' VALUE A.FECHA_NOTA,
                                                                   KEY 'horaNota' VALUE A.HORA_NOTA,
                                                                   KEY 'mperSaludId' VALUE A.MPERS_SALUD_ID,
                                                                   KEY 'tipoNotaId' VALUE A.TIPO_NOTA_ID,
                                                                   KEY 'tipoNota' VALUE (
                                                                                           JSON_OBJECT ( KEY 'tipNotId' VALUE TIPNOTCAT.CATALOGO_ID,
                                                                                                         KEY 'tipNotCodigo' VALUE TIPNOTCAT.CODIGO,
                                                                                                         KEY 'tipNotValor' VALUE TIPNOTCAT.VALOR,
                                                                                                         KEY 'tipoNotDesc' VALUE TIPNOTCAT.DESCRIPCION
                                                                                                       )
                                                                                        ),
                                                                   KEY 'estadoRegId' VALUE A.ESTADO_REGISTRO_ID,
                                                                   KEY 'estadoRegistro' VALUE (
                                                                                           JSON_OBJECT ( KEY 'estRegId' VALUE ESTREGCAT.CATALOGO_ID,
                                                                                                         KEY 'estRegCodigo' VALUE ESTREGCAT.CODIGO,
                                                                                                         KEY 'estRegValor' VALUE ESTREGCAT.VALOR,
                                                                                                         KEY 'estRegDesc' VALUE ESTREGCAT.DESCRIPCION
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
                                                                 )--RETURNING  CLOB
                                                         ) --JSONDATA
                                                        )
                                                         )RETURNING  CLOB)RETURNING  CLOB NULL ON EMPTY) JSONDATA
                            FROM HOSPITALARIO.SNH_MST_NOTAS A
                            JOIN CATALOGOS.SBC_CAT_CATALOGOS TIPNOTCAT
                              ON TIPNOTCAT.CATALOGO_ID = A.TIPO_NOTA_ID
                            JOIN CATALOGOS.SBC_CAT_CATALOGOS ESTREGCAT
                              ON ESTREGCAT.CATALOGO_ID = A.ESTADO_REGISTRO_ID 
--                           WHERE A.DET_NOTA_ID = :pDetNotaId AND
--                                 ESTADO_REGISTRO_ID != :vGLOBAL_ESTADO_ELIMINADO
                             )
        )RETURNING  CLOB)RETURNING  CLOB NULL ON EMPTY) 
--PRETTY) AS notas
FROM DUAL;








SELECT *
FROM CATALOGOS.SBC_MST_PERSONAS













SELECT JSON_SERIALIZE (
                       JSON_OBJECT (
                                     KEY 'personas' VALUE (
                                        SELECT JSON_ARRAYAGG (
                                                              JSON_OBJECT (
                                                                           KEY 'Id' VALUE A.PERSONA_ID,
                                                                           KEY 'primerNombre' VALUE A.PRIMER_NOMBRE,
                                                                           KEY 'primerApellido' VALUE A.PRIMER_APELLIDO,
                                                                           KEY 'expediente' VALUE (
                                                                                                   JSON_OBJECT (
                                                                                                                KEY 'Id' VALUE EXP.EXPEDIENTE_ID,
                                                                                                                KEY 'codExpedienteElectronico' VALUE EXP.CODIGO_EXPEDIENTE_ELECTRONICO
                                                                                                               )
                                                                                                     ),     
                                                                            KEY 'direccion' VALUE (
                                                                                                   SELECT JSON_ARRAYAGG (
                                                                                                                        JSON_OBJECT (
                                                                                                                                     KEY 'idResidencia' VALUE DIR.DET_PRS_RESIDENCIA_ID,
                                                                                                                                     KEY 'direccion' VALUE DIR.DIRECCION
                                                                                                                                    )
                                                                                                                                    
                                                                                                                        )
                                                                                                    FROM CATALOGOS.SBC_DET_PRS_RESIDENCIA DIR
                                                                                                   WHERE DIR.EXPEDIENTE_ID = A.EXPEDIENTE_ID
                                                                                                    ),                                                                                                                                                                           
                                                                           KEY 'identificacion' VALUE A.IDENTIFICACION,
                                                                           KEY 'tipoIdentificacion' VALUE (
                                                                                             JSON_OBJECT(
                                                                                                          KEY 'id' VALUE C.CATALOGO_ID,
                                                                                                          KEY 'codigo' VALUE C.CODIGO,
                                                                                                          KEY 'valor' VALUE C.VALOR,
                                                                                                          KEY 'descripcion' VALUE C.DESCRIPCION
                                                                                                         )

                                                                                  ),
                                                                           KEY 'estado' VALUE (
                                                                                               JSON_OBJECT(
                                                                                                           KEY 'id' VALUE D.CATALOGO_ID,
                                                                                                           KEY 'codigo' VALUE D.CODIGO,
                                                                                                           KEY 'valor' VALUE D.VALOR,
                                                                                                           KEY 'descripcion' VALUE D.DESCRIPCION
                                                                                                           )
                                                                                                )                                                                                                                                                             
                                                                             )
                                                                )
                                        FROM CATALOGOS.SBC_MST_PERSONAS A
                                        JOIN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE EXP
                                          ON EXP.EXPEDIENTE_ID = A.EXPEDIENTE_ID
                                        JOIN CATALOGOS.SBC_CAT_CATALOGOS C
                                          ON C.CATALOGO_ID = A.TIPO_IDENTIFICACION_ID
                                        JOIN CATALOGOS.SBC_CAT_CATALOGOS D
                                          ON D.CATALOGO_ID = A.ESTADO_REGISTRO_ID
                                       WHERE A.EXPEDIENTE_ID = 2418361
                                      )
                                    )
               PRETTY) AS personas
FROM DUAL;

