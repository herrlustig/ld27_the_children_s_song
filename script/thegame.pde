final int screenWidth = 512;
final int screenHeight = 432;

float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;

width = 2000;
height = 2000;
int lvl_width = 1000;
int lvl_height = 1000;

// challenge stuff
boolean challengeMode = false;
boolean activChallenge = false; // will be set by hero, if started he can not move until challenge is over
boolean endedSinging = false;
LevelText ltxt_instruction;
float challengeStart = 0; // in milliseconds
float challengeStartHeroSing = 0; // in milliseconds
int lastSecond = -1; 
boolean challenge_success = false;
Creature challenger;

boolean game_finished = false;
int creature_count;


void initialize() {
  addScreen("level", new HeroLevel(lvl_width, lvl_height));  
  // println( "initialized");
}

void reset() {
  clearScreens();
  addScreen("MainLevel", new MainLevel(4*lvl_width, lvl_height));  
}

class HeroLevel extends Level {
  HeroLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("background layer", new MainBackgroundLayer(this)); 
    addLevelLayer("layer", new HeroLayer(this));
	setViewBox(0,0,screenWidth,screenHeight);
	
	
  } 
}

class MainBackgroundLayer extends LevelLayer {
  Mario mario;
  MainBackgroundLayer(Level owner) {
    super(owner, owner.width, owner.height, 0,0, 0.75,0.75);
    setBackgroundColor(color(0, 100, 190));
    // addBackgroundSprite(new TilingSprite(new Sprite("graphics/floor_2.gif"),0,0,width,height)); // TODO: remove , not needed in this game
  }
  void draw() {
    super.draw();
  }
}

// main layer
class HeroLayer extends LevelLayer {
  HeroLayer(Level owner) {
    super(owner);
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/floor.gif"),0,0,width,height));

	// walls
    addBoundary(new Boundary(0,height-10,width,height-10));
    addBoundary(new Boundary(width,10,0,10));
	addBoundary(new Boundary(0,0,0,height));
	addBoundary(new Boundary(width-10,height, width-10,0));
	

    showBoundaries = true;
    hero = new Hero(width/2, height/2);
	hero.setPosition(50, 50);
    addPlayer(hero);
	Creature creature1 = new Creature(64, height-64);
	Creature creature2 =  new Creature(350, height-64 -100);
	Creature creature3 =  new Creature(780, height-64 -400);
	Creature creature4 =  new Creature(840, height-64 -100);
	Creature creature5 =  new Creature(840, 100);
	addInteractor(creature1);
	addInteractor(creature2);
	addInteractor(creature3);
	addInteractor(creature4);
	addInteractor(creature5);
	
	// this many children must be found
	creature_count = 5;

	
	// just for testing
	/*
	hero.addFollower(creature1);
	creature1.following = true;
	hero.addFollower(creature2);
	creature2.following = true;
	hero.addFollower(creature3);
	creature3.following = true;
	hero.addFollower(creature4);
	creature4.following = true;
	hero.addFollower(creature5);
	creature5.following = true;
	
	*/
	
	MotherCreature mother =  new MotherCreature(350, 350);
	addInteractor(mother);

	
	
	// println( "added player hero");
	LevelText ltxt1 = new LevelText("", 20, height-64, "fonts/acmesa.ttf", 20);
	ltxt1.attach_to(hero);
	// hero.changeText("changed text");
	addText(ltxt1);
	
	ltxt_instruction = new LevelText("", 0, 0, "fonts/acmesa.ttf", 20);
	addText(ltxt_instruction);

	

  }
  
  void draw() {
    super.draw();
	// println("level draw called" + viewbox);
    viewbox.track(parent, hero);
    // just in case!
    if(hero!=null && hero.active != null && hero.active.name!="dead" && hero.y>height) {
      reset();
    }
	
  }
}



class Hero extends Player {

