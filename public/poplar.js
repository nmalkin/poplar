var DEFAULT_ICON_URL = 'poplar.svg';
var INSTALL_BUTTON = '<button id="install" class="btn btn-success btn-large">Install now!</button>';

function updatePreview() {
    var iconURL = $('#icon').val();
    if(iconURL == '') {
        iconURL = DEFAULT_ICON_URL;
    }
    $('#preview img').attr('src', iconURL);
}

updatePreview(); // on load
$('#icon').on('change', updatePreview);

function createInstallLink(manifestURL) {
    console.log(manifestURL);
    var installButton = $(INSTALL_BUTTON);
    installButton.on('click', function() {
        try {
            navigator.mozApps.install(manifestURL);
        } catch(e) {
            alert("Installation failed. Perhaps you're using an old version of Firefox?");
        }
    });
    $('#main').append(installButton);
}

$('form').on('submit', function(e) {
    e.preventDefault();

    // Check browser
    var isFirefox = navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
    if(! isFirefox) {
        alert("We can't continue, because it looks like you're not running Firefox.");
        return;
    }

    // Disable all form entries
    ['url', 'name', 'icon', 'submit'].forEach(function(el) {
        $('#' + el).attr('disabled', true);
    });
    
    var payload = {
        url: $('#url').val(),
        name: $('#name').val(),
        icon: $('#icon').val()
    };
    $.post('/create', payload, function(response) {
        if(response.status === 'success') {
            createInstallLink(response.manifest);
        } else if(response.status === 'failure') {
            alert(response.message);
        } else {
            alert('Received unexpected response from the server.');
        }
    }, 'json');
});
