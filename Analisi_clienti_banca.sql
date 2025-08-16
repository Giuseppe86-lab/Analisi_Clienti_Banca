SELECT * FROM banca.cliente LIMIT 5;
SELECT * FROM banca.conto LIMIT 5;
SELECT * FROM banca.tipo_conto LIMIT 5;
SELECT * FROM banca.tipo_transazione LIMIT 5;
SELECT * FROM banca.transazioni LIMIT 5;

-- 1: INDICATORI DI BASE
CREATE TEMPORARY TABLE clienti_base AS
SELECT 
	id_cliente,
    TIMESTAMPDIFF(YEAR, data_nascita, CURDATE()) AS eta
FROM banca.cliente;

-- 2: INDICATORI DI TRANSAZIONE
/*CREAZIONE TABELLA INDICATORI_TRANSAZIONI PER:
	1 - Numero di transazioni in uscita su tutti i conti
    2 - Numero di transazioni in entrata su tutti i conti
    3 - Importo totale transato in uscita su tutti i conti
    4 - Importo totale transato in entrata su tutti i conti
*/

CREATE TEMPORARY TABLE indicatori_transazioni AS
SELECT
	c.id_cliente,
    COUNT(CASE WHEN tt.segno = '+' THEN 1 END) AS numero_transazioni_entrata,
    COUNT(CASE WHEN tt.segno = '-' THEN 1 END) AS numero_transazioni_uscita,
    SUM(CASE WHEN tt.segno = '+' THEN t.importo END) AS importo_transazioni_entrata,
    SUM(CASE WHEN tt.segno = '-' THEN t.importo END) AS importo_transazioni_uscita
FROM banca.cliente c
LEFT JOIN banca.conto co ON c.id_cliente = co.id_cliente
LEFT JOIN banca.transazioni t ON co.id_conto = t.id_conto
LEFT JOIN banca.tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
GROUP BY c.id_cliente;

SELECT * FROM indicatori_transazioni;

-- 3: INDICATORI SUI CONTI
/* CREAZIONE TABELLA PER:
	1 - Numero totale di conti posseduti
    2 - Numero di conti posseduti per tipologia (un indicatore per ogni tipo di conto)
*/

CREATE TEMPORARY TABLE numero_conti AS
SELECT
	c.id_cliente,
    COUNT(DISTINCT id_conto) as numero_totale_conti,
    COUNT(CASE WHEN co.id_tipo_conto = 0 THEN 1 END) count_conto_base,
	COUNT(CASE WHEN co.id_tipo_conto = 1 THEN 1 END) count_conto_business,
	COUNT(CASE WHEN co.id_tipo_conto = 2 THEN 1 END) count_conto_privati,
	COUNT(CASE WHEN co.id_tipo_conto = 3 THEN 1 END) count_conto_famiglie
FROM banca.cliente c
LEFT JOIN banca.conto co ON c.id_cliente = co.id_cliente
LEFT JOIN banca.tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
GROUP BY c.id_cliente;

SELECT * FROM numero_conti;

-- 4: INDICATORI SULLE TRANSAZIONI PER TIPOLOGIA DI CONTO
/* CREAZIONE TABELLA PER:
	1 - Numero di transazioni in uscita per tipologia di conto
    2 - Numero di transazioni in entrata per tipologia di conto
    3 - Importo transato in uscita per tipologia di conto
    4 - Importo transato in entrata per tipologia di conto
*/

