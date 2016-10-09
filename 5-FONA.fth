TACHYON
[~
\
\  FONA Celullar Routines
\  A small module that sends SMS texts messages on AdaFruit's FONA GMS Module using a TING Account Card 

\ --------------------------------------------------------------------------------------------------------------------------
\   USAGE
\     FONA.GO    --- use this to init the module, start the RX form FONA module Task, hardcoded COG 7
\     FONA.STOP  --- stop the task with this
\     FONA.READ  --- use this to read the FONA module return buffer to console, call by main module keypoll... 
\     FONA.SEND ( " text message to send" " 1234561111" -- ) send SMS message, results can be read with FONA.READ 
\                                                            to the console or revectored 
\ --------------------------------------------------------------------------------------------------------------------------

\  dp  20151227-1900 V0.1
\  dp  20151228-1200 V0.2  got sms sending and reading
\  dp  20151229-2200 V0.3  rewrote commands using strings, paramaterized SEND 
\  dp  20160906-1700 v0.4  added commands, tried to compile and run with Juno but no joy,  stable on 2.4 hum?  
\  dp  20160907-1300 v0.5  debugging routines, work in progress
\  dp  20160907-2030 v0.6  small module to integrate with gardencontrol
\  dp  20160909-0930 v0.7  added start stop routines:  gofona stopfona to control the RX task FONA.TASK
\  dp  20160909-0930 v0.8  minor bug fix
\  dp  20160910-2330 v1.0  rewrote controlling words in object syntax and documented usage, fixed FONA.READ dropped nulls
\  dp, kty 20161005-1700 v1.0a PINS set for P555 board

FORGET FONA.fth

pub FONA.fth   PRINT" FONA Test V1.0a  20161005-1700 " ;

--- setup, pins
#9600 SERBAUD                           --- nice and slow 
#P7 == TX                               --- my pin, device RX
#P8 == RX                               --- my pin, device TX
--- vars
LONG ?fona                              --- task flag

--- serial task rx stuff 
WORD rxrd,rxwr                          --- create receive buffer, indexes
#64 == rxsize
rxsize BYTES buf232                     
10 LONGS stack232 

\ Buffer data from the RS232 port - nothing else
pub FONA.TASK
    stack232 SP! !SP                     \ init data stack to 0, assign stack to this task
    #9600 SERBAUD                        \ how fast are we going
    rxrd W~ rxwr W~ buf232 rxsize ERASE  \ clear rxrd, rxwr and erase buf232
    BEGIN                                \ run loop until ?fona false
       RX SERIN  
       rxwr W@                          \ get serial byte, fetch rxwr buf232 index( -- 0 datadr )
       rxsize 1- AND buf232 + C!        \ compute buf232 addr and write data to buffer
       rxwr W++                         \ increment buffer pointer
    ?fona @ UNTIL 
;

\ You can read the buffered data with this
pub GET232 ( -- ch|0 )
     rxrd W@ rxsize 1- AND rxwr W@ rxsize 1- AND <>   \ compute if the buffer is empty
     IF
       rxrd W@ rxsize 1- AND buf232 + C@
       rxrd W++
     ELSE 0
     THEN
;
	
--- redirect routine
pub celpout  ( char -- )
  TX SEROUT
;

--- redirect output to fona
pub CELP ' celpout uemit W! 
;  

pub cmrdchr  ( char -- )   --- read sms message by index char
--- AT+CMGR
  CELP
  --- send msg cmd
  " AT+CMGR=" PRINT$ 
  EMIT CR
  CON
;


\ Read Fona TX to the console
pub FONA.READ ( -- )                         --- read the fona and output
    GET232                                   --- display
    DUP 0= IF DROP  ELSE EMIT THEN           --- don't tie up console with nulls
;

pub CRST
  CELP
  " ATZ" PRINT$ CR
  CON
;

pub CBAT ( -- bat_status)          --- show battery status  1|0 charging , % bat, millivolts  0, 67, 3890
  CELP
  " AT+CBC"  PRINT$ CR
  CON
;

pub CECH ( ON|OFF -- ) --- set echo
  CELP
  IF "1" ELSE  "0" THEN
  " ATE" PRINT$ EMIT CR
  CON
;

pub CNUM   ( -- )   --- request device number
   CELP
  " AT+CNUM" PRINT$ CR
  CON
;

pub CPWR   ( -- )   --- request device number
  CELP
  " AT+CPOWD=1"  PRINT$ CR
  CON
;

pub CTXT (  -- )   --- set sms command mode to text 
  CELP
  --- set text mode 
  " AT+CMGF=1" PRINT$  CR
  100 ms
  CON
;

pub CPDU (  -- )   --- set sms command mode to pdu
  CELP
  --- set pdu mode 
  " AT+CMGF=0" PRINT$  CR
  100 ms
  CON
;

pub CDELA ( -- ) --- delete all messages
 CPDU --- set into pdu mode
 CELP 
 " AT+CMGDA=6"  PRINT$ CR
 CON
;

pub FONA.SEND ( " message" " number" -- )   --- send sms message
  CTXT   --- set into text mode
  --- Write Command 1) If text mode (+CMGF=1): +CMGS=<da>[, <toda>] <CR>text is entered <ctrl-Z/ESC> 
  CELP                                          --- revector TX pin
  " AT+CMGS=" PRINT$                            --- send msg cmd
  34 EMIT PRINT$  34 EMIT                       --- send the destination address  
  CR
  #500 ms                                       --- wait for reply
  PRINT$                                        --- send the message
  ^Z EMIT   CR                                  --- end message
  CON                                           --- back to CONsole
;

---   This routine starts the system
pub FONA.GO
   OFF ?fona !                               --- set task flag to run
  ." Starting FONA Module " CR
  ' FONA.TASK  7 RUN                         --- start the rs232 task
   #500 ms
   CR ." Reset FONA: " 
   CRST
   #500 ms                                   --- delay
   CR ." Echo Off: " 
   OFF CECH                                  --- command echo off fona
   10 ms
   CR ." Text Mode: " CTXT                   --- set into text mode
;

pub FONA.STOP 
  ." Stopping FONA Module" CR
  ON ?fona !   --- set task flag to stop
;

]~
END


