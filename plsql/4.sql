CREATE OR REPLACE
PROCEDURE total (bank IN NUMBER,pay_count in number ,pay_amount in number,r out VARCHAR2)
--, time IN DATE)
IS
time date :=to_date('2018-08-30','YYYY-MM-DD');
cursor p_log is select * from "pay_log" where "pay_log"."bank_id"=bank and to_char("pay_log"."pay_time",'YYYY-MM-DD') = to_char(time,'YYYY-MM-DD') and "pay_type"<3;
cursor m_log is select "pay_log"."serial_id" from "pay_log" where "pay_log"."bank_id"=bank and to_char("pay_log"."pay_time",'YYYY-MM-DD') = to_char(time,'YYYY-MM-DD') and "pay_type" <3 GROUP BY "pay_log"."serial_id";
e_count number :=0 ;
e_amount number :=0 ;
bank_legial number := 0;
pay_count_legial number := 0;
pay_amount_legial number := 0;
check_t date :=sysdate;
BEGIN
r:= 'check date :'||to_char(check_t,'YYYY-MM-DD');
  
   for log in p_log loop
	    --e_count := e_count+1;
			e_amount := log."pay_amount"+e_amount;
	 END loop;
	 for log in m_log loop
	    e_count := e_count+1;
			--e_amount := log."pay_amount"+e_amount;
	 END loop;
	-- DBMS_OUTPUT.PUT_LINE('count over');
	 if e_count = pay_count and e_amount = pay_amount then--consistent
	    DBMS_OUTPUT.PUT_LINE(to_char(time,'YYYY-MM-DD')||' bank '||bank||' conisitent');
			r :=to_char(time,'YYYY-MM-DD')||' bank '||bank||' conisitent'||chr(10);
			insert into "total_account" ("bank_id","check_date","bank_count","bank_amount","enterprise_count","enterprise_amount","is_consistent") values(bank,check_t,pay_count,pay_amount,e_count,e_amount,1);
			
	 else --unconsistent
	    DBMS_OUTPUT.PUT_LINE(to_char(time,'YYYY-MM-DD')||' bank '||bank||' non-conisitent');
	   insert into "total_account" ("bank_id","check_date","bank_count","bank_amount","enterprise_count","enterprise_amount","is_consistent") values(bank,check_t,pay_count,pay_amount,e_count,e_amount,0);
		 r := r||'not consistent' ||' bank count '||pay_count||'bank amount'|| pay_amount||' e count'||e_count||' e_amount '|| e_amount;
	     if e_count <> pay_count then 	 
			      DBMS_OUTPUT.PUT_LINE('total count not conisitent ,bank '|| pay_count||'  enterprise '||e_count);
						
	      end if;
				
	     if e_amount <> pay_amount then
	         DBMS_OUTPUT.PUT_LINE('total amount not conisitent ,bank '|| pay_amount||'  enterprise '||e_amount);	
			 END if;
			 
		-- insert into "error_account" ("check_time","bank_id","serial_id","customer_id","bank_amount","enterprise_amount",type)values(check_t,bank,);
		
	 end if;
	-- routine body goes here, e.g.
	-- DBMS_OUTPUT.PUT_LINE('Navicat for Oracle');
END;