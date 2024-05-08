*=$0800 "BASIC Start"            // location to put a 1 line basic program so we can just
        .byte $00                // first byte of basic memory should be a zero
        .byte $0E, $08           // Forward address to next basic line
        .byte $0A, $00           // this will be line 10 ($0A)
        .byte $9E                // basic token for SYS
        .text " (2064)"
        .byte $00, $00, $00      // end of basic program (addr $080E from above)

*=$0810                                             //
!main_init:                                         //

    lda #1                                          // Load 1 into accumulator
    sta $d021                                       // Set white screen
    sta $d020                                       // Set white border 


    lda #$80                                        // disable SHIFT-Commodore
    sta $0291
    
    lda #<(nmi)                                     // \
    sta $0318                                       //  \ Load our new nmi vector
    lda #>(nmi)                                     //  / And replace the old vector to our own nmi routine
    sta $0319                                       // /  
    jsr $E544                                       // Clear screen
    lda #21                                         // Load 21 into accumulator and use it to
    sta $D018                                       // Switch to UPPER CASE 
    lda #0
    sta TIMER1
    sta RXFULL
    sta RXINDEX
      
!draw_playfield:
    displayText(text_border1,2,2)                   // use the displayText macro to draw the top line of the play field
    displayText(text_border3,20,2)                  // use the displayText macro to draw the bottom line of the play field

    ldx #2                                          // start our index at 2, because we start at line 2   
!drawloop:                                          // Draw all lines in between the top and bottom of the play field
    lda #2                                          //
    sta $f8                                         // store the column number ( also 2) in $f8
    inx                                             // increase x
    stx $f7                                         // $f7 = line number                                                                                                        
                                                    // $fb $fc = pointer to the text                                                      
    lda #<(text_border2)                            // store the lowbyte of the text location in address $fb
    sta $fb                                         // 
    lda #>(text_border2)                            // store the highbyte of the text location in $fc
    sta $fc                                         // $fb-fc now contains a pointer to the text            
    jsr !displaytextK+                              // Call the displaytext routine     
    cpx #19                                         // compare x to 19
    bne !drawloop-                                  // if NOT equal, go back to the loop
    
!drawArrow:                                         // now draw the big arrow on screen
    displayText(arrow1, 7, 32)
    displayText(arrow2, 8, 31)
    displayText(arrow3, 9, 32)
    
    displayText(arrow4, 10, 29)
    displayText(arrow5, 10, 36) 
    displayText(arrow3, 10, 32)
    displayText(arrow6, 11, 28)
    displayText(arrow7, 12, 29)
    displayText(arrow8, 12, 28)
    displayText(arrow9, 12, 37)
    displayText(arrow8, 13, 29)
    displayText(arrow9, 13, 36)
    displayText(arrow3, 13, 32)
    
    displayText(arrow3, 14, 32)
    displayText(arrow10,15, 31)
    displayText(arrow3, 15, 32)
    displayText(arrow11,16, 32)
    
    displayText(text_not_connected,19, 27)   
     
    lda #$01                                        //
    sta $d015                                       // turn on sprite
    sta $d01c                                       // set multicolor flags    
                                                    // set sprite colors
    lda #10                                         // color of the eyes
    sta $d025                                       //
    lda #13                                         // color of the lights on chest
    sta $d026                                       //
                                                    // colorize sprites body
    lda #0                                          // the body is black
    sta $d027                                       //
                                                    // positioning sprites
    lda #120                                        //
    sta $d000                                       // #0. sprite X low byte
    lda #130
    sta $d001                                       // #0. sprite Y
                                                    // X coordinate high byte
    lda #$00                                        //
    sta $d010                                       //   
                                                    // set sprite pointers
    lda #$3e                                        // my sprite data starts at $0f80, devide that by $40 = $3e
    sta $07F8                                       //

!main_loop:                                         // start of the main loop

!clear_arrows:                                      // clear the big arrows
    jsr !clear_arrow_colors+                        //

!read_stick2:                                       // Read joystick 2
                                                    //
    lda #10                                         // a small delay to move the sprite a bit slower
    sta DELAY                                       //
    jsr !delay+                                     // jump to the delay sub routine
    lda #0                                          //
    sta $d800                                       //
    sta $d801                                       //
                                                    //
    lda $DC00                                       // read the position of joystick2    
    cmp #127                                        // compare to 127 (=middle position)
    bne !+                                          // if the joystick is NOT in the middle postion, skip to next ! label
    jsr !are_we_connected+                          // check if we are connected with bluetooth
    jsr !clear_arrows-                              // clear the big arrows
    jmp !read_stick2-                               // jump back to read the position of the joystick
                                                    //
