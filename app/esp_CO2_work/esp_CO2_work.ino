//https://github.com/pnovot007/air-monitor-thc-v1.git

bool deb= false;  //enable serial output and debug to OLED

//I2C
#include <Wire.h>
byte error;

//OLED https://github.com/squix78/esp8266-oled-ssd1306.git
#include <SSD1306.h>
const byte oled = 0x3c;
SSD1306 display(oled, D1, D2);

//LED WS2812B https://github.com/adafruit/Adafruit_NeoPixel
#include <Adafruit_NeoPixel.h>
#define PIN       D8
#define NUMPIXELS 4
Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
int color_level;

//piezo buzzer
#define piezo_A D4
#define piezo_B D5

// APDS9930 proximity & ambient light https://github.com/Depau/APDS9930.git
#include <APDS9930.h>
APDS9930 apds= APDS9930();
uint16_t proximity_data= 0;
float ambient_light= 0; // can also be an unsigned long
long hold_time= 0;
int hand_min= 800;
int hand_free= 550;

//CO2 SDC30 https://github.com/sparkfun/SparkFun_SCD30_Arduino_Library.git
#include "SparkFun_SCD30_Arduino_Library.h" 
SCD30 airSensor;
String CO2, temp, hum;

void setup() {
  //I2C
  Wire.begin(D1, D2);
  Serial.begin(115200);

  //OLED
  Wire.beginTransmission(oled);
  error= Wire.endTransmission();
  if(error == 0){
    Serial.print("ok OLED [");
    Serial.print(oled, HEX);
    Serial.println("]\n");
  } else Serial.println("OLED not found!\n");
  display.init();
  display.setContrast(255, 255, 1);
  delay(200);

  //LED
  pixels.begin();

  //APDS9930
  if ( apds.init() )
    if(deb) Serial.println("APDS-9930 initialization complete");
  else
    if(deb) Serial.println("Something went wrong during APDS-9930 init!");
  // APDS-9930 ambient light
  if ( apds.enableLightSensor(false) )
    if(deb) Serial.println("Light sensor is now running");
  else
    if(deb) Serial.println("Something went wrong during light sensor init!");

  // Start running the APDS-9930 proximity sensor (no interrupts)
  if ( apds.enableProximitySensor(false) ){
    if(deb) Serial.println("Proximity sensor is now running");
    // Adjust the Proximity sensor gain
    if ( !apds.setProximityGain(PGAIN_2X) )
      if(deb) Serial.println("Something went wrong trying to set PGAIN"); 
  }
  else
    if(deb) Serial.println("Something went wrong during sensor init!");
  //apds.setLEDDrive(LED_DRIVE_100MA);
  //apds.setLEDDrive(LED_DRIVE_50MA);
  apds.setLEDDrive(LED_DRIVE_25MA);
  //apds.setLEDDrive(LED_DRIVE_12_5MA);

  //CO2 SDC30
  airSensor.begin(); //This will cause readings to occur every two seconds
}

void loop() {
  //CO2 SDC30
  if (airSensor.dataAvailable()){
    CO2=  (String)airSensor.getCO2();
    temp= (String)airSensor.getTemperature();
    hum=  (String)airSensor.getHumidity();
  }

  // Read the proximity value
  if ( apds.readProximity(proximity_data) ){
    if(deb) Serial.print("proximity: " + (String)proximity_data);
    color_level= (proximity_data - (hand_min - hand_free)) / 2.5;
  } else
    if(deb) Serial.println("Error reading proximity value");

  // Read the light levels (ambient, red, green, blue)
  if ( apds.readAmbientLightLux(ambient_light) )
    if(deb) Serial.println("\tambient: " + (String)ambient_light);
  else
    if(deb) Serial.println("Error reading light values");

  //LED
  if (proximity_data < hand_free){
    hold_time= 0;
    led(0,30,0);
  }
  else if (proximity_data > hand_min){
    if (hold_time==0) hold_time= millis();
    led(255,0,0);
  }
  else {
    hold_time= 0;
    led(color_level - 1, 256 - color_level, 0);
  }

  if (proximity_data > hand_min && hold_time != 0 && millis() - hold_time > 1000 && millis() - hold_time < 2999)
    beeper();
  else if (proximity_data > hand_min && hold_time != 0 && millis() - hold_time > 3000)
    led(255,255,255);

  oled_show();
  //Serial.println((String)(millis() - hold_time) + "\t" + (String)hold_time + "\t" + (String)proximity_data);
  delay(100);
}

void led(uint8_t r, uint8_t g, uint8_t b){
  pixels.clear();
  pixels.setPixelColor(1, pixels.Color(r, g, b));
  pixels.setPixelColor(2, pixels.Color(r, g, b));
  pixels.show();
}

void oled_show(){
  display.clear();
  display.invertDisplay();
  display.flipScreenVertically();
  display.setFont(ArialMT_Plain_16);
  display.drawString(0, 0, "CO   :");
  display.drawString(24, 6, "2");
  display.drawString(0, 24, "t :");
  display.drawString(0, 48, "Rh :");
  display.drawString(50, 0, CO2 + " ppm");
  display.drawString(50, 24, temp + " °C");
  display.drawString(50, 48, hum + " %");

  display.setFont(ArialMT_Plain_10);
  display.drawString(15, 22, (String)proximity_data);
  display.drawString(15, 32, (String)ambient_light);

  display.setFont(ArialMT_Plain_24);
  if(hold_time > 0) display.drawString( 100, 40, (String)((millis()-hold_time)/1000) );
  display.display();
}

void SetRandomSeed(){
  // random works best with a seed that can use 31 bits
  // analogRead on a unconnected pin tends toward less than four bits
  uint32_t seed= analogRead(0);
  delay(1);
  for (int shifts = 3; shifts < 31; shifts += 3) {
      seed ^= analogRead(0) << shifts;
      delay(1);
  }
  // Serial.println(seed);
  randomSeed(seed);
}

void beeper(){
    pinMode(piezo_A, OUTPUT);
    pinMode(piezo_B, OUTPUT);

    for (int beeps = 0; beeps < 10; beeps += 1) {
    digitalWrite(piezo_A, LOW);
    digitalWrite(piezo_B, HIGH);
    delay(1);
    digitalWrite(piezo_A, HIGH);
    digitalWrite(piezo_B, LOW);
    delay(1);
    }
    pinMode(piezo_A, INPUT);
    pinMode(piezo_B, INPUT);
}
