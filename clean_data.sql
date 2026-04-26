-- ============================================
-- FICHIER : clean_data.sql
-- Description : Nettoyage des données brutes
--               et création des tables SILVER
-- Auteurs : Ouidad Boussala, Idriss Hajjaj,
--           Kedja Manzan Dominique Colombe
-- Cours : Architecture Big Data – MBAESG 2026
-- ============================================

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- ============================================
-- TABLE : CUSTOMER_DEMOGRAPHICS_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans customer_id
--   - Suppression des revenus négatifs
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.CUSTOMER_DEMOGRAPHICS_CLEAN AS
SELECT DISTINCT
    customer_id,
    TRIM(name)                          AS name,
    TRY_TO_DATE(date_of_birth::STRING)  AS date_of_birth,
    TRIM(gender)                        AS gender,
    TRIM(region)                        AS region,
    TRIM(country)                       AS country,
    TRIM(city)                          AS city,
    TRIM(marital_status)                AS marital_status,
    ABS(annual_income)                  AS annual_income
FROM BRONZE.CUSTOMER_DEMOGRAPHICS
WHERE customer_id IS NOT NULL;


-- ============================================
-- TABLE : CUSTOMER_SERVICE_INTERACTIONS_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans interaction_id
--   - Filtrage des notes de satisfaction valides (1-5)
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.CUSTOMER_SERVICE_INTERACTIONS_CLEAN AS
SELECT DISTINCT
    interaction_id,
    TRY_TO_DATE(interaction_date::STRING)   AS interaction_date,
    TRIM(interaction_type)                  AS interaction_type,
    TRIM(issue_category)                    AS issue_category,
    TRIM(description)                       AS description,
    ABS(duration_minutes)                   AS duration_minutes,
    TRIM(resolution_status)                 AS resolution_status,
    TRIM(follow_up_required)                AS follow_up_required,
    customer_satisfaction
FROM BRONZE.CUSTOMER_SERVICE_INTERACTIONS
WHERE interaction_id IS NOT NULL
  AND customer_satisfaction BETWEEN 1 AND 5;


-- ============================================
-- TABLE : FINANCIAL_TRANSACTIONS_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans transaction_id
--   - Suppression des montants négatifs
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.FINANCIAL_TRANSACTIONS_CLEAN AS
SELECT DISTINCT
    transaction_id,
    TRY_TO_DATE(transaction_date::STRING)   AS transaction_date,
    TRIM(transaction_type)                  AS transaction_type,
    ABS(amount)                             AS amount,
    TRIM(payment_method)                    AS payment_method,
    TRIM(entity)                            AS entity,
    TRIM(region)                            AS region,
    TRIM(account_code)                      AS account_code
FROM BRONZE.FINANCIAL_TRANSACTIONS
WHERE transaction_id IS NOT NULL
  AND amount IS NOT NULL
  AND amount > 0;


-- ============================================
-- TABLE : PROMOTIONS_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans promotion_id
--   - Suppression des remises négatives
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.PROMOTIONS_CLEAN AS
SELECT DISTINCT
    promotion_id,
    TRIM(product_category)                  AS product_category,
    TRIM(promotion_type)                    AS promotion_type,
    ABS(discount_percentage)                AS discount_percentage,
    TRY_TO_DATE(start_date::STRING)         AS start_date,
    TRY_TO_DATE(end_date::STRING)           AS end_date,
    TRIM(region)                            AS region
FROM BRONZE.PROMOTIONS_DATA
WHERE promotion_id IS NOT NULL
  AND discount_percentage IS NOT NULL
  AND discount_percentage > 0
  AND start_date IS NOT NULL
  AND end_date IS NOT NULL;


