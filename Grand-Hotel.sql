-- 2.1 Clients et coordonées
-- A.Clients pour lesquels on n'a pas de numéro de portable
select c.CLI_ID, c.CLI_NOM
from CLIENT c
where c.CLI_ID not in
(select distinct CLI_ID
from TELEPHONE
where TYP_CODE = 'GSM')
-- RESULTAT : 100 lignes

-- B.Clients pour lesquels on a au moins un N° de portable ou une adresse mail
select distinct c.CLI_ID, c.CLI_NOM
from CLIENT c
inner join TELEPHONE t on t.CLI_ID = c.CLI_ID
where t.TYP_CODE = 'GSM' or exists (select CLI_ID from EMAIL)
-- RESULTAT : 100 lignes

-- C.Mettre à jour les numéros de téléphone pour qu'ils soient au format "+33XXXXXXXXX" au lieu de "0X-XX-XX-XX-XX"
begin tran
UPDATE TELEPHONE
set TEL_NUMERO =  replace(TEL_NUMERO, TEL_NUMERO, '+33' + substring(REPLACE(TEL_NUMERO, '-', ''), 2, 10))

select TEL_NUMERO
from TELEPHONE
-- RESULTAT : renvoie les numéro corrigés
rollback

-- D.Client qui ont payé avec au moins deux moyens de paiement différents au cours d'un même mois (id, nom)
select distinct c.CLI_ID, CLI_NOM, COUNT(PMCODE) as nbMoyenPaiement, MONTH(FAC_DATE) as mois
from CLIENT c
inner join FACTURE f on c.CLI_ID = f.CLI_ID
group by c.CLI_ID, CLI_NOM, MONTH(FAC_DATE), YEAR(FAC_DATE)
having COUNT(PMCODE) >= 2
-- RESULTAT : O lignes


-- E.Clients de la même ville qui se sont déja retouvés en même temps à l'hôtel
select distinct c.CLI_ID, c.CLI_NOM, a.ADR_VILLE--, cpc.PLN_JOUR
from CLIENT c
inner join ADRESSE a on a.CLI_ID = c.CLI_ID
inner join CHB_PLN_CLI cpc on cpc.CLI_ID = c.CLI_ID
where exists -- une autre client de la même ville existe et a pris une chambre au même moment
	(select abis.ADR_VILLE
	from ADRESSE abis
	inner join CHB_PLN_CLI cpcbis on cpcbis.CLI_ID = abis.CLI_ID
	where abis.CLI_ID != c.CLI_ID and abis.ADR_VILLE = a.ADR_VILLE and cpc.PLN_JOUR = cpcbis.PLN_JOUR)
group by a.ADR_VILLE, c.CLI_ID, c.CLI_NOM
order by a.ADR_VILLE

-- RESULTAT : 32 lignes

