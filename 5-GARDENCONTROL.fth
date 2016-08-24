\   Garden Control Firmware to manage the Ebb Flow Cycles of the System
\   dp V1.0
\   dp 150511  11:00  replaced all indenting with TABs
\   dp 150516  15:30  update light logic for day night cycles, fixed bug
\                     added logic to retry adc readings 3 times if value (tanklevel) greater than 14
\   dp, ky  151107 15:00 Changed the name of this module and file
\                        to GardenControl.fth
\   dp 160815         modifying code for new DLVR-L30D pressure sensor, Tachyon module and P8 board type
\                     *****WIP*****
\   dp 160821         modifying code for final testing
\                     ready for testing, set defaults for new sensor  0.80
\                     *****WIP*****

TACHYON
[~

IFNDEF DLVR-L30D.fth
     CR PRINT" !!!  This module requires a DLVR-L30D.fth  !!!          "
!!!
}

FORGET GARDENCONTROL.fth
pub  GARDENCONTROL.fth   PRINT" Garden Control P8 160823 1400 V0.90          " ;

{ ***** equipment I/O assignments ********* }
#P18 == flowp         --- flow pump
#P17 == ebbp          --- ebb pump
#P19 == lights        --- uh guess what?
#P16 == circp        --- circulation pump
#P15 == alarmp        --- alarm pin for FAULTLIGHT  
#P14 == systempin     --- reset pin input

{ ************ constants ************ }
#22 == ramlen   --- ram data length
{ states }
1 == ebbs    --- ebb state
2 == flows    --- flow state
{ fault codes }
1 == WLSF   --- water level sensor fault, lets shutdown if the water level sensor fails
2 == WLHF  --- water level high fault,  are we over flowing the tank
4 == WLLF  ---  water level low fault,   did it all leak out
{ timers }
TIMER  ebbdwell
TIMER  flowdwell      

{ *********** some variables *************** }
WORD now             --- minutes of day now
WORD daybegin        --- minutes of day daytime begins
WORD dayend          --- minutes of day  daytime ends
LONG fdsflag         --- flag for flow dwell setting
LONG edsflag         --- flag for ebb dwell setting
LONG fflag           --- fault flag
LONG lightflag       --- just turn on the fault light once
LONG retryadc        --- counter to retry adc reading in task
LONG _log            --- true false to display logging to screen
LONG testm           --- on off flag for setting system in test mode


pub LOG? ( -- flag ) --- return logging flag on or off
  _log @
;

pub g==   ( -- )   --- turn data logging to the screen on
   ON _log !
   CR CR PRINT" *** Logging On ***  " CR
;

pub g--   ( -- )    --- turn data logging to the screen off
   OFF _log !
   CR CR PRINT" *** Logging Off ***  " CR
;


{ runtime structure stored in DS1302 RAM, max of 32 bytes }
TABLE runtime #31  ALLOT    \ allocate long aligned memory for #31 bytes
runtime ORG    
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


{ testing stuff }
WORD cntr              --- loop counter for keypoll pacing
cntr W~                --- set to 0
LONG  tanklevel        ---  testing var to simulate tank level

{  new routine using RTC EEPROM }
pub SETRUNTIME
    ramlen 0 DO      
      10 ms
      runtime I + C@ $7.0000 I + EC!         --- write the runtime bytes to the eeprom
    LOOP
;
}

{  new routine using RTC EEPROM }
pub GETRUNTIME  
  ramlen 0 DO      
    10 ms
    $7.0000 I + EC@  I runtime + C!        --- write the eeprom bytes to the buffer
  LOOP
 
;

{ show what is in runtime program memory currently }
pub showit
    ramlen 0 DO
        CR I 2* 2* " HALTLSTSLSTTEBHLEBLLEDWLFLHLFLLLFDWLEBTDEBTNFLTDFLTNHRSDMINDDURHDURMLSTFWLMNWLMXSENFSENC" + 4 CTYPE
        PRINT" : "
        runtime I + C@ .
    LOOP
;  
{ default setup if not set }
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
 
{ display whats in the DS1302 ram }
pub showram
    runtime ramlen ADO   CR I C@ . LOOP
;
{ word to clear the DS1302 ram }
pub clearram
    runtime ramlen ADO  0   I  C!  LOOP
