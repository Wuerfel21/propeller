''**************************************
''
''  Prop Blade and LED Painter Demo DMX Ver. 01.0
''
''  Timothy D. Swieter, E.I.
''  www.brilldea.com
''
''  Copyright (c) 2008 Timothy D. Swieter, E.I.
''  See end of file for terms of use.
''
''  Updated: September 7, 2008
''
''Description:
''      This program is a demo of the Prop Blade controlling an LED Painter using DMX-512A.
''      The DIP Switches need to be set to a non-zero address.  The LEDs will follow
''      the DMX data passed to the board.  CH-0 red on the LED Painter will be the first
''      address followed by the CH-0 green and CH-0 blue and so on.
''
''      This program runs in a Propeller powered Prop Blade by Brilldea.
''      The LEDs are controlled via an LED Painter by Brilldea.
''
''      Note the LED Painter should be connected to Group 2 Header. If you want to
''      use the Group 1 header, certain code needs to updated or comments removed.
''
''Reference:
''      Prop Blade Datasheet and Schematic
''      LED Painter Datasheet and schematic
''
''To do:
''
''Revision Notes:
'' 0.1 Begin coding
'' 1.0 Clean up of documentation, publishing code
''
''**************************************
CON               'Constants to be located here
'***************************************                       

  '***************************************
  ' Processor Settings
  '***************************************
  _clkmode = xtal1 + pll16x     'Use the PLL to multiple the external clock by 16
  _xinfreq = 5_000_000          'An external clock of 5MHz. is used (80MHz. operation)

  '***************************************
  ' System Definitions     
  '***************************************

  _OUTPUT       = 1             'Sets pin to output in DIRA register
  _INPUT        = 0             'Sets pin to input in DIRA register  
  _HIGH         = 1             'High=ON=1=3.3v DC
  _ON           = 1
  _LOW          = 0             'Low=OFF=0=0v DC
  _OFF          = 0
  _ENABLE       = 1             'Enable (turn on) function/mode
  _DISABLE      = 0             'Disable (turn off) function/mode

  '***************************************
  ' I/O Definitions of Prop Blade
  '***************************************

  'DMX-512A Interface
  _DMX_RX       = 2             'Data received from the DMX stream
  _DMX_TX       = 1             'Data to transmit out to a DMX stream
  _DMX_ENA      = 0             'Enable for transmission (disable reception)
  _DMX_LED      = 19            'Status LED
  _DMX_LED_Ena  = _ON           'Enable or disable the use of the DMX LED

  'User Interface (switches)
  _BANK0        = 16            'Enables the 1-5 of the DIP Swith when output, otherwise input
  _BANK1        = 17            'Enables the 6-10 of the DIP Swith when output, otherwise input
  _BANK2        = 18            'Enables the 1-5 of the Tactile Swithes when output, otherwise input
  _SW1          = 11            'Switch input based on which bank is output
  _SW2          = 12            'Switch input based on which bank is output
  _SW3          = 13            'Switch input based on which bank is output
  _SW4          = 14            'Switch input based on which bank is output
  _SW5          = 15            'Switch input based on which bank is output

  'Group 1 (unused)
  _G1_XLAT      = 3             'Latch of the TLC5940
  _G1_SCLK      = 4             'Serial data clock of the TLC5940
  _G1_SIN       = 5             'Serial data out to the TLC5940
  _G1_SRTN      = 6             'Serial data in from the TLC5940
  _G1_GSCLK     = 7             'Gray scale clock of the TLC5940
  _G1_BLNK      = 8             'Blank input to the TLC5940
  _G1_DCPROG    = 9             'DC Programming input to the TLC5940
  _G1_VPRG      = 10            'Voltage Programming input to the TLC5940

  'Group 2 (used - 1 LED Painter)
  _G2_XLAT      = 26            'Latch of the TLC5940
  _G2_SCLK      = 27            'Serial data clock of the TLC5940
  _G2_SIN       = 24            'Serial data out to the TLC5940
  _G2_SRTN      = 25            'Serial data in from the TLC5940
  _G2_GSCLK     = 23            'Gray scale clock of the TLC5940
  _G2_BLNK      = 22            'Blank input to the TLC5940
  _G2_DCPROG    = 21            'DC Programming input to the TLC5940
  _G2_VPRG      = 20            'Voltage Programming input to the TLC5940

  '***************************************
  ' Channel Definitions
  '***************************************
  
  _LEDPainterChannelCount       = 16                                            'Hardware definitions of the number of RGB channels

  _G1_LEDPainters               = 0                                             'How many PCBs in series on Group 1?
  _G2_LEDPainters               = 1                                             'How many PCBs in series on Group 2?
  
  _G1_LEDPainterTotalChannels   = _G1_LEDPainters * _LEDPainterChannelCount     'Number of channels consumed by Group 1
  _G2_LEDPainterTotalChannels   = _G2_LEDPainters * _LEDPainterChannelCount     'Number of channels consumed by Group 2

  _G1_LEDPainterMaxChannels     = _G1_LEDPainterTotalChannels - 1               'Zero based for counter routines
  _G2_LEDPainterMaxChannels     = _G2_LEDPainterTotalChannels - 1               'Zero based for counter routines

  _G1_ChannelsMin               = 0                                             'Starting channel number for the channels on Group 1
  _G1_ChannelsMax               = _G1_LEDPainterMaxChannels                     'Ending channel number for the channels on Group1

  _G2_ChannelsMin               = 0                                             'Starting channel number for the channels on Group 2
  _G2_ChannelsMax               = _G2_LEDPainterMaxChannels                     'Ending channel number for the channels on Group2

  _SystemTotalChannels          = _G1_LEDPainterTotalChannels + _G2_LEDPainterTotalChannels
  _SystemMaxChannels            = _SystemTotalChannels - 1                      'Zero based for counter routines
  _SysetmMaxIntensity           = 255                                           'Max intensity of the LEDs in the system (8-bit)

  _OffScreenArray               = _SystemTotalChannels * 3                      'The number of channels to make the offscreen array

  '***************************************
  ' Misc Definitions
  '***************************************

  'none
  
