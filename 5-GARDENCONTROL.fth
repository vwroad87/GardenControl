\   Garden Control Firmware to manage the Ebb Flow Cycles of the System
\   dp V1.0
\   dp 150511  11:00  replaced all indenting with TABs
\   dp 150516  15:30  update light logic for day night cycles, fixed bug
\                     added logic to retry adc readings 3 times if value (tanklevel) greater than 14
\   dp, ky  151107 15:00 Changed the name of this module and file
\                        to GardenControl.fth
\   dp 160815         modifying code for new DLVR-L30D pressure sensor, Tachyon module and P8 board type
\                     ready for testing, set defaults for new sensor  0.80
\   dp 160824         updated to use DS3232M RTC Ram to save and restore runtime params  0.91
\   dp 160826         cleaned up code and comments, reduced memory allocation to 22 bytes for runtime struct
\   dp 160828         added Peter's techniques,  clean up the code more, ready for live testing again v.93
\   dp 160830         Peter basically rewrote this rountine cleaning up my sloppy use of Forth
\                     I'm still learning, got a great lesson sharing my code and how to debug stack issues
\                     This code needs clean up and proper annotation but seems really stable
\                     Checkin at V1.0,  Thanks to all

\                     
TACHYON
[~

IFNDEF DLVR-L30D.fth
     CR PRINT" !!!  This module requires a DLVR-L30D.fth  !!!          "
!!!
}

FORGET GARDENCONTROL.fth
pub  GARDENCONTROL.fth   PRINT" Garden Control PBJ-8 160830 1000 V1.0          " ;


\ : TP		PRINT" <TP @" DEPTH . PRINT" >" ;

IFNDEF !POLLS
pub !POLLS polls 16 ERASE keypoll W~ ;
pub KEY! ( keycode -- )		delim 13 + C! ;

}
IFNDEF .TIMERS
pub .TIMERS
      SPACE CLKFREQ ttint / ." ticks = 1/" 0 PRINTDEC
      ."  runtime = " runtime @ 0 PRINTDEC
 	timers W@
 	BEGIN
 	  DUP $FF >
 	WHILE
 	  CR DUP .WORD 	  ." : "
 	  DUP 1- >NAME DUP PRINT$ LEN$ #20 SWAP - SPACES
 	  DUP @ 6 PRINTDEC ." ms "
 	  ." =" DUP @ .LONG
 	  ."  L" DUP 6 + W@ .WORD
 	  SPACE DUP 4 + W@ IF ." ALARM=" DUP 4 + W@ >NAME PRINT$ THEN
 	  6 + W@ --- fetch the link to the next timer
 	REPEAT
 	DROP
 	;
pub .TASKS ( -- \ List tasks )
	8 0 DO
	  I TASK 2+ C@ DUP
 	    IF   .INDEX I TASK W@ ?DUP
 	      IF >NAME DUP PRINT$ BL SWAP LEN$ - SPACES
 	      ELSE PRINT" IDLE" #28 SPACES
 	      THEN
	    THEN
	  I COGID = DUP
	    IF   .INDEX PRINT" CONSOLE" #25 SPACES THEN
	  OR IF I TASK DUP W@ .WORD SPACE 2+ 6 ADO I C@ .BYTE SPACE LOOP THEN
	  LOOP
	;

}



{ ***** equipment I/O assignments ********* }
--- pins named with * prefix to indicate PIN CONSTANT plus avoid conflicts with upper/lower cases
#P18 == *flow		--- flow pump
#P17 == *ebb		--- ebb pump
#P19 == *lights		--- uh guess what?
#P16 == *circ		--- circulation pump
#P15 == *alarm		--- alarm pin for FAULTLIGHT  
#P14 == *reset		--- reset pin input

{ ************ constants ************ }
#22 == ramlen        --- ram data length
{ states }
1 == ebbs            --- ebb state
2 == flows           --- flow state
{ fault codes }
1 == WLSF            --- water level sensor fault, lets shutdown if the water level sensor fails
2 == WLHF            --- water level high fault,  are we over flowing the tank
4 == WLLF            ---  water level low fault,   did it all leak out
{ timers }
TIMER  ebbdwell      --- timer to rest at ebb dwell until filling tank to ebb max level
TIMER  flowdwell     --- timer to rest at flow dwell until emptying tank to flow min level  

