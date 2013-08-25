final int screenWidth = 512;
final int screenHeight = 432;

float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;

int lvl_width = 1000;
int lvl_height = 1000;
boolean challengeMode = false; 

void initialize() {
  addScreen("level", new HeroLevel(lvl_width, lvl_height));  
  println( "initialized");
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
    // addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky_2.gif"),0,0,width,height)); // TODO: remove , not needed in this game
  }
  void draw() {
    super.draw();
  }
}

// main layer
class HeroLayer extends LevelLayer {
  HeroLayer(Level owner) {
    super(owner);
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky.gif"),0,0,width,height));

    addBoundary(new Boundary(0,height-48,width,height-48));
    showBoundaries = true;
    hero = new Hero(width/2, height/2);
	hero.setPosition(10, 200);
    addPlayer(hero);
	Koopa koopa1 = new Koopa(64, height-64);
	Koopa koopa2 =  new Koopa(100, height-64);
	Koopa koopa3 =  new Koopa(120, height-64);
	Koopa koopa4 =  new Koopa(140, height-64);
	Koopa koopa5 =  new Koopa(160, height-64);
	Koopa koopa6 =  new Koopa(170, height-64);
	Koopa koopa7 =  new Koopa(180, height-64);
	Koopa koopa8 =  new Koopa(190, height-64);
	Koopa koopa9 =  new Koopa(200, 200);
	addInteractor(koopa1);
	addInteractor(koopa2);
	addInteractor(koopa3);
	addInteractor(koopa4);
	addInteractor(koopa5);
	addInteractor(koopa6);
	addInteractor(koopa7);
	addInteractor(koopa8);
	addInteractor(koopa9);
	
	/*
	hero.addFollower(koopa1);
	hero.addFollower(koopa2);
	hero.addFollower(koopa3);
	hero.addFollower(koopa4);
	hero.addFollower(koopa5);
	hero.addFollower(koopa6);
	hero.addFollower(koopa7);
	hero.addFollower(koopa8);
	hero.addFollower(koopa9);
	
	*/
	
	
	println( "added player hero");
	
	
	// add decorative foreground bushes
    addBushes();
	LevelText ltxt1 = new LevelText("Just a teeeeest", 20, height-64, "fonts/acmesa.ttf", 10);
	ltxt1.attach_to(hero);
	hero.changeText("changed text");
	addText(ltxt1);
	

  }
  
  
  // add some mario-style bushes
  void addBushes() {
    // one bush, composed of four segmetns (sprites 1, 3, 4 and 5)
    int[] bush = {
      1, 3, 4, 5
    };
    for (int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER, BOTTOM);
      sprite.setPosition(116 + xpos, height-48);
      addForegroundSprite(sprite);
    }

