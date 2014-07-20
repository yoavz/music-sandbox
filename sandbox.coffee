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

    octaves_to_MIDI = { 
        4: 60,
        5: 72,
        6: 84,
        7: 96,
    }

    L = (args...) -> console?.log("(Note)", args...) if Note.DEBUG == true 

    # should use params above 
    constructor: (@value, @octave, @duration) ->
        if octave < 4 || octave > 7 
            L "Octave not supported, ", octave

    # input: tempo beat per second
    # returns [ note, length ] corresponding to MIDI values
    toMidi: (tempo) ->
        [octaves_to_MIDI[@octave] + @value, @duration * tempo]


    toVexFlowKey: () ->
        _name = ""
        switch @value
           when Note.VALUES.C then _name = 'C'
           when Note.VALUES.D then _name = 'D'
           when Note.VALUES.E then _name = 'E'
           when Note.VALUES.F then _name = 'F'
           when Note.VALUES.G then _name = 'G'
           when Note.VALUES.A then _name = 'A'
           when Note.VALUES.B then _name = 'B'

        return "#{_name}/#{@octave}"

    toVexFlowDuration: () ->
        switch @duration
           when Note.DURATIONS.EIGHTH then '?'
           when Note.DURATIONS.QUARTER then 'q'
           when Note.DURATIONS.HALF then 'h'
           when Note.DURATIONS.WHOLE then 'w'
        
    # returns a VexFlow Note representing this note
    toVexFlow: () ->
        _key = @toVexFlowKey()
        _duration = @toVexFlowDuration()

        return new Vex.Flow.StaveNote({ keys: [_key], duration: _duration })

class Track 
    @DEBUG = true 
    L = (args...) -> console?.log("(Track)", args...) if Track.DEBUG == true 

    INTERVAL = 0.5
    beatsPerMeasure = 4
    notes = {}
    lastBeat = 0

    constructor: (@tempo) ->

    getMeasures: () ->
        Math.ceil(lastBeat/beatsPerMeasure)

    addNote: (note, beat) -> 
        if beat of notes
            notes[beat].push(note)
        else
            notes[beat] = [note]

        if beat > lastBeat
            lastBeat = beat

    getNotes: () -> notes
    getNotesAtBeat: (beat) ->
        if beat of notes
            return notes[beat]
        else
            return []

    getVexFlowVoice: (measureNum) -> 
        if measureNum > @getMeasures()
            L "Invalid measureNum requested: ", measureNum
            return false

        voice = new Vex.Flow.Voice({
            num_beats: beatsPerMeasure,
            beat_value: 4,
            resolution: Vex.Flow.RESOLUTION
        }) 

        voice.setMode Vex.Flow.Voice.Mode.SOFT

        startingBeat = measureNum * beatsPerMeasure
        endingBeat = startingBeat + beatsPerMeasure

        for i in [startingBeat..endingBeat-INTERVAL] by INTERVAL
            if i of notes
                duration_to_keys = {}
                for note in notes[i]
                    duration = note.toVexFlowDuration()
                    key = note.toVexFlowKey()
                    if duration of duration_to_keys
                        duration_to_keys[duration].push(key)
                    else
                        duration_to_keys[duration] = [key]
                
                for duration of duration_to_keys
                    keys = duration_to_keys[duration]
                    L keys, duration
                    voice.addTickable(new Vex.Flow.StaveNote({ keys: keys, duration: duration}))
            else
                continue

        return voice

class TrackPlayer
    @DEBUG = true 
    @LOADED = false
    L = (args...) -> console?.log("(TrackPlayer)", args...) if TrackPlayer.DEBUG == true 

    constructor: (instrument, @tempo, @volume) ->
        @pointer = 0 
        @interval = 0.5 

        MIDI.loadPlugin({
            soundfontUrl: "./midi-js-soundfonts/FluidR3_GM/",
            instrument: instrument,
            callback: () => TrackPlayer.LOADED = true
        })

    setTempo: (tempo) -> @tempo = tempo
    getTempo: () -> @tempo

    setVolume: (volume) -> @volume = volume 
    getVolume: () -> @volume

    reset: () ->
        @pointer = 0

    playNote: (note) ->
        [midi_note, midi_length] = note.toMidi(@tempo)
        MIDI.noteOn(0, midi_note, @volume, 0)
        MIDI.noteOff(0, midi_note, midi_length)

    attachTrack: (track) ->
        @track = track
        @reset()


    playNext: () ->
        if (TrackPlayer.LOADED)
            notes = @track.getNotesAtBeat(@pointer)
            for note in notes
                @playNote(note)
            @pointer += @interval 

        else
            L "Instrument not yet loaded"
    
    play: () ->
        L "playing..."
        setInterval(@playNext.bind(@), @interval*(1000.0/@tempo))

class MusicSheet
    @DEBUG = true
    L = (args...) -> console?.log("(MusicSheet)", args...) if MusicSheet.DEBUG == true 

    # static methods
    getCanvas = () -> $("#sheet")[0]
    getContext = () -> new Vex.Flow.Renderer(getCanvas(), Vex.Flow.Renderer.Backends.CANVAS).getContext()
    getCanvasWidth = () -> getCanvas().getAttribute('width')
    getStaveHeight = () -> 100

    getStaveWidth: () -> Math.floor (getCanvasWidth()-5)/@width

    # public methods
    constructor: (@track, @width) ->
        @formatter = new Vex.Flow.Formatter()
        @ctx = getContext()

    draw: () ->
        numMeasures = @track.getMeasures()
        
        for i in [0..numMeasures-1]
            L "measure num: ", i

            # create a stave
            rowNum = Math.floor(i/@width)
            colNum = i % @width
            x = colNum*@getStaveWidth()
            y = rowNum*getStaveHeight()

            stave = new Vex.Flow.Stave(x, y, @getStaveWidth())
            stave.setContext(@ctx)
            if colNum == 0
                stave.addClef('treble')
            stave.draw()

            voice = @track.getVexFlowVoice(i)

            L voice

            @formatter.joinVoices([voice]).format([voice], @getStaveWidth())
            voice.draw(@ctx, stave)


# export the classes
if typeof module != "undefined" && module.window
    #On a server
    exports.MusicSheet = MusicSheet
    exports.Track = Track 
    exports.TrackPlayer = TrackPlayer
    exports.Note = Note
else
    #On a client
    window.MusicSheet = MusicSheet
    window.Track = Track 
    window.TrackPlayer = TrackPlayer
    window.Note = Note

