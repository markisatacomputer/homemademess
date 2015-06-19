/* global io */
'use strict';

angular.module('hmm2App')
  .factory('socket', function(socketFactory) {

    // socket.io now auto-configures its connection when we ommit a connection url
    var ioSocket = io('', {
      // Send auth token on connection, you will need to DI the Auth service above
      // 'query': 'token=' + Auth.getToken()
      path: '/socket.io-client'
    });

    var socket = socketFactory({
      ioSocket: ioSocket
    });

    return {
      socket: socket,

      /**
       * Register listeners to sync an array with updates on a model
       *
       * Takes the array we want to sync, the model name that socket updates are sent from,
       * and an optional callback function after new items are updated.
       *
       * @param {String} modelName
       * @param {Array} array
       * @param {Function} cb
       */
      syncUpdates: function (modelName, array, cb) {
        cb = cb || angular.noop;

        /**
         * Syncs item creation/updates on 'model:save'
         */
        socket.on(modelName + ':save', function (item) {
          var oldItem = _.find(array, {_id: item._id});
          var index = array.indexOf(oldItem);
          var event = 'created';

          // replace oldItem if it exists
          // otherwise just add item to the collection
          if (oldItem) {
            array.splice(index, 1, item);
            event = 'updated';
          } else {
            array.push(item);
          }

          cb(event, item, array);
        });

        /**
         * Syncs removed items on 'model:remove'
         */
        socket.on(modelName + ':remove', function (item) {
          var event = 'deleted';
          _.remove(array, {_id: item._id});
          cb(event, item, array);
        });
      },

      /*
      Register listeners to sync an object with updates on a model
      
      Takes the object we want to sync, the model name that socket updates are sent from,
      and an optional callback function after new items are updated.
      
      @param {String} modelName
      @param {Object} obj
      @param {Function} cb
       */
      syncUpdatesObj: function(modelName, obj, cb) {
        cb = cb || angular.noop;
        /*
        Syncs item creation/updates on 'model:save'
         */
        socket.on(modelName + ':save', function(item) {
          var event;
          if (obj[item._id]) {
            event = 'updated';
          } else {
            event = 'created';
          }
          obj[item._id] = item;
          cb(event, item, obj);
        });

        /*
        Syncs removed items on 'model:remove'
         */
        return socket.on(modelName + ':remove', function(item) {
          var event;
          event = 'deleted';
          delete obj[item._id];
          cb(event, item, obj);
        });
      },

      /*
      Register listeners to sync an array with updates on a model
      
      Takes the array we want to sync, the model name that socket updates are sent from,
      and an optional callback function after new items are updated.
      
      @param {String} id
      @param {Object} obj
      @param {Function} cb
       */
      syncUploadProgress: function(id, obj, cb) {
        cb = cb || angular.noop;
        /*
        Syncs original upload progress on 'id:progress'
         */
        socket.on(id+':progress', function(item) {
          var event = 'progress';
          obj[id] = item;
          cb(event, item, obj);
        });

        /*
        Syncs removed items on 'id:complete'
         */
        return socket.on(id + ':complete', function(item) {
          var event;
          event = 'complete';
          obj[id] = 100;//delete obj[id];
          cb(event, item, obj);
        });
      },

      /**
       * Removes listeners for a models updates on the socket
       *
       * @param modelName
       */
      unsyncUpdates: function (modelName) {
        socket.removeAllListeners(modelName + ':save');
        socket.removeAllListeners(modelName + ':remove');
      }
    };
  });
