CREATE SEQUENCE HOSPITALARIO.SNH_S_PREG_INGRESO_ID
  START WITH 1
  MAXVALUE 9999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;
  

GRANT ALTER, SELECT ON HOSPITALARIO.SNH_S_PREG_INGRESO_ID TO CATALOGOS, SEGURIDAD, VIGILANCIA, SIPAI;    

CREATE TABLE HOSPITALARIO.SNH_MST_PREG_INGRESOS
(
 PREG_INGRESO_ID               NUMBER(10)          DEFAULT HOSPITALARIO.SNH_S_PREG_INGRESO_ID.NEXTVAL CONSTRAINT PK_PRINGR_PREG_INGRESO_ID PRIMARY KEY NOT NULL,
 ADMISION_ID                   NUMBER(10)          CONSTRAINT NNC_PRINGR_ADMISION_ID NOT NULL,
 PROCEDENCIA_ID                NUMBER(10)          CONSTRAINT NNC_PRINGR_PROCEDENCIA_ID NOT NULL,  
 PER_NOMINAL_ID                NUMBER(10)          CONSTRAINT NNC_PREGINGR_PERNOMINALID NOT NULL,
 CODIGO_EXPEDIENTE_ELECTRONICO VARCHAR2(50 BYTE)   CONSTRAINT NNC_PREGINGR_CODEXPEDIENTE NOT NULL,  
 EXPEDIENTE_ID                 NUMBER(10)          CONSTRAINT NNC_PRINGR_EXPEDIENTE_ID NOT NULL,
 NOMBRE_COMPLETO_PX            VARCHAR2(500 BYTE)  CONSTRAINT NNC_PRINGR_NOMBRE NOT NULL,
 MEDICO_ORDENA_INGRESO_ID      NUMBER(10)          CONSTRAINT NNC_PRINGR_MEDICO_ORDENA_EXPID NOT NULL,
 SERVICIO_PROCEDENCIA_ID       NUMBER(10)          CONSTRAINT NNC_PRINGR_SRV_PROCEDENCIA_ID NOT NULL,
 ESPECIALIDAD_DESTINO_ID       NUMBER(10)          CONSTRAINT NNC_PREGINGR_ESPE_DEST_ID NOT NULL,
 ADMISIONISTA_SOLICITA_INGR_ID NUMBER(10)          CONSTRAINT NNC_PRINGR_ADMISIONISTA_EXPID NOT NULL,
 FECHA_SOLICITUD_INGRESO       TIMESTAMP(0)        CONSTRAINT NNC_PRINGR_FEC_SOLICITUD_ING NOT NULL,
 HORA_SOLICITUD_INGRESO        VARCHAR2(15 BYTE)   CONSTRAINT NNC_PRINGR_HR_SOLICITUD_ING NOT NULL,
 UNIDAD_SALUD_ORIGEN_ID        NUMBER(10)          CONSTRAINT NNC_PREGINGR_USAL_ORIGEN_ID NOT NULL,
 UNIDAD_SALUD_DESTINO_ID       NUMBER(10)          CONSTRAINT NNC_PRINGR_USAL_DESTINO NOT NULL,
 REFERENCIA_ID                 NUMBER(10)          CONSTRAINT NNC_PRINGR_REFERENCIA_ID NOT NULL,
 ESTADO_PRE_INGRESO_ID         NUMBER(10)          CONSTRAINT NNC_PRINGR_ESTADO_PREGING_ID NOT NULL,
 COMENTARIOS                   VARCHAR2(1000 BYTE),
 TIPO_IDENTIFICACION_ID        NUMBER(10),
 IDENTIFICACION                VARCHAR2(50 BYTE),
 ESTADO_PX_ID                  NUMBER(10)           CONSTRAINT NNC_PRINGR_ESTADOPX NOT NULL,
 ESTADO_REGISTRO_ID            NUMBER(10)           CONSTRAINT NNC_PRINGR_ESTADOREG NOT NULL,
 USUARIO_REGISTRO              VARCHAR2(50 BYTE)    CONSTRAINT NNC_PRINGR_USR_REG NOT NULL,
 FECHA_REGISTRO                TIMESTAMP(0)         DEFAULT CURRENT_TIMESTAMP CONSTRAINT NNC_FEC_REG NOT NULL,
 USUARIO_MODIFICACION          VARCHAR2(50 BYTE),
 FECHA_MODIFICACION            TIMESTAMP(0),
 USUARIO_PASIVA                VARCHAR2(50 BYTE),
 FECHA_PASIVA                  TIMESTAMP(0),
 USUARIO_ELIMINA               VARCHAR2(50 BYTE),
 FECHA_ELIMINA                 TIMESTAMP(0) 
);

