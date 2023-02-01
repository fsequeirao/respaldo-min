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
         --DBMS_OUTPUT.PUT_LINE('Fecha de Nacimiento de la C�dula: ' || vFechaNacimiento);
         EXCEPTION
            WHEN OTHERS
            THEN
               CATALOGOS.PKG_PR.PR_GENERAR_ERROR (
                  'N�mero de C�dula, inv�lida 1');
         END nValidadorFechaNac;

        <<nValidadorMunicipio>>
         BEGIN
            IF    SUBSTR (p_NumeroIdentificacion, 0, 3) = '888'
               OR SUBSTR (p_NumeroIdentificacion, 0, 3) = '777'
            THEN
               NULL;
            ELSE
               --DBMS_OUTPUT.PUT_LINE('[MUNICIPIO] C�digo CSE '||SUBSTR(p_NumeroIdentificacion,0,3));
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
                  'N�mero de C�dula, inv�lida 2');
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
                  'N�mero de C�dula, inv�lida2 3');
            END IF;
            END;

         EXCEPTION
            WHEN OTHERS
            THEN
               CATALOGOS.PKG_PR.PR_GENERAR_ERROR (
                  'N�mero de C�dula, inv�lida3');
         END nValidaUltimoCaracter;
      --DBMS_OUTPUT.PUT_LINE('Fecha Nacimiento: ' || vFechaNacimiento);
      --DBMS_OUTPUT.PUT_LINE('N�mero de C�dula V�lida');
      ELSE
         CATALOGOS.PKG_PR.PR_GENERAR_ERROR ('N�mero de C�dula, inv�lida4');
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
               'N�mero de C�dula, inv�lida5');
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
       HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'En el proceso de validaci�n de estado del registro se requiere el Estado actual del registro',  
                                                           PMSGDEV => '[FN_ALLOW_ACTION_STATE] Especificar el valor del Estado actual del registro' );
    END IF;
    IF pAction IS NULL THEN
        HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'En el proceso de validaci�n de estado del registro se requiere especificar la acci�n que se intenta realizar',  
                                                            PMSGDEV => '[FN_ALLOW_ACTION_STATE] Especificar el tipo de acci�n que se le desea aplicar al registro' );
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
        pMsg        := 'Ha ocurrido un error inesperado en el proceso de validaci�n de la acci�n a realizar para el registro de tipo de '|| pName;
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
        IF (pName IS NULL ) THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo, requerimos especifique un nombre',  
                                                                                        PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Nombre del cat�logo a evaluar no ha sido ingresado' );
        END IF;
        IF (pCrto IS NULL ) THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo, requerimos especifique su C�digo',  
                                                                                        PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] C�digo del cat�logo a evaluar no ha sido ingresado' );
        END IF;
        IF (pTypeValidation IS NULL ) THEN      HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo, requerimos especifique el tipo de validaci�n a realizar',  
                                                                                        PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] El tipo de validaci�n que se le aplicar� al cat�logo a evaluar no ha sido ingresado' );
        END IF;
        CASE pTypeValidation
            WHEN K_VAL_CAT_CHIELD_ID THEN
                IF ( pCodeParent IS NULL ) THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo ' || pName || ' - CODIGO: ' || pCrto || ', tambi�n se requiere el nombre C�digo del Cat�logo Superior', 
                                                                                                    PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Para validar el Cat�logo -> [' || pName || ' - CODIGO -> ' || pCrto || '], requerimos especifique el c�digo del Catalogo Padre' );
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
                EXCEPTION   WHEN  VALUE_ERROR_CONVERT THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El ID ingresado: ' || NVL(pCrto, '0') || ', no es un valor num�rico', 
                                                                                                            PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] Error en la conversi�n del ID recibido -> ' || NVL(pCrto, '0'));
                            WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con ID: ' || pCrto || ', y c�digo superior: ' || pCodeParent || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CATALOGO_ID -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD_ID || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent || ', genera m�ltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] M�ltiples coincidencias con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD_ID || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el cat�logo: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent, 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT_CHIELD THEN
                IF ( pCodeParent IS NULL ) THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Para validar el Cat�logo -> [' || pName || ' - CODIGO -> ' || pCrto || '], requerimos especifique el c�digo del Catalogo Padre', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] El valor del [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', es un valor requerido para evaluar el cat�logo CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
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
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] El valor del [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', y CODIGO_DEP -> ' || pCrto || '], No genera coincidencias. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent || ', genera m�ltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] M�ltiples coincidencias con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el cat�logo: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent, 
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
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo Superior evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_PARENT || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo Superior evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', genera m�ltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] M�ltiples coincidencias con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_PARENT || ']'); 
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el cat�logo Superior: ' || pName || ', identificado con c�digo: ' || pCrto, 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT THEN
                BEGIN
                    SELECT a.* 
                      INTO vCatalogoResult 
                      FROM CATALOGOS.SBC_CAT_CATALOGOS a 
                     WHERE a.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT || ']');

                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', genera m�ltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] M�ltiples coincidencias con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el cat�logo: ' || pName || ', identificado con c�digo: ' || pCrto, 
                                                                                                     PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] ' || SQLERRM); 
                END;
            ELSE
                HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo, requerimos especifique el tipo de validaci�n a realizar', 
                                                                    PMSGDEV => '[FN_VAL_CAT_BY_CODE_ID] El tipo de validaci�n que se le aplicar� al cat�logo a evaluar no ha sido ingresado');              
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
        IF (pName IS NULL ) THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo, requerimos especifique un nombre',
                                                                                        PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Nombre del cat�logo a evaluar no ha sido ingresado' );
        END IF;
        IF (pCrto IS NULL ) THEN    HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo, requerimos especifique su C�digo',  
                                                                                        PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] C�digo del cat�logo a evaluar no ha sido ingresado' );
        END IF;
        IF (pTypeValidation IS NULL ) THEN      HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo, requerimos especifique el tipo de validaci�n a realizar',  
                                                                                        PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] El tipo de validaci�n que se le aplicar� al cat�logo a evaluar no ha sido ingresado' );
        END IF;
        CASE pTypeValidation
            WHEN K_VAL_CAT_CHIELD_ID THEN
                IF ( pCodeParent IS NULL ) THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo ' || pName || ' - CODIGO: ' || pCrto || ', tambi�n se requiere el nombre C�digo del Cat�logo Superior', 
                                                                                                    PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Para validar el Cat�logo -> [' || pName || ' - CODIGO -> ' || pCrto || '], requerimos especifique el c�digo del Catalogo Padre' );
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
                EXCEPTION   WHEN  VALUE_ERROR_CONVERT THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El ID ingresado: ' || NVL(pCrto, '0') || ', no es un valor num�rico', 
                                                                                                            PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] Error en la conversi�n del ID recibido -> ' || NVL(pCrto, '0'));
                            WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con ID: ' || pCrto || ', y c�digo superior: ' || pCodeParent || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CATALOGO_ID -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD_ID || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent || ', genera m�ltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] M�ltiples coincidencias con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD_ID || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el cat�logo: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent, 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT_CHIELD THEN
                IF ( pCodeParent IS NULL ) THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Para validar el Cat�logo -> [' || pName || ' - CODIGO -> ' || pCrto || '], requerimos especifique el c�digo del Catalogo Padre', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] El valor del [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', es un valor requerido para evaluar el cat�logo CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                END IF;
                BEGIN
                    SELECT b.* INTO vCatalogoResult FROM HOSPITALARIO.SNH_CAT_CATALOGOS a INNER JOIN HOSPITALARIO.SNH_CAT_CATALOGOS b
                    ON b.CATALOGO_SUP = a.CATALOGO_ID WHERE b.CATALOGO_SUP IS NOT NULL AND a.CODIGO = pCodeParent
                    AND b.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] El valor del [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', y CODIGO_DEP -> ' || pCrto || '], No genera coincidencias. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent || ', genera m�ltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] M�ltiples coincidencias con los siguientes Valores [ CODIGO_SUP -> ' || pCodeParent || 
                                                                                                                ', CODIGO_DEP -> ' || pCrto || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_CHIELD || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el cat�logo: ' || pName || ', identificado con c�digo: ' || pCrto || ', y c�digo superior: ' || pCodeParent, 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT_PARENT THEN
                BEGIN
                    SELECT a.* INTO vCatalogoResult FROM HOSPITALARIO.SNH_CAT_CATALOGOS a 
                    WHERE a.CATALOGO_SUP IS NULL AND a.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo Superior evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_PARENT || ']');
                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo Superior evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', genera m�ltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] M�ltiples coincidencias con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT_PARENT || ']'); 
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el cat�logo Superior: ' || pName || ', identificado con c�digo: ' || pCrto, 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] ' || SQLERRM);
                END;
            WHEN K_VAL_CAT THEN
                BEGIN
                    SELECT a.* INTO vCatalogoResult FROM HOSPITALARIO.SNH_CAT_CATALOGOS a 
                    WHERE a.CODIGO = pCrto;
                    RETURN  vCatalogoResult;
                EXCEPTION   WHEN NO_DATA_FOUND THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', no genera coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] No se genera coincidencia con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT || ']');

                            WHEN TOO_MANY_ROWS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'El cat�logo evaluado: ' || pName || ', identificado con c�digo: ' || pCrto || ', genera m�ltiples coincidencias', 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] M�ltiples coincidencias con los siguientes Valores [ CODIGO -> ' || pCodeParent || '], favor de Validar. [PTYPEVALIDATION -> ' || K_VAL_CAT || ']');
                            WHEN OTHERS THEN HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(PMSG => 'Error inesperado al intentar evaluar el cat�logo: ' || pName || ', identificado con c�digo: ' || pCrto, 
                                                                                                     PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] ' || SQLERRM); 
                END;
            ELSE
                HOSPITALARIO.PKG_CORE_PRS.PR_GENERATE_CUSTOM_ERROR(   PMSG => 'Para validar el C�talogo, requerimos especifique el tipo de validaci�n a realizar', 
                                                                    PMSGDEV => '[FN_H_VAL_CAT_BY_CODE_ID] El tipo de validaci�n que se le aplicar� al cat�logo a evaluar no ha sido ingresado');              
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
        --        pMsg        := 'Inconvenientes con la validaci�n de exitencia de registro';
        --        pMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
        --                          ' la entidad a evaluar o el tipo validaci�n';
        vMsg        := 'Inconvenientes con la validaci�n de exitencia de registro';
        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                          ' la entidad a evaluar o el tipo validaci�n';
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
                    vMsg            := 'La b�squeda de Expediente Base ' || pArg1 || ', no genera coincidencias';
                    vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Expediente Base ID ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Paciente ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                                          ' la entidad a evaluar o el tipo validaci�n';
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
                        vMsg            := 'La b�squeda de Expediente Electr�nico ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                                          ' la entidad a evaluar o el tipo validaci�n';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_VLD_CODE THEN
                    SELECT COUNT(EXPEDIENTE_ID) INTO vCount FROM HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE WHERE CODIGO_EXPEDIENTE_ELECTRONICO = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Expediente Electr�nico ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                                          ' la entidad a evaluar o el tipo validaci�n';
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
                        vMsg            := 'La b�squeda de C�digo Expediente Electr�nico Hist�rico ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                                          ' la entidad a evaluar o el tipo validaci�n';
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
                        vMsg            := 'La b�squeda de C�digo Expediente Local por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de C�digo Expediente Local por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_EXP_LOCALES A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Expediente Local, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Expediente Local, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Programa por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Programa por su ID: ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Programa por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Programa por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_PROGRAMAS A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Programa, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Programa, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Caracteristica de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Caracteristica de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_CARACTERISTICAS A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda Caracteristica de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Caracteristica de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_DET_PX_CRCT THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_CARACTERISTICAS A WHERE A.PACIENTE_ID = pArg1 AND A.CARACTERISTICA_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda Caracteristica de Paciente, para el Paciente con ID: ' || pArg1 || ', y caracteristica ID: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Caracteristica de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Contactos de Pacientes por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Contactos de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_CONTACTOS_anterior A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda Contactos de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Contactos de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Financiamientos de Pacientes por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Financiamientos de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_FINANCIAMIENTOS A WHERE A.PACIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda Financiamientos de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Financiamientos de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_DET_PX_FNMC THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_FINANCIAMIENTOS A WHERE A.PACIENTE_ID = pArg1 AND FUENTE_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda Financiamientos de Paciente, para el Paciente con ID: ' || pArg1 || ', y Fuente de Financiamiento ID: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Financiamientos de Paciente, para el Paciente con ID: ' || pArg1 || ', y Fuente de Financiamiento ID: ' || pArg2 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_FNMC_CODE THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_FINANCIAMIENTOS A WHERE A.FUENTE_ID = pArg1 AND A.CODIGO_AFILIACION = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda Financiamientos Tipo ID: ' || pArg1 || ', y C�digo de Afiliaci�n: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda Financiamientos Tipo ID: ' || pArg1 || ', y C�digo de Afiliaci�n: ' || pArg2 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Identificacion de Pacientes por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Identificacion de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_MST_PACIENTES THEN

                     -- SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_IDENTIFICACIONES A WHERE A.PACIENTE_ID = pArg1;
                      SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PER_IDENTIFICACIONES A WHERE A.EXPEDIENTE_ID = pArg1;

                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Identificaciones de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Identificaciones de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_DET_PX_IDNT THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_IDENTIFICACIONES A WHERE A.PACIENTE_ID = pArg1 AND TIPO_IDENTIFICACION_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Identificaciones de Paciente, para el Paciente con ID: ' || pArg1 || ', e Identificaci�n ID: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Identificaciones de Paciente, para el Paciente con ID: ' || pArg1 || ', e Identifficaci�n ID: ' || pArg2 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                WHEN K_DET_XP_IDNT THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PER_IDENTIFICACIONES A WHERE A.EXPEDIENTE_ID = pArg1 AND TIPO_IDENTIFICACION_ID = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Identificaciones de Paciente, para el Paciente con Expediente ID: ' || pArg1 || ', e Identificaci�n ID: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Identificaciones de Paciente, para el Paciente con Expediente ID: ' || pArg1 || ', e Identifficaci�n ID: ' || pArg2 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;

                WHEN K_IDNTF_CODE THEN

                     SELECT COUNT(1) INTO vCount FROM HOSPITALARIO.SNH_DET_PX_IDENTIFICACIONES A WHERE A.TIPO_IDENTIFICACION_ID = pArg1 AND A.IDENTIFICACION = pArg2;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Identificaciones de Pacientes, tipo de Identificaci�n ID: ' || pArg1 || ', y n�mero de Identificaci�n: ' || pArg2 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Identificaciones de Pacientes, tipo de Identificaci�n ID: ' || pArg1 || ', y n�mero de Identificaci�n: ' || pArg2 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Residencia de Pacientes por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Residencia de Paciente por su ID: ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda Residencias de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Residencias de Paciente, para el Paciente con ID: ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;

                WHEN K_MST_COD_EXP THEN
                     SELECT COUNT(A.DET_PRS_RESIDENCIA_ID) INTO vCount FROM CATALOGOS.SBC_DET_PRS_RESIDENCIA A WHERE A.EXPEDIENTE_ID = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda Residencias de Residencia, para el Expediente ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Residencias de Paciente, identificado con Expediente ID: ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Unidad de Salud por su ID: ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW] La b�squeda de Unidad de Salud por su ID: ' || pArg1 || ', no genera coincidencias';
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
        vMsg        := 'Inconvenientes con la validaci�n de exitencia de registro';
        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] No se puede evaluar la existencia del registro, ya que no se ha definido ' || 
                          ' la entidad a evaluar o el tipo validaci�n';
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
                        vMsg            := 'La b�squeda de Usuario con ID ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] La b�squeda de Usuario con ID ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;
                --K_LKUSR_USERNAME    
                WHEN K_LKUSR_USERNAME THEN

                    SELECT COUNT(USUARIO_ID) INTO vCount FROM SEGURIDAD.SCS_MST_USUARIOS WHERE USERNAME = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Usuario con username ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] La b�squeda de Usuario con username ' || pArg1 || ', no genera coincidencias';
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
                        vMsg            := 'La b�squeda de Sistema con ID ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] La b�squeda de Sistema con ID ' || pArg1 || ', no genera coincidencias';
                        PR_GENERATE_CUSTOM_ERROR(vMsg, vMsgDev);
                        --RETURN FALSE; 
                    END IF;

                WHEN K_LKSYS_CODE THEN

                    SELECT COUNT(SISTEMA_ID) INTO vCount FROM SEGURIDAD.SCS_CAT_SISTEMAS WHERE CODIGO = pArg1;
                    IF NVL(vCount,0) > 0 THEN 
                        RETURN TRUE; 
                    ELSE 
                        vMsg            := 'La b�squeda de Sistema con c�digo ' || pArg1 || ', no genera coincidencias';
                        vMsgDev        := '[VALIDATE_EXIST_ROW_SEGURIDAD] La b�squeda de Sistema con c�digo ' || pArg1 || ', no genera coincidencias';
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
      DBMS_OUTPUT.PUT_LINE ('Entr� a validar usuario');
      IF pUsuario IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE ('Entr� a usuario is not null');
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
      -- RAISE_APPLICATION_ERROR (-20000, 'No se encontr� tipo identificaci�n. '||SQLERRM);
       vCatalogoId := -1;
       RETURN vCatalogoId;
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id del tipo de identificaci�n. '||SQLERRM);     
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
      -- RAISE_APPLICATION_ERROR (-20000, 'No se encontr� el Id del Sexo. '||SQLERRM);  
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
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontr� el Id de tipo de persona. '||SQLERRM);
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
       -- RAISE_APPLICATION_ERROR (-20000, 'No se encontr� el Id de tipo c�digo expediente. '||SQLERRM);  
       vCatalogoId := -1;
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de tipo c�digo expediente. '||SQLERRM);     
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
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de tipo c�digo expediente a partir del expediente id. '||pExpedienteId||' - '||SQLERRM);     
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
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontr� el Id de Etnia. '||SQLERRM);
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
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontr� el Id de Tipo de sangre. '||SQLERRM);
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
       -- RAISE_APPLICATION_ERROR (-20000, 'No se encontr� Id de religi�n. '||SQLERRM); 
       vCatalogoId := -1;      
       RETURN vCatalogoId;  
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de religi�n. '||SQLERRM);     
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
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontr� el Id de religi�n. '||SQLERRM);
       vCatalogoId := -1;       
       RETURN vCatalogoId; 
  WHEN OTHERS THEN  
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener Id de religi�n. '||SQLERRM);     
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
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo relaci�n. '||SQLERRM);     
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
       --RAISE_APPLICATION_ERROR (-20000, 'No se encontr� el id tipo de tel�fono. '||SQLERRM);  
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
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo relaci�n. '||SQLERRM);     
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
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo relaci�n contacto. '||SQLERRM);     
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

           vIdentificacion:= CATALOGOS.PKG_PR.FN_VALIDA_CADENA('N�mero de Identificaci�n',
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
                pResultado := 'Formato de n�mero de identificaci�n inv�lido';
                pMsgError  := pResultado;            
                RAISE eParametrosInvalidos;             
             END IF;  END 
          IF;           

          CATALOGOS.PKG_SBC_CATALOGOS.PR_VALIDA_REGISTRO(CATALOGOS.PKG_SBC_CATALOGOS.kPAIS, 
                                                         'Pa�s Origen ID', 
                                                         pPaisOrigenId);

         typeArreglo:= CATALOGOS.PKG_SBC_CATALOGOS.FN_OBTIENE_DATOS_POR_ID(CATALOGOS.PKG_SBC_CATALOGOS.kPAIS, 
                                                                           'Pa�s Origen ID', 
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
      pResultado := 'Error no controlado al formatear par�metros nombres y/o identificaci�n. '||SQLERRM;
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

    --INICIO Modificaci�n 20210318
     DBMS_OUTPUT.PUT_LINE ('vPaisOrigenId: '||vPaisOrigenId);
     CASE
     WHEN NVL(vPaisOrigenId,0) = 0 THEN
          vPaisOrigenId := pPaisOrigenId;
     ELSE NULL;
     END CASE;
     IF (NVL(pExpedienteId,0) > 0 OR NVL(vPaisOrigenId,0) > 0)  THEN
        CATALOGOS.PKG_SBC_CATALOGOS.PR_VALIDA_REGISTRO(CATALOGOS.PKG_SBC_CATALOGOS.kPAIS, 
                                                    'Pa�s Origen ID', 
                                                    vPaisOrigenId);   -- NVL(vPaisId,vNicId)); 
     END IF;         
     --FIN Modificaci�n 20210318
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
              dbms_output.put_line ('Valida si la identificaci�n es valida o no: '||vDatos(8)); 
              CASE vDatos(8) 
              WHEN 0 THEN
                CASE
                WHEN pTipoPersona = HOSPITALARIO.PKG_PERSONA_HOSPITALARIO_DEV.kPrsIdntf THEN   -- vPrsIdnt 
                     pResultado := 'El tipo de identificaci�n ingresado no es permitido para una Persona Identificada.';
                     pMsgError  := pResultado;            
                     RAISE eParametrosInvalidos;
                ELSE NULL;
                END CASE;
              WHEN 1 THEN
                CASE
                WHEN pTipoPersona = HOSPITALARIO.PKG_PERSONA_HOSPITALARIO_DEV.kPrsNIdnt THEN   -- vPrsIdnt 
                     pResultado := 'El tipo de identificaci�n ingresado no es permitido para una Persona no Identificada.';
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
                    pResultado := 'Fecha de nacimiento inv�lida -> ' ||pFechaNacimiento ;
                    pMsgError  := pResultado;
                    RAISE eParametroNull; 
               ELSE NULL;
               END CASE;
              END ValFecha;
            --DBMS_OUTPUT.PUT_LINE('Configuraci�n Identificaci�n ID >> ' || vDatos(0));
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
      pResultado := 'Error no controlado al formatear par�metros nombres y/o identificaci�n. '||SQLERRM;
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
  pIdentificacion  := REPLACE(REPLACE(REPLACE(TRANSLATE(UPPER(TRIM(pIdentificacion)),'����������','AEIOUAEIOU'),'-'),'/'),' ');
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 2');  
 IF (pPrimerNombre IS NOT NULL AND pPrimerApellido IS NOT NULL) THEN
  pPrimerNombre    := CATALOGOS.PKG_PR.FN_VALIDA_CADENA ('Primer Nombre',REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pPrimerNombre,'[ ]+',' '))),'����������','AEIOUAEIOU'), kSoloTexto, NULL),50,2,TRUE);         --TRIM(REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pPrimerNombre,'[ ]+',' '))),'����������','AEIOUAEIOU'), kSoloTexto, NULL));
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 3');
  pSegundoNombre   := CATALOGOS.PKG_PR.FN_VALIDA_CADENA ('Segundo Nombre',REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pSegundoNombre,'[ ]+',' '))),'����������','AEIOUAEIOU'), kSoloTexto, NULL),50,0,FALSE);      --TRIM(REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pSegundoNombre,'[ ]+',' '))),'����������','AEIOUAEIOU'), kSoloTexto, NULL));
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 4');
  pPrimerApellido  := CATALOGOS.PKG_PR.FN_VALIDA_CADENA ('Primer Apellido',REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pPrimerApellido,'[ ]+',' '))),'����������','AEIOUAEIOU'), kSoloTexto, NULL),50,2,TRUE);     --TRIM(REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pPrimerApellido,'[ ]+',' '))),'����������','AEIOUAEIOU'), kSoloTexto, NULL));
  dbms_output.put_line('PR_FORMATEAR_PARAMETROS 5');
  pSegundoApellido := CATALOGOS.PKG_PR.FN_VALIDA_CADENA ('Segundo Apellido',REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pSegundoApellido,'[ ]+',' '))),'����������','AEIOUAEIOU'), kSoloTexto, NULL),50,0,FALSE);  --TRIM(REGEXP_REPLACE (TRANSLATE(UPPER (TRIM(REGEXP_REPLACE(pSegundoApellido,'[ ]+',' '))),'����������','AEIOUAEIOU'), kSoloTexto, NULL));
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
      pResultado := 'Error no controlado al formatear par�metros nombres y/o identificaci�n. ';
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
       RAISE_APPLICATION_ERROR (-20000, 'Problema al intentar obtener el id de tipo nota evoluci�n y tratamiento. '||SQLERRM);     
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
        pMsg        := 'No podemos realizar la b�squeda de Unidad de Salud, ya que no se ha espec�ficado el tipo de b�squeda a realizar';
        pMsgDev     := '[FN_GET_UNIDAD_SALUD] No se ha recibido valor en el par�metro de tipo de b�squeda -> ' || pTypeLookUp;
        RETURN NULL;
       END IF;
       IF pArg1 IS NULL OR NVL(pArg1,'')='' THEN 
        pMsg        := 'No podemos realizar la b�squeda de Unidad de Salud, ya que no se ha espec�ficado el criterio principal para realizar la b�squeda';
        pMsgDev     := '[FN_GET_UNIDAD_SALUD] No se ha recibido el criterio de b�squeda para realizar la b�squeda, ya sea Id, etc.';
        RETURN NULL;
       END IF;
    CASE pTypeLookUp
        WHEN PKG_SNH_UTILITARIOS.K_ID THEN
            BEGIN
                SELECT * INTO vUndSld FROM CATALOGOS.SBC_CAT_UNIDADES_SALUD WHERE UNIDAD_SALUD_ID = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La b�squeda de Unidad de Salud, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_UNIDAD_SALUD] La b�squeda de Unidad de Salud, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La b�squeda de Unidad de Salud, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    pMsgDev     := '[FN_GET_UNIDAD_SALUD] La b�squeda de Unidad de Salud, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La b�squeda de Unidad de Salud, por ID: ' || pArg1 || ', no se puede realizar de momento, intente m�s tarde';
                    pMsgDev     := '[FN_GET_UNIDAD_SALUD] '|| SQLERRM;
                    RETURN NULL;
            END;
        ELSE 
            pMsg        := 'La b�squeda de Unidad de Salud, de tipo: ' || pTypeLookUp || ', no existe';
            pMsgDev     := '[FN_GET_UNIDAD_SALUD] La b�squeda de Unidad de Salud, de tipo: ' || pTypeLookUp || ', no existe';
                    RETURN NULL;
    END CASE;
   RETURN vUndSld;
   END FN_GET_UNIDAD_SALUD;

   FUNCTION FN_GET_USER(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN SEGURIDAD.SCS_MST_USUARIOS%ROWTYPE
   IS
   vUsrRow        SEGURIDAD.SCS_MST_USUARIOS%ROWTYPE;
   BEGIN
       IF pTypeLookUp IS NULL THEN 
        pMsg        := 'No podemos realizar la b�squeda de Usuario, ya que no se ha espec�ficado el tipo de b�squeda a realizar';
        pMsgDev     := '[FN_GET_USER] No se ha recibido valor en el par�metro de tipo de b�squeda -> ' || pTypeLookUp;
        RETURN NULL;
       END IF;
       IF pArg1 IS NULL OR NVL(pArg1,'')='' THEN 
        pMsg        := 'No podemos realizar la b�squeda de Usuario, ya que no se ha espec�ficado el criterio principal para realizar la b�squeda';
        pMsgDev     := '[FN_GET_USER] No se ha recibido el criterio de b�squeda para realizar la b�squeda, ya sea Id, etc.';
        RETURN NULL;
       END IF;
    CASE pTypeLookUp
        WHEN PKG_SNH_UTILITARIOS.K_ID THEN
            BEGIN
                SELECT * INTO vUsrRow FROM SEGURIDAD.SCS_MST_USUARIOS WHERE USUARIO_ID = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La b�squeda de Usuario, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_USER] La b�squeda de Usuario, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La b�squeda de Usuario, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    pMsgDev     := '[FN_GET_USER] La b�squeda de Usuario, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La b�squeda de Usuario por ID: ' || pArg1 || ', no se puede realizar de momento, intente m�s tarde';
                    pMsgDev     := '[FN_GET_USER] '|| SQLERRM;
                    RETURN NULL;
            END;
        WHEN PKG_SNH_UTILITARIOS.K_LKUSR_USERNAME THEN
            BEGIN

                SELECT * INTO vUsrRow FROM SEGURIDAD.SCS_MST_USUARIOS WHERE USERNAME = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La b�squeda de Usuario, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_USER] La b�squeda de Usuario, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La b�squeda de Usuario, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    pMsgDev     := '[FN_GET_USER] La b�squeda de Usuario, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La b�squeda de Usuario por ID: ' || pArg1 || ', no se puede realizar de momento, intente m�s tarde';
                    pMsgDev     := '[FN_GET_USER] '|| SQLERRM;
                    RETURN NULL;
            END;
        ELSE 
            pMsg        := 'La b�squeda de Usuario, de tipo: ' || pTypeLookUp || ', no existe';
            pMsgDev     := '[FN_GET_USER] La b�squeda de Usuario, de tipo: ' || pTypeLookUp || ', no existe';
                    RETURN NULL;
    END CASE;
    RETURN vUsrRow;
   END FN_GET_USER;

   FUNCTION FN_GET_SYSTEM(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN SEGURIDAD.SCS_CAT_SISTEMAS%ROWTYPE
   IS
   vSysRow        SEGURIDAD.SCS_CAT_SISTEMAS%ROWTYPE;
   BEGIN
       IF pTypeLookUp IS NULL THEN 
        pMsg        := 'No podemos realizar la b�squeda de Sistema, ya que no se ha espec�ficado el tipo de b�squeda a realizar';
        pMsgDev     := '[FN_GET_SYSTEM] No se ha recibido valor en el par�metro de tipo de b�squeda -> ' || pTypeLookUp;
        RETURN NULL;
       END IF;
       IF pArg1 IS NULL OR NVL(pArg1,'')='' THEN 
        pMsg        := 'No podemos realizar la b�squeda de Sistema, ya que no se ha espec�ficado el criterio principal para realizar la b�squeda';
        pMsgDev     := '[FN_GET_SYSTEM] No se ha recibido el criterio de b�squeda para realizar la b�squeda, ya sea Id, etc.';
        RETURN NULL;
       END IF;
    CASE pTypeLookUp
        WHEN PKG_SNH_UTILITARIOS.K_ID THEN
            BEGIN
                SELECT * INTO vSysRow FROM SEGURIDAD.SCS_CAT_SISTEMAS WHERE SISTEMA_ID = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La b�squeda de Sistema, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_SYSTEM] La b�squeda de Sistema, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La b�squeda de Sistema, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    pMsgDev     := '[FN_GET_SYSTEM] La b�squeda de Sistema, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La b�squeda de Sistema por ID: ' || pArg1 || ', no se puede realizar de momento, intente m�s tarde';
                    pMsgDev     := '[FN_GET_SYSTEM] '|| SQLERRM;
                    RETURN NULL;
            END;
        WHEN PKG_SNH_UTILITARIOS.K_VLD_CODE THEN
            BEGIN
                SELECT * INTO vSysRow FROM SEGURIDAD.SCS_CAT_SISTEMAS WHERE CODIGO = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La b�squeda de Sistema, por C�digo: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_SYSTEM] La b�squeda de Sistema, por C�digo: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La b�squeda de Sistema, por C�digo: ' || pArg1 || ', genera m�ltiples coincidencias';
                    pMsgDev     := '[FN_GET_SYSTEM] La b�squeda de Sistema, por C�digo: ' || pArg1 || ', genera m�ltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La b�squeda de Sistema por C�digo: ' || pArg1 || ', no se puede realizar de momento, intente m�s tarde';
                    pMsgDev     := '[FN_GET_SYSTEM] '|| SQLERRM;
                    RETURN NULL;
            END;
        ELSE 
            pMsg        := 'La b�squeda de Sistema, de tipo: ' || pTypeLookUp || ', no existe';
            pMsgDev     := '[FN_GET_SYSTEM] La b�squeda de Sistema, de tipo: ' || pTypeLookUp || ', no existe';
                    RETURN NULL;
    END CASE;
    RETURN vSysRow;
   END FN_GET_SYSTEM;

   FUNCTION FN_GET_COMUNIDAD(pTypeLookUp VARCHAR2, pArg1 VARCHAR2, pArg2 VARCHAR2, pArg3 VARCHAR2, pArg4 VARCHAR2, pMsgDev OUT VARCHAR2, pMsg OUT VARCHAR2) RETURN CATALOGOS.SBC_CAT_COMUNIDADES%ROWTYPE
   IS
   vCmndRow        CATALOGOS.SBC_CAT_COMUNIDADES%ROWTYPE;
   BEGIN
       IF pTypeLookUp IS NULL THEN 
        pMsg        := 'No podemos realizar la b�squeda de la Comunidad, ya que no se ha espec�ficado el tipo de b�squeda a realizar';
        pMsgDev     := '[FN_GET_COMUNIDAD] No se ha recibido valor en el par�metro de tipo de b�squeda -> ' || pTypeLookUp;
        RETURN NULL;
       END IF;
       IF pArg1 IS NULL OR NVL(pArg1,'')='' THEN 
        pMsg        := 'No podemos realizar la b�squeda de la Comunidad, ya que no se ha espec�ficado el criterio principal para realizar la b�squeda';
        pMsgDev     := '[FN_GET_COMUNIDAD] No se ha recibido el criterio de b�squeda para realizar la b�squeda, ya sea Id, etc.';
        RETURN NULL;
       END IF;
    CASE pTypeLookUp
        WHEN PKG_SNH_UTILITARIOS.K_ID THEN
            BEGIN
                SELECT * INTO vCmndRow FROM CATALOGOS.SBC_CAT_COMUNIDADES WHERE COMUNIDAD_ID = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La b�squeda de Comunidad, por ID: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_COMUNIDAD] La b�squeda de Comunidad, por ID: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La b�squeda de Comunidad, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    pMsgDev     := '[FN_GET_COMUNIDAD] La b�squeda de Comunidad, por ID: ' || pArg1 || ', genera m�ltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La b�squeda de Comunidad por ID: ' || pArg1 || ', no se puede realizar de momento, intente m�s tarde';
                    pMsgDev     := '[FN_GET_COMUNIDAD] '|| SQLERRM;
                    RETURN NULL;
            END;
        WHEN PKG_SNH_UTILITARIOS.K_VLD_CODE THEN
            BEGIN
                SELECT * INTO vCmndRow FROM CATALOGOS.SBC_CAT_COMUNIDADES WHERE CODIGO = pArg1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    pMsg        := 'La b�squeda de Comunidad, por C�digo: ' || pArg1 || ', no genera coincidencias';
                    pMsgDev     := '[FN_GET_COMUNIDAD] La b�squeda de Comunidad, por C�digo: ' || pArg1 || ', no genera coincidencias';
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN 
                    pMsg        := 'La b�squeda de Comunidad, por C�digo: ' || pArg1 || ', genera m�ltiples coincidencias';
                    pMsgDev     := '[FN_GET_COMUNIDAD] La b�squeda de Comunidad, por C�digo: ' || pArg1 || ', genera m�ltiples coincidencias';
                    RETURN NULL;
                WHEN OTHERS THEN 
                    pMsg        := 'La b�squeda de Comunidad por C�digo: ' || pArg1 || ', no se puede realizar de momento, intente m�s tarde';
                    pMsgDev     := '[FN_GET_COMUNIDAD] '|| SQLERRM;
                    RETURN NULL;
            END;
        ELSE 
            pMsg        := 'La b�squeda de Comunidad, de tipo: ' || pTypeLookUp || ', no existe';
            pMsgDev     := '[FN_GET_COMUNIDAD] La b�squeda de Comunidad, de tipo: ' || pTypeLookUp || ', no existe';
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
        pResultado := 'No se encontr� registro asociado a par�metro [pCodEvento: '||pCodEventoId||']';     
        pMsgError  := vFirma||pResultado;
   WHEN TOO_MANY_ROWS THEN
        pResultado := 'Se encontr� mas de un registro asociado a par�metro [pCodEventoId: '||pCodEventoId||']';     
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
 FUNCTION FN_OBT_COMUNIDAD_ID (pUsalDestinoId IN NUMBER) RETURN NUMBER AS
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
 FUNCTION FN_OBT_DIV_POL_ID (pUsalDestinoId IN NUMBER) RETURN NUMBER AS
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

 FUNCTION FN_OBT_RED_SERV_ID (pUsalDestinoId IN NUMBER) RETURN NUMBER AS
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
 
 FUNCTION FN_OBT_SERVICIOID (pCodigo IN HOSPITALARIO.SNH_CAT_SERVICIOS.CODIGO%TYPE) RETURN NUMBER AS
 vContador    SIMPLE_INTEGER := 0;
 vServicioId  HOSPITALARIO.SNH_CAT_SERVICIOS.SERVICIO_ID%TYPE;
 BEGIN
  CASE
  WHEN pCodigo IS NOT NULL THEN
       BEGIN
         SELECT COUNT (1)
           INTO vContador
          FROM HOSPITALARIO.SNH_CAT_SERVICIOS
         WHERE CODIGO = pCodigo;
         
         CASE
         WHEN vContador > 0 THEN
              BEGIN
               SELECT SERVICIO_ID
                 INTO vServicioId
                 FROM HOSPITALARIO.SNH_CAT_SERVICIOS
                WHERE CODIGO = pCodigo;  
              END;
         ELSE NULL;
         END CASE;
       END;
  ELSE NULL;
  END CASE; 
  RETURN vServicioId;
 EXCEPTION
 WHEN OTHERS THEN
      RETURN vServicioId;    
 END FN_OBT_SERVICIOID;

 /* FUNCION PARA OBTENER UN ARCHIVO TIPO BLOB EN EL DIRECTORIO DE INTERES  */
 FUNCTION FN_OBT_BLOB_FROM_DIR (p_file_name      VARCHAR2, 
                                p_directory_name VARCHAR2 DEFAULT K_DIRECTORY_NAME )
      RETURN BLOB
   AS
      dest_loc   BLOB := EMPTY_BLOB ();
      src_loc    BFILE := BFILENAME (p_directory_name, p_file_name);
   BEGIN
      -- Open source binary file from OS
      DBMS_LOB.OPEN (src_loc, DBMS_LOB.LOB_READONLY);

      -- Create temporary LOB object
      DBMS_LOB.CREATETEMPORARY (lob_loc   => dest_loc,
                                cache     => TRUE,
                                dur       => DBMS_LOB.session);

      -- Open temporary lob
      DBMS_LOB.OPEN (dest_loc, DBMS_LOB.LOB_READWRITE);

      -- Load binary file into temporary LOB
      DBMS_LOB.LOADFROMFILE (dest_lob   => dest_loc,
                             src_lob    => src_loc,
                             amount     => DBMS_LOB.getLength (src_loc));

      -- Close lob objects
      DBMS_LOB.CLOSE (dest_loc);
      DBMS_LOB.CLOSE (src_loc);

      -- Return temporary LOB object
      RETURN dest_loc;
   END FN_OBT_BLOB_FROM_DIR;


   -------------------------------------------------------------------------
   --FUNCION PARA CREAR UN ARCHIVO TIPO BLOB EN EL DIRECTORIO DE INTERES
   -------------------------------------------------------------------------

   FUNCTION CREAR_BLOB_TO_DIR (v_blob            IN     BLOB,
                               v_imgname         IN     VARCHAR2,
                               p_directory_name  IN   VARCHAR2 DEFAULT K_DIRECTORY_NAME,
                               pMsgError         OUT VARCHAR2)
      RETURN SIMPLE_INTEGER
   AS
      v_archivo   UTL_FILE.FILE_TYPE;
      v_offset    NUMBER := 1;
      result      SIMPLE_INTEGER := 0;
   BEGIN
      v_archivo :=
         UTL_FILE.FOPEN (p_directory_name,
                         v_imgname,
                         'WB',
                         32767);

      LOOP
         EXIT WHEN v_offset > DBMS_LOB.GETLENGTH (v_blob);
         UTL_FILE.PUT_RAW (v_archivo,
                           DBMS_LOB.SUBSTR (v_blob, 32767, v_offset));
         v_offset := v_offset + 32767;
      END LOOP;

      UTL_FILE.fclose (v_archivo);
      RETURN 1;
   --EXCEPCIONES DE UTL_FILE ORACLE
   EXCEPTION
      --       WHEN NO_DATA_FOUND
      --       THEN
      --            RAISE eRegistroNoExiste;
      --
      --       WHEN INVALID_FILEHANDLE
      --       THEN
      --            pMsgError:= 'ERROR - NO ES UN IDENTIFICADOR DE ARCHIVO VALIDO' || SQLERRM;
      --
      --       WHEN INVALID_OPERATION
      --       THEN
      --            pMsgError:= 'ERROR - EL ARCHIVO NO SE PUEDE ADJUNTAR' || SQLERRM;
      --
      --       WHEN READ_ERROR
      --       THEN
      --            pMsgError:= 'ERROR -  SE PRODUJO UN ERROR DEL SISTEMA OPERATIVO DURANTE LA OPERACIÓN DE LECTURA' || SQLERRM;
      --
      WHEN OTHERS
      THEN
      pMsgError:= 'ERROR -  SE PRODUJO UN ERROR INESPERADO' || SQLERRM;
         RETURN result;
   END CREAR_BLOB_TO_DIR;
