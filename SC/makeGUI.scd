// gui
{|envir|
  // actually build it (on the AppClock)

  var gui = envir.guiEnvir; // make life

  gui.pierreWindow = Window.new("A Pierre", Rect(300, 300, 1000, 300));
  gui.layout = VLayout.new;

  gui.makeHorzSlider = {|envir, slider|
    HLayout(
      VLayout(
        [slider.labelView.minWidth_(200), align: \left],
        HLayout(
          [slider.sliderView.maxHeight_(30), stretch: 1, /* align: \center */],
          slider.numberView.maxWidth_(40),
          slider.unitView.fixedWidth_(50)
        )
      )
    ); 
  };
  gui.makeVertSlider = {|envir, slider|
    VLayout(
      VLayout(
        [slider.labelView, align: \center, stretch: 1],
        [slider.sliderView.maxWidth_(50), stretch: 5, /* align: \center */],
        slider.numberView.fixedWidth_(50),
        slider.unitView
      )
    ); 
  };

  gui.harmGain = EZSlider(gui.pierreWindow, label: 'harmonizer gain', initAction: true,
    controlSpec: ControlSpec(0, 0.5, \lin, units: 'amp'), initVal: 0.07, layout: \horz, unitWidth: 30)
  // .setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey,Color.white, Color.yellow,nil,nil, Color.grey(0.7))
  // .font_(Font("Helvetica",12))
  .action_({arg slider;
    envir.fxGrp.set(\harmGain, slider.value); // gain of the source into the reverberator
  });

  gui.filtGain = EZSlider(gui.pierreWindow, label: 'filter gain', initAction: true,
    controlSpec: ControlSpec(0, 1, \lin, units: 'amp'), initVal: 0.5, layout: \horz, unitWidth: 30)
  .action_({arg slider;
    envir.fxGrp.set(\filtGain, slider.value); // gain of the source into the reverberator
  });

  gui.delGain = EZSlider(gui.pierreWindow, label: 'delay gain', initAction: true,
    controlSpec: ControlSpec(0, 1, \lin, units: 'amp'), initVal: 0.6, layout: \horz, unitWidth: 30)
  .action_({arg slider;
    envir.fxGrp.set(\delGain, slider.value); // gain of the source into the reverberator
  });


  gui.clGain = EZSlider(gui.pierreWindow, label: 'clarinet direct out', initAction: true,
    controlSpec: ControlSpec(0, 1, \lin, units: 'amp'), initVal: 0.15, layout: \horz, unitWidth: 30)
  .action_({arg slider;
    envir.instGrp.set(\clGain, slider.value); // gain of the source into the reverberator
  });
  gui.flGain = EZSlider(gui.pierreWindow, label: 'flute direct out', initAction: true,
    controlSpec: ControlSpec(0, 1, \lin, units: 'amp'), initVal: 0.15, layout: \horz, unitWidth: 30)
  .action_({arg slider;
    envir.instGrp.set(\flGain, slider.value); // gain of the source into the reverberator
  });

  // envir.keysValuesDo{|key, value| key.post; "\t".post; value.postln}; // print the environment


  gui.frontLeft = EZSlider(gui.pierreWindow, 45@300, label: 'FL', initAction: true,
    controlSpec: ControlSpec(0.ampdb, 1.ampdb, \db, units: 'dB'), initVal: 0.0.ampdb, layout: \vert, unitWidth: 30)
  .action_({arg slider;
    envir.revGrp.set(\gainFL, slider.value.dbamp); // gain of the source into the reverberator
  });
  gui.frontRight = EZSlider(gui.pierreWindow, 45@300, label: 'FR', initAction: true,
    controlSpec: ControlSpec(0.ampdb, 1.ampdb, \db, units: 'dB'), initVal: 0.0.ampdb, layout: \vert, unitWidth: 30)
  .action_({arg slider;
    envir.revGrp.set(\gainFR, slider.value.dbamp); // gain of the source into the reverberator
  });
  gui.backLeft = EZSlider(gui.pierreWindow, 45@300, label: 'BL', initAction: true,
    controlSpec: ControlSpec(0.ampdb, 1.ampdb, \db, units: 'dB'), initVal: 0.0.ampdb, layout: \vert, unitWidth: 30)
  .action_({arg slider;
    envir.revGrp.set(\gainBL, slider.value.dbamp); // gain of the source into the reverberator
  });
  gui.backRight = EZSlider(gui.pierreWindow, 45@300, label: 'BR', initAction: true,
    controlSpec: ControlSpec(0.ampdb, 1.ampdb, \db, units: 'dB'), initVal: 0.0.ampdb, layout: \vert, unitWidth: 30)
  .action_({arg slider;
    envir.revGrp.set(\gainBR, slider.value.dbamp); // gain of the source into the reverberator
  });

  gui.layout.add(
    HLayout(
      // one side
      VLayout(
        gui.makeHorzSlider(gui.clGain),
        gui.makeHorzSlider(gui.flGain),
        gui.makeHorzSlider(gui.harmGain),
        gui.makeHorzSlider(gui.delGain),
        gui.makeHorzSlider(gui.filtGain),
      ),
      // the other side
      HLayout(
        gui.makeVertSlider(gui.frontLeft),
        gui.makeVertSlider(gui.frontRight),
        gui.makeVertSlider(gui.backRight),
        gui.makeVertSlider(gui.backLeft),
      ),
    )
  );
  // close the window on CmdPeriod
  CmdPeriod.doOnce({gui.pierreWindow.close});

  //add layout to the window
  gui.pierreWindow
  .layout_(gui.layout)
  .front
  .setTopLeftBounds(Rect(200, 200, gui.pierreWindow.sizeHint.width + 150, gui.pierreWindow.sizeHint.height)) // auto-resize
  .onClose_({
    envir.freeables.do(_.free); // free the freeables
    Buffer.freeAll(s); // free all da buffas (just to be sure)
    s.freeAll; "server freed...\t".post; // (just to be sure)
    MIDIResponder.removeAll; // remove all MIDI responders
    OSCdef.freeAll; "OSCdefs freed...".postln; // free all OSCdefs
    CmdPeriod.removeAll; // remove the previous function
    fork {
      // s.quit; // stop server
      // 0.exit; // quit
    };
  });



}