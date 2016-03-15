LanguageHubrisView = require './language-hubris-view'
{CompositeDisposable, Range, Point, BufferedProcess} = require 'atom'
request = require 'request'

module.exports = LanguageHubris =
  languageHubrisView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @languageHubrisView = new LanguageHubrisView(state.languageHubrisViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @languageHubrisView.getElement(), visible: false)

    # Start a Hubris process to communicate with.
    # Totally a hack atm, not finding hubris on the path, maybe should
    # look it up.
    command =
      '/Users/jroesch/.multirust/toolchains/nightly/cargo/bin/hubris'
    args = ['server']
    stdout = (output) -> console.log(output)
    exit = (code) -> console.log("hubris exited with #{code}")
    @process = new BufferedProcess({command, args, stdout, exit})
    console.log(process)

    # We begin at the start of the file
    @range_start = new Point(0, 0)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'language-hubris:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @languageHubrisView.destroy()
    # Make sure to clean up the server process when we close
    # the editor.
    @process.kill()

  serialize: ->
    languageHubrisViewState: @languageHubrisView.serialize()

  toggle: ->
    console.log 'LanguageHubris was toggled!'

    editor = atom.workspace.getActiveTextEditor()
    pos = editor.getCursorBufferPosition()
    range = new Range(@range_start, pos)

    if @marker?
      @marker.destroy()
    @marker = editor.markBufferRange(range, invalidate: 'inside')
    editor.decorateMarker(@marker, { type: 'line', class: 'prove-window'});

    text = editor.getTextInBufferRange(range)
    req =
      url: "http://localhost:3000/check"
      qs: { code: text }
    request.get req,
    (error, response, body) =>
      console.log(error)
      console.log("response:")
      console.log(response)
      console.log(body)
      # @range_start = pos
    # console.log(pos)
    # console.log(text)