--PROCEDIMIENTO PARA LEER UN ARCHIVO TIPO BLOB DEL DIRECTORIO DE INTERES
   ---------------------------------------------------------------------------

   PROCEDURE SCL_C_FILE_TO_BLOB (p_ImgNombre      IN     VARCHAR2,
                                 p_directory_name IN   VARCHAR2 DEFAULT K_DIRECTORY_NAME,
                                 p_Blob           OUT var_refcursor
                                 )
   IS
   BEGIN
      IF p_ImgNombre IS NULL
      THEN
         RAISE eParametroNull;
      END IF;

      BEGIN
         OPEN p_Blob FOR
            SELECT ROWNUM AS ID,
                   p_ImgNombre AS NOMBRE,
                   HOSPITALARIO.PKG_SNH_UTILITARIOS.FN_OBT_BLOB_FROM_DIR (
                      p_ImgNombre,p_directory_name
                      )
                      AS IMAGEN
              FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE eRegistroNoExiste;
      END;
   EXCEPTION
      WHEN eParametroNull
      THEN
         RAISE_APPLICATION_ERROR (
            -20010,
            'Los parámetros enviados no pueden ser nulos.');
      WHEN eRegistroNoExiste
      THEN
         RAISE_APPLICATION_ERROR (
            -20010,
            'No se encontró el archivo con los parámetros ingresados.');
      WHEN OTHERS
      THEN
         RAISE_APPLICATION_ERROR (
            -20010,
            'Se ha generado un error inesperado' || SQLERRM);
   END SCL_C_FILE_TO_BLOB;

