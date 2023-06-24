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

	main:
	lw	$t0, inst_subu
	sw	$t0, 0($sp)
	li  $t0,  0x00400000
	sw  $t0, 4($sp) # primeira instrução
	
	assembly_process:
	lw			$s5, 0($sp)
	srl 		$s4, $s5, 26
	#descobre opcode
	
	la		$a0, str_end_line
	addi	$v0, $zero, PRINT_STR
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
	beq			$s4, 0x04, type_i_beq
	beq			$s4, 0x05, type_i_bne
	beq			$s4, 0x06, type_i_blez
	beq			$s4, 0x07, type_i_bgtz
	beq			$s4, 0x08, type_i_addi
	beq			$s4, 0x09, type_i_addiu
	beq			$s4, 0x0A, type_i_slti
	beq			$s4, 0x0B, type_i_sltiu
	beq			$s4, 0x0C, type_i_andi
	beq			$s4, 0x0D, type_i_ori
	beq			$s4, 0x0E, type_i_xori
	beq			$s4, 0x0F, type_i_lui
	beq			$s4, 0x20, type_i_lb
	beq			$s4, 0x21, type_i_lh
	beq			$s4, 0x22, type_i_lwl
	beq			$s4, 0x23, type_i_lw
	beq			$s4, 0x24, type_i_lbu
	beq			$s4, 0x25, type_i_lhu
	beq			$s4, 0x26, type_i_lwr
	beq			$s4, 0x28, type_i_sb
	beq			$s4, 0x29, type_i_sh
	beq			$s4, 0x2A, type_i_swl
	beq			$s4, 0x2B, type_i_sw
	beq			$s4, 0x2E, type_i_swr
	
	#else
	la			$a0, str_nao_instr
	addi		$v0, $zero, PRINT_STR
	syscall
	
	j endline_output
	
endline_output:
	la		$a0, str_end_line
	addi	$v0, $zero, PRINT_STR
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
	
	la		$a0, str_nao_instr	#mensagem de instrução não encontrada no sitema
	addi	$v0, $zero, PRINT_STR
	syscall
	
	j endline_output
	
### opcodes  ###

	opcode_1:

	opcode_1c:

###  functs  ###

	funct_add:
	
		la	$a0, str_add
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		j endline_output
		
	funct_addu:
	
		la	$a0, str_addu
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output
	
	funct_and:
	
		la	$a0, str_and
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		j endline_output

	funct_break:
		la	$a0, str_break
		addi $v0, $zero, PRINT_STR
		syscall
		
		j endline_output
		
	funct_div: 
		la	$a0, str_div
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output
	
	funct_divu:
		la	$a0, str_divu
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output
		
	funct_jalr:
		la	$a0, str_jalr
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		j endline_output
	
	funct_jr:
		la	$a0, str_jr
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		j endline_output
	
	funct_mfhi:
		la	$a0, str_mfhi
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		j endline_output
	
	funct_mflo:
		lw	$a0, -4($sp)
		la	$a1, str_mflo
		addi $a2, $zero, 5
		addi $v0, $zero, WRITE_FILE
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		j endline_output
	
	funct_mthi:
		la	$a0, str_mthi
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		j endline_output
	
	funct_mtlo:
		la	$a0, str_mtlo
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		j endline_output
		
	funct_mult:
		la	$a0, str_mult
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output
		
	funct_multu:
		la	$a0, str_multu
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		j endline_output
	
	funct_nor:
		la	$a0, str_nor
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output
	
	funct_or:
		la	$a0, str_or
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		j endline_output
	
	funct_sll:
		la	$a0, str_sll
		addi $v0, $zero, PRINT_STR
		syscall
		
		##rd
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#calcula shamt
		sll $t0, $s5, 11
		srl $t0, $t0, 27
		
		move $a0, $t0
		addi $v0, $0, PRINT_INT
		syscall
		
		j endline_output

	funct_sllv:
		la	$a0, str_sllv
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output	
	
	funct_slt:
		la	$a0, str_slt
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		j endline_output
	
	funct_sltu:
		la	$a0, str_sltu
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output
	
	funct_sra:
		la	$a0, str_sra
		addi $v0, $zero, PRINT_STR
		syscall
		
		##rd
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		#calcula shamt
		srl $t0, $s5, 6
		andi $t0, $t0, 0x1F

		move $a0, $t0
		addi $v0, $0, PRINT_INT
		syscall
		j endline_output
	
	funct_srav: 
		la	$a0, str_srav
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		j endline_output
	
	funct_srl:
		la	$a0, str_srl
		addi $v0, $zero, PRINT_STR
		syscall
		
		##rd
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		#calcula shamt
		srl $t0, $s5, 6
		andi $t0, $t0, 0x1F

		move $a0, $t0
		addi $v0, $0, PRINT_INT
		syscall
		
		j endline_output
	
	
	funct_srlv:
		la	$a0, str_srlv
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output	
	
	funct_sub: 
		la	$a0, str_sub
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output
	
	funct_subu:
		la	$a0, str_subu
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		j endline_output
	
	funct_syscall:
		la	$a0, str_syscall
		addi $v0, $zero, PRINT_STR
		syscall
	
	funct_xor:
		la	$a0, str_xor
		addi $v0, $zero, PRINT_STR
		syscall
		
		# isola o registrador destino
		srl $t0, $s5, 11
		andi $t0, $t0, 0x1F
		move $a0, $t0 
		jal check_regs	# identifica os registradores
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs	
		
		j endline_output

