# DataAnalytics-Assessment

This repository contains the solutions to Cowrywise data analytics assessment comprising of four questions. Each file corresponds to a specific question. Documented also is the approach taken and challenges encountered in solving each question.

### Assessment_Q1
#### High-Value Customers with Multiple Products 
The aim of this is to find customers with at least one funded savings plan and one funded investment plan, sorted by total deposits. 
To solve this, I aimed to summarize each user's funding activity across both savings and investment plans. The goal was to find customers with a funded savings and investment plan, as well as calculate the total amount deposited since inception.

I used the plans_plan table to count the number of funded savings and investment plans, distinguishing between them using the is_regular_savings and is_a_fund flags respectively.
A plan was considered "funded" if it had a positive amount and was not marked as deleted (is_deleted = 0).
To calculate total deposits, I joined the savings_savingsaccount table which acts more like a transaction log, and summed the confirmed_amount for transactions. Made use of a Coalesce function to handle Nulls in the confirmed_amount columns. And regex function to identify the successful transactions.

🚧 Challenges:
1. Inactive or Deleted Plans: Initially, some plans appeared in the dataset but were not active. I resolved this by filtering out plans where is_deleted = 1.
2. Identifying Successful Transactions: Initially, it was not clear how to accurately determine successful transactions in the savings_savingsaccount table due to the large volume of entries and varied status values. To ensure consistency, I filtered transactions using status values that contained the term 'success' (e.g., 'success', 'successful', 'monnify_success').
3. Understanding Table Roles: There was some confusion between the amount fields in the plans_plan and savings_savingsaccount tables. After exploration, I understood that plans_plan stores metadata about savings/investment plans, while savings_savingsaccount contains transactional data — hence the latter was used for calculating deposits.
This approach ensures that only active and funded plans are considered, and users are only included in the final result if they have both at least one savings and one investment plan funded. The output is sorted by total_deposit in descending order to highlight high-value customers.

### Assessment_Q2
#### Transaction Frequency Analysis
The objective of this query was to analyze the customer transaction performance by classifying them into frequency categories — High, Medium, or Low, based on how often they transacted over time.

I focused on transactions from the savings_savingsaccount table and linked them with user data from the users_customuser table.

Regex function was used to include only successful transactions to ensure accuracy in measuring actual customer activity. This included transactions with statuses 'success', 'successful', and 'monnify_success'. I grouped the query into 2 CTEs to properly capture logic.

1. The first CTE transactions computes the transactional metrics for each of the user. 
For each customer, I calculated number of successful transactions, using regex to consider successful transactions.
The active months was also captured, using the Greatest function ensuring a month is picked even if a customer made all transactions in a month.

3. The second CTE customers_category assigns a frequency category and keeps the average transactions per month.
Customers were grouped into the buckets:
High Frequency (10+ transactions/month)
Medium Frequency (3–9 transactions/month)
Low Frequency (<3 transactions/month)
The average number of transactions per month was also captured with safety checks to avoid division by null values.

5. The last query groups by frequency_category to get the count of customers in each group and the average of their average monthly transaction counts.

Why CTE?
I used a Common Table Expression (CTE) to break the logic into manageable steps:


### Assessment_Q3
#### Account Inactivity Alert
This query identifies inactive savings and investment plans that have not been funded in the past 365 days.

To identify inactive Savings and Investments:
I used MAX(s.transaction_date) from the savings_savingsaccount table to determine the last time a transaction occurred on both savings and investment plans.
Regex function was used to include only successful transactions
Only plans marked as is_regular_savings = 1 and active (is_deleted = 0) were considered for savings. 
Only plans marked as is_a_fund = 1 for and active (is_deleted = 0) were considered for investments.
Plans were flagged as inactive if their most recent transaction was over a year ago.
.

🚧 Challenges:
Identifying the most reliable transaction date as there was a last_charge_date in plans table and transaction_date in savings table

### Assessment_Q4
#### Customer Lifetime Value (CLV) Estimation
To estimate CLV, I started by calculating each customer's tenure on Cowrywise using the difference between the current date and their date_joined value from the users_customuser table.

From the savings_savingsaccount table, I computed the following for each customer:

Total successful transactions by counting savings_id.
Total transaction amount, using SUM(confirmed_amount) with the COALESCE function to handle NULL values.
Average transaction value, calculated as the total confirmed amount divided by the number of transactions.

To ensure accuracy, I filtered only successful transactions using a REGEXP condition that matched variations of "success" in lowercase.

Next, I calculated the average monthly transaction frequency as total_transactions / tenure_months
Then multiplied this monthly frequency by 12 to estimate annual transaction frequency.
Multiplied the result by the average transaction value to derive an estimated Customer Lifetime Value (CLV).
Applied the ROUND function to format the final output to two decimal places for better readability.

#### Check files section for sql files