;
{ get time of day in minutes }
pub MINUTES@ ( -- minutes )    --- get time as minutes
    TIME@ #100 / #100 U/MOD #60 * +
;   
{ word to check for each minute change }
pub MINUTE? ( -- flg )   --- has a minute elapsed?            
    MINUTES@ now W@ OVER now W! <>
;  

{ word to set daybegin and dayend to absolute minutes,  adjusts for crossing 2400 hrs boundary }
pub SETTIMES
    HRSD C@ #60 * MIND C@ +  DUP  daybegin W!  --- get day begin time in minutes dup and store a copy
    DURH C@ #60 * DURM C@ +                    --- get duration of day in minutes and add day begin minutes
    +                                          ---   add daybegin to duration for dayend minutes
    DUP #1440 < IF  dayend  W!   ELSE  #1440 -  dayend W!  THEN     --- adjust for crossing 2400 hrs
;
{
  word to return flag given two vars set in minutes,
  "daybegin" and "dayend" this routine determines if it's day or night
}
pub DAY?   (  -- flg )
    SETTIMES                         --- update daybegin and dayend vars
    daybegin W@ dayend W@   <   
    IF                               --- this case we are in the same 0 to 1440 time span  
        MINUTES@  daybegin W@ =>  
        IF  
            MINUTES@ dayend W@ <=     --- return true or false
--- **DP**            IF  
--- **DP**                TRUE
--- **DP**            ELSE
--- **DP**                FALSE
--- **DP**            THEN   
        ELSE
            FALSE
        THEN
    ELSE                             --- this case we cross the midnight clock time
        MINUTES@   daybegin W@  =>
        IF  
            TRUE
        ELSE
            MINUTES@ dayend W@  <=    --- return true of false
--- **DP**            IF   
--- **DP**                TRUE
--- **DP**            ELSE
--- **DP**                FALSE
--- **DP**            THEN
        THEN
    THEN
;
{ show day begin and day end is absolute minutes }
pub showdays
    CR PRINT" day begin: " daybegin W@ .
    CR PRINT" day end  : " dayend W@ .
;

{ Gets tank level }
pub GetTankLevel (  -- level )
testm @  IF             --- check for test mode, if so just return the tanklevel
  tanklevel @
ELSE                    --- else live reading from the psi senor
    PSI@                --- PSI@ from DLVR-L30D module returns inches, 10ths of inches, convert to tenths
    0=  IF
      10 * +         
      DUP tanklevel !   --- set to tanklevel long  and return copy
    ELSE
      SENF C@ LSTF !    ---  set the sensor flaut code
      2DROP             --- drop the other returned values from PSI@
    THEN
THEN

;
ALIAS GetTankLevel gtl


{ tank level set value helper for testing }
pub SetTankLevel ( level -- )        --- this is raw ADC reading
    tanklevel  !
;
ALIAS SetTankLevel  stl


{ equipment action words  }
pub FLOWPUMP  ( ON / OFF -- message to terminal )
    IF  
       flowp HIGH
       LOG? IF CR .TIME PRINT" : FLOW PUMP ON Tank Level: " gtl . THEN
    ELSE
       flowp LOW
       LOG? IF CR .TIME PRINT" : FLOW PUMP OFF Tank Level: " gtl . THEN
    THEN
    LOG? IF CR PRINT" TIME LEFT : "  LSTT C@  .  PRINT"  Minutes" THEN
;


{ word to test if flow pump is on or off }
pub FLOWPUMP?  ( -- ON / OFF )
    flowp PIN@
;

pub EBBPUMP  ( ON / OFF -- message to terminal )
    IF  
       ebbp HIGH
       LOG? IF CR .TIME PRINT" : EBB PUMP ON Tank Level: " gtl . THEN
    ELSE
       ebbp LOW
       LOG? IF CR .TIME PRINT" : EBB PUMP OFF Tank Level: " gtl . THEN
    THEN
    LOG? IF CR PRINT" TIME LEFT : "  LSTT C@  .  PRINT"  Minutes" THEN
;

{ word to test if ebb pump is on or off }
pub EBBPUMP?  ( -- ON / OFF )
    ebbp PIN@
;

{ control circulation pump }
pub CIRCPUMP  ( ON / OFF -- message to terminal )
    IF     
       circp HIGH      
       LOG? IF .TIME PRINT" : CIRC PUMP ON  " CR 
         PRINT" Tank Level: " gtl . CR
       THEN
    ELSE
       circp LOW
       LOG? IF .TIME PRINT" : CIRC PUMP OFF  " CR  
         PRINT" Tank Level: " gtl . CR
       THEN
    THEN