#############TIPO J###################
	type_j_jal:
		la $a0, str_jal
		addi $v0, $0, PRINT_STR
		syscall
	
		j check_j_address
	
	type_j_j:
		la $a0, str_j
		addi $v0, $0, PRINT_STR
		syscall
	
		j check_j_address

##############TIPO I###################
	type_i_beq:
	
		la $a0, str_beq
		addi $v0, $0, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		j imm_ext
	
	type_i_bne:
	type_i_blez:
	type_i_bgtz:
	
	type_i_addi:
	
		la $a0, str_addi
		addi $v0, $0, PRINT_STR
		syscall
		
		#rt
		srl	$t0, $s5, 16
		andi $t0, $t0, 0x1F
		move $a0, $t0
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		#isola o rs 
		srl	$t0, $s5, 21
		
		andi $t0, $t0, 0X1F
		move $a0, $t0	
		jal check_regs
		
		la	$a0, str_virgula
		addi $v0, $zero, PRINT_STR
		syscall
		
		j	check_immediate
		
	type_i_addiu:
	type_i_slti:
	type_i_sltiu:
	type_i_andi:
	type_i_ori:
	type_i_xori:
	type_i_lui:
	type_i_lb:
	type_i_lh:
	type_i_lwl:
	type_i_lw:
	type_i_lbu:
	type_i_lhu:
	type_i_lwr:
	type_i_sb:
	type_i_sh:
	type_i_swl:
	type_i_sw:
	type_i_swr:
	
######## registradores, imediates & endereço de procedimentos #######

check_immediate:

	li $t1, 0x0000FFFF
	and $t1, $s5, $t1
	
	move $a0,$t1
	la $a1, buffer
	jal to_string
	
	la $a0, buffer
	addi $v0, $zero, PRINT_STR
	syscall
	
	j endline_output

imm_ext:
	
	li 	$t1, 0x0000FFFF
	and $t1, $s5, $t1
	
	sll	$t1, $t1, 16
	sra $t1, $t1, 16
	
	move $a0, $t1
	la 	$a1, buffer
	jal to_string
	
	la $a0, buffer
	addi $v0, $zero, PRINT_STR
	syscall
	
	j endline_output

check_j_address:
	
	#mascara p pegar os 26 bits
	li $t1, 0x3FFFFFF
	and $t1, $s5, $t1
	
    move $a0, $t1
    la  $a1, buffer
    jal to_string # funcao para transformar o valor hexa em string

    la  $a0, buffer
    addi $v0, $zero, PRINT_STR
    syscall
	j endline_output

check_regs:
	beq $a0, 0x00, reg00 # $zero
	beq $a0, 0x01, reg01 # $at
	beq $a0, 0x02, reg02 # $v0
	beq $a0, 0x03, reg03 # $v1
	beq $a0, 0x04, reg04 # $a0
	beq $a0, 0x05, reg05 # $a1
	beq $a0, 0x06, reg06 # $a2
	beq $a0, 0x07, reg07 # $a3
	beq $a0, 0x08, reg08 # $t0
	beq $a0, 0x09, reg09 # $t1
	beq $a0, 0x0a, reg10 # $t2
	beq $a0, 0x0b, reg11 # $t3
	beq $a0, 0x0c, reg12 # $t4
	beq $a0, 0x0d, reg13 # $t5
	beq $a0, 0x0e, reg14 # $t6
	beq $a0, 0x0f, reg15 # $t7
	beq $a0, 0x10, reg16 # $s0
	beq $a0, 0x11, reg17 # $s1
	beq $a0, 0x12, reg18 # $s2
	beq $a0, 0x13, reg19 # $s3                	 	    	                	            
	beq $a0, 0x14, reg20 # $s4
	beq $a0, 0x15, reg21 # $s5
	beq $a0, 0x16, reg22 # $s6
	beq $t3, 0x17, reg23 # $s7
	beq $t3, 0x1d, reg29 # $sp
	beq $t3, 0x1f, reg31 # $ra
	
	j exit
	
