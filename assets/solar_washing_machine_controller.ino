#include <IRremote.h>


int motorPin1 = 4;
int motorPin2 = 5;
int motorPin3 = 6;
int motorPin4 = 7;
int inletValve = 8;
int drainPump = 9;
int startButton = 10;
int waterLevelSensor = A5;
int infraredPin = 3;


unsigned long infraredKey0 = 0xF30CBF00;
unsigned long infraredKey1 = 0xEF10BF00;
unsigned long infraredKey2 = 0xEE11BF00;
unsigned long infraredKey3 = 0xED12BF00;

int lowPower = 1;
int mediumPower = 2;
int highPower = 3;


int emptyWaterLevel = 10;
int fullWaterLevel = 80;


int powerLevel = 0;
bool machineRunning = false;
unsigned long lastButtonPress = 0;


void stopMotorRotation() {
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, LOW);
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, LOW);
}


void binaryStep(bool clockwise, int delayTime) {
  static int stepIndex = 0;

  int steps[8][4] = {
    {1, 0, 0, 0},
    {1, 1, 0, 0},
    {0, 1, 0, 0},
    {0, 1, 1, 0},
    {0, 0, 1, 0},
    {0, 0, 1, 1},
    {0, 0, 0, 1},
    {1, 0, 0, 1}
  };

  if (clockwise)
    stepIndex = (stepIndex + 1) % 8;
  else
    stepIndex = (stepIndex + 7) % 8;

  digitalWrite(motorPin1, steps[stepIndex][0]);
  digitalWrite(motorPin2, steps[stepIndex][1]);
  digitalWrite(motorPin3, steps[stepIndex][2]);
  digitalWrite(motorPin4, steps[stepIndex][3]);

  delay(delayTime);
}

void rotateClockwise(int timeDelay) {
  for (int i = 0; i < 8; i++) binaryStep(true, timeDelay);
}

void rotateCounterClockwise(int timeDelay) {
  for (int i = 0; i < 8; i++) binaryStep(false, timeDelay);
}


int readWaterLevel() {
  int sensorValue = analogRead(waterLevelSensor);
  return (int)((sensorValue / 1023.0) * 100);
}

void readIRSensor() {
  if (IrReceiver.decode()) {
    unsigned long code = IrReceiver.decodedIRData.decodedRawData;
    if (code == infraredKey0) powerLevel = 0;
    else if (code == infraredKey1) powerLevel = 1;
    else if (code == infraredKey2) powerLevel = 2;
    else if (code == infraredKey3) powerLevel = 3;
    IrReceiver.resume();
  }
}

bool checkPower(int requiredPowerLevel, int pinNum) {
  bool messageShown = false;
  while (powerLevel < requiredPowerLevel) {
    readIRSensor();
    if (!messageShown) {
      Serial.print("Machine requires Power Level ");
      Serial.println(requiredPowerLevel);
      messageShown = true;
    }
    delay(300);
  }
  Serial.println("Power level is sufficient.\n");
  return true;
}


void fillDrum() {
  checkPower(lowPower, infraredPin);
  Serial.println("Filling drum with water...");
  digitalWrite(inletValve, HIGH);

  int currentLevel = readWaterLevel();
  while (currentLevel < fullWaterLevel) {
    currentLevel = readWaterLevel();
    Serial.print("Water Level: ");
    Serial.print(currentLevel);
    Serial.println("%");
    delay(400);
  }

  digitalWrite(inletValve, LOW);
  Serial.println("Drum filled to 80%.\n");
}

void wash_rinse(String phaseName) {
  checkPower(mediumPower, infraredPin);
  Serial.print(phaseName);
  Serial.println(" cycle started...");
  
  int rotationDelay = 350; 

  
  for (int i = 0; i < 3 * 8; i++) binaryStep(true, rotationDelay);
  stopMotorRotation();
  delay(350);

  for (int i = 0; i < 3 * 8; i++) binaryStep(false, rotationDelay);
  stopMotorRotation();
  delay(350);

  Serial.print(phaseName);
  Serial.println(" cycle completed.\n");
}

void draining() {
  checkPower(lowPower, infraredPin);
  Serial.println("Draining water from drum...");
  digitalWrite(drainPump, HIGH);

  int currentLevel = readWaterLevel();
  while (currentLevel > emptyWaterLevel) {
    currentLevel = readWaterLevel();
    Serial.print("Current Level: ");
    Serial.print(currentLevel);
    Serial.println("%");
    delay(400);
  }

  digitalWrite(drainPump, LOW);
  Serial.println("Drum drained below 10%.\n");
}

void spinning() {
  checkPower(highPower, infraredPin);
  Serial.println("Spinning clothes... removing excess water.");

  digitalWrite(drainPump, HIGH);
  int spinDelay = 200;

  // 20 full clockwise rotations
  for (int i = 0; i < 20 * 8; i++) binaryStep(true, spinDelay);

  digitalWrite(drainPump, LOW);
  stopMotorRotation();
  Serial.println("Spin cycle completed.\n");
}


void setup() {
  Serial.begin(9600);
  pinMode(motorPin1, OUTPUT);
  pinMode(motorPin2, OUTPUT);
  pinMode(motorPin3, OUTPUT);
  pinMode(motorPin4, OUTPUT);
  pinMode(inletValve, OUTPUT);
  pinMode(drainPump, OUTPUT);
  pinMode(startButton, INPUT);
  stopMotorRotation();
  IrReceiver.begin(infraredPin, ENABLE_LED_FEEDBACK);

  Serial.println("Machine charging... Power Level 0 (Press 1, 2, or 3 on remote).");
}

void loop() {
  readIRSensor();

  if (powerLevel == 0) {
    static bool messageShown = false;
    if (!messageShown) {
      Serial.println("Power Level 0: Please increase power to start (Press 1 – 3 on remote).");
      messageShown = true;
    }
    delay(500);
    return;
  }

  static bool readyMessageShown = false;
  if (!readyMessageShown && powerLevel >= 1) {
    Serial.println("Power available. Press START button to begin washing cycle.");
    readyMessageShown = true;
  }

  if (!machineRunning && digitalRead(startButton) == HIGH && millis() - lastButtonPress > 500) {
    lastButtonPress = millis();
    machineRunning = true;

    Serial.println("\n--- Washing Machine Cycle Started ---");

    // Follow full washing process
    Serial.println("Filling drum before washing...");
    fillDrum();

    Serial.println("Washing clothes...");
    wash_rinse("Washing");

    Serial.println("Draining dirty water...");
    draining();

    Serial.println("Filling drum before rinsing...");
    fillDrum();

    Serial.println("Rinsing clothes...");
    wash_rinse("Rinsing");

    Serial.println("Final draining...");
    draining();

    Serial.println("Final spinning...");
    spinning();

    Serial.println("--- Cycle Completed. Machine Ready. ---\n");
    machineRunning = false;
  }
}
