class WVNC extends window.classes.BaseObject
    constructor: (@args) ->
        super "WVNC"
        @socket = undefined
        @uri = undefined
        @uri = @args[0] if @args and @args.length > 0
        @canvas = undefined
        @canvas = ($ @args[1])[0] if @args and @args.length > 1
        @lastPose = { x: 0, y: 0 }
        @scale = 1.0
        @decoder = new Worker('/assets/scripts/decoder.js')
        me = @
        @mouseMask = 0
        @decoder.onmessage = (e) ->
            me.process e.data
    init: () ->
        me = @
        @ready()
            .then () ->
                $("#stop").click (e) -> me.socket.close() if me.socket
                $("#connect").click (e) ->
                    me.openSession()
                me.initInputEvent()
            .catch (m, s) ->
                console.error(m, s)

    initInputEvent: () ->
        me = @

        getMousePos = (e) ->
            rect = me.canvas.getBoundingClientRect()
            pos=
                x:  Math.floor((e.clientX - rect.left) / me.scale)
                y: Math.floor((e.clientY - rect.top) / me.scale)
            return pos

        sendMouseLocation = (e) ->
            p = getMousePos e
            me.sendPointEvent p.x, p.y, me.mouseMask

        return unless me.canvas
        #($ me.canvas).css "cursor", "none"
        ($ me.canvas).contextmenu (e) ->
            e.preventDefault()
            return false

        ($ me.canvas).mousemove (e) -> sendMouseLocation e

        ($ me.canvas).mousedown (e) ->
            state = 1 << e.button
            me.mouseMask = me.mouseMask | state
            sendMouseLocation e
            #e.preventDefault()

        ($ me.canvas).mouseup (e) ->
            state = 1 << e.button
            me.mouseMask = me.mouseMask & (~state)
            sendMouseLocation e
            #e.preventDefault()
        
        me.canvas.onkeydown = me.canvas.onkeyup = me.canvas.onkeypress = (e) ->
            # get the key code
            if e.key is "Shift"
                code = 16
            else if e.ctrlKey
                code = 17
            else if e.altKey
                code = 18
            else if e.metaKey
                code = 91
            else
                code = String.charCodeAt(e.key)
            if e.type is "keydown"
                me.sendKeyEvent code, 1
            else if e.type is "keyup"
                me.sendKeyEvent code, 0
            e.preventDefault()

        # mouse wheel event
        hamster = Hamster @canvas
        hamster.wheel (event, delta, deltaX, deltaY) ->
            p = getMousePos event.originalEvent
            if delta > 0
                me.sendPointEvent p.x, p.y, 8
                me.sendPointEvent p.x, p.y, 0
                return
            me.sendPointEvent p.x, p.y, 16
            me.sendPointEvent p.x, p.y, 0

    initCanvas: (w, h , d) ->
        me = @
        @depth = d
        @canvas.width = w
        @canvas.height = h
        @resolution =
            w: w,
            h: h,
            depth: @depth
        @decoder.postMessage @resolution

    process: (msg) ->
        if not @socket
            return
        data = new Uint8Array msg.buffer
        #w = @buffer.width * @scale
        #h = @buffer.height * @scale
        ctx = @canvas.getContext "2d"
        imgData = ctx.createImageData  msg.w, msg.h
        imgData.data.set data
        ctx.putImageData imgData, msg.x, msg.y
        

    setScale: (n) ->
        @scale = n
        @draw()


    openSession: () ->
        me = @
        @socket.close() if @socket
        return unless @uri
        @socket = new WebSocket @uri
        @socket.binaryType = "arraybuffer"
        @socket.onopen = () ->
            console.log "socket opened"
            me.initConnection()

        @socket.onmessage =  (e) ->
            me.consume e
        @socket.onclose = () ->
            me.socket = null
            console.log "socket closed"

    initConnection: () ->
        vncserver = "localhost:5901"
        data = new Uint8Array vncserver.length + 5
        data[0] = 32 # bbp
        ###
        flag:
            0: raw data no compress
            1: jpeg no compress
            2: raw data compressed by zlib
            3: jpeg data compressed by zlib
        ###
        data[1] = 3
        data[2] = 50 # jpeg quality
        ## rate in milisecond
        rate = 30
        data[3] = rate & 0xFF
        data[4] = (rate >> 8) & 0xFF

        data.set (new TextEncoder()).encode(vncserver), 5
        @socket.send(@buildCommand 0x01, data)

    sendPointEvent: (x, y, mask) ->
        return unless @socket
        data = new Uint8Array 5
        data[0] = x & 0xFF
        data[1] = x >> 8
        data[2] = y & 0xFF
        data[3] = y >> 8
        data[4] = mask
        #console.log x,y
        @socket.send( @buildCommand 0x05, data )

    sendKeyEvent: (code, v) ->
        return unless @socket
        data = new Uint8Array 2
        data[0] = code
        data[1] = v
        console.log String.fromCharCode(code), v
        @socket.send( @buildCommand 0x06, data )

    buildCommand: (hex, o) ->
        data = undefined
        switch typeof o
            when 'string'
                data = (new TextEncoder()).encode(o)
            when 'number'
                data = new Uint8Array [o]
            else
                data = o
        cmd = new Uint8Array data.length + 3
        cmd[0] = hex
        cmd[2] = data.length >> 8
        cmd[1] = data.length & 0x0F
        cmd.set data, 3
        #console.log "the command is", cmd.buffer
        return cmd.buffer
                

    consume: (e) ->
        data = new Uint8Array e.data
        cmd = data[0]
        switch  cmd
            when 0xFE #error
                data = data.subarray 1, data.length - 1
                dec = new TextDecoder("utf-8")
                console.log "Error", dec.decode(data)
            when 0x81
                console.log "Request for password"
                pass = "!x$@n9"
                @socket.send (@buildCommand 0x02, pass)
            when 0x82
                console.log "Request for login"
                user = "mrsang"
                pass = "!x$@n9"
                arr = new Uint8Array user.length + pass.length + 1
                arr.set (new TextEncoder()).encode(user), 0
                arr.set ['\0'], user.length
                arr.set (new TextEncoder()).encode(pass), user.length + 1
                @socket.send(@buildCommand 0x03, arr)
            when 0x83
                console.log "resize"
                w = data[1] | (data[2]<<8)
                h = data[3] | (data[4]<<8)
                depth = data[5]
                @initCanvas w, h, depth
                # status command for ack
                @socket.send(@buildCommand 0x04, 1)
            when 0x84
                # send data to web assembly for decoding
                @decoder.postMessage data.buffer, [data.buffer]
            else
                console.log cmd
        
WVNC.dependencies = [
    "/assets/scripts/hamster.js"
]

makeclass "WVNC", WVNC