//https://github.com/pnovot007/air-monitor-thc-v1.git

bool deb= false;

//I2C
#include <Wire.h>
byte error;

//OLED https://github.com/squix78/esp8266-oled-ssd1306.git
#include <SSD1306.h>
const byte oled = 0x3c;
SSD1306 display(oled, D1, D2);

//LED https://github.com/Makuna/NeoPixelBus.git
#include <NeoPixelBus.h>
const uint16_t PixelCount = 4; // this example assumes 4 pixels, making it smaller will cause a failure
#define colorSaturation 255
NeoPixelBus<NeoGrbFeature, Neo800KbpsMethod> strip(PixelCount);
RgbColor red(colorSaturation, 0, 0);
RgbColor green(0, colorSaturation, 0);
RgbColor blue(0, 0, colorSaturation);
RgbColor white(colorSaturation);
RgbColor black(0);
//RgbColor act_color(0, 0, 0);
uint16_t indexLed;
int color_level; 

#include <NeoPixelAnimator.h>
NeoPixelAnimator animations(PixelCount); // NeoPixel animation management object
struct MyAnimationState
{
    RgbColor StartingColor;
    RgbColor EndingColor;
};
MyAnimationState animationState[PixelCount];

// APDS9930 proximity & ambient light https://github.com/Depau/APDS9930.git
#include <APDS9930.h>
APDS9930 apds = APDS9930();
uint16_t proximity_data = 0;
float ambient_light = 0; // can also be an unsigned long
long hold_time=0;

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
  display.setContrast(200, 255, 1);
  delay(2000);

  //LED
  strip.Begin();
  SetRandomSeed();

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
  if ( apds.enableProximitySensor(false) )
    if(deb) Serial.println("Proximity sensor is now running");
  else
    if(deb) Serial.println("Something went wrong during sensor init!");
  apds.setLEDDrive(LED_DRIVE_100MA);
  //apds.setLEDDrive(LED_DRIVE_25MA);
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
    color_level= proximity_data / 4;
  } else
    if(deb) Serial.println("Error reading proximity value");

  // Read the light levels (ambient, red, green, blue)
  if ( apds.readAmbientLightLux(ambient_light) )
    if(deb) Serial.println("\tambient: " + (String)ambient_light);
  else
    if(deb) Serial.println("Error reading light values");

  //LED
  if (proximity_data < 150){
    hold_time= 0;
    led(RgbColor(0,60,0));
  }
  else if (proximity_data == 1023){
    if (hold_time==0) hold_time= millis();
    led(red);
  }
  else {
    hold_time= 0;
    led(RgbColor(color_level - 1, 256 - color_level, 0));
  }

  if (proximity_data == 1023 && hold_time != 0 && millis() - hold_time > 3000 && millis() - hold_time < 9999)
    led_string();
  else if (proximity_data == 1023 && hold_time != 0 && millis() - hold_time > 10000)
    led(white);

  oled_show();
  //Serial.println((String)(millis() - hold_time) + "\t" + (String)hold_time + "\t" + (String)proximity_data);
  delay(100);
}

void led(RgbColor color){
  for (indexLed= 0; indexLed < PixelCount; indexLed++){
    strip.SetPixelColor(indexLed, color);
  }
  strip.Show();
}

void oled_show(){
  display.clear();
  //display.invertDisplay();
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

void led_string(){
  for (indexLed= 0; indexLed < PixelCount; indexLed++){
    if (animations.IsAnimating()){
      // the normal loop just needs these two to run the active animations
      animations.UpdateAnimations();
      strip.Show();
    } else {
      // no animations runnning, start some 
      PickRandom(0.4f); // 0.0 = black, 0.25 is normal, 0.5 is bright
    }
  }
}

void SetRandomSeed(){
    uint32_t seed;

    // random works best with a seed that can use 31 bits
    // analogRead on a unconnected pin tends toward less than four bits
    seed = analogRead(0);
    delay(1);

    for (int shifts = 3; shifts < 31; shifts += 3)
    {
        seed ^= analogRead(0) << shifts;
        delay(1);
    }

    // Serial.println(seed);
    randomSeed(seed);
}

// simple blend function
void BlendAnimUpdate(const AnimationParam& param){
    // this gets called for each animation on every time step
    // progress will start at 0.0 and end at 1.0
    // we use the blend function on the RgbColor to mix
    // color based on the progress given to us in the animation
    RgbColor updatedColor = RgbColor::LinearBlend(
        animationState[param.index].StartingColor,
        animationState[param.index].EndingColor,
        param.progress);
    // apply the color to the strip
    strip.SetPixelColor(param.index, updatedColor);
}

void PickRandom(float luminance){
    // pick random count of pixels to animate
    uint16_t count = random(PixelCount);
    while (count > 0)
    {
        // pick a random pixel
        uint16_t pixel = random(PixelCount);

        // pick random time and random color
        // we use HslColor object as it allows us to easily pick a color
        // with the same saturation and luminance 
        uint16_t time = random(200, 600);
        animationState[pixel].StartingColor = strip.GetPixelColor(pixel);
        animationState[pixel].EndingColor = HslColor(random(360) / 360.0f, 1.0f, luminance);

        animations.StartAnimation(pixel, time, BlendAnimUpdate);

        count--;
    }
}
