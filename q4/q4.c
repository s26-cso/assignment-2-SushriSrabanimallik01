#include <stdio.h>
#include <dlfcn.h>

int main(){
    char op[6];
    char path[16];
    int a = 0 ,b = 0;

    while(scanf("%5s %d %d" , op , &a , &b)==3){

        int i = 0, j = 0;
        path[j++] = '.';
        path[j++] = '/';
        path[j++] = 'l';
        path[j++] = 'i';
        path[j++] = 'b';
        while (op[i]) path[j++] = op[i++];
        path[j++] = '.';
        path[j++] = 's';
        path[j++] = 'o';
        path[j]   = '\0';

        void *handle = dlopen(path, RTLD_LAZY | RTLD_LOCAL);
        if (!handle) {
            printf("Error\n");  
            continue;
        }
        dlerror();

        int (*func)(int, int);
        *(void **)(&func) = dlsym(handle, op);

        if (dlerror() != NULL) {
            printf("Error\n");
            dlclose(handle);
            continue;
        }
        int res = func(a, b);
        printf("%d\n", res);
        dlclose(handle);
    }

    return 0;



}