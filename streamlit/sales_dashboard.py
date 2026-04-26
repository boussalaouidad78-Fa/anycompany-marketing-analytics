import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(layout="wide", page_title="AnyCompany – Ventes")

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
    <p>Dashboard des Ventes – Marketing Data-Driven 2026</p>
</div>
""", unsafe_allow_html=True)

session = get_active_session()

# FILTRES SIDEBAR
st.sidebar.markdown("## Filtres")

df_regions = session.sql(
    "SELECT DISTINCT region FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN WHERE region IS NOT NULL ORDER BY region"
).to_pandas()
regions = ["Toutes"] + list(df_regions["REGION"])
region_selectionnee = st.sidebar.selectbox("Region", regions)

df_annees = session.sql(
    "SELECT DISTINCT YEAR(transaction_date) AS annee FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN ORDER BY annee"
).to_pandas()
annees = ["Toutes"] + [str(a) for a in df_annees["ANNEE"]]
annee_selectionnee = st.sidebar.selectbox("Annee", annees)

filtre_region = f"AND region = '{region_selectionnee}'" if region_selectionnee != "Toutes" else ""
filtre_annee  = f"AND YEAR(transaction_date) = {annee_selectionnee}" if annee_selectionnee != "Toutes" else ""

# KPIs
st.markdown('<div class="section-title">Indicateurs Cles de Performance</div>', unsafe_allow_html=True)

df_kpi = session.sql(
    f"SELECT COUNT(*) AS nb_transactions, ROUND(SUM(amount),2) AS chiffre_affaires, ROUND(AVG(amount),2) AS panier_moyen, ROUND(MAX(amount),2) AS vente_max FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN WHERE transaction_type = 'Sale' {filtre_region} {filtre_annee}"
).to_pandas()

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

# GRAPHIQUES
col_left, col_right = st.columns(2)

with col_left:
    st.markdown('<div class="section-title">Evolution du CA par annee</div>', unsafe_allow_html=True)
    df_ventes = session.sql(
        f"SELECT YEAR(transaction_date) AS annee, ROUND(SUM(amount),2) AS chiffre_affaires FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN WHERE transaction_type = 'Sale' {filtre_region} GROUP BY YEAR(transaction_date) ORDER BY annee"
    ).to_pandas()
    st.line_chart(data=df_ventes, x="ANNEE", y="CHIFFRE_AFFAIRES", color="#e74c3c")

with col_right:
    st.markdown('<div class="section-title">CA par region</div>', unsafe_allow_html=True)
    df_region = session.sql(
        f"SELECT region, ROUND(SUM(amount),2) AS chiffre_affaires FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN WHERE transaction_type = 'Sale' {filtre_annee} GROUP BY region ORDER BY chiffre_affaires DESC"
    ).to_pandas()
    st.bar_chart(data=df_region, x="REGION", y="CHIFFRE_AFFAIRES", color="#e67e22")

st.divider()

# SEGMENTATION CLIENTS
st.markdown('<div class="section-title">Segmentation des Clients par Revenu</div>', unsafe_allow_html=True)

df_segment = session.sql(
    "SELECT CASE WHEN annual_income < 50000 THEN '1 - Faible' WHEN annual_income < 100000 THEN '2 - Moyen' WHEN annual_income < 150000 THEN '3 - Eleve' ELSE '4 - Tres eleve' END AS segment_revenu, COUNT(*) AS nb_clients, ROUND(AVG(annual_income),0) AS revenu_moyen FROM ANYCOMPANY_LAB.SILVER.CUSTOMER_DEMOGRAPHICS_CLEAN GROUP BY segment_revenu ORDER BY segment_revenu"
).to_pandas()

col1, col2 = st.columns(2)
with col1:
    st.bar_chart(data=df_segment, x="SEGMENT_REVENU", y="NB_CLIENTS", color="#c0392b")
with col2:
    st.dataframe(df_segment, use_container_width=True)

st.divider()

# METHODES DE PAIEMENT
st.markdown('<div class="section-title">Repartition par Methode de Paiement</div>', unsafe_allow_html=True)

df_payment = session.sql(
    f"SELECT payment_method, COUNT(*) AS nb_transactions, ROUND(SUM(amount),2) AS ca_total FROM ANYCOMPANY_LAB.SILVER.FINANCIAL_TRANSACTIONS_CLEAN WHERE transaction_type = 'Sale' {filtre_region} {filtre_annee} GROUP BY payment_method ORDER BY ca_total DESC"
).to_pandas()

col1, col2 = st.columns(2)
with col1:
    st.bar_chart(data=df_payment, x="PAYMENT_METHOD", y="CA_TOTAL", color="#e67e22")
with col2:
    st.dataframe(df_payment, use_container_width=True)

st.markdown("---")
st.markdown("<center><small>AnyCompany Food & Beverage – MBAESG 2026 | Ouidad Boussala | Idriss Hajjaj | Kedja Manzan Dominique Colombe</small></center>", unsafe_allow_html=True)
