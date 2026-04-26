-- ============================================
-- ÉTAPE 1 : Création de l'environnement
-- ============================================

-- 1. Créer la base de données
CREATE DATABASE IF NOT EXISTS ANYCOMPANY_LAB;

-- 2. Se positionner dessus (IMPORTANT : faire ça en premier)
USE DATABASE ANYCOMPANY_LAB;

CREATE SCHEMA IF NOT EXISTS BRONZE;
CREATE SCHEMA IF NOT EXISTS SILVER;

-- 3. Créer les deux schémas
CREATE SCHEMA IF NOT EXISTS ANYCOMPANY_LAB.BRONZE;
CREATE SCHEMA IF NOT EXISTS ANYCOMPANY_LAB.SILVER;

-- 4. Créer un entrepôt
CREATE WAREHOUSE IF NOT EXISTS ANYCOMPANY_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

    -- L'activer
USE WAREHOUSE ANYCOMPANY_WH;

-- Utilisateur IDRISS
CREATE USER IF NOT EXISTS IDRISS
    PASSWORD        = 'Snowflake2026'
    DEFAULT_ROLE    = SYSADMIN
    DEFAULT_WAREHOUSE = ANYCOMPANY_WH
    DEFAULT_NAMESPACE = ANYCOMPANY_LAB
    MUST_CHANGE_PASSWORD = FALSE;

GRANT ROLE SYSADMIN TO USER IDRISS;
-- Utilisateur KEDJA
CREATE USER IF NOT EXISTS KEDJA
    PASSWORD        = 'Snowflake2026'
    DEFAULT_ROLE    = SYSADMIN
    DEFAULT_WAREHOUSE = ANYCOMPANY_WH
    DEFAULT_NAMESPACE = ANYCOMPANY_LAB
    MUST_CHANGE_PASSWORD = FALSE;

GRANT ROLE SYSADMIN TO USER KEDJA;

-- 5. Créer le stage
CREATE STAGE IF NOT EXISTS ANYCOMPANY_LAB.BRONZE.S3_STAGE
    URL = 's3://logbrain-datalake/datasets/food-beverage/'
    FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
CREATE DATABASE IF NOT EXISTS ANYCOMPANY_LAB;

-- Vérifier les schémas
SHOW SCHEMAS IN DATABASE ANYCOMPANY_LAB;


-- Vérifier le stage
SHOW STAGES IN SCHEMA ANYCOMPANY_LAB.BRONZE;

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA BRONZE;
USE WAREHOUSE ANYCOMPANY_WH;

CREATE TABLE IF NOT EXISTS BRONZE.CUSTOMER_DEMOGRAPHICS (
    customer_id       NUMBER,
    name              VARCHAR(100),
    date_of_birth     DATE,
    gender            VARCHAR(20),
    region            VARCHAR(50),
    country           VARCHAR(50),
    city              VARCHAR(50),
    marital_status    VARCHAR(20),
    annual_income     NUMBER
);
---------------
USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA BRONZE;
USE WAREHOUSE ANYCOMPANY_WH;

-- ============================================
-- TABLE : CUSTOMER_DEMOGRAPHICS
-- Source : customer_demographics.csv
-- Description : Contient les informations démographiques
--               des clients (âge, région, revenu, etc.)
--               Utilisée pour segmenter les clients
--               et cibler les campagnes marketing
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.CUSTOMER_DEMOGRAPHICS (
    customer_id       NUMBER,        -- Identifiant unique du client
    name              VARCHAR(100),  -- Nom complet du client
    date_of_birth     DATE,          -- Date de naissance
    gender            VARCHAR(20),   -- Genre (Male, Female, Other)
    region            VARCHAR(50),   -- Région géographique (Europe, Asia...)
    country           VARCHAR(50),   -- Pays du client
    city              VARCHAR(50),   -- Ville du client
    marital_status    VARCHAR(20),   -- Situation matrimoniale
    annual_income     NUMBER         -- Revenu annuel en dollars
);

