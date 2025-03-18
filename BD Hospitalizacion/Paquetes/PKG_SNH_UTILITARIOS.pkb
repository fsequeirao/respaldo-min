CREATE OR REPLACE PACKAGE BODY HOSPITALARIO.PKG_SNH_UTILITARIOS
AS
   PROCEDURE PR_VAL_CEDULA_NICARAGUENSE (
      p_NumeroIdentificacion       VARCHAR2,
      p_MunicipioNacimiento        VARCHAR2 DEFAULT NULL,
      p_FechaNacimiento            TIMESTAMP DEFAULT NULL,
      p_Msg                    OUT VARCHAR2)
   IS
      vMunicipioReg      VARCHAR2 (3);
      vFechaNacimiento   TIMESTAMP;
      vPosicionLetra     NUMBER;
      vLetras            VARCHAR2 (23) := 'ABCDEFGHJKLMNPQRSTUVWXY';
   BEGIN
      IF REGEXP_LIKE (
            p_NumeroIdentificacion,
            '^([0-6][0-9]{2}|[7]{3}|[8]{3})([0-2][0-9]|3[0-1])(0[0-9]|1[0-2])[0-9]{2}[0-9]{4}([A-Z]|[a-z])$')
      THEN
        <<nValidadorFechaNac>>
         BEGIN
            vFechaNacimiento :=
               TO_TIMESTAMP (SUBSTR (p_NumeroIdentificacion, 4, 6), 'ddmmyy');
         --DBMS_OUTPUT.PUT_LINE('Fecha de Nacimiento de la Cédula: ' || vFechaNacimiento);
         EXCEPTION
            WHEN OTHERS
            THEN
               CATALOGOS.PKG_PR.PR_GENERAR_ERROR (
                  'Número de Cédula, inválida 1');
         END nValidadorFechaNac;

        <<nValidadorMunicipio>>
         BEGIN
            IF    SUBSTR (p_NumeroIdentificacion, 0, 3) = '888'
               OR SUBSTR (p_NumeroIdentificacion, 0, 3) = '777'
            THEN
               NULL;
            ELSE
               --DBMS_OUTPUT.PUT_LINE('[MUNICIPIO] Código CSE '||SUBSTR(p_NumeroIdentificacion,0,3));
               SELECT CODIGO_CSE_REG
                 INTO vMunicipioReg
                 FROM CATALOGOS.SBC_CAT_MUNICIPIOS
                WHERE LPAD (CODIGO_CSE_REG, 3, '0') =
                         SUBSTR (p_NumeroIdentificacion, 0, 3);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               CATALOGOS.PKG_PR.PR_GENERAR_ERROR (
                  'Número de Cédula, inválida 2');
         END nValidadorMunicipio;

        <<nValidaUltimoCaracter>>
           BEGIN
                 -- DBMS_OUTPUT.PUT_LINE('FLOOR>> '|| FLOOR (SUBSTR (p_NumeroIdentificacion, 1, 13) / 26));
            BEGIN
            vPosicionLetra := 
                 (  SUBSTR (p_NumeroIdentificacion, 1, 13)
                  - FLOOR (SUBSTR (p_NumeroIdentificacion, 1, 13) / 23) * 23)
               + 1;
            end;
         
           BEGIN
           IF SUBSTR (vLetras, vPosicionLetra, 1) !=
                  SUBSTR (p_NumeroIdentificacion, 14, 1)
            THEN
               CATALOGOS.PKG_PR.PR_GENERAR_ERROR (
                  'Número de Cédula, inválida2 3');
            END IF;
            END;
            
         EXCEPTION
            WHEN OTHERS
            THEN
               CATALOGOS.PKG_PR.PR_GENERAR_ERROR (
                  'Número de Cédula, inválida3');
         END nValidaUltimoCaracter;
      --DBMS_OUTPUT.PUT_LINE('Fecha Nacimiento: ' || vFechaNacimiento);
      --DBMS_OUTPUT.PUT_LINE('Número de Cédula Válida');
      ELSE
         CATALOGOS.PKG_PR.PR_GENERAR_ERROR ('Número de Cédula, inválida4');
      END IF;

      IF p_MunicipioNacimiento IS NOT NULL AND p_FechaNacimiento IS NOT NULL
      THEN
         IF    (    p_MunicipioNacimiento !=
                       SUBSTR (p_NumeroIdentificacion, 0, 3)
                AND (    SUBSTR (p_NumeroIdentificacion, 0, 3) != '777'
                     AND SUBSTR (p_NumeroIdentificacion, 0, 3) != '888'))
            OR trunc(p_FechaNacimiento) !=
                  trunc(TO_TIMESTAMP (SUBSTR (p_NumeroIdentificacion, 4, 6), 'ddmmrr'))
         THEN
            dbms_output.put_line (trunc(p_FechaNacimiento)||' != '||trunc(TO_TIMESTAMP (SUBSTR (p_NumeroIdentificacion, 4, 6),'ddmmrr')));
            CATALOGOS.PKG_PR.PR_GENERAR_ERROR (
               'Número de Cédula, inválida5');
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_Msg := '[PR_VAL_CEDULA_NICARAGUENSE] Error: ' || SQLERRM;
   END PR_VAL_CEDULA_NICARAGUENSE;
   PROCEDURE PR_GENERATE_CUSTOM_ERROR(pMsg VARCHAR2,  
                                      pMsgDev VARCHAR2 )
   IS 
   BEGIN
    RAISE_APPLICATION_ERROR ( K_CODE_CUSTOM_EXCEPTION, pMsg ||  K_STRG_COMODIN_EXCEPTION || pMsgDev, FALSE );
   END PR_GENERATE_CUSTOM_ERROR;
   PROCEDURE PR_GENERATE_ERROR (pMsg VARCHAR2)
   IS 
   BEGIN
   RAISE_APPLICATION_ERROR ( K_CODE_CUSTOM_EXCEPTION, pMsg ||  K_STRG_COMODIN_EXCEPTION, FALSE );
   END PR_GENERATE_ERROR;
   PROCEDURE PR_GET_CUSTOM_ERROR( pMsg OUT VARCHAR2,  
                                  pMsgDev OUT VARCHAR2 )
   IS 
   vMsgException    VARCHAR2(32767);
   BEGIN
    vMsgException       :=  REPLACE(REPLACE(DBMS_UTILITY.FORMAT_ERROR_STACK, CHR(10), ''), 'ORA' || TO_CHAR(SQLCODE) || ': ', '');
    pMsg    := TRIM(SUBSTR(vMsgException,0,INSTR(vMsgException,K_STRG_COMODIN_EXCEPTION)-1));
    pMsgDev := TRIM(regexp_substr(vMsgException,'[^' || K_STRG_COMODIN_EXCEPTION || ']+$', 1, 1));
   END PR_GET_CUSTOM_ERROR;
   
   
   FUNCTION FN_ALLOW_ACTION_STATE (pName VARCHAR2, pTypeRow VARCHAR2, pStateRow NUMBER, pAction VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN BOOLEAN
   IS
   vCatResult       CATALOGOS.SBC_CAT_CATALOGOS%ROWTYPE;
   BEGIN
    /*IF pTypeRow IS NULL THEN
        HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => '',  
                                                            PMSGDEV => '' );
    END IF;*/
    IF NVL(pStateRow,0) = 0 THEN
       HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'En el proceso de validación de estado del registro se requiere el Estado actual del registro',  
                                                           PMSGDEV => '[FN_ALLOW_ACTION_STATE] Especificar el valor del Estado actual del registro' );
    END IF;
    IF pAction IS NULL THEN
        HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'En el proceso de validación de estado del registro se requiere especificar la acción que se intenta realizar',  
                                                            PMSGDEV => '[FN_ALLOW_ACTION_STATE] Especificar el tipo de acción que se le desea aplicar al registro' );
    END IF;
    vCatResult      := HOSPITALARIO.PKG_CORE_PRS.FN_VAL_CAT_BY_CODE_ID(PNAME                      => 'Estado de Registro',
                                                                     PCRTO                      => pStateRow,
                                                                     PCODEPARENT                => HOSPITALARIO.PKG_CORE_PRS.K_STATE_REG,
                                                                     PTYPEVALIDATION            => HOSPITALARIO.PKG_CORE_PRS.K_VAL_CAT_CHIELD_ID,
                                                                     PMSGDEV                    => pMsgDev,
                                                                     PMSG                       => pMsg
                                                                     );
    CASE pTypeRow
        WHEN HOSPITALARIO.PKG_CORE_PRS.K_CFG_EXP_BASE THEN
            dbms_output.put_line('Aplicar validaciones para este tipo de registro');
            RETURN TRUE;
        ELSE 

            CASE vCatResult.CODIGO
               WHEN HOSPITALARIO.PKG_CORE_PRS.K_CAT_REG_DEL THEN
                CASE pAction
                        WHEN HOSPITALARIO.PKG_CORE_PRS.K_DELETE THEN 
                            RETURN TRUE;
                        ELSE
                            HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Actualmente el registro de '|| pName ||' se encuentra Eliminado, por lo que no se puede cambiar su estado, ni actualizarse',  
                                                            PMSGDEV => '[FN_ALLOW_ACTION_STATE] El registro de '|| pName ||' ya se encuentra Eliminado por lo que no puede cambiarse su estado, ni actualizarse' );
                    END CASE;
               WHEN HOSPITALARIO.PKG_CORE_PRS.K_CAT_REG_PAS THEN
                CASE pAction
                        WHEN HOSPITALARIO.PKG_CORE_PRS.K_UPDATE THEN
                            HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Actualmente el registro de '|| pName ||' se encuentra Pasivado, por lo que no se puede Modificar',  
                                                            PMSGDEV => '[FN_ALLOW_ACTION_STATE] El registro de '|| pName ||' ya se encuentra Pasivado por lo que no puede Modificarse' );
                        ELSE
                            RETURN TRUE;
                    END CASE;
               ELSE
                    RETURN TRUE;
            END CASE;
    END CASE;
   EXCEPTION
     WHEN MINSA_CUSTOM_EXCEPTION THEN 
        HOSPITALARIO.PKG_CORE_PRS.PR_GET_CUSTOM_ERROR( pMsg, pMsgDev );
        RETURN FALSE;
    WHEN OTHERS THEN
        pMsg        := 'Ha ocurrido un error inesperado en el proceso de validación de la acción a realizar para el registro de tipo de '|| pName;
        pMsgDev     := '[FN_ALLOW_ACTION_STATE] Error inesperado al intentar evaluar el estado del registro de '|| pName ||' -> ' || SQLERRM;
        RETURN FALSE;
   END FN_ALLOW_ACTION_STATE;
   
   
   FUNCTION FN_VAL_CAT_BY_CODE_ID (
                                  pName                     VARCHAR2,
                                  pCrto                     VARCHAR2,
                                  pCodeParent               VARCHAR2,
                                  pTypeValidation           VARCHAR2,
                                  pMsgDev                   OUT VARCHAR2,
                                  pMsg                      OUT VARCHAR2
                                 ) RETURN CATALOGOS.SBC_CAT_CATALOGOS%ROWTYPE
    IS
    vCatalogoResult     CATALOGOS.SBC_CAT_CATALOGOS%ROWTYPE;
    BEGIN
        IF (pName IS NULL ) THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo, requerimos especifique un nombre',  
                                                                                        PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Nombre del catálogo a evaluar no ha sido ingresado' );
        END IF;
        IF (pCrto IS NULL ) THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo, requerimos especifique su Código',  
                                                                                        PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Código del catálogo a evaluar no ha sido ingresado' );
        END IF;
        IF (pTypeValidation IS NULL ) THEN      HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo, requerimos especifique el tipo de validación a realizar',  
                                                                                        PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] El tipo de validación que se le aplicará al catálogo a evaluar no ha sido ingresado' );
        END IF;
        CASE pTypeValidation
            WHEN K_VAL_CAT_CHIELD_ID THEN
                IF ( pCodeParent IS NULL ) THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo ' || pName || ' - CODIGO: ' || pCrto || ', también se requiere el nombre Código del Catálogo Superior', 
                                                                                                    PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Para validar el Catálogo -> [' || pName || ' - CODIGO -> ' || pCrto || '], requerimos especifique el código del Catalogo Padre' );
                END IF;
                BEGIN
                    SELECT b.* 
                     INTO vCatalogoResult 
                     FROM CATALOGOS.SBC_CAT_CATALOGOS a 
                     INNER JOIN CATALOGOS.SBC_CAT_CATALOGOS b
                           ON b.CATALOGO_SUP = a.CATALOGO_ID 
                     WHERE b.CATALOGO_SUP IS NOT NULL AND 
                           a.CODIGO = pCodeParent
                       AND b.CATALOGO_ID = TO_NUMBER(NVL(pCrto, '0'));
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN  VALUE_ERROR_CONVERT THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El ID ingresado: ' || NVL(pCrto, '0') || ', no es un valor numérico', 
                                                                                                            PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Error en la conversión del ID recibido -> ' || NVL(pCrto, '0'));
                            WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con ID: ' || pCrto || ', y código superior: ' || pCodeParent || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CATALOGO_ID -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD_ID || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent || ', genera múltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Múltiples coincidencias con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD_ID || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el catálogo: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent, 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT_CHIELD THEN
                IF ( pCodeParent IS NULL ) THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Para validar el Catálogo -> [' || pName || ' - CODIGO -> ' || pCrto || '], requerimos especifique el código del Catalogo Padre', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] El valor del [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', es un valor requerido para evaluar el catálogo CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                END IF;
                BEGIN
                    SELECT b.* 
                      INTO vCatalogoResult 
                      FROM CATALOGOS.SBC_CAT_CATALOGOS a 
                      INNER JOIN CATALOGOS.SBC_CAT_CATALOGOS b
                            ON b.CATALOGO_SUP = a.CATALOGO_ID 
                      WHERE b.CATALOGO_SUP IS NOT NULL AND 
                            a.CODIGO = pCodeParent
                         AND b.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] El valor del [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', y CODIGO_DEP -> ' || pCrto || '], No genera coincidencias. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent || ', genera múltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Múltiples coincidencias con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el catálogo: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent, 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT_PARENT THEN
                BEGIN
                    SELECT a.* 
                      INTO vCatalogoResult 
                      FROM CATALOGOS.SBC_CAT_CATALOGOS a 
                     WHERE a.CATALOGO_SUP IS NULL AND 
                           a.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo Superior evaluado: ' || pName || ', identificado con código: ' || pCrto || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_PARENT || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo Superior evaluado: ' || pName || ', identificado con código: ' || pCrto || ', genera múltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Múltiples coincidencias con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_PARENT || ']'); 
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el catálogo Superior: ' || pName || ', identificado con código: ' || pCrto, 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT THEN
                BEGIN
                    SELECT a.* 
                      INTO vCatalogoResult 
                      FROM CATALOGOS.SBC_CAT_CATALOGOS a 
                     WHERE a.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT || ']');
                                                    
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', genera múltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Múltiples coincidencias con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el catálogo: ' || pName || ', identificado con código: ' || pCrto, 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] ' || SQLERRM); 
                END;
            ELSE
                HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo, requerimos especifique el tipo de validación a realizar', 
                                                                    PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] El tipo de validación que se le aplicará al catálogo a evaluar no ha sido ingresado');              
        END CASE; 
        
    EXCEPTION 
         WHEN MINSA_CUSTOM_EXCEPTION THEN 
            HOSPITALARIO.PKG_CORE_PRS.PR_GET_CUSTOM_ERROR( pMsg, pMsgDev );
            RETURN NULL;
    END FN_VAL_CAT_BY_CODE_ID;
    
    
    FUNCTION FN_H_VAL_CAT_BY_CODE_ID (
                                  pName                     VARCHAR2,
                                  pCrto                     VARCHAR2,
                                  pCodeParent               VARCHAR2,
                                  pTypeValidation           VARCHAR2,
                                  pMsgDev                   OUT VARCHAR2,
                                  pMsg                      OUT VARCHAR2
                                 ) RETURN HOSPITALARIO.SNH_CAT_CATALOGOS%ROWTYPE
    IS
    vCatalogoResult     HOSPITALARIO.SNH_CAT_CATALOGOS%ROWTYPE;
    BEGIN
        IF (pName IS NULL ) THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo, requerimos especifique un nombre',
                                                                                        PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Nombre del catálogo a evaluar no ha sido ingresado' );
        END IF;
        IF (pCrto IS NULL ) THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo, requerimos especifique su Código',  
                                                                                        PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Código del catálogo a evaluar no ha sido ingresado' );
        END IF;
        IF (pTypeValidation IS NULL ) THEN      HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo, requerimos especifique el tipo de validación a realizar',  
                                                                                        PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] El tipo de validación que se le aplicará al catálogo a evaluar no ha sido ingresado' );
        END IF;
        CASE pTypeValidation
            WHEN K_VAL_CAT_CHIELD_ID THEN
                IF ( pCodeParent IS NULL ) THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo ' || pName || ' - CODIGO: ' || pCrto || ', también se requiere el nombre Código del Catálogo Superior', 
                                                                                                    PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Para validar el Catálogo -> [' || pName || ' - CODIGO -> ' || pCrto || '], requerimos especifique el código del Catalogo Padre' );
                END IF;
                BEGIN
                    SELECT b.* 
                    INTO vCatalogoResult 
                    FROM HOSPITALARIO.SNH_CAT_CATALOGOS a 
                   INNER JOIN HOSPITALARIO.SNH_CAT_CATALOGOS b
                         ON b.CATALOGO_SUP = a.CATALOGO_ID 
                    WHERE b.CATALOGO_SUP IS NOT NULL AND 
                          a.CODIGO = pCodeParent
                    AND b.CATALOGO_ID = TO_NUMBER(NVL(pCrto, '0'));
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN  VALUE_ERROR_CONVERT THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El ID ingresado: ' || NVL(pCrto, '0') || ', no es un valor numérico', 
                                                                                                            PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Error en la conversión del ID recibido -> ' || NVL(pCrto, '0'));
                            WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con ID: ' || pCrto || ', y código superior: ' || pCodeParent || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CATALOGO_ID -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD_ID || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent || ', genera múltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Múltiples coincidencias con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD_ID || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el catálogo: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent, 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT_CHIELD THEN
                IF ( pCodeParent IS NULL ) THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Para validar el Catálogo -> [' || pName || ' - CODIGO -> ' || pCrto || '], requerimos especifique el código del Catalogo Padre', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] El valor del [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', es un valor requerido para evaluar el catálogo CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                END IF;
                BEGIN
                    SELECT b.* INTO vCatalogoResult FROM HOSPITALARIO.SNH_CAT_CATALOGOS a INNER JOIN HOSPITALARIO.SNH_CAT_CATALOGOS b
                    ON b.CATALOGO_SUP = a.CATALOGO_ID WHERE b.CATALOGO_SUP IS NOT NULL AND a.CODIGO = pCodeParent
                    AND b.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] El valor del [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', y CODIGO_DEP -> ' || pCrto || '], No genera coincidencias. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent || ', genera múltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Múltiples coincidencias con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el catálogo: ' || pName || ', identificado con código: ' || pCrto || ', y código superior: ' || pCodeParent, 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT_PARENT THEN
                BEGIN
                    SELECT a.* INTO vCatalogoResult FROM HOSPITALARIO.SNH_CAT_CATALOGOS a 
                    WHERE a.CATALOGO_SUP IS NULL AND a.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo Superior evaluado: ' || pName || ', identificado con código: ' || pCrto || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_PARENT || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo Superior evaluado: ' || pName || ', identificado con código: ' || pCrto || ', genera múltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Múltiples coincidencias con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_PARENT || ']'); 
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el catálogo Superior: ' || pName || ', identificado con código: ' || pCrto, 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT THEN
                BEGIN
                    SELECT a.* INTO vCatalogoResult FROM HOSPITALARIO.SNH_CAT_CATALOGOS a 
                    WHERE a.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT || ']');
                                                    
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El catálogo evaluado: ' || pName || ', identificado con código: ' || pCrto || ', genera múltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Múltiples coincidencias con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el catálogo: ' || pName || ', identificado con código: ' || pCrto, 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] ' || SQLERRM); 
                END;
            ELSE
                HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el Cátalogo, requerimos especifique el tipo de validación a realizar', 
                                                                    PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] El tipo de validación que se le aplicará al catálogo a evaluar no ha sido ingresado');              
        END CASE; 
    EXCEPTION 
         WHEN MINSA_CUSTOM_EXCEPTION THEN 
            HOSPITALARIO.PKG_CORE_PRS.PR_GET_CUSTOM_ERROR( pMsg, pMsgDev );
            RETURN NULL;
    END FN_H_VAL_CAT_BY_CODE_ID;

   FUNCTION VALIDATE_EXIST_ROW(pCodeEntity VARCHAR2, pTypeValidate VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2,
                               pArg4 VARCHAR2, pArg5 VARCHAR2, pArg6 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN BOOLEAN
   IS
   vCount               NUMBER(10);
   vMsg                 VARCHAR2(32767);
   vMsgDev              VARCHAR2(32767);
   BEGIN
    if (pCodeEntity is null or pTypeValidate is null) then 
        --        pMsg        := 'Inconvenientes con la validación de exitencia de registro';
        --        pMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
        --                          ' la entidad a evaluar o el tipo validación';
        vMsg        := 'Inconvenientes con la validación de exitencia de registro';
        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                          ' la entidad a evaluar o el tipo validación';
        HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(pMsg, pMsgDev);
    end if;
    
    CASE pCodeEntity
        WHEN K_CFG_EXP_BASE THEN 
            CASE pTypeValidate
            WHEN K_VLD_ID THEN
                SELECT COUNT(DET_CODIGO_EXPEDIENTE_ID) INTO vCount FROM SNH_CFG_COD_EXP_BASE WHERE DET_CODIGO_EXPEDIENTE_ID = pArg1;
                IF NVL(vCount,0) > 0 THEN 
                    RETURN TRUE; 
                ELSE 
                    vMsg            := 'La búsqueda de Expediente Base ' || pArg1 || ', no genera coincidencias';
                    vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Expediente Base ID ' || pArg1 || ', no genera coincidencias';
                    PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                    --RETURN FALSE; 
                END IF;
            ELSE RETURN FALSE;
            END CASE;
            
        WHEN K_MST_PACIENTES THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                    SELECT COUNT(PACIENTE_ID) INTO vCount FROM HOSPITALARIO.SNH_MST_PACIENTES WHERE PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Paciente ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                                          ' la entidad a evaluar o el tipo validación';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE;

        WHEN K_MST_COD_EXP THEN
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                    SELECT COUNT(EXPEDIENTE_ID) INTO vCount FROM HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE WHERE EXPEDIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Expediente Electrónico ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                                          ' la entidad a evaluar o el tipo validación';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_VLD_CODE THEN
                    SELECT COUNT(EXPEDIENTE_ID) INTO vCount FROM HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE WHERE CODIGO_EXPEDIENTE_ELECTRONICO = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Expediente Electrónico ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                                          ' la entidad a evaluar o el tipo validación';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE;
        WHEN K_HST_COD_EXP THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                    SELECT COUNT(HIST_EXPEDIENTE_ID) INTO vCount FROM HOSPITALARIO.SNH_HST_CODIGO_EXPEDIENTE WHERE HIST_EXPEDIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Código Expediente Electrónico Histórico ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                                          ' la entidad a evaluar o el tipo validación';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE;
        WHEN K_DET_EXP_LOC THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_EXP_LOCALES A WHERE A.PX_EXP_LOCAL_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Código Expediente Local por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Código Expediente Local por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_EXP_LOCALES A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Expediente Local, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Expediente Local, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                    
                WHEN K_CAT_UND_SLD THEN 
                      --SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_EXP_LOCALES A WHERE A.PACIENTE_ID = pArg1;
                      SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_EXP_LOCALES A WHERE A.PACIENTE_ID = pArg1 AND A.UNIDAD_SALUD_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        RETURN FALSE;
                    END IF;
                WHEN K_DET_EXP_LOC THEN
                    if(pArg3 IS NULL) THEN
                        SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_EXP_LOCALES A WHERE A.UNIDAD_SALUD_ID = pArg1 AND A.EXPEDIENTE_LOCAL = pArg2;
                        IF NVL(vCount,0) > 0 THEN 
                            RETURN TRUE; 
                        ELSE 
                            RETURN FALSE;
                        END IF;
                        ELSE
                        SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_EXP_LOCALES A WHERE A.UNIDAD_SALUD_ID = pArg1 AND A.EXPEDIENTE_LOCAL = pArg2 AND A.PX_EXP_LOCAL_ID != pArg3;
                        IF NVL(vCount,0) > 0 THEN 
                            RETURN TRUE; 
                        ELSE 
                            RETURN FALSE;
                        END IF;
                    END IF;
                ELSE RETURN FALSE;
            END CASE;
        
        WHEN K_CAT_PROGRAMS THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_CAT_PROGRAMAS A WHERE A.PROGRAMA_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Programa por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Programa por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE;

        
        WHEN K_DET_PROGRAM THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_PROGRAMAS A WHERE A.PX_PROGRAMA_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Programa por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Programa por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_PROGRAMAS A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Programa, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Programa, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE;

        WHEN K_DET_PX_CRCT THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_CARACTERISTICAS A WHERE A.PX_CARACTERISTICA_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Caracteristica de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Caracteristica de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_CARACTERISTICAS A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda Caracteristica de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Caracteristica de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_DET_PX_CRCT THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_CARACTERISTICAS A WHERE A.PACIENTE_ID = pArg1 AND A.CARACTERISTICA_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda Caracteristica de Paciente, para el Paciente con ID: ' || pArg1 || ', y caracteristica ID: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Caracteristica de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        --PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE; 
        
        WHEN K_DET_PX_CNCT THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_CONTACTOS_anterior A WHERE A.PX_CONTACTO_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Contactos de Pacientes por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Contactos de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_CONTACTOS_anterior A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda Contactos de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Contactos de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE;
        
        WHEN K_DET_PX_FNMC THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_FINANCIAMIENTOS A WHERE A.PX_FINANCIAMIENTO_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Financiamientos de Pacientes por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Financiamientos de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_FINANCIAMIENTOS A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda Financiamientos de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Financiamientos de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_DET_PX_FNMC THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_FINANCIAMIENTOS A WHERE A.PACIENTE_ID = pArg1 AND FUENTE_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda Financiamientos de Paciente, para el Paciente con ID: ' || pArg1 || ', y Fuente de Financiamiento ID: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Financiamientos de Paciente, para el Paciente con ID: ' || pArg1 || ', y Fuente de Financiamiento ID: ' || pArg2 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_FNMC_CODE THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_FINANCIAMIENTOS A WHERE A.FUENTE_ID = pArg1 AND A.CODIGO_AFILIACION = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda Financiamientos Tipo ID: ' || pArg1 || ', y Código de Afiliación: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda Financiamientos Tipo ID: ' || pArg1 || ', y Código de Afiliación: ' || pArg2 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE;
        
        WHEN K_DET_PX_IDNT THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                   --BAK -->  SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_IDENTIFICACIONES A WHERE A.PX_IDENTIFICACION_ID = pArg1;
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PER_IDENTIFICACIONES A WHERE A.PER_IDENTIFICACION_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Identificacion de Pacientes por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Identificacion de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN
                    
                     -- SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_IDENTIFICACIONES A WHERE A.PACIENTE_ID = pArg1;
                      SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PER_IDENTIFICACIONES A WHERE A.EXPEDIENTE_ID = pArg1;

                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Identificaciones de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Identificaciones de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_DET_PX_IDNT THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_IDENTIFICACIONES A WHERE A.PACIENTE_ID = pArg1 AND TIPO_IDENTIFICACION_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Identificaciones de Paciente, para el Paciente con ID: ' || pArg1 || ', e Identificación ID: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Identificaciones de Paciente, para el Paciente con ID: ' || pArg1 || ', e Identifficación ID: ' || pArg2 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_DET_XP_IDNT THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PER_IDENTIFICACIONES A WHERE A.EXPEDIENTE_ID = pArg1 AND TIPO_IDENTIFICACION_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Identificaciones de Paciente, para el Paciente con Expediente ID: ' || pArg1 || ', e Identificación ID: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Identificaciones de Paciente, para el Paciente con Expediente ID: ' || pArg1 || ', e Identifficación ID: ' || pArg2 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                    
                WHEN K_IDNTF_CODE THEN
                    
                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_IDENTIFICACIONES A WHERE A.TIPO_IDENTIFICACION_ID = pArg1 AND A.IDENTIFICACION = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Identificaciones de Pacientes, tipo de Identificación ID: ' || pArg1 || ', y número de Identificación: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Identificaciones de Pacientes, tipo de Identificación ID: ' || pArg1 || ', y número de Identificación: ' || pArg2 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                ELSE RETURN FALSE;
            END CASE;
        
        WHEN K_DET_PX_RSDN THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                     SELECT COUNT(1) INTO vCount FROM CATALOGOS.SBC_DET_PRS_RESIDENCIA A WHERE A.DET_PRS_RESIDENCIA_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Residencia de Pacientes por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Residencia de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN
                     --SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_RESIDENCIAS A WHERE A.PACIENTE_ID = pArg1;
                     SELECT COUNT(A.DET_PRS_RESIDENCIA_ID) INTO vCount FROM CATALOGOS.SBC_DET_PRS_RESIDENCIA A
                     INNER JOIN HOSPITALARIO.SNH_MST_PACIENTES P ON A.EXPEDIENTE_ID = P.EXPEDIENTE_ID WHERE P.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda Residencias de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Residencias de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;

                WHEN K_MST_COD_EXP THEN
                     SELECT COUNT(A.DET_PRS_RESIDENCIA_ID) INTO vCount FROM CATALOGOS.SBC_DET_PRS_RESIDENCIA A WHERE A.EXPEDIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda Residencias de Residencia, para el Expediente ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Residencias de Paciente, identificado con Expediente ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                
                ELSE RETURN FALSE;
            END CASE;
        WHEN K_CAT_UND_SLD THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN
                     SELECT COUNT(1) INTO vCount FROM CATALOGOS.SBC_CAT_UNIDADES_SALUD A WHERE A.UNIDAD_SALUD_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Unidad de Salud por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La búsqueda de Unidad de Salud por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;

                ELSE RETURN FALSE;
            END CASE;
            
        ELSE return false;
    END CASE;
    
   EXCEPTION
        WHEN HOSPITALARIO.PKG_CORE_PRS.MINSA_CUSTOM_EXCEPTION THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GET_CUSTOM_ERROR( pMsg, pMsgDev ); RETURN FALSE;
   END VALIDATE_EXIST_ROW;
   
   FUNCTION VALIDATE_EXIST_ROW_SEGURIDAD(pCodeEntity VARCHAR2, pTypeValidate VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2,
                                         pArg4 VARCHAR2, pArg5 VARCHAR2, pArg6 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN BOOLEAN
   IS
   vCount               NUMBER(10);
   vMsg                 VARCHAR2(32767);
   vMsgDev              VARCHAR2(32767);
   BEGIN
    if (pCodeEntity is null or pTypeValidate is null) then 
        vMsg        := 'Inconvenientes con la validación de exitencia de registro';
        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                          ' la entidad a evaluar o el tipo validación';
        HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(pMsg, pMsgDev);
    end if;
    
    CASE pCodeEntity
        WHEN K_MST_USUARIOS THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN

                    SELECT COUNT(USUARIO_ID) INTO vCount FROM SEGURIDAD.SCS_MST_USUARIOS WHERE USUARIO_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Usuario con ID ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] La búsqueda de Usuario con ID ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                --K_LKUSR_USERNAME    
                WHEN K_LKUSR_USERNAME THEN

                    SELECT COUNT(USUARIO_ID) INTO vCount FROM SEGURIDAD.SCS_MST_USUARIOS WHERE USERNAME = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Usuario con username ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] La búsqueda de Usuario con username ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;    
                ELSE RETURN FALSE;
            END CASE;
        --    
        WHEN K_MST_SISTEMAS THEN 
            CASE pTypeValidate
                WHEN K_VLD_ID THEN

                    SELECT COUNT(SISTEMA_ID) INTO vCount FROM SEGURIDAD.SCS_CAT_SISTEMAS WHERE SISTEMA_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Sistema con ID ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] La búsqueda de Sistema con ID ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                    
                WHEN K_LKSYS_CODE THEN

                    SELECT COUNT(SISTEMA_ID) INTO vCount FROM SEGURIDAD.SCS_CAT_SISTEMAS WHERE CODIGO = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La búsqueda de Sistema con código ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] La búsqueda de Sistema con código ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;    
                ELSE RETURN FALSE;
            END CASE;    
            
        ELSE return false;
    END CASE;
    
   EXCEPTION
        WHEN HOSPITALARIO.PKG_CORE_PRS.MINSA_CUSTOM_EXCEPTION THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GET_CUSTOM_ERROR( pMsg, pMsgDev ); RETURN FALSE;
   END VALIDATE_EXIST_ROW_SEGURIDAD;

  FUNCTION FN_OBT_ESTADO_REGISTRO (pValor IN CATALOGOS.SBC_CAT_CATALOGOS.VALOR%TYPE) RETURN NUMBER AS
  vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
  -- 6869    ACTREG    Activo
  -- 6870    PASREG    Pasivo
  -- 6871    DELREG    Eliminado
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'STREG' AND 
            B.PASIVO = 0
      WHERE A.VALOR  = pValor AND
            A.PASIVO = 0;

     RETURN vCatalogoId;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId;
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener estado del registro. '||SQLERRM);     
       RETURN vCatalogoId;    
 END FN_OBT_ESTADO_REGISTRO;
 
 FUNCTION FN_OBTENER_ESTADO_REG(pCodeParent IN VARCHAR2, pCodigoHijo IN VARCHAR2) RETURN NUMBER