  float speed = 2;
  ArrayList<Positionable> followers; // following creatures
  float followDistance = 15;
  ArrayList<int> played_notes;
  int hero_note_length = 500;
  boolean note_0_playing = false;
  boolean note_2_playing = false;
  boolean note_4_playing = false;
  boolean note_7_playing = false;
  boolean note_9_playing = false;
  boolean note_12_playing = false;



  Hero(float x, float y) {
    super("Hero");
    setStates();
    setPosition(x,y);
    handleKey('W');
    handleKey('A');
    handleKey('D');
    handleKey('S');
    handleKey('C');
    handleKey('F');
	handleKey('G');
    handleKey('H');
    handleKey('J');
    handleKey('K');
    handleKey('L');



    setImpulseCoefficients(DAMPENING,DAMPENING);
	this.followers = new ArrayList<Positionable>();
	played_notes = new ArrayList<int>();
	// println( "Hero initialized ");

  }
  
  void update() {
	super.update();

	// update followers
	if (this.followers.size() > 0) {
		calcFollowMove(this.followers.get(0), this.getX(), this.getY());
		// println("first follower updated with x y: " + this.followers.get(0).getX() + " " + this.followers.get(0).getY());
		for( int i=0; i < this.followers.size() -1; i++ ) {
			calcFollowMove(this.followers.get(i+1), this.followers.get(i).getX(), this.followers.get(i).getY());
		}
	}
  
  
  }
  
  void calcFollowMove(Positional p, float xin, float yin) {
	  float dx = xin - p.getX();
	  float dy = yin - p.getY();
	  float angle = atan2(dy, dx);
	  float new_distanceX = dx - 1;
	  float new_distanceY = dy - 1;
	  float scaleSizeX = p.sx*32*0.5;
	  float scaleSizeY = p.sy*60*0.5;
	  if (new_distanceX < this.followDistance + scaleSizeX) { new_distanceX = this.followDistance  + scaleSizeX};
	  if (new_distanceY < this.followDistance + scaleSizeY) { new_distanceY = this.followDistance  + scaleSizeY};
	  float x = xin - cos(angle) * new_distanceX; 
	  float y = yin - sin(angle) * new_distanceX; 
	  p.setPosition(x,y);
	  // TODO: set the same movement state
	  p.setCurrentState("idle");

	  // TODO: they should be facing the right direction
	  
  }
  
  
  
  void addFollower(Creature p) {
	p.setFollowing(true)
	this.followers.add(p);
	// println("the hero has now " + this.followers.size() + " followers");
  }
  
