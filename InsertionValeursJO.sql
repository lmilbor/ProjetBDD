-- On remplis la base de donn�e

insert jo.Service (IDService, Libell�) values
('DEV', 'D�veloppement'),
('TEST', 'Test'),
('SL', 'Support Logiciel'),
('MKT', 'Marketing')
go

insert jo.Filiere (IDFiliere, Libell�) values
('BIOV', 'Biologie v�g�tale'),
('BIOH', 'Biologie humaine'),
('BIOA', 'Biologie animale')
go

insert jo.Equipe (IDEquipe, IDFiliere, IDService) values
(0, 'BIOV', 'DEV'),
(1, 'BIOH', 'MKT')
go

insert jo.Logiciel (IDFiliere , IDLogiciel, Libell�) values ('BIOH', 0, 'Genomica')
go

insert jo.Version (IDLogiciel, IDVersion, millesime, DateOuverture, DateSortie, DateSortiePr�vue) values
(0, '1.00', '2017', '2016-01-02', '2017-01-08', ''),
(0, '2.00', '2018', '2016-12-28', '', '')
go

--insert jo.Release

insert jo.Module (IDLogiciel, IDModule, Libell�, IDSurModule) values
(0, 'SEQUENCAGE', 's�quen�age', null),
(0, 'MARQUAGE', 'Marquage', 'SEQUENCAGE'),
(0, 'SEPARATION', 'S�paration', 'SEQUENCAGE'),
(0, 'ANALYSE', 'Analyse', 'SEQUENCAGE'),
(0, 'POLYMORPHISME', 'Polymorphisme g�n�tique', null),
(0, 'VAR_ALLELE', 'Variations all�liques', null),
(0, 'UTIL_DROITS', 'utilisateurs et droits', null),
(0, 'PARAMETRES', 'Param�trage', null)


insert jo.Metier (IDMetier, Libell�) values
('ANA', 'Analyste'),
('CDP', 'Chef de Projet'),
('DEV', 'D�veloppeur'),
('DES', 'Designer'),
('TES', 'Testeur')
go

insert jo.Activite (IDActivit�, Libell�, Type) values
('DBE', 'D�finition des besoins', 'Production'),
('ARF', 'Architecture fonctionnelle', 'Production'),
('ANF', 'Analyse fonctionnelle', 'Production'),
('DES', 'Design', 'Production'),
('INF', 'Infographie', 'Production'),
('ART', 'Architecture technique', 'Production'),
('ANT', 'Analyse technique', 'Production'),
('DEV', 'D�veloppement', 'Production'),
('RPT', 'R�daction de plan de test', 'Production'),
('TES', 'Test', 'Production')
go

insert jo.Metier_Activite (IDMetier, IDActivite) values
('ANA', 'DBE'),('ANA', 'ARF'),('ANA', 'ANF'),
('CDP', 'ARF'),('CDP', 'ANF'),('CDP', 'ART'),('CDP', 'TES'),
('DEV', 'ANF'),('DEV', 'ART'),('DEV', 'ANT'),('DEV', 'DEV'),('DEV', 'TES'),
('DES', 'ANF'),('DES', 'DES'),('DES', 'INF'),
('TES', 'RPT'),('TES', 'TES')

insert jo.Personne (Login, Pr�nom, Nom, IDMetier, IDEquipe, LoginManager) values
('GLECLERCK', 'Genevi�ve', 'LECLERCQ', 'ANA', 1, null),
('AFERRAND', 'Ang�le', 'FERRAND', 'ANA', 1, null),
('BNORMAND', 'Balthazar', 'NORMAND', 'CDP', 0, 'AFERRAND'),
('RFISHER', 'Raymond', 'FISHER', 'DEV', 0, null),
('LBUTLER', 'Lucien', 'BUTLER', 'DEV', 0, null),
('RBEAUMONT', 'Rosline', 'BEAUMONT', 'DEV', 0, null),
('MWEBER', 'Marguerite', 'WEBER', 'DES', 0, null),
('HKLEIN', 'Hilaire', 'KLEIN', 'TES', 0, null),
('NPALMER', 'Nino', 'PALMER', 'TES', 0, null)
go
-- une tache annexe
exec jo.usp_CreeTacheAnnexe @libell� = 'Echange technique / formation', @login = 'LBUTLER'

-- une tache de production
exec jo.usp_CreeTacheProd 
@libell� = 'AT saisie des utilisateur et droits', @login = 'LBUTLER',
@dateDebut = '2017-04-20', @dureePrevue = 7, @iDActivite = 'ANT',
@iDModule = 'UTIL_DROITS', @iDVersion = '1.00'

-- une autre tache tr�s productive
exec jo.usp_CreeTacheProd 
@libell� = 'Faire du codingame', @login = 'BNORMAND',
@dateDebut = '2017-04-10', @dureePrevue = 8, @iDActivite = 'DEV',
@iDModule = 'MARQUAGE', @iDVersion = '1.00'

-- une tache un peu moins productive
exec jo.usp_CreeTacheProd 
@libell� = 'Aller � la p�che ...', @login = 'RFISHER',
@dateDebut = '2017-05-15', @dureePrevue = 10, @iDActivite = 'ANT',
@iDModule = 'PARAMETRES', @iDVersion = '1.00'

-- On a pass� un peu de temps sur ces taches
exec jo.usp_SaisieTempsTache @iDTache = 22, @dateTravail = '2017-04-20', @temps = 2, @productivit� = 80
exec jo.usp_SaisieTempsTache @iDTache = 23, @dateTravail = '2017-04-20', @temps = 3, @productivit� = 100
exec jo.usp_SaisieTempsTache @iDTache = 24, @dateTravail = '2017-04-20', @temps = 1, @productivit� = 50
exec jo.usp_SaisieTempsTache @iDTache = 25, @dateTravail = '2017-04-20', @temps = 3, @productivit� = 60
exec jo.usp_SaisieTempsTache @iDTache = 22, @dateTravail = '2017-05-08', @temps = 3, @productivit� = 80
exec jo.usp_SaisieTempsTache @iDTache = 22, @dateTravail = '2017-05-24', @temps = 1, @productivit� = 100
exec jo.usp_SaisieTempsTache @iDTache = 25, @dateTravail = '2017-05-24', @temps = 4, @productivit� = 100
exec jo.usp_SaisieTempsTache @iDTache = 24, @dateTravail = '2017-05-25', @temps = 3, @productivit� = 90
exec jo.usp_SaisieTempsTache @iDTache = 23, @dateTravail = '2017-05-27', @temps = 4, @productivit� = 75