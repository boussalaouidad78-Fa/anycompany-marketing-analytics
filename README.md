AnyCompany Food & Beverage – Data-Driven Marketing Analytics
Contexte
AnyCompany Food & Beverage est un fabricant de produits alimentaires et de boissons présent sur le marché depuis plus de 25 ans.
En 2025, l'entreprise fait face à :

Une baisse des ventes sans précédent
Une réduction de 30% de son budget marketing
Une perte de part de marché : de 28% à 22% en seulement 8 mois

Objectif : Atteindre 32% de part de marché d'ici le T4 2025 grâce au marketing data-driven.

Architecture
Données Sources (Amazon S3)
        ↓
   BRONZE (données brutes)
        ↓
   SILVER (données nettoyées)
        ↓
  ANALYTICS (data product)

Structure du projet
project/
├── sql/
│   ├── Load_data.sql          → Chargement des données BRONZE
│   ├── clean_data.sql         → Nettoyage des données SILVER
│   ├── sales_trends.sql       → Analyses des ventes
│   ├── promotion_impact.sql   → Impact des promotions
│   └── campaign_performance.sql → Performance des campagnes
├── streamlit/
│   ├── sales_dashboard.py     → Dashboard des ventes
│   ├── promotion_analysis.py  → Analyse des promotions
│   └── marketing_roi.py       → ROI des campagnes
├── README.md
└── business_insights.md

Sources de données
FichierDescriptionLignescustomer_demographics.csvDonnées démographiques clients5000customer_service_interactions.csvInteractions service client5000financial_transactions.csvTransactions financières5000promotions-data.csvDonnées promotions87marketing_campaigns.csvCampagnes marketing5000product_reviews.csvAvis produits5*inventory.jsonNiveaux de stock5000store_locations.jsonInformations magasins5000logistics_and_shipping.csvDonnées logistiques5000supplier_information.csvInformations fournisseurs5000employee_records.csvDonnées employés5000


Prérequis

Compte Snowflake (Edition Enterprise, AWS, us-west-2)
Accès au bucket S3 : s3://logbrain-datalake/datasets/food-beverage/


Installation
1. Créer l'environnement Snowflake
sqlCREATE DATABASE IF NOT EXISTS ANYCOMPANY_LAB;
USE DATABASE ANYCOMPANY_LAB;
CREATE SCHEMA IF NOT EXISTS BRONZE;
CREATE SCHEMA IF NOT EXISTS SILVER;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;
CREATE WAREHOUSE IF NOT EXISTS ANYCOMPANY_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;
2. Charger les données
sql-- Exécuter le fichier sql/Load_data.sql
3. Nettoyer les données
sql-- Exécuter le fichier sql/clean_data.sql
4. Créer le Data Product
sql-- Exécuter le fichier sql/analytics.sql

Analyses réalisées
Phase 2 – Analyses Business
AnalyseFichier SQLEvolution des ventes par annéesales_trends.sqlPerformance par régionsales_trends.sqlSegmentation clientssales_trends.sqlImpact des promotionspromotion_impact.sqlPerformance des campagnescampaign_performance.sqlROI des campagnescampaign_performance.sqlDélais de livraisoncampaign_performance.sqlRuptures de stockcampaign_performance.sql
Phase 3 – Data Product
TableDescriptionANALYTICS.SALES_ENRICHEDVentes enrichies avec promotions et campagnesANALYTICS.CUSTOMERS_ENRICHEDClients enrichis avec interactionsANALYTICS.PROMOTIONS_ENRICHEDPromotions enrichies avec ventes

Equipe
Ce projet a été réalisé par :

Ouidad Boussala
Idriss Hajjaj
Kedja Manzan Dominique Colombe

Dans le cadre du cours Architecture Big Data – MBAESG 2026
