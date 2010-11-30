package {
  import flash.display.*;

  public class Main extends Sprite {
    public function Main():void {
      Xmler.add('copydeck-en', init);
    }

    public function init(data:*):void {
      //trace(Xmler.get("Adv").SIL.contents);
      var adv:Object = Xmler.get('Adv');
      for each (var h:String in adv.people.header) {
        trace(h);  
      }
      //trace(adv.people.header[0]);
      //trace(adv.people.rows[0][0]);
      //trace('\nSimple');
      //trace(adv.norm);

      //trace('\nComplex');
      //trace(adv.comp.name, adv.comp.contents)

      //trace('\nArray');
      //trace(adv.list[0].contents);
    }
  }
}
