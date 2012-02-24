package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class FeedBackScreen extends MovieClip
	{
		public function FeedBackScreen() 
		{
			this.x = 700 / 2;
			this.y = 600 / 2;
			
			//this.closeButton.addEventListener(MouseEvent.CLICK, closeScreen);
			//stage.addEventListener(KeyboardEvent.KEY_UP, escCloseScreen);
			
			this.gotoAndStop("END");
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
			dispatchEvent(new Event(Event.CLOSE, true));
		}
		
		public function openScreen():void
		{
			this.gotoAndStop("BEGIN");
			this.closeButton.addEventListener(MouseEvent.CLICK, closeScreen, false, 0, true);
			this.okButton.addEventListener(MouseEvent.CLICK, closeScreen, false, 0, true);
		}
		
		public function setText(texto:String, imageFrame:String):void
		{
			openScreen();
			if (imageFrame == "") {
				imagemFeedback.visible = false;
				
				fundoFeed.gotoAndStop("SEM_IMAGEM");
				
				this.texto.y = -100;
				this.texto.x = -175;
				this.texto.width = 350;
				
				closeButton.x = 200;
				closeButton.y = -165;
				
				okButton.x = 160;
				okButton.y = 155;
			}
			else {
				imagemFeedback.visible = true;
				imagemFeedback.gotoAndStop(imageFrame);
				
				fundoFeed.gotoAndStop("COM_IMAGEM");
				
				this.texto.y = 135;
				this.texto.x = -250;
				this.texto.width = 500;
				
				closeButton.x = 270;
				closeButton.y = -267;
				
				okButton.x = 226;
				okButton.y = 255;
			}
			this.texto.text = texto;
		}
		
	}

}