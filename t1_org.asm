.text

.eqv PRINT_INT	1
.eqv PRINT_STR	4
.eqv READ_INT	5
.eqv READ_STR	8
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
	addi	$sp, $sp, -12
	
	## ARQUIVO DE ENTRADA - ABERTURA
	addi	$v0, $zero, OPEN_FILE	#diretiva para abertura de arquivo
	la		$a0, input_file			#arquivo a ser aberto
	addi	$a1, $zero, 0					#modo de leitura (0)
	syscall
	
	slt   	$t0, $v0, $zero
    bne   	$t0, $zero, open_error 			
	
	sw		$v0, 0($sp)
	
	## ARQUIVO DE SAÍDA - ABERTURA
	
	add		$v0, $zero, OPEN_FILE	#diretiva para abertura de arquivo
	la		$a0, output_file		#arquivo a ser aberto
	addi	$a1, $zero, 1					#modo de escrita (1)
	syscall
	
	slt   	$t0, $v0, $zero
    bne   	$t0, $zero, open_error
	
	sw		$v0, 4($sp)
	
	addi	$t0, $zero, 0x00400000	#primeiro endereço de instrução
	sw		$t0, 8($sp)
	
	addi	$v0, $zero, PRINT_STR
	la		$a0, sucesso
	syscall
	
	addi	$sp, $sp, 12		#fecha pilha
	
	j check_file
	
assembly_process:
	lw			$s5, 0($sp)
	srl 		$s4, $s5, 26
	#descobre opcode
	
	#tipo r -> opcode == 0
	beq			$s4, $zero, type_r

	#opcode = 1
	beq			$s4, 0x01, opcode_1
	#opcode = 1c		
	beq			$s4, 0x1c, opcode_1c
					
	#tipo j -> opcode == 2 && == 3
	beq			$s4, 0x02, type_j_j
	beq			$s4, 0x03, type_j_jal
	
	#tipo i -> opcode


save_file:
	addi	$sp, $sp, -12
	lw		$a0, -8($sp)		#endereço da primeira instrução
	lw		$t1, -4($sp)		#endereço do arquivo de saída
	
	la		$a1, buffer			#carrega endereço do buffer
	jal		to_string			#procedimento que traduz o hex pra str
	#chama a funcao que converte o endereco que esta em $a0 para string
	# carrega e imprime o endereco que esta salvo na pilha
	move	$a0, $t1			# move o valor do arq de saida para a0
	la		$a1, buffer			# buffer
	addi	$a2, $zero, 4		# numero de bytes lidos
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
	
print_assembly:
	# converte o codigo de maquina que esta em hexa para string
	lw		$a0, -4($sp)		# carrega arquivo de output
	la		$a1, buffer
	jal 	to_string

	lw			$a0, -4($sp)
	la			$a1, buffer
	addi		$a2, $zero, 10
	addi		$v0, $0, WRITE_FILE
	syscall
	
	lw			$a0, -4($sp)
	la			$a1, str_space
	addi 		$a2, $0, 1
	addi		$v0, $0, WRITE_FILE
	syscall
	
	j assembly_process 
	
##############TRATAMENTO DE TIPOS#####################

##############TIPO R##################
type_r:
	
#  opcode    rs      rt       rd      sa      fn
#  31-26   25-21   20-16    15-11    10-6    5-0
	
	#shift left pra isolar o funct de 0 a 6 
	sll		$t0, $s5, 26
	#shift right pra isolar o fn de 0 a 6
	srl		$t0, $t0, 26
	
	## comparação para ver se o funct não é uma das instruções abaixo
	beq		$t0, 0x20, funct_add
	beq		$t0, 0x21, funct_addu
	beq		$t0, 0x22, funct_sub
	beq		$t0, 0x23, funct_subu
	beq		$t0, 0x24, funct_and
	beq		$t0, 0x0D, funct_break
	beq		$t0, 0x1A, funct_div 
	beq		$t0, 0x1B, funct_divu
	beq		$t0, 0x09, funct_jalr
	beq		$t0, 0x08, funct_jr
	beq		$t0, 0x10, funct_mfhi
	beq		$t0, 0x12, funct_mflo
	beq		$t0, 0x11, funct_mthi
	beq		$t0, 0x13, funct_mtlo
	beq		$t0, 0x18, funct_mult
	beq		$t0, 0x19, funct_multu
	beq		$t0, 0x27, funct_nor
	beq		$t0, 0x25, funct_or
	beq 	$t0, 0x00, funct_sll
	beq		$t0, 0x04, funct_sllv
	beq		$t0, 0x2A, funct_slt
	beq		$t0, 0x2B, funct_sltu
	beq		$t0, 0x03, funct_sra
	beq		$t0, 0x07, funct_srav
	beq		$t0, 0x02, funct_srl
	beq		$t0, 0x06, funct_srlv
	beq		$t0, 0x0C, funct_syscall
	beq		$t0, 0x26, funct_xor
	
	lw		$a0, 0($sp)		#descritor do arquivo de output
	la		$a1, str_nao_instr	#mensagem de instrução não encontrada no sitema
	addi	$a2, $0, 37			#qtd de bytes que serao escritos
	addi	$v0, $zero, WRITE_FILE
	syscall
	
	j endline_output
	
