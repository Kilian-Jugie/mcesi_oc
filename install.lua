local internet = require("internet")

local function strsplit(inputstr, sep)
    local ret={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(ret, str)
    end
    return ret
end

local function download(url)
    local handle, result = internet.request(url), ""
    for chunk in handle do result = result..chunk end
    return result
end

local function download_to_file(url, output_path)
    local h = io.open(output_path, "w")
    h:write(download(url))
    h:close()
end

print("Retrieving file list to download")
local to_download = download("https://raw.githubusercontent.com/Kilian-Jugie/mcesi_oc/dev/install_files")
to_download = strsplit(to_download, "\n")
for key, value in pairs(to_download) do
    print("Downloading '"..value.."' "..key.."/"..#to_download)
    download_to_file("https://raw.githubusercontent.com/Kilian-Jugie/mcesi_oc/dev/"..value, value)
end
print("Done")