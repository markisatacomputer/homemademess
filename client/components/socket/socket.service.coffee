# global io

'use strict'

angular.module 'hmm2App'
.factory 'socket', (socketFactory, hmmConfig) ->

  # socket.io now auto-configures its connection when we omit a connection url
  ioSocket = io '',
    # Send auth token on connection, you will need to DI the Auth service above
    # 'query': 'token=' + Auth.getToken()
    path: '/socket.io-client'

  socket = socketFactory ioSocket: ioSocket

  socket: socket

  ###
  Register listeners to sync an array with updates on a model

  Takes the array we want to sync, the model name that socket updates are sent from,
  and an optional callback function after new items are updated.

  @param {String} modelName
  @param {Array} array
  @param {Function} callback
  ###
  syncUpdates: (modelName, array, callback) ->

    ###
    Syncs item creation/updates on 'model:save'
    ###
    socket.on modelName + ':save', (item) ->
      oldItem = _.find array,
        _id: item._id

      index = array.indexOf oldItem
      event = 'created'

      # replace oldItem if it exists
      # otherwise just add item to the collection
      if oldItem
        array.splice index, 1, item
        event = 'updated'
      else
        array.push item

      callback? event, item, array

    ###
    Syncs removed items on 'model:remove'
    ###
    socket.on modelName + ':remove', (item) ->
      event = 'deleted'
      _.remove array,
        _id: item._id

      callback? event, item, array

  ###
  Register listeners to sync an array with updates on a model

  Takes the array we want to sync, the model name that socket updates are sent from,
  and an optional callback function after new items are updated.

  @param {String} modelName
  @param {Object} obj
  @param {Function} callback
  ###
  syncUpdatesObj: (modelName, obj, callback) ->

    ###
    Syncs item creation/updates on 'model:save'
    ###
    socket.on modelName + ':save', (item) ->
      
      console.log ':save', item
      # replace oldItem if it exists
      # otherwise just add item to the collection
      if obj[item._id]
        event = 'updated'
      else
        event = 'created'
      obj[item._id] = item

      callback? event, item, obj

    ###
    Syncs removed items on 'model:remove'
    ###
    socket.on modelName + ':remove', (item) ->
      event = 'deleted'
      delete obj[item._id]

      callback? event, item, obj

  ###
  Removes listeners for a models updates on the socket

  @param modelName
  ###
  unsyncUpdates: (modelName) ->
    socket.removeAllListeners modelName + ':save'
    socket.removeAllListeners modelName + ':remove'
