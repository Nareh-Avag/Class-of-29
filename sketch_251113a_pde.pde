// 
// Girls Go Gamers Presents: Class of '29
// By: Isra Alam, Nareh Avagyan, Franchesca Badrina, Deyiani Christopher-Baker, Alyssa Silmon
// Description: A Persona-5 inspired visual novel about the first-year experience at UMBC,
// however there's a sneaky twist! The popular app, Fizz, 
// has caused a lot of discussion around campus- and all of it isn't good!
// Monsters have formed from the harsh words and stress of your peers, 
//defeat them in between your student life to put an end to the academic madness!
// IMAGES 
PImage introScreenImage;
PImage secondScreenImage;
PImage pickMajorScreenImage;
PImage bioScreenImage;
PImage csScreenImage;
PImage financeScreenImage;
PImage infoSysScreenImage;
PImage mechEngScreenImage;
PImage psychScreenImage;
PImage blankbackgroundImage;
PImage umbcbackgroundImage;
PImage characterposterImage;
PImage FPLAYER1Image;
PImage NPLAYER2Image;
PImage MPLAYER3Image;
PImage activePlayerImage; // the selected player image
PImage[] monsterImages;

// AUDIO
import processing.sound.*;
SoundFile lastSurpriseAudio; // Creates sound object to store soundtrack audio file in
SoundFile massDestructionAudio; // battle music sound object
SoundFile fizzRingAudio; //ringtone warning audio

// SCREEN CONTROL
String currentScreen = "intro";
String selectedPlayer = "";

// BUTTONS 
int[] buttonX;
int[] buttonY;
int[] buttonWidth;
int[] buttonHeight;
String[] buttonAction;

// PLAYER MAJOR 
String major[] = {"Computer Science", "Biology", "Mechanical Engineering", "Psychology", "Information Systems", "Finance"};
String playerMajor = major[0];

// STATS 
int intSmarts = 80;
int intMentalHealth = 70;
int intStink = 20;
int intLockedIn = 50;

final int MAX_METER = 100;
final int BAR_WIDTH = 170;
final int BAR_HEIGHT = 13;

final int BAR_START_X = 30;
final int BAR_START_Y = 10;
final int BAR_SPACING = 35;

//TIME PROGRESSION
int currentDay = 1;
int numDaysPast = 0;

String[] timesOfDay = {"Morning", "Afternoon", "Evening"};
int currentTimeIndex = 0; 
int numActionsMade = 0;

// QUESTIONS 
String[] questions = {
  "What will you do this morning?",
  "How will you spend your afternoon?",
  "Your plans for the evening?"
};

String[][] choices = {
  {"We're supposed to do that here?", "Hang out with friends"},
  {"Go to class", "Take a nap"},
  {"Sleep early", "Binge Netflix"}
};

// Stat effects for each choice: {Smarts, Mental Health, Hygiene, LockedIn}
int[][][] statEffects = {
  { {10, 0, 0, 10}, {-5, 5, 0, -5} },     
  { {5, -5, 0, 0}, {0, 10, -5, -10} },     
  { {0, 5, 0, 5}, {-5, 0, 0, -15} }     
};

// Track current question
int currentQuestionIndex = 0;

// CHARACTER (fixed bottom-right)
float characterDisplayW = 350;
float characterDisplayH = 420;

// MONSTERS APPEARING!!!! Incoming Monsters!!!!
int startTime;
int yPressCount = 0;
int lastMonsterTime = 0;  // when the last monster appeared
boolean showSecondScreen = false;
boolean screen2Activated = false; // battle image triggers only once
boolean battleTriggered = false; //battle start!
int waitTime = 120000; // after 2 minutes have passed (in milliseconds)
boolean fizzPlayed = false;
boolean fizzPlayedThisBattle = false; // tracks fizz warning for the monster
int fizzTime = 110000; // 1 minute 50 seconds in milliseconds


// SETUP
void setup() {
  size(1080, 720);
  frameRate(60);
  startTime = millis(); // keep track of the starting time!!

  // Load audios & media for monster battles
  monsterImages = new PImage[] {
    loadImage("blackboabattle.png"),
    loadImage("ticktocktabby.png"),
  };
  // (gets replaced when battle starts)
  secondScreenImage = monsterImages[0];
  massDestructionAudio = new SoundFile(this, "massDestructionAudio.mp3");
  fizzRingAudio = new SoundFile(this, "fizzRingAudio.mp3");
  lastSurpriseAudio = new SoundFile(this, "lastSurpriseAudio.mp3");
  lastSurpriseAudio.loop();

  // load screens (filenames must exist in data folder)
  introScreenImage = loadImage("introscreen.png");
  pickMajorScreenImage = loadImage("pickmajorscreen.png");
  bioScreenImage = loadImage("biologyscreen.png");
  csScreenImage = loadImage("compsciscreen.png");
  infoSysScreenImage = loadImage("infosysscreen.png");
  mechEngScreenImage = loadImage("mechengscreen.png");
  psychScreenImage = loadImage("psychscreen.png");
  financeScreenImage = loadImage("financescreen.png");
  blankbackgroundImage = loadImage("blankbackground.png");
  umbcbackgroundImage = loadImage("umbcbackground.jpg");
  characterposterImage = loadImage("characterposter.png");

  // load your player PNGs
  FPLAYER1Image = loadImage("FPLAYER1.png");
  NPLAYER2Image = loadImage("NPLAYER2.png");
  MPLAYER3Image = loadImage("MPLAYER3.png");

  // initialize buttons for intro
  setupButtons();
}


