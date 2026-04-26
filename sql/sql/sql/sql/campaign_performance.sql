-- ============================================
-- FICHIER : campaign_performance.sql
-- Description : Analyse des performances des
--               campagnes marketing, logistique
--               et gestion des stocks
-- Auteurs : Ouidad Boussala, Idriss Hajjaj,
--           Kedja Manzan Dominique Colombe
-- Cours : Architecture Big Data – MBAESG 2026
-- ============================================

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- ============================================
-- ANALYSE 6 : Performance des campagnes marketing
-- ============================================

SELECT
    campaign_type,
    product_category,
    COUNT(*)                                AS nb_campagnes,
    ROUND(SUM(budget), 2)                   AS budget_total,
    ROUND(AVG(budget), 2)                   AS budget_moyen,
    ROUND(AVG(conversion_rate) * 100, 2)    AS taux_conversion_moyen,
    ROUND(SUM(reach), 0)                    AS audience_totale
FROM SILVER.MARKETING_CAMPAIGNS_CLEAN
GROUP BY campaign_type, product_category
ORDER BY taux_conversion_moyen DESC;

-- ============================================
-- ANALYSE 7 : ROI des campagnes marketing
-- ============================================

SELECT
    campaign_name,
    campaign_type,
    region,
    ROUND(budget, 2)                        AS budget,
    reach,
    ROUND(conversion_rate * 100, 2)         AS taux_conversion_pct,
    ROUND(reach * conversion_rate, 0)       AS nb_conversions_estimees,
    ROUND(budget / NULLIF(reach, 0), 2)     AS cout_par_personne
FROM SILVER.MARKETING_CAMPAIGNS_CLEAN
ORDER BY taux_conversion_pct DESC
LIMIT 20;

-- ============================================
-- ANALYSE 8 : Impact des délais de livraison
-- ============================================

SELECT
    shipping_method,
    status,
    COUNT(*)                                AS nb_livraisons,
    ROUND(AVG(shipping_cost), 2)            AS cout_moyen,
    ROUND(AVG(DATEDIFF('day',
        ship_date,
        estimated_delivery)), 1)            AS delai_moyen_jours
FROM SILVER.LOGISTICS_AND_SHIPPING_CLEAN
GROUP BY shipping_method, status
ORDER BY shipping_method, nb_livraisons DESC;

-- ============================================
-- ANALYSE 9 : Analyse des ruptures de stock
-- ============================================

SELECT
    product_category,
    region,
    COUNT(*)                                AS nb_produits,
    ROUND(AVG(current_stock), 0)            AS stock_moyen,
    ROUND(AVG(reorder_point), 0)            AS seuil_reappro_moyen,
    SUM(CASE WHEN current_stock <= reorder_point
        THEN 1 ELSE 0 END)                  AS nb_ruptures,
    ROUND(AVG(lead_time), 1)                AS delai_reappro_moyen
FROM SILVER.INVENTORY_CLEAN
GROUP BY product_category, region
ORDER BY nb_ruptures DESC
LIMIT 20;
