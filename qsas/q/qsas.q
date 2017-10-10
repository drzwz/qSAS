//产生随机行情，通过Socket传送到SAS

\d .zz
//=============================读取动态库=============================
// ref: http://itfin.f3322.org/opt/cgi/wiki.pl/KdbPlus
dl:@[{(`:qx 2:(`loadlibrary;1))[]};`;(enlist`)!enlist(::)];    // .zzdl: ...
sockopen:{[x]if[3>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x]};  
sockclose:{[x]if[not type[x] in (-5h;-6h;-7h);:-999];.zz.dl.sockclose[x]};
sockcheck:{[x]if[not type[x] in (-5h;-6h;-7h);:-999];.zz.dl.sockcheck[x]};
tcpsend:{[x;y]if[not type[x] in (-5h;-6h;-7h);:-999];if[not abs[type[y]] in (4h;10h);:-998];.zz.dl.tcpsend[x;y]};  //.zz.tcpsend[h;"abcd\r\n"] .zz.tcpsend[h;0x1234]  
tcprecv:{[x]if[not type[x] in (-5h;-6h;-7h);:-999];.zz.dl.tcprecv[x]};
getsockbuf:{[x].zz.dl.getsockbuf[x]};
setsockbuf:{[x].zz.dl.setsockbuf[x]};

tcpconnasync:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 1]};    //1:TCP client async
tcplistenasync:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 2]};  //2:TCP server async
tcpconn:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 3]};         //3:TCP client sync              //.zz.tcpconn(`127.0.0.1;5000)
tcpdisc:{[x]if[not type[x] in (-5h;-6h;-7);:-999];.zz.dl.sockclose[x]};
tcplisten:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 4]};       //4:TCP server sync
udplisten:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 0]};       //0:UDP
//get sina syms list
getsinafutsyms:{ht:.Q.hg`$"http://finance.sina.com.cn/iframe/futures_info_cff.js";
 :{update exsym:?[ex in`DCE`SHF;lower exsym;exsym],sym:(`$string[exsym],'".",/:string[ex]) from select ex,exsym,name from delete from x where (exsym in`NULL`SHF`DCE`CZC`CFE)or(name=`$"\272\317\324\274")or(name like "*\301\254\320\370")}{update ex:fills?[exsym in`SHF`DCE`CZC`CFE;exsym;`] from x} 
 flip`name`exsym!flip{$[x like "*new Array(*";{`$"," vs {ssr[x;"\"";""]} -2 _ (2+x ? "(")_ x} x;x like "*\311\317\306\332\313\371*";`SHF;x like "*\264\363\311\314\313\371*";`DCE;x like "*\326\243\311\314\313\371*";`CZC;x like "*\326\320\275\360\313\371*";`CFE;`NULL]}each  ";" vs ht};  
 
\d .

upd:()!();
taq:([sym:`$()]date:`date$();time:`time$();prevclose:`real$();open:`real$();high:`real$();low:`real$();close:`real$();volume:`real$();openint:`real$();bid:`real$();bsize:`real$();ask:`real$();asize:`real$());
taq2:taq2_0:`sym`time xcols update time:`real$() from delete date from 0#0!taq;
//=============================期货合约代码转换公式=============================
sub_syms:`;
getcfsyms:{symsmap::1!select exsym,sym from {update {`$string[x]_2}each exsym from x where ex=`CZC} .zz.getsinafutsyms[];sub_syms::exec sym from select sym from symsmap;};   //from sina

upd[`taq]:{`taq upsert d::`sym`date`time`prevclose`open`high`low`close`volume`openint`bid`bsize`ask`asize!x;
  d[`time]:`real$0.001*`long$d`time;`taq2 insert d[`sym`time`prevclose`open`high`low`close`volume`openint`bid`bsize`ask`asize]; 
  };
-1 "\n\n     SIMULATION: trades and quotes are rand numbers....\n\n";
getcfsyms[];
pubtaq:{if[0=count taq2;:()];0N!(.z.T;count taq2);
	if[0<sas:.zz.tcpconn[(`127.0.0.1;5566)];r:.zz.tcpsend[sas;raze{raze(`byte$10#string[x`sym],10#" "),reverse each 0x0 vs/: value `sym _ x} each taq2];if[r>0;taq2::taq2_0];.zz.tcpdisc[sas]];
	};
pubinterval:"J"$first .z.x,enlist "1000";  //发布间隔，毫秒
lastpubtime:.z.D +`time$pubinterval xbar `long$.z.T;
.z.ts:{ 
   ii:0;do[count sub_syms;upd[`taq] raze(sub_syms[ii];.z.D;.z.T),11?100e;ii+:1];
   if[pubinterval<=`long$`time$.z.P -lastpubtime; pubtaq[];lastpubtime::.z.D +`time$pubinterval xbar `long$.z.T;];
   };    
\t 500
