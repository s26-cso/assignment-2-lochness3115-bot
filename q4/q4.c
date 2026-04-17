#include <stdio.h>
#include <string.h>
#include <dlfcn.h>

typedef int (*fptr)(int, int); // Function pointer type for operations taking two ints and returning an int

int main() {
    char op[6];
    int num1, num2;
    void *handle = NULL;
    fptr fn = NULL;
    char loaded[6] = "";
    while (scanf("%5s %d %d", op, &num1, &num2) == 3) { // Read operation name and two integers until input fails
        if (strcmp(op, loaded) != 0) { // Check if the requested operation differs from the one currently loaded
            if (handle != NULL) { // Guard against dlclose(NULL) on first iteration
                dlclose(handle); // Close the current handle
                handle = NULL;
                fn = NULL;
            }
            char libname[20];
            snprintf(libname, sizeof(libname), "./lib%s.so", op); // Construct the library path
            // Open the shared object file dynamically
            handle = dlopen(libname, RTLD_LAZY);
            // Error check: Ensure handle is valid before proceeding
            if (!handle) {
                fprintf(stderr, "Library load error: %s\n", dlerror());
                memset(loaded, 0, sizeof(loaded)); // Reset loaded status
                continue;
            }
            // Extract the function symbol with the same name as the operation
            fn = (fptr)dlsym(handle, op);
            // Error check: Ensure function was found in the library
            char *error = dlerror();
            if (error != NULL) {
                fprintf(stderr, "Symbol error: %s\n", error);
                dlclose(handle);
                handle = NULL;
                memset(loaded, 0, sizeof(loaded));
                continue;
            }
            // Update the tracking string to the new operation
            strncpy(loaded, op, sizeof(loaded) - 1);
            loaded[sizeof(loaded) - 1] = '\0'; // Ensure null termination
        }
        // Final safety check before execution
        if (fn != NULL) {
            printf("%d\n", fn(num1, num2)); // Execute the loaded function and print the result
        }
    }
    
    if (handle != NULL) {
        dlclose(handle); 
    }
    
    return 0;
}
