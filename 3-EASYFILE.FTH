TACHYON [~

FORGET EASYFILE.fth

pub EASYFILE.fth    PRINT" SD card  + FAT32 Virtual Memory Access File System Layer V1.2 16080711-2300 " ;

IFDEF PROMPT   OFF PROMPT }


{
DESCRIPTION
These are the general routines used to initialize and the SD card and can also be used to load and save blocks directly. There are various tools plus the primitives which allow you to directly interact with the card and it's command set. This module forms the foundation on which other modules for virtual memory and file system relies.


NOTE: The card insertion method used here in CARD? is based on that mentioned in the official SD MEMORY CARD SPECIFICATIONS which detects the pullup that exists on the chip select of a memory card itself. This means that a "safety" pull-up is never required and the card detect will not work if one is used. It is perfectly safe to remove any resistor that has been added to pull-up the CS line after which the standard card detect method can be used.


CHANGELOG:
150827 Fixed SD methods - set constants when FILE is executed
150826 Improved XADR methods
141202 added default C:
     Added ?SPIO to save half the CMD execution time by caching this module and pin masks
     Increased &sdto timeout constant from 10,000 to 20,000 (~250ms)
141115 removed diagnostic utilites, added multiple cog access if run in it's own cog (sdtask set)
140121 modified for linked timer method
131114 tidied and trimmed source
131111 Standardized for hardware header support
     Make BUFFERS fully available for 4 sectors (multiple files open)
131105 Increased timeout from 5,000 to 10,000
131104 Added in basic virtual memory interface words
130723 Restructured the code, optimized SDPINS etc. inserted datasheet images
130717 Tidied up source
130303 Changed constant names to =constant rather than #constant as numeric preprocessor clashes
121226 Removed redundant [SPIO] references which were also slowing down access
121013 Modify to use BUFFERS (VM image)
120917 Added SPINNERET
120909 Added CARD detect redefinition vecotr "ucard"
120909 Added extra pin definitions for different boards
120903 Added pin redirection

MODULE INFO:
SMALL BUILD (not reclaimed)
NAMES:  $5D73...74EB for 6008 (0650 bytes added)
CODE:   $0000...3000 for 6280 (1456 bytes added)
CALLS:  0477 vectors free
RAM:    11635 bytes free


NAMES:  $5903...7309 for 6662 (0618 bytes added)
CODE:   $0000...38B6 for 7856 (1820 bytes added)
CALLS:  0405 vectors free
RAM:    8269 bytes free

TESTS:
Reading from the card:
4K LOAD takes 18.76ms
512 byte LOAD takes 2.55ms
}
[PRIVATE
{ NOTE: Pin defintions may be made at compile time or at runtime using SDPINS
If a header file is compiled beforehand then it should include these pin names as shown.
The card detect is via the SDCS which detects a card's "pullup" (do not use external pullups here!!!)
}
IFNDEF &SDCS
#P26    |<	== &SDCS            --- SDCARD CS
#P27    |<	== &SDDO            --- Data out from SDCARD
#P28    |<	== &SDCK            --- SDCARD clocks (Shared with SCL)
#P29    |<	== &SDDI            --- Data to SDCARD (Shared with SDA)
}

IFNDEF PCB
0		== PCB
" NOT DEFINED"	0 STRING PCB$
}
DECIMAL

#512		== BLKSIZ PUBLIC  --- BLKSIZ is used because it is smaller & faster than a literal #512 - it is really constant


[PRIVATE            --- make the following definitions private until PRIVATE]
--- SD Tokens
$FE             == =dtk            --- data token for single block read/write
--- $FC         == =dtk1            --- data token for 1st block read/write
--- $FD         == =dtke            --- data token for last block read/write

( SD CARD REGISTERS )

#176 BYTES sdinfo
sdinfo		ORG            --- Use Tachyon reserved buffer space for SD card (normally at $7400)
#64		DS cid        --- Card ID
#64		DS csd        --- Card Specific Data
#4		DS ocr        --- Operating conditions register

--- #16		DS extbuf        --- temp buffer used for reporting functions
PRIVATE]

4            DS sdpins
4            DS sdsize
4            DS sdwr PRIVATE
4            DS sdrd PRIVATE
2            DS ucard        --- user vector for special card detect routine
2            DS sdbusy
1            DS crc PRIVATE
1            DS card?        --- card detect transition memory
1            DS blklen
1            DS sdhc PRIVATE

1            DS filesel        --- currently selected file 0..3

4 BYTES wrflgs                 --- byte flag for each channel to indicate current sector buffer has been written to

wrflgs         == @WRFLG         --- make @WRFLG a constant byte address, one for each file (faster than bit ops)

--- Current sector loaded in SDBUFs for the 4 files possible
4 LONGS sectors PRIVATE    --- sector is the SD 4GB address shifted right by 9 bits - 512 BLKSIZe
sectors == _sector            --- fast access to current sector than sector @FILE

--- Sector CRCs
4 LONGS scrcs PRIVATE
scrcs == _scrc

BUFFERS == SDBUF        --- initial value for SDBUF which depends upon which file handle is selected

pub FILE ( index:0..3 -- )  \ Set the active file channel (0 ..3)
     3 AND DUP filesel C!                --- remember new selection
     DUP 4* sectors + ' _sector 1+ !        --- 150826 method to improve speed for XADR
     DUP 4* scrcs + ' _scrc 1+ !
     DUP wrflgs + ' @WRFLG 1+ !             --- set @WRFLG constant for faster operation
     9<< BUFFERS + ' SDBUF 1+ !         --- set SDBUF constant for faster operation
     ;

--- return the current file channel
pub FILE# ( -- file# )    filesel C@ 3 AND ;

{HELP @FILE ( addr -- addr+off )
returns the address offset into sector & sectcrc tables for active file channel
as set with    index FILE
e.g. val sector @FILE ! otherval sectcrc @FILE ! sector @FILE @
}
pub @FILE ( addr -- addr+off )
FILE# 4* +
     ;

--- Load default SD pins at compile time ( ce-miso-mosi-clk -- )
&SDCS >| #24 SHL &SDDO >| 16 SHL OR &SDDI >| 8 SHL OR &SDCK >| OR sdpins !


IFNDEF SDBSYLED
pub SDBSYLED     DROP ; --- dummy status LEDs if not defined
}
IFNDEF SDERRLED
pub SDERRLED    DROP ; --- dummy status LEDs if not defined
}

--- 141115 added command channel to allow SDCARD to run in it's own cog.

LONG sdsrc,sddst,sdres
BYTE sdcmd,sdtask
pri SDCMD
     BEGIN sdcmd C@ 0= UNTIL            --- another cog may be using this channel
      SWAP sddst ! SWAP sdsrc ! sdcmd C!
     BEGIN sdcmd C@ 0= UNTIL
     sdres @
     ;


ucard W~
--- Detect SD card presence - the CS line must not have a pullup on it (redundant and undesirable).
pub CARD?    ( -- flg ; Is SD card present? )
     sdtask C@ IF 0 0 "?" SDCMD EXIT THEN	--- replace direct access method with command channel if SDCARD.TASK is running
