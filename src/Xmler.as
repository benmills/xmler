package {
  import flash.events.*;
  import flash.display.*;
	import flash.net.*;

  public class Xmler extends Sprite{
    // Singleton
    public static var instance:Xmler;
    public static var defaultDeck:String;

    public static function add(name:String, callback:Function = null):void {
      if (Xmler.instance == null) Xmler.instance = new Xmler();
      Xmler.instance.loadCopy(name, callback);
    }

    public static function get(objectName:String, deckName:String = null):Object {
      if (deckName == null) deckName = Xmler.getDefaultDeck();
      return Xmler.instance.get(objectName, deckName);  
    }

    public static function getDefaultDeck():String {
      if (Xmler.defaultDeck != null) return Xmler.defaultDeck;
      return Xmler.instance.lastAddedDeck;
    }


    // Instance
    private var decks:Array,
                lastAddedDeck:String;

    public var loadCallback:Function;

    public function Xmler() {
      decks = [];
    }

    public function loadCopy(xml_name:String, callback:Function):void {
      lastAddedDeck = xml_name;

      var loader:URLLoader = new URLLoader(); 
      loader.addEventListener(Event.COMPLETE, function(e:Event):void {
        decks[xml_name] = {};
        parseResults(e, decks[xml_name], callback);
      });
      loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {
        callback(e);
      });

      loader.load(new URLRequest("assets/"+xml_name+".xml"));
    }

    private function parseResults(e:Event, deck:Object, callback:Function = null):void {
      var raw:XML = new XML(e.target.data);
      doCallbak(loadCallback, raw);

      for (var i:* in raw.section) {
        var section:Object = deck[raw.section[i].@name] = {};
        
        for (var ii:* in raw.section[i].children()) {
            var prop:XMLList = raw.section[i].child(ii);
            var attrs:XMLList = prop.attributes();

            if (attrs.length() > 0) {
              // Complex value
              var obj:Object = {};
              for (var iii:int = 0; iii < attrs.length(); iii++) {
                obj[String(attrs[iii].name())] = attrs[iii].toXMLString();
              }
              obj.contents = prop.child(ii);

              section[prop.name()] = obj;
            } else {
              // Simple value
              section[prop.name()] = prop.child(ii);
            }
        }
      }
      
      doCallbak(callback, deck);
    }

    public function get(objectName:String, deckName:String):Object {
      return decks[deckName][objectName];  
    }
    
    // Makes sure the callback exists, then if results exist pass it
    private function doCallbak(callback:Function = null, results:* = null):void {
      if (callback != null) {
        if (results != null) callback(results);
        else callback();
      }  
    }

  }
}
