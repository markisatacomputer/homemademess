'use strict'

angular.module 'hmm2App'
.controller 'NavbarCtrl', ($scope, $location, Auth, $resource, $state, lodash, $q, $mdDialog, apiUrl) ->
  $scope.menu = [
    {
      label: 'home'
      src:   'home'
      action: 'go'
      arg:  'main'
    }
    {
      label: 'Upload'
      src:   'cloud_upload'
      action: 'go'
      arg:  'admin'
    }
    {
      label: 'Settings'
      src:   'settings'
      action:  'go'
      arg: 'settings'
    }
    {
      label: 'Log Out'
      src:   'exit_to_app'
      action:  'logout'
    }
  ]
  $scope.tags = []
  $scope.isLoggedIn = Auth.isLoggedIn
  $scope.isAdmin = Auth.isAdmin
  $scope.user = {}
  $scope.errors = {}
  $scope.navOpen = false
  
  $scope.login = (form) ->
    $scope.submitted = true
    if form.$valid
      # Logged in, redirect to home
      Auth.login
        email: $scope.user.email
        password: $scope.user.password
      .then ->
        $mdDialog.hide()
        $scope.navOpen = true
      .catch (err) ->
        $scope.errors.other = err.message

  $scope.loginOauth = (provider) ->
    $window.location.href = apiUrl + '/auth/' + provider

  $scope.logout = ->
    Auth.logout()

  $scope.loginDialog = () ->
    $mdDialog.show {
      clickOutsideToClose: true
      scope: $scope
      preserveScope: true
      templateUrl: '../../app/account/login/login.html'
      controller: ($scope, $mdDialog) ->
    }

  $scope.go = (there) ->
    $state.go there

  $scope.isActive = (route) ->
    #console.log $location.path()
    route is $location.path()

  #  Map tags to simple array
  $scope.mapTags = (tags) ->
    # return an array of unique values
    lodash.uniq lodash.map tags, '_id'
  
  #  Action to take when tags change
  Images = $resource apiUrl + '/images'
  $scope.redoSearch = () ->
    Images.get { tags: $scope.mapTags $scope.tags }, (result) ->
      $scope.view.images = result.images

  #  Autocomplete
  Auto = $resource apiUrl + '/auto'
  $scope.findTags = (value) ->
    return Auto.query({q:value}).$promise
