'use strict'

angular.module 'hmm2App'
.controller 'MainCtrl', ($scope, $http, socket, apiUrl, $mdDialog) ->
  # init view
  $scope.view = {}
  
  $http.get(apiUrl + '/images').success (result) ->
    $scope.view.images = result.images
    $scope.view.tags = result.tags
    $scope.view.offset = 0;

  ###  This comes later - should we have inline editing
  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'thing'
  ###
  
  $scope.showSlide = (slide) ->
    console.log $scope.view.images[slide]
    $scope.slide = $scope.view.images[slide]
    $mdDialog.show {
      clickOutsideToClose: true
      scope: $scope
      preserveScope: true
      template: '<md-dialog>' +
                    '  <md-dialog-content>' +
                    '     <img src="{{slide.derivative[2].uri}}" width="{{vm.slide.derivative[2].width}}" class="img-responsive" />' +
                    '  </md-dialog-content>' +
                    '</md-dialog>'
      controller: ($scope, $mdDialog) ->
       $scope.closeDialog = () ->
          $mdDialog.hide()
    }