!:  cmp #111                                        // if $dc00 is 111, that means you pressed the fire button
    bne !+                                          // middle position with fire button 
    jsr !sound+
    jmp !read_stick2-   
                                                    //    
!:  cmp #126                                        // up
    bne !+
    jsr !do_up+ 
    jmp !read_stick2-
                                                    //     
!:  cmp #110                                        // up with fire button
    bne !+
    jsr !do_up+
    jmp !read_stick2-
                                                    //        
!:  cmp #125                                        // down
    bne !+
    jsr !do_down+
    jmp !read_stick2-
                                                    //    
!:  cmp #109                        				// down with fire button
    bne !+
    jsr !do_down+
    jmp !read_stick2-
                                                    //
!:  cmp #123                        				// left
    bne !+
    jsr !do_left+
    jmp !read_stick2-
                                                    //    
!:  cmp #107                        				// left with fire button    
    bne !+  
    jsr !do_left+
    jmp !read_stick2-
                                                    //        
!:  cmp #119                        				// right
    bne !+
    jsr !do_right+
    jmp !read_stick2-
                                                    //    
!:  cmp #103                        				// right with fire button   
    bne !+  
    jsr !do_right+
    jmp !read_stick2-
                                                    //     
!:  cmp #122                        				// up left
    bne !+
    jsr !do_up_left+
    jmp !read_stick2-
                                                    //    
!:  cmp #106                        				// up left with fire button
    bne !+
    jsr !do_up_left+
    jmp !read_stick2-
                                                    //    
!:  cmp #118                        				// up right
    bne !+
    jsr !do_up_right+   
    jmp !read_stick2-   
                                                    //        
!:  cmp #102                        				// up right with fire button
    bne !+
    jsr !do_up_right+
    jmp !read_stick2-
                                                    //    
!:  cmp #121                        				// down left
    bne !+
    jsr !do_down_left+
    jmp !read_stick2-
!:  cmp #105                        				// down left with fire button
    bne !+
    jsr !do_down_left+
    jmp !read_stick2-
                                                    //    
!:  cmp #117                        				// down right
    bne !+
    jsr !do_down_right+
    jmp !read_stick2-
!:  cmp #101                        				// down right with fire button
    bne !+
    jsr !do_down_right+
    jmp !read_stick2-   
!:
jmp !read_stick2-
                                                    //    
    
!sound:
    lda #86                                         // Load 'V'
    sta $de00                                       // write the byte to IO1    
    lda #255                                        //
    sta DELAY                                       //
    jsr !delay+                                     //
    lda #32
    sta $400
    rts
    
!do_up:         
    lda #70                                         // Load 'F'
    sta $de00                                       // write the byte to IO1
    jsr !color_up+      
    lda #0 ; sta $fe
    jsr !color_down+
    jsr !color_left+
    jsr !color_right+
    lda #1; sta $fe 
    jsr !sprite_up+
    rts

!do_up_left:        
    lda #71                                         // Load 'G'
    sta $de00                                       // write the byte to IO1        
    jsr !color_up+      
    jsr !color_left+        
    lda #0 ; sta $fe
    jsr !color_down+
    jsr !color_right+
    lda #1; sta $fe 
    jsr !sprite_up+
    jsr !sprite_left+
    rts 
        
!do_up_right:       
    lda #73                                         // Load 'I'
    sta $de00                                       // write the byte to IO1             
    jsr !color_up+      
    jsr !color_right+       
    lda #0 ; sta $fe
    jsr !color_down+
    jsr !color_left+
    lda #1; sta $fe 
    jsr !sprite_right+
    jsr !sprite_up+     
    rts

!do_down_left:      
    lda #72                                         // Load 'H'
    sta $de00                                       // write the byte to IO1            
    jsr !color_down+        
    jsr !color_left+        
    lda #0 ; sta $fe
    jsr !color_up+
    jsr !color_right+
    lda #1; sta $fe 
    jsr !sprite_down+
    jsr !sprite_left+
    rts