  void setStates() {
    // idling state
    addState(new State("idle", "graphics/Standing-hero.gif"));

    // running state
    addState(new State("running", "graphics/Running-hero.gif", 1, 4));

    // default: just stand around doing nothing
    setCurrentState("idle");
  }
  void handleInput() {
  
	// only let him move when no active challenge
	if (activChallenge != true) {
		if(isKeyDown('A') || isKeyDown('D')) {
		  if (isKeyDown('A')) {
			// when we walk left, we need to flip the sprite
			setHorizontalFlip(true);
			// walking left means we get a negative impulse along the x-axis:
			addImpulse(-speed, 0);
			// and we set the viewing direction to "left"
			setViewDirection(-1, 0);
		  }
		  if (isKeyDown('D')) {
			// when we walk right, we need to NOT flip the sprite =)
			setHorizontalFlip(false);
			// walking right means we get a positive impulse along the x-axis:
			addImpulse(speed, 0);
			// and we set the viewing direction to "right"
			setViewDirection(1, 0);
		  }

		}
		if (isKeyDown('W')) { 
			addImpulse(0,-2); 
			setViewDirection(0, -1);
		}
		if (isKeyDown('S')) { 
			addImpulse(0,2); 
			setViewDirection(0, 1);
		}
		
		if(isKeyDown('C') && challengeMode && challenger) {
			// start the challenge timer
			challengeStart = millis();
			activChallenge = true;
			ltxt_instruction.setText('You accepted\nthe challenge');
			
		}
	}
	if(isKeyDown('F')) {
		if(note_0_playing == false) {
			note_0_playing = true;
			playNote(0);
			setTimeout(function () { note_0_playing = false} ,hero_note_length/2);
		}
	}
	if(isKeyDown('G')) {
		if(note_2_playing == false) {
			note_2_playing = true;
			playNote(2);
			setTimeout(function () { note_2_playing = false} ,hero_note_length/2);
		}
	}
	if(isKeyDown('H')) {
		if(note_4_playing == false) {
			note_4_playing = true;
			playNote(4);
			setTimeout(function () { note_4_playing = false} ,hero_note_length/2);
		}
	}
	if(isKeyDown('J')) {
		if(note_7_playing == false) {
			note_7_playing = true;
			playNote(7);
			setTimeout(function () { note_7_playing = false} ,hero_note_length/2);
		}
	}
	if(isKeyDown('K')) {
		if(note_9_playing == false) {
			note_9_playing = true;
			playNote(9);
			setTimeout(function () { note_9_playing = false} ,hero_note_length/2);
		}
	}
	if(isKeyDown('L')) {
		if(note_12_playing == false) {
			note_12_playing = true;
			playNote(12);
			setTimeout(function () { note_12_playing = false} ,hero_note_length/2);
		}
	}
	// and what do we look like when we do this?
    if (active.mayChange())
    {
      // if we're not jumping, but left or right is pressed,
      // make sure we're using the "running" state.
      if(isKeyDown('A') || isKeyDown('D') || isKeyDown('W') || isKeyDown('S') ) {
        setCurrentState("running");
      }
      
      // if we're not actually doing anything,
      // then we change the state to "idle"
      else {
        setCurrentState("idle");
      }
    }
  }
  
  // plays notes and adds them to the played notes during challenge
  void playNote(int noteNr) {
	// println("hero played note " + noteNr);
	if(activChallenge && endedSinging) {
		played_notes.add(noteNr);
		// if more notes in played_notes then challengers melody, remove the first
		if (played_notes.size() > challenger.notes.size()) {
			played_notes.remove(0);
			// println("remove note because its longer then melody, first is now" + played_notes.get(0));
		}
		
		if (played_notes.size() == challenger.notes.size()) {
			// println("melody played has same size! check it now")
			is_success = true;
			for ( int i = 0; i < challenger.notes.size(); i++;) {
				if (played_notes.get(i) != challenger.notes.get(i)) {
					// println("NOT ok note " + played_notes.get(i) + "  , should be " + challenger.notes.get(i) )
					is_success = false;
					break;
				} else {
					// println("ok note " + played_notes.get(i))
				}
			
			}
			if (is_success) {
				challenge_success = true;
				// println("SUCCESS!!!");

			}
		}
		
	}
	dynsoundManager.play(singing_instrument_hero,""+(init_pentatone+init_singing_hero+init_singing_note+noteNr),hero_volume,hero_note_length);
  }
}
Hero hero;


class Creature extends Interactor {
  float distToHero = 200000; // big default value
  boolean heroIsNear = false;
  final float distToHeroInteraction = 160; // sets distance for interaction, switches heroIsNear boolean
  final float distToHeroActivateChallenge = 80; // sets distance for interaction, switches heroIsNear boolean
  String instrument = "piccolo";

  boolean following = false;
  boolean beaten = false; // if the hero successfully challenged the animal, this turns true

  Envelope rotateEnv;
  
  boolean isSinging = false; 
  
  ArrayList<int> notes;
  ArrayList<int> notes_length; // in milliseconds
  
  float singing_timer = 0;
  int current_note = 0;
  int current_song_length = 0; // in milliseconds
  int pause_between_notes = 300;
  int pause_at_end = 1500;
  float sx_orig = 1;
  float sy_orig = 1;


