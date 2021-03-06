{{File: ADC0808driver.spin
Once started, continuously takes samples as fast as possible using the ADC0808,
storing the result in the data variable.  Conversion time is about 64 ADC clocks.

Circuit:

   +5V
       ADC0808           Propeller I/O Pins
    │ ┌──────────┐   1kΩ(all) 
    ┣─┤Vcc     D7├────── P0
    └─┤Vref+    .│
      │         .│
      │        D0├────── P7
      │IN0     OE├──────── P12
      │.      EOC├────── P11
      │.    START├──────── P27
      │IN7   MUXA├──────── P8
      │      MUXB├──────── P9
      │      MUXC├──────── P10
    ┌─┤Vref-  ALE├──────── P26
    ┣─┤GND    CLK├──────── P13
    │ └──────────┘
    

IMPORATANT: this program does not provide clocks to the ADC0808.
            Another program has to do it.

}}
CON
{{These constants represent pins of the ADC0808.  Their value represents the
Propeller pin to which they are connected.

}}
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x  

  OE    = 12                 ''OE is the output enable pin
  D7    = 0                  ''D7 is the most significant bit
  D0    = 7                  ''D0 is the least significant bit
  EOC   = 11                 ''EOC pin goes high when there is no conversion in progress
  START = 27                 ''START pin needs a clock pulse to know when to start converting
  AMUXA = 8                  ''AMUXA is LSB of the mux
  BMUXB = 9                  
  CMUXC = 10                 ''CMUXC MSB of the mux
  ALE   = 26                 ''ALE needs a clock to change the mux state
  CLOCK = 13                 ''CLOCK pulses input ~1MHz
  
VAR
  byte data0, data1, data2, data3, data4, data5, data6, data7
  byte cog
  long stack[32]
  
PUB startConversion : success
{{Starts new converting process on a new cog
}}
  stop
  cog := cognew(convert,@stack) + 1
  success := cog

PUB stop
{{Stops process, if any}}
  if cog
    cogstop(cog~ - 1)

PUB get(YourData0,YourData1,YourData2,YourData3,YourData4,YourData5,YourData6,YourData7)
{{expects an address pointer as input and sets the reference equal to the internal data
variable.  If called before the first conversion, or if there is no conversion process
running, the result will be invalid}}
  byte[YourData0] := data0
  byte[YourData1] := data1
  byte[YourData2] := data2
  byte[YourData3] := data3
  byte[YourData4] := data4
  byte[YourData5] := data5
  byte[YourData6] := data6
  byte[YourData7] := data7
    
PRI convert 
{{makes conversions on all inputs as fast as possible and stores 8 bit result in data}}
          
  dira[CMUXC..AMUXA]~~                      'pin I/O declarations
  dira[ALE]~~
  dira[START]~~                             
  dira[OE]~~                                
  dira[EOC]~                                
  outa[OE]~~                                'Data pins not used for anything else so OE can stay high

  'I am using counters here to send short pulses because I don't know how to do it in assembly
  ctra[30..26] := %00100                    'Configure Counter A to PWM
  ctra[8..0] := START
  frqa := 1

  ctrb[30..26] := %00100                    'Configure Counter B to PWM
  ctrb[8..0] := ALE
  frqb := 1
  
  repeat                                    'infinite loop
                                            
    outa[CMUXC..AMUXA] := 0               'set input to 0
    phsb := $FFFFFFB0                     'ALE go high for 1us
    phsa := $FFFFFFB0                     'START go high for 1us
    repeat until ina[EOC]                 'wait for EOC to go high
    data0 := ina[D7..D0]                  'read data
     
    outa[CMUXC..AMUXA] := 1               'repeat above for input 1
    phsb := $FFFFFFB0
    phsa := $FFFFFFB0                     
    repeat until ina[EOC]                
    data1 := ina[D7..D0]
     
    outa[CMUXC..AMUXA] := 2               'repeat above for input 2
    phsb := $FFFFFFB0
    phsa := $FFFFFFB0                     
    repeat until ina[EOC]                 
    data2 := ina[D7..D0]
     
    outa[CMUXC..AMUXA] := 3               'repeat above for input 3
    phsb := $FFFFFFB0
    phsa := $FFFFFFB0                     
    repeat until ina[EOC]                 
    data3 := ina[D7..D0]
     
    outa[CMUXC..AMUXA] := 4               'repeat above for input 4
    phsb := $FFFFFFB0
    phsa := $FFFFFFB0                     
    repeat until ina[EOC]                 
    data4 := ina[D7..D0]
     
    outa[CMUXC..AMUXA] := 5               'repeat above for input 5
    phsb := $FFFFFFB0
    phsa := $FFFFFFB0                     
    repeat until ina[EOC]                 
    data5 := ina[D7..D0]
     
    outa[CMUXC..AMUXA] := 6               'repeat above for input 6
    phsb := $FFFFFFB0
    phsa := $FFFFFFB0                     
    repeat until ina[EOC]                 
    data6 := ina[D7..D0]
     
    outa[CMUXC..AMUXA] := 7               'repeat above for input 7
    phsb := $FFFFFFB0
    phsa := $FFFFFFB0                     
    repeat until ina[EOC]                 
    data7 := ina[D7..D0]
      
     