\ DLVR-L30D Driver, DLVR-L30D.fth
\ V0.1  dp 151106 2200
\ DLVR-L30D E1BD-C N13N  +- 30 psi pressure sensor 
\ 3.3 Volt, I2C Interface
\ USAGE:   call PSI@ to get ( -- result inches 10ths )
\          call PSI.GET in main program keypoll to run the sensor and accumulate results
\ change log
\ 151107 dp working on transfer functions for temp and psi
\ 151108 kty fixed math and bit masks 151108.1400 V0.3
\ 160807 dp  added PSI@ word for production 160807.23:00 V0.4
\ 160809 dp  modified PSI@ to return   ( --- status psi ) to test for reading or sensor failure V0.5
\ 160812 dp  made pressure driver into a TASK that can be stopped and started.
\            added circ buffers to avg last 16 readings into DPAVG longs   V.06
\ 160813 dp  tested for condition Status 0 and -8192,  sensor grounded, tuned timing better sensor comms V.07
\ 160814 dp  got sensor working  90%,  need to improve I2C-ish "signaling" V.08 release 1. Use runit to test
\ 160822 dp  using new extend.fth resolve errors of I2C arbitration  V1.1
\ 160823 dp  okay complete rewrite to remove this module as a task and it is used in keypoll to read,
\ accumulate, error check and condition data for use in PSI@ word. V1.2 
\ 160830 dp  Peter found a bug, I was sending an ACK on the 4th byte instead of NAK, this routine is now called by a timer in GardenControl.fth
\ driver must protect from these errors
\	Status 0 = good data *** OR *** sensor grounded out = Status 0 reading -8192
\	Status 1 = resevered bad data
\	Status 2 = sensor disconnected from power or stale data 
\	Status 3 = sensor bad data  
\       Status 85 = %01010101  will be returned by this driver when the sensor fails 
\                              after appropriate retry counts.

 
TACHYON
FORGET DLVR-L30D.fth
pub    DLVR-L30D.fth  ." DLVR-L30D PSI Sensor v1.3 160830.0930" ;
 
DECIMAL
[~ 

\ Sensor Data Masks 
$C0000000 CONSTANT status     \ two bits 31-30
$3FFF0000 CONSTANT psi        \ fourteen bits 29-16
$0000FFE0 CONSTANT temp       \ eleven bits 15-5   last 5 are empty / unused

\ Sensor Device Address Base $28
$50 CONSTANT psiw   \ device address write
$51 CONSTANT psir

\ Result
LONG RESULT

\ Use private I2C Bus
--- EEPROM
#P0 == mSDA
#P1 == mSCL

{ fix up non compliant chip with I2C routines that handle the chip's issues }
pub II2C!? ( data -- flg  )      \ write a byte to the I2C bus and return with the ack 0=ack  
    #24 REV                      \ put into lsb first format for SHROUT 
    SDA DUP OUTCLR SWAP          \ data masks 
    8 FOR
      SHROUT                     \ Shift out next data bit
      CLOCK NOP CLOCK
      NEXT                       \ loop
    DROP DUP INPUTS              \ Float SDA
    CLOCK IN 0<> CLOCK           \ ack clock
    ;
    
pub II2C! ( data --  )              \ write a byte to the I2C bus but ignore the ack 
    #24 REV                         \ put into lsb first format for SHROUT 
    SDA DUP OUTCLR SWAP             \ data masks 
    8 FOR                           \ start loop for 8 times
      SHROUT                        \ Shift out next data bit
      CLOCK NOP CLOCK
      NEXT                          \ loop
    DROP INPUTS                     \ Float SDA
    CLOCK NOP CLOCK                 \ dummy ack clock
    ;


{ read data from the device, free running read only device }

    
pub DLVR@ (  --  )            \ sets the RESULT long 
	mSDA mSCL I2CPINS           \ use private i2c bus
	I2CSTART                    \ starts the bus
	psir  II2C!
	ackI2C@ 8<<
	ackI2C@ OR 8<<
	ackI2C@ OR 8<<              \ shift into 3RD byte
	1 I2C@ OR                   \ read 4TH byte, DON'T ACK
	RESULT !                    \ store it
	I2CSTOP                     \ stop the bus
	EEPROM
;

\  TASK Allocations 
#16 LONGS psibuff				--- circ buffer allocation
BYTE psiptr					--- buffer pointer
long PSIFLT					--- fault code result
LONG DPSI, DSTATUS, DTEMP, DPAVG, DRETRY	--- result variables
 

pub PSI.GET
      DLVR@
      RESULT @ status AND #30 >> DSTATUS !
      RESULT @ psi AND #16 >> #8192 - DPSI !
      RESULT @ temp AND 5 >> DTEMP !
      
      DSTATUS @  0= IF
        0 DRETRY !                --- reset retry counter
        psiptr C@  15 =>          --- are we at index 0 - 15
          IF
            0 psiptr C!           --- reset index, write to this index
            DPSI @ psibuff !      --- write to 0 location
          ELSE
            1 psiptr C@ + DUP psiptr C!        --- increment buffer ptr save and leave on stack
            4 * psibuff + DPSI @ SWAP  !        --- write DPSI to this buffer index
          THEN
          0 16 0 DO I 4 * psibuff + @ + LOOP  16 / DPAVG !  --- computer and write the average to DPAVG
      ELSE                          --- capture error condition to retry cout
        1 DRETRY @ + DRETRY !       --- increment the sensor retry max counter
        DRETRY @  20 => IF          --- test for max consecutive retries
          85  PSIFLT !             --- write the sensor fault status
        THEN           
      THEN
  
;

pub PSI@ ( --  tenths inches  Status )
        DPAVG @ 10 / DUP 10 / swap 10 MOD SWAP
        PSIFLT @  
;

pub PSIDBug@ ( --- Status PSI ) 
       ." Status: " DSTATUS @ . CR 
       ." PSI: " DPSI @ . CR
       ." Avg PSI: " DPAVG @   . CR 
       ." Nrmlzd PSI: " DPAVG @ 10 / DUP 10 / swap 10 MOD SWAP . ." ." . CR
       ." TEMP: " DTEMP @ . CR
       ." FAULT: " PSIFLT @ . CR 
;

pub clearpsi  ( -- )  \ clear the psi buffer
  16 0 DO 0 I 4 * psibuff +  ! LOOP       \ clear the buffer for fun
;



{ ********** test the sensor ********** }

pub showbuff   \ show what's in the circular buffer
  16 0 DO CR I 4 * psibuff +  @ . LOOP
;

]~
END

