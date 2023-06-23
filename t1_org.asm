#
#	DISASSEMBLER
#
#	POR RAFAELA DA ROSA SOARES
#	ORGANIZACAO DE COMPUTADORES
#	MATRÍCULA 202211338
#

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

assembly_process:
	lw			$s5, -4($sp)
	srl 		$s4, $s5, 26
	#descobre opcode
	
	addi	$v0, $0, 1
	add		$a0, $zero, $s4
	syscall
	
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
	
	#else
	lw			$a0, -4($sp)
	la			$a1, str_nao_instr
	addi		$a2, $zero, 37
	addi		$v0, $zero, WRITE_FILE
	syscall
	
	j endline_output


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
	
endline_output:
	lw		$a0, -4($sp)
	la		$a1, str_end_line
	addi	$a2, $zero, 2
	addi	$v0, $zero, WRITE_FILE
	syscall
	
check_file:
	## LÊ ARQUIVO DE ENTRADA - de 4 em 4 bytes
	lw     	$a0, 0($sp)   # descritor que esta salvo na pilha
    addiu	$a1, $sp, 4   # endereco onde vai salvar a palavra
    addi	$a2, $0, 4        # numero de caracteres lidos
    addi  	$v0, $0, READ_FILE
    syscall

    # Verifica se foram lidos 4 bytes
    beq $v0, $zero, close_file  # se não foram lidos nenhum byte, pula para close_file

	j save_file
	
close_file:
	lw		$a0, 0($sp)
	addi 	$v0, $0, CLOSE_FILE
	syscall
	
	lw 		$a0, -4($sp)
	addi	$v0, $zero, CLOSE_FILE
	syscall
	
exit:
	addi	$a0, $zero, 0
	addi 	$v0, $zero, EXIT_2
	syscall
	
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
	
### opcodes  ###

	opcode_1:

	opcode_1c:


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
		la	$a1, str_addu
		addi $a2, $zero, 5
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
		la	$a1, str_and
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
		lw	$a0, -4($sp)
		la	$a1, str_break
		addi $a2, $zero, 6
		addi $v0, $zero, WRITE_FILE
		syscall
		
		j endline_output
		
	funct_div: 
		lw	$a0, -4($sp)
		la	$a1, str_div
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
		la	$a1, str_divu
		addi $a2, $zero, 5
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
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
		
	funct_jalr:
		lw	$a0, -4($sp)
		la	$a1, str_jalr
		addi $a2, $zero, 5
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
		
		j endline_output
	
	funct_jr:
		lw	$a0, -4($sp)
		la	$a1, str_jr
		addi $a2, $zero, 3
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		j endline_output
	
	funct_mfhi:
		lw	$a0, -4($sp)
		la	$a1, str_mfhi
		addi $a2, $zero, 5
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		j endline_output
	
	funct_mflo:
		lw	$a0, -4($sp)
		la	$a1, str_mflo
		addi $a2, $zero, 5
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		j endline_output
	
	funct_mthi:
		lw	$a0, -4($sp)
		la	$a1, str_mthi
		addi $a2, $zero, 5
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		j endline_output
	
	funct_mtlo:
		lw	$a0, -4($sp)
		la	$a1, str_mtlo
		addi $a2, $zero, 5
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		j endline_output
		
	funct_mult:
		lw	$a0, -4($sp)
		la	$a1, str_mult
		addi $a2, $zero, 5
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
		
	funct_multu:
		lw	$a0, -4($sp)
		la	$a1, str_multu
		addi $a2, $zero, 6
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#isola o rs 
		sll	$t0, $s5, 6
		srl	$t0, $t0, 27	
		jal check_regs
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_nor:
		lw	$a0, -4($sp)
		la	$a1, str_nor
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
		la	$a1, str_or
		addi $a2, $zero, 3
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
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_sll:
		lw $a0, -4($sp)
		la $a1, str_sll
		addi $a2, $zero, 4
		addi $v0, $0, WRITE_FILE
		
		##rd
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		#calcula shamt
		sll $t0, $s5, 11
		srl $t0, $t0, 27
		
		la	$a0, -4($sp)
		move $a1, $t0
		addi $a2, $zero, 3
		addi $v0, $0, WRITE_FILE
		
		j endline_output

	funct_sllv:
		lw	$a0, -4($sp)
		la	$a1, str_sllv
		addi $a2, $zero, 5
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
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output	
	
	funct_slt:
		lw	$a0, -4($sp)
		la	$a1, str_slt
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
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_sltu:
		lw	$a0, -4($sp)
		la	$a1, str_sltu
		addi $a2, $zero, 5
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
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_sra:
		lw $a0, -4($sp)
		la $a1, str_sra
		addi $a2, $zero, 4
		addi $v0, $0, WRITE_FILE
		
		##rd
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		#calcula shamt
		sll $t0, $s5, 11
		srl $t0, $t0, 27
		
		la	$a0, -4($sp)
		move $a1, $t0
		addi $a2, $zero, 3
		addi $v0, $0, WRITE_FILE
		
		j endline_output
	
	funct_srav: 
		lw	$a0, -4($sp)
		la	$a1, str_srav
		addi $a2, $zero, 5
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
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output
	
	funct_srl:
		lw $a0, -4($sp)
		la $a1, str_srl
		addi $a2, $zero, 4
		addi $v0, $0, WRITE_FILE
		
		##rd
		sll $t0, $s5, 16
		srl $t0, $t0, 27
		jal check_regs	# identifica os registradores
		
		lw	$a0, -4($sp)
		la	$a1, str_virgula
		addi $a2, $zero, 1
		addi $v0, $zero, WRITE_FILE
		syscall
		
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		#calcula shamt
		sll $t0, $s5, 11
		srl $t0, $t0, 27
		
		la	$a0, -4($sp)
		move $a1, $t0
		addi $a2, $zero, 3
		addi $v0, $0, WRITE_FILE
		
		j endline_output
	
	
	funct_srlv:
		lw	$a0, -4($sp)
		la	$a1, str_srlv
		addi $a2, $zero, 5
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
		#rt
		sll	$t0, $s5, 11
		srl	$t0, $t0, 27
		jal check_regs	
		
		j endline_output	
	
	funct_sub: 
		lw	$a0, -4($sp)
		la	$a1, str_sub
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
		la	$a1, str_subu
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
	
	funct_syscall:
		lw	$a0, -4($sp)
		la	$a1, str_syscall
		addi $a2, $zero, 8
		addi $v0, $zero, WRITE_FILE
		syscall
	
	funct_xor:
		lw 	$a0, -4($sp)
		la	$a1, str_xor
		addi $a2, $zero, 4
		addi $v0, $0, WRITE_FILE
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
		lw $a0, -4($sp)
		la $a1, str_jal
		addi $a2, $0, 4
		addi $v0, $0, WRITE_FILE
		syscall
	
		j check_j_address
	
	type_j_j:
		lw $a0, -4($sp)
		la $a1, str_j
		addi $a2, $0, 4
		addi $v0, $0, WRITE_FILE
		syscall
	
		j check_j_address

