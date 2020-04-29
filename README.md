# Jungle Jump - iOS single player game

The target of the game is to collect as many gems as possible using the jumper actions (jump/crouch) and having a number of lives.

The game consists of three diferent scenes:
- Intro Scene
- Game Scene
- Game Over/Highscore Scene

### The Intro Scene
- The intro scene is composed of two static nodes (ie. background node and label node) and two dynamic nodes with which the user can interact (ie. play button node and sound node)

<p align="center">
  <img width="400" src="/img/scene_1.PNG">
</p>

- Using the sound node button, the player can choose between two sound states: sound enabled/sound muted.
  - The **enabled state** enables all the sounds in the environment from the ambiental/background music to the sound effects. 
  - The **muted state** turns off the ambiental music and only the sounds effect are remaining active after choosing the muted state

- By pressing the sound node not only the sound state changes but the sound button texture also.

<p align="center">
  <img width="400" src="/img/scene_1.1.PNG">
</p>

- The play button is the one that makes the transition to the actual game.
  - The transition is made of two different effects, an fadeOut SKAction and a doorway SKTransition which is run after the completion of the fadeOut effect
  
### The Game Scene 

- The Game scene is the place where all the action happens. 

- It has two different modes:
  - Normal mode
    - The normal mode has 3 different levels and in each level the spawning time of the gems/bananas are adjusted regarding the difficulty
  <p align="center">
  <img width="400" src="/img/scene_2.PNG">
  </p>
  
  - Special mode
  <p align="center">
  <img width="400" src="/img/scene_2.1.PNG">
  </p>
  
  - The transition between these two modes is made as it follows:
    - Normal -> Special: when the player collects a special red gem a jumper effect followed by a fade effect on the background are the indicator of passing to the Special mode
    - Special -> Normal: when the time has passed the fade effect is triggered and the normal mode is applied again.
- The main character (the Jumper) is placed in the bottom left part of the scene. 
  - Firstly, the jumper has adnotated four different types of texture actions (using Atlas Textures):
    - Running
    - Got hit
    - Jump
    - Crouch 
    - *Also, the ground has adnotated a texture action which gives enables the motion effect of the scene*
  - The jumper can collect gems which increase the player score by a number (depending on the gem type).
  - Also, when a banana hit the jumper, a splash texture and sound are triggered and the player lose a life.
  - Depending on the place of the touch (left side/right side of the screen) and the type of touch (single-tap/double-tap) the type of jumper action is choosen (left side - crouch/right side - jump) and the max heighth of the jump is adjusted (single-tap middle-air jump/double-tap high-air jump)

<p align="center">
  <img width="400" src="/img/scene_2.2.PNG">
</p>

- The score/lives/timer labels are located in the top left side of the scene.
  - The lives label has a scale animation when the player lose a life
  
- The enemy is located in the left part of the scene. His actions are as it follows:
  - The enemy changes its position in the y axis
  - The enemy throws a banana it the direction of the jumper
    - When the enemy throws the banana the banana has a translation movement accompanied by a rotation movement which gives dynamics to the scene
    - Also, the enemy has a throwing error margin, big error -> low accuracy and higher chances for the player

- In the top side of the scene there are the rewards which are attached to the vines. 
  - The rewards are of three types: common type, special red type, special green type
  - The common type and special red type can be found in the normal game mode (the special red type has a probability of 1/x to appear in the scene) and the special green type can only be found in the special game mode
  <p align="center">
    <img width="400" src="/img/scene_2.4.png">
  </p>
  - The vines are drawn dynamically regarding to the reward position.

<p align="center">
  <img width="400" src="/img/scene_2.5.png">
</p>

### The Game Over Scene
- The game over scene appears when the player has 0 lives left.
- In the game over scene, the player has information about his final score and the highest score (which is stored in non-volatile memory)
- The user can interact with the sound button to toggle the music-sound on/off and he can choose to restart the game
- The game restart will trigger a fade transition to the game scene where the player can play a new game

<p align="center">
  <img width="400" src="/img/scene_3.PNG">
</p>
