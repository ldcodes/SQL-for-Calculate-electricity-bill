CREATE OR REPLACE
PROCEDURE chongzheng (c_id IN NUMBER, serial IN NUMBER,r out VARCHAR2)
IS
cursor c_log is select * from "pay_log" where "pay_log"."serial_id"=serial and tod("pay_log"."pay_time")= tod(sysdate);
total_money number := 0 ;-- pay for device and balance
ef_id number;--souce customer id 
--souce_cid number;
--error_cid number;
exist1 number := 0;
exist2 number := 0;
--next_serial number := 0;
pay_result number ;
--old_balance number;
able number := 0;
t date ;
bank number;
BEGIN
   -- the serial id , bank id ,customer id ,balance are same;
   -- the time will been recorded
    t := sysdate;
	-- routine body goes here, e.g.
	-- DBMS_OUTPUT.PUT_LINE('Navicat for Oracle');
	-- seral pay_log  find ef_id 
	--judge the legality
	 select count(*) into exist1 from "customer" where "customer"."customer_id"=c_id;
	 select count(*) into exist2 from "pay_log" where "pay_log"."serial_id"=serial;
	 select  "pay_log"."bank_id" into bank from "pay_log" where "pay_log"."serial_id"=serial    
			     GROUP BY "pay_log"."bank_id";
	 
	 --DBMS_OUTPUT.PUT_LINE('bank id' ||bank);
	 if exist1 = 1 and exist2 >0 then 
	 
	     --find the souce customer id ,bank id
	     
			 
			 for log in c_log loop
			    able := able+1;
	        ef_id := log."ef_id";
					--select "device"."customer_id" into error_cid from "device" where "device"."device_id"=log."device_id";
					--DBMS_OUTPUT.PUT_LINE('error id' ||to_char(tod(log."pay_time"),'YYYY-mm-dd'));
			    
					--old_balance := log."balance" + old_balance;
			 --customer_id ,"pay_time","pay_amount","bank_id","serial_id","pay_type","device_id","ef_id","aim_customer_id"
			    if log."pay_type"=1 then -- pay for device
					  total_money := log."pay_amount"+total_money;
			      insert into "pay_log" 
			        ("customer_id","pay_time","pay_amount","bank_id","serial_id","pay_type","device_id","ef_id","aim_customer_id","balance")
			         values(c_id,t,-log."pay_amount",log."bank_id",log."serial_id",3,log."device_id",log."ef_id",null,-log."balance");	 
				     update "ef_log" set "state" = 0,"paid_fee"=0,"pay_date"=null where "ef_log"."ef_id"=log."ef_id";
					  
					/*elsif log."pay_type"=2 then -- pay for balance
					   total_money := log."pay_amount"+total_money;
						 insert into "pay_log" 
			        ("customer_id","pay_time","pay_amount","bank_id","serial_id","pay_type","device_id","ef_id","aim_customer_id")
			         values(souce_cid,t,-log."pay_amount",log."bank_id",log."serial_id",4,null,null,error_cid);
				       
						 update "customer" set "balance"= "balance"-log."pay_amount" where "customer_id"=error_cid;
					 */
					end if;
			 
	    end loop;
	
	    if able = 0 then
	       DBMS_OUTPUT.PUT_LINE('time out ,can not ');
				 r :='time out ,can not ';
			else
			  -- total_money := total_money + old_balance ;
			  -- version 1
	      -- pay(souce_cid,d_id,total_money,pay_result,serial);
				
				--version 2
				  r:= 'successful ';
				   update "customer" set "balance" = total_money+"balance"  where "customer_id"=c_id;
	         insert into "pay_log" 
			        ("customer_id","pay_time","pay_amount","bank_id","pay_type","device_id","ef_id","aim_customer_id","serial_id")
			         values(c_id,t,total_money ,bank,3,null,null,c_id,serial);
				   
	    end if;
	    
	 
	 ELSE
	 
	   DBMS_OUTPUT.PUT_LINE('no this device or this pay log');
	   r:='no this device or this pay log';
	 end if;
	 
exception
when others then
DBMS_OUTPUT.PUT_LINE('something error');
r:='input error';
--dbms_output.put_line(sqlerrm);
--dbms_output.put_line(sqlcode);	 
END;