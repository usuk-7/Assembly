# 0903 과제 — Chapter 1 Exercise 풀이

## 1.7.1 Short Answer

**1.** In an 8-bit binary number, which is the most significant bit (MSB)?

8비트 이진수에서 MSB(최상위 비트)는 맨 왼쪽 비트이다.

**2.** What is the decimal representation of each of the following unsigned binary integers?  
a. 00110101 b. 10010110 c. 11001100

- a. 00110101 = 53
- b. 10010110 = 150
- c. 11001100 = 204

**3.** What is the sum of each pair of binary integers?  
a. 10101111 + 11011011 b. 10010111 + 11111111 c. 01110101 + 10101100

(결과, 9비트로 캐리 포함 표기)
- a. 10101111 + 11011011 = 1 10001010 (carry=1, 8비트 결과 10001010)
- b. 10010111 + 11111111 = 1 10010110 (carry=1, 8비트 결과 10010110)
- c. 01110101 + 10101100 = 1 00100001 (carry=1, 8비트 결과 00100001)

**4.** Calculate binary 00001101 minus 00000111.

00001101 − 00000111 = 00000110 (13 − 7 = 6)

**5.** How many bits are used by each of the following data types?  
a. word b. doubleword c. quadword d. double quadword

- a. word = 16 bit
- b. doubleword = 32 bit
- c. quadword = 64 bit
- d. double quadword = 128 bit

**6.** What is the minimum number of binary bits needed to represent each of the following unsigned decimal integers?  
a. 4095 b. 65534 c. 42319

- a. 4095 → 12 bit
- b. 65534 → 16 bit
- c. 42319 → 16 bit

**7.** What is the hexadecimal representation of each of the following binary numbers?  
a. 0011 0101 1101 1010 b. 1100 1110 1010 0011 c. 1111 1110 1101 1011

- a. 0011 0101 1101 1010 → 35DA
- b. 1100 1110 1010 0011 → CEA3
- c. 1111 1110 1101 1011 → FEDB

**8.** What is the binary representation of the following hexadecimal numbers?  
a. 0126F9D4 b. 6ACDFA95 c. F69BDC2A

- a. 0126F9D4 → 0000 0001 0010 0110 1111 1001 1101 0100
- b. 6ACDFA95 → 0110 1010 1100 1101 1111 1010 1001 0101
- c. F69BDC2A → 1111 0110 1001 1011 1101 1100 0010 1010

**9.** What is the unsigned decimal representation of each of the following hexadecimal integers?  
a. 3A b. 1BF c. 1001

- a. 3A = 58
- b. 1BF = 447
- c. 1001(16) = 4097

**10.** What is the unsigned decimal representation of each of the following hexadecimal integers?  
a. 62 b. 4B3 c. 29F

- a. 62 = 98
- b. 4B3 = 1203
- c. 29F = 671

**11.** What is the 16-bit hexadecimal representation of each of the following signed decimal integers?  
a. −24 b. −331

- a. −24 → FFE8
- b. −331 → FEB5

**12.** What is the 16-bit hexadecimal representation of each of the following signed decimal integers?  
a. −21 b. −45

- a. −21 → FFEB
- b. −45 → FFD3

**13.** The following 16-bit hexadecimal numbers represent signed integers. Convert each to decimal.  
a. 6BF9 b. C123

- a. 6BF9 → 27641
- b. C123 → −16093

**14.** The following 16-bit hexadecimal numbers represent signed integers. Convert each to decimal.  
a. 4CD2 b. 8230

- a. 4CD2 → 19666
- b. 8230 → −32208

**15.** What is the decimal representation of each of the following signed binary numbers?  
a. 10110101 b. 00101010 c. 11110000

- a. 10110101 → −75
- b. 00101010 → 42
- c. 11110000 → −16

**16.** What is the decimal representation of each of the following signed binary numbers?  
a. 10000000 b. 11001100 c. 10110111

- a. 10000000 → −128
- b. 11001100 → −52
- c. 10110111 → −73

