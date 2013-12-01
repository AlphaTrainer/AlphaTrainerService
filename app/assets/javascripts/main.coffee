# Remixed upon the niece examples of the "Backbone. js Cookbook" by Vadim Mirgorod
# http://goo.gl/LuAv3p
# 
# Just a log helper - though don't leave log stuff behind you :)
window.log = (args...) ->
  console.log.apply console, args if console.log?

# Extend Backbone Model to support MongoDB Extended JSON.
# NIECETOHAVE: move to new api 2.0 no BSON ids :)
Backbone.Model::parse = (resp, options) ->
  if _.isObject(resp._id)
    resp.id = resp._id.$oid
    delete resp._id
  resp

Backbone.Model::toJSON = ->
  attrs = _.omit(@attributes, "id")
  attrs._id = $oid: @id  unless _.isUndefined(@id)
  attrs

# Define configuration. - customized key
# new api dont load alpha_levels and raise limit from 100 to 500
appConfig =
  baseURL: 'https://data-api.mongolab.com/v2/apis/dk5jpmcf2g1bg/collections/trainings/documents?fields=' + encodeURIComponent('{"alpha_levels":0}') + '&limit=500'


# Create Polling collection
PollingCollection = Backbone.Collection.extend(
  polling: false

  # Set default interval in seconds
  interval: 1

  # Make all object methods to work from it's own context.
  initialize: ->
    # note: in newer back bone / underscore 1.5.2 its not enough with  
    # _.bindAll(this) meaning all functions should be applied - specify for now
    # https://github.com/jashkenas/underscore/issues/992
    _.bindAll(this, 'startPolling', 'stopPolling', 'executePolling', 'onFetch')


  # Starts polling.
  startPolling: (interval) ->
    @polling = true
    @interval = interval  if interval
    @executePolling()


  # Stops polling.
  stopPolling: ->
    @polling = false


  # Executs polling.
  executePolling: ->
    @fetch
      success: @onFetch
      error: @onFetch

  # Runs recursion.
  onFetch: ->
    setTimeout @executePolling, 1000 * @interval
)

# Define training model.
TrainingModel = Backbone.Model.extend(url: ->
  if _.isUndefined(@id)
    appConfig.baseURL
  else
    appConfig.baseURL + "?" + encodeURIComponent(@id)

# NIECETOHAVE: not sure about this part yes after the new api^^
#    appConfig.baseURL + appConfig.collectionsTrainings + "/" + encodeURIComponent(@id) + appConfig.addURL
# when the BSON nested ids are migrated then probably:
# appConfig.baseURL + "?" + encodeURIComponent('{"_id":'+@id+'}')
)

# Define training collection.
TrainingCollection = PollingCollection.extend(
  model: TrainingModel
  url: ->
    appConfig.baseURL
)

# Define new view to render a model.
# Backbone.View.extend(
# Lets sub class lay out manager instead to get the template feature and more
# Note: we dont use this sub view now because we ask service to ignore the
# alpha_levels - its heavy to load all - NIECETOHAVE find away to load on the fly for
# specific trainings.
TrainingView = Backbone.Layout.extend(

  className: 'panel panel-default'

  # Set selector for template.
  template: '#training-item'

  # Returns data for template.
  serialize: ->
    training: @model
    # "When you provide a collection or anything iterable, it is considered
    # a good practice to pass it as a wrapped (chained) underscore object."
    alphaLevels: _.chain(@model.get('alpha_levels'))

  # Bind callback to the model events.
  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "destroy", @remove

)

# Define new view to render a collection.
TrainingListView = Backbone.View.extend(

  className: 'recordingsWrapper'

  # Render view.
  render: ->
    $(@el).empty()

    # Append table  with a row.
    _.each @collection.models, ((model, key) ->
      @append model
    ), this
    this

  # Add training item row to the table.
  prepend: (model) ->
    $(@el).prepend new TrainingView(model: model).render().el

  # Remove model from collection.
  remove: (model) ->
    model.trigger "destroy"

  # Bind callbacks to the collection events.
  initialize: ->
    @listenTo @collection, "reset", @render, this
    @listenTo @collection, "add", @prepend, this
    @listenTo @collection, "remove", @remove, this
)
$(document).ready ->

  # Create collection
  collection = new TrainingCollection()

  # Create whole page view instance and render it.

  $(".row").append new TrainingListView(collection: collection).render().el
  collection.startPolling()

