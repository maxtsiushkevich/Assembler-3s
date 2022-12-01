// Ввести массив чисел с плавающей точкой на 10 элементов. Для каждого 
// элемента массива вычислить: { если Xi < 0, то Хi = (Xi)^2
// если Xi 

#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <iostream>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <locale.h>

#define SIZE 10
using namespace std;

int main()
{
	setlocale(LC_ALL, "ru");
	int flag = 1;
	double zero = 0.0;

	do
	{
		int count = 0;
		double arr[SIZE];
		double resultArr[SIZE] = { 0,0,0,0,0,0,0,0,0,0 };

		try {
			printf("Введите массив:\n");
			for (int i = 0; i < SIZE; i++)
			{
				printf("\[%d] = ", i);
				while (!scanf("%lf", &arr[i]))
					rewind(stdin);
				rewind(stdin);
			}
			double sizeOfArr = SIZE;
			double step = 1;
			double i = 0;
			_asm
			{
				finit;
				fld sizeOfArr
					mov esi, 0
					fld i;
			loop_start:
					fcom
					fstsw ax 
					and ah, 01000101b
					je loop_end
					fld[arr + esi]
					fcom zero
					fstsw ax
					and ah, 01000101b;
					je greaterZ
					jmp lessZ
			greaterZ :
					fmul[arr + esi]
					fstsw ax
					and al, 00001000b
					jne overflow
					fmul[arr + esi]
					fstsw ax
					and al, 00001000b
					jne overflow
					fstp[resultArr + esi]
					jmp next_step;
			lessZ:
					fmul[arr + esi]
					fstsw ax
					and al, 00001000b
					jne overflow
					fstp[resultArr + esi]
					jmp next_step
			next_step :
					fadd step
					fst i
					add esi, 8
					jmp loop_start
			overflow :
				fwait
			}
			throw new overflow_error("Переполнение!");
			_asm
			{
				loop_end:
				fwait
			}
			printf("\n");
			for (int i = 0; i < SIZE; i++)
			{
				printf("[%d] = %.3lf  \n", i, resultArr[i]);
			}

		}
		catch (overflow_error ex)
		{
			cout << ex.what() << endl;
			break;
		}
		catch (...)
		{
			cout << "Неверный ввод!" << endl;
			break;
		}

		system("pause");
		system("CLS");
	} while (flag);
	system("cls");
	system("pause");
	return 0;
}
