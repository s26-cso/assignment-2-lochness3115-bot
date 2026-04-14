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
        if (strcmp(op, loaded) != 0) { //Check if the requested operation differs from the one currently loaded 
            dlclose(handle); // Close the current handle 
            char libname[20];
            snprintf(libname, sizeof(libname), "./lib%s.so", op);    // Construct the library path
            // Open the shared object file dynamically 
            handle = dlopen(libname, RTLD_LAZY);
            //Extract the function symbol with the same name as the operation 
            fn = (fptr)dlsym(handle, op);
            //Update the tracking string to the new operation 
            strncpy(loaded, op, sizeof(loaded));
        }
        printf("%d\n", fn(num1, num2)); //Execute the loaded function and print the result
    } 
    dlclose(handle); 
    return 0;
}
