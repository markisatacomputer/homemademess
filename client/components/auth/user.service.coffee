'use strict'

angular.module 'hmm2App'
.factory 'User', ($resource, apiUrl) ->
  $resource apiUrl + '/users/:id/:controller',
    id: '@_id'
  ,
    changePassword:
      method: 'PUT'
      params:
        controller: 'password'

    get:
      method: 'GET'
      params:
        id: 'me'

