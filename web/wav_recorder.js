(function (global) {
  const TARGET_RATE = 16000;

  let audioContext = null;
  let processor = null;
  let source = null;
  let mute = null;
  let stream = null;
  let chunks = [];
  let startedAt = 0;

  const mergeFloat32 = (arrays) => {
    let length = 0;
    for (const item of arrays) {
      length += item.length;
    }
    const output = new Float32Array(length);
    let offset = 0;
    for (const item of arrays) {
      output.set(item, offset);
      offset += item.length;
    }
    return output;
  };

  const resample = (input, fromRate, toRate) => {
    if (fromRate === toRate) {
      return input;
    }
    const ratio = fromRate / toRate;
    const outLength = Math.max(1, Math.round(input.length / ratio));
    const output = new Float32Array(outLength);
    for (let index = 0; index < outLength; index += 1) {
      const position = index * ratio;
      const left = Math.floor(position);
      const right = Math.min(left + 1, input.length - 1);
      const fraction = position - left;
      output[index] = input[left] * (1 - fraction) + input[right] * fraction;
    }
    return output;
  };

  const encodeWav = (samples, sampleRate) => {
    const buffer = new ArrayBuffer(44 + samples.length * 2);
    const view = new DataView(buffer);
    const writeString = (offset, value) => {
      for (let index = 0; index < value.length; index += 1) {
        view.setUint8(offset + index, value.charCodeAt(index));
      }
    };

    writeString(0, 'RIFF');
    view.setUint32(4, 36 + samples.length * 2, true);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    view.setUint32(16, 16, true);
    view.setUint16(20, 1, true);
    view.setUint16(22, 1, true);
    view.setUint32(24, sampleRate, true);
    view.setUint32(28, sampleRate * 2, true);
    view.setUint16(32, 2, true);
    view.setUint16(34, 16, true);
    writeString(36, 'data');
    view.setUint32(40, samples.length * 2, true);

    let offset = 44;
    for (let index = 0; index < samples.length; index += 1, offset += 2) {
      const clipped = Math.max(-1, Math.min(1, samples[index]));
      view.setInt16(offset, clipped < 0 ? clipped * 0x8000 : clipped * 0x7fff, true);
    }

    const bytes = new Uint8Array(buffer);
    let binary = '';
    const chunkSize = 0x8000;
    for (let index = 0; index < bytes.length; index += chunkSize) {
      binary += String.fromCharCode.apply(
        null,
        bytes.subarray(index, index + chunkSize),
      );
    }
    return btoa(binary);
  };

  const start = async () => {
    await cancel();
    stream = await navigator.mediaDevices.getUserMedia({
      audio: {
        channelCount: 1,
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true,
      },
    });
    audioContext = new AudioContext();
    source = audioContext.createMediaStreamSource(stream);
    processor = audioContext.createScriptProcessor(4096, 1, 1);
    mute = audioContext.createGain();
    mute.gain.value = 0;
    chunks = [];
    processor.onaudioprocess = (event) => {
      chunks.push(new Float32Array(event.inputBuffer.getChannelData(0)));
    };
    source.connect(processor);
    processor.connect(mute);
    mute.connect(audioContext.destination);
    startedAt = Date.now();
    return true;
  };

  const stop = async () => {
    const durationMs = startedAt === 0 ? 0 : Date.now() - startedAt;
    const nativeRate = audioContext ? audioContext.sampleRate : TARGET_RATE;
    const merged = mergeFloat32(chunks);
    await cancel();
    const resampled = resample(merged, nativeRate, TARGET_RATE);
    return {
      wavBase64: encodeWav(resampled, TARGET_RATE),
      sampleRate: TARGET_RATE,
      durationMs,
    };
  };

  const cancel = async () => {
    if (processor) {
      processor.disconnect();
      processor.onaudioprocess = null;
      processor = null;
    }
    if (source) {
      source.disconnect();
      source = null;
    }
    if (mute) {
      mute.disconnect();
      mute = null;
    }
    if (audioContext) {
      await audioContext.close().catch(() => {});
      audioContext = null;
    }
    if (stream) {
      stream.getTracks().forEach((track) => track.stop());
      stream = null;
    }
    chunks = [];
    startedAt = 0;
  };

  global.SpeakMasterWavRecorder = { start, stop, cancel };
})(window);
