/**********************************************************************************/
/* 1 - Import des données */
/***********************************************************************************/

/* Importer la base de données data.csv*/
proc import datafile='/home/pierre/Documents/School/Projet SAS/data.csv'
	out=data dbms=CSV replace;
	delimiter=",";
	getnames=yes;
  guessingrows=10000;
run;

/* Pensez à bien vérifier le format de vos champs !!!*/
/* Pensez à regarder si des erreurs de saisie / valeurs aberrantes sont présentes*/

/***********************************************************************************/
/* 2 - Caractéristiques des joueurs  */
/***********************************************************************************/

/* 0 - Créer une table "combattant" à partir de la table importée et calculer pour chaque combattant : */

/* Taille*/ 
/* Poids */
/* Porté de bras*/
/* Age*/
/* position du combattant (Stance)*/

data R_combattant;
    set data;
    keep R_fighter R_Weight_lbs R_Height_cms R_Height_cms R_Reach_cms R_age R_Stance; 
    rename R_fighter= Fighter R_Height_cms=Height R_Reach_cms=Reach R_age=Age R_Stance=Stance R_Weight_lbs= Weight;
run;

data B_combattant;
    set data;
    keep B_fighter B_Weight_lbs B_Height_cms B_Reach_cms B_age B_Stance; 
    rename B_fighter= Fighter B_Height_cms=Height B_Reach_cms=Reach B_age=Age B_Stance=Stance B_Weight_lbs= Weight;
run;

data Combattant;
set R_combattant B_combattant;
run;

proc sql;
create table Combattant as SELECT DISTINCT Fighter, AVG(Height) AS Height, AVG(Reach) AS Reach, AVG(Weight) as Weight,MAX(Age) as Age, Stance, count(*) as count
                            FROM Combattant
                            GROUP BY Fighter;
RUN;QUIT;


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

/*Un combattant qui est grand a-t-il forcément une plus longue portée de bras (Reach_cms) ?*/

PROC CORR data=Combattant;
  VAR Reach Height;
run;

PROC REG data=Combattant OUTEST=LinearModel_Combattant;
  MODEL Reach = height;
  PLOT Reach*height ;
run;


/* 3 - Mettre en classe les 4 variables numériques créées à l'étape précédente*/

PROC freq data=Combattant;
  TABLE Weight;
run;

data Combattant_classes;
  set Combattant;
  
  if  Height <= 175 then  Height_class='small';
  if  Height > 170 and Height <= 180 then  Height_class='medium_inf';
  if  Height > 180 and Height <= 185 then  Height_class='medium_sup';
  if  Height > 185 then  Height_class='tall';
  
  if age <= 26 then  age_class='young';
  if age > 26 and age <= 30 then  age_class='medium_inf';
  if age > 30 and age <= 33 then  age_class='medium_sup';
  if age > 33 then  age_class='old';

  if  Reach <= 172 then  Reach_class='small';
  if  Reach > 172 and Reach <= 180 then  Reach_class='medium_inf';
  if  Reach > 180 and Reach <= 187 then  Reach_class='medium_sup';
  if  Reach > 187 then  Reach_class='tall';

  if Weight in  (0:125) then Weight_class='Poids_mouches';
  if Weight in  (125:135) then Weight_class='Poids_coqs';
  if Weight in  (135:145) then Weight_class='Poids_plumes';
  if Weight in  (145:155) then Weight_class='Poids_légers';
  if Weight in  (155:170) then Weight_class='Poids_mi-moyens';
  if Weight in  (170:185) then Weight_class=' Poids_moyens';
  if Weight in  (185:205) then Weight_class='Poids_lourds-légers';
  if Weight in  (205:265) then Weight_class='Poids_lourds';
run;

proc univariate data=Combattant;
  class Height; 
   histogram Height / maxnbin=4;
run;

histogram Reach / maxnbin=4;
/* 4 - Faites des tableaux croisées dynamiques / graphiques / test de corrélation / ACP / ACM entre ces 4 variables */
proc freq data=Combattant_classes;
tables Height_class*Reach_class;
tables Height_class*Weight_class;
run;

