.text

.eqv PRINT_STR	4
.eqv OPEN_FILE	13
.eqv READ_FILE	14
.eqv WRITE_FILE 15
.eqv EXIT_2		17

.globl files

files:
#prologo
addiu	$sp, $sp, -16		#abre espaço na memória
lw		$s0, -12($sp)
lw		$s1, -8($sp)
lw		$s2, -4($sp)
lw		$ra, 0($sp)

#abertura do arquivo de escrita
addi	$v0, $0, OPEN_FILE	#serviço de abertura de arquivo
la		$a0, output_file	#arquivo para escrita
addi 	$a1, $0, 1			#flag de escrita
addi	$a2, $0, 0			#modo
syscall

move	$s0, $v0			#arquivo de escrita

slt		$t0, $s0, $zero
bne		$t0, $zero, open_error

#abertura do arquivo para leitura
addi	$v0, $0, OPEN_FILE
la		$a0, input_file 	#arquivo para leitura
addi	$a1, $0, 0			#flag de leitura 
addi	$a2, $0, 0			#modo
syscall

move	$s1, $v0			#arquivo de leitura

slt		$t0, $s1, $zero		#se for negativo, t0 ->1
bne		$t0, $zero,	open_error

#lê arquivo de entrada
addi	$v0, READ_FILE
move	$a0, $s1
la		$a1, buffer
la		$a2, 1024
syscall

impressao (file_input_msg)
impressao (input_file)

#addi	$s2, $zero, 0x00400000		#primeiro endereço das instrucoes

#epilogo
addi	$sp, $sp, 16
sw		$s0, 12($sp)
sw		$s1, 8($sp)
sw		$s2, 4($sp)
sw		$ra, 0($sp)

jr $ra

	.macro impressao (%required_text)
		addi	$v0, $0, PRINT_STR
		la		$a0, %required_text
		syscall
	.end_macro
	
.data

input_file:			.asciiz "t1_org/input.bin"
output_file:		.asciiz "t1_org/output.txt"
binary_file:		.asciiz "binary.txt"
error_open:			.asciiz "Erro na abertura do arquivo."	
success_open:		.asciiz "Arquivo aberto com sucesso."
error_write:		.asciiz "Erro na escrita do arquivo."
sucess_write:		.asciiz "Sucesso na escrita do arquivo."
buffer:				.space	1024
file_input_msg:		.asciiz "Arquivo de leitura:\n"
file_output_msg:	.asciiz "Arquivo gravado:\n"
