drop table if exists interviu;
drop table if exists aplica;
drop table if exists job;
drop table if exists candidat;

CREATE TABLE CANDIDAT 
(
  ID_CANDIDAT INT 
, NUME VARCHAR(20) 
, PRENUME VARCHAR(20) 
, DATA_NASTERE DATE 
, STUDII VARCHAR(20) 
, CONSTRAINT CANDIDAT_PK PRIMARY KEY 
  (
    ID_CANDIDAT
  )
);


CREATE TABLE JOB 
(
  JOB_ID INT NOT NULL 
, DENUMIRE VARCHAR(20) 
, DATA_PUBLICARE_ANUNT DATE 
, CONSTRAINT JOB_PK PRIMARY KEY 
  (
    JOB_ID 
  )
);


CREATE TABLE INTERVIU 
(
  COD_JOB INT NOT NULL 
, COD_CANDIDAT INT NOT NULL 
, DATA_INTERVIU DATE NOT NULL 
, CONSTRAINT INTERVIU_PK PRIMARY KEY 
  (
    COD_JOB 
  , COD_CANDIDAT 
  , DATA_INTERVIU 
  ) 
);


CREATE TABLE APLICA 
(
  COD_JOB INT NOT NULL 
, COD_CANDIDAT INT NOT NULL 
, DATA_APLICARE DATE NOT NULL 
, PUNCTAJ_CV INT 
);

Insert into CANDIDAT (ID_CANDIDAT,NUME,PRENUME,DATA_NASTERE,STUDII) values (1,'Popescu','Ion',str_to_date('04-05-95','%d-%m-%Y'),'fmi');
Insert into CANDIDAT (ID_CANDIDAT,NUME,PRENUME,DATA_NASTERE,STUDII) values (2,'Georgescu ','Ion',str_to_date('07-11-95','%d-%m-%Y'),'cibernetica');
Insert into CANDIDAT (ID_CANDIDAT,NUME,PRENUME,DATA_NASTERE,STUDII) values (3,'Pop','Andrei',str_to_date('22-06-93','%d-%m-%Y'),'automatica');
Insert into CANDIDAT (ID_CANDIDAT,NUME,PRENUME,DATA_NASTERE,STUDII) values (4,'Anghel ','Paul',str_to_date('19-04-94','%d-%m-%Y'),'cibernetica');
Insert into CANDIDAT (ID_CANDIDAT,NUME,PRENUME,DATA_NASTERE,STUDII) values (5,'Ivan','Maria',str_to_date('17-11-92','%d-%m-%Y'),'fmi');
Insert into CANDIDAT (ID_CANDIDAT,NUME,PRENUME,DATA_NASTERE,STUDII) values (6,'Alexandru','Anca',str_to_date('18-03-94','%d-%m-%Y'),'cibernetica');
Insert into CANDIDAT (ID_CANDIDAT,NUME,PRENUME,DATA_NASTERE,STUDII) values (7,'Jianu','Ana',str_to_date('07-04-93','%d-%m-%Y'),'automatica');


Insert into JOB (JOB_ID,DENUMIRE,DATA_PUBLICARE_ANUNT) values (4,'IOS developer',str_to_date('01-05-20','%d-%m-%Y'));
Insert into JOB (JOB_ID,DENUMIRE,DATA_PUBLICARE_ANUNT) values (1,'java developer',str_to_date('01-05-20','%d-%m-%Y'));
Insert into JOB (JOB_ID,DENUMIRE,DATA_PUBLICARE_ANUNT) values (2,'tester',str_to_date('07-04-20','%d-%m-%Y'));
Insert into JOB (JOB_ID,DENUMIRE,DATA_PUBLICARE_ANUNT) values (3,'web developer',str_to_date('29-05-20','%d-%m-%Y'));

Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (1,1,str_to_date('02-05-20','%d-%m-%Y'),70);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (1,2,str_to_date('03-05-20','%d-%m-%Y'),80);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (1,4,str_to_date('04-05-20','%d-%m-%Y'),75);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (2,2,str_to_date('17-04-20','%d-%m-%Y'),60);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (2,3,str_to_date('18-04-20','%d-%m-%Y'),100);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (3,2,str_to_date('19-04-20','%d-%m-%Y'),75);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (3,5,str_to_date('20-04-20','%d-%m-%Y'),85);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (4,2,str_to_date('12-05-20','%d-%m-%Y'),30);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (4,6,str_to_date('14-05-20','%d-%m-%Y'),85);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (4,7,str_to_date('15-05-20','%d-%m-%Y'),70);
Insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (2,3,str_to_date('17-05-20','%d-%m-%Y'),75);

Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (1,1,str_to_date('04-05-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (1,2,str_to_date('05-05-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (1,4,str_to_date('06-05-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (2,2,str_to_date('19-04-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (2,3,str_to_date('20-04-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (3,2,str_to_date('21-04-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (3,5,str_to_date('22-04-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (4,2,str_to_date('14-05-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (4,6,str_to_date('16-05-20','%d-%m-%Y'));
Insert into INTERVIU (COD_JOB,COD_CANDIDAT,DATA_INTERVIU) values (4,7,str_to_date('17-05-20','%d-%m-%Y'));



commit;