'**************************************
VAR               'Variables to be located here
'***************************************

  'Display buffer for LED Painters
  byte  chvalues[_OffScreenArray]

  'DMX-512A variables
  long  DMXAddress                                                              'Start slot to read from the DMX stream                                                     
  

'***************************************
OBJ               'Object declaration to be located here
'***************************************

  'G1_LEDWindow : "Brilldea-TLC5940-Driver-Ver006.spin"                         'Brilldea's TLC5940 Driver for the the LED Painters on Group 1
  G2_LEDWindow   : "Brilldea-TLC5940-Driver-Ver006.spin"                        'Brilldea's TLC5940 Driver for the the LED Painters on Group 2
  DMX           : "DMX-Rx-Driver-Ver014.spin"                                   'Brilldea's DMX-512A receive driver
  Switches      : "Brilldea-Prop Blade-Switches-Driver-Ver011.spin"             'Brilldea's driver for the Prop Blade switches
  

'***************************************
PUB main | t0     'The first PUB in the file is the first one executed
'***************************************

  '**************************************
  ' Initialize the hardware
  '**************************************

  'none (done in the appropriate cog)  
  
  '**************************************
  ' Initialize the variables
  '**************************************
  
  'none                                                                                                

  '**************************************
  ' Start the processes in their cogs
  '**************************************

  'Start the switches driver, requires 1 COG
  Switches.start(_BANK0, _BANK1, _BANK2, _SW1, _SW2, _SW3,_SW4, _SW5)

  'Start the DMX-512A receive driver, requires 1 COG
  DMX.start(_DMX_RX, _DMX_LED)  

  'Start the TLC5940 Driver(s) per the definitions of what is used for the groups, requires 2 COGs each
  'G1_LEDWindow.StartTLC5940(_G1_SCLK, _G1_SIN, _G1_XLAT, _G1_GSCLK, _G1_BLNK, _G1_VPRG, _G1_DCPROG)
  G2_LEDWindow.StartTLC5940(_G2_SCLK, _G2_SIN, _G2_XLAT, _G2_GSCLK, _G2_BLNK, _G2_VPRG, _G2_DCPROG)

  '**************************************
  ' Begin
  '**************************************

  'Test for the DMX DIP Switch Address to be not too high and set the address
  'the address must be non-zero as well
  if (Switches.GetDMXAddress =< (513 - _OffScreenArray))
    DMXAddress := Switches.GetDMXAddress
  else
    DMXAddress := 0

  'infinite loop
  'One DMX channel per color per pixel
  repeat

    'Check the address, if it is good, then update
    if DMXAddress <> 0
    
      'Check that the data in the buffer is "dimmer" data and not RDM or other
      if DMX.level(0) == 0

        'Gather the data from DMX buffer and place it in the LED Painter buffer
        repeat t0 from 0 to (_OffScreenArray - 1)
            chvalues[t0] := DMX.level(DMXAddress + t0)

        'Update the LED Painter     
        WindowUpdate                                                  


'***************************************
PRI WindowUpdate | t0
'***************************************
'' Map the buffer to the actual window channels

  'Update group 1
  'repeat t0 from _G1_ChannelsMin to _G1_ChannelsMax
  ' G1_LEDWindow.SetChValue((t0 - _G1_ChannelsMin), chvalues[(3*t0)+ 0], chvalues[(3*t0)+ 1], chvalues[(3*t0)+ 2])

  'Update group 2
  repeat t0 from _G2_ChannelsMin to _G2_ChannelsMax
   G2_LEDWindow.SetChValue((t0 - _G2_ChannelsMin), chvalues[(3*t0)+ 0], chvalues[(3*t0)+ 1], chvalues[(3*t0)+ 2])

  'Must be called to update the window
  'G1_LEDWindow.UpdateScreen                                                      
  G2_LEDWindow.UpdateScreen
                                            

''**************************************
PRI WindowClear | t0
'***************************************
'' Clear the window buffer (all LEDs off)

  'Update the off screen buffer with all zeros
  repeat t0 from 0 to _OffScreenArray
    chvalues[t0] := 0

  WindowUpdate


'***************************************
PRI pauseMSec(Duration)
'***************************************
'' Pause execution in milliseconds.
'' Duration = number of milliseconds to delay
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

  
'***************************************
DAT
'***************************************
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}