package cache
{
import flash.display.MovieClip;

/**
 * CacheMovieClip's simple manager
 */
public class CacheManager 
{
	/**
	 * @see CacheMovieClip
	 * @param	mc
	 * @return
	 */
	public static function getCache(mc:MovieClip):CacheMovieClip {
		var _cache:CacheMovieClip = new CacheMovieClip(mc);
		_cache.x = mc.x;
		_cache.y = mc.y;
		return _cache;
	}
	
	/**
	 * @see CacheMovieClip
	 * @param	cacheMc
	 */
	public static function removeCache(cacheMc:CacheMovieClip):void {
		cacheMc.dispose();
	}
	
	/**
	 * @see CacheMovieClip
	 * @param	cacheMc
	 * @return
	 */
	public static function checkHitTest(cacheMc:CacheMovieClip):Boolean {
		return cacheMc.checkHitTest();
	}
}
}