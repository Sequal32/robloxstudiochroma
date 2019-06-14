local Chroma = {}
Chroma.__index = Chroma

local HttpService = game:GetService("HttpService")
local BaseURL = "http://localhost:54235/razer/chromasdk"

function Chroma.new(Title, Description, AuthorName, AuthorContact, DevicesSupported)
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

    return NewChroma
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

    local Response = HttpService:RequestAsync({
        Url = BaseURL,
        Method = "POST",
        Body = self.ApplicationInfo,
        Headers = {["Content-Type"] = "application/json"}
    })

    assert(Response.Success, "Initialization failed!", Response.StatusCode, Response.StatusMessage)

    Data = HttpService:JSONDecode(Response.Body)
    self.SessionURL = Data.uri
end


return Chroma