.text

.eqv PRINT_INT	1
.eqv PRINT_STR	4
.eqv EXIT		10
.eqv PRINT_CHAR	11
.eqv OPEN_FILE	13
.eqv READ_FILE	14
.eqv WRITE_FILE 15
.eqv CLOSE_FILE	16
.eqv EXIT_2		17
.eqv PRINT_HEX	34


.globl main

# 		MAPA DE REGISTRADORES
#	$sp ->	0($sp) -> input file  (input.bin)
#			4($sp) -> output file (output.txt)
#			8($sp) -> hexadecimal
main:
	addiu 	$sp, $sp, -12	# Allocate 12 bytes on the stack for 2 file descriptors

    la 		$a0, input_file	# Address of input file name
    li 		$a1, 0		# Flag for reading
    li 		$v0, OPEN_FILE		# System call for open
    syscall
    sw 		$v0, 0($sp)
    
    	slt   	$t0, $v0, $zero
    	bne   	$t0, $zero, open_error
    
   	# Store file descriptor of input file on stack

    la 		$a0, output_file # Address of output file name
    li 		$a1, 1		# Flag for writing
    add		$v0, $zero, OPEN_FILE
    syscall
	sw 		$v0, -4($sp)	# Store file descriptor of output file on stack
 
       	slt   	$t0, $v0, $zero
    	bne   	$t0, $zero, open_error

	addi	$t0, $zero, 0x00400000	#primeiro endereço de instrução
	sw		$t0, 8($sp)
    
    j 		check_file #lê arquivo de entrada em 4 em 4 bytes

save_file:
	lw		$a0, 8($sp)		#endereço da primeira instrução
	lw		$t1, -4($sp)		#endereço do arquivo de saída
	
	la		$a1, buffer			#carrega endereço do buffer
	jal		to_string			#procedimento que traduz o hex pra str
	#chama a funcao que converte o endereco que esta em $a0 para string
	# carrega e imprime o endereco que esta salvo na pilha
	move	$a0, $t1			# move o valor do arq de saida para a0
	la		$a1, buffer			# buffer
	addi	$a2, $zero, 10		# numero de bytes lidos
	addi	$v0, $zero, WRITE_FILE	# diretiva de escrita
	syscall
	## imprime espaço
	move	$a0, $t1
	la		$a1, str_space
	addi	$a2, $0, 1
	addi	$v0, $zero, WRITE_FILE
	syscall
	
	#incrementa o endereço da instrução em 4 bytes
	lw		$t0, 8($sp)
	addiu	$t0, $t0, 4
	sw		$t0, 8($sp)
	
endline_output:
	lw		$a0, -4($sp)
	la		$a1, str_end_line
	addi	$a2, $zero, 2
	addi	$v0, $zero, WRITE_FILE
	syscall
	
check_file:
	lw 		$a0, 0($sp) 	#descritor de arquivo
	addiu   $a1, $sp, 4 	# endereco onde a palavra vai ser salva
	li 		$a2, 4 			#bytes a serem lidos
	li 		$v0, READ_FILE
	syscall
	
		slti $t0, $v0, 4
		bne  $t0, $0, close_file
	
	j 		save_file

close_file:
	lw		$a0, 0($sp)
	addi 	$v0, $0, CLOSE_FILE
	syscall
	
	lw 		$a0, 4($sp)
	addi	$v0, $zero, CLOSE_FILE
	syscall
exit:
	addi	$a0, $zero, 0
	addi 	$v0, $zero, EXIT_2
	syscall

open_error:
	la		$a0, error_open
	addi	$v0, $zero, PRINT_STR
	syscall
	
	j exit
	
to_string:

	la		$a0, aqui
	addi	$v0, $zero, PRINT_STR
	syscall
	
	j exit
.data

## input test

output_file:		.asciiz "output.txt"
input_file:			.asciiz "input.bin"
error_open:			.asciiz "Erro na abertura do arquivo.\n"
sucesso:			.asciiz "sucesso\n"
aqui:	.asciiz "aqui"

buffer:				.space	1024

## basicos
hex_digits:			.asciiz "0123456789ABCDEF"
str_hex_zero:		.asciiz "0"
str_hex_x:			.asciiz "x"

## instrucoes:

### TIPO R ####
											##functs
str_add:			.asciiz "add "			#100000
str_addu:			.asciiz "addu"			#100001
str_and:			.asciiz "and "			#100100
str_break:			.asciiz "break "		#001101
str_div:			.asciiz "div "			#011010
str_divu:			.asciiz "divu"			#011011
str_jalr:			.asciiz "jalr"			#001001
str_jr:				.asciiz	"jr "			#001000
str_mfhi:			.asciiz "mfhi"			#010000
str_mflo:			.asciiz "mflo"			#010010
str_mthi:			.asciiz "mthi"			#010001
str_mtlo:			.asciiz	"mtlo "			#010011
str_mult:			.asciiz "mult " 		#011000
str_multu:			.asciiz "multu "		#011001
str_nor:			.asciiz "nor "			#100111
str_or:				.asciiz "or "			#100101
str_sll:			.asciiz "sll "			#000000
str_sllv:			.asciiz "sllv "			#000100
str_slt:			.asciiz "slt "			#101010
str_sltu:			.asciiz "sltu "			#101011
str_sra:			.asciiz "sra "			#000011
str_srav:			.asciiz "srav "			#000111
str_srl:			.asciiz "srl "			#000010
str_srlv:			.asciiz "srlv "			#000110
str_sub:			.asciiz "sub "			#100010
str_subu:			.asciiz "subu "			#100011
str_syscall:		.asciiz "syscall "		#001100
str_xor:			.asciiz "xor "			#100110


## type j

str_jal:			.asciiz "jal "			#000011
str_j:				.asciiz "j "			#000010


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
str_end_line:		.asciiz "\r\n"
str_space:			.asciiz " "
str_abre_par:		.asciiz "("
str_fecha_par:		.asciiz ")"
str_nao_instr:		.asciiz "Instrução não encontrada no sistema."
