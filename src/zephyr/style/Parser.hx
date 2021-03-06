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

package zephyr.style;

import zephyr.style.Defs;

enum Token {
	TIdent( i : String );
	TString( s : String );
	TInt( i : Int );
	TFloat( f : Float );
	TDblDot;
	TSharp;
	TPOpen;
	TPClose;
	TExclam;
	TComma;
	TEof;
	TPercent;
	TSemicolon;
	TBrOpen;
	TBrClose;
	TDot;
	TSpaces;
	TSlash;
	TStar;
}

enum Value {
	VIdent( i : String );
	VString( s : String );
	VUnit( v : Float, unit : String );
	VFloat( v : Float );
	VInt( v : Int );
	VHex( v : String );
	VList( l : Array<Value> );
	VGroup( l : Array<Value> );
	VCall( f : String, vl : Array<Value> );
	VLabel( v : String, val : Value );
	VSlash;
}

/**
 *  Style parser
 */
class Parser {

	var css : String;
	var s : Style;
	var simp : Style;
	var pos : Int;

	var spacesTokens : Bool;
	var tokens : Array<Token>;

	public function new() {
	}


	// ----------------- style apply ---------------------------

	inline function notImplemented() {
        throw "Not implemented";
	}

	/**
	 *  Apply style
	 *  @param r - rule
	 *  @param v - value
	 *  @param s - style
	 *  @return success
	 */
	function applyStyle (r : String, v : Value, s : Style) : Bool {
		switch (r) {
			case "justify-content":
				switch (getIdent(v)) {
					case "flex-start":
						s.justifyContent = FlexStart;
						return true;
					case "flex-end":
						s.justifyContent = FlexEnd;
						return true;					
					default:
				}
			case "flex-direction":
				switch (getIdent(v)) {
					case "row":
						s.flexDirection = Row;
						return true;
					case "column":
						s.flexDirection = Column;
						return true;
					default:
				}
			case "align-items":
				switch (getIdent(v)) {
					case "flex-start":
						s.alignItems = FlexStart;
						return true;
					case "flex-end":
						s.alignItems = FlexEnd;
						return true;
					case "center":
						s.alignItems = Center;
						return true;
					default:
				}
			case "background-image":
				var img = getAsset(v);
				s.backgroundImage = img;
			case "padding":
				switch (v) {
				case VGroup([a, b]):
					var a = getVal(a), b = getVal(b);
					if( a != null && b != null ) {
						s.paddingTop = s.paddingBottom = a;
						s.paddingLeft = s.paddingRight = b;
						return true;
					}
				default:
					var i = getVal(v);
					if( i != null ) { s.padding(i); return true; }
				}
			case "padding-top":
				var i = getVal(v);
				if (i != null) { s.paddingTop = i; return true; }
			case "padding-left":
				var i = getVal(v);
				if (i != null) { s.paddingLeft = i; return true; }
			case "padding-right":
				var i = getVal(v);
				if (i != null) { s.paddingRight = i; return true; }
			case "padding-bottom":
				var i = getVal(v);
				if (i != null) { s.paddingBottom = i; return true; }
			case "margin":
				switch (v) {
				case VGroup ([a, b]):
					var a = getVal (a), b = getVal (b);
					if( a != null && b != null ) {
						s.marginTop = s.marginBottom = a;
						s.marginLeft = s.marginRight = b;
						return true;
					}
				default:
					var i = getVal (v);
					if( i != null ) { s.margin(i); return true; }
				}
			case "margin-top":
				var i = getVal (v);
				if (i != null) { s.marginTop = i; return true; }
			case "margin-left":
				var i = getVal (v);
				if (i != null) { s.marginLeft = i; return true; }
			case "margin-right":
				var i = getVal (v);
				if (i != null) { s.marginRight = i; return true; }
			case "margin-bottom":
				var i = getVal (v);
				if (i != null) { s.marginBottom = i; return true; }
			case "width":
				var i = getVal (v);
				if (i != null) {
					s.width = i;
					return true;
				}				
			case "height":				
				var i = getVal (v);				
				if (i != null) {
					s.height = i;
					return true;
				}			
			case "background-color":
				var f = getFill (v);
				if (f != null) {
					s.backgroundColor = f;
					return true;
				}
			case "background":
				return applyComposite(["background-color"], v, s);
			case "font-family":
				var l = getFontName(v);
				if (l != null) {
					s.fontName = l;
					return true;
				}
			case "font-size":
				s.fontSize = getVal(v);
				return true;
			case "color":
				var c = getCol (v);
				if (c != null) {
					s.color = c;
					return true;
				}
			case "border-radius":
				var i = getVal (v);
				if (i != null) {
					s.borderRadius = i;
					return true;
				}
			case "border":
				if (applyComposite(["border-width", "border-style", "border-color"], v, s))
					return true;
				if (getIdent (v) == "none") {
					s.borderSize = Px (0);
					s.borderColor = Transparent;
					return true;
				}
			case "border-width":
				var i = getVal (v);
				if (i != null) {
					s.borderSize = i;
					return true;
				}
			case "border-style":
				if (getIdent (v) == "solid")
					return true;
			case "border-color":
				var c = getFill (v);
				if (c != null) {
					s.borderColor = c;
					return true;
				}			
			case "text-align":
				switch (getIdent(v)) {
				case "left":
					s.textAlign = Left;
					return true;
				case "right":
					s.textAlign = Right;
					return true;
				case "center":
					s.textAlign = Center;
					return true;
				default:
				}
			default: {}				
		}
		return false;
	}

