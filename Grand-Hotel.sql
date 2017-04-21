-- 2.1 Clients et coordon�es
-- A.Clients pour lesquels on n'a pas de num�ro de portable
select c.CLI_ID, c.CLI_NOM
from CLIENT c
where c.CLI_ID not in
(select distinct CLI_ID
from TELEPHONE
where TYP_CODE = 'GSM')
-- RESULTAT : 100 lignes

-- B.Clients pour lesquels on a au moins un N� de portable ou une adresse mail
select distinct c.CLI_ID, c.CLI_NOM
from CLIENT c
inner join TELEPHONE t on t.CLI_ID = c.CLI_ID
where t.TYP_CODE = 'GSM' or exists (select CLI_ID from EMAIL)
-- RESULTAT : 100 lignes

-- C.Mettre � jour les num�ros de t�l�phone pour qu'ils soient au format "+33XXXXXXXXX" au lieu de "0X-XX-XX-XX-XX"
begin tran
UPDATE TELEPHONE
set TEL_NUMERO =  replace(TEL_NUMERO, TEL_NUMERO, '+33' + substring(REPLACE(TEL_NUMERO, '-', ''), 2, 10))

select TEL_NUMERO
from TELEPHONE
-- RESULTAT : renvoie les num�ro corrig�s
rollback

-- D.Client qui ont pay� avec au moins deux moyens de paiement diff�rents au cours d'un m�me mois (id, nom)
select distinct c.CLI_ID, CLI_NOM, COUNT(PMCODE) as nbMoyenPaiement, MONTH(FAC_DATE) as mois
from CLIENT c
inner join FACTURE f on c.CLI_ID = f.CLI_ID
group by c.CLI_ID, CLI_NOM, MONTH(FAC_DATE), YEAR(FAC_DATE)
having COUNT(PMCODE) >= 2
-- RESULTAT : O lignes


-- E.Clients de la m�me ville qui se sont d�ja retouv�s en m�me temps � l'h�tel
select distinct c.CLI_ID, c.CLI_NOM, a.ADR_VILLE--, cpc.PLN_JOUR
from CLIENT c
inner join ADRESSE a on a.CLI_ID = c.CLI_ID
inner join CHB_PLN_CLI cpc on cpc.CLI_ID = c.CLI_ID
where exists -- une autre client de la m�me ville existe et a pris une chambre au m�me moment
	(select abis.ADR_VILLE
	from ADRESSE abis
	inner join CHB_PLN_CLI cpcbis on cpcbis.CLI_ID = abis.CLI_ID
	where abis.CLI_ID != c.CLI_ID and abis.ADR_VILLE = a.ADR_VILLE and cpc.PLN_JOUR = cpcbis.PLN_JOUR)
group by a.ADR_VILLE, c.CLI_ID, c.CLI_NOM
order by a.ADR_VILLE

-- RESULTAT : 32 lignes

