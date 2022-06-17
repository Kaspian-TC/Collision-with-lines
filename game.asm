#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
# 
# Student: Kaspian Thoft-Christensen, 1007066336, chris473, kaspian.thoft.christensen@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed) 
# - Display width in pixels: 512 (update this as needed) 
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
# Which milestones have been reached in this submission? 
# (See the assignment handout for descriptions of the milestones) 
# - Milestone 1/2/3 (choose the one the applies) 
# - Milestone 1, 2, and 3 have been met
# Which approved features have been implemented for milestone 3? 
# (See the assignment handout for the list of additional features) 
# 1. Different levels
# 2. Fail condition when the player touches the enemy OR when score goes to 0
# 3. Win condition when the player touches the white flag in the second level
# 4. Moving enemies
# 5. Score which is tied to how long the game goes on
# 6. Live scoreboard
#
# Link to video demonstration for final submission: 
# - (https://youtu.be/7cCN9CAYXM8 YouTube / https://play.library.utoronto.ca/watch/546eae6abc136118312612aa85099426 MyMedia). Make sure we can view it! 
# Youtube is better but I did upload to my media just in case 
# Are you OK with us sharing the video with people outside course staff? 
# - yes / no / yes, and please share this project github link as well!
# Yes, I am okay with sharing the video to others. I did not use github or any other repositories for this assignment though.
# Any additional information that the TA needs to know: 
# -IMPORTANT: for some unexplainable reason, the longer I leave mars open, the slower it gets. It is not tied to the amount of times I run the program. Please be aware of this while testing
# -To beat the game you need to get past the second level.
# -Letting the timer run out will result in a gamer over. Takes appoximately 5 minutes but can be more
# -Pressing q safely quits the game (goes to game over screen)
#####################################################################
# Game name: Collision with lines
.data
# array that represents all the the platforms that span the y axis
PLATFORM_Y_1: .word 0x10008b00, 0x1000bf00,0x10008bfc,0x1000bffe,0x10009A44,0x1000BE44,0x10008B88,0x1000B288,0x100091AC,0x10009AAC
PLATFORM_Y_2: .word 0x10008b00, 0x1000bf00,0x10008bfc,0x1000bffe,0x100092A8,0x10009CA8,0x100099dc,0x1000a2dc,0x10009f64,0x1000a564,0x10009938,0x10009f38,0x1000a728,0x1000b328,0x1000b248,0x1000ba48,0x1000ab80,0x1000ad80,0x1000b398,0x1000be98
PLATFORM_Y_LEN: .word 3 # not the length of the array but number of platforms
# array that represents all the the platforms that span the y axis
PLATFORM_X_1: .word 0x10008b04,0x10008bf8,0x1000bf04,0x1000bff8,0x1000B930,0x1000B958,0x1000A930,0x1000A958,0x1000B104,0x1000B114,0x1000A104,0x1000A114,0x10009930,0x10009958,0x10009274,0x10009294,0x1000A170,0x1000A1A0,0x1000B078,0x1000B088,0x1000B97C,0x1000B994,0x1000B2B4,0x1000B2E0,0x1000A9CC,0x1000A9E8,0x10009BA0,0x10009BBC,0x100091B0,0x100091F8,0x1000a5a4,0x1000a5b8
PLATFORM_X_2: .word 0x10008b04,0x10008bf8,0x1000bf04,0x1000bff8,0x10009104,0x100091A8,0x100098c4,0x10009900,0x10009a5c,0x10009a70,0x1000a628,0x1000a6f8,0x1000b90c,0x1000b91c,0x1000bb2c,0x1000bb48,0x1000b52c,0x1000b538,0x1000b754,0x1000b768,0x1000b158,0x1000b190,0x1000ba80,0x1000ba90
PLATFORM_X_LEN: .word 2 # not the length of the array but number of platforms
ENEMIES_1: .word 0x1000B848,0x1000A8E0
ENEMIES_2: .word 0x1000ab0c,0x100090AC,0x100097D4,0x1000A1A0,0x1000A348,0x1000BC9C,0x1000BAB8,0x1000BAD8,0x1000b07c,0x1000bdd8
ENEMIES_LEN: .word 2
END_FLAG_1 : .word 0x10008DF0
END_FLAG_2 : .word 0x1000baf4
CURRENT_POSITION: .word 0x10008f04
ON_PLATFORM: .word 0	#set to false as default
CURRENT_LEVEL: .word 1
G_ACCEL: .word -1
X_ACCEL: .word 0
CURRENT_ENEMY_STATE: .word 1
SCORE_COUNTER: .word 9000
FIRST_DIGIT_VALUE: .word 0
SECOND_DIGIT_VALUE: .word 0
THIRD_DIGIT_VALUE: .word 3
.text
.eqv DISPLAY_ADDRESS 0x10008000
.eqv KBD_BASE	0xffff0000 
.eqv PLATFORM_Y_1_LEN 5 # length y for level 1
.eqv PLATFORM_X_1_LEN 16 # length x for level 1
.eqv PLATFORM_Y_2_LEN 10 # length y for level 2
.eqv PLATFORM_X_2_LEN 12 # length x for level 2
.eqv ENEMIES_1_LEN 2
.eqv ENEMIES_2_LEN 10
.eqv LEVEL_1_START_POS 0x1000BC0C
.eqv LEVEL_2_START_POS 0x10008E0C
.eqv JUMP_ACCEL 11
.eqv SIDE_ACCEL 2
.eqv ENEMY_STATE_1 0x1000ab0c
.eqv ENEMY_STATE_2 0x1000ab10
.eqv ENEMY_STATE_3 0x1000ab14
.eqv FIRST_DIGIT 0x100084dc
.eqv SECOND_DIGIT 0x100084cc
.eqv THIRD_DIGIT 0x100084bc
.globl main
 main:
 	#update values based on level
 	lw $t3, CURRENT_LEVEL
 	beq $t3, 2, ASSIGN_LEVEL_2
 	
 	addi $t7,$0, DISPLAY_ADDRESS # assigns $t7 to the first pixel to remove
	addi $sp , $sp , -4 # push to stack
	sw $t7, 0($sp)
	jal CLEAR_SCREEN 	#clears the screen
 	# level 1 values
 	# change platform length Y
 	la $t3,PLATFORM_Y_LEN
 	addi $t4, $0, PLATFORM_Y_1_LEN
 	sw $t4,0($t3)
 	# change platform length X
 	la $t3,PLATFORM_X_LEN
 	addi $t4, $0, PLATFORM_X_1_LEN
 	sw $t4,0($t3)
	# change starting position
	la $t3,CURRENT_POSITION
 	addi $t4, $0, LEVEL_1_START_POS
 	sw $t4,0($t3)
	# change enemies length
	la $t3,ENEMIES_LEN
 	addi $t4, $0, ENEMIES_1_LEN
 	sw $t4,0($t3)
 	#reset score
 	addi $t4,$0,0
 	sw $t4,FIRST_DIGIT_VALUE
 	sw,$t4, SECOND_DIGIT_VALUE
 	addi $t4,$0,3
 	sw,$t4 THIRD_DIGIT_VALUE
 	
 	addi $t4, $0, 9000
 	
 	# draw score
 	j WRITE_SCORE
 	j START_PRE_LOOP

ASSIGN_LEVEL_2:
 	
	#level 2 values
	# make sure ON_PLATFORM is set to 0
	addi $t3,$0,0
	sw $t3, ON_PLATFORM
	# make sure gravity is set to -1
	addi $t3,$0,-1	
	sw $t3, G_ACCEL
 	# change platform length Y
 	la $t3,PLATFORM_Y_LEN
 	addi $t4, $0, PLATFORM_Y_2_LEN
 	sw $t4,0($t3)
 	# change platform length X
 	la $t3,PLATFORM_X_LEN
 	addi $t4, $0, PLATFORM_X_2_LEN
 	sw $t4,0($t3)
	# change starting position
	la $t3,CURRENT_POSITION
 	addi $t4, $0, LEVEL_2_START_POS
 	sw $t4,0($t3)
	# change enemies length
	la $t3,ENEMIES_LEN
 	addi $t4, $0, ENEMIES_2_LEN
 	sw $t4,0($t3)
