-- On remplis la base de donnée

insert jo.Service (IDService, Libellé) values
('DEV', 'Développement'),
('TEST', 'Test'),
('SL', 'Support Logiciel'),
('MKT', 'Marketing')
go

insert jo.Filiere (IDFiliere, Libellé) values
('BIOV', 'Biologie végétale'),
('BIOH', 'Biologie humaine'),
('BIOA', 'Biologie animale')
go

insert jo.Equipe (IDEquipe, IDFiliere, IDService) values
(0, 'BIOV', 'DEV'),
(1, 'BIOH', 'MKT')
go

insert jo.Logiciel (IDFiliere , IDLogiciel, Libellé) values ('BIOH', 0, 'Genomica')
go

insert jo.Version (IDLogiciel, IDVersion, millesime, DateOuverture, DateSortie, DateSortiePrévue) values
(0, '1.00', '2017', '2016-01-02', '2017-01-08', ''),
(0, '2.00', '2018', '2016-12-28', '', '')
go

--insert jo.Release

insert jo.Module (IDLogiciel, IDModule, Libellé, IDSurModule) values
(0, 'SEQUENCAGE', 'séquençage', null),
(0, 'MARQUAGE', 'Marquage', 'SEQUENCAGE'),
(0, 'SEPARATION', 'Séparation', 'SEQUENCAGE'),
(0, 'ANALYSE', 'Analyse', 'SEQUENCAGE'),
(0, 'POLYMORPHISME', 'Polymorphisme génétique', null),
(0, 'VAR_ALLELE', 'Variations alléliques', null),
(0, 'UTIL_DROITS', 'utilisateurs et droits', null),
(0, 'PARAMETRES', 'Paramétrage', null)


insert jo.Metier (IDMetier, Libellé) values
('ANA', 'Analyste'),
('CDP', 'Chef de Projet'),
('DEV', 'Développeur'),
('DES', 'Designer'),
('TES', 'Testeur')
go

insert jo.Activite (IDActivité, Libellé, Type) values
('DBE', 'Définition des besoins', 'Production'),
('ARF', 'Architecture fonctionnelle', 'Production'),
('ANF', 'Analyse fonctionnelle', 'Production'),
('DES', 'Design', 'Production'),
('INF', 'Infographie', 'Production'),
('ART', 'Architecture technique', 'Production'),
('ANT', 'Analyse technique', 'Production'),
('DEV', 'Développement', 'Production'),
('RPT', 'Rédaction de plan de test', 'Production'),
('TES', 'Test', 'Production')
go

insert jo.Metier_Activite (IDMetier, IDActivite) values
('ANA', 'DBE'),('ANA', 'ARF'),('ANA', 'ANF'),
('CDP', 'ARF'),('CDP', 'ANF'),('CDP', 'ART'),('CDP', 'TES'),
('DEV', 'ANF'),('DEV', 'ART'),('DEV', 'ANT'),('DEV', 'DEV'),('DEV', 'TES'),
('DES', 'ANF'),('DES', 'DES'),('DES', 'INF'),
('TES', 'RPT'),('TES', 'TES')

insert jo.Personne (Login, Prénom, Nom, IDMetier, IDEquipe, LoginManager) values
('GLECLERCK', 'Geneviève', 'LECLERCQ', 'ANA', 1, null),
('AFERRAND', 'Angèle', 'FERRAND', 'ANA', 1, null),
('BNORMAND', 'Balthazar', 'NORMAND', 'CDP', 0, 'AFERRAND'),
('RFISHER', 'Raymond', 'FISHER', 'DEV', 0, null),
('LBUTLER', 'Lucien', 'BUTLER', 'DEV', 0, null),
('RBEAUMONT', 'Rosline', 'BEAUMONT', 'DEV', 0, null),
('MWEBER', 'Marguerite', 'WEBER', 'DES', 0, null),
('HKLEIN', 'Hilaire', 'KLEIN', 'TES', 0, null),
('NPALMER', 'Nino', 'PALMER', 'TES', 0, null)
go
-- une tache annexe
exec jo.usp_CreeTacheAnnexe @libellé = 'Echange technique / formation', @login = 'LBUTLER'

-- une tache de production
exec jo.usp_CreeTacheProd 
@libellé = 'AT saisie des utilisateur et droits', @login = 'LBUTLER',
@dateDebut = '2017-04-20', @dureePrevue = 7, @iDActivite = 'ANT',
@iDModule = 'UTIL_DROITS', @iDVersion = '1.00'

-- une autre tache très productive
exec jo.usp_CreeTacheProd 
@libellé = 'Faire du codingame', @login = 'BNORMAND',
@dateDebut = '2017-04-10', @dureePrevue = 8, @iDActivite = 'DEV',
@iDModule = 'MARQUAGE', @iDVersion = '1.00'

-- une tache un peu moins productive
exec jo.usp_CreeTacheProd 
@libellé = 'Aller à la pêche ...', @login = 'RFISHER',
@dateDebut = '2017-05-15', @dureePrevue = 10, @iDActivite = 'ANT',
@iDModule = 'PARAMETRES', @iDVersion = '1.00'

-- On a passé un peu de temps sur ces taches
exec jo.usp_SaisieTempsTache @iDTache = 22, @dateTravail = '2017-04-20', @temps = 2, @productivité = 80
exec jo.usp_SaisieTempsTache @iDTache = 23, @dateTravail = '2017-04-20', @temps = 3, @productivité = 100
exec jo.usp_SaisieTempsTache @iDTache = 24, @dateTravail = '2017-04-20', @temps = 1, @productivité = 50
exec jo.usp_SaisieTempsTache @iDTache = 25, @dateTravail = '2017-04-20', @temps = 3, @productivité = 60
exec jo.usp_SaisieTempsTache @iDTache = 22, @dateTravail = '2017-05-08', @temps = 3, @productivité = 80
exec jo.usp_SaisieTempsTache @iDTache = 22, @dateTravail = '2017-05-24', @temps = 1, @productivité = 100
exec jo.usp_SaisieTempsTache @iDTache = 25, @dateTravail = '2017-05-24', @temps = 4, @productivité = 100
exec jo.usp_SaisieTempsTache @iDTache = 24, @dateTravail = '2017-05-25', @temps = 3, @productivité = 90
exec jo.usp_SaisieTempsTache @iDTache = 23, @dateTravail = '2017-05-27', @temps = 4, @productivité = 75