/* @ts-self-types="./p8mod.d.ts" */

export class WasmAudioEngine {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        WasmAudioEngineFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_wasmaudioengine_free(ptr, 0);
    }
    /**
     * Clear post-processing filter, restoring passthrough output.
     */
    clear_post_filter() {
        wasm.wasmaudioengine_clear_post_filter(this.__wbg_ptr);
    }
    /**
     * @returns {number}
     */
    current_music_pattern() {
        const ret = wasm.wasmaudioengine_current_music_pattern(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {number} channel
     * @returns {number}
     */
    current_note(channel) {
        const ret = wasm.wasmaudioengine_current_note(this.__wbg_ptr, channel);
        return ret;
    }
    /**
     * @param {number} channel
     * @returns {number}
     */
    current_sfx(channel) {
        const ret = wasm.wasmaudioengine_current_sfx(this.__wbg_ptr, channel);
        return ret;
    }
    /**
     * @param {Float32Array} buffer
     */
    fill_buffer_f32(buffer) {
        var ptr0 = passArrayF32ToWasm0(buffer, wasm.__wbindgen_malloc);
        var len0 = WASM_VECTOR_LEN;
        wasm.wasmaudioengine_fill_buffer_f32(this.__wbg_ptr, ptr0, len0, buffer);
    }
    /**
     * @param {Int16Array} buffer
     */
    fill_buffer_i16(buffer) {
        var ptr0 = passArray16ToWasm0(buffer, wasm.__wbindgen_malloc);
        var len0 = WASM_VECTOR_LEN;
        wasm.wasmaudioengine_fill_buffer_i16(this.__wbg_ptr, ptr0, len0, buffer);
    }
    /**
     * @returns {boolean}
     */
    is_music_playing() {
        const ret = wasm.wasmaudioengine_is_music_playing(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @param {WasmCart} cart
     */
    load_cart(cart) {
        _assertClass(cart, WasmCart);
        wasm.wasmaudioengine_load_cart(this.__wbg_ptr, cart.__wbg_ptr);
    }
    /**
     * @param {number} n
     * @param {number} fade_ms
     * @param {number} channel_mask
     */
    music(n, fade_ms, channel_mask) {
        wasm.wasmaudioengine_music(this.__wbg_ptr, n, fade_ms, channel_mask);
    }
    /**
     * @param {number} sample_rate
     */
    constructor(sample_rate) {
        const ret = wasm.wasmaudioengine_new(sample_rate);
        this.__wbg_ptr = ret >>> 0;
        WasmAudioEngineFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    reset() {
        wasm.wasmaudioengine_reset(this.__wbg_ptr);
    }
    /**
     * @param {boolean} paused
     */
    set_paused(paused) {
        wasm.wasmaudioengine_set_paused(this.__wbg_ptr, paused);
    }
    /**
     * Set post-processing filter by preset ID: 0=Warm, 1=LoFi, 2=Bright.
     * @param {number} preset
     */
    set_post_filter(preset) {
        const ret = wasm.wasmaudioengine_set_post_filter(this.__wbg_ptr, preset);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * Set a custom post-processing filter.
     * @param {number} lowpass_cutoff
     * @param {number} highpass_cutoff
     * @param {number} bitcrush_bits
     * @param {number} saturation_drive
     * @param {number} sample_hold
     */
    set_post_filter_custom(lowpass_cutoff, highpass_cutoff, bitcrush_bits, saturation_drive, sample_hold) {
        wasm.wasmaudioengine_set_post_filter_custom(this.__wbg_ptr, lowpass_cutoff, highpass_cutoff, bitcrush_bits, saturation_drive, sample_hold);
    }
    /**
     * @param {number} n
     * @param {number} channel
     * @param {number} offset
     * @param {number} length
     */
    sfx(n, channel, offset, length) {
        wasm.wasmaudioengine_sfx(this.__wbg_ptr, n, channel, offset, length);
    }
}
if (Symbol.dispose) WasmAudioEngine.prototype[Symbol.dispose] = WasmAudioEngine.prototype.free;

export class WasmCart {
    static __wrap(ptr) {
        ptr = ptr >>> 0;
        const obj = Object.create(WasmCart.prototype);
        obj.__wbg_ptr = ptr;
        WasmCartFinalization.register(obj, obj.__wbg_ptr, obj);
        return obj;
    }
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        WasmCartFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_wasmcart_free(ptr, 0);
    }
    /**
     * @returns {string}
     */
    get code() {
        let deferred1_0;
        let deferred1_1;
        try {
            const ret = wasm.wasmcart_code(this.__wbg_ptr);
            deferred1_0 = ret[0];
            deferred1_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * Compress code using LZSS for .p8.png export.
     * @param {string} code
     * @returns {Uint8Array}
     */
    static compress_lzss(code) {
        const ptr0 = passStringToWasm0(code, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_compress_lzss(ptr0, len0);
        if (ret[3]) {
            throw takeFromExternrefTable0(ret[2]);
        }
        var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v2;
    }
    /**
     * Count characters in code (excluding comments).
     * @param {string} code
     * @returns {number}
     */
    static count_chars(code) {
        const ptr0 = passStringToWasm0(code, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_count_chars(ptr0, len0);
        return ret >>> 0;
    }
    /**
     * Count PICO-8 tokens in code string.
     * @param {string} code
     * @returns {number}
     */
    static count_tokens(code) {
        const ptr0 = passStringToWasm0(code, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_count_tokens(ptr0, len0);
        return ret >>> 0;
    }
    /**
     * @param {string} text
     * @returns {WasmCart}
     */
    static from_p8(text) {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_from_p8(ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return WasmCart.__wrap(ret[0]);
    }
    /**
     * @param {Uint8Array} data
     * @returns {WasmCart}
     */
    static from_p8_png(data) {
        const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_from_p8_png(ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return WasmCart.__wrap(ret[0]);
    }
    /**
     * @param {string} text
     * @returns {WasmCart}
     */
    static from_p8mod(text) {
        const ptr0 = passStringToWasm0(text, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_from_p8mod(ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return WasmCart.__wrap(ret[0]);
    }
    /**
     * Generate i18n Lua runtime code for a locale.
     * glyph_data is an optional flat array of 8 bytes per glyph (bitmap font data).
     * If not provided, uses empty glyph bitmaps.
     * @param {string} locale
     * @param {Uint8Array | null} [glyph_data]
     * @returns {string}
     */
    generate_i18n_lua(locale, glyph_data) {
        let deferred4_0;
        let deferred4_1;
        try {
            const ptr0 = passStringToWasm0(locale, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len0 = WASM_VECTOR_LEN;
            var ptr1 = isLikeNone(glyph_data) ? 0 : passArray8ToWasm0(glyph_data, wasm.__wbindgen_malloc);
            var len1 = WASM_VECTOR_LEN;
            const ret = wasm.wasmcart_generate_i18n_lua(this.__wbg_ptr, ptr0, len0, ptr1, len1);
            var ptr3 = ret[0];
            var len3 = ret[1];
            if (ret[3]) {
                ptr3 = 0; len3 = 0;
                throw takeFromExternrefTable0(ret[2]);
            }
            deferred4_0 = ptr3;
            deferred4_1 = len3;
            return getStringFromWasm0(ptr3, len3);
        } finally {
            wasm.__wbindgen_free(deferred4_0, deferred4_1, 1);
        }
    }
    /**
     * @returns {Uint8Array}
     */
    gfx_data() {
        const ret = wasm.wasmcart_gfx_data(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {Uint8Array}
     */
    gfx_flags_data() {
        const ret = wasm.wasmcart_gfx_flags_data(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @param {number} x
     * @param {number} y
     * @returns {number}
     */
    gfx_pixel(x, y) {
        const ret = wasm.wasmcart_gfx_pixel(this.__wbg_ptr, x, y);
        return ret;
    }
    /**
     * @returns {string | undefined}
     */
    i18n_json() {
        const ret = wasm.wasmcart_i18n_json(this.__wbg_ptr);
        let v1;
        if (ret[0] !== 0) {
            v1 = getStringFromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v1;
    }
    /**
     * @returns {Uint8Array | undefined}
     */
    label_png() {
        const ret = wasm.wasmcart_label_png(this.__wbg_ptr);
        let v1;
        if (ret[0] !== 0) {
            v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v1;
    }
    /**
     * Auto-detect format from raw bytes and parse.
     * @param {Uint8Array} data
     * @returns {WasmCart}
     */
    static load(data) {
        const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_load(ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return WasmCart.__wrap(ret[0]);
    }
    /**
     * @param {number} x
     * @param {number} y
     * @returns {number}
     */
    map_cell(x, y) {
        const ret = wasm.wasmcart_map_cell(this.__wbg_ptr, x, y);
        return ret;
    }
    /**
     * @returns {Uint8Array}
     */
    map_data() {
        const ret = wasm.wasmcart_map_data(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {string | undefined}
     */
    meta_json() {
        const ret = wasm.wasmcart_meta_json(this.__wbg_ptr);
        let v1;
        if (ret[0] !== 0) {
            v1 = getStringFromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v1;
    }
    /**
     * @returns {Uint8Array}
     */
    music_data() {
        const ret = wasm.wasmcart_music_data(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * Get music pattern as JSON: {channels: [u8;4], channel_enabled: [bool;4], loop_start, loop_end, loop_back}
     * @param {number} index
     * @returns {string}
     */
    music_pattern_json(index) {
        let deferred2_0;
        let deferred2_1;
        try {
            const ret = wasm.wasmcart_music_pattern_json(this.__wbg_ptr, index);
            var ptr1 = ret[0];
            var len1 = ret[1];
            if (ret[3]) {
                ptr1 = 0; len1 = 0;
                throw takeFromExternrefTable0(ret[2]);
            }
            deferred2_0 = ptr1;
            deferred2_1 = len1;
            return getStringFromWasm0(ptr1, len1);
        } finally {
            wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
        }
    }
    constructor() {
        const ret = wasm.wasmcart_new();
        this.__wbg_ptr = ret >>> 0;
        WasmCartFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {string} code
     */
    set code(code) {
        const ptr0 = passStringToWasm0(code, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wasmcart_set_code(this.__wbg_ptr, ptr0, len0);
    }
    /**
     * @param {Uint8Array} data
     */
    set_gfx_data(data) {
        const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_gfx_data(this.__wbg_ptr, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Uint8Array} data
     */
    set_gfx_flags_data(data) {
        const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_gfx_flags_data(this.__wbg_ptr, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {number} x
     * @param {number} y
     * @param {number} color
     */
    set_gfx_pixel(x, y, color) {
        wasm.wasmcart_set_gfx_pixel(this.__wbg_ptr, x, y, color);
    }
    /**
     * @param {string} json
     */
    set_i18n_json(json) {
        const ptr0 = passStringToWasm0(json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_i18n_json(this.__wbg_ptr, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Uint8Array} png_data
     */
    set_label_png(png_data) {
        const ptr0 = passArray8ToWasm0(png_data, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wasmcart_set_label_png(this.__wbg_ptr, ptr0, len0);
    }
    /**
     * @param {number} x
     * @param {number} y
     * @param {number} sprite_id
     */
    set_map_cell(x, y, sprite_id) {
        wasm.wasmcart_set_map_cell(this.__wbg_ptr, x, y, sprite_id);
    }
    /**
     * @param {Uint8Array} data
     */
    set_map_data(data) {
        const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_map_data(this.__wbg_ptr, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} json
     */
    set_meta_json(json) {
        const ptr0 = passStringToWasm0(json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_meta_json(this.__wbg_ptr, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Uint8Array} data
     */
    set_music_data(data) {
        const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_music_data(this.__wbg_ptr, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * Set music pattern from JSON.
     * @param {number} index
     * @param {string} json
     */
    set_music_pattern_json(index, json) {
        const ptr0 = passStringToWasm0(json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_music_pattern_json(this.__wbg_ptr, index, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Uint8Array} data
     */
    set_sfx_data(data) {
        const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_sfx_data(this.__wbg_ptr, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * Set SFX entry from JSON.
     * @param {number} index
     * @param {string} json
     */
    set_sfx_entry_json(index, json) {
        const ptr0 = passStringToWasm0(json, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_set_sfx_entry_json(this.__wbg_ptr, index, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {number} sprite
     * @param {number} flags
     */
    set_sprite_flag(sprite, flags) {
        wasm.wasmcart_set_sprite_flag(this.__wbg_ptr, sprite, flags);
    }
    /**
     * @returns {Uint8Array}
     */
    sfx_data() {
        const ret = wasm.wasmcart_sfx_data(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * Get SFX entry as JSON: {notes: [{pitch, waveform, volume, effect, custom}×32], filters, speed, loop_start, loop_end}
     * @param {number} index
     * @returns {string}
     */
    sfx_entry_json(index) {
        let deferred2_0;
        let deferred2_1;
        try {
            const ret = wasm.wasmcart_sfx_entry_json(this.__wbg_ptr, index);
            var ptr1 = ret[0];
            var len1 = ret[1];
            if (ret[3]) {
                ptr1 = 0; len1 = 0;
                throw takeFromExternrefTable0(ret[2]);
            }
            deferred2_0 = ptr1;
            deferred2_1 = len1;
            return getStringFromWasm0(ptr1, len1);
        } finally {
            wasm.__wbindgen_free(deferred2_0, deferred2_1, 1);
        }
    }
    /**
     * @param {number} sprite
     * @returns {number}
     */
    sprite_flag(sprite) {
        const ret = wasm.wasmcart_sprite_flag(this.__wbg_ptr, sprite);
        return ret;
    }
    /**
     * @returns {string}
     */
    to_p8() {
        let deferred1_0;
        let deferred1_1;
        try {
            const ret = wasm.wasmcart_to_p8(this.__wbg_ptr);
            deferred1_0 = ret[0];
            deferred1_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * @param {Uint8Array | null} [cover]
     * @returns {Uint8Array}
     */
    to_p8_png(cover) {
        var ptr0 = isLikeNone(cover) ? 0 : passArray8ToWasm0(cover, wasm.__wbindgen_malloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.wasmcart_to_p8_png(this.__wbg_ptr, ptr0, len0);
        if (ret[3]) {
            throw takeFromExternrefTable0(ret[2]);
        }
        var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v2;
    }
    /**
     * @returns {string}
     */
    to_p8mod() {
        let deferred1_0;
        let deferred1_1;
        try {
            const ret = wasm.wasmcart_to_p8mod(this.__wbg_ptr);
            deferred1_0 = ret[0];
            deferred1_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * @returns {number}
     */
    get version() {
        const ret = wasm.wasmcart_version(this.__wbg_ptr);
        return ret;
    }
}
if (Symbol.dispose) WasmCart.prototype[Symbol.dispose] = WasmCart.prototype.free;
function __wbg_get_imports() {
    const import0 = {
        __proto__: null,
        __wbg_Error_960c155d3d49e4c2: function(arg0, arg1) {
            const ret = Error(getStringFromWasm0(arg0, arg1));
            return ret;
        },
        __wbg___wbindgen_copy_to_typed_array_9e08990f20659111: function(arg0, arg1, arg2) {
            new Uint8Array(arg2.buffer, arg2.byteOffset, arg2.byteLength).set(getArrayU8FromWasm0(arg0, arg1));
        },
        __wbg___wbindgen_throw_6b64449b9b9ed33c: function(arg0, arg1) {
            throw new Error(getStringFromWasm0(arg0, arg1));
        },
        __wbindgen_init_externref_table: function() {
            const table = wasm.__wbindgen_externrefs;
            const offset = table.grow(4);
            table.set(0, undefined);
            table.set(offset + 0, undefined);
            table.set(offset + 1, null);
            table.set(offset + 2, true);
            table.set(offset + 3, false);
        },
    };
    return {
        __proto__: null,
        "./p8mod_bg.js": import0,
    };
}

const WasmAudioEngineFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_wasmaudioengine_free(ptr >>> 0, 1));
const WasmCartFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_wasmcart_free(ptr >>> 0, 1));

function _assertClass(instance, klass) {
    if (!(instance instanceof klass)) {
        throw new Error(`expected instance of ${klass.name}`);
    }
}

function getArrayU8FromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return getUint8ArrayMemory0().subarray(ptr / 1, ptr / 1 + len);
}

let cachedFloat32ArrayMemory0 = null;
function getFloat32ArrayMemory0() {
    if (cachedFloat32ArrayMemory0 === null || cachedFloat32ArrayMemory0.byteLength === 0) {
        cachedFloat32ArrayMemory0 = new Float32Array(wasm.memory.buffer);
    }
    return cachedFloat32ArrayMemory0;
}

function getStringFromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return decodeText(ptr, len);
}

let cachedUint16ArrayMemory0 = null;
function getUint16ArrayMemory0() {
    if (cachedUint16ArrayMemory0 === null || cachedUint16ArrayMemory0.byteLength === 0) {
        cachedUint16ArrayMemory0 = new Uint16Array(wasm.memory.buffer);
    }
    return cachedUint16ArrayMemory0;
}

let cachedUint8ArrayMemory0 = null;
function getUint8ArrayMemory0() {
    if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
        cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
    }
    return cachedUint8ArrayMemory0;
}

function isLikeNone(x) {
    return x === undefined || x === null;
}

function passArray16ToWasm0(arg, malloc) {
    const ptr = malloc(arg.length * 2, 2) >>> 0;
    getUint16ArrayMemory0().set(arg, ptr / 2);
    WASM_VECTOR_LEN = arg.length;
    return ptr;
}

function passArray8ToWasm0(arg, malloc) {
    const ptr = malloc(arg.length * 1, 1) >>> 0;
    getUint8ArrayMemory0().set(arg, ptr / 1);
    WASM_VECTOR_LEN = arg.length;
    return ptr;
}

function passArrayF32ToWasm0(arg, malloc) {
    const ptr = malloc(arg.length * 4, 4) >>> 0;
    getFloat32ArrayMemory0().set(arg, ptr / 4);
    WASM_VECTOR_LEN = arg.length;
    return ptr;
}

function passStringToWasm0(arg, malloc, realloc) {
    if (realloc === undefined) {
        const buf = cachedTextEncoder.encode(arg);
        const ptr = malloc(buf.length, 1) >>> 0;
        getUint8ArrayMemory0().subarray(ptr, ptr + buf.length).set(buf);
        WASM_VECTOR_LEN = buf.length;
        return ptr;
    }

    let len = arg.length;
    let ptr = malloc(len, 1) >>> 0;

    const mem = getUint8ArrayMemory0();

    let offset = 0;

    for (; offset < len; offset++) {
        const code = arg.charCodeAt(offset);
        if (code > 0x7F) break;
        mem[ptr + offset] = code;
    }
    if (offset !== len) {
        if (offset !== 0) {
            arg = arg.slice(offset);
        }
        ptr = realloc(ptr, len, len = offset + arg.length * 3, 1) >>> 0;
        const view = getUint8ArrayMemory0().subarray(ptr + offset, ptr + len);
        const ret = cachedTextEncoder.encodeInto(arg, view);

        offset += ret.written;
        ptr = realloc(ptr, len, offset, 1) >>> 0;
    }

    WASM_VECTOR_LEN = offset;
    return ptr;
}

function takeFromExternrefTable0(idx) {
    const value = wasm.__wbindgen_externrefs.get(idx);
    wasm.__externref_table_dealloc(idx);
    return value;
}

let cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
cachedTextDecoder.decode();
const MAX_SAFARI_DECODE_BYTES = 2146435072;
let numBytesDecoded = 0;
function decodeText(ptr, len) {
    numBytesDecoded += len;
    if (numBytesDecoded >= MAX_SAFARI_DECODE_BYTES) {
        cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
        cachedTextDecoder.decode();
        numBytesDecoded = len;
    }
    return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
}

const cachedTextEncoder = new TextEncoder();

if (!('encodeInto' in cachedTextEncoder)) {
    cachedTextEncoder.encodeInto = function (arg, view) {
        const buf = cachedTextEncoder.encode(arg);
        view.set(buf);
        return {
            read: arg.length,
            written: buf.length
        };
    };
}

let WASM_VECTOR_LEN = 0;

let wasmModule, wasm;
function __wbg_finalize_init(instance, module) {
    wasm = instance.exports;
    wasmModule = module;
    cachedFloat32ArrayMemory0 = null;
    cachedUint16ArrayMemory0 = null;
    cachedUint8ArrayMemory0 = null;
    wasm.__wbindgen_start();
    return wasm;
}

async function __wbg_load(module, imports) {
    if (typeof Response === 'function' && module instanceof Response) {
        if (typeof WebAssembly.instantiateStreaming === 'function') {
            try {
                return await WebAssembly.instantiateStreaming(module, imports);
            } catch (e) {
                const validResponse = module.ok && expectedResponseType(module.type);

                if (validResponse && module.headers.get('Content-Type') !== 'application/wasm') {
                    console.warn("`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n", e);

                } else { throw e; }
            }
        }

        const bytes = await module.arrayBuffer();
        return await WebAssembly.instantiate(bytes, imports);
    } else {
        const instance = await WebAssembly.instantiate(module, imports);

        if (instance instanceof WebAssembly.Instance) {
            return { instance, module };
        } else {
            return instance;
        }
    }

    function expectedResponseType(type) {
        switch (type) {
            case 'basic': case 'cors': case 'default': return true;
        }
        return false;
    }
}

function initSync(module) {
    if (wasm !== undefined) return wasm;


    if (module !== undefined) {
        if (Object.getPrototypeOf(module) === Object.prototype) {
            ({module} = module)
        } else {
            console.warn('using deprecated parameters for `initSync()`; pass a single object instead')
        }
    }

    const imports = __wbg_get_imports();
    if (!(module instanceof WebAssembly.Module)) {
        module = new WebAssembly.Module(module);
    }
    const instance = new WebAssembly.Instance(module, imports);
    return __wbg_finalize_init(instance, module);
}

async function __wbg_init(module_or_path) {
    if (wasm !== undefined) return wasm;


    if (module_or_path !== undefined) {
        if (Object.getPrototypeOf(module_or_path) === Object.prototype) {
            ({module_or_path} = module_or_path)
        } else {
            console.warn('using deprecated parameters for the initialization function; pass a single object instead')
        }
    }

    if (module_or_path === undefined) {
        module_or_path = new URL('p8mod_bg.wasm', import.meta.url);
    }
    const imports = __wbg_get_imports();

    if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
        module_or_path = fetch(module_or_path);
    }

    const { instance, module } = await __wbg_load(await module_or_path, imports);

    return __wbg_finalize_init(instance, module);
}

export { initSync, __wbg_init as default };