START_PRE_LOOP:	 # $t0 stores the base address for display
	li $t0, DISPLAY_ADDRESS	# load in the first pointer to the display
	li $t9, KBD_BASE	# this is the address to the input
	
	#finds which level to draw
	lw $t3, CURRENT_LEVEL	#assigns $t3 to current level (either 1 or 2)
	beq $t3,2,ASSIGN_LEVEL_2_Y # checks to see of $t3 is 2 (goes to level 2)
	la $t3,PLATFORM_Y_1 # assigns $t3 to the array containing all the level 1 Y axis platforms
	j ASSIGN_PLATFORMS_Y_PRE

ASSIGN_LEVEL_2_Y:
	la $t3,PLATFORM_Y_2 # assigns $t3 to the array containing all the level 2 Y axis platforms

ASSIGN_PLATFORMS_Y_PRE:
	li $t1, 0xf08a4b# $t1 stores the colour for drawing the platforms 
	addi $t8,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $t3,$t3,-8	# sets the counter to $t3-8 to counteract the +8
DRAW_PLATFORMS_Y:
	addi $t8,$t8,1	# adds 1 each time it comes here 
	addi $t3,$t3,8 	# adds 8 each time it comes here 
	lw $t4, PLATFORM_Y_LEN
	bge $t8,$t4,DRAW_PLATFORMS_X_PRE # checks to see if $t8 is greater than the length
	lw $t4, 0($t3) 	# assigns $t4 to the top of the Y axis platform 
	lw $t5, 4($t3) 	# assigns $t5 to the bottom of the Y axis platform 
DRAW_PLATFORMS_Y_i:	# draws the i'th platform
	blt $t5,$t4,DRAW_PLATFORMS_Y 	# is done when $t4 is done drawing the pixel at $t5
	
	sw $t1, 0($t4) 	# draws current pixel for platform
	addi $t4,$t4,256 # moves $t4 to the next pixel
	j DRAW_PLATFORMS_Y_i

DRAW_PLATFORMS_X_PRE:
	#finds which level to draw
	lw $t3, CURRENT_LEVEL	#assigns $t3 to current level (either 1 or 2)
	beq $t3,2,ASSIGN_LEVEL_2_X # checks to see of $t3 is 2 (goes to level 2)
	la $t3,PLATFORM_X_1 # assigns $t3 to the array containing all the level 1 X axis platforms
	j ASSIGN_PLATFORMS_X_PRE
ASSIGN_LEVEL_2_X:
	la $t3,PLATFORM_X_2 # assigns $t3 to the array containing all the level 2 X axis platforms
ASSIGN_PLATFORMS_X_PRE:
	li $t1, 0xf08a4b# $t1 stores the colour for drawing the platforms
	addi $t8,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $t3,$t3,-8	# sets the counter to $t3-8 to counteract the +8
DRAW_PLATFORMS_X:
	addi $t8,$t8,1	# adds 1 each time it comes here
	addi $t3,$t3,8 	# adds 8 each time it comes here
	lw $t4, PLATFORM_X_LEN
	bge $t8,$t4,DRAW_FINISH_LINE_1 # checks to see if $t8 is greater than the length
	lw $t4, 0($t3) 	# assigns $t4 to the left of the X axis platform 
	lw $t5, 4($t3) 	# assigns $t5 to the right of the X axis platform 
DRAW_PLATFORMS_X_i:	# draws the i'th platform
	blt $t5,$t4,DRAW_PLATFORMS_X 	# is done when $t4 is done drawing the pixel at $t5

	sw $t1, 0($t4) 	# draws current pixel for platform
	addi $t4,$t4,4 # moves $t4 to the next pixel
	j DRAW_PLATFORMS_X_i

DRAW_FINISH_LINE_1:
	lw $t3, CURRENT_LEVEL	#assigns $t3 to current level (either 1 or 2)
	beq $t3,2,DRAW_FINISH_LINE_2 # if is level 2 then draw second finish line
	la $t3,END_FLAG_1
	j DRAW_FINISH_LINE
DRAW_FINISH_LINE_2:
	la $t3,END_FLAG_2
	
DRAW_FINISH_LINE:	#draws the finish line here
	lw $t4, 0($t3) # assigns $t4 to the top of the finish line
	li $t1, 0xffffff # sets the colour to white
	sw $t1, 0($t4) 	# draws top pixel of character
	sw $t1, 256($t4) 	
	sw $t1, 512($t4) 	
	sw $t1, 768($t4) # draws bottom pixel 	

DRAW_ENEMIES_PRE:
	#finds which level to draw
	lw $t3, CURRENT_LEVEL	#assigns $t3 to current level (either 1 or 2)
	beq $t3,2,ASSIGN_ENEMIES_2 # checks to see of $t3 is 2 (goes to level 2)
	la $t3,ENEMIES_1 # assigns $t3 to the array containing all the enemies
	j ASSIGN_ENEMIES_PRE
ASSIGN_ENEMIES_2:
	la $t3,ENEMIES_2 # assigns $t3 to the array containing all the enemies
ASSIGN_ENEMIES_PRE:
	li $t1, 0xff0000# $t1 stores the colour for drawing the enemys
	addi $t8,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $t3,$t3,-4	# sets the counter to $t3-4 to counteract the +4
DRAW_ENEMIES:
	addi $t8,$t8,1	# adds 1 each time it comes here
	addi $t3,$t3,4 	# adds 4 each time it comes here
	lw $t4, ENEMIES_LEN
	bge $t8,$t4,PRE_MAIN_LOOP # checks to see if $t8 is greater than the length
	lw $t4, 0($t3) 	# assigns $t4 to the left of the enemy
	addi $t5, $t4, 8 	# assigns $t5 to the right of the enemy
DRAW_ENEMIES_i:	# draws the i'th enemy
	blt $t5,$t4,DRAW_ENEMIES 	# is done when $t4 is done drawing the pixel at $t5

	sw $t1, 0($t4) 	# draws current pixel for platform
	addi $t4,$t4,4 # moves $t4 to the next pixel
	j DRAW_ENEMIES_i

#t8 is freed, $t3 is freed, $t4 is freed, $t5 is freed,$t1 is freed
PRE_MAIN_LOOP:	
	
		
MAIN_LOOP:
	lw $t3, CURRENT_POSITION # assigns $t3 to the current position of the player
	lw $t7, CURRENT_LEVEL # assigns $t7 to the current level (either 1 or 2)
	li $v0, 32
	li $a0, 33	# updates screen at about 30 fps
	syscall

check_input:
	
	lw $t8, 4($t9) 	# takes input from keyboard
	bne $t8, 0x61, not_a 	#checks if input is not 'a'
	
	addi $t7,$t3, -4 
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,clear_input	# if there was a collision, just jump to the clear
	
	addi $t7,$t3, -260 	# looks at value right of middle pixel (-4-256 = -260)
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,clear_input	# if there was a collision, just jump to the clear

	addi $t7,$t3, -516 	# looks at value right of top pixel (4-512 = -516)
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,clear_input	# if there was a collision, just jump to the clear
	
	sub $t7, $0, SIDE_ACCEL		# assign side acceleration to negative
	sw $t7, X_ACCEL
	
	jal CLEAR_PLAYER
	addi $t3,$t3,-4		# if keyboard is a then it moves the current pixel 1 to the left
	j clear_input
	
not_a:	bne $t8, 0x64, not_d	#checks if input is not 'd'
	
	addi $t7,$t3, 4 	# looks at value right of center pixel
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,clear_input	# if there was a collision, just jump to the clear	

	addi $t7,$t3, -252 	# looks at value right of middle pixel (4-256=-252)
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,clear_input	# if there was a collision, just jump to the clear

	addi $t7,$t3, -508 	# looks at value right of top pixel (4-512 = -508)
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,clear_input	# if there was a collision, just jump to the clear

	addi $t7, $0, SIDE_ACCEL		# assign side acceleration to positive
	sw $t7, X_ACCEL

	jal CLEAR_PLAYER
	addi $t3,$t3,4		# if keyboard is d then it moves the current pixel 1 to the right
	j clear_input
