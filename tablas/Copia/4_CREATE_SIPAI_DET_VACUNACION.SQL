CREATE SEQUENCE SIPAI_S_DET_VACUNA_ID
  START WITH 1
  MAXVALUE 999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;
  
  
CREATE TABLE SIPAI_DET_VACUNACION
(
  DET_VACUNACION_ID             NUMBER(10) CONSTRAINT PK_SIPDET_VACUNA_ID PRIMARY KEY NOT NULL,
  CONTROL_VACUNA_ID             NUMBER(10) CONSTRAINT NNC_SIPDET_CONTROL_VACUNA_ID NOT NULL,
  FECHA_VACUNACION              DATE CONSTRAINT NNC_SIPDET_FEC_VACUNACION NOT NULL,
  HORA_VACUNACION               TIMESTAMP(0),
  NUMERO_LOTE                   VARCHAR2(30 BYTE),
  FECHA_VENCIMIENTO             TIMESTAMP(0),  
  PERSONAL_VACUNA_ID            NUMBER(10) CONSTRAINT NNC_SIPDET_PERSONAL_VACUNA_ID NOT NULL,
  VIA_ADMINISTRACION_ID         NUMBER(10) CONSTRAINT NNC_SIPDET_VIA_ADMIN_ID NOT NULL,
  ESTADO_REGISTRO_ID            NUMBER(10) CONSTRAINT NNC_SIPDET_ESTADO_REG_ID NOT NULL,
  SISTEMA_ID                    NUMBER(10) CONSTRAINT NNC_SIPDET_SISTEMA NOT NULL,
  UNIDAD_SALUD_ID               NUMBER(10) CONSTRAINT NNC_SIPDET_USALUD NOT NULL,  
  USUARIO_REGISTRO              VARCHAR2(50 BYTE) CONSTRAINT NNC_SIPDET_USR_REGISTRO NOT NULL,
  FECHA_REGISTRO                TIMESTAMP(0)   DEFAULT SYSTIMESTAMP CONSTRAINT NNC_SIPDET_FECHA_REGISTRO NOT NULL,
  USUARIO_MODIFICACION          VARCHAR2(50 BYTE),
  FECHA_MODIFICACION            TIMESTAMP(0),
  USUARIO_PASIVA                VARCHAR2(50 BYTE),
  FECHA_PASIVO                  TIMESTAMP(0)
  );
  

CREATE UNIQUE INDEX IDX_UI_SIPDET_DET_VACUNA_ID ON SIPAI_DET_VACUNACION
(DET_VACUNACION_ID);

CREATE INDEX IDX_SIPDET_CONTROL_ID ON SIPAI_DET_VACUNACION
(CONTROL_VACUNA_ID);

CREATE INDEX IDX_SIDET_FEC_VACUNACION ON SIPAI_DET_VACUNACION
(FECHA_VACUNACION);

CREATE INDEX IDX_SIPDET_NUM_LOTE ON SIPAI_DET_VACUNACION
(NUMERO_LOTE);


CREATE UNIQUE INDEX SIPAI.UNIQ_IDX_DET_X_FECHA ON SIPAI.SIPAI_DET_VACUNACION
(CONTROL_VACUNA_ID, TRUNC(FECHA_VACUNACION));


  
CREATE OR REPLACE TRIGGER TRG_AUD_SIDET_VACUNACION
BEFORE INSERT OR UPDATE ON SIPAI_DET_VACUNACION FOR EACH ROW
BEGIN
    IF INSERTING THEN
       :NEW.DET_VACUNACION_ID  := SIPAI_S_DET_VACUNA_ID.NEXTVAL;
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

CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPDET_ESTADO_REGISTRO
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON SIPAI.SIPAI_DET_VACUNACION FOR EACH ROW
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


