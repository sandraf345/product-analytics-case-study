# Product Analytics Case Study — User Activation & Retention

A product analytics case study analyzing user behavior across more than 4 million e-commerce interaction events using **Python and SQL**, with a focus on early engagement, activation, retention, funnel performance, and experiment design.

The goal of the project is to translate behavioral data into a concrete product opportunity and design an A/B testing framework to evaluate the proposed product change.

## Project Objective

The analysis explores three main questions:

1. Which early user behaviors are associated with subsequent return?
2. Can a meaningful activation milestone be identified from behavioral data?
3. How can these insights be translated into a product recommendation and a measurable experiment?

## Dataset

The analysis uses an event-level e-commerce behavioral dataset containing product interactions such as:

- product views
- add-to-cart events
- remove-from-cart events
- purchases

**Source:** [eCommerce Events History in Cosmetics Shop — Kaggle](https://www.kaggle.com/mkechinov/ecommerce-events-history-in-cosmetics-shop)

The dataset was provided by REES46 Marketing Platform and contains behavioral events from a medium-sized online cosmetics store. This project uses the October 2019 file (`2019-Oct.csv`).

The raw dataset contains more than **4 million events**.

The raw CSV is not included in this repository due to file size. The analysis expects the dataset to be stored locally in the `data/` directory.

## Tools & Skills

- **Python:** pandas, NumPy, matplotlib
- **SQL:** DuckDB
- **Product Analytics:** activation, retention, behavioral segmentation, funnel analysis
- **Experimentation:** A/B testing, hypothesis design, primary and secondary metrics, guardrails, power analysis and sample-size planning

## Analysis Approach

### 1. Data Preparation

The raw event-level data was inspected and cleaned before analysis. User activity was then transformed into a user-level analytical dataset.

To reduce right-censoring, only users with sufficient remaining observation time were included in the activation and retention analysis.

### 2. Activation & Retention

Early behavior was analyzed during each user's first three observed days.

The proposed activation milestone was defined as:

> **At least 2 sessions and at least 4 unique products viewed within the first 3 observed days.**

Threshold analysis was used to evaluate the trade-off between activation reach and its association with subsequent return behavior.

### 3. SQL Funnel Analysis

SQL was used to analyze progression through the core product funnel:

**View → Cart → Purchase**

Both stage-reach and chronological sequential funnels were evaluated to distinguish between users who reached each stage and users who progressed through the stages in the expected order.

## Key Findings

- **8.25%** of eligible users reached the proposed activation milestone.
- Activated users showed a **30.07%** observed 7–14 day return rate compared with **7.14%** among non-activated users.
- This represents approximately a **4.21× difference** in observed return rate.
- Return behavior increased consistently with deeper early product exploration.
- The sequential funnel showed a **30.35% View → Cart conversion rate**.
- **19.63%** of users who reached cart after viewing subsequently reached purchase.
- Overall sequential **View → Purchase conversion was 5.96%**.
- The largest observed stage-to-stage funnel drop-off occurred between **Cart and Purchase (80.37%)**.

The activation-retention relationship is observational and should not be interpreted as causal.

## Product Recommendation

Based on the relationship between early product exploration and subsequent return behavior, the proposed intervention is a **personalized product discovery module**.

The module would surface relevant products based on products or categories a user has already explored, with the goal of encouraging deeper early exploration and increasing the share of users who reach the activation milestone.

Proposed behavioral pathway:

**Personalized discovery → deeper product exploration → higher activation → potential improvement in subsequent retention**

The substantial Cart → Purchase drop-off represents an additional product opportunity, but the available dataset does not contain enough information to diagnose the underlying source of purchase friction.

## A/B Testing Framework

A controlled experiment is proposed to test whether the personalized discovery module increases activation.

**Control:** Existing product experience.

**Treatment:** Existing experience with personalized product recommendations.

**Primary metric:** Activation rate.

**Secondary metrics:**
- unique products viewed per user
- second-session rate
- 7–14 day return rate
- purchase conversion rate

**Guardrail metrics:**
- remove-from-cart rate
- cart-to-purchase conversion rate

Using the observed **8.25% activation rate** as the baseline, the experiment is powered to detect a **15% relative improvement**, corresponding to an activation rate of approximately **9.49%**.

With α = 0.05 and 80% statistical power, the estimated required sample is approximately:

- **8,275 users per group**
- **16,550 users total**

A minimum **14-day enrollment period** is proposed to capture multiple weekly cycles, followed by the necessary observation period for downstream retention measurement.

## Limitations

- The dataset covers only one month of activity.
- First observed activity does not necessarily represent a user's true first interaction with the product.
- The data does not include acquisition channel, device, demographics, marketing exposure, or detailed checkout information.
- Activation and retention relationships are observational rather than causal.
- The activation threshold was selected and evaluated using the same dataset and should be validated on independent data or through experimentation.
- The proposed recommendation feature was not implemented or experimentally tested; the A/B test represents a framework for future validation.

## Repository Structure

```text
product-analytics-case-study/
│
├── notebooks/
│   └── 01_product_analysis.ipynb
│
├── sql/
│   └── product_metrics.sql
│
├── data/
│   └── raw dataset (not included)
│
├── requirements.txt
├── .gitignore
└── README.md
```

## Reproducing the Analysis

Install the required Python packages:

```bash
pip install -r requirements.txt
```

Place the raw dataset in the `data/` directory and run:

```text
notebooks/01_product_analysis.ipynb
```

The notebook contains the complete workflow from data preparation and exploratory analysis through activation modeling, SQL funnel analysis, product recommendation, and A/B test design.

## Project Summary

This case study demonstrates how **Python, SQL, product analytics, and experimentation principles** can be combined to move from raw behavioral data to a measurable product recommendation.

Rather than treating behavioral correlations as causal effects, the analysis uses observational data to identify a product opportunity and then proposes a controlled experiment to validate whether the intervention can meaningfully improve user activation.