!do_down_right:     
    lda #74                                         // Load 'J'
    sta $de00                                       // write the byte to IO1            
    jsr !color_down+        
    jsr !color_right+       
    lda #0 ; sta $fe
    jsr !color_up+
    jsr !color_left+
    lda #1; sta $fe             
    jsr !sprite_down+           
    jsr !sprite_right+          
    rts 
        
!do_right:
    lda #82                                         // Load 'R'
    sta $de00                                       // write the byte to IO1    
    jsr !color_right+
    lda #0 ; sta $fe
    jsr !color_up+
    jsr !color_left+
    jsr !color_down+
    lda #1; sta $fe
    jsr !sprite_right+
    rts

!do_left:
    lda #76                                         // Load 'L'
    sta $de00                                       // write the byte to IO1    
    jsr !color_left+
    lda #0 ; sta $fe
    jsr !color_up+
    jsr !color_right+
    jsr !color_down+
    lda #1; sta $fe 
    jsr !sprite_left+
    rts

!do_down:
    lda #66                                         // Load 'B'
    sta $de00                                       // write the byte to IO1
    jsr !color_down+
    lda #0 ; sta $fe
    jsr !color_up+
    jsr !color_left+
    jsr !color_right+
    lda #1; sta $fe
    jsr !sprite_down+   
    rts
                                                    //
!sprite_up:                 
    ldx $d001
    cpx #70
    bcc !+
    dec $d001
!:  rts
                                                    //    
!sprite_down:
    ldx $d001
    cpx #194
    bcs !+
    inc $d001
!:  rts
                                                    //
!sprite_left:
    ldx $d000
    cpx #43
    bcc !+
    dec $d000
!:  rts
                                                    //    
!sprite_right:
    ldx $d000
    cpx #205
    bcs !+
    inc $d000
!:  rts
                                                    //
                                                    //
!are_we_connected:
    
    lda RXFULL
    cmp #0
    bne !result+
                                                    //    
    lda #$fb
  !wait:
    cmp $d012    
    bne !wait-
                                                    //    
    inc TIMER1
    lda TIMER1
    cmp #30
    bne !exit+
    
    lda #0
    sta TIMER1  
                                                    //
    												//jsr !wait_for_ready_to_receive+       
    lda #254                                        // Load number #230 (to check if the esp32 is connected)
    sta $de00                                       // write the byte to IO1    
    jmp !exit+                                                                                      
                                                    
!result:                                                    
    lda #0
    sta RXFULL
    sta RXINDEX                                                 
                                                    //    
    displayText(text_not_connected,19, 27)    
    lda RXBUFFER
    cmp #0
    beq !exit+     
    displayText(text_connected,19, 27)                                                  
    rts
!exit: 
    lda #83                         				// Load 'S'
    sta $de00                       				// write the byte to IO1
    rts
                                                    //
//=========================================================================================================
// SUB ROUTINE, WAIT FOR READY TO RECIEVE SIGNAL FROM ESP32
//=========================================================================================================

!wait_for_ready_to_receive:                         // wait for ready to receive before we send a byte
                                                    //
    lda $df00                                       // read a value from IO2
    cmp #128                                        // compare with 128
    bcc !wait_for_ready_to_receive-                 // if smaller try again
    rts                                             //
    
    
//=========================================================================================================
// SUB ROUTINE, DELAY
//=========================================================================================================    

!delay:                                             // the delay sub routine is just a loop inside a loop
                                                    //
    ldx #00                                         // the inner loop counts up to 255
                                                    //
!loop:                                              // the outer loop repeats that 255 times
                                                    //
    cpx DELAY                                       //
    beq !enddelay+                                  //
    inx                                             //
    ldy #00                                         //
                                                    //
!delay:                                             //
                                                    //
    cpy #255                                        //
    beq !loop-                                      //   
    nop                                             //
    nop                                             //
    iny                                             //
    jmp !delay-                                     //
                                                    //
!enddelay:                                          //
                                                    //
    rts                                             //
    
//=========================================================================================================
// Color arrows routines
//========================================================================================================= 
!clear_arrow_colors:    
    lda #0                                          // overwrite the arrow color
    sta $fe
    jsr !color_up+
    jsr !color_right+
    jsr !color_left+
    jsr !color_down+
    lda #1
    sta $fe
    rts
    
    
