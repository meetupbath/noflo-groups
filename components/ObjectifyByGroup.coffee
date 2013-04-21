noflo = require("noflo")
_s = require("underscore.string")

class ObjectifyByGroup extends noflo.Component

  description: _s.clean "specify a regexp string, use the `$1` of a
  matching group as the key of an object containing the data"

  constructor: ->
    @regexp = null
    @match = null

    @inPorts =
      in: new noflo.Port
      regexp: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.regexp.on "data", (regexp) =>
      @regexp = new RegExp(regexp)

    @inPorts.in.on "begingroup", (group) =>
      console.log("* AAA: #{group} | #{@regexp}")
      if @regexp? and group.match(@regexp)?
        console.log("* BBB")
        [original, match, rest...] = group.match(@regexp)
        @match = match
      else
        @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      console.log("* CCC: #{@match?}")
      # If there is a match, make an object out of it
      if @match?
        d = data
        data = {}
        data[@match] = d

      @outPorts.out.send(data)

    @inPorts.in.on "endgroup", (group) =>
      unless @regexp? and group.match(@regexp)?
        @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new ObjectifyByGroup
