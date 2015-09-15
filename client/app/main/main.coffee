'use strict'

angular.module 'hmm2App'
.config ($stateProvider) ->
  $stateProvider
  .state 'main',
    url: '/'
    templateUrl: 'app/main/main.html'
    controller: 'MainCtrl'
  .state 'main.tagged',
    url: '/tagged/:tag'
    templateUrl: 'app/main/main.tagged.html'
    controller: 'TaggedCtrl'
