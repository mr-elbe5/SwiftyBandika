const MODAL_DLG_JQID = '#modalDialog';

function openModalDialog(ajaxCall) {
    $(MODAL_DLG_JQID).load(ajaxCall, function () {
        $(MODAL_DLG_JQID).modal({show: true});
    });
    return false;
}

function closeModalDialog() {
    let $dlg = $(MODAL_DLG_JQID);
    $dlg.html('');
    $dlg.modal('hide');
    $('.modal-backdrop').remove();
    return false;
}

function postByAjax(url, params, identifier) {
    $.ajax({
        url: url, type: 'POST', data: params, cache: false, dataType: 'html'
    }).success(function (html, textStatus) {
        $(identifier).html(html);
    });
    return false;
}

function postMultiByAjax(url, params, target) {
    $.ajax({
        url: url, type: 'POST', data: params, cache: false, dataType: 'html', enctype: 'multipart/form-data', contentType: false, processData: false
    }).success(function (html, textStatus) {
        $(target).html(html);
    });
    return false;
}

function linkTo(url) {
    window.location.href = url;
    return false;
}

$.fn.extend({
    serializeFiles: function () {
        let formData = new FormData();
        $.each($(this).find("input[type='file']"), function (i, tag) {
            $.each($(tag)[0].files, function (i, file) {
                formData.append(tag.name, file);
            });
        });
        let params = $(this).serializeArray();
        $.each(params, function (i, val) {
            formData.append(val.name, val.value);
        });
        return formData;
    }
});







