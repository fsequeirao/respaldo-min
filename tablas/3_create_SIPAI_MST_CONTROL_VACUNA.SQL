CREATE SEQUENCE SIPAI_S_CONTROL_VACUNA_ID
  START WITH 1
  MAXVALUE 999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;
  
  
CREATE TABLE SIPAI_MST_CONTROL_VACUNA
(
  CONTROL_VACUNA_ID             NUMBER(10) CONSTRAINT PK_SIP_CONTROL_VACUNA_ID PRIMARY KEY NOT NULL,
  EXPEDIENTE_ID                 NUMBER(10) CONSTRAINT NNC_SIP_EXPEDIENTE_ID NOT NULL,
  PROGRAMA_VACUNA_ID            NUMBER(10) CONSTRAINT NNC_SIP_PROG_VACUNA_ID NOT NULL,
  GRUPO_PRIORIDAD_ID            NUMBER(10) CONSTRAINT NNC_SIP_GRP_PRIORIDAD_ID NOT NULL,
  TIPO_VACUNA_ID                NUMBER(10) CONSTRAINT NNC_SIP_TIPO_VACUNA_ID NOT NULL,
  CANTIDAD_VACUNA_APLICADA      NUMBER(10),
  CANTIDAD_VACUNA_PROGRAMADA    NUMBER(10),
  FECHA_INICIO_VACUNA           DATE,
  FECHA_FIN_VACUNA              DATE,
  ESTADO_REGISTRO_ID            NUMBER(10) CONSTRAINT NNC_SIP_ESTADO_REG_ID NOT NULL,
  SISTEMA_ID                    NUMBER(10) CONSTRAINT NNC_SIP_SISTEMA NOT NULL,
  UNIDAD_SALUD_ID               NUMBER(10) CONSTRAINT NNC_SIP_USALUD NOT NULL,
  USUARIO_REGISTRO              VARCHAR2(50 BYTE) CONSTRAINT NNC_SIP_USR_REGISTRO NOT NULL,
  FECHA_REGISTRO                TIMESTAMP(0)   DEFAULT SYSTIMESTAMP CONSTRAINT NNC_SIP_FECHA_REGISTRO NOT NULL,
  USUARIO_MODIFICACION          VARCHAR2(50 BYTE),
  FECHA_MODIFICACION            TIMESTAMP(0),
  USUARIO_PASIVA                VARCHAR2(50 BYTE),
  FECHA_PASIVO                  TIMESTAMP(0)
  );
  


CREATE UNIQUE INDEX IDX_UI_SIPAI_CONTROL_ID ON SIPAI_MST_CONTROL_VACUNA
(CONTROL_VACUNA_ID);

CREATE INDEX IDX_SIPAI_PROGRAMA_ID ON SIPAI_MST_CONTROL_VACUNA
(PROGRAMA_VACUNA_ID);

CREATE INDEX IDX_SIPAI_GRP_PRIORIDAD_ID ON SIPAI_MST_CONTROL_VACUNA
(GRUPO_PRIORIDAD_ID);

CREATE INDEX IDX_SIPAI_GRP_TIPO_VACUNA_ID ON SIPAI_MST_CONTROL_VACUNA
(TIPO_VACUNA_ID);


CREATE INDEX IDX_SIPAI_EXPEDIENTE_ID ON SIPAI_MST_CONTROL_VACUNA
(EXPEDIENTE_ID);


CREATE INDEX IDX_SIPAI_CTRL_EXP_ID ON SIPAI_MST_CONTROL_VACUNA
(CONTROL_VACUNA_ID, EXPEDIENTE_ID);

CREATE INDEX IDX_SIPAI_PROG_GRP_ID ON SIPAI_MST_CONTROL_VACUNA
(PROGRAMA_VACUNA_ID, GRUPO_PRIORIDAD_ID);


CREATE INDEX IDX_SIPAI_GRP_TIPVAC_ID ON SIPAI_MST_CONTROL_VACUNA
(GRUPO_PRIORIDAD_ID, TIPO_VACUNA_ID);

  
CREATE OR REPLACE TRIGGER TRG_AUD_SIPAI_CONTROL_VACUNA
BEFORE INSERT OR UPDATE ON SIPAI_MST_CONTROL_VACUNA FOR EACH ROW
BEGIN
    IF INSERTING THEN
       :NEW.CONTROL_VACUNA_ID  := SIPAI_S_CONTROL_VACUNA_ID.NEXTVAL;
       :NEW.FECHA_REGISTRO     := SYSDATE;
    ELSE
       IF :NEW.USUARIO_MODIFICACION IS NULL THEN
           RAISE_APPLICATION_ERROR (-20000, 'El usuario modificación no puede quedar nulo.');
       ELSE
       :NEW.FECHA_MODIFICACION   := SYSDATE;
       END IF;
    END IF;
END;
/

