package ojdbc;

import java.sql.*;
import java.util.Scanner;


public class Test {

	private  static Connection conn  ;
	private static Scanner in = new Scanner(System.in);
	public static void main(String[] args) throws ClassNotFoundException, SQLException {
		// TODO Auto-generated method stub
	    double m =0;
	    Test t = new Test();
        Class.forName("oracle.jdbc.driver.OracleDriver");        
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521/orcl","scott","computer");
        while(true) {
        	t.show();
        	t.p();
        }
        

        //conn.close();

	}
	
	public void show() {
		System.out.println("----------------------------");
		System.out.println("1.query the fee");
		System.out.println("2.pay");
		System.out.println("3.chognzheng ");
		System.out.println("4.check total account");
		System.out.println("5. check the detial");
		System.out.println("----------------------------");
	}
	public void p() {
		System.out.println("input number to select function");
		
		int input = in.nextInt();
		switch(input) {
		case 1:
			 try {
				query();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			break;			
		case 2:
			pay();
			break;
		case 3:
			chongzheng();
			break;
		case 4:
			total();
			break;
		case 5:
			detail();
			break;
		default:
				System.err.println("input error");
		}
		
	}

	private void detail() {
		// TODO Auto-generated method stub
		int bank,count;
		double amount;
		String s,t;
		System.out.println("input the bank id");
		bank = in.nextInt();
		System.out.println("input the check-time");
		t = in.next();
		String str="{call SCOTT.DETAIL(?,?,?)}";
		
		try {
			CallableStatement  cs = conn.prepareCall(str);
			cs.setInt(1,bank);
	        cs.setString(2, t);
	       
	        cs.registerOutParameter(3,Types.VARCHAR);	    
	        cs.execute();
	        s =cs.getString(3);
	        System.err.println(s);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	

	private void total() {
		// TODO Auto-generated method stub
		// (bank IN NUMBER,pay_count in number ,pay_amount in number)
		int bank,count;
		double amount;
		String s;
		System.out.println("input the bank id");
		bank = in.nextInt();
		System.out.println("input the record count");
		count = in.nextInt();
		System.out.println("input the total amount");
		amount= in.nextDouble();
		String str="{call SCOTT.TOTAL(?,?,?,?)}";
		
		try {
			CallableStatement  cs = conn.prepareCall(str);
			cs.setInt(1,bank);
	        cs.setInt(2,count);	
	        cs.setDouble(3, amount);
	        cs.registerOutParameter(4,Types.VARCHAR);	    
	        cs.execute();
	        s =cs.getString(4);
	        System.err.println(s);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private void chongzheng() {
		// TODO Auto-generated method stub
		///PROCEDURE chongzheng (c_id IN NUMBER, serial IN NUMBER)
		int cid,ser;
		String s;
		System.out.println("input the customer id");
		cid = in.nextInt();
		System.out.println("input the serical id");
		ser = in.nextInt();
		String str="{call SCOTT.CHONGZHENG(?,?,?)}";
		
		try {
			CallableStatement  cs = conn.prepareCall(str);
			cs.setInt(1,cid);
	        cs.setInt(2,ser);	       
	        cs.registerOutParameter(3,Types.VARCHAR);	    
	        cs.execute();
	        s =cs.getString(3);
	        System.err.println(s);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
	}

	private void pay() {
		// TODO Auto-generated method stub
		int cid,did;
		double payamount;
		String s;
		System.out.println("input the customer id");
		cid = in.nextInt();
		//System.out.println("input the device id");
		//did = in.nextInt();
		System.out.println("input the amount of money");
		payamount = in.nextInt();
		String str="{call SCOTT.PAY(?,?,?,?)}";
		//(c_id  ,d_id,m_amount,pay_result out number,serial)
		CallableStatement cs;
		try {
			cs = conn.prepareCall(str);
			cs.setInt(1,cid);
	        //cs.setInt(2,did);
	        cs.setDouble(2,payamount);
	        cs.registerOutParameter(3,Types.VARCHAR);
	        cs.setInt(4,-1);
	        cs.execute();
	        s =cs.getString(3);
	        System.err.println(s);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        
	}

	private void query() throws SQLException {
		// TODO Auto-generated method stub
		int id;
		double amount;
		System.out.println("input the customer id");
		id = in.nextInt();
		String str="{call SCOTT.QUERY(?,?)}";
		CallableStatement cs=conn.prepareCall(str);
        cs.setInt(1,id);
        cs.registerOutParameter(2,Types.NUMERIC);
        cs.execute();
        amount =cs.getInt(2);
         if (amount == -1)
        	System.err.println("no this people");
        
         else if (amount ==-2)
        	System.err.println("the people has no  device");
         else 
        	System.err.println("customer :"+id+" arrears "+amount);
        	
        }
        
	}