/

--ALTER TABLE HOSPITALARIO.SNH_MST_PREG_INGRESOS MODIFY(ESTADO_PX_ID CONSTRAINT NNC_PRINGR_ESTADOPX NOT NULL);
/

CREATE INDEX IDX_PRINGR_NOMID_EXPID ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(PER_NOMINAL_ID, EXPEDIENTE_ID);


CREATE INDEX IDX_PRINGR_NOMID ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(PER_NOMINAL_ID);

CREATE INDEX IDX_PRINGR_EXPID ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(EXPEDIENTE_ID);

CREATE INDEX IDX_PRINGR_ESTADO_REGID ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(ESTADO_REGISTRO_ID);


CREATE INDEX IDX_PRINGR_CODEXP_ELECTRONICO ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(CODIGO_EXPEDIENTE_ELECTRONICO);

CREATE INDEX IDX_PRINGR_IDENTIFICACION ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(IDENTIFICACION);


CREATE INDEX IDX_PRINGR_USAL_DESTINO ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(UNIDAD_SALUD_DESTINO_ID);

CREATE INDEX IDX_PRINGR_PROCEDENCIA ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(PROCEDENCIA_ID);

CREATE INDEX IDX_PRINGR_SERV_PROCEDENCIA ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(SERVICIO_PROCEDENCIA_ID);

CREATE INDEX IDX_PRINGR_ESPECIALIDAD_DEST ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(ESPECIALIDAD_DESTINO_ID);


CREATE INDEX IDX_PRINGR_USAL_ORIGEN ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(UNIDAD_SALUD_ORIGEN_ID);

CREATE INDEX IDX_PRINGR_ESTADO_PRE_INGR ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(ESTADO_PRE_INGRESO_ID);


CREATE INDEX IDX_PRINGR_ESTADO_PX ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(ESTADO_PX_ID);

CREATE INDEX IDX_PRINGR_MED_ORDENA_INGR ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(MEDICO_ORDENA_INGRESO_ID);

CREATE INDEX IDX_PRINGR_ADMIN_SOL_INGR ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(ADMISIONISTA_SOLICITA_INGR_ID);








CREATE INDEX IDX_PREINGR_NOM_COMPLETO ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(NOMBRE_COMPLETO_PX)
INDEXTYPE IS CTXSYS.CTXCAT
NOPARALLEL;

CREATE INDEX IDX_PRINGR_NOMBRE_COMPLETO_1 ON HOSPITALARIO.SNH_MST_PREG_INGRESOS
(NOMBRE_COMPLETO_PX);


CREATE OR REPLACE TRIGGER "HOSPITALARIO"."DR$IDX_PREINGR_NOM_COMPLETOTC" after insert or update on "HOSPITALARIO"."SNH_MST_PREG_INGRESOS" for each row
declare   reindex boolean := FALSE;   updop   boolean := FALSE; begin   ctxsys.drvdml.c_updtab.delete;   ctxsys.drvdml.c_numtab.delete;   ctxsys.drvdml.c_vctab.delete;   ctxsys.drvdml.c_rowid := :new.rowid;   if (inserting or updating('NOMBRE_COMPLETO_PX') or       :new."NOMBRE_COMPLETO_PX" <> :old."NOMBRE_COMPLETO_PX") then     reindex := TRUE;     updop := (not inserting);     ctxsys.drvdml.c_text_vc2 := :new."NOMBRE_COMPLETO_PX";   end if;   ctxsys.drvdml.ctxcat_dml('HOSPITALARIO','IDX_PREINGR_NOM_COMPLETO', reindex, updop); end;
/

