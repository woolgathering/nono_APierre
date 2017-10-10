# Electronics for Luigi Nono's A Pierre. Dell'Azzurro Silenzio, Inquietum
Electronics in SuperCollider for Luigi Nono's A Pierre. Dell'Azzurro Silenzio, Inquietum.

## Before beginning
Some slight changes must be made in order for this to function:

### Get an impulse response
The reverb uses a convolution reverb which requires an impulse response. For a great collection of free responses, see [The Echo Thief](http://www.echothief.com/).

### Modify paths
In main.scd, the following lines must be modified:

- Line 18:

  `metaEnvir.thisDir = "path/to/this/file".standardizePath; // set the directory`

  Change the path to whatever the directory is that main.scd is placed in. If you're using the SC IDE or Emacs, using `thisProcess.nowExecutingPath.dirname` should work fine.

- Line 37:

  `rev.irPath = "path/to/your/impulse/response".standardizePath;`

  Set the path to your impulse response.

### Check your MIDI device

#### Set your MIDI device
Also in main.scd:

  - Line 32:

    `midi.out = MIDIOut.newByName("yerMIDIdevice", "Port 1"); // for sending midiout`

    Set your MIDI device however you wish. Using .newByName is an easy way to ensure you connect with the correct device and port each time.

In all likelihood, you'll need to modify the MIDI CC channels for your device. This can be done in SC/midi.scd. A function is available there that clears the reverb buffers to better facilitate rehearsals.