reg00:
		la	$a0, str_r0
		addi $v0, $zero, PRINT_STR
		syscall
		
		jr $ra

reg01:
		la	$a0, str_r1
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg02:
		la	$a0, str_r2
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra

reg03:
		la	$a0, str_r3
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg04:
		la	$a0, str_r4
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg05:
		la	$a0, str_r5
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg06:
		la	$a0, str_r6
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg07:
		la	$a0, str_r7
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg08:
		la	$a0, str_r8
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg09:
		la	$a0, str_r9
		addi $v0, $zero, PRINT_STR
		syscall		
		jr $ra
reg10:
		la	$a0, str_r10
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg11:
		la	$a0, str_r11
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg12:
		la	$a0, str_r12
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg13:
		la	$a0, str_r13
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg14:
		la	$a0, str_r14
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg15:
		la	$a0, str_r15
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg16:
		la	$a0, str_r16
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg17:
		la	$a0, str_r17
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg18:
		la	$a0, str_r18
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg19:
		la	$a0, str_r19
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg20:
		la	$a0, str_r20
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg21:
		la	$a0, str_r21
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg22:
		la	$a0, str_r22
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg23:
		la	$a0, str_r23
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
		
reg24:
		la	$a0, str_r24
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
		
reg25:
		la	$a0, str_r25
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg26:
		la	$a0, str_r26
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg27:
		la	$a0, str_r27
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg28:
		la	$a0, str_r28
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra

reg29:
		la	$a0, str_r29
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg30:
		la	$a0, str_r30
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
reg31:
		la	$a0, str_r31
		addi $v0, $zero, PRINT_STR
		syscall
		jr $ra
		
		
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
sucesso:			.asciiz "sucesso\n"
inst_add:			.word 	0x014B4820 #add $t1, $t2, $t3
inst_sub:			.word	0x02324022 #sub 
inst_subu:			.word   0x0000a4af 
inst_and:			.word   0x00000424 #and 
inst_or:			.word	0x000A4B25
inst_addu:			.word 	0x02281021
inst_beq:			.word   0x11000224
inst_addi:			.word   0x21200800
inst_sll:			.word   0x01281040 #sll $t0, $t1, 4
inst_break:			.word   0x0000000D
inst_j:				.word   0x08010000
inst_jal:			.word	0x0c000000

buffer:				.space	128

## basicos
hex_digits:			.asciiz "0123456789ABCDEF"

## instrucoes:

### TIPO R ####
											##functs
str_add:			.asciiz "add "			#100000
str_addu:			.asciiz "addu "			#100001
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

## type i

str_addi:			.asciiz "addi " #rt, rs, imm	001000	
str_addiu:			.asciiz "addiu "#rt, rs, imm	001001	
str_andi:			.asciiz "andi " #rt, rs, imm	001100	
str_beq:			.asciiz "beq "  #rs, rt, label	000100	
str_bgez:			.asciiz "bgez " #rs, label	000001	rt = 00001
str_bgtz:			.asciiz "bgtz " #rs, label	000111	rt = 00000
str_blez:			.asciiz "blez " #rs, label	000110	rt = 00000
str_bltz:			.asciiz "bltz " #rs, label	000001	rt = 00000
str_bne:			.asciiz "bne " #rs, rt, label	000101	
str_lb:				.asciiz "lb " #rt, imm(rs)	100000	
str_lbu:			.asciiz "lbu " #rt, imm(rs)	100100	
str_lh:				.asciiz "lh " #rt, imm(rs)	100001	
str_lhu:			.asciiz "lhu " #rt, imm(rs)	100101	
str_lui:			.asciiz "lui "#rt, imm	001111	
str_lw:				.asciiz "lw " #rt, imm(rs)	100011	
str_lwc1:			.asciiz "lwc1 " #rt, imm(rs)	110001	
str_ori:			.asciiz "ori " #rt, rs, imm	001101	
str_sb:				.asciiz "sb " #rt, imm(rs)	101000	
str_slti:			.asciiz "slti " #rt, rs, imm	001010	
str_sltiu:			.asciiz "sltiu " #rt, rs, imm	001011	
str_sh:				.asciiz "sh " #rt, imm(rs)	101001	
str_sw:				.asciiz "sw " #rt, imm(rs)	101011	
str_swc1:			.asciiz "swc1 " #rt, imm(rs)	111001	
str_xori:			.asciiz "xori " #rt, rs, imm	001110	

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