-- ============================================
-- TABLE : CUSTOMER_SERVICE_INTERACTIONS
-- Source : customer_service_interactions.csv
-- Description : Contient les interactions entre
--               les clients et le service client
--               (appels, emails, chats)
--               Utilisée pour analyser l'expérience client
--               et son impact sur les ventes
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.CUSTOMER_SERVICE_INTERACTIONS (
    interaction_id        VARCHAR(20),   -- Identifiant unique de l'interaction
    interaction_date      DATE,          -- Date de l'interaction
    interaction_type      VARCHAR(20),   -- Type : Phone, Email, Chat
    issue_category        VARCHAR(50),   -- Catégorie : Complaints, Returns...
    description           VARCHAR(500),  -- Description détaillée de l'interaction
    duration_minutes      NUMBER,        -- Durée en minutes
    resolution_status     VARCHAR(20),   -- Statut : Resolved, Pending, Escalated
    follow_up_required    VARCHAR(5),    -- Suivi nécessaire : Yes / No
    customer_satisfaction NUMBER         -- Note de satisfaction (1 à 5)
);

-- ============================================
-- TABLE : FINANCIAL_TRANSACTIONS
-- Source : financial_transactions.csv
-- Description : Contient les transactions financières
--               (ventes, remboursements, investissements)
--               Utilisée pour analyser les performances
--               commerciales et les revenus
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.FINANCIAL_TRANSACTIONS (
    transaction_id      VARCHAR(20),   -- Identifiant unique de la transaction
    transaction_date    DATE,          -- Date de la transaction
    transaction_type    VARCHAR(50),   -- Type : Sale, Refund, Investment...
    amount              NUMBER(10,2),  -- Montant de la transaction
    payment_method      VARCHAR(50),   -- Méthode : Credit Card, PayPal...
    entity              VARCHAR(100),  -- Entreprise ou entité concernée
    region              VARCHAR(50),   -- Région géographique
    account_code        VARCHAR(20)    -- Code comptable
);


-- ============================================
-- TABLE : PROMOTIONS_DATA
-- Source : promotions-data.csv
-- Description : Contient les données des promotions
--               commerciales par catégorie de produit
--               Utilisée pour analyser l'impact des
--               promotions sur les ventes
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.PROMOTIONS_DATA (
    promotion_id         VARCHAR(20),  -- Identifiant unique de la promotion
    product_category     VARCHAR(50),  -- Catégorie de produit concernée
    promotion_type       VARCHAR(50),  -- Type de promotion (ex: Beverage Bonanza)
    discount_percentage  NUMBER(5,2),  -- Pourcentage de réduction (ex: 0.15 = 15%)
    start_date           DATE,         -- Date de début de la promotion
    end_date             DATE,         -- Date de fin de la promotion
    region               VARCHAR(100)  -- Région ciblée par la promotion
);

-- ============================================
-- TABLE : MARKETING_CAMPAIGNS
-- Source : marketing_campaigns.csv
-- Description : Contient les données des campagnes
--               marketing par type et région
--               Utilisée pour analyser l'efficacité
--               des campagnes et leur ROI
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.MARKETING_CAMPAIGNS (
    campaign_id       VARCHAR(20),    -- Identifiant unique de la campagne
    campaign_name     VARCHAR(100),   -- Nom de la campagne
    campaign_type     VARCHAR(50),    -- Type : Print, Email, Content Marketing...
    product_category  VARCHAR(50),    -- Catégorie de produit ciblée
    target_audience   VARCHAR(50),    -- Audience : Families, Seniors, Professionals...
    start_date        DATE,           -- Date de début de la campagne
    end_date          DATE,           -- Date de fin de la campagne
    region            VARCHAR(100),   -- Région ciblée
    budget            NUMBER(12,2),   -- Budget alloué en dollars
    reach             NUMBER,         -- Nombre de personnes touchées
    conversion_rate   NUMBER(5,4)     -- Taux de conversion (ex: 0.0614 = 6.14%)
);


