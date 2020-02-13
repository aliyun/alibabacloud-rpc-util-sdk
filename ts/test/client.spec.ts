'use strict';

import BaseClient from "../src/client";
import { RuntimeObject, FileField } from '../src/client';
import * as $tea from "@alicloud/tea-typescript";
import { createServer, Server, IncomingMessage } from 'http';
import { Readable } from 'stream';
import { platform, arch } from 'os';
import { request } from 'httpx';
import rewire from 'rewire';
import 'mocha';
import assert from 'assert';
const pkg = require('../package.json');

async function read(readable: Readable): Promise<string> {
  const buffers = [];
  for await (const chunk of readable) {
    buffers.push(chunk);
  }
  return Buffer.concat(buffers).toString();
}

describe('base client', function () {
  let server: Server;
  const testXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n' +
    '<root>\n' +
    '  <Owner>\n' +
    '    <ID>1325847523475998</ID>\n' +
    '    <DisplayName>1325847523475998</DisplayName>\n' +
    '  </Owner>\n' +
    '  <AccessControlList>\n' +
    '    <Grant>public-read</Grant>\n' +
    '  </AccessControlList>\n' +
    '</root>';
  const errorXml = '<Error>\
    <Code>AccessForbidden</Code>\
    <Message>CORSResponse: CORS is not enabled for this bucket.</Message>\
    <RequestId>5DECB1F6F3150D373335D8D2</RequestId>\
    <HostId>sdk-oss-test.oss-cn-hangzhou.aliyuncs.com</HostId>\
  </Error>';
  before((done) => {
    server = createServer((req, res) => {
      if (req.method == 'POST') {
        res.writeHead(200, { 'Content-Type': 'application/xml' });
        res.end(errorXml);
      } else if (req.method == 'GET') {
        res.writeHead(200, { 'Content-Type': 'application/xml' });
        res.end(testXml);
      } else if (req.method == 'PUT') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ test: 'test' }));
      } else {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end('test');
      }
    }).listen(8848, () => {
      done();
    });
  });

  it('readAsString should ok', async function () {
    const readableData = Readable.from("readable test")
    assert.strictEqual(await BaseClient.readAsString(readableData), 'readable test');
    assert.strictEqual(await BaseClient.readAsString(undefined), '');
  });

  it('getEndpoint should ok', async function () {
    const endpoint1 = BaseClient.getEndpoint("common.aliyuncs.com", true, "internal")
    assert.strictEqual("common-internal.aliyuncs.com", endpoint1)

    const endpoint2 = BaseClient.getEndpoint("common.aliyuncs.com", true, "accelerate")
    assert.strictEqual("oss-accelerate.aliyuncs.com", endpoint2)

    const endpoint3 = BaseClient.getEndpoint("common.aliyuncs.com", true, "")
    assert.strictEqual("common.aliyuncs.com", endpoint3)
  });

  it('getHost should ok', async function () {
    const host = BaseClient.getHost('', '', 'client.aliyuncs.com');
    assert.strictEqual(host, 'client.aliyuncs.com')
  });

  it('convert should ok', async function () {
    let inputModel: $tea.Model = new $tea.Model;
    inputModel.test = 'test';
    let outputModel: $tea.Model = new $tea.Model;
    outputModel.test = 'out';
    BaseClient.convert(inputModel, outputModel);
    assert.strictEqual(outputModel.test, 'test')
  });

  it('getNonce should ok', async function () {
    const nonce = BaseClient.getNonce();
    assert.strictEqual(nonce.length, 32)
  });

  it('getSignature should ok', async function () {
    let req = new $tea.Request();
    req.method = 'GET';
    req.headers['date'] = 'Wed, 11 Dec 2019 10:33:08 GMT';
    req.headers['x-oss-test'] = 'test';
    req.pathname = '/';
    req.query = {
      location: 'hangzhou',
    };
    let sign = BaseClient.getSignature(req, 'accessKeySecret');
    assert.strictEqual(sign, 'YIXsGwFhrzkXBid55ND2rbs/EYk=');
  });

  it('json should ok', async function () {
    const res = await request('http://127.0.0.1:8848', { method: 'PUT' });
    const teaRes = new $tea.Response(res);
    const data = await BaseClient.json(teaRes);
    assert.deepEqual(data, { test: 'test' })
    const res2 = await request('http://127.0.0.1:8848', { method: 'DELETE' });
    const teaRes2 = new $tea.Response(res2);
    const data2 = await BaseClient.json(teaRes2);
    assert.deepEqual(data2, {})
  });

  it('hasError should ok', async function () {
    assert.strictEqual(BaseClient.hasError({ Code: 200 }), false)
    assert.strictEqual(BaseClient.hasError({}), true)
    assert.strictEqual(BaseClient.hasError(undefined), true)
    assert.strictEqual(BaseClient.hasError({ Code: undefined }), true)
    assert.strictEqual(BaseClient.hasError({ Code: null }), true)
  });

  it('getTimestamp should ok', async function () {
    assert.ok(BaseClient.getTimestamp())
  });

  it('query should ok', async function () {
    const data: { [key: string]: any } = {
      val1: 'string',
      val2: undefined,
      val3: null,
      val4: 1,
      val5: true
    };
    assert.deepStrictEqual(BaseClient.query(data), {
      Val1: 'string',
      Val2: '',
      Val3: '',
      Val4: '1',
      Val5: 'true'
    });
    assert.deepStrictEqual(BaseClient.query(undefined), {});
  });

  it('default should ok', async function () {
    assert.strictEqual(BaseClient.default('sdk-oss-test', 'sdk-oss-test2'), 'sdk-oss-test');
    assert.strictEqual(BaseClient.default(undefined, 'sdk-oss-test2'), 'sdk-oss-test2');
  });

  it('defaultNumber should ok', async function () {
    assert.strictEqual(BaseClient.defaultNumber(0, 1), 0);
    assert.strictEqual(BaseClient.defaultNumber(undefined, 1), 1);
  });

  it('getUserAgent should ok', async function () {
    assert.strictEqual(BaseClient.getUserAgent(''), `Node.js(${process.version}), @alicloud/rpc-util: ${pkg.version}`);
    assert.strictEqual(BaseClient.getUserAgent('ua'), `Node.js(${process.version}), @alicloud/rpc-util: ${pkg.version} ua`);
  });

  it('getDate should ok', async function () {
    const date = BaseClient.getDate();
    assert.ok(date);
  });

  it('parseXml should ok', async function () {
    class GetBucketAclResponseAccessControlPolicyAccessControlList extends $tea.Model {
      grant: string;
      static names(): { [key: string]: string } {
        return {
          grant: 'Grant',
        };
      }

      static types(): { [key: string]: any } {
        return {
          grant: 'string',
        };
      }

      constructor(map: { [key: string]: any }) {
        super(map);
      }

    }

    class GetBucketAclResponseAccessControlPolicyOwner extends $tea.Model {
      iD: string;
      displayName: string;
      static names(): { [key: string]: string } {
        return {
          iD: 'ID',
          displayName: 'DisplayName',
        };
      }

      static types(): { [key: string]: any } {
        return {
          iD: 'string',
          displayName: 'string',
        };
      }

      constructor(map: { [key: string]: any }) {
        super(map);
      }

    }

    class GetBucketAclResponseAccessControlPolicy extends $tea.Model {
      owner: GetBucketAclResponseAccessControlPolicyOwner;
      accessControlList: GetBucketAclResponseAccessControlPolicyAccessControlList;
      static names(): { [key: string]: string } {
        return {
          owner: 'Owner',
          accessControlList: 'AccessControlList',
        };
      }

      static types(): { [key: string]: any } {
        return {
          owner: GetBucketAclResponseAccessControlPolicyOwner,
          accessControlList: GetBucketAclResponseAccessControlPolicyAccessControlList,
        };
      }

      constructor(map: { [key: string]: any }) {
        super(map);
      }

    }

    class GetBucketAclResponse extends $tea.Model {
      accessControlPolicy: GetBucketAclResponseAccessControlPolicy;
      static names(): { [key: string]: string } {
        return {
          accessControlPolicy: 'root',
        };
      }

      static types(): { [key: string]: any } {
        return {
          accessControlPolicy: GetBucketAclResponseAccessControlPolicy,
        };
      }

      constructor(map: { [key: string]: any }) {
        super(map);
      }
    }

    const data = {
      root: {
        Owner: { ID: '1325847523475998', DisplayName: '1325847523475998' },
        AccessControlList: { Grant: 'public-read' },
      },
    };
    assert.deepStrictEqual(BaseClient.parseXml(testXml, GetBucketAclResponse), data);
    assert.ok(BaseClient.parseXml(errorXml, GetBucketAclResponse));
    try {
      BaseClient.parseXml('ddsfadf', GetBucketAclResponse)
    } catch (err) {
      assert.ok(err);
      return;
    }
    assert.ok(false);
  });

  it('_xmlCast should ok', async function () {
    const data: { [key: string]: any } = {
      boolean: false,
      boolStr: 'true',
      number: 1,
      NaNNumber: null,
      NaN: undefined,
      string: 'string',
      array: ['string1', 'string2'],
      notArray: 'string',
      emptyArray: undefined,
      classArray: [{
        string: 'string',
      }, {
        string: 'string'
      }],
      classMap: '',
      map: {
        string: 'string',
      }
    };

    class TestSubModel extends $tea.Model {
      string: string;
      static names(): { [key: string]: string } {
        return {
          string: 'string',
        };
      }

      static types(): { [key: string]: any } {
        return {
          string: 'string',
        };
      }

      constructor(map: { [key: string]: any }) {
        super(map);
      }
    }

    class TestModel extends $tea.Model {
      boolean: boolean;
      boolStr: boolean;
      string: string;
      number: number;
      NaNNumber: number;
      array: string[];
      emptyArray: string[];
      notArray: string[];
      map: { [key: string]: any };
      classArray: TestSubModel[];
      classMap: TestSubModel;
      static names(): { [key: string]: string } {
        return {
          boolean: 'boolean',
          boolStr: 'boolStr',
          string: 'string',
          number: 'number',
          NaNNumber: 'NaNNumber',
          array: 'array',
          emptyArray: 'emptyArray',
          notArray: 'notArray',
          map: 'map',
          classArray: 'classArray',
          classMap: 'classMap',
        };
      }

      static types(): { [key: string]: any } {
        return {
          boolean: 'boolean',
          boolStr: 'boolean',
          string: 'string',
          number: 'number',
          NaNNumber: 'number',
          array: { type: 'array', itemType: 'string' },
          emptyArray: { type: 'array', itemType: 'string' },
          notArray: { type: 'array', itemType: 'string' },
          map: 'map',
          classArray: { type: 'array', itemType: TestSubModel },
          classMap: TestSubModel,
        };
      }

      constructor(map: { [key: string]: any }) {
        super(map);
      }
    }

    assert.deepStrictEqual(BaseClient._xmlCast(data, TestModel), {
      "boolean": false,
      "boolStr": true,
      "number": 1,
      "NaNNumber": NaN,
      "string": 'string',
      "array": ['string1', 'string2'],
      "classArray": [{
        "string": 'string',
      }, {
        "string": 'string'
      }],
      "notArray": ['string'],
      "emptyArray": [],
      "classMap": {
        "string": ''
      },
      "map": {
        "string": 'string',
      }
    });
  });

  it('toForm should ok', async function () {
    const result = await read(BaseClient.toForm({
      stringkey: 'string',
      file: new FileField({
        filename: 'fakefilename',
        contentType: 'application/json',
        content: new $tea.BytesReadable(`{"key":"value"}\n`)
      }),
    }, new $tea.BytesReadable(`{"key":"value"}\n`), 'boundary'));
    assert.deepStrictEqual(result, '--boundary\r\n'
      + 'Content-Disposition: form-data; name="stringkey"\r\n\r\n'
      + 'string\r\n'
      + '--boundary\r\n'
      + 'Content-Disposition: form-data; name="file"; filename=fakefilename\r\n'
      + 'Content-Type: application/json\r\n'
      + '\r\n'
      + '{"key":"value"}\n'
      + '\r\n'
      + '--boundary--\r\n');
  });

  it('getErrMessage should ok', async function () {
    const res = await request('http://127.0.0.1:8848', { method: 'POST' });
    const teaRes = new $tea.Response(res);
    const xml = await BaseClient.readAsString(teaRes.body);
    assert.deepStrictEqual(await BaseClient.getErrMessage(xml), {
      Code: 'AccessForbidden',
      Message: 'CORSResponse: CORS is not enabled for this bucket.',
      RequestId: '5DECB1F6F3150D373335D8D2',
      HostId: 'sdk-oss-test.oss-cn-hangzhou.aliyuncs.com',
    });
  });

  it('isFail should ok', async function () {
    const res = await request('http://127.0.0.1:8848', { method: 'GET' });
    const teaRes = new $tea.Response(res);
    assert.strictEqual(await BaseClient.isFail(teaRes), false);
  });

  it('getBoundary should ok', async function () {
    const Boundary1 = BaseClient.getBoundary();
    const Boundary2 = BaseClient.getBoundary();
    assert.notEqual(Boundary1, Boundary2);
  });

  it('empty should ok', async function () {
    assert.strictEqual(BaseClient.empty(''), true)
    assert.strictEqual(BaseClient.empty('oss'), false)
    assert.strictEqual(BaseClient.empty(undefined), true)
  });

  it('equal should ok', async function () {
    assert.strictEqual(BaseClient.equal('1', '1'), true)
    assert.strictEqual(BaseClient.equal('1', ''), false)
  });

  after(() => {
    server.close();
  });
});