	function applyComposite( names : Array<String>, v : Value, s : Style ) {
		var vl = switch (v) {
		case VGroup(l): l;
		default: [v];
		};
		while (vl.length > 0) {
			var found = false;
			for (n in names) {
				var count = 1;
				if (count > vl.length) count = vl.length;
				while( count > 0 ) {
					var v = (count == 1) ? vl[0] : VGroup (vl.slice(0, count));
					if (applyStyle(n, v, s)) {
						found = true;
						names.remove (n);
						for (i in 0...count)
							vl.shift ();
						break;
					}
					count--;
				}
				if (found) break;
			}
			if (!found)
				return false;
		}
		return true;
	}

	function getGroup<T> (v : Value, f : Value -> Null<T>) : Null<Array<T>> {
		switch(v) {
		case VGroup(l):
			var a = [];
			for( v in l ) {
				var v = f(v);
				if( v == null ) return null;
				a.push(v);
			}
			return a;
		default:
			var v = f(v);
			return (v == null) ? null : [v];
		}
	}

	function getList<T>( v : Value, f : Value -> Null<T> ) : Null<Array<T>> {
		switch(v) {
		case VList(l):
			var a = [];
			for( v in l ) {
				var v = f(v);
				if( v == null ) return null;
				a.push(v);
			}
			return a;
		default:
			var v = f(v);
			return (v == null) ? null : [v];
		}
	}

	function getInt( v : Value ) : Null<Int> {
		return switch( v ) {
		case VUnit(f, u):
			switch( u ) {
			case "px": Std.int(f);
			case "pt": Std.int(f * 4 / 3);
			default: null;
			}
		case VInt(v):
			Std.int(v);
		default:
			null;
		};
	}

	/**
	 *  Get value
	 *  @param v - 
	 *  @return Null<Float>
	 */
	function getVal (v : Value) : Null<Unit> {		
		return switch( v ) {
		case VUnit (f, u):
			switch (u) {
				case "px": Unit.Px (f);
				case "pt": Unit.Pt (f);
				case "vw": Unit.Vw (f);
				case "vh": Unit.Vh (f);
				//case "pt": f * 4 / 3;
				default: null;
			}
		case VInt(v):
			Unit.Number (v);
		case VFloat(v):
			Unit.Number (v);
		default:
			null;
		};
	}

	function mapIdent<T:EnumValue>( v : Value, vals : Array<T> ) : T {
		var i = getIdent(v);
		if( i == null ) return null;
		for( v in vals )
			if( v.getName().toLowerCase() == i )
				return v;
		return null;
	}

	function getIdent( v : Value ) : Null<String> {
		return switch( v ) {
		case VIdent(v): v;
		default: null;
		};
	}

	/**
	 *  Get alpha color
	 *  @param v - 
	 */
	function getColAlpha (v : Value) {
		var c = getCol(v);
		if( c != null && c >>> 24 == 0 )
			c |= 0xFF000000;
		return c;
	}

	/**
	 *  Get fill type
	 *  @param v - 
	 */
	function getFill (v : Value) {
		var c = getColAlpha(v);
		if( c != null )
			return Color(c);
		switch( v ) {
		case VCall("gradient", [a, b, c, d]):
			var ca = getColAlpha(a);
			var cb = getColAlpha(b);
			var cc = getColAlpha(c);
			var cd = getColAlpha(d);
			if( ca != null && cb != null && cc != null && cd != null )
				return Gradient(ca, cb, cc, cd);
		case VIdent("transparent"):
			return Transparent;
		default:
		}
		return null;
	}

