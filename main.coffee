
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
    player = new TrackPlayer("acoustic_grand_piano", 1.3, 127)
    sheet = new MusicSheet(track, 3)

    $("#add_note").on "click", -> console.log("Not implemented")
    $("#add_stave").on "click", -> console.log("Not implemented")

    track.addNote(new Note(Note.VALUES.C, 4, Note.DURATIONS.QUARTER), 0)
    track.addNote(new Note(Note.VALUES.E, 4, Note.DURATIONS.QUARTER), 1)
    track.addNote(new Note(Note.VALUES.G, 4, Note.DURATIONS.QUARTER), 2)
    track.addNote(new Note(Note.VALUES.C, 5, Note.DURATIONS.QUARTER), 3)
    track.addNote(new Note(Note.VALUES.C, 4, Note.DURATIONS.HALF), 4)
    track.addNote(new Note(Note.VALUES.C, 4, Note.DURATIONS.HALF), 6)
    track.addNote(new Note(Note.VALUES.E, 4, Note.DURATIONS.HALF), 6)
    track.addNote(new Note(Note.VALUES.G, 4, Note.DURATIONS.HALF), 6)

    player.attachTrack(track)
    player.play()

    sheet.draw()
