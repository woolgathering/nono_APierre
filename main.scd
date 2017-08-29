(
var metaEnvir = (), // an empty environment
midi = (), // an empty environment
del = (), // an empty environment
rev = (), // an empty environment
gui = (); // an empty environment

//////// meta environment ////////
// groups
metaEnvir.instGrp = Group.new();
metaEnvir.fxGrp = Group.new(metaEnvir.instGrp, \addAfter);
metaEnvir.revGrp = Group.new(metaEnvir.fxGrp, \addAfter);
// busses
metaEnvir.harmBus = Bus.audio(s, 1);
metaEnvir.delFiltBus = Bus.audio(s, 1);
metaEnvir.revBus = Bus.audio(s, 1);
metaEnvir.outBus = Array.fill(4, {Bus.audio(s,1)}); // fill an array with four busses for output
metaEnvir.thisDir = "path/to/this/file".standardizePath; // set the directory
metaEnvir.freeables = List.with( // a list for freeable objects
  metaEnvir.harmBus, metaEnvir.delFiltBus, metaEnvir.revBus, metaEnvir.outBus // busses
);
// add all the other environments
metaEnvir.midi = midi;
metaEnvir.del = del;
metaEnvir.rev = rev;
metaEnvir.guiEnvir = gui;

// use something here to load an array of all midi faders and knobs: midi.faders[] and midi.knobs[] and midi.button[].
midi.faders = Array.fill(8,{0});
midi.knobs = Array.fill(8,{0});
midi.buttons = Array.fill(2,{Array.fill(8,{0})}); // a 2D array

//////// reverb environment ////////
rev.fftSize = 2048; // size of our partition
// path to the impulse response
rev.irPath = "path/to/your/impulse/response".standardizePath;

//////// delay environment ////////
del.delBuffs = 2.collect({Buffer.alloc(s, s.sampleRate*12.1)}); // allocate buffers for the delay
metaEnvir.freeables.addAll(del.delBuffs); // add the buffers to freeables

// do preparatory stuff
metaEnvir.makeGuiFunc = thisProcess.interpreter.compileFile(metaEnvir.thisDir++"/SC/makeGUI.scd"); // make the GUI function (but don't make it yet)
thisProcess.interpreter.executeFile(metaEnvir.thisDir++"/SC/midi.scd").value(metaEnvir); // make the MIDI function
thisProcess.interpreter.executeFile(metaEnvir.thisDir++"/SC/synths.scd"); // get the synths

//// functions ///////
// prepare reverb
rev.prepareRev = {
    rev.revBuff = Buffer.read(s, rev.irPath); // read the impulse response
    s.sync;  // wait...
    rev.revBuffSize = PartConv.calcBufSize(rev.fftSize, rev.revBuff); // calcuate buffer size
    rev.revSpec = Buffer.alloc(s, rev.revBuffSize, 1); // allocate the buffer
    rev.revSpec = rev.revSpec.preparePartConv(rev.revBuff, rev.fftSize); // prepare the buffer
    s.sync; // wait...
    rev.revBuff.free; // free our soundfile
};

Routine.run({
  s.options.memSize_(32768); // larger memsize
  s.options.numInputBusChannels_(2); // 2 inputs
  s.options.numOutputBusChannels_(4); // 4 outputs
  // s.options.device_(ServerOptions.devices[4]); // set the MOTU
  MIDIClient.init; // start midi
  MIDIIn.connectAll; // connect midi

  s.waitForBoot({
    metaEnvir.firstInput = s.options.numInputBusChannels; // doesn't work correctly?
    rev.prepareRev; // prepare the reverb
    s.sync;

    {metaEnvir.use(metaEnvir.makeGuiFunc)}.defer; // make the gui
    s.sync;
    midi.init; // set the outputs to 0

    // make the synths and start
    s.makeBundle(nil, {
      Synth(\input,
        [instruments: [metaEnvir.firstInput, metaEnvir.firstInput+1],
        instOutBus: [metaEnvir.outBus[0], metaEnvir.outBus[1]],
        harmBus: metaEnvir.harmBus, delFiltBus: metaEnvir.delFiltBus, clGain: -3.dbamp, flGain: -3.dbamp],
        target: metaEnvir.instGrp, addAction: \addToHead
      );

      Synth(\harmonizer,
        [inBus: metaEnvir.harmBus, outBus: metaEnvir.revBus, harmGain: 0.07],
        target: metaEnvir.fxGrp, addAction: \addToHead
      );
      Synth(\delayFilter,
        [inBus: metaEnvir.delFiltBus, outBus: metaEnvir.revBus, delBuffs: del.delBuffs, delGain: 0.5, filtGain: 0.6],
        target: metaEnvir.fxGrp, addAction: \addToTail
      );
      Synth(\reverb,
        [inBus: metaEnvir.revBus, outBus: metaEnvir.outBus, revBuff: rev.revSpec, revBuffSize: rev.fftSize, gain: 1],
        target: metaEnvir.revGrp,
      );
      Synth(\output,
        [outBus: metaEnvir.outBus],
        target: metaEnvir.revGrp, addAction: \addToTail
      );
    });

    // end waitForBoot
  });
});

)
