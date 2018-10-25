CREATE OR REPLACE
PROCEDURE pay (c_id in "customer"."customer_id"%type, 
--,d_id in "device"."device_id"%type ,
m_amount in "ef_log"."amount"%type,pay_result out VARCHAR2,serial in "pay_log"."serial_id"%type)
is 
--cursor c_log is select *  from "ef_log" where "ef_log"."device_id"=d_id and "ef_log"."state"=0 order by "ef_log"."dat" ;
cursor c_log is select "ef_log"."amount","ef_log"."dat","ef_log"."device_id" ,"ef_log"."ef_id" from "ef_log" ,"device" where  "ef_log"."state"=0 and "device"."device_id" ="ef_log"."device_id" and "device"."customer_id"= c_id order by "ef_log"."dat" ;
money number ;-- input + balance
--mouths char ;--log the 
balance number ; -- before pay
t_amount number; -- each log need amount
customer_id number := c_id;
bank_id number :=1; 
old_balance number :=0;

weiyue number :=0;
log_count number :=0;
ser number ;
c_id_legial number :=0;
d_id_legial number :=0;
this_balance number :=0;
t date ;
b number;
p number;
d_id  number;
BEGIN

-- all use a serial number ,pay by transfe and balance last update balance
  t := (sysdate);
  if serial =-1 then
   select   DEVICE_SEQ.nextval  into ser from sys.dual ;
	else
	  ser := serial;
  end if;
	DBMS_OUTPUT.PUT_LINE('input :customer id '||c_id||' device id '|| d_id||' money paid '||m_amount||' serial '||ser);
	select count(*) into c_id_legial from "customer" where "customer"."customer_id"=c_id ;
	select count(*) into d_id_legial from "device" where "device"."device_id"=d_id ;
	if c_id_legial < 1  then
	   DBMS_OUTPUT.PUT_LINE('no this customer or device ');
		 pay_result:='no this customer or device ';
	   return ;
	END if;
	if serial = -1 and m_amount <0 then
	   DBMS_OUTPUT.PUT_LINE('amount can not less than 0');
		 pay_result:='amount can not less than 0';
	   return ;
	end if;

 
 
 pay_result := 0;
 -- whoes balance ?????
 select "customer"."balance" into balance from "customer" where "customer"."customer_id"=c_id;
 money := m_amount+balance;
 old_balance := balance;
 for log in c_log loop
 log_count := log_count+1;
 d_id :=log."device_id";
   ---weiyuejin 
	  weiyu(log."ef_id",weiyue);
	 -- total 
	 t_amount := log."amount"+weiyue ;
	 
	 --if can afford
   if t_amount<money then
     
	   update "ef_log" 
		 set "state" =1 ,"pay_date" = sysdate ,"paid_fee"=t_amount
		 where "ef_log"."ef_id"=log."ef_id";
		 
		 --update the money
		 money :=money-t_amount;
		 
		 -- cal this balance
		 if money > balance then 
		       this_balance := 0;
		 else
		      this_balance := balance -money;
					balance := balance;
		 end if;
		 DBMS_OUTPUT.PUT_LINE('this balance '||this_balance||' balance '||balance|| ' money '||money);
		 
		 -- uninitial bank_id  serial
	  insert into "pay_log"("customer_id","pay_time","pay_amount","pay_type","bank_id","device_id","ef_id","serial_id","pay_log"."balance") values(customer_id,t,t_amount-this_balance,1,bank_id,d_id,log."ef_id",ser,this_balance);
		
		
		 DBMS_OUTPUT.PUT_LINE('success to pay for device '||d_id||' date :'||to_char(log."dat",'YYYY-MM') ||' fee '||t_amount);
		 --pay_result := 1;
		 
			pay_result:=CONCAT(pay_result ,'   success to pay for device '||d_id||' date :'||to_char(log."dat",'YYYY-MM') ||' fee '||t_amount||' ser '||ser);	 
		 else -- can not afford
		 DBMS_OUTPUT.PUT_LINE('fail to pay for device '||d_id||' date :'||to_char(log."dat",'YYYY-MM'));
		 DBMS_OUTPUT.PUT_LINE('need '||t_amount||' ,only have :'||money);
		 --exit when can not continue
		 pay_result:='fail to pay for device '||d_id||' date :'||to_char(log."dat",'YYYY-MM')||'need '||t_amount||' ,only have :'||money;
		 exit  ;
		 
		end if ;--if log."amount"<money then

 end loop;
 
 if log_count = 0 then
 dbms_output.put_line('no log need to pay');
 pay_result:='no log need to pay';
 end if;
 -- update the balance
  if money>0 then
	 DBMS_OUTPUT.PUT_LINE('the balance now is '||money);
	 
	 if money > old_balance then
	        p := money - old_balance;
					b := old_balance ;
	 else
	        p := 0;
					b := money ;
	 end if;
   update "customer" set "balance" = money where "customer_id"=c_id;
	 insert into "pay_log" 
			        ("customer_id","pay_time","pay_amount","bank_id","pay_type","device_id","ef_id","aim_customer_id","serial_id","balance")
			         values(c_id,t,p,bank_id,2,null,null,c_id,ser,b);
  end if;
	
  DBMS_OUTPUT.PUT_LINE('success to pay for '||log_count||'record ');

exception

when others then
DBMS_OUTPUT.PUT_LINE('something error');
dbms_output.put_line(sqlerrm);
dbms_output.put_line(sqlcode);

END;