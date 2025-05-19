WITH customer_transactions AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
        COUNT(s.savings_id) AS total_transactions,
        SUM(COALESCE(s.confirmed_amount, 0) * 0.001) AS total_confirmed_amount,
        -- Calculates the average transaction value
        (SUM(COALESCE(s.confirmed_amount, 0) * 0.001) / COUNT(s.savings_id)) AS avg_transaction_value
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    -- Filters to only successful transactions using case-insensitive pattern
    WHERE LOWER(s.transaction_status) REGEXP 'success'
    GROUP BY 1
)

SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    -- Estimates customer lifetime value (CLV)
    ROUND((total_transactions / NULLIF(tenure_months, 0)) * 12 * avg_transaction_value, 2) AS estimated_clv
FROM customer_transactions
ORDER BY estimated_clv DESC;
