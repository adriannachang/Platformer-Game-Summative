package  {
	
	//Import all the necessary files
    import flash.display.MovieClip;
    import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Enemy3 extends MovieClip{
		
		//Variable Declarations
		private var impulsion:int = 8;
		private var gravity:Number = 0.8;
		private var ySpeed:Number = 0;
		private var currentlyJumping:Boolean = false;
		private var enemyHit:Boolean = false;
		//Spawn points
		private var spawnX:int;
		private var spawnY:int;

		public function Enemy3(xLocation:int, yLocation:int) 
		{
			//Set the enemy's x and y values to the values taken into the function
			this.x = xLocation;
			this.y = yLocation;
			//Set the spawnY value to the enemy's initial position
			spawnY = yLocation;
			//Go to the "still" movieclip
			this.gotoAndStop("still");
			//Call function moveEnemy as soon as the frame is entered (as soon as the enemies are created)
			addEventListener(Event.ENTER_FRAME, moveEnemy);
		}
		
		public function moveEnemy(e:Event):void
		{
			//Move the enemy's y pos based on the ySpeed
			this.y += ySpeed;
			
			//If the enemy passes 50 units above its spawn point, apply gravity to its ySpeed to bring it back down
			if (this.y < spawnY-50)
			{
				ySpeed += gravity;
			}
			
			//If the enemy has jumped and then fallen back past their initial spawn point
			if( this.y > spawnY)
			{
				//Stop them from falling
				ySpeed = 0;
				//go to the "still" movieclip
				this.gotoAndStop("still");

			}
			//If the currentlyjumping boolean is set to false and the enemy has not yet been hit
			if (currentlyJumping == false && enemyHit == false)
			{
				//Change the jumping boolean to true
				currentlyJumping = true;
				
				//Set jumpTimer, which will call function jumpTimerDone when it is done
				var jumpTimer:Timer = new Timer(4000);jumpTimer.addEventListener(TimerEvent.TIMER, jumpTimerDone);
				//Start the timer
				jumpTimer.start();
			}

			function jumpTimerDone (e:TimerEvent):void
			{
				//Stop the timer
				jumpTimer.stop();
				//Call function enemyJump
				enemyJump();

			}
			
		}
		
		public function enemyJump():void
		{
			//Checks to see if enemyHit boolean is false; this prevents the mushroom from jumping after it has been killed
			//(in the case that a timer was set before it was killed... removing the event listener below will
			//not stop a timer that has already been already set)
			if (enemyHit == false)
			{
				//Change the ySpeed to neg impulsion
				ySpeed = -impulsion;
				//Go to the "moving" movieclip
				this.gotoAndStop("moving");
				//Set currentlyJumping boolean to false
				currentlyJumping = false;
			}

		}
		
		public function removeEnemy():void
        {
			//Set enemyHit to true
			enemyHit = true;
			//Remove the event listener that moves the enemy
			removeEventListener(Event.ENTER_FRAME, moveEnemy)
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
			//Removes the enemy from the level it's been place in (the parent)
			parent.removeChild(this); 
		}

	}
	
}
