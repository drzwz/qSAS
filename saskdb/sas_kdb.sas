*��ʽ1:ͨ��odbc;
/*1.��װkdb+ ODBC��������(http://code.kx.com/q/interfaces/q-server-for-odbc/)��ͨ��������塰ODBC ����Դ(32 λ)������ODBC����: 127.0.0.1:5001
  2.����d:\q\w32\q.exe -p 5001 -U d:/q/qusers
 */
 
*��sas����������q�ű���ִ�в�ȡ�ý��;
data _null_;
file "d:\q\execfromsas.q";  *����q��װ��d:\q;
put "
t:([]a:`a`b`c;b:1 2 3); 
f:{ update c:b*2 from t };
";
*q���ǰ�治Ҫ�ո�;
run;

proc sql;
   connect to ODBC as kdb(datasrc="127.0.0.1:5001" user=kdbuser password=kdbpassword);
   execute( \l execfromsas.q ) by kdb;
   create table t  as select * from connection to kdb(select * from t);
   create table tt as select * from connection to kdb(f(1));
   disconnect from kdb;
quit;


*��ʽ2:ͨ��url;
filename foo url 'http://127.0.0.1:5001/a.csv?select%20from%20t%20where%20b>1'  user='kdbuser' pass='kdbpassword' DEBUG ;
/*URL�пո������%20��ʾ*/
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
