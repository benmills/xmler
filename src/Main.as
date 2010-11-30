package {
  import flash.display.*;

  public class Main extends Sprite {
    public function Main():void {
      Xmler.add('copydeck-en', init);
    }

    public function init(data:*):void {
      trace(Xmler.get("Adv").SIL.contents);
    }
  }
}
