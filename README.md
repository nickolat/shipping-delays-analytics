# Shipping Delays Project

## Overview

This project focuses on predicting shipping delays and quantifying expected delays to optimize logistics operations. A key goal is to improve service quality and prioritize the most profitable shipments through targeted, data-driven insights.

The project was developed for the **"Information Systems Design and Big Data"** exam and evaluated by **BIPxTech** instructors. Detailed guidelines and project requirements can be found in the `guidelines.md` file.

The project is divided into two main parts:
1. **Data Analysis and Modeling:** Exploratory data analysis, feature engineering, and predictive modeling using PySpark to forecast late deliveries and their durations.
2. **Architecture and Industrialization:** Design of a modern, cloud-based data platform to continuously monitor, forecast, and report shipping delays.

## Dataset

The dataset used in this project contains information about orders, purchased items, and customers from Puerto Rico and the USA (EE. UU.).
- **Dimensions:** 180,519 rows and 53 columns (excluding the progressive index)
- **Source**: [DataCo Smart Supply Chain For Big Data Analysis](https://data.mendeley.com/datasets/8gx2fvg2k6/5)

*Constante, Fabian; Silva, Fernando; Pereira, António (2019), “DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS”, Mendeley Data, V5, doi: 10.17632/8gx2fvg2k6.5*


## Part 1: Data Analysis and Modeling

The first part of the project is implemented in a DataBricks notebook (`shipping_delays.dbc`) using **PySpark**, and it is also available as a Jupyter notebook (`shipping_delays.ipynb`). It covers the entire data science lifecycle:

- 📊 **Exploratory Data Analysis (EDA) & Data Cleaning:** 
  - Analyzed a complex dataset with over 50 features.
  - Handled data quality issues by removing uninformative, redundant, and zero-variance columns, and fixed date variable formatting.
  - Evaluated collinearities to select the most informative target features.

- ⚙️ **Feature Engineering:**
  - Extracted time-based insights (e.g., order hours, weekdays, and months) and introduced domain-specific features.
  - Identified high-revenue product clusters based on average profit to give greater analytical weight to highly profitable shipments.

- 🧠 **Predictive Modeling:**
  - Adopted a two-step modeling strategy to effectively deal with diverse delivery scenarios (advanced, on-time, late, and canceled shipments).
  - **Classification:** Trained a `RandomForestClassifier` (along with tests on a Gradient-Boosted Trees Classifier) to predict the risk of a late delivery. A weighted evaluation strategy was used to prioritize higher-revenue items.
  - **Regression:** Trained a `RandomForestRegressor` to specifically estimate the amount of delay (in days) for those shipments classified as late.


## Part 2: Architecture and Industrialization

Based on the analytical foundation built in Part 1, the second part focuses on scaling and industrializing the solution into a continuous forecasting pipeline.

- 🔄 **Business Process** (`BPMN.png`): Formalizes the end-to-end business process, illustrating the scheduled pipeline that recalculates shipping delay forecasts every 15 minutes and updates third-party systems.
- 🏗️ **Architecture Diagram** (`architecture_diagram.png`): A high-level visual representation of the modern data platform built on **Google Cloud Platform (GCP)**, capable of handling a continuous stream of daily events.
- 📄 **Architecture Description** (`architecture_description.pdf`): A comprehensive summary of the architecture, detailing the specific components utilized in each layer of the data platform and the overall data flow.
- ☁️ **Infrastructure as Code** (`TF` folder): Includes the **Terraform scripts** required to automatically provision the GCP components identified in the architecture description.
- 💰 **Cost Estimation** (`cost_estimate.xlsx`): A detailed estimation of the running costs associated with the proposed cloud solution.
- 📊 **Business Intelligence** (`report.pbix`): A **PowerBI dashboard** providing insightful visualizations that enable marketing and operational teams to monitor shipment statuses.

