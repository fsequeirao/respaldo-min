CREATE SEQUENCE HOSPITALARIO.SNH_S_MST_NOTAS_ID
  START WITH 1
  MAXVALUE 99999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;

GRANT ALTER, SELECT ON HOSPITALARIO.SNH_S_MST_NOTAS_ID TO CATALOGOS, SEGURIDAD, VIGILANCIA, SIPAI; 



CREATE TABLE HOSPITALARIO.SNH_MST_NOTAS
(DET_NOTA_ID             NUMBER(10)        DEFAULT HOSPITALARIO.SNH_S_MST_NOTAS_ID.NEXTVAL CONSTRAINT PRK_MSTNOTAS_ID PRIMARY KEY NOT NULL,
 ADMISION_SERVICIO_ID    NUMBER(10)        CONSTRAINT NNC_MSTNOTAS_ADM_SERV_ID NOT NULL,
 FECHA_NOTA              TIMESTAMP(0)      CONSTRAINT NNC_MSTNOTAS_FEC_NOTA NOT NULL,
 HORA_NOTA               VARCHAR2(10 BYTE) CONSTRAINT NNC_MSTNOTAS_HR_NOTA NOT NULL,
 MPERS_SALUD_ID          NUMBER(10)        CONSTRAINT NNC_MSTNOTAS_MPERSSALUD_ID NOT NULL,
 TIPO_NOTA_ID            NUMBER(10)        CONSTRAINT NNC_MSTNOTAS_TIPO_NOTA_ID NOT NULL,
 ESTADO_REGISTRO_ID      NUMBER(10)        CONSTRAINT NNC_MSTNOTAS_ESTADOREG NOT NULL,   
 USUARIO_REGISTRO        VARCHAR2(50 BYTE) CONSTRAINT NNC_MSTNOTAS_USR_REGISTRO NOT NULL,
 FECHA_REGISTRO          TIMESTAMP(0)      DEFAULT CURRENT_TIMESTAMP CONSTRAINT NNC_MSTNOTAS_FEC_REGISTRO NOT NULL,
 USUARIO_MODIFICACION    VARCHAR2(50 BYTE),
 FECHA_MODIFICACION      TIMESTAMP(0),
 USUARIO_PASIVA          VARCHAR2(50 BYTE),
 FECHA_PASIVA            TIMESTAMP(0),
 USUARIO_ELIMINA         VARCHAR2(50 BYTE),
 FECHA_ELIMINA           TIMESTAMP(0)   
);




CREATE INDEX IDX_MSTNOTAS_ADMINSERV ON HOSPITALARIO.SNH_MST_NOTAS
(ADMISION_SERVICIO_ID);

CREATE INDEX IDX_MSTNOTA_ADMINSERV_EST ON HOSPITALARIO.SNH_MST_NOTAS
(ADMISION_SERVICIO_ID, ESTADO_REGISTRO_ID);


CREATE INDEX IDX_MSTNOTA_TIPO_NOTA ON HOSPITALARIO.SNH_MST_NOTAS
(TIPO_NOTA_ID);

CREATE INDEX IDX_MSTNOTA_ADMINSERV_TIPO_NOTA ON HOSPITALARIO.SNH_MST_NOTAS
(ADMISION_SERVICIO_ID, TIPO_NOTA_ID);



CREATE INDEX IDX_MSTNOTA_MPERSSALUD ON HOSPITALARIO.SNH_MST_NOTAS
(MPERS_SALUD_ID);



CREATE INDEX IDX_MSTNOTA_ESTADOREG ON HOSPITALARIO.SNH_MST_NOTAS
(ESTADO_REGISTRO_ID);

CREATE INDEX IDX_MSTNOTA_FEC_NOTA ON HOSPITALARIO.SNH_MST_NOTAS
(TRUNC(FECHA_NOTA));



-- estado registro
CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_MSTNOTA_ESTADO_REG
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON HOSPITALARIO.SNH_MST_NOTAS FOR EACH ROW
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


CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_MSTNOTA_TIPNOTA
BEFORE INSERT OR UPDATE OF TIPO_NOTA_ID ON HOSPITALARIO.SNH_MST_NOTAS FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.TIPO_NOTA_ID IS NOT NULL AND :NEW.TIPO_NOTA_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.TIPO_NOTA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El Tipo de nota, no es un valor valido. Tipo Nota id: '||:NEW.TIPO_NOTA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.TIPO_NOTA_ID AND
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
    ELSIF UPDATING THEN
       IF :NEW.TIPO_NOTA_ID IS NOT NULL THEN
         IF NVL(:NEW.TIPO_NOTA_ID,0) != NVL(:OLD.TIPO_NOTA_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.TIPO_NOTA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El Tipo de nota, no es un valor valido. Tipo Nota id: '||:NEW.TIPO_NOTA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.TIPO_NOTA_ID AND
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

CREATE OR REPLACE TRIGGER TRG_AUD_SNH_MST_NOTAS
BEFORE UPDATE ON HOSPITALARIO.SNH_MST_NOTAS FOR EACH ROW
BEGIN
       IF :NEW.USUARIO_MODIFICACION IS NULL THEN
           RAISE_APPLICATION_ERROR (-20000, 'El usuario modificación no puede quedar nulo.');
       ELSE
       :NEW.FECHA_MODIFICACION   := SYSDATE;
       END IF;
END;
/



ALTER TABLE HOSPITALARIO.SNH_MST_NOTAS ADD (
  CONSTRAINT FRK_MSTNOTAS_MPERSSALUD_ID
  FOREIGN KEY (MPERS_SALUD_ID) 
  REFERENCES CATALOGOS.SBC_MST_MINSA_PERSONALES (MINSA_PERSONAL_ID)
  ENABLE VALIDATE);  


ALTER TABLE HOSPITALARIO.SNH_MST_NOTAS ADD (
  CONSTRAINT FRK_MSTNOTAS_ADMIN_SERV_ID
  FOREIGN KEY (ADMISION_SERVICIO_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_ADMISION_SERVICIOS (ADMISION_SERVICIO_ID)
  ENABLE VALIDATE, 
--  CONSTRAINT FRK_MSTNOTAS_MPERSSALUD_ID
--  FOREIGN KEY (MPERS_SALUD_ID) 
--  REFERENCES CATALOGOS.SBC_MST_MPERS_SALUD (MPERS_SALUD_ID)
--  ENABLE VALIDATE,  
  CONSTRAINT FRK_MSTNOTAS_TIPONOTA_ID
  FOREIGN KEY (TIPO_NOTA_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_MSTNOTAS_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_MSTNOTAS_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_MSTNOTAS_USR_MOD 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_MSTNOTAS_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_MSTNOTAS_USR_ELIMINA 
  FOREIGN KEY (USUARIO_ELIMINA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE    
  );



SELECT *
FROM CATALOGOS.SBC_CAT_CATALOGOS
WHERE UPPER(CODIGO) LIKE '%%TPINSTNT%'