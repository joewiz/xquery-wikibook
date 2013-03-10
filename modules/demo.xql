xquery version "3.0";

module namespace demo="http://exist-db.org/apps/demo";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace templates="http://exist-db.org/xquery/templates";

declare function demo:error-handler-test($node as node(), $model as map(*), $number as xs:string?) {
    if (exists($number)) then
        xs:int($number)
    else
        ()
};

declare function demo:link-to-home($node as node(), $model as map(*)) {
    <a href="{request:get-context-path()}/">{ 
        $node/@* except $node/@href,
        $node/node() 
    }</a>
};

declare function demo:run-tests($node as node(), $model as map(*)) {
    let $results := test:suite(inspect:module-functions(xs:anyURI("../examples/tests/shakespeare-tests.xql")))
    return
        test:to-html($results)
};

declare function demo:display-source($node as node(), $model as map(*), $lang as xs:string?, $type as xs:string?) {
    let $source := replace($node/string(), "^\s*(.*)\s*$", "$1")
    let $expanded := replace($source, "@@path", $config:app-root)
    let $eXideLink := templates:link-to-app("http://exist-db.org/apps/eXide", "index.html?snip=" || encode-for-uri($expanded))
    return
        <div xmlns="http://www.w3.org/1999/xhtml" class="source">
            <div class="code" data-language="{if ($lang) then $lang else 'xquery'}">{ $expanded }</div>
            <div class="toolbar">
                <a class="btn run" href="#" data-type="{if ($type) then $type else 'xml'}">Run</a>
                <a class="btn eXide-open" href="{$eXideLink}" target="eXide"
                    data-exide-create="{$expanded}"
                    title="Opens the code in eXide in new tab or existing tab if it is already open.">Edit</a>
                <img class="load-indicator" src="resources/images/ajax-loader.gif"/>
                <div class="output"></div>
            </div>
        </div>
};

declare function demo:display-source-from-db($node as node(), $model as map(*), $path-to-file as xs:string, $starting-at as xs:double?, $length as xs:double?, $lang as xs:string?, $type as xs:string?) {
    let $binary := util:binary-doc($path-to-file)
    let $string := util:binary-to-string($binary)
    let $all-lines := tokenize($string, '\n')
    let $source := 
        let $lines := 
            if ($length) then 
                subsequence($all-lines, $starting-at, $length) 
            else if ($starting-at) then
                subsequence($all-lines, $starting-at)
            else
                $all-lines
        let $pad-empty-lines := 
            for $line in $lines
            return
                if ($line = '') then ' ' else $line
        return
            string-join($pad-empty-lines, '&#10;')
    let $expanded := replace($source, "@@path", $config:app-root)
    let $eXideLink := templates:link-to-app("http://exist-db.org/apps/eXide", "index.html?snip=" || encode-for-uri($expanded))
    return
        <div xmlns="http://www.w3.org/1999/xhtml" class="source">
            <div class="code" data-language="{if ($lang) then $lang else 'xquery'}">{ $expanded }</div>
            <div class="toolbar">
                <a class="btn run" href="#" data-type="{if ($type) then $type else 'xml'}">Run</a>
                <a class="btn eXide-open" href="{$eXideLink}" target="eXide"
                    data-exide-create="{$expanded}"
                    title="Opens the code in eXide in new tab or existing tab if it is already open.">Edit</a>
                <img class="load-indicator" src="resources/images/ajax-loader.gif"/>
                <div class="output"></div>
            </div>
        </div>
};

declare function demo:display-xml-document($node as node(), $model as map(*), $path-to-file as xs:string) {
    let $lang := 'xquery'
    let $type := 'xml'
    let $source := doc($path-to-file)
    return
        <div xmlns="http://www.w3.org/1999/xhtml" class="source">
            <div class="code" data-language="{if ($lang) then $lang else 'xquery'}">{ serialize($source, <output:serialization-parameters
       xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
  <output:method value="xml"/>
</output:serialization-parameters>) }</div>
        </div>
};

declare function demo:run-source-from-db($node as node(), $model as map(*), $path-to-file as xs:string, $lang as xs:string?, $type as xs:string?) {
    let $binary := util:binary-doc($path-to-file)
    let $source := util:binary-to-string($binary)
    let $expanded := replace($source, "@@path", $config:app-root)
    let $eXideLink := templates:link-to-app("http://exist-db.org/apps/eXide", "index.html?snip=" || encode-for-uri($expanded))
    return
        <div xmlns="http://www.w3.org/1999/xhtml" class="source">
            <div class="code" data-language="{if ($lang) then $lang else 'xquery'}" style="display:none;">{ $expanded }</div>
            <div class="toolbar">
                <a class="btn run" href="#" data-type="{if ($type) then $type else 'xml'}">Run</a>
                <a class="btn eXide-open" href="{$eXideLink}" target="eXide"
                    data-exide-create="{$expanded}"
                    title="Opens the code in eXide in new tab or existing tab if it is already open.">Edit</a>
                <img class="load-indicator" src="resources/images/ajax-loader.gif"/>
                <div class="output"></div>
            </div>
        </div>
};