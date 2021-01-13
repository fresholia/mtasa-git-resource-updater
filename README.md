# MTA:SA GitHub Resource Updater

> Welcome, with this module, you can remotely update the system you publish on GitHub.

### How to use it?
- updater.lua & classes.lua add files to the resource you want to update
- Enter the settings from the resource master file as in the example
- Enjoy it

### Example
```lua
local updater = load(updater)

updater:setVersionFile("version.yml", "json", "version")
updater:setDetails({
    user = "cleopatradev",
    repo = "mta-git-resource-updater",

    --The following values ​​are optional, whether or not you enter them
    branch = "master", --default
    private = true,
    token = "bla bla bla",
    restartOnComplete = true -- default: false
})

updater:on("complete",
    function()
    
    end
)

updater:on("error",
    function(err)
        print(err)
    end
)

updater:on("status",
    function(status)
    
    end
)

updater:setDebug(false)
--only valid when setDebug(false)
updater:on("progress",
    function(downloading, total, fileName)
    
    end
)

updater:checkForUpdates()
```
