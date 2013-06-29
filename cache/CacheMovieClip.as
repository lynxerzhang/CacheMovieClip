package cache
{	
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * simple bitmapClip implemention
 */
public class CacheMovieClip extends Sprite
{
	private var originalMc:MovieClip;
	private var totalClipFrames:int = 0;
	private var currentClipFrame:int = 0;

	public function CacheMovieClip(mc:MovieClip):void{
		this.originalMc = mc;
		this.totalClipFrames = this.originalMc.totalFrames;
		this.bounds = new <Rectangle>[];
		this.bitmapData = new <BitmapData>[];
		createClip(this.originalMc);
	}

	private var bounds:Vector.<Rectangle>;
	private var bitmapData:Vector.<BitmapData>;
	private var bitmap:Bitmap;

	private function createClip(mc:MovieClip):void {
		var data:BitmapData, rect:Rectangle;
		for(var i:int = 1; i <= this.totalClipFrames; i ++){
			mc.gotoAndStop(i);
			rect = mc.getBounds(mc);
			rect.x = rect.x|0;
			rect.y = rect.y|0;
			rect.width = Math.ceil(rect.width);
			rect.height = Math.ceil(rect.height);
			bounds.push(rect);
			data = new BitmapData(rect.width, rect.height, true, 0);
			data.draw(mc, new Matrix(1, 0, 0, 1, -bounds[i - 1].x, -bounds[i - 1].y));
			bitmapData.push(data);
		}
		bitmap = new Bitmap();
		this.addChild(bitmap);
		//update first frame offset
		bitmap.x = bounds[0].x;
		bitmap.y = bounds[0].y;
		//show the first frame's clip
		bitmap.bitmapData = bitmapData[currentClipFrame];
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
		if(frame > this.totalClipFrames){
			frame = this.totalClipFrames;
		}
		else if(frame < 1){
			frame = 1;
		}
		this.currentClipFrame = frame - 1;
		showCacheMovie(this.currentClipFrame);
	}

	/**
	 * gotoAndPlay
	 * 
	 * @param	frame specfied frame you want to start play
	 */
	public function gotoAndPlay(frame:int):void{
		if(frame > this.totalClipFrames){
			frame = this.totalClipFrames;
		}
		else if(frame < 1){
			frame = 1;
		}
		this.currentClipFrame = frame - 1;
		showCacheMovie(this.currentClipFrame);
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
		if((currentClipFrame > 0) && (currentClipFrame % (this.totalClipFrames - 1)) == 0){
			currentClipFrame = 0;
		}
		else {
			currentClipFrame++;
		}
		showCacheMovie(currentClipFrame);
	}
	
	private function stepperBackward():void {
		if (currentClipFrame == 0) {
			currentClipFrame = this.totalClipFrames - 1;
		}
		else {
			currentClipFrame--;
		}
		bitmap.x = bounds[currentClipFrame].x;
		bitmap.y = bounds[currentClipFrame].y;
		bitmap.bitmapData = bitmapData[currentClipFrame];
	}
	
	private function showCacheMovie(frame:int):void {
		bitmap.x = bounds[currentClipFrame].x;
		bitmap.y = bounds[currentClipFrame].y;
		bitmap.bitmapData = bitmapData[currentClipFrame];
	}

	/**
	 * check whether hitTest the clip pixel
	 * @return
	 */
	public function checkHitTest():Boolean {
		mousePoint.x = bitmap.mouseX;
		mousePoint.y = bitmap.mouseY;
		return bitmap.bitmapData.hitTest(originPoint, 0xFF, mousePoint);
	}
	
	private var originPoint:Point = new Point(0, 0);
	private var mousePoint:Point = new Point();
	
	/**
	 * get totalFrame
	 */
	public function get totalFrames():int{
		return this.totalClipFrames;
	}

	/**
	 * get currentFrame
	 */
	public function get currentFrame():int{
		return this.currentClipFrame + 1;
	}
	
	/**
	 * goto nextFrame 
	 */
	public function nextFrame():void {
		stopMotion();
		stepperForward();
	}
	
	/**
	 * goto prevFrame  
	 */
	public function prevFrame():void {
		stopMotion();
		stepperBackward();
	}
	
	/**
	 * dispose clip bitmapData
	 */
	public function dispose():void {
		if (isDispose) {
			return;
		}
		isDispose = true;
		if(this.hasEventListener(Event.ENTER_FRAME)){
			this.removeEventListener(Event.ENTER_FRAME, stepperForward);
		}
		this.removeChild(this.bitmap);
		this.bitmap.bitmapData = null;
		this.bitmap = null;
		this.bounds.length = 0;
		this.bitmapData.forEach(clearBitmapData);
		this.bitmapData.length = 0;
		this.originalMc = null;
		if (this.parent) {
			this.parent.removeChild(this);
		}
	}
	
	private var isDispose:Boolean = false;
	
	private function clearBitmapData(c:BitmapData, ...args):void {
		c.dispose();
	}
	
}
}