    // two bush, composed of eight segments
    bush = new int[] {
      1, 2, 4, 2, 3, 4, 2, 5
    };
    for (int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER, BOTTOM);
      sprite.setPosition(384 + xpos, height-48);
      addForegroundSprite(sprite);
    }

    // three bush
    bush = new int[] {
      1, 3, 4, 5
    };
    for (int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER, BOTTOM);
      sprite.setPosition(868 + xpos, height-48);
      addForegroundSprite(sprite);
    }

    // four bush
    bush = new int[] {
      1, 2, 4, 3, 4, 5
    };
    for (int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER, BOTTOM);
      sprite.setPosition(1344 + xpos, height-48);
      addForegroundSprite(sprite);
    }
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


  Hero(float x, float y) {
    super("Hero");
    setStates();
    setPosition(x,y);
    handleKey('W');
    handleKey('A');
    handleKey('D');
    handleKey('S');

    setImpulseCoefficients(DAMPENING,DAMPENING);
	this.followers = new ArrayList<Positionable>();
	println( "Hero initialized ");

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
	  if (new_distanceX < this.followDistance) { new_distanceX = this.followDistance };
	  if (new_distanceY < this.followDistance) { new_distanceY = this.followDistance };
	  float x = xin - cos(angle) * new_distanceX; // this.followDistance;
	  float y = yin - sin(angle) * new_distanceX; // this.followDistance;
	  p.setPosition(x,y);
	  // TODO: set the same movement state
	  p.setCurrentState("idle");

	  // TODO: they should be facing the right direction
	  
  }
  
  
  
  void addFollower(Koopa p) {
	p.setFollowing(true)
	this.followers.add(p);
	println("the hero has now " + this.followers.size() + " followers");
  }
  
  void setStates() {
    // idling state
    addState(new State("idle", "graphics/mario/small/Standing-mario.gif"));

    // running state
    addState(new State("running", "graphics/mario/small/Running-mario.gif", 1, 4));

    // dead state O_O
    State dead = new State("dead", "graphics/mario/small/Dead-mario.gif", 1, 2);
    dead.setAnimationSpeed(0.25);
    dead.setDuration(100);
    addState(dead);   
    // SoundManager.load(dead, "audio/Dead mario.mp3");
    
    // jumping state
    State jumping = new State("jumping", "graphics/mario/small/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);
    // SoundManager.load(jumping, "audio/Jump.mp3");

    // victorious state!
    State won = new State("won", "graphics/mario/small/Standing-mario.gif");
    won.setDuration(240);
    addState(won);

    // default: just stand around doing nothing
    setCurrentState("idle");
  }
  void handleInput() {
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
		dynsoundManager.play("harp", "40"); //+(the_chosen + octave + init_pentatone));
		setViewDirection(0, -1);
	}
	if (isKeyDown('S')) { 
		addImpulse(0,2); 
		dynsoundManager.play("harp", "40"); //+(the_chosen + octave + init_pentatone));
		setViewDirection(0, 1);
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
}
Hero hero;


class Koopa extends Interactor {
  float distToHero = 200000; // big default value
  boolean heroIsNear = false;
  final float distToHeroInteraction = 160; // sets distance for interaction, switches heroIsNear boolean
  final float distToHeroActivateChallenge = 80; // sets distance for interaction, switches heroIsNear boolean

  boolean following = false;
  boolean beaten = false; // if the hero successfully challenged the animal, this turns true

  Envelope rotateEnv;

  Koopa(float x, float y) {
    super("Koopa Trooper");
    setStates();
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setPosition(x,y);
	// TODO: this needs quite time, copy object template as solution?
	rotateEnv = new Envelope([0,0],[1],"repeat",0,"custom","Math.sin(y/15.75)*(Math.PI*2/30)");
	rotateEnv.start();
	
  }
  
  void setFollowing(boolean b) {
	following = true;
  
  }
   void update() {
	super.update();
	
	if (this.heroIsNear) {
		rotateEnv.update(0.03); // TODO: add real framerate
		this.r = rotateEnv.current_value;
		float alpha_value = (1 - (this.distToHero/distToHeroInteraction))*255*2;
		if (alpha_value > 255) alpha_value = 255; // just to be sure
		this.layer.setFadeOutAlpha(alpha_value);
	} else {
		if (this.r != 0) { // TODO: add a tolerance
			if (this.r > 0) {
				this.r = this.r - (Math.PI*2/360);
			} else {
				this.r = this.r + (Math.PI*2/360);
			}
		}
	}
	
   }
   
   void draw(vx, vy, vw, vh) {
    super.draw(vx, vy, vw, vh);
   	if (drawableFor(vx,vy,vw,vh)) {
		// check distance to hero. if he is near start making noises/whistle and go in state "listen" if hero does it right
		// println("hero is here: " + hero.getX());
		distToHero = dist(this.getX(), this.getY(), hero.getX(), hero.getY());
		if (distToHero <= distToHeroInteraction) {
			if (heroIsNear) {
				if (distToHero <= distToHeroActivateChallenge) {
					challengeMode = true; // activate challenge!
					hero.changeText("What?! I have to sing?!");
				}
				
			} else { // if it is false, turn it to true and initiate singing mode
				println("hero is near!");
				heroIsNear = true;
				
				// if the hero have successfully challenged the animal it should follow him
				if (this.beaten && this.following == false) {
					hero.addFollower(this);
					this.following = true;
				}
				
			}
		} else { // hero is too far away to interact
			hero.changeText("");
			if ( heroIsNear ) {
				println("hero is not near anymore!");
				heroIsNear = false;
				rotateEnv.reset();
			} else {
			
			}
		
		}
	}
   }
  
  /**
   * Set up our states
   */
  void setStates() {
    // walking state
    State walking = new State("idle", "graphics/enemies/Red-koopa-walking.gif", 1, 2);
    walking.setAnimationSpeed(0.12);
    // SoundManager.load(walking, "audio/Squish.mp3");
    addState(walking);
	State idle = new State("idle", "graphics/enemies/Red-koopa-walking.gif", 1, 2);
    idle.setAnimationSpeed(0);
    // SoundManager.load(idle, "audio/Squish.mp3");
    addState(idle);
    
    // if we get squished, we first get naked...
    State naked = new State("naked", "graphics/enemies/Naked-koopa-walking.gif", 1, 2);
    naked.setAnimationSpeed(0.12);
    // SoundManager.load(naked, "audio/Squish.mp3");
    addState(naked);
    
    setCurrentState("idle");
  }
}
