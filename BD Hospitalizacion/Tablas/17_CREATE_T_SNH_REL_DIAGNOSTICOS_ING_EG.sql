CREATE SEQUENCE HOSPITALARIO.SNH_S_REL_DIAGNOSTICO_ING_EGR
  START WITH 1
  MAXVALUE 99999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;
    
GRANT ALTER, SELECT ON HOSPITALARIO.SNH_S_REL_DIAGNOSTICO_ING_EGR TO CATALOGOS, SEGURIDAD, VIGILANCIA, SIPAI; 


CREATE TABLE HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG
(REL_DX_ING_EG_ID     NUMBER(10)        DEFAULT HOSPITALARIO.SNH_S_REL_DIAGNOSTICO_ING_EGR.NEXTVAL CONSTRAINT PRK_RELDIAGINEG_ID PRIMARY KEY NOT NULL, 
 INGRESO_ID           NUMBER(10)        CONSTRAINT NNC_RELDIAGINEG_ING_ID NOT NULL,
 DIAGNOSTICO_ID       NUMBER(10)        CONSTRAINT NNC_RELDIAGINEG_DIAGNOSTICO_ID NOT NULL,
 TRASLADO_ID          NUMBER(10)        CONSTRAINT NNC_RELDIAGINEG_TRASLADO_ID NOT NULL,
 TIPO_DX_ING_EG_ID    NUMBER(10)        CONSTRAINT NNC_RELDIAGINEG_TIPO_DXEGINGID NOT NULL,
 ESTADO_REGISTRO_ID   NUMBER(10)        CONSTRAINT NNC_RELDIAGINEG_ESTADOREG NOT NULL,   
 USUARIO_REGISTRO     VARCHAR2(50 BYTE) CONSTRAINT NNC_RELDIAGINEG_USR_REGISTRO NOT NULL,
 FECHA_REGISTRO       TIMESTAMP(0)      DEFAULT CURRENT_TIMESTAMP CONSTRAINT NNC_RELDIAGINEG_FEC_REG NOT NULL,
 USUARIO_MODIFICACION VARCHAR2(50 BYTE),
 FECHA_MODIFICACION   TIMESTAMP(0),
 USUARIO_PASIVA       VARCHAR2(50 BYTE),
 FECHA_PASIVA         TIMESTAMP(0),
 USUARIO_ELIMINA      VARCHAR2(50 BYTE),
 FECHA_ELIMINA        TIMESTAMP(0)   
);


CREATE INDEX IDX_RELDIAGINEG_INGRESOID ON HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG
(INGRESO_ID);

CREATE INDEX IDX_RELDIAGINEG_INGR_DIAG_ID ON HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG
(INGRESO_ID, DIAGNOSTICO_ID);


CREATE INDEX IDX_RELDIAGINEG_DIAG_ID ON HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG
(DIAGNOSTICO_ID);


CREATE INDEX IDX_RELDIAGINEG_INGR_TRASLADO ON HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG
(INGRESO_ID, TRASLADO_ID);


CREATE INDEX IDX_RELDIAGINEG_TRASLADO ON HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG
(TRASLADO_ID);




-- estado registro
CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_RELDIAGINEG_ESTADO_REG
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG FOR EACH ROW
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
BEFORE INSERT OR UPDATE OF TIPO_DET_NOTA_ID ON HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG FOR EACH ROW
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

CREATE OR REPLACE TRIGGER TRG_AUD_REL_DIAGNOSTICO_ING_EG
BEFORE UPDATE ON HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG FOR EACH ROW
BEGIN
       IF :NEW.USUARIO_MODIFICACION IS NULL THEN
           RAISE_APPLICATION_ERROR (-20000, 'El usuario modificación no puede quedar nulo.');
       ELSE
          :NEW.FECHA_MODIFICACION   := SYSDATE;
       END IF;
END;
/


ALTER TABLE HOSPITALARIO.SNH_REL_DIAGNOSTICOS_ING_EG ADD (
  CONSTRAINT FRK_RELDIAG_INGRESO_ID
  FOREIGN KEY (INGRESO_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_INGRESOS_EGRESOS (INGRESO_ID)
  ENABLE VALIDATE, 
  CONSTRAINT FRK_RELDIAG_DIAGNOSTICO_ID
  FOREIGN KEY (DIAGNOSTICO_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_DIAGNOSTICOS (DIAGNOSTICO_ID)
  ENABLE VALIDATE,   
  CONSTRAINT FRK_RELDIAG_TRASLADO_ID
  FOREIGN KEY (TRASLADO_ID) 
  REFERENCES HOSPITALARIO.TRASLADOS_ENTRE_SERVICIOS (TRASLADO_ID)
  ENABLE VALIDATE,   
  CONSTRAINT FRK_RELDIAG_TIPO_DX_ING_EG_ID 
  FOREIGN KEY (TIPO_DX_ING_EG_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_RELDIAG_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_RELDIAG_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_RELDIAG_USR_MOD 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_RELDIAG_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_RELDIAG_USR_ELIMINA 
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