--check a view of file
select * from fash limit 5;
-- check for missing value from this file
select count(*) missing_values from fash
    where User_ID is null or Product_ID is null 
    or Product_Name is null or Brand is null or Category is null 
    or Price is null or Rating is null or Color is null or Size is null;
-- check the number of unique user in this file
select count(distinct User_ID) tot_num_user from fash;
-- check the number of unique product in this file
select count(distinct Product_ID) tot_num_product from fash;
-- check the number of unique brand in this file
select COUNT(distinct Brand) tot_num_Brand from fash;
-- check the average price of each product
select Category,Product_Name, round(avg(Price), 2) avg_price from fash
  group by Category, Product_Name
  order by Category;
  
--check the highest rated product in each category and Product_Name
with data as (select Category, Product_Name Product, User_ID, Rating
FROM fash),
    data1 as (Select * , row_number()over(partition by Category,Product 
                                          order by Rating DESC) Ranking FROM data)
select Category,Product, User_ID, Rating Highest_Rating FROM data1 where Ranking = 1;
--check For each brand, what is the mean price of products in their most common category
with data1 AS (select Brand, Category, count(Category) AS Total,
        row_number() over(partition by Brand order by count(Category)DESC) Ranking
        FROM fash
        GROUP BY Brand, Category),
data2 AS (select Brand, Category, Ranking
        from data1
        where Ranking = 1
        order by Brand),
data3 AS (select DISTINCT Brand, Category,(sum(price)/count(price)) Mean_Price from fash
        group by Brand, Category
        ORDER BY Brand)
select data2.Brand, data2.Category, ROUND(data3.Mean_Price,1) Mean_of_Price FROM data2
    LEFT JOIN data3 ON
    data2.Brand = data3.Brand 
    AND
    data2. Category = data3.Category;

--What is the average price of products purchased by users who have bought products from at least three different brands?
with data1 AS (select DISTINCT User_ID, COUNT(Brand) Brand FROM fash
    group by User_ID 
    HAVING Brand>= 3
    ORDER BY Brand),
data2 AS (select User_ID, ROUND(avg(Price), 1) avg_Price FROM fash
        group by User_ID
        ORDER BY User_ID)
select data1.User_ID User, data2.avg_Price, data1.Brand FROM data1
left join data2 on data1.User_ID = data2.User_ID;

--How many products have a rating higher than the average rating of their brand?
with data1 AS (select DISTINCT Brand, ROUND(avg(Rating),2) Avg_Rating 
               from fash
    GROUP BY fash.Brand
    ORDER BY Avg_Rating DESC),
data2 AS (select DISTINCT Brand, Product_Name Product, 
          ROUND(avg(Rating),2) Rating_Product FROM fash
    GROUP BY fash.Brand, Product
    ORDER BY fash.Brand, Product)
select data2.Brand, COUNT(data2.Product) Total_Product from data2
    left join data1
    ON data1.Brand = data2.Brand
    where data2.Rating_Product > data1.Avg_Rating
    GROUP BY data2.Brand
    order by Total_product DESC;

--For each user, find the product with the highest rating and the lowest rating they have purchased.
with data1 AS (select User_ID, Brand, Product_Name, Rating,
        RANK() OVER(PARTITION BY User_ID ORDER BY Rating) Rating_Rank from fash),
    data2 AS (select User_ID, 
           Product_Name||"-"||Brand||"-"||
                   ROUND(rating,2) Product_Lowes_rate 
            FROM data1
        where Rating_Rank = 1),
    data3 AS (select User_ID, Brand, Product_Name, Rating,
        RANK() OVER(PARTITION BY User_ID ORDER BY Rating DESC) Rate_Rank from fash),
    data4 AS (select User_ID, 
            Product_Name||"-"||Brand||"-"||
                   ROUND(Rating,2) Product_Highest_rate 
            FROM data3
        where Rate_Rank = 1)
    select data2.*, data4.Product_Highest_rate FROM data2
        JOIN data4
        ON data2.User_ID = data4.User_ID
        ORDER BY User_ID;

--Which users have purchased products from every brand within their favorite category
with data1 AS (select user_id, Brand, Category from fash
            order by user_id),
    data2 AS (select user_id, Count(DISTINCT Brand) Total_Brand from data1 GROUP BY user_id),
    data3 AS (select * FROM data2
        where Total_Brand = (Select COUNT(DISTINCT Brand) FROM fash) ORDER BY user_id),
    data4 AS (select data3.user_id, data1.Category, COUNT(Data1.Category) Num_Category 
              FROM data3
                left join data1 on data1.user_id = data3.user_id
                group by data3.user_id, Category
                order by data3.user_id),
    data5 AS (select data4.*, 
        ROW_NUMBER() Over(partition by data4.user_id order by Num_Category DESC) Ranking
        FROM data4),
    data6 AS (Select * FROM data5 where Ranking=1 order by data5.user_id)
select data6.user_id users,data3.Total_Brand, data6.Category Most_Category
from data3 join data6 on data3.user_id = data6.user_id 
order by users;

--How many users have purchased products in all available colors?
--(checking color for each product)--> are every products put difference color?
select Distinct Product_Name, COUNT(DISTINCT Color) Num_Color FROM fash
        group by Product_Name order by Product_Name;
--execution
with data1 AS (select User_ID, Product_Name, Color from fash),
    data2 AS (select User_ID, Count(DISTINCT Color) Total_Color FROM data1
    Group by User_ID
    Order by Total_Color),
    data3 AS (select * from data2 where Total_Color = (select count(distinct Color) 
                                                       FROM fash)
        order by User_ID)
select COUNT(User_ID) Total_User FROM data3;

--What is the average price of products in each size category 
with data1 AS (select DISTINCT Product_Name, Size, Price from fash
order by Product_Name, Size DESC, Price DESC)
select Product_Name, Size, round(Avg(Price),2) avg_price from data1
    group by Product_Name, Size
    Order by Product_Name,avg_price DESC;