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
        preload=" graphics/bush-01.gif,
                  graphics/bush-02.gif,
                  graphics/bush-03.gif,
                  graphics/bush-04.gif,
                  graphics/bush-05.gif,

                  graphics/floor.gif,
				  
                  graphics/creature.gif,
				  graphics/example_sphere.gif,

                  graphics/Running-hero.gif,
                  graphics/Standing-hero.gif"; */