-- estado registro
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPAI_ESTADO_REGISTRO
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON SIPAI.SIPAI_MST_CONTROL_VACUNA FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.ESTADO_REGISTRO_ID IS NOT NULL AND :NEW.ESTADO_REGISTRO_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.ESTADO_REGISTRO_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El estado del registro, no es un valor valido. Estado registro id: '||:NEW.ESTADO_REGISTRO_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.ESTADO_REGISTRO_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'STREG';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Estado registro id: '||:NEW.ESTADO_REGISTRO_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.ESTADO_REGISTRO_ID IS NOT NULL THEN
         IF NVL(:NEW.ESTADO_REGISTRO_ID,0) != NVL(:OLD.ESTADO_REGISTRO_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.ESTADO_REGISTRO_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Estado registro id: '||:NEW.ESTADO_REGISTRO_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.ESTADO_REGISTRO_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'STREG';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Estado registro id: '||:NEW.ESTADO_REGISTRO_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;            
             END;  
         END IF;
       END IF;
    END IF;
END;
/

--- programa vacuna
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPAI_PROG_VACUNA
BEFORE INSERT OR UPDATE OF PROGRAMA_VACUNA_ID ON SIPAI.SIPAI_MST_CONTROL_VACUNA FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.PROGRAMA_VACUNA_ID IS NOT NULL AND :NEW.PROGRAMA_VACUNA_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.PROGRAMA_VACUNA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El programa vacuna, no es un valor valido. Programa vacuna id: '||:NEW.PROGRAMA_VACUNA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.PROGRAMA_VACUNA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'PRO_VAC';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El programa vacuna, no es un valor valido. Programa vacuna id: '||:NEW.PROGRAMA_VACUNA_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.PROGRAMA_VACUNA_ID IS NOT NULL THEN
         IF NVL(:NEW.PROGRAMA_VACUNA_ID,0) != NVL(:OLD.PROGRAMA_VACUNA_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.PROGRAMA_VACUNA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El programa vacuna, no es un valor valido. Programa vacuna id: '||:NEW.PROGRAMA_VACUNA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.PROGRAMA_VACUNA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'PRO_VAC';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El programa vacuna, no es un valor valido. Programa vacuna id: '||:NEW.PROGRAMA_VACUNA_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;            
             END;  
         END IF;
       END IF;
    END IF;
END;
/


--- grupo prioridad
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPAI_GRP_PRIORIDAD
BEFORE INSERT OR UPDATE OF GRUPO_PRIORIDAD_ID ON SIPAI.SIPAI_MST_CONTROL_VACUNA FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.GRUPO_PRIORIDAD_ID IS NOT NULL AND :NEW.GRUPO_PRIORIDAD_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.GRUPO_PRIORIDAD_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El grupo prioridad, no es un valor valido. Grupo Prioridad id: '||:NEW.GRUPO_PRIORIDAD_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.GRUPO_PRIORIDAD_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'GRP_PRI_VAC';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El grupo prioridad, no es un valor valido. Grupo Prioridad id: '||:NEW.GRUPO_PRIORIDAD_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.GRUPO_PRIORIDAD_ID IS NOT NULL THEN
         IF NVL(:NEW.GRUPO_PRIORIDAD_ID,0) != NVL(:OLD.GRUPO_PRIORIDAD_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.GRUPO_PRIORIDAD_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El grupo prioridad, no es un valor valido. Grupo Prioridad id: '||:NEW.GRUPO_PRIORIDAD_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.GRUPO_PRIORIDAD_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'GRP_PRI_VAC';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El grupo prioridad, no es un valor valido. Grupo Prioridad id: '||:NEW.GRUPO_PRIORIDAD_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;            
             END;  
         END IF;
       END IF;
    END IF;
END;
/



CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPAI_FEC_INICIO_VACUNA
BEFORE INSERT OR UPDATE OF FECHA_INICIO_VACUNA ON SIPAI.SIPAI_MST_CONTROL_VACUNA FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF :NEW.FECHA_INICIO_VACUNA IS NOT NULL THEN
         IF TRUNC(:NEW.FECHA_INICIO_VACUNA) > TRUNC(SYSDATE) THEN
              RAISE_APPLICATION_ERROR (-20000, 'La fecha de la primera vacuna no puede ser mayor al día de hoy.');
         END IF;
      END IF;
    ELSIF UPDATING THEN
      IF :NEW.FECHA_INICIO_VACUNA IS NOT NULL THEN
         IF TRUNC(:NEW.FECHA_INICIO_VACUNA) > TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR (-20000, 'La fecha de laprimera vacuna no puede ser mayor al día de hoy.');
         END IF;
      END IF;
    END IF;
END;
/



CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPAI_FEC_FIN_VACUNA 
BEFORE INSERT OR UPDATE OF FECHA_FIN_VACUNA ON SIPAI.SIPAI_MST_CONTROL_VACUNA FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF :NEW.FECHA_FIN_VACUNA IS NOT NULL THEN
         CASE
         WHEN :NEW.FECHA_INICIO_VACUNA IS NOT NULL THEN
            IF TRUNC(:NEW.FECHA_FIN_VACUNA) < TRUNC(:NEW.FECHA_INICIO_VACUNA) THEN
               RAISE_APPLICATION_ERROR (-20000, 'La fecha de fin ultima vacuna no puede ser menor a la fecha de la primera vacuna.');
            END IF;
         WHEN :OLD.FECHA_INICIO_VACUNA IS NOT NULL THEN
            IF TRUNC(:NEW.FECHA_FIN_VACUNA) < TRUNC(:OLD.FECHA_INICIO_VACUNA) THEN
               RAISE_APPLICATION_ERROR (-20000, 'La fecha de ultima vacuna no puede ser menor a la fecha de la primera vacuna.');
            END IF;   
         ELSE  --insertar fecha fin de tratamiento con fecha inicial nula.
             IF (:NEW.FECHA_INICIO_VACUNA IS NULL AND :OLD.FECHA_INICIO_VACUNA IS NULL)  THEN
               RAISE_APPLICATION_ERROR (-20000, 'No se puede registrar fecha de ultima vacuna, sin previamente haber registrado una primera vacuna');
             END IF;
         END CASE;
         IF TRUNC(:NEW.FECHA_FIN_VACUNA) > TRUNC(SYSDATE) THEN
              RAISE_APPLICATION_ERROR (-20000, 'No se puede registrar la fecha de ultima vacuna de tratamiento a futuro.');
         END IF;
      END IF;
    ELSIF UPDATING THEN
      IF :NEW.FECHA_FIN_VACUNA IS NOT NULL THEN
         CASE
         WHEN :NEW.FECHA_INICIO_VACUNA IS NOT NULL THEN
            IF TRUNC(:NEW.FECHA_FIN_VACUNA) < TRUNC(:NEW.FECHA_INICIO_VACUNA) THEN
               RAISE_APPLICATION_ERROR (-20000, 'La fecha de ultima vacuna no puede ser menor a la fecha de la primera vacuna.');
            END IF;
         WHEN :OLD.FECHA_INICIO_VACUNA IS NOT NULL THEN
            IF TRUNC(:NEW.FECHA_FIN_VACUNA) < TRUNC(:OLD.FECHA_INICIO_VACUNA) THEN
               RAISE_APPLICATION_ERROR (-20000, 'La fecha de ultima vacuna no puede ser menor a la fecha de la primera vacuna.');
            END IF;   
         ELSE  --insertar fecha fin de tratamiento con fecha inicial nula.
             IF (:NEW.FECHA_INICIO_VACUNA IS NULL AND :OLD.FECHA_INICIO_VACUNA IS NULL) THEN
                RAISE_APPLICATION_ERROR (-20000, 'No se puede registrar fecha de ultima vacuna, sin previamente haber registrado una primera vacuna');
             END IF;
         END CASE;
         IF TRUNC(:NEW.FECHA_FIN_VACUNA) > TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR (-20000, 'No se puede registrar la fecha de ultima vacuna a futuro.');
         END IF;
      END IF;
    END IF;
END;
/


--ALTER TABLE SIPAI_MST_CONTROL_VACUNA ADD (
--  CONSTRAINT PK_CONTROL_ID
--  PRIMARY KEY
--  (CONTROL_VACUNA_ID)
--  USING INDEX catalogos.PK_PERSONA_ID
--  ENABLE VALIDATE);

ALTER TABLE SIPAI_MST_CONTROL_VACUNA ADD (
  CONSTRAINT FK_SIPAI_TIPO_VACUNA_ID 
  FOREIGN KEY (TIPO_VACUNA_ID) 
  REFERENCES SIPAI.SIPAI_REL_TIP_VACUNACION_DOSIS(REL_TIPO_VACUNA_ID)
  ENABLE VALIDATE);

ALTER TABLE SIPAI_MST_CONTROL_VACUNA ADD (
  CONSTRAINT FK_SIPAI_SISTEMA_ID 
  FOREIGN KEY (SISTEMA_ID) 
  REFERENCES SEGURIDAD.SCS_CAT_SISTEMAS(SISTEMA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPAI_UNISALUD_ID 
  FOREIGN KEY (UNIDAD_SALUD_ID) 
  REFERENCES CATALOGOS.SBC_CAT_UNIDADES_SALUD(UNIDAD_SALUD_ID)
  ENABLE VALIDATE
  );

ALTER TABLE SIPAI_MST_CONTROL_VACUNA ADD (
  CONSTRAINT FK_SIPAI_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPAI_CEXP_EXPEDIENTE 
  FOREIGN KEY (EXPEDIENTE_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE (EXPEDIENTE_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPAI_PROGRAMA_ID 
  FOREIGN KEY (PROGRAMA_VACUNA_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPAI_GRUPO_PRIORIDAD_ID 
  FOREIGN KEY (GRUPO_PRIORIDAD_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
--  CONSTRAINT FK_SIPAI_TIPO_VACUNA_ID 
--  FOREIGN KEY (TIPO_VACUNA_ID) 
--  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
--  ENABLE VALIDATE,
  CONSTRAINT FK_SIPAI_USR_MODIFCACION 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPAI_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPAI_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE);

