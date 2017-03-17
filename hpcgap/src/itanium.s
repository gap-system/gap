// mark_description "Intel(R) C++ Compiler for Itanium(R)-based applications";
// mark_description "Version 8.1    Build 20051006 %s";
// mark_description "-S";
.ident "Intel(R) C++ Compiler for Itanium(R)-based applications"
.ident "-S"
	//.radix C
	.section .text, "xa", "progbits"
	.align 32
	.section .data, "wa", "progbits"
	.align 16
	.section .bss, "wa", "nobits"
	.align 16
	.section .rodata, "a", "progbits"
	.align 16
	.section .sdata, "was", "progbits"
	.align 16
	.section .sbss, "was", "nobits"
	.align 16
	.section .srodata, "as", "progbits"
	.align 16
	.section .data1, "wa", "progbits"
	.align 16
	.section .sdata1, "was", "progbits"
	.align 16
	.section .IA_64.unwind, "ao", "unwind"
	.align 4
	.section .IA_64.unwind_info, "a", "progbits"
	.align 8
	.file "trial.c"
	.section .data
	.section .text
	.align 64
// -- Begin  ItaniumRegisterStackTop
	.proc  ItaniumRegisterStackTop#
// Block 0: entry  Pred:     Succ: 1  -G
// Freq 1.0e+00
	.global ItaniumRegisterStackTop#

ItaniumRegisterStackTop:
 {  	.mii
	flushrs
	nop.i 0
	nop.i 0 ;;
}
 {   .mii
	mov	r8=ar.bsp				 //0:  2    2
	nop.i	0				
	nop.i	0 ;;				
// Block 1: exit  Pred: 0     Succ:  -GO
// Freq 1.0e+00
 }
 {   .mib
	nop.m	0				
	nop.i	0				
	br.ret.sptk.many	b0 ;;			 //0:  2    4
 }
	.section	.IA_64.unwind_info,	"a", "progbits"
	.align 8
__udt_ItaniumRegisterStackTop:
	data8 0x1000000000001				// length: 8 bytes
							// flags: 0x00
							// version: 1
	string "\x60\x03"				//R3: prologue size 3
	string "\x61\x03"				//R3: body size 3
	string "\x81"					//B1: label_state 1
	string "\x00\x00\x00"
	.section .IA_64.unwind, "ao", "unwind"
	data8 @segrel(ItaniumRegisterStackTop#)
	data8 @segrel(ItaniumRegisterStackTop#+0x20)
	data8 @segrel(__udt_ItaniumRegisterStackTop)
	.section .data
	.section .text
// -- End  ItaniumRegisterStackTop
	.endp  ItaniumRegisterStackTop#
	.section .data
// End