	function getCol( v : Value ) : Null<Int> {
		return switch( v ) {
		case VHex(v):
			(v.length == 6) ? Std.parseInt("0x" + v) : ((v.length == 3) ? Std.parseInt("0x"+v.charAt(0)+v.charAt(0)+v.charAt(1)+v.charAt(1)+v.charAt(2)+v.charAt(2)) : null);
		case VIdent(i):
			switch( i ) {
			case "black":	0x000000;
			case "red": 	0xFF0000;
			case "lime":	0x00FF00;
			case "blue":	0x0000FF;
			case "white":	0xFFFFFF;
			case "aqua":	0x00FFFF;
			case "fuchsia":	0xFF00FF;
			case "yellow":	0xFFFF00;
			case "maroon":	0x800000;
			case "green":	0x008000;
			case "navy":	0x000080;
			case "olive":	0x808000;
			case "purple": 	0x800080;
			case "teal":	0x008080;
			case "silver":	0xC0C0C0;
			case "gray", "grey": 0x808080;
			default: null;
			}
		case VCall("rgba", [r, g, b, a]):
			inline function getFloat (v : Unit) : Null<Float> {
				switch (v) {
					case Number (f): return f;
					default: return null;
				}
			}

			var r = getFloat (getVal(r));
			var g = getFloat (getVal(g));
			var b = getFloat (getVal(b));
			var a = getFloat (getVal(a));
			
			inline function conv(k:Float) {
				var v = Std.int(k * 255);
				if( v < 0 ) v = 0;
				if( v > 255 ) v = 255;
				return v;
			}
			inline function check(k:Float) {
				var v = Std.int(k);
				if( v < 0 ) v = 0;
				if( v > 255 ) v = 255;
				return v;
			}
			if( r != null && g != null && b != null && a != null ) {
				var a = conv(a); if( a == 0 ) a = 1; // prevent setting alpha to FF afterwards
				(a << 24) | (check(r) << 16) | (check(g) << 8) | check(b);
			}
			else
				null;
		default:
			null;
		};
	}

	/**
	 *  Get font name from value
	 *  @param v - 
	 */
	function getFontName (v : Value) {
		return switch (v) {
		case VString (s): s;
		case VGroup (_):
			var g = getGroup(v, getIdent);
			if( g == null ) null else g.join(" ");
		case VIdent(i): i;
		default: null;
		};
	}

	/**
	 *  Get asset data: path, url, string data
	 *  @param v - asset data
	 */
	function getAsset (v : Value) {
		switch (v) {
		case VCall("url", [VString(url)]):
			return url;
		default:
			return null;
		}
	}

	// ---------------------- generic parsing --------------------

	function unexpected( t : Token ) : Dynamic {
		throw "Unexpected " + Std.string(t);
		return null;
	}

	function expect( t : Token ) {
		var tk = readToken();
		if( tk != t ) unexpected(tk);
	}

	inline function push( t : Token ) {
		tokens.push(t);
	}

	function isToken(t) {
		var tk = readToken();
		if( tk == t ) return true;
		push(tk);
		return false;
	}

	public function parse( css : String, s : Style ) {
		this.css = css;
		this.s = s;
		pos = 0;
		tokens = [];
		parseStyle(TEof);
	}

	function valueStr(v) {
		return switch( v ) {
		case VIdent(i): i;
		case VString(s): '"' + s + '"';
		case VUnit(f, unit): f + unit;
		case VFloat(f): Std.string(f);
		case VInt(v): Std.string(v);
		case VHex(v): "#" + v;
		case VList(l):
			[for( v in l ) valueStr(v)].join(", ");
		case VGroup(l):
			[for( v in l ) valueStr(v)].join(" ");
		case VCall(f,args): f+"(" + [for( v in args ) valueStr(v)].join(", ") + ")";
		case VLabel(label, v): valueStr(v) + " !" + label;
		case VSlash: "/";
		}
	}

