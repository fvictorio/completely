"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ajv_1 = __importDefault(require("ajv"));
const schema_json_1 = __importDefault(require("./schema.json"));
const ajv = new ajv_1.default();
exports.validate = ajv.compile(schema_json_1.default);
//# sourceMappingURL=index.js.map