
SELECT *
FROM HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP;

WITH data AS (
  SELECT 1 AS id
  FROM   dual
  CONNECT BY level < 10000
)
SELECT rownum, TO_CHAR(rownum)
FROM   data a, data b
WHERE  rownum <= 1000000;




declare
 SUBTYPE MAXVARCHAR2 IS VARCHAR2(32000);
vCamaId          HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE;
vNombre          HOSPITALARIO.SNH_CAT_CAMAS.NOMBRE%TYPE;
vCodAdmin        HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE := 1354;
vNoSerie         HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE;
vEstadoCama      HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_CAMA%TYPE;
vUsuario         SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE;  
vAccionEstado    VARCHAR2 (1000);
vCamaAsignada    NUMBER;                                  
vTipoAccion      VARCHAR2 (1000) := 'C';                                  
vPgn             NUMBER := 1;
vPgnAct          NUMBER := 1;  
vPgnTmn          NUMBER := 50;
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
  HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_CAT_CAMAS (pCamaId          => vCamaId,         
                                                           pNombre          => vNombre,         
                                                           pCodAdmin        => vCodAdmin,       
                                                           pNoSerie         => vNoSerie,        
                                                           pEstadoCama      => vEstadoCama,     
                                                           pUsuario         => vUsuario,        
                                                           pAccionEstado    => vAccionEstado,   
                                                           pCamaAsignada    => vCamaAsignada,   
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
                          LOOP
                               FETCH vRegistro
                                INTO vCamaId,       
                                     vNombre, 
                                     vCodAdmin; 
                                     
                          EXIT WHEN vRegistro%NOTFOUND;      
                               
                               DBMS_OUTPUT.PUT_LINE('vCamaId: '|| vCamaId);       
                               DBMS_OUTPUT.PUT_LINE('vNombre: '||vNombre);
                               DBMS_OUTPUT.PUT_LINE('vCodAdmin: '||vCodAdmin);
                          END LOOP;
                           CLOSE vRegistro;  
                   END CASE;
end;






vCamaId: 128
vCamaId: 129
vCamaId: 130
vCamaId: 131
vCamaId: 132
vCamaId: 133
vCamaId: 134
vCamaId: 135
vCamaId: 136
vCamaId: 137
vCamaId: 138
vCamaId: 140
vCamaId: 141
vCamaId: 142
vCamaId: 143
vCamaId: 144
vCamaId: 145
vCamaId: 146
vCamaId: 148
vCamaId: 149
vCamaId: 152
vCamaId: 153
vCamaId: 154
vCamaId: 157
vCamaId: 158
vCamaId: 159







CREATE INDEX IDX_SNH_PAGINADA_TMP_LINE ON HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
(LINEA);


INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP VALUES (1,5)

SELECT *
FROM HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP

INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP (LINEA, ID)
                         SELECT *
                           FROM (
                                SELECT *
                                 FROM (
                                    SELECT ROW_NUMBER () OVER (ORDER BY CAMA_ID ASC)
                                           LINE_NUMBER,
                                           CAMA_ID
                               FROM
                                  (
                                    SELECT CAMA_ID
                                      FROM HOSPITALARIO.SNH_CAT_CAMAS A
                                     WHERE A.ESTADO_REGISTRO_ID != 6871   --:vGLOBAL_ESTADO_ELIMINADO                                  
                                  )
                                     )
                        WHERE LINE_NUMBER < ((1 * 5) + 1)   ---((:pPgnAct * :pPgnTmn) + 1)
                       ORDER BY LINE_NUMBER)
                    WHERE LINE_NUMBER >= ( ( (1 - 1) * 5) + 1);     --( ( ( :pPgnAct - 1) * :pPgnTmn) + 1); 
                    
                    
                    
                    
                    
                    
            SELECT *
               FROM (
                    SELECT *
                     FROM HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP A,(
                          SELECT ROW_NUMBER () OVER (ORDER BY CAMA_ID ASC)
                                 LINE_NUMBER,   
                                 CAMA_ID,                               
                                 CAMA_NOMBRE,                                
                                 CAMA_COD_ADMINISTRATIVO,                  
                                 NO_SERIE,                          
                                 ESTADO_CAMA,               
                                 ESTADO_REGISTRO_I,                  
                                 CATESTREG_CODIGO,               
                                 CATESTREG_VALOR,               
                                 CATESTREG_DESCRIPCION,               
                                 USUARIO_REGISTRO,                   
                                 FECHA_REGISTRO,                      
                                 USUARIO_MODIFICACION,                
                                 FECHA_MODIFICACION,                  
                                 USUARIO_PASIVA,                      
                                 FECHA_PASIVA,                        
                                 USUARIO_ELIMINA,                     
                                 FECHA_ELIMINA,               
                                 INDISPONIBILIDAD_CAMA_ID,               
                                 IND_CAUSA_ISA,               
                                 CATCAUSAIND_CODIGO,               
                                 CATCAUSAIND_VALOR,               
                                 CATCAUSAIND_DESCRIPCION,               
                                 IND_DESCRIPCION_SALIDA,               
                                 IND_DESCRIPCION_RETORNO,               
                                 IND_FECHA_SALIDA,               
                                 IND_HORA_SALIDA,               
                                 IND_FECHA_RETORNO,               
                                 IND_HORA_RETORNO,               
                                 IND_ESTADO_REGISTRO_ID,               
                                 CATESTREGIND_CODIGO,               
                                 CATESTREGIND_VALOR,               
                                 CATESTREGIND_DESCRIPCION,               
                                 CFG_USLD_SERVICIO_CAMA_ID,               
                                 CFG_USLDSERV_ID,               
                                 CFG_USLDSERV_COD_ASISTENCIAL,               
                                 CFG_USLDSERV_SALDA_ID,               
                                 CFG_USLDSERV_HABITACION_ID,               
                                 CFG_USLDSERV_DISPONIBLE,               
                                 CFG_USLDSERV_ESTADO_CAMA_ID,                            
                                 CATESTCAMA_CAMA,                               
                                 CATESTCAMA_VALOR,                               
                                 CATESTCAMA_DESCRIPCION,                               
                                 CFG_USLDSERV_ESTADO_REGISTRO,                               
                                 CATESTREGCFG_CODIGO,                               
                                 CATESTREGCFG_VALOR,                               
                                 CATESTREGCFG_DESCRIPCION                               
                    FROM
                    (                                
                    SELECT CAT.CAMA_ID                             CAMA_ID,
                           CAT.NOMBRE                              CAMA_NOMBRE, 
                           CAT.CODIGO_ADMINISTRATIVO               CAMA_COD_ADMINISTRATIVO,
                           CAT.NO_SERIE                            NO_SERIE,           
                           CAT.ESTADO_CAMA                         ESTADO_CAMA,
                --           CATESTADO.CODIGO                        CATESTADO_CODIGO,
                --           CATESTADO.VALOR                         CATESTADO_VALOR,
                --           CATESTADO.DESCRIPCION                   CATESTADO_DESCRIPCION,
                           CAT.ESTADO_REGISTRO_ID                  ESTADO_REGISTRO_I,   
                           CATESTREG.CODIGO                        CATESTREG_CODIGO,
                           CATESTREG.VALOR                         CATESTREG_VALOR,
                           CATESTREG.DESCRIPCION                   CATESTREG_DESCRIPCION,
                           CAT.USUARIO_REGISTRO                    USUARIO_REGISTRO,    
                           CAT.FECHA_REGISTRO                      FECHA_REGISTRO,       
                           CAT.USUARIO_MODIFICACION                USUARIO_MODIFICACION, 
                           CAT.FECHA_MODIFICACION                  FECHA_MODIFICACION,   
                           CAT.USUARIO_PASIVA                      USUARIO_PASIVA,       
                           CAT.FECHA_PASIVA                        FECHA_PASIVA,         
                           CAT.USUARIO_ELIMINA                     USUARIO_ELIMINA,      
                           CAT.FECHA_ELIMINA                       FECHA_ELIMINA,
                           IND.INDISPONIBILIDAD_CAMA_ID            INDISPONIBILIDAD_CAMA_ID,
                           IND.CAUSA_ID                            IND_CAUSA_ISA,
                           CATCAUSAIND.CODIGO                      CATCAUSAIND_CODIGO,
                           CATCAUSAIND.VALOR                       CATCAUSAIND_VALOR,
                           CATCAUSAIND.DESCRIPCION                 CATCAUSAIND_DESCRIPCION,
                           IND.DESCRIPCION_SALIDA                  IND_DESCRIPCION_SALIDA,
                           IND.DESCRIPCION_RETORNO                 IND_DESCRIPCION_RETORNO,
                           IND.FECHA_SALIDA                        IND_FECHA_SALIDA,
                           IND.HORA_SALIDA                         IND_HORA_SALIDA,
                           IND.FECHA_RETORNO                       IND_FECHA_RETORNO,
                           IND.HORA_RETORNO                        IND_HORA_RETORNO,
                           IND.ESTADO_REGISTRO_ID                  IND_ESTADO_REGISTRO_ID,
                           CATESTREGIND.CODIGO                     CATESTREGIND_CODIGO,
                           CATESTREGIND.VALOR                      CATESTREGIND_VALOR,
                           CATESTREGIND.DESCRIPCION                CATESTREGIND_DESCRIPCION,
                           CFGUSERVAMAS.CFG_USLD_SERVICIO_CAMA_ID  CFG_USLD_SERVICIO_CAMA_ID,
                           CFGUSERVAMAS.UND_SALUD_SERVICIO_ID      CFG_USLDSERV_ID,
                           CFGUSERVAMAS.CODIGO_ASISTENCIAL         CFG_USLDSERV_COD_ASISTENCIAL,
                           CFGUSERVAMAS.SALA_ID                    CFG_USLDSERV_SALDA_ID,
                           CFGUSERVAMAS.HABITACION_ID              CFG_USLDSERV_HABITACION_ID,
                           CFGUSERVAMAS.DISPONIBLE                 CFG_USLDSERV_DISPONIBLE,
                           CFGUSERVAMAS.ESTADO_CAMA_ID             CFG_USLDSERV_ESTADO_CAMA_ID,
                           CATESTCAMA.CODIGO                       CATESTCAMA_CAMA,
                           CATESTCAMA.VALOR                        CATESTCAMA_VALOR,
                           CATESTCAMA.DESCRIPCION                  CATESTCAMA_DESCRIPCION,
                           CFGUSERVAMAS.ESTADO_REGISTRO_ID         CFG_USLDSERV_ESTADO_REGISTRO,
                           CATESTREGCFG.CODIGO                     CATESTREGCFG_CODIGO,
                           CATESTREGCFG.VALOR                      CATESTREGCFG_VALOR,
                           CATESTREGCFG.DESCRIPCION                CATESTREGCFG_DESCRIPCION
                    FROM HOSPITALARIO.SNH_CAT_CAMAS CAT
                --    JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTADO
                --      ON CATESTADO.CATALOGO_ID = CAT.ESTADO_CAMA
                    JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREG
                      ON CATESTREG.CATALOGO_ID = CAT.ESTADO_REGISTRO_ID
                    LEFT JOIN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS IND 
                      ON IND.CAMA_ID = CAT.CAMA_ID
                    LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATCAUSAIND
                     ON CATCAUSAIND.CATALOGO_ID = IND.CAUSA_ID
                    LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGIND
                     ON CATESTREGIND.CATALOGO_ID = IND.ESTADO_REGISTRO_ID
                    LEFT JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGUSERVAMAS
                     ON CFGUSERVAMAS.CAMA_ID = CAT.CAMA_ID
                    LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTCAMA
                     ON CATESTCAMA.CATALOGO_ID = CFGUSERVAMAS.ESTADO_CAMA_ID 
                    LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGCFG
                     ON CATESTREGCFG.CATALOGO_ID = CFGUSERVAMAS.ESTADO_REGISTRO_ID 
                   WHERE CAT.ESTADO_REGISTRO_ID != :vGLOBAL_ESTADO_ELIMINADO
                                      )
                                         )B
                WHERE A.ID = B.CAMA_ID
               ORDER BY LINE_NUMBER);   