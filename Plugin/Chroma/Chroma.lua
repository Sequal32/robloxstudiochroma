local Chroma = {}
Chroma.__index = Chroma

local HttpService = game:GetService("HttpService")
local BaseURL = "http://localhost:54235/razer/chromasdk"

local Directories = {
    Heartbeat = "/heartbeat",
    Keyboard = "/keyboard",
    Mice = "/mice",
    Mousepads = "/mousepad",
    Headset = "/headset",
    Keypad = "/keypad",
    Chromalink = "/chromalink"
}

function Chroma.new(Title, Description, AuthorName, AuthorContact, DevicesSupported, Verbose)
    -- Check if HTTP requests are enabled
    assert(HttpService.HttpEnabled, "HTTP Requests are not enabled!")

    local NewChroma = {}
    setmetatable(NewChroma, Chroma)

    -- Build application info
    NewChroma.ApplicationInfo = HttpService:JSONEncode({
        title = Title,
        description = Description,
        author = {
            name = AuthorName,
            contact = AuthorContact
        },
        device_supported = DevicesSupported,
        category = "application"
    })
    -- Initialize Variables
    NewChroma.SessionURL = nil
    NewChroma.Verbose = Verbose

    return NewChroma
end

function Chroma:VerboseLog(Message)
    if self.Verbose then
        print("ChromeSDK: " + tostring(Message))
    end
end

function Chroma:ApiStatus()
    local Response = HttpService:RequestAsync({
        Url = BaseURL,
        Method = "GET",
    })

    return Response.Success
end

function Chroma:Initialize()
    -- Check that the API is up
    assert(Chroma:ApiStatus(), "Unable to reach the chroma API")
    -- Initialize the connection
    local Response = HttpService:RequestAsync({
        Url = BaseURL,
        Method = "POST",
        Body = self.ApplicationInfo,
        Headers = {["Content-Type"] = "application/json"}
    })
    -- Error checking
    assert(Response.Success, "Initialization failed!", Response.StatusCode, Response.StatusMessage)
    -- Get the sessionURL
    Data = HttpService:JSONDecode(Response.Body)
    self.SessionURL = Data.uri
end

function Chroma:Heartbeat()
    -- Heartbeat to keep the connection alive
    local Response = HttpService:RequestAsync({
        Url = self.SessionURL + Directories.Heartbeat,
        Method = "PUT",
    })

    assert(Response.Success, "Heartbeat failed!")

    Data = HttpService:JSONDecode(Response.Body)

    self:VerboseLog("Heartbeat " + Data.ticks)
end


return Chroma