--2.2 Fréquentation
-- A.Taux moyen d'occupation de l'hôtel par mois-année.
--   Autrement dit, pour chaque mois-année valeur moyenne sur les chambres du ratio
--   (nombre de jours d'occupation dans le mois / nombre de jours du mois)
SELECT AVG(COUNT(CHB_PLN_CLI_OCCUPE)) over (partition by MONTH(PLN_JOUR), YEAR(PLN_JOUR)) as [Occupation par mois par année],
MONTH(PLN_JOUR) as mois, YEAR(PLN_JOUR) as année
FROM CHB_PLN_CLI
GROUP BY YEAR(PLN_JOUR), MONTH(PLN_JOUR)
order by année

-- RESULTAT : 36 lignes : nombre moyen de clients par mois par années

-- B.Taux moyen d'occupation de chaque étage par année
select AVG(COUNT(CHB_PLN_CLI_OCCUPE)) over (partition by c.CHB_ETAGE, YEAR(cpc.PLN_JOUR)) as [Nb client par étage par année], c.CHB_ETAGE as [étage], YEAR(cpc.PLN_JOUR) as année
from CHB_PLN_CLI cpc
inner join CHAMBRE c on c.CHB_ID = cpc.CHB_ID
group by c.CHB_ETAGE, YEAR(cpc.PLN_JOUR)
order by année

-- RESULTAT : 9 lignes

-- C.Chambre la plus occupée pour chacune des années
select COUNT(CHB_PLN_CLI_OCCUPE) as [Taux d'occupation], YEAR(PLN_JOUR) année, CHB_ID
from CHB_PLN_CLI
group by CHB_ID, YEAR(PLN_JOUR)
order by YEAR(PLN_JOUR) desc
-- RESULTAT : 

-- D.Taux moyen de réservation par mois-année
SELECT AVG(COUNT(CHB_PLN_CLI_RESERVE)) over (partition by MONTH(PLN_JOUR), YEAR(PLN_JOUR)) as [Reservation par mois par année],
MONTH(PLN_JOUR) as mois, YEAR(PLN_JOUR) as année
FROM CHB_PLN_CLI
GROUP BY YEAR(PLN_JOUR), MONTH(PLN_JOUR)
order by année

-- RESULTAT : 36 lignes

-- E.Clients qui ont passé au total au moins 7 jours à l’hôtel au cours d’un même mois (Id, Nom, mois où ils ont passé au moins 7 jours).
select c.CLI_ID, c.CLI_NOM, COUNT(DAY(PLN_JOUR)) as [nombre de jours],
MONTH(PLN_JOUR) as mois, YEAR(PLN_JOUR) as année
from CHB_PLN_CLI cpc
inner join CLIENT c on c.CLI_ID = cpc.CLI_ID
group by YEAR(PLN_JOUR), MONTH(PLN_JOUR), c.CLI_ID, c.CLI_NOM
having COUNT(DAY(PLN_JOUR)) >=7
order by année, mois

-- RESULTAT : 417 lignes

-- F.Nombre de clients qui sont restés à l’hôtel au moins deux jours de suite au cours de l’année 2015
select cpc.CLI_ID, c.CLI_NOM
from CHB_PLN_CLI cpc
inner join CLIENT c on c.CLI_ID = cpc.CLI_ID
where YEAR(PLN_JOUR) = 2015 and exists
(select bis.CLI_ID
from CHB_PLN_CLI bis
where DATEADD(DAY, 1, cpc.PLN_JOUR) = bis.PLN_JOUR and cpc.CLI_ID = bis.CLI_ID)

-- RESULTAT : 575 lignes

-- G.Clients qui ont fait un séjour à l’hôtel au moins deux mois de suite
select cpc.CLI_ID, c.CLI_NOM
from CHB_PLN_CLI cpc
inner join CLIENT c on c.CLI_ID = cpc.CLI_ID
where YEAR(PLN_JOUR) = 2015 and exists
(select bis.CLI_ID
from CHB_PLN_CLI bis
where DATEADD(MONTH, 1, cpc.PLN_JOUR) = bis.PLN_JOUR and cpc.CLI_ID = bis.CLI_ID)

-- RESULTAT : 592 lignes

-- H.Nombre quotidien moyen de clients présents dans l’hôtel pour chaque mois de l’année 2016, en tenant compte du nombre de personnes dans les chambres

-- RESULTAT : 
-- I.Clients qui ont réservé plusieurs fois la même chambre au cours d’un même mois, mais pas deux jours d’affilée
-- RESULTAT : 

-- 2.3 Chiffre d'affaire

-- A.Valeur absolue et pourcentage d’augmentation du tarif de chaque chambre sur l’ensemble de la période

-- RESULTAT : 
-- B.Chiffre d'affaire de l’hôtel par trimestre de chaque année

-- RESULTAT : 
-- C.Chiffre d'affaire de l’hôtel par mode de paiement et par an, avec les modes de paiement en colonne et les années en ligne.

-- RESULTAT : 
-- D.Délai moyen de paiement des factures par année et par mode de paiement, avec les modes de paiement en colonne et les années en ligne.

-- RESULTAT : 
-- E.Compter le nombre de clients dans chaque tranche de 5000 F de chiffre d’affaire total généré, en partant de 20000 F jusqu’à + de 45 000 F. 

-- RESULTAT : 
-- F.A partir du 01/09/2017, augmenter les tarifs des chambres du rez-de-chaussée de 5%, celles du 1er étage de 4% et celles du 2d étage de 2%.

-- RESULTAT : 