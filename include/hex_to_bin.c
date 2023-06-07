#include <stdio.h>

int hex(char* hexdec);

int main() {
    char hexdec[8] = "A3B0FE00"
    printf("%s = %d" hex(hexdec));
    return 0;
}

int hex(char* hexdec){
    size_t i = (hexdec[1] == 'x' || hexdec[1] == 'X')? 2 : 0;
    int
    while (hexdec[i]){
        switch (hexdec[i]){
        case '0':
            
            break;
        
        default:
            break;
        }
        i++;
    }
    
}