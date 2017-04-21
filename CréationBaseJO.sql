-- Vider la Base de donnée

exec usp_DropAll
--exec usp_DropAllPrint
--------------------------------------------------------------------------
-- Création des tables

CREATE
  TABLE jo.Activite
  (
    IDActivité NVARCHAR (20) NOT NULL ,
    Libellé NVARCHAR (100) NOT NULL ,
    Type NVARCHAR (20) NOT NULL
  )
GO
ALTER TABLE jo.Activite ADD CONSTRAINT Activite_PK PRIMARY KEY CLUSTERED (
IDActivité)
GO

CREATE
  TABLE jo.Equipe
  (
    IDEquipe INTEGER NOT NULL ,
    IDFiliere NVARCHAR (20) NOT NULL ,
    IDService NVARCHAR (20) NOT NULL
  )
GO
ALTER TABLE jo.Equipe ADD CONSTRAINT Equipe_PK PRIMARY KEY CLUSTERED (IDEquipe)
GO

CREATE
  TABLE jo.Filiere
  (
    IDFiliere NVARCHAR (20) NOT NULL ,
    Libellé NVARCHAR (100) NOT NULL
  )
GO
ALTER TABLE jo.Filiere ADD CONSTRAINT Filiere_PK PRIMARY KEY CLUSTERED (
IDFiliere)
GO

CREATE
  TABLE jo.Logiciel
  (
    IDLogiciel INTEGER NOT NULL ,
    IDFiliere NVARCHAR (20) NOT NULL ,
    Libellé NVARCHAR (100) NOT NULL
  )
GO
ALTER TABLE jo.Logiciel ADD CONSTRAINT Logiciel_PK PRIMARY KEY CLUSTERED (
IDLogiciel)
GO

CREATE
  TABLE jo.Metier
  (
    IDMetier NVARCHAR (20) NOT NULL ,
    Libellé NVARCHAR (100) NOT NULL
  )
GO
ALTER TABLE jo.Metier ADD CONSTRAINT Metier_PK PRIMARY KEY CLUSTERED (IDMetier)
GO

CREATE
  TABLE jo.Metier_Activite
  (
    IDMetier NVARCHAR (20) NOT NULL ,
    IDActivite NVARCHAR (20) NOT NULL
  )
GO
ALTER TABLE jo.Metier_Activite ADD CONSTRAINT Metier_Activite_PK PRIMARY KEY
CLUSTERED (IDMetier, IDActivite)
GO

CREATE
  TABLE jo.Module
  (
    IDModule NVARCHAR (20) NOT NULL ,
    IDLogiciel INTEGER NOT NULL ,
    IDSurModule NVARCHAR (20) ,
    Libellé NVARCHAR (100) NOT NULL
  )
GO
ALTER TABLE jo.Module ADD CONSTRAINT Module_PK PRIMARY KEY CLUSTERED (IDModule)
GO

CREATE
  TABLE jo.Personne
  (
    Login NVARCHAR (20) NOT NULL ,
    IDEquipe INTEGER NOT NULL ,
    IDMetier NVARCHAR (20) NOT NULL ,
    LoginManager NVARCHAR (20) ,
    Nom NVARCHAR (100) NOT NULL ,
    Prénom NVARCHAR (100) NOT NULL ,
    Productivité BIGINT NOT NULL DEFAULT 100
  )
GO
ALTER TABLE jo.Personne ADD CONSTRAINT Personne_PK PRIMARY KEY CLUSTERED (Login
)
GO

CREATE
  TABLE jo.Release
  (
    IDRelease INTEGER NOT NULL ,
    DateSetup DATE NOT NULL ,
    IDVersion NVARCHAR (20) NOT NULL ,
    IDLogiciel INTEGER NOT NULL
  )
GO
ALTER TABLE jo.Release
ADD
CHECK ( IDRelease BETWEEN 1 AND 999 )
GO
ALTER TABLE jo.Release ADD CONSTRAINT Release_PK PRIMARY KEY CLUSTERED (
IDRelease, IDVersion, IDLogiciel)
GO

CREATE
  TABLE jo.Service
  (
    IDService NVARCHAR (20) NOT NULL ,
    Libellé NVARCHAR (100) NOT NULL
  )
GO
ALTER TABLE jo.Service ADD CONSTRAINT Service_PK PRIMARY KEY CLUSTERED (
IDService)
GO

CREATE
  TABLE jo.Tache
  (
    IDTache INTEGER NOT NULL IDENTITY NOT FOR REPLICATION,
    Libellé NVARCHAR (100) NOT NULL ,
    Description NVARCHAR (100) ,
    Login NVARCHAR (20) NOT NULL ,
    type INTEGER NOT NULL
  )
GO
ALTER TABLE jo.Tache ADD CONSTRAINT Tache_PK PRIMARY KEY CLUSTERED (IDTache)
GO

CREATE
  TABLE jo.TacheProduction
  (
    IDTache INTEGER NOT NULL ,
    IDVersion NVARCHAR (20) NOT NULL ,
    IDModule NVARCHAR (20) NOT NULL ,
    IDActivite NVARCHAR (20) NOT NULL ,
    DuréePrévue BIGINT NOT NULL ,
    DateDébut DATE NOT NULL ,
    DuréeRestante BIGINT NOT NULL ,
    IDLogiciel INTEGER NOT NULL
  )
