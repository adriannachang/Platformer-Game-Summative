package  {
	//Import all the necessary files
    import flash.display.MovieClip;
    import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Boss extends MovieClip{
		
		//variable declarations
		private var shieldisOn:Boolean = false;
		private var speed:int = 3;
		private var spawnY:int;

		//Constructor function
		public function Boss(xLocation:int, yLocation:int):void
		{
			//Set the enemy's x and y values to the values taken into the function
			this.x = xLocation;
			this.y = yLocation;
			
			//Set the spawnY value to the y value taken into the function; keeps track of the boss's initial position
			spawnY = yLocation;
			//Go to the "moving" movieclip
			this.gotoAndStop("moving");
			//Call function moveBoss as soon as the frame is entered (as soon as the boss is created)
			addEventListener(Event.ENTER_FRAME, moveBoss);
			
		}
		
		public function moveBoss(e:Event):void
		{
			//move the boss's y position according to the speed
			this.y -= speed;
				
			//If boss moves 75 units above or below its spawn point, multiplu speed by -1 to change its direction
			if(this.y == spawnY + 75)
			{
				speed *= -1;
			}
				
			else if (this.y == spawnY - 75)
			{
				speed *= -1;
			}
			
			//If boss's shield is not on
			if (shieldisOn == false)
			{
				//Change the boolean to true
				shieldisOn = true;
				//Set timer for Boss's shield to be on and call shieldOnTimerDone when timer is done
				var shieldOnTimer:Timer = new Timer(3500);
				shieldOnTimer.addEventListener(TimerEvent.TIMER, shieldOnTimerDone);
				shieldOnTimer.start();
			}
			
			function shieldOnTimerDone(te:TimerEvent):void
			{
				//Stop the timer
				shieldOnTimer.stop();
				//Call function turnShieldOn
				turnShieldOn();
				
			}
		}
		
		public function turnShieldOn():void
		{
			//Go to the "shield" movieclip
			this.gotoAndStop("shield");
			
			//Set timer for Boss's shield to be off and call shieldOffTimerDone when timer is done
			var shieldOffTimer:Timer = new Timer(8000);
			shieldOffTimer.addEventListener(TimerEvent.TIMER, shieldOffTimerDone);
			shieldOffTimer.start();
			
			function shieldOffTimerDone(te:TimerEvent):void
			{
				//Stop the timer
				shieldOffTimer.stop();
				//Call function turnShieldOff
				turnShieldOff();
			}
		}
		
		public function turnShieldOff ():void	
		{
			//Set shieldisOn boolean back to false (which will start a new shieldOnTimer timer)
			shieldisOn = false;
			//Go back to the "moving" movieclip
			this.gotoAndStop("moving");
			
		}
		
		public function beenHit():void
		{
			//Go to the boss's hit movieclip
			this.gotoAndStop("hit");
		}
		
		public function removeBoss():void
        {
			trace("removing boss");

			//Remove the event listener that will move the boss
			removeEventListener(Event.ENTER_FRAME, moveBoss)
			//Set the enemy to hit position
			this.gotoAndStop("hit");
			//Make a new timer that runs timerDone function when it's done
			var timer:Timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER,timerDone);
			//Start timer
			timer.start();
					
			function timerDone (e:TimerEvent):void
			{
				//Stop the timer
				timer.stop();
				//Call function actuallyRemove(), which will actually remove the boss from the stage
				actuallyRemove();
			}
				
        }
		
		public function actuallyRemove():void
		{
			//Removes the boss from level3 (the parent)
			parent.removeChild(this); 
		}
			

	}
}
