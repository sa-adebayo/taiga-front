###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: attchments-full.controller.coffee
###

sizeFormat = @.taiga.sizeFormat

class AttachmentsFullController
    @.$inject = [
        "$translate",
        "$tgConfirm",
        "$tgConfig",
        "$tgStorage",
        "tgAttachmentsFullService"
    ]

    constructor: (@translate, @confirm, @config, @storage, @attachmentsFullService) ->
        @.mode = @storage.get('attachment-mode', 'list')

        @.maxFileSize = @config.get("maxUploadFileSize", null)
        @.maxFileSize = sizeFormat(@.maxFileSize) if @.maxFileSize
        @.maxFileSizeMsg = if @.maxFileSize then @translate.instant("ATTACHMENT.MAX_UPLOAD_SIZE", {maxFileSize: @.maxFileSize}) else ""

        taiga.defineImmutableProperty @, 'attachments', () => return @attachmentsFullService.attachments
        taiga.defineImmutableProperty @, 'deprecatedsCount', () => return @attachmentsFullService.deprecatedsCount
        taiga.defineImmutableProperty @, 'attachmentsVisible', () => return @attachmentsFullService.attachmentsVisible
        taiga.defineImmutableProperty @, 'deprecatedsVisible', () => return @attachmentsFullService.deprecatedsVisible

    uploadingAttachments: () ->
        return @attachmentsFullService.uploadingAttachments

    addAttachment: (file) ->
        editable = (@.mode == 'list')

        @attachmentsFullService.addAttachment(@.projectId, @.objId, @.type, file, editable)

    setMode: (mode) ->
        @.mode = mode

        @storage.set('attachment-mode', mode)

    toggleDeprecatedsVisible: () ->
        @attachmentsFullService.toggleDeprecatedsVisible()

    addAttachments: (files) ->
        _.forEach files, (file) => @.addAttachment(file)

    loadAttachments: ->
        @attachmentsFullService.loadAttachments(@.type, @.objId, @.projectId)

    deleteAttachment: (toDeleteAttachment) ->
        title = @translate.instant("ATTACHMENT.TITLE_LIGHTBOX_DELETE_ATTACHMENT")
        message = @translate.instant("ATTACHMENT.MSG_LIGHTBOX_DELETE_ATTACHMENT", {
            fileName: toDeleteAttachment.getIn(['file', 'name'])
        })

        return @confirm.askOnDelete(title, message)
            .then (askResponse) =>
                onError = () =>
                    message = @translate.instant("ATTACHMENT.ERROR_DELETE_ATTACHMENT", {errorMessage: message})
                    @confirm.notify("error", null, message)
                    askResponse.finish(false)

                onSuccess = () => askResponse.finish()

                @attachmentsFullService.deleteAttachment(toDeleteAttachment, @.type).then(onSuccess, onError)

    reorderAttachment: (attachment, newIndex) ->
        @attachmentsFullService.reorderAttachment(@.type, attachment, newIndex)

    updateAttachment: (toUpdateAttachment) ->
        @attachmentsFullService.updateAttachment(toUpdateAttachment, @.type)

angular.module("taigaComponents").controller("AttachmentsFull", AttachmentsFullController)
