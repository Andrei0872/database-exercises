# Database exercises

## TODOS

* [ ] add useful tip
* [ ] create ToC
* [ ] add 2nd version for task 6

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