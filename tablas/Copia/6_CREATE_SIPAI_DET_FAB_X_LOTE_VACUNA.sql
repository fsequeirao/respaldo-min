CREATE SEQUENCE SIPAI_S_DET_FAB_X_LOTE
  START WITH 1
  MAXVALUE 999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;

CREATE TABLE SIPAI_DET_TIPVAC_X_LOTE
(
  DETALLE_VACUNA_X_LOTE_ID      NUMBER(10) CONSTRAINT PK_SIPDET_TIPVAC_LOTE_ID PRIMARY KEY NOT NULL,
  REL_TIPO_VACUNA_ID            NUMBER(10) CONSTRAINT NNC_SIPTIPVACLOTE_TIPVAC_ID NOT NULL,
  NUM_LOTE                      VARCHAR2(30) CONSTRAINT NNC_SIPTIPVACLOTE_LOTE NOT NULL,
  FECHA_VENCIMIENTO             TIMESTAMP(0) CONSTRAINT NNC_SIPTIPVACLOTE_FECVEN NOT NULL,
  ESTADO_REGISTRO_ID            NUMBER(10) CONSTRAINT NNC_SIPTIPVACLOTE_EST_REG_ID NOT NULL,
  SISTEMA_ID                    NUMBER(10) CONSTRAINT NNC_SIPTIPVACLOTE_SISTEMA NOT NULL,
  UNIDAD_SALUD_ID               NUMBER(10) CONSTRAINT NNC_SIPTIPVACLOTE_USALUD NOT NULL,   
  USUARIO_REGISTRO              VARCHAR2(50 BYTE) CONSTRAINT NNC_SIPTIPVACLOTE_USR_REGISTRO NOT NULL,
  FECHA_REGISTRO                TIMESTAMP(0)   DEFAULT SYSTIMESTAMP CONSTRAINT NNC_SIPTIPVACLOTE_FEC_REGISTRO NOT NULL,
  USUARIO_MODIFICACION          VARCHAR2(50 BYTE),
  FECHA_MODIFICACION            TIMESTAMP(0),
  USUARIO_PASIVA                VARCHAR2(50 BYTE),
  FECHA_PASIVO                  TIMESTAMP(0)
  );

CREATE INDEX IDX_SIP_TIPVACUNA_LOTE_ID ON SIPAI_DET_TIPVAC_X_LOTE
(DETALLE_VACUNA_X_LOTE_ID);

CREATE INDEX IDX_SIP_TIPVACUNA_LOTE_ESTADO ON SIPAI_DET_TIPVAC_X_LOTE
(ESTADO_REGISTRO_ID);

CREATE INDEX IDX_SIP_TIPVAC_LOTE_RELTIP_ID ON SIPAI_DET_TIPVAC_X_LOTE
(REL_TIPO_VACUNA_ID);

CREATE INDEX IDX_SIP_TIPVAC_LOTE_NUM ON SIPAI_DET_TIPVAC_X_LOTE
(NUM_LOTE);

CREATE INDEX IDX_SIP_TIPVAC_LOTE_FEC_VENC ON SIPAI_DET_TIPVAC_X_LOTE
(TRUNC(FECHA_VENCIMIENTO));

CREATE UNIQUE INDEX IDX_SIP_TIPVACUNA_LOTE_FECVEN ON SIPAI_DET_TIPVAC_X_LOTE
(REL_TIPO_VACUNA_ID, NUM_LOTE, TRUNC(FECHA_VENCIMIENTO));



CREATE OR REPLACE TRIGGER TRG_AUD_SIPVACUNA_LOTE
BEFORE INSERT OR UPDATE ON SIPAI_DET_TIPVAC_X_LOTE FOR EACH ROW
BEGIN
    IF INSERTING THEN
       :NEW.DETALLE_VACUNA_X_LOTE_ID  := SIPAI.SIPAI_S_DET_FAB_X_LOTE.NEXTVAL;
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
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPVAC_LOTE_ESTADO
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON SIPAI.SIPAI_DET_TIPVAC_X_LOTE FOR EACH ROW
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

--- Fecha vencimiento
CREATE OR REPLACE TRIGGER SIPAI.TRG_SIPVACUNA_FEC_VENCIMIENTO
BEFORE INSERT OR UPDATE OF FECHA_VENCIMIENTO ON SIPAI.SIPAI_DET_TIPVAC_X_LOTE FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF :NEW.FECHA_VENCIMIENTO IS NOT NULL THEN
         IF TRUNC(:NEW.FECHA_VENCIMIENTO) < TRUNC(SYSDATE) THEN
              RAISE_APPLICATION_ERROR (-20000, 'La fecha de vencimiento no puede ser menor al dia de hoy.');
         END IF;
      END IF;
    ELSIF UPDATING THEN
      IF :NEW.FECHA_VENCIMIENTO IS NOT NULL THEN
         IF TRUNC(:NEW.FECHA_VENCIMIENTO) < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR (-20000, 'La fecha de vencimiento no puede ser menor al dia de hoy');
         END IF;
      END IF;
    END IF;
END;
/



ALTER TABLE SIPAI_DET_TIPVAC_X_LOTE ADD (
  CONSTRAINT FK_TIPVACUNA_SISTEMA_ID 
  FOREIGN KEY (SISTEMA_ID) 
  REFERENCES SEGURIDAD.SCS_CAT_SISTEMAS(SISTEMA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_TIPVACUNA_UNISALUD_ID 
  FOREIGN KEY (UNIDAD_SALUD_ID) 
  REFERENCES CATALOGOS.SBC_CAT_UNIDADES_SALUD(UNIDAD_SALUD_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_TIPVACUNA_RELTIPVAC_ID 
  FOREIGN KEY (REL_TIPO_VACUNA_ID) 
  REFERENCES SIPAI.SIPAI_REL_TIP_VACUNACION_DOSIS (REL_TIPO_VACUNA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FK_TIPVACUNA_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FKS_TIPVACUNA_USR_MODIFCACION 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_TIPVACUNA_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FK_TIPVACUNA_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE);  
  
  
  
  );