# 2022-compiler-project

2022년 봄학기 컴파일러 기말프로젝트 수행 결과물입니다.

# 테스트 샘플 실행

## `fourOper.cbu`

더하기, 빼기, 곱하기, 나누기 연산

```
시작
가:= 4;
나:= 2;
다:= 나;
더하기테스트:= 가 더하기 나;
빼기테스트:= 가 빼기 다;
곱테스트:= 가 곱하기 나;
누기테스트:= 가 나누기 다;
끝

```

![image](https://user-images.githubusercontent.com/53112143/180184861-6f492153-ca0e-43e9-b850-cc7013163d21.png)

## `ifTest.cbu`

if문

```
시작
a:= 3;
if a > 2
    만약테스트:= 11;
;
a:= 1;
if a > 2
    만약테스트2:= 11;
;
끝
```

![image](https://user-images.githubusercontent.com/53112143/180184989-43229524-040a-463a-9e39-f56ac425565b.png)

## `ifElseTest.cbu`

if-else문

```
시작
a:= 3;
b:= 5;
if a > b
    min:= b;
else
    min:= a;
;
끝
```

![image](https://user-images.githubusercontent.com/53112143/180185105-4de4bdba-a97e-418e-9ffc-b7365780b9f3.png)

## `whileTest.cbu`


while문

```
시작
i:= 0;
sum:= 0;
while i <= 10
    sum:= sum 더하기 i;
    i:= i 더하기 1;
;
끝
```

![image](https://user-images.githubusercontent.com/53112143/180185421-0ed3f6f7-a9ba-44cc-bed0-77e7d5bb77e1.png)
