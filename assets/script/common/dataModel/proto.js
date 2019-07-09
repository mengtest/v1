/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 14:21:06
 * @LastEditTime: 2019-07-09 11:25:04
 */
/*eslint-disable block-scoped-var, id-length, no-control-regex, no-magic-numbers, no-prototype-builtins, no-redeclare, no-shadow, no-var, sort-vars*/
"use strict";

if (!CC_EDITOR) {

    var $protobuf = require("../utils/protobuf");

    // Common aliases
    var $Reader = $protobuf.Reader, $Writer = $protobuf.Writer, $util = $protobuf.util;

    // Exported root namespace
    var $root = $protobuf.roots["default"] || ($protobuf.roots["default"] = {});

    $root.Hongzao = (function () {

        /**
         * Namespace Hongzao.
         * @exports Hongzao
         * @namespace
         */
        var Hongzao = {};

        Hongzao.BaseProtocol = (function () {

            /**
             * Properties of a BaseProtocol.
             * @memberof Hongzao
             * @interface IBaseProtocol
             * @property {string} act BaseProtocol act
             * @property {number} seq BaseProtocol seq
             * @property {number} err BaseProtocol err
             * @property {boolean} isAsync BaseProtocol isAsync
             * @property {string} ts BaseProtocol ts
             */

            /**
             * Constructs a new BaseProtocol.
             * @memberof Hongzao
             * @classdesc Represents a BaseProtocol.
             * @implements IBaseProtocol
             * @constructor
             * @param {Hongzao.IBaseProtocol=} [properties] Properties to set
             */
            function BaseProtocol(properties) {
                if (properties)
                    for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                        if (properties[keys[i]] != null)
                            this[keys[i]] = properties[keys[i]];
            }

            /**
             * BaseProtocol act.
             * @member {string} act
             * @memberof Hongzao.BaseProtocol
             * @instance
             */
            BaseProtocol.prototype.act = "";

            /**
             * BaseProtocol seq.
             * @member {number} seq
             * @memberof Hongzao.BaseProtocol
             * @instance
             */
            BaseProtocol.prototype.seq = 0;

            /**
             * BaseProtocol err.
             * @member {number} err
             * @memberof Hongzao.BaseProtocol
             * @instance
             */
            BaseProtocol.prototype.err = 0;

            /**
             * BaseProtocol isAsync.
             * @member {boolean} isAsync
             * @memberof Hongzao.BaseProtocol
             * @instance
             */
            BaseProtocol.prototype.isAsync = false;

            /**
             * BaseProtocol ts.
             * @member {string} ts
             * @memberof Hongzao.BaseProtocol
             * @instance
             */
            BaseProtocol.prototype.ts = "";

            /**
             * Creates a new BaseProtocol instance using the specified properties.
             * @function create
             * @memberof Hongzao.BaseProtocol
             * @static
             * @param {Hongzao.IBaseProtocol=} [properties] Properties to set
             * @returns {Hongzao.BaseProtocol} BaseProtocol instance
             */
            BaseProtocol.create = function create(properties) {
                return new BaseProtocol(properties);
            };

            /**
             * Encodes the specified BaseProtocol message. Does not implicitly {@link Hongzao.BaseProtocol.verify|verify} messages.
             * @function encode
             * @memberof Hongzao.BaseProtocol
             * @static
             * @param {Hongzao.IBaseProtocol} message BaseProtocol message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            BaseProtocol.encode = function encode(message, writer) {
                if (!writer)
                    writer = $Writer.create();
                writer.uint32(/* id 1, wireType 2 =*/10).string(message.act);
                writer.uint32(/* id 2, wireType 0 =*/16).int32(message.seq);
                writer.uint32(/* id 3, wireType 0 =*/24).int32(message.err);
                writer.uint32(/* id 4, wireType 0 =*/32).bool(message.isAsync);
                writer.uint32(/* id 5, wireType 2 =*/42).string(message.ts);
                return writer;
            };

            /**
             * Encodes the specified BaseProtocol message, length delimited. Does not implicitly {@link Hongzao.BaseProtocol.verify|verify} messages.
             * @function encodeDelimited
             * @memberof Hongzao.BaseProtocol
             * @static
             * @param {Hongzao.IBaseProtocol} message BaseProtocol message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            BaseProtocol.encodeDelimited = function encodeDelimited(message, writer) {
                return this.encode(message, writer).ldelim();
            };

            /**
             * Decodes a BaseProtocol message from the specified reader or buffer.
             * @function decode
             * @memberof Hongzao.BaseProtocol
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @param {number} [length] Message length if known beforehand
             * @returns {Hongzao.BaseProtocol} BaseProtocol
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            BaseProtocol.decode = function decode(reader, length) {
                if (!(reader instanceof $Reader))
                    reader = $Reader.create(reader);
                var end = length === undefined ? reader.len : reader.pos + length, message = new $root.Hongzao.BaseProtocol();
                while (reader.pos < end) {
                    var tag = reader.uint32();
                    switch (tag >>> 3) {
                        case 1:
                            message.act = reader.string();
                            break;
                        case 2:
                            message.seq = reader.int32();
                            break;
                        case 3:
                            message.err = reader.int32();
                            break;
                        case 4:
                            message.isAsync = reader.bool();
                            break;
                        case 5:
                            message.ts = reader.string();
                            break;
                        default:
                            reader.skipType(tag & 7);
                            break;
                    }
                }
                if (!message.hasOwnProperty("act"))
                    throw $util.ProtocolError("missing required 'act'", { instance: message });
                if (!message.hasOwnProperty("seq"))
                    throw $util.ProtocolError("missing required 'seq'", { instance: message });
                if (!message.hasOwnProperty("err"))
                    throw $util.ProtocolError("missing required 'err'", { instance: message });
                if (!message.hasOwnProperty("isAsync"))
                    throw $util.ProtocolError("missing required 'isAsync'", { instance: message });
                if (!message.hasOwnProperty("ts"))
                    throw $util.ProtocolError("missing required 'ts'", { instance: message });
                return message;
            };

            /**
             * Decodes a BaseProtocol message from the specified reader or buffer, length delimited.
             * @function decodeDelimited
             * @memberof Hongzao.BaseProtocol
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @returns {Hongzao.BaseProtocol} BaseProtocol
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            BaseProtocol.decodeDelimited = function decodeDelimited(reader) {
                if (!(reader instanceof $Reader))
                    reader = new $Reader(reader);
                return this.decode(reader, reader.uint32());
            };

            /**
             * Verifies a BaseProtocol message.
             * @function verify
             * @memberof Hongzao.BaseProtocol
             * @static
             * @param {Object.<string,*>} message Plain object to verify
             * @returns {string|null} `null` if valid, otherwise the reason why it is not
             */
            BaseProtocol.verify = function verify(message) {
                if (typeof message !== "object" || message === null)
                    return "object expected";
                if (!$util.isString(message.act))
                    return "act: string expected";
                if (!$util.isInteger(message.seq))
                    return "seq: integer expected";
                if (!$util.isInteger(message.err))
                    return "err: integer expected";
                if (typeof message.isAsync !== "boolean")
                    return "isAsync: boolean expected";
                if (!$util.isString(message.ts))
                    return "ts: string expected";
                return null;
            };

            /**
             * Creates a BaseProtocol message from a plain object. Also converts values to their respective internal types.
             * @function fromObject
             * @memberof Hongzao.BaseProtocol
             * @static
             * @param {Object.<string,*>} object Plain object
             * @returns {Hongzao.BaseProtocol} BaseProtocol
             */
            BaseProtocol.fromObject = function fromObject(object) {
                if (object instanceof $root.Hongzao.BaseProtocol)
                    return object;
                var message = new $root.Hongzao.BaseProtocol();
                if (object.act != null)
                    message.act = String(object.act);
                if (object.seq != null)
                    message.seq = object.seq | 0;
                if (object.err != null)
                    message.err = object.err | 0;
                if (object.isAsync != null)
                    message.isAsync = Boolean(object.isAsync);
                if (object.ts != null)
                    message.ts = String(object.ts);
                return message;
            };

            /**
             * Creates a plain object from a BaseProtocol message. Also converts values to other types if specified.
             * @function toObject
             * @memberof Hongzao.BaseProtocol
             * @static
             * @param {Hongzao.BaseProtocol} message BaseProtocol
             * @param {$protobuf.IConversionOptions} [options] Conversion options
             * @returns {Object.<string,*>} Plain object
             */
            BaseProtocol.toObject = function toObject(message, options) {
                if (!options)
                    options = {};
                var object = {};
                if (options.defaults) {
                    object.act = "";
                    object.seq = 0;
                    object.err = 0;
                    object.isAsync = false;
                    object.ts = "";
                }
                if (message.act != null && message.hasOwnProperty("act"))
                    object.act = message.act;
                if (message.seq != null && message.hasOwnProperty("seq"))
                    object.seq = message.seq;
                if (message.err != null && message.hasOwnProperty("err"))
                    object.err = message.err;
                if (message.isAsync != null && message.hasOwnProperty("isAsync"))
                    object.isAsync = message.isAsync;
                if (message.ts != null && message.hasOwnProperty("ts"))
                    object.ts = message.ts;
                return object;
            };

            /**
             * Converts this BaseProtocol to JSON.
             * @function toJSON
             * @memberof Hongzao.BaseProtocol
             * @instance
             * @returns {Object.<string,*>} JSON object
             */
            BaseProtocol.prototype.toJSON = function toJSON() {
                return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
            };

            return BaseProtocol;
        })();

        Hongzao.HeartBreak = (function () {

            /**
             * Properties of a HeartBreak.
             * @memberof Hongzao
             * @interface IHeartBreak
             * @property {Hongzao.IBaseProtocol} base HeartBreak base
             * @property {string} username HeartBreak username
             */

            /**
             * Constructs a new HeartBreak.
             * @memberof Hongzao
             * @classdesc Represents a HeartBreak.
             * @implements IHeartBreak
             * @constructor
             * @param {Hongzao.IHeartBreak=} [properties] Properties to set
             */
            function HeartBreak(properties) {
                if (properties)
                    for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                        if (properties[keys[i]] != null)
                            this[keys[i]] = properties[keys[i]];
            }

            /**
             * HeartBreak base.
             * @member {Hongzao.IBaseProtocol} base
             * @memberof Hongzao.HeartBreak
             * @instance
             */
            HeartBreak.prototype.base = null;

            /**
             * HeartBreak username.
             * @member {string} username
             * @memberof Hongzao.HeartBreak
             * @instance
             */
            HeartBreak.prototype.username = "";

            /**
             * Creates a new HeartBreak instance using the specified properties.
             * @function create
             * @memberof Hongzao.HeartBreak
             * @static
             * @param {Hongzao.IHeartBreak=} [properties] Properties to set
             * @returns {Hongzao.HeartBreak} HeartBreak instance
             */
            HeartBreak.create = function create(properties) {
                return new HeartBreak(properties);
            };

            /**
             * Encodes the specified HeartBreak message. Does not implicitly {@link Hongzao.HeartBreak.verify|verify} messages.
             * @function encode
             * @memberof Hongzao.HeartBreak
             * @static
             * @param {Hongzao.IHeartBreak} message HeartBreak message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            HeartBreak.encode = function encode(message, writer) {
                if (!writer)
                    writer = $Writer.create();
                $root.Hongzao.BaseProtocol.encode(message.base, writer.uint32(/* id 1, wireType 2 =*/10).fork()).ldelim();
                writer.uint32(/* id 2, wireType 2 =*/18).string(message.username);
                return writer;
            };

            /**
             * Encodes the specified HeartBreak message, length delimited. Does not implicitly {@link Hongzao.HeartBreak.verify|verify} messages.
             * @function encodeDelimited
             * @memberof Hongzao.HeartBreak
             * @static
             * @param {Hongzao.IHeartBreak} message HeartBreak message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            HeartBreak.encodeDelimited = function encodeDelimited(message, writer) {
                return this.encode(message, writer).ldelim();
            };

            /**
             * Decodes a HeartBreak message from the specified reader or buffer.
             * @function decode
             * @memberof Hongzao.HeartBreak
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @param {number} [length] Message length if known beforehand
             * @returns {Hongzao.HeartBreak} HeartBreak
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            HeartBreak.decode = function decode(reader, length) {
                if (!(reader instanceof $Reader))
                    reader = $Reader.create(reader);
                var end = length === undefined ? reader.len : reader.pos + length, message = new $root.Hongzao.HeartBreak();
                while (reader.pos < end) {
                    var tag = reader.uint32();
                    switch (tag >>> 3) {
                        case 1:
                            message.base = $root.Hongzao.BaseProtocol.decode(reader, reader.uint32());
                            break;
                        case 2:
                            message.username = reader.string();
                            break;
                        default:
                            reader.skipType(tag & 7);
                            break;
                    }
                }
                if (!message.hasOwnProperty("base"))
                    throw $util.ProtocolError("missing required 'base'", { instance: message });
                if (!message.hasOwnProperty("username"))
                    throw $util.ProtocolError("missing required 'username'", { instance: message });
                return message;
            };

            /**
             * Decodes a HeartBreak message from the specified reader or buffer, length delimited.
             * @function decodeDelimited
             * @memberof Hongzao.HeartBreak
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @returns {Hongzao.HeartBreak} HeartBreak
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            HeartBreak.decodeDelimited = function decodeDelimited(reader) {
                if (!(reader instanceof $Reader))
                    reader = new $Reader(reader);
                return this.decode(reader, reader.uint32());
            };

            /**
             * Verifies a HeartBreak message.
             * @function verify
             * @memberof Hongzao.HeartBreak
             * @static
             * @param {Object.<string,*>} message Plain object to verify
             * @returns {string|null} `null` if valid, otherwise the reason why it is not
             */
            HeartBreak.verify = function verify(message) {
                if (typeof message !== "object" || message === null)
                    return "object expected";
                {
                    var error = $root.Hongzao.BaseProtocol.verify(message.base);
                    if (error)
                        return "base." + error;
                }
                if (!$util.isString(message.username))
                    return "username: string expected";
                return null;
            };

            /**
             * Creates a HeartBreak message from a plain object. Also converts values to their respective internal types.
             * @function fromObject
             * @memberof Hongzao.HeartBreak
             * @static
             * @param {Object.<string,*>} object Plain object
             * @returns {Hongzao.HeartBreak} HeartBreak
             */
            HeartBreak.fromObject = function fromObject(object) {
                if (object instanceof $root.Hongzao.HeartBreak)
                    return object;
                var message = new $root.Hongzao.HeartBreak();
                if (object.base != null) {
                    if (typeof object.base !== "object")
                        throw TypeError(".Hongzao.HeartBreak.base: object expected");
                    message.base = $root.Hongzao.BaseProtocol.fromObject(object.base);
                }
                if (object.username != null)
                    message.username = String(object.username);
                return message;
            };

            /**
             * Creates a plain object from a HeartBreak message. Also converts values to other types if specified.
             * @function toObject
             * @memberof Hongzao.HeartBreak
             * @static
             * @param {Hongzao.HeartBreak} message HeartBreak
             * @param {$protobuf.IConversionOptions} [options] Conversion options
             * @returns {Object.<string,*>} Plain object
             */
            HeartBreak.toObject = function toObject(message, options) {
                if (!options)
                    options = {};
                var object = {};
                if (options.defaults) {
                    object.base = null;
                    object.username = "";
                }
                if (message.base != null && message.hasOwnProperty("base"))
                    object.base = $root.Hongzao.BaseProtocol.toObject(message.base, options);
                if (message.username != null && message.hasOwnProperty("username"))
                    object.username = message.username;
                return object;
            };

            /**
             * Converts this HeartBreak to JSON.
             * @function toJSON
             * @memberof Hongzao.HeartBreak
             * @instance
             * @returns {Object.<string,*>} JSON object
             */
            HeartBreak.prototype.toJSON = function toJSON() {
                return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
            };

            return HeartBreak;
        })();

        return Hongzao;
    })();

    $root.google = (function () {

        /**
         * Namespace google.
         * @exports google
         * @namespace
         */
        var google = {};

        google.protobuf = (function () {

            /**
             * Namespace protobuf.
             * @memberof google
             * @namespace
             */
            var protobuf = {};

            protobuf.Any = (function () {

                /**
                 * Properties of an Any.
                 * @memberof google.protobuf
                 * @interface IAny
                 * @property {string|null} [type_url] Any type_url
                 * @property {Uint8Array|null} [value] Any value
                 */

                /**
                 * Constructs a new Any.
                 * @memberof google.protobuf
                 * @classdesc Represents an Any.
                 * @implements IAny
                 * @constructor
                 * @param {google.protobuf.IAny=} [properties] Properties to set
                 */
                function Any(properties) {
                    if (properties)
                        for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                            if (properties[keys[i]] != null)
                                this[keys[i]] = properties[keys[i]];
                }

                /**
                 * Any type_url.
                 * @member {string} type_url
                 * @memberof google.protobuf.Any
                 * @instance
                 */
                Any.prototype.type_url = "";

                /**
                 * Any value.
                 * @member {Uint8Array} value
                 * @memberof google.protobuf.Any
                 * @instance
                 */
                Any.prototype.value = $util.newBuffer([]);

                /**
                 * Creates a new Any instance using the specified properties.
                 * @function create
                 * @memberof google.protobuf.Any
                 * @static
                 * @param {google.protobuf.IAny=} [properties] Properties to set
                 * @returns {google.protobuf.Any} Any instance
                 */
                Any.create = function create(properties) {
                    return new Any(properties);
                };

                /**
                 * Encodes the specified Any message. Does not implicitly {@link google.protobuf.Any.verify|verify} messages.
                 * @function encode
                 * @memberof google.protobuf.Any
                 * @static
                 * @param {google.protobuf.IAny} message Any message or plain object to encode
                 * @param {$protobuf.Writer} [writer] Writer to encode to
                 * @returns {$protobuf.Writer} Writer
                 */
                Any.encode = function encode(message, writer) {
                    if (!writer)
                        writer = $Writer.create();
                    if (message.type_url != null && message.hasOwnProperty("type_url"))
                        writer.uint32(/* id 1, wireType 2 =*/10).string(message.type_url);
                    if (message.value != null && message.hasOwnProperty("value"))
                        writer.uint32(/* id 2, wireType 2 =*/18).bytes(message.value);
                    return writer;
                };

                /**
                 * Encodes the specified Any message, length delimited. Does not implicitly {@link google.protobuf.Any.verify|verify} messages.
                 * @function encodeDelimited
                 * @memberof google.protobuf.Any
                 * @static
                 * @param {google.protobuf.IAny} message Any message or plain object to encode
                 * @param {$protobuf.Writer} [writer] Writer to encode to
                 * @returns {$protobuf.Writer} Writer
                 */
                Any.encodeDelimited = function encodeDelimited(message, writer) {
                    return this.encode(message, writer).ldelim();
                };

                /**
                 * Decodes an Any message from the specified reader or buffer.
                 * @function decode
                 * @memberof google.protobuf.Any
                 * @static
                 * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
                 * @param {number} [length] Message length if known beforehand
                 * @returns {google.protobuf.Any} Any
                 * @throws {Error} If the payload is not a reader or valid buffer
                 * @throws {$protobuf.util.ProtocolError} If required fields are missing
                 */
                Any.decode = function decode(reader, length) {
                    if (!(reader instanceof $Reader))
                        reader = $Reader.create(reader);
                    var end = length === undefined ? reader.len : reader.pos + length, message = new $root.google.protobuf.Any();
                    while (reader.pos < end) {
                        var tag = reader.uint32();
                        switch (tag >>> 3) {
                            case 1:
                                message.type_url = reader.string();
                                break;
                            case 2:
                                message.value = reader.bytes();
                                break;
                            default:
                                reader.skipType(tag & 7);
                                break;
                        }
                    }
                    return message;
                };

                /**
                 * Decodes an Any message from the specified reader or buffer, length delimited.
                 * @function decodeDelimited
                 * @memberof google.protobuf.Any
                 * @static
                 * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
                 * @returns {google.protobuf.Any} Any
                 * @throws {Error} If the payload is not a reader or valid buffer
                 * @throws {$protobuf.util.ProtocolError} If required fields are missing
                 */
                Any.decodeDelimited = function decodeDelimited(reader) {
                    if (!(reader instanceof $Reader))
                        reader = new $Reader(reader);
                    return this.decode(reader, reader.uint32());
                };

                /**
                 * Verifies an Any message.
                 * @function verify
                 * @memberof google.protobuf.Any
                 * @static
                 * @param {Object.<string,*>} message Plain object to verify
                 * @returns {string|null} `null` if valid, otherwise the reason why it is not
                 */
                Any.verify = function verify(message) {
                    if (typeof message !== "object" || message === null)
                        return "object expected";
                    if (message.type_url != null && message.hasOwnProperty("type_url"))
                        if (!$util.isString(message.type_url))
                            return "type_url: string expected";
                    if (message.value != null && message.hasOwnProperty("value"))
                        if (!(message.value && typeof message.value.length === "number" || $util.isString(message.value)))
                            return "value: buffer expected";
                    return null;
                };

                /**
                 * Creates an Any message from a plain object. Also converts values to their respective internal types.
                 * @function fromObject
                 * @memberof google.protobuf.Any
                 * @static
                 * @param {Object.<string,*>} object Plain object
                 * @returns {google.protobuf.Any} Any
                 */
                Any.fromObject = function fromObject(object) {
                    if (object instanceof $root.google.protobuf.Any)
                        return object;
                    var message = new $root.google.protobuf.Any();
                    if (object.type_url != null)
                        message.type_url = String(object.type_url);
                    if (object.value != null)
                        if (typeof object.value === "string")
                            $util.base64.decode(object.value, message.value = $util.newBuffer($util.base64.length(object.value)), 0);
                        else if (object.value.length)
                            message.value = object.value;
                    return message;
                };

                /**
                 * Creates a plain object from an Any message. Also converts values to other types if specified.
                 * @function toObject
                 * @memberof google.protobuf.Any
                 * @static
                 * @param {google.protobuf.Any} message Any
                 * @param {$protobuf.IConversionOptions} [options] Conversion options
                 * @returns {Object.<string,*>} Plain object
                 */
                Any.toObject = function toObject(message, options) {
                    if (!options)
                        options = {};
                    var object = {};
                    if (options.defaults) {
                        object.type_url = "";
                        if (options.bytes === String)
                            object.value = "";
                        else {
                            object.value = [];
                            if (options.bytes !== Array)
                                object.value = $util.newBuffer(object.value);
                        }
                    }
                    if (message.type_url != null && message.hasOwnProperty("type_url"))
                        object.type_url = message.type_url;
                    if (message.value != null && message.hasOwnProperty("value"))
                        object.value = options.bytes === String ? $util.base64.encode(message.value, 0, message.value.length) : options.bytes === Array ? Array.prototype.slice.call(message.value) : message.value;
                    return object;
                };

                /**
                 * Converts this Any to JSON.
                 * @function toJSON
                 * @memberof google.protobuf.Any
                 * @instance
                 * @returns {Object.<string,*>} JSON object
                 */
                Any.prototype.toJSON = function toJSON() {
                    return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
                };

                return Any;
            })();

            return protobuf;
        })();

        return google;
    })();

    module.exports = $root;
}