!color_up:  
    colorText(5, 7,32,2)                            // parameters: color, line, column, length
    colorText(5, 8,31,4)
    colorText(5, 9,32,2)    
    rts
    
!color_left:    
    colorText(5, 10,29,1)
    colorText(5, 11,28,2)   
    colorText(5, 12,28,2)   
    colorText(5, 13,29,1)   
    rts
    
!color_right:   
    colorText(5, 10,36,1)
    colorText(5, 11,35,2)   
    colorText(5, 12,35,2)   
    colorText(5, 13,36,1)   
    rts

!color_down:    
    colorText(5, 14,32,2)
    colorText(5, 15,31,4)
    colorText(5, 16,32,2)
    rts
    
//=========================================================================================================
// NMI ROUTINE
//=========================================================================================================
nmi:                                                // When the ESP32 loads a byte in the 74ls244 it pulls the NMI line low
                                                    // to signal the C64. Telling it to read the byte
    pushreg()                                       //
    
    lda $df00                                       // read from IO2. This causes the IO2 line on the cartridge port to go low. Now the ESP32 knows the byte has been received.
    ldx RXINDEX                                     // Load the buffer index into x
    sta RXBUFFER,x                                  // write the byte into the buffer index at position x  
    cmp #128                                        // a message is complete when we receive 128
    beq !message_complete+                          // jump to then label "message complete" when the message is complete
    inx                                             // increase the x value
    stx RXINDEX                                     // store new x value in RXINDEX
    jmp  !exit_nmi+                                 // jump to the exit of this routine
                                                    // 
!message_complete:                                  //
                                                    // color the border black
    lda RXINDEX                                     // load the value of RXINDEX to see how much we have in the buffer
    cmp #0                                          // if the index is still 0, the buffer is empty, set RXFULL to 2 in that case 
    bne !not_empty+                                 // jump to the next label if the buffer is NOT empty
    lda #2                                          // RXFULL=2 means there is no message in buffer
    sta RXFULL                                      // store #2 in the RXFULL indicator
    jmp  !exit_nmi+                                 // and exit the routine
                                                    //  
!not_empty:                                         // if the message is not empty
                                                    //
    lda #1                                          // Store #1 in the RXFULL indicator
    sta RXFULL                                      //
                                                    //   
!exit_nmi:                                          //
    lda #$01                                        // acknoledge the nmi interrupt
    sta $dd0d                                       // you MUST write and read this address to acknoledge the nmi interrupt 
    lda $dd0d                                       // you MUST write and read this address to acknoledge the nmi interrupt
    popreg()                                        //
    rti                                             // return interupt

//=========================================================================================================
//  SUB ROUTINE DISPLAY TEXT 
//=========================================================================================================
!displaytextK:                      
                                                    // first we find out if the text needs to be inverted
                                                    // if the first byte in the text is 143, we will invert the text
                                                    // Inverting the text is done by adding, or bitwise OR, with the number 128
                                                    // see the ora $4b command further down
                                                
    
    lda #0                                          // by default $4b contains 0 so invertion does not work
    sta $02
    sta $4b                                         //      
    ldy #0
    lda ($fb),y                                     // load the very first character of the text
    cmp #143                                        // if it is not equal to 143, do nothing, skip to the next !: label
    bne !+                                          //
    lda #128                                        // if the text starts with 143, load the number 128
    sta $4b                                         // in to address $4b
    inc $02                                         // increase the start index, so the byte 143 is skipped
                                                    //
!:                                                  // $f7 = line number
                                                    // $f8 = column
                                                    // $fb $fc = pointer to the text                                                    
    ldx $f7                                         // zero page f7 has the line number where the text should be displayed
    lda screen_lines_low,x                          // we need to create a pointer in $c1 $c2 to the location in screen RAM
    sta $c1                                         // and a pointer in $c3 $c4 to the location in color RAM
    sta $c3                                         // the lower byte of the color ram is the same as the screen ram
    lda screen_lines_high,x                         // get the high byte for the screen ram
    sta $c2                                         // store it in $c2 to complete the pointer
    lda color_lines_high,x                          
    sta $c4                                         // we now have pointers to the line, we need to add the column to end up in the exact address
    
    clc                                             // Clear the carry flag, we are going to do some additions (adc) so we need to clear the flag
    lda $c3                                         // load the low byte of the pointer to color RAM (the pointer is in $c3,$c4)
    adc $f8                                         // add the column number (stored in $f8)
    sta $c3                                         // put the result back in $c3 (the low byte for the screen RAM pointer)
    sta $c1                                         // Also put the same value in $c1 (the low byte for the color RAM pointer)
    bcc !setup_index+                               // if the result was bigger than #$FF (#255) then the carry flag is set and we need to increase the high byte of the pointer also
    inc $c4                                         // increase the high byte of the screen RAM pointer with one
    inc $c2                                         // and also the high byte of the color RAM pointer
    
