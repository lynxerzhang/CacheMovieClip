package cache
{
import flash.display.MovieClip;
import flash.display.Stage;

/**
 * TODO
 */
public class CacheManager 
{
	public static function getCache(mc:MovieClip):CacheMovieClip {
		var _cache:CacheMovieClip = new CacheMovieClip(mc);
		_cache.x = mc.x;
		_cache.y = mc.y;
		return _cache;
	}
	
	public static function removeCache(cacheMc:CacheMovieClip):void {
		cacheMc.dispose();
	}
	
	public static function checkHitTest(cacheMc:CacheMovieClip):Boolean {
		return cacheMc.checkHitTest();
	}
}
}