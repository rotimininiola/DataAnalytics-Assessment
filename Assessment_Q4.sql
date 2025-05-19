WITH customer_transactions AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
        COUNT(s.savings_id) AS total_transactions,
        SUM(s.confirmed_amount * 0.001) AS total_confirmed_amount,
        -- sums the transaction amount by the number of transactions to get the average transaction value
        (SUM(s.confirmed_amount * 0.001) / COUNT(s.savings_id)) AS avg_transaction_value
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    -- filters to only successful transactions
    WHERE s.transaction_status IN ('success', 'successful', 'monnify_success')
    GROUP BY u.id
)

SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    -- Projects the average number of monthly transactions over a full 12-month period, multiplies the annual transaction frequency by the average value per transaction to estimate total value generated per year
    ROUND((total_transactions / NULLIF(tenure_months, 0)) * 12 * avg_transaction_value, 2) AS estimated_clv
FROM customer_transactions
ORDER BY estimated_clv DESC;