CREATE TEMPORARY TABLE transazioni_per_conto AS
SELECT
	c.id_cliente,
    COUNT(CASE WHEN co.id_tipo_conto = 0 AND tt.segno = '-' THEN 1 END) num_usc_c_base,
    COUNT(CASE WHEN co.id_tipo_conto = 1 AND tt.segno = '-' THEN 1 END) num_usc_c_business,
    COUNT(CASE WHEN co.id_tipo_conto = 2 AND tt.segno = '-' THEN 1 END) num_usc_c_privati,
    COUNT(CASE WHEN co.id_tipo_conto = 3 AND tt.segno = '-' THEN 1 END) num_usc_c_famiglie,
    COUNT(CASE WHEN co.id_tipo_conto = 0 AND tt.segno = '+' THEN 1 END) num_ent_c_base,
    COUNT(CASE WHEN co.id_tipo_conto = 1 AND tt.segno = '+' THEN 1 END) num_ent_c_business,
    COUNT(CASE WHEN co.id_tipo_conto = 2 AND tt.segno = '+' THEN 1 END) num_ent_c_privati,
    COUNT(CASE WHEN co.id_tipo_conto = 3 AND tt.segno = '+' THEN 1 END) num_ent_c_famiglie,
    SUM(CASE WHEN co.id_tipo_conto = 0 AND tt.segno = '-' THEN t.importo END) imp_usc_c_base,
    SUM(CASE WHEN co.id_tipo_conto = 1 AND tt.segno = '-' THEN t.importo END) imp_usc_c_business,
    SUM(CASE WHEN co.id_tipo_conto = 2 AND tt.segno = '-' THEN t.importo END) imp_usc_c_privati,
    SUM(CASE WHEN co.id_tipo_conto = 3 AND tt.segno = '-' THEN t.importo END) imp_usc_c_famiglie,
    SUM(CASE WHEN co.id_tipo_conto = 0 AND tt.segno = '+' THEN t.importo END) imp_ent_c_base,
    SUM(CASE WHEN co.id_tipo_conto = 1 AND tt.segno = '+' THEN t.importo END) imp_ent_c_business,
    SUM(CASE WHEN co.id_tipo_conto = 2 AND tt.segno = '+' THEN t.importo END) imp_ent_c_privati,
    SUM(CASE WHEN co.id_tipo_conto = 3 AND tt.segno = '+' THEN t.importo END) imp_ent_c_famiglie
    
FROM banca.cliente c
LEFT JOIN banca.conto co ON c.id_cliente = co.id_cliente
LEFT JOIN banca.transazioni t ON co.id_conto = t.id_conto
LEFT JOIN banca.tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
GROUP BY c.id_cliente;

SELECT * FROM transazioni_per_conto;

-- 5: AGGREGAZIONE DELLE TABELLE INTERMEDIE PRODOTTE: 
/*
	A: clienti_base
    B: indicatori_transazioni
    C: numero_conti
    D: transazioni_per_conto
*/

CREATE TABLE analisi_clienti_banca AS
SELECT
-- colonne dalla tabella clienti_base
	cb.id_cliente,
    cb.eta,
 -- colonne dalla tabella indicatori_transazioni   
	it.numero_transazioni_entrata,
    it.numero_transazioni_uscita,
    it.importo_transazioni_entrata,
    it.importo_transazioni_uscita,
 -- colonne dalla tabella numero_conti   
    nc.numero_totale_conti,
    nc.count_conto_base,
    nc.count_conto_business,
    nc.count_conto_privati,
    nc.count_conto_famiglie,
 -- colonne dalla tabella transazioni_per_conto   
    tc.num_usc_c_base,
    tc.num_usc_c_business,
    tc.num_usc_c_privati,
    tc.num_usc_c_famiglie,
    tc.num_ent_c_base,
    tc.num_ent_c_business,
    tc.num_ent_c_privati,
    tc.num_ent_c_famiglie,
    tc.imp_usc_c_base,
    tc.imp_usc_c_business,
    tc.imp_usc_c_privati,
    tc.imp_usc_c_famiglie,
    tc.imp_ent_c_base,
    tc.imp_ent_c_business,
    tc.imp_ent_c_privati,
    tc.imp_ent_c_famiglie
    
FROM banca.clienti_base cb
LEFT JOIN banca.indicatori_transazioni it ON cb.id_cliente = it.id_cliente
LEFT JOIN banca.numero_conti nc ON cb.id_cliente = nc.id_cliente
LEFT JOIN banca.transazioni_per_conto tc ON cb.id_cliente = tc.id_cliente;

SELECT * FROM analisi_clienti_banca;
