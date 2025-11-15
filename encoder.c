#include <stdio.h>
#include <string.h>

/* Global variables */
unsigned char password[] = "pass";
int debug = 1; /* Default: debug mode ON */
FILE *infile = NULL;
FILE *outfile = NULL;
char *encoding_key = "0";
int is_add = 1;
int key_index = 0;

/* Encode function - currently returns character unchanged */
char encode(char c)
{
    if (encoding_key[0] == '0')
    {
        return c;
    }

    int key_digit = encoding_key[key_index] - '0';
    key_index++;
    if (encoding_key[key_index] == '\0')
    {
        key_index = 0;
    }

    if (c >= 'A' && c <= 'Z')
    {
        int offset = c - 'A'; // 0-25
        if (is_add)
        {
            offset = (offset + key_digit) % 26;
        }
        else
        {
            offset = (offset - key_digit + 26) % 26;
        }
        return 'A' + offset;
    }

    if (c >= '0' && c <= '9')
    {
        int offset = c - '0';
        if (is_add)
        {
            offset = (offset + key_digit) % 10;
        }
        else
        {
            offset = (offset - key_digit + 10) % 10;
        }
        return '0' + offset;
    }

    return c;
}

int main(int argc, char *argv[])
{
    char c;
    int i;

    /* Initialize file pointers */
    infile = stdin;
    outfile = stdout;

    /* Process command-line arguments */
    for (i = 0; i < argc; i++)
    {
        /* Print argument to stderr if in debug mode */
        if (debug)
        {
            fprintf(stderr, "%s\n", argv[i]);
        }

        /* Check for -D flag (turn debug OFF) */
        if (argv[i][0] == '-' && argv[i][1] == 'D' && argv[i][2] == '\0')
        {
            debug = 0;
        }

        /* Check for +D flag (turn debug ON with password) */
        if (argv[i][0] == '+' && argv[i][1] == 'D')
        {
            if (strcmp(&argv[i][2], (char *)password) == 0)
            {
                debug = 1;
            }
        }

        /* set adding encoding key (+E{key})*/
        if (argv[i][0] == '+' && argv[i][1] == 'E')
        {
            encoding_key = &argv[i][2];
            is_add = 1;
        }

        /* set subtracting encoding key (-E{key})*/
        if (argv[i][0] == '-' && argv[i][1] == 'E')
        {
            encoding_key = &argv[i][2];
            is_add = 0;
        }

        /* set input file (-ifname{fname})*/
        if (argv[i][0] == '-' && argv[i][1] == 'i')
        {
            infile = fopen(&argv[i][2], "r");
            if (infile == NULL)
            { // ✅ בדיקת שגיאה!
                fprintf(stderr, "Error: Cannot open input file\n");
                return 1;
            }
        }

        /* set output file (-ofname{fname})*/
        if (argv[i][0] == '-' && argv[i][1] == 'o')
        {
            outfile = fopen(&argv[i][2], "w");
            if (outfile == NULL)
            {
                fprintf(stderr, "Error: Cannot open output file\n");
                return 1;
            }
        }
    }

    /* Read characters from input, encode, and write to output */
    while (!feof(infile))
    {
        c = fgetc(infile);

        /* Check for EOF after reading */
        if (feof(infile))
        {
            break;
        }

        /* Encode the character */
        c = encode(c);

        /* Write to output */
        fputc(c, outfile);
    }

    /* Close input stream */
    if (infile != stdin && infile != NULL)
    {
        fclose(infile);
    }

    /* Close output stream */
    if (outfile != stdout && outfile != NULL)
    {
        fclose(outfile);
    }

    return 0;
}
