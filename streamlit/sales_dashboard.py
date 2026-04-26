import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(layout="wide", page_title="AnyCompany – Dashboard")

st.markdown("""
<style>
    .header-box {
        background: linear-gradient(135deg, #c0392b, #e67e22);
        padding: 25px;
        border-radius: 15px;
        text-align: center;
        margin-bottom: 25px;
    }
    .header-box h1 { color: white; font-size: 2.2rem; margin: 0; }
    .header-box p  { color: #fde8d8; font-size: 1rem; }
    .kpi-card {
        background: linear-gradient(135deg, #c0392b, #e74c3c);
        padding: 20px;
        border-radius: 12px;
        text-align: center;
        margin-bottom: 10px;
    }
    .kpi-card .value { color: white; font-size: 1.8rem; font-weight: bold; }
    .kpi-card .label { color: #fde8d8; font-size: 0.85rem; }
    .kpi-card-orange {
        background: linear-gradient(135deg, #e67e22, #f39c12);
        padding: 20px;
        border-radius: 12px;
        text-align: center;
        margin-bottom: 10px;
    }
    .kpi-card-orange .value { color: white; font-size: 1.8rem; font-weight: bold; }
    .kpi-card-orange .label { color: #fef9e7; font-size: 0.85rem; }
    .section-title {
        color: #e74c3c;
        font-size: 1.3rem;
        font-weight: bold;
        border-left: 4px solid #e67e22;
        padding-left: 10px;
        margin: 20px 0 10px 0;
    }
    .page-title {
        background: linear-gradient(135deg, #922b21, #c0392b);
        padding: 15px;
        border-radius: 10px;
        color: white;
        font-size: 1.5rem;
        font-weight: bold;
        text-align: center;
        margin: 30px 0 20px 0;
    }
</style>
""", unsafe_allow_html=True)

st.markdown("""
<div class="header-box">
    <h1>AnyCompany Food & Beverage</h1>
    <p>Marketing Data-Driven Dashboard – MBAESG 2026</p>
</div>
""", unsafe_allow_html=True)

session = get_active_session()

# ============================================
# PAGE 1 : DASHBOARD DES VENTES
# ============================================
st.markdown('<div class="page-title">Dashboard des Ventes</div>', unsafe_allow_html=True)

df_kpi = session.sql(
    "SELECT COUNT(*) AS nb_transactions, ROUND(SUM(amount),2) AS chiffre_affaires, ROUND(AVG(amount),2) AS panier_moyen, ROUND(MAX(amount),2) AS vente_max FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN WHERE transaction_type = 'Sale'"
).to_pandas()

st.markdown('<div class="section-title">Indicateurs Cles de Performance</div>', unsafe_allow_html=True)
col1, col2, col3, col4 = st.columns(4)
with col1:
    st.markdown(f'<div class="kpi-card"><div class="value">{int(df_kpi["NB_TRANSACTIONS"][0]):,}</div><div class="label">Total Transactions</div></div>', unsafe_allow_html=True)
with col2:
    st.markdown(f'<div class="kpi-card"><div class="value">{df_kpi["CHIFFRE_AFFAIRES"][0]:,.0f} $</div><div class="label">Chiffre daffaires</div></div>', unsafe_allow_html=True)
with col3:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{df_kpi["PANIER_MOYEN"][0]:,.2f} $</div><div class="label">Panier Moyen</div></div>', unsafe_allow_html=True)
with col4:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{df_kpi["VENTE_MAX"][0]:,.2f} $</div><div class="label">Vente Maximum</div></div>', unsafe_allow_html=True)

st.divider()

col_left, col_right = st.columns(2)
with col_left:
    st.markdown('<div class="section-title">Evolution du CA par annee</div>', unsafe_allow_html=True)
    df_ventes = session.sql(
        "SELECT YEAR(transaction_date) AS annee, ROUND(SUM(amount),2) AS chiffre_affaires FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN WHERE transaction_type = 'Sale' GROUP BY YEAR(transaction_date) ORDER BY annee"
    ).to_pandas()
    st.line_chart(data=df_ventes, x="ANNEE", y="CHIFFRE_AFFAIRES", color="#e74c3c")