AS
pCatalogoResult CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
BEGIN
SELECT  b.CATALOGO_ID INTO pCatalogoResult FROM CATALOGOS.SBC_CAT_CATALOGOS a INNER JOIN CATALOGOS.SBC_CAT_CATALOGOS b
                    ON b.CATALOGO_SUP = a.CATALOGO_ID WHERE b.CATALOGO_SUP IS NOT NULL AND a.CODIGO = pCodeParent
                    AND b.CODIGO = pCodigoHijo AND b.PASIVO = 0;
                    
RETURN pCatalogoResult;
                  
EXCEPTION WHEN NO_DATA_FOUND
THEN
RETURN 0;   
WHEN OTHERS THEN  
RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener estado del registro. '||SQLERRM);     
RETURN 0;               
END FN_OBTENER_ESTADO_REG;
 
 FUNCTION FN_OBT_TIPO_PERSONA (pValor IN CATALOGOS.SBC_CAT_CATALOGOS.VALOR%TYPE) RETURN NUMBER AS
   vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pValor IS NOT NULL THEN
          SELECT A.CATALOGO_ID
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'TPPERS' AND 
                 B.PASIVO = 0
           WHERE A.VALOR  = pValor AND
                 A.PASIVO = 0;
     ELSE NULL;
     END CASE;
     RETURN vCatalogoId;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       vCatalogoId := -1;
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener estado del registro. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_TIPO_PERSONA;
 
 FUNCTION FN_VALIDAR_USUARIO (pUsuario IN VARCHAR2) RETURN BOOLEAN AS
 vContador SIMPLE_INTEGER := 0;
 vRetorna  BOOLEAN := FALSE;
 BEGIN
      DBMS_OUTPUT.PUT_LINE ('Entró a validar usuario');
      IF pUsuario IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE ('Entró a usuario is not null');
         SELECT COUNT (1)
           INTO vContador
           FROM SEGURIDAD.SCS_MST_USUARIOS
          WHERE UPPER (USERNAME) = UPPER (pUsuario) AND
                ROWNUM = 1;
         DBMS_OUTPUT.PUT_LINE ('Contador existe usuario: '||vContador);       
         IF vContador > 0 THEN
            vRetorna := TRUE;
         END IF;
      END IF;
         RETURN vRetorna;
  EXCEPTION
    WHEN OTHERS THEN
         RETURN FALSE;     
 END FN_VALIDAR_USUARIO;
 
 FUNCTION FN_OBT_TIP_IDENT (pTipoIdentificacion IN VARCHAR2) RETURN NUMBER AS
 --  vCodigo CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE;
   vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pTipoIdentificacion IS NOT NULL THEN
          SELECT A.CATALOGO_ID  --CODIGO
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'TPIDNTF' AND 
                 B.PASIVO = 0
           WHERE --A.CATALOGO_ID  = pTipoIdentificacion AND
                 A.CODIGO  = pTipoIdentificacion AND
                 A.PASIVO = 0;
     ELSE NULL;
     END CASE;

    RETURN vCatalogoId;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
      -- RAISE_APPLICATION_ERROR (-20000, 'No se encontró tipo identificación. '||SQLERRM);
       vCatalogoId := -1;
       RETURN vCatalogoId;
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id del tipo de identificación. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_TIP_IDENT; 
 
 FUNCTION FN_OBT_SEXO_ID (pSexo IN VARCHAR2) RETURN NUMBER AS
  -- vCodigo     CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE;
   vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pSexo IS NOT NULL THEN
          SELECT A.CATALOGO_ID  --CODIGO
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'SEXO' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pSexo AND -- 'SEXO|'||pSexo AND
                 A.PASIVO = 0;
      ELSE NULL;
      END CASE;
     RETURN vCatalogoId;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
      -- RAISE_APPLICATION_ERROR (-20000, 'No se encontró el Id del Sexo. '||SQLERRM);  
       vCatalogoId := -1;
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id del Sexo. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_SEXO_ID; 
 
 FUNCTION FN_OBT_TIPO_PERSONA_ID (pTipoPersona IN VARCHAR2) RETURN NUMBER AS
   vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE 
     WHEN pTipoPersona IS NOT NULL THEN
          SELECT A.CATALOGO_ID  --CODIGO
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'TPPERS' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pTipoPersona AND
                 A.PASIVO = 0;
      ELSE NULL;
      END CASE;

     RETURN vCatalogoId;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontró el Id de tipo de persona. '||SQLERRM);
       vCatalogoId := -1;
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de tipo de persona. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_TIPO_PERSONA_ID; 
 
 FUNCTION FN_OBT_TIPO_CODEXPID (pTipoCodExpediente IN VARCHAR2) RETURN NUMBER AS
   vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pTipoCodExpediente IS NOT NULL THEN
          SELECT A.CATALOGO_ID
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'CODEXP' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pTipoCodExpediente AND
                 A.PASIVO = 0;
     ELSE NULL;
     END CASE;

     RETURN vCatalogoId;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       -- RAISE_APPLICATION_ERROR (-20000, 'No se encontró el Id de tipo código expediente. '||SQLERRM);  
       vCatalogoId := -1;
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de tipo código expediente. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_TIPO_CODEXPID;

  FUNCTION FN_OBT_TIPO_CODEXPID_DE_EXPID (pExpedienteId IN NUMBER) RETURN NUMBER AS
   vTipCodExpId SNH_CFG_COD_EXP_BASE.TIPO_CODIGO_EXPEDIENTE_ID%TYPE; 
  BEGIN
        SELECT CFG.TIPO_CODIGO_EXPEDIENTE_ID
          INTO vTipCodExpId
          FROM SNH_CFG_COD_EXP_BASE CFG
          JOIN SNH_MST_CODIGO_EXPEDIENTE EXP
            ON EXP.DET_COD_EXPEDIENTE_ID = CFG.DET_CODIGO_EXPEDIENTE_ID AND
               EXP.EXPEDIENTE_ID = pExpedienteId;   
  RETURN vTipCodExpId;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       vTipCodExpId := -1;
       RETURN vTipCodExpId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de tipo código expediente a partir del expediente id. '||pExpedienteId||' - '||SQLERRM);     
       RETURN vTipCodExpId;
  END FN_OBT_TIPO_CODEXPID_DE_EXPID;  
 
 FUNCTION FN_OBT_ETNIA_ID (pEtnia IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pEtnia IS NOT NULL THEN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'ETNIA' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pEtnia AND
            A.PASIVO = 0;
     ELSE NULL;
     END CASE;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontró el Id de Etnia. '||SQLERRM);
       vCatalogoId := -1;
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de Etnia. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_ETNIA_ID; 
 FUNCTION FN_OBT_TIPO_SANGRE_ID (pTipoSangre IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pTipoSangre IS NOT NULL THEN
          SELECT A.CATALOGO_ID
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'GSANG' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pTipoSangre AND
                 A.PASIVO = 0;
     ELSE NULL;
     END CASE;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontró el Id de Tipo de sangre. '||SQLERRM);
        vCatalogoId := -1;
        RETURN vCatalogoId;  
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de Tipo de sangre. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_TIPO_SANGRE_ID; 
 FUNCTION FN_OBT_ESTADO_CIVIL_ID (pEstadoCivil IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pEstadoCivil IS NOT NULL THEN
          SELECT A.CATALOGO_ID
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'ESTCV' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pEstadoCivil AND
                 A.PASIVO = 0;
      ELSE NULL;
      END CASE;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       -- RAISE_APPLICATION_ERROR (-20000, 'No se encontró Id de religión. '||SQLERRM); 
       vCatalogoId := -1;      
       RETURN vCatalogoId;  
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de religión. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_ESTADO_CIVIL_ID;  
 FUNCTION FN_OBT_RELIGION_ID (pReligion IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pReligion IS NOT NULL THEN
          SELECT A.CATALOGO_ID
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'HSF_RELIG' AND --'RELIGIONES' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pReligion AND
                 A.PASIVO = 0;
     ELSE NULL;
     END CASE;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontró el Id de religión. '||SQLERRM);
       vCatalogoId := -1;       
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de religión. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_RELIGION_ID; 
 FUNCTION FN_OBT_OCUPACION_ID (pOcupacion IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pOcupacion IS NOT NULL THEN
          SELECT A.CATALOGO_ID
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'OCUPACIONES' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pOcupacion AND
                 A.PASIVO = 0;
     ELSE NULL;
     END CASE;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       --RAISE_APPLICATION_ERROR (-20000, 'No se puedo encontrar Id de Ocupacion. '||SQLERRM); 
       vCatalogoId := -1;       
       RETURN vCatalogoId;  
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de Ocupacion. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_OCUPACION_ID;
 
 FUNCTION FN_OBT_TIPO_RESIDENCIA_ID (pTipoResidencia IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE
     WHEN pTipoResidencia IS NOT NULL THEN
          SELECT A.CATALOGO_ID
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'TPRESIDENC' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pTipoResidencia AND
                 A.PASIVO = 0;
     ELSE NULL;
     END CASE;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       --RAISE_APPLICATION_ERROR (-20000, 'No se pudo encontrar el Id de Ocupacion. '||SQLERRM); 
      vCatalogoId := -1;      
      RETURN vCatalogoId;  
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de Ocupacion. '||SQLERRM);     
       RETURN vCatalogoId;  
 END FN_OBT_TIPO_RESIDENCIA_ID; 
 
 FUNCTION FN_OBT_ESCOLARIDAD (pTipEscolaridad IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'ESCOLARIDAD' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pTipEscolaridad AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo relación. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_ESCOLARIDAD;
 
 FUNCTION FN_OBT_TIPO_TELEFONO_ID (pTipoTelefono IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     CASE 
     WHEN pTipoTelefono IS NOT NULL THEN
          SELECT A.CATALOGO_ID
            INTO vCatalogoId  
            FROM CATALOGOS.SBC_CAT_CATALOGOS A
            JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
              ON A.CATALOGO_SUP = B.CATALOGO_ID AND
                 B.CODIGO = 'TP_TELF' AND 
                 B.PASIVO = 0
           WHERE A.CODIGO  = pTipoTelefono AND
                 A.PASIVO = 0;
     ELSE NULL;
     END CASE;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontró el id tipo de teléfono. '||SQLERRM);  
       vCatalogoId := -1;
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id tipo de telefono. '||SQLERRM);     
       RETURN vCatalogoId;  
 END FN_OBT_TIPO_TELEFONO_ID; 
 
 FUNCTION FN_OBT_VALOR_CATALOGO (pCodigo IN VARCHAR2) RETURN VARCHAR2 AS
 vValor CATALOGOS.SBC_CAT_CATALOGOS.VALOR%TYPE;
 BEGIN
    SELECT VALOR
      INTO vValor
      FROM CATALOGOS.SBC_CAT_CATALOGOS
     WHERE CODIGO = pCodigo; 
     
     RETURN vValor;
 END;

 FUNCTION FN_OBT_TIPO_RELACION (pTipoRelacion IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'TAPRS' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pTipoRelacion AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo relación. '||SQLERRM);     
       RETURN vCatalogoId;  
 END FN_OBT_TIPO_RELACION;
 
 FUNCTION FN_OBT_PARENTESCO (pParentesco IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'PRNTSCPRS' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pParentesco AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo parentesco. '||SQLERRM);     
       RETURN vCatalogoId;  
 END FN_OBT_PARENTESCO; 

 FUNCTION FN_OBT_TIP_UNIFICACION (pTipoUnificacion IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'UNIFPERSONAS' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pTipoUnificacion AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo parentesco. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_TIP_UNIFICACION;
  
 FUNCTION FN_OBT_TIP_CONTACTO_PX (pTipoContacto IN VARCHAR2) RETURN NUMBER AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'TPRELACION' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pTipoContacto AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo relación contacto. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_TIP_CONTACTO_PX; 
 /*FUNCTION FN_EXISTE_CATALOGO (pId IN NUMBER, pCodigo VARCHAR2) RETURN BOOLEAN AS
 vId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
   SELECT A.CATALOGO_ID
       INTO vId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = pCodigo AND 
            B.PASIVO = 0
      WHERE A.CATALOGO_ID  = pId AND
            A.PASIVO = 0;

     RETURN vId > 0;
 EXCEPTION
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener estado del registro. '||SQLERRM);     
       RETURN FALSE;
 END FN_EXISTE_CATALOGO; */

 FUNCTION FN_OBT_PAIS_ORIGEN (pExpedienteId IN SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE) RETURN NUMBER AS
 vContador SIMPLE_INTEGER := 0;
 vPaisId   CATALOGOS.SBC_CAT_PAISES.PAIS_ID%TYPE;
 BEGIN
   DBMS_OUTPUT.PUT_LINE ('pExpedienteId: '||pExpedienteId);  
   SELECT COUNT (1) 
     INTO vContador
     FROM CATALOGOS.SBC_MST_PERSONAS
    WHERE EXPEDIENTE_ID = pExpedienteId AND
          PAIS_NACIMIENTO_ID IS NOT NULL;
        DBMS_OUTPUT.PUT_LINE ('Contador pais origen: '||vContador);  
    CASE
    WHEN vContador > 0 THEN
         BEGIN
            SELECT PAIS_NACIMIENTO_ID
              INTO vPaisId
              FROM CATALOGOS.SBC_MST_PERSONAS
             WHERE EXPEDIENTE_ID = pExpedienteId;
          DBMS_OUTPUT.PUT_LINE ('pais origen: '||vPaisId);      
         END; 
    ELSE NULL;
    END CASE;           
    
    RETURN vPaisId;
 EXCEPTION 
 WHEN OTHERS THEN
      RETURN vPaisId;
 END FN_OBT_PAIS_ORIGEN; 
---- Modificaciones para identificaciones
 FUNCTION FN_OBT_FECNAC_FORMATEADA (pFechaNacimiento IN DATE) RETURN TIMESTAMP AS
 vFecha TIMESTAMP;
 BEGIN
   DBMS_OUTPUT.PUT_LINE ('DENTRO FN_OBT_FECNAC_FORMATEADA');
   DBMS_OUTPUT.PUT_LINE ('pFechaNacimiento: '||pFechaNacimiento);
   SELECT pFechaNacimiento
          INTO vFecha 
     FROM DUAL; 
      DBMS_OUTPUT.PUT_LINE ('vFecha: '||vFecha);
     RETURN vFecha;
 EXCEPTION 
 WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE ('ERROR FORMATO FECHA: '||SQLERRM);
      RETURN vFecha; 
 END FN_OBT_FECNAC_FORMATEADA; 

 FUNCTION FN_FORMATEAR_FECHA_NACIMIENTO (pFechaNacimiento IN DATE) RETURN VARCHAR2 AS
 vFechaNac VARCHAR2(6);
 BEGIN    

       SELECT CONCAT(LPAD(EXTRACT(DAY FROM pFechaNacimiento),2,'0'),--[DIA]
              CONCAT(LPAD(EXTRACT(MONTH FROM pFechaNacimiento),2,'0'),--[MES]
              SUBSTR(EXTRACT(YEAR FROM pFechaNacimiento),3,2)/*[ANIO]*/)
                )
         INTO vFechaNac
         FROM DUAL;
 RETURN vFechaNac;
 EXCEPTION
 WHEN OTHERS THEN
     RETURN vFechaNac;         

 END FN_FORMATEAR_FECHA_NACIMIENTO;

 FUNCTION FN_VALIDA_EXISTE_IDENTIF (pExpedienteId IN SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE, 
                                    pIdentificacion IN VARCHAR2) RETURN BOOLEAN AS
 nContador SIMPLE_INTEGER := 0;
 bExiste BOOLEAN := FALSE;                                        
 BEGIN
    SELECT COUNT (1)
      INTO nContador
      FROM HOSPITALARIO.SNH_DET_PER_IDENTIFICACIONES
     WHERE EXPEDIENTE_ID != pExpedienteId AND 
           IDENTIFICACION = pIdentificacion;
     CASE
     WHEN nContador > 0 THEN
          bExiste := TRUE;
     ELSE NULL;
     END CASE;

 RETURN bExiste;
 EXCEPTION
 WHEN OTHERS THEN
     RETURN bExiste;  
 END FN_VALIDA_EXISTE_IDENTIF; 

 PROCEDURE PR_SBC_MST_C_PRS_IDNTF (pConfIdnt              IN HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos,          
                                   pIdentificacion        IN VARCHAR2, 
                                   pFechaNacimiento       IN DATE,
                                   pPaisOrigenId          IN CATALOGOS.SBC_CAT_PAISES.PAIS_ID%TYPE,
                                   pMunicipioNacimientoId IN CATALOGOS.SBC_CAT_MUNICIPIOS.MUNICIPIO_ID%TYPE,
                                   pResultado             OUT VARCHAR2,
                                   pMsgError              OUT VARCHAR2) IS
 vEdadFormat     VARCHAR2(10);
 vFechaNac       VARCHAR2(6);
 vIdentificacion HOSPITALARIO.SNH_DET_PER_IDENTIFICACIONES.IDENTIFICACION%TYPE;
 typeArreglo     CATALOGOS.PKG_SBC_CATALOGOS.assoc_array_str_datos;
 vNicId          NUMBER := 158;
 vExtr           BOOLEAN := FALSE;
 vIniCod         VARCHAR2(3);
 vValNum         BOOLEAN;
 vFirma          VARCHAR2(100) := 'PKG_SNH_UTILITARIOS.PR_SBC_MST_C_PRS_IDNTF => ';
 BEGIN
          CATALOGOS.PKG_PR.PR_VALIDA_FECHA (PNOMBRE      => 'Fecha de Nacimiento', 
                                            PVALOR      => pFechaNacimiento,
                                            PVALMIN     => SYSTIMESTAMP - 47450, 
                                            PVALMAX     => SYSTIMESTAMP,
                                            PREQUIRED   => TRUE);
                                            
           vEdadFormat := HOSPITALARIO.PKG_CATALOGOS_UTIL.FN_FECHA_NACIMIENTO(pFechaNacimiento);    
           
           vFechaNac :=  FN_FORMATEAR_FECHA_NACIMIENTO (pFechaNacimiento);
           
           vFechaNac:= CATALOGOS.PKG_PR.FN_VALIDA_CADENA('Fecha Nacimiento Formateada',vFechaNac,6,6,TRUE); 
           
           vIdentificacion:= CATALOGOS.PKG_PR.FN_VALIDA_CADENA('Número de Identificación',
                                                                REGEXP_REPLACE(UPPER(pIdentificacion),'\W'),
                                                                CASE 
                                                                WHEN pConfIdnt(4) = 0 THEN 
                                                                     50 
                                                                ELSE pConfIdnt(4) 
                                                                END,
                                                                CASE 
                                                                WHEN pConfIdnt(3) = 0 THEN 
                                                                     0 
                                                                ELSE pConfIdnt(3) 
                                                                END,
                                                                FALSE); 
          IF pConfIdnt(5) IS NOT NULL THEN 
             vValNum:= REGEXP_LIKE(vIdentificacion,pConfIdnt(5)); 
             IF vValNum = FALSE THEN
                pResultado := 'Formato de número de identificación inválido';
                pMsgError  := pResultado;            
                RAISE eParametrosInvalidos;             
             END IF;  END 
          IF;           
          
          CATALOGOS.PKG_SBC_CATALOGOS.PR_VALIDA_REGISTRO(CATALOGOS.PKG_SBC_CATALOGOS.kPAIS, 
                                                         'País Origen ID', 
                                                         pPaisOrigenId);
                                                         
         typeArreglo:= CATALOGOS.PKG_SBC_CATALOGOS.FN_OBTIENE_DATOS_POR_ID(CATALOGOS.PKG_SBC_CATALOGOS.kPAIS, 
                                                                           'País Origen ID', 
                                                                           pPaisOrigenId);
         
        CASE pPaisOrigenId
          WHEN vNicId THEN 
                IF (pConfIdnt(2) = 'CED') THEN--ANEXADO 20210319526
                    IF(SUBSTR(pIdentificacion,0,3) != '777' AND SUBSTR(pIdentificacion,0,3) != '888') THEN--ANEXADO -202103191526
                        CATALOGOS.PKG_SBC_CATALOGOS.PR_VALIDA_REGISTRO(CATALOGOS.PKG_SBC_CATALOGOS.kMUNICIPIO, 
                                                                       'Municipio Nacimiento', 
                                                                       pMunicipioNacimientoId);
                        typeArreglo:= CATALOGOS.PKG_SBC_CATALOGOS.FN_OBTIENE_DATOS_POR_ID(CATALOGOS.PKG_SBC_CATALOGOS.kMUNICIPIO, 
                                                                                              'Municipio Nacimiento', 
                                                                                              pMunicipioNacimientoId);
                        vIniCod:= LPAD(typeArreglo(3),3,'0');
                    ELSE
                        vIniCod:= LPAD(typeArreglo(2),3,'0');
                    END IF;
                ELSE    --ANEXADO 20210319526
                    vIniCod:= LPAD(typeArreglo(2),3,'0');--ANEXADO 20210319526
                END IF;--ANEXADO 20210319526
          ELSE 
              vIniCod:= LPAD(typeArreglo(2),3,'0');
        END CASE;  
         /*
        -->>INICIA ORIGINAL<<-- 
        CASE pPaisOrigenId
          WHEN vNicId THEN 
               IF vExtr THEN 
                  vIniCod:= LPAD(typeArreglo(2),3,'0');
               ELSE CATALOGOS.PKG_SBC_CATALOGOS.PR_VALIDA_REGISTRO(CATALOGOS.PKG_SBC_CATALOGOS.kMUNICIPIO, 
                                                                   'Municipio Nacimiento', 
                                                                   pMunicipioNacimientoId);
                        typeArreglo:= CATALOGOS.PKG_SBC_CATALOGOS.FN_OBTIENE_DATOS_POR_ID(CATALOGOS.PKG_SBC_CATALOGOS.kMUNICIPIO, 
                                                                                          'Municipio Nacimiento', 
                                                                                          pMunicipioNacimientoId);
                        vIniCod:= LPAD(typeArreglo(3),3,'0'); END IF;
          ELSE 
              vIniCod:= LPAD(typeArreglo(2),3,'0');
          END CASE; 
          ---->>FIN ORIGINAL<<----
          */   
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;
      pMsgError  := vFirma||pMsgError;
 WHEN eParametrosInvalidos THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pMsgError;
 WHEN eParametroNull THEN
      pResultado := pResultado;       
      pMsgError  := vFirma||pMsgError; 
 WHEN eCoincidencia THEN
      pResultado := pMsgError;
      pMsgError  := vFirma||pResultado;
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al formatear parámetros nombres y/o identificación. '||SQLERRM;
      pMsgError  := vFirma||pResultado||sqlerrm;                                                                                        
 END PR_SBC_MST_C_PRS_IDNTF; 

 PROCEDURE PR_VALIDA_IDENTIFICACIONES (pExpedienteId          IN SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE DEFAULT NULL,
                                       pIdentificacion        IN OUT VARCHAR2,
                                       pTipoIdentificacion    IN CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                       pTipoPersona           IN VARCHAR2 default null,
                                       pPaisOrigenId          IN CATALOGOS.SBC_CAT_PAISES.PAIS_ID%TYPE DEFAULT NULL,
                                       pMunicipioNacimientoId IN CATALOGOS.SBC_MST_PERSONAS.MUNICIPIO_NACIMIENTO_ID%TYPE,
                                       pFechaNacimiento       IN CATALOGOS.SBC_MST_PERSONAS.FECHA_NACIMIENTO%TYPE,                                    
                                       pResultado             OUT VARCHAR2,
                                       pMsgError              OUT VARCHAR2) IS
  vDatos        HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos;
 --  vPaisId       CATALOGOS.SBC_CAT_PAISES.PAIS_ID%TYPE := FN_OBT_PAIS_ORIGEN (pExpedienteId);
  vNicId        NUMBER(10);
  vPaisOrigenId CATALOGOS.SBC_CAT_PAISES.PAIS_ID%TYPE := NVL(FN_OBT_PAIS_ORIGEN (pExpedienteId),0);
  vFirma        VARCHAR2(100) := 'PKG_SNH_UTILITARIOS.PR_VALIDA_IDENTIFICACIONES => ';
  vFechaNac     DATE;  --TIMESTAMP;
 BEGIN
 
    --INICIO Modificación 20210318
     DBMS_OUTPUT.PUT_LINE ('vPaisOrigenId: '||vPaisOrigenId);
     CASE
     WHEN NVL(vPaisOrigenId,0) = 0 THEN
          vPaisOrigenId := pPaisOrigenId;
     ELSE NULL;
     END CASE;
     IF (NVL(pExpedienteId,0) > 0 OR NVL(vPaisOrigenId,0) > 0)  THEN
        CATALOGOS.PKG_SBC_CATALOGOS.PR_VALIDA_REGISTRO(CATALOGOS.PKG_SBC_CATALOGOS.kPAIS, 
                                                    'País Origen ID', 
                                                    vPaisOrigenId);   -- NVL(vPaisId,vNicId)); 
     END IF;         
     --FIN Modificación 20210318
     DBMS_OUTPUT.PUT_LINE ('pTipoIdentificacion: '||pTipoIdentificacion);
     HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_CATALOGO_EXISTENCIA_COD(pCtlNmb   => 'Tipo de Identificacion',
                                                                pCtlCd    => pTipoIdentificacion, 
                                                                pCtlCdSup => 'TPIDNTF', 
                                                                pCtlTp    => HOSPITALARIO.PKG_SNH_HOSPITALARIO.kCATCOLECTIVOG, 
                                                                pCodInc   => FALSE);
                                                                
     DBMS_OUTPUT.PUT_LINE ('ANTES DE PR_VALIDA_IDENTF_TIPOS');
     HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_VALIDA_IDENTF_TIPOS(pTipoIdnId  => NULL, 
                                                            pTipoIdnCod => pTipoIdentificacion,
                                                            pTipoPrm    => 'IDNC', 
                                                            pConfig     => vDatos,
                                                            pMsg        => pMsgError,
                                                            pPaisId     => CASE WHEN vPaisOrigenId = 0 THEN 158 ELSE vPaisOrigenId END);  -- NVL(vPaisId,vNicId));
               DBMS_OUTPUT.PUT_LINE ('pMsgError 1: '||pMsgError);                                            
               IF pMsgError IS NOT NULL THEN 
                  pResultado := pMsgError;
                  pMsgError  := pResultado;
                  RAISE eSalidaConError;
               END IF;
              dbms_output.put_line ('Valida si la identificación es valida o no: '||vDatos(8)); 
              CASE vDatos(8) 
              WHEN 0 THEN
                CASE
                WHEN pTipoPersona = HOSPITALARIO.PKG_PERSONA_HOSPITALARIO_DEV.kPrsIdntf THEN   -- vPrsIdnt 
                     pResultado := 'El tipo de identificación ingresado no es permitido para una Persona Identificada.';
                     pMsgError  := pResultado;            
                     RAISE eParametrosInvalidos;
                ELSE NULL;
                END CASE;
              WHEN 1 THEN
                CASE
                WHEN pTipoPersona = HOSPITALARIO.PKG_PERSONA_HOSPITALARIO_DEV.kPrsNIdnt THEN   -- vPrsIdnt 
                     pResultado := 'El tipo de identificación ingresado no es permitido para una Persona no Identificada.';
                     pMsgError  := pResultado;            
                     RAISE eParametrosInvalidos;
                ELSE NULL;
                END CASE;
              ELSE NULL; 
              END CASE;
             <<ValFecha>> 
              BEGIN
               DBMS_OUTPUT.PUT_LINE ('vFechaNac - pFechaNacimiento: '||pFechaNacimiento);
               vFechaNac := FN_OBT_FECNAC_FORMATEADA (pFechaNacimiento);  -- TO_DATE('07/09/1981','DD/MM/RRRR');  --
               DBMS_OUTPUT.PUT_LINE ('vFechaNac: '||vFechaNac);  
               CASE
               WHEN vFechaNac IS NULL THEN
                    pResultado := 'Fecha de nacimiento inválida -> ' ||pFechaNacimiento ;
                    pMsgError  := pResultado;
                    RAISE eParametroNull; 
               ELSE NULL;
               END CASE;
              END ValFecha;
            --DBMS_OUTPUT.PUT_LINE('Configuración Identificación ID >> ' || vDatos(0));
           -- IF NOT (FN_VALIDA_EXISTE_IDENTIFICACION (pExpedienteId, pNumeroIdentificacion)) THEN 
               CATALOGOS.PKG_PR.PR_VALIDA_FECHA('Fecha de Nacimiento', 
                                                pFechaNacimiento,  -- vFechaNac, 
                                                NULL, 
                                                SYSDATE,  --SYSTIMESTAMP, 
                                                TRUE);
              DBMS_OUTPUT.PUT_LINE ('SALE DE PR_VALIDA_FECHA');                                  
                --Procedimiento de Validaciones propias para personas tipo Identificadas
               PR_SBC_MST_C_PRS_IDNTF (pConfIdnt              => vDatos,
                                       pIdentificacion        => pIdentificacion,
                                       pFechaNacimiento       => vFechaNac,
                                       pPaisOrigenId          => CASE WHEN vPaisOrigenId = 0 THEN 158 ELSE vPaisOrigenId END,       -- pPaisOrigenId,
                                       pMunicipioNacimientoId => pMunicipioNacimientoId,
                                       pResultado             => pResultado,
                                       pMsgError              => pMsgError);
                DBMS_OUTPUT.PUT_LINE ('pMsgError 2: '||pMsgError);                         
                IF pMsgError IS NOT NULL THEN 
                   pResultado := pMsgError;
                   pMsgError  := pResultado;
                   RAISE eSalidaConError;
                END IF;
            --END IF;
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;
      pMsgError  := vFirma||pMsgError;
 WHEN eParametrosInvalidos THEN
      pResultado := pResultado;
      pMsgError  := vFirma||pMsgError;
 WHEN eParametroNull THEN
      pResultado := pResultado;       
      pMsgError  := vFirma||pMsgError; 
 WHEN eCoincidencia THEN
      pResultado := pMsgError;
      pMsgError  := vFirma||pResultado;
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al formatear parámetros nombres y/o identificación. '||SQLERRM;
      pMsgError  := vFirma||pResultado||sqlerrm;            
END PR_VALIDA_IDENTIFICACIONES;
--- fin modificaciones para identificaciones 

 PROCEDURE PR_FORMATEAR_PARAMETROS (pExpedienteId          IN SNH_MST_CODIGO_EXPEDIENTE.EXPEDIENTE_ID%TYPE DEFAULT NULL,
                                    pIdentificacion        IN OUT VARCHAR2,
                                    pTipoIdentificacion    IN CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE,
                                    pTipoPersona           IN VARCHAR2 default null,
                                    pPaisOrigenId          IN CATALOGOS.SBC_CAT_PAISES.PAIS_ID%TYPE DEFAULT NULL,
                                    pNombreCompleto        IN OUT VARCHAR2,
                                    pPrimerNombre          IN OUT VARCHAR2,
                                    pSegundoNombre         IN OUT VARCHAR2,
                                    pPrimerApellido        IN OUT VARCHAR2,
                                    pSegundoApellido       IN OUT VARCHAR2,
                                    pMunicipioNacimientoId IN CATALOGOS.SBC_MST_PERSONAS.MUNICIPIO_NACIMIENTO_ID%TYPE,
                                    pFechaNacimiento       IN CATALOGOS.SBC_MST_PERSONAS.FECHA_NACIMIENTO%TYPE,                                    
                                    pResultado             OUT VARCHAR2,
                                    pMsgError              OUT VARCHAR2) IS
 vFirma        varchar2 (100) := 'PKG_SNH_UTILITARIOS.PR_FORMATEAR_PARAMETROS => ';  
 vTipoIdCodigo CATALOGOS.SBC_CAT_CATALOGOS.CODIGO%TYPE;                                  
 BEGIN
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 1');
  pIdentificacion  := REPLACE(REPLACE(REPLACE(TRANSLATE(UPPER(TRIM(pIdentificacion)),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'),'-'),'/'),' ');
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 2');  
 IF (pPrimerNombre IS NOT NULL AND pPrimerApellido IS NOT NULL) THEN
  pPrimerNombre    := CATALOGOS.PKG_PR.FN_VALIDA_CADENA ('Primer Nombre',REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pPrimerNombre,'[ ]+',' '))),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'), kSoloTexto, NULL),50,2,TRUE);         --TRIM(REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pPrimerNombre,'[ ]+',' '))),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'), kSoloTexto, NULL));
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 3');
  pSegundoNombre   := CATALOGOS.PKG_PR.FN_VALIDA_CADENA ('Segundo Nombre',REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pSegundoNombre,'[ ]+',' '))),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'), kSoloTexto, NULL),50,0,FALSE);      --TRIM(REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pSegundoNombre,'[ ]+',' '))),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'), kSoloTexto, NULL));
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 4');
  pPrimerApellido  := CATALOGOS.PKG_PR.FN_VALIDA_CADENA ('Primer Apellido',REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pPrimerApellido,'[ ]+',' '))),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'), kSoloTexto, NULL),50,2,TRUE);     --TRIM(REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pPrimerApellido,'[ ]+',' '))),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'), kSoloTexto, NULL));
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 5');
  pSegundoApellido := CATALOGOS.PKG_PR.FN_VALIDA_CADENA ('Segundo Apellido',REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pSegundoApellido,'[ ]+',' '))),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'), kSoloTexto, NULL),50,0,FALSE);  --TRIM(REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pSegundoApellido,'[ ]+',' '))),'ÁÉÍÓÚÄËÏÖÜ','AEIOUAEIOU'), kSoloTexto, NULL));
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 6');
  HOSPITALARIO.PKG_PERSONA_HOSPITALARIO.PR_FORMATEO_NOMBRES(pPrimerNombre,
                                                            pSegundoNombre,
                                                            pPrimerApellido,
                                                            pSegundoApellido);
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 7');  
  pNombreCompleto := pPrimerApellido||' '||pPrimerNombre;
  
  dbms_output.put_line ('despues de llenar nombre completo');
 END IF; 
  CASE 
  WHEN pIdentificacion IS NOT NULL THEN
       DBMS_OUTPUT.PUT_LINE ('Entra a validaciones identificaciones');
       DBMS_OUTPUT.PUT_LINE ('pIdentificacion: '||pIdentificacion);
       DBMS_OUTPUT.PUT_LINE ('pTipoIdentificacion: '||pTipoIdentificacion);
       DBMS_OUTPUT.PUT_LINE ('pMunicipioNacimientoId: '||pMunicipioNacimientoId);
       DBMS_OUTPUT.PUT_LINE ('pFechaNacimiento: '||TO_CHAR(pFechaNacimiento,'DDMMRR'));
       DBMS_OUTPUT.PUT_LINE ('pFechaNacimiento sin formato: '||pFechaNacimiento);
        PR_VALIDA_IDENTIFICACIONES (pExpedienteId          => pExpedienteId,           
                                    pIdentificacion        => pIdentificacion,        
                                    pTipoIdentificacion    => pTipoIdentificacion,    
                                    pTipoPersona           => pTipoPersona,
                                    pPaisOrigenId          => pPaisOrigenId,
                                    pMunicipioNacimientoId => pMunicipioNacimientoId, 
                                    pFechaNacimiento       => pFechaNacimiento,       
                                    pResultado             => pResultado,             
                                    pMsgError              => pMsgError);              
      IF pMsgError IS NOT NULL THEN
         pResultado := pResultado;
         pMsgError  := pMsgError;
         RAISE eSalidaConError; 
      END IF;  
       --pTipoIdCatalogoId := FN_OBT_COD_CATALOGO (pTipoIdentificacion);