!setup_index:                                       //
    ldy $02                                         // load start index into y, y will be our index. It has to be y because we will use Indirect-indexed addressing (this is zero in most cases. except for when we receive messages)                                                                                                   
    sty $ff                                         // we need two indexes, one for reading the buffer                                              
    ldy #0                                          //
    sty $fe                                         // and one for writing to the screen and color RAM
                                                    // we can not use one index because the buffer may contain bytes for changing the color (144 = black, 145=white, etc)                                                   
!readbuffer:                                        // 
    ldy $ff                                         // load the buffer index from address $ff
    lda ($fb),y                                     // load a character from the text with y as index this is Indirect-indexed addressing, $fb-$fc contains a pointer to the real address
    cmp #128                                        // compare it to 128, that is the end marker of the text we want to display
    beq !exit+                                      // if equal, exit the loop
    inc $ff                                         // increase the buffer index
    cmp #144                                        // if the byte is 144 or higher, it is not a character but a color code
    bcc !+                                          // if not skip to the next !: label
    sta $f7                                         // store the color code in this address
jmp !readbuffer-                                    // and jump back to read the next byte from the text/buffer

!:  ldy $fe                                         // load the screen index into y
    ora $4b                                         // do a bitwise OR operation with the number in address $4b. If the number is 0 nothing will happen. If the number is 128 the character will invert! 
    sta ($c1),y                                     // write the character, $c1-$c2 contains a pointer to the address of screen RAM, y is the offset
    lda $f7                                         // load the current color from $f7. this adres contains the current color    
    sta ($c3),y                                     // change the color of the character, $c3-$c4 contains a pointer an address in color RAM, y is the offset
    inc $fe                                         // increase the screen index 
    jmp !readbuffer-                                // jump back to the beginning of the loop to read the next byte from the text/buffer
                                                    //
!exit:                                              // at this point we encountered byte 128 in out text string, so we escaped the loop 
    rts                                             // return to sender ;-)

//=========================================================================================================
// COLOR THE TEXT
//=========================================================================================================
!set_screen_color:                                  // $f7 = line number
                                                    // $f8 = column
                                                    // $fb = color                                                  
    lda $fc                                         // $fc = length of text                                             
    tay                                             
    ldx $f7                                         // zero page f7 has the line number where the text color should be changed
    lda screen_lines_low,x                          // we need to create a pointer in $c1 $c2 to the location in screen RAM
                                                    // and a pointer in $c3 $c4 to the location in color RAM
    sta $c3                                         // the lower byte of the color ram is the same as the screen ram
                                                    // get the high byte for the screen ram
                                                    // store it in $c2 to complete the pointer
    lda color_lines_high,x                          
    sta $c4                                         // we now have pointers to the line, we need to add the column to end up in the exact address
    
    clc                                             // Clear the carry flag, we are going to do some additions (adc) so we need to clear the flag
    lda $c3                                         // load the low byte of the pointer to color RAM (the pointer is in $c3,$c4)
    adc $f8                                         // add the column number (stored in $f8)
    sta $c3                                         // put the result back in $c3 (the low byte for the screen RAM pointer)
    
    bcc !setup_index+                               // if the result was bigger than #$FF (#255) then the carry flag is set and we need to increase the high byte of the pointer also
    inc $c4                                         // increase the high byte of the screen RAM pointer with one    

!setup_index:   
    lda $fe
    cmp #1
    beq !mloop+
    sta $fb
!mloop:  
    lda $fb
    sta ($c3),y
    dey
    bne !mloop-
    sta ($c3),y
!exit:                                              //  
    rts                                             // return to sender ;-)
    