  Creature(float x, float y) {
    super("Creature");
    setStates();
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setPosition(x,y);
	// TODO: this needs quite time, copy object template as solution?
	rotateEnv = new Envelope([0,0],[1],"repeat",0,"custom","Math.sin(y/15.75)*(Math.PI*2/30)");
	rotateEnv.start();
	
	// scale 
	this.sx_orig = 1+ (Math.random()/2);
	this.sy_orig = 1+ (Math.random()/2);
	this.sx = this.sx_orig; ;//2;
	this.sy = this.sy_orig;//2;
	
	// melody stuff
	
	notes = new ArrayList<int>();
	notes_length = new ArrayList<int>();
	
	// choose instrument for voice
	instrument = possible_instruments[floor(Math.random()*possible_instruments.length)];
	
	generateNewSong(song_length); 
	
  }
  
  
  // melody_length, nr of notes
  void generateNewSong(int melody_length) {
	// stop current singing
	isSinging = false;
	// clear the old melody
	notes.clear();
	notes_length.clear();
	int total_length = 0; // millisec, keep track of how long the song goes
	int max_song_length = 4000; // a maximum of 4 seconds
	ArrayList<int> possible_notes = new ArrayList<int>(); // TODO: influence by environment tonality
	possible_notes.add(0);
	possible_notes.add(2); 
	possible_notes.add(4); 
	possible_notes.add(7); 
	possible_notes.add(9);
	possible_notes.add(12);
	ArrayList<int> possible_lengths = new ArrayList<int>(); // TODO: could be influenced by environment rhythm
	possible_lengths.add(250); 
	possible_lengths.add(500); 
	for(int i = 0; total_length <= max_song_length && notes.size() < melody_length; i++) {
		// pick a note
		int new_note = possible_notes.get(floor(Math.random()*(possible_notes.size())));
		// pick its length
		int new_length = possible_lengths.get(floor(Math.random()*(possible_lengths.size()-1)));
		if ( total_length + new_length <= max_song_length) {
			notes.add(new_note);
			notes_length.add(new_length);
			total_length = total_length + new_length;
		} else {
			break
		}
	}
	this.current_song_length = total_length + ((this.notes.size()-1)*pause_between_notes)  + pause_at_end;
	// println("New song generated with total length of " + this.current_song_length + " With #" +notes.size() + " notes");
  }
  
  // creature sing
  void sing() {
	// only start singing if not currently singing
	if (this.isSinging == false && game_finished != true) {
		this.isSinging = true;
		String s = "";
		for(int i = 0; i < this.notes.size(); i++) {
			s = s + this.notes.get(i) + " ";
		}
		// println("start singing this: " + s);
		int delay_singing = 500; // 500 ms delay till singing
		int at_time = delay_singing; 
		float note_volume = creatures_volume; // TODO: change, let the distance to hero decide
		for (int i = 0; i < this.notes.size(); i++) {
			var current_note = this.notes.get(i);
			var current_length = this.notes_length.get(i);
			// println("plan to sing singing note " + (24+current_note) + " length: " + current_length);
			scheduleNote(current_note, current_length, at_time, note_volume);

			
			at_time = at_time + current_length + (i*pause_between_notes);
		}
		// also set timeout function to stop singing
		stopSinging(this, this.current_song_length+delay_singing);
		
	}
  
  }
  
  void stopSinging(Positionable thisanimal, int when_to_stop) {
		var thisanimal_ = thisanimal;
		var when_ = when_to_stop;
		setTimeout(function () { 
			thisanimal_.isSinging = false; 
			// println("stop singing");
		},when_)
  
  }
  
  void scheduleNote(int note_nr, int note_length_in_ms, time_to_play, float note_volume) {
	var volume_ = note_volume;
	var current_note_ = note_nr;
	var current_length_ = note_length_in_ms;
	var at_time_ = time_to_play;
	var thiscreature = this;
	setTimeout( function () {
				// TODO: only play notes if hero is near
				dynsoundManager.play(thiscreature.instrument, ""+(init_pentatone+init_singing_note+current_note_), volume_, current_length_);
				// println("now singing note " + (current_note_) + " length: " + current_length_);
			}, at_time_); // TODO: just for testing, remove '*4'
  
  }
  
