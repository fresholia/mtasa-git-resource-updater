local updater = load(updater)

updater:setVersionFile("version.yml", "json", "version")
updater:setDetails({
    user = "cleopatradev",
    repo = "mta-git-resource-updater",
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