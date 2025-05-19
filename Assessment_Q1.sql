WITH user_funding_summary AS (
    SELECT 
        p.owner_id AS id, 
        CONCAT(u.first_name, ' ', u.last_name) AS name,   
        -- Count of active funded savings plans
        COUNT(DISTINCT CASE 
            WHEN p.is_regular_savings = 1 
            -- check for active saving plans 
                AND p.is_deleted = 0
                AND p.amount > 0 
            THEN p.id 
        END) AS savings_count,
        
        -- Count of active funded investment plans
        COUNT(DISTINCT CASE 
            WHEN p.is_a_fund = 1 
            -- check for active investment plans 
                AND p.is_deleted = 0
                AND p.amount > 0 
            THEN p.id 
        END) AS investment_count,
        
        -- Sum of successful deposits using regex and COALESCE for null handling
        ROUND(SUM(
            CASE 
                WHEN LOWER(s.transaction_status) REGEXP 'success' 
                THEN COALESCE(s.confirmed_amount, 0) 
                ELSE 0 
            END
        ) / 100.0, 2) AS total_deposit

    FROM plans_plan p
    JOIN savings_savingsaccount s ON s.plan_id = p.id
    JOIN users_customuser u ON u.id = p.owner_id
    GROUP BY 1, 2
)

SELECT *
FROM user_funding_summary
WHERE savings_count >= 1 
  AND investment_count >= 1
ORDER BY total_deposit DESC;






