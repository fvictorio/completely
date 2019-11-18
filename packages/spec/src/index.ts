import Ajv from 'ajv'

import { Schema } from './interface'

import schema from './schema.json'

const ajv = new Ajv({ jsonPointers: true });
export const validate = ajv.compile(schema);

export { ajv, schema, Schema }