-- ============================================
-- TABLE : PRODUCT_REVIEWS
-- Source : product_reviews.csv
-- Description : Contient les avis et notes des clients
--               sur les produits
--               Utilisée pour analyser l'impact des
--               avis sur les ventes et la satisfaction
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.PRODUCT_REVIEWS (
    review_id         NUMBER,         -- Identifiant unique de l'avis
    product_id        VARCHAR(20),    -- Identifiant du produit
    reviewer_id       VARCHAR(50),    -- Identifiant du reviewer
    reviewer_name     VARCHAR(100),   -- Nom du reviewer
    rating            NUMBER,         -- Note de 1 à 5
    review_date       DATE,           -- Date de l'avis
    review_title      VARCHAR(200),   -- Titre de l'avis
    review_text       VARCHAR(1000),  -- Contenu détaillé de l'avis
    product_category  VARCHAR(100)    -- Catégorie du produit
);


-- ============================================
-- TABLE : INVENTORY
-- Source : inventory.json
-- Description : Contient les niveaux de stock
--               par produit, région et entrepôt
--               Utilisée pour analyser les ruptures
--               de stock et leur impact sur les ventes
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.INVENTORY (
    product_id        VARCHAR(20),    -- Identifiant unique du produit
    product_category  VARCHAR(50),    -- Catégorie du produit
    region            VARCHAR(100),   -- Région géographique
    country           VARCHAR(50),    -- Pays
    warehouse         VARCHAR(100),   -- Nom de l'entrepôt
    current_stock     NUMBER,         -- Niveau de stock actuel
    reorder_point     NUMBER,         -- Seuil de réapprovisionnement
    lead_time         NUMBER,         -- Délai de livraison en jours
    last_restock_date DATE            -- Date du dernier réapprovisionnement
);

-- ============================================
-- TABLE : STORE_LOCATIONS
-- Source : store_locations.json
-- Description : Contient les informations géographiques
--               des magasins (type, région, superficie)
--               Utilisée pour analyser les performances
--               des ventes par magasin et région
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.STORE_LOCATIONS (
    store_id        VARCHAR(20),    -- Identifiant unique du magasin
    store_name      VARCHAR(100),   -- Nom du magasin
    store_type      VARCHAR(50),    -- Type : Supermarket, etc.
    region          VARCHAR(50),    -- Région géographique
    country         VARCHAR(50),    -- Pays
    city            VARCHAR(50),    -- Ville
    address         VARCHAR(200),   -- Adresse complète
    postal_code     VARCHAR(20),    -- Code postal
    square_footage  NUMBER(10,2),   -- Superficie en m²
    employee_count  NUMBER          -- Nombre d'employés
);


-- ============================================
-- TABLE : LOGISTICS_AND_SHIPPING
-- Source : logistics_and_shipping.csv
-- Description : Contient les données logistiques
--               et d'expédition des commandes
--               Utilisée pour analyser les délais
--               de livraison et leur impact sur
--               la satisfaction client
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.LOGISTICS_AND_SHIPPING (
    shipment_id          VARCHAR(20),   -- Identifiant unique de l'expédition
    order_id             VARCHAR(20),   -- Identifiant de la commande
    ship_date            DATE,          -- Date d'expédition
    estimated_delivery   DATE,          -- Date de livraison estimée
    shipping_method      VARCHAR(50),   -- Méthode : Standard, Express, Next Day
    status               VARCHAR(50),   -- Statut : Delivered, Shipped, Returned...
    shipping_cost        NUMBER(10,2),  -- Coût d'expédition
    destination_region   VARCHAR(100),  -- Région de destination
    destination_country  VARCHAR(100),  -- Pays de destination
    carrier              VARCHAR(100)   -- Transporteur
);

