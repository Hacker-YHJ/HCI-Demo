_ = require './_util'
d3 = require 'd3'
Popout = require './popout.coffee'
class Graph
  vCharge = -2000
  vLinkDis = 160
  vNodes = [0...7].map (e) -> {idx: e}
  vNodeSize = 25
  color = d3.scale.category20()

  constructor: (svg) ->
    @height = window.innerHeight
    @width =  window.innerWidth - 64
    @$svg = document.getElementById svg
    @$svg = d3.select @$svg
      .attr 'width', @width
      .attr 'height', @height
    @popout = new Popout 'popout'
    @force = null
    @nodes = null
    @links = null
    @restLinks = 6
    @vLinks = []
    @sP = null
    @eP = null

  init: =>
    funcPC = @onPointsClicked
    @force = d3.layout.force()
      .charge vCharge
      .linkDistance vLinkDis
      .size [@width, @height]
      .nodes vNodes
      .links @vLinks
      .start()

    @links = @$svg.selectAll '.link'
      .data @vLinks
      .enter()
      .append 'line'
      .attr 'class', 'link'
      .style 'stroke-width', 2

    @nodes = @$svg.selectAll '.node'
      .data vNodes
      .enter()
      .append 'circle'
      .attr 'class', 'node'
      .attr 'r', vNodeSize
      .style 'fill', -> color(~~(Math.random()*20))
      .on 'click', ->
        return if d3.event.defaultPrevented
        funcPC @
      .call @force.drag

    @force.on 'tick', =>
      @links.attr 'x1', (d) -> d.source.x
          .attr 'y1', (d) -> d.source.y
          .attr 'x2', (d) -> d.target.x
          .attr 'y2', (d) -> d.target.y

      @nodes.attr 'cx', (d) -> d.x
          .attr 'cy', (d) -> d.y

  isTree: =>
    visited = [0...7].map (e) -> false
    q = [0]
    while q.length > 0
      s = q.shift()
      visited[s] = true
      @links.data().forEach (e) ->
        if e.source.idx is s and visited[e.target.idx] is false
          q.push e.target.idx
        else if e.target.idx is s and visited[e.source.idx] is false
          q.push e.source.idx
    visited = visited.filter (e) -> e is false
    !(visited.length > 0)

  resetLinks: =>
    @vLinks = []
    @restLinks = 6
    @force.links @vLinks
      .start()
    @$svg.selectAll '.link'
      .data @vLinks
      .exit()
      .remove()

  addLink: =>
    return if @restLinks is 0
    unless @sp? and @ep?
      console.error @sp, @ep
      return

    @sp.classList.remove 'active'
    @ep.classList.remove 'active'
    sIdx = d3.select(@sp).datum().idx
    eIdx = d3.select(@ep).datum().idx
    checkArr = @vLinks.filter (e) ->
      e.source.idx is sIdx and e.target.idx is eIdx \
      or e.source.idx is eIdx and e.target.idx is sIdx
    if checkArr.length > 0
      console.error 'same links'
      @sp = @ep = null
      return

    @restLinks--
    @vLinks.push
      source: sIdx
      target: eIdx
      value: 1
    @force.links @vLinks
      .start()
    @$svg.selectAll '.link'
      .data @vLinks
      .enter()
      .insert 'line', ':first-child'
      .attr 'class', 'link'
      .style 'stroke-width', 2
      # .attr 'marker-end', 'url(#arrow)'
    @links = @$svg.selectAll '.link'
    @sp = @ep = null

    if @restLinks is 0
      if @isTree()
        @popout.addOnDismiss @pivotMax
        _.delayFunc 1000, =>
          @popout.pop 'Congrat!', 'This is a perfect tree! Let\'s re-shape it a little bit.'
      else
        @popout.addOnDismiss @resetLinks
        _.delayFunc 1000, =>
          @popout.pop 'Oops!', 'Seems like you didn\'t build a tree, try again please :)'

  pivotMax: =>
    v = [0...7].map -> 0
    @links.data().forEach (e) ->
      v[e.source.idx]++
      v[e.target.idx]++
    ii = 0
    vMax = 0
    v.forEach (e, i) ->
      if vMax < e
        ii = i
        vMax = e
    @nodes.filter (d) -> d.idx is ii
      .attr 'cx', @width / 2
      .attr 'cy', 200
      .classed 'fixed', (d) =>
        d.px = d.x = @width / 2
        d.py = d.y = 200
        d.fixed = true
    @force.start()


  onPointsClicked: (p) =>
    return if @restLinks is 0
    if !@sp?
      p.classList.add 'active'
      @sp = p
    else if @sp is p
      p.classList.remove 'active'
      @sp = null
    else if !@ep?
      p.classList.add 'active'
      @ep = p
      @addLink()
    else return

  onResize: =>
    @height = window.innerHeight
    @width =  window.innerWidth - 64
    @$svg.attr 'width', @width
      .attr 'height', @height
    @nodes?.filter (d) -> d.fixed is true
      .attr 'cx', @width / 2
      .attr 'cy', 200
      .classed 'fixed', (d) =>
        d.px = d.x = @width / 2
        d.py = d.y = 200
        d.fixed = true
    @force?.size [@width, @height]
      .resume()

exports = module.exports = Graph