pri _CARD?
     ucard W@ ?DUP IF JUMP THEN			--- use alternative card detect method if selected
    &SDCS OUTCLR				--- pulse low, float, check, return high
    &SDCS INPUTS				--- Float CS
    &SDCS IN					--- Is it still low or has it been pulled up (by the card's pullup)
    &SDCS OUTSET				--- force back to an inactive CE output
    ;


--- Fetch a byte from the SD (clock in 1's)
pri SD@ ( -- 8b )
    -1 RUNMOD >B
    ;
--- Write a byte to the SD
pri SD! ( 8b -- )
    16<< 8<< RUNMOD DROP
    ;


( SDRD and SCAN )
--- MAKE SURE THAT KERNEL 23140617 or greater is used
BYTE scanch
WORD scancnt,scanpos

--- Read in one block of 512 bytes from SD to dst
pri (SDRD) ( dst -- )
	--- BYTE scanch holds the char to scan for
	--- gives number of character matches found in WORD scancnt
	--- autoincrements on each call, use scancnt W~ to init to 0 if needed
	--- position of first match in WORD scanpos
	[SDRD] 1 COGREG@ OUTSET scanch C@
     ( dst char ) RUNMOD ( first cnt )            --- load the SDRD RUNMOD and run
	scancnt W+!					--- increment scancnt by last number of times scanch was found
	scanpos W@ 0= IF scanpos W! ELSE DROP THEN       --- on multi block reads capture first occurrence
	--- NOTE: use scanpos W~ to init
;

pri SD2@ ( -- word ) --- 16us
     SD@ 8<< SD@ OR
     ;
pri SD4@ ( -- long ) --- 26us
     BL @CNT COGREG! -1 RUNMOD
     8 @CNT COGREG!
     ;
--- Faster byte wide clocks (8/count)
pri SDCLK ( cnt -- )
    FOR SD@ DROP NEXT
    ;

#20000 == &sdto				--- SD timout period - can be very long

--- do what needs to be done if the SD card is busy (LED etc) - can be rewritten
--- LEDs are defined in PCB header files
pri SDBUSY ( state -- )        sdbusy W@ ?DUP IF JUMP ELSE SDBSYLED THEN ;


--- Initialize the SD I/O and basic card
pub SDPINS ( ce-miso-mosi-clk -- --- set pins, save them for reboot and init with !SDIO see high level !SD )
    sdpins !					--- remember which pins were used for BACKUP
    sdtask C@ IF 0 0 "P" SDCMD EXIT THEN	--- replace direct access method with command channel if SDCARD.TASK is running
pri !SDIO					--- init SD pins
     sdpins @
    DUP #24 >> MASK ' &SDCS 1+ !		--- setup SDCS mask
    MODPINS
    ucard W~
    sdbusy W~

    [SPIO]
    1 ms
    &SDCS OUTCLR				--- select the card
    @MOSI COGREG@ OUTSET			--- Set MOSI high
     @SCK COGREG@ DUP OUTCLR			--- clock low (and as an output)
    #100 FOR DUP OUTSET DUP OUTCLR NEXT DROP
    &SDCS OUTSET
    16 SDCLK					--- 16 byte-wide clocking cycles
    &SDCS OUTCLR
    16 SDCLK
    &SDCS OUTSET
    ;

--- define drive select commands
IFNDEF SDC
&SDCS >| #24 SHL &SDDO >| 16 SHL OR &SDDI >| 8 SHL OR &SDCK >| OR == SDC
}

pub C:        SDC SDPINS ;

IFDEF SDD
pub D:        SDD SDPINS ;
}
IFDEF SDE
pub E:        SDE SDPINS ;
}
IFDEF SDF
pub F:        SDF SDPINS ;
}


( SD CARD RESPONSES )





( Response fetch )
pri RES@ ( -- res ) --- Continue reading until a response is received (with timeout)
    $FF &sdto 0					--- TIMEOUT PERIOD   $FF = timeout return value - 115ms
      DO SD@ DUP $FF <>				--- look for a response (non $FF)
        IF NIP LEAVE ELSE DROP THEN
      LOOP
    ;



--- 141202 - added ?SPIO to save 120us each CMD by checking to see if SPIO parameters need to be reloaded
[SPIO]
' RUNMOD COG@		== @RUNMOD
@RUNMOD COG@		== =SPIO PRIVATE    --- SPIO  signature

pri ?SPIO        @RUNMOD COG@ =SPIO <> IF [SPIO] sdpins @ MODPINS THEN ;

{HELP SDCS ( on/off -- ) SD chip select method to allow for Parallax C3 board.
Direct chip select timing: 15.8us ON, 15us OFF
IF PC = 32209 = C3 PCB: 72.2us ON, 21.2us OFF

}
pub SDCS ( on/off -- )
     PCB 32209 = IF			--- C3 PCB? (32209 = Parallax part#)
       8 LOW 8 HIGH IF 5 FOR 25 DUP HIGH LOW NEXT THEN
     ELSE
       IF &SDCS OUTCLR ELSE &SDCS OUTSET THEN
     THEN
;


( Issue a command to the SD card )
pub CMD    ( data cmd -- res )		--- Send the command to the SD card and read result - 108us
    ?SPIO 0 COGREG@ OUTCLR
    SD@ DROP				--- extra clocks
     ON SDCS				--- Select the card
    $3F AND $40 OR SD!			--- send the command
    BL @CNT COGREG!			--- 32-bit transfer
    RUNMOD DROP				--- send data
    8 @CNT COGREG!			--- back to 8-bit transfers
    crc C@ SD!				--- dummy checksum ( is valid for initializing)
    RES@				--- fetch the response
    ;

--- Send an ACMD to the card and return with response
pub ACMD ( data acmd -- res )
     0 #55 CMD DROP CMD
     ;
pri STAT@ ( -- stat )
     0 #13 CMD RES@ 8<< OR
     ;

pub SDERR? ( -- flg ; return SD bit flag errors)
    0 _CARD? 0= 1 AND OR		--- b0 = card detect error
    sdrd @ 0= 2 AND OR			--- b1 = read failure
    sdwr @ 0= 4 AND OR			--- b2 = write failure
    ocr @ 0= 8 AND OR			--- b3 = card error
    ;
pri MARKER? ( marker -- flg ; Find SD marker and return true before timeout )
    &sdto BEGIN OVER SD@ <> WHILE 1- DUP 0= IF NIP EXIT THEN REPEAT
    2DROP TRUE
    ;

pri SDDAT! ( adr -- ; Wait for read token and read SD data into buffer )
    =dtk MARKER? IF 16 ADO SD@ I C! LOOP 3 SDCLK ELSE DROP THEN
    ;






TIMER sdtimer PRIVATE

--- In SPI Mode, only the OCR, CSD and CID registers are accessible.
pri ?SDTIMEOUT        sdtimer TIMEOUT? IF FALSE R> DROP EXIT THEN ;

--- Initialise the SD card (with timeout)
pub !SD ( -- ocr|false ; Initialise the SD card in SPI mode and return with the OCR )
     sdtask C@ IF 0 0 "Z" SDCMD EXIT THEN
pri _!SD
    ON SDBSYLED OFF SDERRLED
    ocr ~
    cid 16 ERASE csd 16 ERASE
     0 FILE
    SDBUF BLKSIZ 2* 2* ERASE		--- erase all 4 file buffers
     sectors 16 -1 FILL			--- force an invalid sector (nothing cached)
\    sdpins @ _SDPINS                   --- reload SDPINS in case this is a reboot & !SDIO
     !SDIO
    _CARD?
    IF
      #1000 sdtimer TIMEOUT
      $95 crc C!
        BEGIN ?SDTIMEOUT 0 0 CMD 1 = UNTIL
      $87 crc C!
           BEGIN ?SDTIMEOUT $1AA 8 CMD 1 = UNTIL
       SD4@ $1AA =
      IF
          BEGIN ?SDTIMEOUT $4000.0000 #41 ACMD 0= UNTIL
          BEGIN ?SDTIMEOUT 0 #58 CMD 0= UNTIL
         SD4@ DUP ocr !
        DUP
         IF
           0 #10 CMD 0= IF cid SDDAT! THEN
           0 9 CMD 0= IF csd SDDAT! THEN
         THEN
      ELSE
        FALSE
      THEN
    ELSE
      FALSE
    THEN
    &SDCS OUTSET
     OFF SDBSYLED
     DUP 0= SDERRLED                --- indicate an error visually if enabled
    ;

--- 141114 deprecated card info diagnostics

{ *** BLOCK BUFFERS *** }

--- card has been prep'd for read  - proceed and read a block of data
pub SDRDBLK ( dst -- crc )            --- dst is the HUB address of an SD buffer, SDBUF  gives active one
    (SDRD)                    --- special fast read module
    [SPIO]                    --- switch back to standard SPI mode (for commands etc)
    SD2@                        --- read crc
    31d MASK OR                    --- force crc as TRUE flag (msb set)
    ;


pri PROCESS_TOKEN    ( dst token -- crcflg )
     =dtk = IF SDRDBLK EXIT THEN        --- read a block of data
    2DROP                        --- drop token and dst
    2 SDCLK STAT@ DROP            --- discard cycles
    &SDCS OUTSET
    FALSE
    ;




--- SD CARD READ BLOCK - measured 2.3ms to 6ms on 4GB Sandisk
pub SDRD    ( sector dst -- crc | false ; Read sector from SD into dst )
     sdtask C@ IF "R" SDCMD EXIT THEN
pri _SDRD
    ON SDBUSY
    SWAP #17 CMD ( data cmd -- res )    --- read block command
      IF
        DROP FALSE                --- didn't like that command - discard dst & return false
      ELSE
        RES@ PROCESS_TOKEN            --- process read token and read block
       THEN
    OFF SDCS                --- release the SD card
    OFF SDBUSY
    DUP sdrd !                   ---  save crc/flg
    ;


{HELP SDWR ( src sect -- flg )
Write to a sector in the SD card - measured 2.84ms on 4GB SanDisk
Testing 32k write: LAP 0 FILE@ 9 >> 64 ADO DUP I SDWR DROP BLKSIZ + LOOP LAP .LAP 274.111ms ok
}
pub SDWR    ( src sect -- flg ; Write from src to xdst in the SD )
     sdtask C@ IF "W" SDCMD EXIT THEN
pri _SDWR
    ON SDBUSY
    OFF SDCS 1 SDCLK                 --- finish off previous
     ON SDCS 3 SDCLK                --- Prep card
    #24 CMD ( src res )                --- write block command
    0=
      IF
         3 SDCLK =dtk SD!
        BLKSIZ [SDWR] RUNMOD            --- Write sector
        [SPIO]                    --- switch back to normal SPI mode
        0 MARKER? $FF MARKER? AND
        ELSE FALSE
      THEN
    OFF SDCS
    OFF SDBUSY
    DUP sdwr !
[SPIO]
    ;

--- --- --- --- --- --- --- ------ --- --- ------ ------ --- --- ------ --- --- ---



PRIVATE]


