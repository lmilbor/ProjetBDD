PROJET BDD

1/ LE SI JobOverview
Fichiers fournis :
- L'ensemble des vues en pdf Data Modeler,
- Le JOBDD.dmb et le zip contenant le reste de fichiers Data Modeler,
- La sauvegarde de la base de donn�es JobOverview.

Les scripts � executer dans l'ordre suivant pour avoir une base :
- Le script ProcedureEtFonctionJO.sql (qui ne contient pas de fonction mais une vue et des procedures d'ailleurs) � lancer en premier,
- Le script Cr�ationBaseJO.sql pour cr�er la base de donn�es � lancer en deuxi�me.

Pour remplir la base :
- Le script InsertionValeurJO.sql � lancer pour remplir quelques tables (n�cessaire pour lancer des tests).

Pour faire diff�rentes requ�tes de test :
- Le script ScriptTestJO.sql pour tester diff�rentes requ�tes.

2/ Requ�tage sur la bas Grand-H�tel
Fichiers fournis :
- Le script Grand-Hotel.sql ou on trouve les solutions trouv�es au requ�tes demand�,
- La base de donn�es GrandHotel.bak a priori non modifi� (les requ�tes de modification �tant pr�c�d�es d'un "begin tran" et suivis d'un "rollback").