FUNCTION FN_OBT_EDAD_PERSONA_HST (pFechaNac          IN CATALOGOS.SBC_MST_PERSONAS.FECHA_NACIMIENTO%TYPE,
                                  pFechaHst          SNH_MST_ADMISIONES.FECHA_INGRESO%TYPE,
                                  pVariableARetornar IN VARCHAR2) RETURN VARCHAR2 AS
    vFechaInicio     TIMESTAMP;
    vFechFin         TIMESTAMP;
    vFechFinD        DATE;
    vAnio            VARCHAR2 (10);
    vMes             VARCHAR2 (10);
    vDias            VARCHAR2 (10);
    vRetorna         VARCHAR2 (100) := NULL;
    vFecNacimiento   DATE;
-- ----
BEGIN
    vFecNacimiento := pFechaNac;
    vFechaInicio :=
        TO_TIMESTAMP (TO_CHAR (vFecNacimiento, 'YYYY/MM/DD'), 'YYYY/MM/DD');
    vFechFin :=
        TO_TIMESTAMP (TO_CHAR (pFechaHst, 'YYYY/MM/DD'), 'YYYY/MM/DD');

   <<CantidadTiempo>>
    BEGIN
        --Validar que al menos se recibe una Fecha
        IF vFechaInicio IS NULL
        THEN
            RAISE eParametroNull;
        END IF;

        CASE
            WHEN vFechFin IS NOT NULL
            THEN
                IF (vFechFin < vFechaInicio)
                THEN
                    RAISE eParametrosInvalidos;
                END IF;

                vFechFinD :=
                    TO_DATE (TO_CHAR (vFechFin, 'YYYY/MM/DD'), 'YYYY/MM/DD');

                SELECT LPAD (TRUNC (MONTHS_BETWEEN (vFechFinD, fnf) / 12),
                             3,
                             '0')    YEARS,
                       LPAD (
                           TRUNC (MOD (MONTHS_BETWEEN (vFechFinD, fnf), 12)),
                           2,
                           '0')      MONTHS,
                       LPAD (
                           TRUNC (
                                 vFechFinD
                               - ADD_MONTHS (
                                     fnf,
                                         TRUNC (
                                               MONTHS_BETWEEN (vFechFinD,
                                                               fnf)
                                             / 12)
                                       * 12
                                     + TRUNC (
                                           MOD (
                                               MONTHS_BETWEEN (vFechFinD,
                                                               fnf),
                                               12)))),
                           2,
                           '0')      DAYS
                  INTO vAnio, vMes, vDias
                  FROM (SELECT vFechaInicio fnf FROM DUAL);
            ELSE
                SELECT LPAD (TRUNC (MONTHS_BETWEEN (SYSDATE, fnf) / 12),
                             3,
                             '0')    YEARS,
                       LPAD (TRUNC (MOD (MONTHS_BETWEEN (SYSDATE, fnf), 12)),
                             2,
                             '0')    MONTHS,
                       LPAD (
                           TRUNC (
                                 SYSDATE
                               - ADD_MONTHS (
                                     fnf,
                                         TRUNC (
                                               MONTHS_BETWEEN (SYSDATE, fnf)
                                             / 12)
                                       * 12
                                     + TRUNC (
                                           MOD (
                                               MONTHS_BETWEEN (SYSDATE, fnf),
                                               12)))),
                           2,
                           '0')      DAYS
                  INTO vAnio, vMes, vDias
                  FROM (SELECT vFechaInicio fnf FROM DUAL);
        END CASE;

        CASE
            WHEN pVariableARetornar = 'A'
            THEN
                -- RETORNA VARIABLE AÑO
                vRetorna := vAnio;
            WHEN pVariableARetornar = 'M'
            THEN
                -- RETORNA MES
                vRetorna := vMes;
            WHEN pVariableARetornar = 'D'
            THEN
                -- RETORNA DIAS
                vRetorna := vDias;
            WHEN pVariableARetornar = 'F'
            THEN
                vRetorna :=
                       vAnio
                    || ' años '
                    || vMes
                    || ' meses '
                    || vDias
                    || ' días';
            ELSE
                vRetorna := ' ';
        END CASE;
    END CantidadTiempo;

    RETURN vRetorna;
