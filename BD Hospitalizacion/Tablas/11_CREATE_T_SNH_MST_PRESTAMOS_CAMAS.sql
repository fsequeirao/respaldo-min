CREATE SEQUENCE HOSPITALARIO.SNH_S_PRESTAMOS_CAMA_ID
  START WITH 1
  MAXVALUE 99999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;

GRANT ALTER, SELECT ON HOSPITALARIO.SNH_S_PRESTAMOS_CAMA_ID TO CATALOGOS, SEGURIDAD, VIGILANCIA, SIPAI; 



CREATE TABLE HOSPITALARIO.SNH_MST_PRESTAMOS_CAMAS
(PRESTAMOS_CAMA_ID  NUMBER(10)    DEFAULT HOSPITALARIO.SNH_S_PRESTAMOS_CAMA_ID.NEXTVAL CONSTRAINT PRK_PR_CAMAS PRIMARY KEY NOT NULL,
 CFG_USLD_SERVICIO_ORIGEN_ID      NUMBER(10)         CONSTRAINT NNC_PR_SERV_ORIGEN_ID NOT NULL,  
 CFG_USLD_SERVICIO_DESTINO_ID     NUMBER(10)         CONSTRAINT NNC_PR_SERV_DESTINO_ID NOT NULL,  
 IS_LAST                          NUMBER(1)          CONSTRAINT NNC_PR_ISLAST NOT NULL,  
 MOTIVO                           VARCHAR2(1000 BYTE),
 ADMISIONISTA_ID                  NUMBER(10)         CONSTRAINT NNC_PR_ADMINID NOT NULL, 
 ESTADO_PRESTAMO_ID               NUMBER(10)         CONSTRAINT NNC_PR_ESTADOPRESTAMO NOT NULL, 
 ESTADO_REGISTRO_ID               NUMBER(10)         CONSTRAINT NNC_PR_ESTADOREG NOT NULL,   
 USUARIO_REGISTRO                 VARCHAR2(50 BYTE)  CONSTRAINT NNC_PR_USR_REGISTRO NOT NULL,
 FECHA_REGISTRO                   TIMESTAMP(0)       DEFAULT CURRENT_TIMESTAMP CONSTRAINT NNC_PR_FEC_REGISTRO NOT NULL,
 USUARIO_MODIFICACION             VARCHAR2(50 BYTE),
 FECHA_MODIFICACION               TIMESTAMP(0),
 USUARIO_PASIVA                   VARCHAR2(50 BYTE),
 FECHA_PASIVA                     TIMESTAMP(0),
 USUARIO_ELIMINA                  VARCHAR2(50 BYTE),
 FECHA_ELIMINA                    TIMESTAMP(0)   
);



CREATE OR REPLACE TRIGGER TRG_AUD_SNH_PR_CAMAS
BEFORE INSERT OR UPDATE ON HOSPITALARIO.SNH_MST_PRESTAMOS_CAMAS FOR EACH ROW
BEGIN
    IF INSERTING THEN
       :NEW.FECHA_REGISTRO  := SYSDATE;
    ELSE
       IF :NEW.USUARIO_MODIFICACION IS NULL THEN
           RAISE_APPLICATION_ERROR (-20000, 'El usuario modificación no puede quedar nulo.');
       ELSE
       :NEW.FECHA_MODIFICACION   := SYSDATE;
       END IF;
    END IF;
END;
/


ALTER TABLE HOSPITALARIO.SNH_MST_PRESTAMOS_CAMAS ADD (
  CONSTRAINT FRK_PR_CFG_USLD_SERV_ORIGEN
  FOREIGN KEY (CFG_USLD_SERVICIO_ORIGEN_ID) 
  REFERENCES HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS (CFG_USLD_SERVICIO_CAMA_ID)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PR_CFG_USLD_SERV_DESTINO
  FOREIGN KEY (CFG_USLD_SERVICIO_DESTINO_ID) 
  REFERENCES HOSPITALARIO.SNH_CFG_USERVICIOS_CAMAS (CFG_USLD_SERVICIO_CAMA_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_PR_CFG_ADMISIONISTA
  FOREIGN KEY (ADMISIONISTA_ID) 
  REFERENCES HOSPITALARIO.SNH_MST_CODIGO_EXPEDIENTE (EXPEDIENTE_ID)
  ENABLE VALIDATE, 
  CONSTRAINT FRK_PR_ESTADO_PRESTAMO_CAMA
  FOREIGN KEY (ESTADO_PRESTAMO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE, 
  CONSTRAINT FRK_PR_ESTADO_REG_ID 
  FOREIGN KEY (ESTADO_REGISTRO_ID) 
  REFERENCES CATALOGOS.SBC_CAT_CATALOGOS (CATALOGO_ID)
  ENABLE VALIDATE,  
  CONSTRAINT FRK_PR_USR_REGISTRO 
  FOREIGN KEY (USUARIO_REGISTRO) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PR_USR_MODIFCACION 
  FOREIGN KEY (USUARIO_MODIFICACION) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PR_USR_PASIVO 
  FOREIGN KEY (USUARIO_PASIVA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE,
  CONSTRAINT FRK_PR_USR_ELIMINA 
  FOREIGN KEY (USUARIO_ELIMINA) 
  REFERENCES SEGURIDAD.SCS_MST_USUARIOS (USERNAME)
  ENABLE VALIDATE    
  );