-- ============================================
-- TABLE : SUPPLIER_INFORMATION
-- Source : supplier_information.csv
-- Description : Contient les informations sur
--               les fournisseurs par catégorie
--               de produit et région
--               Utilisée pour analyser la fiabilité
--               des fournisseurs et la qualité
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.SUPPLIER_INFORMATION (
    supplier_id       VARCHAR(20),   -- Identifiant unique du fournisseur
    supplier_name     VARCHAR(100),  -- Nom du fournisseur
    product_category  VARCHAR(50),   -- Catégorie de produit fournie
    region            VARCHAR(50),   -- Région géographique
    country           VARCHAR(50),   -- Pays du fournisseur
    city              VARCHAR(50),   -- Ville du fournisseur
    lead_time         NUMBER,        -- Délai de livraison en jours
    reliability_score NUMBER(4,2),   -- Score de fiabilité (0 à 1)
    quality_rating    VARCHAR(5)     -- Note qualité : A, B, C
);

-- ============================================
-- TABLE : EMPLOYEE_RECORDS
-- Source : employee_records.csv
-- Description : Contient les données organisationnelles
--               des employés (département, salaire, région)
--               Utilisée pour analyser la structure
--               de l'entreprise et les performances
--               par équipe
-- ============================================

CREATE TABLE IF NOT EXISTS BRONZE.EMPLOYEE_RECORDS (
    employee_id    VARCHAR(20),   -- Identifiant unique de l'employé
    name           VARCHAR(100),  -- Nom complet de l'employé
    date_of_birth  DATE,          -- Date de naissance
    hire_date      DATE,          -- Date d'embauche
    department     VARCHAR(50),   -- Département (Sales, Finance...)
    job_title      VARCHAR(100),  -- Intitulé du poste
    salary         NUMBER(12,2),  -- Salaire annuel
    region         VARCHAR(50),   -- Région géographique
    country        VARCHAR(50),   -- Pays
    email          VARCHAR(100)   -- Adresse email professionnelle
);

-- Vérifier toutes les tables créées dans BRONZE
SHOW TABLES IN SCHEMA ANYCOMPANY_LAB.BRONZE;
-------------------------------------------------


USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA BRONZE;
USE WAREHOUSE ANYCOMPANY_WH;

-- Chargement des données démographiques clients
COPY INTO BRONZE.CUSTOMER_DEMOGRAPHICS
FROM @S3_STAGE/customer_demographics.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
);

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.CUSTOMER_DEMOGRAPHICS;

-- Chargement des interactions service client
COPY INTO BRONZE.CUSTOMER_SERVICE_INTERACTIONS
FROM @S3_STAGE/customer_service_interactions.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
);

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.CUSTOMER_SERVICE_INTERACTIONS;

-- Chargement des transactions financières
COPY INTO BRONZE.FINANCIAL_TRANSACTIONS
FROM @S3_STAGE/financial_transactions.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
);

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.FINANCIAL_TRANSACTIONS;

-- Chargement des données de promotions
COPY INTO BRONZE.PROMOTIONS_DATA
FROM @S3_STAGE/promotions-data.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
);

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.PROMOTIONS_DATA;


-- Chargement des campagnes marketing
COPY INTO BRONZE.MARKETING_CAMPAIGNS
FROM @S3_STAGE/marketing_campaigns.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
);

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.MARKETING_CAMPAIGNS;

-- Chargement des avis produits (corrigé)
COPY INTO BRONZE.PRODUCT_REVIEWS
FROM @S3_STAGE/product_reviews.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.PRODUCT_REVIEWS;


-- Créer un format JSON d'abord
CREATE OR REPLACE FILE FORMAT JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE;

-- Chargement de l'inventaire (JSON)
COPY INTO BRONZE.INVENTORY
FROM (
    SELECT
        $1:product_id::VARCHAR(20),
        $1:product_category::VARCHAR(50),
        $1:region::VARCHAR(100),
        $1:country::VARCHAR(50),
        $1:warehouse::VARCHAR(100),
        $1:current_stock::NUMBER,
        $1:reorder_point::NUMBER,
        $1:lead_time::NUMBER,
        $1:last_restock_date::DATE
    FROM @S3_STAGE/inventory.json
    (FILE_FORMAT => 'JSON_FORMAT')
);

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.INVENTORY;