{ *********** some variables *************** }
WORD now             --- minutes of day now
WORD daybegin        --- minutes of day daytime begins
WORD dayend          --- minutes of day  daytime ends
LONG fdsflag         --- flag for flow dwell setting
LONG edsflag         --- flag for ebb dwell setting
LONG fflag           --- fault flag
LONG lightflag       --- just turn on the fault light once
LONG _log            --- true false to display logging to screen
LONG testm           --- on off flag for setting system in test mode
TIMER statetmr           --- loop counter for keypoll pacing of state machine
TIMER dlvrtmr           --- loop counter for keypoll pacing of calls to PSI.GET from DLVR-L30D.fth module
LONG tanklevel       --- current tank level


pub LOG? ( -- flag ) --- return logging flag on or off
  _log @
;

pub g==   ( -- )    --- turn data logging to the screen on
   ON _log !
   CR CR PRINT" *** Logging On ***  " CR
;

pub g--   ( -- )    --- turn data logging to the screen off
   OFF _log !
   CR CR PRINT" *** Logging Off ***  " CR
;


{ runtime structure stored in DS3232 SRAM }
22 BYTES params     \ allocate memory for #22 bytes
params ORG    
    1 DS HALT      --- halt byte TRUE do not run
    1 DS LSTS      --- Last state running
    1 DS LSTT      --- Last state running time in minutes
    1 DS EBHL      --- Ebb high level  
    1 DS EBLL      --- Ebb low  level ,  pump to EbbHLvl after EbbDwl  time
    1 DS EDWL      --- time to rest after reaching EbbHLvl before testing EbbLLvl and refill in minutes
    1 DS FLHL      --- Flow high level,  pump to FlowLLvl after FlowDwl
    1 DS FLLL      --- Flow low level,  pump to this level when flow cycle
    1 DS FDWL      --- time in min to rest at FlowLLvl before testing FlowHLvl and pumping out to FlowLLvl
    1 DS EBTD      --- Ebb time in minutes during day cycle
    1 DS EBTN      --- Ebb time in minutes during night cycle
    1 DS FLTD      --- Flow time in minute during day cycle
    1 DS FLTN      --- Flow time in minute during night cycle
    1 DS HRSD      --- Hour of day the day cycle starts
    1 DS MIND      --- Mins of day the day cycle starts
    1 DS DURH      --- Duration of day cycle in hours
    1 DS DURM      --- Duration of day cycle in min
    1 DS LSTF      --- Last fault code
    1 DS WLMN      --- low water level  that trips fault code WLLF
    1 DS WLMX      --- high water level that trips fault code WLHF
    1 DS SENF      --- constat reading for water sensor no air fault
    1 DS SENC      --- water sensor calibration



{  new routines to save and restore runtime to RTC ram }

pub SETRUNTIME    \ Write ram/eeprom of RTC from runtime structure
   \ Write runtime structure to ram of RTC 
    @rtc $D0 =		--- only works with DS3232  ram - skips any other RTC with diff address
    IF
      I2CSTART @rtc I2C! $14 I2C!
      params ramlen ADO I C@ I2C! LOOP
      I2CSTOP
    THEN
;

pub GETRUNTIME     \ Read ram/eeprom of RTC and set runtime structure
   \ Read ram of RTC into runtime structure
    @rtc $D0 =
    IF
      I2CSTART @rtc I2C! $14 I2C! I2CREST @rtc 1+ I2C!
      params ramlen ADO 0 I2C@ I C! LOOP 1 I2C@ DROP
      I2CSTOP
    THEN
;

{ show what is in runtime program memory currently }
pub showit
    ramlen 0 DO
        CR I 2* 2* " HALTLSTSLSTTEBHLEBLLEDWLFLHLFLLLFDWLEBTDEBTNFLTDFLTNHRSDMINDDURHDURMLSTFWLMNWLMXSENFSENC" + 4 CTYPE
        PRINT" : " params I + C@ .
    LOOP
; 
 
