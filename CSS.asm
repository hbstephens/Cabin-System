**************************************************************************
* Current version: 
*      1-Feb-2011  5:00 pm
CSBUILD EQU     51              Version number of the system build
**************************************************************************
*        OPT     cre             A cross reference is a good thing to have
**************************************************************************
*
* Cabin Software - Copyright 1996-2011     H. Bruce Stephens
*
*
* Cabin Software - This is the main module which is downloaded into
*       the Cabin System 68HC11 for execution.   The Cabin Software
*       provides a basis for remotely monitoring the Cabin Sensors.
*       In addition, the Cabin Software provides a transparent 
*       interface to the CP290 for direct power control of lights,
*       equipment, etc via the X10 system.   The Cabin Software also
*       provides a history of the weather information collected by
*       the Cabin System.    Local display operations are provided 
*       using a LCD panel which can monitor the sensors directly.
*
* The Cabin System Software will be refered to as CSS
*
* Second generation build date: Wednesday, August 25, 1993
*
* Modification History
*
*   Version   Who          When         Why
*    FT1.0    hbs      25-Aug-1993    Initial Release for 1st field test
*     V1.x    hbs      14-Jul-1996    Revision history begins
*     V1.37   hbs      15-Jul-1996    Must delay a few seconds on startup
*                                     to give the CP290 time to come online
*     V1.38   hbs      18-Jul-1996    Improved display characteristics and
*                                     corrected modem hangup sequence
*     V1.39   hbs      19-Jul-1996    Minor home/clear cleanup
*     V1.40   hbs      22-Jul-1996    Limit the history days to 25
*     V1.41   hbs      13-Aug-1996    Cabin deployment, added extra timing
*                                     delay to temp bus, fixed sensor names                                     
*                                     to match location 
*     V1.42   hbs      25-Dec-1996    Correction to history logic, fix rel
*                                     light lcd negative display, bumped
*                                     the birthday: Sunday, 25Aug96
*     V1.43   hbs      27-Dec-1996    Continue to correct history logic
*                                     and non negative high/low display
*     V1.44   hbs      31-Dec-1996    Open/close door count fix for non 
*                                     negitive numbers and added stops to
*                                     the end of the code for power down
*     V1.45   hbs      13-Nov-2000    Remove the Y2K problems.
*     V1.50   hbs      11-Dec-2001    Bumped the birth date and added a new
*                                     command at the USERNAME: prompt for 
*                                     a PC to dump just the first of the RAM
*     V1.51   hbs       1-Feb-2011    Added to public repository
*
**************************************************************************
*  EVB memory assignments
**************************************************************************
*
BUFFALO EQU     $E000           Buffalo begins here
BUFISIT EQU     $E00A           Buffalo bypass the PORTE bit 0 check
RAMSTRT EQU     $C000           Starting RAM location     
EEPROMS EQU     $6000           Starting EEPROM 
*
*
**************************************************************************
*  Equates into BUFFALO ROM locations for calling routines
**************************************************************************
*
HOSTCO  EQU     $E330           Host connect routine        
HOSTINI EQU     $EF3F           Host init routine
INPUT   EQU     $E387           Input from the PeeCee
OUTPUT  EQU     $E3B3           Output to the PeeCee
UPCASE  EQU     $E18F           Upper case routine
ONACIA  EQU     $E46E           Master reset the ACIA
OUTCRLF EQU     $E4ED           Output a LF/CR sequence to the PeeCee
DUMP1   EQU     $E7E4           Dump memory...used for UPLOAD function
VECINIT EQU     $E340           Interupt vector init routine
BPCLR   EQU     $E19A           Breakpoint clear routine
INIT    EQU     $E361           RS-232 init routine
ONSCI   EQU     $E24F           Setup the SCI routine
ACIA    EQU     $9800           ACIA master address location
*
**************************************************************************
*  68HC11 Equates RAM locations for control/status registers used by CSS
**************************************************************************
*
PORTA   EQU     $1000           Address of PORT A
PORTB   EQU     $1004           Address of PORT B
PORTC   EQU     $1003           Address of PORT C
DDRC    EQU     $1007           Data direction for PORT C
PORTD   EQU     $1008           Address of PORT D
DDRD    EQU     $1009           Data direction for PORT D
PORTE   EQU     $100A           Address of PORT E
PACTL   EQU     $1026           Pulse Accumulator control register
PACNT   EQU     $1027           Pulse Accumulator (Wind speed counter)
BAUD    EQU     $102B           SCI Baud rate register
SCSR    EQU     $102E           SCI Status register
SCDAT   EQU     $102F           SCI Data Register
OPTION  EQU     $1039           System configuration/option register
ADCTL   EQU     $1030           A/D Control/Status Register
TFLG1   EQU     $1023           Main timer flag register
TCNT    EQU     $100E           Timer Counter Register
TOC4    EQU     $101C           Timer Output Compare Register 4 
TOC5    EQU     $101E           Timer Output Compare Register 5 
TMSK2   EQU     $1024           Timer mask two
*
**************************************************************************
*  Equates into BUFFALO RAM locations used by CSS
**************************************************************************
*
PTR1    EQU     $00B2           Starting dump memory pointer
PTR2    EQU     $00B4           Ending dump memory pointer
AUTOLF  EQU     $00A9           Auto Line feed flag location
HOSTDEV EQU     $00AC           0=sci 1=acia Used by CPINIT
EXTDEV  EQU     $00AB           External device address location
STACK   EQU     $0068           The stack location
IODEV   EQU     $00AA           RS-232 I/O Device
*
**************************************************************************
*  Equate definitions used by CSS
**************************************************************************
*
TOC4F   EQU     $10             Timer 4 compare output flag
TOC5F   EQU     $08             Timer 5 compare output flag
REQDATA EQU     $06             CP290 Request graphics data command
REQCLK  EQU     $04             CP290 Request clock command
DNLOAD  EQU     $03             CP290 Download event command
DNTIME  EQU     $02             CP290 Download time command
DCDFLAG EQU     $04             Bit 2 of PORT A is the DCD flag (LOW=ACTIVE)
LCDRSD  EQU     $08             Bit 3 of PORT A is the LCD RS 0=reg 1=data
RDFLAG  EQU     $20             SCI status register Data Ready (RDRF) flag
WINDON  EQU     $10             Sets the wind direction bit for PORT A
HORZTAB EQU     $09             ASCII TAB
CRETURN EQU     $0D             ASCII Carriage Return
LINFEED EQU     $0A             ASCII Line Feed
BACKSP  EQU     $08             ASCII Backspace
EOTEXT  EQU     $04             ASCII End of Text
ASPACE  EQU     $20             ASCII Space
CAPTOLY EQU     $59             ASCII Capital 'Y'
ASCII0  EQU     $30             ASCII 0
ESCAPE  EQU     $1B             ASCII Escape
ACOLON  EQU     $3A             ASCII :
APLUS   EQU     $2B             ASCII +
APERIOD EQU     $2E             ASCII .
ALLONES EQU     $FF             Blank out the LED display
ASMALLA EQU     $61             ASCII a
ASMALLP EQU     $70             ASCII p
ASMALLM EQU     $6D             ASCII m
AMINUS  EQU     $2D             ASCII -
*
**************************************************************************
*  The following information describes some of the timing and housekeeping
*  structures used by the CSS.
*
BDYR    EQU     1               The year we take as a starting point (2001)
BDWDAY  EQU     7               Saturday    HB Stephens birthday on 8/25/2001
BDDAY   EQU     25              25th day
BDMON   EQU     8               August
BDLEAP  EQU     1               2001 was not a leap year
*
**************************************************************************
*   These are commands used by the DS1820 Temp devices
**************************************************************************
*
READROM EQU     $33             Read ROM sends the DS1820 ROM back to master
MACHROM EQU     $55             Match ROM tell only this DS1820 to talk
SKIPROM EQU     $CC             Skip the ROM sequence and do the command
TAKETMP EQU     $44             Initiate the temperature conversion             
READTMP EQU     $BE             Read the temperature
*
*
**************************************************************************
*  RAM definitions used by CSS
**************************************************************************
*
	ORG     EEPROMS         Begin our code section
CSSTART EQU     *               Cabin System Start of our RAM
*
* We begin by doing what BUFFFALO does.   Setting up the system
*
	LDAA    #$93            ADPU, DLY, IRQE, COP
	STAA    OPTION          Turn on these options
	CLRA                    Clear A
	STAA    TMSK2           Timer pre = %1 for trace
	LDS     #STACK          Setup our stack
	JSR     VECINIT         Setup the interrupt vectors
	JSR     BPCLR           Clear this table
	CLR     AUTOLF          Setup this flag
	INC     AUTOLF          CR/LF is ON
*
* Here we initialize the ACIA and get it ready for action
*
	LDAA    #$01            0=SCI 1=ACIA
	STAA    EXTDEV          Save it here
	STAA    IODEV           Ditto
	JSR     ONACIA          Initialize the ACIA
*
* Now we setup the SCI device which handles the CP290
*
	JSR     HOSTCO          Conntect the host to the EVB
	JSR     ONSCI           Initialize the CP290 port
	JMP     STARTUP         Jump over the data section into the start
*        
	LDAA    #$50            To enable the stop command
	TAP                     Put it in the CC register
	STOP                    This is here to halt the CPU on runaway
*
* Here begins the constants
*
VERSION FCB     CSBUILD         Save area for system build version
**************************************************************************
* Here we begin the static data area
**************************************************************************
*
VMSMSG  EQU     *
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'Unauthorized access to this system is prohibited.'
	FCB     CRETURN
	FCB     EOTEXT
*
VMSMSG1 EQU     *
	FCC     'Username: '
	FCB     EOTEXT
*
VMSMSG2 EQU     *
	FCC     'Password: '
	FCB     EOTEXT
*
VMSMSG3 EQU     *                            
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCB     HORZTAB
	FCC     'Welcome to the Cabin System V1.'
	FCB     EOTEXT
*
VMSMSG4 EQU     *
	FCB     CRETURN
	FCC     'User authorization failure'
	FCB     EOTEXT
*
VMSMSG5 EQU     *               Setup VT100 command sequence
	FCB     ESCAPE
	FCC     '[61"p'
	FCB     EOTEXT
*
CWORD   EQU     *		Short command to dump lower memory
	FCC     'CQ'
	FCB     0
*
PWORD   EQU     *
	FCC     'HBSTEPHENS'
	FCB     0
*
DSPMSG1 EQU     *
	FCC     'Unsuccessful attempts:'
	FCB     HORZTAB
	FCB     EOTEXT
*
DSPMSG2 EQU     *
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCB     HORZTAB
	FCC     'Cabin Software Command Menu'
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '1 - Display current conditions'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '2 - Display max/min history'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '3 - Display Door status'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '4 - Display CSS status'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '5 - Upload history data'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '6 - Enter X10 conversation'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '7 - Set CSS time'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '8 - Maintenance mode'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     '0 - Exit the Cabin System'
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'Enter Selection: '
	FCB     EOTEXT
*
DSPMSG3 EQU     *
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'WARNING! WARNING! WARNING!'
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'Control must be returned to the Cabin System after using'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'BUFFALO or remote access will be lost!  Type the command:'
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'G B600   to return to the Cabin System'
	FCB     CRETURN
	FCB     EOTEXT
*
ASKYSNO EQU     *
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'Are you sure? Y/<N> '
	FCB     EOTEXT
*
DSPMSG4 EQU     *
	FCB     CRETURN
	FCC     'Upload History Data.  Ready PC for ASCII Upload in 10 sec.'
	FCB     EOTEXT
*
DSPMSG5 EQU     *
	FCB     CRETURN
	FCC     'Function complete.  <Enter> to continue.'
	FCB     EOTEXT
*
DSPMSG6 EQU     *
	FCC     'Entering CP290 transparant mode.  Use BREAK to return to CSS'
	FCB     CRETURN
	FCB     EOTEXT
*
DSPMSG7 EQU     *
	FCC     'Max/Min history'
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'Location'
	FCB     HORZTAB
	FCC     'Low'
	FCB     HORZTAB
	FCC     'Date'
	FCB     HORZTAB
	FCB     HORZTAB
	FCC     'High'
	FCB     HORZTAB
	FCC     'Date'
	FCB     CRETURN
	FCB     EOTEXT
*
DSPMSG8 EQU     *
	FCB     CRETURN
	FCC     'Current Cabin Conditions'
	FCB     CRETURN
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'Location'
	FCB     HORZTAB
	FCC     'Temperature'
	FCB     CRETURN
	FCB     EOTEXT
*
DSPMSG9 EQU     *
	FCC     'Until next time...goodbye from colorful Colorado'
	FCB     EOTEXT
*
DSPMSGB EQU     *
	FCC     'ATH0'
	FCB     CRETURN
	FCB     EOTEXT
*
DSPMSGC EQU     *
	FCC     'Successful logins: '
	FCB     HORZTAB
	FCB     EOTEXT
*
DSPMSGD EQU     *
	FCB     CRETURN
	FCC     'Warning - CP290 has lost all data'
	FCB     EOTEXT
*
DSPMSGE EQU     *
	FCB     CRETURN
	FCC     'Cabin System time:'
	FCB     HORZTAB
	FCB     EOTEXT
*
DSPMSGF EQU     *
	FCC     'Functional since:'
	FCB     HORZTAB
	FCB     EOTEXT
*
DSPMSGG EQU     *
	FCC     'Power restored:  '
	FCB     HORZTAB
	FCB     EOTEXT
*
DSPMSGH EQU     *
	FCC     'Last user login time:'
	FCB     HORZTAB
	FCB     EOTEXT
*
DSPMSGI EQU     *
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'Cabin System Door Status'
	FCB     EOTEXT
*
DSPMSGJ EQU     *
	FCC     'Number history days:'
	FCB     HORZTAB
	FCB     EOTEXT
*
DSPMSGK EQU     *
	FCC     '<none>'
	FCB     EOTEXT
*
DSPMSGL EQU     *
	FCC     'Power fail scan: '
	FCB     HORZTAB
	FCB     EOTEXT
*
DSPMSGM EQU     *
	FCB     CRETURN
	FCC     'NOTE: History upload will take ~ 2min 40sec @ 2400 baud'
	FCB     CRETURN
	FCB     EOTEXT
*
DNWAIT  EQU     *
	FCB     CRETURN
	FCB     HORZTAB
	FCC     'Loading CP290...wait 30 sec'
	FCB     EOTEXT
*
HACMSG1 EQU     *               VT100 escape sequence to home and clear screen
	FCB     ESCAPE
	FCC     '[2J'
	FCB     EOTEXT
*
HACMSG2 EQU     *               VT100 escape sequence to home cursor
	FCB     ESCAPE
	FCC     '[H'
	FCB     EOTEXT
*
ASKTDAY EQU     *               Ask time/date
	FCB     CRETURN
	FCB     LINFEED
	FCC     'Please enter the time as follows: YY-MM-DD:HH:MM '        
	FCB     EOTEXT
*
* This table is used for the display of the door information
*
MDOOR   FCB     CRETURN
	FCC     'Front'         Main door
	FCB     EOTEXT
BDOOR   FCB     CRETURN
	FCC     'Basement'      Basement door
	FCB     EOTEXT
NDOOR   FCB     CRETURN
	FCC     'N Garage'      North Garage door
	FCB     EOTEXT
SDOOR   FCB     CRETURN
	FCC     'S Garage'      South Garage door
	FCB     EOTEXT
*
DOORTBL EQU     *
	FDB     MDOOR
	FDB     BDOOR
	FDB     NDOOR
	FDB     SDOOR
*
DOORATE EQU     *                       Index table into the door status area
	FDB     SMDOOR
	FDB     SBDOOR
	FDB     SNDOOR
	FDB     SSDOOR
*
DCLOSED FCC     ' door is closed'
	FCB     EOTEXT
DOPENED FCC     ' door is OPEN!!'
	FCB     EOTEXT
DCYCLED FCB     HORZTAB
	FCC     'Open/Close count: '     
	FCB     EOTEXT
DLOPEND FCB     HORZTAB
	FCC     'Last opened: '     
	FCB     EOTEXT
DLCLOSE FCB     HORZTAB
	FCC     'Last closed: '     
	FCB     EOTEXT
*
DAYMON  EQU     *               Day of Month table
	FCB     0               We index from 1 so first is blank
	FCB     31              January
	FCB     28              February
	FCB     31              March
	FCB     30              April
	FCB     31              May
	FCB     30              June
	FCB     31              July
	FCB     31              August
	FCB     30              September
	FCB     31              October
	FCB     30              November
	FCB     31              December
*
*       Month Text Table        
MONTH1  FCC     'January '
	FCB     EOTEXT
MONTH2  FCC     'February '
	FCB     EOTEXT
MONTH3  FCC     'March '
	FCB     EOTEXT
MONTH4  FCC     'April '
	FCB     EOTEXT
MONTH5  FCC     'May '
	FCB     EOTEXT
MONTH6  FCC     'June '
	FCB     EOTEXT
MONTH7  FCC     'July '
	FCB     EOTEXT
MONTH8  FCC     'August '
	FCB     EOTEXT
MONTH9  FCC     'September '
	FCB     EOTEXT
MONTH10 FCC     'October '
	FCB     EOTEXT
MONTH11 FCC     'November '
	FCB     EOTEXT
MONTH12 FCC     'December '
	FCB     EOTEXT
*               
MTABLE  EQU     *               Month Table for indexing
	FDB     0               We index from 1 - 12
	FDB     MONTH1
	FDB     MONTH2
	FDB     MONTH3
	FDB     MONTH4
	FDB     MONTH5
	FDB     MONTH6
	FDB     MONTH7
	FDB     MONTH8
	FDB     MONTH9
	FDB     MONTH10
	FDB     MONTH11
	FDB     MONTH12
*
* Week days text table
WKDAY1  FCC     'Sunday '
	FCB     EOTEXT
WKDAY2  FCC     'Monday '
	FCB     EOTEXT
WKDAY3  FCC     'Tuesday '     
	FCB     EOTEXT
WKDAY4  FCC     'Wednesday '
	FCB     EOTEXT
WKDAY5  FCC     'Thursday '
	FCB     EOTEXT
WKDAY6  FCC     'Friday '
	FCB     EOTEXT
WKDAY7  FCC     'Saturday '
	FCB     EOTEXT
*
DAYOFWK EQU     *               Day of Week table
	FDB     0               This table is indexed from 1-7                
	FDB     WKDAY1          Sunday
	FDB     WKDAY2          Monday
	FDB     WKDAY3          Tuesday
	FDB     WKDAY4          Wednesday
	FDB     WKDAY5          Thursday
	FDB     WKDAY6          Friday
	FDB     WKDAY7          Saturday
*
DAYMAP  EQU     *               Maps the Actual Day to the CP290
	FCB     0               We index from 1
	FCB     $40             Sunday
	FCB     $01             Monday
	FCB     $02             Tuesday
	FCB     $04             Wednesday
	FCB     $08             Thursday
	FCB     $10             Friday
	FCB     $20             Saturday
*
SHOWT20 EQU     *
	FCC     ', 20'
	FCB     EOTEXT
*
LCDSIP  EQU     *               This is the init sequence for the LCD
	FCB     $38
	FCB     $38
	FCB     $38
	FCB     $0F
	FCB     $01
	FCB     $06
	FCB     EOTEXT
*
LCDWEL  EQU     *               Welcome messasge for the LCD
*                1234567890123456        
	FCC     'Cabin System Up!'
	FCB     EOTEXT
*
LCDISOK EQU     *               
	FCC     'Normal Operation'
	FCB     EOTEXT
*
LCDCPAS EQU     *               Sending data between the PeeCee & CP290
	FCC     'CP290 - Passthru' 
	FCB     EOTEXT
*
LCDRMT  EQU     *               In progress with remote system
	FCC     'Servicing Remote'
	FCB     EOTEXT
*
CPDOWN  EQU     *
	FCC     'CP290 - failure!'
	FCB     EOTEXT
*
LCDSCAN EQU     *               We are in a event scan from the CP290
	FCC     'Sensor Data Scan'
	FCB     EOTEXT
*
LCDSAVE EQU     *               We are saving data into the CP290
	FCC     'Saving VitalData'
	FCB     EOTEXT
*
LCDREST EQU     *               We are restoring data from the CP290
	FCC     'Restor VitalData'
	FCB     EOTEXT
*
*
STATBLE EQU     *               State table for LCD display
	FDB     TMPDSP1         S Attic
	FDB     TMPDSP2         East Outside
	FDB     TMPDSP3         North Outside
	FDB     TMPDSP4         Pump Area
	FDB     TMPDSP5         Basement
	FDB     TMPDSP6         South Bedroom
	FDB     TMPDSP7         Kitchen
	FDB     TMPDSP8         Internal
	FDB     CURDSP1         Pressure
	FDB     CURDSP2         Rain Fall
	FDB     CURDSP3         Relative light 
	FDB     CURDSP4         Wind Speed
	FDB     CURDSP5         Direction
*
* These states are special informational events
*
	FDB     LCDISOK         13 - I'm in my main service loop
	FDB     LCDWEL          14 - I'm up and running
	FDB     LCDCPAS         15 - I'm in pass thru with the CP290 
	FDB     LCDRMT          16 - The modem is now in control
	FDB     CPDOWN          17 - The CP290 is not responding
	FDB     LCDSCAN         18 - History data scan from CP290
	FDB     LCDSAVE         19 - Saving data to the CP290
	FDB     LCDREST         20 - Restoring data from CP290
*
**************************************************************************
*  The equates describe the state of the LCD display
*
STMAIN  EQU     13              I'm in my main service loop
STRUN   EQU     14              I'm up and running
STPASS  EQU     15              I'm in pass thru with the CP290 
STMODEM EQU     16              The modem is now in control
STCPDN  EQU     17              The CP290 is not responding
STSCAN  EQU     18              We are gathering sensor data
STSAVE  EQU     19              We are saving data into the CP290
STREST  EQU     20              We are restoring data from the CP290
*
* The following table is used as a JSR table for the user commands
* NOTE: The order here must match the user's selection.
*
CMDTBLE EQU     *
	FDB     DODSPBY         0 - Hang up the phone...user is leaving
	FDB     DODSPCC         1 - Do Display Current Conditions
	FDB     DODSPMM         2 - Do Display Max and Min Values
	FDB     SHODOOR         3 - Display Door status and time
	FDB     SHOWCSS         4 - Display CSS status and time
	FDB     DODSPUD         5 - Do History data upload  
	FDB     DODSPTM         6 - Enter transparent mode with CP290
	FDB     SETUPCP         7 - Setup the time and CP290
	FDB     DODEBUG         8 - Go to BUFFALO
MAXCMDS EQU     $38             In ASCII - Maximum number of user commands
*
* The following tables are used to printout the wind direction.
* When enabled, PORT C contains one or more of the values WINVAL
*
WINDIR  FCC     'E S W N SESWNWNE'
*
WINVAL  FCB     $80             East
	FCB     $20             South
	FCB     $08             West
	FCB     $02             North
	FCB     $40             South East
	FCB     $10             South West
	FCB     $04             North West
	FCB     $01             North East
	FCB     $00             End of table
