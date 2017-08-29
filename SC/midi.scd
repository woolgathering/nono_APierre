{|metaEnvir|

  var gui = metaEnvir.guiEnvir, midi = metaEnvir.midi;

  // front left
  MIDIFunc.cc(
    {|...args|
      var val;
      midi.faders[0] = args[0]; // get the midi value
      val = args[0].linlin(0,127,0,1).ampdb; // scale for dB
      {gui.frontLeft.valueAction = val}.defer; // set the midiData
      // args.postln;
    },
    81 // midi CC number
  );

  // front right
  MIDIFunc.cc(
    {|...args|
      var val;
      midi.faders[0] = args[0]; // get the midi value
      val = args[0].linlin(0,127,0,1).ampdb; // scale for dB
      {gui.frontRight.valueAction = val}.defer; // set the midiData
      // args.postln;
    },
    82 // midi CC number
  );

  // back right
  MIDIFunc.cc(
    {|...args|
      var val;
      midi.faders[0] = args[0]; // get the midi value
      val = args[0].linlin(0,127,0,1).ampdb; // scale for dB
      {gui.backRight.valueAction = val}.defer; // set the midiData
      // args.postln;
    },
    83 // midi CC number
  );

  // back left
  MIDIFunc.cc(
    {|...args|
      var val;
      midi.faders[0] = args[0]; // get the midi value
      val = args[0].linlin(0,127,0,1).ampdb; // scale for dB
      {gui.backLeft.valueAction = val}.defer; // set the midiData
      // args.postln;
    },
    84 // midi CC number
  );


  // clear buffers (left most button in bottom row)
  MIDIFunc.cc(
    {|...args|
      if(args[0]==0)
        { // if the light is off, stop everything

          // mute inputs
          metaEnvir.instGrp.set(\clGain, 0);
          metaEnvir.instGrp.set(\flGain, 0);
          metaEnvir.instGrp.set(\fxGain, 0);

          // set the outputs to 0
          [81,82,83,84].do{|val|
            midi.out.control(0, val, 0);
          };
          defer {
            gui.frontLeft.valueAction_(0.ampdb);
            gui.frontRight.valueAction_(0.ampdb);
            gui.backLeft.valueAction_(0.ampdb);
            gui.backRight.valueAction_(0.ampdb);
          };

          metaEnvir.del.delBuffs.do(_.zero); // clear the delBuffs
          "Buffers cleared".postln;
        } { // otherwise it's on
          // don't reset the outputs
          // reset the inputs
          defer {
            gui.clGain.doAction;
            gui.flGain.doAction;
            metaEnvir.instGrp.set(\fxGain, 1);
          };

          // still clear the buffer
          metaEnvir.del.delBuffs.do(_.zero); // clear the delBuffs
          "Buffers cleared".postln;
        }
    },
    73 // midi CC number
  );  


// zero everything out
  midi.init = {|envir|
    MIDIClient.init; // start midi
    MIDIIn.connectAll; // connect midi
    midi.out = MIDIOut.newByName("BCF2000", "Port 1"); // for sending midiout

    // set the outputs to 0
    [81,82,83,84].do{|val|
      midi.out.control(0, val, 0);
    };
    midi.out.control(0,73,0); // start off
    defer {
      gui.frontLeft.valueAction_(0.ampdb);
      gui.frontRight.valueAction_(0.ampdb);
      gui.backLeft.valueAction_(0.ampdb);
      gui.backRight.valueAction_(0.ampdb);
    };
  };


}