// DRAW
void draw() {
  background(255);

  // --------- SCREENS ---------
  if (currentScreen.equals("intro")) {
    image(introScreenImage, 0, 0);
  }
  else if (currentScreen.equals("pickMajor")) {
    image(pickMajorScreenImage, 0, 0);
  }
  else if (currentScreen.equals("pickPlayer")) {
    // Scale player-select poster to fit the full screen
    image(characterposterImage, 0, 0, width, height);
  }
  else if (currentScreen.equals("Computer Science")) {
    image(csScreenImage, 0, 0);
    playerMajor = major[0];
  }
  else if (currentScreen.equals("Biology")) {
    image(bioScreenImage, 0, 0);
    playerMajor = major[1];
  }
  else if (currentScreen.equals("Mechanical Engineering")) {
    image(mechEngScreenImage, 0, 0);
    playerMajor = major[2];
  }
  else if (currentScreen.equals("Psychology")) {
    image(psychScreenImage, 0, 0);
    playerMajor = major[3];
  }
  else if (currentScreen.equals("Information Systems")) {
    image(infoSysScreenImage, 0, 0);
    playerMajor = major[4];
  }
  else if (currentScreen.equals("Finance")) {
    image(financeScreenImage, 0, 0);
    playerMajor = major[5];
  }
  else if (currentScreen.equals("gameStart")) {
    image(umbcbackgroundImage, 0, 0);
    drawBars();
    drawTimeTracker();

    // Draw selected player FIRST — behind buttons
    if (activePlayerImage != null) {
      float x = width - characterDisplayW - 5;  
      float y = height - characterDisplayH - 10; 
      imageMode(CORNER);
      image(activePlayerImage, x, y, characterDisplayW, characterDisplayH);
      imageMode(CORNER); // ensure mode stays predictable
    }

    // Draw current question
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(28);
    text(questions[currentQuestionIndex], width/2, 200); // Top center

    // Draw visible buttons with choice text (if buttons exist)
    if (buttonX != null) {
      for (int i = 0; i < buttonX.length; i++) {
        stroke(255);
        fill(100, 150, 255); 
        rect(buttonX[i], buttonY[i], buttonWidth[i], buttonHeight[i], 10);

        fill(255);
        textAlign(CENTER, CENTER);
        textSize(20);
        // ensure we have choices for the current question
        if (i < choices[currentQuestionIndex].length) {
          text(choices[currentQuestionIndex][i], buttonX[i] + buttonWidth[i]/2, buttonY[i] + buttonHeight[i]/2);
        }
      }
    }
  }

  // Draw invisible hitboxes for mouse detection (still required)
  if (buttonX != null) {
    for (int i = 0; i < buttonX.length; i++) {
      noStroke();
      fill(0, 0, 0, 0);
      rect(buttonX[i], buttonY[i], buttonWidth[i], buttonHeight[i]);
    }
  }

  // MONSTER AND FIZZ STUFF
  int timeSinceLastMonster = millis() - lastMonsterTime;

  // FIZZ WARNING (10 seconds before monster)
  if (!fizzPlayedThisBattle && timeSinceLastMonster >= waitTime - 10000) {
    fizzPlayedThisBattle = true; // mark fizz as played for this battle
    println("fizz monster incoming!");

    if (!fizzRingAudio.isPlaying()) {
      fizzRingAudio.play();
    }
  }

  // MONSTER SCREEN (repeats every 2 minutes)
  if (timeSinceLastMonster >= waitTime) {
    // reset for new monster battle
    yPressCount = 0; //y counter
    showSecondScreen = true; //show screen
    screen2Activated = false;
    fizzPlayedThisBattle = false; // reset fizz for next monster

    // picks a random monster
    int r = int(random(monsterImages.length));
    secondScreenImage = monsterImages[r];

    // remember when this monster appeared
    lastMonsterTime = millis();
  }

  // MONSTER SCREEN
  if (showSecondScreen) {
    if (yPressCount < 29) { ///  y hasnt been pressed 29 times
      if (!screen2Activated) { /// and second screen isnt on (monster)
        screen2Activated = true; // turn on monster!

        if (lastSurpriseAudio.isPlaying()) { ///if the normal music is playing stop
          lastSurpriseAudio.stop();
        }

        if (!massDestructionAudio.isPlaying()) { // play battle music
          massDestructionAudio.play();
        }
      }
      image(secondScreenImage, 0, 0, width, height);
    }
  }
}


