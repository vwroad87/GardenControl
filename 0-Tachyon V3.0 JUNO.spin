' NOTE: V3 requires BST (or PropellerIDE) to compile due to the >1024 DAT symbols

DAT { *** CHANGELOG *** }
version       long 300_160819
vertime       word 2230
vername       byte "3.0 JUNO"                   ' fixed 8 character version name

' serial console parameters
baudrate      long    baud                      ' The baudrate is now stored as a variable
              byte    rxd,txd,0,0               ' default pins for console

                        org     $10
s                       ' just an offset to be used in DAT sections rather than the distracting +$10

CON { *** CLOCK MODES *** }
{
_clkmode        = xtal1 + pll8x
_xinfreq        = 10_000_000            ' <--- AUTOMATIC 5 or 10MHz operation change at boot
sysfreq         = 80_000_000
'}
' { 6MHZ CRYSTAL
_clkmode        = xtal1 + pll16x
_xinfreq        = 6_000_000
sysfreq         = 96_000_000
'}
baud            = 115200                ' <-- user change - tested from 300 baud to 3M baud

{{

.:.:-- TACHYON --:.:.

A very fast and very small Forth byte code interpreter for the Propeller chip.
2012..2016 Peter Jakacki



STARTUP SCREEN

VER:    Propeller .:.:--TACHYON--:.:. Forth V3.0 JUNO 300160720.0000
FREQ:   80MHZ (PLLEN OSCEN XTAL1  PLL8X )
NAMES:  $5871...74C6 for 7,253 bytes (+741)
CODE:   $0930...3D70 for 13,376 bytes (+2,307)
RAM:    6,913 bytes free
BUILD:  FIRMWARE BUILD DATE 000000:000000   BOOTS:  4   runtime 329,069
BOOT:   EXTEND.bootPOLL:   DEMO0
MODULES LOADED:
346D: VGA.fth             VGA text driver 150709-2200
1787: EXTEND.fth          Primary extensions to TACHYON kernel - 160720-1500
ROMS
0848 VGA32x15
0236 HSSERIAL
1648 SIDEMU
1940 QUADUART
0196 MONO16
1900 F32       POLL:   DEMO0

----------------------------------------------------------------



FEATURES
V2
Stacked backward branch references - fast and simple looping
Fast load features
Large receive buffer
Top 4 stack parameters are accessed as fixed registers - overflow into hub RAM
Small memory footprint
Low level words and run-time bytecode interpreter in PASM
Byte codes are read from hub RAM and directly address first 256 longs of PASM code in cog
User PASM mode via stacks
Interpreted bytecode definitions are referenced  as:
        2 bytes -  vectored CALL opcode + byte index into 512 entry table

All literals and strings are byte aligned
Fast access Forth registers avoids deep stacks and juggling
Fast I/O bit-bashing support for clocked and asynchronous data (2.8MHz clock speed)
                Flexible SPI or I2C PASM code support words in kernel
                Construct fast serial drivers with minimal code
VM Kernel compiled in standard manner via Spin tools so other Spin objects can be combined
Four stacks in COG RAM: Data, Return, Loop, and Loop Branch
        Access loop indices outside of definitions allows efficient factoring
        Avoids manipulation and corruption of return stack
        Static stack arrays for direct addressing of stack items
        Intrinsically safe data stack overflow and underflow - optional error reporting
400ns minimum instruction cycle time (single bytecode, hub access average)
Empty loops can execute in 550ns to 875ns (absolute worst case)
Two to one stack operations ( + * AND etc) inc opcode fetch take 900ns to 1.087us (absolute worse case) *
Flexible number input using common symbols for prefixes and suffixes as well as allowing intermixed symbols
V2.4
Adds KEY! (KEY)
Modifies console KEY now returns with null if there was no key - KEY?

----------------MEMORY MAP---------------

160718
256 entry XCALL saves >400 bytes over 512 entries for larger apps
Kernel used 165 entries
-----------------------------------------------------------------------------------------------
vecsize = 256

39A3: EASYFILE.fth        FAT32 Virtual Memory Access File System Layer V1.1 150213-1530
337C: SDCARD.fth          SD CARD Toolkit - 150827.0000
330B: P1656.fth           P1656 HARDWARE DEFINITIONS 160325.0000
1787: EXTEND.fth          Primary extensions to TACHYON kernel - 160627-1200

NAMES:  $4F2B...70EC for 8,641 bytes (+1,377)
CODE:   $0924...481E for 16,122 bytes (+3,707)
CALLS:  0 vectors free
RAM:    1,805 bytes free

-----------------------------------------------------------------------------------------------
vecsize = 512

3CB0: EASYFILE.fth        FAT32 Virtual Memory Access File System Layer V1.1 150213-1530
3724: SDCARD.fth          SD CARD Toolkit - 150827.0000
36B8: P1656.fth           P1656 HARDWARE DEFINITIONS 160325.0000
1BC7: EXTEND.fth          Primary extensions to TACHYON kernel - 160627-1200

NAMES:  $4F3E...70E9 for 8,619 bytes (+1,377)
CODE:   $0924...49E0 for 16,572 bytes (+3,376)
CALLS:  185 vectors free
RAM:    1,374 bytes free
HERE .WORD 49E0 ok
@NAMES .WORD 4F3E ok
-----------------------------------------------------------------------------------------------

vecsize = 256 and tigher memory + ROMs
MODULES LOADED:
39BB: EASYFILE.fth        FAT32 Virtual Memory Access File System Layer V1.1 150213-1530
3394: SDCARD.fth          SD CARD Toolkit - 150827.0000
3323: P1656.fth           P1656 HARDWARE DEFINITIONS 160325.0000
1787: EXTEND.fth          Primary extensions to TACHYON kernel - 160627-1200

NAMES:  $52EE...74B0 for 8,642 bytes (+1,377)
CODE:   $0930...4836 for 16,134 bytes (+3,707)
CALLS:  0 vectors free
RAM:    2,744 bytes free


-----------------------------------------------------------------------------------------------

}}


'-------------------- WHAT'S NEW --------------------'

{HELP CHANGELOG
V3
160804  Added kernel version of WORDS. EMIT now has translation table for first 16 control codes such as LF suppression
160803  Fixed sneaky bug in ping-pong networking - rxdat needed to be initialized to zero but was compiled as a "res"
160719  Added ROMs into free space that later is overwritten by metacompile words but SAVEROMS moves these to upper EEPROM
        V3 is defined and leaves TRUE on the stack
V2.10   Memory map optimizations
100718  Reducing reserved XCALL table to 256 longs and removing extra call methods - but allowing for easy resize anyway
        Removed VCALL and ZCALL
        Renamed NFA>CFA to NFA>BFA (byte field address) and >PFA to >CFA (pointer to the code itself)
V2.9
100717  Added standard escape sequences for strings such as \<anything> \$xx \t \n \r
160613  Fixed buffer areas as constants
160612  Improved ping-pong timing
160606  Updated to include functions to configure the unit
160602  Integrating new ping-pong RS485 networking driver - provides full-duplex console operation
V2.8
160524  New [SERIN] module for fast serial receive - mask and baud rate preset with [SERIN]
160514  Added an emit register to hold the last character sent (for now) to facilitate a virtual console
160509  Aligned rx image to 128 byte boundary to allow for 128 byte EEPROM page sizes
        Also dropped rxrd and rxwr to just before boundary to allow a full 512 bytes of buffer before kernel image
        This little change means faster error-free load times due to extra buffering
160508  Removed MYOP - redundant
        Added 8<< and 8>> for fast multi-bit shifts including hybrids such as 16<< 16>> 9<< 9>> (avoids stack push and pop)
160507  Fixed &00.xx.xx.xx bug
160415  Change NIP to SWAP DROP - this is only about 200ns slower than dedicated NIP due to hub access synch
        Added SPICE instruction to disable the SPI chip-enable using the COGREG mask
V2.7
150902  Add [CAP] module to perform fast I/O capture to buffers. Disable ONEWAVE
150826  Added 9BITS opcode to perform a fast $1FF AND as used in virtual memory addressing. Only needed one long inserted into >B code
150712  Rearranged task registers etc to avoid having to duplicate more than necessary for a new task.
150621  Added VGA text support
V2.6
150608  Arrange serial receive routine to use larger 2K BUFFERS during TACHYON source code load for faster loading line delays of <5ms

V2.5
150226  Add carry operation - saves carry from +- in lsb of X, fetch with "c" word
150522  Removed buggy SPIOD and replaced with MCP32 module for MCP3208 chips etc.
150521  Replaced UM/MOD2 with UM/MOD32 and UM/MOD64 and set as single byte opcodes.
        Added SQRT RUNMOD and also made RUNMOD a single-byte opcode (fraction faster)
150520  Modified UM/MOD2 to accept a bit count for justified dividend to permit faster 32-bit ops
-1500   Modified # number print words to accept a 64-bit number but high long is held in cntr REG to
        ensure compatibility with other defintions built on # words. prefix print with <D>
150520  Added UM/MOD2 and */ and changed U/MOD and U/ to bytecode defs
        Improved 2+ and 2- by using INC INC etc
        Change default base to decimal

V2.4
150126  Increased depth of return stack from 22 to 26, decreased branch stack from 6 to 5 (tested depths)
150112  Fix CALL16 for immediate words - added method to extract address and call
150105  Added CALL16 methods to CREATESTR and BCOMPILE
        Improved speed and method of +CALL from 5.4ms to 2ms (fixed bug which allowed table overflow)
141209  FIxed MYOP to use variable buffer base
141103  Made structure mismatch call ERROR which also emits a string of ?s
141030  Added WS2812CL to perform 24-bit color table lookup from 8-bit color per RGB LED pixel
1410xx
140724  Modified +FIB to become BOUNDS instead
140722  Automatically convert case of failed search word to upper case and try again
140721  Fixed COMMENT words so that the terminator is passed through (no more empty comments needing two CRs)
        Reshuffled opcodes between first and second page
        Removing KEY? in favour of a standard KEY operation which returns with a false on no key or a key with msb set
        If a word fails to be found in the dictionary and it starts with a lower-case character then convert it to uppercase and try again

140717  Adding in MYOP and removing CMPSTR so that it only loads as a RUNMOD during compling blocks of source, otherwise runs in HL bytecode.
        Working towards integrating runtime OBEX
V2.3
140717  Renamed CROP to MYOP to allow for user programmable opcode - not ever used in kernel or EXTEND
        Optimising STREND and CMPSTR
        Decided this should be V2.4 as CMPSTR is to removed from cog kernel and only loaded as a RUNMOD during TACHYON .... END loads

Refer to V2.3 for older changelogs

}


CON

rxsize          = 256                   ' Serial rx buffer - reuses serial receive cog code image – can extend into BUFFERS area

vecsize         = 256                   ' number of words reserved for XCALL table
vecshr          = >|(vecsize*4)-1

extstk          = $7F80                 ' locate external data stack at end (overflows but it's ROM)

' MULTI-DROP
_myadr          = $81                   ' default node address
_gbl            = $EF                   ' address all nodes - no response

_BUFFERS        = $7700                 ' reclaimed 2k area used for SD, ROM, and general buffers
registers       = $0030


CON { *** PORT ASSIGNMENTS *** }
' Standard Port assignments
scl             = 28
sda             = 29
txd             = 30
rxd             = 31

' Stack sizes
datsz           = 4                     ' expands into hub RAM
retsz           = 28
loopsz          = 8
branchsz        = loopsz/2              ' fast FOR/DO branch address

numpadsz        = 26                    ' We really only need a large buffer for when long binary numbers with separators are used – 26 digits for double number 18,446,744,073,709,551,615
wordsz          = 39                    ' any word up to 37 characters (1 count, 1 terminator)
tasksz          = 8                     ' 8 bytes/task RUN[2] FLAG[1]

' flags
echo            = 1
linenums        = 2                     ' prepend line number to each new line
ipmode          = 4                     ' interpret this number in IP format where a "." separates bytes
leadspaces      = 4
prset           = 8                     ' private headers set as default
striplf         = $10                   ' strip linefeeds from output if set ( not used - LEMIT replaces this !!!)
sign            = $20
comp            = $40                   ' force compilation of the current word - resets each time
defining        = $80



DAT { *** TASK REGISTERS *** }

' Allocate storage memory for buffers and other variables


               long 0[64]              'Variables used by kernel + general-purpose

' Task registers can be switched easily by setting "regptr" ( 7 COGREG! )
' New tasks may only need room for the first 32 or 72 bytes



                org  0
' register offsets within "registers". Access as    REG,delim   ...  REG,base ... etc
'
' Minimum registers required for a new task - other registers after the ' ---- are not needed other than by the console
temp            res 12          ' general purpose
cntr            res 4           ' hold CNT or temp
' @16
uemit           res 2           ' emit vector – 0 = default
ukey            res 2           ' key vector
keypoll         res 2           ' poll user routines - low priority background task
base            res 2           ' current number base + backup location during overrides
baudcnt         res 4           ' SERIN SEROUT baud cnt value where baud = clkfreq/baudcnt – each cog can have it's own
uswitch         res 4           ' target parameter used in CASE structures
flags           res 2           ' echo,linenums,ipmode,leadspaces,prset,striplf,sign,comp,defining
keycol          res 1           ' maintains column position of key input

wordcnt         res 1           ' length of current word (which is still null terminated)
wordbuf         res wordsz              ' words from the input stream are assembled here
' numpad may continue to build backwards into wordbuf for special cases such as long binary numnbers
numpad          res numpadsz    ' Number print format routines assemble digit characters here – builds from end - 18,446,744,073,709,551,615
padwr           res 1           ' write index (builds characters down from lsb to msb in MODULO style)

'
' ------ console only registers – not required for other tasks
'



unum            res 2           ' User number processing routine - executed if number failed and UNUM <> 0
anumber         res 4           ' Assembled number from input
bnumber         res 4
digits          res 1           ' number of digits in current number that has just been processed
dpl             res 1           ' Position of the decimal point if encountered (else zero)

' WORD aligned registers

ufind           res 2           ' runs extended dictionary search if set after failing precompiled dictionary search
createvec       res 2           ' If set will execute user create routines rather than the kernel's

rxptr           res 2           ' Pointer to the terminal receive buffer - read & write index precedes
rxsz            res 2           ' normally set to 256 bytes but increased during block load
corenames       res 2           ' points to core kernel names for optimizing search sequence
oldnames        res 2           ' backup of names used at start of TACHYON load
names           res 2           ' start of dictionary (builds down)
prevname        res 2           ' temp location used by CREATE
fromhere        res 2           ' Used by TACHYON word to backup current “here” to determine code size at end of load
here            res 2           ' pointer to compilation area (overwrites VM image)
codes           res 2           ' current code compilation pointer (updates "here" or is reset by it)
cold            res 2           ' pattern to detect if this is a cold or warm start ($A55A )
autovec         res 2           ' user autostart address if non-zero - called from within terminal
errors          res 2
linenum         res 2

' Unaligned registers

delim           res 2           ' the delimiter used in text input and a save location

prompt          res 2           ' pointer to code to execute when Forth prompts for a new line
accept          res 2           ' pointer to code to execute when Forth accepts a line to interpret (0=ok)


prevch          res 2           ' used to detect LF only sequences vs CRLF to perform auto CR
emitreg         res 4           ' 160514 addition for virtual console - 160705 using txon flg in emitreg+3

'lastkey         res 1           ' written to directly from serialrx
writekey        res 1
keychar         res 1           ' override for next key character to insert a characer into the stream

spincnt         res 1           ' Used by spinner to rotate busy symbol

prefix          res 1           ' NUMBER input prefix
suffix          res 1           ' NUMBER input suffix
                res 3
tasks           res tasksz*8    ' (must be long aligned)

endreg          res 0




DAT { *** VECTOR TABLE *** }
{ *** BYTECODE DEFINITIONS VECTOR TABLE *** }
{
Kernel bytecode definitions need to be called and this table makes it easy to do so
with just a 2 byte call. Extra memory may be allocated for user definitions as well
The Spin compiler requires longs whereas we only need 16-bit words but this will work anyway.
The runtime compiler can reuse the high-word of all these longs and compile a YCALL rather than
an XCALL so that the high-word is used instead.
Also another table has been added to expand the call vectors up to 1024 entries.

So there are 256 16-bits vectors x 4 pages using
XCALL   low word of first 1K page
YCALL   high word of first 1K page
ZCALL   low word of second 1K page
VCALL   High word of second 1K page

Use of a vector table is almost necessary for the Spin compiler just so we can reference bytecode by name without having to align on word boundaries and
add offsets etc. So a call to the an interpreted word such as GETWORD made up of bytecodes is simply
        byte  XCALL,xGETWORD

without having to worry about alignment or offsets rather than a 16-bit absolute call which would awkwardly look like this:
        byte  CALL16,(GETWORD+s)>>8,GETWORD+s
}

                org 0           ' ensure references can be reduced to a single byte index to be called by XCALL xx
'
XCALLS
' NOTE: this table is limited to 1024 word entries but leave room for extensions and user application to use the rest of these
xXCALLS         long @_XCALLS+s
xLSTACK         long @LSTACK+s
xSETQ           long @SETQ+s
xLT             long @LT+s
xZLT            long @ZLT+s
xULT            long @ULT+s
' xSAR            long @_SAR+s
xUDIVIDE        long @UDIVIDE+s
xUDIVMOD        long @UDIVMOD+s
xMULDIV         long @MULDIV+s
xWITHIN         long @WITHIN+s
xFILL           long @FILL+s
xERASE          long @ERASE+s
xms             long @ms+s
xCOMMENT        long @COMMENT+s
xBRACE          long @BRACE+s
xCURLY          long @CURLY+s
xIFNDEF         long @IFNDEF+s
xIFDEF          long @IFDEF+s
xPRTHEX         long @PRTHEX+s
xPRTBYTE        long @PRTBYTE+s
xPRTWORD        long @PRTWORD+s
xPRTLONG        long @PRTLONG+s
xPRTSTK         long @PRTSTK+s
xPRTSTKS        long @PRTSTKS+s
xDEBUG          long @DEBUG+s
xDUMP           long @DUMP+s
xCOGDUMP        long @COGDUMP+s
xREBOOT         long @_REBOOT+s
xSTOP           long @STOP+s
xLOADMOD        long @aLOADMOD+s
xTX485          long @lTX485+s
xSERIN          long @lSERIN+s
xSSD            long @SSD+s
xESPIO          long @ESPIO+s
xBSPIWR         long @BSPIWR+s
xSPIO           long @SPIO+s
xMCP32          long @MCP32+s
xSDRD           long @SDRD+s
xSDWR           long @SDWR+s
xPWM32          long @PWM32+s
xPWMST32        long @PWMST32+s
xPLOT           long @PLOT+s
xPLAYER         long @PLAYER+s
'xONEWAVE       long @ONEWAVE+s
xBCA            long @_BCA+s
xWS2812         long @_WS2812+s
'xWS2812CL      long @_WS2812CL+s
xSQRT           long @_SQRT+s
xCAP            long @_CAP+s
xRCMOVE         long @RCMOVE+s
xCLS            long @CLS+s
xEMIT           long @EMIT+s
xSPACE          long @SPACE+s
xBELL           long @BELL+s
xCR             long @CR+s
xOK             long @OK+s
xSPINNER        long @SPINNER+s
xBIN            long @BIN+s
xDECIMAL        long @DECIMAL+s
xHEX            long @HEX+s
xREADBUF        long @READBUF+s
xCONKEY         long @CONKEY+s
xKEY            long @KEY+s
xWKEY           long @WKEY+s
xSEQKEY         long @SEQKEY+s
xECHOKEY        long @ECHOKEY+s
xLASTKEY        long @_LASTKEY+s
xQEMIT          long @QEMIT+s
xTOUPPER        long @TOUPPER+s
xPUTCHAR        long @PUTCHAR+s
xPUTCHARPL      long @PUTCHARPL+s
xSCRUB          long @SCRUB+s
xdoCHAR         long @doCHAR+s
xGETWORD        long @GETWORD+s
xTICK           long @TICK+s
xATICK          long @ATICK+s
xNFATICK        long @NFATICK+s
x_NFATICK       long @_NFATICK+s
xTOVEC          long @TOVEC+s
xBFACFA         long @BFACFA+s
xIFEXIT         long @IFEXIT+s
xSEARCH         long @SEARCH+s
xFINDSTR        long @FINDSTR+s
xEXECUTE        long @EXECUTE+s
xGETVER         long @GETVER+s
xPRTVER         long @PRTVER+s
xTODIGIT        long @TODIGIT+s
xNUMBER         long @NUMBER+s
xTERMINAL       long @TERMINAL+s
xCONSOLE        long @CONSOLE+s
xRXPARS         long @RXPARS+s
'xVGA            long @VGA+s
x_NUMBER        long @_NUMBER+s
xGRAB           long @GRAB+s
xRESFWD         long @RESFWD+s
xATPAD          long @ATPAD+s
xHOLD           long @HOLD+s
xTOCHAR         long @TOCHAR+s
xRHASH          long @RHASH+s
xLHASH          long @LHASH+s
xHASH           long @HASH+s
xHASHS          long @HASHS+s
xDNUM           long @DNUM+s
x_STR           long @_STR+s
xPSTR           long @PSTR+s
xPRTSTR         long @PRTSTR+s
xSTRLEN         long @STRLEN+s
xUPRT           long @UPRT+s
xPRT            long @PRT+s
xPRTDEC         long @PRTDEC+s
xLITCOMP        long @LITCOMP+s
xBCOMP          long @BCOMP+s
xBCOMPILE       long @BCOMPILE+s
xCCOMP          long @CCOMP+s
xWCOMP          long @WCOMP+s
xLCOMP          long @LCOMP+s
xSTACKS         long @STACKS+s
x_STR_          long @_STR_+s
x_PSTR_         long @_PSTR_+s
x_IF_           long @_IF_+s
x_ELSE_         long @_ELSE_+s
x_THEN_         long @_THEN_+s
x_BEGIN_        long @_BEGIN_+s
x_UNTIL_        long @_UNTIL_+s
x_AGAIN_        long @_AGAIN_+s
x_REPEAT_       long @_REPEAT_+s
xMARK           long @MARK+s
xUNMARK         long @UNMARK+s
xVECTORS        long @VECTORS+s
xTASK           long @TASK+s
xIDLE           long @IDLE+s
xALLOT          long @ALLOT+s
xALLOCATED      long @ALLOCATED+s
xATO            long @Ato+s
xATATR          long @ATATR+s
xCOLON          long @COLON+s
x_COLON         long @_COLON+s
xPUBCOLON       long @PUBCOLON+s
xPRIVATE        long @PRIVATE+s
xUNSMUDGE       long @UNSMUDGE+s
xENDCOLON       long @ENDCOLON+s
xCOMPILES       long @COMPILES+s
xCREATE         long @CREATE+s
xCREATEWORD     long @CREATEWORD+s
xCREATESTR      long @CREATESTR+s
xAddACALL       long @AddACALL+s
xHERE           long @_HERE+s
xNFABFA         long @NFABFA+s
x_TACHYON       long @_TACHYON+s
xERROR          long @ERROR+s
xNOTFOUND       long @NOTFOUND+s
xDISCARD        long @DISCARD+s
'xAUTORUN       long @AUTORUN+s
xFREE           long @FREE+s
'xAUTOST        long @AUTOST+s
xFIXDICT        long @FIXDICT+s
xBUFFERS        long @BUFFERS+s
xCOLDST         long @COLDST+s
xSWITCH         long @_SWITCH+s
xSWITCHFETCH    long @SWITCHFETCH+s
xISEQ           long @ISEQ+s
xIS             long @IS+s
xISEND          long @ISEND+s
xISWITHIN       long @ISWITHIN+s
xInitStack      long @InitStack+s
xSPSTORE        long @SPSTORE+s
xDEPTH          long @_DEPTH+s
xCOGINIT        long @aCOGINIT+s
xSET            long @SET+s
xCLR            long @CLR+s
xWORDS          long @WORDS+s

' Reserve the rest of the area possible
xLAST           long 0[vecsize-xLAST]
' plus one extra for termination
xEND            long -1



CON
loadsz  = 21                    ' Specifies the number of longs to load with LOADMOD for a RUNMOD module

DAT { *** RUNMODs *** }
{ TACHYON VM CODE MODULES }
' There are a number of longs reserved in the cog for a code module which can be loaded with LOADMOD and executed with RUNMOD

                org $01F0-loadsz        ' fixed address - high-level code can always assume RUNMOD' cog origin is here
pRUNMOD
_RUNMOD         res loadsz



                        org     _RUNMOD

rTX485
                        or      outa,rtepin             ' enable transmitter
                        or      dira,rtepin
                        or      dira,rtrpin             ' make tr a transmit outout (along with te)
                        add     tos,#$100 wc              ' add a stop bit (carry = start bit)
                        mov     R0,cnt
                        add     R0,tick485
:txl                    muxc    outa,rtrpin             ' output bit
                        shr     tos,#1 wz,wc              ' lsb first
                        waitcnt R0,tick485             ' bit timing
        if_nz_or_c      jmp     #:txl                   ' next bit (stop bit: z & c)
                        andn    dira,rtrpin             ' Turn data line back to receive
'                        waitcnt R0,tick485
                        andn    outa,rtepin             ' Turn chip back to receive (force high for deglitch)
                        jmp     #DROP
rtrpin                  long 0
rtepin                  long 0
tick485                 long 0


lTX485 '( trmask temask ticks -- )
        byte    _WORD,(@rTX485+s)>>8,@rTX485+s
        byte    XCALL,xLOADMOD
        byte    _WORD,tick485>>8,tick485,XOP,pCOGSTORE
        byte    _WORD,rtepin>>8,rtepin,XOP,pCOGSTORE
        byte    _WORD,rtrpin>>8,rtrpin,XOP,pCOGSTORE
        byte    EXIT




                        org     _RUNMOD

rSERIN ' (  -- dat )
                        mov     R2,#9
serlp 			mov	X,rticks
                        shr     X,#1                    ' half bit time
 			waitpne	rmask,rmask	                ' wait for a low = start bit
 			add	X,cnt           	' uses special start bit timing
 			waitcnt	X,rticks
 			test	rmask,ina       wz        ' sample middle of start bit
		if_nz	jmp	#serlp                   ' restart if false start otherwise bit time from center
serdat 			waitcnt	X,rticks                ' wait until middle of first data bit
 			test	rmask,ina wc	        ' sample bit 0
                        rcl     ACC,#1
                        djnz    R2,#serdat
               if_nc    jmp     #rSERIN                 ' framing error
                        rev     ACC,#23
                        and     ACC,#$FF
                        jmp     #PUSHACC
rmask         long 0
rticks        long 0


lSERIN '( ticks mask -- )
        byte    _WORD,(@rSERIN+s)>>8,@rSERIN+s
        byte    XCALL,xLOADMOD
        byte    _WORD,rmask>>8,rmask,XOP,pCOGSTORE
        byte    _WORD,rticks>>8,rticks,XOP,pCOGSTORE
        byte    EXIT


{
                        org     _RUNMOD
' Write byte to I2C bus
' COGREGS: 0=scl 1=sda
' I2CWR ( send -- ack )  ( A: miso mosi sck )
_I2CWR                  mov     R1,#8
i2cwrlp                 andn    OUTA,sck        ' clock low
                        or      DIRA,mosi       ' make sure data is an output
                        shl     sdat,#1 wc      ' msb first
                        muxc    OUTA,mosi       ' send next bit of data out
                        call    #i2cdly
                        or      OUTA,sck        ' clock high
                        djnz    R1,#i2cwrlp
                        andn    OUTA,sck        ' get ready to read ack
                        andn    DIRA,mosi       ' float SDA
                        or      OUT,sck

                        jmp     unext
ic2dly                  nop
i2cdly_ret                      ret

I2CWR   byte    _WORD,(@_I2CWR+s)>>8,@_I2CWR+s
        byte    XCALL,xLOADMOD,EXIT


}

                        org     _RUNMOD
' BLOCK WRITE SPI
' BSPIWR ( src cnt --  )
_BSPIWR
                        andn    OUTA,spice              ' chip select low
BBlp                    rdbyte  X,tos+1
                        add     tos+1,#1                ' inc addr
                        mov     R1,#8
                        shl     X,#24                   ' left justify transmit data
                        shl     X,#1 wc                 ' balance clock pulse width adjustment
BSPIOlp                 muxc    OUTA,spiout             ' send next bit of data out
                        xor     OUTA,spisck             ' clock low
                        shl     X,#1 wc                 ' assume msb first
                        xor     OUTA,spisck             ' clock high
                        djnz    R1,#BSPIOlp
                        djnz    tos,#BBlp
                        jmp     #DROP2

BSPIWR  byte  _WORD,(@_BSPIWR+s)>>8,@_BSPIWR+s
        byte  XCALL,xLOADMOD,EXIT

{HELP ESPIO ( send -- receive )  ( A: miso mosi sck )
COGREGS: 0=sck 1=mosi 2=miso 3=cnt 4=cs
  *** ENHANCED SERIAL PERIPHERAL INPUT OUTPUT MODULE ***
Transfers 1 to 32 bits msb first
Transmit data does not need to be left justified to be ready for transmission
Receive data is in correct format
Data is shifted in and out while the clock is low
The clock is left low between transfers  unless a chip select mask is specified
}

                        org     _RUNMOD
'
' ESPIO ( send -- receive )  ( A: miso mosi sck )
_ESPIO
                        andn    OUTA,scs        ' chip select low
                        mov     R1,#32
                        sub     R1,scnt
                        shl     tos,R1          ' left justify transmit data
                        mov     R1,scnt
ESPIOlp                 andn    OUTA,sck        ' clock low
                        shl     sdat,#1 wc      ' assume msb first
                        test    miso,INA wz     ' test data from device while clock is low
                        muxc    OUTA,mosi       ' send next bit of data out
                if_nz   or      sdat,#1         ' now assemble data (also setup time for mosi)
                        or      OUTA,sck        ' clock high
                        djnz    R1,#ESPIOlp
                        tjnz    scs,#ESxt       ' leave with clock high if CS mask specified
                        andn    OUTA,sck        ' leave with clock low
ESxt                    or      OUTA,scs        ' chip select high
                        jmp     unext

ESPIO   byte    _WORD,(@_ESPIO+s)>>8,@_ESPIO+s
' this next line  is common to other modules XCALL,xLOADMOD
aLOADMOD        byte    _WORD,_RUNMOD>>8,_RUNMOD,_BYTE,loadsz,XOP,pLOADMOD,EXIT


                        org     _RUNMOD
{HELP SSD ( send cnt --  )  ( A: miso mosi sck )
  SSD module added for fast SSD2119 SPI operations
  COGREGS: 0=sck 1=mosi 2=miso 3=cnt 4=mode }
_SSD
SSDREP                  mov     X,tos+1
                        shl     X,#7            ' left justify but leave msb zero (control byte)
                        call    #SSD8
                        call    #SSD8D
                        call    #SSD8D
                        djnz    tos,#SSDREP
                        jmp     #DROP2

SSD8D                   or      X,#1            ' move 1 into msb = data
                        ror     X,#1
SSD8                    andn    OUTA,scs        ' chip select low
                        mov     R1,scnt
SSDlp                   andn    OUTA,sck        ' clock low
                        shl     X,#1 wc         ' assume msb first
                        muxc    OUTA,mosi       ' send next bit of data out
                        or      OUTA,sck        ' clock high
                        djnz    R1,#SSDlp
                        or      OUTA,scs        ' chip select high
SSD8D_ret
SSD8_ret                ret

SSD     byte    _WORD,(@_SSD+s)>>8,@_SSD+s
        byte    XCALL,xLOADMOD,EXIT




{HELP SPIO ( send -- receive )  ( A: miso mosi sck )
COGREGS: 0=sck 1=mosi 2=miso 3=cnt
 *** SERIAL PERIPHERAL INPUT OUTPUT MODULE ***
Transfers 1 to 32 bits msb first
Transmit data must be left justified ready for transmission
Receive data is in correct format
Data is shifted in and out while the clock is low
The clock is left low between transfers
}
                        org     _RUNMOD
' COGREGS: 0=sck 1=mosi 2=miso 3=cnt
' SPIO ( send -- receive )  ( A: miso mosi sck )
_SPIO                   mov     R1,scnt
                        or      DIRA,mosi       ' MOSI must be an output
SPIOlp                  andn    OUTA,sck        ' clock low
                        shl     sdat,#1 wc      ' assume msb first
                        test    miso,INA wz     ' test data from device while clock is low
                        muxc    OUTA,mosi       ' send next bit of data out
                if_nz   or      sdat,#1 ' now assemble data (also setup time for mosi)
                        or      OUTA,sck        ' clock high
                        djnz    R1,#SPIOlp
                        andn    OUTA,sck        ' leave with clock low
                        jmp     unext

SPIO    byte    _WORD,(@_SPIO+s)>>8,@_SPIO+s
        byte    XCALL,xLOADMOD,EXIT

{               org REG0
sck             res 1
mosi            res 1
miso            res 1
scs             res 1
scnt            res 1
}

{                       org     _RUNMOD
' COGREGS: 0=sck 1=mosi 2=miso 3=delay 4=scnt
' SPIOD ( send -- receive )  ( A: miso mosi sck )
_SPIOD                  mov     R1,scnt
                        or      DIRA,mosi
SPIODlp                 andn    OUTA,sck        ' clock low
                        shl     sdat,#1 wc      ' assume msb first
                        test    miso,INA wz     ' test data from device while clock is low
                        muxc    OUTA,mosi       ' send next bit of data out
                if_nz   or      sdat,#1 ' now assemble data (also setup time for mosi)
                        or      OUTA,sck        ' clock high
                        mov     X,scs   ' use reg3 for delay value
spiodly                 djnz    X,#spiodly
                        djnz    R1,#SPIODlp
                        andn    OUTA,sck        ' leave with clock low
                        jmp     unext

SPIOD   byte    _WORD,(@_SPIOD+s)>>8,@_SPIOD+s
        byte    XCALL,xLOADMOD,EXIT
}

' start,sing/diff,d2,d1,d0,x,x -- 11..0

                        org     _RUNMOD
' COGREGS: 0=sck 1=mosi 2=miso 3=cs
' MCP32 ( send -- receive )  ( A: miso mosi sck )
' send = s/d+ch
_MCP32                  or      sdat,#$18       ' add start bit + single mode
                        shl     sdat,#27        ' left justify
                        or      DIRA,mosi       ' make sure mosi is an output
                        andn    OUTA,scs        ' assert ce
                        mov     R1,#19          ' clock out 7 bits then read 12
mcplp                   andn    OUTA,sck        ' clock low
                        cmp     R1,#14 wc       ' if mosi = miso then switch to input after 5 clocks
                if_c    andn    DIRA,miso
                        shl     sdat,#1 wc      ' assume msb first
                        test    miso,INA wz     ' test data from device while clock is low
                        muxc    OUTA,mosi       ' send next bit of data out
                if_nz   or      sdat,#1         ' now assemble data (also setup time for mosi)
                        or      OUTA,sck        ' clock high
                        mov     X,#1
:dly                    djnz    X,#:dly
                        djnz    R1,#mcplp
                        andn    OUTA,sck        ' leave with clock low
                        or      OUTA,scs        ' ce high
                        and     sdat,mmask
                        jmp     unext
mmask                   long    $0FFF

MCP32   byte    _WORD,(@_MCP32+s)>>8,@_MCP32+s
        byte    XCALL,xLOADMOD,EXIT


{HELP SDRD ( dst char  --  firstPos charcnt   \ read block from SD into memory while scanning for special char )
    dst is a 32 bit SD-card address 0..4GB, char is the character to scan for while, reading in the block.
 NOTE: ensure MOSI is set as an output high from caller by  1 COGREG@ OUTSET
 This is just the low-level block read once the SD card has been setup, so it just reads a sector into the dst
 There is also a scan character that it will look for and return it's first position and how many were found
}

                        org     _RUNMOD
_SDRD
                mov     X,tos+1                 ' dst --> X
                mov     R2,dst1                 '$200   ' R2 = 512 bytes
SDRDSClp        mov     R1,#8                   ' 8-bits
SDRDSCbits      andn    OUTA,sck                ' clock low
                test    miso,INA wc             ' test data from device while clock is low
                rcl     R0,#1                   ' now assemble data (also setup time for mosi)
                or      OUTA,sck                ' clock high
                djnz    R1,#SDRDSCbits
                andn    OUTA,sck                ' leave with clock low
                wrbyte  R0,X                    ' write byte to destination
                and     R0,#$FF                 ' only want to compare a byte value
                cmp     R0,tos wz               ' compare byte with char unsigned for equality
        if_z    add     ACC,#1                  ' found one and increment count
        if_z    cmp     ACC,#1 wz               ' if match and count = 1 (first occurrence)
    if_z        mov     tos+1,X                 ' then save dst (tos+2) to firstpos (tos)
                add     X,#1                    ' dst = dst+1
                djnz    R2,#SDRDSClp            ' next
                call    #POPX                   ' discard "char"
                 jmp     #PUSHACC               ' push char count and clear ACC

' Load the SDSCAN read module (13us)
SDRD    byte    _WORD,(@_SDRD+s)>>8,@_SDRD+s
        byte    XCALL,xLOADMOD,EXIT

{
' moved to SDCARD.fth MJB
WORD scancnt,scanpos
BYTE scanch
--- Read in one block of 512 bytes from SD to dst
pri (SDRD) ( dst -- )
\ BYTE scanch holds the char to scan for
\ gives number of character matches found in WORD scancnt
\ autoincrements on each call, use scancnt W~ to init to 0 if needed
\ position of first match in WORD scanpos
        [SDRD] 1 COGREG@ OUTSET scanch C@ RUNMOD
        scancnt W+! scanpos W@ 0= IF scanpos W! ELSE DROP THEN   ' to catch the earliest over many block reads - use scanpos W~ to init
 ;
}

' SD MODULE
                        org     _RUNMOD
' Write a block to the SD card - 512 bytes
' SDWR ( src cnt --  ;write block from memory to SD )
_SDWR
                        or      DIRA,mosi
SDWRlp                  rdbyte  R0,tos+1        ' read next byte from source
                        add     tos+1,#1        ' increment source address
                        shl     R0,#24          ' left justify
                        mov     R1,#8           ' send 8 bits
SDWRbits                andn    OUTA,sck        ' clock low
                        shl     R0,#1 wc        ' assume msb first
                        muxc    OUTA,mosi       ' send next bit of data out
                        or      OUTA,sck        ' clock high
                        djnz    R1,#SDWRbits
                        andn    OUTA,sck        ' leave with clock low
                        djnz    tos,#SDWRlp     ' next byte
                        jmp     #DROP2

' Load the SD write module
SDWR    byte    _WORD,(@_SDWR+s)>>8,@_SDWR+s
        byte    XCALL,xLOADMOD,EXIT



{ *** 32 channel 8-bit PWM *** }


' [PWM32] loads the PWM32 module into the cog ready for a RUNMOD

PWM32     byte  _WORD,(@_PWM32+s)>>8,@_PWM32+s
          byte  XCALL,xLOADMOD,EXIT


' kuroneko's 7.6kHz version of the 32 channel PWM module
' ( table waitcnt -- )
                         org       _RUNMOD                   ' Compile for RUNMOD area in cog
_PWM32                   movi      ctrb, #%0_11111_000       ' LOGIC.always
                         mov       frqb, tos+1               ' table base address
                         shr       frqb, #1{/2}              ' divided by 2 (expected to be 4n)
                         mov       cnt,#5{14}+2*4+23         ' minimal entry delay
                         add       cnt,cnt
                         mov       phsb,#0                   ' preset (not optional, 8n)

pwmlp32                  and       phsb,wrap32               ' $0400 to $0000 transition        |
                         rdlong    X,phsb                    ' read from index + 2*table/2      | need to be back-to-back

                         waitcnt   cnt,tos                   ' |
                         mov       outa,X                    ' update outputs

                         add       phsb,#4                   ' update read ptr                  |
                         rdlong    X,phsb                    ' read from index + 2*table/2      | need to be back-to-back

                         add       phsb,#4                   ' update read ptr
                         waitcnt   cnt,tos                   ' |
                         mov       outa,X                    ' update outputs

                         jmp       #pwmlp32

wrap32                   long      256 * 4 -1

{ PWM32 TIMING SAMPLE

}
' PWM32! SETUP TABLE MODULE
' this module is run from the controlling cog whereas the PWM32 runtime is in a dedicated cog
                        org     _RUNMOD
' _PWM32! ( duty8 mask table -- )                         ' 104us (LOADMOD takes 18.8us)
_PWMST32                 mov       R2,#256                ' scan through all 256 slices
                         add       tos,endtbl             ' start from end (optimize hub access)
                         add       tos+2,#1               ' compensate for cmp op so that $80 = 50 %, $100 = 100 %
pwmstlp32                rdlong    X,tos                  ' read one 1/256 slice of 32 channels
                         cmp       R2,tos+2 wc            ' is duty8 > R2
                         muxc      X,tos+1                ' set or clear the bit(s)
                         wrlong    X,tos                  ' update slice
                         sub       tos,#4                 ' next long
                         djnz      R2,#pwmstlp32          ' terminate on wrap
                         jmp       #DROP3
endtbl                   long      256 * 4 -4             ' offset to last long of table

' [PWM32!]  Load the PWM32! module which is used to setup the PWM table
PWMST32   byte  _WORD,(@_PWMST32+s)>>8,@_PWMST32+s
          byte  XCALL,xLOADMOD,EXIT



' PLOT MODULE
' Used for VGA/TV or LCD graphics
' pixshift is always a multiple of two, 512 pixels/line = 6 etc
'
                        org     _RUNMOD
' PLOT ( x y -- )
_PLOT                   shl     tos,pixshift    ' n^2 bytes/Y line
                        mov     X,tos+1
                        shr     tos+1,#3        ' byte offset in line
                        add     tos,tos+1       ' byte offset in frame
                        add     tos,pixeladr    ' byte address in memory
                        and     X,#7    ' get bit mask
                        mov     tos+1,#1
                        shl     tos+1,X
                        jmp     #SET

' [PLOT]
PLOT    byte    _WORD,(@_PLOT+s)>>8,@_PLOT+s
        byte    XCALL,xLOADMOD,EXIT


{ AUDIO - PLAY A SINGLE SAMPLE from within a loop
        0 bsyn C!
    BUF1 BLKSIZ ADO I W@ $8000 + SHL16 FRQA COG! WAITCNT 2 +LOOP

REG0 = fade control ptr
REG1 = speed ptr
REG2 = index hub variable ptr
}
{
                        org     _RUNMOD
_ONEWAVE
                        rdword  X,loopstk+1     ' I W@
                        shl     X,#16   ' SHL16
                        rdbyte  R0,REG0 ' REG0 has ptr to fade
                        sar     X,R0    ' volume adjust
                        add     X,wbias ' $8000 +
                        waitcnt cnt,deltaR      ' sync first in case of loop overheads
                        mov     FRQA,X
                        rdlong  deltaR,REG1
                        wrword  loopstk+1,REG2
                        jmp     unext

wbias           long    $8000_0000
ONEWAVE byte    _WORD,(@_ONEWAVE+s)>>8,@_ONEWAVE+s
        byte    XCALL,xLOADMOD,EXIT
}

{
PLAY 16-BIT WAV  22.675us/sample @44100 - plays through 1K buffer cont. (512x2)
updates it's read position so other half of buffer can be refilled.
Uses word at end of buffers for update
ctls point to control block:
0: index
2: vol
4: speed

}

                        org     _RUNMOD
' PLAYER ( ctls blk -- )
_PLAY                   mov     REG0,tos        ' point to readptr hub update location
                        mov     REG2,tos+1
                '       mov     REG0,tos+1
                        add     REG0,#2         ' REG0 points to volume word in hub
                        mov     REG1,tos+1
                        add     REG1,#4         ' REG1 points to speed word in hub
_PLREP                  mov     R1,pblksz       ' reload buffer cnt
                        mov     R2,tos          ' reload buffer ptr
                        rdbyte  tos+1,REG0      ' update volume scale
_PLLP                   rdword  X,R2            ' get next sample
                        add     X,bias          ' offset the sign to half voltage
                        shl     X,#16           ' scale to 32-bits
                        wrword  R1,REG2         ' update hub read cnt (ext. buf fill task)
                        sar     X,tos+1         ' adjust volume?
                        mov     FRQA,X          ' output sample
                        waitcnt cnt,deltaR      ' sample time
                        rdlong  deltaR,REG1
                        add     R2,#2           ' point to next word
                        djnz    R1,#_PLLP       ' 512 samples / 1K (512x2)
                        jmp     #_PLREP         ' repeat buffer

bias            long    $FFFF8000               ' biased sign
pblksz          long    512                     ' 512 samples 1K buffer


PLAYER  byte    _WORD,(@_PLAY+s)>>8,@_PLAY+s
        byte    XCALL,xLOADMOD,EXIT


{

CLKSET
(c) Copyright 2009 Philip C. Pilgrim (propeller@phipi.com)
see end of file for terms of use.

This object determines whether a 5MHz or 10MHz crystal is
being used and sets the PLL accordingly for 80MHz operation.
The main program should use the following settings:
  _clkmode      = xtal1 + pll8x
  _xinfreq      = 10_000_000
}
              org       _RUNMOD

_setpll       movi      ctra,#%0_00001_011      'Set ctra for pll on no pin at x1.
              movi      frqa,#%0100_0000_0      'Set frqa for clk / 4 (= 20MHz w/ 10MHz crystal, i.e. too high).
              add       pllx,cnt                   'Give PLL time to lock (if it can) and stabilize.
              waitcnt   pllx,#0
              movi      vcfg,#$40               'Configure video for discrete pins, but no pins enabled.
              mov       vscl,#$10               'Set for 16 clocks per frame.
              waitvid   0,0                     'Wait once to clear time.
              neg       pllx,cnt                   'Read -cnt.
              waitvid   0,0                     'Wait 16 pll clocks = 64 processor clks.
              add       pllx,cnt                   'Compute elapsed time.
              cmp       pllx,#$40 wz               'Is it really 64 clocks?
        if_z  mov       pllx,#$6f                  '  Yes: Crystal is 5MHz. Set clock mode to XTAL1 and PLL16X.
        if_z  clkset    pllx
        if_z  wrbyte    $-2, #4                 'update clkmode location
            jmp       unext

pllx          long      $1_0000                 '65536 clks for pll to stabilize.


'( BYTE CODE ANALYSER - 140606 - temporary, testing bytecode frequencies with MJB )

                        org     _RUNMOD
' bytecode analyser
BCARUN                  mov     unext,bcavec
bca
                rdbyte  instr,IP        ' read byte code instruction
                add     IP,#1 wc        ' advance IP to next byte token (clears the carry too!)
                mov     R0,instr        ' only process single byte opcodes
                shl     R0,#2   ' address longs
                add     R0,bcabuf       ' in bcabuf (1K at BUFFERS)
                rdlong  X,R0    ' increment the counter for this bytecode
                add     X,#1
                wrlong  X,R0
                jmp     instr   'execute the code by directly indexing the first 256 long in cog

bcavec          long bca
bcabuf          long @RESET+s           ' use BUFFERS (normally at $7500) buffers uses kernel image from RESET

' Load the bytecode analyser module
_BCA    byte    _WORD,(@bcarun+s)>>8,@bcarun+s ' fixed to point to bcarun not bca
        byte    XCALL,xLOADMOD,XOP,pRUNMOD,EXIT


                        org     _RUNMOD
' WS2812 ( array cnt -- ) pin mask is in COGREG4, line RET is done at HL, not here
' Will transmit a whole array of bytes each back to back in WS2812 timing format
' A zero is transmitted as 350ns high by 800ns low (+/-150ns)
' A one is transmitted as 700ns high by 600ns low
' LOADMOD has room for 19 longs which just fits!
WS2812
              rdbyte     X,tos+1        ' read next byte
              rev        X,#24          ' the msb must be transmitted first - get it into the lsb for shr ops
              mov        R1,#8          ' data bits
              jmp        #$+2           ' skip delay of last bit (in loop) as we had to read another byte from hub
TXRGBlp       call       #WSDLY         ' gets skipped if this is a new byte
              shr        X,#1 wc        ' get next bit
              or         OUTA,REG4      ' always clock tx pin high for at least 400ns
              call       #WSDLY         ' delay
        if_nc andn       OUTA,REG4      ' pull line down now if it's a 0 we are transmitting
              call       #WSDLY         ' delay again, either high or low
              andn       OUTA,REG4      ' always needs to go low in the last third of the cycle
              djnz       R1,#TXRGBlp    ' so go back and get the next bit ready
RGBNEXT       add        tos+1,#1       ' next byte in array (and delay)
              djnz       tos,#WS2812    ' read the next long as long as we can (tos = count)
              jmp        #DROP2         ' tx line left low - discard stack parameters, all done.

WSDLY         mov        R2,CNT
              add        R2,#13
              waitcnt    R2,#0          ' just a delay, no need to synch
WSDLY_ret     ret

_WS2812         byte    _WORD,(@WS2812+s)>>8,@WS2812+s
                byte    XCALL,xLOADMOD,EXIT

{
                        org     _RUNMOD
' WS2812CL ( clut array cnt -- ) pin mask is in COGREG4, line RET is done at HL, not here
' Will transmit a whole array of 8-bit color bytes each back to back in WS2812 timing format using
' a color look-up table to translate each 8-bits into 24-bit color for each LED
' So each byte in the array handles 256 colors for each pixel
' A zero is transmitted as 350ns high by 800ns low (+/-150ns)
' A one is transmitted as 700ns high by 600ns low

WS2812CL                rdbyte  X,tos+1         ' read next byte
               shl      X,#2            ' address longs from byte
                add     X,tos+3         ' index into CLUT
                rdlong  X,X             ' lookup 24-bit color in CLUT (left justified) no wait
                mov     R1,#24          ' data bits
                jmp     #$+2            ' skip delay of last bit (in loop) as we had to read another byte from hub
TXCLlp          call    #WSDLY2         ' gets skipped if this is a new byte
                shl     X,#1 wc         ' get next bit
                or      OUTA,REG4               ' always clock tx pin high for at least 400ns
                call    #WSDLY2         ' delay
        if_nc   andn    OUTA,REG4               ' pull line down now if it's a 0 we are transmitting
                call    #WSDLY2         ' delay again, either high or low
                andn    OUTA,REG4               ' always needs to go low in the last third of the cycle
                djnz    R1,#TXCLlp      ' so go back and get the next bit ready
                add     tos+1,#1                ' next byte in array (and delay)
                djnz    tos,#WS2812CL   ' read the next byte as long as we can (tos = count)
                jmp     #DROP3          ' tx line left low - discard stack parameters, all done.

WSDLY2          mov     R2,CNT
                add     R2,#13
                waitcnt         R2,#0           ' just a delay, no need to synch
WSDLY2_ret              ret

_WS2812CL               byte    _WORD,(@WS2812CL+s)>>8,@WS2812CL+s
                byte    XCALL,xLOADMOD,EXIT

}


        org             _RUNMOD

SQRT                    mov     X,#0
:loop                   or      X,smask
                        cmpsub  tos,X wc
                        sumnc   X,smask
                        shr     X,#1
                        ror     smask,#2 wc
        if_nc   jmp     #:loop
                        mov     tos,X
                        jmp     unext
smask                   long    $4000_0000

_SQRT                   byte    _WORD,(@SQRT+s)>>8,@SQRT+s
                byte    _WORD,_RUNMOD>>8,_RUNMOD,_BYTE,10,XOP,pLOADMOD,EXIT
'               byte    XCALL,xLOADMOD,EXIT


        org    _RUNMOD

' CAPTURE ( buf lcnt dly -- )
' the trigger mask is directly loaded into COGREG0
CAPTURE
                    mov         X,ina                   ' look for change of state by reading INA first
                    waitpne     X,REG0                  ' wait for change on those masked bits
                    mov         R1,tos wz               ' read delay
        if_z       movs CAPINS,#CAPLP1          ' if zero then adjust loop to run without delay
        if_nz       add         R1,cnt
CAPLP
        if_nz       waitcnt     R1,tos                  ' (6+) if dly is set correctly then waitcnt can be considered a 6+ cycle NOP
CAPLP1              mov         ina,ina                 ' (4) read INA into its shadow (for dest field)
                    wrlong      ina,tos+2               ' (8..23) save it
                    add         tos+2,#4                ' (4) next long in memory
CAPINS              djnz        tos+1,#CAPLP wz         ' (4)
                    jmp         #DROP3

_CAP                byte        _WORD,(@CAPTURE+s)>>8,@CAPTURE+s
                    byte        XCALL,xLOADMOD,EXIT


{
Capture into COG at mamimum rate
FCAP

                mov             $,ina
                mov             $,ina

                mov             ina,ina
                wrlong          ina,$-1
                mov             ina,ina
                wrlong          ina,$-2



FCAPLP          mov     ina,ina
                add     fcapins,#1
fcapins         wrlong  ina,capbuf
                djnz    capcnt,#FCAPLP
capbuf          res     1


                mov     R1,ina
CAPLP           wrlong  R1,tos+2
                add     tos+2,#4
                mov     R2,ina
                wrlong  R2,tos+2




}

DAT { *** HIGH LEVEL FORTH BYTECODE DEFINITIONS *** }

{              org

' SAR ( n1 cnt -- n2 )
        byte  0,0,0
_SAR    byte  LMM
              sar       tos+1,tos
              jmp       #DROP
}
etbl    byte  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
'
{HELP EMIT ( char -- )  Emit a character to the terminal or to an other output device defined by setting an alternative output routine to the uemit vector. }
EMIT
        byte    DUP,_16,XCALL,xLT,_IF,05,_WORD,(@etbl+s)>>8,@etbl+s,PLUS,CFETCH
emw1    byte    REG,emitreg+3,CFETCH,_IF,10,REG,emitreg,CFETCH,ZEQ,_UNTIL,@emw2-@emw1
emw2    byte    DUP,REG,emitreg,CSTORE                  ' 160514 addition for virtual console
        byte    REG,uemit,WFETCH,QDUP,_IF,01,AJMP       ' execute user EMIT if vector is non-zero
        byte    XOP,pEMIT,EXIT


' Print inline string
PRTSTR  byte    RPOP
pstlp   byte    CFETCHINC,QDUP,_IF,04,XCALL,xEMIT,_AGAIN,@pstret-@pstlp
pstret  byte    PUSHR,EXIT

{ debug print routines - also used by DUMP etc }

{HELP  .HEX ( n -- ) print nibble n as a hex character }
PRTHEX  ' ( n -- ) print n (0..$0F) as a hex character
        byte    toNIB
        byte    _BYTE,$30,PLUS
        byte    DUP,_BYTE,$39,GT,_IF,03,_BYTE,7,PLUS                      'Adjust for A..F
PRTCH   byte    XCALL,xEMIT,EXIT

{HELP  .BYTE ( n -- ) print n as 2 hex characters }
PRTBYTE byte    DUP,_4,_SHR
        byte    XCALL,xPRTHEX,XCALL,xPRTHEX,EXIT

{HELP  .WORD ( n -- ) print n as 4 hex characters }
PRTWORD byte  DUP,_SHR8
        byte  XCALL,xPRTBYTE
PW1     byte  XCALL,xPRTBYTE
PW2     byte  EXIT

{HELP .LONG ( n -- ) print n as 8 hex characters }
PRTLONG byte  DUP,_BYTE,16,_SHR
        byte  XCALL,xPRTWORD
        byte  _BYTE,".",XCALL,xEMIT
PRL1    byte  XCALL,xPRTWORD
PRL2    byte  EXIT

{HELP HDUMP ( addr cnt -- ) Hex dump of hub RAM - (NOTE: if CFETCH is vectored then other memory can be accessed)
Deprecated in favour of BDUMP in EXTEND.fth - still used internally }
DUMP    byte  BOUNDS,DO
        byte    XCALL,xCR
        byte    I,XCALL,xPRTWORD
        byte    XCALL,xPRTSTR,": ",0
        byte    I,_BYTE,$10,BOUNDS,DO
        byte      I,CFETCH,XCALL,xPRTBYTE
        byte      BL,XCALL,xEMIT,LOOP
        byte      XCALL,xPRTSTR,"   ",0
        byte      I,_BYTE,$10,BOUNDS,DO
        byte        I,CFETCH,DUP,BL,XCALL,xLT,OVER,_BYTE,$7E,GT,_OR
        byte        _IF,03,DROP,_BYTE,"."
        byte        XCALL,xEMIT,LOOP
        byte    _BYTE,$10,PLOOP
        byte    XCALL,xCR,EXIT

{HELP COGDUMP ( addr cnt -- ) Dump cog memory, but try to minimize stack usage }
COGDUMP byte  REG,temp,WSTORE,REG,temp+2,WSTORE,JUMP,@cdm2-@cdmlp
cdmlp   byte    REG,temp+2,WFETCH,_3,_AND,ZEQ,_IF,@cdm3-@cdm2
cdm2    byte  XCALL,xCR,REG,temp+2,WFETCH,XCALL,xPRTWORD,XCALL,xPRTSTR,": ",0
cdm3    byte    REG,temp+2,WFETCH,XOP,pCOGFETCH,XCALL,xPRTLONG,BL,XCALL,xEMIT
        byte    _1,REG,temp+2,WPLUSST,MINUS1,REG,temp,WPLUSST
        byte    REG,temp,WFETCH,ZEQ,_UNTIL,@cdm1-@cdmlp
cdm1    byte    EXIT

PRTSTK
        byte    REG,base,CFETCH,PUSHR,XCALL,xDECIMAL
        byte    XCALL,xPRTSTR," Data Stack (",0,XCALL,xDEPTH,XCALL,xPRT,_BYTE,")",XCALL,xEMIT
        byte    XCALL,xDEPTH,_IF,@pstk2-@pstk3
pstk3   byte    _16,XOP,pCOGREG,XOP,pCOGFETCH,_8,PLUS,XCALL,xDEPTH,_SHL1,_SHL1,OVER,PLUS
pstklp  byte    XCALL,xCR,_BYTE,"$",XCALL,xEMIT,DUP,FETCH,DUP,XCALL,xPRTLONG
        byte    XCALL,xPRTSTR," - ",0,XCALL,xPRT
'       byte    _4,MINUS,OVER,OVER,EQ,_UNTIL,@pstk1-@pstklp
        byte    _4,MINUS,OVER,OVER,_4,MINUS,EQ,_UNTIL,@pstk1-@pstklp
pstk1   byte    DROP2
pstk2   byte    RPOP,REG,base,CSTORE,EXIT

STACKS  byte    _0,XOP,pCOGREG,_BYTE,tos-REG0,PLUS,EXIT   ' put the address of tos on the top of the stack
' LSTACK ( index -- cog_addr ) push address of the loop stack in cog memory
LSTACK  byte    _WORD,(loopstk>>8),loopstk,PLUS,EXIT



PRTSTKS ' Print stacks but avoid cluttering with data from debug routines
        byte    XCALL,xPRTSTK
' RETURN STACK
        byte    XCALL,xSTACKS,_BYTE,datsz,PLUS,_BYTE,retsz
        byte    XCALL,xPRTSTR,$0D,$0A,"RETURN STACK ",0
        byte    XCALL,xCOGDUMP
' LOOP STACK
        byte    XCALL,xSTACKS,_BYTE,datsz+retsz,PLUS,_BYTE,loopsz
        byte    XCALL,xPRTSTR,$0D,$0A,"LOOP STACK ",0
        byte    XCALL,xCOGDUMP
' BRANCH STACK
        byte    XCALL,xPRTSTR,$0D,$0A,"BRANCH STACK ",0
        byte    XCALL,xSTACKS,_BYTE,datsz+retsz+loopsz,PLUS,_BYTE,branchsz
        byte    XCALL,xCOGDUMP
        byte    EXIT

' Print the stack(s) and dump the registers - also called by hitting <ctrl>D during text input
DEBUG   byte    XCALL,xPRTSTKS
        byte    XCALL,xPRTSTR,$0D,$0A,"REGISTERS",0
        byte    REG,temp,_WORD,1,00,XCALL,xDUMP
        byte    XCALL,xPRTSTR,$0D,$0A,"COMPILATION AREA",0
        byte    REG,here,WFETCH,_BYTE,$40,XCALL,xDUMP
        byte    EXIT




' COG CONTROL

        org
        byte    0               ' align OPCODE long
_REBOOT
        byte    _BYTE,$80,OPCODE
                CLKSET  tos

        org
        byte    0,0             ' align OPCODE long
{HELP STOP ( cog -- )   stop the COG }
STOP    ' STOP ( cog -- )
        byte    DROP,OPCODE     ' need to drop parameter before opcode which always EXITs but dropped is in X via POPX
                cogstop X


{HELP HERE ( -- addr ) Address of next compilation location }
_HERE   byte    REG,here,WFETCH,EXIT

' SET ( mask caddr -- ) Set bit(s) in hub byte
SET     byte    DUP,CFETCH,ROT,_OR,SWAP,CSTORE,EXIT
' CLR ( mask caddr -- ) Clear bit(s) in hub byte
CLR     byte    DUP,CFETCH,ROT,_ANDN,SWAP,CSTORE,EXIT
{
' SET ( bit caddr -- ) Set bit(s) in hub byte
CSET    byte    MASK,DUP,CFETCH,ROT,_OR,SWAP,CSTORE,EXIT
' CLR ( bit caddr -- ) Clear bit(s) in hub byte
CCLR    byte    MASK,DUP,CFETCH,ROT,_ANDN,SWAP,CSTORE,EXIT
}


' ****************************************************************************************



' ****************************************************************************************







' !SP - Initialize the data stack to a depth of zero
InitStack
        byte    _0,_BYTE,depth-REG0,XOP,pCOGREG,XOP,pCOGSTORE,EXIT      ' zero the depth index

' SP! ( addr -- )
' Assign a data stack pointer for this cog - depth depends on use - typically 8 to 32 longs required
SPSTORE byte    _BYTE,stkptr-REG0,XOP,pCOGREG,XOP,pCOGSTORE,EXIT

' DEPTH ( -- levels )
_DEPTH  byte    _BYTE,depth-REG0,XOP,pCOGREG,XOP,pCOGFETCH,_SHR1,_SHR1,DEC,EXIT

' BUFFERS ( -- addr )
' BUFFERS byte    _WORD,(@RESET+s)>>8,@RESET+s,EXIT
BUFFERS byte    _WORD,_BUFFERS>>8,_BUFFERS,EXIT

' COGINIT ( code pars cog -- ret )
' : COGINIT     SWAP 3 ANDN 2 SHL OR SWAP 3 ANDN 16 SHL OR (COGINIT) ;
aCOGINIT
'        byte    DUP,XCALL,xTASK,FOURTH,OVER,WSTORE                              ' update cog info block with code adr
'        byte    THIRD,SWAP,INC,INC,WSTORE                                       ' store pars field
        '  pCOGINIT = PAR@long(14), CODE@long(14), NEW(1),COG(3)
        byte    SWAP,_16,_SHL,_OR,SWAP,_2,_SHL,_OR,XOP,pCOGINIT,EXIT






{ *** NUMBER PRINT FORMATTING *** }

' @PAD ( -- addr ) pointer to current position in number pad
ATPAD   byte    REG,padwr,CFETCH,REG,numpad,PLUS,EXIT

' HOLD ( char -- )
HOLD    byte    MINUS1,REG,padwr,CPLUSST,XCALL,xATPAD,CSTORE,EXIT

' >CHAR  ( val -- ch ) convert binary value to an ASCII character
TOCHAR  byte    _BYTE,$3F,_AND,_BYTE,"0",PLUS,DUP,_BYTE,"9"             ' convert to "0".."9"
        byte    GT,_BYTE,7,_AND,PLUS            ' convert to "A"..
        byte    DUP,_BYTE,$5D,GT,ZEXIT,_3,PLUS,EXIT             ' skip symbols to go to "a"..

' <#    ' resets number pad write index to end of pad
LHASH   byte    _BYTE,numpadsz,REG,padwr,CSTORE,_0,XCALL,xHOLD
        byte EXIT


' # ( n1 -- n2 ) convert the next ls digit of a double to a char and prepend to number string
HASH    byte  DUP,_IF,@has12-@has22
has22   byte  REG,cntr,FETCH,REG,base,CFETCH,UMDIVMOD64,REG,cntr,STORE
        byte  SWAP,XCALL,xtoCHAR,XCALL,xHOLD,EXIT
        ' conversion digits exhausted, use zeros or spaces
has12   byte  _BYTE,$30,_BYTE,leadspaces,REG,flags,XCALL,xSETQ,_IF,02,DROP,BL,XCALL,xHOLD,EXIT
' #S ( d1 -- 0 ) Convert all digits
HASHS   byte  XCALL,xHASH,DUP,ZEQ,_UNTIL,06,EXIT
' #> ( 1 -- caddr )
RHASH   byte  DROP,XCALL,xATPAD,_BYTE,leadspaces,REG,flags,XCALL,xCLR,_0,REG,cntr,STORE,EXIT
' <D> ( d1 -- n1 ) ' Store high long of double for formating
DNUM    byte  REG,cntr,STORE,EXIT


' STREND ( str -- strend )
STRLEN  ' ( str -- len )
        byte    DUP,STREND,SWAP,MINUS,EXIT

' STR ( -- n ) Leave address of inline string on stack and skip to next instruction
_STR    byte    RPOP,DUP
STRlp   byte    CFETCHINC,ZEQ,_UNTIL,04,PUSHR,EXIT

' . ( n -- ) Print the number off the stack
PRT     byte    DUP,XCALL,xZLT,_IF,05,_BYTE,$2D,XCALL,xEMIT,NEGATE
' U. ( n -- ) Print an unsigned number
UPRT    byte    XCALL,xLHASH,XCALL,xHASHS,XCALL,xRHASH
' PRINT$ ( adr -- ) Print the null or 8th bit terminated string - stops on null or binary
PSTR    byte    CFETCHINC,DUP,_1,_BYTE,$7E,XCALL,xWITHIN,_IF,04,XCALL,xEMIT,_AGAIN,@pstrxt-@pstr
pstrxt  byte    DROP2,EXIT



PRTDEC  byte    _BYTE,10
' DEPPRECATED - only used by END - use .NUM from EXTEND.fth
' B. ( n base -- ) Print the number off the stack in the base specified
basePRT byte    REG,base,CFETCH,PUSHL,REG,base,CSTORE
        byte    XCALL,xLHASH,XCALL,xHASH,XCALL,xHASH,XCALL,xHASH,XCALL,xHASHS,XCALL,xRHASH,XCALL,xPSTR
        byte    LPOP,REG,base,CSTORE,EXIT


{ *** OPERATORS *** }
{
CLKFREQ 1234 LAP U/MOD LAP .LAP  16.600us ok
. 64829 ok
. 1014 ok
}
' U/MOD ( u1 u2 -- rem quot )
UDIVMOD byte    _0,ROT,ROT,UMDIVMOD32,DROP,EXIT

' U/ ( u1 u2 -- quot )
UDIVIDE byte    XCALL,xUDIVMOD,SWAP,DROP,EXIT

' */ ( u1 u2 div1 -- res )
' CLKFREQ 1.333333 1,000,000 LAP */ LAP .LAP  35.200us ok
MULDIV    byte    ROT,ROT,UMMUL,ROT,UMDIVMOD64,DROP,SWAP,DROP,EXIT


' 0< ( n -- flg )
ZLT     byte  _0,XCALL,xLT,EXIT

' < ( n1 n2 -- flg )
LT      byte  SWAP,GT,EXIT

' U<
ULT     byte  OVER,OVER,_XOR,XCALL,xZLT,_IF,05
        byte  SWAP,DROP,XCALL,xZLT,EXIT
        byte  MINUS,XCALL,xZLT,EXIT

' ( n lo hi -- flg ) true if n is within range of low and high inclusive
WITHIN  byte    INC,OVER,MINUS,PUSHR
        byte    MINUS,RPOP,XCALL,xULT
WT1     byte    ZEQ,ZEQ,EXIT

' SET? ( mask caddr -- flg ) Test single bit of a byte in memory
SETQ    byte    CFETCH,_AND,ZEQ,ZEQ,EXIT

' ?EXIT ( flg -- ) Exit if flg is true
IFEXIT  byte    _IF,02,RPOP,DROP,EXIT

'' The read and write index is stored as two words preceding the buffer
'' BKEY ( buffer -- ch ) ' byte size buffer is preceded with a read index, go and read the next character
'
' READBUF ( buffer -- ch|$100 )
READBUF
        byte    DUP,DEC,DEC,DUP,WFETCH                                          ' point to read index ( buffer writeptr writeindex )
        byte    SWAP,DEC,DEC,WFETCH,SWAP                                        ' ( buffer readindex writeindex )
        byte    OVER,EQ,_IF,03,DROP2,_0,EXIT                                    ' empty, return with null
        ' ( buffer read )
        byte    OVER,PLUS,CFETCH                                                '  get (buf+rd) character from buffer
        ' perform auto LF to CR subs (but not when it is part of a CRLF )
        byte    DUP,_BYTE,$0A,EQ
        byte    REG,prevch,CFETCH,_BYTE,$0D,EQ,ZEQ,_AND
        byte    _3,_AND,PLUS                                                    ' convert the LF to a CR
'
        byte    REG,prevch,CFETCH,REG,prevch+1,CSTORE
        byte    DUP,REG,prevch,CSTORE
        byte    _WORD,$01,00,PLUS                                               ' get char ( buffer [buffer+read]+$100 )
        byte    SWAP,_4,MINUS                                                   ' key readptr )
        byte    DUP,WFETCH,INC                                                  ' update read index and wrap
'        byte    DUP,REG,rxsz,WFETCH,DEC,GT,_IF,02,DROP,_0,SWAP,WSTORE
        byte    toBYTE,SWAP,WSTORE
        byte    EXIT

{
' Check the serial input stream for a key
' KEY? ( -- ch flg )
KEYQ
        byte    XCALL,xKEY,DUP,toBYTE,SWAP,EXIT ' uses standard KEY word which always returns with 0 if no key

        byte    REG,ukey,WFETCH,QDUP,_IF,03,ACALL,DUP,EXIT      ' execute user code if set
        byte    REG,rxptr,WFETCH,XCALL,xREADBUF ' read a char from the buffer
        byte    DUP,toBYTE,SWAP,_8,_SHR,ZEQ,ZEQ ' convert to char and flag format
        byte    DUP,ZEQ,ZEXIT           ' skip user keypoll if we are busy with a key
        byte    REG,keypoll,WFETCH,QDUP,_IF,01,ACALL    ' do a user keypoll if nothing else is happening
        byte    EXIT
}
{ always best to look at the need - what drives it - and then how well it addresses the need - example?
might have to come back a little later -- in the hour...

about I/O Streams
the Tachyon interpreter loops input and output can be revectored to:
1. the console (serial) with
inputStream   KEY    &   ukey = 0
outputStream  Emit   &   uEmit = 0
2. now we have
        LAN (actually 4/8 sockets)  with both input & output streams
3. we could have/have?  Bluetooth i/o
4. we have File i/o   FIMPUT / FOUTPUT
5. I created a STRING input stream 'class' where ukey can be revectored to e.g. to evaluate a STRING
        there is no corresponding string output stream yet, but could be easily created
6. I created a BUFFER input stream, which is similar to the STRING input stream, but reads from any user defined buffer
        actually the standard keyboard input stream is s.th. very similar reading from the console input buffer.
        my buffer input stream currently does NOT handle buffer wrap around as would be needed for a ringbuffer
    like the console input buffer.
7. I created a kind of filter stream, which sits on top of any other input stream and performs some
        modifications.  here especially transforming URL escape codes (the %20 etc. ) back to the respective ASCII char
        ( in EVAL$.FTH shared with you )
btw.: similar to a STRING$ 'class' we could have a BUFFER§ class with read&write pointers and size just before the buffer area
        and standard methods for reading/writing a buffer  val bufAdr §!  and bufAdr §@ -> val
        e.g. what you have as the console input buffer ... ,  and of course the SD buffer SDBUF with   val SDBUF §!
        pub §! ( val bufadr -- ) 2- DUP ROT SWAP W@ C! W++ (+ handle wrap) ;
    pub §@ ( bufaddr -- val ) 2- 2- DUP W@ SWAP W++   (+ handle wrap) ;
        MAKEBUF ( size <name> )  creates the buffer allocating 3 words for (rd/wr ptr + size) + size bytes
such a buffer would be the ideal base for a read/write stream.
btw: READBUF would not need the special regs to store sz&ptr if handled as a generic buffer  - it is needed, before the generic BUFFER is there so forget this
a MAKEBUFSTREAM ( size <bufname> ) would perform a MAKEBUF and create 2 additions words
pub <bufname>RD and <bufname>WR which can be used as ukey / uemit values.
pub <bufname>RD ( bufadr -- val )  ' <bufname> §@ ;

I am not sure I like the new KEY behaviour with respect to a uniform way of reading all the different types of input stream, as described above ...

btw:  in your assembler the # immediate char could also be handled by the unknown word hook ??
        to make it even more PASM like (not that it is really required ;-)


\ just watching  I was using the ukey redirection as well for EVAL$ etc. as a StringReadStream
\ did you see it? having a more unified read/write stream mechanism might be useful.
currently there are many small pieces
}
' PUTKEY ( ch -- ) Force a character as the next KEY read
' PUTKEY        byte    REG,keychar,CSTORE,EXIT
' V2.4 relegates KEY to a character stream so therefore nulls are not passed but a null is a null, same as no key
' V2.5 I decided to pass a null but as $100 so it is still a null when treated as a byte but zero = no key
' KEY ( -- ch ) if ch is zero then no key was read
KEY
        byte    REG,keychar,CFETCH
        byte    QDUP,_IF,06,_0,REG,keychar,CSTORE
        byte    JUMP,@CHKKEY-@ky00              ' read a "key" that was forced with KEY!
ky00
        byte    REG,ukey,WFETCH,QDUP    ' or be redirected to a user key routine?
        byte    _IF,03,ACALL,JUMP,@CHKKEY-@ky01 ' redirect key input to ukey vector
ky01                                    ' Default key input if ukey is not set
CONKEY
        byte    REG,rxptr,WFETCH,XCALL,xREADBUF ' this returns with a character with b8 = $100 ? set or a false
        byte    DUP,_IF,@DOPOLL-@cky
cky     byte    toBYTE,DUP,ZEQ,_IF,04,_WORD,$01,00,PLUS
        byte    JUMP,@CHKKEY-@DOPOLL    ' return now if we have a key striped back to 8-bits w/o background polling
                                        ' background polling while waiting for a key
DOPOLL  'byte   _WORD,$01,00,REG,rxsz,WSTORE
        byte    REG,keypoll,WFETCH,QDUP,_IF,01,ACALL,EXIT       ' execute background polling while waiting for input

' WKEY ( -- ch ) wait for a key and return with character
WKEY    byte    XCALL,xKEY,QDUP,_UNTIL,05,toBYTE,EXIT

' keep a track of the position of the this key on the input line (useful for assembler etc)
CHKKEY  byte    _1,REG,keycol,CPLUSST,DUP,_BYTE,$0D,EQ,ZEXIT,_0,REG,keycol,CSTORE,EXIT

_LASTKEY ' ( -- adr )
        byte  REG,rxptr,WFETCH,DUP,DEC,DEC,WFETCH,DEC,toBYTE,PLUS,EXIT


{ *** COMMENTING *** }

'       \       ( -- )
'       Ignore following text till the end of line.
'       IMMED
COMMENT
        byte    REG,delim+1,CFETCH,_BYTE,$0D,EQ,ZEQ,ZEXIT
        byte    XCALL,xKEY,_BYTE,$0D,EQ,_UNTIL,7        ' terminate comment on a CR
        byte    _BYTE,$0D,REG,keychar,CSTORE,EXIT       ' force a CR back into the key stream on exit
'       (       stack or other short inline comments )
BRACE   byte    XCALL,xECHOKEY,_BYTE,")",EQ,_UNTIL,7,EXIT

IFDEF   byte    XCALL,xNFATICK,ZEQ,JUMP,02
IFNDEF  byte    XCALL,xNFATICK,ZEXIT
' {     Block comments - allow nested {{  }} operation
CURLY   byte    _1,REG,11,CSTORE                ' allow nesting by counting braces
CURLYlp         byte    XCALL,xWKEY             ' keep reading each char until we have a matching closing brace
        byte DUP,_BYTE,"{",EQ,_IF,04,_1,REG,11,CPLUSST  ' add up opening braces
        byte _BYTE,"}",EQ,_IF,04,MINUS1,REG,11,CPLUSST  ' count down closing braces
        byte REG,11,CFETCH,ZEQ,_UNTIL,@CURLYxt-@CURLYlp
CURLYxt byte EXIT


{ *** MOVES & FILLS *** }
' <CMOVE ( src dst cnt -- ) byte move in reverse from the ends to the start
RCMOVE  byte    ROT,OVER,PLUS,DEC,ROT,THIRD,PLUS,DEC,ROT,XOP,pRCMOVE,EXIT

' ( addr cnt -- )
ERASE   byte    _0
' ( addr cnt fillch -- )
FILL    byte    THIRD,CSTORE,DEC,OVER,INC,SWAP,XOP,pCMOVE,EXIT


{ *** TIMING *** }

' ms ( n -- ) Wait for n milliseconds
ms       byte  QDUP,ZEXIT,PUSH3,$01,$38,$80,UMMUL,DROP,XOP,pDELTA,EXIT



{ *** NUMBER BASE *** }


' change the default number bases
BIN     byte  _2,JUMP,@SetBase-@DECIMAL
DECIMAL byte  _BYTE,10,JUMP,@SetBase-@HEX
HEX     byte  _BYTE,16
SetBase byte  REG,BASE,CSTORE,EXIT

{ *** OUTPUT OPERATIONS *** }

CLS     byte    _BYTE,$0C,XCALL,xEMIT,EXIT
SPACE   byte    BL,XCALL,xEMIT,EXIT
BELL    byte    _BYTE,7,XCALL,xEMIT,EXIT
CR      byte    _BYTE,$0D,XCALL,xEMIT,_BYTE,$0A,XCALL,xEMIT,EXIT

SPINNER byte    REG,spincnt,CFETCH,_3,_SHR,_3,_AND,XCALL,x_STR,"|/-\",0,PLUS,CFETCH
        byte    XCALL,xEMIT,_8,XCALL,xEMIT,_1,REG,spincnt,CPLUSST,_1,XCALL,xms,EXIT


' PROMPT
OK      byte  XCALL,xPRTSTR," ok",$0D,$0A,0,EXIT


' ?EMIT ,( ch --  ) suppress emitting the character if echo flag is off
QEMIT           byte _BYTE,echo,REG,flags,XCALL,xSETQ,_IF,03,XCALL,xEMIT,EXIT,DROP,EXIT


TULP            byte  INC
' >UPPER  ( str1 --  ) Convert lower-case letters to upper-case
TOUPPER
        byte  DUP,CFETCH,QDUP,_IF,@TUX-@TU1                     ' end of string?
TU1             byte  _BYTE,"a",_BYTE,"z",XCALL,xWITHIN
        byte  _UNTIL,@TU2-@TULP
TU2             byte  _BYTE,-$20,OVER,CPLUSST,_AGAIN,@TUX-@TULP         ' convert case
TUX             byte  DROP,EXIT




{ *** STRING TO NUMBER CONVERSION *** }

' functional test for now - optimize later
' Convert ASCII value as a digit to a numeric value - only interested in bases up to 16 at present
'
TODIGIT ' ( char -- val flg )
        byte    DUP,_BYTE,"0",_BYTE,"9",XCALL,xWITHIN,_IF,@td8-@td7             ' only work with 0..9,A..F
td7     byte    _BYTE,"0",MINUS,_TRUE,EXIT              ' pass decimal digits
td8     byte    DUP,_BYTE,"A",_BYTE,"F",XCALL,xWITHIN,_IF,@td2-@td1
td1     byte    _BYTE,$37,MINUS,_TRUE,EXIT              ' pass hex digits
td2     byte    _FALSE,EXIT

{  Try to convert a string to a number
Allow all kinds of symbols but these are the rules for it to be treated as a number.
1. Leading character must be either a recognized prefix or a decimal digit
2. If trailing character is a recognized suffix then the first character must be a decimal digit
Acceptable forms are:
$1000   hex number
1000h
#1000   decimal number
1000d
%1000   binary number
1000b

Also as long as the first character and last character are valid (0..9,prefix,suffix) then any symbols me be mixed in the number i.e.
11:59  11.59  #5_000_000
}
_NUMBER ' ( str -- value digits | false )
        byte    _0,REG,4,STORE                                                  ' REG0L = 0
        byte    _BYTE,sign,REG,flags,XCALL,xCLR                                 ' clear sign
        byte    DUP,CFETCH,REG,prefix,CSTORE                                    ' save prefix (it may or may not be)
snlp    byte    DUP,STREND,DEC,CFETCH,REG,suffix,CSTORE                         ' save suffix (assume string has count byte)
        byte    DUP,CFETCH,_BYTE,"-",EQ,_IF,@sn01-@sn00                         ' save SIGN
sn00    byte    _BYTE,sign,REG,flags,XCALL,xSET,INC
sn01
        ' PREFIX HANDLER
        byte    DUP,CFETCH                                                      ' check prefix
        '       ( str ch )
        byte    _FALSE                                                          ' preset prefix flag = false
        byte    OVER,_BYTE,"$",EQ,_IF,04,XCALL,xHEX,_TRUE,_OR                   ' as does $ - also set hex base
        byte    OVER,_BYTE,"#",EQ,_IF,04,XCALL,xDECIMAL,_TRUE,_OR               ' as does # - also set decimal base
        byte    OVER,_BYTE,"%",EQ,_IF,04,XCALL,xBIN,_TRUE,_OR                   ' as does % - also set binary base
        byte    OVER,_BYTE,"&",EQ,_IF,@pf1-@pf0                                 ' as does & - also set decimal base and IP notation
pf0     byte    XCALL,xDECIMAL,_TRUE,_OR
        byte    _BYTE,$80,REG,bnumber+3,CSTORE                                  ' this forces "." symbols to work the same as ":"

pf1     byte    DUP,_IF,04,ROT,INC,ROT,ROT                                      ' adjust string pointer to skip prefix
        '       ( str ch flg )
        byte    SWAP,_BYTE,"0",_BYTE,"9",XCALL,xWITHIN,_OR                      ' 0..9 forces processing as a number
        '       ( str flg )
        byte    ZEQ,_IF,03,DROP,_FALSE,EXIT                                     ' Give up now, it isn't a candiate
        '       ( str )                                                         ' so far, so good, now check suffix
        ' SUFFIX HANDLER
        byte    REG,suffix,CFETCH
        byte    DUP,_BYTE,"0",_BYTE,"9",XCALL,xWITHIN                           ' 0..9
        byte    OVER,_BYTE,"A",_BYTE,"F",XCALL,xWITHIN,_OR                      ' A..F ( str sfx flg ) true if still a digit
        byte    OVER,_BYTE,"h",EQ,_IF,04,XCALL,xHEX,_TRUE,_OR                   ' h = HEX
        byte    OVER,_BYTE,"b",EQ,_IF,04,XCALL,xBIN,_TRUE,_OR                   ' b = BINARY
        byte    SWAP,_BYTE,"d",EQ,_IF,04,XCALL,xDECIMAL,_TRUE,_OR               ' d = DECIMAL
        byte    ZEQ,_IF,03,DROP,_FALSE,EXIT                                     ' bad suffix, no good
        ' so far the prefix and suffx have been checked prior to attempt a number conversion
        ' From here on there must be at least one valid digit for a number to be accepted
        ' DIGIT EXTRACTION & ACCUMULATION
nmlp    byte    DUP,CFETCH,DUP,_IF,@nmend-@nm1                                  ' while there is another character
nm1     byte    XCALL,xTODIGIT,_IF,@nmsym-@nm2                                  ' convert to a digit? or else check symbol
nm2     ' a digit has been found but is it valid for this base?                 ' ( str val )
        byte    DUP,REG,BASE,CFETCH,DEC,GT,_IF,@nmok-@nm3
nm3     byte    DROP2,_FALSE,EXIT                                               ' a digit but exceeded base
nmok    byte    REG,anumber,FETCH,REG,BASE,CFETCH,UMMUL,DROP                    ' shift anumber left one digit (base)
        byte    PLUS,REG,anumber,STORE                                          ' and merge in new digit
        byte    _1,REG,digits,CPLUSST                                           ' update number of digits
nmnxt   byte    INC,_AGAIN,@nmsym-@nmlp                                         ' update str and loop

        ' character was not a digit - check for valid symbols (keep it simple for now)
        ' SYMBOLS
nmsym   byte    DROP,DUP,CFETCH,_BYTE,":",EQ                                    ' clock colon seperator
        byte    OVER,CFETCH,_BYTE,".",EQ                                        ' decimal seperator
        byte    DUP,_IF,06,REG,digits,CFETCH,REG,dpl,CSTORE                     ' remember last decimal place (if needed)
        byte    REG,bnumber,FETCH,ZEQ,ZEQ,_AND,_OR                              ' Was & prefix flagged? bnumber+3
        byte    REG,prefix,CFETCH,_BYTE,"&",EQ,_OR                              ' Process as & prefixed?
        byte    _IF,@nmsym2-@nmsym1                                             ' Use : as special byte shift for IP notation etc
nmsym1  byte    REG,bnumber,FETCH,REG,anumber,FETCH                             ' 160507 bug found with leading zero &00.xx
        byte    PLUS,_SHL8,REG,bnumber,STORE,_0,REG,anumber,STORE               ' accumulate & number in bnumber $nnnnnn00
nmsym2  byte    _AGAIN,@nmend-@nmnxt                                            ' just ignore other symbols for now
        '
nmend   ' end of string - check
        byte    DROP2,REG,digits,CFETCH,DUP,ZEXIT                               ' return with false if there are no digits
        byte    REG,anumber,FETCH,REG,bnumber,FETCH,PLUS
        byte    _BYTE,sign,REG,flags,XCALL,xSETQ,QNEGATE
        byte    SWAP,EXIT                                                       ' all good, return with number and true

' NUMBER processing -try to convert a string to a number
NUMBER  ' ( str -- value digits | false )
        byte    DUP,XCALL,xSTRLEN,_2,EQ                                         ' process control prefix i.e. ^A
        byte    OVER,CFETCH,_BYTE,"^",EQ,_AND,_IF,@ch01-@ctlch                  ' ^ch  Accept caret char as <control> char
ctlch   byte    INC,CFETCH,_BYTE,$1F,_AND,_1,EXIT                               ' control character processed

ch01    byte    DUP,XCALL,xSTRLEN,_3,EQ                                         ' process character literal i.e. "A"
        byte    OVER,CFETCH,DUP,_BYTE,$22,EQ,SWAP,_BYTE,$27,EQ,_OR
        byte    _AND,_IF,@ch02-@ascch                                           ' "ch" or 'ch' Accept as an ASCII literal
ascch   byte    INC,CFETCH,_1,EXIT

                                                                                ' It wasn't an ASCII literal, process as a number
ch02    byte    REG,anumber,_BYTE,10,_0,XCALL,xFILL                             ' zero out assembled number (double), digits, dpl
        byte    REG,base,CFETCH,REG,base+1,CSTORE                               ' backup current base as it may be overridden
        byte    XCALL,x_NUMBER
nmb1    byte    REG,base+1,CFETCH,REG,base,CSTORE,EXIT                          ' restore default base before returning





{ *** COMPILER EXTENSIONS *** }



' Most of these words are acted upon immediately rather than compiled as they are
' part of the "compiler" in that they create the necessary structures
'

' dumb compiler for literals - improve later - just needs to optimize the number of bytes needed
LITCOMP ' ( n -- ) compile the literal according to size
        byte    DUP,_BYTE,24,_SHR
        byte    _IF,@lco1-@LITC4
        ' Compile 4 bytes - 32bits
LITC4   byte    _BYTE,PUSH4,XCALL,xBCOMP
        byte      DUP,_BYTE,24,_SHR,XCALL,xBCOMP
        byte      DUP,_BYTE,16,_SHR,XCALL,xBCOMP
        byte      DUP,_SHR8,XCALL,xBCOMP
        byte      XCALL,xBCOMP,EXIT
lco1
        byte    DUP,_BYTE,16,_SHR
        byte    _IF,@lco2-@LITC3
        ' Compile 3 bytes - 24bits
LITC3   byte    _BYTE,PUSH3,XCALL,xBCOMP
        byte      DUP,_BYTE,16,_SHR,XCALL,xBCOMP
        byte      DUP,_SHR8,XCALL,xBCOMP
        byte      XCALL,xBCOMP,EXIT
lco2
        byte    DUP,_SHR8
        byte    _IF,@LITC1-@LITC2
        ' Compile 2 bytes - 16bits
LITC2   byte    _BYTE,PUSH2,XCALL,xBCOMP
        byte      DUP,_SHR8,XCALL,xBCOMP
        byte      XCALL,xBCOMP,EXIT
        ' Compile 1 byte - 8bits
LITC1   byte    _BYTE,_BYTE,XCALL,xBCOMP
        byte      XCALL,xBCOMP,EXIT

' MARK ( addr tag -- tag&addr ) Merge tag and addr by shifting tag into hi word
MARK    byte    _BYTE,16,_SHL,_OR,EXIT
' UNMARK        ( tag&addr -- addr tag )
UNMARK  byte    DUP,_WORD,$FF,$FF,_AND,SWAP,_BYTE,$10,_SHR,EXIT

' BEGIN as in BEGIN...AGAIN or BEGIN...UNTIL
_BEGIN_ byte    REG,codes,WFETCH,_BYTE,$BE,XCALL,xMARK          ' generate branch for BEGIN
bg01    byte    EXIT
' UNTIL ( flg -- )
_UNTIL_ byte    XCALL,xUNMARK
unt00   byte    _BYTE,$BE,EQ,_IF,@badthen-@unt01
unt01   byte    _BYTE,_UNTIL,XCALL,xBCOMP,JUMP,@calcback-@_REPEAT_              '
' AGAIN
_REPEAT_        byte    XCALL,xUNMARK
rp00    byte    _BYTE,$1F,EQ,_IF,@badrep-@rp02
rp02    byte    REG,codes,WFETCH,INC,INC,OVER,MINUS,SWAP,DEC,CSTORE     ' process branch of WHILE to after REPEAT
        byte    JUMP,@_AGAIN_-@badrep
badrep  byte    DROP2,JUMP,@badthen-@_AGAIN_
_AGAIN_ byte    XCALL,xUNMARK
ag00    byte    _BYTE,$BE,EQ,_IF,@badthen-@ag01         '
ag01    byte    _BYTE,_AGAIN
        ' ( addr bc -- ) compile the bytecode and calculate the branch back
lpcalc  byte  XCALL,xBCOMP
calcback        byte    REG,codes,WFETCH,INC,SWAP,MINUS,XCALL,xBCOMP
        byte    EXIT

' IF as in IF...THEN or IF...ELSE...THEN
_WHILE_
_IF_    byte    _BYTE,_IF,XCALL,xBCOMP,_0,XCALL,xBCOMP
        byte    REG,codes,WFETCH,_BYTE,$1F,XCALL,xMARK
if01    byte    EXIT
' ELSE
_ELSE_  byte    XCALL,xUNMARK
el00    byte    _BYTE,$1F,EQ,_IF,@badthen-@el01         ' does this match an IF?
el01    byte    _BYTE,JUMP,XCALL,xBCOMP,_0,XCALL,xBCOMP         ' Compile a jump forward just like an IF
        byte    REG,codes,WFETCH,_BYTE,$1F,XCALL,xMARK          ' mark the else to be processed on a THEN
el02    byte    SWAP,_BYTE,$1F,XCALL,xMARK                      ' get the IF addr and proceed as if it were a THEN
el03
' THEN
_THEN_  byte    XCALL,xUNMARK
th00    byte    _BYTE,$1F,EQ,_IF,@badthen-@RESFWD
RESFWD  byte    REG,codes,WFETCH,OVER,MINUS,SWAP,DEC,CSTORE,EXIT        ' calculate branch and update IF's branch
badthen byte    XCALL,xPRTSTR," Structure mismatch! ",0
        byte    XCALL,xERROR
        byte    DROP,EXIT

' " string"     Compile a literal string - no length restriction - any codes can be included except the delimiter "
_STR_   byte    _BYTE,XCALL,XCALL,xBCOMP,_BYTE,x_STR,XCALL,xBCOMP       ' compile bytecodes for string
        byte    JUMP,@COMPSTR-@st01
st01

ECHOKEY byte    XCALL,xWKEY,DUP,XCALL,xQEMIT,EXIT

SEQKEY  byte    XCALL,xECHOKEY,DUP,_BYTE,"\",EQ,ZEXIT                           ' return immediately if not \
        byte    DROP,XCALL,xECHOKEY
' hex literal
        byte    DUP,_BYTE,"$",EQ,_IF,@sk01-@sk00                                ' process hex number \$XX
sk00    byte    DROP,_1,_2,FOR,_4,_SHL,XCALL,xECHOKEY                           ' 2 seq hex nibbles
        byte    XCALL,xTODIGIT,_AND,_OR,forNEXT,EXIT                            ' non hex = 0, ret with $1xx
' optional checks
sk01    byte    DUP,_BYTE,"n",EQ,_IF,04,DROP,_BYTE,$0A,EXIT                     ' newline
        byte    DUP,_BYTE,"r",EQ,_IF,04,DROP,_BYTE,$0D,EXIT                     ' line return
        byte    DUP,_BYTE,"t",EQ,_IF,04,DROP,_BYTE,$09,EXIT                     ' tab
' default passthrough
        byte    _1,_SHL8,_OR,EXIT        ' return with any other character+$100 (prevent exit, same byte still)


' PRINT" HELLO WORLD"   Compile a literal print string - no length restriction - any codes can be included except the delimiter "
_PSTR_  byte    _BYTE,XCALL,XCALL,xBCOMP,_BYTE,xPRTSTR,XCALL,xBCOMP             ' compile PRTSTR code bytes
COMPSTR                                                                         ' compile string itself + term
pslp    byte    XCALL,xSEQKEY,DUP,_BYTE,$22,EQ,_NOT,_AND
ps02    byte    DUP,XCALL,xBCOMP,ZEQ,_UNTIL,@ps01-@pslp
ps01    byte    EXIT

{ *** CASE STRUCTURE *** }


{ TACHYON CASE STRUCTURES
This implementation follows the C method to some degree.
Each CASE statement simply compares the supplied value with the SWITCH and executes an IF
To prevent the IF statement from falling through a BREAK is used (also acts as a THEN at CT)
The SWITCH can be tested directly and a manual CASE can be constructed with IF <code> BREAK

SWITCH ( switch -- )             \ Save switch value used in CASE structure
CASE ( val -- )                  \ compare val with switch and perform an IF. Equivalent to SWITCH= IF
BREAK                            \ EXIT (return) but also completes IF structure at CT. Equivalent to EXIT THEN
\ extra functions to allow the switch to be manipulated etc
SWITCH@ ( -- switch )            \ Fetch last saved switch value
SWITCH= ( val -- flg )           \ Compare val with switch. Equivalent to SWITCH@ =
SWITCH>< ( from to -- flg )    \ Compare switch within range. Equivalent to SWITCH@ ROT ROT WITHIN

Usage:

pub CASEDEMO  ( val -- )
   SWITCH                \ use the key value as a switch in the case statement
   "A" CASE CR ." A is for APPLE " BREAK
   "H" CASE CR ." H is for HAPPY " BREAK
   "Z" CASE CR ." Z is for ZEBRA " BREAK
   $08 CASE 4 REG ~ BREAK
   \ Now accept 0 to 9 and build a number calculator style
   "0" "9" SWITCH>< IF SWITCH@ $30 - 4 REG @ #10 * + 4 REG ! ." *" BREAK
   \ On enter just display the accumulated number
   $0D CASE CR ." and our lucky number is " 4 REG @ .DEC BREAK
   \ show how we can test more than one value
   "Q" SWITCH= "X" SWITCH= OR IF CR ." So you're a quitter hey?" CR CONSOLE BREAK
   CR ." I don't know what " SWITCH@ EMIT ."  is"
    ;
pub DEMO
   BEGIN WKEY UPPER CASEDEMO AGAIN
 ;


        byte    $20,"BREAK",    hd+xc+im,       XCALL,xISEND
        byte    $20,"CASE",     hd+xc+im,       XCALL,xIS
        byte    $20,"SWITCH",   hd+xc,  XCALL,xSWITCH
        byte    $20,"SWITCH@",  hd+xc,  XCALL,xSWITCHFETCH
        byte    $20,"SWITCH=",  hd+xc,  XCALL,xISEQ
        byte    $20,"SWITCH><", hd+xc,  XCALL,xISWITHIN
}


' SWITCH ( val -- )
_SWITCH byte    REG,uswitch,STORE,EXIT
' SWITCH@ ( -- val )
SWITCHFETCH
        byte    REG,uswitch,FETCH,EXIT
' SWITCH= ( val -- flg )
ISEQ    byte    REG,uswitch,FETCH,EQ,EXIT
' CASE ( compare -- )
IS      byte    _BYTE,XCALL,XCALL,xBCOMP,_BYTE,xISEQ,XCALL,xBCOMP,XCALL,x_IF_,EXIT
' BREAK
ISEND   byte    _BYTE,EXIT,XCALL,xBCOMP,XCALL,xALLOCATED,XCALL,x_THEN_,EXIT


' SWITCH>< ( from to -- flg )..
ISWITHIN        byte    XCALL,xSWITCHFETCH,ROT,ROT,XCALL,xWITHIN,EXIT


{  Table vectoring -
index a table of bytecode vectors and jump to that bytecode
A table limit is supplied as well as a default bytecode vector
NOTE: bytecode is compiled automatically so this simple method uses the compiled bytecode as is,
but a more flexible method would just compile the 16-bit call address although the LOOKUP word
would then become more complicated in parsing each successive word and compiling its address
while looking for a end.

 Usage:
        <limit> VECTORS <vector if over>
        <vector0> <vector1> ...... <vectorx>)
Sample:
        4 LOOKUP BELL                   \ an index of 4 or more will default to BELL
        INDEX0 INDEX1 INDEX2 INDEX3     \ 0 to 3 will execute corresponding vectors

}
' LOOKUP
' VECTORS ( index range -- )
VECTORS byte    OVER,GT,ZEQ,_IF,02,DROP,MINUS1                                  ' limit index to range or -1 (.>0)
        byte    INC,_SHL1,RPOP,PLUS,CFETCHINC,SWAP,CFETCH                       ' form index into vectors (non-aligned)
EXECUTE ' ( bytecode1 bytecode2 -- )            ' 2 bytecodes

{
        word  _SHL8+_OR<<8                                                      ' word align bytecode now for bcexec word access
        byte  _WORD,(@bcexec+s)>>8,@bcexec+s,WSTORE
bcexec  byte  EXIT,EXIT,EXIT
}
        byte    _WORD,(@bcexec+s)>>8,@bcexec+s
        byte    ROT,OVER,CSTORE,INC,CSTORE
bcexec  byte    EXIT,EXIT,EXIT
'}

' XCALLS ( -- addr ) address of XCALLS vector table
_XCALLS byte    _WORD,(@XCALLS+s)>>8,@XCALLS+s,EXIT


{ *** COMPILER *** }
' 12103 - adding a more general method for creating a call vector

{HELP +CALL ( addr -- index opcode ) ( addr -- 0 0 ) ' index = 0..$7FE
Store the addr in the next blank word entry in the XCALL vector table and return with the
bytecodes ready to compile in the form nCALL <index8>
If there are no blank entries then return with the addr and 0 to indicate fail
}
' 150105 - faster +CALL procedure - measured 2ms for same conditions on old at 5.4ms

AddACALL
        byte    XCALL,xXCALLS
        byte    INC,INC,DUP,WFETCH,ZEQ,_UNTIL,07                                ' find a blank vector ( addr ptr )
        byte    DUP,XCALL,xXCALLS,MINUS                                         ' to index ( addr ptr index )
        byte    _BYTE,vecshr,_SHR,_IF,03,DROP,_0,EXIT                           ' overflow index - failed ( -- addr 0 )
        ' ( addr ptr )
        byte    SWAP,OVER,WSTORE                                                ' ( ptr ) store addr in vector
        byte    XCALL,xXCALLS,MINUS                                             ' ( index ) convert to index
        byte    _SHR1,DUP,_1,_AND,_BYTE,XCALL,SWAP,MINUS                        ' calculate the opcode (as XCALL,YCALL,ZCALL..)
'        byte    OVER,_WORD,$02,00,_AND,ZEQ,ZEQ,_SHL1,PLUS
        byte    SWAP,_SHR1,toBYTE,SWAP
        byte    EXIT

' ( bytecode -- ) append this bytecode to next free code location + append EXIT (without counting)
BCOMP
        byte    REG,codes,WFETCH,CSTORE,_1,REG,codes,WPLUSST
        byte    _BYTE,EXIT,REG,codes,WFETCH,CSTORE
        byte    EXIT

' NFA' ( <name> -- nfaptr )
' COMPILE  ( not used in this version )
NFATICK         byte    XCALL,xGETWORD,DEC,XCALL,xSEARCH,EXIT

_NFATICK        byte    XCALL,xNFATICK,XCALL,xLITCOMP,EXIT

' ' <name>  ( -- pfa ) Find the address of the following word - zero if not found or it's PFA (bytecodes do not have a CFA)
TICK    byte    XCALL,xNFATICK,DUP,ZEXIT,XCALL,xNFABFA,XCALL,xBFACFA,EXIT

ATICK   byte    XCALL,xTICK
        byte    XCALL,xLITCOMP,EXIT



{HELP BCOMPILE ( atradr -- )
DESC: compile bytecodes according to header attribute - 0 = one bytecode ; 2 = 2 bytecodes ; 3 = absolute CALL16
}
BCOMPILE
        byte    CFETCHINC,_3,_AND                       ' ( cfaadr atr ) just use 2 bits for test
        ' 0
        byte    DUP,ZEQ,_IF,05,DROP,CFETCH,XCALL,xBCOMP,EXIT            ' compile a single bytecode
        ' 2  = XCALL or 6 = XOP 2 byte sequence
        byte    DUP,_2,EQ,_IF,08
        byte    DROP,CFETCHINC,XCALL,xBCOMP,CFETCH,XCALL,xBCOMP,EXIT
        ' 3 = CALL16?
        byte    DUP,_3,EQ,_IF,12
        byte    DROP,_BYTE,CALL16,XCALL,xBCOMP,CFETCHINC,XCALL,xBCOMP,CFETCH,XCALL,xBCOMP,EXIT          ' compile 3 bytecodes for a CALL16
        byte    DROP2,EXIT                      ' nothing, wasn't a 0,2,or 3

' GRAB ( -- ) \ IMMEDIATE --- executes preceding code to make it available for any immediate words following
GRAB
        byte    _BYTE,EXIT,XCALL,xBCOMP         ' append an EXIT
        byte    XCALL,xHERE,DUP,REG,codes,WSTORE,ACALL          ' execute and release preceding code in text line
        byte    EXIT

' assign a new value for the constant
' 78 TO myconstant
ATO
        byte    XCALL,xGRAB,XCALL,xTICK,INC,STORE,EXIT

' ( -- atradr ) --- point to the attribute byte in the header of the latest name
ATATR   byte    REG,names,WFETCH,XCALL,xNFABFA,DEC,EXIT

' Set attribute of the latest word to PRIVATE -- used by RECLAIM (EXTEND.fth) to cull all unwanted headers.
PRIVATE         byte    XCALL,xCOLON,_BYTE,pr,XCALL,xATATR,XCALL,xSET,EXIT
{
names           res 2           ' start of dictionary (builds down)
prevname                res 2           ' temp location used by CREATE
                res 2
here            res 2           ' pointer to compilation area (overwrites VM image)
}
'  CREATEWORD - create a name in the dictionary using the next word encountered
CREATEWORD
        byte    XCALL,xGETWORD                          ' ( str ) read the next word
' (CREATE) ( str -- )
CREATESTR
        byte    REG,names,WFETCH,REG,prevname,WSTORE            ' backup names ptr (used to change fixed fields easily)
        byte    REG,flags,CFETCH,_BYTE,prset,_AND               ' get attribute
        byte    _BYTE,hd+xc,_OR                                 ' blend in private bit
        byte    XCALL,xPUTCHARPL                                ' add attribute byte to header => cnt,name,atr
        byte    REG,codes,WFETCH                                ' Create a vector to code pointer
        byte    XCALL,xAddACALL                                 '( index opcode ) or ( addr 0 )

        byte    DUP,ZEQ,_IF,@cst01-@cst00                       ' run out of vectors? then use CALL16
cst00   byte    _BYTE,$83,REG,wordcnt,DUP,CFETCH,PLUS,CSTORE
        byte    DROP,DUP,toBYTE,SWAP,_SHR8                      ' convert word addr to bytes ( str adrl adrh )
cst01   byte    XCALL,xPUTCHARPL,XCALL,xPUTCHARPL               ' write 16-bit address or bytecode sequence to wordbuf
        byte    DUP,DEC,CFETCH   'XCALL,xSTRLEN                 ' ( str cnt )
        byte    DUP,NEGATE,REG,names,WPLUSST                    ' ( str cnt ) update names ptr by backwards count
        byte    REG,names,WFETCH,SWAP,XOP,pCMOVE                ' copy it across
        byte    REG,names,WFETCH,DUP,XCALL,xSTRLEN              ' ( names cnt )
        byte    MINUS1,REG,names,WPLUSST                        ' make room for the count
        byte    SWAP,DEC,CSTORE                                 ' and set the count
        ' check for dictionary full
        byte    REG,names,WFETCH,REG,here,WFETCH,_BYTE,$40,PLUS,XCALL,xLT
        byte    _IF,@crw05-@crw04
crw04   byte    XCALL,xPRTSTR,"  Dictionary full! ",0
        byte    XCALL,xERROR
crw05   byte    EXIT

' CREATE <name> - Create a name in the dictionary and also a VARIABLE code entry - or execute call at create
CREATE  byte    REG,createvec,WFETCH,QDUP,_IF,01,AJMP           ' execute extended or user CREATE?
        byte    XCALL,xCREATEWORD                       '
        byte    _BYTE,VARB,XCALL,xBCOMP,_0              ' set default bytecode as a VARIABLE

' ALLOT ( bytes -- )
ALLOT   byte    REG,codes,WPLUSST
' lock in compiled code so far - do not release but set new "here" to the end of these codes
ALLOCATED
        byte    REG,codes,WFETCH,REG,here,WSTORE
        byte    EXIT

' C, ( n -- ) IMMEDIATE --- compile a byte into code and allocate
CCOMP
        byte    XCALL,xGRAB
cc01    byte    XCALL,xBCOMP,XCALL,xALLOCATED,EXIT
' W, ( n -- )
WCOMP
        byte    XCALL,xGRAB
wc01    byte    DUP,XCALL,xBCOMP,_SHR8,XCALL,xBCOMP,XCALL,xALLOCATED,EXIT

' , ( n -- ) Compile a long literal
LCOMP
        byte    XCALL,xGRAB
        byte    _4,FOR,DUP,XCALL,xBCOMP,_SHR8,forNEXT
        byte    DROP,XCALL,xALLOCATED,EXIT

' Create a new entry in the dictionary and also in the XCALLS table but also prevent any execution of code
' at an <enter> which would otherwise normally occur.
' unsmudge any previous name in case this is a fall-through.
' : <name>
COLON   byte    XCALL,xUNSMUDGE                 ' unsmudge any previous definition (fall-through)
        byte    XCALL,xCREATE                   ' this forms an XCALL,index to this new definition
_COLON  byte    _BYTE,sm,XCALL,xATATR,XCALL,xSET                ' smudge it so it can't be referenced yet
        byte  MINUS1,XCALL,xALLOT               ' write over VAR instruction
        byte    _BYTE,defining,REG,flags,XCALL,xSET,EXIT                ' flag that we have entered a definition

PUBCOLON        byte    XCALL,xCOLON,_BYTE,prset,XCALL,xATATR,XCALL,xCLR,EXIT

' Update "here" pointer to point to current free position which "codes" pointer is now at
' Also unsmudge the headers tag
' ;
ENDCOLON        byte    _BYTE,EXIT,XCALL,xBCOMP         ' compile an EXIT
        byte    _BYTE,defining,REG,flags,XCALL,xCLR,XCALL,xALLOCATED    ' end definition and lock allocated bytes
UNSMUDGE
        byte    _BYTE,sm,XCALL,xATATR,XCALL,xCLR,EXIT                                   ' clear the smudge bit


' [COMPILE]
COMPILES        byte    _BYTE,comp,REG,flags,XCALL,xSET,EXIT

{ *** CONSOLE INPUT HANDLERS *** }

{
Replaced traditional parse function with realtime stream parsing
Each word is acted upon when a delimiter is encountered and this also allows for
interactive error checking and even autocompletion.
}

' SCRUB --- scrub out any temporary compiled code, restore the code pointers etc.
SCRUB   byte    XCALL,xHERE,REG,codes,WSTORE
        byte    _0,REG,wordcnt,CSTORE,_0,REG,wordbuf,CSTORE
        byte    _BYTE,$0D,REG,delim+1,CSTORE                                    'restore end-of-line delimiter to a CR
        byte    _BYTE,$0D,XCALL,xEMIT,_BYTE,$40,FOR,_BYTE,"-",XCALL,xEMIT,forNEXT       'horizontal line
        byte    XCALL,xCR,EXIT

' ( ch -- ) write a character into the next free position in the word buffer
PUTCHAR byte    REG,wordcnt,DUP,CFETCH,SWAP,INC,PLUS,CSTORE,EXIT
PUTCHARPL       byte    XCALL,xPUTCHAR,REG,wordcnt,DUP,CFETCH,INC
        byte    _BYTE,wordsz,XCALL,xUDIVMOD,DROP,SWAP,CSTORE,EXIT

' As characters are accepted from the input stream, checks need to be made for delimiters,
' editing commands etc. 123us/CHAR, 184us/CTRL
doCHAR  ' ( char -- flg ) Process char into wordbuf and flag true if all done
        byte    DUP,ZEXIT                                               ' NULL - ignore
        '
'       byte    DUP,REG,lasttwo,DUP,CFETCH,OVER,INC,CSTORE,CSTORE                               ' keep a track of this and the last character
        byte    DUP,REG,delim+1,CSTORE                                                          ' delimiter is always last character
        '''
        byte    _BYTE,$7F,OVER,EQ,_IF,02,DROP,_8                                                 ' subs BS for DEL
        byte    DUP,BL,XCALL,xLT,_IF,@ischar-@ctrls                                              ' only check for control characters
'
' PROCESS CONTROL CHARACTERS
'
ctrls
'       byte    _BYTE,$80,OVER,_AND,_IF,05,_1,REG,flags+1,XCALL,xSET                            ' IAC or binary – pass special control characters
        byte    _BYTE,$0A,OVER,EQ,_IF,03,DROP,_FALSE,EXIT                                       ' LF - discard
        byte    _BYTE,$18,OVER,EQ,_IF,03,DROP,_TRUE,EXIT                                        ' ^X reeXecute previous compiled line
        byte    _1,REG,flags+1,CFETCH,_AND,ZEQ,_IF,@ignore2-@ignore1
ignore1
        byte    _3,OVER,EQ,_IF,02,XCALL,xREBOOT                                                 ' ^C RESET
        byte    _4,OVER,EQ,_IF,05,DROP,XCALL,xDEBUG,_FALSE,EXIT                                 ' ^D DEBUG
        byte    _2,OVER,EQ,_IF,09,DROP,_0,_WORD,$80,00,XCALL,xDUMP,_FALSE,EXIT                  ' ^B Block dump
        byte    _BYTE,$1A,OVER,EQ,REG,prevch+1,CFETCH,_BYTE,$1A,EQ,_AND
        byte    _IF,07,DROP,XCALL,xCOLDST,XCALL,xSCRUB,_FALSE,EXIT                              ' ^Z^Z cold start
ignore2
        byte    _BYTE,$1B,OVER,EQ,_IF,05,DROP,XCALL,xSCRUB,_TRUE,EXIT                           ' ESC will cancel line
        byte    _BYTE,$09,OVER,EQ,_IF,03,XCALL,xEMIT,BL                                         ' TAB - substitute with a space
        byte    _BYTE,$1C,OVER,EQ,_IF,04,DROP,XCALL,xCR,BL                                      ' ^| - multi-line interactive
        byte    _BYTE,$0D,OVER,EQ,_IF,03,DROP,_TRUE,EXIT                                        ' CR - Return & indicate completion
        '
        byte    _8,OVER,EQ,_IF,@ischar-@bksp1                                                   ' BKSP - null out last char
bksp1   byte    REG,wordcnt,CFETCH,_IF,@bksp3-@bksp2                                            ' don't backspace on empty word
bksp2   byte    XCALL,xEMIT,XCALL,xSPACE,_8,XCALL,xEMIT                                          ' backspace and clear
        byte    MINUS1,REG,wordcnt,CPLUSST,_0,XCALL,xPUTCHAR                                    ' null previous char
        byte    _FALSE,EXIT
        '                       '
bksp3   byte    _BYTE,7,XCALL,xEMIT,DROP,_FALSE,EXIT                                            ' can't backspace anymore, bell
        '
ischar
        byte    _BYTE,echo,REG,flags,XCALL,xSETQ,_IF,03                                         ' don't echo if we don't want it
        byte    DUP,XCALL,xEMIT
        byte    REG,delim,CFETCH,OVER,EQ                                        ' delimiter? (always accept a blank)
        byte    OVER,BL,EQ,_OR,_IF,05,DROP,REG,wordcnt,CFETCH,EXIT                              ' true if trailing delimiter - all done (flg=cnt)
        '
        ' otherwise build text in wordbuf - null terminated with a preceding count .....
        byte    XCALL,xPUTCHARPL                                                ' put a character into the word buffer
        byte    _FALSE,EXIT

' Build a delimited word in wordbuf for wordcnt and return immediately upon a valid delimiter
GETWORD ' ( -- str )
        byte    REG,wordcnt,_BYTE,wordsz,_0,XCALL,xFILL                                 ' Erase the word buffer & preceding count
gwlp    byte    XCALL,xWKEY                                             ' get another character
        byte    XCALL,xdoCHAR                                           ' process
        byte    _UNTIL,@gw1-@gwlp                                               ' continue building the next word
gw1     byte    REG,wordbuf,EXIT


{ *** DICTIONARY SEARCH *** }

{HELP DICTIONARY SEARCH

Example of last entry in dictionary "COLD"  04 43 4F 4C 44 82  BF  A4  00 00
                                             cnt C  O  L  D  atr bc1 bc2 <end>

''
'' Compare a null-terminated source string with a dictionary string which is 8th bit terminated.
'' This will always force a mismatch after which one is checked for a null while the other is checked
'' for the 8th bit and if verified then a match has been found.
'' The dict pointer is advanced to point to the end of the dict string on the 8th bit termination which
'' is the attribute byte as in: byte "CMPSTR",$80,CMPSTR
''

search timing results
DUP     54us
RESET   1ms
0       144us
BL      288us
KOLD    3.45ms
TAB     9ms
EXTEND.fth      7.87ms  9.85ms
12345   600us

Searches core names first then bytecode names
}

' SEARCH ( cstr -- nfaptr )                     ' cstr points to the count+string+null
SEARCH
        byte    REG,ufind,WFETCH,QDUP,_IF,01,AJMP               ' use alternative method if enabled (hash search)
        byte    DUP,REG,corenames,WFETCH,XCALL,xFINDSTR         ' search core words first to improve compilation speed
        byte    QDUP,_IF,03,SWAP,DROP,EXIT              ' found it - return now with result
'
        byte    DUP,REG,names,WFETCH,XCALL,xFINDSTR             ' search extended dictionary
        byte    QDUP,_IF,03,SWAP,DROP,EXIT              ' return with positive result
'
        byte    DROP,_FALSE,EXIT                        ' not found in dictionary



' ( cstr dict -- nfaptr | false ) Try to find the counted string in the dictionary(s) using CMPSTR  (ignore smudged entries)
FINDSTR
fstlp           'byte   XCALL,xCMPSTR
        byte    _0,XOP,pCMPSTR
        byte    _IF,@nxtword-@fst1                      ' found it  ( src dict )
fst1    byte    DUP,XCALL,xNFABFA,DEC,CFETCH
        byte    _BYTE,sm,_AND,ZEQ,_IF,@nxtword-@fst0
fst0    byte    SWAP,DROP,EXIT                          ' ( nfaptr ) found
        '
        ' Skip the attribute byte and codes and test for end of dictionary (entry = 00)
nxtword ' ( src dict ) advance past atr+codes to try next.  (atr(1),bytecode)
        byte    CFETCHINC,PLUS,_3,PLUS                  ' jump over CFA to next NFA
                                                ' ( src dict ) dict points to bc1
        byte    DUP,CFETCH,ZEQ,_UNTIL,@fst2-@fstlp
        ' end of dictionary reached
fst2    byte    DROP2,_FALSE,EXIT



' The CFA is the address of the 2 bytecodes stored in the header that are executed or compiled
' Typically these bytecodes will be in the form of "XCALL,xWord"
' or in the case of COG words such as DUP "DUP,EXIT" where only DUP is compiled
' NFA>BFA ( nfa -- bfa )
NFABFA  byte    CFETCHINC,PLUS,INC,EXIT        ' CFETCHINC,_BYTE,$7F,GT,_UNTIL,06,EXIT


' : >CFA  ( bfa -- cfa )
BFACFA  byte    DUP,DEC,CFETCH,_BYTE,$80,EQ,_IF,02,CFETCH,EXIT  ' if atr = COG BYTECODE - just return with it
        ' but this could be a two bytecode sequence rather than a call
        byte    DUP,CFETCH,_BYTE,XOP,EQ
        byte    OVER,DEC,CFETCH,_3,_AND,_3,EQ,_OR,_IF,06,CFETCHINC,_SHL8,SWAP,CFETCH,PLUS,EXIT
        byte    XCALL,xTOVEC
        byte    WFETCH,EXIT

' >VEC ( bfa -- vecptr )
TOVEC   byte    DUP,INC,CFETCH,_SHL1,_SHL1,XCALL,xXCALLS,PLUS                   ' ( bfa xcallptr )
        byte    SWAP,CFETCH,_BYTE,YCALL,MINUS                                   ' calculate which vector XYZ or V we are using
        byte    _1,_XOR                                                         ' ( xcallptr mod )
        ' ( ptr indexh ) 0 = XCALL, 1 = YCALL, 2 = ZCALL, 3 = VCALL
        byte    _1,_AND,_SHL1,PLUS                                             ' point to high or low vector word
        byte    EXIT

{
TOVEC   byte    DUP,INC,CFETCH,_SHL1,_SHL1,XCALL,xXCALLS,PLUS   ' ( cfa xcallptr )
        byte    SWAP,CFETCH,_BYTE,VCALL,MINUS                                   ' calculate which vector XYZ or V we are using
        byte    _3,_XOR                                                         ' ( xcallptr mod )
        ' ( ptr indexh ) 0 = XCALL, 1 = YCALL, 2 = ZCALL, 3 = VCALL
        byte    SWAP,OVER,_1,_AND,_SHL1,PLUS                                    ' point to high or low vector word
        byte    SWAP,_2,_AND,_IF,04,_WORD,$04,00,PLUS
        byte    EXIT
}




' FREE ( -- free ) Read free memory from Spin header and round up to a 64 byte page (to suit EEPROM)
'FREE   byte    _BYTE,10,WFETCH,_BYTE,$80,PLUS,_BYTE,$3F,_ANDN,EXIT
FREE    byte    _WORD,(@last+s)>>8,@last+s,_BYTE,$80,PLUS,_BYTE,$3F,_ANDN,EXIT

' correct the count byte in each entry in the dictionary as the precompiled version leaves a dummy count (too mind-numbing)
FIXDICT byte    _WORD,(@dictionary+s)>>8,@dictionary+s
fdlp    byte    DUP,INC,XCALL,xSTRLEN,OVER,CSTORE                       ' calc length and set count byte
        byte    DUP,CFETCH,_4,PLUS,PLUS,DUP,CFETCH,ZEQ,_UNTIL,@fd01-@fdlp
fd01    byte    DROP,EXIT

' COLD  Force factory defaults
COLDST  byte    XCALL,xPRTSTR," Cold start - no user code - setting defaults ",$0D,$0A,0
        byte    XCALL,xFREE,DUP,REG,here,WSTORE,REG,here-2,WSTORE               ' free memory
        byte    _WORD,(@rxbuffers+s)>>8,@rxbuffers+s,REG,rxptr,WSTORE           ' setup saved receive buffer address
        byte    _WORD,(@dictionary+s)>>8,@dictionary+s
        byte    DUP,REG,corenames,WSTORE,DEC
        byte    DUP,REG,names,WSTORE,REG,names-2,WSTORE                         ' Reset dictionary pointer
        byte    _0,REG,autovec,WSTORE,_0,REG,keypoll,WSTORE                     ' disable autorun and ext keypoll
        byte    XCALL,xFIXDICT
        byte    _WORD,(@xLAST+s)>>8,@xLAST+s                                    ' ( lastadr )
        byte    _WORD,(@xEND+S)>>8,@xEND+s                                      ' ( lastadr endadr)
        byte    OVER,MINUS,_0,XCALL,xFILL                                       ' clear all user XCALLs
        byte    XCALL,xXCALLS,INC,INC,_WORD,(vecsize*4)>>8,00                   'clear YCALLs (interleaved with XCALLS)
        byte    BOUNDS,DO,_0,I,WSTORE,_4,PLOOP
        byte    REG,tasks,_BYTE,tasksz*8,_0,XCALL,xFILL                         ' initialize 8 task words

        byte    _WORD,$A5,$5A,REG,cold,WSTORE
        byte    EXIT

' Discard the current line
DISCARD
dslp    byte    XCALL,xKEY,ZEQ,_UNTIL,@ds01-@dslp
ds01    byte    _BYTE,100,XCALL,xms,XCALL,xKEY,ZEQ,_UNTIL,@ds02-@dslp
ds02    byte    EXIT

' TASK ( cog -- addr ) Return with address of task control register in "tasks"
TASK    byte    _3,_SHL,REG,tasks,PLUS,EXIT
{
'RUN ( pfa cog -- )
RUN     byte    XCALL,xTASK,WSTORE,EXIT
}
        org             ' align the label - needs to be passed in 14-bit PAR register
' idle loop for other Tachyon cogs
IDLE_reset
        byte    pInitRP                                                         ' cog reset entry ???????????
IDLE    byte    XOP,pInitRP
id02    byte    XCALL,xInitStack
        byte    _1,XOP,pCOGID,XCALL,xTASK,INC,INC,CSTORE                        ' task+2 = 1 to indicate Tachyon running
idlp    byte    _8,XCALL,xms                                                    ' do nothing for a bit - saves power
        byte    XOP,pCOGID,XCALL,xTASK,WFETCH                                   ' fetch cog's task variable
        byte    QDUP,_UNTIL,@id00-@idlp                                         ' until it is non-zero
id00    byte    DUP,_SHR8,_IF,01,ACALL                                          ' Execute but ignore if task address is only 8-bits
        byte    _0,XOP,pCOGID,XCALL,xTASK,WSTORE                                ' clear run address only if it has returned back to idle
        byte    _AGAIN,@id01-@IDLE
id01

{
: IDLE
        BEGIN !RP !SP COGID TASK 2+ C!
            BEGIN 8 ms COGID TASK W@! ?DUP UNTIL
          DUP 8>> IF ACALL THEN
          0 COGID TASK W!
        AGAIN
        ;
}





              { *** MAIN TERMINAL CONSOLE ***  }

        org     ' align the label for RESET
TERMINAL_reset
        byte    pInitRP                         ' Only reset from a cog enters here
' COGINIT ( code pars cog -- ret )
'  coginit(1,@TachyonRx, 0)                    ' Load serial receiver into cog 1
'        byte    _word,(@TachyonRx+s)>>8,@TachyonRx+s,_0,_1,XCALL,xCOGINIT
'  repeat 6                                              ' cogs 2..7 loaded with Tachyon and IDLE loop
'        cognew(@RESET, @IDLE_reset)
'        byte    _word,(@RESET+s)>>8,@RESET,_word,(@IDLE_reset+s)>>8,@IDLE_reset+8,_8,XCALL,xCOGINIT
TERMINAL
        byte    XOP,pInitRP                                                     ' normal entry
SETPLL  byte    _WORD,(@_setpll+s)>>8,@_setpll+s                                ' autoset crystal operation
        byte    XCALL,xLOADMOD,XOP,pRUNMOD
        byte    _BYTE,txd,MASK,OUTSET                                              ' make the transmit an output
        byte    XCALL,xInitStack                                                ' Init the internal stack and setup external stack space
        byte    _WORD,extstk>>8,extstk,XCALL,xSPSTORE
        byte    _WORD,00,50,XCALL,xms                                           ' a little startup delay (also wait for serial cog)
        byte    _WORD,rxsize>>8,rxsize,REG,rxsz,WSTORE                          ' Set the rx buffer size
        byte    _BYTE,echo,REG,flags,CSTORE                                     ' echo on
        byte    BL,REG,delim,CSTORE,XCALL,xDECIMAL                              ' default delimiter is a space character
        byte    _BYTE,$0D,XCALL,xEMIT,XCALL,xPRTVER                             ' Show VERSION with optional CLS (default CR)
'       byte    XCALL,xCMPSTRMOD                                                ' use fast string compare module
        byte    REG,cold,WFETCH,_WORD,$A5,$5A,EQ,ZEQ                            ' performing a check for a saved session
        byte    _IF,@warmst-@tm01                                               ' or not
tm01    byte    XCALL,xCOLDST                                                   ' defaults

warmst
        byte    XCALL,xLASTKEY,CFETCH,_1,EQ,_NOT,_IF,@termnew-@chkauto          ' ^A abort autostart with ^A
chkauto         byte    REG,autovec,WFETCH,QDUP,_IF,@termnew-@runauto           ' check for an AUTORUN
runauto byte    ACALL                                                           ' and execute it
'
'
CONSOLE
termnew byte    XOP,pInitRP                                                     ' init return stack in case (limited)
        byte    XCALL,xSCRUB
        byte    _BYTE,defining,REG,flags,XCALL,xCLR                             ' Stop compilation

        '
        ' ****************** PROMPT FOR NEW LINE ******************
        '
        ' Main console line loop - get a new line (word by word)
termcr  byte    REG,prompt,WFETCH,QDUP,_IF,01,ACALL                             ' execute user prompt code
        byte    XCALL,xHERE,REG,codes,WSTORE                                    ' reset temporary code compilation pointer

        '
        ' Main console loop - read a word and process
termlp
        byte    XCALL,xGETWORD                                                  ' Read a word from input stream etc

        byte    _4,REG,flags+1,XCALL,xCLR

        byte    CFETCH,ZEQ,_IF,@trm1-@trm2                                      ' ignore empty string
trm2    byte    REG,delim+1,CFETCH,_BYTE,$18,EQ,_NOT,_IF,@execinp-@trm3         ' ^X then repeat last line
trm3    byte    REG,delim+1,CFETCH,_BYTE,$0D,EQ,_NOT,_IF,@chkeol-@trm1          ' Otherwise process ENTER
        '
trm1    ' Preprocess prefixed numbers #$%
        byte    REG,wordbuf,CFETCH,_BYTE,"#",_BYTE,"%",XCALL,xWITHIN            ' Numeric prefixes?
        byte    REG,wordbuf-1,CFETCH,_2,GT,_AND                                 ' and more than 2 characters? (inc term)
        byte    REG,wordbuf-1,DUP,CFETCH,PLUS,CFETCH                            ' and last char is a digit or hex digit?
        byte    DUP,_BYTE,"0",_BYTE,"9",XCALL,xWITHIN                           ' decimal digit?
        byte    SWAP,_BYTE,"A",_BYTE,"F",XCALL,xWITHIN,_OR,_AND                 ' hex digit?
        byte    ZEQ,_IF,@tryanum-@trm4                                          ' good, process this as a number now @tryanum

        ' Search the dicitonary for a match (as a counted string)
trm4    byte    REG,wordbuf,DEC,XCALL,xSEARCH                                   ' try and find that word in the dictionary(s)
        byte    QDUP,_IF,@_notfound-@foundword                                  ' found it

foundword                                                                       ' found the word in the dictionary - compile or execute?
        byte    XCALL,xNFABFA,DEC                                               ' point to attribute byte
        byte    _BYTE,im,OVER,XCALL,xSETQ                                       ' is the immediate bit set?
        byte    _BYTE,comp,REG,flags,XCALL,xSETQ,ZEQ,_AND                       ' and comp flag off (not forced to compile with [COMPILE])
        byte    _IF,@compword-@immed            '
immed   '!!! FIX CALL16 MODE
        byte    DUP,CFETCH,_3,_AND,_3,EQ,_IF,@imm02-@imm01
imm01   byte    INC,CFETCHINC,_SHL8,SWAP,CFETCH,PLUS,ACALL
        byte    _ELSE,@chkeol-@imm02
imm02   byte    INC,CFETCHINC,SWAP,CFETCH,XCALL,xEXECUTE                        ' Fetch and EXECUTE code immediately
        byte    _ELSE,@chkeol-@compword
compword
        byte    XCALL,xBCOMPILE                                                 ' or else COMPILE the bytecode(s) for this word
        byte    _BYTE,comp,REG,flags,XCALL,xCLR                                 ' reset any forced compile mode via [COMPILE]

        '     ****** END OF LINE CHECK ******
        '
chkeol  byte    REG,delim+1,CFETCH,_BYTE,$0D,EQ                                 ' Was this the end of line?
        byte    DUP,_IF,@eol01-@eol00
eol00   byte    REG,accept,WFETCH,ZEQ,_IF,02,XCALL,xSPACE                       ' Yes, put a space between any user input and response
        byte    _BYTE,linenums,REG,flags,XCALL,xSETQ,_IF,@eol01-@prtline
prtline byte    _BYTE,$0D,XCALL,xEMIT                                           ' List line number if enabled
        byte    REG,linenum,WFETCH,XCALL,xPRTDEC,XCALL,xSPACE
        byte    _1,REG,linenum,WPLUSST
eol01   byte    DUP,_BYTE,defining,REG,flags,XCALL,xSETQ,_AND                   ' and are we in a definition or interactive?
        byte    _IF,02,XCALL,xCR                                                ' If not interactive then CRLF (no other response)
        byte    _BYTE,defining,REG,flags,XCALL,xSETQ,ZEQ,_AND                   ' do not execute if still defining
        byte    _UNTIL,@execs-@termlp                                           ' wait until CR to execute compiled codes

        '     ****** EXECUTE CODE from user input ******
        '
execs   byte    _BYTE,EXIT,XCALL,xBCOMP                                         ' done - append an EXIT (minimum action on empty lines)
execinp byte    XCALL,xHERE,ACALL                                               ' execute from beginning
        byte    REG,accept,WFETCH                                               ' if accept vector is <>0
        byte    QDUP,_IF,03,ACALL                                               ' then execute it
        byte    _ELSE,02,XCALL,xOK                                              ' else echo the "ok"
        byte    _AGAIN,@_notfound-@termcr

_notfound       ' NOT FOUND YET - before trying to convert to a number check encoding for ASCII literals (^ and ")
        ' Attempt to process this word as a number
tryanum byte    REG,wordbuf,XCALL,xNUMBER,_IF,@unknown-@compnum
compnum byte    XCALL,xLITCOMP
        byte    _AGAIN,@unknown-@chkeol         ' is it a number? ( value digits )

' Unknown word or number - try converting case
UNKNOWN
        byte    REG,flags+1,CFETCH,_4,_AND,ZEQ          ' proceed with case conversion if this is the first time for this word
        byte    _IF,10,_4,REG,flags+1,CPLUSST,REG,wordbuf,XCALL,xTOUPPER,_AGAIN,@un03-@trm4


un03    byte    REG,unum,WFETCH,QDUP,_IF,03,ACALL,_AGAIN,@un01-@chkeol  ' UNKNOWN - try unum vector if set
un01    byte    XCALL,xNOTFOUND
un02    byte    _AGAIN,@NOTFOUND-@termlp

' Failed all searches and conversions
NOTFOUND
        byte    _BYTE,defining,REG,flags,CFETCH,_AND            ' interactive or in the middle of a definition?
        byte    _IF,@nfint-@nfdef
nfdef   byte    XCALL,xPRTSTR,9,9," error in ",0
        byte    REG,names,WFETCH,INC,XCALL,xPSTR
        byte    XCALL,xPRTSTR," at ",0
        byte    REG,wordbuf,XCALL,xPSTR         ' Spit out offending word
        byte    XCALL,xSPACE
        byte    XCALL,xKEY,DUP,_BYTE,$0D,EQ,ZEQ
        byte    _IF,04,XCALL,xEMIT,_AGAIN,13
        byte    DROP,_ELSE,@ERROR-@nfint
nfint   byte    XCALL,xPRTSTR,"??? ",0,EXIT

ERROR   byte    _1,REG,errors,WPLUSST           ' count errors
        byte    XCALL,xPRTSTR," *error*",7,$0D,$0A,0
        byte    _BYTE,$0A,XOP,pEMIT             ' force a LF into the serial console
        byte    XCALL,xDISCARD,XCALL,xInitStack,XCALL,xCONSOLE          ' jumps to console (no return)





' : W	CR names W@ BEGIN SPACE DUP C@ OVER 1+ C@ OR WHILE DUP C@ ?DUP IF OVER 1+ SWAP ADO I C@ EMIT LOOP C@++ + 3 + ELSE 1+ THEN REPEAT 2DROP ;
' list dictionary words (basic kernel version)
WORDS   byte  XCALL,xCR,REG,names,WFETCH
wdlp    byte  XCALL,xSPACE,DUP,CFETCH,OVER,INC,CFETCH,_OR,_IF,@wd05-@wd01
wd01    byte  DUP,CFETCH,QDUP,_IF,@wd03-@wd02
wd02    byte  OVER,INC,SWAP,BOUNDS,DO,I,CFETCH,XCALL,xEMIT,LOOP,CFETCHINC,PLUS,_3,PLUS,_ELSE,@wd04-@wd03
wd03    byte  INC
wd04    byte  _AGAIN,@wd05-@wdlp
wd05    byte  DROP2,EXIT





' VER ( -- verptr )
GETVER  byte    _WORD,(@version+s)>>8,@version+s,EXIT

' .VER
PRTVER  byte    XCALL,xPRTSTR   ' ,$0D,$0A
        byte    "  Propeller .:.:--TACHYON--:.:. Forth V",0
        byte    XCALL,xGETVER,_BYTE,6,PLUS,_8,BOUNDS,DO,I,CFETCH,XCALL,xEMIT,LOOP,BL,XCALL,xEMIT
        byte    XCALL,xGETVER,DUP,FETCH,XCALL,xPRTDEC
        byte    _BYTE,".",XCALL,xEMIT,_4,PLUS,WFETCH,XCALL,xPRTDEC
        byte    XCALL,xCR,EXIT

{
' @VGA returns the address to the VGA driver image to be used as the VGA buffer
'VGA     byte    _WORD,(@vgarun+s)>>8,@vgarun+s,EXIT
VGA     byte    _WORD,_VGA>>8,_VGA,EXIT
}
' rxpars ( index -- )
RXPARS  byte  _SHL1,_SHL1,_WORD,(@_rxpars+s)>>8,@_rxpars+s,PLUS,EXIT


' ----- Leave as last code routine in kernel for easy identification of boundaries etc.

{HELP TACHYON - used to verify that source code is intended for Tachyon and also to reset load stats }
_TACHYON        byte    XCALL,xPRTVER
        byte    _0,REG,keypoll,WSTORE                           ' disable background keypoll during load
        byte    _0,REG,errors,WSTORE                            ' reset error count
'       byte    _WORD,$09,$80,REG,rxsz,WSTORE                           ' Use the buffers
        byte    XCALL,xHERE,REG,fromhere,WSTORE                         ' remember code position for reporting
        byte    _0,REG,linenum,WSTORE,_BYTE,linenums,REG,flags,XCALL,xSET       ' reset line# and set linenum mode
        byte    REG,names,WFETCH,REG,names-2,WSTORE                             ' backup dictionary pointer
        byte    XOP,pLAP,EXIT                                   ' time the load

last




aln2    byte    0[$80-(@aln2+s-((@aln2+s)&$FF80))]


{
***************************************
************* METACOMPILED CODE & HEADER MEMORY *************
***************************************

After this point all other code is compiled by the kernel itself on the target
}







'vgarun
'{
' VGA
''***************************************
''*  VGA Driver v1.1                    *
''*  Author: Chip Gracey                *
''*  Copyright (c) 2006 Parallax, Inc.  *
''*  See end of file for terms of use.  *
''***************************************

CON

  paramcount    = 21
  colortable    = $180  'start of colortable inside cog

DAT
              org
roms          byte "ROMS"
              long @romend-@roms
              byte "ROMS"                      ' verification sig.

                        org
              byte ".ROM"                       ' ROM signature
              word @vgaend-@vgarun              ' size
              byte "VGA32x15  "                ' name 9 chars
              '     1234567890

DAT { *** VGA DRIVER *** }

'********************************
'* Assembly language VGA driver *
'********************************

                        org
'
'
' Entry
'
vgarun                  mov     taskptr,#vgatasks        'reset tasks

                        mov     xx,#8                    'perform task sections initially
:init                   jmpret  taskret,taskptr
                        djnz    xx,#:init
'
'
' Superfield
'
superfield              mov     hv,hvbase               'set hv
                        mov     interlace,#0            'reset interlace
                        test    _mode,#%0100    wz      'get interlace into nz
'
'
' Field
'
field                   wrlong  visible,par             'set status to visible

                        tjz     vb,#:nobl               'do any visible back porch lines
                        mov     xx,vb
                        movd    bcolor,#colortable
                        call    #blank_line
:nobl
                        mov     screen,_screen          'point to first tile (upper-leftmost)
                        mov     y,_vt                   'set vertical tiles
:line                   mov     vx,_vx                  'set vertical expand
:vert   if_nz           xor     interlace,#1            'interlace skip?
        if_nz           tjz     interlace,#:skip

                        tjz     hb,#:nobp               'do any visible back porch pixels
                        mov     vscl,hb
                        waitvid colortable,#0
:nobp
                        mov     xx,_ht                   'set horizontal tiles
                        mov     vscl,hx                 'set horizontal expand

''        bits 15..10: select the colorset* for the associated pixel tile
''        bits 9..0: select the pixelgroup** address %ppppppppppcccc00 (p=address, c=0..15)

:tile                   rdword  tile,screen             'read tile ($3A30)
                        add     tile,line               'set pointer bits into tile ($6.3A30)
                        rol     tile,#6                 'read tile pixels ($18E.8C00) 64 bytes/pixel
                        rdlong  pixels,tile             '(8 clocks between reads)
                        shr     tile,#10+6              'set tile colors ($18E)
                        movd    :color,tile
                        add     screen,#2               'point to next tile
:color                  waitvid colortable,pixels       'pass colors and pixels to video
                        djnz    xx,#:tile                'another tile?

                        sub     screen,hc2x             'repoint to first tile in same line

                        tjz     hf,#:nofp               'do any visible front porch pixels
                        mov     vscl,hf
                        waitvid colortable,#0
:nofp
                        mov     xx,#1                    'do hsync
                        call    #blank_hsync            '(x=0)

:skip                   djnz    vx,#:vert               'vertical expand?
                        ror     line,linerot            'set next line
                        add     line,lineadd    wc
                        rol     line,linerot
        if_nc           jmp     #:line
                        add     screen,hc2x             'point to first tile in next line
                        djnz    y,#:line        wc      'another tile line? (c=0)

                        tjz     vf,#:nofl               'do any visible front porch lines
                        mov     xx,vf
                        movd    bcolor,#colortable
                        call    #blank_line
:nofl
        if_nz           xor     interlace,#1    wc,wz   'get interlace and field1 into nz (c=0/?)

        if_z            wrlong  invisible,par           'unless interlace and field1, set status to invisible

                        mov     taskptr,#vgatasks          'reset tasks

                        addx    xx,_vf           wc      'do invisible front porch lines (x=0 before, c=0 after)
                        call    #blank_line

                        mov     xx,_vs                   'do vsync lines
                        call    #blank_vsync

                        mov     xx,_vb                   'do invisible back porch lines, except last
                        call    #blank_vsync

        if_nz           jmp     #field                  'if interlace and field1, display field2
                        jmp     #superfield             'else, new superfield
'
'
' Blank line(s)
'
blank_vsync             cmp     interlace,#2    wc      'vsync (c=1)

blank_line              mov     vscl,h1                 'blank line or vsync-interlace?
        if_nc           add     vscl,h2
        if_c_and_nz     xor     hv,#%01
        if_c            waitvid hv,#0
        if_c            mov     vscl,h2                 'blank line or vsync-normal?
        if_c_and_z      xor     hv,#%01
bcolor                  waitvid hv,#0

        if_nc           jmpret  taskret,taskptr         'call task section (z undisturbed)

blank_hsync             mov     vscl,_hf                'hsync, do invisible front porch pixels
                        waitvid hv,#0

                        mov     vscl,_hs                'do invisble sync pixels
                        xor     hv,#%10
                        waitvid hv,#0

                        mov     vscl,_hb                'do invisible back porch pixels
                        xor     hv,#%10
                        waitvid hv,#0

                        djnz    xx,#blank_line   wc      '(c=0)

                        movd    bcolor,#hv
blank_hsync_ret
blank_line_ret
blank_vsync_ret         ret
'
'
' Tasks - performed in sections during invisible back porch lines
'
 vgatasks                   mov     t1,par                  'load parameters
                        movd    :par,#_enable           '(skip _status)
                        mov     t2,#paramcount - 1
:load                   add     t1,#4
:par                    rdlong  0,t1
                        add     :par,d0
                        djnz    t2,#:load               '+164

                        mov     t1,#2                   'set video pins and directions
                        shl     t1,_pins                '(if video disabled, pins will drive low)
                        sub     t1,#1
                        test    _pins,#$20      wc
                        and     _pins,#$38
                        shr     t1,_pins
                        movs    vcfg,t1
                        shl     t1,_pins
                        shr     _pins,#3
                        movd    vcfg,_pins
        if_nc           mov     dira,t1
        if_nc           mov     dirb,#0
        if_c            mov     dira,#0
        if_c            mov     dirb,t1                 '+14

                        tjz     _enable,#disabled       '+2, disabled?

                        jmpret  taskptr,taskret         '+1=181, break and return later

                        rdlong  t1,#0                   'make sure CLKFREQ => 16MHz
                        shr     t1,#1
                        cmp     t1,m8           wc
        if_c            jmp     #disabled               '+8

                        min     _rate,pllmin            'limit _rate to pll range
                        max     _rate,pllmax            '+2

                        mov     t1,#%00001_011          'set ctra configuration
:max                    cmp     m8,_rate        wc      'adjust rate to be within 4MHz-8MHz
        if_c            shr     _rate,#1                '(vco will be within 64MHz-128MHz)
        if_c            add     t1,#%00000_001
        if_c            jmp     #:max
:min                    cmp     _rate,m4        wc
        if_c            shl     _rate,#1
        if_c            sub     xx,#%00000_001
        if_c            jmp     #:min
                        movi    ctra,t1                 '+22

                        rdlong  t1,#0                   'divide _rate/CLKFREQ and set frqa
                        mov     hvbase,#32+1
:div                    cmpsub  _rate,t1        wc
                        rcl     t2,#1
                        shl     _rate,#1
                        djnz    hvbase,#:div            '(hvbase=0)
                        mov     frqa,t2                 '+136

                        test    _mode,#%0001    wc      'make hvbase
                        muxnc   hvbase,vmask
                        test    _mode,#%0010    wc
                        muxnc   hvbase,hmask            '+4

                        jmpret  taskptr,taskret         '+1=173, break and return later

                        mov     hx,_hx                  'compute horizontal metrics
                        shl     hx,#8
                        or      hx,_hx
                        shl     hx,#4

                        mov     hc2x,_ht
                        shl     hc2x,#1

                        mov     h1,_hd
                        neg     h2,_hf
                        sub     h2,_hs
                        sub     h2,_hb
                        sub     h1,h2
                        shr     h1,#1           wc
                        addx    h2,h1

                        mov     t1,_ht
                        mov     t2,_hx
                        call    #multiply
                        mov     hf,_hd
                        sub     hf,t1
                        shr     hf,#1           wc
                        mov     hb,_ho
                        addx    hb,hf
                        sub     hf,_ho                  '+59

                        mov     t1,_vt                  'compute vertical metrics
                        mov     t2,_vx
                        call    #multiply
                        test    _mode,#%1000    wc      'consider tile size
                        muxc    linerot,#1
                        mov     lineadd,lineinc
        if_c            shr     lineadd,#1
        if_c            shl     t1,#1
                        test    _mode,#%0100    wc      'consider interlace
        if_c            shr     t1,#1
                        mov     vf,_vd
                        sub     vf,t1
                        shr     vf,#1           wc
                        neg     vb,_vo
                        addx    vb,vf
                        add     vf,_vo                  '+53

                        movi    vcfg,#%01100_000        '+1, set video configuration

:colors                 jmpret  taskptr,taskret         '+1=114/160, break and return later

                        mov     t1,#13                  'load next 13 colors into colortable
:loop                   mov     t2,:color               '5 times = 65 (all 64 colors loaded)
                        shr     t2,#9-2
                        and     t2,#$FC
                        add     t2,_colors
                        rdlong  t2,t2
                        and     t2,colormask
                        or      t2,hvbase
:color                  mov     colortable,t2
                        add     :color,d0
                        andn    :color,d6
                        djnz    t1,#:loop               '+158

                        jmp     #:colors                '+1, keep loading colors
'
'
' Multiply t1 * t2 * 16 (t1, t2 = bytes)
'
multiply                shl     t2,#8+4-1

                        mov     tile,#8
:loop                   shr     t1,#1           wc
        if_c            add     t1,t2
                        djnz    tile,#:loop

multiply_ret            ret                             '+37
'
'
' Disabled - reset status, nap ~4ms, try again
'
disabled                mov     ctra,#0                 'reset ctra
                        mov     vcfg,#0                 'reset video

                        wrlong  outa,par                'set status to disabled

                        rdlong  t1,#0                   'get CLKFREQ
                        shr     t1,#8                   'nap for ~4ms
                        min     t1,#3
                        add     t1,cnt
                        waitcnt t1,#0

                        jmp     #vgarun                  'reload parameters
'
'
' Initialized data
'
pllmin                  long    500_000                 'pll lowest output frequency
pllmax                  long    128_000_000             'pll highest output frequency
m8                      long    8_000_000               '*16 = 128MHz (pll vco max)
m4                      long    4_000_000               '*16 = 64MHz (pll vco min)
d0                      long    1 << 9 << 0
d6                      long    1 << 9 << 6
invisible               long    1
visible                 long    2
line                    long    $00060000
lineinc                 long    $10000000
linerot                 long    0
vmask                   long    $01010101
hmask                   long    $02020202
colormask               long    $FCFCFCFC
'
'
' Uninitialized data
'
taskptr                 res     1                       'tasks
taskret                 res     1
t1                      res     1
t2                      res     1

xx                      res     1                       'display
y                       res     1
hf                      res     1
hb                      res     1
vf                      res     1
vb                      res     1
hx                      res     1
vx                      res     1
hc2x                    res     1
screen                  res     1
tile                    res     1
pixels                  res     1
lineadd                 res     1
interlace               res     1
hv                      res     1
hvbase                  res     1
h1                      res     1
h2                      res     1
'
'
' Parameter buffer
'
_enable                 res     1       '0/non-0        read-only
_pins                   res     1       '%pppttt        read-only
_mode                   res     1       '%tihv          read-only
_screen                 res     1       '@word          read-only
_colors                 res     1       '@long          read-only
_ht                     res     1       '1+             read-only
_vt                     res     1       '1+             read-only
_hx                     res     1       '1+             read-only
_vx                     res     1       '1+             read-only
_ho                     res     1       '0+-            read-only
_vo                     res     1       '0+-            read-only
_hd                     res     1       '1+             read-only
_hf                     res     1       '1+             read-only
_hs                     res     1       '1+             read-only
_hb                     res     1       '1+             read-only
_vd                     res     1       '1+             read-only
_vf                     res     1       '1+             read-only
_vs                     res     1       '1+             read-only
_vb                     res     1       '2+             read-only
_rate                   res     1       '500_000+       read-only

vgaend
'                       long 0[30]      ' pad out to allow this image to be used as a screen buffer
''                        fit     colortable              'fit underneath colortable ($180-$1BF)
'}






DAT

                        org
              byte ".ROM"                       ' ROM signature
              word @UARTEnd-@UART               ' size
              byte "HSSERIAL  "                     ' name
              '     1234567890

{ *** SERIAL RECEIVE *** }

'**************************************** SERIAL RECEIVE ******************************************

{ This is a dedicated serial receive routine that runs in it's own cog }

                        	org

UART		        mov	urxwr,#0	        ' init write index
 			wrword	urxwr,uhubrxwr 	' clear rxrd in hub
 			wrword	urxwr,uhubrxrd 	' make rxwr = rxrd
			mov	ustticks,urxticks	' calculate start bit timing
 			shr	ustticks,#1	' half a bit time less
 			sub	ustticks,#4	' compensate timing - important at high speeds
ureceive		mov	urxcnt,ustticks	' Adjusted bit timing for start bit
 			waitpne	urxpin,urxpin	' wait for a low = start bit
 			add	urxcnt,cnt       ' uses special start bit timing
 			waitcnt	urxcnt,urxticks
 			test	urxpin,ina       wz      	' sample middle of start bit
urxcond2	if_nz	jmp	#ureceive                	' restart if false start otherwise bit time from center
 			waitcnt	urxcnt,urxticks	' wait until middle of first data bit
 			test	urxpin,ina wc	' sample bit 0
 			muxc	urxdata,#01	' and assemble rxdata
 			waitcnt	urxcnt,urxticks
 			test	urxpin,ina wc	' sample bit 1
 			muxc	urxdata,#02
 			waitcnt	urxcnt,urxticks
 			test	urxpin,ina wc	' sample bit 2
 			muxc	urxdata,#04
 			waitcnt	urxcnt,urxticks
 			test	urxpin,ina wc	' sample bit 3
 			muxc	urxdata,#08
 			waitcnt	urxcnt,urxticks
 			test	urxpin,ina wc	' sample bit 4
 			muxc	urxdata,#$10
			waitcnt	urxcnt,urxticks
 			test	urxpin,ina wc	' sample bit 5
 			muxc	urxdata,#$20
 			mov	uX1,urxbuf	' squeeze in some overheads, calc write pointer
 			add	uX1,urxwr	        ' X points to buffer location to store
 			waitcnt	urxcnt,urxticks
 			test	urxpin,ina wc	' sample bit 6
 			muxc	urxdata,#$40
 			add	urxwr,#1	        ' update write index
 			and	urxwr,uwrapmask
 			waitcnt	urxcnt,urxticks
 			test	urxpin,ina wc	' sample bit 7
 			muxc	urxdata,#$80
 			wrbyte	urxdata,X1	' save data in buffer - could take 287.5ns worst case
ustopins		waitcnt	urxcnt,urxticks	' check stop bit
 			test	urxpin,ina wc	' sample stop bit
		if_nc	jmp	#ureceive	' framing error discard
		if_c	wrword	urxwr,uhubrxwr	' update hub index for code reading the buffer if all good
 			jmp	#ureceive


urxpin			long	0
utxpin                  long    0
uhubrxrd		long	_buffers+$7BC
uhubrxwr		long	_buffers+$7BE
urxbuf			long	_buffers+$7C0
uwrapmask		long	$3F                     ' default 64 bytes
urxticks		long	0
ustticks		long	0
uspticks		long	0
urxcnt			long	0
urxdata			long	0               	'assembled character
uX1			long	0
urxwr			long	0	'cog receive buffer write index - copied to hub ram

uartend







CON  PAL = 985248.0, NTSC = 1022727.0, MAXF = 1031000.0, TRIANGLE = 16, SAW = 32, SQUARE = 64, NOISE = 128

  C64_CLOCK_FREQ   = PAL
  '                                  ___
  RESONANCE_OFFSET = 6'                 │
  RESONANCE_FACTOR = 5'                 │
  CUTOFF_LIMIT     = 1100'              │
  LP_MAX_CUTOFF    = 11'                │ Don't alter these constants unless you know what you are doing!
  BP_MAX_CUTOFF    = 10'                │
  FILTER_OFFSET    = 12'                │
  START_LOG_LEVEL  = $5d5d5d5d'         │
  DECAY_DIVIDE_REF = $6C6C6C6C'         │
  ENV_CAL_FACTOR   = 545014038.181330'  │ ENV_CAL_FACTOR = (MaxUint32  / SIDcogSampleFreq) / (1 / SidADSR_1secRomValue)
  NOISE_ADD        = %1010_1010_101<<23'│ ENV_CAL_FACTOR = (4294967295 / 30789           ) / (1 / 3907                ) = 545014038,181330
  NOISE_TAP        = %100001 << 8'   ___│


DAT

                 org
              byte ".ROM"                       ' ROM signature
              word @SIDEnd-@SIDEMU              ' size
              byte "SIDEMU    "                 ' name
              '     1234567890

               org 0
'
'                Assembly SID emulator
'
SIDEMU        mov      dira, sr1
              mov      ctra, arg1
              mov      ctrb, arg2
              mov      waitCounter, cnt
              add      waitCounter, sampleRate

'
' Read all SID-registers from hub memory and convert
' them to more convenient representations.
'
getRegisters  mov       tempValue, par                     ' Read in first long ( 16bit frequency / 16bit pulse-width )
              rdlong    frequency1, tempValue
              mov       pulseWidth1, frequency1
              shl       pulseWidth1, #4                    ' Shift in "12 bit" pulse width value( make it 32 bits )
              andn      pulseWidth1, mask20bit
              and       frequency1, mask16bit              ' Mask out 16 bit frequency value
              shl       frequency1, #13
'-----------------------------------------------------------
              add       tempValue, #4                      ' Read in next long ( Control register / ADSR )
              rdlong    selectedWaveform1, tempValue
              mov       controlRegister1, selectedWaveform1
'-----------------------------------------------------------
              mov       arg1, selectedWaveform1            '|
              shr       arg1, #8                           '|
              call      #getADSR                           '|
              mov       decay1, sr1                         '|
              call      #getADSR                           '|
              mov       attack1, sr1                        '|  Convert 4bit ADSR "presets" to their corresponding
              call      #getADSR                           '|  32bit values using attack/decay tables.
              mov       release1, sr1                       '|
              mov       sustain1, arg1                     '|
              ror       sustain1, #4                       '|
              or        sustain1, arg1                     '|
              ror       sustain1, #4                       '|
'-----------------------------------------------------------
              shr       selectedWaveform1, #4              '   Mask out waveform selection
              and       selectedWaveform1, #15
'-----------------------------------------------------------
              test      controlRegister1, #1            wc
              cmp       envelopeState1, #2              wz
 if_z_and_c   mov       envelopeState1, #0
 if_nz_and_nc mov       envelopeState1, #2

'───────────────────────────────────────────────────────────
'                        Channel 2
'───────────────────────────────────────────────────────────
              add       tempValue, #4                      ' Read in first long ( 16bit frequency / 16bit pulse-width )
              rdlong    frequency2, tempValue
              mov       pulseWidth2, frequency2
              shl       pulseWidth2, #4                    ' Shift in "12 bit" pulse width value( make it 32 bits )
              andn      pulseWidth2, mask20bit
              and       frequency2, mask16bit              ' Mask out 16 bit frequency value
              shl       frequency2, #13
'-----------------------------------------------------------
              add       tempValue, #4                      ' Read in next long ( Control register / ADSR )
              rdlong    selectedWaveform2, tempValue
              mov       controlRegister2,  selectedWaveform2
'-----------------------------------------------------------
              mov       arg1, selectedWaveform2            '|
              shr       arg1, #8                           '|
              call      #getADSR                           '|
              mov       decay2, sr1                         '|
              call      #getADSR                           '|
              mov       attack2, sr1                        '|  Convert 4bit ADSR "presets" to their corresponding
              call      #getADSR                           '|  32bit values using attack/decay tables.
              mov       release2, sr1                       '|
              mov       sustain2, arg1                     '|
              ror       sustain2, #4                       '|
              or        sustain2, arg1                     '|
              ror       sustain2, #4                       '|
'-----------------------------------------------------------
              shr       selectedWaveform2, #4              '   Mask out waveform selection
              and       selectedWaveform2, #15
'-----------------------------------------------------------
              test      controlRegister2, #1            wc
              cmp       envelopeState2, #2              wz
 if_z_and_c   mov       envelopeState2, #0
 if_nz_and_nc mov       envelopeState2, #2

'───────────────────────────────────────────────────────────
'                        Channel 3
'───────────────────────────────────────────────────────────
              add       tempValue, #4                      ' Read in first long ( 16bit frequency / 16bit pulse-width )
              rdlong    frequency3, tempValue              '
              mov       pulseWidth3, frequency3
              shl       pulseWidth3, #4                    ' Shift in "12 bit" pulse width value( make it 32 bits )
              andn      pulseWidth3, mask20bit
              and       frequency3, mask16bit              ' Mask out 16 bit frequency value
              shl       frequency3, #13
'-----------------------------------------------------------
              add       tempValue, #4                      ' Read in next long ( Control register / ADSR )
              rdlong    selectedWaveform3, tempValue
              mov       controlRegister3,  selectedWaveform3
'-----------------------------------------------------------
              mov       arg1, selectedWaveform3            '|
              shr       arg1, #8                           '|
              call      #getADSR                           '|
              mov       decay3, sr1                         '|
              call      #getADSR                           '|
              mov       attack3, sr1                        '|  Convert 4bit ADSR "presets" to their corresponding
              call      #getADSR                           '|  32bit values using attack/decay tables.
              mov       release3, sr1                       '|
              mov       sustain3, arg1                     '|
              ror       sustain3, #4                       '|
              or        sustain3, arg1                     '|
              ror       sustain3, #4                       '|
'-----------------------------------------------------------
              shr       selectedWaveform3, #4              ' Mask out waveform selection
              and       selectedWaveform3, #15
'-----------------------------------------------------------
              test      controlRegister3, #1            wc
              cmp       envelopeState3, #2              wz
 if_z_and_c   mov       envelopeState3, #0
 if_nz_and_nc mov       envelopeState3, #2

'───────────────────────────────────────────────────────────
'                      Filter / Volume
'───────────────────────────────────────────────────────────
              add       tempValue, #4                      '|
              rdlong    filterControl, tempValue           '|
              mov       filterCutoff, filterControl        '|
'-----------------------------------------------------------
              shr       filterControl, #16                 '|  Filter control
'-----------------------------------------------------------
              shr       filterCutoff, #5                   '|
              andn      filterCutoff, #7                   '|
              mov       tempValue, filterControl           '|
              and       tempValue, #7                      '|  Filter cutoff frequency
              or        filterCutoff, tempValue            '|
              and       filterCutoff, mask11bit            '|
              add       filterCutoff, filterOffset         '|
'-----------------------------------------------------------
              mov       filterMode_Volume, filterControl   '|  Main volume and filter mode
              shr       filterMode_Volume, #8              '|
'-----------------------------------------------------------
              mov       filterResonance,filterControl      '|
              and       filterResonance,#$F0               '|  Filter Resonance level
              shr       filterResonance,#4                 '|

'
' Calculate sid samples channel 1-3 and store in out1-out3
'

'───────────────────────────────────────────────────────────
'    Increment phase accumulator 1-3 and handle syncing
'───────────────────────────────────────────────────────────
SID           add      phaseAccumulator1, frequency1    wc ' Add frequency value to phase accumulator 1
  if_nc       andn     controlRegister2, #2
              test     controlRegister2, #10            wz ' Sync oscilator 2 to oscillator 1 if sync = on
  if_nz       mov      phaseAccumulator2, #0               ' Or reset counter 2 when bit 4 of control register is 1
'-----------------------------------------------------------
              add      phaseAccumulator2, frequency2    wc
  if_nc       andn     controlRegister3, #2
              test     controlRegister3, #10            wz ' Sync oscilator 3 to oscillator 2 if sync = on
  if_nz       mov      phaseAccumulator3, #0               ' Or reset oscilator 3 when bit 4 of control register is 1
'-----------------------------------------------------------
              add      phaseAccumulator3, frequency3    wc
  if_nc       andn     controlRegister1, #2
              test     controlRegister1, #10            wz ' Sync oscilator 1 to oscillator 3 if sync = on
  if_nz       mov      phaseAccumulator1, #0               ' Or reset oscilator 1 when bit 4 of control register is 1

'───────────────────────────────────────────────────────────
'            Waveform shaping channel 1 -> arg1
'───────────────────────────────────────────────────────────
Saw1          cmp      selectedWaveform1, #2            wz
              mov      arg1, phaseAccumulator1
  if_z        jmp      #Envelope1
'-----------------------------------------------------------
Triangle1     cmp      selectedWaveform1, #1            wz, wc
  if_nz       jmp      #Square1
              shl      arg1, #1                         wc
  if_c        xor      arg1, mask32bit
              test     controlRegister1, #4             wz '|
  if_nz       test     phaseAccumulator3, val31bit      wz '| These 3 lines handles ring modulation
  if_nz       xor      arg1, mask32bit                     '|
              jmp      #Envelope1
'-----------------------------------------------------------
Square1       cmp      selectedWaveform1, #4            wz
  if_z        sub      pulseWidth1, phaseAccumulator1   wc ' C holds the pulse width modulated square wave
  if_z        muxc     arg1, mask32bit
  if_z        jmp      #Envelope1
'-----------------------------------------------------------
Noise1        cmp      selectedWaveform1, #8            wz
  if_nz       jmp      #Combined1
              and      arg1, mask28bit
              sub      arg1, frequency1                 wc
              movi     arg1, noiseValue1
              add      arg1, noiseAddValue
  if_nc       jmp      #Envelope1
              test     noiseValue1, noiseTap            wc
              rcr      noiseValue1, #1
              jmp      #Envelope1
'-----------------------------------------------------------
Combined1     test     selectedWaveform1, #8            wz
              sub      selectedWaveform1, #4
              mins     selectedWaveform1, #0
              shl      selectedWaveform1, #8
              mov      tempValue, phaseAccumulator1
              shr      tempValue, #24
              add      selectedWaveform1, tempValue
              add      selectedWaveform1, combTableAddr
  if_nc_and_z rdbyte   arg1, selectedWaveform1
  if_nc_and_z shl      arg1, #24
  if_c_or_nz  mov      arg1, val31bit
'───────────────────────────────────────────────────────────
'            Envelope shaping channel 1 -> arg2
'───────────────────────────────────────────────────────────
Envelope1     mov      tempValue, decayDivideRef
              shr      tempValue, decayDivide1
              cmp      envelopeLevel1, tempValue        wc
              tjnz     envelopeState1, #Env_Dec1        nr
'-----------------------------------------------------------
Env_At1 if_nc cmpsub   decayDivide1, #1
              add      envelopeLevel1, attack1          wc
  if_c        mov      envelopeLevel1, mask32bit
  if_c        mov      envelopeState1, #1
              jmp      #Amplitude1
'-----------------------------------------------------------
Env_Dec1 if_c add      decayDivide1, #1
              cmp      startLogLevel, envelopeLevel1    wc
              cmp      envelopeState1, #1               wz
  if_nz       jmp      #Rel1
  if_nc       shr      decay1, decayDivide1
              sub      envelopeLevel1, decay1
              min      envelopeLevel1, sustain1         wc
              jmp      #Amplitude1
'-----------------------------------------------------------
Rel1 if_nc    shr      release1, decayDivide1
              cmpsub   envelopeLevel1, release1

'───────────────────────────────────────────────────────────
'Calculate sample out1 = arg1 * arg2 (waveform * amplitude)
'───────────────────────────────────────────────────────────
Amplitude1    shr      arg1, #14
              sub      arg1, val17bit
              mov      arg2, envelopeLevel1
              shr      arg2, #24
              call     #smultiply
              mov      out1, sr1

'───────────────────────────────────────────────────────────
'            Waveform shaping channel 2 -> arg1
'───────────────────────────────────────────────────────────
Saw2          cmp      selectedWaveform2, #2            wz
              mov      arg1, phaseAccumulator2
  if_z        jmp      #Envelope2
'-----------------------------------------------------------
Triangle2     cmp      selectedWaveform2, #1            wz, wc
  if_nz       jmp      #Square2
              shl      arg1, #1                         wc
  if_c        xor      arg1, mask32bit
              test     controlRegister2, #4             wz '|
  if_nz       test     phaseAccumulator1, val31bit      wz '| These 3 lines handles ring modulation
  if_nz       xor      arg1, mask32bit                     '|
              jmp      #Envelope2
'-----------------------------------------------------------
Square2       cmp      selectedWaveform2, #4            wz
  if_z        sub      pulseWidth2, phaseAccumulator2   wc ' C holds the pulse width modulated square wave
  if_z        muxc     arg1, mask32bit
  if_z        jmp      #Envelope2
'-----------------------------------------------------------
Noise2        cmp      selectedWaveform2, #8            wz
  if_nz       jmp      #Combined2
              and      arg1, mask28bit
              sub      arg1, frequency2                 wc
              movi     arg1, noiseValue2
              add      arg1, noiseAddValue
  if_nc       jmp      #Envelope2
              test     noiseValue2, noiseTap            wc
              rcr      noiseValue2, #1
              jmp      #Envelope2
'-----------------------------------------------------------
Combined2     test     selectedWaveform2, #8            wz
              sub      selectedWaveform2, #4
              mins     selectedWaveform2, #0
              shl      selectedWaveform2, #8
              mov      tempValue, phaseAccumulator2
              shr      tempValue, #24
              add      selectedWaveform2, tempValue
              add      selectedWaveform2, combTableAddr
  if_nc_and_z rdbyte   arg1, selectedWaveform2
  if_nc_and_z shl      arg1, #24
  if_c_or_nz  mov      arg1, val31bit
'───────────────────────────────────────────────────────────
'            Envelope shaping channel 2 -> arg2
'───────────────────────────────────────────────────────────
Envelope2     mov      tempValue, decayDivideRef
              shr      tempValue, decayDivide2
              cmp      envelopeLevel2, tempValue        wc
              tjnz     envelopeState2, #Env_Dec2        nr
'-----------------------------------------------------------
Env_At2 if_nc cmpsub   decayDivide2, #1
              add      envelopeLevel2, attack2          wc
  if_c        mov      envelopeLevel2, mask32bit
  if_c        mov      envelopeState2, #1
              jmp      #Amplitude2
'-----------------------------------------------------------
Env_Dec2 if_c add      decayDivide2, #1
              cmp      startLogLevel,envelopeLevel2     wc
              cmp      envelopeState2, #1               wz
  if_nz       jmp      #Rel2
  if_nc       shr      decay2, decayDivide2
              sub      envelopeLevel2, decay2
              min      envelopeLevel2, sustain2         wc
              jmp      #Amplitude2
'-----------------------------------------------------------
Rel2 if_nc    shr      release2, decayDivide2
              cmpsub   envelopeLevel2, release2

'───────────────────────────────────────────────────────────
'Calculate sample out2 = arg1 * arg2 (waveform * amplitude)
'───────────────────────────────────────────────────────────
Amplitude2    shr      arg1, #14
              sub      arg1, val17bit
              mov      arg2, envelopeLevel2
              shr      arg2, #24
              call     #smultiply
              mov      out2, sr1

'───────────────────────────────────────────────────────────
'            Waveform shaping channel 3 -> arg1
'───────────────────────────────────────────────────────────
Saw3          cmp      selectedWaveform3, #2            wz
              mov      arg1, phaseAccumulator3
  if_z        jmp      #Envelope3
'-----------------------------------------------------------
Triangle3     cmp      selectedWaveform3, #1            wz, wc
  if_nz       jmp      #Square3
              shl      arg1, #1                         wc
  if_c        xor      arg1, mask32bit
              test     controlRegister3, #4             wz '|
  if_nz       test     phaseAccumulator2, val31bit      wz '| These 3 lines handles ring modulation
  if_nz       xor      arg1, mask32bit                     '|
              jmp      #Envelope3
'-----------------------------------------------------------
Square3       cmp      selectedWaveform3, #4            wz
  if_z        sub      pulseWidth3, phaseAccumulator3   wc ' C holds the pulse width modulated square wave
  if_z        muxc     arg1, mask32bit
  if_z        jmp      #Envelope3
'-----------------------------------------------------------
Noise3        cmp      selectedWaveform3, #8            wz
  if_nz       jmp      #Combined3
              and      arg1, mask28bit
              sub      arg1, frequency3                 wc
              movi     arg1, noiseValue3
              add      arg1, noiseAddValue
  if_nc       jmp      #Envelope3
              test     noiseValue3, noiseTap            wc
              rcr      noiseValue3, #1
              jmp      #Envelope3
'-----------------------------------------------------------
Combined3     test     selectedWaveform3, #8            wz
              sub      selectedWaveform3, #4
              mins     selectedWaveform3, #0
              shl      selectedWaveform3, #8
              mov      tempValue, phaseAccumulator3
              shr      tempValue, #24
              add      selectedWaveform3, tempValue
              add      selectedWaveform3, combTableAddr
  if_nc_and_z rdbyte   arg1, selectedWaveform3
  if_nc_and_z shl      arg1, #24
  if_c_or_nz  mov      arg1, val31bit

'───────────────────────────────────────────────────────────
'            Envelope shaping channel 3 -> arg2
'───────────────────────────────────────────────────────────
Envelope3     mov      tempValue, decayDivideRef
              shr      tempValue, decayDivide3
              cmp      envelopeLevel3, tempValue        wc
              tjnz     envelopeState3, #Env_Dec3        nr
'-----------------------------------------------------------
Env_At3 if_nc cmpsub   decayDivide3, #1
              add      envelopeLevel3, attack3          wc
  if_c        mov      envelopeLevel3, mask32bit
  if_c        mov      envelopeState3, #1
              jmp      #Amplitude3
'-----------------------------------------------------------
Env_Dec3 if_c add      decayDivide3, #1
              cmp      startLogLevel, envelopeLevel3    wc
              cmp      envelopeState3, #1               wz
  if_nz       jmp      #Rel3
  if_nc       shr      decay3, decayDivide3
              sub      envelopeLevel3, decay3
              min      envelopeLevel3, sustain3         wc
              jmp      #Amplitude3
'-----------------------------------------------------------
Rel3 if_nc    shr      release3, decayDivide3
              cmpsub   envelopeLevel3, release3

'───────────────────────────────────────────────────────────
'Calculate sample out3 = arg1 * arg2 (waveform * amplitude)
'───────────────────────────────────────────────────────────
Amplitude3    shr      arg1, #14
              sub      arg1, val17bit
              mov      arg2, envelopeLevel3
              shr      arg2, #24
              call     #smultiply
              mov      out3, sr1

'
'              Handle multi-mode filtering
'
filter        mov      ordinaryOutput, #0                  '|
              mov      highPassFilter, #0                  '|
              test     filterControl, #1                wc '|
  if_c        add      highPassFilter, out1                '|
  if_nc       add      ordinaryOutput, out1                '|
              test     filterControl, #2                wc '| Route channels trough the filter
  if_c        add      highPassFilter, out2                '| or bypass them
  if_nc       add      ordinaryOutput, out2                '|
              test     filterControl, #4                wc '|
  if_c        add      highPassFilter, out3                '|
  if_nc       add      ordinaryOutput, out3                '|
'-----------------------------------------------------------
              mov      arg2, filterResonance               '|
              add      arg2, #RESONANCE_OFFSET             '|
              mov      arg1, bandPassFilter                '|
              sar      arg1, #RESONANCE_FACTOR             '|
              call     #smultiply                           '| High pass filter
              sub      highPassFilter, bandPassFilter      '|
              add      highPassFilter, sr1                  '|
              sub      highPassFilter, lowPassFilter       '|
'-----------------------------------------------------------
              mov      arg1, highPassFilter                '|
              sar      arg1, #BP_MAX_CUTOFF                '|
              mov      arg2, filterCutoff                  '| Band pass filter
              max      arg2, maxCutoff                     '|
              call     #smultiply                           '|
              add      bandPassFilter, sr1                  '|
'-----------------------------------------------------------
              mov      arg1, bandPassFilter                '|
              sar      arg1, #LP_MAX_CUTOFF                '|
              mov      arg2, filterCutoff                  '| Low pass filter
              call     #smultiply                           '|
              add      lowPassFilter, sr1                   '|
'-----------------------------------------------------------
              mov      filterOutput, #0                    '|
              test     filterMode_Volume, #16           wc '|
  if_c        add      filterOutput, lowPassFilter         '|
              test     filterMode_Volume, #32           wc '| Enable/Disable
  if_c        add      filterOutput, bandPassFilter        '| Low/Band/High pass filtering
              test     filterMode_Volume, #64           wc '|
  if_c        add      filterOutput, highPassFilter        '|

'
'      Mix channels and update FRQA/FRQB PWM-values
'
mixer         mov      arg1, filterOutput
              add      arg1, ordinaryOutput
'-----------------------------------------------------------
              maxs     arg1, clipLevelHigh                 '|
              mins     arg1, clipLevelLow                  '|
              mov      arg2, filterMode_Volume             '| Main volume adjustment
              and      arg2, #15                           '|
              call     #smultiply                           '|
'-----------------------------------------------------------
              add      sr1, val31bit                        '  DC offset
              waitcnt  waitCounter, sampleRate             '  Wait until the right time to update
              mov      FRQA, sr1                            '| Update PWM values in FRQA/FRQB
              mov      FRQB, sr1                            '|
              mov      tempValue, par
              add      tempValue, #28
              wrlong   sr1, tempValue                       '| Write the sample to hub ram
              jmp      #getRegisters

'
'   Get ADSR value    sr1 = attackTable[arg1]
'
getADSR       movs      :indexed1, arg1
              andn      :indexed1, #$1F0
              add       :indexed1, #ADSRTable
              shr       arg1, #4
:indexed1     mov       sr1, 0
getADSR_ret   ret

'
'    Multiplication     sr1(I32) = arg1(I32) * arg2(I32)
'
smultiply      mov       sr1,   #0            'Clear 32-bit product
:multiLoop    shr       arg2, #1   wc, wz   'Half multiplyer and get LSB of it
  if_c        add       sr1,   arg1          'Add multiplicand to product on C
              shl       arg1, #1            'Double multiplicand
  if_nz       jmp       #:multiLoop         'Check nonzero multiplier to continue multiplication
smultiply_ret  ret

'
'    Variables, tables, masks and reference values
'

ADSRTable           long trunc(ENV_CAL_FACTOR * (1.0 / 9.0    )) '2   ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 32.0   )) '8   ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 63.0   )) '16  ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 95.0   )) '24  ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 149.0  )) '38  ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 220.0  )) '56  ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 267.0  )) '68  ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 313.0  )) '80  ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 392.0  )) '100 ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 977.0  )) '250 ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 1954.0 )) '500 ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 3126.0 )) '800 ms
                    long trunc(ENV_CAL_FACTOR * (1.0 / 3907.0 )) '1   s
                    long trunc(ENV_CAL_FACTOR * (1.0 / 11720.0)) '3   s
                    long trunc(ENV_CAL_FACTOR * (1.0 / 19532.0)) '5   s
                    long trunc(ENV_CAL_FACTOR * (1.0 / 31251.0)) '8   s

'Masks and reference values
startLogLevel       long START_LOG_LEVEL
sustainAdd          long $0f000000
mask32bit           long $ffffffff
mask31bit           long $7fffffff
mask28bit           long $fffffff
mask24bit           long $ffffff
mask20bit           long $fffff
mask16bit           long $ffff
mask11bit           long $7ff
val31bit            long $80000000
val28bit            long $10000000
val27bit            long $8000000
val17bit            long $20000
val16bit            long $10000
clipLevelHigh       long $8000000
clipLevelLow        long-$8000000
filterOffset        long FILTER_OFFSET
decayDivideRef      long DECAY_DIVIDE_REF
maxCutoff           long CUTOFF_LIMIT
sampleRate          long 0                 'clocks between samples ( ~31.250 khz )
combTableAddr       long 0

'Setup and subroutine parameters
arg1                long 1
arg2                long 1
sr1                  long 1

'Sid variables
noiseAddValue       long NOISE_ADD
noiseTap            long NOISE_TAP
noiseValue1         long $ffffff
noiseValue2         long $ffffff
noiseValue3         long $ffffff
decayDivide1        long 0
decayDivide2        long 0
decayDivide3        long 0
envelopeLevel1      res  1
envelopeLevel2      res  1
envelopeLevel3      res  1
controlRegister1    res  1
controlRegister2    res  1
controlRegister3    res  1
frequency1          res  1
frequency2          res  1
frequency3          res  1
phaseAccumulator1   res  1
phaseAccumulator2   res  1
phaseAccumulator3   res  1
pulseWidth1         res  1
pulseWidth2         res  1
pulseWidth3         res  1
selectedWaveform1   res  1
selectedWaveform2   res  1
selectedWaveform3   res  1
envelopeState1      res  1
envelopeState2      res  1
envelopeState3      res  1
attack1             res  1
attack2             res  1
attack3             res  1
decay1              res  1
decay2              res  1
decay3              res  1
sustain1            res  1
sustain2            res  1
sustain3            res  1
release1            res  1
release2            res  1
release3            res  1
out1                res  1
out2                res  1
out3                res  1
filterResonance     res  1
filterCutoff        res  1
highPassFilter      res  1
bandPassFilter      res  1
lowPassFilter       res  1
filterMode_Volume   res  1
filterControl       res  1
filterOutput        res  1
ordinaryOutput      res  1

'Working variables
waitCounter         res  1
tempValue           res  1

sidend
'################################################################################################



CON
  FF                            = 12                    ' form feed
'  CR                            = 13                    ' carriage return

  NOMODE                        = %000000
  INVERTRX                      = %000001
  INVERTTX                      = %000010
  OCTX                          = %000100
  NOECHO                        = %001000
  INVERTCTS                     = %010000
  INVERTRTS                     = %100000

  PINNOTUSED                    = -1                    'tx/tx/cts/rts pin is not used

  DEFAULTTHRESHOLD              = 0                     'rts buffer threshold

  BAUD1200                      = 1200
  BAUD2400                      = 2400
  BAUD4800                      = 4800
  BAUD9600                      = 9600
  BAUD19200                     = 19200
  BAUD38400                     = 38400
  BAUD57600                     = 57600
  BAUD115200                    = 115200

DAT

                 org
              byte ".ROM"                       ' ROM signature
              word @QUARTend-@quart               ' size
              byte "QUADUART  "                     ' name
              '     1234567890


'***********************************
'* Assembly language serial driver *
'***********************************
'
                        org
'
' Entry
'
'To maximize the speed of rx and tx processing, all the mode checks are no longer inline
'The initialization code checks the modes and modifies the rx/tx code for that mode
'e.g. the if condition for rx checking for a start bit will be inverted if mode INVERTRX
'is it, similar for other mode flags
'The code is also patched depending on whether a cts or rts pin are supplied. The normal
' routines support cts/rts processing. If the cts/rts mask is 0, then the code is patched
'to remove the addtional code. This means I/O modes and CTS/RTS handling adds no extra code
'in the rx/tx routines which not required.
'Similar with the co-routine variables. If a rx or tx pin is not configured the co-routine
'variable for the routine that handles that pin is modified so the routine is never called
'We start with port 3 and work down to ports because we will be updating the co-routine pointers
'and the order matters. e.g. we can update txcode3 and then update rxcode3 based on txcode3
'port 3
QUART
rxcode  if_never        mov     rxcode,#receive       'statically set these variables
txcode  if_never        mov     txcode,#transmit
rxcode1 if_never        mov     rxcode1,#receive1
txcode1 if_never        mov     txcode1,#transmit1
rxcode2 if_never        mov     rxcode2,#receive2
txcode2 if_never        mov     txcode2,#transmit2
rxcode3 if_never        mov     rxcode3,#receive3
txcode3 if_never        mov     txcode3,#transmit3

                        test rxtx_mode3,#OCTX wz 'init tx pin according to mode
                        test    rxtx_mode3,#INVERTTX wc
        if_z_ne_c       or      outa,qtxmask3
        if_z            or      dira,qtxmask3
                                                      'patch tx routine depending on invert and oc
                                                      'if invert change muxc to muxnc
                                                      'if oc change outa to dira
        if_z_eq_c       or      txout3,domuxnc        'patch muxc to muxnc
        if_nz           movd    txout3,#dira          'change destination from outa to dira
                                                      'patch rx wait for start bit depending on invert
                        test    rxtx_mode3,#INVERTRX wz 'wait for start bit on rx pin
        if_nz           xor     start3,doifc2ifnc     'if_c jmp to if_nc
                                                      'patch tx routine depending on whether cts is used
                                                      'and if it is inverted
                        or      ctsmask3,#0     wz    'cts pin? z not set if in use
        if_nz           test    rxtx_mode3,#INVERTCTS wc 'c set if inverted
        if_nz_and_nc    or      ctsi3,doif_z_or_nc    'if_nc jmp
        if_nz_and_c     or      ctsi3,doif_z_or_c     'if_c jmp
                                                      'if not cts remove the test by moving
                                                      'the transmit entry point down 1 instruction
                                                      'and moving the jmpret over the cts test
                                                      'and changing co-routine entry point
        if_z            mov     txcts3,transmit3      'copy the jmpret over the cts test
        if_z            movs    ctsi3,#txcts3         'patch the jmps to transmit to txcts0
        if_z            add     txcode3,#1            'change co-routine entry to skip first jmpret
                                                      'patch rx routine depending on whether rts is used
                                                      'and if it is inverted
                        or      rtsmask3,#0     wz
        if_nz           test    rxtx_mode3,#INVERTRTS wc
        if_nz_and_nc    or      rts3,domuxnc          'patch muxc to muxnc
        if_z            mov     norts3,rec3i          'patch rts code to a jmp #receive3
        if_z            movs    start3,#receive3      'skip all rts processing
                                                      'patch all of tx routine out if not used
                        or      qtxmask3,#0      wz    'by changing the co-routine variable
'        if_z            mov     txcode3,#receive0
                                                      'patch all of rx routine out if not used
                        or      rxmask3,#0      wz    'by changing the co-routine variable
'        if_z            mov     rxcode3,txcode3       'use variable in case it has been changed
'port 2
                        test    rxtx_mode2,#OCTX wz   'init tx pin according to mode
                        test    rxtx_mode2,#INVERTTX wc
        if_z_ne_c       or      outa,qtxmask2
        if_z            or      dira,qtxmask2
        if_z_eq_c       or      txout2,domuxnc        'patch muxc to muxnc
        if_nz           movd    txout2,#dira          'change destination from outa to dira
                        test    rxtx_mode2,#INVERTRX wz 'wait for start bit on rx pin
        if_nz           xor     start2,doifc2ifnc     'if_c jmp to if_nc
                        or      ctsmask2,#0     wz
        if_nz           test    rxtx_mode2,#INVERTCTS wc
        if_nz_and_nc    or      ctsi2,doif_z_or_nc    'if_nc jmp
        if_nz_and_c     or      ctsi2,doif_z_or_c     'if_c jmp
        if_z            mov     txcts2,transmit2      'copy the jmpret over the cts test
        if_z            movs    ctsi2,#txcts2         'patch the jmps to transmit to txcts0
        if_z            add     txcode2,#1            'change co-routine entry to skip first jmpret
                        or      rtsmask2,#0     wz
        if_nz           test    rxtx_mode2,#INVERTRTS wc
        if_nz_and_nc    or      rts2,domuxnc          'patch muxc to muxnc
        if_z            mov     norts2,rec2i          'patch to a jmp #receive2
        if_z            movs    start2,#receive2      'skip all rts processing
                        or      qtxmask2,#0      wz
'        if_z            mov     txcode2,rxcode3       'use variable in case it has been changed
                        or      rxmask2,#0      wz
'        if_z            mov     rxcode2,txcode2       'use variable in case it has been changed
'port 1
                        test    rxtx_mode1,#OCTX wz   'init tx pin according to mode
                        test    rxtx_mode1,#INVERTTX wc
        if_z_ne_c       or      outa,qtxmask1
        if_z            or      dira,qtxmask1
        if_z_eq_c       or      txout1,domuxnc        'patch muxc to muxnc
        if_nz           movd    txout1,#dira          'change destination from outa to dira
                        test    rxtx_mode1,#INVERTRX wz 'wait for start bit on rx pin
        if_nz           xor     start1,doifc2ifnc     'if_c jmp to if_nc
                        or      ctsmask1,#0     wz
        if_nz           test    rxtx_mode1,#INVERTCTS wc
        if_nz_and_nc    or      ctsi1,doif_z_or_nc    'if_nc jmp
        if_nz_and_c     or      ctsi1,doif_z_or_c     'if_c jmp
        if_z            mov     txcts1,transmit1      'copy the jmpret over the cts test
        if_z            movs    ctsi1,#txcts1         'patch the jmps to transmit to txcts0
        if_z            add     txcode1,#1            'change co-routine entry to skip first jmpret
                                                      'patch rx routine depending on whether rts is used
                                                      'and if it is inverted
                        or      rtsmask1,#0     wz
        if_nz           test    rxtx_mode1,#INVERTRTS wc
        if_nz_and_nc    or      rts1,domuxnc          'patch muxc to muxnc
        if_z            mov     norts1,rec1i          'patch to a jmp #receive1
        if_z            movs    start1,#receive1      'skip all rts processing
                        or      qtxmask1,#0      wz
'        if_z            mov     txcode1,rxcode2       'use variable in case it has been changed
                        or      rxmask1,#0      wz
'        if_z            mov     rxcode1,txcode1       'use variable in case it has been changed
'port 0
                        test    rxtx_mode,#OCTX wz    'init tx pin according to mode
                        test    rxtx_mode,#INVERTTX wc
        if_z_ne_c       or      outa,qtxmask
        if_z            or      dira,qtxmask
                                                      'patch tx routine depending on invert and oc
                                                      'if invert change muxc to muxnc
                                                      'if oc change out1 to dira
        if_z_eq_c       or      txout0,domuxnc        'patch muxc to muxnc
        if_nz           movd    txout0,#dira          'change destination from outa to dira
                                                      'patch rx wait for start bit depending on invert
                        test    rxtx_mode,#INVERTRX wz  'wait for start bit on rx pin
        if_nz           xor     start0,doifc2ifnc     'if_c jmp to if_nc
                                                      'patch tx routine depending on whether cts is used
                                                      'and if it is inverted
                        or      ctsmask,#0     wz     'cts pin? z not set if in use
        if_nz           test    rxtx_mode,#INVERTCTS wc 'c set if inverted
        if_nz_and_nc    or      ctsi0,doif_z_or_nc    'if_nc jmp
        if_nz_and_c     or      ctsi0,doif_z_or_c     'if_c jmp
        if_z            mov     txcts0,transmit       'copy the jmpret over the cts test
        if_z            movs    ctsi0,#txcts0         'patch the jmps to transmit to txcts0
        if_z            add     txcode,#1             'change co-routine entry to skip first jmpret
                                                      'patch rx routine depending on whether rts is used
                                                      'and if it is inverted
                        or      rtsmask,#0     wz     'rts pin, z not set if in use
        if_nz           test    rxtx_mode,#INVERTRTS wc
        if_nz_and_nc    or      rts0,domuxnc          'patch muxc to muxnc
        if_z            mov     norts0,rec0i          'patch to a jmp #receive0
        if_z            movs    start0,#receive0       'skip all rts processing if not used
                                                      'patch all of tx routine out if not used
                        or      qtxmask,#0       wz
'        if_z            mov     txcode,rxcode1        'use variable in case it has been changed
                                                      'patch all of rx routine out if not used
                        or      rxmask,#0       wz
'        if_z            mov     rxcode,txcode         'use variable in case it has been changed
'
' Receive
'
receive0                jmpret  rxcode,txcode         'run a chunk of transmit code, then return
                                                      'patched to a jmp if pin not used
                        test    rxmask,ina      wc
start0  if_c            jmp     #norts0               'go check rts if no start bit
                                                      'will be patched to jmp #receive if no rts

                        mov     rxbits,#9             'ready to receive byte
                        mov     qrxcnt,bit4_ticks      '1/4 bits
                        add     qrxcnt,cnt

:bit                    add     qrxcnt,bit_ticks       '1 bit period

:wait                   jmpret  rxcode,txcode         'run a chuck of transmit code, then return

                        mov     qt1,qrxcnt              'check if bit receive period done
                        sub     qt1,cnt
                        cmps    qt1,#0           wc
        if_nc           jmp     #:wait

                        test    rxmask,ina      wc    'receive bit on rx pin
                        rcr     rxdata,#1
                        djnz    rxbits,#:bit          'get remaining bits

                        jmpret  rxcode,txcode         'run a chunk of transmit code, then return

                        shr     rxdata,#32-9          'justify and trim received byte

                        wrbyte  rxdata,rxbuff_head_ptr'{7-22}
                        add     rx_head,#1
                        and     rx_head,#$3F          '64 byte buffer
                        wrlong  rx_head,rx_head_ptr   '{8}
                        mov     rxbuff_head_ptr,rxbuff_ptr 'calculate next byte head_ptr
                        add     rxbuff_head_ptr,rx_head
norts0                  rdlong  rx_tail,rx_tail_ptr   '{7-22 or 8} will be patched to jmp #r3 if no rts
                        mov     qt1,rx_head
                        sub     qt1,rx_tail            'calculate number bytes in buffer
                        and     qt1,#$3f               'fix wrap
                        cmps    qt1,rtssize      wc    'is it more than the threshold
rts0                    muxc    outa,rtsmask          'set rts correctly

rec0i                   jmp     #receive0              'byte done, receive next byte
'
' Receive1
'
receive1                jmpret  rxcode1,txcode1       'run a chunk of transmit code, then return

                        test    rxmask1,ina     wc
start1  if_c            jmp     #norts1               'go check rts if no start bit

                        mov     rxbits1,#9            'ready to receive byte
                        mov     rxcnt1,bit4_ticks1    '1/4 bits
                        add     rxcnt1,cnt

:bit1                   add     rxcnt1,bit_ticks1     '1 bit period

:wait1                  jmpret  rxcode1,txcode1       'run a chuck of transmit code, then return

                        mov     qt1,rxcnt1             'check if bit receive period done
                        sub     qt1,cnt
                        cmps    qt1,#0           wc
        if_nc           jmp     #:wait1

                        test    rxmask1,ina     wc    'receive bit on rx pin
                        rcr     rxdata1,#1
                        djnz    rxbits1,#:bit1

                        jmpret  rxcode1,txcode1       'run a chunk of transmit code, then return
                        shr     rxdata1,#32-9         'justify and trim received byte

                        wrbyte  rxdata1,rxbuff_head_ptr1 '7-22
                        add     rx_head1,#1
                        and     rx_head1,#$3F         '64 byte buffers
                        wrlong  rx_head1,rx_head_ptr1
                        mov     rxbuff_head_ptr1,rxbuff_ptr1 'calculate next byte head_ptr
                        add     rxbuff_head_ptr1,rx_head1
norts1                  rdlong  rx_tail1,rx_tail_ptr1    '7-22 or 8 will be patched to jmp #r3 if no rts
                        mov     qt1,rx_head1
                        sub     qt1,rx_tail1
                        and     qt1,#$3f
                        cmps    qt1,rtssize1     wc
rts1                    muxc    outa,rtsmask1

rec1i                   jmp     #receive1             'byte done, receive next byte
'
' Receive2
'
receive2                jmpret  rxcode2,txcode2       'run a chunk of transmit code, then return

                        test    rxmask2,ina     wc
start2 if_c             jmp     #norts2               'go check rts if no start bit

                        mov     rxbits2,#9            'ready to receive byte
                        mov     rxcnt2,bit4_ticks2    '1/4 bits
                        add     rxcnt2,cnt

:bit2                   add     rxcnt2,bit_ticks2     '1 bit period

:wait2                  jmpret  rxcode2,txcode2       'run a chuck of transmit code, then return

                        mov     qt1,rxcnt2             'check if bit receive period done
                        sub     qt1,cnt
                        cmps    qt1,#0           wc
        if_nc           jmp     #:wait2

                        test    rxmask2,ina     wc    'receive bit on rx pin
                        rcr     rxdata2,#1
                        djnz    rxbits2,#:bit2

                        jmpret  rxcode2,txcode2       'run a chunk of transmit code, then return
                        shr     rxdata2,#32-9         'justify and trim received byte

                        wrbyte  rxdata2,rxbuff_head_ptr2 '7-22
                        add     rx_head2,#1
                        and     rx_head2,#$3F         '64 byte buffers
                        wrlong  rx_head2,rx_head_ptr2
                        mov     rxbuff_head_ptr2,rxbuff_ptr2 'calculate next byte head_ptr
                        add     rxbuff_head_ptr2,rx_head2
norts2                  rdlong  rx_tail2,rx_tail_ptr2    '7-22 or 8 will be patched to jmp #r3 if no rts
                        mov     qt1,rx_head2
                        sub     qt1,rx_tail2
                        and     qt1,#$3f
                        cmps    qt1,rtssize2     wc
rts2                    muxc    outa,rtsmask2

rec2i                   jmp     #receive2             'byte done, receive next byte
'
' Receive3
'
receive3                jmpret  rxcode3,txcode3       'run a chunk of transmit code, then return

                        test    rxmask3,ina     wc
start3 if_c             jmp     #norts3               'go check rts if no start bit

                        mov     rxbits3,#9            'ready to receive byte
                        mov     rxcnt3,bit4_ticks3    '1/4 bits
                        add     rxcnt3,cnt

:bit3                   add     rxcnt3,bit_ticks3     '1 bit period

:wait3                  jmpret  rxcode3,txcode3       'run a chuck of transmit code, then return

                        mov     qt1,rxcnt3             'check if bit receive period done
                        sub     qt1,cnt
                        cmps    qt1,#0           wc
        if_nc           jmp     #:wait3

                        test    rxmask3,ina     wc    'receive bit on rx pin
                        rcr     rxdata3,#1
                        djnz    rxbits3,#:bit3

                        jmpret  rxcode3,txcode3       'run a chunk of transmit code, then return
                        shr     rxdata3,#32-9         'justify and trim received byte

                        wrbyte  rxdata3,rxbuff_head_ptr3 '7-22
                        add     rx_head3,#1
                        and     rx_head3,#$3F         '64 byte buffers
                        wrlong  rx_head3,rx_head_ptr3    '8
                        mov     rxbuff_head_ptr3,rxbuff_ptr3 'calculate next byte head_ptr
                        add     rxbuff_head_ptr3,rx_head3
norts3                  rdlong  rx_tail3,rx_tail_ptr3    '7-22 or 8, may be patched to jmp #r3 if no rts
                        mov     qt1,rx_head3
                        sub     qt1,rx_tail3
                        and     qt1,#$3f
                        cmps    qt1,rtssize3     wc    'is buffer more that 3/4 full?
rts3                    muxc    outa,rtsmask3

rec3i                   jmp     #receive3             'byte done, receive next byte
'
' Transmit
'
transmit                jmpret  txcode,rxcode1        'run a chunk of receive code, then return
                                                      'patched to a jmp if pin not used

txcts0                  test    ctsmask,ina     wc    'if flow-controlled dont send
                        rdlong  qt1,tx_head_ptr        '{7-22} - head[0]
                        cmp     qt1,tx_tail      wz    'tail[0]
ctsi0   if_z            jmp     #transmit             'may be patched to if_z_or_c or if_z_or_nc

                        rdbyte  txdata,txbuff_tail_ptr '{8}
                        add     tx_tail,#1
                        and     tx_tail,#$0F    wz
                        wrlong  tx_tail,tx_tail_ptr    '{8}
        if_z            mov     txbuff_tail_ptr,txbuff_ptr 'reset tail_ptr if we wrapped
        if_nz           add     txbuff_tail_ptr,#1    'otherwise add 1

                        jmpret  txcode,rxcode1

                        shl     txdata,#2
                        or      txdata,txbitor        'ready byte to transmit
                        mov     qtxbits,#11
                        mov     txcnt,cnt

qtxbit                  shr     txdata,#1       wc
txout0                  muxc    outa,qtxmask           'maybe patched to muxnc dira,txmask
                        add     txcnt,bit_ticks       'ready next cnt

:wait                   jmpret  txcode,rxcode1        'run a chunk of receive code, then return

                        mov     qt1,txcnt              'check if bit transmit period done
                        sub     qt1,cnt
                        cmps    qt1,#0           wc
        if_nc           jmp     #:wait

                        djnz    qtxbits,#qtxbit         'another bit to transmit?
txjmp0                  jmp     ctsi0                 'byte done, transmit next byte
'
' Transmit1
'
transmit1               jmpret  txcode1,rxcode2       'run a chunk of receive code, then return

txcts1                  test    ctsmask1,ina    wc    'if flow-controlled dont send
                        rdlong  qt1,tx_head_ptr1
                        cmp     qt1,tx_tail1     wz
ctsi1   if_z            jmp     #transmit1            'may be patched to if_z_or_c or if_z_or_nc

                        rdbyte  txdata1,txbuff_tail_ptr1
                        add     tx_tail1,#1
                        and     tx_tail1,#$0F   wz
                        wrlong  tx_tail1,tx_tail_ptr1
        if_z            mov     txbuff_tail_ptr1,txbuff_ptr1 'reset tail_ptr if we wrapped
        if_nz           add     txbuff_tail_ptr1,#1   'otherwise add 1

                        shl     txdata1,#2
                        or      txdata1,txbitor       'ready byte to transmit
                        mov     txbits1,#11
                        mov     txcnt1,cnt

txbit1                  shr     txdata1,#1      wc
txout1                  muxc    outa,qtxmask1          'maybe patched to muxnc dira,txmask
                        add     txcnt1,bit_ticks1     'ready next cnt

:wait1                  jmpret  txcode1,rxcode2       'run a chunk of receive code, then return

                        mov     qt1,txcnt1             'check if bit transmit period done
                        sub     qt1,cnt
                        cmps    qt1,#0           wc
        if_nc           jmp     #:wait1

                        djnz    txbits1,#txbit1       'another bit to transmit?
txjmp1                  jmp     ctsi1                 'byte done, transmit next byte
'
' Transmit2
'
transmit2               jmpret  txcode2,rxcode3       'run a chunk of receive code, then return

txcts2                  test    ctsmask2,ina    wc    'if flow-controlled dont send
                        rdlong  qt1,tx_head_ptr2
                        cmp     qt1,tx_tail2     wz
ctsi2   if_z            jmp     #transmit2            'may be patched to if_z_or_c or if_z_or_nc

                        rdbyte  txdata2,txbuff_tail_ptr2
                        add     tx_tail2,#1
                        and     tx_tail2,#$0F   wz
                        wrlong  tx_tail2,tx_tail_ptr2
        if_z            mov     txbuff_tail_ptr2,txbuff_ptr2 'reset tail_ptr if we wrapped
        if_nz           add     txbuff_tail_ptr2,#1   'otherwise add 1

                        jmpret  txcode2,rxcode3

                        shl     txdata2,#2
                        or      txdata2,txbitor       'ready byte to transmit
                        mov     txbits2,#11
                        mov     txcnt2,cnt

txbit2                  shr     txdata2,#1      wc
txout2                  muxc    outa,qtxmask2          'maybe patched to muxnc dira,txmask
                        add     txcnt2,bit_ticks2     'ready next cnt

:wait2                  jmpret  txcode2,rxcode3       'run a chunk of receive code, then return

                        mov     qt1,txcnt2             'check if bit transmit period done
                        sub     qt1,cnt
                        cmps    qt1,#0           wc
        if_nc           jmp     #:wait2

                        djnz    txbits2,#txbit2       'another bit to transmit?
txjmp2                  jmp     ctsi2                 'byte done, transmit next byte
'
' Transmit3
'
transmit3               jmpret  txcode3,rxcode        'run a chunk of receive code, then return

txcts3                  test    ctsmask3,ina    wc    'if flow-controlled dont send
                        rdlong  qt1,tx_head_ptr3
                        cmp     qt1,tx_tail3     wz
ctsi3   if_z            jmp     #transmit3            'may be patched to if_z_or_c or if_z_or_nc

                        rdbyte  txdata3,txbuff_tail_ptr3
                        add     tx_tail3,#1
                        and     tx_tail3,#$0F   wz
                        wrlong  tx_tail3,tx_head_ptr3
        if_z            mov     txbuff_tail_ptr3,txbuff_ptr3 'reset tail_ptr if we wrapped
        if_nz           add     txbuff_tail_ptr3,#1   'otherwise add 1

                        shl     txdata3,#2
                        or      txdata3,txbitor       'ready byte to transmit
                        mov     txbits3,#11
                        mov     txcnt3,cnt

txbit3                  shr     txdata3,#1      wc
txout3                  muxc    outa,qtxmask3          'maybe patched to muxnc dira,txmask
                        add     txcnt3,bit_ticks3     'ready next cnt

:wait3                  jmpret  txcode3,rxcode        'run a chunk of receive code, then return

                        mov     qt1,txcnt3             'check if bit transmit period done
                        sub     qt1,cnt
                        cmps    qt1,#0           wc
        if_nc           jmp     #:wait3

                        djnz    txbits3,#txbit3       'another bit to transmit?
txjmp3                  jmp     ctsi3                 'byte done, transmit next byte
'
'These are used by SPIN and assembler, using DAT rather than VAR
'so all COGs share this instance of the object
'
startfill
  cog                   long      0                   'cog flag/id

  'Dont Change the order of any of these initialized variables without modifying
  'the code to match - both spin and assembler
  'Dont make any of the initialized variables, uninitialized, only the initialized
  'variables are duplicated in hub memory
  rx_head               long      0                   '16 longs for circular buffer head/tails
  rx_head1              long      0
  rx_head2              long      0
  rx_head3              long      0
  rx_tail               long      0
  rx_tail1              long      0
  rx_tail2              long      0
  rx_tail3              long      0
  tx_head               long      0
  tx_head1              long      0
  tx_head2              long      0
  tx_head3              long      0
  tx_tail               long      0
  tx_tail1              long      0
  tx_tail2              long      0
  tx_tail3              long      0

  'This set of variables were initialized to the correct values in Spin and loaded into this cog
  'when it started
  rxmask                long      0                   '33 longs for per port info
  rxmask1               long      0
  rxmask2               long      0
  rxmask3               long      0
  qtxmask                long      0
  qtxmask1               long      0
  qtxmask2               long      0
  qtxmask3               long      0
  ctsmask               long      0
  ctsmask1              long      0
  ctsmask2              long      0
  ctsmask3              long      0
  rtsmask               long      0
  rtsmask1              long      0
  rtsmask2              long      0
  rtsmask3              long      0
  rxtx_mode             long      0
  rxtx_mode1            long      0
  rxtx_mode2            long      0
  rxtx_mode3            long      0
  bit4_ticks            long      0
  bit4_ticks1           long      0
  bit4_ticks2           long      0
  bit4_ticks3           long      0
  bit_ticks             long      0
  bit_ticks1            long      0
  bit_ticks2            long      0
  bit_ticks3            long      0
  rtssize               long      0
  rtssize1              long      0
  rtssize2              long      0
  rtssize3              long      0
  rxchar                byte      0
  rxchar1               byte      0
  rxchar2               byte      0
  rxchar3               byte      0

  'This set of variables were initialized to the correct values in Spin and loaded into this cog
  'when it started. They contain the hub memory address of the rx/txbuffers
  rxbuff_ptr            long      0                   '32 longs for per port buffer hub ptr
  rxbuff_ptr1           long      0
  rxbuff_ptr2           long      0
  rxbuff_ptr3           long      0
  txbuff_ptr            long      0
  txbuff_ptr1           long      0
  txbuff_ptr2           long      0
  txbuff_ptr3           long      0
  rxbuff_head_ptr       long      0
  rxbuff_head_ptr1      long      0
  rxbuff_head_ptr2      long      0
  rxbuff_head_ptr3      long      0
  txbuff_tail_ptr       long      0
  txbuff_tail_ptr1      long      0
  txbuff_tail_ptr2      long      0
  txbuff_tail_ptr3      long      0

  rx_head_ptr           long      0
  rx_head_ptr1          long      0
  rx_head_ptr2          long      0
  rx_head_ptr3          long      0
  rx_tail_ptr           long      0
  rx_tail_ptr1          long      0
  rx_tail_ptr2          long      0
  rx_tail_ptr3          long      0
  tx_head_ptr           long      0
  tx_head_ptr1          long      0
  tx_head_ptr2          long      0
  tx_head_ptr3          long      0
  tx_tail_ptr           long      0
  tx_tail_ptr1          long      0
  tx_tail_ptr2          long      0
  tx_tail_ptr3          long      0
endfill       'used to calculate size of variables for longfill with 0
'
'note we are overlaying cog variables on top of these hub arrays, we need the space
'
  rx_buffer                                           'overlay rx variables over rxbuffer
  rxdata                long      0                   'transmit and receive buffers
  rxbits                long      0
  qrxcnt                 long      0
  rxdata1               long      0
  rxbits1               long      0
  rxcnt1                long      0
  rxdata2               long      0
  rxbits2               long      0
  rxcnt2                long      0
  rxdata3               long      0
  rxbits3               long      0
  rxcnt3                long      0
  qt1                   long      0
                        long      0
                        long      0
                        long      0

  rx_buffer1            long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

  rx_buffer2            long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

  rx_buffer3            long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

  tx_buffer                                           'overlay tx variables over txbuffer
  txdata                long      0
  qtxbits               long      0
  txcnt                 long      0
  txdata1               long      0

  tx_buffer1                                          'overlay tx variables over txbuffer
  txbits1               long      0
  txcnt1                long      0
  txdata2               long      0
  txbits2               long      0

  tx_buffer2                                          'overlay tx variables over txbuffer
  txcnt2                long      0
  txdata3               long      0
  txbits3               long      0
  txcnt3                long      0

                                                      'overlay tx variables over txbuffer
  tx_buffer3            long      0
                        long      0
                        long      0
                        long      0

'values to patch the code
  doifc2ifnc            long      $003c0000           'patch condition if_c to if_nc using xor
  doif_z_or_c           long      $00380000           'patch condition if_z to if_z_or_c using or
  doif_z_or_nc          long      $002c0000           'patch condition if_z to if_z_or_nc using or
  domuxnc               long      $04000000           'patch muxc to muxnc using or
'
  txbitor               long      $0401               'bits to or for transmitting


QUARTend



CON

  CHANNELS = 1
  BITS     = 16
  null     = 0


DAT

                 org
              byte ".ROM"                       ' ROM signature
              word @MONO16end-@MONO16           ' size
              byte "MONO16    "               ' name
              '     1234567890

        org
MONO16
        mov   mr1,par
        add   mr1,#4                             ' r1 points to volume
        or    dira, dcmmask                     ' make pin the dcm audio output
        mov   ctra, dcm_mode                    ' configure counter mode
        add   ctra, dcmpin
        add   dcmpin,#1
        shl   dcmpin,#9
        add   ctra,dcmpin
        mov   nexttime, cnt
        add   nexttime, start_delay
        xor   bufflg, bufflg                    ' zero bufflg = first buffer flag

        mov   frqa,midval                       ' bias to half
:loop1
        mov   samidx, #0                        ' buffer start
        xor   bufflg, neg1                      ' toggle buffer flag
:loop2
        rdlong  delta,par                       ' update delta (sample rate) from hub delta
        rdlong  volume,mr1                       ' update volume from hub volume
        nop
        waitcnt nexttime, delta                 ' sample time wait

        mov   ptr, samidx                       ' 2 * samidx is the relative byte offset to the current
        shl   ptr, #1                           ' WORD (which hopefully lands on a proper pair)

        cmp   bufflg, neg1 wz                   ' select the current frame (buf1 or buf2)

   if_e add   ptr, buf1                         ' ptr := buffer + sample index
  if_ne add   ptr, buf2

        rdword val, ptr                         ' get next sample
'''        cmp   val,_null wz
'''  if_z  mov   val,zero
        add   val,sign16                        ' convert to 16-bit unsigned (biased to half 16-bit range)
        and   val,mask16
        shl   val,volume             '
        wrword _null, ptr                       ' wipe the buffer (so it's silent if not filled)
        mov   frqa, val                         ' output next sample

        add   samidx, #1                        ' point to next sample
        cmp   samidx, bufsiz wz                 ' end of buffer?
  if_ne jmp   #:loop2                           ' no, continue with this buffer

        jmp   #:loop1                           ' next buffer


midval        long $8000_0000
sign16        long $8000
mask16        long $FFFF
dcm_mode      long %00111 << 26                  ' diff duty mode

start_delay   long 1_000_000

neg1          long -1
zero          long 0
_null         long null

rate          long 0

delta         long 0
volume        long 16

dcmpin        long 0

dcmmask       long 0

bufsiz        long 0
buf1          long 0
buf2          long 0

samidx        res 1
bufflg        res 1

nexttime      res 1

ptr           res 1
val           res 1
mr1            res 1

mono16end







'################################################################################################

CON
  SignFlag      = $1
  ZeroFlag      = $2
  NaNFlag       = $8

DAT
                 org
              byte ".ROM"                       ' ROM signature
              word @F32end-@F32                 ' size
              byte "F32       "                 ' name
              '     1234567890


'----------------------------
' Assembly language routines
'----------------------------

'----------------------------
' Main control loop
'----------------------------
                        org     0                       ' (try to keep 2 or fewer instructions between rd/wrlong)
F32                     rdlong  ret_ptr, par wz         ' wait for command to be non-zero, and store it in the call location
              if_z      jmp     #f32

                        rdlong  :execCmd, ret_ptr       ' get the pointer to the return value ("@result")
                        add     ret_ptr, #4

                        rdlong  fNumA, ret_ptr          ' fnumA is the long after "result"
                        add     ret_ptr, #4

                        rdlong  fNumB, ret_ptr          ' fnumB is the long after fnumA
                        sub     ret_ptr, #8

:execCmd                nop                             ' execute command, which was replaced by getCommand

:finishCmd              wrlong  fnumA, ret_ptr          ' store the result (2 longs before fnumB)
                        wrlong  outb, par               ' clear command status (outb is initialized to 0)
                        jmp     #f32                ' wait for next command


'----------------------------
' addition and subtraction
' fnumA = fnumA +- fnumB
'----------------------------
_FSub                   xor     fnumB, Bit31            ' negate B
_FAdd                   call    #_Unpack2               ' unpack two variables
          if_c_or_z     jmp     _FAdd_ret              ' check for NaN or B = 0

                        test    flagA, #SignFlag wz     ' negate A mantissa if negative
          if_nz         neg     manA, manA
                        test    flagB, #SignFlag wz     ' negate B mantissa if negative
          if_nz         neg     manB, manB

                        mov     ft1, expA                ' align mantissas
                        sub     ft1, expB
                        abs     ft1, ft1          wc
                        max     ft1, #31
              if_nc     sar     manB, ft1
              if_c      sar     manA, ft1
              if_c      mov     expA, expB

                        add     manA, manB              ' add the two mantissas
                        abs     manA, manA      wc      ' store the absolte value,
                        muxc    flagA, #SignFlag        ' and flag if it was negative

                        call    #_Pack                  ' pack result and exit
_FSub_ret
_FAdd_ret               ret


'----------------------------
' multiplication
' fnumA *= fnumB
'----------------------------
_FMul                   call    #_Unpack2               ' unpack two variables
              if_c      jmp     _FMul_ret              ' check for NaN

                        xor     flagA, flagB            ' get sign of result
                        add     expA, expB              ' add exponents

                        '{ new method: 4 * (4 * 24 + 10) = 424 counts for this block,
                        ' worst case.  But, it is within the window of the calling Spin
                        ' repeat loop, so un-noticable.  And the best case scenario is
                        ' better.
                        neg     ft1, manA                ' isolate the low bit of manA
                        and     ft1, manA
                        neg     ft2, manB                ' isolate the low bit of manB
                        and     ft2, manB
                        cmp     ft1, ft2 wc               ' who has the greater low bit?  After reversal, this will go to 0 faster.
              if_c      mov     ft1, manA wz             ' if t1 is 0, we'll just skip through everything              '
              if_nc     mov     ft1, manB wz             ' ditto, only t1 is manB
              if_nc     mov     manB, manA              ' and in this case we wanted manA to be the multiplier mask

                        mov     manA, #0                ' manA is my new accumulator
                        rev     manB, #32-30            ' start by right aligning the reverse of the B mantissa

:multiply     if_nz     shr     manB, #1 wc,wz          ' get multiplier bit, and take note if we hit 0 (skip if t1 was already 0!)
              if_c      add     manA, ft1                ' if the bit was set, add in the multiplicand
                        shr     ft1, #1                  ' adjust my increment value's bit alignment
              if_nz     jmp     #:multiply              ' go back for more
                        '}

                        { standard method: 404 counts for this block
                        mov     ft1, #0                  ' t1 is my accumulator
                        mov     ft2, #24                 ' loop counter for multiply (only do the bits needed...23 + implied 1)
                        shr     manB, #6                ' start by right aligning the B mantissa

:multiply               shr     ft1, #1                  ' shift the previous accumulation down by 1
                        shr     manB, #1 wc             ' get multiplier bit
              if_c      add     ft1, manA                ' if the bit was set, add in the multiplicand
                        djnz    ft2, #:multiply          ' go back for more
                        mov     manA, ft1                ' yes, that's my final answer.
                        '}

                        call    #_Pack
_FMul_ret               ret


'----------------------------
' division
' fnumA /= fnumB
'----------------------------
_FDiv                   call    #_Unpack2               ' unpack two variables
          if_c_or_z     mov     fnumA, NaN              ' check for NaN or divide by 0
          if_c_or_z     jmp     _FDiv_ret

                        xor     flagA, flagB            ' get sign of result
                        sub     expA, expB              ' subtract exponents

                        ' slightly faster division, using 26 passes instead of 30
                        mov     ft1, #0                  ' clear quotient
                        mov     ft2, #26                 ' loop counter for divide (need 24, plus 2 for rounding)

:divide                 ' divide the mantissas
                        cmpsub  manA, manB      wc
                        rcl     ft1, #1
                        shl     manA, #1
                        djnz    ft2, #:divide
                        shl     ft1, #4                  ' align the result (we did 26 instead of 30 iterations)

                        mov     manA, ft1                ' get result and exit
                        call    #_Pack

_FDiv_ret               ret

'------------------------------------------------------------------------------
' fnumA = float(fnumA)
'------------------------------------------------------------------------------
_FFloat                 abs     manA, fnumA     wc,wz   ' get |integer value|
              if_z      jmp     _FFloat_ret            ' if zero, exit
                        muxc    flagA, #SignFlag        ' depending on the integer's sign
                        mov     expA, #29               ' set my exponent
                        call    #_Pack                  ' pack and exit
_FFloat_ret             ret

'------------------------------------------------------------------------------
' rounding and truncation
' fnumB controls the output format:
'       %00 = integer, truncate
'       %01 = integer, round
'       %10 = float, truncate
'       %11 = float, round
'------------------------------------------------------------------------------
_FTruncRound            mov     ft1, fnumA               ' grab a copy of the input
                        call    #_Unpack                ' unpack floating point value

                        ' Are we going for float or integer?
                        cmpsub  fnumB, #%10     wc      ' clear bit 1 and set the C flag if it was a 1
                        rcl     ft2, #1
                        and     ft2, #1          wz      ' Z now signified integer output

                        shl     manA, #2                ' left justify mantissa
                        sub     expA, #30               ' our target exponent is 30
                        abs     expA, expA      wc      ' adjust for exponent sign, and track if it was negative

              if_z_and_nc mov   manA, NaN               ' integer output, and it's too large for us to handle
              if_z_and_nc jmp   #:check_sign

              if_nz_and_nc mov  fnumA, ft1                ' float output, and we're already all integer
              if_nz_and_nc jmp  _FTruncRound_ret

                        ' well, I need to kill off some bits, so let's do it
                        cmp     expA, #32       wc      ' DO set the C flag here...I want to know if expA =< 31, aka < 32
                        max     expA, #31               ' DON'T set the C flag here...max sets C if D<S
                        shr     manA, expA
              if_c      add     manA, fnumB             ' round up 1/2 lsb if desired, and if it isn't supposed to be 0! (if expA was > 31)
                        shr     manA, #1

              if_z      jmp     #:check_sign            ' integer output?

                        mov     expA, #29
                        call    #_Pack
                        jmp     _FTruncRound_ret

:check_sign             test    flagA, #signFlag wz     ' check sign and exit
                        negnz   fnumA, manA

_FTruncRound_ret        ret


'------------------------------------------------------------------------------
' truncation to unsigned integer
' fnumA = unsigned int(fnumA), clamped to 0
'------------------------------------------------------------------------------
_UintTrunc              call    #_Unpack
                        mov     fnumA, #0
                        test    flagA, #SignFlag wc
              if_c_or_z jmp     _UintTrunc_ret         ' if the input number was negative or zero, we're done
                        shl     manA, #2                ' left justify mantissa
                        sub     expA, #31               ' our target exponent is 31
                        abs     expA, expA      wc,wz
              if_a      neg     fnumA, #1               ' if we needed to shift left, we're already maxed out
              if_be     cmp     expA, #32       wc      ' otherwise, if we need to shift right by more than 31, the answer is 0
              if_c      shr     manA, expA              ' OK, shift it down
              if_c      mov     fnumA, manA
_UintTrunc_ret          ret


'------------------------------------------------------------------------------
' square root
' fnumA = sqrt(fnumA)
'------------------------------------------------------------------------------
_FSqr                   call    #_Unpack                 ' unpack floating point value
          if_c_or_z     jmp     _FSqr_ret               ' check for NaN or zero
                        test    flagA, #signFlag wz      ' check for negative
          if_nz         mov     fnumA, NaN               ' yes, then return NaN
          if_nz         jmp     _FSqr_ret

                        sar     expA, #1 wc             ' if odd exponent, shift mantissa
          if_c          shl     manA, #1
                        add     expA, #1
                        mov     ft2, #29

                        mov     fnumA, #0               ' set initial result to zero
:sqrt                   ' what is the delta root^2 if we add in this bit?
                        mov     t3, fnumA
                        shl     t3, #2
                        add     t3, #1
                        shl     t3, ft2
                        ' is the remainder >= delta?
                        cmpsub  manA, t3        wc
                        rcl     fnumA, #1
                        shl     manA, #1
                        djnz    ft2, #:sqrt

                        mov     manA, fnumA             ' store new mantissa value and exit
                        call    #_Pack
_FSqr_ret               ret


'------------------------------------------------------------------------------
' compare fnumA , fnumB
' fnumA =
'       1 if fnumA > fnumB
'       -1 if fnumA < fnumB
'       0 if fnumA = fnumB
'------------------------------------------------------------------------------
_FCmp                   mov     ft1, fnumA               ' if both values...
                        and     ft1, fnumB               '  are negative...
                        shl     ft1, #1 wc               ' (bit 31 high)...
                        negc    ft1, #1                  ' then the comparison will be reversed
                        cmps    fnumA, fnumB wc,wz      ' do the signed comparison, save result in flags C Z
              if_z      mov     ft1, #0
                        or      fnumA, fnumB            ' +0 == -0, so compare for both being 0...
                        andn    fnumA, Bit31 wz         ' ignoring bit 31, will be 0 if both fA and fB were zero
              if_nz     negc    fnumA, ft1               ' if it's not zero
_FCmp_ret               ret


'------------------------------------------------------------------------------
' new table lookup code
' Inputs
' t1 = 31-bit number: 1-bit 0, then 11-bits real, then 20-bits fraction (allows the sine table to use the top bit)
' t2 = table base address
' Outputs
' t1 = 30-bit interpolated number
'------------------------------------------------------------------------------
_Table_Interp           ' store the fractional part
                        mov     t4, ft1                  ' will store reversed so a SAR will shift the value and get a bit
                        rev     t4, #12                 ' ignore the top 12 bits, and reverse the rest
                        ' align the input number to get the table offset, multiplied by 2
                        shr     ft1, #19
                        test    ft2, SineTable    wc      'C = 1 if we're doing a SINE table lookup.  added to fix LOG and SIN
                        add     ft2, ft1
                        ' read the 2 intermediate values, and scale them for interpolation
                        rdword  ft1, ft2
                        shl     ft1, #14

                        add     ft2, #2

                        test    ft2, TableMask   wz      'table address has overflowed.  added to fix LOG
        if_z_and_nc     mov     ft2, Bit16               'fix table value unless we're doing the SINE table.  added to fix LOG
        if_nz_or_c      rdword  ft2, ft2                  'else, look up the correct value.  conditional added to fix LOG
                        shl     ft2, #14
                        ' interpolate
                        sub     ft2, ft1                  ' change from 2 points to delta
                        movs    ft2, t4                  ' make the low 9 bits the multiplier (reversed)
                        mov     t3, #9                  ' do 9 steps
:interp                 sar     ft2, #1          wc      ' divide the delta by 2, and get the MSB multiplier bit
              if_c      add     ft1, ft2                  ' if the multiplier bit was 1, add in the shifter delta
                        djnz    t3, #:interp            ' keep going, 9 times around
                        ' done, and the answer is in t1, bit 29 aligned
_Table_Interp_ret       ret


'------------------------------------------------------------------------------
' sine and cosine
' fnumA = sin(fnumA) for sine
' fnumA = sin(fnumA+pi/2) for cosine
' note: resume tan allows reuse of the angle scaling when calling
' both sine and cosine of the same angle.
'------------------------------------------------------------------------------
OneOver2Pi              long    1.0 / (2.0 * pi)        ' I need this constant to get the fractional angle

_Cos                    mov     t4, bit29               ' adjust sine to cosine at the last possible minute by adding 90 degrees
                        andn    fnumA, bit31            ' nuke the sign bit
                        jmp     #_SinCos_cont

_Sin                    mov     t4, #0                  ' just sine, and keep my sign bit

_SinCos_cont            mov     fnumB, OneOver2Pi
                        call    #_FMul                  ' rescale angle from [0..2pi] to [0..1]

                        ' now, work with the raw value
                        call    #_Unpack

                        ' get the whole and fractional bits
                        add     expA, #2                ' bias the exponent by 3 so the resulting data will be 31-bit aligned
                        abs     expA, expA      wc      ' was the exponent positive or negative?
                        max     expA, #31               ' limit to 31, otherwise we do weird wrapping things
              if_c      shr     manA, expA              ' -exp: shift right to bring down to 1.0
              if_nc     shl     manA, expA              ' +exp: shift left to throw away the high bits

                        mov     t6, manA                ' store the address in case Tan needs it

                        add     manA, t4                ' adjust for cosine?

_resume_Tan             test    manA, bit29     wz
                        negnz   ft1, manA
                        shl     ft1, #2

                        mov     ft2, SineTable
                        call    #_Table_Interp

                        ' rebuild the number
                        test    manA, bit30     wz      ' check if we're in quadrant 3 or 4
                        abs     manA, ft1                ' move my number into the mantissa
                        shr     manA, #16               ' but the table went to $FFFF, so scale up a bit to
                        addabs  manA, ft1                ' get to &10000
              if_nz     xor     flagA, #SignFlag        ' invert my sign bit, if the mantissa would have been negative (quad 3 or 4)
                        neg     expA, #1                ' exponent is -1
                        call    #_Pack

_resume_Tan_ret
_Cos_ret
_Sin_ret                ret


'------------------------------------------------------------------------------
' tangent
' fnumA = tan(fnumA) = sin(fnumA) / cos(fnumA)
'------------------------------------------------------------------------------
_Tan                    call    #_Sin
                        mov     t7, fnumA
                        ' skip the angle normalizing, much faster
                        mov     manA, t6                ' was manA for Sine
                        add     manA, bit29             ' add in 90 degrees
                        call    #_resume_Tan            ' go back and recompute the float
                        mov     fnumB, fnumA            ' move Cosine into fnumB
                        mov     fnumA, t7               ' move Sine into fnumA
                        call    #_FDiv                  ' divide
_Tan_ret                ret


'------------------------------------------------------------------------------
' log2
' fnumA = log2(fnumA)
' may be divided by fnumB to change bases
'------------------------------------------------------------------------------
_Log2                   call    #_Unpack                ' unpack variable
          if_nz_and_nc  test    flagA, #SignFlag wc     ' if NaN or <= 0, return NaN
          if_z_or_c     jmp     #:exitNaN

                        mov     ft1, manA
                        shl     ft1, #3
                        shr     ft1, #1
                        mov     ft2, LogTable
                        call    #_Table_Interp
                        ' store the interpolated table lookup
                        mov     manA, ft1
                        shr     manA, #5                  ' clear the top 7 bits (already 2 free
                        ' process the exponent
                        abs     expA, expA      wc
                        muxc    flagA, #SignFlag
                        ' recombine exponent into the mantissa
                        shl     expA, #25
                        negc    manA, manA
                        add     manA, expA
                        mov     expA, #4
                        ' make it a floating point number
                        call    #_Pack
                        ' convert the base
                        cmp     fnumB, #0    wz         ' check that my divisor isn't 0 (which flags that we're doing log2)
              if_nz     call    #_FDiv                  ' convert the base (unless fnumB was 0)
                        jmp     _Log2_ret

:exitNaN                mov     fnumA, NaN              ' return NaN
_Log2_ret               ret

'------------------------------------------------------------------------------
' exp2
' fnumA = 2 ** fnumA
' may be multiplied by fnumB to change bases
'------------------------------------------------------------------------------
                        ' 1st off, convert the base
_Exp2                   cmp     fnumB, #0       wz
              if_nz     call    #_FMul

                        call    #_Unpack
                        shl     manA, #2                ' left justify mantissa
                        mov     ft1, expA                ' copy the local exponent

                        '        OK, get the whole number
                        sub     ft1, #30                 ' our target exponent is 31
                        abs     expA, ft1      wc        ' adjust for exponent sign, and track if it was negative
              if_c      jmp     #:cont_Exp2

                        ' handle this case depending on the sign
                        test    flagA, #signFlag wz
              if_z      mov     fnumA, NaN              ' nope, was positive, bail with NaN (happens to be the largest positive integer)
              if_nz     mov     fnumA, #0
                        jmp     _Exp2_ret

:cont_Exp2              mov     ft2, manA
                        max     expA, #31
                        shr     ft2, expA
                        shr     ft2, #1
                        mov     expA, ft2

                        ' get the fractional part
                        add     ft1, #31
                        abs     ft2, ft1          wc
              if_c      shr     manA, ft2
              if_nc     shl     manA, ft2

                        ' do the table lookup
                        mov     ft1, manA
                        shr     ft1, #1
                        mov     ft2, ALogTable
                        call    #_Table_Interp

                        ' store a copy of the sign
                        mov     t6, flagA

                        ' combine
                        mov     manA, ft1
                        or      manA, bit30
                        sub     expA, #1
                        mov     flagA, #0

                        call    #_Pack

                        test    t6, #signFlag wz        ' check sign and store this back in the exponent
              if_z      jmp     _Exp2_ret
                        mov     fnumB, fnumA            ' yes, then invert
                        mov     fnumA, One
                        call    #_FDiv

_Exp2_ret               ret


'------------------------------------------------------------------------------
' power
' fnumA = fnumA raised to power fnumB
'------------------------------------------------------------------------------
_Pow                    mov     t7, fnumA wc            ' save sign of result
          if_nc         jmp     #:pow3                  ' check if negative base

                        mov     fnumA, fnumB            ' check exponent
                        call    #_Unpack
                        mov     fnumA, t7               ' restore base
          if_z          jmp     #:pow2                  ' check for exponent = 0

                        test    expA, Bit31 wz          ' if exponent < 0, return NaN
          if_nz         jmp     #:pow1

                        max     expA, #23               ' check if exponent = integer
                        shl     manA, expA
                        and     manA, Mask29 wz, nr
          if_z          jmp     #:pow2                  ' yes, then check if odd

:pow1                   mov     fnumA, NaN              ' return NaN
                        jmp     _Pow_ret

:pow2                   test    manA, Bit29 wz          ' if odd, then negate result
          if_z          andn    t7, Bit31

:pow3                   andn    fnumA, Bit31            ' get |fnumA|
                        mov     t6, fnumB               ' save power
                        call    #_Log2                  ' get log of base
                        mov     fnumB, t6               ' multiply by power
                        call    #_FMul
                        call    #_Exp2                  ' get result

                        test    t7, Bit31 wz            ' check for negative
          if_nz         xor     fnumA, Bit31
_Pow_ret                ret


'------------------------------------------------------------------------------
' fraction
' fnumA = fractional part of fnumA
'------------------------------------------------------------------------------
_Frac                   call    #_Unpack                ' get fraction
                        test    expA, Bit31 wz          ' check for exp < 0 or NaN
          if_c_or_nz    jmp     #:exit
                        max     expA, #23               ' remove the integer
                        shl     manA, expA
                        and     manA, Mask29
                        mov     expA, #0                ' return fraction

:exit                   call    #_Pack
                        andn    fnumA, Bit31
_Frac_ret               ret


'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value
'          fnumB        32-bit floating point value
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          flagB        fnumB flag bits (Nan, Infinity, Zero, Sign)
'          expB         fnumB exponent (no bias)
'          manB         fnumB mantissa (aligned to bit 29)
'          C flag       set if fnumA or fnumB is NaN
'          Z flag       set if fnumB is zero
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------
_Unpack2                mov     ft1, fnumA               ' save A
                        mov     fnumA, fnumB            ' unpack B to A
                        call    #_Unpack
          if_c          jmp     _Unpack2_ret           ' check for NaN

                        mov     fnumB, fnumA            ' save B variables
                        mov     flagB, flagA
                        mov     expB, expA
                        mov     manB, manA

                        mov     fnumA, ft1               ' unpack A
                        call    #_Unpack
                        cmp     manB, #0 wz             ' set Z flag
_Unpack2_ret            ret


'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          C flag       set if fnumA is NaN
'          Z flag       set if fnumA is zero
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------
_Unpack                 mov     flagA, fnumA            ' get sign
                        shr     flagA, #31
                        mov     manA, fnumA             ' get mantissa
                        and     manA, Mask23
                        mov     expA, fnumA             ' get exponent
                        shl     expA, #1
                        shr     expA, #24 wz
          if_z          jmp     #:zeroSubnormal         ' check for zero or subnormal
                        cmp     expA, #255 wz           ' check if finite
          if_nz         jmp     #:finite
                        mov     fnumA, NaN              ' no, then return NaN
                        mov     flagA, #NaNFlag
                        jmp     #:exit2

:zeroSubnormal          or      manA, expA wz,nr        ' check for zero
          if_nz         jmp     #:subnorm
                        or      flagA, #ZeroFlag        ' yes, then set zero flag
                        neg     expA, #150              ' set exponent and exit
                        jmp     #:exit2

:subnorm                shl     manA, #7                ' fix justification for subnormals
:subnorm2               test    manA, Bit29 wz
          if_nz         jmp     #:exit1
                        shl     manA, #1
                        sub     expA, #1
                        jmp     #:subnorm2

:finite                 shl     manA, #6                ' justify mantissa to bit 29
                        or      manA, Bit29             ' add leading one bit

:exit1                  sub     expA, #127              ' remove bias from exponent
:exit2                  test    flagA, #NaNFlag wc      ' set C flag
                        cmp     manA, #0 wz             ' set Z flag
_Unpack_ret             ret


'------------------------------------------------------------------------------
' input:   flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
' output:  fnumA        32-bit floating point value
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------
_Pack                   cmp     manA, #0 wz             ' check for zero
          if_z          mov     expA, #0
          if_z          jmp     #:exit1

                        sub     expA, #380              ' take us out of the danger range for djnz
:normalize              shl     manA, #1 wc             ' normalize the mantissa
          if_nc         djnz    expA, #:normalize       ' adjust exponent and jump

                        add     manA, #$100 wc          ' round up by 1/2 lsb

                        addx    expA, #(380 + 127 + 2)  ' add bias to exponent, account for rounding (in flag C, above)
                        mins    expA, Minus23
                        maxs    expA, #255

                        abs     expA, expA wc,wz        ' check for subnormals, and get the abs in case it is
          if_a          jmp     #:exit1

:subnormal              or      manA, #1                ' adjust mantissa
                        ror     manA, #1

                        shr     manA, expA
                        mov     expA, #0                ' biased exponent = 0

:exit1                  mov     fnumA, manA             ' bits 22:0 mantissa
                        shr     fnumA, #9
                        movi    fnumA, expA             ' bits 23:30 exponent
                        shl     flagA, #31
                        or      fnumA, flagA            ' bit 31 sign
_Pack_ret               ret


'------------------------------------------------------------------------------
' modulo
' fnumA = fnumA mod fnumB
'------------------------------------------------------------------------------
_FMod                   mov     t4, fnumA               ' save fnumA
                        mov     t5, fnumB               ' save fnumB
                        call    #_FDiv                  ' a - float(fix(a/b)) * b
                        mov     fnumB, #0
                        call    #_FTruncRound
                        call    #_FFloat
                        mov     fnumB, t5
                        call    #_FMul
                        or      fnumA, Bit31
                        mov     fnumB, t4
                        andn    fnumB, Bit31
                        call    #_FAdd
                        test    t4, Bit31 wz            ' if a < 0, set sign
          if_nz         or      fnumA, Bit31
_FMod_ret               ret


'------------------------------------------------------------------------------
' arctan2
' fnumA = atan2( fnumA, fnumB )
' note: y = fnumA, x = fnumB: same as C++, opposite of Excel!
'------------------------------------------------------------------------------
_ATan2                  call    #_Unpack2               ' OK, start with the basics
                        mov     fnumA, #0               ' clear my accumulator
                        ' which is the larger exponent?
                        sub     expA, expB
                        abs     expA, expA      wc

                        ' decrease my resolution...I could get some overflow without this!
                        ' Thanks, Duane Degn!!
                        shr     manA, #1
                        shr     manB, #1

                        ' make the exponents equal
              if_c      shr     manA, expA
              if_nc     shr     manB, expA

                        ' correct signs based on the Quadrant
                        test    flagA, #SignFlag wc
                        test    flagB, #SignFlag wz
              if_z_eq_c neg     manA, manA
              if_nz     sumc    fnumA, CORDIC_Pi

                        ' do the CORDIC thing
                        mov     ft1, #0
                        mov     ft2, #25                 ' 20 gets you the same error range as the original, 29 is best, 25 is a nice compromise
                        movs    :load_C_table, #CORDIC_Angles

:CORDIC                 ' do the actual CORDIC thing
                        mov     t3, manA        wc      ' mark whether our Y component is negative or not
                        sar     t3, ft1
                        mov     t4, manB
                        sar     t4, ft1
                        sumc    manB, t3                ' C determines the direction of the rotation
                        sumnc   manA, t4        wz      ' (be ready to short-circuit as soon as the Y component is 0)
:load_C_table           sumc    fnumA, 0-0
                        ' update all my counters (including the code ones)
                        add     :load_C_table, #1
                        add     ft1, #1
                        ' go back for more?
                        djnz    ft2, #:CORDIC

                        ' convert to a float
                        mov     expA, #1
                        abs     manA, fnumA     wc
                        muxc    flagA, #SignFlag
                        call    #_Pack

_ATan2_ret              ret

CORDIC_Pi               long    $3243f6a8       ' Pi in 30 bits (otherwise we can overflow)
' The CORDIC angle table...binary 30-bit representation of atan(2^-i)
CORDIC_Angles           long $c90fdaa, $76b19c1, $3eb6ebf, $1fd5ba9, $ffaadd
                        long $7ff556, $3ffeaa, $1fffd5, $ffffa, $7ffff
                        long $3ffff, $20000, $10000, $8000, $4000
                        long $2000, $1000, $800, $400, $200
                        long $100, $80, $40, $20, $10
                        'long $8, $4, $2, $1


'------------------------------------------------------------------------------
' arcsine or arccosine
' fnumA = asin or acos(fnumA)
' asin( x ) = atan2( x, sqrt( 1 - x*x ) )
' acos( x ) = atan2( sqrt( 1 - x*x ), x )
'------------------------------------------------------------------------------
_ASinCos                ' grab a copy of both operands
                        mov     t5, fnumA
                        mov     t6, fnumB
                        ' square fnumA
                        mov     fnumB, fnumA
                        call    #_FMul
                        mov     fnumB, fnumA
                        mov     fnumA, One
                        call    #_FSub
                        '       quick error check
                        test    fnumA, bit31    wc
              if_c      mov     fnumA, NaN
              if_c      jmp     _ASinCos_ret
                        ' carry on
                        call    #_FSqr
                        ' check if this is sine or cosine (determines which goes into fnumA and fnumB)
                        mov     t6, t6          wz
              if_z      mov     fnumB, t5
              if_nz     mov     fnumB, fnumA
              if_nz     mov     fnumA, t5
                        call    #_ATan2
_ASinCos_ret            ret


'------------------------------------------------------------------------------
' _Floor fnumA = floor(fnumA)
' _Ceil fnumA = ceil(fnumA)
'------------------------------------------------------------------------------
_Ceil                   mov     t6, #1                  ' set adjustment value
                        jmp     #floor2

_Floor                  neg     t6, #1                  ' set adjustment value

floor2                  call    #_Unpack                ' unpack variable
          if_c          jmp     _Floor_ret             ' check for NaN
                        cmps     expA, #23 wc, wz       ' check for no fraction
          if_nc         jmp     _Floor_ret

                        mov     t4, fnumA               ' get integer value
                        mov     fnumB, #0
                        call    #_FTruncRound
                        mov     t5, fnumA
                        xor     fnumA, t6
                        test    fnumA, Bit31 wz
          if_nz         jmp     #:exit

                        mov     fnumA, t4               ' get fraction
                        call    #_Frac

                        or      fnumA, fnumA wz
          if_nz         add     t5, t6                  ' if non-zero, then adjust

:exit                   mov     fnumA, t5               ' convert integer to float
                        call    #_FFloat                '}
_Ceil_ret
_Floor_ret              ret


'-------------------- constant values -----------------------------------------

One                     long    1.0
NaN                     long    $7FFF_FFFF
Minus23                 long    -23
Mask23                  long    $007F_FFFF
Mask29                  long    $1FFF_FFFF
TableMask               long    $0FFE           'added to fix LOG
Bit16                   long    $0001_0000       'added to fix LOG
Bit29                   long    $2000_0000
Bit30                   long    $4000_0000
Bit31                   long    $8000_0000
LogTable                long    $C000
ALogTable               long    $D000
SineTable               long    $E000

'-------------------- initialized variables -----------------------------------

'-------------------- local variables -----------------------------------------

ret_ptr                 res     1
ft1                      res     1
ft2                      res     1
t3                      res     1
t4                      res     1
t5                      res     1
t6                      res     1
t7                      res     1

fnumA                   res     1               ' floating point A value
flagA                   res     1
expA                    res     1
manA                    res     1

fnumB                   res     1               ' floating point B value
flagB                   res     1
expB                    res     1
manB                    res     1

F32end
{
' command dispatch table: must be compiled along with PASM code in
' Cog RAM to know the addresses, but does not neet to fit in it.
cmdCallTable
cmdFAdd                 call    #_FAdd
cmdFSub                 call    #_FSub
cmdFMul                 call    #_FMul
cmdFDiv                 call    #_FDiv
cmdFFloat               call    #_FFloat
cmdFTruncRound          call    #_FTruncRound
cmdUintTrunc            call    #_UintTrunc
cmdFSqr                 call    #_FSqr
cmdFCmp                 call    #_FCmp
cmdFSin                 call    #_Sin
cmdFCos                 call    #_Cos
cmdFTan                 call    #_Tan
cmdFLog2                call    #_Log2
cmdFExp2                call    #_Exp2
cmdFPow                 call    #_Pow
cmdFFrac                call    #_Frac
cmdFMod                 call    #_FMod
cmdASinCos              call    #_ASinCos
cmdATan2                call    #_ATan2
cmdCeil                 call    #_Ceil
cmdFloor                call    #_Floor
}

'################################################################################################
romend
'######################################### END OF ROMS ##########################################































CON
{ *** DICTIONARY in RAM and EEPROM *** }
{
The Forth dictionary is loaded into high RAM and is not used at runtime normally unless the console is used to "talk" to Forth.

Search methods:

Structure:
1 - Count byte - This speeds up searching the dictionary both in comparing and in jumping to the next string
2- Name string
3- Attribute byte (8th bit set also terminates name string )
4- 1st bytecode, 2nd bytecode

Dictionary entries do not need a link field as they are bunched together one after another and it is very easy
to find the next entry by scanning forwards and looking for the attribute byte which will have the msb set then
jumping 3 bytes. A name field that begins with a null indicates end of dictionary (or link to another), null null is the end.
}


' Dictionary header attribute flags
hd      = |<7           'indicates this is a an attribute (delimits the start of a null terminated name)
sm      = |<6           'smudge bit - set to deactivate word during definition
im      = |<5           'lexicon immediate bit
pr      = |<3           'private (can be removed from the dictionary)

' code attributes       00 = single bytecode, 02 = XCALL bytecode (2 bytes), 03 = CALL16 bytecode (3 bytes)

sq      = |<2           'indicates the bytecode is a sequence of two PASM instructions (as opposed to a vectored call)
xc      = |<1           'XCALL bytecode
ac      = xc+|<0        'CALL16 - 2 byte address - interpret header CFA as an absolute address

DAT { *** DICTIONARY *** }


' { MANUALLY OPTIMISE }
TRIM    byte    0[$6A7C-@romend]              ' trim this manually to optimize top of memory (rxbuf @7100 etc)


{ This is an 8th bit terminated string using the attribute byte so it saves one byte per entry
plus it simplfies the string compare function. Searching still proceeds from lower memory to higher memory
}



dictionary

' The count field is left blank but filled in at runtime so that these do not need to be calculated when defining
'
        '       CNT,NAME        ATR     CODES
        byte    $20,"DUP",      hd,             DUP,EXIT
        byte    $20,"OVER",     hd,             OVER,EXIT
        byte    $20,"DROP",     hd,             DROP,EXIT
        byte    $20,"2DROP",    hd,             DROP2,EXIT
        byte    $20,"SWAP",     hd,             SWAP,EXIT
        byte    $20,"ROT",      hd,             ROT,EXIT
        byte    $20,"BOUNDS",   hd,             BOUNDS,EXIT
        byte    $20,"STREND",   hd,             STREND,EXIT

        byte    $20,"0",        hd,             _0,EXIT
        byte    $20,"1",        hd,             _1,EXIT
        byte    $20,"2",        hd,             _2,EXIT
        byte    $20,"3",        hd,             _3,EXIT
        byte    $20,"4",        hd,             _4,EXIT
        byte    $20,"8",        hd,             _8,EXIT
        byte    $20,"ON",       hd,             MINUS1,EXIT
        byte    $20,"TRUE",     hd,             MINUS1,EXIT
        byte    $20,"-1",       hd,             MINUS1,EXIT
        byte    $20,"BL",       hd,             BL,EXIT
        byte    $20,"16",       hd,             _16,EXIT
        byte    $20,"FALSE",    hd,             _0,EXIT
        byte    $20,"OFF",      hd,             _0,EXIT

        byte    $20,"1+",       hd,             INC,EXIT
        byte    $20,"1-",       hd,             DEC,EXIT
        byte    $20,"+",        hd,             PLUS,EXIT
        byte    $20,"-",        hd,             MINUS,EXIT

        byte    $20,"DO",       hd,             DO,EXIT
        byte    $20,"LOOP",     hd,             LOOP,EXIT
        byte    $20,"+LOOP",    hd,             PLOOP,EXIT
        byte    $20,"FOR",      hd,             FOR,EXIT
        byte    $20,"NEXT",     hd,             forNEXT,EXIT


        byte    $20,"INVERT",   hd,             INVERT,EXIT
        byte    $20,"AND",      hd,             _AND,EXIT
        byte    $20,"ANDN",     hd,             _ANDN,EXIT
        byte    $20,"OR",       hd,             _OR,EXIT
        byte    $20,"XOR",      hd,             _XOR,EXIT

        byte    $20,"ROL",      hd,             _ROL,EXIT
        byte    $20,"ROR",      hd,             _ROR,EXIT
        byte    $20,"SHR",      hd,             _SHR,EXIT
        byte    $20,"8>>",      hd,             _SHR8,EXIT
        byte    $20,"SHL",      hd,             _SHL,EXIT
        byte    $20,"8<<",      hd,             _SHL8,EXIT
        byte    $20,"2/",       hd,             _SHR1,EXIT
        byte    $20,"2*",       hd,             _SHL1,EXIT
        byte    $20,"REV",      hd,             _REV,EXIT
        byte    $20,"MASK",     hd,             MASK,EXIT
        byte    $20,">N",       hd,             toNIB,EXIT
        byte    $20,">B",       hd,             toBYTE,EXIT
        byte    $20,"9BITS",    hd,             NINEBITS,EXIT

        byte    $20,"0=",       hd,             ZEQ,EXIT
        byte    $20,"NOT",      hd,             ZEQ,EXIT
        byte    $20,"=",        hd,             EQ,EXIT
        byte    $20,">",        hd,             GT,EXIT

        byte    $20,"C@",       hd,             CFETCH,EXIT
        byte    $20,"W@",       hd,             WFETCH,EXIT
        byte    $20,"@",        hd,             FETCH,EXIT
        byte    $20,"C+!",      hd,             CPLUSST,EXIT
        byte    $20,"C!",       hd,             CSTORE,EXIT
        byte    $20,"C@++",     hd,             CFETCHINC,EXIT
        byte    $20,"W+!",      hd,             WPLUSST,EXIT
        byte    $20,"W!",       hd,             WSTORE,EXIT
        byte    $20,"+!",       hd,             PLUSST,EXIT
        byte    $20,"!",        hd,             STORE,EXIT
        byte    $20,"UM*",      hd,             UMMUL,EXIT
        byte    $20,"ABS",      hd,             _ABS,EXIT
        byte    $20,"-NEGATE",  hd,             MNEGATE,EXIT
        byte    $20,"?NEGATE",  hd,             QNEGATE,EXIT
        byte    $20,"NEGATE",   hd,             NEGATE,EXIT

        byte    $20,"CLOCK",    hd,             CLOCK,EXIT

'        byte    $20,"MPIN",     hd,     MPIN,EXIT
'        byte    $20,"H",        hd,     H,EXIT
'        byte    $20,"L",        hd,     L,EXIT

        byte    $20,"OUTSET",   hd,             OUTSET,EXIT
        byte    $20,"OUTCLR",   hd,             OUTCLR,EXIT
        byte    $20,"OUTPUTS",  hd,             OUTPUTS,EXIT

        byte    $20,"INPUTS",   hd,             INPUTS,EXIT
        byte    $20,"SHROUT",   hd,             SHROUT,EXIT
        byte    $20,"SHRINP",   hd,             SHRINP,EXIT


        byte    $20,"RESET",    hd,             RESET,EXIT
        byte    $20,"0EXIT",    hd,             ZEXIT,EXIT
        byte    $20,"EXIT",     hd,             EXIT,EXIT
        byte    $20,"NOP",      hd,              _NOP,EXIT
        byte    $20,"3DROP",    hd,             DROP3,EXIT
        byte    $20,"?DUP",     hd,             QDUP,EXIT
        byte    $20,"3RD",      hd,             THIRD,EXIT
        byte    $20,"4TH",      hd,             FOURTH,EXIT
        byte    $20,"CALL",     hd,             ACALL,EXIT
        byte    $20,"JUMP",     hd,             AJMP,EXIT
        byte    $20,"BRANCH>",  hd,             POPBRANCH,EXIT

        byte    $20,">R",       hd,             PUSHR,EXIT
        byte    $20,"R>",       hd,             RPOP,EXIT
        byte    $20,">L",       hd,             PUSHL,EXIT
        byte    $20,"L>",       hd,             LPOP,EXIT

        byte    $20,"REG",      hd,             ATREG,EXIT
        byte    $20,"(WAITPNE)",        hd,     _WAITPNE,EXIT

{ we don't really need to have the names of these codes in the dictionary - useful for a disassembler though
        byte    $20,"(XCALL)",  hd+pr,          XCALL,EXIT
        byte    $20,"(YCALL)",  hd+pr,          YCALL,EXIT
        byte    $20,"(ELSE)",   hd+pr,          _ELSE,EXIT
        byte    $20,"(IF)",     hd+pr,          _IF,EXIT
        byte    $20,"(UNTIL)",  hd+pr,          _UNTIL,EXIT
        byte    $20,"(AGAIN)",  hd+pr,          _AGAIN,EXIT
        byte    $20,"(REG)",    hd+pr,          REG,EXIT
        byte    $20,"(PUSH4)",  hd+pr,          PUSH4,EXIT
        byte    $20,"(PUSH3)",  hd+pr,          PUSH3,EXIT
        byte    $20,"(PUSH2)",  hd+pr,          PUSH2,EXIT
        byte    $20,"(_BYTE)",  hd+pr,          _BYTE,EXIT
        byte    $20,"(VAR)",    hd+pr,          VARB,EXIT
}
        byte    $20,"I",        hd,             I,EXIT
        byte    $20,"SPIWRB",   hd,             SPIWRB,EXIT
        byte    $20,"SPIWR16",  hd,             SPIWR16,EXIT
        byte    $20,"SPIWR",    hd,             SPIWR,EXIT
        byte    $20,"SPIRD",    hd,             SPIRD,EXIT
        byte    $20,"SPICE",    hd,             _SPICE,EXIT

        byte    $20,"(OPCODE)", hd,             OPCODE,EXIT

        byte    $20,"c",        hd,             PUSHX,EXIT
        byte    $20,"UM/MOD64", hd,             UMDIVMOD64,EXIT
        byte    $20,"UM/MOD32", hd,             UMDIVMOD32,EXIT
        byte    $20,"RUNMOD",   hd,             RUNMOD,EXIT

' Extended operation - accesses high 256 longs of VM cog

        byte    $20,"(WAITPEQ)", hd+xc+sq,      XOP,_WAITPEQ
        byte    $20,"CMOVE",    hd+xc+sq,       XOP,pCMOVE
        byte    $20,"(EMIT)",   hd+xc+sq,       XOP,pEMIT
        byte    $20,"(EMITX)",  hd+xc+sq,       XOP,pEMITX
        byte    $20,"CMPSTR",   hd+xc+sq,       XOP,pCMPSTR
        byte    $20,"LOADMOD",  hd+xc+sq,       XOP,pLOADMOD
        byte    $20,"COGID",    hd+xc+sq,       XOP,pCOGID
        byte    $20,"(COGINIT)",hd+xc+sq,       XOP,pCOGINIT
        byte    $20,"!RP",      hd+xc+sq,       XOP,pInitRP
        byte    $20,"COG@",     hd+xc+sq,       XOP,pCOGFETCH
        byte    $20,"COGREG",   hd+xc+sq,       XOP,pCOGREG
        byte    $20,"COG!",     hd+xc+sq,       XOP,pCOGSTORE
        byte    $20,"DELTA",    hd+xc+sq,       XOP,pDELTA
        byte    $20,"WAITCNT",  hd+xc+sq,       XOP,pWAITCNTS
        byte    $20,"LAP",      hd+xc+sq,       XOP,pLAP

'
' Two instruction sequences
'

'        byte    $20,"PIN",      hd+xc+sq,       MASK,MPIN
'        byte    $20,"OUTSET",   hd+xc+sq,       MPIN,H
'        byte    $20,"OUTCLR",   hd+xc+sq,       MPIN,L
        byte    $20,"FLOAT",    hd+xc+sq,       MASK,INPUTS
'        byte    $20,"OUTPUTS",  hd,     OUTPUTS,EXIT

        byte    $20,"NIP",      hd+xc+sq,       SWAP,DROP
        byte    $20,"ADO",      hd+xc+sq,       BOUNDS,DO
        byte    $20,"2+",       hd+xc+sq,       INC,INC
        byte    $20,"2-",       hd+xc+sq,       DEC,DEC
        byte    $20,"4*",       hd+xc+sq,       _SHL1,_SHL1
        byte    $20,"4/",       hd+xc+sq,       _SHR1,_SHR1
        byte    $20,"2DUP",     hd+xc+sq,       OVER,OVER
        byte    $20,"2OVER",    hd+xc+sq,       FOURTH,FOURTH
        byte    $20,"*",        hd+xc+sq,       UMMUL,DROP
        byte    $20,"0<>",      hd+xc+sq,       ZEQ,ZEQ
        byte    $20,"<>",       hd+xc+sq,       EQ,ZEQ
        byte    $20,"UM/MOD",   hd+xc+sq,       UMDIVMOD64,DROP
        byte    $20,"TUCK",     hd+xc+sq,       SWAP,OVER
        byte    $20,"CELLS",    hd+xc+sq,       _SHL1,_SHL1
        byte    $20,"-ROT",     hd+xc+sq,       ROT,ROT
' 160508 additions
        byte    $20,"9<<",      hd+xc+sq,       _SHL8,_SHL1
        byte    $20,"9>>",      hd+xc+sq,       _SHR8,_SHR1
        byte    $20,"16<<",     hd+xc+sq,       _SHL8,_SHL8
        byte    $20,"16>>",     hd+xc+sq,       _SHR8,_SHR8
' 160627
        byte    $20,"HIGH",     hd+xc+sq,       MASK,OUTSET
        byte    $20,"LOW",      hd+xc+sq,       MASK,OUTCLR


{ INTERPRETED BYTECODE HEADERS  }

        byte    $20,"LSTACK",   hd+xc,          XCALL,xLSTACK
        byte    $20,"SET",      hd+xc,          XCALL,xSET
        byte    $20,"CLR",      hd+xc,          XCALL,xCLR

        byte    $20,"!SP",      hd+xc,          XCALL,xInitStack
        byte    $20,"SP!",      hd+xc,          XCALL,xSPSTORE
        byte    $20,"DEPTH",    hd+xc,          XCALL,xDEPTH

        byte    $20,"(:)",      hd+xc,          XCALL,x_COLON

        byte    $20,":",        hd+xc+im,       XCALL,xCOLON
        byte    $20,"pub",      hd+xc+im,       XCALL,xPUBCOLON
        byte    $20,"pri",      hd+xc+im,       XCALL,xPRIVATE
        byte    $20,"UNSMUDGE", hd+xc+im,       XCALL,xUNSMUDGE

        byte    $20,"IF",       hd+xc+im,       XCALL,x_IF_
        byte    $20,"ELSE",     hd+xc+im,       XCALL,x_ELSE_
        byte    $20,"THEN",     hd+xc+im,       XCALL,x_THEN_
        byte    $20,"ENDIF",    hd+xc+im,       XCALL,x_THEN_
        byte    $20,"BEGIN",    hd+xc+im,       XCALL,x_BEGIN_
        byte    $20,"UNTIL",    hd+xc+im,       XCALL,x_UNTIL_
        byte    $20,"AGAIN",    hd+xc+im,       XCALL,x_AGAIN_
        byte    $20,"WHILE",    hd+xc+im,       XCALL,x_IF_
        byte    $20,"REPEAT",   hd+xc+im,       XCALL,x_REPEAT_
        byte    $20,";",        hd+xc+im,       XCALL,xENDCOLON

        byte    $20,"\",        hd+xc+im,       XCALL,xCOMMENT
        byte    $20,"''",       hd+xc+im,       XCALL,xCOMMENT
        byte    $20,"(",        hd+xc+im,       XCALL,xBRACE
        byte    $20,"{",        hd+xc+im,       XCALL,xCURLY
        byte    $20,"}",        hd+xc+im,       _NOP,EXIT
        byte    $20,"IFNDEF",   hd+xc+im,       XCALL,xIFNDEF
        byte    $20,"IFDEF",    hd+xc+im,       XCALL,xIFDEF
        byte    $20,$22,        hd+xc+im,       XCALL,x_STR_
        byte    $20,$2E,$22,    hd+xc+im,       XCALL,x_PSTR_           ' ."
        byte    $20,"(",$2E,$22,")",    hd+xc+im,       XCALL,xPRTSTR           ' (.")

        byte    $20,"TO",       hd+xc+im,       XCALL,xATO

        'byte   $20,"COMPILE",  hd+xc+im,       XCALL,xCOMPILE
        byte    $20,"BCOMP",    hd+xc+im,       XCALL,xBCOMP
        byte    $20,"C,",       hd+xc+im,       XCALL,xCCOMP
        byte    $20,"|",        hd+xc+im,       XCALL,xCCOMP
        byte    $20,"||",       hd+xc+im,       XCALL,xWCOMP
        byte    $20,",",        hd+xc+im,       XCALL,xLCOMP

        byte    $20,"BREAK",    hd+xc+im,       XCALL,xISEND
        byte    $20,"CASE",     hd+xc+im,       XCALL,xIS




        byte    $20,"SWITCH",   hd+xc,          XCALL,xSWITCH
        byte    $20,"SWITCH@",  hd+xc,          XCALL,xSWITCHFETCH
        byte    $20,"SWITCH=",  hd+xc,          XCALL,xISEQ
        byte    $20,"SWITCH><", hd+xc,          XCALL,xISWITHIN

        byte    $20,"STACKS",   hd+xc,          XCALL,xSTACKS
        byte    $20,"XCALLS",   hd+xc,          XCALL,xXCALLS
        byte    $20,"REBOOT",   hd+xc,          XCALL,xREBOOT
        byte    $20,"STOP",     hd+xc,          XCALL,xSTOP

        byte    $20,"[TX485]",  hd+xc,          XCALL,xTX485
        byte    $20,"[SERIN]",  hd+xc,          XCALL,xSERIN
        byte    $20,"[SSD]",    hd+xc,          XCALL,xSSD
        byte    $20,"[ESPIO]",  hd+xc,          XCALL,xESPIO
        byte    $20,"[BSPIWR]", hd+xc,          XCALL,xBSPIWR
        byte    $20,"[SPIO]",   hd+xc,          XCALL,xSPIO
        byte    $20,"[MCP32]",  hd+xc,          XCALL,xMCP32
        byte    $20,"[SDRD]",   hd+xc,          XCALL,xSDRD
        byte    $20,"[SDWR]",   hd+xc,          XCALL,xSDWR
        byte    $20,"[PWM32]",  hd+xc,          XCALL,xPWM32
        byte    $20,"[PWM32!]", hd+xc,          XCALL,xPWMST32
        byte    $20,"[PLOT]",   hd+xc,          XCALL,xPLOT
'       byte    $20,"[WAVE]",   hd+xc,          XCALL,xONEWAVE
        byte    $20,"[PLAYER]", hd+xc,          XCALL,xPLAYER
        byte    $20,"BCA",      hd+xc,          XCALL,xBCA
        byte    $20,"[WS2812]", hd+xc,          XCALL,xWS2812
        byte    $20,"[SQRT]",   hd+xc,          XCALL,xSQRT
        byte    $20,"[CAP]",    hd+xc,          XCALL,xCAP

'        byte    $20,"SAR",      hd+xc,          XJMP,xSAR

        byte    $20,"SET?",     hd+xc,          XCALL,xSETQ


        byte    $20,"U/",       hd+xc,          XCALL,xUDIVIDE
        byte    $20,"U/MOD",    hd+xc,          XCALL,xUDIVMOD
        byte    $20,"*/",       hd+xc,          XCALL,xMULDIV

        byte    $20,"0<",       hd+xc,          XCALL,xZLT
        byte    $20,"<",        hd+xc,          XCALL,xLT
        byte    $20,"U<",       hd+xc,          XCALL,xULT
        byte    $20,"WITHIN",   hd+xc,          XCALL,xWITHIN
        byte    $20,"?EXIT",    hd+xc,          XCALL,xIFEXIT

        byte    $20,"ERASE",    hd+xc,          XCALL,xERASE
        byte    $20,"FILL",     hd+xc,          XCALL,xFILL
        byte    $20,"ms",       hd+xc,          XCALL,xms
'       byte    $20,"us",       hd+xc,          XCALL,xus

        byte    $20,"READBUF",  hd+xc,          XCALL,xREADBUF
        byte    $20,"KEY",      hd+xc,          XCALL,xKEY
        byte    $20,"WKEY",     hd+xc,          XCALL,xWKEY
        byte    $20,"(KEY)",    hd+xc,          XCALL,xCONKEY

        byte    $20,"HEX",      hd+xc,          XCALL,xHEX
        byte    $20,"DECIMAL",  hd+xc,          XCALL,xDECIMAL
        byte    $20,"BINARY",   hd+xc,          XCALL,xBIN


        byte    $20,".S",       hd+xc,          XCALL,xPRTSTK
        byte    $20,"HDUMP",    hd+xc,          XCALL,xDUMP
        byte    $20,"COGDUMP",  hd+xc,          XCALL,xCOGDUMP

        byte    $20,".STACKS",  hd+xc,          XCALL,xPRTSTKS
        byte    $20,"DEBUG",    hd+xc,          XCALL,xDEBUG
        byte    $20,"EMIT",     hd+xc,          XCALL,xEMIT
        byte    $20,"CLS",      hd+xc,          XCALL,xCLS
        byte    $20,"SPACE",    hd+xc,          XCALL,xSPACE
        byte    $20,"BELL",     hd+xc,          XCALL,xBELL
        byte    $20,"CR",       hd+xc,          XCALL,xCR
        byte    $20,"SPINNER",  hd+xc,          XCALL,xSPINNER
        byte    $20,".HEX",     hd+xc,          XCALL,xPRTHEX
        byte    $20,".BYTE",    hd+xc,          XCALL,xPRTBYTE
        byte    $20,".WORD",    hd+xc,          XCALL,xPRTWORD
        byte    $20,".LONG",    hd+xc,          XCALL,xPRTLONG
        byte    $20,".",        hd+xc,          XCALL,xPRT
        byte    $20,">DIGIT",   hd+xc,          XCALL,xTODIGIT
        byte    $20,"NUMBER",   hd+xc,          XCALL,xNUMBER
        byte    $20,"SCRUB",    hd+xc,          XCALL,xSCRUB
        byte    $20,"GETWORD",  hd+xc,          XCALL,xGETWORD
        byte    $20,"SEARCH",   hd+xc,          XCALL,xSEARCH
        byte    $20,"FINDSTR",  hd+xc,          XCALL,xFINDSTR
        byte    $20,"NFA>BFA",  hd+xc,          XCALL,xNFABFA

        byte    $20,"EXECUTE",  hd+xc,          XCALL,xEXECUTE

        byte    $20,"VER",      hd+xc,          XCALL,xGETVER
        byte    $20,".VER",     hd+xc,          XCALL,xPRTVER
        byte    $20,"TACHYON",  hd+xc,          XCALL,x_TACHYON

        byte    $20,"@PAD",     hd+xc,          XCALL,xATPAD
        byte    $20,"HOLD",     hd+xc,          XCALL,xHOLD
        byte    $20,">CHAR",    hd+xc,          XCALL,xTOCHAR
        byte    $20,"#>",       hd+xc,          XCALL,xRHASH
        byte    $20,"<#",       hd+xc,          XCALL,xLHASH
        byte    $20,"#",        hd+xc,          XCALL,xHASH
        byte    $20,"#S",       hd+xc,          XCALL,xHASHS
        byte    $20,"<D>",      hd+xc,          XCALL,xDNUM
        byte    $20,"PRINT$",   hd+xc,          XCALL,xPSTR
        byte    $20,"LEN$",     hd+xc,          XCALL,xSTRLEN
        byte    $20,"U.",       hd+xc,          XCALL,xUPRT
        byte    $20,".DEC",     hd+xc,          XCALL,xPRTDEC
        byte    $20,"DISCARD",  hd+xc,          XCALL,xDISCARD
        byte    $20,"COGINIT",  hd+xc,          XCALL,xCOGINIT

        byte    $20,"<CMOVE",   hd+xc,          XCALL,xRCMOVE
        byte    $20,"lastkey",  hd+xc,          XCALL,xLASTKEY

' TASK REGISTERS
        byte  $20,"rx",         hd+xc,          REG,rxptr
        byte  $20,"flags",      hd+xc,          REG,flags
        byte  $20,"base",       hd+xc,          REG,base
        byte  $20,"digits",     hd+xc,          REG,digits
        byte  $20,"delim",      hd+xc,          REG,delim
        byte  $20,"@word",      hd+xc,          REG,wordbuf
        byte  $20,"switch",     hd+xc,          REG,uswitch
        byte  $20,"autorun",    hd+xc,          REG,autovec
        byte  $20,"keypoll",    hd+xc,          REG,keypoll
        byte  $20,"tasks",      hd+xc,          REG,tasks
        byte  $20,"unum",       hd+xc,          REG,unum                ' user number processing
        byte  $20,"uemit",      hd+xc,          REG,uemit
        byte  $20,"ukey",       hd+xc,          REG,ukey
        byte  $20,"names",      hd+xc,          REG,names
        byte  $20,"here",       hd+xc,          REG,here
        byte  $20,"codes",      hd+xc,          REG,codes
        byte  $20,"errors",     hd+xc,          REG,errors
        byte  $20,"baudcnt",    hd+xc,          REG,baudcnt
        byte  $20,"prompt",     hd+xc,          REG,prompt
        byte  $20,"ufind",      hd+xc,          REG,ufind               ' user find method
        byte  $20,"create",     hd+xc,          REG,createvec           ' user CREATE
        byte  $20,"lines",      hd+xc,          REG,linenum


        byte  $20,"ALLOT",      hd+xc,          XCALL,xALLOT
        byte  $20,"ALLOCATED",  hd+xc,          XCALL,xALLOCATED
        byte  $20,"HERE",       hd+xc,          XCALL,xHERE
        byte  $20,">VEC",       hd+xc,          XCALL,xTOVEC
        byte  $20,"BFA>CFA",    hd+xc,          XCALL,xBFACFA
        byte  $20,"[NFA']",     hd+xc,          XCALL,xNFATICK
        byte  $20,"[']",        hd+xc,          XCALL,xTICK
        byte  $20,"ERROR",      hd+xc,          XCALL,xERROR
        byte  $20,"NOTFOUND",   hd+xc,          XCALL,xNOTFOUND

' IMMEDIATE
        byte  $20,"NFA'",       hd+xc+im,       XCALL,x_NFATICK
        byte  $20,"'",          hd+xc+im,       XCALL,xATICK


' Building words
        byte  $20,"[COMPILE]",  hd+xc+im,       XCALL,xCOMPILES
        byte  $20,"GRAB",       hd+xc+im,       XCALL,xGRAB
        byte  $20,"LITERAL",    hd+xc+im,       XCALL,xLITCOMP

        byte  $20,"(CREATE)",   hd+xc,          XCALL,xCREATESTR
        byte  $20,"CREATEWORD", hd+xc+im,       XCALL,xCREATEWORD
        byte  $20,"CREATE",     hd+xc+im,       XCALL,xCREATE

        byte  $20,"TASK",       hd+xc,          XCALL,xTASK
        byte  $20,"IDLE",       hd+xc,          XCALL,xIDLE
        byte  $20,"LOOKUP",     hd+xc,          XCALL,xVECTORS
'       byte    $20,"VECTORS",  hd+xc,          XCALL,xVECTORS
        byte  $20,"+CALL",      hd+xc,          XCALL,xAddACALL
        byte  $20,"BUFFERS",    hd+xc,          XCALL,xBUFFERS
        byte  $20,"FREE",       hd+xc,          XCALL,xFREE
        byte  $20,"TERMINAL",   hd+xc,          XCALL,xTERMINAL
        byte  $20,"CONSOLE",    hd+xc,          XCALL,xCONSOLE
        byte  $20,"rxpars",     hd+xc,         XCALL,xRXPARS

        byte  $20,"V3",         hd,             _TRUE,EXIT                       ' used in IFDEF meta-compilations

'        byte  $20,"@VGA",       hd+xc,          XCALL,xVGA
        byte  $20,"KOLD",       hd+xc,          XCALL,xCOLDST           'renamed to avoid conflict
        byte  $20,"WORDS",      hd+xc,          XCALL,xWORDS

        byte  $20,"*end*",      hd+xc+sq,       _NOP,_NOP               ' dummy used to find the end


enddict byte    0,0,0   ' Mark the end of the kernel dictionary (2nd and 3rd byte is a pointer or null)



' align memory upwards to a 128 byte page to suit EEPROM backup as this area will not be backed-up (contains cog image)
aln0    byte    0[($80-(@aln0+s-((@aln0+s)&$FF80)))-8]



DAT { *** SERIAL RECEIVE *** }

'**************************************** SERIAL RECEIVE ******************************************

{ This is a dedicated serial receive routine that runs in it's own cog }

                        long 0[2]                       ' read and write        ' this hub space is used for rxwr & rxrd at runtime
rxbuffers                                               ' hub ram gets reused as the receive buffer
                        org

TachyonRx               mov     rxwr,#0                 ' init write index
                        wrword  rxwr,rxwrptr            ' clear rxrd in hub
                        wrword  rxwr,rxrdptr            ' make rxwr = rxrd
                        mov     rxpins,rxpin
                        or      rxpins,trpin
                        mov     stticks,rxticks
                        shr     stticks,#1
                        sub     stticks,#4
receive                 mov     rxdat,#0
                        waitpne rxpins,rxpins            ' wait for a low = start bit
                        test    rxpin,ina wz            ' test for console rx?
                if_nz   jmp     #pingpong
                        mov     rxcnt,stticks           ' Adjusted bit timing for start bit
                        add     rxcnt,cnt               ' uses special start bit timing
                        waitcnt rxcnt,rxticks
                        test    rxpin,ina       wz      ' sample middle of start bit
rxcond2         if_nz   jmp     #receive                ' restart if false start otherwise bit time from center

'
' START bit validated
' Read in data bits lsb first
' No point in looping as we have plenty of code to play with
' and inlining (don't call) and unrolling (don't loop) can lead to higher receive speeds
'
                        waitcnt rxcnt,rxticks           ' wait until middle of first data bit
                        test    rxpin,ina wc            ' sample bit 0
                        muxc    rxdat,#01              ' and assemble rxdata
                        waitcnt rxcnt,rxticks
                        test    rxpin,ina wc            ' sample bit 1
                        muxc    rxdat,#02
                        waitcnt rxcnt,rxticks
                        test    rxpin,ina wc            ' sample bit 2
                        muxc    rxdat,#04
                        waitcnt rxcnt,rxticks
                        test    rxpin,ina wc            ' sample bit 3
                        muxc    rxdat,#08
                        waitcnt rxcnt,rxticks
                        test    rxpin,ina wc            ' sample bit 4
                        muxc    rxdat,#$10
 ' data bit 5
                        waitcnt rxcnt,rxticks
                        test    rxpin,ina wc            ' sample bit 5
                        muxc    rxdat,#$20
                        mov     X1,rxbuf                ' squeeze in some overheads, calc write pointer
                        add     X1,rxwr                 ' X points to buffer location to store
' data bit 6
                        waitcnt rxcnt,rxticks
                        test    rxpin,ina wc            ' sample bit 6
                        muxc    rxdat,#$40
                        add     rxwr,#1                 ' update write index
                        and     rxwr,#$0FF
' last data bit 7
                        waitcnt rxcnt,rxticks
                        test    rxpin,ina wc            ' sample bit 7
                        muxc    rxdat,#$80
                        wrbyte  rxdat,X1               ' save data in buffer - could take 287.5ns worst case
' stop bit
stopins                 waitcnt rxcnt,rxticks           ' check stop bit early (need to detect errors and breaks)
                        test    rxpin,ina wc            ' sample stop bit
                if_c    wrword  rxwr,rxwrptr            ' update hub index for code reading the buffer if all good
                if_c    mov     breakcnt,#100           ' reset break count
                if_c    jmp     #receive
'
' Framing error - check if it's a null character as it may be part of a break condition
' 160722 update - any continous frame error character will eventually reset the Prop
' any normal character resets the count.
' Earlier versions would not reset it unless it received a normal framing char (improbable)
'
frmerror
                        sub     rxwr,#1
                        or      outa,rxpin
                        or      dira,rxpin              'unintentional? make sure the input is not floating
                        mov     rxcnt,#16
                        djnz    rxcnt,$
                        andn    dira,rxpin              'restore input and delay
                        mov     rxcnt,#16
                        djnz    rxcnt,$
                        test    rxpin,ina wz            'if it's still low then it is being intentionally driven
                if_nz   jmp     #receive                'ignore floating input
                        djnz    breakcnt,#receive
aboot
                        mov     rxcnt,#$80
                        clkset  rxcnt   ' reboot





DAT ' PING-PONG

pingpong
 			mov	rxcnt,pstticks	        ' Adjusted bit timing for start bit
 			add	rxcnt,cnt           	' uses special start bit timing
 			waitcnt	rxcnt,pticks
 			test	trpin,ina       wz      ' sample middle of start bit
		if_nz	jmp	#receive                ' restart if false start otherwise bit time from center
 			waitcnt	rxcnt,pticks	        ' wait until middle of first data bit
 			test	trpin,ina wc	        ' sample bit 0
 			muxc	rxdat,#01	        ' and assemble prxdat
 			waitcnt	rxcnt,pticks
 			test	trpin,ina wc	        ' sample bit 1
 			muxc	rxdat,#02
 			waitcnt	rxcnt,pticks
 			test	trpin,ina wc            ' sample bit 2
 			muxc	rxdat,#04
 			waitcnt	rxcnt,pticks
 			test	trpin,ina wc	        ' sample bit 3
 			muxc	rxdat,#08
 			waitcnt	rxcnt,pticks
 			test	trpin,ina wc	        ' sample bit 4
 			muxc	rxdat,#$10
' data bit 5
			waitcnt	rxcnt,pticks
 			test	trpin,ina wc	        ' sample bit 5
 			muxc	rxdat,#$20
 			mov	X1,rxbuf	        ' squeeze in some overheads, calc write pointer
 			add	X1,rxwr	                ' X points to buffer location to store
' data bit 6
 			waitcnt	rxcnt,pticks
 			test	trpin,ina wc	        ' sample bit 6
 			muxc	rxdat,#$40
' last data bit 7
 			waitcnt	rxcnt,pticks
 			test	trpin,ina wc	        ' sample bit 7
 			muxc	rxdat,#$80
 			wrbyte	rxdat,X1	        ' save data in buffer - could take 287.5ns worst case
' stop bit
			waitcnt	rxcnt,pticks	        ' check stop bit early (need to detect errors and breaks)
 			test	trpin,ina wc	        ' sample stop bit
		if_nc	jmp	#pfrmerr	        ' framing error - check for break - disregard timing now

'
' MULTIDROP ADDRESS CHECK
'
 			mov	rxchk,rxdat             ' $80..$FF?
                        and     rxchk,#$FF
 			sub	rxchk,#$80 wc	        ' if 8-bit high address detected then firstly disable rx pass
                if_nc   jmp     #multidrop
                        tjz     rxon,#receive           ' discard receive data as unit is not selected
' UPDATE BUFFER
                        and     rxdat,#$FF wz           ' don't buffer if it's a null
 		if_nz	add	rxwr,#1	                ' update write index
                        and     rxwr,#$0FF
	        if_nz   wrword	rxwr,rxwrptr	        ' update hub index for code reading the buffer if all good
                        tjz     txon,#receive
                        call    #pptx                   ' ping-pong a character back
 			jmp	#receive
'
' process address/control character
'
multidrop
 		        mov	rxon,#0                 ' Yes, address, disable this receiver for the moment
 		        mov	txon,#0                 ' and the transmitter
 			cmp	rxdat,myadr wz          ' enable if this unit selected
                if_z    jmp     #selected               ' ok then, just check for group or global
			cmp	rxdat,#_gbl wz          ' Global?
 		if_z	mov	rxon,rxdat              ' enable - but rxon is set to global address
                        rdbyte  x1,myadrptr             ' read the group address from hub mem (app updateable)
                        cmp     rxdat,x1 wz             ' same group?
                if_z    mov     rxon,rxdat
                        wrbyte  txon,emitflg            ' signal app EMIT to synch if pingpong transmit is enabled
 			jmp	#receive
selected
		  	mov	rxon,myadr	        ' indicate that it is only this unit responding (rxon = myadr)
		   	mov	txon,myadr	        ' and transmitter
                        mov     txdat,myadr
                        wrbyte  txon,emitflg            ' signal app EMIT to synch if pingpong transmit is enabled
                        call    #pptx1
                        jmp     #receive                ' skip these other checks if selected


' 65hvd75 transceiver has a bad low glitch for up to 600ns after TE is release - delay before sending so other end doesn't miss data
pptx                    rdbyte  txdat,emitptr wz        ' single byte
              if_nz     wrbyte  txclr,emitptr           ' only clear if it's non-zero (in case hl is accessing it)
pptx1                   or      outa,tepin              ' enable transmitter
                        or      dira,tepin
                        or      dira,trpin              ' mask tr a transmit outout (along with te)
                        add     txdat,#$100 wc          ' add a stop bit (carry = start bit)
                        mov     rxcnt,cnt
                        add     rxcnt,pticks
                        waitcnt rxcnt,pticks            ' additional 1-bit idle for rx to tx deglitch
ptxb                    muxc    outa,trpin              ' output bit
                        shr     txdat,#1 wz,wc          ' lsb first
                        waitcnt rxcnt,pticks            ' bit timing
        if_nz_or_c      jmp     #ptxb                   ' next bit (stop bit: z & c)
                        andn    dira,trpin              ' float data line back to receive
                        andn    outa,tepin              ' Turn line back to receive
pptx1_ret
pptx_ret                ret

' Framing error - check if it's a null character as it may be part of a break condition
'
pfrmerr
 			cmp	rxdat,#0 wz	        ' if it's a null it could be part of a break
		if_nz	sub	rxwr,#1
 		if_nz	mov	breakcnt,#100	        ' reset the break count (compromise here to keep main loop tight)
		if_nz	jmp     #receive	        ' ignore normal framing error
 			djnz	breakcnt,#receive
 			mov	rxcnt,#$80
 			clkset	rxcnt	                ' reboot


_rxpars
' CONSOLE
rxpin                   long    |<rxd                   ' mask of rx pin
rxticks                 long    sysfreq/baud
stticks                 long    ((sysfreq/baud)/2)-4
' NETWORK
myadr                   long    0 '$87
trpin                   long    0 '|<14
tepin                   long    0 '|<15
pticks                  long    (sysfreq / 1000000 )
pstticks                long    ((sysfreq/1000000)/2)-4
txon                    long    0
rxon                    long    0

emitptr                 long    emitreg+registers
emitflg                 long    emitreg+registers+3

rxbuf                   long    @rxbuffers+s            ' pointer to rxbuf in hub memory
rxwrptr                 long    @rxbuffers+s-2          ' word address of rxwr in hub (after init)
rxrdptr                 long    @rxbuffers+s-4          ' ptr to rxrdin hub
myadrptr                long    @rxbuffers+s-6
breakcnt                long    100
txclr                   long    0
rxdat                   long    0

rxpins                  res     1
txdat                   res     1
rxcnt                   res     1
lastch                  res     1
x1                      res     1
rxchk                   res     1
rxwr                    res     1                       'cog receive buffer write index - copied to hub ram


end                     res     0


{ CONTROL CHARACTER ASSIGNMENTS
00 ^@   NULL
01 ^A   ABORT AUTOSTART
02 ^B   BLOCK DUMP MEMORY
03 ^C   CANCEL
04 ^D   DEBUG
05 ^E
06 ^F
07 ^G   BELL
08 ^H   BS
09 ^I   TAB
0A ^J   LF
0B ^K
0C ^L
0D ^M   CR
0E ^N
0F ^O
---
10 ^P
11 ^Q
12 ^R
13 ^S
14 ^T
15 ^U
16 ^V
17 ^W
18 ^X   EXECUTE AGAIN
19 ^Y
1A ^Z   COLD START (^Z^Z)
1B ^[   ESC
1C ^\
1D ^]
1E ^^
1F ^_
}

{
' Roundabout way in Spin compiler to align this area to the next 256 byte boundary for filesystem buffers
' This will not be backed up into EEPROM as it contains the kernel image in EEPROM
aln1    byte    0[$100-(@aln1+s-((@aln1+s)&$FF00))]
}








{
***************************************
************* COG IMAGE & BUFFERS *************
***************************************
}


{ TACHYON VM - COG KERNEL (PASM) }

DAT { *** TACHYON KERNEL *** }

{{
Byte tokens directly address code in the first 256 longs of the cog.
A two byte-code instruction XOP allows access to the second 256 longs
Rather than a jump table most functions are short or cascaded to optimize COG memory
Larger fragments of code jump to the second half of the cog's memory.
As a result of not using a jump table (there's not enough memory) there are gaps
in the bytecode values and not all values are usable.

A call and return takes 2us
}}

                        org     0

RESET                   mov     IP,PAR                  ' Load the IP with the address of the first instruction as if it were an XOP

' position XOP here so that any search for an address of an XOP word returns with the correct cog address of $01xx
' Use next byte as an opcode that directly addresses top 256 words of cog
XOP                     rdbyte  instr,IP                ' get next bytecode
                        or      instr,#$100             ' shift range
                        jmp     #doNext+1               ' IP++, execute

' Bill Henning's LMM loop - testing usage
' LMM is an opcode which is placed before a long boundary which contains LMM PASM code,
' use jmp unext to return to Tachyon's loop (' NOP COG@ )
' or change unext to point to LMM so LMM can jmp to Tachyon opcodes and yet still return to LMM
LMM                     rdlong  instr,IP
                        add     IP,#4
instr                   nop
                        jmp     #lmm

' Find the end of the string which could end in a null or any characeter >$7F
' this is also used to find the end of a larger text buffer
' STREND ( ptr -- ptr2 )
STREND
fchlp                   rdbyte  R0,tos                  ' read a byte
                        sub     R0,#1                   ' end is either a null or anything >$7F
                        cmp     R0,#$7E wc
              if_c      add     tos,#1
              if_c      jmp     #fchlp
                        jmp     unext


' 0EXIT ( flg -- ) Exit if flg is false (or zero)  Used in place of IF......THEN EXIT as false would just end up exiting
ZEXIT                   call    #POPX
                        tjnz    X,unext
'
' EXIT a bytecode definition by popping the top of the return stack into the IP
EXIT                    call    #RPOPX                  ' Pop from return stack into X
JUMPX                   mov     IP,X                    ' update IP
_NOP                    jmp     unext                   ' continue

{ *** STACK OPERATORS *** }

' DROP3 ( n1 n2 n3 -- )  Pop the top 3 items off the datastack and discard them (used mostly by cog kernel) - 1.8us
DROP3                   call    #POPX
' DROP2 ( n1 n2 -- )  Pop the top 2 items off the datastack and discard them - 1.4us
DROP2                   call    #POPX
' 800ns execution time including bytecode read and execute
' DROP ( n1 -- )  Pop the top item off the datastack and discard it
DROP                    call    #POPX
                        muxc    X,#1                    ' save carry in X - use "c"  to retrieve
                        jmp     unext

' ?DUP ( n1 -- n1 n1 | 0 ) DUP n1 if non-zero - 1us/1,2us or 400ns
QDUP                    tjz     tos,unext
' DUP ( n1 - n1 n1 ) Duplicate the top item on the stack - 1us
DUP                     mov     X,tos                   ' Read directly from the top of the data stack
PUSHX                   call    #_PUSHX                 ' Push the internal X register onto the datastack
                        jmp     unext

' OVER ( n1 n2 -- n1 n2 n1 ) - 1us
OVER                    mov     X,tos+1                 'read second data item and push
                        jmp     #PUSHX
' 3RD ( n1 n2 n3 -- n1 n2 n3 n1 ) Copy the 3rd item onto the stack
THIRD                   mov     X,tos+2                 ' read third data item
                        jmp     #PUSHX
' 4TH ( n1 n2 n3 n4 -- n1 n2 n3 n4 n1 ) Copy the 4th item onto the stack - 1.2us
FOURTH                  mov     X,tos+3
                        jmp     #PUSHX

' BOUNDS ( n1 n2 -- n2+n1 n1 ) == OVER + SWAP - 600ns
BOUNDS                  add     tos,tos+1
' SWAP ( n1 n2 -- n2 n1 ) Swap the top two items
SWAP                    mov     X,tos+1
SWAPX                   mov     tos+1,tos
PUTX                    mov     tos,X
                        jmp     unext
' ROT ( a b c -- b c a )
ROT                     mov     X,tos+2
                        mov     tos+2,tos+1
                        jmp     #SWAPX


{ *** ARITHMETIC *** }
' - ( n1 n2 -- n3 ) Subtract n2 from n1
MINUS                   neg     tos,tos ' (note: save one long by negating and adding)
' + ( n1 n2 -- n3 ) Add top two stack items together and replace with result
PLUS                    add     tos+1,tos wc
                        jmp     #DROP

' 1- ( n1 -- n1-1 )
DEC                     test    $,#1 wc
' 1+ ( n1 -- n1+1 )
INC                     sumc    tos,#1          ' inc or dec depending upon carry (default cleared by doNEXT)
                        jmp     unext


' -NEGATE ( n1 sn -- n1 | -n1 ) negate n1 if the sign of sn is negative (used in signed divide op)
MNEGATE                 shr     tos,#31
 ' ?NEGATE ( n1 flg -- n2 ) negate n1 if flg is true
QNEGATE                 tjz     tos,#DROP
                        call    #POPX
' NEGATE ( n1 -- n2 )  equivalent to  n2 = 0-n1
NEGATE                  neg     tos,tos
                        jmp     unext

{
NIP                     mov     tos+1,tos
                        jmp     #DROP
}

{ *** BOOLEAN *** }

' 400ns execution time including bytecode read and execute
' INVERT ( n1 -- n2 ) bitwise invert n1 and replace with result n2
INVERT                  add     tos,#1
                        jmp     #NEGATE
{
_BITS                   test    $,#1 wc ' set carry
                        rcl     ACC,tos
                        and     tos+1,ACC
                        jmp     #DROP
}
_AND                    and     tos+1,tos
                        jmp     #DROP
_ANDN                   andn    tos+1,tos
                        jmp     #DROP
_OR                     or      tos+1,tos
                        jmp     #DROP
_XOR                    xor     tos+1,tos
                        jmp     #DROP
' 1.2us execution time including bytecode read and execute
' SHR ( n1 cnt -- n2 ) Shift n1 right by count (5 lsbs )
_SHR                    shr     tos+1,tos
                        jmp     #DROP
_SHL                    shl     tos+1,tos
                        jmp     #DROP
_ROL                    rol     tos+1,tos
                        jmp     #DROP
_ROR                    ror     tos+1,tos
                        jmp     #DROP

_SHR8                   shr     tos,#7
' 400ns execution time including bytecode read and execute
' 2/ ( n1 -- n1 ) shift n1 right one bit (equiv to divide by 2)
_SHR1                   shr     tos,#1
                        jmp     unext
_SHL8                   shl     tos,#7
' 2* ( n1 -- n2 ) shift n1 left one bit (equiv to multiply by 2)
_SHL1                   shl     tos,#1
                        jmp     unext

' REV ( n1 bits -- n2 ) Reverse LSBs of n1 and zero-extend
_REV                    rev     tos+1,tos
                        jmp     #DROP

' 400ns execution time including bytecode read and execute
' MASK ( bitpos -- bitmask  \ only the lower 5 bits of bitpos are taken, regardless of the higher bits )
MASK                    mov     X,tos
                        mov     tos,#1
                        shl     tos,X
                        jmp     unext

' >N ( n -- nibble ) mask n to a nibble
toNIB                   and     tos,#$0F
' >B ( n -- nibble ) mask n to a byte
toBYTE                  and     tos,#$FF
NINEBITS                and     tos,#$1FF
                        jmp     unext


{ *** COMPARISON *** }

' Basic instructions from which other comparison instructions are built from

' = ( n1 n2 -- flg ) true if n1 is equal to n2
EQ                      sub     tos+1,tos               ' n1 == 0 if equal
                        call    #POPX   ' drop n2
'                       -------------
' 0= ( n1 -- flg ) true if n1 equals 0 - same as a boolean NOT where TRUE becomes FALSE
_NOT
ZEQ                     cmp     tos,#1 wc               ' kuroneko method, nice and neat
SETZ                    subx    tos, tos                ' a carry becomes -1, else 0
                        jmp     unext

' > ( n1 n2 -- flg ) true if n1 > n2
GT                      cmps    tos,tos+1  wc           ' n1 > n2: carry set
                        subx    tos+1,tos+1
                        jmp     #DROP

{ *** MEMORY *** }

' C@++  ( caddr -- caddr+1 byte ) fetch byte character and increment address
CFETCHINC               mov     X,tos                   ' dup the address
                        call    #_PUSHX
                        add     tos+1,#1                ' inc the backup address
' C@  ( caddr -- byte ) Fetch a byte from hub memory
CFETCH                  rdbyte  tos,tos
                        jmp     unext

' W@  ( waddr -- word ) Fetch a word from hub memory
WFETCH                  rdword  tos,tos
                        jmp     unext

' @  ( addr -- long ) Fetch a long from hub memory
FETCH                   rdlong  tos,tos
                        jmp     unext

' C+!  ( n caddr -- ) add n to byte at hub addr
CPLUSST                 rdbyte  X,tos                   ' read in word from adress
                        add     tos+1,X                 ' add to contents of address - cascade
' C!  ( n caddr -- ) store n to byte at addr
CSTORE                  wrbyte  tos+1,tos               ' write the byte using address on the tos
                        jmp     #DROP2

' W+!  ( n waddr -- ) add n to word at hub addr
WPLUSST                 rdword  X,tos                   ' read in word from address
                        add     tos+1,X
' W!  ( n waddr -- ) store n to word at addr
WSTORE                  wrword  tos+1,tos
                        jmp     #DROP2

' +!  ( n addr -- ) add n to long at hub addr
PLUSST                  rdlong  X,tos                   ' read in long from address
                        add     tos+1,X
' !  ( n addr -- ) store n to long at addr
STORE                   wrlong  tos+1,tos
                        jmp     #DROP2

{
' BIT! ( mask caddr state -- ) Set or clear bit(s) in hub byte
'BIT                    call    #POPX
'                       tjz     X,#CLR  ' carry clear, finalize
' SET ( mask caddr -- ) Set bit(s) in hub byte
SET                     test    $,#1  wc        ' set the carry flag
' Finalize the bit operation by read/writing the result
' ( mask caddr -- )
CLR                     rdbyte  X,tos   ' Read the contents of the memory location
                        muxc    X,tos+1 ' set or clear the bit(s) specd by mask
                        wrbyte  X,tos   ' update
                        jmp     #DROP2

}
{ *** LITERALS *** }

' LITERALS are stored unaligned in big endian format which faciliates cascading byte reads to accumulate the full number

' 3.4us execution time including bytecode read and execute
' ( -- 32bits ) Push a 32-bit literal onto the datastack by reading in the next 4 bytes (non-aligned)
_LONG
PUSH4                   call    #ACCBYTE                ' read the next byte @IP++ and shift accumulate
' 2.8us execution time including bytecode read and execute
' ( -- 24bits ) Push a 24-bit literal onto the datastack by reading in the next 3 bytes (non-aligned)
PUSH3                   call    #ACCBYTE
' 2.2us execution time including bytecode read and execute
' ( -- 16bits) Push a 16-bit literal onto the datastack by reading in the next 2 bytes (non-aligned)
_WORD
PUSH2                   call    #ACCBYTE
' 1.6us execution time including bytecode read and execute
' ( -- 8bits ) Push an 8-bit literal onto the datastack by reading in the next byte
_BYTE
PUSH1                   call    #ACCBYTE
PUSHACC                 call    #_PUSHACC               ' Push the accumulator onto the stack then zero it
                        jmp     unext

{ *** FAST CONSTANTS *** }

' Push a preset literal onto the stack using just one bytecode
' Use the "accumulator" to push the value which is built up by incrementing and/or decrementing
' There is a minor penalty for the larger constants but it's still faster and more compact
' overall than using the _BYTE method or the mov X,# method

' 140606 just reordered to 1 4 2 3 according to BCA results
' 140603 new method to allow any value in any order, relies on carry being cleared in doNEXT and min will always set carry here

BL      if_nc           min     ACC,#32+1 wc    ' 1.4us
_16     if_nc           min     ACC,#16+1 wc
_8      if_nc           min     ACC,#8+1 wc
_4      if_nc           min     ACC,#4+1 wc     ' 1.2us
_2      if_nc           min     ACC,#2+1 wc
_1      if_nc           min     ACC,#1+1 wc
_3      if_nc           min     ACC,#3+1 wc     ' bytecode analysis reveals 3 is used quite heavily
_TRUE
MINUS1                  sub     ACC,#1
_FALSE
_0                      jmp     #PUSHACC        ' 1us + 200ns if depth >4

' NOTE! CONL must follow _0 as not header is available for CONL --> ' 0 1+

{ *** CONSTANTS & VARIABLES *** }
{HELP CONL
Constants and variables etc are standalone fragments preceded by an opcode then the parameters, either a long or the addess of the parameter field. They are called from the main program and only use the IP to get the result.
}
' Long aligned constant - created with CONSTANT and already aligned
CONL
                        rdlong  X,IP            ' get constant
                        jmp     #PUSHX_EXIT

' Byte aligned variables start with this single byte code which returns with the address of the byte variable following
' long variables just externally align this opcode a byte before the boundary
' INLINE:
VARB                    mov     X,IP
PUSHX_EXIT              call    #_PUSHX         ' push address of variable
                        jmp     #EXIT

' OPCODE assumes that a long aligned long follows which contains the 32-bit opcode.
OPCODE                  rdlong  opc,IP  ' read the long that follows (just like a constant)
                        nop                     ' pipeline delay
opc                     nop                     ' execute the opcode
                        jmp     #EXIT           ' return back to caller


{ *** I/O ACCESS *** }
{ not used - removed to extensions using COG@ COG!
' P@ ( -- n1 ) Read the input port A (assume it is always A for Prop 1)
PFETCH                  mov     X,INA
                        jmp     #PUSHX
' P! ( n1 -- ) Store n1 to the output port A
PSTORE                  mov     OUTA,tos
                        jmp     #DROP

}

{
' MPIN ( mask -- ) - use MASK MPIN as PIN word
MPIN                    mov     pinreg,tos
                        jmp     #DROP
' Using PIN/MPIN word to select a pin we can H and L at 400ns intervals
H                       or      outa,pinreg
                        or      dira,pinreg
                        jmp     unext
L                       andn    outa,pinreg
                        or      dira,pinreg
                        jmp     unext

' OUTSET becomes MPIN,H
' OUTCLR becomes MPIN,L

}

' OUTCLR ( iomask -- ) Clear multiple bits on the output
OUTCLR                  andn    OUTA,tos
                        jmp     #OUTPUTS
' OUTMASK ( data iomask -- )
'                       call    #POPX
'                        andn    OUTA,X  ' clear all iomask outputs
' OUTSET ( iomask -- ) Set multiple bits on the output
OUTSET                  or      OUTA,tos
 ' OUTPUTS ( iomask -- ) Set selected port pins to outputs
OUTPUTS                 or      DIRA,tos
                        jmp     #DROP


' INPUTS ( iomask -- ) Set selected port pins to inputs
INPUTS                  andn    DIRA,tos
                        jmp     #DROP


' WAITPNE       Wait until input is low - REG3 = mask, REG0 = CNT
_WAITPNE
                        waitpne reg3,reg3               ' use COGREG3 as the mask
                        mov     reg0,cnt                ' capture count in COGREG0
                        jmp     unext


{ WAITPNE with timeout - mask in reg3
' Usage: #P4 MASK 3 COGREG! #50,000 WLOW IF <timeout out> THN
' WLOW ( timeout -- rem )
wfp                     test    reg3,ina wz             ' look for low on pin (reg3 mask)
        if_nz           djnz    tos,#wfp                ' otherwise keep checking and continue counting down
                        jmp     unext                   ' either pin is low or it's timed out
}
{ *** SERIAL I/O OPERATORS *** }
{
To maximize the speed of I/O operations especially serial I/O such as ASYNCH, I2C and SPI etc there are special
operators that avoid pushing and popping the stack and instead perform the I/O bit by bit and leave the
latest shifted version of the data on the stack.
}

' SHIFT from INPUT - Assembles with last bit received as msb - needs SHR to right justify if asynch data
' SHRINP ( iomask dat -- iomask dat/2 )
SHRINP                  test    tos+1,INA wc
                        rcr     tos,#1
                        jmp     unext


{ SHIFT to OUT -
This is optimized for when you are sending out multiple bits as in asynchronous serial data or I2C
Shift data one bit right into output via iomask - leave mask & shifted data on stack (looping)
400ns execution time including bytecode read and execute  or 200ns/bit with REPS }
' SHROUT ( iomask dat -- iomask dat/2 )
SHROUT                  shr     tos,#1 wc               ' Shift right and get lsb
                        muxc    OUTA,tos+1              ' reflect state to output
                        jmp     unext

' CLOCK ( COGREG4=iomask ) Toggle multiple bits on the output)
CLOCK                   xor     OUTA,clockpins
                        jmp     unext



{ *** SPI *** }
' SPI INSTRUCTIONS
{HELP SPIWR ( data -- data2 )
Simple fast, bare-bones SPI - transmits 8 bits MSB first
- data must be left justified - data is not discarded but rotated by number of shift operations used
- spicnt is normally zero after the last shift so some ops just add to zero to save a long or two.
Usage: $1234 SPIWR16 'transmit 16 bits
SPIWR ( data -- data<<8 ) send the MSByte
SPIWRB ( data -- data<<8 ) send the LSByte
SPIWR16 ( data -- data<<16 ) send the LSWord
SPIWRX permits variable number of bits if spicnt is set directly with @SPICNT COGREG! and those bits are shifted to MSBit before
}
SPIWR16                 rol     tos,#24                 '
                        mov     spicnt,#8               ' force a 16-bit transfer
SPIWRB                  rol     tos,#24                 ' left justify and write byte to SPI (2.8us)
SPIWR                   add     spicnt,#8               ' code execution time of 2.25us + overhead
SPIWRX                  andn    outa,spice              ' always activate the chip enable (saves time in HL)
                        rol     tos,#1 wc               ' assume msb first (140208 update now rotates)
SPIwrlp                 muxc    OUTA,spiout             ' send next bit of data out
                        xor     OUTA,spisck             ' toggle clock
                        rol     tos,#1 wc               ' (no room) 160608 inserts rol here to spread clock width at same rate
                        xor     OUTA,spisck             ' toggle clock
                        djnz    spicnt,#SPIwrlp
                        ror     tos,#1                  ' reset it
                        jmp     unext



' Receive data and shift into existing stack parameter
' If MOSI needs to be in a certain state then this should be set beforehand
' Clock will simply pulse from it's starting state - normally low
' Useage:  0 SPIRD SPIRD SPIRD SPIRD                    ' read 32-bits as one long
' SPIRD ( data -- data<<8 )                             ' 2.8us
SPIRD                   mov     spicnt,#8               ' always read back 8-bits
SPIRDX                  andn    outa,spice              ' always activate the chip enable (saves time in HL)
SPIrdlp                 xor     OUTA,spisck             ' toggle clock
                        test    spiinp,INA wc           ' read data from device
                        rcl     tos,#1
                        xor     OUTA,spisck             ' toggle clock
                        djnz    spicnt,#SPIrdlp
                        jmp     unext

' SPICE
_SPICE                  or      outa,spice              ' release chip enable
                        jmp    unext


' I ( -- index ) The current loop index is at a fixed address just under the loop limit at top of an ascending loop stack
I                       mov     X,loopstk+1
                        jmp     #PUSHX


{ *** BRANCH & LOOP *** }


' ACALL ( adr -- ) Call arbitrary (from the stack) address - used to execute user vectors
ACALL                   call    #SAVEIP                 ' save current IP onto return stack
AJMP                    mov     IP,tos                  ' jump to address on top of the data stack
                        jmp     #DROP

{ 16-bit absolute inline call
used when vector table is exhausted so references then become direct, but normally only when the system is already fully packed.
}
CALL16                  call    #GETBYTE                ' read high byte
                        mov     R1,X
                        shl     R1,#8
                        call    #SETUPIP                ' read low byte and push IP
                        or      X,R1
                        mov     IP,X
                        jmp     unext



{  VECTOR TABLE ACCESS
 Since Tachyon uses bytecodes for instructions it also uses bytes to address code.
 Since bytes are limited to 256 values these are used instead to lookup the absolute address of the code
 from a table of vectors. To extend that beyond 256 values there are further opcodes which index the  table for a total of 1,024 vectors.

 Vectored call instructions form a 10-bit index with the upper 2 bits derived from the instruction so calls to other words only use 2 bytes total
Note: Originally there was only an XCALL but new opcodes were added to expand the vector table  however the compiled kernel only uses XCALL
}
'VCALL                   mov     ACC,#2                  ' high word of upper page
'ZCALL                   add     ACC,zcalls              ' low word of upper page

' Perform a call to kernel bytecode via the XCALLS but reusing the high word of each vector
' The YCALLs are implemented by the runtime compiler to fully utilize the XCALLs table (high word of longs)
YCALL                   add     ACC,#2
' Inline call to kernel bytecode via the XCALLS vector table using the following inline byte as an index
XCALL                   add     ACC,Xptr                ' ACC = vector table offset ( lopage,loword -> hipage,hiword)
                        call    #SETUPIP                ' Save IP and read next bytecode into X (offset in table)
                        shl     X,#2                    ' offset into longs in hub RAM
                        add     X,ACC                   ' Add to vector table base,now points to vector
                        rdword  IP,X                    ' Load IP with vector, now points to bytecode
ACC0                    mov     ACC,#0                  ' Always clear ACC to zero ready for reuse (repos for hub access)
                        jmp     unext

' Read the next byte as a negative displacement and jump back
_AGAIN
                        test    $,#1 wc                 ' setc for negative displacement
' Jump forward by reading the next byte inline and adding that to the IP (at that point)
JUMP
_ELSE                   call    #GETBYTE                ' read the forward displacement byte
                        sumc    IP,X                    ' jump to that forward location
                        jmp     unext


' If flg is zero than jump forward by reading the next byte inline and adding that to the IP (at that point)
' IF R( flg -- )
' Read the next byte as a positive displacement and branch forward
JZBACK
_UNTIL                  test    $,#1 wc 'set carry for negative branch
JZ
_IF                     call    #GETBYTE                'read in next byte at IP and inc IP
JMPIF                   tjnz    tos,#DROP               'test flag on stack - if non-zero then discard the branch
                        sumc    IP,X                    'Adjust IP forward according to flag
                        jmp     #DROP                   'discard flag
{
' ADO = BOUNDS DO - just a quick and direct way as BOUNDS is most often never used elsewhere
' ADO ( from cnt -- )
ADO                     mov     X,tos+1
                        add     tos+1,tos
                        mov     tos,X
}
' DO ( to from -- )
DO                      call    #_PUSHLP                ' PUSH index onto loop stack
 ' FOR ( count -- ) Setup FOR...NEXT loop for count
FOR                     call    #_PUSHBRANCH            ' Push the IP onto the branch stack and setup loop count
' >L ( n -- ) Push n onto the loop stack
PUSHL                   call    #_PUSHLP
                        jmp     unext

' L> ( -- n ) Pop n from the loop stack
LPOP                    call    #LPOPX  ' Pop loop stack into X
                        jmp     #PUSHX  ' Push X onto the data stack as tos

{HELP +LOOP ( n1 -- )
DESC: adds n1 to the loop index and branches back if not equal to the loop limit
}
PLOOP                   jmpret  POPX_ret,pDELTA wc      ' DELTA calls POPX
' The comparison above is between the call insn (wr) at DELTA and the jump insn (nr) at POPX_ret,
' this will always be carry set. The call itself is indirect.

' 400ns execution time including bytecode read and execute
{HELP (LOOP)
DESC: increment the loop index and branch back to after DO if not equal to loop limit
}
LOOP    if_nc           mov     X,#1                    ' default loop increment of 1
                        add     loopstk+1,X             ' increment index
                        cmps    loopstk,loopstk+1 wz,wc
BRANCH  if_a            mov     IP,branchstk            ' Branch to the address that is saved in branch
        if_a            jmp     unext
                        jmpret  LPOPX_ret,forNEXT+1 wc  ' discard top of loop stack index
                                                        ' then discard next loop and its branch address too

' The call above borrows an indirect jump target from the call #LPOPX following the djnz at forNEXT.
' IOW it's equivalent to a jmpret LPOPX_ret, #LPOPX or call #LPOPX (ignoring flag update).

' Average execution time = 400ns
' NEXT ( -- ) Decrement count (on loop stack) and loop until 0, then pop loop stack
forNEXT         if_nc   djnz    loopstk,#BRANCH wc,wz   ' not done yet, jump to branch
                        call    #LPOPX
' POPBRANCH - pops the branch stack manually (use if forcing an exit from a stacked branch)
POPBRANCH               call    #_POPBRANCH
                        jmp     unext



{HELP >R ( n -- ) Push n onto the return stack }
PUSHR                   mov     R0,tos
                        call    #_PUSHR
                        jmp     #DROP

{HELP R> ( -- n ) Pop n from the return stack }
RPOP                    call    #RPOPX                  ' Pop return stack into R and X
                        jmp     #PUSHX                  ' Push X onto the data stack as tos


' Registers can be used just like variables and the interpreted kernel uses some for itself
' 128+ bytes are reserved which can be accessed as bytes/words/longs depending upon
'  the alignment. Since the registers are pointed to by "regptr" they can relocated


' (REG) ( -- addr ) Read the next inline byte and return with the register byte address
REG                     call    #GETBYTE
                        call    #_PUSHX
' REG ( index -- addr ) Find the address of the register
ATREG                   add     tos,regptr
                        jmp     unext


' ABS ( n -- abs )
_ABS                    abs     tos,tos
                        jmp     unext

RUNMOD                  jmp     #pRUNMOD

{HELP UM* ( u1 u2 -- u1*u2L u1*u2H )
DESC: unsigned 32bit * 32bit multiply -- 64bit result
TIME: 1..11.8us
}
UMMUL                   mov     R0,tos+1
                        min     R0,tos                  ' max(tos, tos+1)
                        mov     R2,tos+1
                        max     R2,tos                  ' min(tos, tos+1)

                        mov     R1,#0
                        mov     tos,#0                  ' zero result
                        mov     tos+1,#0
UMMULLP                 shr     R2,#1 wz,wc             ' test next bit of u1
                if_nc   jmp     #UMMUL1                 ' skip if no bit here
                        add     tos+1,R0 wc             ' add in shifted u2
                        addx    tos,R1                  ' carry into upper long
UMMUL1                  add     R0,R0 wc                ' shift u2 left
                        addx    R1,R1                   ' carry into 64-bits
                if_nz   jmp     #UMMULLP                ' exhausted u1?
                        jmp     unext


' main division sub - called both by U/ and U/MOD
' double div, single divisor
' By specifing bits and left justifying the routine can be adapted and run faster
' CLKFREQ 1234 LAP U/MOD LAP .LAP  27.400us ok --> 18.800us

' UM/MOD64 ( Dbl.dividend divisor -- remainder Dbl.quotient)
UMDIVMOD64              mov     ACC,#32
UMDIVMOD32              add     ACC,#32
                        mov     R0, tos                 ' R0 = divisor
                        mov     R1, tos+2               ' R1R2 = dividend
                        mov     R2, tos+1
                        mov     tos+2, #0               ' remainder

udmlp                   shl     R1, #1 wc               ' dividend msb
                        rcl     R2, #1 wc
                        rcl     tos+2, #1               ' hi bit from dividend
                        cmpsub  tos+2, R0   wc,wr       ' cmp divisor ( R0 - tos & c set if tos => R0 )
                        rcl     tos+1, #1 wc            ' tos+1 = quotient l
                        rcl     tos, #1                 ' tos = quotient h
                        djnz    ACC, #udmlp
                        jmp     unext



' WAITPEQ               Wait until input is high - REG3 = mask, REG1 = CNT
_WAITPEQ
                        waitpeq reg3,reg3
                        mov     reg1,cnt                ' capture count in COGREG1
                        jmp     unext


'
' some internal code is added here so that all the XOP code is definitely in the 2nd page
'
{ *** LITERALS *** }

' Accumulate a literal byte by byte from 1 to 4 bytes long depending upon the number of times this routine is called.
' This allows literals to be byte aligned.
ACCBYTE                 call    #GETBYTE                ' Build a big endian literal by reading in another byte
                        shl     ACC,#8                  ' merge it into the "accumulator" byte by byte
                        or      ACC,X
ACCBYTE_ret             ret

' Read the next byte of code memory via IP
GETBYTE                 rdbyte  X,IP                    ' Simply read a byte (non-code) and advance the IP
                        add     IP,#1
GETBYTE_ret             ret






' *********************************** INTERNAL COG ROUTINES *********************************
' Code from here after cog address $0FF cannot be indexed directly except by an XOP.


{ *** RUNTIME BYTECODE INTERPRETER *** }

'       *       *       *       *
' Fetch the next byte code instruction in hub RAM pointed to by the instruction pointer IP
' This is the very heart of the runtime interpreter
'
doNEXT                  rdbyte  instr,IP                'read byte code instruction
                        add     IP,#1 wc                'advance IP to next byte token (clears the carry too!)
                        jmp     instr                   'execute the code by directly indexing the first 256 long in cog

' XOP CMPSTR ( src dict flg-- src dict+ flg ) Compare strings at these two addresses
pCMPSTR
                        mov     R2,tos+1 wc             ' force nc on entry, s[31] == 0 (doNEXT clears c)
                        mov     X,tos+2                 ' X = source
cmpstrlp                rdbyte  R0,X                    ' read in a character from the source
                        add     X,#1                    ' hub has to wait anyway so get ready for next source byte
                if_c    add     R2,#1                   ' updates the copy of the dictionary pointer
                        rdbyte  R1,R2                   ' read in from the dictionary
                        cmp     R1,R0 wz                ' are they the same?
                if_z    jmpret  par,#cmpstrlp wc,nr     ' keep at it, set carry to enable dict+ (for local copy)
nomatch                 cmp     R0,#1 wc                ' was the src null terminated? (C means we have matched the string)
                if_c    test    R1,#$80 wc              ' set c flag if dict 8th bit set (C = cross-matched)
                        jmp     #SETZ                   ' Change our flag to -1 if C set (matched)


' used in: U@ U! STRINGs
' pRCMOVE bytes from source to destination primitive - <CMOVE conditions the parameters before calling
' XOP (RCMOVE) ( src dst cnt -- ) Copy bytes from src to dst for cnt bytes starting from the ends (in reverse)
pRCMOVE                 test    $,#1  wc                ' set carry for decrementing (always cleared by doNEXT)
' XOP (CMOVE) ( src dst cnt -- ) Copy cnt bytes from src to dst address
pCMOVE                  rdbyte  R0,bsrc                 ' read source byte
                        sumc    bsrc,#1                 ' inc or dec depending upon carry
                        wrbyte  R0,bdst                 ' write destination byte
                        sumc    bdst,#1                 ' inc or dec depending upon carry!!
                        djnz    bcnt,#pCMOVE
                        jmp     #DROP3


pCOGID                  cogid   X
                        jmp     #PUSHX


' COGINIT ( dest -- cog ) PAR(14), CODE(14), NEW(1),COG(3)
pCOGINIT                coginit tos wr
                        jmp     unext

' INIT STACKS
pInitRP
                        movs    rpopins,#retstk
                        movd    _PUSHR,#retstk
                        jmp     unext

' temporary timing instructions
' Capture the current cnt value and calulate cycles since last LAP - result in lapcnt
' LAP ( --  ) delta in lapcnt (created independant regs rather than REG3,4)
pLAP                    neg     lapcnt,target           '  -old
                        mov     target,cnt              ' new
                        add     lapcnt,target           ' new-old
                        jmp     unext



{ *** CONSOLE SERIAL OUTPUT *** }
{
Transmit the character that is in the tos register. The output direction is preset (to save cog space)
}
' (EMIT) ( bits -- )
pEMIT
                        and     tos,#$0FF       ' data controls loop so trim to 8-bits
                        add     tos,#$100 wc    ' add a stop bit (carry = start bit)
pEMITX                  or      dira,txmask     ' make sure it's an output
                        mov     R0,cnt
                        add     R0,txticks
txbit                   muxc    outa,txmask     ' output bit
                        shr     tos,#1 wz,wc    ' lsb first
                        waitcnt R0,txticks      ' bit timing
        if_nz_or_c      jmp     #txbit          ' next bit (stop bit: z & c)
'''                     andn    dira,txmask     ' leave it to be pulled up so another cog can also use it
                        jmp     #DROP

{ *** PASM MODULE LOADER *** }

{
>16 longs are reserved for a selectable module as a helper for specialized functions such as SPI etc.
LOADMOD loads the longs into this area to be executed with RUNMOD
}
' LOADMOD ( src dst cnt -- ) Load a PASM module of up to 18 longs (or loadsz) into the cog
pLOADMOD
                        movd    lcdst,tos+1     ' Init dst pointer - just loading a small module alongside Tachyon
ldmlp                   add     lcdst,dst1      ' post-increment long destination (pipelined after rdlong)
lcdst                   rdlong  0_0,tos+2       ' read a long from hub ram into cog's destination
                        add     tos+2,#4        ' increment hub memory long address
                        djnz    tos,#ldmlp
                        jmp     #DROP3

' DELTA ( delta -- )    Calculate and set the cnt delta and waitcnt
pDELTA                  call    #POPX
                        mov     deltaR,X        ' use otherwise unused video reg for delta
                        mov     cnt,X           ' (kernel isn't doing any video)
                        add     cnt,cnt
' WAITCNT ( -- )
pWAITCNTS               waitcnt cnt,deltaR      ' continue from last count (must be called before target is reached)
                        jmp     unext

{ *** COG ACCESS *** }

' SPR@ ( index -- long ) Fetch a cog's SPR
' pSPRFETCH                     add     tos,#$01F0
' COG@ ( addr -- long ) Fetch a long from cog memory
pCOGFETCH               movs    _readsrc,tos
                        nop
_readsrc                mov     tos,0_0
                        jmp     unext

' COG! ( long addr -- ) Store a long to cog memory
pCOGSTORE               movd    _writedst,tos
                        nop
_writedst               mov     0_0,tos+1
                        jmp     #DROP2


' COGREG ( ix -- addr ) return with the address of the indexed cog register
pCOGREG                 add     tos,#REG0
                        jmp     unext

{

' Usage: n LSTACK COG@
' Loop control words such as J K LEAVE etc implemented
' LSTACK ( index -- cog_addr ) push address of the loop stack in cog memory
pLSTACK                 add     tos,#loopstk
                        jmp     unext
}
{
{ PASM could be deprecated with the use of OPCODE instead }

' Execute a PASM instruction from the stack
' PASM ( val pasm -- result pasm )      120919 modified to not drop
pPASM                   mov     pasmins,tos
                        nop             ' takes care of pipeline and uses high mem for remainder of code
pasmins                         nop
                        jmp     unext
}



{ *** INTERNAL STACKS *** }

{
As well as the data and return stack, a loop and branch stack is also employed
The return stack should normally only used for return addresses
A separate loop stack means that loop indicies can still be accessed in a called function
The branch stack speeds up loops by having the current loop address available without having to read an offset and calculate
The data stack is accessed as 4 fixed registers with an non-addressed overflow stack in hub RAM.
}

{ *** BRANCH STACK HANDLER *** }
{
The branch stack is used for fast loop branching and so holds the branch address
It is constructed as a fixed top-of-stack location which physically moves data when it's pushed or popped
This means also that it is not possible to corrupt other memory by over or underflow.
}
_PUSHBRANCH
'                       mov     branchstk+4,branchstk+3
                        mov     branchstk+3,branchstk+2
                        mov     branchstk+2,branchstk+1
                        mov     branchstk+1,branchstk
                        mov     branchstk,IP    ' this is the address to loop to
_PUSHBRANCH_ret         ret

_POPBRANCH              mov     branchstk,branchstk+1
                        mov     branchstk+1,branchstk+2
                        mov     branchstk+2,branchstk+3
'                       mov     branchstk+3,branchstk+4
_POPBRANCH_ret          ret



{ *** LOOP STACK HANDLER *** }
{HELP LPOPX     --- pop the loop stack into X
The loop stack holds the loop limit and current index. It is constructed as a fixed top-of-stack location which physically moves data when it's pushed or popped. This means also that it is not possible to corrupt other memory by over or underflow.
}
LPOPX
                        mov     X,loopstk
                        mov     loopstk,loopstk+1
                        mov     loopstk+1,loopstk+2
                        mov     loopstk+2,loopstk+3
                        mov     loopstk+3,loopstk+4
                        mov     loopstk+4,loopstk+5
                        mov     loopstk+5,loopstk+6
                        mov     loopstk+6,loopstk+7
                        mov     loopstk+7,#0
LPOPX_ret               ret

' Push tos onto the loop stack and drop tos
_PUSHLP
                        mov     loopstk+7,loopstk+6
                        mov     loopstk+6,loopstk+5
                        mov     loopstk+5,loopstk+4
                        mov     loopstk+4,loopstk+3
                        mov     loopstk+3,loopstk+2
                        mov     loopstk+2,loopstk+1
                        mov     loopstk+1,loopstk
                        mov     loopstk,tos
'
' falls through into a DROP via POPX to remove the tos
' ----> to POPX
{ *** DATA STACK HANDLER *** }

' Pop the data stack using fixed size stack in COG memory (allows fast direct access for operations)
' V2.2 adds an overflow stack in hub ram and reduces the size of the cog stack to 4
'
POPX
                        mov     X,tos                   ' pop old tos into X
                        mov     tos,tos+1
                        mov     tos+1,tos+2
                        mov     tos+2,tos+3
                        tjz     depth,POPX_ret          ' do not allow ext stack to pop past bottom
                        sub     depth,#4
                        testn   depth,#%1111 wz         ' nz: 16+
                if_z    jmp     POPX_ret                ' direct return
                        mov     R0,stkptr
                        add     R0,depth
                        rdlong  tos+3,R0                ' pop from hub into bottom of cog stack
POPX_ret
_PUSHLP_ret
                        ret

_PUSHACC                mov     X,ACC                   ' Accumulator operation used for fast constants
_PUSHX                  mov     ACC,#0                  ' clear it for next operation
                        cmp     depth,#16 wc            ' faster stacking if we can avoid hub access, only on overflow
'                       tjz     stkptr,#PUSHCOG         ' skip external stack if no pointer assigned (set to ROM if not used)
                        mov     R0,stkptr
                        add     R0,depth
                if_nc   wrlong  tos+3,R0                ' save bottom of stack to hub RAM (only if necessary)
PUSHCOG                 mov     tos+3,tos+2             ' push the cog stack registers (4)
                        mov     tos+2,tos+1
                        mov     tos+1,tos
                        mov     tos,X                   ' replace tos with X (DEFAULT)
                        add     depth,#4                ' the depth variable indexes bytes in hub RAM (real depth = depth/4)
_PUSHACC_ret
_PUSHX_ret
                        ret


{ *** RETURN STACK HANDLER *** }
{
Return stack builds up in cog memory
Return stack items do not need to be directly addressed
This indexed method does not use movd and movs methods but directly inc/decs the
source and destination fields of the instruction.(retstk) so it must stay synchronized - Use !RP if needed
}
SETUPIP                 call    #GETBYTE        ' read the next byte into X and save the current IP
SAVEIP                  mov     R0,IP
_PUSHR                  mov     retstk,R0       ' save it on the stack (dest modified)
                        add     rpopins,#1      ' update source for popping
                        add     _PUSHR,dst1     ' update dest for pushing (points to next free)
SETUPIP_ret                     '
SAVEIP_ret                      '
_PUSHR_ret              ret



RPOPX                   sub     rpopins,#1      ' decrement rpop's source field
                        sub     _PUSHR,dst1
rpopins                 mov     X,retstk
RPOPX_ret               ret




dst1            long $200       ' instruction's destination field increment
zcalls          long $0400-2    ' 1K offset after XCALLs for ZCALL table


{ *** COG VARIABLES *** }

pinreg
clockpins       long 0                  ' I/O mask for CLOCK instruction
spisck          long 0                  ' I/O mask for SPI clock
spiout          long 0                  ' I/O mask for SPI data out (MOSI)
spiinp          long 0                  ' I/O mask for SPI data in (MISO)

spice           long 0                  ' I/O mask for SPI CE (not really required unless we use CE instr)
spicnt          long 0                  ' bit count for variable size Kernel SPI

' Registers used by PASM modules to hold parameters such as I/O masks and bit counts etc
REG0            long 0
REG1            long 0
REG2            long 0
REG3            long 0
REG4            long 0

txticks         long (sysfreq / baud )  ' set transmit baud rate
txmask          long |<txd                      ' change mask to reassign transmit
' COGREG 7 = TASK REGISTER POINTER
regptr          long registers          ' used by REG
Xptr            long @XCALLS+s          ' used by XCALL, points to vector table (bytecode>address)
unext           long doNEXT             ' could redirect code if used
' COGREG 10
' rearranged these register to follow REG0 so that they can be directly accessed by COGREG instruction
IP              long 0                  ' Instruction pointer
ACC             long 0                  ' Accumulator for inline byte-aligned literals
X               long 0                  ' primary internal working registers
R0              long 0
R1              long 0
R2              long 0
' COGREG 16
stkptr          long $8000              ' points to start of stack in hub ram - builds up (safe init to rom)
depth           long 0                  ' depth long index - points to top of overflow in hub ram
lapcnt          long 0
target          long 0


' *** STACKS ***
tos
datastk         long 0[datsz]
retstk          long 0[retsz]
loopstk         long 0[loopsz]

branchstk               long 0[branchsz]


_RUNMOD_        ' this is a dummy symbol but the org must be equal to _RUNMOD (or less)
                long 0[loadsz]


                fit 496

' define some constants used by this cog
' The RUNMOD parameters are defined here so that the method can be changed easily

                org tos
sdat            res 1
                org tos
bcnt            res 1
bdst            res 1
bsrc            res 1


                org REG0
sck             res 1
mosi            res 1
miso            res 1
scs             res 1
scnt            res 1

                org REG0
                res 3
pixshift        res 1
pixeladr        res 1

endofkernel     res 0   ' just a branch to identify the end of the kernel in the listing (BST)
                res 0
                res 0
                res 0
                res 0








CON

'instr   = $1F5   ' use OUTB register

deltaR  = $1FF



{ Boot-time Spin startup - launches Tachyon into all the remaining cogs and starts serial receive into cog 1 }

PUB Start
  rxticks := txticks := clkfreq / baudrate      ' Force VM transmit routine to correct baud
  coginit(1,@TachyonRx, 0)                    ' Load serial receiver into cog 1
  repeat 6                                              ' cogs 2..7 loaded with Tachyon and IDLE loop
        cognew(@RESET, @IDLE_reset)
  coginit(0,@RESET, @TERMINAL_reset)                    ' finally replace this cog 0 loaded with Tachyon main terminal loop



