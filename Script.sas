/**********************************************************************************/
/* 1 - Import des données */
/***********************************************************************************/

/* Importer la base de données data.csv*/
proc import datafile='/home/lepagnol_p/Projet SAS-20191114/data.csv'
	out=data dbms=CSV replace;
	delimiter=",";
	getnames=yes;
run;

/* Pensez à bien vérifier le format de vos champs !!!*/
/* Pensez à regarder si des erreurs de saisie / valeurs aberrantes sont présentes*/

/***********************************************************************************/
/* 2 - Caractéristiques des joueurs  */
/***********************************************************************************/

/* 1 - Répondez aux questions suivantes à l'aide de graphique ou de test statistique : */
/* La répartition entre les matchs pour le titre et les autres matchs (colonne "title_bout") est-elle égale ? */
proc freq data=data;
 table title_bout;
run;

/* La répartition des gagnants entre les bleus et les rouges ? 
   Existe-t-il un effet du camp sur le nombre de victoire ? */

proc freq data=data;
 table winner;
run;

/*Un combattant qui est grand a-t-il
  forcément une plus longue portée de bras (Reach_cms) ?*/
PROC CORR data=Combattant;
  VAR Reach Height;
run;

PROC REG data=Combattant OUTEST=LinearModel_Combattant;
  MODEL Reach = height;
  PLOT Reach*height ;
run;
/* 2 - Créer une table "combattant" à partir de la table importée
        et calculer pour chaque combattant : */

/* Taille*/ 
/* Poids */
/* Porté de bras*/
/* Age*/
/* position du combattant (Stance)*/

data R_combattant;
    set data;
    keep R_fighter R_Height_cms R_Reach_cms R_age R_Stance; 
    rename R_fighter= Fighter R_Height_cms=Height R_Reach_cms=Reach R_age=Age R_Stance=Stance;
run;

data B_combattant;
    set data;
    keep B_fighter B_Height_cms B_Reach_cms B_age B_Stance; 
    rename B_fighter= Fighter B_Height_cms=Height B_Reach_cms=Reach B_age=Age B_Stance=Stance;
run;

data Combattant;
set R_combattant B_combattant;
run;

proc sql;
create table Combattant as SELECT Distinct Fighter, AVG(Height) AS Height, AVG(Reach) AS Reach,MAX(Age) as Age, Stance, count(*) as count
                            FROM Combattant
                            GROUP BY Fighter;
RUN;QUIT;


/* 3 - Mettre en classe les 4 variables numériques créées à l'étape précédente*/

PROC freq data=Combattant;
  TABLE Height Reach;
run;
proc univariate data=Combattant;
  class Height; 
   histogram Height / maxnbin=4;
run;
histogram Reach / maxnbin=4;
/* 4 - Faites des tableaux croisées dynamiques / graphiques / test de corrélation / ACP / ACM entre ces 4 variables */

/* Interprétez les résultats. Que pouvez-vous en conclure ? */


/***********************************************************************************/
/* 3 - Analyse des performances  */
/***********************************************************************************/

/* 1 - Nous allons maintenant calculer les performances sportives par combattant. Pour chacun d'eux, calculer les indicateurs suivants : */
/* Nombre de combat total*/
/* Pourcentage de combat gagné*/
/* Pourcentage de combat gagné par KO */
/* Nombre de titres remportés*/
/* Nombre de frappes tentée au global*/
/* Nombre de frappes tentée à la tête*/
/* Nombre de frappes atterrie à la tête*/
/* Nombre de frappes tentée aux corps*/
/* Nombre de frappes atterrie aux corps*/

/* 2 - Mettez tous ces résultats dans un seul et même dataframe appeler "Stat_Global" */

/* 3 - Effectuer une ACP sur les combattants et leurs statistiques*/
/* Interprétez les résultats. Que pouvez-vous en conclure ?  */
