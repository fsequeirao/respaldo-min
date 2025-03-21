--select *
--from HOSPITALARIO.SNH_REL_CNF_GRUPO_CATALOGOS;

CREATE SEQUENCE HOSPITALARIO.SNH_S_CNF_ID
  START WITH 26
  MAXVALUE 99999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  ORDER
  NOKEEP
  GLOBAL;


ALTER TABLE HOSPITALARIO.SNH_REL_CNF_GRUPO_CATALOGOS MODIFY(CNF_ID DEFAULT HOSPITALARIO.SNH_S_CNF_ID.NEXTVAL);



GRANT ALTER, SELECT ON HOSPITALARIO.SNH_S_CNF_ID TO CATALOGOS, SEGURIDAD, VIGILANCIA, SIPAI; 