describe('runtimeObject', function () {
  it('it should ok', async function () {
    assert.ok(new RuntimeObject());
    assert.ok(RuntimeObject.names());
    assert.ok(RuntimeObject.types());
  });
});

describe('private methods', function () {
  const client = rewire('../src/client');

  it('replaceRepeatList should ok', function () {
    const replaceRepeatList = client.__get__('replaceRepeatList');
    function helper(target: any, key: any, repeat: any) {
      replaceRepeatList(target, key, repeat);
      return target;
    }
    assert.deepEqual(helper({}, 'key', []), {})
    assert.deepEqual(helper({}, 'key', ['value']), {
      'key.1': 'value'
    })
    assert.deepEqual(helper({}, 'key', [{
      Domain: '1.com'
    }]), {
      'key.1.Domain': '1.com'
    })
  });

  it('flatParams should ok', function () {
    const flatParams = client.__get__('flatParams');
    assert.deepEqual(flatParams({}), {})
    assert.deepEqual(flatParams({ key: ['value'] }), { 'key.1': 'value' })
    assert.deepEqual(flatParams({ 'key': 'value' }), { 'key': 'value' })
    assert.deepEqual(flatParams({
      key: [
        {
          Domain: '1.com'
        }
      ]
    }), { 'key.1.Domain': '1.com' })
  });

  it('canonicalize should ok', function () {
    const canonicalize = client.__get__('canonicalize');
    assert.strictEqual(canonicalize([]), '');
    assert.strictEqual(canonicalize([
      ['key.1', 'value']
    ]), 'key.1=value');
    assert.strictEqual(canonicalize([
      ['key', 'value']
    ]), 'key=value')
    assert.strictEqual(canonicalize([
      ['key.1.Domain', '1.com']
    ]), 'key.1.Domain=1.com');
    assert.strictEqual(canonicalize([
      ['a', 'value'],
      ['b', 'value'],
      ['c', 'value']
    ]), 'a=value&b=value&c=value')
  });
});

describe('FileField', function () {
  it('should ok', async function () {
    assert.ok(new FileField)
  });
  it('getNames should ok', async function () {
    assert.deepEqual(FileField.names(), {
      filename: 'filename',
      contentType: 'contentType',
      content: 'content',
    })
  });
  it('getTypes should ok', async function () {
    assert.deepEqual(FileField.types(), {
      filename: 'string',
      contentType: 'string',
      content: 'Readable',
    })
  });
});