-- Chargement des magasins (JSON)
COPY INTO BRONZE.STORE_LOCATIONS
FROM (
    SELECT
        $1:store_id::VARCHAR(20),
        $1:store_name::VARCHAR(100),
        $1:store_type::VARCHAR(50),
        $1:region::VARCHAR(50),
        $1:country::VARCHAR(50),
        $1:city::VARCHAR(50),
        $1:address::VARCHAR(200),
        $1:postal_code::VARCHAR(20),
        $1:square_footage::NUMBER(10,2),
        $1:employee_count::NUMBER
    FROM @S3_STAGE/store_locations.json
    (FILE_FORMAT => 'JSON_FORMAT')
);

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.STORE_LOCATIONS;

-- Chargement des données logistiques
COPY INTO BRONZE.LOGISTICS_AND_SHIPPING
FROM @S3_STAGE/logistics_and_shipping.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.LOGISTICS_AND_SHIPPING;

-- Chargement des informations fournisseurs
COPY INTO BRONZE.SUPPLIER_INFORMATION
FROM @S3_STAGE/supplier_information.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
)
ON_ERROR = 'CONTINUE';

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.SUPPLIER_INFORMATION;

-- Chargement des données employés
COPY INTO BRONZE.EMPLOYEE_RECORDS
FROM @S3_STAGE/employee_records.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
)
ON_ERROR = 'CONTINUE';

-- Vérification du nombre de lignes chargées
SELECT COUNT(*) FROM BRONZE.EMPLOYEE_RECORDS;

-- Vérification globale de toutes les tables BRONZE
SELECT 'CUSTOMER_DEMOGRAPHICS' AS table_name, COUNT(*) AS nb_lignes FROM BRONZE.CUSTOMER_DEMOGRAPHICS
UNION ALL
SELECT 'CUSTOMER_SERVICE_INTERACTIONS', COUNT(*) FROM BRONZE.CUSTOMER_SERVICE_INTERACTIONS
UNION ALL
SELECT 'FINANCIAL_TRANSACTIONS', COUNT(*) FROM BRONZE.FINANCIAL_TRANSACTIONS
UNION ALL
SELECT 'PROMOTIONS_DATA', COUNT(*) FROM BRONZE.PROMOTIONS_DATA
UNION ALL
SELECT 'MARKETING_CAMPAIGNS', COUNT(*) FROM BRONZE.MARKETING_CAMPAIGNS
UNION ALL
SELECT 'PRODUCT_REVIEWS', COUNT(*) FROM BRONZE.PRODUCT_REVIEWS
UNION ALL
SELECT 'INVENTORY', COUNT(*) FROM BRONZE.INVENTORY
UNION ALL
SELECT 'STORE_LOCATIONS', COUNT(*) FROM BRONZE.STORE_LOCATIONS
UNION ALL
SELECT 'LOGISTICS_AND_SHIPPING', COUNT(*) FROM BRONZE.LOGISTICS_AND_SHIPPING
UNION ALL
SELECT 'SUPPLIER_INFORMATION', COUNT(*) FROM BRONZE.SUPPLIER_INFORMATION
UNION ALL
SELECT 'EMPLOYEE_RECORDS', COUNT(*) FROM BRONZE.EMPLOYEE_RECORDS;


USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- ============================================
-- TABLE : CUSTOMER_DEMOGRAPHICS_CLEAN
-- Source : BRONZE.CUSTOMER_DEMOGRAPHICS
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans customer_id
--   - Suppression des revenus négatifs
--   - Harmonisation des dates
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

-- Vérification
SELECT COUNT(*) FROM SILVER.CUSTOMER_DEMOGRAPHICS_CLEAN;

  -- ============================================
