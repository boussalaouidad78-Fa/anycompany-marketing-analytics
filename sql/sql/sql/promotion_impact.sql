USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- ============================================
-- ANALYSE 5 : Impact des promotions sur les ventes
-- Objectif : Comparer les ventes avec et sans
--            promotion par catégorie de produit
-- ============================================

SELECT
    p.product_category,
    p.promotion_type,
    COUNT(*)                        AS nb_promotions,
    ROUND(AVG(p.discount_percentage) * 100, 2) AS remise_moyenne_pct,
    ROUND(SUM(f.amount), 2)         AS ca_total,
    ROUND(AVG(f.amount), 2)         AS panier_moyen
FROM SILVER.PROMOTIONS_CLEAN p
LEFT JOIN SILVER.FINANCIAL_TRANSACTIONS_CLEAN f
    ON f.region = p.region
    AND f.transaction_date BETWEEN p.start_date AND p.end_date
    AND f.transaction_type = 'Sale'
GROUP BY p.product_category, p.promotion_type
ORDER BY ca_total DESC;
