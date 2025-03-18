CREATE OR REPLACE PACKAGE BODY HOSPITALARIO.PKG_SNH_INGRESO_EGRESO
AS
 FUNCTION FN_EXISTE_ADMISION_ID_PREG (pPregIngresoId IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE) RETURN BOOLEAN AS
 vContador   SIMPLE_INTEGER := 0;
 vExiste   BOOLEAN := FALSE;
 BEGIN
  SELECT COUNT (1)
    INTO vContador
    FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
   WHERE PREG_INGRESO_ID = pPregIngresoId AND
         ADMISION_ID IS NOT NULL;
   CASE
   WHEN vContador > 0 THEN
        vExiste := TRUE;
   ELSE NULL;
   END CASE;
   RETURN vExiste;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vExiste;  
 END FN_EXISTE_ADMISION_ID_PREG;

 FUNCTION FN_OBT_ADMISION_ID_PREG (pPregIngresoId IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE) RETURN NUMBER AS
 vAdmisionId HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISION_ID%TYPE;
 BEGIN
   SELECT ADMISION_ID
     INTO vAdmisionId
     FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
    WHERE PREG_INGRESO_ID = pPregIngresoId;
   
    RETURN vAdmisionId;
 EXCEPTION
 WHEN OTHERS THEN 
      RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener admision Id desde pre ingreso. [pPregIngresoId: '||pPregIngresoId||'] - '||SQLERRM);
      RETURN vAdmisionId;
 END FN_OBT_ADMISION_ID_PREG;
 
 FUNCTION FN_EXISTE_ESPECIALIDAD_ID_PREG (pPregIngresoId IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE) RETURN BOOLEAN AS
 vContador   SIMPLE_INTEGER := 0;
 vExiste   BOOLEAN := FALSE;
 BEGIN
  SELECT COUNT (1)
    INTO vContador
    FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
   WHERE PREG_INGRESO_ID = pPregIngresoId AND
         ESPECIALIDAD_DESTINO_ID IS NOT NULL;
   CASE
   WHEN vContador > 0 THEN
        vExiste := TRUE;
   ELSE NULL;
   END CASE;
   RETURN vExiste;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vExiste;  
 END FN_EXISTE_ESPECIALIDAD_ID_PREG;

 FUNCTION FN_OBT_ESPECIALIDAD_ID_PREG (pPregIngresoId IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE) RETURN NUMBER AS
 vEspecialidadDestId HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESPECIALIDAD_DESTINO_ID%TYPE;
 BEGIN
   SELECT ESPECIALIDAD_DESTINO_ID
     INTO vEspecialidadDestId
     FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
    WHERE PREG_INGRESO_ID = pPregIngresoId;
   
    RETURN vEspecialidadDestId;
 EXCEPTION
 WHEN OTHERS THEN 
      RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener admision Id desde pre ingreso. [pPregIngresoId: '||pPregIngresoId||'] - '||SQLERRM);
      RETURN vEspecialidadDestId;
 END FN_OBT_ESPECIALIDAD_ID_PREG; 
 
 FUNCTION FN_OBT_DATOS_PAGINACION (pDatosPaginacion IN HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos ) RETURN var_refcursor AS   --(pQuery IN VARCHAR2) RETURN var_refcursor AS
 vRegistro var_refcursor;
 vQuery MAXVARCHAR2;
 BEGIN
      vQuery  := 'SELECT '|| pDatosPaginacion(0) ||
                 ' REGISTROS,' || pDatosPaginacion(1) ||
                 ' PAGINAS,' || pDatosPaginacion(2) ||
                 ' PAGINAS_PENDIENTES,'|| pDatosPaginacion(3) ||
                 ' EXISTE_PRIMERA_PAGINA,'|| pDatosPaginacion(4) ||
                 ' EXISTE_PAGINA_ANTERIOR,'|| pDatosPaginacion(5) ||
                 ' EXISTE_PAGINA_SIGUIENTE,'||pDatosPaginacion(6) || 
                 ' EXISTE_ULTIMA_PAGINA FROM DUAL';
     OPEN vRegistro FOR 
          vQuery;
     RETURN vRegistro;
 END FN_OBT_DATOS_PAGINACION ;  

 PROCEDURE PR_I_TABLA_TEMPORAL_PREGING (pConsulta        IN HOSPITALARIO.OBJ_PRE_INGRESO,
                                        pPgnAct          IN NUMBER DEFAULT 1, 
                                        pPgnTmn          IN NUMBER DEFAULT 100,
                                        pTipoPaginacion  IN NUMBER,
                                        pResultado       OUT VARCHAR2,                       
                                        pMsgError        OUT VARCHAR2) IS
   vFirma VARCHAR2(100) := 'PKG_SIPAI_CONTROL_VACUNAS.PR_I_TABLA_TEMPORAL_PREGING => '; 
 BEGIN
      CASE pTipoPaginacion
--      WHEN 1 THEN
--           BEGIN
--             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
--                          SELECT *
--                            FROM (
--                                 SELECT *
--                                  FROM (
--                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
--                                            LINE_NUMBER,
--                                            PREG_INGRESO_ID
--                                FROM
--                                   (             
--                                    SELECT PREG_INGRESO_ID
--                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
--                                     WHERE PREG_INGRESO_ID = pConsulta.PregIngresoId AND
--                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
--                                   )
--                                                              )
--                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
--                        ORDER BY LINE_NUMBER)
--                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
--           END;
      WHEN 2 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                           EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 3 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;  
      WHEN 4 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;              
      WHEN 5 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND 
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;
      WHEN 6 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE IDENTIFICACION = pConsulta.Identificacion AND 
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;
      WHEN 7 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ADMISION_ID = pConsulta.AdmisionId AND 
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;           
      WHEN 8 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO

                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 9 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO

                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 10 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 11 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 12 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                       FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                      WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                                            UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                                            ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 13 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;      ---
      WHEN 14 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 15 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 16 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 17 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;    
      WHEN 18 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);

            END;  
      WHEN 19 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;                                                                       
      WHEN 20 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 21 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 22 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;   
      WHEN 23 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 24 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 25 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;                                                        
      WHEN 26 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 27 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 28 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE PREG_INGRESO_ID = pConsulta.PregIngresoId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);       
           END;
      WHEN 29 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                           EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 30 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;  
      WHEN 31 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;              
      WHEN 32 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND 
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;
      WHEN 33 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE IDENTIFICACION = pConsulta.Identificacion AND 
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;
      WHEN 34 THEN
           BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ADMISION_ID = pConsulta.AdmisionId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;           
      WHEN 35 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND    
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 36 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 37 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 38 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 39 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 40 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;      ---
      WHEN 41 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 42 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 43 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 44 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;    
      WHEN 45 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND
                                           UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 46 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND
                                           UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;                                                                       
      WHEN 47 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 48 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 49 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;   
      WHEN 50 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 51 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND 
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 52 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND   
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;                                                        
      WHEN 53 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
                                      FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
                                     WHERE UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND 
                                           FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 54 THEN
            BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY PREG_INGRESO_ID ASC)
                                            LINE_NUMBER,
                                            PREG_INGRESO_ID
                                FROM
                                   (             
                                    SELECT PREG_INGRESO_ID
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      ELSE NULL;
      END CASE;
 EXCEPTION
  WHEN OTHERS THEN
      pResultado := 'Error al procesar paginación';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;            
 END PR_I_TABLA_TEMPORAL_PREGING; 

 PROCEDURE PR_I_TABLA_TEMPORAL_ING_EGRE (pConsulta          IN HOSPITALARIO.OBJ_INGRESO_EGRESO,
                                         pMunicipioId       IN NUMBER,
                                         pEntAdminId        IN NUMBER,
                                         pPgnAct            IN NUMBER DEFAULT 1, 
                                         pPgnTmn            IN NUMBER DEFAULT 100,
                                         pTipoPaginacion    IN NUMBER,
                                         pResultado         OUT VARCHAR2,                       
                                         pMsgError          OUT VARCHAR2) IS
   vFirma VARCHAR2(100) := 'PKG_SIPAI_CONTROL_VACUNAS.PR_I_TABLA_TEMPORAL_ING_EGRE => '; 
 BEGIN
        CASE pTipoPaginacion
--        WHEN 1 THEN
--              BEGIN
--                INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
--                             SELECT *
--                               FROM (
--                                    SELECT *
--                                     FROM (
--                                        SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
--                                               LINE_NUMBER,
--                                               INGRESO_ID
--                                   FROM
--                                      (            
--                                       SELECT INGRESO_ID
--                                         FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
--                                        WHERE INGRESO_ID          = pConsulta.IngresoId AND
--                                              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
--                                      )
--                                                                 )
--                            WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
--                           ORDER BY LINE_NUMBER)
--                        WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);          
--              END;
        WHEN 2  THEN
             BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                                         WHERE A.PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                               B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO                                      
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);  
             END;  
      WHEN 3 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS    
                                         WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;  
      WHEN 4 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;              
      WHEN 5 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                           ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;
      WHEN 6 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.IDENTIFICACION_NUMERO = pConsulta.Identificacion AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;
      WHEN 7 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                           FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                           JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                             ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID 
                                          WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto AND
                                                A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                                A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;
      WHEN 8 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                           FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                                                A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                                A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END; 
      WHEN 9 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;      
      WHEN 10 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;       
      WHEN 11 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;   
      WHEN 12 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;         
      WHEN 13 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 14 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 15 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID AND
                                               CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto 
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId
                                         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 16 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                           FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                           JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                             ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                                PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                                          WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                                                A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 17 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;      
      WHEN 18 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;       
      WHEN 19 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;   
      WHEN 20 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;         
      WHEN 21 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 22 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 23 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                                         WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO = pConsulta.NombreCompleto AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN  24 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;    
      WHEN 25 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;       
      WHEN 26  THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 27 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 28 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 29 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 30 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;                                                                                    
      WHEN 31 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;            
      WHEN 32 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS 
                                         WHERE UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 33 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                                         WHERE ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 34 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                                         WHERE INGRESO_ID          = pConsulta.IngresoId AND
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);        
            END;
      WHEN 35  THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                                         WHERE A.PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                               B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;  
      WHEN 36 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS    
                                         WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;  
      WHEN 37 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;              
      WHEN 38 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                           ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;
      WHEN 39 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.IDENTIFICACION_NUMERO = pConsulta.Identificacion AND
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;
      WHEN 40 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID 
                                         WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;
      WHEN 41 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND    
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END; 
      WHEN 42 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;      
      WHEN 43 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND  
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;       
      WHEN 44 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;   
      WHEN 45 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;         
      WHEN 46 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;  
      WHEN 47 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                              A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END; 
      WHEN 48 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID AND
                                               CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto 
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId 
                                         WHERE FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;
      WHEN 49 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                                         WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END; 
      WHEN 50 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;      
      WHEN 51 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;       
      WHEN 52 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND   
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;   
      WHEN 53 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND  
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;         
      WHEN 54 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;  
      WHEN 55 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END; 
      WHEN 56 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                                         WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO = pConsulta.NombreCompleto AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;  
      WHEN  57 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND   
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;    
      WHEN 58 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND 
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;       
      WHEN 59 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND   
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
            END;  
      WHEN 60 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND  
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 61 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND  
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 62 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND  
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 63 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;                                                                                    
      WHEN 64 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;            
      WHEN 65 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS 
                                         WHERE UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND
                                               FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 66 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                                         WHERE FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 67 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                                         WHERE INGRESO_ID          = pConsulta.IngresoId AND
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);       
           END;
      WHEN 68 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                                         WHERE A.PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                               B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);  
            END;  
      WHEN 69 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS    
                                         WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;  
      WHEN 70 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;              
      WHEN 71 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                           ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
           END;
      WHEN 72 THEN
           BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                                         WHERE B.IDENTIFICACION_NUMERO = pConsulta.Identificacion AND
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
           END;
      WHEN 73 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID 
                                         WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 74 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND    
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 76 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;      
      WHEN 76 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND  
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;       
      WHEN 77 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;   
      WHEN 78 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;         
      WHEN 79 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 80 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND
                                               A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 81 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID AND
                                               CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto 
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId 
                                         WHERE FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 82 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                                         WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 83 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;      
      WHEN 84 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;       
      WHEN 85 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND   
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;   
      WHEN 86 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND  
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;         
      WHEN 87 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 88 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 89 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                                            ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                                         WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO = pConsulta.NombreCompleto AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 90 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND   
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;    
      WHEN 91 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND 
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;       
      WHEN 92  THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND   
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 93 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND  
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 94 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND  
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;  
      WHEN 95 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND  
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END; 
      WHEN 96 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                         WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;                                                                                    
      WHEN 97 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                                          JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                                            ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                                               PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                                         WHERE FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                                               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;            
      WHEN 98 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                                          FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS 
                                         WHERE UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND
                                               FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                                               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
      WHEN 99 THEN
            BEGIN
               INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP           
                              SELECT *
                                FROM (
                                     SELECT *
                                      FROM (
                                         SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                                LINE_NUMBER,
                                                INGRESO_ID
                                    FROM
                                       (            
                                        SELECT INGRESO_ID
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                      WHERE FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                          )
                                       )
                             WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                            ORDER BY LINE_NUMBER)
                         WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
            END;
--------------------        
--        WHEN 7 THEN
--             BEGIN
--             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
--                          SELECT *
--                            FROM (
--                                 SELECT *
--                                  FROM (
--                                     SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
--                                            LINE_NUMBER,
--                                            INGRESO_ID
--                                FROM
--                                   (             
--                                    SELECT INGRESO_ID
--                                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
--                                      JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL NOM
--                                        ON NOM.PER_NOMINAL_ID = A.PER_NOMINAL_ID AND
--                                          NOM.NOMBRE_COMPLETO = pNombreCompleto 
--                                     WHERE A.UNIDAD_SALUD_INGRESO = pUnidadSaludId AND   
--                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
--                                   )
--                                                              )
--                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
--                        ORDER BY LINE_NUMBER)
--                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                               
--             
--             END;
--        WHEN 8 THEN
--             BEGIN
--             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
--                          SELECT *
--                            FROM (
--                                 SELECT *
--                                  FROM (
--                                     SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
--                                            LINE_NUMBER,
--                                            INGRESO_ID
--                                FROM
--                                   (
--                                    SELECT INGRESO_ID
--                                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
--                                      JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL NOM
--                                        ON NOM.PER_NOMINAL_ID = A.PER_NOMINAL_ID AND
--                                          NOM.NOMBRE_COMPLETO = pNombreCompleto 
--                                     WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO                                  
--                                   )
--                                      )
--                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
--                        ORDER BY LINE_NUMBER)
--                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
--             END;
--        WHEN 9 THEN
--             BEGIN
--             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
--                          SELECT *
--                            FROM (
--                                 SELECT *
--                                  FROM (
--                                     SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
--                                            LINE_NUMBER,
--                                            INGRESO_ID
--                                FROM
--                                   (
--                                    SELECT INGRESO_ID
--                                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
--                                     WHERE UNIDAD_SALUD_INGRESO = pUnidadSaludId AND   
--                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO                                  
--                                   )
--                                      )
--                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
--                        ORDER BY LINE_NUMBER)
--                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
--             END;
--        WHEN 10 THEN
--             BEGIN
--             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
--                          SELECT *
--                            FROM (
--                                 SELECT *
--                                  FROM (
--                                     SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
--                                            LINE_NUMBER,
--                                            INGRESO_ID
--                                FROM
--                                   (
--                                    SELECT INGRESO_ID
--                                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
--                                     WHERE ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO                                  
--                                   )
--                                      )
--                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
--                        ORDER BY LINE_NUMBER)
--                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
--             END;                          
        ELSE NULL;
        END CASE;
 EXCEPTION
  WHEN OTHERS THEN
      pResultado := 'Error al procesar paginación';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;            
 END PR_I_TABLA_TEMPORAL_ING_EGRE; 

 PROCEDURE PR_I_TABLA_TEMPORAL_CATCAMA (pFechaInicio     IN DATE,
                                        pFechaFin        IN DATE,
                                        pNombreCompleto  IN VARCHAR2,
                                        pPrimerNombre    IN VARCHAR2,
                                        pSegundoNombre   IN VARCHAR2,
                                        pPrimerApellido  IN VARCHAR2,
                                        pSegundoApellido IN VARCHAR2,
                                        pSexo            IN VARCHAR2,
                                        pUnidadSaludId   IN NUMBER,
                                        pMunicipioId     IN NUMBER,
                                        pEntAdminId      IN NUMBER,
                                        pPgnAct          IN NUMBER DEFAULT 1, 
                                        pPgnTmn          IN NUMBER DEFAULT 100,
                                        pTipoPaginacion  IN NUMBER,
                                        pResultado       OUT VARCHAR2,                       
                                        pMsgError        OUT VARCHAR2) IS
   vFirma VARCHAR2(100) := 'PKG_SIPAI_CONTROL_VACUNAS.PR_I_TABLA_TEMPORAL => '; 
 BEGIN
        CASE pTipoPaginacion
        WHEN 2 THEN
             BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CAMA_ID
                                FROM
                                   (             
                                       SELECT A.CAMA_ID
                                         FROM HOSPITALARIO.SNH_CAT_CAMAS A
                                        WHERE (NOT EXISTS (SELECT 1
                                                            FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                                                           WHERE B.CAMA_ID = A.CAMA_ID) AND
                                               NOT EXISTS (SELECT 1
                                                            FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS C
                                                           WHERE C.CAMA_ID = A.CAMA_ID AND
                                                                 C.ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO))
                                          AND A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                               
             
             END;
        WHEN 4 THEN
             BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CAMA_ID
                                FROM
                                   (             
                                       SELECT A.CAMA_ID
                                         FROM HOSPITALARIO.SNH_CAT_CAMAS A
                                        WHERE (EXISTS (SELECT 1
                                                            FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                                                           WHERE B.CAMA_ID = A.CAMA_ID) -- AND
--                                               NOT EXISTS (SELECT 1
--                                                            FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS C
--                                                           WHERE C.CAMA_ID = A.CAMA_ID AND
--                                                                 C.ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO)
                                                                 )
                                          AND A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                               
             
             END;             
        WHEN 3 THEN
             BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
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
                                      WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO                                  
                                   )
                                      )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1); 
             END;
        ELSE NULL;
        END CASE;
 EXCEPTION
 WHEN OTHERS THEN
      pResultado := 'Error al procesar paginación';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;            
 END PR_I_TABLA_TEMPORAL_CATCAMA;
 
 PROCEDURE PR_I_TABLA_TEMPORAL_CFG_CAMA (pConsulta       IN HOSPITALARIO.OBJ_CGF_CAMA_SERVICIO,
                                         pPgnAct         IN NUMBER DEFAULT 1, 
                                         pPgnTmn         IN NUMBER DEFAULT 100,
                                         pTipoPaginacion IN NUMBER,
                                         pResultado      OUT VARCHAR2,                       
                                         pMsgError       OUT VARCHAR2) IS
   vFirma VARCHAR2(100) := 'PKG_SIPAI_CONTROL_VACUNAS.PR_I_TABLA_TEMPORAL_CFG_CAMA => '; 
 BEGIN
 CASE pTipoPaginacion
 WHEN 1 THEN
      BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
                                     WHERE CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);        
      END;
 WHEN 2 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.CODIGO_ASISTENCIAL = pConsulta.CodAsistencial  AND
                                           A.UND_SALUD_SERVICIO_ID = pConsulta.UsalServId AND 
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;
 WHEN 3 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.CODIGO_ASISTENCIAL = pConsulta.CodAsistencial  AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;    
 WHEN 4 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.UND_SALUD_SERVICIO_ID = pConsulta.UsalServId AND 
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;  
 WHEN 5 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.SALA_ID = pConsulta.SalaId  AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;     
 WHEN 6 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.HABITACION_ID = pConsulta.HabitacionId  AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;                        
 WHEN 7 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.CAMA_ID = pConsulta.CamaId AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;  

 WHEN 8 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.SERVICIO_ID = pConsulta.ServicioId AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId 
                                     WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;  
 WHEN 9 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.DISPONIBLE = pConsulta.Disponible AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;  
 WHEN 10 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.ESTADO_CAMA_ID = pConsulta.EstadoCama AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END; 
 WHEN 11 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
                                        ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
                                           B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                     WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;                      
 WHEN 12 THEN
       BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            CFG_USLD_SERVICIO_CAMA_ID
                                FROM
                                   (             
                                    SELECT CFG_USLD_SERVICIO_CAMA_ID
                                      FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
                                     WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
       END;
 ELSE NULL;        
 END CASE;
 EXCEPTION
  WHEN OTHERS THEN
      pResultado := 'Error al procesar paginación';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;   
 END PR_I_TABLA_TEMPORAL_CFG_CAMA;  
 
 PROCEDURE PR_I_TABLA_TEMP_RELADMINSERV (pConsulta       IN HOSPITALARIO.OBJ_ADMSRV_CAMAS,
                                         pPgnAct         IN NUMBER DEFAULT 1, 
                                         pPgnTmn         IN NUMBER DEFAULT 100,
                                         pTipoPaginacion IN NUMBER,
                                         pResultado      OUT VARCHAR2,                       
                                         pMsgError       OUT VARCHAR2) IS
 vFirma VARCHAR2(100) := 'PKG_SIPAI_CONTROL_VACUNAS.PR_I_TABLA_TEMPORAL_CFG_CAMA => '; 
 BEGIN
   CASE pTipoPaginacion
   WHEN 1 THEN
      BEGIN
          INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID  
                                      FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                                     WHERE ADMISION_SRV_CAMA_ID = pConsulta.AdminServCamaId AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                             )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                     
      END;
   WHEN 2 THEN
      BEGIN
          INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID    
                                      FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                                     WHERE CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
                                           IS_LAST = pConsulta.IsLast AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                     
      END;
   WHEN 3 THEN   
      BEGIN
          INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID  
                                      FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                                     WHERE ADMISION_SERVICIO_ID = pConsulta.AdminServId AND
                                           IS_LAST = pConsulta.IsLast AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                  )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                    
      END;
   WHEN 4 THEN 
      BEGIN 
          INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID       
                                      FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS A
                                      JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                                      ON B.CFG_USLD_SERVICIO_CAMA_ID = A.CFG_USLD_SERVICIO_CAMA_ID
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS C
                                      ON C.UND_SALUD_SERVICIO_ID = B.UND_SALUD_SERVICIO_ID AND
                                         C.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                   WHERE A.IS_LAST = pConsulta.IsLast AND
                                         A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                 
      END;
   WHEN 5 THEN
      BEGIN
            INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID  
                                      FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                                     WHERE CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                        
      END;
   WHEN 6 THEN   
      BEGIN
            INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID   
                                      FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                                     WHERE ADMISION_SERVICIO_ID = pConsulta.AdminServId AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                       
      END;
   WHEN 7 THEN 
      BEGIN 
            INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID         
                                      FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS A
                                      JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                                      ON B.CFG_USLD_SERVICIO_CAMA_ID = A.CFG_USLD_SERVICIO_CAMA_ID
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS C
                                      ON C.UND_SALUD_SERVICIO_ID = B.UND_SALUD_SERVICIO_ID AND
                                         C.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
                                   WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                    )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);            
      END;
   WHEN 8 THEN   
      BEGIN
            INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID   
                               FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                              WHERE IS_LAST = pConsulta.IsLast AND
                                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                     )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                       
      END;                  
   WHEN 9 THEN 
      BEGIN
            INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            ADMISION_SRV_CAMA_ID
                                FROM
                                   (             
                                    SELECT ADMISION_SRV_CAMA_ID    
                                      FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                                     WHERE ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                     )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                
      END;  
   ELSE NULL;
   END CASE;
EXCEPTION
 WHEN OTHERS THEN
      pResultado := 'Error al procesar paginación';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;      
  END PR_I_TABLA_TEMP_RELADMINSERV;
 
 PROCEDURE PR_I_TABLA_TEMP_INDISP_CAMAS (pConsulta       IN HOSPITALARIO.OBJ_INDISPONIBILIDAD_CAMAS,       
                                         pPgnAct         IN NUMBER DEFAULT 1, 
                                         pPgnTmn         IN NUMBER DEFAULT 100,
                                         pTipoPaginacion IN NUMBER,
                                         pResultado      OUT VARCHAR2,           
                                         pMsgError       OUT VARCHAR2) IS
 vFirma VARCHAR2(100) := 'PKG_SIPAI_CONTROL_VACUNAS.PR_I_TABLA_TEMP_INDISP_CAMAS => '; 
 BEGIN
   CASE pTipoPaginacion
   WHEN 1 THEN
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS
                                     WHERE INDISPONIBILIDAD_CAMA_ID = pConsulta.IndCamaId AND
                                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);               
        END; 
   WHEN 2 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                      JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
                                        ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
                                           CFGCAMAS.CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
                                           CFGCAMAS.IS_LAST = 1
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
                                        ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
                                           REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
                                     WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);         
        END;    
   WHEN 3 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                      JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
                                        ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
                                           CFGCAMAS.IS_LAST = 1
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
                                        ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
                                           REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
                                     WHERE A.CAMA_ID = pConsulta.CamaId AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO 
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                                                                              
        END; 
   WHEN 4 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                      JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
                                        ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
                                           CFGCAMAS.IS_LAST = 1
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
                                        ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
                                           REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
                                     WHERE A.CAUSA_ID = pConsulta.CausaId AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                                                   
        END;   
   WHEN 5 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                      JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
                                        ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
                                           CFGCAMAS.IS_LAST = 1
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
                                        ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
                                           REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
                                     WHERE (TRUNC(A.FECHA_SALIDA) BETWEEN pConsulta.FecSalidaInicio AND pConsulta.FecSalidaFin) AND 
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                                                   
        END;                         
   WHEN 6 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                      JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
                                        ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
                                           CFGCAMAS.CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
                                           CFGCAMAS.IS_LAST = 1
                                     WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);
                                             
        END;    
   WHEN 7 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                     WHERE A.CAMA_ID = pConsulta.CamaId AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                                                   
        END;  
   WHEN 8 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                     WHERE A.CAUSA_ID = pConsulta.CausaId AND
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                                                   
        END;     
   WHEN 9 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                     WHERE (TRUNC(A.FECHA_SALIDA) BETWEEN pConsulta.FecSalidaInicio AND pConsulta.FecSalidaFin) AND 
                                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                                                   
        END;
   WHEN 10 THEN   
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                      JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
                                        ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
                                           CFGCAMAS.IS_LAST = 1
                                      JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
                                        ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
                                           REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
                                     WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);                                             
        END;   
   WHEN 11 THEN  
        BEGIN
             INSERT INTO HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
                          SELECT *
                            FROM (
                                 SELECT *
                                  FROM (
                                     SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                            LINE_NUMBER,
                                            INDISPONIBILIDAD_CAMA_ID
                                FROM
                                   (             
                                    SELECT INDISPONIBILIDAD_CAMA_ID
                                      FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
                                     WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                   )
                                                              )
                         WHERE LINE_NUMBER < ((pPgnAct * pPgnTmn) + 1)
                        ORDER BY LINE_NUMBER)
                     WHERE LINE_NUMBER >= ( ( ( pPgnAct - 1) * pPgnTmn) + 1);           
                                             
        END;
   ELSE NULL;
   END CASE;
 EXCEPTION
  WHEN OTHERS THEN
      pResultado := 'Error al procesar paginación';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;     
 END PR_I_TABLA_TEMP_INDISP_CAMAS;
 
 PROCEDURE PR_I_PRE_INGRESO (pPregIngresoId     OUT HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE,
                             pAdmisionId        IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISION_ID%TYPE,                                                                             
                             pProcedenciaId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PROCEDENCIA_ID%TYPE,                             
                             pPerNominalId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PER_NOMINAL_ID%TYPE,                             
                             pCodExpElectronico IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.CODIGO_EXPEDIENTE_ELECTRONICO%TYPE,
                             pExpedienteId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.EXPEDIENTE_ID%TYPE,                               
                             pNomCompletoPx     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.NOMBRE_COMPLETO_PX%TYPE,                     
                             pMedOrdenaIngId    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.MEDICO_ORDENA_INGRESO_ID%TYPE,         
                             pServProcedenId    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE,           
                             pEspDestinoId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESPECIALIDAD_DESTINO_ID%TYPE,           
                             pAdminSolicIngId   IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISIONISTA_SOLICITA_INGR_ID%TYPE,
                             pFecSolicitaIng    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.FECHA_SOLICITUD_INGRESO%TYPE,           
                             pHrSolicitudIng    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.HORA_SOLICITUD_INGRESO%TYPE,             
                             pUsalOrigenId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_ORIGEN_ID%TYPE,             
                             pUsalDestinoId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE,           
                             pReferenciaId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.REFERENCIA_ID%TYPE,                               
                             pEstadoPreIngId    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PRE_INGRESO_ID%TYPE,               
                             pComentarios       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.COMENTARIOS%TYPE,                                   
                             pTipIdentiId       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.TIPO_IDENTIFICACION_ID%TYPE,             
                             pIdentificacion    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.IDENTIFICACION%TYPE,                             
                             pEstadoPxId        IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PX_ID%TYPE,
                             pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                             pResultado         OUT VARCHAR2,
                             pMsgError          OUT VARCHAR2
                             ) IS 
 vFirma             VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_I_PRE_INGRESO => ';
 BEGIN
   dbms_output.put_line ('Entra al insert');
    INSERT INTO HOSPITALARIO.SNH_MST_PREG_INGRESOS
               (ADMISION_ID,                   
                PROCEDENCIA_ID,                
                PER_NOMINAL_ID,                
                CODIGO_EXPEDIENTE_ELECTRONICO, 
                EXPEDIENTE_ID,                 
                NOMBRE_COMPLETO_PX,            
                MEDICO_ORDENA_INGRESO_ID,      
                SERVICIO_PROCEDENCIA_ID,       
                ESPECIALIDAD_DESTINO_ID,       
                ADMISIONISTA_SOLICITA_INGR_ID, 
                FECHA_SOLICITUD_INGRESO,       
                HORA_SOLICITUD_INGRESO,        
                UNIDAD_SALUD_ORIGEN_ID,        
                UNIDAD_SALUD_DESTINO_ID,       
                REFERENCIA_ID,                 
                ESTADO_PRE_INGRESO_ID,         
                COMENTARIOS,                   
                TIPO_IDENTIFICACION_ID,        
                IDENTIFICACION,                
                ESTADO_PX_ID,
                ESTADO_REGISTRO_ID,
                USUARIO_REGISTRO)
         VALUES
               (pAdmisionId,                
                pProcedenciaId,             
                pPerNominalId,             
                pCodExpElectronico,  
                pExpedienteId,              
                pNomCompletoPx,         
                pMedOrdenaIngId,     
                pServProcedenId,     
                pEspDestinoId,     
                pAdminSolicIngId,
                pFecSolicitaIng,     
                pHrSolicitudIng,      
                pUsalOrigenId,       
                pUsalDestinoId,      
                pReferenciaId,              
                pEstadoPreIngId,        
                pComentarios,               
                pTipIdentiId,      
                pIdentificacion,            
                pEstadoPxId,
                vGLOBAL_ESTADO_ACTIVO,
                pUsuario                
               )
               RETURNING PREG_INGRESO_ID INTO pPregIngresoId;
               
   pResultado := 'Pre registro creado con éxito. [Id:'||pPregIngresoId||']';  
   dbms_output.put_line ('pPregIngresoId: '||pPregIngresoId);      
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;
 WHEN eRegistroExiste THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;     
 WHEN OTHERS THEN
      dbms_output.put_line ('when others: '||sqlerrm);
      pResultado := 'Error al crear el registro de pre ingreso';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;                                      
 END PR_I_PRE_INGRESO;     

 PROCEDURE PR_U_PRE_INGRESO (pPregIngresoId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE,
                             pAdmisionId        IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISION_ID%TYPE,                   
                             pProcedenciaId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PROCEDENCIA_ID%TYPE,                
                             pPerNominalId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PER_NOMINAL_ID%TYPE,                
                             pCodExpElectronico IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.CODIGO_EXPEDIENTE_ELECTRONICO%TYPE,
                             pExpedienteId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.EXPEDIENTE_ID%TYPE,                 
                             pNomCompletoPx     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.NOMBRE_COMPLETO_PX%TYPE,            
                             pMedOrdenaIngId    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.MEDICO_ORDENA_INGRESO_ID%TYPE,      
                             pServProcedenId    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE,       
                             pEspDestinoId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESPECIALIDAD_DESTINO_ID%TYPE,       
                             pAdminSolicIngId   IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISIONISTA_SOLICITA_INGR_ID%TYPE,
                             pFecSolicitaIng    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.FECHA_SOLICITUD_INGRESO%TYPE,       
                             pHrSolicitudIng    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.HORA_SOLICITUD_INGRESO%TYPE,        
                             pUsalOrigenId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_ORIGEN_ID%TYPE,        
                             pUsalDestinoId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE,       
                             pReferenciaId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.REFERENCIA_ID%TYPE,                 
                             pEstadoPreIngId    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PRE_INGRESO_ID%TYPE,         
                             pComentarios       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.COMENTARIOS%TYPE,                   
                             pTipIdentiId       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.TIPO_IDENTIFICACION_ID%TYPE,        
                             pIdentificacion    IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.IDENTIFICACION%TYPE,                
                             pEstadoPxId        IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PX_ID%TYPE,
                             pEstadoRegistroId  IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_REGISTRO_ID%TYPE,
                             pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                             pResultado         OUT VARCHAR2,
                             pMsgError          OUT VARCHAR2) IS 
 vFirma             VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_U_PRE_INGRESO => ';  
 BEGIN
     CASE
     WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ELIMINADO THEN
         <<EliminaRegistro>>
          BEGIN
             UPDATE HOSPITALARIO.SNH_MST_PREG_INGRESOS
                SET ESTADO_REGISTRO_ID   = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,
                    USUARIO_ELIMINA      = pUsuario,
                    FECHA_ELIMINA        = CURRENT_TIMESTAMP
              WHERE PREG_INGRESO_ID = pPregIngresoId;
          EXCEPTION
             WHEN OTHERS THEN
                  pResultado := 'Error no controlado al eliminar registro [pPregIngresoId] - '||pPregIngresoId;
                  pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                  RETURN;                
          END EliminaRegistro;
          pResultado := 'Se ha eliminado el registro. [Id:'||pPregIngresoId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_PASIVO THEN
         <<PasivaRegistro>>       
         BEGIN
            UPDATE  HOSPITALARIO.SNH_MST_PREG_INGRESOS
                SET ESTADO_REGISTRO_ID = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,  
                    USUARIO_PASIVA       = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                           ELSE USUARIO_PASIVA
                                           END,    
                    FECHA_PASIVA         = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                           ELSE FECHA_PASIVA
                                           END
             WHERE PREG_INGRESO_ID = pPregIngresoId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;     
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al pasivar registro [pPregIngresoId] - '||pPregIngresoId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END PasivaRegistro;
         pResultado := 'Se ha pasivado el registro. [Id:'||pPregIngresoId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN
          <<ActivarRegistro>>
         BEGIN
            UPDATE HOSPITALARIO.SNH_MST_PREG_INGRESOS
               SET ESTADO_REGISTRO_ID   = pEstadoRegistroId, 
                   USUARIO_MODIFICACION = pUsuario,    
                   USUARIO_PASIVA       = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                          ELSE USUARIO_PASIVA
                                          END,    
                   FECHA_PASIVA         = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                          ELSE FECHA_PASIVA
                                          END
             WHERE PREG_INGRESO_ID = pPregIngresoId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [pPregIngresoId] - '||pPregIngresoId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActivarRegistro; 
         pResultado := 'Se ha activado el registro. [Id:'||pPregIngresoId||']';                        
     ELSE 
         <<ActualizarRegistro>>
         BEGIN
            UPDATE HOSPITALARIO.SNH_MST_PREG_INGRESOS  
               SET ADMISION_ID                       = NVL(pAdmisionId, ADMISION_ID),                  
                   PROCEDENCIA_ID                    = NVL(pProcedenciaId, PROCEDENCIA_ID),    
                   PER_NOMINAL_ID                    = NVL(pPerNominalId, PER_NOMINAL_ID),     
                   CODIGO_EXPEDIENTE_ELECTRONICO     = NVL(pCodExpElectronico, CODIGO_EXPEDIENTE_ELECTRONICO),
                   EXPEDIENTE_ID                     = NVL(pExpedienteId, EXPEDIENTE_ID),     
                   NOMBRE_COMPLETO_PX                = NVL(pNomCompletoPx, NOMBRE_COMPLETO_PX),    
                   MEDICO_ORDENA_INGRESO_ID          = NVL(pMedOrdenaIngId, MEDICO_ORDENA_INGRESO_ID),   
                   SERVICIO_PROCEDENCIA_ID           = NVL(pServProcedenId, SERVICIO_PROCEDENCIA_ID),   
                   ESPECIALIDAD_DESTINO_ID           = NVL(pEspDestinoId, ESPECIALIDAD_DESTINO_ID),     
                   ADMISIONISTA_SOLICITA_INGR_ID     = NVL(pAdminSolicIngId, ADMISIONISTA_SOLICITA_INGR_ID),  
                   FECHA_SOLICITUD_INGRESO           = NVL(pFecSolicitaIng, FECHA_SOLICITUD_INGRESO),   
                   HORA_SOLICITUD_INGRESO            = NVL(pHrSolicitudIng, HORA_SOLICITUD_INGRESO),   
                   UNIDAD_SALUD_ORIGEN_ID            = NVL(pUsalOrigenId, UNIDAD_SALUD_ORIGEN_ID),     
                   UNIDAD_SALUD_DESTINO_ID           = NVL(pUsalDestinoId, UNIDAD_SALUD_DESTINO_ID),    
                   REFERENCIA_ID                     = NVL(pReferenciaId, REFERENCIA_ID),     
                   ESTADO_PRE_INGRESO_ID             = pEstadoPreIngId,   
                   COMENTARIOS                       = pComentarios,      
                   TIPO_IDENTIFICACION_ID            = pTipIdentiId,      
                   IDENTIFICACION                    = pIdentificacion,   
                   ESTADO_PX_ID                      = pEstadoPxId,       
                   USUARIO_MODIFICACION              = pUsuario          
             WHERE PREG_INGRESO_ID = pPregIngresoId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [pPregIngresoId] - '||pPregIngresoId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActualizarRegistro; 
         pResultado := 'Se ha actualizado el registro. [Id:'||pPregIngresoId||']';                              
     END CASE;
 END PR_U_PRE_INGRESO;    
  
 FUNCTION FN_VAL_EXISTE_PRE_INGRESO (pConsulta      IN HOSPITALARIO.OBJ_PRE_INGRESO,
                                     pPgn           IN BOOLEAN,
                                     pCantRegistros OUT NUMBER,
                                     pFuente        OUT NUMBER) RETURN BOOLEAN AS
 vContador SIMPLE_INTEGER := 0;
 vExiste BOOLEAN := FALSE;
 BEGIN
 CASE
 WHEN pConsulta.FecInicio IS NULL AND pConsulta.FecFin IS NULL THEN 
      CASE
      WHEN NVL(pConsulta.PregIngresoId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE PREG_INGRESO_ID = pConsulta.PregIngresoId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 1;        
           END;
      WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
            NVL(pConsulta.ExpedienteId,0) > 0)  THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                    EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 2;
            END;  
      WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 3;
           END;  
      WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 4;
           END;              
      WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND 
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 5;
           END;
      WHEN pConsulta.Identificacion IS NOT NULL THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE IDENTIFICACION = pConsulta.Identificacion AND 
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 6;
           END;
      WHEN pConsulta.AdmisionId IS NOT NULL THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE ADMISION_ID = pConsulta.AdmisionId AND 
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 7;
           END;           
      WHEN (pConsulta.NombreCompleto IS NOT NULL AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 8;
            END;
      WHEN (pConsulta.NombreCompleto IS NOT NULL AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 9;
            END;
      WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 10;
            END;  
      WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 11;
            END;  
      WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 12;
            END;  
      WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 13;
            END;      ---
      WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 14;
            END;  
      WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 15;
            END;  
      WHEN (NVL(pConsulta.EstadoPreIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 16;
            END;  
      WHEN (NVL(pConsulta.EstadoPreIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 17;
            END;    
      WHEN (NVL(pConsulta.EstadoPxId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 18;
            END;  
      WHEN (NVL(pConsulta.EstadoPxId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 19;
            END;                                                                       
      WHEN pConsulta.NombreCompleto IS NOT NULL THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 20;
            END;
      WHEN NVL(pConsulta.MedOrdenaIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 21;
            END; 
      WHEN NVL(pConsulta.AdminSolicIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 22;
            END;   
      WHEN NVL(pConsulta.ServProcedenId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 23;
            END;  
      WHEN NVL(pConsulta.EstadoPreIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 24;
            END;  
      WHEN NVL(pConsulta.EstadoPxId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 25;
            END;                                                        
      WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 26;
            END;
      ELSE 
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 27;
            END;
      END CASE;
 ELSE --
       CASE
      WHEN NVL(pConsulta.PregIngresoId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE PREG_INGRESO_ID = pConsulta.PregIngresoId AND
                   FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 28;        
           END;
      WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
            NVL(pConsulta.ExpedienteId,0) > 0)  THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                    EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 29;
            END;  
      WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                   FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 30;
           END;  
      WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                   FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 31;
           END;              
      WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND 
                   FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 32;
           END;
      WHEN pConsulta.Identificacion IS NOT NULL THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE IDENTIFICACION = pConsulta.Identificacion AND 
                   FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 33;
           END;
      WHEN pConsulta.AdmisionId IS NOT NULL THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
             WHERE ADMISION_ID = pConsulta.AdmisionId AND
                   FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 34;
           END;           
      WHEN (pConsulta.NombreCompleto IS NOT NULL AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND    
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 35;
            END;
      WHEN (pConsulta.NombreCompleto IS NOT NULL AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 36;
            END;
      WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 37;
            END;  
      WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 38;
            END;  
      WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 39;
            END;  
      WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 40;
            END;      ---
      WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 41;
            END;  
      WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 42;
            END;  
      WHEN (NVL(pConsulta.EstadoPreIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 43;
            END;  
      WHEN (NVL(pConsulta.EstadoPreIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 44;
            END;    
      WHEN (NVL(pConsulta.EstadoPxId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND
                    UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 45;
            END;  
      WHEN (NVL(pConsulta.EstadoPxId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND
                    UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 46;
            END;                                                                       
      WHEN pConsulta.NombreCompleto IS NOT NULL THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE CATSEARCH(NOMBRE_COMPLETO_PX,pConsulta.NombreCompleto,NULL) > 1 AND  -- NOMBRE_COMPLETO_PX = pConsulta.NombreCompleto AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 47;
            END;
      WHEN NVL(pConsulta.MedOrdenaIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE MEDICO_ORDENA_INGRESO_ID = pConsulta.MedOrdenaIngId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 48;
            END; 
      WHEN NVL(pConsulta.AdminSolicIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ADMISIONISTA_SOLICITA_INGR_ID = pConsulta.AdminSolicIngId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 49;
            END;   
      WHEN NVL(pConsulta.ServProcedenId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE SERVICIO_PROCEDENCIA_ID = pConsulta.ServProcedenId AND
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 50;
            END;  
      WHEN NVL(pConsulta.EstadoPreIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PRE_INGRESO_ID = pConsulta.EstadoPreIngId AND 
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 51;
            END;  
      WHEN NVL(pConsulta.EstadoPxId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE ESTADO_PX_ID = pConsulta.EstadoPxId AND   
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 52;
            END;                                                        
      WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE UNIDAD_SALUD_DESTINO_ID = pConsulta.UsalIngresoId AND 
                    FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 53;
            END;
      ELSE 
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS
              WHERE FECHA_SOLICITUD_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 54;
            END;
      END CASE;
 END CASE;     
 CASE
 WHEN vContador > 0 THEN
      vExiste := TRUE;
 ELSE NULL;
 END CASE;
 pCantRegistros := vContador;          
 RETURN vExiste;
 EXCEPTION
 WHEN OTHERS THEN
     RETURN vExiste;   
 END FN_VAL_EXISTE_PRE_INGRESO; 

 FUNCTION FN_OBT_PREINGR_ID (pPregIngresoId IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE) RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
      OPEN vRegistro FOR
      SELECT *
            -- PRE_INGRESO_ID, 
            -- PRE_ADMISION_ID
      FROM (
           SELECT  PREING.PREG_INGRESO_ID               PRE_INGRESO_ID,                                    
                   PREING.ADMISION_ID                   PRE_ADMISION_ID,                                                        
                   PREING.PROCEDENCIA_ID                PRE_PROCENDENCIA_ID,                                   
                   CATPROCED.CODIGO                     PRECATPROC_CODIGO,
                   CATPROCED.VALOR                      PRECATPROC_VALOR,
                   CATPROCED.DESCRIPCION                PRECATPROC_DESCRIPCION,
                   PREING.NOMBRE_COMPLETO_PX            PRE_NOMBRE_COMPLETO_PX,
                   PREING.PER_NOMINAL_ID                PRE_NOMINAL_ID,   
                   NOM.CODIGO_EXPEDIENTE_ELECTRONICO    PRENOM_COD_EXPEDIENTE,
                   NOM.EXPEDIENTE_ID                    PRENOM_EXPEDIENTE_ID,
                   NOM.PRIMER_NOMBRE                    PRENOM_PNOMBRE,
                   NOM.SEGUNDO_NOMBRE                   PRENOM_SNOMBRE,
                   NOM.PRIMER_APELLIDO                  PRENOM_PAPELLIDO,
                   NOM.SEGUNDO_APELLIDO                 PRENOM_SAPELLIDO,
                   NOM.NOMBRE_COMPLETO                  PRENOM_NOMB_COMPLETO, 
                   NOM.TIPO_IDENTIFICACION_ID           PRENOM_TIP_IDENTIFICACION,
                   NOM.IDENTIFICACION_CODIGO            PRENOM_IDENTIF_CODIGO,
                   NOM.IDENTIFICACION_NOMBRE            PRENOM_IDENTIF_NOMBRE,
                   NOM.IDENTIFICACION_NUMERO            PRENOM_IDENTIF_NUMERO,
                   NOM.SEXO_ID                          PRENOM_SEXO_ID , 
                   NOM.SEXO_CODIGO                      PRENOM_SEXO_CODIGO,
                   NOM.SEXO_VALOR                       PRENOM_SEXO_VALOR,
                   NOM.FECHA_NACIMIENTO                 PRENOM_FEC_NACIMIENTO,
                   NOM.COMUNIDAD_RESIDENCIA_ID          PRENOM_COM_RESIDENCIA_ID,
                   NOM.COMUNIDAD_RESIDENCIA_NOMBRE      PRENOM_COM_RESIDENCIA_NOMBRE,
                   NOM.MUNICIPIO_RESIDENCIA_ID          PRENOM_MUNI_RESIDENCIA_ID,
                   NOM.MUNICIPIO_RESIDENCIA_NOMBRE      PRENOM_MUNI_RESIDENCIA_NOMBRE,
                   NOM.DEPARTAMENTO_RESIDENCIA_ID       PRENOM_DEP_RESIDENCIA_ID,
                   NOM.DEPARTAMENTO_RESIDENCIA_NOMBRE   PRENOM_DEP_RESIDENCIA_NOMBRE,
                   NOM.DIRECCION_RESIDENCIA             PRENOM_DIRECCION_RESIDENCIA,
                   NOM.TELEFONO_ID                      PRENOM_TELEFONO_ID,
                   NOM.TELEFONO                         PRENOM_TELEFONO,  
                   PREING.MEDICO_ORDENA_INGRESO_ID      PRE_MEDICO_ORDENA_INGRESO_ID,                      
                   PER3.PRIMER_NOMBRE                   MEDORDING_PRIMER_NOMBRE,     
                   PER3.SEGUNDO_NOMBRE                  MEDORDING_SEGUNDO_NOMBRE,    
                   PER3.PRIMER_APELLIDO                 MEDORDING_PRIMER_APELLIDO,
                   PER3.SEGUNDO_APELLIDO                MEDORDING_SEGUNDO_APELLIDO,  
                   MEDORDENAING.CODIGO                  MEDORDING_COD_MINSA_PER, 
                   MPERSALUD3.REGISTRO_SANITARIO        MEDORDING_REG_SANITARIO,
                   MEDORDENAING.TIPO_PERSONAL_ID        MEDORDING_TIPO_PERSONAL_ID,
                   CAT3.CODIGO                          MEDORDING_COD_TIPO_PERSONAL,
                   CAT3.VALOR                           MEDORDING_VALOR_TIPO_PERSONAL,
                   CAT3.DESCRIPCION                     MEDORDING_DESC_TIPO_PERSONAL,                   
                   PREING.SERVICIO_PROCEDENCIA_ID       PRE_SERV_PROCEDENCIA_ID,      
                   SERV.CODIGO                          PRE_SERV_PROCED_CODIGO,                          
                   SERV.NOMBRE                          PRE_SERV_PROCED_NOMBRE,                         
                   SERV.DESCRIPCION                     PRE_SERV_PROCED_DESCRIPCION,                    
                   PREING.ESPECIALIDAD_DESTINO_ID       PRE_ESPECIALIDAD_DESTINO,                     
                   ESPDEST.CODIGO                       PREESPDEST_CODIGO, 
                   ESPDEST.NOMBRE                       PREESPDEST_NOMBRE,
                   ESPDEST.DESCRIPCION                  PREESPDEST_DESCRIPCION,
                   PREING.ADMISIONISTA_SOLICITA_INGR_ID PRE_ADMIN_SOLICITA_ING,              
                   PER1.PRIMER_NOMBRE                   ADMSOLINGR_PRIMER_NOMBRE,                  
                   PER1.SEGUNDO_NOMBRE                  ADMSOLINGR_SEGUNDO_NOMBRE,     
                   PER1.PRIMER_APELLIDO                 ADMSOLINGR_PRIMER_APELLIDO,
                   PER1.SEGUNDO_APELLIDO                ADMSOLINGR_SEGUNDO_APELLIDO,  
                   ADMINSOLINGRESO.CODIGO               ADMSOLINGR_COD_MINSA_PER, 
                   MPERSALUD1.REGISTRO_SANITARIO        ADMSOLINGR_REG_SANITARIO,
                   ADMINSOLINGRESO.TIPO_PERSONAL_ID     ADMSOLINGR_TIPO_PERSONAL_ID,
                   CAT1.CODIGO                          ADMSOLINGR_COD_TIPO_PERSONAL,
                   CAT1.VALOR                           ADMSOLINGR_VALOR_TIPO_PERSONAL,
                   CAT1.DESCRIPCION                     ADMSOLINGR_DESC_TIPO_PERSONAL,
                   PREING.FECHA_SOLICITUD_INGRESO       PRE_FEC_SOLICITA_ING,      
                   PREING.HORA_SOLICITUD_INGRESO        PRE_HR_SOLICITA_ING,       
                   PREING.UNIDAD_SALUD_ORIGEN_ID        PRE_USAL_ORIGEN_ID,    
                   USALORI.NOMBRE                       PRE_USAL_ORIGEN_NOMBRE,
                   USALORI.CODIGO                       PRE_USAL_ORIGEN_CODIGO,
                   USALORI.ENTIDAD_ADTVA_ID             PRE_ENTADM_ORIGEN_ID,
                   ENTADVORI.NOMBRE                     PRE_ENTADM_ORIGEN_NOMBRE,   
                   PREING.UNIDAD_SALUD_DESTINO_ID       PRE_USAL_DEST_ID, 
                   USALDEST.NOMBRE                      PRE_USAL_DEST_NOMBRE,
                   USALDEST.CODIGO                      PRE_USAL_DEST_CODIGO,
                   USALDEST.ENTIDAD_ADTVA_ID            PRE_ENTADM_DEST_ID,
                   ENTADVDEST.NOMBRE                    PRE_ENTADM_DEST_NOMBRE,  
                   PREING.REFERENCIA_ID                 PRE_REFERENCIA_ID,                
                   PREING.ESTADO_PRE_INGRESO_ID         PRE_ESTADO_PREINGR_ID,
                   CATESTPREING.CODIGO                  CATESTPRE_CODIGO,
                   CATESTPREING.VALOR                   CATESTPRE_VALOR,
                   CATESTPREING.DESCRIPCION             CATESTPRE_DESCRIPCION,        
                   PREING.COMENTARIOS                   PRE_COMENTARIOS,                  
                   PREING.ESTADO_PX_ID                  PRE_ESTADO_PX_ID,   
                   CATESTPX.CODIGO                      CATESTPX_CODIGO,
                   CATESTPX.VALOR                       CATESTPX_VALOR,
                   CATESTPX.DESCRIPCION                 CATESTPX_DESCRIPCION,              
                   PREING.ESTADO_REGISTRO_ID            PRE_ESTADO_REGISTRO_ID, 
                   CATESTREG.CODIGO                     CATESTREG_CODIGO,          
                   CATESTREG.VALOR                      CATESTREG_VALOR,
                   CATESTREG.DESCRIPCION                CATESTREG_DESCRIPCION,
                   PREING.USUARIO_REGISTRO              PRE_USR_REGISTRO,             
                   PREING.FECHA_REGISTRO                PRE_FEC_REGISTRO,     
                   PREING.USUARIO_MODIFICACION          PRE_USR_MODIFICACION,      
                   PREING.FECHA_MODIFICACION            PRE_FEC_MODIFICACION,
                   PREING.USUARIO_PASIVA                PRE_USR_PASIVA,  
                   PREING.FECHA_PASIVA                  PRE_FEC_PASIVA,      
                   PREING.USUARIO_ELIMINA               PRE_USR_ELIMINA,        
                   PREING.FECHA_ELIMINA                 PRE_FEC_ELIMINA     
              FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS PREING         
              JOIN CATALOGOS.SBC_CAT_CATALOGOS CATPROCED
                ON CATPROCED.CATALOGO_ID = PREING.PROCEDENCIA_ID
              JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL NOM
                ON NOM.PER_NOMINAL_ID = PREING.PER_NOMINAL_ID
              JOIN HOSPITALARIO.SNH_CAT_SERVICIOS SERV
                ON SERV.SERVICIO_ID = PREING.SERVICIO_PROCEDENCIA_ID
              JOIN HOSPITALARIO.SNH_CAT_SERVICIOS ESPDEST
                ON ESPDEST.SERVICIO_ID = PREING.ESPECIALIDAD_DESTINO_ID                  
              JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALORI
                ON USALORI.UNIDAD_SALUD_ID = PREING.UNIDAD_SALUD_ORIGEN_ID
              JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADVORI
                ON ENTADVORI.ENTIDAD_ADTVA_ID = USALORI.ENTIDAD_ADTVA_ID
              JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALDEST
                ON USALDEST.UNIDAD_SALUD_ID = PREING.UNIDAD_SALUD_DESTINO_ID
              JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADVDEST
                ON ENTADVDEST.ENTIDAD_ADTVA_ID = USALDEST.ENTIDAD_ADTVA_ID                    
              JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTPREING
                ON CATESTPREING.CATALOGO_ID = PREING.ESTADO_PRE_INGRESO_ID  
              JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTPX
                ON CATESTPX.CATALOGO_ID = PREING.ESTADO_PX_ID                 
              JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREG
                ON CATESTREG.CATALOGO_ID = PREING.ESTADO_REGISTRO_ID
              JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES MEDORDENAING
                ON MEDORDENAING.MINSA_PERSONAL_ID = PREING.MEDICO_ORDENA_INGRESO_ID
              JOIN CATALOGOS.SBC_MST_PERSONAS PER3
                ON MEDORDENAING.PERSONA_ID = PER3.PERSONA_ID
              JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD3
                ON MPERSALUD3.MINSA_PERSONAL_ID = MEDORDENAING.MINSA_PERSONAL_ID
              JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT3
               ON CAT3.CATALOGO_ID = MEDORDENAING.TIPO_PERSONAL_ID                
              JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES ADMINSOLINGRESO
                ON ADMINSOLINGRESO.MINSA_PERSONAL_ID = PREING.ADMISIONISTA_SOLICITA_INGR_ID
              JOIN CATALOGOS.SBC_MST_PERSONAS PER1
                ON ADMINSOLINGRESO.PERSONA_ID = PER1.PERSONA_ID
              LEFT JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD1
                ON MPERSALUD1.MINSA_PERSONAL_ID = ADMINSOLINGRESO.MINSA_PERSONAL_ID
              JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT1
                ON CAT1.CATALOGO_ID = ADMINSOLINGRESO.TIPO_PERSONAL_ID               
            WHERE PREING.PREG_INGRESO_ID = pPregIngresoId AND
                  PREING.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                  ); 
      RETURN vRegistro; 
 END FN_OBT_PREINGR_ID; 
 
 FUNCTION FN_OBT_PREINGR_PAG RETURN var_refcursor AS
 vRegistro var_refcursor; 
 BEGIN
      OPEN vRegistro FOR
             SELECT *
                   -- PRE_INGRESO_ID, 
                   -- PRE_ADMISION_ID
               FROM (
                    SELECT *
                     FROM HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP A,(
                          SELECT ROW_NUMBER () OVER (ORDER BY PRE_INGRESO_ID ASC)
                                 LINE_NUMBER,   
                                 PRE_INGRESO_ID,                     
                                 PRE_ADMISION_ID,                         
                                 PRE_PROCENDENCIA_ID,                   
                                 PRECATPROC_CODIGO,
                                 PRECATPROC_VALOR,
                                 PRECATPROC_DESCRIPCION,
                                 PRE_NOMBRE_COMPLETO_PX,
                                 PRE_NOMINAL_ID,   
                                 PRENOM_COD_EXPEDIENTE,
                                 PRENOM_EXPEDIENTE_ID,
                                 PRENOM_PNOMBRE,
                                 PRENOM_SNOMBRE,
                                 PRENOM_PAPELLIDO,
                                 PRENOM_SAPELLIDO,
                                 PRENOM_NOMB_COMPLETO, 
                                 PRENOM_TIP_IDENTIFICACION,
                                 PRENOM_IDENTIF_CODIGO,
                                 PRENOM_IDENTIF_NOMBRE, 
                                 PRENOM_IDENTIF_NUMERO,
                                 PRENOM_SEXO_ID , 
                                 PRENOM_SEXO_CODIGO,
                                 PRENOM_SEXO_VALOR,
                                 PRENOM_FEC_NACIMIENTO,
                                 PRENOM_COM_RESIDENCIA_ID,
                                 PRENOM_COM_RESIDENCIA_NOMBRE,
                                 PRENOM_MUNI_RESIDENCIA_ID,
                                 PRENOM_MUNI_RESIDENCIA_NOMBRE,
                                 PRENOM_DEP_RESIDENCIA_ID,
                                 PRENOM_DEP_RESIDENCIA_NOMBRE,
                                 PRENOM_DIRECCION_RESIDENCIA,
                                 PRENOM_TELEFONO_ID,
                                 PRENOM_TELEFONO,   
                                 PRE_MEDICO_ORDENA_INGRESO_ID,         
                                 MEDORDING_PRIMER_NOMBRE,     
                                 MEDORDING_SEGUNDO_NOMBRE,         
                                 MEDORDING_PRIMER_APELLIDO,
                                 MEDORDING_SEGUNDO_APELLIDO,     
                                 MEDORDING_COD_MINSA_PER, 
                                 MEDORDING_REG_SANITARIO,                 
                                 MEDORDING_TIPO_PERSONAL_ID,        
                                 MEDORDING_COD_TIPO_PERSONAL,         
                                 MEDORDING_VALOR_TIPO_PERSONAL,               
                                 MEDORDING_DESC_TIPO_PERSONAL,                            
                                 PRE_SERV_PROCEDENCIA_ID,                  
                                 PRE_SERV_PROCED_CODIGO,                        
                                 PRE_SERV_PROCED_NOMBRE,             
                                 PRE_SERV_PROCED_DESCRIPCION,        
                                 PRE_ESPECIALIDAD_DESTINO,           
                                 PREESPDEST_CODIGO, 
                                 PREESPDEST_NOMBRE,
                                 PREESPDEST_DESCRIPCION,
                                 PRE_ADMIN_SOLICITA_ING,             
                                 ADMSOLINGR_PRIMER_NOMBRE,           
                                 ADMSOLINGR_SEGUNDO_NOMBRE,     
                                 ADMSOLINGR_PRIMER_APELLIDO,
                                 ADMSOLINGR_SEGUNDO_APELLIDO,  
                                 ADMSOLINGR_COD_MINSA_PER, 
                                 ADMSOLINGR_REG_SANITARIO,
                                 ADMSOLINGR_TIPO_PERSONAL_ID,
                                 ADMSOLINGR_COD_TIPO_PERSONAL,
                                 ADMSOLINGR_VALOR_TIPO_PERSONAL,
                                 ADMSOLINGR_DESC_TIPO_PERSONAL,
                                 PRE_FEC_SOLICITA_ING,      
                                 PRE_HR_SOLICITA_ING,       
                                 PRE_USAL_ORIGEN_ID,    
                                 PRE_USAL_ORIGEN_NOMBRE,
                                 PRE_USAL_ORIGEN_CODIGO,
                                 PRE_ENTADM_ORIGEN_ID,
                                 PRE_ENTADM_ORIGEN_NOMBRE,   
                                 PRE_USAL_DEST_ID, 
                                 PRE_USAL_DEST_NOMBRE,
                                 PRE_USAL_DEST_CODIGO,
                                 PRE_ENTADM_DEST_ID,
                                 PRE_ENTADM_DEST_NOMBRE,  
                                 PRE_REFERENCIA_ID,                
                                 PRE_ESTADO_PREINGR_ID,
                                 CATESTPRE_CODIGO,
                                 CATESTPRE_VALOR,
                                 CATESTPRE_DESCRIPCION,        
                                 PRE_COMENTARIOS,                  
                                 PRE_ESTADO_PX_ID,   
                                 CATESTPX_CODIGO,
                                 CATESTPX_VALOR,
                                 CATESTPX_DESCRIPCION,              
                                 PRE_ESTADO_REGISTRO_ID, 
                                 CATESTREG_CODIGO,          
                                 CATESTREG_VALOR,
                                 CATESTREG_DESCRIPCION,
                                 PRE_USR_REGISTRO,             
                                 PRE_FEC_REGISTRO,     
                                 PRE_USR_MODIFICACION,      
                                 PRE_FEC_MODIFICACION,
                                 PRE_USR_PASIVA,  
                                 PRE_FEC_PASIVA,      
                                 PRE_USR_ELIMINA,        
                                 PRE_FEC_ELIMINA     
                    FROM
                    (        
                       SELECT  PREING.PREG_INGRESO_ID               PRE_INGRESO_ID,                                    
                               PREING.ADMISION_ID                   PRE_ADMISION_ID,                                                        
                               PREING.PROCEDENCIA_ID                PRE_PROCENDENCIA_ID,                                   
                               CATPROCED.CODIGO                     PRECATPROC_CODIGO,
                               CATPROCED.VALOR                      PRECATPROC_VALOR,
                               CATPROCED.DESCRIPCION                PRECATPROC_DESCRIPCION,
                               PREING.NOMBRE_COMPLETO_PX            PRE_NOMBRE_COMPLETO_PX,
                               PREING.PER_NOMINAL_ID                PRE_NOMINAL_ID,   
                               NOM.CODIGO_EXPEDIENTE_ELECTRONICO    PRENOM_COD_EXPEDIENTE,
                               NOM.EXPEDIENTE_ID                    PRENOM_EXPEDIENTE_ID,
                               NOM.PRIMER_NOMBRE                    PRENOM_PNOMBRE,
                               NOM.SEGUNDO_NOMBRE                   PRENOM_SNOMBRE,
                               NOM.PRIMER_APELLIDO                  PRENOM_PAPELLIDO,
                               NOM.SEGUNDO_APELLIDO                 PRENOM_SAPELLIDO,
                               NOM.NOMBRE_COMPLETO                  PRENOM_NOMB_COMPLETO, 
                               NOM.TIPO_IDENTIFICACION_ID           PRENOM_TIP_IDENTIFICACION,
                               NOM.IDENTIFICACION_CODIGO            PRENOM_IDENTIF_CODIGO,
                               NOM.IDENTIFICACION_NOMBRE            PRENOM_IDENTIF_NOMBRE,
                               NOM.IDENTIFICACION_NUMERO            PRENOM_IDENTIF_NUMERO,
                               NOM.SEXO_ID                          PRENOM_SEXO_ID , 
                               NOM.SEXO_CODIGO                      PRENOM_SEXO_CODIGO,
                               NOM.SEXO_VALOR                       PRENOM_SEXO_VALOR,
                               NOM.FECHA_NACIMIENTO                 PRENOM_FEC_NACIMIENTO,
                               NOM.COMUNIDAD_RESIDENCIA_ID          PRENOM_COM_RESIDENCIA_ID,
                               NOM.COMUNIDAD_RESIDENCIA_NOMBRE      PRENOM_COM_RESIDENCIA_NOMBRE,
                               NOM.MUNICIPIO_RESIDENCIA_ID          PRENOM_MUNI_RESIDENCIA_ID,
                               NOM.MUNICIPIO_RESIDENCIA_NOMBRE      PRENOM_MUNI_RESIDENCIA_NOMBRE,
                               NOM.DEPARTAMENTO_RESIDENCIA_ID       PRENOM_DEP_RESIDENCIA_ID,
                               NOM.DEPARTAMENTO_RESIDENCIA_NOMBRE   PRENOM_DEP_RESIDENCIA_NOMBRE,
                               NOM.DIRECCION_RESIDENCIA             PRENOM_DIRECCION_RESIDENCIA,
                               NOM.TELEFONO_ID                      PRENOM_TELEFONO_ID,
                               NOM.TELEFONO                         PRENOM_TELEFONO,  
                               PREING.MEDICO_ORDENA_INGRESO_ID      PRE_MEDICO_ORDENA_INGRESO_ID,                      
                               PER3.PRIMER_NOMBRE                   MEDORDING_PRIMER_NOMBRE,     
                               PER3.SEGUNDO_NOMBRE                  MEDORDING_SEGUNDO_NOMBRE,    
                               PER3.PRIMER_APELLIDO                 MEDORDING_PRIMER_APELLIDO,
                               PER3.SEGUNDO_APELLIDO                MEDORDING_SEGUNDO_APELLIDO,  
                               MEDORDENAING.CODIGO                  MEDORDING_COD_MINSA_PER, 
                               MPERSALUD3.REGISTRO_SANITARIO        MEDORDING_REG_SANITARIO,
                               MEDORDENAING.TIPO_PERSONAL_ID        MEDORDING_TIPO_PERSONAL_ID,
                               CAT3.CODIGO                          MEDORDING_COD_TIPO_PERSONAL,
                               CAT3.VALOR                           MEDORDING_VALOR_TIPO_PERSONAL,
                               CAT3.DESCRIPCION                     MEDORDING_DESC_TIPO_PERSONAL,                   
                               PREING.SERVICIO_PROCEDENCIA_ID       PRE_SERV_PROCEDENCIA_ID,      
                               SERV.CODIGO                          PRE_SERV_PROCED_CODIGO,                          
                               SERV.NOMBRE                          PRE_SERV_PROCED_NOMBRE,                         
                               SERV.DESCRIPCION                     PRE_SERV_PROCED_DESCRIPCION,                    
                               PREING.ESPECIALIDAD_DESTINO_ID       PRE_ESPECIALIDAD_DESTINO,                     
                               ESPDEST.CODIGO                       PREESPDEST_CODIGO, 
                               ESPDEST.NOMBRE                       PREESPDEST_NOMBRE,
                               ESPDEST.DESCRIPCION                  PREESPDEST_DESCRIPCION,
                               PREING.ADMISIONISTA_SOLICITA_INGR_ID PRE_ADMIN_SOLICITA_ING,              
                               PER1.PRIMER_NOMBRE                   ADMSOLINGR_PRIMER_NOMBRE,                  
                               PER1.SEGUNDO_NOMBRE                  ADMSOLINGR_SEGUNDO_NOMBRE,     
                               PER1.PRIMER_APELLIDO                 ADMSOLINGR_PRIMER_APELLIDO,
                               PER1.SEGUNDO_APELLIDO                ADMSOLINGR_SEGUNDO_APELLIDO,  
                               ADMINSOLINGRESO.CODIGO               ADMSOLINGR_COD_MINSA_PER, 
                               MPERSALUD1.REGISTRO_SANITARIO        ADMSOLINGR_REG_SANITARIO,
                               ADMINSOLINGRESO.TIPO_PERSONAL_ID     ADMSOLINGR_TIPO_PERSONAL_ID,
                               CAT1.CODIGO                          ADMSOLINGR_COD_TIPO_PERSONAL,
                               CAT1.VALOR                           ADMSOLINGR_VALOR_TIPO_PERSONAL,
                               CAT1.DESCRIPCION                     ADMSOLINGR_DESC_TIPO_PERSONAL,
                               PREING.FECHA_SOLICITUD_INGRESO       PRE_FEC_SOLICITA_ING,      
                               PREING.HORA_SOLICITUD_INGRESO        PRE_HR_SOLICITA_ING,       
                               PREING.UNIDAD_SALUD_ORIGEN_ID        PRE_USAL_ORIGEN_ID,    
                               USALORI.NOMBRE                       PRE_USAL_ORIGEN_NOMBRE,
                               USALORI.CODIGO                       PRE_USAL_ORIGEN_CODIGO,
                               USALORI.ENTIDAD_ADTVA_ID             PRE_ENTADM_ORIGEN_ID,
                               ENTADVORI.NOMBRE                     PRE_ENTADM_ORIGEN_NOMBRE,   
                               PREING.UNIDAD_SALUD_DESTINO_ID       PRE_USAL_DEST_ID, 
                               USALDEST.NOMBRE                      PRE_USAL_DEST_NOMBRE,
                               USALDEST.CODIGO                      PRE_USAL_DEST_CODIGO,
                               USALDEST.ENTIDAD_ADTVA_ID            PRE_ENTADM_DEST_ID,
                               ENTADVDEST.NOMBRE                    PRE_ENTADM_DEST_NOMBRE,  
                               PREING.REFERENCIA_ID                 PRE_REFERENCIA_ID,                
                               PREING.ESTADO_PRE_INGRESO_ID         PRE_ESTADO_PREINGR_ID,
                               CATESTPREING.CODIGO                  CATESTPRE_CODIGO,
                               CATESTPREING.VALOR                   CATESTPRE_VALOR,
                               CATESTPREING.DESCRIPCION             CATESTPRE_DESCRIPCION,        
                               PREING.COMENTARIOS                   PRE_COMENTARIOS,                  
                               PREING.ESTADO_PX_ID                  PRE_ESTADO_PX_ID,   
                               CATESTPX.CODIGO                      CATESTPX_CODIGO,
                               CATESTPX.VALOR                       CATESTPX_VALOR,
                               CATESTPX.DESCRIPCION                 CATESTPX_DESCRIPCION,              
                               PREING.ESTADO_REGISTRO_ID            PRE_ESTADO_REGISTRO_ID, 
                               CATESTREG.CODIGO                     CATESTREG_CODIGO,          
                               CATESTREG.VALOR                      CATESTREG_VALOR,
                               CATESTREG.DESCRIPCION                CATESTREG_DESCRIPCION,
                               PREING.USUARIO_REGISTRO              PRE_USR_REGISTRO,             
                               PREING.FECHA_REGISTRO                PRE_FEC_REGISTRO,     
                               PREING.USUARIO_MODIFICACION          PRE_USR_MODIFICACION,      
                               PREING.FECHA_MODIFICACION            PRE_FEC_MODIFICACION,
                               PREING.USUARIO_PASIVA                PRE_USR_PASIVA,  
                               PREING.FECHA_PASIVA                  PRE_FEC_PASIVA,      
                               PREING.USUARIO_ELIMINA               PRE_USR_ELIMINA,        
                               PREING.FECHA_ELIMINA                 PRE_FEC_ELIMINA     
                          FROM HOSPITALARIO.SNH_MST_PREG_INGRESOS PREING         
                          JOIN CATALOGOS.SBC_CAT_CATALOGOS CATPROCED
                            ON CATPROCED.CATALOGO_ID = PREING.PROCEDENCIA_ID
                          JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL NOM
                            ON NOM.PER_NOMINAL_ID = PREING.PER_NOMINAL_ID
                          JOIN HOSPITALARIO.SNH_CAT_SERVICIOS SERV
                            ON SERV.SERVICIO_ID = PREING.SERVICIO_PROCEDENCIA_ID
                          JOIN HOSPITALARIO.SNH_CAT_SERVICIOS ESPDEST
                            ON ESPDEST.SERVICIO_ID = PREING.ESPECIALIDAD_DESTINO_ID                  
                          JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALORI
                            ON USALORI.UNIDAD_SALUD_ID = PREING.UNIDAD_SALUD_ORIGEN_ID
                          JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADVORI
                            ON ENTADVORI.ENTIDAD_ADTVA_ID = USALORI.ENTIDAD_ADTVA_ID
                          JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALDEST
                            ON USALDEST.UNIDAD_SALUD_ID = PREING.UNIDAD_SALUD_DESTINO_ID
                          JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADVDEST
                            ON ENTADVDEST.ENTIDAD_ADTVA_ID = USALDEST.ENTIDAD_ADTVA_ID                    
                          JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTPREING
                            ON CATESTPREING.CATALOGO_ID = PREING.ESTADO_PRE_INGRESO_ID  
                          JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTPX
                            ON CATESTPX.CATALOGO_ID = PREING.ESTADO_PX_ID                 
                          JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREG
                            ON CATESTREG.CATALOGO_ID = PREING.ESTADO_REGISTRO_ID
                          JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES MEDORDENAING
                            ON MEDORDENAING.MINSA_PERSONAL_ID = PREING.MEDICO_ORDENA_INGRESO_ID
                          JOIN CATALOGOS.SBC_MST_PERSONAS PER3
                            ON MEDORDENAING.PERSONA_ID = PER3.PERSONA_ID
                          JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD3
                            ON MPERSALUD3.MINSA_PERSONAL_ID = MEDORDENAING.MINSA_PERSONAL_ID
                          JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT3
                           ON CAT3.CATALOGO_ID = MEDORDENAING.TIPO_PERSONAL_ID                
                          JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES ADMINSOLINGRESO
                            ON ADMINSOLINGRESO.MINSA_PERSONAL_ID = PREING.ADMISIONISTA_SOLICITA_INGR_ID
                          JOIN CATALOGOS.SBC_MST_PERSONAS PER1
                            ON ADMINSOLINGRESO.PERSONA_ID = PER1.PERSONA_ID
                          LEFT JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD1
                            ON MPERSALUD1.MINSA_PERSONAL_ID = ADMINSOLINGRESO.MINSA_PERSONAL_ID
                          JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT1
                            ON CAT1.CATALOGO_ID = ADMINSOLINGRESO.TIPO_PERSONAL_ID               
                         WHERE PREING.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                      )
                                         )B
                        WHERE  A.ID = B.PRE_INGRESO_ID 
                      ORDER BY LINE_NUMBER);   
     RETURN vRegistro; 
 END FN_OBT_PREINGR_PAG;
               
 FUNCTION FN_OBT_DATOS_PRE_INGRESOS (pConsulta IN HOSPITALARIO.OBJ_PRE_INGRESO,
                                     pPgn      IN BOOLEAN, 
                                     pFuente   IN NUMBER) RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
 CASE
 WHEN pFuente = 1 THEN
      vRegistro := FN_OBT_PREINGR_ID (pConsulta.PregIngresoId);
 ELSE
      vRegistro := FN_OBT_PREINGR_PAG;
 END CASE;
 RETURN vRegistro;
 END FN_OBT_DATOS_PRE_INGRESOS;

 PROCEDURE PR_C_PRE_INGRESO (pConsulta        IN HOSPITALARIO.OBJ_PRE_INGRESO,
                             pPgn             IN NUMBER,
                             pPgnAct          IN NUMBER, 
                             pPgnTmn          IN NUMBER,
                             pDatosPaginacion OUT var_refcursor,
                             pRegistro        OUT var_refcursor,
                             pResultado       OUT VARCHAR2,
                             pMsgError        OUT VARCHAR2) IS
                              
 vFirma             VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_C_PRE_INGRESO => ';  
 vFuente            SIMPLE_INTEGER := 0;
 vPgn             BOOLEAN := TRUE;
 vFechaInicio     DATE;
 vFechaFin        DATE;
 vNombreCompleto  MAXVARCHAR2;
 vPrimerNombre    MAXVARCHAR2;
 vSegundoNombre   MAXVARCHAR2;
 vPrimerApellido  MAXVARCHAR2;
 vSegundoApellido MAXVARCHAR2;
 vSexo            MAXVARCHAR2;
 vUnidadSaludId   NUMBER;
 vMunicipioId     NUMBER;
 vEntAdminId      NUMBER;
 vCantRegistros   SIMPLE_INTEGER := 0;
 vPaginacion HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos;  
 BEGIN
     CASE
     WHEN (FN_VAL_EXISTE_PRE_INGRESO (pConsulta, vPgn, 
                                      vCantRegistros, vFuente)) = TRUE THEN 
            DBMS_OUTPUT.PUT_LINE ('Valida que existe pre regitro');                          
            CASE
            WHEN vPgn THEN
                        DBMS_OUTPUT.PUT_LINE ('Entra a paginación'); 
                 HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_INDC_PAGINACION_PERSONA(PREGISTROS  => vCantRegistros, 
                                                                            pPgnAct     => pPgnAct, 
                                                                            pPgnTmn     => pPgnTmn, 
                                                                            pPaginacion => vPaginacion, 
                                                                            pMsg        => pMsgError);
                 CASE 
                 WHEN pMsgError IS NOT NULL THEN 
                      pResultado := pMsgError;
                      pMsgError  := pMsgError;
                      RAISE eSalidaConError;
                 ELSE 
                      pDatosPaginacion := FN_OBT_DATOS_PAGINACION (pDatosPaginacion =>  vPaginacion); --pQuery =>  vQuery);
                 END CASE;            
                 PR_I_TABLA_TEMPORAL_PREGING (pConsulta        => pConsulta,
                                              pPgnAct          => pPgnAct,        
                                              pPgnTmn          => pPgnTmn,       
                                              pTipoPaginacion  => vFuente,
                                              pResultado       => pResultado,     
                                              pMsgError        => pMsgError); 
                                 dbms_output.put_line ('Error saliendo de I tabla temporal pre: '||pMsgError);              
                                 CASE
                                 WHEN pMsgError IS NOT NULL THEN 
                                      RAISE eSalidaConError;
                                 ELSE NULL;
                                 END CASE;
            ELSE NULL; 
            END CASE;                                      
           dbms_output.put_Line ('despues de validar existe pre registro');
           pRegistro := FN_OBT_DATOS_PRE_INGRESOS(pConsulta, vPgn, vFuente);
     ELSE
     CASE
     WHEN NVL(pConsulta.PregIngresoId,0) > 0 THEN
          pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Pre Ingreso Id: '||pConsulta.PregIngresoId||']';
          RAISE eRegistroNoExiste;
     WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
           NVL(pConsulta.ExpedienteId,0) > 0)  THEN
           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [pPerNominalId: '||pConsulta.PerNominalId||'] - [pExpedienteId: '||pConsulta.ExpedienteId||']';
           RAISE eRegistroNoExiste;
     WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Nominal Id: '||pConsulta.PerNominalId||']';
           RAISE eRegistroNoExiste;
     WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Expediente Id: '||pConsulta.ExpedienteId||']';
           RAISE eRegistroNoExiste;     
     WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [codigo expediente: '||pConsulta.CodExpElectronico||']';
           RAISE eRegistroNoExiste;
     WHEN pConsulta.Identificacion IS NOT NULL THEN
           pResultado := 'No se encontraron registros de pre ingresos relacionadas a la [Identificación: '||pConsulta.Identificacion||']';
           RAISE eRegistroNoExiste;
     WHEN (pConsulta.NombreCompleto IS NOT NULL AND
           NVL (pConsulta.UsalIngresoId,0) > 0) THEN
           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Nombre: '||pConsulta.NombreCompleto||'] - [Unidad salud destino: '||pConsulta.UsalIngresoId||']';
           RAISE eRegistroNoExiste;
     WHEN pConsulta.NombreCompleto IS NOT NULL THEN
           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Nombre: '||pConsulta.NombreCompleto||']';
           RAISE eRegistroNoExiste;
     WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Unidad salud destino: '||pConsulta.UsalIngresoId||']';
           RAISE eRegistroNoExiste;
     ELSE 
           pResultado := 'No se encontraron registros de pre ingresos';
           RAISE eRegistroNoExiste;
     END CASE;     
     END CASE;
 EXCEPTION
 WHEN eSalidaConError THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;  
 WHEN eRegistroNoExiste THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al querer obtener información de Pre registros ingresos egresos. [Id: '||pConsulta.PregIngresoId||'] - y [Id Expediente: '||pConsulta.ExpedienteId||']';
      pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_C_PRE_INGRESO;

 FUNCTION FN_OBT_COMUNIDAD_ID (pUsalDestinoId IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE) RETURN NUMBER AS
 vContador   SIMPLE_INTEGER := 0;
 vComunidadId CATALOGOS.SBC_CAT_COMUNIDADES.COMUNIDAD_ID%TYPE;
 BEGIN  
  SELECT COUNT (1)
    INTO vContador
    FROM CATALOGOS.SBC_CAT_UNIDADES_SALUD
   WHERE UNIDAD_SALUD_ID = pUsalDestinoId AND
         COMUNIDAD_ID IS NOT NULL;
   CASE
   WHEN vContador > 0 THEN
        BEGIN
         SELECT COMUNIDAD_ID
           INTO vComunidadId
           FROM CATALOGOS.SBC_CAT_UNIDADES_SALUD
          WHERE UNIDAD_SALUD_ID = pUsalDestinoId; 
        END;
   ELSE NULL;
   END CASE;
 RETURN vComunidadId;
 EXCEPTION 
 WHEN OTHERS THEN
      RETURN vComunidadId;
 END FN_OBT_COMUNIDAD_ID;  
 FUNCTION FN_OBT_DIV_POL_ID (pUsalDestinoId IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE) RETURN NUMBER AS
 vComunidadId CATALOGOS.SBC_CAT_COMUNIDADES.COMUNIDAD_ID%TYPE;
 vContador SIMPLE_INTEGER := 0;
 vDivPolId CATALOGOS.SBC_HST_DIVISION_POLITICAS.DIVISION_POLITICA_ID%TYPE;
 BEGIN
 vComunidadId := FN_OBT_COMUNIDAD_ID (pUsalDestinoId);
 CASE
 WHEN NVL(vComunidadId,0) > 0 THEN
      BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM CATALOGOS.SBC_HST_DIVISION_POLITICAS
         WHERE COMUNIDAD_ID = vComunidadId AND
               PASIVO = 0;
         CASE
         WHEN vContador = 1 THEN
              BEGIN
               SELECT DIVISION_POLITICA_ID
                 INTO vDivPolId
                 FROM CATALOGOS.SBC_HST_DIVISION_POLITICAS
                WHERE COMUNIDAD_ID = vComunidadId AND
                      PASIVO = 0;
              END;
         ELSE NULL;
         END CASE;
      END;
 ELSE NULL;
 END CASE;
 RETURN vDivPolId;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vDivPolId;
 END FN_OBT_DIV_POL_ID; 
 
 FUNCTION FN_OBT_SECTOR (vComunidadId IN  CATALOGOS.SBC_CAT_COMUNIDADES.COMUNIDAD_ID%TYPE) RETURN NUMBER AS
 vSectorId CATALOGOS.SBC_CAT_SECTORES.SECTOR_ID%TYPE;
 vContador SIMPLE_INTEGER := 0;
 BEGIN
  SELECT COUNT (1)
    INTO vContador
    FROM CATALOGOS.SBC_REL_SECTOR_COMUNIDADES
   WHERE COMUNIDAD_ID = vComunidadId AND 
         PASIVO = 0 AND
         SECTOR_ID IS NOT NULL;
   CASE
   WHEN vContador > 0 THEN
        BEGIN
         SELECT SECTOR_ID
           INTO vSectorId
           FROM CATALOGOS.SBC_REL_SECTOR_COMUNIDADES
          WHERE COMUNIDAD_ID = vComunidadId AND
                PASIVO = 0;
        END;
   ELSE NULL;
   END CASE;
   
 RETURN vSectorId;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vSectorId;
 END FN_OBT_SECTOR; 

 FUNCTION FN_OBT_RED_SERV_ID (pUsalDestinoId IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE) RETURN NUMBER AS
 vComunidadId CATALOGOS.SBC_CAT_COMUNIDADES.COMUNIDAD_ID%TYPE;
 vContador    SIMPLE_INTEGER := 0;
 vRedServlId  CATALOGOS.SBC_HST_RED_SERVICIOS.RED_SERVICIO_ID%TYPE;
 vSectorId    CATALOGOS.SBC_CAT_SECTORES.SECTOR_ID%TYPE;
 BEGIN
 vComunidadId := FN_OBT_COMUNIDAD_ID (pUsalDestinoId);
 CASE
 WHEN NVL(vComunidadId,0) > 0 THEN
      vSectorId := FN_OBT_SECTOR (vComunidadId); 
 ELSE NULL;
 END CASE;
 
 CASE
 WHEN NVL(vSectorId,0) > 0 THEN      
      BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM CATALOGOS.SBC_HST_RED_SERVICIOS
         WHERE UNIDAD_SALUD_ID = pUsalDestinoId AND
               COMUNIDAD_ID = vComunidadId AND
               SECTOR_ID = vSectorId AND
               PASIVO = 0;
         CASE
         WHEN vContador = 1 THEN
              BEGIN
               SELECT RED_SERVICIO_ID
                 INTO vRedServlId
                 FROM CATALOGOS.SBC_HST_RED_SERVICIOS
                WHERE UNIDAD_SALUD_ID = pUsalDestinoId AND
                      COMUNIDAD_ID = vComunidadId AND
                      SECTOR_ID = vSectorId AND
                      PASIVO = 0;
              END;
         ELSE NULL;
         END CASE;
      END;
 ELSE NULL;
 END CASE;
 RETURN vRedServlId;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vRedServlId;
 END FN_OBT_RED_SERV_ID;  
 
 FUNCTION FN_OBT_TIPO_INGRESO RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
   SELECT CATALOGO_ID
     INTO vCatalogoId
     FROM CATALOGOS.SBC_CAT_CATALOGOS
     WHERE CODIGO = 'TIPOINGEMRG|ESPONTANEO' AND
           PASIVO = 0;
 RETURN vCatalogoId;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vCatalogoId;
 END FN_OBT_TIPO_INGRESO;
 
 FUNCTION FN_OBT_ESTADO_ATENCION RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
   SELECT CATALOGO_ID
     INTO vCatalogoId
     FROM CATALOGOS.SBC_CAT_CATALOGOS
     WHERE CODIGO = 'ESTADM01' AND
           PASIVO = 0;
 RETURN vCatalogoId;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vCatalogoId;
 END FN_OBT_ESTADO_ATENCION;
 
 PROCEDURE PR_CRUD_PRE_INGRESO (pPregIngresoId      IN OUT HOSPITALARIO.SNH_MST_PREG_INGRESOS.PREG_INGRESO_ID%TYPE,
                                pAdmisionId         IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISION_ID%TYPE,
                                pProcedenciaId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.PROCEDENCIA_ID%TYPE,
                                pPerNominalId       IN CATALOGOS.SBC_MST_PERSONAS_NOMINAL.PER_NOMINAL_ID%TYPE,
                                pCodExpElectronico  IN CATALOGOS.SBC_MST_PERSONAS_NOMINAL.CODIGO_EXPEDIENTE_ELECTRONICO%TYPE,
                                pExpedienteId       IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE,
                                pNomCompletoPx      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.NOMBRE_COMPLETO_PX%TYPE,
                                pMedOrdenaIngId     IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE,
                                pUsalOrigenId       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_ORIGEN_ID%TYPE,
                                pServProcedenId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE,
                                pAdminSolicIngId    IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE,
                                pFecSolicitaIng     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.FECHA_SOLICITUD_INGRESO%TYPE,
                                pHrSolicitudIng     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.HORA_SOLICITUD_INGRESO%TYPE,
                                pUsalDestinoId      IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.UNIDAD_SALUD_DESTINO_ID%TYPE,
                                pReferenciaId       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.REFERENCIA_ID%TYPE,
                                pEspDestinoId       IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESPECIALIDAD_DESTINO_ID%TYPE,
                                pEstadoPreIngId     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PRE_INGRESO_ID%TYPE,
                                pComentarios        IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.COMENTARIOS%TYPE,
                                pTipIdentiId        IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.TIPO_IDENTIFICACION_ID%TYPE,
                                pIdentificacion     IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.IDENTIFICACION%TYPE,
                                pEstadoPxId         IN HOSPITALARIO.SNH_MST_PREG_INGRESOS.ESTADO_PX_ID%TYPE,
                                pUsuario            IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,    
                                pFecInicio          IN DATE,
                                pFecFin             IN DATE,
                                pAccionEstado       IN VARCHAR2,
                                pTipoAccion         IN VARCHAR2,
                                pPgn                IN NUMBER,
                                pPgnAct             IN NUMBER default 1,  
                                pPgnTmn             IN NUMBER default 100,
                                pDatosPaginacion    OUT var_refcursor,
                                -- pJson               IN VARCHAR2,
                                pRegistro           OUT var_refcursor,
                                pResultado          OUT VARCHAR2,
                                pMsgError           OUT VARCHAR2) IS
      
 vFirma             MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_PRE_INGRESO => ';
 vResultado         MAXVARCHAR2;
 vEstadoRegistroId  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 vFecSolicitaIng    HOSPITALARIO.SNH_MST_PREG_INGRESOS.FECHA_SOLICITUD_INGRESO%TYPE := to_date (pFecSolicitaIng,'dd/mm/rrrr');
 vConsulta          HOSPITALARIO.OBJ_PRE_INGRESO;

 vAdmisionId      SNH_MST_ADMISIONES.ADMISION_ID%TYPE;
 vAdminServId     SNH_MST_ADMISION_SERVICIOS.ADMISION_SERVICIO_ID%TYPE;      
 vCodigo          SNH_MST_ADMISIONES.CODIGO%TYPE;
 vExpedienteLocal SNH_MST_ADMISIONES.EXPEDIENTE_LOCAL%TYPE;
 vTipoIngresoId   SNH_MST_ADMISIONES.TIPO_INGRESO_ID%TYPE; -- := 1236;

 vPxResidenciaId  SNH_MST_ADMISIONES.PX_RESIDENCIA_ID%TYPE;
 vPxContactoUrgId SNH_MST_ADMISIONES.PX_CONTACTO_URGENCIA_ID%TYPE;
 vMPersonalId     SNH_MST_ADMISIONES.MINSA_PERSONAL_ID%TYPE;

 vDependenciaId   SNH_MST_ADMISIONES.DEPENDENCIA_ID%TYPE;
 vDivPolO         SNH_MST_ADMISIONES.DIVPOLO_ID%TYPE;
 vDivPolR         SNH_MST_ADMISIONES.DIVPOLR_ID%TYPE;
 vRedSrvO         SNH_MST_ADMISIONES.REDSRVO_ID%TYPE;
 vRedSrvR         SNH_MST_ADMISIONES.REDSRVR_ID%TYPE;
 vReingreso       SNH_MST_ADMISIONES.REINGRESO%TYPE;

 vEstadoR         SNH_MST_ADMISIONES.ESTADO%TYPE := vGLOBAL_ESTADO_ACTIVO;
 vProcedencia     SNH_MST_ADMISIONES.SISTEMA_PROCEDENCIA%TYPE;
 vTurnoId         SNH_MST_TURNO.TURNO_ID%TYPE;
 vMotivo          SNH_MST_ADMISIONES.MOTIVO_VISITA%TYPE; 
 vEmbarazo        SNH_MST_ADMISIONES.EMBARAZO%TYPE; 
 vEstadoAtencion  SNH_MST_ADMISIONES.ESTADO_ADMISION%TYPE; 
 vGrupoEtareoId   SNH_MST_ADMISIONES.GRUPO_ETAREO_ID%TYPE; 
 vTipoTransporte  SNH_MST_ADMISIONES.LLEGO_EN%TYPE;
 vPrimerAtencion  MAXVARCHAR2;
 vDomicilio       SNH_MST_ADMISIONES.DOMICILIO%TYPE;
 vRegistro        var_refcursor; 
 BEGIN
--           pResultado := 'Entra al paquete';
--           pMsgError  := pResultado;
--           RAISE eParametroNull;
      CASE
      WHEN pTipoAccion IS NULL THEN 
           pResultado := 'El párametro pTipoAccion no puede venir NULL';
           pMsgError  := pResultado;
           RAISE eParametroNull;
      ELSE NULL;
      END CASE;
      
      CASE
      WHEN pTipoAccion = kINSERT THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;
           dbms_output.put_line ('Sale de validar usuario');

           CASE
           WHEN NVL(pExpedienteId,0) = 0 THEN
                pResultado := 'El expedienteId no puede venir nulo'; 
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE NULL;
           END CASE;
            CASE
            WHEN NVL(pAdmisionId,0) = 0 THEN
            CASE
            WHEN NVL(pUsalDestinoId,0) > 0 THEN
                 vDivPolO        := FN_OBT_DIV_POL_ID (pUsalDestinoId);
                 vRedSrvO        := FN_OBT_RED_SERV_ID (pUsalDestinoId);
                 vTipoIngresoId  := FN_OBT_TIPO_INGRESO;
                 vEstadoAtencion := FN_OBT_ESTADO_ATENCION;
                 dbms_output.put_line ('pUsuario: '||pUsuario);
 
                 dbms_output.put_line ('vTipoIngresoId: '||vTipoIngresoId);
                 dbms_output.put_line ('pUsalDestinoId: '||pUsalDestinoId);
                 dbms_output.put_line ('pExpedienteId: '||pExpedienteId);
                 dbms_output.put_line ('vDivPolO: '||vDivPolO);
                 dbms_output.put_line ('vRedSrvO: '||vRedSrvO);
                 dbms_output.put_line ('pFecSolicitaIng: '||pFecSolicitaIng);
                 dbms_output.put_line ('vEstadoR: '||vEstadoR);
                 dbms_output.put_line ('vProcedencia: '||vProcedencia);
                 dbms_output.put_line ('vEstadoAtencion: '||vEstadoAtencion);

            ELSE NULL;
            END CASE;
                 HOSPITALARIO.PKG_SNH_EMERGENCIA.SNH_CRUD_ADMISION (pUsrName         => pUsuario,          --            
                                                                    pAdmisionId      => vAdmisionId,                    
                                                                    pCodigo          => vCodigo,          
                                                                    pExpedienteLocal => vExpedienteLocal, 
                                                                    pTipoIngresoId   => vTipoIngresoId,    --
                                                                    pExpedienteId    => pExpedienteId,     -- 
                                                                    pPxResidenciaId  => vPxResidenciaId,  
                                                                    pPxContactoUrgId => vPxContactoUrgId, 
                                                                    pMPersonalId     => vMPersonalId,     
                                                                    pUndSaludId      => pUsalDestinoId,      --
                                                                    pDependenciaId   => vDependenciaId,   
                                                                    pDivPolO         => vDivPolO,         -- 
                                                                    pDivPolR         => vDivPolR,         
                                                                    pRedSrvO         => vRedSrvO,         --
                                                                    pRedSrvR         => vRedSrvR,         
                                                                    pReingreso       => vReingreso,       
                                                                    pFechaIngreso    => pFecSolicitaIng,    --
                                                                    pEstado          => vEstadoR,         -- 
                                                                    pProcedencia     => vProcedencia,     --
                                                                    pTurnoId         => vTurnoId ,
                                                                    pEmbarazo        => vEmbarazo ,
                                                                    pEstadoAtencion  => vEstadoAtencion,  --
                                                                    pGrupoEtareoId   => vGrupoEtareoId,
                                                                    pTipoTransporte  => vTipoTransporte ,
                                                                    pPrimerAtencion  => vPrimerAtencion ,
                                                                    pDomicilio       => vDomicilio,
                                                                    pTipoOperacion   => kINSERT,   --
                                                                    pMotivo          => vMotivo,
                                                                    pRegistro        => vRegistro,
                                                                    pResultado       => pResultado,
                                                                    pMsgError        => pMsgError 
                                                                   );
                                CASE
                                WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                                     RAISE eSalidaConError;  
                                ELSE NULL;
                                END CASE;   
          /* INCIO - Bloque agregado por FHERNANDEZ - 20211210*/
            --Crear registro de la tabla admision Servicio
            --Si no se realiza el insert sobre la tabla de admision_servicio, la búsqueda de Admisión Quiebra
            
            HOSPITALARIO.PKG_SNH_EMERGENCIA.SNH_CRUD_ADMISION_SERVICIO (pUsrName        => pUsuario ,
                                                                        pAdmisionServId => vAdminServId ,
                                                                        pAdmisionId     => vAdmisionId,
                                                                        --Corregir esta lógica pues el parámetro [pServicioId] espera un ID de la tabla
                                                                        --[hospitalario.snh_cat_servicios], y no el ID del catálogo INGRESOPOR
                                                                        pServicioId     => case 
                                                                                           when pProcedenciaId = 1206 then 
                                                                                                76 
                                                                                           else 85 
                                                                                           end,--vTipoIngresoId,
                                                                        --Como no se recibe el código del catálogo, entonces puse el caso por ID
                                                                        --Lo cual puede chocar entre ambiente
                                                                        pMPerSaludId    => vMPersonalId,
                                                                        pDependenciaId  => NULL,
                                                                        pFechaIni       => pFecSolicitaIng,
                                                                        pFechaFin       => NULL,
                                                                        pEstado         => vEstadoR ,
                                                                        pEsPrincipal    => 1,
                                                                        pEspecialidad   => NULL,
                                                                        pTipoOperacion  => kINSERT,
                                                                        pRegistro       => vRegistro,
                                                                        pResultado      => pResultado,
                                                                        pMsgError       => pMsgError);
                                            
                CASE
                    WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                        RAISE eSalidaConError;  
                        ELSE NULL;
                END CASE; 
            /* FIN - Bloque agregado por FHERNANDEZ - 20211210*/                                    

            ELSE 
            vAdmisionId := pAdmisionId;
            END CASE;
           dbms_output.put_line ('vFecSolicitaIng: '||vFecSolicitaIng);
           dbms_output.put_line ('vAdmisionId: '||vAdmisionId);
           
            PR_I_PRE_INGRESO (pPregIngresoId     => pPregIngresoId,            
                              pAdmisionId        => vAdmisionId,  --pAdmisionId,               
                              pProcedenciaId     => pProcedenciaId,            
                              pPerNominalId      => pPerNominalId,             
                              pCodExpElectronico => pCodExpElectronico,        
                              pExpedienteId      => pExpedienteId,             
                              pNomCompletoPx     => pNomCompletoPx,            
                              pMedOrdenaIngId    => pMedOrdenaIngId,           
                              pServProcedenId    => pServProcedenId,              
                              pEspDestinoId      => pEspDestinoId,              
                              pAdminSolicIngId   => pAdminSolicIngId,                           
                              pFecSolicitaIng    => pFecSolicitaIng,          
                              pHrSolicitudIng    => pHrSolicitudIng,           
                              pUsalOrigenId      => pUsalOrigenId,           
                              pUsalDestinoId     => pUsalDestinoId,            
                              pReferenciaId      => pReferenciaId,             
                              pEstadoPreIngId    => pEstadoPreIngId,                        
                              pComentarios       => pComentarios,           
                              pTipIdentiId       => pTipIdentiId,     
                              pIdentificacion    => pIdentificacion,              
                              pEstadoPxId        => pEstadoPxId,           
                              pUsuario           => pUsuario,                  
                              pResultado         => pResultado,             
                              pMsgError          => pMsgError);  
                              dbms_output.put_line ('error saliendo de insert ingreso: '||pMsgError);              
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            WHEN NVL(pPregIngresoId,0) > 0 THEN
                 dbms_output.put_line ('Antes de llamar a la consulta de crear pre ingreso: '||pPregIngresoId); 
                 PR_C_PRE_INGRESO (pConsulta        => HOSPITALARIO.OBJ_PRE_INGRESO (pPregIngresoId,     --PregIngresoId    
                                                                                     vAdmisionId,        --pAdmisionId,        --AdmisionId       
                                                                                     pProcedenciaId,     --ProcedenciaId    
                                                                                     pPerNominalId,      --PerNominalId     
                                                                                     pExpedienteId,      --ExpedienteId     
                                                                                     pNomCompletoPx,     --NombreCompleto   
                                                                                     pCodExpElectronico, --CodExpElectronico
                                                                                     pIdentificacion,    --Identificacion   
                                                                                     pMedOrdenaIngId,    --MedOrdenaIngId   
                                                                                     pServProcedenId,    --ServProcedenId   
                                                                                     pAdminSolicIngId,   --AdminSolicIngId  
                                                                                     pFecInicio,         --FecInicio        
                                                                                     pFecFin,            --FecFin           
                                                                                     pUsalDestinoId,     --UsalIngresoId    
                                                                                     pUsalOrigenId,      --UsalProcedeId    
                                                                                     pReferenciaId,      --ReferenciaId     
                                                                                     pEstadoPreIngId,    --EstadoPreIngId   
                                                                                     pEstadoPxId        --EstadoPxId       
                                                                                        ),
                                   pPgn             => pPgn,             
                                   pPgnAct          => pPgnAct,         
                                   pPgnTmn          => pPgnTmn,         
                                   pDatosPaginacion => pDatosPaginacion,
                                   pRegistro        => pRegistro,          
                                   pResultado       => pResultado,         
                                   pMsgError        => pMsgError);    
                                   dbms_output.put_line ('error saliendo de consulta ingreso: '||pMsgError);       
                 CASE
                 WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                     RAISE eSalidaConError;
                 ELSE 
                     vResultado := 'Se crea exitosamente el registro de pre ingreso hospitalario [Id]: '||pPregIngresoId||', devolviendo el JSon de este';
                 END CASE;
            ELSE NULL;     
            END CASE; 
      WHEN pTipoAccion = kUPDATE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;      
                      
           CASE
           WHEN pAccionEstado = 0 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_ACTIVO;
           WHEN pAccionEstado = 1 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_PASIVO;
           ELSE NULL;
           END CASE;
           PR_U_PRE_INGRESO (pPregIngresoId     => pPregIngresoId,    
                             pAdmisionId        => pAdmisionId,       
                             pProcedenciaId     => pProcedenciaId,    
                             pPerNominalId      => pPerNominalId,     
                             pCodExpElectronico => pCodExpElectronico,
                             pExpedienteId      => pExpedienteId,     
                             pNomCompletoPx     => pNomCompletoPx,    
                             pMedOrdenaIngId    => pMedOrdenaIngId,   
                             pServProcedenId    => pServProcedenId,   
                             pEspDestinoId      => pEspDestinoId,     
                             pAdminSolicIngId   => pAdminSolicIngId,  
                             pFecSolicitaIng    => pFecSolicitaIng,   
                             pHrSolicitudIng    => pHrSolicitudIng,   
                             pUsalOrigenId      => pUsalOrigenId,     
                             pUsalDestinoId     => pUsalDestinoId,    
                             pReferenciaId      => pReferenciaId,     
                             pEstadoPreIngId    => pEstadoPreIngId,   
                             pComentarios       => pComentarios,      
                             pTipIdentiId       => pTipIdentiId,      
                             pIdentificacion    => pIdentificacion,   
                             pEstadoPxId        => pEstadoPxId,       
                             pEstadoRegistroId  => vEstadoRegistroId, 
                             pUsuario           => pUsuario,          
                             pResultado         => pResultado,        
                             pMsgError          => pMsgError);         
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            ELSE 
               CASE
               WHEN NVL(pPregIngresoId,0) > 0 THEN
               -- se realiza consulta de datos luego de realizar la actualización de persona
                    PR_C_PRE_INGRESO (pConsulta        => HOSPITALARIO.OBJ_PRE_INGRESO (pPregIngresoId,     --PregIngresoId    
                                                                                        pAdmisionId,        --AdmisionId       
                                                                                        pProcedenciaId,     --ProcedenciaId    
                                                                                        pPerNominalId,      --PerNominalId     
                                                                                        pExpedienteId,      --ExpedienteId     
                                                                                        pNomCompletoPx,     --NombreCompleto   
                                                                                        pCodExpElectronico, --CodExpElectronico
                                                                                        pIdentificacion,    --Identificacion   
                                                                                        pMedOrdenaIngId,    --MedOrdenaIngId   
                                                                                        pServProcedenId,    --ServProcedenId   
                                                                                        pAdminSolicIngId,   --AdminSolicIngId  
                                                                                        pFecInicio,          --FecInicio        
                                                                                        pFecFin,             --FecFin           
                                                                                        pUsalDestinoId,     --UsalIngresoId    
                                                                                        pUsalOrigenId,      --UsalProcedeId    
                                                                                        pReferenciaId,      --ReferenciaId     
                                                                                        pEstadoPreIngId,    --EstadoPreIngId   
                                                                                        pEstadoPxId        --EstadoPxId       
                                                                                           ),
                                      pPgn             => pPgn,             
                                      pPgnAct          => pPgnAct,         
                                      pPgnTmn          => pPgnTmn,         
                                      pDatosPaginacion => pDatosPaginacion,
                                      pRegistro        => pRegistro,          
                                      pResultado       => pResultado,         
                                      pMsgError        => pMsgError);           
                   CASE
                   WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                        RAISE eSalidaConError;
                   ELSE vResultado := 'Se actualiza exitosamente el registro de pre ingreso hospitalario [Id]: '||pPregIngresoId||', devolviendo el JSon de este';
                   END CASE;          
               ELSE NULL;    
               END CASE;                 
            END CASE;           
      WHEN pTipoAccion = kCONSULTAR THEN
           PR_C_PRE_INGRESO (pConsulta        => HOSPITALARIO.OBJ_PRE_INGRESO (pPregIngresoId,     --PregIngresoId    
                                                                               pAdmisionId,        --AdmisionId       
                                                                               pProcedenciaId,     --ProcedenciaId    
                                                                               pPerNominalId,      --PerNominalId     
                                                                               pExpedienteId,      --ExpedienteId     
                                                                               pNomCompletoPx,     --NombreCompleto   
                                                                               pCodExpElectronico, --CodExpElectronico
                                                                               pIdentificacion,    --Identificacion   
                                                                               pMedOrdenaIngId,    --MedOrdenaIngId   
                                                                               pServProcedenId,    --ServProcedenId   
                                                                               pAdminSolicIngId,   --AdminSolicIngId  
                                                                               pFecInicio,         --FecInicio        
                                                                               pFecFin,            --FecFin           
                                                                               pUsalDestinoId,     --UsalIngresoId    
                                                                               pUsalOrigenId,      --UsalProcedeId    
                                                                               pReferenciaId,      --ReferenciaId     
                                                                               pEstadoPreIngId,    --EstadoPreIngId   
                                                                               pEstadoPxId        --EstadoPxId       
                                                                                  ),
                             pPgn             => pPgn,             
                             pPgnAct          => pPgnAct,         
                             pPgnTmn          => pPgnTmn,         
                             pDatosPaginacion => pDatosPaginacion,
                             pRegistro        => pRegistro,          
                             pResultado       => pResultado,         
                             pMsgError        => pMsgError);             
           CASE
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Consulta realizada con éxito';
      WHEN pTipoAccion = kDELETE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;     
           CASE
           WHEN NVL(pPregIngresoId,0) > 0 THEN
           PR_U_PRE_INGRESO (pPregIngresoId     => pPregIngresoId,    
                             pAdmisionId        => pAdmisionId,       
                             pProcedenciaId     => pProcedenciaId,    
                             pPerNominalId      => pPerNominalId,     
                             pCodExpElectronico => pCodExpElectronico,
                             pExpedienteId      => pExpedienteId,     
                             pNomCompletoPx     => pNomCompletoPx,    
                             pMedOrdenaIngId    => pMedOrdenaIngId,   
                             pServProcedenId    => pServProcedenId,   
                             pEspDestinoId      => pEspDestinoId,     
                             pAdminSolicIngId   => pAdminSolicIngId,  
                             pFecSolicitaIng    => pFecSolicitaIng,   
                             pHrSolicitudIng    => pHrSolicitudIng,   
                             pUsalOrigenId      => pUsalOrigenId,     
                             pUsalDestinoId     => pUsalDestinoId,    
                             pReferenciaId      => pReferenciaId,     
                             pEstadoPreIngId    => pEstadoPreIngId,   
                             pComentarios       => pComentarios,      
                             pTipIdentiId       => pTipIdentiId,      
                             pIdentificacion    => pIdentificacion,   
                             pEstadoPxId        => pEstadoPxId,       
                             pEstadoRegistroId  => vGLOBAL_ESTADO_ELIMINADO, 
                             pUsuario           => pUsuario,          
                             pResultado         => pResultado,        
                             pMsgError          => pMsgError);                  

            CASE 
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            ELSE NULL;
            END CASE;
           vResultado := 'Registro eliminado con éxito'; 
           ELSE 
               pResultado := 'No hay registros para eliminar con el Id: '||pPregIngresoId;
               pMsgError  := pResultado;
               RAISE eUpdateInvalido;    
           END CASE; 
      ELSE 
          pResultado := 'El Tipo acción no es un parámetro valido.';
          pMsgError  := pResultado;
          RAISE eParametrosInvalidos;
      END CASE;
      pResultado := vResultado; 
      dbms_output.put_line ('Resultado: Id: '||pPregIngresoId||' - '||pResultado);    
 EXCEPTION
    WHEN eUpdateInvalido THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;      
    WHEN eParametroNull THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroNoExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;                       
    WHEN eParametrosInvalidos THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pResultado;
    WHEN eSalidaConError THEN
         pResultado := pResultado;  --vResultado;
         pMsgError  := vFirma||pMsgError;  --vMsgError;
    WHEN OTHERS THEN
         pResultado := 'Error no controlado';
         pMsgError  := vFirma||pResultado||' - '||SQLERRM;            
 END PR_CRUD_PRE_INGRESO;
 
 PROCEDURE PR_I_INGRESO (pIngresoId         OUT SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE,                                         
                         pPregIngresoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PREG_INGRESO_ID%TYPE,                     
                         pPerNominalId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PER_NOMINAL_ID%TYPE,                
                         pProcedenciaId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PROCEDENCIA_ID%TYPE,                
                         pAdmisionId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISION_SERVICIO_ID%TYPE,                     
                         pEdadExactaIng     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.EDAD_EXACTA_INGRESO%TYPE,           
                         pGrupoEtareoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.GRUPO_ETAREO_ID%TYPE,               
                         pMedicoIngId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_INGRESO_ID%TYPE,             
                         pAdminSolicIngId   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_SOLICITA_INGR_ID%TYPE, 
                         pAdmisionistaIngId IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_INGRESO_ID%TYPE,       
                         pMedOrdenaIngId    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_ORDENA_INGRESO_ID%TYPE,      
                         pServProcedenId    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE,       
                         pReingreso         IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO%TYPE,                     
                         pReingresoId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO_ID%TYPE,                  
                         pFecSolicitaIng    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_SOLICITUD_INGRESO%TYPE,       
                         pHrSolicitudIng    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_SOLICITUD_INGRESO%TYPE,        
                         pFecInicioIngreso  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_INICIO_INGRESO%TYPE,          
                         pHrInicioIngreso   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_INICIO_INGRESO%TYPE,           
                         pUsalIngresoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.UNIDAD_SALUD_INGRESO%TYPE,          
                         pServIngresoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_INGRESO_ID%TYPE,           
                         pEstadoIngId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_INGRESO_ID%TYPE,             
                         pTipoEgresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.TIPO_EGRESO_ID%TYPE,                
                         pFecFinIngreso     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_FIN_INGRESO%TYPE,             
                         pHrFinIngreso      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_FIN_INGRESO%TYPE,              
                         pServEgresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_EGRESO_ID%TYPE,            
                         pMedicoEgresoId    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_EGRESO_ID%TYPE,              
                         pReferenciaId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REFERENCIA_ID%TYPE,                 
                         pEsContraferido    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ES_CONTRAFERIDO%TYPE,               
                         pEnvContrareferId  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ENVIO_CONTRAREFERENCIA_ID%TYPE,     
                         pDiasEstancia      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.DIAS_ESTANCIA%TYPE,                 
                         pEstadoPxId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_ID%TYPE,                  
                         pEstadoPxEgresoId  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_EGRESO_ID%TYPE,           
                         pComentarios       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.COMENTARIOS%TYPE,                   
                         pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                         pResultado         OUT VARCHAR2,
                         pMsgError          OUT VARCHAR2) IS
                         
 vFirma            MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_I_INGRESO => ';
 vDatosPaginacion var_refcursor;
 vRegistro        var_refcursor;
 vPregIngresoId    HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PREG_INGRESO_ID%TYPE := pPregIngresoId;
 BEGIN
   INSERT INTO SNH_MST_INGRESOS_EGRESOS (PREG_INGRESO_ID,              
                                         PER_NOMINAL_ID,               
                                         PROCEDENCIA_ID,               
                                         ADMISION_SERVICIO_ID,         
                                         EDAD_EXACTA_INGRESO,          
                                         GRUPO_ETAREO_ID,              
                                         MEDICO_INGRESO_ID,            
                                         ADMISIONISTA_SOLICITA_INGR_ID,
                                         ADMISIONISTA_INGRESO_ID,      
                                         MEDICO_ORDENA_INGRESO_ID,     
                                         SERVICIO_PROCEDENCIA_ID,      
                                         REINGRESO,                    
                                         REINGRESO_ID,                 
                                         FECHA_SOLICITUD_INGRESO,      
                                         HORA_SOLICITUD_INGRESO,       
                                         FECHA_INICIO_INGRESO,         
                                         HORA_INICIO_INGRESO,          
                                         UNIDAD_SALUD_INGRESO,         
                                         SERVICIO_INGRESO_ID,          
                                         ESTADO_INGRESO_ID,            
                                         TIPO_EGRESO_ID,               
                                         FECHA_FIN_INGRESO,            
                                         HORA_FIN_INGRESO,             
                                         SERVICIO_EGRESO_ID,           
                                         MEDICO_EGRESO_ID,             
                                         REFERENCIA_ID,                
                                         ES_CONTRAFERIDO,              
                                         ENVIO_CONTRAREFERENCIA_ID,    
                                         DIAS_ESTANCIA,                
                                         ESTADO_PX_ID,                 
                                         ESTADO_PX_EGRESO_ID,          
                                         COMENTARIOS,                  
                                         ESTADO_REGISTRO_ID,           
                                         USUARIO_REGISTRO)             
                                 VALUES (pPregIngresoId,     
                                         pPerNominalId,     
                                         pProcedenciaId,    
                                         pAdmisionId,       
                                         pEdadExactaIng,    
                                         pGrupoEtareoId,    
                                         pMedicoIngId,      
                                         pAdminSolicIngId,  
                                         pAdmisionistaIngId,
                                         pMedOrdenaIngId,   
                                         pServProcedenId,   
                                         pReingreso,        
                                         pReingresoId,      
                                         pFecSolicitaIng,   
                                         pHrSolicitudIng,   
                                         pFecInicioIngreso, 
                                         pHrInicioIngreso,  
                                         pUsalIngresoId,    
                                         pServIngresoId,    
                                         pEstadoIngId,      
                                         pTipoEgresoId,     
                                         pFecFinIngreso,    
                                         pHrFinIngreso,     
                                         pServEgresoId,     
                                         pMedicoEgresoId,   
                                         pReferenciaId,     
                                         pEsContraferido,   
                                         pEnvContrareferId, 
                                         pDiasEstancia,     
                                         pEstadoPxId,       
                                         pEstadoPxEgresoId, 
                                         pComentarios, 
                                         vGLOBAL_ESTADO_ACTIVO,     
                                         pUsuario)
                                         RETURNING INGRESO_ID INTO pIngresoId;
            CASE
            WHEN NVL(pIngresoId,0) > 0 THEN          
                 PR_CRUD_PRE_INGRESO (pPregIngresoId     => vPregIngresoId,                  
                                      pAdmisionId        => null,                         
                                      pProcedenciaId     => null,                         
                                      pPerNominalId      => null,                         
                                      pCodExpElectronico => null,                         
                                      pExpedienteId      => null,                         
                                      pNomCompletoPx     => null,                         
                                      pMedOrdenaIngId    => null,                         
                                      pUsalOrigenId      => null,                         
                                      pServProcedenId    => null,                         
                                      pAdminSolicIngId   => null,                         
                                      pFecSolicitaIng    => null,                         
                                      pHrSolicitudIng    => null,                         
                                      pUsalDestinoId     => null,                         
                                      pReferenciaId      => null,                         
                                      pEspDestinoId      => null,                         
                                      pEstadoPreIngId    => vGLOBAL_ESTPREING_INGRESADO,  
                                      pComentarios       => null,                         
                                      pTipIdentiId       => null,                         
                                      pIdentificacion    => null,                         
                                      pEstadoPxId        => null,                         
                                      pUsuario           => pUsuario,
                                      pFecInicio         => null, 
                                      pFecFin            => null,
                                      pAccionEstado      => null,     
                                      pTipoAccion        => kUPDATE, 
                                      pPgn               => null,         
                                     -- pPgnAct            => null,
                                     -- pPgnTmn            => null,
                                      pDatosPaginacion   => vDatosPaginacion,
                                      pRegistro          => vRegistro,
                                      pResultado         => pResultado,
                                      pMsgError          => pMsgError);

                CASE 
                WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                     RAISE eSalidaConError;
                ELSE NULL;
                END CASE;
            ELSE NULL;
            END CASE;    

   pResultado := 'Registro creado con éxito. [Id:'||pIngresoId||']';  
   dbms_output.put_line ('pIngresoId: '||pIngresoId);      
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;
 WHEN eRegistroExiste THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;     
 WHEN OTHERS THEN
      dbms_output.put_line ('when others: '||sqlerrm);
      pResultado := 'Error al crear el registro persona';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;  
 END PR_I_INGRESO; 

 PROCEDURE PR_U_INGRESO (pIngresoId         IN SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE,                                         
                         pPregIngresoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PREG_INGRESO_ID%TYPE,                     
                         pPerNominalId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PER_NOMINAL_ID%TYPE,                
                         pProcedenciaId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PROCEDENCIA_ID%TYPE,                
                         pAdmisionId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISION_SERVICIO_ID%TYPE,                     
                         pEdadExactaIng     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.EDAD_EXACTA_INGRESO%TYPE,           
                         pGrupoEtareoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.GRUPO_ETAREO_ID%TYPE,               
                         pMedicoIngId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_INGRESO_ID%TYPE,             
                         pAdminSolicIngId   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_SOLICITA_INGR_ID%TYPE, 
                         pAdmisionistaIngId IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_INGRESO_ID%TYPE,       
                         pMedOrdenaIngId    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_ORDENA_INGRESO_ID%TYPE,      
                         pServProcedenId    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE,       
                         pReingreso         IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO%TYPE,                     
                         pReingresoId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO_ID%TYPE,                  
                         pFecSolicitaIng    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_SOLICITUD_INGRESO%TYPE,       
                         pHrSolicitudIng    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_SOLICITUD_INGRESO%TYPE,        
                         pFecInicioIngreso  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_INICIO_INGRESO%TYPE,          
                         pHrInicioIngreso   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_INICIO_INGRESO%TYPE,           
                         pUsalIngresoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.UNIDAD_SALUD_INGRESO%TYPE,          
                         pServIngresoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_INGRESO_ID%TYPE,           
                         pEstadoIngId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_INGRESO_ID%TYPE,             
                         pTipoEgresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.TIPO_EGRESO_ID%TYPE,                
                         pFecFinIngreso     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_FIN_INGRESO%TYPE,             
                         pHrFinIngreso      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_FIN_INGRESO%TYPE,              
                         pServEgresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_EGRESO_ID%TYPE,            
                         pMedicoEgresoId    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_EGRESO_ID%TYPE,              
                         pReferenciaId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REFERENCIA_ID%TYPE,                 
                         pEsContraferido    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ES_CONTRAFERIDO%TYPE,               
                         pEnvContrareferId  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ENVIO_CONTRAREFERENCIA_ID%TYPE,     
                         pDiasEstancia      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.DIAS_ESTANCIA%TYPE,                 
                         pEstadoPxId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_ID%TYPE,                  
                         pEstadoPxEgresoId  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_EGRESO_ID%TYPE,           
                         pComentarios       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.COMENTARIOS%TYPE,                   
                         pEstadoRegistroId  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_REGISTRO_ID%TYPE,
                         pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                         pResultado         OUT VARCHAR2,
                         pMsgError          OUT VARCHAR2) IS
                         
 vFirma MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_U_INGRESO => ';
 BEGIN
     CASE
     WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ELIMINADO THEN
         <<EliminaRegistro>>
          BEGIN
             UPDATE HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                SET ESTADO_REGISTRO_ID   = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,
                    USUARIO_ELIMINA      = pUsuario,
                    FECHA_ELIMINA        = CURRENT_TIMESTAMP
              WHERE INGRESO_ID = pIngresoId;
          EXCEPTION
             WHEN OTHERS THEN
                  pResultado := 'Error no controlado al eliminar registro [pIngresoId] - '||pIngresoId;
                  pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                  RETURN;                
          END EliminaRegistro;
          pResultado := 'Se ha eliminado el registro. [Id:'||pIngresoId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_PASIVO THEN
         <<PasivaRegistro>>       
         BEGIN
            UPDATE  HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                SET ESTADO_REGISTRO_ID = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,  
                    USUARIO_PASIVA       = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                           ELSE USUARIO_PASIVA
                                           END,    
                    FECHA_PASIVA         = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                           ELSE FECHA_PASIVA
                                           END
             WHERE INGRESO_ID = pIngresoId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;     
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al pasivar registro [pIngresoId] - '||pIngresoId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END PasivaRegistro;
         pResultado := 'Se ha pasivado el registro. [Id:'||pIngresoId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN
          <<ActivarRegistro>>
         BEGIN
            UPDATE HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
               SET ESTADO_REGISTRO_ID   = pEstadoRegistroId, 
                   USUARIO_MODIFICACION = pUsuario,    
                   USUARIO_PASIVA       = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                          ELSE USUARIO_PASIVA
                                          END,    
                   FECHA_PASIVA         = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                          ELSE FECHA_PASIVA
                                          END
             WHERE INGRESO_ID = pIngresoId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [pIngresoId] - '||pIngresoId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActivarRegistro; 
         pResultado := 'Se ha activado el registro. [Id:'||pIngresoId||']';                        
     ELSE 
         <<ActualizarRegistro>>
         BEGIN
            UPDATE HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS  
               SET PREG_INGRESO_ID               = pPregIngresoId,     
                   PER_NOMINAL_ID                = pPerNominalId,     
                   PROCEDENCIA_ID                = pProcedenciaId,    
                   ADMISION_SERVICIO_ID          = pAdmisionId,       
                   EDAD_EXACTA_INGRESO           = pEdadExactaIng,    
                   GRUPO_ETAREO_ID               = pGrupoEtareoId,    
                   MEDICO_INGRESO_ID             = pMedicoIngId,      
                   ADMISIONISTA_SOLICITA_INGR_ID = pAdminSolicIngId,  
                   ADMISIONISTA_INGRESO_ID       = pAdmisionistaIngId,
                   MEDICO_ORDENA_INGRESO_ID      = pMedOrdenaIngId,   
                   SERVICIO_PROCEDENCIA_ID       = pServProcedenId,   
                   REINGRESO                     = pReingreso,        
                   REINGRESO_ID                  = pReingresoId,      
                   FECHA_SOLICITUD_INGRESO       = pFecSolicitaIng,   
                   HORA_SOLICITUD_INGRESO        = pHrSolicitudIng,   
                   FECHA_INICIO_INGRESO          = pFecInicioIngreso, 
                   HORA_INICIO_INGRESO           = pHrInicioIngreso,  
                   UNIDAD_SALUD_INGRESO          = pUsalIngresoId,    
                   SERVICIO_INGRESO_ID           = pServIngresoId,    
                   ESTADO_INGRESO_ID             = pEstadoIngId,      
                   TIPO_EGRESO_ID                = pTipoEgresoId,     
                   FECHA_FIN_INGRESO             = pFecFinIngreso,    
                   HORA_FIN_INGRESO              = pHrFinIngreso,     
                   SERVICIO_EGRESO_ID            = pServEgresoId,     
                   MEDICO_EGRESO_ID              = pMedicoEgresoId,   
                   REFERENCIA_ID                 = pReferenciaId,     
                   ES_CONTRAFERIDO               = pEsContraferido,   
                   ENVIO_CONTRAREFERENCIA_ID     = pEnvContrareferId, 
                   DIAS_ESTANCIA                 = pDiasEstancia,     
                   ESTADO_PX_ID                  = pEstadoPxId,       
                   ESTADO_PX_EGRESO_ID           = pEstadoPxEgresoId, 
                   COMENTARIOS                   = pComentarios,
                   USUARIO_MODIFICACION          = pUsuario
             WHERE INGRESO_ID = pIngresoId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al actualizar registro [pIngresoId] - '||pIngresoId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActualizarRegistro; 
         pResultado := 'Se ha actualizado el registro. [Id:'||pIngresoId||']';                              
     END CASE;

 END PR_U_INGRESO;
 
 FUNCTION FN_VAL_EXISTE_INGRESO (pConsulta      IN HOSPITALARIO.OBJ_INGRESO_EGRESO,
                                 pTipoIngEgr    IN VARCHAR2,
                                 pPgn           IN BOOLEAN,
                                 pCantRegistros OUT NUMBER,
                                 pFuente        OUT NUMBER) RETURN BOOLEAN AS
                                 
 vContador SIMPLE_INTEGER := 0;
 vExiste BOOLEAN := FALSE;
 BEGIN
 CASE
 WHEN pConsulta.FecInicio IS NULL AND pConsulta.FecFin IS NULL THEN
  dbms_output.put_line ('Entra a validación fechas nulas');
  dbms_output.put_line ('pConsulta.IngresoId: '||pConsulta.IngresoId);
      CASE
      WHEN NVL(pConsulta.IngresoId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
             WHERE INGRESO_ID          = pConsulta.IngresoId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 1;        
           END;
      WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
            NVL(pConsulta.ExpedienteId,0) > 0)  THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                 ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
              WHERE A.PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                    B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 2;
            END;  
      WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS    
             WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 3;
           END;  
      WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
             WHERE B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                   A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 4;
           END;              
      WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
               ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
             WHERE B.CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND 
                   A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 5;
           END;
      WHEN pConsulta.Identificacion IS NOT NULL THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
             WHERE B.IDENTIFICACION_NUMERO = pConsulta.Identificacion AND 
                   A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
           pFuente := 6;
           END;
      WHEN (pConsulta.NombreCompleto IS NOT NULL AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                 ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID 
              WHERE CATSEARCH(NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto AND
                    A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 7;
            END;
      WHEN (NVL(pConsulta.ProcedenciaId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                    A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 8;
            END; 
      WHEN (NVL(pConsulta.MedicoIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND
                    A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 9;
            END;      
      WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                    A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 10;
            END;       
      WHEN (NVL(pConsulta.AdmisionistaIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND
                    A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 11;
            END;   
      WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND
                    A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 12;
            END;         
      WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND
                    A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 13;
            END;  
      WHEN (pConsulta.Reingreso IS NOT NULL AND
            NVL (pConsulta.UsalIngresoId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.REINGRESO  = pConsulta.Reingreso AND
                    A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 14;
            END; 
---- USAL ORIGEN
      WHEN (pConsulta.NombreCompleto IS NOT NULL AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                 ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID AND
                    CATSEARCH(NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto 
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId
              WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 15;
            END;
      WHEN (NVL(pConsulta.ProcedenciaId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
              WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 16;
            END; 
      WHEN (NVL(pConsulta.MedicoIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
              WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 17;
            END;      
      WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
              WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 18;
            END;       
      WHEN (NVL(pConsulta.AdmisionistaIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
              WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 19;
            END;   
      WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
              WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 20;
            END;         
      WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
              WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 21;
            END;  
      WHEN (pConsulta.Reingreso IS NOT NULL AND
            NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
              WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 22;
            END; 
      WHEN pConsulta.NombreCompleto IS NOT NULL THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                 ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
              WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO = pConsulta.NombreCompleto AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 23;
            END;  
      WHEN  NVL(pConsulta.ProcedenciaId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 24;
            END;    
      WHEN  NVL(pConsulta.MedicoIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 25;
            END;       
      WHEN  NVL(pConsulta.AdminSolicIngId,0) > 0  THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 26;
            END;  
      WHEN  NVL(pConsulta.AdmisionistaIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 27;
            END;
      WHEN  NVL(pConsulta.MedOrdenaIngId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 28;
            END;  
      WHEN  NVL(pConsulta.ServProcedenId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 29;
            END; 
      WHEN  pConsulta.Reingreso IS NOT NULL THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
              WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                    A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 30;
            END;                                                                                    
      WHEN (NVL (pConsulta.UsalProcedeId,0) > 0) THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
               JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                 ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                    PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
              WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 31;
            END;            
----             
      WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS 
              WHERE UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                    ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 32;
            END;
      ELSE 
            BEGIN
             SELECT COUNT (1)
               INTO vContador
               FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
              WHERE ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
            pFuente := 33;
            END;
      END CASE;
  WHEN pConsulta.FecInicio IS NOT NULL AND pConsulta.FecFin IS NOT NULL THEN  
       CASE pTipoIngEgr
       WHEN kINGRESO THEN
              CASE
              WHEN NVL(pConsulta.IngresoId,0) > 0 THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                     WHERE INGRESO_ID          = pConsulta.IngresoId AND
                           FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 34;        
                   END;
              WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
                    NVL(pConsulta.ExpedienteId,0) > 0)  THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                         ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                      WHERE A.PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                            B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 35;
                    END;  
              WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS    
                     WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                           FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 36;
                   END;  
              WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                        ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                     WHERE B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                           FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 37;
                   END;              
              WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                       ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                     WHERE B.CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND
                           FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 38;
                   END;
              WHEN pConsulta.Identificacion IS NOT NULL THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                        ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                     WHERE B.IDENTIFICACION_NUMERO = pConsulta.Identificacion AND
                           FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 39;
                   END;
              WHEN (pConsulta.NombreCompleto IS NOT NULL AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                         ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID 
                      WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 40;
                    END;
              WHEN (NVL(pConsulta.ProcedenciaId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND    
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 41;
                    END; 
              WHEN (NVL(pConsulta.MedicoIngId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 42;
                    END;      
              WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND  
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 43;
                    END;       
              WHEN (NVL(pConsulta.AdmisionistaIngId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 44;
                    END;   
              WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 45;
                    END;         
              WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 46;
                    END;  
              WHEN (pConsulta.Reingreso IS NOT NULL AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.REINGRESO  = pConsulta.Reingreso AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 47;
                    END; 
        ---- USAL ORIGEN
              WHEN (pConsulta.NombreCompleto IS NOT NULL AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                         ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID AND
                            CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto 
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId 
                      WHERE FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 48;
                    END;
              WHEN (NVL(pConsulta.ProcedenciaId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                      WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 49;
                    END; 
              WHEN (NVL(pConsulta.MedicoIngId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND 
                      FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 50;
                    END;      
              WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 51;
                    END;       
              WHEN (NVL(pConsulta.AdmisionistaIngId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND   
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 52;
                    END;   
              WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                      WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND  
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 53;
                    END;         
              WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND 
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 54;
                    END;  
              WHEN (pConsulta.Reingreso IS NOT NULL AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 55;
                    END; 
              WHEN pConsulta.NombreCompleto IS NOT NULL THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                         ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                      WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO = pConsulta.NombreCompleto AND 
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 56;
                    END;  
              WHEN  NVL(pConsulta.ProcedenciaId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND   
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 57;
                    END;    
              WHEN  NVL(pConsulta.MedicoIngId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND 
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 58;
                    END;       
              WHEN  NVL(pConsulta.AdminSolicIngId,0) > 0  THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND   
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 59;
                    END;  
              WHEN  NVL(pConsulta.AdmisionistaIngId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND  
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 60;
                    END;
              WHEN  NVL(pConsulta.MedOrdenaIngId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND  
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 61;
                    END;  
              WHEN  NVL(pConsulta.ServProcedenId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND  
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 62;
                    END; 
              WHEN  pConsulta.Reingreso IS NOT NULL THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 63;
                    END;                                                                                    
              WHEN (NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 64;
                    END;            
        ----             
              WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS 
                      WHERE UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND
                            FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                            ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 65;
                    END;
              ELSE 
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                      WHERE FECHA_INICIO_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 66;
                    END;
              END CASE;
       WHEN kEGRESO THEN 
             CASE
              WHEN NVL(pConsulta.IngresoId,0) > 0 THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                     WHERE INGRESO_ID          = pConsulta.IngresoId AND
                           FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 67;        
                   END;
              WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
                    NVL(pConsulta.ExpedienteId,0) > 0)  THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                         ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                      WHERE A.PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                            B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 68;
                    END;  
              WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS    
                     WHERE PER_NOMINAL_ID = pConsulta.PerNominalId  AND
                           FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                           ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 69;
                   END;  
              WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                        ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                     WHERE B.EXPEDIENTE_ID = pConsulta.ExpedienteId AND 
                           FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 70;
                   END;              
              WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                       ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                     WHERE B.CODIGO_EXPEDIENTE_ELECTRONICO = pConsulta.CodExpElectronico AND
                           FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 71;
                   END;
              WHEN pConsulta.Identificacion IS NOT NULL THEN
                   BEGIN
                    SELECT COUNT (1)
                      INTO vContador
                      FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                        ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID         
                     WHERE B.IDENTIFICACION_NUMERO = pConsulta.Identificacion AND
                           FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                           A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                   pFuente := 72;
                   END;
              WHEN (pConsulta.NombreCompleto IS NOT NULL AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                         ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID 
                      WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 73;
                    END;
              WHEN (NVL(pConsulta.ProcedenciaId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND    
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 74;
                    END; 
              WHEN (NVL(pConsulta.MedicoIngId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 75;
                    END;      
              WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND  
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 76;
                    END;       
              WHEN (NVL(pConsulta.AdmisionistaIngId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 77;
                    END;   
              WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND 
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 78;
                    END;         
              WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 79;
                    END;  
              WHEN (pConsulta.Reingreso IS NOT NULL AND
                    NVL (pConsulta.UsalIngresoId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.REINGRESO  = pConsulta.Reingreso AND
                            A.UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND   
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 80;
                    END; 
        ---- USAL ORIGEN
              WHEN (pConsulta.NombreCompleto IS NOT NULL AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                         ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID AND
                            CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1  -- B.NOMBRE_COMPLETO  = pConsulta.NombreCompleto 
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId 
                      WHERE FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 81;
                    END;
              WHEN (NVL(pConsulta.ProcedenciaId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                      WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 82;
                    END; 
              WHEN (NVL(pConsulta.MedicoIngId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND 
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 83;
                    END;      
              WHEN (NVL(pConsulta.AdminSolicIngId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 84;
                    END;       
              WHEN (NVL(pConsulta.AdmisionistaIngId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND   
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 85;
                    END;   
              WHEN (NVL(pConsulta.MedOrdenaIngId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId               
                      WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND  
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 86;
                    END;         
              WHEN (NVL(pConsulta.ServProcedenId,0) > 0 AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND 
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 87;
                    END;  
              WHEN (pConsulta.Reingreso IS NOT NULL AND
                    NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 88;
                    END; 
              WHEN pConsulta.NombreCompleto IS NOT NULL THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL B
                         ON B.PER_NOMINAL_ID = A.PER_NOMINAL_ID
                      WHERE CATSEARCH(B.NOMBRE_COMPLETO,pConsulta.NombreCompleto,NULL) > 1 AND  -- B.NOMBRE_COMPLETO = pConsulta.NombreCompleto AND 
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 89;
                    END;  
              WHEN  NVL(pConsulta.ProcedenciaId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.PROCEDENCIA_ID  = pConsulta.ProcedenciaId AND   
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 90;
                    END;    
              WHEN  NVL(pConsulta.MedicoIngId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.MEDICO_INGRESO_ID  = pConsulta.MedicoIngId AND 
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND  
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 91;
                    END;       
              WHEN  NVL(pConsulta.AdminSolicIngId,0) > 0  THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.ADMISIONISTA_SOLICITA_INGR_ID  = pConsulta.AdminSolicIngId AND   
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 92;
                    END;  
              WHEN  NVL(pConsulta.AdmisionistaIngId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.ADMISIONISTA_INGRESO_ID  = pConsulta.AdmisionistaIngId AND  
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 93;
                    END;
              WHEN  NVL(pConsulta.MedOrdenaIngId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.MEDICO_ORDENA_INGRESO_ID  = pConsulta.MedOrdenaIngId AND  
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 94;
                    END;  
              WHEN  NVL(pConsulta.ServProcedenId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.SERVICIO_PROCEDENCIA_ID  = pConsulta.ServProcedenId AND  
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND 
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 95;
                    END; 
              WHEN  pConsulta.Reingreso IS NOT NULL THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                      WHERE A.REINGRESO  = pConsulta.Reingreso AND   
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 96;
                    END;                                                                                    
              WHEN (NVL (pConsulta.UsalProcedeId,0) > 0) THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS A
                       JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PRE
                         ON PRE.PREG_INGRESO_ID = A.PREG_INGRESO_ID AND
                            PRE.UNIDAD_SALUD_ORIGEN_ID = pConsulta.UsalProcedeId                
                      WHERE FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 97;
                    END;            
        ----             
              WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS 
                      WHERE UNIDAD_SALUD_INGRESO = pConsulta.UsalIngresoId AND
                            FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND   
                            ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 98;
                    END;
              ELSE 
                    BEGIN
                     SELECT COUNT (1)
                       INTO vContador
                       FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS
                      WHERE FECHA_FIN_INGRESO BETWEEN pConsulta.FecInicio AND pConsulta.FecFin AND
                            ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
                    pFuente := 99;
                    END;
              END CASE;
       ELSE NULL;
       END CASE; 
  ELSE NULL;
  END CASE;
 CASE
 WHEN vContador > 0 THEN
      vExiste := TRUE;
 ELSE NULL;
 END CASE;
 pCantRegistros := vContador;   
 dbms_output.put_line ('pFuente: '||pFuente);    
 dbms_output.put_line ('pCantRegistros: '||pCantRegistros);    
 RETURN vExiste;
 EXCEPTION
 WHEN OTHERS THEN
     RETURN vExiste;  
 END FN_VAL_EXISTE_INGRESO; 

 FUNCTION FN_OBT_INGR_ID (pIngresoId IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE) RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
      OPEN vRegistro FOR
           SELECT ING.INGRESO_ID                         INGRESO_ID,                    -- Ingreso
                  ING.PREG_INGRESO_ID                    PREG_INGRESO_ID,                 -- pre ingreso      
                  PREING.ESPECIALIDAD_DESTINO_ID         PRE_ESPECIALIDAD_DESTINO,        -- pre ingreso    
                  ESPDEST.CODIGO                         PREESPDEST_CODIGO,                 -- catalogo  
                  ESPDEST.NOMBRE                         PREESPDEST_NOMBRE,                 -- catalogo
                  ESPDEST.DESCRIPCION                    PREESPDEST_DESCRIPCION,            -- catalogo
                  PREING.UNIDAD_SALUD_ORIGEN_ID          PRE_USAL_ORIGEN_ID,              -- pre ingreso
                  USALORI.NOMBRE                         PRE_USAL_ORIGEN_NOMBRE,            -- unidad salud
                  USALORI.CODIGO                         PRE_USAL_ORIGEN_CODIGO,            -- unidad salud
                  USALORI.ENTIDAD_ADTVA_ID               PRE_ENTADM_ORIGEN_ID,              -- unidad salud
                  ENTADVORI.NOMBRE                       PRE_ENTADM_ORIGEN_NOMBRE,            -- entidad admin
                  PREING.UNIDAD_SALUD_DESTINO_ID         PRE_USAL_DEST_ID,                -- pre ingreso
                  USALDEST.NOMBRE                        PRE_USAL_DEST_NOMBRE,              -- unidad salud
                  USALDEST.CODIGO                        PRE_USAL_DEST_CODIGO,              -- unidad salud
                  USALDEST.ENTIDAD_ADTVA_ID              PRE_ENTADM_DEST_ID,                -- unidad salud
                  ENTADVDEST.NOMBRE                      PRE_ENTADM_DEST_NOMBRE,              -- entidad admin
                  ING.PER_NOMINAL_ID                     PER_NOMINAL_ID,                  -- Ingreso              
                  NOM.CODIGO_EXPEDIENTE_ELECTRONICO      PRENOM_COD_EXPEDIENTE,             -- Nominal
                  NOM.EXPEDIENTE_ID                      PRENOM_EXPEDIENTE_ID,              -- Nominal
                  NOM.PRIMER_NOMBRE                      PRENOM_PNOMBRE,                    -- Nominal
                  NOM.SEGUNDO_NOMBRE                     PRENOM_SNOMBRE,                    -- Nominal
                  NOM.PRIMER_APELLIDO                    PRENOM_PAPELLIDO,                  -- Nominal
                  NOM.SEGUNDO_APELLIDO                   PRENOM_SAPELLIDO,                  -- Nominal 
                  NOM.NOMBRE_COMPLETO                    PRENOM_NOMB_COMPLETO,              -- Nominal
                  NOM.TIPO_IDENTIFICACION_ID             PRENOM_TIP_IDENTIFICACION,         -- Nominal
                  NOM.IDENTIFICACION_CODIGO              PRENOM_IDENTIF_CODIGO,             -- Nominal
                  NOM.IDENTIFICACION_NOMBRE              PRENOM_IDENTIF_NOMBRE,             -- Nominal
                  NOM.IDENTIFICACION_NUMERO              PRENOM_IDENTIF_NUMERO,             -- Nominal
                  NOM.SEXO_ID                            PRENOM_SEXO_ID ,                   -- Nominal
                  NOM.SEXO_CODIGO                        PRENOM_SEXO_CODIGO,                -- Nominal
                  NOM.SEXO_VALOR                         PRENOM_SEXO_VALOR,                 -- Nominal
                  NOM.FECHA_NACIMIENTO                   PRENOM_FEC_NACIMIENTO,             -- Nominal
                  NOM.DET_PRS_RESIDENCIA_ID              PRENOM_DET_PRS_RESINDENCIA_ID,     -- Nominal  
                  NOM.COMUNIDAD_RESIDENCIA_ID            PRENOM_COM_RESIDENCIA_ID,          -- Nominal
                  NOM.COMUNIDAD_RESIDENCIA_NOMBRE        PRENOM_COM_RESIDENCIA_NOMBRE,      -- Nominal
                  NOM.MUNICIPIO_RESIDENCIA_ID            PRENOM_MUNI_RESIDENCIA_ID,         -- Nominal
                  NOM.MUNICIPIO_RESIDENCIA_NOMBRE        PRENOM_MUNI_RESIDENCIA_NOMBRE,     -- Nominal
                  NOM.DEPARTAMENTO_RESIDENCIA_ID         PRENOM_DEP_RESIDENCIA_ID,          -- Nominal 
                  NOM.DEPARTAMENTO_RESIDENCIA_NOMBRE     PRENOM_DEP_RESIDENCIA_NOMBRE,      -- Nominal 
                  NOM.DIRECCION_RESIDENCIA               PRENOM_DIRECCION_RESIDENCIA,       -- Nominal
                  NOM.TELEFONO_ID                        PRENOM_TELEFONO_ID,                -- Nominal
                  NOM.TELEFONO                           PRENOM_TELEFONO,                   -- Nominal
                  ING.PROCEDENCIA_ID                     ING_PROCEDENCIA_ID,              -- Ingreso  
                  CATPROCED.CODIGO                       CATPROC_CODIGO,                    -- catalogo
                  CATPROCED.VALOR                        CATPROC_VALOR,                     -- catalogo
                  CATPROCED.DESCRIPCION                  CATPROC_DESCRIPCION,               -- catalogo
                  ING.ADMISION_SERVICIO_ID               ADMISION_SERVICIO_ID,            -- Ingreso        
                  ING.EDAD_EXACTA_INGRESO                EDAD_EXACTA_INGRESO,             -- Ingreso
                  ING.GRUPO_ETAREO_ID                    GRUPO_ETAREO_ID,                 -- Ingreso
                  CONFETAREO.MINIMO                      ETAREO_EDAD_MINIMA,                -- grupo etareo
                  CONFETAREO.MAXIMO                      ETAREO_EDAD_MAXIMA,                -- grupo etareo 
                  CONFETAREO.UMIN_ID                     ETAREO_UMINIMA_ID,                 -- grupo etareo 
                  CONFETAREO.UMAX_ID                     ETAREO_UMAXIMA_ID,                 -- grupo etareo
                  ETAREO.CODIGO                          ETAREO_CODIGO,                       -- catalogo
                  ETAREO.VALOR                           ETAREO_VALOR,                         -- catalogo
                  ETAREO.DESCRIPCION                     ETAREO_DESCRIPCION,                   -- catalogo
                  ING.MEDICO_INGRESO_ID                  MEDICO_INGRESO_ID,               -- Ingreso                        
                  PER.PRIMER_NOMBRE                      MEDINGR_PRIMER_NOMBRE,              ---     
                  PER.SEGUNDO_NOMBRE                     MEDINGR_SEGUNDO_NOMBRE,     
                  PER.PRIMER_APELLIDO                    MEDINGR_PRIMER_APELLIDO,
                  PER.SEGUNDO_APELLIDO                   MEDINGR_SEGUNDO_APELLIDO,  
                  MEDINGRESO.CODIGO                      MEDINGR_COD_MINSA_PER, 
                  MPERSALUD.REGISTRO_SANITARIO           MEDINGR_REG_SANITARIO,
                  MEDINGRESO.TIPO_PERSONAL_ID            MEDINGR_TIPO_PERSONAL_ID,
                  CAT.CODIGO                             MEDINGR_COD_TIPO_PERSONAL,
                  CAT.VALOR                              MEDINGR_VALOR_TIPO_PERSONAL,
                  CAT.DESCRIPCION                        MEDINGR_DESC_TIPO_PERSONAL,
                  ING.ADMISIONISTA_SOLICITA_INGR_ID      ADMISIONISTA_SOLICITA_INGR_ID,   -- Ingreso
                  PER1.PRIMER_NOMBRE                     ADMSOLINGR_PRIMER_NOMBRE,                  
                  PER1.SEGUNDO_NOMBRE                    ADMSOLINGR_SEGUNDO_NOMBRE,     
                  PER1.PRIMER_APELLIDO                   ADMSOLINGR_PRIMER_APELLIDO,
                  PER1.SEGUNDO_APELLIDO                  ADMSOLINGR_SEGUNDO_APELLIDO,  
                  ADMINSOLINGRESO.CODIGO                 ADMSOLINGR_COD_MINSA_PER, 
                  MPERSALUD1.REGISTRO_SANITARIO          ADMSOLINGR_REG_SANITARIO,
                  ADMINSOLINGRESO.TIPO_PERSONAL_ID       ADMSOLINGR_TIPO_PERSONAL_ID,
                  CAT1.CODIGO                            ADMSOLINGR_COD_TIPO_PERSONAL,
                  CAT1.VALOR                             ADMSOLINGR_VALOR_TIPO_PERSONAL,
                  CAT1.DESCRIPCION                       ADMSOLINGR_DESC_TIPO_PERSONAL,                  
                  ING.ADMISIONISTA_INGRESO_ID            ADMISIONISTA_INGRESO_ID,         -- Ingreso   
                  PER2.PRIMER_NOMBRE                     ADMINGR_PRIMER_NOMBRE,     
                  PER2.SEGUNDO_NOMBRE                    ADMINGR_SEGUNDO_NOMBRE,    
                  PER2.PRIMER_APELLIDO                   ADMINGR_PRIMER_APELLIDO,
                  PER2.SEGUNDO_APELLIDO                  ADMINGR_SEGUNDO_APELLIDO,  
                  ADMININGRESO.CODIGO                    ADMINGR_COD_MINSA_PER, 
                  MPERSALUD2.REGISTRO_SANITARIO          ADMINGR_REG_SANITARIO,
                  ADMININGRESO.TIPO_PERSONAL_ID          ADMINGR_TIPO_PERSONAL_ID,
                  CAT2.CODIGO                            ADMINGR_COD_TIPO_PERSONAL,
                  CAT2.VALOR                             ADMINGR_VALOR_TIPO_PERSONAL,
                  CAT2.DESCRIPCION                       ADMINGR_DESC_TIPO_PERSONAL,
                  ING.MEDICO_ORDENA_INGRESO_ID           MEDICO_ORDENA_INGRESO_ID,        -- Ingreso   
                  PER3.PRIMER_NOMBRE                     MEDORDING_PRIMER_NOMBRE,     
                  PER3.SEGUNDO_NOMBRE                    MEDORDING_SEGUNDO_NOMBRE,    
                  PER3.PRIMER_APELLIDO                   MEDORDING_PRIMER_APELLIDO,
                  PER3.SEGUNDO_APELLIDO                  MEDORDING_SEGUNDO_APELLIDO,  
                  MEDORDENAING.CODIGO                    MEDORDING_COD_MINSA_PER, 
                  MPERSALUD3.REGISTRO_SANITARIO          MEDORDING_REG_SANITARIO,
                  MEDORDENAING.TIPO_PERSONAL_ID          MEDORDING_TIPO_PERSONAL_ID,
                  CAT3.CODIGO                            MEDORDING_COD_TIPO_PERSONAL,
                  CAT3.VALOR                             MEDORDING_VALOR_TIPO_PERSONAL,
                  CAT3.DESCRIPCION                       MEDORDING_DESC_TIPO_PERSONAL,
                  ING.SERVICIO_PROCEDENCIA_ID            SERVICIO_PROCEDENCIA_ID,         -- Ingreso 
                  SERV.CODIGO                            PRE_SERV_PROCED_CODIGO,            -- servicio              
                  SERV.NOMBRE                            PRE_SERV_PROCED_NOMBRE,            -- servicio             
                  SERV.DESCRIPCION                       PRE_SERV_PROCED_DESCRIPCION,       -- servicio                 
                  ING.REINGRESO                          REINGRESO,                       -- Ingreso                
                  ING.REINGRESO_ID                       REINGRESO_ID,                    -- Ingreso      
                  ING.FECHA_SOLICITUD_INGRESO            FECHA_SOLICITUD_INGRESO,         -- Ingreso
                  ING.HORA_SOLICITUD_INGRESO             HORA_SOLICITUD_INGRESO ,         -- Ingreso
                  ING.FECHA_INICIO_INGRESO               FECHA_INICIO_INGRESO,            -- Ingreso
                  ING.HORA_INICIO_INGRESO                HORA_INICIO_INGRESO,             -- Ingreso 
                  ING.UNIDAD_SALUD_INGRESO               UNIDAD_SALUD_INGRESO,            -- Ingreso
                  USALING.NOMBRE                         USAL_INGRESO_NOMBRE,               -- unidad salud
                  USALING.CODIGO                         USAL_INGRESO_CODIGO,               -- unidad salud
                  USALING.ENTIDAD_ADTVA_ID               ENTADM_INGRESO_ID,                 -- unidad salud
                  ENTADING.NOMBRE                        ENTADM_INGRESO_NOMBRE,               -- entidad admin
                  ING.SERVICIO_INGRESO_ID                SERV_ING_ID,                     -- Ingreso
                  SERVING.CODIGO                         SERV_ING_CODIGO,                   -- servicio
                  SERVING.NOMBRE                         SERV_ING_NOMBRE,                   -- servicio
                  SERVING.DESCRIPCION                    SERV_ING_DESCRIPCION,              -- servicio 
                  ING.ESTADO_INGRESO_ID                  ESTADO_INGRESO_ID,               -- Ingreso
                  CATESTING.CODIGO                       CATESTING_CODIGO,                  -- catalogo
                  CATESTING.VALOR                        CATESTING_VALOR,                   -- catalogo
                  CATESTING.DESCRIPCION                  CATESTING_DESCRIPCION,             -- catalogo
                  ING.TIPO_EGRESO_ID                     TIPO_EGRESO_ID,                  -- Ingreso       
                  CATTIPEGR.CODIGO                       CATTIPEGR_CODIGO,                  -- catalogo
                  CATTIPEGR.VALOR                        CATTIPEGR_VALOR,                   -- catalogo
                  CATTIPEGR.DESCRIPCION                  CATTIPEGR_DESCRIPCION,             -- catalogo
                  ING.FECHA_FIN_INGRESO                  FECHA_FIN_INGRESO,               -- Ingreso
                  ING.HORA_FIN_INGRESO                   HORA_FIN_INGRESO,                -- Ingreso
                  ING.SERVICIO_EGRESO_ID                 SERVICIO_EGRESO_ID,              -- Ingreso
                  SERVEGR.CODIGO                         SERVEGR_ING_CODIGO,                -- servicio 
                  SERVEGR.NOMBRE                         SERVEGR_ING_NOMBRE,                -- servicio
                  SERVEGR.DESCRIPCION                    SERVEGR_ING_DESCRIPCION,           -- servicio             
                  ING.MEDICO_EGRESO_ID                   MEDICO_EGRESO_ID,                -- Ingreso
                  PER4.PRIMER_NOMBRE                     MEDEGRESO_PRIMER_NOMBRE,     
                  PER4.SEGUNDO_NOMBRE                    MEDEGRESO_SEGUNDO_NOMBRE,    
                  PER4.PRIMER_APELLIDO                   MEDEGRESO_PRIMER_APELLIDO,
                  PER4.SEGUNDO_APELLIDO                  MEDEGRESO_SEGUNDO_APELLIDO,  
                  MEDEGRESO.CODIGO                       MEDEGRESO_COD_MINSA_PER, 
                  MPERSALUD4.REGISTRO_SANITARIO          MEDEGRESO_REG_SANITARIO,
                  MEDEGRESO.TIPO_PERSONAL_ID             MEDEGRESO_TIPO_PERSONAL_ID,
                  CAT4.CODIGO                            MEDEGRESO_COD_TIPO_PERSONAL,
                  CAT4.VALOR                             MEDEGRESO_VALOR_TIPO_PERSONAL,
                  CAT4.DESCRIPCION                       MEDEGRESO_DESC_TIPO_PERSONAL,
                  ING.REFERENCIA_ID                      REFERENCIA_ID,                   -- Ingreso
                  ING.ES_CONTRAFERIDO                    ES_CONTRAFERIDO,                 -- Ingreso          
                  ING.ENVIO_CONTRAREFERENCIA_ID          ENVIO_CONTRAREFERENCIA_ID,       -- Ingreso
                  ING.DIAS_ESTANCIA                      DIAS_ESTANCIA,                   -- Ingreso
                  ING.ESTADO_PX_ID                       ESTADO_PX_ID,                    -- Ingreso
                  CATESTPX.CODIGO                        CATESTPX_CODIGO,                   -- catalogo
                  CATESTPX.VALOR                         CATESTPX_VALOR,                    -- catalogo
                  CATESTPX.DESCRIPCION                   CATESTPX_DESCRIPCION,              -- catalogo          
                  ING.ESTADO_PX_EGRESO_ID                ESTADO_PX_EGRESO_ID,             -- Ingreso          
                  CATESTPXEGR.CODIGO                     CATESTPXEGR_CODIGO,                -- catalogo
                  CATESTPXEGR.VALOR                      CATESTPXEGR_VALOR,                 -- catalogo
                  CATESTPXEGR.DESCRIPCION                CATESTPXEGR_DESCRIPCION,           -- catalogo
                  ING.COMENTARIOS                        COMENTARIOS,                     -- Ingreso
                  ING.ESTADO_REGISTRO_ID                 ESTADO_REGISTRO_ID,              -- Ingreso
                  CATESTREG.CODIGO                       CATESTREG_CODIGO,                  -- catalogo
                  CATESTREG.VALOR                        CATESTREG_VALOR,                   -- catalogo
                  CATESTREG.DESCRIPCION                  CATESTREG_DESCRIPCION,             -- catalogo          
                  ING.USUARIO_REGISTRO                   USR_REGISTRO,                    -- Ingreso
                  ING.FECHA_REGISTRO                     FECHA_REGISTRO,                  -- Ingreso
                  ING.USUARIO_REGISTRO_EGRESO            USR_REGISTRO_EGRESO,             -- Ingreso
                  ING.FECHA_REGISTRO_EGRESO              FEC_REGISTRO_EGRESO,             -- Ingreso 
                  ING.USUARIO_MODIFICACION               USR_MODIFICACION,                -- Ingreso
                  ING.FECHA_MODIFICACION                 FEC_MODIFICACION,                -- Ingreso 
                  ING.USUARIO_PASIVA                     USR_PASIVA,                      -- Ingreso
                  ING.FECHA_PASIVA                       FEC_PASIVA,                      -- Ingreso
                  ING.USUARIO_ELIMINA                    USR_ELIMINA,                     -- Ingreso
                  ING.FECHA_ELIMINA                      FEC_ELIMINA,                      -- Ingreso
                  ADSERVCAMAS.ADMISION_SRV_CAMA_ID       ADSERV_SRV_CAMA_ID,
                  ADSERVCAMAS.CFG_USLD_SERVICIO_CAMA_ID  CFG_USLD_SERVICIO_CAMA_ID,
                  CFG.UND_SALUD_SERVICIO_ID              UND_SALUD_SERVICIO_ID, 
                  RELUSALSERV.UNIDAD_SALUD_ID            ADSERV_USSERV_USALUD_ID,
                  USALSERV.NOMBRE                        ADSERV_USSERV_NOMBRE,
                  USALSERV.CODIGO                        ADSERV_USSERV_CODIGO,
                  USALSERV.DIRECCION                     ADSERV_USSERV_DIRECCION,
                  USALSERV.ENTIDAD_ADTVA_ID              ADSERV_USSERV_ENTADTVA_ID,
                  ENTADMINSERV.NOMBRE                    ADSERV_ENTADMINSERV_NOMBRE,
                  ENTADMINSERV.CODIGO                    ADSERV_ENTADMINSERV_CODIGO,
                  ENTADMINSERV.TELEFONO                  ADSERV_ENTADMINSERV_TELEFONO,
                  ENTADMINSERV.EMAIL                     ADSERV_ENTADMINSERV_EMAIL,
                  ENTADMINSERV.DIRECCION                 ADSERV_ENTADMINSERV_DIRECCION,
                  RELUSALSERV.SERVICIO_ID                ADSERV_RELUSALSERV_SERVICIO_ID,
                  CATSERV.CODIGO                         ADSERV_CATSERV_CODIGO,
                  CATSERV.NOMBRE                         ADSERV_CATSERV_NOMBRE,
                  CATSERV.DESCRIPCION                    ADSERV_CATSERV_DESCRIPCION,
                  CATSERV.PASIVO                         ADSERV_CATSERV_PASIVO,
                  RELUSALSERV.ESTADO_REGISTRO            ADSERV_RELUSALSERV_EST_REG,
                  CATESTREGUSALSERV.CODIGO               ADSERV_CATESTREGUSALSERV_COD,
                  CATESTREGUSALSERV.VALOR                ADSERV_CATESTREGUSALSERV_VALOR,
                  CATESTREGUSALSERV.DESCRIPCION          ADSERV_CATESTREGUSALSERV_DES,
                  RELUSALSERV.USUARIO_REGISTRO           ADSERV_RELUSALSERV_USR_SERV,
                  RELUSALSERV.FECHA_REGISTRO             ADSERV_RELUSALSERV_FEC_REG, 
                  CFG.CODIGO_ASISTENCIAL                 CFG_COD_ASISTENCIAL,       
                  CFG.SALA_ID                            CFG_SALA_ID,                  
                  CFG.HABITACION_ID                      CFG_HABITACION_ID,            
                  CFG.CAMA_ID                            CFG_CAMA_ID,
                  CATCAMAS.NOMBRE                        CATCAMAS_NOMBRE,
                  CATCAMAS.CODIGO_ADMINISTRATIVO         CATCAMAS_COD_ADMIN,
                  CATCAMAS.ESTADO_CAMA                   CATCAMAS_ESTADO_CAMA,
                  CATCAMAS.NO_SERIE                      CATCAMAS_NO_SERIE, 
                  CATCAMAS.ESTADO_REGISTRO_ID            CATCAMAS_EST_REG_ID,
                  CATESTREGCAMAS.CODIGO                  CATESTREGCAMAS_COD,    
                  CATESTREGCAMAS.VALOR                   CATESTREGCAMAS_VALOR,
                  CATESTREGCAMAS.DESCRIPCION             CATESTREGCAMAS_DES,
                  CATCAMAS.USUARIO_REGISTRO              CATCAMAS_USR_REG,
                  CATCAMAS.FECHA_REGISTRO                CATCAMAS_FEC_REG,      
                  CFG.DISPONIBLE                         CFG_DISPONIBLE,                
                  CFG.CENSABLE                           CFG_ADSERV_CENSABLE,       
                  CFG.ESTADO_CAMA_ID                     CFG_ADSERV_ESTADO_CAMA_ID, 
                  CATESTCAMA.CODIGO                      CATESTCAMA_CODIGO,
                  CATESTCAMA.VALOR                       CATESTCAMA_VALOR,
                  CATESTCAMA.DESCRIPCION                 CATESTCAMA_DESCRIPCION,
                  CFG.IS_LAST                            CFG_IS_LAST,                  
                  CFG.ESTADO_REGISTRO_ID                 CFG_ESTADO_REGISTRO_ID,  
                  CATESREG.CODIGO                        CATESREG_CODIGO,
                  CATESREG.VALOR                         CATESREG_VALOR,
                  CATESREG.DESCRIPCION                   CATESREG_DESC,
                  CFG.USUARIO_REGISTRO                   CFG_USR_REGISTRO,           
                  CFG.FECHA_REGISTRO                     CFG_FEC_REGISTRO,      
                  ADSERVCAMAS.ADMISION_SERVICIO_ID       ADSERVCFG_ADMISION_SERV_ID,
                  ADSERVCAMAS.FECHA_INI                  ADSERVCFG_FECHA_INI,
                  ADSERVCAMAS.HORA_INI                   ADSERVCFG_HORA_INI,
                  ADSERVCAMAS.FECHA_FIN                  ADSERVCFG_FECHA_FIN,
                  ADSERVCAMAS.HORA_FIN                   ADSERVCFG_HORA_FIN,
                  ADSERVCAMAS.IS_LAST                    ADSERVCFG_IS_LAST,
                  ADSERVCAMAS.ESTADO_REGISTRO_ID         ADSERVCFG_ESTADO_REGISTRO_ID, 
                  CATESREGADM.CODIGO                     ADSERVCFG_CATESREG_CODIGO,
                  CATESREGADM.VALOR                      ADSERVCFG_CATESREG_VALOR,
                  CATESREGADM.DESCRIPCION                ADSERVCFG_CATESREG_DESC,
                  ADSERVCAMAS.USUARIO_REGISTRO           ADSERVCFG_USR_REGISTRO,
                  ADSERVCAMAS.FECHA_REGISTRO             ADSERVCFG_FEC_REGISTRO
             FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS ING
             JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PREING 
               ON PREING.PREG_INGRESO_ID = ING.PREG_INGRESO_ID  
             JOIN HOSPITALARIO.SNH_CAT_SERVICIOS ESPDEST
               ON ESPDEST.SERVICIO_ID = PREING.ESPECIALIDAD_DESTINO_ID                            
             JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALORI
               ON USALORI.UNIDAD_SALUD_ID = PREING.UNIDAD_SALUD_ORIGEN_ID
             JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADVORI
               ON ENTADVORI.ENTIDAD_ADTVA_ID = USALORI.ENTIDAD_ADTVA_ID
             JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALDEST
               ON USALDEST.UNIDAD_SALUD_ID = PREING.UNIDAD_SALUD_DESTINO_ID
             JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADVDEST
               ON ENTADVDEST.ENTIDAD_ADTVA_ID = USALDEST.ENTIDAD_ADTVA_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL NOM
               ON NOM.PER_NOMINAL_ID = ING.PER_NOMINAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CATPROCED
               ON CATPROCED.CATALOGO_ID = ING.PROCEDENCIA_ID
             JOIN HOSPITALARIO.SNH_REL_CNF_GRUPO_CATALOGOS CONFETAREO
               ON CONFETAREO.CNF_ID = ING.GRUPO_ETAREO_ID  
             JOIN CATALOGOS.SBC_CAT_CATALOGOS ETAREO
               ON ETAREO.CATALOGO_ID = CONFETAREO.CATALOGO_CNF_ID 
             JOIN HOSPITALARIO.SNH_CAT_SERVICIOS SERV
               ON SERV.SERVICIO_ID = ING.SERVICIO_PROCEDENCIA_ID
             JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALING
               ON USALING.UNIDAD_SALUD_ID = ING.UNIDAD_SALUD_INGRESO
             JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADING
               ON ENTADING.ENTIDAD_ADTVA_ID = USALING.ENTIDAD_ADTVA_ID                    
             LEFT JOIN HOSPITALARIO.SNH_CAT_SERVICIOS SERVING
               ON SERVING.SERVICIO_ID = ING.SERVICIO_INGRESO_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTING
               ON CATESTING.CATALOGO_ID = ING.ESTADO_INGRESO_ID 
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATTIPEGR 
               ON CATTIPEGR.CATALOGO_ID = ING.TIPO_EGRESO_ID
             LEFT JOIN HOSPITALARIO.SNH_CAT_SERVICIOS SERVEGR
               ON SERVEGR.SERVICIO_ID = ING.SERVICIO_EGRESO_ID 
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTPX
               ON CATESTPX.CATALOGO_ID = ING.ESTADO_PX_ID 
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTPXEGR
               ON CATESTPXEGR.CATALOGO_ID = ING.ESTADO_PX_EGRESO_ID                     
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREG
               ON CATESTREG.CATALOGO_ID = ING.ESTADO_REGISTRO_ID
             JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES MEDINGRESO
               ON MEDINGRESO.MINSA_PERSONAL_ID = ING.MEDICO_INGRESO_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS PER
               ON MEDINGRESO.PERSONA_ID = PER.PERSONA_ID
             JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD
               ON MPERSALUD.MINSA_PERSONAL_ID = MEDINGRESO.MINSA_PERSONAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT
               ON CAT.CATALOGO_ID = MEDINGRESO.TIPO_PERSONAL_ID          
             JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES ADMINSOLINGRESO
               ON ADMINSOLINGRESO.MINSA_PERSONAL_ID = ING.ADMISIONISTA_SOLICITA_INGR_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS PER1
               ON ADMINSOLINGRESO.PERSONA_ID = PER1.PERSONA_ID
             JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD1
               ON MPERSALUD1.MINSA_PERSONAL_ID = ADMINSOLINGRESO.MINSA_PERSONAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT1
               ON CAT1.CATALOGO_ID = ADMINSOLINGRESO.TIPO_PERSONAL_ID           
             JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES ADMININGRESO
               ON ADMININGRESO.MINSA_PERSONAL_ID = ING.ADMISIONISTA_INGRESO_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS PER2
               ON ADMININGRESO.PERSONA_ID = PER2.PERSONA_ID
             JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD2
               ON MPERSALUD2.MINSA_PERSONAL_ID = ADMININGRESO.MINSA_PERSONAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT2
               ON CAT2.CATALOGO_ID = ADMININGRESO.TIPO_PERSONAL_ID   
             JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES MEDORDENAING
               ON MEDORDENAING.MINSA_PERSONAL_ID = ING.MEDICO_ORDENA_INGRESO_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS PER3
               ON MEDORDENAING.PERSONA_ID = PER3.PERSONA_ID
             JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD3
               ON MPERSALUD3.MINSA_PERSONAL_ID = MEDORDENAING.MINSA_PERSONAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT3
               ON CAT3.CATALOGO_ID = MEDORDENAING.TIPO_PERSONAL_ID          
             LEFT JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES MEDEGRESO
               ON MEDEGRESO.MINSA_PERSONAL_ID = ING.MEDICO_EGRESO_ID
             LEFT JOIN CATALOGOS.SBC_MST_PERSONAS PER4
               ON MEDEGRESO.PERSONA_ID = PER4.PERSONA_ID
             LEFT JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD4
               ON MPERSALUD4.MINSA_PERSONAL_ID = MEDEGRESO.MINSA_PERSONAL_ID
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT4
               ON CAT4.CATALOGO_ID = MEDEGRESO.TIPO_PERSONAL_ID     --------------
             LEFT JOIN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS ADSERVCAMAS --ADSERVAMAS
               ON ADSERVCAMAS.ADMISION_SERVICIO_ID = ING.ADMISION_SERVICIO_ID AND
                  ADSERVCAMAS.IS_LAST = 1
             LEFT JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFG
               ON ADSERVCAMAS.CFG_USLD_SERVICIO_CAMA_ID = CFG.CFG_USLD_SERVICIO_CAMA_ID
              AND CFG.IS_LAST = 1
             LEFT JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS RELUSALSERV
               ON RELUSALSERV.UND_SALUD_SERVICIO_ID = CFG.UND_SALUD_SERVICIO_ID
             LEFT JOIN HOSPITALARIO.SNH_CAT_SERVICIOS CATSERV
               ON CATSERV.SERVICIO_ID = RELUSALSERV.SERVICIO_ID
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGUSALSERV
                  ON CATESTREGUSALSERV.CATALOGO_ID = RELUSALSERV.ESTADO_REGISTRO
             LEFT JOIN HOSPITALARIO.SNH_CAT_CAMAS CATCAMAS
                  ON CATCAMAS.CAMA_ID = CFG.CAMA_ID
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGCAMAS  
                  ON CATESTREGCAMAS.CATALOGO_ID = CATCAMAS.ESTADO_REGISTRO_ID 
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTCAMA
               ON CATESTCAMA.CATALOGO_ID = CFG.ESTADO_CAMA_ID
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESREG
               ON CATESREG.CATALOGO_ID = CFG.ESTADO_REGISTRO_ID
             LEFT JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALSERV
               ON USALSERV.UNIDAD_SALUD_ID = RELUSALSERV.UNIDAD_SALUD_ID
             LEFT JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADMINSERV
               ON ENTADMINSERV.ENTIDAD_ADTVA_ID = USALSERV.ENTIDAD_ADTVA_ID
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESREGADM
               ON CATESREGADM.CATALOGO_ID = ADSERVCAMAS.ESTADO_REGISTRO_ID           
         WHERE ING.INGRESO_ID = pIngresoId AND
               ING.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
     RETURN vRegistro; 
 END FN_OBT_INGR_ID; 

 FUNCTION FN_OBT_INGR_EGR_PAG RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
 dbms_output.put_Line ('dentro de FN_OBT_INGR_EGR_PAG');
      OPEN vRegistro FOR
           SELECT *
                  --  INGRESO_ID,                      
                  --  PREG_INGRESO_ID
               FROM (
                    SELECT *
                     FROM HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP A,(
                          SELECT ROW_NUMBER () OVER (ORDER BY INGRESO_ID ASC)
                                 LINE_NUMBER, 
                                 INGRESO_ID,                      
                                 PREG_INGRESO_ID,              
                                 PRE_ESPECIALIDAD_DESTINO,     
                                 PREESPDEST_CODIGO,            
                                 PREESPDEST_NOMBRE,            
                                 PREESPDEST_DESCRIPCION,       
                                 PRE_USAL_ORIGEN_ID,           
                                 PRE_USAL_ORIGEN_NOMBRE,       
                                 PRE_USAL_ORIGEN_CODIGO,       
                                 PRE_ENTADM_ORIGEN_ID,         
                                 PRE_ENTADM_ORIGEN_NOMBRE,     
                                 PRE_USAL_DEST_ID,             
                                 PRE_USAL_DEST_NOMBRE,         
                                 PRE_USAL_DEST_CODIGO,         
                                 PRE_ENTADM_DEST_ID,           
                                 PRE_ENTADM_DEST_NOMBRE,       
                                 PER_NOMINAL_ID,               
                                 PRENOM_COD_EXPEDIENTE,        
                                 PRENOM_EXPEDIENTE_ID,         
                                 PRENOM_PNOMBRE,               
                                 PRENOM_SNOMBRE,               
                                 PRENOM_PAPELLIDO,             
                                 PRENOM_SAPELLIDO,             
                                 PRENOM_NOMB_COMPLETO,         
                                 PRENOM_TIP_IDENTIFICACION,    
                                 PRENOM_IDENTIF_CODIGO,        
                                 PRENOM_IDENTIF_NOMBRE,        
                                 PRENOM_IDENTIF_NUMERO,        
                                 PRENOM_SEXO_ID ,              
                                 PRENOM_SEXO_CODIGO,           
                                 PRENOM_SEXO_VALOR,            
                                 PRENOM_FEC_NACIMIENTO,        
                                 PRENOM_DET_PRS_RESINDENCIA_ID,
                                 PRENOM_COM_RESIDENCIA_ID,     
                                 PRENOM_COM_RESIDENCIA_NOMBRE, 
                                 PRENOM_MUNI_RESIDENCIA_ID,    
                                 PRENOM_MUNI_RESIDENCIA_NOMBRE,
                                 PRENOM_DEP_RESIDENCIA_ID,     
                                 PRENOM_DEP_RESIDENCIA_NOMBRE, 
                                 PRENOM_DIRECCION_RESIDENCIA,  
                                 PRENOM_TELEFONO_ID,           
                                 PRENOM_TELEFONO,              
                                 ING_PROCEDENCIA_ID,           
                                 CATPROC_CODIGO,               
                                 CATPROC_VALOR,                
                                 CATPROC_DESCRIPCION,          
                                 ADMISION_SERVICIO_ID,         
                                 EDAD_EXACTA_INGRESO,          
                                 GRUPO_ETAREO_ID,              
                                 ETAREO_EDAD_MINIMA,           
                                 ETAREO_EDAD_MAXIMA,           
                                 ETAREO_UMINIMA_ID,            
                                 ETAREO_UMAXIMA_ID,            
                                 ETAREO_CODIGO,                
                                 ETAREO_VALOR,                 
                                 ETAREO_DESCRIPCION,           
                                 MEDICO_INGRESO_ID,            
                                 MEDINGR_PRIMER_NOMBRE,        
                                 MEDINGR_SEGUNDO_NOMBRE,     
                                 MEDINGR_PRIMER_APELLIDO,
                                 MEDINGR_SEGUNDO_APELLIDO,  
                                 MEDINGR_COD_MINSA_PER, 
                                 MEDINGR_REG_SANITARIO,
                                 MEDINGR_TIPO_PERSONAL_ID,
                                 MEDINGR_COD_TIPO_PERSONAL,
                                 MEDINGR_VALOR_TIPO_PERSONAL,
                                 MEDINGR_DESC_TIPO_PERSONAL,
                                 ADMISIONISTA_SOLICITA_INGR_ID,
                                 ADMSOLINGR_PRIMER_NOMBRE,     
                                 ADMSOLINGR_SEGUNDO_NOMBRE,    
                                 ADMSOLINGR_PRIMER_APELLIDO,
                                 ADMSOLINGR_SEGUNDO_APELLIDO,  
                                 ADMSOLINGR_COD_MINSA_PER, 
                                 ADMSOLINGR_REG_SANITARIO,
                                 ADMSOLINGR_TIPO_PERSONAL_ID,
                                 ADMSOLINGR_COD_TIPO_PERSONAL,
                                 ADMSOLINGR_VALOR_TIPO_PERSONAL
                                 ADMSOLINGR_DESC_TIPO_PERSONAL,
                                 ADMISIONISTA_INGRESO_ID,      
                                 ADMINGR_PRIMER_NOMBRE,     
                                 ADMINGR_SEGUNDO_NOMBRE,    
                                 ADMINGR_PRIMER_APELLIDO,
                                 ADMINGR_SEGUNDO_APELLIDO,  
                                 ADMINGR_COD_MINSA_PER, 
                                 ADMINGR_REG_SANITARIO,
                                 ADMINGR_TIPO_PERSONAL_ID,
                                 ADMINGR_COD_TIPO_PERSONAL,
                                 ADMINGR_VALOR_TIPO_PERSONAL,
                                 ADMINGR_DESC_TIPO_PERSONAL,
                                 MEDICO_ORDENA_INGRESO_ID,     
                                 MEDORDING_PRIMER_NOMBRE,     
                                 MEDORDING_SEGUNDO_NOMBRE,    
                                 MEDORDING_PRIMER_APELLIDO,
                                 MEDORDING_SEGUNDO_APELLIDO,  
                                 MEDORDING_COD_MINSA_PER, 
                                 MEDORDING_REG_SANITARIO,
                                 MEDORDING_TIPO_PERSONAL_ID,
                                 MEDORDING_COD_TIPO_PERSONAL,
                                 MEDORDING_VALOR_TIPO_PERSONAL,
                                 MEDORDING_DESC_TIPO_PERSONAL,
                                 SERVICIO_PROCEDENCIA_ID,      
                                 PRE_SERV_PROCED_CODIGO,       
                                 PRE_SERV_PROCED_NOMBRE,       
                                 PRE_SERV_PROCED_DESCRIPCION,  
                                 REINGRESO,                    
                                 REINGRESO_ID,                 
                                 FECHA_SOLICITUD_INGRESO,      
                                 HORA_SOLICITUD_INGRESO ,      
                                 FECHA_INICIO_INGRESO,         
                                 HORA_INICIO_INGRESO,          
                                 UNIDAD_SALUD_INGRESO,         
                                 USAL_INGRESO_NOMBRE,          
                                 USAL_INGRESO_CODIGO,          
                                 ENTADM_INGRESO_ID,            
                                 ENTADM_INGRESO_NOMBRE,        
                                 SERV_ING_ID,                  
                                 SERV_ING_CODIGO,              
                                 SERV_ING_NOMBRE,              
                                 SERV_ING_DESCRIPCION,         
                                 ESTADO_INGRESO_ID,            
                                 CATESTING_CODIGO,             
                                 CATESTING_VALOR,              
                                 CATESTING_DESCRIPCION,        
                                 TIPO_EGRESO_ID,               
                                 CATTIPEGR_CODIGO,             
                                 CATTIPEGR_VALOR,              
                                 CATTIPEGR_DESCRIPCION,        
                                 FECHA_FIN_INGRESO,            
                                 HORA_FIN_INGRESO,             
                                 SERVICIO_EGRESO_ID,           
                                 SERVEGR_ING_CODIGO,           
                                 SERVEGR_ING_NOMBRE,           
                                 SERVEGR_ING_DESCRIPCION,      
                                 MEDICO_EGRESO_ID,             
                                 MEDEGRESO_PRIMER_NOMBRE,     
                                 MEDEGRESO_SEGUNDO_NOMBRE,    
                                 MEDEGRESO_PRIMER_APELLIDO,
                                 MEDEGRESO_SEGUNDO_APELLIDO,  
                                 MEDEGRESO_COD_MINSA_PER, 
                                 MEDEGRESO_REG_SANITARIO,
                                 MEDEGRESO_TIPO_PERSONAL_ID,
                                 MEDEGRESO_COD_TIPO_PERSONAL,
                                 MEDEGRESO_VALOR_TIPO_PERSONAL,
                                 MEDEGRESO_DESC_TIPO_PERSONAL,
                                 REFERENCIA_ID,                
                                 ES_CONTRAFERIDO,              
                                 ENVIO_CONTRAREFERENCIA_ID,    
                                 DIAS_ESTANCIA,                
                                 ESTADO_PX_ID,                 
                                 CATESTPX_CODIGO,              
                                 CATESTPX_VALOR,               
                                 CATESTPX_DESCRIPCION,         
                                 ESTADO_PX_EGRESO_ID,          
                                 CATESTPXEGR_CODIGO,           
                                 CATESTPXEGR_VALOR,            
                                 CATESTPXEGR_DESCRIPCION,      
                                 COMENTARIOS,                  
                                 ESTADO_REGISTRO_ID,           
                                 CATESTREG_CODIGO,             
                                 CATESTREG_VALOR,              
                                 CATESTREG_DESCRIPCION,        
                                 USR_REGISTRO,                 
                                 FECHA_REGISTRO,               
                                 USR_REGISTRO_EGRESO,          
                                 FEC_REGISTRO_EGRESO,          
                                 USR_MODIFICACION,             
                                 FEC_MODIFICACION,             
                                 USR_PASIVA,                   
                                 FEC_PASIVA,                   
                                 USR_ELIMINA,                  
                                 FEC_ELIMINA,
                                 ADSERV_SRV_CAMA_ID,
                                 CFG_USLD_SERVICIO_CAMA_ID,
                                 UND_SALUD_SERVICIO_ID, 
                                 ADSERV_USSERV_USALUD_ID,
                                 ADSERV_USSERV_NOMBRE,
                                 ADSERV_USSERV_CODIGO,
                                 ADSERV_USSERV_DIRECCION,
                                 ADSERV_USSERV_ENTADTVA_ID,
                                 ADSERV_ENTADMINSERV_NOMBRE,
                                 ADSERV_ENTADMINSERV_CODIGO,
                                 ADSERV_ENTADMINSERV_TELEFONO,
                                 ADSERV_ENTADMINSERV_EMAIL,
                                 ADSERV_ENTADMINSERV_DIRECCION,
                                 ADSERV_RELUSALSERV_SERVICIO_ID,
                                 ADSERV_CATSERV_CODIGO,
                                 ADSERV_CATSERV_NOMBRE,
                                 ADSERV_CATSERV_DESCRIPCION,
                                 ADSERV_CATSERV_PASIVO,
                                 ADSERV_RELUSALSERV_EST_REG,
                                 ADSERV_CATESTREGUSALSERV_COD,
                                 ADSERV_CATESTREGUSALSERV_VALOR,
                                 ADSERV_CATESTREGUSALSERV_DES,
                                 ADSERV_RELUSALSERV_USR_SERV,
                                 ADSERV_RELUSALSERV_FEC_REG, 
                                 CFG_COD_ASISTENCIAL,       
                                 CFG_SALA_ID,                  
                                 CFG_HABITACION_ID,            
                                 CFG_CAMA_ID,
                                 CATCAMAS_NOMBRE,
                                 CATCAMAS_COD_ADMIN,
                                 CATCAMAS_ESTADO_CAMA,
                                 CATCAMAS_NO_SERIE,
                                 CATCAMAS_EST_REG_ID,
                                 CATESTREGCAMAS_COD,    
                                 CATESTREGCAMAS_VALOR,
                                 CATESTREGCAMAS_DES,
                                 CATCAMAS_USR_REG,
                                 CATCAMAS_FEC_REG,      
                                 CFG_DISPONIBLE,                
                                 CFG_ADSERV_CENSABLE,       
                                 CFG_ADSERV_ESTADO_CAMA_ID, 
                                 CATESTCAMA_CODIGO,
                                 CATESTCAMA_VALOR,
                                 CATESTCAMA_DESCRIPCION,
                                 CFG_IS_LAST,                  
                                 CFG_ESTADO_REGISTRO_ID,  
                                 CATESREG_CODIGO,
                                 CATESREG_VALOR,
                                 CATESREG_DESC,
                                 CFG_USR_REGISTRO,           
                                 CFG_FEC_REGISTRO,      
                                 ADSERVCFG_ADMISION_SERV_ID,
                                 ADSERVCFG_FECHA_INI,
                                 ADSERVCFG_HORA_INI,
                                 ADSERVCFG_FECHA_FIN,
                                 ADSERVCFG_HORA_FIN,
                                 ADSERVCFG_IS_LAST,
                                 ADSERVCFG_ESTADO_REGISTRO_ID, 
                                 ADSERVCFG_CATESREG_CODIGO,
                                 ADSERVCFG_CATESREG_VALOR,
                                 ADSERVCFG_CATESREG_DESC,
                                 ADSERVCFG_USR_REGISTRO,
                                 ADSERVCFG_FEC_REGISTRO
                    FROM
                    (             
           SELECT ING.INGRESO_ID                         INGRESO_ID,                    -- Ingreso
                  ING.PREG_INGRESO_ID                    PREG_INGRESO_ID,                 -- pre ingreso      
                  PREING.ESPECIALIDAD_DESTINO_ID         PRE_ESPECIALIDAD_DESTINO,        -- pre ingreso    
                  ESPDEST.CODIGO                         PREESPDEST_CODIGO,                 -- catalogo  
                  ESPDEST.NOMBRE                         PREESPDEST_NOMBRE,                 -- catalogo
                  ESPDEST.DESCRIPCION                    PREESPDEST_DESCRIPCION,            -- catalogo
                  PREING.UNIDAD_SALUD_ORIGEN_ID          PRE_USAL_ORIGEN_ID,              -- pre ingreso
                  USALORI.NOMBRE                         PRE_USAL_ORIGEN_NOMBRE,            -- unidad salud
                  USALORI.CODIGO                         PRE_USAL_ORIGEN_CODIGO,            -- unidad salud
                  USALORI.ENTIDAD_ADTVA_ID               PRE_ENTADM_ORIGEN_ID,              -- unidad salud
                  ENTADVORI.NOMBRE                       PRE_ENTADM_ORIGEN_NOMBRE,            -- entidad admin
                  PREING.UNIDAD_SALUD_DESTINO_ID         PRE_USAL_DEST_ID,                -- pre ingreso
                  USALDEST.NOMBRE                        PRE_USAL_DEST_NOMBRE,              -- unidad salud
                  USALDEST.CODIGO                        PRE_USAL_DEST_CODIGO,              -- unidad salud
                  USALDEST.ENTIDAD_ADTVA_ID              PRE_ENTADM_DEST_ID,                -- unidad salud
                  ENTADVDEST.NOMBRE                      PRE_ENTADM_DEST_NOMBRE,              -- entidad admin
                  ING.PER_NOMINAL_ID                     PER_NOMINAL_ID,                  -- Ingreso              
                  NOM.CODIGO_EXPEDIENTE_ELECTRONICO      PRENOM_COD_EXPEDIENTE,             -- Nominal
                  NOM.EXPEDIENTE_ID                      PRENOM_EXPEDIENTE_ID,              -- Nominal
                  NOM.PRIMER_NOMBRE                      PRENOM_PNOMBRE,                    -- Nominal
                  NOM.SEGUNDO_NOMBRE                     PRENOM_SNOMBRE,                    -- Nominal
                  NOM.PRIMER_APELLIDO                    PRENOM_PAPELLIDO,                  -- Nominal
                  NOM.SEGUNDO_APELLIDO                   PRENOM_SAPELLIDO,                  -- Nominal 
                  NOM.NOMBRE_COMPLETO                    PRENOM_NOMB_COMPLETO,              -- Nominal
                  NOM.TIPO_IDENTIFICACION_ID             PRENOM_TIP_IDENTIFICACION,         -- Nominal
                  NOM.IDENTIFICACION_CODIGO              PRENOM_IDENTIF_CODIGO,             -- Nominal
                  NOM.IDENTIFICACION_NOMBRE              PRENOM_IDENTIF_NOMBRE,             -- Nominal
                  NOM.IDENTIFICACION_NUMERO              PRENOM_IDENTIF_NUMERO,             -- Nominal
                  NOM.SEXO_ID                            PRENOM_SEXO_ID ,                   -- Nominal
                  NOM.SEXO_CODIGO                        PRENOM_SEXO_CODIGO,                -- Nominal
                  NOM.SEXO_VALOR                         PRENOM_SEXO_VALOR,                 -- Nominal
                  NOM.FECHA_NACIMIENTO                   PRENOM_FEC_NACIMIENTO,             -- Nominal
                  NOM.DET_PRS_RESIDENCIA_ID              PRENOM_DET_PRS_RESINDENCIA_ID,     -- Nominal  
                  NOM.COMUNIDAD_RESIDENCIA_ID            PRENOM_COM_RESIDENCIA_ID,          -- Nominal
                  NOM.COMUNIDAD_RESIDENCIA_NOMBRE        PRENOM_COM_RESIDENCIA_NOMBRE,      -- Nominal
                  NOM.MUNICIPIO_RESIDENCIA_ID            PRENOM_MUNI_RESIDENCIA_ID,         -- Nominal
                  NOM.MUNICIPIO_RESIDENCIA_NOMBRE        PRENOM_MUNI_RESIDENCIA_NOMBRE,     -- Nominal
                  NOM.DEPARTAMENTO_RESIDENCIA_ID         PRENOM_DEP_RESIDENCIA_ID,          -- Nominal 
                  NOM.DEPARTAMENTO_RESIDENCIA_NOMBRE     PRENOM_DEP_RESIDENCIA_NOMBRE,      -- Nominal 
                  NOM.DIRECCION_RESIDENCIA               PRENOM_DIRECCION_RESIDENCIA,       -- Nominal
                  NOM.TELEFONO_ID                        PRENOM_TELEFONO_ID,                -- Nominal
                  NOM.TELEFONO                           PRENOM_TELEFONO,                   -- Nominal
                  ING.PROCEDENCIA_ID                     ING_PROCEDENCIA_ID,              -- Ingreso  
                  CATPROCED.CODIGO                       CATPROC_CODIGO,                    -- catalogo
                  CATPROCED.VALOR                        CATPROC_VALOR,                     -- catalogo
                  CATPROCED.DESCRIPCION                  CATPROC_DESCRIPCION,               -- catalogo
                  ING.ADMISION_SERVICIO_ID               ADMISION_SERVICIO_ID,            -- Ingreso        
                  ING.EDAD_EXACTA_INGRESO                EDAD_EXACTA_INGRESO,             -- Ingreso
                  ING.GRUPO_ETAREO_ID                    GRUPO_ETAREO_ID,                 -- Ingreso
                  CONFETAREO.MINIMO                      ETAREO_EDAD_MINIMA,                -- grupo etareo
                  CONFETAREO.MAXIMO                      ETAREO_EDAD_MAXIMA,                -- grupo etareo 
                  CONFETAREO.UMIN_ID                     ETAREO_UMINIMA_ID,                 -- grupo etareo 
                  CONFETAREO.UMAX_ID                     ETAREO_UMAXIMA_ID,                 -- grupo etareo
                  ETAREO.CODIGO                          ETAREO_CODIGO,                       -- catalogo
                  ETAREO.VALOR                           ETAREO_VALOR,                         -- catalogo
                  ETAREO.DESCRIPCION                     ETAREO_DESCRIPCION,                   -- catalogo
                  ING.MEDICO_INGRESO_ID                  MEDICO_INGRESO_ID,               -- Ingreso                        
                  PER.PRIMER_NOMBRE                      MEDINGR_PRIMER_NOMBRE,              ---     
                  PER.SEGUNDO_NOMBRE                     MEDINGR_SEGUNDO_NOMBRE,     
                  PER.PRIMER_APELLIDO                    MEDINGR_PRIMER_APELLIDO,
                  PER.SEGUNDO_APELLIDO                   MEDINGR_SEGUNDO_APELLIDO,  
                  MEDINGRESO.CODIGO                      MEDINGR_COD_MINSA_PER, 
                  MPERSALUD.REGISTRO_SANITARIO           MEDINGR_REG_SANITARIO,
                  MEDINGRESO.TIPO_PERSONAL_ID            MEDINGR_TIPO_PERSONAL_ID,
                  CAT.CODIGO                             MEDINGR_COD_TIPO_PERSONAL,
                  CAT.VALOR                              MEDINGR_VALOR_TIPO_PERSONAL,
                  CAT.DESCRIPCION                        MEDINGR_DESC_TIPO_PERSONAL,
                  ING.ADMISIONISTA_SOLICITA_INGR_ID      ADMISIONISTA_SOLICITA_INGR_ID,   -- Ingreso
                  PER1.PRIMER_NOMBRE                     ADMSOLINGR_PRIMER_NOMBRE,                  
                  PER1.SEGUNDO_NOMBRE                    ADMSOLINGR_SEGUNDO_NOMBRE,     
                  PER1.PRIMER_APELLIDO                   ADMSOLINGR_PRIMER_APELLIDO,
                  PER1.SEGUNDO_APELLIDO                  ADMSOLINGR_SEGUNDO_APELLIDO,  
                  ADMINSOLINGRESO.CODIGO                 ADMSOLINGR_COD_MINSA_PER, 
                  MPERSALUD1.REGISTRO_SANITARIO          ADMSOLINGR_REG_SANITARIO,
                  ADMINSOLINGRESO.TIPO_PERSONAL_ID       ADMSOLINGR_TIPO_PERSONAL_ID,
                  CAT1.CODIGO                            ADMSOLINGR_COD_TIPO_PERSONAL,
                  CAT1.VALOR                             ADMSOLINGR_VALOR_TIPO_PERSONAL,
                  CAT1.DESCRIPCION                       ADMSOLINGR_DESC_TIPO_PERSONAL,                  
                  ING.ADMISIONISTA_INGRESO_ID            ADMISIONISTA_INGRESO_ID,         -- Ingreso   
                  PER2.PRIMER_NOMBRE                     ADMINGR_PRIMER_NOMBRE,     
                  PER2.SEGUNDO_NOMBRE                    ADMINGR_SEGUNDO_NOMBRE,    
                  PER2.PRIMER_APELLIDO                   ADMINGR_PRIMER_APELLIDO,
                  PER2.SEGUNDO_APELLIDO                  ADMINGR_SEGUNDO_APELLIDO,  
                  ADMININGRESO.CODIGO                    ADMINGR_COD_MINSA_PER, 
                  MPERSALUD2.REGISTRO_SANITARIO          ADMINGR_REG_SANITARIO,
                  ADMININGRESO.TIPO_PERSONAL_ID          ADMINGR_TIPO_PERSONAL_ID,
                  CAT2.CODIGO                            ADMINGR_COD_TIPO_PERSONAL,
                  CAT2.VALOR                             ADMINGR_VALOR_TIPO_PERSONAL,
                  CAT2.DESCRIPCION                       ADMINGR_DESC_TIPO_PERSONAL,
                  ING.MEDICO_ORDENA_INGRESO_ID           MEDICO_ORDENA_INGRESO_ID,        -- Ingreso   
                  PER3.PRIMER_NOMBRE                     MEDORDING_PRIMER_NOMBRE,     
                  PER3.SEGUNDO_NOMBRE                    MEDORDING_SEGUNDO_NOMBRE,    
                  PER3.PRIMER_APELLIDO                   MEDORDING_PRIMER_APELLIDO,
                  PER3.SEGUNDO_APELLIDO                  MEDORDING_SEGUNDO_APELLIDO,  
                  MEDORDENAING.CODIGO                    MEDORDING_COD_MINSA_PER, 
                  MPERSALUD3.REGISTRO_SANITARIO          MEDORDING_REG_SANITARIO,
                  MEDORDENAING.TIPO_PERSONAL_ID          MEDORDING_TIPO_PERSONAL_ID,
                  CAT3.CODIGO                            MEDORDING_COD_TIPO_PERSONAL,
                  CAT3.VALOR                             MEDORDING_VALOR_TIPO_PERSONAL,
                  CAT3.DESCRIPCION                       MEDORDING_DESC_TIPO_PERSONAL,
                  ING.SERVICIO_PROCEDENCIA_ID            SERVICIO_PROCEDENCIA_ID,         -- Ingreso 
                  SERV.CODIGO                            PRE_SERV_PROCED_CODIGO,            -- servicio              
                  SERV.NOMBRE                            PRE_SERV_PROCED_NOMBRE,            -- servicio             
                  SERV.DESCRIPCION                       PRE_SERV_PROCED_DESCRIPCION,       -- servicio                 
                  ING.REINGRESO                          REINGRESO,                       -- Ingreso                
                  ING.REINGRESO_ID                       REINGRESO_ID,                    -- Ingreso      
                  ING.FECHA_SOLICITUD_INGRESO            FECHA_SOLICITUD_INGRESO,         -- Ingreso
                  ING.HORA_SOLICITUD_INGRESO             HORA_SOLICITUD_INGRESO ,         -- Ingreso
                  ING.FECHA_INICIO_INGRESO               FECHA_INICIO_INGRESO,            -- Ingreso
                  ING.HORA_INICIO_INGRESO                HORA_INICIO_INGRESO,             -- Ingreso 
                  ING.UNIDAD_SALUD_INGRESO               UNIDAD_SALUD_INGRESO,            -- Ingreso
                  USALING.NOMBRE                         USAL_INGRESO_NOMBRE,               -- unidad salud
                  USALING.CODIGO                         USAL_INGRESO_CODIGO,               -- unidad salud
                  USALING.ENTIDAD_ADTVA_ID               ENTADM_INGRESO_ID,                 -- unidad salud
                  ENTADING.NOMBRE                        ENTADM_INGRESO_NOMBRE,               -- entidad admin
                  ING.SERVICIO_INGRESO_ID                SERV_ING_ID,                     -- Ingreso
                  SERVING.CODIGO                         SERV_ING_CODIGO,                   -- servicio
                  SERVING.NOMBRE                         SERV_ING_NOMBRE,                   -- servicio
                  SERVING.DESCRIPCION                    SERV_ING_DESCRIPCION,              -- servicio 
                  ING.ESTADO_INGRESO_ID                  ESTADO_INGRESO_ID,               -- Ingreso
                  CATESTING.CODIGO                       CATESTING_CODIGO,                  -- catalogo
                  CATESTING.VALOR                        CATESTING_VALOR,                   -- catalogo
                  CATESTING.DESCRIPCION                  CATESTING_DESCRIPCION,             -- catalogo
                  ING.TIPO_EGRESO_ID                     TIPO_EGRESO_ID,                  -- Ingreso       
                  CATTIPEGR.CODIGO                       CATTIPEGR_CODIGO,                  -- catalogo
                  CATTIPEGR.VALOR                        CATTIPEGR_VALOR,                   -- catalogo
                  CATTIPEGR.DESCRIPCION                  CATTIPEGR_DESCRIPCION,             -- catalogo
                  ING.FECHA_FIN_INGRESO                  FECHA_FIN_INGRESO,               -- Ingreso
                  ING.HORA_FIN_INGRESO                   HORA_FIN_INGRESO,                -- Ingreso
                  ING.SERVICIO_EGRESO_ID                 SERVICIO_EGRESO_ID,              -- Ingreso
                  SERVEGR.CODIGO                         SERVEGR_ING_CODIGO,                -- servicio 
                  SERVEGR.NOMBRE                         SERVEGR_ING_NOMBRE,                -- servicio
                  SERVEGR.DESCRIPCION                    SERVEGR_ING_DESCRIPCION,           -- servicio             
                  ING.MEDICO_EGRESO_ID                   MEDICO_EGRESO_ID,                -- Ingreso
                  PER4.PRIMER_NOMBRE                     MEDEGRESO_PRIMER_NOMBRE,     
                  PER4.SEGUNDO_NOMBRE                    MEDEGRESO_SEGUNDO_NOMBRE,    
                  PER4.PRIMER_APELLIDO                   MEDEGRESO_PRIMER_APELLIDO,
                  PER4.SEGUNDO_APELLIDO                  MEDEGRESO_SEGUNDO_APELLIDO,  
                  MEDEGRESO.CODIGO                       MEDEGRESO_COD_MINSA_PER, 
                  MPERSALUD4.REGISTRO_SANITARIO          MEDEGRESO_REG_SANITARIO,
                  MEDEGRESO.TIPO_PERSONAL_ID             MEDEGRESO_TIPO_PERSONAL_ID,
                  CAT4.CODIGO                            MEDEGRESO_COD_TIPO_PERSONAL,
                  CAT4.VALOR                             MEDEGRESO_VALOR_TIPO_PERSONAL,
                  CAT4.DESCRIPCION                       MEDEGRESO_DESC_TIPO_PERSONAL,
                  ING.REFERENCIA_ID                      REFERENCIA_ID,                   -- Ingreso
                  ING.ES_CONTRAFERIDO                    ES_CONTRAFERIDO,                 -- Ingreso          
                  ING.ENVIO_CONTRAREFERENCIA_ID          ENVIO_CONTRAREFERENCIA_ID,       -- Ingreso
                  ING.DIAS_ESTANCIA                      DIAS_ESTANCIA,                   -- Ingreso
                  ING.ESTADO_PX_ID                       ESTADO_PX_ID,                    -- Ingreso
                  CATESTPX.CODIGO                        CATESTPX_CODIGO,                   -- catalogo
                  CATESTPX.VALOR                         CATESTPX_VALOR,                    -- catalogo
                  CATESTPX.DESCRIPCION                   CATESTPX_DESCRIPCION,              -- catalogo          
                  ING.ESTADO_PX_EGRESO_ID                ESTADO_PX_EGRESO_ID,             -- Ingreso          
                  CATESTPXEGR.CODIGO                     CATESTPXEGR_CODIGO,                -- catalogo
                  CATESTPXEGR.VALOR                      CATESTPXEGR_VALOR,                 -- catalogo
                  CATESTPXEGR.DESCRIPCION                CATESTPXEGR_DESCRIPCION,           -- catalogo
                  ING.COMENTARIOS                        COMENTARIOS,                     -- Ingreso
                  ING.ESTADO_REGISTRO_ID                 ESTADO_REGISTRO_ID,              -- Ingreso
                  CATESTREG.CODIGO                       CATESTREG_CODIGO,                  -- catalogo
                  CATESTREG.VALOR                        CATESTREG_VALOR,                   -- catalogo
                  CATESTREG.DESCRIPCION                  CATESTREG_DESCRIPCION,             -- catalogo          
                  ING.USUARIO_REGISTRO                   USR_REGISTRO,                    -- Ingreso
                  ING.FECHA_REGISTRO                     FECHA_REGISTRO,                  -- Ingreso
                  ING.USUARIO_REGISTRO_EGRESO            USR_REGISTRO_EGRESO,             -- Ingreso
                  ING.FECHA_REGISTRO_EGRESO              FEC_REGISTRO_EGRESO,             -- Ingreso 
                  ING.USUARIO_MODIFICACION               USR_MODIFICACION,                -- Ingreso
                  ING.FECHA_MODIFICACION                 FEC_MODIFICACION,                -- Ingreso 
                  ING.USUARIO_PASIVA                     USR_PASIVA,                      -- Ingreso
                  ING.FECHA_PASIVA                       FEC_PASIVA,                      -- Ingreso
                  ING.USUARIO_ELIMINA                    USR_ELIMINA,                     -- Ingreso
                  ING.FECHA_ELIMINA                      FEC_ELIMINA,                      -- Ingreso
                  ADSERVCAMAS.ADMISION_SRV_CAMA_ID       ADSERV_SRV_CAMA_ID,
                  ADSERVCAMAS.CFG_USLD_SERVICIO_CAMA_ID  CFG_USLD_SERVICIO_CAMA_ID,
                  CFG.UND_SALUD_SERVICIO_ID              UND_SALUD_SERVICIO_ID, 
                  RELUSALSERV.UNIDAD_SALUD_ID            ADSERV_USSERV_USALUD_ID,
                  USALSERV.NOMBRE                        ADSERV_USSERV_NOMBRE,
                  USALSERV.CODIGO                        ADSERV_USSERV_CODIGO,
                  USALSERV.DIRECCION                     ADSERV_USSERV_DIRECCION,
                  USALSERV.ENTIDAD_ADTVA_ID              ADSERV_USSERV_ENTADTVA_ID,
                  ENTADMINSERV.NOMBRE                    ADSERV_ENTADMINSERV_NOMBRE,
                  ENTADMINSERV.CODIGO                    ADSERV_ENTADMINSERV_CODIGO,
                  ENTADMINSERV.TELEFONO                  ADSERV_ENTADMINSERV_TELEFONO,
                  ENTADMINSERV.EMAIL                     ADSERV_ENTADMINSERV_EMAIL,
                  ENTADMINSERV.DIRECCION                 ADSERV_ENTADMINSERV_DIRECCION,
                  RELUSALSERV.SERVICIO_ID                ADSERV_RELUSALSERV_SERVICIO_ID,
                  CATSERV.CODIGO                         ADSERV_CATSERV_CODIGO,
                  CATSERV.NOMBRE                         ADSERV_CATSERV_NOMBRE,
                  CATSERV.DESCRIPCION                    ADSERV_CATSERV_DESCRIPCION,
                  CATSERV.PASIVO                         ADSERV_CATSERV_PASIVO,
                  RELUSALSERV.ESTADO_REGISTRO            ADSERV_RELUSALSERV_EST_REG,
                  CATESTREGUSALSERV.CODIGO               ADSERV_CATESTREGUSALSERV_COD,
                  CATESTREGUSALSERV.VALOR                ADSERV_CATESTREGUSALSERV_VALOR,
                  CATESTREGUSALSERV.DESCRIPCION          ADSERV_CATESTREGUSALSERV_DES,
                  RELUSALSERV.USUARIO_REGISTRO           ADSERV_RELUSALSERV_USR_SERV,
                  RELUSALSERV.FECHA_REGISTRO             ADSERV_RELUSALSERV_FEC_REG, 
                  CFG.CODIGO_ASISTENCIAL                 CFG_COD_ASISTENCIAL,       
                  CFG.SALA_ID                            CFG_SALA_ID,                  
                  CFG.HABITACION_ID                      CFG_HABITACION_ID,            
                  CFG.CAMA_ID                            CFG_CAMA_ID,
                  CATCAMAS.NOMBRE                        CATCAMAS_NOMBRE,
                  CATCAMAS.CODIGO_ADMINISTRATIVO         CATCAMAS_COD_ADMIN,
                  CATCAMAS.ESTADO_CAMA                   CATCAMAS_ESTADO_CAMA,
                  CATCAMAS.NO_SERIE                      CATCAMAS_NO_SERIE, 
                  CATCAMAS.ESTADO_REGISTRO_ID            CATCAMAS_EST_REG_ID,
                  CATESTREGCAMAS.CODIGO                  CATESTREGCAMAS_COD,    
                  CATESTREGCAMAS.VALOR                   CATESTREGCAMAS_VALOR,
                  CATESTREGCAMAS.DESCRIPCION             CATESTREGCAMAS_DES,
                  CATCAMAS.USUARIO_REGISTRO              CATCAMAS_USR_REG,
                  CATCAMAS.FECHA_REGISTRO                CATCAMAS_FEC_REG,      
                  CFG.DISPONIBLE                         CFG_DISPONIBLE,                
                  CFG.CENSABLE                           CFG_ADSERV_CENSABLE,       
                  CFG.ESTADO_CAMA_ID                     CFG_ADSERV_ESTADO_CAMA_ID, 
                  CATESTCAMA.CODIGO                      CATESTCAMA_CODIGO,
                  CATESTCAMA.VALOR                       CATESTCAMA_VALOR,
                  CATESTCAMA.DESCRIPCION                 CATESTCAMA_DESCRIPCION,
                  CFG.IS_LAST                            CFG_IS_LAST,                  
                  CFG.ESTADO_REGISTRO_ID                 CFG_ESTADO_REGISTRO_ID,  
                  CATESREG.CODIGO                        CATESREG_CODIGO,
                  CATESREG.VALOR                         CATESREG_VALOR,
                  CATESREG.DESCRIPCION                   CATESREG_DESC,
                  CFG.USUARIO_REGISTRO                   CFG_USR_REGISTRO,           
                  CFG.FECHA_REGISTRO                     CFG_FEC_REGISTRO,      
                  ADSERVCAMAS.ADMISION_SERVICIO_ID       ADSERVCFG_ADMISION_SERV_ID,
                  ADSERVCAMAS.FECHA_INI                  ADSERVCFG_FECHA_INI,
                  ADSERVCAMAS.HORA_INI                   ADSERVCFG_HORA_INI,
                  ADSERVCAMAS.FECHA_FIN                  ADSERVCFG_FECHA_FIN,
                  ADSERVCAMAS.HORA_FIN                   ADSERVCFG_HORA_FIN,
                  ADSERVCAMAS.IS_LAST                    ADSERVCFG_IS_LAST,
                  ADSERVCAMAS.ESTADO_REGISTRO_ID         ADSERVCFG_ESTADO_REGISTRO_ID, 
                  CATESREGADM.CODIGO                     ADSERVCFG_CATESREG_CODIGO,
                  CATESREGADM.VALOR                      ADSERVCFG_CATESREG_VALOR,
                  CATESREGADM.DESCRIPCION                ADSERVCFG_CATESREG_DESC,
                  ADSERVCAMAS.USUARIO_REGISTRO           ADSERVCFG_USR_REGISTRO,
                  ADSERVCAMAS.FECHA_REGISTRO             ADSERVCFG_FEC_REGISTRO
             FROM HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS ING
             JOIN HOSPITALARIO.SNH_MST_PREG_INGRESOS PREING 
               ON PREING.PREG_INGRESO_ID = ING.PREG_INGRESO_ID  
             JOIN HOSPITALARIO.SNH_CAT_SERVICIOS ESPDEST
               ON ESPDEST.SERVICIO_ID = PREING.ESPECIALIDAD_DESTINO_ID                            
             JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALORI
               ON USALORI.UNIDAD_SALUD_ID = PREING.UNIDAD_SALUD_ORIGEN_ID
             JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADVORI
               ON ENTADVORI.ENTIDAD_ADTVA_ID = USALORI.ENTIDAD_ADTVA_ID
             JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALDEST
               ON USALDEST.UNIDAD_SALUD_ID = PREING.UNIDAD_SALUD_DESTINO_ID
             JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADVDEST
               ON ENTADVDEST.ENTIDAD_ADTVA_ID = USALDEST.ENTIDAD_ADTVA_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS_NOMINAL NOM
               ON NOM.PER_NOMINAL_ID = ING.PER_NOMINAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CATPROCED
               ON CATPROCED.CATALOGO_ID = ING.PROCEDENCIA_ID
             JOIN HOSPITALARIO.SNH_REL_CNF_GRUPO_CATALOGOS CONFETAREO
               ON CONFETAREO.CNF_ID = ING.GRUPO_ETAREO_ID  
             JOIN CATALOGOS.SBC_CAT_CATALOGOS ETAREO
               ON ETAREO.CATALOGO_ID = CONFETAREO.CATALOGO_CNF_ID 
             JOIN HOSPITALARIO.SNH_CAT_SERVICIOS SERV
               ON SERV.SERVICIO_ID = ING.SERVICIO_PROCEDENCIA_ID
             JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALING
               ON USALING.UNIDAD_SALUD_ID = ING.UNIDAD_SALUD_INGRESO
             JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADING
               ON ENTADING.ENTIDAD_ADTVA_ID = USALING.ENTIDAD_ADTVA_ID                    
             LEFT JOIN HOSPITALARIO.SNH_CAT_SERVICIOS SERVING
               ON SERVING.SERVICIO_ID = ING.SERVICIO_INGRESO_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTING
               ON CATESTING.CATALOGO_ID = ING.ESTADO_INGRESO_ID 
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATTIPEGR 
               ON CATTIPEGR.CATALOGO_ID = ING.TIPO_EGRESO_ID
             LEFT JOIN HOSPITALARIO.SNH_CAT_SERVICIOS SERVEGR
               ON SERVEGR.SERVICIO_ID = ING.SERVICIO_EGRESO_ID 
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTPX
               ON CATESTPX.CATALOGO_ID = ING.ESTADO_PX_ID 
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTPXEGR
               ON CATESTPXEGR.CATALOGO_ID = ING.ESTADO_PX_EGRESO_ID                     
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREG
               ON CATESTREG.CATALOGO_ID = ING.ESTADO_REGISTRO_ID
             JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES MEDINGRESO
               ON MEDINGRESO.MINSA_PERSONAL_ID = ING.MEDICO_INGRESO_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS PER
               ON MEDINGRESO.PERSONA_ID = PER.PERSONA_ID
             JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD
               ON MPERSALUD.MINSA_PERSONAL_ID = MEDINGRESO.MINSA_PERSONAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT
               ON CAT.CATALOGO_ID = MEDINGRESO.TIPO_PERSONAL_ID          
             JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES ADMINSOLINGRESO
               ON ADMINSOLINGRESO.MINSA_PERSONAL_ID = ING.ADMISIONISTA_SOLICITA_INGR_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS PER1
               ON ADMINSOLINGRESO.PERSONA_ID = PER1.PERSONA_ID
             JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD1
               ON MPERSALUD1.MINSA_PERSONAL_ID = ADMINSOLINGRESO.MINSA_PERSONAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT1
               ON CAT1.CATALOGO_ID = ADMINSOLINGRESO.TIPO_PERSONAL_ID           
             JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES ADMININGRESO
               ON ADMININGRESO.MINSA_PERSONAL_ID = ING.ADMISIONISTA_INGRESO_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS PER2
               ON ADMININGRESO.PERSONA_ID = PER2.PERSONA_ID
             JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD2
               ON MPERSALUD2.MINSA_PERSONAL_ID = ADMININGRESO.MINSA_PERSONAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT2
               ON CAT2.CATALOGO_ID = ADMININGRESO.TIPO_PERSONAL_ID   
             JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES MEDORDENAING
               ON MEDORDENAING.MINSA_PERSONAL_ID = ING.MEDICO_ORDENA_INGRESO_ID
             JOIN CATALOGOS.SBC_MST_PERSONAS PER3
               ON MEDORDENAING.PERSONA_ID = PER3.PERSONA_ID
             JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD3
               ON MPERSALUD3.MINSA_PERSONAL_ID = MEDORDENAING.MINSA_PERSONAL_ID
             JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT3
               ON CAT3.CATALOGO_ID = MEDORDENAING.TIPO_PERSONAL_ID          
             LEFT JOIN CATALOGOS.SBC_MST_MINSA_PERSONALES MEDEGRESO
               ON MEDEGRESO.MINSA_PERSONAL_ID = ING.MEDICO_EGRESO_ID
             LEFT JOIN CATALOGOS.SBC_MST_PERSONAS PER4
               ON MEDEGRESO.PERSONA_ID = PER4.PERSONA_ID
             LEFT JOIN CATALOGOS.SBC_MST_MPERS_SALUD MPERSALUD4
               ON MPERSALUD4.MINSA_PERSONAL_ID = MEDEGRESO.MINSA_PERSONAL_ID
             LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CAT4
               ON CAT4.CATALOGO_ID = MEDEGRESO.TIPO_PERSONAL_ID     --------------
               LEFT JOIN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS ADSERVCAMAS --ADSERVAMAS
                 ON ADSERVCAMAS.ADMISION_SERVICIO_ID = ING.ADMISION_SERVICIO_ID AND
                    ADSERVCAMAS.IS_LAST = 1
                    LEFT JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFG
                      ON ADSERVCAMAS.CFG_USLD_SERVICIO_CAMA_ID = CFG.CFG_USLD_SERVICIO_CAMA_ID
                      AND CFG.IS_LAST = 1
                   LEFT JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS RELUSALSERV
                      ON RELUSALSERV.UND_SALUD_SERVICIO_ID = CFG.UND_SALUD_SERVICIO_ID
                   LEFT JOIN HOSPITALARIO.SNH_CAT_SERVICIOS CATSERV
                      ON CATSERV.SERVICIO_ID = RELUSALSERV.SERVICIO_ID
                   LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGUSALSERV
                      ON CATESTREGUSALSERV.CATALOGO_ID = RELUSALSERV.ESTADO_REGISTRO
                   LEFT JOIN HOSPITALARIO.SNH_CAT_CAMAS CATCAMAS
                      ON CATCAMAS.CAMA_ID = CFG.CAMA_ID
                   LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGCAMAS  
                      ON CATESTREGCAMAS.CATALOGO_ID = CATCAMAS.ESTADO_REGISTRO_ID 
                   LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTCAMA
                      ON CATESTCAMA.CATALOGO_ID = CFG.ESTADO_CAMA_ID
                   LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESREG
                      ON CATESREG.CATALOGO_ID = CFG.ESTADO_REGISTRO_ID
                   LEFT JOIN CATALOGOS.SBC_CAT_UNIDADES_SALUD USALSERV
                      ON USALSERV.UNIDAD_SALUD_ID = RELUSALSERV.UNIDAD_SALUD_ID
                   LEFT JOIN CATALOGOS.SBC_CAT_ENTIDADES_ADTVAS ENTADMINSERV
                      ON ENTADMINSERV.ENTIDAD_ADTVA_ID = USALSERV.ENTIDAD_ADTVA_ID
                   LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESREGADM
                      ON CATESREGADM.CATALOGO_ID = ADSERVCAMAS.ESTADO_REGISTRO_ID                    
         WHERE ING.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                      )
                                  )B
                WHERE  A.ID = B.INGRESO_ID 
               ORDER BY LINE_NUMBER);          
     RETURN vRegistro; 
 END FN_OBT_INGR_EGR_PAG; 
 
 FUNCTION FN_OBT_DATOS_INGRESOS (pConsulta IN HOSPITALARIO.OBJ_INGRESO_EGRESO,
                                 pPgn      IN BOOLEAN,
                                 pFuente   IN NUMBER) RETURN var_refcursor AS
 vRegistro var_refcursor;                                 
 BEGIN
     dbms_output.put_Line ('FN_OBT_DATOS_INGRESOS');
     CASE
     WHEN pFuente = 1 THEN
          vRegistro := FN_OBT_INGR_ID (pConsulta.IngresoId);
     
     ELSE
          vRegistro := FN_OBT_INGR_EGR_PAG;
     END CASE; 
     dbms_output.put_Line ('Despues de FN_OBT_INGR_EGR_PAG: '||sqlerrm);
  RETURN vRegistro;
 END FN_OBT_DATOS_INGRESOS;
 
 PROCEDURE PR_C_INGRESO (pConsulta        IN HOSPITALARIO.OBJ_INGRESO_EGRESO,
                         pPgn             IN NUMBER,
                         pPgnAct          IN NUMBER, 
                         pPgnTmn          IN NUMBER,
                         pTipIngEgr       IN VARCHAR2,
                         pDatosPaginacion OUT var_refcursor,                         
                         pRegistro        OUT var_refcursor,
                         pResultado       OUT VARCHAR2,
                         pMsgError        OUT VARCHAR2) IS

 vFirma           MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_C_INGRESO => ';
 vFuente          SIMPLE_INTEGER := 0;
 vPgn             BOOLEAN := FALSE;
 vFechaInicio     DATE;
 vFechaFin        DATE;
 vNombreCompleto  MAXVARCHAR2;
 vPrimerNombre    MAXVARCHAR2;
 vSegundoNombre   MAXVARCHAR2;
 vPrimerApellido  MAXVARCHAR2;
 vSegundoApellido MAXVARCHAR2;
 vSexo            MAXVARCHAR2;
 vUnidadSaludId   NUMBER;
 vMunicipioId     NUMBER;
 vEntAdminId      NUMBER;
 vCantRegistros   SIMPLE_INTEGER := 0;
 vPaginacion HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos;  
 BEGIN
--     CASE
--     WHEN nvl(pPgn,0) = 1 THEN
          vPgn := TRUE;
--     ELSE NULL;
--     END CASE; 
     CASE
     WHEN pConsulta.FecInicio IS NOT NULL AND pConsulta.FecFin IS NOT NULL THEN
       CASE
       WHEN pTipIngEgr IS NULL THEN
            pResultado := 'Tiene que especificar si quiere consultar un Ingreso o un Egreso';
            pMsgError  := pResultado;
            RAISE eParametroNull;    
       WHEN pTipIngEgr NOT IN (kINGRESO, kEGRESO) THEN
            pResultado := 'Parámetro invalido: [TipoIngEgr: '||pTipIngEgr||']';
            pMsgError  := pResultado;
            RAISE eParametrosInvalidos; 
       ELSE NULL;
       END CASE;     
     ELSE NULL;
     END CASE;  
     CASE
     WHEN (FN_VAL_EXISTE_INGRESO (pConsulta, pTipIngEgr, vPgn, vCantRegistros, vFuente)) = TRUE THEN 
            CASE
            WHEN vPgn THEN
                 HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_INDC_PAGINACION_PERSONA(PREGISTROS  => vCantRegistros, 
                                                                            pPgnAct     => pPgnAct, 
                                                                            pPgnTmn     => pPgnTmn, 
                                                                            pPaginacion => vPaginacion, 
                                                                            pMsg        => pMsgError);
                 CASE 
                 WHEN pMsgError IS NOT NULL THEN 
                      pResultado := pMsgError;
                      pMsgError  := pMsgError;
                      RAISE eSalidaConError;
                 ELSE 
                      pDatosPaginacion := FN_OBT_DATOS_PAGINACION (pDatosPaginacion =>  vPaginacion); --pQuery =>  vQuery);
                 END CASE;            
                 PR_I_TABLA_TEMPORAL_ING_EGRE (pConsulta        => HOSPITALARIO.OBJ_INGRESO_EGRESO (pConsulta.IngresoId,        
                                                                                                    pConsulta.PregIngresoId,    
                                                                                                    pConsulta.PerNominalId,     
                                                                                                    pConsulta.ExpedienteId,     
                                                                                                    pConsulta.NombreCompleto,   
                                                                                                    pConsulta.ProcedenciaId,    
                                                                                                    pConsulta.CodExpElectronico,
                                                                                                    pConsulta.Identificacion,   
                                                                                                    pConsulta.AdmisionId,       
                                                                                                    pConsulta.MedicoIngId,      
                                                                                                    pConsulta.AdminSolicIngId,  
                                                                                                    pConsulta.AdmisionistaIngId,
                                                                                                    pConsulta.MedOrdenaIngId,   
                                                                                                    pConsulta.ServProcedenId,   
                                                                                                    pConsulta.Reingreso,        
                                                                                                    pConsulta.FecInicio,        
                                                                                                    pConsulta.FecFin,           
                                                                                                    pConsulta.UsalProcedeId,    
                                                                                                    pConsulta.UsalIngresoId,    
                                                                                                    pConsulta.ServIngresoId,    
                                                                                                    pConsulta.EstadoIngId,      
                                                                                                    pConsulta.TipoEgresoId,     
                                                                                                    pConsulta.ServEgresoId,     
                                                                                                    pConsulta.MedicoEgresoId,   
                                                                                                    pConsulta.EsContraferido,   
                                                                                                    pConsulta.EstadoPxId,       
                                                                                                    pConsulta.EstadoPxEgresoId),
                                               pMunicipioId       => null,  -- vMunicipioId,    
                                               pEntAdminId        => null,  -- vEntAdminId,     
                                               pPgnAct            => pPgnAct,        
                                               pPgnTmn            => pPgnTmn,       
                                               pTipoPaginacion    => vFuente,
                                               pResultado         => pResultado,     
                                               pMsgError          => pMsgError); 
                                 dbms_output.put_line ('Error saliendo de I tabla temporal pre: '||pMsgError);              
                                 CASE
                                 WHEN pMsgError IS NOT NULL THEN 
                                      RAISE eSalidaConError;
                                 ELSE NULL;
                                 END CASE;
            ELSE NULL; 
            END CASE;                                  
           dbms_output.put_Line ('despues de validar existe ingreso');
                   pRegistro := FN_OBT_DATOS_INGRESOS(pConsulta, vPgn, vFuente);
           dbms_output.put_Line ('despues de obtener ingreso');        
     ELSE
     CASE
     WHEN NVL(pConsulta.IngresoId,0) > 0 THEN
          pResultado := 'No se encontraron registros de ingresos relacionadas al [Ingreso Id: '||pConsulta.IngresoId||']';
          RAISE eRegistroNoExiste;
     WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
           NVL(pConsulta.ExpedienteId,0) > 0)  THEN
           pResultado := 'No se encontraron registros de ingresos relacionadas al [pPerNominalId: '||pConsulta.PerNominalId||'] - [pExpedienteId: '||pConsulta.ExpedienteId||']';
           RAISE eRegistroNoExiste;
     WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
           pResultado := 'No se encontraron registros de ingresos relacionadas al [Nominal Id: '||pConsulta.PerNominalId||']';
           RAISE eRegistroNoExiste;
     WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
           pResultado := 'No se encontraron registros de ingresos relacionadas al [Expediente Id: '||pConsulta.ExpedienteId||']';
           RAISE eRegistroNoExiste;     
     WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
           pResultado := 'No se encontraron registros de ingresos relacionadas al [codigo expediente: '||pConsulta.CodExpElectronico||']';
           RAISE eRegistroNoExiste;
     WHEN pConsulta.Identificacion IS NOT NULL THEN
           pResultado := 'No se encontraron registros de ingresos relacionadas a la [Identificación: '||pConsulta.Identificacion||']';
           RAISE eRegistroNoExiste;
     WHEN (pConsulta.NombreCompleto IS NOT NULL AND
           NVL (pConsulta.UsalIngresoId,0) > 0) THEN
           pResultado := 'No se encontraron registros de ingresos relacionadas a [Nombre: '||pConsulta.NombreCompleto||'] - [Unidad salud destino: '||pConsulta.UsalIngresoId||']';
           RAISE eRegistroNoExiste;
     WHEN pConsulta.NombreCompleto IS NOT NULL THEN
           pResultado := 'No se encontraron registros de ingresos relacionadas a [Nombre: '||pConsulta.NombreCompleto||']';
           RAISE eRegistroNoExiste;
     WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
           pResultado := 'No se encontraron registros de ingresos relacionadas a [Unidad salud destino: '||pConsulta.UsalIngresoId||']';
           RAISE eRegistroNoExiste;
     ELSE 
           pResultado := 'No se encontraron registros de ingresos';
           RAISE eRegistroNoExiste;
     END CASE;     
     END CASE;
 EXCEPTION
 WHEN eParametroNull THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;  
 WHEN eParametrosInvalidos THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;      
 WHEN eSalidaConError THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;  
 WHEN eRegistroNoExiste THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al querer obtener información de registros ingresos egresos'; --. [Id: '||pIngresoId||'] - y [Id Expediente: '||pExpedienteId||']';
      pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_C_INGRESO;  
 PROCEDURE PR_CRUD_INGRESO_EGRESO (pIngresoId          IN OUT SNH_MST_INGRESOS_EGRESOS.INGRESO_ID%TYPE,                                         
                                   pPregIngresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PREG_INGRESO_ID%TYPE,                     
                                   pPerNominalId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PER_NOMINAL_ID%TYPE,                
                                   pProcedenciaId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.PROCEDENCIA_ID%TYPE,                
                                   pAdmisionId         IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISION_SERVICIO_ID%TYPE,                     
                                   pEdadExactaIng      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.EDAD_EXACTA_INGRESO%TYPE,           
                                   pGrupoEtareoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.GRUPO_ETAREO_ID%TYPE,               
                                   pMedicoIngId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_INGRESO_ID%TYPE,             
                                   pAdminSolicIngId    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_SOLICITA_INGR_ID%TYPE, 
                                   pAdmisionistaIngId  IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISIONISTA_INGRESO_ID%TYPE,       
                                   pMedOrdenaIngId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_ORDENA_INGRESO_ID%TYPE,      
                                   pServProcedenId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_PROCEDENCIA_ID%TYPE,       
                                   pReingreso          IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO%TYPE,                     
                                   pReingresoId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REINGRESO_ID%TYPE,                  
                                   pFecSolicitaIng     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_SOLICITUD_INGRESO%TYPE,       
                                   pHrSolicitudIng     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_SOLICITUD_INGRESO%TYPE,        
                                   pFecInicioIngreso   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_INICIO_INGRESO%TYPE,          
                                   pHrInicioIngreso    IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_INICIO_INGRESO%TYPE,           
                                   pUsalIngresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.UNIDAD_SALUD_INGRESO%TYPE,          
                                   pServIngresoId      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_INGRESO_ID%TYPE,           
                                   pEstadoIngId        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_INGRESO_ID%TYPE,             
                                   pTipoEgresoId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.TIPO_EGRESO_ID%TYPE,                
                                   pFecFinIngreso      IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.FECHA_FIN_INGRESO%TYPE,             
                                   pHrFinIngreso       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.HORA_FIN_INGRESO%TYPE,              
                                   pServEgresoId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.SERVICIO_EGRESO_ID%TYPE,            
                                   pMedicoEgresoId     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.MEDICO_EGRESO_ID%TYPE,              
                                   pReferenciaId       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.REFERENCIA_ID%TYPE,                 
                                   pEsContraferido     IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ES_CONTRAFERIDO%TYPE,               
                                   pEnvContrareferId   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ENVIO_CONTRAREFERENCIA_ID%TYPE,     
                                   pDiasEstancia       IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.DIAS_ESTANCIA%TYPE,                 
                                   pEstadoPxId         IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_ID%TYPE,                  
                                   pEstadoPxEgresoId   IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ESTADO_PX_EGRESO_ID%TYPE,           
                                   pComentarios        IN HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.COMENTARIOS%TYPE,                   
                                   pUsuario            IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                                   pExpedienteId       IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE,
                                   pNombreCompleto     IN CATALOGOS.SBC_MST_PERSONAS_NOMINAL.NOMBRE_COMPLETO%TYPE,
                                   pCodExpElectronico  IN HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE.CODIGO_EXPEDIENTE_ELECTRONICO%TYPE,
                                   pIdentificacion     IN CATALOGOS.SBC_MST_PERSONAS.IDENTIFICACION%TYPE,
                                   pUsalProcedeId      IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,
                                   pFecInicio          IN DATE,
                                   pFecFin             IN DATE,
                                   pTipIngEgr          IN VARCHAR2,
                                   pAccionEstado       IN VARCHAR2,                                  
                                   pTipoAccion         IN VARCHAR2,    
                                   pPgn                IN NUMBER,
                                   pPgnAct             IN NUMBER default 1, 
                                   pPgnTmn             IN NUMBER default 100,
                                   pDatosPaginacion    OUT var_refcursor,                              
                                  -- pJson               IN VARCHAR2,                                  
                                   pRegistro           OUT var_refcursor,                           
                                   pResultado          OUT VARCHAR2,                                
                                   pMsgError           OUT VARCHAR2) IS

 vFirma              MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_INGRESO_EGRESO => ';
 vResultado          MAXVARCHAR2;
 vEstadoRegistroId   CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 vNomCompletoPx      MAXVARCHAR2;
 vCodExpElectronico  MAXVARCHAR2;
 vIdentificacion     MAXVARCHAR2;
 vExpedienteId       NUMBER;
 vAdmisionid         HOSPITALARIO.SNH_MST_PREG_INGRESOS.ADMISION_ID%TYPE;  -- := FN_OBT_ADMISION_ID_PREG (pPregIngresoId);
 vAdmiServId         HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISION_SERVICIO_ID%TYPE;
 vEspecialidadDestId HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS.ADMISION_SERVICIO_ID%TYPE;
 vRegistro           var_refcursor;
 vConsulta           HOSPITALARIO.OBJ_INGRESO_EGRESO; 
 --pTipoIngEgr         VARCHAR2(2);
 BEGIN
      CASE
      WHEN pTipoAccion IS NULL THEN 
           pResultado := 'El párametro pTipoAccion no puede venir NULL';
           pMsgError  := pResultado;
           RAISE eParametroNull;
      ELSE NULL;
      END CASE;
      
      CASE
      WHEN pTipoAccion = kINSERT THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;
           dbms_output.put_line ('Sale de validar usuario');

            CASE
            WHEN FN_EXISTE_ADMISION_ID_PREG (pPregIngresoId) = TRUE THEN
                 vAdmisionId         := FN_OBT_ADMISION_ID_PREG (pPregIngresoId);
                 CASE
                 WHEN FN_EXISTE_ESPECIALIDAD_ID_PREG (pPregIngresoId) = TRUE THEN
                      vEspecialidadDestId := FN_OBT_ESPECIALIDAD_ID_PREG (pPregIngresoId);
                 ELSE NULL;
                 END CASE;
                 
                 CASE
                 WHEN vAdmisionId > 0 THEN 
                      pkg_snh_consulta_externa.SNH_CRUD_ADMISION_SERVICIO (pUsrName        => pUsuario,
                                                                           pAdmisionServId => vAdmiServId, 
                                                                           pAdmisionId     => vAdmisionId,
                                                                           pServicioId     => pServIngresoId,
                                                                           pMPerSaludId    => pMedOrdenaIngId,
                                                                           pDependenciaId  => NULL,
                                                                           pFechaIni       => pFecSolicitaIng, 
                                                                           pFechaFin       => NULL,
                                                                           pEstado         => NULL,
                                                                           pEsPrincipal    => kES_PRINCIPAL,
                                                                           pEspecialidad   => vEspecialidadDestId,
                                                                           pTipoOperacion  => kINSERT, 
                                                                           pRegistro       => vRegistro,
                                                                           pResultado      => pResultado,
                                                                           pMsgError       => pMsgError);
                      CASE
                      WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                           RAISE eSalidaConError;
                      ELSE NULL;
                      END CASE; 
                 ELSE NULL;
                 END CASE;
            ELSE NULL;
            END CASE;
            PR_I_INGRESO (pIngresoId         => pIngresoId,           
                          pPregIngresoId     => pPregIngresoId,    
                          pPerNominalId      => pPerNominalId,     
                          pProcedenciaId     => pProcedenciaId,    
                          pAdmisionId        => vAdmiServId,    -- aqui se manda la admisión servicio Id -- pAdmisionId,       
                          pEdadExactaIng     => pEdadExactaIng,    
                          pGrupoEtareoId     => pGrupoEtareoId,    
                          pMedicoIngId       => pMedicoIngId,      
                          pAdminSolicIngId   => pAdminSolicIngId,  
                          pAdmisionistaIngId => pAdmisionistaIngId,
                          pMedOrdenaIngId    => pMedOrdenaIngId,   
                          pServProcedenId    => pServProcedenId,   
                          pReingreso         => pReingreso,        
                          pReingresoId       => pReingresoId,      
                          pFecSolicitaIng    => pFecSolicitaIng,   
                          pHrSolicitudIng    => pHrSolicitudIng,   
                          pFecInicioIngreso  => pFecInicioIngreso, 
                          pHrInicioIngreso   => pHrInicioIngreso,  
                          pUsalIngresoId     => pUsalIngresoId,    
                          pServIngresoId     => pServIngresoId,    
                          pEstadoIngId       => pEstadoIngId,      
                          pTipoEgresoId      => pTipoEgresoId,     
                          pFecFinIngreso     => pFecFinIngreso,    
                          pHrFinIngreso      => pHrFinIngreso,     
                          pServEgresoId      => pServEgresoId,     
                          pMedicoEgresoId    => pMedicoEgresoId,   
                          pReferenciaId      => pReferenciaId,     
                          pEsContraferido    => pEsContraferido,   
                          pEnvContrareferId  => pEnvContrareferId, 
                          pDiasEstancia      => pDiasEstancia,     
                          pEstadoPxId        => pEstadoPxId,       
                          pEstadoPxEgresoId  => pEstadoPxEgresoId, 
                          pComentarios       => pComentarios,      
                          pUsuario           => pUsuario,          
                          pResultado         => pResultado,        
                          pMsgError          => pMsgError);         
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            WHEN NVL(pIngresoId,0) > 0 THEN
                 PR_C_INGRESO (pConsulta        => HOSPITALARIO.OBJ_INGRESO_EGRESO (pIngresoId,        
                                                                                    pPregIngresoId,    
                                                                                    pPerNominalId,     
                                                                                    pExpedienteId,     
                                                                                    pNombreCompleto,   
                                                                                    pProcedenciaId,    
                                                                                    pCodExpElectronico,
                                                                                    pIdentificacion,   
                                                                                    pAdmisionId,       
                                                                                    pMedicoIngId,      
                                                                                    pAdminSolicIngId,  
                                                                                    pAdmisionistaIngId,
                                                                                    pMedOrdenaIngId,   
                                                                                    pServProcedenId,   
                                                                                    pReingreso,        
                                                                                    pFecInicio,        
                                                                                    pFecFin,           
                                                                                    pUsalProcedeId,    
                                                                                    pUsalIngresoId,    
                                                                                    pServIngresoId,    
                                                                                    pEstadoIngId,      
                                                                                    pTipoEgresoId,     
                                                                                    pServEgresoId,     
                                                                                    pMedicoEgresoId,   
                                                                                    pEsContraferido,   
                                                                                    pEstadoPxId,       
                                                                                    pEstadoPxEgresoId),
                               pPgn             => pPgn,            
                               pPgnAct          => pPgnAct,         
                               pPgnTmn          => pPgnTmn,         
                               pTipIngEgr       => pTipIngEgr,
                               pDatosPaginacion => pDatosPaginacion,
                               pRegistro        => pRegistro,         
                               pResultado       => pResultado,        
                               pMsgError        => pMsgError); 
                 CASE
                 WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                     RAISE eSalidaConError;
                 ELSE 
                     vResultado := 'Se crea exitosamente el registro de ingreso hospitalario [Id]: '||pIngresoId||', devolviendo el JSon de este';
                 END CASE;
            ELSE NULL;     
            END CASE; 
      WHEN pTipoAccion = kUPDATE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;      
                      
           CASE
           WHEN pAccionEstado = 0 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_ACTIVO;
           WHEN pAccionEstado = 1 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_PASIVO;
           ELSE NULL;
           END CASE;
           PR_U_INGRESO (pIngresoId         => pIngresoId,         
                         pPregIngresoId     => pPregIngresoId,     
                         pPerNominalId      => pPerNominalId,      
                         pProcedenciaId     => pProcedenciaId,     
                         pAdmisionId        => pAdmisionId,        
                         pEdadExactaIng     => pEdadExactaIng,     
                         pGrupoEtareoId     => pGrupoEtareoId,     
                         pMedicoIngId       => pMedicoIngId,       
                         pAdminSolicIngId   => pAdminSolicIngId,   
                         pAdmisionistaIngId => pAdmisionistaIngId, 
                         pMedOrdenaIngId    => pMedOrdenaIngId,    
                         pServProcedenId    => pServProcedenId,    
                         pReingreso         => pReingreso,         
                         pReingresoId       => pReingresoId,       
                         pFecSolicitaIng    => pFecSolicitaIng,    
                         pHrSolicitudIng    => pHrSolicitudIng,    
                         pFecInicioIngreso  => pFecInicioIngreso,  
                         pHrInicioIngreso   => pHrInicioIngreso,   
                         pUsalIngresoId     => pUsalIngresoId,     
                         pServIngresoId     => pServIngresoId,     
                         pEstadoIngId       => pEstadoIngId,       
                         pTipoEgresoId      => pTipoEgresoId,      
                         pFecFinIngreso     => pFecFinIngreso,     
                         pHrFinIngreso      => pHrFinIngreso,      
                         pServEgresoId      => pServEgresoId,      
                         pMedicoEgresoId    => pMedicoEgresoId,    
                         pReferenciaId      => pReferenciaId,      
                         pEsContraferido    => pEsContraferido,    
                         pEnvContrareferId  => pEnvContrareferId,  
                         pDiasEstancia      => pDiasEstancia,      
                         pEstadoPxId        => pEstadoPxId,        
                         pEstadoPxEgresoId  => pEstadoPxEgresoId,  
                         pComentarios       => pComentarios,       
                         pEstadoRegistroId  => vEstadoRegistroId,  
                         pUsuario           => pUsuario,           
                         pResultado         => pResultado,         
                         pMsgError          => pMsgError);          
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            ELSE 
               CASE
               WHEN NVL(pIngresoId,0) > 0 THEN
               -- se realiza consulta de datos luego de realizar la actualización de persona
                    PR_C_INGRESO (pConsulta        => HOSPITALARIO.OBJ_INGRESO_EGRESO (pIngresoId,        
                                                                                       pPregIngresoId,    
                                                                                       pPerNominalId,     
                                                                                       pExpedienteId,     
                                                                                       pNombreCompleto,   
                                                                                       pProcedenciaId,    
                                                                                       pCodExpElectronico,
                                                                                       pIdentificacion,   
                                                                                       pAdmisionId,       
                                                                                       pMedicoIngId,      
                                                                                       pAdminSolicIngId,  
                                                                                       pAdmisionistaIngId,
                                                                                       pMedOrdenaIngId,   
                                                                                       pServProcedenId,   
                                                                                       pReingreso,        
                                                                                       pFecInicio,        
                                                                                       pFecFin,           
                                                                                       pUsalProcedeId,    
                                                                                       pUsalIngresoId,    
                                                                                       pServIngresoId,    
                                                                                       pEstadoIngId,      
                                                                                       pTipoEgresoId,     
                                                                                       pServEgresoId,     
                                                                                       pMedicoEgresoId,   
                                                                                       pEsContraferido,   
                                                                                       pEstadoPxId,       
                                                                                      pEstadoPxEgresoId),
                                  pPgn             => pPgn,            
                                  pPgnAct          => pPgnAct,         
                                  pPgnTmn          => pPgnTmn,         
                                  pTipIngEgr       => pTipIngEgr,
                                  pDatosPaginacion => pDatosPaginacion,
                                  pRegistro        => pRegistro,         
                                  pResultado       => pResultado,        
                                  pMsgError        => pMsgError);
           
                   CASE
                   WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                        RAISE eSalidaConError;
                   ELSE vResultado := 'Se actualiza exitosamente el registro de ingreso hospitalario [Id]: '||pIngresoId||', devolviendo el JSon de este';
                   END CASE;          
               ELSE NULL;    
               END CASE;                 
            END CASE;           
           
      WHEN pTipoAccion = kCONSULTAR THEN
           PR_C_INGRESO (pConsulta        => HOSPITALARIO.OBJ_INGRESO_EGRESO (pIngresoId,        
                                                                              pPregIngresoId,    
                                                                              pPerNominalId,     
                                                                              pExpedienteId,     
                                                                              pNombreCompleto,   
                                                                              pProcedenciaId,    
                                                                              pCodExpElectronico,
                                                                              pIdentificacion,   
                                                                              pAdmisionId,       
                                                                              pMedicoIngId,      
                                                                              pAdminSolicIngId,  
                                                                              pAdmisionistaIngId,
                                                                              pMedOrdenaIngId,   
                                                                              pServProcedenId,   
                                                                              pReingreso,        
                                                                              pFecInicio,        
                                                                              pFecFin,           
                                                                              pUsalProcedeId,   
                                                                              pUsalIngresoId,    
                                                                              pServIngresoId,    
                                                                              pEstadoIngId,      
                                                                              pTipoEgresoId,     
                                                                              pServEgresoId,     
                                                                              pMedicoEgresoId,   
                                                                              pEsContraferido,   
                                                                              pEstadoPxId,       
                                                                              pEstadoPxEgresoId),
                         pPgn             => pPgn,
                         pPgnAct          => pPgnAct,         
                         pPgnTmn          => pPgnTmn,         
                         pTipIngEgr       => pTipIngEgr, 
                         pDatosPaginacion => pDatosPaginacion,
                         pRegistro        => pRegistro,         
                         pResultado       => pResultado,        
                         pMsgError        => pMsgError);
           CASE
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Consulta realizada con éxito';
      WHEN pTipoAccion = kDELETE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;     
           CASE
           WHEN NVL(pIngresoId,0) > 0 THEN
           PR_U_INGRESO (pIngresoId         => pIngresoId,         
                         pPregIngresoId     => pPregIngresoId,     
                         pPerNominalId      => pPerNominalId,      
                         pProcedenciaId     => pProcedenciaId,     
                         pAdmisionId        => pAdmisionId,        
                         pEdadExactaIng     => pEdadExactaIng,     
                         pGrupoEtareoId     => pGrupoEtareoId,     
                         pMedicoIngId       => pMedicoIngId,       
                         pAdminSolicIngId   => pAdminSolicIngId,   
                         pAdmisionistaIngId => pAdmisionistaIngId, 
                         pMedOrdenaIngId    => pMedOrdenaIngId,    
                         pServProcedenId    => pServProcedenId,    
                         pReingreso         => pReingreso,         
                         pReingresoId       => pReingresoId,       
                         pFecSolicitaIng    => pFecSolicitaIng,    
                         pHrSolicitudIng    => pHrSolicitudIng,    
                         pFecInicioIngreso  => pFecInicioIngreso,  
                         pHrInicioIngreso   => pHrInicioIngreso,   
                         pUsalIngresoId     => pUsalIngresoId,     
                         pServIngresoId     => pServIngresoId,     
                         pEstadoIngId       => pEstadoIngId,       
                         pTipoEgresoId      => pTipoEgresoId,      
                         pFecFinIngreso     => pFecFinIngreso,     
                         pHrFinIngreso      => pHrFinIngreso,      
                         pServEgresoId      => pServEgresoId,      
                         pMedicoEgresoId    => pMedicoEgresoId,    
                         pReferenciaId      => pReferenciaId,      
                         pEsContraferido    => pEsContraferido,    
                         pEnvContrareferId  => pEnvContrareferId,  
                         pDiasEstancia      => pDiasEstancia,      
                         pEstadoPxId        => pEstadoPxId,        
                         pEstadoPxEgresoId  => pEstadoPxEgresoId,  
                         pComentarios       => pComentarios,       
                         pEstadoRegistroId  => vGLOBAL_ESTADO_ELIMINADO,  
                         pUsuario           => pUsuario,           
                         pResultado         => pResultado,         
                         pMsgError          => pMsgError);                   
               CASE 
               WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                    RAISE eSalidaConError;
               ELSE NULL;
               END CASE;
               vResultado := 'Registro borrado con éxito';
           ELSE 
               pResultado := 'No hay registros para eliminar con el Id: '||pPregIngresoId;
               pMsgError  := pResultado;
               RAISE eUpdateInvalido;    
           END CASE; 
      ELSE 
          pResultado := 'El Tipo acción no es un parámetro valido.';
          pMsgError  := pResultado;
          RAISE eParametrosInvalidos;
      END CASE;
      pResultado := vResultado;     
 EXCEPTION
    WHEN eUpdateInvalido THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;      
    WHEN eParametroNull THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroNoExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;                       
    WHEN eParametrosInvalidos THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pResultado;
    WHEN eSalidaConError THEN
         pResultado := pResultado;  --vResultado;
         pMsgError  := vFirma||pMsgError;  --vMsgError;
    WHEN OTHERS THEN
         pResultado := 'Error no controlado';
         pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_CRUD_INGRESO_EGRESO;
 
 FUNCTION FN_VALIDA_CAMA_CODAMIN (pCamaId   IN HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE, 
                                  pCodAdmin IN HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE) RETURN BOOLEAN AS
 vContador SIMPLE_INTEGER := 0;
 vRetorna BOOLEAN := FALSE;
 BEGIN
   CASE
   WHEN NVL(pCamaId,0) > 0 THEN
        BEGIN
        SELECT COUNT (1)
         INTO vContador
         FROM HOSPITALARIO.SNH_CAT_CAMAS
        WHERE CAMA_ID != pCamaId AND
              CODIGO_ADMINISTRATIVO = pCodAdmin AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
        END;
   ELSE 
        BEGIN
        SELECT COUNT (1)
         INTO vContador
         FROM HOSPITALARIO.SNH_CAT_CAMAS
        WHERE CODIGO_ADMINISTRATIVO = pCodAdmin AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
        END;   
   END CASE;
   CASE
   WHEN vContador > 0 THEN
        vRetorna := TRUE;
   ELSE NULL;
   END CASE;
   
   RETURN vRetorna;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vRetorna; 
 END FN_VALIDA_CAMA_CODAMIN;
 
 FUNCTION FN_VALIDA_CAMA_NOSERIE (pCamaId   IN HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE, 
                                  pNoSerie  IN HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE) RETURN BOOLEAN AS
 vContador SIMPLE_INTEGER := 0;
 vRetorna BOOLEAN := FALSE;
 BEGIN
   CASE
   WHEN NVL(pCamaId,0) > 0 THEN
        BEGIN
        SELECT COUNT (1)
         INTO vContador
         FROM HOSPITALARIO.SNH_CAT_CAMAS
        WHERE CAMA_ID != pCamaId AND
              NO_SERIE = pNoSerie AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
        END;
   ELSE 
        BEGIN
        SELECT COUNT (1)
         INTO vContador
         FROM HOSPITALARIO.SNH_CAT_CAMAS
        WHERE NO_SERIE = pNoSerie AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
        END;   
   END CASE;
   CASE
   WHEN vContador > 0 THEN
        vRetorna := TRUE;
   ELSE NULL;
   END CASE;
   
   RETURN vRetorna;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vRetorna; 
 END FN_VALIDA_CAMA_NOSERIE; 
 
 PROCEDURE PR_I_CAT_CAMAS (pCamaId     OUT HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE,
                           pNombre     IN HOSPITALARIO.SNH_CAT_CAMAS.NOMBRE%TYPE,
                           pCodAdmin   IN HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE,
                           pNoSerie    IN HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE,
                           pEstadoCama IN HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_CAMA%TYPE,
                           pUsuario    IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                           pResultado  OUT VARCHAR2,                                
                           pMsgError   OUT VARCHAR2) IS
 vFirma             VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_I_CAT_CAMAS => ';
 BEGIN
      CASE
      WHEN (pCodAdmin IS NOT NULL OR
            pNoSerie IS NOT NULL) THEN
            CASE
            WHEN (FN_VALIDA_CAMA_CODAMIN (pCamaId, pCodAdmin)) = TRUE THEN
                  pResultado := 'El código adminitrativo que quiere relacionar a un nuevo registro de cama, ya existe. '||pCodAdmin;
                  pMsgError := pResultado;
                  RAISE eRegistroExiste;
            ELSE 
            CASE
            WHEN (FN_VALIDA_CAMA_NOSERIE (pCamaId, pNoSerie)) = TRUE THEN
                  pResultado := 'El número de serie que quiere relacionar a un nuevo registro de cama, ya existe. '||pNoSerie;
                  pMsgError := pResultado;
                  RAISE eRegistroExiste;
            ELSE NULL;
            END CASE;            
            END CASE;
      ELSE NULL;
      END CASE;
      INSERT INTO SNH_CAT_CAMAS (NOMBRE,
                                 CODIGO_ADMINISTRATIVO,
                                 NO_SERIE,
                                 ESTADO_CAMA,
                                 ESTADO_REGISTRO_ID,
                                 USUARIO_REGISTRO)
                         VALUES (pNombre,
                                 pCodAdmin,
                                 pNoSerie,
                                 1,  --pEstadoCama,
                                 vGLOBAL_ESTADO_ACTIVO,
                                 pUsuario)
                                 RETURNING CAMA_ID INTO pCamaId  ; 
   pResultado := 'Cat camas creado con éxito. [Id:'||pCamaId||']';  
   dbms_output.put_line ('pCamaId: '||pCamaId);      
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;
 WHEN eRegistroExiste THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;     
 WHEN OTHERS THEN
      dbms_output.put_line ('when others: '||sqlerrm);
      pResultado := 'Error al crear el registro persona';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm; 
 END PR_I_CAT_CAMAS;
 
 PROCEDURE PR_U_CAT_CAMAS (pCamaId           IN HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE,
                           pNombre           IN HOSPITALARIO.SNH_CAT_CAMAS.NOMBRE%TYPE,
                           pCodAdmin         IN HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE,
                           pNoSerie          IN HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE,
                           pEstadoCama       IN HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_CAMA%TYPE,
                           pEstadoRegistroId IN HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_REGISTRO_ID%TYPE,
                           pUsuario          IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                           pResultado        OUT VARCHAR2,
                           pMsgError         OUT VARCHAR2) IS
 
 vFirma VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_U_CAT_CAMAS => ';  
 BEGIN
     CASE
     WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ELIMINADO THEN
         <<EliminaRegistro>>
          BEGIN
             UPDATE HOSPITALARIO.SNH_CAT_CAMAS
                SET ESTADO_REGISTRO_ID   = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,
                    USUARIO_ELIMINA      = pUsuario,
                    FECHA_ELIMINA        = CURRENT_TIMESTAMP
              WHERE CAMA_ID = pCamaId;
          EXCEPTION
             WHEN OTHERS THEN
                  pResultado := 'Error no controlado al eliminar registro [pCamaId] - '||pCamaId;
                  pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                  RETURN;                
          END EliminaRegistro;
          pResultado := 'Se ha eliminado el registro. [Id:'||pCamaId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_PASIVO THEN
         <<PasivaRegistro>>       
         BEGIN
            UPDATE  HOSPITALARIO.SNH_CAT_CAMAS
                SET ESTADO_REGISTRO_ID   = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,  
                    USUARIO_PASIVA       = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                           ELSE USUARIO_PASIVA
                                           END,    
                    FECHA_PASIVA         = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                           ELSE FECHA_PASIVA
                                           END
             WHERE CAMA_ID = pCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;     
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al pasivar registro [pCamaId] - '||pCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END PasivaRegistro;
         pResultado := 'Se ha pasivado el registro. [Id:'||pCamaId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN
          <<ActivarRegistro>>
         BEGIN
            UPDATE HOSPITALARIO.SNH_CAT_CAMAS
               SET ESTADO_REGISTRO_ID   = pEstadoRegistroId, 
                   USUARIO_MODIFICACION = pUsuario,    
                   USUARIO_PASIVA       = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                          ELSE USUARIO_PASIVA
                                          END,    
                   FECHA_PASIVA         = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                          ELSE FECHA_PASIVA
                                          END
             WHERE CAMA_ID = pCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [pCamaId] - '||pCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActivarRegistro; 
         pResultado := 'Se ha activado el registro. [Id:'||pCamaId||']';                        
     ELSE 
         <<ActualizarRegistro>>
         BEGIN
            CASE
            WHEN (pCodAdmin IS NOT NULL OR
                  pNoSerie IS NOT NULL) THEN
                  CASE
                  WHEN (FN_VALIDA_CAMA_CODAMIN (pCamaId, pCodAdmin)) = TRUE THEN
                        pResultado := 'El código adminitrativo que quiere relacionar a un nuevo registro de cama, ya existe. '||pCodAdmin;
                        pMsgError := pResultado;
                        RAISE eRegistroExiste;
                  ELSE 
                  CASE
                  WHEN (FN_VALIDA_CAMA_NOSERIE (pCamaId, pNoSerie)) = TRUE THEN
                        pResultado := 'El número de serie que quiere relacionar a un nuevo registro de cama, ya existe. '||pNoSerie;
                        pMsgError := pResultado;
                        RAISE eRegistroExiste;
                  ELSE NULL;
                  END CASE;            
                  END CASE;
            ELSE NULL;
            END CASE;         
         
            UPDATE HOSPITALARIO.SNH_CAT_CAMAS  
               SET NOMBRE                = NVL(pNombre, NOMBRE),
                   CODIGO_ADMINISTRATIVO = NVL(pCodAdmin,CODIGO_ADMINISTRATIVO),
                   NO_SERIE              = NVL(pNoSerie, NO_SERIE),
                   ESTADO_CAMA           = NVL(pEstadoCama, ESTADO_CAMA),
                   USUARIO_MODIFICACION  = pUsuario          
             WHERE CAMA_ID = pCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [pCamaId] - '||pCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActualizarRegistro; 
         pResultado := 'Se ha actualizado el registro. [Id:'||pCamaId||']';                              
     END CASE;
 EXCEPTION    
 WHEN eRegistroExiste THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;  
 WHEN OTHERS THEN
      dbms_output.put_line ('when others: '||sqlerrm);
      pResultado := 'Error al crear el registro persona';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;           
 END PR_U_CAT_CAMAS; 
 
 FUNCTION FN_VAL_EXISTE_CAT_CAMAS (pCamaId        IN HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE,
                                   pCodAdmin      IN HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE, 
                                   pNoSerie       IN HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE,
                                   pEstadoCama    IN HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_CAMA%TYPE,
                                   pCamaAsignada  IN NUMBER,
                                   pPgn           IN BOOLEAN,
                                   pCantRegistros OUT NUMBER,
                                   pFuente        OUT NUMBER) RETURN BOOLEAN AS
 vContador SIMPLE_INTEGER := 0;
 vExiste BOOLEAN := FALSE;
 BEGIN
    dbms_output.put_line ('pCamaAsignada: '||pCamaAsignada);
     CASE
     WHEN NVL(pCamaId,0) > 0 THEN
          BEGIN
          SELECT COUNT (1)
            INTO vContador
            FROM HOSPITALARIO.SNH_CAT_CAMAS
           WHERE CAMA_ID = pCamaId
             AND ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
          pFuente := 1;   
          END;
     WHEN NVL(pCamaAsignada,0) = 1 THEN
          DBMS_OUTPUT.PUT_LINE ('Entra a cama asignada');
          BEGIN
          SELECT COUNT (1)
            INTO vContador
            FROM HOSPITALARIO.SNH_CAT_CAMAS A
           WHERE (NOT EXISTS (SELECT 1
                               FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                              WHERE B.CAMA_ID = A.CAMA_ID) AND
                  NOT EXISTS (SELECT 1
                               FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS C
                              WHERE C.CAMA_ID = A.CAMA_ID AND
                                    C.ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO))
             AND A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
          pFuente := 2;   
          END;
     WHEN NVL(pCamaAsignada,0) = 1 THEN
          DBMS_OUTPUT.PUT_LINE ('Entra a cama asignada');
          BEGIN
          SELECT COUNT (1)
            INTO vContador
            FROM HOSPITALARIO.SNH_CAT_CAMAS A
           WHERE (NOT EXISTS (SELECT 1
                               FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                              WHERE B.CAMA_ID = A.CAMA_ID) AND
                  NOT EXISTS (SELECT 1
                               FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS C
                              WHERE C.CAMA_ID = A.CAMA_ID AND
                                    C.ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO))
             AND A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
          pFuente := 2;   
          END;
      WHEN (pCamaAsignada IS NOT NULL AND pCamaAsignada = 0) THEN
          DBMS_OUTPUT.PUT_LINE ('Entra a cama asignada');
          BEGIN
          SELECT COUNT (1)
            INTO vContador
            FROM HOSPITALARIO.SNH_CAT_CAMAS A
           WHERE (EXISTS (SELECT 1
                               FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                              WHERE B.CAMA_ID = A.CAMA_ID) 
--                  NOT EXISTS (SELECT 1
--                               FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS C
--                              WHERE C.CAMA_ID = A.CAMA_ID AND
--                                    C.ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO)
                                    )
                AND A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
          pFuente := 4;   
          END;     
     WHEN pPgn THEN 
          DBMS_OUTPUT.PUT_LINE ('Entra a getall paginado');
          BEGIN
            SELECT COUNT (1)
              INTO vContador
              FROM HOSPITALARIO.SNH_CAT_CAMAS A
             WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
             pFuente := 3;   
          END;     
     ELSE NULL;
     END CASE;
     DBMS_OUTPUT.PUT_LINE ('vContador: '||vContador);
     DBMS_OUTPUT.PUT_LINE ('pFuente: '||pFuente);
     CASE
     WHEN vContador > 0 THEN
          vExiste := TRUE;
     ELSE NULL;
     END CASE;
     pCantRegistros := vContador; -- Se devuelve cantidad de registros     
   RETURN vExiste;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vExiste;
 END FN_VAL_EXISTE_CAT_CAMAS;
 
 FUNCTION FN_OBT_CAT_CAMAS_X_ID (pCamaId IN HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE) RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
    OPEN vRegistro FOR
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
   WHERE CAT.CAMA_ID = pCamaId AND
         CAT.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
     RETURN vRegistro;             
 END FN_OBT_CAT_CAMAS_X_ID; 
 
 FUNCTION FN_OBT_CAMAS_NOASIGNADAS_PAG RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
-- CAMA_ID,                     
--                   CAMA_NOMBRE,                 
--                   CAMA_COD_ADMINISTRATIVO 
    OPEN vRegistro FOR
             SELECT  * 
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
                  WHERE CAT.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
               
                                      )
                                         )B
                WHERE  A.ID = B.CAMA_ID 
               --- AND LINE_NUMBER = 1
               ORDER BY LINE_NUMBER);          
     RETURN vRegistro;  
 END FN_OBT_CAMAS_NOASIGNADAS_PAG; 
 
 FUNCTION FN_OBT_CAT_CAMAS_ASIGNADAS RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
    OPEN vRegistro FOR
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
   WHERE (EXISTS (SELECT 1
                        FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                       WHERE B.CAMA_ID = CAT.CAMA_ID) --AND
--          NOT EXISTS (SELECT 1
--                        FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS C
--                       WHERE C.CAMA_ID = CAT.CAMA_ID AND
--                             C.ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO)
                             ) AND
         CAT.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
     RETURN vRegistro;  
 END FN_OBT_CAT_CAMAS_ASIGNADAS; 
 
 FUNCTION FN_OBT_CAT_CAMAS_NO_ASIGNADAS RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
    OPEN vRegistro FOR
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
   WHERE (NOT EXISTS (SELECT 1
                        FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
                       WHERE B.CAMA_ID = CAT.CAMA_ID) AND
          NOT EXISTS (SELECT 1
                        FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS C
                       WHERE C.CAMA_ID = CAT.CAMA_ID AND
                             C.ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO)) AND
         CAT.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
     RETURN vRegistro;  
 END FN_OBT_CAT_CAMAS_NO_ASIGNADAS;
 
 FUNCTION FN_OBT_CAT_CAMAS RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
 dbms_output.put_line ('Entrando a la función FN_OBT_CAT_CAMAS');

-- CAMA_ID,                     
--                   CAMA_NOMBRE,                 
--                   CAMA_COD_ADMINISTRATIVO 
    OPEN vRegistro FOR
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
                   WHERE CAT.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                      )
                                         )B
                WHERE  A.ID = B.CAMA_ID 
               --- AND LINE_NUMBER = 1
               ORDER BY LINE_NUMBER);                    
     RETURN vRegistro;             
 END FN_OBT_CAT_CAMAS;  
 FUNCTION FN_OBT_DATOS_CAT_CAMAS (pCamaId       IN HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE,
                                  pCodAdmin     IN HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE, 
                                  pNoSerie      IN HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE,
                                  pEstadoCama   IN HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_CAMA%TYPE,
                                  pCamaAsignada IN NUMBER,
                                  pPgnAct       IN NUMBER,    
                                  pPgnTmn       IN NUMBER, 
                                  pPgn          IN BOOLEAN,   
                                  pFuente       IN NUMBER) RETURN var_refcursor AS
 vRegistro var_refcursor;

 vFechaInicio     DATE;
 vFechaFin        DATE;
 vNombreCompleto  MAXVARCHAR2;
 vPrimerNombre    MAXVARCHAR2;
 vSegundoNombre   MAXVARCHAR2;
 vPrimerApellido  MAXVARCHAR2;
 vSegundoApellido MAXVARCHAR2;
 vSexo            MAXVARCHAR2;
 vUnidadSaludId   NUMBER;
 vMunicipioId     NUMBER;
 vEntAdminId      NUMBER; 
 vResultado       MAXVARCHAR2;
 vMsgError        MAXVARCHAR2; 
 BEGIN
     CASE
     WHEN pFuente = 1 THEN
          BEGIN
          vRegistro := FN_OBT_CAT_CAMAS_X_ID (pCamaId);
          END;
     WHEN pFuente = 2 THEN 
          BEGIN
          CASE
          WHEN pPgn THEN
               vRegistro := FN_OBT_CAMAS_NOASIGNADAS_PAG;
          ELSE 
               vRegistro := FN_OBT_CAT_CAMAS_NO_ASIGNADAS;
          END CASE;
          END;  
     WHEN pFuente = 4 THEN 
          BEGIN
          CASE
          WHEN pPgn THEN
               vRegistro := FN_OBT_CAMAS_NOASIGNADAS_PAG;
          ELSE 
               vRegistro := FN_OBT_CAT_CAMAS_ASIGNADAS;
          END CASE;
          END;             
     WHEN pFuente = 3 THEN 
          BEGIN
          dbms_output.put_line ('pFuente: '||pFuente);
          vRegistro := FN_OBT_CAT_CAMAS;
          END;                      
     ELSE NULL;
     END CASE; 
 RETURN vRegistro;
 END FN_OBT_DATOS_CAT_CAMAS;

 PROCEDURE PR_C_CAT_CAMAS (pCamaId          IN HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE,
                           pCodAdmin        IN HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE,
                           pNoSerie         IN HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE,
                           pEstadoCama      IN HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_CAMA%TYPE,
                           pCamaAsignada    IN NUMBER,
                           pPgn             IN NUMBER,
                           pPgnAct          IN NUMBER, 
                           pPgnTmn          IN NUMBER,
                           pDatosPaginacion OUT var_refcursor,
                           pRegistro        OUT var_refcursor,                           
                           pResultado       OUT VARCHAR2,                                
                           pMsgError        OUT VARCHAR2) IS
 vFirma           VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_C_CAT_CAMAS => ';  
 vFuente          SIMPLE_INTEGER := 0;
 vPgn             BOOLEAN := FALSE;
 vFechaInicio     DATE;
 vFechaFin        DATE;
 vNombreCompleto  MAXVARCHAR2;
 vPrimerNombre    MAXVARCHAR2;
 vSegundoNombre   MAXVARCHAR2;
 vPrimerApellido  MAXVARCHAR2;
 vSegundoApellido MAXVARCHAR2;
 vSexo            MAXVARCHAR2;
 vUnidadSaludId   NUMBER;
 vMunicipioId     NUMBER;
 vEntAdminId      NUMBER;
 vCantRegistros   SIMPLE_INTEGER := 0;
 vPaginacion HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos; 
 BEGIN
      CASE
      WHEN nvl(pPgn,0) = 1 THEN
           vPgn := TRUE;
      ELSE NULL;
      END CASE;
      dbms_output.put_Line ('Antes de validar existe cat camas');
      CASE
      WHEN (FN_VAL_EXISTE_CAT_CAMAS (pCamaId, pCodAdmin, pNoSerie, pEstadoCama, pCamaAsignada, vPgn ,vCantRegistros, vFuente)) = TRUE THEN 
            dbms_output.put_Line ('despues de validar existe cat camas');
            CASE
            WHEN vPgn THEN
                 HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_INDC_PAGINACION_PERSONA(PREGISTROS  => vCantRegistros, 
                                                                            pPgnAct     => pPgnAct, 
                                                                            pPgnTmn     => pPgnTmn, 
                                                                            pPaginacion => vPaginacion, 
                                                                            pMsg        => pMsgError);
                 dbms_output.put_Line ('Error despues de paginacion: '||pMsgError);                                                           
                 CASE 
                 WHEN pMsgError IS NOT NULL THEN 
                      pResultado := 'No se encontraron registros para la pagina: '||pPgnAct;
                      pMsgError  := pMsgError;
                      RAISE eSalidaConError;

                 ELSE 
                      pDatosPaginacion := FN_OBT_DATOS_PAGINACION (pDatosPaginacion =>  vPaginacion); --pQuery =>  vQuery);
                 END CASE;            
                 PR_I_TABLA_TEMPORAL_CATCAMA (pFechaInicio     => vFechaInicio,    
                                              pFechaFin        => vFechaFin,       
                                              pNombreCompleto  => vNombreCompleto, 
                                              pPrimerNombre    => vPrimerNombre,   
                                              pSegundoNombre   => vSegundoNombre,  
                                              pPrimerApellido  => vPrimerApellido, 
                                              pSegundoApellido => vSegundoApellido,
                                              pSexo            => vSexo,           
                                              pUnidadSaludId   => vUnidadSaludId,  
                                              pMunicipioId     => vMunicipioId,    
                                              pEntAdminId      => vEntAdminId,     
                                              pPgnAct          => pPgnAct,        
                                              pPgnTmn          => pPgnTmn,       
                                              pTipoPaginacion  => vFuente,
                                              pResultado       => pResultado,     
                                              pMsgError        => pMsgError); 
                                 dbms_output.put_line ('Error saliendo de I tabla temporal: '||pMsgError);              
                                 CASE
                                 WHEN pMsgError IS NOT NULL THEN 
                                      RAISE eSalidaConError;
                                 ELSE NULL;
                                 END CASE;
            ELSE NULL; 
            END CASE;
            pRegistro := FN_OBT_DATOS_CAT_CAMAS(pCamaId, pCodAdmin, pNoSerie, pEstadoCama, pCamaAsignada, pPgnAct, pPgnTmn, vPgn, vFuente);
             dbms_output.put_line ('Luego de llenar pRegistro FN_OBT_DATOS_CAT_CAMAS');
      ELSE
          CASE
          WHEN NVL(pCamaId,0) > 0 THEN
               pResultado := 'No se encontraron registros de pre ingresos relacionadas al [pCamaId: '||pCamaId||']';
               RAISE eRegistroNoExiste;
          WHEN pCodAdmin IS NOT NULL THEN
               pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Codigo Admin: '||pCodAdmin||']';
               RAISE eRegistroNoExiste;
          WHEN NVL(pEstadoCama,0) > 0 THEN
               pResultado := 'No se encontraron registros de pre ingresos relacionadas al [EstadoCama Id: '||pEstadoCama||']';
               RAISE eRegistroNoExiste;
          WHEN vPgn THEN 
               pResultado := 'No se encontraron registros de cat camas';
               RAISE eRegistroNoExiste;
          ELSE NULL;
          END CASE;     
      END CASE;
      DBMS_OUTPUT.PUT_LINE ('pResultado: '||pResultado);
      DBMS_OUTPUT.PUT_LINE ('pMsgError: '||pMsgError);
 EXCEPTION
 WHEN eSalidaConError THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;      
 WHEN eRegistroNoExiste THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al querer obtener información de Cat Camas. [Id: '||pCamaId||']';
      pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_C_CAT_CAMAS;  
 
 PROCEDURE PR_CRUD_CAT_CAMAS (pCamaId          IN OUT HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE,
                              pNombre          IN HOSPITALARIO.SNH_CAT_CAMAS.NOMBRE%TYPE,
                              pCodAdmin        IN HOSPITALARIO.SNH_CAT_CAMAS.CODIGO_ADMINISTRATIVO%TYPE,
                              pNoSerie         IN HOSPITALARIO.SNH_CAT_CAMAS.NO_SERIE%TYPE,
                              pEstadoCama      IN HOSPITALARIO.SNH_CAT_CAMAS.ESTADO_CAMA%TYPE,
                              pUsuario         IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                              pAccionEstado    IN VARCHAR2,
                              pCamaAsignada    IN NUMBER,                                  
                              pTipoAccion      IN VARCHAR2,                                  
                              pPgn             IN NUMBER,
                              pPgnAct          IN NUMBER default 1, 
                              pPgnTmn          IN NUMBER default 100,
                              pDatosPaginacion OUT var_refcursor,                              
                              pRegistro        OUT var_refcursor,                           
                              pResultado       OUT VARCHAR2,                                
                              pMsgError        OUT VARCHAR2) IS
 vFirma             MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_CAT_CAMAS => ';
 vResultado         MAXVARCHAR2;
 vEstadoRegistroId  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;                             
 BEGIN
      CASE
      WHEN pTipoAccion IS NULL THEN 
           pResultado := 'El párametro pTipoAccion no puede venir NULL';
           pMsgError  := pResultado;
           RAISE eParametroNull;
      ELSE NULL;
      END CASE;
      
      CASE
      WHEN pTipoAccion = kINSERT THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;
           dbms_output.put_line ('Sale de validar usuario');

            PR_I_CAT_CAMAS (pCamaId       => pCamaId,      
                            pNombre       => pNombre,      
                            pCodAdmin     => pCodAdmin,
                            pNoSerie      => pNoSerie,    
                            pEstadoCama   => pEstadoCama,  
                            pUsuario      => pUsuario,     
                            pResultado    => pResultado,   
                            pMsgError     => pMsgError);    
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            WHEN NVL(pCamaId,0) > 0 THEN  
                 PR_C_CAT_CAMAS (pCamaId          => pCamaId,     
                                 pCodAdmin        => pCodAdmin,  
                                 pNoSerie         => pNoSerie,  
                                 pEstadoCama      => pEstadoCama,
                                 pCamaAsignada    => pCamaAsignada, 
                                 pPgn             => pPgn,            
                                 pPgnAct          => pPgnAct,         
                                 pPgnTmn          => pPgnTmn,         
                                 pDatosPaginacion => pDatosPaginacion,
                                 pRegistro        => pRegistro,  
                                 pResultado       => pResultado, 
                                 pMsgError        => pMsgError);  
                 CASE
                 WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                     RAISE eSalidaConError;
                 ELSE 
                     vResultado := 'Se crea exitosamente el registro de cat camas [Id]: '||pCamaId||', devolviendo el JSon de este';
                 END CASE;
            ELSE NULL;     
            END CASE; 
      WHEN pTipoAccion = kUPDATE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;      
                      
           CASE
           WHEN pAccionEstado = 0 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_ACTIVO;
           WHEN pAccionEstado = 1 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_PASIVO;
           ELSE NULL;
           END CASE;
           PR_U_CAT_CAMAS (pCamaId           => pCamaId,          
                           pNombre           => pNombre,          
                           pCodAdmin         => pCodAdmin,        
                           pNoSerie          => pNoSerie,
                           pEstadoCama       => pEstadoCama,      
                           pEstadoRegistroId => vEstadoRegistroId,
                           pUsuario          => pUsuario,         
                           pResultado        => pResultado,       
                           pMsgError         => pMsgError);        
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            ELSE 
               CASE
               WHEN NVL(pCamaId,0) > 0 THEN
               -- se realiza consulta de datos luego de realizar la actualización de persona
                   PR_C_CAT_CAMAS (pCamaId          => pCamaId,     
                                  pCodAdmin        => pCodAdmin,  
                                  pNoSerie         => pNoSerie,  
                                  pEstadoCama      => pEstadoCama,
                                  pCamaAsignada    => pCamaAsignada, 
                                  pPgn             => pPgn,            
                                  pPgnAct          => pPgnAct,         
                                  pPgnTmn          => pPgnTmn,         
                                  pDatosPaginacion => pDatosPaginacion,
                                  pRegistro        => pRegistro,  
                                  pResultado       => pResultado, 
                                  pMsgError        => pMsgError);           
                   CASE
                   WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                        RAISE eSalidaConError;
                   ELSE vResultado := 'Se actualiza exitosamente el registro de cat camas [Id]: '||pCamaId||', devolviendo el JSon de este';
                   END CASE;          
               ELSE NULL;    
               END CASE;                 
            END CASE;           
      WHEN pTipoAccion = kCONSULTAR THEN
           PR_C_CAT_CAMAS (pCamaId          => pCamaId,     
                           pCodAdmin        => pCodAdmin,  
                           pNoSerie         => pNoSerie,  
                           pEstadoCama      => pEstadoCama,
                           pCamaAsignada    => pCamaAsignada, 
                           pPgn             => pPgn,            
                           pPgnAct          => pPgnAct,         
                           pPgnTmn          => pPgnTmn,         
                           pDatosPaginacion => pDatosPaginacion,
                           pRegistro        => pRegistro,  
                           pResultado       => pResultado, 
                           pMsgError        => pMsgError);             
           CASE
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Consulta realizada con éxito';
      WHEN pTipoAccion = kDELETE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;     
           CASE
           WHEN NVL(pCamaId,0) > 0 THEN
           PR_U_CAT_CAMAS (pCamaId           => pCamaId,          
                           pNombre           => pNombre,          
                           pCodAdmin         => pCodAdmin,        
                           pNoSerie          => pNoSerie,
                           pEstadoCama       => pEstadoCama,      
                           pEstadoRegistroId => vGLOBAL_ESTADO_ELIMINADO,
                           pUsuario          => pUsuario,         
                           pResultado        => pResultado,       
                           pMsgError         => pMsgError);          
           CASE 
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Registro eliminado con éxito';
           ELSE 
               pResultado := 'No hay registros para eliminar con el Id: '||pCamaId;
               pMsgError  := pResultado;
               RAISE eUpdateInvalido;    
           END CASE; 
      ELSE 
          pResultado := 'El Tipo acción no es un parámetro valido.';
          pMsgError  := pResultado;
          RAISE eParametrosInvalidos;
      END CASE;
      pResultado := vResultado;     
 EXCEPTION
    WHEN eUpdateInvalido THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;      
    WHEN eParametroNull THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroNoExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;                       
    WHEN eParametrosInvalidos THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pResultado;
    WHEN eSalidaConError THEN
         pResultado := pResultado;  --vResultado;
         pMsgError  := vFirma||pMsgError;  --vMsgError;
    WHEN OTHERS THEN
         pResultado := 'Error no controlado';
         pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_CRUD_CAT_CAMAS;
 
 FUNCTION FN_EXISTE_CAMA_OTRO_SERVICIO (pCamaId    IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CAMA_ID%TYPE, 
                                        pUsalServId IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.UND_SALUD_SERVICIO_ID%TYPE) RETURN BOOLEAN AS
 vContador  SIMPLE_INTEGER := 0;
 vRetorna BOOLEAN := FALSE;
 BEGIN 
  SELECT COUNT (1)
    INTO vContador
    FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
   WHERE CAMA_ID = pCamaId AND
         UND_SALUD_SERVICIO_ID != pUsalServId AND
         IS_LAST = 1 AND
         ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;
  
     CASE
     WHEN vContador > 0 THEN
          vRetorna := TRUE;
     ELSE NULL;
     END CASE;  
     RETURN vRetorna;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vRetorna;
 END FN_EXISTE_CAMA_OTRO_SERVICIO;  
 
 PROCEDURE PR_U_ISLAST_CAMA_USALSERV (pCamaId     IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CAMA_ID%TYPE, 
                                      pUsalServId IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.UND_SALUD_SERVICIO_ID%TYPE,
                                      pUsuario    IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                                      pResultado  OUT VARCHAR2,                               
                                      pMsgError   OUT VARCHAR2) IS 
 vFirma MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_U_ISLAST_CAMA_USALSERV => '; 
 BEGIN
     UPDATE HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
        SET IS_LAST = 0,
            USUARIO_MODIFICACION = pUsuario
      WHERE CAMA_ID = pCamaId AND
            UND_SALUD_SERVICIO_ID != pUsalServId;
 EXCEPTION
 WHEN OTHERS THEN  
      pResultado := 'Error al crear el configuración de camas';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;  
 END PR_U_ISLAST_CAMA_USALSERV;
 
 PROCEDURE PR_I_CFG_USERVICIOS_CAMAS (pCfgUsalServCamaId OUT HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                      pUsalServId        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.UND_SALUD_SERVICIO_ID%TYPE,
                                      pCodAsistencial    IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CODIGO_ASISTENCIAL%TYPE,
                                      pSalaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.SALA_ID%TYPE,
                                      pHabitacionId      IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.HABITACION_ID%TYPE,
                                      pCamaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CAMA_ID%TYPE,
                                      pDisponible        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.DISPONIBLE%TYPE,
                                      pCensable          IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CENSABLE%TYPE,
                                      pEstadoCama        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.ESTADO_CAMA_ID%TYPE,
                                      pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                      pResultado         OUT VARCHAR2,                                
                                      pMsgError          OUT VARCHAR2) IS 
 vFirma MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_I_CFG_USERVICIOS_CAMAS => ';                                     
 BEGIN
      CASE
      WHEN FN_EXISTE_CAMA_OTRO_SERVICIO (pCamaId, pUsalServId) = TRUE THEN
           PR_U_ISLAST_CAMA_USALSERV (pCamaId, 
                                      pUsalServId,
                                      pUsuario,
                                      pResultado,
                                      pMsgError);
           CASE
           WHEN pMsgError IS NOT NULL THEN
                pResultado := pResultado;
                pMsgError  := pMsgError;
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;                             
      ELSE NULL;
      END CASE;
      INSERT INTO HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS (UND_SALUD_SERVICIO_ID,
                                                         CODIGO_ASISTENCIAL,
                                                         SALA_ID,
                                                         HABITACION_ID,
                                                         CAMA_ID,
                                                         DISPONIBLE,
                                                         CENSABLE,
                                                         IS_LAST,
                                                         ESTADO_CAMA_ID,
                                                         ESTADO_REGISTRO_ID,
                                                         USUARIO_REGISTRO)
                                                 VALUES (pUsalServId,    
                                                         pCodAsistencial,
                                                         pSalaId,        
                                                         pHabitacionId,  
                                                         pCamaId,        
                                                         pDisponible,    
                                                         pCensable, 
                                                         kES_PRINCIPAL,     
                                                         vGLOBAL_ESTCAMA_DISPONIBLE,  -- pEstadoCama, 
                                                         vGLOBAL_ESTADO_ACTIVO,   
                                                         pUsuario)
                                                         RETURNING CFG_USLD_SERVICIO_CAMA_ID INTO pCfgUsalServCamaId;       
  pResultado := 'Configuración cama creada con éxito. [Id:'||pCfgUsalServCamaId||']';  
   dbms_output.put_line ('pCfgUsalServCamaId: '||pCfgUsalServCamaId);      
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;
 WHEN eRegistroExiste THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;     
 WHEN OTHERS THEN
      dbms_output.put_line ('when others: '||sqlerrm);
      pResultado := 'Error al crear el configuración de camas';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;                                                               
 END PR_I_CFG_USERVICIOS_CAMAS;   

 PROCEDURE PR_U_CFG_USERVICIOS_CAMAS (pCfgUsalServCamaId IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                      pUsalServId        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.UND_SALUD_SERVICIO_ID%TYPE,
                                      pCodAsistencial    IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CODIGO_ASISTENCIAL%TYPE,
                                      pSalaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.SALA_ID%TYPE,
                                      pHabitacionId      IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.HABITACION_ID%TYPE,
                                      pCamaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CAMA_ID%TYPE,
                                      pDisponible        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.DISPONIBLE%TYPE,
                                      pCensable          IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CENSABLE%TYPE,
                                      pEstadoCama        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.ESTADO_CAMA_ID%TYPE,
                                      pIslast            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.IS_LAST%TYPE,
                                      pEstadoRegistroId  IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.ESTADO_REGISTRO_ID%TYPE,
                                      pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                      pResultado         OUT VARCHAR2,                                
                                      pMsgError          OUT VARCHAR2) IS
 vFirma             VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_U_PRE_INGRESO => ';  
 BEGIN
     CASE
     WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ELIMINADO THEN
         <<EliminaRegistro>>
          BEGIN
             UPDATE HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
                SET ESTADO_REGISTRO_ID   = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,
                    USUARIO_ELIMINA      = pUsuario,
                    FECHA_ELIMINA        = CURRENT_TIMESTAMP
              WHERE CFG_USLD_SERVICIO_CAMA_ID = pCfgUsalServCamaId;
          EXCEPTION
             WHEN OTHERS THEN
                  pResultado := 'Error no controlado al eliminar registro [Id] - '||pCfgUsalServCamaId;
                  pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                  RETURN;                
          END EliminaRegistro;
          pResultado := 'Se ha eliminado el registro. [Id:'||pCfgUsalServCamaId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_PASIVO THEN
         <<PasivaRegistro>>       
         BEGIN
            UPDATE  HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
                SET ESTADO_REGISTRO_ID = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,  
                    USUARIO_PASIVA       = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                           ELSE USUARIO_PASIVA
                                           END,    
                    FECHA_PASIVA         = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                           ELSE FECHA_PASIVA
                                           END
             WHERE CFG_USLD_SERVICIO_CAMA_ID = pCfgUsalServCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;     
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al pasivar registro [Id] - '||pCfgUsalServCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END PasivaRegistro;
         pResultado := 'Se ha pasivado el registro. [Id:'||pCfgUsalServCamaId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN
          <<ActivarRegistro>>
         BEGIN
            UPDATE HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
               SET ESTADO_REGISTRO_ID   = pEstadoRegistroId, 
                   USUARIO_MODIFICACION = pUsuario,    
                   USUARIO_PASIVA       = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                          ELSE USUARIO_PASIVA
                                          END,    
                   FECHA_PASIVA         = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                          ELSE FECHA_PASIVA
                                          END
             WHERE CFG_USLD_SERVICIO_CAMA_ID = pCfgUsalServCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [Id] - '||pCfgUsalServCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActivarRegistro; 
         pResultado := 'Se ha activado el registro. [Id:'||pCfgUsalServCamaId||']';                        
     ELSE 
         <<ActualizarRegistro>>
         BEGIN
          CASE
          WHEN pIsLast = kES_PRINCIPAL THEN          
           CASE
           WHEN FN_EXISTE_CAMA_OTRO_SERVICIO (pCamaId, pUsalServId) = TRUE THEN
                PR_U_ISLAST_CAMA_USALSERV (pCamaId, 
                                           pUsalServId,
                                           pUsuario,
                                           pResultado,
                                           pMsgError);
                CASE
                WHEN pMsgError IS NOT NULL THEN
                     pResultado := pResultado;
                     pMsgError  := pMsgError;
                     RAISE eSalidaConError;
                ELSE NULL;
                END CASE;                             
           ELSE NULL;
           END CASE;
          ELSE NULL;
          END CASE;         
            UPDATE HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS  
               SET UND_SALUD_SERVICIO_ID = NVL(pUsalServId, UND_SALUD_SERVICIO_ID) ,
                   CODIGO_ASISTENCIAL    = NVL(pCodAsistencial, CODIGO_ASISTENCIAL),   
                   SALA_ID               = NVL(pSalaId, SALA_ID),           
                   HABITACION_ID         = NVL(pHabitacionId, HABITACION_ID),     
                   CAMA_ID               = NVL(pCamaId, CAMA_ID),           
                   DISPONIBLE            = NVL(pDisponible, CAMA_ID),       
                   CENSABLE              = NVL(pCensable, CENSABLE),         
                   ESTADO_CAMA_ID        = NVL(pEstadoCama, ESTADO_CAMA_ID),  
                   IS_LAST               = NVL(pIsLast, IS_LAST),     
                   USUARIO_MODIFICACION              = pUsuario          
             WHERE CFG_USLD_SERVICIO_CAMA_ID = pCfgUsalServCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [Id] - '||pCfgUsalServCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActualizarRegistro; 
         pResultado := 'Se ha actualizado el registro. [Id:'||pCfgUsalServCamaId||']';                              
     END CASE;
 EXCEPTION
 WHEN eSalidaConError THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;
 WHEN OTHERS THEN
      pResultado := 'Error al actualizar onfiguración de camas';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;       
 END PR_U_CFG_USERVICIOS_CAMAS;
   
 FUNCTION FN_VAL_EXISTE_CFG_CAMA (pConsulta          IN HOSPITALARIO.OBJ_CGF_CAMA_SERVICIO,
                                  pCantidadRegistros OUT NUMBER,
                                  pFuente            OUT NUMBER) RETURN BOOLEAN AS
 vContador SIMPLE_INTEGER := 0;
 vExiste BOOLEAN := FALSE;
 BEGIN
 CASE
 WHEN NVL(pConsulta.CfgUsalServCamaId,0) > 0 THEN
      BEGIN
       SELECT COUNT (1)
         INTO vContador
         FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
        WHERE CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
      pFuente := 1;        
      END;
 WHEN (NVL(pConsulta.CodAsistencial,0) > 0 AND
       NVL(pConsulta.UsalServId,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.CODIGO_ASISTENCIAL = pConsulta.CodAsistencial  AND
               A.UND_SALUD_SERVICIO_ID = pConsulta.UsalServId AND 
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 2;
       END;
 WHEN (NVL(pConsulta.CodAsistencial,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.CODIGO_ASISTENCIAL = pConsulta.CodAsistencial  AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 3;
       END;    
 WHEN (NVL(pConsulta.UsalServId,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.UND_SALUD_SERVICIO_ID = pConsulta.UsalServId AND 
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 4;
       END;  
 WHEN (NVL (pConsulta.SalaId,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.SALA_ID = pConsulta.SalaId  AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 5;
       END;     
 WHEN (NVL (pConsulta.HabitacionId,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.HABITACION_ID = pConsulta.HabitacionId  AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 6;
       END;                        
 WHEN (NVL (pConsulta.CamaId,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.CAMA_ID = pConsulta.CamaId AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 7;
       END;  
 WHEN (NVL (pConsulta.ServicioId,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.SERVICIO_ID = pConsulta.ServicioId AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId 
         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 8;
       END;       
 WHEN (NVL (pConsulta.Disponible,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.DISPONIBLE = pConsulta.Disponible AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 9;
       END;  
 WHEN (NVL (pConsulta.EstadoCama,0) > 0 AND
       NVL (pConsulta.UnidadSaludId,0) > 0)  THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.ESTADO_CAMA_ID = pConsulta.EstadoCama AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 10;
       END; 
 WHEN  NVL (pConsulta.UnidadSaludId,0) > 0 THEN
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
               B.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 11;
       END;                      
 ELSE 
       BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
       pFuente := 12;
       END;  
 END CASE;
 CASE
 WHEN vContador > 0 THEN
      vExiste := TRUE;
 ELSE NULL;
 END CASE;
 pCantidadRegistros := vContador;          
 RETURN vExiste;
 EXCEPTION
 WHEN OTHERS THEN
     RETURN vExiste;
 END FN_VAL_EXISTE_CFG_CAMA; 
 
 FUNCTION FN_OBT_DATOS_X_ID (pCfgUsalServCamaId IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE) RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
  OPEN vRegistro FOR
       SELECT CFG.CFG_USLD_SERVICIO_CAMA_ID  CFG_USLD_SERVICIO_CAMA_ID,
              CFG.UND_SALUD_SERVICIO_ID      UND_SALUD_SERVICIO_ID, 
              RELUSALSERV.UNIDAD_SALUD_ID    RELUSALSERV_UNIDAD_SALUD_ID,
              USALSERV.NOMBRE                USALSERV_NOMBRE,
              USALSERV.CODIGO                USALSERV_CODIGO,
              USALSERV.DIRECCION             USALSERV_DIRECCION,
              USALSERV.ENTIDAD_ADTVA_ID      USALSERV_ENTIDAD_ADTVA_ID,
              ENTADMINSERV.NOMBRE            ENTADMINSERV_NOMBRE,
              ENTADMINSERV.CODIGO            ENTADMINSERV_CODIGO,
              ENTADMINSERV.TELEFONO          ENTADMINSERV_TELEFONO,
              ENTADMINSERV.EMAIL             ENTADMINSERV_EMAIL,
              ENTADMINSERV.DIRECCION         ENTADMINSERV_DIRECCION,
              RELUSALSERV.SERVICIO_ID        RELUSALSERV_SERVICIO_ID,
              CATSERV.CODIGO                 CATSERV_CODIGO,
              CATSERV.NOMBRE                 CATSERV_NOMBRE,
              CATSERV.DESCRIPCION            CATSERV_DESCRIPCION,
              CATSERV.PASIVO                 CATSERV_PASIVO,
              RELUSALSERV.ESTADO_REGISTRO    RELUSALSERV_ESTADO_REGISTRO,
              CATESTREGUSALSERV.CODIGO       CATESTREGUSALSERV_CODIGO,
              CATESTREGUSALSERV.VALOR        CATESTREGUSALSERV_VALOR,
              CATESTREGUSALSERV.DESCRIPCION  CATESTREGUSALSERV_DESCRIPCION, 
              RELUSALSERV.USUARIO_REGISTRO   RELUSALSERV_USR_SERVICIO,
              RELUSALSERV.FECHA_REGISTRO     RELUSALSERV_FEC_REGISTRO, 
              CFG.CODIGO_ASISTENCIAL         CODIGO_ASISTENCIAL,       
              CFG.SALA_ID                    SALA_ID,                  
              CFG.HABITACION_ID              HABITACION_ID,            
              CFG.CAMA_ID                    CAMA_ID,
              CATCAMAS.NOMBRE                CATCAMAS_NOMBRE,
              CATCAMAS.CODIGO_ADMINISTRATIVO CATCAMAS_COD_ADMINISTRATIVO,
              CATCAMAS.ESTADO_CAMA           CATCAMAS_ESTADO_CAMA,
              CATCAMAS.ESTADO_REGISTRO_ID    CATCAMAS_ESTADO_REGISTRO_ID,
              CATESTREGCAMAS.CODIGO          CATESTREGCAMAS_CODIGO,    
              CATESTREGCAMAS.VALOR           CATESTREGCAMAS_VALOR,
              CATESTREGCAMAS.DESCRIPCION     CATESTREGCAMAS_DESCRIPCION,
              CATCAMAS.USUARIO_REGISTRO      CATCAMAS_USR_REGISTRO,
              CATCAMAS.FECHA_REGISTRO        CATCAMAS_FEC_REGISTRO,                  
              CFG.DISPONIBLE                 DISPONIBLE,                
              CFG.CENSABLE                   CENSABLE,       
              CFG.ESTADO_CAMA_ID             ESTADO_CAMA_ID, 
              CATESTCAMA.CODIGO              CATESTCAMA_CODIGO,
              CATESTCAMA.VALOR               CATESTCAMA_VALOR,
              CATESTCAMA.DESCRIPCION         CATESTCAMA_DESCRIPCION,
              CFG.IS_LAST                    IS_LAST,                  
              CFG.ESTADO_REGISTRO_ID         ESTADO_REGISTRO_ID,  
              CATESREG.CODIGO                CATESREG_CODIGO,
              CATESREG.VALOR                 CATESREG_VALOR,
              CATESREG.DESCRIPCION           CATESREG_DESCRIPCION,
              CFG.USUARIO_REGISTRO           USUARIO_REGISTRO,             
              CFG.FECHA_REGISTRO             FECHA_REGISTRO,      
              CFG.USUARIO_MODIFICACION       USUARIO_MODIFICACION,
              CFG.FECHA_MODIFICACION         FECHA_MODIFICACION,  
              CFG.USUARIO_PASIVA             USUARIO_PASIVA,      
              CFG.FECHA_PASIVA               FECHA_PASIVA,        
              CFG.USUARIO_ELIMINA            USUARIO_ELIMINA,     
              CFG.FECHA_ELIMINA              FECHA_ELIMINA        
         FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFG
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
        WHERE CFG_USLD_SERVICIO_CAMA_ID = pCfgUsalServCamaId AND
              CFG.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO; 
     RETURN vRegistro;  
 END FN_OBT_DATOS_X_ID; 
 
 FUNCTION FN_OBT_DATOS RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
  OPEN vRegistro FOR
       SELECT *
              --CFG_USLD_SERVICIO_CAMA_ID,
              --UND_SALUD_SERVICIO_ID
         FROM 
       (
       SELECT CFG.CFG_USLD_SERVICIO_CAMA_ID  CFG_USLD_SERVICIO_CAMA_ID,
              CFG.UND_SALUD_SERVICIO_ID      UND_SALUD_SERVICIO_ID, 
              RELUSALSERV.UNIDAD_SALUD_ID    RELUSALSERV_UNIDAD_SALUD_ID,
              USALSERV.NOMBRE                USALSERV_NOMBRE,
              USALSERV.CODIGO                USALSERV_CODIGO,
              USALSERV.DIRECCION             USALSERV_DIRECCION,
              USALSERV.ENTIDAD_ADTVA_ID      USALSERV_ENTIDAD_ADTVA_ID,
              ENTADMINSERV.NOMBRE            ENTADMINSERV_NOMBRE,
              ENTADMINSERV.CODIGO            ENTADMINSERV_CODIGO,
              ENTADMINSERV.TELEFONO          ENTADMINSERV_TELEFONO,
              ENTADMINSERV.EMAIL             ENTADMINSERV_EMAIL,
              ENTADMINSERV.DIRECCION         ENTADMINSERV_DIRECCION,
              RELUSALSERV.SERVICIO_ID        RELUSALSERV_SERVICIO_ID,
              CATSERV.CODIGO                 CATSERV_CODIGO,
              CATSERV.NOMBRE                 CATSERV_NOMBRE,
              CATSERV.DESCRIPCION            CATSERV_DESCRIPCION,
              CATSERV.PASIVO                 CATSERV_PASIVO,
              RELUSALSERV.ESTADO_REGISTRO    RELUSALSERV_ESTADO_REGISTRO,
              CATESTREGUSALSERV.CODIGO       CATESTREGUSALSERV_CODIGO,
              CATESTREGUSALSERV.VALOR        CATESTREGUSALSERV_VALOR,
              CATESTREGUSALSERV.DESCRIPCION  CATESTREGUSALSERV_DESCRIPCION, 
              RELUSALSERV.USUARIO_REGISTRO   RELUSALSERV_USR_SERVICIO,
              RELUSALSERV.FECHA_REGISTRO     RELUSALSERV_FEC_REGISTRO, 
              CFG.CODIGO_ASISTENCIAL         CODIGO_ASISTENCIAL,       
              CFG.SALA_ID                    SALA_ID,                  
              CFG.HABITACION_ID              HABITACION_ID,            
              CFG.CAMA_ID                    CAMA_ID,
              CATCAMAS.NOMBRE                CATCAMAS_NOMBRE,
              CATCAMAS.CODIGO_ADMINISTRATIVO CATCAMAS_COD_ADMINISTRATIVO,
              CATCAMAS.ESTADO_CAMA           CATCAMAS_ESTADO_CAMA,
              CATCAMAS.ESTADO_REGISTRO_ID    CATCAMAS_ESTADO_REGISTRO_ID,
              CATESTREGCAMAS.CODIGO          CATESTREGCAMAS_CODIGO,    
              CATESTREGCAMAS.VALOR           CATESTREGCAMAS_VALOR,
              CATESTREGCAMAS.DESCRIPCION     CATESTREGCAMAS_DESCRIPCION,
              CATCAMAS.USUARIO_REGISTRO      CATCAMAS_USR_REGISTRO,
              CATCAMAS.FECHA_REGISTRO        CATCAMAS_FEC_REGISTRO,                  
              CFG.DISPONIBLE                 DISPONIBLE,                
              CFG.CENSABLE                   CENSABLE,       
              CFG.ESTADO_CAMA_ID             ESTADO_CAMA_ID, 
              CATESTCAMA.CODIGO              CATESTCAMA_CODIGO,
              CATESTCAMA.VALOR               CATESTCAMA_VALOR,
              CATESTCAMA.DESCRIPCION         CATESTCAMA_DESCRIPCION,
              CFG.IS_LAST                    IS_LAST,                  
              CFG.ESTADO_REGISTRO_ID         ESTADO_REGISTRO_ID,  
              CATESREG.CODIGO                CATESREG_CODIGO,
              CATESREG.VALOR                 CATESREG_VALOR,
              CATESREG.DESCRIPCION           CATESREG_DESCRIPCION,
              CFG.USUARIO_REGISTRO           USUARIO_REGISTRO,             
              CFG.FECHA_REGISTRO             FECHA_REGISTRO,      
              CFG.USUARIO_MODIFICACION       USUARIO_MODIFICACION,
              CFG.FECHA_MODIFICACION         FECHA_MODIFICACION,  
              CFG.USUARIO_PASIVA             USUARIO_PASIVA,      
              CFG.FECHA_PASIVA               FECHA_PASIVA,        
              CFG.USUARIO_ELIMINA            USUARIO_ELIMINA,     
              CFG.FECHA_ELIMINA              FECHA_ELIMINA        
         FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFG
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
        WHERE CFG.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
        );
     RETURN vRegistro;  
 END FN_OBT_DATOS; 
 
 FUNCTION FN_OBT_DATOS_PAG RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
  OPEN vRegistro FOR
             SELECT *
                    --CFG_USLD_SERVICIO_CAMA_ID, 
                    --UND_SALUD_SERVICIO_ID
               FROM (
                    SELECT *
                     FROM HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP A,(
                          SELECT ROW_NUMBER () OVER (ORDER BY CFG_USLD_SERVICIO_CAMA_ID ASC)
                                 LINE_NUMBER,   
                                 CFG_USLD_SERVICIO_CAMA_ID,
                                 UND_SALUD_SERVICIO_ID, 
                                 RELUSALSERV_UNIDAD_SALUD_ID,
                                 USALSERV_NOMBRE,
                                 USALSERV_CODIGO,
                                 USALSERV_DIRECCION,
                                 USALSERV_ENTIDAD_ADTVA_ID,
                                 ENTADMINSERV_NOMBRE,
                                 ENTADMINSERV_CODIGO,
                                 ENTADMINSERV_TELEFONO,
                                 ENTADMINSERV_EMAIL,
                                 ENTADMINSERV_DIRECCION,
                                 RELUSALSERV_SERVICIO_ID,
                                 CATSERV_CODIGO,
                                 CATSERV_NOMBRE,
                                 CATSERV_DESCRIPCION,
                                 CATSERV_PASIVO,
                                 RELUSALSERV_ESTADO_REGISTRO,
                                 CATESTREGUSALSERV_CODIGO,
                                 CATESTREGUSALSERV_VALOR,
                                 CATESTREGUSALSERV_DESCRIPCION, 
                                 RELUSALSERV_USR_SERVICIO,
                                 RELUSALSERV_FEC_REGISTRO, 
                                 CODIGO_ASISTENCIAL,       
                                 SALA_ID,                  
                                 HABITACION_ID,            
                                 CAMA_ID,
                                 CATCAMAS_NOMBRE,
                                 CATCAMAS_COD_ADMINISTRATIVO,
                                 CATCAMAS_ESTADO_CAMA,
                                 CATCAMAS_ESTADO_REGISTRO_ID,
                                 CATESTREGCAMAS_CODIGO,    
                                 CATESTREGCAMAS_VALOR,
                                 CATCAMAS_NO_SERIE,
                                 CATESTREGCAMAS_DESCRIPCION,
                                 CATCAMAS_USR_REGISTRO,
                                 CATCAMAS_FEC_REGISTRO,                  
                                 DISPONIBLE,                
                                 CENSABLE,       
                                 ESTADO_CAMA_ID, 
                                 CATESTCAMA_CODIGO,
                                 CATESTCAMA_VALOR,
                                 CATESTCAMA_DESCRIPCION,
                                 IS_LAST,                  
                                 ESTADO_REGISTRO_ID,  
                                 CATESREG_CODIGO,
                                 CATESREG_VALOR,
                                 CATESREG_DESCRIPCION,
                                 USUARIO_REGISTRO,             
                                 FECHA_REGISTRO,      
                                 USUARIO_MODIFICACION,
                                 FECHA_MODIFICACION,  
                                 USUARIO_PASIVA,      
                                 FECHA_PASIVA,        
                                 USUARIO_ELIMINA,     
                                 FECHA_ELIMINA        
                    FROM
                    (   
                       SELECT CFG.CFG_USLD_SERVICIO_CAMA_ID  CFG_USLD_SERVICIO_CAMA_ID,
                              CFG.UND_SALUD_SERVICIO_ID      UND_SALUD_SERVICIO_ID, 
                              RELUSALSERV.UNIDAD_SALUD_ID    RELUSALSERV_UNIDAD_SALUD_ID,
                              USALSERV.NOMBRE                USALSERV_NOMBRE,
                              USALSERV.CODIGO                USALSERV_CODIGO,
                              USALSERV.DIRECCION             USALSERV_DIRECCION,
                              USALSERV.ENTIDAD_ADTVA_ID      USALSERV_ENTIDAD_ADTVA_ID,
                              ENTADMINSERV.NOMBRE            ENTADMINSERV_NOMBRE,
                              ENTADMINSERV.CODIGO            ENTADMINSERV_CODIGO,
                              ENTADMINSERV.TELEFONO          ENTADMINSERV_TELEFONO,
                              ENTADMINSERV.EMAIL             ENTADMINSERV_EMAIL,
                              ENTADMINSERV.DIRECCION         ENTADMINSERV_DIRECCION,
                              RELUSALSERV.SERVICIO_ID        RELUSALSERV_SERVICIO_ID,
                              CATSERV.CODIGO                 CATSERV_CODIGO,
                              CATSERV.NOMBRE                 CATSERV_NOMBRE,
                              CATSERV.DESCRIPCION            CATSERV_DESCRIPCION,
                              CATSERV.PASIVO                 CATSERV_PASIVO,
                              RELUSALSERV.ESTADO_REGISTRO    RELUSALSERV_ESTADO_REGISTRO,
                              CATESTREGUSALSERV.CODIGO       CATESTREGUSALSERV_CODIGO,
                              CATESTREGUSALSERV.VALOR        CATESTREGUSALSERV_VALOR,
                              CATESTREGUSALSERV.DESCRIPCION  CATESTREGUSALSERV_DESCRIPCION, 
                              RELUSALSERV.USUARIO_REGISTRO   RELUSALSERV_USR_SERVICIO,
                              RELUSALSERV.FECHA_REGISTRO     RELUSALSERV_FEC_REGISTRO, 
                              CFG.CODIGO_ASISTENCIAL         CODIGO_ASISTENCIAL,       
                              CFG.SALA_ID                    SALA_ID,                  
                              CFG.HABITACION_ID              HABITACION_ID,            
                              CFG.CAMA_ID                    CAMA_ID,
                              CATCAMAS.NOMBRE                CATCAMAS_NOMBRE,
                              CATCAMAS.CODIGO_ADMINISTRATIVO CATCAMAS_COD_ADMINISTRATIVO,
                              CATCAMAS.ESTADO_CAMA           CATCAMAS_ESTADO_CAMA,
                              CATCAMAS.ESTADO_REGISTRO_ID    CATCAMAS_ESTADO_REGISTRO_ID,
                              CATESTREGCAMAS.CODIGO          CATESTREGCAMAS_CODIGO,    
                              CATESTREGCAMAS.VALOR           CATESTREGCAMAS_VALOR,
                              CATCAMAS.NO_SERIE              CATCAMAS_NO_SERIE,
                              CATESTREGCAMAS.DESCRIPCION     CATESTREGCAMAS_DESCRIPCION,
                              CATCAMAS.USUARIO_REGISTRO      CATCAMAS_USR_REGISTRO,
                              CATCAMAS.FECHA_REGISTRO        CATCAMAS_FEC_REGISTRO,                  
                              CFG.DISPONIBLE                 DISPONIBLE,                
                              CFG.CENSABLE                   CENSABLE,       
                              CFG.ESTADO_CAMA_ID             ESTADO_CAMA_ID, 
                              CATESTCAMA.CODIGO              CATESTCAMA_CODIGO,
                              CATESTCAMA.VALOR               CATESTCAMA_VALOR,
                              CATESTCAMA.DESCRIPCION         CATESTCAMA_DESCRIPCION,
                              CFG.IS_LAST                    IS_LAST,                  
                              CFG.ESTADO_REGISTRO_ID         ESTADO_REGISTRO_ID,  
                              CATESREG.CODIGO                CATESREG_CODIGO,
                              CATESREG.VALOR                 CATESREG_VALOR,
                              CATESREG.DESCRIPCION           CATESREG_DESCRIPCION,
                              CFG.USUARIO_REGISTRO           USUARIO_REGISTRO,             
                              CFG.FECHA_REGISTRO             FECHA_REGISTRO,      
                              CFG.USUARIO_MODIFICACION       USUARIO_MODIFICACION,
                              CFG.FECHA_MODIFICACION         FECHA_MODIFICACION,  
                              CFG.USUARIO_PASIVA             USUARIO_PASIVA,      
                              CFG.FECHA_PASIVA               FECHA_PASIVA,        
                              CFG.USUARIO_ELIMINA            USUARIO_ELIMINA,     
                              CFG.FECHA_ELIMINA              FECHA_ELIMINA        
                         FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFG
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
                        WHERE CFG.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO
                                      )
                                         )B
                        WHERE  A.ID = B.CFG_USLD_SERVICIO_CAMA_ID 
                      ORDER BY LINE_NUMBER);  
     RETURN vRegistro;  
 END FN_OBT_DATOS_PAG;  
 
 FUNCTION FN_OBT_DATOS_CFG_CAMAS (pConsulta IN HOSPITALARIO.OBJ_CGF_CAMA_SERVICIO,
                                  pFuente   IN NUMBER) RETURN var_refcursor AS
 vRegistro var_refcursor; 
 vContador SIMPLE_INTEGER := 0;
 BEGIN
 vRegistro :=  FN_OBT_DATOS_PAG;
-- CASE
-- WHEN pFuente = 1 THEN
--      BEGIN
--      vRegistro := FN_OBT_DATOS_X_ID (pConsulta.CfgUsalServCamaId);
--      END;
-- WHEN  pFuente = 2  THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.CODIGO_ASISTENCIAL = pCodAsistencial  AND
--               A.UND_SALUD_SERVICIO_ID = pUsalServId AND 
--               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END;
-- WHEN  pFuente = 3  THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.CODIGO_ASISTENCIAL = pCodAsistencial  AND
--               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END;    
-- WHEN  pFuente = 4  THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.UND_SALUD_SERVICIO_ID = pUsalServId AND 
--               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END;  
-- WHEN  pFuente = 5  THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.SALA_ID = pSalaId  AND
--               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END;     
-- WHEN  pFuente = 6  THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.HABITACION_ID = pHabitacionId  AND
--               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END;                        
-- WHEN  pFuente = 7  THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.CAMA_ID = pCamaId AND
--               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END;  
-- WHEN  pFuente = 8  THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.DISPONIBLE = pDisponible AND
--               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END;  
-- WHEN  pFuente = 9  THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.ESTADO_CAMA_ID = pEstadoCama AND
--               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END; 
-- WHEN  pFuente = 10 THEN
--       BEGIN
--        SELECT COUNT (1)
--          INTO vContador
--          FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS A
--          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS B
--            ON B.UND_SALUD_SERVICIO_ID = A.UND_SALUD_SERVICIO_ID AND
--               B.UNIDAD_SALUD_ID = pUsalud
--         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
--       END;                      
-- WHEN  pFuente = 11 THEN
--       BEGIN
--       vRegistro:= FN_OBT_DATOS;
--       END;  
-- ELSE NULL;      
-- END CASE;
           
 RETURN vRegistro;

 END FN_OBT_DATOS_CFG_CAMAS;
 PROCEDURE PR_C_CFG_USERVICIOS_CAMAS (pConsulta        IN HOSPITALARIO.OBJ_CGF_CAMA_SERVICIO,
                                      pPgn             IN NUMBER,
                                      pPgnAct          IN NUMBER, 
                                      pPgnTmn          IN NUMBER,
                                      pDatosPaginacion OUT var_refcursor,
                                      pRegistro        OUT var_refcursor,
                                      pResultado       OUT VARCHAR2,
                                      pMsgError        OUT VARCHAR2) IS

 vFirma          VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_C_CFG_USERVICIOS_CAMAS => ';  
 vFuente         SIMPLE_INTEGER := 0;
 vPgn            BOOLEAN := TRUE;
 vCantRegistros  SIMPLE_INTEGER := 0;
  vPaginacion    HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos;  
 BEGIN
     CASE
     WHEN (FN_VAL_EXISTE_CFG_CAMA (pConsulta, vCantRegistros, vFuente)) = TRUE THEN 
            CASE
            WHEN vPgn THEN
                        DBMS_OUTPUT.PUT_LINE ('Entra a paginación'); 
                 HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_INDC_PAGINACION_PERSONA(PREGISTROS  => vCantRegistros, 
                                                                            pPgnAct     => pPgnAct, 
                                                                            pPgnTmn     => pPgnTmn, 
                                                                            pPaginacion => vPaginacion, 
                                                                            pMsg        => pMsgError);
                 CASE 
                 WHEN pMsgError IS NOT NULL THEN 
                      pResultado := pMsgError;
                      pMsgError  := pMsgError;
                      RAISE eSalidaConError;
                 ELSE 
                      pDatosPaginacion := FN_OBT_DATOS_PAGINACION (pDatosPaginacion =>  vPaginacion); --pQuery =>  vQuery);
                 END CASE;            
                 PR_I_TABLA_TEMPORAL_CFG_CAMA (pConsulta        => pConsulta,
                                               pPgnAct          => pPgnAct,        
                                               pPgnTmn          => pPgnTmn,       
                                               pTipoPaginacion  => vFuente,
                                               pResultado       => pResultado,     
                                               pMsgError        => pMsgError); 
                                 dbms_output.put_line ('Error saliendo de I tabla temporal cfg camas: '||pMsgError);              
                                 CASE
                                 WHEN pMsgError IS NOT NULL THEN 
                                      RAISE eSalidaConError;
                                 ELSE NULL;
                                 END CASE;
            ELSE NULL; 
            END CASE;          
           dbms_output.put_Line ('despues de validar existe cfg camas');
           pRegistro := FN_OBT_DATOS_CFG_CAMAS (pConsulta, vFuente);
     ELSE
--         CASE
--         WHEN NVL(pCamaId,0) > 0 THEN
--              pResultado := 'No se encontraron registros de pre ingresos relacionadas al [pCamaId: '||pCamaId||']';
--              RAISE eRegistroNoExiste;
--         WHEN pCodAdmin IS NOT NULL THEN
--              pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Codigo Admin: '||pCodAdmin||']';
--              RAISE eRegistroNoExiste;
--         WHEN NVL(pEstadoCama,0) > 0 THEN
--               pResultado := 'No se encontraron registros de pre ingresos relacionadas al [EstadoCama Id: '||pEstadoCama||']';
--               RAISE eRegistroNoExiste;
--         ELSE 
               pResultado := 'No se encontraron registros de cat camas';
               RAISE eRegistroNoExiste;
--         END CASE;     
     END CASE;
 EXCEPTION
 WHEN eSalidaConError THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;  
 WHEN eRegistroNoExiste THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al querer obtener información de Cat Camas. [Id: '||pConsulta.CfgUsalServCamaId||']';
      pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_C_CFG_USERVICIOS_CAMAS;  
 
 FUNCTION FN_VALIDA_COD_ASISTENCIAL (pCfgUsalServCamaId IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE, 
                                     pCodAsistencial    IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CODIGO_ASISTENCIAL%TYPE) RETURN BOOLEAN AS
 vContador SIMPLE_INTEGER := 0;
 vRetorna  BOOLEAN := FALSE;   
 BEGIN
   CASE
   WHEN NVL(pCfgUsalServCamaId,0) > 0 THEN
        BEGIN
          SELECT COUNT (1)
            INTO vContador
            FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
           WHERE CFG_USLD_SERVICIO_CAMA_ID != pCfgUsalServCamaId AND
                 CODIGO_ASISTENCIAL = pCodAsistencial AND
                 ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;  --!= vGLOBAL_ESTADO_ELIMINADO;
        END;
   ELSE 
       BEGIN
          SELECT COUNT (1)
            INTO vContador
            FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
           WHERE CODIGO_ASISTENCIAL = pCodAsistencial AND
                 ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;   --!= vGLOBAL_ESTADO_ELIMINADO;       
       END;
   END CASE;
   
   CASE
   WHEN vContador > 0 THEN
        vRetorna := TRUE;
   ELSE NULL;
   END CASE; 
   RETURN vRetorna;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vRetorna;
 END FN_VALIDA_COD_ASISTENCIAL;       
 
 FUNCTION FN_VALIDA_CAMA_ID (pCfgUsalServCamaId IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE, 
                             pCamaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CAMA_ID%TYPE) RETURN BOOLEAN AS     
 vContador SIMPLE_INTEGER := 0;
 vRetorna  BOOLEAN := FALSE; 
 BEGIN
   CASE
   WHEN NVL(pCfgUsalServCamaId,0) > 0 THEN
        BEGIN
          SELECT COUNT (1)
            INTO vContador
            FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
           WHERE CFG_USLD_SERVICIO_CAMA_ID != pCfgUsalServCamaId AND
                 CAMA_ID = pCamaId AND
                 ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;   --!= vGLOBAL_ESTADO_ELIMINADO;
        END;
   ELSE 
       BEGIN
          SELECT COUNT (1)
            INTO vContador
            FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
           WHERE CAMA_ID = pCamaId AND
                 ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;   -- != vGLOBAL_ESTADO_ELIMINADO;       
       END;
   END CASE;

   CASE
   WHEN vContador > 0 THEN
        vRetorna := TRUE;
   ELSE 
      BEGIN
       SELECT COUNT (1)
         INTO vContador
         FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
        WHERE CAMA_ID = pCamaId AND 
              ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;
        CASE
        WHEN vContador > 0 THEN
             vRetorna := TRUE;
        ELSE NULL;
        END CASE;
      END;
   END CASE; 
   
 RETURN vRetorna;
 EXCEPTION
 WHEN OTHERS THEN 
      vRetorna := TRUE; 
      RETURN vRetorna;
 END FN_VALIDA_CAMA_ID;   
 
 FUNCTION FN_OBT_REL_UNID_SERVID (pUsalud     IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,
                                  pServicioId IN HOSPITALARIO.SNH_CAT_SERVICIOS.SERVICIO_ID%TYPE) RETURN NUMBER AS
 vContador       SIMPLE_INTEGER := 0;
 vUndSaludServId HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS.UND_SALUD_SERVICIO_ID%TYPE;
 BEGIN
    SELECT COUNT (1)
      INTO vContador
      FROM HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS
     WHERE SERVICIO_ID = pServicioId AND
           UNIDAD_SALUD_ID = pUsalud;
     CASE
     WHEN vContador > 0 THEN
          BEGIN
            SELECT UND_SALUD_SERVICIO_ID
              INTO vUndSaludServId
              FROM HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS
             WHERE SERVICIO_ID = pServicioId AND
                   UNIDAD_SALUD_ID = pUsalud;
          END;
     ELSE NULL;
     END CASE;
     
     RETURN vUndSaludServId;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vUndSaludServId; 
 END FN_OBT_REL_UNID_SERVID;      

 PROCEDURE PR_CRUD_CFG_USERVICIOS_CAMAS (pCfgUsalServCamaId IN OUT HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                         pUsalServId        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.UND_SALUD_SERVICIO_ID%TYPE,
                                         pServicioId        IN HOSPITALARIO.SNH_CAT_SERVICIOS.SERVICIO_ID%TYPE,
                                         pCodAsistencial    IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CODIGO_ASISTENCIAL%TYPE,
                                         pSalaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.SALA_ID%TYPE,
                                         pHabitacionId      IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.HABITACION_ID%TYPE,
                                         pCamaId            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CAMA_ID%TYPE,
                                         pDisponible        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.DISPONIBLE%TYPE,
                                         pCensable          IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CENSABLE%TYPE,
                                         pEstadoCama        IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.ESTADO_CAMA_ID%TYPE,
                                         pIslast            IN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.IS_LAST%TYPE,
                                         pUsalud            IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,
                                         pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                         pAccionEstado      IN VARCHAR2,                                  
                                         pTipoAccion        IN VARCHAR2,                                  
                                         pPgn               IN NUMBER,
                                         pPgnAct            IN NUMBER default 1, 
                                         pPgnTmn            IN NUMBER default 100,
                                         pDatosPaginacion   OUT var_refcursor,
                                         pRegistro          OUT var_refcursor,                           
                                         pResultado         OUT VARCHAR2,                                
                                         pMsgError          OUT VARCHAR2) IS
 vFirma             MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_CFG_USERVICIOS_CAMAS => ';
 vResultado         MAXVARCHAR2;
 vEstadoRegistroId  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;   
 vUsalServId        HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.UND_SALUD_SERVICIO_ID%TYPE;                          
 BEGIN
      CASE
      WHEN pTipoAccion IS NULL THEN 
           pResultado := 'El párametro pTipoAccion no puede venir NULL';
           pMsgError  := pResultado;
           RAISE eParametroNull;
      ELSE NULL;
      END CASE;
      
      CASE
      WHEN pTipoAccion = kINSERT THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;
           dbms_output.put_line ('Sale de validar usuario');
            CASE
            WHEN FN_VALIDA_COD_ASISTENCIAL (pCfgUsalServCamaId, pCodAsistencial) = TRUE THEN
                 pResultado := 'El código asistencial que ingresa ya está asignado: '||pCodAsistencial;
                 pMsgError  := pResultado;
                 RAISE eRegistroExiste;
            WHEN FN_VALIDA_CAMA_ID (pCfgUsalServCamaId, pCamaId) = TRUE THEN
                 pResultado := 'La cama no se puede asignar debido a que está marcada como indisponible: Id Cama'||pCamaId;
                 pMsgError  := pResultado;
                 RAISE eRegistroExiste;
            ELSE NULL;
            END CASE;
            CASE
            WHEN NVL(pUsalServId,0) = 0 THEN
                 CASE
                 WHEN (NVL(pServicioId,0) = 0 AND 
                       NVL(pUsalud,0) = 0) THEN
                       pResultado := 'Los parámetros Unidad salud y Servicio Id no pueden venir nulos. Se necesitan para buscar el Id de la tabla Rel Unidad salud Servicios.';
                       pMsgError  := pResultado;
                       RAISE eParametroNull;
                 ELSE 
                 vUsalServId := FN_OBT_REL_UNID_SERVID (pUsalud, pServicioId);
                 END CASE;
                 NULL;
            ELSE NULL;
            END CASE;
            PR_I_CFG_USERVICIOS_CAMAS (pCfgUsalServCamaId =>  pCfgUsalServCamaId, 
                                       pUsalServId        =>  vUsalServId,      -- pUsalServId,       
                                       pCodAsistencial    =>  pCodAsistencial,   
                                       pSalaId            =>  pSalaId,           
                                       pHabitacionId      =>  pHabitacionId,     
                                       pCamaId            =>  pCamaId,           
                                       pDisponible        =>  pDisponible,       
                                       pCensable          =>  pCensable,         
                                       pEstadoCama        =>  pEstadoCama,       
                                       pUsuario           =>  pUsuario,          
                                       pResultado         =>  pResultado,        
                                       pMsgError          =>  pMsgError);         
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            WHEN NVL(pCfgUsalServCamaId,0) > 0 THEN  
                 PR_C_CFG_USERVICIOS_CAMAS (pConsulta        => HOSPITALARIO.OBJ_CGF_CAMA_SERVICIO (pCfgUsalServCamaId, 
                                                                                                    pCodAsistencial,    
                                                                                                    pUsalServId,        
                                                                                                    pServicioId,
                                                                                                    pSalaId,            
                                                                                                    pHabitacionId,      
                                                                                                    pCamaId,            
                                                                                                    pDisponible,        
                                                                                                    pEstadoCama,         
                                                                                                    pUsalud,      
                                                                                                    null,    --FecInicio,          
                                                                                                    null    --FecFin,             
                                                                                 ),
                                            pPgn             => pPgn,             
                                            pPgnAct          => pPgnAct,          
                                            pPgnTmn          => pPgnTmn,         
                                            pDatosPaginacion => pDatosPaginacion,
                                            pRegistro        => pRegistro,         
                                            pResultado       => pResultado,        
                                            pMsgError        => pMsgError);  
                 CASE
                 WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                     RAISE eSalidaConError;
                 ELSE 
                     vResultado := 'Se crea exitosamente el registro de configuracion camas [Id]: '||pCfgUsalServCamaId||', devolviendo el JSon de este';
                 END CASE;
            ELSE NULL;     
            END CASE; 
      WHEN pTipoAccion = kUPDATE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;      
                      
           CASE
           WHEN pAccionEstado = 0 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_ACTIVO;
           WHEN pAccionEstado = 1 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_PASIVO;
           ELSE NULL;
           END CASE;
           PR_U_CFG_USERVICIOS_CAMAS (pCfgUsalServCamaId => pCfgUsalServCamaId,
                                      pUsalServId        => pUsalServId,       
                                      pCodAsistencial    => pCodAsistencial,   
                                      pSalaId            => pSalaId,           
                                      pHabitacionId      => pHabitacionId,     
                                      pCamaId            => pCamaId,           
                                      pDisponible        => pDisponible,       
                                      pCensable          => pCensable,         
                                      pEstadoCama        => pEstadoCama,       
                                      pIsLast            => pIslast,
                                      pEstadoRegistroId  => vEstadoRegistroId, 
                                      pUsuario           => pUsuario,          
                                      pResultado         => pResultado,        
                                      pMsgError          => pMsgError);         
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            ELSE 
               CASE
               WHEN NVL(pCfgUsalServCamaId,0) > 0 THEN
               -- se realiza consulta de datos luego de realizar la actualización de persona
                    PR_C_CFG_USERVICIOS_CAMAS (pConsulta        => HOSPITALARIO.OBJ_CGF_CAMA_SERVICIO (pCfgUsalServCamaId, 
                                                                                                       pCodAsistencial,    
                                                                                                       pUsalServId,        
                                                                                                       pServicioId,
                                                                                                       pSalaId,            
                                                                                                       pHabitacionId,      
                                                                                                       pCamaId,            
                                                                                                       pDisponible,        
                                                                                                       pEstadoCama,         
                                                                                                       pUsalud,      
                                                                                                       null,    --FecInicio,          
                                                                                                       null    --FecFin,             
                                                                                    ),
                                               pPgn             => pPgn,            
                                               pPgnAct          => pPgnAct,         
                                               pPgnTmn          => pPgnTmn,         
                                               pDatosPaginacion => pDatosPaginacion,
                                               pRegistro        => pRegistro,         
                                               pResultado       => pResultado,        
                                               pMsgError        => pMsgError);         
                    CASE
                    WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                         RAISE eSalidaConError;
                    ELSE vResultado := 'Se actualiza exitosamente el registro de configuración camas [Id]: '||pCfgUsalServCamaId||', devolviendo el JSon de este';
                    END CASE;          
               ELSE NULL;    
               END CASE;                 
            END CASE;           
      WHEN pTipoAccion = kCONSULTAR THEN
           PR_C_CFG_USERVICIOS_CAMAS (pConsulta        => HOSPITALARIO.OBJ_CGF_CAMA_SERVICIO (pCfgUsalServCamaId, 
                                                                                              pCodAsistencial,    
                                                                                              pUsalServId,        
                                                                                              pServicioId,
                                                                                              pSalaId,            
                                                                                              pHabitacionId,      
                                                                                              pCamaId,            
                                                                                              pDisponible,        
                                                                                              pEstadoCama,         
                                                                                              pUsalud,      
                                                                                              null,    --FecInicio,          
                                                                                              null    --FecFin,             
                                                                             ),
                                      pPgn             => pPgn,            
                                      pPgnAct          => pPgnAct,         
                                      pPgnTmn          => pPgnTmn,         
                                      pDatosPaginacion => pDatosPaginacion,
                                      pRegistro        => pRegistro,         
                                      pResultado       => pResultado,        
                                      pMsgError        => pMsgError);             
           CASE
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Consulta realizada con éxito';
      WHEN pTipoAccion = kDELETE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;     
           CASE
           WHEN NVL(pCfgUsalServCamaId,0) > 0 THEN
           PR_U_CFG_USERVICIOS_CAMAS (pCfgUsalServCamaId => pCfgUsalServCamaId,
                                      pUsalServId        => pUsalServId,       
                                      pCodAsistencial    => pCodAsistencial,   
                                      pSalaId            => pSalaId,           
                                      pHabitacionId      => pHabitacionId,     
                                      pCamaId            => pCamaId,           
                                      pDisponible        => pDisponible,       
                                      pCensable          => pCensable,         
                                      pEstadoCama        => pEstadoCama,       
                                      pIsLast            => pIslast,
                                      pEstadoRegistroId  => vGLOBAL_ESTADO_ELIMINADO,  --vEstadoRegistroId, 
                                      pUsuario           => pUsuario,          
                                      pResultado         => pResultado,        
                                      pMsgError          => pMsgError);           
           CASE 
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Registro eliminado con éxito';
           ELSE 
               pResultado := 'No hay registros para eliminar con el Id: '||pCfgUsalServCamaId;
               pMsgError  := pResultado;
               RAISE eUpdateInvalido;    
           END CASE; 
      ELSE 
          pResultado := 'El Tipo acción no es un parámetro valido.';
          pMsgError  := pResultado;
          RAISE eParametrosInvalidos;
      END CASE;
      pResultado := vResultado;     
 EXCEPTION
    WHEN eUpdateInvalido THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;      
    WHEN eParametroNull THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroNoExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;                       
    WHEN eParametrosInvalidos THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pResultado;
    WHEN eSalidaConError THEN
         pResultado := pResultado;  --vResultado;
         pMsgError  := vFirma||pMsgError;  --vMsgError;
    WHEN OTHERS THEN
         pResultado := 'Error no controlado';
         pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_CRUD_CFG_USERVICIOS_CAMAS;
 
 FUNCTION FN_OBT_CAMAID (pCfgUsalServCamaId IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE) RETURN NUMBER AS
 vContador SIMPLE_INTEGER := 0;
 vCamaId   HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE;
 BEGIN
   SELECT COUNT (1)
     INTO vContador
     FROM HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS
    WHERE CFG_USLD_SERVICIO_CAMA_ID = pCfgUsalServCamaId AND
          IS_LAST = 1;
    CASE
    WHEN vContador > 0 THEN
         NULL;
    ELSE NULL;
    END CASE;
 END FN_OBT_CAMAID;
 
 FUNCTION FN_VAL_CFG_USLD_SERVCAMA_IND (pCfgUsalServCamaId IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE) RETURN BOOLEAN AS
 vCamaId HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE := FN_OBT_CAMAID (pCfgUsalServCamaId);
 BEGIN
  
  RETURN FALSE;
 END FN_VAL_CFG_USLD_SERVCAMA_IND;
 
 PROCEDURE PR_I_REL_ADMSRV_CAMAS (pAdminServCamaId   OUT HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SRV_CAMA_ID%TYPE,
                                  pCfgUsalServCamaId IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                  pAdminServId       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE,
                                  pFechaInicio       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE,
                                  pHoraInicio        IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE,  
                                  pFechaFin          IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE,
                                  pHoraFin           IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE, 
                                  pIsLast            IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.IS_LAST%TYPE,   
                                  pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                  pResultado         OUT VARCHAR2,                                
                                  pMsgError          OUT VARCHAR2) IS
 vFirma MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_I_REL_ADMSRV_CAMAS => ';                                 
 BEGIN
--     CASE
--     WHEN FN_VAL_CFG_USLD_SERVCAMA_IND (pCfgUsalServCamaId) = TRUE THEN
--          NULL;
--     ELSE NULL;
--     END CASE;
     INSERT INTO HOSPITALARIO.SNH_REL_ADMSRV_CAMAS (CFG_USLD_SERVICIO_CAMA_ID,
                                                    ADMISION_SERVICIO_ID, 
                                                    FECHA_INI,
                                                    HORA_INI,
                                                    FECHA_FIN,
                                                    HORA_FIN,
                                                    IS_LAST,
                                                    ESTADO_REGISTRO_ID, 
                                                    USUARIO_REGISTRO)
                                             VALUES(pCfgUsalServCamaId,
                                                    pAdminServId,
                                                    pFechaInicio,
                                                    pHoraInicio, 
                                                    pFechaFin,   
                                                    pHoraFin,   
                                                    kES_PRINCIPAL,
                                                    vGLOBAL_ESTADO_ACTIVO, 
                                                    pUsuario)
                                                    RETURNING ADMISION_SRV_CAMA_ID INTO pAdminServCamaId;
                                
    pResultado := 'Admisión servicios camas creado con éxito. [Id:'||pAdminServCamaId||']';
    DBMS_OUTPUT.PUT_LINE ('pAdminServCamaId: '||pAdminServCamaId); 
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;
 WHEN eRegistroExiste THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;     
 WHEN OTHERS THEN
      pResultado := 'Error al crear el registro persona';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm; 
      DBMS_OUTPUT.PUT_LINE ('pMsgError: '||pMsgError);                                        
 END PR_I_REL_ADMSRV_CAMAS;
 
 FUNCTION FN_EXISTE_ADMSERV_CAMAS (pCfgUsalServCamaId IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                   pAdminServId       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE) RETURN BOOLEAN AS
 vContador  SIMPLE_INTEGER := 0;
 vRetorna BOOLEAN := FALSE;
 BEGIN 
  SELECT COUNT (1)
    INTO vContador
    FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
   WHERE ADMISION_SERVICIO_ID      = pAdminServId AND 
         CFG_USLD_SERVICIO_CAMA_ID != pCfgUsalServCamaId AND
         IS_LAST = 1 AND
         ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;
  
     CASE
     WHEN vContador > 0 THEN
          vRetorna := TRUE;
     ELSE NULL;
     END CASE;  
     RETURN vRetorna;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vRetorna;
 END FN_EXISTE_ADMSERV_CAMAS;
 
 PROCEDURE PR_U_ISLAST_ADMSERV_CAMAS (pCfgUsalServCamaId IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                      pAdminServId       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE,
                                      pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                                      pResultado         OUT VARCHAR2,                               
                                      pMsgError          OUT VARCHAR2) IS
 vFirma VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_U_ISLAST_ADMSERV_CAMAS => ';                                       
 BEGIN
     UPDATE HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
        SET IS_LAST = 0,
            USUARIO_MODIFICACION = pUsuario
      WHERE ADMISION_SERVICIO_ID      = pAdminServId AND 
            CFG_USLD_SERVICIO_CAMA_ID != pCfgUsalServCamaId;
 EXCEPTION
 WHEN OTHERS THEN  
      pResultado := 'Error al crear el configuración de camas';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;  

 END PR_U_ISLAST_ADMSERV_CAMAS;
 
 PROCEDURE PR_U_REL_ADMSRV_CAMAS (pAdminServCamaId   IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SRV_CAMA_ID%TYPE,
                                  pCfgUsalServCamaId IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                  pAdminServId       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE,
                                  pFechaInicio       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE,
                                  pHoraInicio        IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE,  
                                  pFechaFin          IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE,
                                  pHoraFin           IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE, 
                                  pIsLast            IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.IS_LAST%TYPE,   
                                  pEstadoRegistroId  IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ESTADO_REGISTRO_ID%TYPE,
                                  pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,
                                  pResultado         OUT VARCHAR2,                               
                                  pMsgError          OUT VARCHAR2) IS
 vFirma             VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_U_PRE_INGRESO => ';  
 BEGIN
     CASE
     WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ELIMINADO THEN
         <<EliminaRegistro>>
          BEGIN
             UPDATE HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                SET ESTADO_REGISTRO_ID   = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,
                    USUARIO_ELIMINA      = pUsuario,
                    FECHA_ELIMINA        = CURRENT_TIMESTAMP
              WHERE ADMISION_SRV_CAMA_ID = pAdminServCamaId;
          EXCEPTION
             WHEN OTHERS THEN
                  pResultado := 'Error no controlado al eliminar registro [Id] - '||pAdminServCamaId;
                  pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                  RETURN;                
          END EliminaRegistro;
          pResultado := 'Se ha eliminado el registro. [Id:'||pAdminServCamaId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_PASIVO THEN
         <<PasivaRegistro>>       
         BEGIN
            UPDATE  HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
                SET ESTADO_REGISTRO_ID = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,  
                    USUARIO_PASIVA       = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                           ELSE USUARIO_PASIVA
                                           END,    
                    FECHA_PASIVA         = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                           ELSE FECHA_PASIVA
                                           END
             WHERE ADMISION_SRV_CAMA_ID = pAdminServCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;     
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al pasivar registro [Id] - '||pAdminServCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END PasivaRegistro;
         pResultado := 'Se ha pasivado el registro. [Id:'||pAdminServCamaId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN
          <<ActivarRegistro>>
         BEGIN
            UPDATE HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
               SET ESTADO_REGISTRO_ID   = pEstadoRegistroId, 
                   USUARIO_MODIFICACION = pUsuario,    
                   USUARIO_PASIVA       = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                          ELSE USUARIO_PASIVA
                                          END,    
                   FECHA_PASIVA         = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                          ELSE FECHA_PASIVA
                                          END
             WHERE ADMISION_SRV_CAMA_ID = pAdminServCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [Id] - '||pAdminServCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActivarRegistro; 
         pResultado := 'Se ha activado el registro. [Id:'||pAdminServCamaId||']';                        
     ELSE 
         <<ActualizarRegistro>>
         BEGIN
           CASE
           WHEN NVL(pIsLast,0) = kES_PRINCIPAL THEN 
               CASE        
               WHEN FN_EXISTE_ADMSERV_CAMAS (pAdminServId, pCfgUsalServCamaId) = TRUE THEN
                    PR_U_ISLAST_ADMSERV_CAMAS (pAdminServId       => pAdminServId,
                                               pCfgUsalServCamaId => pCfgUsalServCamaId, 
                                               pUsuario           => pUsuario,
                                               pResultado         => pResultado,
                                               pMsgError          => pMsgError);
                    CASE
                    WHEN pMsgError IS NOT NULL THEN
                         pResultado := pResultado;
                         pMsgError  := pMsgError;
                         RAISE eSalidaConError;
                    ELSE NULL;
                    END CASE;                             
               ELSE NULL;
               END CASE;  
           ELSE NULL;
           END CASE;       
            UPDATE HOSPITALARIO.SNH_REL_ADMSRV_CAMAS  
               SET CFG_USLD_SERVICIO_CAMA_ID = NVL(pCfgUsalServCamaId, CFG_USLD_SERVICIO_CAMA_ID),
                   ADMISION_SERVICIO_ID      = NVL(pAdminServId, ADMISION_SERVICIO_ID), 
                   FECHA_INI                 = NVL(pFechaInicio, FECHA_INI),
                   HORA_INI                  = NVL(pHoraInicio, HORA_INI), 
                   FECHA_FIN                 = NVL(pFechaFin, FECHA_FIN),   
                   HORA_FIN                  = NVL(pHoraFin, HORA_FIN),   
                   IS_LAST                   = NVL(pIsLast, IS_LAST),
                   USUARIO_MODIFICACION  = pUsuario          
             WHERE ADMISION_SRV_CAMA_ID = pAdminServCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [Id] - '||pAdminServCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActualizarRegistro; 
         pResultado := 'Se ha actualizado el registro. [Id:'||pAdminServCamaId||']';                              
     END CASE;
 EXCEPTION
 WHEN eSalidaConError THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;
 WHEN OTHERS THEN
      pResultado := 'Error al actualizar onfiguración de camas';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;   
 END PR_U_REL_ADMSRV_CAMAS;
 
 FUNCTION FN_VAL_EXISTE_RELADMINSERV (pConsulta      IN HOSPITALARIO.OBJ_ADMSRV_CAMAS,
                                      pPgn           IN BOOLEAN,
                                      pCantRegistros OUT NUMBER,
                                      pFuente        OUT NUMBER) RETURN BOOLEAN AS
 vContador SIMPLE_INTEGER := 0;
 vExiste BOOLEAN := FALSE; 
 BEGIN
 CASE
 WHEN NVL(pConsulta.AdminServCamaId,0) > 0 THEN
      BEGIN
       SELECT COUNT (1)
         INTO vContador   
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
        WHERE ADMISION_SRV_CAMA_ID = pConsulta.AdminServCamaId AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;       
      pFuente := 1;
      END;
 WHEN (NVL(pConsulta.CfgUsalServCamaId,0) > 0 AND
       NVL(pConsulta.IsLast,0) > 0) THEN
      BEGIN
       SELECT COUNT (1)
         INTO vContador   
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
        WHERE CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
              IS_LAST = pConsulta.IsLast AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;       
      pFuente := 2;
      END;
 WHEN (NVL(pConsulta.AdminServId,0) > 0 AND
       NVL(pConsulta.IsLast,0) > 0) THEN   
      BEGIN
       SELECT COUNT (1)
         INTO vContador   
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
        WHERE ADMISION_SERVICIO_ID = pConsulta.AdminServId AND
              IS_LAST = pConsulta.IsLast AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;       
      pFuente := 3;
      END;
 WHEN (NVL(pConsulta.UnidadSaludId,0) > 0 AND
       NVL(pConsulta.IsLast,0) > 0) THEN 
      BEGIN 
       SELECT COUNT (1)
         INTO vContador         
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS A
         JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
         ON B.CFG_USLD_SERVICIO_CAMA_ID = A.CFG_USLD_SERVICIO_CAMA_ID
         JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS C
         ON C.UND_SALUD_SERVICIO_ID = B.UND_SALUD_SERVICIO_ID AND
            C.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
      WHERE A.IS_LAST = pConsulta.IsLast AND
            A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;     
      pFuente := 4;  
      END;
 WHEN NVL(pConsulta.CfgUsalServCamaId,0) > 0 THEN
      BEGIN
       SELECT COUNT (1)
         INTO vContador   
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
        WHERE CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;       
      pFuente := 5;
      END;
 WHEN NVL(pConsulta.AdminServId,0) > 0 THEN   
      BEGIN
       SELECT COUNT (1)
         INTO vContador   
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
        WHERE ADMISION_SERVICIO_ID = pConsulta.AdminServId AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;       
      pFuente := 6;
      END;
 WHEN NVL(pConsulta.UnidadSaludId,0) > 0 THEN 
      BEGIN 
       SELECT COUNT (1)
         INTO vContador         
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS A
         JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS B
         ON B.CFG_USLD_SERVICIO_CAMA_ID = A.CFG_USLD_SERVICIO_CAMA_ID
         JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS C
         ON C.UND_SALUD_SERVICIO_ID = B.UND_SALUD_SERVICIO_ID AND
            C.UNIDAD_SALUD_ID = pConsulta.UnidadSaludId
      WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;     
      pFuente := 7;  
      END;
 WHEN NVL(pConsulta.IsLast,0) > 0 THEN   
      BEGIN
       SELECT COUNT (1)
         INTO vContador   
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
        WHERE IS_LAST = pConsulta.IsLast AND
              ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;       
      pFuente := 8;
      END;                  
 ELSE 
      BEGIN
       SELECT COUNT (1)
         INTO vContador   
         FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
        WHERE ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;       
      pFuente := 9;
      END;  
 END CASE; 
 CASE
 WHEN vContador > 0 THEN
      vExiste := TRUE;
 ELSE NULL;
 END CASE;
 pCantRegistros := vContador;   
   RETURN vExiste;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vExiste;
 END FN_VAL_EXISTE_RELADMINSERV;
 
 FUNCTION FB_RELADMINSERV_PAG RETURN var_refcursor AS
 vRegistros var_refcursor;
 BEGIN
      OPEN vRegistros FOR
              SELECT *
                    --ADMISION_SRV_CAMA_ID, 
                    --CFG_USLD_SERVICIO_CAMA_ID
               FROM (
                    SELECT *
                     FROM HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP A,(
                          SELECT ROW_NUMBER () OVER (ORDER BY ADMISION_SRV_CAMA_ID ASC)
                                 LINE_NUMBER,
                                 ADMISION_SRV_CAMA_ID,
                                 CFG_USLD_SERVICIO_CAMA_ID,
                                 CFGUND_SALUD_SERVICIO_ID, 
                                 CFG_RELUSALSERV_USALUD_ID,
                                 CFG_USALSERV_NOMBRE,
                                 CFG_USALSERV_CODIGO,
                                 CFG_USALSERV_DIRECCION,
                                 CFG_USALSERV_ENTIDAD_ADTVA_ID,
                                 CFG_ENTADMINSERV_NOMBRE,
                                 CFG_ENTADMINSERV_CODIGO,
                                 CFG_ENTADMINSERV_TELEFONO,
                                 CFG_ENTADMINSERV_EMAIL,
                                 CFG_ENTADMINSERV_DIRECCION,
                                 CFG_RELUSALSERV_SERVICIO_ID,
                                 CFG_CATSERV_CODIGO,
                                 CFG_CATSERV_NOMBRE,
                                 CFG_CATSERV_DESCRIPCION,
                                 CFG_CATSERV_PASIVO,
                                 CFG_RELUSALSERV_ESTADO_REGISTRO,
                                 CFG_CATESTREGUSALSERV_CODIGO,
                                 CFG_CATESTREGUSALSERV_VALOR,
                                 CFG_CATESTREGUSALSERV_DESCRIPCION,
                                 CFG_RELUSALSERV_USR_SERVICIO,
                                 CFG_RELUSALSERV_FEC_REGISTRO, 
                                 CFG_CODIGO_ASISTENCIAL,       
                                 CFG_SALA_ID,                  
                                 CFG_HABITACION_ID,            
                                 CFG_CAMA_ID,
                                 CFG_CATCAMAS_NOMBRE,
                                 CFG_CATCAMAS_COD_ADMINISTRATIVO,
                                 CFG_CATCAMAS_ESTADO_CAMA,
                                 CFG_CATCAMAS_NO_SERIE,
                                 CFG_CATCAMAS_ESTADO_REGISTRO_ID,
                                 CFG_CATESTREGCAMAS_CODIGO,    
                                 CFG_CATESTREGCAMAS_VALOR,
                                 CFG_CATESTREGCAMAS_DESCRIPCION,
                                 CFG_CATCAMAS_USR_REGISTRO,
                                 CFG_CATCAMAS_FEC_REGISTRO,       
                                 CFG_DISPONIBLE,                
                                 CFG_CENSABLE,       
                                 CFG_ESTADO_CAMA_ID, 
                                 CFG_CATESTCAMA_CODIGO,
                                 CFG_CATESTCAMA_VALOR,
                                 CFG_CATESTCAMA_DESCRIPCION,
                                 CFG_IS_LAST,                  
                                 CFG_ESTADO_REGISTRO_ID,  
                                 CFG_CATESREG_CODIGO,
                                 CFG_CATESREG_VALOR,
                                 CFG_CATESREG_DESCRIPCION,
                                 CFG_USUARIO_REGISTRO,            
                                 CFG_FECHA_REGISTRO,      
                                 ADMISION_SERVICIO_ID,
                                 FECHA_INI,
                                 HORA_INI,
                                 FECHA_FIN,
                                 HORA_FIN,
                                 IS_LAST,
                                 ESTADO_REGISTRO_ID, 
                                 CATESREG_CODIGO,
                                 CATESREG_VALOR,
                                 CATESREG_DESCRIPCION,
                                 USUARIO_REGISTRO,
                                 FECHA_REGISTRO,
                                 USUARIO_MODIFICACION,
                                 FECHA_MODIFICACION,
                                 USUARIO_PASIVA,
                                 FECHA_PASIVA,
                                 USUARIO_ELIMINA,
                                 FECHA_ELIMINA
                          FROM (
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
                                      )
                                         )B
                        WHERE  A.ID = B.ADMISION_SRV_CAMA_ID 
                      ORDER BY LINE_NUMBER);  
  RETURN vRegistros;
 END FB_RELADMINSERV_PAG; 
 
 FUNCTION FN_OBT_DATOS_RELADMINSERV (pConsulta IN HOSPITALARIO.OBJ_ADMSRV_CAMAS,
                                     pPgn      IN BOOLEAN, 
                                     pFuente   IN NUMBER) RETURN var_refcursor AS
 vRegistros var_refcursor;
 BEGIN
  vRegistros := FB_RELADMINSERV_PAG;
  RETURN vRegistros;
 END FN_OBT_DATOS_RELADMINSERV;
 
 PROCEDURE PR_C_REL_ADMSRV_CAMAS (pConsulta        IN HOSPITALARIO.OBJ_ADMSRV_CAMAS,
                                  pPgn             IN NUMBER,
                                  pPgnAct          IN NUMBER, 
                                  pPgnTmn          IN NUMBER,
                                  pDatosPaginacion OUT var_refcursor,
                                  pRegistro        OUT var_refcursor,
                                  pResultado       OUT VARCHAR2,   
                                  pMsgError        OUT VARCHAR2) IS
 vFirma           VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_C_REL_ADMSRV_CAMAS => ';  
 vFuente          SIMPLE_INTEGER := 0;
 vPgn             BOOLEAN := TRUE;
 vFechaInicio     DATE;
 vFechaFin        DATE;
 vNombreCompleto  MAXVARCHAR2;
 vPrimerNombre    MAXVARCHAR2;
 vSegundoNombre   MAXVARCHAR2;
 vPrimerApellido  MAXVARCHAR2;
 vSegundoApellido MAXVARCHAR2;
 vSexo            MAXVARCHAR2;
 vUnidadSaludId   NUMBER;
 vMunicipioId     NUMBER;
 vEntAdminId      NUMBER;
 vCantRegistros   SIMPLE_INTEGER := 0;
 vPaginacion HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos;  
 BEGIN
     CASE
     WHEN (FN_VAL_EXISTE_RELADMINSERV (pConsulta, vPgn, 
                                       vCantRegistros, vFuente)) = TRUE THEN 
            DBMS_OUTPUT.PUT_LINE ('Valida que existe rel admin cama');                          
            CASE
            WHEN vPgn THEN
                        DBMS_OUTPUT.PUT_LINE ('Entra a paginación'); 
                 HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_INDC_PAGINACION_PERSONA(PREGISTROS  => vCantRegistros, 
                                                                            pPgnAct     => pPgnAct, 
                                                                            pPgnTmn     => pPgnTmn, 
                                                                            pPaginacion => vPaginacion, 
                                                                            pMsg        => pMsgError);
                 CASE 
                 WHEN pMsgError IS NOT NULL THEN 
                      pResultado := pMsgError;
                      pMsgError  := pMsgError;
                      RAISE eSalidaConError;
                 ELSE 
                      pDatosPaginacion := FN_OBT_DATOS_PAGINACION (pDatosPaginacion =>  vPaginacion); --pQuery =>  vQuery);
                 END CASE;            
                 PR_I_TABLA_TEMP_RELADMINSERV (pConsulta        => pConsulta,
                                               pPgnAct          => pPgnAct,        
                                               pPgnTmn          => pPgnTmn,       
                                               pTipoPaginacion  => vFuente,
                                               pResultado       => pResultado,     
                                               pMsgError        => pMsgError); 
                                 dbms_output.put_line ('Error saliendo de I tabla temporal Valida que existe rel admin cama: '||pMsgError);              
                                 CASE
                                 WHEN pMsgError IS NOT NULL THEN 
                                      RAISE eSalidaConError;
                                 ELSE NULL;
                                 END CASE;
            ELSE NULL; 
            END CASE;                                      
           dbms_output.put_Line ('despues de validar existe Valida que existe rel admin cama registro');
           pRegistro := FN_OBT_DATOS_RELADMINSERV (pConsulta, vPgn, vFuente);
     ELSE
--     CASE
--     WHEN NVL(pConsulta.PregIngresoId,0) > 0 THEN
--          pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Pre Ingreso Id: '||pConsulta.PregIngresoId||']';
--          RAISE eRegistroNoExiste;
--     WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
--           NVL(pConsulta.ExpedienteId,0) > 0)  THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [pPerNominalId: '||pConsulta.PerNominalId||'] - [pExpedienteId: '||pConsulta.ExpedienteId||']';
--           RAISE eRegistroNoExiste;
--     WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Nominal Id: '||pConsulta.PerNominalId||']';
--           RAISE eRegistroNoExiste;
--     WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Expediente Id: '||pConsulta.ExpedienteId||']';
--           RAISE eRegistroNoExiste;     
--     WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [codigo expediente: '||pConsulta.CodExpElectronico||']';
--           RAISE eRegistroNoExiste;
--     WHEN pConsulta.Identificacion IS NOT NULL THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas a la [Identificación: '||pConsulta.Identificacion||']';
--           RAISE eRegistroNoExiste;
--     WHEN (pConsulta.NombreCompleto IS NOT NULL AND
--           NVL (pConsulta.UsalIngresoId,0) > 0) THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Nombre: '||pConsulta.NombreCompleto||'] - [Unidad salud destino: '||pConsulta.UsalIngresoId||']';
--           RAISE eRegistroNoExiste;
--     WHEN pConsulta.NombreCompleto IS NOT NULL THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Nombre: '||pConsulta.NombreCompleto||']';
--           RAISE eRegistroNoExiste;
--     WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Unidad salud destino: '||pConsulta.UsalIngresoId||']';
--           RAISE eRegistroNoExiste;
--     ELSE 
           pResultado := 'No se encontraron registros';
           RAISE eRegistroNoExiste;
--     END CASE;     
     END CASE;
 EXCEPTION
 WHEN eSalidaConError THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;  
 WHEN eRegistroNoExiste THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al querer obtener información.'; -- [Id: '||pConsulta.PregIngresoId||'] - y [Id Expediente: '||pConsulta.ExpedienteId||']';
      pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_C_REL_ADMSRV_CAMAS;
 
 PROCEDURE PR_CRUD_REL_ADMSRV_CAMAS (pAdminServCamaId   IN OUT HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SRV_CAMA_ID%TYPE,
                                     pCfgUsalServCamaId IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                     pAdminServId       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.ADMISION_SERVICIO_ID%TYPE,
                                     pFechaInicio       IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE,
                                     pHoraInicio        IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE,  
                                     pFechaFin          IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.FECHA_INI%TYPE,
                                     pHoraFin           IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.HORA_INI%TYPE, 
                                     pIsLast            IN HOSPITALARIO.SNH_REL_ADMSRV_CAMAS.IS_LAST%TYPE,   
                                     pUsalud            IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,
                                     pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,  
                                     pAccionEstado      IN VARCHAR2,                                  
                                     pTipoAccion        IN VARCHAR2,                                  
                                     pPgn               IN NUMBER,
                                     pPgnAct            IN NUMBER default 1,  
                                     pPgnTmn            IN NUMBER default 100,
                                     pDatosPaginacion   OUT var_refcursor,
                                     pRegistro          OUT var_refcursor,                           
                                     pResultado         OUT VARCHAR2,                                
                                     pMsgError          OUT VARCHAR2) IS
 vFirma             MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_REL_ADMSRV_CAMAS => ';
 vResultado         MAXVARCHAR2;
 vEstadoRegistroId  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE; 
-- pPgn               NUMBER;
-- pPgnAct            NUMBER; 
-- pPgnTmn            NUMBER;
 ---pDatosPaginacion   var_refcursor;                            
 --pConsulta          HOSPITALARIO.OBJ_ADMSRV_CAMAS;
 BEGIN
      CASE
      WHEN pTipoAccion IS NULL THEN 
           pResultado := 'El párametro pTipoAccion no puede venir NULL';
           pMsgError  := pResultado;
           RAISE eParametroNull;
      ELSE NULL;
      END CASE;
      
      CASE
      WHEN pTipoAccion = kINSERT THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;
           dbms_output.put_line ('Sale de validar usuario');
            PR_I_REL_ADMSRV_CAMAS (pAdminServCamaId   => pAdminServCamaId, 
                                   pCfgUsalServCamaId => pCfgUsalServCamaId,
                                   pAdminServId       => pAdminServId,     
                                   pFechaInicio       => pFechaInicio,     
                                   pHoraInicio        => pHoraInicio,       
                                   pFechaFin          => pFechaFin,        
                                   pHoraFin           => pHoraFin,         
                                   pIsLast            => pIsLast,          
                                   pUsuario           => pUsuario,          
                                   pResultado         => pResultado,        
                                   pMsgError          => pMsgError);         
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            WHEN NVL(pAdminServCamaId,0) > 0 THEN  
                 PR_C_REL_ADMSRV_CAMAS (pConsulta          => HOSPITALARIO.OBJ_ADMSRV_CAMAS (pAdminServCamaId,           --  AdminServCamaId                   
                                                                                             pCfgUsalServCamaId,         --  CfgUsalServCamaId                 
                                                                                             pAdminServId,               --  AdminServId                       
                                                                                             pIsLast,                    --  IsLast                            
                                                                                             pUsalud,                    --  UnidadSaludId    
                                                                                             null,                       --  FecInicio        
                                                                                             null),                        --  FecFin           
                                        pPgn               => pPgn,            
                                        pPgnAct            => pPgnAct,         
                                        pPgnTmn            => pPgnTmn,         
                                        pDatosPaginacion   => pDatosPaginacion,
                                        pRegistro          => pRegistro,         
                                        pResultado         => pResultado,        
                                        pMsgError          => pMsgError);   
                 CASE
                 WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                     RAISE eSalidaConError;
                 ELSE 
                     vResultado := 'Se asigna exitosamente el registro de cama [Id]: '||pAdminServCamaId||', devolviendo el JSon de este';
                 END CASE;
            ELSE NULL;     
            END CASE; 
      WHEN pTipoAccion = kUPDATE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;      
                      
           CASE
           WHEN pAccionEstado = 0 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_ACTIVO;
           WHEN pAccionEstado = 1 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_PASIVO;
           ELSE NULL;
           END CASE;
           DBMS_OUTPUT.PUT_LINE ('1 - pAdminServCamaId: '||pAdminServCamaId);
           PR_U_REL_ADMSRV_CAMAS (pAdminServCamaId   => pAdminServCamaId, 
                                  pCfgUsalServCamaId => pCfgUsalServCamaId,
                                  pAdminServId       => pAdminServId,     
                                  pFechaInicio       => pFechaInicio,     
                                  pHoraInicio        => pHoraInicio,       
                                  pFechaFin          => pFechaFin,        
                                  pHoraFin           => pHoraFin,         
                                  pIsLast            => pIsLast,          
                                  pEstadoRegistroId  => vEstadoRegistroId, 
                                  pUsuario           => pUsuario,          
                                  pResultado         => pResultado,        
                                  pMsgError          => pMsgError);  
            DBMS_OUTPUT.PUT_LINE ('Sale de pro U admsrv camas. : '||pMsgError);                      
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            ELSE 
            DBMS_OUTPUT.PUT_LINE ('pAdminServCamaId: '||pAdminServCamaId);
               CASE
               WHEN NVL(pAdminServCamaId,0) > 0 THEN
               -- se realiza consulta de datos luego de realizar la actualización de persona
                    DBMS_OUTPUT.PUT_LINE ('Antes de entrar al get de update ');
                    PR_C_REL_ADMSRV_CAMAS (pConsulta          => HOSPITALARIO.OBJ_ADMSRV_CAMAS (pAdminServCamaId,           --  AdminServCamaId                   
                                                                                                pCfgUsalServCamaId,         --  CfgUsalServCamaId                 
                                                                                                pAdminServId,               --  AdminServId                       
                                                                                                pIsLast,                    --  IsLast                            
                                                                                                pUsalud,                    --  UnidadSaludId    
                                                                                                null,                       --  FecInicio        
                                                                                                null),                        --  FecFin         
                                           pPgn               => pPgn,            
                                           pPgnAct            => pPgnAct,         
                                           pPgnTmn            => pPgnTmn,         
                                           pDatosPaginacion   => pDatosPaginacion,
                                           pRegistro          => pRegistro,         
                                           pResultado         => pResultado,        
                                           pMsgError          => pMsgError); 
                     DBMS_OUTPUT.PUT_LINE ('Sale de pro C admsrv camas despues de U. : '||pMsgError);                                    
                    CASE
                    WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                         RAISE eSalidaConError;
                    ELSE vResultado := 'Se actualiza exitosamente el registro de asignación de camas [Id]: '||pAdminServCamaId||', devolviendo el JSon de este';
                    END CASE;          
               ELSE NULL;    
               END CASE;                 
            END CASE;           
      WHEN pTipoAccion = kCONSULTAR THEN
           PR_C_REL_ADMSRV_CAMAS (pConsulta          => HOSPITALARIO.OBJ_ADMSRV_CAMAS (pAdminServCamaId,           --  AdminServCamaId                   
                                                                                       pCfgUsalServCamaId,         --  CfgUsalServCamaId                 
                                                                                       pAdminServId,               --  AdminServId                       
                                                                                       pIsLast,                    --  IsLast                            
                                                                                       pUsalud,                    --  UnidadSaludId    
                                                                                       null,                       --  FecInicio        
                                                                                       null),                        --  FecFin         
                                  pPgn               => pPgn,            
                                  pPgnAct            => pPgnAct,         
                                  pPgnTmn            => pPgnTmn,         
                                  pDatosPaginacion   => pDatosPaginacion,
                                  pRegistro          => pRegistro,         
                                  pResultado         => pResultado,        
                                  pMsgError          => pMsgError);              
           CASE
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Consulta realizada con éxito';
      WHEN pTipoAccion = kDELETE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;     
           CASE
           WHEN NVL(pAdminServCamaId,0) > 0 THEN
           PR_U_REL_ADMSRV_CAMAS (pAdminServCamaId   => pAdminServCamaId, 
                                  pCfgUsalServCamaId => pCfgUsalServCamaId,
                                  pAdminServId       => pAdminServId,     
                                  pFechaInicio       => pFechaInicio,     
                                  pHoraInicio        => pHoraInicio,       
                                  pFechaFin          => pFechaFin,        
                                  pHoraFin           => pHoraFin,         
                                  pIsLast            => pIsLast,          
                                  pEstadoRegistroId  => vGLOBAL_ESTADO_ELIMINADO,  -- vEstadoRegistroId, 
                                  pUsuario           => pUsuario,          
                                  pResultado         => pResultado,        
                                  pMsgError          => pMsgError);            
           CASE 
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Registro eliminado con éxito';
           ELSE 
               pResultado := 'No hay registros para eliminar con el Id: '||pAdminServCamaId;
               pMsgError  := pResultado;
               RAISE eUpdateInvalido;    
           END CASE; 
      ELSE 
          pResultado := 'El Tipo acción no es un parámetro valido.';
          pMsgError  := pResultado;
          RAISE eParametrosInvalidos;
      END CASE;
      pResultado := vResultado;     
 EXCEPTION
    WHEN eUpdateInvalido THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;      
    WHEN eParametroNull THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroNoExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;                       
    WHEN eParametrosInvalidos THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pResultado;
    WHEN eSalidaConError THEN
         pResultado := pResultado;  --vResultado;
         pMsgError  := vFirma||pMsgError;  --vMsgError;
    WHEN OTHERS THEN
         pResultado := 'Error no controlado';
         pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_CRUD_REL_ADMSRV_CAMAS; 
 
 FUNCTION FN_OBT_CFG_CAMA_ID (pCamaId IN HOSPITALARIO.SNH_CAT_CAMAS.CAMA_ID%TYPE) RETURN NUMBER AS
 vIdCfgCama HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE;
 BEGIN
   SELECT CFG_USLD_SERVICIO_CAMA_ID
     INTO vIdCfgCama
     FROM SNH_CFG_USERVICIOS_CAMAS A
    WHERE CAMA_ID = pCamaId AND
          IS_LAST = 1 AND
          ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;
 RETURN vIdCfgCama;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vIdCfgCama; 
 END FN_OBT_CFG_CAMA_ID;
 
 FUNCTION FN_VALIDA_CAMAID_ESTA_ASIGNADA (pCamaId IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAMA_ID%TYPE) RETURN BOOLEAN AS
 vIdCfgCama HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE := FN_OBT_CFG_CAMA_ID (pCamaId);
 vContador SIMPLE_INTEGER := 0;
 vExiste BOOLEAN := FALSE;
 BEGIN
      CASE
      WHEN NVL(vIdCfgCama,0) > 0 THEN
           BEGIN
            SELECT COUNT (1)
              INTO vContador
            FROM HOSPITALARIO.SNH_REL_ADMSRV_CAMAS
            WHERE CFG_USLD_SERVICIO_CAMA_ID = vIdCfgCama AND
                  IS_LAST = 1 AND
                  FECHA_FIN IS NULL;             
           END;
      ELSE NULL;
      END CASE;
      CASE
      WHEN vContador > 0 THEN
           vExiste := TRUE;
      ELSE NULL;
      END CASE; 
  RETURN vExiste;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vExiste;
 END FN_VALIDA_CAMAID_ESTA_ASIGNADA;
 
 PROCEDURE PR_I_INDISP_CAMAS (pIndCamaId         OUT HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.INDISPONIBILIDAD_CAMA_ID%TYPE, 
                              pCfgUsalServCamaId IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                              pCamaId            IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAMA_ID%TYPE,                  
                              pCausaId           IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAUSA_ID%TYPE,                 
                              pDescSalida        IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_SALIDA%TYPE,  
                              pDescRetorno       IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_RETORNO%TYPE,      
                              pFecSalida         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_SALIDA%TYPE,             
                              pHrSalida          IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_SALIDA%TYPE,              
                              pFecRetorno        IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_RETORNO%TYPE,            
                              pHrRetorno         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_RETORNO%TYPE,             
                              pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE,      
                              pResultado         OUT VARCHAR2,   
                              pMsgError          OUT VARCHAR2) IS   
 vFirma VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_I_INDISP_CAMAS => ';
 BEGIN
      CASE
      WHEN FN_VALIDA_CAMAID_ESTA_ASIGNADA (pCamaId) = TRUE THEN
           pResultado := 'La cama que quiere poner como no disponible, aún está asignada a un paciente.';
           pMsgError  := pResultado;
           RAISE eRegistroExiste;
      ELSE NULL;
      END CASE;
      INSERT INTO HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS (CFG_USLD_SERVICIO_CAMA_ID,
                                                               CAMA_ID,                  
                                                               CAUSA_ID,                 
                                                               DESCRIPCION_SALIDA,       
                                                               DESCRIPCION_RETORNO,      
                                                               FECHA_SALIDA,             
                                                               HORA_SALIDA,              
                                                               FECHA_RETORNO,            
                                                               HORA_RETORNO,             
                                                               ESTADO_REGISTRO_ID,       
                                                               USUARIO_REGISTRO)     
                                                       VALUES (pCfgUsalServCamaId,
                                                               pCamaId,           
                                                               pCausaId,          
                                                               pDescSalida,       
                                                               pDescRetorno,      
                                                               pFecSalida,        
                                                               pHrSalida,         
                                                               pFecRetorno,       
                                                               pHrRetorno,
                                                               vGLOBAL_ESTADO_ACTIVO,        
                                                               pUsuario)
                                                               RETURNING INDISPONIBILIDAD_CAMA_ID INTO pIndCamaId  ; 
   pResultado := 'Registro Indisponible creado con éxito. [Id:'||pIndCamaId||']';  
   dbms_output.put_line ('pIndCamaId: '||pIndCamaId);      
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;
 WHEN eRegistroExiste THEN
      pResultado := pResultado;   
      pMsgError  := vFirma||pMsgError;     
 WHEN OTHERS THEN
      dbms_output.put_line ('when others: '||sqlerrm);
      pResultado := 'Error al crear el registro persona';
      pMsgError  :=  vFirma||pResultado||' - '||sqlerrm; 
 END PR_I_INDISP_CAMAS;  
 
 FUNCTION FN_OBT_CAMA_ID (pIndCamaId IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.INDISPONIBILIDAD_CAMA_ID%TYPE) RETURN NUMBER AS
 vCamaId HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAMA_ID%TYPE;
 BEGIN
   SELECT CAMA_ID
     INTO vCamaId
     FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS
    WHERE INDISPONIBILIDAD_CAMA_ID = pIndCamaId AND
          FECHA_RETORNO IS NULL AND
          ESTADO_REGISTRO_ID = vGLOBAL_ESTADO_ACTIVO;
            
 RETURN vCamaId;
 EXCEPTION
 WHEN OTHERS THEN 
      RETURN vCamaId;
 END FN_OBT_CAMA_ID;   
 
 PROCEDURE PR_U_INDISP_CAMAS (pIndCamaId         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.INDISPONIBILIDAD_CAMA_ID%TYPE, 
                              pCfgUsalServCamaId IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                              pCamaId            IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAMA_ID%TYPE,                  
                              pCausaId           IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAUSA_ID%TYPE,                 
                              pDescSalida        IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_SALIDA%TYPE,  
                              pDescRetorno       IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_RETORNO%TYPE,      
                              pFecSalida         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_SALIDA%TYPE,             
                              pHrSalida          IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_SALIDA%TYPE,              
                              pFecRetorno        IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_RETORNO%TYPE,            
                              pHrRetorno         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_RETORNO%TYPE,             
                              pEstadoRegistroId  IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.ESTADO_REGISTRO_ID%TYPE,
                              pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE, 
                              pResultado         OUT VARCHAR2,   
                              pMsgError          OUT VARCHAR2) IS   
 vFirma VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_U_INDISP_CAMAS => ';  
 vCamaId HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAMA_ID%TYPE;
 BEGIN
     CASE
     WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ELIMINADO THEN
         <<EliminaRegistro>>
          BEGIN
             UPDATE HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS
                SET ESTADO_REGISTRO_ID   = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,
                    USUARIO_ELIMINA      = pUsuario,
                    FECHA_ELIMINA        = CURRENT_TIMESTAMP
              WHERE INDISPONIBILIDAD_CAMA_ID = pIndCamaId;
          EXCEPTION
             WHEN OTHERS THEN
                  pResultado := 'Error no controlado al eliminar registro [pIndCamaId] - '||pIndCamaId;
                  pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                  RETURN;                
          END EliminaRegistro;
          pResultado := 'Se ha eliminado el registro. [Id:'||pIndCamaId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_PASIVO THEN
         <<PasivaRegistro>>       
         BEGIN
            UPDATE  HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS
                SET ESTADO_REGISTRO_ID   = pEstadoRegistroId,
                    USUARIO_MODIFICACION = pUsuario,  
                    USUARIO_PASIVA       = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                           ELSE USUARIO_PASIVA
                                           END,    
                    FECHA_PASIVA         = CASE
                                           WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                           WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                           ELSE FECHA_PASIVA
                                           END
             WHERE INDISPONIBILIDAD_CAMA_ID = pIndCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;     
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al pasivar registro [pIndCamaId] - '||pIndCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END PasivaRegistro;
         pResultado := 'Se ha pasivado el registro. [Id:'||pIndCamaId||']'; 
      WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN
          <<ActivarRegistro>>
         BEGIN
            CASE
            WHEN NVL(pCamaId,0) > 0 THEN
                 vCamaId := pCamaId;
            ELSE
                 vCamaId := FN_OBT_CAMA_ID (pIndCamaId);
            END CASE;
            CASE
            WHEN FN_VALIDA_CAMAID_ESTA_ASIGNADA (vCamaId) = TRUE THEN
                 pResultado := 'La cama que quiere poner como no disponible, aún está asignada a un paciente.';
                 pMsgError  := pResultado;
                 RAISE eRegistroExiste;
            ELSE NULL;
            END CASE;           
            UPDATE HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS
               SET ESTADO_REGISTRO_ID   = pEstadoRegistroId, 
                   USUARIO_MODIFICACION = pUsuario,    
                   USUARIO_PASIVA       = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN USUARIO_PASIVA IS NULL THEN pUsuario
                                          ELSE USUARIO_PASIVA
                                          END,    
                   FECHA_PASIVA         = CASE
                                          WHEN pEstadoRegistroId = vGLOBAL_ESTADO_ACTIVO THEN NULL
                                          WHEN FECHA_PASIVA IS NULL THEN CURRENT_TIMESTAMP
                                          ELSE FECHA_PASIVA
                                          END
             WHERE INDISPONIBILIDAD_CAMA_ID = pIndCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [pIndCamaId] - '||pIndCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActivarRegistro; 
         pResultado := 'Se ha activado el registro. [Id:'||pIndCamaId||']';                        
     ELSE 
         <<ActualizarRegistro>>
         BEGIN
            UPDATE HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS  
               SET CFG_USLD_SERVICIO_CAMA_ID = NVL(pCfgUsalServCamaId, CFG_USLD_SERVICIO_CAMA_ID), 
                   CAMA_ID                   = NVL(pCamaId, CAMA_ID),                              
                   CAUSA_ID                  = NVL(pCausaId, CAUSA_ID),                          
                   DESCRIPCION_SALIDA        = NVL(pDescSalida, DESCRIPCION_SALIDA),              
                   DESCRIPCION_RETORNO       = NVL(pDescRetorno, DESCRIPCION_RETORNO),            
                   FECHA_SALIDA              = NVL(pFecSalida, FECHA_SALIDA),                     
                   HORA_SALIDA               = NVL(pHrSalida, HORA_SALIDA),                       
                   FECHA_RETORNO             = NVL(pFecRetorno, FECHA_RETORNO),                   
                   HORA_RETORNO              = NVL(pHrRetorno, HORA_RETORNO),                     
                   USUARIO_MODIFICACION  = pUsuario          
             WHERE INDISPONIBILIDAD_CAMA_ID = pIndCamaId AND
                   ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;  
         EXCEPTION
            WHEN OTHERS THEN
                 pResultado := 'Error no controlado al activar registro [pIndCamaId] - '||pIndCamaId;
                 pMsgError  := vFirma||pResultado||' - '||sqlerrm;
                 RETURN;  
         END ActualizarRegistro; 
         pResultado := 'Se ha actualizado el registro. [Id:'||pIndCamaId||']';                              
     END CASE;
 EXCEPTION
 WHEN eRegistroExiste THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pMsgError;
 END PR_U_INDISP_CAMAS;  
 
 FUNCTION FN_VAL_EXISTE_INDISP_CAMAS (pConsulta      IN HOSPITALARIO.OBJ_INDISPONIBILIDAD_CAMAS,
                                      pPgn           IN BOOLEAN, 
                                      pCantRegistros OUT NUMBER, 
                                      pFuente        OUT NUMBER) RETURN BOOLEAN AS
 vRetorna BOOLEAN := FALSE;
 vContador SIMPLE_INTEGER := 0;                                     
 BEGIN
   CASE
   WHEN NVL(pConsulta.IndCamaId, 0) > 0 THEN
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS
         WHERE INDISPONIBILIDAD_CAMA_ID = pConsulta.IndCamaId AND
               ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;
        pFuente := 1;
        END; 
   WHEN (NVL(pConsulta.CfgUsalServCamaId, 0) > 0 AND
         NVL(pConsulta.UnidSsaludId, 0) > 0) THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
          JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
            ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
               CFGCAMAS.CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
               CFGCAMAS.IS_LAST = 1 
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
            ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
               REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;        
        pFuente := 2;
        END;    
   WHEN (NVL(pConsulta.CamaId, 0) > 0 AND
         NVL(pConsulta.UnidSsaludId, 0) > 0) THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
          JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
            ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
               CFGCAMAS.IS_LAST = 1
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
            ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
               REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
         WHERE A.CAMA_ID = pConsulta.CamaId AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;         
        pFuente := 3;
        END; 
   WHEN (NVL(pConsulta.CausaId, 0) > 0 AND
         NVL(pConsulta.UnidSsaludId, 0) > 0) THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
          JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
            ON CFGCAMAS.CAMA_ID = A.CAMA_ID
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
            ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
               REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
         WHERE A.CAUSA_ID = pConsulta.CausaId AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;          
        pFuente := 4;
        END;   
   WHEN ((pConsulta.FecSalidaInicio IS NOT NULL AND pConsulta.FecSalidaFin IS NOT NULL) AND
         NVL(pConsulta.UnidSsaludId, 0) > 0) THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
          JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
            ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
               CFGCAMAS.IS_LAST = 1
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
            ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
               REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
         WHERE (TRUNC(A.FECHA_SALIDA) BETWEEN pConsulta.FecSalidaInicio AND pConsulta.FecSalidaFin) AND 
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;         
        pFuente := 5;
        END;                         
   WHEN NVL(pConsulta.CfgUsalServCamaId, 0) > 0 THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
          JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
            ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
               CFGCAMAS.CFG_USLD_SERVICIO_CAMA_ID = pConsulta.CfgUsalServCamaId AND
               CFGCAMAS.IS_LAST = 1
         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;        
        pFuente := 6;
        END;    
   WHEN NVL(pConsulta.CamaId, 0) > 0 THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
         WHERE A.CAMA_ID = pConsulta.CamaId AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;         
        pFuente := 7;
        END;  
   WHEN NVL(pConsulta.CausaId, 0) > 0 THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
         WHERE A.CAUSA_ID = pConsulta.CausaId AND
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;         
        pFuente := 8;
        END;     
   WHEN (pConsulta.FecSalidaInicio IS NOT NULL AND pConsulta.FecSalidaFin IS NOT NULL) THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
         WHERE (TRUNC(A.FECHA_SALIDA) BETWEEN pConsulta.FecSalidaInicio AND pConsulta.FecSalidaFin) AND 
               A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;         
        pFuente := 9;
        END;
   WHEN NVL(pConsulta.UnidSsaludId, 0) > 0 THEN   
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
          JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS
            ON CFGCAMAS.CAMA_ID = A.CAMA_ID AND
               CFGCAMAS.IS_LAST = 1
          JOIN HOSPITALARIO.SNH_REL_UND_SALUD_SERVICIOS REL
            ON REL.UND_SALUD_SERVICIO_ID = CFGCAMAS.UND_SALUD_SERVICIO_ID AND
               REL.UNIDAD_SALUD_ID = pConsulta.UnidSsaludId
         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;          
        pFuente := 10;
        END;   
   ELSE 
        BEGIN
        SELECT COUNT (1)
          INTO vContador
          FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS A
         WHERE A.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO;         
        pFuente := 11;
        END;
   END CASE;
   CASE
   WHEN vContador > 0 THEN
        vRetorna := TRUE;
   ELSE NULL;
   END CASE;
   pCantRegistros := vContador;
   RETURN vRetorna;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vRetorna;
 END FN_VAL_EXISTE_INDISP_CAMAS; 
 
 FUNCTION FN_OBT_INDISP_CAMAS_PAG RETURN var_refcursor AS
 vRegistros var_refcursor;
 BEGIN
      OPEN vRegistros FOR
              SELECT *
--                 INDISPONIBILIDAD_CAMA_ID,
--                 CAMA_ID    
               FROM (
                    SELECT *
                     FROM HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP A,(
                          SELECT ROW_NUMBER () OVER (ORDER BY INDISPONIBILIDAD_CAMA_ID ASC)
                                 LINE_NUMBER,
                                 INDISPONIBILIDAD_CAMA_ID, 
                                 CAMA_ID,    
                                 CAT_CAMA_NOMBRE, 
                                 CATCAMA_COD_ADMINISTRATIVO,
                                 CAT_NO_SERIE,           
                                 CAT_ESTADO_CAMA,
                                 CAT_ESTADO_REGISTRO_ID,   
                                 CAT_CATESTREG_CODIGO,
                                 CAT_CATESTREG_VALOR,
                                 CAT_CATESTREG_DESCRIPCION,
                                 CAT_USUARIO_REGISTRO,    
                                 CAT_FECHA_REGISTRO,
                                 CFG_USLD_SERVICIO_CAMA_ID,
                                 CFG_USLDSERV_ID,
                                 CFG_USLDSERV_COD_ASISTENCIAL,
                                 CFG_USLDSERV_SALDA_ID,
                                 CFG_USLDSERV_HABITACION_ID,
                                 CFG_USLDSERV_DISPONIBLE,
                                 CFG_USLDSERV_ESTADO_CAMA_ID,
                                 CFG_CATESTCAMA_CAMA,
                                 CFG_CATESTCAMA_VALOR,
                                 CFG_CATESTCAMA_DESCRIPCION,
                                 CFG_USLDSERV_ESTADO_REGISTRO,
                                 CFG_CATESTREGCFG_CODIGO,
                                 CFG_CATESTREGCFG_VALOR,
                                 CFG_CATESTREGCFG_DESCRIPCION,
                                 IND_CAUSA_ISA,
                                 CAUSAIND_CODIGO,
                                 CAUSAIND_VALOR,
                                 CAUSAIND_DESCRIPCION,
                                 DESCRIPCION_SALIDA,
                                 DESCRIPCION_RETORNO,
                                 FECHA_SALIDA,
                                 HORA_SALIDA,
                                 FECHA_RETORNO,
                                 HORA_RETORNO,
                                 ESTADO_REGISTRO_ID,
                                 CATESTREGIND_CODIGO,
                                 CATESTREGIND_VALOR,
                                 CATESTREGIND_DESCRIPCION,
                                 USR_REGISTRO,     
                                 FEC_REGISTRO,     
                                 USR_MODIFICACION, 
                                 FEC_MODIFICACION,
                                 USR_PASIVA,  
                                 FEC_PASIVA,      
                                 USR_ELIMINA,      
                                 FEC_ELIMINA     
                            FROM 
                            (
                               SELECT IND.INDISPONIBILIDAD_CAMA_ID            INDISPONIBILIDAD_CAMA_ID,  
                                      IND.CAMA_ID                             CAMA_ID,     
                                      CAT.NOMBRE                              CAT_CAMA_NOMBRE,  
                                      CAT.CODIGO_ADMINISTRATIVO               CATCAMA_COD_ADMINISTRATIVO, 
                                      CAT.NO_SERIE                            CAT_NO_SERIE,            
                                      CAT.ESTADO_CAMA                         CAT_ESTADO_CAMA, 
                                      CAT.ESTADO_REGISTRO_ID                  CAT_ESTADO_REGISTRO_ID,    
                                      CATESTREG.CODIGO                        CAT_CATESTREG_CODIGO, 
                                      CATESTREG.VALOR                         CAT_CATESTREG_VALOR, 
                                      CATESTREG.DESCRIPCION                   CAT_CATESTREG_DESCRIPCION, 
                                      CAT.USUARIO_REGISTRO                    CAT_USUARIO_REGISTRO,     
                                      CAT.FECHA_REGISTRO                      CAT_FECHA_REGISTRO, 
                                      CFGCAMAS.CFG_USLD_SERVICIO_CAMA_ID      CFG_USLD_SERVICIO_CAMA_ID, 
                                      CFGCAMAS.UND_SALUD_SERVICIO_ID          CFG_USLDSERV_ID, 
                                      CFGCAMAS.CODIGO_ASISTENCIAL             CFG_USLDSERV_COD_ASISTENCIAL, 
                                      CFGCAMAS.SALA_ID                        CFG_USLDSERV_SALDA_ID, 
                                      CFGCAMAS.HABITACION_ID                  CFG_USLDSERV_HABITACION_ID, 
                                      CFGCAMAS.DISPONIBLE                     CFG_USLDSERV_DISPONIBLE, 
                                      CFGCAMAS.ESTADO_CAMA_ID                 CFG_USLDSERV_ESTADO_CAMA_ID, 
                                      CATESTCAMA.CODIGO                       CFG_CATESTCAMA_CAMA, 
                                      CATESTCAMA.VALOR                        CFG_CATESTCAMA_VALOR, 
                                      CATESTCAMA.DESCRIPCION                  CFG_CATESTCAMA_DESCRIPCION, 
                                      CFGCAMAS.ESTADO_REGISTRO_ID             CFG_USLDSERV_ESTADO_REGISTRO, 
                                      CATESTREGCFG.CODIGO                     CFG_CATESTREGCFG_CODIGO, 
                                      CATESTREGCFG.VALOR                      CFG_CATESTREGCFG_VALOR, 
                                      CATESTREGCFG.DESCRIPCION                CFG_CATESTREGCFG_DESCRIPCION, 
                                      IND.CAUSA_ID                            IND_CAUSA_ISA, 
                                      CATCAUSAIND.CODIGO                      CAUSAIND_CODIGO, 
                                      CATCAUSAIND.VALOR                       CAUSAIND_VALOR, 
                                      CATCAUSAIND.DESCRIPCION                 CAUSAIND_DESCRIPCION, 
                                      IND.DESCRIPCION_SALIDA                  DESCRIPCION_SALIDA, 
                                      IND.DESCRIPCION_RETORNO                 DESCRIPCION_RETORNO, 
                                      IND.FECHA_SALIDA                        FECHA_SALIDA, 
                                      IND.HORA_SALIDA                         HORA_SALIDA, 
                                      IND.FECHA_RETORNO                       FECHA_RETORNO, 
                                      IND.HORA_RETORNO                        HORA_RETORNO, 
                                      IND.ESTADO_REGISTRO_ID                  ESTADO_REGISTRO_ID, 
                                      CATESTREGIND.CODIGO                     CATESTREGIND_CODIGO, 
                                      CATESTREGIND.VALOR                      CATESTREGIND_VALOR, 
                                      CATESTREGIND.DESCRIPCION                CATESTREGIND_DESCRIPCION, 
                                      IND.USUARIO_REGISTRO                    USR_REGISTRO,     
                                      IND.FECHA_REGISTRO                      FEC_REGISTRO,     
                                      IND.USUARIO_MODIFICACION                USR_MODIFICACION, 
                                      IND.FECHA_MODIFICACION                  FEC_MODIFICACION,
                                      IND.USUARIO_PASIVA                      USR_PASIVA,  
                                      IND.FECHA_PASIVA                        FEC_PASIVA,      
                                      IND.USUARIO_ELIMINA                     USR_ELIMINA,      
                                      IND.FECHA_ELIMINA                       FEC_ELIMINA     
                                 FROM HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS IND 
                                 JOIN HOSPITALARIO.SNH_CAT_CAMAS CAT 
                                   ON CAT.CAMA_ID = IND.CAMA_ID 
                                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREG 
                                   ON CATESTREG.CATALOGO_ID = CAT.ESTADO_REGISTRO_ID 
                                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATCAUSAIND 
                                   ON CATCAUSAIND.CATALOGO_ID = IND.CAUSA_ID  
                                 JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGIND 
                                   ON CATESTREGIND.CATALOGO_ID = IND.ESTADO_REGISTRO_ID    
                            LEFT JOIN HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS CFGCAMAS 
                                   ON CFGCAMAS.CAMA_ID = CAT.CAMA_ID 
                            LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTCAMA 
                                   ON CATESTCAMA.CATALOGO_ID = CFGCAMAS.ESTADO_CAMA_ID  
                            LEFT JOIN CATALOGOS.SBC_CAT_CATALOGOS CATESTREGCFG 
                                   ON CATESTREGCFG.CATALOGO_ID = CFGCAMAS.ESTADO_REGISTRO_ID 
                              WHERE IND.ESTADO_REGISTRO_ID != vGLOBAL_ESTADO_ELIMINADO       
                                                                  )
                                         )B
                        WHERE  A.ID = B.INDISPONIBILIDAD_CAMA_ID 
                      ORDER BY LINE_NUMBER);  
     RETURN vRegistros;                            
 END FN_OBT_INDISP_CAMAS_PAG;
 
 FUNCTION FN_OBT_DATOS_INDISP_CAMAS(pConsulta IN HOSPITALARIO.OBJ_INDISPONIBILIDAD_CAMAS, 
                                    pPgn      IN BOOLEAN,  
                                    pFuente   IN NUMBER) RETURN var_refcursor AS
 vRegistro var_refcursor;
 BEGIN
   vRegistro := FN_OBT_INDISP_CAMAS_PAG;   
   return vRegistro;
 END FN_OBT_DATOS_INDISP_CAMAS; 
 PROCEDURE PR_C_INDISP_CAMAS (pConsulta        IN HOSPITALARIO.OBJ_INDISPONIBILIDAD_CAMAS,
                              pPgn             IN NUMBER,
                              pPgnAct          IN NUMBER default 1, 
                              pPgnTmn          IN NUMBER default 100,
                              pDatosPaginacion OUT var_refcursor,
                              pRegistro        OUT var_refcursor,    
                              pResultado       OUT VARCHAR2,         
                              pMsgError        OUT VARCHAR2) IS
           
 vFirma             VARCHAR2(100) := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_C_INDISP_CAMAS => ';  
 vFuente            SIMPLE_INTEGER := 0;
 vPgn             BOOLEAN := TRUE;
 vFechaInicio     DATE;
 vFechaFin        DATE;
 vNombreCompleto  MAXVARCHAR2;
 vPrimerNombre    MAXVARCHAR2;
 vSegundoNombre   MAXVARCHAR2;
 vPrimerApellido  MAXVARCHAR2;
 vSegundoApellido MAXVARCHAR2;
 vSexo            MAXVARCHAR2;
 vUnidadSaludId   NUMBER;
 vMunicipioId     NUMBER;
 vEntAdminId      NUMBER;
 vCantRegistros   SIMPLE_INTEGER := 0;
 vPaginacion HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos;  
 BEGIN
     CASE
     WHEN (FN_VAL_EXISTE_INDISP_CAMAS (pConsulta, vPgn, 
                                       vCantRegistros, vFuente)) = TRUE THEN 
            DBMS_OUTPUT.PUT_LINE ('Valida que existe camas no disponibles');                          
            CASE
            WHEN vPgn THEN
                        DBMS_OUTPUT.PUT_LINE ('Entra a paginación'); 
                 HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_INDC_PAGINACION_PERSONA(PREGISTROS  => vCantRegistros, 
                                                                            pPgnAct     => pPgnAct, 
                                                                            pPgnTmn     => pPgnTmn, 
                                                                            pPaginacion => vPaginacion, 
                                                                            pMsg        => pMsgError);
                    DBMS_OUTPUT.PUT_LINE ('sale de paginación: '||pMsgError);                                                          
                 CASE 
                 WHEN pMsgError IS NOT NULL THEN 
                      pResultado := pMsgError;
                      pMsgError  := pMsgError;
                      RAISE eSalidaConError;
                 ELSE 
                      pDatosPaginacion := FN_OBT_DATOS_PAGINACION (pDatosPaginacion =>  vPaginacion); --pQuery =>  vQuery);
                 END CASE;            
                 PR_I_TABLA_TEMP_INDISP_CAMAS (pConsulta        => pConsulta,
                                               pPgnAct          => pPgnAct,        
                                               pPgnTmn          => pPgnTmn,       
                                               pTipoPaginacion  => vFuente,
                                               pResultado       => pResultado,     
                                               pMsgError        => pMsgError); 
                                 dbms_output.put_line ('Error saliendo de I tabla temporal INDISP_CAMAS: '||pMsgError);              
                                 CASE
                                 WHEN pMsgError IS NOT NULL THEN 
                                      RAISE eSalidaConError;
                                 ELSE NULL;
                                 END CASE;
            ELSE NULL; 
            END CASE;                                      
           dbms_output.put_Line ('despues de validar existe camas no disponibles y paginación');
           pRegistro := FN_OBT_DATOS_INDISP_CAMAS(pConsulta, vPgn, vFuente);
     ELSE
--     CASE
--     WHEN NVL(pConsulta.PregIngresoId,0) > 0 THEN
--          pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Pre Ingreso Id: '||pConsulta.PregIngresoId||']';
--          RAISE eRegistroNoExiste;
--     WHEN (NVL(pConsulta.PerNominalId,0) > 0 AND
--           NVL(pConsulta.ExpedienteId,0) > 0)  THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [pPerNominalId: '||pConsulta.PerNominalId||'] - [pExpedienteId: '||pConsulta.ExpedienteId||']';
--           RAISE eRegistroNoExiste;
--     WHEN NVL(pConsulta.PerNominalId,0) > 0 THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Nominal Id: '||pConsulta.PerNominalId||']';
--           RAISE eRegistroNoExiste;
--     WHEN NVL(pConsulta.ExpedienteId,0) > 0 THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [Expediente Id: '||pConsulta.ExpedienteId||']';
--           RAISE eRegistroNoExiste;     
--     WHEN pConsulta.CodExpElectronico IS NOT NULL THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas al [codigo expediente: '||pConsulta.CodExpElectronico||']';
--           RAISE eRegistroNoExiste;
--     WHEN pConsulta.Identificacion IS NOT NULL THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas a la [Identificación: '||pConsulta.Identificacion||']';
--           RAISE eRegistroNoExiste;
--     WHEN (pConsulta.NombreCompleto IS NOT NULL AND
--           NVL (pConsulta.UsalIngresoId,0) > 0) THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Nombre: '||pConsulta.NombreCompleto||'] - [Unidad salud destino: '||pConsulta.UsalIngresoId||']';
--           RAISE eRegistroNoExiste;
--     WHEN pConsulta.NombreCompleto IS NOT NULL THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Nombre: '||pConsulta.NombreCompleto||']';
--           RAISE eRegistroNoExiste;
--     WHEN NVL (pConsulta.UsalIngresoId,0) > 0 THEN
--           pResultado := 'No se encontraron registros de pre ingresos relacionadas a [Unidad salud destino: '||pConsulta.UsalIngresoId||']';
--           RAISE eRegistroNoExiste;
--     ELSE 
           pResultado := 'No se encontraron registros con los parámetros enviados';
           RAISE eRegistroNoExiste;
--     END CASE;     
     END CASE;
 EXCEPTION
 WHEN eSalidaConError THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;  
 WHEN eRegistroNoExiste THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pResultado;
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al querer obtener información de camas no disponibles.'; -- [Id: '||pConsulta.PregIngresoId||'] - y [Id Expediente: '||pConsulta.ExpedienteId||']';
      pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_C_INDISP_CAMAS;
 
 PROCEDURE PR_CRUD_INDISP_CAMAS (pIndCamaId         IN OUT HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.INDISPONIBILIDAD_CAMA_ID%TYPE, 
                                 pCfgUsalServCamaId IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CFG_USLD_SERVICIO_CAMA_ID%TYPE,
                                 pCamaId            IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAMA_ID%TYPE,                  
                                 pCausaId           IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.CAUSA_ID%TYPE,                 
                                 pUnidSsaludId      IN CATALOGOS.SBC_CAT_UNIDADES_SALUD.UNIDAD_SALUD_ID%TYPE,
                                 pDescSalida        IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_SALIDA%TYPE,       
                                 pDescRetorno       IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.DESCRIPCION_RETORNO%TYPE,      
                                 pFecSalida         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_SALIDA%TYPE,             
                                 pHrSalida          IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_SALIDA%TYPE,              
                                 pFecRetorno        IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.FECHA_RETORNO%TYPE,            
                                 pHrRetorno         IN HOSPITALARIO.SNH_MST_INDISPONIBILIDAD_CAMAS.HORA_RETORNO%TYPE,             
                                 pUsuario           IN SEGURIDAD.SCS_MST_USUARIOS.USERNAME%TYPE, 
                                 pAccionEstado      IN VARCHAR2, 
                                 pFecInicio         IN DATE,
                                 pFecFin            IN DATE,                                 
                                 pTipoAccion        IN VARCHAR2,                                  
                                 pPgn               IN NUMBER,
                                 pPgnAct            IN NUMBER default 1, 
                                 pPgnTmn            IN NUMBER default 100,
                                 pDatosPaginacion   OUT var_refcursor,
                                 pRegistro          OUT var_refcursor,                           
                                 pResultado         OUT VARCHAR2,                                
                                 pMsgError          OUT VARCHAR2) IS
 vFirma             MAXVARCHAR2 := 'HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.PR_CRUD_CAT_CAMAS => ';
 vResultado         MAXVARCHAR2;
 vEstadoRegistroId  CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;                             
 BEGIN
      CASE
      WHEN pTipoAccion IS NULL THEN 
           pResultado := 'El párametro pTipoAccion no puede venir NULL';
           pMsgError  := pResultado;
           RAISE eParametroNull;
      ELSE NULL;
      END CASE;
      
      CASE
      WHEN pTipoAccion = kINSERT THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;
           dbms_output.put_line ('Sale de validar usuario');

            PR_I_INDISP_CAMAS (pIndCamaId         => pIndCamaId,        
                               pCfgUsalServCamaId => pCfgUsalServCamaId,
                               pCamaId            => pCamaId,           
                               pCausaId           => pCausaId,          
                               pDescSalida        => pDescSalida,       
                               pDescRetorno       => pDescRetorno,      
                               pFecSalida         => pFecSalida,        
                               pHrSalida          => pHrSalida,         
                               pFecRetorno        => pFecRetorno,       
                               pHrRetorno         => pHrRetorno,        
                               pUsuario           => pUsuario,     
                               pResultado         => pResultado,   
                               pMsgError          => pMsgError);    
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            WHEN NVL(pIndCamaId,0) > 0 THEN  
                 PR_C_INDISP_CAMAS (pConsulta        => HOSPITALARIO.OBJ_INDISPONIBILIDAD_CAMAS(pIndCamaId,        
                                                                                                pCfgUsalServCamaId,
                                                                                                pCamaId,           
                                                                                                pCausaId,          
                                                                                                pUnidSsaludId,     
                                                                                                pFecInicio,        
                                                                                                pFecFin   
                                                                                                ),
                                    pPgn             => pPgn,            
                                    --pPgnAct          => pPgnAct,         
                                    --pPgnTmn          => pPgnTmn,         
                                    pDatosPaginacion => pDatosPaginacion,
                                    pRegistro        => pRegistro,  
                                    pResultado       => pResultado, 
                                    pMsgError        => pMsgError);  
                 CASE
                 WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                     RAISE eSalidaConError;
                 ELSE 
                     vResultado := 'Se crea exitosamente el registro de cama no disponible [Id]: '||pIndCamaId||', devolviendo el JSon de este';
                 END CASE;
            ELSE NULL;     
            END CASE; 
      WHEN pTipoAccion = kUPDATE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;      
                      
           CASE
           WHEN pAccionEstado = 0 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_ACTIVO;
           WHEN pAccionEstado = 1 THEN
                vEstadoRegistroId := vGLOBAL_ESTADO_PASIVO;
           ELSE NULL;
           END CASE;
           PR_U_INDISP_CAMAS (pIndCamaId         => pIndCamaId,        
                              pCfgUsalServCamaId => pCfgUsalServCamaId,
                              pCamaId            => pCamaId,           
                              pCausaId           => pCausaId,          
                              pDescSalida        => pDescSalida,       
                              pDescRetorno       => pDescRetorno,      
                              pFecSalida         => pFecSalida,        
                              pHrSalida          => pHrSalida,         
                              pFecRetorno        => pFecRetorno,       
                              pHrRetorno         => pHrRetorno,        
                              pEstadoRegistroId  => vEstadoRegistroId,
                              pUsuario           => pUsuario,         
                              pResultado         => pResultado,       
                              pMsgError          => pMsgError);        
            CASE
            WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                 RAISE eSalidaConError;
            ELSE 
               CASE
               WHEN NVL(pIndCamaId,0) > 0 THEN
               -- se realiza consulta de datos luego de realizar la actualización de persona
                    PR_C_INDISP_CAMAS (pConsulta        => HOSPITALARIO.OBJ_INDISPONIBILIDAD_CAMAS(pIndCamaId,        
                                                                                                  pCfgUsalServCamaId,
                                                                                                  pCamaId,           
                                                                                                  pCausaId,          
                                                                                                  pUnidSsaludId,     
                                                                                                  pFecInicio,        
                                                                                                  pFecFin   
                                                                                                  ),   
                                       pPgn             => pPgn,            
                                      -- pPgnAct          => pPgnAct,         
                                      -- pPgnTmn          => pPgnTmn,         
                                       pDatosPaginacion => pDatosPaginacion,
                                       pRegistro        => pRegistro,  
                                       pResultado       => pResultado, 
                                       pMsgError        => pMsgError);           
                   CASE
                   WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                        RAISE eSalidaConError;
                   ELSE vResultado := 'Se actualiza exitosamente el registro de cama no disponible [Id]: '||pIndCamaId||', devolviendo el JSon de este';
                   END CASE;          
               ELSE NULL;    
               END CASE;                 
            END CASE;           
      WHEN pTipoAccion = kCONSULTAR THEN
           PR_C_INDISP_CAMAS (pConsulta        => HOSPITALARIO.OBJ_INDISPONIBILIDAD_CAMAS(pIndCamaId,        
                                                                                          pCfgUsalServCamaId,
                                                                                          pCamaId,           
                                                                                          pCausaId,          
                                                                                          pUnidSsaludId,     
                                                                                          pFecInicio,        
                                                                                          pFecFin         
                                                                                          ),      
                              pPgn             => pPgn,            
                              pPgnAct          => pPgnAct,         
                              pPgnTmn          => pPgnTmn,         
                              pDatosPaginacion => pDatosPaginacion,
                              pRegistro        => pRegistro,  
                              pResultado       => pResultado, 
                              pMsgError        => pMsgError);               
           CASE
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Consulta realizada con éxito';
      WHEN pTipoAccion = kDELETE THEN
           CASE
           WHEN pUsuario IS NULL THEN
                pResultado := 'El usuario no puede venir nulo.';
                pMsgError  := pResultado;
                RAISE eParametroNull;
           ELSE 
                CASE -- validamos que el usuario se valido, con mst_usuarios
                WHEN (PKG_SNH_UTILITARIOS.FN_VALIDAR_USUARIO (pUsuario)) = FALSE THEN
                      pResultado := 'Usuario no valido';
                      pMsgError  := pResultado;
                      RAISE eRegistroNoExiste;
                ELSE NULL;
                END CASE;
           END CASE;     
           CASE
           WHEN NVL(pIndCamaId,0) > 0 THEN
                PR_U_INDISP_CAMAS (pIndCamaId         => pIndCamaId,        
                                   pCfgUsalServCamaId => pCfgUsalServCamaId,
                                   pCamaId            => pCamaId,           
                                   pCausaId           => pCausaId,          
                                   pDescSalida        => pDescSalida,       
                                   pDescRetorno       => pDescRetorno,      
                                   pFecSalida         => pFecSalida,        
                                   pHrSalida          => pHrSalida,         
                                   pFecRetorno        => pFecRetorno,       
                                   pHrRetorno         => pHrRetorno,        
                                   pEstadoRegistroId  => vGLOBAL_ESTADO_ELIMINADO,  -- vEstadoRegistroId,
                                   pUsuario           => pUsuario,         
                                   pResultado         => pResultado,       
                                   pMsgError          => pMsgError);          
           CASE 
           WHEN pMsgError IS NOT NULL AND LENGTH (TRIM (pMsgError)) > 0 THEN
                RAISE eSalidaConError;
           ELSE NULL;
           END CASE;
           vResultado := 'Registro eliminado con éxito';
           ELSE 
               pResultado := 'No hay registros para eliminar con el Id: '||pIndCamaId;
               pMsgError  := pResultado;
               RAISE eUpdateInvalido;    
           END CASE; 
      ELSE 
          pResultado := 'El Tipo acción no es un parámetro valido.';
          pMsgError  := pResultado;
          RAISE eParametrosInvalidos;
      END CASE;
      pResultado := vResultado;     
 EXCEPTION
    WHEN eUpdateInvalido THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;      
    WHEN eParametroNull THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroNoExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;
    WHEN eRegistroExiste THEN
         pResultado := pResultado;  
         pMsgError  := vFirma||pMsgError;                       
    WHEN eParametrosInvalidos THEN
         pResultado := pResultado;
         pMsgError  := vFirma||pResultado;
    WHEN eSalidaConError THEN
         pResultado := pResultado;  --vResultado;
         pMsgError  := vFirma||pMsgError;  --vMsgError;
    WHEN OTHERS THEN
         pResultado := 'Error no controlado';
         pMsgError  := vFirma||pResultado||' - '||SQLERRM;
 END PR_CRUD_INDISP_CAMAS; 
 END PKG_SNH_INGRESO_EGRESO;
/