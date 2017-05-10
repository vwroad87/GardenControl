\  Support module for ESP8266 webserver interface to tachyon
\  170501 initial code, dp
\  170502 working on quiet mode with CR, dp


TACHYON

[~

IFNDEF GARDENCONTROL.fth
     CR PRINT" !!!  This module requires a GARDENCONTROL.fth  !!!          "
!!!
}

FORGET ESP8266.fth
pub  ESP8266.fth   PRINT" ESP Tachyon Support 170502 1600 V0.3" ;

pub @{ 123 emit ;
pub @}  125 emit ;
pub @"  34 emit ;
pub @[  91 emit ;
pub @]  93 emit ;
pub @,  44 emit ;
pub @:  58 emit ;

pub showitj    ( -- )
     exclude @ NOT IF     --- test for serial exclude flag
       @{                   
       ramlen 0 DO             
         @"
         I 2* 2* 
         " HALTLSTSLSTTEBHLEBLLEDWLFLHLFLLLFDWLEBTDEBTNFLTDFLTNHRSDMINDDURHDURMLSTFWLMNWLMXSENFSENCLOGF" + 
         4  CTYPE  @" 
         PRINT" : "  @" params I + C@ . @"  @, 
         ---  I ramlen 1 - < IF @, ELSE @} THEN
       LOOP 
       @" " GTL" PRINT$ @" @: @" gtl@ . @"  @}    
     THEN       
    
; 

--- return JSON string of Tank Level
pub gtlj 
  exclude @ NOT IF 
    @{ @" " GTL" PRINT$ @" @: @" gtl@ . @" @} 
  THEN
;
--- prompt 
pub MYPROMPT CR ;

--- set tachyon prompt no echo CR only no ok
pub QUIET ( on/off -- )		IF OFF ECHO ' MYPROMPT ELSE ON ECHO 0 THEN prompt 2+ W! ;


]~  END

