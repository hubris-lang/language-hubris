LanguageHubrisView = require './language-hubris-view'
{CompositeDisposable} = require 'atom'

module.exports = LanguageHubris =
  languageHubrisView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @languageHubrisView = new LanguageHubrisView(state.languageHubrisViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @languageHubrisView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'language-hubris:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @languageHubrisView.destroy()

  serialize: ->
    languageHubrisViewState: @languageHubrisView.serialize()

  toggle: ->
    console.log 'LanguageHubris was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