  void setFollowing(boolean b) {
	following = true;
  
  }
   void update() {
	super.update();
	
	if (this.heroIsNear) {
	
		// only auto sing if no challenge and not beaten
		if (activChallenge == false && this.beaten != true ) { this.sing(); }
		rotateEnv.update(0.03); // TODO: add real framerate
		this.r = rotateEnv.current_value;
		// if not beaten already darken screen when you get near
		if (this.beaten == false && game_finished != true){
			float alpha_value = (1 - (this.distToHero/distToHeroInteraction))*255*2;
			if (alpha_value > 255) alpha_value = 255; // just to be sure
			// println("Creature, set fade out to " + alpha_value);
			this.layer.setFadeOutAlpha(alpha_value);
		}
	} else {
		if (this.r > 0.05 || this.r < -0.05) {
			if (this.r > 0) {
				this.r = this.r - (Math.PI*2/360);
			} else {
				this.r = this.r + (Math.PI*2/360);
			}
		}
	}
	
	// only the current challenger has to do this
	if ( this == challenger ) {
		// challenge first part, creature starts singing after a while
		if (activChallenge && endedSinging == false){
			float now = millis();
			float diff = ((now/1000)-(challengeStart/1000));
			float diff_seconds = floor(diff);
			if (now%1000) {
				// println( "Seconds:" + diff + " rounded: " + diff_seconds);
			}
			
			if (diff_seconds < 1) { // TODO: wait till last note has been sung
				// challenger.stopSinging(); // TODO
			}
			
			// Remove instruction
			if (diff_seconds >= 1 && diff_seconds < 2) { // TODO: change to 10, just for testing
				// println("Remove text");
				ltxt_instruction.setText('');
				hero.changeText('');

			}
			if (diff_seconds >= 2 && diff_seconds < (2 + (challenger.current_song_length/1000) + 1)) { 
				// println("Remove text");
				ltxt_instruction.setText('Listen');
				//  start singing
				challenger.sing();
			}
			if (diff_seconds >= (2 + (challenger.current_song_length/1000) + 1)) { 
				endedSinging = true; // end first part of challenge. now the hero has to sing
				challengeHeroStart = millis(); // start timer for hero 
			
			}
			
		}
		
		// second part of challenge, creature ended, hero must sing now, ten seconds time
		
		if ( activChallenge && endedSinging ) {
			float now = millis();
			float diff = ((now/1000)-(challengeHeroStart/1000));
			float diff_seconds = floor(diff);
			int max_time = 10;
			if (diff_seconds < 1 ) {
				ltxt_instruction.setText('Sing, you have\n' + max_time +' secs time');
			}
			if (diff_seconds >= 1 && diff_seconds < max_time + 1) {
				// here the hero sings
				if (challenge_success) {
					// reset challenge stuff
					challenge_success = false;
					activChallenge = false;
					endedSinging = false;
					ltxt_instruction.setText('It trusts you now');
					setTimeout(function() { ltxt_instruction.setText('')}, 1500 );
					challenger.beaten = true;
					hero.changeText("Come with me!");
					setTimeout(function() { hero.changeText("");}, 2000 );
					this.layer.setFadeOutAlpha(0);
				}
			}
			if (diff_seconds >= max_time + 1) { 
				ltxt_instruction.setText("Challenge ended.\nIt does not trust you.");
				setTimeout( function() {
					ltxt_instruction.setText("Try again, Hit 'C'");
				}, 1500);
				// TODO: add instructional text
				activChallenge = false;
				endedSinging = false;
				// now generate a new song, it should not be that easy
				challenger.generateNewSong(song_length);				
			}
		}
	}
	
   }
   
