'use strict'

angular.module 'hmm2App'
.config ($stateProvider) ->
  $stateProvider
  .state 'tagged',
    url: '/tagged/:tag'
    templateUrl: 'app/tagged/tagged.html'
    controller: 'TaggedCtrl'