( Virtual memory addressing is suitable for addressing the first 4GB of the memory )

HELP: SECTOR ( sect -- )
Read the sector into the SDBUF
takes around 1.9ms, 2.55ms
}
pub SECTOR ( sect -- )
     DUP _sector !                     --- update sector pointer for this file channel
     SDBUF SDRD _scrc !
     ;

pri ACTIVE? ( -- flg )
     _scrc @ $8000.0000 <>
     ;


pub WRSECT ( -- flg ) ( write the current sector back to the storage media )
     SDBUF _sector @ SDWR
    ;

pub FLUSH   ( Write the sector buffer if it has been modified )
     @WRFLG C@
     IF WRSECT DROP @WRFLG C~ THEN
    ;

IFNDEF 9BITS pub 9BITS $1FF AND ; }

{
Translate a virtual address into a HUB RAM address - may have to flush and read a sector
15.8us if cached, else around 2ms average

V2.7 150826 just uses 9BITS and preset constants for 18.2us
$8000 0 LAP DO I XC@ DROP LOOP LAP .LAP 817.786ms ok
64 0 LAP DO I SECTOR LOOP LAP .LAP 128.475ms ok

V2.8 160508 now has 8>> and 8<< to avoid slow stack push and pops - down to 14us
$8000 0 LAP DO I XC@ DROP LOOP LAP .LAP  760.208ms ok

A 512 byte sector takes 2ms on the average to read into memory
}
pri XADR! ( xaddr -- addr )
     @WRFLG C~~
pub XADR ( xaddr -- addr )				--- make sure sector is loaded into SDBUF and return with physical address
    DUP 9>> _sector @ <>				--- same sector - buffered already?
    IF							--- No
	FLUSH						--- make sure any writes to the current buffer are flushed
        DUP 9>> SECTOR				--- get sector into SDBUF if not already there
    THEN
    9BITS SDBUF +    ( 4.6us )				--- return with physical address
    ;


--- cached timing = 16.4us or ~2ms to buffer sector
pub X@ ( xaddr -- long )                    --- read a long from virtual memory address xaddr
     XADR @
     ;
pub X! ( long xaddr -- )                    --- write a long to virtual memory address xaddr
     XADR! !
    ;
--- Execution time if cached = 43.6us or 2.8ms non-cached
pub XC@ ( xaddr -- byte )                    --- read a byte from virtual memory address xaddr
    XADR C@
    ;
pub XC! ( byte xaddr -- )                    --- write a byte to virtual memory address xaddr
    XADR! C!
    ;

pub XW@ ( xaddr -- word )                    --- read a byte from virtual memory address xaddr
    XADR W@
    ;


--- DUMP MEMORY ACCESS METHOD MODIFIER
--- Usage: 0 $200 SD DUMP

pub SD         ' XC@ dmm W! ' XW@ dmm 2+ W! ' X@ dmm 4 + W! ;


{

--- 141114 - examining methods of multiple cog access with SDFS running in it's own cog
pri SDCMD:
     SWITCH
     "R" CASE sdsrc @ sddst @ _SDRD sdres ! BREAK
    "W" CASE sdsrc @ sddst @ _SDWR sdres ! BREAK
    "Z" CASE _!SD sdres ! BREAK
     "P" CASE !SDIO BREAK
     "?" CASE _CARD? sdres ! BREAK
     "?" sdres !    --- unknown command
     ;

8 LONGS sdstk
pub SDCARD.TASK
     !RP sdstk SP! !SP
     sdtask C~~                --- indicate SD task is running for auto command channel
     BEGIN
       sdcmd C@ ?DUP IF SDCMD: sdcmd C~ THEN
     AGAIN
     ;
}


{
CHANGELOG:
160804	added FCREATE$ which creates a file and preallocates clusters.

}



--- EASYFILE CODE ---

--- PARTITION TABLE ---

--- Partition table image - copied here
16 LONGS parts			--- Room for 4 entries of 16 bytes

--- These are the offset constants compiled as absolute addresses (for 1st partition)
--- Many names have not been added to the dictionary to save space

parts    ORG
1    DS+ --- state		--- 00 = inactive, $80 = active
1    DS+ --- head		--- beginning of paritiion
2    DS+ --- cylsec		--- beginning of partition cylinders/sector
1    DS+ --- partype		--- type of partition
1    DS+ --- ehead		--- end of partition head
2    DS+ --- ecylsec		--- end of partitiion cylinder/sector
4    DS fatptr
4    DS+ --- size

--- BOOT RECORD ---

