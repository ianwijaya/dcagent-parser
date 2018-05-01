when HTTP_REQUEST {
    if { [HTTP::method] eq "POST" } {
          ## Trigger the collection for up to 1MB of data
          if { [HTTP::header Content-Length] ne "" and [HTTP::header value Content-Length] <= 1048576 } {
             set content_length [HTTP::header value Content-Length]
          } else {
             set content_length 1048576
          }
          ## Check if $content-length is not set to 0
          if { $content_length > 0 } {
             HTTP::collect $content_length
          }
       }
}

when HTTP_REQUEST_DATA {
   #log local0. [HTTP::payload]
   set newData [findstr [HTTP::payload] "<update" 0 ]
   #log local0. $newData
   set username [string map {"\"" "" " " "" "\'" ""} [findstr [findstr $newData "identity" ] "name=" 5 " "]]
   set addr [string map {"\"" "" " " "" "\'" ""} [findstr [findstr $newData "ip-address"] "value=" 6 " "]]
   if { $username!="" && $addr!="" } {
      log local0. "$username - $addr"
      table set $addr $username indef indef
   }
}
