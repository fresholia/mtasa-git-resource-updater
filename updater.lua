updater = new "Updater";

local gitURL = "https://raw.githubusercontent.com/"

local fetchRemote = fetchRemote
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
    self.url = gitURL
    self.filePath = "version.yml" --default
    self.metaData = {}
end

function updater.prototype.setDetails(self, details)
    self.details = details
    if not self.details.branch then
        self.details.branch = "master"
    end

    if self.details.private then
        self.url = gitURL..self.details.user.."/"..self.details.repo.."/"..self.details.branch.."/%s?token="..self.details.token
    else
        self.url = gitURL..self.details.user.."/"..self.details.repo.."/"..self.details.branch.."/%s"
    end
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
    self.filePath = filePath
end

function updater.prototype.pushEvent(self, event, ...)
    if event == "progress" and not self.debug then
        print(...)
        return
    end
    if self.events[event] then
        self.events[event](...)
    end
end

function updater.prototype.downloadFile(self, currentID)
    local resourceFiles = self.metaData

    local fileDir = resourceFiles[currentID]

    self:pushEvent("progress", currentID, #resourceFiles, fileDir)
    fetchRemote(self.url:format(fileDir),
        function(data, err)
            if err ~= 0 then
                self:pushEvent("error", err)
                return
            end

            if fileExists(fileDir) then
                fileDelete(fileDir)
            end

            local file = fileCreate(fileDir)
            fileWrite(file, data)
            fileClose(file)

            if resourceFiles[currentID + 1] then
                self:downloadFile(currentID + 1)
            else
                self:saveMetaData()
                self:pushEvent("complete")
            end

        end
    )
end

function updater.prototype.updateResource(self)
    self:downloadFile(1)
end

function updater.prototype.saveMetaData(self)
    fileDelete("meta.xml")
    fileRename("meta.xml.new", "meta.xml")

    if self.details.restartOnComplete then
        restartResource(getThisResource())
    end
end

function updater.prototype.readMetaData(self)
    fetchRemote(self.url:format("meta.xml"),
        function(data, err)
            if err ~= 0 then
                self:pushEvent("error", err)
                return
            end
            local cacheFile = fileCreate("meta.xml.new") -- because you can't xmlLoadFile from string :(
            if cacheFile then
                fileWrite(cacheFile, data)
                fileClose(cacheFile)

                local meta = xmlLoadFile("meta.xml.new")
                local metaData = xmlNodeGetChildren(meta)
                local resourceFileCache = {}
                if metaData then
                    for index, node in ipairs(metaData) do
                        local fileType = xmlNodeGetName(node)
                        local fileLocation = xmlNodeGetAttribute(node, "src")
                        if fileType == "script" or fileType == "file" or fileType == "config" or fileType == "map" or fileType == "html" then
                            resourceFileCache[#resourceFileCache + 1] = fileLocation
                        end
                    end
                end
                xmlUnloadFile(meta)

                self.metaData = resourceFileCache
                collectgarbage("collect")

                self:pushEvent("status", "[GitUpdater]: Cached meta.xml, downloading file(s)...")
                self:updateResource()
            end
        end
    )
end

function updater.prototype.checkForUpdates(self)
    assert(#self.details == 0, "Please use updater.setDetails(), see more info github.com/cleopatradev/mta-git-resource-updater/README.md")

    fetchRemote(self.url:format(self.filePath),
        function(data, err)
            if err ~= 0 then
                self:pushEvent("error", err)
                return
            end

            local data = fromJSON(tostring(data)) or {}
            if #data > 0 then
                if data.version > self.localVer then
                    self:pushEvent("status", "[GitUpdater]: Update available, please wait...")
                    self:readMetaData()
                end
            else
                self:pushEvent("error", "[GitUpdater]: Couldn't find version file.")
            end
        end
    )
end

function updater.prototype.on(self, eventName, callback)
    self.events[eventName] = callback
end


-- function usages:

updater = load(updater)
updater:setVersionFile("version.yml", "json", "version")
updater:setDetails({
    user = "cleopatradev",
    repo = "mta-git-resource-updater",
    branch = "master", --default
    private = true,
    token = "bla bla bla",
    restartOnComplete = true -- default: false
})

updater:checkForUpdates()

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