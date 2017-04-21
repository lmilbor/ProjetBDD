---- Ecriture des contraintes de cl�s �trang�res, vues et des tables qu'on peut supprimer
if exists (select * from sys.procedures where name = 'usp_DropAllPrint')
	drop procedure jo.usp_DropAllPrint
go
create procedure jo.usp_DropAllPrint
as
begin
	declare @dropAllConstraints table (nom nvarchar(50), nomTable nvarchar(50))
	declare @dropAllTable table (nomTable nvarchar(50))
	DECLARE @req AS VARCHAR(MAX)
	set @req = ''

	insert @dropAllConstraints
	select CONSTRAINT_NAME, TABLE_NAME
	from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
	where CONSTRAINT_TYPE = 'FOREIGN KEY'

	select @req = @req + 'alter table jo.' + nomTable + ' drop constraint ' + nom +  ';' + CHAR(13)
	from @dropAllConstraints
	
	print @req
	
	set @req = ''
	
	insert @dropAllTable
	select TABLE_NAME
	from INFORMATION_SCHEMA.TABLES
	where TABLE_TYPE = 'BASE TABLE' or TABLE_TYPE = 'VIEW'
	
	select @req = @req + 'drop table jo.' + nomTable + ';' + CHAR(13)
	from @dropAllTable
	group by nomTable
	
	print @req
end
go

---- Suppression des contraintes de cl�s �trang�res, vues et des tables
if exists (select * from sys.procedures where name = 'usp_DropAll')
	drop procedure jo.usp_DropAll
go
create procedure jo.usp_DropAll
as
begin
	declare @dropAllConstraints table (nom nvarchar(50), nomTable nvarchar(50))
	declare @dropAllTable table (nomTable nvarchar(50))
	DECLARE @req AS VARCHAR(MAX)
	set @req = ''

	insert @dropAllConstraints
	select CONSTRAINT_NAME, TABLE_NAME
	from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
	where CONSTRAINT_TYPE = 'FOREIGN KEY'

	select @req = @req + 'alter table jo.' + nomTable + ' drop constraint ' + nom +  ';' + CHAR(13)
	from @dropAllConstraints
	
	--print @req
	EXEC(@req)
	
	set @req = ''
	
	insert @dropAllTable
	select TABLE_NAME
	from INFORMATION_SCHEMA.TABLES
	where TABLE_TYPE = 'BASE TABLE' or TABLE_TYPE = 'VIEW'
	
	select @req = @req + 'drop table jo.' + nomTable + ';' + CHAR(13)
	from @dropAllTable
	group by nomTable
	
	--print @req
	EXEC(@req)
end
go
---- Cr�ation d'une tache de production
if exists (select * from sys.procedures where name = 'usp_CreeTacheProd')
	drop procedure jo.usp_CreeTacheProd
go
create procedure jo.usp_CreeTacheProd @libell� nvarchar(100), @login nvarchar(20), @dateDebut date, @dureePrevue bigint, @iDActivite nvarchar(20), @iDModule nvarchar(20), @iDVersion nvarchar(20) , @description nvarchar(100) = null
as
begin
insert jo.Tache (Libell�, Login, type, Description) values
(@libell�, @login, 1, @description)

insert jo.TacheProduction (IDTache, DateD�but, Dur�ePr�vue, Dur�eRestante, IDActivite, IDLogiciel, IDModule, IDVersion) values
((select top(1) IDTache from jo.Tache order by IDTache desc),
@dateDebut, @dureePrevue, @dureePrevue, @iDActivite,
(select IDLogiciel from jo.Module where IDModule = @iDModule),
@iDModule, @iDVersion)
end
go

---- cr�ation d�une t�che annexe
if exists (select * from sys.procedures where name = 'usp_CreeTacheAnnexe')
	drop procedure jo.usp_CreeTacheAnnexe
go
create procedure jo.usp_CreeTacheAnnexe @libell� nvarchar(100), @login nvarchar(20), @description nvarchar(100) = null
as
begin
insert jo.Tache (Libell�, Login, type, Description) values
(@libell�, @login, 0, @description)
end
go

---- saisie de temps sur une t�che. Si le temps total saisi pour une journ�e d�passe 8h, une erreur explicite doit �tre renvoy�e
if exists (select * from sys.procedures where name = 'usp_SaisieTempsTache')
	drop procedure jo.usp_SaisieTempsTache
