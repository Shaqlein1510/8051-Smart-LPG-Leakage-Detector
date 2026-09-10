# 8051 Smart LPG Leakage Detector

An 8051-based LPG gas leakage detection and safety system designed to continuously monitor gas concentration and provide multi-level alerts with automatic exhaust-fan activation during high leakage conditions.

##  Project Overview

This project uses an AT89C51/8051 microcontroller, MQ-2 gas sensor, and ADC0804 to detect LPG gas concentration. Based on the detected ADC value, the system classifies the condition into three levels:

- 🟢 Normal – No significant leakage detected
- 🟡 Low Leakage – Warning condition
- 🔴 High Leakage – Critical condition

The system provides visual and audible alerts through LEDs and a buzzer. During high leakage, a relay-driven exhaust fan is activated automatically.

##  Main Components

- AT89C51 / 8051 Microcontroller
- MQ-2 Gas Sensor
- ADC0804 Analog-to-Digital Converter
- 16×2 LCD Display
- Green, Yellow and Red LEDs
- Buzzer
- 5V Relay
- BC547 Transistors
- 12V DC Exhaust Fan
- 11.0592 MHz Crystal
- Resistors, capacitors and potentiometers
- 5V Power Supply

##  System Operation

The MQ-2 sensor detects combustible gases and produces an analog signal. The ADC0804 converts this analog signal into an 8-bit digital value, which is read by the 8051 microcontroller.

The microcontroller compares the ADC value with predefined thresholds and activates the appropriate output devices.

### Alert Levels

| ADC Value |   Condition  | Output |
|-----------|--------------|--------|
| 0–100     | Normal       | Green LED ON, buzzer OFF, fan OFF |
| 101–180   | Low Leakage  | Yellow LED ON, buzzer OFF, fan OFF |
| 181–255   | High Leakage | Red LED ON, buzzer ON, fan ON |


