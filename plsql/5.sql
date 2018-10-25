CREATE OR REPLACE
PROCEDURE detail (bank in number ,check_time in VARCHAR2 ,r out VARCHAR2)
IS
cursor bank_log(t date) is select * from "transfer_log" where "bank_id"=bank and TO_CHAR(t,'YYYY-MM-DD')=TO_CHAR("transfer_log"."time",'YYYY-MM-DD') order by "transfer_log"."serial_id";
cursor en_log(t date) is select "pay_log"."serial_id" ,sum("pay_log"."pay_amount") from "pay_log" where "bank_id"=bank and TO_CHAR(t,'YYYY-MM-DD')=TO_CHAR("pay_time",'YYYY-MM-DD') GROUP BY "pay_log"."serial_id" order by "pay_log"."serial_id";
time date;
bank_legial number ;
b_log "transfer_log"%ROWTYPE;
--e_log "pay_log"%ROWTYPE;
e_ser number;
e_amount number ;
c_id number;
b_count number :=0;
e_count number :=0;

BEGIN
   --DBMS_OUTPUT.PUT_LINE('1 :');
  DBMS_OUTPUT.ENABLE(buffer_size => null) ;
  time := TO_DATE(check_time,'YYYY-MM-DD');
	DBMS_OUTPUT.PUT_LINE('time :'||to_char(time,'YYYY-MM-DD'));
	select count(*) into bank_legial from "bank" where "bank_id"=bank;
	if bank_legial <1 then
	   DBMS_OUTPUT.PUT_LINE('no this bank :'||bank);
  else
	   
		 open bank_log(time);
		 open en_log(time);
		 fetch bank_log into b_log;
		 fetch en_log into e_ser ,e_amount;
		    LOOP
				 exit when bank_log %notfound or en_log%notfound;
		 --WHILE bank_log % found and en_log%found LOOP
		    b_count := b_count+1;
				e_count := e_count+1;
        if b_log."serial_id"= e_ser then
				   if b_log."transfer_amount" = e_amount then
					    DBMS_OUTPUT.PUT_LINE(b_log."serial_id"||' is consistent 1');				
					 else --amount is not 
					 -- insert into "error_account" 
					    DBMS_OUTPUT.PUT_LINE(b_log."serial_id"||','||e_ser ||' is not consistent 2' ||b_log."transfer_amount"||' '||e_amount);
							r := r||b_log."serial_id"||','||e_ser ||' is not consistent 2  ';
					    insert into 
							"error_account"("check_time","bank_id","serial_id","customer_id","bank_amount","enterprise_amount","type")                        
							values(time,b_log."bank_id",b_log."serial_id", b_log."customer_id",b_log."transfer_amount",e_amount,1);
					 END if;
					 
					 fetch bank_log into b_log ;
		       fetch en_log into e_ser ,e_amount;
					 
				elsif  b_log."serial_id"> e_ser then
				    --bank lack a log
				    DBMS_OUTPUT.PUT_LINE(e_ser||' is not consistent 3');
						r :=r||e_ser||' is not consistent ';
				   insert into 
					 "error_account"("check_time","bank_id","serial_id","customer_id","bank_amount","enterprise_amount","type")                       
					 values(time,bank,e_ser, b_log."customer_id",null,e_amount,2);
					-- fetch bank_log into b_log ;
		       fetch en_log into e_ser ,e_amount;
				else 
				 	  --en lack a log
				    DBMS_OUTPUT.PUT_LINE(b_log."serial_id"||' is not consistent 4');
						r :=r||b_log."serial_id"||' is not consistent ';
				   insert into 
					 "error_account"("check_time","bank_id","serial_id","customer_id","bank_amount","enterprise_amount","type")                     
					 values(time,b_log."bank_id",b_log."serial_id", b_log."customer_id",b_log."transfer_amount",null,3);
					 fetch bank_log into b_log ;
		      -- fetch en_log into e_log;
				end if;
				
       END LOOP;

    if bank_log % found then
		    -- bank 
		    loop 
				   exit when bank_log %notfound ;
				   fetch bank_log into b_log ;
		       DBMS_OUTPUT.PUT_LINE(b_log."serial_id"||' is not consistent 5');
					 r :=r||b_log."serial_id"||' is not consistent 5';
				   insert into 
					 "error_account"("check_time","bank_id","serial_id","customer_id","bank_amount","enterprise_amount","type")                      
					 values(time,b_log."bank_id",b_log."serial_id", b_log."customer_id",b_log."transfer_amount",null,3);
				   
				 end loop;
		elsif en_log % found then
		  --
		   loop 
			      exit when en_log %notfound ;
				    fetch en_log into e_ser ,e_amount;
		      --DBMS_OUTPUT.PUT_LINE(b_log."serial_id"||' is not consistent');
					  select "customer_id" into c_id from "pay_log" where "serial_id"=e_ser GROUP BY "customer_id";
				    DBMS_OUTPUT.PUT_LINE(e_ser||' is not consistent 6');
						r:=r||e_ser||' is not consistent 6';
				   insert into 
					 "error_account"("check_time","bank_id","serial_id","customer_id","bank_amount","enterprise_amount","type")                        
					 values(time,bank,e_ser, c_id,null,e_amount,2);
					  
				 end loop;
		 END if;--if bank_log % found then
		 
	 end if;--bank_legial <1 then
    close en_log;
		close bank_log;
		DBMS_OUTPUT.PUT_LINE('bank '||b_count||' e '||e_count);
exception
when others then
r:='input error';DBMS_OUTPUT.PUT_LINE('may the time error');
dbms_output.put_line(sqlerrm);
dbms_output.put_line(sqlcode);

END;