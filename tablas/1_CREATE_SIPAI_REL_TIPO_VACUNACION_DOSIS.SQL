CREATE SEQUENCE SIPAI_S_REL_VACUNA_DOSIS_ID
  START WITH 1
  MAXVALUE 999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;
  
  
CREATE TABLE SIPAI_REL_TIP_VACUNACION_DOSIS
(
  REL_TIPO_VACUNA_ID            NUMBER(10) CONSTRAINT PK_SIPREL_VACUNA_DOSIS_ID PRIMARY KEY NOT NULL,
  TIPO_VACUNA_ID                NUMBER(10) CONSTRAINT NNC_SIPREL_TIPO_VACUNA_ID NOT NULL,
  FABRICANTE_VACUNA_ID          NUMBER(10),
  ESTADO_REGISTRO_ID            NUMBER(10) CONSTRAINT NNC_SIPREL_ESTADO_REG_ID NOT NULL,
  CANTIDAD_DOSIS                NUMBER(10) CONSTRAINT NNC_SIPREL_CANTIDAD NOT NULL,  
  SISTEMA_ID                    NUMBER(10) CONSTRAINT NNC_SIPREL_SISTEMA NOT NULL,
  UNIDAD_SALUD_ID               NUMBER(10) CONSTRAINT NNC_SIPREL_USALUD NOT NULL,  
  USUARIO_REGISTRO              VARCHAR2(50 BYTE) CONSTRAINT NNC_SIPREL_USR_REGISTRO NOT NULL,
  FECHA_REGISTRO                TIMESTAMP(0)   DEFAULT SYSTIMESTAMP CONSTRAINT NNC_SIPREL_FECHA_REGISTRO NOT NULL,
  USUARIO_MODIFICACION          VARCHAR2(50 BYTE),
  FECHA_MODIFICACION            TIMESTAMP(0),
  USUARIO_PASIVA                VARCHAR2(50 BYTE),
  FECHA_PASIVO                  TIMESTAMP(0),
  NUMERO_LOTE                   VARCHAR2(30),
  FECHA_VENCIMIENTO             TIMESTAMP(0)
  );
  

CREATE UNIQUE INDEX IDX_UI_SIPREL_TIPO_VACUNA_ID ON SIPAI_REL_TIP_VACUNACION_DOSIS
(REL_TIPO_VACUNA_ID);

CREATE INDEX IDX_SIPREL_TIPO_VACUNA_ID ON SIPAI_REL_TIP_VACUNACION_DOSIS
(TIPO_VACUNA_ID);

CREATE INDEX IDX_SIPREL_FAB_VACUNA ON SIPAI_REL_TIP_VACUNACION_DOSIS
(FABRICANTE_VACUNA_ID);

CREATE INDEX IDX_SIPREL_ESTADO_ID ON SIPAI_REL_TIP_VACUNACION_DOSIS
(ESTADO_REGISTRO_ID);


CREATE INDEX IDX_SIPREL_CANT_DOSIS ON SIPAI_REL_TIP_VACUNACION_DOSIS
(CANTIDAD_DOSIS);

CREATE UNIQUE INDEX SIPAI.UNIQ_IDX_REL_TIP_VAC ON SIPAI.SIPAI_REL_TIP_VACUNACION_DOSIS
(TIPO_VACUNA_ID, FABRICANTE_VACUNA_ID);
  
CREATE OR REPLACE TRIGGER TRG_AUD_SIPREL_TIP_VAC_DOSIS
BEFORE INSERT OR UPDATE ON SIPAI_REL_TIP_VACUNACION_DOSIS FOR EACH ROW
BEGIN
    IF INSERTING THEN
       :NEW.REL_TIPO_VACUNA_ID  := SIPAI.SIPAI_S_REL_VACUNA_DOSIS_ID.NEXTVAL;
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
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPREL_ESTADO_REGISTRO
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON SIPAI.SIPAI_REL_TIP_VACUNACION_DOSIS FOR EACH ROW
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


