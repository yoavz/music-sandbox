
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
    player = new TrackPlayer(track, MIDI)
    sheet = new MusicSheet(track, 3)

    $("#add_note").on "click", -> console.log("Not implemented")
    $("#add_stave").on "click", -> console.log("Not implemented")

    loadInstrument("acoustic_grand_piano")

    note = new Note(Note.VALUES.C, 4, Note.DURATIONS.HALF)
    note2 = new Note(Note.VALUES.D, 4, Note.DURATIONS.QUARTER)
    track.addNote(note, 0)
    track.addNote(note2, 2)
    track.addNote(note2, 3)

    sheet.draw()
    player.play()