;
{ control lights }
pub LIGHTS  ( ON / OFF -- message to terminal )
    IF     
        lights HIGH      
        LOG? IF .TIME PRINT" : LIGHTS ON  " CR THEN
    ELSE
        lights LOW
        LOG? IF .TIME PRINT" : LIGHTS OFF  " CR THEN
    THEN
;
{ ***************equipment ****************** }

{ word to change to next state and set time in this state }
pub NEXTSTATE   ( -- )
    DAY?
    IF                                            ---  it's day time
        LSTS C@ ebbs =                            ---  determine the next state change for day cycle
        IF  
            flows  LSTS C!                        ---  change state to  flow and flow day time
            OFF EBBPUMP                           ---  make sure the ebb pump is off during state change
            FLTD C@  LSTT C!                      ---  set the time for this state
            LOG? IF CR .TIME  PRINT" : State change to day flow "
              CR  PRINT" Time in this state : " LSTT C@ . CR
              PRINT" Tank Level: " gtl . CR	
            THEN
        ELSE  
            ebbs LSTS C!                          ---  state change to ebb
            OFF FLOWPUMP                          ---  make sure the pump pump is off during state change
            EBTD  C@ LSTT C!
            LOG? IF CR .TIME  PRINT" : State change to day ebb "
              CR  PRINT" Time in this state : " LSTT C@ .  CR
              PRINT" Tank Level: " gtl . CR	
            THEN
        THEN
    ELSE                                          ---  it's night time, stay warm
        LSTS C@ ebbs =                            ---  determine the next state change for night cycle
        IF  
            flows LSTS C!                         ---  change state to  flow and flow night time
            OFF EBBPUMP                           ---  make sure the ebb pump is off during state change
            FLTN C@  LSTT C!                      ---  set the time for this state
            LOG? IF CR .TIME  PRINT" : State change to night flow "
              CR  PRINT" Time in this state : " LSTT C@ .  CR
              PRINT" Tank Level: " gtl . CR	
            THEN
         ELSE  
            ebbs LSTS C!                          ---  state change to ebb
            OFF FLOWPUMP                          ---  make sure the flow pump is off during state change
            EBTN  C@ LSTT C!
            LOG? IF CR .TIME  PRINT" : State change to night ebb "
              CR  PRINT" Time in this state : " LSTT C@ . CR 
              PRINT" Tank Level: " gtl . CR	
            THEN
        THEN
   THEN
;

{ run the ebb cycle }
pub EBB
    gtl   EBHL C@ =>  
    IF                                             --- ebb water full ?
        OFF EBBPUMP                                --- turn the pump off
        edsflag C@ FALSE =                         --- set dwell timer one time
        IF
            TRUE edsflag C!                        --- reset ebb the dwell timer flag
            EDWL C@  #60000 * ebbdwell   TIMEOUT   --- set the dwell timer
            LOG? IF CR .TIME PRINT" : Reset EBB Dwell Timer Set Pump OFF " CR
              PRINT" Tank Level: " gtl . CR	
            THEN     
        THEN
    ELSE   
        gtl EBLL C@  <=                            --- ebb water below low level setting ?    
        IF
            ebbdwell TIMEOUT?                      --- has the dwell timer elapsed?
            IF   
                ON EBBPUMP                         --- ebb pump back on
                FALSE edsflag C!                   --- reset ebb dwell timer flag
                LOG? IF CR .TIME PRINT" : EBB Water Low, filling Tank Level: "  gtl . CR
                THEN
            ELSE
                LOG? IF CR .TIME PRINT" : EBB Water Low, Dwell TIme Left: " ebbdwell @ 1000 U/ . CR
                  PRINT" Tank Level: " gtl . CR 
                THEN
            THEN
        ELSE  
            LOG? IF CR  PRINT" EBB Water Nominal, Tank Level: "  gtl .
              CR PRINT" EBB Pump is: "   EBBPUMP? IF ." ON "  ELSE ." OFF" THEN  
              CR PRINT" TIME LEFT : "  LSTT C@  .  PRINT"  Minutes" 
            THEN
        THEN
    THEN
;

