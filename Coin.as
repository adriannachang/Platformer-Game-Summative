package  {
	import flash.display.MovieClip;
	public class Coin extends MovieClip{

		public function Coin(xLocation:int, yLocation:int) 
		{
			//Set the coin's x and y position to the values taken into the constructor
			this.x = xLocation;
			this.y = yLocation;
		}
		
		public function removeCoin():void
        {
			//Remove the coin from the level it's in (the parent)
			parent.removeChild(this); 
	
        }

	}
	
}
