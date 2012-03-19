package 
{
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.SimpleGraph;
	import cepa.utils.ToolTip;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import pipwerks.SCORM;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite
	{
		private const PAR:String = "par";
		private const IMPAR:String = "impar";
		private const INDEFINIDA:String = "indefinida";
		
		/*
		 * Filtro de conversão para tons de cinza.
		 */
		private const GRAYSCALE_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.0000, 0.0000, 0.0000, 1, 0
		]);
		
		private var graph:SimpleGraph;
		private var xmin:Number;
		private var xmax:Number;
		
		private var func:GraphFunction;
		private var style:DataStyle = new DataStyle();
		
		private var funcoes:Vector.<Function> = new Vector.<Function>;
		private var funcoes_pares:Vector.<Function> = new Vector.<Function>;
		private var funcoes_impares:Vector.<Function> = new Vector.<Function>;
		
		private var currentFuncVector:Vector.<Function>;
		private var currentFuncIndex:int;
		private var currentAnswer:String;
		private var selectedAnswer:String = "";
		
		private var rd_par:RadioButton;
		private var rd_impar:RadioButton;
		private var rd_ambas:RadioButton;
		private var rd_indefinida:RadioButton;
		private var rd_none:RadioButton;
		
		private var orientacoesScreen:InstScreen;
		private var creditosScreen:AboutScreen;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.scrollRect = new Rectangle(0, 0, 700, 600);
			
			creditosScreen = new AboutScreen();
			addChild(creditosScreen);
			orientacoesScreen = new InstScreen();
			addChild(orientacoesScreen);
			
			createGraph();
			createFunctions();
			configRadioButtons();
			addListeners();
			sortExercise();
			
			iniciaTutorial();
			
			if (ExternalInterface.available) {
				initLMSConnection();
			}
		}
		
		private function createGraph():void 
		{
			xmin = 	-5.5;
			xmax = 	5.5;
			var xsize:Number = 	670;
			var ysize:Number = 	400;
			var yRange:Number = Math.abs((xmin - xmax) * ysize / xsize);
			var ymin:Number = 	-yRange / 2;
			var ymax:Number = 	yRange / 2;
			
			var tickSize:Number = 2;
			
			graph = new SimpleGraph(xmin, xmax, xsize, ymin, ymax, ysize);
			graph.x = (stage.stageWidth - xsize) / 2;
			graph.y = graph.x;
			
			graph.enableTicks(SimpleGraph.AXIS_X, true);
			graph.enableTicks(SimpleGraph.AXIS_Y, true);
			graph.setTicksDistance(SimpleGraph.AXIS_X, tickSize);
			graph.setTicksDistance(SimpleGraph.AXIS_Y, tickSize);
			graph.setSubticksDistance(SimpleGraph.AXIS_X, tickSize / 2);
			graph.setSubticksDistance(SimpleGraph.AXIS_Y, tickSize / 2);
			graph.resolution = 0.1;
			graph.grid = false;
			
			addChild(graph);
			graph.draw();
			
			//var graphBorder:Sprite = new Sprite();
			//graphBorder.graphics.lineStyle(1, 0x000000);
			//graphBorder.graphics.drawRect(0, 0, xsize, ysize);
			//graphBorder.x = graph.x;
			//graphBorder.y = graph.y;
			//addChild(graphBorder);
			
			style.color = 0xFF0000;
			style.alpha = 1;
			style.stroke = 2;
		}
		
		private function createFunctions():void 
		{
			funcoes.push(function(x:Number):Number { return 1 + (2 * x); } ); //"1+2x"
			funcoes.push(function(x:Number):Number { return Math.pow(x, 2) + 0.3 * Math.pow(x, 3); } ); //"x^2+0.3x^3"
			funcoes.push(function(x:Number):Number { return Math.sin(x) + Math.cos(x); } ); //"sin(x) + cos(x)"
			funcoes.push(function(x:Number):Number { return Math.tan(x) - Math.pow(x, 2); } ); //"tan(x)-x^2"
			funcoes.push(function(x:Number):Number { return (Math.abs(x) / x) + 2; } ); //"abs(x)/x + 2"
			funcoes.push(function(x:Number):Number { return Math.log(x); } ); //"log(x)"
			funcoes.push(function(x:Number):Number { return Math.exp(x); } ); // "exp(x)"
			
			
			funcoes_pares.push(function(x:Number):Number { return 1; } );//"1", 
			funcoes_pares.push(function(x:Number):Number { return Math.pow(x, 2); } );//"x^2", 
			funcoes_pares.push(function(x:Number):Number { return Math.pow(x, 4) - 3; } );//"x^4 - 3", 
			funcoes_pares.push(function(x:Number):Number { return Math.cos(x); } );//"cos(x)", 
			funcoes_pares.push(function(x:Number):Number { return Math.cos(x) + 2 * Math.cos(2 * x); } );//"cos(x) + 2*cos(2*x)", 
			funcoes_pares.push(function(x:Number):Number { return Math.abs(x); } );//"abs(x)", 
			funcoes_pares.push(function(x:Number):Number { return Math.sqrt(Math.abs(x)); } );//"sqrt(abs(x))"
			
			
			funcoes_impares.push(function(x:Number):Number { return 2 * x; } );//"2*x", 
			funcoes_impares.push(function(x:Number):Number { return Math.pow(x, 3); } );//"x^3", 
			funcoes_impares.push(function(x:Number):Number { return Math.pow(x, 5); } );//"x^5", 
			funcoes_impares.push(function(x:Number):Number { return Math.sin(x); } );//"sin(x)", 
			funcoes_impares.push(function(x:Number):Number { return Math.tan(x); } );//"tan(x)", 
			funcoes_impares.push(function(x:Number):Number { return Math.sin(x) + 2 * Math.sin(2 * x); } );//"sin(x) + 2*sin(2*x)", 
			funcoes_impares.push(function(x:Number):Number { return 1 / x; } );//"1/x", 
			funcoes_impares.push(function(x:Number):Number { return Math.abs(x) / x; } );//"abs(x)/x"
		}
		
		private function configRadioButtons():void 
		{
			rd_par = radio_par;
			rd_impar = radio_impar;
			rd_ambas = radio_ambas;
			rd_indefinida = radio_indefinida;
			rd_none = new RadioButton();
			rd_none.group = rd_par.group;
			
			rd_par.buttonMode = true;
			rd_impar.buttonMode = true;
			rd_ambas.buttonMode = true;
			rd_indefinida.buttonMode = true;
			
			rd_par.label = PAR;
			rd_impar.label = IMPAR;
			rd_ambas.label = "ambas";
			rd_indefinida.label = INDEFINIDA;
		}
		
		private function addListeners():void 
		{
			botoes.tutorialBtn.addEventListener(MouseEvent.CLICK, iniciaTutorial);
			botoes.orientacoesBtn.addEventListener(MouseEvent.CLICK, openOrientacoes);
			botoes.creditos.addEventListener(MouseEvent.CLICK, openCreditos);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, sortExercise);
			
			rd_par.addEventListener(MouseEvent.CLICK, changeSelectedAnswer);
			rd_impar.addEventListener(MouseEvent.CLICK, changeSelectedAnswer);
			rd_ambas.addEventListener(MouseEvent.CLICK, changeSelectedAnswer);
			rd_indefinida.addEventListener(MouseEvent.CLICK, changeSelectedAnswer);
			
			finaliza.addEventListener(MouseEvent.CLICK, finalizaExec);
			btReiniciar.addEventListener(MouseEvent.CLICK, sortExercise);
			
			createToolTips();
		}
		
		private function changeSelectedAnswer(e:MouseEvent):void 
		{
			var rdClicked:RadioButton = RadioButton(e.target);
			selectedAnswer = rdClicked.label;
			
			finaliza.filters = [];
			finaliza.mouseEnabled = true;
			finaliza.alpha = 1;
			
			certoErrado2.x = rdClicked.x;
			certoErrado2.y = rdClicked.y;
		}
		
		private function openOrientacoes(e:MouseEvent):void 
		{
			orientacoesScreen.openScreen();
			setChildIndex(orientacoesScreen, numChildren - 1);
			setChildIndex(borda, numChildren - 1);
		}
		
		private function openCreditos(e:MouseEvent):void 
		{
			creditosScreen.openScreen();
			setChildIndex(creditosScreen, numChildren - 1);
			setChildIndex(borda, numChildren - 1);
		}
		
		private function createToolTips():void 
		{
			var infoTT:ToolTip = new ToolTip(botoes.creditos, "Créditos", 12, 0.8, 100, 0.6, 0.1);
			var instTT:ToolTip = new ToolTip(botoes.orientacoesBtn, "Orientações", 12, 0.8, 100, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(botoes.resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			var intTT:ToolTip = new ToolTip(botoes.tutorialBtn, "Reiniciar tutorial", 12, 0.8, 150, 0.6, 0.1);
			var finalizaTT:ToolTip = new ToolTip(finaliza, "Finaliza atividade", 12, 0.8, 200, 0.6, 0.1);
			var reiniciarTT:ToolTip = new ToolTip(btReiniciar, "Reiniciar", 12, 0.8, 250, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			addChild(intTT);
			addChild(finalizaTT);
			addChild(reiniciarTT);
		}
		
		private function sortExercise(e:MouseEvent = null):void 
		{
			if (func != null) graph.removeFunction(func);
			
			func = getFunction();
			
			graph.addFunction(func, style);
			
			graph.draw();
			resetRadioButtons();
		}
		
		private function resetRadioButtons():void 
		{
			rd_none.selected = true;
			finaliza.filters = [GRAYSCALE_FILTER];
			finaliza.mouseEnabled = false;
			finaliza.alpha = 0.5;
			finaliza.visible = true;
			
			rd_ambas.mouseEnabled = true;
			rd_impar.mouseEnabled = true;
			rd_indefinida.mouseEnabled = true;
			rd_par.mouseEnabled = true;
			
			btReiniciar.visible = false;
			botoes.resetButton.mouseEnabled = false;
			botoes.resetButton.filters = [GRAYSCALE_FILTER];
			botoes.resetButton.alpha = 0.5;
			
			certoErrado2.visible = false;
			
			selectedAnswer = "";
		}
		
		private function getFunction():GraphFunction 
		{
			var sortFunc:Number = Math.round(Math.random() * 3);
			
			if (sortFunc == 0) {
				currentFuncVector = funcoes;
				currentAnswer = INDEFINIDA;
			}else if (sortFunc == 1) {
				currentFuncVector = funcoes_pares;
				currentAnswer = PAR
			}else {
				currentFuncVector = funcoes_impares;
				currentAnswer = IMPAR;
			}
			
			currentFuncIndex = int(Math.floor(Math.random() * currentFuncVector.length));
			
			var func:GraphFunction = new GraphFunction(xmin, xmax, currentFuncVector[currentFuncIndex]);
			
			return func;
		}
		
		private function finalizaExec(e:MouseEvent = null):void
		{
			var strFeedBack:String;
			var strImageFrame:String = "";
			
			if (selectedAnswer == PAR) {
				if (currentAnswer == PAR) {//Acertou
					certoErrado2.gotoAndStop("CERTO");
					strFeedBack = "Para qualquer x escolhido, f(-x) sempre será igual a -f(x).";
				}else if (currentAnswer == IMPAR) {
					certoErrado2.gotoAndStop("ERRADO");
					strImageFrame = IMPAR;
					strFeedBack = "Note que f(-x) = -f(x), qualquer que seja x. Para entender esta expressão, observe a figura acima: se associarmos ao lápis a parte do gráfico de f na região x > 0, o reflexo dele (indicado pela flecha vermelha) corresponderia à função na região x < 0. Ou seja, é como se refletíssemos f em x > 0 em x e em y para obtermos f em x < 0. Pense um pouco a respeito.";
				}else if (currentAnswer == INDEFINIDA) {
					certoErrado2.gotoAndStop("ERRADO");
					strFeedBack = "Atente para a região x > 0, nela não é possível \"replicar\" o gráfico de f(x) sobre o eixo y de modo a obter o mesmo f(x) na região x < 0. Assim, ao colocar um objeto na posição vertical em frente ao espelho, o reflexo irá aparecer na posição horizontal. Ou seja, não existe relação de simetria entre o objeto \"f(x) em x > 0\" e seu reflexo \"f(x) em x < 0\".";
				}
			}else if (selectedAnswer == IMPAR) {
				if (currentAnswer == PAR) {
					certoErrado2.gotoAndStop("ERRADO");
					strImageFrame = PAR;
					strFeedBack = "Note que f(-x) = f(x), qualquer que seja x. Para entender esta expressão, observe a figura acima: se associarmos ao lápis a parte do gráfico de f na região x > 0, o reflexo dele (indicado pela flecha vermelha) corresponderia à função na região x < 0. Ou seja, é como se refletíssemos f em x > 0 em y (mas não em x) para obtermos f em x < 0. Pense um pouco a respeito.";
				}else if (currentAnswer == IMPAR) {//Acertou
					certoErrado2.gotoAndStop("CERTO");
					strFeedBack = "Para qualquer x escolhido, f(-x) sempre será igual a f(x).";
				}else if (currentAnswer == INDEFINIDA) {
					certoErrado2.gotoAndStop("ERRADO");
					strFeedBack = "Atente para a região x > 0, nela não é possível \"replicar\" o gráfico de f(x) sobre o eixo y de modo a obter o mesmo f(x) na região x < 0. Assim, ao colocar um objeto na posição vertical em frente ao espelho, o reflexo irá aparecer na posição horizontal. Ou seja, não existe relação de simetria entre o objeto \"f(x) em x > 0\" e seu reflexo \"f(x) em x < 0\".";
				}
			}else if (selectedAnswer == "ambas") {
				strFeedBack = "Nenhuma função pode ser ao mesmo tempo par e ímpar (exceto se f(x) = 0). Ou ela é par, ou ímpar, ou não tem simetria (nem par nem ímpar).";
				certoErrado2.gotoAndStop("ERRADO");
			}else if (selectedAnswer == INDEFINIDA) {
				if (currentAnswer == PAR) {
					certoErrado2.gotoAndStop("ERRADO");
					strImageFrame = PAR;
					strFeedBack = "Observe que f(-x) = f(x). Para entender essa expressão, imagine a delimitação de um espaço no gráfico de f(x) na região x > 0 e o refletissemos no eixo y, gerando a parte de f(x) da região x < 0. Como se pode verificar na imagem.";
				}else if (currentAnswer == IMPAR) {
					certoErrado2.gotoAndStop("ERRADO");
					strImageFrame = IMPAR;
					strFeedBack = "Observe que f(-x) = -f(x). Para entender essa expressão, imagine a delimitação de um espaço no gráfico de f(x) que, na região x > 0, refletisse duas vezes, uma em x e outra em y, gerando a parte f(x) da região x < 0. Ou seja, ao colocar um objeto na posição vertical em frente a um espelho, é possível visualizar seu reflexo.";
				}else if (currentAnswer == INDEFINIDA) {//Acertou
					certoErrado2.gotoAndStop("CERTO");
					strFeedBack = "Esta função não tem paridade definida.";
				}
			}
			
			certoErrado2.visible = true;
			
			finaliza.filters = [GRAYSCALE_FILTER];
			finaliza.mouseEnabled = false;
			finaliza.alpha = 0.5;
			finaliza.visible = false;
			
			btReiniciar.visible = true;
			botoes.resetButton.mouseEnabled = true;
			botoes.resetButton.filters = [];
			botoes.resetButton.alpha = 1;
			
			rd_ambas.mouseEnabled = false;
			rd_impar.mouseEnabled = false;
			rd_indefinida.mouseEnabled = false;
			rd_par.mouseEnabled = false;
			
			feedBackScreen.setText(strFeedBack, strImageFrame);
			setChildIndex(feedBackScreen, numChildren - 1);
			setChildIndex(borda, numChildren - 1);
			
			if (ExternalInterface.available) {
				if (!completed) {
					completed = true;
					score = 100;
					commit();
				}
			}
		}
		
		
		//Tutorial
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoPhaseFinal:Boolean;
		private var tutoSequence:Array = ["Esta é uma função f(x) escolhida aleatoriamente.",
										  "Qual é a simetria de f(x)? Escolha uma opção.",
										  "Clique em \"Terminei\" para verificar sua resposta."];
										  
		private function iniciaTutorial(e:MouseEvent = null):void 
		{
			tutoPos = 0;
			tutoPhaseFinal = false;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(420, 240),
								new Point(rd_par.x + 100, rd_par.y + 2 * rd_par.height),
								new Point(finaliza.x + (finaliza.width / 2) + 5, finaliza.y)];
								
				tutoBaloonPos = [[CaixaTexto.TOP, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.LAST]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			feedBackScreen.removeEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function closeBalao(e:Event):void 
		{
			if (tutoPhaseFinal) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
				feedBackScreen.removeEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
			}else{
				tutoPos++;
				if (tutoPos >= tutoSequence.length) {
					balao.removeEventListener(Event.CLOSE, closeBalao);
					balao.visible = false;
					feedBackScreen.addEventListener(Event.CLOSE, iniciaTutorialSegundaFase);
					tutoPhaseFinal = true;
				}else {
					balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
					balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
				}
			}
		}
		
		private function iniciaTutorialSegundaFase(e:Event):void 
		{
			if(tutoPhaseFinal){
				balao.setText("Você pode começar um novo exercício clicando aqui.", tutoBaloonPos[2][0], tutoBaloonPos[2][1]);
				balao.setPosition(160, pointsTuto[2].y);
				tutoPhaseFinal = false;
			}
		}
		
		
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:int;
		private var pingTimer:Timer;
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				var stringScore:String = scorm.get("cmi.score.raw");
			 
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				success = scorm.save();
				
				if (success)
				{
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				scorm.set("cmi.exit", "suspend");
				
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				//mementoSerialized = marshalObjects();
				//success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			//scorm.get("cmi.completion_status");
			commit();
		}
		
	}

}