@MIDI

loadInstrument = (instrument) ->
    MIDI.loadPlugin({
        soundfontUrl: "./midi-js-soundfonts/FluidR3_GM/",
        instrument: instrument,
        callback: (() ->
            @MIDI = MIDI
            playNote(50, 0.75)
        )
    })

playNote = (note, length) ->
    @MIDI.setVolume(127)
    @MIDI.noteOn(0, note, 127, 0)
    @MIDI.noteOff(0, note, length)

@init = () ->
    music = new Music()
    sheet = new MusicSheet(music)

    $("#add_note").on "click", -> console.log("Not implemented")
    $("#add_stave").on "click", -> console.log("Not implemented")

    loadInstrument("acoustic_grand_piano")

    console.log(Note.OCTAVES)
