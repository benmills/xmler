package {
  import flash.display.*;

  public class Main extends Sprite {
    public function Main():void {
      Xmler.add('copydeck-en', init);
      Xmler.strict = false; 
    }

    public function init(data:*):void {
      var vo:TestVo = new TestVo();
      Xmler.mapVO(vo, "Footer");
      trace(vo.copyright);
    }
  }
}
