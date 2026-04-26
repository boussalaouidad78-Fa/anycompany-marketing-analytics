import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(layout="wide", page_title="AnyCompany – Promotions")

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
</style>
""", unsafe_allow_html=True)

st.markdown("""
<div class="header-box">
    <h1>AnyCompany Food & Beverage</h1>
    <p>Analyse de l Impact des Promotions – Marketing Data-Driven 2026</p>
</div>
""", unsafe_allow_html=True)

session = get_active_session()

# FILTRES SIDEBAR
st.sidebar.markdown("## Filtres")

df_categories = session.sql(
    "SELECT DISTINCT product_category FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN WHERE product_category IS NOT NULL ORDER BY product_category"
).to_pandas()

categories = ["Toutes"] + list(df_categories["PRODUCT_CATEGORY"])
categorie_selectionnee = st.sidebar.selectbox("Categorie de produit", categories)

filtre_categorie = f"AND p.product_category = '{categorie_selectionnee}'" if categorie_selectionnee != "Toutes" else ""

# KPIs
st.markdown('<div class="section-title">Indicateurs Cles des Promotions</div>', unsafe_allow_html=True)

df_kpi = session.sql(
    "SELECT COUNT(*) AS nb_promotions, ROUND(AVG(discount_percentage)*100,2) AS remise_moyenne, ROUND(MAX(discount_percentage)*100,2) AS remise_max, COUNT(DISTINCT region) AS nb_regions FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN"
).to_pandas()

col1, col2, col3, col4 = st.columns(4)
with col1:
    st.markdown(f'<div class="kpi-card"><div class="value">{int(df_kpi["NB_PROMOTIONS"][0])}</div><div class="label">Total Promotions</div></div>', unsafe_allow_html=True)
with col2:
    st.markdown(f'<div class="kpi-card"><div class="value">{df_kpi["REMISE_MOYENNE"][0]} %</div><div class="label">Remise Moyenne</div></div>', unsafe_allow_html=True)
with col3:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{df_kpi["REMISE_MAX"][0]} %</div><div class="label">Remise Maximum</div></div>', unsafe_allow_html=True)
with col4:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{int(df_kpi["NB_REGIONS"][0])}</div><div class="label">Regions Ciblees</div></div>', unsafe_allow_html=True)

st.divider()

# GRAPHIQUES
col_left, col_right = st.columns(2)

with col_left:
    st.markdown('<div class="section-title">Top 15 promotions par CA</div>', unsafe_allow_html=True)
    df_promo = session.sql(
        f"SELECT p.promotion_type, p.product_category, ROUND(SUM(f.amount), 2) AS ca_total, ROUND(AVG(p.discount_percentage)*100,2) AS remise_pct FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN p LEFT JOIN ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN f ON f.region = p.region AND f.transaction_date BETWEEN p.start_date AND p.end_date AND f.transaction_type = 'Sale' WHERE 1=1 {filtre_categorie} GROUP BY p.promotion_type, p.product_category HAVING SUM(f.amount) IS NOT NULL ORDER BY ca_total DESC LIMIT 15"
    ).to_pandas()
    st.bar_chart(data=df_promo, x="PROMOTION_TYPE", y="CA_TOTAL", color="#e74c3c")

with col_right:
    st.markdown('<div class="section-title">Remise moyenne par categorie</div>', unsafe_allow_html=True)
    df_remise = session.sql(
        "SELECT product_category, ROUND(AVG(discount_percentage)*100,2) AS remise_moyenne_pct, COUNT(*) AS nb_promotions FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN GROUP BY product_category ORDER BY remise_moyenne_pct DESC"
    ).to_pandas()
    st.bar_chart(data=df_remise, x="PRODUCT_CATEGORY", y="REMISE_MOYENNE_PCT", color="#e67e22")

st.divider()

# PROMOTIONS PAR REGION
st.markdown('<div class="section-title">Promotions par Region</div>', unsafe_allow_html=True)

df_region = session.sql(
    "SELECT region, COUNT(*) AS nb_promotions, ROUND(AVG(discount_percentage)*100,2) AS remise_moyenne_pct FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN GROUP BY region ORDER BY nb_promotions DESC"
).to_pandas()

col1, col2 = st.columns(2)
with col1:
    st.bar_chart(data=df_region, x="REGION", y="NB_PROMOTIONS", color="#c0392b")
with col2:
    st.dataframe(df_region, use_container_width=True)

st.divider()

st.markdown('<div class="section-title">Detail des Promotions</div>', unsafe_allow_html=True)
st.dataframe(df_promo, use_container_width=True)

st.markdown("---")
st.markdown("<center><small>AnyCompany Food & Beverage – MBAESG 2026 | Ouidad Boussala | Idriss Hajjaj | Kedja Manzan Dominique Colombe</small></center>", unsafe_allow_html=True)
