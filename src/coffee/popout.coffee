_ = require './_util'
class Popout
  constructor: (elem) ->
    @$popout = document.getElementById elem
    @$main = @$popout.getElementsByTagName('main')[0]
    @$title = @$popout.getElementsByTagName('h1')[0]
    @$desc = @$popout.getElementsByTagName('p')[0]
    @onDismiss = []
    @hidden = true

  pop: (title, desc) =>
    return unless @hidden
    @hidden = false
    @$title.innerHTML = title
    @$desc.innerHTML = desc
    @$popout.style.display = 'block'
    _.delayFunc 400, =>
      @$popout.style.opacity = 1

  dismiss: =>
    return if @hidden
    @hidden = true
    @$popout.style.opacity = 0
    @onDismiss.forEach (f) ->
      f()
    @onDismiss = []
    _.delayFunc 400, =>
      @$popout.style.display = 'none'

  addOnDismiss: (func) =>
    @onDismiss.push func



exports = module.exports = Popout
