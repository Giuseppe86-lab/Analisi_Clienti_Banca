# Analisi_Clienti_Banca
This repository is the ninth project of my master in Data Science

L'argomento centrale del modulo a cui appartiene questo progetto è stato SQL, quindi una panoramica sui tipi di database che possono essere incontrati in ambito lavorativo, con approfondimento specifico per quelli relazionali con studio della sintassi di MySQL. Sono stati presentati gli strumenti principali per creare delle query dalle più semplici alle più complesse. Sono state trattate le operazioni sulle stringhe, i filtri, l'aggregazione dei dati, i vari tipi di join, le subquery e come creare viste, tabelle e database.

L'obiettivo di questo progetto è creare una tabella denormalizzata, da poter usare in progetti di machine learning, con feature derivanti dalle tabelle disponibili nel database, che rappresentano i comportamenti e le attività finanziare dei clienti.

Il database è formato da cinque tabelle: Cliente, Conto, Tipo_conto, Tipo_transazione, Transazioni.

Questo progetto mi ha permesso di fare esperienza sull'utilizzo del linguaggio SQL, in particolare nello sviluppo del compito assegnato ho usato: la left join per poter sempre fare riferimento all'id cliente definito nella medesima tabella, e riportato nelle tabelle riferite ai clienti. Per poter gestire le molteplici richieste ho costruito delle tabelle temporanee che ho successivamente unito per creare la tabella denormalizzata finale. Le colonne richieste necessitavano non solo di definire delle aggregazioni ma di utilizzare anche dei filtri, in modo tale da poter determinare quantità totali sotto certe condizioni. 

Linguaggio di programmazione: SQL
