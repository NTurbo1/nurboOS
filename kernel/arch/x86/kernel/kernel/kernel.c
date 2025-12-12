#include <stdio.h>

#include <kernel/tty.h>
#include <kernel/descriptor_tables.h>

void kernel_main(void) {
    init_descriptor_tables();

	terminal_initialize();
	printf("Hello, kernel World!\n");
    printf("Welcome to Nurbo OS!!!");

    asm volatile ("int $0x3");
    asm volatile ("int $0x4"); 
}
