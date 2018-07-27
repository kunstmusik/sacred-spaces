/* Title: Tape Loops
Author: Steven Yi
Date: 2018.07.16

Description: Ambient music generated in the tape loop style of Brian Eno
*/

// sr not set here so that Web version uses default sr of WebAudio
/*sr	=	48000*/ 
ksmps	= 64	
nchnls	=	2
0dbfs	=	1

/* UDOs from csound-live-code's livecode.orc */

opcode declick, a, a
  ain xin
  aenv = linseg:a(0, 0.01, 1, p3 - 0.02, 1, 0.01, 0, 0.01, 0)
  xout ain * aenv
endop

gi_scale_minor[] = array(0, 2, 3, 5, 7, 8, 10)

gi_cur_scale[] = gi_scale_minor
gi_scale_base = 60

opcode in_scale, i, ii
  ioct, idegree xin

  ibase = gi_scale_base + (ioct * 12)

  idegrees = lenarray(gi_cur_scale)

  ioct = int(idegree / idegrees)
  indx = idegree % idegrees

  if(indx < 0) then
    ioct -= 1
    indx += idegrees
  endif

  xout cpsmidinn(ibase + (ioct * 12) + gi_cur_scale[indx]) 
endop

/* end livecode.orc code */

;; noise/vco synth instrument
instr Syn1
  asig = pinker() * 0.2
  asig = zdf_2pole(asig, p4, 24.8, 2)
  asig += zdf_ladder(vco2(0.5, p4), 2000, 2)

  asig *= p5 * oscili(1, 0.5 / p3) * 0.5
  asig = declick(asig)
  al, ar pan2 asig, p6

;   outc(al, ar)
  chnmix(al, "left")
  chnmix(ar, "right")
endin

;; always-on mixer instrument for reverb processing
instr Mix
  al = chnget:a("left")
  ar = chnget:a("right")

  alr, arr reverbsc al, ar, 0.9, 3000
  
  outc(ntrpol(al, alr, 0.4), ntrpol(ar, arr, 0.4))
  
  chnclear("left")
  chnclear("right")

endin
schedule("Mix", 0, -1)

;; tape loops...
instr Run
  schedule("Syn1", 0, p5, in_scale(0,p4), ampdbfs(-12), p6)
  schedule(p1, p3, p3, p4, p5, p6)
endin


instr Main
  ;; starting 8 loops...
  indx = 0
  while (indx < 8) do
    idur = random(12, 21)
    ilen = random(4, idur / 2)
    istart = random(0, idur)
    ipan = random(0.25, 0.75)
    schedule("Run", istart, idur, indx * 2, ilen, ipan)
    
    indx += 1
  od
endin


;; START
seed(0)
schedule("Main", 0, 1)