   void draw(vx, vy, vw, vh) {
    super.draw(vx, vy, vw, vh);
   	if (drawableFor(vx,vy,vw,vh)) {
		// check distance to hero. if he is near start making noises/whistle and go in state "listen" if hero does it right
		// println("hero is here: " + hero.getX());
		if (game_finished != true && activChallenge == false && this.beaten == false) {
			distToHero = dist(this.getX(), this.getY(), hero.getX(), hero.getY());
			if (distToHero <= distToHeroInteraction) {
				if (heroIsNear) {
					this.sing();
					hero.changeText("What?! I have to sing?!");
					if (distToHero <= distToHeroActivateChallenge) {
						
						if (challengeMode == false) {
							challengeMode = true; // activate challenge!
							// set this creature as challenger
							challenger = this;
							ltxt_instruction.setPosition(this.layer.parent.viewbox.x+(this.layer.parent.viewbox.w/6), this.layer.parent.viewbox.y+(4*this.layer.parent.viewbox.h/6));
							ltxt_instruction.setText("Hit 'C' to accept\nthe song challenge");
						}
					} else {
						challengeMode = false; // deactivate challenge :/
						ltxt_instruction.setText("");
					}
					
				} else { // if it is false, turn it to true and initiate singing mode
					// println("hero is near!");
					heroIsNear = true;
				}
			} else { // hero is too far away to interact
				hero.changeText("");
				if ( heroIsNear ) {
					// println("hero is not near anymore!");
					heroIsNear = false;
					rotateEnv.reset();
				} else {
				
				}
			
			}
		}
		// if the hero have successfully challenged the animal it should follow him
		if (this.beaten && this.following == false) {
			hero.addFollower(this);
			this.following = true;
		}
	}
   }
  
  /**
   * Set up our states
   */
  void setStates() {
    // walking state
    // State walking = new State("idle", "graphics/creature-walking.gif", 1, 2);
    State walking = new State("idle", "graphics/creature.gif", 1, 1);

	
    walking.setAnimationSpeed(0.12);
    // SoundManager.load(walking, "audio/Squish.mp3");
    addState(walking);
	//  sState idle = new State("idle", "graphics/creature-walking.gif", 1, 2);
	State idle = new State("idle", "graphics/creature.gif", 1, 1);

    idle.setAnimationSpeed(0);
    addState(idle);
    
    setCurrentState("idle");
  }
}



class MotherCreature extends Interactor {
  float distToHero = 200000; // big default value
  boolean heroIsNear = false;
  final float distToHeroInteraction = 300; // sets distance for interaction, switches heroIsNear boolean
  final float distToHeroActivateChallenge = 0; // sets distance for interaction, switches heroIsNear boolean
  String instrument = "tuba";

  Envelope rotateEnv;
  Envelope squeezeEnv;
  
  boolean isSinging = false; 
  
  ArrayList<int> notes;
  ArrayList<int> notes_length; // in milliseconds
  
  float singing_timer = 0;
  int current_note = 0;
  int current_song_length = 0; // in milliseconds
  int pause_between_notes = 300;
  int pause_at_end = 1500;
  float sx_orig = 1;
  float sy_orig = 1;

  boolean beaten = false;
  boolean following = false;

