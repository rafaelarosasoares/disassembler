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
#   0   -> output_file                  						#
#	4	-> input_file											#
#	8   -> 1º endereço	0040 0000 								#
#	s4  -> opcode												#
#	s0	-> hexadecimal para mascara								#
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
.eqv OPEN_FILE	13
.eqv READ_FILE	14
.eqv WRITE_FILE 15
.eqv CLOSE_FILE	16
.eqv EXIT_2		17
.eqv PRINT_HEX	34

.globl main

main:
	addiu		$sp, $sp, -12				#abre espaço na memória

	# abertura do arquivo para escrita
	
	addi 		$v0, $0, OPEN_FILE          	# open_file syscall code = 13
    la 			$a0, output_file     			# get the file name
    addi 		$a1, $0, 0           			# file flag = read (0)
   	syscall
    move 		$t1, $v0        				# save the file descriptor. $t1 = file
	
	slt   		$t0, $t1, $zero 				# caso houve erro na abertura, $v0 sera negativo
    bne   		$t0, $zero, open_error 			# se $t0 for 1, eh porque deu erro na abertura do arquivo
    
    addi		$v0, $0, PRINT_STR
    la			$a0, success_open
    syscall
    
    sw			$t1, 0($sp)						# arquivo para gravar
	
	# abertura do arquivo de leitura
	li   		$v0, OPEN_FILE # servico de abertura do arquivo
	la    		$a0, input_file # nome do arquivo
	li    		$a1, 0 # flag de leitura
	li    		$a2, 0 # modo
	syscall
	
	move 		$t1, $v0	
	
	slt   		$t0, $t1, $zero 			# caso houve erro na abertura, $s1 sera negativo
    bne   		$t0, $zero, open_error 		# $t0 = 1 -> deu erro na abertura do arquivo
    
    addi		$v0, $0, PRINT_STR
    la			$a0, success_open
    syscall
  
    sw			$t1, 4($sp)					#arquivo para ler
        
    addi   		$t2, $zero, 0x00400000 # endereco inicial das instrucoes
	sw			$t2, 8($sp)
    
    j 			read_word	# faz a leitura da palavra
    
##### MENSAGENS ##########

exit:
	addi	$v0, $zero, EXIT_2
	syscall

open_error:
	addi	$v0, $zero, PRINT_STR
	la		$a0, error_open
	syscall
	
	j exit

read_error:
	addi	$v0, $zero, PRINT_STR
	la		$a0, error_read
	syscall
	
	j exit

end_output:
	lw		$a0, 0($sp)		#descritor do arquivo de output
	la		$a1, str_end_line	#mensagem de instrução não encontrada no sitema
	addi	$a2, $0, 2			#qtd de bytes que serao escritos
	addi	$v0, $zero, WRITE_FILE
	syscall

read_word:
	# leitura do arquivo
	lw   		$a0, 0($sp)   # endereço salvo na pilha
    addiu 		$a1, $sp, 4   # endereco onde vai salvar a palavra
    addi    	$a2, $zero, 4        # numero de caracteres lidos
    addi    	$v0, $zero, READ_FILE
    syscall
        
    addi		$v0, $0, PRINT_STR
    la			$a0, success_read
    syscall
        
    #testa se foram lidos 4 bytes
    slti  		$t0, $v0, 4
    beq   		$t0, $zero, print_address # caso foram lidos 4 bytes, pula para a impressao do endereco em binário
    #senao
    j 			exit

print_address:
	lw    		$a0, 8($sp)		#carrega em $a0 o valor do primeiro endereço 0x0040 0000
	la    		$a1, buffer		#carrega o endereço do buffer
	jal   		hex_to_file #converte o endereco que esta em $a0 para str
	#carrega e imprime o endereco que esta salvo na pilha
	lw    		$a0, 0($sp) 	#carrega o arquivo de output
	la    		$a1, buffer		#carrega o endereço do buffer para escrita do arquivo
	addi  		$a2, $zero, 4 	#carrega o valor de bytes lidos 
	addi  		$v0, $zero, WRITE_FILE	#chama diretiva de escrita
	syscall
	#imprime espaco
	lw    		$a0, 0($sp) 
	la    		$a1, str_space
	addi  		$a2, $zero, 1
	addi    	$v0, $0, WRITE_FILE
	syscall
    #incrementa o endereco em 4
	lw    		$t0, 8($sp)
	addiu 		$t0, $t0, 4
	sw    		$t0, 8($sp)
	
hex_to_str:
## transforma o valor hexadecimal recebido da função anterior em uma string
	lw			$a0, 0($sp)
	la			$a1, buffer
	jal			hex_to_file

	lw			$a0, 0($sp)
	la			$a1, buffer
	addi		$a2, $zero, 10
	addi		$v0, $0, WRITE_FILE
	syscall
	
	lw			$a0, 0($sp)
	la			$a1, str_space
	addi 		$a2, $0, 1
	addi		$v0, $0, WRITE_FILE
	syscall
	
	j assembly_process
	
