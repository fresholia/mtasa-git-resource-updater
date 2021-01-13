local updater = new "Updater";

local fileExists = fileExists
local fileOpen = fileOpen

function updater.prototype.____constructor(self)
    self.data = {}
    self.version = ""
end

function updater.prototype.setVersionFile(self, file, type, index)
    
    switch {
        type,
        case = {
            ["json"] = function()
                if fileExists(file) then
                    local file = fileOpen(file, true)
                    
                else

                end

                break
            end;
            ["xml"] = function()

                break
            end;
        }
    }
end


updater:setVersionFile("version.yml", "json", "version")