// synths
(
SynthDef(\input, {|instruments = #[0,1], harmBus = 0, delFiltBus = 0, instOutBus = #[0,0], clGain = 0.2, flGain = 0.2, fxGain = 0.2|
  var cl, fl, mix;
  #cl, fl = In.ar(instruments, 1); // clarinet is first, flute is second
  // cl = In.ar((0..8), 1);
  // poll(cl, 1);
  mix = Mix.new([cl,fl]) * 0.5; // mix the signals together

  Out.ar([harmBus, delFiltBus], mix*fxGain.lag2); // mix out into effects
  Out.ar(instOutBus[1], cl*clGain.lag2); // clarinet goes directly out FL
  Out.ar(instOutBus[0], fl*flGain.lag2); // flute goes directly out FR
}).load(s);

SynthDef(\harmonizer, {|inBus = 0, outBus = 0, harmGain = 0.2, shift = #[0.5612311616, 0.7071065624]|
  var sig, clar, flute, m7down, ttdown, vib1, vib2;

  sig = Mix.new(In.ar(inBus, 1)); // mono input

  vib1 = SinOsc.kr(Rand(10.0,12.0).reciprocal).range(0.940537, 1.059463); // about a m2??? <----- maybe vibrato with a delay line???
  m7down = PitchShift.ar(sig, windowSize: 0.2, pitchRatio: shift[0]*vib1, timeDispersion: 0.01); 

  vib2 = SinOsc.kr(Rand(5.0,6.0).reciprocal).range(0.940537, 1.059463); // about a m2??? <----- speed of vibrato is fixed??
  ttdown = PitchShift.ar(sig, windowSize: 0.2, pitchRatio: shift[1]*vib2, timeDispersion: 0.01); 

  sig = Mix.new([m7down, ttdown]) * 0.5; // mix the signals down to mono
  sig = sig*harmGain.lag2; // multiply
  Out.ar(outBus, sig);
}).load(s);

SynthDef(\delayFilter, {|inBus = 0, outBus = 0, delGain = 0.2, filtGain = 0.2, delBuffs = #[0,0]|
  var sig, del, filts, filtSig, notchFreq;

  filts = [[40,300], [675, 1012], [2278, 3417]]; // cutoffs for the three filters
  sig = In.ar(inBus, 1); // mixed sig comes in from \input
  // notchFreq = MouseX.kr(50, 130);
  // poll(notchFreq, 1);
  // sig = BRF.ar(sig, 138.59131548844, 0.036077296635641); // 5hz bandwidth
  // sig = BBandStop.ar(BBandStop.ar(BBandStop.ar(sig, notchFreq, 0.041666666666667), notchFreq, 0.041666666666667), notchFreq, 0.041666666666667); // 1/4 step bandwidth...?
  sig = BufDelayN.ar(delBuffs[0], sig, delaytime: 12); // initial 12s delay
  del = BufDelayN.ar(delBuffs[1], sig, delaytime: 12, mul: delGain.lag2);// 12s delay again

  /// delay into filters
  filtSig = Mix.new([
    BHiShelf.ar(BLowShelf.ar(sig, freq: filts[0][0], db: -60), freq: filts[0][1], db: -60, mul: 6),
    BHiShelf.ar(BLowShelf.ar(sig, freq: filts[1][0], db: -60), freq: filts[1][1], db: -60, mul: 6),
    BHiShelf.ar(BLowShelf.ar(sig, freq: filts[2][0], db: -60), freq: filts[2][1], db: -60, mul: 6),
  ]);
  filtSig = CompanderD.ar(filtSig, thresh: 0.3, slopeAbove: 0.5, mul: 1) * filtGain.lag2;

  sig = Mix.new([del, filtSig]); // new mixed signal (mono)
  // sig = BLowShelf.ar(sig, freq: 60, db: -60, mul: 2);
  Out.ar(outBus, sig);
}).load(s);

SynthDef(\reverb, {|inBus = 0, outBus = #[0,0,0,0], revBuff, revBuffSize, gain = 1, lpCutoff = 15000|
  var sig, wetSig;
  sig = In.ar(inBus, 1); // signal in (mix of harmonizer, delay, and filters)

  wetSig = LPF.ar(PartConv.ar(sig, revBuffSize, revBuff), lpCutoff, gain.lag2); // apply reverb, low pass, apply gain
  wetSig = HPF.ar(wetSig, 60); // adjust
  wetSig = wetSig.dup(4); // make four copies (one for each speaker)

  Out.ar(outBus[0], wetSig[0]); // send it out
  Out.ar(outBus[1], wetSig[1]); // send it out
  Out.ar(outBus[2], wetSig[2]); // send it out
  Out.ar(outBus[3], wetSig[3]); // send it out
}).load(s);

SynthDef(\output, {|outBus, gainFL = 0.2, gainFR = 0.2, gainBL = 0.2, gainBR = 0.2|
  var sig;
  sig = In.ar(outBus, 4);
  // sig = HPF.ar(sig, 60);
  sig = BLowShelf.ar(sig, freq: 60, db: -30, mul: 1);
  sig = PitchShift.ar(sig, pitchRatio: 0.999, timeDispersion: 0.2);
  Out.ar(0, sig[0]*gainFL.lag2(1));
  Out.ar(1, sig[1]*gainFR.lag2(1));
  Out.ar(2, sig[2]*gainBR.lag2(1));
  Out.ar(3, sig[3]*gainBL.lag2(1));
}).load(s);

)