{
Boot Record
The boot record occupies one sector, and is always placed in logical sector number zero of the "partition".
If the media is not divided into partitions, then this is the beginning of the media.
This is the easiest sector on the partition for the computer to locate when it is loaded.
If the storage media is partitioned (such as a hard disk), then the beginning of the actual media contains an MBR (x86)
 or other form of partition information.
In this case each partition's first sector holds a Volume Boot Record.
}




#24 LONGS fat32 ( 90/96 used )
fat32    ORG
3    DS+
8    DS oemname
2    DS byte/sect
1    DS sect/clust
2    DS rsvd
( 16 )
1    DS fats			--- Copies of FAT
4    DS+			--- root entry count (FAT16)
1    DS+			--- media
2    DS+
2    DS+			--- sect/trk
2    DS+			--- heads
4    DS+			--- hidden sectors
( 32 )
4    DS sectors			--- Number of sectors * byte/sect (512) = capacity
--- offset = 36
4    DS sect/fat		--- Number of sectors per FAT table
2    DS+			--- fatflags
2    DS+			--- fatver
4    DS rootcl			--- Cluster Number of the Start of the Root Directory
2    DS+			--- info = Sector Number of the FileSystem Information Sector  (from part start)
2    DS+			--- boot = Sector Number of the Backup Boot Sector (from part start)
#12  DS+
3    DS+
4    DS serial			--- #67 serial number of partition
#11  DS volname			--- #71 volume name
8    DS fatname			--- always FAT32 - (don't trust)

--- create room for some system variables in this table
1    DS mounted			--- true flag if mounted (but also depends upon other checks)
1    DS clshift			--- cluster shift (fast  multiplier)
4    DS rootdir			--- sector address of root directory


--- DIR BUFFERS ---

--- A copy of the original virtual address of the directory entry is kept in this array (4 entries)

4 LONGS diradr			--- virtual memory address of file's directory entry

4 LONGS file                    --- table entry for 4 open files - holds sector address

--- Directory entry table
BL LONGS dirbuf                 --- create a directory buffer for the opened file

LONG fboot                      --- boot signature - determines whether it needs to remount


--- FAT HANDLERS ---

pub @ROOT ( -- rootdiradr )	--- virtual memory address of the start of the root directory )
    rootdir @ 9<<
     ;

LONG cwdsect

pub @BOOT ( -- bootblkadr )
     fatptr @ 9<<
     ;