-- Tipo vacuna
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPREL_TIPO_VACUNA
BEFORE INSERT OR UPDATE OF TIPO_VACUNA_ID ON SIPAI.SIPAI_REL_TIP_VACUNACION_DOSIS FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.TIPO_VACUNA_ID IS NOT NULL AND :NEW.TIPO_VACUNA_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.TIPO_VACUNA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El tipo vacuna, no es un valor valido. Tipo vacuna id: '||:NEW.TIPO_VACUNA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.TIPO_VACUNA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'TIP_VAC_SIPAI';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El tipo vacuna, no es un valor valido. Tipo vacuna id: '||:NEW.TIPO_VACUNA_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.TIPO_VACUNA_ID IS NOT NULL THEN
         IF NVL(:NEW.TIPO_VACUNA_ID,0) != NVL(:OLD.TIPO_VACUNA_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.TIPO_VACUNA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El tipo vacuna, no es un valor valido. Tipo vacuna id: '||:NEW.TIPO_VACUNA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.TIPO_VACUNA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'TIP_VAC_SIPAI';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El tipo vacuna, no es un valor valido. Tipo vacuna id: '||:NEW.TIPO_VACUNA_ID);                
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

-- fabricante
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPREL_FABRICANTE_VACUNA
BEFORE INSERT OR UPDATE OF FABRICANTE_VACUNA_ID ON SIPAI.SIPAI_REL_TIP_VACUNACION_DOSIS FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.FABRICANTE_VACUNA_ID IS NOT NULL AND :NEW.FABRICANTE_VACUNA_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.FABRICANTE_VACUNA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El fabricante, no es un valor valido. Fabricante id: '||:NEW.FABRICANTE_VACUNA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.FABRICANTE_VACUNA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'FAB_VAC';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El fabricante, no es un valor valido. Fabricante id: '||:NEW.FABRICANTE_VACUNA_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.FABRICANTE_VACUNA_ID IS NOT NULL THEN
         IF NVL(:NEW.FABRICANTE_VACUNA_ID,0) != NVL(:OLD.FABRICANTE_VACUNA_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.FABRICANTE_VACUNA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El fabricante, no es un valor valido. Fabricante id: '||:NEW.FABRICANTE_VACUNA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.FABRICANTE_VACUNA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'FAB_VAC';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El fabricante, no es un valor valido. Fabricante id: '||:NEW.FABRICANTE_VACUNA_ID);                
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

--ALTER TABLE SIPAI_DET_VACUNACION ADD (
--  CONSTRAINT PK_CONTROL_ID
--  PRIMARY KEY
--  (CONTROL_VACUNA_ID)
--  USING INDEX catalogos.PK_PERSONA_ID
--  ENABLE VALIDATE);

ALTER TABLE SIPAI_REL_TIP_VACUNACION_DOSIS ADD (
  CONSTRAINT FK_SIPREL_SISTEMA_ID 
  FOREIGN KEY (SISTEMA_ID) 
  REFERENCES SEGURIDAD.SCS_CAT_SISTEMAS(SISTEMA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPREL_UNISALUD_ID 
  FOREIGN KEY (UNIDAD_SALUD_ID) 
  REFERENCES CATALOGOS.SBC_CAT_UNIDADES_SALUD(UNIDAD_SALUD_ID)
  ENABLE VALIDATE
  );

ALTER TABLE SIPAI_REL_TIP_VACUNACION_DOSIS ADD (
  CONSTRAINT FK_SIPREL_TIP_VACUNA_ID 
  FOREIGN KEY (TIPO_VACUNA_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPREL_TIP_FABRICANTE_ID 
  FOREIGN KEY (FABRICANTE_VACUNA_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPREL_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPREL_USR_MODIFCACION 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPREL_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_SIPREL_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE);

