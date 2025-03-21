DECLARE
  PINGRESOID NUMBER;
  PPREGINGRESOID NUMBER;
  PPERNOMINALID NUMBER;
  PPROCEDENCIAID NUMBER;
  PADMISIONID NUMBER;
  PEDADEXACTAING VARCHAR2(100);
  PGRUPOETAREOID NUMBER;
  PMEDICOINGID NUMBER;
  PADMINSOLICINGID NUMBER;
  PADMISIONISTAINGID NUMBER;
  PMEDORDENAINGID NUMBER;
  PSERVPROCEDENID NUMBER;
  PREINGRESO NUMBER;
  PREINGRESOID NUMBER;
  PFECSOLICITAING DATE;
  PHRSOLICITUDING VARCHAR2(15);
  PFECINICIOINGRESO DATE;
  PHRINICIOINGRESO VARCHAR2(15);
  PUSALINGRESOID NUMBER;
  PSERVINGRESOID NUMBER;
  PESTADOINGID NUMBER;
  PTIPOEGRESOID NUMBER;
  PFECFININGRESO DATE;
  PHRFININGRESO VARCHAR2(15);
  PSERVEGRESOID NUMBER;
  PMEDICOEGRESOID NUMBER;
  PREFERENCIAID NUMBER;
  PESCONTRAFERIDO NUMBER;
  PENVCONTRAREFERID NUMBER;
  PDIASESTANCIA NUMBER;
  PESTADOPXID NUMBER;
  PESTADOPXEGRESOID NUMBER;
  PCOMENTARIOS VARCHAR2(1000);
  PUSUARIO VARCHAR2(50);
  PACCIONESTADO VARCHAR2(200);
  PTIPOACCION VARCHAR2(200);
  PREGISTRO HOSPITALARIO.PKG_SNH_INGRESO_EGRESO.var_refcursor;
  PRESULTADO VARCHAR2(200);
  PMSGERROR VARCHAR2(200);
BEGIN
  PINGRESOID := NULL;
  PPREGINGRESOID := 34;
  PPERNOMINALID := 4999992;
  PPROCEDENCIAID := 2;
  PADMISIONID := 605;
  PEDADEXACTAING := '38anios,4meses, 2d�as, 20seg';
  PGRUPOETAREOID := 8;
  PMEDICOINGID := 18778;
  PADMINSOLICINGID := 19150;
  PADMISIONISTAINGID := 19150;
  PMEDORDENAINGID := 18778;
  PSERVPROCEDENID := 78;
  PREINGRESO := 0;
  PREINGRESOID := NULL;
  PFECSOLICITAING := to_date('2021-10-08','yyyy-MM-dd');
  PHRSOLICITUDING := '04: 58';
  PFECINICIOINGRESO := to_date('2021-10-15','yyyy-MM-dd');
  PHRINICIOINGRESO := '03: 45PM';
  PUSALINGRESOID := 1635;
  PSERVINGRESOID := 86;
  PESTADOINGID := 7648;
  PTIPOEGRESOID := NULL;
  PFECFININGRESO := NULL;
  PHRFININGRESO := NULL;
  PSERVEGRESOID := NULL;
  PMEDICOEGRESOID := NULL;
  PREFERENCIAID := NULL;
  PESCONTRAFERIDO := 0;
  PENVCONTRAREFERID := NULL;
  PDIASESTANCIA := NULL;
  PESTADOPXID := 1984;
  PESTADOPXEGRESOID := NULL;
  PCOMENTARIOS := 'Estoesunapruebadeingresos';
  PUSUARIO := 'jmairena01';
  PACCIONESTADO := NULL;
  PTIPOACCION := 'I';

  PKG_SNH_INGRESO_EGRESO.PR_CRUD_INGRESO_EGRESO(
    PINGRESOID => PINGRESOID,
    PPREGINGRESOID => PPREGINGRESOID,
    PPERNOMINALID => PPERNOMINALID,
    PPROCEDENCIAID => PPROCEDENCIAID,
    PADMISIONID => PADMISIONID,
    PEDADEXACTAING => PEDADEXACTAING,
    PGRUPOETAREOID => PGRUPOETAREOID,
    PMEDICOINGID => PMEDICOINGID,
    PADMINSOLICINGID => PADMINSOLICINGID,
    PADMISIONISTAINGID => PADMISIONISTAINGID,
    PMEDORDENAINGID => PMEDORDENAINGID,
    PSERVPROCEDENID => PSERVPROCEDENID,
    PREINGRESO => PREINGRESO,
    PREINGRESOID => PREINGRESOID,
    PFECSOLICITAING => PFECSOLICITAING,
    PHRSOLICITUDING => PHRSOLICITUDING,
    PFECINICIOINGRESO => PFECINICIOINGRESO,
    PHRINICIOINGRESO => PHRINICIOINGRESO,
    PUSALINGRESOID => PUSALINGRESOID,
    PSERVINGRESOID => PSERVINGRESOID,
    PESTADOINGID => PESTADOINGID,
    PTIPOEGRESOID => PTIPOEGRESOID,
    PFECFININGRESO => PFECFININGRESO,
    PHRFININGRESO => PHRFININGRESO,
    PSERVEGRESOID => PSERVEGRESOID,
    PMEDICOEGRESOID => PMEDICOEGRESOID,
    PREFERENCIAID => PREFERENCIAID,
    PESCONTRAFERIDO => PESCONTRAFERIDO,
    PENVCONTRAREFERID => PENVCONTRAREFERID,
    PDIASESTANCIA => PDIASESTANCIA,
    PESTADOPXID => PESTADOPXID,
    PESTADOPXEGRESOID => PESTADOPXEGRESOID,
    PCOMENTARIOS => PCOMENTARIOS,
    PUSUARIO => PUSUARIO,
    PACCIONESTADO => PACCIONESTADO,
    PTIPOACCION => PTIPOACCION,
    PREGISTRO => PREGISTRO,
    PRESULTADO => PRESULTADO,
    PMSGERROR => PMSGERROR
  );
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('PINGRESOID = ' || PINGRESOID);
*/ 
  :PINGRESOID := PINGRESOID;
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('PREGISTRO = ' || PREGISTRO);
*/ 
  :PREGISTRO := PREGISTRO; --<-- Cursor
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('PRESULTADO = ' || PRESULTADO);
*/ 
  :PRESULTADO := PRESULTADO;
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('PMSGERROR = ' || PMSGERROR);
*/ 
  :PMSGERROR := PMSGERROR;
--rollback; 
END;
