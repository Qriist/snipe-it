#Requires AutoHotkey v2.0 
#include <Aris/G33kDude/cJson> ; G33kDude/cJson@2.0.0
#include <Aris/Qriist/LibQurl> ; Qriist/LibQurl@v0.88.0

;ImagePut is used to generate the Base64'd image from your example.
;If you work with more than just images then you'll probably want a more media-agnostic Base64 encoder.
#include <Aris/iseahound/imageput> ; iseahound/imageput@v1.10

;LibQurl is supposed to auto-detect the dll but seems that's broken outside of my dev enviornment.
;You'll need to manually set the location for now. Sorry.
dll := A_ScriptDir "\lib\Aris\Qriist\LibQurl@v0.88.0\bin\libcurl.dll"
curl := LibQurl(dll)

;LibQurl creates a default easy_handle automatically.
;Every subsequent method below uses this implicitly assigned easy_handle.
;If you need to work on multiple concurrently prepared transfers then pass an explicit handle, ala:
;your_easy_handle := curl.Init()
;curl.SetOpt("URL",url,your_easy_handle)

;LibQurl auto-ingests to memory, which is great for working with APIs,
;but I'm deliberately saving to file for our verification.
curl.HeaderToFile(A_ScriptDir "\results.headers.txt")
curl.WriteToFile(A_ScriptDir "\results.body.txt")

;Make sure that you relay your entire required environment when asking for help.
;I would not have had "raybow" if I didn't check your original v1 request.
; url := "https://user.snipe-it.io/api/v1/hardware/2"
url := "https://raybow.snipe-it.io/api/v1/hardware/2"

;test site I used to echo what is being sent
; url := "https://httpbin.org/anything"

curl.SetOpt("URL",url)
curl.SetOpt("CUSTOMREQUEST","PATCH")

;prepare the headers
headers := Map()
headers["Content-Type"] := "application/json"
headers["accept"] := "application/json"
;read the bearer token file once and then remember it in a variable
bearer ??= FileOpen(A_ScriptDir "\bearer.txt","r").Read()
headers["Authorization"] := "Bearer " bearer
curl.SetHeaders(headers)

;Loads the json template as an AHK Map.
payload := JSON.Load(FileOpen(A_ScriptDir "\payload_template.json","r").Read())
;Embed the Base64-encoded image.
payload["image"] := ImagePutBase64(A_ScriptDir "\sample.png")
;Hand the Map to LibQurl.
curl.SetPost(payload)

;Execute the transfer.
curl.Sync()

;Observe the results. Remember that the return content was also saved to disk.
msgbox curl.GetLastHeaders() "`n" curl.GetLastBody()