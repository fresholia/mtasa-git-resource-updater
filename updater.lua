local updater = new "Updater";

local fileExists = fileExists
local fileOpen = fileOpen
local fileRead = fileRead
local fileGetSize = fileGetSize
local print = print

function updater.prototype.____constructor(self)
    self.details = {}
    self.version = ""
    self.debug = true
    self.events = {}
    self.localVer = 1.0
end

function updater.prototype.setDetails(self, details)
    self.details = details
end

function updater.prototype.setDebug(self, debug)
    self.debug = debug 
end

function updater.prototype.setVersionFile(self, filePath, type, index)
    assert(filePath, "Please use updater.setDetails(filePath, type, index)")
    assert(type, "Please use 'json' or 'xml'")
    switch {
        type:lower(),
        case = {
            ["json"] = function()
                if fileExists(filePath) then
                    local file = fileOpen(filePath, true)
                    if file then
                        local fileData = fileRead(file, fileGetSize(file))

                        self.localVer = fileData.version
                        fileClose(file)
                    end
                else
                    local file = fileCreate(filePath)
                    if file then
                        fileWrite(file, toJSON({version=self.localVer}))
                        fileClose(file)
                    end
                end

                break
            end;
            ["xml"] = function()

                break
            end;
        }
        default = function()
            print("[GitUpdater]: Please use 'json' or 'xml' format.")
        end;
    }
end

function updater.checkForUpdates(self)
    assert(#self.details == 0, "Please use updater.setDetails(), see more info github.com/cleopatradev/mta-git-resource-updater/README.md")

end

function updater.prototype.on(self, eventName, callback)
    self.events[eventName] = callback
end


-- function usages:

updater = new "Updater";
updater:setVersionFile("version.yml", "json", "version")
updater:setDetails({
    user = "cleopatradev",
    repo = "mta-git-resource-updater",
    private = true,
    token = "bla bla bla"
})

updater:checkForUpdates()

updater:on("complete",
    function()
    
    end
)

updater:on("error",
    function()
    
    end
)

updater:setDebug(false)
--only valid when setDebug(false)
updater:on("progress",
    function(downloading, total, fileName)
    
    end
)