EXCEPTION
    WHEN eParametroNull
    THEN
        RETURN 'N/A - N';
    WHEN eParametrosInvalidos
    THEN
        RETURN 'N/A - A';
    WHEN OTHERS
    THEN
        RETURN 'N/A - O';
END FN_OBT_EDAD_PERSONA_HST;

FUNCTION FN_OBT_CAT_CNF_ID_EVENTOS_HOSP (pCodigo IN VARCHAR2) RETURN NUMBER AS
vId HOSPITALARIO.SNH_CNF_GRUPO_EVENTOS_HOSP.CATALOGO_CNF_ID%TYPE;
vConteo SIMPLE_INTEGER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('pCodigo: '||pCodigo);
  CASE
  WHEN pCodigo IS NOT NULL THEN
       BEGIN
         SELECT COUNT(1)
           INTO vConteo
           FROM HOSPITALARIO.SNH_CNF_GRUPO_EVENTOS_HOSP
          WHERE CODIGO_TIPO_CATALOGO = pCodigo AND
                ESTADO_REGISTRO_ID = HOSPITALARIO.PKG_PERSONA_HOSPITALARIO_DEV.vGLOBAL_ESTADO_ACTIVO;
           DBMS_OUTPUT.PUT_LINE ('vConteo: '||vConteo); 
          CASE
          WHEN vConteo > 0 THEN
               BEGIN
                 SELECT CATALOGO_CNF_ID
                   INTO vId
                   FROM HOSPITALARIO.SNH_CNF_GRUPO_EVENTOS_HOSP
                  WHERE CODIGO_TIPO_CATALOGO = pCodigo AND
                        ESTADO_REGISTRO_ID = HOSPITALARIO.PKG_PERSONA_HOSPITALARIO_DEV.vGLOBAL_ESTADO_ACTIVO;    
               DBMS_OUTPUT.PUT_LINE ('vId: '||vId);                    
               END;
          ELSE NULL;
          END CASE; 
       END;
  ELSE NULL;
  END CASE;
  RETURN vId;
  EXCEPTION
  WHEN OTHERS THEN
       RETURN vId;
