-- Déterminer dans quel service, filière et équipe travail une personne et qui est son manager
select Nom, s.Libellé, f.Libellé, e.IDEquipe, p.LoginManager
from jo.Personne p
inner join jo.Equipe e on p.IDEquipe = e.IDEquipe
inner join jo.Service s on s.IDService = e.IDService
inner join jo.Filiere f on f.IDFiliere = e.IDFiliere
where login = 'BNORMAND'

-- Déterminer sur une période donnée la répartition du temps d'une personne sur ses différentes activités
select tp.IDActivite, SUM(tt.TempsPassé) as [temps par activité]
from jo.Tache t
inner join jo.TempsTache tt on tt.IDTache = t.IDTache
right outer join jo.TacheProduction tp on tp.IDTache = t.IDTache
where t.Login = 'BNORMAND' and tt.DateMAJ in ('2017-04-20', '2017-05-25')
group by tp.IDActivite

-- Comparer les temps prévus et réalisés sur une version d'un logiciel, pour une personne ou une équipe
select p.Nom, e.IDEquipe, tp.DuréePrévue, SUM(tt.TempsPassé) over (partition by tt.IDTache) as [temps passé]
from jo.TacheProduction tp
inner join jo.Tache t on t.IDTache = tp.IDTache
inner join jo.TempsTache tt on tt.IDTache = t.IDTache
inner join jo.Personne p on p.Login = t.Login
inner join jo.Equipe e on e.IDEquipe = p.IDEquipe
where tp.IDVersion = '1.00' and (t.Login = 'BNORMAND' or e.IDEquipe = 0)

-- Déterminer la durée de travail réalisée par chaque équipe pour produire une version
select e.IDEquipe, SUM(tt.TempsPassé) as [durée de travail réalisée]
from jo.Equipe e
inner join jo.Personne p on p.IDEquipe = e.IDEquipe
inner join jo.Tache t on t.Login = p.Login
inner join jo.TempsTache tt on tt.IDTache = t.IDTache
inner join jo.TacheProduction tp on tp.IDTache = t.IDTache
where tp.IDVersion = '1.00'
group by e.IDEquipe

-- Déterminer le temps total passé par une filière sur la production de chaque module d’un logiciel depuis sa première version
select l.Libellé, m.Libellé, SUM(tt.TempsPassé) as [temps total passé]
from jo.TempsTache tt
inner join jo.TacheProduction tp on tp.IDTache = tt.IDTache
inner join jo.Module m on m.IDModule = tp.IDModule
inner join jo.Logiciel l on l.IDLogiciel = m.IDLogiciel
where l.IDFiliere = 'BIOH'
group by l.Libellé, m.Libellé, l.IDLogiciel, m.IDModule