not_d: 	bne $t8, 0x77, not_w	#checks if input is not 'w'
	
	lw $t7, ON_PLATFORM	# checks to see if player is on a platform
	beq $t7, 0, clear_input	# if player is not on a platoform, do nothing
	addi $t7, $0, 0
	sw $t7, ON_PLATFORM	# if player is on platform, then after pressing w they are no longer on a platform 
	
	addi $t7, $0, JUMP_ACCEL		# assign acceleration to positive
	sw $t7, G_ACCEL
	
	addi $t7,$t3, -768 # assigns $t7 to the direction to move to + top pixel
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,clear_input	# if there was a collision, just jump to the clear
	
	jal CLEAR_PLAYER
	addi $t3,$t3, -256	# if keyboard is w then it moves the current pixel 1 up	
	
	j clear_input
not_w: bne $t8, 0x73, continue	#checks if input is not 's'
	
	#lw $t7, G_ACCEL
	#blt $t7,0,is_not_falling
	addi $t7, $0, -1		# cancel upwards acceleration
	sw $t7, G_ACCEL
	addi $t7, $0, 0			# cancel sideways acceleration
	sw $t7, X_ACCEL
is_not_falling:
	
	addi $t7,$t3, 256 # assigns $t7 to the direction to move to
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,clear_input	# if there was a collision, just jump to the clear

	jal CLEAR_PLAYER
	addi $t3,$t3, 256	# if keyboard is s then it moves the current pixel 1 down
	
clear_input:
	addi $t8, $0, 0		# sets the currently pressed pixel back to nothing
	sw $t8, 4($t9)

continue: 
	beq $t8,0x71,GAME_OVER_SCREEN # if 'q' is pressed then quit
	beq $t8,0x70,RESTART
	# $t8 is now freed
check_x_accel:
	lw $t8, X_ACCEL
	ble $t8,0,check_x_neg_accel
	# X_ACCEL is greater than 0 if it goes here. Moves right
	addi $t7,$t3, 4 	# looks at value right of center pixel
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,decrease_x_accel	# if there was a collision, just jump to the clear	

	addi $t7,$t3, -252 	# looks at value right of middle pixel (4-256=-252)
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,decrease_x_accel	# if there was a collision, just jump to the clear

	addi $t7,$t3, -508 	# looks at value right of top pixel (4-512 = -508)
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,decrease_x_accel	# if there was a collision, just jump to the clear
	
	jal CLEAR_PLAYER
	addi $t3,$t3, 4
	
decrease_x_accel: 
	lw $t8, X_ACCEL
	addi $t8,$t8,-1	#slow down acceleration
	sw $t8, X_ACCEL
	
	j no_x_accel
check_x_neg_accel:
	lw $t8, X_ACCEL
	beq $t8,0,no_x_accel
	# goes here if X_ACCEL is less than 
	addi $t7,$t3, -4 
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,increase_x_accel	# if there was a collision, just jump to the clear
	
	addi $t7,$t3, -260 	# looks at value right of middle pixel (-4-256 = -260)
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,increase_x_accel	# if there was a collision, just jump to the clear

	addi $t7,$t3, -516 	# looks at value right of top pixel (4-512 = -516)
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value
	addi $sp , $sp , 4 
	beq $t7,1,increase_x_accel	# if there was a collision, just jump to the clear
	
	jal CLEAR_PLAYER
	addi $t3,$t3, -4
	
increase_x_accel:
	lw $t8, X_ACCEL
	addi $t8,$t8,1	#slow down acceleration
	sw $t8, X_ACCEL
	
no_x_accel:

check_neg_accel:	
	addi $t7,$t3, 256 # assigns $t7 to the direction to move to
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value 
	addi $sp , $sp , 4 
	
	sw $t7, ON_PLATFORM # if there is a collision then the player is on a platform and it ON_PLATFORM needs to be updated
	beq $t7,1,no_neg_accel # if there is a collision then don't move 
	
	lw $t8,G_ACCEL	
	bgt $t8, -1, no_neg_accel	# if G_ACCEL is positive then go up
	
	jal CLEAR_PLAYER
	addi $t3,$t3, 256
	
	j draw_player
no_neg_accel:
	lw $t8,G_ACCEL
	beq  $t8, -1, draw_player # if negative, don't decrease acceleration
	beq $t8, 0, no_accel	#don't move if less than or equal to zero
	
	addi $t7,$t3, -768 # assigns $t7 to the direction to move to + top pixel
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $t7, 0($sp)
	jal COLLIDE
	lw $t7, 0($sp) # load return value 
	addi $sp , $sp , 4 
	
	beq $t7,1,no_accel # if there is a collision then don't move
	
	jal CLEAR_PLAYER
	addi $t3,$t3, -256
	
no_accel:
	addi $t8, $t8, -1
	sw $t8,G_ACCEL
draw_player:	
	li $t1, 0xff00f0 # $t1 stores the colour pink
	sw $t1, 0($t3) 	# draws center pixel of character
	sw $t1, -256($t3) 	# draws middle pixel of character
	sw $t1, -512($t3) 	# draws top pixel of character
	
	la $t8, CURRENT_POSITION	# assigns $t8 to the address where it shows the current position of the player
	sw $t3,0($t8)			# changes the current position of the player
move_enemy:
	lw $t8, CURRENT_LEVEL 	#check if level is equal to 1
	beq $t8,1,update_score_counter
	#goes here if the current level is level 2
	lw $t8, CURRENT_ENEMY_STATE	#move enemy depending on the state
	beq $t8,3,move_enemy_3
	beq $t8,2,move_enemy_2
	#move_enemy_1
	addi  $t7,$0,ENEMY_STATE_2	# assign $t7 to enemy 2 position
	addi $t8,$0,2	#move state 1 to state 2
	j update_enemy
move_enemy_2:
	add $t7,$0,ENEMY_STATE_3	# assign $t7 to enemy 3 position
	addi $t8,$0,3	#move state 2 to state 3
	j update_enemy
move_enemy_3:
	add $t7,$0,ENEMY_STATE_1	# assign $t7 to enemy 1 position
	addi $t8,$0,1	#move state 3 to state 1
update_enemy:
	addi $t1,$0,0
	lw $t4, ENEMIES_2
	sw $t1, 0($t4) 	# remove current enemy
	sw $t1, 4($t4)
	sw $t1, 8($t4)
	
	li $t1, 0xff0000# $t1 stores the colour for drawing the enemys
	sw $t1, 0($t7) 	# redraw enemy in new location
	sw $t1, 4($t7)
	sw $t1, 8($t7)
	
	sw $t8,CURRENT_ENEMY_STATE # reassigns enemy state
	sw $t7,ENEMIES_2	# changes location of first enemy
	
update_score_counter:
	lw $t8,SCORE_COUNTER
	addi $t8,$t8,-1		#takes score and removes one from it
	beq $t8,0,GAME_OVER_SCREEN
	sw $t8,SCORE_COUNTER	# stores it back into the score_counter
	
	addi $t6, $0, 30
	div $t8,$t6	# divide $t8 by 30
	mfhi $t5 	# store mod in $t5
	bne $t5,0,MAIN_LOOP_END # checks to see if mod is 0
	
	# if mod is zero, then update the score counter (this should happen once every second)
	lw $t6, FIRST_DIGIT_VALUE	# use $t6 as the value for the first digit 
	bne $t6,0,change_first_digit 	# checks if the first digit is zero to then draw 9
	addi $t6,$0,10
	lw $t5, SECOND_DIGIT_VALUE	# use $t5 as the value for the second digit
	bne $t5,0,change_second_digit 	# checks if the second digit is zero to then draw 9
	addi $t5,$0,10
	lw $t4, THIRD_DIGIT_VALUE	# use $t5 as the value for the second digit
	bne $t4,0,change_third_digit 	# checks if the second digit is zero to then draw 9
	addi $t4,$0,10

change_third_digit:
	addi $t4,$t4,-1
	sw $t4, THIRD_DIGIT_VALUE # store the new digit
	addi $sp , $sp , -4 # push new digit onto stack
	sw $t4, 0($sp)
	li $t7,THIRD_DIGIT 	# push the address of the first digit
	addi $sp , $sp , -4 # push address onto the stack
	sw $t7, 0($sp)
	jal UPDATE_SCORE
	