*
*
DS18201 EQU     *               64 bit ROM code for DS1820 #1
	FCB     $10
	FCB     $4A
	FCB     $2B
	FCB     $02
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $CE
DS18202 EQU     *               64 bit ROM code for DS1820 #2
	FCB     $10
	FCB     $85
	FCB     $2B
	FCB     $02
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $75
DS18203 EQU     *               64 bit ROM code for DS1820 #3
	FCB     $10
	FCB     $2F
	FCB     $2B
	FCB     $02
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $E6
DS18204 EQU     *               64 bit ROM code for DS1820 #4
	FCB     $10
	FCB     $5B
	FCB     $2C
	FCB     $02
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $F3
DS18205 EQU     *               64 bit ROM code for DS1820 #5
	FCB     $10
	FCB     $07
	FCB     $2C
	FCB     $02
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $A0
DS18206 EQU     *               64 bit ROM code for DS1820 #6
	FCB     $10
	FCB     $5E
	FCB     $0C
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $E7
DS18207 EQU     *               64 bit ROM code for DS1820 #7
	FCB     $10
	FCB     $A3
	FCB     $2B
	FCB     $02
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $71
DS18208 EQU     *               64 bit ROM code for DS1820 #8
	FCB     $10
	FCB     $A4
	FCB     $06
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $00
	FCB     $E7
*
* These are the pointers to the ROM codes for the temperature sensors
*
TMPIDX  FDB     DS18201         South Attic        
	FDB     DS18202         East Outside
	FDB     DS18203         North Outside
	FDB     DS18204         Pump Area
	FDB     DS18205         Basement
	FDB     DS18206         South Bedroom
	FDB     DS18207         Kitchen
	FDB     DS18208         Internal
*
TMPDSP1 EQU     *
	FCC     'South Attic '     
	FCB     EOTEXT
TMPDSP2 EQU     *
	FCC     'East Outsid '     
	FCB     EOTEXT
TMPDSP3 EQU     *
	FCC     'North Deck  '     
	FCB     EOTEXT
TMPDSP4 EQU     *
	FCC     'Pump Area   '     
	FCB     EOTEXT
TMPDSP5 EQU     *
	FCC     'Basement    '     
	FCB     EOTEXT
TMPDSP6 EQU     *
	FCC     'South Bedrm '     
	FCB     EOTEXT
TMPDSP7 EQU     *
	FCC     'Kitchen     '     
	FCB     EOTEXT
TMPDSP8 EQU     *
	FCC     'Internal    '     
	FCB     EOTEXT
*
TMPCTAB EQU     *               Printout adjustment
	FCB     CRETURN
TMPHORZ EQU     *        
	FCB     HORZTAB
	FCB     EOTEXT
*
CURDSP1 EQU     *
	FCC     'Presssure   '     
	FCB     EOTEXT
CURDSP2 EQU     *
	FCC     'Rain Fall   '     
	FCB     EOTEXT
CURDSP3 EQU     *
	FCC     'Rel Light   '     
	FCB     EOTEXT
CURDSP4 EQU     *
	FCC     'Wind Speed  '     
	FCB     EOTEXT
CURDSP5 EQU     *
	FCC     'Wind Dir    '     
	FCB     EOTEXT
*
*        
*
* This is the temperature conversion table.   From what we are given 
* from the DS1820 which measures the temp in .5 increments of Centigrade
* We make the conversion between this and Fahrenheit (1.8 * C) + 32
* The value given from the DS1820 is taken, we add 124 which give our
* index into this table.
*
*      Reported          T oC    T oF   1820  Index
*        T oF                           Value  -1
*
TMPTTBL EQU     *
	FCB -79         -62.00  -79.60  FF84    1
	FCB -78         -61.50  -78.70  FF85    2
	FCB -77         -61.00  -77.80  FF86    3
	FCB -76         -60.50  -76.90  FF87    4
	FCB -76         -60.00  -76.00  FF88    5
	FCB -75         -59.50  -75.10  FF89    6
	FCB -74         -59.00  -74.20  FF8A    7
	FCB -73         -58.50  -73.30  FF8B    8
	FCB -72         -58.00  -72.40  FF8C    9
	FCB -71         -57.50  -71.50  FF8D    10
	FCB -70         -57.00  -70.60  FF8E    11
	FCB -69         -56.50  -69.70  FF8F    12
	FCB -68         -56.00  -68.80  FF90    13
	FCB -67         -55.50  -67.90  FF91    14
	FCB -67         -55.00  -67.00  FF92    15
	FCB -66         -54.50  -66.10  FF93    16
	FCB -65         -54.00  -65.20  FF94    17
	FCB -64         -53.50  -64.30  FF95    18
	FCB -63         -53.00  -63.40  FF96    19
	FCB -62         -52.50  -62.50  FF97    20
	FCB -61         -52.00  -61.60  FF98    21
	FCB -60         -51.50  -60.70  FF99    22
	FCB -59         -51.00  -59.80  FF9A    23
	FCB -58         -50.50  -58.90  FF9B    24
	FCB -58         -50.00  -58.00  FF9C    25
	FCB -57         -49.50  -57.10  FF9D    26
	FCB -56         -49.00  -56.20  FF9E    27
	FCB -55         -48.50  -55.30  FF9F    28
	FCB -54         -48.00  -54.40  FFA0    29
	FCB -53         -47.50  -53.50  FFA1    30
	FCB -52         -47.00  -52.60  FFA2    31
	FCB -51         -46.50  -51.70  FFA3    32
	FCB -50         -46.00  -50.80  FFA4    33
	FCB -49         -45.50  -49.90  FFA5    34
	FCB -49         -45.00  -49.00  FFA6    35
	FCB -48         -44.50  -48.10  FFA7    36
	FCB -47         -44.00  -47.20  FFA8    37
	FCB -46         -43.50  -46.30  FFA9    38
	FCB -45         -43.00  -45.40  FFAA    39
	FCB -44         -42.50  -44.50  FFAB    40
	FCB -43         -42.00  -43.60  FFAC    41
	FCB -42         -41.50  -42.70  FFAD    42
	FCB -41         -41.00  -41.80  FFAE    43
	FCB -40         -40.50  -40.90  FFAF    44
	FCB -40         -40.00  -40.00  FFB0    45
	FCB -39         -39.50  -39.10  FFB1    46
	FCB -38         -39.00  -38.20  FFB2    47
	FCB -37         -38.50  -37.30  FFB3    48
	FCB -36         -38.00  -36.40  FFB4    49
	FCB -35         -37.50  -35.50  FFB5    50
	FCB -34         -37.00  -34.60  FFB6    51
	FCB -33         -36.50  -33.70  FFB7    52
	FCB -32         -36.00  -32.80  FFB8    53
	FCB -31         -35.50  -31.90  FFB9    54
	FCB -31         -35.00  -31.00  FFBA    55
	FCB -30         -34.50  -30.10  FFBB    56
	FCB -29         -34.00  -29.20  FFBC    57
	FCB -28         -33.50  -28.30  FFBD    58
	FCB -27         -33.00  -27.40  FFBE    59
	FCB -26         -32.50  -26.50  FFBF    60
	FCB -25         -32.00  -25.60  FFC0    61
	FCB -24         -31.50  -24.70  FFC1    62
	FCB -23         -31.00  -23.80  FFC2    63
	FCB -22         -30.50  -22.90  FFC3    64
	FCB -22         -30.00  -22.00  FFC4    65
	FCB -21         -29.50  -21.10  FFC5    66
	FCB -20         -29.00  -20.20  FFC6    67
	FCB -19         -28.50  -19.30  FFC7    68
	FCB -18         -28.00  -18.40  FFC8    69
	FCB -17         -27.50  -17.50  FFC9    70
	FCB -16         -27.00  -16.60  FFCA    71
	FCB -15         -26.50  -15.70  FFCB    72
	FCB -14         -26.00  -14.80  FFCC    73
	FCB -13         -25.50  -13.90  FFCD    74
	FCB -13         -25.00  -13.00  FFCE    75
	FCB -12         -24.50  -12.10  FFCF    76
	FCB -11         -24.00  -11.20  FFD0    77
	FCB -10         -23.50  -10.30  FFD1    78
	FCB -9          -23.00  -9.40   FFD2    79
	FCB -8          -22.50  -8.50   FFD3    80
	FCB -7          -22.00  -7.60   FFD4    81
	FCB -6          -21.50  -6.70   FFD5    82
	FCB -5          -21.00  -5.80   FFD6    83
	FCB -4          -20.50  -4.90   FFD7    84
	FCB -4          -20.00  -4.00   FFD8    85
	FCB -3          -19.50  -3.10   FFD9    86
	FCB -2          -19.00  -2.20   FFDA    87
	FCB -1          -18.50  -1.30   FFDB    88
	FCB 0           -18.00  -0.40   FFDC    89
	FCB 0           -17.50   0.50   FFDD    90
	FCB 1           -17.00   1.40   FFDE    91
	FCB 2           -16.50   2.30   FFDF    92
	FCB 3           -16.00   3.20   FFE0    93
	FCB 4           -15.50   4.10   FFE1    94
	FCB 5           -15.00   5.00   FFE2    95
	FCB 6           -14.50   5.90   FFE3    96
	FCB 7           -14.00   6.80   FFE4    97
	FCB 8           -13.50   7.70   FFE5    98
	FCB 9           -13.00   8.60   FFE6    99
	FCB 9           -12.50   9.50   FFE7    100
	FCB 10          -12.00  10.40   FFE8    101
	FCB 11          -11.50  11.30   FFE9    102
	FCB 12          -11.00  12.20   FFEA    103
	FCB 13          -10.50  13.10   FFEB    104
	FCB 14          -10.00  14.00   FFEC    105
	FCB 15          -9.50   14.90   FFED    106
	FCB 16          -9.00   15.80   FFEE    107
	FCB 17          -8.50   16.70   FFEF    108
	FCB 18          -8.00   17.60   FFF0    109
	FCB 18          -7.50   18.50   FFF1    110
	FCB 19          -7.00   19.40   FFF2    111
	FCB 20          -6.50   20.30   FFF3    112
	FCB 21          -6.00   21.20   FFF4    113
	FCB 22          -5.50   22.10   FFF5    114
	FCB 23          -5.00   23.00   FFF6    115
	FCB 24          -4.50   23.90   FFF7    116
	FCB 25          -4.00   24.80   FFF8    117
	FCB 26          -3.50   25.70   FFF9    118
	FCB 27          -3.00   26.60   FFFA    119
	FCB 27          -2.50   27.50   FFFB    120
	FCB 28          -2.00   28.40   FFFC    121
	FCB 29          -1.50   29.30   FFFD    122
	FCB 30          -1.00   30.20   FFFE    123
	FCB 31          -0.50   31.10   FFFF    124
	FCB 32           0.00   32.00   0000    125
	FCB 33           0.50   32.90   0001    126
	FCB 34           1.00   33.80   0002    127
	FCB 35           1.50   34.70   0003    128
	FCB 36           2.00   35.60   0004    129
	FCB 36           2.50   36.50   0005    130
	FCB 37           3.00   37.40   0006    131
	FCB 38           3.50   38.30   0007    132
	FCB 39           4.00   39.20   0008    133
	FCB 40           4.50   40.10   0009    134
	FCB 41           5.00   41.00   000A    135
	FCB 42           5.50   41.90   000B    136
	FCB 43           6.00   42.80   000C    137
	FCB 44           6.50   43.70   000D    138
	FCB 45           7.00   44.60   000E    139
	FCB 45           7.50   45.50   000F    140
	FCB 46           8.00   46.40   0010    141
	FCB 47           8.50   47.30   0011    142
	FCB 48           9.00   48.20   0012    143
	FCB 49           9.50   49.10   0013    144
	FCB 50          10.00   50.00   0014    145
	FCB 51          10.50   50.90   0015    146
	FCB 52          11.00   51.80   0016    147
	FCB 53          11.50   52.70   0017    148
	FCB 54          12.00   53.60   0018    149
	FCB 54          12.50   54.50   0019    150
	FCB 55          13.00   55.40   001A    151
	FCB 56          13.50   56.30   001B    152
	FCB 57          14.00   57.20   001C    153
	FCB 58          14.50   58.10   001D    154
	FCB 59          15.00   59.00   001E    155
	FCB 60          15.50   59.90   001F    156
	FCB 61          16.00   60.80   0020    157
	FCB 62          16.50   61.70   0021    158
	FCB 63          17.00   62.60   0022    159
	FCB 63          17.50   63.50   0023    160
	FCB 64          18.00   64.40   0024    161
	FCB 65          18.50   65.30   0025    162
	FCB 66          19.00   66.20   0026    163
	FCB 67          19.50   67.10   0027    164
	FCB 68          20.00   68.00   0028    165
	FCB 69          20.50   68.90   0029    166
	FCB 70          21.00   69.80   002A    167
	FCB 71          21.50   70.70   002B    168
	FCB 72          22.00   71.60   002C    169
	FCB 72          22.50   72.50   002D    170
	FCB 73          23.00   73.40   002E    171
	FCB 74          23.50   74.30   002F    172
	FCB 75          24.00   75.20   0030    173
	FCB 76          24.50   76.10   0031    174
	FCB 77          25.00   77.00   0032    175
	FCB 78          25.50   77.90   0033    176
	FCB 79          26.00   78.80   0034    177
	FCB 80          26.50   79.70   0035    178
	FCB 81          27.00   80.60   0036    179
	FCB 81          27.50   81.50   0037    180
	FCB 82          28.00   82.40   0038    181
	FCB 83          28.50   83.30   0039    182
	FCB 84          29.00   84.20   003A    183
	FCB 85          29.50   85.10   003B    184
	FCB 86          30.00   86.00   003C    185
	FCB 87          30.50   86.90   003D    186
	FCB 88          31.00   87.80   003E    187
	FCB 89          31.50   88.70   003F    188
	FCB 90          32.00   89.60   0040    189
	FCB 90          32.50   90.50   0041    190
	FCB 91          33.00   91.40   0042    191
	FCB 92          33.50   92.30   0043    192
	FCB 93          34.00   93.20   0044    193
	FCB 94          34.50   94.10   0045    194
	FCB 95          35.00   95.00   0046    195
	FCB 96          35.50   95.90   0047    196
	FCB 97          36.00   96.80   0048    197
	FCB 98          36.50   97.70   0049    198
	FCB 99          37.00   98.60   004A    199
	FCB 99          37.50   99.50   004B    200
	FCB 100         38.00   100.40  004C    201
	FCB 101         38.50   101.30  004D    202
	FCB 102         39.00   102.20  004E    203
	FCB 103         39.50   103.10  004F    204
	FCB 104         40.00   104.00  0050    205
	FCB 105         40.50   104.90  0051    206
	FCB 106         41.00   105.80  0052    207
	FCB 107         41.50   106.70  0053    208
	FCB 108         42.00   107.60  0054    209
	FCB 108         42.50   108.50  0055    210
	FCB 109         43.00   109.40  0056    211
	FCB 110         43.50   110.30  0057    212
	FCB 111         44.00   111.20  0058    213
	FCB 112         44.50   112.10  0059    214
	FCB 113         45.00   113.00  005A    215
	FCB 114         45.50   113.90  005B    216
	FCB 115         46.00   114.80  005C    217
	FCB 116         46.50   115.70  005D    218
	FCB 117         47.00   116.60  005E    219
	FCB 117         47.50   117.50  005F    220
	FCB 118         48.00   118.40  0060    221
	FCB 119         48.50   119.30  0061    222
	FCB 120         49.00   120.20  0062    223
	FCB 121         49.50   121.10  0063    224
	FCB 122         50.00   122.00  0064    225
	FCB 123         50.50   122.90  0065    226
	FCB 124         51.00   123.80  0066    227
	FCB 125         51.50   124.70  0067    228
	FCB 126         52.00   125.60  0068    229
	FCB 126         52.50   126.50  0069    230
	FCB 127         53.00   127.40  006A    231
	FCB 128         53.50   128.30  006B    232
	FCB 129         54.00   129.20  006C    233
	FCB 130         54.50   130.10  006D    234
	FCB 131         55.00   131.00  006E    235
	FCB 132         55.50   131.90  006F    236
	FCB 133         56.00   132.80  0070    237
	FCB 134         56.50   133.70  0071    238
	FCB 135         57.00   134.60  0072    239
	FCB 135         57.50   135.50  0073    240
	FCB 136         58.00   136.40  0074    241
	FCB 137         58.50   137.30  0075    242
	FCB 138         59.00   138.20  0076    243
	FCB 139         59.50   139.10  0077    244
	FCB 140         60.00   140.00  0078    245
	FCB 141         60.50   140.90  0079    246
	FCB 142         61.00   141.80  007A    247
	FCB 143         61.50   142.70  007B    248
	FCB 144         62.00   143.60  007C    249
	FCB 144         62.50   144.50  007D    250
	FCB 145         63.00   145.40  007E    251
	FCB 146         63.50   146.30  007F    252
	FCB 147         64.00   147.20  0080    253
	FCB 148         64.50   148.10  0081    254
	FCB 149         65.00   149.00  0082    255
	FCB 150         65.50   149.90  0083    256
*
*        
**************************************************************************
* START - Cabin System Software (CSS) begins execution
**************************************************************************
*
STARTUP EQU     *               In the beginning...
	JSR     CSSINIT         Initialize the system and variables
*
* Here is our major loop:
* 
*       1) Look for Modem activity
*       2) Look for CP290 activity
*       3) Look for Local activity
*       
MAJLOOP EQU     *
	JSR     CKMODEM         See if anyone is calling
	BCC     MAJLOO1         No...jump
	JSR     DOMODEM         Do modem activity
*
MAJLOO1 JSR     CKCP290         See if we need to do something
	BCC     MAJLOO2         No...jump
	JSR     DOCP290         Do the CP290 activity
*
MAJLOO2 JSR     CKLOCAL         See if someone local needs information.
	BCC     MAJLOO3         No...jump
	JSR     DOLOCAL         Do the Local activity
*
MAJLOO3 JSR     KEEPTIM         Make realtime display updates
	BRA     MAJLOOP         Continue major loop
*      
	LDAA    #$50            To enable the stop command
	TAP                     Put it in the CC register
	STOP                    This is here to halt the CPU on runaway
*
*
**************************************************************************
* CSSINIT - CSS Initialization routine
**************************************************************************
*
* Routine: This routine assumes we are just starting from power up.
*       RAM initialization, setup, and communication/health checks
*       are made.  We want to recognize a power failure by looking to
*       the CP290 for information.   
*
*       There are two type of starts: COLD and WARM.   We inquire the
*       time of the the CP290.    If it is up and happy, then we assume
*       a WARM start, retrieve the stored data in the NVRAM of the CP290
*       and begin our execution.
*
*       If the CP290 does not have a good time, then we cold start the
*       system.   This implies restarting the CP290 from a fixed time,
*       and reinitialization of all data structures.
*
CSSINIT EQU     *
*
* Setup the system options to turn on the A/D converter
*
	LDAA    #$90            Power up the A/D
	STAA    OPTION          ADPU + DLY
	LDX     #PORTA          Address of port A
	BSET    0,X #WINDON     Turn off the wind enable bit - LOW ACTIVE
*
* Next  we make sure the RAM is clean for startup
*
	LDX     #STRRAM         Starting RAM address to clear
	LDY     #NUMRAM         How many locations we must do
	CLRA                    This is what we will load
	COMA                    All ones
CSSINI2 STA     0,X             Store the value
	INX                     Go to the next address
	DEY                     Count it down
	BNE     CSSINI2         Continue till we are done
*        
	CLR     UNSIGN          Flag to ITOA conversion
	CLR     UNPAD           Flag to ITOA padding
	JSR     CPINIT          Setup the host port for the CP290
	JSR     LCDINIT         Setup the LCD
*
* Here we wait 10 seconds to give the CP290 a chance to get started
*
	LDAA    #10             Wait 10 seconds
CSCINI4 STAA    PORTB           Just as an indication we are alive
	JSR     WAITONE         Delay
	DECA                    Count down
	BNE     CSCINI4         Continue till we are done
*
* Now get the data and time from the CP290...if unit has lost all data 
* then assume a cold start and reset everything
*
	JSR     GETDATE         Fetch the CP290 time first to see if OK
	BCC     CSSINI5         The date is bad...this is a cold start
	LDY     #WRMDATE        Location to save into
	JSR     SAVTIME         Temporary save...just need CURHR/MIN time 
	JSR     UPSAVED         Get the saved data from the CP290
	BCC     CSSINI5         Jump...data is gone we have a cold start!
	LDY     #SCNDATE        Save area for last scan before power fail
	JSR     SAVTIME         Move the CURTIM here for the printout 
	LDY     #WRMDATE        Here we adjust the CURHR/MIN for warm start
	LDAA    1,Y             Get CURHR
	STAA    CURHR           Save it back
	LDAA    3,Y             Get CURMIN
	STAA    CURMIN          Save it back
	JSR     SAVTIME         Copy the time we began from powerfail
	LDY     #DSPTIM         Copy the current time into the display time
	JSR     SAVTIME         This is to setup display time for WHATDAY
	JSR     WHATDAY         All of this to just set the WKWDAY value
	BRA     CSSINI8         The date is good...this is a warm start
*
* Here we have a cold start...data in the CP290 is gone
* So we must reload and begin from scratch and setup some defaults
* Here we start from our given birthday from power up condition
*
CSSINI5 LDAA    #BDYR           Birthday year
	STAA    CURYR           Save it
	LDAA    #BDMON          Birthday month
	STAA    CURMON          Save it
	LDAA    #BDDAY          Birthday day
	STAA    CURDAY          Save it
	LDAA    #BDWDAY         Birthday day of the week
	STAA    WKWDAY          Save it
	LDAA    #59             Sixty seconds we count down
	STAA    CURSEC          Save it away
	CLR     CURHR           Starting from midnight
	CLR     CURMIN          The clock has chimed.
*
	LDY     #WRMDATE        Location to save into
	JSR     SAVTIME         Copy the time we began from powerfail
	LDY     #SCNDATE        Save area for last scan before power fail
	JSR     SAVTIME         Reset this date value as well 
	LDAA    #1              One signon
	STAA    SIGNONG         Good signon count increment (NOTE: CP290 err)
	JSR     SETUPC4         Save it all so we can come up clean
*        
CSSINI8 EQU     *
	LDX     #HISTOP         Must reset the history forward link 
	STX     HFLINK          Save it for the next scan
	CLRA                    Clear 
	CLRB                    Ditto
	STD     NUMSCAN         Store zero in the number of scans
	CLR     CURDPTR         This is our history index...we start over
	CLR     NUMDPTR         We start over with number of history days
	CLR     DSPOINT         This is our display counter
	CLR     RAINFAL         This is our rainfall counter
*        
* Here we setup the initial state of the MAX/MIN history values
*
	JSR     SGATHER         Get the initial sensor conditions
	JSR     HISETUP         Setup the values
*
	LDAA    #40             This will be a one second delay
	JSR     DELAYIT         Setup the delay timer
	RTS                     Return to the main loop
*
*
**************************************************************************
* SNDSNC - Sends the 16 byte sync bytes the CP290 
**************************************************************************
*
* Routine: Sends to the CP290 16 sync bytes to begin command transfer
*
SNDSNC  EQU     *               Send the 16byte sync to the CP290
	LDAB    #16             We will do this 16 times
	LDAA    #$FF            What to send
*
* Wait for the transmitter to finish any work already in progress
*
SNDSNC1 JSR     CPUT290         Send it out to the CP290
	DECB                    Count it down
	BNE     SNDSNC1         Do it again...until it is over
	RTS                     Back to the caller
*
*       
*
**************************************************************************
* CPUT290 - Sends a byte to the CP290 
**************************************************************************
*
* Routine: Sends the byte in A to the CP290
*
* All registers are saved
*
CPUT290 EQU     *               Sends a byte the CP290
	PSHA                    Save the register
*
* Wait for the transmitter to finish any work already in progress
*
CPUT291 LDAA    SCSR            Get the SCI status register
	BITA    #$80            Check to see if we are still in transmit mode
	BEQ     CPUT291         Continue to wait for transmitter to clear
