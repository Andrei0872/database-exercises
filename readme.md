# Database exercises

## TODOS

* [ ] add useful tip
* [ ] create ToC

---

## Prerequisites

* [Docker Compose](https://docs.docker.com/compose/) installed

---

## Getting started

* start the containers

  ```bash
  docker-compose up
  ```

* type `http://localhost:8080/` into the URL bar of your preferred browser

---

## Useful tips


### Clearing everything and starting over

* https://docs.docker.com/compose/reference/down/

---

## Solutions

### Task 1

```sql
/*
1. Să se obțină denumire joburilor la care a aplicat candidatul Popescu în luna mai a anului
trecut. (pentru a afla anul curent se apeleaza o functie care returneaza data curenta). Lista va
fi sortata descrescător în funcție de data la care a fost publicat anunțul.
*/

select *
from JOB j
inner join APLICA a
	on j.JOB_ID = a.COD_JOB and a.COD_CANDIDAT = (select c.ID_CANDIDAT from CANDIDAT c where lower(c.nume) = 'popescu')
where year(CURDATE()) - 1 = extract(YEAR from a.DATA_APLICARE) and extract(MONTH from a.DATA_APLICARE) = '05' 
order by j.DATA_PUBLICARE_ANUNT desc;
```

### Task 2

```sql
/*
2. Dați exemplu de interogare care utilizează operatorul MINUS, enunțați semnificația
rezultatului (ce problema rezolva interogarea) si scrieți o cerere echivalentă, dar care să nu
utilizeze operatorul MINUS.
*/

-- MySQL **nu** suporta MINUS: https://www.mysqltutorial.org/mysql-minus/

/*
Sa presupunem ca vrem sa selectem numele complet al candidatilor care nu au aplicat vreodata pentru postul de `java developer`.

Dintre toti candidatii care au aplicat, ii selectam pe cei ai caror `CANDIDAT_ID` nu se gaseste in tabelul `APLICA` alaturi de `JOB_ID`-ul corespunzator job-ului de `java developer`.
*/
select concat(c.NUME, ' ', c.PRENUME) as 'Full Name'
from CANDIDAT c
where c.ID_CANDIDAT not in (
  -- Se selecteaza ID-ul candidatilor care au aplicat candva pentru `java developer`
	select c.ID_CANDIDAT 
  from CANDIDAT c
  inner join APLICA a
    on a.COD_CANDIDAT = c.ID_CANDIDAT and a.COD_JOB = (select j.JOB_ID from JOB j where j.DENUMIRE = 'java developer')
);
```

### Task 3

```sql
/*
3. Să se obțină pentru fiecare job, denumirea și numărul candidaților care au aplicat. Se vor
afișa și joburi la care nu a aplicat niciun candidat.
*/

select j.DENUMIRE, count(*) as 'Nr. candidati'
from APLICA a
inner join JOB j
	on a.COD_JOB = j.JOB_ID
GROUP by a.COD_JOB;
```

### Task 4

```sql
/*
4. Să se afișeze numele și prenumele candiatului/candidaților care au aplicat la cel mai mare
număr de joburi.
*/

-- Obtinem un tabel cu evidenta numarului de job-uri la care a aplicat fiecare candidat
WITH candidateNrJobsMap as (
  select a.COD_CANDIDAT, count(*) as 'nr_jobs'
  from APLICA a
  group by a.COD_CANDIDAT
),

-- Obtinem numarul maxim din tabelul de mai sus
maxNrOfAppliedJobs as (
  select max(cj.nr_jobs)
  from candidateNrJobsMap cj
)


select c.NUME, c.PRENUME
from candidateNrJobsMap
inner join CANDIDAT c
  on c.ID_CANDIDAT = candidateNrJobsMap.COD_CANDIDAT
where candidateNrJobsMap.nr_jobs = (select * from maxNrOfAppliedJobs);
```

### Task 5

```sql
/*
5. Pentru fiecare job să se afișeze denumirea, textul ‘activ’/’inactiv’ daca numărul de luni
care au trecut de la publicarea anunțului este mai mic/mai mare decat 11, și numele
candidatului care a aplicat cu un punctaj_cv maxim.
*/

select 
	j.DENUMIRE, 
    if (
      timestampdiff(MONTH, j.DATA_PUBLICARE_ANUNT, curdate()) <= 11,
      'activ',
      'inactiv'
    ) as 'status',
	concat(c.NUME, ' ', c.PRENUME) as 'Full Name'
from JOB j
inner join (
    -- Cautam ID-ul candidatului care a obtinut punctajul maxim
    select a.COD_JOB, a.COD_CANDIDAT, a.PUNCTAJ_CV
    from APLICA a
    where (a.COD_JOB, a.PUNCTAJ_CV) in (
      -- Un tabel de forma: { JOB_ID: PUNCTAJ_CV_MAXIM }
      select a.COD_JOB, max(a.PUNCTAJ_CV)
      from APLICA a
      group by a.COD_JOB 
    )
) data on data.COD_JOB = j.JOB_ID
-- In final, facem legatura cu ce am acumulat anterior pentur a obtine numele complet al candidatului
inner join CANDIDAT c
on c.ID_CANDIDAT = data.COD_CANDIDAT;
```

### Task 6

```sql
/*
6. Să se afișeze pentru fiecare candidat numele, numărul interviurilor din luna aprilie și
numărul interviurilor din luna mai la care a fost programat.
*/

with interviewWithMonthNumber as (
	select *, month(i.DATA_INTERVIU) as 'month_value' from INTERVIU i
)

select c.NUME, c.PRENUME, data.nr_interviews, data.luna
from CANDIDAT c
inner join (
	select 
	i.COD_CANDIDAT, 
    count(i.month_value) as 'nr_interviews',
    -- i.month_value,
    case
    	when i.month_value = 5 then 'mai'
        when i.month_value = 4 then 'aprilie'
        else concat('alta luna: ', i.month_value)
	end as 'luna'
    from interviewWithMonthNumber i
    -- Folosind `COD_CANDIDAT`, obtinem gruparea in functie de ID-ul candidatului,
    -- insa aceasta grupare trebuie grupata la randul ei in functie de numarul lunii(care poate fi 4 sau 5 in acest caz)
    -- Practic, daca ar fi sa ne imaginam un dictionar, cheia este acum compusa din 'i.COD_CANDIDAT:i.month_value'
    GROUP by i.COD_CANDIDAT, i.month_value
) data
on data.COD_CANDIDAT = c.ID_CANDIDAT
;
```

### Task 7

```sql
/*
7. Dați exemplu de interogare care utilizează operatorul OUTER JOIN, enunțați semnificația
rezultatului (ce problema rezolva interogarea). Interogarea va utiliza cel puțin trei tabele.
*/

-- In MySQL **nu** exista `OUTER JOIN`: https://stackoverflow.com/a/12473340/9632621
-- dar se poate simula cu LEFT JOIN + RIGHT JOIN

/*
Sa se selecteze, pentru fiecare candidat, numele acestuia, numele si data publicarii job-ului la care a obtinut un interviu. 
Se vor afisa si job-urile la care nu a obtinut nimeni vreun interviu, dar si candidatii care nu au obtinut niciun interviu.
*/

/*
Pentru a se vedea mai clar rezultatul query-ului, mai inseram un job la care nu a aplicat nimeni, si pentru care nici nu s-a inregistrat vreun interviu. 
Se va insera si un candidat care nu a obtinut niciun interviu.

La final(si inainte) cele de mai sus se vor sterge, pentru a lasa lucrurile ca inainte.
*/

delete from JOB j where j.JOB_ID = 5;
delete from CANDIDAT c where c.ID_CANDIDAT = 19;

insert into JOB (JOB_ID,DENUMIRE,DATA_PUBLICARE_ANUNT) values (5,'DevOps engineer',str_to_date('19-04-2021','%d-%m-%Y'));
Insert into CANDIDAT (ID_CANDIDAT,NUME,PRENUME,DATA_NASTERE,STUDII) values (19,'Doe','Jane',str_to_date('19-04-2001','%d-%m-%Y'),'fmi');

with candidateInterviewOuter as (
	select distinct c.NUME, c.PRENUME, i.COD_JOB  from CANDIDAT c
    left join INTERVIU i
        on i.COD_CANDIDAT = c.ID_CANDIDAT
	union
    select distinct c2.NUME, c2.PRENUME, i2.COD_JOB  from CANDIDAT c2
	right join INTERVIU i2
    	on i2.COD_CANDIDAT = c2.ID_CANDIDAT
)

select *, j.DENUMIRE, j.DATA_PUBLICARE_ANUNT 
from candidateInterviewOuter ci
left join JOB j
	on j.JOB_ID = ci.COD_JOB
union
select *, j2.DENUMIRE, j2.DATA_PUBLICARE_ANUNT 
from candidateInterviewOuter ci2
right join JOB j2
	on j2.JOB_ID = ci2.COD_JOB
;

delete from JOB j where j.JOB_ID = 5;
delete from CANDIDAT c where c.ID_CANDIDAT = 19;
```

### Task 8

```sql
/*
8. Care este denumirea jobului pentru care diferența dintre data publicării anunțului și data
la care a fost programat primului interviu este maximă?
*/

with jobWithTimeDiff as (
	select *, timediff(data.first_scheduled_date, j.DATA_PUBLICARE_ANUNT) as 'diff_btw_published_and_interview'
    from JOB j
    inner join (
        select i.COD_JOB, min(i.DATA_INTERVIU) as 'first_scheduled_date'
        from INTERVIU i
        group by i.COD_JOB
    ) data
        on data.COD_JOB = j.JOB_ID
)

select 
	jobWithTimeDiff.DENUMIRE
    -- , diff_btw_published_and_interview
from jobWithTimeDiff
where jobWithTimeDiff.diff_btw_published_and_interview = (select max(diff_btw_published_and_interview) from jobWithTimeDiff)
;
```

### Task 9

```sql
/*
9. Să se afișeze numele și prenumele candidaților care au aplicat la cel puțin un job cu un
punctaj_cv peste media punctajelor pentru jobul respectiv.
*/

with applicationAvgScore as (
	select a.COD_JOB, avg(a.PUNCTAJ_CV) as 'avg_score'
    from APLICA a
    group by a.COD_JOB
)

select c.NUME, c.PRENUME
from APLICA a
-- Raman doar aplicatiile pentru care candidatul a obtinut un punctaj peste medie
inner join applicationAvgScore
	on applicationAvgScore.COD_JOB = a.COD_JOB and a.PUNCTAJ_CV > applicationAvgScore.avg_score
inner join CANDIDAT c
	on c.ID_CANDIDAT = a.COD_CANDIDAT
;
```

### Task 10

```sql
/*
10. Pentru candidații care au aplicat la jobul cu id 1, afișați numărul de joburi distincte la care
au aplicat, și punctaj_cv maxim.
*/

-- delete from APLICA a where a.DATA_APLICARE = str_to_date('19-04-2021','%d-%m-%Y');
--insert into APLICA (COD_JOB,COD_CANDIDAT,DATA_APLICARE,PUNCTAJ_CV) values (1,1,str_to_date('19-04-2021','%d-%m-%Y'),72);


select c.NUME, c.PRENUME, data.nr_jobs_applied, data.max_cv_score
from CANDIDAT c
inner join (
	select 
        a.COD_CANDIDAT, 
        count(a.COD_JOB) as 'nr_jobs_applied', 
        max(a.PUNCTAJ_CV) as 'max_cv_score'
    from APLICA a
    where a.COD_JOB = 1
    group by a.COD_CANDIDAT
) data
	on data.COD_CANDIDAT = c.ID_CANDIDAT
;

-- delete from APLICA a where a.DATA_APLICARE = str_to_date('19-04-2021','%d-%m-%Y');
```