-- TABLE : FINANCIAL_TRANSACTIONS_CLEAN
-- Source : BRONZE.FINANCIAL_TRANSACTIONS
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans transaction_id
--   - Suppression des montants négatifs
--   - Harmonisation des dates
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

-- Vérification
SELECT COUNT(*) FROM SILVER.FINANCIAL_TRANSACTIONS_CLEAN;

-- ============================================
-- TABLE : PROMOTIONS_CLEAN
-- Source : BRONZE.PROMOTIONS_DATA
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans promotion_id
--   - Suppression des remises négatives
--   - Harmonisation des dates
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

-- Vérification
SELECT COUNT(*) FROM SILVER.PROMOTIONS_CLEAN;

-- ============================================
-- TABLE : MARKETING_CAMPAIGNS_CLEAN
-- Source : BRONZE.MARKETING_CAMPAIGNS
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans campaign_id
--   - Suppression des budgets négatifs
--   - Harmonisation des dates
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

-- Vérification
SELECT COUNT(*) FROM SILVER.MARKETING_CAMPAIGNS_CLEAN;

-- ============================================
-- TABLE : PRODUCT_REVIEWS_CLEAN
-- Source : BRONZE.PRODUCT_REVIEWS
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans review_id
--   - Suppression des notes invalides (hors 1-5)
--   - Harmonisation des dates
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

-- Vérification
SELECT COUNT(*) FROM SILVER.PRODUCT_REVIEWS_CLEAN;

-- Vérifions d'abord la table BRONZE
SELECT COUNT(*) FROM BRONZE.PRODUCT_REVIEWS;

-- Regardons un échantillon
SELECT * FROM BRONZE.PRODUCT_REVIEWS LIMIT 10;

-- On vide la table d'abord
TRUNCATE TABLE BRONZE.PRODUCT_REVIEWS;

-- Se repositionner sur BRONZE
USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA BRONZE;
USE WAREHOUSE ANYCOMPANY_WH;

-- On vide la table d'abord
TRUNCATE TABLE BRONZE.PRODUCT_REVIEWS;

-- On recharge avec plus de tolerances
COPY INTO BRONZE.PRODUCT_REVIEWS
FROM @S3_STAGE/product_reviews.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';

-- Vérification
SELECT COUNT(*) FROM BRONZE.PRODUCT_REVIEWS;

-- Echantillon
SELECT * FROM BRONZE.PRODUCT_REVIEWS LIMIT 10;
-- Vérifier les fichiers disponibles dans le stage
LIST @S3_STAGE;

-- Essayons de voir le contenu brut du fichier
SELECT $1, $2, $3, $4, $5, $6, $7, $8
FROM @S3_STAGE/product_reviews.csv
(FILE_FORMAT => (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
))
LIMIT 10;

-- Créer un format CSV spécial pour la lecture
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    NULL_IF = ('NULL', 'null', '');

-- Essayons de voir le contenu brut du fichier
SELECT $1, $2, $3, $4, $5, $6, $7, $8
FROM @S3_STAGE/product_reviews.csv
(FILE_FORMAT => 'CSV_FORMAT')
LIMIT 10;

-- Essayons de voir le contenu brut du fichier
SELECT $1, $2, $3, $4, $5, $6, $7, $8
FROM @S3_STAGE/product_reviews.csv
(FILE_FORMAT => 'CSV_FORMAT')
LIMIT 55;

-- Recharger avec ON_ERROR CONTINUE et voir ce qu'on récupère
TRUNCATE TABLE BRONZE.PRODUCT_REVIEWS;

COPY INTO BRONZE.PRODUCT_REVIEWS
FROM @S3_STAGE/product_reviews.csv
FILE_FORMAT = 'CSV_FORMAT'
ON_ERROR = 'CONTINUE';

-- Vérification
SELECT COUNT(*) FROM BRONZE.PRODUCT_REVIEWS;
SELECT * FROM BRONZE.PRODUCT_REVIEWS LIMIT 10;

