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
import zephyr.style.Engine;
import zephyr.asset.Asset;

/**
 *  Interface to native application. Like: Activity
 */
interface INativeApplication {

    /**
     *  Apply view
     *  @param view - 
     */
    public function setView (view : NativeView) : Void;

    /**
     *  Get asset by name
     *  @param name - asset name
     *  @return Bytes
     */
    public function getAsset (name : String) : Asset;    

    /**
     *  Add styles to app
     *  @param text - stylesheet
     */
    public function addStyle (text : String) : Void;
    
    /**
     *  Return engine for styling native views
     *  @return AndroidEngine
     */
    public function getEngine () : Engine;

    /**
     *  Return screen width
     *  @return Float
     */
    public function getScreenWidth () : Float;

    /**
     *  Return screen height
     *  @return Float
     */
    public function getScreenHeight () : Float;        
}