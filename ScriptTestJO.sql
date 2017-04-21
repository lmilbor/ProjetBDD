-- D�terminer dans quel service, fili�re et �quipe travail une personne et qui est son manager
select Nom, s.Libell�, f.Libell�, e.IDEquipe, p.LoginManager
from jo.Personne p
inner join jo.Equipe e on p.IDEquipe = e.IDEquipe
inner join jo.Service s on s.IDService = e.IDService
inner join jo.Filiere f on f.IDFiliere = e.IDFiliere
where login = 'BNORMAND'

-- D�terminer sur une p�riode donn�e la r�partition du temps d'une personne sur ses diff�rentes activit�s
select tp.IDActivite, SUM(tt.TempsPass�) as [temps par activit�]
from jo.Tache t
inner join jo.TempsTache tt on tt.IDTache = t.IDTache
right outer join jo.TacheProduction tp on tp.IDTache = t.IDTache
where t.Login = 'BNORMAND' and tt.DateMAJ in ('2017-04-20', '2017-05-25')
group by tp.IDActivite

-- Comparer les temps pr�vus et r�alis�s sur une version d'un logiciel, pour une personne ou une �quipe
select p.Nom, e.IDEquipe, tp.Dur�ePr�vue, SUM(tt.TempsPass�) over (partition by tt.IDTache) as [temps pass�]
from jo.TacheProduction tp
inner join jo.Tache t on t.IDTache = tp.IDTache
inner join jo.TempsTache tt on tt.IDTache = t.IDTache
inner join jo.Personne p on p.Login = t.Login
inner join jo.Equipe e on e.IDEquipe = p.IDEquipe
where tp.IDVersion = '1.00' and (t.Login = 'BNORMAND' or e.IDEquipe = 0)

-- D�terminer la dur�e de travail r�alis�e par chaque �quipe pour produire une version
select e.IDEquipe, SUM(tt.TempsPass�) as [dur�e de travail r�alis�e]
from jo.Equipe e
inner join jo.Personne p on p.IDEquipe = e.IDEquipe
inner join jo.Tache t on t.Login = p.Login
inner join jo.TempsTache tt on tt.IDTache = t.IDTache
inner join jo.TacheProduction tp on tp.IDTache = t.IDTache
where tp.IDVersion = '1.00'
group by e.IDEquipe

-- D�terminer le temps total pass� par une fili�re sur la production de chaque module d�un logiciel depuis sa premi�re version
select l.Libell�, m.Libell�, SUM(tt.TempsPass�) as [temps total pass�]
from jo.TempsTache tt
inner join jo.TacheProduction tp on tp.IDTache = tt.IDTache
inner join jo.Module m on m.IDModule = tp.IDModule
inner join jo.Logiciel l on l.IDLogiciel = m.IDLogiciel
where l.IDFiliere = 'BIOH'
group by l.Libell�, m.Libell�, l.IDLogiciel, m.IDModule