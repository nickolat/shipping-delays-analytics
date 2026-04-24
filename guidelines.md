# Project Guidelines
*Predicting Shipping Delays and Enhancing Revenue with Data-Driven Insights*

**Information Systems Design and Big Data**

**Exam date: 2024-09-23**


## INTRODUCTION

This project-work involves a series of tasks modeled after authentic projects, requiring you to identify optimal solutions, design and architect systems, and execute data processing tasks in accordance with defined specifications.

The project work deliverables must be completed and consigned within 24 hours before starting the exam session.
Timely submission of project-work deliverables is a prerequisite for eligibility to undertake the theoretical exam. Evaluation will encompass both the project-work and the theoretical test, each carrying equal weight at 50%. Should the final grade fall below the passing threshold or face rejection, the standalone mark for the project work cannot be sustained and must be revisited in subsequent sessions with a new set of specifications.


## PART 1

You are a data scientist working for a shipping company that aims to optimize its logistics operations. Your task is to predict shipping delays and quantify the expected delay in days. The ultimate goal is to provide better service to the most profitable customers by tailoring predictions and evaluations based on revenue-generating clusters. This project will help improve customer satisfaction and operational efficiency by minimizing delays for high-revenue segments.

### Objective

The objectives of your work are the following:

1. Perform **exploratory data analysis** to understand the factors influencing shipping delays.
2. Identify **clusters** that bring the highest revenues to the company (e.g., based on country, product type).
3. Develop predictive models to **forecast shipping delays** and quantify the expected delay in days.
4. Tailor the training and evaluation process by giving more weight to the **most profitable customers**.

### Data Sources

The dataset is made of 50 columns providing a comprehensive evaluation of the orders, customers and items purchased. For sake of brevity, we will omit the summary of the columns here, and we will focus on the content. You fill find numerical and categorical variables, one even time-related. Some columns will be anonymized, others will be uninformative, and other will have high cardinality. The target variable should either be "Delivery Status" or the delta between "Days for shipping (real)" and "Days for shipment (scheduled)" columns, or a function of the previous variables.


### Data Exploration and Cleaning

This is a complex dataset, so it is imperative to perform a very thorough data exploration. In particular, focus on the following tasks:

1. Identify the presence of uninformative features based on their name.
2. Generate summary statistics for each of the remaining features.
3. Identify the features with 0 variance and remove them.
4. When you identify categorical variables, determine whether the categories are nominals or ordinals.
5. Identify potentially redundant and multicollinear features based on their column names and contents.
6. Identify potential collinearities between the numerical features through the correlation matrix.
7. Define what to do with the time-related features.
8. Generate summary statistics for each feature.

Finally, identify the clusters that drive the bulk of the revenue. Such clusters can either be related to the items (e.g., Category Name), or to the customer (e.g., Customer Segment). The value to aggregate should be "Order Profit Per Order" or "Order Item Profit Ratio", because they identify how profitable the transaction was.

### Feature Selection and Engineering

The large number of redundant categorical features is a considerable challenge that must be overcome: it increases exponentially the complexity of the dataset without adding much information. Your first task, hence, should be to treat them accordingly. To do it, you should choose an appropriate level of granularity (too many classes = risk of overfitting, too few classes = risk of underfitting) and either select a feature well representing your choice or choosing a suitable one and performing custom aggregations to reach the desired result. In doing this task, please consider also the clusters you have previously identified.

Then proceed with all the standard steps:

1. encoding the categorical variables;
2. scaling the numerical variables.

### Model Development

Now it is time to develop the model. Firstly, an appropriate metric should be defined. Then the weights should be included in such metric. In fact, data points from the most profitable clusters should be given more importance than those from the least profitable ones.

Secondly, define a suitable train-test splitting strategy and implement it. *Hint: this step is particularly critical because different strategies have different implications. When selecting your strategy, try answering questions like: is it better to perform a temporal or an atemporal splitting? How can we ensure that the class abundances in the train set are compatible with those in the test set?*

Finally, select a suitable model, train it and evaluate its performances. Perform the training both using the weights and without them and compare the results according to the weighted metric that you have previously defined. Which is better? Discuss it.

### Conclusion

This project aims to enhance the logistics operations of the shipping company by leveraging predictive analytics to forecast shipping delays. By tailoring the training and evaluation process to prioritize high-revenue customers/products, the project seeks to improve customer satisfaction and operational efficiency. The final models will empower the company to make data-driven decisions, ultimately leading to better resource allocation and improved service quality.


## PART 2

Considering the ad-hoc data analysis developed in PART 1, you are now required to design your proposed architecture to industrialize the solution for shipping delay continuous forecasting and monitoring.

### Process description

The proposed solution will support processes here described:

*Shipping events and updated status are real time integrated from an external shipping tracking system which collects events data from all shipments and pushes data in real time to the data platform. Shipping delay forecast is recalculated every 15 minutes based on the data collected during the past hours, when the scheduled process to recalculate the shipments delay is finished, a data pipeline report is sent to the Data Engineers team to give evidence on the amount and type of data involved in the process. Once the updated Shipping Delay forecast report is ready, it is pushed to an external third-party monitoring console accessible by customers in a secure way. Once a day at 5.00pm, a daily Shipping Delay forecast recap report is sent via email to the marketing team for monitoring and control the status of shipments delay for each customer.*

### Solution requirements and constraints

The solution must be implemented as a modern data platform cloud based, which receives a data stream from the external shipments tracking system to a message queue system, data stream needs to be locally stored for further elaboration. Every 15 minutes a scheduled task triggers the data elaboration pipeline to update the shipment delay forecast value and update the third-party system by means of a standard API call.

- Average number of events collected per day: 300.000
- Average size for each event message: 5KB

## Deliverables

You will have to describe the main components, tools, and technologies that you would use to achieve this goal, as well as the rationale behind your choices. In agreement with the client, it has been established that the solution will be based on public cloud services, and the elements of the proposed architecture must be collected in a deliverable document containing at least the following elements:

1. Formalize the business process by representing it through a **BPMN diagram**.
2. Provide architecture description including a high-level diagram that illustrates solutions functional layers, technical components, the data flow and the interactions among the different elements of your architecture. Architecture components must be described and choices must be motivated taking into account the trade-offs between performance, reliability, and affordability.
3. Provide the **Terraform script** which executes the provisioning of components identified in the architecture description.
4. Finally, you will have to **estimate the running costs** of your solution.

Secondly, you need to provide a **notebook** with all the technical details about the exploratory data analysis, data integration, feature engineering, model development and evaluation. Moreover, in this notebook include all the visuals and SQL queries used for your analysis.

Finally, build a **PowerBI dashboard** that contains some insightful visualization to further improve the presentation of your analysis (File PBix).