##############TIPO I###################
	type_i:



######## registradores, imediates & endereço de procedimentos #######

check_j_address:

	sll	$t1, $s5, 6
	srl $t1, $t1, 6
	
	move $a0, $t1
	la 	$a1, buffer
	jal to_string
	
	lw 	$a0, -4($sp)
	la 	$a1, buffer
	addi $a2, $0, 10
	addi $v0, $zero, WRITE_FILE
	syscall
	
	j endline_output

check_regs:
	beq	$t0, 0x00, reg00	#zero
	beq	$t0, 0x01, reg01 	#at
	beq $t0, 0x02, reg02
	beq $t0, 0x03, reg03
	beq $t0, 0x04, reg04
	beq $t0, 0x05, reg05
	beq $t0, 0x06, reg06
	beq $t0, 0x07, reg07
	beq $t0, 0x08, reg08
	beq $t0, 0x09, reg09
	
	
	
reg00:

		lw $a0, -4($sp)
		la $a1, str_r0
		addi $a2, $0, 5
		addi $v0, $0, WRITE_FILE
		syscall

reg01:
		lw $a0, -4($sp)
		la $a1, str_r1
		addi $a2, $0, 3
		addi $v0, $0, WRITE_FILE
		syscall

reg02:
		lw $a0, -4($sp)
		la $a1, str_r2
		addi $a2, $0, 3
		addi $v0, $0, WRITE_FILE
		syscall

reg03:
reg04:
reg05:
reg06:
reg07:
reg08:
reg09:

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
		
		lbu	$s1, 0($s1)
		sb	$s1, 0($a1) 
		
		addiu $a1, $a1, 1 	#incrementa em 1 o ponteiro do endereço do valor de conversao
		addiu $t0, $t0, -4	# decrementa do contador 4 bits
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
fd:					.space 	32

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
