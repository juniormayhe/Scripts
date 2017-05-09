
select *  from E098LOG where DESREG like '%Bloqueto%';
select * from E098REG where DESREG like '%Bloqueto%';
select * from R910MDG where DESMOD like '%Bloqueto%';
select * from R910MNU where DESMNU like '%Bloqueto%';
select * from R975PRP where ITEMDSC like '%Bloqueto%';
select * from R996FLD where LGNTIT like '%Bloqueto%';
select * from R999MDS where DESMOD like '%Bloqueto%';


select * from E000CRR where DESCRR like '%referente%';
select * from E000OBS where TEXOBS like '%referente%';
select * from E120OBS where OBSPED like '%referente%';
select * from E140ISV where DESIMP like '%referente%';
select * from E640LCT where CPLLCT like '%referente%';
select * from E640LOG where DESLOG like '%referente%';
select * from R910CMP where DESCMP like '%referente%';
select * from R996FLD where DESFLD like '%referente%';
select * from R996LSF where VALKEY like '%referente%';
select * from USU_T651RTO where USU_OBSLCT like '%referente%';

SELECT DBMS_LOB.SUBSTR(XMLRET) from E000CIM;

select XMLRET from E000CIM;
select utl_raw.cast_to_varchar2(dbms_lob.substr(IMGFOT, 4000,1))   from E046NEI;
select utl_raw.cast_to_varchar2(dbms_lob.substr(IMGSEG, 4000,1))   from E069SEG;
select utl_raw.cast_to_varchar2(dbms_lob.substr(LOGEMP, 4000,1))   from E070EMP;
select utl_raw.cast_to_varchar2(dbms_lob.substr(IMGFOT, 4000,1))   from E075FOT;
select utl_raw.cast_to_varchar2(dbms_lob.substr(IMGREF, 4000,1))   from E085IMG;
select utl_raw.cast_to_varchar2(dbms_lob.substr(IMGFOT, 4000,1))   from E210EMB;
select utl_raw.cast_to_varchar2(dbms_lob.substr(IMGBEM, 4000,1))   from E670BEM;
select utl_raw.cast_to_varchar2(dbms_lob.substr(IMGFOT, 4000,1))   from E720FOT;
--to huge clob
select to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(parval, 2000,1))) from R960PAR;



--to varchar2
select  to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(parval, 2000,1)))  from R960PAR where to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(parval, 2000,1)))   like '%vianna%';
select  to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(RULDAT, 2000,1)))  from R960RUL where to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(RULDAT, 2000,1)))   like '%Bloqueto%';
select  to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(image, 2000,1)))  from R975SNS where to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(image, 2000,1)))   like '%Bloqueto%';
select  to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(BINTRADET, 2000,1)))  from R981TRD where to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(BINTRADET, 2000,1)))   like '%Bloqueto%';
select  to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(icone, 2000,1)))  from R999BOT where to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(icone, 2000,1)))   like '%Bloqueto%';
select  to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(cubdat, 2000,1)))  from R999CUB where to_clob(utl_raw.cast_to_varchar2(dbms_lob.substr(cubdat, 2000,1)))   like '%Bloqueto%';
--select utl_raw.cast_to_varchar2(dbms_lob.substr(PARVAL, 4000,1))   from R960PAR ;
--select utl_raw.cast_to_varchar2(dbms_lob.substr(RULDAT, 4000,1))   from R960RUL;
--select utl_raw.cast_to_varchar2(dbms_lob.substr(IMAGE, 4000,1))   from R975SNS;
--select utl_raw.cast_to_varchar2(dbms_lob.substr(BINTRADET, 4000,1))   from R981TRD;
--select utl_raw.cast_to_varchar2(dbms_lob.substr(ICONE, 4000,1))   from R999BOT;
--select utl_raw.cast_to_varchar2(dbms_lob.substr(CUBDAT, 4000,1))  from R999CUB;