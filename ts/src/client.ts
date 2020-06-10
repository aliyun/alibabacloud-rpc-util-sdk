
import { Readable } from 'stream';
import * as $tea from '@alicloud/tea-typescript';
import * as kitx from "kitx";
import { Parser } from 'xml2js';
import { platform, arch } from 'os';
const DEFAULT_USER_AGENT = `AlibabaCloud (${platform()}; ${arch()}) Node.js/${process.version} Core/1.0.1 TeaDSL/1`;

function parseXML(body: string): any {
  let parser = new Parser({ explicitArray: false });
  let result: { [key: string]: any } = {};
  parser.parseString(body, function (err: any, output: any) {
    result.err = err;
    result.output = output;
  });
  if (result.err) {
    throw result.err;
  }

  return result.output;
}

function encode(str: string) {
  var result = encodeURIComponent(str);

  return result.replace(/!/g, '%21')
    .replace(/'/g, '%27')
    .replace(/\(/g, '%28')
    .replace(/\)/g, '%29')
    .replace(/\*/g, '%2A');
}

function replaceRepeatList(target: { [key: string]: string }, repeat: any[], prefix: string) {
  if (prefix) {
    prefix = prefix + '.';
  }
  for (var i = 0; i < repeat.length; i++) {
    var item = repeat[i];
    let key = prefix + (i + 1);
    if (typeof item === 'undefined' || item == null) {
      target[key] = '';
      continue;
    }
    if (Array.isArray(item)) {
      replaceRepeatList(target, item, key);
    } else if (item instanceof Object) {
      flatMap(target, item, key);
    } else {
      target[key] = item.toString();
    }
  }
}

function flatMap(target: { [key: string]: any }, params: { [key: string]: any }, prefix: string = '') {
  if (prefix) {
    prefix = prefix + '.';
  }
  let keys = Object.keys(params);
  for (let i = 0; i < keys.length; i++) {
    let key = keys[i];
    let value = params[key];
    key = prefix + key;
    if (typeof value === 'undefined' || value == null) {
      target[key] = '';
      continue;
    }

    if (Array.isArray(value)) {
      replaceRepeatList(target, value, key);
    } else if (value instanceof Object){ 
      flatMap(target, value, key);
    }else {
      target[key] = value.toString();
    }
  }
  return target;
}

function normalize(params: { [key: string]: any }) {
  var list = [];
  var flated: { [key: string]: string } = {};
  flatMap(flated, params);
  var keys = Object.keys(flated).sort();
  for (let i = 0; i < keys.length; i++) {
    var key = keys[i];
    var value = flated[key];
    list.push([encode(key), encode(value)]);
  }
  return list;
}

function canonicalize(normalized: any[]) {
  var fields = [];
  for (var i = 0; i < normalized.length; i++) {
    var [key, value] = normalized[i];
    fields.push(key + '=' + value);
  }
  return fields.join('&');
}

export class FileField extends $tea.Model {
  filename: string;
  contentType: string;
  content: Readable;
  static names(): { [key: string]: string } {
    return {
      filename: 'filename',
      contentType: 'contentType',
      content: 'content',
    };
  }

  static types(): { [key: string]: any } {
    return {
      filename: 'string',
      contentType: 'string',
      content: 'Readable',
    };
  }

  constructor(map?: { [key: string]: any }) {
    super(map);
  }
}

class FileFormStream extends Readable {
  form: { [key: string]: any };
  boundary: string;
  keys: string[];
  index: number;
  streaming: boolean;
  content: Readable;

  constructor(form: { [key: string]: any }, content: Readable, boundary: string) {
    super();
    this.form = form;
    this.keys = Object.keys(form);
    this.index = 0;
    this.boundary = boundary;
    this.streaming = false;
    this.content = content;
  }

  _read() {
    if (this.streaming) {
      return;
    }
    const separator = this.boundary;
    if (this.index < this.keys.length) {
      const name = this.keys[this.index];
      const fieldValue = this.form[name];
      if (name === 'file') {
        let body =
          `--${separator}\r\n` +
          `Content-Disposition: form-data; name="${name}"; filename=${fieldValue.filename}\r\n` +
          `Content-Type: ${fieldValue.contentType}\r\n\r\n`;
        this.push(Buffer.from(body));
        this.streaming = true;
        this.content.on('data', (chunk) => {
          this.push(chunk);
        });
        this.content.on('end', () => {
          this.index++;
          this.streaming = false;
        });
      } else {
        this.push(Buffer.from(`--${separator}\r\n` +
          `Content-Disposition: form-data; name="${name}"\r\n\r\n` +
          `${encodeURIComponent(fieldValue)}\r\n`));
        this.index++;
      }
    } else {
      this.push(Buffer.from(`\r\n--${separator}--\r\n`));
      this.push(null);
    }
  }
}

export class RuntimeObject extends $tea.Model {
  autoretry: boolean;
  ignoreSSL: boolean;
  maxAttempts: number;
  backoffPolicy: string;
  backoffPeriod: number;
  readTimeout: number;
  connectTimeout: number;
  httpProxy: string;
  httpsProxy: string;
  noProxy: string;
  maxIdleConns: number;
  static names(): { [key: string]: string } {
    return {
      autoretry: 'autoretry',
      ignoreSSL: 'ignoreSSL',
      maxAttempts: 'max_attempts',
      backoffPolicy: 'backoff_policy',
      backoffPeriod: 'backoff_period',
      readTimeout: 'readTimeout',
      connectTimeout: 'connectTimeout',
      httpProxy: 'httpProxy',
      httpsProxy: 'httpsProxy',
      noProxy: 'noProxy',
      maxIdleConns: 'maxIdleConns',
    };
  }

  static types(): { [key: string]: any } {
    return {
      autoretry: 'boolean',
      ignoreSSL: 'boolean',
      maxAttempts: 'number',
      backoffPolicy: 'string',
      backoffPeriod: 'number',
      readTimeout: 'number',
      connectTimeout: 'number',
      httpProxy: 'string',
      httpsProxy: 'string',
      noProxy: 'string',
      maxIdleConns: 'number',
    };
  }

  constructor(map?: { [key: string]: any }) {
    super(map);
  }
}


export default class Client {

  static async readAsString(body: Readable): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!body) {
        resolve('');
      }
      let result: string = '';
      body.on('data', (data) => {
        result += data;
      })
      body.on('end', () => {
        resolve(result);
      })
      body.on('err', (err) => {
        reject(err)
      })
    })
  }

  static getEndpoint(endpoint: string, serverUse: boolean, endpointType: string): string {
    if (endpointType == "internal") {
      let strs = endpoint.split(".");
      strs[0] += "-internal";
      endpoint = strs.join(".")
    }
    if (serverUse && endpointType == "accelerate") {
      return "oss-accelerate.aliyuncs.com"
    }

    return endpoint
  }

  static getHost(productId: string, regionId: string, endpoint: string): string {
    return endpoint;
  }

  static convert(input: $tea.Model, output: $tea.Model): void {
    if (!output) {
      return;
    }
    let inputModel = Object.assign({}, input);
    let constructor = <any>output.constructor;
    for (let key of Object.keys(constructor.names())) {
      if (inputModel[key]) {
        output[key] = inputModel[key];
      }
    }
  }

  static getNonce(): string {
    return kitx.makeNonce();
  }

  static getSignature(request: $tea.Request, secret: string): string {
    var method = (request.method || 'GET').toUpperCase();
    var normalized = normalize(request.query);
    var canonicalized = canonicalize(normalized);
    var stringToSign = `${method}&${encode('/')}&${encode(canonicalized)}`;
    const key = secret + '&';
    return <string>kitx.sha1(stringToSign, key, 'base64');
  }
  
  static getSignatureV1(query: { [key: string]: string }, method: string, secret: string): string {
    var normalized = normalize(query);
    var canonicalized = canonicalize(normalized);
    var stringToSign = `${method}&${encode('/')}&${encode(canonicalized)}`;
    const key = secret + '&';
    return <string>kitx.sha1(stringToSign, key, 'base64');
  }

  static async json(body: $tea.Response): Promise<{ [key: string]: any }> {
    let bytes = await body.readBytes();
    let content = bytes.toString();
    try {
      let result = JSON.parse(content);
      return result;
    } catch (err) {
      return {};
    }
  }

  static hasError(obj: { [key: string]: any }): boolean {
    if (!obj) {
      return true;
    }
    if (obj.Code && obj.Code !== '0') {
      return true
    }
    return false;
  }

  static getTimestamp(): string {
    let date = new Date();
    let YYYY = date.getUTCFullYear();
    let MM = kitx.pad2(date.getUTCMonth() + 1);
    let DD = kitx.pad2(date.getUTCDate());
    let HH = kitx.pad2(date.getUTCHours());
    let mm = kitx.pad2(date.getUTCMinutes());
    let ss = kitx.pad2(date.getUTCSeconds());
    return `${YYYY}-${MM}-${DD}T${HH}:${mm}:${ss}Z`;
  }

  static query(filter: { [key: string]: any }): { [key: string]: string } {
    if (!filter) {
      return {};
    }
    let ret: { [key: string]: string } = {};
    flatMap(ret, filter);
    return ret;
  }

  static default(real: string, default_: string): string {
    if (typeof real === 'undefined') {
      return default_;
    }
    return real;
  }

  static defaultNumber(real: number, default_: number): number {
    if (typeof real === 'undefined') {
      return default_;
    }
    return real;
  }

  static getUserAgent(userAgent: string): string {
    if (!userAgent || !userAgent.length) {
      return DEFAULT_USER_AGENT;
    }
    return DEFAULT_USER_AGENT + " " + userAgent;
  }
  static getDate(): string {
    let date = new Date();
    let YYYY = date.getUTCFullYear();
    let MM = kitx.pad2(date.getUTCMonth() + 1);
    let DD = kitx.pad2(date.getUTCDate());
    let HH = kitx.pad2(date.getUTCHours());
    let mm = kitx.pad2(date.getUTCMinutes());
    let ss = kitx.pad2(date.getUTCSeconds());
    return `${YYYY}-${MM}-${DD}T${HH}:${mm}:${ss}Z`;
  }


  static parseXml<T>(body: string, clazz: T): { [key: string]: any } {
    let ret: { [key: string]: any } = parseXML(body);
    if (typeof clazz !== 'undefined') {
      ret = this._xmlCast(ret, clazz);
    }
    return ret;
  }

  static _xmlCast<T>(obj: any, clazz: T): { [key: string]: any } {
    obj = obj || {};
    let ret: { [key: string]: any } = {};
    let clz = clazz as any;
    let names: { [key: string]: string } = clz.names();
    let types: { [key: string]: any } = clz.types();

    Object.keys(names).forEach((key) => {
      let originName = names[key];
      let value = obj[originName];
      let type = types[key];
      switch (type) {
        case 'boolean':
          if (!value) {
            ret[originName] = false;
            return;
          }
          ret[originName] = value === 'false' ? false : true;
          return;
        case 'number':
          if (value != 0 && !value) {
            ret[originName] = NaN;
            return;
          }
          ret[originName] = +value;
          return;
        case 'string':
          if (!value) {
            ret[originName] = '';
            return;
          }
          ret[originName] = value.toString();
          return;
        default:
          if (type.type === 'array') {
            if (!value) {
              ret[originName] = [];
              return;
            }
            if (!Array.isArray(value)) {
              value = [value];
            }
            if (typeof type.itemType === 'function') {
              ret[originName] = value.map((d: any) => {
                return this._xmlCast(d, type.itemType);
              });
            } else {
              ret[originName] = value;
            }
          } else if (typeof type === 'function') {
            if (!value) {
              value = {}
            }
            ret[originName] = this._xmlCast(value, type);
          } else {
            ret[originName] = value;
          }
      }
    })
    return ret;
  }

  static toForm(body: { [key: string]: any }, content: Readable, boundary: string): Readable {
    return new FileFormStream(body, content, boundary);
  }

  static getErrMessage(xml: string): { [key: string]: any } {
    let body: { [key: string]: any } = parseXML(xml);
    return body.Error || {};
  }

  static isFail(response: $tea.Response): boolean {
    return !response || response.statusCode < 200 || response.statusCode >= 300;
  }

  static getBoundary(): string {
    return kitx.makeNonce();
  }

  static empty(val: string): boolean {
    return !val;
  }

  static equal(val1: string, val2: string): boolean {
    return val1 === val2;
  }
  static getOpenPlatFormEndpoint(endpoint: string, regionId: string): string {
    const supportRegionId = ['ap-southeast-1', 'ap-northeast-1', 'eu-central-1', 'cn-hongkong', 'ap-south-1'];
    if (regionId && regionId.length && supportRegionId.indexOf(regionId.toLowerCase()) != -1) {
      let strs = endpoint.split('.');
      strs[0] = strs[0] + "." + regionId.toLowerCase();
      return strs.join(".");
    } else {
      return endpoint
    }
  }

}