change_second_digit:
	addi $t5,$t5,-1
	sw $t5, SECOND_DIGIT_VALUE # store the new digit
	addi $sp , $sp , -4 # push new digit onto stack
	sw $t5, 0($sp)
	li $t7,SECOND_DIGIT 	# push the address of the first digit
	addi $sp , $sp , -4 # push address onto the stack
	sw $t7, 0($sp)
	jal UPDATE_SCORE

change_first_digit:
	addi $t6,$t6,-1
	sw $t6, FIRST_DIGIT_VALUE # store the new digit
	addi $sp , $sp , -4 # push new digit onto stack
	sw $t6, 0($sp)
	li $t7,FIRST_DIGIT 	# push the address of the first digit
	addi $sp , $sp , -4 # push address onto the stack
	sw $t7, 0($sp)
	jal UPDATE_SCORE
	
MAIN_LOOP_END: j MAIN_LOOP # jumps back to loop

RESTART:
	addi $t7,$0,DISPLAY_ADDRESS # assigns $t7 to the first pixel to remove
	addi $sp , $sp , -4 # push to stack
	sw $t7, 0($sp)
	jal CLEAR_SCREEN 	# clears the screen
	
	addi $t8, $0, 0		# sets the currently pressed pixel back to nothing
	sw $t8, 4($t9)
	
	la $t1,CURRENT_LEVEL 	# set the level back to 1
	addi $t2,$0,1	
	sw $t2,0($t1)
	
	la $t1,CURRENT_POSITION	# set the level back to 1
	addi $t2,$0,LEVEL_1_START_POS	
	sw $t2,0($t1) 
	
	j main
NEXT_LEVEL:
	addi $t7,$0, 0x10008b00 # assigns $t7 to the first pixel to remove
	addi $sp , $sp , -4 # push to stack
	sw $t7, 0($sp)
	jal CLEAR_SCREEN 	#clears the screen
	#if level 2, end, otherwise go to level 2
	lw $t3, CURRENT_LEVEL
 	beq $t3, 2, WIN_SCREEN
 	# change platform length Y
 	la $t3,CURRENT_LEVEL
 	addi $t4, $0, 2
 	sw $t4,0($t3)
 	j main

END:	
	li $v0, 10 # terminate the program gracefully 
	syscall
	
CLEAR_SCREEN:			# function clears the screen
	li $s1, 0x000000	# assign temp value for the 0x000000
	lw $s0, 0($sp) # load location
	addi $sp , $sp , 4
	#li $s0, DISPLAY_ADDRESS	# load in the first pointer to the display
	
CLEAR_LOOP:			# start loop
	sw $s1, 0($s0)		# colour current position
	addi $s0,$s0,4		# iterate to the next pixel
	bge $s0,0x1000c000,END_CLEAR	#check if pixel is out of range. If pixel is out of range, end loop
	j CLEAR_LOOP		# loop back
END_CLEAR: jr $ra

COLLIDE:	#s0 is the location to be assesed, #s1 which level (either 1 or 2), #s2 is the return value (either 1 or 0) 
	lw $s0, 0($sp) # load location
	addi $sp , $sp , 4 
	lw $s1, CURRENT_LEVEL
	
CHECK_COLLIDE_X:
	# loop through the current level's array and then check if location($s0) 
	beq $s1, 2, LEVEL_2_X #checks for the correct level
LEVEL_1_X:
	la $s3,PLATFORM_X_1 # assigns $t3 to the array containing all the X axis platforms
	addi $s7,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $s3,$s3,-8	# sets the counter to $t3-8 to counteract the +8
	j COLLIDE_X_LOOP
LEVEL_2_X:
	la $s3,PLATFORM_X_2 # assigns $t3 to the array containing all the X axis platforms
	addi $s7,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $s3,$s3,-8	# sets the counter to $t3-8 to counteract the +8

COLLIDE_X_LOOP: # s7 represents the current index, #s3 is the pointer to the array, $s4 is the left of the platform, $s5 is the right
	addi $s7,$s7,1	# adds 1 each time it comes here 
	addi $s3,$s3,8 	# adds 8 each time it comes here 
	lw $s4, PLATFORM_X_LEN # this should change based on the level. $s4 is a temp var for length
	bge $s7,$s4,CHECK_COLLIDE_Y # checks to see if $t8 is greater than the length, then goes to check the collision with Y
	lw $s4, 0($s3) 	# assigns $t4 to the left of the X axis platform 
	lw $s5, 4($s3) 	# assigns $t5 to the right of the X axis platform 
	bgt $s4,$s0,COLLIDE_X_LOOP # if $s4>$s0, loop
	blt $s5,$s0,COLLIDE_X_LOOP # if $s5<$s0, loop
	addi $s2,$0,1	#assigns true if passes
	j RETURN_COLLIDE
	
CHECK_COLLIDE_Y:
	# loop through the current level's array and then check if location($s0) 
	beq $s1, 2, LEVEL_2_Y #checks for the correct level
LEVEL_1_Y:
	la $s3,PLATFORM_Y_1 # assigns $t3 to the array containing all the X axis platforms
	addi $s7,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $s3,$s3,-8	# sets the counter to $t3-8 to counteract the +8
	j COLLIDE_Y_LOOP
LEVEL_2_Y:
	la $s3,PLATFORM_Y_2 # assigns $t3 to the array containing all the X axis platforms
	addi $s7,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $s3,$s3,-8	# sets the counter to $t3-8 to counteract the +8

COLLIDE_Y_LOOP: # s7 represents the current index, #s3 is the pointer to the array, $s4 is the left of the platform, $s5 is the right
	addi $s7,$s7,1	# adds 1 each time it comes here 
	addi $s3,$s3,8 	# adds 8 each time it comes here 
	lw $s4, PLATFORM_Y_LEN # this should change based on the level. $s4 is a temp var for length
	bge $s7,$s4,COLLIDE_END_FLAG # checks to see if $s7 is greater than the length, then goes to check the collision with Y
	lw $s4, 0($s3) 	# assigns $s4 to the top of the Y axis platform 
	lw $s5, 4($s3) 	# assigns $s5 to the bottom of the Y axis platform 
	bgt $s4,$s0,COLLIDE_Y_LOOP # if $s4>$s0, loop
	blt $s5,$s0,COLLIDE_Y_LOOP # if $s5<$s0, loop
	# there is an extra step here, check if $s4 mod 256 != $s0 mod 256
	addi $s6, $0, 256
	div $s4,$s6	# divide $s4 by 256
	mfhi $s5	# store mod in $s5
	div $s0,$s6	# divide location by 256
	mfhi $s6	# store mod in $s6
	bne $s5,$s6,COLLIDE_Y_LOOP	# loops if mod is not the same (no collision)
	
	addi $s2,$0,1	# collides
	j RETURN_COLLIDE
	
COLLIDE_END_FLAG:
	beq $s1, 2, LEVEL_2_FLAG
	lw $s4, END_FLAG_1
	j COLLIDE_END_FLAG_CHECK
LEVEL_2_FLAG:
	lw $s4, END_FLAG_2
COLLIDE_END_FLAG_CHECK:
	addi, $s5, $s4, 768	# assigns $s5 to the bottom value of the flag
	bgt $s4,$s0,CHECK_COLLIDE_ENEMIES # if $s4>$s0, no collision
	blt $s5,$s0,CHECK_COLLIDE_ENEMIES # if $s5<$s0, no collision
	# there is an extra step here, check if $s4 mod 256 != $s0 mod 256
	addi $s6, $0, 256
	div $s4,$s6	# divide $s4 by 256
	mfhi $s5	# store mod in $s5
	div $s0,$s6	# divide location by 256
	mfhi $s6	# store mod in $s6
	bne $s5,$s6,CHECK_COLLIDE_ENEMIES	# no collision if mod isn't the same
	# in case of collision found, go to next level
	j NEXT_LEVEL

CHECK_COLLIDE_ENEMIES:
	# loop through the current level's array and then check if location($s0) 
	beq $s1, 2, LEVEL_2_ENEMIES #checks for the correct level
LEVEL_1_ENEMIES:
	la $s3,ENEMIES_1 # assigns $t3 to the array containing all the X axis platforms
	addi $s7,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $s3,$s3,-4	# sets the counter to $t3-4 to counteract the +4
	j COLLIDE_ENEMIES_LOOP
