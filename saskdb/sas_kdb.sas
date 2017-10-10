*方式1:通过odbc;
/*1.安装kdb+ ODBC驱动程序(http://code.kx.com/q/interfaces/q-server-for-odbc/)，通过控制面板“ODBC 数据源(32 位)”创建ODBC名称: 127.0.0.1:5001
  2.启动d:\q\w32\q.exe -p 5001 -U d:/q/qusers
 */
 
*在sas程序里生成q脚本，执行并取得结果;
data _null_;
file "d:\q\execfromsas.q";  *假设q安装在d:\q;
put "
t:([]a:`a`b`c;b:1 2 3); 
f:{ update c:b*2 from t };
";
*q语句前面不要空格;
run;

proc sql;
   connect to ODBC as kdb(datasrc="127.0.0.1:5001" user=kdbuser password=kdbpassword);
   execute( \l execfromsas.q ) by kdb;
   create table t  as select * from connection to kdb(select * from t);
   create table tt as select * from connection to kdb(f(1));
   disconnect from kdb;
quit;


*方式2:通过url;
filename foo url 'http://127.0.0.1:5001/a.csv?select%20from%20t%20where%20b>1'  user='kdbuser' pass='kdbpassword' DEBUG ;
/*URL中空格必须以%20表示*/
data _null_;
   infile foo ;
   input ;
   put _infile_;
run;
data t;
   infile foo delimiter=',' DSD;
   if _n_ > 1 then do;
   	 input a $ b;
   end;
run;
