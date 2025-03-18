CREATE SEQUENCE HOSPITALARIO.SNH_S_MPERS_NOTA_ID
  START WITH 1
  MAXVALUE 99999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;
    
GRANT ALTER, SELECT ON HOSPITALARIO.SNH_S_MPERS_NOTA_ID TO CATALOGOS, SEGURIDAD, VIGILANCIA, SIPAI; 



CREATE TABLE HOSPITALARIO.SNH_REL_MPERS_NOTA
(REL_MPERS_NOTA_ID       NUMBER(10)        DEFAULT HOSPITALARIO.SNH_S_MPERS_NOTA_ID.NEXTVAL CONSTRAINT PRK_MPERSNOTA_ID PRIMARY KEY NOT NULL,  
 PERSALUD_EVO_NOTA_ID    NUMBER(10)        CONSTRAINT NNC_MPERSNOTA_EVO_NOTA_ID NOT NULL, 
 MPERS_SALUD_ID          NUMBER(10)        CONSTRAINT NNC_MPERSNOTA_MPERSSALUD_ID NOT NULL,
 ES_PRINCIPAL            NUMBER(10)        CONSTRAINT NNC_MPERSNOTA_PRINCIPAL NOT NULL,
 ESTADO_REGISTRO_ID      NUMBER(10)        CONSTRAINT NNC_MPERSNOTA_ESTADOREG NOT NULL,   
 USUARIO_REGISTRO        VARCHAR2(50 BYTE) CONSTRAINT NNC_MPERSNOTA_USR_REGISTRO NOT NULL,
 FECHA_REGISTRO          TIMESTAMP(0)      DEFAULT CURRENT_TIMESTAMP CONSTRAINT NNC_MPERSNOTA_FEC_REG NOT NULL,
 USUARIO_MODIFICACION    VARCHAR2(50 BYTE),
 FECHA_MODIFICACION      TIMESTAMP(0),
 USUARIO_PASIVA          VARCHAR2(50 BYTE),
 FECHA_PASIVA            TIMESTAMP(0),
 USUARIO_ELIMINA         VARCHAR2(50 BYTE),
 FECHA_ELIMINA           TIMESTAMP(0)   
);




CREATE INDEX IDX_MPERSNOTA_PESAL_EVONOTA_ID ON HOSPITALARIO.SNH_REL_MPERS_NOTA
(PERSALUD_EVO_NOTA_ID);

CREATE INDEX IDX_MPERSNOTA_MPERS_EVONOTA_ID ON HOSPITALARIO.SNH_REL_MPERS_NOTA
(MPERS_SALUD_ID, PERSALUD_EVO_NOTA_ID);

CREATE INDEX IDX_MPERSNOTA_PRIN_EVONOTA ON HOSPITALARIO.SNH_REL_MPERS_NOTA
(PERSALUD_EVO_NOTA_ID, ES_PRINCIPAL);


CREATE INDEX IDX_MPERSNOTA_ES_PRINCIPAL ON HOSPITALARIO.SNH_REL_MPERS_NOTA
(ES_PRINCIPAL);

CREATE INDEX IDX_MPERSNOTA_ESTADOREG ON HOSPITALARIO.SNH_REL_MPERS_NOTA
(ESTADO_REGISTRO_ID);

CREATE INDEX IDX_MPERSNOTA_FEC_REG ON HOSPITALARIO.SNH_REL_MPERS_NOTA
(TRUNC(FECHA_REGISTRO));



-- estado registro
CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_MPERSNOTA_ESTADO_REG
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON HOSPITALARIO.SNH_REL_MPERS_NOTA FOR EACH ROW
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


CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_DETNOTAS_TIPNOTA
BEFORE INSERT OR UPDATE OF TIPO_DET_NOTA_ID ON HOSPITALARIO.SNH_REL_MPERS_NOTA FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.TIPO_DET_NOTA_ID IS NOT NULL AND :NEW.TIPO_DET_NOTA_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.TIPO_DET_NOTA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El Tipo de nota, no es un valor valido. Tipo Nota id: '||:NEW.TIPO_DET_NOTA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.TIPO_DET_NOTA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'TPINSTNT';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El Tipo de nota, no es un valor valido. Tipo Nota id: '||:NEW.TIPO_DET_NOTA_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.TIPO_DET_NOTA_ID IS NOT NULL THEN
         IF NVL(:NEW.TIPO_DET_NOTA_ID,0) != NVL(:OLD.TIPO_DET_NOTA_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.TIPO_DET_NOTA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El Tipo de nota, no es un valor valido. Tipo Nota id: '||:NEW.TIPO_DET_NOTA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.TIPO_DET_NOTA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'TPINSTNT';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El Tipo de nota, no es un valor valido. Tipo Nota id: '||:NEW.TIPO_NOTA_ID);                
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

CREATE OR REPLACE TRIGGER TRG_AUD_MPERSNOTA_RELNOTAS
BEFORE UPDATE ON HOSPITALARIO.SNH_REL_MPERS_NOTA FOR EACH ROW
BEGIN
       IF :NEW.USUARIO_MODIFICACION IS NULL THEN
           RAISE_APPLICATION_ERROR (-20000, 'El usuario modificación no puede quedar nulo.');
       ELSE
       :NEW.FECHA_MODIFICACION   := SYSDATE;
       END IF;
END;
/


ALTER TABLE HOSPITALARIO.SNH_REL_MPERS_NOTA ADD (
  CONSTRAINT FRK_MPERSNOTA_ADMIN_SERV_ID
  FOREIGN KEY (PERSALUD_EVO_NOTA_ID) 
  REFERENCES HOSPITALARIO.SNH_DET_NOTAS (PERSALUD_EVO_NOTA_ID)
  ENABLE VALIDATE, 
  CONSTRAINT FRK_MPERSNOTA_MPERSSALUD_ID
  FOREIGN KEY (MPERS_SALUD_ID) 
  REFERENCES CATALOGOS.SBC_MST_MPERS_SALUD (MPERS_SALUD_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_MPERSNOTA_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_MPERSNOTA_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_MPERSNOTA_USR_MOD 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_MPERSNOTA_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_MPERSNOTA_USR_ELIMINA 
  FOREIGN KEY (USUARIO_ELIMINA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE    
  );


--
--SELECT *
--FROM CATALOGOS.SBC_CAT_CATALOGOS
--WHERE UPPER(CODIGO) LIKE '%%TPINSTNT%';
--
--
--SELECT *
--FROM CATALOGOS.SBC_CAT_CATALOGOS
--WHERE CATALOGO_SUP = 8184;
--
--
--SELECT *
--FROM CATALOGOS.SBC_CAT_CATALOGOS
--WHERE CATALOGO_SUP = 8185