//=========================================================================================================
// CONSTANTS
//=========================================================================================================
text_border1:                       .byte 144,79 ,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,80 ,128
text_border2:                       .byte 144,101,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,32 ,106,128
text_border3:                       .byte 144,76 ,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,111,122,128
arrow1:                             .byte 143,144,105,95,128    
arrow2:                             .byte 143,144,105,32,32,95,128  
arrow3:                             .byte 143,144,32,32,128 
arrow4:                             .byte 143,144,105,128
arrow5:                             .byte 143,144,95,128
arrow6:                             .byte 143,144,105,32,32,32,32,32,32,32,32,95,128
arrow7:                             .byte 143,144,32,32,32,32,32,32,32,32,128
arrow8:                             .byte 144,95,128
arrow9:                             .byte 144,105,128
arrow10:                            .byte 144,95,32,32,105,128
arrow11:                            .byte 144,95,105,128
text_not_connected:                 .byte 146; .text "not connected"; .byte 128
text_connected:                     .byte 149; .text "  connected  "; .byte 128

arrow_up:                           .word $d800; .byte 128
arrow_down:
arrow_left:
arrow_right:
screen_lines_low:                   .byte $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$e0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
screen_lines_high:                  .byte $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,07,$07
color_lines_high:                   .byte $d8,$d8,$d8,$d8,$d8,$d8,$d8,$d9,$d9,$d9,$d9,$d9,$d9,$da,$da,$da,$da,$da,$da,$da,$db,$db,$db,$db,$db

*=$0f80 "Sprite Data"
sprite1:    .byte $02, $AA, $80, $02, $AA, $80, $02, $69, $80, $02, $69, $80, $02, $AA, $80, $02, $AA, $80, $02, $AA, $80
            .byte $00, $28, $00, $2A, $AA, $A8, $AA, $AA, $AA, $AA, $AA, $AA, $8B, $77, $62, $8B, $77, $62, $8A, $AA, $A0
            .byte $8A, $AA, $A0, $0A, $AA, $A0, $0A, $AA, $A0, $2A, $AA, $A8, $2A, $AA, $A8, $2A, $AA, $A8, $28, $00, $28
            .byte 0


//=========================================================================================================
// VARIABLE BUFFERS
//=========================================================================================================
.segment Variables [start=$6000, max=$7fff, virtual]
//* = $1300 virtual
HOME_LINE:                          .byte 0         // the start line of the text input box
RXINDEX:                            .byte 0         // index for when we recieve data
RXFULL:                             .byte 0         // indicator if the buffer contains a complete message
RXBUFFER:                           .fill 256,128   // reserved space for incoming data
TXBUFFER:                           .fill 256,128   // reserved space for outgoing data
DELAY:                              .byte 0
TIMER1:                             .byte 0
//=========================================================================================================
// MACROS
//=========================================================================================================
.macro colorText(color, line,column, len){
    lda #line                                       // $f7 = line number
    sta $f7
    lda #column                                     // $f8 = column
    sta $f8
    lda #color                                      // $fb = color
    sta $fb
    lda #len                                        // $fc = length of text
    sta $fc
    jsr !set_screen_color-
}
                                    
                                                    
                                                        

.macro displayText(text,line,column){               //
                                                    // $f7 = line number
                                                    // $f8 = column
                                                    // $fb $fc = pointer to the text
                                                    //
    lda #line                                       //
    sta $f7                                         // store the line in zero page address $f7
    lda #column                                     //
    sta $f8                                         // store the column in zero page address $f8  
    lda #<(text)                                    // store the lowbyte of the text location in zero page address $fb
    sta $fb                                         // $fb is a zero page address
    lda #>(text)                                    // store the highbyte of the text location in $fc
    sta $fc                                         // $FC is is a zero page address            
    jsr !displaytextK-                              // Call the displaytext routine

}                                                   //
                                                    //
.macro pushreg(){                                   //
                                                    //
    php                                             // push the status register to stack
    pha                                             // push A to stack
    txa                                             // move x to a
    pha                                             // push it to the stack
    tya                                             // move y to a
    pha                                             // push it to the stack
}                                                   //
                                                    //
.macro popreg(){                                    //
                                                    //
    pla                                             // pull the y register from the stack
    tay                                             // move it to the y register
    pla                                             // pull the x register from the stack
    tax                                             // move it to the x register
    pla                                             // pull the acc from the stack
    plp                                             // pull the the processor status from the stack                                                 //
}                                                   //                                                  
