#Requires AutoHotkey v2.0 
#include <Aris/G33kDude/cJson> ; G33kDude/cJson@2.0.0
#include <Aris/Qriist/LibQurl> ; Qriist/LibQurl@v0.88.0

;Since Base64 methods are included in LibQurl there's no longer a pressing need for 
;an external libray to handle them. I removed imageput as a dependency here.
; #include <Aris/iseahound/imageput> ; iseahound/imageput@v1.10

;I fixed LibQurl's dll auto-detection :D
curl := LibQurl()

/*
    LibQurl creates a default easy_handle automatically.
    Every subsequent method below uses this implicitly assigned easy_handle.

    If you need to work on multiple concurrently prepared transfers,
    pass an explicit handle ala:
    
    your_easy_handle := curl.Init()
    curl.SetOpt("URL",url,your_easy_handle)
*/

;LibQurl auto-ingests to memory, which is great for working with APIs,
;but I'm deliberately saving to file for our verification.
curl.HeaderToFile(A_ScriptDir "\results.headers.txt")
curl.WriteToFile(A_ScriptDir "\results.body.txt")

;Make sure that you relay your entire required environment when asking for help.
;I would not have had "raybow" if I didn't check your original v1 request.
; url := "https://raybow.snipe-it.io/api/v1/hardware/2"
; url := "http://your-snipe-it/api/v1/hardware/1/files"
url := "https://raybow.snipe-it.io/api/v1/hardware/1/files"

;test site I used to echo what is being sent
; url := "https://httpbin.org/anything"

curl.SetOpt("URL",url)

/*
    Custom Requests are only required for special cases like PATCH.
    
    GET and POST are handled automatically, though there's no harm in 
    passing GET or POST if you need to frequently swap request types:
    curl.SetOpt("CUSTOMREQUEST","GET")
    curl.SetOpt("CUSTOMREQUEST","POST")
    curl.SetOpt("CUSTOMREQUEST","PATCH")
    
    You can also .Init() a new easy_handle for each different type of
    request if you think it's easier to keep modes distinct.
*/


;prepare the headers
headers := Map()
; headers["Content-Type"] := "application/json" ;setting this on a MIME transfer WILL break things
headers["accept"] := "application/json"

;read the bearer token file once and then remember it in a variable
bearer ??= FileOpen(A_ScriptDir "\bearer.txt","r").Read()
headers["Authorization"] := "Bearer " bearer
curl.SetHeaders(headers)



/*
    The type of request your CLI asked for (-F "file[]=@test.txt") is not a regular POST

    So we don't need this:
    
    ; Loads the json template as an AHK Map.
    ; payload := JSON.Load(FileOpen(A_ScriptDir "\payload_template.json","r").Read())
    ; Embed the Base64-encoded image.
    ; fileHandle := FileOpen(A_ScriptDir "\sample.png","r")
    ; payload["image"] := curl.EncodeBase64(fileHandle)
    ; curl.SetPost(payload)

    ; If you're doing a lot of different types of requests,
    ; use ClearPost to detach the upload data from the handle.
    ; (I may call ClearPost automatically in the future)
    ; curl.ClearPost()

    Instead we need to use the MIME interface below.
*/

; MIME handles are never created by default because they affect
; the outgoing request just by existing.
; mimeFile := FileOpen(A_ScriptDir "\sample.png","r")
mimeFile := FileOpen(A_ScriptDir "\test.rar","r")

mime_handle := curl.MimeInit()

; "file" here comes, not from being a literal file,
; but from the name "file[]" in your CLI
; (though your site seems to require that exact name anyways)
mime_part := curl.AttachMimePart("file",mimeFile)

;Execute the transfer.
curl.Sync()

;Observe the results. Remember that the return content was also saved to disk.
msgbox curl.GetLastHeaders() "`n" curl.GetLastBody()