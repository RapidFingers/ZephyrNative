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

import tink.cli.*;
import tink.Cli;
import console.commands.CreateNewProject;
import console.commands.BuildProject;

/**
 *  Process console commands
 */
@:alias(false)
class ConsoleCommand {

    /**
     *  Create project flag
     */
    @:flag('-create')
	public var create : Bool = false;

    /**
     *  Build project flag
     */
    @:flag('-build')
	public var build : Array<String>;

    /**
     *  Build project flag
     */
    @:flag('-install')
	public var install : Array<String>;

    /**
     *  Constructor
     */
    public function new() {}

    @:defaultCommand
	public function run(rest : Rest<String>) {        
        try {
            if (create) {
                new CreateNewProject (rest).run ();
            } else if (build != null) {
                new BuildProject (build, rest).run ();
            } else if (install != null) {
                new BuildProject (install, rest).run (true);
            }
            else {
                var doc = Cli.getDoc(this);
                Logger.info (doc);
            }
        } catch (e : Dynamic) {
            Logger.error (e);
        }
    }
}