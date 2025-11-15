#!/bin/bash

# צבעים לפלט
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================"
echo "   בדיקות Encoder - Lab A"
echo "================================"
echo ""

# קומפילציה
echo -e "${YELLOW}קומפילציה...${NC}"
make encoder
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ שגיאת קומפילציה${NC}"
    exit 1
fi
echo -e "${GREEN}✓ קומפילציה הצליחה${NC}"
echo ""

# בדיקה 1: Echo רגיל
echo "בדיקה 1: Echo רגיל"
./encoder < input.txt > test_output.txt 2>/dev/null
if diff -q input.txt test_output.txt > /dev/null; then
    echo -e "${GREEN}✓ עבר${NC}"
else
    echo -e "${RED}✗ נכשל${NC}"
fi
echo ""

# בדיקה 2: הצפנה +E12345
echo "בדיקה 2: הצפנה +E12345"
echo "ABCDEZ" | ./encoder +E12345 2>/dev/null > test_output.txt
EXPECTED="BDFHJA"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - ABCDEZ → BDFHJA${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 3: הצפנה -E4321
echo "בדיקה 3: הצפנה -E4321 (חיסור)"
echo "GDUQP523" | ./encoder -E4321 2>/dev/null > test_output.txt
EXPECTED="CASPL202"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - GDUQP523 → CASPL202${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 4: Wrap around אותיות
echo "בדיקה 4: Wrap around (Z+1=A)"
echo "Z" | ./encoder +E1 2>/dev/null > test_output.txt
EXPECTED="A"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - Z+1 → A${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 5: Wrap around ספרות
echo "בדיקה 5: Wrap around ספרות (9+1=0)"
echo "9" | ./encoder +E1 2>/dev/null > test_output.txt
EXPECTED="0"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - 9+1 → 0${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 6: אותיות קטנות לא משתנות
echo "בדיקה 6: אותיות קטנות לא משתנות"
echo "abc" | ./encoder +E5 2>/dev/null > test_output.txt
EXPECTED="abc"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - abc נשאר abc${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 7: תווים מיוחדים לא משתנים
echo "בדיקה 7: תווים מיוחדים לא משתנים"
echo "!@#" | ./encoder +E5 2>/dev/null > test_output.txt
EXPECTED="!@#"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - !@# נשאר !@#${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 8: key מתקדם עבור כל תו
echo "בדיקה 8: key מתקדם גם עבור תווים שלא מוצפנים"
echo "A!B" | ./encoder +E123 2>/dev/null > test_output.txt
EXPECTED="B!E"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - A!B → B!E (key התקדם גם עבור !)${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 9: קבצים
echo "בדיקה 9: קריאה וכתיבה מקבצים"
echo "ABC" > test_input.txt
./encoder +E123 -itest_input.txt -otest_output.txt 2>/dev/null
EXPECTED="BDF"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - קבצי קלט/פלט עובדים${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
rm -f test_input.txt
echo ""

# בדיקה 10: שגיאת קובץ
echo "בדיקה 10: טיפול בשגיאות (קובץ לא קיים)"
./encoder -inonexistent_file.txt 2>&1 | grep -q "Error"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ עבר - הודעת שגיאה מוצגת${NC}"
else
    echo -e "${RED}✗ נכשל - לא הוצגה הודעת שגיאה${NC}"
fi
echo ""

# בדיקה 11: Debug mode (-D)
echo "בדיקה 11: Debug mode (-D)"
OUTPUT=$(echo "A" | ./encoder -D test 2>&1)
if echo "$OUTPUT" | grep -q "./encoder" && echo "$OUTPUT" | grep -q -- "-D" && ! echo "$OUTPUT" | grep -q "test"; then
    echo -e "${GREEN}✓ עבר - debug כבוי נכון${NC}"
else
    echo -e "${RED}✗ נכשל - debug לא כבוי נכון${NC}"
fi
echo ""

# בדיקה 12: +D עם סיסמה נכונה
echo "בדיקה 12: +D עם סיסמה נכונה"
OUTPUT=$(echo "A" | ./encoder -D +Dpass test 2>&1 1>/dev/null)
if echo "$OUTPUT" | grep -q "test"; then
    echo -e "${GREEN}✓ עבר - debug הודלק מחדש עם סיסמה נכונה${NC}"
else
    echo -e "${RED}✗ נכשל - debug לא הודלק${NC}"
fi
echo ""

# בדיקה 13: +D עם סיסמה שגויה
echo "בדיקה 13: +D עם סיסמה שגויה"
OUTPUT=$(echo "A" | ./encoder -D +Dwrong test 2>&1 1>/dev/null)
if ! echo "$OUTPUT" | grep -q "test"; then
    echo -e "${GREEN}✓ עבר - debug נשאר כבוי עם סיסמה שגויה${NC}"
else
    echo -e "${RED}✗ נכשל - debug הודלק עם סיסמה שגויה${NC}"
fi
echo ""

# בדיקה 14: סדר שרירותי - הצפנה לפני debug
echo "בדיקה 14: סדר שרירותי (+E לפני -D)"
OUTPUT=$(echo "ABC" | ./encoder +E123 -D test 2>&1)
STDERR=$(echo "$OUTPUT" | grep -v "^[A-Z]")
STDOUT=$(echo "$OUTPUT" | grep "^[A-Z]")
if ! echo "$STDERR" | grep -q "test" && [ "$STDOUT" = "BDF" ]; then
    echo -e "${GREEN}✓ עבר - סדר שרירותי עובד${NC}"
else
    echo -e "${RED}✗ נכשל - סדר שרירותי לא עובד${NC}"
fi
echo ""

# בדיקה 15: הצפנה + קובץ פלט בלבד
echo "בדיקה 15: הצפנה + קובץ פלט (-o בלבד)"
echo "XYZ" | ./encoder +E5 -otest_output.txt 2>/dev/null
EXPECTED="CDE"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - קובץ פלט בלבד${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 16: הצפנה + קובץ קלט בלבד
echo "בדיקה 16: הצפנה + קובץ קלט (-i בלבד)"
echo "ABC" > test_input.txt
./encoder +E123 -itest_input.txt 2>/dev/null > test_output.txt
EXPECTED="BDF"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - קובץ קלט בלבד${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
rm -f test_input.txt
echo ""

# בדיקה 17: כל הפלאגים יחד
echo "בדיקה 17: כל הפלאגים יחד (-i -o +E -D)"
echo "ABCDE" > test_input.txt
./encoder -D +E12345 -itest_input.txt -otest_output.txt 2>/dev/null
EXPECTED="BDFHJ"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - כל הפלאגים יחד${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
rm -f test_input.txt
echo ""

# בדיקה 18: Wrap around חיסור (A-1=Z)
echo "בדיקה 18: Wrap around חיסור (A-1=Z)"
echo "A" | ./encoder -E1 2>/dev/null > test_output.txt
EXPECTED="Z"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - A-1 → Z${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 19: Wrap around ספרות חיסור (0-1=9)
echo "בדיקה 19: Wrap around ספרות חיסור (0-1=9)"
echo "0" | ./encoder -E1 2>/dev/null > test_output.txt
EXPECTED="9"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - 0-1 → 9${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 20: דוגמה מלאה מהמטלה (עם newline)
echo "בדיקה 20: דוגמה מהמטלה עם newline"
echo -e "ABCDEZ\n12#<" | ./encoder +E12345 2>/dev/null > test_output.txt
EXPECTED=$'BDFHJA\n46#<'
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - דוגמה מהמטלה${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 21: מפתח ארוך + key מתקדם
echo "בדיקה 21: מפתח ארוך + מעבר מחזורי"
echo "ABCDEFGH" | ./encoder +E123 2>/dev/null > test_output.txt
# A+1=B, B+2=D, C+3=F, D+1=E, E+2=G, F+3=I, G+1=H, H+2=J
EXPECTED="BDFEGIHJ"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - מעבר מחזורי על מפתח${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 22: מעורב אותיות וספרות
echo "בדיקה 22: מעורב אותיות + ספרות"
echo "A1B2C3" | ./encoder +E111 2>/dev/null > test_output.txt
EXPECTED="B2C3D4"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - מעורב אותיות וספרות${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 23: ללא הצפנה (ברירת מחדל)
echo "בדיקה 23: ללא הצפנה (encoding_key = '0')"
echo "TEST123" | ./encoder 2>/dev/null > test_output.txt
EXPECTED="TEST123"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - ללא הצפנה${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 24: שגיאת קובץ פלט (תיקייה לא קיימת)
echo "בדיקה 24: שגיאת קובץ פלט"
echo "ABC" | ./encoder -o/nonexistent_dir/output.txt 2>&1 | grep -q "Error"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ עבר - שגיאת קובץ פלט מטופלת${NC}"
else
    echo -e "${RED}✗ נכשל - לא הוצגה שגיאה${NC}"
fi
echo ""

# בדיקה 25: Pipe מ-echo (stdin רגיל)
echo "בדיקה 25: Pipe מ-echo"
echo "HELLO" | ./encoder +E1 2>/dev/null > test_output.txt
EXPECTED="IFMMP"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - pipe מ-echo${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 26: redirection < (stdin מקובץ)
echo "בדיקה 26: Redirection מקובץ (<)"
echo "WORLD" > test_input.txt
./encoder +E1 < test_input.txt 2>/dev/null > test_output.txt
EXPECTED="XPSME"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - redirection מקובץ${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
rm -f test_input.txt
echo ""

# בדיקה 27: קומבינציה: -D +E -i -o בסדר שרירותי
echo "בדיקה 27: קומבינציה מלאה בסדר שרירותי"
echo "ABC" > test_input.txt
./encoder -otest_output.txt +E123 -itest_input.txt -D 2>/dev/null
ACTUAL_FILE=$(cat test_output.txt)
if [ "$ACTUAL_FILE" = "BDF" ]; then
    echo -e "${GREEN}✓ עבר - קומבינציה מלאה בסדר שרירותי${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL_FILE, ציפיתי: BDF${NC}"
fi
rm -f test_input.txt
echo ""

# בדיקה 28: רק -i (output ל-stdout)
echo "בדיקה 28: רק -i (output ל-stdout)"
echo "XYZ" > test_input.txt
./encoder +E1 -itest_input.txt 2>/dev/null > test_output.txt
EXPECTED="YZA"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - קריאה מקובץ, כתיבה ל-stdout${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
rm -f test_input.txt
echo ""

# בדיקה 29: רק -o (input מ-stdin)
echo "בדיקה 29: רק -o (input מ-stdin)"
echo "ABC" | ./encoder +E1 -otest_output.txt 2>/dev/null
EXPECTED="BCD"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - קריאה מ-stdin, כתיבה לקובץ${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 30: מפתח חד-ספרתי
echo "בדיקה 30: מפתח חד-ספרתי"
echo "AAA" | ./encoder +E5 2>/dev/null > test_output.txt
EXPECTED="FFF"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - מפתח חד-ספרתי${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 31: חיסור + קבצים
echo "בדיקה 31: חיסור + קבצים"
echo "DEF" > test_input.txt
./encoder -E123 -itest_input.txt -otest_output.txt 2>/dev/null
# D-1=C, E-2=C, F-3=C
EXPECTED="CCC"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - חיסור עם קבצים${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
rm -f test_input.txt
echo ""

# בדיקה 32: debug ON + קבצים
echo "בדיקה 32: debug ON + קבצים (ברירת מחדל)"
echo "A" > test_input.txt
OUTPUT=$(./encoder +E1 -itest_input.txt -otest_output.txt 2>&1 1>/dev/null)
ACTUAL_FILE=$(cat test_output.txt)
if echo "$OUTPUT" | grep -q "+E1" && echo "$OUTPUT" | grep -q "\-itest_input.txt" && [ "$ACTUAL_FILE" = "B" ]; then
    echo -e "${GREEN}✓ עבר - debug ON עם קבצים${NC}"
else
    echo -e "${RED}✗ נכשל - debug או הצפנה לא עובדים${NC}"
fi
rm -f test_input.txt
echo ""

# בדיקה 33: רווחים ותווים מיוחדים לא משתנים אבל key מתקדם
echo "בדיקה 33: רווחים מתקדמים key"
echo "A B" | ./encoder +E123 2>/dev/null > test_output.txt
EXPECTED="B E"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - רווח מתקדם key${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: '$ACTUAL', ציפיתי: '$EXPECTED'${NC}"
fi
echo ""

# בדיקה 34: newline מתקדם key
echo "בדיקה 34: newline מתקדם key (דוגמה מהמטלה)"
echo -e "Z\n1" | ./encoder +E12 2>/dev/null > test_output.txt
# Z+1=A (key=1, idx→1), \n (key=2, idx→2→0), 1+1=2 (key=1)
EXPECTED=$'A\n2'
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - newline מתקדם key${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: '$ACTUAL', ציפיתי: '$EXPECTED'${NC}"
fi
echo ""

# בדיקה 35: wrap around מרובה (Z+9=I, wrap)
echo "בדיקה 35: wrap around גדול (Z+9=I)"
echo "Z" | ./encoder +E9 2>/dev/null > test_output.txt
# Z=25, 25+9=34, 34%26=8, A+8=I
EXPECTED="I"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - wrap around גדול${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 36: ספרה wrap around גדול (9+5=4)
echo "בדיקה 36: ספרה wrap around גדול (9+5=4)"
echo "9" | ./encoder +E5 2>/dev/null > test_output.txt
# 9=9, 9+5=14, 14%10=4, 0+4=4
EXPECTED="4"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - ספרה wrap גדול${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 37: קומבינציה: +D +E בסדר מעורב
echo "בדיקה 37: +D +E בסדר מעורב"
OUTPUT=$(echo "AB" | ./encoder -D +E12 +Dpass test 2>&1)
STDERR=$(echo "$OUTPUT" | head -3)
STDOUT=$(echo "$OUTPUT" | tail -1)
if echo "$STDERR" | grep -q "test" && [ "$STDOUT" = "BD" ]; then
    echo -e "${GREEN}✓ עבר - +D +E בסדר מעורב${NC}"
else
    echo -e "${RED}✗ נכשל${NC}"
fi
echo ""

# בדיקה 38: ללא ארגומנטים (ברירות מחדל)
echo "בדיקה 38: ללא ארגומנטים (רק echo)"
echo "Hello123" | ./encoder 2>/dev/null > test_output.txt
EXPECTED="Hello123"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - ברירות מחדל${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 39: +E ו--E יחד (רק אחד אמור לעבוד - האחרון)
echo "בדיקה 39: +E ו--E יחד (האחרון מנצח)"
echo "C" | ./encoder +E1 -E1 2>/dev/null > test_output.txt
EXPECTED="B"
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - -E האחרון מנצח${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: $ACTUAL, ציפיתי: $EXPECTED${NC}"
fi
echo ""

# בדיקה 40: קלט ריק
echo "בדיקה 40: קלט ריק"
echo -n "" | ./encoder +E123 2>/dev/null > test_output.txt
EXPECTED=""
ACTUAL=$(cat test_output.txt)
if [ "$ACTUAL" = "$EXPECTED" ]; then
    echo -e "${GREEN}✓ עבר - קלט ריק${NC}"
else
    echo -e "${RED}✗ נכשל - קיבלתי: '$ACTUAL', ציפיתי: קלט ריק${NC}"
fi
echo ""

# ניקוי
rm -f test_output.txt

echo "================================"
echo "   בדיקות הסתיימו"
echo "================================"

