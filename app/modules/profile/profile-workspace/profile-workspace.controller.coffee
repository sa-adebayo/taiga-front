###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: profile-workspace.controller.coffee
###

debounceLeading = @.taiga.debounceLeading

class WorkspaceBaseController
    constructor: ->
        @._init()

        #@._getItems = null # Define in inheritance classes
        #
    _init: ->
        @.enableFilterByAll = true
        @.enableFilterByProjects = true
        @.enableFilterByUserStories = true
        @.enableFilterByTasks = true
        @.enableFilterByIssues = true
        @.enableFilterByTextQuery = true

        @._resetList()
        @.q = null
        @.type = null

    _resetList: ->
        @.items = Immutable.List()
        @.scrollDisabled = false
        @._page = 1

    _enableLoadingSpinner: ->
        @.isLoading = true

    _disableLoadingSpinner: ->
        @.isLoading = false

    _enableScroll : ->
        @.scrollDisabled = false

    _disableScroll : ->
        @.scrollDisabled = true

    _checkIfHasMorePages: (hasNext) ->
        if hasNext
            @._page += 1
            @._enableScroll()
        else
            @._disableScroll()

    _checkIfHasNoResults: ->
        @.hasNoResults = @.items.size == 0

    loadItems:  ->
        @._enableLoadingSpinner()
        @._disableScroll()

        @._getItems(@.user.get("id"), @._page, @.type, @.q)
            .then (response) =>
                @.items = @.items.concat(response.get("data"))

                @._checkIfHasMorePages(response.get("next"))
                @._checkIfHasNoResults()
                @._disableLoadingSpinner()

                return @.items
            .catch =>
                @._disableLoadingSpinner()

                return @.items

    ################################################
    ## Filtre actions
    ################################################
    filterByTextQuery: debounceLeading 500, ->
        @._resetList()
        @.loadItems()

    showAll: ->
        if @.type isnt null
            @.type = null
            @._resetList()
            @.loadItems()

    showProjectsOnly: ->
        if @.type isnt "project"
            @.type = "project"
            @._resetList()
            @.loadItems()

    showUserStoriesOnly: ->
        if @.type isnt "userstory"
            @.type = "userstory"
            @._resetList()
            @.loadItems()

    showTasksOnly: ->
        if @.type isnt "task"
            @.type = "task"
            @._resetList()
            @.loadItems()

    showIssuesOnly: ->
        if @.type isnt "issue"
            @.type = "issue"
            @._resetList()
            @.loadItems()

####################################################
## Workspace
####################################################

class ProfileWorkspaceController extends WorkspaceBaseController
    @.$inject = [
        "tgUserService",
    ]

    constructor: (@userService) ->
        super()
        @._getItems = @userService.getWatched


angular.module("taigaProfile")
.controller("ProfileWorkspace", ProfileWorkspaceController)
