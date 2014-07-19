class Note
    @DEBUG = true 

    Note.DURATIONS = {
        EIGHT: 0.5,
        QUARTER: 1,
        HALF: 2,
        WHOLE: 4,
    }

    Note.VALUES = { 
        C: 0,
        Cs: 1, # s: sharp
        Db: 1, # b: flat
        D: 2,
        Ds: 3,
        Eb: 3,
        E: 4,
        Es: 5,
        Fb: 4,
        F: 5,
        Fs: 6, 
        Gb: 6,
        G: 7,
        Gs: 8,
        Ab: 8,
        A: 9,
        As: 10,
        Bb: 10,
        B: 11,
        Bs: 0,
        Cb: 11,
    }

    Note.OCTAVES = { 
        4: 60,
        5: 72,
        6: 84,
        7: 96,
    }

    L = (args...) -> console?.log("(Note)", args...) if Note.DEBUG == true 

    # should use params above 
    constructor: (@value, @octave, @duration) ->

    # input: tempo beat per second
    # returns [ note, length ] corresponding to MIDI values
    toMidi: (tempo) ->
        [@octave + @value, @duration * tempo]

    # returns a VexFlow Note representing this note
    toVexFlow: () ->
        _name = ""
        switch @value
           when Note.VALUES.C then _name = 'C'
           when Note.VALUES.D then _name = 'D'
           when Note.VALUES.E then _name = 'E'
           when Note.VALUES.F then _name = 'F'
           when Note.VALUES.G then _name = 'G'
           when Note.VALUES.A then _name = 'A'
           when Note.VALUES.B then _name = 'B'
           # finish later...
        _duration = ""
        switch @duration
           when Note.DURATIONS.EIGHTH then _duration = '?'
           when Note.DURATIONS.QUARTER then _duration = 'q'
           when Note.DURATIONS.HALF then _duration = 'h'
           when Note.DURATIONS.WHOLE then _duration = 'w'

        return new Vex.Flow.StaveNote({ keys: [_name], duration: _duration })

class Music
    @DEBUG = true 
    L = (args...) -> console?.log("(Music)", args...) if Music.DEBUG == true 

    constructor: () ->
        #L "built object"

class MusicSheet
    @DEBUG = true
    L = (args...) -> console?.log("(MusicSheet)", args...) if MusicSheet.DEBUG == true 

    # private members
    #noteValues = Vex.Flow.Music.noteValues

    # private methods
    getCanvas = -> $("#sheet")[0]
    getContext = ->
        new Vex.Flow.Renderer(getCanvas(), Vex.Flow.Renderer.Backends.CANVAS).getContext()
    getCanvasWidth = -> getCanvas().getAttribute('width')

    generateRandomNot = ->
        all_notes = Vex.Flow.keyProperties.note_values

    # public methods
    constructor: (@music) ->

    draw: () ->
        L "Not Implemented Yet, ya bish!"

# export the classes
if typeof module != "undefined" && module.window
    #On a server
    exports.MusicSheet = MusicSheet
    exports.Music = Music
    exports.Note = Note
else
    #On a client
    window.MusicSheet = MusicSheet
    window.Music = Music
    window.Note = Note

