# 🩺 Healthcare Analytics Project – SQL & Power BI

> 🚀 **Project assigned by LearnBay** as part of the Data Analytics Capstone

---

## 🎯 Project Objective

Analyze a real-world healthcare dataset to identify:
- High-cost encounters and procedures
- Financial risks due to uncovered costs
- Utilization patterns by patient demographics and geography
- Insights for improving coverage and reducing system strain

---

## 💼 Business Problems Addressed

1. **Encounter Cost Distribution by Encounter Class**  
2. **High-Cost Patient Identification**  
3. **Uncovered Costs by Payer and Reason Code**  
4. **Procedure Cost Trends and Diagnosis Correlation**  
5. **Geographical Analysis of Encounters by Organization and Cost**  
6. **Encounter Duration and Risk Pattern Analysis**

---

## 🛠️ Tools & Technologies Used

 Tool                |Purpose                         

| 🐘 SQL Server     | Data cleaning, querying, analysis 
| 📊 Power BI       | Dashboard building & visualization 
| 🔄 Power Query    | Data transformation & merging     
| 📐 DAX            | Calculated columns, KPIs, logic  

---

## 📦 Actions Taken (Step-by-Step)

1. **🧾 Data Understanding & Import**
   - Reviewed CSV files and data dictionary
   - Imported all data into **SQL Server**

2. **🧹 Data Cleaning**
   - Removed duplicates
   - Handled null values (e.g., ReasonCode, Age)
   - Cleaned patient names (removed numbers)

3. **🔑 Data Modeling**
   - Established **primary and foreign keys**
   - Related tables using organization, patient, and payer IDs

4. **📊 Power BI Dashboarding**
   - Created 4 KPI cards: Total Cost, Avg Cost, Uncovered Cost, High-Cost Patients
   - Used pie charts, bar charts, map visual, matrix views
   - Built slicers for organization, city, encounter class

5. **📌 SQL Query Development**
   - Designed SQL queries for each business question
   - Generated data exports and cleaned views for Power BI

6. **🧠 Insight Generation**
   - Interpreted outputs using cost, frequency, and demographics
   - Summarized results with actionable insight

---

## 📈 Key Insights

- **Ambulatory** visits had the highest total cost due to frequency, not severity
- 153 patients had **repeated high-cost encounters**, many in urgent care
- Payers like **Anthem** and **Cigna** underpaid several diagnoses, raising risk
- Chronic and maternal procedures showed **low coverage** but **high costs**
- Cities like **Cambridge** and **Brookline** led in both volume and avg. cost
- Inpatient stays often exceeded **24 hours**, especially in top hospitals

---

## ✅ Recommendations

- 🎯 Implement **care management programs** for high-cost repeat patients
- 🤝 Negotiate better coverage terms with **underperforming payers**
- 📦 Consider **bundled pricing** for procedures like maternity & screenings
- 🏥 Expand **preventive care access** in high-cost/low-access regions
- 📉 Monitor cost spikes and unpaid claim trends on a **monthly basis**

---

## 🙌 Acknowledgment

This project was completed as part of the **LearnBay Data Analytics Capstone**, applying practical tools to real-world healthcare data.


