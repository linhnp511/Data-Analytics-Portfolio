select * from customers;
select * from sales;
select * from [segment scores];

with RFM_base
as 
(
    select c.customer_name as CustomerName,
        datediff(day, max(s.order_date), convert(date, GETDATE())) as Recency_Value,
        count(distinct s.order_date) as Frequency_Value,
        round(sum(s.sales),2) as Monetary_Value
    from sales as s
    join customers as c
    on s.customer_id = c.customer_id
    group by c.customer_name
),
RFM_Score
as
(
    select *,
        ntile(5) over (order by Recency_Value desc) as R_Score,
        ntile(5) over (order by Frequency_Value asc) as F_Score,
        ntile(5) over (order by Monetary_Value asc) as M_Score
    from RFM_base 
),
RFM_Final
as
(
    select *,
        concat(R_Score, F_Score, M_Score) as RFM_Overall
    from RFM_Score 
)
select f.*, s.Segment
from RFM_Final f 
join [segment scores] s 
on f.RFM_Overall = s.Scores;