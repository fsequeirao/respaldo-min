DROP TABLE HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP CASCADE CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
(
  LINEA NUMBER,
  ID    NUMBER
)
ON COMMIT DELETE ROWS
--ON COMMIT PRESERVE ROWS
RESULT_CACHE (MODE DEFAULT)
NOCACHE;


--CREATE PRIVATE TEMPORARY TABLE ora$SNH_CTRL_PAGINADAS_TMP (
--  LINEA NUMBER,
--  ID    NUMBER
--)
--ON COMMIT DROP DEFINITION;


CREATE INDEX HOSPITALARIO.IDX_SNH_PAGINADA_TMP ON HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
(ID);

CREATE INDEX IDX_SNH_PAGINADA_TMP_LINE ON HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
(LINEA);


CREATE INDEX HOSPITALARIO.IDX_SNH_PAGINADA_TMP_ID_LINE ON HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP
(ID, LINEA);

GRANT INSERT, SELECT ON HOSPITALARIO.SNH_CTRL_PAGINADAS_TMP TO HOSPITALARIO, CATALOGOS, VIGILANCIA, SEGURIDAD, SIPAI;