	function parseStyle( eof ) {
		while( true ) {
			if( isToken(eof) )
				break;
			var r = readIdent();
			expect(TDblDot);
			var v = readValue();
			var s = this.s;
			switch( v ) {
			case VLabel(label, val):
				if( label == "important" ) {
					v = val;
					if( simp == null ) simp = new Style();
					s = simp;
				}
			default:
			}

			// Ignore wrong style
			applyStyle(r, v, s);
			
			if( isToken(eof) )
				break;
			expect(TSemicolon);
		}
	}

	public function parseRules( css : String ) {
		this.css = css;
		pos = 0;
		tokens = [];
		var rules = [];
		while( true ) {
			if( isToken(TEof) )
				break;
			var classes = readClasses();
			expect(TBrOpen);
			this.s = new Style();
			this.simp = null;
			parseStyle(TBrClose);
			for( c in classes )
				rules.push( { c : c, s : s, imp : false } );
			if( this.simp != null )
				for( c in classes )
					rules.push( { c : c, s : simp, imp : true } );
		}
		return rules;
	}

	public function parseClasses( css : String ) {
		this.css = css;
		pos = 0;
		tokens = [];
		var c = readClasses();
		expect(TEof);
		return c;
	}

	// ----------------- class parser ---------------------------

	function readClasses() {
		var classes = [];
		while( true ) {
			spacesTokens = true;
			isToken(TSpaces); // skip
			var c = readClass(null);
			spacesTokens = false;
			if( c == null ) break;			
			classes.push(c);
			if( !isToken(TComma) )
				break;
		}
		if( classes.length == 0 )
			unexpected(readToken());
		return classes;
	}	

	function readClass (parent : CssClass) : CssClass {
		var c = new CssClass();
		c.parent = parent;
		var def = false;
		var last = null;
		while( true ) {
			var t = readToken();
			if( last == null )
				switch( t ) {
				case TStar: def = true;
				case TDot, TSharp, TDblDot: last = t;
				case TIdent(i): c.node = i; def = true;
				case TSpaces:
					return def ? readClass(c) : null;
				case TBrOpen, TComma, TEof:
					push(t);
					break;
				default:
					unexpected(t);
				}
			else
				switch( t ) {
				case TIdent(i):
					switch( last ) {
					case TDot: c.className = i; def = true;
					case TSharp: c.id = i; def = true;
					case TDblDot: c.pseudoClass = i; def = true;
					default: throw "assert";
					}
					last = null;
				default:
					unexpected(t);
				}
		}
		return def ? c : parent;
	}

	// ----------------- value parser ---------------------------

	function readIdent() {
		var t = readToken();
		return switch( t ) {
		case TIdent(i): i;
		default: unexpected(t);
		}
	}

	function readValue(?opt)  : Value {
		var t = readToken();
		var v = switch( t ) {
		case TSharp:
			VHex(readHex());
		case TIdent(i):
			VIdent(i);
		case TString(s):
			VString(s);
		case TInt(i):
			readValueUnit(i, i);
		case TFloat(f):
			readValueUnit(f, null);
		case TSlash:
			VSlash;
		default:
			if( !opt ) unexpected(t);
			push(t);
			null;
		};
		if( v != null ) v = readValueNext(v);
		return v;
	}

	function readHex() {
		var start = pos;
		while( true ) {
			var c = next();
			if( (c >= "A".code && c <= "F".code) || (c >= "a".code && c <= "f".code) || (c >= "0".code && c <= "9".code) )
				continue;
			pos--;
			break;
		}
		return css.substr(start, pos - start);
	}

	function readValueUnit( f : Float, ?i : Int ) {
		var t = readToken();
		return switch( t ) {
		case TIdent(i):
			VUnit(f, i);
		case TPercent:
			VUnit(f, "%");
		default:
			push(t);
			if( i != null )
				VInt(i);
			else
				VFloat(f);
		};
	}

	function readValueNext( v : Value ) : Value {
		var t = readToken();
		return switch( t ) {
		case TPOpen:
			switch( v ) {
			case VIdent(i):
				switch( i ) {
				case "url":
					readValueNext(VCall("url",[VString(readUrl())]));
				default:
					var args = switch( readValue() ) {
					case VList(l): l;
					case x: [x];
					}
					expect(TPClose);
					readValueNext(VCall(i, args));
				}
			default:
				push(t);
				v;
			}
		case TExclam:
			var t = readToken();
			switch( t ) {
			case TIdent(i):
				VLabel(i, v);
			default:
				unexpected(t);
			}
		case TComma:
			loopComma(v, readValue());
		default:
			push(t);
			var v2 = readValue(true);
			if( v2 == null )
				v;
			else
				loopNext(v, v2);
		}
	}

