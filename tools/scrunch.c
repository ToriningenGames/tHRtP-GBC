#include <stdio.h>


int getitem()
{
        static int count = -1;
        while (!feof(stdin)) {
                count++;
                switch (getc(stdin)) {
                case '0':
                        return 0 + (count > 255)*0x08;
                case '1':
                        return 1 + (count > 255)*0x08;
                case '2':
                        return 2 + (count > 255)*0x08;
                case '3':
                        return 3 + (count > 255)*0x08;
                case '4':
                        return 4 + (count > 255)*0x08;
                case '5':
                        return 5 + (count > 255)*0x08;
                case '6':
                        return 6 + (count > 255)*0x08;
                case '7':
                        return 7 + (count > 255)*0x08;
                }
                count--;
        }
        return -1;
}

int main(void)
{
        int out1 = -1, out2 = -1;
        while (1) {
                out1 = getitem();
                out2 = getitem();
                if (out2 == -1)
                        break;
                putc((out1*0x10+out2)&0xFF, stdout);
        }
        //Check for a half; there shouldn't be, but...
        if (out1 != -1)
                putc((out1*0x10)&0xFF, stdout);
        return 0;
}