*
* The transmitter is clear, now send the sync byte to the CP290
*
	PULA                    Restore the data value we are to send
	STAA    SCDAT           Send it to the CP290
	RTS                     Back to the caller
*
*       
*
**************************************************************************
* GETDATE - Routine to get the time/date from the CP290
**************************************************************************
*
* Routine: Sends the sync bytes, then the command to get the date 
*       from the CP290.   
*
* Carry flag is set if date is fetched OK
* Carry flag is clear if we failed for some reason
*
GETDATE EQU     *               Get the time/date from the CP290
	LDX     #PCFIFO         Get the FIFO address
	CLR     6,X             Clear the status value to assume failure.
	JSR     SNDSNC          Send the sync bytes
	LDAA    #REQCLK         Request Clock command
	JSR     CPUT290         Send it to the CP290
	LDAA    #12             We expect to get these bytes back
	JSR     GETCPD          Get the data from the CP290
	TST     PCFPTR          Get the PC forward pointer
	BEQ     GETDAT7         Bad...we should have something
*
	LDX     #PCFIFO         Get the FIFO address
	LDAA    6,X             Get the value
	BEQ     GETDAT7         Bad...we should have something
*        
* Here we just want the hours and minutes and day
*
	LDAA    7,X             Get the value
	STAA    CURMIN          Minutes
	LDAA    8,X             Get the value
	STAA    CURHR           Hours
	LDAA    9,X             Get the value
	STAA    CURWDAY         Day of the week
	SEC                     Set carry to say we have date
	BRA     GETDAT9         Jump and return
*
GETDAT7 CLC                     We failed...
GETDAT9 RTS                     Back to the caller
*
*
*
**************************************************************************
* GETCPD - Receives a data message from the CP290
**************************************************************************
*
* Routine: GETCPD is a general purpose routine to get information from 
*       the CP290 and put the data into the buffer indicated by the index
*       register.   We don't want to get stuck waiting on the CP290
*       in case it dies for some reason, so we use the DELAY function
*       to serve as our exit point.   When the timer goes off we assume
*       we got all the data we were going to get, then we return to the 
*       caller.
*
*       Register A contains the number of bytes we expect to receive back
*
* Output - The PCFIFO will contain the message from the CP290.   This is
*       because we are using a shared routine which places the data into
*       this buffer to be shipped to the PeeCee.
*
GETCPD  EQU     *               Get data from the CP290
	PSHA                    Save A
	CLR     PCFPTR          Clear PeeCee FIFO forward pointer
	CLR     PCFIFO          Clear first data byte in the FIFO
	LDAA    #60             This is 1 1/2 seconds (25msec * 60) 
	JSR     DELAYIT         Initialize the wait loop
	PULA                    Bring A back
*
GETCPD1 PSHA                    Save it for our looping
	JSR     CP290IN         Get any data from the CP290
	PULA                    Get A back
	CMPA    PCFPTR          See if we have done enough
	BEQ     GETCPD9         Yes...jump and exit
	JSR     DELAY           Check for time out
	BCC     GETCPD1         Continue to loop
*
GETCPD9 EQU     *               We are done
	RTS                     Back to the caller
*
*
*
**************************************************************************
* CPTMPC - Transparent communication with CP290 and the PeeCee
**************************************************************************
*
* Routine: This code places the CSS in transparent mode with the CP290
*       to allow the communication from the PeeCee.   The purpose is to
*       use standard X10 software when making setup changes with the 
*       CP290.
*
* The BREAK transmitted from the PeeCee, or the modem dropping carrier 
*       will get us out of the transparent loop
*
CPTMPC  EQU     *               Begin Transparent mode
	CLR     TFLAG           This will be our break counter
	CLR     CPFPTR          Clear CP290 FIFO forward pointer
	CLR     PCFPTR          Clear PeeCee FIFO forward pointer
	CLR     CPBPTR          Clear CP290 FIFO back pointer
	CLR     PCBPTR          Clear PeeCee FIFO back pointer 
*
* This is the character exchange loop 
*
CP290A  EQU     *
	JSR     PCIN            See if we have a character from the PeeCee
*
* Each time thru the loop we check to see if we got a BREAK 
* OR the DCD went away meaning that the MODEM user has gone.
*
	BVS     CP290B          Exit back to the caller
*
	JSR     CP290OUT        Send the char to the CP290
	JSR     CP290IN         See if the CP290 has anything to say
	JSR     PCOUT           CP290 has a char...send it to the PeeCee
	BRA     CP290A          And then continue looking for data

CP290B  EQU     *               Either we got a BREAK, or DCD went away, so
	RTS                     Return to the caller
*
*
*
**************************************************************************
* CPINIT - Initialize the SCI port for CP290 communication
**************************************************************************
*
* Routine:  This short routine does the setup on the SCI port and sets
*       the baud rate to 600 for the CP290.
*
CPINIT  CLR     HOSTDEV         Make sure we point to the SCI device
	JSR     HOSTCO          Connect the CP290 using the SCI port
	JSR     HOSTINI         Initialize the port
	LDAA    #$34            Set for 600 baud of the CP290
	STAA    BAUD            Put it in the BAUD register...and begin
	LDAA    SCSR            Read the SCI status register
	LDAA    SCDAT           Get the data
	RTS                     Back to the caller
*
*
*
**************************************************************************
* PCIN - This routine gets data from the PeeCee and puts it in the FIFO
**************************************************************************
*
* Routine: This routine is the almost the same as the INPUT routine, however
*       it does not AND off the parity bit and it sets the carry bit when
*       there is data.   
*
*       Output: Data is returned in A if carry is set, plus the data
*       is placed in the CPFIFO for transmit out to the CP290
*
*       If a BREAK is given, then the Overflow flag is set
*       If DCD is not there, then the Overflow flag is set
*
PCIN    EQU    *
	LDAA    PORTA           Get PORTA value
	ANDA    #DCDFLAG        See if we are still have DCD from the MODEM
	BNE     PCIN0           Clear is active...jump if user is gone
*
	LDX     #ACIA           Address the ACIA
	LDAA    0,X             Get the CSR
	PSHA                    Save the CSR
	ANDA    #$70            Check PE, OV, FE
	PULA                    Restore the CSR
	BEQ     PCIN2           No error, then jump look for data
*
	BITA    #$10            Check just the frame error flag
	BEQ     PCIN1           Not a frame error...jump
	LSRA                    Check RDRF - do we have data?
	BCC     PCIN1           No data...but could be another error
	LDAA    1,X             Get the data into A   
	BNE     PCIN1           Then reset the ACIA
	JSR     WAITONE         Wait a second...
	INC     TFLAG           We have a break...check to see if double
	LDAA    TFLAG           Get the value
	CMPA    #2              See if we have double
	BNE     PCIN1           No...continue to look for data
PCIN0   JSR     ONACIA          Master Reset the ACIA
	SEV                     Set the overflow flag...we have a BREAK
	SEC                     Turn on the carry as well
	BRA     PCIN4           Go back to the caller and get us out of here
*
* Here we made some kind of ACIA error...reset the device and start over.        
*
PCIN1   JSR     ONACIA          Master Reset the ACIA
	BRA     PCIN            Continue to look for data
*       
* No errors, now look for receive data
*
PCIN2   LSRA                    Check RDRF - do we have data?
	BCC     PCIN4           No data...jump and exit
	LDAA    1,X             Get the data into A   
	LDX     #CPFIFO         Address of the transmit fifo
	LDAB    CPFPTR          Get the fifo forward pointer
	ABX                     Add the pointer to the X reg
	STAA    0,X             Save the data byte in the FIFO
	INCB                    Bump the pointer
	CMPB    #FIFOMAX        See if we are in wrap around condition
	BNE     PCIN3           No wrap around...jump
	CLRB                    Start the forward pointer over
PCIN3   STAB    CPFPTR          Save the forward pointer back
	CLR     TFLAG           Reset the break counter since we have data
	SEC                     Set the carry to say we have data
	CLV                     Clear the overflow flag - No break given
PCIN4   RTS                     Back to the caller
*
*
**************************************************************************
* PCOUT - Sends data from the FIFO to the PeeCee
**************************************************************************
*
* Routine: This routine is the same as OUTACIA except that it does
*       sent out the LF/CR sequence and does not AND off the parity
*       All data is put in the FIFO for the CP290.
*
PCOUT   EQU     *
	LDAB    PCFPTR          Get the forward FIFO pointer
	CMPB    PCBPTR          See if there is anything to send
	BEQ     PCOUT4          Nothing to send...exit
*
* We have data to send, now check to see if we are busy transmitting
*
	LDX     #ACIA           Address the ACIA
	LDAA    0,X             Get the CSR register
	BITA    #$2             Check the transmitter
	BEQ     PCOUT4          We are still busy...exit
*
* We have data and the transmitter is clear, get the data and send it
*
	LDX     #PCFIFO         Address of the transmit fifo
	LDAB    PCBPTR          Get the fifo backward pointer
	ABX                     Add the pointer to the X reg
	LDAA    0,X             Get the data byte out of the FIFO
	INCB                    Bump the pointer
	CMPB    #FIFOMAX        See if we are in wrap around condition
	BNE     PCOUT2          No wrap around...jump
	CLRB                    Start the backward pointer over
PCOUT2  STAB    PCBPTR          Save the backward pointer back
	LDX     #ACIA           Address the ACIA
	STAA    1,X             Store the data ... at last
PCOUT4  RTS
*
*
*
**************************************************************************
* CP290IN - Gets data from the CP290 and places it in the PC FIFO 
**************************************************************************
*
* Routine: This routine is used by the transparent mode with the CP290
*       The routine is the same as HOSTIN, however it does not
*       strip off the parity bit before returning the data
*
* The value read is returned in the A register and carry is set
*
CP290IN EQU     *
	LDAA    SCSR            Read the SCI status register
	ANDA    #$20            Check the RDRF flag
	BEQ     CP290I4         Nothing to read
	LDAA    SCDAT           Get the data
	LDX     #PCFIFO         Address of the transmit fifo
	LDAB    PCFPTR          Get the fifo forward pointer
	ABX                     Add the pointer to the X reg
	STAA    0,X             Save the data byte in the FIFO
	INCB                    Bump the pointer
	CMPB    #FIFOMAX        See if we are in wrap around condition
	BNE     CP290I2         No wrap around...jump
	CLRB                    Start the forward pointer over
CP290I2 STAB    PCFPTR          Save the forward pointer back
	SEC                     Set the carry flag
	BRA     CP290I9         Jump and exit out
*
CP290I4 CLC                     Flag that nothing was read
CP290I9 RTS                     Back to the caller
*
*
*
**************************************************************************
* CP290OUT - Sends data from the FIFO to the CP290
**************************************************************************
*
* Routine: This routine is used by the transparent mode with the CP290
*       The routine is the same as HOSTOUT, however not clearing
*       the parity and doing the LF/CR things.  Also we send only from
*       the FIFO.
*
CP290OUT EQU    *
	LDAB    CPFPTR          Get the forward FIFO pointer
	CMPB    CPBPTR          See if there is anything to send
	BEQ     CP290O4         Nothing to send...exit
*
* We have data to send, now check to see if we are busy transmitting
*
	LDAB    SCSR            Get the SCI status
	BITB    #$80            Are we busy transmitting?
	BEQ     CP290O4         Yes...exit and do something else
*
* We have data and the transmitter is clear, get the data and send it
*
	LDX     #CPFIFO         Address of the transmit fifo
	LDAB    CPBPTR          Get the fifo backward pointer
	ABX                     Add the pointer to the X reg
	LDAA    0,X             Get the data byte out of the FIFO
	INCB                    Bump the pointer
	CMPB    #FIFOMAX        See if we are in wrap around condition
	BNE     CP290O2         No wrap around...jump
	CLRB                    Start the backward pointer over
CP290O2 STAB    CPBPTR          Save the backward pointer back
	STAA    SCDAT           Send the data
CP290O4 RTS                     Back to the caller
*
*
*
******************************************************************************
* SIGNON - Validate the remote user of CSS
******************************************************************************
*
* Routine: This routine is entered when the DCD line goes active indicating
*       a user has dialed the modem and is ready to begin dialog with the
*       CSS.   The design of this module is to 'look and feel' like a VMS
*       system, however looks are oft time deceiving.  The purpose is to 
*       limit access to the system except to authorized folks, i.e. who
*       know the password.   Only the password is validated.  
*
*       To get a string of characters from the
*       user and place them in the CBUF until a CR or ^Z, with correct
*       handling of DEL char.   The CR or ^Z terminates the string with
*       a zero.   The case is convered to upper. 
*
* Function: This is called anyone communication with the outside world.
*       The ECHOIT variable is tested to determin if we echo the input
*       back to the output.
*
* Returns: The Carry is set if there is valid data in the CBUF.
*       If Carry is clear, then DCD is gone and we need to get back
*       to our main loop.   If Carry is set and CBUF is blank, then
*       only a CR or ^Z was read.
*
* Date: 27-Aug-1993
*



* Now we wait here for two <CR>s from the user and then display the
* signon message.
*               
SIGNON  EQU     *
	CLR     TFLAG           This will count our CR times
	CLR     AUTOLF          Do not give an auto line feed
	CLR     ECHOIT          We do not want to echo here
SIGNON1 EQU     *
	JSR     GETSTR          Wait for the user to enter CR
	BCC     SIGNOFF         User is gone...return to main loop
*
	TST     CBUFFPT         See if this is zero indicating just a CR
	BNE     SIGNON          No...coutinue to look
	TST     TFLAG           Is the second time thru?
	BNE     SIGNON2         We have two CRs...now send banner
	INC     TFLAG           Yes...we got a CR
	BRA     SIGNON1         Look for another
*
SIGNON2 EQU     *               Begin display
	INC     AUTOLF          We want to LF now
	LDX     #VMSMSG         Load up the banner message
	JSR     OUTSTRG         Send it out
SIGNON3 LDX     #VMSMSG1        Load up the username request message
	JSR     OUTSTRG         Send it out
	INC     ECHOIT          Echo the input
	JSR     GETSTR          See who it is
	BCC     SIGNOFF         User is gone...return to main loop
	TST     CBUFFPT         See if this is zero indicating just a CR
	BEQ     SIGNON3         No...coutinue to look
*
* Now see if the user is a PC giving the special command for quick dump
*
	LDX     #CBUFF          This is what the user provided
	LDY     #CWORD          Check it against the desired value.
	JSR     STRCMP          Compare the data
	BCC     SIGNON4         This is valid...do the quick dump
*
* Here we have been given the short dump command, so we do a sensor scan
* then dump out the first part of memory, and return to the username
* prompt and continue looking for a valid signon.
*
	JSR     SGATHER         Poll the sensor devices
	LDX     #ADSCAN         Load the sensor value index to move from
	STX     PTR1            Save it here for the dump
	LDX     #ADSCANX        End address of the RAM
	STX     PTR2            Save it here for the dump
	JSR     DUMP1           Do it
	BRA     SIGNON3         Back to username and look for another
*
* Now we have a user name, we don't care who it is as long as they
* know the magic password!
*
SIGNON4	LDX     #VMSMSG2        Load up the password request message
	JSR     OUTSTRG         Send it out
	CLR     ECHOIT          No Echo now
	JSR     GETSTR          See who it is
	INC     ECHOIT          Turn Echo back on
	BCC     SIGNOFF         User is gone...return to main loop
	LDX     #CBUFF          This is the user's name
	LDY     #PWORD          This is what is must be.
	JSR     STRCMP          Compare the data
	BCS     SIGNON5         This is valid...Welcome to the Cabin system
*
* Here we handle the invalid user entry
*
	LDX     #VMSMSG4        Load up the failure message
	JSR     OUTSTRG         Send it out
	BRA     SIGNOFF         And let him try again if DCD continues
*
* Here we welcome the user to the system and return to the main routine
*
SIGNON5 EQU     *
	SEC                     Set the carry to say we are OK to go on
	INC     SIGNONG         Good signon count increment
	INC     ECHOIT          Echo the input flag back on 
	RTS                     Return to the caller
*
SIGNOFF CLC                     Clear the carry to say the user is gone
	INC     SIGNONB         Bad signon count increment
	RTS                     Return to the caller
*
*
*
******************************************************************************
* GETSTR - Get a string of characters
******************************************************************************
*
* Routine: This routine is entered to get a string of characters from the
*       user and place them in the CBUF until a CR or ^Z, with correct
*       handling of DEL char.   The CR or ^Z terminates the string with
*       a zero.   The case is convered to upper. 
*
* Function: This is called anyone communication with the outside world.
*       The ECHOIT variable is tested to determin if we echo the input
*       back to the output.
*
* Returns: The Carry is set if there is valid data in the CBUF.
*       If Carry is clear, then DCD is gone and we need to get back
*       to our main loop.   If Carry is set and CBUF is blank, then
*       only a CR or ^Z was read.
*
* Date: 27-Aug-1993
*
*               
GETSTR  EQU     *
	CLR     CBUFF           Reset the first character to zero
	CLR     CBUFFPT         Reset the character counter to zero
	CLR     CBUFFOV         Clear the last byte, just in case we run over
*
* Here we wait for data from the ACIA or until DCD drops indicating
* the modem has lost carrier and the user has gone
*
GETSTR1 JSR     INPUT           Get a character if there is one
	TSTA                    Anything?
	BNE     GETSTR2         Jump, we have input
	LDX     #PORTA          No data...check DCD. Get the address of PORT A
	BRCLR   0,X DCDFLAG GETSTR1     We still have a carrier detect...loop
	CLC                     Otherwise Indicate that the user is gone.
	BRA     GETSTR9         Back to the caller
*
* We have a character now in A.   Check for a delete, then make it upper case
*
GETSTR2 CMPA    #$7f            See if it is a DELETE
	BEQ     GETSTR3         Yes...jump
	CMPA    #BACKSP         See if it is a BACKSPACE
	BNE     GETSTR5         No...jump
*
*       We have a delete or backspace...process it 
*
GETSTR3 TST     CBUFFPT         Check if we have cleared it all
	BEQ     GETSTR          Nothing to delete...contine to input
	TST     ECHOIT          Check the flag if we are to ECHO 
	BEQ     GETSTR4         Zero is no echo...jump
	LDAA    #BACKSP         Backspace
	JSR     OUTPUT          Put it back to the user
	LDAA    #ASPACE         Space
	JSR     OUTPUT          Put it back to the user
	LDAA    #BACKSP         Backspace
	JSR     OUTPUT          Put it back to the user
GETSTR4 DEC     CBUFFPT         Back off the pointer
	LDAB    CBUFFPT         Get the character pointer
	LDX     #CBUFF          Get the address of the buffer
	ABX                     Add B to the address
	CLR     0,X             Clear this byte
	BRA     GETSTR1         Continue to get input
*
GETSTR5 JSR     UPCASE          Make it into upper case
	TST     ECHOIT          Check the flag if we are to ECHO 
	BEQ     GETSTR6         Zero is no echo...jump
	CLR     AUTOLF          No Line feed if CR
	JSR     OUTPUT          Put it back to the user
	INC     AUTOLF          Put LF back
GETSTR6 CMPA    #26             See if it is a ^Z
	BEQ     GETSTR7         Yes...wind down
	CMPA    #13             See if it is a RETURN
	BEQ     GETSTR7         Yes...wind down
*
	LDAB    CBUFFPT         Get the character pointer
	LDX     #CBUFF          Get the address of the buffer
	ABX                     Add B to the address
	STAA    0,X             Save this character byte
	CLR     1,X             Clear the next byte
	INCB                    Add one to our pointer
	CMPB    #CBUFFMX        See if we are at the limit
	BEQ     GETSTR7         Yes...exit
	STAB    CBUFFPT         Otherwise...save the counter
	BRA     GETSTR1         Continue to get input
*
GETSTR7 SEC                     Set the carry flag
GETSTR9 RTS                     Return to the caller
*
*
*
******************************************************************************
* STRCMP - Routine to compare two null terminated character strings
******************************************************************************
*
* Routine: This routine does a compare on two character buffers which
*       are zero terminated strings.
*
*       The X register points to string 1
*       The Y register points to string 2
*
*       The comparison continues until either string contains a zero.
*
*       A,B,X,Y are saved
*
* Returns: The Carry is set if the compare is exact.
*       If Carry is clear, then the compare failed.
*
* Date: 27-Aug-1993
*
STRCMP  EQU     *               Null terminated string compare
	PSHA                    Save the registers
	PSHB
	PSHX
	PSHY
STRCMP1 LDAA    0,X             Get a character from S1
	LDAB    0,Y             Get a character from S2
	CBA                     Check the two bytes
	BNE     STRCMP2         It is over...we did not compare
	INX                     Go to the next byte
	INY                     Ditto
	TSTA                    Is it a zero
	BNE     STRCMP1         No...continue to look
*
	SEC                     Set the carry flag we are equal
	BRA     STRCMP3         Restore regs and return
*
STRCMP2 CLC                     Clear the carry flag to indicate we failed
STRCMP3 PULY                    Restore the registers
	PULX
	PULB
	PULA
	RTS                     Return to the caller
*
*
*
******************************************************************************
* CKMODEM - Check for Modem activity
******************************************************************************
*
* Routine: This routine is called from the major loop to see if anyone is
*       connected remotely.
*
* Function: Check the DCD flag - PORT A bit 2 for activity 
*
* Returns: Sets the carry flag if active, otherwise clear the carry flag 
*
******************************************************************************
*
CKMODEM EQU     *
	LDX     #PORTA          No data...check DCD. Get the address of PORT A
	BRCLR   0,X DCDFLAG CKMODE1     We have a carrier detect...jump
	CLC                     Otherwise Indicate that there is no user.
	BRA     CKMODE2         No user...return with carry clear.
CKMODE1 SEC                     Set the carry flag
CKMODE2 RTS                     Return to the caller
*
*
*
******************************************************************************
* CKMODEM - Check for Modem activity
******************************************************************************
*
* Routine: This routine is called from the major loop to see if the CP290
*       is sending us any data.   If so, then we need to check what it is
*       and act accordingly.
*
* Function: Check the DCD flag - PORT A bit 2 for activity 
*
* Returns: Sets the carry flag if active, otherwise clear the carry flag 
*
******************************************************************************
*
CKCP290 EQU     *
	LDX     #SCSR           Get the address of the SCI status register
	BRSET   0,X RDFLAG CKCP291      We have a data ready flag...jump
	CLC                     Otherwise Indicate that there is no CP290 data.
	BRA     CKCP292         No data...return with carry clear.
CKCP291 SEC                     Set the carry flag
CKCP292 RTS                     Return to the caller
*
*
*
******************************************************************************
* CKLOCAL - Checks for Local CSS activity
******************************************************************************
*
* Routine: This routine is called from the major loop to see if someone 
*       local to the CSS has pressed a switch on the panel indicating 
*       they want some information displayed.
*
* Function: Check the switches for activity 
*
* Returns: Sets the carry flag if active, otherwise clear the carry flag 
*       The first switch pressed sets DSPOINT with a value 1-10 and exits. 
*
******************************************************************************
*
CKLOCAL EQU     *
	LDAA    #10             This will be our counter
*        
	LDAB    PORTA           Get the first two...0 & 1 - off and on
CKLOCA1 LSRB                    Shift down the value
	BCC     CKLOCA5         Carry is clear...switch active...jump & exit
	DECA                    Count it down
	CMPA    #8              Are we done?
	BNE     CKLOCA1         No...continue to loop 
*        
	LDAB    PORTC           Get the switch bank
CKLOCA2 LSRB                    Shift down the value
	BCC     CKLOCA5         Carry is clear...switch active...jump & exit
	DECA                    Count down our switch counter
	BNE     CKLOCA2         Continue to cycle thru the bits
