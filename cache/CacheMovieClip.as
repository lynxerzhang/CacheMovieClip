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
	private var _totalFrames:int = 0;
	private var _currentFrame:int = 0;

	public function CacheMovieClip(mc:MovieClip):void{
		this.originalMc = mc;
		this._totalFrames = this.originalMc.totalFrames;
		this.mouseChildren = this.mouseEnabled = false;
		createInternalClip(this.originalMc);
	}

	private var rectVec:Vector.<Rectangle> = new <Rectangle>[];
	private var bitmapData:Vector.<BitmapData> = new <BitmapData>[];
	private var internalBitmap:Bitmap;

	private function createInternalClip(mc:MovieClip):void{
		var totalFrames:int = mc.totalFrames;
		var _bitD:BitmapData;
		var _bitM:Matrix;	
		var _rect:Rectangle;
		
		for(var i:int = 1; i <= mc.totalFrames; i ++){
			mc.gotoAndStop(i);
			_rect = mc.getBounds(mc);
			_rect.x = Math.ceil(_rect.x);
			_rect.y = Math.ceil(_rect.y);
			_rect.width = Math.ceil(_rect.width);
			_rect.height = Math.ceil(_rect.height);
			rectVec.push(_rect);
			
			_bitM = new Matrix(1, 0, 0, 1, -rectVec[i - 1].x, -rectVec[i - 1].y);
			_bitD = new BitmapData(_rect.width, _rect.height, true, 0);
			_bitD.draw(mc, _bitM);
			bitmapData.push(_bitD);
		}
		
		internalBitmap = new Bitmap();
		this.addChild(internalBitmap);
		
		//update first frame offset
		internalBitmap.x = rectVec[0].x;
		internalBitmap.y = rectVec[0].y;
		
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
		internalBitmap.x = rectVec[_currentFrame].x;
		internalBitmap.y = rectVec[_currentFrame].y;
		internalBitmap.bitmapData = bitmapData[_currentFrame];
	}
	
	private function showCacheMovie(frame:int):void {
		internalBitmap.x = rectVec[_currentFrame].x;
		internalBitmap.y = rectVec[_currentFrame].y;
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