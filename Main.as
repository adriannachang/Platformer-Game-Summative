package  {
	
	//Import all the necessary files into Flash
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;	
	import flash.geom.Point;
	import flash.text.*;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.net.SharedObject;
	
	//Class definition; it is public and an extension of a movie clip's regular functionality
	public class Main extends MovieClip {
		
		//Variable Declarations
		//Define the three game levels; levels were designed within the FLA and exported for actionscript
		var level1:Level1 = new Level1();
		var level2:Level2 = new Level2();
		var level3:Level3 = new Level3();
		//Create the player, which is of type "Character" - designed in the FLA
		var player:Character = new Character();
		//Create all the menuScreens and the end screen that pops up at the end of the game
		var menuScreen:titleScreen = new titleScreen();
		var menuScreen2:title2Screen = new title2Screen();
		var theHelpScreen:helpScreen = new helpScreen();
		var theAboutScreen:aboutScreen = new aboutScreen();
		var endScreen:winningScreen = new winningScreen();
		
		//Set the current level to 1
		var currentLevel = 1;
		//Boolean for whether or not the game has started - set to false
		var gameHasStarted:Boolean = false;
		
		//Game control variables adjust the physics of the game
		//Gravity: speed at which player is pulled down after jump
		var gravity:Number = 0.8;
		//scrollX, constantSpeed, constantFriction and constantMaxSpeed adjust the background scrolling during the game
		var scrollX = 0;
		var constantSpeed = 8;
		var constantFriction = 0.92;	
		var constantMaxSpeed = 14;
		
		//Keep track of the bullets and the enemies within the game using arrays
		var bulletList:Array = new Array();
		var enemyList:Array = new Array();
		//Boolean keeps track of whether an enemy has been hit
		var enemyHit:Boolean = false;
		
		//Create the boss and designate it's spawn point
		var boss:Boss = new Boss(3900, 400);
		//Booleans track when the boss has shot a bullet and when it has been defeated (more on this later)
		var bossBulletShot:Boolean = false;
		var bossDefeated:Boolean = false;
		
		//Keep track of the boss's bullets using an array
		var bossBulletList:Array = new Array();
		
		//Keep track of the coins in the game using an array
		var coinList:Array = new Array();
		
		//Create the player's health bar
		var playerHealthBar:healthBar = new healthBar();
		//Keep track of the player's HP
		//Total health
		var totalHP:int = 100;
		//Current health in the game
		var currentHP:int = totalHP;
		//The percent of their health remaining 
		var percentHP:Number = currentHP / totalHP;
		
		//Create the boss's health bar
		var bossHealthBar:BossHealthBar = new BossHealthBar();
		//Variables include total boss health, the boss's current health, and the percent of their health remaining
		var totalBossHP:int = 100;
		var currentBossHP:int = totalBossHP;
		var percentBossHP:Number = currentBossHP/totalBossHP;
		//Boolean checks to see if the boss's temporary invincibility is turned on (more on this later)
		var bossTempInvincibility:Boolean = false;
		
		//Keep track of points
		//Current score set to 0
		var currentScore:int = 0;
		//Current score in the form of a string (for putting into textboxes)
		var currentScoreString:String;
		//Define vars for the bonuses at the end of the game; time bonus and health bonus
		var timeBonus:int;
		var healthBonus:int;
		
		//Var playerScoreTextBox displays the points accumulated during the game by both collecting
		//coins as well as killing enemies 
		var playerScoreTextBox:coinCountTextbox = new coinCountTextbox();
		
		//Keep track of the time (score will be determined by both points accumulated during the game and the time of completion
		var gameStartTime:uint;
		//gameTime set to 0
		var gameTime:uint = 0;
		//Create a textField for the time to be displayed in
		var gameTimeTextfield:TextField = new TextField();
		
		//Keep track of highscores achieved
		var highScore:int;
		//Create a sharedObject that will store a highscore/load a highscore from the local drive
		var saveDataObject:SharedObject = SharedObject.getLocal("Highscores");
		
		//Constructor function		
		public function Main()
		{		
			//Add level1 to the stage
			addChild(level1);
			
			//Add player health bar to the stage and set its x and y values
			addChild(playerHealthBar);
			playerHealthBar.x = 600;
			playerHealthBar.y = 50;
					
			//Convert int score to string
			currentScoreString = String(currentScore);
			//Set the text in the score textbox to the currentScoreString variable
			playerScoreTextBox.scoreText.text = "Score: "+currentScoreString;
			//Give the textbox a width, and set its x and y values
			playerScoreTextBox.width = 500;
			playerScoreTextBox.x = 275;
			playerScoreTextBox.y = 60;
			//Add score textbox to stage
			addChild(playerScoreTextBox);
			
			//Set the x and y values for the game time textbox
			gameTimeTextfield.x = 310;
			gameTimeTextfield.y = 12;
			//Set the text box's width
			gameTimeTextfield.width = 200;
			//Because the textfield was created dynamically, must set the font and size of the text dynamically
			//as well
			var myTextFormat:TextFormat = new TextFormat();
			myTextFormat.size = 28; //change the font size
			myTextFormat.font = "Snap ITC"; //font type
			gameTimeTextfield.defaultTextFormat = myTextFormat;
			//Add the textfield to the stage
			addChild(gameTimeTextfield);
			//Add event listener to the stage that runs upon execution of the .swf and that calls function showTime
			addEventListener(Event.ENTER_FRAME,showTime);

			//Set the doors on each level to "closed" 
			level1.lockedDoor.gotoAndStop("closed");
			level2.lockedDoor2.gotoAndStop("closed");
			level3.lockedDoor3.gotoAndStop("closed");
			//Set boolean for whether the key has been collected (for each level) to false
			level1.doorKey.collected = false;
			level2.doorKey2.collected = false;
			level3.doorKey3.collected = false;
			
			//Set the player's position in the game
			player.x = 150;
			player.y = 534;
			//Set the player's x and y speeds to 0
			player.xSpeed = 0;
			player.ySpeed = 0;
			//Set the booleans associated with what state the player's in to their corresponding values (all should be false)
			player.jump = false;
			player.move = false;
			player.climbing = false;
			player.hitWater = false;
			player.hit = false;
			player.tempInvincibility = false;
			player.noShoot = false;
			player.endGame = false;
			
			//Set the player impulsion (height player reaches after a jump)
			player.impulsion = 16;
			//Set the player to his standing position within the movie clip
			player.gotoAndStop("standing");
			//ADd the player to the stage
			addChild(player);
			
			//Call function to set up the menu screens
			setUpMenuScreens();
						
			//Event listener checks to see when a key has been pressed; calls movePlayer function
			stage.addEventListener(KeyboardEvent.KEY_DOWN, movePlayer);
			//Event listener checks to see when a key has been released; calls stopPlayer function
			stage.addEventListener(KeyboardEvent.KEY_UP, stopPlayer);
			//Event listener runs function gameAction as soon as every frame is entered, meaning that it is 
			//execute as soon as the .swf file opens, and constantly runs after that
			stage.addEventListener(Event.ENTER_FRAME, gameAction);		
					
			//Add enemies to level1
			addEnemiestoLevel1();
			//Add coins to level1
			addCoinstoLevel1();			
		}
		
		//Set up all the menu screens
		public function setUpMenuScreens():void
		{
			//Add all the menu screens to the stage
			addChild(menuScreen);
			addChild(menuScreen2);
			addChild(theHelpScreen);
			addChild(theAboutScreen);
			//Add the end screen
			addChild(endScreen);
			//Give all the screen x and y positions and set their visibility to false (except for menuScreen,
			//which is the only screen visible when the .swf loads)
			menuScreen.x = 400;
			menuScreen.y = 300;
			theHelpScreen.visible = false;
			theHelpScreen.x = 400;
			theHelpScreen.y = 300;
			theAboutScreen.visible = false;
			theAboutScreen.x = 400;
			theAboutScreen.y = 300;
			menuScreen2.visible = false;
			menuScreen2.x = 400;
			menuScreen2.y = 300;
			endScreen.visible = false;
			endScreen.x = 400;
			endScreen.y = 300;
			
			//Checks to see if a highscore has already been saved to the computer (for example, if this
			//is the first time the program is being run on a computer)
			if(saveDataObject.data.savedScore == null)
			{ 
         		//Trace that there is no saved data
				trace("No saved data yet."); 
     		} 
			
			else 
			{
				//Trace that data was found
				trace("Save data found."); 
				//Call the function to load the score (found after the setUpMenuScreens function)
				loadScore(); 
			}
			
			//Set the highScore textbox within the menuScreen to the highScore 
			menuScreen.highScoreBox.text = "Highscore: "+highScore;

			//Before the player has played a game, if they hit the "Play" button, it will run the function startGame...
			//This will basically just hide the menu screen and the user will be permitted to play
			menuScreen.playButton.addEventListener(MouseEvent.CLICK, startGame);
			//If the player presses the about or help buttons, run the corresponding functions
			menuScreen.aboutButton.addEventListener(MouseEvent.CLICK, showAbout);
			menuScreen.helpButton.addEventListener(MouseEvent.CLICK, showHelp);
			//If the player hits the back button while on the about or help screen, run function gotoMenu
			theAboutScreen.backbutton.addEventListener(MouseEvent.CLICK, gotoMenu);
			theHelpScreen.backbutton.addEventListener(MouseEvent.CLICK, gotoMenu);
			
			//If the second menu screen is up (meaning that the player has gone through the game and
			//re-called the menu up after dying/winning, the "Play" button will now call the function resetGame
			//and RESET the game
			menuScreen2.playButton2.addEventListener(MouseEvent.CLICK, resetGame);
			//Add event listeners that will take player to the about/help screens on the second menu screen
			menuScreen2.aboutButton.addEventListener(MouseEvent.CLICK,showAbout);
			menuScreen2.helpButton.addEventListener(MouseEvent.CLICK, showHelp);
			
			//Button playAgain will reset the game; button menuButton will call the gotoMenu function
			endScreen.playAgain.addEventListener(MouseEvent.CLICK, resetGame);
			endScreen.menuButton.addEventListener(MouseEvent.CLICK, gotoMenu);
			
			//Function called when the player presses the play button FOR THE FIRST TIME after the .swf has beene executed
			function startGame (me:MouseEvent):void
			{
				//hide the menu screen
				menuScreen.visible = false;
				trace("GAME COMMENCING!");
				//Get the start time
				gameStartTime = getTimer();
				//Set the gameHasStarted boolean to true
				gameHasStarted = true;
			}
							
			//Make the about screen visible
			function showAbout(me:MouseEvent):void
			{
				theAboutScreen.visible = true;
			}
				
			//Make the help screen visible
			function showHelp(me:MouseEvent):void
			{
				theHelpScreen.visible = true;
			}	
			
			//Pulls up the menu
			function gotoMenu(me:MouseEvent):void
			{			
				//If the end screen is visible (ie the player won/lost and then went to menu), hide it
				if (endScreen.visible == true)
				{
					endScreen.visible = false;
				}
				
				//If the help/about screens are open (ie the player clicked "BACK" while on one of the screens
				//to return to the menu), hide them
				if(theHelpScreen.visible == true)
				{
					theHelpScreen.visible = false;
				}
	
				if(theAboutScreen.visible == true)
				{
					theAboutScreen.visible = false;
				}
				
				//If the endGame boolean is FALSE, meaning that the player has not yet initiated a game,
				//show the FIRST menuScreen - that way, when they select "PLAY", it will START the game rather
				//than reset it
				if (player.endGame == false)
				{
					menuScreen.visible = true;
				}
				
				//Otherwise, if endGame is TRUE and the player has finished a game (either won or lost) and called up
				//the menu, bring up the SECOND menuScreen (ie menuScreen2)... This will ensure that if they then select
				//"PLAY", it will RESET the game by calling the restGame function rather than calling the startGame function
				else
				{
					menuScreen2.visible = true;
				}

				trace("going to menu");
				
				//Call the load score function to load the highScore
				loadScore();
				//Set the highScore textbox on the second menuScreen to the highScore
				menuScreen2.highScoreBox.text = "Highscore: "+highScore;
	
			}
		}
 
		public function loadScore():void
		{
			//Set value of highScore to the score saved in the sharedObject
			highScore = saveDataObject.data.savedScore; 
			trace("Data Loaded!");
		}
		
		public function saveHighScore():void
		{
			//Set the saved score to the finalScore attained
			saveDataObject.data.savedScore = currentScore + timeBonus + healthBonus; 
			trace("Data Saved!");
			//Save to the local drive
			saveDataObject.flush(); 

		}
		//Add enemies to level1 by calling function and sending in the desired x and y coordinates and the type of enemy
		public function addEnemiestoLevel1():void
		{									
			addEnemy(6000, 380, 1);
			addEnemy(7875, 410, 1);
			addEnemy(7000, 525, 3);
			addEnemy(8500, 376, 3);
			addEnemy(10000, 20, 1);
			addEnemy(10430, -115, 3);
			addEnemy(10550, -115, 3);
			addEnemy(10640, -115, 3);
			addEnemy(11900, -60, 1);
			addEnemy(14000, 110, 1);
		}
		
		//Add coins to level1 by calling function and sending in desired x and y coordinates
		public function addCoinstoLevel1():void
		{
			addCoin(900, 400);
			addCoin(1000, 350);
			addCoin(1100, 400);
			addCoin(3600, 425);
			addCoin(3700, 400);
			addCoin(3800, 375);
			addCoin(5900, 500);
			addCoin(8900, 220);
			addCoin(8900, 425);
			addCoin(9000, 220);
			addCoin(11000, -100)
			addCoin(11120, -200);
			addCoin(11240, -100);
			addCoin(12750, -50);
			addCoin(12900, -50);
			addCoin(13250, -50);
			addCoin(13350, -50);
		}
		
		//REPEAT ABOVE WITH THE SECOND AND THIRD LEVELS
		public function addEnemiestoLevel2():void
		{
			addEnemy(1000, 525, 1);
			addEnemy(2800, 250, 2);
			addEnemy(3660, 530, 1);
			addEnemy(3550, 235, 3);
			addEnemy(3675, 235, 3);
			addEnemy(5550, 210, 2);
			addEnemy(6950, 530, 1);
			addEnemy(9250, 200, 2);
			addEnemy(9400, 230, 2);
			addEnemy(9600, 180, 2);
			addEnemy(8800, -138, 1);
			addEnemy(9100, -138, 3);
			addEnemy(9400, -138, 3);
			addEnemy(10280, 414, 1);
			addEnemy(12000, 518, 1);
			addEnemy(12700, 518, 3);
			addEnemy(13400, 395, 1);
			addEnemy(13500, 200, 2);
			addEnemy(14200, 517, 1);
			
		}
		
		public function addCoinstoLevel2():void
		{
			addCoin(1400, 400);
			addCoin(1500, 325);
			addCoin(1600, 400);
			addCoin(2000, 100);
			addCoin(2100, 100);
			addCoin(2200, 100);
			addCoin(4200, 100);
			addCoin(4300, 100);
			addCoin(4400, 100);
			addCoin(5000, 300);
			addCoin(5000, 225);
			addCoin(5950, 200);
			addCoin(6100, 200);
			addCoin(8100, 425);
			addCoin(8200, 425);
			addCoin(9600, -250);
			addCoin(9700, -250);
			addCoin(11550, 300);
			addCoin(11550, 225);
			addCoin(11550, 150);
			addCoin(13450, 250);
			addCoin(13550, 250);
			addCoin(13650, 250);
		}
		
		
		public function addEnemiestoLevel3():void
		{
			addEnemy(1475, 345, 1);
			addEnemy(1800, 520, 1);
			addEnemy(1660, 210, 3);
			addEnemy(1780, 210, 3);
			addEnemy(2200, 250, 2);
			addEnemy(2300, 200, 2);
			addEnemy(2750, 375, 1);
			addEnemy(3000, 200, 2);
			addEnemy(3100, 150, 2);
		}
		
		public function addCoinstoLevel3():void
		{
			addCoin(300, 400);
			addCoin(400, 325);
			addCoin(500, 400);
			addCoin(1275, 475);
			addCoin(1375, 475);
			addCoin(1475, 475);
			addCoin(2400, 475);
			addCoin(2500, 475);
			addCoin(3100, 150);
			addCoin(3200, 150);
			addCoin(4100, 400);
			addCoin(4200, 400);
			addCoin(4300, 400);
		}
		
		//Displays the gametime
		public function showTime(e:Event):void
		{
			//If the game has NOT ended yet
			if (player.endGame == false)
			{
				//the game time is equal to the current time on the timer minus the start time
				gameTime = getTimer()-gameStartTime;
			}
			  //Display the game time in the textbox - send the current time (which is in milliseconds) into the function clockTime
  			  gameTimeTextfield.text = "Time: "+clockTime(gameTime);
		}
		
		public function clockTime(ms:int)
		{
			//Convert the time (which is entirely in milliseconds) into readable time
			var seconds:int = Math.floor(ms/1000);
			var minutes:int = Math.floor(seconds/60);
			seconds -= minutes*60;
			//Create a string for the time that puts together all the time values
			var timeString:String = minutes+":"+String(seconds+100).substr(1,2);
			//Return the timeString
			return timeString;
		}
		
		//Allows the player to move
		public function movePlayer(ke:KeyboardEvent):void
		{

			//Player can only move if the game has started (ie. if they're on the menu screen, they should
			//not be able to move) --> use of the gameHasStarted boolean
			
			//If user hits right arrow key
			if (ke.keyCode == Keyboard.RIGHT && gameHasStarted == true)
			{
				//Change the necessary booleans to true
				player.moveRight = true;
				player.move = true;	
			}
			
			//If user hits left arrow key
			if (ke.keyCode == Keyboard.LEFT && gameHasStarted == true)
			{
				//Change the necessary booleans to true				
				player.moveLeft = true;
				player.move = true;	
			}
			//If user hits down arrow key			
			if (ke.keyCode == Keyboard.DOWN && gameHasStarted == true)
			{
				//Change the necessary booleans to true
				player.downPressed = true;	
				player.move = true;
	
			}
			
			//If user hits up arrow key		
			if (ke.keyCode == Keyboard.UP && gameHasStarted == true)
			{							
				
				//Change upPressed boolean to true
				//If player is NOT currently climbing, then set the jumpUp boolean to true (explained more down below)
				player.upPressed = true;
				
				if (player.climbing == false)
				{
					player.jumpUp = true;
				}
			}
			//If user hits space bar
			if (ke.keyCode == Keyboard.SPACE && gameHasStarted == true)
			{			
				//If player is allowed to shoot
				if (player.noShoot == false)
				{
					//Call on function shootBullet 
					shootBullet();
				}
				
			}	
		}
			
		public function gameAction(e:Event):void
		{
			trace("water: "+player.hitWater);
		//If the player.moveLeft boolean is true, player.xSpeed = current player.xSpeed - constantSpeed
		//Flip direction player is facing
		if(player.moveLeft == true)
		{
			player.xSpeed -= constantSpeed;
			player.scaleX = -1;
			//If player is NOT currently jumping, put them in running position
			if (player.jump == false)
			{
				player.gotoAndStop("running");	
			}
		} 
		
		//If the player.moveLeft boolean is true, player.xSpeed = current player.xSpeed + constantSpeed		
		if(player.moveRight == true)
		{	
			player.xSpeed += constantSpeed;
			player.scaleX = 1;
			
			//If player is NOT currently jumping, put them in running position
			if (player.jump == false)
			{
				player.gotoAndStop("running");	
			}		
		}
		
		//If the downPressed boolean is true AND the player is not currently climbing, put
		//them in ducking position
		if (player.downPressed == true && player.climbing == false)
		{
			//If player is NOT currently jumping, put them in ducking position
			if (player.jump == false)
			{
				player.gotoAndStop("ducking");	
				//Player is not allowed to shoot while ducking, so change the boolean to false
				player.noShoot = true;
			}	
		}
		//If player hits an object within level1 from the left side
		if (level1.levelObjects.hitTestPoint(player.x-player.width/2, player.y-player.height/2, true) || level2.level2Objects.hitTestPoint(player.x-player.width/2, player.y-player.height/2, true) || level3.level3Objects.hitTestPoint(player.x-player.width/2, player.y-player.height/2, true))
		{
			//If player is moving (abs value of speed > 0 -- in this case, < 0 beacuse player is left facing),
			//half their xSpeed and change their direction, mimicing a "bounce"
			if(player.xSpeed < 0)
			{
				player.xSpeed *= -0.5;
			}

		}	
		
		//Player bounces off object from right
		if (level1.levelObjects.hitTestPoint(player.x+player.width/2, player.y-player.height/2, true) || level2.level2Objects.hitTestPoint(player.x+player.width/2, player.y-player.height/2, true) || level3.level3Objects.hitTestPoint(player.x+player.width/2, player.y-player.height/2, true))
		{
			if(player.xSpeed > 0)
			{
				player.xSpeed *= -0.5;
			}
		}
			
		//Player bounces off object from above
		if (level1.levelObjects.hitTestPoint(player.x-player.width/2, player.y-player.height/2, true)|| level1.levelObjects.hitTestPoint(player.x+player.width/2, player.y-player.height/2, true) || level2.level2Objects.hitTestPoint(player.x-player.width/2, player.y-player.height/2, true)|| level2.level2Objects.hitTestPoint(player.x+player.width/2, player.y-player.height/2, true) || level3.level3Objects.hitTestPoint(player.x-player.width/2, player.y-player.height/2, true)|| level3.level3Objects.hitTestPoint(player.x+player.width/2, player.y-player.height/2, true)) 
		{
			//Same as above examples, only now it's the player's ySpeed that is being affected
			if(player.ySpeed < 0)
			{
				player.ySpeed *= -0.5;
			}
		}		
			
		//If player is standing on something/ colliding with something below him
		if (level1.levelObjects.hitTestPoint(player.x-player.width/2, player.y, true)|| level1.levelObjects.hitTestPoint(player.x+player.width/2, player.y, true) || level2.level2Objects.hitTestPoint(player.x-player.width/2, player.y, true)|| level2.level2Objects.hitTestPoint(player.x+player.width/2, player.y, true) || level3.level3Objects.hitTestPoint(player.x-player.width/2, player.y, true)|| level3.level3Objects.hitTestPoint(player.x+player.width/2, player.y, true))
		{
			//Set the jump boolean to false
			player.jump = false;
			//Stop the player from falling 			
			player.ySpeed = 0; 
			//If player is standing on something, and not being told to move, automatically assume standing pos
			if (player.move == false)
			{
				player.gotoAndStop("standing");
			}
			
			//If the jumpUp boolean has been set to true (meaning that the up arrow was pressed BUT the player is not climbing)
			if(player.jumpUp == true)
			{
				//Set the player to jumping position
				player.gotoAndStop("jumping");	
				//player.jump is now true
				player.jump = true;
				//Player's ySpeed = negative impulsion (because y gets more neg as it moves up)
				player.ySpeed= -player.impulsion;
				
				//Get a random number between 0 and 2
				var myNum:Number = Math.floor(Math.random()*3);
				
				//Create a new sound for when AJ jumps
				var jumpSound:Sound = new Sound(); 
				//Add event listener that checks to see when the sound had loaded
				jumpSound.addEventListener(Event.COMPLETE, jumpSoundLoaded); 
				//Define the URLRequest that will store the file location of the sound
				var jumpSoundRequest:URLRequest;
				
				//Based on the random number generated, select one of the three jump sounds in the Sounds folder
				switch(myNum)
				{
					case 0:
						jumpSoundRequest = new URLRequest("Sounds/Jump1.mp3"); 
						break;
					case 1:
						jumpSoundRequest = new URLRequest("Sounds/Jump2.mp3");
						break;
					case 2:
						jumpSoundRequest = new URLRequest("Sounds/Jump3.mp3");
				}
				//Load the URLRequest
				jumpSound.load(jumpSoundRequest); 
						 
				//When the sound has loaded, play it
				function jumpSoundLoaded(event:Event):void 
				{ 
					jumpSound.play(); 
				}
			}

		}
		
		//Else if the player is not standing on something, and not climbing, and endGame boolean has not been set to true
		else if (player.climbing == false && player.endGame == false)
		{
			//Apply gravity to player's ySpeed
			player.ySpeed += gravity;
		}
		
		
		//Code for collecting the key:
		//If the key HAS NOT been collected
		if (level1.doorKey.collected == false)
		{
			//If the player hits the key/ collects the key
			if (player.hitTestObject(level1.doorKey))
			{
				//Hide the key once the player has collected it
				level1.doorKey.visible = false;
				//Set boolean to true
				level1.doorKey.collected = true;
				trace("Key collected");
				
				//play the key sound effect
				keySoundEffect();
			}
		}
		
		//Same as above
		if (level2.doorKey2.collected == false)
		{
			if (player.hitTestObject(level2.doorKey2))
			{
				level2.doorKey2.visible = false;
				level2.doorKey2.collected = true;
				trace("Key collected");
				
				keySoundEffect();
			}
		}
		
		//Same as above
		if (level3.doorKey3.collected == false)
		{
			//If the player hits the key/ collects the key
			if (player.hitTestObject(level3.doorKey3))
			{
				//Hide the key once the player has collected it
				level3.doorKey3.visible = false;
				//Set boolean to true
				level3.doorKey3.collected = true;
				trace("Key collected");
				keySoundEffect();
			}
		}
		
		function keySoundEffect():void
		{
			//Create new sound and load the appropriate file from the sound folder; play the sound
			//once it has loaded
			var keyCollectedSound:Sound = new Sound(); 
			keyCollectedSound.addEventListener(Event.COMPLETE, keyCollectedSoundLoaded); 
			var keyCollectedSoundRequest:URLRequest = new URLRequest("Sounds/Key collected.mp3"); 
			keyCollectedSound.load(keyCollectedSoundRequest); 
					
			function keyCollectedSoundLoaded(event:Event):void 
			{ 
				keyCollectedSound.play(); 
			}
		}
		//Code for opening the door:
		//If key has been collected
		if (level1.doorKey.collected == true)
		{
			//If player is touching the door AND the current level is 1
			if (player.hitTestObject(level1.lockedDoor) && currentLevel == 1)
			{
				
				//Set the current level to 2
				currentLevel++;
				//Set the door to open
				level1.lockedDoor.gotoAndStop("open");
				
				//Remove all the enemies remaining on level1
				for (var a:int = 0; a< enemyList.length; a++)
				{
					enemyList[a].removeEnemy();
				}
				
				//Remove all the remaining coins on level1
				for (var d:int = 0; d<coinList.length;d++)
				{
					coinList[d].removeCoin();
				}
				
				//Create a timer, have it call timer1Done function when the timer is done, and start the timer
				var timer1:Timer = new Timer(750);
				timer1.addEventListener(TimerEvent.TIMER,timer1Done);
				timer1.start();
				
				//The purpose of the timer is to create a delay between the door being opened and the next level
				//being displayed; otherwise, the animation of the door opening would not be shown
				function timer1Done(e:TimerEvent):void
				{
					//Stop the timer
					timer1.stop();
					//Remove level1
					trace("removing level 1");
					removeChild(level1);
					//At level2, and give it the lowest index
					addChildAt(level2, 0);
					//Reset the player's x and y position
					player.x = 150;
					player.y = 534;
					//Set scrollX to 0
					scrollX = 0;
					
					//Add enemies to level2
					addEnemiestoLevel2();
					//Add coins to level2
					addCoinstoLevel2();
					
				}
			}
		
		}
		
		//Code for opening the 2nd door:
		//If key has been collected
		if (level2.doorKey2.collected == true)
		{
			//If player is touching the door AND the current level is 2
			if (player.hitTestObject(level2.lockedDoor2) && currentLevel == 2)
			{
				//Set the current level to 3
				currentLevel++;
				//Set the door to open
				level2.lockedDoor2.gotoAndStop("open");
				
				//Remove all the enemies remaining on level2
				for (var b:int = 0; b< enemyList.length; b++)
				{
					enemyList[b].removeEnemy();
				}
				
				//Remove all the coins remaining on level2
				for (var q:int = 0; q<coinList.length; q++)
				{
					coinList[q].removeCoin();
				}
				
				//Create a timer, have it call timer2Done function when the timer is done, and start the timer
				var timer2:Timer = new Timer(750);
				timer2.addEventListener(TimerEvent.TIMER,timer2Done);
				timer2.start();
				
				//When the timer is done...
				function timer2Done(e:TimerEvent):void
				{
					//Stop the timer
					timer2.stop();
					//Remove level2
					trace("removing level 2");
					removeChild(level2);
					//Add level3 at the lowest index
					addChildAt(level3, 0);
					//Reset player's x and y position and set scrollX to 0
					player.x = 150;
					player.y = 534;
					scrollX = 0;
					
					//Add enemies to level3
					addEnemiestoLevel3();
					//Add coins to level3
					addCoinstoLevel3();
				
					//Add the boss to level3
					level3.addChild(boss);
					//Add the boss's health bar to level3
					addChild(bossHealthBar);
					//Update the boss's health bar (ie. if the player has already gotten to level3 and partially damaged the boss,
					//and then chose to replay the game, the boss's health bar will need to be updated back to full health)
					updateBossHealthBar();
					//Set x and y coordinates for health bar
					bossHealthBar.x = 600;
					bossHealthBar.y = 500;
					
				}
			}
		}
		
		//If the player is on level3, call function bossAttack
		if (currentLevel == 3)
		{
			bossAttack();
		}
		
		//Code for the final door
		//If the key has been collected
		if (level3.doorKey3.collected == true)
		{
			//If player is touching the door, and the endGame boolean has not yet been set to true, and the boss has been defeated
			if (player.hitTestObject(level3.lockedDoor3) && player.endGame == false && bossDefeated == true)
			{
				
				//Load the winning sound and play it
				var winSound:Sound = new Sound(); 
				winSound.addEventListener(Event.COMPLETE, winSoundLoaded); 
				var winSoundRequest:URLRequest = new URLRequest("Sounds/AJ win.mp3"); 
				winSound.load(winSoundRequest); 
						
				function winSoundLoaded(event:Event):void 
				{ 
					winSound.play(); 
				}
					
				//Set endGame boolean to true
				player.endGame = true;
				
				//Set the door to open
				level3.lockedDoor3.gotoAndStop("open");
				
				//Start the timer, and have it call timer3Done when done
				var timer3:Timer = new Timer(750);
				timer3.addEventListener(TimerEvent.TIMER, timer3Done);
				timer3.start();
			
				function timer3Done(e:TimerEvent):void
				{
					//Stop the timer
					timer3.stop();
					//Call the winGame function
					winGame();
					
				}	
			}
			
		}
		
		//If player's y value is greater than 800 (meaning that the player has fallen through a crack in the level)
		//AND player.endGame is false (once again, without the endGame boolean, this chunk of code would run endlessly)
		if (player.y > 800 && player.endGame == false)
		{
			//Stop the player from falling			
			player.ySpeed = 0;
			//Call function loseGame()			
			loseGame();
			//Set player.endGame to true
			player.endGame = true;
			
			//If player is NOT falling in water
			if (player.hitWater == false)
			{
				//Load and play the falling sound
				var fallSound:Sound = new Sound(); 
				fallSound.addEventListener(Event.COMPLETE, fallSoundLoaded); 
				var fallSoundRequest:URLRequest = new URLRequest("Sounds/Fall.mp3"); 
				fallSound.load(fallSoundRequest); 
						
				function fallSoundLoaded(event:Event):void 
				{ 
					fallSound.play(); 
				}
			}
			
		}
		
		//Code for the ladder(s):
		//If player is touching ladder on level 1
		if (level1.ladder.hitTestObject(player))
		{
			//Go to climbing position (climbing is a movie clip within the player movie clip)
			player.gotoAndStop("climbing");	
			//Set boolean to true
			player.climbing = true;
			//If player pressed up arrow, and level1 has not been moved up past 345, move level1 up 5 pxs
			if (player.upPressed == true && level1.y <345)
			{
				trace("move up");
				level1.y += 5;
			}
			
			//If player pressed down arrow, and level1 has not been moved down past 0, move level1 down 5 pxs			
			if (player.downPressed == true && level1.y > 0)
			{		
				trace("move down");
				level1.y -= 5;
			}
			
		}
		
		//If player is touching ladder on level 2
		else if (level2.ladder2.hitTestObject(player) || level2.ladder3.hitTestObject(player))
		{
			//Go to climbing position (climbing is a movie clip within the player movie clip)
			player.gotoAndStop("climbing");	
			//Set boolean to true
			player.climbing = true;
			//If player pressed up arrow, and level2 has not been moved up past 415, move level2 up 5 
			if (player.upPressed == true && level2.y <415)
			{
				trace("move up");
				level2.y += 5;
			}
			
			//If player pressed down arrow, and level2 has not been moved down past 0, move level2 down 5 			
			if (player.downPressed == true && level2.y > 0)
			{		
				trace("move down");
				level2.y -= 5;
			}
			
		}
		//If player is not touching ladder, set climbing boolean to false
		else
		{
			player.climbing = false;
		}	
		
		//If player hits water, the endGame boolean is currently false, and the hitWater boolean is also false (ensures that
		//the following code only runs through once)
		if (player.hitTestObject(level2.water.water_hitPoint) && player.endGame == false && player.hitWater == false)
		{			
			//Once the player has fallen past 800
			if (player.y > 800)
			{
				//Set the endGame boolean to true
				player.endGame = true;
				//Stop the player from falling
				player.ySpeed = 0;
				//Call the loseGame function
				loseGame();
			}

			trace("hit water");
			//Change the hitWater boolean to true
			player.hitWater = true;
			
			//Load and play the "falling in water" sound
			var fallWaterSound:Sound = new Sound(); 
			fallWaterSound.addEventListener(Event.COMPLETE, fallWaterLoaded); 
			var fallWaterRequest:URLRequest = new URLRequest("Sounds/Fall in Water.mp3"); 
			fallWaterSound.load(fallWaterRequest); 
					
			function fallWaterLoaded(event:Event):void 
			{ 
				fallWaterSound.play(); 
			}
		}
		//Because speed accelerates over time, prevents player from being able to go too fast
		//Right moving player
		if (player.xSpeed > constantMaxSpeed)
		{
			player.xSpeed = constantMaxSpeed;
		}
		//Left moving player
		else if (player.xSpeed < (constantMaxSpeed*-1))
		{
			player.xSpeed = (constantMaxSpeed*-1);
		}
				
		//This controls the actual movement of the levels (which simulates the movement of the player); player can only
		//"move" if the endGame boolean has not been set to true 
		if (player.endGame == false )
		{
			//Apply friction to the player's xSpeed
			player.xSpeed *= constantFriction; 
			//Change the player's y pos according to the ySpeed
			player.y += player.ySpeed;
			//Scroll the level according to the player's xSpeed
			scrollX -= player.xSpeed;
			
			//If player is on level 1
			if (currentLevel == 1)
			{
				//Set level1's x pos to scrollX
				level1.x = scrollX;	
			}
			
			//if player is on level 2
			else if (currentLevel == 2)
			{
				//Set level2's x pos to scrollX
				level2.x = scrollX;
			}
			
			//Otherwise (if player is on level 3)
			else
			{
				//Set level3's x pos to scrollX
				level3.x = scrollX;
			}

		}

		function winGame():void
		{
			trace("You win!");
			//Set the gameHasStarted boolean to false
			gameHasStarted = false;
			//Set the text within the endScreen to "YOU WIN"
			endScreen.winLoseText.text = "YOU WIN!";
			//Set the character within the endScreen to jumping position
			endScreen.endCharacter.gotoAndStop("jumping");
			//Make the endScreen visible
			endScreen.visible = true;
			//Have the coinScore textbox display the currentScoreString
			endScreen.coinScore.text = "Score: "+currentScoreString;
			//Have the finalTime textbox display the final time
			endScreen.finalTime.text = "Total Time: "+clockTime(gameTime);
			//Calculate timeBonus
			timeBonus = (1000*60*5 - gameTime)/500;
			//Show the timeBonus in the timeBonusScore textbox
			endScreen.timeBonusScore.text = "Time Bonus: "+timeBonus;
			//Calculate the healthBonus
			healthBonus = (currentHP/20)*100;
			//Show the healthBonus in the healthBonusScore textbox
			endScreen.healthBonusScore.text = "Health Bonus: "+healthBonus;
			//Show the final score in the totalScore textbox
			endScreen.totalScore.text = "Final Score: "+(currentScore+timeBonus+healthBonus);
			
			//If the final score achieved is higher than the previous highScore
			if (currentScore+timeBonus+healthBonus > highScore)
			{
				//Show the textfield that says "New HighScore"
				endScreen.newHighScore.visible = true;
				//Call saveHighScore() function to save highscore
				saveHighScore();
			}
			
			//Otherwise, don't show the "New Highscore" textbox
			else
			{
				endScreen.newHighScore.visible = false;
			}
			
		}

		function loseGame():void
		{
			//If player lost on level3, remove the bossHealthBar
			if (currentLevel == 3)
			{
				removeChild(bossHealthBar);
			}
			
			trace("You lose!");
			//Set the gameHasStarted boolean to false
			gameHasStarted = false;
			//Set the player.hit boolean to false 
			player.hit = false;
			//Set the text within the endScreen to "YOU LOSE"
			endScreen.winLoseText.text = "YOU LOSE!";
			//Set the character within the endScreen to dying position
			endScreen.endCharacter.gotoAndStop("dying");
			//Make the endScreen visible
			endScreen.visible = true;
			//Set all the score textboxes to their corresponding values
			endScreen.coinScore.text = "Score: "+currentScoreString;
			endScreen.finalTime.text = "Total Time: "+clockTime(gameTime);
			//No time or health bonuses allocated when the player doesn't finish the game
			endScreen.timeBonusScore.text = "Time Bonus: None";
			endScreen.healthBonusScore.text = "Health Bonus: None";
			endScreen.totalScore.text = "Final Score: "+(currentScore);
			
			//If the current score achieved is greater than the previous highscore
			if (currentScore > highScore)
			{
				//Show the "new high score" textbox
				endScreen.newHighScore.visible = true;
				//Call function saveHighScore() to save highscore
				saveHighScore();
			}
			
			//Otherwise, don't display the "new high score" textbox
			else
			{
				endScreen.newHighScore.visible = false;
			}
			
		}
		
		//Check for collision between enemy and bullet
		//If there are any enemies left in the enemyList array
		if (enemyList.length > 0) 
		{
			//For each enemy in the array
			for (var i:int = 0; i < enemyList.length; i++) 
			{
				//If there are any bullets left in the bulletList array
				if (bulletList.length > 0) 
				{
					//For each bullet in the array
					for (var j:int = 0; j < bulletList.length; j++) 
					{
						/*Check all enemies and bullets and see if any are colliding
						If an enemy and a bullet collide, AND an enemy has not been hit (this second part is important,
						seeing as there is a delay between the enemy being hit and it being actually removed from the
						screen - so, once an enemy has been hit, the program will stop checking for collisions
						until the enemy has actually been removed from the screen and enemyHit returns to false... This prevents
						errors from arising)*/
						if ( enemyList[i].monster_hitPoint.hitTestObject(bulletList[j]) && enemyHit == false )
						{
							//Set the boolean to true
							enemyHit = true;
							trace("Bullet and enemy are colliding");
							//Call on functions to remove the enemy and the bullet that collided; the functions removeEnemy
							//and removeBullet are located within the .as class files "Enemy" and "bullet"
							enemyList[i].removeEnemy();
							bulletList[j].removeBullet();
							
							//Give the player 10 points for killing enemy
							currentScore += 10;
							//Update score
							updateScore();
						}
						
					}
				}
			}
		}
		
		//Check for collision between boss and bullet
		if (currentLevel == 3)
		{
			//If there are any bullets left in the array
			if (bulletList.length > 0)
			{
				//For each bullet in the array
				for (var k:int = 0; k< bulletList.length; k++)
				{
						//If a bullet hits the boss's hitPoint, and the boss has not yet been defeated (prevents errors from occurring
						//in the case that the boss has been defeated, but not yet removed from the stage), and the boss's temporary
						//invincibility is turned off
						if (boss.boss_hitPoint.hitTestObject(bulletList[k]) && bossDefeated == false && bossTempInvincibility == false)
						{				
							//Turn on the boss's temporary invincibility
							bossTempInvincibility = true;
							//Decrease the boss's HP by 25
							currentBossHP -= 25;
							//Update the boss's health bar
							updateBossHealthBar();
								
							//Set the boss to hit state
							boss.beenHit(); //(Function found within the boss class)
							//Give the player 20 points
							currentScore += 20;
							//update the score
							updateScore();
								
							//Start the timer; this will provide boss with 2.5 seconds of invicibility after being hit 
							var timer7:Timer = new Timer(2500);
							timer7.addEventListener(TimerEvent.TIMER,timer7Done);
							timer7.start();
							trace("You hit the boss!");
												
							//When timer is done
							function timer7Done(e:TimerEvent):void
							{
								//Stop the timer, and turn the boss's temporary invincibility off
								timer7.stop();
								bossTempInvincibility = false;
							}
								
							//If the boss's HP is less than or equal to 0
							if(currentBossHP <= 0)
							{
								//Set the bossDefeated boolean to true
								bossDefeated = true;
								//Call function to remove the boss (found within .as class for Boss)
								boss.removeBoss();
								//Remove the boss's health bar
								removeChild(bossHealthBar);
							}
							
							//Load and play the boss hit sound sound
							var bossHitSound:Sound = new Sound(); 
							bossHitSound.addEventListener(Event.COMPLETE, bossHitSoundLoaded); 
							var bossHitSoundRequest:URLRequest = new URLRequest("Sounds/Boss Growl.mp3"); 
							bossHitSound.load(bossHitSoundRequest); 
									
							function bossHitSoundLoaded(event:Event):void 
							{ 
								bossHitSound.play(); 
							}
						}
							
						//If a bullet hits the boss's shield area
						if (boss.bossShieldArea.hitTestObject(bulletList[k]))
						{
							//Remove the bullet
							bulletList[k].removeBullet();
							trace("Hit the boss's shield");
						}
						
				}
			}
		}
		
		//Check for collision between enemy and player
		//If there are any enemies left in the enemyList array
		if (enemyList.length > 0)
		{ 
			//For each enemy in the array
			for (var m:int = 0; m < enemyList.length; m++)
			{ 
				//If an enemy and a player collide, and player.endGame is false, and enemyHit is false (in this
				//case, this ensures that if a player collides with an enemy in the short amount of time after it
				//has been hit but before it has been removed from the screen, the player doesn't lose) AND the player's
				//temporary invincibility (given to player after they've been hit) is not turned on
				if (enemyList[m].monster_hitPoint.hitTestObject(player) && player.endGame == false && enemyHit == false && player.tempInvincibility == false)
				{
					//Call function playerwasHit (see below)
					playerwasHit();

				}
			}
		}
		
		//If the current level is 3
		if (currentLevel == 3)
		{
			//If there are any boss bullets left
			if (bossBulletList.length > 0)
			{
				//For each boss bullet
				for (var c:int = 0; c < bossBulletList.length; c++)
				{
					//if a bullet from the boss hits the player, AND the game hasn't ended yet, AND the player's invincibility is turned off, AND the boss hasn't been defeated yet
					if (bossBulletList[c].bossBullet_hitPoint.hitTestObject(player) && player.endGame == false && player.tempInvincibility == false && bossDefeated == false)
					{
						//Remove the boss bullet
						bossBulletList[c].removeBullet();
						//Call the playerwasHit function
						playerwasHit();
					}
				}
			}
			
			//If boss hits player, and the game hasn't ended yet, and the player's invincibility is turned off, and the boss has not yet been defeated
			if (player.hitTestObject(boss.boss_hitPoint) && player.endGame == false && player.tempInvincibility == false && bossDefeated == false)
			{
				//Call the playerWasHit function
				playerwasHit();
			}
		}

		
		function playerwasHit ():void
		{
			//Turn the player's temporary invincibility on
			player.tempInvincibility = true;
			//Decrease player's HP by 20
			currentHP -= 20;
			//update the health bar
			updateHealthBar();
					
			//Set player.hit to true
			player.hit = true;
				
			//Start timer, which will provide player with 1.5 seconds of invicibility after being hit by an enemy
			var timer4:Timer = new Timer(1500);
			timer4.addEventListener(TimerEvent.TIMER,timer4Done);
			timer4.start();
			trace("player collided with enemy");
							
			//When timer is done
			function timer4Done(e:TimerEvent):void
			{
				//Set player.hit to false
				player.hit = false;
				//Stop the timer
				timer4.stop();
				//Turn off the player's temp invincibility
				player.tempInvincibility = false;
			}
					
			//If the player's HP is less than or equal to 0
			if(currentHP <= 0)
			{
				//Set a timer to call timer5Done when it has finished (provides a delay between the player
				//being hit for the final time, and the losing screen actually popping up)
				var timer5:Timer = new Timer(750);
				timer5.addEventListener(TimerEvent.TIMER,timer5Done);
				timer5.start();
						
				//When timer is done
				function timer5Done (e:TimerEvent):void
				{
					//Stop the timer
					timer5.stop();
					//Call loseGame() function
					loseGame();
				}
						
				//Set player.endGame to true
				player.endGame = true;
			}

			//Load and play the hit sound
			var AJHitSound:Sound = new Sound(); 
			AJHitSound.addEventListener(Event.COMPLETE, AJHitSoundLoaded); 
			var AJHitSoundRequest:URLRequest = new URLRequest("Sounds/AJ hit.mp3"); 
			AJHitSound.load(AJHitSoundRequest); 
					
			function AJHitSoundLoaded(event:Event):void 
			{ 
				AJHitSound.play(); 
			}
		}
		
		
		//If player.hit is true, set player to hit position
		if (player.hit == true)
		{
			player.gotoAndStop("hit");

		}
		
		//Code for seeing if a player is colliding with a coin (and therefore should be collecting it)
		//If there are any coins left in the array
		if (coinList.length > 0)
		{ 
			//For each coin in the array
			for (var n:int = 0; n < coinList.length; n++)
			{ 
				//If the player hits a coin
				if (coinList[n].hitTestObject(player))
				{
					//Award player 10 points
					currentScore += 10;
					//update score
					updateScore();
					//Remove the coin
					coinList[n].removeCoin();
					
					//Load and play the coin collect sound
					var coinCollectSound:Sound = new Sound(); 
					coinCollectSound.addEventListener(Event.COMPLETE, coinCollectSoundLoaded); 
					var coinCollectSoundRequest:URLRequest = new URLRequest("Sounds/Coin Ding.mp3"); 
					coinCollectSound.load(coinCollectSoundRequest); 
						 
					function coinCollectSoundLoaded(event:Event):void 
					{ 
						coinCollectSound.play(); 
					}

				}
			}
		}
	}

	//Stops the player's movement
	public function stopPlayer(ke:KeyboardEvent):void
	{
		
		//If user releases a moving left/right key, set the corresponding boolean(s) to false and set player.move to false
		if (ke.keyCode == Keyboard.RIGHT)
		{
			player.moveRight = false;
			player.move = false;
		}
		if (ke.keyCode == Keyboard.LEFT)
		{
			player.moveLeft = false;
			player.move = false;
		}

		//If user releases a ducking/jumping key, set the corresponding boolean(s) to false, but
		//DON'T set player.move to false (as the player may still be moving)
		if (ke.keyCode == Keyboard.DOWN)
		{
			player.downPressed = false;	
			player.noShoot = false;
		}
			
		if (ke.keyCode == Keyboard.UP)
		{
			player.upPressed = false;
			player.jumpUp = false;
		}

	}
	
	//If user presses the space bar and calls the shootBullet() function
	public function shootBullet():void 
	{
		//Declaration of string playerDirection
		var playerDirection:String;
		
		//If the scale is -1, set playerDirection to left
		if(player.scaleX < 0)
		{
			playerDirection = "left";
		} 
		
		//If scale is 1, set playerDirection to right
		else if(player.scaleX > 0)
		{
			playerDirection = "right";
		}
		
		//If current level is 1
		if (currentLevel == 1)
		{
			//Create a new bullet (NOTE: bullet has it's own class definition --> see .as file "bullet")
			//Send the player's x pos (taking into account scrollX), y pos, the player's direction, the player's speed, and the y pos of the currentLevel
			//(in the instance that the player has moved up a ladder) to the bullet constructor function
			var myBullet1:bullet = new bullet(player.x-scrollX, player.y, playerDirection, player.xSpeed, level1.y);
			//Add the bullet WITHIN level1
			level1.addChild(myBullet1);
			
			//Add an event listener to each bullet that checks to see if the bullet is removed; calls function removeArrayBullet
			myBullet1.addEventListener(Event.REMOVED_FROM_STAGE, removeArrayBullet);
			
			//Add the bullet into the bulletList array(keeps track of all the bullets on the screen in order to check for
			//enemy interaction)
			bulletList.push(myBullet1);
		}

		//If current level is 2
		else if (currentLevel == 2)
		{
			//Create new bullet and send in the same variables as above, only instead of level1.y, send in level2.y
			var myBullet2:bullet = new bullet(player.x-scrollX, player.y, playerDirection, player.xSpeed, level2.y);
			//Add the bullet WITHIN level2
			level2.addChild(myBullet2);
			
			//Add an event listener to each bullet that checks to see if the bullet is removed; calls function removeArrayBullet
			myBullet2.addEventListener(Event.REMOVED_FROM_STAGE, removeArrayBullet);
			
			//Add the bullet into the bulletList array
			bulletList.push(myBullet2);
		}
		
		//If current level is 3
		else
		{
			//Create new bullet, and send all above variables + level3.y
			var myBullet3:bullet = new bullet(player.x-scrollX, player.y, playerDirection, player.xSpeed, level3.y);
			//Add the bullet WITHIN level3
			level3.addChild(myBullet3);
			
			//Add an event listener to each bullet that checks to see if the bullet is removed; calls function removeArrayBullet
			myBullet3.addEventListener(Event.REMOVED_FROM_STAGE, removeArrayBullet);
			
			//Add the bullet into the bulletList array
			bulletList.push(myBullet3);
		}

		//Load and play fireball sound effect
		var fireballSound:Sound = new Sound(); 
		fireballSound.addEventListener(Event.COMPLETE, fireballSoundLoaded); 
		var fireballSoundRequest:URLRequest = new URLRequest("Sounds/Fireball.mp3"); 
		fireballSound.load(fireballSoundRequest); 
				
		function fireballSoundLoaded(event:Event):void 
		{ 
			fireballSound.play(); 
		}
	}
	
	public function removeArrayBullet (e:Event):void
	{ 
		//Removes bullet that triggered the event listener from the array
		bulletList.splice(bulletList.indexOf(e.currentTarget), 1);
	}
	
	//Function adds enemies to the level; function takes in an x value and a y value
	public function addEnemy(xLocation:int, yLocation:int, enemyType:int):void
	{
		//NOTE: All enemies have their own class definitions --> see .as file "Enemy", "Enemy2", "Enemy3"
		
		//Create a type 1 enemy
		if (enemyType == 1)
		{
			//Create a new enemy; send the x and y position to the Enemy constructor function
			var enemy:Enemy = new Enemy(xLocation, yLocation);
					
			//If the current level is 1
			if (currentLevel == 1)
			{
				//Add the enemy WITHIN level1
				level1.addChild(enemy);
			}
			
			//If the current level is 2
			else if (currentLevel == 2)
			{
				//Add the enemy WITHIN level 2
				level2.addChild(enemy);
			}
			
			//If the current level is 3
			else
			{
				//Add the enemy WITHIN level 3
				level3.addChild(enemy);
			}
			//Add an event listener to each enemy that checks to see if the enemy is removed; calls function removeArrayEnemy
			enemy.addEventListener(Event.REMOVED_FROM_STAGE, removeArrayEnemy);
			//Add the enemy into the enemyList array
			enemyList.push(enemy);
		}
		
		//Create a type 2 enemy
		else if (enemyType == 2)
		{
			//Create a new enemy; send the x and y position to the Enemy2 constructor function
			var enemy2:Enemy2 = new Enemy2(xLocation, yLocation);
			
			//Add the enemy to the corresponding level
			if (currentLevel == 1)
			{
				trace("Adding enemy");
				//Add the enemy WITHIN level1
				level1.addChild(enemy2);
			}
			
			else if (currentLevel == 2)
			{
				//Add the enemy WITHIN level 2
				level2.addChild(enemy2);
			}
			
			else
			{
				//Add the enemy WITHIN level 3
				level3.addChild(enemy2);
			}
			//Add an event listener to each enemy that checks to see if the enemy is removed; calls function removeArrayEnemy
			enemy2.addEventListener(Event.REMOVED_FROM_STAGE, removeArrayEnemy);
			//When the enemy is added to the stage (when it enters frame), call the enemyFollow function
			enemy2.addEventListener(Event.ENTER_FRAME, enemyFollow);
			//Add the enemy into the array
			enemyList.push(enemy2);
			
			function enemyFollow(e:Event):void
			{
				//If the current level is 1
				if (currentLevel == 1)
				{
					//Call the enemy that triggered the event listener's moveEnemy function (located in the class), and
					//send in the enemy (e.target), the player, scrollX, and level1.y
					e.target.moveEnemy(e.target, player, scrollX, level1.y);
				}
				
				//Do the same for levels 2 and 3, but send in the corresponding level's y pos
				else if (currentLevel == 2)
				{
					e.target.moveEnemy(e.target, player, scrollX, level2.y);
				}
				else
				{
					e.target.moveEnemy(e.target, player, scrollX, level3.y)
				}

			}
		}
		
		//Create a type 3 enemy
		else if (enemyType == 3)
		{
			//Create a new enemy; send the x and y position to the Enemy3 constructor function
			var enemy3:Enemy3 = new Enemy3(xLocation, yLocation);
			
			//Add the enemy to the corresponding level
			if (currentLevel == 1)
			{
				//Add the enemy WITHIN level1
				level1.addChild(enemy3);
			}
			
			else if (currentLevel == 2)
			{
				//Add the enemy WITHIN level 2
				level2.addChild(enemy3);
			}
			else
			{
				//Add the enemy WITHIN level 3
				level3.addChild(enemy3);
			}
			
			//Add an event listener to each enemy that checks to see if the enemy is removed; calls function removeArrayEnemy
			enemy3.addEventListener(Event.REMOVED_FROM_STAGE, removeArrayEnemy);
			//Add the enemy to the array
			enemyList.push(enemy3);

		}

	}
	

	public function removeArrayEnemy(e:Event):void
	{
		//Set enemyHit to false (so that program will resume detecting enemy and bullet collisions/ enemy and player collisions)
		enemyHit = false;
		//Removes enemy that triggered the event listener from the array
		enemyList.splice(enemyList.indexOf(e.currentTarget), 1);
		
	}
	
	public function addCoin(xLocation:int, yLocation:int):void
	{
		//Create new coin and send in x and y position to the constructor function
		var coin:Coin = new Coin(xLocation, yLocation);
		
		//Add the coin to the corresponding level
		if (currentLevel == 1)
		{
			level1.addChild(coin);
		}
		
		else if (currentLevel == 2)
		{
			level2.addChild(coin);
		}
		
		else
		{
			level3.addChild(coin);
		}
		
		//Add event listener that checks to see if the coin has been removed from the stage and calls the function
		//removeArrayCoin
		coin.addEventListener(Event.REMOVED_FROM_STAGE, removeArrayCoin);
		//Add the coin to the coinList array
		coinList.push(coin);
	}
	
	public function removeArrayCoin(e:Event):void
	{
		//Removes coin that triggered the event listener from the array
		coinList.splice(coinList.indexOf(e.currentTarget), 1);
	}
	
	//update the player's health bar
	public function updateHealthBar():void
	{
		 //The percent of HP remaining is the currentHP divided by the player's total HP
		 percentHP = currentHP / totalHP;
		 //Change the scaleX of the barColour within the player's health bar to the percent of HP remaining
		 //(e.g. if player has 50% health, scale the scaleX to 0.5)
		 playerHealthBar.barColour.scaleX = percentHP;
	}
	
	//Update the boss's health bar
	public function updateBossHealthBar():void
	{
		//Same as with player's health bar, only with the boss's health bar
		percentBossHP = currentBossHP/totalBossHP;
		bossHealthBar.bossBarColour.scaleX = percentBossHP;
		
	}
	
	public function updateScore():void
	{
		//trace("updating score");
		//Convert int score to string
		currentScoreString = String(currentScore);
		//Display the currentScoreString in the score textbox
		playerScoreTextBox.scoreText.text = "Score: "+currentScoreString;
	}
	
	//Controls the boss's shooting
	public function bossAttack():void
	{
		//If bossBulletShot is false and the boss has NOT been defeated
		if (bossBulletShot == false && bossDefeated == false)
		{
			//Change bossBulletShot to true (this prevents an infinite number of timers from being set and going off every second)
			bossBulletShot = true;
			//Start a new timer that will call shootBossBullet function when done
			var timer6:Timer = new Timer(3500);
			timer6.addEventListener(TimerEvent.TIMER, shootBossBullet);
			timer6.start();
		}

		
		function shootBossBullet(te:TimerEvent):void
		{
			//Stop the timer
			timer6.stop();
			//Change bossBulletShot to false (which will start another timer)
			bossBulletShot = false;
			
			//Check to see if boss has been defeated; prevents a timer that was set BEFORE the 
			//boss was killed from releasing a bullet if the boss HAS now been killed
			if (bossDefeated == false)
			{
				//Create a new bossBullet and send in the desired x pos, as well as the boss's current 
				//y position
				var myBossBullet:bossBullet = new bossBullet(3900, boss.y);
				//Add the bossBullet within level 3
				level3.addChild(myBossBullet);
					
				//Add an event listener to each boss bullet that checks to see if the bullet is removed; calls function removeArrayBossBullet
				myBossBullet.addEventListener(Event.REMOVED_FROM_STAGE, removeArrayBossBullet);
					
				//Add the bossBullet into the array
				bossBulletList.push(myBossBullet);
			}

		}

	}
	
	public function removeArrayBossBullet(e:Event):void
	{
		//remove the boss bullet that triggered the event listener from the bossBulletList array
		bossBulletList.splice(bossBulletList.indexOf(e.currentTarget), 1);
	}		
		

	//Function will restart the game
	public function resetGame(me:MouseEvent):void
	{
		//if the menuScreen2 is visible, hide it
		if (menuScreen2.visible == true)
		{
			menuScreen2.visible = false;
		}
		
		trace("reset game");
		
		//Make the endScreen invisible
		endScreen.visible = false;

		//Set the x and y values of level1 to 0
		level1.x = 0;
		level1.y = 0;
		
		//Remove all the enemies remaining on the level
		for (var i:int = 0; i< enemyList.length; i++)
		{
			enemyList[i].removeEnemy();
		}
		
		//Remove all the coins remaining on the level
		for (var j:int = 0; j< coinList.length; j++)
		{
			coinList[j].removeCoin();
		}
		
		//If player is resetting the game from level2
		if (currentLevel == 2)
		{
			//Remove level2 and add level1 at the lowest index
			removeChild(level2);
			addChildAt(level1, 0);

		}
		
		//If player is resetting the game from level3
		if (currentLevel == 3)
		{
			//Remove level3 and add level1 at the lowest index
			removeChild(level3);
			addChildAt(level1, 0);
			//Reset the boss's HP to 100
			currentBossHP = 100;
			//Set the bossDefeated boolean to false
			bossDefeated = false;
		}
		
		//Set currentLevel back 1
		currentLevel = 1;

		//Set scrollX to 0
		scrollX = 0;
		//Set player to his initial x and y values
		player.x = 150;
		player.y = 534;
		//Make the player face right and put him in standing position
		player.scaleX = 1;
		player.gotoAndStop("standing");
		//make sure hitWater boolean is set back to false
		player.hitWater = false;
		//Set the doors to closed
		level1.lockedDoor.gotoAndStop("closed");	
		level2.lockedDoor2.gotoAndStop("closed");
		level3.lockedDoor3.gotoAndStop("closed");
		//Set the keys to visible, and the collected booleans to false
		level1.doorKey.visible = true;
		level1.doorKey.collected = false;
		level2.doorKey2.visible = true;
		level2.doorKey2.collected = false;
		level3.doorKey3.visible = true;
		level3.doorKey3.collected = false;
		
		//Call the function addEnemiestoLevel1 to re-add all the enemies back to level1
		addEnemiestoLevel1();
		
		//Add coins back into level1
		addCoinstoLevel1();
		
		//Reset score and update the score textbox
		currentScore = 0;
		updateScore();
		
		//Reset health and update the health bar
		currentHP = 100;
		updateHealthBar();
		
		//Set the endGame boolean to false, the gameHasStarted boolean to true
		player.endGame = false;
		gameHasStarted = true;
		
		//Reset timer
		gameStartTime = getTimer();
		
	}
		
	}
	
}