*
* We have checked all the bits...none are set, so we clear the carry and exit
*
	CLC                     Clear the carry flag...no local user
	BRA     CKLOCA9         Jump and return
*
CKLOCA5 STAA    DSPOINT         Save the switch values
	SEC                     Set the carry and return
*
CKLOCA9 EQU     *                       
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* KEEPTIM - Updates the local display from the Major loop
******************************************************************************
*
* Routine: This routine is called from the major loop to:
*       1) Update the time keeping functions
*       2) Update the LCD time display.
*       3) Check the door status.
*       4) Check the rain sensor.
*       5) Update the LCD mode display.
*
******************************************************************************
*
KEEPTIM EQU     *
	JSR     DELAY           Count down our seconds
	BCC     KEEPTI9         Update the LCD and continue to wait
*
* A second is now over...update the counters
*
	LDAA    #40             This will be a one second delay
	JSR     DELAYIT         Setup the delay timer
	DEC     CURSEC          Count down the seconds
	LDAA    CURSEC          Get the seconds again
	BEQ     KEEPTI6         Zero...time to change the minute...jump
*        
* Here we cycle our LCD display every four seconds
*
	ANDA    #3              Every four seconds
	CMPA    #3              See if we are there
	BNE     KEEPTI7         Not time yet...jump
	LDAA    DSPOINT         Get the value
	CMPA    #DSPOMAX        See if we are over the max value
	BLO     KEEPTI3         Jump and Keep going if below the max
	CLRA                    Zero our counter
	CLR     DSPOINT         Start over
KEEPTI3 JSR     SETMODE         Set the mode
	INC     DSPOINT         Bump the next display point
	BRA     KEEPTI7         Keep going
*
* Now the minute is over...display the time and reset the counters
*
KEEPTI6 LDAA    #59             Another minutes worth of seconds
	STAA    CURSEC          Save it
	INC     CURMIN          Bump the minute
	JSR     LCDTIM          Show the time
	CLRA                    Clear our display counter to being the cycle
	JSR     SETMODE         Begin the LCD display variables
*
KEEPTI7 EQU     *
	LDAA    PORTE           Here we check the door status
	ANDA    #$1E            Just look at the four doors
	CMPA    DSTATUS         See if anything has changed
	BEQ     KEEPTI9         Nothing changed...jump and continue         
*
* since it is unlikely that someone can open the door in less than
* second, we put the door checking inside the second time loop
*
	JSR     UPDOORS         Update the door status
*
KEEPTI9 EQU     *
	
*
* since the rain guage event can occur quickly, unlike the door status, 
* this is in the fast loop, and is checked often.   With special debounce
*
	JSR     CHKRAIN         Check the rain guage status
	JSR     DSPMODE         Update the LCD state if necessary
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* CHKRAIN - Check the rain guage for activity
******************************************************************************
*
* Routine: This routine is called from the KEEPTIM loop to handle the 
*       rain guage events.
*
* The Rain indicator bit is PORT E bit 6
*
******************************************************************************
*
CHKRAIN EQU     *
	LDAA    PORTE           Get the status from port e
	ANDA    #$40            Just look at the rain bit = NORMAL is HIGH
	BNE     CHKRAI4         It is high, check for been low
*
* Here the value is low, check to see if we have been low for a second
*
	LDAA    CURSEC          Get the current seconds
	TST     BEENLOW         Clear = been low, otherwise = NORMAL
	BNE     CHKRAI2         First time thru...jump        
	CMPA    RAINSEC         See if we've been here for awhile
	BEQ     CHKRAI9         Yes...jump and continue to wait
*
* Now we catch the timer and get ready for the return event
*
CHKRAI2 STAA    RAINSEC         Save the current seconds
	CLR     BEENLOW         Clear our flag
	BRA     CHKRAI9         Exit back to the main loop
*
*
CHKRAI4 TST     BEENLOW         Clear = been low, otherwise = NORMAL
	BNE     CHKRAI9         Exit if NORMAL
*
* Here we've been low, now it's back high, are we still at the same second?
*
	LDAA    CURSEC          Get the current second counter
	CMPA    RAINSEC         Is it the same?
	BEQ     CHKRAI9         Yes...jump and continue to wait
*
* Now the time has passed, we can increment the rain sensor and continue
*
	INC     RAINFAL         Bump the counter
	INC     BEENLOW         Reset the flag
	COM     RAINSEC         Reset this indicator
CHKRAI9 EQU     *               
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* DOMODEM - Handles Remote user activity
******************************************************************************
*
* Routine: This routine is called from the major loop to handle the 
*       remote user activity.
*
******************************************************************************
*
DOMODEM EQU     *
	LDAA    #STMODEM        New state
	JSR     SETMODE         Change it
	JSR     SIGNON          Get the user logged in
	BCS     DOMODE0         User is still online...jump and continue
	JMP     DOMODE9         User gone or can't get in
*
* Give the user the LOGIN information and then give menu
*
DOMODE0 EQU     *
	JSR     SHOWCSS         Display the CSS status and time
DOMODE1 LDX     #DSPMSG2        Load up the Menu message
	JSR     OUTSTRG         Send it out
	JSR     GETSTR          Get the user pick
	BCC     DOMODE9         User is gone...so are we
	TST     CBUFFPT         See if this is zero indicating just a CR
	BEQ     DOMODE1         Yes...just return, so loop back up
*
* Now we process what the user has entered for a choice
*
	LDAB    CBUFF           Get the first input data byte
	CMPB    #ASCII0         See if it is less than 0
	BLT     DOMODE1         Less than $30, then display menu again
	CMPB    #MAXCMDS        See if we are greater than the maximum
	BGT     DOMODE1         Jump and give the menu again
*        
* Limits have been checked...now strip off the $30 and call the routine
*
	ANDB    #$0F            Just the low order nibble
	LSLB                    Multiply by 2
	LDX     #CMDTBLE        Get the command table
	ABX                     Add in the offset
	LDX     0,X             Fetch the address
	JSR     0,X             Do the command
	BRA     DOMODE1         Restore the menu
*
DOMODE9 EQU     *               
	JSR     NORMODE         Return LCD state display to normal
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* DODSPUD - Upload history data file to the remote system
******************************************************************************
*
* Routine: This routine is called from the remote/modem command menu to
*       upload the history data to the PeeCee system
*
******************************************************************************
*
DODSPUD EQU     *
	LDX     #DSPMSGM        This will take awhile...are you sure?
	JSR     OUTSTRG         Send it out
	JSR     GETYSNO         Get the user response
	BCC     DODSPU9         User is gone...so are we
	BVC     DODSPU9         No...it is not OK...jump back to main menu
	
	LDX     #DSPMSG4        Display Upload History Data message
	JSR     OUTSTRG         Send it out
	LDAA    #10             This is our counter
	STAA    TFLAG           This will be our delay counter
DODSPU1 JSR     WAITONE         Wait a second.
	DEC     TFLAG           Count it back
	LDAA    TFLAG           Get the counter
	BEQ     DODSPU2         We are done...jump and UPLOAD
	ORAA    #$30            Make it a ASCII char    
	JSR     OUTPUT          Send it out
	BRA     DODSPU1         Continue to wait
*
DODSPU2 EQU     *               Here we setup for the UPLOAD
	LDX     #STRRAM         Starting RAM location
	STX     PTR1            Save it here for the dump
	LDX     #ENDRAM         End address of the RAM
	STX     PTR2            Save it here for the dump
	JSR     DUMP1           Do it
*
	LDX     #DSPMSG5        Display Function complete.
	JSR     OUTSTRG         Send it out
	JSR     GETSTR          Wait for CR before we continue
DODSPU9 EQU     *        
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* DODSPTM - Enter transparant mode with CP290
******************************************************************************
*
* Routine: This routine is called from the remote/modem command menu to
*       begin transparant mode with the CP290 and the PeeCee.
*
* Note: We must monitor for a BREAK condition from the ACIA to get us out
*       of this loop.
*
******************************************************************************
*
DODSPTM EQU     *
	LDX     #DSPMSG6        Display Transparant mode message
	JSR     OUTSTRG         Send it out
	LDAA    #STPASS         CP290 Pass thru mode
	JSR     SETMODE         Send it out
	JSR     CPTMPC          Begin Transparent mode
	LDX     #DSPMSG5        Display Function complete.
	JSR     OUTSTRG         Send it out
	JSR     GETSTR          Wait for CR before we continue
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* DODSPMM - Display Max/Min values to the remote system
******************************************************************************
*
* Routine: This routine is called from the remote/modem command menu to
*       display Max/Min history values to the PeeCee system
*
******************************************************************************
*
DODSPMM EQU     *
	JSR     HOMECLR         Home and Clear the screen
	LDX     #DSPMSG7        Display Max/Min History Data message
	JSR     OUTSTRG         Send it out
*        
	CLR     TFLAG           This will be our counter
DODSPM1 EQU     *               Top of the loop
	LDX     #TMPCTAB        CR/TAB for format purposes
	JSR     OUTSTRN         Send it out
*
* Now we print the location of the sensor
*
	LDX     #STATBLE        Address of the location text
	LDAB    TFLAG           Get the counter
	LSLB                    *2 our offset
	ABX                     Add in the offset
	LDX     0,X             Get the next location printout
	JSR     OUTSTRN         Send it out
	JSR     JUSTAB          Send it out just a tab
*
* Now we reference the HIGHVAL and LOWSVAL array for the history data
*
	LDAB    TFLAG           Get the counter
	LSLB                    *2 our offset
	LSLB                    *4 our offset
	LDX     #LOWSVAL        Address of the low values
	ABX                     Add in the offset
	LDAA    0,X             Get the sensor low value
	PSHX                    Save our index value
*
* Here we check for non negative display for rel light/wind speed/etc
*
	CMPB    #$20            Is this a pressure value
	BLT     DODSPM2         No...jump and continue
	INC     UNSIGN          No negative numbers please
*        
* We check here to see if this is a pressure, which we do special printout
*
	CMPB    #$20            Is this a pressure
	BNE     DODSPM2         No...jump and print as usual
	STAA    CURBP           Save the BP in the printout place
	JSR     BPRINT          Format the BP
	LDX     #BPRESSC        This is the place to print from
	JSR     OUTSTRN         Send it out
	BRA     DODSPM3         Jump over and continue
*
DODSPM2 JSR     PRINTA          Convert it to ASCII and print it out
	CLR     UNSIGN          Normal +/- display
DODSPM3 JSR     JUSTAB          Send it out just a tab
	PULX                    Restore the index value
	JSR     HIS2TIM         Move and print the correct time        
	JSR     HISTIM          Print out the time
	JSR     JUSTAB          Send it out just a tab
*        
	LDAB    TFLAG           Get the counter
	LSLB                    *2 our offset
	LSLB                    *4 our offset
	LDX     #HIGHVAL        Address of the high values
	ABX                     Add in the offset
	LDAA    0,X             Get the sensor high value
	PSHX                    Save our index value
*
* Here we check for non negative display for rel light/wind speed/etc
*
	CMPB    #$20            Is this a pressure value
	BLT     DODSPM4         No...jump and continue
	INC     UNSIGN          No negative numbers please
*        
* We again check here to see if this is a pressure...special printout
*
	CMPB    #$20            Is this a pressure
	BNE     DODSPM4         No...jump and print as usual
	STAA    CURBP           Save the BP in the printout place
	JSR     BPRINT          Format the BP
	LDX     #BPRESSC        This is the place to print from
	JSR     OUTSTRN         Send it out
	BRA     DODSPM5         Jump over and continue
	
DODSPM4 JSR     PRINTA          Convert it to ASCII and print it out
	CLR     UNSIGN          Normal +/- display
DODSPM5 JSR     JUSTAB          Send it out just a tab
	PULX                    Restore the index value
	JSR     HIS2TIM         Move and print the correct time        
	JSR     HISTIM          Print out the time
*                
* Do the housekeeping and printout all values
*
	INC     TFLAG           Increment our counter
	LDAB    TFLAG           Get the value
	CMPB    #HLBYTES        See if we are done (Windir is not used)
	BEQ     DODSPM9         We are done...exit
	JMP     DODSPM1         Continue to loop
*
DODSPM9 EQU     *        
	LDX     #DSPMSG5        Display Function complete.
	JSR     OUTSTRG         Send it out
	JSR     GETSTR          Wait for CR before we continue
	RTS                     Return to the main loop
*
*
******************************************************************************
* HIS2TIM - Helper routine for moving the history time  
******************************************************************************
*
* Routine: This routine is called from above to move the correct history time
*
HIS2TIM EQU     *               Move history time        
	LDAA    1,X             Get the DSPMON
	STAA    DSPMON          Save it
	LDAA    2,X             Get the DSPDAY
	STAA    DSPDAY          Save it
	LDAA    3,X             Get the DSPHR
	STAA    DSPHR           Save it
	RTS                     Return to the upper loop
*
*
*
******************************************************************************
* SHODOOR - Show the door status  
******************************************************************************
*
* Routine: This routine is called from the main loop to update the
*       display the current door status: open/close/count/time 
*
******************************************************************************
*
SHODOOR EQU     *
	JSR     HOMECLR         Home and Clear the screen
	LDX     #DSPMSGI        Display door header message
	JSR     OUTSTRG         Send it out
*        
* Now we begin a loop of 4 cycles to display the door conditions
*
	CLRB                    B is our index value
SHODOO2 EQU     *               Top of the loop        
	PSHB                    Save it on the Stack
	LSLB                    *2 for the double index value
	LDX     #DOORTBL        Get the index printout pointers
	ABX                     Add in the current day pointer
	LDX     0,X             Get this new index value
	JSR     OUTSTRG         Send it out - Name of the door
*
* Now we want to printout if it is currently open or closed
*
	PULA                    Get our index Back
	PSHA                    Save it on the Stack
	CLRB                    B will be our mask for port E
	INCB                    Make it a one
SHODOO3 LSLB                    Shift it up one
	DECA                    Minus one
	BPL     SHODOO3         Continue to loop till we have correct mask
	ANDB    PORTE           AND PORT E which has the door status
	BEQ     SHODOO4         Zero means door is open
	LDX     #DCLOSED        Door is closed
	BRA     SHODOO5         Print it out
SHODOO4 LDX     #DOPENED        Door is open
SHODOO5 JSR     OUTSTRN         Print it out
*
* Now we printout the cycle count value
*
	LDX     #DCYCLED        Display door cycled message
	JSR     OUTSTRG         Send it out
	PULB                    Get our index Back
	PSHB                    Save it on the Stack
	LSLB                    *2 for the double index value
	LDY     #DOORATE        Get the index history pointers
	ABY                     Add in the current day pointer
	LDX     0,Y             Get the value at the pointer
	LDAA    DCOUNT,X        Get this new index value
	INC     UNSIGN          No negative numbers
	JSR     PRINTA          Convert it to ASCII and print it out
	CLR     UNSIGN          Back to normal
*
* Now we printout the Last open/closed times
*
	LDX     #DLOPEND        Display door last opened message
	JSR     OUTSTRG         Send it out
	LDX     0,Y             Get this new index value Date OPEN
	JSR     SHOWTIM         Give the value
	LDX     #DLCLOSE        Display door last closed message
	JSR     OUTSTRG         Send it out
	LDX     0,Y             Get this new index value Date OPEN
	LDAB    #6              Offset into the Date CLOSED
	ABX                     Add it into the X reg
	JSR     SHOWTIM         Give the value
*
* Now go to the next door and loop
*
	PULB                    Get our index Back
	INCB                    Bump to next door
	CMPB    #4              Only 4 doors
	BNE     SHODOO2         We are not done
*
* We are done
*
	LDX     #DSPMSG5        Display Function complete.
	JSR     OUTSTRG         Send it out
	JSR     GETSTR          Wait for CR before we continue
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* UPDOORS - Update door status  
******************************************************************************
*
* Routine: This routine is called from the main loop to update the
*       door status in the event of a change...ie door open/closed
*
* PORTE contains the current door status register
*
*                     PortE
*       DOOR CLOSED = HIGH = SWITCH OPEN
*       DOOR OPEN   = LOW  = SWITCH CLOSED
*
*
*       7 6 5 4 3 2 1 0                   
*       x x x N S B F x         Where NSBF are:
*                               Front Door
*                               Basement Door
*                               South Garage Door
*                               North Garage Door
*
* We enter this routine with A already masked PORTE from the main loop
*
******************************************************************************
*
UPDOORS EQU     *               Update door open/close status
	PSHA                    Save the masked door status
	LDAA    #2              This will be our counter/index
	STAA    TFLAG           We use this general purpose location
UPDOOR2 EQU     *               Loop entry from below        
	LDAA    DSTATUS         Get the old door status
	ANDA    TFLAG           Check just the one door in question
	PULB                    Get the masked E back
	PSHB                    Save it back on the stack
	ANDB    TFLAG           Check just the one door in question
*
* at this point, A=old door status, B=new door status (for just one door)
*
	CBA                     Check to see if they are different
	BEQ     UPDOOR8         They are the same...jump and do the next one
*
* now we update the date/time of the occurance and the cycle count
*
	LDY     #DOORATE        Index into the door table     
	TSTB                    Test the current door condition
	BEQ     UPDOOR3         Jump...the door is OPEN
*        
* Here the door is closed...save the time
*
	JSR     MKINDEX         Make B into an offset
	ABY                     Add B into Y for the correct offset
	LDY     0,Y             Get the proper index into the door status
	INC     DCOUNT,Y        Since door is now closed...but the cycle cnt
	LDAB    #6              Offset into the door closed time area
	ABY                     Adjust the Y index value
	BRA     UPDOOR4         Save the time
*
UPDOOR3 TAB                     Door is OPEN, put A->B so we can index
	JSR     MKINDEX         Make B into an offset
	ABY                     Add B into Y for the correct offset
	LDY     0,Y             Get the proper index into the door status
UPDOOR4 JSR     SAVTIME         Save the time
*        
UPDOOR8 EQU     *               Continue to loop
	LSL     TFLAG           Shift to the next door bit location
	LDAA    TFLAG           Get this value
	CMPA    #$20            See if we are finished with all four doors
	BNE     UPDOOR2         No...jump and continue to loop
*
	PULA                    Clean off the stack...this is our new status
	STAA    DSTATUS         Save it for next time
	RTS                     Return to the main loop
*
******************************************************************************
* MKINDEX - Special purpose routine for UPDOOR
******************************************************************************
*
* This routine take B and makes in into a index 
*
*       input   output
*       2       0
*       4       2
*       8       4
*       16      6
*       
MKINDEX EQU     *               Make an index value from B
	LSRB                    Shift it down
	LSRB                    Shift it down
	CMPB    #4              This is a special case
	BNE     MKINDE9         OK to return
	DECB                    Back it off one
MKINDE9 EQU     *               We are done
	LSLB                    *2
	RTS                     Return to the caller
*
*
*
******************************************************************************
* DODSPCC - Display Current conditions to the remote system
******************************************************************************
*
* Routine: This routine is called from the remote/modem command menu to
*       display the current sensor values to the PeeCee system
*
******************************************************************************
*
DODSPCC EQU     *               Display current conditions
	JSR     HOMECLR         Home and Clear the screen
DODSPC0 LDX     #DSPMSG8        Display Current Sensor conditions message
	JSR     OUTSTRG         Send it out
	JSR     SGATHER         Poll the sensor devices
*
* Now display what we have found as current data
*
	CLR     TFLAG           This will be our counter
*        
* Top of TEMPERATURE display loop
*
DODSPC1 EQU     *
	LDX     #TMPCTAB        CR/TAB for format purposes
	JSR     OUTSTRN         Send it out
*
* Now we print the location of the temp sensor
*
	LDX     #STATBLE        Address of the location text
	LDAB    TFLAG           Get the counter
	LSLB                    *2 our offset
	ABX                     Add in the offset
	LDX     0,X             Get the next location printout
	JSR     OUTSTRN         Send it out
	JSR     JUSTAB          Send it out just a tab
*        
* Here we print the value of the sensor - going thru the table conversion
*
	LDX     #TMPDATA        Address of the DS1820 results save area
	LDAB    TFLAG           Get the counter
	ABX                     Add in the offset
	LDAA    0,X             Get the real temperature value
	JSR     PRINTA          Convert it to ASCII and print it out
*                
* Do the housekeeping and printout all values
*
	INC     TFLAG           Increment our counter
	LDAB    TFLAG           Get the value
	CMPB    #TMPSENS        See if we are done
	BNE     DODSPC1         Continue to loop
*
* Now printout the rest of the information
*                               Pressure
	LDX     #CURDSP1        Load the character address
	JSR     LFCRSAY         Send it out a CR/TAB
	LDAA    BPRESUR         Get the barometric pressure
	STAA    CURBP           Save it away for the printout
	JSR     BPRINT          Print the pressure in standard format
	LDX     #BPRESSC        Load the character address
	JSR     OUTSTRN         Send it out without doing LF/CR first
*                               Rainfall
	LDX     #CURDSP2        Load the character address
	JSR     LFCRSAY         Send it out a CR/TAB
	LDAA    RAINFAL         Get the rainfall count
	INC     UNSIGN          No negative numbers 
	JSR     PRINTA          Convert it to ASCII and print it out
*                               Relative Light
	LDX     #CURDSP3        Load the character address
	JSR     LFCRSAY         Send it out a CR/TAB
	LDAA    RELIGHT         Get the relative light
	JSR     PRINTA          Convert it to ASCII and print it out
*                               Wind speed
	LDX     #CURDSP4        Load the character address
	JSR     LFCRSAY         Send it out a CR/TAB
	LDAA    WINDSPD         Get the wind speed
	JSR     PRINTA          Convert it to ASCII and print it out
	CLR     UNSIGN          Return flag to normal +/- 
*                               Wind direction                
	LDX     #CURDSP5        Load the character address
	JSR     LFCRSAY         Send it out a CR/TAB
	LDX     #WINDIRC        Load the character address
	JSR     OUTSTRN         Send it out without doing LF/CR first
*
* We are done
*
	LDX     #DSPMSG5        Display Function complete.
	JSR     OUTSTRG         Send it out
	JSR     PCIN            Wait for any character before we continue
	BCS     DODSPC9         anything entered...exit back to main loop
	JSR     HOMEIT          Jump back to the top of the screen
	JMP     DODSPC0         Do it again
*
DODSPC9 EQU     *               We are done
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* LFCRSAY - Issue a LF / CR / Say wait is given
******************************************************************************
*
* Routine: This routine used for more screen formatting 
*
*       X is the pointer to what to say
*
LFCRSAY EQU     *
	PSHX                    Save X for the moment
	JSR     LFCRTAB         Send it out a CR/TAB
	PULX                    Load the character address
	JSR     OUTSTRN         Send it out without doing LF/CR first
	JSR     JUSTAB          Send it out just a tab
	RTS                     Return to the caller
*
*
*
******************************************************************************
* LFCRTAB - Issue a LF / CR / TAB to the user
******************************************************************************
*
* Routine: This routine used for screen formatting 
*
LFCRTAB EQU     *
	LDX     #TMPCTAB        CR/TAB for format purposes
	BRA     JUSTAB9         Send it out
*
JUSTAB  EQU     *
	LDX     #TMPHORZ        Just a TAB for format purposes
JUSTAB9 JSR     OUTSTRN         Send it out
	RTS                     Return to the caller
*
*
*
******************************************************************************
* PRINTA - Prints the value of A to the user
******************************************************************************
*
* Routine: This will convert A into ASCII and print it out
*
*
PRINTA  EQU     *               Print the value of A to the user
	JSR     ITOA            Convert it to ASCII
	LDX     #ITOAC          Load the character address
	JSR     OUTSTRN         Send it out without doing LF/CR first
	RTS                     Return to the caller