LEVEL_2_ENEMIES:
	la $s3,ENEMIES_2 # assigns $t3 to the array containing all the X axis platforms
	addi $s7,$0,-1 	# sets the counter to -1 to counteract the +1
	addi $s3,$s3,-4	# sets the counter to $t3-4 to counteract the +4

COLLIDE_ENEMIES_LOOP: # s7 represents the current index, #s3 is the pointer to the array, $s4 is the left of the enemy, $s5 is the right
	addi $s7,$s7,1	# adds 1 each time it comes here 
	addi $s3,$s3,4 	# adds 4 each time it comes here 
	lw $s4, ENEMIES_LEN # this should change based on the level. $s4 is a temp var for length
	bge $s7,$s4,RETURN_COLLIDE_FAIL # checks to see if $t8 is greater than the length, then goes to fail
	lw $s4, 0($s3) 	# assigns $t4 to the left of the X axis platform 
	addi $s5, $s4,8 	# assigns $t5 to the right of the enemy 
	bgt $s4,$s0,COLLIDE_ENEMIES_LOOP # if $s4>$s0, loop
	blt $s5,$s0,COLLIDE_ENEMIES_LOOP # if $s5<$s0, loop
	j GAME_OVER_SCREEN # go to game over screen (end for now)

RETURN_COLLIDE_FAIL:
	addi $s2,$0,0 	# no collision found
RETURN_COLLIDE:
	addi $sp , $sp , -4 # push $s2 (return value) onto the stack
	sw $s2, 0($sp)
	jr $ra

CLEAR_PLAYER: 	# this is a way to simplify drawing and clearing the player,
		# assumes that $t1 is not in use and $t3 is the current player's center
	
	li $t1, 0x000000 # $t1 stores the colour black
	sw $t1, 0($t3) 	# draws center pixel of character
	sw $t1, -256($t3) 	# draws middle pixel of character
	sw $t1, -512($t3) 	# draws top pixel of character
	jr $ra
	
DRAW_X:	# draws along the x axis
	# $t1 is the colour, $t3 is the start, $t4 is the end
DRAW_X_LOOP:
	blt $t4,$t3,DRAW_X_LOOP_END 	# is done when $t3 is done drawing the pixel at $t4
	sw $t1, 0($t3) 	# draws current pixel for platform
	addi $t3,$t3,4 # moves $t3 to the next pixel
	j DRAW_X_LOOP
DRAW_X_LOOP_END:	
	jr $ra

DRAW_Y:	# draws along the x axis
	# $t1 is the colour, $t3 is the start, $t4 is the end
DRAW_Y_LOOP:
	blt $t4,$t3,DRAW_Y_LOOP_END	# is done when $t3 is done drawing the pixel at $t4
	sw $t1, 0($t3) 	# draws current pixel for platform
	addi $t3,$t3,256 # moves $t3 to the next pixel
	j DRAW_Y_LOOP
DRAW_Y_LOOP_END:
	jr $ra	
UPDATE_SCORE: # takes in $s0 which is the address of the top left corner, and $s1 which is the number to write
	# $s3 will also store the colour to draw with
	
	lw $s0, 0($sp) # load address
	addi $sp , $sp , 4
	lw $s1, 0($sp) # load number to write
	addi $sp , $sp , 4 
	
	bne $s1,9,DRAW_8
	#draw 9 to $s0 over the current 0
	#draw white part
	li $s3, 0xffffff
	sw $s3,516($s0) #draws to (1,2) relative to top left corner
	#draw black part
	li $s3, 0x000000
	sw $s3,512($s0) #draws to (0,2) relative to top left corner
	
	j RETURN_UPDATE_SCORE
DRAW_8:
	bne $s1,8,DRAW_7
	#draw 8 to $s0 over the current 9
	#draw white part
	li $s3, 0xffffff
	sw $s3,512($s0) #draws to (0,2) relative to top left corner
	sw $s3,260($s0) #draws to (1,1) relative to top left corner
	#draw black part
	li $s3, 0x000000
	sw $s3,516($s0) #draws to (1,2) relative to top left corner
	j RETURN_UPDATE_SCORE
DRAW_7:	bne $s1,7,DRAW_6
	#draw 7 to $s0 over the current 8
	#draw white part
	li $s3, 0xffffff
	sw $s3,516($s0) #draws to (0,2) relative to top left corner
	
	#draw black part
	li $s3, 0x000000
	sw $s3,260($s0) #draws to (0,1) relative to top left corner
	sw $s3,512($s0) #draws to (0,2) relative to top left corner
	sw $s3,260($s0) #draws to (1,1) relative to top left corner
	sw $s3,520($s0) #draws to (2,2) relative to top left corner
	sw $s3,776($s0) #draws to (2,3) relative to top left corner
	sw $s3,772($s0) #draws to (1,3) relative to top left corner
	j RETURN_UPDATE_SCORE
DRAW_6:	bne $s1,6,DRAW_5
	#draw 6 to $s0 over the current 7
	#draw white part
	li $s3, 0xffffff
	sw $s3,260($s0) #draws to (0,1) relative to top left corner
	sw $s3,512($s0) #draws to (0,2) relative to top left corner
	sw $s3,260($s0) #draws to (1,1) relative to top left corner
	sw $s3,520($s0) #draws to (2,2) relative to top left corner
	sw $s3,776($s0) #draws to (2,3) relative to top left corner
	sw $s3,772($s0) #draws to (1,3) relative to top left corner
	
	#draw black part
	li $s3, 0x000000
	sw $s3,516($s0) #draws to (1,2) relative to top left corner
	sw $s3,264($s0) #draws to (2,1) relative to top left corner
	j RETURN_UPDATE_SCORE
DRAW_5:	bne $s1,5,DRAW_4
	#draw 5 to $s0 over the current 6
	#draw white part
	li $s3, 0xffffff
	sw $s3,264($s0) #draws to (2,1) relative to top left corner	
	#draw black part
	li $s3, 0x000000
	sw $s3,512($s0) #draws to (0,2) relative to top left corner
	sw $s3,8($s0) #draws to (2,0) relative to top left corner
	j RETURN_UPDATE_SCORE
DRAW_4:	bne $s1,4,DRAW_3
	#draw 4 to $s0 over the current 5
	#draw white part
	li $s3, 0xffffff
	sw $s3,512($s0) #draws to (0,2) relative to top left corner	
	sw $s3,516($s0) #draws to (1,2) relative to top left corner	
	#draw black part
	li $s3, 0x000000
	sw $s3,4($s0) #draws to (1,0) relative to top left corner
	sw $s3,260($s0) #draws to (1,1) relative to top left corner
	sw $s3,768($s0) #draws to (0,3) relative to top left corner	
	sw $s3,772($s0) #draws to (1,3) relative to top left corner
	j RETURN_UPDATE_SCORE
DRAW_3:	bne $s1,3,DRAW_2
	#draw 3 to $s0 over the current 4
	#draw white part
	li $s3, 0xffffff
	sw $s3,4($s0) #draws to (1,0) relative to top left corner	
	sw $s3,8($s0) #draws to (2,0) relative to top left corner
	sw $s3,260($s0) #draws to (1,1) relative to top left corner
	sw $s3,768($s0) #draws to (0,3) relative to top left corner
	sw $s3,772($s0) #draws to (1,3) relative to top left corner
	#draw black part
	li $s3, 0x000000
	sw $s3,256($s0) #draws to (0,1) relative to top left corner
	sw $s3,512($s0) #draws to (0,2) relative to top left corner
	sw $s3,516($s0) #draws to (1,2) relative to top left corner
	j RETURN_UPDATE_SCORE
DRAW_2:	bne $s1,2,DRAW_1
	#draw 2 to $s0 over the current 3
	#draw white part
	li $s3, 0xffffff
	sw $s3,256($s0) #draws to (0,1) relative to top left corner
	sw $s3,512($s0) #draws to (0,2) relative to top left corner	
	#draw black part
	li $s3, 0x000000
	sw $s3,0($s0) #draws to (0,0) relative to top left corner
	sw $s3,520($s0) #draws to (2,2) relative to top left corner
	j RETURN_UPDATE_SCORE
