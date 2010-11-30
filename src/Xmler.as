package {
  import flash.events.*;
  import flash.display.*;
	import flash.net.*;
  import flash.utils.describeType;

  public class Xmler {

    // Singleton
    public static var instance:Xmler,
                      defaultDeck:String,
                      strict:Boolean = true; // If true, Xmler will throw runtime errors if it can't find something

    public static function add(name:String, callback:Function = null):void {
      if (Xmler.instance == null) Xmler.instance = new Xmler();
      Xmler.instance.loadCopy(name, callback);
    }

    public static function get(objectName:String, deckName:String = null):Object {
      if (Xmler.instance == null) Xmler.instance = new Xmler();
      if (deckName == null) deckName = Xmler.getDefaultDeck();
      return Xmler.instance.get(objectName, deckName);  
    }

    public static function getDefaultDeck():String {
      if (Xmler.instance == null) Xmler.instance = new Xmler();
      if (Xmler.defaultDeck != null) return Xmler.defaultDeck;
      return Xmler.instance.lastAddedDeck;
    }

    public static function mapVO(vo:*, objName:String, deckName:String = null):void {
        if (Xmler.instance == null) Xmler.instance = new Xmler();
        if (deckName == null) deckName = Xmler.getDefaultDeck();

        Xmler.instance.map(vo, objName, deckName);
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
        notice("Copydeck at assets/"+xml_name+".xml could not be found", true);
      });

      loader.load(new URLRequest("assets/"+xml_name+".xml"));
    }

    private function parseResults(e:Event, deck:Object, callback:Function = null):void {
      var raw:XML = new XML(e.target.data);
      doCallbak(loadCallback, raw)
      for (var i:* in raw.section) {
        var section:Object = deck[raw.section[i].@name] = {};

        for (var ii:* in raw.section[i].children()) {
            parseObject(raw.section[i].child(ii), section);
        }
      }
      
      doCallbak(callback, deck);
    }

    private function parseObject(prop:XMLList, section:Object, name:String = null):void {
      var attrs:XMLList = prop.attributes();
      if (name == null) name = prop.name();
      
      // Check if it is a table
      if (prop.name() == 'table') {
        var table:Object = {
          type: "table",
          header: [],
          rows: null
        };
       
        for (var i:String in prop.child(0).children()) {
          table.header.push(prop.child(0).child(i).name())
        }

        section[prop.@key] = table;
        return;
      }

      // Check if it is an array
      if(prop.children().length() > 1) {
        var objs:Object = {};
        var ii:int = 0;
        for (var i:String in prop.children()) {
          parseObject(prop.child(i), objs, i.toString());
        }
        var arr:Array = [];
        var c:int = 0;
        for (var o:String in objs) arr[c++] = objs[o];
        section[name] = arr;
        return;
      }

      if (attrs.length() > 0) {
        // Complex value
        var obj:Object = {};
        for (var iii:int = 0; iii < attrs.length(); iii++) {
          obj[String(attrs[iii].name())] = attrs[iii].toXMLString();
        }
        obj.contents = prop;
        obj.key = prop.name();
        
        section[name] = obj;
        return;
      } else {
        // Simple value
        section[name] = prop;
        return;
      }
    }

    public function get(objectName:String, deckName:String):Object {
      if (decks[deckName]) {
        if (decks[deckName][objectName]) return decks[deckName][objectName];
        notice("Object `"+objectName+"` on deck "+deckName+" could not be found", true);
        return null;
      }

      notice(deckName+" could not be found in Xmler", true);
      return  null;
    }

    public function map(vo:*, objName:String, deckName:String):void {
      
        // We are using describeType to get the class as XML then we are looping
        // over the XML to get a hash of the property name and type

        var desc:XML = describeType(vo);
        var propMap:Object = {};

        for each (var item:XML in desc.variable) {
          var itemName:String = item.name().toString();
          propMap[item.@name.toString()] = item.@type.toString();
        }
        
        // Map to copydeck
        var obj:Object = get(objName, deckName);
        
        for (var i:String in propMap) {
          if (!obj[i]) notice("VO cannot find property `"+i+"` on obj "+objName+" in copy deck "+deckName, true)
          else vo[i] = obj[i];
        }
    }
    
    // Makes sure the callback exists, then if results exist pass it
    private function doCallbak(callback:Function = null, results:* = null):void {
      if (callback != null) {
        if (results != null) callback(results);
        else callback();
      }  
    }

    // Any errors or messages come out of here
    public function notice(msg:String, error:Boolean = false):void {
      if (Xmler.strict && error) {
        throw new Error(msg);    
      } else {
        trace(msg);     
      }
    }

  }
}
