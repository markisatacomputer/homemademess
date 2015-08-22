###*
# Angular JS multiple-selection module
# @author Maksym Pomazan
# @version 0.0.3
###

getSelectableElements = (element) ->
  element.find 'div.dz-preview'

offset = (element) ->
  documentElem = undefined
  box = 
    top: 0
    left: 0
  doc = element and element.ownerDocument
  documentElem = doc.documentElement
  if typeof element.getBoundingClientRect != undefined
    box = element.getBoundingClientRect()
  {
    top: box.top + (window.pageYOffset or documentElem.scrollTop) - (documentElem.clientTop or 0)
    left: box.left + (window.pageXOffset or documentElem.scrollLeft) - (documentElem.clientLeft or 0)
  }

angular.module('multipleSelection', []).directive 'multipleSelectionZone', [
  '$document'
  ($document) ->
    {
      scope: true
      restrict: 'A'
      link: (scope, element, iAttrs, controller) ->

        ###*
        # Check that 2 boxes hitting
        # @param  {Object} box1
        # @param  {Object} box2
        # @return {Boolean} is hitting
        ###

        checkElementHitting = (box1, box2) ->
          (box2.beginX <= box1.beginX and box1.beginX <= box2.endX or box1.beginX <= box2.beginX and box2.beginX <= box1.endX) and (box2.beginY <= box1.beginY and box1.beginY <= box2.endY or box1.beginY <= box2.beginY and box2.beginY <= box1.endY)

        ###*
        # Transform box to object to:
        #  beginX is always be less then endX
        #  beginY is always be less then endY
        # @param  {Number} startX
        # @param  {Number} startY
        # @param  {Number} endX
        # @param  {Number} endY
        # @return {Object} result Transformed object
        ###

        transformBox = (startX, startY, endX, endY) ->
          result = {}
          if startX > endX
            result.beginX = endX
            result.endX = startX
          else
            result.beginX = startX
            result.endX = endX
          if startY > endY
            result.beginY = endY
            result.endY = startY
          else
            result.beginY = startY
            result.endY = endY
          result

        ###*
        # Method move selection helper
        # @param  {Element} hepler
        # @param  {Number} startX
        # @param  {Number} startY
        # @param  {Number} endX
        # @param  {Number} endY
        ###

        moveSelectionHelper = (hepler, startX, startY, endX, endY) ->
          box = transformBox(startX, startY, endX, endY)
          helper.css
            'top': box.beginY + 'px'
            'left': box.beginX + 'px'
            'width': box.endX - (box.beginX) + 'px'
            'height': box.endY - (box.beginY) + 'px'
          return

        ###*
        # Method on Mouse Move
        # @param  {Event} @event
        ###

        mousemove = (event) ->
          # Prevent default dragging of selected content
          event.preventDefault()
          # Move helper
          moveSelectionHelper helper, startX, startY, event.pageX, event.pageY
          # Check items is selecting
          childs = getSelectableElements(element)
          i = 0
          while i < childs.length
            child = angular.element childs[i]
            if checkElementHitting(transformBox(offset(child[0]).left, offset(child[0]).top, offset(child[0]).left + child.prop('offsetWidth'), offset(child[0]).top + child.prop('offsetHeight')), transformBox(startX, startY, event.pageX, event.pageY))
              #  add isSelecting class
              child.toggleClass 'selecting', true
            else
              #  remove isSelecting class
              child.toggleClass 'selecting', false
            i++
          return

        ###*
        # Event on Mouse up
        # @param  {Event} event
        ###

        mouseup = (event) ->
          # Prevent default dragging of selected content
          event.preventDefault()
          # Remove helper
          helper.remove()
          # Change all selecting items to selected
          childs = getSelectableElements(element)
          i = 0
          while i < childs.length
            child = angular.element(childs[i])
            if child.hasClass 'selecting'
              child.toggleClass 'selecting', false
              if !event.ctrlKey
                child.trigger 'click'
              else if !child.hasClass 'selected'
                child.trigger 'click'
            i++
          # Remove listeners
          $document.off 'mousemove', mousemove
          $document.off 'mouseup', mouseup
          return

        startX = 0
        startY = 0
        helper = undefined
        element.on 'mousedown', (event) ->
          # Prevent default dragging of selected content
          event.preventDefault()
          if !event.ctrlKey
            # Reset all selected or selecting items if not clicking on preview and no ctrl press
            childs = getSelectableElements(element)
            i = 0
            reset = true
            while i < childs.length
              child = angular.element childs[i]
              if checkElementHitting(transformBox(child.prop('offsetLeft'), child.prop('offsetTop'), child.prop('offsetLeft') + child.prop('offsetWidth'), child.prop('offsetTop') + child.prop('offsetHeight')), transformBox(event.pageX, event.pageY, event.pageX, event.pageY))
                reset = false
                break
              i++
            #  reset  
            if reset
              element.find 'div.dz-preview' 
              .trigger 'click'

          # Update start coordinates
          startX = event.pageX
          startY = event.pageY
          # Create helper
          helper = angular.element('<div></div>').addClass('select-helper')
          $document.find('body').eq(0).append helper
          # Attach events
          $document.on 'mousemove', mousemove
          $document.on 'mouseup', mouseup
          return
        return

    }
]