DRAW_1:	bne $s1,1,DRAW_0
	#draw 1 to $s0 over the current 2
	#draw white part
	li $s3, 0xffffff
	sw $s3,516($s0) #draws to (1,2) relative to top left corner	
	#draw black part
	li $s3, 0x000000
	sw $s3,8($s0) #draws to (2,0) relative to top left corner
	sw $s3,264($s0) #draws to (2,1) relative to top left corner
	sw $s3,512($s0) #draws to (0,2) relative to top left corner
	j RETURN_UPDATE_SCORE
DRAW_0:	bne $s1,0,RETURN_UPDATE_SCORE
	#draw 0 to $s0 over the current 1
	#draw white part
	li $s3, 0xffffff
	sw $s3,0($s0) #draws to (0,0) relative to top left corner
	sw $s3,8($s0) #draws to (2,0) relative to top left corner
	sw $s3,264($s0) #draws to (2,1) relative to top left corner
	sw $s3,512($s0) #draws to (2,1) relative to top left corner
	sw $s3,520($s0) #draws to (2,1) relative to top left corner
	#draw black part
	li $s3, 0x000000
	sw $s3,260($s0) #draws to (1,1) relative to top left corner
	sw $s3,516($s0) #draws to (1,2) relative to top left corner

RETURN_UPDATE_SCORE:
	jr $ra
	
WRITE_SCORE: # this function draws the word "score" in the top box
	li $t1, 0xffffff # $t1 stores the colour white
	#draw s
	addi $t3,$0,0x10008464	# assign $t3 to (25,4)
	addi $t4,$t3,4	# assign $t4 to (26,4)
	jal DRAW_X
	addi $t3,$0,0x10008564	# assign $t3 to (25,5)
	addi $t4,$t3,8	# assign $t4 to (27,5)
	jal DRAW_X
	addi $t3,$0,0x10008764	# assign $t3 to (25,7)
	addi $t4,$t3,8	# assign $t4 to (27,7)
	jal DRAW_X
	addi $t3,$0,0x1000866c	# assign $t3 to (27,6)
	sw $t1, 0($t3) 	# draws current pixel for platform
	#draw c
	addi $t3,$0,0x10008474	# assign $t3 to (29,4)
	addi $t4,$t3,8	# assign $t4 to (31,4)
	jal DRAW_X
	addi $t3,$0,0x10008574	# assign $t3 to (29,5)
	sw $t1, 0($t3) 	# draws current pixel
	sw $t1, 256($t3) 	# draws below pixel
	addi $t3,$0,0x10008774	# assign $t3 to (29,7)
	addi $t4,$t3,8	# assign $t4 to (31,7)
	jal DRAW_X
	#draw o
	addi $t3,$0,0x10008484	# assign $t3 to (33,4)
	addi $t4,$t3,512	# assign $t4 to (33,6)	
	jal DRAW_Y
	addi $t3,$0,0x1000858c	# assign $t3 to (35,5)
	addi $t4,$t3,512	# assign $t4 to (35,7)	
	jal DRAW_Y
	addi $t3,$0,0x10008488 	# assign $t3 to (34,4)
	sw $t1, 0($t3) 	# draws current pixel
	sw $t1, 768($t3) 	# draws (34,7)
	#draw r
	addi $t3,$0,0x10008494	# assign $t3 to (37,4)
	addi $t4,$t3,768	# assign $t4 to (37,7)	
	jal DRAW_Y
	addi $t3,$0,0x10008498	# assign $t3 to (38,4)
	sw $t1, 0($t3) 		# draws current pixel
	sw $t1, 512($t3) 	# draws pixel (38,6)
	addi $t3,$0,0x1000859c	# assign $t3 to (39,5)
	sw $t1, 0($t3) 	# draws current pixel
	sw $t1, 512($t3) 	# draws pixel (39,7)
	#draw e
	addi $t3,$0,0x100084A4	# assign $t3 to (41,4)
	addi $t4,$t3,768	# assign $t4 to (41,7)
	jal DRAW_Y
	addi $t3,$0,0x100084A8	# assign $t3 to (42,4)
	sw $t1, 0($t3) 		# draws current pixel
	sw $t1, 256($t3) 	# draws pixel (42,5)
	sw $t1, 768($t3)	# draws pixel (42,7)
	addi $t3,$0,0x100084Ac	# assign $t3 to (43,4)
	sw $t1, 0($t3) 		# draws current pixel
	sw $t1, 768($t3)	# draws pixel (43,7)
	#draw :
	addi $t3,$0,0x100084b4	# assign $t3 to (43,4)
	sw $t1, 0($t3) 		# draws current pixel
	sw $t1, 768($t3)	# draws pixel (43,7)
	#draw 3 digit
	addi $t3,$0,THIRD_DIGIT	# assign $t3 to (47,4)
	sw $t1, 0($t3) 		# draws current pixel
	sw $t1, 4($t3)		# draws pixel (48,4)
	sw $t1, 8($t3)		# draws pixel (49,4)
	sw $t1, 260($t3)	# draws pixel (48,5)
	sw $t1, 264($t3)	# draws pixel (49,5)
	sw $t1, 520($t3)	# draws pixel (49,6)
	sw $t1, 768($t3)	# draws pixel (47,7)
	sw $t1, 772($t3)	# draws pixel (48,7)
	sw $t1, 776($t3)	# draws pixel (49,7)
	#draw 0 digit 1
	addi $t3,$0,SECOND_DIGIT # assign $t3 to (51,4)
	sw $t1, 4($t3)		# draws pixel (52,4)
	sw $t1, 772($t3)	# draws pixel (52,7)
	addi $t4,$t3,768	# assign $t4 to (51,7)
	jal DRAW_Y		# draw line from $t3 to $t4
	addi $t3,$0,SECOND_DIGIT # assign $t3 to (55,4)
	addi $t3,$t3,8 		# assign $t3 to (53,4)
	addi $t4,$t3,768	# assign $t4 to (51,7)
	jal DRAW_Y		# draw line from $t3 to $t4
		
	#draw 0 digit 2
	addi $t3,$0,FIRST_DIGIT # assign $t3 to (55,4)
	sw $t1, 4($t3)		# draws pixel (56,4)
	sw $t1, 772($t3)	# draws pixel (56,7)
	addi $t4,$t3,768	# assign $t4 to (55,7)
	jal DRAW_Y		# draw line from $t3 to $t4
	addi $t3,$0,FIRST_DIGIT # assign $t3 to (55,4)
	addi $t3,$t3,8 		# assign $t3 to (57,4)
	addi $t4,$t3,768	# assign $t4 to (55,7)
	jal DRAW_Y		# draw line from $t3 to $t4
	j START_PRE_LOOP #start the loop

