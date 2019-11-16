import Ajv from 'ajv'

import { Schema } from './interface'

import schema from './schema.json'

const ajv = new Ajv();
export const validate = ajv.compile(schema);

export { Schema }
