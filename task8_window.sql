SELECT * FROM global.`global superstore`;
SELECT COUNT(*) AS total_rows
FROM global.`global superstore`;
SHOW COLUMNS FROM global.`global superstore`;
SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS Total_Sales
FROM global.`global superstore`
GROUP BY
    `Customer ID`,
    `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 5000;
SELECT
    "Customer Name",
    SUM(Sales) AS Total_Sales
FROM global.`global superstore`
GROUP BY "Customer Name";
SELECT
    Region,
    `Customer Name`,
    Total_Sales,
    ROW_NUMBER() OVER (
        PARTITION BY Region
        ORDER BY Total_Sales DESC
    ) AS Sales_Rank
FROM (
    SELECT
        Region,
        `Customer Name`,
        SUM(Sales) AS Total_Sales
    FROM global.`global superstore`
    GROUP BY
        Region,
        `Customer Name`
) AS customer_sales
ORDER BY
    Region,
    Sales_Rank;
SELECT
    Region,
    `Customer Name`,
    Total_Sales,

    RANK() OVER (
        PARTITION BY Region
        ORDER BY Total_Sales DESC
    ) AS Rank_With_Gaps,

    DENSE_RANK() OVER (
        PARTITION BY Region
        ORDER BY Total_Sales DESC
    ) AS Rank_No_Gaps

FROM (
    SELECT
        Region,
        `Customer Name`,
        SUM(Sales) AS Total_Sales
    FROM global.`global superstore`
    GROUP BY
        Region,
        `Customer Name`
) AS customer_sales
ORDER BY
    Region,
    Total_Sales DESC;
SELECT
    `Order Date`,
    Sales,
    SUM(Sales) OVER (
        ORDER BY `Order Date`
    ) AS Running_Total_Sales
FROM global.`global superstore`
ORDER BY `Order Date`;
SELECT DISTINCT `Order Date`
FROM global.`global superstore`
LIMIT 10;
SELECT
    `Order Date`,
    STR_TO_DATE(`Order Date`, '%d-%m-%Y') AS Parsed_Date
FROM global.`global superstore`
LIMIT 10;
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(`Order Date`, '%d-%m-%Y'),
            '%Y-%m'
        ) AS Month,
        SUM(Sales) AS Total_Sales
    FROM global.`global superstore`
    GROUP BY
        DATE_FORMAT(
            STR_TO_DATE(`Order Date`, '%d-%m-%Y'),
            '%Y-%m'
        )
)
SELECT
    Month,
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY Month) AS Prev_Month_Sales,
    ROUND(
        (Total_Sales - LAG(Total_Sales) OVER (ORDER BY Month))
        / LAG(Total_Sales) OVER (ORDER BY Month) * 100, 2
    ) AS MoM_Growth_Percent
FROM monthly_sales
ORDER BY Month;
WITH product_sales AS (
    SELECT
        Category,
        `Product Name`,
        SUM(Sales) AS Total_Sales
    FROM global.`global superstore`
    GROUP BY
        Category,
        `Product Name`
),
ranked_products AS (
    SELECT
        Category,
        `Product Name`,
        Total_Sales,
        DENSE_RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Sales DESC
        ) AS Sales_Rank
    FROM product_sales
)
SELECT
    Category,
    `Product Name`,
    Total_Sales,
    Sales_Rank
FROM ranked_products
WHERE Sales_Rank <= 3
ORDER BY Category, Sales_Rank;


