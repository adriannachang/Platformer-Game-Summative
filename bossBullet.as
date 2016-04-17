package  {
	//Import necessary files
	import flash.display.MovieClip;
    import flash.events.Event;
	
	public class bossBullet extends MovieClip
	{
		private var speed:int = 15; //Speed of the bullet
		private var spawnPoint:int; //Initial spot the bullet spawned from
		
		public function bossBullet(bossX:int, bossY:int):void
		{
			//Set the position of the boss bullet based on the boss's current x and y pos
			this.x = bossX - 20;
			this.y = bossY - 45;
			//Set the spawn point to the x value taken into the constructor in order to keep track of the 
			//boss bullet's initial spawn point
			spawnPoint = bossX;
			
			//As soon as the bullet has been released, call function shootBullet
			addEventListener(Event.ENTER_FRAME, shootBullet);
		}
		
        public function shootBullet(e:Event):void 
		{
            this.x -= speed; //Change bullet's x position according to speed

			//Remove the bullet once it has moved 800 pixels past its spawn point (basically once it has just 
			//moved off the screen)
			if (this.x < spawnPoint - 800)
			{
				//Call function removeBullet
				removeBullet();
			}
			
        }
		
		public function removeBullet()
		{		
			//Remove the event listener
			removeEventListener(Event.ENTER_FRAME, shootBullet); 
			//Remove the bullet from level3 (the parent)
			parent.removeChild(this);
		}
    }
}