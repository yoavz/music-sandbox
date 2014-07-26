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

littleStar = (track, beat) ->
    a = (track, beat) -> 
        track.addNote(new Note('c', 4, 4), beat+0)
        track.addNote(new Note('c', 4, 4), beat+1)
        track.addNote(new Note('g', 4, 4), beat+2)
        track.addNote(new Note('g', 4, 4), beat+3)
        track.addNote(new Note('a', 4, 4), beat+4)
        track.addNote(new Note('a', 4, 4), beat+5)
        track.addNote(new Note('g', 4, 2), beat+6)
        track.addNote(new Note('f', 4, 4), beat+8)
        track.addNote(new Note('f', 4, 4), beat+9)
        track.addNote(new Note('e', 4, 4), beat+10)
        track.addNote(new Note('e', 4, 4), beat+11)
        track.addNote(new Note('d', 4, 4), beat+12)
        track.addNote(new Note('d', 4, 4), beat+13)
        track.addNote(new Note('c', 4, 2), beat+14)

    b = (track, beat) ->
        sub_b = (track, beat) ->
            track.addNote(new Note('g', 4, 4), beat+0)
            track.addNote(new Note('g', 4, 4), beat+1)
            track.addNote(new Note('f', 4, 4), beat+2)
            track.addNote(new Note('f', 4, 4), beat+3)
            track.addNote(new Note('e', 4, 4), beat+4)
            track.addNote(new Note('e', 4, 4), beat+5)
            track.addNote(new Note('d', 4, 2), beat+6)
        sub_b(track, beat)
        sub_b(track, beat+8)

    a(track, beat)
    b(track, beat+16)
    a(track, beat+32)
    
jQuery -> 
    track = new Track()
    sheet = new MusicSheet(track)
    
    littleStar(track, 0)

    $("#play").on "click", -> sheet.play()
    $("#stop").on "click", -> sheet.stop() 

    sheet.draw()
