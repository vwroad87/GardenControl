TACHYON
[~
\
\  FONA Celullar Test Routines
\  dp  20151227-1900 V0.1
\  dp  20151228-1200 V0.2  got sms sending and reading
\  dp  20151229-2200 V0.3  rewrote commands using strings, paramaterized cmsg 
\  dp  20160906-1700 v0.4  added commands, tried to compile and run with Juno but no joy,  stable on 2.4 hum?  
\  dp  20160907-1300 v0.5  debugging routines, work in progress
\  dp  20160907-2030 v0.6  small module to integrate with gardencontrol
\  dp  20160909-0930 v0.7  added start stop routines:  gofona stopfona to control the RX task FONA.TASK
\  dp  20160909-0930 v0.8  minor bug fix

FORGET FONA.fth

pub FONA.fth   PRINT" FONA Test V0.8 dp  20160909-1000 " ;

--- setup
#9600 SERBAUD                           --- nice and slow 
#P2 == TX                               --- my pin, device RX
#P20 == RX                              --- my pin, device TX

--- timers
TIMER fonatmr       --- timer for pacing of reading FONA TX pin
LONG ?fona          --- flag for task 

--- serial task rx stuff 
WORD rxrd,rxwr                          --- create receive buffer, indexes
#128 == rxsize
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
pub celp ' celpout uemit W! 
;  

pub cmrdchr  ( char -- )   --- read sms message by index char
--- AT+CMGR
  celp
  --- send msg cmd
  " AT+CMGR=" PRINT$ 
  EMIT CR
  CON
;


\ Read Fona TX to the console
pub rfona ( - )                  --- read the fona and output
  fonatmr TIMEOUT?               --- run state machine now ?
    IF
      10 fonatmr TIMEOUT        --- reset time and run every 10 seconds 
      GET232                     --- display
      EMIT
  THEN
;

pub crst   --- reset device
  celp
  " ATZ" PRINT$ CR
  CON
;

--- 0 Received unread messages
--- 1 Received read messages
--- 2 Stored unsent messages
--- 3 Stored sent messages
--- 4 All messages 
pub clst ( cmd -- )  --- list messages
  celp               --- revector to FONA RX, our TX pin
  " AT+CMGL=" PRINT$ 
  .                  --- output cmd
  CR
  CON                --- back to the console
;

pub cbat   --- show battery status
  celp
  " AT+CBC"  PRINT$ CR
  CON
;

pub cech ( ON|OFF -- ) --- set echo
  celp
  IF "1" ELSE  "0" THEN
  " ATE" PRINT$ EMIT CR
  CON
;

pub cnum   ( -- )   --- request device number
   celp
  " AT+CNUM" PRINT$ CR
  CON
;

pub cpwr   ( -- )   --- request device number
  celp
  " AT+CPOWD=1"  PRINT$ CR
  CON
;

pub ctxt (  -- )   --- set sms command mode to text 
  celp
  --- set text mode 
  " AT+CMGF=1" PRINT$  CR
  100 ms
  CON
;

pub cpdu (  -- )   --- set sms command mode to pdu
  celp
  --- set pdu mode 
  " AT+CMGF=0" PRINT$  CR
  100 ms
  CON
;

pub cdela ( -- ) --- delete all messages
 cpdu --- set into pdu mode
 celp 
 " AT+CMGDA=6"  PRINT$ CR
 CON
;

pub cmsg ( " message" " number" -- )   --- send sms message
  ctxt   --- set into text mode
  --- Write Command 1) If text mode (+CMGF=1): +CMGS=<da>[, <toda>] <CR>text is entered <ctrl-Z/ESC> 
  celp
  --- send msg cmd
  " AT+CMGS=" PRINT$
  --- da destination address
  34 EMIT   --- send a: "
  PRINT$   --- send the destination address  
  34 EMIT   --- send a: "
  CR
  #500 ms    --- wait for reply
  --- message body
  PRINT$   --- send the message
  --- end message
  ^Z EMIT   CR
  CON
;

\   This routine starts the system
pub gofona
  OFF ?fona !    --- set task flag to run
  ." Starting FONA module " CR
  ' FONA.TASK  7 RUN   --- start the rs232 task
  #500 ms
  ' rfona keypoll W!   
  CR ." Reset FONA: " crst       --- reset fona
  #500 ms    --- delay
  CR ." Echo Off: " OFF cech   --- command echo off fona
  10 ms
  CR ." Text Mode: " ctxt       --- set into text mode
;

pub stopfona
  ." Stopping FONA module " CR
  ON ?fona !   --- set task flag to stop
  0 keypoll W!
;

]~
END


