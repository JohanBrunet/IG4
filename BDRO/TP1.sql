--              Les tableaux Varray et tables imbriquées

-- Q1.
drop table etudiants;

drop type Tetudiant force;
drop type TlistePrenom force;
drop type Ttel force;
drop type Tadresse force;
drop type type_adresse force;
drop table diplomes;
drop table etudiants;

create type TlistePrenom as VARRAY(4) of varchar(30);
/
create type Ttel as VARRAY(2) of varchar(13);
/
create type type_adresse as object(
    rue varchar(256),
    ville varchar(20),
    code varchar(6)
);
/
create type Tadresse as table of type_adresse; --table imbriquée
/
create type Tetudiant as object(
    numero number,
    nom varchar(30),
    prenoms TlistePrenom,
    adresses Tadresse,
    tels Ttel
);
/

create table etudiants of Tetudiant(
    numero primary key
)
nested table adresses store as nt_adresses_etudiants;

-- Q2.

insert into etudiants values('901001',
'LEVEQUE',
TlistePrenom('PIERRE','PAUL','JEAN',null),
Tadresse(type_adresse('10 avenue Foch','MONTPELLIER',null),type_adresse('30 rue des Moulins','ANGERS',null)),
Ttel('0656678956','0467566723')
);
insert into etudiants values('902043',
'DUPONT',
TlistePrenom('MARIE,','ISABELLE',null,null),
Tadresse(type_adresse('23 rue des Abeilles','MONTPELLIER',null),type_adresse('10 Avenue Foch','Paris',null)),
Ttel('0634321245',null)
);
insert into etudiants values('902075',
'RENARD',
TlistePrenom('ALBERT','JEAN',null,null),
Tadresse(type_adresse('3 Impasse des Cigales','MONTPELLIER',null),type_adresse('45 Avenue de Palavas','CARNON',null)),
Ttel('0456788900',null)
);
insert into etudiants values('911007',
'MARTIN',
TlistePrenom('LOIC',null,null,null),
Tadresse(type_adresse('67 Rue des Colles','BEZIER',null)),
Ttel(null,null)
);
insert into etudiants values('911021',
'DUPONT',
TlistePrenom('ANTOINE',null,null,null),
Tadresse(type_adresse('10 Avenue Foch','MONTPELLIER',null),type_adresse('20 rue Jean Moulin','NEVERS',null)),
Ttel(null,null)
);

-- Q3.
insert into etudiants values('911022',
'DUPONT',
TlistePrenom('SYLVIE',null,null,null),
(select adresses from etudiants where numero = '902043'),
Ttel(null,null)
);

-- Q4.
    -- Leveque Pierre
        --Mettre a jour le numéro de téléphone seulement => récupérer le fixe
update etudiants  
set tels = Ttel('0645678989', 
                (select t.column_value 
                from etudiants e, table(e.tels) t 
                where numero = '901001' and t.column_value like '04%')
    )
where numero='901001';

        --Mettre a jour l'adresse de Montpellier dans le nested table
update table (select adresses from etudiants where numero = '901001')
set rue = '10 impasse des Moulins'
where ville = 'MONTPELLIER';

    -- Dupont Antoine
            --Mettre a jour les numéro de téléphone 
update etudiants  
set tels = Ttel('0656457890', '0467786744')
where numero='911021';

-- Q5.
    -- 1) les adresses d'un etudiant dont le nom est donné en paramètre
select e.prenoms, t.rue, t.ville, t.code 
from etudiants e, table(e.adresses) t 
where e.nom = '&donnerNom';

    -- 2) les étudiants qui habitent 10 avenue Foch
select e.nom, e.prenoms
from etudiants e, table(e.adresses) t 
where t.rue = '10 Avenue Foch';
    -- 3) Les étudiants qui possèdent un portable
select e.nom, e.prenoms
from etudiants e, table(e.tels) t 
where t.column_value like '06%';

-- Référencer les objets 
  -- Q1

drop type Tdiplome force;
create type Tdiplome as object(
  nom varchar(50),
  fac varchar(20)
);
/
drop table diplomes;
create table diplomes of Tdiplome;/

