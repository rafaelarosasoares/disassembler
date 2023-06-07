#################################################################
#Disassembler - T1 2023/1										#
#Feito por:														#			
#																#
#	Rafaela da Rosa Soares										#
#	Giordana Camargo											#
#																#
#################################################################
#																#
# 					##		reg_map:		##			 		#
#																#
#################################################################
#																#
#	Mapa de registradores:										#
#																#
#	$s0 -> output_file 											#
#	$s1	-> input_file											#
#	$s3 -> 1º endereço	0040 0000								#
#																#
#																#
#																#
#																#
#																#
#################################################################

.text

.eqv PRINT_INT	1
.eqv PRINT_STR	4
.eqv READ_INT	5
.eqv READ_STR	8
.eqv EXIT		10
.eqv PRINT_CHAR	11
.eqv EXIT_2		17
.eqv PRINT_HEX	34

.globl main
main:

	jal files
	
	
compare_opcode:

type_i:

type_r:

type_j:

.data

open_error:

addi	$v0, $zero, PRINT_STR
la		$a0, error_open
syscall

exit:

addi	$v0, $zero, EXIT_2
syscall

## basicos
any_value:			.asciiz "00000000000000000000000000000000"

## instrucoes:

str_add:			.asciiz "add "
str_addi:			.asciiz "addi "
str_addiu:			.asciiz "addiu "
str_and:			.asciiz "and "
str_beq:			.asciiz "beq "
str_bne:			.asciiz "bne "
str_jr:				.asciiz "jr "

## registradores

str_r0:				.asciiz "$zero"
str_r1:				.asciiz "$at"
str_r2:				.asciiz "$v0"
str_r3:				.asciiz "$v1"
str_r4:				.asciiz "$a0"
str_r5:				.asciiz "$a1"
str_r6:				.asciiz "$a2"
str_r7:				.asciiz "$a3"
str_r8:				.asciiz "$t0"
str_r9:				.asciiz "$t1"
str_r10:			.asciiz "$t2"
str_r11:			.asciiz "$t3"
str_r12:			.asciiz "$t4"
str_r13:			.asciiz "$t5"
str_r14:			.asciiz "$t6"
str_r15:			.asciiz "$t7"
str_r16:			.asciiz "$s0"
str_r17:			.asciiz "$s1"
str_r18:			.asciiz "$s2"
str_r19:			.asciiz "$s3"
str_r20:			.asciiz "$s4"
str_r21:			.asciiz "$s5"
str_r22:			.asciiz "$s6"
str_r23:			.asciiz "$s7"
str_r24:			.asciiz "$t8"
str_r25:			.asciiz "$t9"
str_r26:			.asciiz "$k0"
str_r27:			.asciiz "$k1"
str_r28:			.asciiz "$gp"
str_r29:			.asciiz "$sp"
str_r30:			.asciiz "$fp"
str_r31:			.asciiz "$ra"

#strings

str_virgula:		.asciiz ","
str_new_line:		.asciiz "\r\n"
str_space:			.asciiz " "
str_abre_par:		.asciiz "("
str_fecha_par:		.asciiz ")"
str_nao_instr:		.asciiz "Instrução não encontrada no sistema."


## mascaras
mask_opcode: 		.byte	1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_rd:			.byte	0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_rs:			.byte	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_rt:			.byte	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
mask_shamt:			.byte	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
mask_funct:			.byte	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1
mask_imm:			.byte	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
mask_immj:			.byte	0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

.include "include/hex_to_bin.asm"
.include "files.asm"