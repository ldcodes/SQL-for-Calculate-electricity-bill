CREATE OR REPLACE
procedure query(c_id in "customer"."customer_id"%type , v_amount out "customer"."balance"%type)
IS
isexist number :=0 ;
device_number number:= 0 ;
balance number := 0;
cursor log_cursor is select "device"."device_id","device"."type","ef_log"."amount","ef_log"."deadline","ef_log"."dat" from "ef_log" , "device" where "ef_log"."state" = 0 and "device"."customer_id"= c_id and "device"."device_id"= "ef_log"."device_id";

fee number := 0;-- base+add1+add2
weiyue number := 0;
total number := 0;
now date;
begin

now := tod(sysdate);
v_amount := 0;
select count(*) into isexist from "customer" where "customer"."customer_id"= c_id;

if isexist = 0 then
dbms_output.put_line('no this people');
v_amount:= -1;
else  select count(*) into device_number from "device" where "device"."customer_id"=c_id ;
  if device_number = 0 then 
    dbms_output.put_line('the people has no device');
		v_amount:=-2;
  else 
	select "customer"."balance" into balance from "customer" where "customer"."customer_id"=c_id ;
	for log in log_cursor loop
	dbms_output.put_line(to_char(log."deadline",'yyyy-mm-dd'));
	  fee := log."amount";
	  weiyue := 0;		 
		--deadline
		 if now-log."deadline" >0  then
		  -- personal
		   if log."type" = '01' then 
			 
			    weiyue := floor(now -tod(log."deadline") +1)*0.001 *fee ;		
		        --dbms_output.put_line(weiyue||'aa '||fee||' '||(fee+weiyue));			
			 --non - personal and in one year
			 elsif to_char(now ,'YYYY') = to_char(log."deadline",'YYYY') then
			    weiyue := floor(now-tod(log."deadline")+1)*0.002*(log."amount");
					dbms_output.put_line(weiyue||'xx');
			 else 
			   weiyue :=  (floor((1+floor(last_day(add_months(trunc(log."deadline",'y'),11))-log."deadline")))*0.002+
		    floor(now-last_day(add_months(trunc(log."deadline",'y'),11)))*0.003)*(log."amount");
				
			dbms_output.put_line(to_char(floor(now-last_day(add_months(trunc(log."deadline",'y'),11))))||'  '||(1+floor(last_day(add_months(trunc(log."deadline",'y'),11))-tod(log."deadline")))|| '  '||weiyue);
				--to_date(to_char(log."deadline",'yyyy-mm-dd'),'yyyy-mm-dd')
			  end if;--if log."type" = '01' then 
			 
		 end if ;--if now-log."deadline" <0  then
		 v_amount := v_amount + fee + weiyue ;
	end loop;
	 if v_amount > balance then
    v_amount := v_amount - balance ;
		else
		v_amount :=0;
		end if;
 end if;--device_number = 0 then 
 dbms_output.put_line('customer id ='|| c_id || ' amount '||v_amount);
end if;--if isexist = 0 then

exception
when others then
DBMS_OUTPUT.PUT_LINE('input error');
dbms_output.put_line(sqlerrm);
dbms_output.put_line(sqlcode);


END;