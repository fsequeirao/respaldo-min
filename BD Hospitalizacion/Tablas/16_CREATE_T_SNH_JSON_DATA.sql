CREATE SEQUENCE HOSPITALARIO.SNH_S_JSON_DATA_ID
  START WITH 1
  MAXVALUE 9999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;
  

GRANT ALTER, SELECT ON HOSPITALARIO.SNH_S_JSON_DATA_ID TO CATALOGOS, SEGURIDAD, VIGILANCIA, SIPAI;    

CREATE TABLE HOSPITALARIO.SNH_JSON_DATA
(
   id     NUMBER DEFAULT HOSPITALARIO.SNH_S_JSON_DATA_ID.NEXTVAL CONSTRAINT PRK_JSONDATA_ID PRIMARY KEY NOT NULL, 
   info   CLOB CONSTRAINT is_json CHECK (info IS JSON ) )
/