*
*
*
******************************************************************************
* SGATHER - Scan the sensor devices
******************************************************************************
*
* Routine: This routine used to gather the current conditions and place
*       them in the CUR locations for each value
*
******************************************************************************
*
SGATHER EQU     *
	LDAA    #STSCAN         We are entering scan state
	JSR     SETMODE         Set the LCD state
*
* While we gather the other sensors, we can begin to count pulses from
* the wind boom, so that when we are done, we can get a relative value
*
	JSR     WSETUP          Setup to begin counting wind pulses
*
* Now gather all of the DS1820 values for temperature
*
	JSR     SCANTP          Get the temperature sensors
*
* Now get the A/D registers for Light/Barometric pressure      
*
	LDX     #ADCTL          Address the A/D control register
	LDAA    #$14            MULT + CC to get the second 4 values
	STAA    0,X             Do it, begin the conversion
*
SGATHE2 EQU     *               Wait for the A/D to complete
	LDAA    0,X             Get the status register back
	LSLA                    Check if conversion is complete
	BCC     SGATHE2         Continue to wait
*
*  E5 - The relative light sensor
*  E7 - The barometric pressure sensor
*
	LDAA    2,X             Get the E5 value for Light
	STAA    RELIGHT         Save it away
	LDAA    4,X             Get the E7 value for BP
	STAA    BPRESUR         Save it away
*
	JSR     GOWIND          Get the wind direction
	JSR     WSPEED          Get the wind speed
*
	RTS                     Return to the caller
*
*
*
******************************************************************************
* DODSPBY - Hangup the phone the use is leaving
******************************************************************************
*
* Routine: This routine is called from the remote/modem command menu to
*       get off the system
*
******************************************************************************
*
DODSPBY EQU     *
	LDX     #DSPMSG9        Display Good Bye message
	JSR     OUTSTRG         Send it out
	JSR     WAITONE         Wait two seconds
	JSR     WAITONE         Till the modem goes to command mode
*        
* We have waited the guard time from the work sending to the CP290
* Now we can send the attention +++
*
	LDAA    #APLUS          Set the attention character
	JSR     OUTPUT          Send it out
	LDAA    #APLUS          Set the attention character
	JSR     OUTPUT          Send it out
	LDAA    #APLUS          Set the attention character
	JSR     OUTPUT          Send it out
	JSR     WAITONE         Wait two seconds
	JSR     WAITONE         Till the modem goes to command mode
	LDX     #DSPMSGB        Tell the modem to hang up with ATH0
	JSR     OUTSTRN         Send it out...DCD should drop
*
* Now we save the current date and time as our last valid user signon
*
	LDY     #USRDATE        Location to save into
	JSR     SAVTIME         Copy the time the last user was here
	JSR     DNSAVE          Save the vital data back to the CP290
*        
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* DOCP290 - Handles CP290 activity
******************************************************************************
*
* Routine: This routine is called from the major loop to execute commands
*       for scan from the CP290.   If there is any CP290 activity, then
*       this routine gets it, however it must check to see if the command
*       is for us, meaning it is one of the special hourly events.
*
******************************************************************************
*
DOCP290 EQU     *               Handle CP290 activity
	LDAA    #12             We expect to get these bytes back
	JSR     GETCPD          Get any data from the CP290 in PCFIFO
	LDX     #PCFIFO         Address the data
	LDAA    7,X             Get the Housecode value and function
	CMPA    #$F3            We check this value 'J' and 'OFF'
	BNE     DOCP299         No...this is not us...exit
	LDAA    6,X             Get the current status
	DECA                    Back it off one
	BNE     DOCP299         No...this is not us...exit
	JSR     SCANTIM         This is for us...do a sensor scan
*
DOCP299 EQU     *                
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* SCANTIM - Handles the housekeeping related to a hourly scan
******************************************************************************
*
* Routine: This routine is called from the DOCP290 to execute 
*       the sensor scan and do the related housekeeping
*       This is our event...Now gather the hourly observations
*
SCANTIM EQU     *               Do the sensor data scan
	JSR     SGATHER         Get the conditions
	JSR     HIGLOWS         Find the high/low values
*
* We resync our time with the CP290 
* We clear the minutes, and then get the hour and set it 
*
	CLR     CURMIN          The clock has chimed.
	LDAA    #59             Sixty seconds we count down
	STAA    CURSEC          Save it away
	LDX     #PCFIFO         Address the data from the CP290
	LDAA    8,X             It is coded in the unit codes.
	DECA                    Back it off by one
	STAA    CURHR           Save the hour
	BEQ     SCANTI1         Jump if midnight...0 indicates a new day
*
* In the beginning, BHISTHR is set to -1, so we begin by saving the 
* CHRHR in BHISTHR and start saving scans in the first (0) CURDPTR
* location.   When the first midnight rolls around, then we bump to
* the next day.  NOTE: CURDPTR is cleared on startup.
*
	LDAA    BHISTHR         Get the special first hour flag
	BGE     SCANTI5         We have been here before..jump and continue
	BRA     SCANTI2         Jump, initial startup, start as if new day
*
* It must be the start of a new day...so do the calender housekeeping
*
SCANTI1 JSR     BUMPDAY         Go to the next working day
	LDAA    WKDAY           Load the working day
	STAA    CURDAY          Save it here
	LDAA    WKMON           Load the working month
	STAA    CURMON          Save it here
	LDAA    WKYR            Load the working year
	STAA    CURYR           Save it here
	CLR     RAINFAL         Restart our rain guage counter
	INC     CURDPTR         Bump our history index pointer
*
* Now bump the history number of days...only to a max of MAXDPTR
*
	LDAA    #MAXDPTR        This is our maximum value
	LDAB    NUMDPTR         Get the number of history days already
	INCB                    Bump it up one
	CBA                     See how we're doing
	BGE     SCANTIA         Jump if less or equal        
	TAB                     Move MAXDPTR into B
SCANTIA STAB    NUMDPTR         Save it back
*
* Now bump the history index pointer to the next days of data.
* CURDPTR is cleared on startup, so this is to check for the first
* midnight, or it was a wrap around.
*
SCANTI2 LDAB    CURDPTR         Get the value
	BNE     SCANTI3         This is special...zero = must save the CURHR
	LDAA    CURHR           Get the current hour
	STAA    BHISTHR         Save this indicator when we first start
*
SCANTI3 CMPB    #MAXDPTR        Are we over the limit
	BNE     SCANTI4         We are OK...jump and continue
	CLR     CURDPTR         Max'ed out...we must start over
SCANTI4 LSLB                    *2 for the double index value
	LSLB                    *4 since this is an four byte array
	LDX     #HISIDX         Get the index history pointers
	ABX                     Add in the current day pointer
	LDAA    CURMON          And the current month
	STAA    0,X             Save it
	LDAA    CURDAY          Get the current day
	STAA    1,X             Save it
	LDY     HFLINK          Get the next history pointer to put the data
	STY     2,X             Save it also
*
* Now save the sensor data in HFLINK which is in Y.
*
SCANTI5 EQU     *
	LDAA    #SNBYTES        How many sensor bytes are we saving
	LDY     HFLINK          Get the next history pointer to put the data
	LDX     #ADSCAN         Load the sensor value index to move from
	JSR     MEMCPY          Copy the current into the history area
*
* Now we must adjust the HFLINK for the next scan time, being careful
* not to run off the end of the buffer, but wrap back around to the top
*
	LDX     HFLINK          Get the history forward link back
	LDAB    #SNBYTES        How many sensor bytes are we saving
	ABX                     Add in the sensor count
	PSHX                    Save the intermediate value
	ABX                     Do it again, to see if we run off the end
	CPX     #ENDRAM         Are we over the top of our RAM?
	BCS     SCANTI6         Jump if HISEND is larger...don't wrap yet
	PULX                    Pop the stack of X, but we don't need it
	LDX     #HISTOP         Must reset the value 
	BRA     SCANTI7         Exit and save the value
*
SCANTI6 PULX                    Yank of our new index value
SCANTI7 STX     HFLINK          Save it for the next scan
*
* Now bump the number of scan values till we reach the max
*
	LDX     NUMSCAN         Get the number of scans
	CPX     #MAXSCAN        Are we over?
	BEQ     SCANTI9         We are done...jump and exit
	INX                     We did yet another
	STX     NUMSCAN         Save the current scan counter
*
SCANTI9 EQU     *        
	JSR     DNSAVE          Save the vital data back to the CP290
	JSR     NORMODE         Return LCD state to normal
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* DOLOCAL - Handles Local switch activity
******************************************************************************
*
* Routine: This routine is called from the major loop to execute commands
*       from the local switches
*
* Switch Panel is connected as follows:
* 
*       PC0 - Load/Rew 
*       PC1 - Online
*       PC2 - Unload
*       PC3 - Reset
*       PC4 - Test
*       PC5 - Step
*       PC6 - Execute
*       PC7 - CE
*       PA0 - On 
*       PA1 - Off
*
******************************************************************************
*
DOLOCAL EQU     *
	BCC     DOLOCA9         Nothing to do...jump
*
	JSR     SGATHER         Fetch the current conditions
	LDAA    DSPOINT         Get switch to display
	JSR     SETMODE         Show what is requested by the user
DOLOCA9 CLC                     Clear the carry flag for the main loop
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* ITOA - Converts a byte a ASCII string
******************************************************************************
*
* Routine: This routine takes a byte given in A and converts it to its 
*       ASCII representation.     $80 (-128) -> $7F (127)
*
* Inputs:       A       - is the byte to convert
*               UNSIGN  - is a flag value to indicate we want an unsigned
*                       conversion i.e. 0 -> $FF = 255
*               UNPAD   - is a flag value to indicate we do NOT want to 
*                       pad the end of the number with spaces
*
* Outputs:      ITOAC   - is a 5 byte character string.   The last char 
*                       will contain a 04 to terminate the string.  The
*                       string will be padded with spaces at the end.
*
* All registers are saved
*
******************************************************************************
*
ITOA    EQU     *               byte -> ASCII
	PSHX                    Save the registers
	PSHY
	PSHB
	PSHA                    Save A last because we use it again
	TAB                     Put A in the B reg
*
	LDY     #ITOAC          Get the address of the character buffer
	LDAA    #ASPACE         This is an ASCII space
	STAA    1,Y             Save it
	STAA    2,Y             Save it
	STAA    3,Y             Save it
	LDAA    #EOTEXT         EOT value for the end of the string
	STAA    4,Y             Save it
	TST     UNSIGN          See if we are doing an unsigned convert
	BNE     ITOA1           Jump and do a unsigned conversion
*
	TSTB                    See if the given value is negative
	BPL     ITOA1           If it is positive...then don't worry with sign
	LDAA    #45             The number is negative so store a "-"
	STAA    0,Y             Store the negative
	INY                     Point to the next value
	COMB                    Complement B
	INCB                    One's complement so add 1
*
ITOA1   EQU     *               Here B has the value we want to convert
	CLRA                    Clear the upper bits for the D register
	LDX     #10             This is our divisor
	IDIV                    make the first conversion
	PSHB                    Save the 'ones' value on the stack
	XGDX                    Put the whole number back in the D register
	LDX     #10             This  is our divisor again
	IDIV                    make the second conversion
	PSHB                    Save the 'tens' value on the stack
	XGDX                    Get the 'hundreds' back into the D register
	TSTB                    See if there are any 'hundreds' (1xx or 2xx)
	BEQ     ITOA2           No...it is zero, go on to the tens
	ORAB    #$30            Make it a ASCII number
	STAB    0,Y             Save the value
	INY                     Point to the next value
ITOA2   PULB                    Get the 'tens' value
	TSTB                    See if there are any 'tens' (xNx)
	BEQ     ITOA3           No...it is zero, go on to the ones
	ORAB    #$30            Make it a ASCII number
	STAB    0,Y             Save the value
	INY                     Point to the next value
ITOA3   PULB                    Get the 'ones' value
	ORAB    #$30            Make it a ASCII number...it will be at least 0
	STAB    0,Y             Save the value
	TST     UNPAD           See if we are not to pad the number 
	BEQ     ITOA4           Jump, already paded, and exit
	LDAA    #EOTEXT         End of Text marker
	STAA    1,Y             End the string without space padding
*
ITOA4   PULA                    Restore the registers
	PULB
	PULY
	PULX
	RTS                     Return to the caller
*
*
*
******************************************************************************
* ITWOA - Converts a value in A to 2 ASCII chars returned in D
******************************************************************************
*
* Routine: This routine takes a byte given in A and converts it into
*       two ASCII characters.   This is used for date and time display.
*
* Inputs:       A       - is the byte to convert
*
* Outputs:      D       - is two bytes of ASCII between 00 and 99 
*
* NOTE:         X is saved
*
******************************************************************************
*
ITWOA   EQU     *               byte -> ASCII  00-99
	PSHX                    Save the X register
	TAB                     Put A in the B reg
	CLRA                    Clear the upper bits for the D register
	LDX     #10             This is our divisor
	IDIV                    make the first conversion
	PSHB                    Save the 'ones' value on the stack
	XGDX                    Put the whole number back in the D register
	LDX     #10             This  is our divisor again
	IDIV                    make the second conversion
	TBA                     Save the 'tens' value in A
	ORAA    #$30            Make it a ASCII number
	PULB                    Restore B as our 'ones' value
	ORAB    #$30            Make it a ASCII number
	PULX                    Restore the X register
	RTS                     Return to the caller
*
*
*
******************************************************************************
* HOMECLR - Sends the home & clear screen commands to the PeeCee
******************************************************************************
*
* Function: This routine sends the VT100 escape sequence to home and then
*       clear the screen.
*
HOMECLR EQU     *               Home and Clear the screen
	LDX     #HACMSG1        This is the escape sequence
	JSR     OUTSTRN         Send it out.
	JSR     HOMEIT          Send it out.
	JSR     WAIT500         Delay one half second
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* HOMEIT  - Sends the home the cursor screen commands to the PeeCee
******************************************************************************
*
* Function: This routine sends the VT100 escape sequence to home the 
*       cursor
*
HOMEIT  EQU     *               Home the curson
	LDX     #HACMSG2        This is the escape sequence
	JSR     OUTSTRN         Send it out.
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* OUTSTRG - Sends a string to the PeeCee
******************************************************************************
*
* Function: This function will send a character string to the PeeCee.
*       The string is terminated by an EOT (End of Text) character.
*       This routine is the same as BUFFALO except this one does not
*       pause for ^W
*
* Note: There are two entry points for this routine, the first OUTSTRG
*       does a LF/CR sequence before the string is output and  OUTSTRN
*       just sends the text without the carriage control
*
OUTSTRG EQU     *               Sends a character string to the PeeCee
	JSR     OUTCRLF         Send a carriage return
OUTSTRN EQU     *               Just send the string
	LDAA    0,X             Get the next character in the string
	CMPA    #EOTEXT         See if we are at the end
	BEQ     OUTSTR1         Yes...jump and exit
	JSR     OUTPUT          Send it out
	INX                     Bump the index to the next char
	BRA     OUTSTRN         Continue to loop
OUTSTR1 RTS                     Return to the caller
*
*
*
******************************************************************************
* LCDINIT - Sends a setup string to the LCD 
******************************************************************************
*
* Function: This function will send the init sequence to the LCD and 
*       then display the Welcome message.
*
LCDINIT JSR     LCDRSEL         Select for register output
	LDX     #LCDSIP         This is the init string
	JSR     LCDLOOP         Send it out
	LDAA    #2              This is a 2*25msec delay 
	JSR     DELAYIT         Initialize the wait loop
LCDINI1 JSR     DELAY           Wait here
	BCC     LCDINI1         Until it is over
	LDX     #LCDWEL         Welcome message
	JSR     LCDTOP          Send it out
	RTS
*
*
*
******************************************************************************
* LCDTOP - Sends a string to the LCD top line
******************************************************************************
*
* Function: This function will send a character string to the LCD
*       The string is terminated by an EOT (End of Text) character.
*
*
LCDTOP  EQU     *               Sends a character string to the top LCD line
	PSHX                    Save the index of the string
	JSR     LCDRSEL         Register select
	LDAA    #$80            Top line of the LCD
	BRA     LCDDOIT         Send it out
*
******************************************************************************
* LCDBOT - Sends a string to the LCD bottom line
******************************************************************************
*
LCDBOT  EQU     *               Sends a character string to the bottom line
	PSHX                    Save the index of the string
	JSR     LCDRSEL         Register select
	LDAA    #$C0            Bottom line of the LCD
LCDDOIT EQU     *               Send it out
	STAA    PORTB           Set the correct address
	FDIV                    Wait for the LCD
	FDIV                    Wait for the LCD
	JSR     LCDDSEL         Put is back in data mode
	PULX                    Get the data address back
LCDLOOP LDAA    0,X             Get the next character in the string
	CMPA    #EOTEXT         See if we are at the end
	BEQ     LCDONE          Yes...jump and exit
	STAA    PORTB           Send it out
	INX                     Bump the index to the next char
	PSHX                    Save the register
	FDIV                    Wait for the LCD
	FDIV                    Wait for the LCD
	PULX                    Restore the register
	BRA     LCDLOOP         Continue to loop
*
LCDONE  EQU     *
	CLRA                    This last command just clears the HEX display
	COMA                    On the front of the cabin monitor
	STAA    PORTB           Send it out
	RTS                     Return to the caller
*
*
*
******************************************************************************
* LCDDSEL - Selects LCD data input
******************************************************************************
*
LCDDSEL EQU     *               Setup the LCD for data output
	LDX     #PORTA          Get the A port register
	BSET    0,X LCDRSD      Set the RS flag for data
	RTS                     Return to caller
*
*
*
******************************************************************************
* LCDRSEL - Selects LCD register input
******************************************************************************
*
LCDRSEL EQU     *               Setup the LCD for register input
	LDX     #PORTA          Get the A port register
	BCLR    0,X LCDRSD      Clear the RS flag for register input
	RTS                     Return to caller
*
*
*
******************************************************************************
* WAITONE - Delays one second
******************************************************************************
*
* Function: This routine simply returns to the user after one second
*
WAITONE EQU     *               Waits one second
	PSHA                    Save this register
	LDAA    #40             This will be a one second delay
	JSR     DELAYIT         Setup the delay timer
WAITON1 JSR     DELAY           This is our loop        
	BCC     WAITON1         Continue to wait
	PULA                    Restore this register
	RTS                     Return to the main loop
*
*
*
******************************************************************************
* WAIT500 - Delays 500 msec
******************************************************************************
*
* Function: This routine simply returns to the user after a half second
*
WAIT500 EQU     *               Waits one half second
	PSHA                    Save this register
	LDAA    #20             This will be a 500 msec delay
	JSR     DELAYIT         Setup the delay timer
WAIT501 JSR     DELAY           This is our loop        
	BCC     WAIT501         Continue to wait
	PULA                    Restore this register
	RTS                     Return to the main loop
*
*
*
**************************************************************************
* DELAY - Wait/delay loop
**************************************************************************
*
* Routine:  This routine will provide a variable delay.   It will use
*       the DELAYIT to set the value to determine how much delay 
*       should be provided.    This routine is intended to be called 
*       in conjunction with the routine that is being timed.   
*
*       DELAYIT - This is the initialization/setup routine which must
*       be called to ready the DELAY routine for operation
*
* Inputs: DELAYWS is a byte value of the number of milliseconds to 
*       delay.
*
* Outputs: The carry flag is set when the delay is completed, otherwise
*       the carry is cleared.
*
* All registers are saved
*
DELAY   EQU     *               Delay the given number of MS
	PSHA                    Save the register
	CLC                     Assume we have not exausted the timer
	LDAA    TFLG1           Get the main timer interrupt flag register
	ANDA    #TOC5F          Looking for output compare on timer 5 flag
	BEQ     DELAY1          It is not time yet...jump
*
* Here the timer has gone off so we have waited 25 msec.
* Now check the working register to see if there is more to do.
*
	TST     DELAYWK         See if there is more time to wait
	BEQ     DELAY2          No...we are timed out...jump
	DEC     DELAYWK         Count it down
	JSR     DELAYUP         Reset the timer compare register
	CLC                     Clear the carry in case it was set by the ADDD
	BRA     DELAY1          Continue to wait
*
DELAY2  SEC                     Yes...we have a timeout
DELAY1  PULA                    Restore the register
	RTS                     Return to the caller
*
*
*
**************************************************************************
* DELAYIT - Setup Routine for DELAY
**************************************************************************
*
DELAYIT EQU     *               Setup routine for the DELAY function
	PSHA                    Save the registers
	PSHB
	STAA    DELAYWK         Put it in our working area
	JSR     DELAYUP         Setup the timer for the compare
	PULB                    Restore the registers
	PULA
	RTS                     Return to the caller
*
*
*
**************************************************************************
* DELAYUP - Setup the timer compare for DELAY
**************************************************************************
*
DELAYUP EQU     *               Reset the timer for action
	LDD     TCNT            Get the timer counter
	ADDD    #$C350          This is 25 ms (2Mh/1) 0.5 usec ticks
	STD     TOC5            Put it in the output compare
	LDAA    #TOC5F          Reset the TOC5 compare
	STAA    TFLG1           By writing it back with a 1
	RTS                     Return to the caller
*
*
*
**************************************************************************
* SETUPCP - Setup Routine for the CP290
**************************************************************************
*
* Routine: This module is used when the CP290 has been powered down
*       and needs to be reloaded with the time, date, housecode and
*       timer event information.
*
SETUPCP EQU     *               Setup routine for the CP290
	JSR     WHATIME         Get the date and time from the user
	BCC     SETUPC9         The user is gone...exit
	LDX     #DNWAIT         Load the information message to wait
	JSR     OUTSTRG         Send it out
*        
* This entry point is from the CSSINIT routine which will load the CP290
* from the preset values...the battery backup has failed in the CP290
*
SETUPC4 EQU     *
	JSR     SETIME          Set the housecode and time into the CP290
*
* Now we save the date and time as our cold start value
*
	LDY     #COLDATE        Location to save into
	JSR     SAVTIME         Copy the time we began from scratch
*
* Here we clear out some of the data structures to act as a soft reset
*        
	CLR     SMDOOR+DCOUNT   Clear the open/closed counts
	CLR     SBDOOR+DCOUNT   Ditto
	CLR     SNDOOR+DCOUNT   Ditto
	CLR     SSDOOR+DCOUNT   Ditto
*        
	JSR     DNSCAN          Download the scan events
	JSR     DNSAVE          Save the necessary data
	JSR     SGATHER         Gather the inital scan data
	JSR     HISETUP         Restart our history data
SETUPC9 RTS                     Return to the caller
*
*
*
**************************************************************************
* WHATIME - Get the date and time from the user
**************************************************************************
*
* Routine: 
*
WHATIME EQU     *        
	CLR     TFLAG           This is the counter for two defaults
WHATIM2 LDX     #ASKTDAY        Load up the time request message
	JSR     OUTSTRG         Send it out
	INC     ECHOIT          Make sure the user sees this
	JSR     GETSTR          See what we get back
	BCC     WHATIM9         The user is gone...exit        
*
* Now we parse out the time and date as given by the user
* In the input buffer we should have DD-MM-YY:HH:MM
*
	LDX     #CBUFF          Address the input buffer
	TST     CBUFFPT         See if this is zero indicating just a CR
	BNE     WHATIM4         We have something...go see what it is
	INC     TFLAG           Ask again the same question...twice
	LDAA    TFLAG           Load the counter  
	CMPA    #2              Are we done?
	BNE     WHATIM2         NO...jump and ask again
	CLC                     We have had enough
	BRA     WHATIM9         Get out