CREATE OR REPLACE TRIGGER TRG_AUD_SNH_PREG_INGR
BEFORE INSERT OR UPDATE ON HOSPITALARIO.SNH_MST_PREG_INGRESOS FOR EACH ROW
BEGIN
    IF INSERTING THEN
      -- :NEW.PREG_INGRESO_ID  := HOSPITALARIO.SNH_S_PREG_INGRESO_ID.NEXTVAL;
       :NEW.FECHA_REGISTRO            := SYSDATE;
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
CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_PREGINGR_ESTREG
BEFORE INSERT OR UPDATE OF ESTADO_REGISTRO_ID ON HOSPITALARIO.SNH_MST_PREG_INGRESOS FOR EACH ROW
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


--- ESTADO PRE INGRESO
CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_PREGINGR_ESTPREG
BEFORE INSERT OR UPDATE OF ESTADO_PRE_INGRESO_ID ON HOSPITALARIO.SNH_MST_PREG_INGRESOS FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.ESTADO_PRE_INGRESO_ID IS NOT NULL AND :NEW.ESTADO_PRE_INGRESO_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.ESTADO_PRE_INGRESO_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El estado del registro, no es un valor valido. Estado pre ingreso id: '||:NEW.ESTADO_PRE_INGRESO_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.ESTADO_PRE_INGRESO_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'STSLPRG';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Estado pre ingreso id: '||:NEW.ESTADO_PRE_INGRESO_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.ESTADO_PRE_INGRESO_ID IS NOT NULL THEN
         IF NVL(:NEW.ESTADO_PRE_INGRESO_ID,0) != NVL(:OLD.ESTADO_PRE_INGRESO_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.ESTADO_PRE_INGRESO_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Estado pre ingreso id: '||:NEW.ESTADO_PRE_INGRESO_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.ESTADO_PRE_INGRESO_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'STSLPRG';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Estado pre ingreso id: '||:NEW.ESTADO_PRE_INGRESO_ID);                
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



--- procedencia id
CREATE OR REPLACE TRIGGER HOSPITALARIO.TRG_SNH_PREGINGR_PROCEDENCIA
BEFORE INSERT OR UPDATE OF PROCEDENCIA_ID ON HOSPITALARIO.SNH_MST_PREG_INGRESOS FOR EACH ROW
BEGIN
    IF INSERTING THEN
      IF  (:NEW.PROCEDENCIA_ID IS NOT NULL AND :NEW.PROCEDENCIA_ID > 0)   THEN
             DECLARE
              vCONTEO     SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.PROCEDENCIA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El estado del registro, no es un valor valido. Procedencia id: '||:NEW.PROCEDENCIA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.PROCEDENCIA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'INGRESOPOR';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Procedencia id: '||:NEW.PROCEDENCIA_ID);                
                           ELSE NULL;
                           END CASE;
                        END;  
                    END;
                END CASE;
             END;
      END IF;
    ELSIF UPDATING THEN
       IF :NEW.PROCEDENCIA_ID IS NOT NULL THEN
         IF NVL(:NEW.PROCEDENCIA_ID,0) != NVL(:OLD.PROCEDENCIA_ID,0) THEN
             DECLARE
              vCONTEO SIMPLE_INTEGER := 0;
              vCatalogoId CATALOGOS.SBC_CAT_CATALOGOS.CATALOGO_ID%TYPE;
             BEGIN
              SELECT COUNT (1)
                INTO vCONTEO
                FROM CATALOGOS.SBC_CAT_CATALOGOS
               WHERE CATALOGO_ID = :NEW.PROCEDENCIA_ID AND
                     PASIVO = 0 AND
                     CATALOGO_SUP IS NOT NULL;
                
                CASE vCONTEO 
                WHEN 0 THEN
                     RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Procedencia id: '||:NEW.PROCEDENCIA_ID);
                ELSE
                    BEGIN
                      vCONTEO := 0;
                      SELECT CATALOGO_SUP
                        INTO vCatalogoId
                        FROM CATALOGOS.SBC_CAT_CATALOGOS
                       WHERE CATALOGO_ID = :NEW.PROCEDENCIA_ID AND
                             PASIVO = 0 ;
                    
                        BEGIN
                          SELECT COUNT (1)
                            INTO vCONTEO
                            FROM CATALOGOS.SBC_CAT_CATALOGOS
                           WHERE CATALOGO_ID = vCatalogoId AND
                                 PASIVO = 0 AND
                                 CODIGO = 'INGRESOPOR';       
                           CASE vCONTEO 
                           WHEN 0 THEN
                                RAISE_APPLICATION_ERROR (-20000, 'El estado registro, no es un valor valido. Procendencia id: '||:NEW.PROCEDENCIA_ID);                
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

