CacheMovieClip
==============

  **convert flash movieclip to bitmapClip**

#Example

    //flash created movieclip
    var mc:MovieClip = new someClip();
    
    var clip:CacheMovieClip = new CacheMovieClip(mc);
    addChild(clip);
    clip.play(); //play the clip