-- Via administracion
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPDET_VIA_ADMINISTRACION
BEFORE INSERT OR UPDATE OF VIA_ADMINISTRACION_ID ON SIPAI.SIPAI_DET_VACUNACION FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.VIA_ADMINISTRACION_ID IS NOT NULL AND :NEW.VIA_ADMINISTRACION_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.VIA_ADMINISTRACION_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'Via administración de la vacuna, no es un valor valido. Via administración id: '||:NEW.VIA_ADMINISTRACION_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.VIA_ADMINISTRACION_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'VIA_ADM_VAC';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'Via administración de la vacuna, no es un valor valido. Via administración id: '||:NEW.VIA_ADMINISTRACION_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.VIA_ADMINISTRACION_ID IS NOT NULL THEN
         IF NVL(:NEW.VIA_ADMINISTRACION_ID,0) != NVL(:OLD.VIA_ADMINISTRACION_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.VIA_ADMINISTRACION_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'Via administración de la vacuna, no es un valor valido. Via administración id: '||:NEW.VIA_ADMINISTRACION_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.VIA_ADMINISTRACION_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'VIA_ADM_VAC';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'Via administración de la vacuna, no es un valor valido. Via administración id: '||:NEW.VIA_ADMINISTRACION_ID);                
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

CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPAI_DET_FEC_VACUNACION
BEFORE INSERT OR UPDATE OF FECHA_VACUNACION ON SIPAI.SIPAI_DET_VACUNACION FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF :NEW.FECHA_VACUNACION IS NOT NULL THEN
         IF TRUNC(:NEW.FECHA_VACUNACION) > TRUNC(SYSDATE) THEN
              RAISE_APPLICATION_ERROR (-20000, 'La fecha de vacunación no puede ser mayor al día de hoy.');
         END IF;
      END IF;
    ELSIF UPDATING THEN
      IF :NEW.FECHA_VACUNACION IS NOT NULL THEN
         IF TRUNC(:NEW.FECHA_VACUNACION) > TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR (-20000, 'La fecha de vacunación no puede ser mayor al día de hoy.');
         END IF;
      END IF;
    END IF;
END;
/


--ALTER TABLE SIPAI_DET_VACUNACION ADD (
--  CONSTRAINT PK_CONTROL_ID
--  PRIMARY KEY
--  (CONTROL_VACUNA_ID)
--  USING INDEX catalogos.PK_PERSONA_ID
--  ENABLE VALIDATE);

ALTER TABLE SIPAI_DET_VACUNACION ADD (
  CONSTRAINT FK_SIPDET_SISTEMA_ID 
  FOREIGN KEY (SISTEMA_ID) 
  REFERENCES SEGURIDAD.SCS_CAT_SISTEMAS(SISTEMA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPDET_UNISALUD_ID 
  FOREIGN KEY (UNIDAD_SALUD_ID) 
  REFERENCES CATALOGOS.SBC_CAT_UNIDADES_SALUD(UNIDAD_SALUD_ID)
  ENABLE VALIDATE
  );


ALTER TABLE SIPAI_DET_VACUNACION ADD DETALLE_VACUNA_X_LOTE_ID NUMBER (10);

  SIPAI_DET_TIPVAC_X_LOTE.DETALLE_VACUNA_X_LOTE_ID%TYPE,

ALTER TABLE SIPAI_DET_VACUNACION ADD (
  CONSTRAINT FK_SIPDET_DETVA_LOTEFECVEN 
  FOREIGN KEY (DETALLE_VACUNA_X_LOTE_ID) 
  REFERENCES SIPAI.SIPAI_DET_TIPVAC_X_LOTE(DETALLE_VACUNA_X_LOTE_ID)
  ENABLE VALIDATE
);

ALTER TABLE SIPAI_DET_VACUNACION ADD (
  CONSTRAINT FK_SIPDET_CONTROL_VACUNA_ID 
  FOREIGN KEY (CONTROL_VACUNA_ID) 
  REFERENCES SIPAI_MST_CONTROL_VACUNA (CONTROL_VACUNA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPDET_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,

  CONSTRAINT FK_SIPDET_VIA_ADMIN_ID 
  FOREIGN KEY (VIA_ADMINISTRACION_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,

  CONSTRAINT FK_SIPDET_PERSONAL_VACUNA 
  FOREIGN KEY (PERSONAL_VACUNA_ID) 
  REFERENCES SIPAI_DET_PERSONAL_VACUNA (PERSONAL_VACUNA_ID)
  ENABLE VALIDATE,



  CONSTRAINT FK_SIPDET_USR_MODIFCACION 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPDET_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPDET_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE);