-- On crée la table SILVER vide pour l'instant
USE SCHEMA SILVER;

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

SELECT COUNT(*) FROM SILVER.PRODUCT_REVIEWS_CLEAN;

-- ============================================
-- TABLE : INVENTORY_CLEAN
-- Source : BRONZE.INVENTORY
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans product_id
--   - Suppression des stocks négatifs
--   - Harmonisation des dates
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

-- Vérification
SELECT COUNT(*) FROM SILVER.INVENTORY_CLEAN;

-- ============================================
-- TABLE : STORE_LOCATIONS_CLEAN
-- Source : BRONZE.STORE_LOCATIONS
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans store_id
--   - Suppression des superficies négatives
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

-- Vérification
SELECT COUNT(*) FROM SILVER.STORE_LOCATIONS_CLEAN;

-- ============================================
-- TABLE : LOGISTICS_AND_SHIPPING_CLEAN
-- Source : BRONZE.LOGISTICS_AND_SHIPPING
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans shipment_id
--   - Suppression des coûts négatifs
--   - Harmonisation des dates
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

-- Vérification
SELECT COUNT(*) FROM SILVER.LOGISTICS_AND_SHIPPING_CLEAN;

-- ============================================
-- TABLE : SUPPLIER_INFORMATION_CLEAN
-- Source : BRONZE.SUPPLIER_INFORMATION
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans supplier_id
--   - Suppression des scores négatifs
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

-- Vérification
SELECT COUNT(*) FROM SILVER.SUPPLIER_INFORMATION_CLEAN;

-- ============================================
-- TABLE : EMPLOYEE_RECORDS_CLEAN
-- Source : BRONZE.EMPLOYEE_RECORDS
-- Nettoyage :
--   - Suppression des doublons
--   - Suppression des lignes sans employee_id
--   - Suppression des salaires négatifs
--   - Harmonisation des dates
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

-- Vérification
SELECT COUNT(*) FROM SILVER.EMPLOYEE_RECORDS_CLEAN;

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- Vérification globale de toutes les tables SILVER
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

-- Voir toutes les tables dans SILVER
SHOW TABLES IN SCHEMA ANYCOMPANY_LAB.SILVER;

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- Création de la table manquante
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

-- Vérification
SELECT COUNT(*) FROM SILVER.CUSTOMER_SERVICE_INTERACTIONS_CLEAN;

-- Vérification globale de toutes les tables SILVER
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


USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA BRONZE;

INSERT INTO BRONZE.PRODUCT_REVIEWS VALUES
(1, 'B001EO5QW8', 'A2GHZ2UTV2B0CD', 'JERRY REITH', 4, '2014-08-19', 'its oatmeal', 'What else do you need to know? Oatmeal', 'Organic Beverages'),
(2, 'B001EO5QW8', 'AQLL2R1PPR46X', 'grumpyrainbow', 3, '2013-06-12', 'decent', 'dairy-free alternative but texture could be better', 'Organic Beverages'),
(3, 'B0026Y3YBK', 'A38BUM0OXH38VK', 'singlewinder', 5, '2015-01-03', 'excellent', 'creamy and convenient works well with cereal', 'Plant-based Milk Alternatives'),
(4, 'B001IUKD76', 'A2KVCXTQVN18KI', 'A. Martin', 4, '2016-09-18', 'good product', 'fortified with essential vitamins and minerals', 'Baby Food'),
(5, 'B001ELL6O8', 'A1PTPN5SY7C7SW', 'Leonard Kocurek', 2, '2014-11-02', 'disappointed', 'expected better taste not worth the price', 'Snacks');

SHOW TABLES IN SCHEMA BRONZE

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- Supprimer l'ancienne table vide
DROP TABLE IF EXISTS SILVER.PRODUCT_REVIEWS_CLEAN;

-- Recréer avec les données insérées
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

-- Vérification
SELECT COUNT(*) FROM SILVER.PRODUCT_REVIEWS_CLEAN;

