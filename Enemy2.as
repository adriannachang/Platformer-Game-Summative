package  {
	//Import all the necessary files
    import flash.display.MovieClip;
    import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Enemy2 extends MovieClip
	{
		//Speed of the enemy
		private var speedConst:Number = 3;	
		private var enemyHit:Boolean = false;

		public function Enemy2(xLocation:int, yLocation:int):void
		{
			//Set the enemy's x and y values to the values taken into the function
			this.x = xLocation;
			this.y = yLocation;
			//Set the enemy to running position
			this.gotoAndStop("flying");
			
		}
		
		public function moveEnemy(enemy:MovieClip, player:MovieClip, levelXShift:int, levelYShift:int):void
		{
			//Variable Declarations
			var enemyRange:int = 650;
			var moveX:Number = 0;
			var moveY:Number = 0;
			
			//Calculate distance between enemy and player in terms of x and y
			var distanceX = enemy.x-player.x+levelXShift;
			var distanceY = player.y-enemy.y-levelYShift;
			
			//Calculate the TOTAL distance between the enemy and the player (in terms of a line)
			var distanceTotal = Math.sqrt(distanceX*distanceX+distanceY*distanceY);
			
			//If the enemy is located to the right of the player, it's scaleX is 1
			if (distanceX > 0)
			{
				this.scaleX = 1;

			}
			
			//If the enemy is located to the left of the player, flip it's direction by setting scaleX to -1
			else if (distanceX < 0)
			{
				this.scaleX = -1;
			}

	
			//If the player is within the enemy`s range AND they haven't collided yet (collision happens when
			//total distance is about 30) AND the enemy hasn't been hit yet
			if (distanceTotal <= enemyRange && distanceTotal >= 30 && enemyHit == false)
			{
				//Trace that the player is within range of enemy
				trace("within range");
				
				//Calculate how much to move the enemy horizontally by doing ratio of the enemy's distance from the player(x) and 
				//the enemy's total distance from the player
				var moveDistanceX:Number = distanceX/distanceTotal;
							
				//Calculate how much to move the enemy vertically by doing ratio of the enemy's distance from the player(y) and 
				//the enemy's total distance from the player
				var moveDistanceY:Number = distanceY/distanceTotal;				

				//Have moveX and moveY change by the moveDistance values calculated above
				moveX -= moveDistanceX;
				moveY += moveDistanceY;

				//Multiply the moveX and moveY values by the enemy's speed
				moveX = speedConst*moveX;
				moveY = speedConst*moveY;
				
				//Move the enemy by moveX and moveY values
				enemy.x += moveX;
				enemy.y += moveY;
		

			}
			
		}
		
		public function removeEnemy():void
        {
			trace("removing flying enemy");
			//Change the enemyHit boolean to true
			enemyHit = true;
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
			//Removes the enemy from the level it's been placed in (the parent)
			parent.removeChild(this); 
		}

	}
	
}
