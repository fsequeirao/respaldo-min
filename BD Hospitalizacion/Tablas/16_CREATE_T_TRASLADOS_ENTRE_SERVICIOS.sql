CREATE SEQUENCE HOSPITALARIO.SNH_S_TRALADO_ENTSERV_ID
  START WITH 1
  MAXVALUE 99999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;
    
GRANT ALTER, SELECT ON HOSPITALARIO.SNH_S_TRALADO_ENTSERV_ID TO CATALOGOS, SEGURIDAD, VIGILANCIA, SIPAI; 


CREATE TABLE HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS
(TRASLADO_ID                    NUMBER(10)        DEFAULT HOSPITALARIO.SNH_S_TRALADO_ENTSERV_ID.NEXTVAL CONSTRAINT PRK_TRASLADO_ID PRIMARY KEY NOT NULL, 
 SERVICIO_ORG_ID                NUMBER(10)        CONSTRAINT NNC_TRASSERV_SERVORGID NOT NULL,   
 CFG_USLD_SERVICIO_CAMA_ORG_ID  NUMBER(10)        CONSTRAINT NNC_TRASSERV_CFGUSERV_ORGID NOT NULL, 
 SERVICIO_DEST_ID               NUMBER(10)        CONSTRAINT NNC_TRASSERV_SERVDEST_ID NOT NULL, 
 CFG_USLD_SERVICIO_CAMA_DEST_ID NUMBER(10)        CONSTRAINT NNC_TRASSERV_CFG_USERVC_DESTID NOT NULL, 
 MEDICO_ORDENA_TRASLADO_ID      NUMBER(10)        CONSTRAINT NNC_TRASSERV_MEDICO_TRASLADO NOT NULL,
 MOTIVO_TRASLADO                NUMBER(10)        CONSTRAINT NNC_TRASSERV_MOTIVO_TRASLADO NOT NULL,
 FECHA_TRASLADO                 DATE              CONSTRAINT NNC_TRASSERV_FECHA_TRASLADO NOT NULL,
 HORA_TRASLADO                  VARCHAR2(20)      CONSTRAINT NNC_TRASSERV_HORA_TRASLADO NOT NULL,
 ESTADO_TRASLADO_ID             NUMBER(10)        CONSTRAINT NNC_TRASSERV_ESTADO_TRASLADO NOT NULL,  
 OBSERVACIONES                  VARCHAR2(4000)    CONSTRAINT NNC_TRASSERV_OBSERVACIONES NOT NULL,
 ESTADO_REGISTRO_ID             NUMBER(10)        CONSTRAINT NNC_TRASSERV_ESTADOREG NOT NULL,   
 USUARIO_REGISTRO               VARCHAR2(50 BYTE) CONSTRAINT NNC_TRASSERV_USR_REGISTRO NOT NULL,
 FECHA_REGISTRO                 TIMESTAMP(0)      DEFAULT CURRENT_TIMESTAMP CONSTRAINT NNC_TRASSERV_FEC_REG NOT NULL,
 USUARIO_MODIFICACION           VARCHAR2(50 BYTE),
 FECHA_MODIFICACION             TIMESTAMP(0),
 USUARIO_PASIVA                 VARCHAR2(50 BYTE),
 FECHA_PASIVA                   TIMESTAMP(0),
 USUARIO_ELIMINA                VARCHAR2(50 BYTE),
 FECHA_ELIMINA                  TIMESTAMP(0)   
);



-- estado registro
CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_TRASSERV_ESTREG
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS FOR EACH ROW
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


----- Motivo traslado

CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_TRASSERV_MOTIV_TRAS
BEFORE INSERT OR UPDATE OF MOTIVO_TRASLADO ON HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.MOTIVO_TRASLADO IS NOT NULL AND :NEW.MOTIVO_TRASLADO > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.MOTIVO_TRASLADO AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El motivo traslado, no es un valor valido. Motivo traslado id: '||:NEW.MOTIVO_TRASLADO);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.MOTIVO_TRASLADO AND
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
                                RAISE_APPLICATION_ERROR (-20000, 'El motivo traslado, no es un valor valido. Motivo traslado id: '||:NEW.MOTIVO_TRASLADO);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.MOTIVO_TRASLADO IS NOT NULL THEN
         IF NVL(:NEW.TIPO_DET_NOTA_ID,0) != NVL(:OLD.MOTIVO_TRASLADO,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.MOTIVO_TRASLADO AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El motivo traslado, no es un valor valido. Motivo traslado id: '||:NEW.MOTIVO_TRASLADO);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.MOTIVO_TRASLADO AND
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
                                RAISE_APPLICATION_ERROR (-20000, 'El Motivo traslado, no es un valor valido. Motivo traslado id: '||:NEW.MOTIVO_TRASLADO);                
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


----- estado traslado

CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_TRASSERV_EST_TRASLADO
BEFORE INSERT OR UPDATE OF ESTADO_TRASLADO_ID ON HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.ESTADO_TRASLADO_ID IS NOT NULL AND :NEW.ESTADO_TRASLADO_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.ESTADO_TRASLADO_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El Estado traslado, no es un valor valido. Estado traslado id: '||:NEW.ESTADO_TRASLADO_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.ESTADO_TRASLADO_ID AND
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
                                RAISE_APPLICATION_ERROR (-20000, 'El Estado traslado, no es un valor valido. Estado traslado id: '||:NEW.ESTADO_TRASLADO_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.ESTADO_TRASLADO_ID IS NOT NULL THEN
         IF NVL(:NEW.TIPO_DET_NOTA_ID,0) != NVL(:OLD.ESTADO_TRASLADO_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.ESTADO_TRASLADO_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El Estado traslado, no es un valor valido. Estado traslado id: '||:NEW.ESTADO_TRASLADO_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.ESTADO_TRASLADO_ID AND
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
                                RAISE_APPLICATION_ERROR (-20000, 'El Estado traslado, no es un valor valido. Estado traslado id: '||:NEW.ESTADO_TRASLADO_ID);                
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


CREATE OR REPLACE TRIGGER TRG_AUD_TRASLADO_SERV
BEFORE UPDATE ON HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS FOR EACH ROW
BEGIN
       IF :NEW.USUARIO_MODIFICACION IS NULL THEN
           RAISE_APPLICATION_ERROR (-20000, 'El usuario modificación no puede quedar nulo.');
       ELSE
          :NEW.FECHA_MODIFICACION   := SYSDATE;
       END IF;
END;
/



CREATE INDEX IDX_MPERSNOTA_PESAL_EVONOTA_ID ON HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS
(SERVICIO_ORG_ID);





ALTER TABLE HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS ADD (
  CONSTRAINT FRK_TRASSERV_SERV_ORG_ID 
  FOREIGN KEY (SERVICIO_ORG_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_TRASSERV_CFGSERV_CAMA_ORG 
  FOREIGN KEY (CFG_USLD_SERVICIO_CAMA_ORG_ID) 
  REFERENCES HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS (CFG_USLD_SERVICIO_CAMA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_TRASSERV_SERV_DEST_ID 
  FOREIGN KEY (SERVICIO_DEST_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_TRASSERV_CFGSERV_CAMA_DEST 
  FOREIGN KEY (CFG_USLD_SERVICIO_CAMA_DEST_ID) 
  REFERENCES HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS (CFG_USLD_SERVICIO_CAMA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_TRASSERV_MEDORDENA_TRASL
  FOREIGN KEY (MEDICO_ORDENA_TRASLADO_ID) 
  REFERENCES CATALOGOS.SBC_MST_MINSA_PERSONALES (MINSA_PERSONAL_ID)
  ENABLE VALIDATE,   
  CONSTRAINT FRK_TRASSERV_MOTIVO_TRASLADO 
  FOREIGN KEY (MOTIVO_TRASLADO) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_TRASSERV_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE --,
--  CONSTRAINT FRK_TRASSERV_USR_REGISTRO 
--  FOREIGN KEY (USUARIO_REGISTRO) 
--  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
--  ENABLE VALIDATE,
--  CONSTRAINT FRK_TRASSERV_USR_MOD 
--  FOREIGN KEY (USUARIO_MODIFICACION) 
--  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
--  ENABLE VALIDATE,
--  CONSTRAINT FRK_TRASSERV_USR_PASIVO 
--  FOREIGN KEY (USUARIO_PASIVA) 
--  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
--  ENABLE VALIDATE,
--  CONSTRAINT FRK_TRASSERV_USR_ELIMINA 
--  FOREIGN KEY (USUARIO_ELIMINA) 
--  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
--  ENABLE VALIDATE    
  );
