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

#if android
import android.app.Activity;
import android.os.Bundle;
import android.view.Window;
import zephyr.app.NativeView;

@:keep
class AndroidApplication extends android.app.Activity implements INativeApplication {

    /**
     *  On activity create
     *  @param bundle - 
     */
    @:overload
    override function onCreate (bundle : Bundle) : Void {
        super.onCreate (bundle);
        this.requestWindowFeature (Window.FEATURE_NO_TITLE);
        var entryPoint = EntryPointHelper.getEntryPoint();
        var cls = Type.resolveClass (entryPoint);
        if (cls != null) {
            var inst : IApplication = cast Type.createEmptyInstance (cls);
            inst.onReady (new ApplicationContext (this));
        }
    }

    /**
     *  Apply view
     *  @param view - 
     */
    public function setView (view : NativeView) : Void {
        setContentView (view);
    }
}
#end