hex_to_file:
# args
#           $a0 -> valor que será convertido para uma str do hexadecimal
#           $a1 -> endereço da variável buffer que guardará uma str hexadecimal 
#                 do valor
#
	li			$t0, '0'
	sb			$t0, 0($a1)
	li			$t0, 'x'
	sb			$t0, 1($a1)
	addiu		$a1, $a1, 2		#arruma o ponteiro de a1 que é o endereço do buffer
	
	lui			$s0, 0xF000		#hexadecimal
	li			$s1, 28			#contador
	la			$s2, hex_digits	#carrega digitos hexadecimal do .data
	
	loop_hex:			
		#le de 4 em 4 para encontrar a instrução final em hexadecimal e transforma-la em str
		#obtem o nibble do valor binario para converter
		# shift right logical variable -> $s3 -> valor do hexadecimal atual
		# srlv de 32/28 bits -> 00000000000000000000000000001111
		and 	$s3, $a0, $s0		# and n valor convertido para hexadecimal e o hexadecimal para aplicacao da mascara
		srlv  	$s3, $s3, $s1		# shift right, 
		add		$s3, $s3, $s2		#encontra endereço do valor hexadecimal atual + o endereço inicial da instrucao
		
		lb		$s3, 0($s3)			#salva no primeiro espaço de s3 na pilha os primeiros bits
		sb		$s3, 0($a1)			#guarda no buffer o nibble
		
		addi	$a1, $a1, 1			#atualiza o ponteiro do buffer para a próxima posição
		addi	$s1, $s1, -4		#decrementa em 4 o contador para o srlv
		srl 	$s0, $s0, 4			#ajusta a máscara para o próximo nibble
		
		#se o contador = 0 || máscara = 0x00000000 então todos nibbles foram acessados e processaddos
		
		bne		$s1, $0, loop_hex
		lb		$0, 0($a1)
	
		jr 		$ra
		
assembly_process:

	lw			$s5, 0($sp)
	srl 		$s4, $t0, 26
	#descobre opcode
	
	#tipo r -> opcode == 0
	beq			$s4, $zero, type_r
	
	#tipo j -> opcode == 2 && == 3
	beq			$s4, 0x02, type_j_j
	beq			$s4, 0x03, type_j_jal
	
	#tipo i -> opcode =- 4 p cima
	

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
	#beq		$t0, 0x21, funct_addu
	#beq		$t0, 0x22, funct_sub
	#beq		$t0, 0x23, funct_subu
	#beq		$t0, 0x24, funct_and
	#beq		$t0, 0x0D, funct_break
	#beq		$t0, 0x1A, funct_div 
	#beq		$t0, 0x1B, funct_divu
	#beq		$t0, 0x09, funct_jalr
	#beq		$t0, 0x08, funct_jr
	#beq		$t0, 0x10, funct_mfhi
	#beq		$t0, 0x12, funct_mflo
	#beq		$t0, 0x11, funct_mthi
	#beq		$t0, 0x13, funct_mtlo
	#beq		$t0, 0x18, funct_mult
	#beq		$t0, 0x19, funct_multu
	#beq		$t0, 0x27, funct_nor
	#beq		$t0, 0x25, funct_or
	#beq 	$t0, 0x00, funct_sll
	#beq		$t0, 0x04, funct_sllv
	#beq		$t0, 0x2A, funct_slt
	#beq		$t0, 0x2B, funct_sltu
	#beq		$t0, 0x03, funct_sra
	#beq		$t0, 0x07, funct_srav
	#beq		$t0, 0x02, funct_srl
	#beq		$t0, 0x06, funct_srlv
	#beq		$t0, 0x0C, funct_syscall
	#beq		$t0, 0x26, funct_xor
	
	lw		$a0, 0($sp)		#descritor do arquivo de output
	la		$a1, str_nao_instr	#mensagem de instrução não encontrada no sitema
	addi	$a2, $0, 37			#qtd de bytes que serao escritos
	addi	$v0, $zero, WRITE_FILE
	syscall
	
	j end_output
	
	
###  functs  ###

	funct_add:
	
		lw	$a0, 0($sp)
		la	$a1, str_add
		addi $a2, $zero, 4
		addi $v0, $zero, WRITE_FILE
		syscall
		
		jal check_regs


#############TIPO J###################
type_j_jal:

type_j_j:


##############TIPO I###################
type_i:


check_regs:

close_file:

	la		$t0, 0($sp)
	addi	$v0, $zero, CLOSE_FILE
	move	$a0, $t0
	syscall

	la		$t0, 4($sp)
	addi	$v0, $zero, CLOSE_FILE
	move	$a0, $t0
	syscall

.data

# arquivos
input_file:			.asciiz "input.bin"
output_file:		.asciiz "output.txt"
binary_file:		.asciiz "binary.txt"
error_open:			.asciiz "Erro na abertura do arquivo.\n"	
success_open:		.asciiz "Arquivo aberto com sucesso.\n"
error_read:			.asciiz "Erro na leitura do arquivo.\n"
success_read:		.asciiz "Sucesso na leitura do arquivo.\n"
error_write:		.asciiz "Erro na escrita do arquivo.\n"
success_write:		.asciiz "Sucesso na escrita do arquivo.\n"
buffer:				.space	102400
file_input_msg:		.asciiz "Arquivo de leitura:\n"
file_output_msg:	.asciiz "Arquivo gravado:\n"

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