  MotherCreature(float x, float y) {
    super("MotherCreature");
    setStates();
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setPosition(x,y);
	// TODO: this needs quite time, copy object template as solution?
	rotateEnv = new Envelope([0,0],[1],"repeat",0,"custom","Math.sin(y/15.75)*(Math.PI*2/30)");
	rotateEnv.start();
	
	// scale 
	this.sx_orig = 5.5*1.5;
	this.sy_orig = 5*1.5;
	this.sx = this.sx_orig; 
	this.sy = this.sy_orig;
	
	// melody stuff
	
	notes = new ArrayList<int>();
	notes_length = new ArrayList<int>();
	
	generateNewSong(song_length); 
	
  }
  
  
  // melody_length, nr of notes
  void generateNewSong(int melody_length) {
	// stop current singing
	isSinging = false;
	// clear the old melody
	notes.clear();
	notes_length.clear();
	int total_length = 0; // millisec, keep track of how long the song goes
	int max_song_length = 4000; // a maximum of 4 seconds
	ArrayList<int> possible_notes = new ArrayList<int>(); // TODO: influence by environment tonality
	possible_notes.add(0);
	possible_notes.add(2); 
	possible_notes.add(4); 
	possible_notes.add(7); 
	possible_notes.add(9);
	possible_notes.add(12);
	possible_notes.add(14);
	possible_notes.add(16); 
	possible_notes.add(19); 
	possible_notes.add(21); 
	possible_notes.add(24);
	ArrayList<int> possible_lengths = new ArrayList<int>(); // TODO: could be influenced by environment rhythm
	possible_lengths.add(250); 
	possible_lengths.add(500);
	possible_lengths.add(1000);
	possible_lengths.add(1000); 
	possible_lengths.add(1500);
	possible_lengths.add(2000); 
	for(int i = 0; total_length <= max_song_length && notes.size() < melody_length; i++) {
		// pick a note
		int new_note = possible_notes.get(floor(Math.random()*(possible_notes.size())));
		// pick its length
		int new_length = possible_lengths.get(floor(Math.random()*(possible_lengths.size()-1)));
		if ( total_length + new_length <= max_song_length) {
			notes.add(new_note);
			notes_length.add(new_length);
			total_length = total_length + new_length;
		} else {
			break
		}
	}
	this.current_song_length = total_length + ((this.notes.size()-1)*pause_between_notes)  + pause_at_end;
	// println("Mother: New song generated with total length of " + this.current_song_length + " With #" +notes.size() + " notes");
  }
  
  void sing() {
	// only start singing if not currently singing
	if (this.isSinging == false) {
		generateNewSong(8); // TODO: add sometimes, the mother can sing longer
		this.isSinging = true;
		String s = "";
		// TODO: remove this loop, only for debug
		for(int i = 0; i < this.notes.size(); i++) {
			s = s + this.notes.get(i) + " ";
		}
		// println("Mother: start singing this: " + s);
		int delay_singing = 500; // 500 ms delay till singing
		int at_time = delay_singing; 
		float note_volume = creatures_volume; // TODO: change, let the distance to hero decide
		for (int i = 0; i < this.notes.size(); i++) {
			var current_note = this.notes.get(i);
			var current_length = this.notes_length.get(i);
			// println("plan to sing singing note " + (24+current_note) + " length: " + current_length);
			scheduleNote(current_note, current_length, at_time, note_volume);

			
			at_time = at_time + current_length + (i*pause_between_notes);
		}
		// also set timeout function to stop singing
		// also set timeout function to stop singing
		stopSinging(this, this.current_song_length+delay_singing);
		
	}
  
  }
  
  void stopSinging(Positionable thisanimal, int when_to_stop) {
		var thisanimal_ = thisanimal;
		var when_ = when_to_stop;
		setTimeout(function () { 
			thisanimal_.isSinging = false; 
			// println("stop singing");
		},when_)
  }
  
  void scheduleNote(int note_nr, int note_length_in_ms, time_to_play, float note_volume) {
	var volume_ = note_volume;
	var current_note_ = note_nr;
	var current_length_ = note_length_in_ms;
	var at_time_ = time_to_play;
	var thiscreature = this;
	setTimeout( function () {
				// TODO: only play notes if hero is near
				dynsoundManager.play(mother_instrument, ""+(init_pentatone+init_singing_note+init_singing_note_mother+current_note_), volume_, current_length_);
				// println("Mother: now singing note " + (current_note_) + " length: " + current_length_);
			}, at_time_); // TODO: just for testing, remove '*4'
  
  }
  