END FN_OBT_CAT_CNF_ID_EVENTOS_HOSP;


FUNCTION FN_OBT_GRP_ETAREO (pFecNacimiento IN CATALOGOS.SBC_MST_PERSONAS.FECHA_NACIMIENTO%TYPE,
                            pCodigo        IN VARCHAR2) RETURN VARCHAR2 AS
 vGrupoEtareo   HOSPITALARIO.SNH_REL_CNF_GRUPO_CATALOGOS.DESCRIPCION%TYPE := 'NA';
 vCatCnfId      HOSPITALARIO.SNH_CNF_GRUPO_EVENTOS_HOSP.CATALOGO_CNF_ID%TYPE :=  FN_OBT_CAT_CNF_ID_EVENTOS_HOSP (pCodigo); ---('CNF_CATLABIMG'); -- ('CNF_CATCIE10');  
 vEdadCalculada VARCHAR2(7) := HOSPITALARIO.PKG_CATALOGOS_UTIL.FN_FECHA_NACIMIENTO(pFecNacimiento);
 vGrupoEtareoId NUMBER;
 vMsgError      VARCHAR2 (1000);
BEGIN
    DBMS_OUTPUT.PUT_LINE ('vCatCnfId: '||vCatCnfId);
    DBMS_OUTPUT.PUT_LINE ('vEdadCalculada: '||vEdadCalculada);
    vGrupoEtareoId := HOSPITALARIO.PKG_SNH_PACIENTE_V2.CALCULAR_RANGO_PX(vEdadCalculada, vCatCnfId, kCATCIE10, vMsgError);
    DBMS_OUTPUT.PUT_LINE ('vMsgError: '||vMsgError);
    DBMS_OUTPUT.PUT_LINE ('vGrupoEtareoId: '||vGrupoEtareoId);
    vGrupoEtareo := FN_OBT_GRP_ETAREO_DESCRIPCION (vGrupoEtareoId);
    DBMS_OUTPUT.PUT_LINE ('vGrupoEtareo: '||vGrupoEtareo);
 RETURN vGrupoEtareo;

EXCEPTION 
WHEN OTHERS THEN 
     RETURN vGrupoEtareo; 
END FN_OBT_GRP_ETAREO;  

FUNCTION FN_OBT_GRP_ETAREO_DESCRIPCION (pGrupoEtareoId IN NUMBER) RETURN VARCHAR2 AS
vGrupoEtereo HOSPITALARIO.SNH_REL_CNF_GRUPO_CATALOGOS.DESCRIPCION%TYPE := 'NA'; 
BEGIN
 SELECT DESCRIPCION
   INTO vGrupoEtereo
   FROM HOSPITALARIO.SNH_REL_CNF_GRUPO_CATALOGOS 
  WHERE CNF_ID = pGrupoEtareoId;
 RETURN vGrupoEtereo;

EXCEPTION
WHEN OTHERS THEN
     RETURN vGrupoEtereo; 
END FN_OBT_GRP_ETAREO_DESCRIPCION; 
END PKG_SNH_UTILITARIOS;
/