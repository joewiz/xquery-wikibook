xquery version "1.0";

declare option exist:serialize "method=text media-type=text/plain";

let $message := 'Hello World!'
return
    $message