-- ============================================
-- TABLE : MARKETING_CAMPAIGNS_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans campaign_id
--   - Suppression des budgets négatifs
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.MARKETING_CAMPAIGNS_CLEAN AS
SELECT DISTINCT
    campaign_id,
    TRIM(campaign_name)                     AS campaign_name,
    TRIM(campaign_type)                     AS campaign_type,
    TRIM(product_category)                  AS product_category,
    TRIM(target_audience)                   AS target_audience,
    TRY_TO_DATE(start_date::STRING)         AS start_date,
    TRY_TO_DATE(end_date::STRING)           AS end_date,
    TRIM(region)                            AS region,
    ABS(budget)                             AS budget,
    ABS(reach)                              AS reach,
    ABS(conversion_rate)                    AS conversion_rate
FROM BRONZE.MARKETING_CAMPAIGNS
WHERE campaign_id IS NOT NULL
  AND budget IS NOT NULL
  AND budget > 0;


-- ============================================
-- TABLE : PRODUCT_REVIEWS_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans review_id
--   - Filtrage des notes valides (1-5)
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.PRODUCT_REVIEWS_CLEAN AS
SELECT DISTINCT
    review_id,
    TRIM(product_id)                        AS product_id,
    TRIM(reviewer_id)                       AS reviewer_id,
    TRIM(reviewer_name)                     AS reviewer_name,
    rating,
    TRY_TO_DATE(review_date::STRING)        AS review_date,
    TRIM(review_title)                      AS review_title,
    TRIM(review_text)                       AS review_text,
    TRIM(product_category)                  AS product_category
FROM BRONZE.PRODUCT_REVIEWS
WHERE review_id IS NOT NULL
  AND rating BETWEEN 1 AND 5
  AND product_id IS NOT NULL;


-- ============================================
-- TABLE : INVENTORY_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans product_id
--   - Suppression des stocks négatifs
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.INVENTORY_CLEAN AS
SELECT DISTINCT
    TRIM(product_id)                        AS product_id,
    TRIM(product_category)                  AS product_category,
    TRIM(region)                            AS region,
    TRIM(country)                           AS country,
    TRIM(warehouse)                         AS warehouse,
    ABS(current_stock)                      AS current_stock,
    ABS(reorder_point)                      AS reorder_point,
    ABS(lead_time)                          AS lead_time,
    TRY_TO_DATE(last_restock_date::STRING)  AS last_restock_date
FROM BRONZE.INVENTORY
WHERE product_id IS NOT NULL
  AND current_stock IS NOT NULL;


-- ============================================
-- TABLE : STORE_LOCATIONS_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans store_id
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.STORE_LOCATIONS_CLEAN AS
SELECT DISTINCT
    TRIM(store_id)                          AS store_id,
    TRIM(store_name)                        AS store_name,
    TRIM(store_type)                        AS store_type,
    TRIM(region)                            AS region,
    TRIM(country)                           AS country,
    TRIM(city)                              AS city,
    TRIM(address)                           AS address,
    TRIM(postal_code)                       AS postal_code,
    ABS(square_footage)                     AS square_footage,
    ABS(employee_count)                     AS employee_count
FROM BRONZE.STORE_LOCATIONS
WHERE store_id IS NOT NULL;


-- ============================================
-- TABLE : LOGISTICS_AND_SHIPPING_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans shipment_id
--   - Suppression des coûts négatifs
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.LOGISTICS_AND_SHIPPING_CLEAN AS
SELECT DISTINCT
    TRIM(shipment_id)                       AS shipment_id,
    TRIM(order_id)                          AS order_id,
    TRY_TO_DATE(ship_date::STRING)          AS ship_date,
    TRY_TO_DATE(estimated_delivery::STRING) AS estimated_delivery,
    TRIM(shipping_method)                   AS shipping_method,
    TRIM(status)                            AS status,
    ABS(shipping_cost)                      AS shipping_cost,
    TRIM(destination_region)               AS destination_region,
    TRIM(destination_country)              AS destination_country,
    TRIM(carrier)                           AS carrier