{ default setup parameters if not set }
--- IFDEF SETDEFAULT
pub setdefaults
    FALSE HALT C!      --- start in running state
    flows LSTS C!      --- last state, in flow day state
    2 LSTT  C!         --- in flow day state for 2 minute
    #80  EBHL C!       --- was 110 Ebb high level, ebb pump fill to this level
    #70  EBLL C!       --- was 105 Ebb low level, turn ebb pump on when at this level to reach EbbHLvl
    2  EDWL C!         --- ebb recycle dwell time in minutes
    #30  FLLL C!       --- was 20 Flow low level, turn flow pump to empy to this level
    #40  FLHL C!       --- Flow high level, turn flow pump back on to empty to FlowLLvl
    2  FDWL C!         --- flow recycle dwell time
    #11  EBTD C!       --- time of day ebb cycle in minutes
    #11  EBTN C!       --- time of night ebb cycle in minutes
    #40  FLTD C!       --- time of day Flow cycle in minutes
    #60  FLTN C!       --- time of night Flow cycle in minutes
    7 HRSD C!          --- hours that day cycle begins
    0 MIND C!          --- minutes that day cycles begins  
    #16 DURH  C!       --- 13 hours of day
    0 DURM  C!         --- and 0 minutes of day
    0 LSTF  C!         --- Last fault code
    #20 WLMN  C!       --- low water level  that trips fault code WLLF
    #90 WLMX  C!       --- high water level that trips fault code WLHF
    #85 SENF   C!      --- set this constat reading with water sensor no air
    0  SENC C!         --- set this water sensor calibration
    3 tanklevel !      --- testing variable for tank level simulation
;
--- }
 
{ display whats in the runtime table }
pub showram
    params ramlen ADO   CR I C@ . LOOP
;
{ word to clear runtime table }
pub clearram
    params ramlen ADO  0   I  C!  LOOP
;

{ get time of day in minutes }
pub MINUTES@ ( -- minutes )    --- get time as minutes
    TIME@ #100 / #100 U/MOD #60 * +
;   

{ check for each minute change }
pub MINUTE? ( -- flg )   --- has a minute elapsed?            
    MINUTES@ now W@ OVER now W! <>
;  

{ set daybegin and dayend to absolute minutes,  adjusts for crossing 2400 hrs boundary }
pub SETTIMES
    HRSD C@ #60 * MIND C@ +  DUP  daybegin W!  --- get day begin time in minutes dup and store a copy
    DURH C@ #60 * DURM C@ +                    --- get duration of day in minutes and add day begin minutes
    +                                          ---   add daybegin to duration for dayend minutes
    DUP #1440 < IF  dayend  W!   ELSE  #1440 -  dayend W!  THEN     --- adjust for crossing 2400 hrs
;

{
  return flag given two vars set in minutes,
  "daybegin" and "dayend" this routine determines if it's day or night
}
pub DAY?   (  -- flg )
    SETTIMES				--- update daybegin and dayend vars
    MINUTES@  daybegin W@ =>		--- start?
    MINUTES@ dayend W@ <=		--- but not end?
    daybegin W@ dayend W@   <		
    IF AND ELSE OR THEN
;

{ show day begin and day end is absolute minutes }
pub showdays
    CR PRINT" day begin: " daybegin W@ .
    CR PRINT" day end  : " dayend W@ .
;

{ Get tank level in tenths of inches, i.e. 50 is 5 inches }
( GetTankLevel )
pub gtl@ (  -- level )
	--- check for test mode, if so just return the tanklevel
	--- PSI@ from DLVR-L30D module returns status, inches, 10ths of inches  
     PSI@ ( -- Status inches tenths )               
	--- convert to tenths                    
     0=  IF
       10 * + ( tenths )         
	--- set to tanklevel long  and return copy
       DUP tanklevel !   
     ELSE ( status inches )
	---  set the sensor flaut code (fix LSTF ! bug )
       SENF C@ LSTF C!    
	--- drop the other returned values from PSI@
       2DROP  FALSE            
     THEN
;



{ tank level set value helper for testing }
pub SetTankLevel ( level -- )                 --- set the global tank level for debug 
    tanklevel  !
;
ALIAS SetTankLevel  stl!                      --- store the tank level to global tanklevel var for debug  




{ helper word to print status of ON or OFF }
pub .ON/OFF ( on/off -- on/off )
	IF PRINT" ON " ELSE PRINT" OFF " THEN CR
;

{ helper word to print level of tank } 
pub .GTL ( -- print tank level ) 
	PRINT" Tank Level  " gtl@ . CR
;


{ helper word to print time left in this state of tank } 
pub .TLS ( -- print time left in this state  ) 
	PRINT" Time Left  " LSTT C@ . PRINT"  Minutes " CR
;

{ equipment action words  }
pub FLOWPUMP  ( ON / OFF -- message to terminal )
    DUP *flow PIN!
    LOG? IF CR .TIME PRINT"  FLOW PUMP  " DUP .ON/OFF .GTL THEN
    DROP    --- if logging is off we need to drop 
;