*
WHATIM4 LDY     #CURTIM         This is where we store the information
	CLR     TFLAG           This is the counter of for char parsed
WHATIM5 EQU     *               Main loop to convert the data
	LDD     0,X             Get the two ASCII characters
	JSR     ATOI            Convert it to a number
	BVS     WHATIME         Conversion error...ask date again
	STAA    0,Y             Save the value
	INX                     Bump the 
	INX                     Bump the index 
	INX                     Bump the index value
	INY                     Step to the next save value
	INY                     YR (HR) MON (MIN) DAY
	INC     TFLAG           Increment the loop counter
	LDAA    TFLAG           Load the counter  
	CMPA    #3              Are we done with YR MON DAY ?
	BNE     WHATIM7         No...jump and continue
	LDY     #CURHR          Reset the index value
WHATIM7 CMPA    #5              Are we done?
	BNE     WHATIM5         Continue to process the data
*
* Now we have converted all the data.
* Give the user the chance to change it if we did not get it right
*
	LDX     #DSPMSGE        The 'the current time' header message
	JSR     OUTSTRG         Send it out
	LDX     #CURTIM         Current time location
	JSR     SHOWTIM         Display the time
	JSR     GETYSNO         Ask if this is correct
	BCC     WHATIM9         User is gone...return to the main
	BVC     WHATIME         Jump and ask the user the time again
*
WHATIM9 EQU     *        
	RTS                     Return to the caller
*
*
*
**************************************************************************
* SETIME - Set the housecode and time into the CP290
**************************************************************************
*
* Routine: This routine takes the time values in the CURxx and loads 
*       them to the CP290.   This routine is called from the DOMODEM
*       loop when we notice that the CP290 has been powered down.
*
*       NOTE: Before we set the time we load down the housecode
*
SETIME  EQU     *               Set the housecode and time into the CP290
	LDX     #CPFIFO         This is where we will place the commands
	CLRA                    Command is download base housecode
	STAA    0,X             Save it
	LDAA    #$10            Housecode E
	STAA    1,X             Save it
	LDAA    #2              Just two bytes...nochecksum
	JSR     SENDCP          Send it out
*
* Now make the time command and send it down
*
	LDX     #CPFIFO         This is where we will place the commands
	LDAA    #DNTIME         Command the CP290 to download the time
	STAA    0,X             Save it
	CLRA                    This will be our checksum
	LDAB    CURMIN          Get the current minutes
	ABA                     Add in the checksum
	STAB    1,X             Save it
	LDAB    CURHR           Get the current hour
	ABA                     Add in the checksum
	STAB    2,X             Save it
	LDY     #DAYMAP         Address the map between CP290 days
	LDAB    WKWDAY          Get the weekday value
	ABY                     Bump the index
	LDAB    0,Y             Fetch the day in CP290 bitmap format
	ABA                     Add in the checksum
	STAB    3,X             Save it
	STAA    4,X             Save it...last is the checksum
*
* Now we have built the command...send it to the CP290
*
	LDAA    #5              Bytes to send
	JSR     SENDCP          Send it to the device
	RTS                     Return to the caller
*
*
*
**************************************************************************
* DNSCAN - Download the scan events
**************************************************************************
*
* Routine: This routine is used to download the events into the CP290
*       which are used to signal the CSS that a SCAN event is to occur.
*       There are 24 scan events, one per hour.   Each event is coded
*       using the upper bits of the unit code (units 12-16) as the 
*       indicator for which event.   The events are stored in the CP290
*       at locations starting with 101 - 124.   The lower order events
*       can still be used by the CP290 for actual timer events.
*      
*
DNSCAN  EQU     *               Download the scan events        
	CLR     TFLAG           This will be our event counter
*
* Here we begin our main loop to load down the timer events
*
DNSCAN1 EQU     *               Top of the main loop
	LDX     #CPFIFO         This will be our send buffer 
	LDAA    #DNLOAD         CP290 command to download events
	STAA    0,X             17 - Save the command
	LDAA    TFLAG           Load the loop counter
	CMPA    #24             If we have done a days worth then
	BEQ     DNSCAN9         Jump and we are done
*
	CLRA                    Clear the top of the D register
	LDAB    TFLAG           Load the loop counter
	LSLD                    Shift it up
	LSLD                    Shift it up
	LSLD                    Shift it up
	STAB    1,X             18, Low order first
	STAA    2,X             19 - Save it away
*
* Now we have to keep a checksum, which will be in the A register
*
	CLRA                    Clear the checksum
	LDAB    #$08            Mode is NORMAL, everyday
	STAB    3,X             20 - Store the MODE
	ABA                     Add the checksum
	LDAB    #$7F            Bit map of days...all days
	STAB    4,X             21 - Store the DAYS
	ABA                     Add the checksum
	LDAB    TFLAG           Get the event counter
	STAB    5,X             22 - Save the HOUR
	ABA                     Add the checksum
	CLRB                    The minutes will always be zero
	STAB    6,X             23 - Save the MINUTE
	STAB    7,X             24 - Bit map of units is also zero
	LDAB    TFLAG           Get event number, this will be saved here
	INCB                    This will be indexed from 1 not 0
	STAB    8,X             25 - Unit codes 9-16
	ABA                     Add the checksum
	LDAB    #$F0            House code 'J'
	STAB    9,X             26 - Load dummy housecode
	ABA                     Add the checksum
	LDAB    #$03            This function is OFF
	STAB    10,X            27 - Load the level/function
	ABA                     Add the checksum
	STAA    11,X            28 - Save the checksum
*
* The message has been created, now send it off to the CP290
*
	LDAA    #12             Twelve bytes to send
	JSR     SENDCP          Send the command
	INC     TFLAG           Increment the loop counter
	BRA     DNSCAN1         Continue to loop  
DNSCAN9 EQU     *
	RTS                     Return to the caller
*
*
*
**************************************************************************
* DNSAVE - Download the save area 
**************************************************************************
*
* Routine: This routine is used to download the save area to the CP290
*       We use this as a way to save our volitle memory into the CP290
*       so if we loose power, we can come back up, reload an be ready.
*       Location CP2SAVE is where we begin to save data till we are done.
*       Location CP2QUIT is where we end the transfer
*
*       The CP290 command saves two bytes, so we loop through here enough 
*       times to transfer the data < 512 bytes
*
DNSAVE  EQU     *               Download the save area        
	JSR     CPINIT          Setup the host port for the CP290
	LDAA    #STSAVE         New state
	JSR     SETMODE         Change it
	LDY     #CP2SAVE        Address to start saving data
	CLR     TFLAG           This will be used in our CP290 address 
*
* Here we begin our main loop to load down the 'graphics' events
*
DNSAVE1 EQU     *               Top of the main loop
	LDX     #CPFIFO         This will be our send buffer 
	LDAA    #DNLOAD         CP290 command to download events
	STAA    0,X             17 - Save the command
	LDAB    TFLAG           Load the loop counter
	CLRA                    We will use a double register
	LSLD                    Shift it up one
	STAB    1,X             18 - lower address
	ORAA    #$04            Turn on D2
	STAA    2,X             19 - Save the upper address byte
	CLRA                    This will be our checksum
	LDAB    0,Y             Get the data byte
	INY                     Bump to the next address
	ABA                     Add in the checksum
	STAB    3,X             20 - Save the data in the command
	LDAB    0,Y             Get the data byte
	INY                     Bump to the next address
	ABA                     Add in the checksum
	STAB    4,X             21 - Save the data in the command
	STAA    5,X             22 - Store the checksum
*
* The message has been created, now send it off to the CP290
*
	LDAA    #6              Half a dozen bytes to send
	JSR     SENDCP          Send the command
	INC     TFLAG           Bump our CP290 address
	CPY     #CP2QUIT        See if we have done enough
	BLS     DNSAVE1         Continue to loop
*        
	JSR     NORMODE         Return LCD state to normal
	RTS                     Return to the caller
*
*
*
**************************************************************************
* UPSAVED - Upload the save area from the CP290
**************************************************************************
*
* Routine: Sends the request graphics command to the CP290 which will 
* start sending our saved data, which we load back into memory.
* We start at CP2SAVE location and end with CP2QUIT.   The rest of the
* data from the CP290 is ignored.
*
* A good upload will set the carry flag.   
* A bad upload then carry is clear.
*
UPSAVED EQU     *               Restore the save area from CP290       
	JSR     CPINIT          Setup the host port for the CP290
	LDAA    #STREST         New state
	JSR     SETMODE         Change it
	JSR     SNDSNC          Send the sync bytes
	LDAA    #REQDATA        Request the data download
	JSR     CPUT290         Send the command to the CP290
*
* Get ready...here comes the data...six bytes of sync, status, then data
*
*
	LDAA    #6              This is number of sync bytes to throw away
UPSAVE0 PSHA                    Save it for our looping
	JSR     UPREST          Reset the watch dog timer
UPSAVE1 JSR     CP290IN         Get any data from the CP290
	BCS     UPSAVE2         We got a character
	JSR     DELAY           See if we should abort this loop
	BCC     UPSAVE1         Continue to loop...
	PULA                    We failed...exit
	BRA     UPSAVE8         Signal failure and return
*
UPSAVE2 PULA                    Get A back
	DECA                    Count it down
	BNE     UPSAVE0         Continue to look for data
*
* The next data word will tell us if the CP290 has valid data
*
	JSR     UPREST          Reset the watch dog timer
UPSAVE3 JSR     CP290IN         Get any data from the CP290
	BCS     UPSAVE4         We got a character
	JSR     DELAY           See if we should abort this loop
	BCC     UPSAVE3         Continue to loop...
	BRA     UPSAVE8         Signal failure and return
*
UPSAVE4 DECA                    A should equal 1 and a decrement be zero
	BNE     UPSAVE8         This is bad...jump and get out
*
* Now we begin our restore loop
*
	LDY     #CP2SAVE        Address to start restoring data
UPSAVE5 JSR     UPREST          Reset the watch dog timer
UPSAVE6 JSR     CP290IN         Get any data from the CP290
	BCS     UPSAVE7         We got a character
	JSR     DELAY           See if we should abort this loop
	BCC     UPSAVE6         Continue to loop...
	BRA     UPSAVE8         Signal failure and return
*        
UPSAVE7 STAA    0,Y             Restore the data
	INY                     Bump the index
	CPY     #CP2QUIT        See if we have done enough
	BLS     UPSAVE5         Continue to loop
	SEC                     We are done...set carry and exit
	BRA     UPSAVE9         Get out
*
UPSAVE8 EQU     *   
	LDAA    #STCPDN         New state
	JSR     SETMODE         Change it
	CLC                     Bad return...clear the carry flag
UPSAVE9 RTS                     Return to the caller
*
*
**************************************************************************
* UPREST - Reset watch dog timer, support routine for UPSAVED
**************************************************************************
*
UPREST  EQU     *               Reset the watch timer        
	PSHA                    Save A
	CLR     PCFPTR          Clear PeeCee FIFO forward pointer
	LDAA    #40             This is 1 second (25msec * 40) 
	JSR     DELAYIT         Initialize the wait loop
	PULA                    Bring A back
	RTS                     Return to the caller
*
*
**************************************************************************
* SENDCP - Send the command to the CP290
**************************************************************************
*
* Routine: Send a data/command to the CP290 from the CPFIFO
*
* The A register contains the number of bytes to send following
*       the 16byte sync.   The data is contained in the CPFIFO.
*
SENDCP  EQU     *        
	STAA    CPFPTR          Save it in the forward pointer
	CLR     CPBPTR          Clear the backward FIFO pointer
	LDAA    SCSR            Read the SCI status register
	LDAA    SCDAT           To clear any left over data in the read reg
	JSR     SNDSNC          Send the sync bytes
*        
* Here we loop until all the data has been sent
*
SENDCP1 JSR     CP290OUT        Do the send
	LDAB    CPFPTR          Get the forward FIFO pointer
	CMPB    CPBPTR          See if there is anything to send
	BNE     SENDCP1         Continue to loop until FIFO is empty
*
* See if we get an ACK back from the CP290
*
	LDAA    #7              We expect to get these bytes back
	JSR     GETCPD          Give the CP290 a chance 
	LDAA    PCFPTR          See if we got anything back
	BEQ     SENDCP2         Send error message
	CMPA    #7              Should be seven bytes
	BEQ     SENDCP9         This is good
*
SENDCP2 EQU     *
	LDX     #CPDOWN         Load the bad news 
	JSR     OUTSTRG         Send it out
	LDAA    #STCPDN         New state
	JSR     SETMODE         Change it
*
SENDCP9 EQU     *               
	RTS                     Return to the caller
*
*
*
**************************************************************************
* GETYSNO - As the user if this is OK
*
* Routine: Get the user to say Yes or No.
*
*       If Carry is Clear, then the user is gone
*       If Overflow is Clear, then the user's answer is NO
*               Overflow set is YES
*
GETYSNO EQU     *        
	LDX     #ASKYSNO        Is this OK message 
	JSR     OUTSTRG         Send it out
	JSR     GETSTR          Get the user pick
	BCC     GETYSN8         User is gone...so are we
	LDAA    CBUFF           Get the first character
	CMPA    #CAPTOLY        It must be a 'Y'
	BNE     GETYSN8         No...jump and get out
	SEV                     Yes...we have an YES
	SEC                     And set the carry flag as well
	BRA     GETYSN9         Jump and exit
*
GETYSN8 EQU     *               User has gone...
	CLV                     Clear the overflow flag
GETYSN9 RTS                     Return to the user
*
*
**************************************************************************
* MEMCPY - Copy a string of bytes
**************************************************************************
* CPYDATE - Copy the X time into location Y
**************************************************************************
* SAVTIME - Copy the current time into location Y
**************************************************************************
*
* This routine copies a string of bytes
* The registers:
*       X - Input string address
*       Y - Output string address
*       A - Count of bytes to copy
*
* A, B and X registers are saved and restored
*
SAVTIME EQU     *               Save the current date/time 6 bytes
	PSHA                    Save A on the stack
	LDAA    #6              Six date bytes
	PSHX                    Save X on the stack
	LDX     #CURTIM         This is the current time location
	BRA     MEMCPY1         Continue with the copy
*
CPYDATE EQU     *               Save the X date in the Y location       
	PSHA                    Save A on the stack
	LDAA    #6              Six date bytes
	PSHX                    Save X on the stack
	BRA     MEMCPY1         Continue with this copy
*                               
* MEMCPY - Copy memory bytes
*
MEMCPY  EQU     *               Copy A bytes from X -> Y
	PSHA                    Save A on the stack
	PSHX                    Save X on the stack
MEMCPY1 PSHB                    Save B on the stack
MEMCPY3 LDAB    0,X             Get the value
	INX                     Bump the input index
	STAB    0,Y             Save the value
	INY                     Bump the output index
	DECA                    Decrement our count
	BNE     MEMCPY3         Continue till count is exausted
	PULB                    Pull them off the stack
	PULX                    In backward order
	PULA                    Restore the registers
	RTS                     Return to the user
*
*
**************************************************************************
* SHOWTIM - Display the time
**************************************************************************
*
* Routine: This routine displays the date/time to the user.
*
* Input:
*       X - Points to the date/time values to print
* 
* All registers are saved
*
SHOWTIM EQU     *               Display the time
	PSHA                    Save A on the stack
	PSHB                    Save B on the stack
	PSHX                    Save X register
	PSHY                    Save Y as well
*
	LDY     #DSPTIM         Display time location
	JSR     CPYDATE         Copy the time
*
* This check was added to see if the date was valid.   We look at the year
*        
	LDAA    DSPYR           Get the display year
	CMPA    #BDYR           See if we are in the correct range
	BGE     SHOWTI2         This is valid...jump and continue
	LDX     #DSPMSGK        Address the string <none> for the date
	JSR     OUTSTRN         Send it out
	JMP     SHOWTI9         Get out
*
SHOWTI2 EQU     *               Printout Sunday, etc.
	JSR     WHATDAY         What is the day of the week
	LDY     #DAYOFWK        Address the day table
	LDAB    WKWDAY          Get the weekday
	LSLB                    Multiply by 2 to get the offset
	ABY                     Offset into the table
	LDX     0,Y             Get the day's address
	JSR     OUTSTRN         Send it out
*        
	LDY     #MTABLE         Address of the month
	LDAB    DSPMON          Get the display month
	LSLB                    Multiply by 2 to get the offset
	ABY                     Offset into the table
	LDX     0,Y             Get the month's address
	JSR     OUTSTRN         Send it out
*        
	INC     UNPAD           No padding on this value
	LDAA    DSPDAY          Get the display day
	JSR     PRINTA          Convert it to ASCII and print it out
	CLR     UNPAD           We can have padding now
*
	LDX     #SHOWT20        Address the string ,20
	JSR     OUTSTRN         Send it out
	LDAA    DSPYR           Get the year again
	JSR     ITWOA           Two char only
	PSHB                    Save the 'ones' number
	JSR     OUTPUT          Send it out the 10s
	PULA                    Get the 'ones' back
	JSR     OUTPUT          Send it out
	LDAA    #ASPACE         Send a space
	JSR     OUTPUT          Send it out
*
* Now we print the hour and minutes
*
SHOWTI7 EQU     *
	LDAA    DSPHR           Hours
	JSR     ITWOA           Two char only
	PSHB                    Save the 'ones' number
	JSR     OUTPUT          Send it out
	PULA                    Get the 'ones' back
	JSR     OUTPUT          Send it out
*
	LDAA    #ACOLON         Send a :
	JSR     OUTPUT          Send it out
*
	LDAA    DSPMIN          Minutes
	JSR     ITWOA           Two char only
	PSHB                    Save the 'ones' number
	JSR     OUTPUT          Send it out
	PULA                    Get the 'ones' back
	JSR     OUTPUT          Send it out
*        
	LDAA    #ACOLON         Send a :
	JSR     OUTPUT          Send it out
*
	LDAA    DSPSEC          Seconds
	STAA    CBUFFOV         Save it here
	LDAA    #59             Sixty seconds
	SUBA    CBUFFOV         We count down from 59 so we must subtract
	JSR     ITWOA           Two char only
	PSHB                    Save the 'ones' number
	JSR     OUTPUT          Send it out
	PULA                    Get the 'ones' back
	JSR     OUTPUT          Send it out
*        
SHOWTI9 PULY                    In
	PULX                    Backward 
	PULB                    Order we
	PULA                    Restore the registers
	RTS                     Return to the caller
*
*
*
**************************************************************************
* ATOI - Converts ASCII to Integer
**************************************************************************
*
* Routine: This routine converts the two character ASCII number
*       that is in the D register to a integer and returns it 
*       in the A register.     The ASCII number should be between
*       30-39 hex.   If it is not then we force the value to zero,
*       and set the OVERFLOW flag
*
ATOI    EQU     *               Converts ASCII to Integer
	ANDB    #$0F            Strip off the upper bits
	CMPB    #09             See if we have a conversion problem
	BGT     ATOI1           Bad...something greater than 9
	ANDA    #$0F            Strip off the upper bits
	CMPA    #09             See if we have a conversion problem
	BGT     ATOI1           Bad...something greater than 9
	PSHB                    Save B ONEs for the moment
	LDAB    #10             This is for the TENs value
	MUL                     Multiply A by 10
	PULA                    Get the ONEs value back
	ABA                     Add them together
	CLV                     Clear the overflow flag...good number
	BRA     ATOI2           Good exit
*
ATOI1   CLRA                    Error...return zero
	SEV                     Set the overflow flag...bad number
ATOI2   RTS                     Return to the caller
*
*
*
**************************************************************************
* BUMPDAY - Count the days go by
**************************************************************************
*
* Routine: This routine simply counts from it's designated birthday
*       Howard B. Stephens, August 25, and uses this as its birthday
*       (the Cabin System) in 1995 which was a Friday.
*       Note: it was also a Friday for 25Aug2000
*
BUMPDAY EQU     *               Go to the next day
	LDX     #DAYMON         Get the days of the month table
	LDAB    WKMON           Get the working month
	ABX                     This is our offset into the table
	LDAA    0,X             Get the number of days this month
*        
* Now we check to see if it is leap year...then if it is February
*
	LDAB    WKLEAP          Get the Leap Year value
	CMPB    #4              Every 4th year is leap year
	BNE     BUMPDA1         No...continue as normal
	LDAB    WKMON           Get the working month
	CMPB    #2              Is it February?
	BNE     BUMPDA1         No...jump and continue
	INCA                    OK, Leap Year! There are 29 days this month.
BUMPDA1 CMPA    WKDAY           Are we at the end of the month?
	BNE     BUMPDA2         No...jump and continue to count
	CLR     WKDAY           We must start over...end of the month
	JSR     NEXTMON         Bump the working month
BUMPDA2 EQU     *
	INC     WKDAY           Go to the next day
	JSR     NEXTDAY         Go to the next weekday
	RTS                     Return to the caller
*
*
*
**************************************************************************
* NEXTDAY - Moves the week day value
**************************************************************************
*
* Routine: This routine simply moves the working weekday counter
*
* NOTE: Counter is indexed from 1
*
NEXTDAY EQU     *               Go to the next weekday        
	INC     WKWDAY          Next day of the week
	LDAA    WKWDAY          Get the value
	CMPA    #8              See if we have turned a new week
	BNE     NEXTDA1         No...jump and return to the caller
	LDAA    #1              Start over
	STAA    WKWDAY          It is a new week...Sunday
NEXTDA1 EQU     *
	RTS                     Return to the caller
*
*
*
**************************************************************************
* NEXTMON - Moves the month value
**************************************************************************
*
* Routine: This routine simply moves the working month counter
*
* NOTE: Counter is indexed from 1
*
NEXTMON EQU     *               Go to the next month        
	INC     WKMON           Next month
	LDAA    WKMON           Get the value
	CMPA    #13             See if we have turned a new year
	BNE     NEXTMO1         No...jump and return to the caller
	LDAA    #1              Start over
	STAA    WKMON           It is a new year...January
	INC     WKYR            Bump year 0,1...2000,2001
	INC     WKLEAP          And leap year counters
	LDAA    WKLEAP          Get the leap year counter
	CMPA    #5              Only every four years
	BNE     NEXTMO1         No...jump and return to caller
	LDAA    #1              Start over
	STAA    WKLEAP          With a new set of four years
NEXTMO1 RTS                     Return to the caller
*
*
*
**************************************************************************
* WHATDAY - Finds Day of the Week
**************************************************************************
*
* Routine: The output of this routine is to determine the day of the 
*       week from the given current date.   The result is the correct
*       day left in the WKWDAY location.
*
WHATDAY EQU     *               Finds the Day of the Week 
	LDAA    #BDYR           Birthday year
	STAA    WKYR            Save it
	LDAA    #BDMON          Birthday month
	STAA    WKMON           Save it
	LDAA    #BDDAY          Birthday day
	STAA    WKDAY           Save it
	LDAA    #BDWDAY         Birthday Weekday
	STAA    WKWDAY          Save it
	LDAA    #BDLEAP         Birthday Leap Year
	STAA    WKLEAP          Save it
*
* Now here is the loop, counting days till we make a match
*
WHATDA1 EQU     *               Top of loop
	JSR     CHKDAY          Check first to see if we have make it yet
	BCS     WHATDA9         Jump if equal otherwise watch the days go by
	JSR     BUMPDAY         Go to the next day
	BRA     WHATDA1         Continue to loop
WHATDA9 EQU     *                       
	RTS                     Return to the caller
*
*
*
**************************************************************************
* CHKDAY - Compares the Current day with the work day
**************************************************************************
*
* Routine: This routine compares the working day registers to the current
*       day registers and when they are equal, then the carry flag is 
*       set, otherwise carry is clear
*
CHKDAY  EQU     *               Finds the Day of the Week 
	LDAA    DSPYR           Get the current year
	CMPA    WKYR            See if we match
	BNE     CHKDAY1         No...jump an return to the caller
