package animations
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	[SWF(width="550", height="320", frameRate="60", backgroundColor="0xffffff")]
	public class DrawRadian extends Sprite
	{
		private var line:AHDrawLine;
		private var line2:AHDrawLine;
		private var line3:AHDrawLine;
		private var line4:AHDrawLine;
		public function DrawRadian()
		{
			drawLine();
			var mytf:TextFormat = new TextFormat();
			mytf.font = "Arial Narrow";
			mytf.color = "0xFF0033";
			mytf.size = 42;
			mytf.letterSpacing = 2;
			
			//输出文本
			var mytext:TextField = new TextField();
			mytext.defaultTextFormat = mytf;
			mytext.multiline = true;
			mytext.autoSize = TextFieldAutoSize.LEFT;
			mytext.x = 185;mytext.y = 260;
			mytext.text = "点我重绘";
			mytext.addEventListener(MouseEvent.MOUSE_DOWN, rem);
			addChild(mytext);
		}
		
		public function drawLine():void{
			var arr1:Array = ["275","20","275","70","150","70","150","120"];
			var arr2:Array = [275,20,275,180,320,180];
			var arr3:Array = [275,20,275,70,400,70,400,120];
			var arr4:Array = [20,200,150,200,150,260,250,260,250,220,320,220];
			
			line1 = new AHDrawLine(stage,arr1,15,false,true,3,0x000000,true);	
			line2 = new AHDrawLine(stage,arr2,15,false,true,3,0x000000,true);		
			line3 = new AHDrawLine(stage,arr3,15,false,true,3,0x000000,true);		
			line4 = new AHDrawLine(stage,arr4,10,false,true,3,0x000000,true);
		}
		
		public function rem(eve:MouseEvent):void{
			stage.removeChild(line1._lineShape);
			stage.removeChild(line2._lineShape);
			stage.removeChild(line3._lineShape);
			stage.removeChild(line4._lineShape);
			drawLine();
		}
	}
}