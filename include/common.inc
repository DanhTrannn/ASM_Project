%define LC_ALL 6

%define KEY_DOWN 258
%define KEY_UP 259
%define KEY_NPAGE 338
%define KEY_PPAGE 339

%define A_REVERSE 0x40000
%define COLOR_PAIR_1 0x100
%define COLOR_PAIR_2 0x200
%define COLOR_PAIR_3 0x300
%define COLOR_PAIR_4 0x400

%define TRUE 1
%define FALSE 0

%macro ccall 1
	xor eax, eax
	call %1
%endmacro
