drop view VOexemplaire;
drop type Tabonne;
drop view VOabonne;
drop type NTemprunt;
drop type Temprunt;
drop type Texemplaire;
/

-- Q1

create type Texemplaire as object (
    num_ex NUMBER,
    date_achat DATE,
    prix NUMBER,
    code_pret VARCHAR(20),
    etat VARCHAR(10),
    ISBN VARCHAR(20)
);
/

create type Temprunt as object (
    exemplaire ref Texemplaire,
    date_emprunt DATE,
    date_retour DATE,
    date_retour_reel DATE,
    nb_relance NUMBER
);
/
create type NTemprunt as table of Temprunt;
/

create type Tabonne as object (
    num_ab NUMBER,
    nom VARCHAR(30),
    prenom VARCHAR(20),
    ville VARCHAR(30),
    age NUMBER,
    tarif NUMBER,
    reduc NUMBER,
    emprunts NTemprunt
);
/

-- Q2

create view VOexemplaire of Texemplaire with object oid(num_ex)
as
select numero, date_achat, prix, code_pret, etat, isbn from exemplaire;
/

create view VOabonne of Tabonne with object oid(num_ab)
as
select num_ab, nom, prenom, ville, age, tarif, reduc,
cast(
    multiset(
        select Temprunt(make_ref(VOexemplaire, num_ex), d_emprunt, d_retour, d_ret_reel, nb_relance)
        from emprunt e
        where a.num_ab = e.num_ab
    ) as NTemprunt
)
from abonne a;
/

-- Q3

-- Q3.1
select * from VOabonne where nom = 'LUCAS';
-- Q3.2
select nom, deref(e.exemplaire) from VOabonne a, table(a.emprunts) e where nom = 'LUCAS';


-- Q4

create or replace trigger ins_VOabonne
instead of insert on VOabonne
begin

end;