--- return with the starting address of the selected FAT (normally 0 or 1)
pub @FAT ( fat# -- sector )
    sect/fat @ *
     fatptr @ rsvd W@ +                    --- look at FAT1 and read sector
     +
    ;

0    == FAT1
0    == FAT2

pub CLUST>SECT ( clust# -- sector )
    rootcl @ - clshift C@ SHL rootdir @ +
    ;

pri READFAT32
     fatptr @ SECTOR                    --- Read the FAT32 boot record
     SDBUF fat32 #90 CMOVE                --- backup the FAT32 entry for direct access
    sect/clust C@ >| clshift C!            --- make a fast multiply using a shift left constant
     rsvd W@ sect/fat @ fats C@ *
     rootcl @ 2 - clshift C@ << + + fatptr @ + rootdir !
     0 @FAT ' FAT1 1+ !
     1 @FAT ' FAT2 1+ !            --- save time by precalculating FAT table addresses
    ;

pri .FAT
     CR PRINT" Mounted "
      fatptr @ SECTOR                    --- read FAT32 boot record
     cid 9 + U@ .LONG                    --- print SD card serial#
     PRINT" -" serial U@ .LONG
     SPACE oemname 8 CTYPE                --- print OEM name
     SPACE
     volname #11 CTYPE                    --- print volume name
     SPACE
     fatname 8 CTYPE                    --- print FAT32 name
    sectors @ 512 1000000 */ 0 PRINTDEC PRINT" MB ("
    sect/clust C@ BLKSIZ * 0 PRINTDEC PRINT" /cluster)"
\\\     PRINT"  with " sectors @ 0 PRINTDEC PRINT"  sectors"
    ;




HELP: MOUNT
Mount the currently selected storage device and init all 4 file handles
Read the FAT32 and set variables accordingly
}
pub MOUNT
    mounted C~ wrflgs 4 ERASE
     sectors 16 ERASE
     file 16 ERASE
     dirbuf $80 ERASE
     diradr 16 ERASE					--- erase dir entry address pointers
     BUFFERS $800 ERASE					--- clear the buffers
     0 FILE
     !SD
      ON SDERRLED					--- turn on error LED - only cleared if FAT passes muster
     IF
       mounted C~~
       0 SECTOR						--- read partition info
       $01FE SDBUF + W@ $AA55 =				--- Could it be a partition?
       IF
         $01BE SDBUF + parts $40 CMOVE			--- buffer patitions
        READFAT32					--- read the FAT32 sector
        \ PRINT"  Mounted SD Card "
         .FAT						--- display
        rootdir @ cwdsect !
         OFF SDERRLED					--- clear error indication
        boot @ fboot !					--- copy boot signature to validate mount status
       ELSE
          PRINT"  *Format Error* "
       THEN
    ELSE
       PRINT" *Card Error* "
    THEN
    ;

pub ?MOUNT
    CARD? NOT
     IF
       PRINT"  *No Card inserted!* "
       ON SDERRLED MOUNT
     THEN
    boot @ fboot @ <> mounted C@ 0= OR IF MOUNT THEN
     ;


{HELP ?SDCARD
Make sure the card is inserted or mount it if it has just been inserted
}
pub ?SDCARD
    card? C@ 0= CARD? DUP card? C! AND			--- check previous card state with now and update
      IF MOUNT THEN					--- just inserted so mount automatically
    CARD? NOT IF ON SDERRLED mounted C~ THEN		--- indicate an error if it's not inserted
    ;





--- FILE NAME HANDLERS ---

" FILENAME.TXT" 16 4 * STRING file$			--- The actual name of the file requested
--- file$ stores 4 8.3 filenames at 16 byte boundaries

pub FILE$  ( -- addrOfFilenameString )    FILE# 4 SHL file$ + ;

" FILENAMESTR " 0 STRING fname$				--- The formatted name of the file requested for internal use

--- format friendly file name into directory format
--- FILE.TXT --> FILE    TXT
pri >F83 ( str1 -- str2 )
    fname$ #11 BL FILL					--- prep fname$ as all blanks
     fname$ #11 + C~					--- ensure terminator is set
    fname$ ( str1 fname$ )
     OVER C@ "." = IF OVER LEN$ CMOVE fname$ EXIT  THEN

    "." 3RD LOCATE$ ( str1 fname$ str1ext )		--- located the extension?
    ?DUP IF						--- found an ext
       DUP >L
       3RD - ( str1 fname$ name8len ) CMOVE		--- copy across the filename part
       L> 1+ ( ext )					--- get the extension
      DUP LEN$      ( ext extLen )
      fname$ 8 + SWAP CMOVE				--- only move LEN$ chars  MJB so .JS becomes .JS(sp)
    ELSE						--- no ext found
       ( str fname$ )
       OVER LEN$ CMOVE					--- just copy the string
      THEN
    fname$
    ;




--- DIRECTORY STRUCTURE ---

[PRIVATE
#00    == @FNAME		--- File name
#08    == @FEXT			--- File extension
#11    == @ATR			--- Attribute
#13    == @CMS         		--- creation millisecond (2ms)
#14    == @CTIME        	--- creation time
#16    == @CDATE		--- creation date
#18    == @ADATE		--- access data
#20    == @FCLSTH		--- First cluster (high word)
#22    == @FTIME		--- modification time
#24    == @FDATE		--- modification date
#26    == @FCLST		--- First cluster of file (low word)
PRIVATE]
#28    == @FSIZE		--- size of file







--- return with the address of the directory buffer  in RAM
pub @DIRBUF ( -- bufadr )				--- get dir buffer address for current file# - set with FILE
     FILE# 5 SHL dirbuf +				--- index 1 of 4 32-byte directory buffers
     ;



#13 BYTES dir$						--- make room for 8.3 filename inc dot + terminator


pub DIR?    ( str -- diraddr | FALSE )
    ?MOUNT
      mounted C@ IF
      >L						--- save str ptr onto loop stack - ref as IX
       cwdsect @ 9<<					--- get virtual address of current working directory
       BEGIN ( dirptr )
         DUP XC@					--- assume the file is in the root cluster
       WHILE
        DUP XADR dir$ #11 CMOVE dir$			--- copy the name as a string
           0 OVER #11 + C!				--- ensure it's terminated correctly (previous bug)
        IX COMPARE$ IF L> DROP EXIT THEN		--- Found it, exit here with address
         BL +						--- skip to next dir entry (32 bytes)
       REPEAT
       L> 2DROP						--- failed to find it - discard parameters
     ELSE
        DROP
     THEN
     FALSE						--- Failed to find it
      ;


--- DIRECTORY ENTRY HANDLERS ---

--- update current directory entry from buffer
pub DIR!
    @DIRBUF diradr @FILE @ XADR BL CMOVE		--- copy that to the virtual address
    WRSECT    DROP					--- Force an update
    ;
--- split 6 digit decimal number into 3 two digit groups
pri DECS ( #xxyyzz -- zz yy xx )
     #100 U/MOD #100 U/MOD
    ;

--- update file modification/create date in dir buf
pri FDATE! ( #yymmdd field -- )				--- Date (7/4/5 bits, for year-since-1980/month/day)
     SWAP
    #20.00.00 +						--- arrange as decimal YYMMDD from 1980 ( 2000.0000 + 1980.0000 - )

     DECS 9 SHL SWAP 5 SHL + +
    SWAP
pri @DIR! ( word field -- )
     @DIRBUF + W!					--- write to directory entry as new date
     ;

--- update file modification/create time in dir buf
pri FTIME! ( #hhmmss field -- )				--- Time (5/6/5 bits, for hour/minutes/doubleseconds)
     SWAP
     DECS #11 SHL SWAP 5 SHL + SWAP 2/ +
     SWAP @DIR!
     ;

--- DATE TIME STAMPING ---

IFNDEF DATE@
#150101    == DATE@
#120000    == TIME@
}

{HELP FSTAMP
Update the modified time and data of the current file
}
pub FSTAMP ( -- )
     DATE@ @FDATE FDATE! TIME@ @FTIME FTIME!              --- update file date and time with current
     ;

pri .FYEAR ( fdate -- )
     9>> #1980 + $250A .NUM
     ;

IFNDEF .ASMONTH
pri .ASMONTH ( index -- )
     >N 1- 3 *
     " JanFebMarAprMayJunJulAugSepOctNovDec" + 3 CTYPE
     ;
}
--- print date in Unix format
pri .FDATE ( fdate -- )
     DUP 5 SHR .ASMONTH					--- extract day of the month to index into name string
      ( date )
      $1F AND $230A .NUM				--- day of the month
     ;
pri .FTIME ( ftime -- )
      DUP #11 SHR $20A .NUM PRINT" :"
      5 SHR 6 BITS $20A .NUM
     ;



--- CLUSTER HANDLERS ---

{
--- display cluster usage from FAT
pub .FATMAP
     sect/fat 0 DO
       I $3F AND 0= IF .INDEX THEN
       I FAT1 + SECTOR
       sectcrc @FILE W@
       IF PRINT" *" ELSE PRINT" ." THEN
       lastkey C@ $1B = IF LEAVE THEN
     LOOP
     ;

}
--- Find the next free directory entry
pri NextFreeDir ( -- xadr )
     0
     cwdsect @ 9<< sect/clust C@ BLKSIZ *
     ADO I XC@ 0= IF I OR LEAVE THEN BL +LOOP
     ;


{ CLUSTER CHAIN CODES
If value => $0FFF.FFF8 then there are no more clusters in this chain.
$0FFF.FFF7 = bad
0 = free

}
pri @CLUSTER ( index -- xadr )
     2* 2* FAT1 9<< +
    ;
pri CLUSTER@ ( index -- cluster )
      @CLUSTER X@
     ;



{HELP CLUSTERS? ( size -- startcluster )
Find free clusters for the file size in bytes - 0 = all
return with address of first free cluster
Here's a dump of the end of the cluster table.
0062_7820:   0000.0409  0000.040A   0000.040B  0000.040C   ................
0062_7830:   0FFF.FFFF  0000.040E   0000.040F  0000.0410   ................
0062_7840:   0FFF.FFFF  0FFF.FFFF   0000.0413  0000.0414   ................
0062_7850:   0FFF.FFFF  0000.0000   0000.0000  0000.0000   ................
0062_7860:   0000.0000  0000.0000   0000.0000  0000.0000   ................

$2.0000 CLUSTERS?  ok
.S  Data Stack (2)
$0000.0415 - 1045
$DEAD.BEEF - -559038737 ok
$415 @CLUSTER $40 SD DUMPL
0062_7854:   0000.0416  0000.0417   0000.0418  0FFF.FFFF   ................
0062_7864:   0000.0000  0000.0000   0000.0000  0000.0000   ................

check for fragmented clusters
$4.0000 0 DO I CLUSTER@ DUP $0FFF.FFF8 < OVER 1- I <> AND SWAP 0<> AND IF CR I .LONG THEN LOOP


}
pri CLUSTERS? ( size -- startcluster )
     BLKSIZ 1- + 9>> sect/clust C@ / ( clusters )				--- calculate clusters required
      0
     BEGIN
       BEGIN DUP CLUSTER@ WHILE 1+ REPEAT						--- find a free cluster
       ( clusters index )
       0 OVER 4TH ADO I @CLUSTER X@ OR DUP IF NIP I SWAP LEAVE THEN LOOP	--- check for sufficient contiguous clusters
       ( clusters chain flag )
     WHILE
       1+
    REPEAT
      ( clusters startcluster )							--- allocate these clusters
      2DUP SWAP ADO I 1+ I @CLUSTER X! LOOP					--- link clusters
      DUP ROT + 1- $0FFF.FFFF SWAP @CLUSTER X!					--- mark end cluster
     ;


pri StartCluster ( diradr -- cluster )						--- get the file starting cluster for diradr
--- = virtual memory address of file's directory entry
    DUP @FCLST + W@ SWAP @FCLSTH + W@ W>L
    ;






pub FSIZE@			@DIRBUF @FSIZE + @ ;

pub FSECT@ ( -- sect )		file @FILE @ ;

{HELP FILE@ ( -- xadr )
Fetch the virtual memory address of the currently open file
}
pub FILE@ (  -- xadr )		FSECT@ 9<< ;

--- VIRTUAL FILE ACCESS ---

{HELP FC! ( byte offset -- )
Store a character byte to the file with the offset
This write will only write to an open file and can address 4GB within that file which can be at any offset
in the media, even beyond 4GB.
}
pub FC! ( byte faddr -- )                     --- store a byte in virtual memory relative to the start of the file with limits
\\\    FSECT@ ?DUP IF
     FILE@ ?DUP IF + 0 MAX FSIZE@ MIN XC! ELSE 2DROP THEN
     ;
--- fast file byte read - skips checks
pub FC@ ( faddr --- byte )
     FILE@ ?DUP IF + 0 MAX FSIZE@ MIN XC@ ELSE FALSE THEN
     ;
pub FFC@ ( faddr -- byte )
	FILE@ + XC@
	;
--- SEQUENTIAL FILE ACCESS ---

--- maintain read and write pointers for 4 files ---
4 LONGS fread					--- access via @FILE for current file:   fread @FILE   or    @FREAD
4 LONGS fwrite					--- access via @FILE for current file:   fwrite @FILE  or    @FWRITE
BYTE fstat					--- current status of file system

pub @FREAD ( -- readptr )
    fread @FILE
    ;
pub @FWRITE ( -- writeptr )
    fwrite @FILE
    ;

--- return with remaining bytes in file
pub FREM ( --- rem )     @FWRITE @ DUP IF FILE@ FSIZE@ + SWAP - THEN ;


WORD fkey						--- backup for input device when input is switched to file

--- Read in the next character in the virtual buffer as part of the console input stream
pri FGET ( -- ch )
    @FREAD @ XC@					--- Read a single character
    DUP 0=
       IF "X" fstat C! fkey W@ ukey W!			--- stop when null encountered and return to previous input device
       ELSE @FREAD ++					--- update index otherwise
       THEN
    ;

--- Write a character into the logical end of the file and update the write pointer
\ 280us typical
pub FPUT ( ch -- )
    ?DUP IF						--- ignore null characters (but will write nulls if another bit in long is set)
pub FPUTB ( byte -- )					--- write byte even if it is null
      FILE@ 0<> @FWRITE @ AND				--- check if file is opened and a valid write pointer is set (APPEND)
     IF							--- don't write if a file is not opened
      @FWRITE @ FILE@ FSIZE@ BLKSIZ ALIGN + =>		--- file full?
         IF DROP "O" fstat C! EXIT THEN			--- Don't write to beyond end of file - fstat = O for OVERFLOW
							--- still room in the file so just write it
      @FWRITE @ XC!					--- write the character to the file
      @FWRITE @ FILE@ FSIZE@ BLKSIZ ALIGN + 1- =	--- last byte in file?
         IF "F" fstat C! EXIT THEN			--- Warn file is now full - fstat = F for FULL, exit now!

      @FWRITE ++
       0 @FWRITE @ XC!					--- Insert a null terminator (overwritten by the next character)
     ELSE
       DROP "N" fstat C!				--- no file - fstat = N
     THEN
     THEN
     ;

--- Redirect the console input to read the file sequentially
pub FILE>
pub FINPUT
    FILE@ IF ukey W@ fkey W! ' FGET ukey W! THEN
     ;

{HELP >FILE ( -- )
Redirect character output via uemit to the open file using "fptr" which is set to the start of the file when opened
If the file is not opened and a valid write pointer set then output will be discarded
}
pub >FILE
pub FOUTPUT ( -- )
     FILE@ IF ' FPUT uemit W! ELSE NULLOUT THEN
    ;


pub FCLOSE						--- Close the current file
    FLUSH						--- make sure that this file has any modifications written back.
     _sector ~~						--- clear sector (-1)
     file @FILE ~					--- clear file pointer
     NULL$ FILE$ $!					--- blank out file name
     @DIRBUF BL ERASE					--- wipe dir entry
     ;


HELP: FCREATE$ ( size namestr -- flg )
--- Create a new file by name but if it already exists then delete the old one and reuse the dir entry.
--- preallocate 1M (hidden) per file in cluster table so only dir entry needs updating.
--- last file can increase beyond 1M if needed
}
pub FCREATE$ ( size namestr --  )
\     FCLOSE						--- close any open file on this channel - clears dir entry buffer
    >F83 ( namestr -- f83str )				--- make sure it's ready in the correct 8.3 format
     @DIRBUF #11 CMOVE					--- write the name of the file to the directory buffer
     $20 @DIRBUF @ATR + C!				--- set archive attribute
     DATE@ @CDATE FDATE! TIME@ @CTIME FTIME!		--- stamp create date and time
     DUP @DIRBUF @FSIZE + !				--- Set size of file to maximum
     CLUSTERS? ( startcluster )				--- preallocate clusters
     L>W @FCLSTH @DIR! @FCLST @DIR!			--- write first cluster
     FSTAMP
     --- add directory record to directory
     NextFreeDir ( xadr ) XADR ( bufptr )
     @DIRBUF SWAP BL CMOVE				--- write directory entry
     WRSECT DROP
     ;

--- make file
pub mk ( size <name> -- ) IMMEDIATE		[C] GRAB GETWORD FCREATE$ ;



{HELP FOPEN# ( diradr -- sector )
Open the file pointed to by the virtual directory entry address
}
pub FOPEN# ( xdiradr --- sector )
       DUP diradr @FILE !				--- save RAM address of directory entry
        DUP $7FFF > IF XADR THEN			--- only convert virtual addreses, pass physical addresses
       DUP @DIRBUF BL CMOVE				--- copy directory entry to local buffer
       StartCluster CLUST>SECT
       DUP file @FILE !					--- save address of file
       DUP 9<< @FREAD !					--- Set virtual memory FREAD address to start of file
       @FWRITE ~					--- disable writing by specifying illegal write address = 0
     ;

{HELP FOPEN$ ( namestr -- sector )
Open the file with the 8.3 name and return with its sector or 0 if failed
The variable fstat can be checked for more information if there was an error
Execution time ~ 10ms sample:
" FIRMWARE.ROM" LAP FOPEN$ DROP LAP .LAP 2.887ms ok
Usage: " SYSLOG.TXT" FOPEN$ IF etc etc
}
pub FOPEN$ ( namestr -- sector )
     FCLOSE
     DUP C@
     IF							--- skip null name
       DUP C@ "/" = IF 1+ THEN				--- ignore leading / in file name
       DUP LEN$ #12 > IF "!" fstat C! DROP FALSE EXIT THEN         --- abort with ! status if name is too long
       DUP FILE$ $!					--- set the name for this file
      >F83 DIR? DUP					--- find the dir entry
         IF FOPEN#    ( sector )                        --- open the file from the dir entry
        ELSE "?" fstat C!				--- else ? not found
          THEN
     ELSE
       DROP FALSE "?" fstat C!
     THEN
    ;

{HELP FOPEN ( <name> -- )
Open a file interactively with the name specified in the input stream
Report back to the console
}
pub FOPEN ( <name> -- ) IMMEDIATE
    GETWORD
     FOPEN$ ?DUP
       IF PRINT" ...opened at "  .LONG SPACE
       ELSE PRINT"  not found "
       THEN
    ;


--- Open or create a file
pub FMAKEOPEN$ ( name -- flg )
	DUP FOPEN$ NOT IF $10.0000 OVER FCREATE$ THEN FOPEN$
	;



--- FILE APPEND OPERATIONS ---

--- APPEND TO TEXT FILES USING AN EOF MARKER


#1         == RCDSZ					--- Minimum record increment, normally 1 for text files, needs to be 2^n, n>=0
RCDSZ >|    == >|RCDSZ

--- virtual memory address for rcd record number (for text files rcd = char pos)
pub @RCD    ( rcd -- xadr )
     >|RCDSZ SHL FILE@ +
     ;

--- Erase the current file by overwriting with nulls
pub -FERASE
     FILE@ 0EXIT
     FILE@ FSIZE@ ADO 0 I X! 4 +LOOP
     FLUSH
     ;

BYTE eof						--- end of file character

pri APPEND.BLK ( -- relblk )
    FILE@ 9>> FSIZE@ 9>> OVER + SWAP     ( max min )
     BEGIN
      2DUP - 2/ OVER +        ( max min mid )		--- Find new mid point
        SECTOR                  ( max min )
     2DUP - 1 >
     WHILE
       SDBUF C@ eof C@ =        ( max min flg )		--- if true then too high
       IF 2DUP - 2/ OVER + ROT DROP SWAP
       ELSE 2DUP - 2/ OVER + NIP
       THEN
    REPEAT
      NIP
    ;

{HELP APPEND ( eof -- xptr )
Find the EOF marker (normally a null) and set the write pointer and result to this ready to append
return with null if failed.
}
pub APPEND ( eof -- ptr )
     eof C!
\\\     SDBUF BLKSIZ + DUP C@ >R C~			--- ensure we have a null after the block (but save)
    FILE@ DUP 0EXIT DROP				--- exit with false if there is no file opened
     APPEND.BLK ( -- relblk )				--- find the active block to use
     9<< SDBUF LEN$ BLKSIZ MIN +			--- add in offset allowing for a full block as well
     FILE@ FSIZE@ + OVER = IF DROP FALSE THEN
     DUP @FWRITE !
\\\     R> SDBUF BLKSIZ + C!
     ;

{HELP RW
Make current file read/write
}
pub RW			FILE@ DUP @FWRITE ! @FREAD ! ;




--- FILE SHELL COMMANDS ---

pub RENAME$ ( new$ -- )
     FILE@ IF
       >F83 @DIRBUF #11 CMOVE				--- update local copy of directory entry
       DIR!
    THEN
      DROP
    ;

pub RENAME ( <oldname> <newname> ) IMMEDIATE
    GETWORD FOPEN$ IF PRINT"  to " GETWORD RENAME$ ELSE DROP PRINT"  No file opened " THEN
    ;

pub DELETE ( <name> -- ) IMMEDIATE
     GETWORD FOPEN$ IF PRINT" NOT IMPLEMENTED YET" THEN
     ;
ALIAS DELETE rm

--- Load a file as console input - scripts or source code
pub FLOAD ( <name> -- ) IMMEDIATE
    GETWORD FOPEN$ 0EXIT FINPUT
    ;

--- exception handler - if word not found then run from file - point unum to this code
pub FRUN        @word DUP C@ "." = IF 1+ THEN FOPEN$ 0EXIT FINPUT ;


--- Print the contents of the file specified by the string if it exists
pub FPRINT$ ( file$ -- )
     FOPEN$ 0EXIT
pub (cat) --- type out the currently open file else ignore
     FILE@ ?DUP 0EXIT
     lastkey C~						--- clear any preexisting console escape
     BEGIN
       DUP XC@ DUP lastkey C@ $1B <> AND		--- null end of file or escape key?
     WHILE						--- no, continue
       DUP $0A = IF $0D EMIT THEN			--- insert CR for an LF
       EMIT
       1+
     REPEAT
     2DROP
     ;

{HELP cat <name>
List the contents of the specified file
}
pub cat ( <name> -- ) IMMEDIATE				--- List the file as text
    [COMPILE] FOPEN
    CR (cat)
    ;


--- DIRECTORY PATH CONTROL ---

" /" #11 STRING cwd$

pub cd     IMMEDIATE
     GETWORD
pub cd$ ( dirstr -- )
     DUP C@ "/" =                             --- from root directory?
     IF
       rootdir @ cwdsect ! " /" cwd$ $!
       1+                                --- point to remainder of string after preceding /
     THEN
     DUP FOPEN$ IF $10 @DIRBUF @ATR + SET?  IF cwd$ $! FSECT@ cwdsect ! EXIT THEN THEN
     DROP
    ;

pub pwd     cwd$ PRINT$ ;

IFDEF PCB$
pub .PATH      PCB$ PRINT$ PRINT" @" serial U@ .LONG SPACE pwd ."  $ " ;
}
IFNDEF PCB$
pub .PATH      PRINT" Tachyon@" serial U@ .LONG SPACE pwd ."  $ " ;
}
{HELP PROMPT ( on/off -- )
Turn on the path prompt and and suppress the ok response or revert back to normal Forth ok
}
pub PROMPT ( on/off -- )        DUP NOT OK ' .PATH AND prompt W! ;




