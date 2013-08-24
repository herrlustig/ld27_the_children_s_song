final int screenWidth = 512;
final int screenHeight = 432;

float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;

int lvl_width = 1000;
int lvl_height = 1000;


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
    addLevelLayer("layer", new HeroLayer(this));
	setViewBox(0,0,screenWidth,screenHeight);
	
	
  }
  
  
  
}

class HeroLayer extends LevelLayer {
  Hero hero;
  HeroLayer(Level owner) {
    super(owner);
    setBackgroundColor(color(0, 100, 190));
    addBoundary(new Boundary(0,height-48,width,height-48));
    showBoundaries = true;
    hero = new Hero(width/2, height/2);
	hero.setPosition(32, height-64);
    addPlayer(hero);
	println( "added player hero");
	
	
	// add decorative foreground bushes
    addBushes();
	LevelText ltxt1 = new LevelText("Just a teeeeest", 32, height-64, "fonts/acmesa.ttf", 20);
	ltxt1.attach_to(hero);
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

  Hero(float x, float y) {
    super("Hero");
    setStates();
    setPosition(x,y);
    handleKey('W');
    handleKey('A');
    handleKey('D');
    handleKey('S');

    // setForces(0, 0);
    // setAcceleration(0,0);
    setImpulseCoefficients(DAMPENING,DAMPENING);
	println( "Hero initialized ");

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