/*
 * Copyright (c) 2017 Grabli66
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package zephyr.app;

import haxe.io.Bytes;

#if web
import zephyr.asset.Asset;
import js.Browser;
import zephyr.app.NativeView;
import zephyr.app.EntryPointHelper;
import zephyr.style.Engine;

/**
 *  Application for webview: browser, cordova, etc
 */
@:keep
class WebApplication implements INativeApplication {

    /**
     *  Engine for styling
     */
    var styleEngine : Engine;

    /**
     *  Entry point
     */
    public static function main () {
        Browser.document.addEventListener ("DOMContentLoaded", function () {
            var entryPoint = EntryPointHelper.getEntryPoint();
            var cls = Type.resolveClass (entryPoint);
            if (cls != null) {
                var app = new WebApplication ();
                var inst : IApplication = cast Type.createEmptyInstance (cls);
                inst.onReady (new ApplicationContext (app));
            }
        });        
    }

    /**
     *  Constructor
     */
    public function new () {
        styleEngine = new Engine (this);
    }

    /**
     *  Get asset by name
     *  @param name - asset name
     *  @return Bytes
     */
    public function getAsset (name : String) : Asset {
        var hostname = Browser.location.hostname;
        if (hostname == "") throw "Need launch from server";
        var data = haxe.Http.requestUrl(name);
        var data = Bytes.ofString (data);
        var tp = Asset.getAssetType (name);
        return new Asset (tp, data);
    }

    /**
     *  Add styles to app
     *  @param text - stylesheet
     */
    public function addStyle (text : String) : Void {
        var style = Browser.document.createStyleElement ();
        style.type = 'text/css';
        style.appendChild (Browser.document.createTextNode (text));
        Browser.document.head.appendChild (style);
    }

    /**
     *  Return engine for styling native views
     *  @return AndroidEngine
     */
    public function getEngine () : Engine {
        return styleEngine;
    }

    /**
     *  Apply view
     *  @param view - 
     */
    public function setView (view : NativeView) : Void {        
        Browser.document.body.appendChild (view);
    }

    /**
     *  Return screen width
     *  @return Float
     */
    public inline function getScreenWidth () : Float {
        return 0;
    }

    /**
     *  Return screen height
     *  @return Float
     */
    public inline function getScreenHeight () : Float {
        return 0;
    }
}
#end