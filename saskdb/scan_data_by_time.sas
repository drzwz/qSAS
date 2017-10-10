options nosource nonumber nodate nonotes nomprint error=10;
*���Ժ�;
%macro TS();
        %put ���ԡ�������;
        *�����������ݿ⣬���ݴ������Դ���ȣ�ע�Ȿ�������ʱ��;

%mend;

*������ʱ�����;
%macro ScanByTime();
        %let tm0 = %sysfunc(time());
        %let dt0 = %sysfunc(DHMS(%sysfunc(date()),%sysfunc(hour(&tm0)),%sysfunc(minute(&tm0)),0));  *������Ϊ0;
        %do %while (1);
                %let dt1 =  %sysfunc(datetime());
                %let tm1 =  %sysfunc(time());
                %*ֻ��ָ���Ľ���ʱ�����У��������޸�;
                %let cond= %sysevalf(   (&tm1. > %sysfunc(HMS( 9, 0,0)) and &tm1. < %sysfunc(HMS(11,30,0)) ) or
                                        (&tm1. > %sysfunc(HMS(13,30,0)) and &tm1. < %sysfunc(HMS(15, 0,0)) ) or
                                        (&tm1. > %sysfunc(HMS(21, 0,0)) and &tm1. < %sysfunc(HMS(24, 0,0)) ) or
                                        (&tm1. >=%sysfunc(HMS( 0, 0,0)) and &tm1. < %sysfunc(HMS(02,30,0)) ) );
                %if(&cond) %then %do;
                %*����Ϊ1��������һ�Σ���Ҫ������Ҫ�޸�;
                %let cond= %sysevalf( &dt1 - &dt0 >= 60 and %sysfunc(minute(&dt1))-%sysfunc(minute(&dt0)) >= 1 );  *������һ����ʱ;
                %if(&cond) %then %do;
                        %let dt0 = &dt1;
                        %put %sysfunc(time(),time.) ���в��Դ���...;
                        %TS();
                        %put %sysfunc(time(),time.) ���в��Դ������;
                %end;
                %end;
        %end;
%mend ScanByTime;

%ScanByTime();

options source;   *��������޸�;