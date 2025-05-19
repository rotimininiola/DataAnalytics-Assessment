WITH transactions AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
        COUNT(s.savings_id) AS total_transactions,
        GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 1) AS active_months
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    WHERE s.transaction_status IN ('success','successful', 'monnify_success')
    GROUP BY u.id, customer_name
),

customers_categories AS (
    SELECT 
        customer_id,
        total_transactions,
        active_months,
        ROUND(total_transactions / active_months, 2) AS avg_txn_per_month,
        CASE 
            WHEN total_transactions / active_months >= 10 THEN 'High Frequency'
            WHEN total_transactions / active_months BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM transactions
)

SELECT 
    frequency_category,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month
FROM customers_categories
GROUP BY frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