WIN_SCREEN:
	li $t1, 0xffffff # $t1 stores the colour white
	# draw y
	addi $t3,$0,0x1000994C	# assign $t3 to (19,25)
	addi $t4,$t3,512	# assign $t4 to (19,27)
	jal DRAW_Y
	addi $t3,$0,0x10009950	# assign $t3 to (20,25)
	addi $t4,$t3,768	# assign $t4 to (20,27)
	jal DRAW_Y
	
	addi $t3,$0,0x10009C54	# assign $t3 to (21,28)
	addi $t4,$t3,768	# assign $t4 to (21,31)
	jal DRAW_Y
	addi $t3,$0,0x10009C58	# assign $t3 to (22,28)
	addi $t4,$t3,768	# assign $t4 to (22,31)
	jal DRAW_Y
	
	addi $t3,$0,0x1000995C	# assign $t3 to (23,25)
	addi $t4,$t3,768	# assign $t4 to (23,27)
	jal DRAW_Y
	addi $t3,$0,0x10009960	# assign $t3 to (24,25)
	addi $t4,$t3,512	# assign $t4 to (24,27)
	jal DRAW_Y
	
	# draw o
	addi $t3,$0,0x10009A70	# assign $t3 to (28,26)
	addi $t4,$t3,1024	# assign $t4 to (28,30)
	jal DRAW_Y
	addi $t3,$0,0x10009a74	# assign $t3 to (29,26)
	addi $t4,$t3,1024	# assign $t4 to (29,30)
	jal DRAW_Y
	addi $t3,$0,0x10009a84	# assign $t3 to (33,26)
	addi $t4,$t3,1024	# assign $t4 to (33,30)
	jal DRAW_Y
	addi $t3,$0,0x10009a88	# assign $t3 to (34,26)
	addi $t4,$t3,1024	# assign $t4 to (34,30)
	jal DRAW_Y
	addi $t3,$0,0x10009974	# assign $t3 to (29,25)
	addi $t4,$t3,16	# assign $t4 to (33,25)
	jal DRAW_X
	addi $t3,$0,0x10009F74	# assign $t3 to (29,31)
	addi $t4,$t3,16	# assign $t4 to (33,31)
	jal DRAW_X

	#draw u
	addi $t3,$0,0x10009994	# assign $t3 to (37,25)
	addi $t4,$t3,1280	# assign $t4 to (37,30)
	jal DRAW_Y
	addi $t3,$0,0x10009998	# assign $t3 to (38,25)
	addi $t4,$t3,1280	# assign $t4 to (38,30)
	jal DRAW_Y
	addi $t3,$0,0x100099A8	# assign $t3 to (42,25)
	addi $t4,$t3,1280	# assign $t4 to (42,30)
	jal DRAW_Y
	addi $t3,$0,0x100099ac	# assign $t3 to (43,25)
	addi $t4,$t3,1280	# assign $t4 to (43,30)
	jal DRAW_Y
	addi $t3,$0,0x10009F98	# assign $t3 to (38,31)
	addi $t4,$t3,16	# assign $t4 to (42,31)
	jal DRAW_X
	# draw w
	addi $t3,$0,0x1000A44C	# assign $t3 to (19,36)
	addi $t4,$t3,1536	# assign $t4 to (19,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A450	# assign $t3 to (20,36)
	addi $t4,$t3,1536	# assign $t4 to (20,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A754	# assign $t3 to (21,39)
	addi $t4,$t3,512	# assign $t4 to (21,41)
	jal DRAW_Y
	addi $t3,$0,0x1000A658	# assign $t3 to (22,38)
	addi $t4,$t3,512	# assign $t4 to (20,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A75c	# assign $t3 to (23,39)
	addi $t4,$t3,512	# assign $t4 to (20,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A460	# assign $t3 to (24,36)
	addi $t4,$t3,1536	# assign $t4 to (24,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A464	# assign $t3 to (25,36)
	addi $t4,$t3,1536	# assign $t4 to (25,42)
	jal DRAW_Y
	# draw i
	addi $t3,$0,0x1000A474	# assign $t3 to (29,36)
	addi $t4,$t3,20	# assign $t4 to (34,36)
	jal DRAW_X
	addi $t3,$0,0x1000Aa74	# assign $t3 to (29,42)
	addi $t4,$t3,20	# assign $t4 to (34,42)
	jal DRAW_X
	addi $t3,$0,0x1000A57C	# assign $t3 to (31,37)
	addi $t4,$t3,1024	# assign $t4 to (24,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A580	# assign $t3 to (32,37)
	addi $t4,$t3,1024	# assign $t4 to (25,42)
	jal DRAW_Y
	#draw n
	addi $t3,$0,0x1000A494	# assign $t3 to (37,36)
	addi $t4,$t3,1536	# assign $t4 to (37,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A498	# assign $t3 to (38,36)
	addi $t4,$t3,1536	# assign $t4 to (38,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A59C	# assign $t3 to (39,37)
	addi $t4,$t3,512	# assign $t4 to (39,39)
	jal DRAW_Y
	addi $t3,$0,0x1000A6A0	# assign $t3 to (40,38)
	addi $t4,$t3,512	# assign $t4 to (40,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A7A4	# assign $t3 to (41,39)
	addi $t4,$t3,512	# assign $t4 to (41,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A4A8	# assign $t3 to (42,36)
	addi $t4,$t3,1536	# assign $t4 to (42,42)
	jal DRAW_Y
	addi $t3,$0,0x1000A4AC	# assign $t3 to (43,36)
	addi $t4,$t3,1536	# assign $t4 to (43,42)
	jal DRAW_Y
	
	
	
	
	j END

