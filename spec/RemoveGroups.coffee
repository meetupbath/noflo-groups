noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-groups'

describe 'RemoveGroups component', ->
  c = null
  regexp = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'groups/RemoveGroups', (err, instance) ->
      return done err if err
      c = instance
      regexp = noflo.internalSocket.createSocket()
      ins = noflo.internalSocket.createSocket()
      c.inPorts.regexp.attach regexp
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'with no regexp', ->
    it 'should remove all groups', (done) ->
      expected = [
        'DATA matched'
        'DATA unmatched'
      ]
      received = []

      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.beginGroup 'abcd'
      ins.send 'matched'
      ins.endGroup()
      ins.beginGroup 'wxyz'
      ins.send 'unmatched'
      ins.endGroup()
      ins.disconnect()

  describe 'with a regexp', ->
    it 'should remove matching groups', (done) ->
      expected = [
        'DATA matched'
        '< wxyz'
        'DATA unmatched'
        '>'
      ]
      received = []

      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      regexp.send 'abc'

      ins.beginGroup 'abcd'
      ins.send 'matched'
      ins.endGroup()
      ins.beginGroup 'wxyz'
      ins.send 'unmatched'
      ins.endGroup()
      ins.disconnect()