--       HOSPITALARIO.PKG_CATALOGOS_UTIL.PR_CATALOGO_EXISTENCIA_COD(pCtlNmb   => 'Tipo de Identificacion',
--                                                                  pCtlCd    => pTipoIdentificacion, 
--                                                                  pCtlCdSup => 'TPIDNTF', 
--                                                                  pCtlTp    => HOSPITALARIO.PKG_SNH_HOSPITALARIO.kCATCOLECTIVOG, 
--                                                                  pCodInc   => FALSE);
--            dbms_output.put_line ('despues de PR_CATALOGO_EXISTENCIA_COD');      
--            
--      -- CATALOGOS.PKG_SBC_CATALOGOS_V2.PR_VAL_CEDULA_NICARAGUENSE
--       CATALOGOS.PKG_SBC_CATALOGOS.PR_VAL_CEDULA_NICARAGUENSE   (p_NumeroIdentificacion => pIdentificacion,
--                                                                 p_MunicipioNacimiento  => pMunicipioNacimientoId,
--                                                                 p_FechaNacimiento      => TO_CHAR(pFechaNacimiento,'DDMMRR'),
--                                                                 p_Msg                  => pMsgError);     
--       IF pMsgError IS NOT NULL THEN 
--          pResultado := pMsgError; 
--          pMsgError  := pMsgError;
--          RETURN;
--       END IF;                                                                 
                                                              
  ELSE NULL;
  END CASE;
    dbms_output.put_line('PR_FORMATEAR_PARAMETROS 8'); 
 EXCEPTION
 WHEN eSalidaConError THEN 
      pResultado := pResultado;
      pMsgError  := vFirma||pMsgError;
 WHEN eCoincidencia THEN
      pResultado := pMsgError;
      pMsgError  := vFirma||pResultado; 
 WHEN OTHERS THEN
      pResultado := 'Error no controlado al formatear parámetros nombres y/o identificación. ';
      pMsgError  := vFirma||pResultado||sqlerrm;
 END PR_FORMATEAR_PARAMETROS;
 FUNCTION FN_OBT_ESTADO_PREINGRESO (pCodigo IN VARCHAR2) RETURN VARCHAR2 AS
 vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'STSLPRG' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pCodigo AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de estado pre ingreso. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_ESTADO_PREINGRESO; 
 FUNCTION FN_OBT_ESTADO_CAMA (pCodigo IN VARCHAR2) RETURN VARCHAR2 AS
  vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'ESTADOCAMA' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pCodigo AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de estado pre ingreso. '||SQLERRM);     
       RETURN vCatalogoId;
 END FN_OBT_ESTADO_CAMA;
 
 FUNCTION FN_OBT_TIPO_NOTA (pTipoNota IN VARCHAR2) RETURN NUMBER AS
  vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'TPINSTNT' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pTipoNota AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo nota. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_TIPO_NOTA; 
 