insert into diplomes values('Maitrise d''informatique', 'UMII');
insert into diplomes values('License d''informatique', 'UMII');
insert into diplomes values('Deug MIASS', 'UMII');
insert into diplomes values('IG', 'ISIM-UMII');


  -- Q2
  
alter type Tetudiant add attribute (diplome REF Tdiplome) cascade;

update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'IG')
where numero = '901001'; 

update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'Maitrise d''informatique')
where numero = '902043'; 

update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'License d''informatique')
where numero = '902075'; 

update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'Maitrise d''informatique')
where numero = '911007';

update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'IG')
where numero = '911021';

update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'Deug MIASS')
where numero = '911022';

  -- Q3
  
select e.nom, deref(e.diplome).nom from etudiants e;

  -- Q4

delete from diplomes where nom = 'Deug MIASS';
update etudiants set diplome=null where diplome is dangling;
  
  -- Q5
  
select e.nom, deref(e.diplome).nom from etudiants e where deref(e.diplome) is not null;  

  -- Q6

drop type TListeDiplomes;
create type TListeDiplomes as table of REF TDiplome;
/
alter type Tetudiant drop attribute diplome cascade;
alter type Tetudiant add attribute (diplomes TListeDiplomes) cascade;

-- Les tables système

  -- Q1
  
select * from User_Types;
select * from User_Coll_Types;
select * from User_Tab_COlumns;
select * from User_Type_Attrs;

-- Les méthodes

/* On revient à un seul diplôme par étudiant */
alter type Tetudiant drop attribute diplomes cascade;
alter type Tetudiant add attribute (diplome ref Tdiplome) cascade;
update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'IG')
where numero = '901001'; 
update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'Maitrise d''informatique')
where numero = '902043'; 
update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'License d''informatique')
where numero = '902075'; 
update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'Maitrise d''informatique')
where numero = '911007';
update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'IG')
where numero = '911021';
update etudiants 
set diplome = (select ref(d) from diplomes d where d.nom = 'Deug MIASS')
where numero = '911022';

alter type Tetudiant add attribute (date_naiss date) cascade;
alter table etudiants modify  date_naiss default '23/10/85';
update etudiants set  date_naiss = '23/10/85';

/* Méthode age */
alter type Tetudiant add member function age return number cascade;
create or replace type body Tetudiant as
member function age return number is
begin
  return round(months_between( sysdate , to_date(date_naiss))/12);
end age;
end;
/

select nom, e.age() from etudiants e;

/* Méthode estInscrit */
alter type Tetudiant add member function EstInscrit return varchar2  cascade;
create or replace type body Tetudiant as
  member function age  return number is 
  begin 
  return round(months_between( sysdate , to_date(date_naiss))/12);
  end age;

  member function EstInscrit  return varchar2 is
  begin
    declare
	  dp TDiplome;
    begin
      -- attention   deref(x).y interdit avec pl/sql (mais ok en SQL)
      select deref(diplome) into dp from dual;
      return dp.nom;
    end;
  end EstInscrit; 
end;
/

select nom, e.age(), e.EstInscrit()  from etudiants e;

/* Méthode ajoutDiplome */
alter type Tetudiant add static procedure ajoutDiplome(num in number, intitule in varchar2, faculte in varchar2) cascade; 
create or replace type body Tetudiant as
  member function age  return number is 
  begin 
  return round(months_between( sysdate , to_date(date_naiss))/12);
  end age;

  member function EstInscrit  return varchar2 is
  begin
    declare
	  dp TDiplome;
    begin
      select deref(diplome) into dp from dual;
      return dp.nom;
    end;
  end EstInscrit; 
  
  static procedure ajoutDiplome(num in number, intitule in varchar2, faculte in varchar2) is
  begin
    declare 
        c number;
    begin
        select count(*) into c from diplomes where nom = intitule and fac = faculte;
        if c = 0
        then
            insert into diplomes values (intitule, faculte);
        end if;
        update etudiants 
        set diplome = (select ref(d) from diplomes d where nom = intitule and fac = faculte)
        where numero = num;
        end;
    end ajoutDiplome;
end;
/

call Tetudiant.ajoutDiplome('901001', 'DUT', 'IUT');