/*
OUT= Recup les coordonees par individus 
OUTSTAT=Recup les coordonees par variables
*/
proc princomp DATA=Combattant OUT=coordon OUTSTAT=statis N=5 prefix=axe;
  var Height Reach Weight Age;
run;

PROC GPLOT DATA=coordon;
  plot axe1*axe3;
run;


proc corresp data=Combattant_classes outc=coordonnees_MCA outf=coordonnees_var_MCA /*noprint*/ mca;
tables Weight_class Height_class Reach_class age_class Stance;
run;
/* Interprétez les résultats. Que pouvez-vous en conclure ? */


/***********************************************************************************/
/* 3 - Analyse des performances  */
/***********************************************************************************/

/* 1 - Nous allons maintenant calculer les performances sportives par combattant. Pour chacun d'eux, calculer les indicateurs suivants : */
/* Nombre de combat total*/

proc sql;
create table data_combattant as SELECT R_Fighter, B_Fighter, winner, title_bout,  R_HEAD
run; QUIT;

data nb_Combattant;
  set R_combattant B_combattant;
  rename R_Fighter=Fighter B_Fighter=Fighter;
run;

proc sql;
create table Nombre_Match as SELECT Fighter, count(Fighter) as count
                            FROM nb_Combattant
                            GROUP BY Fighter;
RUN;QUIT;
 
   /*****************************/
  /* Nombre de titres remportés*/
 /*****************************/
/*On met en place les 2 tables utiles pour le calcul*/
data R_combattant;
    set data;
    keep R_fighter Winner date title_bout; 
    rename R_fighter = Fighter;
run;

data B_combattant;
  set data;
  keep B_fighter Winner date title_bout;
  rename B_fighter = Fighter;
run; 

/* on crée une variable indiquant si le combat est une victoire coté rouge pour le titre */
data R_combattant;
	set R_combattant;
	if title_bout = "True" and winner = "Red" then WinTitle = 1;
	else WinTitle = 0;
run; 

/* on crée une variable indiquant si le combat est une victoire coté bleu pour le titre */
data B_combattant;
	set B_combattant;
	if title_bout = "True" and winner = "Blue" then WinTitle = 1;
	else WinTitle = 0;
run; 

data Combattant;
set R_combattant B_combattant;
run;

proc sql;
  CREATE table count_titre as SELECT Fighter, sum(WinTitle) as Counter
                              FROM Combattant
                              GROUP BY Fighter;
QUIT;

proc sort data = count_titre ;
by  descending Counter;
run;


  /******************************/
 /* Pourcentage de combat gagné*/
/******************************/

data R_combattant;
    set data;
    keep R_fighter Winner date title_bout; 
    rename R_fighter = Fighter;
run;

data B_combattant;
  set data;
  keep B_fighter Winner date title_bout;
  rename B_fighter = Fighter;
run;

/* on crée une variable indiquant si le combat est une victoire coté rouge */
data R_combattant;
	set R_combattant;
	if winner = "Red" then Win = 1;
	else Win = 0;
run; 

/* on crée une variable indiquant si le combat est une victoire coté bleu */
data B_combattant;
	set B_combattant;
	if winner = "Blue" then Win = 1;
	else Win = 0;
run;





  /**************************************/
 /* Pourcentage de combat gagné par KO */
/**************************************/  
  


  /*****************************/
 /* Nombre de titres remportés*/
/*****************************/ 
/* Nombre de frappes tentée au global*/
/* Nombre de frappes tentée à la tête*/
/* Nombre de frappes atterrie à la tête*/
/* Nombre de frappes tentée aux corps*/
/* Nombre de frappes atterrie aux corps*/

R_HEAD est nombre de frappe à la tête ayant atterri
BODY est est nombre de frappe au corps ayant atterri
CLINCH est est nombre de frappe au corps à corps ayant atterri
GROUND


/* 2 - Mettez tous ces résultats dans un seul et même dataframe appeler "Stat_Global" */

/* 3 - Effectuer une ACP sur les combattants et leurs statistiques*/
/* Interprétez les résultats. Que pouvez-vous en conclure ?  */