--2.2 Fr�quentation
-- A.Taux moyen d'occupation de l'h�tel par mois-ann�e.
--   Autrement dit, pour chaque mois-ann�e valeur moyenne sur les chambres du ratio
--   (nombre de jours d'occupation dans le mois / nombre de jours du mois)
SELECT AVG(COUNT(CHB_PLN_CLI_OCCUPE)) over (partition by MONTH(PLN_JOUR), YEAR(PLN_JOUR)) as [Occupation par mois par ann�e],
MONTH(PLN_JOUR) as mois, YEAR(PLN_JOUR) as ann�e
FROM CHB_PLN_CLI
GROUP BY YEAR(PLN_JOUR), MONTH(PLN_JOUR)
order by ann�e

-- RESULTAT : 36 lignes : nombre moyen de clients par mois par ann�es

-- B.Taux moyen d'occupation de chaque �tage par ann�e
select AVG(COUNT(CHB_PLN_CLI_OCCUPE)) over (partition by c.CHB_ETAGE, YEAR(cpc.PLN_JOUR)) as [Nb client par �tage par ann�e], c.CHB_ETAGE as [�tage], YEAR(cpc.PLN_JOUR) as ann�e
from CHB_PLN_CLI cpc
inner join CHAMBRE c on c.CHB_ID = cpc.CHB_ID
group by c.CHB_ETAGE, YEAR(cpc.PLN_JOUR)
order by ann�e

-- RESULTAT : 9 lignes

-- C.Chambre la plus occup�e pour chacune des ann�es
select COUNT(CHB_PLN_CLI_OCCUPE) as [Taux d'occupation], YEAR(PLN_JOUR) ann�e, CHB_ID
from CHB_PLN_CLI
group by CHB_ID, YEAR(PLN_JOUR)
order by YEAR(PLN_JOUR) desc
-- RESULTAT : 

-- D.Taux moyen de r�servation par mois-ann�e
SELECT AVG(COUNT(CHB_PLN_CLI_RESERVE)) over (partition by MONTH(PLN_JOUR), YEAR(PLN_JOUR)) as [Reservation par mois par ann�e],
MONTH(PLN_JOUR) as mois, YEAR(PLN_JOUR) as ann�e
FROM CHB_PLN_CLI
GROUP BY YEAR(PLN_JOUR), MONTH(PLN_JOUR)
order by ann�e

-- RESULTAT : 36 lignes

-- E.Clients qui ont pass� au total au moins 7 jours � l�h�tel au cours d�un m�me mois (Id, Nom, mois o� ils ont pass� au moins 7 jours).
select c.CLI_ID, c.CLI_NOM, COUNT(DAY(PLN_JOUR)) as [nombre de jours],
MONTH(PLN_JOUR) as mois, YEAR(PLN_JOUR) as ann�e
from CHB_PLN_CLI cpc
inner join CLIENT c on c.CLI_ID = cpc.CLI_ID
group by YEAR(PLN_JOUR), MONTH(PLN_JOUR), c.CLI_ID, c.CLI_NOM
having COUNT(DAY(PLN_JOUR)) >=7
order by ann�e, mois

-- RESULTAT : 417 lignes

-- F.Nombre de clients qui sont rest�s � l�h�tel au moins deux jours de suite au cours de l�ann�e 2015
select cpc.CLI_ID, c.CLI_NOM
from CHB_PLN_CLI cpc
inner join CLIENT c on c.CLI_ID = cpc.CLI_ID
where YEAR(PLN_JOUR) = 2015 and exists
(select bis.CLI_ID
from CHB_PLN_CLI bis
where DATEADD(DAY, 1, cpc.PLN_JOUR) = bis.PLN_JOUR and cpc.CLI_ID = bis.CLI_ID)

-- RESULTAT : 575 lignes

-- G.Clients qui ont fait un s�jour � l�h�tel au moins deux mois de suite
select cpc.CLI_ID, c.CLI_NOM
from CHB_PLN_CLI cpc
inner join CLIENT c on c.CLI_ID = cpc.CLI_ID
where YEAR(PLN_JOUR) = 2015 and exists
(select bis.CLI_ID
from CHB_PLN_CLI bis
where DATEADD(MONTH, 1, cpc.PLN_JOUR) = bis.PLN_JOUR and cpc.CLI_ID = bis.CLI_ID)

-- RESULTAT : 592 lignes

-- H.Nombre quotidien moyen de clients pr�sents dans l�h�tel pour chaque mois de l�ann�e 2016, en tenant compte du nombre de personnes dans les chambres

-- RESULTAT : 
-- I.Clients qui ont r�serv� plusieurs fois la m�me chambre au cours d�un m�me mois, mais pas deux jours d�affil�e
-- RESULTAT : 

-- 2.3 Chiffre d'affaire

-- A.Valeur absolue et pourcentage d�augmentation du tarif de chaque chambre sur l�ensemble de la p�riode

-- RESULTAT : 
-- B.Chiffre d'affaire de l�h�tel par trimestre de chaque ann�e

-- RESULTAT : 
-- C.Chiffre d'affaire de l�h�tel par mode de paiement et par an, avec les modes de paiement en colonne et les ann�es en ligne.

-- RESULTAT : 
-- D.D�lai moyen de paiement des factures par ann�e et par mode de paiement, avec les modes de paiement en colonne et les ann�es en ligne.

-- RESULTAT : 
-- E.Compter le nombre de clients dans chaque tranche de 5000 F de chiffre d�affaire total g�n�r�, en partant de 20000 F jusqu�� + de 45 000 F. 

-- RESULTAT : 
-- F.A partir du 01/09/2017, augmenter les tarifs des chambres du rez-de-chauss�e de 5%, celles du 1er �tage de 4% et celles du 2d �tage de 2%.

-- RESULTAT : 