import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(layout="wide", page_title="AnyCompany – Marketing ROI")

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
    <p>Performance des Campagnes Marketing – Marketing Data-Driven 2026</p>
</div>
""", unsafe_allow_html=True)

session = get_active_session()

# FILTRES SIDEBAR
st.sidebar.markdown("## Filtres")

df_types = session.sql(
    "SELECT DISTINCT campaign_type FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN WHERE campaign_type IS NOT NULL ORDER BY campaign_type"
).to_pandas()

types = ["Tous"] + list(df_types["CAMPAIGN_TYPE"])
type_selectionne = st.sidebar.selectbox("Type de campagne", types)

filtre_type = f"AND campaign_type = '{type_selectionne}'" if type_selectionne != "Tous" else ""

# KPIs
st.markdown('<div class="section-title">Indicateurs Cles des Campagnes</div>', unsafe_allow_html=True)

df_kpi = session.sql(
    "SELECT COUNT(*) AS nb_campagnes, ROUND(SUM(budget),2) AS budget_total, ROUND(AVG(conversion_rate)*100,2) AS taux_conversion_moyen, ROUND(SUM(reach),0) AS audience_totale FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN"
).to_pandas()

col1, col2, col3, col4 = st.columns(4)
with col1:
    st.markdown(f'<div class="kpi-card"><div class="value">{int(df_kpi["NB_CAMPAGNES"][0]):,}</div><div class="label">Total Campagnes</div></div>', unsafe_allow_html=True)
with col2:
    st.markdown(f'<div class="kpi-card"><div class="value">{df_kpi["BUDGET_TOTAL"][0]:,.0f} $</div><div class="label">Budget Total</div></div>', unsafe_allow_html=True)
with col3:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{df_kpi["TAUX_CONVERSION_MOYEN"][0]} %</div><div class="label">Taux Conversion Moyen</div></div>', unsafe_allow_html=True)
with col4:
    st.markdown(f'<div class="kpi-card-orange"><div class="value">{int(df_kpi["AUDIENCE_TOTALE"][0]):,}</div><div class="label">Audience Totale</div></div>', unsafe_allow_html=True)

st.divider()

# GRAPHIQUES
col_left, col_right = st.columns(2)

with col_left:
    st.markdown('<div class="section-title">Taux de conversion par type de campagne</div>', unsafe_allow_html=True)
    df_conv = session.sql(
        f"SELECT campaign_type, ROUND(AVG(conversion_rate)*100,2) AS taux_conversion_moyen, COUNT(*) AS nb_campagnes FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN WHERE 1=1 {filtre_type} GROUP BY campaign_type ORDER BY taux_conversion_moyen DESC"
    ).to_pandas()
    st.bar_chart(data=df_conv, x="CAMPAIGN_TYPE", y="TAUX_CONVERSION_MOYEN", color="#e74c3c")

with col_right:
    st.markdown('<div class="section-title">Budget total par type de campagne</div>', unsafe_allow_html=True)
    df_budget = session.sql(
        f"SELECT campaign_type, ROUND(SUM(budget),2) AS budget_total FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN WHERE 1=1 {filtre_type} GROUP BY campaign_type ORDER BY budget_total DESC"
    ).to_pandas()
    st.bar_chart(data=df_budget, x="CAMPAIGN_TYPE", y="BUDGET_TOTAL", color="#e67e22")

st.divider()

# TOP 10 CAMPAGNES
st.markdown('<div class="section-title">Top 10 Campagnes les plus efficaces</div>', unsafe_allow_html=True)

df_top = session.sql(
    f"SELECT campaign_name, campaign_type, region, ROUND(budget,2) AS budget, reach, ROUND(conversion_rate*100,2) AS taux_conversion_pct, ROUND(reach*conversion_rate,0) AS nb_conversions_estimees, ROUND(budget/NULLIF(reach,0),2) AS cout_par_personne FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN WHERE 1=1 {filtre_type} ORDER BY taux_conversion_pct DESC LIMIT 10"
).to_pandas()

st.bar_chart(data=df_top, x="CAMPAIGN_NAME", y="TAUX_CONVERSION_PCT", color="#c0392b")

st.divider()

# PERFORMANCE PAR REGION
st.markdown('<div class="section-title">Performance par Region</div>', unsafe_allow_html=True)

df_region = session.sql(
    f"SELECT region, COUNT(*) AS nb_campagnes, ROUND(AVG(conversion_rate)*100,2) AS taux_conversion_moyen, ROUND(SUM(budget),2) AS budget_total FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN WHERE 1=1 {filtre_type} GROUP BY region ORDER BY taux_conversion_moyen DESC"
).to_pandas()

col1, col2 = st.columns(2)
with col1:
    st.bar_chart(data=df_region, x="REGION", y="TAUX_CONVERSION_MOYEN", color="#e67e22")
with col2:
    st.dataframe(df_region, use_container_width=True)

st.divider()

st.markdown('<div class="section-title">Detail des Top 10 Campagnes</div>', unsafe_allow_html=True)
st.dataframe(df_top, use_container_width=True)

st.markdown("---")
st.markdown("<center><small>AnyCompany Food & Beverage – MBAESG 2026 | Ouidad Boussala | Idriss Hajjaj | Kedja Manzan Dominique Colombe</small></center>", unsafe_allow_html=True)
