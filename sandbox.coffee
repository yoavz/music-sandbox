class Note
    @DEBUG = true 

    Note.DURATIONS = [16, 8, 4, 2, 1]
    Note.VALUES = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
    Note.ACCIDENTALS = ['#', 'b', '']

    notes_to_MIDI =
        C: 0,
        D: 2,
        E: 4,
        F: 5,
        G: 7,
        A: 9,
        B: 11,

    octaves_to_MIDI = 
        4: 60,
        5: 72,
        6: 84,
        7: 96,

    L = (args...) -> console?.log("(Note)", args...) if Note.DEBUG == true 

    # should use params above 
    constructor: (@value, @octave, @duration) ->
        @value = @value.toUpperCase()
        if @value.length > 2 or
           @value.length <= 0 or
           @value.charAt(0) not in Note.VALUES or
           @value.charAt(1) not in Note.ACCIDENTALS
            throw new Error("Illegal value: ", @value)
        if @octave < 4 || @octave > 7 
            throw new Error("Octave not supported, ", @octave)
        if @duration not in Note.DURATIONS
            throw new Error("Illegal duration, ", @duration)

    # assuming X/4 time signature
    length: () -> 4.0 / @duration

    # input: tempo beat per second
    # returns [ note, length ] corresponding to MIDI values
    toMidi: (tempo) ->
        midi_value = octaves_to_MIDI[@octave]
        midi_value += notes_to_MIDI[@value.charAt(0)]
        if @value.charAt(1) is '#' 
            midi_value += 1
        else if @value.charAt(1) is 'b'
            midi_value -= 1

        [midi_value, @length()]

    toVexFlowKey: () ->
        return "#{@value.charAt(0)}/#{@octave}"

    toVexFlowDuration: () ->
        return String(@duration)
        
    # returns a VexFlow Note representing this note
    toVexFlow: () ->
        _key = @toVexFlowKey()
        _duration = @toVexFlowDuration()

        return new Vex.Flow.StaveNote({ keys: [_key], duration: _duration })

class Track 
    @DEBUG = true 
    L = (args...) -> console?.log("(Track)", args...) if Track.DEBUG == true 

    beatsPerMeasure = 4
    notes = {}
    lastBeat = 0

    constructor: (@tempo) ->

    getMeasures: () ->
        Math.ceil(lastBeat/beatsPerMeasure)

    beatsPerMeasure: () ->
        beatsPerMeasure

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


class MusicSheet
    @DEBUG = true
    @INSTRUMENTS_LOADED = {}
    DRAW_INTERVAL = 0.25
    L = (args...) -> console?.log("(MusicSheet)", args...) if MusicSheet.DEBUG == true 

    # static methods
    getCanvas = () -> $("#sheet")[0]
    getContext = () -> new Vex.Flow.Renderer(getCanvas(), Vex.Flow.Renderer.Backends.CANVAS).getContext()
    getCanvasWidth = () -> getCanvas().getAttribute('width')
    getStaveHeight = () -> 100

    # DRAWING
    constructor: (@track, @width=2, @tempo=1, @volume=127, @instrument='acoustic_grand_piano') ->
        @formatter = new Vex.Flow.Formatter()
        @ctx = getContext()
        @pointer = 0 
        @interval = 0.5 
        @loadInstrument(@instrument)

    getStaveWidth: () -> Math.floor (getCanvasWidth()-5)/@width

    constructVoiceForMeasure: (measureNum) -> 
        if measureNum > @track.getMeasures()
            L "Invalid measureNum requested: ", measureNum
            return false

        voice = new Vex.Flow.Voice({
            num_beats: @track.beatsPerMeasure(),
            beat_value: 4,
            resolution: Vex.Flow.RESOLUTION
        }) 

        voice.setMode Vex.Flow.Voice.Mode.SOFT

        startingBeat = measureNum * @track.beatsPerMeasure()
        endingBeat = startingBeat + @track.beatsPerMeasure()

        for i in [startingBeat..endingBeat-DRAW_INTERVAL] by DRAW_INTERVAL
            duration_to_notes = {}
            for note in @track.getNotesAtBeat(i) 
                duration = note.toVexFlowDuration()
                if duration of duration_to_notes
                    duration_to_notes[duration].push(note)
                else
                    duration_to_notes[duration] = [note]
            
            for duration of duration_to_notes
                notes = duration_to_notes[duration]
                keys = notes.map (note) -> note.toVexFlowKey()
                note = new Vex.Flow.StaveNote({ keys: keys, duration: duration})

                # color the note head if it is currently being played
                to_color = []
                for j in [0..notes.length-1] by 1 
                    if i <= @pointer < i+notes[j].length()
                        to_color.push(j)
                for index in to_color
                    note.setKeyStyle(index, {fillStyle: '#FF0000'})

                voice.addTickable(note)

        return voice

    draw: () ->
        numMeasures = @track.getMeasures()
        
        for i in [0..numMeasures-1]
            
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

            voice = @constructVoiceForMeasure(i)

            @formatter.joinVoices([voice]).format([voice], @getStaveWidth())
            voice.draw(@ctx, stave)

    # PLAYING
    reset: () ->
        @pointer = -1 

    setInstrument: (instrument) ->
        if instrument of MusicSheet.INSTRUMENTS_LOADED and
           MusicSheet.INSTRUMENTS_LOADED[instrument]
            @instrument = instrument
        else:
            loadInstrument(instrument, set=true)

    loadInstrument: (instrument, set=false) ->
        if instrument of MusicSheet.INSTRUMENTS_LOADED and
           MusicSheet.INSTRUMENTS_LOADED[instrument]
            return
        else
            MusicSheet.INSTRUMENTS_LOADED[instrument] = false
            MIDI.loadPlugin
                soundfontUrl: "./midi-js-soundfonts/FluidR3_GM/",
                instrument: @instrument,
                callback: (() => 
                            MusicSheet.INSTRUMENTS_LOADED[instrument] = true
                            if set
                                @setInstrument(instrument))

    playNote: (note) ->
        [midi_note, midi_length] = note.toMidi(@tempo)
        MIDI.noteOn(0, midi_note, @volume, 0)
        MIDI.noteOff(0, midi_note, midi_length)

    playNext: () ->
        @draw()
        if (MusicSheet.INSTRUMENTS_LOADED[@instrument])
            notes = @track.getNotesAtBeat(@pointer)
            for note in notes
                @playNote(note)
            @pointer += @interval 

        else
            L "Instrument not yet loaded"
    
    play: () ->
        if not @intervalObj? 
            @reset
            @intervalObj = setInterval(@playNext.bind(@), @interval*(1000.0/@tempo))

    stop: () ->
        clearInterval(@intervalObj)
        @intervalObj = null
        @reset()

# export the classes
if typeof module != "undefined" && module.window
    #On a server
    exports.MusicSheet = MusicSheet
    exports.Track = Track 
    exports.Note = Note
else
    #On a client
    window.MusicSheet = MusicSheet
    window.Track = Track 
    window.Note = Note