{ return terminal message of flow pump status }
pub .FLOWPUMP  ( -- terminal message on or off )
    *flow PIN@ CR PRINT" Flow Pump is " .ON/OFF
;

{ control ebbpump }
pub EBBPUMP  ( ON / OFF -- message to terminal )
    DUP *ebb PIN!      --- set the pump on or off
    LOG? IF CR .TIME PRINT"  EBB PUMP " DUP .ON/OFF .GTL  THEN
    DROP    --- if logging is off we need to drop 
;

{ return terminal message of ebb pump status }
pub .EBBPUMP  ( -- terminal message on or off )
    *ebb PIN@ CR PRINT" Ebb Pump is " .ON/OFF
;

{ control circulation pump }
pub CIRCPUMP  ( ON / OFF -- message to terminal )
    DUP *circ PIN!
    LOG? IF .TIME PRINT"  CIRC PUMP " DUP .ON/OFF .GTL THEN
    DROP    --- if logging is off we need to drop 
;

{ control lights }
pub LIGHTS  ( ON / OFF -- message to terminal )
    DUP *lights PIN!      
    LOG? IF .TIME PRINT"  LIGHTS " DUP .ON/OFF THEN
    DROP    --- if logging is off we need to drop 
;


pub ebb? ( -- flg )	LSTS C@ ebbs = ;
--- toggle ebb/flow 
pub ebb/flow		ebb? IF flows ELSE ebbs THEN LSTS C! ;

pub .ebb/flow		IF PRINT" ebb " ELSE PRINT" flow " THEN ;

{ change to next state and set time in this state }
pub NEXTSTATE   ( -- )    				 
    ebb? IF OFF EBBPUMP FLTD ELSE OFF FLOWPUMP EBTD THEN C@ LSTT C! 
    ebb/flow
    LOG? IF 
      CR .TIME PRINT" State Change to " 
        DAY? IF PRINT" day " ELSE PRINT" night " THEN
      ebb? .ebb/flow .TLS .GTL
    THEN
;
    

pub EBBFULL
        OFF EBBPUMP                                --- turn the pump off
        edsflag @ FALSE =                         --- set dwell timer one time
        IF
            TRUE edsflag !                        --- reset ebb the dwell timer flag
            EDWL C@  #60000 * ebbdwell   TIMEOUT   --- set the dwell timer
            LOG? IF CR .TIME PRINT"  Reset EBB Dwell Timer Set Pump OFF " CR .GTL THEN
        THEN
;
pub EBBLOW
	ebbdwell TIMEOUT?                      --- has the dwell timer elapsed?
	IF
          ON EBBPUMP                         --- ebb pump back on
          FALSE edsflag !                   --- reset ebb dwell timer flag
	  LOG? IF CR .TIME PRINT"  EBB Water Low, filling "  CR .GTL THEN
	ELSE
            LOG? IF CR .TIME PRINT"  EBB Water Low, Dwell TIme Left  " ebbdwell @ 1000 U/ . CR .GTL THEN
	THEN
;
pub EBBOK
	LOG? IF CR  PRINT" EBB Water Nominal "  CR .GTL .EBBPUMP .TLS THEN
;
{ run the ebb cycle }
pub EBB
    gtl@   EBHL C@ =>
    IF 
      EBBFULL                                            --- ebb water full ?
    ELSE
    gtl@ EBLL C@  <=					--- ebb water below low level setting ?    
        IF EBBLOW ELSE EBBOK THEN
    THEN
;

pub FLOWLOW
        OFF FLOWPUMP                                          --- turn the pump off
        fdsflag @ FALSE =                                     --- set dwell timer one time
        IF
           TRUE fdsflag !                                     --- reset the dwell flag
           FDWL C@  #60000 * flowdwell TIMEOUT            --- set the dwell timer
            LOG? IF CR .TIME PRINT"  Reset Flow Dwell Timer Reset Pump OFF " CR .GTL THEN
        THEN
;
pub FLOWFULL
	flowdwell TIMEOUT?                         --- has dwell timer elasped?
	IF
          ON FLOWPUMP                            --- flow pump back on
          FALSE fdsflag !                        --- reset flow dwell timer flag  
          LOG? IF CR .TIME PRINT"  Flow Water High, Empyting " CR .GTL THEN
	ELSE
	  LOG? IF CR .TIME PRINT"  FLOW Water High, Dwell TIme Left " flowdwell @ 1000 U/ . CR .GTL THEN
        THEN
