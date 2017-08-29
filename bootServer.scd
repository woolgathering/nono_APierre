(
s.options.memSize_(32768); // larger memsize
s.options.numInputBusChannels_(2); // 2 inputs (but weird input bus numbers?)
s.options.numOutputBusChannels_(4); // 4 outputs
s.options.device_(ServerOptions.devices[4]); // set the MOTU
MIDIClient.init; // start midi
MIDIIn.connectAll; // connect midi

s.waitForBoot({
  s.meter; // give me the levels
  s.options.device.postln;
});

)