--- DIRECTORY LISTING ---

{
DIRECTORY ENTRY
FILENAME
EXT
ATR
CMS
CTIME
CTIME
CTIME
CDATE
CDATE
ADATE
ADATE
FCLSTH
FCLSTH
FTIME
FTIME
FDATE
FDATE
CLUST
CLUST
FSIZE
FSIZE
FSIZE
FSIZE
0080_0140:   57 45 4C 43  4F 4D 45 20   46 54 50 20  00 00 87 83   WELCOME FTP ....
0080_0150:   A2 44 A2 44  00 00 D9 BE   83 44 0F 00  90 00 00 00   .D.D.....D......

LEGAL SYMBOLS
! # $ % & ' ( ) - @ ^ _ ` { } ~
Directory Attribute flags
0    Read Only
1    Hidden
2    System
3    Volume label
4    Directory
5    Archive

Directory types - first byte
Normal record with short filename - Attrib is normal
Long filename text - Attrib has all four type bits set
Unused - First byte is 0xE5
End of directory - First byte is zero
}


--- print the symbol(s) for each active directory name attribute
pri .ATR ( atr -- )
    " rhsvda" SWAP 6
     FOR
       DUP 1 AND IF OVER C@ EMIT ELSE PRINT" ." THEN
       2/ SWAP 1+ SWAP
     NEXT 2DROP
    ;