{ run the flow cycle }
pub FLOW
    gtl   FLLL C@ <=                         
    IF                                                          --- flow water empty ?
        OFF FLOWPUMP                                            --- turn the pump off
        fdsflag C@ FALSE =                                      --- set dwell timer one time
        IF
            TRUE fdsflag C!                                     --- reset the dwell flag
            FDWL C@  #60000 * flowdwell   TIMEOUT               --- set the dwell timer
            LOG? IF CR .TIME PRINT" : Reset Flow Dwell Timer Reset Pump OFF "  CR
              PRINT" Tank Level: " gtl .  CR
            THEN
        THEN
    ELSE                                  
        gtl FLHL C@  =>                                --- flow water above high level setting ?     
        IF
            flowdwell TIMEOUT?                         --- has dwell timer elasped?
            IF
                ON FLOWPUMP                            --- flow pump back on
                FALSE fdsflag C!                       --- reset flow dwell timer flag  
                LOG? IF CR .TIME PRINT" : Flow Water High, Empyting Tank Level: "  gtl . CR
                THEN
            ELSE
                LOG? IF CR .TIME PRINT" : FLOW Water High, Dwell TIme Left: " flowdwell @ 1000 U/ . CR 
                  PRINT" Tank Level: " gtl . CR 
                THEN
            THEN    
        ELSE  
            LOG? IF CR  PRINT" Flow Water Nominal, Tank Level: "  gtl .
              CR  PRINT" Flow Pump is: "   FLOWPUMP? IF ." ON "  ELSE ." OFF" THEN
              CR PRINT" TIME LEFT : "  LSTT C@  .  PRINT"  Minutes" 
            THEN
        THEN
    THEN
;

{ simple state machine, very simple }

pub  STATE   ( -- )
    MINUTE?   
    IF
        DAY? LIGHTS            --- control the lights from here, checking everything minute
--- **DP**        IF  
--- **DP**           ON LIGHTS
--- **DP**        ELSE
--- **DP**           OFF LIGHTS
--- **DP**        THEN
        
        SETRUNTIME       --- each minute store running parameters to DS3231 eeprom 
        LOG? IF CR PRINT" Storing Parameters to DS3231 EEPROM " 
        THEN
        LSTT C@ 1- 0 <=  --- calc last state running time on minute tick check for time out
        IF
            NEXTSTATE      --- change state  reload LSTT/LSTS with correct day night value and state
            LOG? IF CR   .TIME PRINT" : State Changed to: "
              LSTS C@  1 = IF PRINT" Ebb " ELSE PRINT" Flow " THEN
            THEN
        ELSE  
            LSTT C--       --- nope still in this state just write LSTT with the decrimented minute
            LOG? IF CR .TIME PRINT" : Minute change" 
            THEN
        THEN   
    ELSE
        LSTS C@
        ebbs = IF
           --- running Ebb cycle
           LOG? IF CR .TIME PRINT" : Running State: Ebb" 
           THEN     
           EBB
         ELSE
           --- running FLow cycle
           LOG? IF CR .TIME PRINT" : Running State: Flow"
           THEN  
           FLOW
         THEN     
    THEN
;
{ halt set? }
pub HALT? ( -- 0 / non zero )
    HALT C@
;

{ do we have any fautls }
pub LSTF?  ( -- true/false )
    PSI@  #85 =  IF       --- status is 85 fault code, sensor grounded, retry failures
        SENF LSTF C!      --- write the water level sensor fault code
    THEN
    2DROP             --- drop the other return readings from PSI@
    
    WLMX C@           --- waterlevel max ?
    gtl < IF WLHF LSTF C! THEN ---  water level high fault
    
    WLMN C@           --- waterlevel low ?
    gtl  => IF WLLF LSTF C! THEN  ---  water level low fault
    LSTF C@ 0 > IF TRUE ELSE FALSE THEN    --- return true or false and fault code in var
;

{ turns off all equipment }
pub ALLSTOP
    OFF FLOWPUMP
    OFF EBBPUMP
    OFF LIGHTS
    OFF CIRCPUMP
;

{ flashes the fault light or buzzer with a timer }
pub FAULTLIGHT
    lightflag @ FALSE =     --- fault light already on? 
    IF
        alarmp  APIN    --- BUZZER
        8 HZ
        TRUE lightflag !
    THEN
;