// KEY PRESSED (for monster battles)
void keyPressed() {
  if (key == 'y' || key == 'Y') {
    yPressCount++;   // counts how many times Y has been pressed
    println("Y pressed " + yPressCount + " times");

    if (yPressCount >= 29) {
      println("29 presses reached, monster defeated!");
      showSecondScreen = false;
      screen2Activated = false;

      // stops monster music
      if (massDestructionAudio.isPlaying()) {
        massDestructionAudio.stop();
      }

      // starts main music
      if (!lastSurpriseAudio.isPlaying()) {
        lastSurpriseAudio.loop();
      }

      // if Y is pressed more than 29 times, mental health gets hit!
      if (yPressCount > 29) {
        intMentalHealth -= 15;
        intMentalHealth = constrain(intMentalHealth, 0, MAX_METER);
        println("oops thats more than 29! that battle with the fizz monster must've stressed you out a ton, your mental health went down to...." + intMentalHealth);
      }
    }
  }
}


// BUTTONS (definition exists here)
void setupButtons() {
  // Intro screen buttons
  if (currentScreen.equals("intro")) {
    buttonX = new int[]{200, 365};
    buttonY = new int[]{430, 550};
    buttonWidth = new int[]{685, 350};
    buttonHeight = new int[]{65, 65};
    buttonAction = new String[]{"pickMajor", "exit"};
  }
  // Pick Major screen buttons
  else if (currentScreen.equals("pickMajor")) {
    buttonX = new int[]{50, 50, 50, 655, 725, 785};
    buttonY = new int[]{225, 425, 560, 260, 390, 600};
    buttonWidth = new int[]{315, 230, 325, 365, 290, 235};
    buttonHeight = new int[]{110, 40, 110, 45, 105, 40};
    buttonAction = major;
  }
  // When viewing an individual major, show a continue button to player pick
  else if (
    currentScreen.equals("Computer Science") ||
    currentScreen.equals("Biology") ||
    currentScreen.equals("Mechanical Engineering") ||
    currentScreen.equals("Psychology") ||
    currentScreen.equals("Information Systems") ||
    currentScreen.equals("Finance")
  ) {
    buttonX = new int[]{745};
    buttonY = new int[]{600};
    buttonWidth = new int[]{255};
    buttonHeight = new int[]{50};
    buttonAction = new String[]{"goToPlayerSelect"};
  }
  // Pick Player screen: three hitboxes (left, center, right)
  else if (currentScreen.equals("pickPlayer")) {
    buttonX = new int[]{120, 440, 760};
    buttonY = new int[]{180, 170, 200};
    buttonWidth = new int[]{250, 250, 250};
    buttonHeight = new int[]{430, 430, 430};

    buttonAction = new String[]{
      "pickP1",
      "pickP2",
      "pickP3"
    };
  }
  // Game start: show the choice buttons (two choices for the question)
  else if (currentScreen.equals("gameStart")) {
    buttonX = new int[]{150, 490};
    buttonY = new int[]{580, 580};
    buttonWidth = new int[]{300, 300};
    buttonHeight = new int[]{75, 75};
    buttonAction = new String[]{"choiceOne", "choiceTwo"};
  }
  // fallback - no buttons
  else {
    buttonX = new int[]{};
    buttonY = new int[]{};
    buttonWidth = new int[]{};
    buttonHeight = new int[]{};
    buttonAction = new String[]{};
  }
}

// MOUSE
void mousePressed() {
  if (buttonX == null) return;
  for (int i = 0; i < buttonX.length; i++) {
    if (mouseX > buttonX[i] && mouseX < buttonX[i] + buttonWidth[i] &&
        mouseY > buttonY[i] && mouseY < buttonY[i] + buttonHeight[i]) {
      handleButtonAction(buttonAction[i]);
      break;
    }
  }
}