with col_right:
    st.markdown('<div class="section-title">CA par region</div>', unsafe_allow_html=True)
    df_region = session.sql(
        "SELECT region, ROUND(SUM(amount),2) AS chiffre_affaires FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN WHERE transaction_type = 'Sale' GROUP BY region ORDER BY chiffre_affaires DESC"
    ).to_pandas()
    st.bar_chart(data=df_region, x="REGION", y="CHIFFRE_AFFAIRES", color="#e67e22")

st.divider()

st.markdown('<div class="section-title">Segmentation des Clients par Revenu</div>', unsafe_allow_html=True)
df_segment = session.sql(
    "SELECT CASE WHEN annual_income < 50000 THEN '1 - Faible' WHEN annual_income < 100000 THEN '2 - Moyen' WHEN annual_income < 150000 THEN '3 - Eleve' ELSE '4 - Tres eleve' END AS segment_revenu, COUNT(*) AS nb_clients FROM ANYCOMPANY_LAB.SILVER.CUSTOMER_DEMOGRAPHICS_CLEAN GROUP BY segment_revenu ORDER BY segment_revenu"
).to_pandas()
col1, col2 = st.columns(2)
with col1:
    st.bar_chart(data=df_segment, x="SEGMENT_REVENU", y="NB_CLIENTS", color="#c0392b")
with col2:
    st.dataframe(df_segment, use_container_width=True)

# ============================================
# PAGE 2 : ANALYSE DES PROMOTIONS
# ============================================
st.markdown('<div class="page-title">Analyse des Promotions</div>', unsafe_allow_html=True)

df_kpi_promo = session.sql(
    "SELECT COUNT(*) AS nb_promotions, ROUND(AVG(discount_percentage)*100,2) AS remise_moyenne, ROUND(MAX(discount_percentage)*100,2) AS remise_max, COUNT(DISTINCT region) AS nb_regions FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN"
).to_pandas()

st.markdown('<div class="section-title">Indicateurs Cles des Promotions</div>', unsafe_allow_html=True)
col1, col2, col3, col4 = st.columns(4)
with col1:
    st.markdown(f'<div class="kpi-card"><div class="value">{int(df_kpi_promo["NB_PROMOTIONS"][0])}</div><div class="label">Total Promotions</div></div>', unsafe_allow_html=True)
with col2:
    st.markdown(f'<div class="kpi-card"><div class="value">{df_kpi_promo["REMISE_MOYENNE"][0]} %</div><div class="label">Remise Moyenne</div></div>', unsafe_allow_html=True)
with col3:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{df_kpi_promo["REMISE_MAX"][0]} %</div><div class="label">Remise Maximum</div></div>', unsafe_allow_html=True)
with col4:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{int(df_kpi_promo["NB_REGIONS"][0])}</div><div class="label">Regions Ciblees</div></div>', unsafe_allow_html=True)

st.divider()

col_left, col_right = st.columns(2)
with col_left:
    st.markdown('<div class="section-title">Top 15 promotions par CA</div>', unsafe_allow_html=True)
    df_promo = session.sql(
        "SELECT p.promotion_type, p.product_category, ROUND(SUM(f.amount),2) AS ca_total, ROUND(AVG(p.discount_percentage)*100,2) AS remise_pct FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN p LEFT JOIN ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN f ON f.region = p.region AND f.transaction_date BETWEEN p.start_date AND p.end_date AND f.transaction_type = 'Sale' GROUP BY p.promotion_type, p.product_category HAVING SUM(f.amount) IS NOT NULL ORDER BY ca_total DESC LIMIT 15"
    ).to_pandas()
    st.bar_chart(data=df_promo, x="PROMOTION_TYPE", y="CA_TOTAL", color="#e74c3c")

with col_right:
    st.markdown('<div class="section-title">Remise moyenne par categorie</div>', unsafe_allow_html=True)
    df_remise = session.sql(
        "SELECT product_category, ROUND(AVG(discount_percentage)*100,2) AS remise_moyenne_pct, COUNT(*) AS nb_promotions FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN GROUP BY product_category ORDER BY remise_moyenne_pct DESC"
    ).to_pandas()
    st.bar_chart(data=df_remise, x="PRODUCT_CATEGORY", y="REMISE_MOYENNE_PCT", color="#e67e22")

