# DataAnalytics-Assessment

This repository contains the solutions to Cowrywise data analytics assessment comprising of four questions. Each file corresponds to a specific question. Documented also is the approach taken and challenges encountered in solving each question.

### Assessment_Q1
#### High-Value Customers with Multiple Products 
The aim of this is to find customers with at least one funded savings plan and one funded investment plan, sorted by total deposits. 
To solve this, I aimed to summarize each user's funding activity across both savings and investment plans. The goal was to find customers with a funded savings and investment plan, as well as calculate the total amount deposited since inception.

I used the plans_plan table to count the number of funded savings and investment plans, distinguishing between them using the is_regular_savings and is_a_fund flags respectively.
A plan was considered "funded" if it had a positive amount and was not marked as deleted (is_deleted = 0).
To calculate total deposits, I joined the savings_savingsaccount table which acts more like a transaction log, and summed the confirmed_amount for transactions with a status of 'success', 'successful', or 'monnify_success'. This ensured only actual successful inflows were counted.

🚧 Challenges:
1. Inactive or Deleted Plans: Initially, some plans appeared in the dataset but were not active. I resolved this by filtering out plans where is_deleted = 1.
2. Understanding Table Roles: There was some confusion between the amount fields in the plans_plan and savings_savingsaccount tables. After exploration, I understood that plans_plan stores metadata about savings/investment plans, while savings_savingsaccount contains transactional data — hence the latter was used for calculating deposits.
This approach ensures that only active and funded plans are considered, and users are only included in the final result if they have both at least one savings and one investment plan funded. The output is sorted by total_deposit in descending order to highlight high-value customers.

### Assessment_Q2
#### Transaction Frequency Analysis
The objective of this query was to analyze the customer transaction performance by classifying them into frequency categories — High, Medium, or Low, based on how often they transacted over time.

I focused on transactions from the savings_savingsaccount table and linked them with user data from the users_customuser table.

Only successful transactions were considered to ensure accuracy in measuring actual customer activity. This included transactions with statuses 'success', 'successful', and 'monnify_success'. I grouped the query into 2 CTEs to properly capture logic.

1. The first CTE transactions computes the transactional metrics for each of the user.
For each customer, I calculated number of successful transactions, number of active months.

2. The second CTE customers_category assigns a frequency category and keeps the average transactions per month.
Customers were grouped into the buckets:
High Frequency (10+ transactions/month)
Medium Frequency (3–9 transactions/month)
Low Frequency (<3 transactions/month)

3. The last query groups by frequency_category to get the count of customers in each group and the average of their average monthly transaction counts.

Why CTE?
I used a Common Table Expression (CTE) to break the logic into manageable steps:


### Assessment_Q3
#### Account Inactivity Alert
This query identifies inactive savings and investment plans that have not been funded in the past 365 days.

Inactive Savings and Investments:
I used MAX(s.transaction_date) from the savings_savingsaccount table to determine the last time a transaction occurred on both savings and investment plans.
Only plans marked as is_regular_savings = 1 and active (is_deleted = 0) were considered for savings. 
Only plans marked as is_a_fund = 1 for and active (is_deleted = 0) were considered for investments.
Plans were flagged as inactive if their most recent transaction was over a year ago.

🚧 Challenges:
Identifying the most reliable transaction date 

### Assessment_Q4
#### Customer Lifetime Value (CLV) Estimation
To estimate the CLV, my approach was first calculating how long the customers joined Cowrywise using the difference between the current date and the date_joined in the users_customuser table. I also computed the total successful transactions (counting the saving_id), amount(adding confirmed_amount) and average transaction value(amount/no of transactions done) for each customer using the savings_savingsaccount table. 

I got the average monthly transaction frequency using total_transactions / tenure_month(the nunber of months customer got activated).
Then multiplied the monthly frequency by 12 to get an annual transaction frequency.
Multiplied that by the avg_transaction_value to estimate how much value a customer might generate in a year.
Then used the ROUND function for a cleaner output.

#### Check files section for sql files
