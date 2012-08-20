package cache
{	
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.display.Bitmap;
import flash.geom.Point;
import flash.geom.Rectangle;
	
/**
 *  a simple CacheMovieClip's implementation (fixed clip dithering problem)
 * 
 *  @example
 *  
 *  var ns:CacheMovieClip = new CacheMovieClip(_mc);
 *  addChild(ns);
 *  ns.x = _mc.x;
 *  ns.y = _mc.y;
 *  ns.play();
 */
public class CacheMovieClip extends Sprite
{

	private var originalMc:MovieClip;
	private var maxWidth:Number = 0;
	private var maxHeight:Number = 0;
	private var _totalFrames:int = 0;
	private var _currentFrame:int = 0;

	public function CacheMovieClip(mc:MovieClip):void{
		this.originalMc = mc;
		this._totalFrames = this.originalMc.totalFrames;
		this.mouseChildren = this.mouseEnabled = false;
		getDrawInfo(this.originalMc);
		createInternalClip(this.originalMc);
	}

	private var rectVec:Vector.<Rectangle> = new <Rectangle>[];
	private var bitmapData:Vector.<BitmapData> = new <BitmapData>[];
	
	private var maxTop:Number = 0;
	private var maxLeft:Number = 0;
	private var maxRight:Number = 0;
	private var maxBottom:Number = 0;
	
	private function getDrawInfo(mc:MovieClip):void{
		var totalFrames:int = mc.totalFrames;
		var rect:Rectangle;
		
		for(var i:int = 1; i <= totalFrames; i ++){
			mc.gotoAndStop(i);
			rect = mc.getBounds(mc);
			rectVec.push(rect);
			
			if (rect.top < maxTop) {
				maxTop = rect.top;
			}
			if (rect.left < maxLeft) {
				maxLeft = rect.left;
			}
			if (rect.right > maxRight) {
				maxRight = rect.right;
			}
			if (rect.bottom > maxBottom) {
				maxBottom = rect.bottom;
			}
		}
		
		maxTop = Math.abs(maxTop);
		maxLeft = Math.abs(maxLeft);
		maxBottom = Math.abs(maxBottom);
		maxRight = Math.abs(maxRight);
		
		maxWidth = Math.ceil(maxLeft + maxRight);
		maxHeight = Math.ceil(maxTop + maxBottom);
	}

	private var internalBitmap:Bitmap;

	private function createInternalClip(mc:MovieClip):void{
		var totalFrames:int = mc.totalFrames;
		var _bitD:BitmapData;
		var _bitM:Matrix;	
		
		for(var i:int = 1; i <= mc.totalFrames; i ++){
			mc.gotoAndStop(i);
			_bitM = new Matrix(1, 0, 0, 1, 
								-rectVec[i - 1].x + (maxLeft - Math.abs(rectVec[i - 1].left)), 
								-rectVec[i - 1].y + (maxTop - Math.abs(rectVec[i - 1].top))) ;
			_bitD = new BitmapData(maxWidth, maxHeight, true, 0);
			_bitD.draw(mc, _bitM);
			bitmapData.push(_bitD);
		}
		
		internalBitmap = new Bitmap();
		this.addChild(internalBitmap);
		
		//update first frame offset
		internalBitmap.x = rectVec[0].x - (maxLeft - Math.abs(rectVec[0].left));
		internalBitmap.y = rectVec[0].y - (maxTop - Math.abs(rectVec[0].top));
		
		//show the first frame's clip
		internalBitmap.bitmapData = bitmapData[_currentFrame];
	}

	/**
	 * begin play the series of clip
	 */
	public function play():void{
		startMotion();
	}

	/**
	 * stop motion immediately
	 */
	public function stop():void{
		stopMotion();
	}

	/**
	 * gotoAndStop
	 * 
	 * @param	frame specifed frame you want to stop
	 */
	public function gotoAndStop(frame:int):void{
		stopMotion();
		if(frame > this._totalFrames){
			frame = this._totalFrames;
		}
		else if(frame < 1){
			frame = 1;
		}
		this._currentFrame = frame - 1;
		showCacheMovie(this._currentFrame);
	}

	/**
	 * gotoAndPlay
	 * 
	 * @param	frame specfied frame you want to start play
	 */
	public function gotoAndPlay(frame:int):void{
		if(frame > this._totalFrames){
			frame = this._totalFrames;
		}
		else if(frame < 1){
			frame = 1;
		}
		this._currentFrame = frame - 1;
		showCacheMovie(this._currentFrame);
		startMotion();
	}

	private function startMotion():void{
		if(!this.hasEventListener(Event.ENTER_FRAME)){
			this.addEventListener(Event.ENTER_FRAME, stepperForward);
		}
	}

	private function stopMotion():void{
		if(this.hasEventListener(Event.ENTER_FRAME)){
			this.removeEventListener(Event.ENTER_FRAME, stepperForward);
		}
	}

	private function stepperForward(evt:Event = null):void{
		if((_currentFrame > 0) && (_currentFrame % (this._totalFrames - 1)) == 0){
			_currentFrame = 0;
		}
		else {
			_currentFrame++;
		}
		showCacheMovie(_currentFrame);
	}
	
	private function stepperBackward():void {
		if (_currentFrame == 0) {
			_currentFrame = this._totalFrames - 1;
		}
		else {
			_currentFrame--;
		}
		internalBitmap.bitmapData = bitmapData[_currentFrame];
	}
	
	private function showCacheMovie(frame:int):void {
		internalBitmap.bitmapData = bitmapData[_currentFrame];
	}

	public function checkHitTest():Boolean {
		return internalBitmap.bitmapData.hitTest(new Point(0, 0), 
												 0xFF, 
												 new Point(internalBitmap.mouseX, internalBitmap.mouseY));
	}
	
	/**
	 * get the cacheMovie's totalframe
	 */
	public function get totalFrames():int{
		return this._totalFrames;
	}

	/**
	 * get the cacheMovie's currentFrame
	 */
	public function get currentFrame():int{
		return this._currentFrame + 1;
	}
	
	/**
	 * nextFrame 
	 * relative to the previous frame
	 */
	public function nextFrame():void {
		stopMotion();
		stepperForward();
	}
	
	/**
	 * prevFrame  
	 * relative to the previous frame
	 */
	public function prevFrame():void {
		stopMotion();
		stepperBackward();
	}
	
	/**
	 * 
	 */
	public function dispose():void {
		if(this.hasEventListener(Event.ENTER_FRAME)){
			this.removeEventListener(Event.ENTER_FRAME, stepperForward);
		}
		this.internalBitmap.bitmapData = null;
		this.originalMc = null;
		
		this.removeChild(this.internalBitmap);
		this.internalBitmap = null;
		
		this.rectVec.length = 0;
		this.rectVec = null;
		
		this.bitmapData.forEach(function(c:BitmapData, ...args):void {
			c.dispose();
		});
		
		this.bitmapData.length = 0;
		this.bitmapData = null;
		
		if (this.parent) {
			this.parent.removeChild(this);
		}
	}
}
}