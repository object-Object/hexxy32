#include <simpleRPC.h>

void setup() {
    Serial.begin(115200);
}

void loop() {
    interface(
        Serial,
        digitalRead, "digital_read: Reads the value from a specified digital pin, either `HIGH` (`1`) or `LOW` (`0`)."
                     " @pin: The Arduino pin number you want to read."
                     " @return: `HIGH` (`1`) or `LOW` (`0`).",
        digitalWrite, "digital_write: Writes a `HIGH` (`1`) or a `LOW` (`0`) value to a digital pin."
                      " @pin: The Arduino pin number."
                      " @value: `HIGH` (`1`) or `LOW` (`0`).",
        pinMode, "pin_mode: Configures the specified pin to behave either as an input or an output."
                 " @pin: The Arduino pin number to set the mode of."
                 " @mode: `INPUT` (`0`), `OUTPUT` (`1`), or `INPUT_PULLUP` (`2`)."
    );
}
