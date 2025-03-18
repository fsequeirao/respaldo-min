CREATE SEQUENCE SIPAI_S_PER_VAC_ENF_CRON_ID
  START WITH 1
  MAXVALUE 999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;

CREATE TABLE SIPAI.SIPAI_PER_VACUNADA_ENF_CRON
(
  DET_PER_X_ENFCRON_ID    NUMBER(10)        CONSTRAINT PK_SIPPERCRONIC_ID PRIMARY KEY NOT NULL,
  EXPEDIENTE_ID           NUMBER(10)        CONSTRAINT NNC_SIPPERCRONIC_EXP_ID NOT NULL,
  ENF_CRONICA_ID          NUMBER(10)        CONSTRAINT NNC_SIPPERCRONIC_ENFER_ID NOT NULL,
  ESTADO_REGISTRO_ID      NUMBER(10)        CONSTRAINT NNC_SIPPERCRONIC_ESTADO_REG NOT NULL,
  USUARIO_REGISTRO        VARCHAR2(50 BYTE) CONSTRAINT NNC_SIPPERCRONIC_USR_REG NOT NULL,
  FECHA_REGISTRO          TIMESTAMP(0)      DEFAULT SYSTIMESTAMP CONSTRAINT NNC_SIPPERCRONIC_FEC_REG NOT NULL,
  USUARIO_MODIFICACION    VARCHAR2(50 BYTE),
  FECHA_MODIFICACION      TIMESTAMP(0),
  USUARIO_PASIVA          VARCHAR2(50 BYTE),
  FECHA_PASIVO            TIMESTAMP(0)
);


CREATE UNIQUE INDEX PK_SVSC_DET_SEG_ID ON SIPAI.SIPAI_PER_VACUNADA_ENF_CRON
(DET_PER_X_ENFCRON_ID);


CREATE INDEX IDX_SIPAI_PERENFER_EXP_ID ON SIPAI_PER_VACUNADA_ENF_CRON
(EXPEDIENTE_ID);


--CREATE INDEX IDX_SIPAI_PERENFER_EXP_ID_ENFI ON SIPAI_PER_VACUNADA_ENF_CRON
--(EXPEDIENTE_ID, ENF_CRONICA_ID);

CREATE UNIQUE INDEX IDX_SIPAI_PERENFER_EXP_ID_ENFI ON SIPAI_PER_VACUNADA_ENF_CRON
(EXPEDIENTE_ID, ENF_CRONICA_ID);



CREATE INDEX IDX_SIPAI_PERENFER_ENFID ON SIPAI_PER_VACUNADA_ENF_CRON
(ENF_CRONICA_ID);

  
CREATE OR REPLACE TRIGGER TRG_AUD_SIPAI_PER_X_ENFER
BEFORE INSERT OR UPDATE ON SIPAI_PER_VACUNADA_ENF_CRON FOR EACH ROW
BEGIN
    IF INSERTING THEN
       :NEW.DET_PER_X_ENFCRON_ID  := SIPAI_S_PER_VAC_ENF_CRON_ID.NEXTVAL;
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
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPAI_PERENFER_ESTADO
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON SIPAI.SIPAI_PER_VACUNADA_ENF_CRON FOR EACH ROW
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


-- Enfermedades cronicas
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPAI_PERENFER_ENFERCRON
BEFORE INSERT OR UPDATE OF ENF_CRONICA_ID ON SIPAI.SIPAI_PER_VACUNADA_ENF_CRON FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.ENF_CRONICA_ID IS NOT NULL AND :NEW.ENF_CRONICA_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.ENF_CRONICA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El registro no es un valor valido. Enfermedad crónica id: '||:NEW.ENF_CRONICA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.ENF_CRONICA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'ENFER_CRONICOS';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El registro no es un valor valido. Enfermedad crónica id: '||:NEW.ENF_CRONICA_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.ENF_CRONICA_ID IS NOT NULL THEN
         IF NVL(:NEW.ENF_CRONICA_ID,0) != NVL(:OLD.ENF_CRONICA_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.ENF_CRONICA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El registro no es un valor valido. Enfermedad crónica id: '||:NEW.ENF_CRONICA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.ENF_CRONICA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'ENFER_CRONICOS';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El registro no es un valor valido. Enfermedad crónica id: '||:NEW.ENF_CRONICA_ID);                
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



ALTER TABLE VIGILANCIA.SVSC_REL_SEGUIMIENTO_SINTOMAS ADD (
  CONSTRAINT PK_SVSC_DET_SEG_ID
  PRIMARY KEY
  (DETALLE_SEGUIMIENTO_ID)
  USING INDEX VIGILANCIA.PK_SVSC_DET_SEG_ID
  ENABLE VALIDATE);

ALTER TABLE SIPAI.SIPAI_PER_VACUNADA_ENF_CRON ADD (
  CONSTRAINT FK_PERENFER_ESTADO_REG 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_PERENFER_EXP_ID 
  FOREIGN KEY (EXPEDIENTE_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE (EXPEDIENTE_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_PERENFER_ENFERMEDAD_ID 
  FOREIGN KEY (ENF_CRONICA_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_PERENFER_USR_MODIFCACION 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_PERENFER_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_PERENFER_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE);

GRANT DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE ON SIPAI.SIPAI_PER_VACUNADA_ENF_CRON TO PUBLIC;