pub showfault ( faultcode -- )  --- display fault
   SWITCH                                       --- what fault ?
     WLLF case  PRINT" Water too low " BREAK
     WLHF case  PRINT" Water too high " BREAK
     WLSF case  PRINT" Water sensor zero value " BREAK
     SENF C@ case  PRINT" Water sensor runtime fault value " BREAK
     0 case  PRINT" Halt, other fault" BREAK

;
    
{ this is the main word so far }
pub doit
    fflag @
    IF  
        FAULTLIGHT    --- turn on the fault light
        LOG? IF CR .TIME PRINT"  : Clear Fault and Press Reset to continue" CR
          PRINT" Tank level: " gtl . CR 
        THEN
        systempin PIN@ FALSE =
        IF  
            0 LSTF C!          --- reset Last Fault code to zero
            FALSE fflag !      --- reset fault flag
            FALSE lightflag !  --- reset the fault light flag
            0 PSIFLT !         --- reset fault code from DLVR-L30D.fth PSI Sensor Driver
            MUTE               --- turn off light
            ON CIRCPUMP        --- start the circulation pump
            DAY?               --- is it day?
            IF
                ON LIGHTS
            ELSE
                OFF LIGHTS
            THEN
            LOG? IF CR .TIME  PRINT" : System Reset "
              CR PRINT"  Restoring Running Parameters from Clock Memory " CR
              PRINT" Tank level: " gtl . CR 
            THEN
        THEN       
    ELSE  
        HALT? LSTF?  OR   
        IF                                           --- check for halt or fault code
            ALLSTOP                                  --- stop everything
            TRUE fflag !                             --- turn on fault lights
            LOG? IF CR .TIME PRINT" : System Halted"         --- system halted
              CR PRINT" Last Fault: "
            THEN
            LOG? IF
              LSTF C@  showfault              --- call the word to show fault text
            THEN       
        ELSE
            LOG? IF CR 
            THEN
            STATE     --- run the state machine
        THEN
    THEN     
;

pub systestmode (  ON/OFF  -- )   --- put system in test mode for tank levelA
    DUP IF 
           50 tanklevel !      --- put dummy tank level for testing
        THEN
        testm !               --- write on off flag
;
       
pub sysinit  ( -- )   --- initialize the system
    CR PRINT" Setting Time from DS3231 "
    .Time 10 ms ."  " .DAY 10 ms ."  " .DATE --- set the kernel rtc from the DS3231  
    GETRUNTIME                   --- get current runtime parameters from DS3231 eeprom 
    10 ms
    0 LSTF C!                    --- clear last fault
    --- TRUE tsflag !            --- set task flag to run the loop
    ON CIRCPUMP            --- start the circulation pump
    DAY?                   --- is it day?
    IF
        ON LIGHTS
    ELSE
        OFF LIGHTS
    THEN
    CR PRINT" Circ Pump Started "
    CR PRINT" Task Started "
    CR PRINT" Restoring System Running Parameters from DS3231 EEPROM "
    --- setdefaults     --- this sets defaults from program, debugging or no DS1302 setup
    FALSE edsflag !     --- ebb dwell status flag
    FALSE fdsflag !     --- flow dwell status flag
    FALSE fflag !       --- fault flag, stops system
    FALSE lightflag !   --- light flag to false fault light
    systempin FLOAT     --- reset system pin to input
    --- #150503 DATE!   --- date time is no DS1302 attached
    --- #193000 TIME!  
    g==                 --- turn console logging on
    OFF systestmode     --- start system in live mode 
;


WORD pcntr 

{ stepping routine with delay for keypoll 4K/sec calls }
pub nstps
    cntr W@
    0=
    IF
        #64000 cntr W!
        doit
    ELSE
        cntr W--
    THEN
    pcntr W@
    0=
    IF
        #5000 pcntr W!
        PSI.GET            --- call the PSI Sensor
    ELSE
        pcntr W--
    THEN
;

    
{ Start the system }
pub startit
    sysinit
    #64000 cntr W!            --- set state machine loop delay cntr to delay for GET.PSI 
    pcntr W~                  --- set  loop for GET.PSI polling
    0 LSTF C!                 --- reset Last Fault code to zero
    ' nstps  keypoll W!
;
 
{ stop the sytem }
pub stopit
    ALLSTOP
    0 keypoll W!
;

--- AUTORUN startit         --- auto-start the system


]~
END
 