FUNCTION FN_OBT_TIPO_NOTA_EVO_TRATA (pTipoNota IN VARCHAR2) RETURN NUMBER AS
  vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
 SELECT CATALOGO_ID
   INTO vCatalogoId
  FROM (
     SELECT A.CATALOGO_ID
      -- INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'TPINSTNTEVT' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pTipoNota AND
            A.PASIVO = 0
      UNION
     SELECT A.CATALOGO_ID
      -- INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = 'TPINSTNTENF' AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pTipoNota AND
            A.PASIVO = 0     
       );
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo nota evolución y tratamiento. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_TIPO_NOTA_EVO_TRATA;  
 
  FUNCTION FN_OBT_CATALOGO_ID (pCodPadre IN VARCHAR2,
                               pCodHijo  IN VARCHAR2) RETURN NUMBER AS
  vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
 BEGIN
     SELECT A.CATALOGO_ID
       INTO vCatalogoId  
       FROM CATALOGOS.SBC_CAT_CATALOGOS A
       JOIN CATALOGOS.SBC_CAT_CATALOGOS B 
         ON A.CATALOGO_SUP = B.CATALOGO_ID AND
            B.CODIGO = pCodPadre AND 
            B.PASIVO = 0
      WHERE A.CODIGO  = pCodHijo AND
            A.PASIVO = 0;
 RETURN vCatalogoId; 
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo nota. '||SQLERRM);     
       RETURN vCatalogoId; 
 END FN_OBT_CATALOGO_ID;

 FUNCTION FN_OBT_DATOS_PAGINACION (pDatosPaginacion IN HOSPITALARIO.PKG_CATALOGOS_UTIL.assoc_array_str_datos ) RETURN var_refcursor AS   --(pQuery IN VARCHAR2) RETURN var_refcursor AS
 vRegistro var_refcursor;
 vQuery vMAX_VARCHAR2;
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
 
 FUNCTION FN_VALIDA_NUMERO (pNombre      IN VARCHAR2,
                            pValor       IN NUMBER,
                            pValMin      IN NUMBER := NULL,
                            pValMax      IN NUMBER := NULL,
                            pRequired    IN BOOLEAN := TRUE)
      RETURN VARCHAR2 AS
      pMsgError   VARCHAR2 (1000);
   BEGIN
      CASE
      WHEN pValor IS NULL THEN
            IF pRequired THEN
               pMsgError := pNombre || ' no puede ser nulo';
            END IF;
      WHEN pValMin IS NOT NULL AND pValor < pValMin THEN
            pMsgError :=
                  pNombre
               || ' no puede ser menor que '
               || TO_CHAR (pValMin)
               || '. ';
      WHEN pValMax IS NOT NULL AND pValor > pValMax THEN
            CASE
               WHEN LENGTH (pMsgError) = 0
               THEN
                  pMsgError :=
                        pNombre
                     || ' no puede ser mayor que '
                     || TO_CHAR (pValMax)
                     || '.';
               ELSE
                  pMsgError :=
                        pMsgError
                     || ' '
                     || pNombre
                     || ' no puede ser mayor que '
                     || TO_CHAR (pValMax)
                     || '.';
            END CASE;
      ELSE pMsgError := NULL;
      END CASE;

      RETURN pMsgError;
   EXCEPTION
      WHEN OTHERS THEN
           RETURN NULL;
   END FN_VALIDA_NUMERO;
   
   FUNCTION FN_GET_UNIDAD_SALUD(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN CATALOGOS.SBC_CAT_UNIDADES_SALUD%ROWTYPE
   IS
   vUndSld      CATALOGOS.SBC_CAT_UNIDADES_SALUD%ROWTYPE;
   BEGIN
       IF pTypeLookUp IS NULL THEN 
        pMsg        := 'No podemos realizar la búsqueda de Unidad de Salud, ya que no se ha específicado el tipo de búsqueda a realizar';
        pMsgDev     := '[FN_GET_UNIDAD_SALUD] No se ha recibido valor en el parámetro de tipo de búsqueda -> ' || pTypeLookUp;
        RETURN NULL;
       END IF;
       IF pArg1 IS NULL OR NVL(pArg1,'')='' THEN 
        pMsg        := 'No podemos realizar la búsqueda de Unidad de Salud, ya que no se ha específicado el criterio principal para realizar la búsqueda';
        pMsgDev     := '[FN_GET_UNIDAD_SALUD] No se ha recibido el criterio de búsqueda para realizar la búsqueda, ya sea Id, etc.';
        RETURN NULL;
       END IF;
    CASE pTypeLookUp
        WHEN PKG_SNH_UTILITARIOS.K_ID THEN
            BEGIN
                SELECT * INTO vUndSld FROM CATALOGOS.SBC_CAT_UNIDADES_SALUD WHERE UNIDAD_SALUD_ID = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La búsqueda de Unidad de Salud, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_UNIDAD_SALUD] La búsqueda de Unidad de Salud, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La búsqueda de Unidad de Salud, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    pMsgDev     := '[FN_GET_UNIDAD_SALUD] La búsqueda de Unidad de Salud, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La búsqueda de Unidad de Salud, por ID: ' || pArg1 || ', no se puede realizar de momento, intente más tarde';
                    pMsgDev     := '[FN_GET_UNIDAD_SALUD] '|| SQLERRM;
                    RETURN NULL;
            END;
        ELSE 
            pMsg        := 'La búsqueda de Unidad de Salud, de tipo: ' || pTypeLookUp || ', no existe';
            pMsgDev     := '[FN_GET_UNIDAD_SALUD] La búsqueda de Unidad de Salud, de tipo: ' || pTypeLookUp || ', no existe';
                    RETURN NULL;
    END CASE;
   RETURN vUndSld;
   END FN_GET_UNIDAD_SALUD;
   
   FUNCTION FN_GET_USER(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN SEGURIDAD.SCS_MST_USUARIOS%ROWTYPE
   IS
   vUsrRow        SEGURIDAD.SCS_MST_USUARIOS%ROWTYPE;
   BEGIN
       IF pTypeLookUp IS NULL THEN 
        pMsg        := 'No podemos realizar la búsqueda de Usuario, ya que no se ha específicado el tipo de búsqueda a realizar';
        pMsgDev     := '[FN_GET_USER] No se ha recibido valor en el parámetro de tipo de búsqueda -> ' || pTypeLookUp;
        RETURN NULL;
       END IF;
       IF pArg1 IS NULL OR NVL(pArg1,'')='' THEN 
        pMsg        := 'No podemos realizar la búsqueda de Usuario, ya que no se ha específicado el criterio principal para realizar la búsqueda';
        pMsgDev     := '[FN_GET_USER] No se ha recibido el criterio de búsqueda para realizar la búsqueda, ya sea Id, etc.';
        RETURN NULL;
       END IF;
    CASE pTypeLookUp
        WHEN PKG_SNH_UTILITARIOS.K_ID THEN
            BEGIN
                SELECT * INTO vUsrRow FROM SEGURIDAD.SCS_MST_USUARIOS WHERE USUARIO_ID = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La búsqueda de Usuario, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_USER] La búsqueda de Usuario, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La búsqueda de Usuario, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    pMsgDev     := '[FN_GET_USER] La búsqueda de Usuario, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La búsqueda de Usuario por ID: ' || pArg1 || ', no se puede realizar de momento, intente más tarde';
                    pMsgDev     := '[FN_GET_USER] '|| SQLERRM;
                    RETURN NULL;
            END;
        WHEN PKG_SNH_UTILITARIOS.K_LKUSR_USERNAME THEN
            BEGIN

                SELECT * INTO vUsrRow FROM SEGURIDAD.SCS_MST_USUARIOS WHERE USERNAME = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La búsqueda de Usuario, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_USER] La búsqueda de Usuario, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La búsqueda de Usuario, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    pMsgDev     := '[FN_GET_USER] La búsqueda de Usuario, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La búsqueda de Usuario por ID: ' || pArg1 || ', no se puede realizar de momento, intente más tarde';
                    pMsgDev     := '[FN_GET_USER] '|| SQLERRM;
                    RETURN NULL;
            END;
        ELSE 
            pMsg        := 'La búsqueda de Usuario, de tipo: ' || pTypeLookUp || ', no existe';
            pMsgDev     := '[FN_GET_USER] La búsqueda de Usuario, de tipo: ' || pTypeLookUp || ', no existe';
                    RETURN NULL;
    END CASE;
    RETURN vUsrRow;
   END FN_GET_USER;
   
   FUNCTION FN_GET_SYSTEM(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN SEGURIDAD.SCS_CAT_SISTEMAS%ROWTYPE
   IS
   vSysRow        SEGURIDAD.SCS_CAT_SISTEMAS%ROWTYPE;
   BEGIN
       IF pTypeLookUp IS NULL THEN 
        pMsg        := 'No podemos realizar la búsqueda de Sistema, ya que no se ha específicado el tipo de búsqueda a realizar';
        pMsgDev     := '[FN_GET_SYSTEM] No se ha recibido valor en el parámetro de tipo de búsqueda -> ' || pTypeLookUp;
        RETURN NULL;
       END IF;
       IF pArg1 IS NULL OR NVL(pArg1,'')='' THEN 
        pMsg        := 'No podemos realizar la búsqueda de Sistema, ya que no se ha específicado el criterio principal para realizar la búsqueda';
        pMsgDev     := '[FN_GET_SYSTEM] No se ha recibido el criterio de búsqueda para realizar la búsqueda, ya sea Id, etc.';
        RETURN NULL;
       END IF;
    CASE pTypeLookUp
        WHEN PKG_SNH_UTILITARIOS.K_ID THEN
            BEGIN
                SELECT * INTO vSysRow FROM SEGURIDAD.SCS_CAT_SISTEMAS WHERE SISTEMA_ID = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La búsqueda de Sistema, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_SYSTEM] La búsqueda de Sistema, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La búsqueda de Sistema, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    pMsgDev     := '[FN_GET_SYSTEM] La búsqueda de Sistema, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La búsqueda de Sistema por ID: ' || pArg1 || ', no se puede realizar de momento, intente más tarde';
                    pMsgDev     := '[FN_GET_SYSTEM] '|| SQLERRM;
                    RETURN NULL;
            END;
        WHEN PKG_SNH_UTILITARIOS.K_VLD_CODE THEN
            BEGIN
                SELECT * INTO vSysRow FROM SEGURIDAD.SCS_CAT_SISTEMAS WHERE CODIGO = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La búsqueda de Sistema, por Código: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_SYSTEM] La búsqueda de Sistema, por Código: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La búsqueda de Sistema, por Código: ' || pArg1 || ', genera múltiples coincidencias';
                    pMsgDev     := '[FN_GET_SYSTEM] La búsqueda de Sistema, por Código: ' || pArg1 || ', genera múltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La búsqueda de Sistema por Código: ' || pArg1 || ', no se puede realizar de momento, intente más tarde';
                    pMsgDev     := '[FN_GET_SYSTEM] '|| SQLERRM;
                    RETURN NULL;
            END;
        ELSE 
            pMsg        := 'La búsqueda de Sistema, de tipo: ' || pTypeLookUp || ', no existe';
            pMsgDev     := '[FN_GET_SYSTEM] La búsqueda de Sistema, de tipo: ' || pTypeLookUp || ', no existe';
                    RETURN NULL;
    END CASE;
    RETURN vSysRow;
   END FN_GET_SYSTEM;
   
   FUNCTION FN_GET_COMUNIDAD(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN CATALOGOS.SBC_CAT_COMUNIDADES%ROWTYPE
   IS
   vCmndRow        CATALOGOS.SBC_CAT_COMUNIDADES%ROWTYPE;
   BEGIN
       IF pTypeLookUp IS NULL THEN 
        pMsg        := 'No podemos realizar la búsqueda de la Comunidad, ya que no se ha específicado el tipo de búsqueda a realizar';
        pMsgDev     := '[FN_GET_COMUNIDAD] No se ha recibido valor en el parámetro de tipo de búsqueda -> ' || pTypeLookUp;
        RETURN NULL;
       END IF;
       IF pArg1 IS NULL OR NVL(pArg1,'')='' THEN 
        pMsg        := 'No podemos realizar la búsqueda de la Comunidad, ya que no se ha específicado el criterio principal para realizar la búsqueda';
        pMsgDev     := '[FN_GET_COMUNIDAD] No se ha recibido el criterio de búsqueda para realizar la búsqueda, ya sea Id, etc.';
        RETURN NULL;
       END IF;
    CASE pTypeLookUp
        WHEN PKG_SNH_UTILITARIOS.K_ID THEN
            BEGIN
                SELECT * INTO vCmndRow FROM CATALOGOS.SBC_CAT_COMUNIDADES WHERE COMUNIDAD_ID = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La búsqueda de Comunidad, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_COMUNIDAD] La búsqueda de Comunidad, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La búsqueda de Comunidad, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    pMsgDev     := '[FN_GET_COMUNIDAD] La búsqueda de Comunidad, por ID: ' || pArg1 || ', genera múltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La búsqueda de Comunidad por ID: ' || pArg1 || ', no se puede realizar de momento, intente más tarde';
                    pMsgDev     := '[FN_GET_COMUNIDAD] '|| SQLERRM;
                    RETURN NULL;
            END;
        WHEN PKG_SNH_UTILITARIOS.K_VLD_CODE THEN
            BEGIN
                SELECT * INTO vCmndRow FROM CATALOGOS.SBC_CAT_COMUNIDADES WHERE CODIGO = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La búsqueda de Comunidad, por Código: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_COMUNIDAD] La búsqueda de Comunidad, por Código: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La búsqueda de Comunidad, por Código: ' || pArg1 || ', genera múltiples coincidencias';
                    pMsgDev     := '[FN_GET_COMUNIDAD] La búsqueda de Comunidad, por Código: ' || pArg1 || ', genera múltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La búsqueda de Comunidad por Código: ' || pArg1 || ', no se puede realizar de momento, intente más tarde';
                    pMsgDev     := '[FN_GET_COMUNIDAD] '|| SQLERRM;
                    RETURN NULL;
            END;
        ELSE 
            pMsg        := 'La búsqueda de Comunidad, de tipo: ' || pTypeLookUp || ', no existe';
            pMsgDev     := '[FN_GET_COMUNIDAD] La búsqueda de Comunidad, de tipo: ' || pTypeLookUp || ', no existe';
                    RETURN NULL;
    END CASE;
    RETURN vCmndRow;
   END FN_GET_COMUNIDAD;
   
   FUNCTION FN_GET_FEC_NACIMIENTO_PERSONA (pPerNominalId IN CATALOGOS.SBC_MST_PERSONAS_NOMINAL.PER_NOMINAL_ID%TYPE) RETURN DATE AS
   vContador PLS_INTEGER := 0;
   vFecNacimiento CATALOGOS.SBC_MST_PERSONAS_NOMINAL.FECHA_NACIMIENTO%TYPE;
   BEGIN
    CASE
    WHEN NVL(pPerNominalId,0)> 0 THEN
         BEGIN
         SELECT COUNT (1) 
           INTO vContador
           FROM CATALOGOS.SBC_MST_PERSONAS_NOMINAL
          WHERE PER_NOMINAL_ID = pPerNominalId AND
                FECHA_NACIMIENTO IS NOT NULL;
         
             CASE
             WHEN vContador > 0 THEN
                  BEGIN
                     SELECT FECHA_NACIMIENTO
                       INTO vFecNacimiento
                       FROM CATALOGOS.SBC_MST_PERSONAS_NOMINAL
                      WHERE PER_NOMINAL_ID = pPerNominalId;
                  END;
             ELSE NULL;
             END CASE;
         END;      
    ELSE NULL;
    END CASE;
   RETURN vFecNacimiento; 
   EXCEPTION
   WHEN OTHERS THEN
        RETURN vFecNacimiento;
   END;   

 PROCEDURE PR_GRUPO_ETAREO (pCodEventoId   IN NUMBER,
                            pFecNacimiento IN DATE,
                            pCodigo        IN VARCHAR2,
                            pGrupoEtareoId OUT NUMBER,
                            pResultado     OUT VARCHAR2,
                            pMsgError      OUT VARCHAR2) IS
 vFirma         varchar2(100) := 'PKG_SNH_UTILITARIOS.PR_GRUPO_ETAREO => ';
 vEdadCalculada VARCHAR2(7);
 vCnfCatalogoId HOSPITALARIO.SNH_CNF_GRUPO_EVENTOS_HOSP.CATALOGO_CNF_ID%TYPE;
 BEGIN
    SELECT CATALOGO_CNF_ID 
      INTO vCnfCatalogoId 
      FROM HOSPITALARIO.SNH_CNF_GRUPO_EVENTOS_HOSP 
     WHERE EVENTO_ID = pCodEventoId AND 
           CODIGO_TIPO_CATALOGO = pCodigo;
     dbms_output.put_line ('vCnfCatalogoId: '||vCnfCatalogoId);      
     vEdadCalculada := HOSPITALARIO.PKG_CATALOGOS_UTIL.FN_FECHA_NACIMIENTO(pFecNacimiento);
     dbms_output.put_line ('vEdadCalculada: '||vEdadCalculada);
     IF vEdadCalculada IS NULL THEN
        pResultado := 'Error presentado al tratar de calcular la edad';
        pMsgError  := pResultado;
        RAISE eSalidaConError;
     END IF;      
     
     pGrupoEtareoId := HOSPITALARIO.PKG_SNH_PACIENTE_V2.CALCULAR_RANGO_PX(vEdadCalculada, vCnfCatalogoId, pCodigo, pMsgError);
     dbms_output.put_line ('pGrupoEtareoId: '||pGrupoEtareoId);
                     CASE 
                     WHEN pMsgError IS NOT NULL AND LENGTH(TRIM(pMsgError)) > 0 THEN
                          pResultado := pMsgError;
                          pMsgError  := pMsgError;
                          RAISE eSalidaConError;
                     ELSE NULL;
                     END CASE;
                     CASE
                     WHEN pGrupoEtareoId IS NULL THEN
                          pResultado := 'No se le pudo asignar valor a variable Grupo etareo';
                          pMsgError  := pResultado;
                          RAISE eParametroNull;
                     ELSE NULL;
                     END CASE;
 
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        pResultado := 'No se encontró registro asociado a parámetro [pCodEvento: '||pCodEventoId||']';     
        pMsgError  := vFirma||pResultado;
   WHEN TOO_MANY_ROWS THEN
        pResultado := 'Se encontró mas de un registro asociado a parámetro [pCodEventoId: '||pCodEventoId||']';     
        pMsgError  := vFirma||pResultado; 
   WHEN eParametroNull THEN
        pResultado := pResultado; 
        pMsgError  := vFirma||pMsgError; 
   WHEN eSalidaConError THEN
        pResultado := pResultado;
        pMsgError  := vFirma||pMsgError;        
   WHEN OTHERS THEN
        pResultado := 'Error no controlado al querer obtener variable grupo etareo';      
        pMsgError  :=  vFirma||pResultado||' - '||sqlerrm;
        DBMS_SESSION.reset_package;
 END PR_GRUPO_ETAREO; 
 
 FUNCTION FN_OBT_FORMATO_HR_BASE (pHrBase IN NUMBER) RETURN NUMBER AS
 vHrBase NUMBER;
 BEGIN
     CASE
     WHEN pHrBase = 0 THEN
          vHrBase := 24;
     WHEN pHrBase = 1 THEN
          vHrBase := 25;      
     WHEN pHrBase = 2 THEN
          vHrBase := 26;
     WHEN pHrBase = 3 THEN
          vHrBase := 27;
     WHEN pHrBase = 4 THEN
          vHrBase := 28;
     WHEN pHrBase = 5 THEN
          vHrBase := 29;
     WHEN pHrBase = 6 THEN
          vHrBase := 30;
     WHEN pHrBase = 7 THEN
          vHrBase := 31;
     WHEN pHrBase = 8 THEN
          vHrBase := 32;
     WHEN pHrBase = 9 THEN
          vHrBase := 33;
     WHEN pHrBase = 10 THEN
          vHrBase := 34;
     WHEN pHrBase = 11 THEN
          vHrBase := 35;
     WHEN pHrBase = 12 THEN
          vHrBase := 36;
     WHEN pHrBase = 13 THEN
          vHrBase := 37;                                                                                                                                                                  
     WHEN pHrBase = 14 THEN
          vHrBase := 38;
     WHEN pHrBase = 15 THEN
          vHrBase := 39;
     WHEN pHrBase = 16 THEN
          vHrBase := 40;
     WHEN pHrBase = 17 THEN
          vHrBase := 41;
     WHEN pHrBase = 18 THEN
          vHrBase := 42;
     WHEN pHrBase = 19 THEN
          vHrBase := 43;
     WHEN pHrBase = 20 THEN
          vHrBase := 44;
     WHEN pHrBase = 21 THEN
          vHrBase := 45;
     WHEN pHrBase = 22 THEN
          vHrBase := 46;
     WHEN pHrBase = 23 THEN
          vHrBase := 47;
     ELSE NULL;
     END CASE;
     RETURN vHrBase; 
 END FN_OBT_FORMATO_HR_BASE;
 
 FUNCTION FN_OBT_EDAD_EN_BASE_A_FECHA (pFechaNacimiento IN DATE,
                                       pFechaBase       IN DATE,
                                       pHoraBase        IN VARCHAR2) RETURN VARCHAR2 AS
 vAnios CHAR(3);
 vMeses CHAR(2);
 vDias             CHAR(2);
 vRetorna          VARCHAR2 (20);
 vHrBase           VARCHAR2(3);
 vHrNacimiento     NUMBER;
 vHrsTranscurridas NUMBER;
 vYears            vMAX_VARCHAR2 := LPAD (0, 3, '0') ; 
 vMonths           vMAX_VARCHAR2 := LPAD (0, 2, '0');
 vDays             vMAX_VARCHAR2 := LPAD (0, 2, '0');
 vHoras            vMAX_VARCHAR2 := LPAD (0, 2, '0');
 BEGIN
   SELECT LPAD (TRUNC (MONTHS_BETWEEN (pFechaBase, fnf) / 12), 3, '0') YEARS,
          LPAD (TRUNC (MOD (MONTHS_BETWEEN (pFechaBase, fnf), 12)), 2, '0') MONTHS,
          LPAD (TRUNC (pFechaBase - ADD_MONTHS (fnf,TRUNC (MONTHS_BETWEEN (pFechaBase , fnf) / 12) * 12
              + TRUNC (MOD (MONTHS_BETWEEN (pFechaBase, fnf), 12)))),2,'0') DAYS
   INTO vAnios,vMeses,vDias             
  FROM (SELECT pFechaNacimiento fnf 
   FROM DUAL);
      DBMS_OUTPUT.PUT_LINE (vAnios||vMeses||vDias||vHoras);
      
      CASE
      WHEN TO_NUMBER(vAnios||vMeses||vDias) > 0 THEN
           vRetorna := vAnios||vMeses||vDias||vHoras;
           DBMS_OUTPUT.PUT_LINE ('Entra a validar 1');
      WHEN pHoraBase IS NOT NULL THEN
           DBMS_OUTPUT.PUT_LINE ('pHoraBase: '||pHoraBase);
           vHrBase       := SUBSTR(pHoraBase,1,2);
           vHrNacimiento := TO_NUMBER(TO_CHAR(pFechaNacimiento,'hh24'));
           DBMS_OUTPUT.PUT_LINE ('Entra a validar 2');
           DBMS_OUTPUT.PUT_LINE ('vHrBase: '||vHrBase);
           DBMS_OUTPUT.PUT_LINE ('vHrNacimiento: '||vHrNacimiento);
            CASE
            WHEN TO_NUMBER(vHrBase) > 0 AND vHrNacimiento > 0 THEN
                 CASE
                 WHEN TO_NUMBER(vHrBase) > vHrNacimiento THEN
                      vHrsTranscurridas := TO_NUMBER(vHrBase) - vHrNacimiento;
                 ELSE 
                      vHrBase := FN_OBT_FORMATO_HR_BASE (TO_NUMBER(vHrBase));
                      vHrsTranscurridas := TO_NUMBER(vHrBase) - vHrNacimiento;
                 END CASE;
            ELSE NULL;
            END CASE;
            vRetorna := vYears||vMonths||vDays||LPAD(vHrsTranscurridas, 2, '0');    
      ELSE NULL;
      END CASE;
     -- RETURN vAnios||vMeses||vDias; 
     RETURN vRetorna; 
 END FN_OBT_EDAD_EN_BASE_A_FECHA;
END PKG_SNH_UTILITARIOS;
/