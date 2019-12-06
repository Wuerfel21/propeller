{{

┌──────────────────────────────────────────┐
│ DTMF.spin                                │
│ Author: Thomas E. McInnes                │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘
prop pin 0 ─┬────┬──┐
prop pin 1 ──┘      ←speaker                          
           ┌────────┴──┘   
                 
          VSS
}}

VAR

  Long tpin1, tpin2, num
  Byte dcount

OBJ

  s     :       "Synth"

PUB start_up(pin1, pin2)

  tpin1 := pin1
  tpin2 := pin2

PUB dial(num_ptr)

  dcount := 0
  tone(1)
  waitcnt(clkfreq / 5 + cnt)
  repeat until dcount == 10
    tone(byte[num_ptr][dcount++])

PUB tech_support

  dial(@parallax_tech)

PUB tone(key)

  case key
   1:
    s.synth("A", tpin1, 1209)
    s.synth("B", tpin2, 697)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   2:
    s.synth("A", tpin1, 1336)
    s.synth("B", tpin2, 697)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   3:
    s.synth("A", tpin1, 1477)
    s.synth("B", tpin2, 697)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   4:
    s.synth("A", tpin1, 1209)
    s.synth("B", tpin2, 770)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   5:
    s.synth("A", tpin1, 1336)
    s.synth("B", tpin2, 770)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   6:
    s.synth("A", tpin1, 1477)
    s.synth("B", tpin2, 770)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   7:
    s.synth("A", tpin1, 1209)
    s.synth("B", tpin2, 852)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   8:
    s.synth("A", tpin1, 1336)
    s.synth("B", tpin2, 852)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   9:
    s.synth("A", tpin1, 1477)
    s.synth("B", tpin2, 852)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)
   0:
    s.synth("A", tpin1, 1336)
    s.synth("B", tpin2, 941)
    waitcnt(clkfreq / 3 + cnt)
    s.silence_a(tpin1)
    s.silence_b(tpin2)                     

DAT

parallax_tech  Byte      8, 8, 8, 9, 9, 7, 8, 2, 6, 7
     
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