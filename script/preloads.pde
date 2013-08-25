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
        preload=" graphics/backgrounds/bush-01.gif,
                  graphics/backgrounds/bush-02.gif,
                  graphics/backgrounds/bush-03.gif,
                  graphics/backgrounds/bush-04.gif,
                  graphics/backgrounds/bush-05.gif,

                  graphics/backgrounds/sky.gif,
                  graphics/backgrounds/sky_2.gif,
				  
                  graphics/enemies/Red-koopa-walking.gif,

                  graphics/mario/small/Running-mario.gif,
                  graphics/mario/small/Standing-mario.gif"; */