	function loopNext(v, v2) {
		return switch( v2 ) {
		case VGroup(l):
			l.unshift(v);
			v2;
		case VList(l):
			l[0] = loopNext(v, l[0]);
			v2;
		case VLabel(lab, v2):
			VLabel(lab, loopNext(v, v2));
		default:
			VGroup([v, v2]);
		};
	}

	function loopComma(v,v2) {
		return switch( v2 ) {
		case VList(l):
			l.unshift(v);
			v2;
		case VLabel(lab, v2):
			VLabel(lab, loopComma(v, v2));
		default:
			VList([v, v2]);
		};
	}

	// ----------------- lexer -----------------------

	inline function isSpace(c) {
		return (c == " ".code || c == "\n".code || c == "\r".code || c == "\t".code);
	}

	inline function isIdentChar(c) {
		return (c >= "a".code && c <= "z".code) || (c >= "A".code && c <= "Z".code) || (c == "-".code) || (c == "_".code);
	}

	inline function isNum(c) {
		return c >= "0".code && c <= "9".code;
	}

	inline function next() {
		return StringTools.fastCodeAt(css, pos++);
	}

	function readUrl() {
		var c0 = next();
		while( isSpace(c0) )
			c0 = next();
		var quote = c0;
		if( quote == "'".code || quote == '"'.code ) {
			pos--;
			switch( readToken() ) {
			case TString(s):
				var c0 = next();
				while( isSpace(c0) )
					c0 = next();
				if( c0 != ")".code )
					throw "Invalid char " + String.fromCharCode(c0);
				return s;
			default: throw "assert";
			}

		}
		var start = pos - 1;
		while( true ) {
			if( StringTools.isEof(c0) )
				break;
			c0 = next();
			if( c0 == ")".code ) break;
		}
		return StringTools.trim(css.substr(start, pos - start - 1));
	}

	function readToken() {	
		var t = tokens.pop();
		if( t != null )
			return t;
		while( true ) {
			var c = next();
			if( StringTools.isEof(c) )
				return TEof;
			if( isSpace(c) ) {
				if( spacesTokens ) {
					while( isSpace(next()) ) {
					}
					pos--;
					return TSpaces;
				}

				continue;
			}
			if( isNum(c) || c == '-'.code ) {
				var i = 0, neg = false;
				if( c == '-'.code ) { c = "0".code; neg = true; }
				do {
					i = i * 10 + (c - "0".code);
					c = next();
				} while( isNum(c) );
				if( c == ".".code ) {
					var f : Float = i;
					var k = 0.1;
					while( isNum(c = next()) ) {
						f += (c - "0".code) * k;
						k *= 0.1;
					}
					pos--;
					return TFloat(neg? -f : f);
				}
				pos--;
				return TInt(neg ? -i : i);
			}
			if( isIdentChar(c) ) {
				var pos = pos - 1;
				do c = next() while( isIdentChar(c) || isNum(c) );
				this.pos--;
				return TIdent(css.substr(pos,this.pos - pos));
			}
			switch( c ) {
			case ":".code: return TDblDot;
			case "#".code: return TSharp;
			case "(".code: return TPOpen;
			case ")".code: return TPClose;
			case "!".code: return TExclam;
			case "%".code: return TPercent;
			case ";".code: return TSemicolon;
			case ".".code: return TDot;
			case "{".code: return TBrOpen;
			case "}".code: return TBrClose;
			case ",".code: return TComma;
			case "*".code: return TStar;
			case "/".code:
				if( (c = next()) != '*'.code ) {
					pos--;
					return TSlash;
				}
				while( true ) {
					while( (c = next()) != '*'.code ) {
						if( StringTools.isEof(c) )
							throw "Unclosed comment";
					}
					c = next();
					if( c == "/".code ) break;
					if( StringTools.isEof(c) )
						throw "Unclosed comment";
				}
				return readToken();
			case "'".code, '"'.code:
				var pos = pos;
				var k;
				while( (k = next()) != c ) {
					if( StringTools.isEof(k) )
						throw "Unclosed string constant";
					if( k == "\\".code ) {
						throw "todo";
						continue;
					}
				}
				return TString(css.substr(pos, this.pos - pos - 1));
			default:
			}
			pos--;
			throw "Invalid char " + css.charAt(pos);
		}
		return null;
	}
}