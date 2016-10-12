<form role="form" id="ConfigApiSettings">
    <div class="row">
        <div class="col-sm-2 col-xs-12 settings-header">
            General Settings
        </div>
        <div class="col-sm-10 col-xs-12">
            <label>
                Select the keys of config values that you want to expose at <code>/api/config</code>
            </label>
            <button id="ClearConfigKeysInput" class="btn btn-link">Clear</button>
            <div class="config-multi-select-container-container">
                <div class="config-multi-slect-container">
                    <select multiple data-key="configKeys" id="ConfigKeysInput" class="form-control">
                        <!-- BEGIN configKey -->
                        <option value="{configKey.name}">{configKey.name}</option>
                        <!-- END configKey -->
                    </select>
                </div>
            </div>
            <label>
                Example response
            </label>
            <pre><samp id='SampleConfigResponse'></samp></pre>
        </div>
    </div>
</form>

<button id="save" class="floating-button mdl-button mdl-js-button mdl-button--fab mdl-js-ripple-effect mdl-button--colored">
<i class="material-icons">save</i>
</button>

<script>
    require(['settings'], function(Settings) {
        var wrapper = $('#ConfigApiSettings');
        var fullConfig = JSON.parse(decodeURIComponent('{{fullConfig}}'));

        Settings.sync('configApi', wrapper, function() {
            fillSampleResponse();
        });

        SizeListSelect($('#ConfigKeysInput'));

        $('#save').click(function() {
            Settings.persist('configApi', wrapper, function() {
                socket.emit('admin.settings.syncConfigApi');
            });
        });

        $('#ClearConfigKeysInput').click(function(event) {
            $('#ConfigKeysInput').val([]);
            fillSampleResponse();
            event.preventDefault();
        });

        $('#ConfigKeysInput').mousedown(function(event) {
            if(event.target.nodeName === 'OPTION') {
                event.target.selected = !event.target.selected;
            }
            fillSampleResponse();
            event.preventDefault();
        });

        $('#ConfigKeysInput').change(function() {
            fillSampleResponse();
        });

        function fillSampleResponse() {
            var configKeys = $(ConfigKeysInput).val();
            var filteredConfig = {};

            configKeys.forEach(function(key) {
                if (key in fullConfig) {
                    filteredConfig[key] = fullConfig[key];
                }
            });
            var exampleResponse = JSON.stringify(filteredConfig, null, 2);

            $('#SampleConfigResponse').text(exampleResponse);
        }

        function SizeListSelect($selectObject) {
            if (!(typeof $selectObject[0].options === 'undefined')) {
                var opts = $selectObject[0].options.length;
                opts = opts > 9 ? opts : 9;
                $selectObject[0].size = opts;
                $selectObject
                    .parent('.config-multi-select')
                    .height($selectObject.height());
            }
        }
    });
</script>
<style type="text/css">
    .config-multi-select-container-container {
        height: 6em;
        overflow: auto;
        border: solid 1px #ccc;
        border-radius: 3px;
        margin-bottom: 20px;
    }
    .config-multi-select-container {
        overflow: hidden;
    }
    #ConfigKeysInput {
        width: 100%;
        overflow-y: hidden;
        padding-left: 16px;
    }
</style>