*        
	LDAA    DSPMON          Get the current month
	CMPA    WKMON           See if we match
	BNE     CHKDAY1         No...jump an return to the caller
*
	LDAA    DSPDAY          Get the current day
	CMPA    WKDAY           See if we match
	BNE     CHKDAY1         No...jump an return to the caller
*
	SEC                     Match located
	BRA     CHKDAY9         Exit
*
CHKDAY1 CLC                     Clear the carry...not a match
CHKDAY9 EQU     *
	RTS                     Return to the caller
*
*
*
**************************************************************************
* LCDTIM - Displays the time on the LCD
**************************************************************************
*
* Routine: This routine displays the current time on the LCD
*       in the format HH:MM WWW DD MMM
*       0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 
*       H  H  :  M  M  s  M  O  N  s  1  2  s  O  C  T
*
*       We use CBUFF as our string construction area
*
LCDTIM  EQU     *               Display the current time 
	LDX     #CBUFF          Index the string area for the display
	LDAA    CURHR           Get the current hour
	CMPA    #12             Make it into standard time
	BLT     LCDTIM1         Normal time...jump and convert
	SUBA    #12             24 hour time to normal time
LCDTIM1 BNE     LCDTIM2         Not zero...jump
	LDAA    #12             Special case between 12:00 -> 12:59
LCDTIM2 JSR     ITWOA           Convert the data to ASCII 
	STD     0,X             Save it
	LDAA    #ACOLON         ASCII :
	STAA    2,X             Save it
	LDAA    CURMIN          Get the current minute
	JSR     ITWOA           Convert the data to ASCII 
	STD     3,X             Save it
	LDAA    #ASPACE         Put in the spaces        
	STAA    5,X             Save it
	STAA    9,X             Save it
	STAA    12,X            Save it
*        
	LDAA    CURDAY          Get the current day
	JSR     ITWOA           Convert the data to ASCII 
	STD     10,X            Save it
*        
* Now we put in three characters from the Weekday date
*
	LDAB    WKWDAY          Get the current week day
	LSLB                    Multiply it by two
	LDY     #DAYOFWK        Table of day text
	ABY                     Add in the index
	LDY     0,Y             Get the new address in Y
	LDAA    0,Y             Get the first Char
	STAA    6,X             Save it
	LDAA    1,Y             Get the first Char
	STAA    7,X             Save it
	LDAA    2,Y             Get the first Char
	STAA    8,X             Save it
*        
	LDAB    CURMON          Get the current month
	LSLB                    Multiply it by two
	LDY     #MTABLE         Table of month text
	ABY                     Add in the index
	LDY     0,Y             Get the new address in Y
	LDAA    0,Y             Get the first Char
	STAA    13,X            Save it
	LDAA    1,Y             Get the first Char
	STAA    14,X            Save it
	LDAA    2,Y             Get the first Char
	STAA    15,X            Save it
*
	LDAA    #EOTEXT         Put in the terminator        
	STAA    16,X            Save it
	JSR     LCDTOP          Put this on the top line
	RTS                     Return to the caller
*
*
*
**************************************************************************
* HISTIM - Displays the time for the history display
**************************************************************************
*
* Routine: This routine displays the history time       
*       in the format HH:MM WWW DD MMM
*       0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 
*       1  2  p  m  s  1  0  -  M  A  Y  EOT
*
* Input:  DSPHR, DSPMON, DSPDAY
* Output: CBUFF as our string construction area
*
HISTIM  EQU     *               History time 
	CLR     CBUFFOV         Buffer overflow flag - zero=am  
	LDAA    DSPHR           Get the current hour
	CMPA    #12             Make it into standard time
	BLT     HISTIM1         Normal time...jump and convert
	INC     CBUFFOV         This is pm
	SUBA    #12             24 hour time to normal time
HISTIM1 BNE     HISTIM2         Not zero...jump
	CLR     CBUFFOV         Buffer overflow flag - zero=am  
	LDAA    #12             Special case between 12:00 -> 12:59
HISTIM2 JSR     ITWOA           Convert the data to ASCII 
	LDX     #CBUFF          Index the string area for the display
	STD     0,X             Save it
	TST     CBUFFOV         See if we are AM or PM
	BEQ     HISTIM3         Zero = AM
	LDAA    #ASMALLP        For PM
	BRA     HISTIM4         Jump and save it
*
HISTIM3 LDAA    #ASMALLA        For AM
HISTIM4 LDAB    #ASMALLM        For the rest
	STD     2,X             Save it
	LDAA    #ASPACE         Put in the spaces        
	STAA    4,X             Save it
	LDAA    DSPDAY          Get the current day
	JSR     ITWOA           Convert the data to ASCII 
	STD     5,X             Save it
	LDAA    #AMINUS         Put in the -        
	STAA    7,X             Save it
*        
	LDAB    DSPMON          Get the current month
	LSLB                    Multiply it by two
	LDY     #MTABLE         Table of month text
	ABY                     Add in the index
	LDY     0,Y             Get the new address in Y
	LDD     0,Y             Get the two char
	STD     8,X             Save it
	LDAA    2,Y             Get the last char
	STAA    10,X            Save it
*
	LDAA    #EOTEXT         Put in the terminator        
	STAA    11,X            Save it
	JSR     OUTSTRN         Send it out
	RTS                     Return to the caller
*
*
*
**************************************************************************
* DSPMODE - Display the current state of the CSS
**************************************************************************
*
* Routine: This routine checks the current mode, and if it is the same
*       is does nothing, but if changed, then it displays the current
*       machine state to the LCD bottom line
*
NORMODE EQU     *               Sets up for normal display mode
	LDAA    #STMAIN         Back in the main loop
*
SETMODE EQU     *               Sets the new state and then falls thru
	STAA    NEWMODE         Save the new state 
*
DSPMODE EQU     *               Display the current CSS state
	LDAB    NEWMODE         Get the new mode
	CMPB    OLDMODE         See if we have changed state
	BEQ     DSPMOD9         No change...jump and exit
*
* The state has changed...fetch the text from the index value of the mode
* and send it out to the LCD
*
	STAB    OLDMODE         Save our current state
	CMPB    #STMAIN         Are we just doing standard information?
	BGE     DSPMOD7         Jump and continue
*
* Here we copy the text into a temporary buffer
*
	LSLB                    Multiply it by two
	LDY     #STATBLE        State table index
	ABY                     Point into the table
	LDX     0,Y             Fetch the index
	LDY     #CBUFF          This will be our text build area
	LDAA    #12             Copy this many characters
	JSR     MEMCPY          Move the data
	LDAB    OLDMODE         Get our value back
	CMPB    #DIRSENS        Is this wind direction?
	BNE     DSPMOD2         No...continue to look
*
* Here we handle the wind direction printout
*
	LDX     #WINDIRC        This is where we get the data
	BRA     DSPMOD5         Jump and do the display
*
DSPMOD2 CMPB    #BPRSENS        Is this a pressure printout request?
	BNE     DSPMOD4         No...jump and just printout the value
*
* Here we handle the BP printout
*
	LDAA    BPRESUR         Get the barometric pressure
	STAA    CURBP           Save it away for the printout
	JSR     BPRINT          Print the pressure in standard format
	LDX     #BPRESSC        Load the character address
	LDY     #CBUFFAX        This will be our text/data build area
	DEY                     Back off one space
	LDAA    #6              Copy this many characters
	BRA     DSPMOD6         Jump and do the display
*        
* It's a temp value...now fetch it, convert it to ascii and move it
* If it is not a temp value, then we do an unsigned convert
*
DSPMOD4 CMPB    #BPRSENS        See if we are past the temp values
	BLE     DSPMODA         No...must be a temp sensor...jump
	INC     UNSIGN          Yes...no negative numbers please
*
DSPMODA LDX     #TMPDATA        Address of the DS1820 results save area
	ABX                     Add in the offset
	LDAA    0,X             Get the real temperature value
	JSR     ITOA            Convert it to ASCII
	CLR     UNSIGN          We do +/- normal display 
	LDX     #ITOAC          Load the character address
DSPMOD5 LDY     #CBUFFAX        This will be our text/data build area
	LDAA    #5              Copy this many characters
DSPMOD6 JSR     MEMCPY          Move the data
	LDX     #CBUFF          This will be our text build area
	BRA     DSPMOD8         Jump and do the display
*
* Normal format for the state
*
DSPMOD7 LSLB                    Multiply it by two
	LDY     #STATBLE        State table index
	ABY                     Point into the table
	LDX     0,Y             Fetch the index
DSPMOD8 EQU     *               Write it out        
	JSR     LCDBOT          Put this on the bottom line
DSPMOD9 RTS                     Return to the caller
*
*
*
**************************************************************************
* SHOWCSS - Display the current state of the CSS
**************************************************************************
*
* Routine: This routine is used to show the login and time conditions
*       of CSS to the user.
*
SHOWCSS EQU     *               Display the CSS time and status information
	LDX     #VMSMSG5        Load up the VT100 setup message
	JSR     OUTSTRG         Send it out
	JSR     HOMECLR         Home and Clear the screen
	LDX     #VMSMSG3        Load up the welcome message
	JSR     OUTSTRG         Send it out
	LDAA    VERSION         Get the build version number 
	JSR     PRINTA          Convert it to ASCII and print it out
*       
	JSR     CPINIT          Setup the host port for the CP290
	JSR     GETDATE         Fetch the CP290 time
	BCC     SHOWCS1         Jump if we have problems...print a message
	LDX     #DSPMSGE        The 'the current time' header message
	JSR     OUTSTRG         Send it out
	LDX     #CURTIM         Current time location
	JSR     SHOWTIM         Print day and time
	BRA     SHOWCS2         Continue operation
*
SHOWCS1 EQU     *               CP290 is not communicating
	LDX     #DSPMSGD        Load up the CP290 down message
	JSR     OUTSTRG         Send it out
	JSR     SETUPCP         Setup the CP290 with time and scan events
	BCC     SHOWCS9         User gone...jump, it will exit
*        
SHOWCS2 
	LDX     #DSPMSGF        The 'the cold time' header message
	JSR     OUTSTRG         Send it out
	LDX     #COLDATE        Cold time location
	JSR     SHOWTIM         Print day and time
*
	LDX     #DSPMSGG        The 'the warm time' header message
	JSR     OUTSTRG         Send it out
	LDX     #WRMDATE        Warm time location
	JSR     SHOWTIM         Print day and time
*
	LDX     #DSPMSGL        The date of the last scan before powerfail
	JSR     OUTSTRG         Send it out
	LDX     #SCNDATE        Current time location
	JSR     SHOWTIM         Print day and time
*
	LDX     #DSPMSGH        The last date of user login
	JSR     OUTSTRG         Send it out
	LDX     #USRDATE        Current time location
	JSR     SHOWTIM         Print day and time
*
	LDX     #DSPMSGC        Load up the good LOGIN count message
	JSR     OUTSTRG         Send it out
	LDAA    SIGNONG         Get the good signon count
	INC     UNSIGN          No negative numbers please
	JSR     PRINTA          Convert it to ASCII and print it out
*        
	LDX     #DSPMSG1        Load up the unsuccessful LOGIN info message
	JSR     OUTSTRG         Send it out
	LDAA    SIGNONB         Get the number of signon attempts
	JSR     PRINTA          Convert it to ASCII and print it out
	CLR     SIGNONB         Clear the bad signon counter
*        
	LDX     #DSPMSGJ        Load up the number of history days
	JSR     OUTSTRG         Send it out
	LDAA    NUMDPTR         Get the number of history days
	JSR     PRINTA          Convert it to ASCII and print it out
*
	CLR     UNSIGN          Return flag to normal +/- 
	LDX     #DSPMSG5        Display Function complete.
	JSR     OUTSTRG         Send it out
	JSR     GETSTR          Wait for CR before we continue
*
SHOWCS9 EQU     *
	RTS                     Return to the main menu
*
*
**************************************************************************
* GODEBUG - Jumps back to BUFFALO on the user's request
**************************************************************************
*
* Routine: This routine asks the user if you're sure you want to do this
*       along with the warning to call CSS back to restart us back when
*       done with debug.   Then we jump off...
*
DODEBUG EQU     *               Jump to BUFFALO
	LDX     #DSPMSG3        Load up the BUFFALO warning message
	JSR     OUTSTRG         Send it out
	JSR     GETYSNO         Get the user response
	BCC     DODEBU9         User is gone...so are we
	BVC     DODEBU9         No...it is not OK...jump back to main menu
	JMP     BUFISIT         Here we go, bypass the porte bit 0 check 
*       JMP     BUFFALO         Here we go...we are out of control...
*
DODEBU9 RTS                     Back to the main menu
*
*
*
**************************************************************************
*  GOWIND - Get the current wind direction and build the ASCII string
**************************************************************************
*
* Routine: This routine gets the wind direction information from PORTC
*       and translates the value into ASCII text for printing.  The 
*       resulting EOT terminated string is in WINDIRC
*
GOWIND  EQU     *               Create the wind ASCII string
	LDX     #WINDIRC        This will be where we put the ASCII string
	PSHX                    Save X
	LDAA    #ASPACE         Pad out the display
	STAA    2,X             Space out the string before we start
	STAA    3,X             ditto
*
	CLR     TFLAG           This will be our offset into the WINDIRC
	LDX     #PORTA          Address of port A
	BCLR    0,X #WINDON     Turn down the wind enable bit - LOW ACTIVE
	FDIV                    Take some time for line to go stable
	FDIV                    ditto
	LDX     #WINVAL         Get index of bit table to check against
	LDY     #WINDIR         This is our string of characters
	CLR     DDRC            Turn C port into input data
	LDAA    PORTC           Get the wind direction value
	COMA                    Invert the bits
	STAA    WINDDIR         Save the direction
GOWIN1  BITA    0,X             See if we are ON
	BEQ     GOWIN8          Continue...nothing is set here
*
* Ok, we have a match, now we want to put the correct string in WINDIRC
* so we can print it when requested.
*
	PSHA                    Save the registers
	PSHX
	LDX     #WINDIRC        This will be where we put the ASCII string
	LDAB    TFLAG           This is our offset value
	ABX                     Add in the offset to the index
	ADDB    #2              Bump our offset value
	STAB    TFLAG           Save it back for later use
	LDD     0,Y             Get the ASCII text
	STD     0,X             Save it in the WINDIRC
	PULX                    Restore the registers
	PULA
	LDAB    TFLAG           Get out offset back
	CMPB    #4              Have we filled up the character buffer?
	BEQ     GOWIN9          Jump and exit...we are done
*        
GOWIN8  INY                     Bump to the next direction string
	INY                     Ditto
	INX                     Go to the next direction value
	TST     0,X             Are we done?  Zero gets us out.
	BNE     GOWIN1          Continue the effort
*        
* Now we turn off PORTC wind direction enable
*
GOWIN9  EQU     *               
	LDAA    #EOTEXT         Get the termination character
	PULX                    Restore the X register
	STAA    4,X             Zero out the string before we start
	LDX     #PORTA          Address of port A
	BSET    0,X #WINDON     Turn off the wind enable bit - LOW ACTIVE
	RTS                     Back to who called us
*
*
*
**************************************************************************
*  WSETUP - Wind Speed Setup routine
**************************************************************************
*
* Routine: This routine sets up the pulse accumulator for gathering
*       pulses from the weather boom.
*
WSETUP  EQU     *               Setup the pulse accumulator 
	LDAA    PACTL           Get the current PA control values
	ANDA    #$03            Keep just the RTL adjustment count
	ORAA    #$50            Put in our values:
*                               0=DDRA7 for input
*                               1=PAEN enable pulse accumulator
*                               0=PAMOD count pulses
*                               1=PEDGE rising edge
	STAA    PACTL           Save the value
	CLR     PACNT           Start the count from zero
	RTS                     Back to who called us
*
*
*
**************************************************************************
*  WSPEED - Take the value of the pulse accumulator as the wind spped
**************************************************************************
*
* Routine: This routine get the pulse accumulator and converts it to
*       a string for printout
*
WSPEED  EQU     *               Get the pulse accumulator 
	LDAA    PACNT           Get the current PA control values
	STAA    WINDSPD         Save the counter
	CLR     PACNT           Clear the value
	INC     UNSIGN          Do a unsigned conversion
	JSR     ITOA            Convert to a ascii string
	CLR     UNSIGN          Return flag to normal +/- 
	RTS                     Back to who called us
*
*
**************************************************************************
* BONEIS - Bus One Wire Initialization Sequence
**************************************************************************
*
* The initialization/reset sequence for the one wire bus is as follows:
*       a) Transmit a low for 480-960 usec
*       b) Release the bus
*       c) Wait for 240 usec for the 1820s to issue their 'presence'
*               signal indicating the bus is active
*
* Register A&B are saved
*
* Carry Clear = BAD - The 'presence' pulse did not come back
* Carry Set = GOOD - Bus is active and ready to go
*
**************************************************************************
*
BONEIS  EQU     *               Bus One Initialization seqnence
	PSHA                    Save the A register
	PSHB                    Save the B register
	JSR     BONELO          Turn the bus low
*
* Now we get the current timer counter and add in our wait count
* then save it back in the timer compare register 4
*
	LDD     TCNT            Get the current timer counter
	ADDD    #1000           500 usec of ticks
	STD     TOC4            Save it in timer compare register 4
	LDAA    #TOC4F          Write a one for the compare register
	STAA    TFLG1           Resets the compare register flag
*
* Now we can bit spin waiting for the timer to expire
*
BONEI1  LDAA    TFLG1           Get the timer flag register
	ANDA    #TOC4F          Just look at the timer compare 4
	BEQ     BONEI1          Continue to wait
*        
	JSR     BONEHI          Release the one wire bus
*
* Now we can bit spin waiting for either the timer to expire or the
* 'presence' pulse to come back on the one wire bus.   If the 'presence'
* pulse comes back first, we still wait the entire time.
*
	LDD     TCNT            Get the current timer counter
	ADDD    #1000           500 usec of ticks
	STD     TOC4            Save it in timer compare register 4
	LDAA    #TOC4F          Write a one for the compare register
	STAA    TFLG1           Resets the compare register flag
*
BONEI2  LDAA    PORTD           Get the PORT D value
	ANDA    #$20            Did we get a 'presence' pulse?
	BNE     BONEI3          Yes...branch and get out
	LDAA    TFLG1           Get the timer flag register
	ANDA    #TOC4F          Just look at the timer compare 4
	BEQ     BONEI2          Continue to wait
*
* We waited the specified time, and nothing came back.   This is bad
* so we clear the carry and get out.
*
	CLC                     Clear the carry flag...this is an error
	BRA     BONEI9          Get out
*
* Now we wait the rest of the time allocated for the 'reset' signal
*
BONEI3  LDAA    TFLG1           Get the timer flag register
	ANDA    #TOC4F          Just look at the timer compare 4
	BEQ     BONEI3          Continue to wait
	SEC                     Set the carry...this is good
*
BONEI9  EQU     *               Exit
	PULB                    Restore the B register
	PULA                    Restore the A register
	RTS                     Return to the caller
*
*
**************************************************************************
* BONELO - Drive the Bus One Wire Low
**************************************************************************
*
BONELO  EQU     *               Drive the one write bus low
*
* Here we set the D5 bit low in the Output register
*
	LDAA    PORTD           Get the current contents of PORT D
	ANDA    #$DF            Save everything but bit 5
	STAA    PORTD           Put it back in the output register
*
* Now we set the D5 bit in the data direction register to be output
* which will drive the one wire bus low
*
	LDAA    DDRD            Get the data direction register for PORT D
	ORAA    #$20            Add in bit 5
	STAA    DDRD            Drive the one wire bus low
	RTS                     Return to the caller
*
*
**************************************************************************
* BONEHI - Releae the Bus One Wire to go back to the high state
**************************************************************************
*
BONEHI  EQU     *               Release the one write bus to go back high
*
* Now we clear the D5 bit in the data direction register which 
* will release the drive on the one wire bus and let it go high
*
	LDAA    DDRD            Get the data direction register for PORT D
	ANDA    #$DF            Clear bit 5
	STAA    DDRD            Release the one wire bus back high
	RTS                     Return to the caller
*
*
**************************************************************************
* BONEW0 - Writes a zero to the one wire bus
**************************************************************************
*
* To write a zero on the one wire bus we hold the line down for the 
* entire period.
*
BONEW0  EQU     *               Write a zero to the bus                           
	PSHA                    Save A register
	PSHB                    Save B register
	JSR     BONELO          Turn the bus low
	LDD     TCNT            Get the current timer counter
	ADDD    #120            60 usec of ticks
	STD     TOC4            Save it in timer compare register 4
	LDAA    #TOC4F          Write a one for the compare register
	STAA    TFLG1           Resets the compare register flag
*
* Now we can bit spin waiting for the timer to expire
*
BONEW2  LDAA    TFLG1           Get the timer flag register
	ANDA    #TOC4F          Just look at the timer compare 4
	BEQ     BONEW2          Continue to wait
*        
	JSR     BONEHI          Release the bus
	PULB                    Restore B
	PULA                    Restore A
	RTS                     Return to the caller
*
*
**************************************************************************
* BONEW1 - Writes a one to the one wire bus
**************************************************************************
*
* To write a one on the one wire bus, we pulse the bus low for 
* 6 usec, then release the bus to go back high
*
BONEW1  EQU     *               Write a one to the bus                           
	PSHA                    Save A register
	PSHB                    Save B register
	JSR     BONELO          Turn the bus low
	JSR     BONEHI          Release the bus
	LDD     TCNT            Get the current timer counter
	ADDD    #120            60 usec of ticks
	STD     TOC4            Save it in timer compare register 4
	LDAA    #TOC4F          Write a one for the compare register
	STAA    TFLG1           Resets the compare register flag
*
* Now we can bit spin waiting for the timer to expire
*
BONEW3  LDAA    TFLG1           Get the timer flag register
	ANDA    #TOC4F          Just look at the timer compare 4
	BEQ     BONEW3          Continue to wait
	PULB                    Restore B
	PULA                    Restore A
	RTS                     Return to the caller
*
*
**************************************************************************
* BONERB - Reads a bit from the one wire bus
**************************************************************************
*
* To read a bit from the bus, we pulse the bus, and wait to see
* what comes back.
*
*  Carry Set = bit is read HIGH
*  Carry Clear = bit is read LOW
*
BONERB  EQU     *               Reads a bit from one wire bus                           
	PSHA                    Save the A register
	PSHB                    Save the B register
*        
* In order to maxmize our master sample time, we move the timer setup
* ahead of the bus read command.   This will give us a few more cycles.
* We sample the bus for only 15 usec after the falling edge of the read.
*
	LDD     TCNT            Get the current timer counter
	ADDD    #140            70 usec of ticks
	STD     TOC4            Save it in timer compare register 4
	LDAA    #TOC4F          Write a one for the compare register
	STAA    TFLG1           Resets the compare register flag

*        
* Now we issue a read command
*
	JSR     BONELO          Turn the bus low
	JSR     BONEHI          Release the bus
	MUL                     Give the wire a chance to recover
	MUL
	MUL
	NOP
	NOP
*
* Now we quickly wait for the sample window...no time to do anything else
*
BONER1  LDAA    PORTD           (4) Get the PORT D value
	ANDA    #$20            (2) Did we read a pulse?
	BNE     BONER3          (3) Yes...branch and get out
	CLC                     Clear the carry flag
	BRA     BONER8          Continue to wait the required time
