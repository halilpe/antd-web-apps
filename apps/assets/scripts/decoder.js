// Generated by CoffeeScript 1.9.3
  var api, onmessage, resolution;

  importScripts('wvnc_asm.js');

  api = {};

  resolution = void 0;

  Module.onRuntimeInitialized = function() {
    return api = {
      createBuffer: Module.cwrap('create_buffer', 'number', ['number', 'number']),
      destroyBuffer: Module.cwrap('destroy_buffer', '', ['number']),
      updateBuffer: Module.cwrap("update", 'number', ['number', 'number', 'number', 'number', 'number', 'number']),
      decodeBuffer: Module.cwrap("decode", 'number', ['number', 'number', 'number', 'number'])
    };
  };

  onmessage = function(e) {
    var datain, dataout, flag, h, msg, p, po, size, tmp, w, x, y;
    if (e.data.depth) {
      return resolution = e.data;
    } else {
      datain = new Uint8Array(e.data);
      x = datain[1] | (datain[2] << 8);
      y = datain[3] | (datain[4] << 8);
      w = datain[5] | (datain[6] << 8);
      h = datain[7] | (datain[8] << 8);
      flag = datain[9];
      p = api.createBuffer(datain.length);
      Module.HEAP8.set(datain, p);
      size = w * h * 4;
      po = api.decodeBuffer(p, datain.length, resolution.depth, size);
      dataout = new Uint8Array(Module.HEAP8.buffer, po, size);
      msg = {};
      tmp = new Uint8Array(size);
      tmp.set(dataout, 0);
      msg.buffer = tmp.buffer;
      msg.x = x;
      msg.y = y;
      msg.w = w;
      msg.h = h;
      postMessage(msg, [msg.buffer]);
      api.destroyBuffer(p);
      if (flag !== 0x0 || resolution.depth !== 32) {
        return api.destroyBuffer(po);
      }
    }
  };