( FIRMWARE.ROM .....a 0000.620A    07/07/2014 11:58:14   5,536 )

pri .DIR ( addr -- )
     DUP C@                                --- ignore blank entries as closed
     IF
      DUP 8 CTYPE PRINT" ." DUP 8 + 3 CTYPE            --- print the file name with spaces included (formatted listing)
       SPACE DUP @ATR + C@ .ATR SPACE                --- print attributes as alphas
      DUP StartCluster CLUST>SECT .LONG                --- print sector number
       4 SPACES DUP @FDATE + W@  DUP .FDATE            --- print date
       SPACE .FYEAR
       SPACE DUP @FTIME + W@ .FTIME                --- print time
       3 SPACES @FSIZE + @ .DECX                --- print size
     ELSE
       DROP PRINT" *CLOSED*"
     THEN
    ;

pri (.DIR) I CR .DIR ;


{
DIR     PBJTECH.SDL
------------------------------------------------------------------------------
NAME    .EXT ATRS   SECTOR     DATE       TIME       SIZE
CE1372  .JPG .....a 0000.7C17    20/06/2013 02:36:52   736,486
}

WORD udir
pub DIR
\           CE1372  .JPG .....a 0000.7C17    20/06/2013 02:36:52   736,486
\    CR PRINT" NAME    .EXT ATRS   SECTOR       DATE       TIME       SIZE "
    ' (.DIR) --- use this method for listing the directory
pri (DIR) ( code -- )
    ?MOUNT
     CR volname #11 CTYPE
