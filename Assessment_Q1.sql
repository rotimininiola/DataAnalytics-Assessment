WITH user_funding_summary AS (
    SELECT 
        p.owner_id AS id, 
        CONCAT(u.first_name, ' ', u.last_name) AS name, 
        -- counting active funded savings plans
        COUNT(DISTINCT CASE 
            WHEN p.is_regular_savings = 1 
                AND is_deleted = 0
                AND p.amount > 0 
            THEN p.id 
        END) AS savings_count,
         -- counting active funded investment plans
        COUNT(DISTINCT CASE 
            WHEN p.is_a_fund = 1 
                AND is_deleted = 0
                AND p.amount > 0 
            THEN p.id 
        END) AS investment_count,
        ROUND(SUM(
            CASE 
                WHEN s.transaction_status IN ('success', 'successful', 'monnify_success') 
                THEN s.confirmed_amount 
                ELSE 0 
            END
        ) / 100.0, 2) AS total_deposit
    FROM plans_plan p
    JOIN savings_savingsaccount s ON s.plan_id = p.id
    JOIN users_customuser u ON u.id = p.owner_id
    GROUP BY p.owner_id, name
)

SELECT *
FROM user_funding_summary
WHERE savings_count >= 1 
  AND investment_count >= 1
ORDER BY total_deposit DESC;









