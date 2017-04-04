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

package console;

import haxe.io.Path;
import haxe.Json;
import sys.io.File;
using StringTools;

typedef ProjectSettingsFields = {
    /**
     *  Name of project
     */
    public var name : String;

    /**
     *  Package of project
     *  Example: com.myorg.myprojects
     */
    public var packageName : String;

    /**
     *  Java libs to attach
     *  Only names: android.jar
     *  Paths substitutes on generating data
     */
    public var javaLibs : Array<String>;
}

/**
 *  Settings to manage project
 */
class ProjectSettings {

    /**
     *  Project name
     */
    public inline static var projectNameDef = "project.settings";

    /**
     *  Lib name for android
     */
    public inline static var androidLib = "android.jar";

    /**
     *  android.hxml
     */
    public inline static var androidHxmlName = "android.hxml";

    /**
     *  Path to libs
     */
    public inline static var libsDir = "libs";

    /**
     *  Package name parameter
     */
    public inline static var packageNameParam = "${packageName}";

    /**
     *  Project name parameter
     */
    public inline static var projectNameParam = "${projectName}";

    /**
     *  Activity name parameter
     */
    public inline static var activityNameParam = "${activityName}";

    /**
     *  Full class (with package) path parameter
     */
    public inline static var classPathParam = "${classPath}";

    /**
     *  -java-lib parameter
     */
    public inline static var javaLibsParam = "${javaLibs}";

    /**
     *  Fields for settings
     */
    public var settings : ProjectSettingsFields;

    /**
     *  android.hxml template
     */    
    inline static var androidHxml : String = 
"-cp src
-D analyzer-optimize
-D no-compilation
-dce full
-lib ZephyrNative
-java ./build/android/src/main/java
${packageName}.${projectName}
${javaLibs}";
    

    /**
     *  Load project settings
     *  @return ProjectSettings
     */
    public static function load (path : String) : ProjectSettings {
        var text = File.getContent (path);
        var sett : ProjectSettingsFields =  Json.parse (text);
        var proj = new ProjectSettings ("", "");
        proj.settings = sett;
        return proj;        
    }

    /**
     *  Constructor
     *  @param name - 
     *  @param package - 
     */
    public function new (name : String, packageName : String) {
        settings = {
            name : name,
            packageName : packageName,
            javaLibs : ["android.jar"]
        };       
    }

    /**
     *  Return activity name
     *  @return String
     */
    public function getActivityName () : String {
        return '${settings.name}Activity';
    }

    /**
     *  Generate android.hxml from settings
     *  @param libDir - 
     *  @return String
     */
    public function generateAndroidHxml (libDir : String) : String {
        var stringBuf = new StringBuf ();
        for (e in settings.javaLibs) {
            var path = Path.join ([libDir, libsDir, androidLib]);
            stringBuf.add ('-java-lib ${path}');
        }        

        var text = androidHxml.replace (packageNameParam, settings.packageName);
        text = text.replace (projectNameParam, settings.name);
        text = text.replace (javaLibsParam, stringBuf.toString ());
        return text;
    }

    /**
     *  Save project
     *  @param path - 
     */
    public function save (path : String) {
        var text = Json.stringify (settings, null, "\t");
        File.saveContent (path, text);
    }
}