go
create procedure jo.usp_SaisieTempsTache @iDTache int, @dateTravail date, @temps bigint, @productivit� bigint = 100
as
begin
-- si le temps de travail d'une personne pour la journ�e rentr�e (en comptant le temps rentr� pour la tache en cours) est > 8h, on renvoie un message d'erreur.
if (select SUM(tt.TempsPass�) + @temps
from jo.TempsTache tt
inner join jo.Tache t on t.IDTache = tt.IDTache
where tt.DateMAJ = @dateTravail -- pour la date donn�e
	and t.Login = (select Login from jo.Tache where IDTache = @iDTache) -- pour la personne � qui est reli�e la tache
group by t.Login) > 8
	begin
	RAISERROR ( 'Menteur ! Le temps de travail par jour ne peut pas d�passer 8h.', 10, 2)
    return
	end
	
-- si pas d'erreur, on rentre les valeurs donn� dans la table
insert jo.TempsTache (IDTache, DateMAJ, Productivit�, TempsPass�) values
(@iDTache, @dateTravail, @productivit�, @temps)
end
go

---- remplissage des listes d�roulantes des fen�tres de saisie de temps
if exists (select * from sys.all_views where name = 'ListeDeroulante')
	drop view jo.ListeDeroulante
go
create view jo.ListeDeroulante as (
select l.Libell� as [Logiciel], v.IDVersion as [Version], m.Libell� as [Module],
a.Libell� as [Activit�], t.Libell� as [T�che], tt.TempsPass� as [Temps pass� en h],
tt.DateMAJ as [� la date], tp.Dur�ePr�vue as [Pr�vision initiale], tp.Dur�eRestante as [Temps restant en h]
from jo.Logiciel l
inner join jo.Version v on v.IDLogiciel = l.IDLogiciel
inner join jo.Module m on m.IDLogiciel = l.IDLogiciel
inner join jo.TacheProduction tp on tp.IDLogiciel = l.IDLogiciel
inner join jo.Activite a on a.IDActivit� = tp.IDActivite
inner join jo.Tache t on t.IDTache = tp.IDTache
inner join jo.TempsTache tt on tt.IDTache = t.IDTache
)
go


---- v�rifier si les personnes de son �quipe ont bien saisi tous leurs temps, c�est � dire 8h par jour
if exists (select * from sys.procedures where name = 'usp_VerifTempsTravail')
	drop procedure jo.usp_VerifTempsTravail
go
create procedure jo.usp_VerifTempsTravail @login nvarchar(20), @date date = getdate
as
begin
declare @temps bigint
set @temps = -- On r�cup�re le temps pass� par l'employ� donn� � la date donn�e
(select SUM(tt.TempsPass�) as [temps pass�]
from jo.TempsTache tt
inner join jo.Tache t on t.IDTache = tt.IDTache
where t.Login = @login and tt.DateMAJ = @date)

if @temps = 8
	print 'L''employ�e ' + @login + ' a bien travaill� 8h aujourd''hui.'
else
	print 'L''employ�e ' + @login + ' a travaill� ' + @temps + 'h aujourd''hui.'
end
go
---- suppression de toutes les donn�es qui sont li�es � une version d�un logiciel
if exists (select * from sys.procedures where name = 'usp_DeleteVersion')
	drop procedure jo.usp_DeleteVersion
go
create procedure jo.usp_DeleteVersion @version nvarchar(20)
as
begin
-- On doit bien supprimer dans l'ordre
-- De la table TempsTache
delete jo.TempsTache
from jo.Version v
inner join jo.Release r on r.IDVersion = v.IDVersion
inner join jo.TacheProduction tp on tp.IDVersion = v.IDVersion
inner join jo.TempsTache tt on tt.IDTache = tp.IDTache
where v.IDVersion = @version
-- De la table TacheProduction
delete jo.TacheProduction
from jo.Version v
inner join jo.Release r on r.IDVersion = v.IDVersion
inner join jo.TacheProduction tp on tp.IDVersion = v.IDVersion
where v.IDVersion = @version
-- De la table Tache
delete jo.Tache
from jo.Version v
inner join jo.Release r on r.IDVersion = v.IDVersion
inner join jo.TacheProduction tp on tp.IDVersion = v.IDVersion
inner join jo.Tache t on t.IDTache = tp.IDTache
where v.IDVersion = @version
-- De la table Release
delete jo.Release
from jo.Version v
inner join jo.Release r on r.IDVersion = v.IDVersion
where v.IDVersion = @version
-- De la table Version
delete jo.Version
from jo.Version v
where v.IDVersion = @version
end
go