  void setFollowing(boolean b) {
	following = true;
  
  }
   void update() {
	super.update();
	
	if (this.heroIsNear) {
	
		// only auto sing if no challenge and not beaten
		if (activChallenge == false && this.beaten != true ) { this.sing(); }
		rotateEnv.update(0.010); // TODO: add real framerate
		this.r = rotateEnv.current_value;
		this.sx = this.sx_orig + (rotateEnv.current_value*30/8);
		this.sy = this.sy_orig + (-rotateEnv.current_value*30/8);
		// if not beaten already darken screen when you get near
		if (this.beaten == false && game_finished != true){
			float alpha_value = (1 - (this.distToHero/distToHeroInteraction))*255*3;
			if (alpha_value > 255) alpha_value = 255; // just to be sure
			// println("Mother:, set fade out to " + alpha_value);
			this.layer.setFadeOutAlpha(alpha_value);
		}
	} else {
		if (this.r > 0.05 || this.r < -0.05) { // TODO: add a tolerance
			if (this.r > 0) {
				this.r = this.r - (Math.PI*2/640); //  Mother moves slower
			} else {
				this.r = this.r + (Math.PI*2/640);
			}
		}
	}
	
   }
   
   void draw(vx, vy, vw, vh) {
    super.draw(vx, vy, vw, vh);
   	if (drawableFor(vx,vy,vw,vh)) {
		// check distance to hero. if he is near start making noises/whistle and go in state "listen" if hero does it right
		if (game_finished != true && activChallenge == false && this.beaten == false) {
			distToHero = dist(this.getX(), this.getY(), hero.getX(), hero.getY());
			// println("Mother: draw at " + this.getX() + " " + this.getY() + " DIST TO HERO: " + distToHero);
			if (distToHero <= distToHeroInteraction) {
				// println("Mother: hero is in range");

				if (heroIsNear) {
					this.sing();
					// check if all children are there
					if (game_finished == false && hero.followers.size() == creature_count) {
						game_finished = true;
						this.beaten = true;
						println("Game finished!!!!!!!!!!!!!!!!!!!!!!!!!!!");
						// follow hero too!
						hero.addFollower(this);
						this.following = true;
						instrument_set = ["male","female","clarinet", "flute", "piccolo", "tenor_trombone", "tuba", "horn", "englishhorn"];
						// playInterval(); // this function is defined in index.html // TODO: readd
						ltxt_instruction.setPosition(this.layer.parent.viewbox.x+(this.layer.parent.viewbox.w/6), this.layer.parent.viewbox.y+(4*this.layer.parent.viewbox.h/6));
						ltxt_instruction.setText("Thank you");
						this.layer.setFadeOutAlpha(255);
					}
					if (game_finished == false) {
						hero.changeText("What do you want from me?");
						ltxt_instruction.setPosition(this.layer.parent.viewbox.x+(this.layer.parent.viewbox.w/6), this.layer.parent.viewbox.y+(4*this.layer.parent.viewbox.h/6));
						ltxt_instruction.setText("Bring me my children\nGain their trust...\nsing to them");
					}
					
				} else { // if it is false, turn it to true and initiate singing mode
					// println("Mother: hero is near!");
					this.heroIsNear = true;
				} 
				
			} else { // hero is too far away to interact
				hero.changeText("");
				if ( heroIsNear ) {
					// println("hero is not near anymore!");
					heroIsNear = false;
					rotateEnv.reset();
				} else {
				
				}
				
			
			}
		}
		
		if (this.beaten && this.following == true) {
			this.sing();
		}
	} else {
		// println("Mother: should not be drawn");
	}
	
	if (game_finished == true) {
		ltxt_instruction.setPosition(this.layer.parent.viewbox.x+(this.layer.parent.viewbox.w/6), this.layer.parent.viewbox.y+(4*this.layer.parent.viewbox.h/6));
	}
   }
  
  /**
   * Set up our states
   */
  void setStates() {
    // walking state
    // State walking = new State("idle", "graphics/creature-walking.gif", 1, 2);
    State walking = new State("idle", "graphics/creature.gif", 1, 1);

	
    walking.setAnimationSpeed(0.12);
    // SoundManager.load(walking, "audio/Squish.mp3");
    addState(walking);
	//  sState idle = new State("idle", "graphics/creature-walking.gif", 1, 2);
	State idle = new State("idle", "graphics/creature.gif", 1, 1);

    idle.setAnimationSpeed(0);
    addState(idle);
    
    setCurrentState("idle");
  }
}