// HANDLE BUTTON ACTIONS
void handleButtonAction(String action) {

  // Intro -> go to major
  if (action.equals("pickMajor") || action.equals("goToMajor")) {
    currentScreen = "pickMajor";
    setupButtons();
    return;
  }

  // exit
  if (action.equals("exit")) {
    exit();
    return;
  }

  // When clicking on a major tile (string in major[]) -> go to that major screen
  for (int i = 0; i < major.length; i++) {
    if (action.equals(major[i])) {
      currentScreen = major[i];
      setupButtons();
      return;
    }
  }

  // From major details -> go to player select
  if (action.equals("goToPlayerSelect")) {
    currentScreen = "pickPlayer";
    setupButtons();
    return;
  }

  // Player selection actions
  if (action.equals("pickP1")) {
    selectedPlayer = "P1";
    activePlayerImage = FPLAYER1Image;
    currentScreen = "gameStart";
    setupButtons();
    return;
    }
  if (action.equals("pickP2")) {
    selectedPlayer = "P2";
    activePlayerImage = NPLAYER2Image;
    currentScreen = "gameStart";
    setupButtons();
    return;
  }
  if (action.equals("pickP3")) {
    selectedPlayer = "P3";
    activePlayerImage = MPLAYER3Image;
    currentScreen = "gameStart";
    setupButtons();
    return;
  }

  // Gameplay choices
  if (action.equals("choiceOne") || action.equals("choiceTwo")) {
    int choiceIndex = action.equals("choiceOne") ? 0 : 1;

    // Apply stat effects
    intSmarts += statEffects[currentQuestionIndex][choiceIndex][0];
    intMentalHealth += statEffects[currentQuestionIndex][choiceIndex][1];
    intStink += statEffects[currentQuestionIndex][choiceIndex][2];
    intLockedIn += statEffects[currentQuestionIndex][choiceIndex][3];
  
    // Constrain stats
    intSmarts = constrain(intSmarts, 0, MAX_METER);
    intMentalHealth = constrain(intMentalHealth, 0, MAX_METER);
    intStink = constrain(intStink, 0, MAX_METER);
    intLockedIn = constrain(intLockedIn, 0, MAX_METER);

    // Move to next question
    currentQuestionIndex++;

    // Time progression after choice
    currentTimeIndex++;  // Move to next time of day
    if (currentTimeIndex >= timesOfDay.length) {
      currentTimeIndex = 0;        // Reset to Morning
      currentDay++;                // Increment day
      numDaysPast++;
      currentQuestionIndex = 0;    // Reset question index for the new day
    }

    // Wrap question index if it goes beyond current day questions
    if (currentQuestionIndex >= questions.length) {
      currentQuestionIndex = questions.length - 1;  // Stay on last question for that time
    }

    // Re-setup buttons because questions/choices may change UI
    setupButtons();
    return;
  }

  // Default: treat action as a screen name
  currentScreen = action;
  setupButtons();
}


// STAT BARS
void drawBars() {
  fill(0, 0, 0, 150); // Background panel
  stroke(255);
  rect(BAR_START_X - 20, BAR_START_Y - 20, BAR_WIDTH + 200, (BAR_SPACING * 4) + 40, 15);

  drawSingleBar(BAR_START_X, BAR_START_Y, intSmarts, "Smarts", color(100,150,255));
  drawSingleBar(BAR_START_X, BAR_START_Y + BAR_SPACING, intMentalHealth, "Mental Health", color(100,255,100));
  drawSingleBar(BAR_START_X, BAR_START_Y + BAR_SPACING*2, MAX_METER - intStink, "Hygiene", color(150,200,255));
  drawSingleBar(BAR_START_X, BAR_START_Y + BAR_SPACING*3, intLockedIn, "Locked In", color(255,200,50));
}

void drawSingleBar(int x, int y, int value, String label, color c) {
  int v = constrain(value, 0, MAX_METER);
  textSize(16);
  textAlign(LEFT, CENTER);
  fill(255);
  float labelWidth = textWidth(label) + 10;
  int barX = x + int(labelWidth);
  int barWidth = BAR_WIDTH;
  int barHeight = BAR_HEIGHT;
  float fillWidth = (float)v / MAX_METER * barWidth;

  text(label, x, y + barHeight / 2);

  noStroke();
  fill(50);
  rect(barX, y, barWidth, barHeight, 3);

  fill(c);
  rect(barX, y, fillWidth, barHeight, 3);

  noFill();
  stroke(255);
  rect(barX, y, barWidth, barHeight, 3);

  textAlign(LEFT, CENTER);
  text(v, barX + barWidth + 10, y + barHeight / 2);
}


// TIME
void timeProgression() {
  currentTimeIndex++;  // Move to next time
  if (currentTimeIndex >= timesOfDay.length) {
    currentTimeIndex = 0;  // Back to morning
    currentDay++;          // Next day
    numDaysPast++;
    currentQuestionIndex = 0; // Reset question for new day
  }
}

String getCurrentTimeOfDay() {
  return timesOfDay[currentTimeIndex];
}

void drawTimeTracker() {
  int panelWidth = 150;
  int panelHeight = 50;
  int padding = 10;

  fill(0, 0, 0, 150);
  stroke(255);
  rect(width - panelWidth - padding, padding, panelWidth, panelHeight, 10);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Day: " + currentDay, width - panelWidth, padding + 5);
  text("Time: " + getCurrentTimeOfDay(), width - panelWidth, padding + 25);
}