###  functs  ###

	funct_add:
	
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
		
	funct_addu:
	
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_and:
	
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output

	funct_break:
	
	funct_div: 
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_divu:
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
		
	funct_jalr:
	
	funct_jr:
	
	funct_mfhi:
	
	funct_mflo:
	
	funct_mthi:
	
	funct_mtlo:
	
	funct_mult:
	
	funct_multu:
	
	funct_nor:
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_or:
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_sub: 
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_subu:
		lw	$a0, -4($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $0, 1
		addi $v0, $0, WRITE_FILE
		syscall
		
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	


#############TIPO J###################
type_j_jal:

type_j_j:


##############TIPO I###################
type_i:


check_regs:
	beq	$t0, 0x00, reg00	#zero
	beq	$t0, 0x01, reg01 	#at
	beq $t0, 0x02, reg02

endline_output:
	addi	$v0, $zero, PRINT_STR
	la		$a0, str_end_line
	syscall
	
check_file:
	## LÊ ARQUIVO DE ENTRADA - de 4 em 4 bytes
	addi	$sp, $sp, -12	#abre a pilha
	lw		$t0, 0($sp)		#carrega em $t0 o arquivo de input 
	
	addi	$v0, $zero, READ_FILE
	move	$a0, $t0	#move o endereço do input para $a0 para chamar a diretiva de leitura
	la		$a1, buffer
	addi	$a2, $zero, 4 # quantidade de bytes a serem lidos por vez
	syscall
	
	slti	$t1, $v0, 4	#checa se 4 bytes foram lidos
	beq		$t0, $0, save_file		# se sim, salva arquivo
	# se nao
	j close_file

close_file:
	
exit:
	addi 	$v0, $zero, EXIT_2
	syscall

open_error:
	addi	$v0, $zero, PRINT_STR
	la		$a0, error_open
	syscall
	
	j exit
	
	
to_string:
	#a0 -> valor para conversão
	#a1 -> endereço do valor para conversão
	
	# trecho que escreve "0x" na parte inicial da instrução
	li		$t0, '0'
	sb		$t0, 0($a1)
	li		$t0, 'x'
	sb		$t0, 1($a1)
	addiu	$a1, $a1, 2		# aponta para a nova posição do vetor de str
	
	lui		$s0, 0XF000		#hexadecimal de máscara
	li		$t0, 28			#contador que será decrementado de 4 em 4 pra representar a leitura dos bits do hexadecimal
	la		$t1, hex_digits	#digitos de hexadecimal declarados no .data
	
	#parte que converterá trecho para string
	loop_str:
		#obtem o nibble
		# srlv para conseguir de 4 em 4
		
		and	$s1, $a0, $s0
		srlv $s1, $s1, $t0
		add	$s1, $s1, $t1
		
		lb	$s1, 0($s1)
		sb	$s1, 0($s1) 
		
		addi $a1, $a1, 1 	#incrementa em 1 o ponteiro do endereço do valor de conversao
		addi $t0, $t0, -4	# decrementa do contador 4 bits
		srl $s0, $s0, 4		#ajusta a máscara
		
		bne	$s0, $zero, loop_str	#se a máscara for diferente de 0, continua chamando funcao
		lb 	$0, 0($a1)				#zera o endereço da instrucao para ir pra proxima instrucao e reiniciar a conversão
		
	jr	$ra

.data

## input test

output_file:		.asciiz "output.txt"
input_file:			.asciiz "input.bin"
error_open:			.asciiz "Erro na abertura do arquivo.\n"
sucesso:			.asciiz "sucesso\n"

buffer:				.space	128

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
