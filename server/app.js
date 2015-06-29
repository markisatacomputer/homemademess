/**
 * Main application file
 */

'use strict';

// Set default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

//require('v8-profiler');
/*require('nodetime').profile({
  accountKey: '9dbb5b7ff0e42a8b33d111f6d8dfa057d7956897', 
  appName: 'hmm2'
});*/

var express = require('express');
var mongoose = require('mongoose');
var config = require('./config/environment');

// Connect to database
var connection = mongoose.connect(config.mongo.uri, config.mongo.options);

// Populate DB with sample data
if(config.seedDB) { require('./config/seed'); }

// Setup server
var app = express();
var server = require('http').createServer(app);
var socketio = require('socket.io')(server, {
  serveClient: (config.env === 'production') ? false : true,
  path: '/socket.io-client'
});
require('./config/socketio')(socketio);
require('./config/express')(app);
require('./routes')(app);

// Start server
server.listen(config.port, config.ip, function () {
  console.log('Express server listening on %d, in %s mode', config.port, app.get('env'));
  // Schedule cleanup
  require('./components/schedule');
});

// Expose app
exports = module.exports = app;