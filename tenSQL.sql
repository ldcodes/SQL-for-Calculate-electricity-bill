-- 1
select distinct "customer"."customer_name"
from "customer" , "device" , "ef_log" 
where "customer"."customer_id" = "device"."customer_id" and "device"."device_id" ="ef_log"."device_id" and "ef_log"."state" <> 1 ;


--2
    select b."customer_name"
    from (select "customer"."customer_id"
    from "customer","device"
    where "customer"."customer_id" = "device"."customer_id"
    group by "customer"."customer_id"
    having count("customer"."customer_id")>2) a , "customer" b
		where a."customer_id" = b."customer_id"
;

--3
-- define the time
with x(x) as(
select TO_DATE('2018-08-29','YYYY-MM-DD') from dual
) ,
--1252.668 41.2
-- calacute the money per device per zhangdan
WEIYUEJIN1 as (select "device"."device_id" device_id,"customer"."customer_id" customer_id, "ef_log"."dat" d,
   case 
	 --1 without 
    when months_between(x.x, "ef_log"."deadline" ) <0 then 0
		--2  people 
    when months_between(x.x, "ef_log"."deadline" ) >0 and "device"."type" = 1  then floor(x.x-"ef_log"."deadline"+1)*0.001*("ef_log"."amount")
  --3
		 when months_between(x.x, "ef_log"."deadline" ) >0 and to_char(SYSDATE ,'YYYY') =to_char("ef_log"."deadline",'YYYY') and "device"."type" = 2 then 
		 floor(x.x-"ef_log"."deadline"+1)*0.002*("ef_log"."amount")
		 --4
		 when EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM TO_DATE("ef_log"."deadline",'YYYY-MM-DD')) > 0 and "device"."type" = 2 then  
		(((1+floor(last_day(add_months(trunc("ef_log"."deadline",'y'),11))-"ef_log"."deadline")))*0.02+
		floor(x.x-last_day(add_months(trunc("ef_log"."deadline",'y'),11)))*0.003)*("ef_log"."amount")
		
   end amount
from  "ef_log" ,"device" ,"customer" ,x
where "ef_log"."device_id"="device"."device_id" and"customer"."customer_id"= "device"."customer_id" and "ef_log"."ef_id" not in (select "ef_id" from "ef_log" where "ef_log"."pay_date" is not null and "ef_log"."pay_date" < x.x) 

),
-- first result  base + add1+add2+weiyue-balance
-- sum the base + add1+add2+weiyue
A as (
select sum("ef_log"."amount"+WEIYUEJIN1.amount) a
from "ef_log" ,WEIYUEJIN1,x
where  "ef_log"."device_id"=WEIYUEJIN1.device_id 
--and "ef_log"."ef_id" not in (select "ef_id" from "ef_log" where "ef_log"."pay_date" is not null and "ef_log"."pay_date" < x.x)) 
),
-- sum the balance 
C as (
select sum("customer"."balance") c
from "customer"),
-- second result
B as (
select sum("pay_log"."pay_amount") b
from "pay_log"
where to_char("pay_log"."pay_time",'yyyy-mm-dd') = '2018-08-22' ) ---2018-03-22
------
--select * from inyear ;

select A.a-c.c yongshou,B.b shishou
from A ,B ,c;

--4
select distinct "customer"."customer_name"
from "customer" , "device" , "ef_log"
where "customer"."customer_id" = "device"."customer_id" and "device"."device_id" = "ef_log"."device_id"
and "ef_log"."state" <>1 and months_between(current_date,"ef_log"."deadline")>6 ;


--5

-- define the time
with x(x) as(
--select TO_DATE('2018-08-25','YYYY-MM-DD') from dual
select sysdate from dual
) ,
-- calacute the money
WEIYUEJIN1 as (select "device"."device_id" device_id,"customer"."customer_id" customer_id, "ef_log"."dat" d,
   case 
	 --1 without 
    when months_between(x.x, "ef_log"."deadline" ) <0 then 0
		--2  people 
    when months_between(x.x, "ef_log"."deadline" ) >0 and "device"."type" = 1  then floor(x.x-"ef_log"."deadline"+1)*0.001*("ef_log"."amount")
  --3
		 when months_between(x.x, "ef_log"."deadline" ) >0 and to_char(SYSDATE ,'YYYY') =to_char("ef_log"."deadline",'YYYY') and "device"."type" = 2 then 
		 floor(x.x-"ef_log"."deadline"+1)*0.002*("ef_log"."amount")
		 --4
		 when EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM TO_DATE("ef_log"."deadline",'YYYY-MM-DD')) > 0 and "device"."type" = 2 then  
		(((1+floor(last_day(add_months(trunc("ef_log"."deadline",'y'),11))-"ef_log"."deadline")))*0.002+
		floor(x.x-last_day(add_months(trunc("ef_log"."deadline",'y'),11)))*0.003)*("ef_log"."amount")
			
   end amount
from  "ef_log" ,"device" ,"customer" ,x
where "ef_log"."device_id"="device"."device_id" and"customer"."customer_id"= "device"."customer_id" and "ef_log"."ef_id" not in (select "ef_id" from "ef_log" where "ef_log"."pay_date" is not null and "ef_log"."pay_date" < x.x) 
)

select "customer"."customer_id", sum("ef_log"."amount"+WEIYUEJIN1.amount-"customer"."balance") fee
from "ef_log" , "customer" , "device" ,WEIYUEJIN1
where "ef_log"."device_id" = "device"."device_id" and "customer"."customer_id" = 
"device"."customer_id" and WEIYUEJIN1.device_id="device"."device_id" and "ef_log"."state" <> '1' 
group by "customer"."customer_id"
;

--6
with C as (
select "customer"."customer_id" customer_id, sum("ef_log"."use_amount") amount
from "device" ,"ef_log" ,"customer"
where "customer"."customer_id" = "device"."customer_id" and "device"."device_id" = "ef_log"."device_id" and to_char("ef_log"."dat",'YYYY-MM') ='2018-07'
GROUP BY "customer"."customer_id"
order by amount desc )
--
select *
from C
where rownum< 4
£»

--7

with A(time,Pnumber) as (
select to_char("pay_log"."pay_time",'DD')  ,count(distinct "customer"."customer_id") 
from "pay_log" , "device" ,"customer"
where to_char("pay_log"."pay_time",'MM')= '03' and "device"."device_id"="pay_log"."device_id"--03/08
and "customer"."customer_id" ="device"."customer_id" 
group by  to_char("pay_log"."pay_time",'DD') )
select *
from A
where A.pnumber >= all (
select A.pnumber
from A);

--8

select "device"."type" ,count(distinct "customer"."customer_id") c_number
from "device" , "customer"
where "device"."customer_id" = "customer"."customer_id"
group by "device"."type"
order by c_number desc;

--9

select "bank"."bank_name" ,A.times
from (select "pay_log"."bank_id" ,count(distinct"serial_id") times
from "pay_log"
where to_char("pay_time",'yyyy-mm')='2018-08'
group by "pay_log"."bank_id" 
order by  times desc) A,"bank"
where A."bank_id"="bank"."bank_id";

--10

--find new device
with A as ( select "device"."device_id" device_id
from "em_log" ,"device"
where "device"."device_id"= "em_log"."device_id"
group by "device"."device_id"
having months_between(SYSDATE,min("em_log"."dat")) <6)

select distinct "customer"."customer_name"
from A , "device" ,"customer"
where "device"."device_id"= A.DEVICE_ID and "device"."customer_id"= "customer"."customer_id"

;