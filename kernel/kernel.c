#include <stdint.h>

void kernel_main(void) {
    // VGA framebuffer address for text mode (0xb8000)
    volatile uint16_t* video = (uint16_t*)0xB8000;

    const char* msg = "Hello, World!";
    for (int i = 0; msg[i] != '\0'; i++) {
        video[i] = (0x0F << 8) | msg[i]; // White text on black background
    }

    while (1) {
        __asm__("hlt"); // Halt
    }
}

