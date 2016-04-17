package {
    
	//Import necessary files
	import flash.display.MovieClip;
    import flash.events.Event;

   //Class is public and an extension of a movieClip
	public class bullet extends MovieClip
	{
		private var speed:int = 20; //Speed of the bullet
		private var spawnPoint:int; //Initial spot the bullet spawned from
		
		//Constructor function, takes in player's X pos, player's Y pos, player's direction, speed and the Y pos of level1
		public function bullet(playerX:int, playerY:int, playerDirection:String, playerSpeed:int, levelShift:int) 
		{
			//If player is facing left
			if(playerDirection == "left") 
			{
				//The speed of the bullet is adjusted to the player's speed (so that the player can't outrun a bullet)
				speed -= playerSpeed;
				//Speed is then multiplied by -1 (seeing as the bullet must be moving to the left)
				speed *= -1;
				//Set the bullet's x pos to 80 units left of the player's X pos
				this.x = playerX - 80;
			} 
			//If player is facing right
			else if(playerDirection == "right") 
			{
				//Same as above, only flipped
				speed += playerSpeed;
				speed *= 1;
				this.x = playerX +80;
				//Flip the image of the bullet so that it's facing the correct direction
				this.scaleX *= -1;
			}
			
			//Set the bullet's y pos to the player's Y pos, -50 (so that the bullet leaves at about hand-height), -any levelShift
			//(if level1's y pos has been shifted at all, the bullet will adjust itself accordingly)
			this.y = playerY -50-levelShift;
			//Spawn point is the bullet's x value when it is released
			spawnPoint = this.x;
			//As soon as the bullet has been released, call function shootBullet
			addEventListener(Event.ENTER_FRAME, shootBullet);
		}
		
        public function shootBullet(e:Event):void 
		{
            this.x += speed; //Change bullet's x position according to speed
			
			//If bullet is moving right
			if(speed > 0) 
			{
				//Remove the bullet once it has moved 800 pixels past its spawn point (basically once it has just 
				//moved off the screen)
				if (this.x > spawnPoint +800)
				{
					//Call function removeBullet
					removeBullet();
				}
			}
				
			//If bullet is moving left
			else if (speed < 0)
			{
				//Remove the bullet once it has moved 800 pixels past its spawn point (basically once it has just 
				//moved off the screen)
				if (this.x < spawnPoint - 800)
				{
					//Call function removeBullet
					removeBullet();
				}
			}
        }
		
		public function removeBullet()
		{
			//trace("removing bullet");			
			//Remove the event listener
			removeEventListener(Event.ENTER_FRAME, shootBullet); 
			//Removes the bullet from level1 (the parent), consequentially removing it from the stage
			parent.removeChild(this);
		}
    }
}