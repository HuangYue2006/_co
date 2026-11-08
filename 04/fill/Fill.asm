// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// 作法：不斷讀 KBD；有按鍵 color=-1（全黑），否則 color=0（全白），
//       再把 SCREEN 到 SCREEN+8191 共 8192 個 word 全部填成 color。
(MAIN)
    @KBD
    D=M
    @BLACK
    D;JNE        // 有按鍵 → 黑
    @color
    M=0          // 沒按鍵 → 白
    @DRAW
    0;JMP
(BLACK)
    @color
    M=-1         // -1 = 0xFFFF，16 個像素全黑
(DRAW)
    @SCREEN
    D=A
    @addr
    M=D          // addr = SCREEN (16384)
(LOOP)
    @addr
    D=M
    @KBD
    D=D-A        // addr - KBD (24576)
    @MAIN
    D;JGE        // 畫完整個螢幕 → 回去重新讀鍵盤
    @color
    D=M
    @addr
    A=M
    M=D          // RAM[addr] = color
    @addr
    M=M+1        // addr++
    @LOOP
    0;JMP
