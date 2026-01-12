local mp = require('mp')
local utils = require('mp.utils')
local msg = require('mp.msg')

local external_providers = {}

local function get_subs_file_path()
    local script_dir = mp.get_script_directory()
    if script_dir then
        return script_dir .. "/../playtorrio-subs.json"
    end
    return nil
end

local function load_external_subs()
    local subs_file = get_subs_file_path()
    if not subs_file then return end
    
    local file = io.open(subs_file, "r")
    if not file then return end
    
    local content = file:read("*all")
    file:close()
    
    if content and content ~= "" then
        local parsed = utils.parse_json(content)
        if parsed and parsed.providers then
            external_providers = parsed.providers
            msg.info("Loaded " .. #external_providers .. " provider(s)")
        end
    end
    
    os.remove(subs_file)
end

local function get_providers()
    return external_providers
end

mp.register_script_message("get-external-providers", function()
    mp.commandv("script-message", "external-providers-data", utils.format_json(external_providers))
end)

mp.register_script_message("load-external-sub", function(url, name)
    msg.info("Loading subtitle: " .. (name or url))
    mp.commandv("sub-add", url, "select", name or "External")
    mp.osd_message("Loaded: " .. (name or "subtitle"), 2)
end)

mp.register_event("file-loaded", load_external_subs)
load_external_subs()

-- Export for modernz
_G.playtorrio_get_providers = get_providers

msg.info("PlayTorrioPlayer subtitle provider script loaded")
