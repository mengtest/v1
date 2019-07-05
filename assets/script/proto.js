/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 14:21:06
 * @LastEditTime: 2019-07-05 11:18:55
 */
/*eslint-disable block-scoped-var, id-length, no-control-regex, no-magic-numbers, no-prototype-builtins, no-redeclare, no-shadow, no-var, sort-vars*/
"use strict";

if (!CC_EDITOR) {



    var $protobuf = protobuf;

    // Common aliases
    var $Reader = $protobuf.Reader, $Writer = $protobuf.Writer, $util = $protobuf.util;

    // Exported root namespace
    var $root = $protobuf.roots["default"] || ($protobuf.roots["default"] = {});

    $root.PbLobby = (function () {

        /**
         * Namespace PbLobby.
         * @exports PbLobby
         * @namespace
         */
        var PbLobby = {};

        PbLobby.VersionContent = (function () {

            /**
             * Properties of a VersionContent.
             * @memberof PbLobby
             * @interface IVersionContent
             * @property {string|null} [game] VersionContent game
             * @property {string|null} [version] VersionContent version
             */

            /**
             * Constructs a new VersionContent.
             * @memberof PbLobby
             * @classdesc Represents a VersionContent.
             * @implements IVersionContent
             * @constructor
             * @param {PbLobby.IVersionContent=} [properties] Properties to set
             */
            function VersionContent(properties) {
                if (properties)
                    for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                        if (properties[keys[i]] != null)
                            this[keys[i]] = properties[keys[i]];
            }

            /**
             * VersionContent game.
             * @member {string} game
             * @memberof PbLobby.VersionContent
             * @instance
             */
            VersionContent.prototype.game = "";

            /**
             * VersionContent version.
             * @member {string} version
             * @memberof PbLobby.VersionContent
             * @instance
             */
            VersionContent.prototype.version = "";

            /**
             * Creates a new VersionContent instance using the specified properties.
             * @function create
             * @memberof PbLobby.VersionContent
             * @static
             * @param {PbLobby.IVersionContent=} [properties] Properties to set
             * @returns {PbLobby.VersionContent} VersionContent instance
             */
            VersionContent.create = function create(properties) {
                return new VersionContent(properties);
            };

            /**
             * Encodes the specified VersionContent message. Does not implicitly {@link PbLobby.VersionContent.verify|verify} messages.
             * @function encode
             * @memberof PbLobby.VersionContent
             * @static
             * @param {PbLobby.IVersionContent} message VersionContent message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            VersionContent.encode = function encode(message, writer) {
                if (!writer)
                    writer = $Writer.create();
                if (message.game != null && message.hasOwnProperty("game"))
                    writer.uint32(/* id 1, wireType 2 =*/10).string(message.game);
                if (message.version != null && message.hasOwnProperty("version"))
                    writer.uint32(/* id 2, wireType 2 =*/18).string(message.version);
                return writer;
            };

            /**
             * Encodes the specified VersionContent message, length delimited. Does not implicitly {@link PbLobby.VersionContent.verify|verify} messages.
             * @function encodeDelimited
             * @memberof PbLobby.VersionContent
             * @static
             * @param {PbLobby.IVersionContent} message VersionContent message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            VersionContent.encodeDelimited = function encodeDelimited(message, writer) {
                return this.encode(message, writer).ldelim();
            };

            /**
             * Decodes a VersionContent message from the specified reader or buffer.
             * @function decode
             * @memberof PbLobby.VersionContent
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @param {number} [length] Message length if known beforehand
             * @returns {PbLobby.VersionContent} VersionContent
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            VersionContent.decode = function decode(reader, length) {
                if (!(reader instanceof $Reader))
                    reader = $Reader.create(reader);
                var end = length === undefined ? reader.len : reader.pos + length, message = new $root.PbLobby.VersionContent();
                while (reader.pos < end) {
                    var tag = reader.uint32();
                    switch (tag >>> 3) {
                        case 1:
                            message.game = reader.string();
                            break;
                        case 2:
                            message.version = reader.string();
                            break;
                        default:
                            reader.skipType(tag & 7);
                            break;
                    }
                }
                return message;
            };

            /**
             * Decodes a VersionContent message from the specified reader or buffer, length delimited.
             * @function decodeDelimited
             * @memberof PbLobby.VersionContent
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @returns {PbLobby.VersionContent} VersionContent
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            VersionContent.decodeDelimited = function decodeDelimited(reader) {
                if (!(reader instanceof $Reader))
                    reader = new $Reader(reader);
                return this.decode(reader, reader.uint32());
            };

            /**
             * Verifies a VersionContent message.
             * @function verify
             * @memberof PbLobby.VersionContent
             * @static
             * @param {Object.<string,*>} message Plain object to verify
             * @returns {string|null} `null` if valid, otherwise the reason why it is not
             */
            VersionContent.verify = function verify(message) {
                if (typeof message !== "object" || message === null)
                    return "object expected";
                if (message.game != null && message.hasOwnProperty("game"))
                    if (!$util.isString(message.game))
                        return "game: string expected";
                if (message.version != null && message.hasOwnProperty("version"))
                    if (!$util.isString(message.version))
                        return "version: string expected";
                return null;
            };

            /**
             * Creates a VersionContent message from a plain object. Also converts values to their respective internal types.
             * @function fromObject
             * @memberof PbLobby.VersionContent
             * @static
             * @param {Object.<string,*>} object Plain object
             * @returns {PbLobby.VersionContent} VersionContent
             */
            VersionContent.fromObject = function fromObject(object) {
                if (object instanceof $root.PbLobby.VersionContent)
                    return object;
                var message = new $root.PbLobby.VersionContent();
                if (object.game != null)
                    message.game = String(object.game);
                if (object.version != null)
                    message.version = String(object.version);
                return message;
            };

            /**
             * Creates a plain object from a VersionContent message. Also converts values to other types if specified.
             * @function toObject
             * @memberof PbLobby.VersionContent
             * @static
             * @param {PbLobby.VersionContent} message VersionContent
             * @param {$protobuf.IConversionOptions} [options] Conversion options
             * @returns {Object.<string,*>} Plain object
             */
            VersionContent.toObject = function toObject(message, options) {
                if (!options)
                    options = {};
                var object = {};
                if (options.defaults) {
                    object.game = "";
                    object.version = "";
                }
                if (message.game != null && message.hasOwnProperty("game"))
                    object.game = message.game;
                if (message.version != null && message.hasOwnProperty("version"))
                    object.version = message.version;
                return object;
            };

            /**
             * Converts this VersionContent to JSON.
             * @function toJSON
             * @memberof PbLobby.VersionContent
             * @instance
             * @returns {Object.<string,*>} JSON object
             */
            VersionContent.prototype.toJSON = function toJSON() {
                return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
            };

            return VersionContent;
        })();

        PbLobby.User = (function () {

            /**
             * Properties of a User.
             * @memberof PbLobby
             * @interface IUser
             * @property {string|null} [message] User message
             * @property {boolean|null} [status] User status
             * @property {PbLobby.IVersionContent|null} [content] User content
             */

            /**
             * Constructs a new User.
             * @memberof PbLobby
             * @classdesc Represents a User.
             * @implements IUser
             * @constructor
             * @param {PbLobby.IUser=} [properties] Properties to set
             */
            function User(properties) {
                if (properties)
                    for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                        if (properties[keys[i]] != null)
                            this[keys[i]] = properties[keys[i]];
            }

            /**
             * User message.
             * @member {string} message
             * @memberof PbLobby.User
             * @instance
             */
            User.prototype.message = "";

            /**
             * User status.
             * @member {boolean} status
             * @memberof PbLobby.User
             * @instance
             */
            User.prototype.status = false;

            /**
             * User content.
             * @member {PbLobby.IVersionContent|null|undefined} content
             * @memberof PbLobby.User
             * @instance
             */
            User.prototype.content = null;

            /**
             * Creates a new User instance using the specified properties.
             * @function create
             * @memberof PbLobby.User
             * @static
             * @param {PbLobby.IUser=} [properties] Properties to set
             * @returns {PbLobby.User} User instance
             */
            User.create = function create(properties) {
                return new User(properties);
            };

            /**
             * Encodes the specified User message. Does not implicitly {@link PbLobby.User.verify|verify} messages.
             * @function encode
             * @memberof PbLobby.User
             * @static
             * @param {PbLobby.IUser} message User message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            User.encode = function encode(message, writer) {
                if (!writer)
                    writer = $Writer.create();
                if (message.message != null && message.hasOwnProperty("message"))
                    writer.uint32(/* id 1, wireType 2 =*/10).string(message.message);
                if (message.status != null && message.hasOwnProperty("status"))
                    writer.uint32(/* id 2, wireType 0 =*/16).bool(message.status);
                if (message.content != null && message.hasOwnProperty("content"))
                    $root.PbLobby.VersionContent.encode(message.content, writer.uint32(/* id 3, wireType 2 =*/26).fork()).ldelim();
                return writer;
            };

            /**
             * Encodes the specified User message, length delimited. Does not implicitly {@link PbLobby.User.verify|verify} messages.
             * @function encodeDelimited
             * @memberof PbLobby.User
             * @static
             * @param {PbLobby.IUser} message User message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            User.encodeDelimited = function encodeDelimited(message, writer) {
                return this.encode(message, writer).ldelim();
            };

            /**
             * Decodes a User message from the specified reader or buffer.
             * @function decode
             * @memberof PbLobby.User
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @param {number} [length] Message length if known beforehand
             * @returns {PbLobby.User} User
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            User.decode = function decode(reader, length) {
                if (!(reader instanceof $Reader))
                    reader = $Reader.create(reader);
                var end = length === undefined ? reader.len : reader.pos + length, message = new $root.PbLobby.User();
                while (reader.pos < end) {
                    var tag = reader.uint32();
                    switch (tag >>> 3) {
                        case 1:
                            message.message = reader.string();
                            break;
                        case 2:
                            message.status = reader.bool();
                            break;
                        case 3:
                            message.content = $root.PbLobby.VersionContent.decode(reader, reader.uint32());
                            break;
                        default:
                            reader.skipType(tag & 7);
                            break;
                    }
                }
                return message;
            };

            /**
             * Decodes a User message from the specified reader or buffer, length delimited.
             * @function decodeDelimited
             * @memberof PbLobby.User
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @returns {PbLobby.User} User
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            User.decodeDelimited = function decodeDelimited(reader) {
                if (!(reader instanceof $Reader))
                    reader = new $Reader(reader);
                return this.decode(reader, reader.uint32());
            };

            /**
             * Verifies a User message.
             * @function verify
             * @memberof PbLobby.User
             * @static
             * @param {Object.<string,*>} message Plain object to verify
             * @returns {string|null} `null` if valid, otherwise the reason why it is not
             */
            User.verify = function verify(message) {
                if (typeof message !== "object" || message === null)
                    return "object expected";
                if (message.message != null && message.hasOwnProperty("message"))
                    if (!$util.isString(message.message))
                        return "message: string expected";
                if (message.status != null && message.hasOwnProperty("status"))
                    if (typeof message.status !== "boolean")
                        return "status: boolean expected";
                if (message.content != null && message.hasOwnProperty("content")) {
                    var error = $root.PbLobby.VersionContent.verify(message.content);
                    if (error)
                        return "content." + error;
                }
                return null;
            };

            /**
             * Creates a User message from a plain object. Also converts values to their respective internal types.
             * @function fromObject
             * @memberof PbLobby.User
             * @static
             * @param {Object.<string,*>} object Plain object
             * @returns {PbLobby.User} User
             */
            User.fromObject = function fromObject(object) {
                if (object instanceof $root.PbLobby.User)
                    return object;
                var message = new $root.PbLobby.User();
                if (object.message != null)
                    message.message = String(object.message);
                if (object.status != null)
                    message.status = Boolean(object.status);
                if (object.content != null) {
                    if (typeof object.content !== "object")
                        throw TypeError(".PbLobby.User.content: object expected");
                    message.content = $root.PbLobby.VersionContent.fromObject(object.content);
                }
                return message;
            };

            /**
             * Creates a plain object from a User message. Also converts values to other types if specified.
             * @function toObject
             * @memberof PbLobby.User
             * @static
             * @param {PbLobby.User} message User
             * @param {$protobuf.IConversionOptions} [options] Conversion options
             * @returns {Object.<string,*>} Plain object
             */
            User.toObject = function toObject(message, options) {
                if (!options)
                    options = {};
                var object = {};
                if (options.defaults) {
                    object.message = "";
                    object.status = false;
                    object.content = null;
                }
                if (message.message != null && message.hasOwnProperty("message"))
                    object.message = message.message;
                if (message.status != null && message.hasOwnProperty("status"))
                    object.status = message.status;
                if (message.content != null && message.hasOwnProperty("content"))
                    object.content = $root.PbLobby.VersionContent.toObject(message.content, options);
                return object;
            };

            /**
             * Converts this User to JSON.
             * @function toJSON
             * @memberof PbLobby.User
             * @instance
             * @returns {Object.<string,*>} JSON object
             */
            User.prototype.toJSON = function toJSON() {
                return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
            };

            return User;
        })();

        return PbLobby;
    })();

    module.exports = $root;
}