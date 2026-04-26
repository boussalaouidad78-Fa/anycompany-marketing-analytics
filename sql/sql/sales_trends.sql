USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- ============================================
-- ANALYSE 1 : Evolution des ventes par année
-- Objectif : Identifier les tendances des ventes
--            et les périodes les plus performantes
-- ============================================

SELECT
    YEAR(transaction_date)          AS annee,
    COUNT(*)                        AS nb_transactions,
    ROUND(SUM(amount), 2)           AS chiffre_affaires,
    ROUND(AVG(amount), 2)           AS panier_moyen,
    ROUND(MIN(amount), 2)           AS vente_min,
    ROUND(MAX(amount), 2)           AS vente_max
FROM SILVER.FINANCIAL_TRANSACTIONS_CLEAN
WHERE transaction_type = 'Sale'
GROUP BY YEAR(transaction_date)
ORDER BY annee;

-- ============================================
-- ANALYSE 2 : Performance des ventes par région
-- Objectif : Identifier les régions les plus
--            performantes commercialement
-- ============================================

SELECT
    region,
    COUNT(*)                        AS nb_transactions,
    ROUND(SUM(amount), 2)           AS chiffre_affaires,
    ROUND(AVG(amount), 2)           AS panier_moyen
FROM SILVER.FINANCIAL_TRANSACTIONS_CLEAN
WHERE transaction_type = 'Sale'
GROUP BY region
ORDER BY chiffre_affaires DESC;


-- ============================================
-- ANALYSE 3 : Répartition des clients par région
-- Objectif : Comprendre la distribution
--            géographique des clients
-- ============================================

SELECT
    region,
    gender,
    COUNT(*)                        AS nb_clients,
    ROUND(AVG(annual_income), 2)    AS revenu_moyen
FROM SILVER.CUSTOMER_DEMOGRAPHICS_CLEAN
GROUP BY region, gender
ORDER BY nb_clients DESC;

-- ============================================
-- ANALYSE 4 : Segmentation des clients par revenu
-- Objectif : Identifier les segments de clients
--            à fort potentiel pour le marketing
-- ============================================

SELECT
    CASE
        WHEN annual_income < 50000  THEN '1 - Faible (< 50K)'
        WHEN annual_income < 100000 THEN '2 - Moyen (50K - 100K)'
        WHEN annual_income < 150000 THEN '3 - Elevé (100K - 150K)'
        ELSE                             '4 - Très élevé (> 150K)'
    END                             AS segment_revenu,
    COUNT(*)                        AS nb_clients,
    ROUND(AVG(annual_income), 2)    AS revenu_moyen,
    region
FROM SILVER.CUSTOMER_DEMOGRAPHICS_CLEAN
GROUP BY segment_revenu, region
ORDER BY segment_revenu, nb_clients DESC;