--ALTER TABLE HOSPITALARIO.SNH_MST_PREG_INGRESOS
-- ADD (PER_NOMINAL_ID NUMBER(10) CONSTRAINT NNC_PREGINGR_PERNOMINALID NOT NULL);
--
--ALTER TABLE HOSPITALARIO.SNH_MST_PREG_INGRESOS
-- ADD (CODIGO_EXPEDIENTE_ELECTRONICO VARCHAR2(50 BYTE) CONSTRAINT NNC_PREGINGR_CODEXPEDIENTE NOT NULL);
-- 
--ALTER TABLE HOSPITALARIO.SNH_MST_PREG_INGRESOS
-- ADD (ESPECIALIDAD_DESTINO_ID NUMBER(10) CONSTRAINT NNC_PREGINGR_ESPE_DEST_ID NOT NULL); 
-- 
--
--ALTER TABLE HOSPITALARIO.SNH_MST_PREG_INGRESOS
-- ADD (UNIDAD_SALUD_ORIGEN_ID NUMBER(10) CONSTRAINT NNC_PREGINGR_USAL_ORIGEN_ID NOT NULL);  
-- 
--ALTER TABLE HOSPITALARIO.SNH_MST_PREG_INGRESOS ADD ( 
--  CONSTRAINT FRK_PREGINGR_PERNOM_ID 
--  FOREIGN KEY (PER_NOMINAL_ID) 
--  REFERENCES CATALOGOS.SBC_MST_PERSONAS_NOMINAL (PER_NOMINAL_ID)
--  ENABLE VALIDATE,
--  CONSTRAINT FRK_PREGINGR_USALORIGEN_ID 
--  FOREIGN KEY (UNIDAD_SALUD_ORIGEN_ID ) 
--  REFERENCES CATALOGOS.SBC_CAT_UNIDADES_SALUD (UNIDAD_SALUD_ID)
--  ENABLE VALIDATE,
--  CONSTRAINT FRK_PREGINGR_USALDESTINO_ID 
--  FOREIGN KEY (UNIDAD_SALUD_DESTINO_ID ) 
--  REFERENCES CATALOGOS.SBC_CAT_UNIDADES_SALUD (UNIDAD_SALUD_ID)
--  ENABLE VALIDATE);   

ALTER TABLE HOSPITALARIO.SNH_MST_PREG_INGRESOS ADD (
  CONSTRAINT FRK_PREGINGR_ADMISION_ID 
  FOREIGN KEY (ADMISION_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_ADMISIONES (ADMISION_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_PROCEDENCIA_ID 
  FOREIGN KEY (PROCEDENCIA_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_EXPID 
  FOREIGN KEY (EXPEDIENTE_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE (EXPEDIENTE_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_MEDORDENA_EXPID 
  FOREIGN KEY (MEDICO_ORDENA_INGRESO_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE (EXPEDIENTE_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_SERV_PROCED_ID 
  FOREIGN KEY (SERVICIO_PROCEDENCIA_ID) 
  REFERENCES HOSPITALARIO.SNH_CAT_SERVICIOS (SERVICIO_ID)
  ENABLE VALIDATE,    
  CONSTRAINT FRK_PREGINGR_ADMISIONISTA_EXPID 
  FOREIGN KEY (ADMISIONISTA_SOLICITA_INGR_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE (EXPEDIENTE_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_PERNOM_ID 
  FOREIGN KEY (PER_NOMINAL_ID) 
  REFERENCES CATALOGOS.SBC_MST_PERSONAS_NOMINAL (PER_NOMINAL_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_USALORIGEN_ID 
  FOREIGN KEY (UNIDAD_SALUD_ORIGEN_ID ) 
  REFERENCES CATALOGOS.SBC_CAT_UNIDADES_SALUD (UNIDAD_SALUD_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_USALDESTINO_ID 
  FOREIGN KEY (UNIDAD_SALUD_DESTINO_ID ) 
  REFERENCES CATALOGOS.SBC_CAT_UNIDADES_SALUD (UNIDAD_SALUD_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_PREGINGR_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_PREGINGR_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_USR_MODIFCACION 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PREGINGR_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE  
  );
  
  
