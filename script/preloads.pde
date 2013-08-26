/**
 * override!
 * this disables the default "loop()" when using addScreen
 */
void addScreen(String name, Screen screen) {
  screenSet.put(name, screen);
  if (activeScreen == null) { activeScreen = screen; }
  else { SoundManager.stop(activeScreen); }
}

/* @pjs pauseOnBlur="true";
        font="fonts/acmesa.ttf";
        preload=" graphics/floor.gif,
				  
                  graphics/creature.gif,
				  graphics/example_sphere.gif,

                  graphics/Running-hero.gif,
                  graphics/Standing-hero.gif"; */