;
pub FLOWOK
	LOG? IF CR  PRINT" Flow Water Nominal " CR .FLOWPUMP .GTL .TLS THEN
;
{ run the flow cycle }
pub FLOW
    gtl@ FLLL C@ <=                                           --- tank <= to flow low level?
    IF FLOWLOW                                                       --- flow water empty ?
    ELSE                                  
        gtl@ FLHL C@  =>                               --- flow water above high level setting ?     
        IF FLOWFULL ELSE FLOWOK THEN
    THEN
;

pub REGULARLY
        DAY? LIGHTS            --- control the lights from here, checking everything minute
        SETRUNTIME             --- each minute store running parameters to DS3231 eeprom 
        --- LOG? IF CR PRINT" Storing Parameters to DS3231 EEPROM " 
        --- THEN
        LSTT C@ 1- 0 <=        --- calc last state running time on minute tick check for time out
        IF
            NEXTSTATE          --- change state  reload LSTT/LSTS with correct day night value and state
            LOG? IF CR   .TIME PRINT"  State Changed to " LSTS C@  1 = .ebb/flow THEN
        ELSE  
            LSTT C--           --- still in this state just write LSTT, decrimented minute
            --- LOG? IF CR .TIME PRINT"  Minute Change " THEN
        THEN   
;
pub CONSTANTLY
	ebb? IF 
	  LOG? IF CR .TIME PRINT"  Running State  Ebb " .TLS THEN EBB     
	ELSE
          LOG? IF CR .TIME PRINT"  Running State Flow " .TLS THEN FLOW
        THEN     
;
{ simple state machine, very simple }
pub STATE   ( -- )
    MINUTE? IF REGULARLY ELSE CONSTANTLY THEN
;

{ halt set? }
pub HALT? ( -- 0 / non zero )
    HALT C@
;

pub LSTF?  ( -- true/false )
    PSI@ #85 =  IF SENF LSTF C! THEN 2DROP
    
    WLMX C@                                --- waterlevel max ?
    gtl@ < IF WLHF LSTF C! THEN             ---  water level high fault
    
    WLMN C@                             --- waterlevel low ?
    gtl@  => IF WLLF LSTF C! THEN       ---  water level low fault
    LSTF C@				--- return true (value) or false and fault code in var
;

{ turns off all equipment }
pub ALLSTOP 
    MUTE            --- turn off alarm
    OFF FLOWPUMP
    OFF EBBPUMP
    OFF LIGHTS
    OFF CIRCPUMP
;

{ flashes the fault light or buzzer with a timer }
pub FAULTLIGHT
    lightflag @ FALSE =       --- fault light already on? 
    IF
        *alarm  APIN          --- BUZZER
        8 HZ
        TRUE lightflag !
    THEN
;

pub showfault ( faultcode -- )                  --- display fault
   SWITCH                                       --- what fault ?
     WLLF case  PRINT" Water too low " BREAK
     WLHF case  PRINT" Water too high " BREAK
     WLSF case  PRINT" Water sensor zero value " BREAK
     SENF C@ case  PRINT" Water sensor runtime fault value " BREAK
     PRINT" Halt, other fault "  SWITCH@ .
;

pub ?Reset
	*reset LOW? 0EXIT
pub Reset
	0 LSTF C!              --- reset Last Fault code to zero
        FALSE fflag !          --- reset fault flag
        FALSE lightflag !      --- reset the fault light flag
        0 PSIFLT !             --- reset fault code from DLVR-L30D.fth PSI Sensor Driver
        MUTE                   --- turn off light
        ON CIRCPUMP            --- start the circulation pump
        DAY? LIGHTS            --- is it day?
        LOG? IF 
	  CR .TIME  PRINT"  System Reset "
          CR PRINT"  Restoring Running Parameters from Clock Memory " CR
          .GTL CR              --- print tank level
        THEN
;    
{ this controls error checking, system recovery from system pin depress
  and calls the state machine
}
pub doit
    fflag @
    IF  
        FAULTLIGHT                 --- turn on the fault light
        LOG? IF CR .TIME PRINT"   Clear Fault and Press Reset to continue" CR .GTL THEN
        ?Reset       
    ELSE  
        HALT? LSTF?  OR   
        IF                                            --- check for halt or fault code
            ALLSTOP                                   --- stop everything
            TRUE fflag !                              --- turn on fault lights
            LOG? IF 
	      CR .TIME PRINT"  System Halted"		--- system halted
              CR PRINT" Last Fault "
            THEN
            LOG? IF LSTF C@  showfault THEN                     --- call the word to show fault text       
        ELSE
            STATE                                      --- run the state machine
        THEN
    THEN     
