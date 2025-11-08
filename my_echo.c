#include <stdio.h>

int main(int argc, char **argv) {
    int i;
    
    // Start from argv[1] (skip program name)
    for (i = 1; i < argc; i++) {
        printf("%s", argv[i]);
        
        // Print space between arguments (but not after the last one)
        if (i < argc - 1) {
            printf(" ");
        }
    }
    
    // Print newline at the end
    printf("\n");
    
    return 0;
}