pub (SLIST) ( method -- )
    udir W!
     1 FILE FCLOSE			--- always use FILE#1 for directory and any temp read only
    cwdsect @ sect/clust C@		--- scan and list rootdir by sector up to one cluster long
     ADO
       I SECTOR
       ACTIVE?
       IF
        SDBUF BLKSIZ			--- scan the buffer for dir entries
         ADO				--- up to 16 dir entries/sector
           I @ATR + C@ $0F >            --- accept only valid entries
         I C@ $80 < AND			--- but ignore if 1st character has 8th bit set
           I C@ "?" <> AND		--- ignore "deleted" entries
            IF udir W@ CALL THEN        --- all good, list this one using the directed method
        BL +LOOP			--- next dir entry 32 bytes (assumes standard 8.3)
       ELSE
         LEAVE				--- no more dir sectors - leave loop
      THEN
    LOOP
    ;

--- Print the file name at the current loop index I
pub .FNAME ( --- )
     I C@ BL >                            --- skip invalid index/entry
     IF
       $10 I @ATR + SET? IF PRINT" [" THEN
       #11 0 DO
         J I + C@ DUP BL > IF I 8 = IF PRINT" ." THEN DUP EMIT THEN DROP
       LOOP
       $10 I @ATR + SET? IF PRINT" ]" THEN
     THEN
;

--- print the Unix time or year if the file is older than 6 months
pri .UTIME (  -- )
---  print time
      2 SPACES I @FTIME + W@ .FTIME                    // read file modification time
    ;


BYTE lscnt PRIVATE

--- directory list method for ls
--- FORMAT: CE1372  .FTH   CE1372  .PDF   CHARLCD .JPG   IOT5500 .ROM   DRAGON  .JPG
pri (ls)
     lscnt C@ 5 MOD 0= IF CR THEN			--- 5 files per line
     $10 I @ATR + SET?					--- format a directory name
     IF
       PRINT" [" I 8 CTYPE PRINT" ]" 5 SPACES		--- Use [ ] to enclose name
     ELSE
       I 8 CTYPE					--- normal, print name and opt ext
       I 8 + C@ BL <>
         IF  PRINT" ." I 8 + 3 CTYPE 3 SPACES ELSE 7 SPACES THEN
     THEN
     1 lscnt C+!
    ;

--- List a single directory entry in FTP compatible format
pri (.LIST) ( <index> )
      PRINT" -rwxrwxrwx 1 502     500"			--- dummy permissions
      I @FSIZE + @ $2C0A .NUM				--- print file size "1048576"
      SPACE
      I @FDATE + W@ .FDATE				--- DATE

--- most systems expect either the time or the year if it is older than 6 months
       .UTIME
       SPACE .FNAME CR					--- FILE NAME "LOG0001.TXT"
    ;

pub .LIST        ' (.LIST) (SLIST) ;			--- set list method


--- list the directory in wide and simple format
--- ls -l in long format

pub ls IMMEDIATE
     delim 1+ C@ BL =
     IF
       GETWORD " -l" $=
       IF CR .LIST EXIT THEN
     THEN
     lscnt C~ ' (ls) (DIR)
    ;



{ FILES
List the currently open files
Usage:
0 FILE   ok
FOPEN SYSLOG.TXT...opened at 0000.4B28  ok
1 FILE  ok
FOPEN SDCARD.FTH...opened at 0000.5620  ok
2 FILE   ok
FOPEN LOG0001.TXT...opened at 0000.3B28  ok
3 FILE  ok
FOPEN LOG0002.TXT...opened at 0000.3C28  ok
FILES
#0 SYSLOG  .TXT .....a 0000.4B28    04/11/2013 19:02:22   1,048,562
#1 SDCARD  .FTH .....a 0000.5620    20/11/2013 03:23:56   16,590
#2 LOG0001 .TXT .....a 0000.3B28    04/11/2013 01:25:18   131,072
#3 LOG0002 .TXT .....a 0000.3C28    04/11/2013 01:25:18   131,072 ok
}



pub .FILE	filesel C@
pub .FX		CR PRINT" #" DUP PRINT SPACE FILE @DIRBUF .DIR ;
pub .FILES
	FILE# 4 0 DO I .FX LOOP FILE
     ;





--- FILE SYSTEM ADD-ONS ---


\ : FIXLF		FILE@ BEGIN DUP XC@ ?DUP WHILE $0A = IF $0D OVER XC! THEN 1+ REPEAT DROP FLUSH ;

--- Return with the size of the "ROM", 64K if the EEPROM is larger > 32K and the file is too.
pri ROMSZ ( -- size )		0 E@ $8000 E@ <> FSIZE@ $1.0000 = AND IF $FF00 ELSE $8000 THEN ;
ifndef FIXBIN
pub FIXBIN ( src cnt -- )
	5 C~									--- zero our cksum
	0 0 $16 ESAVEB								--- backup header into EEPROM (with checksum zeroed)
	SWAP @EE DROP EERD DROP							--- Setup EEPROM for sequential read from src address
 	  FOR ackI2C@ 5 C+! NEXT						--- add up all the bytes in memory
	1 I2C@ DROP I2CSTOP							--- terminate EEPROM read
	5 C@ NEGATE 5 EC!
	;
}


--- These are a couple of add-ons to the file system which allow the "ROM" to be saved to a file called default FIRMWARE.BIN
pub SAVEROM IMMEDIATE
	delim C@ BL = IF GETWORD ELSE " FIRMWARE.ROM" THEN
pub SAVEIMG ( filename$ -- )
	FOPEN$ NOT IF $1.0000 FILE$ FCREATE$ THEN
        0 $8000 FIXBIN							--- fix up the image so checksum matches "binary" load
        PRINT"  Saving EEPROM image to " FILE$ PRINT$			--- prompt
        0 FILE@ FSIZE@ ( start size )					--- 150108 Just save everything - only be selective during load
        ADO
          DUP SDBUF BLKSIZ ELOAD BLKSIZ +
          SDBUF I 9>> SDWR DROP						--- write one full sector
          SPINNER
          BLKSIZ
	+LOOP
	DROP								--- discard source address
	_sector ~~							--- invalidate sector as we used raw methods to write image.
	FSTAMP DIR!
;



pub LOADROM IMMEDIATE
    delim C@ BL = IF GETWORD ELSE " FIRMWARE.ROM" THEN
pub LOADIMG ( filename$ -- )
    1 FILE FOPEN$ 0EXIT
pri (LOADROM)
     PRINT"  Loading EEPROM image " FILE$ PRINT$ PRINT"  to EEPROM "
     FILE@ 0 ROMSZ
     ADO DUP I + XADR I ep ESAVE ep +LOOP				--- EEPROM page size at a time.
     DROP
     ;

--- Generate a file CRC
pub FCRC ( -- crc )
     0 FILE@ FSIZE@
    ADO
          I XADR BLKSIZ
       ADO
         I C@ SWAP
            8 FOR
               2DUP XOR 1 AND
             ROT 2/ ROT 2/ ROT
               IF $A001 XOR THEN
            NEXT
          NIP
       LOOP
     BLKSIZ +LOOP
     ;

HELP: ?AUTOLOAD ( -- )
Check if new firmware is available and if CRC is correct then load and reboot
}
pub ?AUTOLOAD
    MOUNT
    " FIRMWARE.ROM" FOPEN$ 0EXIT
    ."   ...CHECKING FOR NEW FIRMWARE...."
    0
    $8000 0 DO I FILE@ + X@ I E@ <> IF LEAVE 1+ THEN 4 +LOOP
    IF ." LOADING NEW FIRMWARE " (LOADROM) REBOOT ELSE ."  NONE FOUND " THEN
    ;




HELP: QV ( <filename> -- )
Quick view of file header in ASCII dump format
}
pub QV  GETWORD FOPEN$ 0EXIT FILE@ $100 SD DUMPA ; IMMEDIATE


DATE@ build.date E! TIME@ build.time E!
]~
\ RECLAIM
?BACKUP
END