GAME_OVER_SCREEN:
	addi $t7,$0, DISPLAY_ADDRESS # assigns $t7 to the first pixel to remove
	addi $sp , $sp , -4 # push to stack
	sw $t7, 0($sp)
	jal CLEAR_SCREEN 	#clears the screen
	# draw game over and a skull
	#draw g
	li $t1, 0xffffff # $t1 stores the colour white
	addi $t3,$0,0x10008A38	# assign $t3 to (14,10)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (14,11)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (14,12)
	sw $t1, 0($t3)
	addi $t3,$0,0x1000893C	# assign $t3 to (15,9)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (15,10)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (15,11)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (15,12)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (15,13)
	sw $t1, 0($t3)
	addi $t3,$t3,4		# assign $t3 to (16,13)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (16,14)
	sw $t1, 0($t3)
	addi $t3,$t3,4		# assign $t3 to (17,14)
	sw $t1, 0($t3)
	addi $t3,$t3,4		# assign $t3 to (18,14)
	sw $t1, 0($t3)
	addi $t3,$t3,4		# assign $t3 to (19,14)
	sw $t1, 0($t3)
	addi $t3,$t3,4		# assign $t3 to (20,14)
	sw $t1, 0($t3)
	addi $t3,$t3,-256	# assign $t3 to (20,13)
	sw $t1, 0($t3)
	addi $t3,$t3,-256	# assign $t3 to (20,12)
	sw $t1, 0($t3)
	addi $t3,$t3,-256	# assign $t3 to (20,11)
	sw $t1, 0($t3)
	addi $t3,$t3,-4		# assign $t3 to (19,11)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (19,12)
	sw $t1, 0($t3)
	addi $t3,$t3,256	# assign $t3 to (19,13)
	sw $t1, 0($t3)
	addi $t3,$t3,-516	# assign $t3 to (18,11)
	sw $t1, 0($t3)
	addi $t3,$0,0x10008940 	# assign $t3 to (16,9)
	sw $t1, 0($t3)
	addi $t3,$0,0x10008840	# assign $t3 to (16,8)
	addi $t4,$0,0x10008850	# assign $t4 to (20,8)
	jal DRAW_X
	#draw a
	addi $t3,$0,0x10008A5C	# assign $t3 to (23,10)
	addi $t4,$t3,1024	# assign $t4 to (23,14)
	jal DRAW_Y
	addi $t3,$0,0x10008960	# assign $t3 to (24,9)
	addi $t4,$t3,1280	# assign $t4 to (24,14)
	jal DRAW_Y
	addi $t3,$0,0x10008970	# assign $t3 to (24,9)
	addi $t4,$t3,1280	# assign $t4 to (24,14)
	jal DRAW_Y
	addi $t3,$0,0x10008A74	# assign $t3 to (29,10)
	addi $t4,$t3,1024	# assign $t4 to (29,14)
	jal DRAW_Y
	addi $t3,$0,0x10008C64	# assign $t3 to (25,12)
	addi $t4,$t3,12	# assign $t4 to (27,12)
	jal DRAW_X
	addi $t3,$0,0x10008864	# assign $t3 to (25,8)
	addi $t4,$t3,8	# assign $t4 to (27,8)
	jal DRAW_X
	# draw m
	addi $t3,$0,0x10008880	# assign $t3 to (32,8)
	addi $t4,$t3,1536	# assign $t4 to (32,14)
	jal DRAW_Y
	addi $t3,$0,0x10008884	# assign $t3 to (33,8)
	addi $t4,$t3,1536	# assign $t4 to (33,14)
	jal DRAW_Y
	addi $t3,$0,0x10008894	# assign $t3 to (37,8)
	addi $t4,$t3,1536	# assign $t4 to (37,14)
	jal DRAW_Y
	addi $t3,$0,0x10008898	# assign $t3 to (38,8)
	addi $t4,$t3,1536	# assign $t4 to (38,14)
	jal DRAW_Y
	
	addi $t3,$0,0x10008988	# assign $t3 to (34,9)
	addi $t4,$t3,256	# assign $t4 to (34,10)
	jal DRAW_Y
	addi $t3,$0,0x10008A8C	# assign $t3 to (35,10)
	addi $t4,$t3,256	# assign $t4 to (35,11)
	jal DRAW_Y
	addi $t3,$0,0x10008990	# assign $t3 to (36,9)
	addi $t4,$t3,256	# assign $t4 to (36,10)
	jal DRAW_Y
	# draw e
	addi $t3,$0,0x100088A4	# assign $t3 to (41,8)
	addi $t4,$t3,1536	# assign $t4 to (41,14)
	jal DRAW_Y
	addi $t3,$0,0x100088A8	# assign $t3 to (42,8)
	addi $t4,$t3,1536	# assign $t4 to (42,14)
	jal DRAW_Y
	addi $t3,$0,0x100088AC	# assign $t3 to (43,8)
	addi $t4,$t3,16	# assign $t4 to (47,8)
	jal DRAW_X
	addi $t3,$0,0x10008BAC	# assign $t3 to (43,11)
	addi $t4,$t3,12	# assign $t4 to (47,11)
	jal DRAW_X		
	addi $t3,$0,0x10008EAC	# assign $t3 to (43,14)
	addi $t4,$t3,16	# assign $t4 to (47,14)
	jal DRAW_X
	#draw o
	addi $t3,$0,0x10009438	# assign $t3 to (14,20)
	addi $t4,$t3,1024	# assign $t4 to (14,24)
	jal DRAW_Y
	addi $t3,$0,0x1000943c	# assign $t3 to (15,20)
	addi $t4,$t3,1024	# assign $t4 to (15,24)
	jal DRAW_Y
	addi $t3,$0,0x1000944c	# assign $t3 to (19,20)
	addi $t4,$t3,1024	# assign $t4 to (19,24)
	jal DRAW_Y
	addi $t3,$0,0x10009450	# assign $t3 to (20,20)
	addi $t4,$t3,1024	# assign $t4 to (20,24)
	jal DRAW_Y
	addi $t3,$0,0x1000933C	# assign $t3 to (15,19)
	addi $t4,$t3,16	# assign $t4 to (19,19)
	jal DRAW_X
	addi $t3,$0,0x1000993C	# assign $t3 to (15,25)
	addi $t4,$t3,16	# assign $t4 to (19,25)
	jal DRAW_X
	# draw v
	addi $t3,$0,0x1000935C	# assign $t3 to (23,19)
	addi $t4,$t3,768	# assign $t4 to (23,22)
	jal DRAW_Y
	addi $t3,$0,0x10009360	# assign $t3 to (24,19)
	addi $t4,$t3,768	# assign $t4 to (24,22)
	jal DRAW_Y
	addi $t3,$0,0x10009760	# assign $t3 to (24,23)
	addi $t4,$t3,4	# assign $t4 to (25,23)
	jal DRAW_X
	addi $t3,$0,0x1000976c	# assign $t3 to (27,23)
	addi $t4,$t3,4	# assign $t4 to (28,23)
	jal DRAW_X
	addi $t3,$0,0x10009864	# assign $t3 to (25,24)
	addi $t4,$t3,8	# assign $t4 to (27,24)
	jal DRAW_X
	addi $t3,$0,0x10009370	# assign $t3 to (23,19)
	addi $t4,$t3,768	# assign $t4 to (23,22)
	jal DRAW_Y
	addi $t3,$0,0x10009374	# assign $t3 to (24,19)
	addi $t4,$t3,768	# assign $t4 to (24,22)
	jal DRAW_Y
	addi $t3,$0,0x10009968	# assign $t3 to (14,10)
	sw $t1, 0($t3)
	# draw e 2
	addi $t3,$0,0x10009380	# assign $t3 to (32,19)
	addi $t4,$t3,1536	# assign $t4 to (32,25)
	jal DRAW_Y
	addi $t3,$0,0x10009384	# assign $t3 to (33,19)
	addi $t4,$t3,1536	# assign $t4 to (33,25)
	jal DRAW_Y
	addi $t3,$0,0x10009388	# assign $t3 to (34,19)
	addi $t4,$t3,16	# assign $t4 to (38,19)
	jal DRAW_X
	addi $t3,$0,0x10009688	# assign $t3 to (34,22)
	addi $t4,$t3,12	# assign $t4 to (37,22)
	jal DRAW_X		
	addi $t3,$0,0x10009988	# assign $t3 to (34,25)
	addi $t4,$t3,16	# assign $t4 to (38,25)
	jal DRAW_X
	# draw r
	addi $t3,$0,0x100093A4	# assign $t3 to (41,19)
	addi $t4,$t3,1536	# assign $t4 to (41,25)
	jal DRAW_Y
	addi $t3,$0,0x100093A8	# assign $t3 to (42,19)
	addi $t4,$t3,1536	# assign $t4 to (42,25)
	jal DRAW_Y
	addi $t3,$0,0x100093AC	# assign $t3 to (42,19)
	addi $t4,$t3,12	# assign $t4 to (46,19)
	jal DRAW_X
	addi $t3,$0,0x100094B8	# assign $t3 to (46,20)
	addi $t4,$t3,512	# assign $t4 to (46,22)
	jal DRAW_Y
	addi $t3,$0,0x100094Bc	# assign $t3 to (47,20)
	addi $t4,$t3,512	# assign $t4 to (47,22)
	jal DRAW_Y
	addi $t3,$0,0x100096B4	# assign $t3 to (45,22)
	addi $t4,$t3,256	# assign $t4 to (45,24)
	jal DRAW_Y
	addi $t3,$0,0x100098B0	# assign $t3 to (44,24)
	addi $t4,$t3,8	# assign $t4 to (46,24)
	jal DRAW_X
	addi $t3,$0,0x100099B4	# assign $t3 to (45,25)
	addi $t4,$t3,8	# assign $t4 to (47,25)
	jal DRAW_X
	# draw skull
	addi $t3,$0,0x1000A870	# assign $t3 to (28,40)
	addi $t4,$t3,24	# assign $t4 to (34,40)
	jal DRAW_X
	addi $t3,$0,0x1000A96C	# assign $t3 to (27,41)
	addi $t4,$t3,32	# assign $t4 to (35,41)
	jal DRAW_X
	addi $t3,$0,0x1000Aa6C	# assign $t3 to (27,42)
	addi $t4,$t3,32	# assign $t4 to (35,42)
	jal DRAW_X
	addi $t3,$0,0x1000Ab6C	# assign $t3 to (27,43)
	addi $t4,$t3,32	# assign $t4 to (35,43)
	jal DRAW_X
	addi $t3,$0,0x1000Ac6C	# assign $t3 to (27,44)
	addi $t4,$t3,512	# assign $t4 to (27,46)
	jal DRAW_Y
	addi $t3,$0,0x1000AE70	# assign $t3 to (28,46)
	addi $t4,$t3,512	# assign $t4 to (28,48)
	jal DRAW_Y
	addi $t3,$0,0x1000AE74	# assign $t3 to (29,46)
	addi $t4,$t3,768	# assign $t4 to (29,49)
	jal DRAW_Y
	addi $t3,$0,0x1000AC78	# assign $t3 to (30,44)
	addi $t4,$t3,1024	# assign $t4 to (30,48)
	jal DRAW_Y
	addi $t3,$0,0x1000B07C	# assign $t3 to (31,48)
	addi $t4,$t3, 256	# assign $t4 to (32,49)
	jal DRAW_Y
	addi $t3,$0,0x1000AC80	# assign $t3 to (32,44)
	addi $t4,$t3,1024	# assign $t4 to (32,48)
	jal DRAW_Y
	addi $t3,$0,0x1000AE84	# assign $t3 to (33,46)
	addi $t4,$t3,768	# assign $t4 to (33,49)
	jal DRAW_Y
	addi $t3,$0,0x1000AE88	# assign $t3 to (34,46)
	addi $t4,$t3,512	# assign $t4 to (34,48)
	jal DRAW_Y
	addi $t3,$0,0x1000Ac8C	# assign $t3 to (35,44)
	addi $t4,$t3,512	# assign $t4 to (35,46)
	jal DRAW_Y
	
	
	j END	# end game