*
BONER3  SEC                     The bus went high...we have a one
	LDAA    TFLG1           Get the timer flag register
	ANDA    #TOC4F          Just look at the timer compare 4
	BEQ     BONER1          Continue to wait
	BRA     BONER9          Wait is over..exit
*
* Our sample is over, but we must wait the rest of the time 
*
BONER8  LDAA    TFLG1           Get the timer flag register
	ANDA    #TOC4F          Just look at the timer compare 4
	BEQ     BONER8          Continue to wait the remainder time
*
BONER9  PULB                    Restore the B register
	PULA                    Restore the A register
	RTS                     Return to the caller
*
*
**************************************************************************
* BONEBW - Writes a byte to the one wire bus
**************************************************************************
*
* This routine will writes the A register byte to the one wire bus.
*
* Register A is what we write and it is saved
* Register B is also saved
*
BONEBW  EQU     *               Write A to the bus
	PSHA                    Save A on the stack
	PSHB                    Save B on the stack
	LDAB    #$7F            This is our shift bit counter    
BONEB1  LSRA                    Shift A right into the carry
	BCC     BONEB3          Jump if carry is clear and write a zero
	JSR     BONEW1          Carry set...write a one
	BRA     BONEB5          Jump and continue
*
BONEB3  JSR     BONEW0          Write out a zero to the bus
*
* Do the book keeping to keep track of how many we have written
*
BONEB5  LSRB                    Now put a bit from B into the carry
	BCS     BONEB1          Continue to send out bits     
	PULB                    Until we are done...
	PULA                    Restore the registers
	RTS                     Return to the caller
*
*
**************************************************************************
* BONEBR - Reads a byte from the one wire bus
**************************************************************************
*
* This routine will read a byte from the one wire bus and return it  
* in the A register.
*
* Register A is what we read from the bus
* Register B is also saved
*
BONEBR  EQU     *               Read a byte from the bus into A 
	PSHB                    Save B on the stack
	CLRA                    Wipe out A
	LDAB    #$7F            This is our shift bit counter    
BONEB7  JSR     BONERB          Read a bit from the bus 
	RORA                    Shift it into A top > down
*
* Do the book keeping to keep track of how many we have written
*
	LSRB                    Now put a bit from B into the carry
	BCS     BONEB7          Continue to send out bits     
	PULB                    Until we are done...
	RTS                     Return to the caller
*
*
**************************************************************************
* BONEXR - Reads the ROM address from the DS1820
**************************************************************************
*
* This routine reads the ROM value from the DS1820 connected to the
* one wire bus.   
*
* NOTE: This is a diagnostic test routine, and assumes that there is
* only one device on the bus.    It is used to identify a DS1820 so that
* its ROM code can be entered into the system.
*
*
BONEXR  EQU     *               Read the ROM from the DS1820
	LDX     #DSDATA         Address for the communication area
	LDAB    #$7F            This is our shift bit counter    
	LDAA    #$5A            Test pattern
BONEX1  STAA    0,X             Plug this value
	INX                     Bump to the next index location
	LSRB                    Now put a bit from B into the carry
	BCS     BONEX1          Continue to send out bits     
*        
	JSR     BONEIS          Reset the bus...ready for action
	BCC     BONEX9          Jump if we do not get the 'presence' 
	LDAA    #READROM        Command to Read the ROM on the DS1820
	JSR     BONEBW          Send it out
*        
	LDX     #DSDATA         Address for the communication area
	LDAB    #$7F            This is our shift bit counter    
BONEX3  JSR     BONEBR          Read a byte from the bus 
	STAA    0,X             Save it in the communication area
*
* Do the book keeping to keep track of how many we have written
*
	INX                     Bump to the next index location
	LSRB                    Now put a bit from B into the carry
	BCS     BONEX3          Continue to send out bits     
BONEX9  EQU     *
	RTS                     Return to the caller
*
*
**************************************************************************
* BONETR - Reads a temperature value from one of the DS1820 devices
**************************************************************************
*
* This routine will command the DS1820 to take its temperature and 
* converts the value into oF from the table lookup then saves it 
* back into the desired location
*
* Register X points to the ROM address of the desired DS1820 
* Register Y points to the address to place the temperature
*
* Register A and B are saved
*
BONETR  EQU     *               Reads a temperature value from a DS1820 
	PSHA                    Save A on the stack
	PSHB                    Save B on the stack
	PSHX                    Save X on the stack
	PSHY                    Save Y on the stack
	JSR     BONEIS          Reset the bus
	LDAA    #MACHROM        Command to match this ROM value
	JSR     BONEBW          Send it out
	LDAB    #$7F            This is our shift bit counter    
BONET1  LDAA    0,X             Get the ROM byte
	JSR     BONEBW          Send it out
	INX                     Bump the counter
	LSRB                    Now put a bit from B into the carry
	BCS     BONET1          Continue to send out bits     
*
* At this point we have the attention of one of the DS1802 devices.
* Now we can ask the DS1820 to send us the temperature value
* We only want the first two bytes of data, and we terminate the read
*
	LDAA    #READTMP        Command to read the temperature value
	JSR     BONEBW          Send it out
	LDAB    #$7F            This is our shift bit counter    
	JSR     BONEBR          Read the first byte in
	TAB                     Put it in the B register for now
	JSR     BONEBR          Read the second byte in
*
* Now we have a 16 bit temp value from the DS1820 in the D register
*
	ADDD    #124            Add our magic offset to make it into an index
	LDX     #TMPTTBL        Get address the temp conversion table
	ABX                     Add in the index value
	LDAA    0,X             Get the converted value
	STAA    0,Y             Save it in the desired location
*
* We are done
*
	PULY                    Until we are done...
	PULX                    Restore the registers
	PULB                    Restore the registers
	PULA                    Restore the registers
	RTS                     Return to the caller
*
*
**************************************************************************
* SCANTP - Scans one wire bus collecting the temperature values
**************************************************************************
*
* This routine will spin through the DS1820s connected to the one wire
* bus commanding them to take their temperature and report it back to
* the desired location.
*
* Registers A and B are saved
*
SCANTP  EQU     *               Scans temperature values from one wire bus 
	PSHA                    Save A on the stack
	PSHB                    Save B on the stack
	JSR     BONEIS          Reset the bus
	LDAA    #SKIPROM        Command everybody to listen up
	JSR     BONEBW          Send it out
	LDAA    #TAKETMP        Command to take your temperature
	JSR     BONEBW          Send it out
	JSR     WAITONE         Wait a second
	JSR     WAITONE         And another...
*
* Now everyone has the temperature in their scratchpad area...now fetch it
*
	LDY     #TMPDATA        This is where we want to store the data
	CLR     TFLAG           This is our index offset
	CLRB                    Clear out B
*
SCANT1  LSLB                    Shift *2 for a two byte pointer value
	LDX     #TMPIDX         Get the pointer to the list of pointers
	ABX                     Adjust the offset
	LDX     0,X             This is the ROM code for the DS1820 device
	JSR     BONETR          Fetch the temperature from the device
*
* Now we do the housekeeping to adjust to the next device
*
	INY                     Bump to the next store location
	INC     TFLAG           Bump our counter
	LDAB    TFLAG           Get the value
	CMPB    #TMPSENS        See if we have more to do
	BNE     SCANT1          Continue to scan for temp data
*
	PULB                    Until we are done...
	PULA                    Restore the registers
	RTS                     Return to the caller
*
*
*
**************************************************************************
* BPRINT - Printout the barometric pressure 
**************************************************************************
*
* This routine will convert the given pressure into a standard format
* It uses CURBP as the value to convert and print.   The data is converted
* into BPRESSC buffer for output.
*
* Here's the plan:  The A/D converts a voltage between 2.50 and 3.80
* to a value between 0-255, which represents 28.00 - 33.00 inches of Hg
* so we assign a range of values as follows:
*
*       0 -  51 = 28.xx
*      52 - 102 = 29.xx
*     103 - 153 = 30.xx
*     154 - 204 = 31.xx
*     205 - 255 = 32.xx
*
*
BPRINT  EQU     *               Printout the title and version
	LDAA    #28             First value
	STAA    SFLAG           Save it here
	LDAB    #51             First cutoff range
	LDAA    CURBP           Get the value to compare
BPRINT1 CBA                     See where we are
	BLS     BPRINT2         We have found the range
	SUBA    #51             Back off the value
	INC     SFLAG           Go up the scale
	BRA     BPRINT1         Continue to loop
*
* Here TFLAG contains a value between 28-32 and B has a value 51 for compare
*
BPRINT2 PSHA                    Save our count
	LDY     #BPRESSC        Save the character address
	LDAA    SFLAG           Print this value out
	INC     UNPAD           Do not pad our value!
	JSR     ITOA            Convert it to ASCII
	CLR     UNPAD           We can have padding now
	LDX     #ITOAC          Load the character address
	LDD     0,X             Get the two characters
	STD     0,Y             Save them
	LDAA    #APERIOD        Send out a period
	STAA    2,Y             Save a dot
*
* Now convert the final two digits
*
	PULA                    Get our value back
	LSLA                    *2
	CMPA    #100            See if we are over the top
	BLO     BPRINT3         No...jump and continue
	LDAA    #99             Take the maximum value
BPRINT3 CMPA    #10             See if we must add an ascii zero
	BHS     BPRINT4         No need...just jump and continue
	LDAB    #ASCII0         Send out a zero for looks
	STAB    3,Y             xx.0
	ORAA    #$30            Make it ASCII by hand
	STAB    4,Y             xx.0x
	BRA     BPRINT9         End it off
*
BPRINT4 JSR     ITOA            Convert it to ascii
	LDX     #ITOAC          Load the character address
	LDD     0,X             Get the value
	STD     3,Y             Save it
*
BPRINT9 EQU     *               End off the string
	LDAA    #EOTEXT         Mark the end of the string
	STAA    5,Y             Save it
	RTS                     Return to the caller
*
*
*
**************************************************************************
* HISETUP - Setup the history data structure 
**************************************************************************
*
* This routine will take the ADSCAN values and load them into both the
* high and low (HIGHVAL and LOWSVAL) structures to act as our starting
* point for comparison.
*
HISETUP EQU     *               History data structure setup
	CLR     TFLAG           This will be our counter
	CLRB                    This will be our offset
HISETU2 LDY     #HIGHVAL        This is where we want to save them
	LDX     #ADSCAN         Get the index to the sensor values
	ABX                     Add in the offset
	LDAA    0,X             Get the sensor value
	LSLB                    *4 for our history data
	LSLB                    ditto
	ABY                     Add in our index
	STAA    0,Y             Save the value
	LDAA    CURMON          Get the current month
	STAA    1,Y             Save the value
	LDAA    CURDAY          Get the current day
	STAA    2,Y             Save the value
	LDAA    CURHR           Get the current hour
	STAA    3,Y             Save the value
	INC     TFLAG           Bump to the next sensor
	LDAB    TFLAG           Get the offset back
	CMPB    #HLBYTES        Number of high/low bytes 
	BNE     HISETU2         Loop back and do some more
*
* Now we just copy the data from the high -> lows
*
	LDX     #HIGHVAL        This is where we copy from
	LDY     #LOWSVAL        This is where we want to save them
	LDAA    #HLHSIZE        This is the count
	JSR     MEMCPY          Copy the data
	RTS                     Return to the caller
*        
*
*
**************************************************************************
* HIGLOWS - Make the necessary comparisons for high/low values 
**************************************************************************
*
* This routine will take the ADSCAN values and compare them with the
* high and low (HIGHVAL and LOWSVAL).
*
HIGLOWS EQU     *               High/Low comparison
	CLR     TFLAG           This will be our counter
	CLRB                    This will be our offset
*
* First we do the high values
*
HIGLOW2 LDY     #HIGHVAL        This is where we want to save them
	LDX     #ADSCAN         Get the index to the sensor values
	ABX                     Add in the offset
	LDAA    0,X             Get the sensor value
	LSLB                    *4 for our history data
	LSLB                    ditto
	ABY                     Add in our index
	LDAB    0,Y             Get the value
*
* At this point A contains the current value and B contains last high value
*
	CBA                     See how they match (A-B)
	BEQ     HIGLOW3         Equal means we have a new high value
	BMI     HIGLOW4         Current is lower...jump and go to the next
HIGLOW3 STAA    0,Y             Save the new high value
	JSR     TIM2HIS         Save the time
*
HIGLOW4 INC     TFLAG           Bump to the next sensor
	LDAB    TFLAG           Get the offset back
	CMPB    #HLBYTES        Number of high/low bytes 
	BNE     HIGLOW2         Loop back and do some more
*
* Now we do the low values values
*
	CLR     TFLAG           This will be our counter
	CLRB                    This will be our offset
HIGLOW6 LDY     #LOWSVAL        This is where we want to save them
	LDX     #ADSCAN         Get the index to the sensor values
	ABX                     Add in the offset
	LDAA    0,X             Get the sensor value
	LSLB                    *4 for our history data
	LSLB                    ditto
	ABY                     Add in our index
	LDAB    0,Y             Get the value
*
* At this point A contains the current value and B contains last low value
*
	CBA                     See how they match (A-B)
	BEQ     HIGLOW7         Equal means we have a new low value
	BPL     HIGLOW8         Current is higher...jump and go to the next
HIGLOW7 STAA    0,Y             Save the new high value
	JSR     TIM2HIS         Save the time
*
HIGLOW8 INC     TFLAG           Bump to the next sensor
	LDAB    TFLAG           Get the offset back
	CMPB    #HLBYTES        Number of high/low bytes 
	BNE     HIGLOW6         Loop back and do some more
*
	RTS                     Return to the caller
*
*
*
******************************************************************************
* TIM2HIS - Helper routine for moving the history time  
******************************************************************************
*
* Routine: This routine is called from above to move the correct history time
*
TIM2HIS EQU     *               Move history time        
	LDAA    CURMON          Get it
	STAA    1,Y             Save the CURMON
	LDAA    CURDAY          Get it
	STAA    2,Y             Save the CURDAY
	LDAA    CURHR           Get it
	STAA    3,Y             Save the CURHR
	RTS                     Return to the upper loop
*
*        
	LDAA    #$50            To enable the stop command
	TAP                     Put it in the CC register
	STOP                    This is here to halt the CPU on runaway
*
******************************************************************************
* RAM starting address
******************************************************************************
*
*
	ORG     RAMSTRT         Begin our data section
STRRAM  EQU     *               Starting RAM location used for clear routine
*
* CP2SAVE pointer is the beginning of a contigious area of less than 512 
* byte area that is mirrored into the CP290 at the end of every scan period 
* for powerfail backup.   NOTE: we do not copy everything...just from the 
* CP2SAVE to the CP2QUIT (since it takes so long to communicate with the 
* CP290, over a minute to download 512 bytes, we just do a small amount
*
* NOTE: 29OCT95 - Another unexpected problem with the CP290, in that it
* has a quirk if the upper byte to be saved is zero, then it assumes
* (which is hard to understand why the makers of the CP290 would do this)
* that the area is blank, and skips over it.   So to compensate for this
* wonderful feature, we have carefully arranged the values below so that
* we are sure that zero will not be seen in the leading byte!
*
* Note: (14Nov2000) since we are just about ready to deploy this unit 
* back at the cabin, I made the decision to keep the year starting from
* zero to indicate 2000, knowing that it will fail to load down to the 
* CP290 correctly due to the above error, but this will be OK once we
* hit the next century, for 1 will be 2001 and things will work fine.
* This was simply easier than to put a bunch of checks in for zero.
*
CP2SAVE EQU     *               Starting address to save important data
*
* The CURxxx are the current values used by the CABIN SYSTEM 
*
CURTIM  EQU     *               Current time values
CURYR   RMB     1               Current Year 0 = year 2000
CURHR   RMB     1               Current Hour (0-23)
CURMON  RMB     1               Current Month (1-12)
CURMIN  RMB     1               Current Minute (0-59)
CURDAY  RMB     1               Current Day (1-31)
CURSEC  RMB     1               Current Second (0-59) seconds we count down!
*
*
COLDATE RMB     6               Date cabin system cold started CP290 was off
USRDATE RMB     6               Last time someone logged into the system
*
* These values are used to maintain the DOOR information:
*
* The first 6 bytes are the open date, mirrored from the information above
* The next 6 bytes are the close date, mirrored from the information above
* The next byte is a count of open/close cycles
* 
* Door status register is a copy of the E register.   We use this copy
* whenever a change has occured the last time we checked the door status
*
DCOUNT  EQU     13              Door open/close count
DTOTAL  EQU     14              Total number of door date bytes
*
SMDOOR  RMB     DTOTAL          Save area for Main door status
SBDOOR  RMB     DTOTAL          Save area for Basement door status
SNDOOR  RMB     DTOTAL          Save area for North Garage door status
SSDOOR  RMB     DTOTAL          Save area for South Garage door status
*
SIGNONG RMB     1               Number of good signons since booted
SIGNONB RMB     1               Number of aborted signons since booted
*
*
CP2QUIT EQU     *               Ending address to save important data
*
WRMDATE RMB     6               Power fail date warm started CP290 was OK
SCNDATE RMB     6               Date of the last scan time before power fail 
CBUFFMX EQU     20              Maximum number of input characters
NEWMODE RMB     1               New State - Used for LCD display
OLDMODE RMB     1               Old State
TFLAG   RMB     1               General flag field
ECHOIT  RMB     1               Echo the input back.
DELAYWK RMB     1               Delay routine # of 25msec intervals to wait
DSTATUS RMB     1               Last changed door status
CURBP   RMB     1               Current BP for printout subroutine
*
CURWDAY RMB     1               Current Week Day in CP290 format
*
* Here's a bit of documentation concerning the history data area:
* The history area is a single block of memory divided into scan layers.
* Each scan represents SNBYTES of data.   The master pointer to this history
* block is HFLINK,   The start of the buffer is HISTOP, and the end 
* is HISEND.   The init routine sets HFLINK to HISTOP, and after every
* scan, we bump the HFLINK to the next scan location, up to HISEND, then
* we wrap back around.   We also keep a scan count NUMSCAN, which is cleared
* on startup and then incremented each scan until MAXSCAN is reached, meaning
* a full history buffer.
*
* Now to keep track of where the days are in the history buffer, there is
* a structure HISIDX, which contains CURDAY, CURMON, and HFLINK (four bytes).
* one for each day.   The CURDPTR is the offset into the HISIDX structure.
* The day we begin will not be a 24 hour day, therefore we keep a BHISHR,
* which contains CURHR of the time we began the history.   We also keep a
* NUMDPTR which is incremented each day to MAXDPTR, which is the maximum
* number of history days we can hold
*
NUMDPTR RMB     1               Number of history days <= MAXDPTR
CURDPTR RMB     1               Current history index (number history days)
BHISTHR RMB     1               Beginning history hour (when CURDPTR = 0)
NUMSCAN RMB     2               Number of history scan values
*
MAXDPTR EQU     25              Limit to the number of history days
MAXHRDY EQU     24              Maximum hours/day
MAXSCAN EQU     MAXDPTR*MAXHRDY Maximum number of scan value (24*MAXDPTR)
*
* There is a directory area consisting of day pointers of:
*       CURMON - CURDAY - HFLINK.
*
HFLINK  RMB     2               History pointer forward link
HISDAYC EQU     4               CURMON,CURDAY,HFLINK (two bytes)
HISIDXS EQU     MAXDPTR*HISDAYC Max Number of days * 4 bytes per day
HISIDX  RMB     HISIDXS         History index DAY pointer structure
*
* These structures are used for communication with the CP290
*
CBUFFOF EQU     12              Offset into CBUFF for number
CBUFFAX EQU     *+CBUFFOF       Place to put the converted temp data
CBUFF   RMB     CBUFFMX         Input character buffer
CBUFFOV RMB     1               Overflow byte...just in case
CBUFFPT RMB     1               Character counter
*
FIFOMAX EQU     40              Maximum size of the FIFO
PCFIFO  RMB     FIFOMAX         FIFO of data to be sent to the PC
	RMB     1               End of the PCFIFO
PCFPTR  RMB     1               Forward offset pointer for FIFO
PCBPTR  RMB     1               Backward pointer for FIFO
*
CPFIFO  RMB     FIFOMAX         FIFO of data to be sent to the CP290
SFLAG   RMB     1               End of the CPFIFO
CPFPTR  RMB     1               Forward offset pointer for FIFO
CPBPTR  RMB     1               Backward pointer for FIFO
*
BEENLOW RMB     1               Flag to debounce rain guage
RAINSEC RMB     1               Save area for CURSEC to debounce rain guage
UNSIGN  RMB     1               Flag to ITOA for unsigned conversion
UNPAD   RMB     1               Flag to ITOA not to pad with spaces at the end
ITOAC   RMB     5               Byte to ASCII converted string
WINDIRC RMB     6               Wind direction ASCII characters
BPRESSC RMB     6               Pressure ASCII characters
*
DSPOMAX EQU     12              Maximum number of display values
DSPOINT RMB     1               Display Point for LCD
*
*
* The DSPxxx are the display values used by the SHOWTIM routine
*
DSPTIM  EQU     *               Display time values
DSPYR   RMB     1               Display Year 0 = year 2000
DSPHR   RMB     1               Display Hour (0-23)
DSPMON  RMB     1               Display Month (1-12)
DSPMIN  RMB     1               Display Minute (0-59)
DSPDAY  RMB     1               Display Day (1-31)
DSPSEC  RMB     1               Display Second (0-59) seconds we count down!
*
WKDAY   RMB     1               Working Day (1-day of month)
WKMON   RMB     1               Working Month (1-12)
WKYR    RMB     1               Working Year (93-...)
WKLEAP  RMB     1               Working Leap indicator (1-4) 4=leap
WKWDAY  RMB     1               Working Week Day (1=Sunday, 2=Monday...)
DSDATA  RMB     10              Data area for DS1820 communication
*
* This section defines the number and location of the area to store
* the data from the DS1820 temperature sensors and other weather data
*
SNBYTES EQU     13              Number of sensor bytes of data
TMPSENS EQU     8               Number of temperature sensors (1-8)
BPRSENS EQU     8               Pressure sensor offset number (0 index)
DIRSENS EQU     12              Wind direction sensor offset number (0 index)
HLBYTES EQU     SNBYTES-1       Number of high/low bytes of data (not WINDIR)
*
ADSCAN  EQU     *               The current temperature/sensor values
TMPDATA RMB     TMPSENS         The number of converted DS1820 values
BPRESUR RMB     1               Barometric pressure
RAINFAL RMB     1               Rain fall count
RELIGHT RMB     1               Relative Light 
WINDSPD RMB     1               Wind speed
WINDDIR RMB     1               Wind direction
ADSCANX EQU     *               End current temperature/sensor values
*
* Here we store the High and Lows for each of the sensors, except wind dir
* We keep the VALUE, CURMON, CURDAY, CURHR for each sensor - four bytes.
*
HLXSTR  EQU     4               VALUE,CURMON,CURDAY,CURHR
HLHSIZE EQU     HLXSTR*HLBYTES  Size of high/low array
HIGHVAL RMB     HLXSTR*HLBYTES  High values + date/hr 12 * 4
LOWSVAL RMB     HLXSTR*HLBYTES  Low value + date/hr 12 * 4
*
SOMEPAD RMB     10              A bit of padding
*
*
**************************************************************************
*
* This is the history data block which takes the remaining area of RAM
*
HISTOP  EQU     *               History begins here
ENDRAM  EQU     $E000           End of the History data
HISIZE  EQU     ENDRAM-HISTOP   Take what we can
*
**************************************************************************
*
NUMRAM  EQU     ENDRAM-STRRAM   Number of RAM location used for clear routine
*
* <end of CSS>
*
*
