package  
{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class FeedBackScreen extends MovieClip
	{
		private var certo:Boolean = true;
		
		public function FeedBackScreen() 
		{
			this.x = 700 / 2;
			this.y = 600 / 2;
			
			this.gotoAndStop("END");
			
			this.addEventListener(MouseEvent.CLICK, closeScreen);
			stage.addEventListener(KeyboardEvent.KEY_UP, escCloseScreen);
		}
		
		private function escCloseScreen(e:KeyboardEvent):void 
		{
			if (e.keyCode ==  Keyboard.ESCAPE) {
				if(this.currentFrame == 1) this.play();
			}
		}
		
		private function closeScreen(e:MouseEvent):void 
		{
			this.play();
		}
		
		public function openScreen():void
		{
			this.gotoAndStop("BEGIN");
		}
		
		public function setText(texto:String):void
		{
			openScreen();
			if (certo) certoErrado.gotoAndStop(1);
			else certoErrado.gotoAndStop(2);
			this.texto.text = texto;
		}
		
		public function set setCerto(certo:Boolean):void
		{
			this.certo = certo;
		}
		
	}

}