GO
ALTER TABLE jo.TacheProduction ADD CONSTRAINT TacheProduction_PK PRIMARY KEY
CLUSTERED (IDTache)
GO

CREATE
  TABLE jo.TempsTache
  (
    IDTache INTEGER NOT NULL ,
    DateMAJ DATE NOT NULL ,
    TempsPassé BIGINT NOT NULL ,
    Productivité BIGINT NOT NULL
  )
GO
ALTER TABLE jo.TempsTache ADD CONSTRAINT TempsTache_PK PRIMARY KEY CLUSTERED (
DateMAJ, IDTache)
GO

CREATE
  TABLE jo.Version
  (
    IDVersion NVARCHAR (20) NOT NULL ,
    IDLogiciel INTEGER NOT NULL ,
    millesime NVARCHAR (40) NOT NULL ,
    DateOuverture    DATE NOT NULL ,
    DateSortie       DATE ,
    DateSortiePrévue DATE NOT NULL
  )
GO
ALTER TABLE jo.Version ADD CONSTRAINT Version_PK PRIMARY KEY CLUSTERED (
IDVersion, IDLogiciel)
GO

ALTER TABLE jo.Equipe
ADD CONSTRAINT Equipe_Filiere_FK FOREIGN KEY
(
IDFiliere
)
REFERENCES jo.Filiere
(
IDFiliere
)
GO

ALTER TABLE jo.Equipe
ADD CONSTRAINT Equipe_Service_FK FOREIGN KEY
(
IDService
)
REFERENCES jo.Service
(
IDService
)
GO

ALTER TABLE jo.Metier_Activite
ADD CONSTRAINT FK_ASS_28 FOREIGN KEY
(
IDMetier
)
REFERENCES jo.Metier
(
IDMetier
)
GO

ALTER TABLE jo.Metier_Activite
ADD CONSTRAINT FK_ASS_29 FOREIGN KEY
(
IDActivite
)
REFERENCES jo.Activite
(
IDActivité
)
GO

ALTER TABLE jo.Logiciel
ADD CONSTRAINT Logiciel_Filiere_FK FOREIGN KEY
(
IDFiliere
)
REFERENCES jo.Filiere
(
IDFiliere
)
GO

ALTER TABLE jo.Module
ADD CONSTRAINT Module_Logiciel_FK FOREIGN KEY
(
IDLogiciel
)
REFERENCES jo.Logiciel
(
IDLogiciel
)
GO

ALTER TABLE jo.Module
ADD CONSTRAINT Module_Module_FK FOREIGN KEY
(
IDSurModule
)
REFERENCES jo.Module
(
IDModule
)
GO

ALTER TABLE jo.Personne
ADD CONSTRAINT Personne_Equipe_FK FOREIGN KEY
(
IDEquipe
)
REFERENCES jo.Equipe
(
IDEquipe
)
GO

ALTER TABLE jo.Personne
ADD CONSTRAINT Personne_Metier_FK FOREIGN KEY
(
IDMetier
)
REFERENCES jo.Metier
(
IDMetier
)
GO

ALTER TABLE jo.Personne
ADD CONSTRAINT Personne_Personne_FK FOREIGN KEY
(
LoginManager
)
REFERENCES jo.Personne
(
Login
)
GO

ALTER TABLE jo.RELEASE
ADD CONSTRAINT Release_Version_FK FOREIGN KEY
(
IDVersion,
IDLogiciel
)
REFERENCES jo.Version
(
IDVersion ,
IDLogiciel
)
GO

ALTER TABLE jo.TacheProduction
ADD CONSTRAINT TacheProduction_Activite_FK FOREIGN KEY
(
IDActivite
)
REFERENCES jo.Activite
(
IDActivité
)
GO

ALTER TABLE jo.TacheProduction
ADD CONSTRAINT TacheProduction_Module_FK FOREIGN KEY
(
IDModule
)
REFERENCES jo.Module
(
IDModule
)
GO

ALTER TABLE jo.TacheProduction
ADD CONSTRAINT TacheProduction_Tache_FK FOREIGN KEY
(
IDTache
)
REFERENCES jo.Tache
(
IDTache
)
GO

ALTER TABLE jo.TacheProduction
ADD CONSTRAINT TacheProduction_Version_FK FOREIGN KEY
(
IDVersion,
IDLogiciel
)
REFERENCES jo.Version
(
IDVersion ,
IDLogiciel
)
GO

ALTER TABLE jo.Tache
ADD CONSTRAINT Tache_Personne_FK FOREIGN KEY
(
Login
)
REFERENCES jo.Personne
(
Login
)
GO

ALTER TABLE jo.TempsTache
ADD CONSTRAINT TempsTache_Tache_FK FOREIGN KEY
(
IDTache
)
REFERENCES jo.Tache
(
IDTache
)
GO

ALTER TABLE jo.Version
ADD CONSTRAINT Version_Logiciel_FK FOREIGN KEY
(
IDLogiciel
)
REFERENCES jo.Logiciel
(
IDLogiciel
)
GO