st.divider()
st.markdown('<div class="section-title">Detail des Promotions</div>', unsafe_allow_html=True)
st.dataframe(df_promo, use_container_width=True)

# ============================================
# PAGE 3 : PERFORMANCE MARKETING
# ============================================
st.markdown('<div class="page-title">Performance des Campagnes Marketing</div>', unsafe_allow_html=True)

df_kpi_camp = session.sql(
    "SELECT COUNT(*) AS nb_campagnes, ROUND(SUM(budget),2) AS budget_total, ROUND(AVG(conversion_rate)*100,2) AS taux_conversion_moyen, ROUND(SUM(reach),0) AS audience_totale FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN"
).to_pandas()

st.markdown('<div class="section-title">Indicateurs Cles des Campagnes</div>', unsafe_allow_html=True)
col1, col2, col3, col4 = st.columns(4)
with col1:
    st.markdown(f'<div class="kpi-card"><div class="value">{int(df_kpi_camp["NB_CAMPAGNES"][0]):,}</div><div class="label">Total Campagnes</div></div>', unsafe_allow_html=True)
with col2:
    st.markdown(f'<div class="kpi-card"><div class="value">{df_kpi_camp["BUDGET_TOTAL"][0]:,.0f} $</div><div class="label">Budget Total</div></div>', unsafe_allow_html=True)
with col3:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{df_kpi_camp["TAUX_CONVERSION_MOYEN"][0]} %</div><div class="label">Taux Conversion Moyen</div></div>', unsafe_allow_html=True)
with col4:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{int(df_kpi_camp["AUDIENCE_TOTALE"][0]):,}</div><div class="label">Audience Totale</div></div>', unsafe_allow_html=True)

st.divider()

col_left, col_right = st.columns(2)
with col_left:
    st.markdown('<div class="section-title">Taux de conversion par type</div>', unsafe_allow_html=True)
    df_conv = session.sql(
        "SELECT campaign_type, ROUND(AVG(conversion_rate)*100,2) AS taux_conversion_moyen FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN GROUP BY campaign_type ORDER BY taux_conversion_moyen DESC"
    ).to_pandas()
    st.bar_chart(data=df_conv, x="CAMPAIGN_TYPE", y="TAUX_CONVERSION_MOYEN", color="#e74c3c")

with col_right:
    st.markdown('<div class="section-title">Budget par type de campagne</div>', unsafe_allow_html=True)
    df_budget = session.sql(
        "SELECT campaign_type, ROUND(SUM(budget),2) AS budget_total FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN GROUP BY campaign_type ORDER BY budget_total DESC"
    ).to_pandas()
    st.bar_chart(data=df_budget, x="CAMPAIGN_TYPE", y="BUDGET_TOTAL", color="#e67e22")

st.divider()

st.markdown('<div class="section-title">Top 10 Campagnes les plus efficaces</div>', unsafe_allow_html=True)
df_top = session.sql(
    "SELECT campaign_name, campaign_type, region, ROUND(budget,2) AS budget, reach, ROUND(conversion_rate*100,2) AS taux_conversion_pct, ROUND(reach*conversion_rate,0) AS nb_conversions_estimees, ROUND(budget/NULLIF(reach,0),2) AS cout_par_personne FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN ORDER BY taux_conversion_pct DESC LIMIT 10"
).to_pandas()
st.bar_chart(data=df_top, x="CAMPAIGN_NAME", y="TAUX_CONVERSION_PCT", color="#c0392b")

st.divider()
st.markdown('<div class="section-title">Detail des Top 10 Campagnes</div>', unsafe_allow_html=True)
st.dataframe(df_top, use_container_width=True)

st.markdown("---")
st.markdown("<center><small>AnyCompany Food & Beverage – MBAESG 2026 | Ouidad Boussala | Idriss Hajjaj | Kedja Manzan Dominique Colombe</small></center>", unsafe_allow_html=True)
