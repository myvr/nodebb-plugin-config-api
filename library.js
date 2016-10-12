(function(module) {
    "use strict";

    var plugin = {},

        meta = module.parent.require('./meta'),
        Settings = module.parent.require('./settings'),
        SocketAdmin = module.parent.require('./socket.io/admin'),

        defaultSettings = {configKeys: []},
        configApiSettings = new Settings('configApi', '1.0.0', defaultSettings);


    plugin.init = function(params, callback) {
        var app = params.router,
            middleware = params.middleware;

        app.get('/api/config', render);

        app.get('/admin/plugins/config-api', middleware.admin.buildHeader, renderAdmin);
        app.get('/api/admin/plugins/config-api', renderAdmin);

        callback();
    };

    function render(req, res, next) {
        var configKeys = configApiSettings.get('configKeys');
        var filteredConfig = {};

        meta.configs.list(function(err, config) {
            configKeys.forEach(function(key) {
                if (key in config) {
                    filteredConfig[key] = config[key];
                }
            });
            res.json(filteredConfig);
        });
    }

    function renderAdmin(req, res, next) {
        meta.configs.list(function(err, config) {
            if (err) {
                return next(err);
            }

            var configKeyList = Object.keys(config).map(function(value) {
                return {name: value};
            });
            var fullConfig = encodeURIComponent(
                JSON.stringify(config)).replace(/\'/g, "\\'");
            res.render('config-api-admin', {
                fullConfig: fullConfig,
                configKey: configKeyList
            });
        });
    }

    plugin.addAdminNavigation = function(header, callback) {
        header.plugins.push({
            route: '/plugins/config-api',
            icon: 'fa-cog',
            name: 'Config API'
        });

        callback(null, header);
    };

    SocketAdmin.settings.syncConfigApi = function() {
        configApiSettings.sync();
    };

    module.exports = plugin;
}(module));
