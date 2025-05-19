WITH inactive_savings AS (
    SELECT 
        p.id AS plan_id,
        'Savings' AS type,
        p.owner_id AS owner_id,
        MAX(s.transaction_date) AS last_transaction_date
    FROM plans_plan p
    JOIN savings_savingsaccount s on s.plan_id = p.id
    WHERE p.is_regular_savings = 1 
    -- this ensures the savings are still active
	  AND p.is_deleted = 0
    GROUP BY p.id, p.owner_id
    HAVING MAX(s.transaction_date) < CURDATE() - INTERVAL 365 DAY
),

inactive_investments AS (
    SELECT 
        p.id AS plan_id,
        'Investment' AS type,
        p.owner_id AS owner_id,
        -- the last time an investment contribution was made
        MAX(s.transaction_date) AS last_transaction_date
    FROM plans_plan p
    left join savings_savingsaccount s on s.plan_id = p.id
    WHERE p.is_a_fund = 1 
    -- this ensures the investments are still active
      AND p.is_deleted = 0
    GROUP BY p.id, p.owner_id
    HAVING MAX(s.transaction_date) < CURDATE() - INTERVAL 365 DAY
)

SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
FROM (
    SELECT * FROM inactive_savings
    UNION ALL
    SELECT * FROM inactive_investments
) AS combined_accounts
ORDER BY inactivity_days DESC;
