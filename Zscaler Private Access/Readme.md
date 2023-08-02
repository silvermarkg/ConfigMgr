# Force ConfigMgr client to Internet when ZPA enabled
This script installs a scheduled task that will run the ConfigMgr client 'Refresh Default MP Task' schedule to update the client location as soon as it detects ZPA has changed the ClientAlwaysOnInternet registry key.

This solution requires ZPA to be configured to set the ConfigMgr location to be internet when ZPA is active on a non-trusted network and also auditing enabled to montitor the ClientAlwaysOnInternet registry key changes.