**17.** What is the 8-bit binary (two's-complement) representation of each of the following signed decimal integers?  
a. −5 b. −42 c. −16

- a. −5 → 11111011
- b. −42 → 11010110
- c. −16 → 11110000

**18.** What is the 8-bit binary (two's-complement) representation of each of the following signed decimal integers?  
a. −72 b. −98 c. −26

- a. −72 → 10111000
- b. −98 → 10011110
- c. −26 → 11100110

**19.** What is the sum of each pair of hexadecimal integers?  
a. 6B4 + 3FE b. A49 + 6BD

- a. 6B4 + 3FE = AB2
- b. A49 + 6BD = 1106

**20.** What is the sum of each pair of hexadecimal integers?  
a. 7C4 + 3BE b. B69 + 7AD

- a. 7C4 + 3BE = B82
- b. B69 + 7AD = 1316

**21.** What are the hexadecimal and decimal representations of the ASCII character capital B?

16진수 42, 십진수 66

**22.** What are the hexadecimal and decimal representations of the ASCII character capital G?

16진수 47, 십진수 71

**23. Challenge:** What is the largest decimal value you can represent, using a 129-bit unsigned integer?

2¹²⁹ − 1

**24. Challenge:** What is the largest decimal value you can represent, using a 86-bit signed integer?

2⁸⁵ − 1

**25.** Create a truth table to show all possible inputs and outputs for the boolean function described by ¬(A ∨ B).

| A | B | A∨B | ¬(A∨B) |
|---|---|-----|--------|
| 0 | 0 | 0   | 1      |
| 0 | 1 | 1   | 0      |
| 1 | 0 | 1   | 0      |
| 1 | 1 | 1   | 0      |

**26.** Create a truth table to show all possible inputs and outputs for the boolean function described by (¬A ∧ ¬B). How would you describe the rightmost column of this table in relation to the table from question number 25? Have you heard of De Morgan's Theorem?

| A | B | ¬A | ¬B | ¬A∧¬B |
|---|---|----|----|-------|
| 0 | 0 | 1  | 1  | 1     |
| 0 | 1 | 1  | 0  | 0     |
| 1 | 0 | 0  | 1  | 0     |
| 1 | 1 | 0  | 0  | 0     |

오른쪽 열(결과)이 25번 표와 완전히 동일하다. 즉 ¬(A∨B) = ¬A∧¬B — 이것이 드모르간의 법칙(De Morgan's Theorem)이다.

**27.** If a boolean function has four inputs, how many rows are required for its truth table?

2⁴ = 16행

**28.** How many selector bits are required for a four-input multiplexer?

log₂(4) = 2비트

---

## 1.7.2 Algorithm Workbench

Use any high-level programming language you wish for the following programming exercises. Do not call built-in library functions that accomplish these tasks automatically. (Examples are sprintf and sscanf from the Standard C library.)

**1.** Write a function that receives a string containing a 16-bit binary integer. The function must return the string's integer value.

```java
public static int binToInt(String s) {
    int result = 0;
    for (int i = 0; i < s.length(); i++) {
        result = result * 2 + (s.charAt(i) - '0');
    }
    return result;
}
```

**2.** Write a function that receives a string containing a 32-bit hexadecimal integer. The function must return the string's integer value.

```java
public static int hexToInt(String s) {
    int result = 0;
    for (int i = 0; i < s.length(); i++) {
        char ch = Character.toUpperCase(s.charAt(i));
        int digit = (ch >= '0' && ch <= '9') ? ch - '0' : ch - 'A' + 10;
        result = result * 16 + digit;
    }
    return result;
}
```

**3.** Write a function that receives an integer. The function must return a string containing the binary representation of the integer.

```java
public static String intToBin(int n) {
    if (n == 0) return "0";
    StringBuilder sb = new StringBuilder();
    while (n > 0) {
        sb.insert(0, n % 2);
        n /= 2;
    }
    return sb.toString();
}
```

**4.** Write a function that receives an integer. The function must return a string containing the hexadecimal representation of the integer.

```java
public static String intToHex(int n) {
    String digits = "0123456789ABCDEF";
    if (n == 0) return "0";
    StringBuilder sb = new StringBuilder();
    while (n > 0) {
        sb.insert(0, digits.charAt(n % 16));
        n /= 16;
    }
    return sb.toString();
}
```

**5.** Write a function that adds two digit strings in base b, where 2 ≤ b ≤ 10. Each string may contain as many as 1,000 digits. Return the sum in a string that uses the same number base.

```java
public static String addBaseStrings(String s1, String s2, int b) {
    int i = s1.length() - 1, j = s2.length() - 1;
    int carry = 0;
    StringBuilder sb = new StringBuilder();
    while (i >= 0 || j >= 0 || carry != 0) {
        int d1 = (i >= 0) ? s1.charAt(i) - '0' : 0;
        int d2 = (j >= 0) ? s2.charAt(j) - '0' : 0;
        int total = d1 + d2 + carry;
        sb.append(total % b);
        carry = total / b;
        i--;
        j--;
    }
    return sb.reverse().toString();
}
```

**6.** Write a function that adds two hexadecimal strings, each as long as 1,000 digits. Return a hexadecimal string that represents the sum of the inputs.

```java
public static String addHexStrings(String s1, String s2) {
    String digits = "0123456789ABCDEF";
    int i = s1.length() - 1, j = s2.length() - 1;
    int carry = 0;
    StringBuilder sb = new StringBuilder();
    while (i >= 0 || j >= 0 || carry != 0) {
        int d1 = (i >= 0) ? digits.indexOf(Character.toUpperCase(s1.charAt(i))) : 0;
        int d2 = (j >= 0) ? digits.indexOf(Character.toUpperCase(s2.charAt(j))) : 0;
        int total = d1 + d2 + carry;
        sb.append(digits.charAt(total % 16));
        carry = total / 16;
        i--;
        j--;
    }
    return sb.reverse().toString();
}
```

**7.** Write a function that multiplies a single hexadecimal digit by a hexadecimal digit string as long as 1,000 digits. Return a hexadecimal string that represents the product.

```java
public static String multiplyHexByDigit(String s, char digit) {
    String digits = "0123456789ABCDEF";
    int dval = digits.indexOf(Character.toUpperCase(digit));
    int carry = 0;
    StringBuilder sb = new StringBuilder();
    for (int i = s.length() - 1; i >= 0; i--) {
        int val = digits.indexOf(Character.toUpperCase(s.charAt(i))) * dval + carry;
        sb.append(digits.charAt(val % 16));
        carry = val / 16;
    }
    while (carry != 0) {
        sb.append(digits.charAt(carry % 16));
        carry /= 16;
    }
    return sb.length() == 0 ? "0" : sb.reverse().toString();
}
```

**8.** Write a Java program that contains the calculation shown below. Then, use the javap –c command to disassemble your code. Add comments to each line that provide your best guess as to its purpose.
```
int Y;
int X = (Y + 4) * 3;
```

```java
public class Calc {
    public static void main(String[] args) {
        int Y = 5;
        int X = (Y + 4) * 3;
        System.out.println(X);
    }
}
```

`javap -c` 디스어셈블 결과에 대한 예상 주석 :
```
iload_1        // 지역변수 Y 값을 스택에 로드
iconst_4       // 상수 4를 스택에 push
iadd           // Y + 4 연산 수행, 결과를 스택에 push
iconst_3       // 상수 3을 스택에 push
imul           // (Y+4) * 3 연산 수행
istore_2       // 연산 결과를 지역변수 X에 저장
```

**9.** Devise a way of subtracting unsigned binary integers. Test your technique by subtracting binary 00000101 from binary 10001000, producing 10000011. Test your technique with at least two other sets of integers, in which a smaller value is always subtracted from a larger one.

**방법(자리 빌림/borrow 방식):** 십진수 뺄셈처럼 최하위 비트(LSB)부터 시작해 각 자리에서 위쪽(피감수) 비트에서 아래쪽(감수) 비트를 뺀다. 위쪽 비트가 0이고 아래쪽 비트가 1이면 그 자리는 다음 상위 자리에서 1을 빌려와(borrow) 계산하고, 빌려온 상위 자리는 1을 뺀 뒤 다시 계산을 진행한다.

- 테스트 1: 10001000 − 00000101 = 10000011 (136 − 5 = 131) — 문제에서 주어진 예
- 테스트 2: 11110000 − 00010101 = 11011011 (240 − 21 = 219)
- 테스트 3: 01100100 − 00011001 = 01001011 (100 − 25 = 75)

```java
public static String subtractUnsignedBin(String a, String b) {
    int n = a.length();
    char[] result = new char[n];
    int borrow = 0;
    for (int i = n - 1; i >= 0; i--) {
        int da = (a.charAt(i) - '0') - borrow;
        int db = b.charAt(i) - '0';
        if (da < db) {
            da += 2;
            borrow = 1;
        } else {
            borrow = 0;
        }
        result[i] = (char) ('0' + (da - db));
    }
    return new String(result);
}
```
