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
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends Sprite
	{
		private const PAR:String = "par";
		private const IMPAR:String = "impar";
		private const INDEFINIDA:String = "indefinida";
		
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
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			createGraph();
			createFunctions();
			configRadioButtons();
			addListeners();
			sortExercise();
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
			
			var graphBorder:Sprite = new Sprite();
			graphBorder.graphics.lineStyle(1, 0x000000);
			graphBorder.graphics.drawRect(0, 0, xsize, ysize);
			graphBorder.x = graph.x;
			graphBorder.y = graph.y;
			addChild(graphBorder);
			
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
			funcoes_pares.push(function(x:Number):Number { return x * x; } );//"x^2", 
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
			
			rd_par.label = "par";
			rd_impar.label = "impar";
			rd_ambas.label = "ambas";
			rd_indefinida.label = "indefinida";
		}
		
		private function addListeners():void 
		{
			//botoes.tutorialBtn.addEventListener(MouseEvent.CLICK, iniciaTutorial);
			botoes.orientacoesBtn.addEventListener(MouseEvent.CLICK, openOrientacoes);
			botoes.creditos.addEventListener(MouseEvent.CLICK, openCreditos);
			botoes.resetButton.addEventListener(MouseEvent.CLICK, sortExercise);
			
			rd_par.addEventListener(MouseEvent.CLICK, changeSelectedAnswer);
			rd_impar.addEventListener(MouseEvent.CLICK, changeSelectedAnswer);
			rd_ambas.addEventListener(MouseEvent.CLICK, changeSelectedAnswer);
			rd_indefinida.addEventListener(MouseEvent.CLICK, changeSelectedAnswer);
			
			finaliza.addEventListener(MouseEvent.CLICK, finalizaExec);
			
			createToolTips();
		}
		
		private function changeSelectedAnswer(e:MouseEvent):void 
		{
			var rdClicked:RadioButton = RadioButton(e.target);
			selectedAnswer = rdClicked.label;
		}
		
		private function openOrientacoes(e:MouseEvent):void 
		{
			orientacoesScreen.openScreen();
			setChildIndex(orientacoesScreen, numChildren - 1);
		}
		
		private function openCreditos(e:MouseEvent):void 
		{
			creditosScreen.openScreen();
			setChildIndex(creditosScreen, numChildren - 1);
		}
		
		private function createToolTips():void 
		{
			var infoTT:ToolTip = new ToolTip(botoes.creditos, "Créditos", 12, 0.8, 100, 0.6, 0.1);
			var instTT:ToolTip = new ToolTip(botoes.orientacoesBtn, "Orientações", 12, 0.8, 100, 0.6, 0.1);
			var resetTT:ToolTip = new ToolTip(botoes.resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.1);
			var intTT:ToolTip = new ToolTip(botoes.tutorialBtn, "Reiniciar tutorial", 12, 0.8, 150, 0.6, 0.1);
			var finalizaTT:ToolTip = new ToolTip(finaliza, "Finaliza atividade", 12, 0.8, 200, 0.6, 0.1);
			//var trocaTuboTT:ToolTip = new ToolTip(trocaTubo, "Novo tubo de ensaio", 12, 0.8, 250, 0.6, 0.1);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			addChild(intTT);
			addChild(finalizaTT);
			//addChild(trocaTuboTT);
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
			if (currentAnswer == selectedAnswer) {
				trace("Acertou");
			}else {
				trace("Errou");
			}
		}
		
	}

}