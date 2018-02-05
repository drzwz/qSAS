options nosource nonumber nodate nonotes nomprint error=10;
*策略宏;
%macro TS();
        %put 策略…………;
        *这里连接数据库，数据处理，策略处理等，注意本宏的运行时间;

%mend;

*按本地时间遍历;
%macro ScanByTime();
        %let tm0 = %sysfunc(time());
        %let dt0 = %sysfunc(DHMS(%sysfunc(date()),%sysfunc(hour(&tm0)),%sysfunc(minute(&tm0)),0));  *把秒置为0;
        %do %while (1);
                %let dt1 =  %sysfunc(datetime());
                %let tm1 =  %sysfunc(time());
                %*只在指定的交易时段运行，根据需修改;
                %let cond= %sysevalf(   (&tm1. > %sysfunc(HMS( 9, 0,0)) and &tm1. < %sysfunc(HMS(11,30,0)) ) or
                                        (&tm1. > %sysfunc(HMS(13,30,0)) and &tm1. < %sysfunc(HMS(15, 0,0)) ) or
                                        (&tm1. > %sysfunc(HMS(21, 0,0)) and &tm1. < %sysfunc(HMS(24, 0,0)) ) or
                                        (&tm1. >=%sysfunc(HMS( 0, 0,0)) and &tm1. < %sysfunc(HMS(02,30,0)) ) );
                %if(&cond) %then %do;
                %*这里为1分钟运行一次，需要根据需要修改;
                %let cond= %sysevalf( &dt1 - &dt0 >= 60  );  
                %if(&cond) %then %do;
                        %let dt0 = &dt1;
                        %put %sysfunc(time(),time.) 运行策略代码...;
                        %TS();
                        %put %sysfunc(time(),time.) 运行策略代码结束;
                %end;
                %end;
        %end;
%mend ScanByTime;

%ScanByTime();

options source;   *根据情况修改;
