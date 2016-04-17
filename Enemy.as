package
{
	//Import all the necessary files
    import flash.display.MovieClip;
    import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
 
   //Class is public and an extension of a movieClip   
	public class Enemy extends MovieClip
    {
       //Speed of the enemy
		private var speedConst:int = 2;	
		//Spawn points
		private var spawnX:int;
		private var spawnY:int;
		
		//Constructor function takes in an x and a y value
		public function Enemy(xLocation:int, yLocation:int)
		{
			//Set the enemy's x and y values to the values taken into the function
			this.x = xLocation;
			this.y = yLocation;
			//Also set the spawnX and spawnY variables to the x and y values taken into the function; this keeps
			//track of the enemy's initial pos
			spawnX = xLocation;
			spawnY = yLocation;
			//Set the enemy to running position
			this.gotoAndStop("running");
			
			//Call function moveEnemy as soon as the frame is entered (as soon as the enemies are created)
			addEventListener(Event.ENTER_FRAME, moveEnemy);
		}
 
        public function moveEnemy(e:Event):void
        {
			//Move the enemy according to the speed
			this.x +=speedConst;
			
			//If the enemy has moved 100 pxs past it's spawn point
			if(this.x == spawnX + 100)
			{
				//Multiply the speed constant by -1 (changing the enemy's direction)
				speedConst*= -1;
			}
			
			//Same thing, just if the enemy has moved 100 pxs past its spawn point in the other direction
			else if (this.x == spawnX - 100)
			{
				speedConst *= -1;
			}
        }
 
        public function removeEnemy():void
        {
			trace("removing enemy");
			//Remove the event listener
			removeEventListener(Event.ENTER_FRAME, moveEnemy); 
			//Set the enemy to hit position
			this.gotoAndStop("hit");
			//Make a new timer that runs timerDone function when it's done
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER,timerDone);
			//Start timer
			timer.start();
					
			function timerDone (e:TimerEvent):void
			{
				//Stop the timer
				timer.stop();
				//Call function actuallyRemove(), which will actually remove the enemy from the stage
				actuallyRemove();
			}
				
	
        }
		
		public function actuallyRemove():void
		{
			//Removes the enemy from level1 (the parent), consequentially removing it from the stage	
			parent.removeChild(this); 
		}
		
 
    }
 
}