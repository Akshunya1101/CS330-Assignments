
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	c3013103          	ld	sp,-976(sp) # 80009c30 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = TIMER_INTERVAL; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	0000a717          	auipc	a4,0xa
    80000054:	03070713          	addi	a4,a4,48 # 8000a080 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00007797          	auipc	a5,0x7
    80000066:	6fe78793          	addi	a5,a5,1790 # 80007760 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd57ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	36a080e7          	jalr	874(ra) # 80003494 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	77e080e7          	jalr	1918(ra) # 800008b8 <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00012517          	auipc	a0,0x12
    8000018e:	03650513          	addi	a0,a0,54 # 800121c0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a3e080e7          	jalr	-1474(ra) # 80000bd0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00012497          	auipc	s1,0x12
    8000019e:	02648493          	addi	s1,s1,38 # 800121c0 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00012917          	auipc	s2,0x12
    800001a6:	0b690913          	addi	s2,s2,182 # 80012258 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305863          	blez	s3,80000220 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71463          	bne	a4,a5,800001e4 <consoleread+0x80>
      if(myproc()->killed){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	83e080e7          	jalr	-1986(ra) # 800019fe <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	5e0080e7          	jalr	1504(ra) # 800027b0 <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fef700e3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	08e4ac23          	sw	a4,152(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	01874703          	lbu	a4,24(a4)
    800001f6:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001fa:	077d0563          	beq	s10,s7,80000264 <consoleread+0x100>
    cbuf = c;
    800001fe:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000202:	4685                	li	a3,1
    80000204:	f9f40613          	addi	a2,s0,-97
    80000208:	85d2                	mv	a1,s4
    8000020a:	8556                	mv	a0,s5
    8000020c:	00003097          	auipc	ra,0x3
    80000210:	232080e7          	jalr	562(ra) # 8000343e <either_copyout>
    80000214:	01850663          	beq	a0,s8,80000220 <consoleread+0xbc>
    dst++;
    80000218:	0a05                	addi	s4,s4,1
    --n;
    8000021a:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021c:	f99d1ae3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000220:	00012517          	auipc	a0,0x12
    80000224:	fa050513          	addi	a0,a0,-96 # 800121c0 <cons>
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	a5c080e7          	jalr	-1444(ra) # 80000c84 <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xe4>
        release(&cons.lock);
    80000236:	00012517          	auipc	a0,0x12
    8000023a:	f8a50513          	addi	a0,a0,-118 # 800121c0 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a46080e7          	jalr	-1466(ra) # 80000c84 <release>
        return -1;
    80000246:	557d                	li	a0,-1
}
    80000248:	70a6                	ld	ra,104(sp)
    8000024a:	7406                	ld	s0,96(sp)
    8000024c:	64e6                	ld	s1,88(sp)
    8000024e:	6946                	ld	s2,80(sp)
    80000250:	69a6                	ld	s3,72(sp)
    80000252:	6a06                	ld	s4,64(sp)
    80000254:	7ae2                	ld	s5,56(sp)
    80000256:	7b42                	ld	s6,48(sp)
    80000258:	7ba2                	ld	s7,40(sp)
    8000025a:	7c02                	ld	s8,32(sp)
    8000025c:	6ce2                	ld	s9,24(sp)
    8000025e:	6d42                	ld	s10,16(sp)
    80000260:	6165                	addi	sp,sp,112
    80000262:	8082                	ret
      if(n < target){
    80000264:	0009871b          	sext.w	a4,s3
    80000268:	fb677ce3          	bgeu	a4,s6,80000220 <consoleread+0xbc>
        cons.r--;
    8000026c:	00012717          	auipc	a4,0x12
    80000270:	fef72623          	sw	a5,-20(a4) # 80012258 <cons+0x98>
    80000274:	b775                	j	80000220 <consoleread+0xbc>

0000000080000276 <consputc>:
{
    80000276:	1141                	addi	sp,sp,-16
    80000278:	e406                	sd	ra,8(sp)
    8000027a:	e022                	sd	s0,0(sp)
    8000027c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027e:	10000793          	li	a5,256
    80000282:	00f50a63          	beq	a0,a5,80000296 <consputc+0x20>
    uartputc_sync(c);
    80000286:	00000097          	auipc	ra,0x0
    8000028a:	560080e7          	jalr	1376(ra) # 800007e6 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	54e080e7          	jalr	1358(ra) # 800007e6 <uartputc_sync>
    800002a0:	02000513          	li	a0,32
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	542080e7          	jalr	1346(ra) # 800007e6 <uartputc_sync>
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	538080e7          	jalr	1336(ra) # 800007e6 <uartputc_sync>
    800002b6:	bfe1                	j	8000028e <consputc+0x18>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	1101                	addi	sp,sp,-32
    800002ba:	ec06                	sd	ra,24(sp)
    800002bc:	e822                	sd	s0,16(sp)
    800002be:	e426                	sd	s1,8(sp)
    800002c0:	e04a                	sd	s2,0(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00012517          	auipc	a0,0x12
    800002ca:	efa50513          	addi	a0,a0,-262 # 800121c0 <cons>
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	902080e7          	jalr	-1790(ra) # 80000bd0 <acquire>

  switch(c){
    800002d6:	47d5                	li	a5,21
    800002d8:	0af48663          	beq	s1,a5,80000384 <consoleintr+0xcc>
    800002dc:	0297ca63          	blt	a5,s1,80000310 <consoleintr+0x58>
    800002e0:	47a1                	li	a5,8
    800002e2:	0ef48763          	beq	s1,a5,800003d0 <consoleintr+0x118>
    800002e6:	47c1                	li	a5,16
    800002e8:	10f49a63          	bne	s1,a5,800003fc <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ec:	00003097          	auipc	ra,0x3
    800002f0:	1fe080e7          	jalr	510(ra) # 800034ea <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00012517          	auipc	a0,0x12
    800002f8:	ecc50513          	addi	a0,a0,-308 # 800121c0 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	988080e7          	jalr	-1656(ra) # 80000c84 <release>
}
    80000304:	60e2                	ld	ra,24(sp)
    80000306:	6442                	ld	s0,16(sp)
    80000308:	64a2                	ld	s1,8(sp)
    8000030a:	6902                	ld	s2,0(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0af48e63          	beq	s1,a5,800003d0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000318:	00012717          	auipc	a4,0x12
    8000031c:	ea870713          	addi	a4,a4,-344 # 800121c0 <cons>
    80000320:	0a072783          	lw	a5,160(a4)
    80000324:	09872703          	lw	a4,152(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf763e3          	bltu	a4,a5,800002f4 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x14a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	f3c080e7          	jalr	-196(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000342:	00012797          	auipc	a5,0x12
    80000346:	e7e78793          	addi	a5,a5,-386 # 800121c0 <cons>
    8000034a:	0a07a703          	lw	a4,160(a5)
    8000034e:	0017069b          	addiw	a3,a4,1
    80000352:	0006861b          	sext.w	a2,a3
    80000356:	0ad7a023          	sw	a3,160(a5)
    8000035a:	07f77713          	andi	a4,a4,127
    8000035e:	97ba                	add	a5,a5,a4
    80000360:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000364:	47a9                	li	a5,10
    80000366:	0cf48563          	beq	s1,a5,80000430 <consoleintr+0x178>
    8000036a:	4791                	li	a5,4
    8000036c:	0cf48263          	beq	s1,a5,80000430 <consoleintr+0x178>
    80000370:	00012797          	auipc	a5,0x12
    80000374:	ee87a783          	lw	a5,-280(a5) # 80012258 <cons+0x98>
    80000378:	0807879b          	addiw	a5,a5,128
    8000037c:	f6f61ce3          	bne	a2,a5,800002f4 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000380:	863e                	mv	a2,a5
    80000382:	a07d                	j	80000430 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000384:	00012717          	auipc	a4,0x12
    80000388:	e3c70713          	addi	a4,a4,-452 # 800121c0 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	00012497          	auipc	s1,0x12
    80000398:	e2c48493          	addi	s1,s1,-468 # 800121c0 <cons>
    while(cons.e != cons.w &&
    8000039c:	4929                	li	s2,10
    8000039e:	f4f70be3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	37fd                	addiw	a5,a5,-1
    800003a4:	07f7f713          	andi	a4,a5,127
    800003a8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003aa:	01874703          	lbu	a4,24(a4)
    800003ae:	f52703e3          	beq	a4,s2,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003b2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b6:	10000513          	li	a0,256
    800003ba:	00000097          	auipc	ra,0x0
    800003be:	ebc080e7          	jalr	-324(ra) # 80000276 <consputc>
    while(cons.e != cons.w &&
    800003c2:	0a04a783          	lw	a5,160(s1)
    800003c6:	09c4a703          	lw	a4,156(s1)
    800003ca:	fcf71ce3          	bne	a4,a5,800003a2 <consoleintr+0xea>
    800003ce:	b71d                	j	800002f4 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d0:	00012717          	auipc	a4,0x12
    800003d4:	df070713          	addi	a4,a4,-528 # 800121c0 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f70ae3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	00012717          	auipc	a4,0x12
    800003ea:	e6f72d23          	sw	a5,-390(a4) # 80012260 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	e84080e7          	jalr	-380(ra) # 80000276 <consputc>
    800003fa:	bded                	j	800002f4 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fc:	ee048ce3          	beqz	s1,800002f4 <consoleintr+0x3c>
    80000400:	bf21                	j	80000318 <consoleintr+0x60>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e72080e7          	jalr	-398(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040c:	00012797          	auipc	a5,0x12
    80000410:	db478793          	addi	a5,a5,-588 # 800121c0 <cons>
    80000414:	0a07a703          	lw	a4,160(a5)
    80000418:	0017069b          	addiw	a3,a4,1
    8000041c:	0006861b          	sext.w	a2,a3
    80000420:	0ad7a023          	sw	a3,160(a5)
    80000424:	07f77713          	andi	a4,a4,127
    80000428:	97ba                	add	a5,a5,a4
    8000042a:	4729                	li	a4,10
    8000042c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000430:	00012797          	auipc	a5,0x12
    80000434:	e2c7a623          	sw	a2,-468(a5) # 8001225c <cons+0x9c>
        wakeup(&cons.r);
    80000438:	00012517          	auipc	a0,0x12
    8000043c:	e2050513          	addi	a0,a0,-480 # 80012258 <cons+0x98>
    80000440:	00003097          	auipc	ra,0x3
    80000444:	942080e7          	jalr	-1726(ra) # 80002d82 <wakeup>
    80000448:	b575                	j	800002f4 <consoleintr+0x3c>

000000008000044a <consoleinit>:

void
consoleinit(void)
{
    8000044a:	1141                	addi	sp,sp,-16
    8000044c:	e406                	sd	ra,8(sp)
    8000044e:	e022                	sd	s0,0(sp)
    80000450:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000452:	00009597          	auipc	a1,0x9
    80000456:	bbe58593          	addi	a1,a1,-1090 # 80009010 <etext+0x10>
    8000045a:	00012517          	auipc	a0,0x12
    8000045e:	d6650513          	addi	a0,a0,-666 # 800121c0 <cons>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	6de080e7          	jalr	1758(ra) # 80000b40 <initlock>

  uartinit();
    8000046a:	00000097          	auipc	ra,0x0
    8000046e:	32c080e7          	jalr	812(ra) # 80000796 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000472:	00024797          	auipc	a5,0x24
    80000476:	b6e78793          	addi	a5,a5,-1170 # 80023fe0 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	cea70713          	addi	a4,a4,-790 # 80000164 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c7c70713          	addi	a4,a4,-900 # 80000100 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
}
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000496:	7179                	addi	sp,sp,-48
    80000498:	f406                	sd	ra,40(sp)
    8000049a:	f022                	sd	s0,32(sp)
    8000049c:	ec26                	sd	s1,24(sp)
    8000049e:	e84a                	sd	s2,16(sp)
    800004a0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0x12>
    800004a4:	08054763          	bltz	a0,80000532 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004a8:	2501                	sext.w	a0,a0
    800004aa:	4881                	li	a7,0
    800004ac:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b2:	2581                	sext.w	a1,a1
    800004b4:	00009617          	auipc	a2,0x9
    800004b8:	b8c60613          	addi	a2,a2,-1140 # 80009040 <digits>
    800004bc:	883a                	mv	a6,a4
    800004be:	2705                	addiw	a4,a4,1
    800004c0:	02b577bb          	remuw	a5,a0,a1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	97b2                	add	a5,a5,a2
    800004ca:	0007c783          	lbu	a5,0(a5)
    800004ce:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d2:	0005079b          	sext.w	a5,a0
    800004d6:	02b5553b          	divuw	a0,a0,a1
    800004da:	0685                	addi	a3,a3,1
    800004dc:	feb7f0e3          	bgeu	a5,a1,800004bc <printint+0x26>

  if(sign)
    800004e0:	00088c63          	beqz	a7,800004f8 <printint+0x62>
    buf[i++] = '-';
    800004e4:	fe070793          	addi	a5,a4,-32
    800004e8:	00878733          	add	a4,a5,s0
    800004ec:	02d00793          	li	a5,45
    800004f0:	fef70823          	sb	a5,-16(a4)
    800004f4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f8:	02e05763          	blez	a4,80000526 <printint+0x90>
    800004fc:	fd040793          	addi	a5,s0,-48
    80000500:	00e784b3          	add	s1,a5,a4
    80000504:	fff78913          	addi	s2,a5,-1
    80000508:	993a                	add	s2,s2,a4
    8000050a:	377d                	addiw	a4,a4,-1
    8000050c:	1702                	slli	a4,a4,0x20
    8000050e:	9301                	srli	a4,a4,0x20
    80000510:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000514:	fff4c503          	lbu	a0,-1(s1)
    80000518:	00000097          	auipc	ra,0x0
    8000051c:	d5e080e7          	jalr	-674(ra) # 80000276 <consputc>
  while(--i >= 0)
    80000520:	14fd                	addi	s1,s1,-1
    80000522:	ff2499e3          	bne	s1,s2,80000514 <printint+0x7e>
}
    80000526:	70a2                	ld	ra,40(sp)
    80000528:	7402                	ld	s0,32(sp)
    8000052a:	64e2                	ld	s1,24(sp)
    8000052c:	6942                	ld	s2,16(sp)
    8000052e:	6145                	addi	sp,sp,48
    80000530:	8082                	ret
    x = -xx;
    80000532:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000536:	4885                	li	a7,1
    x = -xx;
    80000538:	bf95                	j	800004ac <printint+0x16>

000000008000053a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053a:	1101                	addi	sp,sp,-32
    8000053c:	ec06                	sd	ra,24(sp)
    8000053e:	e822                	sd	s0,16(sp)
    80000540:	e426                	sd	s1,8(sp)
    80000542:	1000                	addi	s0,sp,32
    80000544:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000546:	00012797          	auipc	a5,0x12
    8000054a:	d207ad23          	sw	zero,-710(a5) # 80012280 <pr+0x18>
  printf("panic: ");
    8000054e:	00009517          	auipc	a0,0x9
    80000552:	aca50513          	addi	a0,a0,-1334 # 80009018 <etext+0x18>
    80000556:	00000097          	auipc	ra,0x0
    8000055a:	02e080e7          	jalr	46(ra) # 80000584 <printf>
  printf(s);
    8000055e:	8526                	mv	a0,s1
    80000560:	00000097          	auipc	ra,0x0
    80000564:	024080e7          	jalr	36(ra) # 80000584 <printf>
  printf("\n");
    80000568:	00009517          	auipc	a0,0x9
    8000056c:	24850513          	addi	a0,a0,584 # 800097b0 <syscalls+0x150>
    80000570:	00000097          	auipc	ra,0x0
    80000574:	014080e7          	jalr	20(ra) # 80000584 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000578:	4785                	li	a5,1
    8000057a:	0000a717          	auipc	a4,0xa
    8000057e:	a8f72323          	sw	a5,-1402(a4) # 8000a000 <panicked>
  for(;;)
    80000582:	a001                	j	80000582 <panic+0x48>

0000000080000584 <printf>:
{
    80000584:	7131                	addi	sp,sp,-192
    80000586:	fc86                	sd	ra,120(sp)
    80000588:	f8a2                	sd	s0,112(sp)
    8000058a:	f4a6                	sd	s1,104(sp)
    8000058c:	f0ca                	sd	s2,96(sp)
    8000058e:	ecce                	sd	s3,88(sp)
    80000590:	e8d2                	sd	s4,80(sp)
    80000592:	e4d6                	sd	s5,72(sp)
    80000594:	e0da                	sd	s6,64(sp)
    80000596:	fc5e                	sd	s7,56(sp)
    80000598:	f862                	sd	s8,48(sp)
    8000059a:	f466                	sd	s9,40(sp)
    8000059c:	f06a                	sd	s10,32(sp)
    8000059e:	ec6e                	sd	s11,24(sp)
    800005a0:	0100                	addi	s0,sp,128
    800005a2:	8a2a                	mv	s4,a0
    800005a4:	e40c                	sd	a1,8(s0)
    800005a6:	e810                	sd	a2,16(s0)
    800005a8:	ec14                	sd	a3,24(s0)
    800005aa:	f018                	sd	a4,32(s0)
    800005ac:	f41c                	sd	a5,40(s0)
    800005ae:	03043823          	sd	a6,48(s0)
    800005b2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b6:	00012d97          	auipc	s11,0x12
    800005ba:	ccadad83          	lw	s11,-822(s11) # 80012280 <pr+0x18>
  if(locking)
    800005be:	020d9b63          	bnez	s11,800005f4 <printf+0x70>
  if (fmt == 0)
    800005c2:	040a0263          	beqz	s4,80000606 <printf+0x82>
  va_start(ap, fmt);
    800005c6:	00840793          	addi	a5,s0,8
    800005ca:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005ce:	000a4503          	lbu	a0,0(s4)
    800005d2:	14050f63          	beqz	a0,80000730 <printf+0x1ac>
    800005d6:	4981                	li	s3,0
    if(c != '%'){
    800005d8:	02500a93          	li	s5,37
    switch(c){
    800005dc:	07000b93          	li	s7,112
  consputc('x');
    800005e0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e2:	00009b17          	auipc	s6,0x9
    800005e6:	a5eb0b13          	addi	s6,s6,-1442 # 80009040 <digits>
    switch(c){
    800005ea:	07300c93          	li	s9,115
    800005ee:	06400c13          	li	s8,100
    800005f2:	a82d                	j	8000062c <printf+0xa8>
    acquire(&pr.lock);
    800005f4:	00012517          	auipc	a0,0x12
    800005f8:	c7450513          	addi	a0,a0,-908 # 80012268 <pr>
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	5d4080e7          	jalr	1492(ra) # 80000bd0 <acquire>
    80000604:	bf7d                	j	800005c2 <printf+0x3e>
    panic("null fmt");
    80000606:	00009517          	auipc	a0,0x9
    8000060a:	a2250513          	addi	a0,a0,-1502 # 80009028 <etext+0x28>
    8000060e:	00000097          	auipc	ra,0x0
    80000612:	f2c080e7          	jalr	-212(ra) # 8000053a <panic>
      consputc(c);
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	c60080e7          	jalr	-928(ra) # 80000276 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061e:	2985                	addiw	s3,s3,1
    80000620:	013a07b3          	add	a5,s4,s3
    80000624:	0007c503          	lbu	a0,0(a5)
    80000628:	10050463          	beqz	a0,80000730 <printf+0x1ac>
    if(c != '%'){
    8000062c:	ff5515e3          	bne	a0,s5,80000616 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000630:	2985                	addiw	s3,s3,1
    80000632:	013a07b3          	add	a5,s4,s3
    80000636:	0007c783          	lbu	a5,0(a5)
    8000063a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063e:	cbed                	beqz	a5,80000730 <printf+0x1ac>
    switch(c){
    80000640:	05778a63          	beq	a5,s7,80000694 <printf+0x110>
    80000644:	02fbf663          	bgeu	s7,a5,80000670 <printf+0xec>
    80000648:	09978863          	beq	a5,s9,800006d8 <printf+0x154>
    8000064c:	07800713          	li	a4,120
    80000650:	0ce79563          	bne	a5,a4,8000071a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4605                	li	a2,1
    80000662:	85ea                	mv	a1,s10
    80000664:	4388                	lw	a0,0(a5)
    80000666:	00000097          	auipc	ra,0x0
    8000066a:	e30080e7          	jalr	-464(ra) # 80000496 <printint>
      break;
    8000066e:	bf45                	j	8000061e <printf+0x9a>
    switch(c){
    80000670:	09578f63          	beq	a5,s5,8000070e <printf+0x18a>
    80000674:	0b879363          	bne	a5,s8,8000071a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4605                	li	a2,1
    80000686:	45a9                	li	a1,10
    80000688:	4388                	lw	a0,0(a5)
    8000068a:	00000097          	auipc	ra,0x0
    8000068e:	e0c080e7          	jalr	-500(ra) # 80000496 <printint>
      break;
    80000692:	b771                	j	8000061e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a4:	03000513          	li	a0,48
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	bce080e7          	jalr	-1074(ra) # 80000276 <consputc>
  consputc('x');
    800006b0:	07800513          	li	a0,120
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	bc2080e7          	jalr	-1086(ra) # 80000276 <consputc>
    800006bc:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006be:	03c95793          	srli	a5,s2,0x3c
    800006c2:	97da                	add	a5,a5,s6
    800006c4:	0007c503          	lbu	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	bae080e7          	jalr	-1106(ra) # 80000276 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d0:	0912                	slli	s2,s2,0x4
    800006d2:	34fd                	addiw	s1,s1,-1
    800006d4:	f4ed                	bnez	s1,800006be <printf+0x13a>
    800006d6:	b7a1                	j	8000061e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d8:	f8843783          	ld	a5,-120(s0)
    800006dc:	00878713          	addi	a4,a5,8
    800006e0:	f8e43423          	sd	a4,-120(s0)
    800006e4:	6384                	ld	s1,0(a5)
    800006e6:	cc89                	beqz	s1,80000700 <printf+0x17c>
      for(; *s; s++)
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	d90d                	beqz	a0,8000061e <printf+0x9a>
        consputc(*s);
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	b88080e7          	jalr	-1144(ra) # 80000276 <consputc>
      for(; *s; s++)
    800006f6:	0485                	addi	s1,s1,1
    800006f8:	0004c503          	lbu	a0,0(s1)
    800006fc:	f96d                	bnez	a0,800006ee <printf+0x16a>
    800006fe:	b705                	j	8000061e <printf+0x9a>
        s = "(null)";
    80000700:	00009497          	auipc	s1,0x9
    80000704:	92048493          	addi	s1,s1,-1760 # 80009020 <etext+0x20>
      for(; *s; s++)
    80000708:	02800513          	li	a0,40
    8000070c:	b7cd                	j	800006ee <printf+0x16a>
      consputc('%');
    8000070e:	8556                	mv	a0,s5
    80000710:	00000097          	auipc	ra,0x0
    80000714:	b66080e7          	jalr	-1178(ra) # 80000276 <consputc>
      break;
    80000718:	b719                	j	8000061e <printf+0x9a>
      consputc('%');
    8000071a:	8556                	mv	a0,s5
    8000071c:	00000097          	auipc	ra,0x0
    80000720:	b5a080e7          	jalr	-1190(ra) # 80000276 <consputc>
      consputc(c);
    80000724:	8526                	mv	a0,s1
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b50080e7          	jalr	-1200(ra) # 80000276 <consputc>
      break;
    8000072e:	bdc5                	j	8000061e <printf+0x9a>
  if(locking)
    80000730:	020d9163          	bnez	s11,80000752 <printf+0x1ce>
}
    80000734:	70e6                	ld	ra,120(sp)
    80000736:	7446                	ld	s0,112(sp)
    80000738:	74a6                	ld	s1,104(sp)
    8000073a:	7906                	ld	s2,96(sp)
    8000073c:	69e6                	ld	s3,88(sp)
    8000073e:	6a46                	ld	s4,80(sp)
    80000740:	6aa6                	ld	s5,72(sp)
    80000742:	6b06                	ld	s6,64(sp)
    80000744:	7be2                	ld	s7,56(sp)
    80000746:	7c42                	ld	s8,48(sp)
    80000748:	7ca2                	ld	s9,40(sp)
    8000074a:	7d02                	ld	s10,32(sp)
    8000074c:	6de2                	ld	s11,24(sp)
    8000074e:	6129                	addi	sp,sp,192
    80000750:	8082                	ret
    release(&pr.lock);
    80000752:	00012517          	auipc	a0,0x12
    80000756:	b1650513          	addi	a0,a0,-1258 # 80012268 <pr>
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	52a080e7          	jalr	1322(ra) # 80000c84 <release>
}
    80000762:	bfc9                	j	80000734 <printf+0x1b0>

0000000080000764 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000764:	1101                	addi	sp,sp,-32
    80000766:	ec06                	sd	ra,24(sp)
    80000768:	e822                	sd	s0,16(sp)
    8000076a:	e426                	sd	s1,8(sp)
    8000076c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076e:	00012497          	auipc	s1,0x12
    80000772:	afa48493          	addi	s1,s1,-1286 # 80012268 <pr>
    80000776:	00009597          	auipc	a1,0x9
    8000077a:	8c258593          	addi	a1,a1,-1854 # 80009038 <etext+0x38>
    8000077e:	8526                	mv	a0,s1
    80000780:	00000097          	auipc	ra,0x0
    80000784:	3c0080e7          	jalr	960(ra) # 80000b40 <initlock>
  pr.locking = 1;
    80000788:	4785                	li	a5,1
    8000078a:	cc9c                	sw	a5,24(s1)
}
    8000078c:	60e2                	ld	ra,24(sp)
    8000078e:	6442                	ld	s0,16(sp)
    80000790:	64a2                	ld	s1,8(sp)
    80000792:	6105                	addi	sp,sp,32
    80000794:	8082                	ret

0000000080000796 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000796:	1141                	addi	sp,sp,-16
    80000798:	e406                	sd	ra,8(sp)
    8000079a:	e022                	sd	s0,0(sp)
    8000079c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079e:	100007b7          	lui	a5,0x10000
    800007a2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a6:	f8000713          	li	a4,-128
    800007aa:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ae:	470d                	li	a4,3
    800007b0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007bc:	469d                	li	a3,7
    800007be:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c6:	00009597          	auipc	a1,0x9
    800007ca:	89258593          	addi	a1,a1,-1902 # 80009058 <digits+0x18>
    800007ce:	00012517          	auipc	a0,0x12
    800007d2:	aba50513          	addi	a0,a0,-1350 # 80012288 <uart_tx_lock>
    800007d6:	00000097          	auipc	ra,0x0
    800007da:	36a080e7          	jalr	874(ra) # 80000b40 <initlock>
}
    800007de:	60a2                	ld	ra,8(sp)
    800007e0:	6402                	ld	s0,0(sp)
    800007e2:	0141                	addi	sp,sp,16
    800007e4:	8082                	ret

00000000800007e6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e6:	1101                	addi	sp,sp,-32
    800007e8:	ec06                	sd	ra,24(sp)
    800007ea:	e822                	sd	s0,16(sp)
    800007ec:	e426                	sd	s1,8(sp)
    800007ee:	1000                	addi	s0,sp,32
    800007f0:	84aa                	mv	s1,a0
  push_off();
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	392080e7          	jalr	914(ra) # 80000b84 <push_off>

  if(panicked){
    800007fa:	0000a797          	auipc	a5,0xa
    800007fe:	8067a783          	lw	a5,-2042(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000802:	10000737          	lui	a4,0x10000
  if(panicked){
    80000806:	c391                	beqz	a5,8000080a <uartputc_sync+0x24>
    for(;;)
    80000808:	a001                	j	80000808 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080e:	0207f793          	andi	a5,a5,32
    80000812:	dfe5                	beqz	a5,8000080a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000814:	0ff4f513          	zext.b	a0,s1
    80000818:	100007b7          	lui	a5,0x10000
    8000081c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000820:	00000097          	auipc	ra,0x0
    80000824:	404080e7          	jalr	1028(ra) # 80000c24 <pop_off>
}
    80000828:	60e2                	ld	ra,24(sp)
    8000082a:	6442                	ld	s0,16(sp)
    8000082c:	64a2                	ld	s1,8(sp)
    8000082e:	6105                	addi	sp,sp,32
    80000830:	8082                	ret

0000000080000832 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000832:	00009797          	auipc	a5,0x9
    80000836:	7d67b783          	ld	a5,2006(a5) # 8000a008 <uart_tx_r>
    8000083a:	00009717          	auipc	a4,0x9
    8000083e:	7d673703          	ld	a4,2006(a4) # 8000a010 <uart_tx_w>
    80000842:	06f70a63          	beq	a4,a5,800008b6 <uartstart+0x84>
{
    80000846:	7139                	addi	sp,sp,-64
    80000848:	fc06                	sd	ra,56(sp)
    8000084a:	f822                	sd	s0,48(sp)
    8000084c:	f426                	sd	s1,40(sp)
    8000084e:	f04a                	sd	s2,32(sp)
    80000850:	ec4e                	sd	s3,24(sp)
    80000852:	e852                	sd	s4,16(sp)
    80000854:	e456                	sd	s5,8(sp)
    80000856:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000858:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085c:	00012a17          	auipc	s4,0x12
    80000860:	a2ca0a13          	addi	s4,s4,-1492 # 80012288 <uart_tx_lock>
    uart_tx_r += 1;
    80000864:	00009497          	auipc	s1,0x9
    80000868:	7a448493          	addi	s1,s1,1956 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086c:	00009997          	auipc	s3,0x9
    80000870:	7a498993          	addi	s3,s3,1956 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000878:	02077713          	andi	a4,a4,32
    8000087c:	c705                	beqz	a4,800008a4 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087e:	01f7f713          	andi	a4,a5,31
    80000882:	9752                	add	a4,a4,s4
    80000884:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000888:	0785                	addi	a5,a5,1
    8000088a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088c:	8526                	mv	a0,s1
    8000088e:	00002097          	auipc	ra,0x2
    80000892:	4f4080e7          	jalr	1268(ra) # 80002d82 <wakeup>
    
    WriteReg(THR, c);
    80000896:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089a:	609c                	ld	a5,0(s1)
    8000089c:	0009b703          	ld	a4,0(s3)
    800008a0:	fcf71ae3          	bne	a4,a5,80000874 <uartstart+0x42>
  }
}
    800008a4:	70e2                	ld	ra,56(sp)
    800008a6:	7442                	ld	s0,48(sp)
    800008a8:	74a2                	ld	s1,40(sp)
    800008aa:	7902                	ld	s2,32(sp)
    800008ac:	69e2                	ld	s3,24(sp)
    800008ae:	6a42                	ld	s4,16(sp)
    800008b0:	6aa2                	ld	s5,8(sp)
    800008b2:	6121                	addi	sp,sp,64
    800008b4:	8082                	ret
    800008b6:	8082                	ret

00000000800008b8 <uartputc>:
{
    800008b8:	7179                	addi	sp,sp,-48
    800008ba:	f406                	sd	ra,40(sp)
    800008bc:	f022                	sd	s0,32(sp)
    800008be:	ec26                	sd	s1,24(sp)
    800008c0:	e84a                	sd	s2,16(sp)
    800008c2:	e44e                	sd	s3,8(sp)
    800008c4:	e052                	sd	s4,0(sp)
    800008c6:	1800                	addi	s0,sp,48
    800008c8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ca:	00012517          	auipc	a0,0x12
    800008ce:	9be50513          	addi	a0,a0,-1602 # 80012288 <uart_tx_lock>
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	2fe080e7          	jalr	766(ra) # 80000bd0 <acquire>
  if(panicked){
    800008da:	00009797          	auipc	a5,0x9
    800008de:	7267a783          	lw	a5,1830(a5) # 8000a000 <panicked>
    800008e2:	c391                	beqz	a5,800008e6 <uartputc+0x2e>
    for(;;)
    800008e4:	a001                	j	800008e4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00009717          	auipc	a4,0x9
    800008ea:	72a73703          	ld	a4,1834(a4) # 8000a010 <uart_tx_w>
    800008ee:	00009797          	auipc	a5,0x9
    800008f2:	71a7b783          	ld	a5,1818(a5) # 8000a008 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    800008fa:	02e79b63          	bne	a5,a4,80000930 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00012997          	auipc	s3,0x12
    80000902:	98a98993          	addi	s3,s3,-1654 # 80012288 <uart_tx_lock>
    80000906:	00009497          	auipc	s1,0x9
    8000090a:	70248493          	addi	s1,s1,1794 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00009917          	auipc	s2,0x9
    80000912:	70290913          	addi	s2,s2,1794 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	e96080e7          	jalr	-362(ra) # 800027b0 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00012497          	auipc	s1,0x12
    80000934:	95848493          	addi	s1,s1,-1704 # 80012288 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00009797          	auipc	a5,0x9
    80000948:	6ce7b623          	sd	a4,1740(a5) # 8000a010 <uart_tx_w>
      uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee6080e7          	jalr	-282(ra) # 80000832 <uartstart>
      release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	32e080e7          	jalr	814(ra) # 80000c84 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret

000000008000096e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096e:	1141                	addi	sp,sp,-16
    80000970:	e422                	sd	s0,8(sp)
    80000972:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000974:	100007b7          	lui	a5,0x10000
    80000978:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097c:	8b85                	andi	a5,a5,1
    8000097e:	cb81                	beqz	a5,8000098e <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000980:	100007b7          	lui	a5,0x10000
    80000984:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000988:	6422                	ld	s0,8(sp)
    8000098a:	0141                	addi	sp,sp,16
    8000098c:	8082                	ret
    return -1;
    8000098e:	557d                	li	a0,-1
    80000990:	bfe5                	j	80000988 <uartgetc+0x1a>

0000000080000992 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000992:	1101                	addi	sp,sp,-32
    80000994:	ec06                	sd	ra,24(sp)
    80000996:	e822                	sd	s0,16(sp)
    80000998:	e426                	sd	s1,8(sp)
    8000099a:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099c:	54fd                	li	s1,-1
    8000099e:	a029                	j	800009a8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a0:	00000097          	auipc	ra,0x0
    800009a4:	918080e7          	jalr	-1768(ra) # 800002b8 <consoleintr>
    int c = uartgetc();
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	fc6080e7          	jalr	-58(ra) # 8000096e <uartgetc>
    if(c == -1)
    800009b0:	fe9518e3          	bne	a0,s1,800009a0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b4:	00012497          	auipc	s1,0x12
    800009b8:	8d448493          	addi	s1,s1,-1836 # 80012288 <uart_tx_lock>
    800009bc:	8526                	mv	a0,s1
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	212080e7          	jalr	530(ra) # 80000bd0 <acquire>
  uartstart();
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	e6c080e7          	jalr	-404(ra) # 80000832 <uartstart>
  release(&uart_tx_lock);
    800009ce:	8526                	mv	a0,s1
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	2b4080e7          	jalr	692(ra) # 80000c84 <release>
}
    800009d8:	60e2                	ld	ra,24(sp)
    800009da:	6442                	ld	s0,16(sp)
    800009dc:	64a2                	ld	s1,8(sp)
    800009de:	6105                	addi	sp,sp,32
    800009e0:	8082                	ret

00000000800009e2 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e2:	1101                	addi	sp,sp,-32
    800009e4:	ec06                	sd	ra,24(sp)
    800009e6:	e822                	sd	s0,16(sp)
    800009e8:	e426                	sd	s1,8(sp)
    800009ea:	e04a                	sd	s2,0(sp)
    800009ec:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009ee:	03451793          	slli	a5,a0,0x34
    800009f2:	ebb9                	bnez	a5,80000a48 <kfree+0x66>
    800009f4:	84aa                	mv	s1,a0
    800009f6:	00028797          	auipc	a5,0x28
    800009fa:	60a78793          	addi	a5,a5,1546 # 80029000 <end>
    800009fe:	04f56563          	bltu	a0,a5,80000a48 <kfree+0x66>
    80000a02:	47c5                	li	a5,17
    80000a04:	07ee                	slli	a5,a5,0x1b
    80000a06:	04f57163          	bgeu	a0,a5,80000a48 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0a:	6605                	lui	a2,0x1
    80000a0c:	4585                	li	a1,1
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	2be080e7          	jalr	702(ra) # 80000ccc <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a16:	00012917          	auipc	s2,0x12
    80000a1a:	8aa90913          	addi	s2,s2,-1878 # 800122c0 <kmem>
    80000a1e:	854a                	mv	a0,s2
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	1b0080e7          	jalr	432(ra) # 80000bd0 <acquire>
  r->next = kmem.freelist;
    80000a28:	01893783          	ld	a5,24(s2)
    80000a2c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a32:	854a                	mv	a0,s2
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	250080e7          	jalr	592(ra) # 80000c84 <release>
}
    80000a3c:	60e2                	ld	ra,24(sp)
    80000a3e:	6442                	ld	s0,16(sp)
    80000a40:	64a2                	ld	s1,8(sp)
    80000a42:	6902                	ld	s2,0(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret
    panic("kfree");
    80000a48:	00008517          	auipc	a0,0x8
    80000a4c:	61850513          	addi	a0,a0,1560 # 80009060 <digits+0x20>
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	aea080e7          	jalr	-1302(ra) # 8000053a <panic>

0000000080000a58 <freerange>:
{
    80000a58:	7179                	addi	sp,sp,-48
    80000a5a:	f406                	sd	ra,40(sp)
    80000a5c:	f022                	sd	s0,32(sp)
    80000a5e:	ec26                	sd	s1,24(sp)
    80000a60:	e84a                	sd	s2,16(sp)
    80000a62:	e44e                	sd	s3,8(sp)
    80000a64:	e052                	sd	s4,0(sp)
    80000a66:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a68:	6785                	lui	a5,0x1
    80000a6a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a6e:	00e504b3          	add	s1,a0,a4
    80000a72:	777d                	lui	a4,0xfffff
    80000a74:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	94be                	add	s1,s1,a5
    80000a78:	0095ee63          	bltu	a1,s1,80000a94 <freerange+0x3c>
    80000a7c:	892e                	mv	s2,a1
    kfree(p);
    80000a7e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	6985                	lui	s3,0x1
    kfree(p);
    80000a82:	01448533          	add	a0,s1,s4
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	f5c080e7          	jalr	-164(ra) # 800009e2 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe9979e3          	bgeu	s2,s1,80000a82 <freerange+0x2a>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00008597          	auipc	a1,0x8
    80000ab0:	5bc58593          	addi	a1,a1,1468 # 80009068 <digits+0x28>
    80000ab4:	00012517          	auipc	a0,0x12
    80000ab8:	80c50513          	addi	a0,a0,-2036 # 800122c0 <kmem>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	084080e7          	jalr	132(ra) # 80000b40 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	00028517          	auipc	a0,0x28
    80000acc:	53850513          	addi	a0,a0,1336 # 80029000 <end>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	f88080e7          	jalr	-120(ra) # 80000a58 <freerange>
}
    80000ad8:	60a2                	ld	ra,8(sp)
    80000ada:	6402                	ld	s0,0(sp)
    80000adc:	0141                	addi	sp,sp,16
    80000ade:	8082                	ret

0000000080000ae0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae0:	1101                	addi	sp,sp,-32
    80000ae2:	ec06                	sd	ra,24(sp)
    80000ae4:	e822                	sd	s0,16(sp)
    80000ae6:	e426                	sd	s1,8(sp)
    80000ae8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aea:	00011497          	auipc	s1,0x11
    80000aee:	7d648493          	addi	s1,s1,2006 # 800122c0 <kmem>
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	0dc080e7          	jalr	220(ra) # 80000bd0 <acquire>
  r = kmem.freelist;
    80000afc:	6c84                	ld	s1,24(s1)
  if(r)
    80000afe:	c885                	beqz	s1,80000b2e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b00:	609c                	ld	a5,0(s1)
    80000b02:	00011517          	auipc	a0,0x11
    80000b06:	7be50513          	addi	a0,a0,1982 # 800122c0 <kmem>
    80000b0a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	178080e7          	jalr	376(ra) # 80000c84 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1b2080e7          	jalr	434(ra) # 80000ccc <memset>
  return (void*)r;
}
    80000b22:	8526                	mv	a0,s1
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
  release(&kmem.lock);
    80000b2e:	00011517          	auipc	a0,0x11
    80000b32:	79250513          	addi	a0,a0,1938 # 800122c0 <kmem>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	14e080e7          	jalr	334(ra) # 80000c84 <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b40:	1141                	addi	sp,sp,-16
    80000b42:	e422                	sd	s0,8(sp)
    80000b44:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b46:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b48:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4c:	00053823          	sd	zero,16(a0)
}
    80000b50:	6422                	ld	s0,8(sp)
    80000b52:	0141                	addi	sp,sp,16
    80000b54:	8082                	ret

0000000080000b56 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b56:	411c                	lw	a5,0(a0)
    80000b58:	e399                	bnez	a5,80000b5e <holding+0x8>
    80000b5a:	4501                	li	a0,0
  return r;
}
    80000b5c:	8082                	ret
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	6904                	ld	s1,16(a0)
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	e78080e7          	jalr	-392(ra) # 800019e2 <mycpu>
    80000b72:	40a48533          	sub	a0,s1,a0
    80000b76:	00153513          	seqz	a0,a0
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret

0000000080000b84 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8e:	100024f3          	csrr	s1,sstatus
    80000b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b96:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b98:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9c:	00001097          	auipc	ra,0x1
    80000ba0:	e46080e7          	jalr	-442(ra) # 800019e2 <mycpu>
    80000ba4:	5d3c                	lw	a5,120(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba8:	00001097          	auipc	ra,0x1
    80000bac:	e3a080e7          	jalr	-454(ra) # 800019e2 <mycpu>
    80000bb0:	5d3c                	lw	a5,120(a0)
    80000bb2:	2785                	addiw	a5,a5,1
    80000bb4:	dd3c                	sw	a5,120(a0)
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    mycpu()->intena = old;
    80000bc0:	00001097          	auipc	ra,0x1
    80000bc4:	e22080e7          	jalr	-478(ra) # 800019e2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc8:	8085                	srli	s1,s1,0x1
    80000bca:	8885                	andi	s1,s1,1
    80000bcc:	dd64                	sw	s1,124(a0)
    80000bce:	bfe9                	j	80000ba8 <push_off+0x24>

0000000080000bd0 <acquire>:
{
    80000bd0:	1101                	addi	sp,sp,-32
    80000bd2:	ec06                	sd	ra,24(sp)
    80000bd4:	e822                	sd	s0,16(sp)
    80000bd6:	e426                	sd	s1,8(sp)
    80000bd8:	1000                	addi	s0,sp,32
    80000bda:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	fa8080e7          	jalr	-88(ra) # 80000b84 <push_off>
  if(holding(lk))
    80000be4:	8526                	mv	a0,s1
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	f70080e7          	jalr	-144(ra) # 80000b56 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bee:	4705                	li	a4,1
  if(holding(lk))
    80000bf0:	e115                	bnez	a0,80000c14 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf2:	87ba                	mv	a5,a4
    80000bf4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf8:	2781                	sext.w	a5,a5
    80000bfa:	ffe5                	bnez	a5,80000bf2 <acquire+0x22>
  __sync_synchronize();
    80000bfc:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	de2080e7          	jalr	-542(ra) # 800019e2 <mycpu>
    80000c08:	e888                	sd	a0,16(s1)
}
    80000c0a:	60e2                	ld	ra,24(sp)
    80000c0c:	6442                	ld	s0,16(sp)
    80000c0e:	64a2                	ld	s1,8(sp)
    80000c10:	6105                	addi	sp,sp,32
    80000c12:	8082                	ret
    panic("acquire");
    80000c14:	00008517          	auipc	a0,0x8
    80000c18:	45c50513          	addi	a0,a0,1116 # 80009070 <digits+0x30>
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	91e080e7          	jalr	-1762(ra) # 8000053a <panic>

0000000080000c24 <pop_off>:

void
pop_off(void)
{
    80000c24:	1141                	addi	sp,sp,-16
    80000c26:	e406                	sd	ra,8(sp)
    80000c28:	e022                	sd	s0,0(sp)
    80000c2a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2c:	00001097          	auipc	ra,0x1
    80000c30:	db6080e7          	jalr	-586(ra) # 800019e2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c38:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3a:	e78d                	bnez	a5,80000c64 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	02f05b63          	blez	a5,80000c74 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c42:	37fd                	addiw	a5,a5,-1
    80000c44:	0007871b          	sext.w	a4,a5
    80000c48:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4a:	eb09                	bnez	a4,80000c5c <pop_off+0x38>
    80000c4c:	5d7c                	lw	a5,124(a0)
    80000c4e:	c799                	beqz	a5,80000c5c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c58:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5c:	60a2                	ld	ra,8(sp)
    80000c5e:	6402                	ld	s0,0(sp)
    80000c60:	0141                	addi	sp,sp,16
    80000c62:	8082                	ret
    panic("pop_off - interruptible");
    80000c64:	00008517          	auipc	a0,0x8
    80000c68:	41450513          	addi	a0,a0,1044 # 80009078 <digits+0x38>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	8ce080e7          	jalr	-1842(ra) # 8000053a <panic>
    panic("pop_off");
    80000c74:	00008517          	auipc	a0,0x8
    80000c78:	41c50513          	addi	a0,a0,1052 # 80009090 <digits+0x50>
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	8be080e7          	jalr	-1858(ra) # 8000053a <panic>

0000000080000c84 <release>:
{
    80000c84:	1101                	addi	sp,sp,-32
    80000c86:	ec06                	sd	ra,24(sp)
    80000c88:	e822                	sd	s0,16(sp)
    80000c8a:	e426                	sd	s1,8(sp)
    80000c8c:	1000                	addi	s0,sp,32
    80000c8e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	ec6080e7          	jalr	-314(ra) # 80000b56 <holding>
    80000c98:	c115                	beqz	a0,80000cbc <release+0x38>
  lk->cpu = 0;
    80000c9a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c9e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca2:	0f50000f          	fence	iorw,ow
    80000ca6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	f7a080e7          	jalr	-134(ra) # 80000c24 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00008517          	auipc	a0,0x8
    80000cc0:	3dc50513          	addi	a0,a0,988 # 80009098 <digits+0x58>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	876080e7          	jalr	-1930(ra) # 8000053a <panic>

0000000080000ccc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ccc:	1141                	addi	sp,sp,-16
    80000cce:	e422                	sd	s0,8(sp)
    80000cd0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd2:	ca19                	beqz	a2,80000ce8 <memset+0x1c>
    80000cd4:	87aa                	mv	a5,a0
    80000cd6:	1602                	slli	a2,a2,0x20
    80000cd8:	9201                	srli	a2,a2,0x20
    80000cda:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cde:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce2:	0785                	addi	a5,a5,1
    80000ce4:	fee79de3          	bne	a5,a4,80000cde <memset+0x12>
  }
  return dst;
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret

0000000080000cee <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cee:	1141                	addi	sp,sp,-16
    80000cf0:	e422                	sd	s0,8(sp)
    80000cf2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf4:	ca05                	beqz	a2,80000d24 <memcmp+0x36>
    80000cf6:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfa:	1682                	slli	a3,a3,0x20
    80000cfc:	9281                	srli	a3,a3,0x20
    80000cfe:	0685                	addi	a3,a3,1
    80000d00:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d02:	00054783          	lbu	a5,0(a0)
    80000d06:	0005c703          	lbu	a4,0(a1)
    80000d0a:	00e79863          	bne	a5,a4,80000d1a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0e:	0505                	addi	a0,a0,1
    80000d10:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d12:	fed518e3          	bne	a0,a3,80000d02 <memcmp+0x14>
  }

  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	a019                	j	80000d1e <memcmp+0x30>
      return *s1 - *s2;
    80000d1a:	40e7853b          	subw	a0,a5,a4
}
    80000d1e:	6422                	ld	s0,8(sp)
    80000d20:	0141                	addi	sp,sp,16
    80000d22:	8082                	ret
  return 0;
    80000d24:	4501                	li	a0,0
    80000d26:	bfe5                	j	80000d1e <memcmp+0x30>

0000000080000d28 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d28:	1141                	addi	sp,sp,-16
    80000d2a:	e422                	sd	s0,8(sp)
    80000d2c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2e:	c205                	beqz	a2,80000d4e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d30:	02a5e263          	bltu	a1,a0,80000d54 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d34:	1602                	slli	a2,a2,0x20
    80000d36:	9201                	srli	a2,a2,0x20
    80000d38:	00c587b3          	add	a5,a1,a2
{
    80000d3c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3e:	0585                	addi	a1,a1,1
    80000d40:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd6001>
    80000d42:	fff5c683          	lbu	a3,-1(a1)
    80000d46:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4a:	fef59ae3          	bne	a1,a5,80000d3e <memmove+0x16>

  return dst;
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  if(s < d && s + n > d){
    80000d54:	02061693          	slli	a3,a2,0x20
    80000d58:	9281                	srli	a3,a3,0x20
    80000d5a:	00d58733          	add	a4,a1,a3
    80000d5e:	fce57be3          	bgeu	a0,a4,80000d34 <memmove+0xc>
    d += n;
    80000d62:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d64:	fff6079b          	addiw	a5,a2,-1
    80000d68:	1782                	slli	a5,a5,0x20
    80000d6a:	9381                	srli	a5,a5,0x20
    80000d6c:	fff7c793          	not	a5,a5
    80000d70:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d72:	177d                	addi	a4,a4,-1
    80000d74:	16fd                	addi	a3,a3,-1
    80000d76:	00074603          	lbu	a2,0(a4)
    80000d7a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7e:	fee79ae3          	bne	a5,a4,80000d72 <memmove+0x4a>
    80000d82:	b7f1                	j	80000d4e <memmove+0x26>

0000000080000d84 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e406                	sd	ra,8(sp)
    80000d88:	e022                	sd	s0,0(sp)
    80000d8a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8c:	00000097          	auipc	ra,0x0
    80000d90:	f9c080e7          	jalr	-100(ra) # 80000d28 <memmove>
}
    80000d94:	60a2                	ld	ra,8(sp)
    80000d96:	6402                	ld	s0,0(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret

0000000080000d9c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9c:	1141                	addi	sp,sp,-16
    80000d9e:	e422                	sd	s0,8(sp)
    80000da0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da2:	ce11                	beqz	a2,80000dbe <strncmp+0x22>
    80000da4:	00054783          	lbu	a5,0(a0)
    80000da8:	cf89                	beqz	a5,80000dc2 <strncmp+0x26>
    80000daa:	0005c703          	lbu	a4,0(a1)
    80000dae:	00f71a63          	bne	a4,a5,80000dc2 <strncmp+0x26>
    n--, p++, q++;
    80000db2:	367d                	addiw	a2,a2,-1
    80000db4:	0505                	addi	a0,a0,1
    80000db6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db8:	f675                	bnez	a2,80000da4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dba:	4501                	li	a0,0
    80000dbc:	a809                	j	80000dce <strncmp+0x32>
    80000dbe:	4501                	li	a0,0
    80000dc0:	a039                	j	80000dce <strncmp+0x32>
  if(n == 0)
    80000dc2:	ca09                	beqz	a2,80000dd4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc4:	00054503          	lbu	a0,0(a0)
    80000dc8:	0005c783          	lbu	a5,0(a1)
    80000dcc:	9d1d                	subw	a0,a0,a5
}
    80000dce:	6422                	ld	s0,8(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret
    return 0;
    80000dd4:	4501                	li	a0,0
    80000dd6:	bfe5                	j	80000dce <strncmp+0x32>

0000000080000dd8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd8:	1141                	addi	sp,sp,-16
    80000dda:	e422                	sd	s0,8(sp)
    80000ddc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dde:	872a                	mv	a4,a0
    80000de0:	8832                	mv	a6,a2
    80000de2:	367d                	addiw	a2,a2,-1
    80000de4:	01005963          	blez	a6,80000df6 <strncpy+0x1e>
    80000de8:	0705                	addi	a4,a4,1
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	fef70fa3          	sb	a5,-1(a4)
    80000df2:	0585                	addi	a1,a1,1
    80000df4:	f7f5                	bnez	a5,80000de0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df6:	86ba                	mv	a3,a4
    80000df8:	00c05c63          	blez	a2,80000e10 <strncpy+0x38>
    *s++ = 0;
    80000dfc:	0685                	addi	a3,a3,1
    80000dfe:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e02:	40d707bb          	subw	a5,a4,a3
    80000e06:	37fd                	addiw	a5,a5,-1
    80000e08:	010787bb          	addw	a5,a5,a6
    80000e0c:	fef048e3          	bgtz	a5,80000dfc <strncpy+0x24>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	4685                	li	a3,1
    80000e5a:	9e89                	subw	a3,a3,a0
    80000e5c:	00f6853b          	addw	a0,a3,a5
    80000e60:	0785                	addi	a5,a5,1
    80000e62:	fff7c703          	lbu	a4,-1(a5)
    80000e66:	fb7d                	bnez	a4,80000e5c <strlen+0x14>
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
extern int sem_buffer[20];

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	7179                	addi	sp,sp,-48
    80000e74:	f406                	sd	ra,40(sp)
    80000e76:	f022                	sd	s0,32(sp)
    80000e78:	ec26                	sd	s1,24(sp)
    80000e7a:	e84a                	sd	s2,16(sp)
    80000e7c:	e44e                	sd	s3,8(sp)
    80000e7e:	e052                	sd	s4,0(sp)
    80000e80:	1800                	addi	s0,sp,48
  if(cpuid() == 0){
    80000e82:	00001097          	auipc	ra,0x1
    80000e86:	b50080e7          	jalr	-1200(ra) # 800019d2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e8a:	00009717          	auipc	a4,0x9
    80000e8e:	18e70713          	addi	a4,a4,398 # 8000a018 <started>
  if(cpuid() == 0){
    80000e92:	c559                	beqz	a0,80000f20 <main+0xae>
    while(started == 0)
    80000e94:	431c                	lw	a5,0(a4)
    80000e96:	2781                	sext.w	a5,a5
    80000e98:	dff5                	beqz	a5,80000e94 <main+0x22>
      ;
    __sync_synchronize();
    80000e9a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9e:	00001097          	auipc	ra,0x1
    80000ea2:	b34080e7          	jalr	-1228(ra) # 800019d2 <cpuid>
    80000ea6:	85aa                	mv	a1,a0
    80000ea8:	00008517          	auipc	a0,0x8
    80000eac:	21050513          	addi	a0,a0,528 # 800090b8 <digits+0x78>
    80000eb0:	fffff097          	auipc	ra,0xfffff
    80000eb4:	6d4080e7          	jalr	1748(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000eb8:	00000097          	auipc	ra,0x0
    80000ebc:	120080e7          	jalr	288(ra) # 80000fd8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ec0:	00003097          	auipc	ra,0x3
    80000ec4:	a98080e7          	jalr	-1384(ra) # 80003958 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec8:	00007097          	auipc	ra,0x7
    80000ecc:	8d8080e7          	jalr	-1832(ra) # 800077a0 <plicinithart>
  }

  sched_policy = SCHED_PREEMPT_RR;
    80000ed0:	4789                	li	a5,2
    80000ed2:	00009717          	auipc	a4,0x9
    80000ed6:	18f72b23          	sw	a5,406(a4) # 8000a068 <sched_policy>

  for (int i = 0; i < 10; i++)
    80000eda:	00018497          	auipc	s1,0x18
    80000ede:	c6e48493          	addi	s1,s1,-914 # 80018b48 <barriers+0x8>
    80000ee2:	00018a17          	auipc	s4,0x18
    80000ee6:	076a0a13          	addi	s4,s4,118 # 80018f58 <lock_delete+0x8>
  {
    barriers[i].counter = -1;
    80000eea:	59fd                	li	s3,-1
    initsleeplock(&barriers[i].lock, "barrier_lock");
    80000eec:	00008917          	auipc	s2,0x8
    80000ef0:	1e490913          	addi	s2,s2,484 # 800090d0 <digits+0x90>
    barriers[i].counter = -1;
    80000ef4:	ff34ac23          	sw	s3,-8(s1)
    initsleeplock(&barriers[i].lock, "barrier_lock");
    80000ef8:	85ca                	mv	a1,s2
    80000efa:	8526                	mv	a0,s1
    80000efc:	00005097          	auipc	ra,0x5
    80000f00:	f94080e7          	jalr	-108(ra) # 80005e90 <initsleeplock>
    cond_init(&barriers[i].cv);
    80000f04:	03048513          	addi	a0,s1,48
    80000f08:	00007097          	auipc	ra,0x7
    80000f0c:	e92080e7          	jalr	-366(ra) # 80007d9a <cond_init>
  for (int i = 0; i < 10; i++)
    80000f10:	06848493          	addi	s1,s1,104
    80000f14:	ff4490e3          	bne	s1,s4,80000ef4 <main+0x82>
  }
  

  scheduler();        
    80000f18:	00001097          	auipc	ra,0x1
    80000f1c:	336080e7          	jalr	822(ra) # 8000224e <scheduler>
    consoleinit();
    80000f20:	fffff097          	auipc	ra,0xfffff
    80000f24:	52a080e7          	jalr	1322(ra) # 8000044a <consoleinit>
    printfinit();
    80000f28:	00000097          	auipc	ra,0x0
    80000f2c:	83c080e7          	jalr	-1988(ra) # 80000764 <printfinit>
    printf("\n");
    80000f30:	00009517          	auipc	a0,0x9
    80000f34:	88050513          	addi	a0,a0,-1920 # 800097b0 <syscalls+0x150>
    80000f38:	fffff097          	auipc	ra,0xfffff
    80000f3c:	64c080e7          	jalr	1612(ra) # 80000584 <printf>
    printf("xv6 kernel is booting\n");
    80000f40:	00008517          	auipc	a0,0x8
    80000f44:	16050513          	addi	a0,a0,352 # 800090a0 <digits+0x60>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	63c080e7          	jalr	1596(ra) # 80000584 <printf>
    printf("\n");
    80000f50:	00009517          	auipc	a0,0x9
    80000f54:	86050513          	addi	a0,a0,-1952 # 800097b0 <syscalls+0x150>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	62c080e7          	jalr	1580(ra) # 80000584 <printf>
    kinit();         // physical page allocator
    80000f60:	00000097          	auipc	ra,0x0
    80000f64:	b44080e7          	jalr	-1212(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f68:	00000097          	auipc	ra,0x0
    80000f6c:	322080e7          	jalr	802(ra) # 8000128a <kvminit>
    kvminithart();   // turn on paging
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	068080e7          	jalr	104(ra) # 80000fd8 <kvminithart>
    procinit();      // process table
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	992080e7          	jalr	-1646(ra) # 8000190a <procinit>
    trapinit();      // trap vectors
    80000f80:	00003097          	auipc	ra,0x3
    80000f84:	9b0080e7          	jalr	-1616(ra) # 80003930 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f88:	00003097          	auipc	ra,0x3
    80000f8c:	9d0080e7          	jalr	-1584(ra) # 80003958 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f90:	00006097          	auipc	ra,0x6
    80000f94:	7fa080e7          	jalr	2042(ra) # 8000778a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f98:	00007097          	auipc	ra,0x7
    80000f9c:	808080e7          	jalr	-2040(ra) # 800077a0 <plicinithart>
    binit();         // buffer cache
    80000fa0:	00004097          	auipc	ra,0x4
    80000fa4:	9ca080e7          	jalr	-1590(ra) # 8000496a <binit>
    iinit();         // inode table
    80000fa8:	00004097          	auipc	ra,0x4
    80000fac:	058080e7          	jalr	88(ra) # 80005000 <iinit>
    fileinit();      // file table
    80000fb0:	00005097          	auipc	ra,0x5
    80000fb4:	00a080e7          	jalr	10(ra) # 80005fba <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb8:	00007097          	auipc	ra,0x7
    80000fbc:	908080e7          	jalr	-1784(ra) # 800078c0 <virtio_disk_init>
    userinit();      // first user process
    80000fc0:	00001097          	auipc	ra,0x1
    80000fc4:	d8c080e7          	jalr	-628(ra) # 80001d4c <userinit>
    __sync_synchronize();
    80000fc8:	0ff0000f          	fence
    started = 1;
    80000fcc:	4785                	li	a5,1
    80000fce:	00009717          	auipc	a4,0x9
    80000fd2:	04f72523          	sw	a5,74(a4) # 8000a018 <started>
    80000fd6:	bded                	j	80000ed0 <main+0x5e>

0000000080000fd8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fd8:	1141                	addi	sp,sp,-16
    80000fda:	e422                	sd	s0,8(sp)
    80000fdc:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fde:	00009797          	auipc	a5,0x9
    80000fe2:	0427b783          	ld	a5,66(a5) # 8000a020 <kernel_pagetable>
    80000fe6:	83b1                	srli	a5,a5,0xc
    80000fe8:	577d                	li	a4,-1
    80000fea:	177e                	slli	a4,a4,0x3f
    80000fec:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fee:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ff2:	12000073          	sfence.vma
  sfence_vma();
}
    80000ff6:	6422                	ld	s0,8(sp)
    80000ff8:	0141                	addi	sp,sp,16
    80000ffa:	8082                	ret

0000000080000ffc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ffc:	7139                	addi	sp,sp,-64
    80000ffe:	fc06                	sd	ra,56(sp)
    80001000:	f822                	sd	s0,48(sp)
    80001002:	f426                	sd	s1,40(sp)
    80001004:	f04a                	sd	s2,32(sp)
    80001006:	ec4e                	sd	s3,24(sp)
    80001008:	e852                	sd	s4,16(sp)
    8000100a:	e456                	sd	s5,8(sp)
    8000100c:	e05a                	sd	s6,0(sp)
    8000100e:	0080                	addi	s0,sp,64
    80001010:	84aa                	mv	s1,a0
    80001012:	89ae                	mv	s3,a1
    80001014:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001016:	57fd                	li	a5,-1
    80001018:	83e9                	srli	a5,a5,0x1a
    8000101a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000101c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000101e:	04b7f263          	bgeu	a5,a1,80001062 <walk+0x66>
    panic("walk");
    80001022:	00008517          	auipc	a0,0x8
    80001026:	0be50513          	addi	a0,a0,190 # 800090e0 <digits+0xa0>
    8000102a:	fffff097          	auipc	ra,0xfffff
    8000102e:	510080e7          	jalr	1296(ra) # 8000053a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001032:	060a8663          	beqz	s5,8000109e <walk+0xa2>
    80001036:	00000097          	auipc	ra,0x0
    8000103a:	aaa080e7          	jalr	-1366(ra) # 80000ae0 <kalloc>
    8000103e:	84aa                	mv	s1,a0
    80001040:	c529                	beqz	a0,8000108a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001042:	6605                	lui	a2,0x1
    80001044:	4581                	li	a1,0
    80001046:	00000097          	auipc	ra,0x0
    8000104a:	c86080e7          	jalr	-890(ra) # 80000ccc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000104e:	00c4d793          	srli	a5,s1,0xc
    80001052:	07aa                	slli	a5,a5,0xa
    80001054:	0017e793          	ori	a5,a5,1
    80001058:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000105c:	3a5d                	addiw	s4,s4,-9
    8000105e:	036a0063          	beq	s4,s6,8000107e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001062:	0149d933          	srl	s2,s3,s4
    80001066:	1ff97913          	andi	s2,s2,511
    8000106a:	090e                	slli	s2,s2,0x3
    8000106c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000106e:	00093483          	ld	s1,0(s2)
    80001072:	0014f793          	andi	a5,s1,1
    80001076:	dfd5                	beqz	a5,80001032 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001078:	80a9                	srli	s1,s1,0xa
    8000107a:	04b2                	slli	s1,s1,0xc
    8000107c:	b7c5                	j	8000105c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000107e:	00c9d513          	srli	a0,s3,0xc
    80001082:	1ff57513          	andi	a0,a0,511
    80001086:	050e                	slli	a0,a0,0x3
    80001088:	9526                	add	a0,a0,s1
}
    8000108a:	70e2                	ld	ra,56(sp)
    8000108c:	7442                	ld	s0,48(sp)
    8000108e:	74a2                	ld	s1,40(sp)
    80001090:	7902                	ld	s2,32(sp)
    80001092:	69e2                	ld	s3,24(sp)
    80001094:	6a42                	ld	s4,16(sp)
    80001096:	6aa2                	ld	s5,8(sp)
    80001098:	6b02                	ld	s6,0(sp)
    8000109a:	6121                	addi	sp,sp,64
    8000109c:	8082                	ret
        return 0;
    8000109e:	4501                	li	a0,0
    800010a0:	b7ed                	j	8000108a <walk+0x8e>

00000000800010a2 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010a2:	57fd                	li	a5,-1
    800010a4:	83e9                	srli	a5,a5,0x1a
    800010a6:	00b7f463          	bgeu	a5,a1,800010ae <walkaddr+0xc>
    return 0;
    800010aa:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010ac:	8082                	ret
{
    800010ae:	1141                	addi	sp,sp,-16
    800010b0:	e406                	sd	ra,8(sp)
    800010b2:	e022                	sd	s0,0(sp)
    800010b4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010b6:	4601                	li	a2,0
    800010b8:	00000097          	auipc	ra,0x0
    800010bc:	f44080e7          	jalr	-188(ra) # 80000ffc <walk>
  if(pte == 0)
    800010c0:	c105                	beqz	a0,800010e0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010c2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010c4:	0117f693          	andi	a3,a5,17
    800010c8:	4745                	li	a4,17
    return 0;
    800010ca:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010cc:	00e68663          	beq	a3,a4,800010d8 <walkaddr+0x36>
}
    800010d0:	60a2                	ld	ra,8(sp)
    800010d2:	6402                	ld	s0,0(sp)
    800010d4:	0141                	addi	sp,sp,16
    800010d6:	8082                	ret
  pa = PTE2PA(*pte);
    800010d8:	83a9                	srli	a5,a5,0xa
    800010da:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010de:	bfcd                	j	800010d0 <walkaddr+0x2e>
    return 0;
    800010e0:	4501                	li	a0,0
    800010e2:	b7fd                	j	800010d0 <walkaddr+0x2e>

00000000800010e4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010e4:	715d                	addi	sp,sp,-80
    800010e6:	e486                	sd	ra,72(sp)
    800010e8:	e0a2                	sd	s0,64(sp)
    800010ea:	fc26                	sd	s1,56(sp)
    800010ec:	f84a                	sd	s2,48(sp)
    800010ee:	f44e                	sd	s3,40(sp)
    800010f0:	f052                	sd	s4,32(sp)
    800010f2:	ec56                	sd	s5,24(sp)
    800010f4:	e85a                	sd	s6,16(sp)
    800010f6:	e45e                	sd	s7,8(sp)
    800010f8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010fa:	c639                	beqz	a2,80001148 <mappages+0x64>
    800010fc:	8aaa                	mv	s5,a0
    800010fe:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001100:	777d                	lui	a4,0xfffff
    80001102:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001106:	fff58993          	addi	s3,a1,-1
    8000110a:	99b2                	add	s3,s3,a2
    8000110c:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001110:	893e                	mv	s2,a5
    80001112:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001116:	6b85                	lui	s7,0x1
    80001118:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000111c:	4605                	li	a2,1
    8000111e:	85ca                	mv	a1,s2
    80001120:	8556                	mv	a0,s5
    80001122:	00000097          	auipc	ra,0x0
    80001126:	eda080e7          	jalr	-294(ra) # 80000ffc <walk>
    8000112a:	cd1d                	beqz	a0,80001168 <mappages+0x84>
    if(*pte & PTE_V)
    8000112c:	611c                	ld	a5,0(a0)
    8000112e:	8b85                	andi	a5,a5,1
    80001130:	e785                	bnez	a5,80001158 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001132:	80b1                	srli	s1,s1,0xc
    80001134:	04aa                	slli	s1,s1,0xa
    80001136:	0164e4b3          	or	s1,s1,s6
    8000113a:	0014e493          	ori	s1,s1,1
    8000113e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001140:	05390063          	beq	s2,s3,80001180 <mappages+0x9c>
    a += PGSIZE;
    80001144:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001146:	bfc9                	j	80001118 <mappages+0x34>
    panic("mappages: size");
    80001148:	00008517          	auipc	a0,0x8
    8000114c:	fa050513          	addi	a0,a0,-96 # 800090e8 <digits+0xa8>
    80001150:	fffff097          	auipc	ra,0xfffff
    80001154:	3ea080e7          	jalr	1002(ra) # 8000053a <panic>
      panic("mappages: remap");
    80001158:	00008517          	auipc	a0,0x8
    8000115c:	fa050513          	addi	a0,a0,-96 # 800090f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3da080e7          	jalr	986(ra) # 8000053a <panic>
      return -1;
    80001168:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000116a:	60a6                	ld	ra,72(sp)
    8000116c:	6406                	ld	s0,64(sp)
    8000116e:	74e2                	ld	s1,56(sp)
    80001170:	7942                	ld	s2,48(sp)
    80001172:	79a2                	ld	s3,40(sp)
    80001174:	7a02                	ld	s4,32(sp)
    80001176:	6ae2                	ld	s5,24(sp)
    80001178:	6b42                	ld	s6,16(sp)
    8000117a:	6ba2                	ld	s7,8(sp)
    8000117c:	6161                	addi	sp,sp,80
    8000117e:	8082                	ret
  return 0;
    80001180:	4501                	li	a0,0
    80001182:	b7e5                	j	8000116a <mappages+0x86>

0000000080001184 <kvmmap>:
{
    80001184:	1141                	addi	sp,sp,-16
    80001186:	e406                	sd	ra,8(sp)
    80001188:	e022                	sd	s0,0(sp)
    8000118a:	0800                	addi	s0,sp,16
    8000118c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000118e:	86b2                	mv	a3,a2
    80001190:	863e                	mv	a2,a5
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f52080e7          	jalr	-174(ra) # 800010e4 <mappages>
    8000119a:	e509                	bnez	a0,800011a4 <kvmmap+0x20>
}
    8000119c:	60a2                	ld	ra,8(sp)
    8000119e:	6402                	ld	s0,0(sp)
    800011a0:	0141                	addi	sp,sp,16
    800011a2:	8082                	ret
    panic("kvmmap");
    800011a4:	00008517          	auipc	a0,0x8
    800011a8:	f6450513          	addi	a0,a0,-156 # 80009108 <digits+0xc8>
    800011ac:	fffff097          	auipc	ra,0xfffff
    800011b0:	38e080e7          	jalr	910(ra) # 8000053a <panic>

00000000800011b4 <kvmmake>:
{
    800011b4:	1101                	addi	sp,sp,-32
    800011b6:	ec06                	sd	ra,24(sp)
    800011b8:	e822                	sd	s0,16(sp)
    800011ba:	e426                	sd	s1,8(sp)
    800011bc:	e04a                	sd	s2,0(sp)
    800011be:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011c0:	00000097          	auipc	ra,0x0
    800011c4:	920080e7          	jalr	-1760(ra) # 80000ae0 <kalloc>
    800011c8:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011ca:	6605                	lui	a2,0x1
    800011cc:	4581                	li	a1,0
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	afe080e7          	jalr	-1282(ra) # 80000ccc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011d6:	4719                	li	a4,6
    800011d8:	6685                	lui	a3,0x1
    800011da:	10000637          	lui	a2,0x10000
    800011de:	100005b7          	lui	a1,0x10000
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	fa0080e7          	jalr	-96(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011ec:	4719                	li	a4,6
    800011ee:	6685                	lui	a3,0x1
    800011f0:	10001637          	lui	a2,0x10001
    800011f4:	100015b7          	lui	a1,0x10001
    800011f8:	8526                	mv	a0,s1
    800011fa:	00000097          	auipc	ra,0x0
    800011fe:	f8a080e7          	jalr	-118(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001202:	4719                	li	a4,6
    80001204:	004006b7          	lui	a3,0x400
    80001208:	0c000637          	lui	a2,0xc000
    8000120c:	0c0005b7          	lui	a1,0xc000
    80001210:	8526                	mv	a0,s1
    80001212:	00000097          	auipc	ra,0x0
    80001216:	f72080e7          	jalr	-142(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000121a:	00008917          	auipc	s2,0x8
    8000121e:	de690913          	addi	s2,s2,-538 # 80009000 <etext>
    80001222:	4729                	li	a4,10
    80001224:	80008697          	auipc	a3,0x80008
    80001228:	ddc68693          	addi	a3,a3,-548 # 9000 <_entry-0x7fff7000>
    8000122c:	4605                	li	a2,1
    8000122e:	067e                	slli	a2,a2,0x1f
    80001230:	85b2                	mv	a1,a2
    80001232:	8526                	mv	a0,s1
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f50080e7          	jalr	-176(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000123c:	4719                	li	a4,6
    8000123e:	46c5                	li	a3,17
    80001240:	06ee                	slli	a3,a3,0x1b
    80001242:	412686b3          	sub	a3,a3,s2
    80001246:	864a                	mv	a2,s2
    80001248:	85ca                	mv	a1,s2
    8000124a:	8526                	mv	a0,s1
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f38080e7          	jalr	-200(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001254:	4729                	li	a4,10
    80001256:	6685                	lui	a3,0x1
    80001258:	00007617          	auipc	a2,0x7
    8000125c:	da860613          	addi	a2,a2,-600 # 80008000 <_trampoline>
    80001260:	040005b7          	lui	a1,0x4000
    80001264:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001266:	05b2                	slli	a1,a1,0xc
    80001268:	8526                	mv	a0,s1
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	f1a080e7          	jalr	-230(ra) # 80001184 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001272:	8526                	mv	a0,s1
    80001274:	00000097          	auipc	ra,0x0
    80001278:	600080e7          	jalr	1536(ra) # 80001874 <proc_mapstacks>
}
    8000127c:	8526                	mv	a0,s1
    8000127e:	60e2                	ld	ra,24(sp)
    80001280:	6442                	ld	s0,16(sp)
    80001282:	64a2                	ld	s1,8(sp)
    80001284:	6902                	ld	s2,0(sp)
    80001286:	6105                	addi	sp,sp,32
    80001288:	8082                	ret

000000008000128a <kvminit>:
{
    8000128a:	1141                	addi	sp,sp,-16
    8000128c:	e406                	sd	ra,8(sp)
    8000128e:	e022                	sd	s0,0(sp)
    80001290:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001292:	00000097          	auipc	ra,0x0
    80001296:	f22080e7          	jalr	-222(ra) # 800011b4 <kvmmake>
    8000129a:	00009797          	auipc	a5,0x9
    8000129e:	d8a7b323          	sd	a0,-634(a5) # 8000a020 <kernel_pagetable>
}
    800012a2:	60a2                	ld	ra,8(sp)
    800012a4:	6402                	ld	s0,0(sp)
    800012a6:	0141                	addi	sp,sp,16
    800012a8:	8082                	ret

00000000800012aa <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012aa:	715d                	addi	sp,sp,-80
    800012ac:	e486                	sd	ra,72(sp)
    800012ae:	e0a2                	sd	s0,64(sp)
    800012b0:	fc26                	sd	s1,56(sp)
    800012b2:	f84a                	sd	s2,48(sp)
    800012b4:	f44e                	sd	s3,40(sp)
    800012b6:	f052                	sd	s4,32(sp)
    800012b8:	ec56                	sd	s5,24(sp)
    800012ba:	e85a                	sd	s6,16(sp)
    800012bc:	e45e                	sd	s7,8(sp)
    800012be:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c0:	03459793          	slli	a5,a1,0x34
    800012c4:	e795                	bnez	a5,800012f0 <uvmunmap+0x46>
    800012c6:	8a2a                	mv	s4,a0
    800012c8:	892e                	mv	s2,a1
    800012ca:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012cc:	0632                	slli	a2,a2,0xc
    800012ce:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012d2:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012d4:	6b05                	lui	s6,0x1
    800012d6:	0735e263          	bltu	a1,s3,8000133a <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012da:	60a6                	ld	ra,72(sp)
    800012dc:	6406                	ld	s0,64(sp)
    800012de:	74e2                	ld	s1,56(sp)
    800012e0:	7942                	ld	s2,48(sp)
    800012e2:	79a2                	ld	s3,40(sp)
    800012e4:	7a02                	ld	s4,32(sp)
    800012e6:	6ae2                	ld	s5,24(sp)
    800012e8:	6b42                	ld	s6,16(sp)
    800012ea:	6ba2                	ld	s7,8(sp)
    800012ec:	6161                	addi	sp,sp,80
    800012ee:	8082                	ret
    panic("uvmunmap: not aligned");
    800012f0:	00008517          	auipc	a0,0x8
    800012f4:	e2050513          	addi	a0,a0,-480 # 80009110 <digits+0xd0>
    800012f8:	fffff097          	auipc	ra,0xfffff
    800012fc:	242080e7          	jalr	578(ra) # 8000053a <panic>
      panic("uvmunmap: walk");
    80001300:	00008517          	auipc	a0,0x8
    80001304:	e2850513          	addi	a0,a0,-472 # 80009128 <digits+0xe8>
    80001308:	fffff097          	auipc	ra,0xfffff
    8000130c:	232080e7          	jalr	562(ra) # 8000053a <panic>
      panic("uvmunmap: not mapped");
    80001310:	00008517          	auipc	a0,0x8
    80001314:	e2850513          	addi	a0,a0,-472 # 80009138 <digits+0xf8>
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	222080e7          	jalr	546(ra) # 8000053a <panic>
      panic("uvmunmap: not a leaf");
    80001320:	00008517          	auipc	a0,0x8
    80001324:	e3050513          	addi	a0,a0,-464 # 80009150 <digits+0x110>
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	212080e7          	jalr	530(ra) # 8000053a <panic>
    *pte = 0;
    80001330:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001334:	995a                	add	s2,s2,s6
    80001336:	fb3972e3          	bgeu	s2,s3,800012da <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000133a:	4601                	li	a2,0
    8000133c:	85ca                	mv	a1,s2
    8000133e:	8552                	mv	a0,s4
    80001340:	00000097          	auipc	ra,0x0
    80001344:	cbc080e7          	jalr	-836(ra) # 80000ffc <walk>
    80001348:	84aa                	mv	s1,a0
    8000134a:	d95d                	beqz	a0,80001300 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000134c:	6108                	ld	a0,0(a0)
    8000134e:	00157793          	andi	a5,a0,1
    80001352:	dfdd                	beqz	a5,80001310 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001354:	3ff57793          	andi	a5,a0,1023
    80001358:	fd7784e3          	beq	a5,s7,80001320 <uvmunmap+0x76>
    if(do_free){
    8000135c:	fc0a8ae3          	beqz	s5,80001330 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001360:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001362:	0532                	slli	a0,a0,0xc
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	67e080e7          	jalr	1662(ra) # 800009e2 <kfree>
    8000136c:	b7d1                	j	80001330 <uvmunmap+0x86>

000000008000136e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000136e:	1101                	addi	sp,sp,-32
    80001370:	ec06                	sd	ra,24(sp)
    80001372:	e822                	sd	s0,16(sp)
    80001374:	e426                	sd	s1,8(sp)
    80001376:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001378:	fffff097          	auipc	ra,0xfffff
    8000137c:	768080e7          	jalr	1896(ra) # 80000ae0 <kalloc>
    80001380:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001382:	c519                	beqz	a0,80001390 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001384:	6605                	lui	a2,0x1
    80001386:	4581                	li	a1,0
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	944080e7          	jalr	-1724(ra) # 80000ccc <memset>
  return pagetable;
}
    80001390:	8526                	mv	a0,s1
    80001392:	60e2                	ld	ra,24(sp)
    80001394:	6442                	ld	s0,16(sp)
    80001396:	64a2                	ld	s1,8(sp)
    80001398:	6105                	addi	sp,sp,32
    8000139a:	8082                	ret

000000008000139c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000139c:	7179                	addi	sp,sp,-48
    8000139e:	f406                	sd	ra,40(sp)
    800013a0:	f022                	sd	s0,32(sp)
    800013a2:	ec26                	sd	s1,24(sp)
    800013a4:	e84a                	sd	s2,16(sp)
    800013a6:	e44e                	sd	s3,8(sp)
    800013a8:	e052                	sd	s4,0(sp)
    800013aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013ac:	6785                	lui	a5,0x1
    800013ae:	04f67863          	bgeu	a2,a5,800013fe <uvminit+0x62>
    800013b2:	8a2a                	mv	s4,a0
    800013b4:	89ae                	mv	s3,a1
    800013b6:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013b8:	fffff097          	auipc	ra,0xfffff
    800013bc:	728080e7          	jalr	1832(ra) # 80000ae0 <kalloc>
    800013c0:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013c2:	6605                	lui	a2,0x1
    800013c4:	4581                	li	a1,0
    800013c6:	00000097          	auipc	ra,0x0
    800013ca:	906080e7          	jalr	-1786(ra) # 80000ccc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013ce:	4779                	li	a4,30
    800013d0:	86ca                	mv	a3,s2
    800013d2:	6605                	lui	a2,0x1
    800013d4:	4581                	li	a1,0
    800013d6:	8552                	mv	a0,s4
    800013d8:	00000097          	auipc	ra,0x0
    800013dc:	d0c080e7          	jalr	-756(ra) # 800010e4 <mappages>
  memmove(mem, src, sz);
    800013e0:	8626                	mv	a2,s1
    800013e2:	85ce                	mv	a1,s3
    800013e4:	854a                	mv	a0,s2
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	942080e7          	jalr	-1726(ra) # 80000d28 <memmove>
}
    800013ee:	70a2                	ld	ra,40(sp)
    800013f0:	7402                	ld	s0,32(sp)
    800013f2:	64e2                	ld	s1,24(sp)
    800013f4:	6942                	ld	s2,16(sp)
    800013f6:	69a2                	ld	s3,8(sp)
    800013f8:	6a02                	ld	s4,0(sp)
    800013fa:	6145                	addi	sp,sp,48
    800013fc:	8082                	ret
    panic("inituvm: more than a page");
    800013fe:	00008517          	auipc	a0,0x8
    80001402:	d6a50513          	addi	a0,a0,-662 # 80009168 <digits+0x128>
    80001406:	fffff097          	auipc	ra,0xfffff
    8000140a:	134080e7          	jalr	308(ra) # 8000053a <panic>

000000008000140e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000140e:	1101                	addi	sp,sp,-32
    80001410:	ec06                	sd	ra,24(sp)
    80001412:	e822                	sd	s0,16(sp)
    80001414:	e426                	sd	s1,8(sp)
    80001416:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001418:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000141a:	00b67d63          	bgeu	a2,a1,80001434 <uvmdealloc+0x26>
    8000141e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	00f60733          	add	a4,a2,a5
    80001428:	76fd                	lui	a3,0xfffff
    8000142a:	8f75                	and	a4,a4,a3
    8000142c:	97ae                	add	a5,a5,a1
    8000142e:	8ff5                	and	a5,a5,a3
    80001430:	00f76863          	bltu	a4,a5,80001440 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001434:	8526                	mv	a0,s1
    80001436:	60e2                	ld	ra,24(sp)
    80001438:	6442                	ld	s0,16(sp)
    8000143a:	64a2                	ld	s1,8(sp)
    8000143c:	6105                	addi	sp,sp,32
    8000143e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001440:	8f99                	sub	a5,a5,a4
    80001442:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001444:	4685                	li	a3,1
    80001446:	0007861b          	sext.w	a2,a5
    8000144a:	85ba                	mv	a1,a4
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	e5e080e7          	jalr	-418(ra) # 800012aa <uvmunmap>
    80001454:	b7c5                	j	80001434 <uvmdealloc+0x26>

0000000080001456 <uvmalloc>:
  if(newsz < oldsz)
    80001456:	0ab66163          	bltu	a2,a1,800014f8 <uvmalloc+0xa2>
{
    8000145a:	7139                	addi	sp,sp,-64
    8000145c:	fc06                	sd	ra,56(sp)
    8000145e:	f822                	sd	s0,48(sp)
    80001460:	f426                	sd	s1,40(sp)
    80001462:	f04a                	sd	s2,32(sp)
    80001464:	ec4e                	sd	s3,24(sp)
    80001466:	e852                	sd	s4,16(sp)
    80001468:	e456                	sd	s5,8(sp)
    8000146a:	0080                	addi	s0,sp,64
    8000146c:	8aaa                	mv	s5,a0
    8000146e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001470:	6785                	lui	a5,0x1
    80001472:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001474:	95be                	add	a1,a1,a5
    80001476:	77fd                	lui	a5,0xfffff
    80001478:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147c:	08c9f063          	bgeu	s3,a2,800014fc <uvmalloc+0xa6>
    80001480:	894e                	mv	s2,s3
    mem = kalloc();
    80001482:	fffff097          	auipc	ra,0xfffff
    80001486:	65e080e7          	jalr	1630(ra) # 80000ae0 <kalloc>
    8000148a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000148c:	c51d                	beqz	a0,800014ba <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000148e:	6605                	lui	a2,0x1
    80001490:	4581                	li	a1,0
    80001492:	00000097          	auipc	ra,0x0
    80001496:	83a080e7          	jalr	-1990(ra) # 80000ccc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000149a:	4779                	li	a4,30
    8000149c:	86a6                	mv	a3,s1
    8000149e:	6605                	lui	a2,0x1
    800014a0:	85ca                	mv	a1,s2
    800014a2:	8556                	mv	a0,s5
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	c40080e7          	jalr	-960(ra) # 800010e4 <mappages>
    800014ac:	e905                	bnez	a0,800014dc <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ae:	6785                	lui	a5,0x1
    800014b0:	993e                	add	s2,s2,a5
    800014b2:	fd4968e3          	bltu	s2,s4,80001482 <uvmalloc+0x2c>
  return newsz;
    800014b6:	8552                	mv	a0,s4
    800014b8:	a809                	j	800014ca <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014ba:	864e                	mv	a2,s3
    800014bc:	85ca                	mv	a1,s2
    800014be:	8556                	mv	a0,s5
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	f4e080e7          	jalr	-178(ra) # 8000140e <uvmdealloc>
      return 0;
    800014c8:	4501                	li	a0,0
}
    800014ca:	70e2                	ld	ra,56(sp)
    800014cc:	7442                	ld	s0,48(sp)
    800014ce:	74a2                	ld	s1,40(sp)
    800014d0:	7902                	ld	s2,32(sp)
    800014d2:	69e2                	ld	s3,24(sp)
    800014d4:	6a42                	ld	s4,16(sp)
    800014d6:	6aa2                	ld	s5,8(sp)
    800014d8:	6121                	addi	sp,sp,64
    800014da:	8082                	ret
      kfree(mem);
    800014dc:	8526                	mv	a0,s1
    800014de:	fffff097          	auipc	ra,0xfffff
    800014e2:	504080e7          	jalr	1284(ra) # 800009e2 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014e6:	864e                	mv	a2,s3
    800014e8:	85ca                	mv	a1,s2
    800014ea:	8556                	mv	a0,s5
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	f22080e7          	jalr	-222(ra) # 8000140e <uvmdealloc>
      return 0;
    800014f4:	4501                	li	a0,0
    800014f6:	bfd1                	j	800014ca <uvmalloc+0x74>
    return oldsz;
    800014f8:	852e                	mv	a0,a1
}
    800014fa:	8082                	ret
  return newsz;
    800014fc:	8532                	mv	a0,a2
    800014fe:	b7f1                	j	800014ca <uvmalloc+0x74>

0000000080001500 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001500:	7179                	addi	sp,sp,-48
    80001502:	f406                	sd	ra,40(sp)
    80001504:	f022                	sd	s0,32(sp)
    80001506:	ec26                	sd	s1,24(sp)
    80001508:	e84a                	sd	s2,16(sp)
    8000150a:	e44e                	sd	s3,8(sp)
    8000150c:	e052                	sd	s4,0(sp)
    8000150e:	1800                	addi	s0,sp,48
    80001510:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001512:	84aa                	mv	s1,a0
    80001514:	6905                	lui	s2,0x1
    80001516:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001518:	4985                	li	s3,1
    8000151a:	a829                	j	80001534 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000151c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000151e:	00c79513          	slli	a0,a5,0xc
    80001522:	00000097          	auipc	ra,0x0
    80001526:	fde080e7          	jalr	-34(ra) # 80001500 <freewalk>
      pagetable[i] = 0;
    8000152a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000152e:	04a1                	addi	s1,s1,8
    80001530:	03248163          	beq	s1,s2,80001552 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001534:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001536:	00f7f713          	andi	a4,a5,15
    8000153a:	ff3701e3          	beq	a4,s3,8000151c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000153e:	8b85                	andi	a5,a5,1
    80001540:	d7fd                	beqz	a5,8000152e <freewalk+0x2e>
      panic("freewalk: leaf");
    80001542:	00008517          	auipc	a0,0x8
    80001546:	c4650513          	addi	a0,a0,-954 # 80009188 <digits+0x148>
    8000154a:	fffff097          	auipc	ra,0xfffff
    8000154e:	ff0080e7          	jalr	-16(ra) # 8000053a <panic>
    }
  }
  kfree((void*)pagetable);
    80001552:	8552                	mv	a0,s4
    80001554:	fffff097          	auipc	ra,0xfffff
    80001558:	48e080e7          	jalr	1166(ra) # 800009e2 <kfree>
}
    8000155c:	70a2                	ld	ra,40(sp)
    8000155e:	7402                	ld	s0,32(sp)
    80001560:	64e2                	ld	s1,24(sp)
    80001562:	6942                	ld	s2,16(sp)
    80001564:	69a2                	ld	s3,8(sp)
    80001566:	6a02                	ld	s4,0(sp)
    80001568:	6145                	addi	sp,sp,48
    8000156a:	8082                	ret

000000008000156c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000156c:	1101                	addi	sp,sp,-32
    8000156e:	ec06                	sd	ra,24(sp)
    80001570:	e822                	sd	s0,16(sp)
    80001572:	e426                	sd	s1,8(sp)
    80001574:	1000                	addi	s0,sp,32
    80001576:	84aa                	mv	s1,a0
  if(sz > 0)
    80001578:	e999                	bnez	a1,8000158e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000157a:	8526                	mv	a0,s1
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	f84080e7          	jalr	-124(ra) # 80001500 <freewalk>
}
    80001584:	60e2                	ld	ra,24(sp)
    80001586:	6442                	ld	s0,16(sp)
    80001588:	64a2                	ld	s1,8(sp)
    8000158a:	6105                	addi	sp,sp,32
    8000158c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000158e:	6785                	lui	a5,0x1
    80001590:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001592:	95be                	add	a1,a1,a5
    80001594:	4685                	li	a3,1
    80001596:	00c5d613          	srli	a2,a1,0xc
    8000159a:	4581                	li	a1,0
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	d0e080e7          	jalr	-754(ra) # 800012aa <uvmunmap>
    800015a4:	bfd9                	j	8000157a <uvmfree+0xe>

00000000800015a6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015a6:	c679                	beqz	a2,80001674 <uvmcopy+0xce>
{
    800015a8:	715d                	addi	sp,sp,-80
    800015aa:	e486                	sd	ra,72(sp)
    800015ac:	e0a2                	sd	s0,64(sp)
    800015ae:	fc26                	sd	s1,56(sp)
    800015b0:	f84a                	sd	s2,48(sp)
    800015b2:	f44e                	sd	s3,40(sp)
    800015b4:	f052                	sd	s4,32(sp)
    800015b6:	ec56                	sd	s5,24(sp)
    800015b8:	e85a                	sd	s6,16(sp)
    800015ba:	e45e                	sd	s7,8(sp)
    800015bc:	0880                	addi	s0,sp,80
    800015be:	8b2a                	mv	s6,a0
    800015c0:	8aae                	mv	s5,a1
    800015c2:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015c4:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015c6:	4601                	li	a2,0
    800015c8:	85ce                	mv	a1,s3
    800015ca:	855a                	mv	a0,s6
    800015cc:	00000097          	auipc	ra,0x0
    800015d0:	a30080e7          	jalr	-1488(ra) # 80000ffc <walk>
    800015d4:	c531                	beqz	a0,80001620 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015d6:	6118                	ld	a4,0(a0)
    800015d8:	00177793          	andi	a5,a4,1
    800015dc:	cbb1                	beqz	a5,80001630 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015de:	00a75593          	srli	a1,a4,0xa
    800015e2:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015e6:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	4f6080e7          	jalr	1270(ra) # 80000ae0 <kalloc>
    800015f2:	892a                	mv	s2,a0
    800015f4:	c939                	beqz	a0,8000164a <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015f6:	6605                	lui	a2,0x1
    800015f8:	85de                	mv	a1,s7
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	72e080e7          	jalr	1838(ra) # 80000d28 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001602:	8726                	mv	a4,s1
    80001604:	86ca                	mv	a3,s2
    80001606:	6605                	lui	a2,0x1
    80001608:	85ce                	mv	a1,s3
    8000160a:	8556                	mv	a0,s5
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	ad8080e7          	jalr	-1320(ra) # 800010e4 <mappages>
    80001614:	e515                	bnez	a0,80001640 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001616:	6785                	lui	a5,0x1
    80001618:	99be                	add	s3,s3,a5
    8000161a:	fb49e6e3          	bltu	s3,s4,800015c6 <uvmcopy+0x20>
    8000161e:	a081                	j	8000165e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001620:	00008517          	auipc	a0,0x8
    80001624:	b7850513          	addi	a0,a0,-1160 # 80009198 <digits+0x158>
    80001628:	fffff097          	auipc	ra,0xfffff
    8000162c:	f12080e7          	jalr	-238(ra) # 8000053a <panic>
      panic("uvmcopy: page not present");
    80001630:	00008517          	auipc	a0,0x8
    80001634:	b8850513          	addi	a0,a0,-1144 # 800091b8 <digits+0x178>
    80001638:	fffff097          	auipc	ra,0xfffff
    8000163c:	f02080e7          	jalr	-254(ra) # 8000053a <panic>
      kfree(mem);
    80001640:	854a                	mv	a0,s2
    80001642:	fffff097          	auipc	ra,0xfffff
    80001646:	3a0080e7          	jalr	928(ra) # 800009e2 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000164a:	4685                	li	a3,1
    8000164c:	00c9d613          	srli	a2,s3,0xc
    80001650:	4581                	li	a1,0
    80001652:	8556                	mv	a0,s5
    80001654:	00000097          	auipc	ra,0x0
    80001658:	c56080e7          	jalr	-938(ra) # 800012aa <uvmunmap>
  return -1;
    8000165c:	557d                	li	a0,-1
}
    8000165e:	60a6                	ld	ra,72(sp)
    80001660:	6406                	ld	s0,64(sp)
    80001662:	74e2                	ld	s1,56(sp)
    80001664:	7942                	ld	s2,48(sp)
    80001666:	79a2                	ld	s3,40(sp)
    80001668:	7a02                	ld	s4,32(sp)
    8000166a:	6ae2                	ld	s5,24(sp)
    8000166c:	6b42                	ld	s6,16(sp)
    8000166e:	6ba2                	ld	s7,8(sp)
    80001670:	6161                	addi	sp,sp,80
    80001672:	8082                	ret
  return 0;
    80001674:	4501                	li	a0,0
}
    80001676:	8082                	ret

0000000080001678 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001678:	1141                	addi	sp,sp,-16
    8000167a:	e406                	sd	ra,8(sp)
    8000167c:	e022                	sd	s0,0(sp)
    8000167e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001680:	4601                	li	a2,0
    80001682:	00000097          	auipc	ra,0x0
    80001686:	97a080e7          	jalr	-1670(ra) # 80000ffc <walk>
  if(pte == 0)
    8000168a:	c901                	beqz	a0,8000169a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000168c:	611c                	ld	a5,0(a0)
    8000168e:	9bbd                	andi	a5,a5,-17
    80001690:	e11c                	sd	a5,0(a0)
}
    80001692:	60a2                	ld	ra,8(sp)
    80001694:	6402                	ld	s0,0(sp)
    80001696:	0141                	addi	sp,sp,16
    80001698:	8082                	ret
    panic("uvmclear");
    8000169a:	00008517          	auipc	a0,0x8
    8000169e:	b3e50513          	addi	a0,a0,-1218 # 800091d8 <digits+0x198>
    800016a2:	fffff097          	auipc	ra,0xfffff
    800016a6:	e98080e7          	jalr	-360(ra) # 8000053a <panic>

00000000800016aa <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016aa:	c6bd                	beqz	a3,80001718 <copyout+0x6e>
{
    800016ac:	715d                	addi	sp,sp,-80
    800016ae:	e486                	sd	ra,72(sp)
    800016b0:	e0a2                	sd	s0,64(sp)
    800016b2:	fc26                	sd	s1,56(sp)
    800016b4:	f84a                	sd	s2,48(sp)
    800016b6:	f44e                	sd	s3,40(sp)
    800016b8:	f052                	sd	s4,32(sp)
    800016ba:	ec56                	sd	s5,24(sp)
    800016bc:	e85a                	sd	s6,16(sp)
    800016be:	e45e                	sd	s7,8(sp)
    800016c0:	e062                	sd	s8,0(sp)
    800016c2:	0880                	addi	s0,sp,80
    800016c4:	8b2a                	mv	s6,a0
    800016c6:	8c2e                	mv	s8,a1
    800016c8:	8a32                	mv	s4,a2
    800016ca:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016cc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ce:	6a85                	lui	s5,0x1
    800016d0:	a015                	j	800016f4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016d2:	9562                	add	a0,a0,s8
    800016d4:	0004861b          	sext.w	a2,s1
    800016d8:	85d2                	mv	a1,s4
    800016da:	41250533          	sub	a0,a0,s2
    800016de:	fffff097          	auipc	ra,0xfffff
    800016e2:	64a080e7          	jalr	1610(ra) # 80000d28 <memmove>

    len -= n;
    800016e6:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ea:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ec:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016f0:	02098263          	beqz	s3,80001714 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016f4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016f8:	85ca                	mv	a1,s2
    800016fa:	855a                	mv	a0,s6
    800016fc:	00000097          	auipc	ra,0x0
    80001700:	9a6080e7          	jalr	-1626(ra) # 800010a2 <walkaddr>
    if(pa0 == 0)
    80001704:	cd01                	beqz	a0,8000171c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001706:	418904b3          	sub	s1,s2,s8
    8000170a:	94d6                	add	s1,s1,s5
    8000170c:	fc99f3e3          	bgeu	s3,s1,800016d2 <copyout+0x28>
    80001710:	84ce                	mv	s1,s3
    80001712:	b7c1                	j	800016d2 <copyout+0x28>
  }
  return 0;
    80001714:	4501                	li	a0,0
    80001716:	a021                	j	8000171e <copyout+0x74>
    80001718:	4501                	li	a0,0
}
    8000171a:	8082                	ret
      return -1;
    8000171c:	557d                	li	a0,-1
}
    8000171e:	60a6                	ld	ra,72(sp)
    80001720:	6406                	ld	s0,64(sp)
    80001722:	74e2                	ld	s1,56(sp)
    80001724:	7942                	ld	s2,48(sp)
    80001726:	79a2                	ld	s3,40(sp)
    80001728:	7a02                	ld	s4,32(sp)
    8000172a:	6ae2                	ld	s5,24(sp)
    8000172c:	6b42                	ld	s6,16(sp)
    8000172e:	6ba2                	ld	s7,8(sp)
    80001730:	6c02                	ld	s8,0(sp)
    80001732:	6161                	addi	sp,sp,80
    80001734:	8082                	ret

0000000080001736 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001736:	caa5                	beqz	a3,800017a6 <copyin+0x70>
{
    80001738:	715d                	addi	sp,sp,-80
    8000173a:	e486                	sd	ra,72(sp)
    8000173c:	e0a2                	sd	s0,64(sp)
    8000173e:	fc26                	sd	s1,56(sp)
    80001740:	f84a                	sd	s2,48(sp)
    80001742:	f44e                	sd	s3,40(sp)
    80001744:	f052                	sd	s4,32(sp)
    80001746:	ec56                	sd	s5,24(sp)
    80001748:	e85a                	sd	s6,16(sp)
    8000174a:	e45e                	sd	s7,8(sp)
    8000174c:	e062                	sd	s8,0(sp)
    8000174e:	0880                	addi	s0,sp,80
    80001750:	8b2a                	mv	s6,a0
    80001752:	8a2e                	mv	s4,a1
    80001754:	8c32                	mv	s8,a2
    80001756:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001758:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000175a:	6a85                	lui	s5,0x1
    8000175c:	a01d                	j	80001782 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000175e:	018505b3          	add	a1,a0,s8
    80001762:	0004861b          	sext.w	a2,s1
    80001766:	412585b3          	sub	a1,a1,s2
    8000176a:	8552                	mv	a0,s4
    8000176c:	fffff097          	auipc	ra,0xfffff
    80001770:	5bc080e7          	jalr	1468(ra) # 80000d28 <memmove>

    len -= n;
    80001774:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001778:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000177a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000177e:	02098263          	beqz	s3,800017a2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001782:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001786:	85ca                	mv	a1,s2
    80001788:	855a                	mv	a0,s6
    8000178a:	00000097          	auipc	ra,0x0
    8000178e:	918080e7          	jalr	-1768(ra) # 800010a2 <walkaddr>
    if(pa0 == 0)
    80001792:	cd01                	beqz	a0,800017aa <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001794:	418904b3          	sub	s1,s2,s8
    80001798:	94d6                	add	s1,s1,s5
    8000179a:	fc99f2e3          	bgeu	s3,s1,8000175e <copyin+0x28>
    8000179e:	84ce                	mv	s1,s3
    800017a0:	bf7d                	j	8000175e <copyin+0x28>
  }
  return 0;
    800017a2:	4501                	li	a0,0
    800017a4:	a021                	j	800017ac <copyin+0x76>
    800017a6:	4501                	li	a0,0
}
    800017a8:	8082                	ret
      return -1;
    800017aa:	557d                	li	a0,-1
}
    800017ac:	60a6                	ld	ra,72(sp)
    800017ae:	6406                	ld	s0,64(sp)
    800017b0:	74e2                	ld	s1,56(sp)
    800017b2:	7942                	ld	s2,48(sp)
    800017b4:	79a2                	ld	s3,40(sp)
    800017b6:	7a02                	ld	s4,32(sp)
    800017b8:	6ae2                	ld	s5,24(sp)
    800017ba:	6b42                	ld	s6,16(sp)
    800017bc:	6ba2                	ld	s7,8(sp)
    800017be:	6c02                	ld	s8,0(sp)
    800017c0:	6161                	addi	sp,sp,80
    800017c2:	8082                	ret

00000000800017c4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017c4:	c2dd                	beqz	a3,8000186a <copyinstr+0xa6>
{
    800017c6:	715d                	addi	sp,sp,-80
    800017c8:	e486                	sd	ra,72(sp)
    800017ca:	e0a2                	sd	s0,64(sp)
    800017cc:	fc26                	sd	s1,56(sp)
    800017ce:	f84a                	sd	s2,48(sp)
    800017d0:	f44e                	sd	s3,40(sp)
    800017d2:	f052                	sd	s4,32(sp)
    800017d4:	ec56                	sd	s5,24(sp)
    800017d6:	e85a                	sd	s6,16(sp)
    800017d8:	e45e                	sd	s7,8(sp)
    800017da:	0880                	addi	s0,sp,80
    800017dc:	8a2a                	mv	s4,a0
    800017de:	8b2e                	mv	s6,a1
    800017e0:	8bb2                	mv	s7,a2
    800017e2:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017e4:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e6:	6985                	lui	s3,0x1
    800017e8:	a02d                	j	80001812 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ea:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ee:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017f0:	37fd                	addiw	a5,a5,-1
    800017f2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017f6:	60a6                	ld	ra,72(sp)
    800017f8:	6406                	ld	s0,64(sp)
    800017fa:	74e2                	ld	s1,56(sp)
    800017fc:	7942                	ld	s2,48(sp)
    800017fe:	79a2                	ld	s3,40(sp)
    80001800:	7a02                	ld	s4,32(sp)
    80001802:	6ae2                	ld	s5,24(sp)
    80001804:	6b42                	ld	s6,16(sp)
    80001806:	6ba2                	ld	s7,8(sp)
    80001808:	6161                	addi	sp,sp,80
    8000180a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000180c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001810:	c8a9                	beqz	s1,80001862 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001812:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001816:	85ca                	mv	a1,s2
    80001818:	8552                	mv	a0,s4
    8000181a:	00000097          	auipc	ra,0x0
    8000181e:	888080e7          	jalr	-1912(ra) # 800010a2 <walkaddr>
    if(pa0 == 0)
    80001822:	c131                	beqz	a0,80001866 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001824:	417906b3          	sub	a3,s2,s7
    80001828:	96ce                	add	a3,a3,s3
    8000182a:	00d4f363          	bgeu	s1,a3,80001830 <copyinstr+0x6c>
    8000182e:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001830:	955e                	add	a0,a0,s7
    80001832:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001836:	daf9                	beqz	a3,8000180c <copyinstr+0x48>
    80001838:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000183a:	41650633          	sub	a2,a0,s6
    8000183e:	fff48593          	addi	a1,s1,-1
    80001842:	95da                	add	a1,a1,s6
    while(n > 0){
    80001844:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001846:	00f60733          	add	a4,a2,a5
    8000184a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd6000>
    8000184e:	df51                	beqz	a4,800017ea <copyinstr+0x26>
        *dst = *p;
    80001850:	00e78023          	sb	a4,0(a5)
      --max;
    80001854:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001858:	0785                	addi	a5,a5,1
    while(n > 0){
    8000185a:	fed796e3          	bne	a5,a3,80001846 <copyinstr+0x82>
      dst++;
    8000185e:	8b3e                	mv	s6,a5
    80001860:	b775                	j	8000180c <copyinstr+0x48>
    80001862:	4781                	li	a5,0
    80001864:	b771                	j	800017f0 <copyinstr+0x2c>
      return -1;
    80001866:	557d                	li	a0,-1
    80001868:	b779                	j	800017f6 <copyinstr+0x32>
  int got_null = 0;
    8000186a:	4781                	li	a5,0
  if(got_null){
    8000186c:	37fd                	addiw	a5,a5,-1
    8000186e:	0007851b          	sext.w	a0,a5
}
    80001872:	8082                	ret

0000000080001874 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001874:	7139                	addi	sp,sp,-64
    80001876:	fc06                	sd	ra,56(sp)
    80001878:	f822                	sd	s0,48(sp)
    8000187a:	f426                	sd	s1,40(sp)
    8000187c:	f04a                	sd	s2,32(sp)
    8000187e:	ec4e                	sd	s3,24(sp)
    80001880:	e852                	sd	s4,16(sp)
    80001882:	e456                	sd	s5,8(sp)
    80001884:	e05a                	sd	s6,0(sp)
    80001886:	0080                	addi	s0,sp,64
    80001888:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188a:	00011497          	auipc	s1,0x11
    8000188e:	e9e48493          	addi	s1,s1,-354 # 80012728 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001892:	8b26                	mv	s6,s1
    80001894:	00007a97          	auipc	s5,0x7
    80001898:	76ca8a93          	addi	s5,s5,1900 # 80009000 <etext>
    8000189c:	04000937          	lui	s2,0x4000
    800018a0:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800018a2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a4:	00017a17          	auipc	s4,0x17
    800018a8:	284a0a13          	addi	s4,s4,644 # 80018b28 <tickslock>
    char *pa = kalloc();
    800018ac:	fffff097          	auipc	ra,0xfffff
    800018b0:	234080e7          	jalr	564(ra) # 80000ae0 <kalloc>
    800018b4:	862a                	mv	a2,a0
    if(pa == 0)
    800018b6:	c131                	beqz	a0,800018fa <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018b8:	416485b3          	sub	a1,s1,s6
    800018bc:	8591                	srai	a1,a1,0x4
    800018be:	000ab783          	ld	a5,0(s5)
    800018c2:	02f585b3          	mul	a1,a1,a5
    800018c6:	2585                	addiw	a1,a1,1
    800018c8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018cc:	4719                	li	a4,6
    800018ce:	6685                	lui	a3,0x1
    800018d0:	40b905b3          	sub	a1,s2,a1
    800018d4:	854e                	mv	a0,s3
    800018d6:	00000097          	auipc	ra,0x0
    800018da:	8ae080e7          	jalr	-1874(ra) # 80001184 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018de:	19048493          	addi	s1,s1,400
    800018e2:	fd4495e3          	bne	s1,s4,800018ac <proc_mapstacks+0x38>
  }
}
    800018e6:	70e2                	ld	ra,56(sp)
    800018e8:	7442                	ld	s0,48(sp)
    800018ea:	74a2                	ld	s1,40(sp)
    800018ec:	7902                	ld	s2,32(sp)
    800018ee:	69e2                	ld	s3,24(sp)
    800018f0:	6a42                	ld	s4,16(sp)
    800018f2:	6aa2                	ld	s5,8(sp)
    800018f4:	6b02                	ld	s6,0(sp)
    800018f6:	6121                	addi	sp,sp,64
    800018f8:	8082                	ret
      panic("kalloc");
    800018fa:	00008517          	auipc	a0,0x8
    800018fe:	8ee50513          	addi	a0,a0,-1810 # 800091e8 <digits+0x1a8>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	c38080e7          	jalr	-968(ra) # 8000053a <panic>

000000008000190a <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000190a:	7139                	addi	sp,sp,-64
    8000190c:	fc06                	sd	ra,56(sp)
    8000190e:	f822                	sd	s0,48(sp)
    80001910:	f426                	sd	s1,40(sp)
    80001912:	f04a                	sd	s2,32(sp)
    80001914:	ec4e                	sd	s3,24(sp)
    80001916:	e852                	sd	s4,16(sp)
    80001918:	e456                	sd	s5,8(sp)
    8000191a:	e05a                	sd	s6,0(sp)
    8000191c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000191e:	00008597          	auipc	a1,0x8
    80001922:	8d258593          	addi	a1,a1,-1838 # 800091f0 <digits+0x1b0>
    80001926:	00011517          	auipc	a0,0x11
    8000192a:	9ba50513          	addi	a0,a0,-1606 # 800122e0 <pid_lock>
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	212080e7          	jalr	530(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001936:	00008597          	auipc	a1,0x8
    8000193a:	8c258593          	addi	a1,a1,-1854 # 800091f8 <digits+0x1b8>
    8000193e:	00011517          	auipc	a0,0x11
    80001942:	9ba50513          	addi	a0,a0,-1606 # 800122f8 <wait_lock>
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	1fa080e7          	jalr	506(ra) # 80000b40 <initlock>
  initlock(&condsleep_lock, "condsleep_lock");
    8000194e:	00008597          	auipc	a1,0x8
    80001952:	8ba58593          	addi	a1,a1,-1862 # 80009208 <digits+0x1c8>
    80001956:	00011517          	auipc	a0,0x11
    8000195a:	9ba50513          	addi	a0,a0,-1606 # 80012310 <condsleep_lock>
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	1e2080e7          	jalr	482(ra) # 80000b40 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001966:	00011497          	auipc	s1,0x11
    8000196a:	dc248493          	addi	s1,s1,-574 # 80012728 <proc>
      initlock(&p->lock, "proc");
    8000196e:	00008b17          	auipc	s6,0x8
    80001972:	8aab0b13          	addi	s6,s6,-1878 # 80009218 <digits+0x1d8>
      p->kstack = KSTACK((int) (p - proc));
    80001976:	8aa6                	mv	s5,s1
    80001978:	00007a17          	auipc	s4,0x7
    8000197c:	688a0a13          	addi	s4,s4,1672 # 80009000 <etext>
    80001980:	04000937          	lui	s2,0x4000
    80001984:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001986:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001988:	00017997          	auipc	s3,0x17
    8000198c:	1a098993          	addi	s3,s3,416 # 80018b28 <tickslock>
      initlock(&p->lock, "proc");
    80001990:	85da                	mv	a1,s6
    80001992:	8526                	mv	a0,s1
    80001994:	fffff097          	auipc	ra,0xfffff
    80001998:	1ac080e7          	jalr	428(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000199c:	415487b3          	sub	a5,s1,s5
    800019a0:	8791                	srai	a5,a5,0x4
    800019a2:	000a3703          	ld	a4,0(s4)
    800019a6:	02e787b3          	mul	a5,a5,a4
    800019aa:	2785                	addiw	a5,a5,1
    800019ac:	00d7979b          	slliw	a5,a5,0xd
    800019b0:	40f907b3          	sub	a5,s2,a5
    800019b4:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b6:	19048493          	addi	s1,s1,400
    800019ba:	fd349be3          	bne	s1,s3,80001990 <procinit+0x86>
  }
}
    800019be:	70e2                	ld	ra,56(sp)
    800019c0:	7442                	ld	s0,48(sp)
    800019c2:	74a2                	ld	s1,40(sp)
    800019c4:	7902                	ld	s2,32(sp)
    800019c6:	69e2                	ld	s3,24(sp)
    800019c8:	6a42                	ld	s4,16(sp)
    800019ca:	6aa2                	ld	s5,8(sp)
    800019cc:	6b02                	ld	s6,0(sp)
    800019ce:	6121                	addi	sp,sp,64
    800019d0:	8082                	ret

00000000800019d2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019d2:	1141                	addi	sp,sp,-16
    800019d4:	e422                	sd	s0,8(sp)
    800019d6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019d8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019da:	2501                	sext.w	a0,a0
    800019dc:	6422                	ld	s0,8(sp)
    800019de:	0141                	addi	sp,sp,16
    800019e0:	8082                	ret

00000000800019e2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    800019e2:	1141                	addi	sp,sp,-16
    800019e4:	e422                	sd	s0,8(sp)
    800019e6:	0800                	addi	s0,sp,16
    800019e8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019ea:	2781                	sext.w	a5,a5
    800019ec:	079e                	slli	a5,a5,0x7
  return c;
}
    800019ee:	00011517          	auipc	a0,0x11
    800019f2:	93a50513          	addi	a0,a0,-1734 # 80012328 <cpus>
    800019f6:	953e                	add	a0,a0,a5
    800019f8:	6422                	ld	s0,8(sp)
    800019fa:	0141                	addi	sp,sp,16
    800019fc:	8082                	ret

00000000800019fe <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019fe:	1101                	addi	sp,sp,-32
    80001a00:	ec06                	sd	ra,24(sp)
    80001a02:	e822                	sd	s0,16(sp)
    80001a04:	e426                	sd	s1,8(sp)
    80001a06:	1000                	addi	s0,sp,32
  push_off();
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	17c080e7          	jalr	380(ra) # 80000b84 <push_off>
    80001a10:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a12:	2781                	sext.w	a5,a5
    80001a14:	079e                	slli	a5,a5,0x7
    80001a16:	00011717          	auipc	a4,0x11
    80001a1a:	8ca70713          	addi	a4,a4,-1846 # 800122e0 <pid_lock>
    80001a1e:	97ba                	add	a5,a5,a4
    80001a20:	67a4                	ld	s1,72(a5)
  pop_off();
    80001a22:	fffff097          	auipc	ra,0xfffff
    80001a26:	202080e7          	jalr	514(ra) # 80000c24 <pop_off>
  return p;
}
    80001a2a:	8526                	mv	a0,s1
    80001a2c:	60e2                	ld	ra,24(sp)
    80001a2e:	6442                	ld	s0,16(sp)
    80001a30:	64a2                	ld	s1,8(sp)
    80001a32:	6105                	addi	sp,sp,32
    80001a34:	8082                	ret

0000000080001a36 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a36:	1101                	addi	sp,sp,-32
    80001a38:	ec06                	sd	ra,24(sp)
    80001a3a:	e822                	sd	s0,16(sp)
    80001a3c:	e426                	sd	s1,8(sp)
    80001a3e:	1000                	addi	s0,sp,32
  static int first = 1;
  uint xticks;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a40:	00000097          	auipc	ra,0x0
    80001a44:	fbe080e7          	jalr	-66(ra) # 800019fe <myproc>
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	23c080e7          	jalr	572(ra) # 80000c84 <release>

  acquire(&tickslock);
    80001a50:	00017517          	auipc	a0,0x17
    80001a54:	0d850513          	addi	a0,a0,216 # 80018b28 <tickslock>
    80001a58:	fffff097          	auipc	ra,0xfffff
    80001a5c:	178080e7          	jalr	376(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80001a60:	00008497          	auipc	s1,0x8
    80001a64:	60c4a483          	lw	s1,1548(s1) # 8000a06c <ticks>
  release(&tickslock);
    80001a68:	00017517          	auipc	a0,0x17
    80001a6c:	0c050513          	addi	a0,a0,192 # 80018b28 <tickslock>
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	214080e7          	jalr	532(ra) # 80000c84 <release>

  myproc()->stime = xticks;
    80001a78:	00000097          	auipc	ra,0x0
    80001a7c:	f86080e7          	jalr	-122(ra) # 800019fe <myproc>
    80001a80:	16952a23          	sw	s1,372(a0)

  if (first) {
    80001a84:	00008797          	auipc	a5,0x8
    80001a88:	14c7a783          	lw	a5,332(a5) # 80009bd0 <first.3>
    80001a8c:	eb91                	bnez	a5,80001aa0 <forkret+0x6a>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a8e:	00002097          	auipc	ra,0x2
    80001a92:	ee2080e7          	jalr	-286(ra) # 80003970 <usertrapret>
}
    80001a96:	60e2                	ld	ra,24(sp)
    80001a98:	6442                	ld	s0,16(sp)
    80001a9a:	64a2                	ld	s1,8(sp)
    80001a9c:	6105                	addi	sp,sp,32
    80001a9e:	8082                	ret
    first = 0;
    80001aa0:	00008797          	auipc	a5,0x8
    80001aa4:	1207a823          	sw	zero,304(a5) # 80009bd0 <first.3>
    fsinit(ROOTDEV);
    80001aa8:	4505                	li	a0,1
    80001aaa:	00003097          	auipc	ra,0x3
    80001aae:	4d6080e7          	jalr	1238(ra) # 80004f80 <fsinit>
    80001ab2:	bff1                	j	80001a8e <forkret+0x58>

0000000080001ab4 <allocpid>:
allocpid() {
    80001ab4:	1101                	addi	sp,sp,-32
    80001ab6:	ec06                	sd	ra,24(sp)
    80001ab8:	e822                	sd	s0,16(sp)
    80001aba:	e426                	sd	s1,8(sp)
    80001abc:	e04a                	sd	s2,0(sp)
    80001abe:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ac0:	00011917          	auipc	s2,0x11
    80001ac4:	82090913          	addi	s2,s2,-2016 # 800122e0 <pid_lock>
    80001ac8:	854a                	mv	a0,s2
    80001aca:	fffff097          	auipc	ra,0xfffff
    80001ace:	106080e7          	jalr	262(ra) # 80000bd0 <acquire>
  pid = nextpid;
    80001ad2:	00008797          	auipc	a5,0x8
    80001ad6:	11278793          	addi	a5,a5,274 # 80009be4 <nextpid>
    80001ada:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001adc:	0014871b          	addiw	a4,s1,1
    80001ae0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ae2:	854a                	mv	a0,s2
    80001ae4:	fffff097          	auipc	ra,0xfffff
    80001ae8:	1a0080e7          	jalr	416(ra) # 80000c84 <release>
}
    80001aec:	8526                	mv	a0,s1
    80001aee:	60e2                	ld	ra,24(sp)
    80001af0:	6442                	ld	s0,16(sp)
    80001af2:	64a2                	ld	s1,8(sp)
    80001af4:	6902                	ld	s2,0(sp)
    80001af6:	6105                	addi	sp,sp,32
    80001af8:	8082                	ret

0000000080001afa <proc_pagetable>:
{
    80001afa:	1101                	addi	sp,sp,-32
    80001afc:	ec06                	sd	ra,24(sp)
    80001afe:	e822                	sd	s0,16(sp)
    80001b00:	e426                	sd	s1,8(sp)
    80001b02:	e04a                	sd	s2,0(sp)
    80001b04:	1000                	addi	s0,sp,32
    80001b06:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b08:	00000097          	auipc	ra,0x0
    80001b0c:	866080e7          	jalr	-1946(ra) # 8000136e <uvmcreate>
    80001b10:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b12:	c121                	beqz	a0,80001b52 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b14:	4729                	li	a4,10
    80001b16:	00006697          	auipc	a3,0x6
    80001b1a:	4ea68693          	addi	a3,a3,1258 # 80008000 <_trampoline>
    80001b1e:	6605                	lui	a2,0x1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	5bc080e7          	jalr	1468(ra) # 800010e4 <mappages>
    80001b30:	02054863          	bltz	a0,80001b60 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b34:	4719                	li	a4,6
    80001b36:	06093683          	ld	a3,96(s2)
    80001b3a:	6605                	lui	a2,0x1
    80001b3c:	020005b7          	lui	a1,0x2000
    80001b40:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b42:	05b6                	slli	a1,a1,0xd
    80001b44:	8526                	mv	a0,s1
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	59e080e7          	jalr	1438(ra) # 800010e4 <mappages>
    80001b4e:	02054163          	bltz	a0,80001b70 <proc_pagetable+0x76>
}
    80001b52:	8526                	mv	a0,s1
    80001b54:	60e2                	ld	ra,24(sp)
    80001b56:	6442                	ld	s0,16(sp)
    80001b58:	64a2                	ld	s1,8(sp)
    80001b5a:	6902                	ld	s2,0(sp)
    80001b5c:	6105                	addi	sp,sp,32
    80001b5e:	8082                	ret
    uvmfree(pagetable, 0);
    80001b60:	4581                	li	a1,0
    80001b62:	8526                	mv	a0,s1
    80001b64:	00000097          	auipc	ra,0x0
    80001b68:	a08080e7          	jalr	-1528(ra) # 8000156c <uvmfree>
    return 0;
    80001b6c:	4481                	li	s1,0
    80001b6e:	b7d5                	j	80001b52 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b70:	4681                	li	a3,0
    80001b72:	4605                	li	a2,1
    80001b74:	040005b7          	lui	a1,0x4000
    80001b78:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b7a:	05b2                	slli	a1,a1,0xc
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	fffff097          	auipc	ra,0xfffff
    80001b82:	72c080e7          	jalr	1836(ra) # 800012aa <uvmunmap>
    uvmfree(pagetable, 0);
    80001b86:	4581                	li	a1,0
    80001b88:	8526                	mv	a0,s1
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	9e2080e7          	jalr	-1566(ra) # 8000156c <uvmfree>
    return 0;
    80001b92:	4481                	li	s1,0
    80001b94:	bf7d                	j	80001b52 <proc_pagetable+0x58>

0000000080001b96 <proc_freepagetable>:
{
    80001b96:	1101                	addi	sp,sp,-32
    80001b98:	ec06                	sd	ra,24(sp)
    80001b9a:	e822                	sd	s0,16(sp)
    80001b9c:	e426                	sd	s1,8(sp)
    80001b9e:	e04a                	sd	s2,0(sp)
    80001ba0:	1000                	addi	s0,sp,32
    80001ba2:	84aa                	mv	s1,a0
    80001ba4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ba6:	4681                	li	a3,0
    80001ba8:	4605                	li	a2,1
    80001baa:	040005b7          	lui	a1,0x4000
    80001bae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bb0:	05b2                	slli	a1,a1,0xc
    80001bb2:	fffff097          	auipc	ra,0xfffff
    80001bb6:	6f8080e7          	jalr	1784(ra) # 800012aa <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	020005b7          	lui	a1,0x2000
    80001bc2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bc4:	05b6                	slli	a1,a1,0xd
    80001bc6:	8526                	mv	a0,s1
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	6e2080e7          	jalr	1762(ra) # 800012aa <uvmunmap>
  uvmfree(pagetable, sz);
    80001bd0:	85ca                	mv	a1,s2
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	998080e7          	jalr	-1640(ra) # 8000156c <uvmfree>
}
    80001bdc:	60e2                	ld	ra,24(sp)
    80001bde:	6442                	ld	s0,16(sp)
    80001be0:	64a2                	ld	s1,8(sp)
    80001be2:	6902                	ld	s2,0(sp)
    80001be4:	6105                	addi	sp,sp,32
    80001be6:	8082                	ret

0000000080001be8 <freeproc>:
{
    80001be8:	1101                	addi	sp,sp,-32
    80001bea:	ec06                	sd	ra,24(sp)
    80001bec:	e822                	sd	s0,16(sp)
    80001bee:	e426                	sd	s1,8(sp)
    80001bf0:	1000                	addi	s0,sp,32
    80001bf2:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bf4:	7128                	ld	a0,96(a0)
    80001bf6:	c509                	beqz	a0,80001c00 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bf8:	fffff097          	auipc	ra,0xfffff
    80001bfc:	dea080e7          	jalr	-534(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001c00:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001c04:	6ca8                	ld	a0,88(s1)
    80001c06:	c511                	beqz	a0,80001c12 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c08:	68ac                	ld	a1,80(s1)
    80001c0a:	00000097          	auipc	ra,0x0
    80001c0e:	f8c080e7          	jalr	-116(ra) # 80001b96 <proc_freepagetable>
  p->pagetable = 0;
    80001c12:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001c16:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001c1a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c1e:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001c22:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001c26:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c2a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c2e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c32:	0004ac23          	sw	zero,24(s1)
}
    80001c36:	60e2                	ld	ra,24(sp)
    80001c38:	6442                	ld	s0,16(sp)
    80001c3a:	64a2                	ld	s1,8(sp)
    80001c3c:	6105                	addi	sp,sp,32
    80001c3e:	8082                	ret

0000000080001c40 <allocproc>:
{
    80001c40:	1101                	addi	sp,sp,-32
    80001c42:	ec06                	sd	ra,24(sp)
    80001c44:	e822                	sd	s0,16(sp)
    80001c46:	e426                	sd	s1,8(sp)
    80001c48:	e04a                	sd	s2,0(sp)
    80001c4a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c4c:	00011497          	auipc	s1,0x11
    80001c50:	adc48493          	addi	s1,s1,-1316 # 80012728 <proc>
    80001c54:	00017917          	auipc	s2,0x17
    80001c58:	ed490913          	addi	s2,s2,-300 # 80018b28 <tickslock>
    acquire(&p->lock);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	fffff097          	auipc	ra,0xfffff
    80001c62:	f72080e7          	jalr	-142(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    80001c66:	4c9c                	lw	a5,24(s1)
    80001c68:	cf81                	beqz	a5,80001c80 <allocproc+0x40>
      release(&p->lock);
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	018080e7          	jalr	24(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c74:	19048493          	addi	s1,s1,400
    80001c78:	ff2492e3          	bne	s1,s2,80001c5c <allocproc+0x1c>
  return 0;
    80001c7c:	4481                	li	s1,0
    80001c7e:	a841                	j	80001d0e <allocproc+0xce>
  p->pid = allocpid();
    80001c80:	00000097          	auipc	ra,0x0
    80001c84:	e34080e7          	jalr	-460(ra) # 80001ab4 <allocpid>
    80001c88:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c8a:	4785                	li	a5,1
    80001c8c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	e52080e7          	jalr	-430(ra) # 80000ae0 <kalloc>
    80001c96:	892a                	mv	s2,a0
    80001c98:	f0a8                	sd	a0,96(s1)
    80001c9a:	c149                	beqz	a0,80001d1c <allocproc+0xdc>
  p->pagetable = proc_pagetable(p);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	e5c080e7          	jalr	-420(ra) # 80001afa <proc_pagetable>
    80001ca6:	892a                	mv	s2,a0
    80001ca8:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001caa:	c549                	beqz	a0,80001d34 <allocproc+0xf4>
  memset(&p->context, 0, sizeof(p->context));
    80001cac:	07000613          	li	a2,112
    80001cb0:	4581                	li	a1,0
    80001cb2:	06848513          	addi	a0,s1,104
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	016080e7          	jalr	22(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001cbe:	00000797          	auipc	a5,0x0
    80001cc2:	d7878793          	addi	a5,a5,-648 # 80001a36 <forkret>
    80001cc6:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cc8:	64bc                	ld	a5,72(s1)
    80001cca:	6705                	lui	a4,0x1
    80001ccc:	97ba                	add	a5,a5,a4
    80001cce:	f8bc                	sd	a5,112(s1)
  acquire(&tickslock);
    80001cd0:	00017517          	auipc	a0,0x17
    80001cd4:	e5850513          	addi	a0,a0,-424 # 80018b28 <tickslock>
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	ef8080e7          	jalr	-264(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80001ce0:	00008917          	auipc	s2,0x8
    80001ce4:	38c92903          	lw	s2,908(s2) # 8000a06c <ticks>
  release(&tickslock);
    80001ce8:	00017517          	auipc	a0,0x17
    80001cec:	e4050513          	addi	a0,a0,-448 # 80018b28 <tickslock>
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	f94080e7          	jalr	-108(ra) # 80000c84 <release>
  p->ctime = xticks;
    80001cf8:	1724a823          	sw	s2,368(s1)
  p->stime = -1;
    80001cfc:	57fd                	li	a5,-1
    80001cfe:	16f4aa23          	sw	a5,372(s1)
  p->endtime = -1;
    80001d02:	16f4ac23          	sw	a5,376(s1)
  p->is_batchproc = 0;
    80001d06:	0204ae23          	sw	zero,60(s1)
  p->cpu_usage = 0;
    80001d0a:	1804a623          	sw	zero,396(s1)
}
    80001d0e:	8526                	mv	a0,s1
    80001d10:	60e2                	ld	ra,24(sp)
    80001d12:	6442                	ld	s0,16(sp)
    80001d14:	64a2                	ld	s1,8(sp)
    80001d16:	6902                	ld	s2,0(sp)
    80001d18:	6105                	addi	sp,sp,32
    80001d1a:	8082                	ret
    freeproc(p);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	00000097          	auipc	ra,0x0
    80001d22:	eca080e7          	jalr	-310(ra) # 80001be8 <freeproc>
    release(&p->lock);
    80001d26:	8526                	mv	a0,s1
    80001d28:	fffff097          	auipc	ra,0xfffff
    80001d2c:	f5c080e7          	jalr	-164(ra) # 80000c84 <release>
    return 0;
    80001d30:	84ca                	mv	s1,s2
    80001d32:	bff1                	j	80001d0e <allocproc+0xce>
    freeproc(p);
    80001d34:	8526                	mv	a0,s1
    80001d36:	00000097          	auipc	ra,0x0
    80001d3a:	eb2080e7          	jalr	-334(ra) # 80001be8 <freeproc>
    release(&p->lock);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	f44080e7          	jalr	-188(ra) # 80000c84 <release>
    return 0;
    80001d48:	84ca                	mv	s1,s2
    80001d4a:	b7d1                	j	80001d0e <allocproc+0xce>

0000000080001d4c <userinit>:
{
    80001d4c:	1101                	addi	sp,sp,-32
    80001d4e:	ec06                	sd	ra,24(sp)
    80001d50:	e822                	sd	s0,16(sp)
    80001d52:	e426                	sd	s1,8(sp)
    80001d54:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d56:	00000097          	auipc	ra,0x0
    80001d5a:	eea080e7          	jalr	-278(ra) # 80001c40 <allocproc>
    80001d5e:	84aa                	mv	s1,a0
  initproc = p;
    80001d60:	00008797          	auipc	a5,0x8
    80001d64:	30a7b023          	sd	a0,768(a5) # 8000a060 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d68:	03400613          	li	a2,52
    80001d6c:	00008597          	auipc	a1,0x8
    80001d70:	e8458593          	addi	a1,a1,-380 # 80009bf0 <initcode>
    80001d74:	6d28                	ld	a0,88(a0)
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	626080e7          	jalr	1574(ra) # 8000139c <uvminit>
  p->sz = PGSIZE;
    80001d7e:	6785                	lui	a5,0x1
    80001d80:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d82:	70b8                	ld	a4,96(s1)
    80001d84:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d88:	70b8                	ld	a4,96(s1)
    80001d8a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d8c:	4641                	li	a2,16
    80001d8e:	00007597          	auipc	a1,0x7
    80001d92:	49258593          	addi	a1,a1,1170 # 80009220 <digits+0x1e0>
    80001d96:	16048513          	addi	a0,s1,352
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	07c080e7          	jalr	124(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001da2:	00007517          	auipc	a0,0x7
    80001da6:	48e50513          	addi	a0,a0,1166 # 80009230 <digits+0x1f0>
    80001daa:	00004097          	auipc	ra,0x4
    80001dae:	c0c080e7          	jalr	-1012(ra) # 800059b6 <namei>
    80001db2:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001db6:	478d                	li	a5,3
    80001db8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dba:	8526                	mv	a0,s1
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	ec8080e7          	jalr	-312(ra) # 80000c84 <release>
}
    80001dc4:	60e2                	ld	ra,24(sp)
    80001dc6:	6442                	ld	s0,16(sp)
    80001dc8:	64a2                	ld	s1,8(sp)
    80001dca:	6105                	addi	sp,sp,32
    80001dcc:	8082                	ret

0000000080001dce <growproc>:
{
    80001dce:	1101                	addi	sp,sp,-32
    80001dd0:	ec06                	sd	ra,24(sp)
    80001dd2:	e822                	sd	s0,16(sp)
    80001dd4:	e426                	sd	s1,8(sp)
    80001dd6:	e04a                	sd	s2,0(sp)
    80001dd8:	1000                	addi	s0,sp,32
    80001dda:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ddc:	00000097          	auipc	ra,0x0
    80001de0:	c22080e7          	jalr	-990(ra) # 800019fe <myproc>
    80001de4:	892a                	mv	s2,a0
  sz = p->sz;
    80001de6:	692c                	ld	a1,80(a0)
    80001de8:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001dec:	00904f63          	bgtz	s1,80001e0a <growproc+0x3c>
  } else if(n < 0){
    80001df0:	0204cd63          	bltz	s1,80001e2a <growproc+0x5c>
  p->sz = sz;
    80001df4:	1782                	slli	a5,a5,0x20
    80001df6:	9381                	srli	a5,a5,0x20
    80001df8:	04f93823          	sd	a5,80(s2)
  return 0;
    80001dfc:	4501                	li	a0,0
}
    80001dfe:	60e2                	ld	ra,24(sp)
    80001e00:	6442                	ld	s0,16(sp)
    80001e02:	64a2                	ld	s1,8(sp)
    80001e04:	6902                	ld	s2,0(sp)
    80001e06:	6105                	addi	sp,sp,32
    80001e08:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e0a:	00f4863b          	addw	a2,s1,a5
    80001e0e:	1602                	slli	a2,a2,0x20
    80001e10:	9201                	srli	a2,a2,0x20
    80001e12:	1582                	slli	a1,a1,0x20
    80001e14:	9181                	srli	a1,a1,0x20
    80001e16:	6d28                	ld	a0,88(a0)
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	63e080e7          	jalr	1598(ra) # 80001456 <uvmalloc>
    80001e20:	0005079b          	sext.w	a5,a0
    80001e24:	fbe1                	bnez	a5,80001df4 <growproc+0x26>
      return -1;
    80001e26:	557d                	li	a0,-1
    80001e28:	bfd9                	j	80001dfe <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e2a:	00f4863b          	addw	a2,s1,a5
    80001e2e:	1602                	slli	a2,a2,0x20
    80001e30:	9201                	srli	a2,a2,0x20
    80001e32:	1582                	slli	a1,a1,0x20
    80001e34:	9181                	srli	a1,a1,0x20
    80001e36:	6d28                	ld	a0,88(a0)
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	5d6080e7          	jalr	1494(ra) # 8000140e <uvmdealloc>
    80001e40:	0005079b          	sext.w	a5,a0
    80001e44:	bf45                	j	80001df4 <growproc+0x26>

0000000080001e46 <fork>:
{
    80001e46:	7139                	addi	sp,sp,-64
    80001e48:	fc06                	sd	ra,56(sp)
    80001e4a:	f822                	sd	s0,48(sp)
    80001e4c:	f426                	sd	s1,40(sp)
    80001e4e:	f04a                	sd	s2,32(sp)
    80001e50:	ec4e                	sd	s3,24(sp)
    80001e52:	e852                	sd	s4,16(sp)
    80001e54:	e456                	sd	s5,8(sp)
    80001e56:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	ba6080e7          	jalr	-1114(ra) # 800019fe <myproc>
    80001e60:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e62:	00000097          	auipc	ra,0x0
    80001e66:	dde080e7          	jalr	-546(ra) # 80001c40 <allocproc>
    80001e6a:	10050c63          	beqz	a0,80001f82 <fork+0x13c>
    80001e6e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e70:	050ab603          	ld	a2,80(s5)
    80001e74:	6d2c                	ld	a1,88(a0)
    80001e76:	058ab503          	ld	a0,88(s5)
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	72c080e7          	jalr	1836(ra) # 800015a6 <uvmcopy>
    80001e82:	04054863          	bltz	a0,80001ed2 <fork+0x8c>
  np->sz = p->sz;
    80001e86:	050ab783          	ld	a5,80(s5)
    80001e8a:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e8e:	060ab683          	ld	a3,96(s5)
    80001e92:	87b6                	mv	a5,a3
    80001e94:	060a3703          	ld	a4,96(s4)
    80001e98:	12068693          	addi	a3,a3,288
    80001e9c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ea0:	6788                	ld	a0,8(a5)
    80001ea2:	6b8c                	ld	a1,16(a5)
    80001ea4:	6f90                	ld	a2,24(a5)
    80001ea6:	01073023          	sd	a6,0(a4)
    80001eaa:	e708                	sd	a0,8(a4)
    80001eac:	eb0c                	sd	a1,16(a4)
    80001eae:	ef10                	sd	a2,24(a4)
    80001eb0:	02078793          	addi	a5,a5,32
    80001eb4:	02070713          	addi	a4,a4,32
    80001eb8:	fed792e3          	bne	a5,a3,80001e9c <fork+0x56>
  np->trapframe->a0 = 0;
    80001ebc:	060a3783          	ld	a5,96(s4)
    80001ec0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ec4:	0d8a8493          	addi	s1,s5,216
    80001ec8:	0d8a0913          	addi	s2,s4,216
    80001ecc:	158a8993          	addi	s3,s5,344
    80001ed0:	a00d                	j	80001ef2 <fork+0xac>
    freeproc(np);
    80001ed2:	8552                	mv	a0,s4
    80001ed4:	00000097          	auipc	ra,0x0
    80001ed8:	d14080e7          	jalr	-748(ra) # 80001be8 <freeproc>
    release(&np->lock);
    80001edc:	8552                	mv	a0,s4
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	da6080e7          	jalr	-602(ra) # 80000c84 <release>
    return -1;
    80001ee6:	597d                	li	s2,-1
    80001ee8:	a059                	j	80001f6e <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001eea:	04a1                	addi	s1,s1,8
    80001eec:	0921                	addi	s2,s2,8
    80001eee:	01348b63          	beq	s1,s3,80001f04 <fork+0xbe>
    if(p->ofile[i])
    80001ef2:	6088                	ld	a0,0(s1)
    80001ef4:	d97d                	beqz	a0,80001eea <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ef6:	00004097          	auipc	ra,0x4
    80001efa:	156080e7          	jalr	342(ra) # 8000604c <filedup>
    80001efe:	00a93023          	sd	a0,0(s2)
    80001f02:	b7e5                	j	80001eea <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001f04:	158ab503          	ld	a0,344(s5)
    80001f08:	00003097          	auipc	ra,0x3
    80001f0c:	2b4080e7          	jalr	692(ra) # 800051bc <idup>
    80001f10:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f14:	4641                	li	a2,16
    80001f16:	160a8593          	addi	a1,s5,352
    80001f1a:	160a0513          	addi	a0,s4,352
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	ef8080e7          	jalr	-264(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001f26:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f2a:	8552                	mv	a0,s4
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	d58080e7          	jalr	-680(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001f34:	00010497          	auipc	s1,0x10
    80001f38:	3c448493          	addi	s1,s1,964 # 800122f8 <wait_lock>
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	c92080e7          	jalr	-878(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001f46:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	d38080e7          	jalr	-712(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001f54:	8552                	mv	a0,s4
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	c7a080e7          	jalr	-902(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    80001f5e:	478d                	li	a5,3
    80001f60:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f64:	8552                	mv	a0,s4
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d1e080e7          	jalr	-738(ra) # 80000c84 <release>
}
    80001f6e:	854a                	mv	a0,s2
    80001f70:	70e2                	ld	ra,56(sp)
    80001f72:	7442                	ld	s0,48(sp)
    80001f74:	74a2                	ld	s1,40(sp)
    80001f76:	7902                	ld	s2,32(sp)
    80001f78:	69e2                	ld	s3,24(sp)
    80001f7a:	6a42                	ld	s4,16(sp)
    80001f7c:	6aa2                	ld	s5,8(sp)
    80001f7e:	6121                	addi	sp,sp,64
    80001f80:	8082                	ret
    return -1;
    80001f82:	597d                	li	s2,-1
    80001f84:	b7ed                	j	80001f6e <fork+0x128>

0000000080001f86 <forkf>:
{
    80001f86:	7139                	addi	sp,sp,-64
    80001f88:	fc06                	sd	ra,56(sp)
    80001f8a:	f822                	sd	s0,48(sp)
    80001f8c:	f426                	sd	s1,40(sp)
    80001f8e:	f04a                	sd	s2,32(sp)
    80001f90:	ec4e                	sd	s3,24(sp)
    80001f92:	e852                	sd	s4,16(sp)
    80001f94:	e456                	sd	s5,8(sp)
    80001f96:	0080                	addi	s0,sp,64
    80001f98:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f9a:	00000097          	auipc	ra,0x0
    80001f9e:	a64080e7          	jalr	-1436(ra) # 800019fe <myproc>
    80001fa2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001fa4:	00000097          	auipc	ra,0x0
    80001fa8:	c9c080e7          	jalr	-868(ra) # 80001c40 <allocproc>
    80001fac:	12050163          	beqz	a0,800020ce <forkf+0x148>
    80001fb0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001fb2:	050ab603          	ld	a2,80(s5)
    80001fb6:	6d2c                	ld	a1,88(a0)
    80001fb8:	058ab503          	ld	a0,88(s5)
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	5ea080e7          	jalr	1514(ra) # 800015a6 <uvmcopy>
    80001fc4:	04054d63          	bltz	a0,8000201e <forkf+0x98>
  np->sz = p->sz;
    80001fc8:	050ab783          	ld	a5,80(s5)
    80001fcc:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001fd0:	060ab683          	ld	a3,96(s5)
    80001fd4:	87b6                	mv	a5,a3
    80001fd6:	0609b703          	ld	a4,96(s3)
    80001fda:	12068693          	addi	a3,a3,288
    80001fde:	0007b883          	ld	a7,0(a5)
    80001fe2:	0087b803          	ld	a6,8(a5)
    80001fe6:	6b8c                	ld	a1,16(a5)
    80001fe8:	6f90                	ld	a2,24(a5)
    80001fea:	01173023          	sd	a7,0(a4)
    80001fee:	01073423          	sd	a6,8(a4)
    80001ff2:	eb0c                	sd	a1,16(a4)
    80001ff4:	ef10                	sd	a2,24(a4)
    80001ff6:	02078793          	addi	a5,a5,32
    80001ffa:	02070713          	addi	a4,a4,32
    80001ffe:	fed790e3          	bne	a5,a3,80001fde <forkf+0x58>
  np->trapframe->a0 = 0;
    80002002:	0609b783          	ld	a5,96(s3)
    80002006:	0607b823          	sd	zero,112(a5)
  np->trapframe->epc = faddr;
    8000200a:	0609b783          	ld	a5,96(s3)
    8000200e:	ef84                	sd	s1,24(a5)
  for(i = 0; i < NOFILE; i++)
    80002010:	0d8a8493          	addi	s1,s5,216
    80002014:	0d898913          	addi	s2,s3,216
    80002018:	158a8a13          	addi	s4,s5,344
    8000201c:	a00d                	j	8000203e <forkf+0xb8>
    freeproc(np);
    8000201e:	854e                	mv	a0,s3
    80002020:	00000097          	auipc	ra,0x0
    80002024:	bc8080e7          	jalr	-1080(ra) # 80001be8 <freeproc>
    release(&np->lock);
    80002028:	854e                	mv	a0,s3
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	c5a080e7          	jalr	-934(ra) # 80000c84 <release>
    return -1;
    80002032:	597d                	li	s2,-1
    80002034:	a059                	j	800020ba <forkf+0x134>
  for(i = 0; i < NOFILE; i++)
    80002036:	04a1                	addi	s1,s1,8
    80002038:	0921                	addi	s2,s2,8
    8000203a:	01448b63          	beq	s1,s4,80002050 <forkf+0xca>
    if(p->ofile[i])
    8000203e:	6088                	ld	a0,0(s1)
    80002040:	d97d                	beqz	a0,80002036 <forkf+0xb0>
      np->ofile[i] = filedup(p->ofile[i]);
    80002042:	00004097          	auipc	ra,0x4
    80002046:	00a080e7          	jalr	10(ra) # 8000604c <filedup>
    8000204a:	00a93023          	sd	a0,0(s2)
    8000204e:	b7e5                	j	80002036 <forkf+0xb0>
  np->cwd = idup(p->cwd);
    80002050:	158ab503          	ld	a0,344(s5)
    80002054:	00003097          	auipc	ra,0x3
    80002058:	168080e7          	jalr	360(ra) # 800051bc <idup>
    8000205c:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002060:	4641                	li	a2,16
    80002062:	160a8593          	addi	a1,s5,352
    80002066:	16098513          	addi	a0,s3,352
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	dac080e7          	jalr	-596(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80002072:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002076:	854e                	mv	a0,s3
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	c0c080e7          	jalr	-1012(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80002080:	00010497          	auipc	s1,0x10
    80002084:	27848493          	addi	s1,s1,632 # 800122f8 <wait_lock>
    80002088:	8526                	mv	a0,s1
    8000208a:	fffff097          	auipc	ra,0xfffff
    8000208e:	b46080e7          	jalr	-1210(ra) # 80000bd0 <acquire>
  np->parent = p;
    80002092:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bec080e7          	jalr	-1044(ra) # 80000c84 <release>
  acquire(&np->lock);
    800020a0:	854e                	mv	a0,s3
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	b2e080e7          	jalr	-1234(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    800020aa:	478d                	li	a5,3
    800020ac:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800020b0:	854e                	mv	a0,s3
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	bd2080e7          	jalr	-1070(ra) # 80000c84 <release>
}
    800020ba:	854a                	mv	a0,s2
    800020bc:	70e2                	ld	ra,56(sp)
    800020be:	7442                	ld	s0,48(sp)
    800020c0:	74a2                	ld	s1,40(sp)
    800020c2:	7902                	ld	s2,32(sp)
    800020c4:	69e2                	ld	s3,24(sp)
    800020c6:	6a42                	ld	s4,16(sp)
    800020c8:	6aa2                	ld	s5,8(sp)
    800020ca:	6121                	addi	sp,sp,64
    800020cc:	8082                	ret
    return -1;
    800020ce:	597d                	li	s2,-1
    800020d0:	b7ed                	j	800020ba <forkf+0x134>

00000000800020d2 <forkp>:
{
    800020d2:	7139                	addi	sp,sp,-64
    800020d4:	fc06                	sd	ra,56(sp)
    800020d6:	f822                	sd	s0,48(sp)
    800020d8:	f426                	sd	s1,40(sp)
    800020da:	f04a                	sd	s2,32(sp)
    800020dc:	ec4e                	sd	s3,24(sp)
    800020de:	e852                	sd	s4,16(sp)
    800020e0:	e456                	sd	s5,8(sp)
    800020e2:	e05a                	sd	s6,0(sp)
    800020e4:	0080                	addi	s0,sp,64
    800020e6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020e8:	00000097          	auipc	ra,0x0
    800020ec:	916080e7          	jalr	-1770(ra) # 800019fe <myproc>
    800020f0:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800020f2:	00000097          	auipc	ra,0x0
    800020f6:	b4e080e7          	jalr	-1202(ra) # 80001c40 <allocproc>
    800020fa:	14050863          	beqz	a0,8000224a <forkp+0x178>
    800020fe:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002100:	050ab603          	ld	a2,80(s5)
    80002104:	6d2c                	ld	a1,88(a0)
    80002106:	058ab503          	ld	a0,88(s5)
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	49c080e7          	jalr	1180(ra) # 800015a6 <uvmcopy>
    80002112:	04054863          	bltz	a0,80002162 <forkp+0x90>
  np->sz = p->sz;
    80002116:	050ab783          	ld	a5,80(s5)
    8000211a:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    8000211e:	060ab683          	ld	a3,96(s5)
    80002122:	87b6                	mv	a5,a3
    80002124:	0609b703          	ld	a4,96(s3)
    80002128:	12068693          	addi	a3,a3,288
    8000212c:	0007b803          	ld	a6,0(a5)
    80002130:	6788                	ld	a0,8(a5)
    80002132:	6b8c                	ld	a1,16(a5)
    80002134:	6f90                	ld	a2,24(a5)
    80002136:	01073023          	sd	a6,0(a4)
    8000213a:	e708                	sd	a0,8(a4)
    8000213c:	eb0c                	sd	a1,16(a4)
    8000213e:	ef10                	sd	a2,24(a4)
    80002140:	02078793          	addi	a5,a5,32
    80002144:	02070713          	addi	a4,a4,32
    80002148:	fed792e3          	bne	a5,a3,8000212c <forkp+0x5a>
  np->trapframe->a0 = 0;
    8000214c:	0609b783          	ld	a5,96(s3)
    80002150:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002154:	0d8a8493          	addi	s1,s5,216
    80002158:	0d898913          	addi	s2,s3,216
    8000215c:	158a8a13          	addi	s4,s5,344
    80002160:	a00d                	j	80002182 <forkp+0xb0>
    freeproc(np);
    80002162:	854e                	mv	a0,s3
    80002164:	00000097          	auipc	ra,0x0
    80002168:	a84080e7          	jalr	-1404(ra) # 80001be8 <freeproc>
    release(&np->lock);
    8000216c:	854e                	mv	a0,s3
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	b16080e7          	jalr	-1258(ra) # 80000c84 <release>
    return -1;
    80002176:	597d                	li	s2,-1
    80002178:	a875                	j	80002234 <forkp+0x162>
  for(i = 0; i < NOFILE; i++)
    8000217a:	04a1                	addi	s1,s1,8
    8000217c:	0921                	addi	s2,s2,8
    8000217e:	01448b63          	beq	s1,s4,80002194 <forkp+0xc2>
    if(p->ofile[i])
    80002182:	6088                	ld	a0,0(s1)
    80002184:	d97d                	beqz	a0,8000217a <forkp+0xa8>
      np->ofile[i] = filedup(p->ofile[i]);
    80002186:	00004097          	auipc	ra,0x4
    8000218a:	ec6080e7          	jalr	-314(ra) # 8000604c <filedup>
    8000218e:	00a93023          	sd	a0,0(s2)
    80002192:	b7e5                	j	8000217a <forkp+0xa8>
  np->cwd = idup(p->cwd);
    80002194:	158ab503          	ld	a0,344(s5)
    80002198:	00003097          	auipc	ra,0x3
    8000219c:	024080e7          	jalr	36(ra) # 800051bc <idup>
    800021a0:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800021a4:	4641                	li	a2,16
    800021a6:	160a8593          	addi	a1,s5,352
    800021aa:	16098513          	addi	a0,s3,352
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	c68080e7          	jalr	-920(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    800021b6:	0309a903          	lw	s2,48(s3)
  np->base_priority = priority;
    800021ba:	0369aa23          	sw	s6,52(s3)
  np->is_batchproc = 1;
    800021be:	4785                	li	a5,1
    800021c0:	02f9ae23          	sw	a5,60(s3)
  np->nextburst_estimate = 0;
    800021c4:	1809a423          	sw	zero,392(s3)
  np->waittime = 0;
    800021c8:	1609ae23          	sw	zero,380(s3)
  release(&np->lock);
    800021cc:	854e                	mv	a0,s3
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	ab6080e7          	jalr	-1354(ra) # 80000c84 <release>
  batchsize++;
    800021d6:	00008717          	auipc	a4,0x8
    800021da:	e8670713          	addi	a4,a4,-378 # 8000a05c <batchsize>
    800021de:	431c                	lw	a5,0(a4)
    800021e0:	2785                	addiw	a5,a5,1
    800021e2:	c31c                	sw	a5,0(a4)
  batchsize2++;
    800021e4:	00008717          	auipc	a4,0x8
    800021e8:	e7470713          	addi	a4,a4,-396 # 8000a058 <batchsize2>
    800021ec:	431c                	lw	a5,0(a4)
    800021ee:	2785                	addiw	a5,a5,1
    800021f0:	c31c                	sw	a5,0(a4)
  acquire(&wait_lock);
    800021f2:	00010497          	auipc	s1,0x10
    800021f6:	10648493          	addi	s1,s1,262 # 800122f8 <wait_lock>
    800021fa:	8526                	mv	a0,s1
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	9d4080e7          	jalr	-1580(ra) # 80000bd0 <acquire>
  np->parent = p;
    80002204:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    80002208:	8526                	mv	a0,s1
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	a7a080e7          	jalr	-1414(ra) # 80000c84 <release>
  acquire(&np->lock);
    80002212:	854e                	mv	a0,s3
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	9bc080e7          	jalr	-1604(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    8000221c:	478d                	li	a5,3
    8000221e:	00f9ac23          	sw	a5,24(s3)
  np->waitstart = np->ctime;
    80002222:	1709a783          	lw	a5,368(s3)
    80002226:	18f9a023          	sw	a5,384(s3)
  release(&np->lock);
    8000222a:	854e                	mv	a0,s3
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	a58080e7          	jalr	-1448(ra) # 80000c84 <release>
}
    80002234:	854a                	mv	a0,s2
    80002236:	70e2                	ld	ra,56(sp)
    80002238:	7442                	ld	s0,48(sp)
    8000223a:	74a2                	ld	s1,40(sp)
    8000223c:	7902                	ld	s2,32(sp)
    8000223e:	69e2                	ld	s3,24(sp)
    80002240:	6a42                	ld	s4,16(sp)
    80002242:	6aa2                	ld	s5,8(sp)
    80002244:	6b02                	ld	s6,0(sp)
    80002246:	6121                	addi	sp,sp,64
    80002248:	8082                	ret
    return -1;
    8000224a:	597d                	li	s2,-1
    8000224c:	b7e5                	j	80002234 <forkp+0x162>

000000008000224e <scheduler>:
{
    8000224e:	711d                	addi	sp,sp,-96
    80002250:	ec86                	sd	ra,88(sp)
    80002252:	e8a2                	sd	s0,80(sp)
    80002254:	e4a6                	sd	s1,72(sp)
    80002256:	e0ca                	sd	s2,64(sp)
    80002258:	fc4e                	sd	s3,56(sp)
    8000225a:	f852                	sd	s4,48(sp)
    8000225c:	f456                	sd	s5,40(sp)
    8000225e:	f05a                	sd	s6,32(sp)
    80002260:	ec5e                	sd	s7,24(sp)
    80002262:	e862                	sd	s8,16(sp)
    80002264:	e466                	sd	s9,8(sp)
    80002266:	e06a                	sd	s10,0(sp)
    80002268:	1080                	addi	s0,sp,96
    8000226a:	8792                	mv	a5,tp
  int id = r_tp();
    8000226c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000226e:	00779a93          	slli	s5,a5,0x7
    80002272:	00010717          	auipc	a4,0x10
    80002276:	06e70713          	addi	a4,a4,110 # 800122e0 <pid_lock>
    8000227a:	9756                	add	a4,a4,s5
    8000227c:	04073423          	sd	zero,72(a4)
            swtch(&c->context, &p->context);
    80002280:	00010717          	auipc	a4,0x10
    80002284:	0b070713          	addi	a4,a4,176 # 80012330 <cpus+0x8>
    80002288:	9aba                	add	s5,s5,a4
          xticks = ticks;
    8000228a:	00008997          	auipc	s3,0x8
    8000228e:	de298993          	addi	s3,s3,-542 # 8000a06c <ticks>
            c->proc = p;
    80002292:	079e                	slli	a5,a5,0x7
    80002294:	00010a17          	auipc	s4,0x10
    80002298:	04ca0a13          	addi	s4,s4,76 # 800122e0 <pid_lock>
    8000229c:	9a3e                	add	s4,s4,a5
       for(p = proc; p < &proc[NPROC]; p++) {
    8000229e:	00017917          	auipc	s2,0x17
    800022a2:	88a90913          	addi	s2,s2,-1910 # 80018b28 <tickslock>
    800022a6:	aca9                	j	80002500 <scheduler+0x2b2>
       acquire(&tickslock);
    800022a8:	00017517          	auipc	a0,0x17
    800022ac:	88050513          	addi	a0,a0,-1920 # 80018b28 <tickslock>
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	920080e7          	jalr	-1760(ra) # 80000bd0 <acquire>
       xticks = ticks;
    800022b8:	0009ad03          	lw	s10,0(s3)
       release(&tickslock);
    800022bc:	00017517          	auipc	a0,0x17
    800022c0:	86c50513          	addi	a0,a0,-1940 # 80018b28 <tickslock>
    800022c4:	fffff097          	auipc	ra,0xfffff
    800022c8:	9c0080e7          	jalr	-1600(ra) # 80000c84 <release>
       min_burst = 0x7FFFFFFF;
    800022cc:	80000c37          	lui	s8,0x80000
    800022d0:	fffc4c13          	not	s8,s8
       q = 0;
    800022d4:	4c81                	li	s9,0
       for(p = proc; p < &proc[NPROC]; p++) {
    800022d6:	00010497          	auipc	s1,0x10
    800022da:	45248493          	addi	s1,s1,1106 # 80012728 <proc>
	  if(p->state == RUNNABLE) {
    800022de:	4b8d                	li	s7,3
    800022e0:	a0ad                	j	8000234a <scheduler+0xfc>
                if (q) release(&q->lock);
    800022e2:	000c8763          	beqz	s9,800022f0 <scheduler+0xa2>
    800022e6:	8566                	mv	a0,s9
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	99c080e7          	jalr	-1636(ra) # 80000c84 <release>
          q->state = RUNNING;
    800022f0:	4791                	li	a5,4
    800022f2:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    800022f4:	17c4a783          	lw	a5,380(s1)
    800022f8:	01a787bb          	addw	a5,a5,s10
    800022fc:	1804a703          	lw	a4,384(s1)
    80002300:	9f99                	subw	a5,a5,a4
    80002302:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    80002306:	19a4a223          	sw	s10,388(s1)
          c->proc = q;
    8000230a:	049a3423          	sd	s1,72(s4)
          swtch(&c->context, &q->context);
    8000230e:	06848593          	addi	a1,s1,104
    80002312:	8556                	mv	a0,s5
    80002314:	00001097          	auipc	ra,0x1
    80002318:	5b2080e7          	jalr	1458(ra) # 800038c6 <swtch>
          c->proc = 0;
    8000231c:	040a3423          	sd	zero,72(s4)
	  release(&q->lock);
    80002320:	8526                	mv	a0,s1
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	962080e7          	jalr	-1694(ra) # 80000c84 <release>
    8000232a:	aad9                	j	80002500 <scheduler+0x2b2>
             else release(&p->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	956080e7          	jalr	-1706(ra) # 80000c84 <release>
    80002336:	a031                	j	80002342 <scheduler+0xf4>
	  else release(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	94a080e7          	jalr	-1718(ra) # 80000c84 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002342:	19048493          	addi	s1,s1,400
    80002346:	03248d63          	beq	s1,s2,80002380 <scheduler+0x132>
          acquire(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	884080e7          	jalr	-1916(ra) # 80000bd0 <acquire>
	  if(p->state == RUNNABLE) {
    80002354:	4c9c                	lw	a5,24(s1)
    80002356:	ff7791e3          	bne	a5,s7,80002338 <scheduler+0xea>
	     if (!p->is_batchproc) {
    8000235a:	5cdc                	lw	a5,60(s1)
    8000235c:	d3d9                	beqz	a5,800022e2 <scheduler+0x94>
             else if (p->nextburst_estimate < min_burst) {
    8000235e:	1884ab03          	lw	s6,392(s1)
    80002362:	fd8b55e3          	bge	s6,s8,8000232c <scheduler+0xde>
		if (q) release(&q->lock);
    80002366:	000c8a63          	beqz	s9,8000237a <scheduler+0x12c>
    8000236a:	8566                	mv	a0,s9
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	918080e7          	jalr	-1768(ra) # 80000c84 <release>
	        min_burst = p->nextburst_estimate;
    80002374:	8c5a                	mv	s8,s6
		if (q) release(&q->lock);
    80002376:	8ca6                	mv	s9,s1
    80002378:	b7e9                	j	80002342 <scheduler+0xf4>
	        min_burst = p->nextburst_estimate;
    8000237a:	8c5a                	mv	s8,s6
    8000237c:	8ca6                	mv	s9,s1
    8000237e:	b7d1                	j	80002342 <scheduler+0xf4>
       if (q) {
    80002380:	180c8063          	beqz	s9,80002500 <scheduler+0x2b2>
    80002384:	84e6                	mv	s1,s9
    80002386:	b7ad                	j	800022f0 <scheduler+0xa2>
       acquire(&tickslock);
    80002388:	00016517          	auipc	a0,0x16
    8000238c:	7a050513          	addi	a0,a0,1952 # 80018b28 <tickslock>
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	840080e7          	jalr	-1984(ra) # 80000bd0 <acquire>
       xticks = ticks;
    80002398:	0009ab83          	lw	s7,0(s3)
       release(&tickslock);
    8000239c:	00016517          	auipc	a0,0x16
    800023a0:	78c50513          	addi	a0,a0,1932 # 80018b28 <tickslock>
    800023a4:	fffff097          	auipc	ra,0xfffff
    800023a8:	8e0080e7          	jalr	-1824(ra) # 80000c84 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800023ac:	00010497          	auipc	s1,0x10
    800023b0:	37c48493          	addi	s1,s1,892 # 80012728 <proc>
	  if(p->state == RUNNABLE) {
    800023b4:	4b0d                	li	s6,3
    800023b6:	a811                	j	800023ca <scheduler+0x17c>
	  release(&p->lock);
    800023b8:	8526                	mv	a0,s1
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	8ca080e7          	jalr	-1846(ra) # 80000c84 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800023c2:	19048493          	addi	s1,s1,400
    800023c6:	03248e63          	beq	s1,s2,80002402 <scheduler+0x1b4>
          acquire(&p->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	804080e7          	jalr	-2044(ra) # 80000bd0 <acquire>
	  if(p->state == RUNNABLE) {
    800023d4:	4c9c                	lw	a5,24(s1)
    800023d6:	ff6791e3          	bne	a5,s6,800023b8 <scheduler+0x16a>
	     p->cpu_usage = p->cpu_usage/2;
    800023da:	18c4a703          	lw	a4,396(s1)
    800023de:	01f7579b          	srliw	a5,a4,0x1f
    800023e2:	9fb9                	addw	a5,a5,a4
    800023e4:	4017d79b          	sraiw	a5,a5,0x1
    800023e8:	18f4a623          	sw	a5,396(s1)
	     p->priority = p->base_priority + (p->cpu_usage/2);
    800023ec:	41f7579b          	sraiw	a5,a4,0x1f
    800023f0:	01e7d79b          	srliw	a5,a5,0x1e
    800023f4:	9fb9                	addw	a5,a5,a4
    800023f6:	4027d79b          	sraiw	a5,a5,0x2
    800023fa:	58d8                	lw	a4,52(s1)
    800023fc:	9fb9                	addw	a5,a5,a4
    800023fe:	dc9c                	sw	a5,56(s1)
    80002400:	bf65                	j	800023b8 <scheduler+0x16a>
       min_prio = 0x7FFFFFFF;
    80002402:	80000cb7          	lui	s9,0x80000
    80002406:	fffccc93          	not	s9,s9
       q = 0;
    8000240a:	4d01                	li	s10,0
       for(p = proc; p < &proc[NPROC]; p++) {
    8000240c:	00010497          	auipc	s1,0x10
    80002410:	31c48493          	addi	s1,s1,796 # 80012728 <proc>
          if(p->state == RUNNABLE) {
    80002414:	4c0d                	li	s8,3
    80002416:	a0ad                	j	80002480 <scheduler+0x232>
                if (q) release(&q->lock);
    80002418:	000d0763          	beqz	s10,80002426 <scheduler+0x1d8>
    8000241c:	856a                	mv	a0,s10
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	866080e7          	jalr	-1946(ra) # 80000c84 <release>
          q->state = RUNNING;
    80002426:	4791                	li	a5,4
    80002428:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    8000242a:	17c4a783          	lw	a5,380(s1)
    8000242e:	017787bb          	addw	a5,a5,s7
    80002432:	1804a703          	lw	a4,384(s1)
    80002436:	9f99                	subw	a5,a5,a4
    80002438:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    8000243c:	1974a223          	sw	s7,388(s1)
          c->proc = q;
    80002440:	049a3423          	sd	s1,72(s4)
          swtch(&c->context, &q->context);
    80002444:	06848593          	addi	a1,s1,104
    80002448:	8556                	mv	a0,s5
    8000244a:	00001097          	auipc	ra,0x1
    8000244e:	47c080e7          	jalr	1148(ra) # 800038c6 <swtch>
          c->proc = 0;
    80002452:	040a3423          	sd	zero,72(s4)
          release(&q->lock);
    80002456:	8526                	mv	a0,s1
    80002458:	fffff097          	auipc	ra,0xfffff
    8000245c:	82c080e7          	jalr	-2004(ra) # 80000c84 <release>
    80002460:	a045                	j	80002500 <scheduler+0x2b2>
             else release(&p->lock);
    80002462:	8526                	mv	a0,s1
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	820080e7          	jalr	-2016(ra) # 80000c84 <release>
    8000246c:	a031                	j	80002478 <scheduler+0x22a>
          else release(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	814080e7          	jalr	-2028(ra) # 80000c84 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002478:	19048493          	addi	s1,s1,400
    8000247c:	03248d63          	beq	s1,s2,800024b6 <scheduler+0x268>
          acquire(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	74e080e7          	jalr	1870(ra) # 80000bd0 <acquire>
          if(p->state == RUNNABLE) {
    8000248a:	4c9c                	lw	a5,24(s1)
    8000248c:	ff8791e3          	bne	a5,s8,8000246e <scheduler+0x220>
             if (!p->is_batchproc) {
    80002490:	5cdc                	lw	a5,60(s1)
    80002492:	d3d9                	beqz	a5,80002418 <scheduler+0x1ca>
             else if (p->priority < min_prio) {
    80002494:	0384ab03          	lw	s6,56(s1)
    80002498:	fd9b55e3          	bge	s6,s9,80002462 <scheduler+0x214>
                if (q) release(&q->lock);
    8000249c:	000d0a63          	beqz	s10,800024b0 <scheduler+0x262>
    800024a0:	856a                	mv	a0,s10
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	7e2080e7          	jalr	2018(ra) # 80000c84 <release>
                min_prio = p->priority;
    800024aa:	8cda                	mv	s9,s6
                if (q) release(&q->lock);
    800024ac:	8d26                	mv	s10,s1
    800024ae:	b7e9                	j	80002478 <scheduler+0x22a>
                min_prio = p->priority;
    800024b0:	8cda                	mv	s9,s6
    800024b2:	8d26                	mv	s10,s1
    800024b4:	b7d1                	j	80002478 <scheduler+0x22a>
       if (q) {
    800024b6:	040d0563          	beqz	s10,80002500 <scheduler+0x2b2>
    800024ba:	84ea                	mv	s1,s10
    800024bc:	b7ad                	j	80002426 <scheduler+0x1d8>
          acquire(&tickslock);
    800024be:	855a                	mv	a0,s6
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	710080e7          	jalr	1808(ra) # 80000bd0 <acquire>
          xticks = ticks;
    800024c8:	0009ac83          	lw	s9,0(s3)
          release(&tickslock);
    800024cc:	855a                	mv	a0,s6
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	7b6080e7          	jalr	1974(ra) # 80000c84 <release>
          acquire(&p->lock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	ffffe097          	auipc	ra,0xffffe
    800024dc:	6f8080e7          	jalr	1784(ra) # 80000bd0 <acquire>
          if(p->state == RUNNABLE) {
    800024e0:	4c9c                	lw	a5,24(s1)
    800024e2:	05878d63          	beq	a5,s8,8000253c <scheduler+0x2ee>
          release(&p->lock);
    800024e6:	8526                	mv	a0,s1
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	79c080e7          	jalr	1948(ra) # 80000c84 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800024f0:	19048493          	addi	s1,s1,400
    800024f4:	01248663          	beq	s1,s2,80002500 <scheduler+0x2b2>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    800024f8:	000ba783          	lw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffd6000>
    800024fc:	9bf5                	andi	a5,a5,-3
    800024fe:	d3e1                	beqz	a5,800024be <scheduler+0x270>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002500:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002504:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002508:	10079073          	csrw	sstatus,a5
    if (sched_policy == SCHED_NPREEMPT_SJF) {
    8000250c:	00008797          	auipc	a5,0x8
    80002510:	b5c7a783          	lw	a5,-1188(a5) # 8000a068 <sched_policy>
    80002514:	4705                	li	a4,1
    80002516:	d8e789e3          	beq	a5,a4,800022a8 <scheduler+0x5a>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    8000251a:	470d                	li	a4,3
       for(p = proc; p < &proc[NPROC]; p++) {
    8000251c:	00010497          	auipc	s1,0x10
    80002520:	20c48493          	addi	s1,s1,524 # 80012728 <proc>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    80002524:	e6e782e3          	beq	a5,a4,80002388 <scheduler+0x13a>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    80002528:	00008b97          	auipc	s7,0x8
    8000252c:	b40b8b93          	addi	s7,s7,-1216 # 8000a068 <sched_policy>
          acquire(&tickslock);
    80002530:	00016b17          	auipc	s6,0x16
    80002534:	5f8b0b13          	addi	s6,s6,1528 # 80018b28 <tickslock>
          if(p->state == RUNNABLE) {
    80002538:	4c0d                	li	s8,3
    8000253a:	bf7d                	j	800024f8 <scheduler+0x2aa>
            p->state = RUNNING;
    8000253c:	4791                	li	a5,4
    8000253e:	cc9c                	sw	a5,24(s1)
	    p->waittime += (xticks - p->waitstart);
    80002540:	17c4a783          	lw	a5,380(s1)
    80002544:	019787bb          	addw	a5,a5,s9
    80002548:	1804a703          	lw	a4,384(s1)
    8000254c:	9f99                	subw	a5,a5,a4
    8000254e:	16f4ae23          	sw	a5,380(s1)
	    p->burst_start = xticks;
    80002552:	1994a223          	sw	s9,388(s1)
            c->proc = p;
    80002556:	049a3423          	sd	s1,72(s4)
            swtch(&c->context, &p->context);
    8000255a:	06848593          	addi	a1,s1,104
    8000255e:	8556                	mv	a0,s5
    80002560:	00001097          	auipc	ra,0x1
    80002564:	366080e7          	jalr	870(ra) # 800038c6 <swtch>
            c->proc = 0;
    80002568:	040a3423          	sd	zero,72(s4)
    8000256c:	bfad                	j	800024e6 <scheduler+0x298>

000000008000256e <sched>:
{
    8000256e:	7179                	addi	sp,sp,-48
    80002570:	f406                	sd	ra,40(sp)
    80002572:	f022                	sd	s0,32(sp)
    80002574:	ec26                	sd	s1,24(sp)
    80002576:	e84a                	sd	s2,16(sp)
    80002578:	e44e                	sd	s3,8(sp)
    8000257a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	482080e7          	jalr	1154(ra) # 800019fe <myproc>
    80002584:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	5d0080e7          	jalr	1488(ra) # 80000b56 <holding>
    8000258e:	c93d                	beqz	a0,80002604 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002590:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002592:	2781                	sext.w	a5,a5
    80002594:	079e                	slli	a5,a5,0x7
    80002596:	00010717          	auipc	a4,0x10
    8000259a:	d4a70713          	addi	a4,a4,-694 # 800122e0 <pid_lock>
    8000259e:	97ba                	add	a5,a5,a4
    800025a0:	0c07a703          	lw	a4,192(a5)
    800025a4:	4785                	li	a5,1
    800025a6:	06f71763          	bne	a4,a5,80002614 <sched+0xa6>
  if(p->state == RUNNING)
    800025aa:	4c98                	lw	a4,24(s1)
    800025ac:	4791                	li	a5,4
    800025ae:	06f70b63          	beq	a4,a5,80002624 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025b2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025b6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800025b8:	efb5                	bnez	a5,80002634 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025ba:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800025bc:	00010917          	auipc	s2,0x10
    800025c0:	d2490913          	addi	s2,s2,-732 # 800122e0 <pid_lock>
    800025c4:	2781                	sext.w	a5,a5
    800025c6:	079e                	slli	a5,a5,0x7
    800025c8:	97ca                	add	a5,a5,s2
    800025ca:	0c47a983          	lw	s3,196(a5)
    800025ce:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800025d0:	2781                	sext.w	a5,a5
    800025d2:	079e                	slli	a5,a5,0x7
    800025d4:	00010597          	auipc	a1,0x10
    800025d8:	d5c58593          	addi	a1,a1,-676 # 80012330 <cpus+0x8>
    800025dc:	95be                	add	a1,a1,a5
    800025de:	06848513          	addi	a0,s1,104
    800025e2:	00001097          	auipc	ra,0x1
    800025e6:	2e4080e7          	jalr	740(ra) # 800038c6 <swtch>
    800025ea:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800025ec:	2781                	sext.w	a5,a5
    800025ee:	079e                	slli	a5,a5,0x7
    800025f0:	993e                	add	s2,s2,a5
    800025f2:	0d392223          	sw	s3,196(s2)
}
    800025f6:	70a2                	ld	ra,40(sp)
    800025f8:	7402                	ld	s0,32(sp)
    800025fa:	64e2                	ld	s1,24(sp)
    800025fc:	6942                	ld	s2,16(sp)
    800025fe:	69a2                	ld	s3,8(sp)
    80002600:	6145                	addi	sp,sp,48
    80002602:	8082                	ret
    panic("sched p->lock");
    80002604:	00007517          	auipc	a0,0x7
    80002608:	c3450513          	addi	a0,a0,-972 # 80009238 <digits+0x1f8>
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	f2e080e7          	jalr	-210(ra) # 8000053a <panic>
    panic("sched locks");
    80002614:	00007517          	auipc	a0,0x7
    80002618:	c3450513          	addi	a0,a0,-972 # 80009248 <digits+0x208>
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	f1e080e7          	jalr	-226(ra) # 8000053a <panic>
    panic("sched running");
    80002624:	00007517          	auipc	a0,0x7
    80002628:	c3450513          	addi	a0,a0,-972 # 80009258 <digits+0x218>
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	f0e080e7          	jalr	-242(ra) # 8000053a <panic>
    panic("sched interruptible");
    80002634:	00007517          	auipc	a0,0x7
    80002638:	c3450513          	addi	a0,a0,-972 # 80009268 <digits+0x228>
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	efe080e7          	jalr	-258(ra) # 8000053a <panic>

0000000080002644 <yield>:
{
    80002644:	1101                	addi	sp,sp,-32
    80002646:	ec06                	sd	ra,24(sp)
    80002648:	e822                	sd	s0,16(sp)
    8000264a:	e426                	sd	s1,8(sp)
    8000264c:	e04a                	sd	s2,0(sp)
    8000264e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002650:	fffff097          	auipc	ra,0xfffff
    80002654:	3ae080e7          	jalr	942(ra) # 800019fe <myproc>
    80002658:	84aa                	mv	s1,a0
  acquire(&tickslock);
    8000265a:	00016517          	auipc	a0,0x16
    8000265e:	4ce50513          	addi	a0,a0,1230 # 80018b28 <tickslock>
    80002662:	ffffe097          	auipc	ra,0xffffe
    80002666:	56e080e7          	jalr	1390(ra) # 80000bd0 <acquire>
  xticks = ticks;
    8000266a:	00008917          	auipc	s2,0x8
    8000266e:	a0292903          	lw	s2,-1534(s2) # 8000a06c <ticks>
  release(&tickslock);
    80002672:	00016517          	auipc	a0,0x16
    80002676:	4b650513          	addi	a0,a0,1206 # 80018b28 <tickslock>
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	60a080e7          	jalr	1546(ra) # 80000c84 <release>
  acquire(&p->lock);
    80002682:	8526                	mv	a0,s1
    80002684:	ffffe097          	auipc	ra,0xffffe
    80002688:	54c080e7          	jalr	1356(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    8000268c:	478d                	li	a5,3
    8000268e:	cc9c                	sw	a5,24(s1)
  p->waitstart = xticks;
    80002690:	1924a023          	sw	s2,384(s1)
  p->cpu_usage += SCHED_PARAM_CPU_USAGE;
    80002694:	18c4a783          	lw	a5,396(s1)
    80002698:	0c87879b          	addiw	a5,a5,200
    8000269c:	18f4a623          	sw	a5,396(s1)
  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    800026a0:	5cdc                	lw	a5,60(s1)
    800026a2:	c7ed                	beqz	a5,8000278c <yield+0x148>
    800026a4:	1844a783          	lw	a5,388(s1)
    800026a8:	0f278263          	beq	a5,s2,8000278c <yield+0x148>
     num_cpubursts++;
    800026ac:	00008697          	auipc	a3,0x8
    800026b0:	99868693          	addi	a3,a3,-1640 # 8000a044 <num_cpubursts>
    800026b4:	4298                	lw	a4,0(a3)
    800026b6:	2705                	addiw	a4,a4,1
    800026b8:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    800026ba:	40f9073b          	subw	a4,s2,a5
    800026be:	0007061b          	sext.w	a2,a4
    800026c2:	00008597          	auipc	a1,0x8
    800026c6:	97e58593          	addi	a1,a1,-1666 # 8000a040 <cpubursts_tot>
    800026ca:	4194                	lw	a3,0(a1)
    800026cc:	9eb9                	addw	a3,a3,a4
    800026ce:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    800026d0:	00008697          	auipc	a3,0x8
    800026d4:	96c6a683          	lw	a3,-1684(a3) # 8000a03c <cpubursts_max>
    800026d8:	00c6f663          	bgeu	a3,a2,800026e4 <yield+0xa0>
    800026dc:	00008697          	auipc	a3,0x8
    800026e0:	96e6a023          	sw	a4,-1696(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    800026e4:	00007697          	auipc	a3,0x7
    800026e8:	4f46a683          	lw	a3,1268(a3) # 80009bd8 <cpubursts_min>
    800026ec:	00d67663          	bgeu	a2,a3,800026f8 <yield+0xb4>
    800026f0:	00007697          	auipc	a3,0x7
    800026f4:	4ee6a423          	sw	a4,1256(a3) # 80009bd8 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    800026f8:	1884a683          	lw	a3,392(s1)
    800026fc:	02d05763          	blez	a3,8000272a <yield+0xe6>
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002700:	0006859b          	sext.w	a1,a3
    80002704:	0ac5e363          	bltu	a1,a2,800027aa <yield+0x166>
    80002708:	9fad                	addw	a5,a5,a1
    8000270a:	412785bb          	subw	a1,a5,s2
    8000270e:	00008617          	auipc	a2,0x8
    80002712:	91e60613          	addi	a2,a2,-1762 # 8000a02c <estimation_error>
    80002716:	421c                	lw	a5,0(a2)
    80002718:	9fad                	addw	a5,a5,a1
    8000271a:	c21c                	sw	a5,0(a2)
	estimation_error_instance++;
    8000271c:	00008617          	auipc	a2,0x8
    80002720:	90c60613          	addi	a2,a2,-1780 # 8000a028 <estimation_error_instance>
    80002724:	421c                	lw	a5,0(a2)
    80002726:	2785                	addiw	a5,a5,1
    80002728:	c21c                	sw	a5,0(a2)
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    8000272a:	01f6d79b          	srliw	a5,a3,0x1f
    8000272e:	9fb5                	addw	a5,a5,a3
    80002730:	4017d79b          	sraiw	a5,a5,0x1
    80002734:	9fb9                	addw	a5,a5,a4
    80002736:	0017571b          	srliw	a4,a4,0x1
    8000273a:	9f99                	subw	a5,a5,a4
    8000273c:	0007871b          	sext.w	a4,a5
    80002740:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    80002744:	04e05463          	blez	a4,8000278c <yield+0x148>
        num_cpubursts_est++;
    80002748:	00008617          	auipc	a2,0x8
    8000274c:	8f060613          	addi	a2,a2,-1808 # 8000a038 <num_cpubursts_est>
    80002750:	4214                	lw	a3,0(a2)
    80002752:	2685                	addiw	a3,a3,1
    80002754:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    80002756:	00008617          	auipc	a2,0x8
    8000275a:	8de60613          	addi	a2,a2,-1826 # 8000a034 <cpubursts_est_tot>
    8000275e:	4214                	lw	a3,0(a2)
    80002760:	9ebd                	addw	a3,a3,a5
    80002762:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002764:	00008697          	auipc	a3,0x8
    80002768:	8cc6a683          	lw	a3,-1844(a3) # 8000a030 <cpubursts_est_max>
    8000276c:	00e6d663          	bge	a3,a4,80002778 <yield+0x134>
    80002770:	00008697          	auipc	a3,0x8
    80002774:	8cf6a023          	sw	a5,-1856(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80002778:	00007697          	auipc	a3,0x7
    8000277c:	45c6a683          	lw	a3,1116(a3) # 80009bd4 <cpubursts_est_min>
    80002780:	00d75663          	bge	a4,a3,8000278c <yield+0x148>
    80002784:	00007717          	auipc	a4,0x7
    80002788:	44f72823          	sw	a5,1104(a4) # 80009bd4 <cpubursts_est_min>
  sched();
    8000278c:	00000097          	auipc	ra,0x0
    80002790:	de2080e7          	jalr	-542(ra) # 8000256e <sched>
  release(&p->lock);
    80002794:	8526                	mv	a0,s1
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	4ee080e7          	jalr	1262(ra) # 80000c84 <release>
}
    8000279e:	60e2                	ld	ra,24(sp)
    800027a0:	6442                	ld	s0,16(sp)
    800027a2:	64a2                	ld	s1,8(sp)
    800027a4:	6902                	ld	s2,0(sp)
    800027a6:	6105                	addi	sp,sp,32
    800027a8:	8082                	ret
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    800027aa:	40b705bb          	subw	a1,a4,a1
    800027ae:	b785                	j	8000270e <yield+0xca>

00000000800027b0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800027b0:	7179                	addi	sp,sp,-48
    800027b2:	f406                	sd	ra,40(sp)
    800027b4:	f022                	sd	s0,32(sp)
    800027b6:	ec26                	sd	s1,24(sp)
    800027b8:	e84a                	sd	s2,16(sp)
    800027ba:	e44e                	sd	s3,8(sp)
    800027bc:	e052                	sd	s4,0(sp)
    800027be:	1800                	addi	s0,sp,48
    800027c0:	89aa                	mv	s3,a0
    800027c2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027c4:	fffff097          	auipc	ra,0xfffff
    800027c8:	23a080e7          	jalr	570(ra) # 800019fe <myproc>
    800027cc:	84aa                	mv	s1,a0
  uint xticks;

  if (!holding(&tickslock)) {
    800027ce:	00016517          	auipc	a0,0x16
    800027d2:	35a50513          	addi	a0,a0,858 # 80018b28 <tickslock>
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	380080e7          	jalr	896(ra) # 80000b56 <holding>
    800027de:	14050863          	beqz	a0,8000292e <sleep+0x17e>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    800027e2:	00008a17          	auipc	s4,0x8
    800027e6:	88aa2a03          	lw	s4,-1910(s4) # 8000a06c <ticks>
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800027ea:	8526                	mv	a0,s1
    800027ec:	ffffe097          	auipc	ra,0xffffe
    800027f0:	3e4080e7          	jalr	996(ra) # 80000bd0 <acquire>
  release(lk);
    800027f4:	854a                	mv	a0,s2
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	48e080e7          	jalr	1166(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    800027fe:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002802:	4789                	li	a5,2
    80002804:	cc9c                	sw	a5,24(s1)

  p->cpu_usage += (SCHED_PARAM_CPU_USAGE/2);
    80002806:	18c4a783          	lw	a5,396(s1)
    8000280a:	0647879b          	addiw	a5,a5,100
    8000280e:	18f4a623          	sw	a5,396(s1)

  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    80002812:	5cdc                	lw	a5,60(s1)
    80002814:	c7ed                	beqz	a5,800028fe <sleep+0x14e>
    80002816:	1844a783          	lw	a5,388(s1)
    8000281a:	0f478263          	beq	a5,s4,800028fe <sleep+0x14e>
     num_cpubursts++;
    8000281e:	00008697          	auipc	a3,0x8
    80002822:	82668693          	addi	a3,a3,-2010 # 8000a044 <num_cpubursts>
    80002826:	4298                	lw	a4,0(a3)
    80002828:	2705                	addiw	a4,a4,1
    8000282a:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    8000282c:	40fa073b          	subw	a4,s4,a5
    80002830:	0007061b          	sext.w	a2,a4
    80002834:	00008597          	auipc	a1,0x8
    80002838:	80c58593          	addi	a1,a1,-2036 # 8000a040 <cpubursts_tot>
    8000283c:	4194                	lw	a3,0(a1)
    8000283e:	9eb9                	addw	a3,a3,a4
    80002840:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002842:	00007697          	auipc	a3,0x7
    80002846:	7fa6a683          	lw	a3,2042(a3) # 8000a03c <cpubursts_max>
    8000284a:	00c6f663          	bgeu	a3,a2,80002856 <sleep+0xa6>
    8000284e:	00007697          	auipc	a3,0x7
    80002852:	7ee6a723          	sw	a4,2030(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002856:	00007697          	auipc	a3,0x7
    8000285a:	3826a683          	lw	a3,898(a3) # 80009bd8 <cpubursts_min>
    8000285e:	00d67663          	bgeu	a2,a3,8000286a <sleep+0xba>
    80002862:	00007697          	auipc	a3,0x7
    80002866:	36e6ab23          	sw	a4,886(a3) # 80009bd8 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    8000286a:	1884a683          	lw	a3,392(s1)
    8000286e:	02d05763          	blez	a3,8000289c <sleep+0xec>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002872:	0006859b          	sext.w	a1,a3
    80002876:	0ec5e163          	bltu	a1,a2,80002958 <sleep+0x1a8>
    8000287a:	9fad                	addw	a5,a5,a1
    8000287c:	414785bb          	subw	a1,a5,s4
    80002880:	00007617          	auipc	a2,0x7
    80002884:	7ac60613          	addi	a2,a2,1964 # 8000a02c <estimation_error>
    80002888:	421c                	lw	a5,0(a2)
    8000288a:	9fad                	addw	a5,a5,a1
    8000288c:	c21c                	sw	a5,0(a2)
        estimation_error_instance++;
    8000288e:	00007617          	auipc	a2,0x7
    80002892:	79a60613          	addi	a2,a2,1946 # 8000a028 <estimation_error_instance>
    80002896:	421c                	lw	a5,0(a2)
    80002898:	2785                	addiw	a5,a5,1
    8000289a:	c21c                	sw	a5,0(a2)
     }
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    8000289c:	01f6d79b          	srliw	a5,a3,0x1f
    800028a0:	9fb5                	addw	a5,a5,a3
    800028a2:	4017d79b          	sraiw	a5,a5,0x1
    800028a6:	9fb9                	addw	a5,a5,a4
    800028a8:	0017571b          	srliw	a4,a4,0x1
    800028ac:	9f99                	subw	a5,a5,a4
    800028ae:	0007871b          	sext.w	a4,a5
    800028b2:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    800028b6:	04e05463          	blez	a4,800028fe <sleep+0x14e>
        num_cpubursts_est++;
    800028ba:	00007617          	auipc	a2,0x7
    800028be:	77e60613          	addi	a2,a2,1918 # 8000a038 <num_cpubursts_est>
    800028c2:	4214                	lw	a3,0(a2)
    800028c4:	2685                	addiw	a3,a3,1
    800028c6:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    800028c8:	00007617          	auipc	a2,0x7
    800028cc:	76c60613          	addi	a2,a2,1900 # 8000a034 <cpubursts_est_tot>
    800028d0:	4214                	lw	a3,0(a2)
    800028d2:	9ebd                	addw	a3,a3,a5
    800028d4:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    800028d6:	00007697          	auipc	a3,0x7
    800028da:	75a6a683          	lw	a3,1882(a3) # 8000a030 <cpubursts_est_max>
    800028de:	00e6d663          	bge	a3,a4,800028ea <sleep+0x13a>
    800028e2:	00007697          	auipc	a3,0x7
    800028e6:	74f6a723          	sw	a5,1870(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    800028ea:	00007697          	auipc	a3,0x7
    800028ee:	2ea6a683          	lw	a3,746(a3) # 80009bd4 <cpubursts_est_min>
    800028f2:	00d75663          	bge	a4,a3,800028fe <sleep+0x14e>
    800028f6:	00007717          	auipc	a4,0x7
    800028fa:	2cf72f23          	sw	a5,734(a4) # 80009bd4 <cpubursts_est_min>
     }
  }

  sched();
    800028fe:	00000097          	auipc	ra,0x0
    80002902:	c70080e7          	jalr	-912(ra) # 8000256e <sched>

  // Tidy up.
  p->chan = 0;
    80002906:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000290a:	8526                	mv	a0,s1
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	378080e7          	jalr	888(ra) # 80000c84 <release>
  acquire(lk);
    80002914:	854a                	mv	a0,s2
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	2ba080e7          	jalr	698(ra) # 80000bd0 <acquire>
}
    8000291e:	70a2                	ld	ra,40(sp)
    80002920:	7402                	ld	s0,32(sp)
    80002922:	64e2                	ld	s1,24(sp)
    80002924:	6942                	ld	s2,16(sp)
    80002926:	69a2                	ld	s3,8(sp)
    80002928:	6a02                	ld	s4,0(sp)
    8000292a:	6145                	addi	sp,sp,48
    8000292c:	8082                	ret
     acquire(&tickslock);
    8000292e:	00016517          	auipc	a0,0x16
    80002932:	1fa50513          	addi	a0,a0,506 # 80018b28 <tickslock>
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	29a080e7          	jalr	666(ra) # 80000bd0 <acquire>
     xticks = ticks;
    8000293e:	00007a17          	auipc	s4,0x7
    80002942:	72ea2a03          	lw	s4,1838(s4) # 8000a06c <ticks>
     release(&tickslock);
    80002946:	00016517          	auipc	a0,0x16
    8000294a:	1e250513          	addi	a0,a0,482 # 80018b28 <tickslock>
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	336080e7          	jalr	822(ra) # 80000c84 <release>
    80002956:	bd51                	j	800027ea <sleep+0x3a>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002958:	40b705bb          	subw	a1,a4,a1
    8000295c:	b715                	j	80002880 <sleep+0xd0>

000000008000295e <wait>:
{
    8000295e:	715d                	addi	sp,sp,-80
    80002960:	e486                	sd	ra,72(sp)
    80002962:	e0a2                	sd	s0,64(sp)
    80002964:	fc26                	sd	s1,56(sp)
    80002966:	f84a                	sd	s2,48(sp)
    80002968:	f44e                	sd	s3,40(sp)
    8000296a:	f052                	sd	s4,32(sp)
    8000296c:	ec56                	sd	s5,24(sp)
    8000296e:	e85a                	sd	s6,16(sp)
    80002970:	e45e                	sd	s7,8(sp)
    80002972:	e062                	sd	s8,0(sp)
    80002974:	0880                	addi	s0,sp,80
    80002976:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002978:	fffff097          	auipc	ra,0xfffff
    8000297c:	086080e7          	jalr	134(ra) # 800019fe <myproc>
    80002980:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002982:	00010517          	auipc	a0,0x10
    80002986:	97650513          	addi	a0,a0,-1674 # 800122f8 <wait_lock>
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	246080e7          	jalr	582(ra) # 80000bd0 <acquire>
    havekids = 0;
    80002992:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002994:	4a15                	li	s4,5
        havekids = 1;
    80002996:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002998:	00016997          	auipc	s3,0x16
    8000299c:	19098993          	addi	s3,s3,400 # 80018b28 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800029a0:	00010c17          	auipc	s8,0x10
    800029a4:	958c0c13          	addi	s8,s8,-1704 # 800122f8 <wait_lock>
    havekids = 0;
    800029a8:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800029aa:	00010497          	auipc	s1,0x10
    800029ae:	d7e48493          	addi	s1,s1,-642 # 80012728 <proc>
    800029b2:	a0bd                	j	80002a20 <wait+0xc2>
          pid = np->pid;
    800029b4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800029b8:	000b0e63          	beqz	s6,800029d4 <wait+0x76>
    800029bc:	4691                	li	a3,4
    800029be:	02c48613          	addi	a2,s1,44
    800029c2:	85da                	mv	a1,s6
    800029c4:	05893503          	ld	a0,88(s2)
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	ce2080e7          	jalr	-798(ra) # 800016aa <copyout>
    800029d0:	02054563          	bltz	a0,800029fa <wait+0x9c>
          freeproc(np);
    800029d4:	8526                	mv	a0,s1
    800029d6:	fffff097          	auipc	ra,0xfffff
    800029da:	212080e7          	jalr	530(ra) # 80001be8 <freeproc>
          release(&np->lock);
    800029de:	8526                	mv	a0,s1
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	2a4080e7          	jalr	676(ra) # 80000c84 <release>
          release(&wait_lock);
    800029e8:	00010517          	auipc	a0,0x10
    800029ec:	91050513          	addi	a0,a0,-1776 # 800122f8 <wait_lock>
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	294080e7          	jalr	660(ra) # 80000c84 <release>
          return pid;
    800029f8:	a09d                	j	80002a5e <wait+0x100>
            release(&np->lock);
    800029fa:	8526                	mv	a0,s1
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	288080e7          	jalr	648(ra) # 80000c84 <release>
            release(&wait_lock);
    80002a04:	00010517          	auipc	a0,0x10
    80002a08:	8f450513          	addi	a0,a0,-1804 # 800122f8 <wait_lock>
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	278080e7          	jalr	632(ra) # 80000c84 <release>
            return -1;
    80002a14:	59fd                	li	s3,-1
    80002a16:	a0a1                	j	80002a5e <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002a18:	19048493          	addi	s1,s1,400
    80002a1c:	03348463          	beq	s1,s3,80002a44 <wait+0xe6>
      if(np->parent == p){
    80002a20:	60bc                	ld	a5,64(s1)
    80002a22:	ff279be3          	bne	a5,s2,80002a18 <wait+0xba>
        acquire(&np->lock);
    80002a26:	8526                	mv	a0,s1
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	1a8080e7          	jalr	424(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    80002a30:	4c9c                	lw	a5,24(s1)
    80002a32:	f94781e3          	beq	a5,s4,800029b4 <wait+0x56>
        release(&np->lock);
    80002a36:	8526                	mv	a0,s1
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	24c080e7          	jalr	588(ra) # 80000c84 <release>
        havekids = 1;
    80002a40:	8756                	mv	a4,s5
    80002a42:	bfd9                	j	80002a18 <wait+0xba>
    if(!havekids || p->killed){
    80002a44:	c701                	beqz	a4,80002a4c <wait+0xee>
    80002a46:	02892783          	lw	a5,40(s2)
    80002a4a:	c79d                	beqz	a5,80002a78 <wait+0x11a>
      release(&wait_lock);
    80002a4c:	00010517          	auipc	a0,0x10
    80002a50:	8ac50513          	addi	a0,a0,-1876 # 800122f8 <wait_lock>
    80002a54:	ffffe097          	auipc	ra,0xffffe
    80002a58:	230080e7          	jalr	560(ra) # 80000c84 <release>
      return -1;
    80002a5c:	59fd                	li	s3,-1
}
    80002a5e:	854e                	mv	a0,s3
    80002a60:	60a6                	ld	ra,72(sp)
    80002a62:	6406                	ld	s0,64(sp)
    80002a64:	74e2                	ld	s1,56(sp)
    80002a66:	7942                	ld	s2,48(sp)
    80002a68:	79a2                	ld	s3,40(sp)
    80002a6a:	7a02                	ld	s4,32(sp)
    80002a6c:	6ae2                	ld	s5,24(sp)
    80002a6e:	6b42                	ld	s6,16(sp)
    80002a70:	6ba2                	ld	s7,8(sp)
    80002a72:	6c02                	ld	s8,0(sp)
    80002a74:	6161                	addi	sp,sp,80
    80002a76:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a78:	85e2                	mv	a1,s8
    80002a7a:	854a                	mv	a0,s2
    80002a7c:	00000097          	auipc	ra,0x0
    80002a80:	d34080e7          	jalr	-716(ra) # 800027b0 <sleep>
    havekids = 0;
    80002a84:	b715                	j	800029a8 <wait+0x4a>

0000000080002a86 <waitpid>:
{
    80002a86:	711d                	addi	sp,sp,-96
    80002a88:	ec86                	sd	ra,88(sp)
    80002a8a:	e8a2                	sd	s0,80(sp)
    80002a8c:	e4a6                	sd	s1,72(sp)
    80002a8e:	e0ca                	sd	s2,64(sp)
    80002a90:	fc4e                	sd	s3,56(sp)
    80002a92:	f852                	sd	s4,48(sp)
    80002a94:	f456                	sd	s5,40(sp)
    80002a96:	f05a                	sd	s6,32(sp)
    80002a98:	ec5e                	sd	s7,24(sp)
    80002a9a:	e862                	sd	s8,16(sp)
    80002a9c:	e466                	sd	s9,8(sp)
    80002a9e:	1080                	addi	s0,sp,96
    80002aa0:	8a2a                	mv	s4,a0
    80002aa2:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    80002aa4:	fffff097          	auipc	ra,0xfffff
    80002aa8:	f5a080e7          	jalr	-166(ra) # 800019fe <myproc>
    80002aac:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002aae:	00010517          	auipc	a0,0x10
    80002ab2:	84a50513          	addi	a0,a0,-1974 # 800122f8 <wait_lock>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	11a080e7          	jalr	282(ra) # 80000bd0 <acquire>
  int found=0;
    80002abe:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    80002ac0:	4a95                	li	s5,5
	found = 1;
    80002ac2:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002ac4:	00016997          	auipc	s3,0x16
    80002ac8:	06498993          	addi	s3,s3,100 # 80018b28 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002acc:	00010b97          	auipc	s7,0x10
    80002ad0:	82cb8b93          	addi	s7,s7,-2004 # 800122f8 <wait_lock>
    80002ad4:	a0c9                	j	80002b96 <waitpid+0x110>
             release(&np->lock);
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	1ac080e7          	jalr	428(ra) # 80000c84 <release>
             release(&wait_lock);
    80002ae0:	00010517          	auipc	a0,0x10
    80002ae4:	81850513          	addi	a0,a0,-2024 # 800122f8 <wait_lock>
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	19c080e7          	jalr	412(ra) # 80000c84 <release>
             return -1;
    80002af0:	557d                	li	a0,-1
    80002af2:	a895                	j	80002b66 <waitpid+0xe0>
        release(&np->lock);
    80002af4:	8526                	mv	a0,s1
    80002af6:	ffffe097          	auipc	ra,0xffffe
    80002afa:	18e080e7          	jalr	398(ra) # 80000c84 <release>
	found = 1;
    80002afe:	8cda                	mv	s9,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002b00:	19048493          	addi	s1,s1,400
    80002b04:	07348e63          	beq	s1,s3,80002b80 <waitpid+0xfa>
      if((np->parent == p) && (np->pid == pid)){
    80002b08:	60bc                	ld	a5,64(s1)
    80002b0a:	ff279be3          	bne	a5,s2,80002b00 <waitpid+0x7a>
    80002b0e:	589c                	lw	a5,48(s1)
    80002b10:	ff4798e3          	bne	a5,s4,80002b00 <waitpid+0x7a>
        acquire(&np->lock);
    80002b14:	8526                	mv	a0,s1
    80002b16:	ffffe097          	auipc	ra,0xffffe
    80002b1a:	0ba080e7          	jalr	186(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    80002b1e:	4c9c                	lw	a5,24(s1)
    80002b20:	fd579ae3          	bne	a5,s5,80002af4 <waitpid+0x6e>
           if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002b24:	000c0e63          	beqz	s8,80002b40 <waitpid+0xba>
    80002b28:	4691                	li	a3,4
    80002b2a:	02c48613          	addi	a2,s1,44
    80002b2e:	85e2                	mv	a1,s8
    80002b30:	05893503          	ld	a0,88(s2)
    80002b34:	fffff097          	auipc	ra,0xfffff
    80002b38:	b76080e7          	jalr	-1162(ra) # 800016aa <copyout>
    80002b3c:	f8054de3          	bltz	a0,80002ad6 <waitpid+0x50>
           freeproc(np);
    80002b40:	8526                	mv	a0,s1
    80002b42:	fffff097          	auipc	ra,0xfffff
    80002b46:	0a6080e7          	jalr	166(ra) # 80001be8 <freeproc>
           release(&np->lock);
    80002b4a:	8526                	mv	a0,s1
    80002b4c:	ffffe097          	auipc	ra,0xffffe
    80002b50:	138080e7          	jalr	312(ra) # 80000c84 <release>
           release(&wait_lock);
    80002b54:	0000f517          	auipc	a0,0xf
    80002b58:	7a450513          	addi	a0,a0,1956 # 800122f8 <wait_lock>
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	128080e7          	jalr	296(ra) # 80000c84 <release>
           return pid;
    80002b64:	8552                	mv	a0,s4
}
    80002b66:	60e6                	ld	ra,88(sp)
    80002b68:	6446                	ld	s0,80(sp)
    80002b6a:	64a6                	ld	s1,72(sp)
    80002b6c:	6906                	ld	s2,64(sp)
    80002b6e:	79e2                	ld	s3,56(sp)
    80002b70:	7a42                	ld	s4,48(sp)
    80002b72:	7aa2                	ld	s5,40(sp)
    80002b74:	7b02                	ld	s6,32(sp)
    80002b76:	6be2                	ld	s7,24(sp)
    80002b78:	6c42                	ld	s8,16(sp)
    80002b7a:	6ca2                	ld	s9,8(sp)
    80002b7c:	6125                	addi	sp,sp,96
    80002b7e:	8082                	ret
    if(!found || p->killed){
    80002b80:	020c8063          	beqz	s9,80002ba0 <waitpid+0x11a>
    80002b84:	02892783          	lw	a5,40(s2)
    80002b88:	ef81                	bnez	a5,80002ba0 <waitpid+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002b8a:	85de                	mv	a1,s7
    80002b8c:	854a                	mv	a0,s2
    80002b8e:	00000097          	auipc	ra,0x0
    80002b92:	c22080e7          	jalr	-990(ra) # 800027b0 <sleep>
    for(np = proc; np < &proc[NPROC]; np++){
    80002b96:	00010497          	auipc	s1,0x10
    80002b9a:	b9248493          	addi	s1,s1,-1134 # 80012728 <proc>
    80002b9e:	b7ad                	j	80002b08 <waitpid+0x82>
      release(&wait_lock);
    80002ba0:	0000f517          	auipc	a0,0xf
    80002ba4:	75850513          	addi	a0,a0,1880 # 800122f8 <wait_lock>
    80002ba8:	ffffe097          	auipc	ra,0xffffe
    80002bac:	0dc080e7          	jalr	220(ra) # 80000c84 <release>
      return -1;
    80002bb0:	557d                	li	a0,-1
    80002bb2:	bf55                	j	80002b66 <waitpid+0xe0>

0000000080002bb4 <condsleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
condsleep(struct cond_t* chan, struct sleeplock *lk)
{
    80002bb4:	7139                	addi	sp,sp,-64
    80002bb6:	fc06                	sd	ra,56(sp)
    80002bb8:	f822                	sd	s0,48(sp)
    80002bba:	f426                	sd	s1,40(sp)
    80002bbc:	f04a                	sd	s2,32(sp)
    80002bbe:	ec4e                	sd	s3,24(sp)
    80002bc0:	e852                	sd	s4,16(sp)
    80002bc2:	e456                	sd	s5,8(sp)
    80002bc4:	0080                	addi	s0,sp,64
    80002bc6:	89aa                	mv	s3,a0
    80002bc8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bca:	fffff097          	auipc	ra,0xfffff
    80002bce:	e34080e7          	jalr	-460(ra) # 800019fe <myproc>
    80002bd2:	84aa                	mv	s1,a0
  uint xticks;

  if (!holding(&tickslock)) {
    80002bd4:	00016517          	auipc	a0,0x16
    80002bd8:	f5450513          	addi	a0,a0,-172 # 80018b28 <tickslock>
    80002bdc:	ffffe097          	auipc	ra,0xffffe
    80002be0:	f7a080e7          	jalr	-134(ra) # 80000b56 <holding>
    80002be4:	16050763          	beqz	a0,80002d52 <condsleep+0x19e>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    80002be8:	00007a97          	auipc	s5,0x7
    80002bec:	484aaa83          	lw	s5,1156(s5) # 8000a06c <ticks>
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&condsleep_lock);
    80002bf0:	0000fa17          	auipc	s4,0xf
    80002bf4:	720a0a13          	addi	s4,s4,1824 # 80012310 <condsleep_lock>
    80002bf8:	8552                	mv	a0,s4
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	fd6080e7          	jalr	-42(ra) # 80000bd0 <acquire>
  acquire(&p->lock);  //DOC: sleeplock1
    80002c02:	8526                	mv	a0,s1
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	fcc080e7          	jalr	-52(ra) # 80000bd0 <acquire>
  releasesleep(lk);
    80002c0c:	854a                	mv	a0,s2
    80002c0e:	00003097          	auipc	ra,0x3
    80002c12:	312080e7          	jalr	786(ra) # 80005f20 <releasesleep>
  release(&condsleep_lock);
    80002c16:	8552                	mv	a0,s4
    80002c18:	ffffe097          	auipc	ra,0xffffe
    80002c1c:	06c080e7          	jalr	108(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    80002c20:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002c24:	4789                	li	a5,2
    80002c26:	cc9c                	sw	a5,24(s1)

  p->cpu_usage += (SCHED_PARAM_CPU_USAGE/2);
    80002c28:	18c4a783          	lw	a5,396(s1)
    80002c2c:	0647879b          	addiw	a5,a5,100
    80002c30:	18f4a623          	sw	a5,396(s1)

  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    80002c34:	5cdc                	lw	a5,60(s1)
    80002c36:	c7ed                	beqz	a5,80002d20 <condsleep+0x16c>
    80002c38:	1844a783          	lw	a5,388(s1)
    80002c3c:	0f578263          	beq	a5,s5,80002d20 <condsleep+0x16c>
     num_cpubursts++;
    80002c40:	00007697          	auipc	a3,0x7
    80002c44:	40468693          	addi	a3,a3,1028 # 8000a044 <num_cpubursts>
    80002c48:	4298                	lw	a4,0(a3)
    80002c4a:	2705                	addiw	a4,a4,1
    80002c4c:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    80002c4e:	40fa873b          	subw	a4,s5,a5
    80002c52:	0007061b          	sext.w	a2,a4
    80002c56:	00007597          	auipc	a1,0x7
    80002c5a:	3ea58593          	addi	a1,a1,1002 # 8000a040 <cpubursts_tot>
    80002c5e:	4194                	lw	a3,0(a1)
    80002c60:	9eb9                	addw	a3,a3,a4
    80002c62:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002c64:	00007697          	auipc	a3,0x7
    80002c68:	3d86a683          	lw	a3,984(a3) # 8000a03c <cpubursts_max>
    80002c6c:	00c6f663          	bgeu	a3,a2,80002c78 <condsleep+0xc4>
    80002c70:	00007697          	auipc	a3,0x7
    80002c74:	3ce6a623          	sw	a4,972(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002c78:	00007697          	auipc	a3,0x7
    80002c7c:	f606a683          	lw	a3,-160(a3) # 80009bd8 <cpubursts_min>
    80002c80:	00d67663          	bgeu	a2,a3,80002c8c <condsleep+0xd8>
    80002c84:	00007697          	auipc	a3,0x7
    80002c88:	f4e6aa23          	sw	a4,-172(a3) # 80009bd8 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    80002c8c:	1884a683          	lw	a3,392(s1)
    80002c90:	02d05763          	blez	a3,80002cbe <condsleep+0x10a>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002c94:	0006859b          	sext.w	a1,a3
    80002c98:	0ec5e263          	bltu	a1,a2,80002d7c <condsleep+0x1c8>
    80002c9c:	9fad                	addw	a5,a5,a1
    80002c9e:	415785bb          	subw	a1,a5,s5
    80002ca2:	00007617          	auipc	a2,0x7
    80002ca6:	38a60613          	addi	a2,a2,906 # 8000a02c <estimation_error>
    80002caa:	421c                	lw	a5,0(a2)
    80002cac:	9fad                	addw	a5,a5,a1
    80002cae:	c21c                	sw	a5,0(a2)
        estimation_error_instance++;
    80002cb0:	00007617          	auipc	a2,0x7
    80002cb4:	37860613          	addi	a2,a2,888 # 8000a028 <estimation_error_instance>
    80002cb8:	421c                	lw	a5,0(a2)
    80002cba:	2785                	addiw	a5,a5,1
    80002cbc:	c21c                	sw	a5,0(a2)
     }
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    80002cbe:	01f6d79b          	srliw	a5,a3,0x1f
    80002cc2:	9fb5                	addw	a5,a5,a3
    80002cc4:	4017d79b          	sraiw	a5,a5,0x1
    80002cc8:	9fb9                	addw	a5,a5,a4
    80002cca:	0017571b          	srliw	a4,a4,0x1
    80002cce:	9f99                	subw	a5,a5,a4
    80002cd0:	0007871b          	sext.w	a4,a5
    80002cd4:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    80002cd8:	04e05463          	blez	a4,80002d20 <condsleep+0x16c>
        num_cpubursts_est++;
    80002cdc:	00007617          	auipc	a2,0x7
    80002ce0:	35c60613          	addi	a2,a2,860 # 8000a038 <num_cpubursts_est>
    80002ce4:	4214                	lw	a3,0(a2)
    80002ce6:	2685                	addiw	a3,a3,1
    80002ce8:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    80002cea:	00007617          	auipc	a2,0x7
    80002cee:	34a60613          	addi	a2,a2,842 # 8000a034 <cpubursts_est_tot>
    80002cf2:	4214                	lw	a3,0(a2)
    80002cf4:	9ebd                	addw	a3,a3,a5
    80002cf6:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002cf8:	00007697          	auipc	a3,0x7
    80002cfc:	3386a683          	lw	a3,824(a3) # 8000a030 <cpubursts_est_max>
    80002d00:	00e6d663          	bge	a3,a4,80002d0c <condsleep+0x158>
    80002d04:	00007697          	auipc	a3,0x7
    80002d08:	32f6a623          	sw	a5,812(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80002d0c:	00007697          	auipc	a3,0x7
    80002d10:	ec86a683          	lw	a3,-312(a3) # 80009bd4 <cpubursts_est_min>
    80002d14:	00d75663          	bge	a4,a3,80002d20 <condsleep+0x16c>
    80002d18:	00007717          	auipc	a4,0x7
    80002d1c:	eaf72e23          	sw	a5,-324(a4) # 80009bd4 <cpubursts_est_min>
     }
  }

  sched();
    80002d20:	00000097          	auipc	ra,0x0
    80002d24:	84e080e7          	jalr	-1970(ra) # 8000256e <sched>

  // Tidy up.
  p->chan = 0;
    80002d28:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002d2c:	8526                	mv	a0,s1
    80002d2e:	ffffe097          	auipc	ra,0xffffe
    80002d32:	f56080e7          	jalr	-170(ra) # 80000c84 <release>
  acquiresleep(lk);
    80002d36:	854a                	mv	a0,s2
    80002d38:	00003097          	auipc	ra,0x3
    80002d3c:	192080e7          	jalr	402(ra) # 80005eca <acquiresleep>
}
    80002d40:	70e2                	ld	ra,56(sp)
    80002d42:	7442                	ld	s0,48(sp)
    80002d44:	74a2                	ld	s1,40(sp)
    80002d46:	7902                	ld	s2,32(sp)
    80002d48:	69e2                	ld	s3,24(sp)
    80002d4a:	6a42                	ld	s4,16(sp)
    80002d4c:	6aa2                	ld	s5,8(sp)
    80002d4e:	6121                	addi	sp,sp,64
    80002d50:	8082                	ret
     acquire(&tickslock);
    80002d52:	00016517          	auipc	a0,0x16
    80002d56:	dd650513          	addi	a0,a0,-554 # 80018b28 <tickslock>
    80002d5a:	ffffe097          	auipc	ra,0xffffe
    80002d5e:	e76080e7          	jalr	-394(ra) # 80000bd0 <acquire>
     xticks = ticks;
    80002d62:	00007a97          	auipc	s5,0x7
    80002d66:	30aaaa83          	lw	s5,778(s5) # 8000a06c <ticks>
     release(&tickslock);
    80002d6a:	00016517          	auipc	a0,0x16
    80002d6e:	dbe50513          	addi	a0,a0,-578 # 80018b28 <tickslock>
    80002d72:	ffffe097          	auipc	ra,0xffffe
    80002d76:	f12080e7          	jalr	-238(ra) # 80000c84 <release>
    80002d7a:	bd9d                	j	80002bf0 <condsleep+0x3c>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002d7c:	40b705bb          	subw	a1,a4,a1
    80002d80:	b70d                	j	80002ca2 <condsleep+0xee>

0000000080002d82 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002d82:	7139                	addi	sp,sp,-64
    80002d84:	fc06                	sd	ra,56(sp)
    80002d86:	f822                	sd	s0,48(sp)
    80002d88:	f426                	sd	s1,40(sp)
    80002d8a:	f04a                	sd	s2,32(sp)
    80002d8c:	ec4e                	sd	s3,24(sp)
    80002d8e:	e852                	sd	s4,16(sp)
    80002d90:	e456                	sd	s5,8(sp)
    80002d92:	e05a                	sd	s6,0(sp)
    80002d94:	0080                	addi	s0,sp,64
    80002d96:	8a2a                	mv	s4,a0
  struct proc *p;
  uint xticks;

  if (!holding(&tickslock)) {
    80002d98:	00016517          	auipc	a0,0x16
    80002d9c:	d9050513          	addi	a0,a0,-624 # 80018b28 <tickslock>
    80002da0:	ffffe097          	auipc	ra,0xffffe
    80002da4:	db6080e7          	jalr	-586(ra) # 80000b56 <holding>
    80002da8:	c105                	beqz	a0,80002dc8 <wakeup+0x46>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    80002daa:	00007b17          	auipc	s6,0x7
    80002dae:	2c2b2b03          	lw	s6,706(s6) # 8000a06c <ticks>

  for(p = proc; p < &proc[NPROC]; p++) {
    80002db2:	00010497          	auipc	s1,0x10
    80002db6:	97648493          	addi	s1,s1,-1674 # 80012728 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002dba:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002dbc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002dbe:	00016917          	auipc	s2,0x16
    80002dc2:	d6a90913          	addi	s2,s2,-662 # 80018b28 <tickslock>
    80002dc6:	a83d                	j	80002e04 <wakeup+0x82>
     acquire(&tickslock);
    80002dc8:	00016517          	auipc	a0,0x16
    80002dcc:	d6050513          	addi	a0,a0,-672 # 80018b28 <tickslock>
    80002dd0:	ffffe097          	auipc	ra,0xffffe
    80002dd4:	e00080e7          	jalr	-512(ra) # 80000bd0 <acquire>
     xticks = ticks;
    80002dd8:	00007b17          	auipc	s6,0x7
    80002ddc:	294b2b03          	lw	s6,660(s6) # 8000a06c <ticks>
     release(&tickslock);
    80002de0:	00016517          	auipc	a0,0x16
    80002de4:	d4850513          	addi	a0,a0,-696 # 80018b28 <tickslock>
    80002de8:	ffffe097          	auipc	ra,0xffffe
    80002dec:	e9c080e7          	jalr	-356(ra) # 80000c84 <release>
    80002df0:	b7c9                	j	80002db2 <wakeup+0x30>
	p->waitstart = xticks;
      }
      release(&p->lock);
    80002df2:	8526                	mv	a0,s1
    80002df4:	ffffe097          	auipc	ra,0xffffe
    80002df8:	e90080e7          	jalr	-368(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002dfc:	19048493          	addi	s1,s1,400
    80002e00:	03248863          	beq	s1,s2,80002e30 <wakeup+0xae>
    if(p != myproc()){
    80002e04:	fffff097          	auipc	ra,0xfffff
    80002e08:	bfa080e7          	jalr	-1030(ra) # 800019fe <myproc>
    80002e0c:	fea488e3          	beq	s1,a0,80002dfc <wakeup+0x7a>
      acquire(&p->lock);
    80002e10:	8526                	mv	a0,s1
    80002e12:	ffffe097          	auipc	ra,0xffffe
    80002e16:	dbe080e7          	jalr	-578(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002e1a:	4c9c                	lw	a5,24(s1)
    80002e1c:	fd379be3          	bne	a5,s3,80002df2 <wakeup+0x70>
    80002e20:	709c                	ld	a5,32(s1)
    80002e22:	fd4798e3          	bne	a5,s4,80002df2 <wakeup+0x70>
        p->state = RUNNABLE;
    80002e26:	0154ac23          	sw	s5,24(s1)
	p->waitstart = xticks;
    80002e2a:	1964a023          	sw	s6,384(s1)
    80002e2e:	b7d1                	j	80002df2 <wakeup+0x70>
    }
  }
}
    80002e30:	70e2                	ld	ra,56(sp)
    80002e32:	7442                	ld	s0,48(sp)
    80002e34:	74a2                	ld	s1,40(sp)
    80002e36:	7902                	ld	s2,32(sp)
    80002e38:	69e2                	ld	s3,24(sp)
    80002e3a:	6a42                	ld	s4,16(sp)
    80002e3c:	6aa2                	ld	s5,8(sp)
    80002e3e:	6b02                	ld	s6,0(sp)
    80002e40:	6121                	addi	sp,sp,64
    80002e42:	8082                	ret

0000000080002e44 <reparent>:
{
    80002e44:	7179                	addi	sp,sp,-48
    80002e46:	f406                	sd	ra,40(sp)
    80002e48:	f022                	sd	s0,32(sp)
    80002e4a:	ec26                	sd	s1,24(sp)
    80002e4c:	e84a                	sd	s2,16(sp)
    80002e4e:	e44e                	sd	s3,8(sp)
    80002e50:	e052                	sd	s4,0(sp)
    80002e52:	1800                	addi	s0,sp,48
    80002e54:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002e56:	00010497          	auipc	s1,0x10
    80002e5a:	8d248493          	addi	s1,s1,-1838 # 80012728 <proc>
      pp->parent = initproc;
    80002e5e:	00007a17          	auipc	s4,0x7
    80002e62:	202a0a13          	addi	s4,s4,514 # 8000a060 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002e66:	00016997          	auipc	s3,0x16
    80002e6a:	cc298993          	addi	s3,s3,-830 # 80018b28 <tickslock>
    80002e6e:	a029                	j	80002e78 <reparent+0x34>
    80002e70:	19048493          	addi	s1,s1,400
    80002e74:	01348d63          	beq	s1,s3,80002e8e <reparent+0x4a>
    if(pp->parent == p){
    80002e78:	60bc                	ld	a5,64(s1)
    80002e7a:	ff279be3          	bne	a5,s2,80002e70 <reparent+0x2c>
      pp->parent = initproc;
    80002e7e:	000a3503          	ld	a0,0(s4)
    80002e82:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	efe080e7          	jalr	-258(ra) # 80002d82 <wakeup>
    80002e8c:	b7d5                	j	80002e70 <reparent+0x2c>
}
    80002e8e:	70a2                	ld	ra,40(sp)
    80002e90:	7402                	ld	s0,32(sp)
    80002e92:	64e2                	ld	s1,24(sp)
    80002e94:	6942                	ld	s2,16(sp)
    80002e96:	69a2                	ld	s3,8(sp)
    80002e98:	6a02                	ld	s4,0(sp)
    80002e9a:	6145                	addi	sp,sp,48
    80002e9c:	8082                	ret

0000000080002e9e <exit>:
{
    80002e9e:	7179                	addi	sp,sp,-48
    80002ea0:	f406                	sd	ra,40(sp)
    80002ea2:	f022                	sd	s0,32(sp)
    80002ea4:	ec26                	sd	s1,24(sp)
    80002ea6:	e84a                	sd	s2,16(sp)
    80002ea8:	e44e                	sd	s3,8(sp)
    80002eaa:	e052                	sd	s4,0(sp)
    80002eac:	1800                	addi	s0,sp,48
    80002eae:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	b4e080e7          	jalr	-1202(ra) # 800019fe <myproc>
    80002eb8:	892a                	mv	s2,a0
  if(p == initproc)
    80002eba:	00007797          	auipc	a5,0x7
    80002ebe:	1a67b783          	ld	a5,422(a5) # 8000a060 <initproc>
    80002ec2:	0d850493          	addi	s1,a0,216
    80002ec6:	15850993          	addi	s3,a0,344
    80002eca:	02a79363          	bne	a5,a0,80002ef0 <exit+0x52>
    panic("init exiting");
    80002ece:	00006517          	auipc	a0,0x6
    80002ed2:	3b250513          	addi	a0,a0,946 # 80009280 <digits+0x240>
    80002ed6:	ffffd097          	auipc	ra,0xffffd
    80002eda:	664080e7          	jalr	1636(ra) # 8000053a <panic>
      fileclose(f);
    80002ede:	00003097          	auipc	ra,0x3
    80002ee2:	1c0080e7          	jalr	448(ra) # 8000609e <fileclose>
      p->ofile[fd] = 0;
    80002ee6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002eea:	04a1                	addi	s1,s1,8
    80002eec:	01348563          	beq	s1,s3,80002ef6 <exit+0x58>
    if(p->ofile[fd]){
    80002ef0:	6088                	ld	a0,0(s1)
    80002ef2:	f575                	bnez	a0,80002ede <exit+0x40>
    80002ef4:	bfdd                	j	80002eea <exit+0x4c>
  begin_op();
    80002ef6:	00003097          	auipc	ra,0x3
    80002efa:	ce0080e7          	jalr	-800(ra) # 80005bd6 <begin_op>
  iput(p->cwd);
    80002efe:	15893503          	ld	a0,344(s2)
    80002f02:	00002097          	auipc	ra,0x2
    80002f06:	4b2080e7          	jalr	1202(ra) # 800053b4 <iput>
  end_op();
    80002f0a:	00003097          	auipc	ra,0x3
    80002f0e:	d4a080e7          	jalr	-694(ra) # 80005c54 <end_op>
  p->cwd = 0;
    80002f12:	14093c23          	sd	zero,344(s2)
  acquire(&wait_lock);
    80002f16:	0000f497          	auipc	s1,0xf
    80002f1a:	3e248493          	addi	s1,s1,994 # 800122f8 <wait_lock>
    80002f1e:	8526                	mv	a0,s1
    80002f20:	ffffe097          	auipc	ra,0xffffe
    80002f24:	cb0080e7          	jalr	-848(ra) # 80000bd0 <acquire>
  reparent(p);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	00000097          	auipc	ra,0x0
    80002f2e:	f1a080e7          	jalr	-230(ra) # 80002e44 <reparent>
  wakeup(p->parent);
    80002f32:	04093503          	ld	a0,64(s2)
    80002f36:	00000097          	auipc	ra,0x0
    80002f3a:	e4c080e7          	jalr	-436(ra) # 80002d82 <wakeup>
  acquire(&p->lock);
    80002f3e:	854a                	mv	a0,s2
    80002f40:	ffffe097          	auipc	ra,0xffffe
    80002f44:	c90080e7          	jalr	-880(ra) # 80000bd0 <acquire>
  p->xstate = status;
    80002f48:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80002f4c:	4795                	li	a5,5
    80002f4e:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002f52:	8526                	mv	a0,s1
    80002f54:	ffffe097          	auipc	ra,0xffffe
    80002f58:	d30080e7          	jalr	-720(ra) # 80000c84 <release>
  acquire(&tickslock);
    80002f5c:	00016517          	auipc	a0,0x16
    80002f60:	bcc50513          	addi	a0,a0,-1076 # 80018b28 <tickslock>
    80002f64:	ffffe097          	auipc	ra,0xffffe
    80002f68:	c6c080e7          	jalr	-916(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002f6c:	00007497          	auipc	s1,0x7
    80002f70:	1004a483          	lw	s1,256(s1) # 8000a06c <ticks>
  release(&tickslock);
    80002f74:	00016517          	auipc	a0,0x16
    80002f78:	bb450513          	addi	a0,a0,-1100 # 80018b28 <tickslock>
    80002f7c:	ffffe097          	auipc	ra,0xffffe
    80002f80:	d08080e7          	jalr	-760(ra) # 80000c84 <release>
  p->endtime = xticks;
    80002f84:	0004879b          	sext.w	a5,s1
    80002f88:	16f92c23          	sw	a5,376(s2)
  if (p->is_batchproc) {
    80002f8c:	03c92703          	lw	a4,60(s2)
    80002f90:	16070763          	beqz	a4,800030fe <exit+0x260>
     if ((xticks - p->burst_start) > 0) {
    80002f94:	18492603          	lw	a2,388(s2)
    80002f98:	0e960063          	beq	a2,s1,80003078 <exit+0x1da>
        num_cpubursts++;
    80002f9c:	00007697          	auipc	a3,0x7
    80002fa0:	0a868693          	addi	a3,a3,168 # 8000a044 <num_cpubursts>
    80002fa4:	4298                	lw	a4,0(a3)
    80002fa6:	2705                	addiw	a4,a4,1
    80002fa8:	c298                	sw	a4,0(a3)
        cpubursts_tot += (xticks - p->burst_start);
    80002faa:	40c486bb          	subw	a3,s1,a2
    80002fae:	0006859b          	sext.w	a1,a3
    80002fb2:	00007517          	auipc	a0,0x7
    80002fb6:	08e50513          	addi	a0,a0,142 # 8000a040 <cpubursts_tot>
    80002fba:	4118                	lw	a4,0(a0)
    80002fbc:	9f35                	addw	a4,a4,a3
    80002fbe:	c118                	sw	a4,0(a0)
        if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002fc0:	00007717          	auipc	a4,0x7
    80002fc4:	07c72703          	lw	a4,124(a4) # 8000a03c <cpubursts_max>
    80002fc8:	00b77663          	bgeu	a4,a1,80002fd4 <exit+0x136>
    80002fcc:	00007717          	auipc	a4,0x7
    80002fd0:	06d72823          	sw	a3,112(a4) # 8000a03c <cpubursts_max>
        if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002fd4:	00007717          	auipc	a4,0x7
    80002fd8:	c0472703          	lw	a4,-1020(a4) # 80009bd8 <cpubursts_min>
    80002fdc:	00e5f663          	bgeu	a1,a4,80002fe8 <exit+0x14a>
    80002fe0:	00007717          	auipc	a4,0x7
    80002fe4:	bed72c23          	sw	a3,-1032(a4) # 80009bd8 <cpubursts_min>
        if (p->nextburst_estimate > 0) {
    80002fe8:	18892703          	lw	a4,392(s2)
    80002fec:	02e05763          	blez	a4,8000301a <exit+0x17c>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002ff0:	0007051b          	sext.w	a0,a4
    80002ff4:	12b56163          	bltu	a0,a1,80003116 <exit+0x278>
    80002ff8:	9e29                	addw	a2,a2,a0
    80002ffa:	4096053b          	subw	a0,a2,s1
    80002ffe:	00007597          	auipc	a1,0x7
    80003002:	02e58593          	addi	a1,a1,46 # 8000a02c <estimation_error>
    80003006:	4190                	lw	a2,0(a1)
    80003008:	9e29                	addw	a2,a2,a0
    8000300a:	c190                	sw	a2,0(a1)
           estimation_error_instance++;
    8000300c:	00007597          	auipc	a1,0x7
    80003010:	01c58593          	addi	a1,a1,28 # 8000a028 <estimation_error_instance>
    80003014:	4190                	lw	a2,0(a1)
    80003016:	2605                	addiw	a2,a2,1
    80003018:	c190                	sw	a2,0(a1)
        p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    8000301a:	4609                	li	a2,2
    8000301c:	02c7473b          	divw	a4,a4,a2
    80003020:	9f35                	addw	a4,a4,a3
    80003022:	0016d69b          	srliw	a3,a3,0x1
    80003026:	9f15                	subw	a4,a4,a3
    80003028:	0007069b          	sext.w	a3,a4
    8000302c:	18e92423          	sw	a4,392(s2)
        if (p->nextburst_estimate > 0) {
    80003030:	04d05463          	blez	a3,80003078 <exit+0x1da>
           num_cpubursts_est++;
    80003034:	00007597          	auipc	a1,0x7
    80003038:	00458593          	addi	a1,a1,4 # 8000a038 <num_cpubursts_est>
    8000303c:	4190                	lw	a2,0(a1)
    8000303e:	2605                	addiw	a2,a2,1
    80003040:	c190                	sw	a2,0(a1)
           cpubursts_est_tot += p->nextburst_estimate;
    80003042:	00007597          	auipc	a1,0x7
    80003046:	ff258593          	addi	a1,a1,-14 # 8000a034 <cpubursts_est_tot>
    8000304a:	4190                	lw	a2,0(a1)
    8000304c:	9e39                	addw	a2,a2,a4
    8000304e:	c190                	sw	a2,0(a1)
           if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80003050:	00007617          	auipc	a2,0x7
    80003054:	fe062603          	lw	a2,-32(a2) # 8000a030 <cpubursts_est_max>
    80003058:	00d65663          	bge	a2,a3,80003064 <exit+0x1c6>
    8000305c:	00007617          	auipc	a2,0x7
    80003060:	fce62a23          	sw	a4,-44(a2) # 8000a030 <cpubursts_est_max>
           if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80003064:	00007617          	auipc	a2,0x7
    80003068:	b7062603          	lw	a2,-1168(a2) # 80009bd4 <cpubursts_est_min>
    8000306c:	00c6d663          	bge	a3,a2,80003078 <exit+0x1da>
    80003070:	00007697          	auipc	a3,0x7
    80003074:	b6e6a223          	sw	a4,-1180(a3) # 80009bd4 <cpubursts_est_min>
     if (p->stime < batch_start) batch_start = p->stime;
    80003078:	17492703          	lw	a4,372(s2)
    8000307c:	00007697          	auipc	a3,0x7
    80003080:	b646a683          	lw	a3,-1180(a3) # 80009be0 <batch_start>
    80003084:	00d75663          	bge	a4,a3,80003090 <exit+0x1f2>
    80003088:	00007697          	auipc	a3,0x7
    8000308c:	b4e6ac23          	sw	a4,-1192(a3) # 80009be0 <batch_start>
     batchsize--;
    80003090:	00007617          	auipc	a2,0x7
    80003094:	fcc60613          	addi	a2,a2,-52 # 8000a05c <batchsize>
    80003098:	4214                	lw	a3,0(a2)
    8000309a:	36fd                	addiw	a3,a3,-1
    8000309c:	0006859b          	sext.w	a1,a3
    800030a0:	c214                	sw	a3,0(a2)
     turnaround += (p->endtime - p->stime);
    800030a2:	00007697          	auipc	a3,0x7
    800030a6:	fb268693          	addi	a3,a3,-78 # 8000a054 <turnaround>
    800030aa:	40e7873b          	subw	a4,a5,a4
    800030ae:	4290                	lw	a2,0(a3)
    800030b0:	9f31                	addw	a4,a4,a2
    800030b2:	c298                	sw	a4,0(a3)
     waiting_tot += p->waittime;
    800030b4:	00007697          	auipc	a3,0x7
    800030b8:	f9868693          	addi	a3,a3,-104 # 8000a04c <waiting_tot>
    800030bc:	17c92603          	lw	a2,380(s2)
    800030c0:	4298                	lw	a4,0(a3)
    800030c2:	9f31                	addw	a4,a4,a2
    800030c4:	c298                	sw	a4,0(a3)
     completion_tot += p->endtime;
    800030c6:	00007697          	auipc	a3,0x7
    800030ca:	f8a68693          	addi	a3,a3,-118 # 8000a050 <completion_tot>
    800030ce:	4298                	lw	a4,0(a3)
    800030d0:	9f3d                	addw	a4,a4,a5
    800030d2:	c298                	sw	a4,0(a3)
     if (p->endtime > completion_max) completion_max = p->endtime;
    800030d4:	00007717          	auipc	a4,0x7
    800030d8:	f7472703          	lw	a4,-140(a4) # 8000a048 <completion_max>
    800030dc:	00f75663          	bge	a4,a5,800030e8 <exit+0x24a>
    800030e0:	00007717          	auipc	a4,0x7
    800030e4:	f6f72423          	sw	a5,-152(a4) # 8000a048 <completion_max>
     if (p->endtime < completion_min) completion_min = p->endtime;
    800030e8:	00007717          	auipc	a4,0x7
    800030ec:	af472703          	lw	a4,-1292(a4) # 80009bdc <completion_min>
    800030f0:	00e7d663          	bge	a5,a4,800030fc <exit+0x25e>
    800030f4:	00007717          	auipc	a4,0x7
    800030f8:	aef72423          	sw	a5,-1304(a4) # 80009bdc <completion_min>
     if (batchsize == 0) {
    800030fc:	c185                	beqz	a1,8000311c <exit+0x27e>
  sched();
    800030fe:	fffff097          	auipc	ra,0xfffff
    80003102:	470080e7          	jalr	1136(ra) # 8000256e <sched>
  panic("zombie exit");
    80003106:	00006517          	auipc	a0,0x6
    8000310a:	2c250513          	addi	a0,a0,706 # 800093c8 <digits+0x388>
    8000310e:	ffffd097          	auipc	ra,0xffffd
    80003112:	42c080e7          	jalr	1068(ra) # 8000053a <panic>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80003116:	40a6853b          	subw	a0,a3,a0
    8000311a:	b5d5                	j	80002ffe <exit+0x160>
        printf("\nBatch execution time: %d\n", p->endtime - batch_start);
    8000311c:	00007597          	auipc	a1,0x7
    80003120:	ac45a583          	lw	a1,-1340(a1) # 80009be0 <batch_start>
    80003124:	40b785bb          	subw	a1,a5,a1
    80003128:	00006517          	auipc	a0,0x6
    8000312c:	16850513          	addi	a0,a0,360 # 80009290 <digits+0x250>
    80003130:	ffffd097          	auipc	ra,0xffffd
    80003134:	454080e7          	jalr	1108(ra) # 80000584 <printf>
	printf("Average turn-around time: %d\n", turnaround/batchsize2);
    80003138:	00007497          	auipc	s1,0x7
    8000313c:	f2048493          	addi	s1,s1,-224 # 8000a058 <batchsize2>
    80003140:	00007597          	auipc	a1,0x7
    80003144:	f145a583          	lw	a1,-236(a1) # 8000a054 <turnaround>
    80003148:	409c                	lw	a5,0(s1)
    8000314a:	02f5c5bb          	divw	a1,a1,a5
    8000314e:	00006517          	auipc	a0,0x6
    80003152:	16250513          	addi	a0,a0,354 # 800092b0 <digits+0x270>
    80003156:	ffffd097          	auipc	ra,0xffffd
    8000315a:	42e080e7          	jalr	1070(ra) # 80000584 <printf>
	printf("Average waiting time: %d\n", waiting_tot/batchsize2);
    8000315e:	00007597          	auipc	a1,0x7
    80003162:	eee5a583          	lw	a1,-274(a1) # 8000a04c <waiting_tot>
    80003166:	409c                	lw	a5,0(s1)
    80003168:	02f5c5bb          	divw	a1,a1,a5
    8000316c:	00006517          	auipc	a0,0x6
    80003170:	16450513          	addi	a0,a0,356 # 800092d0 <digits+0x290>
    80003174:	ffffd097          	auipc	ra,0xffffd
    80003178:	410080e7          	jalr	1040(ra) # 80000584 <printf>
	printf("Completion time: avg: %d, max: %d, min: %d\n", completion_tot/batchsize2, completion_max, completion_min);
    8000317c:	00007597          	auipc	a1,0x7
    80003180:	ed45a583          	lw	a1,-300(a1) # 8000a050 <completion_tot>
    80003184:	409c                	lw	a5,0(s1)
    80003186:	00007697          	auipc	a3,0x7
    8000318a:	a566a683          	lw	a3,-1450(a3) # 80009bdc <completion_min>
    8000318e:	00007617          	auipc	a2,0x7
    80003192:	eba62603          	lw	a2,-326(a2) # 8000a048 <completion_max>
    80003196:	02f5c5bb          	divw	a1,a1,a5
    8000319a:	00006517          	auipc	a0,0x6
    8000319e:	15650513          	addi	a0,a0,342 # 800092f0 <digits+0x2b0>
    800031a2:	ffffd097          	auipc	ra,0xffffd
    800031a6:	3e2080e7          	jalr	994(ra) # 80000584 <printf>
	if ((sched_policy == SCHED_NPREEMPT_FCFS) || (sched_policy == SCHED_NPREEMPT_SJF)) {
    800031aa:	00007717          	auipc	a4,0x7
    800031ae:	ebe72703          	lw	a4,-322(a4) # 8000a068 <sched_policy>
    800031b2:	4785                	li	a5,1
    800031b4:	08e7fb63          	bgeu	a5,a4,8000324a <exit+0x3ac>
	batchsize2 = 0;
    800031b8:	00007797          	auipc	a5,0x7
    800031bc:	ea07a023          	sw	zero,-352(a5) # 8000a058 <batchsize2>
	batch_start = 0x7FFFFFFF;
    800031c0:	800007b7          	lui	a5,0x80000
    800031c4:	fff7c793          	not	a5,a5
    800031c8:	00007717          	auipc	a4,0x7
    800031cc:	a0f72c23          	sw	a5,-1512(a4) # 80009be0 <batch_start>
	turnaround = 0;
    800031d0:	00007717          	auipc	a4,0x7
    800031d4:	e8072223          	sw	zero,-380(a4) # 8000a054 <turnaround>
	waiting_tot = 0;
    800031d8:	00007717          	auipc	a4,0x7
    800031dc:	e6072a23          	sw	zero,-396(a4) # 8000a04c <waiting_tot>
	completion_tot = 0;
    800031e0:	00007717          	auipc	a4,0x7
    800031e4:	e6072823          	sw	zero,-400(a4) # 8000a050 <completion_tot>
	completion_max = 0;
    800031e8:	00007717          	auipc	a4,0x7
    800031ec:	e6072023          	sw	zero,-416(a4) # 8000a048 <completion_max>
	completion_min = 0x7FFFFFFF;
    800031f0:	00007717          	auipc	a4,0x7
    800031f4:	9ef72623          	sw	a5,-1556(a4) # 80009bdc <completion_min>
	num_cpubursts = 0;
    800031f8:	00007717          	auipc	a4,0x7
    800031fc:	e4072623          	sw	zero,-436(a4) # 8000a044 <num_cpubursts>
        cpubursts_tot = 0;
    80003200:	00007717          	auipc	a4,0x7
    80003204:	e4072023          	sw	zero,-448(a4) # 8000a040 <cpubursts_tot>
        cpubursts_max = 0;
    80003208:	00007717          	auipc	a4,0x7
    8000320c:	e2072a23          	sw	zero,-460(a4) # 8000a03c <cpubursts_max>
        cpubursts_min = 0x7FFFFFFF;
    80003210:	00007717          	auipc	a4,0x7
    80003214:	9cf72423          	sw	a5,-1592(a4) # 80009bd8 <cpubursts_min>
	num_cpubursts_est = 0;
    80003218:	00007717          	auipc	a4,0x7
    8000321c:	e2072023          	sw	zero,-480(a4) # 8000a038 <num_cpubursts_est>
        cpubursts_est_tot = 0;
    80003220:	00007717          	auipc	a4,0x7
    80003224:	e0072a23          	sw	zero,-492(a4) # 8000a034 <cpubursts_est_tot>
        cpubursts_est_max = 0;
    80003228:	00007717          	auipc	a4,0x7
    8000322c:	e0072423          	sw	zero,-504(a4) # 8000a030 <cpubursts_est_max>
        cpubursts_est_min = 0x7FFFFFFF;
    80003230:	00007717          	auipc	a4,0x7
    80003234:	9af72223          	sw	a5,-1628(a4) # 80009bd4 <cpubursts_est_min>
	estimation_error = 0;
    80003238:	00007797          	auipc	a5,0x7
    8000323c:	de07aa23          	sw	zero,-524(a5) # 8000a02c <estimation_error>
        estimation_error_instance = 0;
    80003240:	00007797          	auipc	a5,0x7
    80003244:	de07a423          	sw	zero,-536(a5) # 8000a028 <estimation_error_instance>
    80003248:	bd5d                	j	800030fe <exit+0x260>
	   printf("CPU bursts: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts, cpubursts_tot/num_cpubursts, cpubursts_max, cpubursts_min);
    8000324a:	00007597          	auipc	a1,0x7
    8000324e:	dfa5a583          	lw	a1,-518(a1) # 8000a044 <num_cpubursts>
    80003252:	00007617          	auipc	a2,0x7
    80003256:	dee62603          	lw	a2,-530(a2) # 8000a040 <cpubursts_tot>
    8000325a:	00007717          	auipc	a4,0x7
    8000325e:	97e72703          	lw	a4,-1666(a4) # 80009bd8 <cpubursts_min>
    80003262:	00007697          	auipc	a3,0x7
    80003266:	dda6a683          	lw	a3,-550(a3) # 8000a03c <cpubursts_max>
    8000326a:	02b6463b          	divw	a2,a2,a1
    8000326e:	00006517          	auipc	a0,0x6
    80003272:	0b250513          	addi	a0,a0,178 # 80009320 <digits+0x2e0>
    80003276:	ffffd097          	auipc	ra,0xffffd
    8000327a:	30e080e7          	jalr	782(ra) # 80000584 <printf>
	   printf("CPU burst estimates: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts_est, cpubursts_est_tot/num_cpubursts_est, cpubursts_est_max, cpubursts_est_min);
    8000327e:	00007597          	auipc	a1,0x7
    80003282:	dba5a583          	lw	a1,-582(a1) # 8000a038 <num_cpubursts_est>
    80003286:	00007617          	auipc	a2,0x7
    8000328a:	dae62603          	lw	a2,-594(a2) # 8000a034 <cpubursts_est_tot>
    8000328e:	00007717          	auipc	a4,0x7
    80003292:	94672703          	lw	a4,-1722(a4) # 80009bd4 <cpubursts_est_min>
    80003296:	00007697          	auipc	a3,0x7
    8000329a:	d9a6a683          	lw	a3,-614(a3) # 8000a030 <cpubursts_est_max>
    8000329e:	02b6463b          	divw	a2,a2,a1
    800032a2:	00006517          	auipc	a0,0x6
    800032a6:	0b650513          	addi	a0,a0,182 # 80009358 <digits+0x318>
    800032aa:	ffffd097          	auipc	ra,0xffffd
    800032ae:	2da080e7          	jalr	730(ra) # 80000584 <printf>
	   printf("CPU burst estimation error: count: %d, avg: %d\n", estimation_error_instance, estimation_error/estimation_error_instance);
    800032b2:	00007597          	auipc	a1,0x7
    800032b6:	d765a583          	lw	a1,-650(a1) # 8000a028 <estimation_error_instance>
    800032ba:	00007617          	auipc	a2,0x7
    800032be:	d7262603          	lw	a2,-654(a2) # 8000a02c <estimation_error>
    800032c2:	02b6463b          	divw	a2,a2,a1
    800032c6:	00006517          	auipc	a0,0x6
    800032ca:	0d250513          	addi	a0,a0,210 # 80009398 <digits+0x358>
    800032ce:	ffffd097          	auipc	ra,0xffffd
    800032d2:	2b6080e7          	jalr	694(ra) # 80000584 <printf>
    800032d6:	b5cd                	j	800031b8 <exit+0x31a>

00000000800032d8 <wakeupone>:

// Wake up one processes sleeping on chan.
// Must be called without any p->lock.
void
wakeupone(void *chan)
{
    800032d8:	7139                	addi	sp,sp,-64
    800032da:	fc06                	sd	ra,56(sp)
    800032dc:	f822                	sd	s0,48(sp)
    800032de:	f426                	sd	s1,40(sp)
    800032e0:	f04a                	sd	s2,32(sp)
    800032e2:	ec4e                	sd	s3,24(sp)
    800032e4:	e852                	sd	s4,16(sp)
    800032e6:	e456                	sd	s5,8(sp)
    800032e8:	0080                	addi	s0,sp,64
    800032ea:	8a2a                	mv	s4,a0
  struct proc *p;
  uint xticks;

  if (!holding(&tickslock)) {
    800032ec:	00016517          	auipc	a0,0x16
    800032f0:	83c50513          	addi	a0,a0,-1988 # 80018b28 <tickslock>
    800032f4:	ffffe097          	auipc	ra,0xffffe
    800032f8:	862080e7          	jalr	-1950(ra) # 80000b56 <holding>
    800032fc:	cd19                	beqz	a0,8000331a <wakeupone+0x42>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    800032fe:	00007a97          	auipc	s5,0x7
    80003302:	d6eaaa83          	lw	s5,-658(s5) # 8000a06c <ticks>

  int waken=0;
  for(p = proc; p < &proc[NPROC]; p++) {
    80003306:	0000f497          	auipc	s1,0xf
    8000330a:	42248493          	addi	s1,s1,1058 # 80012728 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000330e:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80003310:	00016917          	auipc	s2,0x16
    80003314:	81890913          	addi	s2,s2,-2024 # 80018b28 <tickslock>
    80003318:	a83d                	j	80003356 <wakeupone+0x7e>
     acquire(&tickslock);
    8000331a:	00016517          	auipc	a0,0x16
    8000331e:	80e50513          	addi	a0,a0,-2034 # 80018b28 <tickslock>
    80003322:	ffffe097          	auipc	ra,0xffffe
    80003326:	8ae080e7          	jalr	-1874(ra) # 80000bd0 <acquire>
     xticks = ticks;
    8000332a:	00007a97          	auipc	s5,0x7
    8000332e:	d42aaa83          	lw	s5,-702(s5) # 8000a06c <ticks>
     release(&tickslock);
    80003332:	00015517          	auipc	a0,0x15
    80003336:	7f650513          	addi	a0,a0,2038 # 80018b28 <tickslock>
    8000333a:	ffffe097          	auipc	ra,0xffffe
    8000333e:	94a080e7          	jalr	-1718(ra) # 80000c84 <release>
    80003342:	b7d1                	j	80003306 <wakeupone+0x2e>
        p->state = RUNNABLE;
	      p->waitstart = xticks;
        waken = 1;
      }
      release(&p->lock);
    80003344:	8526                	mv	a0,s1
    80003346:	ffffe097          	auipc	ra,0xffffe
    8000334a:	93e080e7          	jalr	-1730(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000334e:	19048493          	addi	s1,s1,400
    80003352:	03248c63          	beq	s1,s2,8000338a <wakeupone+0xb2>
    if(p != myproc()){
    80003356:	ffffe097          	auipc	ra,0xffffe
    8000335a:	6a8080e7          	jalr	1704(ra) # 800019fe <myproc>
    8000335e:	fea488e3          	beq	s1,a0,8000334e <wakeupone+0x76>
      acquire(&p->lock);
    80003362:	8526                	mv	a0,s1
    80003364:	ffffe097          	auipc	ra,0xffffe
    80003368:	86c080e7          	jalr	-1940(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000336c:	4c9c                	lw	a5,24(s1)
    8000336e:	fd379be3          	bne	a5,s3,80003344 <wakeupone+0x6c>
    80003372:	709c                	ld	a5,32(s1)
    80003374:	fd4798e3          	bne	a5,s4,80003344 <wakeupone+0x6c>
        p->state = RUNNABLE;
    80003378:	478d                	li	a5,3
    8000337a:	cc9c                	sw	a5,24(s1)
	      p->waitstart = xticks;
    8000337c:	1954a023          	sw	s5,384(s1)
      release(&p->lock);
    80003380:	8526                	mv	a0,s1
    80003382:	ffffe097          	auipc	ra,0xffffe
    80003386:	902080e7          	jalr	-1790(ra) # 80000c84 <release>
      if(waken)
        break;
    }
  }
}
    8000338a:	70e2                	ld	ra,56(sp)
    8000338c:	7442                	ld	s0,48(sp)
    8000338e:	74a2                	ld	s1,40(sp)
    80003390:	7902                	ld	s2,32(sp)
    80003392:	69e2                	ld	s3,24(sp)
    80003394:	6a42                	ld	s4,16(sp)
    80003396:	6aa2                	ld	s5,8(sp)
    80003398:	6121                	addi	sp,sp,64
    8000339a:	8082                	ret

000000008000339c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000339c:	7179                	addi	sp,sp,-48
    8000339e:	f406                	sd	ra,40(sp)
    800033a0:	f022                	sd	s0,32(sp)
    800033a2:	ec26                	sd	s1,24(sp)
    800033a4:	e84a                	sd	s2,16(sp)
    800033a6:	e44e                	sd	s3,8(sp)
    800033a8:	e052                	sd	s4,0(sp)
    800033aa:	1800                	addi	s0,sp,48
    800033ac:	892a                	mv	s2,a0
  struct proc *p;
  uint xticks;

  acquire(&tickslock);
    800033ae:	00015517          	auipc	a0,0x15
    800033b2:	77a50513          	addi	a0,a0,1914 # 80018b28 <tickslock>
    800033b6:	ffffe097          	auipc	ra,0xffffe
    800033ba:	81a080e7          	jalr	-2022(ra) # 80000bd0 <acquire>
  xticks = ticks;
    800033be:	00007a17          	auipc	s4,0x7
    800033c2:	caea2a03          	lw	s4,-850(s4) # 8000a06c <ticks>
  release(&tickslock);
    800033c6:	00015517          	auipc	a0,0x15
    800033ca:	76250513          	addi	a0,a0,1890 # 80018b28 <tickslock>
    800033ce:	ffffe097          	auipc	ra,0xffffe
    800033d2:	8b6080e7          	jalr	-1866(ra) # 80000c84 <release>

  for(p = proc; p < &proc[NPROC]; p++){
    800033d6:	0000f497          	auipc	s1,0xf
    800033da:	35248493          	addi	s1,s1,850 # 80012728 <proc>
    800033de:	00015997          	auipc	s3,0x15
    800033e2:	74a98993          	addi	s3,s3,1866 # 80018b28 <tickslock>
    acquire(&p->lock);
    800033e6:	8526                	mv	a0,s1
    800033e8:	ffffd097          	auipc	ra,0xffffd
    800033ec:	7e8080e7          	jalr	2024(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    800033f0:	589c                	lw	a5,48(s1)
    800033f2:	01278d63          	beq	a5,s2,8000340c <kill+0x70>
	p->waitstart = xticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800033f6:	8526                	mv	a0,s1
    800033f8:	ffffe097          	auipc	ra,0xffffe
    800033fc:	88c080e7          	jalr	-1908(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80003400:	19048493          	addi	s1,s1,400
    80003404:	ff3491e3          	bne	s1,s3,800033e6 <kill+0x4a>
  }
  return -1;
    80003408:	557d                	li	a0,-1
    8000340a:	a829                	j	80003424 <kill+0x88>
      p->killed = 1;
    8000340c:	4785                	li	a5,1
    8000340e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80003410:	4c98                	lw	a4,24(s1)
    80003412:	4789                	li	a5,2
    80003414:	02f70063          	beq	a4,a5,80003434 <kill+0x98>
      release(&p->lock);
    80003418:	8526                	mv	a0,s1
    8000341a:	ffffe097          	auipc	ra,0xffffe
    8000341e:	86a080e7          	jalr	-1942(ra) # 80000c84 <release>
      return 0;
    80003422:	4501                	li	a0,0
}
    80003424:	70a2                	ld	ra,40(sp)
    80003426:	7402                	ld	s0,32(sp)
    80003428:	64e2                	ld	s1,24(sp)
    8000342a:	6942                	ld	s2,16(sp)
    8000342c:	69a2                	ld	s3,8(sp)
    8000342e:	6a02                	ld	s4,0(sp)
    80003430:	6145                	addi	sp,sp,48
    80003432:	8082                	ret
        p->state = RUNNABLE;
    80003434:	478d                	li	a5,3
    80003436:	cc9c                	sw	a5,24(s1)
	p->waitstart = xticks;
    80003438:	1944a023          	sw	s4,384(s1)
    8000343c:	bff1                	j	80003418 <kill+0x7c>

000000008000343e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000343e:	7179                	addi	sp,sp,-48
    80003440:	f406                	sd	ra,40(sp)
    80003442:	f022                	sd	s0,32(sp)
    80003444:	ec26                	sd	s1,24(sp)
    80003446:	e84a                	sd	s2,16(sp)
    80003448:	e44e                	sd	s3,8(sp)
    8000344a:	e052                	sd	s4,0(sp)
    8000344c:	1800                	addi	s0,sp,48
    8000344e:	84aa                	mv	s1,a0
    80003450:	892e                	mv	s2,a1
    80003452:	89b2                	mv	s3,a2
    80003454:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80003456:	ffffe097          	auipc	ra,0xffffe
    8000345a:	5a8080e7          	jalr	1448(ra) # 800019fe <myproc>
  if(user_dst){
    8000345e:	c08d                	beqz	s1,80003480 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80003460:	86d2                	mv	a3,s4
    80003462:	864e                	mv	a2,s3
    80003464:	85ca                	mv	a1,s2
    80003466:	6d28                	ld	a0,88(a0)
    80003468:	ffffe097          	auipc	ra,0xffffe
    8000346c:	242080e7          	jalr	578(ra) # 800016aa <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80003470:	70a2                	ld	ra,40(sp)
    80003472:	7402                	ld	s0,32(sp)
    80003474:	64e2                	ld	s1,24(sp)
    80003476:	6942                	ld	s2,16(sp)
    80003478:	69a2                	ld	s3,8(sp)
    8000347a:	6a02                	ld	s4,0(sp)
    8000347c:	6145                	addi	sp,sp,48
    8000347e:	8082                	ret
    memmove((char *)dst, src, len);
    80003480:	000a061b          	sext.w	a2,s4
    80003484:	85ce                	mv	a1,s3
    80003486:	854a                	mv	a0,s2
    80003488:	ffffe097          	auipc	ra,0xffffe
    8000348c:	8a0080e7          	jalr	-1888(ra) # 80000d28 <memmove>
    return 0;
    80003490:	8526                	mv	a0,s1
    80003492:	bff9                	j	80003470 <either_copyout+0x32>

0000000080003494 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80003494:	7179                	addi	sp,sp,-48
    80003496:	f406                	sd	ra,40(sp)
    80003498:	f022                	sd	s0,32(sp)
    8000349a:	ec26                	sd	s1,24(sp)
    8000349c:	e84a                	sd	s2,16(sp)
    8000349e:	e44e                	sd	s3,8(sp)
    800034a0:	e052                	sd	s4,0(sp)
    800034a2:	1800                	addi	s0,sp,48
    800034a4:	892a                	mv	s2,a0
    800034a6:	84ae                	mv	s1,a1
    800034a8:	89b2                	mv	s3,a2
    800034aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800034ac:	ffffe097          	auipc	ra,0xffffe
    800034b0:	552080e7          	jalr	1362(ra) # 800019fe <myproc>
  if(user_src){
    800034b4:	c08d                	beqz	s1,800034d6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800034b6:	86d2                	mv	a3,s4
    800034b8:	864e                	mv	a2,s3
    800034ba:	85ca                	mv	a1,s2
    800034bc:	6d28                	ld	a0,88(a0)
    800034be:	ffffe097          	auipc	ra,0xffffe
    800034c2:	278080e7          	jalr	632(ra) # 80001736 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800034c6:	70a2                	ld	ra,40(sp)
    800034c8:	7402                	ld	s0,32(sp)
    800034ca:	64e2                	ld	s1,24(sp)
    800034cc:	6942                	ld	s2,16(sp)
    800034ce:	69a2                	ld	s3,8(sp)
    800034d0:	6a02                	ld	s4,0(sp)
    800034d2:	6145                	addi	sp,sp,48
    800034d4:	8082                	ret
    memmove(dst, (char*)src, len);
    800034d6:	000a061b          	sext.w	a2,s4
    800034da:	85ce                	mv	a1,s3
    800034dc:	854a                	mv	a0,s2
    800034de:	ffffe097          	auipc	ra,0xffffe
    800034e2:	84a080e7          	jalr	-1974(ra) # 80000d28 <memmove>
    return 0;
    800034e6:	8526                	mv	a0,s1
    800034e8:	bff9                	j	800034c6 <either_copyin+0x32>

00000000800034ea <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800034ea:	715d                	addi	sp,sp,-80
    800034ec:	e486                	sd	ra,72(sp)
    800034ee:	e0a2                	sd	s0,64(sp)
    800034f0:	fc26                	sd	s1,56(sp)
    800034f2:	f84a                	sd	s2,48(sp)
    800034f4:	f44e                	sd	s3,40(sp)
    800034f6:	f052                	sd	s4,32(sp)
    800034f8:	ec56                	sd	s5,24(sp)
    800034fa:	e85a                	sd	s6,16(sp)
    800034fc:	e45e                	sd	s7,8(sp)
    800034fe:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80003500:	00006517          	auipc	a0,0x6
    80003504:	2b050513          	addi	a0,a0,688 # 800097b0 <syscalls+0x150>
    80003508:	ffffd097          	auipc	ra,0xffffd
    8000350c:	07c080e7          	jalr	124(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003510:	0000f497          	auipc	s1,0xf
    80003514:	37848493          	addi	s1,s1,888 # 80012888 <proc+0x160>
    80003518:	00015917          	auipc	s2,0x15
    8000351c:	77090913          	addi	s2,s2,1904 # 80018c88 <barriers+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003520:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80003522:	00006997          	auipc	s3,0x6
    80003526:	eb698993          	addi	s3,s3,-330 # 800093d8 <digits+0x398>
    printf("%d %s %s", p->pid, state, p->name);
    8000352a:	00006a97          	auipc	s5,0x6
    8000352e:	eb6a8a93          	addi	s5,s5,-330 # 800093e0 <digits+0x3a0>
    printf("\n");
    80003532:	00006a17          	auipc	s4,0x6
    80003536:	27ea0a13          	addi	s4,s4,638 # 800097b0 <syscalls+0x150>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000353a:	00006b97          	auipc	s7,0x6
    8000353e:	f3eb8b93          	addi	s7,s7,-194 # 80009478 <states.2>
    80003542:	a00d                	j	80003564 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80003544:	ed06a583          	lw	a1,-304(a3)
    80003548:	8556                	mv	a0,s5
    8000354a:	ffffd097          	auipc	ra,0xffffd
    8000354e:	03a080e7          	jalr	58(ra) # 80000584 <printf>
    printf("\n");
    80003552:	8552                	mv	a0,s4
    80003554:	ffffd097          	auipc	ra,0xffffd
    80003558:	030080e7          	jalr	48(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000355c:	19048493          	addi	s1,s1,400
    80003560:	03248263          	beq	s1,s2,80003584 <procdump+0x9a>
    if(p->state == UNUSED)
    80003564:	86a6                	mv	a3,s1
    80003566:	eb84a783          	lw	a5,-328(s1)
    8000356a:	dbed                	beqz	a5,8000355c <procdump+0x72>
      state = "???";
    8000356c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000356e:	fcfb6be3          	bltu	s6,a5,80003544 <procdump+0x5a>
    80003572:	02079713          	slli	a4,a5,0x20
    80003576:	01d75793          	srli	a5,a4,0x1d
    8000357a:	97de                	add	a5,a5,s7
    8000357c:	6390                	ld	a2,0(a5)
    8000357e:	f279                	bnez	a2,80003544 <procdump+0x5a>
      state = "???";
    80003580:	864e                	mv	a2,s3
    80003582:	b7c9                	j	80003544 <procdump+0x5a>
  }
}
    80003584:	60a6                	ld	ra,72(sp)
    80003586:	6406                	ld	s0,64(sp)
    80003588:	74e2                	ld	s1,56(sp)
    8000358a:	7942                	ld	s2,48(sp)
    8000358c:	79a2                	ld	s3,40(sp)
    8000358e:	7a02                	ld	s4,32(sp)
    80003590:	6ae2                	ld	s5,24(sp)
    80003592:	6b42                	ld	s6,16(sp)
    80003594:	6ba2                	ld	s7,8(sp)
    80003596:	6161                	addi	sp,sp,80
    80003598:	8082                	ret

000000008000359a <ps>:

// Print a process listing to console with proper locks held.
// Caution: don't invoke too often; can slow down the machine.
int
ps(void)
{
    8000359a:	7119                	addi	sp,sp,-128
    8000359c:	fc86                	sd	ra,120(sp)
    8000359e:	f8a2                	sd	s0,112(sp)
    800035a0:	f4a6                	sd	s1,104(sp)
    800035a2:	f0ca                	sd	s2,96(sp)
    800035a4:	ecce                	sd	s3,88(sp)
    800035a6:	e8d2                	sd	s4,80(sp)
    800035a8:	e4d6                	sd	s5,72(sp)
    800035aa:	e0da                	sd	s6,64(sp)
    800035ac:	fc5e                	sd	s7,56(sp)
    800035ae:	f862                	sd	s8,48(sp)
    800035b0:	f466                	sd	s9,40(sp)
    800035b2:	f06a                	sd	s10,32(sp)
    800035b4:	ec6e                	sd	s11,24(sp)
    800035b6:	0100                	addi	s0,sp,128
  struct proc *p;
  char *state;
  int ppid, pid;
  uint xticks;

  printf("\n");
    800035b8:	00006517          	auipc	a0,0x6
    800035bc:	1f850513          	addi	a0,a0,504 # 800097b0 <syscalls+0x150>
    800035c0:	ffffd097          	auipc	ra,0xffffd
    800035c4:	fc4080e7          	jalr	-60(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800035c8:	0000f497          	auipc	s1,0xf
    800035cc:	16048493          	addi	s1,s1,352 # 80012728 <proc>
    acquire(&p->lock);
    if(p->state == UNUSED) {
      release(&p->lock);
      continue;
    }
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800035d0:	4d95                	li	s11,5
    else
      state = "???";

    pid = p->pid;
    release(&p->lock);
    acquire(&wait_lock);
    800035d2:	0000fb97          	auipc	s7,0xf
    800035d6:	d26b8b93          	addi	s7,s7,-730 # 800122f8 <wait_lock>
    if (p->parent) {
       acquire(&p->parent->lock);
       ppid = p->parent->pid;
       release(&p->parent->lock);
    }
    else ppid = -1;
    800035da:	5b7d                	li	s6,-1
    release(&wait_lock);

    acquire(&tickslock);
    800035dc:	00015a97          	auipc	s5,0x15
    800035e0:	54ca8a93          	addi	s5,s5,1356 # 80018b28 <tickslock>
  for(p = proc; p < &proc[NPROC]; p++){
    800035e4:	00015d17          	auipc	s10,0x15
    800035e8:	544d0d13          	addi	s10,s10,1348 # 80018b28 <tickslock>
    800035ec:	a85d                	j	800036a2 <ps+0x108>
      release(&p->lock);
    800035ee:	8526                	mv	a0,s1
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	694080e7          	jalr	1684(ra) # 80000c84 <release>
      continue;
    800035f8:	a04d                	j	8000369a <ps+0x100>
    pid = p->pid;
    800035fa:	0304ac03          	lw	s8,48(s1)
    release(&p->lock);
    800035fe:	8526                	mv	a0,s1
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	684080e7          	jalr	1668(ra) # 80000c84 <release>
    acquire(&wait_lock);
    80003608:	855e                	mv	a0,s7
    8000360a:	ffffd097          	auipc	ra,0xffffd
    8000360e:	5c6080e7          	jalr	1478(ra) # 80000bd0 <acquire>
    if (p->parent) {
    80003612:	60a8                	ld	a0,64(s1)
    else ppid = -1;
    80003614:	8a5a                	mv	s4,s6
    if (p->parent) {
    80003616:	cd01                	beqz	a0,8000362e <ps+0x94>
       acquire(&p->parent->lock);
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	5b8080e7          	jalr	1464(ra) # 80000bd0 <acquire>
       ppid = p->parent->pid;
    80003620:	60a8                	ld	a0,64(s1)
    80003622:	03052a03          	lw	s4,48(a0)
       release(&p->parent->lock);
    80003626:	ffffd097          	auipc	ra,0xffffd
    8000362a:	65e080e7          	jalr	1630(ra) # 80000c84 <release>
    release(&wait_lock);
    8000362e:	855e                	mv	a0,s7
    80003630:	ffffd097          	auipc	ra,0xffffd
    80003634:	654080e7          	jalr	1620(ra) # 80000c84 <release>
    acquire(&tickslock);
    80003638:	8556                	mv	a0,s5
    8000363a:	ffffd097          	auipc	ra,0xffffd
    8000363e:	596080e7          	jalr	1430(ra) # 80000bd0 <acquire>
    xticks = ticks;
    80003642:	00007797          	auipc	a5,0x7
    80003646:	a2a78793          	addi	a5,a5,-1494 # 8000a06c <ticks>
    8000364a:	0007ac83          	lw	s9,0(a5)
    release(&tickslock);
    8000364e:	8556                	mv	a0,s5
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	634080e7          	jalr	1588(ra) # 80000c84 <release>

    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    80003658:	16090713          	addi	a4,s2,352
    8000365c:	1704a783          	lw	a5,368(s1)
    80003660:	1744a803          	lw	a6,372(s1)
    80003664:	1784a683          	lw	a3,376(s1)
    80003668:	410688bb          	subw	a7,a3,a6
    8000366c:	07668b63          	beq	a3,s6,800036e2 <ps+0x148>
    80003670:	68b4                	ld	a3,80(s1)
    80003672:	e036                	sd	a3,0(sp)
    80003674:	86ce                	mv	a3,s3
    80003676:	8652                	mv	a2,s4
    80003678:	85e2                	mv	a1,s8
    8000367a:	00006517          	auipc	a0,0x6
    8000367e:	d7650513          	addi	a0,a0,-650 # 800093f0 <digits+0x3b0>
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	f02080e7          	jalr	-254(ra) # 80000584 <printf>
    printf("\n");
    8000368a:	00006517          	auipc	a0,0x6
    8000368e:	12650513          	addi	a0,a0,294 # 800097b0 <syscalls+0x150>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	ef2080e7          	jalr	-270(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000369a:	19048493          	addi	s1,s1,400
    8000369e:	05a48563          	beq	s1,s10,800036e8 <ps+0x14e>
    acquire(&p->lock);
    800036a2:	8926                	mv	s2,s1
    800036a4:	8526                	mv	a0,s1
    800036a6:	ffffd097          	auipc	ra,0xffffd
    800036aa:	52a080e7          	jalr	1322(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    800036ae:	4c9c                	lw	a5,24(s1)
    800036b0:	df9d                	beqz	a5,800035ee <ps+0x54>
      state = "???";
    800036b2:	00006997          	auipc	s3,0x6
    800036b6:	d2698993          	addi	s3,s3,-730 # 800093d8 <digits+0x398>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800036ba:	f4fde0e3          	bltu	s11,a5,800035fa <ps+0x60>
    800036be:	02079713          	slli	a4,a5,0x20
    800036c2:	01d75793          	srli	a5,a4,0x1d
    800036c6:	00006717          	auipc	a4,0x6
    800036ca:	db270713          	addi	a4,a4,-590 # 80009478 <states.2>
    800036ce:	97ba                	add	a5,a5,a4
    800036d0:	0307b983          	ld	s3,48(a5)
    800036d4:	f20993e3          	bnez	s3,800035fa <ps+0x60>
      state = "???";
    800036d8:	00006997          	auipc	s3,0x6
    800036dc:	d0098993          	addi	s3,s3,-768 # 800093d8 <digits+0x398>
    800036e0:	bf29                	j	800035fa <ps+0x60>
    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    800036e2:	410c88bb          	subw	a7,s9,a6
    800036e6:	b769                	j	80003670 <ps+0xd6>
  }
  return 0;
}
    800036e8:	4501                	li	a0,0
    800036ea:	70e6                	ld	ra,120(sp)
    800036ec:	7446                	ld	s0,112(sp)
    800036ee:	74a6                	ld	s1,104(sp)
    800036f0:	7906                	ld	s2,96(sp)
    800036f2:	69e6                	ld	s3,88(sp)
    800036f4:	6a46                	ld	s4,80(sp)
    800036f6:	6aa6                	ld	s5,72(sp)
    800036f8:	6b06                	ld	s6,64(sp)
    800036fa:	7be2                	ld	s7,56(sp)
    800036fc:	7c42                	ld	s8,48(sp)
    800036fe:	7ca2                	ld	s9,40(sp)
    80003700:	7d02                	ld	s10,32(sp)
    80003702:	6de2                	ld	s11,24(sp)
    80003704:	6109                	addi	sp,sp,128
    80003706:	8082                	ret

0000000080003708 <pinfo>:

int
pinfo(int pid, uint64 addr)
{
    80003708:	7159                	addi	sp,sp,-112
    8000370a:	f486                	sd	ra,104(sp)
    8000370c:	f0a2                	sd	s0,96(sp)
    8000370e:	eca6                	sd	s1,88(sp)
    80003710:	e8ca                	sd	s2,80(sp)
    80003712:	e4ce                	sd	s3,72(sp)
    80003714:	e0d2                	sd	s4,64(sp)
    80003716:	1880                	addi	s0,sp,112
    80003718:	892a                	mv	s2,a0
    8000371a:	89ae                	mv	s3,a1
  struct proc *p;
  char *state;
  uint xticks;
  int found=0;

  if (pid == -1) {
    8000371c:	57fd                	li	a5,-1
     p = myproc();
     acquire(&p->lock);
     found=1;
  }
  else {
     for(p = proc; p < &proc[NPROC]; p++){
    8000371e:	0000f497          	auipc	s1,0xf
    80003722:	00a48493          	addi	s1,s1,10 # 80012728 <proc>
    80003726:	00015a17          	auipc	s4,0x15
    8000372a:	402a0a13          	addi	s4,s4,1026 # 80018b28 <tickslock>
  if (pid == -1) {
    8000372e:	02f51563          	bne	a0,a5,80003758 <pinfo+0x50>
     p = myproc();
    80003732:	ffffe097          	auipc	ra,0xffffe
    80003736:	2cc080e7          	jalr	716(ra) # 800019fe <myproc>
    8000373a:	84aa                	mv	s1,a0
     acquire(&p->lock);
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	494080e7          	jalr	1172(ra) # 80000bd0 <acquire>
         found=1;
         break;
       }
     }
  }
  if (found) {
    80003744:	a025                	j	8000376c <pinfo+0x64>
         release(&p->lock);
    80003746:	8526                	mv	a0,s1
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	53c080e7          	jalr	1340(ra) # 80000c84 <release>
     for(p = proc; p < &proc[NPROC]; p++){
    80003750:	19048493          	addi	s1,s1,400
    80003754:	13448e63          	beq	s1,s4,80003890 <pinfo+0x188>
       acquire(&p->lock);
    80003758:	8526                	mv	a0,s1
    8000375a:	ffffd097          	auipc	ra,0xffffd
    8000375e:	476080e7          	jalr	1142(ra) # 80000bd0 <acquire>
       if((p->state == UNUSED) || (p->pid != pid)) {
    80003762:	4c9c                	lw	a5,24(s1)
    80003764:	d3ed                	beqz	a5,80003746 <pinfo+0x3e>
    80003766:	589c                	lw	a5,48(s1)
    80003768:	fd279fe3          	bne	a5,s2,80003746 <pinfo+0x3e>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000376c:	4c9c                	lw	a5,24(s1)
    8000376e:	4715                	li	a4,5
         state = states[p->state];
     else
         state = "???";
    80003770:	00006917          	auipc	s2,0x6
    80003774:	c6890913          	addi	s2,s2,-920 # 800093d8 <digits+0x398>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003778:	00f76f63          	bltu	a4,a5,80003796 <pinfo+0x8e>
    8000377c:	02079713          	slli	a4,a5,0x20
    80003780:	01d75793          	srli	a5,a4,0x1d
    80003784:	00006717          	auipc	a4,0x6
    80003788:	cf470713          	addi	a4,a4,-780 # 80009478 <states.2>
    8000378c:	97ba                	add	a5,a5,a4
    8000378e:	0607b903          	ld	s2,96(a5)
    80003792:	10090163          	beqz	s2,80003894 <pinfo+0x18c>

     pstat.pid = p->pid;
    80003796:	589c                	lw	a5,48(s1)
    80003798:	f8f42c23          	sw	a5,-104(s0)
     release(&p->lock);
    8000379c:	8526                	mv	a0,s1
    8000379e:	ffffd097          	auipc	ra,0xffffd
    800037a2:	4e6080e7          	jalr	1254(ra) # 80000c84 <release>
     acquire(&wait_lock);
    800037a6:	0000f517          	auipc	a0,0xf
    800037aa:	b5250513          	addi	a0,a0,-1198 # 800122f8 <wait_lock>
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	422080e7          	jalr	1058(ra) # 80000bd0 <acquire>
     if (p->parent) {
    800037b6:	60a8                	ld	a0,64(s1)
    800037b8:	c17d                	beqz	a0,8000389e <pinfo+0x196>
        acquire(&p->parent->lock);
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	416080e7          	jalr	1046(ra) # 80000bd0 <acquire>
        pstat.ppid = p->parent->pid;
    800037c2:	60a8                	ld	a0,64(s1)
    800037c4:	591c                	lw	a5,48(a0)
    800037c6:	f8f42e23          	sw	a5,-100(s0)
        release(&p->parent->lock);
    800037ca:	ffffd097          	auipc	ra,0xffffd
    800037ce:	4ba080e7          	jalr	1210(ra) # 80000c84 <release>
     }
     else pstat.ppid = -1;
     release(&wait_lock);
    800037d2:	0000f517          	auipc	a0,0xf
    800037d6:	b2650513          	addi	a0,a0,-1242 # 800122f8 <wait_lock>
    800037da:	ffffd097          	auipc	ra,0xffffd
    800037de:	4aa080e7          	jalr	1194(ra) # 80000c84 <release>

     acquire(&tickslock);
    800037e2:	00015517          	auipc	a0,0x15
    800037e6:	34650513          	addi	a0,a0,838 # 80018b28 <tickslock>
    800037ea:	ffffd097          	auipc	ra,0xffffd
    800037ee:	3e6080e7          	jalr	998(ra) # 80000bd0 <acquire>
     xticks = ticks;
    800037f2:	00007a17          	auipc	s4,0x7
    800037f6:	87aa2a03          	lw	s4,-1926(s4) # 8000a06c <ticks>
     release(&tickslock);
    800037fa:	00015517          	auipc	a0,0x15
    800037fe:	32e50513          	addi	a0,a0,814 # 80018b28 <tickslock>
    80003802:	ffffd097          	auipc	ra,0xffffd
    80003806:	482080e7          	jalr	1154(ra) # 80000c84 <release>

     safestrcpy(&pstat.state[0], state, strlen(state)+1);
    8000380a:	854a                	mv	a0,s2
    8000380c:	ffffd097          	auipc	ra,0xffffd
    80003810:	63c080e7          	jalr	1596(ra) # 80000e48 <strlen>
    80003814:	0015061b          	addiw	a2,a0,1
    80003818:	85ca                	mv	a1,s2
    8000381a:	fa040513          	addi	a0,s0,-96
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	5f8080e7          	jalr	1528(ra) # 80000e16 <safestrcpy>
     safestrcpy(&pstat.command[0], &p->name[0], sizeof(p->name));
    80003826:	4641                	li	a2,16
    80003828:	16048593          	addi	a1,s1,352
    8000382c:	fa840513          	addi	a0,s0,-88
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	5e6080e7          	jalr	1510(ra) # 80000e16 <safestrcpy>
     pstat.ctime = p->ctime;
    80003838:	1704a783          	lw	a5,368(s1)
    8000383c:	faf42c23          	sw	a5,-72(s0)
     pstat.stime = p->stime;
    80003840:	1744a783          	lw	a5,372(s1)
    80003844:	faf42e23          	sw	a5,-68(s0)
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    80003848:	1784a703          	lw	a4,376(s1)
    8000384c:	567d                	li	a2,-1
    8000384e:	40f706bb          	subw	a3,a4,a5
    80003852:	04c70a63          	beq	a4,a2,800038a6 <pinfo+0x19e>
    80003856:	fcd42023          	sw	a3,-64(s0)
     pstat.size = p->sz;
    8000385a:	68bc                	ld	a5,80(s1)
    8000385c:	fcf43423          	sd	a5,-56(s0)
     if(copyout(myproc()->pagetable, addr, (char *)&pstat, sizeof(pstat)) < 0) return -1;
    80003860:	ffffe097          	auipc	ra,0xffffe
    80003864:	19e080e7          	jalr	414(ra) # 800019fe <myproc>
    80003868:	03800693          	li	a3,56
    8000386c:	f9840613          	addi	a2,s0,-104
    80003870:	85ce                	mv	a1,s3
    80003872:	6d28                	ld	a0,88(a0)
    80003874:	ffffe097          	auipc	ra,0xffffe
    80003878:	e36080e7          	jalr	-458(ra) # 800016aa <copyout>
    8000387c:	41f5551b          	sraiw	a0,a0,0x1f
     return 0;
  }
  else return -1;
}
    80003880:	70a6                	ld	ra,104(sp)
    80003882:	7406                	ld	s0,96(sp)
    80003884:	64e6                	ld	s1,88(sp)
    80003886:	6946                	ld	s2,80(sp)
    80003888:	69a6                	ld	s3,72(sp)
    8000388a:	6a06                	ld	s4,64(sp)
    8000388c:	6165                	addi	sp,sp,112
    8000388e:	8082                	ret
  else return -1;
    80003890:	557d                	li	a0,-1
    80003892:	b7fd                	j	80003880 <pinfo+0x178>
         state = "???";
    80003894:	00006917          	auipc	s2,0x6
    80003898:	b4490913          	addi	s2,s2,-1212 # 800093d8 <digits+0x398>
    8000389c:	bded                	j	80003796 <pinfo+0x8e>
     else pstat.ppid = -1;
    8000389e:	57fd                	li	a5,-1
    800038a0:	f8f42e23          	sw	a5,-100(s0)
    800038a4:	b73d                	j	800037d2 <pinfo+0xca>
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    800038a6:	40fa06bb          	subw	a3,s4,a5
    800038aa:	b775                	j	80003856 <pinfo+0x14e>

00000000800038ac <schedpolicy>:

int
schedpolicy(int x)
{
    800038ac:	1141                	addi	sp,sp,-16
    800038ae:	e422                	sd	s0,8(sp)
    800038b0:	0800                	addi	s0,sp,16
   int y = sched_policy;
    800038b2:	00006797          	auipc	a5,0x6
    800038b6:	7b678793          	addi	a5,a5,1974 # 8000a068 <sched_policy>
    800038ba:	4398                	lw	a4,0(a5)
   sched_policy = x;
    800038bc:	c388                	sw	a0,0(a5)
   return y;
}
    800038be:	853a                	mv	a0,a4
    800038c0:	6422                	ld	s0,8(sp)
    800038c2:	0141                	addi	sp,sp,16
    800038c4:	8082                	ret

00000000800038c6 <swtch>:
    800038c6:	00153023          	sd	ra,0(a0)
    800038ca:	00253423          	sd	sp,8(a0)
    800038ce:	e900                	sd	s0,16(a0)
    800038d0:	ed04                	sd	s1,24(a0)
    800038d2:	03253023          	sd	s2,32(a0)
    800038d6:	03353423          	sd	s3,40(a0)
    800038da:	03453823          	sd	s4,48(a0)
    800038de:	03553c23          	sd	s5,56(a0)
    800038e2:	05653023          	sd	s6,64(a0)
    800038e6:	05753423          	sd	s7,72(a0)
    800038ea:	05853823          	sd	s8,80(a0)
    800038ee:	05953c23          	sd	s9,88(a0)
    800038f2:	07a53023          	sd	s10,96(a0)
    800038f6:	07b53423          	sd	s11,104(a0)
    800038fa:	0005b083          	ld	ra,0(a1)
    800038fe:	0085b103          	ld	sp,8(a1)
    80003902:	6980                	ld	s0,16(a1)
    80003904:	6d84                	ld	s1,24(a1)
    80003906:	0205b903          	ld	s2,32(a1)
    8000390a:	0285b983          	ld	s3,40(a1)
    8000390e:	0305ba03          	ld	s4,48(a1)
    80003912:	0385ba83          	ld	s5,56(a1)
    80003916:	0405bb03          	ld	s6,64(a1)
    8000391a:	0485bb83          	ld	s7,72(a1)
    8000391e:	0505bc03          	ld	s8,80(a1)
    80003922:	0585bc83          	ld	s9,88(a1)
    80003926:	0605bd03          	ld	s10,96(a1)
    8000392a:	0685bd83          	ld	s11,104(a1)
    8000392e:	8082                	ret

0000000080003930 <trapinit>:

extern int sched_policy;

void
trapinit(void)
{
    80003930:	1141                	addi	sp,sp,-16
    80003932:	e406                	sd	ra,8(sp)
    80003934:	e022                	sd	s0,0(sp)
    80003936:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003938:	00006597          	auipc	a1,0x6
    8000393c:	bd058593          	addi	a1,a1,-1072 # 80009508 <states.0+0x30>
    80003940:	00015517          	auipc	a0,0x15
    80003944:	1e850513          	addi	a0,a0,488 # 80018b28 <tickslock>
    80003948:	ffffd097          	auipc	ra,0xffffd
    8000394c:	1f8080e7          	jalr	504(ra) # 80000b40 <initlock>
}
    80003950:	60a2                	ld	ra,8(sp)
    80003952:	6402                	ld	s0,0(sp)
    80003954:	0141                	addi	sp,sp,16
    80003956:	8082                	ret

0000000080003958 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003958:	1141                	addi	sp,sp,-16
    8000395a:	e422                	sd	s0,8(sp)
    8000395c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000395e:	00004797          	auipc	a5,0x4
    80003962:	d7278793          	addi	a5,a5,-654 # 800076d0 <kernelvec>
    80003966:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000396a:	6422                	ld	s0,8(sp)
    8000396c:	0141                	addi	sp,sp,16
    8000396e:	8082                	ret

0000000080003970 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80003970:	1141                	addi	sp,sp,-16
    80003972:	e406                	sd	ra,8(sp)
    80003974:	e022                	sd	s0,0(sp)
    80003976:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003978:	ffffe097          	auipc	ra,0xffffe
    8000397c:	086080e7          	jalr	134(ra) # 800019fe <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003980:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003984:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003986:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000398a:	00004697          	auipc	a3,0x4
    8000398e:	67668693          	addi	a3,a3,1654 # 80008000 <_trampoline>
    80003992:	00004717          	auipc	a4,0x4
    80003996:	66e70713          	addi	a4,a4,1646 # 80008000 <_trampoline>
    8000399a:	8f15                	sub	a4,a4,a3
    8000399c:	040007b7          	lui	a5,0x4000
    800039a0:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800039a2:	07b2                	slli	a5,a5,0xc
    800039a4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800039a6:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800039aa:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800039ac:	18002673          	csrr	a2,satp
    800039b0:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800039b2:	7130                	ld	a2,96(a0)
    800039b4:	6538                	ld	a4,72(a0)
    800039b6:	6585                	lui	a1,0x1
    800039b8:	972e                	add	a4,a4,a1
    800039ba:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800039bc:	7138                	ld	a4,96(a0)
    800039be:	00000617          	auipc	a2,0x0
    800039c2:	13860613          	addi	a2,a2,312 # 80003af6 <usertrap>
    800039c6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800039c8:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800039ca:	8612                	mv	a2,tp
    800039cc:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800039ce:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800039d2:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800039d6:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800039da:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800039de:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800039e0:	6f18                	ld	a4,24(a4)
    800039e2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800039e6:	6d2c                	ld	a1,88(a0)
    800039e8:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800039ea:	00004717          	auipc	a4,0x4
    800039ee:	6a670713          	addi	a4,a4,1702 # 80008090 <userret>
    800039f2:	8f15                	sub	a4,a4,a3
    800039f4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800039f6:	577d                	li	a4,-1
    800039f8:	177e                	slli	a4,a4,0x3f
    800039fa:	8dd9                	or	a1,a1,a4
    800039fc:	02000537          	lui	a0,0x2000
    80003a00:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80003a02:	0536                	slli	a0,a0,0xd
    80003a04:	9782                	jalr	a5
}
    80003a06:	60a2                	ld	ra,8(sp)
    80003a08:	6402                	ld	s0,0(sp)
    80003a0a:	0141                	addi	sp,sp,16
    80003a0c:	8082                	ret

0000000080003a0e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003a0e:	1101                	addi	sp,sp,-32
    80003a10:	ec06                	sd	ra,24(sp)
    80003a12:	e822                	sd	s0,16(sp)
    80003a14:	e426                	sd	s1,8(sp)
    80003a16:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003a18:	00015497          	auipc	s1,0x15
    80003a1c:	11048493          	addi	s1,s1,272 # 80018b28 <tickslock>
    80003a20:	8526                	mv	a0,s1
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	1ae080e7          	jalr	430(ra) # 80000bd0 <acquire>
  ticks++;
    80003a2a:	00006517          	auipc	a0,0x6
    80003a2e:	64250513          	addi	a0,a0,1602 # 8000a06c <ticks>
    80003a32:	411c                	lw	a5,0(a0)
    80003a34:	2785                	addiw	a5,a5,1
    80003a36:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003a38:	fffff097          	auipc	ra,0xfffff
    80003a3c:	34a080e7          	jalr	842(ra) # 80002d82 <wakeup>
  release(&tickslock);
    80003a40:	8526                	mv	a0,s1
    80003a42:	ffffd097          	auipc	ra,0xffffd
    80003a46:	242080e7          	jalr	578(ra) # 80000c84 <release>
}
    80003a4a:	60e2                	ld	ra,24(sp)
    80003a4c:	6442                	ld	s0,16(sp)
    80003a4e:	64a2                	ld	s1,8(sp)
    80003a50:	6105                	addi	sp,sp,32
    80003a52:	8082                	ret

0000000080003a54 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003a54:	1101                	addi	sp,sp,-32
    80003a56:	ec06                	sd	ra,24(sp)
    80003a58:	e822                	sd	s0,16(sp)
    80003a5a:	e426                	sd	s1,8(sp)
    80003a5c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003a5e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80003a62:	00074d63          	bltz	a4,80003a7c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003a66:	57fd                	li	a5,-1
    80003a68:	17fe                	slli	a5,a5,0x3f
    80003a6a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80003a6c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003a6e:	06f70363          	beq	a4,a5,80003ad4 <devintr+0x80>
  }
}
    80003a72:	60e2                	ld	ra,24(sp)
    80003a74:	6442                	ld	s0,16(sp)
    80003a76:	64a2                	ld	s1,8(sp)
    80003a78:	6105                	addi	sp,sp,32
    80003a7a:	8082                	ret
     (scause & 0xff) == 9){
    80003a7c:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80003a80:	46a5                	li	a3,9
    80003a82:	fed792e3          	bne	a5,a3,80003a66 <devintr+0x12>
    int irq = plic_claim();
    80003a86:	00004097          	auipc	ra,0x4
    80003a8a:	d52080e7          	jalr	-686(ra) # 800077d8 <plic_claim>
    80003a8e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003a90:	47a9                	li	a5,10
    80003a92:	02f50763          	beq	a0,a5,80003ac0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003a96:	4785                	li	a5,1
    80003a98:	02f50963          	beq	a0,a5,80003aca <devintr+0x76>
    return 1;
    80003a9c:	4505                	li	a0,1
    } else if(irq){
    80003a9e:	d8f1                	beqz	s1,80003a72 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003aa0:	85a6                	mv	a1,s1
    80003aa2:	00006517          	auipc	a0,0x6
    80003aa6:	a6e50513          	addi	a0,a0,-1426 # 80009510 <states.0+0x38>
    80003aaa:	ffffd097          	auipc	ra,0xffffd
    80003aae:	ada080e7          	jalr	-1318(ra) # 80000584 <printf>
      plic_complete(irq);
    80003ab2:	8526                	mv	a0,s1
    80003ab4:	00004097          	auipc	ra,0x4
    80003ab8:	d48080e7          	jalr	-696(ra) # 800077fc <plic_complete>
    return 1;
    80003abc:	4505                	li	a0,1
    80003abe:	bf55                	j	80003a72 <devintr+0x1e>
      uartintr();
    80003ac0:	ffffd097          	auipc	ra,0xffffd
    80003ac4:	ed2080e7          	jalr	-302(ra) # 80000992 <uartintr>
    80003ac8:	b7ed                	j	80003ab2 <devintr+0x5e>
      virtio_disk_intr();
    80003aca:	00004097          	auipc	ra,0x4
    80003ace:	1be080e7          	jalr	446(ra) # 80007c88 <virtio_disk_intr>
    80003ad2:	b7c5                	j	80003ab2 <devintr+0x5e>
    if(cpuid() == 0){
    80003ad4:	ffffe097          	auipc	ra,0xffffe
    80003ad8:	efe080e7          	jalr	-258(ra) # 800019d2 <cpuid>
    80003adc:	c901                	beqz	a0,80003aec <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003ade:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003ae2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003ae4:	14479073          	csrw	sip,a5
    return 2;
    80003ae8:	4509                	li	a0,2
    80003aea:	b761                	j	80003a72 <devintr+0x1e>
      clockintr();
    80003aec:	00000097          	auipc	ra,0x0
    80003af0:	f22080e7          	jalr	-222(ra) # 80003a0e <clockintr>
    80003af4:	b7ed                	j	80003ade <devintr+0x8a>

0000000080003af6 <usertrap>:
{
    80003af6:	1101                	addi	sp,sp,-32
    80003af8:	ec06                	sd	ra,24(sp)
    80003afa:	e822                	sd	s0,16(sp)
    80003afc:	e426                	sd	s1,8(sp)
    80003afe:	e04a                	sd	s2,0(sp)
    80003b00:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003b02:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003b06:	1007f793          	andi	a5,a5,256
    80003b0a:	e3ad                	bnez	a5,80003b6c <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003b0c:	00004797          	auipc	a5,0x4
    80003b10:	bc478793          	addi	a5,a5,-1084 # 800076d0 <kernelvec>
    80003b14:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003b18:	ffffe097          	auipc	ra,0xffffe
    80003b1c:	ee6080e7          	jalr	-282(ra) # 800019fe <myproc>
    80003b20:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003b22:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003b24:	14102773          	csrr	a4,sepc
    80003b28:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003b2a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003b2e:	47a1                	li	a5,8
    80003b30:	04f71c63          	bne	a4,a5,80003b88 <usertrap+0x92>
    if(p->killed)
    80003b34:	551c                	lw	a5,40(a0)
    80003b36:	e3b9                	bnez	a5,80003b7c <usertrap+0x86>
    p->trapframe->epc += 4;
    80003b38:	70b8                	ld	a4,96(s1)
    80003b3a:	6f1c                	ld	a5,24(a4)
    80003b3c:	0791                	addi	a5,a5,4
    80003b3e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003b40:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003b44:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003b48:	10079073          	csrw	sstatus,a5
    syscall();
    80003b4c:	00000097          	auipc	ra,0x0
    80003b50:	2fc080e7          	jalr	764(ra) # 80003e48 <syscall>
  if(p->killed)
    80003b54:	549c                	lw	a5,40(s1)
    80003b56:	efd9                	bnez	a5,80003bf4 <usertrap+0xfe>
  usertrapret();
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	e18080e7          	jalr	-488(ra) # 80003970 <usertrapret>
}
    80003b60:	60e2                	ld	ra,24(sp)
    80003b62:	6442                	ld	s0,16(sp)
    80003b64:	64a2                	ld	s1,8(sp)
    80003b66:	6902                	ld	s2,0(sp)
    80003b68:	6105                	addi	sp,sp,32
    80003b6a:	8082                	ret
    panic("usertrap: not from user mode");
    80003b6c:	00006517          	auipc	a0,0x6
    80003b70:	9c450513          	addi	a0,a0,-1596 # 80009530 <states.0+0x58>
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	9c6080e7          	jalr	-1594(ra) # 8000053a <panic>
      exit(-1);
    80003b7c:	557d                	li	a0,-1
    80003b7e:	fffff097          	auipc	ra,0xfffff
    80003b82:	320080e7          	jalr	800(ra) # 80002e9e <exit>
    80003b86:	bf4d                	j	80003b38 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	ecc080e7          	jalr	-308(ra) # 80003a54 <devintr>
    80003b90:	892a                	mv	s2,a0
    80003b92:	c501                	beqz	a0,80003b9a <usertrap+0xa4>
  if(p->killed)
    80003b94:	549c                	lw	a5,40(s1)
    80003b96:	c3a1                	beqz	a5,80003bd6 <usertrap+0xe0>
    80003b98:	a815                	j	80003bcc <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003b9a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003b9e:	5890                	lw	a2,48(s1)
    80003ba0:	00006517          	auipc	a0,0x6
    80003ba4:	9b050513          	addi	a0,a0,-1616 # 80009550 <states.0+0x78>
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	9dc080e7          	jalr	-1572(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003bb0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003bb4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003bb8:	00006517          	auipc	a0,0x6
    80003bbc:	9c850513          	addi	a0,a0,-1592 # 80009580 <states.0+0xa8>
    80003bc0:	ffffd097          	auipc	ra,0xffffd
    80003bc4:	9c4080e7          	jalr	-1596(ra) # 80000584 <printf>
    p->killed = 1;
    80003bc8:	4785                	li	a5,1
    80003bca:	d49c                	sw	a5,40(s1)
    exit(-1);
    80003bcc:	557d                	li	a0,-1
    80003bce:	fffff097          	auipc	ra,0xfffff
    80003bd2:	2d0080e7          	jalr	720(ra) # 80002e9e <exit>
  if(which_dev == 2) {
    80003bd6:	4789                	li	a5,2
    80003bd8:	f8f910e3          	bne	s2,a5,80003b58 <usertrap+0x62>
    if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    80003bdc:	00006717          	auipc	a4,0x6
    80003be0:	48c72703          	lw	a4,1164(a4) # 8000a068 <sched_policy>
    80003be4:	4785                	li	a5,1
    80003be6:	f6e7f9e3          	bgeu	a5,a4,80003b58 <usertrap+0x62>
    80003bea:	fffff097          	auipc	ra,0xfffff
    80003bee:	a5a080e7          	jalr	-1446(ra) # 80002644 <yield>
    80003bf2:	b79d                	j	80003b58 <usertrap+0x62>
  int which_dev = 0;
    80003bf4:	4901                	li	s2,0
    80003bf6:	bfd9                	j	80003bcc <usertrap+0xd6>

0000000080003bf8 <kerneltrap>:
{
    80003bf8:	7179                	addi	sp,sp,-48
    80003bfa:	f406                	sd	ra,40(sp)
    80003bfc:	f022                	sd	s0,32(sp)
    80003bfe:	ec26                	sd	s1,24(sp)
    80003c00:	e84a                	sd	s2,16(sp)
    80003c02:	e44e                	sd	s3,8(sp)
    80003c04:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003c06:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003c0a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003c0e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003c12:	1004f793          	andi	a5,s1,256
    80003c16:	cb85                	beqz	a5,80003c46 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003c18:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003c1c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003c1e:	ef85                	bnez	a5,80003c56 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003c20:	00000097          	auipc	ra,0x0
    80003c24:	e34080e7          	jalr	-460(ra) # 80003a54 <devintr>
    80003c28:	cd1d                	beqz	a0,80003c66 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003c2a:	4789                	li	a5,2
    80003c2c:	06f50a63          	beq	a0,a5,80003ca0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003c30:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003c34:	10049073          	csrw	sstatus,s1
}
    80003c38:	70a2                	ld	ra,40(sp)
    80003c3a:	7402                	ld	s0,32(sp)
    80003c3c:	64e2                	ld	s1,24(sp)
    80003c3e:	6942                	ld	s2,16(sp)
    80003c40:	69a2                	ld	s3,8(sp)
    80003c42:	6145                	addi	sp,sp,48
    80003c44:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003c46:	00006517          	auipc	a0,0x6
    80003c4a:	95a50513          	addi	a0,a0,-1702 # 800095a0 <states.0+0xc8>
    80003c4e:	ffffd097          	auipc	ra,0xffffd
    80003c52:	8ec080e7          	jalr	-1812(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    80003c56:	00006517          	auipc	a0,0x6
    80003c5a:	97250513          	addi	a0,a0,-1678 # 800095c8 <states.0+0xf0>
    80003c5e:	ffffd097          	auipc	ra,0xffffd
    80003c62:	8dc080e7          	jalr	-1828(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    80003c66:	85ce                	mv	a1,s3
    80003c68:	00006517          	auipc	a0,0x6
    80003c6c:	98050513          	addi	a0,a0,-1664 # 800095e8 <states.0+0x110>
    80003c70:	ffffd097          	auipc	ra,0xffffd
    80003c74:	914080e7          	jalr	-1772(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003c78:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003c7c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003c80:	00006517          	auipc	a0,0x6
    80003c84:	97850513          	addi	a0,a0,-1672 # 800095f8 <states.0+0x120>
    80003c88:	ffffd097          	auipc	ra,0xffffd
    80003c8c:	8fc080e7          	jalr	-1796(ra) # 80000584 <printf>
    panic("kerneltrap");
    80003c90:	00006517          	auipc	a0,0x6
    80003c94:	98050513          	addi	a0,a0,-1664 # 80009610 <states.0+0x138>
    80003c98:	ffffd097          	auipc	ra,0xffffd
    80003c9c:	8a2080e7          	jalr	-1886(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003ca0:	ffffe097          	auipc	ra,0xffffe
    80003ca4:	d5e080e7          	jalr	-674(ra) # 800019fe <myproc>
    80003ca8:	d541                	beqz	a0,80003c30 <kerneltrap+0x38>
    80003caa:	ffffe097          	auipc	ra,0xffffe
    80003cae:	d54080e7          	jalr	-684(ra) # 800019fe <myproc>
    80003cb2:	4d18                	lw	a4,24(a0)
    80003cb4:	4791                	li	a5,4
    80003cb6:	f6f71de3          	bne	a4,a5,80003c30 <kerneltrap+0x38>
     if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    80003cba:	00006717          	auipc	a4,0x6
    80003cbe:	3ae72703          	lw	a4,942(a4) # 8000a068 <sched_policy>
    80003cc2:	4785                	li	a5,1
    80003cc4:	f6e7f6e3          	bgeu	a5,a4,80003c30 <kerneltrap+0x38>
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	97c080e7          	jalr	-1668(ra) # 80002644 <yield>
    80003cd0:	b785                	j	80003c30 <kerneltrap+0x38>

0000000080003cd2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003cd2:	1101                	addi	sp,sp,-32
    80003cd4:	ec06                	sd	ra,24(sp)
    80003cd6:	e822                	sd	s0,16(sp)
    80003cd8:	e426                	sd	s1,8(sp)
    80003cda:	1000                	addi	s0,sp,32
    80003cdc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003cde:	ffffe097          	auipc	ra,0xffffe
    80003ce2:	d20080e7          	jalr	-736(ra) # 800019fe <myproc>
  switch (n) {
    80003ce6:	4795                	li	a5,5
    80003ce8:	0497e163          	bltu	a5,s1,80003d2a <argraw+0x58>
    80003cec:	048a                	slli	s1,s1,0x2
    80003cee:	00006717          	auipc	a4,0x6
    80003cf2:	95a70713          	addi	a4,a4,-1702 # 80009648 <states.0+0x170>
    80003cf6:	94ba                	add	s1,s1,a4
    80003cf8:	409c                	lw	a5,0(s1)
    80003cfa:	97ba                	add	a5,a5,a4
    80003cfc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003cfe:	713c                	ld	a5,96(a0)
    80003d00:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003d02:	60e2                	ld	ra,24(sp)
    80003d04:	6442                	ld	s0,16(sp)
    80003d06:	64a2                	ld	s1,8(sp)
    80003d08:	6105                	addi	sp,sp,32
    80003d0a:	8082                	ret
    return p->trapframe->a1;
    80003d0c:	713c                	ld	a5,96(a0)
    80003d0e:	7fa8                	ld	a0,120(a5)
    80003d10:	bfcd                	j	80003d02 <argraw+0x30>
    return p->trapframe->a2;
    80003d12:	713c                	ld	a5,96(a0)
    80003d14:	63c8                	ld	a0,128(a5)
    80003d16:	b7f5                	j	80003d02 <argraw+0x30>
    return p->trapframe->a3;
    80003d18:	713c                	ld	a5,96(a0)
    80003d1a:	67c8                	ld	a0,136(a5)
    80003d1c:	b7dd                	j	80003d02 <argraw+0x30>
    return p->trapframe->a4;
    80003d1e:	713c                	ld	a5,96(a0)
    80003d20:	6bc8                	ld	a0,144(a5)
    80003d22:	b7c5                	j	80003d02 <argraw+0x30>
    return p->trapframe->a5;
    80003d24:	713c                	ld	a5,96(a0)
    80003d26:	6fc8                	ld	a0,152(a5)
    80003d28:	bfe9                	j	80003d02 <argraw+0x30>
  panic("argraw");
    80003d2a:	00006517          	auipc	a0,0x6
    80003d2e:	8f650513          	addi	a0,a0,-1802 # 80009620 <states.0+0x148>
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	808080e7          	jalr	-2040(ra) # 8000053a <panic>

0000000080003d3a <fetchaddr>:
{
    80003d3a:	1101                	addi	sp,sp,-32
    80003d3c:	ec06                	sd	ra,24(sp)
    80003d3e:	e822                	sd	s0,16(sp)
    80003d40:	e426                	sd	s1,8(sp)
    80003d42:	e04a                	sd	s2,0(sp)
    80003d44:	1000                	addi	s0,sp,32
    80003d46:	84aa                	mv	s1,a0
    80003d48:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003d4a:	ffffe097          	auipc	ra,0xffffe
    80003d4e:	cb4080e7          	jalr	-844(ra) # 800019fe <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003d52:	693c                	ld	a5,80(a0)
    80003d54:	02f4f863          	bgeu	s1,a5,80003d84 <fetchaddr+0x4a>
    80003d58:	00848713          	addi	a4,s1,8
    80003d5c:	02e7e663          	bltu	a5,a4,80003d88 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003d60:	46a1                	li	a3,8
    80003d62:	8626                	mv	a2,s1
    80003d64:	85ca                	mv	a1,s2
    80003d66:	6d28                	ld	a0,88(a0)
    80003d68:	ffffe097          	auipc	ra,0xffffe
    80003d6c:	9ce080e7          	jalr	-1586(ra) # 80001736 <copyin>
    80003d70:	00a03533          	snez	a0,a0
    80003d74:	40a00533          	neg	a0,a0
}
    80003d78:	60e2                	ld	ra,24(sp)
    80003d7a:	6442                	ld	s0,16(sp)
    80003d7c:	64a2                	ld	s1,8(sp)
    80003d7e:	6902                	ld	s2,0(sp)
    80003d80:	6105                	addi	sp,sp,32
    80003d82:	8082                	ret
    return -1;
    80003d84:	557d                	li	a0,-1
    80003d86:	bfcd                	j	80003d78 <fetchaddr+0x3e>
    80003d88:	557d                	li	a0,-1
    80003d8a:	b7fd                	j	80003d78 <fetchaddr+0x3e>

0000000080003d8c <fetchstr>:
{
    80003d8c:	7179                	addi	sp,sp,-48
    80003d8e:	f406                	sd	ra,40(sp)
    80003d90:	f022                	sd	s0,32(sp)
    80003d92:	ec26                	sd	s1,24(sp)
    80003d94:	e84a                	sd	s2,16(sp)
    80003d96:	e44e                	sd	s3,8(sp)
    80003d98:	1800                	addi	s0,sp,48
    80003d9a:	892a                	mv	s2,a0
    80003d9c:	84ae                	mv	s1,a1
    80003d9e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003da0:	ffffe097          	auipc	ra,0xffffe
    80003da4:	c5e080e7          	jalr	-930(ra) # 800019fe <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003da8:	86ce                	mv	a3,s3
    80003daa:	864a                	mv	a2,s2
    80003dac:	85a6                	mv	a1,s1
    80003dae:	6d28                	ld	a0,88(a0)
    80003db0:	ffffe097          	auipc	ra,0xffffe
    80003db4:	a14080e7          	jalr	-1516(ra) # 800017c4 <copyinstr>
  if(err < 0)
    80003db8:	00054763          	bltz	a0,80003dc6 <fetchstr+0x3a>
  return strlen(buf);
    80003dbc:	8526                	mv	a0,s1
    80003dbe:	ffffd097          	auipc	ra,0xffffd
    80003dc2:	08a080e7          	jalr	138(ra) # 80000e48 <strlen>
}
    80003dc6:	70a2                	ld	ra,40(sp)
    80003dc8:	7402                	ld	s0,32(sp)
    80003dca:	64e2                	ld	s1,24(sp)
    80003dcc:	6942                	ld	s2,16(sp)
    80003dce:	69a2                	ld	s3,8(sp)
    80003dd0:	6145                	addi	sp,sp,48
    80003dd2:	8082                	ret

0000000080003dd4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003dd4:	1101                	addi	sp,sp,-32
    80003dd6:	ec06                	sd	ra,24(sp)
    80003dd8:	e822                	sd	s0,16(sp)
    80003dda:	e426                	sd	s1,8(sp)
    80003ddc:	1000                	addi	s0,sp,32
    80003dde:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	ef2080e7          	jalr	-270(ra) # 80003cd2 <argraw>
    80003de8:	c088                	sw	a0,0(s1)
  return 0;
}
    80003dea:	4501                	li	a0,0
    80003dec:	60e2                	ld	ra,24(sp)
    80003dee:	6442                	ld	s0,16(sp)
    80003df0:	64a2                	ld	s1,8(sp)
    80003df2:	6105                	addi	sp,sp,32
    80003df4:	8082                	ret

0000000080003df6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003df6:	1101                	addi	sp,sp,-32
    80003df8:	ec06                	sd	ra,24(sp)
    80003dfa:	e822                	sd	s0,16(sp)
    80003dfc:	e426                	sd	s1,8(sp)
    80003dfe:	1000                	addi	s0,sp,32
    80003e00:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003e02:	00000097          	auipc	ra,0x0
    80003e06:	ed0080e7          	jalr	-304(ra) # 80003cd2 <argraw>
    80003e0a:	e088                	sd	a0,0(s1)
  return 0;
}
    80003e0c:	4501                	li	a0,0
    80003e0e:	60e2                	ld	ra,24(sp)
    80003e10:	6442                	ld	s0,16(sp)
    80003e12:	64a2                	ld	s1,8(sp)
    80003e14:	6105                	addi	sp,sp,32
    80003e16:	8082                	ret

0000000080003e18 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003e18:	1101                	addi	sp,sp,-32
    80003e1a:	ec06                	sd	ra,24(sp)
    80003e1c:	e822                	sd	s0,16(sp)
    80003e1e:	e426                	sd	s1,8(sp)
    80003e20:	e04a                	sd	s2,0(sp)
    80003e22:	1000                	addi	s0,sp,32
    80003e24:	84ae                	mv	s1,a1
    80003e26:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	eaa080e7          	jalr	-342(ra) # 80003cd2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003e30:	864a                	mv	a2,s2
    80003e32:	85a6                	mv	a1,s1
    80003e34:	00000097          	auipc	ra,0x0
    80003e38:	f58080e7          	jalr	-168(ra) # 80003d8c <fetchstr>
}
    80003e3c:	60e2                	ld	ra,24(sp)
    80003e3e:	6442                	ld	s0,16(sp)
    80003e40:	64a2                	ld	s1,8(sp)
    80003e42:	6902                	ld	s2,0(sp)
    80003e44:	6105                	addi	sp,sp,32
    80003e46:	8082                	ret

0000000080003e48 <syscall>:
[SYS_sem_consume] sys_sem_consume,
};

void
syscall(void)
{
    80003e48:	1101                	addi	sp,sp,-32
    80003e4a:	ec06                	sd	ra,24(sp)
    80003e4c:	e822                	sd	s0,16(sp)
    80003e4e:	e426                	sd	s1,8(sp)
    80003e50:	e04a                	sd	s2,0(sp)
    80003e52:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003e54:	ffffe097          	auipc	ra,0xffffe
    80003e58:	baa080e7          	jalr	-1110(ra) # 800019fe <myproc>
    80003e5c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003e5e:	06053903          	ld	s2,96(a0)
    80003e62:	0a893783          	ld	a5,168(s2)
    80003e66:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003e6a:	37fd                	addiw	a5,a5,-1
    80003e6c:	02600713          	li	a4,38
    80003e70:	00f76f63          	bltu	a4,a5,80003e8e <syscall+0x46>
    80003e74:	00369713          	slli	a4,a3,0x3
    80003e78:	00005797          	auipc	a5,0x5
    80003e7c:	7e878793          	addi	a5,a5,2024 # 80009660 <syscalls>
    80003e80:	97ba                	add	a5,a5,a4
    80003e82:	639c                	ld	a5,0(a5)
    80003e84:	c789                	beqz	a5,80003e8e <syscall+0x46>
    p->trapframe->a0 = syscalls[num]();
    80003e86:	9782                	jalr	a5
    80003e88:	06a93823          	sd	a0,112(s2)
    80003e8c:	a839                	j	80003eaa <syscall+0x62>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003e8e:	16048613          	addi	a2,s1,352
    80003e92:	588c                	lw	a1,48(s1)
    80003e94:	00005517          	auipc	a0,0x5
    80003e98:	79450513          	addi	a0,a0,1940 # 80009628 <states.0+0x150>
    80003e9c:	ffffc097          	auipc	ra,0xffffc
    80003ea0:	6e8080e7          	jalr	1768(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003ea4:	70bc                	ld	a5,96(s1)
    80003ea6:	577d                	li	a4,-1
    80003ea8:	fbb8                	sd	a4,112(a5)
  }
}
    80003eaa:	60e2                	ld	ra,24(sp)
    80003eac:	6442                	ld	s0,16(sp)
    80003eae:	64a2                	ld	s1,8(sp)
    80003eb0:	6902                	ld	s2,0(sp)
    80003eb2:	6105                	addi	sp,sp,32
    80003eb4:	8082                	ret

0000000080003eb6 <sys_exit>:
int nextp, nextc;
struct sem_t pro, con, empty, full;

uint64
sys_exit(void)
{
    80003eb6:	1101                	addi	sp,sp,-32
    80003eb8:	ec06                	sd	ra,24(sp)
    80003eba:	e822                	sd	s0,16(sp)
    80003ebc:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003ebe:	fec40593          	addi	a1,s0,-20
    80003ec2:	4501                	li	a0,0
    80003ec4:	00000097          	auipc	ra,0x0
    80003ec8:	f10080e7          	jalr	-240(ra) # 80003dd4 <argint>
    return -1;
    80003ecc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003ece:	00054963          	bltz	a0,80003ee0 <sys_exit+0x2a>
  exit(n);
    80003ed2:	fec42503          	lw	a0,-20(s0)
    80003ed6:	fffff097          	auipc	ra,0xfffff
    80003eda:	fc8080e7          	jalr	-56(ra) # 80002e9e <exit>
  return 0;  // not reached
    80003ede:	4781                	li	a5,0
}
    80003ee0:	853e                	mv	a0,a5
    80003ee2:	60e2                	ld	ra,24(sp)
    80003ee4:	6442                	ld	s0,16(sp)
    80003ee6:	6105                	addi	sp,sp,32
    80003ee8:	8082                	ret

0000000080003eea <sys_getpid>:

uint64
sys_getpid(void)
{
    80003eea:	1141                	addi	sp,sp,-16
    80003eec:	e406                	sd	ra,8(sp)
    80003eee:	e022                	sd	s0,0(sp)
    80003ef0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003ef2:	ffffe097          	auipc	ra,0xffffe
    80003ef6:	b0c080e7          	jalr	-1268(ra) # 800019fe <myproc>
}
    80003efa:	5908                	lw	a0,48(a0)
    80003efc:	60a2                	ld	ra,8(sp)
    80003efe:	6402                	ld	s0,0(sp)
    80003f00:	0141                	addi	sp,sp,16
    80003f02:	8082                	ret

0000000080003f04 <sys_fork>:

uint64
sys_fork(void)
{
    80003f04:	1141                	addi	sp,sp,-16
    80003f06:	e406                	sd	ra,8(sp)
    80003f08:	e022                	sd	s0,0(sp)
    80003f0a:	0800                	addi	s0,sp,16
  return fork();
    80003f0c:	ffffe097          	auipc	ra,0xffffe
    80003f10:	f3a080e7          	jalr	-198(ra) # 80001e46 <fork>
}
    80003f14:	60a2                	ld	ra,8(sp)
    80003f16:	6402                	ld	s0,0(sp)
    80003f18:	0141                	addi	sp,sp,16
    80003f1a:	8082                	ret

0000000080003f1c <sys_wait>:

uint64
sys_wait(void)
{
    80003f1c:	1101                	addi	sp,sp,-32
    80003f1e:	ec06                	sd	ra,24(sp)
    80003f20:	e822                	sd	s0,16(sp)
    80003f22:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003f24:	fe840593          	addi	a1,s0,-24
    80003f28:	4501                	li	a0,0
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	ecc080e7          	jalr	-308(ra) # 80003df6 <argaddr>
    80003f32:	87aa                	mv	a5,a0
    return -1;
    80003f34:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003f36:	0007c863          	bltz	a5,80003f46 <sys_wait+0x2a>
  return wait(p);
    80003f3a:	fe843503          	ld	a0,-24(s0)
    80003f3e:	fffff097          	auipc	ra,0xfffff
    80003f42:	a20080e7          	jalr	-1504(ra) # 8000295e <wait>
}
    80003f46:	60e2                	ld	ra,24(sp)
    80003f48:	6442                	ld	s0,16(sp)
    80003f4a:	6105                	addi	sp,sp,32
    80003f4c:	8082                	ret

0000000080003f4e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003f4e:	7179                	addi	sp,sp,-48
    80003f50:	f406                	sd	ra,40(sp)
    80003f52:	f022                	sd	s0,32(sp)
    80003f54:	ec26                	sd	s1,24(sp)
    80003f56:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003f58:	fdc40593          	addi	a1,s0,-36
    80003f5c:	4501                	li	a0,0
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	e76080e7          	jalr	-394(ra) # 80003dd4 <argint>
    80003f66:	87aa                	mv	a5,a0
    return -1;
    80003f68:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003f6a:	0207c063          	bltz	a5,80003f8a <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003f6e:	ffffe097          	auipc	ra,0xffffe
    80003f72:	a90080e7          	jalr	-1392(ra) # 800019fe <myproc>
    80003f76:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80003f78:	fdc42503          	lw	a0,-36(s0)
    80003f7c:	ffffe097          	auipc	ra,0xffffe
    80003f80:	e52080e7          	jalr	-430(ra) # 80001dce <growproc>
    80003f84:	00054863          	bltz	a0,80003f94 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003f88:	8526                	mv	a0,s1
}
    80003f8a:	70a2                	ld	ra,40(sp)
    80003f8c:	7402                	ld	s0,32(sp)
    80003f8e:	64e2                	ld	s1,24(sp)
    80003f90:	6145                	addi	sp,sp,48
    80003f92:	8082                	ret
    return -1;
    80003f94:	557d                	li	a0,-1
    80003f96:	bfd5                	j	80003f8a <sys_sbrk+0x3c>

0000000080003f98 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003f98:	7139                	addi	sp,sp,-64
    80003f9a:	fc06                	sd	ra,56(sp)
    80003f9c:	f822                	sd	s0,48(sp)
    80003f9e:	f426                	sd	s1,40(sp)
    80003fa0:	f04a                	sd	s2,32(sp)
    80003fa2:	ec4e                	sd	s3,24(sp)
    80003fa4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003fa6:	fcc40593          	addi	a1,s0,-52
    80003faa:	4501                	li	a0,0
    80003fac:	00000097          	auipc	ra,0x0
    80003fb0:	e28080e7          	jalr	-472(ra) # 80003dd4 <argint>
    return -1;
    80003fb4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003fb6:	06054563          	bltz	a0,80004020 <sys_sleep+0x88>
  acquire(&tickslock);
    80003fba:	00015517          	auipc	a0,0x15
    80003fbe:	b6e50513          	addi	a0,a0,-1170 # 80018b28 <tickslock>
    80003fc2:	ffffd097          	auipc	ra,0xffffd
    80003fc6:	c0e080e7          	jalr	-1010(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80003fca:	00006917          	auipc	s2,0x6
    80003fce:	0a292903          	lw	s2,162(s2) # 8000a06c <ticks>
  while(ticks - ticks0 < n){
    80003fd2:	fcc42783          	lw	a5,-52(s0)
    80003fd6:	cf85                	beqz	a5,8000400e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003fd8:	00015997          	auipc	s3,0x15
    80003fdc:	b5098993          	addi	s3,s3,-1200 # 80018b28 <tickslock>
    80003fe0:	00006497          	auipc	s1,0x6
    80003fe4:	08c48493          	addi	s1,s1,140 # 8000a06c <ticks>
    if(myproc()->killed){
    80003fe8:	ffffe097          	auipc	ra,0xffffe
    80003fec:	a16080e7          	jalr	-1514(ra) # 800019fe <myproc>
    80003ff0:	551c                	lw	a5,40(a0)
    80003ff2:	ef9d                	bnez	a5,80004030 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003ff4:	85ce                	mv	a1,s3
    80003ff6:	8526                	mv	a0,s1
    80003ff8:	ffffe097          	auipc	ra,0xffffe
    80003ffc:	7b8080e7          	jalr	1976(ra) # 800027b0 <sleep>
  while(ticks - ticks0 < n){
    80004000:	409c                	lw	a5,0(s1)
    80004002:	412787bb          	subw	a5,a5,s2
    80004006:	fcc42703          	lw	a4,-52(s0)
    8000400a:	fce7efe3          	bltu	a5,a4,80003fe8 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000400e:	00015517          	auipc	a0,0x15
    80004012:	b1a50513          	addi	a0,a0,-1254 # 80018b28 <tickslock>
    80004016:	ffffd097          	auipc	ra,0xffffd
    8000401a:	c6e080e7          	jalr	-914(ra) # 80000c84 <release>
  return 0;
    8000401e:	4781                	li	a5,0
}
    80004020:	853e                	mv	a0,a5
    80004022:	70e2                	ld	ra,56(sp)
    80004024:	7442                	ld	s0,48(sp)
    80004026:	74a2                	ld	s1,40(sp)
    80004028:	7902                	ld	s2,32(sp)
    8000402a:	69e2                	ld	s3,24(sp)
    8000402c:	6121                	addi	sp,sp,64
    8000402e:	8082                	ret
      release(&tickslock);
    80004030:	00015517          	auipc	a0,0x15
    80004034:	af850513          	addi	a0,a0,-1288 # 80018b28 <tickslock>
    80004038:	ffffd097          	auipc	ra,0xffffd
    8000403c:	c4c080e7          	jalr	-948(ra) # 80000c84 <release>
      return -1;
    80004040:	57fd                	li	a5,-1
    80004042:	bff9                	j	80004020 <sys_sleep+0x88>

0000000080004044 <sys_kill>:

uint64
sys_kill(void)
{
    80004044:	1101                	addi	sp,sp,-32
    80004046:	ec06                	sd	ra,24(sp)
    80004048:	e822                	sd	s0,16(sp)
    8000404a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000404c:	fec40593          	addi	a1,s0,-20
    80004050:	4501                	li	a0,0
    80004052:	00000097          	auipc	ra,0x0
    80004056:	d82080e7          	jalr	-638(ra) # 80003dd4 <argint>
    8000405a:	87aa                	mv	a5,a0
    return -1;
    8000405c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000405e:	0007c863          	bltz	a5,8000406e <sys_kill+0x2a>
  return kill(pid);
    80004062:	fec42503          	lw	a0,-20(s0)
    80004066:	fffff097          	auipc	ra,0xfffff
    8000406a:	336080e7          	jalr	822(ra) # 8000339c <kill>
}
    8000406e:	60e2                	ld	ra,24(sp)
    80004070:	6442                	ld	s0,16(sp)
    80004072:	6105                	addi	sp,sp,32
    80004074:	8082                	ret

0000000080004076 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80004076:	1101                	addi	sp,sp,-32
    80004078:	ec06                	sd	ra,24(sp)
    8000407a:	e822                	sd	s0,16(sp)
    8000407c:	e426                	sd	s1,8(sp)
    8000407e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80004080:	00015517          	auipc	a0,0x15
    80004084:	aa850513          	addi	a0,a0,-1368 # 80018b28 <tickslock>
    80004088:	ffffd097          	auipc	ra,0xffffd
    8000408c:	b48080e7          	jalr	-1208(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80004090:	00006497          	auipc	s1,0x6
    80004094:	fdc4a483          	lw	s1,-36(s1) # 8000a06c <ticks>
  release(&tickslock);
    80004098:	00015517          	auipc	a0,0x15
    8000409c:	a9050513          	addi	a0,a0,-1392 # 80018b28 <tickslock>
    800040a0:	ffffd097          	auipc	ra,0xffffd
    800040a4:	be4080e7          	jalr	-1052(ra) # 80000c84 <release>
  return xticks;
}
    800040a8:	02049513          	slli	a0,s1,0x20
    800040ac:	9101                	srli	a0,a0,0x20
    800040ae:	60e2                	ld	ra,24(sp)
    800040b0:	6442                	ld	s0,16(sp)
    800040b2:	64a2                	ld	s1,8(sp)
    800040b4:	6105                	addi	sp,sp,32
    800040b6:	8082                	ret

00000000800040b8 <sys_getppid>:

uint64
sys_getppid(void)
{
    800040b8:	1141                	addi	sp,sp,-16
    800040ba:	e406                	sd	ra,8(sp)
    800040bc:	e022                	sd	s0,0(sp)
    800040be:	0800                	addi	s0,sp,16
  if (myproc()->parent) return myproc()->parent->pid;
    800040c0:	ffffe097          	auipc	ra,0xffffe
    800040c4:	93e080e7          	jalr	-1730(ra) # 800019fe <myproc>
    800040c8:	613c                	ld	a5,64(a0)
    800040ca:	cb99                	beqz	a5,800040e0 <sys_getppid+0x28>
    800040cc:	ffffe097          	auipc	ra,0xffffe
    800040d0:	932080e7          	jalr	-1742(ra) # 800019fe <myproc>
    800040d4:	613c                	ld	a5,64(a0)
    800040d6:	5b88                	lw	a0,48(a5)
  else {
     printf("No parent found.\n");
     return 0;
  }
}
    800040d8:	60a2                	ld	ra,8(sp)
    800040da:	6402                	ld	s0,0(sp)
    800040dc:	0141                	addi	sp,sp,16
    800040de:	8082                	ret
     printf("No parent found.\n");
    800040e0:	00005517          	auipc	a0,0x5
    800040e4:	6c050513          	addi	a0,a0,1728 # 800097a0 <syscalls+0x140>
    800040e8:	ffffc097          	auipc	ra,0xffffc
    800040ec:	49c080e7          	jalr	1180(ra) # 80000584 <printf>
     return 0;
    800040f0:	4501                	li	a0,0
    800040f2:	b7dd                	j	800040d8 <sys_getppid+0x20>

00000000800040f4 <sys_yield>:

uint64
sys_yield(void)
{
    800040f4:	1141                	addi	sp,sp,-16
    800040f6:	e406                	sd	ra,8(sp)
    800040f8:	e022                	sd	s0,0(sp)
    800040fa:	0800                	addi	s0,sp,16
  yield();
    800040fc:	ffffe097          	auipc	ra,0xffffe
    80004100:	548080e7          	jalr	1352(ra) # 80002644 <yield>
  return 0;
}
    80004104:	4501                	li	a0,0
    80004106:	60a2                	ld	ra,8(sp)
    80004108:	6402                	ld	s0,0(sp)
    8000410a:	0141                	addi	sp,sp,16
    8000410c:	8082                	ret

000000008000410e <sys_getpa>:

uint64
sys_getpa(void)
{
    8000410e:	1101                	addi	sp,sp,-32
    80004110:	ec06                	sd	ra,24(sp)
    80004112:	e822                	sd	s0,16(sp)
    80004114:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    80004116:	fe840593          	addi	a1,s0,-24
    8000411a:	4501                	li	a0,0
    8000411c:	00000097          	auipc	ra,0x0
    80004120:	cda080e7          	jalr	-806(ra) # 80003df6 <argaddr>
    80004124:	87aa                	mv	a5,a0
    80004126:	557d                	li	a0,-1
    80004128:	0207c263          	bltz	a5,8000414c <sys_getpa+0x3e>
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
    8000412c:	ffffe097          	auipc	ra,0xffffe
    80004130:	8d2080e7          	jalr	-1838(ra) # 800019fe <myproc>
    80004134:	fe843583          	ld	a1,-24(s0)
    80004138:	6d28                	ld	a0,88(a0)
    8000413a:	ffffd097          	auipc	ra,0xffffd
    8000413e:	f68080e7          	jalr	-152(ra) # 800010a2 <walkaddr>
    80004142:	fe843783          	ld	a5,-24(s0)
    80004146:	17d2                	slli	a5,a5,0x34
    80004148:	93d1                	srli	a5,a5,0x34
    8000414a:	953e                	add	a0,a0,a5
}
    8000414c:	60e2                	ld	ra,24(sp)
    8000414e:	6442                	ld	s0,16(sp)
    80004150:	6105                	addi	sp,sp,32
    80004152:	8082                	ret

0000000080004154 <sys_forkf>:

uint64
sys_forkf(void)
{
    80004154:	1101                	addi	sp,sp,-32
    80004156:	ec06                	sd	ra,24(sp)
    80004158:	e822                	sd	s0,16(sp)
    8000415a:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    8000415c:	fe840593          	addi	a1,s0,-24
    80004160:	4501                	li	a0,0
    80004162:	00000097          	auipc	ra,0x0
    80004166:	c94080e7          	jalr	-876(ra) # 80003df6 <argaddr>
    8000416a:	87aa                	mv	a5,a0
    8000416c:	557d                	li	a0,-1
    8000416e:	0007c863          	bltz	a5,8000417e <sys_forkf+0x2a>
  return forkf(x);
    80004172:	fe843503          	ld	a0,-24(s0)
    80004176:	ffffe097          	auipc	ra,0xffffe
    8000417a:	e10080e7          	jalr	-496(ra) # 80001f86 <forkf>
}
    8000417e:	60e2                	ld	ra,24(sp)
    80004180:	6442                	ld	s0,16(sp)
    80004182:	6105                	addi	sp,sp,32
    80004184:	8082                	ret

0000000080004186 <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80004186:	1101                	addi	sp,sp,-32
    80004188:	ec06                	sd	ra,24(sp)
    8000418a:	e822                	sd	s0,16(sp)
    8000418c:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    8000418e:	fe440593          	addi	a1,s0,-28
    80004192:	4501                	li	a0,0
    80004194:	00000097          	auipc	ra,0x0
    80004198:	c40080e7          	jalr	-960(ra) # 80003dd4 <argint>
    return -1;
    8000419c:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    8000419e:	02054c63          	bltz	a0,800041d6 <sys_waitpid+0x50>
  if(argaddr(1, &p) < 0)
    800041a2:	fe840593          	addi	a1,s0,-24
    800041a6:	4505                	li	a0,1
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	c4e080e7          	jalr	-946(ra) # 80003df6 <argaddr>
    800041b0:	04054063          	bltz	a0,800041f0 <sys_waitpid+0x6a>
    return -1;

  if (x == -1) return wait(p);
    800041b4:	fe442503          	lw	a0,-28(s0)
    800041b8:	57fd                	li	a5,-1
    800041ba:	02f50363          	beq	a0,a5,800041e0 <sys_waitpid+0x5a>
  if ((x == 0) || (x < -1)) return -1;
    800041be:	57fd                	li	a5,-1
    800041c0:	c919                	beqz	a0,800041d6 <sys_waitpid+0x50>
    800041c2:	577d                	li	a4,-1
    800041c4:	00e54963          	blt	a0,a4,800041d6 <sys_waitpid+0x50>
  return waitpid(x, p);
    800041c8:	fe843583          	ld	a1,-24(s0)
    800041cc:	fffff097          	auipc	ra,0xfffff
    800041d0:	8ba080e7          	jalr	-1862(ra) # 80002a86 <waitpid>
    800041d4:	87aa                	mv	a5,a0
}
    800041d6:	853e                	mv	a0,a5
    800041d8:	60e2                	ld	ra,24(sp)
    800041da:	6442                	ld	s0,16(sp)
    800041dc:	6105                	addi	sp,sp,32
    800041de:	8082                	ret
  if (x == -1) return wait(p);
    800041e0:	fe843503          	ld	a0,-24(s0)
    800041e4:	ffffe097          	auipc	ra,0xffffe
    800041e8:	77a080e7          	jalr	1914(ra) # 8000295e <wait>
    800041ec:	87aa                	mv	a5,a0
    800041ee:	b7e5                	j	800041d6 <sys_waitpid+0x50>
    return -1;
    800041f0:	57fd                	li	a5,-1
    800041f2:	b7d5                	j	800041d6 <sys_waitpid+0x50>

00000000800041f4 <sys_ps>:

uint64
sys_ps(void)
{
    800041f4:	1141                	addi	sp,sp,-16
    800041f6:	e406                	sd	ra,8(sp)
    800041f8:	e022                	sd	s0,0(sp)
    800041fa:	0800                	addi	s0,sp,16
   return ps();
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	39e080e7          	jalr	926(ra) # 8000359a <ps>
}
    80004204:	60a2                	ld	ra,8(sp)
    80004206:	6402                	ld	s0,0(sp)
    80004208:	0141                	addi	sp,sp,16
    8000420a:	8082                	ret

000000008000420c <sys_pinfo>:

uint64
sys_pinfo(void)
{
    8000420c:	1101                	addi	sp,sp,-32
    8000420e:	ec06                	sd	ra,24(sp)
    80004210:	e822                	sd	s0,16(sp)
    80004212:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    80004214:	fe440593          	addi	a1,s0,-28
    80004218:	4501                	li	a0,0
    8000421a:	00000097          	auipc	ra,0x0
    8000421e:	bba080e7          	jalr	-1094(ra) # 80003dd4 <argint>
    return -1;
    80004222:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    80004224:	02054963          	bltz	a0,80004256 <sys_pinfo+0x4a>
  if(argaddr(1, &p) < 0)
    80004228:	fe840593          	addi	a1,s0,-24
    8000422c:	4505                	li	a0,1
    8000422e:	00000097          	auipc	ra,0x0
    80004232:	bc8080e7          	jalr	-1080(ra) # 80003df6 <argaddr>
    80004236:	02054563          	bltz	a0,80004260 <sys_pinfo+0x54>
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    8000423a:	fe442503          	lw	a0,-28(s0)
    8000423e:	57fd                	li	a5,-1
    80004240:	c919                	beqz	a0,80004256 <sys_pinfo+0x4a>
    80004242:	02f54163          	blt	a0,a5,80004264 <sys_pinfo+0x58>
    80004246:	fe843583          	ld	a1,-24(s0)
    8000424a:	c591                	beqz	a1,80004256 <sys_pinfo+0x4a>
  return pinfo(x, p);
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	4bc080e7          	jalr	1212(ra) # 80003708 <pinfo>
    80004254:	87aa                	mv	a5,a0
}
    80004256:	853e                	mv	a0,a5
    80004258:	60e2                	ld	ra,24(sp)
    8000425a:	6442                	ld	s0,16(sp)
    8000425c:	6105                	addi	sp,sp,32
    8000425e:	8082                	ret
    return -1;
    80004260:	57fd                	li	a5,-1
    80004262:	bfd5                	j	80004256 <sys_pinfo+0x4a>
  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    80004264:	57fd                	li	a5,-1
    80004266:	bfc5                	j	80004256 <sys_pinfo+0x4a>

0000000080004268 <sys_forkp>:

uint64
sys_forkp(void)
{
    80004268:	1101                	addi	sp,sp,-32
    8000426a:	ec06                	sd	ra,24(sp)
    8000426c:	e822                	sd	s0,16(sp)
    8000426e:	1000                	addi	s0,sp,32
  int x;
  if(argint(0, &x) < 0) return -1;
    80004270:	fec40593          	addi	a1,s0,-20
    80004274:	4501                	li	a0,0
    80004276:	00000097          	auipc	ra,0x0
    8000427a:	b5e080e7          	jalr	-1186(ra) # 80003dd4 <argint>
    8000427e:	87aa                	mv	a5,a0
    80004280:	557d                	li	a0,-1
    80004282:	0007c863          	bltz	a5,80004292 <sys_forkp+0x2a>
  return forkp(x);
    80004286:	fec42503          	lw	a0,-20(s0)
    8000428a:	ffffe097          	auipc	ra,0xffffe
    8000428e:	e48080e7          	jalr	-440(ra) # 800020d2 <forkp>
}
    80004292:	60e2                	ld	ra,24(sp)
    80004294:	6442                	ld	s0,16(sp)
    80004296:	6105                	addi	sp,sp,32
    80004298:	8082                	ret

000000008000429a <sys_schedpolicy>:

uint64
sys_schedpolicy(void)
{
    8000429a:	1101                	addi	sp,sp,-32
    8000429c:	ec06                	sd	ra,24(sp)
    8000429e:	e822                	sd	s0,16(sp)
    800042a0:	1000                	addi	s0,sp,32
  int x;
  if(argint(0, &x) < 0) return -1;
    800042a2:	fec40593          	addi	a1,s0,-20
    800042a6:	4501                	li	a0,0
    800042a8:	00000097          	auipc	ra,0x0
    800042ac:	b2c080e7          	jalr	-1236(ra) # 80003dd4 <argint>
    800042b0:	87aa                	mv	a5,a0
    800042b2:	557d                	li	a0,-1
    800042b4:	0007c863          	bltz	a5,800042c4 <sys_schedpolicy+0x2a>
  return schedpolicy(x);
    800042b8:	fec42503          	lw	a0,-20(s0)
    800042bc:	fffff097          	auipc	ra,0xfffff
    800042c0:	5f0080e7          	jalr	1520(ra) # 800038ac <schedpolicy>
}
    800042c4:	60e2                	ld	ra,24(sp)
    800042c6:	6442                	ld	s0,16(sp)
    800042c8:	6105                	addi	sp,sp,32
    800042ca:	8082                	ret

00000000800042cc <sys_barrier>:

uint64 
sys_barrier(void)
{
    800042cc:	7179                	addi	sp,sp,-48
    800042ce:	f406                	sd	ra,40(sp)
    800042d0:	f022                	sd	s0,32(sp)
    800042d2:	ec26                	sd	s1,24(sp)
    800042d4:	e84a                	sd	s2,16(sp)
    800042d6:	1800                	addi	s0,sp,48

  int barrier_instance_no, barrier_id, n;
  if(argint(0, &barrier_instance_no) < 0){
    800042d8:	fdc40593          	addi	a1,s0,-36
    800042dc:	4501                	li	a0,0
    800042de:	00000097          	auipc	ra,0x0
    800042e2:	af6080e7          	jalr	-1290(ra) # 80003dd4 <argint>
    return -1;
    800042e6:	57fd                	li	a5,-1
  if(argint(0, &barrier_instance_no) < 0){
    800042e8:	0c054a63          	bltz	a0,800043bc <sys_barrier+0xf0>
  }

  if(argint(1, &barrier_id) < 0){
    800042ec:	fd840593          	addi	a1,s0,-40
    800042f0:	4505                	li	a0,1
    800042f2:	00000097          	auipc	ra,0x0
    800042f6:	ae2080e7          	jalr	-1310(ra) # 80003dd4 <argint>
    return -1;
    800042fa:	57fd                	li	a5,-1
  if(argint(1, &barrier_id) < 0){
    800042fc:	0c054063          	bltz	a0,800043bc <sys_barrier+0xf0>
  }

  if(argint(2, &n) < 0){
    80004300:	fd440593          	addi	a1,s0,-44
    80004304:	4509                	li	a0,2
    80004306:	00000097          	auipc	ra,0x0
    8000430a:	ace080e7          	jalr	-1330(ra) # 80003dd4 <argint>
    8000430e:	0e054c63          	bltz	a0,80004406 <sys_barrier+0x13a>
    return -1;
  }

  if(barriers[barrier_id].counter == -1){
    80004312:	fd842783          	lw	a5,-40(s0)
    80004316:	06800693          	li	a3,104
    8000431a:	02d786b3          	mul	a3,a5,a3
    8000431e:	00015717          	auipc	a4,0x15
    80004322:	82270713          	addi	a4,a4,-2014 # 80018b40 <barriers>
    80004326:	9736                	add	a4,a4,a3
    80004328:	4318                	lw	a4,0(a4)
    8000432a:	56fd                	li	a3,-1
    8000432c:	08d70f63          	beq	a4,a3,800043ca <sys_barrier+0xfe>
    printf("Element with given barrier array id is not allocated\n");
    return -1;
  }

  barriers[barrier_id].counter++ ;
    80004330:	00015497          	auipc	s1,0x15
    80004334:	81048493          	addi	s1,s1,-2032 # 80018b40 <barriers>
    80004338:	06800913          	li	s2,104
    8000433c:	032787b3          	mul	a5,a5,s2
    80004340:	97a6                	add	a5,a5,s1
    80004342:	2705                	addiw	a4,a4,1
    80004344:	c398                	sw	a4,0(a5)

  printf("%d: Entered barrier#%d for barrier array id %d\n", myproc()->pid, barrier_instance_no, barrier_id);
    80004346:	ffffd097          	auipc	ra,0xffffd
    8000434a:	6b8080e7          	jalr	1720(ra) # 800019fe <myproc>
    8000434e:	fd842683          	lw	a3,-40(s0)
    80004352:	fdc42603          	lw	a2,-36(s0)
    80004356:	590c                	lw	a1,48(a0)
    80004358:	00005517          	auipc	a0,0x5
    8000435c:	49850513          	addi	a0,a0,1176 # 800097f0 <syscalls+0x190>
    80004360:	ffffc097          	auipc	ra,0xffffc
    80004364:	224080e7          	jalr	548(ra) # 80000584 <printf>


  if(barriers[barrier_id].counter != n){
    80004368:	fd842783          	lw	a5,-40(s0)
    8000436c:	03278933          	mul	s2,a5,s2
    80004370:	94ca                	add	s1,s1,s2
    80004372:	4094                	lw	a3,0(s1)
    80004374:	fd442703          	lw	a4,-44(s0)
    80004378:	06e68363          	beq	a3,a4,800043de <sys_barrier+0x112>
    cond_wait(&barriers[barrier_id].cv, &barriers[barrier_id].lock);
    8000437c:	00014517          	auipc	a0,0x14
    80004380:	7c450513          	addi	a0,a0,1988 # 80018b40 <barriers>
    80004384:	00890593          	addi	a1,s2,8
    80004388:	03890793          	addi	a5,s2,56
    8000438c:	95aa                	add	a1,a1,a0
    8000438e:	953e                	add	a0,a0,a5
    80004390:	00004097          	auipc	ra,0x4
    80004394:	9c2080e7          	jalr	-1598(ra) # 80007d52 <cond_wait>
  else{
    barriers[barrier_id].counter = 0;
    cond_broadcast(&barriers[barrier_id].cv);
  }

  printf("%d: Finished barrier#%d for barrier array id %d\n", myproc()->pid, barrier_instance_no, barrier_id);
    80004398:	ffffd097          	auipc	ra,0xffffd
    8000439c:	666080e7          	jalr	1638(ra) # 800019fe <myproc>
    800043a0:	fd842683          	lw	a3,-40(s0)
    800043a4:	fdc42603          	lw	a2,-36(s0)
    800043a8:	590c                	lw	a1,48(a0)
    800043aa:	00005517          	auipc	a0,0x5
    800043ae:	47650513          	addi	a0,a0,1142 # 80009820 <syscalls+0x1c0>
    800043b2:	ffffc097          	auipc	ra,0xffffc
    800043b6:	1d2080e7          	jalr	466(ra) # 80000584 <printf>
  
  return 0;
    800043ba:	4781                	li	a5,0
}
    800043bc:	853e                	mv	a0,a5
    800043be:	70a2                	ld	ra,40(sp)
    800043c0:	7402                	ld	s0,32(sp)
    800043c2:	64e2                	ld	s1,24(sp)
    800043c4:	6942                	ld	s2,16(sp)
    800043c6:	6145                	addi	sp,sp,48
    800043c8:	8082                	ret
    printf("Element with given barrier array id is not allocated\n");
    800043ca:	00005517          	auipc	a0,0x5
    800043ce:	3ee50513          	addi	a0,a0,1006 # 800097b8 <syscalls+0x158>
    800043d2:	ffffc097          	auipc	ra,0xffffc
    800043d6:	1b2080e7          	jalr	434(ra) # 80000584 <printf>
    return -1;
    800043da:	57fd                	li	a5,-1
    800043dc:	b7c5                	j	800043bc <sys_barrier+0xf0>
    barriers[barrier_id].counter = 0;
    800043de:	00014517          	auipc	a0,0x14
    800043e2:	76250513          	addi	a0,a0,1890 # 80018b40 <barriers>
    800043e6:	06800713          	li	a4,104
    800043ea:	02e787b3          	mul	a5,a5,a4
    800043ee:	00f50733          	add	a4,a0,a5
    800043f2:	00072023          	sw	zero,0(a4)
    cond_broadcast(&barriers[barrier_id].cv);
    800043f6:	03878793          	addi	a5,a5,56
    800043fa:	953e                	add	a0,a0,a5
    800043fc:	00004097          	auipc	ra,0x4
    80004400:	986080e7          	jalr	-1658(ra) # 80007d82 <cond_broadcast>
    80004404:	bf51                	j	80004398 <sys_barrier+0xcc>
    return -1;
    80004406:	57fd                	li	a5,-1
    80004408:	bf55                	j	800043bc <sys_barrier+0xf0>

000000008000440a <sys_barrier_alloc>:

uint64 
sys_barrier_alloc(void)
{
    8000440a:	7139                	addi	sp,sp,-64
    8000440c:	fc06                	sd	ra,56(sp)
    8000440e:	f822                	sd	s0,48(sp)
    80004410:	f426                	sd	s1,40(sp)
    80004412:	f04a                	sd	s2,32(sp)
    80004414:	ec4e                	sd	s3,24(sp)
    80004416:	e852                	sd	s4,16(sp)
    80004418:	e456                	sd	s5,8(sp)
    8000441a:	0080                	addi	s0,sp,64
    for(int i=0; i<10; ++i){
    8000441c:	00014497          	auipc	s1,0x14
    80004420:	72c48493          	addi	s1,s1,1836 # 80018b48 <barriers+0x8>
    80004424:	4901                	li	s2,0
      acquiresleep(&barriers[i].lock);
      if(barriers[i].counter == -1){
    80004426:	59fd                	li	s3,-1
    for(int i=0; i<10; ++i){
    80004428:	4a29                	li	s4,10
      acquiresleep(&barriers[i].lock);
    8000442a:	8526                	mv	a0,s1
    8000442c:	00002097          	auipc	ra,0x2
    80004430:	a9e080e7          	jalr	-1378(ra) # 80005eca <acquiresleep>
      if(barriers[i].counter == -1){
    80004434:	ff84a783          	lw	a5,-8(s1)
    80004438:	03378663          	beq	a5,s3,80004464 <sys_barrier_alloc+0x5a>
        barriers[i].counter = 0;
        releasesleep(&barriers[i].lock);
        return i;
      }
      releasesleep(&barriers[i].lock);
    8000443c:	8526                	mv	a0,s1
    8000443e:	00002097          	auipc	ra,0x2
    80004442:	ae2080e7          	jalr	-1310(ra) # 80005f20 <releasesleep>
    for(int i=0; i<10; ++i){
    80004446:	2905                	addiw	s2,s2,1
    80004448:	06848493          	addi	s1,s1,104
    8000444c:	fd491fe3          	bne	s2,s4,8000442a <sys_barrier_alloc+0x20>
    } 
  return -1;
    80004450:	557d                	li	a0,-1
}
    80004452:	70e2                	ld	ra,56(sp)
    80004454:	7442                	ld	s0,48(sp)
    80004456:	74a2                	ld	s1,40(sp)
    80004458:	7902                	ld	s2,32(sp)
    8000445a:	69e2                	ld	s3,24(sp)
    8000445c:	6a42                	ld	s4,16(sp)
    8000445e:	6aa2                	ld	s5,8(sp)
    80004460:	6121                	addi	sp,sp,64
    80004462:	8082                	ret
        barriers[i].counter = 0;
    80004464:	06800713          	li	a4,104
    80004468:	02e90733          	mul	a4,s2,a4
    8000446c:	00014797          	auipc	a5,0x14
    80004470:	6d478793          	addi	a5,a5,1748 # 80018b40 <barriers>
    80004474:	97ba                	add	a5,a5,a4
    80004476:	0007a023          	sw	zero,0(a5)
        releasesleep(&barriers[i].lock);
    8000447a:	8526                	mv	a0,s1
    8000447c:	00002097          	auipc	ra,0x2
    80004480:	aa4080e7          	jalr	-1372(ra) # 80005f20 <releasesleep>
        return i;
    80004484:	854a                	mv	a0,s2
    80004486:	b7f1                	j	80004452 <sys_barrier_alloc+0x48>

0000000080004488 <sys_barrier_free>:

uint64 
sys_barrier_free(void)
{
    80004488:	7179                	addi	sp,sp,-48
    8000448a:	f406                	sd	ra,40(sp)
    8000448c:	f022                	sd	s0,32(sp)
    8000448e:	ec26                	sd	s1,24(sp)
    80004490:	e84a                	sd	s2,16(sp)
    80004492:	1800                	addi	s0,sp,48
   int barrier_id;
   if(argint(0, &barrier_id) < 0){
    80004494:	fdc40593          	addi	a1,s0,-36
    80004498:	4501                	li	a0,0
    8000449a:	00000097          	auipc	ra,0x0
    8000449e:	93a080e7          	jalr	-1734(ra) # 80003dd4 <argint>
    return -1;
    800044a2:	57fd                	li	a5,-1
   if(argint(0, &barrier_id) < 0){
    800044a4:	04054663          	bltz	a0,800044f0 <sys_barrier_free+0x68>
   }
   barriers[barrier_id].counter = -1;
    800044a8:	fdc42503          	lw	a0,-36(s0)
    800044ac:	00014497          	auipc	s1,0x14
    800044b0:	69448493          	addi	s1,s1,1684 # 80018b40 <barriers>
    800044b4:	06800913          	li	s2,104
    800044b8:	03250533          	mul	a0,a0,s2
    800044bc:	00a487b3          	add	a5,s1,a0
    800044c0:	577d                	li	a4,-1
    800044c2:	c398                	sw	a4,0(a5)
   initsleeplock(&barriers[barrier_id].lock, "barrier_lock");
    800044c4:	0521                	addi	a0,a0,8
    800044c6:	00005597          	auipc	a1,0x5
    800044ca:	c0a58593          	addi	a1,a1,-1014 # 800090d0 <digits+0x90>
    800044ce:	9526                	add	a0,a0,s1
    800044d0:	00002097          	auipc	ra,0x2
    800044d4:	9c0080e7          	jalr	-1600(ra) # 80005e90 <initsleeplock>
   cond_init(&barriers[barrier_id].cv);
    800044d8:	fdc42503          	lw	a0,-36(s0)
    800044dc:	03250533          	mul	a0,a0,s2
    800044e0:	03850513          	addi	a0,a0,56
    800044e4:	9526                	add	a0,a0,s1
    800044e6:	00004097          	auipc	ra,0x4
    800044ea:	8b4080e7          	jalr	-1868(ra) # 80007d9a <cond_init>

   return 0;
    800044ee:	4781                	li	a5,0

}
    800044f0:	853e                	mv	a0,a5
    800044f2:	70a2                	ld	ra,40(sp)
    800044f4:	7402                	ld	s0,32(sp)
    800044f6:	64e2                	ld	s1,24(sp)
    800044f8:	6942                	ld	s2,16(sp)
    800044fa:	6145                	addi	sp,sp,48
    800044fc:	8082                	ret

00000000800044fe <sys_buffer_cond_init>:

uint64
sys_buffer_cond_init(void)
{
    800044fe:	7179                	addi	sp,sp,-48
    80004500:	f406                	sd	ra,40(sp)
    80004502:	f022                	sd	s0,32(sp)
    80004504:	ec26                	sd	s1,24(sp)
    80004506:	e84a                	sd	s2,16(sp)
    80004508:	e44e                	sd	s3,8(sp)
    8000450a:	e052                	sd	s4,0(sp)
    8000450c:	1800                	addi	s0,sp,48
  tail = 0;
    8000450e:	00006797          	auipc	a5,0x6
    80004512:	b607a723          	sw	zero,-1170(a5) # 8000a07c <tail>
  head = 0;
    80004516:	00006797          	auipc	a5,0x6
    8000451a:	b607a123          	sw	zero,-1182(a5) # 8000a078 <head>
  initsleeplock(&lock_delete, "delete");
    8000451e:	00005597          	auipc	a1,0x5
    80004522:	33a58593          	addi	a1,a1,826 # 80009858 <syscalls+0x1f8>
    80004526:	00015517          	auipc	a0,0x15
    8000452a:	a2a50513          	addi	a0,a0,-1494 # 80018f50 <lock_delete>
    8000452e:	00002097          	auipc	ra,0x2
    80004532:	962080e7          	jalr	-1694(ra) # 80005e90 <initsleeplock>
  initsleeplock(&lock_insert, "insert");
    80004536:	00005597          	auipc	a1,0x5
    8000453a:	32a58593          	addi	a1,a1,810 # 80009860 <syscalls+0x200>
    8000453e:	00015517          	auipc	a0,0x15
    80004542:	a4250513          	addi	a0,a0,-1470 # 80018f80 <lock_insert>
    80004546:	00002097          	auipc	ra,0x2
    8000454a:	94a080e7          	jalr	-1718(ra) # 80005e90 <initsleeplock>
  initsleeplock(&lock_print, "print");
    8000454e:	00005597          	auipc	a1,0x5
    80004552:	31a58593          	addi	a1,a1,794 # 80009868 <syscalls+0x208>
    80004556:	00015517          	auipc	a0,0x15
    8000455a:	a5a50513          	addi	a0,a0,-1446 # 80018fb0 <lock_print>
    8000455e:	00002097          	auipc	ra,0x2
    80004562:	932080e7          	jalr	-1742(ra) # 80005e90 <initsleeplock>
  for (int i = 0; i < SIZE; i++) {
    80004566:	00015497          	auipc	s1,0x15
    8000456a:	c7248493          	addi	s1,s1,-910 # 800191d8 <buffer+0x8>
    8000456e:	00016a17          	auipc	s4,0x16
    80004572:	84aa0a13          	addi	s4,s4,-1974 # 80019db8 <bcache+0x8>
    buffer[i].x = -1;
    80004576:	59fd                	li	s3,-1
    buffer[i].full = 0;
    initsleeplock(&buffer[i].lock, "buffer_lock");
    80004578:	00005917          	auipc	s2,0x5
    8000457c:	2f890913          	addi	s2,s2,760 # 80009870 <syscalls+0x210>
    buffer[i].x = -1;
    80004580:	ff34ac23          	sw	s3,-8(s1)
    buffer[i].full = 0;
    80004584:	fe04ae23          	sw	zero,-4(s1)
    initsleeplock(&buffer[i].lock, "buffer_lock");
    80004588:	85ca                	mv	a1,s2
    8000458a:	8526                	mv	a0,s1
    8000458c:	00002097          	auipc	ra,0x2
    80004590:	904080e7          	jalr	-1788(ra) # 80005e90 <initsleeplock>
    cond_init(&buffer[i].inserted);
    80004594:	03048513          	addi	a0,s1,48
    80004598:	00004097          	auipc	ra,0x4
    8000459c:	802080e7          	jalr	-2046(ra) # 80007d9a <cond_init>
    cond_init(&buffer[i].deleted);
    800045a0:	06048513          	addi	a0,s1,96
    800045a4:	00003097          	auipc	ra,0x3
    800045a8:	7f6080e7          	jalr	2038(ra) # 80007d9a <cond_init>
  for (int i = 0; i < SIZE; i++) {
    800045ac:	09848493          	addi	s1,s1,152
    800045b0:	fd4498e3          	bne	s1,s4,80004580 <sys_buffer_cond_init+0x82>
  }
  return 0;
}
    800045b4:	4501                	li	a0,0
    800045b6:	70a2                	ld	ra,40(sp)
    800045b8:	7402                	ld	s0,32(sp)
    800045ba:	64e2                	ld	s1,24(sp)
    800045bc:	6942                	ld	s2,16(sp)
    800045be:	69a2                	ld	s3,8(sp)
    800045c0:	6a02                	ld	s4,0(sp)
    800045c2:	6145                	addi	sp,sp,48
    800045c4:	8082                	ret

00000000800045c6 <sys_cond_produce>:

uint64
sys_cond_produce(void)
{
    800045c6:	715d                	addi	sp,sp,-80
    800045c8:	e486                	sd	ra,72(sp)
    800045ca:	e0a2                	sd	s0,64(sp)
    800045cc:	fc26                	sd	s1,56(sp)
    800045ce:	f84a                	sd	s2,48(sp)
    800045d0:	f44e                	sd	s3,40(sp)
    800045d2:	f052                	sd	s4,32(sp)
    800045d4:	ec56                	sd	s5,24(sp)
    800045d6:	0880                	addi	s0,sp,80
  int val;
  if(argint(0, &val) < 0) return -1;
    800045d8:	fbc40593          	addi	a1,s0,-68
    800045dc:	4501                	li	a0,0
    800045de:	fffff097          	auipc	ra,0xfffff
    800045e2:	7f6080e7          	jalr	2038(ra) # 80003dd4 <argint>
    800045e6:	57fd                	li	a5,-1
    800045e8:	0c054063          	bltz	a0,800046a8 <sys_cond_produce+0xe2>
  int index;
  acquiresleep(&lock_insert);
    800045ec:	00015497          	auipc	s1,0x15
    800045f0:	99448493          	addi	s1,s1,-1644 # 80018f80 <lock_insert>
    800045f4:	8526                	mv	a0,s1
    800045f6:	00002097          	auipc	ra,0x2
    800045fa:	8d4080e7          	jalr	-1836(ra) # 80005eca <acquiresleep>
  index = tail;
    800045fe:	00006717          	auipc	a4,0x6
    80004602:	a7e70713          	addi	a4,a4,-1410 # 8000a07c <tail>
    80004606:	00072a03          	lw	s4,0(a4)
  tail = (tail + 1) % SIZE;
    8000460a:	001a079b          	addiw	a5,s4,1
    8000460e:	46d1                	li	a3,20
    80004610:	02d7e7bb          	remw	a5,a5,a3
    80004614:	c31c                	sw	a5,0(a4)
  releasesleep(&lock_insert);
    80004616:	8526                	mv	a0,s1
    80004618:	00002097          	auipc	ra,0x2
    8000461c:	908080e7          	jalr	-1784(ra) # 80005f20 <releasesleep>
  acquiresleep(&buffer[index].lock);
    80004620:	09800a93          	li	s5,152
    80004624:	035a0ab3          	mul	s5,s4,s5
    80004628:	008a8493          	addi	s1,s5,8
    8000462c:	00015917          	auipc	s2,0x15
    80004630:	ba490913          	addi	s2,s2,-1116 # 800191d0 <buffer>
    80004634:	94ca                	add	s1,s1,s2
    80004636:	8526                	mv	a0,s1
    80004638:	00002097          	auipc	ra,0x2
    8000463c:	892080e7          	jalr	-1902(ra) # 80005eca <acquiresleep>
  while(buffer[index].full)
    80004640:	9956                	add	s2,s2,s5
    80004642:	00492783          	lw	a5,4(s2)
    80004646:	c785                	beqz	a5,8000466e <sys_cond_produce+0xa8>
    cond_wait(&buffer[index].deleted, &buffer[index].lock);
    80004648:	00015997          	auipc	s3,0x15
    8000464c:	bf098993          	addi	s3,s3,-1040 # 80019238 <buffer+0x68>
    80004650:	99d6                	add	s3,s3,s5
  while(buffer[index].full)
    80004652:	00015917          	auipc	s2,0x15
    80004656:	b7e90913          	addi	s2,s2,-1154 # 800191d0 <buffer>
    8000465a:	9956                	add	s2,s2,s5
    cond_wait(&buffer[index].deleted, &buffer[index].lock);
    8000465c:	85a6                	mv	a1,s1
    8000465e:	854e                	mv	a0,s3
    80004660:	00003097          	auipc	ra,0x3
    80004664:	6f2080e7          	jalr	1778(ra) # 80007d52 <cond_wait>
  while(buffer[index].full)
    80004668:	00492783          	lw	a5,4(s2)
    8000466c:	fbe5                	bnez	a5,8000465c <sys_cond_produce+0x96>
  buffer[index].x = val;
    8000466e:	00015517          	auipc	a0,0x15
    80004672:	b6250513          	addi	a0,a0,-1182 # 800191d0 <buffer>
    80004676:	09800793          	li	a5,152
    8000467a:	02fa0a33          	mul	s4,s4,a5
    8000467e:	9a2a                	add	s4,s4,a0
    80004680:	fbc42783          	lw	a5,-68(s0)
    80004684:	00fa2023          	sw	a5,0(s4)
  buffer[index].full = 1;
    80004688:	4785                	li	a5,1
    8000468a:	00fa2223          	sw	a5,4(s4)
  cond_signal(&buffer[index].inserted);
    8000468e:	038a8a93          	addi	s5,s5,56
    80004692:	9556                	add	a0,a0,s5
    80004694:	00003097          	auipc	ra,0x3
    80004698:	6d6080e7          	jalr	1750(ra) # 80007d6a <cond_signal>
  releasesleep(&buffer[index].lock);
    8000469c:	8526                	mv	a0,s1
    8000469e:	00002097          	auipc	ra,0x2
    800046a2:	882080e7          	jalr	-1918(ra) # 80005f20 <releasesleep>
  return 0;
    800046a6:	4781                	li	a5,0
}
    800046a8:	853e                	mv	a0,a5
    800046aa:	60a6                	ld	ra,72(sp)
    800046ac:	6406                	ld	s0,64(sp)
    800046ae:	74e2                	ld	s1,56(sp)
    800046b0:	7942                	ld	s2,48(sp)
    800046b2:	79a2                	ld	s3,40(sp)
    800046b4:	7a02                	ld	s4,32(sp)
    800046b6:	6ae2                	ld	s5,24(sp)
    800046b8:	6161                	addi	sp,sp,80
    800046ba:	8082                	ret

00000000800046bc <sys_cond_consume>:

uint64
sys_cond_consume(void)
{
    800046bc:	7139                	addi	sp,sp,-64
    800046be:	fc06                	sd	ra,56(sp)
    800046c0:	f822                	sd	s0,48(sp)
    800046c2:	f426                	sd	s1,40(sp)
    800046c4:	f04a                	sd	s2,32(sp)
    800046c6:	ec4e                	sd	s3,24(sp)
    800046c8:	e852                	sd	s4,16(sp)
    800046ca:	e456                	sd	s5,8(sp)
    800046cc:	0080                	addi	s0,sp,64
  int index, v;
  acquiresleep(&lock_delete);
    800046ce:	00015497          	auipc	s1,0x15
    800046d2:	88248493          	addi	s1,s1,-1918 # 80018f50 <lock_delete>
    800046d6:	8526                	mv	a0,s1
    800046d8:	00001097          	auipc	ra,0x1
    800046dc:	7f2080e7          	jalr	2034(ra) # 80005eca <acquiresleep>
  index = head;
    800046e0:	00006717          	auipc	a4,0x6
    800046e4:	99870713          	addi	a4,a4,-1640 # 8000a078 <head>
    800046e8:	00072a03          	lw	s4,0(a4)
  head = (head + 1) % SIZE;
    800046ec:	001a079b          	addiw	a5,s4,1
    800046f0:	46d1                	li	a3,20
    800046f2:	02d7e7bb          	remw	a5,a5,a3
    800046f6:	c31c                	sw	a5,0(a4)
  releasesleep(&lock_delete);
    800046f8:	8526                	mv	a0,s1
    800046fa:	00002097          	auipc	ra,0x2
    800046fe:	826080e7          	jalr	-2010(ra) # 80005f20 <releasesleep>
  acquiresleep(&buffer[index].lock);
    80004702:	09800a93          	li	s5,152
    80004706:	035a0ab3          	mul	s5,s4,s5
    8000470a:	008a8493          	addi	s1,s5,8
    8000470e:	00015917          	auipc	s2,0x15
    80004712:	ac290913          	addi	s2,s2,-1342 # 800191d0 <buffer>
    80004716:	94ca                	add	s1,s1,s2
    80004718:	8526                	mv	a0,s1
    8000471a:	00001097          	auipc	ra,0x1
    8000471e:	7b0080e7          	jalr	1968(ra) # 80005eca <acquiresleep>
  while (!buffer[index].full)
    80004722:	9956                	add	s2,s2,s5
    80004724:	00492783          	lw	a5,4(s2)
    80004728:	e785                	bnez	a5,80004750 <sys_cond_consume+0x94>
    cond_wait(&buffer[index].inserted, &buffer[index].lock);
    8000472a:	00015997          	auipc	s3,0x15
    8000472e:	ade98993          	addi	s3,s3,-1314 # 80019208 <buffer+0x38>
    80004732:	99d6                	add	s3,s3,s5
  while (!buffer[index].full)
    80004734:	00015917          	auipc	s2,0x15
    80004738:	a9c90913          	addi	s2,s2,-1380 # 800191d0 <buffer>
    8000473c:	9956                	add	s2,s2,s5
    cond_wait(&buffer[index].inserted, &buffer[index].lock);
    8000473e:	85a6                	mv	a1,s1
    80004740:	854e                	mv	a0,s3
    80004742:	00003097          	auipc	ra,0x3
    80004746:	610080e7          	jalr	1552(ra) # 80007d52 <cond_wait>
  while (!buffer[index].full)
    8000474a:	00492783          	lw	a5,4(s2)
    8000474e:	dbe5                	beqz	a5,8000473e <sys_cond_consume+0x82>
  v = buffer[index].x;
    80004750:	00015517          	auipc	a0,0x15
    80004754:	a8050513          	addi	a0,a0,-1408 # 800191d0 <buffer>
    80004758:	09800793          	li	a5,152
    8000475c:	02fa0a33          	mul	s4,s4,a5
    80004760:	9a2a                	add	s4,s4,a0
    80004762:	000a2903          	lw	s2,0(s4)
  buffer[index].full = 0;
    80004766:	000a2223          	sw	zero,4(s4)
  cond_signal(&buffer[index].deleted);
    8000476a:	068a8a93          	addi	s5,s5,104
    8000476e:	9556                	add	a0,a0,s5
    80004770:	00003097          	auipc	ra,0x3
    80004774:	5fa080e7          	jalr	1530(ra) # 80007d6a <cond_signal>
  releasesleep(&buffer[index].lock);
    80004778:	8526                	mv	a0,s1
    8000477a:	00001097          	auipc	ra,0x1
    8000477e:	7a6080e7          	jalr	1958(ra) # 80005f20 <releasesleep>
  acquiresleep(&lock_print);
    80004782:	00015497          	auipc	s1,0x15
    80004786:	82e48493          	addi	s1,s1,-2002 # 80018fb0 <lock_print>
    8000478a:	8526                	mv	a0,s1
    8000478c:	00001097          	auipc	ra,0x1
    80004790:	73e080e7          	jalr	1854(ra) # 80005eca <acquiresleep>
  printf("%d ", v);
    80004794:	85ca                	mv	a1,s2
    80004796:	00005517          	auipc	a0,0x5
    8000479a:	0ea50513          	addi	a0,a0,234 # 80009880 <syscalls+0x220>
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	de6080e7          	jalr	-538(ra) # 80000584 <printf>
  releasesleep(&lock_print);
    800047a6:	8526                	mv	a0,s1
    800047a8:	00001097          	auipc	ra,0x1
    800047ac:	778080e7          	jalr	1912(ra) # 80005f20 <releasesleep>
  return v;
}
    800047b0:	854a                	mv	a0,s2
    800047b2:	70e2                	ld	ra,56(sp)
    800047b4:	7442                	ld	s0,48(sp)
    800047b6:	74a2                	ld	s1,40(sp)
    800047b8:	7902                	ld	s2,32(sp)
    800047ba:	69e2                	ld	s3,24(sp)
    800047bc:	6a42                	ld	s4,16(sp)
    800047be:	6aa2                	ld	s5,8(sp)
    800047c0:	6121                	addi	sp,sp,64
    800047c2:	8082                	ret

00000000800047c4 <sys_buffer_sem_init>:

uint64
sys_buffer_sem_init(void)
{
    800047c4:	1141                	addi	sp,sp,-16
    800047c6:	e406                	sd	ra,8(sp)
    800047c8:	e022                	sd	s0,0(sp)
    800047ca:	0800                	addi	s0,sp,16
  nextp = 0;
    800047cc:	00006797          	auipc	a5,0x6
    800047d0:	8a07a423          	sw	zero,-1880(a5) # 8000a074 <nextp>
  nextc = 0;
    800047d4:	00006797          	auipc	a5,0x6
    800047d8:	8807ae23          	sw	zero,-1892(a5) # 8000a070 <nextc>
  sem_init(&pro, 1);
    800047dc:	4585                	li	a1,1
    800047de:	00015517          	auipc	a0,0x15
    800047e2:	80250513          	addi	a0,a0,-2046 # 80018fe0 <pro>
    800047e6:	00003097          	auipc	ra,0x3
    800047ea:	5d4080e7          	jalr	1492(ra) # 80007dba <sem_init>
  sem_init(&con, 1);
    800047ee:	4585                	li	a1,1
    800047f0:	00015517          	auipc	a0,0x15
    800047f4:	85850513          	addi	a0,a0,-1960 # 80019048 <con>
    800047f8:	00003097          	auipc	ra,0x3
    800047fc:	5c2080e7          	jalr	1474(ra) # 80007dba <sem_init>
  sem_init(&empty, N);
    80004800:	45d1                	li	a1,20
    80004802:	00015517          	auipc	a0,0x15
    80004806:	8ae50513          	addi	a0,a0,-1874 # 800190b0 <empty>
    8000480a:	00003097          	auipc	ra,0x3
    8000480e:	5b0080e7          	jalr	1456(ra) # 80007dba <sem_init>
  sem_init(&full, 0);
    80004812:	4581                	li	a1,0
    80004814:	00015517          	auipc	a0,0x15
    80004818:	90450513          	addi	a0,a0,-1788 # 80019118 <full>
    8000481c:	00003097          	auipc	ra,0x3
    80004820:	59e080e7          	jalr	1438(ra) # 80007dba <sem_init>
  return 0;
}
    80004824:	4501                	li	a0,0
    80004826:	60a2                	ld	ra,8(sp)
    80004828:	6402                	ld	s0,0(sp)
    8000482a:	0141                	addi	sp,sp,16
    8000482c:	8082                	ret

000000008000482e <sys_sem_produce>:

uint64
sys_sem_produce(void)
{
    8000482e:	7179                	addi	sp,sp,-48
    80004830:	f406                	sd	ra,40(sp)
    80004832:	f022                	sd	s0,32(sp)
    80004834:	ec26                	sd	s1,24(sp)
    80004836:	1800                	addi	s0,sp,48
  int val;
  if(argint(0, &val) < 0) return -1;
    80004838:	fdc40593          	addi	a1,s0,-36
    8000483c:	4501                	li	a0,0
    8000483e:	fffff097          	auipc	ra,0xfffff
    80004842:	596080e7          	jalr	1430(ra) # 80003dd4 <argint>
    80004846:	57fd                	li	a5,-1
    80004848:	06054663          	bltz	a0,800048b4 <sys_sem_produce+0x86>
  sem_wait(&empty);
    8000484c:	00015517          	auipc	a0,0x15
    80004850:	86450513          	addi	a0,a0,-1948 # 800190b0 <empty>
    80004854:	00003097          	auipc	ra,0x3
    80004858:	59e080e7          	jalr	1438(ra) # 80007df2 <sem_wait>
  sem_wait(&pro);
    8000485c:	00014497          	auipc	s1,0x14
    80004860:	78448493          	addi	s1,s1,1924 # 80018fe0 <pro>
    80004864:	8526                	mv	a0,s1
    80004866:	00003097          	auipc	ra,0x3
    8000486a:	58c080e7          	jalr	1420(ra) # 80007df2 <sem_wait>
  sem_buffer[nextp] = val;
    8000486e:	00006697          	auipc	a3,0x6
    80004872:	80668693          	addi	a3,a3,-2042 # 8000a074 <nextp>
    80004876:	429c                	lw	a5,0(a3)
    80004878:	00279613          	slli	a2,a5,0x2
    8000487c:	00014717          	auipc	a4,0x14
    80004880:	2c470713          	addi	a4,a4,708 # 80018b40 <barriers>
    80004884:	9732                	add	a4,a4,a2
    80004886:	fdc42603          	lw	a2,-36(s0)
    8000488a:	64c72023          	sw	a2,1600(a4)
  nextp = (nextp + 1)%N;
    8000488e:	2785                	addiw	a5,a5,1
    80004890:	4751                	li	a4,20
    80004892:	02e7e7bb          	remw	a5,a5,a4
    80004896:	c29c                	sw	a5,0(a3)
  sem_post (&pro);
    80004898:	8526                	mv	a0,s1
    8000489a:	00003097          	auipc	ra,0x3
    8000489e:	5ae080e7          	jalr	1454(ra) # 80007e48 <sem_post>
  sem_post (&full);
    800048a2:	00015517          	auipc	a0,0x15
    800048a6:	87650513          	addi	a0,a0,-1930 # 80019118 <full>
    800048aa:	00003097          	auipc	ra,0x3
    800048ae:	59e080e7          	jalr	1438(ra) # 80007e48 <sem_post>
  return 0;
    800048b2:	4781                	li	a5,0
}
    800048b4:	853e                	mv	a0,a5
    800048b6:	70a2                	ld	ra,40(sp)
    800048b8:	7402                	ld	s0,32(sp)
    800048ba:	64e2                	ld	s1,24(sp)
    800048bc:	6145                	addi	sp,sp,48
    800048be:	8082                	ret

00000000800048c0 <sys_sem_consume>:

uint64
sys_sem_consume(void)
{
    800048c0:	1101                	addi	sp,sp,-32
    800048c2:	ec06                	sd	ra,24(sp)
    800048c4:	e822                	sd	s0,16(sp)
    800048c6:	e426                	sd	s1,8(sp)
    800048c8:	e04a                	sd	s2,0(sp)
    800048ca:	1000                	addi	s0,sp,32
  int v;
  sem_wait (&full);
    800048cc:	00015517          	auipc	a0,0x15
    800048d0:	84c50513          	addi	a0,a0,-1972 # 80019118 <full>
    800048d4:	00003097          	auipc	ra,0x3
    800048d8:	51e080e7          	jalr	1310(ra) # 80007df2 <sem_wait>
  sem_wait (&con);
    800048dc:	00014917          	auipc	s2,0x14
    800048e0:	76c90913          	addi	s2,s2,1900 # 80019048 <con>
    800048e4:	854a                	mv	a0,s2
    800048e6:	00003097          	auipc	ra,0x3
    800048ea:	50c080e7          	jalr	1292(ra) # 80007df2 <sem_wait>
  v = sem_buffer[nextc];
    800048ee:	00005697          	auipc	a3,0x5
    800048f2:	78268693          	addi	a3,a3,1922 # 8000a070 <nextc>
    800048f6:	429c                	lw	a5,0(a3)
    800048f8:	00279613          	slli	a2,a5,0x2
    800048fc:	00014717          	auipc	a4,0x14
    80004900:	24470713          	addi	a4,a4,580 # 80018b40 <barriers>
    80004904:	9732                	add	a4,a4,a2
    80004906:	64072483          	lw	s1,1600(a4)
  nextc = (nextc+1)%N;
    8000490a:	2785                	addiw	a5,a5,1
    8000490c:	4751                	li	a4,20
    8000490e:	02e7e7bb          	remw	a5,a5,a4
    80004912:	c29c                	sw	a5,0(a3)
  sem_post (&con);
    80004914:	854a                	mv	a0,s2
    80004916:	00003097          	auipc	ra,0x3
    8000491a:	532080e7          	jalr	1330(ra) # 80007e48 <sem_post>
  sem_post (&empty);
    8000491e:	00014517          	auipc	a0,0x14
    80004922:	79250513          	addi	a0,a0,1938 # 800190b0 <empty>
    80004926:	00003097          	auipc	ra,0x3
    8000492a:	522080e7          	jalr	1314(ra) # 80007e48 <sem_post>
  acquiresleep(&lock_print);
    8000492e:	00014917          	auipc	s2,0x14
    80004932:	68290913          	addi	s2,s2,1666 # 80018fb0 <lock_print>
    80004936:	854a                	mv	a0,s2
    80004938:	00001097          	auipc	ra,0x1
    8000493c:	592080e7          	jalr	1426(ra) # 80005eca <acquiresleep>
  printf("%d ", v);
    80004940:	85a6                	mv	a1,s1
    80004942:	00005517          	auipc	a0,0x5
    80004946:	f3e50513          	addi	a0,a0,-194 # 80009880 <syscalls+0x220>
    8000494a:	ffffc097          	auipc	ra,0xffffc
    8000494e:	c3a080e7          	jalr	-966(ra) # 80000584 <printf>
  releasesleep(&lock_print);
    80004952:	854a                	mv	a0,s2
    80004954:	00001097          	auipc	ra,0x1
    80004958:	5cc080e7          	jalr	1484(ra) # 80005f20 <releasesleep>
  return v;
    8000495c:	8526                	mv	a0,s1
    8000495e:	60e2                	ld	ra,24(sp)
    80004960:	6442                	ld	s0,16(sp)
    80004962:	64a2                	ld	s1,8(sp)
    80004964:	6902                	ld	s2,0(sp)
    80004966:	6105                	addi	sp,sp,32
    80004968:	8082                	ret

000000008000496a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000496a:	7179                	addi	sp,sp,-48
    8000496c:	f406                	sd	ra,40(sp)
    8000496e:	f022                	sd	s0,32(sp)
    80004970:	ec26                	sd	s1,24(sp)
    80004972:	e84a                	sd	s2,16(sp)
    80004974:	e44e                	sd	s3,8(sp)
    80004976:	e052                	sd	s4,0(sp)
    80004978:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000497a:	00005597          	auipc	a1,0x5
    8000497e:	f0e58593          	addi	a1,a1,-242 # 80009888 <syscalls+0x228>
    80004982:	00015517          	auipc	a0,0x15
    80004986:	42e50513          	addi	a0,a0,1070 # 80019db0 <bcache>
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	1b6080e7          	jalr	438(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80004992:	0001d797          	auipc	a5,0x1d
    80004996:	41e78793          	addi	a5,a5,1054 # 80021db0 <bcache+0x8000>
    8000499a:	0001d717          	auipc	a4,0x1d
    8000499e:	67e70713          	addi	a4,a4,1662 # 80022018 <bcache+0x8268>
    800049a2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800049a6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800049aa:	00015497          	auipc	s1,0x15
    800049ae:	41e48493          	addi	s1,s1,1054 # 80019dc8 <bcache+0x18>
    b->next = bcache.head.next;
    800049b2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800049b4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800049b6:	00005a17          	auipc	s4,0x5
    800049ba:	edaa0a13          	addi	s4,s4,-294 # 80009890 <syscalls+0x230>
    b->next = bcache.head.next;
    800049be:	2b893783          	ld	a5,696(s2)
    800049c2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800049c4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800049c8:	85d2                	mv	a1,s4
    800049ca:	01048513          	addi	a0,s1,16
    800049ce:	00001097          	auipc	ra,0x1
    800049d2:	4c2080e7          	jalr	1218(ra) # 80005e90 <initsleeplock>
    bcache.head.next->prev = b;
    800049d6:	2b893783          	ld	a5,696(s2)
    800049da:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800049dc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800049e0:	45848493          	addi	s1,s1,1112
    800049e4:	fd349de3          	bne	s1,s3,800049be <binit+0x54>
  }
}
    800049e8:	70a2                	ld	ra,40(sp)
    800049ea:	7402                	ld	s0,32(sp)
    800049ec:	64e2                	ld	s1,24(sp)
    800049ee:	6942                	ld	s2,16(sp)
    800049f0:	69a2                	ld	s3,8(sp)
    800049f2:	6a02                	ld	s4,0(sp)
    800049f4:	6145                	addi	sp,sp,48
    800049f6:	8082                	ret

00000000800049f8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800049f8:	7179                	addi	sp,sp,-48
    800049fa:	f406                	sd	ra,40(sp)
    800049fc:	f022                	sd	s0,32(sp)
    800049fe:	ec26                	sd	s1,24(sp)
    80004a00:	e84a                	sd	s2,16(sp)
    80004a02:	e44e                	sd	s3,8(sp)
    80004a04:	1800                	addi	s0,sp,48
    80004a06:	892a                	mv	s2,a0
    80004a08:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80004a0a:	00015517          	auipc	a0,0x15
    80004a0e:	3a650513          	addi	a0,a0,934 # 80019db0 <bcache>
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	1be080e7          	jalr	446(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004a1a:	0001d497          	auipc	s1,0x1d
    80004a1e:	64e4b483          	ld	s1,1614(s1) # 80022068 <bcache+0x82b8>
    80004a22:	0001d797          	auipc	a5,0x1d
    80004a26:	5f678793          	addi	a5,a5,1526 # 80022018 <bcache+0x8268>
    80004a2a:	02f48f63          	beq	s1,a5,80004a68 <bread+0x70>
    80004a2e:	873e                	mv	a4,a5
    80004a30:	a021                	j	80004a38 <bread+0x40>
    80004a32:	68a4                	ld	s1,80(s1)
    80004a34:	02e48a63          	beq	s1,a4,80004a68 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80004a38:	449c                	lw	a5,8(s1)
    80004a3a:	ff279ce3          	bne	a5,s2,80004a32 <bread+0x3a>
    80004a3e:	44dc                	lw	a5,12(s1)
    80004a40:	ff3799e3          	bne	a5,s3,80004a32 <bread+0x3a>
      b->refcnt++;
    80004a44:	40bc                	lw	a5,64(s1)
    80004a46:	2785                	addiw	a5,a5,1
    80004a48:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004a4a:	00015517          	auipc	a0,0x15
    80004a4e:	36650513          	addi	a0,a0,870 # 80019db0 <bcache>
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	232080e7          	jalr	562(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80004a5a:	01048513          	addi	a0,s1,16
    80004a5e:	00001097          	auipc	ra,0x1
    80004a62:	46c080e7          	jalr	1132(ra) # 80005eca <acquiresleep>
      return b;
    80004a66:	a8b9                	j	80004ac4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004a68:	0001d497          	auipc	s1,0x1d
    80004a6c:	5f84b483          	ld	s1,1528(s1) # 80022060 <bcache+0x82b0>
    80004a70:	0001d797          	auipc	a5,0x1d
    80004a74:	5a878793          	addi	a5,a5,1448 # 80022018 <bcache+0x8268>
    80004a78:	00f48863          	beq	s1,a5,80004a88 <bread+0x90>
    80004a7c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80004a7e:	40bc                	lw	a5,64(s1)
    80004a80:	cf81                	beqz	a5,80004a98 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004a82:	64a4                	ld	s1,72(s1)
    80004a84:	fee49de3          	bne	s1,a4,80004a7e <bread+0x86>
  panic("bget: no buffers");
    80004a88:	00005517          	auipc	a0,0x5
    80004a8c:	e1050513          	addi	a0,a0,-496 # 80009898 <syscalls+0x238>
    80004a90:	ffffc097          	auipc	ra,0xffffc
    80004a94:	aaa080e7          	jalr	-1366(ra) # 8000053a <panic>
      b->dev = dev;
    80004a98:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80004a9c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80004aa0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80004aa4:	4785                	li	a5,1
    80004aa6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004aa8:	00015517          	auipc	a0,0x15
    80004aac:	30850513          	addi	a0,a0,776 # 80019db0 <bcache>
    80004ab0:	ffffc097          	auipc	ra,0xffffc
    80004ab4:	1d4080e7          	jalr	468(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80004ab8:	01048513          	addi	a0,s1,16
    80004abc:	00001097          	auipc	ra,0x1
    80004ac0:	40e080e7          	jalr	1038(ra) # 80005eca <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80004ac4:	409c                	lw	a5,0(s1)
    80004ac6:	cb89                	beqz	a5,80004ad8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004ac8:	8526                	mv	a0,s1
    80004aca:	70a2                	ld	ra,40(sp)
    80004acc:	7402                	ld	s0,32(sp)
    80004ace:	64e2                	ld	s1,24(sp)
    80004ad0:	6942                	ld	s2,16(sp)
    80004ad2:	69a2                	ld	s3,8(sp)
    80004ad4:	6145                	addi	sp,sp,48
    80004ad6:	8082                	ret
    virtio_disk_rw(b, 0);
    80004ad8:	4581                	li	a1,0
    80004ada:	8526                	mv	a0,s1
    80004adc:	00003097          	auipc	ra,0x3
    80004ae0:	f26080e7          	jalr	-218(ra) # 80007a02 <virtio_disk_rw>
    b->valid = 1;
    80004ae4:	4785                	li	a5,1
    80004ae6:	c09c                	sw	a5,0(s1)
  return b;
    80004ae8:	b7c5                	j	80004ac8 <bread+0xd0>

0000000080004aea <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004aea:	1101                	addi	sp,sp,-32
    80004aec:	ec06                	sd	ra,24(sp)
    80004aee:	e822                	sd	s0,16(sp)
    80004af0:	e426                	sd	s1,8(sp)
    80004af2:	1000                	addi	s0,sp,32
    80004af4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004af6:	0541                	addi	a0,a0,16
    80004af8:	00001097          	auipc	ra,0x1
    80004afc:	46c080e7          	jalr	1132(ra) # 80005f64 <holdingsleep>
    80004b00:	cd01                	beqz	a0,80004b18 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80004b02:	4585                	li	a1,1
    80004b04:	8526                	mv	a0,s1
    80004b06:	00003097          	auipc	ra,0x3
    80004b0a:	efc080e7          	jalr	-260(ra) # 80007a02 <virtio_disk_rw>
}
    80004b0e:	60e2                	ld	ra,24(sp)
    80004b10:	6442                	ld	s0,16(sp)
    80004b12:	64a2                	ld	s1,8(sp)
    80004b14:	6105                	addi	sp,sp,32
    80004b16:	8082                	ret
    panic("bwrite");
    80004b18:	00005517          	auipc	a0,0x5
    80004b1c:	d9850513          	addi	a0,a0,-616 # 800098b0 <syscalls+0x250>
    80004b20:	ffffc097          	auipc	ra,0xffffc
    80004b24:	a1a080e7          	jalr	-1510(ra) # 8000053a <panic>

0000000080004b28 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004b28:	1101                	addi	sp,sp,-32
    80004b2a:	ec06                	sd	ra,24(sp)
    80004b2c:	e822                	sd	s0,16(sp)
    80004b2e:	e426                	sd	s1,8(sp)
    80004b30:	e04a                	sd	s2,0(sp)
    80004b32:	1000                	addi	s0,sp,32
    80004b34:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004b36:	01050913          	addi	s2,a0,16
    80004b3a:	854a                	mv	a0,s2
    80004b3c:	00001097          	auipc	ra,0x1
    80004b40:	428080e7          	jalr	1064(ra) # 80005f64 <holdingsleep>
    80004b44:	c92d                	beqz	a0,80004bb6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80004b46:	854a                	mv	a0,s2
    80004b48:	00001097          	auipc	ra,0x1
    80004b4c:	3d8080e7          	jalr	984(ra) # 80005f20 <releasesleep>

  acquire(&bcache.lock);
    80004b50:	00015517          	auipc	a0,0x15
    80004b54:	26050513          	addi	a0,a0,608 # 80019db0 <bcache>
    80004b58:	ffffc097          	auipc	ra,0xffffc
    80004b5c:	078080e7          	jalr	120(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80004b60:	40bc                	lw	a5,64(s1)
    80004b62:	37fd                	addiw	a5,a5,-1
    80004b64:	0007871b          	sext.w	a4,a5
    80004b68:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80004b6a:	eb05                	bnez	a4,80004b9a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004b6c:	68bc                	ld	a5,80(s1)
    80004b6e:	64b8                	ld	a4,72(s1)
    80004b70:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80004b72:	64bc                	ld	a5,72(s1)
    80004b74:	68b8                	ld	a4,80(s1)
    80004b76:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80004b78:	0001d797          	auipc	a5,0x1d
    80004b7c:	23878793          	addi	a5,a5,568 # 80021db0 <bcache+0x8000>
    80004b80:	2b87b703          	ld	a4,696(a5)
    80004b84:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80004b86:	0001d717          	auipc	a4,0x1d
    80004b8a:	49270713          	addi	a4,a4,1170 # 80022018 <bcache+0x8268>
    80004b8e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80004b90:	2b87b703          	ld	a4,696(a5)
    80004b94:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004b96:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004b9a:	00015517          	auipc	a0,0x15
    80004b9e:	21650513          	addi	a0,a0,534 # 80019db0 <bcache>
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	0e2080e7          	jalr	226(ra) # 80000c84 <release>
}
    80004baa:	60e2                	ld	ra,24(sp)
    80004bac:	6442                	ld	s0,16(sp)
    80004bae:	64a2                	ld	s1,8(sp)
    80004bb0:	6902                	ld	s2,0(sp)
    80004bb2:	6105                	addi	sp,sp,32
    80004bb4:	8082                	ret
    panic("brelse");
    80004bb6:	00005517          	auipc	a0,0x5
    80004bba:	d0250513          	addi	a0,a0,-766 # 800098b8 <syscalls+0x258>
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	97c080e7          	jalr	-1668(ra) # 8000053a <panic>

0000000080004bc6 <bpin>:

void
bpin(struct buf *b) {
    80004bc6:	1101                	addi	sp,sp,-32
    80004bc8:	ec06                	sd	ra,24(sp)
    80004bca:	e822                	sd	s0,16(sp)
    80004bcc:	e426                	sd	s1,8(sp)
    80004bce:	1000                	addi	s0,sp,32
    80004bd0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004bd2:	00015517          	auipc	a0,0x15
    80004bd6:	1de50513          	addi	a0,a0,478 # 80019db0 <bcache>
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	ff6080e7          	jalr	-10(ra) # 80000bd0 <acquire>
  b->refcnt++;
    80004be2:	40bc                	lw	a5,64(s1)
    80004be4:	2785                	addiw	a5,a5,1
    80004be6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004be8:	00015517          	auipc	a0,0x15
    80004bec:	1c850513          	addi	a0,a0,456 # 80019db0 <bcache>
    80004bf0:	ffffc097          	auipc	ra,0xffffc
    80004bf4:	094080e7          	jalr	148(ra) # 80000c84 <release>
}
    80004bf8:	60e2                	ld	ra,24(sp)
    80004bfa:	6442                	ld	s0,16(sp)
    80004bfc:	64a2                	ld	s1,8(sp)
    80004bfe:	6105                	addi	sp,sp,32
    80004c00:	8082                	ret

0000000080004c02 <bunpin>:

void
bunpin(struct buf *b) {
    80004c02:	1101                	addi	sp,sp,-32
    80004c04:	ec06                	sd	ra,24(sp)
    80004c06:	e822                	sd	s0,16(sp)
    80004c08:	e426                	sd	s1,8(sp)
    80004c0a:	1000                	addi	s0,sp,32
    80004c0c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004c0e:	00015517          	auipc	a0,0x15
    80004c12:	1a250513          	addi	a0,a0,418 # 80019db0 <bcache>
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	fba080e7          	jalr	-70(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80004c1e:	40bc                	lw	a5,64(s1)
    80004c20:	37fd                	addiw	a5,a5,-1
    80004c22:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004c24:	00015517          	auipc	a0,0x15
    80004c28:	18c50513          	addi	a0,a0,396 # 80019db0 <bcache>
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	058080e7          	jalr	88(ra) # 80000c84 <release>
}
    80004c34:	60e2                	ld	ra,24(sp)
    80004c36:	6442                	ld	s0,16(sp)
    80004c38:	64a2                	ld	s1,8(sp)
    80004c3a:	6105                	addi	sp,sp,32
    80004c3c:	8082                	ret

0000000080004c3e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004c3e:	1101                	addi	sp,sp,-32
    80004c40:	ec06                	sd	ra,24(sp)
    80004c42:	e822                	sd	s0,16(sp)
    80004c44:	e426                	sd	s1,8(sp)
    80004c46:	e04a                	sd	s2,0(sp)
    80004c48:	1000                	addi	s0,sp,32
    80004c4a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004c4c:	00d5d59b          	srliw	a1,a1,0xd
    80004c50:	0001e797          	auipc	a5,0x1e
    80004c54:	83c7a783          	lw	a5,-1988(a5) # 8002248c <sb+0x1c>
    80004c58:	9dbd                	addw	a1,a1,a5
    80004c5a:	00000097          	auipc	ra,0x0
    80004c5e:	d9e080e7          	jalr	-610(ra) # 800049f8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80004c62:	0074f713          	andi	a4,s1,7
    80004c66:	4785                	li	a5,1
    80004c68:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004c6c:	14ce                	slli	s1,s1,0x33
    80004c6e:	90d9                	srli	s1,s1,0x36
    80004c70:	00950733          	add	a4,a0,s1
    80004c74:	05874703          	lbu	a4,88(a4)
    80004c78:	00e7f6b3          	and	a3,a5,a4
    80004c7c:	c69d                	beqz	a3,80004caa <bfree+0x6c>
    80004c7e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80004c80:	94aa                	add	s1,s1,a0
    80004c82:	fff7c793          	not	a5,a5
    80004c86:	8f7d                	and	a4,a4,a5
    80004c88:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80004c8c:	00001097          	auipc	ra,0x1
    80004c90:	120080e7          	jalr	288(ra) # 80005dac <log_write>
  brelse(bp);
    80004c94:	854a                	mv	a0,s2
    80004c96:	00000097          	auipc	ra,0x0
    80004c9a:	e92080e7          	jalr	-366(ra) # 80004b28 <brelse>
}
    80004c9e:	60e2                	ld	ra,24(sp)
    80004ca0:	6442                	ld	s0,16(sp)
    80004ca2:	64a2                	ld	s1,8(sp)
    80004ca4:	6902                	ld	s2,0(sp)
    80004ca6:	6105                	addi	sp,sp,32
    80004ca8:	8082                	ret
    panic("freeing free block");
    80004caa:	00005517          	auipc	a0,0x5
    80004cae:	c1650513          	addi	a0,a0,-1002 # 800098c0 <syscalls+0x260>
    80004cb2:	ffffc097          	auipc	ra,0xffffc
    80004cb6:	888080e7          	jalr	-1912(ra) # 8000053a <panic>

0000000080004cba <balloc>:
{
    80004cba:	711d                	addi	sp,sp,-96
    80004cbc:	ec86                	sd	ra,88(sp)
    80004cbe:	e8a2                	sd	s0,80(sp)
    80004cc0:	e4a6                	sd	s1,72(sp)
    80004cc2:	e0ca                	sd	s2,64(sp)
    80004cc4:	fc4e                	sd	s3,56(sp)
    80004cc6:	f852                	sd	s4,48(sp)
    80004cc8:	f456                	sd	s5,40(sp)
    80004cca:	f05a                	sd	s6,32(sp)
    80004ccc:	ec5e                	sd	s7,24(sp)
    80004cce:	e862                	sd	s8,16(sp)
    80004cd0:	e466                	sd	s9,8(sp)
    80004cd2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80004cd4:	0001d797          	auipc	a5,0x1d
    80004cd8:	7a07a783          	lw	a5,1952(a5) # 80022474 <sb+0x4>
    80004cdc:	cbc1                	beqz	a5,80004d6c <balloc+0xb2>
    80004cde:	8baa                	mv	s7,a0
    80004ce0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004ce2:	0001db17          	auipc	s6,0x1d
    80004ce6:	78eb0b13          	addi	s6,s6,1934 # 80022470 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004cea:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004cec:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004cee:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004cf0:	6c89                	lui	s9,0x2
    80004cf2:	a831                	j	80004d0e <balloc+0x54>
    brelse(bp);
    80004cf4:	854a                	mv	a0,s2
    80004cf6:	00000097          	auipc	ra,0x0
    80004cfa:	e32080e7          	jalr	-462(ra) # 80004b28 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004cfe:	015c87bb          	addw	a5,s9,s5
    80004d02:	00078a9b          	sext.w	s5,a5
    80004d06:	004b2703          	lw	a4,4(s6)
    80004d0a:	06eaf163          	bgeu	s5,a4,80004d6c <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80004d0e:	41fad79b          	sraiw	a5,s5,0x1f
    80004d12:	0137d79b          	srliw	a5,a5,0x13
    80004d16:	015787bb          	addw	a5,a5,s5
    80004d1a:	40d7d79b          	sraiw	a5,a5,0xd
    80004d1e:	01cb2583          	lw	a1,28(s6)
    80004d22:	9dbd                	addw	a1,a1,a5
    80004d24:	855e                	mv	a0,s7
    80004d26:	00000097          	auipc	ra,0x0
    80004d2a:	cd2080e7          	jalr	-814(ra) # 800049f8 <bread>
    80004d2e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004d30:	004b2503          	lw	a0,4(s6)
    80004d34:	000a849b          	sext.w	s1,s5
    80004d38:	8762                	mv	a4,s8
    80004d3a:	faa4fde3          	bgeu	s1,a0,80004cf4 <balloc+0x3a>
      m = 1 << (bi % 8);
    80004d3e:	00777693          	andi	a3,a4,7
    80004d42:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004d46:	41f7579b          	sraiw	a5,a4,0x1f
    80004d4a:	01d7d79b          	srliw	a5,a5,0x1d
    80004d4e:	9fb9                	addw	a5,a5,a4
    80004d50:	4037d79b          	sraiw	a5,a5,0x3
    80004d54:	00f90633          	add	a2,s2,a5
    80004d58:	05864603          	lbu	a2,88(a2)
    80004d5c:	00c6f5b3          	and	a1,a3,a2
    80004d60:	cd91                	beqz	a1,80004d7c <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004d62:	2705                	addiw	a4,a4,1
    80004d64:	2485                	addiw	s1,s1,1
    80004d66:	fd471ae3          	bne	a4,s4,80004d3a <balloc+0x80>
    80004d6a:	b769                	j	80004cf4 <balloc+0x3a>
  panic("balloc: out of blocks");
    80004d6c:	00005517          	auipc	a0,0x5
    80004d70:	b6c50513          	addi	a0,a0,-1172 # 800098d8 <syscalls+0x278>
    80004d74:	ffffb097          	auipc	ra,0xffffb
    80004d78:	7c6080e7          	jalr	1990(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80004d7c:	97ca                	add	a5,a5,s2
    80004d7e:	8e55                	or	a2,a2,a3
    80004d80:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80004d84:	854a                	mv	a0,s2
    80004d86:	00001097          	auipc	ra,0x1
    80004d8a:	026080e7          	jalr	38(ra) # 80005dac <log_write>
        brelse(bp);
    80004d8e:	854a                	mv	a0,s2
    80004d90:	00000097          	auipc	ra,0x0
    80004d94:	d98080e7          	jalr	-616(ra) # 80004b28 <brelse>
  bp = bread(dev, bno);
    80004d98:	85a6                	mv	a1,s1
    80004d9a:	855e                	mv	a0,s7
    80004d9c:	00000097          	auipc	ra,0x0
    80004da0:	c5c080e7          	jalr	-932(ra) # 800049f8 <bread>
    80004da4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004da6:	40000613          	li	a2,1024
    80004daa:	4581                	li	a1,0
    80004dac:	05850513          	addi	a0,a0,88
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	f1c080e7          	jalr	-228(ra) # 80000ccc <memset>
  log_write(bp);
    80004db8:	854a                	mv	a0,s2
    80004dba:	00001097          	auipc	ra,0x1
    80004dbe:	ff2080e7          	jalr	-14(ra) # 80005dac <log_write>
  brelse(bp);
    80004dc2:	854a                	mv	a0,s2
    80004dc4:	00000097          	auipc	ra,0x0
    80004dc8:	d64080e7          	jalr	-668(ra) # 80004b28 <brelse>
}
    80004dcc:	8526                	mv	a0,s1
    80004dce:	60e6                	ld	ra,88(sp)
    80004dd0:	6446                	ld	s0,80(sp)
    80004dd2:	64a6                	ld	s1,72(sp)
    80004dd4:	6906                	ld	s2,64(sp)
    80004dd6:	79e2                	ld	s3,56(sp)
    80004dd8:	7a42                	ld	s4,48(sp)
    80004dda:	7aa2                	ld	s5,40(sp)
    80004ddc:	7b02                	ld	s6,32(sp)
    80004dde:	6be2                	ld	s7,24(sp)
    80004de0:	6c42                	ld	s8,16(sp)
    80004de2:	6ca2                	ld	s9,8(sp)
    80004de4:	6125                	addi	sp,sp,96
    80004de6:	8082                	ret

0000000080004de8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004de8:	7179                	addi	sp,sp,-48
    80004dea:	f406                	sd	ra,40(sp)
    80004dec:	f022                	sd	s0,32(sp)
    80004dee:	ec26                	sd	s1,24(sp)
    80004df0:	e84a                	sd	s2,16(sp)
    80004df2:	e44e                	sd	s3,8(sp)
    80004df4:	e052                	sd	s4,0(sp)
    80004df6:	1800                	addi	s0,sp,48
    80004df8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004dfa:	47ad                	li	a5,11
    80004dfc:	04b7fe63          	bgeu	a5,a1,80004e58 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80004e00:	ff45849b          	addiw	s1,a1,-12
    80004e04:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004e08:	0ff00793          	li	a5,255
    80004e0c:	0ae7e463          	bltu	a5,a4,80004eb4 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004e10:	08052583          	lw	a1,128(a0)
    80004e14:	c5b5                	beqz	a1,80004e80 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004e16:	00092503          	lw	a0,0(s2)
    80004e1a:	00000097          	auipc	ra,0x0
    80004e1e:	bde080e7          	jalr	-1058(ra) # 800049f8 <bread>
    80004e22:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004e24:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004e28:	02049713          	slli	a4,s1,0x20
    80004e2c:	01e75593          	srli	a1,a4,0x1e
    80004e30:	00b784b3          	add	s1,a5,a1
    80004e34:	0004a983          	lw	s3,0(s1)
    80004e38:	04098e63          	beqz	s3,80004e94 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004e3c:	8552                	mv	a0,s4
    80004e3e:	00000097          	auipc	ra,0x0
    80004e42:	cea080e7          	jalr	-790(ra) # 80004b28 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004e46:	854e                	mv	a0,s3
    80004e48:	70a2                	ld	ra,40(sp)
    80004e4a:	7402                	ld	s0,32(sp)
    80004e4c:	64e2                	ld	s1,24(sp)
    80004e4e:	6942                	ld	s2,16(sp)
    80004e50:	69a2                	ld	s3,8(sp)
    80004e52:	6a02                	ld	s4,0(sp)
    80004e54:	6145                	addi	sp,sp,48
    80004e56:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004e58:	02059793          	slli	a5,a1,0x20
    80004e5c:	01e7d593          	srli	a1,a5,0x1e
    80004e60:	00b504b3          	add	s1,a0,a1
    80004e64:	0504a983          	lw	s3,80(s1)
    80004e68:	fc099fe3          	bnez	s3,80004e46 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80004e6c:	4108                	lw	a0,0(a0)
    80004e6e:	00000097          	auipc	ra,0x0
    80004e72:	e4c080e7          	jalr	-436(ra) # 80004cba <balloc>
    80004e76:	0005099b          	sext.w	s3,a0
    80004e7a:	0534a823          	sw	s3,80(s1)
    80004e7e:	b7e1                	j	80004e46 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80004e80:	4108                	lw	a0,0(a0)
    80004e82:	00000097          	auipc	ra,0x0
    80004e86:	e38080e7          	jalr	-456(ra) # 80004cba <balloc>
    80004e8a:	0005059b          	sext.w	a1,a0
    80004e8e:	08b92023          	sw	a1,128(s2)
    80004e92:	b751                	j	80004e16 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004e94:	00092503          	lw	a0,0(s2)
    80004e98:	00000097          	auipc	ra,0x0
    80004e9c:	e22080e7          	jalr	-478(ra) # 80004cba <balloc>
    80004ea0:	0005099b          	sext.w	s3,a0
    80004ea4:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004ea8:	8552                	mv	a0,s4
    80004eaa:	00001097          	auipc	ra,0x1
    80004eae:	f02080e7          	jalr	-254(ra) # 80005dac <log_write>
    80004eb2:	b769                	j	80004e3c <bmap+0x54>
  panic("bmap: out of range");
    80004eb4:	00005517          	auipc	a0,0x5
    80004eb8:	a3c50513          	addi	a0,a0,-1476 # 800098f0 <syscalls+0x290>
    80004ebc:	ffffb097          	auipc	ra,0xffffb
    80004ec0:	67e080e7          	jalr	1662(ra) # 8000053a <panic>

0000000080004ec4 <iget>:
{
    80004ec4:	7179                	addi	sp,sp,-48
    80004ec6:	f406                	sd	ra,40(sp)
    80004ec8:	f022                	sd	s0,32(sp)
    80004eca:	ec26                	sd	s1,24(sp)
    80004ecc:	e84a                	sd	s2,16(sp)
    80004ece:	e44e                	sd	s3,8(sp)
    80004ed0:	e052                	sd	s4,0(sp)
    80004ed2:	1800                	addi	s0,sp,48
    80004ed4:	89aa                	mv	s3,a0
    80004ed6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004ed8:	0001d517          	auipc	a0,0x1d
    80004edc:	5b850513          	addi	a0,a0,1464 # 80022490 <itable>
    80004ee0:	ffffc097          	auipc	ra,0xffffc
    80004ee4:	cf0080e7          	jalr	-784(ra) # 80000bd0 <acquire>
  empty = 0;
    80004ee8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004eea:	0001d497          	auipc	s1,0x1d
    80004eee:	5be48493          	addi	s1,s1,1470 # 800224a8 <itable+0x18>
    80004ef2:	0001f697          	auipc	a3,0x1f
    80004ef6:	04668693          	addi	a3,a3,70 # 80023f38 <log>
    80004efa:	a039                	j	80004f08 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004efc:	02090b63          	beqz	s2,80004f32 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004f00:	08848493          	addi	s1,s1,136
    80004f04:	02d48a63          	beq	s1,a3,80004f38 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004f08:	449c                	lw	a5,8(s1)
    80004f0a:	fef059e3          	blez	a5,80004efc <iget+0x38>
    80004f0e:	4098                	lw	a4,0(s1)
    80004f10:	ff3716e3          	bne	a4,s3,80004efc <iget+0x38>
    80004f14:	40d8                	lw	a4,4(s1)
    80004f16:	ff4713e3          	bne	a4,s4,80004efc <iget+0x38>
      ip->ref++;
    80004f1a:	2785                	addiw	a5,a5,1
    80004f1c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004f1e:	0001d517          	auipc	a0,0x1d
    80004f22:	57250513          	addi	a0,a0,1394 # 80022490 <itable>
    80004f26:	ffffc097          	auipc	ra,0xffffc
    80004f2a:	d5e080e7          	jalr	-674(ra) # 80000c84 <release>
      return ip;
    80004f2e:	8926                	mv	s2,s1
    80004f30:	a03d                	j	80004f5e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004f32:	f7f9                	bnez	a5,80004f00 <iget+0x3c>
    80004f34:	8926                	mv	s2,s1
    80004f36:	b7e9                	j	80004f00 <iget+0x3c>
  if(empty == 0)
    80004f38:	02090c63          	beqz	s2,80004f70 <iget+0xac>
  ip->dev = dev;
    80004f3c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004f40:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004f44:	4785                	li	a5,1
    80004f46:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004f4a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004f4e:	0001d517          	auipc	a0,0x1d
    80004f52:	54250513          	addi	a0,a0,1346 # 80022490 <itable>
    80004f56:	ffffc097          	auipc	ra,0xffffc
    80004f5a:	d2e080e7          	jalr	-722(ra) # 80000c84 <release>
}
    80004f5e:	854a                	mv	a0,s2
    80004f60:	70a2                	ld	ra,40(sp)
    80004f62:	7402                	ld	s0,32(sp)
    80004f64:	64e2                	ld	s1,24(sp)
    80004f66:	6942                	ld	s2,16(sp)
    80004f68:	69a2                	ld	s3,8(sp)
    80004f6a:	6a02                	ld	s4,0(sp)
    80004f6c:	6145                	addi	sp,sp,48
    80004f6e:	8082                	ret
    panic("iget: no inodes");
    80004f70:	00005517          	auipc	a0,0x5
    80004f74:	99850513          	addi	a0,a0,-1640 # 80009908 <syscalls+0x2a8>
    80004f78:	ffffb097          	auipc	ra,0xffffb
    80004f7c:	5c2080e7          	jalr	1474(ra) # 8000053a <panic>

0000000080004f80 <fsinit>:
fsinit(int dev) {
    80004f80:	7179                	addi	sp,sp,-48
    80004f82:	f406                	sd	ra,40(sp)
    80004f84:	f022                	sd	s0,32(sp)
    80004f86:	ec26                	sd	s1,24(sp)
    80004f88:	e84a                	sd	s2,16(sp)
    80004f8a:	e44e                	sd	s3,8(sp)
    80004f8c:	1800                	addi	s0,sp,48
    80004f8e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80004f90:	4585                	li	a1,1
    80004f92:	00000097          	auipc	ra,0x0
    80004f96:	a66080e7          	jalr	-1434(ra) # 800049f8 <bread>
    80004f9a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80004f9c:	0001d997          	auipc	s3,0x1d
    80004fa0:	4d498993          	addi	s3,s3,1236 # 80022470 <sb>
    80004fa4:	02000613          	li	a2,32
    80004fa8:	05850593          	addi	a1,a0,88
    80004fac:	854e                	mv	a0,s3
    80004fae:	ffffc097          	auipc	ra,0xffffc
    80004fb2:	d7a080e7          	jalr	-646(ra) # 80000d28 <memmove>
  brelse(bp);
    80004fb6:	8526                	mv	a0,s1
    80004fb8:	00000097          	auipc	ra,0x0
    80004fbc:	b70080e7          	jalr	-1168(ra) # 80004b28 <brelse>
  if(sb.magic != FSMAGIC)
    80004fc0:	0009a703          	lw	a4,0(s3)
    80004fc4:	102037b7          	lui	a5,0x10203
    80004fc8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004fcc:	02f71263          	bne	a4,a5,80004ff0 <fsinit+0x70>
  initlog(dev, &sb);
    80004fd0:	0001d597          	auipc	a1,0x1d
    80004fd4:	4a058593          	addi	a1,a1,1184 # 80022470 <sb>
    80004fd8:	854a                	mv	a0,s2
    80004fda:	00001097          	auipc	ra,0x1
    80004fde:	b56080e7          	jalr	-1194(ra) # 80005b30 <initlog>
}
    80004fe2:	70a2                	ld	ra,40(sp)
    80004fe4:	7402                	ld	s0,32(sp)
    80004fe6:	64e2                	ld	s1,24(sp)
    80004fe8:	6942                	ld	s2,16(sp)
    80004fea:	69a2                	ld	s3,8(sp)
    80004fec:	6145                	addi	sp,sp,48
    80004fee:	8082                	ret
    panic("invalid file system");
    80004ff0:	00005517          	auipc	a0,0x5
    80004ff4:	92850513          	addi	a0,a0,-1752 # 80009918 <syscalls+0x2b8>
    80004ff8:	ffffb097          	auipc	ra,0xffffb
    80004ffc:	542080e7          	jalr	1346(ra) # 8000053a <panic>

0000000080005000 <iinit>:
{
    80005000:	7179                	addi	sp,sp,-48
    80005002:	f406                	sd	ra,40(sp)
    80005004:	f022                	sd	s0,32(sp)
    80005006:	ec26                	sd	s1,24(sp)
    80005008:	e84a                	sd	s2,16(sp)
    8000500a:	e44e                	sd	s3,8(sp)
    8000500c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000500e:	00005597          	auipc	a1,0x5
    80005012:	92258593          	addi	a1,a1,-1758 # 80009930 <syscalls+0x2d0>
    80005016:	0001d517          	auipc	a0,0x1d
    8000501a:	47a50513          	addi	a0,a0,1146 # 80022490 <itable>
    8000501e:	ffffc097          	auipc	ra,0xffffc
    80005022:	b22080e7          	jalr	-1246(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80005026:	0001d497          	auipc	s1,0x1d
    8000502a:	49248493          	addi	s1,s1,1170 # 800224b8 <itable+0x28>
    8000502e:	0001f997          	auipc	s3,0x1f
    80005032:	f1a98993          	addi	s3,s3,-230 # 80023f48 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80005036:	00005917          	auipc	s2,0x5
    8000503a:	90290913          	addi	s2,s2,-1790 # 80009938 <syscalls+0x2d8>
    8000503e:	85ca                	mv	a1,s2
    80005040:	8526                	mv	a0,s1
    80005042:	00001097          	auipc	ra,0x1
    80005046:	e4e080e7          	jalr	-434(ra) # 80005e90 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000504a:	08848493          	addi	s1,s1,136
    8000504e:	ff3498e3          	bne	s1,s3,8000503e <iinit+0x3e>
}
    80005052:	70a2                	ld	ra,40(sp)
    80005054:	7402                	ld	s0,32(sp)
    80005056:	64e2                	ld	s1,24(sp)
    80005058:	6942                	ld	s2,16(sp)
    8000505a:	69a2                	ld	s3,8(sp)
    8000505c:	6145                	addi	sp,sp,48
    8000505e:	8082                	ret

0000000080005060 <ialloc>:
{
    80005060:	715d                	addi	sp,sp,-80
    80005062:	e486                	sd	ra,72(sp)
    80005064:	e0a2                	sd	s0,64(sp)
    80005066:	fc26                	sd	s1,56(sp)
    80005068:	f84a                	sd	s2,48(sp)
    8000506a:	f44e                	sd	s3,40(sp)
    8000506c:	f052                	sd	s4,32(sp)
    8000506e:	ec56                	sd	s5,24(sp)
    80005070:	e85a                	sd	s6,16(sp)
    80005072:	e45e                	sd	s7,8(sp)
    80005074:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80005076:	0001d717          	auipc	a4,0x1d
    8000507a:	40672703          	lw	a4,1030(a4) # 8002247c <sb+0xc>
    8000507e:	4785                	li	a5,1
    80005080:	04e7fa63          	bgeu	a5,a4,800050d4 <ialloc+0x74>
    80005084:	8aaa                	mv	s5,a0
    80005086:	8bae                	mv	s7,a1
    80005088:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000508a:	0001da17          	auipc	s4,0x1d
    8000508e:	3e6a0a13          	addi	s4,s4,998 # 80022470 <sb>
    80005092:	00048b1b          	sext.w	s6,s1
    80005096:	0044d593          	srli	a1,s1,0x4
    8000509a:	018a2783          	lw	a5,24(s4)
    8000509e:	9dbd                	addw	a1,a1,a5
    800050a0:	8556                	mv	a0,s5
    800050a2:	00000097          	auipc	ra,0x0
    800050a6:	956080e7          	jalr	-1706(ra) # 800049f8 <bread>
    800050aa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800050ac:	05850993          	addi	s3,a0,88
    800050b0:	00f4f793          	andi	a5,s1,15
    800050b4:	079a                	slli	a5,a5,0x6
    800050b6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800050b8:	00099783          	lh	a5,0(s3)
    800050bc:	c785                	beqz	a5,800050e4 <ialloc+0x84>
    brelse(bp);
    800050be:	00000097          	auipc	ra,0x0
    800050c2:	a6a080e7          	jalr	-1430(ra) # 80004b28 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800050c6:	0485                	addi	s1,s1,1
    800050c8:	00ca2703          	lw	a4,12(s4)
    800050cc:	0004879b          	sext.w	a5,s1
    800050d0:	fce7e1e3          	bltu	a5,a4,80005092 <ialloc+0x32>
  panic("ialloc: no inodes");
    800050d4:	00005517          	auipc	a0,0x5
    800050d8:	86c50513          	addi	a0,a0,-1940 # 80009940 <syscalls+0x2e0>
    800050dc:	ffffb097          	auipc	ra,0xffffb
    800050e0:	45e080e7          	jalr	1118(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    800050e4:	04000613          	li	a2,64
    800050e8:	4581                	li	a1,0
    800050ea:	854e                	mv	a0,s3
    800050ec:	ffffc097          	auipc	ra,0xffffc
    800050f0:	be0080e7          	jalr	-1056(ra) # 80000ccc <memset>
      dip->type = type;
    800050f4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800050f8:	854a                	mv	a0,s2
    800050fa:	00001097          	auipc	ra,0x1
    800050fe:	cb2080e7          	jalr	-846(ra) # 80005dac <log_write>
      brelse(bp);
    80005102:	854a                	mv	a0,s2
    80005104:	00000097          	auipc	ra,0x0
    80005108:	a24080e7          	jalr	-1500(ra) # 80004b28 <brelse>
      return iget(dev, inum);
    8000510c:	85da                	mv	a1,s6
    8000510e:	8556                	mv	a0,s5
    80005110:	00000097          	auipc	ra,0x0
    80005114:	db4080e7          	jalr	-588(ra) # 80004ec4 <iget>
}
    80005118:	60a6                	ld	ra,72(sp)
    8000511a:	6406                	ld	s0,64(sp)
    8000511c:	74e2                	ld	s1,56(sp)
    8000511e:	7942                	ld	s2,48(sp)
    80005120:	79a2                	ld	s3,40(sp)
    80005122:	7a02                	ld	s4,32(sp)
    80005124:	6ae2                	ld	s5,24(sp)
    80005126:	6b42                	ld	s6,16(sp)
    80005128:	6ba2                	ld	s7,8(sp)
    8000512a:	6161                	addi	sp,sp,80
    8000512c:	8082                	ret

000000008000512e <iupdate>:
{
    8000512e:	1101                	addi	sp,sp,-32
    80005130:	ec06                	sd	ra,24(sp)
    80005132:	e822                	sd	s0,16(sp)
    80005134:	e426                	sd	s1,8(sp)
    80005136:	e04a                	sd	s2,0(sp)
    80005138:	1000                	addi	s0,sp,32
    8000513a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000513c:	415c                	lw	a5,4(a0)
    8000513e:	0047d79b          	srliw	a5,a5,0x4
    80005142:	0001d597          	auipc	a1,0x1d
    80005146:	3465a583          	lw	a1,838(a1) # 80022488 <sb+0x18>
    8000514a:	9dbd                	addw	a1,a1,a5
    8000514c:	4108                	lw	a0,0(a0)
    8000514e:	00000097          	auipc	ra,0x0
    80005152:	8aa080e7          	jalr	-1878(ra) # 800049f8 <bread>
    80005156:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80005158:	05850793          	addi	a5,a0,88
    8000515c:	40d8                	lw	a4,4(s1)
    8000515e:	8b3d                	andi	a4,a4,15
    80005160:	071a                	slli	a4,a4,0x6
    80005162:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80005164:	04449703          	lh	a4,68(s1)
    80005168:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000516c:	04649703          	lh	a4,70(s1)
    80005170:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80005174:	04849703          	lh	a4,72(s1)
    80005178:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000517c:	04a49703          	lh	a4,74(s1)
    80005180:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80005184:	44f8                	lw	a4,76(s1)
    80005186:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80005188:	03400613          	li	a2,52
    8000518c:	05048593          	addi	a1,s1,80
    80005190:	00c78513          	addi	a0,a5,12
    80005194:	ffffc097          	auipc	ra,0xffffc
    80005198:	b94080e7          	jalr	-1132(ra) # 80000d28 <memmove>
  log_write(bp);
    8000519c:	854a                	mv	a0,s2
    8000519e:	00001097          	auipc	ra,0x1
    800051a2:	c0e080e7          	jalr	-1010(ra) # 80005dac <log_write>
  brelse(bp);
    800051a6:	854a                	mv	a0,s2
    800051a8:	00000097          	auipc	ra,0x0
    800051ac:	980080e7          	jalr	-1664(ra) # 80004b28 <brelse>
}
    800051b0:	60e2                	ld	ra,24(sp)
    800051b2:	6442                	ld	s0,16(sp)
    800051b4:	64a2                	ld	s1,8(sp)
    800051b6:	6902                	ld	s2,0(sp)
    800051b8:	6105                	addi	sp,sp,32
    800051ba:	8082                	ret

00000000800051bc <idup>:
{
    800051bc:	1101                	addi	sp,sp,-32
    800051be:	ec06                	sd	ra,24(sp)
    800051c0:	e822                	sd	s0,16(sp)
    800051c2:	e426                	sd	s1,8(sp)
    800051c4:	1000                	addi	s0,sp,32
    800051c6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800051c8:	0001d517          	auipc	a0,0x1d
    800051cc:	2c850513          	addi	a0,a0,712 # 80022490 <itable>
    800051d0:	ffffc097          	auipc	ra,0xffffc
    800051d4:	a00080e7          	jalr	-1536(ra) # 80000bd0 <acquire>
  ip->ref++;
    800051d8:	449c                	lw	a5,8(s1)
    800051da:	2785                	addiw	a5,a5,1
    800051dc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800051de:	0001d517          	auipc	a0,0x1d
    800051e2:	2b250513          	addi	a0,a0,690 # 80022490 <itable>
    800051e6:	ffffc097          	auipc	ra,0xffffc
    800051ea:	a9e080e7          	jalr	-1378(ra) # 80000c84 <release>
}
    800051ee:	8526                	mv	a0,s1
    800051f0:	60e2                	ld	ra,24(sp)
    800051f2:	6442                	ld	s0,16(sp)
    800051f4:	64a2                	ld	s1,8(sp)
    800051f6:	6105                	addi	sp,sp,32
    800051f8:	8082                	ret

00000000800051fa <ilock>:
{
    800051fa:	1101                	addi	sp,sp,-32
    800051fc:	ec06                	sd	ra,24(sp)
    800051fe:	e822                	sd	s0,16(sp)
    80005200:	e426                	sd	s1,8(sp)
    80005202:	e04a                	sd	s2,0(sp)
    80005204:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80005206:	c115                	beqz	a0,8000522a <ilock+0x30>
    80005208:	84aa                	mv	s1,a0
    8000520a:	451c                	lw	a5,8(a0)
    8000520c:	00f05f63          	blez	a5,8000522a <ilock+0x30>
  acquiresleep(&ip->lock);
    80005210:	0541                	addi	a0,a0,16
    80005212:	00001097          	auipc	ra,0x1
    80005216:	cb8080e7          	jalr	-840(ra) # 80005eca <acquiresleep>
  if(ip->valid == 0){
    8000521a:	40bc                	lw	a5,64(s1)
    8000521c:	cf99                	beqz	a5,8000523a <ilock+0x40>
}
    8000521e:	60e2                	ld	ra,24(sp)
    80005220:	6442                	ld	s0,16(sp)
    80005222:	64a2                	ld	s1,8(sp)
    80005224:	6902                	ld	s2,0(sp)
    80005226:	6105                	addi	sp,sp,32
    80005228:	8082                	ret
    panic("ilock");
    8000522a:	00004517          	auipc	a0,0x4
    8000522e:	72e50513          	addi	a0,a0,1838 # 80009958 <syscalls+0x2f8>
    80005232:	ffffb097          	auipc	ra,0xffffb
    80005236:	308080e7          	jalr	776(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000523a:	40dc                	lw	a5,4(s1)
    8000523c:	0047d79b          	srliw	a5,a5,0x4
    80005240:	0001d597          	auipc	a1,0x1d
    80005244:	2485a583          	lw	a1,584(a1) # 80022488 <sb+0x18>
    80005248:	9dbd                	addw	a1,a1,a5
    8000524a:	4088                	lw	a0,0(s1)
    8000524c:	fffff097          	auipc	ra,0xfffff
    80005250:	7ac080e7          	jalr	1964(ra) # 800049f8 <bread>
    80005254:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80005256:	05850593          	addi	a1,a0,88
    8000525a:	40dc                	lw	a5,4(s1)
    8000525c:	8bbd                	andi	a5,a5,15
    8000525e:	079a                	slli	a5,a5,0x6
    80005260:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80005262:	00059783          	lh	a5,0(a1)
    80005266:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000526a:	00259783          	lh	a5,2(a1)
    8000526e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80005272:	00459783          	lh	a5,4(a1)
    80005276:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000527a:	00659783          	lh	a5,6(a1)
    8000527e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80005282:	459c                	lw	a5,8(a1)
    80005284:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80005286:	03400613          	li	a2,52
    8000528a:	05b1                	addi	a1,a1,12
    8000528c:	05048513          	addi	a0,s1,80
    80005290:	ffffc097          	auipc	ra,0xffffc
    80005294:	a98080e7          	jalr	-1384(ra) # 80000d28 <memmove>
    brelse(bp);
    80005298:	854a                	mv	a0,s2
    8000529a:	00000097          	auipc	ra,0x0
    8000529e:	88e080e7          	jalr	-1906(ra) # 80004b28 <brelse>
    ip->valid = 1;
    800052a2:	4785                	li	a5,1
    800052a4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800052a6:	04449783          	lh	a5,68(s1)
    800052aa:	fbb5                	bnez	a5,8000521e <ilock+0x24>
      panic("ilock: no type");
    800052ac:	00004517          	auipc	a0,0x4
    800052b0:	6b450513          	addi	a0,a0,1716 # 80009960 <syscalls+0x300>
    800052b4:	ffffb097          	auipc	ra,0xffffb
    800052b8:	286080e7          	jalr	646(ra) # 8000053a <panic>

00000000800052bc <iunlock>:
{
    800052bc:	1101                	addi	sp,sp,-32
    800052be:	ec06                	sd	ra,24(sp)
    800052c0:	e822                	sd	s0,16(sp)
    800052c2:	e426                	sd	s1,8(sp)
    800052c4:	e04a                	sd	s2,0(sp)
    800052c6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800052c8:	c905                	beqz	a0,800052f8 <iunlock+0x3c>
    800052ca:	84aa                	mv	s1,a0
    800052cc:	01050913          	addi	s2,a0,16
    800052d0:	854a                	mv	a0,s2
    800052d2:	00001097          	auipc	ra,0x1
    800052d6:	c92080e7          	jalr	-878(ra) # 80005f64 <holdingsleep>
    800052da:	cd19                	beqz	a0,800052f8 <iunlock+0x3c>
    800052dc:	449c                	lw	a5,8(s1)
    800052de:	00f05d63          	blez	a5,800052f8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800052e2:	854a                	mv	a0,s2
    800052e4:	00001097          	auipc	ra,0x1
    800052e8:	c3c080e7          	jalr	-964(ra) # 80005f20 <releasesleep>
}
    800052ec:	60e2                	ld	ra,24(sp)
    800052ee:	6442                	ld	s0,16(sp)
    800052f0:	64a2                	ld	s1,8(sp)
    800052f2:	6902                	ld	s2,0(sp)
    800052f4:	6105                	addi	sp,sp,32
    800052f6:	8082                	ret
    panic("iunlock");
    800052f8:	00004517          	auipc	a0,0x4
    800052fc:	67850513          	addi	a0,a0,1656 # 80009970 <syscalls+0x310>
    80005300:	ffffb097          	auipc	ra,0xffffb
    80005304:	23a080e7          	jalr	570(ra) # 8000053a <panic>

0000000080005308 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80005308:	7179                	addi	sp,sp,-48
    8000530a:	f406                	sd	ra,40(sp)
    8000530c:	f022                	sd	s0,32(sp)
    8000530e:	ec26                	sd	s1,24(sp)
    80005310:	e84a                	sd	s2,16(sp)
    80005312:	e44e                	sd	s3,8(sp)
    80005314:	e052                	sd	s4,0(sp)
    80005316:	1800                	addi	s0,sp,48
    80005318:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000531a:	05050493          	addi	s1,a0,80
    8000531e:	08050913          	addi	s2,a0,128
    80005322:	a021                	j	8000532a <itrunc+0x22>
    80005324:	0491                	addi	s1,s1,4
    80005326:	01248d63          	beq	s1,s2,80005340 <itrunc+0x38>
    if(ip->addrs[i]){
    8000532a:	408c                	lw	a1,0(s1)
    8000532c:	dde5                	beqz	a1,80005324 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000532e:	0009a503          	lw	a0,0(s3)
    80005332:	00000097          	auipc	ra,0x0
    80005336:	90c080e7          	jalr	-1780(ra) # 80004c3e <bfree>
      ip->addrs[i] = 0;
    8000533a:	0004a023          	sw	zero,0(s1)
    8000533e:	b7dd                	j	80005324 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80005340:	0809a583          	lw	a1,128(s3)
    80005344:	e185                	bnez	a1,80005364 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80005346:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000534a:	854e                	mv	a0,s3
    8000534c:	00000097          	auipc	ra,0x0
    80005350:	de2080e7          	jalr	-542(ra) # 8000512e <iupdate>
}
    80005354:	70a2                	ld	ra,40(sp)
    80005356:	7402                	ld	s0,32(sp)
    80005358:	64e2                	ld	s1,24(sp)
    8000535a:	6942                	ld	s2,16(sp)
    8000535c:	69a2                	ld	s3,8(sp)
    8000535e:	6a02                	ld	s4,0(sp)
    80005360:	6145                	addi	sp,sp,48
    80005362:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80005364:	0009a503          	lw	a0,0(s3)
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	690080e7          	jalr	1680(ra) # 800049f8 <bread>
    80005370:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80005372:	05850493          	addi	s1,a0,88
    80005376:	45850913          	addi	s2,a0,1112
    8000537a:	a021                	j	80005382 <itrunc+0x7a>
    8000537c:	0491                	addi	s1,s1,4
    8000537e:	01248b63          	beq	s1,s2,80005394 <itrunc+0x8c>
      if(a[j])
    80005382:	408c                	lw	a1,0(s1)
    80005384:	dde5                	beqz	a1,8000537c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80005386:	0009a503          	lw	a0,0(s3)
    8000538a:	00000097          	auipc	ra,0x0
    8000538e:	8b4080e7          	jalr	-1868(ra) # 80004c3e <bfree>
    80005392:	b7ed                	j	8000537c <itrunc+0x74>
    brelse(bp);
    80005394:	8552                	mv	a0,s4
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	792080e7          	jalr	1938(ra) # 80004b28 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000539e:	0809a583          	lw	a1,128(s3)
    800053a2:	0009a503          	lw	a0,0(s3)
    800053a6:	00000097          	auipc	ra,0x0
    800053aa:	898080e7          	jalr	-1896(ra) # 80004c3e <bfree>
    ip->addrs[NDIRECT] = 0;
    800053ae:	0809a023          	sw	zero,128(s3)
    800053b2:	bf51                	j	80005346 <itrunc+0x3e>

00000000800053b4 <iput>:
{
    800053b4:	1101                	addi	sp,sp,-32
    800053b6:	ec06                	sd	ra,24(sp)
    800053b8:	e822                	sd	s0,16(sp)
    800053ba:	e426                	sd	s1,8(sp)
    800053bc:	e04a                	sd	s2,0(sp)
    800053be:	1000                	addi	s0,sp,32
    800053c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800053c2:	0001d517          	auipc	a0,0x1d
    800053c6:	0ce50513          	addi	a0,a0,206 # 80022490 <itable>
    800053ca:	ffffc097          	auipc	ra,0xffffc
    800053ce:	806080e7          	jalr	-2042(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800053d2:	4498                	lw	a4,8(s1)
    800053d4:	4785                	li	a5,1
    800053d6:	02f70363          	beq	a4,a5,800053fc <iput+0x48>
  ip->ref--;
    800053da:	449c                	lw	a5,8(s1)
    800053dc:	37fd                	addiw	a5,a5,-1
    800053de:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800053e0:	0001d517          	auipc	a0,0x1d
    800053e4:	0b050513          	addi	a0,a0,176 # 80022490 <itable>
    800053e8:	ffffc097          	auipc	ra,0xffffc
    800053ec:	89c080e7          	jalr	-1892(ra) # 80000c84 <release>
}
    800053f0:	60e2                	ld	ra,24(sp)
    800053f2:	6442                	ld	s0,16(sp)
    800053f4:	64a2                	ld	s1,8(sp)
    800053f6:	6902                	ld	s2,0(sp)
    800053f8:	6105                	addi	sp,sp,32
    800053fa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800053fc:	40bc                	lw	a5,64(s1)
    800053fe:	dff1                	beqz	a5,800053da <iput+0x26>
    80005400:	04a49783          	lh	a5,74(s1)
    80005404:	fbf9                	bnez	a5,800053da <iput+0x26>
    acquiresleep(&ip->lock);
    80005406:	01048913          	addi	s2,s1,16
    8000540a:	854a                	mv	a0,s2
    8000540c:	00001097          	auipc	ra,0x1
    80005410:	abe080e7          	jalr	-1346(ra) # 80005eca <acquiresleep>
    release(&itable.lock);
    80005414:	0001d517          	auipc	a0,0x1d
    80005418:	07c50513          	addi	a0,a0,124 # 80022490 <itable>
    8000541c:	ffffc097          	auipc	ra,0xffffc
    80005420:	868080e7          	jalr	-1944(ra) # 80000c84 <release>
    itrunc(ip);
    80005424:	8526                	mv	a0,s1
    80005426:	00000097          	auipc	ra,0x0
    8000542a:	ee2080e7          	jalr	-286(ra) # 80005308 <itrunc>
    ip->type = 0;
    8000542e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80005432:	8526                	mv	a0,s1
    80005434:	00000097          	auipc	ra,0x0
    80005438:	cfa080e7          	jalr	-774(ra) # 8000512e <iupdate>
    ip->valid = 0;
    8000543c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80005440:	854a                	mv	a0,s2
    80005442:	00001097          	auipc	ra,0x1
    80005446:	ade080e7          	jalr	-1314(ra) # 80005f20 <releasesleep>
    acquire(&itable.lock);
    8000544a:	0001d517          	auipc	a0,0x1d
    8000544e:	04650513          	addi	a0,a0,70 # 80022490 <itable>
    80005452:	ffffb097          	auipc	ra,0xffffb
    80005456:	77e080e7          	jalr	1918(ra) # 80000bd0 <acquire>
    8000545a:	b741                	j	800053da <iput+0x26>

000000008000545c <iunlockput>:
{
    8000545c:	1101                	addi	sp,sp,-32
    8000545e:	ec06                	sd	ra,24(sp)
    80005460:	e822                	sd	s0,16(sp)
    80005462:	e426                	sd	s1,8(sp)
    80005464:	1000                	addi	s0,sp,32
    80005466:	84aa                	mv	s1,a0
  iunlock(ip);
    80005468:	00000097          	auipc	ra,0x0
    8000546c:	e54080e7          	jalr	-428(ra) # 800052bc <iunlock>
  iput(ip);
    80005470:	8526                	mv	a0,s1
    80005472:	00000097          	auipc	ra,0x0
    80005476:	f42080e7          	jalr	-190(ra) # 800053b4 <iput>
}
    8000547a:	60e2                	ld	ra,24(sp)
    8000547c:	6442                	ld	s0,16(sp)
    8000547e:	64a2                	ld	s1,8(sp)
    80005480:	6105                	addi	sp,sp,32
    80005482:	8082                	ret

0000000080005484 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80005484:	1141                	addi	sp,sp,-16
    80005486:	e422                	sd	s0,8(sp)
    80005488:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000548a:	411c                	lw	a5,0(a0)
    8000548c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000548e:	415c                	lw	a5,4(a0)
    80005490:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80005492:	04451783          	lh	a5,68(a0)
    80005496:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000549a:	04a51783          	lh	a5,74(a0)
    8000549e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800054a2:	04c56783          	lwu	a5,76(a0)
    800054a6:	e99c                	sd	a5,16(a1)
}
    800054a8:	6422                	ld	s0,8(sp)
    800054aa:	0141                	addi	sp,sp,16
    800054ac:	8082                	ret

00000000800054ae <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800054ae:	457c                	lw	a5,76(a0)
    800054b0:	0ed7e963          	bltu	a5,a3,800055a2 <readi+0xf4>
{
    800054b4:	7159                	addi	sp,sp,-112
    800054b6:	f486                	sd	ra,104(sp)
    800054b8:	f0a2                	sd	s0,96(sp)
    800054ba:	eca6                	sd	s1,88(sp)
    800054bc:	e8ca                	sd	s2,80(sp)
    800054be:	e4ce                	sd	s3,72(sp)
    800054c0:	e0d2                	sd	s4,64(sp)
    800054c2:	fc56                	sd	s5,56(sp)
    800054c4:	f85a                	sd	s6,48(sp)
    800054c6:	f45e                	sd	s7,40(sp)
    800054c8:	f062                	sd	s8,32(sp)
    800054ca:	ec66                	sd	s9,24(sp)
    800054cc:	e86a                	sd	s10,16(sp)
    800054ce:	e46e                	sd	s11,8(sp)
    800054d0:	1880                	addi	s0,sp,112
    800054d2:	8baa                	mv	s7,a0
    800054d4:	8c2e                	mv	s8,a1
    800054d6:	8ab2                	mv	s5,a2
    800054d8:	84b6                	mv	s1,a3
    800054da:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800054dc:	9f35                	addw	a4,a4,a3
    return 0;
    800054de:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800054e0:	0ad76063          	bltu	a4,a3,80005580 <readi+0xd2>
  if(off + n > ip->size)
    800054e4:	00e7f463          	bgeu	a5,a4,800054ec <readi+0x3e>
    n = ip->size - off;
    800054e8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800054ec:	0a0b0963          	beqz	s6,8000559e <readi+0xf0>
    800054f0:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800054f2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800054f6:	5cfd                	li	s9,-1
    800054f8:	a82d                	j	80005532 <readi+0x84>
    800054fa:	020a1d93          	slli	s11,s4,0x20
    800054fe:	020ddd93          	srli	s11,s11,0x20
    80005502:	05890613          	addi	a2,s2,88
    80005506:	86ee                	mv	a3,s11
    80005508:	963a                	add	a2,a2,a4
    8000550a:	85d6                	mv	a1,s5
    8000550c:	8562                	mv	a0,s8
    8000550e:	ffffe097          	auipc	ra,0xffffe
    80005512:	f30080e7          	jalr	-208(ra) # 8000343e <either_copyout>
    80005516:	05950d63          	beq	a0,s9,80005570 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000551a:	854a                	mv	a0,s2
    8000551c:	fffff097          	auipc	ra,0xfffff
    80005520:	60c080e7          	jalr	1548(ra) # 80004b28 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005524:	013a09bb          	addw	s3,s4,s3
    80005528:	009a04bb          	addw	s1,s4,s1
    8000552c:	9aee                	add	s5,s5,s11
    8000552e:	0569f763          	bgeu	s3,s6,8000557c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80005532:	000ba903          	lw	s2,0(s7)
    80005536:	00a4d59b          	srliw	a1,s1,0xa
    8000553a:	855e                	mv	a0,s7
    8000553c:	00000097          	auipc	ra,0x0
    80005540:	8ac080e7          	jalr	-1876(ra) # 80004de8 <bmap>
    80005544:	0005059b          	sext.w	a1,a0
    80005548:	854a                	mv	a0,s2
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	4ae080e7          	jalr	1198(ra) # 800049f8 <bread>
    80005552:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80005554:	3ff4f713          	andi	a4,s1,1023
    80005558:	40ed07bb          	subw	a5,s10,a4
    8000555c:	413b06bb          	subw	a3,s6,s3
    80005560:	8a3e                	mv	s4,a5
    80005562:	2781                	sext.w	a5,a5
    80005564:	0006861b          	sext.w	a2,a3
    80005568:	f8f679e3          	bgeu	a2,a5,800054fa <readi+0x4c>
    8000556c:	8a36                	mv	s4,a3
    8000556e:	b771                	j	800054fa <readi+0x4c>
      brelse(bp);
    80005570:	854a                	mv	a0,s2
    80005572:	fffff097          	auipc	ra,0xfffff
    80005576:	5b6080e7          	jalr	1462(ra) # 80004b28 <brelse>
      tot = -1;
    8000557a:	59fd                	li	s3,-1
  }
  return tot;
    8000557c:	0009851b          	sext.w	a0,s3
}
    80005580:	70a6                	ld	ra,104(sp)
    80005582:	7406                	ld	s0,96(sp)
    80005584:	64e6                	ld	s1,88(sp)
    80005586:	6946                	ld	s2,80(sp)
    80005588:	69a6                	ld	s3,72(sp)
    8000558a:	6a06                	ld	s4,64(sp)
    8000558c:	7ae2                	ld	s5,56(sp)
    8000558e:	7b42                	ld	s6,48(sp)
    80005590:	7ba2                	ld	s7,40(sp)
    80005592:	7c02                	ld	s8,32(sp)
    80005594:	6ce2                	ld	s9,24(sp)
    80005596:	6d42                	ld	s10,16(sp)
    80005598:	6da2                	ld	s11,8(sp)
    8000559a:	6165                	addi	sp,sp,112
    8000559c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000559e:	89da                	mv	s3,s6
    800055a0:	bff1                	j	8000557c <readi+0xce>
    return 0;
    800055a2:	4501                	li	a0,0
}
    800055a4:	8082                	ret

00000000800055a6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800055a6:	457c                	lw	a5,76(a0)
    800055a8:	10d7e863          	bltu	a5,a3,800056b8 <writei+0x112>
{
    800055ac:	7159                	addi	sp,sp,-112
    800055ae:	f486                	sd	ra,104(sp)
    800055b0:	f0a2                	sd	s0,96(sp)
    800055b2:	eca6                	sd	s1,88(sp)
    800055b4:	e8ca                	sd	s2,80(sp)
    800055b6:	e4ce                	sd	s3,72(sp)
    800055b8:	e0d2                	sd	s4,64(sp)
    800055ba:	fc56                	sd	s5,56(sp)
    800055bc:	f85a                	sd	s6,48(sp)
    800055be:	f45e                	sd	s7,40(sp)
    800055c0:	f062                	sd	s8,32(sp)
    800055c2:	ec66                	sd	s9,24(sp)
    800055c4:	e86a                	sd	s10,16(sp)
    800055c6:	e46e                	sd	s11,8(sp)
    800055c8:	1880                	addi	s0,sp,112
    800055ca:	8b2a                	mv	s6,a0
    800055cc:	8c2e                	mv	s8,a1
    800055ce:	8ab2                	mv	s5,a2
    800055d0:	8936                	mv	s2,a3
    800055d2:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800055d4:	00e687bb          	addw	a5,a3,a4
    800055d8:	0ed7e263          	bltu	a5,a3,800056bc <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800055dc:	00043737          	lui	a4,0x43
    800055e0:	0ef76063          	bltu	a4,a5,800056c0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800055e4:	0c0b8863          	beqz	s7,800056b4 <writei+0x10e>
    800055e8:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800055ea:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800055ee:	5cfd                	li	s9,-1
    800055f0:	a091                	j	80005634 <writei+0x8e>
    800055f2:	02099d93          	slli	s11,s3,0x20
    800055f6:	020ddd93          	srli	s11,s11,0x20
    800055fa:	05848513          	addi	a0,s1,88
    800055fe:	86ee                	mv	a3,s11
    80005600:	8656                	mv	a2,s5
    80005602:	85e2                	mv	a1,s8
    80005604:	953a                	add	a0,a0,a4
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	e8e080e7          	jalr	-370(ra) # 80003494 <either_copyin>
    8000560e:	07950263          	beq	a0,s9,80005672 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80005612:	8526                	mv	a0,s1
    80005614:	00000097          	auipc	ra,0x0
    80005618:	798080e7          	jalr	1944(ra) # 80005dac <log_write>
    brelse(bp);
    8000561c:	8526                	mv	a0,s1
    8000561e:	fffff097          	auipc	ra,0xfffff
    80005622:	50a080e7          	jalr	1290(ra) # 80004b28 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80005626:	01498a3b          	addw	s4,s3,s4
    8000562a:	0129893b          	addw	s2,s3,s2
    8000562e:	9aee                	add	s5,s5,s11
    80005630:	057a7663          	bgeu	s4,s7,8000567c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80005634:	000b2483          	lw	s1,0(s6)
    80005638:	00a9559b          	srliw	a1,s2,0xa
    8000563c:	855a                	mv	a0,s6
    8000563e:	fffff097          	auipc	ra,0xfffff
    80005642:	7aa080e7          	jalr	1962(ra) # 80004de8 <bmap>
    80005646:	0005059b          	sext.w	a1,a0
    8000564a:	8526                	mv	a0,s1
    8000564c:	fffff097          	auipc	ra,0xfffff
    80005650:	3ac080e7          	jalr	940(ra) # 800049f8 <bread>
    80005654:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80005656:	3ff97713          	andi	a4,s2,1023
    8000565a:	40ed07bb          	subw	a5,s10,a4
    8000565e:	414b86bb          	subw	a3,s7,s4
    80005662:	89be                	mv	s3,a5
    80005664:	2781                	sext.w	a5,a5
    80005666:	0006861b          	sext.w	a2,a3
    8000566a:	f8f674e3          	bgeu	a2,a5,800055f2 <writei+0x4c>
    8000566e:	89b6                	mv	s3,a3
    80005670:	b749                	j	800055f2 <writei+0x4c>
      brelse(bp);
    80005672:	8526                	mv	a0,s1
    80005674:	fffff097          	auipc	ra,0xfffff
    80005678:	4b4080e7          	jalr	1204(ra) # 80004b28 <brelse>
  }

  if(off > ip->size)
    8000567c:	04cb2783          	lw	a5,76(s6)
    80005680:	0127f463          	bgeu	a5,s2,80005688 <writei+0xe2>
    ip->size = off;
    80005684:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80005688:	855a                	mv	a0,s6
    8000568a:	00000097          	auipc	ra,0x0
    8000568e:	aa4080e7          	jalr	-1372(ra) # 8000512e <iupdate>

  return tot;
    80005692:	000a051b          	sext.w	a0,s4
}
    80005696:	70a6                	ld	ra,104(sp)
    80005698:	7406                	ld	s0,96(sp)
    8000569a:	64e6                	ld	s1,88(sp)
    8000569c:	6946                	ld	s2,80(sp)
    8000569e:	69a6                	ld	s3,72(sp)
    800056a0:	6a06                	ld	s4,64(sp)
    800056a2:	7ae2                	ld	s5,56(sp)
    800056a4:	7b42                	ld	s6,48(sp)
    800056a6:	7ba2                	ld	s7,40(sp)
    800056a8:	7c02                	ld	s8,32(sp)
    800056aa:	6ce2                	ld	s9,24(sp)
    800056ac:	6d42                	ld	s10,16(sp)
    800056ae:	6da2                	ld	s11,8(sp)
    800056b0:	6165                	addi	sp,sp,112
    800056b2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800056b4:	8a5e                	mv	s4,s7
    800056b6:	bfc9                	j	80005688 <writei+0xe2>
    return -1;
    800056b8:	557d                	li	a0,-1
}
    800056ba:	8082                	ret
    return -1;
    800056bc:	557d                	li	a0,-1
    800056be:	bfe1                	j	80005696 <writei+0xf0>
    return -1;
    800056c0:	557d                	li	a0,-1
    800056c2:	bfd1                	j	80005696 <writei+0xf0>

00000000800056c4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800056c4:	1141                	addi	sp,sp,-16
    800056c6:	e406                	sd	ra,8(sp)
    800056c8:	e022                	sd	s0,0(sp)
    800056ca:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800056cc:	4639                	li	a2,14
    800056ce:	ffffb097          	auipc	ra,0xffffb
    800056d2:	6ce080e7          	jalr	1742(ra) # 80000d9c <strncmp>
}
    800056d6:	60a2                	ld	ra,8(sp)
    800056d8:	6402                	ld	s0,0(sp)
    800056da:	0141                	addi	sp,sp,16
    800056dc:	8082                	ret

00000000800056de <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800056de:	7139                	addi	sp,sp,-64
    800056e0:	fc06                	sd	ra,56(sp)
    800056e2:	f822                	sd	s0,48(sp)
    800056e4:	f426                	sd	s1,40(sp)
    800056e6:	f04a                	sd	s2,32(sp)
    800056e8:	ec4e                	sd	s3,24(sp)
    800056ea:	e852                	sd	s4,16(sp)
    800056ec:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800056ee:	04451703          	lh	a4,68(a0)
    800056f2:	4785                	li	a5,1
    800056f4:	00f71a63          	bne	a4,a5,80005708 <dirlookup+0x2a>
    800056f8:	892a                	mv	s2,a0
    800056fa:	89ae                	mv	s3,a1
    800056fc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800056fe:	457c                	lw	a5,76(a0)
    80005700:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80005702:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005704:	e79d                	bnez	a5,80005732 <dirlookup+0x54>
    80005706:	a8a5                	j	8000577e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80005708:	00004517          	auipc	a0,0x4
    8000570c:	27050513          	addi	a0,a0,624 # 80009978 <syscalls+0x318>
    80005710:	ffffb097          	auipc	ra,0xffffb
    80005714:	e2a080e7          	jalr	-470(ra) # 8000053a <panic>
      panic("dirlookup read");
    80005718:	00004517          	auipc	a0,0x4
    8000571c:	27850513          	addi	a0,a0,632 # 80009990 <syscalls+0x330>
    80005720:	ffffb097          	auipc	ra,0xffffb
    80005724:	e1a080e7          	jalr	-486(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005728:	24c1                	addiw	s1,s1,16
    8000572a:	04c92783          	lw	a5,76(s2)
    8000572e:	04f4f763          	bgeu	s1,a5,8000577c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005732:	4741                	li	a4,16
    80005734:	86a6                	mv	a3,s1
    80005736:	fc040613          	addi	a2,s0,-64
    8000573a:	4581                	li	a1,0
    8000573c:	854a                	mv	a0,s2
    8000573e:	00000097          	auipc	ra,0x0
    80005742:	d70080e7          	jalr	-656(ra) # 800054ae <readi>
    80005746:	47c1                	li	a5,16
    80005748:	fcf518e3          	bne	a0,a5,80005718 <dirlookup+0x3a>
    if(de.inum == 0)
    8000574c:	fc045783          	lhu	a5,-64(s0)
    80005750:	dfe1                	beqz	a5,80005728 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80005752:	fc240593          	addi	a1,s0,-62
    80005756:	854e                	mv	a0,s3
    80005758:	00000097          	auipc	ra,0x0
    8000575c:	f6c080e7          	jalr	-148(ra) # 800056c4 <namecmp>
    80005760:	f561                	bnez	a0,80005728 <dirlookup+0x4a>
      if(poff)
    80005762:	000a0463          	beqz	s4,8000576a <dirlookup+0x8c>
        *poff = off;
    80005766:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000576a:	fc045583          	lhu	a1,-64(s0)
    8000576e:	00092503          	lw	a0,0(s2)
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	752080e7          	jalr	1874(ra) # 80004ec4 <iget>
    8000577a:	a011                	j	8000577e <dirlookup+0xa0>
  return 0;
    8000577c:	4501                	li	a0,0
}
    8000577e:	70e2                	ld	ra,56(sp)
    80005780:	7442                	ld	s0,48(sp)
    80005782:	74a2                	ld	s1,40(sp)
    80005784:	7902                	ld	s2,32(sp)
    80005786:	69e2                	ld	s3,24(sp)
    80005788:	6a42                	ld	s4,16(sp)
    8000578a:	6121                	addi	sp,sp,64
    8000578c:	8082                	ret

000000008000578e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000578e:	711d                	addi	sp,sp,-96
    80005790:	ec86                	sd	ra,88(sp)
    80005792:	e8a2                	sd	s0,80(sp)
    80005794:	e4a6                	sd	s1,72(sp)
    80005796:	e0ca                	sd	s2,64(sp)
    80005798:	fc4e                	sd	s3,56(sp)
    8000579a:	f852                	sd	s4,48(sp)
    8000579c:	f456                	sd	s5,40(sp)
    8000579e:	f05a                	sd	s6,32(sp)
    800057a0:	ec5e                	sd	s7,24(sp)
    800057a2:	e862                	sd	s8,16(sp)
    800057a4:	e466                	sd	s9,8(sp)
    800057a6:	e06a                	sd	s10,0(sp)
    800057a8:	1080                	addi	s0,sp,96
    800057aa:	84aa                	mv	s1,a0
    800057ac:	8b2e                	mv	s6,a1
    800057ae:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800057b0:	00054703          	lbu	a4,0(a0)
    800057b4:	02f00793          	li	a5,47
    800057b8:	02f70363          	beq	a4,a5,800057de <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800057bc:	ffffc097          	auipc	ra,0xffffc
    800057c0:	242080e7          	jalr	578(ra) # 800019fe <myproc>
    800057c4:	15853503          	ld	a0,344(a0)
    800057c8:	00000097          	auipc	ra,0x0
    800057cc:	9f4080e7          	jalr	-1548(ra) # 800051bc <idup>
    800057d0:	8a2a                	mv	s4,a0
  while(*path == '/')
    800057d2:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800057d6:	4cb5                	li	s9,13
  len = path - s;
    800057d8:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800057da:	4c05                	li	s8,1
    800057dc:	a87d                	j	8000589a <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800057de:	4585                	li	a1,1
    800057e0:	4505                	li	a0,1
    800057e2:	fffff097          	auipc	ra,0xfffff
    800057e6:	6e2080e7          	jalr	1762(ra) # 80004ec4 <iget>
    800057ea:	8a2a                	mv	s4,a0
    800057ec:	b7dd                	j	800057d2 <namex+0x44>
      iunlockput(ip);
    800057ee:	8552                	mv	a0,s4
    800057f0:	00000097          	auipc	ra,0x0
    800057f4:	c6c080e7          	jalr	-916(ra) # 8000545c <iunlockput>
      return 0;
    800057f8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800057fa:	8552                	mv	a0,s4
    800057fc:	60e6                	ld	ra,88(sp)
    800057fe:	6446                	ld	s0,80(sp)
    80005800:	64a6                	ld	s1,72(sp)
    80005802:	6906                	ld	s2,64(sp)
    80005804:	79e2                	ld	s3,56(sp)
    80005806:	7a42                	ld	s4,48(sp)
    80005808:	7aa2                	ld	s5,40(sp)
    8000580a:	7b02                	ld	s6,32(sp)
    8000580c:	6be2                	ld	s7,24(sp)
    8000580e:	6c42                	ld	s8,16(sp)
    80005810:	6ca2                	ld	s9,8(sp)
    80005812:	6d02                	ld	s10,0(sp)
    80005814:	6125                	addi	sp,sp,96
    80005816:	8082                	ret
      iunlock(ip);
    80005818:	8552                	mv	a0,s4
    8000581a:	00000097          	auipc	ra,0x0
    8000581e:	aa2080e7          	jalr	-1374(ra) # 800052bc <iunlock>
      return ip;
    80005822:	bfe1                	j	800057fa <namex+0x6c>
      iunlockput(ip);
    80005824:	8552                	mv	a0,s4
    80005826:	00000097          	auipc	ra,0x0
    8000582a:	c36080e7          	jalr	-970(ra) # 8000545c <iunlockput>
      return 0;
    8000582e:	8a4e                	mv	s4,s3
    80005830:	b7e9                	j	800057fa <namex+0x6c>
  len = path - s;
    80005832:	40998633          	sub	a2,s3,s1
    80005836:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000583a:	09acd863          	bge	s9,s10,800058ca <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000583e:	4639                	li	a2,14
    80005840:	85a6                	mv	a1,s1
    80005842:	8556                	mv	a0,s5
    80005844:	ffffb097          	auipc	ra,0xffffb
    80005848:	4e4080e7          	jalr	1252(ra) # 80000d28 <memmove>
    8000584c:	84ce                	mv	s1,s3
  while(*path == '/')
    8000584e:	0004c783          	lbu	a5,0(s1)
    80005852:	01279763          	bne	a5,s2,80005860 <namex+0xd2>
    path++;
    80005856:	0485                	addi	s1,s1,1
  while(*path == '/')
    80005858:	0004c783          	lbu	a5,0(s1)
    8000585c:	ff278de3          	beq	a5,s2,80005856 <namex+0xc8>
    ilock(ip);
    80005860:	8552                	mv	a0,s4
    80005862:	00000097          	auipc	ra,0x0
    80005866:	998080e7          	jalr	-1640(ra) # 800051fa <ilock>
    if(ip->type != T_DIR){
    8000586a:	044a1783          	lh	a5,68(s4)
    8000586e:	f98790e3          	bne	a5,s8,800057ee <namex+0x60>
    if(nameiparent && *path == '\0'){
    80005872:	000b0563          	beqz	s6,8000587c <namex+0xee>
    80005876:	0004c783          	lbu	a5,0(s1)
    8000587a:	dfd9                	beqz	a5,80005818 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000587c:	865e                	mv	a2,s7
    8000587e:	85d6                	mv	a1,s5
    80005880:	8552                	mv	a0,s4
    80005882:	00000097          	auipc	ra,0x0
    80005886:	e5c080e7          	jalr	-420(ra) # 800056de <dirlookup>
    8000588a:	89aa                	mv	s3,a0
    8000588c:	dd41                	beqz	a0,80005824 <namex+0x96>
    iunlockput(ip);
    8000588e:	8552                	mv	a0,s4
    80005890:	00000097          	auipc	ra,0x0
    80005894:	bcc080e7          	jalr	-1076(ra) # 8000545c <iunlockput>
    ip = next;
    80005898:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000589a:	0004c783          	lbu	a5,0(s1)
    8000589e:	01279763          	bne	a5,s2,800058ac <namex+0x11e>
    path++;
    800058a2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800058a4:	0004c783          	lbu	a5,0(s1)
    800058a8:	ff278de3          	beq	a5,s2,800058a2 <namex+0x114>
  if(*path == 0)
    800058ac:	cb9d                	beqz	a5,800058e2 <namex+0x154>
  while(*path != '/' && *path != 0)
    800058ae:	0004c783          	lbu	a5,0(s1)
    800058b2:	89a6                	mv	s3,s1
  len = path - s;
    800058b4:	8d5e                	mv	s10,s7
    800058b6:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800058b8:	01278963          	beq	a5,s2,800058ca <namex+0x13c>
    800058bc:	dbbd                	beqz	a5,80005832 <namex+0xa4>
    path++;
    800058be:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800058c0:	0009c783          	lbu	a5,0(s3)
    800058c4:	ff279ce3          	bne	a5,s2,800058bc <namex+0x12e>
    800058c8:	b7ad                	j	80005832 <namex+0xa4>
    memmove(name, s, len);
    800058ca:	2601                	sext.w	a2,a2
    800058cc:	85a6                	mv	a1,s1
    800058ce:	8556                	mv	a0,s5
    800058d0:	ffffb097          	auipc	ra,0xffffb
    800058d4:	458080e7          	jalr	1112(ra) # 80000d28 <memmove>
    name[len] = 0;
    800058d8:	9d56                	add	s10,s10,s5
    800058da:	000d0023          	sb	zero,0(s10)
    800058de:	84ce                	mv	s1,s3
    800058e0:	b7bd                	j	8000584e <namex+0xc0>
  if(nameiparent){
    800058e2:	f00b0ce3          	beqz	s6,800057fa <namex+0x6c>
    iput(ip);
    800058e6:	8552                	mv	a0,s4
    800058e8:	00000097          	auipc	ra,0x0
    800058ec:	acc080e7          	jalr	-1332(ra) # 800053b4 <iput>
    return 0;
    800058f0:	4a01                	li	s4,0
    800058f2:	b721                	j	800057fa <namex+0x6c>

00000000800058f4 <dirlink>:
{
    800058f4:	7139                	addi	sp,sp,-64
    800058f6:	fc06                	sd	ra,56(sp)
    800058f8:	f822                	sd	s0,48(sp)
    800058fa:	f426                	sd	s1,40(sp)
    800058fc:	f04a                	sd	s2,32(sp)
    800058fe:	ec4e                	sd	s3,24(sp)
    80005900:	e852                	sd	s4,16(sp)
    80005902:	0080                	addi	s0,sp,64
    80005904:	892a                	mv	s2,a0
    80005906:	8a2e                	mv	s4,a1
    80005908:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000590a:	4601                	li	a2,0
    8000590c:	00000097          	auipc	ra,0x0
    80005910:	dd2080e7          	jalr	-558(ra) # 800056de <dirlookup>
    80005914:	e93d                	bnez	a0,8000598a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005916:	04c92483          	lw	s1,76(s2)
    8000591a:	c49d                	beqz	s1,80005948 <dirlink+0x54>
    8000591c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000591e:	4741                	li	a4,16
    80005920:	86a6                	mv	a3,s1
    80005922:	fc040613          	addi	a2,s0,-64
    80005926:	4581                	li	a1,0
    80005928:	854a                	mv	a0,s2
    8000592a:	00000097          	auipc	ra,0x0
    8000592e:	b84080e7          	jalr	-1148(ra) # 800054ae <readi>
    80005932:	47c1                	li	a5,16
    80005934:	06f51163          	bne	a0,a5,80005996 <dirlink+0xa2>
    if(de.inum == 0)
    80005938:	fc045783          	lhu	a5,-64(s0)
    8000593c:	c791                	beqz	a5,80005948 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000593e:	24c1                	addiw	s1,s1,16
    80005940:	04c92783          	lw	a5,76(s2)
    80005944:	fcf4ede3          	bltu	s1,a5,8000591e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80005948:	4639                	li	a2,14
    8000594a:	85d2                	mv	a1,s4
    8000594c:	fc240513          	addi	a0,s0,-62
    80005950:	ffffb097          	auipc	ra,0xffffb
    80005954:	488080e7          	jalr	1160(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80005958:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000595c:	4741                	li	a4,16
    8000595e:	86a6                	mv	a3,s1
    80005960:	fc040613          	addi	a2,s0,-64
    80005964:	4581                	li	a1,0
    80005966:	854a                	mv	a0,s2
    80005968:	00000097          	auipc	ra,0x0
    8000596c:	c3e080e7          	jalr	-962(ra) # 800055a6 <writei>
    80005970:	872a                	mv	a4,a0
    80005972:	47c1                	li	a5,16
  return 0;
    80005974:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005976:	02f71863          	bne	a4,a5,800059a6 <dirlink+0xb2>
}
    8000597a:	70e2                	ld	ra,56(sp)
    8000597c:	7442                	ld	s0,48(sp)
    8000597e:	74a2                	ld	s1,40(sp)
    80005980:	7902                	ld	s2,32(sp)
    80005982:	69e2                	ld	s3,24(sp)
    80005984:	6a42                	ld	s4,16(sp)
    80005986:	6121                	addi	sp,sp,64
    80005988:	8082                	ret
    iput(ip);
    8000598a:	00000097          	auipc	ra,0x0
    8000598e:	a2a080e7          	jalr	-1494(ra) # 800053b4 <iput>
    return -1;
    80005992:	557d                	li	a0,-1
    80005994:	b7dd                	j	8000597a <dirlink+0x86>
      panic("dirlink read");
    80005996:	00004517          	auipc	a0,0x4
    8000599a:	00a50513          	addi	a0,a0,10 # 800099a0 <syscalls+0x340>
    8000599e:	ffffb097          	auipc	ra,0xffffb
    800059a2:	b9c080e7          	jalr	-1124(ra) # 8000053a <panic>
    panic("dirlink");
    800059a6:	00004517          	auipc	a0,0x4
    800059aa:	10a50513          	addi	a0,a0,266 # 80009ab0 <syscalls+0x450>
    800059ae:	ffffb097          	auipc	ra,0xffffb
    800059b2:	b8c080e7          	jalr	-1140(ra) # 8000053a <panic>

00000000800059b6 <namei>:

struct inode*
namei(char *path)
{
    800059b6:	1101                	addi	sp,sp,-32
    800059b8:	ec06                	sd	ra,24(sp)
    800059ba:	e822                	sd	s0,16(sp)
    800059bc:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800059be:	fe040613          	addi	a2,s0,-32
    800059c2:	4581                	li	a1,0
    800059c4:	00000097          	auipc	ra,0x0
    800059c8:	dca080e7          	jalr	-566(ra) # 8000578e <namex>
}
    800059cc:	60e2                	ld	ra,24(sp)
    800059ce:	6442                	ld	s0,16(sp)
    800059d0:	6105                	addi	sp,sp,32
    800059d2:	8082                	ret

00000000800059d4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800059d4:	1141                	addi	sp,sp,-16
    800059d6:	e406                	sd	ra,8(sp)
    800059d8:	e022                	sd	s0,0(sp)
    800059da:	0800                	addi	s0,sp,16
    800059dc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800059de:	4585                	li	a1,1
    800059e0:	00000097          	auipc	ra,0x0
    800059e4:	dae080e7          	jalr	-594(ra) # 8000578e <namex>
}
    800059e8:	60a2                	ld	ra,8(sp)
    800059ea:	6402                	ld	s0,0(sp)
    800059ec:	0141                	addi	sp,sp,16
    800059ee:	8082                	ret

00000000800059f0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800059f0:	1101                	addi	sp,sp,-32
    800059f2:	ec06                	sd	ra,24(sp)
    800059f4:	e822                	sd	s0,16(sp)
    800059f6:	e426                	sd	s1,8(sp)
    800059f8:	e04a                	sd	s2,0(sp)
    800059fa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800059fc:	0001e917          	auipc	s2,0x1e
    80005a00:	53c90913          	addi	s2,s2,1340 # 80023f38 <log>
    80005a04:	01892583          	lw	a1,24(s2)
    80005a08:	02892503          	lw	a0,40(s2)
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	fec080e7          	jalr	-20(ra) # 800049f8 <bread>
    80005a14:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005a16:	02c92683          	lw	a3,44(s2)
    80005a1a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80005a1c:	02d05863          	blez	a3,80005a4c <write_head+0x5c>
    80005a20:	0001e797          	auipc	a5,0x1e
    80005a24:	54878793          	addi	a5,a5,1352 # 80023f68 <log+0x30>
    80005a28:	05c50713          	addi	a4,a0,92
    80005a2c:	36fd                	addiw	a3,a3,-1
    80005a2e:	02069613          	slli	a2,a3,0x20
    80005a32:	01e65693          	srli	a3,a2,0x1e
    80005a36:	0001e617          	auipc	a2,0x1e
    80005a3a:	53660613          	addi	a2,a2,1334 # 80023f6c <log+0x34>
    80005a3e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80005a40:	4390                	lw	a2,0(a5)
    80005a42:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005a44:	0791                	addi	a5,a5,4
    80005a46:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80005a48:	fed79ce3          	bne	a5,a3,80005a40 <write_head+0x50>
  }
  bwrite(buf);
    80005a4c:	8526                	mv	a0,s1
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	09c080e7          	jalr	156(ra) # 80004aea <bwrite>
  brelse(buf);
    80005a56:	8526                	mv	a0,s1
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	0d0080e7          	jalr	208(ra) # 80004b28 <brelse>
}
    80005a60:	60e2                	ld	ra,24(sp)
    80005a62:	6442                	ld	s0,16(sp)
    80005a64:	64a2                	ld	s1,8(sp)
    80005a66:	6902                	ld	s2,0(sp)
    80005a68:	6105                	addi	sp,sp,32
    80005a6a:	8082                	ret

0000000080005a6c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005a6c:	0001e797          	auipc	a5,0x1e
    80005a70:	4f87a783          	lw	a5,1272(a5) # 80023f64 <log+0x2c>
    80005a74:	0af05d63          	blez	a5,80005b2e <install_trans+0xc2>
{
    80005a78:	7139                	addi	sp,sp,-64
    80005a7a:	fc06                	sd	ra,56(sp)
    80005a7c:	f822                	sd	s0,48(sp)
    80005a7e:	f426                	sd	s1,40(sp)
    80005a80:	f04a                	sd	s2,32(sp)
    80005a82:	ec4e                	sd	s3,24(sp)
    80005a84:	e852                	sd	s4,16(sp)
    80005a86:	e456                	sd	s5,8(sp)
    80005a88:	e05a                	sd	s6,0(sp)
    80005a8a:	0080                	addi	s0,sp,64
    80005a8c:	8b2a                	mv	s6,a0
    80005a8e:	0001ea97          	auipc	s5,0x1e
    80005a92:	4daa8a93          	addi	s5,s5,1242 # 80023f68 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005a96:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005a98:	0001e997          	auipc	s3,0x1e
    80005a9c:	4a098993          	addi	s3,s3,1184 # 80023f38 <log>
    80005aa0:	a00d                	j	80005ac2 <install_trans+0x56>
    brelse(lbuf);
    80005aa2:	854a                	mv	a0,s2
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	084080e7          	jalr	132(ra) # 80004b28 <brelse>
    brelse(dbuf);
    80005aac:	8526                	mv	a0,s1
    80005aae:	fffff097          	auipc	ra,0xfffff
    80005ab2:	07a080e7          	jalr	122(ra) # 80004b28 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005ab6:	2a05                	addiw	s4,s4,1
    80005ab8:	0a91                	addi	s5,s5,4
    80005aba:	02c9a783          	lw	a5,44(s3)
    80005abe:	04fa5e63          	bge	s4,a5,80005b1a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005ac2:	0189a583          	lw	a1,24(s3)
    80005ac6:	014585bb          	addw	a1,a1,s4
    80005aca:	2585                	addiw	a1,a1,1
    80005acc:	0289a503          	lw	a0,40(s3)
    80005ad0:	fffff097          	auipc	ra,0xfffff
    80005ad4:	f28080e7          	jalr	-216(ra) # 800049f8 <bread>
    80005ad8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80005ada:	000aa583          	lw	a1,0(s5)
    80005ade:	0289a503          	lw	a0,40(s3)
    80005ae2:	fffff097          	auipc	ra,0xfffff
    80005ae6:	f16080e7          	jalr	-234(ra) # 800049f8 <bread>
    80005aea:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005aec:	40000613          	li	a2,1024
    80005af0:	05890593          	addi	a1,s2,88
    80005af4:	05850513          	addi	a0,a0,88
    80005af8:	ffffb097          	auipc	ra,0xffffb
    80005afc:	230080e7          	jalr	560(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    80005b00:	8526                	mv	a0,s1
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	fe8080e7          	jalr	-24(ra) # 80004aea <bwrite>
    if(recovering == 0)
    80005b0a:	f80b1ce3          	bnez	s6,80005aa2 <install_trans+0x36>
      bunpin(dbuf);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	0f2080e7          	jalr	242(ra) # 80004c02 <bunpin>
    80005b18:	b769                	j	80005aa2 <install_trans+0x36>
}
    80005b1a:	70e2                	ld	ra,56(sp)
    80005b1c:	7442                	ld	s0,48(sp)
    80005b1e:	74a2                	ld	s1,40(sp)
    80005b20:	7902                	ld	s2,32(sp)
    80005b22:	69e2                	ld	s3,24(sp)
    80005b24:	6a42                	ld	s4,16(sp)
    80005b26:	6aa2                	ld	s5,8(sp)
    80005b28:	6b02                	ld	s6,0(sp)
    80005b2a:	6121                	addi	sp,sp,64
    80005b2c:	8082                	ret
    80005b2e:	8082                	ret

0000000080005b30 <initlog>:
{
    80005b30:	7179                	addi	sp,sp,-48
    80005b32:	f406                	sd	ra,40(sp)
    80005b34:	f022                	sd	s0,32(sp)
    80005b36:	ec26                	sd	s1,24(sp)
    80005b38:	e84a                	sd	s2,16(sp)
    80005b3a:	e44e                	sd	s3,8(sp)
    80005b3c:	1800                	addi	s0,sp,48
    80005b3e:	892a                	mv	s2,a0
    80005b40:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005b42:	0001e497          	auipc	s1,0x1e
    80005b46:	3f648493          	addi	s1,s1,1014 # 80023f38 <log>
    80005b4a:	00004597          	auipc	a1,0x4
    80005b4e:	e6658593          	addi	a1,a1,-410 # 800099b0 <syscalls+0x350>
    80005b52:	8526                	mv	a0,s1
    80005b54:	ffffb097          	auipc	ra,0xffffb
    80005b58:	fec080e7          	jalr	-20(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    80005b5c:	0149a583          	lw	a1,20(s3)
    80005b60:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80005b62:	0109a783          	lw	a5,16(s3)
    80005b66:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80005b68:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005b6c:	854a                	mv	a0,s2
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	e8a080e7          	jalr	-374(ra) # 800049f8 <bread>
  log.lh.n = lh->n;
    80005b76:	4d34                	lw	a3,88(a0)
    80005b78:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80005b7a:	02d05663          	blez	a3,80005ba6 <initlog+0x76>
    80005b7e:	05c50793          	addi	a5,a0,92
    80005b82:	0001e717          	auipc	a4,0x1e
    80005b86:	3e670713          	addi	a4,a4,998 # 80023f68 <log+0x30>
    80005b8a:	36fd                	addiw	a3,a3,-1
    80005b8c:	02069613          	slli	a2,a3,0x20
    80005b90:	01e65693          	srli	a3,a2,0x1e
    80005b94:	06050613          	addi	a2,a0,96
    80005b98:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80005b9a:	4390                	lw	a2,0(a5)
    80005b9c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005b9e:	0791                	addi	a5,a5,4
    80005ba0:	0711                	addi	a4,a4,4
    80005ba2:	fed79ce3          	bne	a5,a3,80005b9a <initlog+0x6a>
  brelse(buf);
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	f82080e7          	jalr	-126(ra) # 80004b28 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005bae:	4505                	li	a0,1
    80005bb0:	00000097          	auipc	ra,0x0
    80005bb4:	ebc080e7          	jalr	-324(ra) # 80005a6c <install_trans>
  log.lh.n = 0;
    80005bb8:	0001e797          	auipc	a5,0x1e
    80005bbc:	3a07a623          	sw	zero,940(a5) # 80023f64 <log+0x2c>
  write_head(); // clear the log
    80005bc0:	00000097          	auipc	ra,0x0
    80005bc4:	e30080e7          	jalr	-464(ra) # 800059f0 <write_head>
}
    80005bc8:	70a2                	ld	ra,40(sp)
    80005bca:	7402                	ld	s0,32(sp)
    80005bcc:	64e2                	ld	s1,24(sp)
    80005bce:	6942                	ld	s2,16(sp)
    80005bd0:	69a2                	ld	s3,8(sp)
    80005bd2:	6145                	addi	sp,sp,48
    80005bd4:	8082                	ret

0000000080005bd6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005bd6:	1101                	addi	sp,sp,-32
    80005bd8:	ec06                	sd	ra,24(sp)
    80005bda:	e822                	sd	s0,16(sp)
    80005bdc:	e426                	sd	s1,8(sp)
    80005bde:	e04a                	sd	s2,0(sp)
    80005be0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005be2:	0001e517          	auipc	a0,0x1e
    80005be6:	35650513          	addi	a0,a0,854 # 80023f38 <log>
    80005bea:	ffffb097          	auipc	ra,0xffffb
    80005bee:	fe6080e7          	jalr	-26(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    80005bf2:	0001e497          	auipc	s1,0x1e
    80005bf6:	34648493          	addi	s1,s1,838 # 80023f38 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005bfa:	4979                	li	s2,30
    80005bfc:	a039                	j	80005c0a <begin_op+0x34>
      sleep(&log, &log.lock);
    80005bfe:	85a6                	mv	a1,s1
    80005c00:	8526                	mv	a0,s1
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	bae080e7          	jalr	-1106(ra) # 800027b0 <sleep>
    if(log.committing){
    80005c0a:	50dc                	lw	a5,36(s1)
    80005c0c:	fbed                	bnez	a5,80005bfe <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005c0e:	5098                	lw	a4,32(s1)
    80005c10:	2705                	addiw	a4,a4,1
    80005c12:	0007069b          	sext.w	a3,a4
    80005c16:	0027179b          	slliw	a5,a4,0x2
    80005c1a:	9fb9                	addw	a5,a5,a4
    80005c1c:	0017979b          	slliw	a5,a5,0x1
    80005c20:	54d8                	lw	a4,44(s1)
    80005c22:	9fb9                	addw	a5,a5,a4
    80005c24:	00f95963          	bge	s2,a5,80005c36 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005c28:	85a6                	mv	a1,s1
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	ffffd097          	auipc	ra,0xffffd
    80005c30:	b84080e7          	jalr	-1148(ra) # 800027b0 <sleep>
    80005c34:	bfd9                	j	80005c0a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80005c36:	0001e517          	auipc	a0,0x1e
    80005c3a:	30250513          	addi	a0,a0,770 # 80023f38 <log>
    80005c3e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005c40:	ffffb097          	auipc	ra,0xffffb
    80005c44:	044080e7          	jalr	68(ra) # 80000c84 <release>
      break;
    }
  }
}
    80005c48:	60e2                	ld	ra,24(sp)
    80005c4a:	6442                	ld	s0,16(sp)
    80005c4c:	64a2                	ld	s1,8(sp)
    80005c4e:	6902                	ld	s2,0(sp)
    80005c50:	6105                	addi	sp,sp,32
    80005c52:	8082                	ret

0000000080005c54 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005c54:	7139                	addi	sp,sp,-64
    80005c56:	fc06                	sd	ra,56(sp)
    80005c58:	f822                	sd	s0,48(sp)
    80005c5a:	f426                	sd	s1,40(sp)
    80005c5c:	f04a                	sd	s2,32(sp)
    80005c5e:	ec4e                	sd	s3,24(sp)
    80005c60:	e852                	sd	s4,16(sp)
    80005c62:	e456                	sd	s5,8(sp)
    80005c64:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005c66:	0001e497          	auipc	s1,0x1e
    80005c6a:	2d248493          	addi	s1,s1,722 # 80023f38 <log>
    80005c6e:	8526                	mv	a0,s1
    80005c70:	ffffb097          	auipc	ra,0xffffb
    80005c74:	f60080e7          	jalr	-160(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    80005c78:	509c                	lw	a5,32(s1)
    80005c7a:	37fd                	addiw	a5,a5,-1
    80005c7c:	0007891b          	sext.w	s2,a5
    80005c80:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80005c82:	50dc                	lw	a5,36(s1)
    80005c84:	e7b9                	bnez	a5,80005cd2 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80005c86:	04091e63          	bnez	s2,80005ce2 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80005c8a:	0001e497          	auipc	s1,0x1e
    80005c8e:	2ae48493          	addi	s1,s1,686 # 80023f38 <log>
    80005c92:	4785                	li	a5,1
    80005c94:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80005c96:	8526                	mv	a0,s1
    80005c98:	ffffb097          	auipc	ra,0xffffb
    80005c9c:	fec080e7          	jalr	-20(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005ca0:	54dc                	lw	a5,44(s1)
    80005ca2:	06f04763          	bgtz	a5,80005d10 <end_op+0xbc>
    acquire(&log.lock);
    80005ca6:	0001e497          	auipc	s1,0x1e
    80005caa:	29248493          	addi	s1,s1,658 # 80023f38 <log>
    80005cae:	8526                	mv	a0,s1
    80005cb0:	ffffb097          	auipc	ra,0xffffb
    80005cb4:	f20080e7          	jalr	-224(ra) # 80000bd0 <acquire>
    log.committing = 0;
    80005cb8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80005cbc:	8526                	mv	a0,s1
    80005cbe:	ffffd097          	auipc	ra,0xffffd
    80005cc2:	0c4080e7          	jalr	196(ra) # 80002d82 <wakeup>
    release(&log.lock);
    80005cc6:	8526                	mv	a0,s1
    80005cc8:	ffffb097          	auipc	ra,0xffffb
    80005ccc:	fbc080e7          	jalr	-68(ra) # 80000c84 <release>
}
    80005cd0:	a03d                	j	80005cfe <end_op+0xaa>
    panic("log.committing");
    80005cd2:	00004517          	auipc	a0,0x4
    80005cd6:	ce650513          	addi	a0,a0,-794 # 800099b8 <syscalls+0x358>
    80005cda:	ffffb097          	auipc	ra,0xffffb
    80005cde:	860080e7          	jalr	-1952(ra) # 8000053a <panic>
    wakeup(&log);
    80005ce2:	0001e497          	auipc	s1,0x1e
    80005ce6:	25648493          	addi	s1,s1,598 # 80023f38 <log>
    80005cea:	8526                	mv	a0,s1
    80005cec:	ffffd097          	auipc	ra,0xffffd
    80005cf0:	096080e7          	jalr	150(ra) # 80002d82 <wakeup>
  release(&log.lock);
    80005cf4:	8526                	mv	a0,s1
    80005cf6:	ffffb097          	auipc	ra,0xffffb
    80005cfa:	f8e080e7          	jalr	-114(ra) # 80000c84 <release>
}
    80005cfe:	70e2                	ld	ra,56(sp)
    80005d00:	7442                	ld	s0,48(sp)
    80005d02:	74a2                	ld	s1,40(sp)
    80005d04:	7902                	ld	s2,32(sp)
    80005d06:	69e2                	ld	s3,24(sp)
    80005d08:	6a42                	ld	s4,16(sp)
    80005d0a:	6aa2                	ld	s5,8(sp)
    80005d0c:	6121                	addi	sp,sp,64
    80005d0e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005d10:	0001ea97          	auipc	s5,0x1e
    80005d14:	258a8a93          	addi	s5,s5,600 # 80023f68 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005d18:	0001ea17          	auipc	s4,0x1e
    80005d1c:	220a0a13          	addi	s4,s4,544 # 80023f38 <log>
    80005d20:	018a2583          	lw	a1,24(s4)
    80005d24:	012585bb          	addw	a1,a1,s2
    80005d28:	2585                	addiw	a1,a1,1
    80005d2a:	028a2503          	lw	a0,40(s4)
    80005d2e:	fffff097          	auipc	ra,0xfffff
    80005d32:	cca080e7          	jalr	-822(ra) # 800049f8 <bread>
    80005d36:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005d38:	000aa583          	lw	a1,0(s5)
    80005d3c:	028a2503          	lw	a0,40(s4)
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	cb8080e7          	jalr	-840(ra) # 800049f8 <bread>
    80005d48:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005d4a:	40000613          	li	a2,1024
    80005d4e:	05850593          	addi	a1,a0,88
    80005d52:	05848513          	addi	a0,s1,88
    80005d56:	ffffb097          	auipc	ra,0xffffb
    80005d5a:	fd2080e7          	jalr	-46(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    80005d5e:	8526                	mv	a0,s1
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	d8a080e7          	jalr	-630(ra) # 80004aea <bwrite>
    brelse(from);
    80005d68:	854e                	mv	a0,s3
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	dbe080e7          	jalr	-578(ra) # 80004b28 <brelse>
    brelse(to);
    80005d72:	8526                	mv	a0,s1
    80005d74:	fffff097          	auipc	ra,0xfffff
    80005d78:	db4080e7          	jalr	-588(ra) # 80004b28 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005d7c:	2905                	addiw	s2,s2,1
    80005d7e:	0a91                	addi	s5,s5,4
    80005d80:	02ca2783          	lw	a5,44(s4)
    80005d84:	f8f94ee3          	blt	s2,a5,80005d20 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80005d88:	00000097          	auipc	ra,0x0
    80005d8c:	c68080e7          	jalr	-920(ra) # 800059f0 <write_head>
    install_trans(0); // Now install writes to home locations
    80005d90:	4501                	li	a0,0
    80005d92:	00000097          	auipc	ra,0x0
    80005d96:	cda080e7          	jalr	-806(ra) # 80005a6c <install_trans>
    log.lh.n = 0;
    80005d9a:	0001e797          	auipc	a5,0x1e
    80005d9e:	1c07a523          	sw	zero,458(a5) # 80023f64 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005da2:	00000097          	auipc	ra,0x0
    80005da6:	c4e080e7          	jalr	-946(ra) # 800059f0 <write_head>
    80005daa:	bdf5                	j	80005ca6 <end_op+0x52>

0000000080005dac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005dac:	1101                	addi	sp,sp,-32
    80005dae:	ec06                	sd	ra,24(sp)
    80005db0:	e822                	sd	s0,16(sp)
    80005db2:	e426                	sd	s1,8(sp)
    80005db4:	e04a                	sd	s2,0(sp)
    80005db6:	1000                	addi	s0,sp,32
    80005db8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80005dba:	0001e917          	auipc	s2,0x1e
    80005dbe:	17e90913          	addi	s2,s2,382 # 80023f38 <log>
    80005dc2:	854a                	mv	a0,s2
    80005dc4:	ffffb097          	auipc	ra,0xffffb
    80005dc8:	e0c080e7          	jalr	-500(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80005dcc:	02c92603          	lw	a2,44(s2)
    80005dd0:	47f5                	li	a5,29
    80005dd2:	06c7c563          	blt	a5,a2,80005e3c <log_write+0x90>
    80005dd6:	0001e797          	auipc	a5,0x1e
    80005dda:	17e7a783          	lw	a5,382(a5) # 80023f54 <log+0x1c>
    80005dde:	37fd                	addiw	a5,a5,-1
    80005de0:	04f65e63          	bge	a2,a5,80005e3c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005de4:	0001e797          	auipc	a5,0x1e
    80005de8:	1747a783          	lw	a5,372(a5) # 80023f58 <log+0x20>
    80005dec:	06f05063          	blez	a5,80005e4c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005df0:	4781                	li	a5,0
    80005df2:	06c05563          	blez	a2,80005e5c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005df6:	44cc                	lw	a1,12(s1)
    80005df8:	0001e717          	auipc	a4,0x1e
    80005dfc:	17070713          	addi	a4,a4,368 # 80023f68 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005e00:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005e02:	4314                	lw	a3,0(a4)
    80005e04:	04b68c63          	beq	a3,a1,80005e5c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005e08:	2785                	addiw	a5,a5,1
    80005e0a:	0711                	addi	a4,a4,4
    80005e0c:	fef61be3          	bne	a2,a5,80005e02 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005e10:	0621                	addi	a2,a2,8
    80005e12:	060a                	slli	a2,a2,0x2
    80005e14:	0001e797          	auipc	a5,0x1e
    80005e18:	12478793          	addi	a5,a5,292 # 80023f38 <log>
    80005e1c:	97b2                	add	a5,a5,a2
    80005e1e:	44d8                	lw	a4,12(s1)
    80005e20:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005e22:	8526                	mv	a0,s1
    80005e24:	fffff097          	auipc	ra,0xfffff
    80005e28:	da2080e7          	jalr	-606(ra) # 80004bc6 <bpin>
    log.lh.n++;
    80005e2c:	0001e717          	auipc	a4,0x1e
    80005e30:	10c70713          	addi	a4,a4,268 # 80023f38 <log>
    80005e34:	575c                	lw	a5,44(a4)
    80005e36:	2785                	addiw	a5,a5,1
    80005e38:	d75c                	sw	a5,44(a4)
    80005e3a:	a82d                	j	80005e74 <log_write+0xc8>
    panic("too big a transaction");
    80005e3c:	00004517          	auipc	a0,0x4
    80005e40:	b8c50513          	addi	a0,a0,-1140 # 800099c8 <syscalls+0x368>
    80005e44:	ffffa097          	auipc	ra,0xffffa
    80005e48:	6f6080e7          	jalr	1782(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    80005e4c:	00004517          	auipc	a0,0x4
    80005e50:	b9450513          	addi	a0,a0,-1132 # 800099e0 <syscalls+0x380>
    80005e54:	ffffa097          	auipc	ra,0xffffa
    80005e58:	6e6080e7          	jalr	1766(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    80005e5c:	00878693          	addi	a3,a5,8
    80005e60:	068a                	slli	a3,a3,0x2
    80005e62:	0001e717          	auipc	a4,0x1e
    80005e66:	0d670713          	addi	a4,a4,214 # 80023f38 <log>
    80005e6a:	9736                	add	a4,a4,a3
    80005e6c:	44d4                	lw	a3,12(s1)
    80005e6e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005e70:	faf609e3          	beq	a2,a5,80005e22 <log_write+0x76>
  }
  release(&log.lock);
    80005e74:	0001e517          	auipc	a0,0x1e
    80005e78:	0c450513          	addi	a0,a0,196 # 80023f38 <log>
    80005e7c:	ffffb097          	auipc	ra,0xffffb
    80005e80:	e08080e7          	jalr	-504(ra) # 80000c84 <release>
}
    80005e84:	60e2                	ld	ra,24(sp)
    80005e86:	6442                	ld	s0,16(sp)
    80005e88:	64a2                	ld	s1,8(sp)
    80005e8a:	6902                	ld	s2,0(sp)
    80005e8c:	6105                	addi	sp,sp,32
    80005e8e:	8082                	ret

0000000080005e90 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005e90:	1101                	addi	sp,sp,-32
    80005e92:	ec06                	sd	ra,24(sp)
    80005e94:	e822                	sd	s0,16(sp)
    80005e96:	e426                	sd	s1,8(sp)
    80005e98:	e04a                	sd	s2,0(sp)
    80005e9a:	1000                	addi	s0,sp,32
    80005e9c:	84aa                	mv	s1,a0
    80005e9e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005ea0:	00004597          	auipc	a1,0x4
    80005ea4:	b6058593          	addi	a1,a1,-1184 # 80009a00 <syscalls+0x3a0>
    80005ea8:	0521                	addi	a0,a0,8
    80005eaa:	ffffb097          	auipc	ra,0xffffb
    80005eae:	c96080e7          	jalr	-874(ra) # 80000b40 <initlock>
  lk->name = name;
    80005eb2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005eb6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005eba:	0204a423          	sw	zero,40(s1)
}
    80005ebe:	60e2                	ld	ra,24(sp)
    80005ec0:	6442                	ld	s0,16(sp)
    80005ec2:	64a2                	ld	s1,8(sp)
    80005ec4:	6902                	ld	s2,0(sp)
    80005ec6:	6105                	addi	sp,sp,32
    80005ec8:	8082                	ret

0000000080005eca <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005eca:	1101                	addi	sp,sp,-32
    80005ecc:	ec06                	sd	ra,24(sp)
    80005ece:	e822                	sd	s0,16(sp)
    80005ed0:	e426                	sd	s1,8(sp)
    80005ed2:	e04a                	sd	s2,0(sp)
    80005ed4:	1000                	addi	s0,sp,32
    80005ed6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005ed8:	00850913          	addi	s2,a0,8
    80005edc:	854a                	mv	a0,s2
    80005ede:	ffffb097          	auipc	ra,0xffffb
    80005ee2:	cf2080e7          	jalr	-782(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    80005ee6:	409c                	lw	a5,0(s1)
    80005ee8:	cb89                	beqz	a5,80005efa <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005eea:	85ca                	mv	a1,s2
    80005eec:	8526                	mv	a0,s1
    80005eee:	ffffd097          	auipc	ra,0xffffd
    80005ef2:	8c2080e7          	jalr	-1854(ra) # 800027b0 <sleep>
  while (lk->locked) {
    80005ef6:	409c                	lw	a5,0(s1)
    80005ef8:	fbed                	bnez	a5,80005eea <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005efa:	4785                	li	a5,1
    80005efc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005efe:	ffffc097          	auipc	ra,0xffffc
    80005f02:	b00080e7          	jalr	-1280(ra) # 800019fe <myproc>
    80005f06:	591c                	lw	a5,48(a0)
    80005f08:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005f0a:	854a                	mv	a0,s2
    80005f0c:	ffffb097          	auipc	ra,0xffffb
    80005f10:	d78080e7          	jalr	-648(ra) # 80000c84 <release>
}
    80005f14:	60e2                	ld	ra,24(sp)
    80005f16:	6442                	ld	s0,16(sp)
    80005f18:	64a2                	ld	s1,8(sp)
    80005f1a:	6902                	ld	s2,0(sp)
    80005f1c:	6105                	addi	sp,sp,32
    80005f1e:	8082                	ret

0000000080005f20 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005f20:	1101                	addi	sp,sp,-32
    80005f22:	ec06                	sd	ra,24(sp)
    80005f24:	e822                	sd	s0,16(sp)
    80005f26:	e426                	sd	s1,8(sp)
    80005f28:	e04a                	sd	s2,0(sp)
    80005f2a:	1000                	addi	s0,sp,32
    80005f2c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005f2e:	00850913          	addi	s2,a0,8
    80005f32:	854a                	mv	a0,s2
    80005f34:	ffffb097          	auipc	ra,0xffffb
    80005f38:	c9c080e7          	jalr	-868(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    80005f3c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005f40:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005f44:	8526                	mv	a0,s1
    80005f46:	ffffd097          	auipc	ra,0xffffd
    80005f4a:	e3c080e7          	jalr	-452(ra) # 80002d82 <wakeup>
  release(&lk->lk);
    80005f4e:	854a                	mv	a0,s2
    80005f50:	ffffb097          	auipc	ra,0xffffb
    80005f54:	d34080e7          	jalr	-716(ra) # 80000c84 <release>
}
    80005f58:	60e2                	ld	ra,24(sp)
    80005f5a:	6442                	ld	s0,16(sp)
    80005f5c:	64a2                	ld	s1,8(sp)
    80005f5e:	6902                	ld	s2,0(sp)
    80005f60:	6105                	addi	sp,sp,32
    80005f62:	8082                	ret

0000000080005f64 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005f64:	7179                	addi	sp,sp,-48
    80005f66:	f406                	sd	ra,40(sp)
    80005f68:	f022                	sd	s0,32(sp)
    80005f6a:	ec26                	sd	s1,24(sp)
    80005f6c:	e84a                	sd	s2,16(sp)
    80005f6e:	e44e                	sd	s3,8(sp)
    80005f70:	1800                	addi	s0,sp,48
    80005f72:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005f74:	00850913          	addi	s2,a0,8
    80005f78:	854a                	mv	a0,s2
    80005f7a:	ffffb097          	auipc	ra,0xffffb
    80005f7e:	c56080e7          	jalr	-938(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80005f82:	409c                	lw	a5,0(s1)
    80005f84:	ef99                	bnez	a5,80005fa2 <holdingsleep+0x3e>
    80005f86:	4481                	li	s1,0
  release(&lk->lk);
    80005f88:	854a                	mv	a0,s2
    80005f8a:	ffffb097          	auipc	ra,0xffffb
    80005f8e:	cfa080e7          	jalr	-774(ra) # 80000c84 <release>
  return r;
}
    80005f92:	8526                	mv	a0,s1
    80005f94:	70a2                	ld	ra,40(sp)
    80005f96:	7402                	ld	s0,32(sp)
    80005f98:	64e2                	ld	s1,24(sp)
    80005f9a:	6942                	ld	s2,16(sp)
    80005f9c:	69a2                	ld	s3,8(sp)
    80005f9e:	6145                	addi	sp,sp,48
    80005fa0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005fa2:	0284a983          	lw	s3,40(s1)
    80005fa6:	ffffc097          	auipc	ra,0xffffc
    80005faa:	a58080e7          	jalr	-1448(ra) # 800019fe <myproc>
    80005fae:	5904                	lw	s1,48(a0)
    80005fb0:	413484b3          	sub	s1,s1,s3
    80005fb4:	0014b493          	seqz	s1,s1
    80005fb8:	bfc1                	j	80005f88 <holdingsleep+0x24>

0000000080005fba <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005fba:	1141                	addi	sp,sp,-16
    80005fbc:	e406                	sd	ra,8(sp)
    80005fbe:	e022                	sd	s0,0(sp)
    80005fc0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005fc2:	00004597          	auipc	a1,0x4
    80005fc6:	a4e58593          	addi	a1,a1,-1458 # 80009a10 <syscalls+0x3b0>
    80005fca:	0001e517          	auipc	a0,0x1e
    80005fce:	0b650513          	addi	a0,a0,182 # 80024080 <ftable>
    80005fd2:	ffffb097          	auipc	ra,0xffffb
    80005fd6:	b6e080e7          	jalr	-1170(ra) # 80000b40 <initlock>
}
    80005fda:	60a2                	ld	ra,8(sp)
    80005fdc:	6402                	ld	s0,0(sp)
    80005fde:	0141                	addi	sp,sp,16
    80005fe0:	8082                	ret

0000000080005fe2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005fe2:	1101                	addi	sp,sp,-32
    80005fe4:	ec06                	sd	ra,24(sp)
    80005fe6:	e822                	sd	s0,16(sp)
    80005fe8:	e426                	sd	s1,8(sp)
    80005fea:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005fec:	0001e517          	auipc	a0,0x1e
    80005ff0:	09450513          	addi	a0,a0,148 # 80024080 <ftable>
    80005ff4:	ffffb097          	auipc	ra,0xffffb
    80005ff8:	bdc080e7          	jalr	-1060(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005ffc:	0001e497          	auipc	s1,0x1e
    80006000:	09c48493          	addi	s1,s1,156 # 80024098 <ftable+0x18>
    80006004:	0001f717          	auipc	a4,0x1f
    80006008:	03470713          	addi	a4,a4,52 # 80025038 <ftable+0xfb8>
    if(f->ref == 0){
    8000600c:	40dc                	lw	a5,4(s1)
    8000600e:	cf99                	beqz	a5,8000602c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80006010:	02848493          	addi	s1,s1,40
    80006014:	fee49ce3          	bne	s1,a4,8000600c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80006018:	0001e517          	auipc	a0,0x1e
    8000601c:	06850513          	addi	a0,a0,104 # 80024080 <ftable>
    80006020:	ffffb097          	auipc	ra,0xffffb
    80006024:	c64080e7          	jalr	-924(ra) # 80000c84 <release>
  return 0;
    80006028:	4481                	li	s1,0
    8000602a:	a819                	j	80006040 <filealloc+0x5e>
      f->ref = 1;
    8000602c:	4785                	li	a5,1
    8000602e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80006030:	0001e517          	auipc	a0,0x1e
    80006034:	05050513          	addi	a0,a0,80 # 80024080 <ftable>
    80006038:	ffffb097          	auipc	ra,0xffffb
    8000603c:	c4c080e7          	jalr	-948(ra) # 80000c84 <release>
}
    80006040:	8526                	mv	a0,s1
    80006042:	60e2                	ld	ra,24(sp)
    80006044:	6442                	ld	s0,16(sp)
    80006046:	64a2                	ld	s1,8(sp)
    80006048:	6105                	addi	sp,sp,32
    8000604a:	8082                	ret

000000008000604c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000604c:	1101                	addi	sp,sp,-32
    8000604e:	ec06                	sd	ra,24(sp)
    80006050:	e822                	sd	s0,16(sp)
    80006052:	e426                	sd	s1,8(sp)
    80006054:	1000                	addi	s0,sp,32
    80006056:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80006058:	0001e517          	auipc	a0,0x1e
    8000605c:	02850513          	addi	a0,a0,40 # 80024080 <ftable>
    80006060:	ffffb097          	auipc	ra,0xffffb
    80006064:	b70080e7          	jalr	-1168(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80006068:	40dc                	lw	a5,4(s1)
    8000606a:	02f05263          	blez	a5,8000608e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000606e:	2785                	addiw	a5,a5,1
    80006070:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80006072:	0001e517          	auipc	a0,0x1e
    80006076:	00e50513          	addi	a0,a0,14 # 80024080 <ftable>
    8000607a:	ffffb097          	auipc	ra,0xffffb
    8000607e:	c0a080e7          	jalr	-1014(ra) # 80000c84 <release>
  return f;
}
    80006082:	8526                	mv	a0,s1
    80006084:	60e2                	ld	ra,24(sp)
    80006086:	6442                	ld	s0,16(sp)
    80006088:	64a2                	ld	s1,8(sp)
    8000608a:	6105                	addi	sp,sp,32
    8000608c:	8082                	ret
    panic("filedup");
    8000608e:	00004517          	auipc	a0,0x4
    80006092:	98a50513          	addi	a0,a0,-1654 # 80009a18 <syscalls+0x3b8>
    80006096:	ffffa097          	auipc	ra,0xffffa
    8000609a:	4a4080e7          	jalr	1188(ra) # 8000053a <panic>

000000008000609e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000609e:	7139                	addi	sp,sp,-64
    800060a0:	fc06                	sd	ra,56(sp)
    800060a2:	f822                	sd	s0,48(sp)
    800060a4:	f426                	sd	s1,40(sp)
    800060a6:	f04a                	sd	s2,32(sp)
    800060a8:	ec4e                	sd	s3,24(sp)
    800060aa:	e852                	sd	s4,16(sp)
    800060ac:	e456                	sd	s5,8(sp)
    800060ae:	0080                	addi	s0,sp,64
    800060b0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800060b2:	0001e517          	auipc	a0,0x1e
    800060b6:	fce50513          	addi	a0,a0,-50 # 80024080 <ftable>
    800060ba:	ffffb097          	auipc	ra,0xffffb
    800060be:	b16080e7          	jalr	-1258(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    800060c2:	40dc                	lw	a5,4(s1)
    800060c4:	06f05163          	blez	a5,80006126 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800060c8:	37fd                	addiw	a5,a5,-1
    800060ca:	0007871b          	sext.w	a4,a5
    800060ce:	c0dc                	sw	a5,4(s1)
    800060d0:	06e04363          	bgtz	a4,80006136 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800060d4:	0004a903          	lw	s2,0(s1)
    800060d8:	0094ca83          	lbu	s5,9(s1)
    800060dc:	0104ba03          	ld	s4,16(s1)
    800060e0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800060e4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800060e8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800060ec:	0001e517          	auipc	a0,0x1e
    800060f0:	f9450513          	addi	a0,a0,-108 # 80024080 <ftable>
    800060f4:	ffffb097          	auipc	ra,0xffffb
    800060f8:	b90080e7          	jalr	-1136(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    800060fc:	4785                	li	a5,1
    800060fe:	04f90d63          	beq	s2,a5,80006158 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80006102:	3979                	addiw	s2,s2,-2
    80006104:	4785                	li	a5,1
    80006106:	0527e063          	bltu	a5,s2,80006146 <fileclose+0xa8>
    begin_op();
    8000610a:	00000097          	auipc	ra,0x0
    8000610e:	acc080e7          	jalr	-1332(ra) # 80005bd6 <begin_op>
    iput(ff.ip);
    80006112:	854e                	mv	a0,s3
    80006114:	fffff097          	auipc	ra,0xfffff
    80006118:	2a0080e7          	jalr	672(ra) # 800053b4 <iput>
    end_op();
    8000611c:	00000097          	auipc	ra,0x0
    80006120:	b38080e7          	jalr	-1224(ra) # 80005c54 <end_op>
    80006124:	a00d                	j	80006146 <fileclose+0xa8>
    panic("fileclose");
    80006126:	00004517          	auipc	a0,0x4
    8000612a:	8fa50513          	addi	a0,a0,-1798 # 80009a20 <syscalls+0x3c0>
    8000612e:	ffffa097          	auipc	ra,0xffffa
    80006132:	40c080e7          	jalr	1036(ra) # 8000053a <panic>
    release(&ftable.lock);
    80006136:	0001e517          	auipc	a0,0x1e
    8000613a:	f4a50513          	addi	a0,a0,-182 # 80024080 <ftable>
    8000613e:	ffffb097          	auipc	ra,0xffffb
    80006142:	b46080e7          	jalr	-1210(ra) # 80000c84 <release>
  }
}
    80006146:	70e2                	ld	ra,56(sp)
    80006148:	7442                	ld	s0,48(sp)
    8000614a:	74a2                	ld	s1,40(sp)
    8000614c:	7902                	ld	s2,32(sp)
    8000614e:	69e2                	ld	s3,24(sp)
    80006150:	6a42                	ld	s4,16(sp)
    80006152:	6aa2                	ld	s5,8(sp)
    80006154:	6121                	addi	sp,sp,64
    80006156:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80006158:	85d6                	mv	a1,s5
    8000615a:	8552                	mv	a0,s4
    8000615c:	00000097          	auipc	ra,0x0
    80006160:	34c080e7          	jalr	844(ra) # 800064a8 <pipeclose>
    80006164:	b7cd                	j	80006146 <fileclose+0xa8>

0000000080006166 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80006166:	715d                	addi	sp,sp,-80
    80006168:	e486                	sd	ra,72(sp)
    8000616a:	e0a2                	sd	s0,64(sp)
    8000616c:	fc26                	sd	s1,56(sp)
    8000616e:	f84a                	sd	s2,48(sp)
    80006170:	f44e                	sd	s3,40(sp)
    80006172:	0880                	addi	s0,sp,80
    80006174:	84aa                	mv	s1,a0
    80006176:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80006178:	ffffc097          	auipc	ra,0xffffc
    8000617c:	886080e7          	jalr	-1914(ra) # 800019fe <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80006180:	409c                	lw	a5,0(s1)
    80006182:	37f9                	addiw	a5,a5,-2
    80006184:	4705                	li	a4,1
    80006186:	04f76763          	bltu	a4,a5,800061d4 <filestat+0x6e>
    8000618a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000618c:	6c88                	ld	a0,24(s1)
    8000618e:	fffff097          	auipc	ra,0xfffff
    80006192:	06c080e7          	jalr	108(ra) # 800051fa <ilock>
    stati(f->ip, &st);
    80006196:	fb840593          	addi	a1,s0,-72
    8000619a:	6c88                	ld	a0,24(s1)
    8000619c:	fffff097          	auipc	ra,0xfffff
    800061a0:	2e8080e7          	jalr	744(ra) # 80005484 <stati>
    iunlock(f->ip);
    800061a4:	6c88                	ld	a0,24(s1)
    800061a6:	fffff097          	auipc	ra,0xfffff
    800061aa:	116080e7          	jalr	278(ra) # 800052bc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800061ae:	46e1                	li	a3,24
    800061b0:	fb840613          	addi	a2,s0,-72
    800061b4:	85ce                	mv	a1,s3
    800061b6:	05893503          	ld	a0,88(s2)
    800061ba:	ffffb097          	auipc	ra,0xffffb
    800061be:	4f0080e7          	jalr	1264(ra) # 800016aa <copyout>
    800061c2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800061c6:	60a6                	ld	ra,72(sp)
    800061c8:	6406                	ld	s0,64(sp)
    800061ca:	74e2                	ld	s1,56(sp)
    800061cc:	7942                	ld	s2,48(sp)
    800061ce:	79a2                	ld	s3,40(sp)
    800061d0:	6161                	addi	sp,sp,80
    800061d2:	8082                	ret
  return -1;
    800061d4:	557d                	li	a0,-1
    800061d6:	bfc5                	j	800061c6 <filestat+0x60>

00000000800061d8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800061d8:	7179                	addi	sp,sp,-48
    800061da:	f406                	sd	ra,40(sp)
    800061dc:	f022                	sd	s0,32(sp)
    800061de:	ec26                	sd	s1,24(sp)
    800061e0:	e84a                	sd	s2,16(sp)
    800061e2:	e44e                	sd	s3,8(sp)
    800061e4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800061e6:	00854783          	lbu	a5,8(a0)
    800061ea:	c3d5                	beqz	a5,8000628e <fileread+0xb6>
    800061ec:	84aa                	mv	s1,a0
    800061ee:	89ae                	mv	s3,a1
    800061f0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800061f2:	411c                	lw	a5,0(a0)
    800061f4:	4705                	li	a4,1
    800061f6:	04e78963          	beq	a5,a4,80006248 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800061fa:	470d                	li	a4,3
    800061fc:	04e78d63          	beq	a5,a4,80006256 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80006200:	4709                	li	a4,2
    80006202:	06e79e63          	bne	a5,a4,8000627e <fileread+0xa6>
    ilock(f->ip);
    80006206:	6d08                	ld	a0,24(a0)
    80006208:	fffff097          	auipc	ra,0xfffff
    8000620c:	ff2080e7          	jalr	-14(ra) # 800051fa <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80006210:	874a                	mv	a4,s2
    80006212:	5094                	lw	a3,32(s1)
    80006214:	864e                	mv	a2,s3
    80006216:	4585                	li	a1,1
    80006218:	6c88                	ld	a0,24(s1)
    8000621a:	fffff097          	auipc	ra,0xfffff
    8000621e:	294080e7          	jalr	660(ra) # 800054ae <readi>
    80006222:	892a                	mv	s2,a0
    80006224:	00a05563          	blez	a0,8000622e <fileread+0x56>
      f->off += r;
    80006228:	509c                	lw	a5,32(s1)
    8000622a:	9fa9                	addw	a5,a5,a0
    8000622c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000622e:	6c88                	ld	a0,24(s1)
    80006230:	fffff097          	auipc	ra,0xfffff
    80006234:	08c080e7          	jalr	140(ra) # 800052bc <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80006238:	854a                	mv	a0,s2
    8000623a:	70a2                	ld	ra,40(sp)
    8000623c:	7402                	ld	s0,32(sp)
    8000623e:	64e2                	ld	s1,24(sp)
    80006240:	6942                	ld	s2,16(sp)
    80006242:	69a2                	ld	s3,8(sp)
    80006244:	6145                	addi	sp,sp,48
    80006246:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80006248:	6908                	ld	a0,16(a0)
    8000624a:	00000097          	auipc	ra,0x0
    8000624e:	3c0080e7          	jalr	960(ra) # 8000660a <piperead>
    80006252:	892a                	mv	s2,a0
    80006254:	b7d5                	j	80006238 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80006256:	02451783          	lh	a5,36(a0)
    8000625a:	03079693          	slli	a3,a5,0x30
    8000625e:	92c1                	srli	a3,a3,0x30
    80006260:	4725                	li	a4,9
    80006262:	02d76863          	bltu	a4,a3,80006292 <fileread+0xba>
    80006266:	0792                	slli	a5,a5,0x4
    80006268:	0001e717          	auipc	a4,0x1e
    8000626c:	d7870713          	addi	a4,a4,-648 # 80023fe0 <devsw>
    80006270:	97ba                	add	a5,a5,a4
    80006272:	639c                	ld	a5,0(a5)
    80006274:	c38d                	beqz	a5,80006296 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80006276:	4505                	li	a0,1
    80006278:	9782                	jalr	a5
    8000627a:	892a                	mv	s2,a0
    8000627c:	bf75                	j	80006238 <fileread+0x60>
    panic("fileread");
    8000627e:	00003517          	auipc	a0,0x3
    80006282:	7b250513          	addi	a0,a0,1970 # 80009a30 <syscalls+0x3d0>
    80006286:	ffffa097          	auipc	ra,0xffffa
    8000628a:	2b4080e7          	jalr	692(ra) # 8000053a <panic>
    return -1;
    8000628e:	597d                	li	s2,-1
    80006290:	b765                	j	80006238 <fileread+0x60>
      return -1;
    80006292:	597d                	li	s2,-1
    80006294:	b755                	j	80006238 <fileread+0x60>
    80006296:	597d                	li	s2,-1
    80006298:	b745                	j	80006238 <fileread+0x60>

000000008000629a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000629a:	715d                	addi	sp,sp,-80
    8000629c:	e486                	sd	ra,72(sp)
    8000629e:	e0a2                	sd	s0,64(sp)
    800062a0:	fc26                	sd	s1,56(sp)
    800062a2:	f84a                	sd	s2,48(sp)
    800062a4:	f44e                	sd	s3,40(sp)
    800062a6:	f052                	sd	s4,32(sp)
    800062a8:	ec56                	sd	s5,24(sp)
    800062aa:	e85a                	sd	s6,16(sp)
    800062ac:	e45e                	sd	s7,8(sp)
    800062ae:	e062                	sd	s8,0(sp)
    800062b0:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800062b2:	00954783          	lbu	a5,9(a0)
    800062b6:	10078663          	beqz	a5,800063c2 <filewrite+0x128>
    800062ba:	892a                	mv	s2,a0
    800062bc:	8b2e                	mv	s6,a1
    800062be:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800062c0:	411c                	lw	a5,0(a0)
    800062c2:	4705                	li	a4,1
    800062c4:	02e78263          	beq	a5,a4,800062e8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800062c8:	470d                	li	a4,3
    800062ca:	02e78663          	beq	a5,a4,800062f6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800062ce:	4709                	li	a4,2
    800062d0:	0ee79163          	bne	a5,a4,800063b2 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800062d4:	0ac05d63          	blez	a2,8000638e <filewrite+0xf4>
    int i = 0;
    800062d8:	4981                	li	s3,0
    800062da:	6b85                	lui	s7,0x1
    800062dc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800062e0:	6c05                	lui	s8,0x1
    800062e2:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800062e6:	a861                	j	8000637e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800062e8:	6908                	ld	a0,16(a0)
    800062ea:	00000097          	auipc	ra,0x0
    800062ee:	22e080e7          	jalr	558(ra) # 80006518 <pipewrite>
    800062f2:	8a2a                	mv	s4,a0
    800062f4:	a045                	j	80006394 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800062f6:	02451783          	lh	a5,36(a0)
    800062fa:	03079693          	slli	a3,a5,0x30
    800062fe:	92c1                	srli	a3,a3,0x30
    80006300:	4725                	li	a4,9
    80006302:	0cd76263          	bltu	a4,a3,800063c6 <filewrite+0x12c>
    80006306:	0792                	slli	a5,a5,0x4
    80006308:	0001e717          	auipc	a4,0x1e
    8000630c:	cd870713          	addi	a4,a4,-808 # 80023fe0 <devsw>
    80006310:	97ba                	add	a5,a5,a4
    80006312:	679c                	ld	a5,8(a5)
    80006314:	cbdd                	beqz	a5,800063ca <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80006316:	4505                	li	a0,1
    80006318:	9782                	jalr	a5
    8000631a:	8a2a                	mv	s4,a0
    8000631c:	a8a5                	j	80006394 <filewrite+0xfa>
    8000631e:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80006322:	00000097          	auipc	ra,0x0
    80006326:	8b4080e7          	jalr	-1868(ra) # 80005bd6 <begin_op>
      ilock(f->ip);
    8000632a:	01893503          	ld	a0,24(s2)
    8000632e:	fffff097          	auipc	ra,0xfffff
    80006332:	ecc080e7          	jalr	-308(ra) # 800051fa <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80006336:	8756                	mv	a4,s5
    80006338:	02092683          	lw	a3,32(s2)
    8000633c:	01698633          	add	a2,s3,s6
    80006340:	4585                	li	a1,1
    80006342:	01893503          	ld	a0,24(s2)
    80006346:	fffff097          	auipc	ra,0xfffff
    8000634a:	260080e7          	jalr	608(ra) # 800055a6 <writei>
    8000634e:	84aa                	mv	s1,a0
    80006350:	00a05763          	blez	a0,8000635e <filewrite+0xc4>
        f->off += r;
    80006354:	02092783          	lw	a5,32(s2)
    80006358:	9fa9                	addw	a5,a5,a0
    8000635a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000635e:	01893503          	ld	a0,24(s2)
    80006362:	fffff097          	auipc	ra,0xfffff
    80006366:	f5a080e7          	jalr	-166(ra) # 800052bc <iunlock>
      end_op();
    8000636a:	00000097          	auipc	ra,0x0
    8000636e:	8ea080e7          	jalr	-1814(ra) # 80005c54 <end_op>

      if(r != n1){
    80006372:	009a9f63          	bne	s5,s1,80006390 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80006376:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000637a:	0149db63          	bge	s3,s4,80006390 <filewrite+0xf6>
      int n1 = n - i;
    8000637e:	413a04bb          	subw	s1,s4,s3
    80006382:	0004879b          	sext.w	a5,s1
    80006386:	f8fbdce3          	bge	s7,a5,8000631e <filewrite+0x84>
    8000638a:	84e2                	mv	s1,s8
    8000638c:	bf49                	j	8000631e <filewrite+0x84>
    int i = 0;
    8000638e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80006390:	013a1f63          	bne	s4,s3,800063ae <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80006394:	8552                	mv	a0,s4
    80006396:	60a6                	ld	ra,72(sp)
    80006398:	6406                	ld	s0,64(sp)
    8000639a:	74e2                	ld	s1,56(sp)
    8000639c:	7942                	ld	s2,48(sp)
    8000639e:	79a2                	ld	s3,40(sp)
    800063a0:	7a02                	ld	s4,32(sp)
    800063a2:	6ae2                	ld	s5,24(sp)
    800063a4:	6b42                	ld	s6,16(sp)
    800063a6:	6ba2                	ld	s7,8(sp)
    800063a8:	6c02                	ld	s8,0(sp)
    800063aa:	6161                	addi	sp,sp,80
    800063ac:	8082                	ret
    ret = (i == n ? n : -1);
    800063ae:	5a7d                	li	s4,-1
    800063b0:	b7d5                	j	80006394 <filewrite+0xfa>
    panic("filewrite");
    800063b2:	00003517          	auipc	a0,0x3
    800063b6:	68e50513          	addi	a0,a0,1678 # 80009a40 <syscalls+0x3e0>
    800063ba:	ffffa097          	auipc	ra,0xffffa
    800063be:	180080e7          	jalr	384(ra) # 8000053a <panic>
    return -1;
    800063c2:	5a7d                	li	s4,-1
    800063c4:	bfc1                	j	80006394 <filewrite+0xfa>
      return -1;
    800063c6:	5a7d                	li	s4,-1
    800063c8:	b7f1                	j	80006394 <filewrite+0xfa>
    800063ca:	5a7d                	li	s4,-1
    800063cc:	b7e1                	j	80006394 <filewrite+0xfa>

00000000800063ce <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800063ce:	7179                	addi	sp,sp,-48
    800063d0:	f406                	sd	ra,40(sp)
    800063d2:	f022                	sd	s0,32(sp)
    800063d4:	ec26                	sd	s1,24(sp)
    800063d6:	e84a                	sd	s2,16(sp)
    800063d8:	e44e                	sd	s3,8(sp)
    800063da:	e052                	sd	s4,0(sp)
    800063dc:	1800                	addi	s0,sp,48
    800063de:	84aa                	mv	s1,a0
    800063e0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800063e2:	0005b023          	sd	zero,0(a1)
    800063e6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800063ea:	00000097          	auipc	ra,0x0
    800063ee:	bf8080e7          	jalr	-1032(ra) # 80005fe2 <filealloc>
    800063f2:	e088                	sd	a0,0(s1)
    800063f4:	c551                	beqz	a0,80006480 <pipealloc+0xb2>
    800063f6:	00000097          	auipc	ra,0x0
    800063fa:	bec080e7          	jalr	-1044(ra) # 80005fe2 <filealloc>
    800063fe:	00aa3023          	sd	a0,0(s4)
    80006402:	c92d                	beqz	a0,80006474 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80006404:	ffffa097          	auipc	ra,0xffffa
    80006408:	6dc080e7          	jalr	1756(ra) # 80000ae0 <kalloc>
    8000640c:	892a                	mv	s2,a0
    8000640e:	c125                	beqz	a0,8000646e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80006410:	4985                	li	s3,1
    80006412:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80006416:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000641a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000641e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80006422:	00003597          	auipc	a1,0x3
    80006426:	62e58593          	addi	a1,a1,1582 # 80009a50 <syscalls+0x3f0>
    8000642a:	ffffa097          	auipc	ra,0xffffa
    8000642e:	716080e7          	jalr	1814(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    80006432:	609c                	ld	a5,0(s1)
    80006434:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80006438:	609c                	ld	a5,0(s1)
    8000643a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000643e:	609c                	ld	a5,0(s1)
    80006440:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80006444:	609c                	ld	a5,0(s1)
    80006446:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000644a:	000a3783          	ld	a5,0(s4)
    8000644e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80006452:	000a3783          	ld	a5,0(s4)
    80006456:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000645a:	000a3783          	ld	a5,0(s4)
    8000645e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80006462:	000a3783          	ld	a5,0(s4)
    80006466:	0127b823          	sd	s2,16(a5)
  return 0;
    8000646a:	4501                	li	a0,0
    8000646c:	a025                	j	80006494 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000646e:	6088                	ld	a0,0(s1)
    80006470:	e501                	bnez	a0,80006478 <pipealloc+0xaa>
    80006472:	a039                	j	80006480 <pipealloc+0xb2>
    80006474:	6088                	ld	a0,0(s1)
    80006476:	c51d                	beqz	a0,800064a4 <pipealloc+0xd6>
    fileclose(*f0);
    80006478:	00000097          	auipc	ra,0x0
    8000647c:	c26080e7          	jalr	-986(ra) # 8000609e <fileclose>
  if(*f1)
    80006480:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80006484:	557d                	li	a0,-1
  if(*f1)
    80006486:	c799                	beqz	a5,80006494 <pipealloc+0xc6>
    fileclose(*f1);
    80006488:	853e                	mv	a0,a5
    8000648a:	00000097          	auipc	ra,0x0
    8000648e:	c14080e7          	jalr	-1004(ra) # 8000609e <fileclose>
  return -1;
    80006492:	557d                	li	a0,-1
}
    80006494:	70a2                	ld	ra,40(sp)
    80006496:	7402                	ld	s0,32(sp)
    80006498:	64e2                	ld	s1,24(sp)
    8000649a:	6942                	ld	s2,16(sp)
    8000649c:	69a2                	ld	s3,8(sp)
    8000649e:	6a02                	ld	s4,0(sp)
    800064a0:	6145                	addi	sp,sp,48
    800064a2:	8082                	ret
  return -1;
    800064a4:	557d                	li	a0,-1
    800064a6:	b7fd                	j	80006494 <pipealloc+0xc6>

00000000800064a8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800064a8:	1101                	addi	sp,sp,-32
    800064aa:	ec06                	sd	ra,24(sp)
    800064ac:	e822                	sd	s0,16(sp)
    800064ae:	e426                	sd	s1,8(sp)
    800064b0:	e04a                	sd	s2,0(sp)
    800064b2:	1000                	addi	s0,sp,32
    800064b4:	84aa                	mv	s1,a0
    800064b6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800064b8:	ffffa097          	auipc	ra,0xffffa
    800064bc:	718080e7          	jalr	1816(ra) # 80000bd0 <acquire>
  if(writable){
    800064c0:	02090d63          	beqz	s2,800064fa <pipeclose+0x52>
    pi->writeopen = 0;
    800064c4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800064c8:	21848513          	addi	a0,s1,536
    800064cc:	ffffd097          	auipc	ra,0xffffd
    800064d0:	8b6080e7          	jalr	-1866(ra) # 80002d82 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800064d4:	2204b783          	ld	a5,544(s1)
    800064d8:	eb95                	bnez	a5,8000650c <pipeclose+0x64>
    release(&pi->lock);
    800064da:	8526                	mv	a0,s1
    800064dc:	ffffa097          	auipc	ra,0xffffa
    800064e0:	7a8080e7          	jalr	1960(ra) # 80000c84 <release>
    kfree((char*)pi);
    800064e4:	8526                	mv	a0,s1
    800064e6:	ffffa097          	auipc	ra,0xffffa
    800064ea:	4fc080e7          	jalr	1276(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    800064ee:	60e2                	ld	ra,24(sp)
    800064f0:	6442                	ld	s0,16(sp)
    800064f2:	64a2                	ld	s1,8(sp)
    800064f4:	6902                	ld	s2,0(sp)
    800064f6:	6105                	addi	sp,sp,32
    800064f8:	8082                	ret
    pi->readopen = 0;
    800064fa:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800064fe:	21c48513          	addi	a0,s1,540
    80006502:	ffffd097          	auipc	ra,0xffffd
    80006506:	880080e7          	jalr	-1920(ra) # 80002d82 <wakeup>
    8000650a:	b7e9                	j	800064d4 <pipeclose+0x2c>
    release(&pi->lock);
    8000650c:	8526                	mv	a0,s1
    8000650e:	ffffa097          	auipc	ra,0xffffa
    80006512:	776080e7          	jalr	1910(ra) # 80000c84 <release>
}
    80006516:	bfe1                	j	800064ee <pipeclose+0x46>

0000000080006518 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80006518:	711d                	addi	sp,sp,-96
    8000651a:	ec86                	sd	ra,88(sp)
    8000651c:	e8a2                	sd	s0,80(sp)
    8000651e:	e4a6                	sd	s1,72(sp)
    80006520:	e0ca                	sd	s2,64(sp)
    80006522:	fc4e                	sd	s3,56(sp)
    80006524:	f852                	sd	s4,48(sp)
    80006526:	f456                	sd	s5,40(sp)
    80006528:	f05a                	sd	s6,32(sp)
    8000652a:	ec5e                	sd	s7,24(sp)
    8000652c:	e862                	sd	s8,16(sp)
    8000652e:	1080                	addi	s0,sp,96
    80006530:	84aa                	mv	s1,a0
    80006532:	8aae                	mv	s5,a1
    80006534:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80006536:	ffffb097          	auipc	ra,0xffffb
    8000653a:	4c8080e7          	jalr	1224(ra) # 800019fe <myproc>
    8000653e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80006540:	8526                	mv	a0,s1
    80006542:	ffffa097          	auipc	ra,0xffffa
    80006546:	68e080e7          	jalr	1678(ra) # 80000bd0 <acquire>
  while(i < n){
    8000654a:	0b405363          	blez	s4,800065f0 <pipewrite+0xd8>
  int i = 0;
    8000654e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80006550:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80006552:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80006556:	21c48b93          	addi	s7,s1,540
    8000655a:	a089                	j	8000659c <pipewrite+0x84>
      release(&pi->lock);
    8000655c:	8526                	mv	a0,s1
    8000655e:	ffffa097          	auipc	ra,0xffffa
    80006562:	726080e7          	jalr	1830(ra) # 80000c84 <release>
      return -1;
    80006566:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80006568:	854a                	mv	a0,s2
    8000656a:	60e6                	ld	ra,88(sp)
    8000656c:	6446                	ld	s0,80(sp)
    8000656e:	64a6                	ld	s1,72(sp)
    80006570:	6906                	ld	s2,64(sp)
    80006572:	79e2                	ld	s3,56(sp)
    80006574:	7a42                	ld	s4,48(sp)
    80006576:	7aa2                	ld	s5,40(sp)
    80006578:	7b02                	ld	s6,32(sp)
    8000657a:	6be2                	ld	s7,24(sp)
    8000657c:	6c42                	ld	s8,16(sp)
    8000657e:	6125                	addi	sp,sp,96
    80006580:	8082                	ret
      wakeup(&pi->nread);
    80006582:	8562                	mv	a0,s8
    80006584:	ffffc097          	auipc	ra,0xffffc
    80006588:	7fe080e7          	jalr	2046(ra) # 80002d82 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000658c:	85a6                	mv	a1,s1
    8000658e:	855e                	mv	a0,s7
    80006590:	ffffc097          	auipc	ra,0xffffc
    80006594:	220080e7          	jalr	544(ra) # 800027b0 <sleep>
  while(i < n){
    80006598:	05495d63          	bge	s2,s4,800065f2 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000659c:	2204a783          	lw	a5,544(s1)
    800065a0:	dfd5                	beqz	a5,8000655c <pipewrite+0x44>
    800065a2:	0289a783          	lw	a5,40(s3)
    800065a6:	fbdd                	bnez	a5,8000655c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800065a8:	2184a783          	lw	a5,536(s1)
    800065ac:	21c4a703          	lw	a4,540(s1)
    800065b0:	2007879b          	addiw	a5,a5,512
    800065b4:	fcf707e3          	beq	a4,a5,80006582 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800065b8:	4685                	li	a3,1
    800065ba:	01590633          	add	a2,s2,s5
    800065be:	faf40593          	addi	a1,s0,-81
    800065c2:	0589b503          	ld	a0,88(s3)
    800065c6:	ffffb097          	auipc	ra,0xffffb
    800065ca:	170080e7          	jalr	368(ra) # 80001736 <copyin>
    800065ce:	03650263          	beq	a0,s6,800065f2 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800065d2:	21c4a783          	lw	a5,540(s1)
    800065d6:	0017871b          	addiw	a4,a5,1
    800065da:	20e4ae23          	sw	a4,540(s1)
    800065de:	1ff7f793          	andi	a5,a5,511
    800065e2:	97a6                	add	a5,a5,s1
    800065e4:	faf44703          	lbu	a4,-81(s0)
    800065e8:	00e78c23          	sb	a4,24(a5)
      i++;
    800065ec:	2905                	addiw	s2,s2,1
    800065ee:	b76d                	j	80006598 <pipewrite+0x80>
  int i = 0;
    800065f0:	4901                	li	s2,0
  wakeup(&pi->nread);
    800065f2:	21848513          	addi	a0,s1,536
    800065f6:	ffffc097          	auipc	ra,0xffffc
    800065fa:	78c080e7          	jalr	1932(ra) # 80002d82 <wakeup>
  release(&pi->lock);
    800065fe:	8526                	mv	a0,s1
    80006600:	ffffa097          	auipc	ra,0xffffa
    80006604:	684080e7          	jalr	1668(ra) # 80000c84 <release>
  return i;
    80006608:	b785                	j	80006568 <pipewrite+0x50>

000000008000660a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000660a:	715d                	addi	sp,sp,-80
    8000660c:	e486                	sd	ra,72(sp)
    8000660e:	e0a2                	sd	s0,64(sp)
    80006610:	fc26                	sd	s1,56(sp)
    80006612:	f84a                	sd	s2,48(sp)
    80006614:	f44e                	sd	s3,40(sp)
    80006616:	f052                	sd	s4,32(sp)
    80006618:	ec56                	sd	s5,24(sp)
    8000661a:	e85a                	sd	s6,16(sp)
    8000661c:	0880                	addi	s0,sp,80
    8000661e:	84aa                	mv	s1,a0
    80006620:	892e                	mv	s2,a1
    80006622:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80006624:	ffffb097          	auipc	ra,0xffffb
    80006628:	3da080e7          	jalr	986(ra) # 800019fe <myproc>
    8000662c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000662e:	8526                	mv	a0,s1
    80006630:	ffffa097          	auipc	ra,0xffffa
    80006634:	5a0080e7          	jalr	1440(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80006638:	2184a703          	lw	a4,536(s1)
    8000663c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80006640:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80006644:	02f71463          	bne	a4,a5,8000666c <piperead+0x62>
    80006648:	2244a783          	lw	a5,548(s1)
    8000664c:	c385                	beqz	a5,8000666c <piperead+0x62>
    if(pr->killed){
    8000664e:	028a2783          	lw	a5,40(s4)
    80006652:	ebc9                	bnez	a5,800066e4 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80006654:	85a6                	mv	a1,s1
    80006656:	854e                	mv	a0,s3
    80006658:	ffffc097          	auipc	ra,0xffffc
    8000665c:	158080e7          	jalr	344(ra) # 800027b0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80006660:	2184a703          	lw	a4,536(s1)
    80006664:	21c4a783          	lw	a5,540(s1)
    80006668:	fef700e3          	beq	a4,a5,80006648 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000666c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000666e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006670:	05505463          	blez	s5,800066b8 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80006674:	2184a783          	lw	a5,536(s1)
    80006678:	21c4a703          	lw	a4,540(s1)
    8000667c:	02f70e63          	beq	a4,a5,800066b8 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80006680:	0017871b          	addiw	a4,a5,1
    80006684:	20e4ac23          	sw	a4,536(s1)
    80006688:	1ff7f793          	andi	a5,a5,511
    8000668c:	97a6                	add	a5,a5,s1
    8000668e:	0187c783          	lbu	a5,24(a5)
    80006692:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80006696:	4685                	li	a3,1
    80006698:	fbf40613          	addi	a2,s0,-65
    8000669c:	85ca                	mv	a1,s2
    8000669e:	058a3503          	ld	a0,88(s4)
    800066a2:	ffffb097          	auipc	ra,0xffffb
    800066a6:	008080e7          	jalr	8(ra) # 800016aa <copyout>
    800066aa:	01650763          	beq	a0,s6,800066b8 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800066ae:	2985                	addiw	s3,s3,1
    800066b0:	0905                	addi	s2,s2,1
    800066b2:	fd3a91e3          	bne	s5,s3,80006674 <piperead+0x6a>
    800066b6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800066b8:	21c48513          	addi	a0,s1,540
    800066bc:	ffffc097          	auipc	ra,0xffffc
    800066c0:	6c6080e7          	jalr	1734(ra) # 80002d82 <wakeup>
  release(&pi->lock);
    800066c4:	8526                	mv	a0,s1
    800066c6:	ffffa097          	auipc	ra,0xffffa
    800066ca:	5be080e7          	jalr	1470(ra) # 80000c84 <release>
  return i;
}
    800066ce:	854e                	mv	a0,s3
    800066d0:	60a6                	ld	ra,72(sp)
    800066d2:	6406                	ld	s0,64(sp)
    800066d4:	74e2                	ld	s1,56(sp)
    800066d6:	7942                	ld	s2,48(sp)
    800066d8:	79a2                	ld	s3,40(sp)
    800066da:	7a02                	ld	s4,32(sp)
    800066dc:	6ae2                	ld	s5,24(sp)
    800066de:	6b42                	ld	s6,16(sp)
    800066e0:	6161                	addi	sp,sp,80
    800066e2:	8082                	ret
      release(&pi->lock);
    800066e4:	8526                	mv	a0,s1
    800066e6:	ffffa097          	auipc	ra,0xffffa
    800066ea:	59e080e7          	jalr	1438(ra) # 80000c84 <release>
      return -1;
    800066ee:	59fd                	li	s3,-1
    800066f0:	bff9                	j	800066ce <piperead+0xc4>

00000000800066f2 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800066f2:	de010113          	addi	sp,sp,-544
    800066f6:	20113c23          	sd	ra,536(sp)
    800066fa:	20813823          	sd	s0,528(sp)
    800066fe:	20913423          	sd	s1,520(sp)
    80006702:	21213023          	sd	s2,512(sp)
    80006706:	ffce                	sd	s3,504(sp)
    80006708:	fbd2                	sd	s4,496(sp)
    8000670a:	f7d6                	sd	s5,488(sp)
    8000670c:	f3da                	sd	s6,480(sp)
    8000670e:	efde                	sd	s7,472(sp)
    80006710:	ebe2                	sd	s8,464(sp)
    80006712:	e7e6                	sd	s9,456(sp)
    80006714:	e3ea                	sd	s10,448(sp)
    80006716:	ff6e                	sd	s11,440(sp)
    80006718:	1400                	addi	s0,sp,544
    8000671a:	892a                	mv	s2,a0
    8000671c:	dea43423          	sd	a0,-536(s0)
    80006720:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80006724:	ffffb097          	auipc	ra,0xffffb
    80006728:	2da080e7          	jalr	730(ra) # 800019fe <myproc>
    8000672c:	84aa                	mv	s1,a0

  begin_op();
    8000672e:	fffff097          	auipc	ra,0xfffff
    80006732:	4a8080e7          	jalr	1192(ra) # 80005bd6 <begin_op>

  if((ip = namei(path)) == 0){
    80006736:	854a                	mv	a0,s2
    80006738:	fffff097          	auipc	ra,0xfffff
    8000673c:	27e080e7          	jalr	638(ra) # 800059b6 <namei>
    80006740:	c93d                	beqz	a0,800067b6 <exec+0xc4>
    80006742:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80006744:	fffff097          	auipc	ra,0xfffff
    80006748:	ab6080e7          	jalr	-1354(ra) # 800051fa <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000674c:	04000713          	li	a4,64
    80006750:	4681                	li	a3,0
    80006752:	e5040613          	addi	a2,s0,-432
    80006756:	4581                	li	a1,0
    80006758:	8556                	mv	a0,s5
    8000675a:	fffff097          	auipc	ra,0xfffff
    8000675e:	d54080e7          	jalr	-684(ra) # 800054ae <readi>
    80006762:	04000793          	li	a5,64
    80006766:	00f51a63          	bne	a0,a5,8000677a <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000676a:	e5042703          	lw	a4,-432(s0)
    8000676e:	464c47b7          	lui	a5,0x464c4
    80006772:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80006776:	04f70663          	beq	a4,a5,800067c2 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000677a:	8556                	mv	a0,s5
    8000677c:	fffff097          	auipc	ra,0xfffff
    80006780:	ce0080e7          	jalr	-800(ra) # 8000545c <iunlockput>
    end_op();
    80006784:	fffff097          	auipc	ra,0xfffff
    80006788:	4d0080e7          	jalr	1232(ra) # 80005c54 <end_op>
  }
  return -1;
    8000678c:	557d                	li	a0,-1
}
    8000678e:	21813083          	ld	ra,536(sp)
    80006792:	21013403          	ld	s0,528(sp)
    80006796:	20813483          	ld	s1,520(sp)
    8000679a:	20013903          	ld	s2,512(sp)
    8000679e:	79fe                	ld	s3,504(sp)
    800067a0:	7a5e                	ld	s4,496(sp)
    800067a2:	7abe                	ld	s5,488(sp)
    800067a4:	7b1e                	ld	s6,480(sp)
    800067a6:	6bfe                	ld	s7,472(sp)
    800067a8:	6c5e                	ld	s8,464(sp)
    800067aa:	6cbe                	ld	s9,456(sp)
    800067ac:	6d1e                	ld	s10,448(sp)
    800067ae:	7dfa                	ld	s11,440(sp)
    800067b0:	22010113          	addi	sp,sp,544
    800067b4:	8082                	ret
    end_op();
    800067b6:	fffff097          	auipc	ra,0xfffff
    800067ba:	49e080e7          	jalr	1182(ra) # 80005c54 <end_op>
    return -1;
    800067be:	557d                	li	a0,-1
    800067c0:	b7f9                	j	8000678e <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800067c2:	8526                	mv	a0,s1
    800067c4:	ffffb097          	auipc	ra,0xffffb
    800067c8:	336080e7          	jalr	822(ra) # 80001afa <proc_pagetable>
    800067cc:	8b2a                	mv	s6,a0
    800067ce:	d555                	beqz	a0,8000677a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800067d0:	e7042783          	lw	a5,-400(s0)
    800067d4:	e8845703          	lhu	a4,-376(s0)
    800067d8:	c735                	beqz	a4,80006844 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800067da:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800067dc:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    800067e0:	6a05                	lui	s4,0x1
    800067e2:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800067e6:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800067ea:	6d85                	lui	s11,0x1
    800067ec:	7d7d                	lui	s10,0xfffff
    800067ee:	ac1d                	j	80006a24 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800067f0:	00003517          	auipc	a0,0x3
    800067f4:	26850513          	addi	a0,a0,616 # 80009a58 <syscalls+0x3f8>
    800067f8:	ffffa097          	auipc	ra,0xffffa
    800067fc:	d42080e7          	jalr	-702(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80006800:	874a                	mv	a4,s2
    80006802:	009c86bb          	addw	a3,s9,s1
    80006806:	4581                	li	a1,0
    80006808:	8556                	mv	a0,s5
    8000680a:	fffff097          	auipc	ra,0xfffff
    8000680e:	ca4080e7          	jalr	-860(ra) # 800054ae <readi>
    80006812:	2501                	sext.w	a0,a0
    80006814:	1aa91863          	bne	s2,a0,800069c4 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80006818:	009d84bb          	addw	s1,s11,s1
    8000681c:	013d09bb          	addw	s3,s10,s3
    80006820:	1f74f263          	bgeu	s1,s7,80006a04 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80006824:	02049593          	slli	a1,s1,0x20
    80006828:	9181                	srli	a1,a1,0x20
    8000682a:	95e2                	add	a1,a1,s8
    8000682c:	855a                	mv	a0,s6
    8000682e:	ffffb097          	auipc	ra,0xffffb
    80006832:	874080e7          	jalr	-1932(ra) # 800010a2 <walkaddr>
    80006836:	862a                	mv	a2,a0
    if(pa == 0)
    80006838:	dd45                	beqz	a0,800067f0 <exec+0xfe>
      n = PGSIZE;
    8000683a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000683c:	fd49f2e3          	bgeu	s3,s4,80006800 <exec+0x10e>
      n = sz - i;
    80006840:	894e                	mv	s2,s3
    80006842:	bf7d                	j	80006800 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80006844:	4481                	li	s1,0
  iunlockput(ip);
    80006846:	8556                	mv	a0,s5
    80006848:	fffff097          	auipc	ra,0xfffff
    8000684c:	c14080e7          	jalr	-1004(ra) # 8000545c <iunlockput>
  end_op();
    80006850:	fffff097          	auipc	ra,0xfffff
    80006854:	404080e7          	jalr	1028(ra) # 80005c54 <end_op>
  p = myproc();
    80006858:	ffffb097          	auipc	ra,0xffffb
    8000685c:	1a6080e7          	jalr	422(ra) # 800019fe <myproc>
    80006860:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80006862:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80006866:	6785                	lui	a5,0x1
    80006868:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000686a:	97a6                	add	a5,a5,s1
    8000686c:	777d                	lui	a4,0xfffff
    8000686e:	8ff9                	and	a5,a5,a4
    80006870:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80006874:	6609                	lui	a2,0x2
    80006876:	963e                	add	a2,a2,a5
    80006878:	85be                	mv	a1,a5
    8000687a:	855a                	mv	a0,s6
    8000687c:	ffffb097          	auipc	ra,0xffffb
    80006880:	bda080e7          	jalr	-1062(ra) # 80001456 <uvmalloc>
    80006884:	8c2a                	mv	s8,a0
  ip = 0;
    80006886:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80006888:	12050e63          	beqz	a0,800069c4 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000688c:	75f9                	lui	a1,0xffffe
    8000688e:	95aa                	add	a1,a1,a0
    80006890:	855a                	mv	a0,s6
    80006892:	ffffb097          	auipc	ra,0xffffb
    80006896:	de6080e7          	jalr	-538(ra) # 80001678 <uvmclear>
  stackbase = sp - PGSIZE;
    8000689a:	7afd                	lui	s5,0xfffff
    8000689c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000689e:	df043783          	ld	a5,-528(s0)
    800068a2:	6388                	ld	a0,0(a5)
    800068a4:	c925                	beqz	a0,80006914 <exec+0x222>
    800068a6:	e9040993          	addi	s3,s0,-368
    800068aa:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800068ae:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800068b0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800068b2:	ffffa097          	auipc	ra,0xffffa
    800068b6:	596080e7          	jalr	1430(ra) # 80000e48 <strlen>
    800068ba:	0015079b          	addiw	a5,a0,1
    800068be:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800068c2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800068c6:	13596363          	bltu	s2,s5,800069ec <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800068ca:	df043d83          	ld	s11,-528(s0)
    800068ce:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800068d2:	8552                	mv	a0,s4
    800068d4:	ffffa097          	auipc	ra,0xffffa
    800068d8:	574080e7          	jalr	1396(ra) # 80000e48 <strlen>
    800068dc:	0015069b          	addiw	a3,a0,1
    800068e0:	8652                	mv	a2,s4
    800068e2:	85ca                	mv	a1,s2
    800068e4:	855a                	mv	a0,s6
    800068e6:	ffffb097          	auipc	ra,0xffffb
    800068ea:	dc4080e7          	jalr	-572(ra) # 800016aa <copyout>
    800068ee:	10054363          	bltz	a0,800069f4 <exec+0x302>
    ustack[argc] = sp;
    800068f2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800068f6:	0485                	addi	s1,s1,1
    800068f8:	008d8793          	addi	a5,s11,8
    800068fc:	def43823          	sd	a5,-528(s0)
    80006900:	008db503          	ld	a0,8(s11)
    80006904:	c911                	beqz	a0,80006918 <exec+0x226>
    if(argc >= MAXARG)
    80006906:	09a1                	addi	s3,s3,8
    80006908:	fb3c95e3          	bne	s9,s3,800068b2 <exec+0x1c0>
  sz = sz1;
    8000690c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80006910:	4a81                	li	s5,0
    80006912:	a84d                	j	800069c4 <exec+0x2d2>
  sp = sz;
    80006914:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80006916:	4481                	li	s1,0
  ustack[argc] = 0;
    80006918:	00349793          	slli	a5,s1,0x3
    8000691c:	f9078793          	addi	a5,a5,-112
    80006920:	97a2                	add	a5,a5,s0
    80006922:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80006926:	00148693          	addi	a3,s1,1
    8000692a:	068e                	slli	a3,a3,0x3
    8000692c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80006930:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80006934:	01597663          	bgeu	s2,s5,80006940 <exec+0x24e>
  sz = sz1;
    80006938:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000693c:	4a81                	li	s5,0
    8000693e:	a059                	j	800069c4 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80006940:	e9040613          	addi	a2,s0,-368
    80006944:	85ca                	mv	a1,s2
    80006946:	855a                	mv	a0,s6
    80006948:	ffffb097          	auipc	ra,0xffffb
    8000694c:	d62080e7          	jalr	-670(ra) # 800016aa <copyout>
    80006950:	0a054663          	bltz	a0,800069fc <exec+0x30a>
  p->trapframe->a1 = sp;
    80006954:	060bb783          	ld	a5,96(s7)
    80006958:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000695c:	de843783          	ld	a5,-536(s0)
    80006960:	0007c703          	lbu	a4,0(a5)
    80006964:	cf11                	beqz	a4,80006980 <exec+0x28e>
    80006966:	0785                	addi	a5,a5,1
    if(*s == '/')
    80006968:	02f00693          	li	a3,47
    8000696c:	a039                	j	8000697a <exec+0x288>
      last = s+1;
    8000696e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80006972:	0785                	addi	a5,a5,1
    80006974:	fff7c703          	lbu	a4,-1(a5)
    80006978:	c701                	beqz	a4,80006980 <exec+0x28e>
    if(*s == '/')
    8000697a:	fed71ce3          	bne	a4,a3,80006972 <exec+0x280>
    8000697e:	bfc5                	j	8000696e <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80006980:	4641                	li	a2,16
    80006982:	de843583          	ld	a1,-536(s0)
    80006986:	160b8513          	addi	a0,s7,352
    8000698a:	ffffa097          	auipc	ra,0xffffa
    8000698e:	48c080e7          	jalr	1164(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80006992:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80006996:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000699a:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000699e:	060bb783          	ld	a5,96(s7)
    800069a2:	e6843703          	ld	a4,-408(s0)
    800069a6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800069a8:	060bb783          	ld	a5,96(s7)
    800069ac:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800069b0:	85ea                	mv	a1,s10
    800069b2:	ffffb097          	auipc	ra,0xffffb
    800069b6:	1e4080e7          	jalr	484(ra) # 80001b96 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800069ba:	0004851b          	sext.w	a0,s1
    800069be:	bbc1                	j	8000678e <exec+0x9c>
    800069c0:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800069c4:	df843583          	ld	a1,-520(s0)
    800069c8:	855a                	mv	a0,s6
    800069ca:	ffffb097          	auipc	ra,0xffffb
    800069ce:	1cc080e7          	jalr	460(ra) # 80001b96 <proc_freepagetable>
  if(ip){
    800069d2:	da0a94e3          	bnez	s5,8000677a <exec+0x88>
  return -1;
    800069d6:	557d                	li	a0,-1
    800069d8:	bb5d                	j	8000678e <exec+0x9c>
    800069da:	de943c23          	sd	s1,-520(s0)
    800069de:	b7dd                	j	800069c4 <exec+0x2d2>
    800069e0:	de943c23          	sd	s1,-520(s0)
    800069e4:	b7c5                	j	800069c4 <exec+0x2d2>
    800069e6:	de943c23          	sd	s1,-520(s0)
    800069ea:	bfe9                	j	800069c4 <exec+0x2d2>
  sz = sz1;
    800069ec:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800069f0:	4a81                	li	s5,0
    800069f2:	bfc9                	j	800069c4 <exec+0x2d2>
  sz = sz1;
    800069f4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800069f8:	4a81                	li	s5,0
    800069fa:	b7e9                	j	800069c4 <exec+0x2d2>
  sz = sz1;
    800069fc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80006a00:	4a81                	li	s5,0
    80006a02:	b7c9                	j	800069c4 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006a04:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006a08:	e0843783          	ld	a5,-504(s0)
    80006a0c:	0017869b          	addiw	a3,a5,1
    80006a10:	e0d43423          	sd	a3,-504(s0)
    80006a14:	e0043783          	ld	a5,-512(s0)
    80006a18:	0387879b          	addiw	a5,a5,56
    80006a1c:	e8845703          	lhu	a4,-376(s0)
    80006a20:	e2e6d3e3          	bge	a3,a4,80006846 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006a24:	2781                	sext.w	a5,a5
    80006a26:	e0f43023          	sd	a5,-512(s0)
    80006a2a:	03800713          	li	a4,56
    80006a2e:	86be                	mv	a3,a5
    80006a30:	e1840613          	addi	a2,s0,-488
    80006a34:	4581                	li	a1,0
    80006a36:	8556                	mv	a0,s5
    80006a38:	fffff097          	auipc	ra,0xfffff
    80006a3c:	a76080e7          	jalr	-1418(ra) # 800054ae <readi>
    80006a40:	03800793          	li	a5,56
    80006a44:	f6f51ee3          	bne	a0,a5,800069c0 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80006a48:	e1842783          	lw	a5,-488(s0)
    80006a4c:	4705                	li	a4,1
    80006a4e:	fae79de3          	bne	a5,a4,80006a08 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80006a52:	e4043603          	ld	a2,-448(s0)
    80006a56:	e3843783          	ld	a5,-456(s0)
    80006a5a:	f8f660e3          	bltu	a2,a5,800069da <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80006a5e:	e2843783          	ld	a5,-472(s0)
    80006a62:	963e                	add	a2,a2,a5
    80006a64:	f6f66ee3          	bltu	a2,a5,800069e0 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006a68:	85a6                	mv	a1,s1
    80006a6a:	855a                	mv	a0,s6
    80006a6c:	ffffb097          	auipc	ra,0xffffb
    80006a70:	9ea080e7          	jalr	-1558(ra) # 80001456 <uvmalloc>
    80006a74:	dea43c23          	sd	a0,-520(s0)
    80006a78:	d53d                	beqz	a0,800069e6 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80006a7a:	e2843c03          	ld	s8,-472(s0)
    80006a7e:	de043783          	ld	a5,-544(s0)
    80006a82:	00fc77b3          	and	a5,s8,a5
    80006a86:	ff9d                	bnez	a5,800069c4 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80006a88:	e2042c83          	lw	s9,-480(s0)
    80006a8c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80006a90:	f60b8ae3          	beqz	s7,80006a04 <exec+0x312>
    80006a94:	89de                	mv	s3,s7
    80006a96:	4481                	li	s1,0
    80006a98:	b371                	j	80006824 <exec+0x132>

0000000080006a9a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006a9a:	7179                	addi	sp,sp,-48
    80006a9c:	f406                	sd	ra,40(sp)
    80006a9e:	f022                	sd	s0,32(sp)
    80006aa0:	ec26                	sd	s1,24(sp)
    80006aa2:	e84a                	sd	s2,16(sp)
    80006aa4:	1800                	addi	s0,sp,48
    80006aa6:	892e                	mv	s2,a1
    80006aa8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80006aaa:	fdc40593          	addi	a1,s0,-36
    80006aae:	ffffd097          	auipc	ra,0xffffd
    80006ab2:	326080e7          	jalr	806(ra) # 80003dd4 <argint>
    80006ab6:	04054063          	bltz	a0,80006af6 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006aba:	fdc42703          	lw	a4,-36(s0)
    80006abe:	47bd                	li	a5,15
    80006ac0:	02e7ed63          	bltu	a5,a4,80006afa <argfd+0x60>
    80006ac4:	ffffb097          	auipc	ra,0xffffb
    80006ac8:	f3a080e7          	jalr	-198(ra) # 800019fe <myproc>
    80006acc:	fdc42703          	lw	a4,-36(s0)
    80006ad0:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd601a>
    80006ad4:	078e                	slli	a5,a5,0x3
    80006ad6:	953e                	add	a0,a0,a5
    80006ad8:	651c                	ld	a5,8(a0)
    80006ada:	c395                	beqz	a5,80006afe <argfd+0x64>
    return -1;
  if(pfd)
    80006adc:	00090463          	beqz	s2,80006ae4 <argfd+0x4a>
    *pfd = fd;
    80006ae0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80006ae4:	4501                	li	a0,0
  if(pf)
    80006ae6:	c091                	beqz	s1,80006aea <argfd+0x50>
    *pf = f;
    80006ae8:	e09c                	sd	a5,0(s1)
}
    80006aea:	70a2                	ld	ra,40(sp)
    80006aec:	7402                	ld	s0,32(sp)
    80006aee:	64e2                	ld	s1,24(sp)
    80006af0:	6942                	ld	s2,16(sp)
    80006af2:	6145                	addi	sp,sp,48
    80006af4:	8082                	ret
    return -1;
    80006af6:	557d                	li	a0,-1
    80006af8:	bfcd                	j	80006aea <argfd+0x50>
    return -1;
    80006afa:	557d                	li	a0,-1
    80006afc:	b7fd                	j	80006aea <argfd+0x50>
    80006afe:	557d                	li	a0,-1
    80006b00:	b7ed                	j	80006aea <argfd+0x50>

0000000080006b02 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006b02:	1101                	addi	sp,sp,-32
    80006b04:	ec06                	sd	ra,24(sp)
    80006b06:	e822                	sd	s0,16(sp)
    80006b08:	e426                	sd	s1,8(sp)
    80006b0a:	1000                	addi	s0,sp,32
    80006b0c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80006b0e:	ffffb097          	auipc	ra,0xffffb
    80006b12:	ef0080e7          	jalr	-272(ra) # 800019fe <myproc>
    80006b16:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006b18:	0d850793          	addi	a5,a0,216
    80006b1c:	4501                	li	a0,0
    80006b1e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80006b20:	6398                	ld	a4,0(a5)
    80006b22:	cb19                	beqz	a4,80006b38 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006b24:	2505                	addiw	a0,a0,1
    80006b26:	07a1                	addi	a5,a5,8
    80006b28:	fed51ce3          	bne	a0,a3,80006b20 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80006b2c:	557d                	li	a0,-1
}
    80006b2e:	60e2                	ld	ra,24(sp)
    80006b30:	6442                	ld	s0,16(sp)
    80006b32:	64a2                	ld	s1,8(sp)
    80006b34:	6105                	addi	sp,sp,32
    80006b36:	8082                	ret
      p->ofile[fd] = f;
    80006b38:	01a50793          	addi	a5,a0,26
    80006b3c:	078e                	slli	a5,a5,0x3
    80006b3e:	963e                	add	a2,a2,a5
    80006b40:	e604                	sd	s1,8(a2)
      return fd;
    80006b42:	b7f5                	j	80006b2e <fdalloc+0x2c>

0000000080006b44 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80006b44:	715d                	addi	sp,sp,-80
    80006b46:	e486                	sd	ra,72(sp)
    80006b48:	e0a2                	sd	s0,64(sp)
    80006b4a:	fc26                	sd	s1,56(sp)
    80006b4c:	f84a                	sd	s2,48(sp)
    80006b4e:	f44e                	sd	s3,40(sp)
    80006b50:	f052                	sd	s4,32(sp)
    80006b52:	ec56                	sd	s5,24(sp)
    80006b54:	0880                	addi	s0,sp,80
    80006b56:	89ae                	mv	s3,a1
    80006b58:	8ab2                	mv	s5,a2
    80006b5a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006b5c:	fb040593          	addi	a1,s0,-80
    80006b60:	fffff097          	auipc	ra,0xfffff
    80006b64:	e74080e7          	jalr	-396(ra) # 800059d4 <nameiparent>
    80006b68:	892a                	mv	s2,a0
    80006b6a:	12050e63          	beqz	a0,80006ca6 <create+0x162>
    return 0;

  ilock(dp);
    80006b6e:	ffffe097          	auipc	ra,0xffffe
    80006b72:	68c080e7          	jalr	1676(ra) # 800051fa <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80006b76:	4601                	li	a2,0
    80006b78:	fb040593          	addi	a1,s0,-80
    80006b7c:	854a                	mv	a0,s2
    80006b7e:	fffff097          	auipc	ra,0xfffff
    80006b82:	b60080e7          	jalr	-1184(ra) # 800056de <dirlookup>
    80006b86:	84aa                	mv	s1,a0
    80006b88:	c921                	beqz	a0,80006bd8 <create+0x94>
    iunlockput(dp);
    80006b8a:	854a                	mv	a0,s2
    80006b8c:	fffff097          	auipc	ra,0xfffff
    80006b90:	8d0080e7          	jalr	-1840(ra) # 8000545c <iunlockput>
    ilock(ip);
    80006b94:	8526                	mv	a0,s1
    80006b96:	ffffe097          	auipc	ra,0xffffe
    80006b9a:	664080e7          	jalr	1636(ra) # 800051fa <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006b9e:	2981                	sext.w	s3,s3
    80006ba0:	4789                	li	a5,2
    80006ba2:	02f99463          	bne	s3,a5,80006bca <create+0x86>
    80006ba6:	0444d783          	lhu	a5,68(s1)
    80006baa:	37f9                	addiw	a5,a5,-2
    80006bac:	17c2                	slli	a5,a5,0x30
    80006bae:	93c1                	srli	a5,a5,0x30
    80006bb0:	4705                	li	a4,1
    80006bb2:	00f76c63          	bltu	a4,a5,80006bca <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006bb6:	8526                	mv	a0,s1
    80006bb8:	60a6                	ld	ra,72(sp)
    80006bba:	6406                	ld	s0,64(sp)
    80006bbc:	74e2                	ld	s1,56(sp)
    80006bbe:	7942                	ld	s2,48(sp)
    80006bc0:	79a2                	ld	s3,40(sp)
    80006bc2:	7a02                	ld	s4,32(sp)
    80006bc4:	6ae2                	ld	s5,24(sp)
    80006bc6:	6161                	addi	sp,sp,80
    80006bc8:	8082                	ret
    iunlockput(ip);
    80006bca:	8526                	mv	a0,s1
    80006bcc:	fffff097          	auipc	ra,0xfffff
    80006bd0:	890080e7          	jalr	-1904(ra) # 8000545c <iunlockput>
    return 0;
    80006bd4:	4481                	li	s1,0
    80006bd6:	b7c5                	j	80006bb6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006bd8:	85ce                	mv	a1,s3
    80006bda:	00092503          	lw	a0,0(s2)
    80006bde:	ffffe097          	auipc	ra,0xffffe
    80006be2:	482080e7          	jalr	1154(ra) # 80005060 <ialloc>
    80006be6:	84aa                	mv	s1,a0
    80006be8:	c521                	beqz	a0,80006c30 <create+0xec>
  ilock(ip);
    80006bea:	ffffe097          	auipc	ra,0xffffe
    80006bee:	610080e7          	jalr	1552(ra) # 800051fa <ilock>
  ip->major = major;
    80006bf2:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006bf6:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006bfa:	4a05                	li	s4,1
    80006bfc:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006c00:	8526                	mv	a0,s1
    80006c02:	ffffe097          	auipc	ra,0xffffe
    80006c06:	52c080e7          	jalr	1324(ra) # 8000512e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006c0a:	2981                	sext.w	s3,s3
    80006c0c:	03498a63          	beq	s3,s4,80006c40 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006c10:	40d0                	lw	a2,4(s1)
    80006c12:	fb040593          	addi	a1,s0,-80
    80006c16:	854a                	mv	a0,s2
    80006c18:	fffff097          	auipc	ra,0xfffff
    80006c1c:	cdc080e7          	jalr	-804(ra) # 800058f4 <dirlink>
    80006c20:	06054b63          	bltz	a0,80006c96 <create+0x152>
  iunlockput(dp);
    80006c24:	854a                	mv	a0,s2
    80006c26:	fffff097          	auipc	ra,0xfffff
    80006c2a:	836080e7          	jalr	-1994(ra) # 8000545c <iunlockput>
  return ip;
    80006c2e:	b761                	j	80006bb6 <create+0x72>
    panic("create: ialloc");
    80006c30:	00003517          	auipc	a0,0x3
    80006c34:	e4850513          	addi	a0,a0,-440 # 80009a78 <syscalls+0x418>
    80006c38:	ffffa097          	auipc	ra,0xffffa
    80006c3c:	902080e7          	jalr	-1790(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    80006c40:	04a95783          	lhu	a5,74(s2)
    80006c44:	2785                	addiw	a5,a5,1
    80006c46:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006c4a:	854a                	mv	a0,s2
    80006c4c:	ffffe097          	auipc	ra,0xffffe
    80006c50:	4e2080e7          	jalr	1250(ra) # 8000512e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006c54:	40d0                	lw	a2,4(s1)
    80006c56:	00003597          	auipc	a1,0x3
    80006c5a:	e3258593          	addi	a1,a1,-462 # 80009a88 <syscalls+0x428>
    80006c5e:	8526                	mv	a0,s1
    80006c60:	fffff097          	auipc	ra,0xfffff
    80006c64:	c94080e7          	jalr	-876(ra) # 800058f4 <dirlink>
    80006c68:	00054f63          	bltz	a0,80006c86 <create+0x142>
    80006c6c:	00492603          	lw	a2,4(s2)
    80006c70:	00003597          	auipc	a1,0x3
    80006c74:	e2058593          	addi	a1,a1,-480 # 80009a90 <syscalls+0x430>
    80006c78:	8526                	mv	a0,s1
    80006c7a:	fffff097          	auipc	ra,0xfffff
    80006c7e:	c7a080e7          	jalr	-902(ra) # 800058f4 <dirlink>
    80006c82:	f80557e3          	bgez	a0,80006c10 <create+0xcc>
      panic("create dots");
    80006c86:	00003517          	auipc	a0,0x3
    80006c8a:	e1250513          	addi	a0,a0,-494 # 80009a98 <syscalls+0x438>
    80006c8e:	ffffa097          	auipc	ra,0xffffa
    80006c92:	8ac080e7          	jalr	-1876(ra) # 8000053a <panic>
    panic("create: dirlink");
    80006c96:	00003517          	auipc	a0,0x3
    80006c9a:	e1250513          	addi	a0,a0,-494 # 80009aa8 <syscalls+0x448>
    80006c9e:	ffffa097          	auipc	ra,0xffffa
    80006ca2:	89c080e7          	jalr	-1892(ra) # 8000053a <panic>
    return 0;
    80006ca6:	84aa                	mv	s1,a0
    80006ca8:	b739                	j	80006bb6 <create+0x72>

0000000080006caa <sys_dup>:
{
    80006caa:	7179                	addi	sp,sp,-48
    80006cac:	f406                	sd	ra,40(sp)
    80006cae:	f022                	sd	s0,32(sp)
    80006cb0:	ec26                	sd	s1,24(sp)
    80006cb2:	e84a                	sd	s2,16(sp)
    80006cb4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006cb6:	fd840613          	addi	a2,s0,-40
    80006cba:	4581                	li	a1,0
    80006cbc:	4501                	li	a0,0
    80006cbe:	00000097          	auipc	ra,0x0
    80006cc2:	ddc080e7          	jalr	-548(ra) # 80006a9a <argfd>
    return -1;
    80006cc6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006cc8:	02054363          	bltz	a0,80006cee <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80006ccc:	fd843903          	ld	s2,-40(s0)
    80006cd0:	854a                	mv	a0,s2
    80006cd2:	00000097          	auipc	ra,0x0
    80006cd6:	e30080e7          	jalr	-464(ra) # 80006b02 <fdalloc>
    80006cda:	84aa                	mv	s1,a0
    return -1;
    80006cdc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006cde:	00054863          	bltz	a0,80006cee <sys_dup+0x44>
  filedup(f);
    80006ce2:	854a                	mv	a0,s2
    80006ce4:	fffff097          	auipc	ra,0xfffff
    80006ce8:	368080e7          	jalr	872(ra) # 8000604c <filedup>
  return fd;
    80006cec:	87a6                	mv	a5,s1
}
    80006cee:	853e                	mv	a0,a5
    80006cf0:	70a2                	ld	ra,40(sp)
    80006cf2:	7402                	ld	s0,32(sp)
    80006cf4:	64e2                	ld	s1,24(sp)
    80006cf6:	6942                	ld	s2,16(sp)
    80006cf8:	6145                	addi	sp,sp,48
    80006cfa:	8082                	ret

0000000080006cfc <sys_read>:
{
    80006cfc:	7179                	addi	sp,sp,-48
    80006cfe:	f406                	sd	ra,40(sp)
    80006d00:	f022                	sd	s0,32(sp)
    80006d02:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d04:	fe840613          	addi	a2,s0,-24
    80006d08:	4581                	li	a1,0
    80006d0a:	4501                	li	a0,0
    80006d0c:	00000097          	auipc	ra,0x0
    80006d10:	d8e080e7          	jalr	-626(ra) # 80006a9a <argfd>
    return -1;
    80006d14:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d16:	04054163          	bltz	a0,80006d58 <sys_read+0x5c>
    80006d1a:	fe440593          	addi	a1,s0,-28
    80006d1e:	4509                	li	a0,2
    80006d20:	ffffd097          	auipc	ra,0xffffd
    80006d24:	0b4080e7          	jalr	180(ra) # 80003dd4 <argint>
    return -1;
    80006d28:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d2a:	02054763          	bltz	a0,80006d58 <sys_read+0x5c>
    80006d2e:	fd840593          	addi	a1,s0,-40
    80006d32:	4505                	li	a0,1
    80006d34:	ffffd097          	auipc	ra,0xffffd
    80006d38:	0c2080e7          	jalr	194(ra) # 80003df6 <argaddr>
    return -1;
    80006d3c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d3e:	00054d63          	bltz	a0,80006d58 <sys_read+0x5c>
  return fileread(f, p, n);
    80006d42:	fe442603          	lw	a2,-28(s0)
    80006d46:	fd843583          	ld	a1,-40(s0)
    80006d4a:	fe843503          	ld	a0,-24(s0)
    80006d4e:	fffff097          	auipc	ra,0xfffff
    80006d52:	48a080e7          	jalr	1162(ra) # 800061d8 <fileread>
    80006d56:	87aa                	mv	a5,a0
}
    80006d58:	853e                	mv	a0,a5
    80006d5a:	70a2                	ld	ra,40(sp)
    80006d5c:	7402                	ld	s0,32(sp)
    80006d5e:	6145                	addi	sp,sp,48
    80006d60:	8082                	ret

0000000080006d62 <sys_write>:
{
    80006d62:	7179                	addi	sp,sp,-48
    80006d64:	f406                	sd	ra,40(sp)
    80006d66:	f022                	sd	s0,32(sp)
    80006d68:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d6a:	fe840613          	addi	a2,s0,-24
    80006d6e:	4581                	li	a1,0
    80006d70:	4501                	li	a0,0
    80006d72:	00000097          	auipc	ra,0x0
    80006d76:	d28080e7          	jalr	-728(ra) # 80006a9a <argfd>
    return -1;
    80006d7a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d7c:	04054163          	bltz	a0,80006dbe <sys_write+0x5c>
    80006d80:	fe440593          	addi	a1,s0,-28
    80006d84:	4509                	li	a0,2
    80006d86:	ffffd097          	auipc	ra,0xffffd
    80006d8a:	04e080e7          	jalr	78(ra) # 80003dd4 <argint>
    return -1;
    80006d8e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d90:	02054763          	bltz	a0,80006dbe <sys_write+0x5c>
    80006d94:	fd840593          	addi	a1,s0,-40
    80006d98:	4505                	li	a0,1
    80006d9a:	ffffd097          	auipc	ra,0xffffd
    80006d9e:	05c080e7          	jalr	92(ra) # 80003df6 <argaddr>
    return -1;
    80006da2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006da4:	00054d63          	bltz	a0,80006dbe <sys_write+0x5c>
  return filewrite(f, p, n);
    80006da8:	fe442603          	lw	a2,-28(s0)
    80006dac:	fd843583          	ld	a1,-40(s0)
    80006db0:	fe843503          	ld	a0,-24(s0)
    80006db4:	fffff097          	auipc	ra,0xfffff
    80006db8:	4e6080e7          	jalr	1254(ra) # 8000629a <filewrite>
    80006dbc:	87aa                	mv	a5,a0
}
    80006dbe:	853e                	mv	a0,a5
    80006dc0:	70a2                	ld	ra,40(sp)
    80006dc2:	7402                	ld	s0,32(sp)
    80006dc4:	6145                	addi	sp,sp,48
    80006dc6:	8082                	ret

0000000080006dc8 <sys_close>:
{
    80006dc8:	1101                	addi	sp,sp,-32
    80006dca:	ec06                	sd	ra,24(sp)
    80006dcc:	e822                	sd	s0,16(sp)
    80006dce:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80006dd0:	fe040613          	addi	a2,s0,-32
    80006dd4:	fec40593          	addi	a1,s0,-20
    80006dd8:	4501                	li	a0,0
    80006dda:	00000097          	auipc	ra,0x0
    80006dde:	cc0080e7          	jalr	-832(ra) # 80006a9a <argfd>
    return -1;
    80006de2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006de4:	02054463          	bltz	a0,80006e0c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006de8:	ffffb097          	auipc	ra,0xffffb
    80006dec:	c16080e7          	jalr	-1002(ra) # 800019fe <myproc>
    80006df0:	fec42783          	lw	a5,-20(s0)
    80006df4:	07e9                	addi	a5,a5,26
    80006df6:	078e                	slli	a5,a5,0x3
    80006df8:	953e                	add	a0,a0,a5
    80006dfa:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80006dfe:	fe043503          	ld	a0,-32(s0)
    80006e02:	fffff097          	auipc	ra,0xfffff
    80006e06:	29c080e7          	jalr	668(ra) # 8000609e <fileclose>
  return 0;
    80006e0a:	4781                	li	a5,0
}
    80006e0c:	853e                	mv	a0,a5
    80006e0e:	60e2                	ld	ra,24(sp)
    80006e10:	6442                	ld	s0,16(sp)
    80006e12:	6105                	addi	sp,sp,32
    80006e14:	8082                	ret

0000000080006e16 <sys_fstat>:
{
    80006e16:	1101                	addi	sp,sp,-32
    80006e18:	ec06                	sd	ra,24(sp)
    80006e1a:	e822                	sd	s0,16(sp)
    80006e1c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006e1e:	fe840613          	addi	a2,s0,-24
    80006e22:	4581                	li	a1,0
    80006e24:	4501                	li	a0,0
    80006e26:	00000097          	auipc	ra,0x0
    80006e2a:	c74080e7          	jalr	-908(ra) # 80006a9a <argfd>
    return -1;
    80006e2e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006e30:	02054563          	bltz	a0,80006e5a <sys_fstat+0x44>
    80006e34:	fe040593          	addi	a1,s0,-32
    80006e38:	4505                	li	a0,1
    80006e3a:	ffffd097          	auipc	ra,0xffffd
    80006e3e:	fbc080e7          	jalr	-68(ra) # 80003df6 <argaddr>
    return -1;
    80006e42:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006e44:	00054b63          	bltz	a0,80006e5a <sys_fstat+0x44>
  return filestat(f, st);
    80006e48:	fe043583          	ld	a1,-32(s0)
    80006e4c:	fe843503          	ld	a0,-24(s0)
    80006e50:	fffff097          	auipc	ra,0xfffff
    80006e54:	316080e7          	jalr	790(ra) # 80006166 <filestat>
    80006e58:	87aa                	mv	a5,a0
}
    80006e5a:	853e                	mv	a0,a5
    80006e5c:	60e2                	ld	ra,24(sp)
    80006e5e:	6442                	ld	s0,16(sp)
    80006e60:	6105                	addi	sp,sp,32
    80006e62:	8082                	ret

0000000080006e64 <sys_link>:
{
    80006e64:	7169                	addi	sp,sp,-304
    80006e66:	f606                	sd	ra,296(sp)
    80006e68:	f222                	sd	s0,288(sp)
    80006e6a:	ee26                	sd	s1,280(sp)
    80006e6c:	ea4a                	sd	s2,272(sp)
    80006e6e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006e70:	08000613          	li	a2,128
    80006e74:	ed040593          	addi	a1,s0,-304
    80006e78:	4501                	li	a0,0
    80006e7a:	ffffd097          	auipc	ra,0xffffd
    80006e7e:	f9e080e7          	jalr	-98(ra) # 80003e18 <argstr>
    return -1;
    80006e82:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006e84:	10054e63          	bltz	a0,80006fa0 <sys_link+0x13c>
    80006e88:	08000613          	li	a2,128
    80006e8c:	f5040593          	addi	a1,s0,-176
    80006e90:	4505                	li	a0,1
    80006e92:	ffffd097          	auipc	ra,0xffffd
    80006e96:	f86080e7          	jalr	-122(ra) # 80003e18 <argstr>
    return -1;
    80006e9a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006e9c:	10054263          	bltz	a0,80006fa0 <sys_link+0x13c>
  begin_op();
    80006ea0:	fffff097          	auipc	ra,0xfffff
    80006ea4:	d36080e7          	jalr	-714(ra) # 80005bd6 <begin_op>
  if((ip = namei(old)) == 0){
    80006ea8:	ed040513          	addi	a0,s0,-304
    80006eac:	fffff097          	auipc	ra,0xfffff
    80006eb0:	b0a080e7          	jalr	-1270(ra) # 800059b6 <namei>
    80006eb4:	84aa                	mv	s1,a0
    80006eb6:	c551                	beqz	a0,80006f42 <sys_link+0xde>
  ilock(ip);
    80006eb8:	ffffe097          	auipc	ra,0xffffe
    80006ebc:	342080e7          	jalr	834(ra) # 800051fa <ilock>
  if(ip->type == T_DIR){
    80006ec0:	04449703          	lh	a4,68(s1)
    80006ec4:	4785                	li	a5,1
    80006ec6:	08f70463          	beq	a4,a5,80006f4e <sys_link+0xea>
  ip->nlink++;
    80006eca:	04a4d783          	lhu	a5,74(s1)
    80006ece:	2785                	addiw	a5,a5,1
    80006ed0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006ed4:	8526                	mv	a0,s1
    80006ed6:	ffffe097          	auipc	ra,0xffffe
    80006eda:	258080e7          	jalr	600(ra) # 8000512e <iupdate>
  iunlock(ip);
    80006ede:	8526                	mv	a0,s1
    80006ee0:	ffffe097          	auipc	ra,0xffffe
    80006ee4:	3dc080e7          	jalr	988(ra) # 800052bc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006ee8:	fd040593          	addi	a1,s0,-48
    80006eec:	f5040513          	addi	a0,s0,-176
    80006ef0:	fffff097          	auipc	ra,0xfffff
    80006ef4:	ae4080e7          	jalr	-1308(ra) # 800059d4 <nameiparent>
    80006ef8:	892a                	mv	s2,a0
    80006efa:	c935                	beqz	a0,80006f6e <sys_link+0x10a>
  ilock(dp);
    80006efc:	ffffe097          	auipc	ra,0xffffe
    80006f00:	2fe080e7          	jalr	766(ra) # 800051fa <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006f04:	00092703          	lw	a4,0(s2)
    80006f08:	409c                	lw	a5,0(s1)
    80006f0a:	04f71d63          	bne	a4,a5,80006f64 <sys_link+0x100>
    80006f0e:	40d0                	lw	a2,4(s1)
    80006f10:	fd040593          	addi	a1,s0,-48
    80006f14:	854a                	mv	a0,s2
    80006f16:	fffff097          	auipc	ra,0xfffff
    80006f1a:	9de080e7          	jalr	-1570(ra) # 800058f4 <dirlink>
    80006f1e:	04054363          	bltz	a0,80006f64 <sys_link+0x100>
  iunlockput(dp);
    80006f22:	854a                	mv	a0,s2
    80006f24:	ffffe097          	auipc	ra,0xffffe
    80006f28:	538080e7          	jalr	1336(ra) # 8000545c <iunlockput>
  iput(ip);
    80006f2c:	8526                	mv	a0,s1
    80006f2e:	ffffe097          	auipc	ra,0xffffe
    80006f32:	486080e7          	jalr	1158(ra) # 800053b4 <iput>
  end_op();
    80006f36:	fffff097          	auipc	ra,0xfffff
    80006f3a:	d1e080e7          	jalr	-738(ra) # 80005c54 <end_op>
  return 0;
    80006f3e:	4781                	li	a5,0
    80006f40:	a085                	j	80006fa0 <sys_link+0x13c>
    end_op();
    80006f42:	fffff097          	auipc	ra,0xfffff
    80006f46:	d12080e7          	jalr	-750(ra) # 80005c54 <end_op>
    return -1;
    80006f4a:	57fd                	li	a5,-1
    80006f4c:	a891                	j	80006fa0 <sys_link+0x13c>
    iunlockput(ip);
    80006f4e:	8526                	mv	a0,s1
    80006f50:	ffffe097          	auipc	ra,0xffffe
    80006f54:	50c080e7          	jalr	1292(ra) # 8000545c <iunlockput>
    end_op();
    80006f58:	fffff097          	auipc	ra,0xfffff
    80006f5c:	cfc080e7          	jalr	-772(ra) # 80005c54 <end_op>
    return -1;
    80006f60:	57fd                	li	a5,-1
    80006f62:	a83d                	j	80006fa0 <sys_link+0x13c>
    iunlockput(dp);
    80006f64:	854a                	mv	a0,s2
    80006f66:	ffffe097          	auipc	ra,0xffffe
    80006f6a:	4f6080e7          	jalr	1270(ra) # 8000545c <iunlockput>
  ilock(ip);
    80006f6e:	8526                	mv	a0,s1
    80006f70:	ffffe097          	auipc	ra,0xffffe
    80006f74:	28a080e7          	jalr	650(ra) # 800051fa <ilock>
  ip->nlink--;
    80006f78:	04a4d783          	lhu	a5,74(s1)
    80006f7c:	37fd                	addiw	a5,a5,-1
    80006f7e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006f82:	8526                	mv	a0,s1
    80006f84:	ffffe097          	auipc	ra,0xffffe
    80006f88:	1aa080e7          	jalr	426(ra) # 8000512e <iupdate>
  iunlockput(ip);
    80006f8c:	8526                	mv	a0,s1
    80006f8e:	ffffe097          	auipc	ra,0xffffe
    80006f92:	4ce080e7          	jalr	1230(ra) # 8000545c <iunlockput>
  end_op();
    80006f96:	fffff097          	auipc	ra,0xfffff
    80006f9a:	cbe080e7          	jalr	-834(ra) # 80005c54 <end_op>
  return -1;
    80006f9e:	57fd                	li	a5,-1
}
    80006fa0:	853e                	mv	a0,a5
    80006fa2:	70b2                	ld	ra,296(sp)
    80006fa4:	7412                	ld	s0,288(sp)
    80006fa6:	64f2                	ld	s1,280(sp)
    80006fa8:	6952                	ld	s2,272(sp)
    80006faa:	6155                	addi	sp,sp,304
    80006fac:	8082                	ret

0000000080006fae <sys_unlink>:
{
    80006fae:	7151                	addi	sp,sp,-240
    80006fb0:	f586                	sd	ra,232(sp)
    80006fb2:	f1a2                	sd	s0,224(sp)
    80006fb4:	eda6                	sd	s1,216(sp)
    80006fb6:	e9ca                	sd	s2,208(sp)
    80006fb8:	e5ce                	sd	s3,200(sp)
    80006fba:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006fbc:	08000613          	li	a2,128
    80006fc0:	f3040593          	addi	a1,s0,-208
    80006fc4:	4501                	li	a0,0
    80006fc6:	ffffd097          	auipc	ra,0xffffd
    80006fca:	e52080e7          	jalr	-430(ra) # 80003e18 <argstr>
    80006fce:	18054163          	bltz	a0,80007150 <sys_unlink+0x1a2>
  begin_op();
    80006fd2:	fffff097          	auipc	ra,0xfffff
    80006fd6:	c04080e7          	jalr	-1020(ra) # 80005bd6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006fda:	fb040593          	addi	a1,s0,-80
    80006fde:	f3040513          	addi	a0,s0,-208
    80006fe2:	fffff097          	auipc	ra,0xfffff
    80006fe6:	9f2080e7          	jalr	-1550(ra) # 800059d4 <nameiparent>
    80006fea:	84aa                	mv	s1,a0
    80006fec:	c979                	beqz	a0,800070c2 <sys_unlink+0x114>
  ilock(dp);
    80006fee:	ffffe097          	auipc	ra,0xffffe
    80006ff2:	20c080e7          	jalr	524(ra) # 800051fa <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006ff6:	00003597          	auipc	a1,0x3
    80006ffa:	a9258593          	addi	a1,a1,-1390 # 80009a88 <syscalls+0x428>
    80006ffe:	fb040513          	addi	a0,s0,-80
    80007002:	ffffe097          	auipc	ra,0xffffe
    80007006:	6c2080e7          	jalr	1730(ra) # 800056c4 <namecmp>
    8000700a:	14050a63          	beqz	a0,8000715e <sys_unlink+0x1b0>
    8000700e:	00003597          	auipc	a1,0x3
    80007012:	a8258593          	addi	a1,a1,-1406 # 80009a90 <syscalls+0x430>
    80007016:	fb040513          	addi	a0,s0,-80
    8000701a:	ffffe097          	auipc	ra,0xffffe
    8000701e:	6aa080e7          	jalr	1706(ra) # 800056c4 <namecmp>
    80007022:	12050e63          	beqz	a0,8000715e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80007026:	f2c40613          	addi	a2,s0,-212
    8000702a:	fb040593          	addi	a1,s0,-80
    8000702e:	8526                	mv	a0,s1
    80007030:	ffffe097          	auipc	ra,0xffffe
    80007034:	6ae080e7          	jalr	1710(ra) # 800056de <dirlookup>
    80007038:	892a                	mv	s2,a0
    8000703a:	12050263          	beqz	a0,8000715e <sys_unlink+0x1b0>
  ilock(ip);
    8000703e:	ffffe097          	auipc	ra,0xffffe
    80007042:	1bc080e7          	jalr	444(ra) # 800051fa <ilock>
  if(ip->nlink < 1)
    80007046:	04a91783          	lh	a5,74(s2)
    8000704a:	08f05263          	blez	a5,800070ce <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000704e:	04491703          	lh	a4,68(s2)
    80007052:	4785                	li	a5,1
    80007054:	08f70563          	beq	a4,a5,800070de <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80007058:	4641                	li	a2,16
    8000705a:	4581                	li	a1,0
    8000705c:	fc040513          	addi	a0,s0,-64
    80007060:	ffffa097          	auipc	ra,0xffffa
    80007064:	c6c080e7          	jalr	-916(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80007068:	4741                	li	a4,16
    8000706a:	f2c42683          	lw	a3,-212(s0)
    8000706e:	fc040613          	addi	a2,s0,-64
    80007072:	4581                	li	a1,0
    80007074:	8526                	mv	a0,s1
    80007076:	ffffe097          	auipc	ra,0xffffe
    8000707a:	530080e7          	jalr	1328(ra) # 800055a6 <writei>
    8000707e:	47c1                	li	a5,16
    80007080:	0af51563          	bne	a0,a5,8000712a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80007084:	04491703          	lh	a4,68(s2)
    80007088:	4785                	li	a5,1
    8000708a:	0af70863          	beq	a4,a5,8000713a <sys_unlink+0x18c>
  iunlockput(dp);
    8000708e:	8526                	mv	a0,s1
    80007090:	ffffe097          	auipc	ra,0xffffe
    80007094:	3cc080e7          	jalr	972(ra) # 8000545c <iunlockput>
  ip->nlink--;
    80007098:	04a95783          	lhu	a5,74(s2)
    8000709c:	37fd                	addiw	a5,a5,-1
    8000709e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800070a2:	854a                	mv	a0,s2
    800070a4:	ffffe097          	auipc	ra,0xffffe
    800070a8:	08a080e7          	jalr	138(ra) # 8000512e <iupdate>
  iunlockput(ip);
    800070ac:	854a                	mv	a0,s2
    800070ae:	ffffe097          	auipc	ra,0xffffe
    800070b2:	3ae080e7          	jalr	942(ra) # 8000545c <iunlockput>
  end_op();
    800070b6:	fffff097          	auipc	ra,0xfffff
    800070ba:	b9e080e7          	jalr	-1122(ra) # 80005c54 <end_op>
  return 0;
    800070be:	4501                	li	a0,0
    800070c0:	a84d                	j	80007172 <sys_unlink+0x1c4>
    end_op();
    800070c2:	fffff097          	auipc	ra,0xfffff
    800070c6:	b92080e7          	jalr	-1134(ra) # 80005c54 <end_op>
    return -1;
    800070ca:	557d                	li	a0,-1
    800070cc:	a05d                	j	80007172 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800070ce:	00003517          	auipc	a0,0x3
    800070d2:	9ea50513          	addi	a0,a0,-1558 # 80009ab8 <syscalls+0x458>
    800070d6:	ffff9097          	auipc	ra,0xffff9
    800070da:	464080e7          	jalr	1124(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800070de:	04c92703          	lw	a4,76(s2)
    800070e2:	02000793          	li	a5,32
    800070e6:	f6e7f9e3          	bgeu	a5,a4,80007058 <sys_unlink+0xaa>
    800070ea:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800070ee:	4741                	li	a4,16
    800070f0:	86ce                	mv	a3,s3
    800070f2:	f1840613          	addi	a2,s0,-232
    800070f6:	4581                	li	a1,0
    800070f8:	854a                	mv	a0,s2
    800070fa:	ffffe097          	auipc	ra,0xffffe
    800070fe:	3b4080e7          	jalr	948(ra) # 800054ae <readi>
    80007102:	47c1                	li	a5,16
    80007104:	00f51b63          	bne	a0,a5,8000711a <sys_unlink+0x16c>
    if(de.inum != 0)
    80007108:	f1845783          	lhu	a5,-232(s0)
    8000710c:	e7a1                	bnez	a5,80007154 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000710e:	29c1                	addiw	s3,s3,16
    80007110:	04c92783          	lw	a5,76(s2)
    80007114:	fcf9ede3          	bltu	s3,a5,800070ee <sys_unlink+0x140>
    80007118:	b781                	j	80007058 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000711a:	00003517          	auipc	a0,0x3
    8000711e:	9b650513          	addi	a0,a0,-1610 # 80009ad0 <syscalls+0x470>
    80007122:	ffff9097          	auipc	ra,0xffff9
    80007126:	418080e7          	jalr	1048(ra) # 8000053a <panic>
    panic("unlink: writei");
    8000712a:	00003517          	auipc	a0,0x3
    8000712e:	9be50513          	addi	a0,a0,-1602 # 80009ae8 <syscalls+0x488>
    80007132:	ffff9097          	auipc	ra,0xffff9
    80007136:	408080e7          	jalr	1032(ra) # 8000053a <panic>
    dp->nlink--;
    8000713a:	04a4d783          	lhu	a5,74(s1)
    8000713e:	37fd                	addiw	a5,a5,-1
    80007140:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80007144:	8526                	mv	a0,s1
    80007146:	ffffe097          	auipc	ra,0xffffe
    8000714a:	fe8080e7          	jalr	-24(ra) # 8000512e <iupdate>
    8000714e:	b781                	j	8000708e <sys_unlink+0xe0>
    return -1;
    80007150:	557d                	li	a0,-1
    80007152:	a005                	j	80007172 <sys_unlink+0x1c4>
    iunlockput(ip);
    80007154:	854a                	mv	a0,s2
    80007156:	ffffe097          	auipc	ra,0xffffe
    8000715a:	306080e7          	jalr	774(ra) # 8000545c <iunlockput>
  iunlockput(dp);
    8000715e:	8526                	mv	a0,s1
    80007160:	ffffe097          	auipc	ra,0xffffe
    80007164:	2fc080e7          	jalr	764(ra) # 8000545c <iunlockput>
  end_op();
    80007168:	fffff097          	auipc	ra,0xfffff
    8000716c:	aec080e7          	jalr	-1300(ra) # 80005c54 <end_op>
  return -1;
    80007170:	557d                	li	a0,-1
}
    80007172:	70ae                	ld	ra,232(sp)
    80007174:	740e                	ld	s0,224(sp)
    80007176:	64ee                	ld	s1,216(sp)
    80007178:	694e                	ld	s2,208(sp)
    8000717a:	69ae                	ld	s3,200(sp)
    8000717c:	616d                	addi	sp,sp,240
    8000717e:	8082                	ret

0000000080007180 <sys_open>:

uint64
sys_open(void)
{
    80007180:	7131                	addi	sp,sp,-192
    80007182:	fd06                	sd	ra,184(sp)
    80007184:	f922                	sd	s0,176(sp)
    80007186:	f526                	sd	s1,168(sp)
    80007188:	f14a                	sd	s2,160(sp)
    8000718a:	ed4e                	sd	s3,152(sp)
    8000718c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000718e:	08000613          	li	a2,128
    80007192:	f5040593          	addi	a1,s0,-176
    80007196:	4501                	li	a0,0
    80007198:	ffffd097          	auipc	ra,0xffffd
    8000719c:	c80080e7          	jalr	-896(ra) # 80003e18 <argstr>
    return -1;
    800071a0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800071a2:	0c054163          	bltz	a0,80007264 <sys_open+0xe4>
    800071a6:	f4c40593          	addi	a1,s0,-180
    800071aa:	4505                	li	a0,1
    800071ac:	ffffd097          	auipc	ra,0xffffd
    800071b0:	c28080e7          	jalr	-984(ra) # 80003dd4 <argint>
    800071b4:	0a054863          	bltz	a0,80007264 <sys_open+0xe4>

  begin_op();
    800071b8:	fffff097          	auipc	ra,0xfffff
    800071bc:	a1e080e7          	jalr	-1506(ra) # 80005bd6 <begin_op>

  if(omode & O_CREATE){
    800071c0:	f4c42783          	lw	a5,-180(s0)
    800071c4:	2007f793          	andi	a5,a5,512
    800071c8:	cbdd                	beqz	a5,8000727e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800071ca:	4681                	li	a3,0
    800071cc:	4601                	li	a2,0
    800071ce:	4589                	li	a1,2
    800071d0:	f5040513          	addi	a0,s0,-176
    800071d4:	00000097          	auipc	ra,0x0
    800071d8:	970080e7          	jalr	-1680(ra) # 80006b44 <create>
    800071dc:	892a                	mv	s2,a0
    if(ip == 0){
    800071de:	c959                	beqz	a0,80007274 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800071e0:	04491703          	lh	a4,68(s2)
    800071e4:	478d                	li	a5,3
    800071e6:	00f71763          	bne	a4,a5,800071f4 <sys_open+0x74>
    800071ea:	04695703          	lhu	a4,70(s2)
    800071ee:	47a5                	li	a5,9
    800071f0:	0ce7ec63          	bltu	a5,a4,800072c8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800071f4:	fffff097          	auipc	ra,0xfffff
    800071f8:	dee080e7          	jalr	-530(ra) # 80005fe2 <filealloc>
    800071fc:	89aa                	mv	s3,a0
    800071fe:	10050263          	beqz	a0,80007302 <sys_open+0x182>
    80007202:	00000097          	auipc	ra,0x0
    80007206:	900080e7          	jalr	-1792(ra) # 80006b02 <fdalloc>
    8000720a:	84aa                	mv	s1,a0
    8000720c:	0e054663          	bltz	a0,800072f8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80007210:	04491703          	lh	a4,68(s2)
    80007214:	478d                	li	a5,3
    80007216:	0cf70463          	beq	a4,a5,800072de <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000721a:	4789                	li	a5,2
    8000721c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80007220:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80007224:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80007228:	f4c42783          	lw	a5,-180(s0)
    8000722c:	0017c713          	xori	a4,a5,1
    80007230:	8b05                	andi	a4,a4,1
    80007232:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80007236:	0037f713          	andi	a4,a5,3
    8000723a:	00e03733          	snez	a4,a4
    8000723e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80007242:	4007f793          	andi	a5,a5,1024
    80007246:	c791                	beqz	a5,80007252 <sys_open+0xd2>
    80007248:	04491703          	lh	a4,68(s2)
    8000724c:	4789                	li	a5,2
    8000724e:	08f70f63          	beq	a4,a5,800072ec <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80007252:	854a                	mv	a0,s2
    80007254:	ffffe097          	auipc	ra,0xffffe
    80007258:	068080e7          	jalr	104(ra) # 800052bc <iunlock>
  end_op();
    8000725c:	fffff097          	auipc	ra,0xfffff
    80007260:	9f8080e7          	jalr	-1544(ra) # 80005c54 <end_op>

  return fd;
}
    80007264:	8526                	mv	a0,s1
    80007266:	70ea                	ld	ra,184(sp)
    80007268:	744a                	ld	s0,176(sp)
    8000726a:	74aa                	ld	s1,168(sp)
    8000726c:	790a                	ld	s2,160(sp)
    8000726e:	69ea                	ld	s3,152(sp)
    80007270:	6129                	addi	sp,sp,192
    80007272:	8082                	ret
      end_op();
    80007274:	fffff097          	auipc	ra,0xfffff
    80007278:	9e0080e7          	jalr	-1568(ra) # 80005c54 <end_op>
      return -1;
    8000727c:	b7e5                	j	80007264 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000727e:	f5040513          	addi	a0,s0,-176
    80007282:	ffffe097          	auipc	ra,0xffffe
    80007286:	734080e7          	jalr	1844(ra) # 800059b6 <namei>
    8000728a:	892a                	mv	s2,a0
    8000728c:	c905                	beqz	a0,800072bc <sys_open+0x13c>
    ilock(ip);
    8000728e:	ffffe097          	auipc	ra,0xffffe
    80007292:	f6c080e7          	jalr	-148(ra) # 800051fa <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80007296:	04491703          	lh	a4,68(s2)
    8000729a:	4785                	li	a5,1
    8000729c:	f4f712e3          	bne	a4,a5,800071e0 <sys_open+0x60>
    800072a0:	f4c42783          	lw	a5,-180(s0)
    800072a4:	dba1                	beqz	a5,800071f4 <sys_open+0x74>
      iunlockput(ip);
    800072a6:	854a                	mv	a0,s2
    800072a8:	ffffe097          	auipc	ra,0xffffe
    800072ac:	1b4080e7          	jalr	436(ra) # 8000545c <iunlockput>
      end_op();
    800072b0:	fffff097          	auipc	ra,0xfffff
    800072b4:	9a4080e7          	jalr	-1628(ra) # 80005c54 <end_op>
      return -1;
    800072b8:	54fd                	li	s1,-1
    800072ba:	b76d                	j	80007264 <sys_open+0xe4>
      end_op();
    800072bc:	fffff097          	auipc	ra,0xfffff
    800072c0:	998080e7          	jalr	-1640(ra) # 80005c54 <end_op>
      return -1;
    800072c4:	54fd                	li	s1,-1
    800072c6:	bf79                	j	80007264 <sys_open+0xe4>
    iunlockput(ip);
    800072c8:	854a                	mv	a0,s2
    800072ca:	ffffe097          	auipc	ra,0xffffe
    800072ce:	192080e7          	jalr	402(ra) # 8000545c <iunlockput>
    end_op();
    800072d2:	fffff097          	auipc	ra,0xfffff
    800072d6:	982080e7          	jalr	-1662(ra) # 80005c54 <end_op>
    return -1;
    800072da:	54fd                	li	s1,-1
    800072dc:	b761                	j	80007264 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800072de:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800072e2:	04691783          	lh	a5,70(s2)
    800072e6:	02f99223          	sh	a5,36(s3)
    800072ea:	bf2d                	j	80007224 <sys_open+0xa4>
    itrunc(ip);
    800072ec:	854a                	mv	a0,s2
    800072ee:	ffffe097          	auipc	ra,0xffffe
    800072f2:	01a080e7          	jalr	26(ra) # 80005308 <itrunc>
    800072f6:	bfb1                	j	80007252 <sys_open+0xd2>
      fileclose(f);
    800072f8:	854e                	mv	a0,s3
    800072fa:	fffff097          	auipc	ra,0xfffff
    800072fe:	da4080e7          	jalr	-604(ra) # 8000609e <fileclose>
    iunlockput(ip);
    80007302:	854a                	mv	a0,s2
    80007304:	ffffe097          	auipc	ra,0xffffe
    80007308:	158080e7          	jalr	344(ra) # 8000545c <iunlockput>
    end_op();
    8000730c:	fffff097          	auipc	ra,0xfffff
    80007310:	948080e7          	jalr	-1720(ra) # 80005c54 <end_op>
    return -1;
    80007314:	54fd                	li	s1,-1
    80007316:	b7b9                	j	80007264 <sys_open+0xe4>

0000000080007318 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80007318:	7175                	addi	sp,sp,-144
    8000731a:	e506                	sd	ra,136(sp)
    8000731c:	e122                	sd	s0,128(sp)
    8000731e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80007320:	fffff097          	auipc	ra,0xfffff
    80007324:	8b6080e7          	jalr	-1866(ra) # 80005bd6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80007328:	08000613          	li	a2,128
    8000732c:	f7040593          	addi	a1,s0,-144
    80007330:	4501                	li	a0,0
    80007332:	ffffd097          	auipc	ra,0xffffd
    80007336:	ae6080e7          	jalr	-1306(ra) # 80003e18 <argstr>
    8000733a:	02054963          	bltz	a0,8000736c <sys_mkdir+0x54>
    8000733e:	4681                	li	a3,0
    80007340:	4601                	li	a2,0
    80007342:	4585                	li	a1,1
    80007344:	f7040513          	addi	a0,s0,-144
    80007348:	fffff097          	auipc	ra,0xfffff
    8000734c:	7fc080e7          	jalr	2044(ra) # 80006b44 <create>
    80007350:	cd11                	beqz	a0,8000736c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80007352:	ffffe097          	auipc	ra,0xffffe
    80007356:	10a080e7          	jalr	266(ra) # 8000545c <iunlockput>
  end_op();
    8000735a:	fffff097          	auipc	ra,0xfffff
    8000735e:	8fa080e7          	jalr	-1798(ra) # 80005c54 <end_op>
  return 0;
    80007362:	4501                	li	a0,0
}
    80007364:	60aa                	ld	ra,136(sp)
    80007366:	640a                	ld	s0,128(sp)
    80007368:	6149                	addi	sp,sp,144
    8000736a:	8082                	ret
    end_op();
    8000736c:	fffff097          	auipc	ra,0xfffff
    80007370:	8e8080e7          	jalr	-1816(ra) # 80005c54 <end_op>
    return -1;
    80007374:	557d                	li	a0,-1
    80007376:	b7fd                	j	80007364 <sys_mkdir+0x4c>

0000000080007378 <sys_mknod>:

uint64
sys_mknod(void)
{
    80007378:	7135                	addi	sp,sp,-160
    8000737a:	ed06                	sd	ra,152(sp)
    8000737c:	e922                	sd	s0,144(sp)
    8000737e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80007380:	fffff097          	auipc	ra,0xfffff
    80007384:	856080e7          	jalr	-1962(ra) # 80005bd6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80007388:	08000613          	li	a2,128
    8000738c:	f7040593          	addi	a1,s0,-144
    80007390:	4501                	li	a0,0
    80007392:	ffffd097          	auipc	ra,0xffffd
    80007396:	a86080e7          	jalr	-1402(ra) # 80003e18 <argstr>
    8000739a:	04054a63          	bltz	a0,800073ee <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000739e:	f6c40593          	addi	a1,s0,-148
    800073a2:	4505                	li	a0,1
    800073a4:	ffffd097          	auipc	ra,0xffffd
    800073a8:	a30080e7          	jalr	-1488(ra) # 80003dd4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800073ac:	04054163          	bltz	a0,800073ee <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800073b0:	f6840593          	addi	a1,s0,-152
    800073b4:	4509                	li	a0,2
    800073b6:	ffffd097          	auipc	ra,0xffffd
    800073ba:	a1e080e7          	jalr	-1506(ra) # 80003dd4 <argint>
     argint(1, &major) < 0 ||
    800073be:	02054863          	bltz	a0,800073ee <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800073c2:	f6841683          	lh	a3,-152(s0)
    800073c6:	f6c41603          	lh	a2,-148(s0)
    800073ca:	458d                	li	a1,3
    800073cc:	f7040513          	addi	a0,s0,-144
    800073d0:	fffff097          	auipc	ra,0xfffff
    800073d4:	774080e7          	jalr	1908(ra) # 80006b44 <create>
     argint(2, &minor) < 0 ||
    800073d8:	c919                	beqz	a0,800073ee <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800073da:	ffffe097          	auipc	ra,0xffffe
    800073de:	082080e7          	jalr	130(ra) # 8000545c <iunlockput>
  end_op();
    800073e2:	fffff097          	auipc	ra,0xfffff
    800073e6:	872080e7          	jalr	-1934(ra) # 80005c54 <end_op>
  return 0;
    800073ea:	4501                	li	a0,0
    800073ec:	a031                	j	800073f8 <sys_mknod+0x80>
    end_op();
    800073ee:	fffff097          	auipc	ra,0xfffff
    800073f2:	866080e7          	jalr	-1946(ra) # 80005c54 <end_op>
    return -1;
    800073f6:	557d                	li	a0,-1
}
    800073f8:	60ea                	ld	ra,152(sp)
    800073fa:	644a                	ld	s0,144(sp)
    800073fc:	610d                	addi	sp,sp,160
    800073fe:	8082                	ret

0000000080007400 <sys_chdir>:

uint64
sys_chdir(void)
{
    80007400:	7135                	addi	sp,sp,-160
    80007402:	ed06                	sd	ra,152(sp)
    80007404:	e922                	sd	s0,144(sp)
    80007406:	e526                	sd	s1,136(sp)
    80007408:	e14a                	sd	s2,128(sp)
    8000740a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000740c:	ffffa097          	auipc	ra,0xffffa
    80007410:	5f2080e7          	jalr	1522(ra) # 800019fe <myproc>
    80007414:	892a                	mv	s2,a0
  
  begin_op();
    80007416:	ffffe097          	auipc	ra,0xffffe
    8000741a:	7c0080e7          	jalr	1984(ra) # 80005bd6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000741e:	08000613          	li	a2,128
    80007422:	f6040593          	addi	a1,s0,-160
    80007426:	4501                	li	a0,0
    80007428:	ffffd097          	auipc	ra,0xffffd
    8000742c:	9f0080e7          	jalr	-1552(ra) # 80003e18 <argstr>
    80007430:	04054b63          	bltz	a0,80007486 <sys_chdir+0x86>
    80007434:	f6040513          	addi	a0,s0,-160
    80007438:	ffffe097          	auipc	ra,0xffffe
    8000743c:	57e080e7          	jalr	1406(ra) # 800059b6 <namei>
    80007440:	84aa                	mv	s1,a0
    80007442:	c131                	beqz	a0,80007486 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80007444:	ffffe097          	auipc	ra,0xffffe
    80007448:	db6080e7          	jalr	-586(ra) # 800051fa <ilock>
  if(ip->type != T_DIR){
    8000744c:	04449703          	lh	a4,68(s1)
    80007450:	4785                	li	a5,1
    80007452:	04f71063          	bne	a4,a5,80007492 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80007456:	8526                	mv	a0,s1
    80007458:	ffffe097          	auipc	ra,0xffffe
    8000745c:	e64080e7          	jalr	-412(ra) # 800052bc <iunlock>
  iput(p->cwd);
    80007460:	15893503          	ld	a0,344(s2)
    80007464:	ffffe097          	auipc	ra,0xffffe
    80007468:	f50080e7          	jalr	-176(ra) # 800053b4 <iput>
  end_op();
    8000746c:	ffffe097          	auipc	ra,0xffffe
    80007470:	7e8080e7          	jalr	2024(ra) # 80005c54 <end_op>
  p->cwd = ip;
    80007474:	14993c23          	sd	s1,344(s2)
  return 0;
    80007478:	4501                	li	a0,0
}
    8000747a:	60ea                	ld	ra,152(sp)
    8000747c:	644a                	ld	s0,144(sp)
    8000747e:	64aa                	ld	s1,136(sp)
    80007480:	690a                	ld	s2,128(sp)
    80007482:	610d                	addi	sp,sp,160
    80007484:	8082                	ret
    end_op();
    80007486:	ffffe097          	auipc	ra,0xffffe
    8000748a:	7ce080e7          	jalr	1998(ra) # 80005c54 <end_op>
    return -1;
    8000748e:	557d                	li	a0,-1
    80007490:	b7ed                	j	8000747a <sys_chdir+0x7a>
    iunlockput(ip);
    80007492:	8526                	mv	a0,s1
    80007494:	ffffe097          	auipc	ra,0xffffe
    80007498:	fc8080e7          	jalr	-56(ra) # 8000545c <iunlockput>
    end_op();
    8000749c:	ffffe097          	auipc	ra,0xffffe
    800074a0:	7b8080e7          	jalr	1976(ra) # 80005c54 <end_op>
    return -1;
    800074a4:	557d                	li	a0,-1
    800074a6:	bfd1                	j	8000747a <sys_chdir+0x7a>

00000000800074a8 <sys_exec>:

uint64
sys_exec(void)
{
    800074a8:	7145                	addi	sp,sp,-464
    800074aa:	e786                	sd	ra,456(sp)
    800074ac:	e3a2                	sd	s0,448(sp)
    800074ae:	ff26                	sd	s1,440(sp)
    800074b0:	fb4a                	sd	s2,432(sp)
    800074b2:	f74e                	sd	s3,424(sp)
    800074b4:	f352                	sd	s4,416(sp)
    800074b6:	ef56                	sd	s5,408(sp)
    800074b8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800074ba:	08000613          	li	a2,128
    800074be:	f4040593          	addi	a1,s0,-192
    800074c2:	4501                	li	a0,0
    800074c4:	ffffd097          	auipc	ra,0xffffd
    800074c8:	954080e7          	jalr	-1708(ra) # 80003e18 <argstr>
    return -1;
    800074cc:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800074ce:	0c054b63          	bltz	a0,800075a4 <sys_exec+0xfc>
    800074d2:	e3840593          	addi	a1,s0,-456
    800074d6:	4505                	li	a0,1
    800074d8:	ffffd097          	auipc	ra,0xffffd
    800074dc:	91e080e7          	jalr	-1762(ra) # 80003df6 <argaddr>
    800074e0:	0c054263          	bltz	a0,800075a4 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800074e4:	10000613          	li	a2,256
    800074e8:	4581                	li	a1,0
    800074ea:	e4040513          	addi	a0,s0,-448
    800074ee:	ffff9097          	auipc	ra,0xffff9
    800074f2:	7de080e7          	jalr	2014(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800074f6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800074fa:	89a6                	mv	s3,s1
    800074fc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800074fe:	02000a13          	li	s4,32
    80007502:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80007506:	00391513          	slli	a0,s2,0x3
    8000750a:	e3040593          	addi	a1,s0,-464
    8000750e:	e3843783          	ld	a5,-456(s0)
    80007512:	953e                	add	a0,a0,a5
    80007514:	ffffd097          	auipc	ra,0xffffd
    80007518:	826080e7          	jalr	-2010(ra) # 80003d3a <fetchaddr>
    8000751c:	02054a63          	bltz	a0,80007550 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80007520:	e3043783          	ld	a5,-464(s0)
    80007524:	c3b9                	beqz	a5,8000756a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80007526:	ffff9097          	auipc	ra,0xffff9
    8000752a:	5ba080e7          	jalr	1466(ra) # 80000ae0 <kalloc>
    8000752e:	85aa                	mv	a1,a0
    80007530:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80007534:	cd11                	beqz	a0,80007550 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80007536:	6605                	lui	a2,0x1
    80007538:	e3043503          	ld	a0,-464(s0)
    8000753c:	ffffd097          	auipc	ra,0xffffd
    80007540:	850080e7          	jalr	-1968(ra) # 80003d8c <fetchstr>
    80007544:	00054663          	bltz	a0,80007550 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80007548:	0905                	addi	s2,s2,1
    8000754a:	09a1                	addi	s3,s3,8
    8000754c:	fb491be3          	bne	s2,s4,80007502 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80007550:	f4040913          	addi	s2,s0,-192
    80007554:	6088                	ld	a0,0(s1)
    80007556:	c531                	beqz	a0,800075a2 <sys_exec+0xfa>
    kfree(argv[i]);
    80007558:	ffff9097          	auipc	ra,0xffff9
    8000755c:	48a080e7          	jalr	1162(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80007560:	04a1                	addi	s1,s1,8
    80007562:	ff2499e3          	bne	s1,s2,80007554 <sys_exec+0xac>
  return -1;
    80007566:	597d                	li	s2,-1
    80007568:	a835                	j	800075a4 <sys_exec+0xfc>
      argv[i] = 0;
    8000756a:	0a8e                	slli	s5,s5,0x3
    8000756c:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd5fc0>
    80007570:	00878ab3          	add	s5,a5,s0
    80007574:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80007578:	e4040593          	addi	a1,s0,-448
    8000757c:	f4040513          	addi	a0,s0,-192
    80007580:	fffff097          	auipc	ra,0xfffff
    80007584:	172080e7          	jalr	370(ra) # 800066f2 <exec>
    80007588:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000758a:	f4040993          	addi	s3,s0,-192
    8000758e:	6088                	ld	a0,0(s1)
    80007590:	c911                	beqz	a0,800075a4 <sys_exec+0xfc>
    kfree(argv[i]);
    80007592:	ffff9097          	auipc	ra,0xffff9
    80007596:	450080e7          	jalr	1104(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000759a:	04a1                	addi	s1,s1,8
    8000759c:	ff3499e3          	bne	s1,s3,8000758e <sys_exec+0xe6>
    800075a0:	a011                	j	800075a4 <sys_exec+0xfc>
  return -1;
    800075a2:	597d                	li	s2,-1
}
    800075a4:	854a                	mv	a0,s2
    800075a6:	60be                	ld	ra,456(sp)
    800075a8:	641e                	ld	s0,448(sp)
    800075aa:	74fa                	ld	s1,440(sp)
    800075ac:	795a                	ld	s2,432(sp)
    800075ae:	79ba                	ld	s3,424(sp)
    800075b0:	7a1a                	ld	s4,416(sp)
    800075b2:	6afa                	ld	s5,408(sp)
    800075b4:	6179                	addi	sp,sp,464
    800075b6:	8082                	ret

00000000800075b8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800075b8:	7139                	addi	sp,sp,-64
    800075ba:	fc06                	sd	ra,56(sp)
    800075bc:	f822                	sd	s0,48(sp)
    800075be:	f426                	sd	s1,40(sp)
    800075c0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800075c2:	ffffa097          	auipc	ra,0xffffa
    800075c6:	43c080e7          	jalr	1084(ra) # 800019fe <myproc>
    800075ca:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800075cc:	fd840593          	addi	a1,s0,-40
    800075d0:	4501                	li	a0,0
    800075d2:	ffffd097          	auipc	ra,0xffffd
    800075d6:	824080e7          	jalr	-2012(ra) # 80003df6 <argaddr>
    return -1;
    800075da:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800075dc:	0e054063          	bltz	a0,800076bc <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800075e0:	fc840593          	addi	a1,s0,-56
    800075e4:	fd040513          	addi	a0,s0,-48
    800075e8:	fffff097          	auipc	ra,0xfffff
    800075ec:	de6080e7          	jalr	-538(ra) # 800063ce <pipealloc>
    return -1;
    800075f0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800075f2:	0c054563          	bltz	a0,800076bc <sys_pipe+0x104>
  fd0 = -1;
    800075f6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800075fa:	fd043503          	ld	a0,-48(s0)
    800075fe:	fffff097          	auipc	ra,0xfffff
    80007602:	504080e7          	jalr	1284(ra) # 80006b02 <fdalloc>
    80007606:	fca42223          	sw	a0,-60(s0)
    8000760a:	08054c63          	bltz	a0,800076a2 <sys_pipe+0xea>
    8000760e:	fc843503          	ld	a0,-56(s0)
    80007612:	fffff097          	auipc	ra,0xfffff
    80007616:	4f0080e7          	jalr	1264(ra) # 80006b02 <fdalloc>
    8000761a:	fca42023          	sw	a0,-64(s0)
    8000761e:	06054963          	bltz	a0,80007690 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80007622:	4691                	li	a3,4
    80007624:	fc440613          	addi	a2,s0,-60
    80007628:	fd843583          	ld	a1,-40(s0)
    8000762c:	6ca8                	ld	a0,88(s1)
    8000762e:	ffffa097          	auipc	ra,0xffffa
    80007632:	07c080e7          	jalr	124(ra) # 800016aa <copyout>
    80007636:	02054063          	bltz	a0,80007656 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000763a:	4691                	li	a3,4
    8000763c:	fc040613          	addi	a2,s0,-64
    80007640:	fd843583          	ld	a1,-40(s0)
    80007644:	0591                	addi	a1,a1,4
    80007646:	6ca8                	ld	a0,88(s1)
    80007648:	ffffa097          	auipc	ra,0xffffa
    8000764c:	062080e7          	jalr	98(ra) # 800016aa <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80007650:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80007652:	06055563          	bgez	a0,800076bc <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80007656:	fc442783          	lw	a5,-60(s0)
    8000765a:	07e9                	addi	a5,a5,26
    8000765c:	078e                	slli	a5,a5,0x3
    8000765e:	97a6                	add	a5,a5,s1
    80007660:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80007664:	fc042783          	lw	a5,-64(s0)
    80007668:	07e9                	addi	a5,a5,26
    8000766a:	078e                	slli	a5,a5,0x3
    8000766c:	00f48533          	add	a0,s1,a5
    80007670:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80007674:	fd043503          	ld	a0,-48(s0)
    80007678:	fffff097          	auipc	ra,0xfffff
    8000767c:	a26080e7          	jalr	-1498(ra) # 8000609e <fileclose>
    fileclose(wf);
    80007680:	fc843503          	ld	a0,-56(s0)
    80007684:	fffff097          	auipc	ra,0xfffff
    80007688:	a1a080e7          	jalr	-1510(ra) # 8000609e <fileclose>
    return -1;
    8000768c:	57fd                	li	a5,-1
    8000768e:	a03d                	j	800076bc <sys_pipe+0x104>
    if(fd0 >= 0)
    80007690:	fc442783          	lw	a5,-60(s0)
    80007694:	0007c763          	bltz	a5,800076a2 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80007698:	07e9                	addi	a5,a5,26
    8000769a:	078e                	slli	a5,a5,0x3
    8000769c:	97a6                	add	a5,a5,s1
    8000769e:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800076a2:	fd043503          	ld	a0,-48(s0)
    800076a6:	fffff097          	auipc	ra,0xfffff
    800076aa:	9f8080e7          	jalr	-1544(ra) # 8000609e <fileclose>
    fileclose(wf);
    800076ae:	fc843503          	ld	a0,-56(s0)
    800076b2:	fffff097          	auipc	ra,0xfffff
    800076b6:	9ec080e7          	jalr	-1556(ra) # 8000609e <fileclose>
    return -1;
    800076ba:	57fd                	li	a5,-1
}
    800076bc:	853e                	mv	a0,a5
    800076be:	70e2                	ld	ra,56(sp)
    800076c0:	7442                	ld	s0,48(sp)
    800076c2:	74a2                	ld	s1,40(sp)
    800076c4:	6121                	addi	sp,sp,64
    800076c6:	8082                	ret
	...

00000000800076d0 <kernelvec>:
    800076d0:	7111                	addi	sp,sp,-256
    800076d2:	e006                	sd	ra,0(sp)
    800076d4:	e40a                	sd	sp,8(sp)
    800076d6:	e80e                	sd	gp,16(sp)
    800076d8:	ec12                	sd	tp,24(sp)
    800076da:	f016                	sd	t0,32(sp)
    800076dc:	f41a                	sd	t1,40(sp)
    800076de:	f81e                	sd	t2,48(sp)
    800076e0:	fc22                	sd	s0,56(sp)
    800076e2:	e0a6                	sd	s1,64(sp)
    800076e4:	e4aa                	sd	a0,72(sp)
    800076e6:	e8ae                	sd	a1,80(sp)
    800076e8:	ecb2                	sd	a2,88(sp)
    800076ea:	f0b6                	sd	a3,96(sp)
    800076ec:	f4ba                	sd	a4,104(sp)
    800076ee:	f8be                	sd	a5,112(sp)
    800076f0:	fcc2                	sd	a6,120(sp)
    800076f2:	e146                	sd	a7,128(sp)
    800076f4:	e54a                	sd	s2,136(sp)
    800076f6:	e94e                	sd	s3,144(sp)
    800076f8:	ed52                	sd	s4,152(sp)
    800076fa:	f156                	sd	s5,160(sp)
    800076fc:	f55a                	sd	s6,168(sp)
    800076fe:	f95e                	sd	s7,176(sp)
    80007700:	fd62                	sd	s8,184(sp)
    80007702:	e1e6                	sd	s9,192(sp)
    80007704:	e5ea                	sd	s10,200(sp)
    80007706:	e9ee                	sd	s11,208(sp)
    80007708:	edf2                	sd	t3,216(sp)
    8000770a:	f1f6                	sd	t4,224(sp)
    8000770c:	f5fa                	sd	t5,232(sp)
    8000770e:	f9fe                	sd	t6,240(sp)
    80007710:	ce8fc0ef          	jal	ra,80003bf8 <kerneltrap>
    80007714:	6082                	ld	ra,0(sp)
    80007716:	6122                	ld	sp,8(sp)
    80007718:	61c2                	ld	gp,16(sp)
    8000771a:	7282                	ld	t0,32(sp)
    8000771c:	7322                	ld	t1,40(sp)
    8000771e:	73c2                	ld	t2,48(sp)
    80007720:	7462                	ld	s0,56(sp)
    80007722:	6486                	ld	s1,64(sp)
    80007724:	6526                	ld	a0,72(sp)
    80007726:	65c6                	ld	a1,80(sp)
    80007728:	6666                	ld	a2,88(sp)
    8000772a:	7686                	ld	a3,96(sp)
    8000772c:	7726                	ld	a4,104(sp)
    8000772e:	77c6                	ld	a5,112(sp)
    80007730:	7866                	ld	a6,120(sp)
    80007732:	688a                	ld	a7,128(sp)
    80007734:	692a                	ld	s2,136(sp)
    80007736:	69ca                	ld	s3,144(sp)
    80007738:	6a6a                	ld	s4,152(sp)
    8000773a:	7a8a                	ld	s5,160(sp)
    8000773c:	7b2a                	ld	s6,168(sp)
    8000773e:	7bca                	ld	s7,176(sp)
    80007740:	7c6a                	ld	s8,184(sp)
    80007742:	6c8e                	ld	s9,192(sp)
    80007744:	6d2e                	ld	s10,200(sp)
    80007746:	6dce                	ld	s11,208(sp)
    80007748:	6e6e                	ld	t3,216(sp)
    8000774a:	7e8e                	ld	t4,224(sp)
    8000774c:	7f2e                	ld	t5,232(sp)
    8000774e:	7fce                	ld	t6,240(sp)
    80007750:	6111                	addi	sp,sp,256
    80007752:	10200073          	sret
    80007756:	00000013          	nop
    8000775a:	00000013          	nop
    8000775e:	0001                	nop

0000000080007760 <timervec>:
    80007760:	34051573          	csrrw	a0,mscratch,a0
    80007764:	e10c                	sd	a1,0(a0)
    80007766:	e510                	sd	a2,8(a0)
    80007768:	e914                	sd	a3,16(a0)
    8000776a:	6d0c                	ld	a1,24(a0)
    8000776c:	7110                	ld	a2,32(a0)
    8000776e:	6194                	ld	a3,0(a1)
    80007770:	96b2                	add	a3,a3,a2
    80007772:	e194                	sd	a3,0(a1)
    80007774:	4589                	li	a1,2
    80007776:	14459073          	csrw	sip,a1
    8000777a:	6914                	ld	a3,16(a0)
    8000777c:	6510                	ld	a2,8(a0)
    8000777e:	610c                	ld	a1,0(a0)
    80007780:	34051573          	csrrw	a0,mscratch,a0
    80007784:	30200073          	mret
	...

000000008000778a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000778a:	1141                	addi	sp,sp,-16
    8000778c:	e422                	sd	s0,8(sp)
    8000778e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80007790:	0c0007b7          	lui	a5,0xc000
    80007794:	4705                	li	a4,1
    80007796:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80007798:	c3d8                	sw	a4,4(a5)
}
    8000779a:	6422                	ld	s0,8(sp)
    8000779c:	0141                	addi	sp,sp,16
    8000779e:	8082                	ret

00000000800077a0 <plicinithart>:

void
plicinithart(void)
{
    800077a0:	1141                	addi	sp,sp,-16
    800077a2:	e406                	sd	ra,8(sp)
    800077a4:	e022                	sd	s0,0(sp)
    800077a6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800077a8:	ffffa097          	auipc	ra,0xffffa
    800077ac:	22a080e7          	jalr	554(ra) # 800019d2 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800077b0:	0085171b          	slliw	a4,a0,0x8
    800077b4:	0c0027b7          	lui	a5,0xc002
    800077b8:	97ba                	add	a5,a5,a4
    800077ba:	40200713          	li	a4,1026
    800077be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800077c2:	00d5151b          	slliw	a0,a0,0xd
    800077c6:	0c2017b7          	lui	a5,0xc201
    800077ca:	97aa                	add	a5,a5,a0
    800077cc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800077d0:	60a2                	ld	ra,8(sp)
    800077d2:	6402                	ld	s0,0(sp)
    800077d4:	0141                	addi	sp,sp,16
    800077d6:	8082                	ret

00000000800077d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800077d8:	1141                	addi	sp,sp,-16
    800077da:	e406                	sd	ra,8(sp)
    800077dc:	e022                	sd	s0,0(sp)
    800077de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800077e0:	ffffa097          	auipc	ra,0xffffa
    800077e4:	1f2080e7          	jalr	498(ra) # 800019d2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800077e8:	00d5151b          	slliw	a0,a0,0xd
    800077ec:	0c2017b7          	lui	a5,0xc201
    800077f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800077f2:	43c8                	lw	a0,4(a5)
    800077f4:	60a2                	ld	ra,8(sp)
    800077f6:	6402                	ld	s0,0(sp)
    800077f8:	0141                	addi	sp,sp,16
    800077fa:	8082                	ret

00000000800077fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800077fc:	1101                	addi	sp,sp,-32
    800077fe:	ec06                	sd	ra,24(sp)
    80007800:	e822                	sd	s0,16(sp)
    80007802:	e426                	sd	s1,8(sp)
    80007804:	1000                	addi	s0,sp,32
    80007806:	84aa                	mv	s1,a0
  int hart = cpuid();
    80007808:	ffffa097          	auipc	ra,0xffffa
    8000780c:	1ca080e7          	jalr	458(ra) # 800019d2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80007810:	00d5151b          	slliw	a0,a0,0xd
    80007814:	0c2017b7          	lui	a5,0xc201
    80007818:	97aa                	add	a5,a5,a0
    8000781a:	c3c4                	sw	s1,4(a5)
}
    8000781c:	60e2                	ld	ra,24(sp)
    8000781e:	6442                	ld	s0,16(sp)
    80007820:	64a2                	ld	s1,8(sp)
    80007822:	6105                	addi	sp,sp,32
    80007824:	8082                	ret

0000000080007826 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80007826:	1141                	addi	sp,sp,-16
    80007828:	e406                	sd	ra,8(sp)
    8000782a:	e022                	sd	s0,0(sp)
    8000782c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000782e:	479d                	li	a5,7
    80007830:	06a7c863          	blt	a5,a0,800078a0 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80007834:	0001e717          	auipc	a4,0x1e
    80007838:	7cc70713          	addi	a4,a4,1996 # 80026000 <disk>
    8000783c:	972a                	add	a4,a4,a0
    8000783e:	6789                	lui	a5,0x2
    80007840:	97ba                	add	a5,a5,a4
    80007842:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80007846:	e7ad                	bnez	a5,800078b0 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80007848:	00451793          	slli	a5,a0,0x4
    8000784c:	00020717          	auipc	a4,0x20
    80007850:	7b470713          	addi	a4,a4,1972 # 80028000 <disk+0x2000>
    80007854:	6314                	ld	a3,0(a4)
    80007856:	96be                	add	a3,a3,a5
    80007858:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000785c:	6314                	ld	a3,0(a4)
    8000785e:	96be                	add	a3,a3,a5
    80007860:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80007864:	6314                	ld	a3,0(a4)
    80007866:	96be                	add	a3,a3,a5
    80007868:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000786c:	6318                	ld	a4,0(a4)
    8000786e:	97ba                	add	a5,a5,a4
    80007870:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80007874:	0001e717          	auipc	a4,0x1e
    80007878:	78c70713          	addi	a4,a4,1932 # 80026000 <disk>
    8000787c:	972a                	add	a4,a4,a0
    8000787e:	6789                	lui	a5,0x2
    80007880:	97ba                	add	a5,a5,a4
    80007882:	4705                	li	a4,1
    80007884:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80007888:	00020517          	auipc	a0,0x20
    8000788c:	79050513          	addi	a0,a0,1936 # 80028018 <disk+0x2018>
    80007890:	ffffb097          	auipc	ra,0xffffb
    80007894:	4f2080e7          	jalr	1266(ra) # 80002d82 <wakeup>
}
    80007898:	60a2                	ld	ra,8(sp)
    8000789a:	6402                	ld	s0,0(sp)
    8000789c:	0141                	addi	sp,sp,16
    8000789e:	8082                	ret
    panic("free_desc 1");
    800078a0:	00002517          	auipc	a0,0x2
    800078a4:	25850513          	addi	a0,a0,600 # 80009af8 <syscalls+0x498>
    800078a8:	ffff9097          	auipc	ra,0xffff9
    800078ac:	c92080e7          	jalr	-878(ra) # 8000053a <panic>
    panic("free_desc 2");
    800078b0:	00002517          	auipc	a0,0x2
    800078b4:	25850513          	addi	a0,a0,600 # 80009b08 <syscalls+0x4a8>
    800078b8:	ffff9097          	auipc	ra,0xffff9
    800078bc:	c82080e7          	jalr	-894(ra) # 8000053a <panic>

00000000800078c0 <virtio_disk_init>:
{
    800078c0:	1101                	addi	sp,sp,-32
    800078c2:	ec06                	sd	ra,24(sp)
    800078c4:	e822                	sd	s0,16(sp)
    800078c6:	e426                	sd	s1,8(sp)
    800078c8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800078ca:	00002597          	auipc	a1,0x2
    800078ce:	24e58593          	addi	a1,a1,590 # 80009b18 <syscalls+0x4b8>
    800078d2:	00021517          	auipc	a0,0x21
    800078d6:	85650513          	addi	a0,a0,-1962 # 80028128 <disk+0x2128>
    800078da:	ffff9097          	auipc	ra,0xffff9
    800078de:	266080e7          	jalr	614(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800078e2:	100017b7          	lui	a5,0x10001
    800078e6:	4398                	lw	a4,0(a5)
    800078e8:	2701                	sext.w	a4,a4
    800078ea:	747277b7          	lui	a5,0x74727
    800078ee:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800078f2:	0ef71063          	bne	a4,a5,800079d2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800078f6:	100017b7          	lui	a5,0x10001
    800078fa:	43dc                	lw	a5,4(a5)
    800078fc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800078fe:	4705                	li	a4,1
    80007900:	0ce79963          	bne	a5,a4,800079d2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80007904:	100017b7          	lui	a5,0x10001
    80007908:	479c                	lw	a5,8(a5)
    8000790a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000790c:	4709                	li	a4,2
    8000790e:	0ce79263          	bne	a5,a4,800079d2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80007912:	100017b7          	lui	a5,0x10001
    80007916:	47d8                	lw	a4,12(a5)
    80007918:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000791a:	554d47b7          	lui	a5,0x554d4
    8000791e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80007922:	0af71863          	bne	a4,a5,800079d2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80007926:	100017b7          	lui	a5,0x10001
    8000792a:	4705                	li	a4,1
    8000792c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000792e:	470d                	li	a4,3
    80007930:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80007932:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80007934:	c7ffe6b7          	lui	a3,0xc7ffe
    80007938:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd575f>
    8000793c:	8f75                	and	a4,a4,a3
    8000793e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007940:	472d                	li	a4,11
    80007942:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007944:	473d                	li	a4,15
    80007946:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80007948:	6705                	lui	a4,0x1
    8000794a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000794c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007950:	5bdc                	lw	a5,52(a5)
    80007952:	2781                	sext.w	a5,a5
  if(max == 0)
    80007954:	c7d9                	beqz	a5,800079e2 <virtio_disk_init+0x122>
  if(max < NUM)
    80007956:	471d                	li	a4,7
    80007958:	08f77d63          	bgeu	a4,a5,800079f2 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000795c:	100014b7          	lui	s1,0x10001
    80007960:	47a1                	li	a5,8
    80007962:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80007964:	6609                	lui	a2,0x2
    80007966:	4581                	li	a1,0
    80007968:	0001e517          	auipc	a0,0x1e
    8000796c:	69850513          	addi	a0,a0,1688 # 80026000 <disk>
    80007970:	ffff9097          	auipc	ra,0xffff9
    80007974:	35c080e7          	jalr	860(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80007978:	0001e717          	auipc	a4,0x1e
    8000797c:	68870713          	addi	a4,a4,1672 # 80026000 <disk>
    80007980:	00c75793          	srli	a5,a4,0xc
    80007984:	2781                	sext.w	a5,a5
    80007986:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80007988:	00020797          	auipc	a5,0x20
    8000798c:	67878793          	addi	a5,a5,1656 # 80028000 <disk+0x2000>
    80007990:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007992:	0001e717          	auipc	a4,0x1e
    80007996:	6ee70713          	addi	a4,a4,1774 # 80026080 <disk+0x80>
    8000799a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000799c:	0001f717          	auipc	a4,0x1f
    800079a0:	66470713          	addi	a4,a4,1636 # 80027000 <disk+0x1000>
    800079a4:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800079a6:	4705                	li	a4,1
    800079a8:	00e78c23          	sb	a4,24(a5)
    800079ac:	00e78ca3          	sb	a4,25(a5)
    800079b0:	00e78d23          	sb	a4,26(a5)
    800079b4:	00e78da3          	sb	a4,27(a5)
    800079b8:	00e78e23          	sb	a4,28(a5)
    800079bc:	00e78ea3          	sb	a4,29(a5)
    800079c0:	00e78f23          	sb	a4,30(a5)
    800079c4:	00e78fa3          	sb	a4,31(a5)
}
    800079c8:	60e2                	ld	ra,24(sp)
    800079ca:	6442                	ld	s0,16(sp)
    800079cc:	64a2                	ld	s1,8(sp)
    800079ce:	6105                	addi	sp,sp,32
    800079d0:	8082                	ret
    panic("could not find virtio disk");
    800079d2:	00002517          	auipc	a0,0x2
    800079d6:	15650513          	addi	a0,a0,342 # 80009b28 <syscalls+0x4c8>
    800079da:	ffff9097          	auipc	ra,0xffff9
    800079de:	b60080e7          	jalr	-1184(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    800079e2:	00002517          	auipc	a0,0x2
    800079e6:	16650513          	addi	a0,a0,358 # 80009b48 <syscalls+0x4e8>
    800079ea:	ffff9097          	auipc	ra,0xffff9
    800079ee:	b50080e7          	jalr	-1200(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    800079f2:	00002517          	auipc	a0,0x2
    800079f6:	17650513          	addi	a0,a0,374 # 80009b68 <syscalls+0x508>
    800079fa:	ffff9097          	auipc	ra,0xffff9
    800079fe:	b40080e7          	jalr	-1216(ra) # 8000053a <panic>

0000000080007a02 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80007a02:	7119                	addi	sp,sp,-128
    80007a04:	fc86                	sd	ra,120(sp)
    80007a06:	f8a2                	sd	s0,112(sp)
    80007a08:	f4a6                	sd	s1,104(sp)
    80007a0a:	f0ca                	sd	s2,96(sp)
    80007a0c:	ecce                	sd	s3,88(sp)
    80007a0e:	e8d2                	sd	s4,80(sp)
    80007a10:	e4d6                	sd	s5,72(sp)
    80007a12:	e0da                	sd	s6,64(sp)
    80007a14:	fc5e                	sd	s7,56(sp)
    80007a16:	f862                	sd	s8,48(sp)
    80007a18:	f466                	sd	s9,40(sp)
    80007a1a:	f06a                	sd	s10,32(sp)
    80007a1c:	ec6e                	sd	s11,24(sp)
    80007a1e:	0100                	addi	s0,sp,128
    80007a20:	8aaa                	mv	s5,a0
    80007a22:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80007a24:	00c52c83          	lw	s9,12(a0)
    80007a28:	001c9c9b          	slliw	s9,s9,0x1
    80007a2c:	1c82                	slli	s9,s9,0x20
    80007a2e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80007a32:	00020517          	auipc	a0,0x20
    80007a36:	6f650513          	addi	a0,a0,1782 # 80028128 <disk+0x2128>
    80007a3a:	ffff9097          	auipc	ra,0xffff9
    80007a3e:	196080e7          	jalr	406(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80007a42:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007a44:	44a1                	li	s1,8
      disk.free[i] = 0;
    80007a46:	0001ec17          	auipc	s8,0x1e
    80007a4a:	5bac0c13          	addi	s8,s8,1466 # 80026000 <disk>
    80007a4e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007a50:	4b0d                	li	s6,3
    80007a52:	a0ad                	j	80007abc <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007a54:	00fc0733          	add	a4,s8,a5
    80007a58:	975e                	add	a4,a4,s7
    80007a5a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80007a5e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007a60:	0207c563          	bltz	a5,80007a8a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007a64:	2905                	addiw	s2,s2,1
    80007a66:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80007a68:	19690c63          	beq	s2,s6,80007c00 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80007a6c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007a6e:	00020717          	auipc	a4,0x20
    80007a72:	5aa70713          	addi	a4,a4,1450 # 80028018 <disk+0x2018>
    80007a76:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80007a78:	00074683          	lbu	a3,0(a4)
    80007a7c:	fee1                	bnez	a3,80007a54 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007a7e:	2785                	addiw	a5,a5,1
    80007a80:	0705                	addi	a4,a4,1
    80007a82:	fe979be3          	bne	a5,s1,80007a78 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80007a86:	57fd                	li	a5,-1
    80007a88:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80007a8a:	01205d63          	blez	s2,80007aa4 <virtio_disk_rw+0xa2>
    80007a8e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007a90:	000a2503          	lw	a0,0(s4)
    80007a94:	00000097          	auipc	ra,0x0
    80007a98:	d92080e7          	jalr	-622(ra) # 80007826 <free_desc>
      for(int j = 0; j < i; j++)
    80007a9c:	2d85                	addiw	s11,s11,1
    80007a9e:	0a11                	addi	s4,s4,4
    80007aa0:	ff2d98e3          	bne	s11,s2,80007a90 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007aa4:	00020597          	auipc	a1,0x20
    80007aa8:	68458593          	addi	a1,a1,1668 # 80028128 <disk+0x2128>
    80007aac:	00020517          	auipc	a0,0x20
    80007ab0:	56c50513          	addi	a0,a0,1388 # 80028018 <disk+0x2018>
    80007ab4:	ffffb097          	auipc	ra,0xffffb
    80007ab8:	cfc080e7          	jalr	-772(ra) # 800027b0 <sleep>
  for(int i = 0; i < 3; i++){
    80007abc:	f8040a13          	addi	s4,s0,-128
{
    80007ac0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007ac2:	894e                	mv	s2,s3
    80007ac4:	b765                	j	80007a6c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80007ac6:	00020697          	auipc	a3,0x20
    80007aca:	53a6b683          	ld	a3,1338(a3) # 80028000 <disk+0x2000>
    80007ace:	96ba                	add	a3,a3,a4
    80007ad0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007ad4:	0001e817          	auipc	a6,0x1e
    80007ad8:	52c80813          	addi	a6,a6,1324 # 80026000 <disk>
    80007adc:	00020697          	auipc	a3,0x20
    80007ae0:	52468693          	addi	a3,a3,1316 # 80028000 <disk+0x2000>
    80007ae4:	6290                	ld	a2,0(a3)
    80007ae6:	963a                	add	a2,a2,a4
    80007ae8:	00c65583          	lhu	a1,12(a2)
    80007aec:	0015e593          	ori	a1,a1,1
    80007af0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007af4:	f8842603          	lw	a2,-120(s0)
    80007af8:	628c                	ld	a1,0(a3)
    80007afa:	972e                	add	a4,a4,a1
    80007afc:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007b00:	20050593          	addi	a1,a0,512
    80007b04:	0592                	slli	a1,a1,0x4
    80007b06:	95c2                	add	a1,a1,a6
    80007b08:	577d                	li	a4,-1
    80007b0a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80007b0e:	00461713          	slli	a4,a2,0x4
    80007b12:	6290                	ld	a2,0(a3)
    80007b14:	963a                	add	a2,a2,a4
    80007b16:	03078793          	addi	a5,a5,48
    80007b1a:	97c2                	add	a5,a5,a6
    80007b1c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80007b1e:	629c                	ld	a5,0(a3)
    80007b20:	97ba                	add	a5,a5,a4
    80007b22:	4605                	li	a2,1
    80007b24:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80007b26:	629c                	ld	a5,0(a3)
    80007b28:	97ba                	add	a5,a5,a4
    80007b2a:	4809                	li	a6,2
    80007b2c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007b30:	629c                	ld	a5,0(a3)
    80007b32:	97ba                	add	a5,a5,a4
    80007b34:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80007b38:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007b3c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007b40:	6698                	ld	a4,8(a3)
    80007b42:	00275783          	lhu	a5,2(a4)
    80007b46:	8b9d                	andi	a5,a5,7
    80007b48:	0786                	slli	a5,a5,0x1
    80007b4a:	973e                	add	a4,a4,a5
    80007b4c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80007b50:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007b54:	6698                	ld	a4,8(a3)
    80007b56:	00275783          	lhu	a5,2(a4)
    80007b5a:	2785                	addiw	a5,a5,1
    80007b5c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007b60:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007b64:	100017b7          	lui	a5,0x10001
    80007b68:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007b6c:	004aa783          	lw	a5,4(s5)
    80007b70:	02c79163          	bne	a5,a2,80007b92 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007b74:	00020917          	auipc	s2,0x20
    80007b78:	5b490913          	addi	s2,s2,1460 # 80028128 <disk+0x2128>
  while(b->disk == 1) {
    80007b7c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007b7e:	85ca                	mv	a1,s2
    80007b80:	8556                	mv	a0,s5
    80007b82:	ffffb097          	auipc	ra,0xffffb
    80007b86:	c2e080e7          	jalr	-978(ra) # 800027b0 <sleep>
  while(b->disk == 1) {
    80007b8a:	004aa783          	lw	a5,4(s5)
    80007b8e:	fe9788e3          	beq	a5,s1,80007b7e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007b92:	f8042903          	lw	s2,-128(s0)
    80007b96:	20090713          	addi	a4,s2,512
    80007b9a:	0712                	slli	a4,a4,0x4
    80007b9c:	0001e797          	auipc	a5,0x1e
    80007ba0:	46478793          	addi	a5,a5,1124 # 80026000 <disk>
    80007ba4:	97ba                	add	a5,a5,a4
    80007ba6:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007baa:	00020997          	auipc	s3,0x20
    80007bae:	45698993          	addi	s3,s3,1110 # 80028000 <disk+0x2000>
    80007bb2:	00491713          	slli	a4,s2,0x4
    80007bb6:	0009b783          	ld	a5,0(s3)
    80007bba:	97ba                	add	a5,a5,a4
    80007bbc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007bc0:	854a                	mv	a0,s2
    80007bc2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80007bc6:	00000097          	auipc	ra,0x0
    80007bca:	c60080e7          	jalr	-928(ra) # 80007826 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007bce:	8885                	andi	s1,s1,1
    80007bd0:	f0ed                	bnez	s1,80007bb2 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007bd2:	00020517          	auipc	a0,0x20
    80007bd6:	55650513          	addi	a0,a0,1366 # 80028128 <disk+0x2128>
    80007bda:	ffff9097          	auipc	ra,0xffff9
    80007bde:	0aa080e7          	jalr	170(ra) # 80000c84 <release>
}
    80007be2:	70e6                	ld	ra,120(sp)
    80007be4:	7446                	ld	s0,112(sp)
    80007be6:	74a6                	ld	s1,104(sp)
    80007be8:	7906                	ld	s2,96(sp)
    80007bea:	69e6                	ld	s3,88(sp)
    80007bec:	6a46                	ld	s4,80(sp)
    80007bee:	6aa6                	ld	s5,72(sp)
    80007bf0:	6b06                	ld	s6,64(sp)
    80007bf2:	7be2                	ld	s7,56(sp)
    80007bf4:	7c42                	ld	s8,48(sp)
    80007bf6:	7ca2                	ld	s9,40(sp)
    80007bf8:	7d02                	ld	s10,32(sp)
    80007bfa:	6de2                	ld	s11,24(sp)
    80007bfc:	6109                	addi	sp,sp,128
    80007bfe:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007c00:	f8042503          	lw	a0,-128(s0)
    80007c04:	20050793          	addi	a5,a0,512
    80007c08:	0792                	slli	a5,a5,0x4
  if(write)
    80007c0a:	0001e817          	auipc	a6,0x1e
    80007c0e:	3f680813          	addi	a6,a6,1014 # 80026000 <disk>
    80007c12:	00f80733          	add	a4,a6,a5
    80007c16:	01a036b3          	snez	a3,s10
    80007c1a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007c1e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007c22:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007c26:	7679                	lui	a2,0xffffe
    80007c28:	963e                	add	a2,a2,a5
    80007c2a:	00020697          	auipc	a3,0x20
    80007c2e:	3d668693          	addi	a3,a3,982 # 80028000 <disk+0x2000>
    80007c32:	6298                	ld	a4,0(a3)
    80007c34:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007c36:	0a878593          	addi	a1,a5,168
    80007c3a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007c3c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007c3e:	6298                	ld	a4,0(a3)
    80007c40:	9732                	add	a4,a4,a2
    80007c42:	45c1                	li	a1,16
    80007c44:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80007c46:	6298                	ld	a4,0(a3)
    80007c48:	9732                	add	a4,a4,a2
    80007c4a:	4585                	li	a1,1
    80007c4c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007c50:	f8442703          	lw	a4,-124(s0)
    80007c54:	628c                	ld	a1,0(a3)
    80007c56:	962e                	add	a2,a2,a1
    80007c58:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd500e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007c5c:	0712                	slli	a4,a4,0x4
    80007c5e:	6290                	ld	a2,0(a3)
    80007c60:	963a                	add	a2,a2,a4
    80007c62:	058a8593          	addi	a1,s5,88
    80007c66:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80007c68:	6294                	ld	a3,0(a3)
    80007c6a:	96ba                	add	a3,a3,a4
    80007c6c:	40000613          	li	a2,1024
    80007c70:	c690                	sw	a2,8(a3)
  if(write)
    80007c72:	e40d1ae3          	bnez	s10,80007ac6 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80007c76:	00020697          	auipc	a3,0x20
    80007c7a:	38a6b683          	ld	a3,906(a3) # 80028000 <disk+0x2000>
    80007c7e:	96ba                	add	a3,a3,a4
    80007c80:	4609                	li	a2,2
    80007c82:	00c69623          	sh	a2,12(a3)
    80007c86:	b5b9                	j	80007ad4 <virtio_disk_rw+0xd2>

0000000080007c88 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80007c88:	1101                	addi	sp,sp,-32
    80007c8a:	ec06                	sd	ra,24(sp)
    80007c8c:	e822                	sd	s0,16(sp)
    80007c8e:	e426                	sd	s1,8(sp)
    80007c90:	e04a                	sd	s2,0(sp)
    80007c92:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80007c94:	00020517          	auipc	a0,0x20
    80007c98:	49450513          	addi	a0,a0,1172 # 80028128 <disk+0x2128>
    80007c9c:	ffff9097          	auipc	ra,0xffff9
    80007ca0:	f34080e7          	jalr	-204(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80007ca4:	10001737          	lui	a4,0x10001
    80007ca8:	533c                	lw	a5,96(a4)
    80007caa:	8b8d                	andi	a5,a5,3
    80007cac:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007cae:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007cb2:	00020797          	auipc	a5,0x20
    80007cb6:	34e78793          	addi	a5,a5,846 # 80028000 <disk+0x2000>
    80007cba:	6b94                	ld	a3,16(a5)
    80007cbc:	0207d703          	lhu	a4,32(a5)
    80007cc0:	0026d783          	lhu	a5,2(a3)
    80007cc4:	06f70163          	beq	a4,a5,80007d26 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007cc8:	0001e917          	auipc	s2,0x1e
    80007ccc:	33890913          	addi	s2,s2,824 # 80026000 <disk>
    80007cd0:	00020497          	auipc	s1,0x20
    80007cd4:	33048493          	addi	s1,s1,816 # 80028000 <disk+0x2000>
    __sync_synchronize();
    80007cd8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007cdc:	6898                	ld	a4,16(s1)
    80007cde:	0204d783          	lhu	a5,32(s1)
    80007ce2:	8b9d                	andi	a5,a5,7
    80007ce4:	078e                	slli	a5,a5,0x3
    80007ce6:	97ba                	add	a5,a5,a4
    80007ce8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007cea:	20078713          	addi	a4,a5,512
    80007cee:	0712                	slli	a4,a4,0x4
    80007cf0:	974a                	add	a4,a4,s2
    80007cf2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80007cf6:	e731                	bnez	a4,80007d42 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80007cf8:	20078793          	addi	a5,a5,512
    80007cfc:	0792                	slli	a5,a5,0x4
    80007cfe:	97ca                	add	a5,a5,s2
    80007d00:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007d02:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80007d06:	ffffb097          	auipc	ra,0xffffb
    80007d0a:	07c080e7          	jalr	124(ra) # 80002d82 <wakeup>

    disk.used_idx += 1;
    80007d0e:	0204d783          	lhu	a5,32(s1)
    80007d12:	2785                	addiw	a5,a5,1
    80007d14:	17c2                	slli	a5,a5,0x30
    80007d16:	93c1                	srli	a5,a5,0x30
    80007d18:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007d1c:	6898                	ld	a4,16(s1)
    80007d1e:	00275703          	lhu	a4,2(a4)
    80007d22:	faf71be3          	bne	a4,a5,80007cd8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80007d26:	00020517          	auipc	a0,0x20
    80007d2a:	40250513          	addi	a0,a0,1026 # 80028128 <disk+0x2128>
    80007d2e:	ffff9097          	auipc	ra,0xffff9
    80007d32:	f56080e7          	jalr	-170(ra) # 80000c84 <release>
}
    80007d36:	60e2                	ld	ra,24(sp)
    80007d38:	6442                	ld	s0,16(sp)
    80007d3a:	64a2                	ld	s1,8(sp)
    80007d3c:	6902                	ld	s2,0(sp)
    80007d3e:	6105                	addi	sp,sp,32
    80007d40:	8082                	ret
      panic("virtio_disk_intr status");
    80007d42:	00002517          	auipc	a0,0x2
    80007d46:	e4650513          	addi	a0,a0,-442 # 80009b88 <syscalls+0x528>
    80007d4a:	ffff8097          	auipc	ra,0xffff8
    80007d4e:	7f0080e7          	jalr	2032(ra) # 8000053a <panic>

0000000080007d52 <cond_wait>:
#include "spinlock.h"
#include "condvar.h"
#include "riscv.h"
#include "defs.h"

void cond_wait (struct cond_t *cv, struct sleeplock *lock) {
    80007d52:	1141                	addi	sp,sp,-16
    80007d54:	e406                	sd	ra,8(sp)
    80007d56:	e022                	sd	s0,0(sp)
    80007d58:	0800                	addi	s0,sp,16
    condsleep(cv, lock);
    80007d5a:	ffffb097          	auipc	ra,0xffffb
    80007d5e:	e5a080e7          	jalr	-422(ra) # 80002bb4 <condsleep>
}
    80007d62:	60a2                	ld	ra,8(sp)
    80007d64:	6402                	ld	s0,0(sp)
    80007d66:	0141                	addi	sp,sp,16
    80007d68:	8082                	ret

0000000080007d6a <cond_signal>:
void cond_signal (struct cond_t *cv) {
    80007d6a:	1141                	addi	sp,sp,-16
    80007d6c:	e406                	sd	ra,8(sp)
    80007d6e:	e022                	sd	s0,0(sp)
    80007d70:	0800                	addi	s0,sp,16
    wakeupone(cv);
    80007d72:	ffffb097          	auipc	ra,0xffffb
    80007d76:	566080e7          	jalr	1382(ra) # 800032d8 <wakeupone>
}
    80007d7a:	60a2                	ld	ra,8(sp)
    80007d7c:	6402                	ld	s0,0(sp)
    80007d7e:	0141                	addi	sp,sp,16
    80007d80:	8082                	ret

0000000080007d82 <cond_broadcast>:
void cond_broadcast (struct cond_t *cv) {
    80007d82:	1141                	addi	sp,sp,-16
    80007d84:	e406                	sd	ra,8(sp)
    80007d86:	e022                	sd	s0,0(sp)
    80007d88:	0800                	addi	s0,sp,16
    wakeup(cv);
    80007d8a:	ffffb097          	auipc	ra,0xffffb
    80007d8e:	ff8080e7          	jalr	-8(ra) # 80002d82 <wakeup>
}
    80007d92:	60a2                	ld	ra,8(sp)
    80007d94:	6402                	ld	s0,0(sp)
    80007d96:	0141                	addi	sp,sp,16
    80007d98:	8082                	ret

0000000080007d9a <cond_init>:

void cond_init (struct cond_t *cv) {
    80007d9a:	1141                	addi	sp,sp,-16
    80007d9c:	e406                	sd	ra,8(sp)
    80007d9e:	e022                	sd	s0,0(sp)
    80007da0:	0800                	addi	s0,sp,16
    initsleeplock(&cv->lk, "condition_variable");
    80007da2:	00002597          	auipc	a1,0x2
    80007da6:	dfe58593          	addi	a1,a1,-514 # 80009ba0 <syscalls+0x540>
    80007daa:	ffffe097          	auipc	ra,0xffffe
    80007dae:	0e6080e7          	jalr	230(ra) # 80005e90 <initsleeplock>
    80007db2:	60a2                	ld	ra,8(sp)
    80007db4:	6402                	ld	s0,0(sp)
    80007db6:	0141                	addi	sp,sp,16
    80007db8:	8082                	ret

0000000080007dba <sem_init>:
#include "semaphore.h"
#include "riscv.h"
#include "defs.h"

void sem_init (struct sem_t *z, int value) {
    80007dba:	1101                	addi	sp,sp,-32
    80007dbc:	ec06                	sd	ra,24(sp)
    80007dbe:	e822                	sd	s0,16(sp)
    80007dc0:	e426                	sd	s1,8(sp)
    80007dc2:	1000                	addi	s0,sp,32
    80007dc4:	84aa                	mv	s1,a0
    z->value = value;
    80007dc6:	c10c                	sw	a1,0(a0)
    cond_init(&z->cv);
    80007dc8:	03850513          	addi	a0,a0,56
    80007dcc:	00000097          	auipc	ra,0x0
    80007dd0:	fce080e7          	jalr	-50(ra) # 80007d9a <cond_init>
    initsleeplock(&z->lock, "semaphore_lock");
    80007dd4:	00002597          	auipc	a1,0x2
    80007dd8:	de458593          	addi	a1,a1,-540 # 80009bb8 <syscalls+0x558>
    80007ddc:	00848513          	addi	a0,s1,8
    80007de0:	ffffe097          	auipc	ra,0xffffe
    80007de4:	0b0080e7          	jalr	176(ra) # 80005e90 <initsleeplock>
}
    80007de8:	60e2                	ld	ra,24(sp)
    80007dea:	6442                	ld	s0,16(sp)
    80007dec:	64a2                	ld	s1,8(sp)
    80007dee:	6105                	addi	sp,sp,32
    80007df0:	8082                	ret

0000000080007df2 <sem_wait>:

void sem_wait (struct sem_t *z) {
    80007df2:	7179                	addi	sp,sp,-48
    80007df4:	f406                	sd	ra,40(sp)
    80007df6:	f022                	sd	s0,32(sp)
    80007df8:	ec26                	sd	s1,24(sp)
    80007dfa:	e84a                	sd	s2,16(sp)
    80007dfc:	e44e                	sd	s3,8(sp)
    80007dfe:	1800                	addi	s0,sp,48
    80007e00:	84aa                	mv	s1,a0
acquiresleep (&z->lock);
    80007e02:	00850913          	addi	s2,a0,8
    80007e06:	854a                	mv	a0,s2
    80007e08:	ffffe097          	auipc	ra,0xffffe
    80007e0c:	0c2080e7          	jalr	194(ra) # 80005eca <acquiresleep>
while (z->value <= 0)
    80007e10:	409c                	lw	a5,0(s1)
    80007e12:	00f04d63          	bgtz	a5,80007e2c <sem_wait+0x3a>
    cond_wait (&z->cv, &z->lock);
    80007e16:	03848993          	addi	s3,s1,56
    80007e1a:	85ca                	mv	a1,s2
    80007e1c:	854e                	mv	a0,s3
    80007e1e:	00000097          	auipc	ra,0x0
    80007e22:	f34080e7          	jalr	-204(ra) # 80007d52 <cond_wait>
while (z->value <= 0)
    80007e26:	409c                	lw	a5,0(s1)
    80007e28:	fef059e3          	blez	a5,80007e1a <sem_wait+0x28>
z->value--;
    80007e2c:	37fd                	addiw	a5,a5,-1
    80007e2e:	c09c                	sw	a5,0(s1)
releasesleep (&z->lock);
    80007e30:	854a                	mv	a0,s2
    80007e32:	ffffe097          	auipc	ra,0xffffe
    80007e36:	0ee080e7          	jalr	238(ra) # 80005f20 <releasesleep>
}
    80007e3a:	70a2                	ld	ra,40(sp)
    80007e3c:	7402                	ld	s0,32(sp)
    80007e3e:	64e2                	ld	s1,24(sp)
    80007e40:	6942                	ld	s2,16(sp)
    80007e42:	69a2                	ld	s3,8(sp)
    80007e44:	6145                	addi	sp,sp,48
    80007e46:	8082                	ret

0000000080007e48 <sem_post>:

void sem_post (struct sem_t *z) {
    80007e48:	1101                	addi	sp,sp,-32
    80007e4a:	ec06                	sd	ra,24(sp)
    80007e4c:	e822                	sd	s0,16(sp)
    80007e4e:	e426                	sd	s1,8(sp)
    80007e50:	e04a                	sd	s2,0(sp)
    80007e52:	1000                	addi	s0,sp,32
    80007e54:	84aa                	mv	s1,a0
acquiresleep (&z->lock);
    80007e56:	00850913          	addi	s2,a0,8
    80007e5a:	854a                	mv	a0,s2
    80007e5c:	ffffe097          	auipc	ra,0xffffe
    80007e60:	06e080e7          	jalr	110(ra) # 80005eca <acquiresleep>
z->value++;
    80007e64:	409c                	lw	a5,0(s1)
    80007e66:	2785                	addiw	a5,a5,1
    80007e68:	c09c                	sw	a5,0(s1)
cond_signal (&z->cv);
    80007e6a:	03848513          	addi	a0,s1,56
    80007e6e:	00000097          	auipc	ra,0x0
    80007e72:	efc080e7          	jalr	-260(ra) # 80007d6a <cond_signal>
releasesleep (&z->lock);
    80007e76:	854a                	mv	a0,s2
    80007e78:	ffffe097          	auipc	ra,0xffffe
    80007e7c:	0a8080e7          	jalr	168(ra) # 80005f20 <releasesleep>
}
    80007e80:	60e2                	ld	ra,24(sp)
    80007e82:	6442                	ld	s0,16(sp)
    80007e84:	64a2                	ld	s1,8(sp)
    80007e86:	6902                	ld	s2,0(sp)
    80007e88:	6105                	addi	sp,sp,32
    80007e8a:	8082                	ret
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