;

pub systestmode (  ON/OFF  -- )   --- put system in test mode for tank levelA
    DUP IF 50 tanklevel ! THEN
    testm !                   --- write on off flag
;
       
pub sysinit  ( -- )   --- initialize the system
    CR PRINT" Setting Time from DS3231 " CR
    .DT                          --- set the kernel rtc from the DS3231  
    CR PRINT" Restoring System Running Parameters from DS3231 EEPROM "
    GETRUNTIME                   --- get current runtime parameters from DS3231 eeprom 
    10 ms
    CR PRINT" Starting System" CR
    CR PRINT" Circ Pump Started "
    ON CIRCPUMP                  --- start the circulation pump
    CR PRINT" Setting Day or Night " CR 
    DAY? LIGHTS                         --- is it day?
    --- setdefaults     --- this sets defaults from program, debugging or no DS1302 setup
    FALSE edsflag !     --- ebb dwell status flag
    FALSE fdsflag !     --- flow dwell status flag
    FALSE fflag !       --- fault flag, stops system
    FALSE lightflag !   --- light flag to false fault light
    *reset FLOAT     --- reset system pin to input
    0 LSTF C!           --- clear last fault code
    0 PSIFLT !          --- reset fault code from DLVR-L30D.fth PSI Sensor Driver
    g==                 --- turn console logging on
    OFF systestmode     --- start system in live mode 
    CR PRINT" Tank Level Sensor Starting Up, Standby " CR
;


{ stop the sytem }
pub stopit
    CR PRINT" ***** System is Stopped ***** " CR
    ALLSTOP                    --- turn everything off
    !POLLS               --- disable keypoll calling nstps
;

pri !CTL	0 lastkey C! 8 KEY! ;

{ stepping routine with delay for keypoll 4K/sec calls
  the state machine is called about ever 2 seconds
  and the PSI sensor from DLVR-L30D.fth driver is called about 10 per second
} 
pub nstps
    lastkey C@ ^Q = IF stopit !CTL EXIT THEN
    lastkey C@ ^? = IF showit !CTL THEN
    lastkey C@ ^R = IF setdefaults Reset !CTL THEN
    statetmr TIMEOUT?                --- get the state machine counter
    IF
        2000 statetmr TIMEOUT     --- reset counter 
        doit                       --- run the state machine
    THEN

    dlvrtmr TIMEOUT?                --- get the read psi sensor counter
    IF
        10 dlvrtmr TIMEOUT  --- reset counter and read sensor
        PSI.GET            --- run the PSI Sensor often from the DLVR-L30D.fth driver to read sensor
    THEN
;

    
{ Start the system }
pub startit
    !!SP                       --- Init data stack with $DEADBEEF  sanity check
    sysinit                    --- initialize system 
    #10_000 statetmr TIMEOUT     --- set state machine loop delay large to delay for GET.PSI readings   
    0 dlvrtmr TIMEOUT                    --- set loop for GET.PSI polling
    0 LSTF C!                  --- reset Last Fault code to zero
    ' nstps keypoll W!              --- set nstps to get called by keypoll
;








( DEBUG )


: GO	startit #10_000 statetmr TIMEOUT 0 HALT C! g== ;


--- AUTORUN startit            --- auto-start the system
{ DEBUG notes
renamed runtime to params
Fixed LSTF ! bug
add DUP for LOG? .ON/OFF



*** Logging On ***  

Tank Level Sensor Starting Up, Standby 
 ok
.TIMERS  ticks = 1/1,000 runtime = 102,320
51F8: dlvrtmr             000,000ms =0000.0000 L51E8 
51E8: statetmr            003,775ms =0000.0EBD L2868 
2868:                     000,000ms =0000.0000 L0001 ALARM= ok

11:47:25 FLOW PUMP  OFF 
Tank Level  0
<TP @2>
11:47:25 EBB PUMP OFF 
Tank Level  0
<TP @1>11:47:25 LIGHTS OFF 
11:47:25 CIRC PUMP OFF 
Tank Level  0
<TP @0>
11:47:25 System Halted
Last Fault Water sensor runtime fault value 
11:47:27  Clear Fault and Press Reset to continue
Tank Level  0
<TP @0>&

}
]~
END
?BACKUP
