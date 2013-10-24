package animations
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class AHDrawLine extends Sprite
	{
		private var _stage:Object = null;       //声明一个舞台(stage)，接受传过来的stage
		private var _radius:uint;               //圆弧半径
		public var _lineShape:Shape;            //线
		private var _animation:Boolean;         //是否需要动画
		private var _linePointsArr:Array = [];  //画线所需要的点(值为int类型)
		private var _arcPoints:Array = [];      //包含绘制弧度需要点的数组
		private var _midLinePoints:Array = [];  //包含所有中间点的数组
		private var timer1:Timer;               //控制x轴方向绘制的定时调用
		private var timer2:Timer;               //控制轴方向绘制的定时调用
		private var _currentPos:uint;           //记录当前绘制点在数组中的位置
		private var _animationPoint_x:uint;     //动态绘制点的x坐标
		private var _animationPoint_y:uint;     //动态绘制点的y坐标
		private var _startsWithArrow:Boolean;   //起点是否需要画箭头
		private var _endsWithArrow:Boolean;     //终点是否需要画箭头
		private var _arrowLength:Number;        //箭头长度
		private var _arrowWidth:Number;         //箭头宽度
		
		/**
		 * Description                :根据给定的点绘制拐角为弧的线
		 * @param stage               :需要绘制的舞台
		 * @param lines               :绘制线段的坐标的数组
		 * @param radius              :弧度半径
		 * @param startsWithArrow     :起点是否有箭头
		 * @param endsWithArrow       :终点是否有箭头
		 * @param thickness           :线段粗细，默认2像素
		 * @param color               :线段颜色，默认黑色
		 * @param animation           :绘制线段时是否显示动画，默认显示
		 * @param arrowLength         :箭头长度，默认为24
		 * @param arrowWidth          :箭头宽度，默认为16
		 * @author answer-huang
		 * */
		public function AHDrawLine(stage:Object,lines:Array,radius:uint,startsWithArrow:Boolean,endsWithArrow:Boolean,thickness:Number=2,color:uint=0,animation:Boolean=true,arrowLength:Number=24, arrowWidth:Number=16)
		{
			_stage = stage;
			_radius = radius;
			_animation = animation;
			_startsWithArrow = startsWithArrow;
			_endsWithArrow = endsWithArrow;
			_arrowLength = arrowLength;
			_arrowWidth = arrowWidth;
			
			_lineShape = new Shape();
			_lineShape.graphics.lineStyle(thickness,color);
			for(var i:int=0;i<lines.length;i++)
			{
				_linePointsArr.push(int(lines[i]));
			}
			CalculateMidPoints(_linePointsArr);
			_stage.addChild(_lineShape);
		}
		
		//根据给定画线数组计算出中间点，如果只有两个点，则直接画线
		public function CalculateMidPoints(arr:Array):void{
			if (arr.length > 4) 
			{
				//将绘制点的第一个坐标放进中间点
				_midLinePoints.push(arr[0],arr[1]);
				
				//定义拐角点的前一个点的x，y，和后一个点的x，y
				var perPoint_x:int;var perPoint_y:int;
				var aftPoint_x:int;var aftPoint_y:int;
				
				for (var i:int = 2; i < arr.length-2; i+=2) 
				{
					//如果拐角点上一个坐标的x轴跟其x轴相等，则这是一条横线
					if (arr[i]==arr[i-2]) 
					{
						//中间点的x轴不变，如果前一个点的y坐标小于拐角点，那么中间点的y坐标为拐角点的y坐标减去半径。
						//如果前一个点的y坐标大于拐角点的y，那么中间点的y坐标为拐角点的y坐标加上半径。
						perPoint_x = arr[i];
						perPoint_y = (arr[i-1] < arr[i+1])? (arr[i+1]-_radius) : (arr[i+1] + _radius);
						//原理同上。
						aftPoint_x = (arr[i] < arr[i+2])? (arr[i]+_radius):(arr[i]-_radius);
						aftPoint_y = arr[i+1];
					}
					//拐点y坐标跟上一个点y坐标相等，则这是一条竖线
					else if (arr[i+1]==arr[i-1]) 
					{
						perPoint_x = (arr[i-2]<arr[i])?(arr[i]-_radius):(arr[i]+_radius);
						perPoint_y = arr[i+1];
						aftPoint_x = arr[i];
						aftPoint_y = (arr[i+1]<arr[i+3])?(arr[i+1]+_radius):(arr[i+1]-_radius);
					}
					_arcPoints.push(perPoint_x,perPoint_y,arr[i],arr[i+1],aftPoint_x,aftPoint_y);
					_midLinePoints.push(perPoint_x,perPoint_y,aftPoint_x,aftPoint_y);
				}
				//将最后一个点加入中间点的数组。
				_midLinePoints.push(arr[arr.length-2],arr[arr.length-1]);
				
				trace("_arcPoints: "+_arcPoints);
				trace("_midLinePoints:"+_midLinePoints);
				if(_animation){
					timer1=new Timer(6);
					timer1.addEventListener(TimerEvent.TIMER,drawAnimationLine_x);
					timer2=new Timer(6);
					timer2.addEventListener(TimerEvent.TIMER,drawAnimationLine_y);
					DrawMidLineWithAnimation();
				}else{
					DrawMidLine(_midLinePoints);
					DrawArcs();
					DrawArrows();
				}
			}else{ 
				_lineShape.graphics.moveTo(arr[0],arr[1]);
				_lineShape.graphics.lineTo(arr[2],arr[3]);
				DrawArrows();
			}
		}
		
		//动态的绘制线段
		public function DrawMidLineWithAnimation():void{
			if(_currentPos < _midLinePoints.length){
				_lineShape.graphics.moveTo(_midLinePoints[_currentPos],_midLinePoints[_currentPos+1]);
				_animationPoint_x = _midLinePoints[_currentPos];
				_animationPoint_y = _midLinePoints[_currentPos+1];
				if(_midLinePoints[_currentPos]==_midLinePoints[_currentPos+2]){ //x轴相等
					timer1.start();
				}else if (_midLinePoints[_currentPos+1]==_midLinePoints[_currentPos+3]) //y轴相等
				{
					timer2.start();
				}
			}else{
				timer1.stop();timer1 = null;
				timer2.stop();timer2 = null;
				DrawArcs();
				DrawArrows();
			}
		}
		
		//动态绘制x轴不变的线段
		public function drawAnimationLine_x(evt:Event):void{
			//y轴是正向的
			if(_midLinePoints[_currentPos+1] < _midLinePoints[_currentPos+3]){
				if(_animationPoint_y<=_midLinePoints[_currentPos+3]){
					_lineShape.graphics.lineTo(_midLinePoints[_currentPos],_animationPoint_y);
					_lineShape.graphics.moveTo(_midLinePoints[_currentPos],_animationPoint_y);
				}else{
					_currentPos+=4;
					timer1.stop();
					DrawArcsAnimation();
					DrawMidLineWithAnimation();
				}
				_animationPoint_y+=2;
			}else if(_midLinePoints[_currentPos+1]>_midLinePoints[_currentPos+3]){
				if(_animationPoint_y>=_midLinePoints[_currentPos+3]){
					_lineShape.graphics.lineTo(_midLinePoints[_currentPos],_animationPoint_y);
					_lineShape.graphics.moveTo(_midLinePoints[_currentPos],_animationPoint_y);
				}else{
					_currentPos+=4;
					timer1.stop();
					DrawArcsAnimation();
					DrawMidLineWithAnimation();
				}
				_animationPoint_y-=2;
			}
		}
		
		//动态绘制y轴不变的线段
		public function drawAnimationLine_y(evt:Event):void{
			//x轴是正向的
			if(_midLinePoints[_currentPos]<_midLinePoints[_currentPos+2]){
				if(_animationPoint_x<=_midLinePoints[_currentPos+2]){
					_lineShape.graphics.lineTo(_animationPoint_x,_midLinePoints[_currentPos+1]);
					_lineShape.graphics.moveTo(_animationPoint_x,_midLinePoints[_currentPos+1]);
				}else{
					_currentPos+=4;
					timer2.stop();
					DrawArcsAnimation();
					DrawMidLineWithAnimation();
				}
				_animationPoint_x+=2;
			}else if(_midLinePoints[_currentPos]>_midLinePoints[_currentPos+2]){
				if(_animationPoint_x>=_midLinePoints[_currentPos+2]){
					_lineShape.graphics.lineTo(_animationPoint_x,_midLinePoints[_currentPos+1]);
					_lineShape.graphics.moveTo(_animationPoint_x,_midLinePoints[_currentPos+1]);
				}else{
					_currentPos+=4;
					timer2.stop();
					DrawArcsAnimation();
					DrawMidLineWithAnimation();
				}
				_animationPoint_x-=2;
			}
		}
		
		//画直线,无动画
		public function DrawMidLine(lines:Array):void{
			for (var i:int = 0; i < lines.length; i+=4) 
			{
				_lineShape.graphics.moveTo(lines[i],lines[i+1]);
				_lineShape.graphics.lineTo(lines[i+2],lines[i+3]);
			}
		}
		
		//动态得到数组中各个拐角的点。
		public function DrawArcsAnimation():void{
			var p1:Object = new Object();
			var p2:Object = new Object();
			var p0:Object = new Object();
			//计算当前应该绘制那个拐弯点
			var pos:uint =(_currentPos/4-1)*6;
			if( pos< _arcPoints.length){
				p0.x = _arcPoints[pos];p0.y = _arcPoints[pos+1];
				p1.x = _arcPoints[pos+2];p1.y = _arcPoints[pos+3];
				p2.x = _arcPoints[pos+4];p2.y = _arcPoints[pos+5];
				DrawArcsWithPoint(p0, p1, p2);
			}
		}
		
		//得到数组中各个拐角的点。
		public function DrawArcs():void{
			var p1:Object = new Object();
			var p2:Object = new Object();
			var p0:Object = new Object();
			for (var i:int = 0; i < _arcPoints.length; i+=6) 
			{
				p0.x = _arcPoints[i];p0.y = _arcPoints[i+1];
				p1.x = _arcPoints[i+2];p1.y = _arcPoints[i+3];
				p2.x = _arcPoints[i+4];p2.y = _arcPoints[i+5];
				DrawArcsWithPoint(p0, p1, p2);
			}
		}
		
		//根据三点画拐角
		public function DrawArcsWithPoint(p0:Object,p1:Object,p2:Object):void{
			_lineShape.graphics.moveTo(p0.x,p0.y);
			var pos_x:Number; 
			var pos_y:Number;
			for (var i:Number = 0; i <= 1; i+= 1/100) 
			{
				pos_x = Math.pow(i,2)*(p0.x-2*p1.x+p2.x) + 2*i*(p1.x-p0.x)+p0.x;
				pos_y = Math.pow(i,2)*(p0.y-2*p1.y+p2.y) + 2*i*(p1.y-p0.y)+p0.y;
				_lineShape.graphics.lineTo(pos_x, pos_y);
			}
		}
		
		/**
		 *Description: 画箭头
		 **/
		public function DrawArrows():void{
			var slopy:Number;
			var cosy:Number;
			var siny:Number;
			
			var startPoint:Object = new Object();
			var endPoint:Object = new Object();
			if(_startsWithArrow){
				startPoint.x = _linePointsArr[2];
				startPoint.y = _linePointsArr[3];
				endPoint.x = _linePointsArr[0];
				endPoint.y = _linePointsArr[1];	
				draw();
			}
			if(_endsWithArrow){
				var len:int = _linePointsArr.length;
				startPoint.x = _linePointsArr[len-4];
				startPoint.y = _linePointsArr[len-3];
				endPoint.x = _linePointsArr[len-2];
				endPoint.y = _linePointsArr[len-1];	
				draw();
			}
			
			/**
			 *Description: 画箭头
			 **/
			function draw():void
			{
				slopy = Math.atan2(startPoint.y - endPoint.y, startPoint.x - endPoint.x);
				cosy = Math.cos(slopy);
				siny = Math.sin(slopy);
				_lineShape.graphics.moveTo(endPoint.x,endPoint.y);
				_lineShape.graphics.lineTo(endPoint.x +  (_arrowLength * cosy - ( _arrowWidth / 2.0 * siny )),
					endPoint.y +  (_arrowLength * siny + ( _arrowWidth / 2.0 * cosy )));
				_lineShape.graphics.moveTo(endPoint.x,endPoint.y);
				_lineShape.graphics.lineTo(endPoint.x +  (_arrowLength * cosy + _arrowWidth / 2.0 * siny),
					endPoint.y -  (_arrowWidth / 2.0 * cosy - _arrowLength * siny));
			}
		}
	}
}