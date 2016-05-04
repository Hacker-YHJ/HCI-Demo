require '../stylus/main.styl'
_ = require './_util'
domready = require 'domready'
d3 = require 'd3'
Graph = require './graph.coffee'

graph = null

onResize = ->
  graph.onResize()

domready ->
  graph = new Graph 'board'
  window.addEventListener 'resize', onResize
  window.addEventListener 'click', graph.popout.dismiss
  graph.popout.addOnDismiss graph.init
  graph.popout.addOnDismiss () ->
    _.delayFunc 2000, () ->
      graph.popout.pop('Try to build a tree!', 'Click two nodes to connect them with edges. Use only SIX edges to connect all the nodes without forming a loop, then you will have a tree!')
  graph.popout.pop 'Welcome!', 'Welcome to lesson 1! We will show you some circles and let\'s call them nodes.'