FROM BRONZE.LOGISTICS_AND_SHIPPING
WHERE shipment_id IS NOT NULL
  AND shipping_cost IS NOT NULL
  AND shipping_cost > 0;


-- ============================================
-- TABLE : SUPPLIER_INFORMATION_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans supplier_id
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.SUPPLIER_INFORMATION_CLEAN AS
SELECT DISTINCT
    TRIM(supplier_id)                       AS supplier_id,
    TRIM(supplier_name)                     AS supplier_name,
    TRIM(product_category)                  AS product_category,
    TRIM(region)                            AS region,
    TRIM(country)                           AS country,
    TRIM(city)                              AS city,
    ABS(lead_time)                          AS lead_time,
    ABS(reliability_score)                  AS reliability_score,
    TRIM(quality_rating)                    AS quality_rating
FROM BRONZE.SUPPLIER_INFORMATION
WHERE supplier_id IS NOT NULL
  AND reliability_score IS NOT NULL
  AND reliability_score > 0;


-- ============================================
-- TABLE : EMPLOYEE_RECORDS_CLEAN
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans employee_id
--   - Suppression des salaires négatifs
-- ============================================

CREATE TABLE IF NOT EXISTS SILVER.EMPLOYEE_RECORDS_CLEAN AS
SELECT DISTINCT
    TRIM(employee_id)                       AS employee_id,
    TRIM(name)                              AS name,
    TRY_TO_DATE(date_of_birth::STRING)      AS date_of_birth,
    TRY_TO_DATE(hire_date::STRING)          AS hire_date,
    TRIM(department)                        AS department,
    TRIM(job_title)                         AS job_title,
    ABS(salary)                             AS salary,
    TRIM(region)                            AS region,
    TRIM(country)                           AS country,
    TRIM(email)                             AS email
FROM BRONZE.EMPLOYEE_RECORDS
WHERE employee_id IS NOT NULL
  AND salary IS NOT NULL
  AND salary > 0;


-- ============================================
-- VERIFICATION GLOBALE
-- ============================================

SELECT 'CUSTOMER_DEMOGRAPHICS_CLEAN' AS table_name, COUNT(*) AS nb_lignes FROM SILVER.CUSTOMER_DEMOGRAPHICS_CLEAN
UNION ALL
SELECT 'CUSTOMER_SERVICE_INTERACTIONS_CLEAN', COUNT(*) FROM SILVER.CUSTOMER_SERVICE_INTERACTIONS_CLEAN
UNION ALL
SELECT 'FINANCIAL_TRANSACTIONS_CLEAN', COUNT(*) FROM SILVER.FINANCIAL_TRANSACTIONS_CLEAN
UNION ALL
SELECT 'PROMOTIONS_CLEAN', COUNT(*) FROM SILVER.PROMOTIONS_CLEAN
UNION ALL
SELECT 'MARKETING_CAMPAIGNS_CLEAN', COUNT(*) FROM SILVER.MARKETING_CAMPAIGNS_CLEAN
UNION ALL
SELECT 'PRODUCT_REVIEWS_CLEAN', COUNT(*) FROM SILVER.PRODUCT_REVIEWS_CLEAN
UNION ALL
SELECT 'INVENTORY_CLEAN', COUNT(*) FROM SILVER.INVENTORY_CLEAN
UNION ALL
SELECT 'STORE_LOCATIONS_CLEAN', COUNT(*) FROM SILVER.STORE_LOCATIONS_CLEAN
UNION ALL
SELECT 'LOGISTICS_AND_SHIPPING_CLEAN', COUNT(*) FROM SILVER.LOGISTICS_AND_SHIPPING_CLEAN
UNION ALL
SELECT 'SUPPLIER_INFORMATION_CLEAN', COUNT(*) FROM SILVER.SUPPLIER_INFORMATION_CLEAN
UNION ALL
SELECT 'EMPLOYEE_RECORDS_CLEAN', COUNT(*) FROM SILVER.EMPLOYEE_RECORDS_CLEAN;
