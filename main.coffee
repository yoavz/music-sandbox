
loadInstrument = (instrument) ->
    MIDI.loadPlugin({
        soundfontUrl: "./midi-js-soundfonts/FluidR3_GM/",
        instrument: instrument,
        callback: playNote,
    })

playNote = () ->
    MIDI.setVolume(127)
    MIDI.noteOn(0, 60, 127, 0)
    MIDI.noteOff(0, 60, 0.75)

jQuery -> 
    track = new Track()
    sheet = new MusicSheet(track)
    
    track.addNote(new Note('c', 4, 4), 0)
    track.addNote(new Note('c', 4, 4), 1)
    track.addNote(new Note('g', 4, 4), 2)
    track.addNote(new Note('g', 4, 4), 3)
    track.addNote(new Note('a', 4, 4), 4)
    track.addNote(new Note('a', 4, 4), 5)
    track.addNote(new Note('g', 4, 2), 6)

    $("#play").on "click", -> sheet.play()
    $("#stop").on "click", -> sheet.stop() 

    sheet.draw()
