
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
    80000016:	074000ef          	jal	ra,8000008a <start>

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
    8000003c:	6661                	lui	a2,0x18
    8000003e:	6a060613          	addi	a2,a2,1696 # 186a0 <_entry-0x7ffe7960>
    80000042:	9732                	add	a4,a4,a2
    80000044:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000046:	00259693          	slli	a3,a1,0x2
    8000004a:	96ae                	add	a3,a3,a1
    8000004c:	068e                	slli	a3,a3,0x3
    8000004e:	0000a717          	auipc	a4,0xa
    80000052:	03270713          	addi	a4,a4,50 # 8000a080 <timer_scratch>
    80000056:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80000058:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005a:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005c:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000060:	00007797          	auipc	a5,0x7
    80000064:	6f078793          	addi	a5,a5,1776 # 80007750 <timervec>
    80000068:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000070:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000078:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007c:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000080:	30479073          	csrw	mie,a5
}
    80000084:	6422                	ld	s0,8(sp)
    80000086:	0141                	addi	sp,sp,16
    80000088:	8082                	ret

000000008000008a <start>:
{
    8000008a:	1141                	addi	sp,sp,-16
    8000008c:	e406                	sd	ra,8(sp)
    8000008e:	e022                	sd	s0,0(sp)
    80000090:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000092:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000096:	7779                	lui	a4,0xffffe
    80000098:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd57ff>
    8000009c:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009e:	6705                	lui	a4,0x1
    800000a0:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a6:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000aa:	00001797          	auipc	a5,0x1
    800000ae:	dc678793          	addi	a5,a5,-570 # 80000e70 <main>
    800000b2:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b6:	4781                	li	a5,0
    800000b8:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000bc:	67c1                	lui	a5,0x10
    800000be:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c0:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c4:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c8:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000cc:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d0:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d4:	57fd                	li	a5,-1
    800000d6:	83a9                	srli	a5,a5,0xa
    800000d8:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000dc:	47bd                	li	a5,15
    800000de:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e2:	00000097          	auipc	ra,0x0
    800000e6:	f3a080e7          	jalr	-198(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ea:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000ee:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f0:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f2:	30200073          	mret
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret

00000000800000fe <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000fe:	715d                	addi	sp,sp,-80
    80000100:	e486                	sd	ra,72(sp)
    80000102:	e0a2                	sd	s0,64(sp)
    80000104:	fc26                	sd	s1,56(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	f44e                	sd	s3,40(sp)
    8000010a:	f052                	sd	s4,32(sp)
    8000010c:	ec56                	sd	s5,24(sp)
    8000010e:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000110:	04c05763          	blez	a2,8000015e <consolewrite+0x60>
    80000114:	8a2a                	mv	s4,a0
    80000116:	84ae                	mv	s1,a1
    80000118:	89b2                	mv	s3,a2
    8000011a:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011c:	5afd                	li	s5,-1
    8000011e:	4685                	li	a3,1
    80000120:	8626                	mv	a2,s1
    80000122:	85d2                	mv	a1,s4
    80000124:	fbf40513          	addi	a0,s0,-65
    80000128:	00003097          	auipc	ra,0x3
    8000012c:	33e080e7          	jalr	830(ra) # 80003466 <either_copyin>
    80000130:	01550d63          	beq	a0,s5,8000014a <consolewrite+0x4c>
      break;
    uartputc(c);
    80000134:	fbf44503          	lbu	a0,-65(s0)
    80000138:	00000097          	auipc	ra,0x0
    8000013c:	77e080e7          	jalr	1918(ra) # 800008b6 <uartputc>
  for(i = 0; i < n; i++){
    80000140:	2905                	addiw	s2,s2,1
    80000142:	0485                	addi	s1,s1,1
    80000144:	fd299de3          	bne	s3,s2,8000011e <consolewrite+0x20>
    80000148:	894e                	mv	s2,s3
  }

  return i;
}
    8000014a:	854a                	mv	a0,s2
    8000014c:	60a6                	ld	ra,72(sp)
    8000014e:	6406                	ld	s0,64(sp)
    80000150:	74e2                	ld	s1,56(sp)
    80000152:	7942                	ld	s2,48(sp)
    80000154:	79a2                	ld	s3,40(sp)
    80000156:	7a02                	ld	s4,32(sp)
    80000158:	6ae2                	ld	s5,24(sp)
    8000015a:	6161                	addi	sp,sp,80
    8000015c:	8082                	ret
  for(i = 0; i < n; i++){
    8000015e:	4901                	li	s2,0
    80000160:	b7ed                	j	8000014a <consolewrite+0x4c>

0000000080000162 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000162:	7159                	addi	sp,sp,-112
    80000164:	f486                	sd	ra,104(sp)
    80000166:	f0a2                	sd	s0,96(sp)
    80000168:	eca6                	sd	s1,88(sp)
    8000016a:	e8ca                	sd	s2,80(sp)
    8000016c:	e4ce                	sd	s3,72(sp)
    8000016e:	e0d2                	sd	s4,64(sp)
    80000170:	fc56                	sd	s5,56(sp)
    80000172:	f85a                	sd	s6,48(sp)
    80000174:	f45e                	sd	s7,40(sp)
    80000176:	f062                	sd	s8,32(sp)
    80000178:	ec66                	sd	s9,24(sp)
    8000017a:	e86a                	sd	s10,16(sp)
    8000017c:	1880                	addi	s0,sp,112
    8000017e:	8aaa                	mv	s5,a0
    80000180:	8a2e                	mv	s4,a1
    80000182:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000184:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000188:	00012517          	auipc	a0,0x12
    8000018c:	03850513          	addi	a0,a0,56 # 800121c0 <cons>
    80000190:	00001097          	auipc	ra,0x1
    80000194:	a3e080e7          	jalr	-1474(ra) # 80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	02848493          	addi	s1,s1,40 # 800121c0 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	0b890913          	addi	s2,s2,184 # 80012258 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001a8:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001aa:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ac:	4ca9                	li	s9,10
  while(n > 0){
    800001ae:	07305863          	blez	s3,8000021e <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	02f71463          	bne	a4,a5,800001e2 <consoleread+0x80>
      if(myproc()->killed){
    800001be:	00002097          	auipc	ra,0x2
    800001c2:	832080e7          	jalr	-1998(ra) # 800019f0 <myproc>
    800001c6:	551c                	lw	a5,40(a0)
    800001c8:	e7b5                	bnez	a5,80000234 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001ca:	85a6                	mv	a1,s1
    800001cc:	854a                	mv	a0,s2
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	5d4080e7          	jalr	1492(ra) # 800027a2 <sleep>
    while(cons.r == cons.w){
    800001d6:	0984a783          	lw	a5,152(s1)
    800001da:	09c4a703          	lw	a4,156(s1)
    800001de:	fef700e3          	beq	a4,a5,800001be <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e2:	0017871b          	addiw	a4,a5,1
    800001e6:	08e4ac23          	sw	a4,152(s1)
    800001ea:	07f7f713          	andi	a4,a5,127
    800001ee:	9726                	add	a4,a4,s1
    800001f0:	01874703          	lbu	a4,24(a4)
    800001f4:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001f8:	077d0563          	beq	s10,s7,80000262 <consoleread+0x100>
    cbuf = c;
    800001fc:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	f9f40613          	addi	a2,s0,-97
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	00003097          	auipc	ra,0x3
    8000020e:	206080e7          	jalr	518(ra) # 80003410 <either_copyout>
    80000212:	01850663          	beq	a0,s8,8000021e <consoleread+0xbc>
    dst++;
    80000216:	0a05                	addi	s4,s4,1
    --n;
    80000218:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021a:	f99d1ae3          	bne	s10,s9,800001ae <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000021e:	00012517          	auipc	a0,0x12
    80000222:	fa250513          	addi	a0,a0,-94 # 800121c0 <cons>
    80000226:	00001097          	auipc	ra,0x1
    8000022a:	a5c080e7          	jalr	-1444(ra) # 80000c82 <release>

  return target - n;
    8000022e:	413b053b          	subw	a0,s6,s3
    80000232:	a811                	j	80000246 <consoleread+0xe4>
        release(&cons.lock);
    80000234:	00012517          	auipc	a0,0x12
    80000238:	f8c50513          	addi	a0,a0,-116 # 800121c0 <cons>
    8000023c:	00001097          	auipc	ra,0x1
    80000240:	a46080e7          	jalr	-1466(ra) # 80000c82 <release>
        return -1;
    80000244:	557d                	li	a0,-1
}
    80000246:	70a6                	ld	ra,104(sp)
    80000248:	7406                	ld	s0,96(sp)
    8000024a:	64e6                	ld	s1,88(sp)
    8000024c:	6946                	ld	s2,80(sp)
    8000024e:	69a6                	ld	s3,72(sp)
    80000250:	6a06                	ld	s4,64(sp)
    80000252:	7ae2                	ld	s5,56(sp)
    80000254:	7b42                	ld	s6,48(sp)
    80000256:	7ba2                	ld	s7,40(sp)
    80000258:	7c02                	ld	s8,32(sp)
    8000025a:	6ce2                	ld	s9,24(sp)
    8000025c:	6d42                	ld	s10,16(sp)
    8000025e:	6165                	addi	sp,sp,112
    80000260:	8082                	ret
      if(n < target){
    80000262:	0009871b          	sext.w	a4,s3
    80000266:	fb677ce3          	bgeu	a4,s6,8000021e <consoleread+0xbc>
        cons.r--;
    8000026a:	00012717          	auipc	a4,0x12
    8000026e:	fef72723          	sw	a5,-18(a4) # 80012258 <cons+0x98>
    80000272:	b775                	j	8000021e <consoleread+0xbc>

0000000080000274 <consputc>:
{
    80000274:	1141                	addi	sp,sp,-16
    80000276:	e406                	sd	ra,8(sp)
    80000278:	e022                	sd	s0,0(sp)
    8000027a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027c:	10000793          	li	a5,256
    80000280:	00f50a63          	beq	a0,a5,80000294 <consputc+0x20>
    uartputc_sync(c);
    80000284:	00000097          	auipc	ra,0x0
    80000288:	560080e7          	jalr	1376(ra) # 800007e4 <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	54e080e7          	jalr	1358(ra) # 800007e4 <uartputc_sync>
    8000029e:	02000513          	li	a0,32
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	542080e7          	jalr	1346(ra) # 800007e4 <uartputc_sync>
    800002aa:	4521                	li	a0,8
    800002ac:	00000097          	auipc	ra,0x0
    800002b0:	538080e7          	jalr	1336(ra) # 800007e4 <uartputc_sync>
    800002b4:	bfe1                	j	8000028c <consputc+0x18>

00000000800002b6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b6:	1101                	addi	sp,sp,-32
    800002b8:	ec06                	sd	ra,24(sp)
    800002ba:	e822                	sd	s0,16(sp)
    800002bc:	e426                	sd	s1,8(sp)
    800002be:	e04a                	sd	s2,0(sp)
    800002c0:	1000                	addi	s0,sp,32
    800002c2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c4:	00012517          	auipc	a0,0x12
    800002c8:	efc50513          	addi	a0,a0,-260 # 800121c0 <cons>
    800002cc:	00001097          	auipc	ra,0x1
    800002d0:	902080e7          	jalr	-1790(ra) # 80000bce <acquire>

  switch(c){
    800002d4:	47d5                	li	a5,21
    800002d6:	0af48663          	beq	s1,a5,80000382 <consoleintr+0xcc>
    800002da:	0297ca63          	blt	a5,s1,8000030e <consoleintr+0x58>
    800002de:	47a1                	li	a5,8
    800002e0:	0ef48763          	beq	s1,a5,800003ce <consoleintr+0x118>
    800002e4:	47c1                	li	a5,16
    800002e6:	10f49a63          	bne	s1,a5,800003fa <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ea:	00003097          	auipc	ra,0x3
    800002ee:	1d2080e7          	jalr	466(ra) # 800034bc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f2:	00012517          	auipc	a0,0x12
    800002f6:	ece50513          	addi	a0,a0,-306 # 800121c0 <cons>
    800002fa:	00001097          	auipc	ra,0x1
    800002fe:	988080e7          	jalr	-1656(ra) # 80000c82 <release>
}
    80000302:	60e2                	ld	ra,24(sp)
    80000304:	6442                	ld	s0,16(sp)
    80000306:	64a2                	ld	s1,8(sp)
    80000308:	6902                	ld	s2,0(sp)
    8000030a:	6105                	addi	sp,sp,32
    8000030c:	8082                	ret
  switch(c){
    8000030e:	07f00793          	li	a5,127
    80000312:	0af48e63          	beq	s1,a5,800003ce <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000316:	00012717          	auipc	a4,0x12
    8000031a:	eaa70713          	addi	a4,a4,-342 # 800121c0 <cons>
    8000031e:	0a072783          	lw	a5,160(a4)
    80000322:	09872703          	lw	a4,152(a4)
    80000326:	9f99                	subw	a5,a5,a4
    80000328:	07f00713          	li	a4,127
    8000032c:	fcf763e3          	bltu	a4,a5,800002f2 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000330:	47b5                	li	a5,13
    80000332:	0cf48763          	beq	s1,a5,80000400 <consoleintr+0x14a>
      consputc(c);
    80000336:	8526                	mv	a0,s1
    80000338:	00000097          	auipc	ra,0x0
    8000033c:	f3c080e7          	jalr	-196(ra) # 80000274 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000340:	00012797          	auipc	a5,0x12
    80000344:	e8078793          	addi	a5,a5,-384 # 800121c0 <cons>
    80000348:	0a07a703          	lw	a4,160(a5)
    8000034c:	0017069b          	addiw	a3,a4,1
    80000350:	0006861b          	sext.w	a2,a3
    80000354:	0ad7a023          	sw	a3,160(a5)
    80000358:	07f77713          	andi	a4,a4,127
    8000035c:	97ba                	add	a5,a5,a4
    8000035e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000362:	47a9                	li	a5,10
    80000364:	0cf48563          	beq	s1,a5,8000042e <consoleintr+0x178>
    80000368:	4791                	li	a5,4
    8000036a:	0cf48263          	beq	s1,a5,8000042e <consoleintr+0x178>
    8000036e:	00012797          	auipc	a5,0x12
    80000372:	eea7a783          	lw	a5,-278(a5) # 80012258 <cons+0x98>
    80000376:	0807879b          	addiw	a5,a5,128
    8000037a:	f6f61ce3          	bne	a2,a5,800002f2 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000037e:	863e                	mv	a2,a5
    80000380:	a07d                	j	8000042e <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000382:	00012717          	auipc	a4,0x12
    80000386:	e3e70713          	addi	a4,a4,-450 # 800121c0 <cons>
    8000038a:	0a072783          	lw	a5,160(a4)
    8000038e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000392:	00012497          	auipc	s1,0x12
    80000396:	e2e48493          	addi	s1,s1,-466 # 800121c0 <cons>
    while(cons.e != cons.w &&
    8000039a:	4929                	li	s2,10
    8000039c:	f4f70be3          	beq	a4,a5,800002f2 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a0:	37fd                	addiw	a5,a5,-1
    800003a2:	07f7f713          	andi	a4,a5,127
    800003a6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003a8:	01874703          	lbu	a4,24(a4)
    800003ac:	f52703e3          	beq	a4,s2,800002f2 <consoleintr+0x3c>
      cons.e--;
    800003b0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b4:	10000513          	li	a0,256
    800003b8:	00000097          	auipc	ra,0x0
    800003bc:	ebc080e7          	jalr	-324(ra) # 80000274 <consputc>
    while(cons.e != cons.w &&
    800003c0:	0a04a783          	lw	a5,160(s1)
    800003c4:	09c4a703          	lw	a4,156(s1)
    800003c8:	fcf71ce3          	bne	a4,a5,800003a0 <consoleintr+0xea>
    800003cc:	b71d                	j	800002f2 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003ce:	00012717          	auipc	a4,0x12
    800003d2:	df270713          	addi	a4,a4,-526 # 800121c0 <cons>
    800003d6:	0a072783          	lw	a5,160(a4)
    800003da:	09c72703          	lw	a4,156(a4)
    800003de:	f0f70ae3          	beq	a4,a5,800002f2 <consoleintr+0x3c>
      cons.e--;
    800003e2:	37fd                	addiw	a5,a5,-1
    800003e4:	00012717          	auipc	a4,0x12
    800003e8:	e6f72e23          	sw	a5,-388(a4) # 80012260 <cons+0xa0>
      consputc(BACKSPACE);
    800003ec:	10000513          	li	a0,256
    800003f0:	00000097          	auipc	ra,0x0
    800003f4:	e84080e7          	jalr	-380(ra) # 80000274 <consputc>
    800003f8:	bded                	j	800002f2 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fa:	ee048ce3          	beqz	s1,800002f2 <consoleintr+0x3c>
    800003fe:	bf21                	j	80000316 <consoleintr+0x60>
      consputc(c);
    80000400:	4529                	li	a0,10
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e72080e7          	jalr	-398(ra) # 80000274 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040a:	00012797          	auipc	a5,0x12
    8000040e:	db678793          	addi	a5,a5,-586 # 800121c0 <cons>
    80000412:	0a07a703          	lw	a4,160(a5)
    80000416:	0017069b          	addiw	a3,a4,1
    8000041a:	0006861b          	sext.w	a2,a3
    8000041e:	0ad7a023          	sw	a3,160(a5)
    80000422:	07f77713          	andi	a4,a4,127
    80000426:	97ba                	add	a5,a5,a4
    80000428:	4729                	li	a4,10
    8000042a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000042e:	00012797          	auipc	a5,0x12
    80000432:	e2c7a723          	sw	a2,-466(a5) # 8001225c <cons+0x9c>
        wakeup(&cons.r);
    80000436:	00012517          	auipc	a0,0x12
    8000043a:	e2250513          	addi	a0,a0,-478 # 80012258 <cons+0x98>
    8000043e:	00003097          	auipc	ra,0x3
    80000442:	916080e7          	jalr	-1770(ra) # 80002d54 <wakeup>
    80000446:	b575                	j	800002f2 <consoleintr+0x3c>

0000000080000448 <consoleinit>:

void
consoleinit(void)
{
    80000448:	1141                	addi	sp,sp,-16
    8000044a:	e406                	sd	ra,8(sp)
    8000044c:	e022                	sd	s0,0(sp)
    8000044e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000450:	00009597          	auipc	a1,0x9
    80000454:	bc058593          	addi	a1,a1,-1088 # 80009010 <etext+0x10>
    80000458:	00012517          	auipc	a0,0x12
    8000045c:	d6850513          	addi	a0,a0,-664 # 800121c0 <cons>
    80000460:	00000097          	auipc	ra,0x0
    80000464:	6de080e7          	jalr	1758(ra) # 80000b3e <initlock>

  uartinit();
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	32c080e7          	jalr	812(ra) # 80000794 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000470:	00024797          	auipc	a5,0x24
    80000474:	b5878793          	addi	a5,a5,-1192 # 80023fc8 <devsw>
    80000478:	00000717          	auipc	a4,0x0
    8000047c:	cea70713          	addi	a4,a4,-790 # 80000162 <consoleread>
    80000480:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000482:	00000717          	auipc	a4,0x0
    80000486:	c7c70713          	addi	a4,a4,-900 # 800000fe <consolewrite>
    8000048a:	ef98                	sd	a4,24(a5)
}
    8000048c:	60a2                	ld	ra,8(sp)
    8000048e:	6402                	ld	s0,0(sp)
    80000490:	0141                	addi	sp,sp,16
    80000492:	8082                	ret

0000000080000494 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000494:	7179                	addi	sp,sp,-48
    80000496:	f406                	sd	ra,40(sp)
    80000498:	f022                	sd	s0,32(sp)
    8000049a:	ec26                	sd	s1,24(sp)
    8000049c:	e84a                	sd	s2,16(sp)
    8000049e:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a0:	c219                	beqz	a2,800004a6 <printint+0x12>
    800004a2:	08054763          	bltz	a0,80000530 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004a6:	2501                	sext.w	a0,a0
    800004a8:	4881                	li	a7,0
    800004aa:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004ae:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b0:	2581                	sext.w	a1,a1
    800004b2:	00009617          	auipc	a2,0x9
    800004b6:	b8e60613          	addi	a2,a2,-1138 # 80009040 <digits>
    800004ba:	883a                	mv	a6,a4
    800004bc:	2705                	addiw	a4,a4,1
    800004be:	02b577bb          	remuw	a5,a0,a1
    800004c2:	1782                	slli	a5,a5,0x20
    800004c4:	9381                	srli	a5,a5,0x20
    800004c6:	97b2                	add	a5,a5,a2
    800004c8:	0007c783          	lbu	a5,0(a5)
    800004cc:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d0:	0005079b          	sext.w	a5,a0
    800004d4:	02b5553b          	divuw	a0,a0,a1
    800004d8:	0685                	addi	a3,a3,1
    800004da:	feb7f0e3          	bgeu	a5,a1,800004ba <printint+0x26>

  if(sign)
    800004de:	00088c63          	beqz	a7,800004f6 <printint+0x62>
    buf[i++] = '-';
    800004e2:	fe070793          	addi	a5,a4,-32
    800004e6:	00878733          	add	a4,a5,s0
    800004ea:	02d00793          	li	a5,45
    800004ee:	fef70823          	sb	a5,-16(a4)
    800004f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f6:	02e05763          	blez	a4,80000524 <printint+0x90>
    800004fa:	fd040793          	addi	a5,s0,-48
    800004fe:	00e784b3          	add	s1,a5,a4
    80000502:	fff78913          	addi	s2,a5,-1
    80000506:	993a                	add	s2,s2,a4
    80000508:	377d                	addiw	a4,a4,-1
    8000050a:	1702                	slli	a4,a4,0x20
    8000050c:	9301                	srli	a4,a4,0x20
    8000050e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000512:	fff4c503          	lbu	a0,-1(s1)
    80000516:	00000097          	auipc	ra,0x0
    8000051a:	d5e080e7          	jalr	-674(ra) # 80000274 <consputc>
  while(--i >= 0)
    8000051e:	14fd                	addi	s1,s1,-1
    80000520:	ff2499e3          	bne	s1,s2,80000512 <printint+0x7e>
}
    80000524:	70a2                	ld	ra,40(sp)
    80000526:	7402                	ld	s0,32(sp)
    80000528:	64e2                	ld	s1,24(sp)
    8000052a:	6942                	ld	s2,16(sp)
    8000052c:	6145                	addi	sp,sp,48
    8000052e:	8082                	ret
    x = -xx;
    80000530:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000534:	4885                	li	a7,1
    x = -xx;
    80000536:	bf95                	j	800004aa <printint+0x16>

0000000080000538 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000538:	1101                	addi	sp,sp,-32
    8000053a:	ec06                	sd	ra,24(sp)
    8000053c:	e822                	sd	s0,16(sp)
    8000053e:	e426                	sd	s1,8(sp)
    80000540:	1000                	addi	s0,sp,32
    80000542:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000544:	00012797          	auipc	a5,0x12
    80000548:	d207ae23          	sw	zero,-708(a5) # 80012280 <pr+0x18>
  printf("panic: ");
    8000054c:	00009517          	auipc	a0,0x9
    80000550:	acc50513          	addi	a0,a0,-1332 # 80009018 <etext+0x18>
    80000554:	00000097          	auipc	ra,0x0
    80000558:	02e080e7          	jalr	46(ra) # 80000582 <printf>
  printf(s);
    8000055c:	8526                	mv	a0,s1
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	024080e7          	jalr	36(ra) # 80000582 <printf>
  printf("\n");
    80000566:	00009517          	auipc	a0,0x9
    8000056a:	24a50513          	addi	a0,a0,586 # 800097b0 <syscalls+0x150>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	014080e7          	jalr	20(ra) # 80000582 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000576:	4785                	li	a5,1
    80000578:	0000a717          	auipc	a4,0xa
    8000057c:	a8f72423          	sw	a5,-1400(a4) # 8000a000 <panicked>
  for(;;)
    80000580:	a001                	j	80000580 <panic+0x48>

0000000080000582 <printf>:
{
    80000582:	7131                	addi	sp,sp,-192
    80000584:	fc86                	sd	ra,120(sp)
    80000586:	f8a2                	sd	s0,112(sp)
    80000588:	f4a6                	sd	s1,104(sp)
    8000058a:	f0ca                	sd	s2,96(sp)
    8000058c:	ecce                	sd	s3,88(sp)
    8000058e:	e8d2                	sd	s4,80(sp)
    80000590:	e4d6                	sd	s5,72(sp)
    80000592:	e0da                	sd	s6,64(sp)
    80000594:	fc5e                	sd	s7,56(sp)
    80000596:	f862                	sd	s8,48(sp)
    80000598:	f466                	sd	s9,40(sp)
    8000059a:	f06a                	sd	s10,32(sp)
    8000059c:	ec6e                	sd	s11,24(sp)
    8000059e:	0100                	addi	s0,sp,128
    800005a0:	8a2a                	mv	s4,a0
    800005a2:	e40c                	sd	a1,8(s0)
    800005a4:	e810                	sd	a2,16(s0)
    800005a6:	ec14                	sd	a3,24(s0)
    800005a8:	f018                	sd	a4,32(s0)
    800005aa:	f41c                	sd	a5,40(s0)
    800005ac:	03043823          	sd	a6,48(s0)
    800005b0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b4:	00012d97          	auipc	s11,0x12
    800005b8:	cccdad83          	lw	s11,-820(s11) # 80012280 <pr+0x18>
  if(locking)
    800005bc:	020d9b63          	bnez	s11,800005f2 <printf+0x70>
  if (fmt == 0)
    800005c0:	040a0263          	beqz	s4,80000604 <printf+0x82>
  va_start(ap, fmt);
    800005c4:	00840793          	addi	a5,s0,8
    800005c8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005cc:	000a4503          	lbu	a0,0(s4)
    800005d0:	14050f63          	beqz	a0,8000072e <printf+0x1ac>
    800005d4:	4981                	li	s3,0
    if(c != '%'){
    800005d6:	02500a93          	li	s5,37
    switch(c){
    800005da:	07000b93          	li	s7,112
  consputc('x');
    800005de:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e0:	00009b17          	auipc	s6,0x9
    800005e4:	a60b0b13          	addi	s6,s6,-1440 # 80009040 <digits>
    switch(c){
    800005e8:	07300c93          	li	s9,115
    800005ec:	06400c13          	li	s8,100
    800005f0:	a82d                	j	8000062a <printf+0xa8>
    acquire(&pr.lock);
    800005f2:	00012517          	auipc	a0,0x12
    800005f6:	c7650513          	addi	a0,a0,-906 # 80012268 <pr>
    800005fa:	00000097          	auipc	ra,0x0
    800005fe:	5d4080e7          	jalr	1492(ra) # 80000bce <acquire>
    80000602:	bf7d                	j	800005c0 <printf+0x3e>
    panic("null fmt");
    80000604:	00009517          	auipc	a0,0x9
    80000608:	a2450513          	addi	a0,a0,-1500 # 80009028 <etext+0x28>
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	f2c080e7          	jalr	-212(ra) # 80000538 <panic>
      consputc(c);
    80000614:	00000097          	auipc	ra,0x0
    80000618:	c60080e7          	jalr	-928(ra) # 80000274 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061c:	2985                	addiw	s3,s3,1
    8000061e:	013a07b3          	add	a5,s4,s3
    80000622:	0007c503          	lbu	a0,0(a5)
    80000626:	10050463          	beqz	a0,8000072e <printf+0x1ac>
    if(c != '%'){
    8000062a:	ff5515e3          	bne	a0,s5,80000614 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000062e:	2985                	addiw	s3,s3,1
    80000630:	013a07b3          	add	a5,s4,s3
    80000634:	0007c783          	lbu	a5,0(a5)
    80000638:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063c:	cbed                	beqz	a5,8000072e <printf+0x1ac>
    switch(c){
    8000063e:	05778a63          	beq	a5,s7,80000692 <printf+0x110>
    80000642:	02fbf663          	bgeu	s7,a5,8000066e <printf+0xec>
    80000646:	09978863          	beq	a5,s9,800006d6 <printf+0x154>
    8000064a:	07800713          	li	a4,120
    8000064e:	0ce79563          	bne	a5,a4,80000718 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4605                	li	a2,1
    80000660:	85ea                	mv	a1,s10
    80000662:	4388                	lw	a0,0(a5)
    80000664:	00000097          	auipc	ra,0x0
    80000668:	e30080e7          	jalr	-464(ra) # 80000494 <printint>
      break;
    8000066c:	bf45                	j	8000061c <printf+0x9a>
    switch(c){
    8000066e:	09578f63          	beq	a5,s5,8000070c <printf+0x18a>
    80000672:	0b879363          	bne	a5,s8,80000718 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000676:	f8843783          	ld	a5,-120(s0)
    8000067a:	00878713          	addi	a4,a5,8
    8000067e:	f8e43423          	sd	a4,-120(s0)
    80000682:	4605                	li	a2,1
    80000684:	45a9                	li	a1,10
    80000686:	4388                	lw	a0,0(a5)
    80000688:	00000097          	auipc	ra,0x0
    8000068c:	e0c080e7          	jalr	-500(ra) # 80000494 <printint>
      break;
    80000690:	b771                	j	8000061c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a2:	03000513          	li	a0,48
    800006a6:	00000097          	auipc	ra,0x0
    800006aa:	bce080e7          	jalr	-1074(ra) # 80000274 <consputc>
  consputc('x');
    800006ae:	07800513          	li	a0,120
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bc2080e7          	jalr	-1086(ra) # 80000274 <consputc>
    800006ba:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006bc:	03c95793          	srli	a5,s2,0x3c
    800006c0:	97da                	add	a5,a5,s6
    800006c2:	0007c503          	lbu	a0,0(a5)
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	bae080e7          	jalr	-1106(ra) # 80000274 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ce:	0912                	slli	s2,s2,0x4
    800006d0:	34fd                	addiw	s1,s1,-1
    800006d2:	f4ed                	bnez	s1,800006bc <printf+0x13a>
    800006d4:	b7a1                	j	8000061c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d6:	f8843783          	ld	a5,-120(s0)
    800006da:	00878713          	addi	a4,a5,8
    800006de:	f8e43423          	sd	a4,-120(s0)
    800006e2:	6384                	ld	s1,0(a5)
    800006e4:	cc89                	beqz	s1,800006fe <printf+0x17c>
      for(; *s; s++)
    800006e6:	0004c503          	lbu	a0,0(s1)
    800006ea:	d90d                	beqz	a0,8000061c <printf+0x9a>
        consputc(*s);
    800006ec:	00000097          	auipc	ra,0x0
    800006f0:	b88080e7          	jalr	-1144(ra) # 80000274 <consputc>
      for(; *s; s++)
    800006f4:	0485                	addi	s1,s1,1
    800006f6:	0004c503          	lbu	a0,0(s1)
    800006fa:	f96d                	bnez	a0,800006ec <printf+0x16a>
    800006fc:	b705                	j	8000061c <printf+0x9a>
        s = "(null)";
    800006fe:	00009497          	auipc	s1,0x9
    80000702:	92248493          	addi	s1,s1,-1758 # 80009020 <etext+0x20>
      for(; *s; s++)
    80000706:	02800513          	li	a0,40
    8000070a:	b7cd                	j	800006ec <printf+0x16a>
      consputc('%');
    8000070c:	8556                	mv	a0,s5
    8000070e:	00000097          	auipc	ra,0x0
    80000712:	b66080e7          	jalr	-1178(ra) # 80000274 <consputc>
      break;
    80000716:	b719                	j	8000061c <printf+0x9a>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b5a080e7          	jalr	-1190(ra) # 80000274 <consputc>
      consputc(c);
    80000722:	8526                	mv	a0,s1
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b50080e7          	jalr	-1200(ra) # 80000274 <consputc>
      break;
    8000072c:	bdc5                	j	8000061c <printf+0x9a>
  if(locking)
    8000072e:	020d9163          	bnez	s11,80000750 <printf+0x1ce>
}
    80000732:	70e6                	ld	ra,120(sp)
    80000734:	7446                	ld	s0,112(sp)
    80000736:	74a6                	ld	s1,104(sp)
    80000738:	7906                	ld	s2,96(sp)
    8000073a:	69e6                	ld	s3,88(sp)
    8000073c:	6a46                	ld	s4,80(sp)
    8000073e:	6aa6                	ld	s5,72(sp)
    80000740:	6b06                	ld	s6,64(sp)
    80000742:	7be2                	ld	s7,56(sp)
    80000744:	7c42                	ld	s8,48(sp)
    80000746:	7ca2                	ld	s9,40(sp)
    80000748:	7d02                	ld	s10,32(sp)
    8000074a:	6de2                	ld	s11,24(sp)
    8000074c:	6129                	addi	sp,sp,192
    8000074e:	8082                	ret
    release(&pr.lock);
    80000750:	00012517          	auipc	a0,0x12
    80000754:	b1850513          	addi	a0,a0,-1256 # 80012268 <pr>
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	52a080e7          	jalr	1322(ra) # 80000c82 <release>
}
    80000760:	bfc9                	j	80000732 <printf+0x1b0>

0000000080000762 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000762:	1101                	addi	sp,sp,-32
    80000764:	ec06                	sd	ra,24(sp)
    80000766:	e822                	sd	s0,16(sp)
    80000768:	e426                	sd	s1,8(sp)
    8000076a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076c:	00012497          	auipc	s1,0x12
    80000770:	afc48493          	addi	s1,s1,-1284 # 80012268 <pr>
    80000774:	00009597          	auipc	a1,0x9
    80000778:	8c458593          	addi	a1,a1,-1852 # 80009038 <etext+0x38>
    8000077c:	8526                	mv	a0,s1
    8000077e:	00000097          	auipc	ra,0x0
    80000782:	3c0080e7          	jalr	960(ra) # 80000b3e <initlock>
  pr.locking = 1;
    80000786:	4785                	li	a5,1
    80000788:	cc9c                	sw	a5,24(s1)
}
    8000078a:	60e2                	ld	ra,24(sp)
    8000078c:	6442                	ld	s0,16(sp)
    8000078e:	64a2                	ld	s1,8(sp)
    80000790:	6105                	addi	sp,sp,32
    80000792:	8082                	ret

0000000080000794 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000794:	1141                	addi	sp,sp,-16
    80000796:	e406                	sd	ra,8(sp)
    80000798:	e022                	sd	s0,0(sp)
    8000079a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079c:	100007b7          	lui	a5,0x10000
    800007a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a4:	f8000713          	li	a4,-128
    800007a8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ac:	470d                	li	a4,3
    800007ae:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b2:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b6:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ba:	469d                	li	a3,7
    800007bc:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c0:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c4:	00009597          	auipc	a1,0x9
    800007c8:	89458593          	addi	a1,a1,-1900 # 80009058 <digits+0x18>
    800007cc:	00012517          	auipc	a0,0x12
    800007d0:	abc50513          	addi	a0,a0,-1348 # 80012288 <uart_tx_lock>
    800007d4:	00000097          	auipc	ra,0x0
    800007d8:	36a080e7          	jalr	874(ra) # 80000b3e <initlock>
}
    800007dc:	60a2                	ld	ra,8(sp)
    800007de:	6402                	ld	s0,0(sp)
    800007e0:	0141                	addi	sp,sp,16
    800007e2:	8082                	ret

00000000800007e4 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e4:	1101                	addi	sp,sp,-32
    800007e6:	ec06                	sd	ra,24(sp)
    800007e8:	e822                	sd	s0,16(sp)
    800007ea:	e426                	sd	s1,8(sp)
    800007ec:	1000                	addi	s0,sp,32
    800007ee:	84aa                	mv	s1,a0
  push_off();
    800007f0:	00000097          	auipc	ra,0x0
    800007f4:	392080e7          	jalr	914(ra) # 80000b82 <push_off>

  if(panicked){
    800007f8:	0000a797          	auipc	a5,0xa
    800007fc:	8087a783          	lw	a5,-2040(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000800:	10000737          	lui	a4,0x10000
  if(panicked){
    80000804:	c391                	beqz	a5,80000808 <uartputc_sync+0x24>
    for(;;)
    80000806:	a001                	j	80000806 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080c:	0207f793          	andi	a5,a5,32
    80000810:	dfe5                	beqz	a5,80000808 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000812:	0ff4f513          	zext.b	a0,s1
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000081e:	00000097          	auipc	ra,0x0
    80000822:	404080e7          	jalr	1028(ra) # 80000c22 <pop_off>
}
    80000826:	60e2                	ld	ra,24(sp)
    80000828:	6442                	ld	s0,16(sp)
    8000082a:	64a2                	ld	s1,8(sp)
    8000082c:	6105                	addi	sp,sp,32
    8000082e:	8082                	ret

0000000080000830 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000830:	00009797          	auipc	a5,0x9
    80000834:	7d87b783          	ld	a5,2008(a5) # 8000a008 <uart_tx_r>
    80000838:	00009717          	auipc	a4,0x9
    8000083c:	7d873703          	ld	a4,2008(a4) # 8000a010 <uart_tx_w>
    80000840:	06f70a63          	beq	a4,a5,800008b4 <uartstart+0x84>
{
    80000844:	7139                	addi	sp,sp,-64
    80000846:	fc06                	sd	ra,56(sp)
    80000848:	f822                	sd	s0,48(sp)
    8000084a:	f426                	sd	s1,40(sp)
    8000084c:	f04a                	sd	s2,32(sp)
    8000084e:	ec4e                	sd	s3,24(sp)
    80000850:	e852                	sd	s4,16(sp)
    80000852:	e456                	sd	s5,8(sp)
    80000854:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000856:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085a:	00012a17          	auipc	s4,0x12
    8000085e:	a2ea0a13          	addi	s4,s4,-1490 # 80012288 <uart_tx_lock>
    uart_tx_r += 1;
    80000862:	00009497          	auipc	s1,0x9
    80000866:	7a648493          	addi	s1,s1,1958 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086a:	00009997          	auipc	s3,0x9
    8000086e:	7a698993          	addi	s3,s3,1958 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000872:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000876:	02077713          	andi	a4,a4,32
    8000087a:	c705                	beqz	a4,800008a2 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087c:	01f7f713          	andi	a4,a5,31
    80000880:	9752                	add	a4,a4,s4
    80000882:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000886:	0785                	addi	a5,a5,1
    80000888:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088a:	8526                	mv	a0,s1
    8000088c:	00002097          	auipc	ra,0x2
    80000890:	4c8080e7          	jalr	1224(ra) # 80002d54 <wakeup>
    
    WriteReg(THR, c);
    80000894:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80000898:	609c                	ld	a5,0(s1)
    8000089a:	0009b703          	ld	a4,0(s3)
    8000089e:	fcf71ae3          	bne	a4,a5,80000872 <uartstart+0x42>
  }
}
    800008a2:	70e2                	ld	ra,56(sp)
    800008a4:	7442                	ld	s0,48(sp)
    800008a6:	74a2                	ld	s1,40(sp)
    800008a8:	7902                	ld	s2,32(sp)
    800008aa:	69e2                	ld	s3,24(sp)
    800008ac:	6a42                	ld	s4,16(sp)
    800008ae:	6aa2                	ld	s5,8(sp)
    800008b0:	6121                	addi	sp,sp,64
    800008b2:	8082                	ret
    800008b4:	8082                	ret

00000000800008b6 <uartputc>:
{
    800008b6:	7179                	addi	sp,sp,-48
    800008b8:	f406                	sd	ra,40(sp)
    800008ba:	f022                	sd	s0,32(sp)
    800008bc:	ec26                	sd	s1,24(sp)
    800008be:	e84a                	sd	s2,16(sp)
    800008c0:	e44e                	sd	s3,8(sp)
    800008c2:	e052                	sd	s4,0(sp)
    800008c4:	1800                	addi	s0,sp,48
    800008c6:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008c8:	00012517          	auipc	a0,0x12
    800008cc:	9c050513          	addi	a0,a0,-1600 # 80012288 <uart_tx_lock>
    800008d0:	00000097          	auipc	ra,0x0
    800008d4:	2fe080e7          	jalr	766(ra) # 80000bce <acquire>
  if(panicked){
    800008d8:	00009797          	auipc	a5,0x9
    800008dc:	7287a783          	lw	a5,1832(a5) # 8000a000 <panicked>
    800008e0:	c391                	beqz	a5,800008e4 <uartputc+0x2e>
    for(;;)
    800008e2:	a001                	j	800008e2 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e4:	00009717          	auipc	a4,0x9
    800008e8:	72c73703          	ld	a4,1836(a4) # 8000a010 <uart_tx_w>
    800008ec:	00009797          	auipc	a5,0x9
    800008f0:	71c7b783          	ld	a5,1820(a5) # 8000a008 <uart_tx_r>
    800008f4:	02078793          	addi	a5,a5,32
    800008f8:	02e79b63          	bne	a5,a4,8000092e <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00012997          	auipc	s3,0x12
    80000900:	98c98993          	addi	s3,s3,-1652 # 80012288 <uart_tx_lock>
    80000904:	00009497          	auipc	s1,0x9
    80000908:	70448493          	addi	s1,s1,1796 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00009917          	auipc	s2,0x9
    80000910:	70490913          	addi	s2,s2,1796 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000914:	85ce                	mv	a1,s3
    80000916:	8526                	mv	a0,s1
    80000918:	00002097          	auipc	ra,0x2
    8000091c:	e8a080e7          	jalr	-374(ra) # 800027a2 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00093703          	ld	a4,0(s2)
    80000924:	609c                	ld	a5,0(s1)
    80000926:	02078793          	addi	a5,a5,32
    8000092a:	fee785e3          	beq	a5,a4,80000914 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000092e:	00012497          	auipc	s1,0x12
    80000932:	95a48493          	addi	s1,s1,-1702 # 80012288 <uart_tx_lock>
    80000936:	01f77793          	andi	a5,a4,31
    8000093a:	97a6                	add	a5,a5,s1
    8000093c:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000940:	0705                	addi	a4,a4,1
    80000942:	00009797          	auipc	a5,0x9
    80000946:	6ce7b723          	sd	a4,1742(a5) # 8000a010 <uart_tx_w>
      uartstart();
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	ee6080e7          	jalr	-282(ra) # 80000830 <uartstart>
      release(&uart_tx_lock);
    80000952:	8526                	mv	a0,s1
    80000954:	00000097          	auipc	ra,0x0
    80000958:	32e080e7          	jalr	814(ra) # 80000c82 <release>
}
    8000095c:	70a2                	ld	ra,40(sp)
    8000095e:	7402                	ld	s0,32(sp)
    80000960:	64e2                	ld	s1,24(sp)
    80000962:	6942                	ld	s2,16(sp)
    80000964:	69a2                	ld	s3,8(sp)
    80000966:	6a02                	ld	s4,0(sp)
    80000968:	6145                	addi	sp,sp,48
    8000096a:	8082                	ret

000000008000096c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096c:	1141                	addi	sp,sp,-16
    8000096e:	e422                	sd	s0,8(sp)
    80000970:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000972:	100007b7          	lui	a5,0x10000
    80000976:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097a:	8b85                	andi	a5,a5,1
    8000097c:	cb81                	beqz	a5,8000098c <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    8000097e:	100007b7          	lui	a5,0x10000
    80000982:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000986:	6422                	ld	s0,8(sp)
    80000988:	0141                	addi	sp,sp,16
    8000098a:	8082                	ret
    return -1;
    8000098c:	557d                	li	a0,-1
    8000098e:	bfe5                	j	80000986 <uartgetc+0x1a>

0000000080000990 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000990:	1101                	addi	sp,sp,-32
    80000992:	ec06                	sd	ra,24(sp)
    80000994:	e822                	sd	s0,16(sp)
    80000996:	e426                	sd	s1,8(sp)
    80000998:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099a:	54fd                	li	s1,-1
    8000099c:	a029                	j	800009a6 <uartintr+0x16>
      break;
    consoleintr(c);
    8000099e:	00000097          	auipc	ra,0x0
    800009a2:	918080e7          	jalr	-1768(ra) # 800002b6 <consoleintr>
    int c = uartgetc();
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	fc6080e7          	jalr	-58(ra) # 8000096c <uartgetc>
    if(c == -1)
    800009ae:	fe9518e3          	bne	a0,s1,8000099e <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b2:	00012497          	auipc	s1,0x12
    800009b6:	8d648493          	addi	s1,s1,-1834 # 80012288 <uart_tx_lock>
    800009ba:	8526                	mv	a0,s1
    800009bc:	00000097          	auipc	ra,0x0
    800009c0:	212080e7          	jalr	530(ra) # 80000bce <acquire>
  uartstart();
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	e6c080e7          	jalr	-404(ra) # 80000830 <uartstart>
  release(&uart_tx_lock);
    800009cc:	8526                	mv	a0,s1
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	2b4080e7          	jalr	692(ra) # 80000c82 <release>
}
    800009d6:	60e2                	ld	ra,24(sp)
    800009d8:	6442                	ld	s0,16(sp)
    800009da:	64a2                	ld	s1,8(sp)
    800009dc:	6105                	addi	sp,sp,32
    800009de:	8082                	ret

00000000800009e0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e0:	1101                	addi	sp,sp,-32
    800009e2:	ec06                	sd	ra,24(sp)
    800009e4:	e822                	sd	s0,16(sp)
    800009e6:	e426                	sd	s1,8(sp)
    800009e8:	e04a                	sd	s2,0(sp)
    800009ea:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009ec:	03451793          	slli	a5,a0,0x34
    800009f0:	ebb9                	bnez	a5,80000a46 <kfree+0x66>
    800009f2:	84aa                	mv	s1,a0
    800009f4:	00028797          	auipc	a5,0x28
    800009f8:	60c78793          	addi	a5,a5,1548 # 80029000 <end>
    800009fc:	04f56563          	bltu	a0,a5,80000a46 <kfree+0x66>
    80000a00:	47c5                	li	a5,17
    80000a02:	07ee                	slli	a5,a5,0x1b
    80000a04:	04f57163          	bgeu	a0,a5,80000a46 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a08:	6605                	lui	a2,0x1
    80000a0a:	4585                	li	a1,1
    80000a0c:	00000097          	auipc	ra,0x0
    80000a10:	2be080e7          	jalr	702(ra) # 80000cca <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a14:	00012917          	auipc	s2,0x12
    80000a18:	8ac90913          	addi	s2,s2,-1876 # 800122c0 <kmem>
    80000a1c:	854a                	mv	a0,s2
    80000a1e:	00000097          	auipc	ra,0x0
    80000a22:	1b0080e7          	jalr	432(ra) # 80000bce <acquire>
  r->next = kmem.freelist;
    80000a26:	01893783          	ld	a5,24(s2)
    80000a2a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a30:	854a                	mv	a0,s2
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	250080e7          	jalr	592(ra) # 80000c82 <release>
}
    80000a3a:	60e2                	ld	ra,24(sp)
    80000a3c:	6442                	ld	s0,16(sp)
    80000a3e:	64a2                	ld	s1,8(sp)
    80000a40:	6902                	ld	s2,0(sp)
    80000a42:	6105                	addi	sp,sp,32
    80000a44:	8082                	ret
    panic("kfree");
    80000a46:	00008517          	auipc	a0,0x8
    80000a4a:	61a50513          	addi	a0,a0,1562 # 80009060 <digits+0x20>
    80000a4e:	00000097          	auipc	ra,0x0
    80000a52:	aea080e7          	jalr	-1302(ra) # 80000538 <panic>

0000000080000a56 <freerange>:
{
    80000a56:	7179                	addi	sp,sp,-48
    80000a58:	f406                	sd	ra,40(sp)
    80000a5a:	f022                	sd	s0,32(sp)
    80000a5c:	ec26                	sd	s1,24(sp)
    80000a5e:	e84a                	sd	s2,16(sp)
    80000a60:	e44e                	sd	s3,8(sp)
    80000a62:	e052                	sd	s4,0(sp)
    80000a64:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a66:	6785                	lui	a5,0x1
    80000a68:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a6c:	00e504b3          	add	s1,a0,a4
    80000a70:	777d                	lui	a4,0xfffff
    80000a72:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a74:	94be                	add	s1,s1,a5
    80000a76:	0095ee63          	bltu	a1,s1,80000a92 <freerange+0x3c>
    80000a7a:	892e                	mv	s2,a1
    kfree(p);
    80000a7c:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7e:	6985                	lui	s3,0x1
    kfree(p);
    80000a80:	01448533          	add	a0,s1,s4
    80000a84:	00000097          	auipc	ra,0x0
    80000a88:	f5c080e7          	jalr	-164(ra) # 800009e0 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8c:	94ce                	add	s1,s1,s3
    80000a8e:	fe9979e3          	bgeu	s2,s1,80000a80 <freerange+0x2a>
}
    80000a92:	70a2                	ld	ra,40(sp)
    80000a94:	7402                	ld	s0,32(sp)
    80000a96:	64e2                	ld	s1,24(sp)
    80000a98:	6942                	ld	s2,16(sp)
    80000a9a:	69a2                	ld	s3,8(sp)
    80000a9c:	6a02                	ld	s4,0(sp)
    80000a9e:	6145                	addi	sp,sp,48
    80000aa0:	8082                	ret

0000000080000aa2 <kinit>:
{
    80000aa2:	1141                	addi	sp,sp,-16
    80000aa4:	e406                	sd	ra,8(sp)
    80000aa6:	e022                	sd	s0,0(sp)
    80000aa8:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aaa:	00008597          	auipc	a1,0x8
    80000aae:	5be58593          	addi	a1,a1,1470 # 80009068 <digits+0x28>
    80000ab2:	00012517          	auipc	a0,0x12
    80000ab6:	80e50513          	addi	a0,a0,-2034 # 800122c0 <kmem>
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	084080e7          	jalr	132(ra) # 80000b3e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac2:	45c5                	li	a1,17
    80000ac4:	05ee                	slli	a1,a1,0x1b
    80000ac6:	00028517          	auipc	a0,0x28
    80000aca:	53a50513          	addi	a0,a0,1338 # 80029000 <end>
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	f88080e7          	jalr	-120(ra) # 80000a56 <freerange>
}
    80000ad6:	60a2                	ld	ra,8(sp)
    80000ad8:	6402                	ld	s0,0(sp)
    80000ada:	0141                	addi	sp,sp,16
    80000adc:	8082                	ret

0000000080000ade <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ade:	1101                	addi	sp,sp,-32
    80000ae0:	ec06                	sd	ra,24(sp)
    80000ae2:	e822                	sd	s0,16(sp)
    80000ae4:	e426                	sd	s1,8(sp)
    80000ae6:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ae8:	00011497          	auipc	s1,0x11
    80000aec:	7d848493          	addi	s1,s1,2008 # 800122c0 <kmem>
    80000af0:	8526                	mv	a0,s1
    80000af2:	00000097          	auipc	ra,0x0
    80000af6:	0dc080e7          	jalr	220(ra) # 80000bce <acquire>
  r = kmem.freelist;
    80000afa:	6c84                	ld	s1,24(s1)
  if(r)
    80000afc:	c885                	beqz	s1,80000b2c <kalloc+0x4e>
    kmem.freelist = r->next;
    80000afe:	609c                	ld	a5,0(s1)
    80000b00:	00011517          	auipc	a0,0x11
    80000b04:	7c050513          	addi	a0,a0,1984 # 800122c0 <kmem>
    80000b08:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0a:	00000097          	auipc	ra,0x0
    80000b0e:	178080e7          	jalr	376(ra) # 80000c82 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b12:	6605                	lui	a2,0x1
    80000b14:	4595                	li	a1,5
    80000b16:	8526                	mv	a0,s1
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	1b2080e7          	jalr	434(ra) # 80000cca <memset>
  return (void*)r;
}
    80000b20:	8526                	mv	a0,s1
    80000b22:	60e2                	ld	ra,24(sp)
    80000b24:	6442                	ld	s0,16(sp)
    80000b26:	64a2                	ld	s1,8(sp)
    80000b28:	6105                	addi	sp,sp,32
    80000b2a:	8082                	ret
  release(&kmem.lock);
    80000b2c:	00011517          	auipc	a0,0x11
    80000b30:	79450513          	addi	a0,a0,1940 # 800122c0 <kmem>
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	14e080e7          	jalr	334(ra) # 80000c82 <release>
  if(r)
    80000b3c:	b7d5                	j	80000b20 <kalloc+0x42>

0000000080000b3e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b3e:	1141                	addi	sp,sp,-16
    80000b40:	e422                	sd	s0,8(sp)
    80000b42:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b44:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b46:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4a:	00053823          	sd	zero,16(a0)
}
    80000b4e:	6422                	ld	s0,8(sp)
    80000b50:	0141                	addi	sp,sp,16
    80000b52:	8082                	ret

0000000080000b54 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b54:	411c                	lw	a5,0(a0)
    80000b56:	e399                	bnez	a5,80000b5c <holding+0x8>
    80000b58:	4501                	li	a0,0
  return r;
}
    80000b5a:	8082                	ret
{
    80000b5c:	1101                	addi	sp,sp,-32
    80000b5e:	ec06                	sd	ra,24(sp)
    80000b60:	e822                	sd	s0,16(sp)
    80000b62:	e426                	sd	s1,8(sp)
    80000b64:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b66:	6904                	ld	s1,16(a0)
    80000b68:	00001097          	auipc	ra,0x1
    80000b6c:	e6c080e7          	jalr	-404(ra) # 800019d4 <mycpu>
    80000b70:	40a48533          	sub	a0,s1,a0
    80000b74:	00153513          	seqz	a0,a0
}
    80000b78:	60e2                	ld	ra,24(sp)
    80000b7a:	6442                	ld	s0,16(sp)
    80000b7c:	64a2                	ld	s1,8(sp)
    80000b7e:	6105                	addi	sp,sp,32
    80000b80:	8082                	ret

0000000080000b82 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b82:	1101                	addi	sp,sp,-32
    80000b84:	ec06                	sd	ra,24(sp)
    80000b86:	e822                	sd	s0,16(sp)
    80000b88:	e426                	sd	s1,8(sp)
    80000b8a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8c:	100024f3          	csrr	s1,sstatus
    80000b90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b94:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b96:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	e3a080e7          	jalr	-454(ra) # 800019d4 <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	cf89                	beqz	a5,80000bbe <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba6:	00001097          	auipc	ra,0x1
    80000baa:	e2e080e7          	jalr	-466(ra) # 800019d4 <mycpu>
    80000bae:	5d3c                	lw	a5,120(a0)
    80000bb0:	2785                	addiw	a5,a5,1
    80000bb2:	dd3c                	sw	a5,120(a0)
}
    80000bb4:	60e2                	ld	ra,24(sp)
    80000bb6:	6442                	ld	s0,16(sp)
    80000bb8:	64a2                	ld	s1,8(sp)
    80000bba:	6105                	addi	sp,sp,32
    80000bbc:	8082                	ret
    mycpu()->intena = old;
    80000bbe:	00001097          	auipc	ra,0x1
    80000bc2:	e16080e7          	jalr	-490(ra) # 800019d4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	bfe9                	j	80000ba6 <push_off+0x24>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	fa8080e7          	jalr	-88(ra) # 80000b82 <push_off>
  if(holding(lk))
    80000be2:	8526                	mv	a0,s1
    80000be4:	00000097          	auipc	ra,0x0
    80000be8:	f70080e7          	jalr	-144(ra) # 80000b54 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bec:	4705                	li	a4,1
  if(holding(lk))
    80000bee:	e115                	bnez	a0,80000c12 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	87ba                	mv	a5,a4
    80000bf2:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf6:	2781                	sext.w	a5,a5
    80000bf8:	ffe5                	bnez	a5,80000bf0 <acquire+0x22>
  __sync_synchronize();
    80000bfa:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bfe:	00001097          	auipc	ra,0x1
    80000c02:	dd6080e7          	jalr	-554(ra) # 800019d4 <mycpu>
    80000c06:	e888                	sd	a0,16(s1)
}
    80000c08:	60e2                	ld	ra,24(sp)
    80000c0a:	6442                	ld	s0,16(sp)
    80000c0c:	64a2                	ld	s1,8(sp)
    80000c0e:	6105                	addi	sp,sp,32
    80000c10:	8082                	ret
    panic("acquire");
    80000c12:	00008517          	auipc	a0,0x8
    80000c16:	45e50513          	addi	a0,a0,1118 # 80009070 <digits+0x30>
    80000c1a:	00000097          	auipc	ra,0x0
    80000c1e:	91e080e7          	jalr	-1762(ra) # 80000538 <panic>

0000000080000c22 <pop_off>:

void
pop_off(void)
{
    80000c22:	1141                	addi	sp,sp,-16
    80000c24:	e406                	sd	ra,8(sp)
    80000c26:	e022                	sd	s0,0(sp)
    80000c28:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2a:	00001097          	auipc	ra,0x1
    80000c2e:	daa080e7          	jalr	-598(ra) # 800019d4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c32:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c36:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c38:	e78d                	bnez	a5,80000c62 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3a:	5d3c                	lw	a5,120(a0)
    80000c3c:	02f05b63          	blez	a5,80000c72 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c40:	37fd                	addiw	a5,a5,-1
    80000c42:	0007871b          	sext.w	a4,a5
    80000c46:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c48:	eb09                	bnez	a4,80000c5a <pop_off+0x38>
    80000c4a:	5d7c                	lw	a5,124(a0)
    80000c4c:	c799                	beqz	a5,80000c5a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c52:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c56:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5a:	60a2                	ld	ra,8(sp)
    80000c5c:	6402                	ld	s0,0(sp)
    80000c5e:	0141                	addi	sp,sp,16
    80000c60:	8082                	ret
    panic("pop_off - interruptible");
    80000c62:	00008517          	auipc	a0,0x8
    80000c66:	41650513          	addi	a0,a0,1046 # 80009078 <digits+0x38>
    80000c6a:	00000097          	auipc	ra,0x0
    80000c6e:	8ce080e7          	jalr	-1842(ra) # 80000538 <panic>
    panic("pop_off");
    80000c72:	00008517          	auipc	a0,0x8
    80000c76:	41e50513          	addi	a0,a0,1054 # 80009090 <digits+0x50>
    80000c7a:	00000097          	auipc	ra,0x0
    80000c7e:	8be080e7          	jalr	-1858(ra) # 80000538 <panic>

0000000080000c82 <release>:
{
    80000c82:	1101                	addi	sp,sp,-32
    80000c84:	ec06                	sd	ra,24(sp)
    80000c86:	e822                	sd	s0,16(sp)
    80000c88:	e426                	sd	s1,8(sp)
    80000c8a:	1000                	addi	s0,sp,32
    80000c8c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c8e:	00000097          	auipc	ra,0x0
    80000c92:	ec6080e7          	jalr	-314(ra) # 80000b54 <holding>
    80000c96:	c115                	beqz	a0,80000cba <release+0x38>
  lk->cpu = 0;
    80000c98:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c9c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca0:	0f50000f          	fence	iorw,ow
    80000ca4:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	f7a080e7          	jalr	-134(ra) # 80000c22 <pop_off>
}
    80000cb0:	60e2                	ld	ra,24(sp)
    80000cb2:	6442                	ld	s0,16(sp)
    80000cb4:	64a2                	ld	s1,8(sp)
    80000cb6:	6105                	addi	sp,sp,32
    80000cb8:	8082                	ret
    panic("release");
    80000cba:	00008517          	auipc	a0,0x8
    80000cbe:	3de50513          	addi	a0,a0,990 # 80009098 <digits+0x58>
    80000cc2:	00000097          	auipc	ra,0x0
    80000cc6:	876080e7          	jalr	-1930(ra) # 80000538 <panic>

0000000080000cca <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cca:	1141                	addi	sp,sp,-16
    80000ccc:	e422                	sd	s0,8(sp)
    80000cce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd0:	ca19                	beqz	a2,80000ce6 <memset+0x1c>
    80000cd2:	87aa                	mv	a5,a0
    80000cd4:	1602                	slli	a2,a2,0x20
    80000cd6:	9201                	srli	a2,a2,0x20
    80000cd8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cdc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce0:	0785                	addi	a5,a5,1
    80000ce2:	fee79de3          	bne	a5,a4,80000cdc <memset+0x12>
  }
  return dst;
}
    80000ce6:	6422                	ld	s0,8(sp)
    80000ce8:	0141                	addi	sp,sp,16
    80000cea:	8082                	ret

0000000080000cec <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cec:	1141                	addi	sp,sp,-16
    80000cee:	e422                	sd	s0,8(sp)
    80000cf0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf2:	ca05                	beqz	a2,80000d22 <memcmp+0x36>
    80000cf4:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf8:	1682                	slli	a3,a3,0x20
    80000cfa:	9281                	srli	a3,a3,0x20
    80000cfc:	0685                	addi	a3,a3,1
    80000cfe:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d00:	00054783          	lbu	a5,0(a0)
    80000d04:	0005c703          	lbu	a4,0(a1)
    80000d08:	00e79863          	bne	a5,a4,80000d18 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0c:	0505                	addi	a0,a0,1
    80000d0e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d10:	fed518e3          	bne	a0,a3,80000d00 <memcmp+0x14>
  }

  return 0;
    80000d14:	4501                	li	a0,0
    80000d16:	a019                	j	80000d1c <memcmp+0x30>
      return *s1 - *s2;
    80000d18:	40e7853b          	subw	a0,a5,a4
}
    80000d1c:	6422                	ld	s0,8(sp)
    80000d1e:	0141                	addi	sp,sp,16
    80000d20:	8082                	ret
  return 0;
    80000d22:	4501                	li	a0,0
    80000d24:	bfe5                	j	80000d1c <memcmp+0x30>

0000000080000d26 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d26:	1141                	addi	sp,sp,-16
    80000d28:	e422                	sd	s0,8(sp)
    80000d2a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2c:	c205                	beqz	a2,80000d4c <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2e:	02a5e263          	bltu	a1,a0,80000d52 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d32:	1602                	slli	a2,a2,0x20
    80000d34:	9201                	srli	a2,a2,0x20
    80000d36:	00c587b3          	add	a5,a1,a2
{
    80000d3a:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3c:	0585                	addi	a1,a1,1
    80000d3e:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd6001>
    80000d40:	fff5c683          	lbu	a3,-1(a1)
    80000d44:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d48:	fef59ae3          	bne	a1,a5,80000d3c <memmove+0x16>

  return dst;
}
    80000d4c:	6422                	ld	s0,8(sp)
    80000d4e:	0141                	addi	sp,sp,16
    80000d50:	8082                	ret
  if(s < d && s + n > d){
    80000d52:	02061693          	slli	a3,a2,0x20
    80000d56:	9281                	srli	a3,a3,0x20
    80000d58:	00d58733          	add	a4,a1,a3
    80000d5c:	fce57be3          	bgeu	a0,a4,80000d32 <memmove+0xc>
    d += n;
    80000d60:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d62:	fff6079b          	addiw	a5,a2,-1
    80000d66:	1782                	slli	a5,a5,0x20
    80000d68:	9381                	srli	a5,a5,0x20
    80000d6a:	fff7c793          	not	a5,a5
    80000d6e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d70:	177d                	addi	a4,a4,-1
    80000d72:	16fd                	addi	a3,a3,-1
    80000d74:	00074603          	lbu	a2,0(a4)
    80000d78:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7c:	fee79ae3          	bne	a5,a4,80000d70 <memmove+0x4a>
    80000d80:	b7f1                	j	80000d4c <memmove+0x26>

0000000080000d82 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d82:	1141                	addi	sp,sp,-16
    80000d84:	e406                	sd	ra,8(sp)
    80000d86:	e022                	sd	s0,0(sp)
    80000d88:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8a:	00000097          	auipc	ra,0x0
    80000d8e:	f9c080e7          	jalr	-100(ra) # 80000d26 <memmove>
}
    80000d92:	60a2                	ld	ra,8(sp)
    80000d94:	6402                	ld	s0,0(sp)
    80000d96:	0141                	addi	sp,sp,16
    80000d98:	8082                	ret

0000000080000d9a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e422                	sd	s0,8(sp)
    80000d9e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da0:	ce11                	beqz	a2,80000dbc <strncmp+0x22>
    80000da2:	00054783          	lbu	a5,0(a0)
    80000da6:	cf89                	beqz	a5,80000dc0 <strncmp+0x26>
    80000da8:	0005c703          	lbu	a4,0(a1)
    80000dac:	00f71a63          	bne	a4,a5,80000dc0 <strncmp+0x26>
    n--, p++, q++;
    80000db0:	367d                	addiw	a2,a2,-1
    80000db2:	0505                	addi	a0,a0,1
    80000db4:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db6:	f675                	bnez	a2,80000da2 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db8:	4501                	li	a0,0
    80000dba:	a809                	j	80000dcc <strncmp+0x32>
    80000dbc:	4501                	li	a0,0
    80000dbe:	a039                	j	80000dcc <strncmp+0x32>
  if(n == 0)
    80000dc0:	ca09                	beqz	a2,80000dd2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc2:	00054503          	lbu	a0,0(a0)
    80000dc6:	0005c783          	lbu	a5,0(a1)
    80000dca:	9d1d                	subw	a0,a0,a5
}
    80000dcc:	6422                	ld	s0,8(sp)
    80000dce:	0141                	addi	sp,sp,16
    80000dd0:	8082                	ret
    return 0;
    80000dd2:	4501                	li	a0,0
    80000dd4:	bfe5                	j	80000dcc <strncmp+0x32>

0000000080000dd6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd6:	1141                	addi	sp,sp,-16
    80000dd8:	e422                	sd	s0,8(sp)
    80000dda:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ddc:	872a                	mv	a4,a0
    80000dde:	8832                	mv	a6,a2
    80000de0:	367d                	addiw	a2,a2,-1
    80000de2:	01005963          	blez	a6,80000df4 <strncpy+0x1e>
    80000de6:	0705                	addi	a4,a4,1
    80000de8:	0005c783          	lbu	a5,0(a1)
    80000dec:	fef70fa3          	sb	a5,-1(a4)
    80000df0:	0585                	addi	a1,a1,1
    80000df2:	f7f5                	bnez	a5,80000dde <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df4:	86ba                	mv	a3,a4
    80000df6:	00c05c63          	blez	a2,80000e0e <strncpy+0x38>
    *s++ = 0;
    80000dfa:	0685                	addi	a3,a3,1
    80000dfc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e00:	40d707bb          	subw	a5,a4,a3
    80000e04:	37fd                	addiw	a5,a5,-1
    80000e06:	010787bb          	addw	a5,a5,a6
    80000e0a:	fef048e3          	bgtz	a5,80000dfa <strncpy+0x24>
  return os;
}
    80000e0e:	6422                	ld	s0,8(sp)
    80000e10:	0141                	addi	sp,sp,16
    80000e12:	8082                	ret

0000000080000e14 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e422                	sd	s0,8(sp)
    80000e18:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1a:	02c05363          	blez	a2,80000e40 <safestrcpy+0x2c>
    80000e1e:	fff6069b          	addiw	a3,a2,-1
    80000e22:	1682                	slli	a3,a3,0x20
    80000e24:	9281                	srli	a3,a3,0x20
    80000e26:	96ae                	add	a3,a3,a1
    80000e28:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2a:	00d58963          	beq	a1,a3,80000e3c <safestrcpy+0x28>
    80000e2e:	0585                	addi	a1,a1,1
    80000e30:	0785                	addi	a5,a5,1
    80000e32:	fff5c703          	lbu	a4,-1(a1)
    80000e36:	fee78fa3          	sb	a4,-1(a5)
    80000e3a:	fb65                	bnez	a4,80000e2a <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e40:	6422                	ld	s0,8(sp)
    80000e42:	0141                	addi	sp,sp,16
    80000e44:	8082                	ret

0000000080000e46 <strlen>:

int
strlen(const char *s)
{
    80000e46:	1141                	addi	sp,sp,-16
    80000e48:	e422                	sd	s0,8(sp)
    80000e4a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4c:	00054783          	lbu	a5,0(a0)
    80000e50:	cf91                	beqz	a5,80000e6c <strlen+0x26>
    80000e52:	0505                	addi	a0,a0,1
    80000e54:	87aa                	mv	a5,a0
    80000e56:	4685                	li	a3,1
    80000e58:	9e89                	subw	a3,a3,a0
    80000e5a:	00f6853b          	addw	a0,a3,a5
    80000e5e:	0785                	addi	a5,a5,1
    80000e60:	fff7c703          	lbu	a4,-1(a5)
    80000e64:	fb7d                	bnez	a4,80000e5a <strlen+0x14>
    ;
  return n;
}
    80000e66:	6422                	ld	s0,8(sp)
    80000e68:	0141                	addi	sp,sp,16
    80000e6a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6c:	4501                	li	a0,0
    80000e6e:	bfe5                	j	80000e66 <strlen+0x20>

0000000080000e70 <main>:
extern int sem_buffer[20];

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e70:	7139                	addi	sp,sp,-64
    80000e72:	fc06                	sd	ra,56(sp)
    80000e74:	f822                	sd	s0,48(sp)
    80000e76:	f426                	sd	s1,40(sp)
    80000e78:	f04a                	sd	s2,32(sp)
    80000e7a:	ec4e                	sd	s3,24(sp)
    80000e7c:	e852                	sd	s4,16(sp)
    80000e7e:	e456                	sd	s5,8(sp)
    80000e80:	0080                	addi	s0,sp,64
  if(cpuid() == 0){
    80000e82:	00001097          	auipc	ra,0x1
    80000e86:	b42080e7          	jalr	-1214(ra) # 800019c4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e8a:	00009717          	auipc	a4,0x9
    80000e8e:	18e70713          	addi	a4,a4,398 # 8000a018 <started>
  if(cpuid() == 0){
    80000e92:	cd41                	beqz	a0,80000f2a <main+0xba>
    while(started == 0)
    80000e94:	431c                	lw	a5,0(a4)
    80000e96:	2781                	sext.w	a5,a5
    80000e98:	dff5                	beqz	a5,80000e94 <main+0x24>
      ;
    __sync_synchronize();
    80000e9a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9e:	00001097          	auipc	ra,0x1
    80000ea2:	b26080e7          	jalr	-1242(ra) # 800019c4 <cpuid>
    80000ea6:	85aa                	mv	a1,a0
    80000ea8:	00008517          	auipc	a0,0x8
    80000eac:	21050513          	addi	a0,a0,528 # 800090b8 <digits+0x78>
    80000eb0:	fffff097          	auipc	ra,0xfffff
    80000eb4:	6d2080e7          	jalr	1746(ra) # 80000582 <printf>
    kvminithart();    // turn on paging
    80000eb8:	00000097          	auipc	ra,0x0
    80000ebc:	12a080e7          	jalr	298(ra) # 80000fe2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ec0:	00003097          	auipc	ra,0x3
    80000ec4:	a6a080e7          	jalr	-1430(ra) # 8000392a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec8:	00007097          	auipc	ra,0x7
    80000ecc:	8c8080e7          	jalr	-1848(ra) # 80007790 <plicinithart>
  }

  sched_policy = SCHED_PREEMPT_RR;
    80000ed0:	4789                	li	a5,2
    80000ed2:	00009717          	auipc	a4,0x9
    80000ed6:	18f72b23          	sw	a5,406(a4) # 8000a068 <sched_policy>

  for (int i = 0; i < 10; i++)
    80000eda:	00018497          	auipc	s1,0x18
    80000ede:	c5648493          	addi	s1,s1,-938 # 80018b30 <barr+0x8>
    80000ee2:	00018a97          	auipc	s5,0x18
    80000ee6:	05ea8a93          	addi	s5,s5,94 # 80018f40 <lock_delete+0x8>
  {
    barr[i].counter = -1;
    80000eea:	5a7d                	li	s4,-1
    initsleeplock(&barr[i].lock, "barrier_lock");
    80000eec:	00008997          	auipc	s3,0x8
    80000ef0:	1e498993          	addi	s3,s3,484 # 800090d0 <digits+0x90>
    initsleeplock(&barr[i].cv.lk, "barrier_cv_lock");
    80000ef4:	00008917          	auipc	s2,0x8
    80000ef8:	1ec90913          	addi	s2,s2,492 # 800090e0 <digits+0xa0>
    barr[i].counter = -1;
    80000efc:	ff44ac23          	sw	s4,-8(s1)
    initsleeplock(&barr[i].lock, "barrier_lock");
    80000f00:	85ce                	mv	a1,s3
    80000f02:	8526                	mv	a0,s1
    80000f04:	00005097          	auipc	ra,0x5
    80000f08:	f82080e7          	jalr	-126(ra) # 80005e86 <initsleeplock>
    initsleeplock(&barr[i].cv.lk, "barrier_cv_lock");
    80000f0c:	85ca                	mv	a1,s2
    80000f0e:	03048513          	addi	a0,s1,48
    80000f12:	00005097          	auipc	ra,0x5
    80000f16:	f74080e7          	jalr	-140(ra) # 80005e86 <initsleeplock>
  for (int i = 0; i < 10; i++)
    80000f1a:	06848493          	addi	s1,s1,104
    80000f1e:	fd549fe3          	bne	s1,s5,80000efc <main+0x8c>
  }
  

  scheduler();        
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	31e080e7          	jalr	798(ra) # 80002240 <scheduler>
    consoleinit();
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	51e080e7          	jalr	1310(ra) # 80000448 <consoleinit>
    printfinit();
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	830080e7          	jalr	-2000(ra) # 80000762 <printfinit>
    printf("\n");
    80000f3a:	00009517          	auipc	a0,0x9
    80000f3e:	87650513          	addi	a0,a0,-1930 # 800097b0 <syscalls+0x150>
    80000f42:	fffff097          	auipc	ra,0xfffff
    80000f46:	640080e7          	jalr	1600(ra) # 80000582 <printf>
    printf("xv6 kernel is booting\n");
    80000f4a:	00008517          	auipc	a0,0x8
    80000f4e:	15650513          	addi	a0,a0,342 # 800090a0 <digits+0x60>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	630080e7          	jalr	1584(ra) # 80000582 <printf>
    printf("\n");
    80000f5a:	00009517          	auipc	a0,0x9
    80000f5e:	85650513          	addi	a0,a0,-1962 # 800097b0 <syscalls+0x150>
    80000f62:	fffff097          	auipc	ra,0xfffff
    80000f66:	620080e7          	jalr	1568(ra) # 80000582 <printf>
    kinit();         // physical page allocator
    80000f6a:	00000097          	auipc	ra,0x0
    80000f6e:	b38080e7          	jalr	-1224(ra) # 80000aa2 <kinit>
    kvminit();       // create kernel page table
    80000f72:	00000097          	auipc	ra,0x0
    80000f76:	322080e7          	jalr	802(ra) # 80001294 <kvminit>
    kvminithart();   // turn on paging
    80000f7a:	00000097          	auipc	ra,0x0
    80000f7e:	068080e7          	jalr	104(ra) # 80000fe2 <kvminithart>
    procinit();      // process table
    80000f82:	00001097          	auipc	ra,0x1
    80000f86:	992080e7          	jalr	-1646(ra) # 80001914 <procinit>
    trapinit();      // trap vectors
    80000f8a:	00003097          	auipc	ra,0x3
    80000f8e:	978080e7          	jalr	-1672(ra) # 80003902 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f92:	00003097          	auipc	ra,0x3
    80000f96:	998080e7          	jalr	-1640(ra) # 8000392a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9a:	00006097          	auipc	ra,0x6
    80000f9e:	7e0080e7          	jalr	2016(ra) # 8000777a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa2:	00006097          	auipc	ra,0x6
    80000fa6:	7ee080e7          	jalr	2030(ra) # 80007790 <plicinithart>
    binit();         // buffer cache
    80000faa:	00004097          	auipc	ra,0x4
    80000fae:	9b6080e7          	jalr	-1610(ra) # 80004960 <binit>
    iinit();         // inode table
    80000fb2:	00004097          	auipc	ra,0x4
    80000fb6:	044080e7          	jalr	68(ra) # 80004ff6 <iinit>
    fileinit();      // file table
    80000fba:	00005097          	auipc	ra,0x5
    80000fbe:	ff6080e7          	jalr	-10(ra) # 80005fb0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc2:	00007097          	auipc	ra,0x7
    80000fc6:	8ee080e7          	jalr	-1810(ra) # 800078b0 <virtio_disk_init>
    userinit();      // first user process
    80000fca:	00001097          	auipc	ra,0x1
    80000fce:	d74080e7          	jalr	-652(ra) # 80001d3e <userinit>
    __sync_synchronize();
    80000fd2:	0ff0000f          	fence
    started = 1;
    80000fd6:	4785                	li	a5,1
    80000fd8:	00009717          	auipc	a4,0x9
    80000fdc:	04f72023          	sw	a5,64(a4) # 8000a018 <started>
    80000fe0:	bdc5                	j	80000ed0 <main+0x60>

0000000080000fe2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e422                	sd	s0,8(sp)
    80000fe6:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fe8:	00009797          	auipc	a5,0x9
    80000fec:	0387b783          	ld	a5,56(a5) # 8000a020 <kernel_pagetable>
    80000ff0:	83b1                	srli	a5,a5,0xc
    80000ff2:	577d                	li	a4,-1
    80000ff4:	177e                	slli	a4,a4,0x3f
    80000ff6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000ff8:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ffc:	12000073          	sfence.vma
  sfence_vma();
}
    80001000:	6422                	ld	s0,8(sp)
    80001002:	0141                	addi	sp,sp,16
    80001004:	8082                	ret

0000000080001006 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001006:	7139                	addi	sp,sp,-64
    80001008:	fc06                	sd	ra,56(sp)
    8000100a:	f822                	sd	s0,48(sp)
    8000100c:	f426                	sd	s1,40(sp)
    8000100e:	f04a                	sd	s2,32(sp)
    80001010:	ec4e                	sd	s3,24(sp)
    80001012:	e852                	sd	s4,16(sp)
    80001014:	e456                	sd	s5,8(sp)
    80001016:	e05a                	sd	s6,0(sp)
    80001018:	0080                	addi	s0,sp,64
    8000101a:	84aa                	mv	s1,a0
    8000101c:	89ae                	mv	s3,a1
    8000101e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001020:	57fd                	li	a5,-1
    80001022:	83e9                	srli	a5,a5,0x1a
    80001024:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001026:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001028:	04b7f263          	bgeu	a5,a1,8000106c <walk+0x66>
    panic("walk");
    8000102c:	00008517          	auipc	a0,0x8
    80001030:	0c450513          	addi	a0,a0,196 # 800090f0 <digits+0xb0>
    80001034:	fffff097          	auipc	ra,0xfffff
    80001038:	504080e7          	jalr	1284(ra) # 80000538 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000103c:	060a8663          	beqz	s5,800010a8 <walk+0xa2>
    80001040:	00000097          	auipc	ra,0x0
    80001044:	a9e080e7          	jalr	-1378(ra) # 80000ade <kalloc>
    80001048:	84aa                	mv	s1,a0
    8000104a:	c529                	beqz	a0,80001094 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000104c:	6605                	lui	a2,0x1
    8000104e:	4581                	li	a1,0
    80001050:	00000097          	auipc	ra,0x0
    80001054:	c7a080e7          	jalr	-902(ra) # 80000cca <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001058:	00c4d793          	srli	a5,s1,0xc
    8000105c:	07aa                	slli	a5,a5,0xa
    8000105e:	0017e793          	ori	a5,a5,1
    80001062:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001066:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd5ff7>
    80001068:	036a0063          	beq	s4,s6,80001088 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000106c:	0149d933          	srl	s2,s3,s4
    80001070:	1ff97913          	andi	s2,s2,511
    80001074:	090e                	slli	s2,s2,0x3
    80001076:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001078:	00093483          	ld	s1,0(s2)
    8000107c:	0014f793          	andi	a5,s1,1
    80001080:	dfd5                	beqz	a5,8000103c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001082:	80a9                	srli	s1,s1,0xa
    80001084:	04b2                	slli	s1,s1,0xc
    80001086:	b7c5                	j	80001066 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001088:	00c9d513          	srli	a0,s3,0xc
    8000108c:	1ff57513          	andi	a0,a0,511
    80001090:	050e                	slli	a0,a0,0x3
    80001092:	9526                	add	a0,a0,s1
}
    80001094:	70e2                	ld	ra,56(sp)
    80001096:	7442                	ld	s0,48(sp)
    80001098:	74a2                	ld	s1,40(sp)
    8000109a:	7902                	ld	s2,32(sp)
    8000109c:	69e2                	ld	s3,24(sp)
    8000109e:	6a42                	ld	s4,16(sp)
    800010a0:	6aa2                	ld	s5,8(sp)
    800010a2:	6b02                	ld	s6,0(sp)
    800010a4:	6121                	addi	sp,sp,64
    800010a6:	8082                	ret
        return 0;
    800010a8:	4501                	li	a0,0
    800010aa:	b7ed                	j	80001094 <walk+0x8e>

00000000800010ac <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010ac:	57fd                	li	a5,-1
    800010ae:	83e9                	srli	a5,a5,0x1a
    800010b0:	00b7f463          	bgeu	a5,a1,800010b8 <walkaddr+0xc>
    return 0;
    800010b4:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010b6:	8082                	ret
{
    800010b8:	1141                	addi	sp,sp,-16
    800010ba:	e406                	sd	ra,8(sp)
    800010bc:	e022                	sd	s0,0(sp)
    800010be:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010c0:	4601                	li	a2,0
    800010c2:	00000097          	auipc	ra,0x0
    800010c6:	f44080e7          	jalr	-188(ra) # 80001006 <walk>
  if(pte == 0)
    800010ca:	c105                	beqz	a0,800010ea <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010cc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010ce:	0117f693          	andi	a3,a5,17
    800010d2:	4745                	li	a4,17
    return 0;
    800010d4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010d6:	00e68663          	beq	a3,a4,800010e2 <walkaddr+0x36>
}
    800010da:	60a2                	ld	ra,8(sp)
    800010dc:	6402                	ld	s0,0(sp)
    800010de:	0141                	addi	sp,sp,16
    800010e0:	8082                	ret
  pa = PTE2PA(*pte);
    800010e2:	83a9                	srli	a5,a5,0xa
    800010e4:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010e8:	bfcd                	j	800010da <walkaddr+0x2e>
    return 0;
    800010ea:	4501                	li	a0,0
    800010ec:	b7fd                	j	800010da <walkaddr+0x2e>

00000000800010ee <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ee:	715d                	addi	sp,sp,-80
    800010f0:	e486                	sd	ra,72(sp)
    800010f2:	e0a2                	sd	s0,64(sp)
    800010f4:	fc26                	sd	s1,56(sp)
    800010f6:	f84a                	sd	s2,48(sp)
    800010f8:	f44e                	sd	s3,40(sp)
    800010fa:	f052                	sd	s4,32(sp)
    800010fc:	ec56                	sd	s5,24(sp)
    800010fe:	e85a                	sd	s6,16(sp)
    80001100:	e45e                	sd	s7,8(sp)
    80001102:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001104:	c639                	beqz	a2,80001152 <mappages+0x64>
    80001106:	8aaa                	mv	s5,a0
    80001108:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000110a:	777d                	lui	a4,0xfffff
    8000110c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001110:	fff58993          	addi	s3,a1,-1
    80001114:	99b2                	add	s3,s3,a2
    80001116:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000111a:	893e                	mv	s2,a5
    8000111c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001120:	6b85                	lui	s7,0x1
    80001122:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001126:	4605                	li	a2,1
    80001128:	85ca                	mv	a1,s2
    8000112a:	8556                	mv	a0,s5
    8000112c:	00000097          	auipc	ra,0x0
    80001130:	eda080e7          	jalr	-294(ra) # 80001006 <walk>
    80001134:	cd1d                	beqz	a0,80001172 <mappages+0x84>
    if(*pte & PTE_V)
    80001136:	611c                	ld	a5,0(a0)
    80001138:	8b85                	andi	a5,a5,1
    8000113a:	e785                	bnez	a5,80001162 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000113c:	80b1                	srli	s1,s1,0xc
    8000113e:	04aa                	slli	s1,s1,0xa
    80001140:	0164e4b3          	or	s1,s1,s6
    80001144:	0014e493          	ori	s1,s1,1
    80001148:	e104                	sd	s1,0(a0)
    if(a == last)
    8000114a:	05390063          	beq	s2,s3,8000118a <mappages+0x9c>
    a += PGSIZE;
    8000114e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001150:	bfc9                	j	80001122 <mappages+0x34>
    panic("mappages: size");
    80001152:	00008517          	auipc	a0,0x8
    80001156:	fa650513          	addi	a0,a0,-90 # 800090f8 <digits+0xb8>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	3de080e7          	jalr	990(ra) # 80000538 <panic>
      panic("mappages: remap");
    80001162:	00008517          	auipc	a0,0x8
    80001166:	fa650513          	addi	a0,a0,-90 # 80009108 <digits+0xc8>
    8000116a:	fffff097          	auipc	ra,0xfffff
    8000116e:	3ce080e7          	jalr	974(ra) # 80000538 <panic>
      return -1;
    80001172:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001174:	60a6                	ld	ra,72(sp)
    80001176:	6406                	ld	s0,64(sp)
    80001178:	74e2                	ld	s1,56(sp)
    8000117a:	7942                	ld	s2,48(sp)
    8000117c:	79a2                	ld	s3,40(sp)
    8000117e:	7a02                	ld	s4,32(sp)
    80001180:	6ae2                	ld	s5,24(sp)
    80001182:	6b42                	ld	s6,16(sp)
    80001184:	6ba2                	ld	s7,8(sp)
    80001186:	6161                	addi	sp,sp,80
    80001188:	8082                	ret
  return 0;
    8000118a:	4501                	li	a0,0
    8000118c:	b7e5                	j	80001174 <mappages+0x86>

000000008000118e <kvmmap>:
{
    8000118e:	1141                	addi	sp,sp,-16
    80001190:	e406                	sd	ra,8(sp)
    80001192:	e022                	sd	s0,0(sp)
    80001194:	0800                	addi	s0,sp,16
    80001196:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001198:	86b2                	mv	a3,a2
    8000119a:	863e                	mv	a2,a5
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	f52080e7          	jalr	-174(ra) # 800010ee <mappages>
    800011a4:	e509                	bnez	a0,800011ae <kvmmap+0x20>
}
    800011a6:	60a2                	ld	ra,8(sp)
    800011a8:	6402                	ld	s0,0(sp)
    800011aa:	0141                	addi	sp,sp,16
    800011ac:	8082                	ret
    panic("kvmmap");
    800011ae:	00008517          	auipc	a0,0x8
    800011b2:	f6a50513          	addi	a0,a0,-150 # 80009118 <digits+0xd8>
    800011b6:	fffff097          	auipc	ra,0xfffff
    800011ba:	382080e7          	jalr	898(ra) # 80000538 <panic>

00000000800011be <kvmmake>:
{
    800011be:	1101                	addi	sp,sp,-32
    800011c0:	ec06                	sd	ra,24(sp)
    800011c2:	e822                	sd	s0,16(sp)
    800011c4:	e426                	sd	s1,8(sp)
    800011c6:	e04a                	sd	s2,0(sp)
    800011c8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	914080e7          	jalr	-1772(ra) # 80000ade <kalloc>
    800011d2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011d4:	6605                	lui	a2,0x1
    800011d6:	4581                	li	a1,0
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	af2080e7          	jalr	-1294(ra) # 80000cca <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011e0:	4719                	li	a4,6
    800011e2:	6685                	lui	a3,0x1
    800011e4:	10000637          	lui	a2,0x10000
    800011e8:	100005b7          	lui	a1,0x10000
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	fa0080e7          	jalr	-96(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	6685                	lui	a3,0x1
    800011fa:	10001637          	lui	a2,0x10001
    800011fe:	100015b7          	lui	a1,0x10001
    80001202:	8526                	mv	a0,s1
    80001204:	00000097          	auipc	ra,0x0
    80001208:	f8a080e7          	jalr	-118(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000120c:	4719                	li	a4,6
    8000120e:	004006b7          	lui	a3,0x400
    80001212:	0c000637          	lui	a2,0xc000
    80001216:	0c0005b7          	lui	a1,0xc000
    8000121a:	8526                	mv	a0,s1
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	f72080e7          	jalr	-142(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001224:	00008917          	auipc	s2,0x8
    80001228:	ddc90913          	addi	s2,s2,-548 # 80009000 <etext>
    8000122c:	4729                	li	a4,10
    8000122e:	80008697          	auipc	a3,0x80008
    80001232:	dd268693          	addi	a3,a3,-558 # 9000 <_entry-0x7fff7000>
    80001236:	4605                	li	a2,1
    80001238:	067e                	slli	a2,a2,0x1f
    8000123a:	85b2                	mv	a1,a2
    8000123c:	8526                	mv	a0,s1
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	f50080e7          	jalr	-176(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001246:	4719                	li	a4,6
    80001248:	46c5                	li	a3,17
    8000124a:	06ee                	slli	a3,a3,0x1b
    8000124c:	412686b3          	sub	a3,a3,s2
    80001250:	864a                	mv	a2,s2
    80001252:	85ca                	mv	a1,s2
    80001254:	8526                	mv	a0,s1
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	f38080e7          	jalr	-200(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000125e:	4729                	li	a4,10
    80001260:	6685                	lui	a3,0x1
    80001262:	00007617          	auipc	a2,0x7
    80001266:	d9e60613          	addi	a2,a2,-610 # 80008000 <_trampoline>
    8000126a:	040005b7          	lui	a1,0x4000
    8000126e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001270:	05b2                	slli	a1,a1,0xc
    80001272:	8526                	mv	a0,s1
    80001274:	00000097          	auipc	ra,0x0
    80001278:	f1a080e7          	jalr	-230(ra) # 8000118e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	600080e7          	jalr	1536(ra) # 8000187e <proc_mapstacks>
}
    80001286:	8526                	mv	a0,s1
    80001288:	60e2                	ld	ra,24(sp)
    8000128a:	6442                	ld	s0,16(sp)
    8000128c:	64a2                	ld	s1,8(sp)
    8000128e:	6902                	ld	s2,0(sp)
    80001290:	6105                	addi	sp,sp,32
    80001292:	8082                	ret

0000000080001294 <kvminit>:
{
    80001294:	1141                	addi	sp,sp,-16
    80001296:	e406                	sd	ra,8(sp)
    80001298:	e022                	sd	s0,0(sp)
    8000129a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f22080e7          	jalr	-222(ra) # 800011be <kvmmake>
    800012a4:	00009797          	auipc	a5,0x9
    800012a8:	d6a7be23          	sd	a0,-644(a5) # 8000a020 <kernel_pagetable>
}
    800012ac:	60a2                	ld	ra,8(sp)
    800012ae:	6402                	ld	s0,0(sp)
    800012b0:	0141                	addi	sp,sp,16
    800012b2:	8082                	ret

00000000800012b4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012b4:	715d                	addi	sp,sp,-80
    800012b6:	e486                	sd	ra,72(sp)
    800012b8:	e0a2                	sd	s0,64(sp)
    800012ba:	fc26                	sd	s1,56(sp)
    800012bc:	f84a                	sd	s2,48(sp)
    800012be:	f44e                	sd	s3,40(sp)
    800012c0:	f052                	sd	s4,32(sp)
    800012c2:	ec56                	sd	s5,24(sp)
    800012c4:	e85a                	sd	s6,16(sp)
    800012c6:	e45e                	sd	s7,8(sp)
    800012c8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012ca:	03459793          	slli	a5,a1,0x34
    800012ce:	e795                	bnez	a5,800012fa <uvmunmap+0x46>
    800012d0:	8a2a                	mv	s4,a0
    800012d2:	892e                	mv	s2,a1
    800012d4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012d6:	0632                	slli	a2,a2,0xc
    800012d8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012dc:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	6b05                	lui	s6,0x1
    800012e0:	0735e263          	bltu	a1,s3,80001344 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012e4:	60a6                	ld	ra,72(sp)
    800012e6:	6406                	ld	s0,64(sp)
    800012e8:	74e2                	ld	s1,56(sp)
    800012ea:	7942                	ld	s2,48(sp)
    800012ec:	79a2                	ld	s3,40(sp)
    800012ee:	7a02                	ld	s4,32(sp)
    800012f0:	6ae2                	ld	s5,24(sp)
    800012f2:	6b42                	ld	s6,16(sp)
    800012f4:	6ba2                	ld	s7,8(sp)
    800012f6:	6161                	addi	sp,sp,80
    800012f8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012fa:	00008517          	auipc	a0,0x8
    800012fe:	e2650513          	addi	a0,a0,-474 # 80009120 <digits+0xe0>
    80001302:	fffff097          	auipc	ra,0xfffff
    80001306:	236080e7          	jalr	566(ra) # 80000538 <panic>
      panic("uvmunmap: walk");
    8000130a:	00008517          	auipc	a0,0x8
    8000130e:	e2e50513          	addi	a0,a0,-466 # 80009138 <digits+0xf8>
    80001312:	fffff097          	auipc	ra,0xfffff
    80001316:	226080e7          	jalr	550(ra) # 80000538 <panic>
      panic("uvmunmap: not mapped");
    8000131a:	00008517          	auipc	a0,0x8
    8000131e:	e2e50513          	addi	a0,a0,-466 # 80009148 <digits+0x108>
    80001322:	fffff097          	auipc	ra,0xfffff
    80001326:	216080e7          	jalr	534(ra) # 80000538 <panic>
      panic("uvmunmap: not a leaf");
    8000132a:	00008517          	auipc	a0,0x8
    8000132e:	e3650513          	addi	a0,a0,-458 # 80009160 <digits+0x120>
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	206080e7          	jalr	518(ra) # 80000538 <panic>
    *pte = 0;
    8000133a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000133e:	995a                	add	s2,s2,s6
    80001340:	fb3972e3          	bgeu	s2,s3,800012e4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001344:	4601                	li	a2,0
    80001346:	85ca                	mv	a1,s2
    80001348:	8552                	mv	a0,s4
    8000134a:	00000097          	auipc	ra,0x0
    8000134e:	cbc080e7          	jalr	-836(ra) # 80001006 <walk>
    80001352:	84aa                	mv	s1,a0
    80001354:	d95d                	beqz	a0,8000130a <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001356:	6108                	ld	a0,0(a0)
    80001358:	00157793          	andi	a5,a0,1
    8000135c:	dfdd                	beqz	a5,8000131a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000135e:	3ff57793          	andi	a5,a0,1023
    80001362:	fd7784e3          	beq	a5,s7,8000132a <uvmunmap+0x76>
    if(do_free){
    80001366:	fc0a8ae3          	beqz	s5,8000133a <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000136a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000136c:	0532                	slli	a0,a0,0xc
    8000136e:	fffff097          	auipc	ra,0xfffff
    80001372:	672080e7          	jalr	1650(ra) # 800009e0 <kfree>
    80001376:	b7d1                	j	8000133a <uvmunmap+0x86>

0000000080001378 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001378:	1101                	addi	sp,sp,-32
    8000137a:	ec06                	sd	ra,24(sp)
    8000137c:	e822                	sd	s0,16(sp)
    8000137e:	e426                	sd	s1,8(sp)
    80001380:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	75c080e7          	jalr	1884(ra) # 80000ade <kalloc>
    8000138a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000138c:	c519                	beqz	a0,8000139a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	00000097          	auipc	ra,0x0
    80001396:	938080e7          	jalr	-1736(ra) # 80000cca <memset>
  return pagetable;
}
    8000139a:	8526                	mv	a0,s1
    8000139c:	60e2                	ld	ra,24(sp)
    8000139e:	6442                	ld	s0,16(sp)
    800013a0:	64a2                	ld	s1,8(sp)
    800013a2:	6105                	addi	sp,sp,32
    800013a4:	8082                	ret

00000000800013a6 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013a6:	7179                	addi	sp,sp,-48
    800013a8:	f406                	sd	ra,40(sp)
    800013aa:	f022                	sd	s0,32(sp)
    800013ac:	ec26                	sd	s1,24(sp)
    800013ae:	e84a                	sd	s2,16(sp)
    800013b0:	e44e                	sd	s3,8(sp)
    800013b2:	e052                	sd	s4,0(sp)
    800013b4:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013b6:	6785                	lui	a5,0x1
    800013b8:	04f67863          	bgeu	a2,a5,80001408 <uvminit+0x62>
    800013bc:	8a2a                	mv	s4,a0
    800013be:	89ae                	mv	s3,a1
    800013c0:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013c2:	fffff097          	auipc	ra,0xfffff
    800013c6:	71c080e7          	jalr	1820(ra) # 80000ade <kalloc>
    800013ca:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013cc:	6605                	lui	a2,0x1
    800013ce:	4581                	li	a1,0
    800013d0:	00000097          	auipc	ra,0x0
    800013d4:	8fa080e7          	jalr	-1798(ra) # 80000cca <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013d8:	4779                	li	a4,30
    800013da:	86ca                	mv	a3,s2
    800013dc:	6605                	lui	a2,0x1
    800013de:	4581                	li	a1,0
    800013e0:	8552                	mv	a0,s4
    800013e2:	00000097          	auipc	ra,0x0
    800013e6:	d0c080e7          	jalr	-756(ra) # 800010ee <mappages>
  memmove(mem, src, sz);
    800013ea:	8626                	mv	a2,s1
    800013ec:	85ce                	mv	a1,s3
    800013ee:	854a                	mv	a0,s2
    800013f0:	00000097          	auipc	ra,0x0
    800013f4:	936080e7          	jalr	-1738(ra) # 80000d26 <memmove>
}
    800013f8:	70a2                	ld	ra,40(sp)
    800013fa:	7402                	ld	s0,32(sp)
    800013fc:	64e2                	ld	s1,24(sp)
    800013fe:	6942                	ld	s2,16(sp)
    80001400:	69a2                	ld	s3,8(sp)
    80001402:	6a02                	ld	s4,0(sp)
    80001404:	6145                	addi	sp,sp,48
    80001406:	8082                	ret
    panic("inituvm: more than a page");
    80001408:	00008517          	auipc	a0,0x8
    8000140c:	d7050513          	addi	a0,a0,-656 # 80009178 <digits+0x138>
    80001410:	fffff097          	auipc	ra,0xfffff
    80001414:	128080e7          	jalr	296(ra) # 80000538 <panic>

0000000080001418 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001418:	1101                	addi	sp,sp,-32
    8000141a:	ec06                	sd	ra,24(sp)
    8000141c:	e822                	sd	s0,16(sp)
    8000141e:	e426                	sd	s1,8(sp)
    80001420:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001422:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001424:	00b67d63          	bgeu	a2,a1,8000143e <uvmdealloc+0x26>
    80001428:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000142a:	6785                	lui	a5,0x1
    8000142c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142e:	00f60733          	add	a4,a2,a5
    80001432:	76fd                	lui	a3,0xfffff
    80001434:	8f75                	and	a4,a4,a3
    80001436:	97ae                	add	a5,a5,a1
    80001438:	8ff5                	and	a5,a5,a3
    8000143a:	00f76863          	bltu	a4,a5,8000144a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000143e:	8526                	mv	a0,s1
    80001440:	60e2                	ld	ra,24(sp)
    80001442:	6442                	ld	s0,16(sp)
    80001444:	64a2                	ld	s1,8(sp)
    80001446:	6105                	addi	sp,sp,32
    80001448:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000144a:	8f99                	sub	a5,a5,a4
    8000144c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000144e:	4685                	li	a3,1
    80001450:	0007861b          	sext.w	a2,a5
    80001454:	85ba                	mv	a1,a4
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	e5e080e7          	jalr	-418(ra) # 800012b4 <uvmunmap>
    8000145e:	b7c5                	j	8000143e <uvmdealloc+0x26>

0000000080001460 <uvmalloc>:
  if(newsz < oldsz)
    80001460:	0ab66163          	bltu	a2,a1,80001502 <uvmalloc+0xa2>
{
    80001464:	7139                	addi	sp,sp,-64
    80001466:	fc06                	sd	ra,56(sp)
    80001468:	f822                	sd	s0,48(sp)
    8000146a:	f426                	sd	s1,40(sp)
    8000146c:	f04a                	sd	s2,32(sp)
    8000146e:	ec4e                	sd	s3,24(sp)
    80001470:	e852                	sd	s4,16(sp)
    80001472:	e456                	sd	s5,8(sp)
    80001474:	0080                	addi	s0,sp,64
    80001476:	8aaa                	mv	s5,a0
    80001478:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000147a:	6785                	lui	a5,0x1
    8000147c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000147e:	95be                	add	a1,a1,a5
    80001480:	77fd                	lui	a5,0xfffff
    80001482:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001486:	08c9f063          	bgeu	s3,a2,80001506 <uvmalloc+0xa6>
    8000148a:	894e                	mv	s2,s3
    mem = kalloc();
    8000148c:	fffff097          	auipc	ra,0xfffff
    80001490:	652080e7          	jalr	1618(ra) # 80000ade <kalloc>
    80001494:	84aa                	mv	s1,a0
    if(mem == 0){
    80001496:	c51d                	beqz	a0,800014c4 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001498:	6605                	lui	a2,0x1
    8000149a:	4581                	li	a1,0
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	82e080e7          	jalr	-2002(ra) # 80000cca <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014a4:	4779                	li	a4,30
    800014a6:	86a6                	mv	a3,s1
    800014a8:	6605                	lui	a2,0x1
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	c40080e7          	jalr	-960(ra) # 800010ee <mappages>
    800014b6:	e905                	bnez	a0,800014e6 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014b8:	6785                	lui	a5,0x1
    800014ba:	993e                	add	s2,s2,a5
    800014bc:	fd4968e3          	bltu	s2,s4,8000148c <uvmalloc+0x2c>
  return newsz;
    800014c0:	8552                	mv	a0,s4
    800014c2:	a809                	j	800014d4 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014c4:	864e                	mv	a2,s3
    800014c6:	85ca                	mv	a1,s2
    800014c8:	8556                	mv	a0,s5
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	f4e080e7          	jalr	-178(ra) # 80001418 <uvmdealloc>
      return 0;
    800014d2:	4501                	li	a0,0
}
    800014d4:	70e2                	ld	ra,56(sp)
    800014d6:	7442                	ld	s0,48(sp)
    800014d8:	74a2                	ld	s1,40(sp)
    800014da:	7902                	ld	s2,32(sp)
    800014dc:	69e2                	ld	s3,24(sp)
    800014de:	6a42                	ld	s4,16(sp)
    800014e0:	6aa2                	ld	s5,8(sp)
    800014e2:	6121                	addi	sp,sp,64
    800014e4:	8082                	ret
      kfree(mem);
    800014e6:	8526                	mv	a0,s1
    800014e8:	fffff097          	auipc	ra,0xfffff
    800014ec:	4f8080e7          	jalr	1272(ra) # 800009e0 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014f0:	864e                	mv	a2,s3
    800014f2:	85ca                	mv	a1,s2
    800014f4:	8556                	mv	a0,s5
    800014f6:	00000097          	auipc	ra,0x0
    800014fa:	f22080e7          	jalr	-222(ra) # 80001418 <uvmdealloc>
      return 0;
    800014fe:	4501                	li	a0,0
    80001500:	bfd1                	j	800014d4 <uvmalloc+0x74>
    return oldsz;
    80001502:	852e                	mv	a0,a1
}
    80001504:	8082                	ret
  return newsz;
    80001506:	8532                	mv	a0,a2
    80001508:	b7f1                	j	800014d4 <uvmalloc+0x74>

000000008000150a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000150a:	7179                	addi	sp,sp,-48
    8000150c:	f406                	sd	ra,40(sp)
    8000150e:	f022                	sd	s0,32(sp)
    80001510:	ec26                	sd	s1,24(sp)
    80001512:	e84a                	sd	s2,16(sp)
    80001514:	e44e                	sd	s3,8(sp)
    80001516:	e052                	sd	s4,0(sp)
    80001518:	1800                	addi	s0,sp,48
    8000151a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000151c:	84aa                	mv	s1,a0
    8000151e:	6905                	lui	s2,0x1
    80001520:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001522:	4985                	li	s3,1
    80001524:	a829                	j	8000153e <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001526:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001528:	00c79513          	slli	a0,a5,0xc
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	fde080e7          	jalr	-34(ra) # 8000150a <freewalk>
      pagetable[i] = 0;
    80001534:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001538:	04a1                	addi	s1,s1,8
    8000153a:	03248163          	beq	s1,s2,8000155c <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000153e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001540:	00f7f713          	andi	a4,a5,15
    80001544:	ff3701e3          	beq	a4,s3,80001526 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001548:	8b85                	andi	a5,a5,1
    8000154a:	d7fd                	beqz	a5,80001538 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000154c:	00008517          	auipc	a0,0x8
    80001550:	c4c50513          	addi	a0,a0,-948 # 80009198 <digits+0x158>
    80001554:	fffff097          	auipc	ra,0xfffff
    80001558:	fe4080e7          	jalr	-28(ra) # 80000538 <panic>
    }
  }
  kfree((void*)pagetable);
    8000155c:	8552                	mv	a0,s4
    8000155e:	fffff097          	auipc	ra,0xfffff
    80001562:	482080e7          	jalr	1154(ra) # 800009e0 <kfree>
}
    80001566:	70a2                	ld	ra,40(sp)
    80001568:	7402                	ld	s0,32(sp)
    8000156a:	64e2                	ld	s1,24(sp)
    8000156c:	6942                	ld	s2,16(sp)
    8000156e:	69a2                	ld	s3,8(sp)
    80001570:	6a02                	ld	s4,0(sp)
    80001572:	6145                	addi	sp,sp,48
    80001574:	8082                	ret

0000000080001576 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001576:	1101                	addi	sp,sp,-32
    80001578:	ec06                	sd	ra,24(sp)
    8000157a:	e822                	sd	s0,16(sp)
    8000157c:	e426                	sd	s1,8(sp)
    8000157e:	1000                	addi	s0,sp,32
    80001580:	84aa                	mv	s1,a0
  if(sz > 0)
    80001582:	e999                	bnez	a1,80001598 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001584:	8526                	mv	a0,s1
    80001586:	00000097          	auipc	ra,0x0
    8000158a:	f84080e7          	jalr	-124(ra) # 8000150a <freewalk>
}
    8000158e:	60e2                	ld	ra,24(sp)
    80001590:	6442                	ld	s0,16(sp)
    80001592:	64a2                	ld	s1,8(sp)
    80001594:	6105                	addi	sp,sp,32
    80001596:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001598:	6785                	lui	a5,0x1
    8000159a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000159c:	95be                	add	a1,a1,a5
    8000159e:	4685                	li	a3,1
    800015a0:	00c5d613          	srli	a2,a1,0xc
    800015a4:	4581                	li	a1,0
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	d0e080e7          	jalr	-754(ra) # 800012b4 <uvmunmap>
    800015ae:	bfd9                	j	80001584 <uvmfree+0xe>

00000000800015b0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015b0:	c679                	beqz	a2,8000167e <uvmcopy+0xce>
{
    800015b2:	715d                	addi	sp,sp,-80
    800015b4:	e486                	sd	ra,72(sp)
    800015b6:	e0a2                	sd	s0,64(sp)
    800015b8:	fc26                	sd	s1,56(sp)
    800015ba:	f84a                	sd	s2,48(sp)
    800015bc:	f44e                	sd	s3,40(sp)
    800015be:	f052                	sd	s4,32(sp)
    800015c0:	ec56                	sd	s5,24(sp)
    800015c2:	e85a                	sd	s6,16(sp)
    800015c4:	e45e                	sd	s7,8(sp)
    800015c6:	0880                	addi	s0,sp,80
    800015c8:	8b2a                	mv	s6,a0
    800015ca:	8aae                	mv	s5,a1
    800015cc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015ce:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015d0:	4601                	li	a2,0
    800015d2:	85ce                	mv	a1,s3
    800015d4:	855a                	mv	a0,s6
    800015d6:	00000097          	auipc	ra,0x0
    800015da:	a30080e7          	jalr	-1488(ra) # 80001006 <walk>
    800015de:	c531                	beqz	a0,8000162a <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015e0:	6118                	ld	a4,0(a0)
    800015e2:	00177793          	andi	a5,a4,1
    800015e6:	cbb1                	beqz	a5,8000163a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015e8:	00a75593          	srli	a1,a4,0xa
    800015ec:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015f0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	4ea080e7          	jalr	1258(ra) # 80000ade <kalloc>
    800015fc:	892a                	mv	s2,a0
    800015fe:	c939                	beqz	a0,80001654 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001600:	6605                	lui	a2,0x1
    80001602:	85de                	mv	a1,s7
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	722080e7          	jalr	1826(ra) # 80000d26 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000160c:	8726                	mv	a4,s1
    8000160e:	86ca                	mv	a3,s2
    80001610:	6605                	lui	a2,0x1
    80001612:	85ce                	mv	a1,s3
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	ad8080e7          	jalr	-1320(ra) # 800010ee <mappages>
    8000161e:	e515                	bnez	a0,8000164a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001620:	6785                	lui	a5,0x1
    80001622:	99be                	add	s3,s3,a5
    80001624:	fb49e6e3          	bltu	s3,s4,800015d0 <uvmcopy+0x20>
    80001628:	a081                	j	80001668 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000162a:	00008517          	auipc	a0,0x8
    8000162e:	b7e50513          	addi	a0,a0,-1154 # 800091a8 <digits+0x168>
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	f06080e7          	jalr	-250(ra) # 80000538 <panic>
      panic("uvmcopy: page not present");
    8000163a:	00008517          	auipc	a0,0x8
    8000163e:	b8e50513          	addi	a0,a0,-1138 # 800091c8 <digits+0x188>
    80001642:	fffff097          	auipc	ra,0xfffff
    80001646:	ef6080e7          	jalr	-266(ra) # 80000538 <panic>
      kfree(mem);
    8000164a:	854a                	mv	a0,s2
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	394080e7          	jalr	916(ra) # 800009e0 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001654:	4685                	li	a3,1
    80001656:	00c9d613          	srli	a2,s3,0xc
    8000165a:	4581                	li	a1,0
    8000165c:	8556                	mv	a0,s5
    8000165e:	00000097          	auipc	ra,0x0
    80001662:	c56080e7          	jalr	-938(ra) # 800012b4 <uvmunmap>
  return -1;
    80001666:	557d                	li	a0,-1
}
    80001668:	60a6                	ld	ra,72(sp)
    8000166a:	6406                	ld	s0,64(sp)
    8000166c:	74e2                	ld	s1,56(sp)
    8000166e:	7942                	ld	s2,48(sp)
    80001670:	79a2                	ld	s3,40(sp)
    80001672:	7a02                	ld	s4,32(sp)
    80001674:	6ae2                	ld	s5,24(sp)
    80001676:	6b42                	ld	s6,16(sp)
    80001678:	6ba2                	ld	s7,8(sp)
    8000167a:	6161                	addi	sp,sp,80
    8000167c:	8082                	ret
  return 0;
    8000167e:	4501                	li	a0,0
}
    80001680:	8082                	ret

0000000080001682 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001682:	1141                	addi	sp,sp,-16
    80001684:	e406                	sd	ra,8(sp)
    80001686:	e022                	sd	s0,0(sp)
    80001688:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000168a:	4601                	li	a2,0
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	97a080e7          	jalr	-1670(ra) # 80001006 <walk>
  if(pte == 0)
    80001694:	c901                	beqz	a0,800016a4 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001696:	611c                	ld	a5,0(a0)
    80001698:	9bbd                	andi	a5,a5,-17
    8000169a:	e11c                	sd	a5,0(a0)
}
    8000169c:	60a2                	ld	ra,8(sp)
    8000169e:	6402                	ld	s0,0(sp)
    800016a0:	0141                	addi	sp,sp,16
    800016a2:	8082                	ret
    panic("uvmclear");
    800016a4:	00008517          	auipc	a0,0x8
    800016a8:	b4450513          	addi	a0,a0,-1212 # 800091e8 <digits+0x1a8>
    800016ac:	fffff097          	auipc	ra,0xfffff
    800016b0:	e8c080e7          	jalr	-372(ra) # 80000538 <panic>

00000000800016b4 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016b4:	c6bd                	beqz	a3,80001722 <copyout+0x6e>
{
    800016b6:	715d                	addi	sp,sp,-80
    800016b8:	e486                	sd	ra,72(sp)
    800016ba:	e0a2                	sd	s0,64(sp)
    800016bc:	fc26                	sd	s1,56(sp)
    800016be:	f84a                	sd	s2,48(sp)
    800016c0:	f44e                	sd	s3,40(sp)
    800016c2:	f052                	sd	s4,32(sp)
    800016c4:	ec56                	sd	s5,24(sp)
    800016c6:	e85a                	sd	s6,16(sp)
    800016c8:	e45e                	sd	s7,8(sp)
    800016ca:	e062                	sd	s8,0(sp)
    800016cc:	0880                	addi	s0,sp,80
    800016ce:	8b2a                	mv	s6,a0
    800016d0:	8c2e                	mv	s8,a1
    800016d2:	8a32                	mv	s4,a2
    800016d4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016d6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016d8:	6a85                	lui	s5,0x1
    800016da:	a015                	j	800016fe <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016dc:	9562                	add	a0,a0,s8
    800016de:	0004861b          	sext.w	a2,s1
    800016e2:	85d2                	mv	a1,s4
    800016e4:	41250533          	sub	a0,a0,s2
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	63e080e7          	jalr	1598(ra) # 80000d26 <memmove>

    len -= n;
    800016f0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016f4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016f6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016fa:	02098263          	beqz	s3,8000171e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016fe:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001702:	85ca                	mv	a1,s2
    80001704:	855a                	mv	a0,s6
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	9a6080e7          	jalr	-1626(ra) # 800010ac <walkaddr>
    if(pa0 == 0)
    8000170e:	cd01                	beqz	a0,80001726 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001710:	418904b3          	sub	s1,s2,s8
    80001714:	94d6                	add	s1,s1,s5
    80001716:	fc99f3e3          	bgeu	s3,s1,800016dc <copyout+0x28>
    8000171a:	84ce                	mv	s1,s3
    8000171c:	b7c1                	j	800016dc <copyout+0x28>
  }
  return 0;
    8000171e:	4501                	li	a0,0
    80001720:	a021                	j	80001728 <copyout+0x74>
    80001722:	4501                	li	a0,0
}
    80001724:	8082                	ret
      return -1;
    80001726:	557d                	li	a0,-1
}
    80001728:	60a6                	ld	ra,72(sp)
    8000172a:	6406                	ld	s0,64(sp)
    8000172c:	74e2                	ld	s1,56(sp)
    8000172e:	7942                	ld	s2,48(sp)
    80001730:	79a2                	ld	s3,40(sp)
    80001732:	7a02                	ld	s4,32(sp)
    80001734:	6ae2                	ld	s5,24(sp)
    80001736:	6b42                	ld	s6,16(sp)
    80001738:	6ba2                	ld	s7,8(sp)
    8000173a:	6c02                	ld	s8,0(sp)
    8000173c:	6161                	addi	sp,sp,80
    8000173e:	8082                	ret

0000000080001740 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001740:	caa5                	beqz	a3,800017b0 <copyin+0x70>
{
    80001742:	715d                	addi	sp,sp,-80
    80001744:	e486                	sd	ra,72(sp)
    80001746:	e0a2                	sd	s0,64(sp)
    80001748:	fc26                	sd	s1,56(sp)
    8000174a:	f84a                	sd	s2,48(sp)
    8000174c:	f44e                	sd	s3,40(sp)
    8000174e:	f052                	sd	s4,32(sp)
    80001750:	ec56                	sd	s5,24(sp)
    80001752:	e85a                	sd	s6,16(sp)
    80001754:	e45e                	sd	s7,8(sp)
    80001756:	e062                	sd	s8,0(sp)
    80001758:	0880                	addi	s0,sp,80
    8000175a:	8b2a                	mv	s6,a0
    8000175c:	8a2e                	mv	s4,a1
    8000175e:	8c32                	mv	s8,a2
    80001760:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001762:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001764:	6a85                	lui	s5,0x1
    80001766:	a01d                	j	8000178c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001768:	018505b3          	add	a1,a0,s8
    8000176c:	0004861b          	sext.w	a2,s1
    80001770:	412585b3          	sub	a1,a1,s2
    80001774:	8552                	mv	a0,s4
    80001776:	fffff097          	auipc	ra,0xfffff
    8000177a:	5b0080e7          	jalr	1456(ra) # 80000d26 <memmove>

    len -= n;
    8000177e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001782:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001784:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001788:	02098263          	beqz	s3,800017ac <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000178c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001790:	85ca                	mv	a1,s2
    80001792:	855a                	mv	a0,s6
    80001794:	00000097          	auipc	ra,0x0
    80001798:	918080e7          	jalr	-1768(ra) # 800010ac <walkaddr>
    if(pa0 == 0)
    8000179c:	cd01                	beqz	a0,800017b4 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000179e:	418904b3          	sub	s1,s2,s8
    800017a2:	94d6                	add	s1,s1,s5
    800017a4:	fc99f2e3          	bgeu	s3,s1,80001768 <copyin+0x28>
    800017a8:	84ce                	mv	s1,s3
    800017aa:	bf7d                	j	80001768 <copyin+0x28>
  }
  return 0;
    800017ac:	4501                	li	a0,0
    800017ae:	a021                	j	800017b6 <copyin+0x76>
    800017b0:	4501                	li	a0,0
}
    800017b2:	8082                	ret
      return -1;
    800017b4:	557d                	li	a0,-1
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6c02                	ld	s8,0(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret

00000000800017ce <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017ce:	c2dd                	beqz	a3,80001874 <copyinstr+0xa6>
{
    800017d0:	715d                	addi	sp,sp,-80
    800017d2:	e486                	sd	ra,72(sp)
    800017d4:	e0a2                	sd	s0,64(sp)
    800017d6:	fc26                	sd	s1,56(sp)
    800017d8:	f84a                	sd	s2,48(sp)
    800017da:	f44e                	sd	s3,40(sp)
    800017dc:	f052                	sd	s4,32(sp)
    800017de:	ec56                	sd	s5,24(sp)
    800017e0:	e85a                	sd	s6,16(sp)
    800017e2:	e45e                	sd	s7,8(sp)
    800017e4:	0880                	addi	s0,sp,80
    800017e6:	8a2a                	mv	s4,a0
    800017e8:	8b2e                	mv	s6,a1
    800017ea:	8bb2                	mv	s7,a2
    800017ec:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017ee:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017f0:	6985                	lui	s3,0x1
    800017f2:	a02d                	j	8000181c <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017f4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017f8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017fa:	37fd                	addiw	a5,a5,-1
    800017fc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001800:	60a6                	ld	ra,72(sp)
    80001802:	6406                	ld	s0,64(sp)
    80001804:	74e2                	ld	s1,56(sp)
    80001806:	7942                	ld	s2,48(sp)
    80001808:	79a2                	ld	s3,40(sp)
    8000180a:	7a02                	ld	s4,32(sp)
    8000180c:	6ae2                	ld	s5,24(sp)
    8000180e:	6b42                	ld	s6,16(sp)
    80001810:	6ba2                	ld	s7,8(sp)
    80001812:	6161                	addi	sp,sp,80
    80001814:	8082                	ret
    srcva = va0 + PGSIZE;
    80001816:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000181a:	c8a9                	beqz	s1,8000186c <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000181c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001820:	85ca                	mv	a1,s2
    80001822:	8552                	mv	a0,s4
    80001824:	00000097          	auipc	ra,0x0
    80001828:	888080e7          	jalr	-1912(ra) # 800010ac <walkaddr>
    if(pa0 == 0)
    8000182c:	c131                	beqz	a0,80001870 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000182e:	417906b3          	sub	a3,s2,s7
    80001832:	96ce                	add	a3,a3,s3
    80001834:	00d4f363          	bgeu	s1,a3,8000183a <copyinstr+0x6c>
    80001838:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000183a:	955e                	add	a0,a0,s7
    8000183c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001840:	daf9                	beqz	a3,80001816 <copyinstr+0x48>
    80001842:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001844:	41650633          	sub	a2,a0,s6
    80001848:	fff48593          	addi	a1,s1,-1
    8000184c:	95da                	add	a1,a1,s6
    while(n > 0){
    8000184e:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001850:	00f60733          	add	a4,a2,a5
    80001854:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd6000>
    80001858:	df51                	beqz	a4,800017f4 <copyinstr+0x26>
        *dst = *p;
    8000185a:	00e78023          	sb	a4,0(a5)
      --max;
    8000185e:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001862:	0785                	addi	a5,a5,1
    while(n > 0){
    80001864:	fed796e3          	bne	a5,a3,80001850 <copyinstr+0x82>
      dst++;
    80001868:	8b3e                	mv	s6,a5
    8000186a:	b775                	j	80001816 <copyinstr+0x48>
    8000186c:	4781                	li	a5,0
    8000186e:	b771                	j	800017fa <copyinstr+0x2c>
      return -1;
    80001870:	557d                	li	a0,-1
    80001872:	b779                	j	80001800 <copyinstr+0x32>
  int got_null = 0;
    80001874:	4781                	li	a5,0
  if(got_null){
    80001876:	37fd                	addiw	a5,a5,-1
    80001878:	0007851b          	sext.w	a0,a5
}
    8000187c:	8082                	ret

000000008000187e <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000187e:	7139                	addi	sp,sp,-64
    80001880:	fc06                	sd	ra,56(sp)
    80001882:	f822                	sd	s0,48(sp)
    80001884:	f426                	sd	s1,40(sp)
    80001886:	f04a                	sd	s2,32(sp)
    80001888:	ec4e                	sd	s3,24(sp)
    8000188a:	e852                	sd	s4,16(sp)
    8000188c:	e456                	sd	s5,8(sp)
    8000188e:	e05a                	sd	s6,0(sp)
    80001890:	0080                	addi	s0,sp,64
    80001892:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001894:	00011497          	auipc	s1,0x11
    80001898:	e7c48493          	addi	s1,s1,-388 # 80012710 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000189c:	8b26                	mv	s6,s1
    8000189e:	00007a97          	auipc	s5,0x7
    800018a2:	762a8a93          	addi	s5,s5,1890 # 80009000 <etext>
    800018a6:	04000937          	lui	s2,0x4000
    800018aa:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800018ac:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ae:	00017a17          	auipc	s4,0x17
    800018b2:	262a0a13          	addi	s4,s4,610 # 80018b10 <tickslock>
    char *pa = kalloc();
    800018b6:	fffff097          	auipc	ra,0xfffff
    800018ba:	228080e7          	jalr	552(ra) # 80000ade <kalloc>
    800018be:	862a                	mv	a2,a0
    if(pa == 0)
    800018c0:	c131                	beqz	a0,80001904 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018c2:	416485b3          	sub	a1,s1,s6
    800018c6:	8591                	srai	a1,a1,0x4
    800018c8:	000ab783          	ld	a5,0(s5)
    800018cc:	02f585b3          	mul	a1,a1,a5
    800018d0:	2585                	addiw	a1,a1,1
    800018d2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018d6:	4719                	li	a4,6
    800018d8:	6685                	lui	a3,0x1
    800018da:	40b905b3          	sub	a1,s2,a1
    800018de:	854e                	mv	a0,s3
    800018e0:	00000097          	auipc	ra,0x0
    800018e4:	8ae080e7          	jalr	-1874(ra) # 8000118e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e8:	19048493          	addi	s1,s1,400
    800018ec:	fd4495e3          	bne	s1,s4,800018b6 <proc_mapstacks+0x38>
  }
}
    800018f0:	70e2                	ld	ra,56(sp)
    800018f2:	7442                	ld	s0,48(sp)
    800018f4:	74a2                	ld	s1,40(sp)
    800018f6:	7902                	ld	s2,32(sp)
    800018f8:	69e2                	ld	s3,24(sp)
    800018fa:	6a42                	ld	s4,16(sp)
    800018fc:	6aa2                	ld	s5,8(sp)
    800018fe:	6b02                	ld	s6,0(sp)
    80001900:	6121                	addi	sp,sp,64
    80001902:	8082                	ret
      panic("kalloc");
    80001904:	00008517          	auipc	a0,0x8
    80001908:	8f450513          	addi	a0,a0,-1804 # 800091f8 <digits+0x1b8>
    8000190c:	fffff097          	auipc	ra,0xfffff
    80001910:	c2c080e7          	jalr	-980(ra) # 80000538 <panic>

0000000080001914 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001914:	7139                	addi	sp,sp,-64
    80001916:	fc06                	sd	ra,56(sp)
    80001918:	f822                	sd	s0,48(sp)
    8000191a:	f426                	sd	s1,40(sp)
    8000191c:	f04a                	sd	s2,32(sp)
    8000191e:	ec4e                	sd	s3,24(sp)
    80001920:	e852                	sd	s4,16(sp)
    80001922:	e456                	sd	s5,8(sp)
    80001924:	e05a                	sd	s6,0(sp)
    80001926:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001928:	00008597          	auipc	a1,0x8
    8000192c:	8d858593          	addi	a1,a1,-1832 # 80009200 <digits+0x1c0>
    80001930:	00011517          	auipc	a0,0x11
    80001934:	9b050513          	addi	a0,a0,-1616 # 800122e0 <pid_lock>
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	206080e7          	jalr	518(ra) # 80000b3e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001940:	00008597          	auipc	a1,0x8
    80001944:	8c858593          	addi	a1,a1,-1848 # 80009208 <digits+0x1c8>
    80001948:	00011517          	auipc	a0,0x11
    8000194c:	9b050513          	addi	a0,a0,-1616 # 800122f8 <wait_lock>
    80001950:	fffff097          	auipc	ra,0xfffff
    80001954:	1ee080e7          	jalr	494(ra) # 80000b3e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001958:	00011497          	auipc	s1,0x11
    8000195c:	db848493          	addi	s1,s1,-584 # 80012710 <proc>
      initlock(&p->lock, "proc");
    80001960:	00008b17          	auipc	s6,0x8
    80001964:	8b8b0b13          	addi	s6,s6,-1864 # 80009218 <digits+0x1d8>
      p->kstack = KSTACK((int) (p - proc));
    80001968:	8aa6                	mv	s5,s1
    8000196a:	00007a17          	auipc	s4,0x7
    8000196e:	696a0a13          	addi	s4,s4,1686 # 80009000 <etext>
    80001972:	04000937          	lui	s2,0x4000
    80001976:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001978:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197a:	00017997          	auipc	s3,0x17
    8000197e:	19698993          	addi	s3,s3,406 # 80018b10 <tickslock>
      initlock(&p->lock, "proc");
    80001982:	85da                	mv	a1,s6
    80001984:	8526                	mv	a0,s1
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	1b8080e7          	jalr	440(ra) # 80000b3e <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000198e:	415487b3          	sub	a5,s1,s5
    80001992:	8791                	srai	a5,a5,0x4
    80001994:	000a3703          	ld	a4,0(s4)
    80001998:	02e787b3          	mul	a5,a5,a4
    8000199c:	2785                	addiw	a5,a5,1
    8000199e:	00d7979b          	slliw	a5,a5,0xd
    800019a2:	40f907b3          	sub	a5,s2,a5
    800019a6:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a8:	19048493          	addi	s1,s1,400
    800019ac:	fd349be3          	bne	s1,s3,80001982 <procinit+0x6e>
  }
}
    800019b0:	70e2                	ld	ra,56(sp)
    800019b2:	7442                	ld	s0,48(sp)
    800019b4:	74a2                	ld	s1,40(sp)
    800019b6:	7902                	ld	s2,32(sp)
    800019b8:	69e2                	ld	s3,24(sp)
    800019ba:	6a42                	ld	s4,16(sp)
    800019bc:	6aa2                	ld	s5,8(sp)
    800019be:	6b02                	ld	s6,0(sp)
    800019c0:	6121                	addi	sp,sp,64
    800019c2:	8082                	ret

00000000800019c4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019c4:	1141                	addi	sp,sp,-16
    800019c6:	e422                	sd	s0,8(sp)
    800019c8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019ca:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019cc:	2501                	sext.w	a0,a0
    800019ce:	6422                	ld	s0,8(sp)
    800019d0:	0141                	addi	sp,sp,16
    800019d2:	8082                	ret

00000000800019d4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    800019d4:	1141                	addi	sp,sp,-16
    800019d6:	e422                	sd	s0,8(sp)
    800019d8:	0800                	addi	s0,sp,16
    800019da:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019dc:	2781                	sext.w	a5,a5
    800019de:	079e                	slli	a5,a5,0x7
  return c;
}
    800019e0:	00011517          	auipc	a0,0x11
    800019e4:	93050513          	addi	a0,a0,-1744 # 80012310 <cpus>
    800019e8:	953e                	add	a0,a0,a5
    800019ea:	6422                	ld	s0,8(sp)
    800019ec:	0141                	addi	sp,sp,16
    800019ee:	8082                	ret

00000000800019f0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019f0:	1101                	addi	sp,sp,-32
    800019f2:	ec06                	sd	ra,24(sp)
    800019f4:	e822                	sd	s0,16(sp)
    800019f6:	e426                	sd	s1,8(sp)
    800019f8:	1000                	addi	s0,sp,32
  push_off();
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	188080e7          	jalr	392(ra) # 80000b82 <push_off>
    80001a02:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a04:	2781                	sext.w	a5,a5
    80001a06:	079e                	slli	a5,a5,0x7
    80001a08:	00011717          	auipc	a4,0x11
    80001a0c:	8d870713          	addi	a4,a4,-1832 # 800122e0 <pid_lock>
    80001a10:	97ba                	add	a5,a5,a4
    80001a12:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a14:	fffff097          	auipc	ra,0xfffff
    80001a18:	20e080e7          	jalr	526(ra) # 80000c22 <pop_off>
  return p;
}
    80001a1c:	8526                	mv	a0,s1
    80001a1e:	60e2                	ld	ra,24(sp)
    80001a20:	6442                	ld	s0,16(sp)
    80001a22:	64a2                	ld	s1,8(sp)
    80001a24:	6105                	addi	sp,sp,32
    80001a26:	8082                	ret

0000000080001a28 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a28:	1101                	addi	sp,sp,-32
    80001a2a:	ec06                	sd	ra,24(sp)
    80001a2c:	e822                	sd	s0,16(sp)
    80001a2e:	e426                	sd	s1,8(sp)
    80001a30:	1000                	addi	s0,sp,32
  static int first = 1;
  uint xticks;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a32:	00000097          	auipc	ra,0x0
    80001a36:	fbe080e7          	jalr	-66(ra) # 800019f0 <myproc>
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	248080e7          	jalr	584(ra) # 80000c82 <release>

  acquire(&tickslock);
    80001a42:	00017517          	auipc	a0,0x17
    80001a46:	0ce50513          	addi	a0,a0,206 # 80018b10 <tickslock>
    80001a4a:	fffff097          	auipc	ra,0xfffff
    80001a4e:	184080e7          	jalr	388(ra) # 80000bce <acquire>
  xticks = ticks;
    80001a52:	00008497          	auipc	s1,0x8
    80001a56:	61a4a483          	lw	s1,1562(s1) # 8000a06c <ticks>
  release(&tickslock);
    80001a5a:	00017517          	auipc	a0,0x17
    80001a5e:	0b650513          	addi	a0,a0,182 # 80018b10 <tickslock>
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	220080e7          	jalr	544(ra) # 80000c82 <release>

  myproc()->stime = xticks;
    80001a6a:	00000097          	auipc	ra,0x0
    80001a6e:	f86080e7          	jalr	-122(ra) # 800019f0 <myproc>
    80001a72:	16952a23          	sw	s1,372(a0)

  if (first) {
    80001a76:	00008797          	auipc	a5,0x8
    80001a7a:	15a7a783          	lw	a5,346(a5) # 80009bd0 <first.3>
    80001a7e:	eb91                	bnez	a5,80001a92 <forkret+0x6a>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a80:	00002097          	auipc	ra,0x2
    80001a84:	ec2080e7          	jalr	-318(ra) # 80003942 <usertrapret>
}
    80001a88:	60e2                	ld	ra,24(sp)
    80001a8a:	6442                	ld	s0,16(sp)
    80001a8c:	64a2                	ld	s1,8(sp)
    80001a8e:	6105                	addi	sp,sp,32
    80001a90:	8082                	ret
    first = 0;
    80001a92:	00008797          	auipc	a5,0x8
    80001a96:	1207af23          	sw	zero,318(a5) # 80009bd0 <first.3>
    fsinit(ROOTDEV);
    80001a9a:	4505                	li	a0,1
    80001a9c:	00003097          	auipc	ra,0x3
    80001aa0:	4da080e7          	jalr	1242(ra) # 80004f76 <fsinit>
    80001aa4:	bff1                	j	80001a80 <forkret+0x58>

0000000080001aa6 <allocpid>:
allocpid() {
    80001aa6:	1101                	addi	sp,sp,-32
    80001aa8:	ec06                	sd	ra,24(sp)
    80001aaa:	e822                	sd	s0,16(sp)
    80001aac:	e426                	sd	s1,8(sp)
    80001aae:	e04a                	sd	s2,0(sp)
    80001ab0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ab2:	00011917          	auipc	s2,0x11
    80001ab6:	82e90913          	addi	s2,s2,-2002 # 800122e0 <pid_lock>
    80001aba:	854a                	mv	a0,s2
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	112080e7          	jalr	274(ra) # 80000bce <acquire>
  pid = nextpid;
    80001ac4:	00008797          	auipc	a5,0x8
    80001ac8:	12078793          	addi	a5,a5,288 # 80009be4 <nextpid>
    80001acc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ace:	0014871b          	addiw	a4,s1,1
    80001ad2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ad4:	854a                	mv	a0,s2
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	1ac080e7          	jalr	428(ra) # 80000c82 <release>
}
    80001ade:	8526                	mv	a0,s1
    80001ae0:	60e2                	ld	ra,24(sp)
    80001ae2:	6442                	ld	s0,16(sp)
    80001ae4:	64a2                	ld	s1,8(sp)
    80001ae6:	6902                	ld	s2,0(sp)
    80001ae8:	6105                	addi	sp,sp,32
    80001aea:	8082                	ret

0000000080001aec <proc_pagetable>:
{
    80001aec:	1101                	addi	sp,sp,-32
    80001aee:	ec06                	sd	ra,24(sp)
    80001af0:	e822                	sd	s0,16(sp)
    80001af2:	e426                	sd	s1,8(sp)
    80001af4:	e04a                	sd	s2,0(sp)
    80001af6:	1000                	addi	s0,sp,32
    80001af8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	87e080e7          	jalr	-1922(ra) # 80001378 <uvmcreate>
    80001b02:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b04:	c121                	beqz	a0,80001b44 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b06:	4729                	li	a4,10
    80001b08:	00006697          	auipc	a3,0x6
    80001b0c:	4f868693          	addi	a3,a3,1272 # 80008000 <_trampoline>
    80001b10:	6605                	lui	a2,0x1
    80001b12:	040005b7          	lui	a1,0x4000
    80001b16:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b18:	05b2                	slli	a1,a1,0xc
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	5d4080e7          	jalr	1492(ra) # 800010ee <mappages>
    80001b22:	02054863          	bltz	a0,80001b52 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b26:	4719                	li	a4,6
    80001b28:	06093683          	ld	a3,96(s2)
    80001b2c:	6605                	lui	a2,0x1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	slli	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	5b6080e7          	jalr	1462(ra) # 800010ee <mappages>
    80001b40:	02054163          	bltz	a0,80001b62 <proc_pagetable+0x76>
}
    80001b44:	8526                	mv	a0,s1
    80001b46:	60e2                	ld	ra,24(sp)
    80001b48:	6442                	ld	s0,16(sp)
    80001b4a:	64a2                	ld	s1,8(sp)
    80001b4c:	6902                	ld	s2,0(sp)
    80001b4e:	6105                	addi	sp,sp,32
    80001b50:	8082                	ret
    uvmfree(pagetable, 0);
    80001b52:	4581                	li	a1,0
    80001b54:	8526                	mv	a0,s1
    80001b56:	00000097          	auipc	ra,0x0
    80001b5a:	a20080e7          	jalr	-1504(ra) # 80001576 <uvmfree>
    return 0;
    80001b5e:	4481                	li	s1,0
    80001b60:	b7d5                	j	80001b44 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b62:	4681                	li	a3,0
    80001b64:	4605                	li	a2,1
    80001b66:	040005b7          	lui	a1,0x4000
    80001b6a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b6c:	05b2                	slli	a1,a1,0xc
    80001b6e:	8526                	mv	a0,s1
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	744080e7          	jalr	1860(ra) # 800012b4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b78:	4581                	li	a1,0
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	00000097          	auipc	ra,0x0
    80001b80:	9fa080e7          	jalr	-1542(ra) # 80001576 <uvmfree>
    return 0;
    80001b84:	4481                	li	s1,0
    80001b86:	bf7d                	j	80001b44 <proc_pagetable+0x58>

0000000080001b88 <proc_freepagetable>:
{
    80001b88:	1101                	addi	sp,sp,-32
    80001b8a:	ec06                	sd	ra,24(sp)
    80001b8c:	e822                	sd	s0,16(sp)
    80001b8e:	e426                	sd	s1,8(sp)
    80001b90:	e04a                	sd	s2,0(sp)
    80001b92:	1000                	addi	s0,sp,32
    80001b94:	84aa                	mv	s1,a0
    80001b96:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b98:	4681                	li	a3,0
    80001b9a:	4605                	li	a2,1
    80001b9c:	040005b7          	lui	a1,0x4000
    80001ba0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ba2:	05b2                	slli	a1,a1,0xc
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	710080e7          	jalr	1808(ra) # 800012b4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bac:	4681                	li	a3,0
    80001bae:	4605                	li	a2,1
    80001bb0:	020005b7          	lui	a1,0x2000
    80001bb4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bb6:	05b6                	slli	a1,a1,0xd
    80001bb8:	8526                	mv	a0,s1
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	6fa080e7          	jalr	1786(ra) # 800012b4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bc2:	85ca                	mv	a1,s2
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	9b0080e7          	jalr	-1616(ra) # 80001576 <uvmfree>
}
    80001bce:	60e2                	ld	ra,24(sp)
    80001bd0:	6442                	ld	s0,16(sp)
    80001bd2:	64a2                	ld	s1,8(sp)
    80001bd4:	6902                	ld	s2,0(sp)
    80001bd6:	6105                	addi	sp,sp,32
    80001bd8:	8082                	ret

0000000080001bda <freeproc>:
{
    80001bda:	1101                	addi	sp,sp,-32
    80001bdc:	ec06                	sd	ra,24(sp)
    80001bde:	e822                	sd	s0,16(sp)
    80001be0:	e426                	sd	s1,8(sp)
    80001be2:	1000                	addi	s0,sp,32
    80001be4:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001be6:	7128                	ld	a0,96(a0)
    80001be8:	c509                	beqz	a0,80001bf2 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bea:	fffff097          	auipc	ra,0xfffff
    80001bee:	df6080e7          	jalr	-522(ra) # 800009e0 <kfree>
  p->trapframe = 0;
    80001bf2:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001bf6:	6ca8                	ld	a0,88(s1)
    80001bf8:	c511                	beqz	a0,80001c04 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bfa:	68ac                	ld	a1,80(s1)
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	f8c080e7          	jalr	-116(ra) # 80001b88 <proc_freepagetable>
  p->pagetable = 0;
    80001c04:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001c08:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001c0c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c10:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001c14:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001c18:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c1c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c20:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c24:	0004ac23          	sw	zero,24(s1)
}
    80001c28:	60e2                	ld	ra,24(sp)
    80001c2a:	6442                	ld	s0,16(sp)
    80001c2c:	64a2                	ld	s1,8(sp)
    80001c2e:	6105                	addi	sp,sp,32
    80001c30:	8082                	ret

0000000080001c32 <allocproc>:
{
    80001c32:	1101                	addi	sp,sp,-32
    80001c34:	ec06                	sd	ra,24(sp)
    80001c36:	e822                	sd	s0,16(sp)
    80001c38:	e426                	sd	s1,8(sp)
    80001c3a:	e04a                	sd	s2,0(sp)
    80001c3c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c3e:	00011497          	auipc	s1,0x11
    80001c42:	ad248493          	addi	s1,s1,-1326 # 80012710 <proc>
    80001c46:	00017917          	auipc	s2,0x17
    80001c4a:	eca90913          	addi	s2,s2,-310 # 80018b10 <tickslock>
    acquire(&p->lock);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	f7e080e7          	jalr	-130(ra) # 80000bce <acquire>
    if(p->state == UNUSED) {
    80001c58:	4c9c                	lw	a5,24(s1)
    80001c5a:	cf81                	beqz	a5,80001c72 <allocproc+0x40>
      release(&p->lock);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	fffff097          	auipc	ra,0xfffff
    80001c62:	024080e7          	jalr	36(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c66:	19048493          	addi	s1,s1,400
    80001c6a:	ff2492e3          	bne	s1,s2,80001c4e <allocproc+0x1c>
  return 0;
    80001c6e:	4481                	li	s1,0
    80001c70:	a841                	j	80001d00 <allocproc+0xce>
  p->pid = allocpid();
    80001c72:	00000097          	auipc	ra,0x0
    80001c76:	e34080e7          	jalr	-460(ra) # 80001aa6 <allocpid>
    80001c7a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c7c:	4785                	li	a5,1
    80001c7e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	e5e080e7          	jalr	-418(ra) # 80000ade <kalloc>
    80001c88:	892a                	mv	s2,a0
    80001c8a:	f0a8                	sd	a0,96(s1)
    80001c8c:	c149                	beqz	a0,80001d0e <allocproc+0xdc>
  p->pagetable = proc_pagetable(p);
    80001c8e:	8526                	mv	a0,s1
    80001c90:	00000097          	auipc	ra,0x0
    80001c94:	e5c080e7          	jalr	-420(ra) # 80001aec <proc_pagetable>
    80001c98:	892a                	mv	s2,a0
    80001c9a:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001c9c:	c549                	beqz	a0,80001d26 <allocproc+0xf4>
  memset(&p->context, 0, sizeof(p->context));
    80001c9e:	07000613          	li	a2,112
    80001ca2:	4581                	li	a1,0
    80001ca4:	06848513          	addi	a0,s1,104
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	022080e7          	jalr	34(ra) # 80000cca <memset>
  p->context.ra = (uint64)forkret;
    80001cb0:	00000797          	auipc	a5,0x0
    80001cb4:	d7878793          	addi	a5,a5,-648 # 80001a28 <forkret>
    80001cb8:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cba:	64bc                	ld	a5,72(s1)
    80001cbc:	6705                	lui	a4,0x1
    80001cbe:	97ba                	add	a5,a5,a4
    80001cc0:	f8bc                	sd	a5,112(s1)
  acquire(&tickslock);
    80001cc2:	00017517          	auipc	a0,0x17
    80001cc6:	e4e50513          	addi	a0,a0,-434 # 80018b10 <tickslock>
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	f04080e7          	jalr	-252(ra) # 80000bce <acquire>
  xticks = ticks;
    80001cd2:	00008917          	auipc	s2,0x8
    80001cd6:	39a92903          	lw	s2,922(s2) # 8000a06c <ticks>
  release(&tickslock);
    80001cda:	00017517          	auipc	a0,0x17
    80001cde:	e3650513          	addi	a0,a0,-458 # 80018b10 <tickslock>
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	fa0080e7          	jalr	-96(ra) # 80000c82 <release>
  p->ctime = xticks;
    80001cea:	1724a823          	sw	s2,368(s1)
  p->stime = -1;
    80001cee:	57fd                	li	a5,-1
    80001cf0:	16f4aa23          	sw	a5,372(s1)
  p->endtime = -1;
    80001cf4:	16f4ac23          	sw	a5,376(s1)
  p->is_batchproc = 0;
    80001cf8:	0204ae23          	sw	zero,60(s1)
  p->cpu_usage = 0;
    80001cfc:	1804a623          	sw	zero,396(s1)
}
    80001d00:	8526                	mv	a0,s1
    80001d02:	60e2                	ld	ra,24(sp)
    80001d04:	6442                	ld	s0,16(sp)
    80001d06:	64a2                	ld	s1,8(sp)
    80001d08:	6902                	ld	s2,0(sp)
    80001d0a:	6105                	addi	sp,sp,32
    80001d0c:	8082                	ret
    freeproc(p);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	00000097          	auipc	ra,0x0
    80001d14:	eca080e7          	jalr	-310(ra) # 80001bda <freeproc>
    release(&p->lock);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	f68080e7          	jalr	-152(ra) # 80000c82 <release>
    return 0;
    80001d22:	84ca                	mv	s1,s2
    80001d24:	bff1                	j	80001d00 <allocproc+0xce>
    freeproc(p);
    80001d26:	8526                	mv	a0,s1
    80001d28:	00000097          	auipc	ra,0x0
    80001d2c:	eb2080e7          	jalr	-334(ra) # 80001bda <freeproc>
    release(&p->lock);
    80001d30:	8526                	mv	a0,s1
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	f50080e7          	jalr	-176(ra) # 80000c82 <release>
    return 0;
    80001d3a:	84ca                	mv	s1,s2
    80001d3c:	b7d1                	j	80001d00 <allocproc+0xce>

0000000080001d3e <userinit>:
{
    80001d3e:	1101                	addi	sp,sp,-32
    80001d40:	ec06                	sd	ra,24(sp)
    80001d42:	e822                	sd	s0,16(sp)
    80001d44:	e426                	sd	s1,8(sp)
    80001d46:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	eea080e7          	jalr	-278(ra) # 80001c32 <allocproc>
    80001d50:	84aa                	mv	s1,a0
  initproc = p;
    80001d52:	00008797          	auipc	a5,0x8
    80001d56:	30a7b723          	sd	a0,782(a5) # 8000a060 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d5a:	03400613          	li	a2,52
    80001d5e:	00008597          	auipc	a1,0x8
    80001d62:	e9258593          	addi	a1,a1,-366 # 80009bf0 <initcode>
    80001d66:	6d28                	ld	a0,88(a0)
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	63e080e7          	jalr	1598(ra) # 800013a6 <uvminit>
  p->sz = PGSIZE;
    80001d70:	6785                	lui	a5,0x1
    80001d72:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d74:	70b8                	ld	a4,96(s1)
    80001d76:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d7a:	70b8                	ld	a4,96(s1)
    80001d7c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d7e:	4641                	li	a2,16
    80001d80:	00007597          	auipc	a1,0x7
    80001d84:	4a058593          	addi	a1,a1,1184 # 80009220 <digits+0x1e0>
    80001d88:	16048513          	addi	a0,s1,352
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	088080e7          	jalr	136(ra) # 80000e14 <safestrcpy>
  p->cwd = namei("/");
    80001d94:	00007517          	auipc	a0,0x7
    80001d98:	49c50513          	addi	a0,a0,1180 # 80009230 <digits+0x1f0>
    80001d9c:	00004097          	auipc	ra,0x4
    80001da0:	c10080e7          	jalr	-1008(ra) # 800059ac <namei>
    80001da4:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001da8:	478d                	li	a5,3
    80001daa:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dac:	8526                	mv	a0,s1
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	ed4080e7          	jalr	-300(ra) # 80000c82 <release>
}
    80001db6:	60e2                	ld	ra,24(sp)
    80001db8:	6442                	ld	s0,16(sp)
    80001dba:	64a2                	ld	s1,8(sp)
    80001dbc:	6105                	addi	sp,sp,32
    80001dbe:	8082                	ret

0000000080001dc0 <growproc>:
{
    80001dc0:	1101                	addi	sp,sp,-32
    80001dc2:	ec06                	sd	ra,24(sp)
    80001dc4:	e822                	sd	s0,16(sp)
    80001dc6:	e426                	sd	s1,8(sp)
    80001dc8:	e04a                	sd	s2,0(sp)
    80001dca:	1000                	addi	s0,sp,32
    80001dcc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	c22080e7          	jalr	-990(ra) # 800019f0 <myproc>
    80001dd6:	892a                	mv	s2,a0
  sz = p->sz;
    80001dd8:	692c                	ld	a1,80(a0)
    80001dda:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001dde:	00904f63          	bgtz	s1,80001dfc <growproc+0x3c>
  } else if(n < 0){
    80001de2:	0204cd63          	bltz	s1,80001e1c <growproc+0x5c>
  p->sz = sz;
    80001de6:	1782                	slli	a5,a5,0x20
    80001de8:	9381                	srli	a5,a5,0x20
    80001dea:	04f93823          	sd	a5,80(s2)
  return 0;
    80001dee:	4501                	li	a0,0
}
    80001df0:	60e2                	ld	ra,24(sp)
    80001df2:	6442                	ld	s0,16(sp)
    80001df4:	64a2                	ld	s1,8(sp)
    80001df6:	6902                	ld	s2,0(sp)
    80001df8:	6105                	addi	sp,sp,32
    80001dfa:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dfc:	00f4863b          	addw	a2,s1,a5
    80001e00:	1602                	slli	a2,a2,0x20
    80001e02:	9201                	srli	a2,a2,0x20
    80001e04:	1582                	slli	a1,a1,0x20
    80001e06:	9181                	srli	a1,a1,0x20
    80001e08:	6d28                	ld	a0,88(a0)
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	656080e7          	jalr	1622(ra) # 80001460 <uvmalloc>
    80001e12:	0005079b          	sext.w	a5,a0
    80001e16:	fbe1                	bnez	a5,80001de6 <growproc+0x26>
      return -1;
    80001e18:	557d                	li	a0,-1
    80001e1a:	bfd9                	j	80001df0 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e1c:	00f4863b          	addw	a2,s1,a5
    80001e20:	1602                	slli	a2,a2,0x20
    80001e22:	9201                	srli	a2,a2,0x20
    80001e24:	1582                	slli	a1,a1,0x20
    80001e26:	9181                	srli	a1,a1,0x20
    80001e28:	6d28                	ld	a0,88(a0)
    80001e2a:	fffff097          	auipc	ra,0xfffff
    80001e2e:	5ee080e7          	jalr	1518(ra) # 80001418 <uvmdealloc>
    80001e32:	0005079b          	sext.w	a5,a0
    80001e36:	bf45                	j	80001de6 <growproc+0x26>

0000000080001e38 <fork>:
{
    80001e38:	7139                	addi	sp,sp,-64
    80001e3a:	fc06                	sd	ra,56(sp)
    80001e3c:	f822                	sd	s0,48(sp)
    80001e3e:	f426                	sd	s1,40(sp)
    80001e40:	f04a                	sd	s2,32(sp)
    80001e42:	ec4e                	sd	s3,24(sp)
    80001e44:	e852                	sd	s4,16(sp)
    80001e46:	e456                	sd	s5,8(sp)
    80001e48:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e4a:	00000097          	auipc	ra,0x0
    80001e4e:	ba6080e7          	jalr	-1114(ra) # 800019f0 <myproc>
    80001e52:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e54:	00000097          	auipc	ra,0x0
    80001e58:	dde080e7          	jalr	-546(ra) # 80001c32 <allocproc>
    80001e5c:	10050c63          	beqz	a0,80001f74 <fork+0x13c>
    80001e60:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e62:	050ab603          	ld	a2,80(s5)
    80001e66:	6d2c                	ld	a1,88(a0)
    80001e68:	058ab503          	ld	a0,88(s5)
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	744080e7          	jalr	1860(ra) # 800015b0 <uvmcopy>
    80001e74:	04054863          	bltz	a0,80001ec4 <fork+0x8c>
  np->sz = p->sz;
    80001e78:	050ab783          	ld	a5,80(s5)
    80001e7c:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e80:	060ab683          	ld	a3,96(s5)
    80001e84:	87b6                	mv	a5,a3
    80001e86:	060a3703          	ld	a4,96(s4)
    80001e8a:	12068693          	addi	a3,a3,288
    80001e8e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e92:	6788                	ld	a0,8(a5)
    80001e94:	6b8c                	ld	a1,16(a5)
    80001e96:	6f90                	ld	a2,24(a5)
    80001e98:	01073023          	sd	a6,0(a4)
    80001e9c:	e708                	sd	a0,8(a4)
    80001e9e:	eb0c                	sd	a1,16(a4)
    80001ea0:	ef10                	sd	a2,24(a4)
    80001ea2:	02078793          	addi	a5,a5,32
    80001ea6:	02070713          	addi	a4,a4,32
    80001eaa:	fed792e3          	bne	a5,a3,80001e8e <fork+0x56>
  np->trapframe->a0 = 0;
    80001eae:	060a3783          	ld	a5,96(s4)
    80001eb2:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001eb6:	0d8a8493          	addi	s1,s5,216
    80001eba:	0d8a0913          	addi	s2,s4,216
    80001ebe:	158a8993          	addi	s3,s5,344
    80001ec2:	a00d                	j	80001ee4 <fork+0xac>
    freeproc(np);
    80001ec4:	8552                	mv	a0,s4
    80001ec6:	00000097          	auipc	ra,0x0
    80001eca:	d14080e7          	jalr	-748(ra) # 80001bda <freeproc>
    release(&np->lock);
    80001ece:	8552                	mv	a0,s4
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	db2080e7          	jalr	-590(ra) # 80000c82 <release>
    return -1;
    80001ed8:	597d                	li	s2,-1
    80001eda:	a059                	j	80001f60 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001edc:	04a1                	addi	s1,s1,8
    80001ede:	0921                	addi	s2,s2,8
    80001ee0:	01348b63          	beq	s1,s3,80001ef6 <fork+0xbe>
    if(p->ofile[i])
    80001ee4:	6088                	ld	a0,0(s1)
    80001ee6:	d97d                	beqz	a0,80001edc <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ee8:	00004097          	auipc	ra,0x4
    80001eec:	15a080e7          	jalr	346(ra) # 80006042 <filedup>
    80001ef0:	00a93023          	sd	a0,0(s2)
    80001ef4:	b7e5                	j	80001edc <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ef6:	158ab503          	ld	a0,344(s5)
    80001efa:	00003097          	auipc	ra,0x3
    80001efe:	2b8080e7          	jalr	696(ra) # 800051b2 <idup>
    80001f02:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f06:	4641                	li	a2,16
    80001f08:	160a8593          	addi	a1,s5,352
    80001f0c:	160a0513          	addi	a0,s4,352
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	f04080e7          	jalr	-252(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    80001f18:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f1c:	8552                	mv	a0,s4
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	d64080e7          	jalr	-668(ra) # 80000c82 <release>
  acquire(&wait_lock);
    80001f26:	00010497          	auipc	s1,0x10
    80001f2a:	3d248493          	addi	s1,s1,978 # 800122f8 <wait_lock>
    80001f2e:	8526                	mv	a0,s1
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	c9e080e7          	jalr	-866(ra) # 80000bce <acquire>
  np->parent = p;
    80001f38:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	d44080e7          	jalr	-700(ra) # 80000c82 <release>
  acquire(&np->lock);
    80001f46:	8552                	mv	a0,s4
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	c86080e7          	jalr	-890(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    80001f50:	478d                	li	a5,3
    80001f52:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f56:	8552                	mv	a0,s4
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	d2a080e7          	jalr	-726(ra) # 80000c82 <release>
}
    80001f60:	854a                	mv	a0,s2
    80001f62:	70e2                	ld	ra,56(sp)
    80001f64:	7442                	ld	s0,48(sp)
    80001f66:	74a2                	ld	s1,40(sp)
    80001f68:	7902                	ld	s2,32(sp)
    80001f6a:	69e2                	ld	s3,24(sp)
    80001f6c:	6a42                	ld	s4,16(sp)
    80001f6e:	6aa2                	ld	s5,8(sp)
    80001f70:	6121                	addi	sp,sp,64
    80001f72:	8082                	ret
    return -1;
    80001f74:	597d                	li	s2,-1
    80001f76:	b7ed                	j	80001f60 <fork+0x128>

0000000080001f78 <forkf>:
{
    80001f78:	7139                	addi	sp,sp,-64
    80001f7a:	fc06                	sd	ra,56(sp)
    80001f7c:	f822                	sd	s0,48(sp)
    80001f7e:	f426                	sd	s1,40(sp)
    80001f80:	f04a                	sd	s2,32(sp)
    80001f82:	ec4e                	sd	s3,24(sp)
    80001f84:	e852                	sd	s4,16(sp)
    80001f86:	e456                	sd	s5,8(sp)
    80001f88:	0080                	addi	s0,sp,64
    80001f8a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f8c:	00000097          	auipc	ra,0x0
    80001f90:	a64080e7          	jalr	-1436(ra) # 800019f0 <myproc>
    80001f94:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f96:	00000097          	auipc	ra,0x0
    80001f9a:	c9c080e7          	jalr	-868(ra) # 80001c32 <allocproc>
    80001f9e:	12050163          	beqz	a0,800020c0 <forkf+0x148>
    80001fa2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001fa4:	050ab603          	ld	a2,80(s5)
    80001fa8:	6d2c                	ld	a1,88(a0)
    80001faa:	058ab503          	ld	a0,88(s5)
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	602080e7          	jalr	1538(ra) # 800015b0 <uvmcopy>
    80001fb6:	04054d63          	bltz	a0,80002010 <forkf+0x98>
  np->sz = p->sz;
    80001fba:	050ab783          	ld	a5,80(s5)
    80001fbe:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001fc2:	060ab683          	ld	a3,96(s5)
    80001fc6:	87b6                	mv	a5,a3
    80001fc8:	0609b703          	ld	a4,96(s3)
    80001fcc:	12068693          	addi	a3,a3,288
    80001fd0:	0007b883          	ld	a7,0(a5)
    80001fd4:	0087b803          	ld	a6,8(a5)
    80001fd8:	6b8c                	ld	a1,16(a5)
    80001fda:	6f90                	ld	a2,24(a5)
    80001fdc:	01173023          	sd	a7,0(a4)
    80001fe0:	01073423          	sd	a6,8(a4)
    80001fe4:	eb0c                	sd	a1,16(a4)
    80001fe6:	ef10                	sd	a2,24(a4)
    80001fe8:	02078793          	addi	a5,a5,32
    80001fec:	02070713          	addi	a4,a4,32
    80001ff0:	fed790e3          	bne	a5,a3,80001fd0 <forkf+0x58>
  np->trapframe->a0 = 0;
    80001ff4:	0609b783          	ld	a5,96(s3)
    80001ff8:	0607b823          	sd	zero,112(a5)
  np->trapframe->epc = faddr;
    80001ffc:	0609b783          	ld	a5,96(s3)
    80002000:	ef84                	sd	s1,24(a5)
  for(i = 0; i < NOFILE; i++)
    80002002:	0d8a8493          	addi	s1,s5,216
    80002006:	0d898913          	addi	s2,s3,216
    8000200a:	158a8a13          	addi	s4,s5,344
    8000200e:	a00d                	j	80002030 <forkf+0xb8>
    freeproc(np);
    80002010:	854e                	mv	a0,s3
    80002012:	00000097          	auipc	ra,0x0
    80002016:	bc8080e7          	jalr	-1080(ra) # 80001bda <freeproc>
    release(&np->lock);
    8000201a:	854e                	mv	a0,s3
    8000201c:	fffff097          	auipc	ra,0xfffff
    80002020:	c66080e7          	jalr	-922(ra) # 80000c82 <release>
    return -1;
    80002024:	597d                	li	s2,-1
    80002026:	a059                	j	800020ac <forkf+0x134>
  for(i = 0; i < NOFILE; i++)
    80002028:	04a1                	addi	s1,s1,8
    8000202a:	0921                	addi	s2,s2,8
    8000202c:	01448b63          	beq	s1,s4,80002042 <forkf+0xca>
    if(p->ofile[i])
    80002030:	6088                	ld	a0,0(s1)
    80002032:	d97d                	beqz	a0,80002028 <forkf+0xb0>
      np->ofile[i] = filedup(p->ofile[i]);
    80002034:	00004097          	auipc	ra,0x4
    80002038:	00e080e7          	jalr	14(ra) # 80006042 <filedup>
    8000203c:	00a93023          	sd	a0,0(s2)
    80002040:	b7e5                	j	80002028 <forkf+0xb0>
  np->cwd = idup(p->cwd);
    80002042:	158ab503          	ld	a0,344(s5)
    80002046:	00003097          	auipc	ra,0x3
    8000204a:	16c080e7          	jalr	364(ra) # 800051b2 <idup>
    8000204e:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002052:	4641                	li	a2,16
    80002054:	160a8593          	addi	a1,s5,352
    80002058:	16098513          	addi	a0,s3,352
    8000205c:	fffff097          	auipc	ra,0xfffff
    80002060:	db8080e7          	jalr	-584(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    80002064:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002068:	854e                	mv	a0,s3
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	c18080e7          	jalr	-1000(ra) # 80000c82 <release>
  acquire(&wait_lock);
    80002072:	00010497          	auipc	s1,0x10
    80002076:	28648493          	addi	s1,s1,646 # 800122f8 <wait_lock>
    8000207a:	8526                	mv	a0,s1
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	b52080e7          	jalr	-1198(ra) # 80000bce <acquire>
  np->parent = p;
    80002084:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    80002088:	8526                	mv	a0,s1
    8000208a:	fffff097          	auipc	ra,0xfffff
    8000208e:	bf8080e7          	jalr	-1032(ra) # 80000c82 <release>
  acquire(&np->lock);
    80002092:	854e                	mv	a0,s3
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	b3a080e7          	jalr	-1222(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    8000209c:	478d                	li	a5,3
    8000209e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800020a2:	854e                	mv	a0,s3
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	bde080e7          	jalr	-1058(ra) # 80000c82 <release>
}
    800020ac:	854a                	mv	a0,s2
    800020ae:	70e2                	ld	ra,56(sp)
    800020b0:	7442                	ld	s0,48(sp)
    800020b2:	74a2                	ld	s1,40(sp)
    800020b4:	7902                	ld	s2,32(sp)
    800020b6:	69e2                	ld	s3,24(sp)
    800020b8:	6a42                	ld	s4,16(sp)
    800020ba:	6aa2                	ld	s5,8(sp)
    800020bc:	6121                	addi	sp,sp,64
    800020be:	8082                	ret
    return -1;
    800020c0:	597d                	li	s2,-1
    800020c2:	b7ed                	j	800020ac <forkf+0x134>

00000000800020c4 <forkp>:
{
    800020c4:	7139                	addi	sp,sp,-64
    800020c6:	fc06                	sd	ra,56(sp)
    800020c8:	f822                	sd	s0,48(sp)
    800020ca:	f426                	sd	s1,40(sp)
    800020cc:	f04a                	sd	s2,32(sp)
    800020ce:	ec4e                	sd	s3,24(sp)
    800020d0:	e852                	sd	s4,16(sp)
    800020d2:	e456                	sd	s5,8(sp)
    800020d4:	e05a                	sd	s6,0(sp)
    800020d6:	0080                	addi	s0,sp,64
    800020d8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020da:	00000097          	auipc	ra,0x0
    800020de:	916080e7          	jalr	-1770(ra) # 800019f0 <myproc>
    800020e2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800020e4:	00000097          	auipc	ra,0x0
    800020e8:	b4e080e7          	jalr	-1202(ra) # 80001c32 <allocproc>
    800020ec:	14050863          	beqz	a0,8000223c <forkp+0x178>
    800020f0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020f2:	050ab603          	ld	a2,80(s5)
    800020f6:	6d2c                	ld	a1,88(a0)
    800020f8:	058ab503          	ld	a0,88(s5)
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	4b4080e7          	jalr	1204(ra) # 800015b0 <uvmcopy>
    80002104:	04054863          	bltz	a0,80002154 <forkp+0x90>
  np->sz = p->sz;
    80002108:	050ab783          	ld	a5,80(s5)
    8000210c:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80002110:	060ab683          	ld	a3,96(s5)
    80002114:	87b6                	mv	a5,a3
    80002116:	0609b703          	ld	a4,96(s3)
    8000211a:	12068693          	addi	a3,a3,288
    8000211e:	0007b803          	ld	a6,0(a5)
    80002122:	6788                	ld	a0,8(a5)
    80002124:	6b8c                	ld	a1,16(a5)
    80002126:	6f90                	ld	a2,24(a5)
    80002128:	01073023          	sd	a6,0(a4)
    8000212c:	e708                	sd	a0,8(a4)
    8000212e:	eb0c                	sd	a1,16(a4)
    80002130:	ef10                	sd	a2,24(a4)
    80002132:	02078793          	addi	a5,a5,32
    80002136:	02070713          	addi	a4,a4,32
    8000213a:	fed792e3          	bne	a5,a3,8000211e <forkp+0x5a>
  np->trapframe->a0 = 0;
    8000213e:	0609b783          	ld	a5,96(s3)
    80002142:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002146:	0d8a8493          	addi	s1,s5,216
    8000214a:	0d898913          	addi	s2,s3,216
    8000214e:	158a8a13          	addi	s4,s5,344
    80002152:	a00d                	j	80002174 <forkp+0xb0>
    freeproc(np);
    80002154:	854e                	mv	a0,s3
    80002156:	00000097          	auipc	ra,0x0
    8000215a:	a84080e7          	jalr	-1404(ra) # 80001bda <freeproc>
    release(&np->lock);
    8000215e:	854e                	mv	a0,s3
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	b22080e7          	jalr	-1246(ra) # 80000c82 <release>
    return -1;
    80002168:	597d                	li	s2,-1
    8000216a:	a875                	j	80002226 <forkp+0x162>
  for(i = 0; i < NOFILE; i++)
    8000216c:	04a1                	addi	s1,s1,8
    8000216e:	0921                	addi	s2,s2,8
    80002170:	01448b63          	beq	s1,s4,80002186 <forkp+0xc2>
    if(p->ofile[i])
    80002174:	6088                	ld	a0,0(s1)
    80002176:	d97d                	beqz	a0,8000216c <forkp+0xa8>
      np->ofile[i] = filedup(p->ofile[i]);
    80002178:	00004097          	auipc	ra,0x4
    8000217c:	eca080e7          	jalr	-310(ra) # 80006042 <filedup>
    80002180:	00a93023          	sd	a0,0(s2)
    80002184:	b7e5                	j	8000216c <forkp+0xa8>
  np->cwd = idup(p->cwd);
    80002186:	158ab503          	ld	a0,344(s5)
    8000218a:	00003097          	auipc	ra,0x3
    8000218e:	028080e7          	jalr	40(ra) # 800051b2 <idup>
    80002192:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002196:	4641                	li	a2,16
    80002198:	160a8593          	addi	a1,s5,352
    8000219c:	16098513          	addi	a0,s3,352
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	c74080e7          	jalr	-908(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    800021a8:	0309a903          	lw	s2,48(s3)
  np->base_priority = priority;
    800021ac:	0369aa23          	sw	s6,52(s3)
  np->is_batchproc = 1;
    800021b0:	4785                	li	a5,1
    800021b2:	02f9ae23          	sw	a5,60(s3)
  np->nextburst_estimate = 0;
    800021b6:	1809a423          	sw	zero,392(s3)
  np->waittime = 0;
    800021ba:	1609ae23          	sw	zero,380(s3)
  release(&np->lock);
    800021be:	854e                	mv	a0,s3
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	ac2080e7          	jalr	-1342(ra) # 80000c82 <release>
  batchsize++;
    800021c8:	00008717          	auipc	a4,0x8
    800021cc:	e9470713          	addi	a4,a4,-364 # 8000a05c <batchsize>
    800021d0:	431c                	lw	a5,0(a4)
    800021d2:	2785                	addiw	a5,a5,1
    800021d4:	c31c                	sw	a5,0(a4)
  batchsize2++;
    800021d6:	00008717          	auipc	a4,0x8
    800021da:	e8270713          	addi	a4,a4,-382 # 8000a058 <batchsize2>
    800021de:	431c                	lw	a5,0(a4)
    800021e0:	2785                	addiw	a5,a5,1
    800021e2:	c31c                	sw	a5,0(a4)
  acquire(&wait_lock);
    800021e4:	00010497          	auipc	s1,0x10
    800021e8:	11448493          	addi	s1,s1,276 # 800122f8 <wait_lock>
    800021ec:	8526                	mv	a0,s1
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	9e0080e7          	jalr	-1568(ra) # 80000bce <acquire>
  np->parent = p;
    800021f6:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    800021fa:	8526                	mv	a0,s1
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	a86080e7          	jalr	-1402(ra) # 80000c82 <release>
  acquire(&np->lock);
    80002204:	854e                	mv	a0,s3
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	9c8080e7          	jalr	-1592(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    8000220e:	478d                	li	a5,3
    80002210:	00f9ac23          	sw	a5,24(s3)
  np->waitstart = np->ctime;
    80002214:	1709a783          	lw	a5,368(s3)
    80002218:	18f9a023          	sw	a5,384(s3)
  release(&np->lock);
    8000221c:	854e                	mv	a0,s3
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	a64080e7          	jalr	-1436(ra) # 80000c82 <release>
}
    80002226:	854a                	mv	a0,s2
    80002228:	70e2                	ld	ra,56(sp)
    8000222a:	7442                	ld	s0,48(sp)
    8000222c:	74a2                	ld	s1,40(sp)
    8000222e:	7902                	ld	s2,32(sp)
    80002230:	69e2                	ld	s3,24(sp)
    80002232:	6a42                	ld	s4,16(sp)
    80002234:	6aa2                	ld	s5,8(sp)
    80002236:	6b02                	ld	s6,0(sp)
    80002238:	6121                	addi	sp,sp,64
    8000223a:	8082                	ret
    return -1;
    8000223c:	597d                	li	s2,-1
    8000223e:	b7e5                	j	80002226 <forkp+0x162>

0000000080002240 <scheduler>:
{
    80002240:	711d                	addi	sp,sp,-96
    80002242:	ec86                	sd	ra,88(sp)
    80002244:	e8a2                	sd	s0,80(sp)
    80002246:	e4a6                	sd	s1,72(sp)
    80002248:	e0ca                	sd	s2,64(sp)
    8000224a:	fc4e                	sd	s3,56(sp)
    8000224c:	f852                	sd	s4,48(sp)
    8000224e:	f456                	sd	s5,40(sp)
    80002250:	f05a                	sd	s6,32(sp)
    80002252:	ec5e                	sd	s7,24(sp)
    80002254:	e862                	sd	s8,16(sp)
    80002256:	e466                	sd	s9,8(sp)
    80002258:	e06a                	sd	s10,0(sp)
    8000225a:	1080                	addi	s0,sp,96
    8000225c:	8792                	mv	a5,tp
  int id = r_tp();
    8000225e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002260:	00779a93          	slli	s5,a5,0x7
    80002264:	00010717          	auipc	a4,0x10
    80002268:	07c70713          	addi	a4,a4,124 # 800122e0 <pid_lock>
    8000226c:	9756                	add	a4,a4,s5
    8000226e:	02073823          	sd	zero,48(a4)
            swtch(&c->context, &p->context);
    80002272:	00010717          	auipc	a4,0x10
    80002276:	0a670713          	addi	a4,a4,166 # 80012318 <cpus+0x8>
    8000227a:	9aba                	add	s5,s5,a4
          xticks = ticks;
    8000227c:	00008997          	auipc	s3,0x8
    80002280:	df098993          	addi	s3,s3,-528 # 8000a06c <ticks>
            c->proc = p;
    80002284:	079e                	slli	a5,a5,0x7
    80002286:	00010a17          	auipc	s4,0x10
    8000228a:	05aa0a13          	addi	s4,s4,90 # 800122e0 <pid_lock>
    8000228e:	9a3e                	add	s4,s4,a5
       for(p = proc; p < &proc[NPROC]; p++) {
    80002290:	00017917          	auipc	s2,0x17
    80002294:	88090913          	addi	s2,s2,-1920 # 80018b10 <tickslock>
    80002298:	aca9                	j	800024f2 <scheduler+0x2b2>
       acquire(&tickslock);
    8000229a:	00017517          	auipc	a0,0x17
    8000229e:	87650513          	addi	a0,a0,-1930 # 80018b10 <tickslock>
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	92c080e7          	jalr	-1748(ra) # 80000bce <acquire>
       xticks = ticks;
    800022aa:	0009ad03          	lw	s10,0(s3)
       release(&tickslock);
    800022ae:	00017517          	auipc	a0,0x17
    800022b2:	86250513          	addi	a0,a0,-1950 # 80018b10 <tickslock>
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	9cc080e7          	jalr	-1588(ra) # 80000c82 <release>
       min_burst = 0x7FFFFFFF;
    800022be:	80000c37          	lui	s8,0x80000
    800022c2:	fffc4c13          	not	s8,s8
       q = 0;
    800022c6:	4c81                	li	s9,0
       for(p = proc; p < &proc[NPROC]; p++) {
    800022c8:	00010497          	auipc	s1,0x10
    800022cc:	44848493          	addi	s1,s1,1096 # 80012710 <proc>
	  if(p->state == RUNNABLE) {
    800022d0:	4b8d                	li	s7,3
    800022d2:	a0ad                	j	8000233c <scheduler+0xfc>
                if (q) release(&q->lock);
    800022d4:	000c8763          	beqz	s9,800022e2 <scheduler+0xa2>
    800022d8:	8566                	mv	a0,s9
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	9a8080e7          	jalr	-1624(ra) # 80000c82 <release>
          q->state = RUNNING;
    800022e2:	4791                	li	a5,4
    800022e4:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    800022e6:	17c4a783          	lw	a5,380(s1)
    800022ea:	01a787bb          	addw	a5,a5,s10
    800022ee:	1804a703          	lw	a4,384(s1)
    800022f2:	9f99                	subw	a5,a5,a4
    800022f4:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    800022f8:	19a4a223          	sw	s10,388(s1)
          c->proc = q;
    800022fc:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &q->context);
    80002300:	06848593          	addi	a1,s1,104
    80002304:	8556                	mv	a0,s5
    80002306:	00001097          	auipc	ra,0x1
    8000230a:	592080e7          	jalr	1426(ra) # 80003898 <swtch>
          c->proc = 0;
    8000230e:	020a3823          	sd	zero,48(s4)
	  release(&q->lock);
    80002312:	8526                	mv	a0,s1
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	96e080e7          	jalr	-1682(ra) # 80000c82 <release>
    8000231c:	aad9                	j	800024f2 <scheduler+0x2b2>
             else release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	962080e7          	jalr	-1694(ra) # 80000c82 <release>
    80002328:	a031                	j	80002334 <scheduler+0xf4>
	  else release(&p->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	956080e7          	jalr	-1706(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002334:	19048493          	addi	s1,s1,400
    80002338:	03248d63          	beq	s1,s2,80002372 <scheduler+0x132>
          acquire(&p->lock);
    8000233c:	8526                	mv	a0,s1
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	890080e7          	jalr	-1904(ra) # 80000bce <acquire>
	  if(p->state == RUNNABLE) {
    80002346:	4c9c                	lw	a5,24(s1)
    80002348:	ff7791e3          	bne	a5,s7,8000232a <scheduler+0xea>
	     if (!p->is_batchproc) {
    8000234c:	5cdc                	lw	a5,60(s1)
    8000234e:	d3d9                	beqz	a5,800022d4 <scheduler+0x94>
             else if (p->nextburst_estimate < min_burst) {
    80002350:	1884ab03          	lw	s6,392(s1)
    80002354:	fd8b55e3          	bge	s6,s8,8000231e <scheduler+0xde>
		if (q) release(&q->lock);
    80002358:	000c8a63          	beqz	s9,8000236c <scheduler+0x12c>
    8000235c:	8566                	mv	a0,s9
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	924080e7          	jalr	-1756(ra) # 80000c82 <release>
	        min_burst = p->nextburst_estimate;
    80002366:	8c5a                	mv	s8,s6
		if (q) release(&q->lock);
    80002368:	8ca6                	mv	s9,s1
    8000236a:	b7e9                	j	80002334 <scheduler+0xf4>
	        min_burst = p->nextburst_estimate;
    8000236c:	8c5a                	mv	s8,s6
    8000236e:	8ca6                	mv	s9,s1
    80002370:	b7d1                	j	80002334 <scheduler+0xf4>
       if (q) {
    80002372:	180c8063          	beqz	s9,800024f2 <scheduler+0x2b2>
    80002376:	84e6                	mv	s1,s9
    80002378:	b7ad                	j	800022e2 <scheduler+0xa2>
       acquire(&tickslock);
    8000237a:	00016517          	auipc	a0,0x16
    8000237e:	79650513          	addi	a0,a0,1942 # 80018b10 <tickslock>
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	84c080e7          	jalr	-1972(ra) # 80000bce <acquire>
       xticks = ticks;
    8000238a:	0009ab83          	lw	s7,0(s3)
       release(&tickslock);
    8000238e:	00016517          	auipc	a0,0x16
    80002392:	78250513          	addi	a0,a0,1922 # 80018b10 <tickslock>
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	8ec080e7          	jalr	-1812(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    8000239e:	00010497          	auipc	s1,0x10
    800023a2:	37248493          	addi	s1,s1,882 # 80012710 <proc>
	  if(p->state == RUNNABLE) {
    800023a6:	4b0d                	li	s6,3
    800023a8:	a811                	j	800023bc <scheduler+0x17c>
	  release(&p->lock);
    800023aa:	8526                	mv	a0,s1
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	8d6080e7          	jalr	-1834(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800023b4:	19048493          	addi	s1,s1,400
    800023b8:	03248e63          	beq	s1,s2,800023f4 <scheduler+0x1b4>
          acquire(&p->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	810080e7          	jalr	-2032(ra) # 80000bce <acquire>
	  if(p->state == RUNNABLE) {
    800023c6:	4c9c                	lw	a5,24(s1)
    800023c8:	ff6791e3          	bne	a5,s6,800023aa <scheduler+0x16a>
	     p->cpu_usage = p->cpu_usage/2;
    800023cc:	18c4a703          	lw	a4,396(s1)
    800023d0:	01f7579b          	srliw	a5,a4,0x1f
    800023d4:	9fb9                	addw	a5,a5,a4
    800023d6:	4017d79b          	sraiw	a5,a5,0x1
    800023da:	18f4a623          	sw	a5,396(s1)
	     p->priority = p->base_priority + (p->cpu_usage/2);
    800023de:	41f7579b          	sraiw	a5,a4,0x1f
    800023e2:	01e7d79b          	srliw	a5,a5,0x1e
    800023e6:	9fb9                	addw	a5,a5,a4
    800023e8:	4027d79b          	sraiw	a5,a5,0x2
    800023ec:	58d8                	lw	a4,52(s1)
    800023ee:	9fb9                	addw	a5,a5,a4
    800023f0:	dc9c                	sw	a5,56(s1)
    800023f2:	bf65                	j	800023aa <scheduler+0x16a>
       min_prio = 0x7FFFFFFF;
    800023f4:	80000cb7          	lui	s9,0x80000
    800023f8:	fffccc93          	not	s9,s9
       q = 0;
    800023fc:	4d01                	li	s10,0
       for(p = proc; p < &proc[NPROC]; p++) {
    800023fe:	00010497          	auipc	s1,0x10
    80002402:	31248493          	addi	s1,s1,786 # 80012710 <proc>
          if(p->state == RUNNABLE) {
    80002406:	4c0d                	li	s8,3
    80002408:	a0ad                	j	80002472 <scheduler+0x232>
                if (q) release(&q->lock);
    8000240a:	000d0763          	beqz	s10,80002418 <scheduler+0x1d8>
    8000240e:	856a                	mv	a0,s10
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	872080e7          	jalr	-1934(ra) # 80000c82 <release>
          q->state = RUNNING;
    80002418:	4791                	li	a5,4
    8000241a:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    8000241c:	17c4a783          	lw	a5,380(s1)
    80002420:	017787bb          	addw	a5,a5,s7
    80002424:	1804a703          	lw	a4,384(s1)
    80002428:	9f99                	subw	a5,a5,a4
    8000242a:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    8000242e:	1974a223          	sw	s7,388(s1)
          c->proc = q;
    80002432:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &q->context);
    80002436:	06848593          	addi	a1,s1,104
    8000243a:	8556                	mv	a0,s5
    8000243c:	00001097          	auipc	ra,0x1
    80002440:	45c080e7          	jalr	1116(ra) # 80003898 <swtch>
          c->proc = 0;
    80002444:	020a3823          	sd	zero,48(s4)
          release(&q->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	838080e7          	jalr	-1992(ra) # 80000c82 <release>
    80002452:	a045                	j	800024f2 <scheduler+0x2b2>
             else release(&p->lock);
    80002454:	8526                	mv	a0,s1
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	82c080e7          	jalr	-2004(ra) # 80000c82 <release>
    8000245e:	a031                	j	8000246a <scheduler+0x22a>
          else release(&p->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	820080e7          	jalr	-2016(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    8000246a:	19048493          	addi	s1,s1,400
    8000246e:	03248d63          	beq	s1,s2,800024a8 <scheduler+0x268>
          acquire(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	75a080e7          	jalr	1882(ra) # 80000bce <acquire>
          if(p->state == RUNNABLE) {
    8000247c:	4c9c                	lw	a5,24(s1)
    8000247e:	ff8791e3          	bne	a5,s8,80002460 <scheduler+0x220>
             if (!p->is_batchproc) {
    80002482:	5cdc                	lw	a5,60(s1)
    80002484:	d3d9                	beqz	a5,8000240a <scheduler+0x1ca>
             else if (p->priority < min_prio) {
    80002486:	0384ab03          	lw	s6,56(s1)
    8000248a:	fd9b55e3          	bge	s6,s9,80002454 <scheduler+0x214>
                if (q) release(&q->lock);
    8000248e:	000d0a63          	beqz	s10,800024a2 <scheduler+0x262>
    80002492:	856a                	mv	a0,s10
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7ee080e7          	jalr	2030(ra) # 80000c82 <release>
                min_prio = p->priority;
    8000249c:	8cda                	mv	s9,s6
                if (q) release(&q->lock);
    8000249e:	8d26                	mv	s10,s1
    800024a0:	b7e9                	j	8000246a <scheduler+0x22a>
                min_prio = p->priority;
    800024a2:	8cda                	mv	s9,s6
    800024a4:	8d26                	mv	s10,s1
    800024a6:	b7d1                	j	8000246a <scheduler+0x22a>
       if (q) {
    800024a8:	040d0563          	beqz	s10,800024f2 <scheduler+0x2b2>
    800024ac:	84ea                	mv	s1,s10
    800024ae:	b7ad                	j	80002418 <scheduler+0x1d8>
          acquire(&tickslock);
    800024b0:	855a                	mv	a0,s6
    800024b2:	ffffe097          	auipc	ra,0xffffe
    800024b6:	71c080e7          	jalr	1820(ra) # 80000bce <acquire>
          xticks = ticks;
    800024ba:	0009ac83          	lw	s9,0(s3)
          release(&tickslock);
    800024be:	855a                	mv	a0,s6
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	7c2080e7          	jalr	1986(ra) # 80000c82 <release>
          acquire(&p->lock);
    800024c8:	8526                	mv	a0,s1
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	704080e7          	jalr	1796(ra) # 80000bce <acquire>
          if(p->state == RUNNABLE) {
    800024d2:	4c9c                	lw	a5,24(s1)
    800024d4:	05878d63          	beq	a5,s8,8000252e <scheduler+0x2ee>
          release(&p->lock);
    800024d8:	8526                	mv	a0,s1
    800024da:	ffffe097          	auipc	ra,0xffffe
    800024de:	7a8080e7          	jalr	1960(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800024e2:	19048493          	addi	s1,s1,400
    800024e6:	01248663          	beq	s1,s2,800024f2 <scheduler+0x2b2>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    800024ea:	000ba783          	lw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffd6000>
    800024ee:	9bf5                	andi	a5,a5,-3
    800024f0:	d3e1                	beqz	a5,800024b0 <scheduler+0x270>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024fa:	10079073          	csrw	sstatus,a5
    if (sched_policy == SCHED_NPREEMPT_SJF) {
    800024fe:	00008797          	auipc	a5,0x8
    80002502:	b6a7a783          	lw	a5,-1174(a5) # 8000a068 <sched_policy>
    80002506:	4705                	li	a4,1
    80002508:	d8e789e3          	beq	a5,a4,8000229a <scheduler+0x5a>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    8000250c:	470d                	li	a4,3
       for(p = proc; p < &proc[NPROC]; p++) {
    8000250e:	00010497          	auipc	s1,0x10
    80002512:	20248493          	addi	s1,s1,514 # 80012710 <proc>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    80002516:	e6e782e3          	beq	a5,a4,8000237a <scheduler+0x13a>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    8000251a:	00008b97          	auipc	s7,0x8
    8000251e:	b4eb8b93          	addi	s7,s7,-1202 # 8000a068 <sched_policy>
          acquire(&tickslock);
    80002522:	00016b17          	auipc	s6,0x16
    80002526:	5eeb0b13          	addi	s6,s6,1518 # 80018b10 <tickslock>
          if(p->state == RUNNABLE) {
    8000252a:	4c0d                	li	s8,3
    8000252c:	bf7d                	j	800024ea <scheduler+0x2aa>
            p->state = RUNNING;
    8000252e:	4791                	li	a5,4
    80002530:	cc9c                	sw	a5,24(s1)
	    p->waittime += (xticks - p->waitstart);
    80002532:	17c4a783          	lw	a5,380(s1)
    80002536:	019787bb          	addw	a5,a5,s9
    8000253a:	1804a703          	lw	a4,384(s1)
    8000253e:	9f99                	subw	a5,a5,a4
    80002540:	16f4ae23          	sw	a5,380(s1)
	    p->burst_start = xticks;
    80002544:	1994a223          	sw	s9,388(s1)
            c->proc = p;
    80002548:	029a3823          	sd	s1,48(s4)
            swtch(&c->context, &p->context);
    8000254c:	06848593          	addi	a1,s1,104
    80002550:	8556                	mv	a0,s5
    80002552:	00001097          	auipc	ra,0x1
    80002556:	346080e7          	jalr	838(ra) # 80003898 <swtch>
            c->proc = 0;
    8000255a:	020a3823          	sd	zero,48(s4)
    8000255e:	bfad                	j	800024d8 <scheduler+0x298>

0000000080002560 <sched>:
{
    80002560:	7179                	addi	sp,sp,-48
    80002562:	f406                	sd	ra,40(sp)
    80002564:	f022                	sd	s0,32(sp)
    80002566:	ec26                	sd	s1,24(sp)
    80002568:	e84a                	sd	s2,16(sp)
    8000256a:	e44e                	sd	s3,8(sp)
    8000256c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000256e:	fffff097          	auipc	ra,0xfffff
    80002572:	482080e7          	jalr	1154(ra) # 800019f0 <myproc>
    80002576:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	5dc080e7          	jalr	1500(ra) # 80000b54 <holding>
    80002580:	c93d                	beqz	a0,800025f6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002582:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002584:	2781                	sext.w	a5,a5
    80002586:	079e                	slli	a5,a5,0x7
    80002588:	00010717          	auipc	a4,0x10
    8000258c:	d5870713          	addi	a4,a4,-680 # 800122e0 <pid_lock>
    80002590:	97ba                	add	a5,a5,a4
    80002592:	0a87a703          	lw	a4,168(a5)
    80002596:	4785                	li	a5,1
    80002598:	06f71763          	bne	a4,a5,80002606 <sched+0xa6>
  if(p->state == RUNNING)
    8000259c:	4c98                	lw	a4,24(s1)
    8000259e:	4791                	li	a5,4
    800025a0:	06f70b63          	beq	a4,a5,80002616 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025a8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800025aa:	efb5                	bnez	a5,80002626 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025ac:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800025ae:	00010917          	auipc	s2,0x10
    800025b2:	d3290913          	addi	s2,s2,-718 # 800122e0 <pid_lock>
    800025b6:	2781                	sext.w	a5,a5
    800025b8:	079e                	slli	a5,a5,0x7
    800025ba:	97ca                	add	a5,a5,s2
    800025bc:	0ac7a983          	lw	s3,172(a5)
    800025c0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800025c2:	2781                	sext.w	a5,a5
    800025c4:	079e                	slli	a5,a5,0x7
    800025c6:	00010597          	auipc	a1,0x10
    800025ca:	d5258593          	addi	a1,a1,-686 # 80012318 <cpus+0x8>
    800025ce:	95be                	add	a1,a1,a5
    800025d0:	06848513          	addi	a0,s1,104
    800025d4:	00001097          	auipc	ra,0x1
    800025d8:	2c4080e7          	jalr	708(ra) # 80003898 <swtch>
    800025dc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800025de:	2781                	sext.w	a5,a5
    800025e0:	079e                	slli	a5,a5,0x7
    800025e2:	993e                	add	s2,s2,a5
    800025e4:	0b392623          	sw	s3,172(s2)
}
    800025e8:	70a2                	ld	ra,40(sp)
    800025ea:	7402                	ld	s0,32(sp)
    800025ec:	64e2                	ld	s1,24(sp)
    800025ee:	6942                	ld	s2,16(sp)
    800025f0:	69a2                	ld	s3,8(sp)
    800025f2:	6145                	addi	sp,sp,48
    800025f4:	8082                	ret
    panic("sched p->lock");
    800025f6:	00007517          	auipc	a0,0x7
    800025fa:	c4250513          	addi	a0,a0,-958 # 80009238 <digits+0x1f8>
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	f3a080e7          	jalr	-198(ra) # 80000538 <panic>
    panic("sched locks");
    80002606:	00007517          	auipc	a0,0x7
    8000260a:	c4250513          	addi	a0,a0,-958 # 80009248 <digits+0x208>
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	f2a080e7          	jalr	-214(ra) # 80000538 <panic>
    panic("sched running");
    80002616:	00007517          	auipc	a0,0x7
    8000261a:	c4250513          	addi	a0,a0,-958 # 80009258 <digits+0x218>
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	f1a080e7          	jalr	-230(ra) # 80000538 <panic>
    panic("sched interruptible");
    80002626:	00007517          	auipc	a0,0x7
    8000262a:	c4250513          	addi	a0,a0,-958 # 80009268 <digits+0x228>
    8000262e:	ffffe097          	auipc	ra,0xffffe
    80002632:	f0a080e7          	jalr	-246(ra) # 80000538 <panic>

0000000080002636 <yield>:
{
    80002636:	1101                	addi	sp,sp,-32
    80002638:	ec06                	sd	ra,24(sp)
    8000263a:	e822                	sd	s0,16(sp)
    8000263c:	e426                	sd	s1,8(sp)
    8000263e:	e04a                	sd	s2,0(sp)
    80002640:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002642:	fffff097          	auipc	ra,0xfffff
    80002646:	3ae080e7          	jalr	942(ra) # 800019f0 <myproc>
    8000264a:	84aa                	mv	s1,a0
  acquire(&tickslock);
    8000264c:	00016517          	auipc	a0,0x16
    80002650:	4c450513          	addi	a0,a0,1220 # 80018b10 <tickslock>
    80002654:	ffffe097          	auipc	ra,0xffffe
    80002658:	57a080e7          	jalr	1402(ra) # 80000bce <acquire>
  xticks = ticks;
    8000265c:	00008917          	auipc	s2,0x8
    80002660:	a1092903          	lw	s2,-1520(s2) # 8000a06c <ticks>
  release(&tickslock);
    80002664:	00016517          	auipc	a0,0x16
    80002668:	4ac50513          	addi	a0,a0,1196 # 80018b10 <tickslock>
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	616080e7          	jalr	1558(ra) # 80000c82 <release>
  acquire(&p->lock);
    80002674:	8526                	mv	a0,s1
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	558080e7          	jalr	1368(ra) # 80000bce <acquire>
  p->state = RUNNABLE;
    8000267e:	478d                	li	a5,3
    80002680:	cc9c                	sw	a5,24(s1)
  p->waitstart = xticks;
    80002682:	1924a023          	sw	s2,384(s1)
  p->cpu_usage += SCHED_PARAM_CPU_USAGE;
    80002686:	18c4a783          	lw	a5,396(s1)
    8000268a:	0c87879b          	addiw	a5,a5,200
    8000268e:	18f4a623          	sw	a5,396(s1)
  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    80002692:	5cdc                	lw	a5,60(s1)
    80002694:	c7ed                	beqz	a5,8000277e <yield+0x148>
    80002696:	1844a783          	lw	a5,388(s1)
    8000269a:	0f278263          	beq	a5,s2,8000277e <yield+0x148>
     num_cpubursts++;
    8000269e:	00008697          	auipc	a3,0x8
    800026a2:	9a668693          	addi	a3,a3,-1626 # 8000a044 <num_cpubursts>
    800026a6:	4298                	lw	a4,0(a3)
    800026a8:	2705                	addiw	a4,a4,1
    800026aa:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    800026ac:	40f9073b          	subw	a4,s2,a5
    800026b0:	0007061b          	sext.w	a2,a4
    800026b4:	00008597          	auipc	a1,0x8
    800026b8:	98c58593          	addi	a1,a1,-1652 # 8000a040 <cpubursts_tot>
    800026bc:	4194                	lw	a3,0(a1)
    800026be:	9eb9                	addw	a3,a3,a4
    800026c0:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    800026c2:	00008697          	auipc	a3,0x8
    800026c6:	97a6a683          	lw	a3,-1670(a3) # 8000a03c <cpubursts_max>
    800026ca:	00c6f663          	bgeu	a3,a2,800026d6 <yield+0xa0>
    800026ce:	00008697          	auipc	a3,0x8
    800026d2:	96e6a723          	sw	a4,-1682(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    800026d6:	00007697          	auipc	a3,0x7
    800026da:	5026a683          	lw	a3,1282(a3) # 80009bd8 <cpubursts_min>
    800026de:	00d67663          	bgeu	a2,a3,800026ea <yield+0xb4>
    800026e2:	00007697          	auipc	a3,0x7
    800026e6:	4ee6ab23          	sw	a4,1270(a3) # 80009bd8 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    800026ea:	1884a683          	lw	a3,392(s1)
    800026ee:	02d05763          	blez	a3,8000271c <yield+0xe6>
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    800026f2:	0006859b          	sext.w	a1,a3
    800026f6:	0ac5e363          	bltu	a1,a2,8000279c <yield+0x166>
    800026fa:	9fad                	addw	a5,a5,a1
    800026fc:	412785bb          	subw	a1,a5,s2
    80002700:	00008617          	auipc	a2,0x8
    80002704:	92c60613          	addi	a2,a2,-1748 # 8000a02c <estimation_error>
    80002708:	421c                	lw	a5,0(a2)
    8000270a:	9fad                	addw	a5,a5,a1
    8000270c:	c21c                	sw	a5,0(a2)
	estimation_error_instance++;
    8000270e:	00008617          	auipc	a2,0x8
    80002712:	91a60613          	addi	a2,a2,-1766 # 8000a028 <estimation_error_instance>
    80002716:	421c                	lw	a5,0(a2)
    80002718:	2785                	addiw	a5,a5,1
    8000271a:	c21c                	sw	a5,0(a2)
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    8000271c:	01f6d79b          	srliw	a5,a3,0x1f
    80002720:	9fb5                	addw	a5,a5,a3
    80002722:	4017d79b          	sraiw	a5,a5,0x1
    80002726:	9fb9                	addw	a5,a5,a4
    80002728:	0017571b          	srliw	a4,a4,0x1
    8000272c:	9f99                	subw	a5,a5,a4
    8000272e:	0007871b          	sext.w	a4,a5
    80002732:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    80002736:	04e05463          	blez	a4,8000277e <yield+0x148>
        num_cpubursts_est++;
    8000273a:	00008617          	auipc	a2,0x8
    8000273e:	8fe60613          	addi	a2,a2,-1794 # 8000a038 <num_cpubursts_est>
    80002742:	4214                	lw	a3,0(a2)
    80002744:	2685                	addiw	a3,a3,1
    80002746:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    80002748:	00008617          	auipc	a2,0x8
    8000274c:	8ec60613          	addi	a2,a2,-1812 # 8000a034 <cpubursts_est_tot>
    80002750:	4214                	lw	a3,0(a2)
    80002752:	9ebd                	addw	a3,a3,a5
    80002754:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002756:	00008697          	auipc	a3,0x8
    8000275a:	8da6a683          	lw	a3,-1830(a3) # 8000a030 <cpubursts_est_max>
    8000275e:	00e6d663          	bge	a3,a4,8000276a <yield+0x134>
    80002762:	00008697          	auipc	a3,0x8
    80002766:	8cf6a723          	sw	a5,-1842(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    8000276a:	00007697          	auipc	a3,0x7
    8000276e:	46a6a683          	lw	a3,1130(a3) # 80009bd4 <cpubursts_est_min>
    80002772:	00d75663          	bge	a4,a3,8000277e <yield+0x148>
    80002776:	00007717          	auipc	a4,0x7
    8000277a:	44f72f23          	sw	a5,1118(a4) # 80009bd4 <cpubursts_est_min>
  sched();
    8000277e:	00000097          	auipc	ra,0x0
    80002782:	de2080e7          	jalr	-542(ra) # 80002560 <sched>
  release(&p->lock);
    80002786:	8526                	mv	a0,s1
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	4fa080e7          	jalr	1274(ra) # 80000c82 <release>
}
    80002790:	60e2                	ld	ra,24(sp)
    80002792:	6442                	ld	s0,16(sp)
    80002794:	64a2                	ld	s1,8(sp)
    80002796:	6902                	ld	s2,0(sp)
    80002798:	6105                	addi	sp,sp,32
    8000279a:	8082                	ret
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    8000279c:	40b705bb          	subw	a1,a4,a1
    800027a0:	b785                	j	80002700 <yield+0xca>

00000000800027a2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800027a2:	7179                	addi	sp,sp,-48
    800027a4:	f406                	sd	ra,40(sp)
    800027a6:	f022                	sd	s0,32(sp)
    800027a8:	ec26                	sd	s1,24(sp)
    800027aa:	e84a                	sd	s2,16(sp)
    800027ac:	e44e                	sd	s3,8(sp)
    800027ae:	e052                	sd	s4,0(sp)
    800027b0:	1800                	addi	s0,sp,48
    800027b2:	89aa                	mv	s3,a0
    800027b4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027b6:	fffff097          	auipc	ra,0xfffff
    800027ba:	23a080e7          	jalr	570(ra) # 800019f0 <myproc>
    800027be:	84aa                	mv	s1,a0
  uint xticks;

  if (!holding(&tickslock)) {
    800027c0:	00016517          	auipc	a0,0x16
    800027c4:	35050513          	addi	a0,a0,848 # 80018b10 <tickslock>
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	38c080e7          	jalr	908(ra) # 80000b54 <holding>
    800027d0:	14050863          	beqz	a0,80002920 <sleep+0x17e>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    800027d4:	00008a17          	auipc	s4,0x8
    800027d8:	898a2a03          	lw	s4,-1896(s4) # 8000a06c <ticks>
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800027dc:	8526                	mv	a0,s1
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	3f0080e7          	jalr	1008(ra) # 80000bce <acquire>
  release(lk);
    800027e6:	854a                	mv	a0,s2
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	49a080e7          	jalr	1178(ra) # 80000c82 <release>

  // Go to sleep.
  p->chan = chan;
    800027f0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800027f4:	4789                	li	a5,2
    800027f6:	cc9c                	sw	a5,24(s1)

  p->cpu_usage += (SCHED_PARAM_CPU_USAGE/2);
    800027f8:	18c4a783          	lw	a5,396(s1)
    800027fc:	0647879b          	addiw	a5,a5,100
    80002800:	18f4a623          	sw	a5,396(s1)

  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    80002804:	5cdc                	lw	a5,60(s1)
    80002806:	c7ed                	beqz	a5,800028f0 <sleep+0x14e>
    80002808:	1844a783          	lw	a5,388(s1)
    8000280c:	0f478263          	beq	a5,s4,800028f0 <sleep+0x14e>
     num_cpubursts++;
    80002810:	00008697          	auipc	a3,0x8
    80002814:	83468693          	addi	a3,a3,-1996 # 8000a044 <num_cpubursts>
    80002818:	4298                	lw	a4,0(a3)
    8000281a:	2705                	addiw	a4,a4,1
    8000281c:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    8000281e:	40fa073b          	subw	a4,s4,a5
    80002822:	0007061b          	sext.w	a2,a4
    80002826:	00008597          	auipc	a1,0x8
    8000282a:	81a58593          	addi	a1,a1,-2022 # 8000a040 <cpubursts_tot>
    8000282e:	4194                	lw	a3,0(a1)
    80002830:	9eb9                	addw	a3,a3,a4
    80002832:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002834:	00008697          	auipc	a3,0x8
    80002838:	8086a683          	lw	a3,-2040(a3) # 8000a03c <cpubursts_max>
    8000283c:	00c6f663          	bgeu	a3,a2,80002848 <sleep+0xa6>
    80002840:	00007697          	auipc	a3,0x7
    80002844:	7ee6ae23          	sw	a4,2044(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002848:	00007697          	auipc	a3,0x7
    8000284c:	3906a683          	lw	a3,912(a3) # 80009bd8 <cpubursts_min>
    80002850:	00d67663          	bgeu	a2,a3,8000285c <sleep+0xba>
    80002854:	00007697          	auipc	a3,0x7
    80002858:	38e6a223          	sw	a4,900(a3) # 80009bd8 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    8000285c:	1884a683          	lw	a3,392(s1)
    80002860:	02d05763          	blez	a3,8000288e <sleep+0xec>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002864:	0006859b          	sext.w	a1,a3
    80002868:	0ec5e163          	bltu	a1,a2,8000294a <sleep+0x1a8>
    8000286c:	9fad                	addw	a5,a5,a1
    8000286e:	414785bb          	subw	a1,a5,s4
    80002872:	00007617          	auipc	a2,0x7
    80002876:	7ba60613          	addi	a2,a2,1978 # 8000a02c <estimation_error>
    8000287a:	421c                	lw	a5,0(a2)
    8000287c:	9fad                	addw	a5,a5,a1
    8000287e:	c21c                	sw	a5,0(a2)
        estimation_error_instance++;
    80002880:	00007617          	auipc	a2,0x7
    80002884:	7a860613          	addi	a2,a2,1960 # 8000a028 <estimation_error_instance>
    80002888:	421c                	lw	a5,0(a2)
    8000288a:	2785                	addiw	a5,a5,1
    8000288c:	c21c                	sw	a5,0(a2)
     }
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    8000288e:	01f6d79b          	srliw	a5,a3,0x1f
    80002892:	9fb5                	addw	a5,a5,a3
    80002894:	4017d79b          	sraiw	a5,a5,0x1
    80002898:	9fb9                	addw	a5,a5,a4
    8000289a:	0017571b          	srliw	a4,a4,0x1
    8000289e:	9f99                	subw	a5,a5,a4
    800028a0:	0007871b          	sext.w	a4,a5
    800028a4:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    800028a8:	04e05463          	blez	a4,800028f0 <sleep+0x14e>
        num_cpubursts_est++;
    800028ac:	00007617          	auipc	a2,0x7
    800028b0:	78c60613          	addi	a2,a2,1932 # 8000a038 <num_cpubursts_est>
    800028b4:	4214                	lw	a3,0(a2)
    800028b6:	2685                	addiw	a3,a3,1
    800028b8:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    800028ba:	00007617          	auipc	a2,0x7
    800028be:	77a60613          	addi	a2,a2,1914 # 8000a034 <cpubursts_est_tot>
    800028c2:	4214                	lw	a3,0(a2)
    800028c4:	9ebd                	addw	a3,a3,a5
    800028c6:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    800028c8:	00007697          	auipc	a3,0x7
    800028cc:	7686a683          	lw	a3,1896(a3) # 8000a030 <cpubursts_est_max>
    800028d0:	00e6d663          	bge	a3,a4,800028dc <sleep+0x13a>
    800028d4:	00007697          	auipc	a3,0x7
    800028d8:	74f6ae23          	sw	a5,1884(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    800028dc:	00007697          	auipc	a3,0x7
    800028e0:	2f86a683          	lw	a3,760(a3) # 80009bd4 <cpubursts_est_min>
    800028e4:	00d75663          	bge	a4,a3,800028f0 <sleep+0x14e>
    800028e8:	00007717          	auipc	a4,0x7
    800028ec:	2ef72623          	sw	a5,748(a4) # 80009bd4 <cpubursts_est_min>
     }
  }

  sched();
    800028f0:	00000097          	auipc	ra,0x0
    800028f4:	c70080e7          	jalr	-912(ra) # 80002560 <sched>

  // Tidy up.
  p->chan = 0;
    800028f8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800028fc:	8526                	mv	a0,s1
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	384080e7          	jalr	900(ra) # 80000c82 <release>
  acquire(lk);
    80002906:	854a                	mv	a0,s2
    80002908:	ffffe097          	auipc	ra,0xffffe
    8000290c:	2c6080e7          	jalr	710(ra) # 80000bce <acquire>
}
    80002910:	70a2                	ld	ra,40(sp)
    80002912:	7402                	ld	s0,32(sp)
    80002914:	64e2                	ld	s1,24(sp)
    80002916:	6942                	ld	s2,16(sp)
    80002918:	69a2                	ld	s3,8(sp)
    8000291a:	6a02                	ld	s4,0(sp)
    8000291c:	6145                	addi	sp,sp,48
    8000291e:	8082                	ret
     acquire(&tickslock);
    80002920:	00016517          	auipc	a0,0x16
    80002924:	1f050513          	addi	a0,a0,496 # 80018b10 <tickslock>
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	2a6080e7          	jalr	678(ra) # 80000bce <acquire>
     xticks = ticks;
    80002930:	00007a17          	auipc	s4,0x7
    80002934:	73ca2a03          	lw	s4,1852(s4) # 8000a06c <ticks>
     release(&tickslock);
    80002938:	00016517          	auipc	a0,0x16
    8000293c:	1d850513          	addi	a0,a0,472 # 80018b10 <tickslock>
    80002940:	ffffe097          	auipc	ra,0xffffe
    80002944:	342080e7          	jalr	834(ra) # 80000c82 <release>
    80002948:	bd51                	j	800027dc <sleep+0x3a>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    8000294a:	40b705bb          	subw	a1,a4,a1
    8000294e:	b715                	j	80002872 <sleep+0xd0>

0000000080002950 <wait>:
{
    80002950:	715d                	addi	sp,sp,-80
    80002952:	e486                	sd	ra,72(sp)
    80002954:	e0a2                	sd	s0,64(sp)
    80002956:	fc26                	sd	s1,56(sp)
    80002958:	f84a                	sd	s2,48(sp)
    8000295a:	f44e                	sd	s3,40(sp)
    8000295c:	f052                	sd	s4,32(sp)
    8000295e:	ec56                	sd	s5,24(sp)
    80002960:	e85a                	sd	s6,16(sp)
    80002962:	e45e                	sd	s7,8(sp)
    80002964:	e062                	sd	s8,0(sp)
    80002966:	0880                	addi	s0,sp,80
    80002968:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000296a:	fffff097          	auipc	ra,0xfffff
    8000296e:	086080e7          	jalr	134(ra) # 800019f0 <myproc>
    80002972:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002974:	00010517          	auipc	a0,0x10
    80002978:	98450513          	addi	a0,a0,-1660 # 800122f8 <wait_lock>
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	252080e7          	jalr	594(ra) # 80000bce <acquire>
    havekids = 0;
    80002984:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002986:	4a15                	li	s4,5
        havekids = 1;
    80002988:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000298a:	00016997          	auipc	s3,0x16
    8000298e:	18698993          	addi	s3,s3,390 # 80018b10 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002992:	00010c17          	auipc	s8,0x10
    80002996:	966c0c13          	addi	s8,s8,-1690 # 800122f8 <wait_lock>
    havekids = 0;
    8000299a:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000299c:	00010497          	auipc	s1,0x10
    800029a0:	d7448493          	addi	s1,s1,-652 # 80012710 <proc>
    800029a4:	a0bd                	j	80002a12 <wait+0xc2>
          pid = np->pid;
    800029a6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800029aa:	000b0e63          	beqz	s6,800029c6 <wait+0x76>
    800029ae:	4691                	li	a3,4
    800029b0:	02c48613          	addi	a2,s1,44
    800029b4:	85da                	mv	a1,s6
    800029b6:	05893503          	ld	a0,88(s2)
    800029ba:	fffff097          	auipc	ra,0xfffff
    800029be:	cfa080e7          	jalr	-774(ra) # 800016b4 <copyout>
    800029c2:	02054563          	bltz	a0,800029ec <wait+0x9c>
          freeproc(np);
    800029c6:	8526                	mv	a0,s1
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	212080e7          	jalr	530(ra) # 80001bda <freeproc>
          release(&np->lock);
    800029d0:	8526                	mv	a0,s1
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	2b0080e7          	jalr	688(ra) # 80000c82 <release>
          release(&wait_lock);
    800029da:	00010517          	auipc	a0,0x10
    800029de:	91e50513          	addi	a0,a0,-1762 # 800122f8 <wait_lock>
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	2a0080e7          	jalr	672(ra) # 80000c82 <release>
          return pid;
    800029ea:	a09d                	j	80002a50 <wait+0x100>
            release(&np->lock);
    800029ec:	8526                	mv	a0,s1
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	294080e7          	jalr	660(ra) # 80000c82 <release>
            release(&wait_lock);
    800029f6:	00010517          	auipc	a0,0x10
    800029fa:	90250513          	addi	a0,a0,-1790 # 800122f8 <wait_lock>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	284080e7          	jalr	644(ra) # 80000c82 <release>
            return -1;
    80002a06:	59fd                	li	s3,-1
    80002a08:	a0a1                	j	80002a50 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002a0a:	19048493          	addi	s1,s1,400
    80002a0e:	03348463          	beq	s1,s3,80002a36 <wait+0xe6>
      if(np->parent == p){
    80002a12:	60bc                	ld	a5,64(s1)
    80002a14:	ff279be3          	bne	a5,s2,80002a0a <wait+0xba>
        acquire(&np->lock);
    80002a18:	8526                	mv	a0,s1
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	1b4080e7          	jalr	436(ra) # 80000bce <acquire>
        if(np->state == ZOMBIE){
    80002a22:	4c9c                	lw	a5,24(s1)
    80002a24:	f94781e3          	beq	a5,s4,800029a6 <wait+0x56>
        release(&np->lock);
    80002a28:	8526                	mv	a0,s1
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	258080e7          	jalr	600(ra) # 80000c82 <release>
        havekids = 1;
    80002a32:	8756                	mv	a4,s5
    80002a34:	bfd9                	j	80002a0a <wait+0xba>
    if(!havekids || p->killed){
    80002a36:	c701                	beqz	a4,80002a3e <wait+0xee>
    80002a38:	02892783          	lw	a5,40(s2)
    80002a3c:	c79d                	beqz	a5,80002a6a <wait+0x11a>
      release(&wait_lock);
    80002a3e:	00010517          	auipc	a0,0x10
    80002a42:	8ba50513          	addi	a0,a0,-1862 # 800122f8 <wait_lock>
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	23c080e7          	jalr	572(ra) # 80000c82 <release>
      return -1;
    80002a4e:	59fd                	li	s3,-1
}
    80002a50:	854e                	mv	a0,s3
    80002a52:	60a6                	ld	ra,72(sp)
    80002a54:	6406                	ld	s0,64(sp)
    80002a56:	74e2                	ld	s1,56(sp)
    80002a58:	7942                	ld	s2,48(sp)
    80002a5a:	79a2                	ld	s3,40(sp)
    80002a5c:	7a02                	ld	s4,32(sp)
    80002a5e:	6ae2                	ld	s5,24(sp)
    80002a60:	6b42                	ld	s6,16(sp)
    80002a62:	6ba2                	ld	s7,8(sp)
    80002a64:	6c02                	ld	s8,0(sp)
    80002a66:	6161                	addi	sp,sp,80
    80002a68:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a6a:	85e2                	mv	a1,s8
    80002a6c:	854a                	mv	a0,s2
    80002a6e:	00000097          	auipc	ra,0x0
    80002a72:	d34080e7          	jalr	-716(ra) # 800027a2 <sleep>
    havekids = 0;
    80002a76:	b715                	j	8000299a <wait+0x4a>

0000000080002a78 <waitpid>:
{
    80002a78:	711d                	addi	sp,sp,-96
    80002a7a:	ec86                	sd	ra,88(sp)
    80002a7c:	e8a2                	sd	s0,80(sp)
    80002a7e:	e4a6                	sd	s1,72(sp)
    80002a80:	e0ca                	sd	s2,64(sp)
    80002a82:	fc4e                	sd	s3,56(sp)
    80002a84:	f852                	sd	s4,48(sp)
    80002a86:	f456                	sd	s5,40(sp)
    80002a88:	f05a                	sd	s6,32(sp)
    80002a8a:	ec5e                	sd	s7,24(sp)
    80002a8c:	e862                	sd	s8,16(sp)
    80002a8e:	e466                	sd	s9,8(sp)
    80002a90:	1080                	addi	s0,sp,96
    80002a92:	8a2a                	mv	s4,a0
    80002a94:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	f5a080e7          	jalr	-166(ra) # 800019f0 <myproc>
    80002a9e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002aa0:	00010517          	auipc	a0,0x10
    80002aa4:	85850513          	addi	a0,a0,-1960 # 800122f8 <wait_lock>
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	126080e7          	jalr	294(ra) # 80000bce <acquire>
  int found=0;
    80002ab0:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    80002ab2:	4a95                	li	s5,5
	found = 1;
    80002ab4:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002ab6:	00016997          	auipc	s3,0x16
    80002aba:	05a98993          	addi	s3,s3,90 # 80018b10 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002abe:	00010b97          	auipc	s7,0x10
    80002ac2:	83ab8b93          	addi	s7,s7,-1990 # 800122f8 <wait_lock>
    80002ac6:	a0c9                	j	80002b88 <waitpid+0x110>
             release(&np->lock);
    80002ac8:	8526                	mv	a0,s1
    80002aca:	ffffe097          	auipc	ra,0xffffe
    80002ace:	1b8080e7          	jalr	440(ra) # 80000c82 <release>
             release(&wait_lock);
    80002ad2:	00010517          	auipc	a0,0x10
    80002ad6:	82650513          	addi	a0,a0,-2010 # 800122f8 <wait_lock>
    80002ada:	ffffe097          	auipc	ra,0xffffe
    80002ade:	1a8080e7          	jalr	424(ra) # 80000c82 <release>
             return -1;
    80002ae2:	557d                	li	a0,-1
    80002ae4:	a895                	j	80002b58 <waitpid+0xe0>
        release(&np->lock);
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	19a080e7          	jalr	410(ra) # 80000c82 <release>
	found = 1;
    80002af0:	8cda                	mv	s9,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002af2:	19048493          	addi	s1,s1,400
    80002af6:	07348e63          	beq	s1,s3,80002b72 <waitpid+0xfa>
      if((np->parent == p) && (np->pid == pid)){
    80002afa:	60bc                	ld	a5,64(s1)
    80002afc:	ff279be3          	bne	a5,s2,80002af2 <waitpid+0x7a>
    80002b00:	589c                	lw	a5,48(s1)
    80002b02:	ff4798e3          	bne	a5,s4,80002af2 <waitpid+0x7a>
        acquire(&np->lock);
    80002b06:	8526                	mv	a0,s1
    80002b08:	ffffe097          	auipc	ra,0xffffe
    80002b0c:	0c6080e7          	jalr	198(ra) # 80000bce <acquire>
        if(np->state == ZOMBIE){
    80002b10:	4c9c                	lw	a5,24(s1)
    80002b12:	fd579ae3          	bne	a5,s5,80002ae6 <waitpid+0x6e>
           if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002b16:	000c0e63          	beqz	s8,80002b32 <waitpid+0xba>
    80002b1a:	4691                	li	a3,4
    80002b1c:	02c48613          	addi	a2,s1,44
    80002b20:	85e2                	mv	a1,s8
    80002b22:	05893503          	ld	a0,88(s2)
    80002b26:	fffff097          	auipc	ra,0xfffff
    80002b2a:	b8e080e7          	jalr	-1138(ra) # 800016b4 <copyout>
    80002b2e:	f8054de3          	bltz	a0,80002ac8 <waitpid+0x50>
           freeproc(np);
    80002b32:	8526                	mv	a0,s1
    80002b34:	fffff097          	auipc	ra,0xfffff
    80002b38:	0a6080e7          	jalr	166(ra) # 80001bda <freeproc>
           release(&np->lock);
    80002b3c:	8526                	mv	a0,s1
    80002b3e:	ffffe097          	auipc	ra,0xffffe
    80002b42:	144080e7          	jalr	324(ra) # 80000c82 <release>
           release(&wait_lock);
    80002b46:	0000f517          	auipc	a0,0xf
    80002b4a:	7b250513          	addi	a0,a0,1970 # 800122f8 <wait_lock>
    80002b4e:	ffffe097          	auipc	ra,0xffffe
    80002b52:	134080e7          	jalr	308(ra) # 80000c82 <release>
           return pid;
    80002b56:	8552                	mv	a0,s4
}
    80002b58:	60e6                	ld	ra,88(sp)
    80002b5a:	6446                	ld	s0,80(sp)
    80002b5c:	64a6                	ld	s1,72(sp)
    80002b5e:	6906                	ld	s2,64(sp)
    80002b60:	79e2                	ld	s3,56(sp)
    80002b62:	7a42                	ld	s4,48(sp)
    80002b64:	7aa2                	ld	s5,40(sp)
    80002b66:	7b02                	ld	s6,32(sp)
    80002b68:	6be2                	ld	s7,24(sp)
    80002b6a:	6c42                	ld	s8,16(sp)
    80002b6c:	6ca2                	ld	s9,8(sp)
    80002b6e:	6125                	addi	sp,sp,96
    80002b70:	8082                	ret
    if(!found || p->killed){
    80002b72:	020c8063          	beqz	s9,80002b92 <waitpid+0x11a>
    80002b76:	02892783          	lw	a5,40(s2)
    80002b7a:	ef81                	bnez	a5,80002b92 <waitpid+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002b7c:	85de                	mv	a1,s7
    80002b7e:	854a                	mv	a0,s2
    80002b80:	00000097          	auipc	ra,0x0
    80002b84:	c22080e7          	jalr	-990(ra) # 800027a2 <sleep>
    for(np = proc; np < &proc[NPROC]; np++){
    80002b88:	00010497          	auipc	s1,0x10
    80002b8c:	b8848493          	addi	s1,s1,-1144 # 80012710 <proc>
    80002b90:	b7ad                	j	80002afa <waitpid+0x82>
      release(&wait_lock);
    80002b92:	0000f517          	auipc	a0,0xf
    80002b96:	76650513          	addi	a0,a0,1894 # 800122f8 <wait_lock>
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	0e8080e7          	jalr	232(ra) # 80000c82 <release>
      return -1;
    80002ba2:	557d                	li	a0,-1
    80002ba4:	bf55                	j	80002b58 <waitpid+0xe0>

0000000080002ba6 <condsleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
condsleep(struct cond_t* chan, struct sleeplock *lk)
{
    80002ba6:	7179                	addi	sp,sp,-48
    80002ba8:	f406                	sd	ra,40(sp)
    80002baa:	f022                	sd	s0,32(sp)
    80002bac:	ec26                	sd	s1,24(sp)
    80002bae:	e84a                	sd	s2,16(sp)
    80002bb0:	e44e                	sd	s3,8(sp)
    80002bb2:	e052                	sd	s4,0(sp)
    80002bb4:	1800                	addi	s0,sp,48
    80002bb6:	89aa                	mv	s3,a0
    80002bb8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bba:	fffff097          	auipc	ra,0xfffff
    80002bbe:	e36080e7          	jalr	-458(ra) # 800019f0 <myproc>
    80002bc2:	84aa                	mv	s1,a0
  uint xticks;

  if (!holding(&tickslock)) {
    80002bc4:	00016517          	auipc	a0,0x16
    80002bc8:	f4c50513          	addi	a0,a0,-180 # 80018b10 <tickslock>
    80002bcc:	ffffe097          	auipc	ra,0xffffe
    80002bd0:	f88080e7          	jalr	-120(ra) # 80000b54 <holding>
    80002bd4:	14050863          	beqz	a0,80002d24 <condsleep+0x17e>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    80002bd8:	00007a17          	auipc	s4,0x7
    80002bdc:	494a2a03          	lw	s4,1172(s4) # 8000a06c <ticks>
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002be0:	8526                	mv	a0,s1
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	fec080e7          	jalr	-20(ra) # 80000bce <acquire>
  releasesleep(lk);
    80002bea:	854a                	mv	a0,s2
    80002bec:	00003097          	auipc	ra,0x3
    80002bf0:	32a080e7          	jalr	810(ra) # 80005f16 <releasesleep>

  // Go to sleep.
  p->chan = chan;
    80002bf4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002bf8:	4789                	li	a5,2
    80002bfa:	cc9c                	sw	a5,24(s1)

  p->cpu_usage += (SCHED_PARAM_CPU_USAGE/2);
    80002bfc:	18c4a783          	lw	a5,396(s1)
    80002c00:	0647879b          	addiw	a5,a5,100
    80002c04:	18f4a623          	sw	a5,396(s1)

  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    80002c08:	5cdc                	lw	a5,60(s1)
    80002c0a:	c7ed                	beqz	a5,80002cf4 <condsleep+0x14e>
    80002c0c:	1844a783          	lw	a5,388(s1)
    80002c10:	0f478263          	beq	a5,s4,80002cf4 <condsleep+0x14e>
     num_cpubursts++;
    80002c14:	00007697          	auipc	a3,0x7
    80002c18:	43068693          	addi	a3,a3,1072 # 8000a044 <num_cpubursts>
    80002c1c:	4298                	lw	a4,0(a3)
    80002c1e:	2705                	addiw	a4,a4,1
    80002c20:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    80002c22:	40fa073b          	subw	a4,s4,a5
    80002c26:	0007061b          	sext.w	a2,a4
    80002c2a:	00007597          	auipc	a1,0x7
    80002c2e:	41658593          	addi	a1,a1,1046 # 8000a040 <cpubursts_tot>
    80002c32:	4194                	lw	a3,0(a1)
    80002c34:	9eb9                	addw	a3,a3,a4
    80002c36:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002c38:	00007697          	auipc	a3,0x7
    80002c3c:	4046a683          	lw	a3,1028(a3) # 8000a03c <cpubursts_max>
    80002c40:	00c6f663          	bgeu	a3,a2,80002c4c <condsleep+0xa6>
    80002c44:	00007697          	auipc	a3,0x7
    80002c48:	3ee6ac23          	sw	a4,1016(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002c4c:	00007697          	auipc	a3,0x7
    80002c50:	f8c6a683          	lw	a3,-116(a3) # 80009bd8 <cpubursts_min>
    80002c54:	00d67663          	bgeu	a2,a3,80002c60 <condsleep+0xba>
    80002c58:	00007697          	auipc	a3,0x7
    80002c5c:	f8e6a023          	sw	a4,-128(a3) # 80009bd8 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    80002c60:	1884a683          	lw	a3,392(s1)
    80002c64:	02d05763          	blez	a3,80002c92 <condsleep+0xec>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002c68:	0006859b          	sext.w	a1,a3
    80002c6c:	0ec5e163          	bltu	a1,a2,80002d4e <condsleep+0x1a8>
    80002c70:	9fad                	addw	a5,a5,a1
    80002c72:	414785bb          	subw	a1,a5,s4
    80002c76:	00007617          	auipc	a2,0x7
    80002c7a:	3b660613          	addi	a2,a2,950 # 8000a02c <estimation_error>
    80002c7e:	421c                	lw	a5,0(a2)
    80002c80:	9fad                	addw	a5,a5,a1
    80002c82:	c21c                	sw	a5,0(a2)
        estimation_error_instance++;
    80002c84:	00007617          	auipc	a2,0x7
    80002c88:	3a460613          	addi	a2,a2,932 # 8000a028 <estimation_error_instance>
    80002c8c:	421c                	lw	a5,0(a2)
    80002c8e:	2785                	addiw	a5,a5,1
    80002c90:	c21c                	sw	a5,0(a2)
     }
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    80002c92:	01f6d79b          	srliw	a5,a3,0x1f
    80002c96:	9fb5                	addw	a5,a5,a3
    80002c98:	4017d79b          	sraiw	a5,a5,0x1
    80002c9c:	9fb9                	addw	a5,a5,a4
    80002c9e:	0017571b          	srliw	a4,a4,0x1
    80002ca2:	9f99                	subw	a5,a5,a4
    80002ca4:	0007871b          	sext.w	a4,a5
    80002ca8:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    80002cac:	04e05463          	blez	a4,80002cf4 <condsleep+0x14e>
        num_cpubursts_est++;
    80002cb0:	00007617          	auipc	a2,0x7
    80002cb4:	38860613          	addi	a2,a2,904 # 8000a038 <num_cpubursts_est>
    80002cb8:	4214                	lw	a3,0(a2)
    80002cba:	2685                	addiw	a3,a3,1
    80002cbc:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    80002cbe:	00007617          	auipc	a2,0x7
    80002cc2:	37660613          	addi	a2,a2,886 # 8000a034 <cpubursts_est_tot>
    80002cc6:	4214                	lw	a3,0(a2)
    80002cc8:	9ebd                	addw	a3,a3,a5
    80002cca:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002ccc:	00007697          	auipc	a3,0x7
    80002cd0:	3646a683          	lw	a3,868(a3) # 8000a030 <cpubursts_est_max>
    80002cd4:	00e6d663          	bge	a3,a4,80002ce0 <condsleep+0x13a>
    80002cd8:	00007697          	auipc	a3,0x7
    80002cdc:	34f6ac23          	sw	a5,856(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80002ce0:	00007697          	auipc	a3,0x7
    80002ce4:	ef46a683          	lw	a3,-268(a3) # 80009bd4 <cpubursts_est_min>
    80002ce8:	00d75663          	bge	a4,a3,80002cf4 <condsleep+0x14e>
    80002cec:	00007717          	auipc	a4,0x7
    80002cf0:	eef72423          	sw	a5,-280(a4) # 80009bd4 <cpubursts_est_min>
     }
  }

  sched();
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	86c080e7          	jalr	-1940(ra) # 80002560 <sched>

  // Tidy up.
  p->chan = 0;
    80002cfc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002d00:	8526                	mv	a0,s1
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	f80080e7          	jalr	-128(ra) # 80000c82 <release>
  acquiresleep(lk);
    80002d0a:	854a                	mv	a0,s2
    80002d0c:	00003097          	auipc	ra,0x3
    80002d10:	1b4080e7          	jalr	436(ra) # 80005ec0 <acquiresleep>
}
    80002d14:	70a2                	ld	ra,40(sp)
    80002d16:	7402                	ld	s0,32(sp)
    80002d18:	64e2                	ld	s1,24(sp)
    80002d1a:	6942                	ld	s2,16(sp)
    80002d1c:	69a2                	ld	s3,8(sp)
    80002d1e:	6a02                	ld	s4,0(sp)
    80002d20:	6145                	addi	sp,sp,48
    80002d22:	8082                	ret
     acquire(&tickslock);
    80002d24:	00016517          	auipc	a0,0x16
    80002d28:	dec50513          	addi	a0,a0,-532 # 80018b10 <tickslock>
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	ea2080e7          	jalr	-350(ra) # 80000bce <acquire>
     xticks = ticks;
    80002d34:	00007a17          	auipc	s4,0x7
    80002d38:	338a2a03          	lw	s4,824(s4) # 8000a06c <ticks>
     release(&tickslock);
    80002d3c:	00016517          	auipc	a0,0x16
    80002d40:	dd450513          	addi	a0,a0,-556 # 80018b10 <tickslock>
    80002d44:	ffffe097          	auipc	ra,0xffffe
    80002d48:	f3e080e7          	jalr	-194(ra) # 80000c82 <release>
    80002d4c:	bd51                	j	80002be0 <condsleep+0x3a>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002d4e:	40b705bb          	subw	a1,a4,a1
    80002d52:	b715                	j	80002c76 <condsleep+0xd0>

0000000080002d54 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002d54:	7139                	addi	sp,sp,-64
    80002d56:	fc06                	sd	ra,56(sp)
    80002d58:	f822                	sd	s0,48(sp)
    80002d5a:	f426                	sd	s1,40(sp)
    80002d5c:	f04a                	sd	s2,32(sp)
    80002d5e:	ec4e                	sd	s3,24(sp)
    80002d60:	e852                	sd	s4,16(sp)
    80002d62:	e456                	sd	s5,8(sp)
    80002d64:	e05a                	sd	s6,0(sp)
    80002d66:	0080                	addi	s0,sp,64
    80002d68:	8a2a                	mv	s4,a0
  struct proc *p;
  uint xticks;

  if (!holding(&tickslock)) {
    80002d6a:	00016517          	auipc	a0,0x16
    80002d6e:	da650513          	addi	a0,a0,-602 # 80018b10 <tickslock>
    80002d72:	ffffe097          	auipc	ra,0xffffe
    80002d76:	de2080e7          	jalr	-542(ra) # 80000b54 <holding>
    80002d7a:	c105                	beqz	a0,80002d9a <wakeup+0x46>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    80002d7c:	00007b17          	auipc	s6,0x7
    80002d80:	2f0b2b03          	lw	s6,752(s6) # 8000a06c <ticks>

  for(p = proc; p < &proc[NPROC]; p++) {
    80002d84:	00010497          	auipc	s1,0x10
    80002d88:	98c48493          	addi	s1,s1,-1652 # 80012710 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002d8c:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002d8e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002d90:	00016917          	auipc	s2,0x16
    80002d94:	d8090913          	addi	s2,s2,-640 # 80018b10 <tickslock>
    80002d98:	a83d                	j	80002dd6 <wakeup+0x82>
     acquire(&tickslock);
    80002d9a:	00016517          	auipc	a0,0x16
    80002d9e:	d7650513          	addi	a0,a0,-650 # 80018b10 <tickslock>
    80002da2:	ffffe097          	auipc	ra,0xffffe
    80002da6:	e2c080e7          	jalr	-468(ra) # 80000bce <acquire>
     xticks = ticks;
    80002daa:	00007b17          	auipc	s6,0x7
    80002dae:	2c2b2b03          	lw	s6,706(s6) # 8000a06c <ticks>
     release(&tickslock);
    80002db2:	00016517          	auipc	a0,0x16
    80002db6:	d5e50513          	addi	a0,a0,-674 # 80018b10 <tickslock>
    80002dba:	ffffe097          	auipc	ra,0xffffe
    80002dbe:	ec8080e7          	jalr	-312(ra) # 80000c82 <release>
    80002dc2:	b7c9                	j	80002d84 <wakeup+0x30>
	p->waitstart = xticks;
      }
      release(&p->lock);
    80002dc4:	8526                	mv	a0,s1
    80002dc6:	ffffe097          	auipc	ra,0xffffe
    80002dca:	ebc080e7          	jalr	-324(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002dce:	19048493          	addi	s1,s1,400
    80002dd2:	03248863          	beq	s1,s2,80002e02 <wakeup+0xae>
    if(p != myproc()){
    80002dd6:	fffff097          	auipc	ra,0xfffff
    80002dda:	c1a080e7          	jalr	-998(ra) # 800019f0 <myproc>
    80002dde:	fea488e3          	beq	s1,a0,80002dce <wakeup+0x7a>
      acquire(&p->lock);
    80002de2:	8526                	mv	a0,s1
    80002de4:	ffffe097          	auipc	ra,0xffffe
    80002de8:	dea080e7          	jalr	-534(ra) # 80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002dec:	4c9c                	lw	a5,24(s1)
    80002dee:	fd379be3          	bne	a5,s3,80002dc4 <wakeup+0x70>
    80002df2:	709c                	ld	a5,32(s1)
    80002df4:	fd4798e3          	bne	a5,s4,80002dc4 <wakeup+0x70>
        p->state = RUNNABLE;
    80002df8:	0154ac23          	sw	s5,24(s1)
	p->waitstart = xticks;
    80002dfc:	1964a023          	sw	s6,384(s1)
    80002e00:	b7d1                	j	80002dc4 <wakeup+0x70>
    }
  }
}
    80002e02:	70e2                	ld	ra,56(sp)
    80002e04:	7442                	ld	s0,48(sp)
    80002e06:	74a2                	ld	s1,40(sp)
    80002e08:	7902                	ld	s2,32(sp)
    80002e0a:	69e2                	ld	s3,24(sp)
    80002e0c:	6a42                	ld	s4,16(sp)
    80002e0e:	6aa2                	ld	s5,8(sp)
    80002e10:	6b02                	ld	s6,0(sp)
    80002e12:	6121                	addi	sp,sp,64
    80002e14:	8082                	ret

0000000080002e16 <reparent>:
{
    80002e16:	7179                	addi	sp,sp,-48
    80002e18:	f406                	sd	ra,40(sp)
    80002e1a:	f022                	sd	s0,32(sp)
    80002e1c:	ec26                	sd	s1,24(sp)
    80002e1e:	e84a                	sd	s2,16(sp)
    80002e20:	e44e                	sd	s3,8(sp)
    80002e22:	e052                	sd	s4,0(sp)
    80002e24:	1800                	addi	s0,sp,48
    80002e26:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002e28:	00010497          	auipc	s1,0x10
    80002e2c:	8e848493          	addi	s1,s1,-1816 # 80012710 <proc>
      pp->parent = initproc;
    80002e30:	00007a17          	auipc	s4,0x7
    80002e34:	230a0a13          	addi	s4,s4,560 # 8000a060 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002e38:	00016997          	auipc	s3,0x16
    80002e3c:	cd898993          	addi	s3,s3,-808 # 80018b10 <tickslock>
    80002e40:	a029                	j	80002e4a <reparent+0x34>
    80002e42:	19048493          	addi	s1,s1,400
    80002e46:	01348d63          	beq	s1,s3,80002e60 <reparent+0x4a>
    if(pp->parent == p){
    80002e4a:	60bc                	ld	a5,64(s1)
    80002e4c:	ff279be3          	bne	a5,s2,80002e42 <reparent+0x2c>
      pp->parent = initproc;
    80002e50:	000a3503          	ld	a0,0(s4)
    80002e54:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002e56:	00000097          	auipc	ra,0x0
    80002e5a:	efe080e7          	jalr	-258(ra) # 80002d54 <wakeup>
    80002e5e:	b7d5                	j	80002e42 <reparent+0x2c>
}
    80002e60:	70a2                	ld	ra,40(sp)
    80002e62:	7402                	ld	s0,32(sp)
    80002e64:	64e2                	ld	s1,24(sp)
    80002e66:	6942                	ld	s2,16(sp)
    80002e68:	69a2                	ld	s3,8(sp)
    80002e6a:	6a02                	ld	s4,0(sp)
    80002e6c:	6145                	addi	sp,sp,48
    80002e6e:	8082                	ret

0000000080002e70 <exit>:
{
    80002e70:	7179                	addi	sp,sp,-48
    80002e72:	f406                	sd	ra,40(sp)
    80002e74:	f022                	sd	s0,32(sp)
    80002e76:	ec26                	sd	s1,24(sp)
    80002e78:	e84a                	sd	s2,16(sp)
    80002e7a:	e44e                	sd	s3,8(sp)
    80002e7c:	e052                	sd	s4,0(sp)
    80002e7e:	1800                	addi	s0,sp,48
    80002e80:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002e82:	fffff097          	auipc	ra,0xfffff
    80002e86:	b6e080e7          	jalr	-1170(ra) # 800019f0 <myproc>
    80002e8a:	892a                	mv	s2,a0
  if(p == initproc)
    80002e8c:	00007797          	auipc	a5,0x7
    80002e90:	1d47b783          	ld	a5,468(a5) # 8000a060 <initproc>
    80002e94:	0d850493          	addi	s1,a0,216
    80002e98:	15850993          	addi	s3,a0,344
    80002e9c:	02a79363          	bne	a5,a0,80002ec2 <exit+0x52>
    panic("init exiting");
    80002ea0:	00006517          	auipc	a0,0x6
    80002ea4:	3e050513          	addi	a0,a0,992 # 80009280 <digits+0x240>
    80002ea8:	ffffd097          	auipc	ra,0xffffd
    80002eac:	690080e7          	jalr	1680(ra) # 80000538 <panic>
      fileclose(f);
    80002eb0:	00003097          	auipc	ra,0x3
    80002eb4:	1e4080e7          	jalr	484(ra) # 80006094 <fileclose>
      p->ofile[fd] = 0;
    80002eb8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002ebc:	04a1                	addi	s1,s1,8
    80002ebe:	01348563          	beq	s1,s3,80002ec8 <exit+0x58>
    if(p->ofile[fd]){
    80002ec2:	6088                	ld	a0,0(s1)
    80002ec4:	f575                	bnez	a0,80002eb0 <exit+0x40>
    80002ec6:	bfdd                	j	80002ebc <exit+0x4c>
  begin_op();
    80002ec8:	00003097          	auipc	ra,0x3
    80002ecc:	d04080e7          	jalr	-764(ra) # 80005bcc <begin_op>
  iput(p->cwd);
    80002ed0:	15893503          	ld	a0,344(s2)
    80002ed4:	00002097          	auipc	ra,0x2
    80002ed8:	4d6080e7          	jalr	1238(ra) # 800053aa <iput>
  end_op();
    80002edc:	00003097          	auipc	ra,0x3
    80002ee0:	d6e080e7          	jalr	-658(ra) # 80005c4a <end_op>
  p->cwd = 0;
    80002ee4:	14093c23          	sd	zero,344(s2)
  acquire(&wait_lock);
    80002ee8:	0000f497          	auipc	s1,0xf
    80002eec:	41048493          	addi	s1,s1,1040 # 800122f8 <wait_lock>
    80002ef0:	8526                	mv	a0,s1
    80002ef2:	ffffe097          	auipc	ra,0xffffe
    80002ef6:	cdc080e7          	jalr	-804(ra) # 80000bce <acquire>
  reparent(p);
    80002efa:	854a                	mv	a0,s2
    80002efc:	00000097          	auipc	ra,0x0
    80002f00:	f1a080e7          	jalr	-230(ra) # 80002e16 <reparent>
  wakeup(p->parent);
    80002f04:	04093503          	ld	a0,64(s2)
    80002f08:	00000097          	auipc	ra,0x0
    80002f0c:	e4c080e7          	jalr	-436(ra) # 80002d54 <wakeup>
  acquire(&p->lock);
    80002f10:	854a                	mv	a0,s2
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	cbc080e7          	jalr	-836(ra) # 80000bce <acquire>
  p->xstate = status;
    80002f1a:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80002f1e:	4795                	li	a5,5
    80002f20:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002f24:	8526                	mv	a0,s1
    80002f26:	ffffe097          	auipc	ra,0xffffe
    80002f2a:	d5c080e7          	jalr	-676(ra) # 80000c82 <release>
  acquire(&tickslock);
    80002f2e:	00016517          	auipc	a0,0x16
    80002f32:	be250513          	addi	a0,a0,-1054 # 80018b10 <tickslock>
    80002f36:	ffffe097          	auipc	ra,0xffffe
    80002f3a:	c98080e7          	jalr	-872(ra) # 80000bce <acquire>
  xticks = ticks;
    80002f3e:	00007497          	auipc	s1,0x7
    80002f42:	12e4a483          	lw	s1,302(s1) # 8000a06c <ticks>
  release(&tickslock);
    80002f46:	00016517          	auipc	a0,0x16
    80002f4a:	bca50513          	addi	a0,a0,-1078 # 80018b10 <tickslock>
    80002f4e:	ffffe097          	auipc	ra,0xffffe
    80002f52:	d34080e7          	jalr	-716(ra) # 80000c82 <release>
  p->endtime = xticks;
    80002f56:	0004879b          	sext.w	a5,s1
    80002f5a:	16f92c23          	sw	a5,376(s2)
  if (p->is_batchproc) {
    80002f5e:	03c92703          	lw	a4,60(s2)
    80002f62:	16070763          	beqz	a4,800030d0 <exit+0x260>
     if ((xticks - p->burst_start) > 0) {
    80002f66:	18492603          	lw	a2,388(s2)
    80002f6a:	0e960063          	beq	a2,s1,8000304a <exit+0x1da>
        num_cpubursts++;
    80002f6e:	00007697          	auipc	a3,0x7
    80002f72:	0d668693          	addi	a3,a3,214 # 8000a044 <num_cpubursts>
    80002f76:	4298                	lw	a4,0(a3)
    80002f78:	2705                	addiw	a4,a4,1
    80002f7a:	c298                	sw	a4,0(a3)
        cpubursts_tot += (xticks - p->burst_start);
    80002f7c:	40c486bb          	subw	a3,s1,a2
    80002f80:	0006859b          	sext.w	a1,a3
    80002f84:	00007517          	auipc	a0,0x7
    80002f88:	0bc50513          	addi	a0,a0,188 # 8000a040 <cpubursts_tot>
    80002f8c:	4118                	lw	a4,0(a0)
    80002f8e:	9f35                	addw	a4,a4,a3
    80002f90:	c118                	sw	a4,0(a0)
        if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002f92:	00007717          	auipc	a4,0x7
    80002f96:	0aa72703          	lw	a4,170(a4) # 8000a03c <cpubursts_max>
    80002f9a:	00b77663          	bgeu	a4,a1,80002fa6 <exit+0x136>
    80002f9e:	00007717          	auipc	a4,0x7
    80002fa2:	08d72f23          	sw	a3,158(a4) # 8000a03c <cpubursts_max>
        if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002fa6:	00007717          	auipc	a4,0x7
    80002faa:	c3272703          	lw	a4,-974(a4) # 80009bd8 <cpubursts_min>
    80002fae:	00e5f663          	bgeu	a1,a4,80002fba <exit+0x14a>
    80002fb2:	00007717          	auipc	a4,0x7
    80002fb6:	c2d72323          	sw	a3,-986(a4) # 80009bd8 <cpubursts_min>
        if (p->nextburst_estimate > 0) {
    80002fba:	18892703          	lw	a4,392(s2)
    80002fbe:	02e05763          	blez	a4,80002fec <exit+0x17c>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002fc2:	0007051b          	sext.w	a0,a4
    80002fc6:	12b56163          	bltu	a0,a1,800030e8 <exit+0x278>
    80002fca:	9e29                	addw	a2,a2,a0
    80002fcc:	4096053b          	subw	a0,a2,s1
    80002fd0:	00007597          	auipc	a1,0x7
    80002fd4:	05c58593          	addi	a1,a1,92 # 8000a02c <estimation_error>
    80002fd8:	4190                	lw	a2,0(a1)
    80002fda:	9e29                	addw	a2,a2,a0
    80002fdc:	c190                	sw	a2,0(a1)
           estimation_error_instance++;
    80002fde:	00007597          	auipc	a1,0x7
    80002fe2:	04a58593          	addi	a1,a1,74 # 8000a028 <estimation_error_instance>
    80002fe6:	4190                	lw	a2,0(a1)
    80002fe8:	2605                	addiw	a2,a2,1
    80002fea:	c190                	sw	a2,0(a1)
        p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    80002fec:	4609                	li	a2,2
    80002fee:	02c7473b          	divw	a4,a4,a2
    80002ff2:	9f35                	addw	a4,a4,a3
    80002ff4:	0016d69b          	srliw	a3,a3,0x1
    80002ff8:	9f15                	subw	a4,a4,a3
    80002ffa:	0007069b          	sext.w	a3,a4
    80002ffe:	18e92423          	sw	a4,392(s2)
        if (p->nextburst_estimate > 0) {
    80003002:	04d05463          	blez	a3,8000304a <exit+0x1da>
           num_cpubursts_est++;
    80003006:	00007597          	auipc	a1,0x7
    8000300a:	03258593          	addi	a1,a1,50 # 8000a038 <num_cpubursts_est>
    8000300e:	4190                	lw	a2,0(a1)
    80003010:	2605                	addiw	a2,a2,1
    80003012:	c190                	sw	a2,0(a1)
           cpubursts_est_tot += p->nextburst_estimate;
    80003014:	00007597          	auipc	a1,0x7
    80003018:	02058593          	addi	a1,a1,32 # 8000a034 <cpubursts_est_tot>
    8000301c:	4190                	lw	a2,0(a1)
    8000301e:	9e39                	addw	a2,a2,a4
    80003020:	c190                	sw	a2,0(a1)
           if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80003022:	00007617          	auipc	a2,0x7
    80003026:	00e62603          	lw	a2,14(a2) # 8000a030 <cpubursts_est_max>
    8000302a:	00d65663          	bge	a2,a3,80003036 <exit+0x1c6>
    8000302e:	00007617          	auipc	a2,0x7
    80003032:	00e62123          	sw	a4,2(a2) # 8000a030 <cpubursts_est_max>
           if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80003036:	00007617          	auipc	a2,0x7
    8000303a:	b9e62603          	lw	a2,-1122(a2) # 80009bd4 <cpubursts_est_min>
    8000303e:	00c6d663          	bge	a3,a2,8000304a <exit+0x1da>
    80003042:	00007697          	auipc	a3,0x7
    80003046:	b8e6a923          	sw	a4,-1134(a3) # 80009bd4 <cpubursts_est_min>
     if (p->stime < batch_start) batch_start = p->stime;
    8000304a:	17492703          	lw	a4,372(s2)
    8000304e:	00007697          	auipc	a3,0x7
    80003052:	b926a683          	lw	a3,-1134(a3) # 80009be0 <batch_start>
    80003056:	00d75663          	bge	a4,a3,80003062 <exit+0x1f2>
    8000305a:	00007697          	auipc	a3,0x7
    8000305e:	b8e6a323          	sw	a4,-1146(a3) # 80009be0 <batch_start>
     batchsize--;
    80003062:	00007617          	auipc	a2,0x7
    80003066:	ffa60613          	addi	a2,a2,-6 # 8000a05c <batchsize>
    8000306a:	4214                	lw	a3,0(a2)
    8000306c:	36fd                	addiw	a3,a3,-1
    8000306e:	0006859b          	sext.w	a1,a3
    80003072:	c214                	sw	a3,0(a2)
     turnaround += (p->endtime - p->stime);
    80003074:	00007697          	auipc	a3,0x7
    80003078:	fe068693          	addi	a3,a3,-32 # 8000a054 <turnaround>
    8000307c:	40e7873b          	subw	a4,a5,a4
    80003080:	4290                	lw	a2,0(a3)
    80003082:	9f31                	addw	a4,a4,a2
    80003084:	c298                	sw	a4,0(a3)
     waiting_tot += p->waittime;
    80003086:	00007697          	auipc	a3,0x7
    8000308a:	fc668693          	addi	a3,a3,-58 # 8000a04c <waiting_tot>
    8000308e:	17c92603          	lw	a2,380(s2)
    80003092:	4298                	lw	a4,0(a3)
    80003094:	9f31                	addw	a4,a4,a2
    80003096:	c298                	sw	a4,0(a3)
     completion_tot += p->endtime;
    80003098:	00007697          	auipc	a3,0x7
    8000309c:	fb868693          	addi	a3,a3,-72 # 8000a050 <completion_tot>
    800030a0:	4298                	lw	a4,0(a3)
    800030a2:	9f3d                	addw	a4,a4,a5
    800030a4:	c298                	sw	a4,0(a3)
     if (p->endtime > completion_max) completion_max = p->endtime;
    800030a6:	00007717          	auipc	a4,0x7
    800030aa:	fa272703          	lw	a4,-94(a4) # 8000a048 <completion_max>
    800030ae:	00f75663          	bge	a4,a5,800030ba <exit+0x24a>
    800030b2:	00007717          	auipc	a4,0x7
    800030b6:	f8f72b23          	sw	a5,-106(a4) # 8000a048 <completion_max>
     if (p->endtime < completion_min) completion_min = p->endtime;
    800030ba:	00007717          	auipc	a4,0x7
    800030be:	b2272703          	lw	a4,-1246(a4) # 80009bdc <completion_min>
    800030c2:	00e7d663          	bge	a5,a4,800030ce <exit+0x25e>
    800030c6:	00007717          	auipc	a4,0x7
    800030ca:	b0f72b23          	sw	a5,-1258(a4) # 80009bdc <completion_min>
     if (batchsize == 0) {
    800030ce:	c185                	beqz	a1,800030ee <exit+0x27e>
  sched();
    800030d0:	fffff097          	auipc	ra,0xfffff
    800030d4:	490080e7          	jalr	1168(ra) # 80002560 <sched>
  panic("zombie exit");
    800030d8:	00006517          	auipc	a0,0x6
    800030dc:	2f050513          	addi	a0,a0,752 # 800093c8 <digits+0x388>
    800030e0:	ffffd097          	auipc	ra,0xffffd
    800030e4:	458080e7          	jalr	1112(ra) # 80000538 <panic>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    800030e8:	40a6853b          	subw	a0,a3,a0
    800030ec:	b5d5                	j	80002fd0 <exit+0x160>
        printf("\nBatch execution time: %d\n", p->endtime - batch_start);
    800030ee:	00007597          	auipc	a1,0x7
    800030f2:	af25a583          	lw	a1,-1294(a1) # 80009be0 <batch_start>
    800030f6:	40b785bb          	subw	a1,a5,a1
    800030fa:	00006517          	auipc	a0,0x6
    800030fe:	19650513          	addi	a0,a0,406 # 80009290 <digits+0x250>
    80003102:	ffffd097          	auipc	ra,0xffffd
    80003106:	480080e7          	jalr	1152(ra) # 80000582 <printf>
	printf("Average turn-around time: %d\n", turnaround/batchsize2);
    8000310a:	00007497          	auipc	s1,0x7
    8000310e:	f4e48493          	addi	s1,s1,-178 # 8000a058 <batchsize2>
    80003112:	00007597          	auipc	a1,0x7
    80003116:	f425a583          	lw	a1,-190(a1) # 8000a054 <turnaround>
    8000311a:	409c                	lw	a5,0(s1)
    8000311c:	02f5c5bb          	divw	a1,a1,a5
    80003120:	00006517          	auipc	a0,0x6
    80003124:	19050513          	addi	a0,a0,400 # 800092b0 <digits+0x270>
    80003128:	ffffd097          	auipc	ra,0xffffd
    8000312c:	45a080e7          	jalr	1114(ra) # 80000582 <printf>
	printf("Average waiting time: %d\n", waiting_tot/batchsize2);
    80003130:	00007597          	auipc	a1,0x7
    80003134:	f1c5a583          	lw	a1,-228(a1) # 8000a04c <waiting_tot>
    80003138:	409c                	lw	a5,0(s1)
    8000313a:	02f5c5bb          	divw	a1,a1,a5
    8000313e:	00006517          	auipc	a0,0x6
    80003142:	19250513          	addi	a0,a0,402 # 800092d0 <digits+0x290>
    80003146:	ffffd097          	auipc	ra,0xffffd
    8000314a:	43c080e7          	jalr	1084(ra) # 80000582 <printf>
	printf("Completion time: avg: %d, max: %d, min: %d\n", completion_tot/batchsize2, completion_max, completion_min);
    8000314e:	00007597          	auipc	a1,0x7
    80003152:	f025a583          	lw	a1,-254(a1) # 8000a050 <completion_tot>
    80003156:	409c                	lw	a5,0(s1)
    80003158:	00007697          	auipc	a3,0x7
    8000315c:	a846a683          	lw	a3,-1404(a3) # 80009bdc <completion_min>
    80003160:	00007617          	auipc	a2,0x7
    80003164:	ee862603          	lw	a2,-280(a2) # 8000a048 <completion_max>
    80003168:	02f5c5bb          	divw	a1,a1,a5
    8000316c:	00006517          	auipc	a0,0x6
    80003170:	18450513          	addi	a0,a0,388 # 800092f0 <digits+0x2b0>
    80003174:	ffffd097          	auipc	ra,0xffffd
    80003178:	40e080e7          	jalr	1038(ra) # 80000582 <printf>
	if ((sched_policy == SCHED_NPREEMPT_FCFS) || (sched_policy == SCHED_NPREEMPT_SJF)) {
    8000317c:	00007717          	auipc	a4,0x7
    80003180:	eec72703          	lw	a4,-276(a4) # 8000a068 <sched_policy>
    80003184:	4785                	li	a5,1
    80003186:	08e7fb63          	bgeu	a5,a4,8000321c <exit+0x3ac>
	batchsize2 = 0;
    8000318a:	00007797          	auipc	a5,0x7
    8000318e:	ec07a723          	sw	zero,-306(a5) # 8000a058 <batchsize2>
	batch_start = 0x7FFFFFFF;
    80003192:	800007b7          	lui	a5,0x80000
    80003196:	fff7c793          	not	a5,a5
    8000319a:	00007717          	auipc	a4,0x7
    8000319e:	a4f72323          	sw	a5,-1466(a4) # 80009be0 <batch_start>
	turnaround = 0;
    800031a2:	00007717          	auipc	a4,0x7
    800031a6:	ea072923          	sw	zero,-334(a4) # 8000a054 <turnaround>
	waiting_tot = 0;
    800031aa:	00007717          	auipc	a4,0x7
    800031ae:	ea072123          	sw	zero,-350(a4) # 8000a04c <waiting_tot>
	completion_tot = 0;
    800031b2:	00007717          	auipc	a4,0x7
    800031b6:	e8072f23          	sw	zero,-354(a4) # 8000a050 <completion_tot>
	completion_max = 0;
    800031ba:	00007717          	auipc	a4,0x7
    800031be:	e8072723          	sw	zero,-370(a4) # 8000a048 <completion_max>
	completion_min = 0x7FFFFFFF;
    800031c2:	00007717          	auipc	a4,0x7
    800031c6:	a0f72d23          	sw	a5,-1510(a4) # 80009bdc <completion_min>
	num_cpubursts = 0;
    800031ca:	00007717          	auipc	a4,0x7
    800031ce:	e6072d23          	sw	zero,-390(a4) # 8000a044 <num_cpubursts>
        cpubursts_tot = 0;
    800031d2:	00007717          	auipc	a4,0x7
    800031d6:	e6072723          	sw	zero,-402(a4) # 8000a040 <cpubursts_tot>
        cpubursts_max = 0;
    800031da:	00007717          	auipc	a4,0x7
    800031de:	e6072123          	sw	zero,-414(a4) # 8000a03c <cpubursts_max>
        cpubursts_min = 0x7FFFFFFF;
    800031e2:	00007717          	auipc	a4,0x7
    800031e6:	9ef72b23          	sw	a5,-1546(a4) # 80009bd8 <cpubursts_min>
	num_cpubursts_est = 0;
    800031ea:	00007717          	auipc	a4,0x7
    800031ee:	e4072723          	sw	zero,-434(a4) # 8000a038 <num_cpubursts_est>
        cpubursts_est_tot = 0;
    800031f2:	00007717          	auipc	a4,0x7
    800031f6:	e4072123          	sw	zero,-446(a4) # 8000a034 <cpubursts_est_tot>
        cpubursts_est_max = 0;
    800031fa:	00007717          	auipc	a4,0x7
    800031fe:	e2072b23          	sw	zero,-458(a4) # 8000a030 <cpubursts_est_max>
        cpubursts_est_min = 0x7FFFFFFF;
    80003202:	00007717          	auipc	a4,0x7
    80003206:	9cf72923          	sw	a5,-1582(a4) # 80009bd4 <cpubursts_est_min>
	estimation_error = 0;
    8000320a:	00007797          	auipc	a5,0x7
    8000320e:	e207a123          	sw	zero,-478(a5) # 8000a02c <estimation_error>
        estimation_error_instance = 0;
    80003212:	00007797          	auipc	a5,0x7
    80003216:	e007ab23          	sw	zero,-490(a5) # 8000a028 <estimation_error_instance>
    8000321a:	bd5d                	j	800030d0 <exit+0x260>
	   printf("CPU bursts: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts, cpubursts_tot/num_cpubursts, cpubursts_max, cpubursts_min);
    8000321c:	00007597          	auipc	a1,0x7
    80003220:	e285a583          	lw	a1,-472(a1) # 8000a044 <num_cpubursts>
    80003224:	00007617          	auipc	a2,0x7
    80003228:	e1c62603          	lw	a2,-484(a2) # 8000a040 <cpubursts_tot>
    8000322c:	00007717          	auipc	a4,0x7
    80003230:	9ac72703          	lw	a4,-1620(a4) # 80009bd8 <cpubursts_min>
    80003234:	00007697          	auipc	a3,0x7
    80003238:	e086a683          	lw	a3,-504(a3) # 8000a03c <cpubursts_max>
    8000323c:	02b6463b          	divw	a2,a2,a1
    80003240:	00006517          	auipc	a0,0x6
    80003244:	0e050513          	addi	a0,a0,224 # 80009320 <digits+0x2e0>
    80003248:	ffffd097          	auipc	ra,0xffffd
    8000324c:	33a080e7          	jalr	826(ra) # 80000582 <printf>
	   printf("CPU burst estimates: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts_est, cpubursts_est_tot/num_cpubursts_est, cpubursts_est_max, cpubursts_est_min);
    80003250:	00007597          	auipc	a1,0x7
    80003254:	de85a583          	lw	a1,-536(a1) # 8000a038 <num_cpubursts_est>
    80003258:	00007617          	auipc	a2,0x7
    8000325c:	ddc62603          	lw	a2,-548(a2) # 8000a034 <cpubursts_est_tot>
    80003260:	00007717          	auipc	a4,0x7
    80003264:	97472703          	lw	a4,-1676(a4) # 80009bd4 <cpubursts_est_min>
    80003268:	00007697          	auipc	a3,0x7
    8000326c:	dc86a683          	lw	a3,-568(a3) # 8000a030 <cpubursts_est_max>
    80003270:	02b6463b          	divw	a2,a2,a1
    80003274:	00006517          	auipc	a0,0x6
    80003278:	0e450513          	addi	a0,a0,228 # 80009358 <digits+0x318>
    8000327c:	ffffd097          	auipc	ra,0xffffd
    80003280:	306080e7          	jalr	774(ra) # 80000582 <printf>
	   printf("CPU burst estimation error: count: %d, avg: %d\n", estimation_error_instance, estimation_error/estimation_error_instance);
    80003284:	00007597          	auipc	a1,0x7
    80003288:	da45a583          	lw	a1,-604(a1) # 8000a028 <estimation_error_instance>
    8000328c:	00007617          	auipc	a2,0x7
    80003290:	da062603          	lw	a2,-608(a2) # 8000a02c <estimation_error>
    80003294:	02b6463b          	divw	a2,a2,a1
    80003298:	00006517          	auipc	a0,0x6
    8000329c:	10050513          	addi	a0,a0,256 # 80009398 <digits+0x358>
    800032a0:	ffffd097          	auipc	ra,0xffffd
    800032a4:	2e2080e7          	jalr	738(ra) # 80000582 <printf>
    800032a8:	b5cd                	j	8000318a <exit+0x31a>

00000000800032aa <wakeupone>:

// Wake up one processes sleeping on chan.
// Must be called without any p->lock.
void
wakeupone(void *chan)
{
    800032aa:	7139                	addi	sp,sp,-64
    800032ac:	fc06                	sd	ra,56(sp)
    800032ae:	f822                	sd	s0,48(sp)
    800032b0:	f426                	sd	s1,40(sp)
    800032b2:	f04a                	sd	s2,32(sp)
    800032b4:	ec4e                	sd	s3,24(sp)
    800032b6:	e852                	sd	s4,16(sp)
    800032b8:	e456                	sd	s5,8(sp)
    800032ba:	0080                	addi	s0,sp,64
    800032bc:	8a2a                	mv	s4,a0
  struct proc *p;
  uint xticks;

  if (!holding(&tickslock)) {
    800032be:	00016517          	auipc	a0,0x16
    800032c2:	85250513          	addi	a0,a0,-1966 # 80018b10 <tickslock>
    800032c6:	ffffe097          	auipc	ra,0xffffe
    800032ca:	88e080e7          	jalr	-1906(ra) # 80000b54 <holding>
    800032ce:	cd19                	beqz	a0,800032ec <wakeupone+0x42>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    800032d0:	00007a97          	auipc	s5,0x7
    800032d4:	d9caaa83          	lw	s5,-612(s5) # 8000a06c <ticks>

  int waken=0;
  for(p = proc; p < &proc[NPROC]; p++) {
    800032d8:	0000f497          	auipc	s1,0xf
    800032dc:	43848493          	addi	s1,s1,1080 # 80012710 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800032e0:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800032e2:	00016917          	auipc	s2,0x16
    800032e6:	82e90913          	addi	s2,s2,-2002 # 80018b10 <tickslock>
    800032ea:	a83d                	j	80003328 <wakeupone+0x7e>
     acquire(&tickslock);
    800032ec:	00016517          	auipc	a0,0x16
    800032f0:	82450513          	addi	a0,a0,-2012 # 80018b10 <tickslock>
    800032f4:	ffffe097          	auipc	ra,0xffffe
    800032f8:	8da080e7          	jalr	-1830(ra) # 80000bce <acquire>
     xticks = ticks;
    800032fc:	00007a97          	auipc	s5,0x7
    80003300:	d70aaa83          	lw	s5,-656(s5) # 8000a06c <ticks>
     release(&tickslock);
    80003304:	00016517          	auipc	a0,0x16
    80003308:	80c50513          	addi	a0,a0,-2036 # 80018b10 <tickslock>
    8000330c:	ffffe097          	auipc	ra,0xffffe
    80003310:	976080e7          	jalr	-1674(ra) # 80000c82 <release>
    80003314:	b7d1                	j	800032d8 <wakeupone+0x2e>
        p->state = RUNNABLE;
	      p->waitstart = xticks;
        waken = 1;
      }
      release(&p->lock);
    80003316:	8526                	mv	a0,s1
    80003318:	ffffe097          	auipc	ra,0xffffe
    8000331c:	96a080e7          	jalr	-1686(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80003320:	19048493          	addi	s1,s1,400
    80003324:	03248c63          	beq	s1,s2,8000335c <wakeupone+0xb2>
    if(p != myproc()){
    80003328:	ffffe097          	auipc	ra,0xffffe
    8000332c:	6c8080e7          	jalr	1736(ra) # 800019f0 <myproc>
    80003330:	fea488e3          	beq	s1,a0,80003320 <wakeupone+0x76>
      acquire(&p->lock);
    80003334:	8526                	mv	a0,s1
    80003336:	ffffe097          	auipc	ra,0xffffe
    8000333a:	898080e7          	jalr	-1896(ra) # 80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000333e:	4c9c                	lw	a5,24(s1)
    80003340:	fd379be3          	bne	a5,s3,80003316 <wakeupone+0x6c>
    80003344:	709c                	ld	a5,32(s1)
    80003346:	fd4798e3          	bne	a5,s4,80003316 <wakeupone+0x6c>
        p->state = RUNNABLE;
    8000334a:	478d                	li	a5,3
    8000334c:	cc9c                	sw	a5,24(s1)
	      p->waitstart = xticks;
    8000334e:	1954a023          	sw	s5,384(s1)
      release(&p->lock);
    80003352:	8526                	mv	a0,s1
    80003354:	ffffe097          	auipc	ra,0xffffe
    80003358:	92e080e7          	jalr	-1746(ra) # 80000c82 <release>
      if(waken)
        return;
    }
  }
}
    8000335c:	70e2                	ld	ra,56(sp)
    8000335e:	7442                	ld	s0,48(sp)
    80003360:	74a2                	ld	s1,40(sp)
    80003362:	7902                	ld	s2,32(sp)
    80003364:	69e2                	ld	s3,24(sp)
    80003366:	6a42                	ld	s4,16(sp)
    80003368:	6aa2                	ld	s5,8(sp)
    8000336a:	6121                	addi	sp,sp,64
    8000336c:	8082                	ret

000000008000336e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000336e:	7179                	addi	sp,sp,-48
    80003370:	f406                	sd	ra,40(sp)
    80003372:	f022                	sd	s0,32(sp)
    80003374:	ec26                	sd	s1,24(sp)
    80003376:	e84a                	sd	s2,16(sp)
    80003378:	e44e                	sd	s3,8(sp)
    8000337a:	e052                	sd	s4,0(sp)
    8000337c:	1800                	addi	s0,sp,48
    8000337e:	892a                	mv	s2,a0
  struct proc *p;
  uint xticks;

  acquire(&tickslock);
    80003380:	00015517          	auipc	a0,0x15
    80003384:	79050513          	addi	a0,a0,1936 # 80018b10 <tickslock>
    80003388:	ffffe097          	auipc	ra,0xffffe
    8000338c:	846080e7          	jalr	-1978(ra) # 80000bce <acquire>
  xticks = ticks;
    80003390:	00007a17          	auipc	s4,0x7
    80003394:	cdca2a03          	lw	s4,-804(s4) # 8000a06c <ticks>
  release(&tickslock);
    80003398:	00015517          	auipc	a0,0x15
    8000339c:	77850513          	addi	a0,a0,1912 # 80018b10 <tickslock>
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	8e2080e7          	jalr	-1822(ra) # 80000c82 <release>

  for(p = proc; p < &proc[NPROC]; p++){
    800033a8:	0000f497          	auipc	s1,0xf
    800033ac:	36848493          	addi	s1,s1,872 # 80012710 <proc>
    800033b0:	00015997          	auipc	s3,0x15
    800033b4:	76098993          	addi	s3,s3,1888 # 80018b10 <tickslock>
    acquire(&p->lock);
    800033b8:	8526                	mv	a0,s1
    800033ba:	ffffe097          	auipc	ra,0xffffe
    800033be:	814080e7          	jalr	-2028(ra) # 80000bce <acquire>
    if(p->pid == pid){
    800033c2:	589c                	lw	a5,48(s1)
    800033c4:	01278d63          	beq	a5,s2,800033de <kill+0x70>
	p->waitstart = xticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800033c8:	8526                	mv	a0,s1
    800033ca:	ffffe097          	auipc	ra,0xffffe
    800033ce:	8b8080e7          	jalr	-1864(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800033d2:	19048493          	addi	s1,s1,400
    800033d6:	ff3491e3          	bne	s1,s3,800033b8 <kill+0x4a>
  }
  return -1;
    800033da:	557d                	li	a0,-1
    800033dc:	a829                	j	800033f6 <kill+0x88>
      p->killed = 1;
    800033de:	4785                	li	a5,1
    800033e0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800033e2:	4c98                	lw	a4,24(s1)
    800033e4:	4789                	li	a5,2
    800033e6:	02f70063          	beq	a4,a5,80003406 <kill+0x98>
      release(&p->lock);
    800033ea:	8526                	mv	a0,s1
    800033ec:	ffffe097          	auipc	ra,0xffffe
    800033f0:	896080e7          	jalr	-1898(ra) # 80000c82 <release>
      return 0;
    800033f4:	4501                	li	a0,0
}
    800033f6:	70a2                	ld	ra,40(sp)
    800033f8:	7402                	ld	s0,32(sp)
    800033fa:	64e2                	ld	s1,24(sp)
    800033fc:	6942                	ld	s2,16(sp)
    800033fe:	69a2                	ld	s3,8(sp)
    80003400:	6a02                	ld	s4,0(sp)
    80003402:	6145                	addi	sp,sp,48
    80003404:	8082                	ret
        p->state = RUNNABLE;
    80003406:	478d                	li	a5,3
    80003408:	cc9c                	sw	a5,24(s1)
	p->waitstart = xticks;
    8000340a:	1944a023          	sw	s4,384(s1)
    8000340e:	bff1                	j	800033ea <kill+0x7c>

0000000080003410 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80003410:	7179                	addi	sp,sp,-48
    80003412:	f406                	sd	ra,40(sp)
    80003414:	f022                	sd	s0,32(sp)
    80003416:	ec26                	sd	s1,24(sp)
    80003418:	e84a                	sd	s2,16(sp)
    8000341a:	e44e                	sd	s3,8(sp)
    8000341c:	e052                	sd	s4,0(sp)
    8000341e:	1800                	addi	s0,sp,48
    80003420:	84aa                	mv	s1,a0
    80003422:	892e                	mv	s2,a1
    80003424:	89b2                	mv	s3,a2
    80003426:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80003428:	ffffe097          	auipc	ra,0xffffe
    8000342c:	5c8080e7          	jalr	1480(ra) # 800019f0 <myproc>
  if(user_dst){
    80003430:	c08d                	beqz	s1,80003452 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80003432:	86d2                	mv	a3,s4
    80003434:	864e                	mv	a2,s3
    80003436:	85ca                	mv	a1,s2
    80003438:	6d28                	ld	a0,88(a0)
    8000343a:	ffffe097          	auipc	ra,0xffffe
    8000343e:	27a080e7          	jalr	634(ra) # 800016b4 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80003442:	70a2                	ld	ra,40(sp)
    80003444:	7402                	ld	s0,32(sp)
    80003446:	64e2                	ld	s1,24(sp)
    80003448:	6942                	ld	s2,16(sp)
    8000344a:	69a2                	ld	s3,8(sp)
    8000344c:	6a02                	ld	s4,0(sp)
    8000344e:	6145                	addi	sp,sp,48
    80003450:	8082                	ret
    memmove((char *)dst, src, len);
    80003452:	000a061b          	sext.w	a2,s4
    80003456:	85ce                	mv	a1,s3
    80003458:	854a                	mv	a0,s2
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	8cc080e7          	jalr	-1844(ra) # 80000d26 <memmove>
    return 0;
    80003462:	8526                	mv	a0,s1
    80003464:	bff9                	j	80003442 <either_copyout+0x32>

0000000080003466 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80003466:	7179                	addi	sp,sp,-48
    80003468:	f406                	sd	ra,40(sp)
    8000346a:	f022                	sd	s0,32(sp)
    8000346c:	ec26                	sd	s1,24(sp)
    8000346e:	e84a                	sd	s2,16(sp)
    80003470:	e44e                	sd	s3,8(sp)
    80003472:	e052                	sd	s4,0(sp)
    80003474:	1800                	addi	s0,sp,48
    80003476:	892a                	mv	s2,a0
    80003478:	84ae                	mv	s1,a1
    8000347a:	89b2                	mv	s3,a2
    8000347c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000347e:	ffffe097          	auipc	ra,0xffffe
    80003482:	572080e7          	jalr	1394(ra) # 800019f0 <myproc>
  if(user_src){
    80003486:	c08d                	beqz	s1,800034a8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80003488:	86d2                	mv	a3,s4
    8000348a:	864e                	mv	a2,s3
    8000348c:	85ca                	mv	a1,s2
    8000348e:	6d28                	ld	a0,88(a0)
    80003490:	ffffe097          	auipc	ra,0xffffe
    80003494:	2b0080e7          	jalr	688(ra) # 80001740 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80003498:	70a2                	ld	ra,40(sp)
    8000349a:	7402                	ld	s0,32(sp)
    8000349c:	64e2                	ld	s1,24(sp)
    8000349e:	6942                	ld	s2,16(sp)
    800034a0:	69a2                	ld	s3,8(sp)
    800034a2:	6a02                	ld	s4,0(sp)
    800034a4:	6145                	addi	sp,sp,48
    800034a6:	8082                	ret
    memmove(dst, (char*)src, len);
    800034a8:	000a061b          	sext.w	a2,s4
    800034ac:	85ce                	mv	a1,s3
    800034ae:	854a                	mv	a0,s2
    800034b0:	ffffe097          	auipc	ra,0xffffe
    800034b4:	876080e7          	jalr	-1930(ra) # 80000d26 <memmove>
    return 0;
    800034b8:	8526                	mv	a0,s1
    800034ba:	bff9                	j	80003498 <either_copyin+0x32>

00000000800034bc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800034bc:	715d                	addi	sp,sp,-80
    800034be:	e486                	sd	ra,72(sp)
    800034c0:	e0a2                	sd	s0,64(sp)
    800034c2:	fc26                	sd	s1,56(sp)
    800034c4:	f84a                	sd	s2,48(sp)
    800034c6:	f44e                	sd	s3,40(sp)
    800034c8:	f052                	sd	s4,32(sp)
    800034ca:	ec56                	sd	s5,24(sp)
    800034cc:	e85a                	sd	s6,16(sp)
    800034ce:	e45e                	sd	s7,8(sp)
    800034d0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800034d2:	00006517          	auipc	a0,0x6
    800034d6:	2de50513          	addi	a0,a0,734 # 800097b0 <syscalls+0x150>
    800034da:	ffffd097          	auipc	ra,0xffffd
    800034de:	0a8080e7          	jalr	168(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800034e2:	0000f497          	auipc	s1,0xf
    800034e6:	38e48493          	addi	s1,s1,910 # 80012870 <proc+0x160>
    800034ea:	00015917          	auipc	s2,0x15
    800034ee:	78690913          	addi	s2,s2,1926 # 80018c70 <barr+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800034f2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800034f4:	00006997          	auipc	s3,0x6
    800034f8:	ee498993          	addi	s3,s3,-284 # 800093d8 <digits+0x398>
    printf("%d %s %s", p->pid, state, p->name);
    800034fc:	00006a97          	auipc	s5,0x6
    80003500:	ee4a8a93          	addi	s5,s5,-284 # 800093e0 <digits+0x3a0>
    printf("\n");
    80003504:	00006a17          	auipc	s4,0x6
    80003508:	2aca0a13          	addi	s4,s4,684 # 800097b0 <syscalls+0x150>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000350c:	00006b97          	auipc	s7,0x6
    80003510:	f6cb8b93          	addi	s7,s7,-148 # 80009478 <states.2>
    80003514:	a00d                	j	80003536 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80003516:	ed06a583          	lw	a1,-304(a3)
    8000351a:	8556                	mv	a0,s5
    8000351c:	ffffd097          	auipc	ra,0xffffd
    80003520:	066080e7          	jalr	102(ra) # 80000582 <printf>
    printf("\n");
    80003524:	8552                	mv	a0,s4
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	05c080e7          	jalr	92(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000352e:	19048493          	addi	s1,s1,400
    80003532:	03248263          	beq	s1,s2,80003556 <procdump+0x9a>
    if(p->state == UNUSED)
    80003536:	86a6                	mv	a3,s1
    80003538:	eb84a783          	lw	a5,-328(s1)
    8000353c:	dbed                	beqz	a5,8000352e <procdump+0x72>
      state = "???";
    8000353e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003540:	fcfb6be3          	bltu	s6,a5,80003516 <procdump+0x5a>
    80003544:	02079713          	slli	a4,a5,0x20
    80003548:	01d75793          	srli	a5,a4,0x1d
    8000354c:	97de                	add	a5,a5,s7
    8000354e:	6390                	ld	a2,0(a5)
    80003550:	f279                	bnez	a2,80003516 <procdump+0x5a>
      state = "???";
    80003552:	864e                	mv	a2,s3
    80003554:	b7c9                	j	80003516 <procdump+0x5a>
  }
}
    80003556:	60a6                	ld	ra,72(sp)
    80003558:	6406                	ld	s0,64(sp)
    8000355a:	74e2                	ld	s1,56(sp)
    8000355c:	7942                	ld	s2,48(sp)
    8000355e:	79a2                	ld	s3,40(sp)
    80003560:	7a02                	ld	s4,32(sp)
    80003562:	6ae2                	ld	s5,24(sp)
    80003564:	6b42                	ld	s6,16(sp)
    80003566:	6ba2                	ld	s7,8(sp)
    80003568:	6161                	addi	sp,sp,80
    8000356a:	8082                	ret

000000008000356c <ps>:

// Print a process listing to console with proper locks held.
// Caution: don't invoke too often; can slow down the machine.
int
ps(void)
{
    8000356c:	7119                	addi	sp,sp,-128
    8000356e:	fc86                	sd	ra,120(sp)
    80003570:	f8a2                	sd	s0,112(sp)
    80003572:	f4a6                	sd	s1,104(sp)
    80003574:	f0ca                	sd	s2,96(sp)
    80003576:	ecce                	sd	s3,88(sp)
    80003578:	e8d2                	sd	s4,80(sp)
    8000357a:	e4d6                	sd	s5,72(sp)
    8000357c:	e0da                	sd	s6,64(sp)
    8000357e:	fc5e                	sd	s7,56(sp)
    80003580:	f862                	sd	s8,48(sp)
    80003582:	f466                	sd	s9,40(sp)
    80003584:	f06a                	sd	s10,32(sp)
    80003586:	ec6e                	sd	s11,24(sp)
    80003588:	0100                	addi	s0,sp,128
  struct proc *p;
  char *state;
  int ppid, pid;
  uint xticks;

  printf("\n");
    8000358a:	00006517          	auipc	a0,0x6
    8000358e:	22650513          	addi	a0,a0,550 # 800097b0 <syscalls+0x150>
    80003592:	ffffd097          	auipc	ra,0xffffd
    80003596:	ff0080e7          	jalr	-16(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000359a:	0000f497          	auipc	s1,0xf
    8000359e:	17648493          	addi	s1,s1,374 # 80012710 <proc>
    acquire(&p->lock);
    if(p->state == UNUSED) {
      release(&p->lock);
      continue;
    }
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800035a2:	4d95                	li	s11,5
    else
      state = "???";

    pid = p->pid;
    release(&p->lock);
    acquire(&wait_lock);
    800035a4:	0000fb97          	auipc	s7,0xf
    800035a8:	d54b8b93          	addi	s7,s7,-684 # 800122f8 <wait_lock>
    if (p->parent) {
       acquire(&p->parent->lock);
       ppid = p->parent->pid;
       release(&p->parent->lock);
    }
    else ppid = -1;
    800035ac:	5b7d                	li	s6,-1
    release(&wait_lock);

    acquire(&tickslock);
    800035ae:	00015a97          	auipc	s5,0x15
    800035b2:	562a8a93          	addi	s5,s5,1378 # 80018b10 <tickslock>
  for(p = proc; p < &proc[NPROC]; p++){
    800035b6:	00015d17          	auipc	s10,0x15
    800035ba:	55ad0d13          	addi	s10,s10,1370 # 80018b10 <tickslock>
    800035be:	a85d                	j	80003674 <ps+0x108>
      release(&p->lock);
    800035c0:	8526                	mv	a0,s1
    800035c2:	ffffd097          	auipc	ra,0xffffd
    800035c6:	6c0080e7          	jalr	1728(ra) # 80000c82 <release>
      continue;
    800035ca:	a04d                	j	8000366c <ps+0x100>
    pid = p->pid;
    800035cc:	0304ac03          	lw	s8,48(s1)
    release(&p->lock);
    800035d0:	8526                	mv	a0,s1
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	6b0080e7          	jalr	1712(ra) # 80000c82 <release>
    acquire(&wait_lock);
    800035da:	855e                	mv	a0,s7
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	5f2080e7          	jalr	1522(ra) # 80000bce <acquire>
    if (p->parent) {
    800035e4:	60a8                	ld	a0,64(s1)
    else ppid = -1;
    800035e6:	8a5a                	mv	s4,s6
    if (p->parent) {
    800035e8:	cd01                	beqz	a0,80003600 <ps+0x94>
       acquire(&p->parent->lock);
    800035ea:	ffffd097          	auipc	ra,0xffffd
    800035ee:	5e4080e7          	jalr	1508(ra) # 80000bce <acquire>
       ppid = p->parent->pid;
    800035f2:	60a8                	ld	a0,64(s1)
    800035f4:	03052a03          	lw	s4,48(a0)
       release(&p->parent->lock);
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	68a080e7          	jalr	1674(ra) # 80000c82 <release>
    release(&wait_lock);
    80003600:	855e                	mv	a0,s7
    80003602:	ffffd097          	auipc	ra,0xffffd
    80003606:	680080e7          	jalr	1664(ra) # 80000c82 <release>
    acquire(&tickslock);
    8000360a:	8556                	mv	a0,s5
    8000360c:	ffffd097          	auipc	ra,0xffffd
    80003610:	5c2080e7          	jalr	1474(ra) # 80000bce <acquire>
    xticks = ticks;
    80003614:	00007797          	auipc	a5,0x7
    80003618:	a5878793          	addi	a5,a5,-1448 # 8000a06c <ticks>
    8000361c:	0007ac83          	lw	s9,0(a5)
    release(&tickslock);
    80003620:	8556                	mv	a0,s5
    80003622:	ffffd097          	auipc	ra,0xffffd
    80003626:	660080e7          	jalr	1632(ra) # 80000c82 <release>

    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    8000362a:	16090713          	addi	a4,s2,352
    8000362e:	1704a783          	lw	a5,368(s1)
    80003632:	1744a803          	lw	a6,372(s1)
    80003636:	1784a683          	lw	a3,376(s1)
    8000363a:	410688bb          	subw	a7,a3,a6
    8000363e:	07668b63          	beq	a3,s6,800036b4 <ps+0x148>
    80003642:	68b4                	ld	a3,80(s1)
    80003644:	e036                	sd	a3,0(sp)
    80003646:	86ce                	mv	a3,s3
    80003648:	8652                	mv	a2,s4
    8000364a:	85e2                	mv	a1,s8
    8000364c:	00006517          	auipc	a0,0x6
    80003650:	da450513          	addi	a0,a0,-604 # 800093f0 <digits+0x3b0>
    80003654:	ffffd097          	auipc	ra,0xffffd
    80003658:	f2e080e7          	jalr	-210(ra) # 80000582 <printf>
    printf("\n");
    8000365c:	00006517          	auipc	a0,0x6
    80003660:	15450513          	addi	a0,a0,340 # 800097b0 <syscalls+0x150>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	f1e080e7          	jalr	-226(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000366c:	19048493          	addi	s1,s1,400
    80003670:	05a48563          	beq	s1,s10,800036ba <ps+0x14e>
    acquire(&p->lock);
    80003674:	8926                	mv	s2,s1
    80003676:	8526                	mv	a0,s1
    80003678:	ffffd097          	auipc	ra,0xffffd
    8000367c:	556080e7          	jalr	1366(ra) # 80000bce <acquire>
    if(p->state == UNUSED) {
    80003680:	4c9c                	lw	a5,24(s1)
    80003682:	df9d                	beqz	a5,800035c0 <ps+0x54>
      state = "???";
    80003684:	00006997          	auipc	s3,0x6
    80003688:	d5498993          	addi	s3,s3,-684 # 800093d8 <digits+0x398>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000368c:	f4fde0e3          	bltu	s11,a5,800035cc <ps+0x60>
    80003690:	02079713          	slli	a4,a5,0x20
    80003694:	01d75793          	srli	a5,a4,0x1d
    80003698:	00006717          	auipc	a4,0x6
    8000369c:	de070713          	addi	a4,a4,-544 # 80009478 <states.2>
    800036a0:	97ba                	add	a5,a5,a4
    800036a2:	0307b983          	ld	s3,48(a5)
    800036a6:	f20993e3          	bnez	s3,800035cc <ps+0x60>
      state = "???";
    800036aa:	00006997          	auipc	s3,0x6
    800036ae:	d2e98993          	addi	s3,s3,-722 # 800093d8 <digits+0x398>
    800036b2:	bf29                	j	800035cc <ps+0x60>
    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    800036b4:	410c88bb          	subw	a7,s9,a6
    800036b8:	b769                	j	80003642 <ps+0xd6>
  }
  return 0;
}
    800036ba:	4501                	li	a0,0
    800036bc:	70e6                	ld	ra,120(sp)
    800036be:	7446                	ld	s0,112(sp)
    800036c0:	74a6                	ld	s1,104(sp)
    800036c2:	7906                	ld	s2,96(sp)
    800036c4:	69e6                	ld	s3,88(sp)
    800036c6:	6a46                	ld	s4,80(sp)
    800036c8:	6aa6                	ld	s5,72(sp)
    800036ca:	6b06                	ld	s6,64(sp)
    800036cc:	7be2                	ld	s7,56(sp)
    800036ce:	7c42                	ld	s8,48(sp)
    800036d0:	7ca2                	ld	s9,40(sp)
    800036d2:	7d02                	ld	s10,32(sp)
    800036d4:	6de2                	ld	s11,24(sp)
    800036d6:	6109                	addi	sp,sp,128
    800036d8:	8082                	ret

00000000800036da <pinfo>:

int
pinfo(int pid, uint64 addr)
{
    800036da:	7159                	addi	sp,sp,-112
    800036dc:	f486                	sd	ra,104(sp)
    800036de:	f0a2                	sd	s0,96(sp)
    800036e0:	eca6                	sd	s1,88(sp)
    800036e2:	e8ca                	sd	s2,80(sp)
    800036e4:	e4ce                	sd	s3,72(sp)
    800036e6:	e0d2                	sd	s4,64(sp)
    800036e8:	1880                	addi	s0,sp,112
    800036ea:	892a                	mv	s2,a0
    800036ec:	89ae                	mv	s3,a1
  struct proc *p;
  char *state;
  uint xticks;
  int found=0;

  if (pid == -1) {
    800036ee:	57fd                	li	a5,-1
     p = myproc();
     acquire(&p->lock);
     found=1;
  }
  else {
     for(p = proc; p < &proc[NPROC]; p++){
    800036f0:	0000f497          	auipc	s1,0xf
    800036f4:	02048493          	addi	s1,s1,32 # 80012710 <proc>
    800036f8:	00015a17          	auipc	s4,0x15
    800036fc:	418a0a13          	addi	s4,s4,1048 # 80018b10 <tickslock>
  if (pid == -1) {
    80003700:	02f51563          	bne	a0,a5,8000372a <pinfo+0x50>
     p = myproc();
    80003704:	ffffe097          	auipc	ra,0xffffe
    80003708:	2ec080e7          	jalr	748(ra) # 800019f0 <myproc>
    8000370c:	84aa                	mv	s1,a0
     acquire(&p->lock);
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	4c0080e7          	jalr	1216(ra) # 80000bce <acquire>
         found=1;
         break;
       }
     }
  }
  if (found) {
    80003716:	a025                	j	8000373e <pinfo+0x64>
         release(&p->lock);
    80003718:	8526                	mv	a0,s1
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	568080e7          	jalr	1384(ra) # 80000c82 <release>
     for(p = proc; p < &proc[NPROC]; p++){
    80003722:	19048493          	addi	s1,s1,400
    80003726:	13448e63          	beq	s1,s4,80003862 <pinfo+0x188>
       acquire(&p->lock);
    8000372a:	8526                	mv	a0,s1
    8000372c:	ffffd097          	auipc	ra,0xffffd
    80003730:	4a2080e7          	jalr	1186(ra) # 80000bce <acquire>
       if((p->state == UNUSED) || (p->pid != pid)) {
    80003734:	4c9c                	lw	a5,24(s1)
    80003736:	d3ed                	beqz	a5,80003718 <pinfo+0x3e>
    80003738:	589c                	lw	a5,48(s1)
    8000373a:	fd279fe3          	bne	a5,s2,80003718 <pinfo+0x3e>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000373e:	4c9c                	lw	a5,24(s1)
    80003740:	4715                	li	a4,5
         state = states[p->state];
     else
         state = "???";
    80003742:	00006917          	auipc	s2,0x6
    80003746:	c9690913          	addi	s2,s2,-874 # 800093d8 <digits+0x398>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000374a:	00f76f63          	bltu	a4,a5,80003768 <pinfo+0x8e>
    8000374e:	02079713          	slli	a4,a5,0x20
    80003752:	01d75793          	srli	a5,a4,0x1d
    80003756:	00006717          	auipc	a4,0x6
    8000375a:	d2270713          	addi	a4,a4,-734 # 80009478 <states.2>
    8000375e:	97ba                	add	a5,a5,a4
    80003760:	0607b903          	ld	s2,96(a5)
    80003764:	10090163          	beqz	s2,80003866 <pinfo+0x18c>

     pstat.pid = p->pid;
    80003768:	589c                	lw	a5,48(s1)
    8000376a:	f8f42c23          	sw	a5,-104(s0)
     release(&p->lock);
    8000376e:	8526                	mv	a0,s1
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	512080e7          	jalr	1298(ra) # 80000c82 <release>
     acquire(&wait_lock);
    80003778:	0000f517          	auipc	a0,0xf
    8000377c:	b8050513          	addi	a0,a0,-1152 # 800122f8 <wait_lock>
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	44e080e7          	jalr	1102(ra) # 80000bce <acquire>
     if (p->parent) {
    80003788:	60a8                	ld	a0,64(s1)
    8000378a:	c17d                	beqz	a0,80003870 <pinfo+0x196>
        acquire(&p->parent->lock);
    8000378c:	ffffd097          	auipc	ra,0xffffd
    80003790:	442080e7          	jalr	1090(ra) # 80000bce <acquire>
        pstat.ppid = p->parent->pid;
    80003794:	60a8                	ld	a0,64(s1)
    80003796:	591c                	lw	a5,48(a0)
    80003798:	f8f42e23          	sw	a5,-100(s0)
        release(&p->parent->lock);
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	4e6080e7          	jalr	1254(ra) # 80000c82 <release>
     }
     else pstat.ppid = -1;
     release(&wait_lock);
    800037a4:	0000f517          	auipc	a0,0xf
    800037a8:	b5450513          	addi	a0,a0,-1196 # 800122f8 <wait_lock>
    800037ac:	ffffd097          	auipc	ra,0xffffd
    800037b0:	4d6080e7          	jalr	1238(ra) # 80000c82 <release>

     acquire(&tickslock);
    800037b4:	00015517          	auipc	a0,0x15
    800037b8:	35c50513          	addi	a0,a0,860 # 80018b10 <tickslock>
    800037bc:	ffffd097          	auipc	ra,0xffffd
    800037c0:	412080e7          	jalr	1042(ra) # 80000bce <acquire>
     xticks = ticks;
    800037c4:	00007a17          	auipc	s4,0x7
    800037c8:	8a8a2a03          	lw	s4,-1880(s4) # 8000a06c <ticks>
     release(&tickslock);
    800037cc:	00015517          	auipc	a0,0x15
    800037d0:	34450513          	addi	a0,a0,836 # 80018b10 <tickslock>
    800037d4:	ffffd097          	auipc	ra,0xffffd
    800037d8:	4ae080e7          	jalr	1198(ra) # 80000c82 <release>

     safestrcpy(&pstat.state[0], state, strlen(state)+1);
    800037dc:	854a                	mv	a0,s2
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	668080e7          	jalr	1640(ra) # 80000e46 <strlen>
    800037e6:	0015061b          	addiw	a2,a0,1
    800037ea:	85ca                	mv	a1,s2
    800037ec:	fa040513          	addi	a0,s0,-96
    800037f0:	ffffd097          	auipc	ra,0xffffd
    800037f4:	624080e7          	jalr	1572(ra) # 80000e14 <safestrcpy>
     safestrcpy(&pstat.command[0], &p->name[0], sizeof(p->name));
    800037f8:	4641                	li	a2,16
    800037fa:	16048593          	addi	a1,s1,352
    800037fe:	fa840513          	addi	a0,s0,-88
    80003802:	ffffd097          	auipc	ra,0xffffd
    80003806:	612080e7          	jalr	1554(ra) # 80000e14 <safestrcpy>
     pstat.ctime = p->ctime;
    8000380a:	1704a783          	lw	a5,368(s1)
    8000380e:	faf42c23          	sw	a5,-72(s0)
     pstat.stime = p->stime;
    80003812:	1744a783          	lw	a5,372(s1)
    80003816:	faf42e23          	sw	a5,-68(s0)
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    8000381a:	1784a703          	lw	a4,376(s1)
    8000381e:	567d                	li	a2,-1
    80003820:	40f706bb          	subw	a3,a4,a5
    80003824:	04c70a63          	beq	a4,a2,80003878 <pinfo+0x19e>
    80003828:	fcd42023          	sw	a3,-64(s0)
     pstat.size = p->sz;
    8000382c:	68bc                	ld	a5,80(s1)
    8000382e:	fcf43423          	sd	a5,-56(s0)
     if(copyout(myproc()->pagetable, addr, (char *)&pstat, sizeof(pstat)) < 0) return -1;
    80003832:	ffffe097          	auipc	ra,0xffffe
    80003836:	1be080e7          	jalr	446(ra) # 800019f0 <myproc>
    8000383a:	03800693          	li	a3,56
    8000383e:	f9840613          	addi	a2,s0,-104
    80003842:	85ce                	mv	a1,s3
    80003844:	6d28                	ld	a0,88(a0)
    80003846:	ffffe097          	auipc	ra,0xffffe
    8000384a:	e6e080e7          	jalr	-402(ra) # 800016b4 <copyout>
    8000384e:	41f5551b          	sraiw	a0,a0,0x1f
     return 0;
  }
  else return -1;
}
    80003852:	70a6                	ld	ra,104(sp)
    80003854:	7406                	ld	s0,96(sp)
    80003856:	64e6                	ld	s1,88(sp)
    80003858:	6946                	ld	s2,80(sp)
    8000385a:	69a6                	ld	s3,72(sp)
    8000385c:	6a06                	ld	s4,64(sp)
    8000385e:	6165                	addi	sp,sp,112
    80003860:	8082                	ret
  else return -1;
    80003862:	557d                	li	a0,-1
    80003864:	b7fd                	j	80003852 <pinfo+0x178>
         state = "???";
    80003866:	00006917          	auipc	s2,0x6
    8000386a:	b7290913          	addi	s2,s2,-1166 # 800093d8 <digits+0x398>
    8000386e:	bded                	j	80003768 <pinfo+0x8e>
     else pstat.ppid = -1;
    80003870:	57fd                	li	a5,-1
    80003872:	f8f42e23          	sw	a5,-100(s0)
    80003876:	b73d                	j	800037a4 <pinfo+0xca>
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    80003878:	40fa06bb          	subw	a3,s4,a5
    8000387c:	b775                	j	80003828 <pinfo+0x14e>

000000008000387e <schedpolicy>:

int
schedpolicy(int x)
{
    8000387e:	1141                	addi	sp,sp,-16
    80003880:	e422                	sd	s0,8(sp)
    80003882:	0800                	addi	s0,sp,16
   int y = sched_policy;
    80003884:	00006797          	auipc	a5,0x6
    80003888:	7e478793          	addi	a5,a5,2020 # 8000a068 <sched_policy>
    8000388c:	4398                	lw	a4,0(a5)
   sched_policy = x;
    8000388e:	c388                	sw	a0,0(a5)
   return y;
}
    80003890:	853a                	mv	a0,a4
    80003892:	6422                	ld	s0,8(sp)
    80003894:	0141                	addi	sp,sp,16
    80003896:	8082                	ret

0000000080003898 <swtch>:
    80003898:	00153023          	sd	ra,0(a0)
    8000389c:	00253423          	sd	sp,8(a0)
    800038a0:	e900                	sd	s0,16(a0)
    800038a2:	ed04                	sd	s1,24(a0)
    800038a4:	03253023          	sd	s2,32(a0)
    800038a8:	03353423          	sd	s3,40(a0)
    800038ac:	03453823          	sd	s4,48(a0)
    800038b0:	03553c23          	sd	s5,56(a0)
    800038b4:	05653023          	sd	s6,64(a0)
    800038b8:	05753423          	sd	s7,72(a0)
    800038bc:	05853823          	sd	s8,80(a0)
    800038c0:	05953c23          	sd	s9,88(a0)
    800038c4:	07a53023          	sd	s10,96(a0)
    800038c8:	07b53423          	sd	s11,104(a0)
    800038cc:	0005b083          	ld	ra,0(a1)
    800038d0:	0085b103          	ld	sp,8(a1)
    800038d4:	6980                	ld	s0,16(a1)
    800038d6:	6d84                	ld	s1,24(a1)
    800038d8:	0205b903          	ld	s2,32(a1)
    800038dc:	0285b983          	ld	s3,40(a1)
    800038e0:	0305ba03          	ld	s4,48(a1)
    800038e4:	0385ba83          	ld	s5,56(a1)
    800038e8:	0405bb03          	ld	s6,64(a1)
    800038ec:	0485bb83          	ld	s7,72(a1)
    800038f0:	0505bc03          	ld	s8,80(a1)
    800038f4:	0585bc83          	ld	s9,88(a1)
    800038f8:	0605bd03          	ld	s10,96(a1)
    800038fc:	0685bd83          	ld	s11,104(a1)
    80003900:	8082                	ret

0000000080003902 <trapinit>:

extern int sched_policy;

void
trapinit(void)
{
    80003902:	1141                	addi	sp,sp,-16
    80003904:	e406                	sd	ra,8(sp)
    80003906:	e022                	sd	s0,0(sp)
    80003908:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000390a:	00006597          	auipc	a1,0x6
    8000390e:	bfe58593          	addi	a1,a1,-1026 # 80009508 <states.0+0x30>
    80003912:	00015517          	auipc	a0,0x15
    80003916:	1fe50513          	addi	a0,a0,510 # 80018b10 <tickslock>
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	224080e7          	jalr	548(ra) # 80000b3e <initlock>
}
    80003922:	60a2                	ld	ra,8(sp)
    80003924:	6402                	ld	s0,0(sp)
    80003926:	0141                	addi	sp,sp,16
    80003928:	8082                	ret

000000008000392a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000392a:	1141                	addi	sp,sp,-16
    8000392c:	e422                	sd	s0,8(sp)
    8000392e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003930:	00004797          	auipc	a5,0x4
    80003934:	d9078793          	addi	a5,a5,-624 # 800076c0 <kernelvec>
    80003938:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000393c:	6422                	ld	s0,8(sp)
    8000393e:	0141                	addi	sp,sp,16
    80003940:	8082                	ret

0000000080003942 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80003942:	1141                	addi	sp,sp,-16
    80003944:	e406                	sd	ra,8(sp)
    80003946:	e022                	sd	s0,0(sp)
    80003948:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000394a:	ffffe097          	auipc	ra,0xffffe
    8000394e:	0a6080e7          	jalr	166(ra) # 800019f0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003952:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003956:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003958:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000395c:	00004697          	auipc	a3,0x4
    80003960:	6a468693          	addi	a3,a3,1700 # 80008000 <_trampoline>
    80003964:	00004717          	auipc	a4,0x4
    80003968:	69c70713          	addi	a4,a4,1692 # 80008000 <_trampoline>
    8000396c:	8f15                	sub	a4,a4,a3
    8000396e:	040007b7          	lui	a5,0x4000
    80003972:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80003974:	07b2                	slli	a5,a5,0xc
    80003976:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003978:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000397c:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000397e:	18002673          	csrr	a2,satp
    80003982:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003984:	7130                	ld	a2,96(a0)
    80003986:	6538                	ld	a4,72(a0)
    80003988:	6585                	lui	a1,0x1
    8000398a:	972e                	add	a4,a4,a1
    8000398c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000398e:	7138                	ld	a4,96(a0)
    80003990:	00000617          	auipc	a2,0x0
    80003994:	13860613          	addi	a2,a2,312 # 80003ac8 <usertrap>
    80003998:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000399a:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000399c:	8612                	mv	a2,tp
    8000399e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800039a0:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800039a4:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800039a8:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800039ac:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800039b0:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800039b2:	6f18                	ld	a4,24(a4)
    800039b4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800039b8:	6d2c                	ld	a1,88(a0)
    800039ba:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800039bc:	00004717          	auipc	a4,0x4
    800039c0:	6d470713          	addi	a4,a4,1748 # 80008090 <userret>
    800039c4:	8f15                	sub	a4,a4,a3
    800039c6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800039c8:	577d                	li	a4,-1
    800039ca:	177e                	slli	a4,a4,0x3f
    800039cc:	8dd9                	or	a1,a1,a4
    800039ce:	02000537          	lui	a0,0x2000
    800039d2:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800039d4:	0536                	slli	a0,a0,0xd
    800039d6:	9782                	jalr	a5
}
    800039d8:	60a2                	ld	ra,8(sp)
    800039da:	6402                	ld	s0,0(sp)
    800039dc:	0141                	addi	sp,sp,16
    800039de:	8082                	ret

00000000800039e0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800039e0:	1101                	addi	sp,sp,-32
    800039e2:	ec06                	sd	ra,24(sp)
    800039e4:	e822                	sd	s0,16(sp)
    800039e6:	e426                	sd	s1,8(sp)
    800039e8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800039ea:	00015497          	auipc	s1,0x15
    800039ee:	12648493          	addi	s1,s1,294 # 80018b10 <tickslock>
    800039f2:	8526                	mv	a0,s1
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	1da080e7          	jalr	474(ra) # 80000bce <acquire>
  ticks++;
    800039fc:	00006517          	auipc	a0,0x6
    80003a00:	67050513          	addi	a0,a0,1648 # 8000a06c <ticks>
    80003a04:	411c                	lw	a5,0(a0)
    80003a06:	2785                	addiw	a5,a5,1
    80003a08:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003a0a:	fffff097          	auipc	ra,0xfffff
    80003a0e:	34a080e7          	jalr	842(ra) # 80002d54 <wakeup>
  release(&tickslock);
    80003a12:	8526                	mv	a0,s1
    80003a14:	ffffd097          	auipc	ra,0xffffd
    80003a18:	26e080e7          	jalr	622(ra) # 80000c82 <release>
}
    80003a1c:	60e2                	ld	ra,24(sp)
    80003a1e:	6442                	ld	s0,16(sp)
    80003a20:	64a2                	ld	s1,8(sp)
    80003a22:	6105                	addi	sp,sp,32
    80003a24:	8082                	ret

0000000080003a26 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003a26:	1101                	addi	sp,sp,-32
    80003a28:	ec06                	sd	ra,24(sp)
    80003a2a:	e822                	sd	s0,16(sp)
    80003a2c:	e426                	sd	s1,8(sp)
    80003a2e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003a30:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80003a34:	00074d63          	bltz	a4,80003a4e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003a38:	57fd                	li	a5,-1
    80003a3a:	17fe                	slli	a5,a5,0x3f
    80003a3c:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80003a3e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003a40:	06f70363          	beq	a4,a5,80003aa6 <devintr+0x80>
  }
}
    80003a44:	60e2                	ld	ra,24(sp)
    80003a46:	6442                	ld	s0,16(sp)
    80003a48:	64a2                	ld	s1,8(sp)
    80003a4a:	6105                	addi	sp,sp,32
    80003a4c:	8082                	ret
     (scause & 0xff) == 9){
    80003a4e:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80003a52:	46a5                	li	a3,9
    80003a54:	fed792e3          	bne	a5,a3,80003a38 <devintr+0x12>
    int irq = plic_claim();
    80003a58:	00004097          	auipc	ra,0x4
    80003a5c:	d70080e7          	jalr	-656(ra) # 800077c8 <plic_claim>
    80003a60:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003a62:	47a9                	li	a5,10
    80003a64:	02f50763          	beq	a0,a5,80003a92 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003a68:	4785                	li	a5,1
    80003a6a:	02f50963          	beq	a0,a5,80003a9c <devintr+0x76>
    return 1;
    80003a6e:	4505                	li	a0,1
    } else if(irq){
    80003a70:	d8f1                	beqz	s1,80003a44 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003a72:	85a6                	mv	a1,s1
    80003a74:	00006517          	auipc	a0,0x6
    80003a78:	a9c50513          	addi	a0,a0,-1380 # 80009510 <states.0+0x38>
    80003a7c:	ffffd097          	auipc	ra,0xffffd
    80003a80:	b06080e7          	jalr	-1274(ra) # 80000582 <printf>
      plic_complete(irq);
    80003a84:	8526                	mv	a0,s1
    80003a86:	00004097          	auipc	ra,0x4
    80003a8a:	d66080e7          	jalr	-666(ra) # 800077ec <plic_complete>
    return 1;
    80003a8e:	4505                	li	a0,1
    80003a90:	bf55                	j	80003a44 <devintr+0x1e>
      uartintr();
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	efe080e7          	jalr	-258(ra) # 80000990 <uartintr>
    80003a9a:	b7ed                	j	80003a84 <devintr+0x5e>
      virtio_disk_intr();
    80003a9c:	00004097          	auipc	ra,0x4
    80003aa0:	1dc080e7          	jalr	476(ra) # 80007c78 <virtio_disk_intr>
    80003aa4:	b7c5                	j	80003a84 <devintr+0x5e>
    if(cpuid() == 0){
    80003aa6:	ffffe097          	auipc	ra,0xffffe
    80003aaa:	f1e080e7          	jalr	-226(ra) # 800019c4 <cpuid>
    80003aae:	c901                	beqz	a0,80003abe <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003ab0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003ab4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003ab6:	14479073          	csrw	sip,a5
    return 2;
    80003aba:	4509                	li	a0,2
    80003abc:	b761                	j	80003a44 <devintr+0x1e>
      clockintr();
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	f22080e7          	jalr	-222(ra) # 800039e0 <clockintr>
    80003ac6:	b7ed                	j	80003ab0 <devintr+0x8a>

0000000080003ac8 <usertrap>:
{
    80003ac8:	1101                	addi	sp,sp,-32
    80003aca:	ec06                	sd	ra,24(sp)
    80003acc:	e822                	sd	s0,16(sp)
    80003ace:	e426                	sd	s1,8(sp)
    80003ad0:	e04a                	sd	s2,0(sp)
    80003ad2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003ad4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003ad8:	1007f793          	andi	a5,a5,256
    80003adc:	e3ad                	bnez	a5,80003b3e <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003ade:	00004797          	auipc	a5,0x4
    80003ae2:	be278793          	addi	a5,a5,-1054 # 800076c0 <kernelvec>
    80003ae6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003aea:	ffffe097          	auipc	ra,0xffffe
    80003aee:	f06080e7          	jalr	-250(ra) # 800019f0 <myproc>
    80003af2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003af4:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003af6:	14102773          	csrr	a4,sepc
    80003afa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003afc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003b00:	47a1                	li	a5,8
    80003b02:	04f71c63          	bne	a4,a5,80003b5a <usertrap+0x92>
    if(p->killed)
    80003b06:	551c                	lw	a5,40(a0)
    80003b08:	e3b9                	bnez	a5,80003b4e <usertrap+0x86>
    p->trapframe->epc += 4;
    80003b0a:	70b8                	ld	a4,96(s1)
    80003b0c:	6f1c                	ld	a5,24(a4)
    80003b0e:	0791                	addi	a5,a5,4
    80003b10:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003b12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003b16:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003b1a:	10079073          	csrw	sstatus,a5
    syscall();
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	2fc080e7          	jalr	764(ra) # 80003e1a <syscall>
  if(p->killed)
    80003b26:	549c                	lw	a5,40(s1)
    80003b28:	efd9                	bnez	a5,80003bc6 <usertrap+0xfe>
  usertrapret();
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	e18080e7          	jalr	-488(ra) # 80003942 <usertrapret>
}
    80003b32:	60e2                	ld	ra,24(sp)
    80003b34:	6442                	ld	s0,16(sp)
    80003b36:	64a2                	ld	s1,8(sp)
    80003b38:	6902                	ld	s2,0(sp)
    80003b3a:	6105                	addi	sp,sp,32
    80003b3c:	8082                	ret
    panic("usertrap: not from user mode");
    80003b3e:	00006517          	auipc	a0,0x6
    80003b42:	9f250513          	addi	a0,a0,-1550 # 80009530 <states.0+0x58>
    80003b46:	ffffd097          	auipc	ra,0xffffd
    80003b4a:	9f2080e7          	jalr	-1550(ra) # 80000538 <panic>
      exit(-1);
    80003b4e:	557d                	li	a0,-1
    80003b50:	fffff097          	auipc	ra,0xfffff
    80003b54:	320080e7          	jalr	800(ra) # 80002e70 <exit>
    80003b58:	bf4d                	j	80003b0a <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80003b5a:	00000097          	auipc	ra,0x0
    80003b5e:	ecc080e7          	jalr	-308(ra) # 80003a26 <devintr>
    80003b62:	892a                	mv	s2,a0
    80003b64:	c501                	beqz	a0,80003b6c <usertrap+0xa4>
  if(p->killed)
    80003b66:	549c                	lw	a5,40(s1)
    80003b68:	c3a1                	beqz	a5,80003ba8 <usertrap+0xe0>
    80003b6a:	a815                	j	80003b9e <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003b6c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003b70:	5890                	lw	a2,48(s1)
    80003b72:	00006517          	auipc	a0,0x6
    80003b76:	9de50513          	addi	a0,a0,-1570 # 80009550 <states.0+0x78>
    80003b7a:	ffffd097          	auipc	ra,0xffffd
    80003b7e:	a08080e7          	jalr	-1528(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003b82:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003b86:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003b8a:	00006517          	auipc	a0,0x6
    80003b8e:	9f650513          	addi	a0,a0,-1546 # 80009580 <states.0+0xa8>
    80003b92:	ffffd097          	auipc	ra,0xffffd
    80003b96:	9f0080e7          	jalr	-1552(ra) # 80000582 <printf>
    p->killed = 1;
    80003b9a:	4785                	li	a5,1
    80003b9c:	d49c                	sw	a5,40(s1)
    exit(-1);
    80003b9e:	557d                	li	a0,-1
    80003ba0:	fffff097          	auipc	ra,0xfffff
    80003ba4:	2d0080e7          	jalr	720(ra) # 80002e70 <exit>
  if(which_dev == 2) {
    80003ba8:	4789                	li	a5,2
    80003baa:	f8f910e3          	bne	s2,a5,80003b2a <usertrap+0x62>
    if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    80003bae:	00006717          	auipc	a4,0x6
    80003bb2:	4ba72703          	lw	a4,1210(a4) # 8000a068 <sched_policy>
    80003bb6:	4785                	li	a5,1
    80003bb8:	f6e7f9e3          	bgeu	a5,a4,80003b2a <usertrap+0x62>
    80003bbc:	fffff097          	auipc	ra,0xfffff
    80003bc0:	a7a080e7          	jalr	-1414(ra) # 80002636 <yield>
    80003bc4:	b79d                	j	80003b2a <usertrap+0x62>
  int which_dev = 0;
    80003bc6:	4901                	li	s2,0
    80003bc8:	bfd9                	j	80003b9e <usertrap+0xd6>

0000000080003bca <kerneltrap>:
{
    80003bca:	7179                	addi	sp,sp,-48
    80003bcc:	f406                	sd	ra,40(sp)
    80003bce:	f022                	sd	s0,32(sp)
    80003bd0:	ec26                	sd	s1,24(sp)
    80003bd2:	e84a                	sd	s2,16(sp)
    80003bd4:	e44e                	sd	s3,8(sp)
    80003bd6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003bd8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003bdc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003be0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003be4:	1004f793          	andi	a5,s1,256
    80003be8:	cb85                	beqz	a5,80003c18 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003bea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003bee:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003bf0:	ef85                	bnez	a5,80003c28 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003bf2:	00000097          	auipc	ra,0x0
    80003bf6:	e34080e7          	jalr	-460(ra) # 80003a26 <devintr>
    80003bfa:	cd1d                	beqz	a0,80003c38 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003bfc:	4789                	li	a5,2
    80003bfe:	06f50a63          	beq	a0,a5,80003c72 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003c02:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003c06:	10049073          	csrw	sstatus,s1
}
    80003c0a:	70a2                	ld	ra,40(sp)
    80003c0c:	7402                	ld	s0,32(sp)
    80003c0e:	64e2                	ld	s1,24(sp)
    80003c10:	6942                	ld	s2,16(sp)
    80003c12:	69a2                	ld	s3,8(sp)
    80003c14:	6145                	addi	sp,sp,48
    80003c16:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003c18:	00006517          	auipc	a0,0x6
    80003c1c:	98850513          	addi	a0,a0,-1656 # 800095a0 <states.0+0xc8>
    80003c20:	ffffd097          	auipc	ra,0xffffd
    80003c24:	918080e7          	jalr	-1768(ra) # 80000538 <panic>
    panic("kerneltrap: interrupts enabled");
    80003c28:	00006517          	auipc	a0,0x6
    80003c2c:	9a050513          	addi	a0,a0,-1632 # 800095c8 <states.0+0xf0>
    80003c30:	ffffd097          	auipc	ra,0xffffd
    80003c34:	908080e7          	jalr	-1784(ra) # 80000538 <panic>
    printf("scause %p\n", scause);
    80003c38:	85ce                	mv	a1,s3
    80003c3a:	00006517          	auipc	a0,0x6
    80003c3e:	9ae50513          	addi	a0,a0,-1618 # 800095e8 <states.0+0x110>
    80003c42:	ffffd097          	auipc	ra,0xffffd
    80003c46:	940080e7          	jalr	-1728(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003c4a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003c4e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003c52:	00006517          	auipc	a0,0x6
    80003c56:	9a650513          	addi	a0,a0,-1626 # 800095f8 <states.0+0x120>
    80003c5a:	ffffd097          	auipc	ra,0xffffd
    80003c5e:	928080e7          	jalr	-1752(ra) # 80000582 <printf>
    panic("kerneltrap");
    80003c62:	00006517          	auipc	a0,0x6
    80003c66:	9ae50513          	addi	a0,a0,-1618 # 80009610 <states.0+0x138>
    80003c6a:	ffffd097          	auipc	ra,0xffffd
    80003c6e:	8ce080e7          	jalr	-1842(ra) # 80000538 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003c72:	ffffe097          	auipc	ra,0xffffe
    80003c76:	d7e080e7          	jalr	-642(ra) # 800019f0 <myproc>
    80003c7a:	d541                	beqz	a0,80003c02 <kerneltrap+0x38>
    80003c7c:	ffffe097          	auipc	ra,0xffffe
    80003c80:	d74080e7          	jalr	-652(ra) # 800019f0 <myproc>
    80003c84:	4d18                	lw	a4,24(a0)
    80003c86:	4791                	li	a5,4
    80003c88:	f6f71de3          	bne	a4,a5,80003c02 <kerneltrap+0x38>
     if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    80003c8c:	00006717          	auipc	a4,0x6
    80003c90:	3dc72703          	lw	a4,988(a4) # 8000a068 <sched_policy>
    80003c94:	4785                	li	a5,1
    80003c96:	f6e7f6e3          	bgeu	a5,a4,80003c02 <kerneltrap+0x38>
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	99c080e7          	jalr	-1636(ra) # 80002636 <yield>
    80003ca2:	b785                	j	80003c02 <kerneltrap+0x38>

0000000080003ca4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003ca4:	1101                	addi	sp,sp,-32
    80003ca6:	ec06                	sd	ra,24(sp)
    80003ca8:	e822                	sd	s0,16(sp)
    80003caa:	e426                	sd	s1,8(sp)
    80003cac:	1000                	addi	s0,sp,32
    80003cae:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003cb0:	ffffe097          	auipc	ra,0xffffe
    80003cb4:	d40080e7          	jalr	-704(ra) # 800019f0 <myproc>
  switch (n) {
    80003cb8:	4795                	li	a5,5
    80003cba:	0497e163          	bltu	a5,s1,80003cfc <argraw+0x58>
    80003cbe:	048a                	slli	s1,s1,0x2
    80003cc0:	00006717          	auipc	a4,0x6
    80003cc4:	98870713          	addi	a4,a4,-1656 # 80009648 <states.0+0x170>
    80003cc8:	94ba                	add	s1,s1,a4
    80003cca:	409c                	lw	a5,0(s1)
    80003ccc:	97ba                	add	a5,a5,a4
    80003cce:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003cd0:	713c                	ld	a5,96(a0)
    80003cd2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003cd4:	60e2                	ld	ra,24(sp)
    80003cd6:	6442                	ld	s0,16(sp)
    80003cd8:	64a2                	ld	s1,8(sp)
    80003cda:	6105                	addi	sp,sp,32
    80003cdc:	8082                	ret
    return p->trapframe->a1;
    80003cde:	713c                	ld	a5,96(a0)
    80003ce0:	7fa8                	ld	a0,120(a5)
    80003ce2:	bfcd                	j	80003cd4 <argraw+0x30>
    return p->trapframe->a2;
    80003ce4:	713c                	ld	a5,96(a0)
    80003ce6:	63c8                	ld	a0,128(a5)
    80003ce8:	b7f5                	j	80003cd4 <argraw+0x30>
    return p->trapframe->a3;
    80003cea:	713c                	ld	a5,96(a0)
    80003cec:	67c8                	ld	a0,136(a5)
    80003cee:	b7dd                	j	80003cd4 <argraw+0x30>
    return p->trapframe->a4;
    80003cf0:	713c                	ld	a5,96(a0)
    80003cf2:	6bc8                	ld	a0,144(a5)
    80003cf4:	b7c5                	j	80003cd4 <argraw+0x30>
    return p->trapframe->a5;
    80003cf6:	713c                	ld	a5,96(a0)
    80003cf8:	6fc8                	ld	a0,152(a5)
    80003cfa:	bfe9                	j	80003cd4 <argraw+0x30>
  panic("argraw");
    80003cfc:	00006517          	auipc	a0,0x6
    80003d00:	92450513          	addi	a0,a0,-1756 # 80009620 <states.0+0x148>
    80003d04:	ffffd097          	auipc	ra,0xffffd
    80003d08:	834080e7          	jalr	-1996(ra) # 80000538 <panic>

0000000080003d0c <fetchaddr>:
{
    80003d0c:	1101                	addi	sp,sp,-32
    80003d0e:	ec06                	sd	ra,24(sp)
    80003d10:	e822                	sd	s0,16(sp)
    80003d12:	e426                	sd	s1,8(sp)
    80003d14:	e04a                	sd	s2,0(sp)
    80003d16:	1000                	addi	s0,sp,32
    80003d18:	84aa                	mv	s1,a0
    80003d1a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003d1c:	ffffe097          	auipc	ra,0xffffe
    80003d20:	cd4080e7          	jalr	-812(ra) # 800019f0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003d24:	693c                	ld	a5,80(a0)
    80003d26:	02f4f863          	bgeu	s1,a5,80003d56 <fetchaddr+0x4a>
    80003d2a:	00848713          	addi	a4,s1,8
    80003d2e:	02e7e663          	bltu	a5,a4,80003d5a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003d32:	46a1                	li	a3,8
    80003d34:	8626                	mv	a2,s1
    80003d36:	85ca                	mv	a1,s2
    80003d38:	6d28                	ld	a0,88(a0)
    80003d3a:	ffffe097          	auipc	ra,0xffffe
    80003d3e:	a06080e7          	jalr	-1530(ra) # 80001740 <copyin>
    80003d42:	00a03533          	snez	a0,a0
    80003d46:	40a00533          	neg	a0,a0
}
    80003d4a:	60e2                	ld	ra,24(sp)
    80003d4c:	6442                	ld	s0,16(sp)
    80003d4e:	64a2                	ld	s1,8(sp)
    80003d50:	6902                	ld	s2,0(sp)
    80003d52:	6105                	addi	sp,sp,32
    80003d54:	8082                	ret
    return -1;
    80003d56:	557d                	li	a0,-1
    80003d58:	bfcd                	j	80003d4a <fetchaddr+0x3e>
    80003d5a:	557d                	li	a0,-1
    80003d5c:	b7fd                	j	80003d4a <fetchaddr+0x3e>

0000000080003d5e <fetchstr>:
{
    80003d5e:	7179                	addi	sp,sp,-48
    80003d60:	f406                	sd	ra,40(sp)
    80003d62:	f022                	sd	s0,32(sp)
    80003d64:	ec26                	sd	s1,24(sp)
    80003d66:	e84a                	sd	s2,16(sp)
    80003d68:	e44e                	sd	s3,8(sp)
    80003d6a:	1800                	addi	s0,sp,48
    80003d6c:	892a                	mv	s2,a0
    80003d6e:	84ae                	mv	s1,a1
    80003d70:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003d72:	ffffe097          	auipc	ra,0xffffe
    80003d76:	c7e080e7          	jalr	-898(ra) # 800019f0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003d7a:	86ce                	mv	a3,s3
    80003d7c:	864a                	mv	a2,s2
    80003d7e:	85a6                	mv	a1,s1
    80003d80:	6d28                	ld	a0,88(a0)
    80003d82:	ffffe097          	auipc	ra,0xffffe
    80003d86:	a4c080e7          	jalr	-1460(ra) # 800017ce <copyinstr>
  if(err < 0)
    80003d8a:	00054763          	bltz	a0,80003d98 <fetchstr+0x3a>
  return strlen(buf);
    80003d8e:	8526                	mv	a0,s1
    80003d90:	ffffd097          	auipc	ra,0xffffd
    80003d94:	0b6080e7          	jalr	182(ra) # 80000e46 <strlen>
}
    80003d98:	70a2                	ld	ra,40(sp)
    80003d9a:	7402                	ld	s0,32(sp)
    80003d9c:	64e2                	ld	s1,24(sp)
    80003d9e:	6942                	ld	s2,16(sp)
    80003da0:	69a2                	ld	s3,8(sp)
    80003da2:	6145                	addi	sp,sp,48
    80003da4:	8082                	ret

0000000080003da6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003da6:	1101                	addi	sp,sp,-32
    80003da8:	ec06                	sd	ra,24(sp)
    80003daa:	e822                	sd	s0,16(sp)
    80003dac:	e426                	sd	s1,8(sp)
    80003dae:	1000                	addi	s0,sp,32
    80003db0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003db2:	00000097          	auipc	ra,0x0
    80003db6:	ef2080e7          	jalr	-270(ra) # 80003ca4 <argraw>
    80003dba:	c088                	sw	a0,0(s1)
  return 0;
}
    80003dbc:	4501                	li	a0,0
    80003dbe:	60e2                	ld	ra,24(sp)
    80003dc0:	6442                	ld	s0,16(sp)
    80003dc2:	64a2                	ld	s1,8(sp)
    80003dc4:	6105                	addi	sp,sp,32
    80003dc6:	8082                	ret

0000000080003dc8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003dc8:	1101                	addi	sp,sp,-32
    80003dca:	ec06                	sd	ra,24(sp)
    80003dcc:	e822                	sd	s0,16(sp)
    80003dce:	e426                	sd	s1,8(sp)
    80003dd0:	1000                	addi	s0,sp,32
    80003dd2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	ed0080e7          	jalr	-304(ra) # 80003ca4 <argraw>
    80003ddc:	e088                	sd	a0,0(s1)
  return 0;
}
    80003dde:	4501                	li	a0,0
    80003de0:	60e2                	ld	ra,24(sp)
    80003de2:	6442                	ld	s0,16(sp)
    80003de4:	64a2                	ld	s1,8(sp)
    80003de6:	6105                	addi	sp,sp,32
    80003de8:	8082                	ret

0000000080003dea <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003dea:	1101                	addi	sp,sp,-32
    80003dec:	ec06                	sd	ra,24(sp)
    80003dee:	e822                	sd	s0,16(sp)
    80003df0:	e426                	sd	s1,8(sp)
    80003df2:	e04a                	sd	s2,0(sp)
    80003df4:	1000                	addi	s0,sp,32
    80003df6:	84ae                	mv	s1,a1
    80003df8:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003dfa:	00000097          	auipc	ra,0x0
    80003dfe:	eaa080e7          	jalr	-342(ra) # 80003ca4 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003e02:	864a                	mv	a2,s2
    80003e04:	85a6                	mv	a1,s1
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	f58080e7          	jalr	-168(ra) # 80003d5e <fetchstr>
}
    80003e0e:	60e2                	ld	ra,24(sp)
    80003e10:	6442                	ld	s0,16(sp)
    80003e12:	64a2                	ld	s1,8(sp)
    80003e14:	6902                	ld	s2,0(sp)
    80003e16:	6105                	addi	sp,sp,32
    80003e18:	8082                	ret

0000000080003e1a <syscall>:
[SYS_sem_consume] sys_sem_consume,
};

void
syscall(void)
{
    80003e1a:	1101                	addi	sp,sp,-32
    80003e1c:	ec06                	sd	ra,24(sp)
    80003e1e:	e822                	sd	s0,16(sp)
    80003e20:	e426                	sd	s1,8(sp)
    80003e22:	e04a                	sd	s2,0(sp)
    80003e24:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003e26:	ffffe097          	auipc	ra,0xffffe
    80003e2a:	bca080e7          	jalr	-1078(ra) # 800019f0 <myproc>
    80003e2e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003e30:	06053903          	ld	s2,96(a0)
    80003e34:	0a893783          	ld	a5,168(s2)
    80003e38:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003e3c:	37fd                	addiw	a5,a5,-1
    80003e3e:	02600713          	li	a4,38
    80003e42:	00f76f63          	bltu	a4,a5,80003e60 <syscall+0x46>
    80003e46:	00369713          	slli	a4,a3,0x3
    80003e4a:	00006797          	auipc	a5,0x6
    80003e4e:	81678793          	addi	a5,a5,-2026 # 80009660 <syscalls>
    80003e52:	97ba                	add	a5,a5,a4
    80003e54:	639c                	ld	a5,0(a5)
    80003e56:	c789                	beqz	a5,80003e60 <syscall+0x46>
    p->trapframe->a0 = syscalls[num]();
    80003e58:	9782                	jalr	a5
    80003e5a:	06a93823          	sd	a0,112(s2)
    80003e5e:	a839                	j	80003e7c <syscall+0x62>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003e60:	16048613          	addi	a2,s1,352
    80003e64:	588c                	lw	a1,48(s1)
    80003e66:	00005517          	auipc	a0,0x5
    80003e6a:	7c250513          	addi	a0,a0,1986 # 80009628 <states.0+0x150>
    80003e6e:	ffffc097          	auipc	ra,0xffffc
    80003e72:	714080e7          	jalr	1812(ra) # 80000582 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003e76:	70bc                	ld	a5,96(s1)
    80003e78:	577d                	li	a4,-1
    80003e7a:	fbb8                	sd	a4,112(a5)
  }
}
    80003e7c:	60e2                	ld	ra,24(sp)
    80003e7e:	6442                	ld	s0,16(sp)
    80003e80:	64a2                	ld	s1,8(sp)
    80003e82:	6902                	ld	s2,0(sp)
    80003e84:	6105                	addi	sp,sp,32
    80003e86:	8082                	ret

0000000080003e88 <sys_exit>:
int nextp, nextc;
struct sem_t pro, con, empty, full;

uint64
sys_exit(void)
{
    80003e88:	1101                	addi	sp,sp,-32
    80003e8a:	ec06                	sd	ra,24(sp)
    80003e8c:	e822                	sd	s0,16(sp)
    80003e8e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003e90:	fec40593          	addi	a1,s0,-20
    80003e94:	4501                	li	a0,0
    80003e96:	00000097          	auipc	ra,0x0
    80003e9a:	f10080e7          	jalr	-240(ra) # 80003da6 <argint>
    return -1;
    80003e9e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003ea0:	00054963          	bltz	a0,80003eb2 <sys_exit+0x2a>
  exit(n);
    80003ea4:	fec42503          	lw	a0,-20(s0)
    80003ea8:	fffff097          	auipc	ra,0xfffff
    80003eac:	fc8080e7          	jalr	-56(ra) # 80002e70 <exit>
  return 0;  // not reached
    80003eb0:	4781                	li	a5,0
}
    80003eb2:	853e                	mv	a0,a5
    80003eb4:	60e2                	ld	ra,24(sp)
    80003eb6:	6442                	ld	s0,16(sp)
    80003eb8:	6105                	addi	sp,sp,32
    80003eba:	8082                	ret

0000000080003ebc <sys_getpid>:

uint64
sys_getpid(void)
{
    80003ebc:	1141                	addi	sp,sp,-16
    80003ebe:	e406                	sd	ra,8(sp)
    80003ec0:	e022                	sd	s0,0(sp)
    80003ec2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003ec4:	ffffe097          	auipc	ra,0xffffe
    80003ec8:	b2c080e7          	jalr	-1236(ra) # 800019f0 <myproc>
}
    80003ecc:	5908                	lw	a0,48(a0)
    80003ece:	60a2                	ld	ra,8(sp)
    80003ed0:	6402                	ld	s0,0(sp)
    80003ed2:	0141                	addi	sp,sp,16
    80003ed4:	8082                	ret

0000000080003ed6 <sys_fork>:

uint64
sys_fork(void)
{
    80003ed6:	1141                	addi	sp,sp,-16
    80003ed8:	e406                	sd	ra,8(sp)
    80003eda:	e022                	sd	s0,0(sp)
    80003edc:	0800                	addi	s0,sp,16
  return fork();
    80003ede:	ffffe097          	auipc	ra,0xffffe
    80003ee2:	f5a080e7          	jalr	-166(ra) # 80001e38 <fork>
}
    80003ee6:	60a2                	ld	ra,8(sp)
    80003ee8:	6402                	ld	s0,0(sp)
    80003eea:	0141                	addi	sp,sp,16
    80003eec:	8082                	ret

0000000080003eee <sys_wait>:

uint64
sys_wait(void)
{
    80003eee:	1101                	addi	sp,sp,-32
    80003ef0:	ec06                	sd	ra,24(sp)
    80003ef2:	e822                	sd	s0,16(sp)
    80003ef4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003ef6:	fe840593          	addi	a1,s0,-24
    80003efa:	4501                	li	a0,0
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	ecc080e7          	jalr	-308(ra) # 80003dc8 <argaddr>
    80003f04:	87aa                	mv	a5,a0
    return -1;
    80003f06:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003f08:	0007c863          	bltz	a5,80003f18 <sys_wait+0x2a>
  return wait(p);
    80003f0c:	fe843503          	ld	a0,-24(s0)
    80003f10:	fffff097          	auipc	ra,0xfffff
    80003f14:	a40080e7          	jalr	-1472(ra) # 80002950 <wait>
}
    80003f18:	60e2                	ld	ra,24(sp)
    80003f1a:	6442                	ld	s0,16(sp)
    80003f1c:	6105                	addi	sp,sp,32
    80003f1e:	8082                	ret

0000000080003f20 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003f20:	7179                	addi	sp,sp,-48
    80003f22:	f406                	sd	ra,40(sp)
    80003f24:	f022                	sd	s0,32(sp)
    80003f26:	ec26                	sd	s1,24(sp)
    80003f28:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003f2a:	fdc40593          	addi	a1,s0,-36
    80003f2e:	4501                	li	a0,0
    80003f30:	00000097          	auipc	ra,0x0
    80003f34:	e76080e7          	jalr	-394(ra) # 80003da6 <argint>
    80003f38:	87aa                	mv	a5,a0
    return -1;
    80003f3a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003f3c:	0207c063          	bltz	a5,80003f5c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003f40:	ffffe097          	auipc	ra,0xffffe
    80003f44:	ab0080e7          	jalr	-1360(ra) # 800019f0 <myproc>
    80003f48:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80003f4a:	fdc42503          	lw	a0,-36(s0)
    80003f4e:	ffffe097          	auipc	ra,0xffffe
    80003f52:	e72080e7          	jalr	-398(ra) # 80001dc0 <growproc>
    80003f56:	00054863          	bltz	a0,80003f66 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003f5a:	8526                	mv	a0,s1
}
    80003f5c:	70a2                	ld	ra,40(sp)
    80003f5e:	7402                	ld	s0,32(sp)
    80003f60:	64e2                	ld	s1,24(sp)
    80003f62:	6145                	addi	sp,sp,48
    80003f64:	8082                	ret
    return -1;
    80003f66:	557d                	li	a0,-1
    80003f68:	bfd5                	j	80003f5c <sys_sbrk+0x3c>

0000000080003f6a <sys_sleep>:

uint64
sys_sleep(void)
{
    80003f6a:	7139                	addi	sp,sp,-64
    80003f6c:	fc06                	sd	ra,56(sp)
    80003f6e:	f822                	sd	s0,48(sp)
    80003f70:	f426                	sd	s1,40(sp)
    80003f72:	f04a                	sd	s2,32(sp)
    80003f74:	ec4e                	sd	s3,24(sp)
    80003f76:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003f78:	fcc40593          	addi	a1,s0,-52
    80003f7c:	4501                	li	a0,0
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	e28080e7          	jalr	-472(ra) # 80003da6 <argint>
    return -1;
    80003f86:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003f88:	06054563          	bltz	a0,80003ff2 <sys_sleep+0x88>
  acquire(&tickslock);
    80003f8c:	00015517          	auipc	a0,0x15
    80003f90:	b8450513          	addi	a0,a0,-1148 # 80018b10 <tickslock>
    80003f94:	ffffd097          	auipc	ra,0xffffd
    80003f98:	c3a080e7          	jalr	-966(ra) # 80000bce <acquire>
  ticks0 = ticks;
    80003f9c:	00006917          	auipc	s2,0x6
    80003fa0:	0d092903          	lw	s2,208(s2) # 8000a06c <ticks>
  while(ticks - ticks0 < n){
    80003fa4:	fcc42783          	lw	a5,-52(s0)
    80003fa8:	cf85                	beqz	a5,80003fe0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003faa:	00015997          	auipc	s3,0x15
    80003fae:	b6698993          	addi	s3,s3,-1178 # 80018b10 <tickslock>
    80003fb2:	00006497          	auipc	s1,0x6
    80003fb6:	0ba48493          	addi	s1,s1,186 # 8000a06c <ticks>
    if(myproc()->killed){
    80003fba:	ffffe097          	auipc	ra,0xffffe
    80003fbe:	a36080e7          	jalr	-1482(ra) # 800019f0 <myproc>
    80003fc2:	551c                	lw	a5,40(a0)
    80003fc4:	ef9d                	bnez	a5,80004002 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003fc6:	85ce                	mv	a1,s3
    80003fc8:	8526                	mv	a0,s1
    80003fca:	ffffe097          	auipc	ra,0xffffe
    80003fce:	7d8080e7          	jalr	2008(ra) # 800027a2 <sleep>
  while(ticks - ticks0 < n){
    80003fd2:	409c                	lw	a5,0(s1)
    80003fd4:	412787bb          	subw	a5,a5,s2
    80003fd8:	fcc42703          	lw	a4,-52(s0)
    80003fdc:	fce7efe3          	bltu	a5,a4,80003fba <sys_sleep+0x50>
  }
  release(&tickslock);
    80003fe0:	00015517          	auipc	a0,0x15
    80003fe4:	b3050513          	addi	a0,a0,-1232 # 80018b10 <tickslock>
    80003fe8:	ffffd097          	auipc	ra,0xffffd
    80003fec:	c9a080e7          	jalr	-870(ra) # 80000c82 <release>
  return 0;
    80003ff0:	4781                	li	a5,0
}
    80003ff2:	853e                	mv	a0,a5
    80003ff4:	70e2                	ld	ra,56(sp)
    80003ff6:	7442                	ld	s0,48(sp)
    80003ff8:	74a2                	ld	s1,40(sp)
    80003ffa:	7902                	ld	s2,32(sp)
    80003ffc:	69e2                	ld	s3,24(sp)
    80003ffe:	6121                	addi	sp,sp,64
    80004000:	8082                	ret
      release(&tickslock);
    80004002:	00015517          	auipc	a0,0x15
    80004006:	b0e50513          	addi	a0,a0,-1266 # 80018b10 <tickslock>
    8000400a:	ffffd097          	auipc	ra,0xffffd
    8000400e:	c78080e7          	jalr	-904(ra) # 80000c82 <release>
      return -1;
    80004012:	57fd                	li	a5,-1
    80004014:	bff9                	j	80003ff2 <sys_sleep+0x88>

0000000080004016 <sys_kill>:

uint64
sys_kill(void)
{
    80004016:	1101                	addi	sp,sp,-32
    80004018:	ec06                	sd	ra,24(sp)
    8000401a:	e822                	sd	s0,16(sp)
    8000401c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000401e:	fec40593          	addi	a1,s0,-20
    80004022:	4501                	li	a0,0
    80004024:	00000097          	auipc	ra,0x0
    80004028:	d82080e7          	jalr	-638(ra) # 80003da6 <argint>
    8000402c:	87aa                	mv	a5,a0
    return -1;
    8000402e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80004030:	0007c863          	bltz	a5,80004040 <sys_kill+0x2a>
  return kill(pid);
    80004034:	fec42503          	lw	a0,-20(s0)
    80004038:	fffff097          	auipc	ra,0xfffff
    8000403c:	336080e7          	jalr	822(ra) # 8000336e <kill>
}
    80004040:	60e2                	ld	ra,24(sp)
    80004042:	6442                	ld	s0,16(sp)
    80004044:	6105                	addi	sp,sp,32
    80004046:	8082                	ret

0000000080004048 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80004048:	1101                	addi	sp,sp,-32
    8000404a:	ec06                	sd	ra,24(sp)
    8000404c:	e822                	sd	s0,16(sp)
    8000404e:	e426                	sd	s1,8(sp)
    80004050:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80004052:	00015517          	auipc	a0,0x15
    80004056:	abe50513          	addi	a0,a0,-1346 # 80018b10 <tickslock>
    8000405a:	ffffd097          	auipc	ra,0xffffd
    8000405e:	b74080e7          	jalr	-1164(ra) # 80000bce <acquire>
  xticks = ticks;
    80004062:	00006497          	auipc	s1,0x6
    80004066:	00a4a483          	lw	s1,10(s1) # 8000a06c <ticks>
  release(&tickslock);
    8000406a:	00015517          	auipc	a0,0x15
    8000406e:	aa650513          	addi	a0,a0,-1370 # 80018b10 <tickslock>
    80004072:	ffffd097          	auipc	ra,0xffffd
    80004076:	c10080e7          	jalr	-1008(ra) # 80000c82 <release>
  return xticks;
}
    8000407a:	02049513          	slli	a0,s1,0x20
    8000407e:	9101                	srli	a0,a0,0x20
    80004080:	60e2                	ld	ra,24(sp)
    80004082:	6442                	ld	s0,16(sp)
    80004084:	64a2                	ld	s1,8(sp)
    80004086:	6105                	addi	sp,sp,32
    80004088:	8082                	ret

000000008000408a <sys_getppid>:

uint64
sys_getppid(void)
{
    8000408a:	1141                	addi	sp,sp,-16
    8000408c:	e406                	sd	ra,8(sp)
    8000408e:	e022                	sd	s0,0(sp)
    80004090:	0800                	addi	s0,sp,16
  if (myproc()->parent) return myproc()->parent->pid;
    80004092:	ffffe097          	auipc	ra,0xffffe
    80004096:	95e080e7          	jalr	-1698(ra) # 800019f0 <myproc>
    8000409a:	613c                	ld	a5,64(a0)
    8000409c:	cb99                	beqz	a5,800040b2 <sys_getppid+0x28>
    8000409e:	ffffe097          	auipc	ra,0xffffe
    800040a2:	952080e7          	jalr	-1710(ra) # 800019f0 <myproc>
    800040a6:	613c                	ld	a5,64(a0)
    800040a8:	5b88                	lw	a0,48(a5)
  else {
     printf("No parent found.\n");
     return 0;
  }
}
    800040aa:	60a2                	ld	ra,8(sp)
    800040ac:	6402                	ld	s0,0(sp)
    800040ae:	0141                	addi	sp,sp,16
    800040b0:	8082                	ret
     printf("No parent found.\n");
    800040b2:	00005517          	auipc	a0,0x5
    800040b6:	6ee50513          	addi	a0,a0,1774 # 800097a0 <syscalls+0x140>
    800040ba:	ffffc097          	auipc	ra,0xffffc
    800040be:	4c8080e7          	jalr	1224(ra) # 80000582 <printf>
     return 0;
    800040c2:	4501                	li	a0,0
    800040c4:	b7dd                	j	800040aa <sys_getppid+0x20>

00000000800040c6 <sys_yield>:

uint64
sys_yield(void)
{
    800040c6:	1141                	addi	sp,sp,-16
    800040c8:	e406                	sd	ra,8(sp)
    800040ca:	e022                	sd	s0,0(sp)
    800040cc:	0800                	addi	s0,sp,16
  yield();
    800040ce:	ffffe097          	auipc	ra,0xffffe
    800040d2:	568080e7          	jalr	1384(ra) # 80002636 <yield>
  return 0;
}
    800040d6:	4501                	li	a0,0
    800040d8:	60a2                	ld	ra,8(sp)
    800040da:	6402                	ld	s0,0(sp)
    800040dc:	0141                	addi	sp,sp,16
    800040de:	8082                	ret

00000000800040e0 <sys_getpa>:

uint64
sys_getpa(void)
{
    800040e0:	1101                	addi	sp,sp,-32
    800040e2:	ec06                	sd	ra,24(sp)
    800040e4:	e822                	sd	s0,16(sp)
    800040e6:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    800040e8:	fe840593          	addi	a1,s0,-24
    800040ec:	4501                	li	a0,0
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	cda080e7          	jalr	-806(ra) # 80003dc8 <argaddr>
    800040f6:	87aa                	mv	a5,a0
    800040f8:	557d                	li	a0,-1
    800040fa:	0207c263          	bltz	a5,8000411e <sys_getpa+0x3e>
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
    800040fe:	ffffe097          	auipc	ra,0xffffe
    80004102:	8f2080e7          	jalr	-1806(ra) # 800019f0 <myproc>
    80004106:	fe843583          	ld	a1,-24(s0)
    8000410a:	6d28                	ld	a0,88(a0)
    8000410c:	ffffd097          	auipc	ra,0xffffd
    80004110:	fa0080e7          	jalr	-96(ra) # 800010ac <walkaddr>
    80004114:	fe843783          	ld	a5,-24(s0)
    80004118:	17d2                	slli	a5,a5,0x34
    8000411a:	93d1                	srli	a5,a5,0x34
    8000411c:	953e                	add	a0,a0,a5
}
    8000411e:	60e2                	ld	ra,24(sp)
    80004120:	6442                	ld	s0,16(sp)
    80004122:	6105                	addi	sp,sp,32
    80004124:	8082                	ret

0000000080004126 <sys_forkf>:

uint64
sys_forkf(void)
{
    80004126:	1101                	addi	sp,sp,-32
    80004128:	ec06                	sd	ra,24(sp)
    8000412a:	e822                	sd	s0,16(sp)
    8000412c:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    8000412e:	fe840593          	addi	a1,s0,-24
    80004132:	4501                	li	a0,0
    80004134:	00000097          	auipc	ra,0x0
    80004138:	c94080e7          	jalr	-876(ra) # 80003dc8 <argaddr>
    8000413c:	87aa                	mv	a5,a0
    8000413e:	557d                	li	a0,-1
    80004140:	0007c863          	bltz	a5,80004150 <sys_forkf+0x2a>
  return forkf(x);
    80004144:	fe843503          	ld	a0,-24(s0)
    80004148:	ffffe097          	auipc	ra,0xffffe
    8000414c:	e30080e7          	jalr	-464(ra) # 80001f78 <forkf>
}
    80004150:	60e2                	ld	ra,24(sp)
    80004152:	6442                	ld	s0,16(sp)
    80004154:	6105                	addi	sp,sp,32
    80004156:	8082                	ret

0000000080004158 <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80004158:	1101                	addi	sp,sp,-32
    8000415a:	ec06                	sd	ra,24(sp)
    8000415c:	e822                	sd	s0,16(sp)
    8000415e:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    80004160:	fe440593          	addi	a1,s0,-28
    80004164:	4501                	li	a0,0
    80004166:	00000097          	auipc	ra,0x0
    8000416a:	c40080e7          	jalr	-960(ra) # 80003da6 <argint>
    return -1;
    8000416e:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    80004170:	02054c63          	bltz	a0,800041a8 <sys_waitpid+0x50>
  if(argaddr(1, &p) < 0)
    80004174:	fe840593          	addi	a1,s0,-24
    80004178:	4505                	li	a0,1
    8000417a:	00000097          	auipc	ra,0x0
    8000417e:	c4e080e7          	jalr	-946(ra) # 80003dc8 <argaddr>
    80004182:	04054063          	bltz	a0,800041c2 <sys_waitpid+0x6a>
    return -1;

  if (x == -1) return wait(p);
    80004186:	fe442503          	lw	a0,-28(s0)
    8000418a:	57fd                	li	a5,-1
    8000418c:	02f50363          	beq	a0,a5,800041b2 <sys_waitpid+0x5a>
  if ((x == 0) || (x < -1)) return -1;
    80004190:	57fd                	li	a5,-1
    80004192:	c919                	beqz	a0,800041a8 <sys_waitpid+0x50>
    80004194:	577d                	li	a4,-1
    80004196:	00e54963          	blt	a0,a4,800041a8 <sys_waitpid+0x50>
  return waitpid(x, p);
    8000419a:	fe843583          	ld	a1,-24(s0)
    8000419e:	fffff097          	auipc	ra,0xfffff
    800041a2:	8da080e7          	jalr	-1830(ra) # 80002a78 <waitpid>
    800041a6:	87aa                	mv	a5,a0
}
    800041a8:	853e                	mv	a0,a5
    800041aa:	60e2                	ld	ra,24(sp)
    800041ac:	6442                	ld	s0,16(sp)
    800041ae:	6105                	addi	sp,sp,32
    800041b0:	8082                	ret
  if (x == -1) return wait(p);
    800041b2:	fe843503          	ld	a0,-24(s0)
    800041b6:	ffffe097          	auipc	ra,0xffffe
    800041ba:	79a080e7          	jalr	1946(ra) # 80002950 <wait>
    800041be:	87aa                	mv	a5,a0
    800041c0:	b7e5                	j	800041a8 <sys_waitpid+0x50>
    return -1;
    800041c2:	57fd                	li	a5,-1
    800041c4:	b7d5                	j	800041a8 <sys_waitpid+0x50>

00000000800041c6 <sys_ps>:

uint64
sys_ps(void)
{
    800041c6:	1141                	addi	sp,sp,-16
    800041c8:	e406                	sd	ra,8(sp)
    800041ca:	e022                	sd	s0,0(sp)
    800041cc:	0800                	addi	s0,sp,16
   return ps();
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	39e080e7          	jalr	926(ra) # 8000356c <ps>
}
    800041d6:	60a2                	ld	ra,8(sp)
    800041d8:	6402                	ld	s0,0(sp)
    800041da:	0141                	addi	sp,sp,16
    800041dc:	8082                	ret

00000000800041de <sys_pinfo>:

uint64
sys_pinfo(void)
{
    800041de:	1101                	addi	sp,sp,-32
    800041e0:	ec06                	sd	ra,24(sp)
    800041e2:	e822                	sd	s0,16(sp)
    800041e4:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    800041e6:	fe440593          	addi	a1,s0,-28
    800041ea:	4501                	li	a0,0
    800041ec:	00000097          	auipc	ra,0x0
    800041f0:	bba080e7          	jalr	-1094(ra) # 80003da6 <argint>
    return -1;
    800041f4:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    800041f6:	02054963          	bltz	a0,80004228 <sys_pinfo+0x4a>
  if(argaddr(1, &p) < 0)
    800041fa:	fe840593          	addi	a1,s0,-24
    800041fe:	4505                	li	a0,1
    80004200:	00000097          	auipc	ra,0x0
    80004204:	bc8080e7          	jalr	-1080(ra) # 80003dc8 <argaddr>
    80004208:	02054563          	bltz	a0,80004232 <sys_pinfo+0x54>
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    8000420c:	fe442503          	lw	a0,-28(s0)
    80004210:	57fd                	li	a5,-1
    80004212:	c919                	beqz	a0,80004228 <sys_pinfo+0x4a>
    80004214:	02f54163          	blt	a0,a5,80004236 <sys_pinfo+0x58>
    80004218:	fe843583          	ld	a1,-24(s0)
    8000421c:	c591                	beqz	a1,80004228 <sys_pinfo+0x4a>
  return pinfo(x, p);
    8000421e:	fffff097          	auipc	ra,0xfffff
    80004222:	4bc080e7          	jalr	1212(ra) # 800036da <pinfo>
    80004226:	87aa                	mv	a5,a0
}
    80004228:	853e                	mv	a0,a5
    8000422a:	60e2                	ld	ra,24(sp)
    8000422c:	6442                	ld	s0,16(sp)
    8000422e:	6105                	addi	sp,sp,32
    80004230:	8082                	ret
    return -1;
    80004232:	57fd                	li	a5,-1
    80004234:	bfd5                	j	80004228 <sys_pinfo+0x4a>
  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    80004236:	57fd                	li	a5,-1
    80004238:	bfc5                	j	80004228 <sys_pinfo+0x4a>

000000008000423a <sys_forkp>:

uint64
sys_forkp(void)
{
    8000423a:	1101                	addi	sp,sp,-32
    8000423c:	ec06                	sd	ra,24(sp)
    8000423e:	e822                	sd	s0,16(sp)
    80004240:	1000                	addi	s0,sp,32
  int x;
  if(argint(0, &x) < 0) return -1;
    80004242:	fec40593          	addi	a1,s0,-20
    80004246:	4501                	li	a0,0
    80004248:	00000097          	auipc	ra,0x0
    8000424c:	b5e080e7          	jalr	-1186(ra) # 80003da6 <argint>
    80004250:	87aa                	mv	a5,a0
    80004252:	557d                	li	a0,-1
    80004254:	0007c863          	bltz	a5,80004264 <sys_forkp+0x2a>
  return forkp(x);
    80004258:	fec42503          	lw	a0,-20(s0)
    8000425c:	ffffe097          	auipc	ra,0xffffe
    80004260:	e68080e7          	jalr	-408(ra) # 800020c4 <forkp>
}
    80004264:	60e2                	ld	ra,24(sp)
    80004266:	6442                	ld	s0,16(sp)
    80004268:	6105                	addi	sp,sp,32
    8000426a:	8082                	ret

000000008000426c <sys_schedpolicy>:

uint64
sys_schedpolicy(void)
{
    8000426c:	1101                	addi	sp,sp,-32
    8000426e:	ec06                	sd	ra,24(sp)
    80004270:	e822                	sd	s0,16(sp)
    80004272:	1000                	addi	s0,sp,32
  int x;
  if(argint(0, &x) < 0) return -1;
    80004274:	fec40593          	addi	a1,s0,-20
    80004278:	4501                	li	a0,0
    8000427a:	00000097          	auipc	ra,0x0
    8000427e:	b2c080e7          	jalr	-1236(ra) # 80003da6 <argint>
    80004282:	87aa                	mv	a5,a0
    80004284:	557d                	li	a0,-1
    80004286:	0007c863          	bltz	a5,80004296 <sys_schedpolicy+0x2a>
  return schedpolicy(x);
    8000428a:	fec42503          	lw	a0,-20(s0)
    8000428e:	fffff097          	auipc	ra,0xfffff
    80004292:	5f0080e7          	jalr	1520(ra) # 8000387e <schedpolicy>
}
    80004296:	60e2                	ld	ra,24(sp)
    80004298:	6442                	ld	s0,16(sp)
    8000429a:	6105                	addi	sp,sp,32
    8000429c:	8082                	ret

000000008000429e <sys_barrier>:

uint64 
sys_barrier(void)
{
    8000429e:	7179                	addi	sp,sp,-48
    800042a0:	f406                	sd	ra,40(sp)
    800042a2:	f022                	sd	s0,32(sp)
    800042a4:	ec26                	sd	s1,24(sp)
    800042a6:	e84a                	sd	s2,16(sp)
    800042a8:	1800                	addi	s0,sp,48

  int barr_inst, barr_id, n;
  if(argint(0, &barr_inst) < 0){
    800042aa:	fdc40593          	addi	a1,s0,-36
    800042ae:	4501                	li	a0,0
    800042b0:	00000097          	auipc	ra,0x0
    800042b4:	af6080e7          	jalr	-1290(ra) # 80003da6 <argint>
    return -1;
    800042b8:	57fd                	li	a5,-1
  if(argint(0, &barr_inst) < 0){
    800042ba:	0c054a63          	bltz	a0,8000438e <sys_barrier+0xf0>
  }

  if(argint(1, &barr_id) < 0){
    800042be:	fd840593          	addi	a1,s0,-40
    800042c2:	4505                	li	a0,1
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	ae2080e7          	jalr	-1310(ra) # 80003da6 <argint>
    return -1;
    800042cc:	57fd                	li	a5,-1
  if(argint(1, &barr_id) < 0){
    800042ce:	0c054063          	bltz	a0,8000438e <sys_barrier+0xf0>
  }

  if(argint(2, &n) < 0){
    800042d2:	fd440593          	addi	a1,s0,-44
    800042d6:	4509                	li	a0,2
    800042d8:	00000097          	auipc	ra,0x0
    800042dc:	ace080e7          	jalr	-1330(ra) # 80003da6 <argint>
    800042e0:	0e054c63          	bltz	a0,800043d8 <sys_barrier+0x13a>
    return -1;
  }

  if(barr[barr_id].counter == -1){
    800042e4:	fd842783          	lw	a5,-40(s0)
    800042e8:	06800693          	li	a3,104
    800042ec:	02d786b3          	mul	a3,a5,a3
    800042f0:	00015717          	auipc	a4,0x15
    800042f4:	83870713          	addi	a4,a4,-1992 # 80018b28 <barr>
    800042f8:	9736                	add	a4,a4,a3
    800042fa:	4318                	lw	a4,0(a4)
    800042fc:	56fd                	li	a3,-1
    800042fe:	08d70f63          	beq	a4,a3,8000439c <sys_barrier+0xfe>
    printf("Element with given barrier array id is not allocated\n");
    return -1;
  }

  barr[barr_id].counter++ ;
    80004302:	00015497          	auipc	s1,0x15
    80004306:	82648493          	addi	s1,s1,-2010 # 80018b28 <barr>
    8000430a:	06800913          	li	s2,104
    8000430e:	032787b3          	mul	a5,a5,s2
    80004312:	97a6                	add	a5,a5,s1
    80004314:	2705                	addiw	a4,a4,1
    80004316:	c398                	sw	a4,0(a5)

  printf("%d: Entered barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst, barr_id);
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	6d8080e7          	jalr	1752(ra) # 800019f0 <myproc>
    80004320:	fd842683          	lw	a3,-40(s0)
    80004324:	fdc42603          	lw	a2,-36(s0)
    80004328:	590c                	lw	a1,48(a0)
    8000432a:	00005517          	auipc	a0,0x5
    8000432e:	4c650513          	addi	a0,a0,1222 # 800097f0 <syscalls+0x190>
    80004332:	ffffc097          	auipc	ra,0xffffc
    80004336:	250080e7          	jalr	592(ra) # 80000582 <printf>


  if(barr[barr_id].counter != n){
    8000433a:	fd842783          	lw	a5,-40(s0)
    8000433e:	03278933          	mul	s2,a5,s2
    80004342:	94ca                	add	s1,s1,s2
    80004344:	4094                	lw	a3,0(s1)
    80004346:	fd442703          	lw	a4,-44(s0)
    8000434a:	06e68363          	beq	a3,a4,800043b0 <sys_barrier+0x112>
    cond_wait(&barr[barr_id].cv, &barr[barr_id].lock);
    8000434e:	00014517          	auipc	a0,0x14
    80004352:	7da50513          	addi	a0,a0,2010 # 80018b28 <barr>
    80004356:	00890593          	addi	a1,s2,8
    8000435a:	03890793          	addi	a5,s2,56
    8000435e:	95aa                	add	a1,a1,a0
    80004360:	953e                	add	a0,a0,a5
    80004362:	00004097          	auipc	ra,0x4
    80004366:	9e0080e7          	jalr	-1568(ra) # 80007d42 <cond_wait>
  else{
    barr[barr_id].counter = 0;
    cond_broadcast(&barr[barr_id].cv);
  }

  printf("%d: Finished barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst, barr_id);
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	686080e7          	jalr	1670(ra) # 800019f0 <myproc>
    80004372:	fd842683          	lw	a3,-40(s0)
    80004376:	fdc42603          	lw	a2,-36(s0)
    8000437a:	590c                	lw	a1,48(a0)
    8000437c:	00005517          	auipc	a0,0x5
    80004380:	4a450513          	addi	a0,a0,1188 # 80009820 <syscalls+0x1c0>
    80004384:	ffffc097          	auipc	ra,0xffffc
    80004388:	1fe080e7          	jalr	510(ra) # 80000582 <printf>
  
  return 0;
    8000438c:	4781                	li	a5,0
}
    8000438e:	853e                	mv	a0,a5
    80004390:	70a2                	ld	ra,40(sp)
    80004392:	7402                	ld	s0,32(sp)
    80004394:	64e2                	ld	s1,24(sp)
    80004396:	6942                	ld	s2,16(sp)
    80004398:	6145                	addi	sp,sp,48
    8000439a:	8082                	ret
    printf("Element with given barrier array id is not allocated\n");
    8000439c:	00005517          	auipc	a0,0x5
    800043a0:	41c50513          	addi	a0,a0,1052 # 800097b8 <syscalls+0x158>
    800043a4:	ffffc097          	auipc	ra,0xffffc
    800043a8:	1de080e7          	jalr	478(ra) # 80000582 <printf>
    return -1;
    800043ac:	57fd                	li	a5,-1
    800043ae:	b7c5                	j	8000438e <sys_barrier+0xf0>
    barr[barr_id].counter = 0;
    800043b0:	00014517          	auipc	a0,0x14
    800043b4:	77850513          	addi	a0,a0,1912 # 80018b28 <barr>
    800043b8:	06800713          	li	a4,104
    800043bc:	02e787b3          	mul	a5,a5,a4
    800043c0:	00f50733          	add	a4,a0,a5
    800043c4:	00072023          	sw	zero,0(a4)
    cond_broadcast(&barr[barr_id].cv);
    800043c8:	03878793          	addi	a5,a5,56
    800043cc:	953e                	add	a0,a0,a5
    800043ce:	00004097          	auipc	ra,0x4
    800043d2:	9a4080e7          	jalr	-1628(ra) # 80007d72 <cond_broadcast>
    800043d6:	bf51                	j	8000436a <sys_barrier+0xcc>
    return -1;
    800043d8:	57fd                	li	a5,-1
    800043da:	bf55                	j	8000438e <sys_barrier+0xf0>

00000000800043dc <sys_barrier_alloc>:

uint64 
sys_barrier_alloc(void)
{
    800043dc:	7139                	addi	sp,sp,-64
    800043de:	fc06                	sd	ra,56(sp)
    800043e0:	f822                	sd	s0,48(sp)
    800043e2:	f426                	sd	s1,40(sp)
    800043e4:	f04a                	sd	s2,32(sp)
    800043e6:	ec4e                	sd	s3,24(sp)
    800043e8:	e852                	sd	s4,16(sp)
    800043ea:	e456                	sd	s5,8(sp)
    800043ec:	0080                	addi	s0,sp,64
    for(int i=0; i<10; ++i){
    800043ee:	00014497          	auipc	s1,0x14
    800043f2:	74248493          	addi	s1,s1,1858 # 80018b30 <barr+0x8>
    800043f6:	4901                	li	s2,0
      acquiresleep(&barr[i].lock);
      if(barr[i].counter == -1){
    800043f8:	59fd                	li	s3,-1
    for(int i=0; i<10; ++i){
    800043fa:	4a29                	li	s4,10
      acquiresleep(&barr[i].lock);
    800043fc:	8526                	mv	a0,s1
    800043fe:	00002097          	auipc	ra,0x2
    80004402:	ac2080e7          	jalr	-1342(ra) # 80005ec0 <acquiresleep>
      if(barr[i].counter == -1){
    80004406:	ff84a783          	lw	a5,-8(s1)
    8000440a:	03378663          	beq	a5,s3,80004436 <sys_barrier_alloc+0x5a>
        barr[i].counter = 0;
        releasesleep(&barr[i].lock);
        return i;
      }
      releasesleep(&barr[i].lock);
    8000440e:	8526                	mv	a0,s1
    80004410:	00002097          	auipc	ra,0x2
    80004414:	b06080e7          	jalr	-1274(ra) # 80005f16 <releasesleep>
    for(int i=0; i<10; ++i){
    80004418:	2905                	addiw	s2,s2,1
    8000441a:	06848493          	addi	s1,s1,104
    8000441e:	fd491fe3          	bne	s2,s4,800043fc <sys_barrier_alloc+0x20>
    } 
  return -1;
    80004422:	557d                	li	a0,-1
}
    80004424:	70e2                	ld	ra,56(sp)
    80004426:	7442                	ld	s0,48(sp)
    80004428:	74a2                	ld	s1,40(sp)
    8000442a:	7902                	ld	s2,32(sp)
    8000442c:	69e2                	ld	s3,24(sp)
    8000442e:	6a42                	ld	s4,16(sp)
    80004430:	6aa2                	ld	s5,8(sp)
    80004432:	6121                	addi	sp,sp,64
    80004434:	8082                	ret
        barr[i].counter = 0;
    80004436:	06800713          	li	a4,104
    8000443a:	02e90733          	mul	a4,s2,a4
    8000443e:	00014797          	auipc	a5,0x14
    80004442:	6ea78793          	addi	a5,a5,1770 # 80018b28 <barr>
    80004446:	97ba                	add	a5,a5,a4
    80004448:	0007a023          	sw	zero,0(a5)
        releasesleep(&barr[i].lock);
    8000444c:	8526                	mv	a0,s1
    8000444e:	00002097          	auipc	ra,0x2
    80004452:	ac8080e7          	jalr	-1336(ra) # 80005f16 <releasesleep>
        return i;
    80004456:	854a                	mv	a0,s2
    80004458:	b7f1                	j	80004424 <sys_barrier_alloc+0x48>

000000008000445a <sys_barrier_free>:

uint64 
sys_barrier_free(void)
{
    8000445a:	7179                	addi	sp,sp,-48
    8000445c:	f406                	sd	ra,40(sp)
    8000445e:	f022                	sd	s0,32(sp)
    80004460:	ec26                	sd	s1,24(sp)
    80004462:	e84a                	sd	s2,16(sp)
    80004464:	1800                	addi	s0,sp,48
   int barr_id;
   if(argint(0, &barr_id) < 0){
    80004466:	fdc40593          	addi	a1,s0,-36
    8000446a:	4501                	li	a0,0
    8000446c:	00000097          	auipc	ra,0x0
    80004470:	93a080e7          	jalr	-1734(ra) # 80003da6 <argint>
    return -1;
    80004474:	57fd                	li	a5,-1
   if(argint(0, &barr_id) < 0){
    80004476:	04054a63          	bltz	a0,800044ca <sys_barrier_free+0x70>
   }
   barr[barr_id].counter = -1;
    8000447a:	fdc42503          	lw	a0,-36(s0)
    8000447e:	00014497          	auipc	s1,0x14
    80004482:	6aa48493          	addi	s1,s1,1706 # 80018b28 <barr>
    80004486:	06800913          	li	s2,104
    8000448a:	03250533          	mul	a0,a0,s2
    8000448e:	00a487b3          	add	a5,s1,a0
    80004492:	577d                	li	a4,-1
    80004494:	c398                	sw	a4,0(a5)
   initsleeplock(&barr[barr_id].lock, "barrier_lock");
    80004496:	0521                	addi	a0,a0,8
    80004498:	00005597          	auipc	a1,0x5
    8000449c:	c3858593          	addi	a1,a1,-968 # 800090d0 <digits+0x90>
    800044a0:	9526                	add	a0,a0,s1
    800044a2:	00002097          	auipc	ra,0x2
    800044a6:	9e4080e7          	jalr	-1564(ra) # 80005e86 <initsleeplock>
   initsleeplock(&barr[barr_id].cv.lk, "barrier_cv_lock");
    800044aa:	fdc42503          	lw	a0,-36(s0)
    800044ae:	03250533          	mul	a0,a0,s2
    800044b2:	03850513          	addi	a0,a0,56
    800044b6:	00005597          	auipc	a1,0x5
    800044ba:	c2a58593          	addi	a1,a1,-982 # 800090e0 <digits+0xa0>
    800044be:	9526                	add	a0,a0,s1
    800044c0:	00002097          	auipc	ra,0x2
    800044c4:	9c6080e7          	jalr	-1594(ra) # 80005e86 <initsleeplock>

   return 0;
    800044c8:	4781                	li	a5,0

}
    800044ca:	853e                	mv	a0,a5
    800044cc:	70a2                	ld	ra,40(sp)
    800044ce:	7402                	ld	s0,32(sp)
    800044d0:	64e2                	ld	s1,24(sp)
    800044d2:	6942                	ld	s2,16(sp)
    800044d4:	6145                	addi	sp,sp,48
    800044d6:	8082                	ret

00000000800044d8 <sys_buffer_cond_init>:

uint64
sys_buffer_cond_init(void)
{
    800044d8:	7139                	addi	sp,sp,-64
    800044da:	fc06                	sd	ra,56(sp)
    800044dc:	f822                	sd	s0,48(sp)
    800044de:	f426                	sd	s1,40(sp)
    800044e0:	f04a                	sd	s2,32(sp)
    800044e2:	ec4e                	sd	s3,24(sp)
    800044e4:	e852                	sd	s4,16(sp)
    800044e6:	e456                	sd	s5,8(sp)
    800044e8:	e05a                	sd	s6,0(sp)
    800044ea:	0080                	addi	s0,sp,64
  tail = 0;
    800044ec:	00006797          	auipc	a5,0x6
    800044f0:	b807a823          	sw	zero,-1136(a5) # 8000a07c <tail>
  head = 0;
    800044f4:	00006797          	auipc	a5,0x6
    800044f8:	b807a223          	sw	zero,-1148(a5) # 8000a078 <head>
  initsleeplock(&lock_delete, "delete");
    800044fc:	00005597          	auipc	a1,0x5
    80004500:	35c58593          	addi	a1,a1,860 # 80009858 <syscalls+0x1f8>
    80004504:	00015517          	auipc	a0,0x15
    80004508:	a3450513          	addi	a0,a0,-1484 # 80018f38 <lock_delete>
    8000450c:	00002097          	auipc	ra,0x2
    80004510:	97a080e7          	jalr	-1670(ra) # 80005e86 <initsleeplock>
  initsleeplock(&lock_insert, "insert");
    80004514:	00005597          	auipc	a1,0x5
    80004518:	34c58593          	addi	a1,a1,844 # 80009860 <syscalls+0x200>
    8000451c:	00015517          	auipc	a0,0x15
    80004520:	a4c50513          	addi	a0,a0,-1460 # 80018f68 <lock_insert>
    80004524:	00002097          	auipc	ra,0x2
    80004528:	962080e7          	jalr	-1694(ra) # 80005e86 <initsleeplock>
  initsleeplock(&lock_print, "print");
    8000452c:	00005597          	auipc	a1,0x5
    80004530:	33c58593          	addi	a1,a1,828 # 80009868 <syscalls+0x208>
    80004534:	00015517          	auipc	a0,0x15
    80004538:	a6450513          	addi	a0,a0,-1436 # 80018f98 <lock_print>
    8000453c:	00002097          	auipc	ra,0x2
    80004540:	94a080e7          	jalr	-1718(ra) # 80005e86 <initsleeplock>
  for (int i = 0; i < SIZE; i++) {
    80004544:	00015497          	auipc	s1,0x15
    80004548:	c7c48493          	addi	s1,s1,-900 # 800191c0 <buffer+0x8>
    8000454c:	00016b17          	auipc	s6,0x16
    80004550:	854b0b13          	addi	s6,s6,-1964 # 80019da0 <bcache+0x8>
    buffer[i].x = -1;
    80004554:	5afd                	li	s5,-1
    buffer[i].full = 0;
    initsleeplock(&buffer[i].lock, "buffer_lock");
    80004556:	00005a17          	auipc	s4,0x5
    8000455a:	31aa0a13          	addi	s4,s4,794 # 80009870 <syscalls+0x210>
    initsleeplock(&buffer[i].inserted.lk, "insert");
    8000455e:	00005997          	auipc	s3,0x5
    80004562:	30298993          	addi	s3,s3,770 # 80009860 <syscalls+0x200>
    initsleeplock(&buffer[i].deleted.lk, "delete");
    80004566:	00005917          	auipc	s2,0x5
    8000456a:	2f290913          	addi	s2,s2,754 # 80009858 <syscalls+0x1f8>
    buffer[i].x = -1;
    8000456e:	ff54ac23          	sw	s5,-8(s1)
    buffer[i].full = 0;
    80004572:	fe04ae23          	sw	zero,-4(s1)
    initsleeplock(&buffer[i].lock, "buffer_lock");
    80004576:	85d2                	mv	a1,s4
    80004578:	8526                	mv	a0,s1
    8000457a:	00002097          	auipc	ra,0x2
    8000457e:	90c080e7          	jalr	-1780(ra) # 80005e86 <initsleeplock>
    initsleeplock(&buffer[i].inserted.lk, "insert");
    80004582:	85ce                	mv	a1,s3
    80004584:	03048513          	addi	a0,s1,48
    80004588:	00002097          	auipc	ra,0x2
    8000458c:	8fe080e7          	jalr	-1794(ra) # 80005e86 <initsleeplock>
    initsleeplock(&buffer[i].deleted.lk, "delete");
    80004590:	85ca                	mv	a1,s2
    80004592:	06048513          	addi	a0,s1,96
    80004596:	00002097          	auipc	ra,0x2
    8000459a:	8f0080e7          	jalr	-1808(ra) # 80005e86 <initsleeplock>
  for (int i = 0; i < SIZE; i++) {
    8000459e:	09848493          	addi	s1,s1,152
    800045a2:	fd6496e3          	bne	s1,s6,8000456e <sys_buffer_cond_init+0x96>
  }
  return 0;
}
    800045a6:	4501                	li	a0,0
    800045a8:	70e2                	ld	ra,56(sp)
    800045aa:	7442                	ld	s0,48(sp)
    800045ac:	74a2                	ld	s1,40(sp)
    800045ae:	7902                	ld	s2,32(sp)
    800045b0:	69e2                	ld	s3,24(sp)
    800045b2:	6a42                	ld	s4,16(sp)
    800045b4:	6aa2                	ld	s5,8(sp)
    800045b6:	6b02                	ld	s6,0(sp)
    800045b8:	6121                	addi	sp,sp,64
    800045ba:	8082                	ret

00000000800045bc <sys_cond_produce>:

uint64
sys_cond_produce(void)
{
    800045bc:	715d                	addi	sp,sp,-80
    800045be:	e486                	sd	ra,72(sp)
    800045c0:	e0a2                	sd	s0,64(sp)
    800045c2:	fc26                	sd	s1,56(sp)
    800045c4:	f84a                	sd	s2,48(sp)
    800045c6:	f44e                	sd	s3,40(sp)
    800045c8:	f052                	sd	s4,32(sp)
    800045ca:	ec56                	sd	s5,24(sp)
    800045cc:	0880                	addi	s0,sp,80
  int val;
  if(argint(0, &val) < 0) return -1;
    800045ce:	fbc40593          	addi	a1,s0,-68
    800045d2:	4501                	li	a0,0
    800045d4:	fffff097          	auipc	ra,0xfffff
    800045d8:	7d2080e7          	jalr	2002(ra) # 80003da6 <argint>
    800045dc:	57fd                	li	a5,-1
    800045de:	0c054063          	bltz	a0,8000469e <sys_cond_produce+0xe2>
  int index;
  acquiresleep(&lock_insert);
    800045e2:	00015497          	auipc	s1,0x15
    800045e6:	98648493          	addi	s1,s1,-1658 # 80018f68 <lock_insert>
    800045ea:	8526                	mv	a0,s1
    800045ec:	00002097          	auipc	ra,0x2
    800045f0:	8d4080e7          	jalr	-1836(ra) # 80005ec0 <acquiresleep>
  index = tail;
    800045f4:	00006717          	auipc	a4,0x6
    800045f8:	a8870713          	addi	a4,a4,-1400 # 8000a07c <tail>
    800045fc:	00072a03          	lw	s4,0(a4)
  tail = (tail + 1) % SIZE;
    80004600:	001a079b          	addiw	a5,s4,1
    80004604:	46d1                	li	a3,20
    80004606:	02d7e7bb          	remw	a5,a5,a3
    8000460a:	c31c                	sw	a5,0(a4)
  releasesleep(&lock_insert);
    8000460c:	8526                	mv	a0,s1
    8000460e:	00002097          	auipc	ra,0x2
    80004612:	908080e7          	jalr	-1784(ra) # 80005f16 <releasesleep>
  acquiresleep(&buffer[index].lock);
    80004616:	09800a93          	li	s5,152
    8000461a:	035a0ab3          	mul	s5,s4,s5
    8000461e:	008a8493          	addi	s1,s5,8
    80004622:	00015917          	auipc	s2,0x15
    80004626:	b9690913          	addi	s2,s2,-1130 # 800191b8 <buffer>
    8000462a:	94ca                	add	s1,s1,s2
    8000462c:	8526                	mv	a0,s1
    8000462e:	00002097          	auipc	ra,0x2
    80004632:	892080e7          	jalr	-1902(ra) # 80005ec0 <acquiresleep>
  while(buffer[index].full)
    80004636:	9956                	add	s2,s2,s5
    80004638:	00492783          	lw	a5,4(s2)
    8000463c:	c785                	beqz	a5,80004664 <sys_cond_produce+0xa8>
    cond_wait(&buffer[index].deleted, &buffer[index].lock);
    8000463e:	00015997          	auipc	s3,0x15
    80004642:	be298993          	addi	s3,s3,-1054 # 80019220 <buffer+0x68>
    80004646:	99d6                	add	s3,s3,s5
  while(buffer[index].full)
    80004648:	00015917          	auipc	s2,0x15
    8000464c:	b7090913          	addi	s2,s2,-1168 # 800191b8 <buffer>
    80004650:	9956                	add	s2,s2,s5
    cond_wait(&buffer[index].deleted, &buffer[index].lock);
    80004652:	85a6                	mv	a1,s1
    80004654:	854e                	mv	a0,s3
    80004656:	00003097          	auipc	ra,0x3
    8000465a:	6ec080e7          	jalr	1772(ra) # 80007d42 <cond_wait>
  while(buffer[index].full)
    8000465e:	00492783          	lw	a5,4(s2)
    80004662:	fbe5                	bnez	a5,80004652 <sys_cond_produce+0x96>
  buffer[index].x = val;
    80004664:	00015517          	auipc	a0,0x15
    80004668:	b5450513          	addi	a0,a0,-1196 # 800191b8 <buffer>
    8000466c:	09800793          	li	a5,152
    80004670:	02fa0a33          	mul	s4,s4,a5
    80004674:	9a2a                	add	s4,s4,a0
    80004676:	fbc42783          	lw	a5,-68(s0)
    8000467a:	00fa2023          	sw	a5,0(s4)
  buffer[index].full = 1;
    8000467e:	4785                	li	a5,1
    80004680:	00fa2223          	sw	a5,4(s4)
  cond_signal(&buffer[index].inserted);
    80004684:	038a8a93          	addi	s5,s5,56
    80004688:	9556                	add	a0,a0,s5
    8000468a:	00003097          	auipc	ra,0x3
    8000468e:	6d0080e7          	jalr	1744(ra) # 80007d5a <cond_signal>
  releasesleep(&buffer[index].lock);
    80004692:	8526                	mv	a0,s1
    80004694:	00002097          	auipc	ra,0x2
    80004698:	882080e7          	jalr	-1918(ra) # 80005f16 <releasesleep>
  return 0;
    8000469c:	4781                	li	a5,0
}
    8000469e:	853e                	mv	a0,a5
    800046a0:	60a6                	ld	ra,72(sp)
    800046a2:	6406                	ld	s0,64(sp)
    800046a4:	74e2                	ld	s1,56(sp)
    800046a6:	7942                	ld	s2,48(sp)
    800046a8:	79a2                	ld	s3,40(sp)
    800046aa:	7a02                	ld	s4,32(sp)
    800046ac:	6ae2                	ld	s5,24(sp)
    800046ae:	6161                	addi	sp,sp,80
    800046b0:	8082                	ret

00000000800046b2 <sys_cond_consume>:

uint64
sys_cond_consume(void)
{
    800046b2:	7139                	addi	sp,sp,-64
    800046b4:	fc06                	sd	ra,56(sp)
    800046b6:	f822                	sd	s0,48(sp)
    800046b8:	f426                	sd	s1,40(sp)
    800046ba:	f04a                	sd	s2,32(sp)
    800046bc:	ec4e                	sd	s3,24(sp)
    800046be:	e852                	sd	s4,16(sp)
    800046c0:	e456                	sd	s5,8(sp)
    800046c2:	0080                	addi	s0,sp,64
  int index, v;
  acquiresleep(&lock_delete);
    800046c4:	00015497          	auipc	s1,0x15
    800046c8:	87448493          	addi	s1,s1,-1932 # 80018f38 <lock_delete>
    800046cc:	8526                	mv	a0,s1
    800046ce:	00001097          	auipc	ra,0x1
    800046d2:	7f2080e7          	jalr	2034(ra) # 80005ec0 <acquiresleep>
  index = head;
    800046d6:	00006717          	auipc	a4,0x6
    800046da:	9a270713          	addi	a4,a4,-1630 # 8000a078 <head>
    800046de:	00072a03          	lw	s4,0(a4)
  head = (head + 1) % SIZE;
    800046e2:	001a079b          	addiw	a5,s4,1
    800046e6:	46d1                	li	a3,20
    800046e8:	02d7e7bb          	remw	a5,a5,a3
    800046ec:	c31c                	sw	a5,0(a4)
  releasesleep(&lock_delete);
    800046ee:	8526                	mv	a0,s1
    800046f0:	00002097          	auipc	ra,0x2
    800046f4:	826080e7          	jalr	-2010(ra) # 80005f16 <releasesleep>
  acquiresleep(&buffer[index].lock);
    800046f8:	09800a93          	li	s5,152
    800046fc:	035a0ab3          	mul	s5,s4,s5
    80004700:	008a8493          	addi	s1,s5,8
    80004704:	00015917          	auipc	s2,0x15
    80004708:	ab490913          	addi	s2,s2,-1356 # 800191b8 <buffer>
    8000470c:	94ca                	add	s1,s1,s2
    8000470e:	8526                	mv	a0,s1
    80004710:	00001097          	auipc	ra,0x1
    80004714:	7b0080e7          	jalr	1968(ra) # 80005ec0 <acquiresleep>
  while (!buffer[index].full)
    80004718:	9956                	add	s2,s2,s5
    8000471a:	00492783          	lw	a5,4(s2)
    8000471e:	e785                	bnez	a5,80004746 <sys_cond_consume+0x94>
    cond_wait(&buffer[index].inserted, &buffer[index].lock);
    80004720:	00015997          	auipc	s3,0x15
    80004724:	ad098993          	addi	s3,s3,-1328 # 800191f0 <buffer+0x38>
    80004728:	99d6                	add	s3,s3,s5
  while (!buffer[index].full)
    8000472a:	00015917          	auipc	s2,0x15
    8000472e:	a8e90913          	addi	s2,s2,-1394 # 800191b8 <buffer>
    80004732:	9956                	add	s2,s2,s5
    cond_wait(&buffer[index].inserted, &buffer[index].lock);
    80004734:	85a6                	mv	a1,s1
    80004736:	854e                	mv	a0,s3
    80004738:	00003097          	auipc	ra,0x3
    8000473c:	60a080e7          	jalr	1546(ra) # 80007d42 <cond_wait>
  while (!buffer[index].full)
    80004740:	00492783          	lw	a5,4(s2)
    80004744:	dbe5                	beqz	a5,80004734 <sys_cond_consume+0x82>
  v = buffer[index].x;
    80004746:	00015517          	auipc	a0,0x15
    8000474a:	a7250513          	addi	a0,a0,-1422 # 800191b8 <buffer>
    8000474e:	09800793          	li	a5,152
    80004752:	02fa0a33          	mul	s4,s4,a5
    80004756:	9a2a                	add	s4,s4,a0
    80004758:	000a2903          	lw	s2,0(s4)
  buffer[index].full = 0;
    8000475c:	000a2223          	sw	zero,4(s4)
  cond_signal(&buffer[index].deleted);
    80004760:	068a8a93          	addi	s5,s5,104
    80004764:	9556                	add	a0,a0,s5
    80004766:	00003097          	auipc	ra,0x3
    8000476a:	5f4080e7          	jalr	1524(ra) # 80007d5a <cond_signal>
  releasesleep(&buffer[index].lock);
    8000476e:	8526                	mv	a0,s1
    80004770:	00001097          	auipc	ra,0x1
    80004774:	7a6080e7          	jalr	1958(ra) # 80005f16 <releasesleep>
  acquiresleep(&lock_print);
    80004778:	00015497          	auipc	s1,0x15
    8000477c:	82048493          	addi	s1,s1,-2016 # 80018f98 <lock_print>
    80004780:	8526                	mv	a0,s1
    80004782:	00001097          	auipc	ra,0x1
    80004786:	73e080e7          	jalr	1854(ra) # 80005ec0 <acquiresleep>
  printf("%d ", v);
    8000478a:	85ca                	mv	a1,s2
    8000478c:	00005517          	auipc	a0,0x5
    80004790:	0f450513          	addi	a0,a0,244 # 80009880 <syscalls+0x220>
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	dee080e7          	jalr	-530(ra) # 80000582 <printf>
  releasesleep(&lock_print);
    8000479c:	8526                	mv	a0,s1
    8000479e:	00001097          	auipc	ra,0x1
    800047a2:	778080e7          	jalr	1912(ra) # 80005f16 <releasesleep>
  return v;
}
    800047a6:	854a                	mv	a0,s2
    800047a8:	70e2                	ld	ra,56(sp)
    800047aa:	7442                	ld	s0,48(sp)
    800047ac:	74a2                	ld	s1,40(sp)
    800047ae:	7902                	ld	s2,32(sp)
    800047b0:	69e2                	ld	s3,24(sp)
    800047b2:	6a42                	ld	s4,16(sp)
    800047b4:	6aa2                	ld	s5,8(sp)
    800047b6:	6121                	addi	sp,sp,64
    800047b8:	8082                	ret

00000000800047ba <sys_buffer_sem_init>:

uint64
sys_buffer_sem_init(void)
{
    800047ba:	1141                	addi	sp,sp,-16
    800047bc:	e406                	sd	ra,8(sp)
    800047be:	e022                	sd	s0,0(sp)
    800047c0:	0800                	addi	s0,sp,16
  nextp = 0;
    800047c2:	00006797          	auipc	a5,0x6
    800047c6:	8a07a923          	sw	zero,-1870(a5) # 8000a074 <nextp>
  nextc = 0;
    800047ca:	00006797          	auipc	a5,0x6
    800047ce:	8a07a323          	sw	zero,-1882(a5) # 8000a070 <nextc>
  sem_init(&pro, 1);
    800047d2:	4585                	li	a1,1
    800047d4:	00014517          	auipc	a0,0x14
    800047d8:	7f450513          	addi	a0,a0,2036 # 80018fc8 <pro>
    800047dc:	00003097          	auipc	ra,0x3
    800047e0:	5ae080e7          	jalr	1454(ra) # 80007d8a <sem_init>
  sem_init(&con, 1);
    800047e4:	4585                	li	a1,1
    800047e6:	00015517          	auipc	a0,0x15
    800047ea:	84a50513          	addi	a0,a0,-1974 # 80019030 <con>
    800047ee:	00003097          	auipc	ra,0x3
    800047f2:	59c080e7          	jalr	1436(ra) # 80007d8a <sem_init>
  sem_init(&empty, N);
    800047f6:	45d1                	li	a1,20
    800047f8:	00015517          	auipc	a0,0x15
    800047fc:	8a050513          	addi	a0,a0,-1888 # 80019098 <empty>
    80004800:	00003097          	auipc	ra,0x3
    80004804:	58a080e7          	jalr	1418(ra) # 80007d8a <sem_init>
  sem_init(&full, 0);
    80004808:	4581                	li	a1,0
    8000480a:	00015517          	auipc	a0,0x15
    8000480e:	8f650513          	addi	a0,a0,-1802 # 80019100 <full>
    80004812:	00003097          	auipc	ra,0x3
    80004816:	578080e7          	jalr	1400(ra) # 80007d8a <sem_init>
  return 0;
}
    8000481a:	4501                	li	a0,0
    8000481c:	60a2                	ld	ra,8(sp)
    8000481e:	6402                	ld	s0,0(sp)
    80004820:	0141                	addi	sp,sp,16
    80004822:	8082                	ret

0000000080004824 <sys_sem_produce>:

uint64
sys_sem_produce(void)
{
    80004824:	7179                	addi	sp,sp,-48
    80004826:	f406                	sd	ra,40(sp)
    80004828:	f022                	sd	s0,32(sp)
    8000482a:	ec26                	sd	s1,24(sp)
    8000482c:	1800                	addi	s0,sp,48
  int val;
  if(argint(0, &val) < 0) return -1;
    8000482e:	fdc40593          	addi	a1,s0,-36
    80004832:	4501                	li	a0,0
    80004834:	fffff097          	auipc	ra,0xfffff
    80004838:	572080e7          	jalr	1394(ra) # 80003da6 <argint>
    8000483c:	57fd                	li	a5,-1
    8000483e:	06054663          	bltz	a0,800048aa <sys_sem_produce+0x86>
  sem_wait(&empty);
    80004842:	00015517          	auipc	a0,0x15
    80004846:	85650513          	addi	a0,a0,-1962 # 80019098 <empty>
    8000484a:	00003097          	auipc	ra,0x3
    8000484e:	580080e7          	jalr	1408(ra) # 80007dca <sem_wait>
  sem_wait(&pro);
    80004852:	00014497          	auipc	s1,0x14
    80004856:	77648493          	addi	s1,s1,1910 # 80018fc8 <pro>
    8000485a:	8526                	mv	a0,s1
    8000485c:	00003097          	auipc	ra,0x3
    80004860:	56e080e7          	jalr	1390(ra) # 80007dca <sem_wait>
  sem_buffer[nextp] = val;
    80004864:	00006697          	auipc	a3,0x6
    80004868:	81068693          	addi	a3,a3,-2032 # 8000a074 <nextp>
    8000486c:	429c                	lw	a5,0(a3)
    8000486e:	00279613          	slli	a2,a5,0x2
    80004872:	00014717          	auipc	a4,0x14
    80004876:	2b670713          	addi	a4,a4,694 # 80018b28 <barr>
    8000487a:	9732                	add	a4,a4,a2
    8000487c:	fdc42603          	lw	a2,-36(s0)
    80004880:	64c72023          	sw	a2,1600(a4)
  nextp = (nextp + 1)%N;
    80004884:	2785                	addiw	a5,a5,1
    80004886:	4751                	li	a4,20
    80004888:	02e7e7bb          	remw	a5,a5,a4
    8000488c:	c29c                	sw	a5,0(a3)
  sem_post (&pro);
    8000488e:	8526                	mv	a0,s1
    80004890:	00003097          	auipc	ra,0x3
    80004894:	58c080e7          	jalr	1420(ra) # 80007e1c <sem_post>
  sem_post (&full);
    80004898:	00015517          	auipc	a0,0x15
    8000489c:	86850513          	addi	a0,a0,-1944 # 80019100 <full>
    800048a0:	00003097          	auipc	ra,0x3
    800048a4:	57c080e7          	jalr	1404(ra) # 80007e1c <sem_post>
  return 0;
    800048a8:	4781                	li	a5,0
}
    800048aa:	853e                	mv	a0,a5
    800048ac:	70a2                	ld	ra,40(sp)
    800048ae:	7402                	ld	s0,32(sp)
    800048b0:	64e2                	ld	s1,24(sp)
    800048b2:	6145                	addi	sp,sp,48
    800048b4:	8082                	ret

00000000800048b6 <sys_sem_consume>:

uint64
sys_sem_consume(void)
{
    800048b6:	1101                	addi	sp,sp,-32
    800048b8:	ec06                	sd	ra,24(sp)
    800048ba:	e822                	sd	s0,16(sp)
    800048bc:	e426                	sd	s1,8(sp)
    800048be:	e04a                	sd	s2,0(sp)
    800048c0:	1000                	addi	s0,sp,32
  int v;
  sem_wait (&full);
    800048c2:	00015517          	auipc	a0,0x15
    800048c6:	83e50513          	addi	a0,a0,-1986 # 80019100 <full>
    800048ca:	00003097          	auipc	ra,0x3
    800048ce:	500080e7          	jalr	1280(ra) # 80007dca <sem_wait>
  sem_wait (&con);
    800048d2:	00014917          	auipc	s2,0x14
    800048d6:	75e90913          	addi	s2,s2,1886 # 80019030 <con>
    800048da:	854a                	mv	a0,s2
    800048dc:	00003097          	auipc	ra,0x3
    800048e0:	4ee080e7          	jalr	1262(ra) # 80007dca <sem_wait>
  v = sem_buffer[nextc];
    800048e4:	00005697          	auipc	a3,0x5
    800048e8:	78c68693          	addi	a3,a3,1932 # 8000a070 <nextc>
    800048ec:	429c                	lw	a5,0(a3)
    800048ee:	00279613          	slli	a2,a5,0x2
    800048f2:	00014717          	auipc	a4,0x14
    800048f6:	23670713          	addi	a4,a4,566 # 80018b28 <barr>
    800048fa:	9732                	add	a4,a4,a2
    800048fc:	64072483          	lw	s1,1600(a4)
  nextc = (nextc+1)%N;
    80004900:	2785                	addiw	a5,a5,1
    80004902:	4751                	li	a4,20
    80004904:	02e7e7bb          	remw	a5,a5,a4
    80004908:	c29c                	sw	a5,0(a3)
  sem_post (&con);
    8000490a:	854a                	mv	a0,s2
    8000490c:	00003097          	auipc	ra,0x3
    80004910:	510080e7          	jalr	1296(ra) # 80007e1c <sem_post>
  sem_post (&empty);
    80004914:	00014517          	auipc	a0,0x14
    80004918:	78450513          	addi	a0,a0,1924 # 80019098 <empty>
    8000491c:	00003097          	auipc	ra,0x3
    80004920:	500080e7          	jalr	1280(ra) # 80007e1c <sem_post>
  acquiresleep(&lock_print);
    80004924:	00014917          	auipc	s2,0x14
    80004928:	67490913          	addi	s2,s2,1652 # 80018f98 <lock_print>
    8000492c:	854a                	mv	a0,s2
    8000492e:	00001097          	auipc	ra,0x1
    80004932:	592080e7          	jalr	1426(ra) # 80005ec0 <acquiresleep>
  printf("%d ", v);
    80004936:	85a6                	mv	a1,s1
    80004938:	00005517          	auipc	a0,0x5
    8000493c:	f4850513          	addi	a0,a0,-184 # 80009880 <syscalls+0x220>
    80004940:	ffffc097          	auipc	ra,0xffffc
    80004944:	c42080e7          	jalr	-958(ra) # 80000582 <printf>
  releasesleep(&lock_print);
    80004948:	854a                	mv	a0,s2
    8000494a:	00001097          	auipc	ra,0x1
    8000494e:	5cc080e7          	jalr	1484(ra) # 80005f16 <releasesleep>
  return v;
    80004952:	8526                	mv	a0,s1
    80004954:	60e2                	ld	ra,24(sp)
    80004956:	6442                	ld	s0,16(sp)
    80004958:	64a2                	ld	s1,8(sp)
    8000495a:	6902                	ld	s2,0(sp)
    8000495c:	6105                	addi	sp,sp,32
    8000495e:	8082                	ret

0000000080004960 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80004960:	7179                	addi	sp,sp,-48
    80004962:	f406                	sd	ra,40(sp)
    80004964:	f022                	sd	s0,32(sp)
    80004966:	ec26                	sd	s1,24(sp)
    80004968:	e84a                	sd	s2,16(sp)
    8000496a:	e44e                	sd	s3,8(sp)
    8000496c:	e052                	sd	s4,0(sp)
    8000496e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80004970:	00005597          	auipc	a1,0x5
    80004974:	f1858593          	addi	a1,a1,-232 # 80009888 <syscalls+0x228>
    80004978:	00015517          	auipc	a0,0x15
    8000497c:	42050513          	addi	a0,a0,1056 # 80019d98 <bcache>
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	1be080e7          	jalr	446(ra) # 80000b3e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80004988:	0001d797          	auipc	a5,0x1d
    8000498c:	41078793          	addi	a5,a5,1040 # 80021d98 <bcache+0x8000>
    80004990:	0001d717          	auipc	a4,0x1d
    80004994:	67070713          	addi	a4,a4,1648 # 80022000 <bcache+0x8268>
    80004998:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000499c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800049a0:	00015497          	auipc	s1,0x15
    800049a4:	41048493          	addi	s1,s1,1040 # 80019db0 <bcache+0x18>
    b->next = bcache.head.next;
    800049a8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800049aa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800049ac:	00005a17          	auipc	s4,0x5
    800049b0:	ee4a0a13          	addi	s4,s4,-284 # 80009890 <syscalls+0x230>
    b->next = bcache.head.next;
    800049b4:	2b893783          	ld	a5,696(s2)
    800049b8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800049ba:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800049be:	85d2                	mv	a1,s4
    800049c0:	01048513          	addi	a0,s1,16
    800049c4:	00001097          	auipc	ra,0x1
    800049c8:	4c2080e7          	jalr	1218(ra) # 80005e86 <initsleeplock>
    bcache.head.next->prev = b;
    800049cc:	2b893783          	ld	a5,696(s2)
    800049d0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800049d2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800049d6:	45848493          	addi	s1,s1,1112
    800049da:	fd349de3          	bne	s1,s3,800049b4 <binit+0x54>
  }
}
    800049de:	70a2                	ld	ra,40(sp)
    800049e0:	7402                	ld	s0,32(sp)
    800049e2:	64e2                	ld	s1,24(sp)
    800049e4:	6942                	ld	s2,16(sp)
    800049e6:	69a2                	ld	s3,8(sp)
    800049e8:	6a02                	ld	s4,0(sp)
    800049ea:	6145                	addi	sp,sp,48
    800049ec:	8082                	ret

00000000800049ee <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800049ee:	7179                	addi	sp,sp,-48
    800049f0:	f406                	sd	ra,40(sp)
    800049f2:	f022                	sd	s0,32(sp)
    800049f4:	ec26                	sd	s1,24(sp)
    800049f6:	e84a                	sd	s2,16(sp)
    800049f8:	e44e                	sd	s3,8(sp)
    800049fa:	1800                	addi	s0,sp,48
    800049fc:	892a                	mv	s2,a0
    800049fe:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80004a00:	00015517          	auipc	a0,0x15
    80004a04:	39850513          	addi	a0,a0,920 # 80019d98 <bcache>
    80004a08:	ffffc097          	auipc	ra,0xffffc
    80004a0c:	1c6080e7          	jalr	454(ra) # 80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004a10:	0001d497          	auipc	s1,0x1d
    80004a14:	6404b483          	ld	s1,1600(s1) # 80022050 <bcache+0x82b8>
    80004a18:	0001d797          	auipc	a5,0x1d
    80004a1c:	5e878793          	addi	a5,a5,1512 # 80022000 <bcache+0x8268>
    80004a20:	02f48f63          	beq	s1,a5,80004a5e <bread+0x70>
    80004a24:	873e                	mv	a4,a5
    80004a26:	a021                	j	80004a2e <bread+0x40>
    80004a28:	68a4                	ld	s1,80(s1)
    80004a2a:	02e48a63          	beq	s1,a4,80004a5e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80004a2e:	449c                	lw	a5,8(s1)
    80004a30:	ff279ce3          	bne	a5,s2,80004a28 <bread+0x3a>
    80004a34:	44dc                	lw	a5,12(s1)
    80004a36:	ff3799e3          	bne	a5,s3,80004a28 <bread+0x3a>
      b->refcnt++;
    80004a3a:	40bc                	lw	a5,64(s1)
    80004a3c:	2785                	addiw	a5,a5,1
    80004a3e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004a40:	00015517          	auipc	a0,0x15
    80004a44:	35850513          	addi	a0,a0,856 # 80019d98 <bcache>
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	23a080e7          	jalr	570(ra) # 80000c82 <release>
      acquiresleep(&b->lock);
    80004a50:	01048513          	addi	a0,s1,16
    80004a54:	00001097          	auipc	ra,0x1
    80004a58:	46c080e7          	jalr	1132(ra) # 80005ec0 <acquiresleep>
      return b;
    80004a5c:	a8b9                	j	80004aba <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004a5e:	0001d497          	auipc	s1,0x1d
    80004a62:	5ea4b483          	ld	s1,1514(s1) # 80022048 <bcache+0x82b0>
    80004a66:	0001d797          	auipc	a5,0x1d
    80004a6a:	59a78793          	addi	a5,a5,1434 # 80022000 <bcache+0x8268>
    80004a6e:	00f48863          	beq	s1,a5,80004a7e <bread+0x90>
    80004a72:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80004a74:	40bc                	lw	a5,64(s1)
    80004a76:	cf81                	beqz	a5,80004a8e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004a78:	64a4                	ld	s1,72(s1)
    80004a7a:	fee49de3          	bne	s1,a4,80004a74 <bread+0x86>
  panic("bget: no buffers");
    80004a7e:	00005517          	auipc	a0,0x5
    80004a82:	e1a50513          	addi	a0,a0,-486 # 80009898 <syscalls+0x238>
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	ab2080e7          	jalr	-1358(ra) # 80000538 <panic>
      b->dev = dev;
    80004a8e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80004a92:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80004a96:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80004a9a:	4785                	li	a5,1
    80004a9c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004a9e:	00015517          	auipc	a0,0x15
    80004aa2:	2fa50513          	addi	a0,a0,762 # 80019d98 <bcache>
    80004aa6:	ffffc097          	auipc	ra,0xffffc
    80004aaa:	1dc080e7          	jalr	476(ra) # 80000c82 <release>
      acquiresleep(&b->lock);
    80004aae:	01048513          	addi	a0,s1,16
    80004ab2:	00001097          	auipc	ra,0x1
    80004ab6:	40e080e7          	jalr	1038(ra) # 80005ec0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80004aba:	409c                	lw	a5,0(s1)
    80004abc:	cb89                	beqz	a5,80004ace <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004abe:	8526                	mv	a0,s1
    80004ac0:	70a2                	ld	ra,40(sp)
    80004ac2:	7402                	ld	s0,32(sp)
    80004ac4:	64e2                	ld	s1,24(sp)
    80004ac6:	6942                	ld	s2,16(sp)
    80004ac8:	69a2                	ld	s3,8(sp)
    80004aca:	6145                	addi	sp,sp,48
    80004acc:	8082                	ret
    virtio_disk_rw(b, 0);
    80004ace:	4581                	li	a1,0
    80004ad0:	8526                	mv	a0,s1
    80004ad2:	00003097          	auipc	ra,0x3
    80004ad6:	f20080e7          	jalr	-224(ra) # 800079f2 <virtio_disk_rw>
    b->valid = 1;
    80004ada:	4785                	li	a5,1
    80004adc:	c09c                	sw	a5,0(s1)
  return b;
    80004ade:	b7c5                	j	80004abe <bread+0xd0>

0000000080004ae0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004ae0:	1101                	addi	sp,sp,-32
    80004ae2:	ec06                	sd	ra,24(sp)
    80004ae4:	e822                	sd	s0,16(sp)
    80004ae6:	e426                	sd	s1,8(sp)
    80004ae8:	1000                	addi	s0,sp,32
    80004aea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004aec:	0541                	addi	a0,a0,16
    80004aee:	00001097          	auipc	ra,0x1
    80004af2:	46c080e7          	jalr	1132(ra) # 80005f5a <holdingsleep>
    80004af6:	cd01                	beqz	a0,80004b0e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80004af8:	4585                	li	a1,1
    80004afa:	8526                	mv	a0,s1
    80004afc:	00003097          	auipc	ra,0x3
    80004b00:	ef6080e7          	jalr	-266(ra) # 800079f2 <virtio_disk_rw>
}
    80004b04:	60e2                	ld	ra,24(sp)
    80004b06:	6442                	ld	s0,16(sp)
    80004b08:	64a2                	ld	s1,8(sp)
    80004b0a:	6105                	addi	sp,sp,32
    80004b0c:	8082                	ret
    panic("bwrite");
    80004b0e:	00005517          	auipc	a0,0x5
    80004b12:	da250513          	addi	a0,a0,-606 # 800098b0 <syscalls+0x250>
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	a22080e7          	jalr	-1502(ra) # 80000538 <panic>

0000000080004b1e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004b1e:	1101                	addi	sp,sp,-32
    80004b20:	ec06                	sd	ra,24(sp)
    80004b22:	e822                	sd	s0,16(sp)
    80004b24:	e426                	sd	s1,8(sp)
    80004b26:	e04a                	sd	s2,0(sp)
    80004b28:	1000                	addi	s0,sp,32
    80004b2a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004b2c:	01050913          	addi	s2,a0,16
    80004b30:	854a                	mv	a0,s2
    80004b32:	00001097          	auipc	ra,0x1
    80004b36:	428080e7          	jalr	1064(ra) # 80005f5a <holdingsleep>
    80004b3a:	c92d                	beqz	a0,80004bac <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80004b3c:	854a                	mv	a0,s2
    80004b3e:	00001097          	auipc	ra,0x1
    80004b42:	3d8080e7          	jalr	984(ra) # 80005f16 <releasesleep>

  acquire(&bcache.lock);
    80004b46:	00015517          	auipc	a0,0x15
    80004b4a:	25250513          	addi	a0,a0,594 # 80019d98 <bcache>
    80004b4e:	ffffc097          	auipc	ra,0xffffc
    80004b52:	080080e7          	jalr	128(ra) # 80000bce <acquire>
  b->refcnt--;
    80004b56:	40bc                	lw	a5,64(s1)
    80004b58:	37fd                	addiw	a5,a5,-1
    80004b5a:	0007871b          	sext.w	a4,a5
    80004b5e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80004b60:	eb05                	bnez	a4,80004b90 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004b62:	68bc                	ld	a5,80(s1)
    80004b64:	64b8                	ld	a4,72(s1)
    80004b66:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80004b68:	64bc                	ld	a5,72(s1)
    80004b6a:	68b8                	ld	a4,80(s1)
    80004b6c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80004b6e:	0001d797          	auipc	a5,0x1d
    80004b72:	22a78793          	addi	a5,a5,554 # 80021d98 <bcache+0x8000>
    80004b76:	2b87b703          	ld	a4,696(a5)
    80004b7a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80004b7c:	0001d717          	auipc	a4,0x1d
    80004b80:	48470713          	addi	a4,a4,1156 # 80022000 <bcache+0x8268>
    80004b84:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80004b86:	2b87b703          	ld	a4,696(a5)
    80004b8a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004b8c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004b90:	00015517          	auipc	a0,0x15
    80004b94:	20850513          	addi	a0,a0,520 # 80019d98 <bcache>
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	0ea080e7          	jalr	234(ra) # 80000c82 <release>
}
    80004ba0:	60e2                	ld	ra,24(sp)
    80004ba2:	6442                	ld	s0,16(sp)
    80004ba4:	64a2                	ld	s1,8(sp)
    80004ba6:	6902                	ld	s2,0(sp)
    80004ba8:	6105                	addi	sp,sp,32
    80004baa:	8082                	ret
    panic("brelse");
    80004bac:	00005517          	auipc	a0,0x5
    80004bb0:	d0c50513          	addi	a0,a0,-756 # 800098b8 <syscalls+0x258>
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	984080e7          	jalr	-1660(ra) # 80000538 <panic>

0000000080004bbc <bpin>:

void
bpin(struct buf *b) {
    80004bbc:	1101                	addi	sp,sp,-32
    80004bbe:	ec06                	sd	ra,24(sp)
    80004bc0:	e822                	sd	s0,16(sp)
    80004bc2:	e426                	sd	s1,8(sp)
    80004bc4:	1000                	addi	s0,sp,32
    80004bc6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004bc8:	00015517          	auipc	a0,0x15
    80004bcc:	1d050513          	addi	a0,a0,464 # 80019d98 <bcache>
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	ffe080e7          	jalr	-2(ra) # 80000bce <acquire>
  b->refcnt++;
    80004bd8:	40bc                	lw	a5,64(s1)
    80004bda:	2785                	addiw	a5,a5,1
    80004bdc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004bde:	00015517          	auipc	a0,0x15
    80004be2:	1ba50513          	addi	a0,a0,442 # 80019d98 <bcache>
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	09c080e7          	jalr	156(ra) # 80000c82 <release>
}
    80004bee:	60e2                	ld	ra,24(sp)
    80004bf0:	6442                	ld	s0,16(sp)
    80004bf2:	64a2                	ld	s1,8(sp)
    80004bf4:	6105                	addi	sp,sp,32
    80004bf6:	8082                	ret

0000000080004bf8 <bunpin>:

void
bunpin(struct buf *b) {
    80004bf8:	1101                	addi	sp,sp,-32
    80004bfa:	ec06                	sd	ra,24(sp)
    80004bfc:	e822                	sd	s0,16(sp)
    80004bfe:	e426                	sd	s1,8(sp)
    80004c00:	1000                	addi	s0,sp,32
    80004c02:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004c04:	00015517          	auipc	a0,0x15
    80004c08:	19450513          	addi	a0,a0,404 # 80019d98 <bcache>
    80004c0c:	ffffc097          	auipc	ra,0xffffc
    80004c10:	fc2080e7          	jalr	-62(ra) # 80000bce <acquire>
  b->refcnt--;
    80004c14:	40bc                	lw	a5,64(s1)
    80004c16:	37fd                	addiw	a5,a5,-1
    80004c18:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004c1a:	00015517          	auipc	a0,0x15
    80004c1e:	17e50513          	addi	a0,a0,382 # 80019d98 <bcache>
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	060080e7          	jalr	96(ra) # 80000c82 <release>
}
    80004c2a:	60e2                	ld	ra,24(sp)
    80004c2c:	6442                	ld	s0,16(sp)
    80004c2e:	64a2                	ld	s1,8(sp)
    80004c30:	6105                	addi	sp,sp,32
    80004c32:	8082                	ret

0000000080004c34 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004c34:	1101                	addi	sp,sp,-32
    80004c36:	ec06                	sd	ra,24(sp)
    80004c38:	e822                	sd	s0,16(sp)
    80004c3a:	e426                	sd	s1,8(sp)
    80004c3c:	e04a                	sd	s2,0(sp)
    80004c3e:	1000                	addi	s0,sp,32
    80004c40:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004c42:	00d5d59b          	srliw	a1,a1,0xd
    80004c46:	0001e797          	auipc	a5,0x1e
    80004c4a:	82e7a783          	lw	a5,-2002(a5) # 80022474 <sb+0x1c>
    80004c4e:	9dbd                	addw	a1,a1,a5
    80004c50:	00000097          	auipc	ra,0x0
    80004c54:	d9e080e7          	jalr	-610(ra) # 800049ee <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80004c58:	0074f713          	andi	a4,s1,7
    80004c5c:	4785                	li	a5,1
    80004c5e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004c62:	14ce                	slli	s1,s1,0x33
    80004c64:	90d9                	srli	s1,s1,0x36
    80004c66:	00950733          	add	a4,a0,s1
    80004c6a:	05874703          	lbu	a4,88(a4)
    80004c6e:	00e7f6b3          	and	a3,a5,a4
    80004c72:	c69d                	beqz	a3,80004ca0 <bfree+0x6c>
    80004c74:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80004c76:	94aa                	add	s1,s1,a0
    80004c78:	fff7c793          	not	a5,a5
    80004c7c:	8f7d                	and	a4,a4,a5
    80004c7e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80004c82:	00001097          	auipc	ra,0x1
    80004c86:	120080e7          	jalr	288(ra) # 80005da2 <log_write>
  brelse(bp);
    80004c8a:	854a                	mv	a0,s2
    80004c8c:	00000097          	auipc	ra,0x0
    80004c90:	e92080e7          	jalr	-366(ra) # 80004b1e <brelse>
}
    80004c94:	60e2                	ld	ra,24(sp)
    80004c96:	6442                	ld	s0,16(sp)
    80004c98:	64a2                	ld	s1,8(sp)
    80004c9a:	6902                	ld	s2,0(sp)
    80004c9c:	6105                	addi	sp,sp,32
    80004c9e:	8082                	ret
    panic("freeing free block");
    80004ca0:	00005517          	auipc	a0,0x5
    80004ca4:	c2050513          	addi	a0,a0,-992 # 800098c0 <syscalls+0x260>
    80004ca8:	ffffc097          	auipc	ra,0xffffc
    80004cac:	890080e7          	jalr	-1904(ra) # 80000538 <panic>

0000000080004cb0 <balloc>:
{
    80004cb0:	711d                	addi	sp,sp,-96
    80004cb2:	ec86                	sd	ra,88(sp)
    80004cb4:	e8a2                	sd	s0,80(sp)
    80004cb6:	e4a6                	sd	s1,72(sp)
    80004cb8:	e0ca                	sd	s2,64(sp)
    80004cba:	fc4e                	sd	s3,56(sp)
    80004cbc:	f852                	sd	s4,48(sp)
    80004cbe:	f456                	sd	s5,40(sp)
    80004cc0:	f05a                	sd	s6,32(sp)
    80004cc2:	ec5e                	sd	s7,24(sp)
    80004cc4:	e862                	sd	s8,16(sp)
    80004cc6:	e466                	sd	s9,8(sp)
    80004cc8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80004cca:	0001d797          	auipc	a5,0x1d
    80004cce:	7927a783          	lw	a5,1938(a5) # 8002245c <sb+0x4>
    80004cd2:	cbc1                	beqz	a5,80004d62 <balloc+0xb2>
    80004cd4:	8baa                	mv	s7,a0
    80004cd6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004cd8:	0001db17          	auipc	s6,0x1d
    80004cdc:	780b0b13          	addi	s6,s6,1920 # 80022458 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004ce0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004ce2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004ce4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004ce6:	6c89                	lui	s9,0x2
    80004ce8:	a831                	j	80004d04 <balloc+0x54>
    brelse(bp);
    80004cea:	854a                	mv	a0,s2
    80004cec:	00000097          	auipc	ra,0x0
    80004cf0:	e32080e7          	jalr	-462(ra) # 80004b1e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004cf4:	015c87bb          	addw	a5,s9,s5
    80004cf8:	00078a9b          	sext.w	s5,a5
    80004cfc:	004b2703          	lw	a4,4(s6)
    80004d00:	06eaf163          	bgeu	s5,a4,80004d62 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80004d04:	41fad79b          	sraiw	a5,s5,0x1f
    80004d08:	0137d79b          	srliw	a5,a5,0x13
    80004d0c:	015787bb          	addw	a5,a5,s5
    80004d10:	40d7d79b          	sraiw	a5,a5,0xd
    80004d14:	01cb2583          	lw	a1,28(s6)
    80004d18:	9dbd                	addw	a1,a1,a5
    80004d1a:	855e                	mv	a0,s7
    80004d1c:	00000097          	auipc	ra,0x0
    80004d20:	cd2080e7          	jalr	-814(ra) # 800049ee <bread>
    80004d24:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004d26:	004b2503          	lw	a0,4(s6)
    80004d2a:	000a849b          	sext.w	s1,s5
    80004d2e:	8762                	mv	a4,s8
    80004d30:	faa4fde3          	bgeu	s1,a0,80004cea <balloc+0x3a>
      m = 1 << (bi % 8);
    80004d34:	00777693          	andi	a3,a4,7
    80004d38:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004d3c:	41f7579b          	sraiw	a5,a4,0x1f
    80004d40:	01d7d79b          	srliw	a5,a5,0x1d
    80004d44:	9fb9                	addw	a5,a5,a4
    80004d46:	4037d79b          	sraiw	a5,a5,0x3
    80004d4a:	00f90633          	add	a2,s2,a5
    80004d4e:	05864603          	lbu	a2,88(a2)
    80004d52:	00c6f5b3          	and	a1,a3,a2
    80004d56:	cd91                	beqz	a1,80004d72 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004d58:	2705                	addiw	a4,a4,1
    80004d5a:	2485                	addiw	s1,s1,1
    80004d5c:	fd471ae3          	bne	a4,s4,80004d30 <balloc+0x80>
    80004d60:	b769                	j	80004cea <balloc+0x3a>
  panic("balloc: out of blocks");
    80004d62:	00005517          	auipc	a0,0x5
    80004d66:	b7650513          	addi	a0,a0,-1162 # 800098d8 <syscalls+0x278>
    80004d6a:	ffffb097          	auipc	ra,0xffffb
    80004d6e:	7ce080e7          	jalr	1998(ra) # 80000538 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80004d72:	97ca                	add	a5,a5,s2
    80004d74:	8e55                	or	a2,a2,a3
    80004d76:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80004d7a:	854a                	mv	a0,s2
    80004d7c:	00001097          	auipc	ra,0x1
    80004d80:	026080e7          	jalr	38(ra) # 80005da2 <log_write>
        brelse(bp);
    80004d84:	854a                	mv	a0,s2
    80004d86:	00000097          	auipc	ra,0x0
    80004d8a:	d98080e7          	jalr	-616(ra) # 80004b1e <brelse>
  bp = bread(dev, bno);
    80004d8e:	85a6                	mv	a1,s1
    80004d90:	855e                	mv	a0,s7
    80004d92:	00000097          	auipc	ra,0x0
    80004d96:	c5c080e7          	jalr	-932(ra) # 800049ee <bread>
    80004d9a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004d9c:	40000613          	li	a2,1024
    80004da0:	4581                	li	a1,0
    80004da2:	05850513          	addi	a0,a0,88
    80004da6:	ffffc097          	auipc	ra,0xffffc
    80004daa:	f24080e7          	jalr	-220(ra) # 80000cca <memset>
  log_write(bp);
    80004dae:	854a                	mv	a0,s2
    80004db0:	00001097          	auipc	ra,0x1
    80004db4:	ff2080e7          	jalr	-14(ra) # 80005da2 <log_write>
  brelse(bp);
    80004db8:	854a                	mv	a0,s2
    80004dba:	00000097          	auipc	ra,0x0
    80004dbe:	d64080e7          	jalr	-668(ra) # 80004b1e <brelse>
}
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	60e6                	ld	ra,88(sp)
    80004dc6:	6446                	ld	s0,80(sp)
    80004dc8:	64a6                	ld	s1,72(sp)
    80004dca:	6906                	ld	s2,64(sp)
    80004dcc:	79e2                	ld	s3,56(sp)
    80004dce:	7a42                	ld	s4,48(sp)
    80004dd0:	7aa2                	ld	s5,40(sp)
    80004dd2:	7b02                	ld	s6,32(sp)
    80004dd4:	6be2                	ld	s7,24(sp)
    80004dd6:	6c42                	ld	s8,16(sp)
    80004dd8:	6ca2                	ld	s9,8(sp)
    80004dda:	6125                	addi	sp,sp,96
    80004ddc:	8082                	ret

0000000080004dde <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004dde:	7179                	addi	sp,sp,-48
    80004de0:	f406                	sd	ra,40(sp)
    80004de2:	f022                	sd	s0,32(sp)
    80004de4:	ec26                	sd	s1,24(sp)
    80004de6:	e84a                	sd	s2,16(sp)
    80004de8:	e44e                	sd	s3,8(sp)
    80004dea:	e052                	sd	s4,0(sp)
    80004dec:	1800                	addi	s0,sp,48
    80004dee:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004df0:	47ad                	li	a5,11
    80004df2:	04b7fe63          	bgeu	a5,a1,80004e4e <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80004df6:	ff45849b          	addiw	s1,a1,-12
    80004dfa:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004dfe:	0ff00793          	li	a5,255
    80004e02:	0ae7e463          	bltu	a5,a4,80004eaa <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004e06:	08052583          	lw	a1,128(a0)
    80004e0a:	c5b5                	beqz	a1,80004e76 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004e0c:	00092503          	lw	a0,0(s2)
    80004e10:	00000097          	auipc	ra,0x0
    80004e14:	bde080e7          	jalr	-1058(ra) # 800049ee <bread>
    80004e18:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004e1a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004e1e:	02049713          	slli	a4,s1,0x20
    80004e22:	01e75593          	srli	a1,a4,0x1e
    80004e26:	00b784b3          	add	s1,a5,a1
    80004e2a:	0004a983          	lw	s3,0(s1)
    80004e2e:	04098e63          	beqz	s3,80004e8a <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004e32:	8552                	mv	a0,s4
    80004e34:	00000097          	auipc	ra,0x0
    80004e38:	cea080e7          	jalr	-790(ra) # 80004b1e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004e3c:	854e                	mv	a0,s3
    80004e3e:	70a2                	ld	ra,40(sp)
    80004e40:	7402                	ld	s0,32(sp)
    80004e42:	64e2                	ld	s1,24(sp)
    80004e44:	6942                	ld	s2,16(sp)
    80004e46:	69a2                	ld	s3,8(sp)
    80004e48:	6a02                	ld	s4,0(sp)
    80004e4a:	6145                	addi	sp,sp,48
    80004e4c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004e4e:	02059793          	slli	a5,a1,0x20
    80004e52:	01e7d593          	srli	a1,a5,0x1e
    80004e56:	00b504b3          	add	s1,a0,a1
    80004e5a:	0504a983          	lw	s3,80(s1)
    80004e5e:	fc099fe3          	bnez	s3,80004e3c <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80004e62:	4108                	lw	a0,0(a0)
    80004e64:	00000097          	auipc	ra,0x0
    80004e68:	e4c080e7          	jalr	-436(ra) # 80004cb0 <balloc>
    80004e6c:	0005099b          	sext.w	s3,a0
    80004e70:	0534a823          	sw	s3,80(s1)
    80004e74:	b7e1                	j	80004e3c <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80004e76:	4108                	lw	a0,0(a0)
    80004e78:	00000097          	auipc	ra,0x0
    80004e7c:	e38080e7          	jalr	-456(ra) # 80004cb0 <balloc>
    80004e80:	0005059b          	sext.w	a1,a0
    80004e84:	08b92023          	sw	a1,128(s2)
    80004e88:	b751                	j	80004e0c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004e8a:	00092503          	lw	a0,0(s2)
    80004e8e:	00000097          	auipc	ra,0x0
    80004e92:	e22080e7          	jalr	-478(ra) # 80004cb0 <balloc>
    80004e96:	0005099b          	sext.w	s3,a0
    80004e9a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004e9e:	8552                	mv	a0,s4
    80004ea0:	00001097          	auipc	ra,0x1
    80004ea4:	f02080e7          	jalr	-254(ra) # 80005da2 <log_write>
    80004ea8:	b769                	j	80004e32 <bmap+0x54>
  panic("bmap: out of range");
    80004eaa:	00005517          	auipc	a0,0x5
    80004eae:	a4650513          	addi	a0,a0,-1466 # 800098f0 <syscalls+0x290>
    80004eb2:	ffffb097          	auipc	ra,0xffffb
    80004eb6:	686080e7          	jalr	1670(ra) # 80000538 <panic>

0000000080004eba <iget>:
{
    80004eba:	7179                	addi	sp,sp,-48
    80004ebc:	f406                	sd	ra,40(sp)
    80004ebe:	f022                	sd	s0,32(sp)
    80004ec0:	ec26                	sd	s1,24(sp)
    80004ec2:	e84a                	sd	s2,16(sp)
    80004ec4:	e44e                	sd	s3,8(sp)
    80004ec6:	e052                	sd	s4,0(sp)
    80004ec8:	1800                	addi	s0,sp,48
    80004eca:	89aa                	mv	s3,a0
    80004ecc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004ece:	0001d517          	auipc	a0,0x1d
    80004ed2:	5aa50513          	addi	a0,a0,1450 # 80022478 <itable>
    80004ed6:	ffffc097          	auipc	ra,0xffffc
    80004eda:	cf8080e7          	jalr	-776(ra) # 80000bce <acquire>
  empty = 0;
    80004ede:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004ee0:	0001d497          	auipc	s1,0x1d
    80004ee4:	5b048493          	addi	s1,s1,1456 # 80022490 <itable+0x18>
    80004ee8:	0001f697          	auipc	a3,0x1f
    80004eec:	03868693          	addi	a3,a3,56 # 80023f20 <log>
    80004ef0:	a039                	j	80004efe <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004ef2:	02090b63          	beqz	s2,80004f28 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004ef6:	08848493          	addi	s1,s1,136
    80004efa:	02d48a63          	beq	s1,a3,80004f2e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004efe:	449c                	lw	a5,8(s1)
    80004f00:	fef059e3          	blez	a5,80004ef2 <iget+0x38>
    80004f04:	4098                	lw	a4,0(s1)
    80004f06:	ff3716e3          	bne	a4,s3,80004ef2 <iget+0x38>
    80004f0a:	40d8                	lw	a4,4(s1)
    80004f0c:	ff4713e3          	bne	a4,s4,80004ef2 <iget+0x38>
      ip->ref++;
    80004f10:	2785                	addiw	a5,a5,1
    80004f12:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004f14:	0001d517          	auipc	a0,0x1d
    80004f18:	56450513          	addi	a0,a0,1380 # 80022478 <itable>
    80004f1c:	ffffc097          	auipc	ra,0xffffc
    80004f20:	d66080e7          	jalr	-666(ra) # 80000c82 <release>
      return ip;
    80004f24:	8926                	mv	s2,s1
    80004f26:	a03d                	j	80004f54 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004f28:	f7f9                	bnez	a5,80004ef6 <iget+0x3c>
    80004f2a:	8926                	mv	s2,s1
    80004f2c:	b7e9                	j	80004ef6 <iget+0x3c>
  if(empty == 0)
    80004f2e:	02090c63          	beqz	s2,80004f66 <iget+0xac>
  ip->dev = dev;
    80004f32:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004f36:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004f3a:	4785                	li	a5,1
    80004f3c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004f40:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004f44:	0001d517          	auipc	a0,0x1d
    80004f48:	53450513          	addi	a0,a0,1332 # 80022478 <itable>
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	d36080e7          	jalr	-714(ra) # 80000c82 <release>
}
    80004f54:	854a                	mv	a0,s2
    80004f56:	70a2                	ld	ra,40(sp)
    80004f58:	7402                	ld	s0,32(sp)
    80004f5a:	64e2                	ld	s1,24(sp)
    80004f5c:	6942                	ld	s2,16(sp)
    80004f5e:	69a2                	ld	s3,8(sp)
    80004f60:	6a02                	ld	s4,0(sp)
    80004f62:	6145                	addi	sp,sp,48
    80004f64:	8082                	ret
    panic("iget: no inodes");
    80004f66:	00005517          	auipc	a0,0x5
    80004f6a:	9a250513          	addi	a0,a0,-1630 # 80009908 <syscalls+0x2a8>
    80004f6e:	ffffb097          	auipc	ra,0xffffb
    80004f72:	5ca080e7          	jalr	1482(ra) # 80000538 <panic>

0000000080004f76 <fsinit>:
fsinit(int dev) {
    80004f76:	7179                	addi	sp,sp,-48
    80004f78:	f406                	sd	ra,40(sp)
    80004f7a:	f022                	sd	s0,32(sp)
    80004f7c:	ec26                	sd	s1,24(sp)
    80004f7e:	e84a                	sd	s2,16(sp)
    80004f80:	e44e                	sd	s3,8(sp)
    80004f82:	1800                	addi	s0,sp,48
    80004f84:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80004f86:	4585                	li	a1,1
    80004f88:	00000097          	auipc	ra,0x0
    80004f8c:	a66080e7          	jalr	-1434(ra) # 800049ee <bread>
    80004f90:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80004f92:	0001d997          	auipc	s3,0x1d
    80004f96:	4c698993          	addi	s3,s3,1222 # 80022458 <sb>
    80004f9a:	02000613          	li	a2,32
    80004f9e:	05850593          	addi	a1,a0,88
    80004fa2:	854e                	mv	a0,s3
    80004fa4:	ffffc097          	auipc	ra,0xffffc
    80004fa8:	d82080e7          	jalr	-638(ra) # 80000d26 <memmove>
  brelse(bp);
    80004fac:	8526                	mv	a0,s1
    80004fae:	00000097          	auipc	ra,0x0
    80004fb2:	b70080e7          	jalr	-1168(ra) # 80004b1e <brelse>
  if(sb.magic != FSMAGIC)
    80004fb6:	0009a703          	lw	a4,0(s3)
    80004fba:	102037b7          	lui	a5,0x10203
    80004fbe:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004fc2:	02f71263          	bne	a4,a5,80004fe6 <fsinit+0x70>
  initlog(dev, &sb);
    80004fc6:	0001d597          	auipc	a1,0x1d
    80004fca:	49258593          	addi	a1,a1,1170 # 80022458 <sb>
    80004fce:	854a                	mv	a0,s2
    80004fd0:	00001097          	auipc	ra,0x1
    80004fd4:	b56080e7          	jalr	-1194(ra) # 80005b26 <initlog>
}
    80004fd8:	70a2                	ld	ra,40(sp)
    80004fda:	7402                	ld	s0,32(sp)
    80004fdc:	64e2                	ld	s1,24(sp)
    80004fde:	6942                	ld	s2,16(sp)
    80004fe0:	69a2                	ld	s3,8(sp)
    80004fe2:	6145                	addi	sp,sp,48
    80004fe4:	8082                	ret
    panic("invalid file system");
    80004fe6:	00005517          	auipc	a0,0x5
    80004fea:	93250513          	addi	a0,a0,-1742 # 80009918 <syscalls+0x2b8>
    80004fee:	ffffb097          	auipc	ra,0xffffb
    80004ff2:	54a080e7          	jalr	1354(ra) # 80000538 <panic>

0000000080004ff6 <iinit>:
{
    80004ff6:	7179                	addi	sp,sp,-48
    80004ff8:	f406                	sd	ra,40(sp)
    80004ffa:	f022                	sd	s0,32(sp)
    80004ffc:	ec26                	sd	s1,24(sp)
    80004ffe:	e84a                	sd	s2,16(sp)
    80005000:	e44e                	sd	s3,8(sp)
    80005002:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80005004:	00005597          	auipc	a1,0x5
    80005008:	92c58593          	addi	a1,a1,-1748 # 80009930 <syscalls+0x2d0>
    8000500c:	0001d517          	auipc	a0,0x1d
    80005010:	46c50513          	addi	a0,a0,1132 # 80022478 <itable>
    80005014:	ffffc097          	auipc	ra,0xffffc
    80005018:	b2a080e7          	jalr	-1238(ra) # 80000b3e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000501c:	0001d497          	auipc	s1,0x1d
    80005020:	48448493          	addi	s1,s1,1156 # 800224a0 <itable+0x28>
    80005024:	0001f997          	auipc	s3,0x1f
    80005028:	f0c98993          	addi	s3,s3,-244 # 80023f30 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000502c:	00005917          	auipc	s2,0x5
    80005030:	90c90913          	addi	s2,s2,-1780 # 80009938 <syscalls+0x2d8>
    80005034:	85ca                	mv	a1,s2
    80005036:	8526                	mv	a0,s1
    80005038:	00001097          	auipc	ra,0x1
    8000503c:	e4e080e7          	jalr	-434(ra) # 80005e86 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80005040:	08848493          	addi	s1,s1,136
    80005044:	ff3498e3          	bne	s1,s3,80005034 <iinit+0x3e>
}
    80005048:	70a2                	ld	ra,40(sp)
    8000504a:	7402                	ld	s0,32(sp)
    8000504c:	64e2                	ld	s1,24(sp)
    8000504e:	6942                	ld	s2,16(sp)
    80005050:	69a2                	ld	s3,8(sp)
    80005052:	6145                	addi	sp,sp,48
    80005054:	8082                	ret

0000000080005056 <ialloc>:
{
    80005056:	715d                	addi	sp,sp,-80
    80005058:	e486                	sd	ra,72(sp)
    8000505a:	e0a2                	sd	s0,64(sp)
    8000505c:	fc26                	sd	s1,56(sp)
    8000505e:	f84a                	sd	s2,48(sp)
    80005060:	f44e                	sd	s3,40(sp)
    80005062:	f052                	sd	s4,32(sp)
    80005064:	ec56                	sd	s5,24(sp)
    80005066:	e85a                	sd	s6,16(sp)
    80005068:	e45e                	sd	s7,8(sp)
    8000506a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000506c:	0001d717          	auipc	a4,0x1d
    80005070:	3f872703          	lw	a4,1016(a4) # 80022464 <sb+0xc>
    80005074:	4785                	li	a5,1
    80005076:	04e7fa63          	bgeu	a5,a4,800050ca <ialloc+0x74>
    8000507a:	8aaa                	mv	s5,a0
    8000507c:	8bae                	mv	s7,a1
    8000507e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80005080:	0001da17          	auipc	s4,0x1d
    80005084:	3d8a0a13          	addi	s4,s4,984 # 80022458 <sb>
    80005088:	00048b1b          	sext.w	s6,s1
    8000508c:	0044d593          	srli	a1,s1,0x4
    80005090:	018a2783          	lw	a5,24(s4)
    80005094:	9dbd                	addw	a1,a1,a5
    80005096:	8556                	mv	a0,s5
    80005098:	00000097          	auipc	ra,0x0
    8000509c:	956080e7          	jalr	-1706(ra) # 800049ee <bread>
    800050a0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800050a2:	05850993          	addi	s3,a0,88
    800050a6:	00f4f793          	andi	a5,s1,15
    800050aa:	079a                	slli	a5,a5,0x6
    800050ac:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800050ae:	00099783          	lh	a5,0(s3)
    800050b2:	c785                	beqz	a5,800050da <ialloc+0x84>
    brelse(bp);
    800050b4:	00000097          	auipc	ra,0x0
    800050b8:	a6a080e7          	jalr	-1430(ra) # 80004b1e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800050bc:	0485                	addi	s1,s1,1
    800050be:	00ca2703          	lw	a4,12(s4)
    800050c2:	0004879b          	sext.w	a5,s1
    800050c6:	fce7e1e3          	bltu	a5,a4,80005088 <ialloc+0x32>
  panic("ialloc: no inodes");
    800050ca:	00005517          	auipc	a0,0x5
    800050ce:	87650513          	addi	a0,a0,-1930 # 80009940 <syscalls+0x2e0>
    800050d2:	ffffb097          	auipc	ra,0xffffb
    800050d6:	466080e7          	jalr	1126(ra) # 80000538 <panic>
      memset(dip, 0, sizeof(*dip));
    800050da:	04000613          	li	a2,64
    800050de:	4581                	li	a1,0
    800050e0:	854e                	mv	a0,s3
    800050e2:	ffffc097          	auipc	ra,0xffffc
    800050e6:	be8080e7          	jalr	-1048(ra) # 80000cca <memset>
      dip->type = type;
    800050ea:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800050ee:	854a                	mv	a0,s2
    800050f0:	00001097          	auipc	ra,0x1
    800050f4:	cb2080e7          	jalr	-846(ra) # 80005da2 <log_write>
      brelse(bp);
    800050f8:	854a                	mv	a0,s2
    800050fa:	00000097          	auipc	ra,0x0
    800050fe:	a24080e7          	jalr	-1500(ra) # 80004b1e <brelse>
      return iget(dev, inum);
    80005102:	85da                	mv	a1,s6
    80005104:	8556                	mv	a0,s5
    80005106:	00000097          	auipc	ra,0x0
    8000510a:	db4080e7          	jalr	-588(ra) # 80004eba <iget>
}
    8000510e:	60a6                	ld	ra,72(sp)
    80005110:	6406                	ld	s0,64(sp)
    80005112:	74e2                	ld	s1,56(sp)
    80005114:	7942                	ld	s2,48(sp)
    80005116:	79a2                	ld	s3,40(sp)
    80005118:	7a02                	ld	s4,32(sp)
    8000511a:	6ae2                	ld	s5,24(sp)
    8000511c:	6b42                	ld	s6,16(sp)
    8000511e:	6ba2                	ld	s7,8(sp)
    80005120:	6161                	addi	sp,sp,80
    80005122:	8082                	ret

0000000080005124 <iupdate>:
{
    80005124:	1101                	addi	sp,sp,-32
    80005126:	ec06                	sd	ra,24(sp)
    80005128:	e822                	sd	s0,16(sp)
    8000512a:	e426                	sd	s1,8(sp)
    8000512c:	e04a                	sd	s2,0(sp)
    8000512e:	1000                	addi	s0,sp,32
    80005130:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80005132:	415c                	lw	a5,4(a0)
    80005134:	0047d79b          	srliw	a5,a5,0x4
    80005138:	0001d597          	auipc	a1,0x1d
    8000513c:	3385a583          	lw	a1,824(a1) # 80022470 <sb+0x18>
    80005140:	9dbd                	addw	a1,a1,a5
    80005142:	4108                	lw	a0,0(a0)
    80005144:	00000097          	auipc	ra,0x0
    80005148:	8aa080e7          	jalr	-1878(ra) # 800049ee <bread>
    8000514c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000514e:	05850793          	addi	a5,a0,88
    80005152:	40d8                	lw	a4,4(s1)
    80005154:	8b3d                	andi	a4,a4,15
    80005156:	071a                	slli	a4,a4,0x6
    80005158:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000515a:	04449703          	lh	a4,68(s1)
    8000515e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80005162:	04649703          	lh	a4,70(s1)
    80005166:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000516a:	04849703          	lh	a4,72(s1)
    8000516e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80005172:	04a49703          	lh	a4,74(s1)
    80005176:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000517a:	44f8                	lw	a4,76(s1)
    8000517c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000517e:	03400613          	li	a2,52
    80005182:	05048593          	addi	a1,s1,80
    80005186:	00c78513          	addi	a0,a5,12
    8000518a:	ffffc097          	auipc	ra,0xffffc
    8000518e:	b9c080e7          	jalr	-1124(ra) # 80000d26 <memmove>
  log_write(bp);
    80005192:	854a                	mv	a0,s2
    80005194:	00001097          	auipc	ra,0x1
    80005198:	c0e080e7          	jalr	-1010(ra) # 80005da2 <log_write>
  brelse(bp);
    8000519c:	854a                	mv	a0,s2
    8000519e:	00000097          	auipc	ra,0x0
    800051a2:	980080e7          	jalr	-1664(ra) # 80004b1e <brelse>
}
    800051a6:	60e2                	ld	ra,24(sp)
    800051a8:	6442                	ld	s0,16(sp)
    800051aa:	64a2                	ld	s1,8(sp)
    800051ac:	6902                	ld	s2,0(sp)
    800051ae:	6105                	addi	sp,sp,32
    800051b0:	8082                	ret

00000000800051b2 <idup>:
{
    800051b2:	1101                	addi	sp,sp,-32
    800051b4:	ec06                	sd	ra,24(sp)
    800051b6:	e822                	sd	s0,16(sp)
    800051b8:	e426                	sd	s1,8(sp)
    800051ba:	1000                	addi	s0,sp,32
    800051bc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800051be:	0001d517          	auipc	a0,0x1d
    800051c2:	2ba50513          	addi	a0,a0,698 # 80022478 <itable>
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	a08080e7          	jalr	-1528(ra) # 80000bce <acquire>
  ip->ref++;
    800051ce:	449c                	lw	a5,8(s1)
    800051d0:	2785                	addiw	a5,a5,1
    800051d2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800051d4:	0001d517          	auipc	a0,0x1d
    800051d8:	2a450513          	addi	a0,a0,676 # 80022478 <itable>
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	aa6080e7          	jalr	-1370(ra) # 80000c82 <release>
}
    800051e4:	8526                	mv	a0,s1
    800051e6:	60e2                	ld	ra,24(sp)
    800051e8:	6442                	ld	s0,16(sp)
    800051ea:	64a2                	ld	s1,8(sp)
    800051ec:	6105                	addi	sp,sp,32
    800051ee:	8082                	ret

00000000800051f0 <ilock>:
{
    800051f0:	1101                	addi	sp,sp,-32
    800051f2:	ec06                	sd	ra,24(sp)
    800051f4:	e822                	sd	s0,16(sp)
    800051f6:	e426                	sd	s1,8(sp)
    800051f8:	e04a                	sd	s2,0(sp)
    800051fa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800051fc:	c115                	beqz	a0,80005220 <ilock+0x30>
    800051fe:	84aa                	mv	s1,a0
    80005200:	451c                	lw	a5,8(a0)
    80005202:	00f05f63          	blez	a5,80005220 <ilock+0x30>
  acquiresleep(&ip->lock);
    80005206:	0541                	addi	a0,a0,16
    80005208:	00001097          	auipc	ra,0x1
    8000520c:	cb8080e7          	jalr	-840(ra) # 80005ec0 <acquiresleep>
  if(ip->valid == 0){
    80005210:	40bc                	lw	a5,64(s1)
    80005212:	cf99                	beqz	a5,80005230 <ilock+0x40>
}
    80005214:	60e2                	ld	ra,24(sp)
    80005216:	6442                	ld	s0,16(sp)
    80005218:	64a2                	ld	s1,8(sp)
    8000521a:	6902                	ld	s2,0(sp)
    8000521c:	6105                	addi	sp,sp,32
    8000521e:	8082                	ret
    panic("ilock");
    80005220:	00004517          	auipc	a0,0x4
    80005224:	73850513          	addi	a0,a0,1848 # 80009958 <syscalls+0x2f8>
    80005228:	ffffb097          	auipc	ra,0xffffb
    8000522c:	310080e7          	jalr	784(ra) # 80000538 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80005230:	40dc                	lw	a5,4(s1)
    80005232:	0047d79b          	srliw	a5,a5,0x4
    80005236:	0001d597          	auipc	a1,0x1d
    8000523a:	23a5a583          	lw	a1,570(a1) # 80022470 <sb+0x18>
    8000523e:	9dbd                	addw	a1,a1,a5
    80005240:	4088                	lw	a0,0(s1)
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	7ac080e7          	jalr	1964(ra) # 800049ee <bread>
    8000524a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000524c:	05850593          	addi	a1,a0,88
    80005250:	40dc                	lw	a5,4(s1)
    80005252:	8bbd                	andi	a5,a5,15
    80005254:	079a                	slli	a5,a5,0x6
    80005256:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80005258:	00059783          	lh	a5,0(a1)
    8000525c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80005260:	00259783          	lh	a5,2(a1)
    80005264:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80005268:	00459783          	lh	a5,4(a1)
    8000526c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80005270:	00659783          	lh	a5,6(a1)
    80005274:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80005278:	459c                	lw	a5,8(a1)
    8000527a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000527c:	03400613          	li	a2,52
    80005280:	05b1                	addi	a1,a1,12
    80005282:	05048513          	addi	a0,s1,80
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	aa0080e7          	jalr	-1376(ra) # 80000d26 <memmove>
    brelse(bp);
    8000528e:	854a                	mv	a0,s2
    80005290:	00000097          	auipc	ra,0x0
    80005294:	88e080e7          	jalr	-1906(ra) # 80004b1e <brelse>
    ip->valid = 1;
    80005298:	4785                	li	a5,1
    8000529a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000529c:	04449783          	lh	a5,68(s1)
    800052a0:	fbb5                	bnez	a5,80005214 <ilock+0x24>
      panic("ilock: no type");
    800052a2:	00004517          	auipc	a0,0x4
    800052a6:	6be50513          	addi	a0,a0,1726 # 80009960 <syscalls+0x300>
    800052aa:	ffffb097          	auipc	ra,0xffffb
    800052ae:	28e080e7          	jalr	654(ra) # 80000538 <panic>

00000000800052b2 <iunlock>:
{
    800052b2:	1101                	addi	sp,sp,-32
    800052b4:	ec06                	sd	ra,24(sp)
    800052b6:	e822                	sd	s0,16(sp)
    800052b8:	e426                	sd	s1,8(sp)
    800052ba:	e04a                	sd	s2,0(sp)
    800052bc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800052be:	c905                	beqz	a0,800052ee <iunlock+0x3c>
    800052c0:	84aa                	mv	s1,a0
    800052c2:	01050913          	addi	s2,a0,16
    800052c6:	854a                	mv	a0,s2
    800052c8:	00001097          	auipc	ra,0x1
    800052cc:	c92080e7          	jalr	-878(ra) # 80005f5a <holdingsleep>
    800052d0:	cd19                	beqz	a0,800052ee <iunlock+0x3c>
    800052d2:	449c                	lw	a5,8(s1)
    800052d4:	00f05d63          	blez	a5,800052ee <iunlock+0x3c>
  releasesleep(&ip->lock);
    800052d8:	854a                	mv	a0,s2
    800052da:	00001097          	auipc	ra,0x1
    800052de:	c3c080e7          	jalr	-964(ra) # 80005f16 <releasesleep>
}
    800052e2:	60e2                	ld	ra,24(sp)
    800052e4:	6442                	ld	s0,16(sp)
    800052e6:	64a2                	ld	s1,8(sp)
    800052e8:	6902                	ld	s2,0(sp)
    800052ea:	6105                	addi	sp,sp,32
    800052ec:	8082                	ret
    panic("iunlock");
    800052ee:	00004517          	auipc	a0,0x4
    800052f2:	68250513          	addi	a0,a0,1666 # 80009970 <syscalls+0x310>
    800052f6:	ffffb097          	auipc	ra,0xffffb
    800052fa:	242080e7          	jalr	578(ra) # 80000538 <panic>

00000000800052fe <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800052fe:	7179                	addi	sp,sp,-48
    80005300:	f406                	sd	ra,40(sp)
    80005302:	f022                	sd	s0,32(sp)
    80005304:	ec26                	sd	s1,24(sp)
    80005306:	e84a                	sd	s2,16(sp)
    80005308:	e44e                	sd	s3,8(sp)
    8000530a:	e052                	sd	s4,0(sp)
    8000530c:	1800                	addi	s0,sp,48
    8000530e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80005310:	05050493          	addi	s1,a0,80
    80005314:	08050913          	addi	s2,a0,128
    80005318:	a021                	j	80005320 <itrunc+0x22>
    8000531a:	0491                	addi	s1,s1,4
    8000531c:	01248d63          	beq	s1,s2,80005336 <itrunc+0x38>
    if(ip->addrs[i]){
    80005320:	408c                	lw	a1,0(s1)
    80005322:	dde5                	beqz	a1,8000531a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80005324:	0009a503          	lw	a0,0(s3)
    80005328:	00000097          	auipc	ra,0x0
    8000532c:	90c080e7          	jalr	-1780(ra) # 80004c34 <bfree>
      ip->addrs[i] = 0;
    80005330:	0004a023          	sw	zero,0(s1)
    80005334:	b7dd                	j	8000531a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80005336:	0809a583          	lw	a1,128(s3)
    8000533a:	e185                	bnez	a1,8000535a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000533c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80005340:	854e                	mv	a0,s3
    80005342:	00000097          	auipc	ra,0x0
    80005346:	de2080e7          	jalr	-542(ra) # 80005124 <iupdate>
}
    8000534a:	70a2                	ld	ra,40(sp)
    8000534c:	7402                	ld	s0,32(sp)
    8000534e:	64e2                	ld	s1,24(sp)
    80005350:	6942                	ld	s2,16(sp)
    80005352:	69a2                	ld	s3,8(sp)
    80005354:	6a02                	ld	s4,0(sp)
    80005356:	6145                	addi	sp,sp,48
    80005358:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000535a:	0009a503          	lw	a0,0(s3)
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	690080e7          	jalr	1680(ra) # 800049ee <bread>
    80005366:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80005368:	05850493          	addi	s1,a0,88
    8000536c:	45850913          	addi	s2,a0,1112
    80005370:	a021                	j	80005378 <itrunc+0x7a>
    80005372:	0491                	addi	s1,s1,4
    80005374:	01248b63          	beq	s1,s2,8000538a <itrunc+0x8c>
      if(a[j])
    80005378:	408c                	lw	a1,0(s1)
    8000537a:	dde5                	beqz	a1,80005372 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000537c:	0009a503          	lw	a0,0(s3)
    80005380:	00000097          	auipc	ra,0x0
    80005384:	8b4080e7          	jalr	-1868(ra) # 80004c34 <bfree>
    80005388:	b7ed                	j	80005372 <itrunc+0x74>
    brelse(bp);
    8000538a:	8552                	mv	a0,s4
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	792080e7          	jalr	1938(ra) # 80004b1e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80005394:	0809a583          	lw	a1,128(s3)
    80005398:	0009a503          	lw	a0,0(s3)
    8000539c:	00000097          	auipc	ra,0x0
    800053a0:	898080e7          	jalr	-1896(ra) # 80004c34 <bfree>
    ip->addrs[NDIRECT] = 0;
    800053a4:	0809a023          	sw	zero,128(s3)
    800053a8:	bf51                	j	8000533c <itrunc+0x3e>

00000000800053aa <iput>:
{
    800053aa:	1101                	addi	sp,sp,-32
    800053ac:	ec06                	sd	ra,24(sp)
    800053ae:	e822                	sd	s0,16(sp)
    800053b0:	e426                	sd	s1,8(sp)
    800053b2:	e04a                	sd	s2,0(sp)
    800053b4:	1000                	addi	s0,sp,32
    800053b6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800053b8:	0001d517          	auipc	a0,0x1d
    800053bc:	0c050513          	addi	a0,a0,192 # 80022478 <itable>
    800053c0:	ffffc097          	auipc	ra,0xffffc
    800053c4:	80e080e7          	jalr	-2034(ra) # 80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800053c8:	4498                	lw	a4,8(s1)
    800053ca:	4785                	li	a5,1
    800053cc:	02f70363          	beq	a4,a5,800053f2 <iput+0x48>
  ip->ref--;
    800053d0:	449c                	lw	a5,8(s1)
    800053d2:	37fd                	addiw	a5,a5,-1
    800053d4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800053d6:	0001d517          	auipc	a0,0x1d
    800053da:	0a250513          	addi	a0,a0,162 # 80022478 <itable>
    800053de:	ffffc097          	auipc	ra,0xffffc
    800053e2:	8a4080e7          	jalr	-1884(ra) # 80000c82 <release>
}
    800053e6:	60e2                	ld	ra,24(sp)
    800053e8:	6442                	ld	s0,16(sp)
    800053ea:	64a2                	ld	s1,8(sp)
    800053ec:	6902                	ld	s2,0(sp)
    800053ee:	6105                	addi	sp,sp,32
    800053f0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800053f2:	40bc                	lw	a5,64(s1)
    800053f4:	dff1                	beqz	a5,800053d0 <iput+0x26>
    800053f6:	04a49783          	lh	a5,74(s1)
    800053fa:	fbf9                	bnez	a5,800053d0 <iput+0x26>
    acquiresleep(&ip->lock);
    800053fc:	01048913          	addi	s2,s1,16
    80005400:	854a                	mv	a0,s2
    80005402:	00001097          	auipc	ra,0x1
    80005406:	abe080e7          	jalr	-1346(ra) # 80005ec0 <acquiresleep>
    release(&itable.lock);
    8000540a:	0001d517          	auipc	a0,0x1d
    8000540e:	06e50513          	addi	a0,a0,110 # 80022478 <itable>
    80005412:	ffffc097          	auipc	ra,0xffffc
    80005416:	870080e7          	jalr	-1936(ra) # 80000c82 <release>
    itrunc(ip);
    8000541a:	8526                	mv	a0,s1
    8000541c:	00000097          	auipc	ra,0x0
    80005420:	ee2080e7          	jalr	-286(ra) # 800052fe <itrunc>
    ip->type = 0;
    80005424:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80005428:	8526                	mv	a0,s1
    8000542a:	00000097          	auipc	ra,0x0
    8000542e:	cfa080e7          	jalr	-774(ra) # 80005124 <iupdate>
    ip->valid = 0;
    80005432:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80005436:	854a                	mv	a0,s2
    80005438:	00001097          	auipc	ra,0x1
    8000543c:	ade080e7          	jalr	-1314(ra) # 80005f16 <releasesleep>
    acquire(&itable.lock);
    80005440:	0001d517          	auipc	a0,0x1d
    80005444:	03850513          	addi	a0,a0,56 # 80022478 <itable>
    80005448:	ffffb097          	auipc	ra,0xffffb
    8000544c:	786080e7          	jalr	1926(ra) # 80000bce <acquire>
    80005450:	b741                	j	800053d0 <iput+0x26>

0000000080005452 <iunlockput>:
{
    80005452:	1101                	addi	sp,sp,-32
    80005454:	ec06                	sd	ra,24(sp)
    80005456:	e822                	sd	s0,16(sp)
    80005458:	e426                	sd	s1,8(sp)
    8000545a:	1000                	addi	s0,sp,32
    8000545c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000545e:	00000097          	auipc	ra,0x0
    80005462:	e54080e7          	jalr	-428(ra) # 800052b2 <iunlock>
  iput(ip);
    80005466:	8526                	mv	a0,s1
    80005468:	00000097          	auipc	ra,0x0
    8000546c:	f42080e7          	jalr	-190(ra) # 800053aa <iput>
}
    80005470:	60e2                	ld	ra,24(sp)
    80005472:	6442                	ld	s0,16(sp)
    80005474:	64a2                	ld	s1,8(sp)
    80005476:	6105                	addi	sp,sp,32
    80005478:	8082                	ret

000000008000547a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000547a:	1141                	addi	sp,sp,-16
    8000547c:	e422                	sd	s0,8(sp)
    8000547e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80005480:	411c                	lw	a5,0(a0)
    80005482:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80005484:	415c                	lw	a5,4(a0)
    80005486:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80005488:	04451783          	lh	a5,68(a0)
    8000548c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80005490:	04a51783          	lh	a5,74(a0)
    80005494:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80005498:	04c56783          	lwu	a5,76(a0)
    8000549c:	e99c                	sd	a5,16(a1)
}
    8000549e:	6422                	ld	s0,8(sp)
    800054a0:	0141                	addi	sp,sp,16
    800054a2:	8082                	ret

00000000800054a4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800054a4:	457c                	lw	a5,76(a0)
    800054a6:	0ed7e963          	bltu	a5,a3,80005598 <readi+0xf4>
{
    800054aa:	7159                	addi	sp,sp,-112
    800054ac:	f486                	sd	ra,104(sp)
    800054ae:	f0a2                	sd	s0,96(sp)
    800054b0:	eca6                	sd	s1,88(sp)
    800054b2:	e8ca                	sd	s2,80(sp)
    800054b4:	e4ce                	sd	s3,72(sp)
    800054b6:	e0d2                	sd	s4,64(sp)
    800054b8:	fc56                	sd	s5,56(sp)
    800054ba:	f85a                	sd	s6,48(sp)
    800054bc:	f45e                	sd	s7,40(sp)
    800054be:	f062                	sd	s8,32(sp)
    800054c0:	ec66                	sd	s9,24(sp)
    800054c2:	e86a                	sd	s10,16(sp)
    800054c4:	e46e                	sd	s11,8(sp)
    800054c6:	1880                	addi	s0,sp,112
    800054c8:	8baa                	mv	s7,a0
    800054ca:	8c2e                	mv	s8,a1
    800054cc:	8ab2                	mv	s5,a2
    800054ce:	84b6                	mv	s1,a3
    800054d0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800054d2:	9f35                	addw	a4,a4,a3
    return 0;
    800054d4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800054d6:	0ad76063          	bltu	a4,a3,80005576 <readi+0xd2>
  if(off + n > ip->size)
    800054da:	00e7f463          	bgeu	a5,a4,800054e2 <readi+0x3e>
    n = ip->size - off;
    800054de:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800054e2:	0a0b0963          	beqz	s6,80005594 <readi+0xf0>
    800054e6:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800054e8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800054ec:	5cfd                	li	s9,-1
    800054ee:	a82d                	j	80005528 <readi+0x84>
    800054f0:	020a1d93          	slli	s11,s4,0x20
    800054f4:	020ddd93          	srli	s11,s11,0x20
    800054f8:	05890613          	addi	a2,s2,88
    800054fc:	86ee                	mv	a3,s11
    800054fe:	963a                	add	a2,a2,a4
    80005500:	85d6                	mv	a1,s5
    80005502:	8562                	mv	a0,s8
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	f0c080e7          	jalr	-244(ra) # 80003410 <either_copyout>
    8000550c:	05950d63          	beq	a0,s9,80005566 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80005510:	854a                	mv	a0,s2
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	60c080e7          	jalr	1548(ra) # 80004b1e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000551a:	013a09bb          	addw	s3,s4,s3
    8000551e:	009a04bb          	addw	s1,s4,s1
    80005522:	9aee                	add	s5,s5,s11
    80005524:	0569f763          	bgeu	s3,s6,80005572 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80005528:	000ba903          	lw	s2,0(s7)
    8000552c:	00a4d59b          	srliw	a1,s1,0xa
    80005530:	855e                	mv	a0,s7
    80005532:	00000097          	auipc	ra,0x0
    80005536:	8ac080e7          	jalr	-1876(ra) # 80004dde <bmap>
    8000553a:	0005059b          	sext.w	a1,a0
    8000553e:	854a                	mv	a0,s2
    80005540:	fffff097          	auipc	ra,0xfffff
    80005544:	4ae080e7          	jalr	1198(ra) # 800049ee <bread>
    80005548:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000554a:	3ff4f713          	andi	a4,s1,1023
    8000554e:	40ed07bb          	subw	a5,s10,a4
    80005552:	413b06bb          	subw	a3,s6,s3
    80005556:	8a3e                	mv	s4,a5
    80005558:	2781                	sext.w	a5,a5
    8000555a:	0006861b          	sext.w	a2,a3
    8000555e:	f8f679e3          	bgeu	a2,a5,800054f0 <readi+0x4c>
    80005562:	8a36                	mv	s4,a3
    80005564:	b771                	j	800054f0 <readi+0x4c>
      brelse(bp);
    80005566:	854a                	mv	a0,s2
    80005568:	fffff097          	auipc	ra,0xfffff
    8000556c:	5b6080e7          	jalr	1462(ra) # 80004b1e <brelse>
      tot = -1;
    80005570:	59fd                	li	s3,-1
  }
  return tot;
    80005572:	0009851b          	sext.w	a0,s3
}
    80005576:	70a6                	ld	ra,104(sp)
    80005578:	7406                	ld	s0,96(sp)
    8000557a:	64e6                	ld	s1,88(sp)
    8000557c:	6946                	ld	s2,80(sp)
    8000557e:	69a6                	ld	s3,72(sp)
    80005580:	6a06                	ld	s4,64(sp)
    80005582:	7ae2                	ld	s5,56(sp)
    80005584:	7b42                	ld	s6,48(sp)
    80005586:	7ba2                	ld	s7,40(sp)
    80005588:	7c02                	ld	s8,32(sp)
    8000558a:	6ce2                	ld	s9,24(sp)
    8000558c:	6d42                	ld	s10,16(sp)
    8000558e:	6da2                	ld	s11,8(sp)
    80005590:	6165                	addi	sp,sp,112
    80005592:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005594:	89da                	mv	s3,s6
    80005596:	bff1                	j	80005572 <readi+0xce>
    return 0;
    80005598:	4501                	li	a0,0
}
    8000559a:	8082                	ret

000000008000559c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000559c:	457c                	lw	a5,76(a0)
    8000559e:	10d7e863          	bltu	a5,a3,800056ae <writei+0x112>
{
    800055a2:	7159                	addi	sp,sp,-112
    800055a4:	f486                	sd	ra,104(sp)
    800055a6:	f0a2                	sd	s0,96(sp)
    800055a8:	eca6                	sd	s1,88(sp)
    800055aa:	e8ca                	sd	s2,80(sp)
    800055ac:	e4ce                	sd	s3,72(sp)
    800055ae:	e0d2                	sd	s4,64(sp)
    800055b0:	fc56                	sd	s5,56(sp)
    800055b2:	f85a                	sd	s6,48(sp)
    800055b4:	f45e                	sd	s7,40(sp)
    800055b6:	f062                	sd	s8,32(sp)
    800055b8:	ec66                	sd	s9,24(sp)
    800055ba:	e86a                	sd	s10,16(sp)
    800055bc:	e46e                	sd	s11,8(sp)
    800055be:	1880                	addi	s0,sp,112
    800055c0:	8b2a                	mv	s6,a0
    800055c2:	8c2e                	mv	s8,a1
    800055c4:	8ab2                	mv	s5,a2
    800055c6:	8936                	mv	s2,a3
    800055c8:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800055ca:	00e687bb          	addw	a5,a3,a4
    800055ce:	0ed7e263          	bltu	a5,a3,800056b2 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800055d2:	00043737          	lui	a4,0x43
    800055d6:	0ef76063          	bltu	a4,a5,800056b6 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800055da:	0c0b8863          	beqz	s7,800056aa <writei+0x10e>
    800055de:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800055e0:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800055e4:	5cfd                	li	s9,-1
    800055e6:	a091                	j	8000562a <writei+0x8e>
    800055e8:	02099d93          	slli	s11,s3,0x20
    800055ec:	020ddd93          	srli	s11,s11,0x20
    800055f0:	05848513          	addi	a0,s1,88
    800055f4:	86ee                	mv	a3,s11
    800055f6:	8656                	mv	a2,s5
    800055f8:	85e2                	mv	a1,s8
    800055fa:	953a                	add	a0,a0,a4
    800055fc:	ffffe097          	auipc	ra,0xffffe
    80005600:	e6a080e7          	jalr	-406(ra) # 80003466 <either_copyin>
    80005604:	07950263          	beq	a0,s9,80005668 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80005608:	8526                	mv	a0,s1
    8000560a:	00000097          	auipc	ra,0x0
    8000560e:	798080e7          	jalr	1944(ra) # 80005da2 <log_write>
    brelse(bp);
    80005612:	8526                	mv	a0,s1
    80005614:	fffff097          	auipc	ra,0xfffff
    80005618:	50a080e7          	jalr	1290(ra) # 80004b1e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000561c:	01498a3b          	addw	s4,s3,s4
    80005620:	0129893b          	addw	s2,s3,s2
    80005624:	9aee                	add	s5,s5,s11
    80005626:	057a7663          	bgeu	s4,s7,80005672 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000562a:	000b2483          	lw	s1,0(s6)
    8000562e:	00a9559b          	srliw	a1,s2,0xa
    80005632:	855a                	mv	a0,s6
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	7aa080e7          	jalr	1962(ra) # 80004dde <bmap>
    8000563c:	0005059b          	sext.w	a1,a0
    80005640:	8526                	mv	a0,s1
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	3ac080e7          	jalr	940(ra) # 800049ee <bread>
    8000564a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000564c:	3ff97713          	andi	a4,s2,1023
    80005650:	40ed07bb          	subw	a5,s10,a4
    80005654:	414b86bb          	subw	a3,s7,s4
    80005658:	89be                	mv	s3,a5
    8000565a:	2781                	sext.w	a5,a5
    8000565c:	0006861b          	sext.w	a2,a3
    80005660:	f8f674e3          	bgeu	a2,a5,800055e8 <writei+0x4c>
    80005664:	89b6                	mv	s3,a3
    80005666:	b749                	j	800055e8 <writei+0x4c>
      brelse(bp);
    80005668:	8526                	mv	a0,s1
    8000566a:	fffff097          	auipc	ra,0xfffff
    8000566e:	4b4080e7          	jalr	1204(ra) # 80004b1e <brelse>
  }

  if(off > ip->size)
    80005672:	04cb2783          	lw	a5,76(s6)
    80005676:	0127f463          	bgeu	a5,s2,8000567e <writei+0xe2>
    ip->size = off;
    8000567a:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000567e:	855a                	mv	a0,s6
    80005680:	00000097          	auipc	ra,0x0
    80005684:	aa4080e7          	jalr	-1372(ra) # 80005124 <iupdate>

  return tot;
    80005688:	000a051b          	sext.w	a0,s4
}
    8000568c:	70a6                	ld	ra,104(sp)
    8000568e:	7406                	ld	s0,96(sp)
    80005690:	64e6                	ld	s1,88(sp)
    80005692:	6946                	ld	s2,80(sp)
    80005694:	69a6                	ld	s3,72(sp)
    80005696:	6a06                	ld	s4,64(sp)
    80005698:	7ae2                	ld	s5,56(sp)
    8000569a:	7b42                	ld	s6,48(sp)
    8000569c:	7ba2                	ld	s7,40(sp)
    8000569e:	7c02                	ld	s8,32(sp)
    800056a0:	6ce2                	ld	s9,24(sp)
    800056a2:	6d42                	ld	s10,16(sp)
    800056a4:	6da2                	ld	s11,8(sp)
    800056a6:	6165                	addi	sp,sp,112
    800056a8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800056aa:	8a5e                	mv	s4,s7
    800056ac:	bfc9                	j	8000567e <writei+0xe2>
    return -1;
    800056ae:	557d                	li	a0,-1
}
    800056b0:	8082                	ret
    return -1;
    800056b2:	557d                	li	a0,-1
    800056b4:	bfe1                	j	8000568c <writei+0xf0>
    return -1;
    800056b6:	557d                	li	a0,-1
    800056b8:	bfd1                	j	8000568c <writei+0xf0>

00000000800056ba <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800056ba:	1141                	addi	sp,sp,-16
    800056bc:	e406                	sd	ra,8(sp)
    800056be:	e022                	sd	s0,0(sp)
    800056c0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800056c2:	4639                	li	a2,14
    800056c4:	ffffb097          	auipc	ra,0xffffb
    800056c8:	6d6080e7          	jalr	1750(ra) # 80000d9a <strncmp>
}
    800056cc:	60a2                	ld	ra,8(sp)
    800056ce:	6402                	ld	s0,0(sp)
    800056d0:	0141                	addi	sp,sp,16
    800056d2:	8082                	ret

00000000800056d4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800056d4:	7139                	addi	sp,sp,-64
    800056d6:	fc06                	sd	ra,56(sp)
    800056d8:	f822                	sd	s0,48(sp)
    800056da:	f426                	sd	s1,40(sp)
    800056dc:	f04a                	sd	s2,32(sp)
    800056de:	ec4e                	sd	s3,24(sp)
    800056e0:	e852                	sd	s4,16(sp)
    800056e2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800056e4:	04451703          	lh	a4,68(a0)
    800056e8:	4785                	li	a5,1
    800056ea:	00f71a63          	bne	a4,a5,800056fe <dirlookup+0x2a>
    800056ee:	892a                	mv	s2,a0
    800056f0:	89ae                	mv	s3,a1
    800056f2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800056f4:	457c                	lw	a5,76(a0)
    800056f6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800056f8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800056fa:	e79d                	bnez	a5,80005728 <dirlookup+0x54>
    800056fc:	a8a5                	j	80005774 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800056fe:	00004517          	auipc	a0,0x4
    80005702:	27a50513          	addi	a0,a0,634 # 80009978 <syscalls+0x318>
    80005706:	ffffb097          	auipc	ra,0xffffb
    8000570a:	e32080e7          	jalr	-462(ra) # 80000538 <panic>
      panic("dirlookup read");
    8000570e:	00004517          	auipc	a0,0x4
    80005712:	28250513          	addi	a0,a0,642 # 80009990 <syscalls+0x330>
    80005716:	ffffb097          	auipc	ra,0xffffb
    8000571a:	e22080e7          	jalr	-478(ra) # 80000538 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000571e:	24c1                	addiw	s1,s1,16
    80005720:	04c92783          	lw	a5,76(s2)
    80005724:	04f4f763          	bgeu	s1,a5,80005772 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005728:	4741                	li	a4,16
    8000572a:	86a6                	mv	a3,s1
    8000572c:	fc040613          	addi	a2,s0,-64
    80005730:	4581                	li	a1,0
    80005732:	854a                	mv	a0,s2
    80005734:	00000097          	auipc	ra,0x0
    80005738:	d70080e7          	jalr	-656(ra) # 800054a4 <readi>
    8000573c:	47c1                	li	a5,16
    8000573e:	fcf518e3          	bne	a0,a5,8000570e <dirlookup+0x3a>
    if(de.inum == 0)
    80005742:	fc045783          	lhu	a5,-64(s0)
    80005746:	dfe1                	beqz	a5,8000571e <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80005748:	fc240593          	addi	a1,s0,-62
    8000574c:	854e                	mv	a0,s3
    8000574e:	00000097          	auipc	ra,0x0
    80005752:	f6c080e7          	jalr	-148(ra) # 800056ba <namecmp>
    80005756:	f561                	bnez	a0,8000571e <dirlookup+0x4a>
      if(poff)
    80005758:	000a0463          	beqz	s4,80005760 <dirlookup+0x8c>
        *poff = off;
    8000575c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80005760:	fc045583          	lhu	a1,-64(s0)
    80005764:	00092503          	lw	a0,0(s2)
    80005768:	fffff097          	auipc	ra,0xfffff
    8000576c:	752080e7          	jalr	1874(ra) # 80004eba <iget>
    80005770:	a011                	j	80005774 <dirlookup+0xa0>
  return 0;
    80005772:	4501                	li	a0,0
}
    80005774:	70e2                	ld	ra,56(sp)
    80005776:	7442                	ld	s0,48(sp)
    80005778:	74a2                	ld	s1,40(sp)
    8000577a:	7902                	ld	s2,32(sp)
    8000577c:	69e2                	ld	s3,24(sp)
    8000577e:	6a42                	ld	s4,16(sp)
    80005780:	6121                	addi	sp,sp,64
    80005782:	8082                	ret

0000000080005784 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80005784:	711d                	addi	sp,sp,-96
    80005786:	ec86                	sd	ra,88(sp)
    80005788:	e8a2                	sd	s0,80(sp)
    8000578a:	e4a6                	sd	s1,72(sp)
    8000578c:	e0ca                	sd	s2,64(sp)
    8000578e:	fc4e                	sd	s3,56(sp)
    80005790:	f852                	sd	s4,48(sp)
    80005792:	f456                	sd	s5,40(sp)
    80005794:	f05a                	sd	s6,32(sp)
    80005796:	ec5e                	sd	s7,24(sp)
    80005798:	e862                	sd	s8,16(sp)
    8000579a:	e466                	sd	s9,8(sp)
    8000579c:	e06a                	sd	s10,0(sp)
    8000579e:	1080                	addi	s0,sp,96
    800057a0:	84aa                	mv	s1,a0
    800057a2:	8b2e                	mv	s6,a1
    800057a4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800057a6:	00054703          	lbu	a4,0(a0)
    800057aa:	02f00793          	li	a5,47
    800057ae:	02f70363          	beq	a4,a5,800057d4 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800057b2:	ffffc097          	auipc	ra,0xffffc
    800057b6:	23e080e7          	jalr	574(ra) # 800019f0 <myproc>
    800057ba:	15853503          	ld	a0,344(a0)
    800057be:	00000097          	auipc	ra,0x0
    800057c2:	9f4080e7          	jalr	-1548(ra) # 800051b2 <idup>
    800057c6:	8a2a                	mv	s4,a0
  while(*path == '/')
    800057c8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800057cc:	4cb5                	li	s9,13
  len = path - s;
    800057ce:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800057d0:	4c05                	li	s8,1
    800057d2:	a87d                	j	80005890 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800057d4:	4585                	li	a1,1
    800057d6:	4505                	li	a0,1
    800057d8:	fffff097          	auipc	ra,0xfffff
    800057dc:	6e2080e7          	jalr	1762(ra) # 80004eba <iget>
    800057e0:	8a2a                	mv	s4,a0
    800057e2:	b7dd                	j	800057c8 <namex+0x44>
      iunlockput(ip);
    800057e4:	8552                	mv	a0,s4
    800057e6:	00000097          	auipc	ra,0x0
    800057ea:	c6c080e7          	jalr	-916(ra) # 80005452 <iunlockput>
      return 0;
    800057ee:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800057f0:	8552                	mv	a0,s4
    800057f2:	60e6                	ld	ra,88(sp)
    800057f4:	6446                	ld	s0,80(sp)
    800057f6:	64a6                	ld	s1,72(sp)
    800057f8:	6906                	ld	s2,64(sp)
    800057fa:	79e2                	ld	s3,56(sp)
    800057fc:	7a42                	ld	s4,48(sp)
    800057fe:	7aa2                	ld	s5,40(sp)
    80005800:	7b02                	ld	s6,32(sp)
    80005802:	6be2                	ld	s7,24(sp)
    80005804:	6c42                	ld	s8,16(sp)
    80005806:	6ca2                	ld	s9,8(sp)
    80005808:	6d02                	ld	s10,0(sp)
    8000580a:	6125                	addi	sp,sp,96
    8000580c:	8082                	ret
      iunlock(ip);
    8000580e:	8552                	mv	a0,s4
    80005810:	00000097          	auipc	ra,0x0
    80005814:	aa2080e7          	jalr	-1374(ra) # 800052b2 <iunlock>
      return ip;
    80005818:	bfe1                	j	800057f0 <namex+0x6c>
      iunlockput(ip);
    8000581a:	8552                	mv	a0,s4
    8000581c:	00000097          	auipc	ra,0x0
    80005820:	c36080e7          	jalr	-970(ra) # 80005452 <iunlockput>
      return 0;
    80005824:	8a4e                	mv	s4,s3
    80005826:	b7e9                	j	800057f0 <namex+0x6c>
  len = path - s;
    80005828:	40998633          	sub	a2,s3,s1
    8000582c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80005830:	09acd863          	bge	s9,s10,800058c0 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80005834:	4639                	li	a2,14
    80005836:	85a6                	mv	a1,s1
    80005838:	8556                	mv	a0,s5
    8000583a:	ffffb097          	auipc	ra,0xffffb
    8000583e:	4ec080e7          	jalr	1260(ra) # 80000d26 <memmove>
    80005842:	84ce                	mv	s1,s3
  while(*path == '/')
    80005844:	0004c783          	lbu	a5,0(s1)
    80005848:	01279763          	bne	a5,s2,80005856 <namex+0xd2>
    path++;
    8000584c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000584e:	0004c783          	lbu	a5,0(s1)
    80005852:	ff278de3          	beq	a5,s2,8000584c <namex+0xc8>
    ilock(ip);
    80005856:	8552                	mv	a0,s4
    80005858:	00000097          	auipc	ra,0x0
    8000585c:	998080e7          	jalr	-1640(ra) # 800051f0 <ilock>
    if(ip->type != T_DIR){
    80005860:	044a1783          	lh	a5,68(s4)
    80005864:	f98790e3          	bne	a5,s8,800057e4 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80005868:	000b0563          	beqz	s6,80005872 <namex+0xee>
    8000586c:	0004c783          	lbu	a5,0(s1)
    80005870:	dfd9                	beqz	a5,8000580e <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80005872:	865e                	mv	a2,s7
    80005874:	85d6                	mv	a1,s5
    80005876:	8552                	mv	a0,s4
    80005878:	00000097          	auipc	ra,0x0
    8000587c:	e5c080e7          	jalr	-420(ra) # 800056d4 <dirlookup>
    80005880:	89aa                	mv	s3,a0
    80005882:	dd41                	beqz	a0,8000581a <namex+0x96>
    iunlockput(ip);
    80005884:	8552                	mv	a0,s4
    80005886:	00000097          	auipc	ra,0x0
    8000588a:	bcc080e7          	jalr	-1076(ra) # 80005452 <iunlockput>
    ip = next;
    8000588e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80005890:	0004c783          	lbu	a5,0(s1)
    80005894:	01279763          	bne	a5,s2,800058a2 <namex+0x11e>
    path++;
    80005898:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000589a:	0004c783          	lbu	a5,0(s1)
    8000589e:	ff278de3          	beq	a5,s2,80005898 <namex+0x114>
  if(*path == 0)
    800058a2:	cb9d                	beqz	a5,800058d8 <namex+0x154>
  while(*path != '/' && *path != 0)
    800058a4:	0004c783          	lbu	a5,0(s1)
    800058a8:	89a6                	mv	s3,s1
  len = path - s;
    800058aa:	8d5e                	mv	s10,s7
    800058ac:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800058ae:	01278963          	beq	a5,s2,800058c0 <namex+0x13c>
    800058b2:	dbbd                	beqz	a5,80005828 <namex+0xa4>
    path++;
    800058b4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800058b6:	0009c783          	lbu	a5,0(s3)
    800058ba:	ff279ce3          	bne	a5,s2,800058b2 <namex+0x12e>
    800058be:	b7ad                	j	80005828 <namex+0xa4>
    memmove(name, s, len);
    800058c0:	2601                	sext.w	a2,a2
    800058c2:	85a6                	mv	a1,s1
    800058c4:	8556                	mv	a0,s5
    800058c6:	ffffb097          	auipc	ra,0xffffb
    800058ca:	460080e7          	jalr	1120(ra) # 80000d26 <memmove>
    name[len] = 0;
    800058ce:	9d56                	add	s10,s10,s5
    800058d0:	000d0023          	sb	zero,0(s10)
    800058d4:	84ce                	mv	s1,s3
    800058d6:	b7bd                	j	80005844 <namex+0xc0>
  if(nameiparent){
    800058d8:	f00b0ce3          	beqz	s6,800057f0 <namex+0x6c>
    iput(ip);
    800058dc:	8552                	mv	a0,s4
    800058de:	00000097          	auipc	ra,0x0
    800058e2:	acc080e7          	jalr	-1332(ra) # 800053aa <iput>
    return 0;
    800058e6:	4a01                	li	s4,0
    800058e8:	b721                	j	800057f0 <namex+0x6c>

00000000800058ea <dirlink>:
{
    800058ea:	7139                	addi	sp,sp,-64
    800058ec:	fc06                	sd	ra,56(sp)
    800058ee:	f822                	sd	s0,48(sp)
    800058f0:	f426                	sd	s1,40(sp)
    800058f2:	f04a                	sd	s2,32(sp)
    800058f4:	ec4e                	sd	s3,24(sp)
    800058f6:	e852                	sd	s4,16(sp)
    800058f8:	0080                	addi	s0,sp,64
    800058fa:	892a                	mv	s2,a0
    800058fc:	8a2e                	mv	s4,a1
    800058fe:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80005900:	4601                	li	a2,0
    80005902:	00000097          	auipc	ra,0x0
    80005906:	dd2080e7          	jalr	-558(ra) # 800056d4 <dirlookup>
    8000590a:	e93d                	bnez	a0,80005980 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000590c:	04c92483          	lw	s1,76(s2)
    80005910:	c49d                	beqz	s1,8000593e <dirlink+0x54>
    80005912:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005914:	4741                	li	a4,16
    80005916:	86a6                	mv	a3,s1
    80005918:	fc040613          	addi	a2,s0,-64
    8000591c:	4581                	li	a1,0
    8000591e:	854a                	mv	a0,s2
    80005920:	00000097          	auipc	ra,0x0
    80005924:	b84080e7          	jalr	-1148(ra) # 800054a4 <readi>
    80005928:	47c1                	li	a5,16
    8000592a:	06f51163          	bne	a0,a5,8000598c <dirlink+0xa2>
    if(de.inum == 0)
    8000592e:	fc045783          	lhu	a5,-64(s0)
    80005932:	c791                	beqz	a5,8000593e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005934:	24c1                	addiw	s1,s1,16
    80005936:	04c92783          	lw	a5,76(s2)
    8000593a:	fcf4ede3          	bltu	s1,a5,80005914 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000593e:	4639                	li	a2,14
    80005940:	85d2                	mv	a1,s4
    80005942:	fc240513          	addi	a0,s0,-62
    80005946:	ffffb097          	auipc	ra,0xffffb
    8000594a:	490080e7          	jalr	1168(ra) # 80000dd6 <strncpy>
  de.inum = inum;
    8000594e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005952:	4741                	li	a4,16
    80005954:	86a6                	mv	a3,s1
    80005956:	fc040613          	addi	a2,s0,-64
    8000595a:	4581                	li	a1,0
    8000595c:	854a                	mv	a0,s2
    8000595e:	00000097          	auipc	ra,0x0
    80005962:	c3e080e7          	jalr	-962(ra) # 8000559c <writei>
    80005966:	872a                	mv	a4,a0
    80005968:	47c1                	li	a5,16
  return 0;
    8000596a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000596c:	02f71863          	bne	a4,a5,8000599c <dirlink+0xb2>
}
    80005970:	70e2                	ld	ra,56(sp)
    80005972:	7442                	ld	s0,48(sp)
    80005974:	74a2                	ld	s1,40(sp)
    80005976:	7902                	ld	s2,32(sp)
    80005978:	69e2                	ld	s3,24(sp)
    8000597a:	6a42                	ld	s4,16(sp)
    8000597c:	6121                	addi	sp,sp,64
    8000597e:	8082                	ret
    iput(ip);
    80005980:	00000097          	auipc	ra,0x0
    80005984:	a2a080e7          	jalr	-1494(ra) # 800053aa <iput>
    return -1;
    80005988:	557d                	li	a0,-1
    8000598a:	b7dd                	j	80005970 <dirlink+0x86>
      panic("dirlink read");
    8000598c:	00004517          	auipc	a0,0x4
    80005990:	01450513          	addi	a0,a0,20 # 800099a0 <syscalls+0x340>
    80005994:	ffffb097          	auipc	ra,0xffffb
    80005998:	ba4080e7          	jalr	-1116(ra) # 80000538 <panic>
    panic("dirlink");
    8000599c:	00004517          	auipc	a0,0x4
    800059a0:	11450513          	addi	a0,a0,276 # 80009ab0 <syscalls+0x450>
    800059a4:	ffffb097          	auipc	ra,0xffffb
    800059a8:	b94080e7          	jalr	-1132(ra) # 80000538 <panic>

00000000800059ac <namei>:

struct inode*
namei(char *path)
{
    800059ac:	1101                	addi	sp,sp,-32
    800059ae:	ec06                	sd	ra,24(sp)
    800059b0:	e822                	sd	s0,16(sp)
    800059b2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800059b4:	fe040613          	addi	a2,s0,-32
    800059b8:	4581                	li	a1,0
    800059ba:	00000097          	auipc	ra,0x0
    800059be:	dca080e7          	jalr	-566(ra) # 80005784 <namex>
}
    800059c2:	60e2                	ld	ra,24(sp)
    800059c4:	6442                	ld	s0,16(sp)
    800059c6:	6105                	addi	sp,sp,32
    800059c8:	8082                	ret

00000000800059ca <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800059ca:	1141                	addi	sp,sp,-16
    800059cc:	e406                	sd	ra,8(sp)
    800059ce:	e022                	sd	s0,0(sp)
    800059d0:	0800                	addi	s0,sp,16
    800059d2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800059d4:	4585                	li	a1,1
    800059d6:	00000097          	auipc	ra,0x0
    800059da:	dae080e7          	jalr	-594(ra) # 80005784 <namex>
}
    800059de:	60a2                	ld	ra,8(sp)
    800059e0:	6402                	ld	s0,0(sp)
    800059e2:	0141                	addi	sp,sp,16
    800059e4:	8082                	ret

00000000800059e6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800059e6:	1101                	addi	sp,sp,-32
    800059e8:	ec06                	sd	ra,24(sp)
    800059ea:	e822                	sd	s0,16(sp)
    800059ec:	e426                	sd	s1,8(sp)
    800059ee:	e04a                	sd	s2,0(sp)
    800059f0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800059f2:	0001e917          	auipc	s2,0x1e
    800059f6:	52e90913          	addi	s2,s2,1326 # 80023f20 <log>
    800059fa:	01892583          	lw	a1,24(s2)
    800059fe:	02892503          	lw	a0,40(s2)
    80005a02:	fffff097          	auipc	ra,0xfffff
    80005a06:	fec080e7          	jalr	-20(ra) # 800049ee <bread>
    80005a0a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005a0c:	02c92683          	lw	a3,44(s2)
    80005a10:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80005a12:	02d05863          	blez	a3,80005a42 <write_head+0x5c>
    80005a16:	0001e797          	auipc	a5,0x1e
    80005a1a:	53a78793          	addi	a5,a5,1338 # 80023f50 <log+0x30>
    80005a1e:	05c50713          	addi	a4,a0,92
    80005a22:	36fd                	addiw	a3,a3,-1
    80005a24:	02069613          	slli	a2,a3,0x20
    80005a28:	01e65693          	srli	a3,a2,0x1e
    80005a2c:	0001e617          	auipc	a2,0x1e
    80005a30:	52860613          	addi	a2,a2,1320 # 80023f54 <log+0x34>
    80005a34:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80005a36:	4390                	lw	a2,0(a5)
    80005a38:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005a3a:	0791                	addi	a5,a5,4
    80005a3c:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80005a3e:	fed79ce3          	bne	a5,a3,80005a36 <write_head+0x50>
  }
  bwrite(buf);
    80005a42:	8526                	mv	a0,s1
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	09c080e7          	jalr	156(ra) # 80004ae0 <bwrite>
  brelse(buf);
    80005a4c:	8526                	mv	a0,s1
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	0d0080e7          	jalr	208(ra) # 80004b1e <brelse>
}
    80005a56:	60e2                	ld	ra,24(sp)
    80005a58:	6442                	ld	s0,16(sp)
    80005a5a:	64a2                	ld	s1,8(sp)
    80005a5c:	6902                	ld	s2,0(sp)
    80005a5e:	6105                	addi	sp,sp,32
    80005a60:	8082                	ret

0000000080005a62 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005a62:	0001e797          	auipc	a5,0x1e
    80005a66:	4ea7a783          	lw	a5,1258(a5) # 80023f4c <log+0x2c>
    80005a6a:	0af05d63          	blez	a5,80005b24 <install_trans+0xc2>
{
    80005a6e:	7139                	addi	sp,sp,-64
    80005a70:	fc06                	sd	ra,56(sp)
    80005a72:	f822                	sd	s0,48(sp)
    80005a74:	f426                	sd	s1,40(sp)
    80005a76:	f04a                	sd	s2,32(sp)
    80005a78:	ec4e                	sd	s3,24(sp)
    80005a7a:	e852                	sd	s4,16(sp)
    80005a7c:	e456                	sd	s5,8(sp)
    80005a7e:	e05a                	sd	s6,0(sp)
    80005a80:	0080                	addi	s0,sp,64
    80005a82:	8b2a                	mv	s6,a0
    80005a84:	0001ea97          	auipc	s5,0x1e
    80005a88:	4cca8a93          	addi	s5,s5,1228 # 80023f50 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005a8c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005a8e:	0001e997          	auipc	s3,0x1e
    80005a92:	49298993          	addi	s3,s3,1170 # 80023f20 <log>
    80005a96:	a00d                	j	80005ab8 <install_trans+0x56>
    brelse(lbuf);
    80005a98:	854a                	mv	a0,s2
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	084080e7          	jalr	132(ra) # 80004b1e <brelse>
    brelse(dbuf);
    80005aa2:	8526                	mv	a0,s1
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	07a080e7          	jalr	122(ra) # 80004b1e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005aac:	2a05                	addiw	s4,s4,1
    80005aae:	0a91                	addi	s5,s5,4
    80005ab0:	02c9a783          	lw	a5,44(s3)
    80005ab4:	04fa5e63          	bge	s4,a5,80005b10 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005ab8:	0189a583          	lw	a1,24(s3)
    80005abc:	014585bb          	addw	a1,a1,s4
    80005ac0:	2585                	addiw	a1,a1,1
    80005ac2:	0289a503          	lw	a0,40(s3)
    80005ac6:	fffff097          	auipc	ra,0xfffff
    80005aca:	f28080e7          	jalr	-216(ra) # 800049ee <bread>
    80005ace:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80005ad0:	000aa583          	lw	a1,0(s5)
    80005ad4:	0289a503          	lw	a0,40(s3)
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	f16080e7          	jalr	-234(ra) # 800049ee <bread>
    80005ae0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005ae2:	40000613          	li	a2,1024
    80005ae6:	05890593          	addi	a1,s2,88
    80005aea:	05850513          	addi	a0,a0,88
    80005aee:	ffffb097          	auipc	ra,0xffffb
    80005af2:	238080e7          	jalr	568(ra) # 80000d26 <memmove>
    bwrite(dbuf);  // write dst to disk
    80005af6:	8526                	mv	a0,s1
    80005af8:	fffff097          	auipc	ra,0xfffff
    80005afc:	fe8080e7          	jalr	-24(ra) # 80004ae0 <bwrite>
    if(recovering == 0)
    80005b00:	f80b1ce3          	bnez	s6,80005a98 <install_trans+0x36>
      bunpin(dbuf);
    80005b04:	8526                	mv	a0,s1
    80005b06:	fffff097          	auipc	ra,0xfffff
    80005b0a:	0f2080e7          	jalr	242(ra) # 80004bf8 <bunpin>
    80005b0e:	b769                	j	80005a98 <install_trans+0x36>
}
    80005b10:	70e2                	ld	ra,56(sp)
    80005b12:	7442                	ld	s0,48(sp)
    80005b14:	74a2                	ld	s1,40(sp)
    80005b16:	7902                	ld	s2,32(sp)
    80005b18:	69e2                	ld	s3,24(sp)
    80005b1a:	6a42                	ld	s4,16(sp)
    80005b1c:	6aa2                	ld	s5,8(sp)
    80005b1e:	6b02                	ld	s6,0(sp)
    80005b20:	6121                	addi	sp,sp,64
    80005b22:	8082                	ret
    80005b24:	8082                	ret

0000000080005b26 <initlog>:
{
    80005b26:	7179                	addi	sp,sp,-48
    80005b28:	f406                	sd	ra,40(sp)
    80005b2a:	f022                	sd	s0,32(sp)
    80005b2c:	ec26                	sd	s1,24(sp)
    80005b2e:	e84a                	sd	s2,16(sp)
    80005b30:	e44e                	sd	s3,8(sp)
    80005b32:	1800                	addi	s0,sp,48
    80005b34:	892a                	mv	s2,a0
    80005b36:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005b38:	0001e497          	auipc	s1,0x1e
    80005b3c:	3e848493          	addi	s1,s1,1000 # 80023f20 <log>
    80005b40:	00004597          	auipc	a1,0x4
    80005b44:	e7058593          	addi	a1,a1,-400 # 800099b0 <syscalls+0x350>
    80005b48:	8526                	mv	a0,s1
    80005b4a:	ffffb097          	auipc	ra,0xffffb
    80005b4e:	ff4080e7          	jalr	-12(ra) # 80000b3e <initlock>
  log.start = sb->logstart;
    80005b52:	0149a583          	lw	a1,20(s3)
    80005b56:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80005b58:	0109a783          	lw	a5,16(s3)
    80005b5c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80005b5e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005b62:	854a                	mv	a0,s2
    80005b64:	fffff097          	auipc	ra,0xfffff
    80005b68:	e8a080e7          	jalr	-374(ra) # 800049ee <bread>
  log.lh.n = lh->n;
    80005b6c:	4d34                	lw	a3,88(a0)
    80005b6e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80005b70:	02d05663          	blez	a3,80005b9c <initlog+0x76>
    80005b74:	05c50793          	addi	a5,a0,92
    80005b78:	0001e717          	auipc	a4,0x1e
    80005b7c:	3d870713          	addi	a4,a4,984 # 80023f50 <log+0x30>
    80005b80:	36fd                	addiw	a3,a3,-1
    80005b82:	02069613          	slli	a2,a3,0x20
    80005b86:	01e65693          	srli	a3,a2,0x1e
    80005b8a:	06050613          	addi	a2,a0,96
    80005b8e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80005b90:	4390                	lw	a2,0(a5)
    80005b92:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005b94:	0791                	addi	a5,a5,4
    80005b96:	0711                	addi	a4,a4,4
    80005b98:	fed79ce3          	bne	a5,a3,80005b90 <initlog+0x6a>
  brelse(buf);
    80005b9c:	fffff097          	auipc	ra,0xfffff
    80005ba0:	f82080e7          	jalr	-126(ra) # 80004b1e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005ba4:	4505                	li	a0,1
    80005ba6:	00000097          	auipc	ra,0x0
    80005baa:	ebc080e7          	jalr	-324(ra) # 80005a62 <install_trans>
  log.lh.n = 0;
    80005bae:	0001e797          	auipc	a5,0x1e
    80005bb2:	3807af23          	sw	zero,926(a5) # 80023f4c <log+0x2c>
  write_head(); // clear the log
    80005bb6:	00000097          	auipc	ra,0x0
    80005bba:	e30080e7          	jalr	-464(ra) # 800059e6 <write_head>
}
    80005bbe:	70a2                	ld	ra,40(sp)
    80005bc0:	7402                	ld	s0,32(sp)
    80005bc2:	64e2                	ld	s1,24(sp)
    80005bc4:	6942                	ld	s2,16(sp)
    80005bc6:	69a2                	ld	s3,8(sp)
    80005bc8:	6145                	addi	sp,sp,48
    80005bca:	8082                	ret

0000000080005bcc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005bcc:	1101                	addi	sp,sp,-32
    80005bce:	ec06                	sd	ra,24(sp)
    80005bd0:	e822                	sd	s0,16(sp)
    80005bd2:	e426                	sd	s1,8(sp)
    80005bd4:	e04a                	sd	s2,0(sp)
    80005bd6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005bd8:	0001e517          	auipc	a0,0x1e
    80005bdc:	34850513          	addi	a0,a0,840 # 80023f20 <log>
    80005be0:	ffffb097          	auipc	ra,0xffffb
    80005be4:	fee080e7          	jalr	-18(ra) # 80000bce <acquire>
  while(1){
    if(log.committing){
    80005be8:	0001e497          	auipc	s1,0x1e
    80005bec:	33848493          	addi	s1,s1,824 # 80023f20 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005bf0:	4979                	li	s2,30
    80005bf2:	a039                	j	80005c00 <begin_op+0x34>
      sleep(&log, &log.lock);
    80005bf4:	85a6                	mv	a1,s1
    80005bf6:	8526                	mv	a0,s1
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	baa080e7          	jalr	-1110(ra) # 800027a2 <sleep>
    if(log.committing){
    80005c00:	50dc                	lw	a5,36(s1)
    80005c02:	fbed                	bnez	a5,80005bf4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005c04:	5098                	lw	a4,32(s1)
    80005c06:	2705                	addiw	a4,a4,1
    80005c08:	0007069b          	sext.w	a3,a4
    80005c0c:	0027179b          	slliw	a5,a4,0x2
    80005c10:	9fb9                	addw	a5,a5,a4
    80005c12:	0017979b          	slliw	a5,a5,0x1
    80005c16:	54d8                	lw	a4,44(s1)
    80005c18:	9fb9                	addw	a5,a5,a4
    80005c1a:	00f95963          	bge	s2,a5,80005c2c <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005c1e:	85a6                	mv	a1,s1
    80005c20:	8526                	mv	a0,s1
    80005c22:	ffffd097          	auipc	ra,0xffffd
    80005c26:	b80080e7          	jalr	-1152(ra) # 800027a2 <sleep>
    80005c2a:	bfd9                	j	80005c00 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80005c2c:	0001e517          	auipc	a0,0x1e
    80005c30:	2f450513          	addi	a0,a0,756 # 80023f20 <log>
    80005c34:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005c36:	ffffb097          	auipc	ra,0xffffb
    80005c3a:	04c080e7          	jalr	76(ra) # 80000c82 <release>
      break;
    }
  }
}
    80005c3e:	60e2                	ld	ra,24(sp)
    80005c40:	6442                	ld	s0,16(sp)
    80005c42:	64a2                	ld	s1,8(sp)
    80005c44:	6902                	ld	s2,0(sp)
    80005c46:	6105                	addi	sp,sp,32
    80005c48:	8082                	ret

0000000080005c4a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005c4a:	7139                	addi	sp,sp,-64
    80005c4c:	fc06                	sd	ra,56(sp)
    80005c4e:	f822                	sd	s0,48(sp)
    80005c50:	f426                	sd	s1,40(sp)
    80005c52:	f04a                	sd	s2,32(sp)
    80005c54:	ec4e                	sd	s3,24(sp)
    80005c56:	e852                	sd	s4,16(sp)
    80005c58:	e456                	sd	s5,8(sp)
    80005c5a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005c5c:	0001e497          	auipc	s1,0x1e
    80005c60:	2c448493          	addi	s1,s1,708 # 80023f20 <log>
    80005c64:	8526                	mv	a0,s1
    80005c66:	ffffb097          	auipc	ra,0xffffb
    80005c6a:	f68080e7          	jalr	-152(ra) # 80000bce <acquire>
  log.outstanding -= 1;
    80005c6e:	509c                	lw	a5,32(s1)
    80005c70:	37fd                	addiw	a5,a5,-1
    80005c72:	0007891b          	sext.w	s2,a5
    80005c76:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80005c78:	50dc                	lw	a5,36(s1)
    80005c7a:	e7b9                	bnez	a5,80005cc8 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80005c7c:	04091e63          	bnez	s2,80005cd8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80005c80:	0001e497          	auipc	s1,0x1e
    80005c84:	2a048493          	addi	s1,s1,672 # 80023f20 <log>
    80005c88:	4785                	li	a5,1
    80005c8a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80005c8c:	8526                	mv	a0,s1
    80005c8e:	ffffb097          	auipc	ra,0xffffb
    80005c92:	ff4080e7          	jalr	-12(ra) # 80000c82 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005c96:	54dc                	lw	a5,44(s1)
    80005c98:	06f04763          	bgtz	a5,80005d06 <end_op+0xbc>
    acquire(&log.lock);
    80005c9c:	0001e497          	auipc	s1,0x1e
    80005ca0:	28448493          	addi	s1,s1,644 # 80023f20 <log>
    80005ca4:	8526                	mv	a0,s1
    80005ca6:	ffffb097          	auipc	ra,0xffffb
    80005caa:	f28080e7          	jalr	-216(ra) # 80000bce <acquire>
    log.committing = 0;
    80005cae:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80005cb2:	8526                	mv	a0,s1
    80005cb4:	ffffd097          	auipc	ra,0xffffd
    80005cb8:	0a0080e7          	jalr	160(ra) # 80002d54 <wakeup>
    release(&log.lock);
    80005cbc:	8526                	mv	a0,s1
    80005cbe:	ffffb097          	auipc	ra,0xffffb
    80005cc2:	fc4080e7          	jalr	-60(ra) # 80000c82 <release>
}
    80005cc6:	a03d                	j	80005cf4 <end_op+0xaa>
    panic("log.committing");
    80005cc8:	00004517          	auipc	a0,0x4
    80005ccc:	cf050513          	addi	a0,a0,-784 # 800099b8 <syscalls+0x358>
    80005cd0:	ffffb097          	auipc	ra,0xffffb
    80005cd4:	868080e7          	jalr	-1944(ra) # 80000538 <panic>
    wakeup(&log);
    80005cd8:	0001e497          	auipc	s1,0x1e
    80005cdc:	24848493          	addi	s1,s1,584 # 80023f20 <log>
    80005ce0:	8526                	mv	a0,s1
    80005ce2:	ffffd097          	auipc	ra,0xffffd
    80005ce6:	072080e7          	jalr	114(ra) # 80002d54 <wakeup>
  release(&log.lock);
    80005cea:	8526                	mv	a0,s1
    80005cec:	ffffb097          	auipc	ra,0xffffb
    80005cf0:	f96080e7          	jalr	-106(ra) # 80000c82 <release>
}
    80005cf4:	70e2                	ld	ra,56(sp)
    80005cf6:	7442                	ld	s0,48(sp)
    80005cf8:	74a2                	ld	s1,40(sp)
    80005cfa:	7902                	ld	s2,32(sp)
    80005cfc:	69e2                	ld	s3,24(sp)
    80005cfe:	6a42                	ld	s4,16(sp)
    80005d00:	6aa2                	ld	s5,8(sp)
    80005d02:	6121                	addi	sp,sp,64
    80005d04:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005d06:	0001ea97          	auipc	s5,0x1e
    80005d0a:	24aa8a93          	addi	s5,s5,586 # 80023f50 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005d0e:	0001ea17          	auipc	s4,0x1e
    80005d12:	212a0a13          	addi	s4,s4,530 # 80023f20 <log>
    80005d16:	018a2583          	lw	a1,24(s4)
    80005d1a:	012585bb          	addw	a1,a1,s2
    80005d1e:	2585                	addiw	a1,a1,1
    80005d20:	028a2503          	lw	a0,40(s4)
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	cca080e7          	jalr	-822(ra) # 800049ee <bread>
    80005d2c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005d2e:	000aa583          	lw	a1,0(s5)
    80005d32:	028a2503          	lw	a0,40(s4)
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	cb8080e7          	jalr	-840(ra) # 800049ee <bread>
    80005d3e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005d40:	40000613          	li	a2,1024
    80005d44:	05850593          	addi	a1,a0,88
    80005d48:	05848513          	addi	a0,s1,88
    80005d4c:	ffffb097          	auipc	ra,0xffffb
    80005d50:	fda080e7          	jalr	-38(ra) # 80000d26 <memmove>
    bwrite(to);  // write the log
    80005d54:	8526                	mv	a0,s1
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	d8a080e7          	jalr	-630(ra) # 80004ae0 <bwrite>
    brelse(from);
    80005d5e:	854e                	mv	a0,s3
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	dbe080e7          	jalr	-578(ra) # 80004b1e <brelse>
    brelse(to);
    80005d68:	8526                	mv	a0,s1
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	db4080e7          	jalr	-588(ra) # 80004b1e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005d72:	2905                	addiw	s2,s2,1
    80005d74:	0a91                	addi	s5,s5,4
    80005d76:	02ca2783          	lw	a5,44(s4)
    80005d7a:	f8f94ee3          	blt	s2,a5,80005d16 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80005d7e:	00000097          	auipc	ra,0x0
    80005d82:	c68080e7          	jalr	-920(ra) # 800059e6 <write_head>
    install_trans(0); // Now install writes to home locations
    80005d86:	4501                	li	a0,0
    80005d88:	00000097          	auipc	ra,0x0
    80005d8c:	cda080e7          	jalr	-806(ra) # 80005a62 <install_trans>
    log.lh.n = 0;
    80005d90:	0001e797          	auipc	a5,0x1e
    80005d94:	1a07ae23          	sw	zero,444(a5) # 80023f4c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005d98:	00000097          	auipc	ra,0x0
    80005d9c:	c4e080e7          	jalr	-946(ra) # 800059e6 <write_head>
    80005da0:	bdf5                	j	80005c9c <end_op+0x52>

0000000080005da2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005da2:	1101                	addi	sp,sp,-32
    80005da4:	ec06                	sd	ra,24(sp)
    80005da6:	e822                	sd	s0,16(sp)
    80005da8:	e426                	sd	s1,8(sp)
    80005daa:	e04a                	sd	s2,0(sp)
    80005dac:	1000                	addi	s0,sp,32
    80005dae:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80005db0:	0001e917          	auipc	s2,0x1e
    80005db4:	17090913          	addi	s2,s2,368 # 80023f20 <log>
    80005db8:	854a                	mv	a0,s2
    80005dba:	ffffb097          	auipc	ra,0xffffb
    80005dbe:	e14080e7          	jalr	-492(ra) # 80000bce <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80005dc2:	02c92603          	lw	a2,44(s2)
    80005dc6:	47f5                	li	a5,29
    80005dc8:	06c7c563          	blt	a5,a2,80005e32 <log_write+0x90>
    80005dcc:	0001e797          	auipc	a5,0x1e
    80005dd0:	1707a783          	lw	a5,368(a5) # 80023f3c <log+0x1c>
    80005dd4:	37fd                	addiw	a5,a5,-1
    80005dd6:	04f65e63          	bge	a2,a5,80005e32 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005dda:	0001e797          	auipc	a5,0x1e
    80005dde:	1667a783          	lw	a5,358(a5) # 80023f40 <log+0x20>
    80005de2:	06f05063          	blez	a5,80005e42 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005de6:	4781                	li	a5,0
    80005de8:	06c05563          	blez	a2,80005e52 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005dec:	44cc                	lw	a1,12(s1)
    80005dee:	0001e717          	auipc	a4,0x1e
    80005df2:	16270713          	addi	a4,a4,354 # 80023f50 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005df6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005df8:	4314                	lw	a3,0(a4)
    80005dfa:	04b68c63          	beq	a3,a1,80005e52 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005dfe:	2785                	addiw	a5,a5,1
    80005e00:	0711                	addi	a4,a4,4
    80005e02:	fef61be3          	bne	a2,a5,80005df8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005e06:	0621                	addi	a2,a2,8
    80005e08:	060a                	slli	a2,a2,0x2
    80005e0a:	0001e797          	auipc	a5,0x1e
    80005e0e:	11678793          	addi	a5,a5,278 # 80023f20 <log>
    80005e12:	97b2                	add	a5,a5,a2
    80005e14:	44d8                	lw	a4,12(s1)
    80005e16:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005e18:	8526                	mv	a0,s1
    80005e1a:	fffff097          	auipc	ra,0xfffff
    80005e1e:	da2080e7          	jalr	-606(ra) # 80004bbc <bpin>
    log.lh.n++;
    80005e22:	0001e717          	auipc	a4,0x1e
    80005e26:	0fe70713          	addi	a4,a4,254 # 80023f20 <log>
    80005e2a:	575c                	lw	a5,44(a4)
    80005e2c:	2785                	addiw	a5,a5,1
    80005e2e:	d75c                	sw	a5,44(a4)
    80005e30:	a82d                	j	80005e6a <log_write+0xc8>
    panic("too big a transaction");
    80005e32:	00004517          	auipc	a0,0x4
    80005e36:	b9650513          	addi	a0,a0,-1130 # 800099c8 <syscalls+0x368>
    80005e3a:	ffffa097          	auipc	ra,0xffffa
    80005e3e:	6fe080e7          	jalr	1790(ra) # 80000538 <panic>
    panic("log_write outside of trans");
    80005e42:	00004517          	auipc	a0,0x4
    80005e46:	b9e50513          	addi	a0,a0,-1122 # 800099e0 <syscalls+0x380>
    80005e4a:	ffffa097          	auipc	ra,0xffffa
    80005e4e:	6ee080e7          	jalr	1774(ra) # 80000538 <panic>
  log.lh.block[i] = b->blockno;
    80005e52:	00878693          	addi	a3,a5,8
    80005e56:	068a                	slli	a3,a3,0x2
    80005e58:	0001e717          	auipc	a4,0x1e
    80005e5c:	0c870713          	addi	a4,a4,200 # 80023f20 <log>
    80005e60:	9736                	add	a4,a4,a3
    80005e62:	44d4                	lw	a3,12(s1)
    80005e64:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005e66:	faf609e3          	beq	a2,a5,80005e18 <log_write+0x76>
  }
  release(&log.lock);
    80005e6a:	0001e517          	auipc	a0,0x1e
    80005e6e:	0b650513          	addi	a0,a0,182 # 80023f20 <log>
    80005e72:	ffffb097          	auipc	ra,0xffffb
    80005e76:	e10080e7          	jalr	-496(ra) # 80000c82 <release>
}
    80005e7a:	60e2                	ld	ra,24(sp)
    80005e7c:	6442                	ld	s0,16(sp)
    80005e7e:	64a2                	ld	s1,8(sp)
    80005e80:	6902                	ld	s2,0(sp)
    80005e82:	6105                	addi	sp,sp,32
    80005e84:	8082                	ret

0000000080005e86 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005e86:	1101                	addi	sp,sp,-32
    80005e88:	ec06                	sd	ra,24(sp)
    80005e8a:	e822                	sd	s0,16(sp)
    80005e8c:	e426                	sd	s1,8(sp)
    80005e8e:	e04a                	sd	s2,0(sp)
    80005e90:	1000                	addi	s0,sp,32
    80005e92:	84aa                	mv	s1,a0
    80005e94:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005e96:	00004597          	auipc	a1,0x4
    80005e9a:	b6a58593          	addi	a1,a1,-1174 # 80009a00 <syscalls+0x3a0>
    80005e9e:	0521                	addi	a0,a0,8
    80005ea0:	ffffb097          	auipc	ra,0xffffb
    80005ea4:	c9e080e7          	jalr	-866(ra) # 80000b3e <initlock>
  lk->name = name;
    80005ea8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005eac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005eb0:	0204a423          	sw	zero,40(s1)
}
    80005eb4:	60e2                	ld	ra,24(sp)
    80005eb6:	6442                	ld	s0,16(sp)
    80005eb8:	64a2                	ld	s1,8(sp)
    80005eba:	6902                	ld	s2,0(sp)
    80005ebc:	6105                	addi	sp,sp,32
    80005ebe:	8082                	ret

0000000080005ec0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005ec0:	1101                	addi	sp,sp,-32
    80005ec2:	ec06                	sd	ra,24(sp)
    80005ec4:	e822                	sd	s0,16(sp)
    80005ec6:	e426                	sd	s1,8(sp)
    80005ec8:	e04a                	sd	s2,0(sp)
    80005eca:	1000                	addi	s0,sp,32
    80005ecc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005ece:	00850913          	addi	s2,a0,8
    80005ed2:	854a                	mv	a0,s2
    80005ed4:	ffffb097          	auipc	ra,0xffffb
    80005ed8:	cfa080e7          	jalr	-774(ra) # 80000bce <acquire>
  while (lk->locked) {
    80005edc:	409c                	lw	a5,0(s1)
    80005ede:	cb89                	beqz	a5,80005ef0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005ee0:	85ca                	mv	a1,s2
    80005ee2:	8526                	mv	a0,s1
    80005ee4:	ffffd097          	auipc	ra,0xffffd
    80005ee8:	8be080e7          	jalr	-1858(ra) # 800027a2 <sleep>
  while (lk->locked) {
    80005eec:	409c                	lw	a5,0(s1)
    80005eee:	fbed                	bnez	a5,80005ee0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005ef0:	4785                	li	a5,1
    80005ef2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005ef4:	ffffc097          	auipc	ra,0xffffc
    80005ef8:	afc080e7          	jalr	-1284(ra) # 800019f0 <myproc>
    80005efc:	591c                	lw	a5,48(a0)
    80005efe:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005f00:	854a                	mv	a0,s2
    80005f02:	ffffb097          	auipc	ra,0xffffb
    80005f06:	d80080e7          	jalr	-640(ra) # 80000c82 <release>
}
    80005f0a:	60e2                	ld	ra,24(sp)
    80005f0c:	6442                	ld	s0,16(sp)
    80005f0e:	64a2                	ld	s1,8(sp)
    80005f10:	6902                	ld	s2,0(sp)
    80005f12:	6105                	addi	sp,sp,32
    80005f14:	8082                	ret

0000000080005f16 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005f16:	1101                	addi	sp,sp,-32
    80005f18:	ec06                	sd	ra,24(sp)
    80005f1a:	e822                	sd	s0,16(sp)
    80005f1c:	e426                	sd	s1,8(sp)
    80005f1e:	e04a                	sd	s2,0(sp)
    80005f20:	1000                	addi	s0,sp,32
    80005f22:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005f24:	00850913          	addi	s2,a0,8
    80005f28:	854a                	mv	a0,s2
    80005f2a:	ffffb097          	auipc	ra,0xffffb
    80005f2e:	ca4080e7          	jalr	-860(ra) # 80000bce <acquire>
  lk->locked = 0;
    80005f32:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005f36:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005f3a:	8526                	mv	a0,s1
    80005f3c:	ffffd097          	auipc	ra,0xffffd
    80005f40:	e18080e7          	jalr	-488(ra) # 80002d54 <wakeup>
  release(&lk->lk);
    80005f44:	854a                	mv	a0,s2
    80005f46:	ffffb097          	auipc	ra,0xffffb
    80005f4a:	d3c080e7          	jalr	-708(ra) # 80000c82 <release>
}
    80005f4e:	60e2                	ld	ra,24(sp)
    80005f50:	6442                	ld	s0,16(sp)
    80005f52:	64a2                	ld	s1,8(sp)
    80005f54:	6902                	ld	s2,0(sp)
    80005f56:	6105                	addi	sp,sp,32
    80005f58:	8082                	ret

0000000080005f5a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005f5a:	7179                	addi	sp,sp,-48
    80005f5c:	f406                	sd	ra,40(sp)
    80005f5e:	f022                	sd	s0,32(sp)
    80005f60:	ec26                	sd	s1,24(sp)
    80005f62:	e84a                	sd	s2,16(sp)
    80005f64:	e44e                	sd	s3,8(sp)
    80005f66:	1800                	addi	s0,sp,48
    80005f68:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005f6a:	00850913          	addi	s2,a0,8
    80005f6e:	854a                	mv	a0,s2
    80005f70:	ffffb097          	auipc	ra,0xffffb
    80005f74:	c5e080e7          	jalr	-930(ra) # 80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80005f78:	409c                	lw	a5,0(s1)
    80005f7a:	ef99                	bnez	a5,80005f98 <holdingsleep+0x3e>
    80005f7c:	4481                	li	s1,0
  release(&lk->lk);
    80005f7e:	854a                	mv	a0,s2
    80005f80:	ffffb097          	auipc	ra,0xffffb
    80005f84:	d02080e7          	jalr	-766(ra) # 80000c82 <release>
  return r;
}
    80005f88:	8526                	mv	a0,s1
    80005f8a:	70a2                	ld	ra,40(sp)
    80005f8c:	7402                	ld	s0,32(sp)
    80005f8e:	64e2                	ld	s1,24(sp)
    80005f90:	6942                	ld	s2,16(sp)
    80005f92:	69a2                	ld	s3,8(sp)
    80005f94:	6145                	addi	sp,sp,48
    80005f96:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005f98:	0284a983          	lw	s3,40(s1)
    80005f9c:	ffffc097          	auipc	ra,0xffffc
    80005fa0:	a54080e7          	jalr	-1452(ra) # 800019f0 <myproc>
    80005fa4:	5904                	lw	s1,48(a0)
    80005fa6:	413484b3          	sub	s1,s1,s3
    80005faa:	0014b493          	seqz	s1,s1
    80005fae:	bfc1                	j	80005f7e <holdingsleep+0x24>

0000000080005fb0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005fb0:	1141                	addi	sp,sp,-16
    80005fb2:	e406                	sd	ra,8(sp)
    80005fb4:	e022                	sd	s0,0(sp)
    80005fb6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005fb8:	00004597          	auipc	a1,0x4
    80005fbc:	a5858593          	addi	a1,a1,-1448 # 80009a10 <syscalls+0x3b0>
    80005fc0:	0001e517          	auipc	a0,0x1e
    80005fc4:	0a850513          	addi	a0,a0,168 # 80024068 <ftable>
    80005fc8:	ffffb097          	auipc	ra,0xffffb
    80005fcc:	b76080e7          	jalr	-1162(ra) # 80000b3e <initlock>
}
    80005fd0:	60a2                	ld	ra,8(sp)
    80005fd2:	6402                	ld	s0,0(sp)
    80005fd4:	0141                	addi	sp,sp,16
    80005fd6:	8082                	ret

0000000080005fd8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005fd8:	1101                	addi	sp,sp,-32
    80005fda:	ec06                	sd	ra,24(sp)
    80005fdc:	e822                	sd	s0,16(sp)
    80005fde:	e426                	sd	s1,8(sp)
    80005fe0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005fe2:	0001e517          	auipc	a0,0x1e
    80005fe6:	08650513          	addi	a0,a0,134 # 80024068 <ftable>
    80005fea:	ffffb097          	auipc	ra,0xffffb
    80005fee:	be4080e7          	jalr	-1052(ra) # 80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005ff2:	0001e497          	auipc	s1,0x1e
    80005ff6:	08e48493          	addi	s1,s1,142 # 80024080 <ftable+0x18>
    80005ffa:	0001f717          	auipc	a4,0x1f
    80005ffe:	02670713          	addi	a4,a4,38 # 80025020 <ftable+0xfb8>
    if(f->ref == 0){
    80006002:	40dc                	lw	a5,4(s1)
    80006004:	cf99                	beqz	a5,80006022 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80006006:	02848493          	addi	s1,s1,40
    8000600a:	fee49ce3          	bne	s1,a4,80006002 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000600e:	0001e517          	auipc	a0,0x1e
    80006012:	05a50513          	addi	a0,a0,90 # 80024068 <ftable>
    80006016:	ffffb097          	auipc	ra,0xffffb
    8000601a:	c6c080e7          	jalr	-916(ra) # 80000c82 <release>
  return 0;
    8000601e:	4481                	li	s1,0
    80006020:	a819                	j	80006036 <filealloc+0x5e>
      f->ref = 1;
    80006022:	4785                	li	a5,1
    80006024:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80006026:	0001e517          	auipc	a0,0x1e
    8000602a:	04250513          	addi	a0,a0,66 # 80024068 <ftable>
    8000602e:	ffffb097          	auipc	ra,0xffffb
    80006032:	c54080e7          	jalr	-940(ra) # 80000c82 <release>
}
    80006036:	8526                	mv	a0,s1
    80006038:	60e2                	ld	ra,24(sp)
    8000603a:	6442                	ld	s0,16(sp)
    8000603c:	64a2                	ld	s1,8(sp)
    8000603e:	6105                	addi	sp,sp,32
    80006040:	8082                	ret

0000000080006042 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80006042:	1101                	addi	sp,sp,-32
    80006044:	ec06                	sd	ra,24(sp)
    80006046:	e822                	sd	s0,16(sp)
    80006048:	e426                	sd	s1,8(sp)
    8000604a:	1000                	addi	s0,sp,32
    8000604c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000604e:	0001e517          	auipc	a0,0x1e
    80006052:	01a50513          	addi	a0,a0,26 # 80024068 <ftable>
    80006056:	ffffb097          	auipc	ra,0xffffb
    8000605a:	b78080e7          	jalr	-1160(ra) # 80000bce <acquire>
  if(f->ref < 1)
    8000605e:	40dc                	lw	a5,4(s1)
    80006060:	02f05263          	blez	a5,80006084 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80006064:	2785                	addiw	a5,a5,1
    80006066:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80006068:	0001e517          	auipc	a0,0x1e
    8000606c:	00050513          	mv	a0,a0
    80006070:	ffffb097          	auipc	ra,0xffffb
    80006074:	c12080e7          	jalr	-1006(ra) # 80000c82 <release>
  return f;
}
    80006078:	8526                	mv	a0,s1
    8000607a:	60e2                	ld	ra,24(sp)
    8000607c:	6442                	ld	s0,16(sp)
    8000607e:	64a2                	ld	s1,8(sp)
    80006080:	6105                	addi	sp,sp,32
    80006082:	8082                	ret
    panic("filedup");
    80006084:	00004517          	auipc	a0,0x4
    80006088:	99450513          	addi	a0,a0,-1644 # 80009a18 <syscalls+0x3b8>
    8000608c:	ffffa097          	auipc	ra,0xffffa
    80006090:	4ac080e7          	jalr	1196(ra) # 80000538 <panic>

0000000080006094 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80006094:	7139                	addi	sp,sp,-64
    80006096:	fc06                	sd	ra,56(sp)
    80006098:	f822                	sd	s0,48(sp)
    8000609a:	f426                	sd	s1,40(sp)
    8000609c:	f04a                	sd	s2,32(sp)
    8000609e:	ec4e                	sd	s3,24(sp)
    800060a0:	e852                	sd	s4,16(sp)
    800060a2:	e456                	sd	s5,8(sp)
    800060a4:	0080                	addi	s0,sp,64
    800060a6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800060a8:	0001e517          	auipc	a0,0x1e
    800060ac:	fc050513          	addi	a0,a0,-64 # 80024068 <ftable>
    800060b0:	ffffb097          	auipc	ra,0xffffb
    800060b4:	b1e080e7          	jalr	-1250(ra) # 80000bce <acquire>
  if(f->ref < 1)
    800060b8:	40dc                	lw	a5,4(s1)
    800060ba:	06f05163          	blez	a5,8000611c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800060be:	37fd                	addiw	a5,a5,-1
    800060c0:	0007871b          	sext.w	a4,a5
    800060c4:	c0dc                	sw	a5,4(s1)
    800060c6:	06e04363          	bgtz	a4,8000612c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800060ca:	0004a903          	lw	s2,0(s1)
    800060ce:	0094ca83          	lbu	s5,9(s1)
    800060d2:	0104ba03          	ld	s4,16(s1)
    800060d6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800060da:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800060de:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800060e2:	0001e517          	auipc	a0,0x1e
    800060e6:	f8650513          	addi	a0,a0,-122 # 80024068 <ftable>
    800060ea:	ffffb097          	auipc	ra,0xffffb
    800060ee:	b98080e7          	jalr	-1128(ra) # 80000c82 <release>

  if(ff.type == FD_PIPE){
    800060f2:	4785                	li	a5,1
    800060f4:	04f90d63          	beq	s2,a5,8000614e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800060f8:	3979                	addiw	s2,s2,-2
    800060fa:	4785                	li	a5,1
    800060fc:	0527e063          	bltu	a5,s2,8000613c <fileclose+0xa8>
    begin_op();
    80006100:	00000097          	auipc	ra,0x0
    80006104:	acc080e7          	jalr	-1332(ra) # 80005bcc <begin_op>
    iput(ff.ip);
    80006108:	854e                	mv	a0,s3
    8000610a:	fffff097          	auipc	ra,0xfffff
    8000610e:	2a0080e7          	jalr	672(ra) # 800053aa <iput>
    end_op();
    80006112:	00000097          	auipc	ra,0x0
    80006116:	b38080e7          	jalr	-1224(ra) # 80005c4a <end_op>
    8000611a:	a00d                	j	8000613c <fileclose+0xa8>
    panic("fileclose");
    8000611c:	00004517          	auipc	a0,0x4
    80006120:	90450513          	addi	a0,a0,-1788 # 80009a20 <syscalls+0x3c0>
    80006124:	ffffa097          	auipc	ra,0xffffa
    80006128:	414080e7          	jalr	1044(ra) # 80000538 <panic>
    release(&ftable.lock);
    8000612c:	0001e517          	auipc	a0,0x1e
    80006130:	f3c50513          	addi	a0,a0,-196 # 80024068 <ftable>
    80006134:	ffffb097          	auipc	ra,0xffffb
    80006138:	b4e080e7          	jalr	-1202(ra) # 80000c82 <release>
  }
}
    8000613c:	70e2                	ld	ra,56(sp)
    8000613e:	7442                	ld	s0,48(sp)
    80006140:	74a2                	ld	s1,40(sp)
    80006142:	7902                	ld	s2,32(sp)
    80006144:	69e2                	ld	s3,24(sp)
    80006146:	6a42                	ld	s4,16(sp)
    80006148:	6aa2                	ld	s5,8(sp)
    8000614a:	6121                	addi	sp,sp,64
    8000614c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000614e:	85d6                	mv	a1,s5
    80006150:	8552                	mv	a0,s4
    80006152:	00000097          	auipc	ra,0x0
    80006156:	34c080e7          	jalr	844(ra) # 8000649e <pipeclose>
    8000615a:	b7cd                	j	8000613c <fileclose+0xa8>

000000008000615c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000615c:	715d                	addi	sp,sp,-80
    8000615e:	e486                	sd	ra,72(sp)
    80006160:	e0a2                	sd	s0,64(sp)
    80006162:	fc26                	sd	s1,56(sp)
    80006164:	f84a                	sd	s2,48(sp)
    80006166:	f44e                	sd	s3,40(sp)
    80006168:	0880                	addi	s0,sp,80
    8000616a:	84aa                	mv	s1,a0
    8000616c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000616e:	ffffc097          	auipc	ra,0xffffc
    80006172:	882080e7          	jalr	-1918(ra) # 800019f0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80006176:	409c                	lw	a5,0(s1)
    80006178:	37f9                	addiw	a5,a5,-2
    8000617a:	4705                	li	a4,1
    8000617c:	04f76763          	bltu	a4,a5,800061ca <filestat+0x6e>
    80006180:	892a                	mv	s2,a0
    ilock(f->ip);
    80006182:	6c88                	ld	a0,24(s1)
    80006184:	fffff097          	auipc	ra,0xfffff
    80006188:	06c080e7          	jalr	108(ra) # 800051f0 <ilock>
    stati(f->ip, &st);
    8000618c:	fb840593          	addi	a1,s0,-72
    80006190:	6c88                	ld	a0,24(s1)
    80006192:	fffff097          	auipc	ra,0xfffff
    80006196:	2e8080e7          	jalr	744(ra) # 8000547a <stati>
    iunlock(f->ip);
    8000619a:	6c88                	ld	a0,24(s1)
    8000619c:	fffff097          	auipc	ra,0xfffff
    800061a0:	116080e7          	jalr	278(ra) # 800052b2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800061a4:	46e1                	li	a3,24
    800061a6:	fb840613          	addi	a2,s0,-72
    800061aa:	85ce                	mv	a1,s3
    800061ac:	05893503          	ld	a0,88(s2)
    800061b0:	ffffb097          	auipc	ra,0xffffb
    800061b4:	504080e7          	jalr	1284(ra) # 800016b4 <copyout>
    800061b8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800061bc:	60a6                	ld	ra,72(sp)
    800061be:	6406                	ld	s0,64(sp)
    800061c0:	74e2                	ld	s1,56(sp)
    800061c2:	7942                	ld	s2,48(sp)
    800061c4:	79a2                	ld	s3,40(sp)
    800061c6:	6161                	addi	sp,sp,80
    800061c8:	8082                	ret
  return -1;
    800061ca:	557d                	li	a0,-1
    800061cc:	bfc5                	j	800061bc <filestat+0x60>

00000000800061ce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800061ce:	7179                	addi	sp,sp,-48
    800061d0:	f406                	sd	ra,40(sp)
    800061d2:	f022                	sd	s0,32(sp)
    800061d4:	ec26                	sd	s1,24(sp)
    800061d6:	e84a                	sd	s2,16(sp)
    800061d8:	e44e                	sd	s3,8(sp)
    800061da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800061dc:	00854783          	lbu	a5,8(a0)
    800061e0:	c3d5                	beqz	a5,80006284 <fileread+0xb6>
    800061e2:	84aa                	mv	s1,a0
    800061e4:	89ae                	mv	s3,a1
    800061e6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800061e8:	411c                	lw	a5,0(a0)
    800061ea:	4705                	li	a4,1
    800061ec:	04e78963          	beq	a5,a4,8000623e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800061f0:	470d                	li	a4,3
    800061f2:	04e78d63          	beq	a5,a4,8000624c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800061f6:	4709                	li	a4,2
    800061f8:	06e79e63          	bne	a5,a4,80006274 <fileread+0xa6>
    ilock(f->ip);
    800061fc:	6d08                	ld	a0,24(a0)
    800061fe:	fffff097          	auipc	ra,0xfffff
    80006202:	ff2080e7          	jalr	-14(ra) # 800051f0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80006206:	874a                	mv	a4,s2
    80006208:	5094                	lw	a3,32(s1)
    8000620a:	864e                	mv	a2,s3
    8000620c:	4585                	li	a1,1
    8000620e:	6c88                	ld	a0,24(s1)
    80006210:	fffff097          	auipc	ra,0xfffff
    80006214:	294080e7          	jalr	660(ra) # 800054a4 <readi>
    80006218:	892a                	mv	s2,a0
    8000621a:	00a05563          	blez	a0,80006224 <fileread+0x56>
      f->off += r;
    8000621e:	509c                	lw	a5,32(s1)
    80006220:	9fa9                	addw	a5,a5,a0
    80006222:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80006224:	6c88                	ld	a0,24(s1)
    80006226:	fffff097          	auipc	ra,0xfffff
    8000622a:	08c080e7          	jalr	140(ra) # 800052b2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000622e:	854a                	mv	a0,s2
    80006230:	70a2                	ld	ra,40(sp)
    80006232:	7402                	ld	s0,32(sp)
    80006234:	64e2                	ld	s1,24(sp)
    80006236:	6942                	ld	s2,16(sp)
    80006238:	69a2                	ld	s3,8(sp)
    8000623a:	6145                	addi	sp,sp,48
    8000623c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000623e:	6908                	ld	a0,16(a0)
    80006240:	00000097          	auipc	ra,0x0
    80006244:	3c0080e7          	jalr	960(ra) # 80006600 <piperead>
    80006248:	892a                	mv	s2,a0
    8000624a:	b7d5                	j	8000622e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000624c:	02451783          	lh	a5,36(a0)
    80006250:	03079693          	slli	a3,a5,0x30
    80006254:	92c1                	srli	a3,a3,0x30
    80006256:	4725                	li	a4,9
    80006258:	02d76863          	bltu	a4,a3,80006288 <fileread+0xba>
    8000625c:	0792                	slli	a5,a5,0x4
    8000625e:	0001e717          	auipc	a4,0x1e
    80006262:	d6a70713          	addi	a4,a4,-662 # 80023fc8 <devsw>
    80006266:	97ba                	add	a5,a5,a4
    80006268:	639c                	ld	a5,0(a5)
    8000626a:	c38d                	beqz	a5,8000628c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000626c:	4505                	li	a0,1
    8000626e:	9782                	jalr	a5
    80006270:	892a                	mv	s2,a0
    80006272:	bf75                	j	8000622e <fileread+0x60>
    panic("fileread");
    80006274:	00003517          	auipc	a0,0x3
    80006278:	7bc50513          	addi	a0,a0,1980 # 80009a30 <syscalls+0x3d0>
    8000627c:	ffffa097          	auipc	ra,0xffffa
    80006280:	2bc080e7          	jalr	700(ra) # 80000538 <panic>
    return -1;
    80006284:	597d                	li	s2,-1
    80006286:	b765                	j	8000622e <fileread+0x60>
      return -1;
    80006288:	597d                	li	s2,-1
    8000628a:	b755                	j	8000622e <fileread+0x60>
    8000628c:	597d                	li	s2,-1
    8000628e:	b745                	j	8000622e <fileread+0x60>

0000000080006290 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80006290:	715d                	addi	sp,sp,-80
    80006292:	e486                	sd	ra,72(sp)
    80006294:	e0a2                	sd	s0,64(sp)
    80006296:	fc26                	sd	s1,56(sp)
    80006298:	f84a                	sd	s2,48(sp)
    8000629a:	f44e                	sd	s3,40(sp)
    8000629c:	f052                	sd	s4,32(sp)
    8000629e:	ec56                	sd	s5,24(sp)
    800062a0:	e85a                	sd	s6,16(sp)
    800062a2:	e45e                	sd	s7,8(sp)
    800062a4:	e062                	sd	s8,0(sp)
    800062a6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800062a8:	00954783          	lbu	a5,9(a0)
    800062ac:	10078663          	beqz	a5,800063b8 <filewrite+0x128>
    800062b0:	892a                	mv	s2,a0
    800062b2:	8b2e                	mv	s6,a1
    800062b4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800062b6:	411c                	lw	a5,0(a0)
    800062b8:	4705                	li	a4,1
    800062ba:	02e78263          	beq	a5,a4,800062de <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800062be:	470d                	li	a4,3
    800062c0:	02e78663          	beq	a5,a4,800062ec <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800062c4:	4709                	li	a4,2
    800062c6:	0ee79163          	bne	a5,a4,800063a8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800062ca:	0ac05d63          	blez	a2,80006384 <filewrite+0xf4>
    int i = 0;
    800062ce:	4981                	li	s3,0
    800062d0:	6b85                	lui	s7,0x1
    800062d2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800062d6:	6c05                	lui	s8,0x1
    800062d8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800062dc:	a861                	j	80006374 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800062de:	6908                	ld	a0,16(a0)
    800062e0:	00000097          	auipc	ra,0x0
    800062e4:	22e080e7          	jalr	558(ra) # 8000650e <pipewrite>
    800062e8:	8a2a                	mv	s4,a0
    800062ea:	a045                	j	8000638a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800062ec:	02451783          	lh	a5,36(a0)
    800062f0:	03079693          	slli	a3,a5,0x30
    800062f4:	92c1                	srli	a3,a3,0x30
    800062f6:	4725                	li	a4,9
    800062f8:	0cd76263          	bltu	a4,a3,800063bc <filewrite+0x12c>
    800062fc:	0792                	slli	a5,a5,0x4
    800062fe:	0001e717          	auipc	a4,0x1e
    80006302:	cca70713          	addi	a4,a4,-822 # 80023fc8 <devsw>
    80006306:	97ba                	add	a5,a5,a4
    80006308:	679c                	ld	a5,8(a5)
    8000630a:	cbdd                	beqz	a5,800063c0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000630c:	4505                	li	a0,1
    8000630e:	9782                	jalr	a5
    80006310:	8a2a                	mv	s4,a0
    80006312:	a8a5                	j	8000638a <filewrite+0xfa>
    80006314:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80006318:	00000097          	auipc	ra,0x0
    8000631c:	8b4080e7          	jalr	-1868(ra) # 80005bcc <begin_op>
      ilock(f->ip);
    80006320:	01893503          	ld	a0,24(s2)
    80006324:	fffff097          	auipc	ra,0xfffff
    80006328:	ecc080e7          	jalr	-308(ra) # 800051f0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000632c:	8756                	mv	a4,s5
    8000632e:	02092683          	lw	a3,32(s2)
    80006332:	01698633          	add	a2,s3,s6
    80006336:	4585                	li	a1,1
    80006338:	01893503          	ld	a0,24(s2)
    8000633c:	fffff097          	auipc	ra,0xfffff
    80006340:	260080e7          	jalr	608(ra) # 8000559c <writei>
    80006344:	84aa                	mv	s1,a0
    80006346:	00a05763          	blez	a0,80006354 <filewrite+0xc4>
        f->off += r;
    8000634a:	02092783          	lw	a5,32(s2)
    8000634e:	9fa9                	addw	a5,a5,a0
    80006350:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80006354:	01893503          	ld	a0,24(s2)
    80006358:	fffff097          	auipc	ra,0xfffff
    8000635c:	f5a080e7          	jalr	-166(ra) # 800052b2 <iunlock>
      end_op();
    80006360:	00000097          	auipc	ra,0x0
    80006364:	8ea080e7          	jalr	-1814(ra) # 80005c4a <end_op>

      if(r != n1){
    80006368:	009a9f63          	bne	s5,s1,80006386 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000636c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80006370:	0149db63          	bge	s3,s4,80006386 <filewrite+0xf6>
      int n1 = n - i;
    80006374:	413a04bb          	subw	s1,s4,s3
    80006378:	0004879b          	sext.w	a5,s1
    8000637c:	f8fbdce3          	bge	s7,a5,80006314 <filewrite+0x84>
    80006380:	84e2                	mv	s1,s8
    80006382:	bf49                	j	80006314 <filewrite+0x84>
    int i = 0;
    80006384:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80006386:	013a1f63          	bne	s4,s3,800063a4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000638a:	8552                	mv	a0,s4
    8000638c:	60a6                	ld	ra,72(sp)
    8000638e:	6406                	ld	s0,64(sp)
    80006390:	74e2                	ld	s1,56(sp)
    80006392:	7942                	ld	s2,48(sp)
    80006394:	79a2                	ld	s3,40(sp)
    80006396:	7a02                	ld	s4,32(sp)
    80006398:	6ae2                	ld	s5,24(sp)
    8000639a:	6b42                	ld	s6,16(sp)
    8000639c:	6ba2                	ld	s7,8(sp)
    8000639e:	6c02                	ld	s8,0(sp)
    800063a0:	6161                	addi	sp,sp,80
    800063a2:	8082                	ret
    ret = (i == n ? n : -1);
    800063a4:	5a7d                	li	s4,-1
    800063a6:	b7d5                	j	8000638a <filewrite+0xfa>
    panic("filewrite");
    800063a8:	00003517          	auipc	a0,0x3
    800063ac:	69850513          	addi	a0,a0,1688 # 80009a40 <syscalls+0x3e0>
    800063b0:	ffffa097          	auipc	ra,0xffffa
    800063b4:	188080e7          	jalr	392(ra) # 80000538 <panic>
    return -1;
    800063b8:	5a7d                	li	s4,-1
    800063ba:	bfc1                	j	8000638a <filewrite+0xfa>
      return -1;
    800063bc:	5a7d                	li	s4,-1
    800063be:	b7f1                	j	8000638a <filewrite+0xfa>
    800063c0:	5a7d                	li	s4,-1
    800063c2:	b7e1                	j	8000638a <filewrite+0xfa>

00000000800063c4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800063c4:	7179                	addi	sp,sp,-48
    800063c6:	f406                	sd	ra,40(sp)
    800063c8:	f022                	sd	s0,32(sp)
    800063ca:	ec26                	sd	s1,24(sp)
    800063cc:	e84a                	sd	s2,16(sp)
    800063ce:	e44e                	sd	s3,8(sp)
    800063d0:	e052                	sd	s4,0(sp)
    800063d2:	1800                	addi	s0,sp,48
    800063d4:	84aa                	mv	s1,a0
    800063d6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800063d8:	0005b023          	sd	zero,0(a1)
    800063dc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800063e0:	00000097          	auipc	ra,0x0
    800063e4:	bf8080e7          	jalr	-1032(ra) # 80005fd8 <filealloc>
    800063e8:	e088                	sd	a0,0(s1)
    800063ea:	c551                	beqz	a0,80006476 <pipealloc+0xb2>
    800063ec:	00000097          	auipc	ra,0x0
    800063f0:	bec080e7          	jalr	-1044(ra) # 80005fd8 <filealloc>
    800063f4:	00aa3023          	sd	a0,0(s4)
    800063f8:	c92d                	beqz	a0,8000646a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800063fa:	ffffa097          	auipc	ra,0xffffa
    800063fe:	6e4080e7          	jalr	1764(ra) # 80000ade <kalloc>
    80006402:	892a                	mv	s2,a0
    80006404:	c125                	beqz	a0,80006464 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80006406:	4985                	li	s3,1
    80006408:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000640c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80006410:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80006414:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80006418:	00003597          	auipc	a1,0x3
    8000641c:	63858593          	addi	a1,a1,1592 # 80009a50 <syscalls+0x3f0>
    80006420:	ffffa097          	auipc	ra,0xffffa
    80006424:	71e080e7          	jalr	1822(ra) # 80000b3e <initlock>
  (*f0)->type = FD_PIPE;
    80006428:	609c                	ld	a5,0(s1)
    8000642a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000642e:	609c                	ld	a5,0(s1)
    80006430:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80006434:	609c                	ld	a5,0(s1)
    80006436:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000643a:	609c                	ld	a5,0(s1)
    8000643c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80006440:	000a3783          	ld	a5,0(s4)
    80006444:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80006448:	000a3783          	ld	a5,0(s4)
    8000644c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80006450:	000a3783          	ld	a5,0(s4)
    80006454:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80006458:	000a3783          	ld	a5,0(s4)
    8000645c:	0127b823          	sd	s2,16(a5)
  return 0;
    80006460:	4501                	li	a0,0
    80006462:	a025                	j	8000648a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80006464:	6088                	ld	a0,0(s1)
    80006466:	e501                	bnez	a0,8000646e <pipealloc+0xaa>
    80006468:	a039                	j	80006476 <pipealloc+0xb2>
    8000646a:	6088                	ld	a0,0(s1)
    8000646c:	c51d                	beqz	a0,8000649a <pipealloc+0xd6>
    fileclose(*f0);
    8000646e:	00000097          	auipc	ra,0x0
    80006472:	c26080e7          	jalr	-986(ra) # 80006094 <fileclose>
  if(*f1)
    80006476:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000647a:	557d                	li	a0,-1
  if(*f1)
    8000647c:	c799                	beqz	a5,8000648a <pipealloc+0xc6>
    fileclose(*f1);
    8000647e:	853e                	mv	a0,a5
    80006480:	00000097          	auipc	ra,0x0
    80006484:	c14080e7          	jalr	-1004(ra) # 80006094 <fileclose>
  return -1;
    80006488:	557d                	li	a0,-1
}
    8000648a:	70a2                	ld	ra,40(sp)
    8000648c:	7402                	ld	s0,32(sp)
    8000648e:	64e2                	ld	s1,24(sp)
    80006490:	6942                	ld	s2,16(sp)
    80006492:	69a2                	ld	s3,8(sp)
    80006494:	6a02                	ld	s4,0(sp)
    80006496:	6145                	addi	sp,sp,48
    80006498:	8082                	ret
  return -1;
    8000649a:	557d                	li	a0,-1
    8000649c:	b7fd                	j	8000648a <pipealloc+0xc6>

000000008000649e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000649e:	1101                	addi	sp,sp,-32
    800064a0:	ec06                	sd	ra,24(sp)
    800064a2:	e822                	sd	s0,16(sp)
    800064a4:	e426                	sd	s1,8(sp)
    800064a6:	e04a                	sd	s2,0(sp)
    800064a8:	1000                	addi	s0,sp,32
    800064aa:	84aa                	mv	s1,a0
    800064ac:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800064ae:	ffffa097          	auipc	ra,0xffffa
    800064b2:	720080e7          	jalr	1824(ra) # 80000bce <acquire>
  if(writable){
    800064b6:	02090d63          	beqz	s2,800064f0 <pipeclose+0x52>
    pi->writeopen = 0;
    800064ba:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800064be:	21848513          	addi	a0,s1,536
    800064c2:	ffffd097          	auipc	ra,0xffffd
    800064c6:	892080e7          	jalr	-1902(ra) # 80002d54 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800064ca:	2204b783          	ld	a5,544(s1)
    800064ce:	eb95                	bnez	a5,80006502 <pipeclose+0x64>
    release(&pi->lock);
    800064d0:	8526                	mv	a0,s1
    800064d2:	ffffa097          	auipc	ra,0xffffa
    800064d6:	7b0080e7          	jalr	1968(ra) # 80000c82 <release>
    kfree((char*)pi);
    800064da:	8526                	mv	a0,s1
    800064dc:	ffffa097          	auipc	ra,0xffffa
    800064e0:	504080e7          	jalr	1284(ra) # 800009e0 <kfree>
  } else
    release(&pi->lock);
}
    800064e4:	60e2                	ld	ra,24(sp)
    800064e6:	6442                	ld	s0,16(sp)
    800064e8:	64a2                	ld	s1,8(sp)
    800064ea:	6902                	ld	s2,0(sp)
    800064ec:	6105                	addi	sp,sp,32
    800064ee:	8082                	ret
    pi->readopen = 0;
    800064f0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800064f4:	21c48513          	addi	a0,s1,540
    800064f8:	ffffd097          	auipc	ra,0xffffd
    800064fc:	85c080e7          	jalr	-1956(ra) # 80002d54 <wakeup>
    80006500:	b7e9                	j	800064ca <pipeclose+0x2c>
    release(&pi->lock);
    80006502:	8526                	mv	a0,s1
    80006504:	ffffa097          	auipc	ra,0xffffa
    80006508:	77e080e7          	jalr	1918(ra) # 80000c82 <release>
}
    8000650c:	bfe1                	j	800064e4 <pipeclose+0x46>

000000008000650e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000650e:	711d                	addi	sp,sp,-96
    80006510:	ec86                	sd	ra,88(sp)
    80006512:	e8a2                	sd	s0,80(sp)
    80006514:	e4a6                	sd	s1,72(sp)
    80006516:	e0ca                	sd	s2,64(sp)
    80006518:	fc4e                	sd	s3,56(sp)
    8000651a:	f852                	sd	s4,48(sp)
    8000651c:	f456                	sd	s5,40(sp)
    8000651e:	f05a                	sd	s6,32(sp)
    80006520:	ec5e                	sd	s7,24(sp)
    80006522:	e862                	sd	s8,16(sp)
    80006524:	1080                	addi	s0,sp,96
    80006526:	84aa                	mv	s1,a0
    80006528:	8aae                	mv	s5,a1
    8000652a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000652c:	ffffb097          	auipc	ra,0xffffb
    80006530:	4c4080e7          	jalr	1220(ra) # 800019f0 <myproc>
    80006534:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80006536:	8526                	mv	a0,s1
    80006538:	ffffa097          	auipc	ra,0xffffa
    8000653c:	696080e7          	jalr	1686(ra) # 80000bce <acquire>
  while(i < n){
    80006540:	0b405363          	blez	s4,800065e6 <pipewrite+0xd8>
  int i = 0;
    80006544:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80006546:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80006548:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000654c:	21c48b93          	addi	s7,s1,540
    80006550:	a089                	j	80006592 <pipewrite+0x84>
      release(&pi->lock);
    80006552:	8526                	mv	a0,s1
    80006554:	ffffa097          	auipc	ra,0xffffa
    80006558:	72e080e7          	jalr	1838(ra) # 80000c82 <release>
      return -1;
    8000655c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000655e:	854a                	mv	a0,s2
    80006560:	60e6                	ld	ra,88(sp)
    80006562:	6446                	ld	s0,80(sp)
    80006564:	64a6                	ld	s1,72(sp)
    80006566:	6906                	ld	s2,64(sp)
    80006568:	79e2                	ld	s3,56(sp)
    8000656a:	7a42                	ld	s4,48(sp)
    8000656c:	7aa2                	ld	s5,40(sp)
    8000656e:	7b02                	ld	s6,32(sp)
    80006570:	6be2                	ld	s7,24(sp)
    80006572:	6c42                	ld	s8,16(sp)
    80006574:	6125                	addi	sp,sp,96
    80006576:	8082                	ret
      wakeup(&pi->nread);
    80006578:	8562                	mv	a0,s8
    8000657a:	ffffc097          	auipc	ra,0xffffc
    8000657e:	7da080e7          	jalr	2010(ra) # 80002d54 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80006582:	85a6                	mv	a1,s1
    80006584:	855e                	mv	a0,s7
    80006586:	ffffc097          	auipc	ra,0xffffc
    8000658a:	21c080e7          	jalr	540(ra) # 800027a2 <sleep>
  while(i < n){
    8000658e:	05495d63          	bge	s2,s4,800065e8 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80006592:	2204a783          	lw	a5,544(s1)
    80006596:	dfd5                	beqz	a5,80006552 <pipewrite+0x44>
    80006598:	0289a783          	lw	a5,40(s3)
    8000659c:	fbdd                	bnez	a5,80006552 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000659e:	2184a783          	lw	a5,536(s1)
    800065a2:	21c4a703          	lw	a4,540(s1)
    800065a6:	2007879b          	addiw	a5,a5,512
    800065aa:	fcf707e3          	beq	a4,a5,80006578 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800065ae:	4685                	li	a3,1
    800065b0:	01590633          	add	a2,s2,s5
    800065b4:	faf40593          	addi	a1,s0,-81
    800065b8:	0589b503          	ld	a0,88(s3)
    800065bc:	ffffb097          	auipc	ra,0xffffb
    800065c0:	184080e7          	jalr	388(ra) # 80001740 <copyin>
    800065c4:	03650263          	beq	a0,s6,800065e8 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800065c8:	21c4a783          	lw	a5,540(s1)
    800065cc:	0017871b          	addiw	a4,a5,1
    800065d0:	20e4ae23          	sw	a4,540(s1)
    800065d4:	1ff7f793          	andi	a5,a5,511
    800065d8:	97a6                	add	a5,a5,s1
    800065da:	faf44703          	lbu	a4,-81(s0)
    800065de:	00e78c23          	sb	a4,24(a5)
      i++;
    800065e2:	2905                	addiw	s2,s2,1
    800065e4:	b76d                	j	8000658e <pipewrite+0x80>
  int i = 0;
    800065e6:	4901                	li	s2,0
  wakeup(&pi->nread);
    800065e8:	21848513          	addi	a0,s1,536
    800065ec:	ffffc097          	auipc	ra,0xffffc
    800065f0:	768080e7          	jalr	1896(ra) # 80002d54 <wakeup>
  release(&pi->lock);
    800065f4:	8526                	mv	a0,s1
    800065f6:	ffffa097          	auipc	ra,0xffffa
    800065fa:	68c080e7          	jalr	1676(ra) # 80000c82 <release>
  return i;
    800065fe:	b785                	j	8000655e <pipewrite+0x50>

0000000080006600 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80006600:	715d                	addi	sp,sp,-80
    80006602:	e486                	sd	ra,72(sp)
    80006604:	e0a2                	sd	s0,64(sp)
    80006606:	fc26                	sd	s1,56(sp)
    80006608:	f84a                	sd	s2,48(sp)
    8000660a:	f44e                	sd	s3,40(sp)
    8000660c:	f052                	sd	s4,32(sp)
    8000660e:	ec56                	sd	s5,24(sp)
    80006610:	e85a                	sd	s6,16(sp)
    80006612:	0880                	addi	s0,sp,80
    80006614:	84aa                	mv	s1,a0
    80006616:	892e                	mv	s2,a1
    80006618:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000661a:	ffffb097          	auipc	ra,0xffffb
    8000661e:	3d6080e7          	jalr	982(ra) # 800019f0 <myproc>
    80006622:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80006624:	8526                	mv	a0,s1
    80006626:	ffffa097          	auipc	ra,0xffffa
    8000662a:	5a8080e7          	jalr	1448(ra) # 80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000662e:	2184a703          	lw	a4,536(s1)
    80006632:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80006636:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000663a:	02f71463          	bne	a4,a5,80006662 <piperead+0x62>
    8000663e:	2244a783          	lw	a5,548(s1)
    80006642:	c385                	beqz	a5,80006662 <piperead+0x62>
    if(pr->killed){
    80006644:	028a2783          	lw	a5,40(s4)
    80006648:	ebc9                	bnez	a5,800066da <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000664a:	85a6                	mv	a1,s1
    8000664c:	854e                	mv	a0,s3
    8000664e:	ffffc097          	auipc	ra,0xffffc
    80006652:	154080e7          	jalr	340(ra) # 800027a2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80006656:	2184a703          	lw	a4,536(s1)
    8000665a:	21c4a783          	lw	a5,540(s1)
    8000665e:	fef700e3          	beq	a4,a5,8000663e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006662:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80006664:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006666:	05505463          	blez	s5,800066ae <piperead+0xae>
    if(pi->nread == pi->nwrite)
    8000666a:	2184a783          	lw	a5,536(s1)
    8000666e:	21c4a703          	lw	a4,540(s1)
    80006672:	02f70e63          	beq	a4,a5,800066ae <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80006676:	0017871b          	addiw	a4,a5,1
    8000667a:	20e4ac23          	sw	a4,536(s1)
    8000667e:	1ff7f793          	andi	a5,a5,511
    80006682:	97a6                	add	a5,a5,s1
    80006684:	0187c783          	lbu	a5,24(a5)
    80006688:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000668c:	4685                	li	a3,1
    8000668e:	fbf40613          	addi	a2,s0,-65
    80006692:	85ca                	mv	a1,s2
    80006694:	058a3503          	ld	a0,88(s4)
    80006698:	ffffb097          	auipc	ra,0xffffb
    8000669c:	01c080e7          	jalr	28(ra) # 800016b4 <copyout>
    800066a0:	01650763          	beq	a0,s6,800066ae <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800066a4:	2985                	addiw	s3,s3,1
    800066a6:	0905                	addi	s2,s2,1
    800066a8:	fd3a91e3          	bne	s5,s3,8000666a <piperead+0x6a>
    800066ac:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800066ae:	21c48513          	addi	a0,s1,540
    800066b2:	ffffc097          	auipc	ra,0xffffc
    800066b6:	6a2080e7          	jalr	1698(ra) # 80002d54 <wakeup>
  release(&pi->lock);
    800066ba:	8526                	mv	a0,s1
    800066bc:	ffffa097          	auipc	ra,0xffffa
    800066c0:	5c6080e7          	jalr	1478(ra) # 80000c82 <release>
  return i;
}
    800066c4:	854e                	mv	a0,s3
    800066c6:	60a6                	ld	ra,72(sp)
    800066c8:	6406                	ld	s0,64(sp)
    800066ca:	74e2                	ld	s1,56(sp)
    800066cc:	7942                	ld	s2,48(sp)
    800066ce:	79a2                	ld	s3,40(sp)
    800066d0:	7a02                	ld	s4,32(sp)
    800066d2:	6ae2                	ld	s5,24(sp)
    800066d4:	6b42                	ld	s6,16(sp)
    800066d6:	6161                	addi	sp,sp,80
    800066d8:	8082                	ret
      release(&pi->lock);
    800066da:	8526                	mv	a0,s1
    800066dc:	ffffa097          	auipc	ra,0xffffa
    800066e0:	5a6080e7          	jalr	1446(ra) # 80000c82 <release>
      return -1;
    800066e4:	59fd                	li	s3,-1
    800066e6:	bff9                	j	800066c4 <piperead+0xc4>

00000000800066e8 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800066e8:	de010113          	addi	sp,sp,-544
    800066ec:	20113c23          	sd	ra,536(sp)
    800066f0:	20813823          	sd	s0,528(sp)
    800066f4:	20913423          	sd	s1,520(sp)
    800066f8:	21213023          	sd	s2,512(sp)
    800066fc:	ffce                	sd	s3,504(sp)
    800066fe:	fbd2                	sd	s4,496(sp)
    80006700:	f7d6                	sd	s5,488(sp)
    80006702:	f3da                	sd	s6,480(sp)
    80006704:	efde                	sd	s7,472(sp)
    80006706:	ebe2                	sd	s8,464(sp)
    80006708:	e7e6                	sd	s9,456(sp)
    8000670a:	e3ea                	sd	s10,448(sp)
    8000670c:	ff6e                	sd	s11,440(sp)
    8000670e:	1400                	addi	s0,sp,544
    80006710:	892a                	mv	s2,a0
    80006712:	dea43423          	sd	a0,-536(s0)
    80006716:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000671a:	ffffb097          	auipc	ra,0xffffb
    8000671e:	2d6080e7          	jalr	726(ra) # 800019f0 <myproc>
    80006722:	84aa                	mv	s1,a0

  begin_op();
    80006724:	fffff097          	auipc	ra,0xfffff
    80006728:	4a8080e7          	jalr	1192(ra) # 80005bcc <begin_op>

  if((ip = namei(path)) == 0){
    8000672c:	854a                	mv	a0,s2
    8000672e:	fffff097          	auipc	ra,0xfffff
    80006732:	27e080e7          	jalr	638(ra) # 800059ac <namei>
    80006736:	c93d                	beqz	a0,800067ac <exec+0xc4>
    80006738:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000673a:	fffff097          	auipc	ra,0xfffff
    8000673e:	ab6080e7          	jalr	-1354(ra) # 800051f0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80006742:	04000713          	li	a4,64
    80006746:	4681                	li	a3,0
    80006748:	e5040613          	addi	a2,s0,-432
    8000674c:	4581                	li	a1,0
    8000674e:	8556                	mv	a0,s5
    80006750:	fffff097          	auipc	ra,0xfffff
    80006754:	d54080e7          	jalr	-684(ra) # 800054a4 <readi>
    80006758:	04000793          	li	a5,64
    8000675c:	00f51a63          	bne	a0,a5,80006770 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80006760:	e5042703          	lw	a4,-432(s0)
    80006764:	464c47b7          	lui	a5,0x464c4
    80006768:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000676c:	04f70663          	beq	a4,a5,800067b8 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80006770:	8556                	mv	a0,s5
    80006772:	fffff097          	auipc	ra,0xfffff
    80006776:	ce0080e7          	jalr	-800(ra) # 80005452 <iunlockput>
    end_op();
    8000677a:	fffff097          	auipc	ra,0xfffff
    8000677e:	4d0080e7          	jalr	1232(ra) # 80005c4a <end_op>
  }
  return -1;
    80006782:	557d                	li	a0,-1
}
    80006784:	21813083          	ld	ra,536(sp)
    80006788:	21013403          	ld	s0,528(sp)
    8000678c:	20813483          	ld	s1,520(sp)
    80006790:	20013903          	ld	s2,512(sp)
    80006794:	79fe                	ld	s3,504(sp)
    80006796:	7a5e                	ld	s4,496(sp)
    80006798:	7abe                	ld	s5,488(sp)
    8000679a:	7b1e                	ld	s6,480(sp)
    8000679c:	6bfe                	ld	s7,472(sp)
    8000679e:	6c5e                	ld	s8,464(sp)
    800067a0:	6cbe                	ld	s9,456(sp)
    800067a2:	6d1e                	ld	s10,448(sp)
    800067a4:	7dfa                	ld	s11,440(sp)
    800067a6:	22010113          	addi	sp,sp,544
    800067aa:	8082                	ret
    end_op();
    800067ac:	fffff097          	auipc	ra,0xfffff
    800067b0:	49e080e7          	jalr	1182(ra) # 80005c4a <end_op>
    return -1;
    800067b4:	557d                	li	a0,-1
    800067b6:	b7f9                	j	80006784 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800067b8:	8526                	mv	a0,s1
    800067ba:	ffffb097          	auipc	ra,0xffffb
    800067be:	332080e7          	jalr	818(ra) # 80001aec <proc_pagetable>
    800067c2:	8b2a                	mv	s6,a0
    800067c4:	d555                	beqz	a0,80006770 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800067c6:	e7042783          	lw	a5,-400(s0)
    800067ca:	e8845703          	lhu	a4,-376(s0)
    800067ce:	c735                	beqz	a4,8000683a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800067d0:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800067d2:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    800067d6:	6a05                	lui	s4,0x1
    800067d8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800067dc:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800067e0:	6d85                	lui	s11,0x1
    800067e2:	7d7d                	lui	s10,0xfffff
    800067e4:	ac1d                	j	80006a1a <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800067e6:	00003517          	auipc	a0,0x3
    800067ea:	27250513          	addi	a0,a0,626 # 80009a58 <syscalls+0x3f8>
    800067ee:	ffffa097          	auipc	ra,0xffffa
    800067f2:	d4a080e7          	jalr	-694(ra) # 80000538 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800067f6:	874a                	mv	a4,s2
    800067f8:	009c86bb          	addw	a3,s9,s1
    800067fc:	4581                	li	a1,0
    800067fe:	8556                	mv	a0,s5
    80006800:	fffff097          	auipc	ra,0xfffff
    80006804:	ca4080e7          	jalr	-860(ra) # 800054a4 <readi>
    80006808:	2501                	sext.w	a0,a0
    8000680a:	1aa91863          	bne	s2,a0,800069ba <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    8000680e:	009d84bb          	addw	s1,s11,s1
    80006812:	013d09bb          	addw	s3,s10,s3
    80006816:	1f74f263          	bgeu	s1,s7,800069fa <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    8000681a:	02049593          	slli	a1,s1,0x20
    8000681e:	9181                	srli	a1,a1,0x20
    80006820:	95e2                	add	a1,a1,s8
    80006822:	855a                	mv	a0,s6
    80006824:	ffffb097          	auipc	ra,0xffffb
    80006828:	888080e7          	jalr	-1912(ra) # 800010ac <walkaddr>
    8000682c:	862a                	mv	a2,a0
    if(pa == 0)
    8000682e:	dd45                	beqz	a0,800067e6 <exec+0xfe>
      n = PGSIZE;
    80006830:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80006832:	fd49f2e3          	bgeu	s3,s4,800067f6 <exec+0x10e>
      n = sz - i;
    80006836:	894e                	mv	s2,s3
    80006838:	bf7d                	j	800067f6 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000683a:	4481                	li	s1,0
  iunlockput(ip);
    8000683c:	8556                	mv	a0,s5
    8000683e:	fffff097          	auipc	ra,0xfffff
    80006842:	c14080e7          	jalr	-1004(ra) # 80005452 <iunlockput>
  end_op();
    80006846:	fffff097          	auipc	ra,0xfffff
    8000684a:	404080e7          	jalr	1028(ra) # 80005c4a <end_op>
  p = myproc();
    8000684e:	ffffb097          	auipc	ra,0xffffb
    80006852:	1a2080e7          	jalr	418(ra) # 800019f0 <myproc>
    80006856:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80006858:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000685c:	6785                	lui	a5,0x1
    8000685e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80006860:	97a6                	add	a5,a5,s1
    80006862:	777d                	lui	a4,0xfffff
    80006864:	8ff9                	and	a5,a5,a4
    80006866:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000686a:	6609                	lui	a2,0x2
    8000686c:	963e                	add	a2,a2,a5
    8000686e:	85be                	mv	a1,a5
    80006870:	855a                	mv	a0,s6
    80006872:	ffffb097          	auipc	ra,0xffffb
    80006876:	bee080e7          	jalr	-1042(ra) # 80001460 <uvmalloc>
    8000687a:	8c2a                	mv	s8,a0
  ip = 0;
    8000687c:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000687e:	12050e63          	beqz	a0,800069ba <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80006882:	75f9                	lui	a1,0xffffe
    80006884:	95aa                	add	a1,a1,a0
    80006886:	855a                	mv	a0,s6
    80006888:	ffffb097          	auipc	ra,0xffffb
    8000688c:	dfa080e7          	jalr	-518(ra) # 80001682 <uvmclear>
  stackbase = sp - PGSIZE;
    80006890:	7afd                	lui	s5,0xfffff
    80006892:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80006894:	df043783          	ld	a5,-528(s0)
    80006898:	6388                	ld	a0,0(a5)
    8000689a:	c925                	beqz	a0,8000690a <exec+0x222>
    8000689c:	e9040993          	addi	s3,s0,-368
    800068a0:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800068a4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800068a6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800068a8:	ffffa097          	auipc	ra,0xffffa
    800068ac:	59e080e7          	jalr	1438(ra) # 80000e46 <strlen>
    800068b0:	0015079b          	addiw	a5,a0,1
    800068b4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800068b8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800068bc:	13596363          	bltu	s2,s5,800069e2 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800068c0:	df043d83          	ld	s11,-528(s0)
    800068c4:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800068c8:	8552                	mv	a0,s4
    800068ca:	ffffa097          	auipc	ra,0xffffa
    800068ce:	57c080e7          	jalr	1404(ra) # 80000e46 <strlen>
    800068d2:	0015069b          	addiw	a3,a0,1
    800068d6:	8652                	mv	a2,s4
    800068d8:	85ca                	mv	a1,s2
    800068da:	855a                	mv	a0,s6
    800068dc:	ffffb097          	auipc	ra,0xffffb
    800068e0:	dd8080e7          	jalr	-552(ra) # 800016b4 <copyout>
    800068e4:	10054363          	bltz	a0,800069ea <exec+0x302>
    ustack[argc] = sp;
    800068e8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800068ec:	0485                	addi	s1,s1,1
    800068ee:	008d8793          	addi	a5,s11,8
    800068f2:	def43823          	sd	a5,-528(s0)
    800068f6:	008db503          	ld	a0,8(s11)
    800068fa:	c911                	beqz	a0,8000690e <exec+0x226>
    if(argc >= MAXARG)
    800068fc:	09a1                	addi	s3,s3,8
    800068fe:	fb3c95e3          	bne	s9,s3,800068a8 <exec+0x1c0>
  sz = sz1;
    80006902:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80006906:	4a81                	li	s5,0
    80006908:	a84d                	j	800069ba <exec+0x2d2>
  sp = sz;
    8000690a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000690c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000690e:	00349793          	slli	a5,s1,0x3
    80006912:	f9078793          	addi	a5,a5,-112
    80006916:	97a2                	add	a5,a5,s0
    80006918:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000691c:	00148693          	addi	a3,s1,1
    80006920:	068e                	slli	a3,a3,0x3
    80006922:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80006926:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000692a:	01597663          	bgeu	s2,s5,80006936 <exec+0x24e>
  sz = sz1;
    8000692e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80006932:	4a81                	li	s5,0
    80006934:	a059                	j	800069ba <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80006936:	e9040613          	addi	a2,s0,-368
    8000693a:	85ca                	mv	a1,s2
    8000693c:	855a                	mv	a0,s6
    8000693e:	ffffb097          	auipc	ra,0xffffb
    80006942:	d76080e7          	jalr	-650(ra) # 800016b4 <copyout>
    80006946:	0a054663          	bltz	a0,800069f2 <exec+0x30a>
  p->trapframe->a1 = sp;
    8000694a:	060bb783          	ld	a5,96(s7)
    8000694e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80006952:	de843783          	ld	a5,-536(s0)
    80006956:	0007c703          	lbu	a4,0(a5)
    8000695a:	cf11                	beqz	a4,80006976 <exec+0x28e>
    8000695c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000695e:	02f00693          	li	a3,47
    80006962:	a039                	j	80006970 <exec+0x288>
      last = s+1;
    80006964:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80006968:	0785                	addi	a5,a5,1
    8000696a:	fff7c703          	lbu	a4,-1(a5)
    8000696e:	c701                	beqz	a4,80006976 <exec+0x28e>
    if(*s == '/')
    80006970:	fed71ce3          	bne	a4,a3,80006968 <exec+0x280>
    80006974:	bfc5                	j	80006964 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80006976:	4641                	li	a2,16
    80006978:	de843583          	ld	a1,-536(s0)
    8000697c:	160b8513          	addi	a0,s7,352
    80006980:	ffffa097          	auipc	ra,0xffffa
    80006984:	494080e7          	jalr	1172(ra) # 80000e14 <safestrcpy>
  oldpagetable = p->pagetable;
    80006988:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    8000698c:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80006990:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80006994:	060bb783          	ld	a5,96(s7)
    80006998:	e6843703          	ld	a4,-408(s0)
    8000699c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000699e:	060bb783          	ld	a5,96(s7)
    800069a2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800069a6:	85ea                	mv	a1,s10
    800069a8:	ffffb097          	auipc	ra,0xffffb
    800069ac:	1e0080e7          	jalr	480(ra) # 80001b88 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800069b0:	0004851b          	sext.w	a0,s1
    800069b4:	bbc1                	j	80006784 <exec+0x9c>
    800069b6:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800069ba:	df843583          	ld	a1,-520(s0)
    800069be:	855a                	mv	a0,s6
    800069c0:	ffffb097          	auipc	ra,0xffffb
    800069c4:	1c8080e7          	jalr	456(ra) # 80001b88 <proc_freepagetable>
  if(ip){
    800069c8:	da0a94e3          	bnez	s5,80006770 <exec+0x88>
  return -1;
    800069cc:	557d                	li	a0,-1
    800069ce:	bb5d                	j	80006784 <exec+0x9c>
    800069d0:	de943c23          	sd	s1,-520(s0)
    800069d4:	b7dd                	j	800069ba <exec+0x2d2>
    800069d6:	de943c23          	sd	s1,-520(s0)
    800069da:	b7c5                	j	800069ba <exec+0x2d2>
    800069dc:	de943c23          	sd	s1,-520(s0)
    800069e0:	bfe9                	j	800069ba <exec+0x2d2>
  sz = sz1;
    800069e2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800069e6:	4a81                	li	s5,0
    800069e8:	bfc9                	j	800069ba <exec+0x2d2>
  sz = sz1;
    800069ea:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800069ee:	4a81                	li	s5,0
    800069f0:	b7e9                	j	800069ba <exec+0x2d2>
  sz = sz1;
    800069f2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800069f6:	4a81                	li	s5,0
    800069f8:	b7c9                	j	800069ba <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800069fa:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800069fe:	e0843783          	ld	a5,-504(s0)
    80006a02:	0017869b          	addiw	a3,a5,1
    80006a06:	e0d43423          	sd	a3,-504(s0)
    80006a0a:	e0043783          	ld	a5,-512(s0)
    80006a0e:	0387879b          	addiw	a5,a5,56
    80006a12:	e8845703          	lhu	a4,-376(s0)
    80006a16:	e2e6d3e3          	bge	a3,a4,8000683c <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006a1a:	2781                	sext.w	a5,a5
    80006a1c:	e0f43023          	sd	a5,-512(s0)
    80006a20:	03800713          	li	a4,56
    80006a24:	86be                	mv	a3,a5
    80006a26:	e1840613          	addi	a2,s0,-488
    80006a2a:	4581                	li	a1,0
    80006a2c:	8556                	mv	a0,s5
    80006a2e:	fffff097          	auipc	ra,0xfffff
    80006a32:	a76080e7          	jalr	-1418(ra) # 800054a4 <readi>
    80006a36:	03800793          	li	a5,56
    80006a3a:	f6f51ee3          	bne	a0,a5,800069b6 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80006a3e:	e1842783          	lw	a5,-488(s0)
    80006a42:	4705                	li	a4,1
    80006a44:	fae79de3          	bne	a5,a4,800069fe <exec+0x316>
    if(ph.memsz < ph.filesz)
    80006a48:	e4043603          	ld	a2,-448(s0)
    80006a4c:	e3843783          	ld	a5,-456(s0)
    80006a50:	f8f660e3          	bltu	a2,a5,800069d0 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80006a54:	e2843783          	ld	a5,-472(s0)
    80006a58:	963e                	add	a2,a2,a5
    80006a5a:	f6f66ee3          	bltu	a2,a5,800069d6 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006a5e:	85a6                	mv	a1,s1
    80006a60:	855a                	mv	a0,s6
    80006a62:	ffffb097          	auipc	ra,0xffffb
    80006a66:	9fe080e7          	jalr	-1538(ra) # 80001460 <uvmalloc>
    80006a6a:	dea43c23          	sd	a0,-520(s0)
    80006a6e:	d53d                	beqz	a0,800069dc <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80006a70:	e2843c03          	ld	s8,-472(s0)
    80006a74:	de043783          	ld	a5,-544(s0)
    80006a78:	00fc77b3          	and	a5,s8,a5
    80006a7c:	ff9d                	bnez	a5,800069ba <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80006a7e:	e2042c83          	lw	s9,-480(s0)
    80006a82:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80006a86:	f60b8ae3          	beqz	s7,800069fa <exec+0x312>
    80006a8a:	89de                	mv	s3,s7
    80006a8c:	4481                	li	s1,0
    80006a8e:	b371                	j	8000681a <exec+0x132>

0000000080006a90 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006a90:	7179                	addi	sp,sp,-48
    80006a92:	f406                	sd	ra,40(sp)
    80006a94:	f022                	sd	s0,32(sp)
    80006a96:	ec26                	sd	s1,24(sp)
    80006a98:	e84a                	sd	s2,16(sp)
    80006a9a:	1800                	addi	s0,sp,48
    80006a9c:	892e                	mv	s2,a1
    80006a9e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80006aa0:	fdc40593          	addi	a1,s0,-36
    80006aa4:	ffffd097          	auipc	ra,0xffffd
    80006aa8:	302080e7          	jalr	770(ra) # 80003da6 <argint>
    80006aac:	04054063          	bltz	a0,80006aec <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006ab0:	fdc42703          	lw	a4,-36(s0)
    80006ab4:	47bd                	li	a5,15
    80006ab6:	02e7ed63          	bltu	a5,a4,80006af0 <argfd+0x60>
    80006aba:	ffffb097          	auipc	ra,0xffffb
    80006abe:	f36080e7          	jalr	-202(ra) # 800019f0 <myproc>
    80006ac2:	fdc42703          	lw	a4,-36(s0)
    80006ac6:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd601a>
    80006aca:	078e                	slli	a5,a5,0x3
    80006acc:	953e                	add	a0,a0,a5
    80006ace:	651c                	ld	a5,8(a0)
    80006ad0:	c395                	beqz	a5,80006af4 <argfd+0x64>
    return -1;
  if(pfd)
    80006ad2:	00090463          	beqz	s2,80006ada <argfd+0x4a>
    *pfd = fd;
    80006ad6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80006ada:	4501                	li	a0,0
  if(pf)
    80006adc:	c091                	beqz	s1,80006ae0 <argfd+0x50>
    *pf = f;
    80006ade:	e09c                	sd	a5,0(s1)
}
    80006ae0:	70a2                	ld	ra,40(sp)
    80006ae2:	7402                	ld	s0,32(sp)
    80006ae4:	64e2                	ld	s1,24(sp)
    80006ae6:	6942                	ld	s2,16(sp)
    80006ae8:	6145                	addi	sp,sp,48
    80006aea:	8082                	ret
    return -1;
    80006aec:	557d                	li	a0,-1
    80006aee:	bfcd                	j	80006ae0 <argfd+0x50>
    return -1;
    80006af0:	557d                	li	a0,-1
    80006af2:	b7fd                	j	80006ae0 <argfd+0x50>
    80006af4:	557d                	li	a0,-1
    80006af6:	b7ed                	j	80006ae0 <argfd+0x50>

0000000080006af8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006af8:	1101                	addi	sp,sp,-32
    80006afa:	ec06                	sd	ra,24(sp)
    80006afc:	e822                	sd	s0,16(sp)
    80006afe:	e426                	sd	s1,8(sp)
    80006b00:	1000                	addi	s0,sp,32
    80006b02:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80006b04:	ffffb097          	auipc	ra,0xffffb
    80006b08:	eec080e7          	jalr	-276(ra) # 800019f0 <myproc>
    80006b0c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006b0e:	0d850793          	addi	a5,a0,216
    80006b12:	4501                	li	a0,0
    80006b14:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80006b16:	6398                	ld	a4,0(a5)
    80006b18:	cb19                	beqz	a4,80006b2e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006b1a:	2505                	addiw	a0,a0,1
    80006b1c:	07a1                	addi	a5,a5,8
    80006b1e:	fed51ce3          	bne	a0,a3,80006b16 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80006b22:	557d                	li	a0,-1
}
    80006b24:	60e2                	ld	ra,24(sp)
    80006b26:	6442                	ld	s0,16(sp)
    80006b28:	64a2                	ld	s1,8(sp)
    80006b2a:	6105                	addi	sp,sp,32
    80006b2c:	8082                	ret
      p->ofile[fd] = f;
    80006b2e:	01a50793          	addi	a5,a0,26
    80006b32:	078e                	slli	a5,a5,0x3
    80006b34:	963e                	add	a2,a2,a5
    80006b36:	e604                	sd	s1,8(a2)
      return fd;
    80006b38:	b7f5                	j	80006b24 <fdalloc+0x2c>

0000000080006b3a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80006b3a:	715d                	addi	sp,sp,-80
    80006b3c:	e486                	sd	ra,72(sp)
    80006b3e:	e0a2                	sd	s0,64(sp)
    80006b40:	fc26                	sd	s1,56(sp)
    80006b42:	f84a                	sd	s2,48(sp)
    80006b44:	f44e                	sd	s3,40(sp)
    80006b46:	f052                	sd	s4,32(sp)
    80006b48:	ec56                	sd	s5,24(sp)
    80006b4a:	0880                	addi	s0,sp,80
    80006b4c:	89ae                	mv	s3,a1
    80006b4e:	8ab2                	mv	s5,a2
    80006b50:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006b52:	fb040593          	addi	a1,s0,-80
    80006b56:	fffff097          	auipc	ra,0xfffff
    80006b5a:	e74080e7          	jalr	-396(ra) # 800059ca <nameiparent>
    80006b5e:	892a                	mv	s2,a0
    80006b60:	12050e63          	beqz	a0,80006c9c <create+0x162>
    return 0;

  ilock(dp);
    80006b64:	ffffe097          	auipc	ra,0xffffe
    80006b68:	68c080e7          	jalr	1676(ra) # 800051f0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80006b6c:	4601                	li	a2,0
    80006b6e:	fb040593          	addi	a1,s0,-80
    80006b72:	854a                	mv	a0,s2
    80006b74:	fffff097          	auipc	ra,0xfffff
    80006b78:	b60080e7          	jalr	-1184(ra) # 800056d4 <dirlookup>
    80006b7c:	84aa                	mv	s1,a0
    80006b7e:	c921                	beqz	a0,80006bce <create+0x94>
    iunlockput(dp);
    80006b80:	854a                	mv	a0,s2
    80006b82:	fffff097          	auipc	ra,0xfffff
    80006b86:	8d0080e7          	jalr	-1840(ra) # 80005452 <iunlockput>
    ilock(ip);
    80006b8a:	8526                	mv	a0,s1
    80006b8c:	ffffe097          	auipc	ra,0xffffe
    80006b90:	664080e7          	jalr	1636(ra) # 800051f0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006b94:	2981                	sext.w	s3,s3
    80006b96:	4789                	li	a5,2
    80006b98:	02f99463          	bne	s3,a5,80006bc0 <create+0x86>
    80006b9c:	0444d783          	lhu	a5,68(s1)
    80006ba0:	37f9                	addiw	a5,a5,-2
    80006ba2:	17c2                	slli	a5,a5,0x30
    80006ba4:	93c1                	srli	a5,a5,0x30
    80006ba6:	4705                	li	a4,1
    80006ba8:	00f76c63          	bltu	a4,a5,80006bc0 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006bac:	8526                	mv	a0,s1
    80006bae:	60a6                	ld	ra,72(sp)
    80006bb0:	6406                	ld	s0,64(sp)
    80006bb2:	74e2                	ld	s1,56(sp)
    80006bb4:	7942                	ld	s2,48(sp)
    80006bb6:	79a2                	ld	s3,40(sp)
    80006bb8:	7a02                	ld	s4,32(sp)
    80006bba:	6ae2                	ld	s5,24(sp)
    80006bbc:	6161                	addi	sp,sp,80
    80006bbe:	8082                	ret
    iunlockput(ip);
    80006bc0:	8526                	mv	a0,s1
    80006bc2:	fffff097          	auipc	ra,0xfffff
    80006bc6:	890080e7          	jalr	-1904(ra) # 80005452 <iunlockput>
    return 0;
    80006bca:	4481                	li	s1,0
    80006bcc:	b7c5                	j	80006bac <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006bce:	85ce                	mv	a1,s3
    80006bd0:	00092503          	lw	a0,0(s2)
    80006bd4:	ffffe097          	auipc	ra,0xffffe
    80006bd8:	482080e7          	jalr	1154(ra) # 80005056 <ialloc>
    80006bdc:	84aa                	mv	s1,a0
    80006bde:	c521                	beqz	a0,80006c26 <create+0xec>
  ilock(ip);
    80006be0:	ffffe097          	auipc	ra,0xffffe
    80006be4:	610080e7          	jalr	1552(ra) # 800051f0 <ilock>
  ip->major = major;
    80006be8:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006bec:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006bf0:	4a05                	li	s4,1
    80006bf2:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006bf6:	8526                	mv	a0,s1
    80006bf8:	ffffe097          	auipc	ra,0xffffe
    80006bfc:	52c080e7          	jalr	1324(ra) # 80005124 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006c00:	2981                	sext.w	s3,s3
    80006c02:	03498a63          	beq	s3,s4,80006c36 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006c06:	40d0                	lw	a2,4(s1)
    80006c08:	fb040593          	addi	a1,s0,-80
    80006c0c:	854a                	mv	a0,s2
    80006c0e:	fffff097          	auipc	ra,0xfffff
    80006c12:	cdc080e7          	jalr	-804(ra) # 800058ea <dirlink>
    80006c16:	06054b63          	bltz	a0,80006c8c <create+0x152>
  iunlockput(dp);
    80006c1a:	854a                	mv	a0,s2
    80006c1c:	fffff097          	auipc	ra,0xfffff
    80006c20:	836080e7          	jalr	-1994(ra) # 80005452 <iunlockput>
  return ip;
    80006c24:	b761                	j	80006bac <create+0x72>
    panic("create: ialloc");
    80006c26:	00003517          	auipc	a0,0x3
    80006c2a:	e5250513          	addi	a0,a0,-430 # 80009a78 <syscalls+0x418>
    80006c2e:	ffffa097          	auipc	ra,0xffffa
    80006c32:	90a080e7          	jalr	-1782(ra) # 80000538 <panic>
    dp->nlink++;  // for ".."
    80006c36:	04a95783          	lhu	a5,74(s2)
    80006c3a:	2785                	addiw	a5,a5,1
    80006c3c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006c40:	854a                	mv	a0,s2
    80006c42:	ffffe097          	auipc	ra,0xffffe
    80006c46:	4e2080e7          	jalr	1250(ra) # 80005124 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006c4a:	40d0                	lw	a2,4(s1)
    80006c4c:	00003597          	auipc	a1,0x3
    80006c50:	e3c58593          	addi	a1,a1,-452 # 80009a88 <syscalls+0x428>
    80006c54:	8526                	mv	a0,s1
    80006c56:	fffff097          	auipc	ra,0xfffff
    80006c5a:	c94080e7          	jalr	-876(ra) # 800058ea <dirlink>
    80006c5e:	00054f63          	bltz	a0,80006c7c <create+0x142>
    80006c62:	00492603          	lw	a2,4(s2)
    80006c66:	00003597          	auipc	a1,0x3
    80006c6a:	e2a58593          	addi	a1,a1,-470 # 80009a90 <syscalls+0x430>
    80006c6e:	8526                	mv	a0,s1
    80006c70:	fffff097          	auipc	ra,0xfffff
    80006c74:	c7a080e7          	jalr	-902(ra) # 800058ea <dirlink>
    80006c78:	f80557e3          	bgez	a0,80006c06 <create+0xcc>
      panic("create dots");
    80006c7c:	00003517          	auipc	a0,0x3
    80006c80:	e1c50513          	addi	a0,a0,-484 # 80009a98 <syscalls+0x438>
    80006c84:	ffffa097          	auipc	ra,0xffffa
    80006c88:	8b4080e7          	jalr	-1868(ra) # 80000538 <panic>
    panic("create: dirlink");
    80006c8c:	00003517          	auipc	a0,0x3
    80006c90:	e1c50513          	addi	a0,a0,-484 # 80009aa8 <syscalls+0x448>
    80006c94:	ffffa097          	auipc	ra,0xffffa
    80006c98:	8a4080e7          	jalr	-1884(ra) # 80000538 <panic>
    return 0;
    80006c9c:	84aa                	mv	s1,a0
    80006c9e:	b739                	j	80006bac <create+0x72>

0000000080006ca0 <sys_dup>:
{
    80006ca0:	7179                	addi	sp,sp,-48
    80006ca2:	f406                	sd	ra,40(sp)
    80006ca4:	f022                	sd	s0,32(sp)
    80006ca6:	ec26                	sd	s1,24(sp)
    80006ca8:	e84a                	sd	s2,16(sp)
    80006caa:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006cac:	fd840613          	addi	a2,s0,-40
    80006cb0:	4581                	li	a1,0
    80006cb2:	4501                	li	a0,0
    80006cb4:	00000097          	auipc	ra,0x0
    80006cb8:	ddc080e7          	jalr	-548(ra) # 80006a90 <argfd>
    return -1;
    80006cbc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006cbe:	02054363          	bltz	a0,80006ce4 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80006cc2:	fd843903          	ld	s2,-40(s0)
    80006cc6:	854a                	mv	a0,s2
    80006cc8:	00000097          	auipc	ra,0x0
    80006ccc:	e30080e7          	jalr	-464(ra) # 80006af8 <fdalloc>
    80006cd0:	84aa                	mv	s1,a0
    return -1;
    80006cd2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006cd4:	00054863          	bltz	a0,80006ce4 <sys_dup+0x44>
  filedup(f);
    80006cd8:	854a                	mv	a0,s2
    80006cda:	fffff097          	auipc	ra,0xfffff
    80006cde:	368080e7          	jalr	872(ra) # 80006042 <filedup>
  return fd;
    80006ce2:	87a6                	mv	a5,s1
}
    80006ce4:	853e                	mv	a0,a5
    80006ce6:	70a2                	ld	ra,40(sp)
    80006ce8:	7402                	ld	s0,32(sp)
    80006cea:	64e2                	ld	s1,24(sp)
    80006cec:	6942                	ld	s2,16(sp)
    80006cee:	6145                	addi	sp,sp,48
    80006cf0:	8082                	ret

0000000080006cf2 <sys_read>:
{
    80006cf2:	7179                	addi	sp,sp,-48
    80006cf4:	f406                	sd	ra,40(sp)
    80006cf6:	f022                	sd	s0,32(sp)
    80006cf8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006cfa:	fe840613          	addi	a2,s0,-24
    80006cfe:	4581                	li	a1,0
    80006d00:	4501                	li	a0,0
    80006d02:	00000097          	auipc	ra,0x0
    80006d06:	d8e080e7          	jalr	-626(ra) # 80006a90 <argfd>
    return -1;
    80006d0a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d0c:	04054163          	bltz	a0,80006d4e <sys_read+0x5c>
    80006d10:	fe440593          	addi	a1,s0,-28
    80006d14:	4509                	li	a0,2
    80006d16:	ffffd097          	auipc	ra,0xffffd
    80006d1a:	090080e7          	jalr	144(ra) # 80003da6 <argint>
    return -1;
    80006d1e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d20:	02054763          	bltz	a0,80006d4e <sys_read+0x5c>
    80006d24:	fd840593          	addi	a1,s0,-40
    80006d28:	4505                	li	a0,1
    80006d2a:	ffffd097          	auipc	ra,0xffffd
    80006d2e:	09e080e7          	jalr	158(ra) # 80003dc8 <argaddr>
    return -1;
    80006d32:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d34:	00054d63          	bltz	a0,80006d4e <sys_read+0x5c>
  return fileread(f, p, n);
    80006d38:	fe442603          	lw	a2,-28(s0)
    80006d3c:	fd843583          	ld	a1,-40(s0)
    80006d40:	fe843503          	ld	a0,-24(s0)
    80006d44:	fffff097          	auipc	ra,0xfffff
    80006d48:	48a080e7          	jalr	1162(ra) # 800061ce <fileread>
    80006d4c:	87aa                	mv	a5,a0
}
    80006d4e:	853e                	mv	a0,a5
    80006d50:	70a2                	ld	ra,40(sp)
    80006d52:	7402                	ld	s0,32(sp)
    80006d54:	6145                	addi	sp,sp,48
    80006d56:	8082                	ret

0000000080006d58 <sys_write>:
{
    80006d58:	7179                	addi	sp,sp,-48
    80006d5a:	f406                	sd	ra,40(sp)
    80006d5c:	f022                	sd	s0,32(sp)
    80006d5e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d60:	fe840613          	addi	a2,s0,-24
    80006d64:	4581                	li	a1,0
    80006d66:	4501                	li	a0,0
    80006d68:	00000097          	auipc	ra,0x0
    80006d6c:	d28080e7          	jalr	-728(ra) # 80006a90 <argfd>
    return -1;
    80006d70:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d72:	04054163          	bltz	a0,80006db4 <sys_write+0x5c>
    80006d76:	fe440593          	addi	a1,s0,-28
    80006d7a:	4509                	li	a0,2
    80006d7c:	ffffd097          	auipc	ra,0xffffd
    80006d80:	02a080e7          	jalr	42(ra) # 80003da6 <argint>
    return -1;
    80006d84:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d86:	02054763          	bltz	a0,80006db4 <sys_write+0x5c>
    80006d8a:	fd840593          	addi	a1,s0,-40
    80006d8e:	4505                	li	a0,1
    80006d90:	ffffd097          	auipc	ra,0xffffd
    80006d94:	038080e7          	jalr	56(ra) # 80003dc8 <argaddr>
    return -1;
    80006d98:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006d9a:	00054d63          	bltz	a0,80006db4 <sys_write+0x5c>
  return filewrite(f, p, n);
    80006d9e:	fe442603          	lw	a2,-28(s0)
    80006da2:	fd843583          	ld	a1,-40(s0)
    80006da6:	fe843503          	ld	a0,-24(s0)
    80006daa:	fffff097          	auipc	ra,0xfffff
    80006dae:	4e6080e7          	jalr	1254(ra) # 80006290 <filewrite>
    80006db2:	87aa                	mv	a5,a0
}
    80006db4:	853e                	mv	a0,a5
    80006db6:	70a2                	ld	ra,40(sp)
    80006db8:	7402                	ld	s0,32(sp)
    80006dba:	6145                	addi	sp,sp,48
    80006dbc:	8082                	ret

0000000080006dbe <sys_close>:
{
    80006dbe:	1101                	addi	sp,sp,-32
    80006dc0:	ec06                	sd	ra,24(sp)
    80006dc2:	e822                	sd	s0,16(sp)
    80006dc4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80006dc6:	fe040613          	addi	a2,s0,-32
    80006dca:	fec40593          	addi	a1,s0,-20
    80006dce:	4501                	li	a0,0
    80006dd0:	00000097          	auipc	ra,0x0
    80006dd4:	cc0080e7          	jalr	-832(ra) # 80006a90 <argfd>
    return -1;
    80006dd8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006dda:	02054463          	bltz	a0,80006e02 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006dde:	ffffb097          	auipc	ra,0xffffb
    80006de2:	c12080e7          	jalr	-1006(ra) # 800019f0 <myproc>
    80006de6:	fec42783          	lw	a5,-20(s0)
    80006dea:	07e9                	addi	a5,a5,26
    80006dec:	078e                	slli	a5,a5,0x3
    80006dee:	953e                	add	a0,a0,a5
    80006df0:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80006df4:	fe043503          	ld	a0,-32(s0)
    80006df8:	fffff097          	auipc	ra,0xfffff
    80006dfc:	29c080e7          	jalr	668(ra) # 80006094 <fileclose>
  return 0;
    80006e00:	4781                	li	a5,0
}
    80006e02:	853e                	mv	a0,a5
    80006e04:	60e2                	ld	ra,24(sp)
    80006e06:	6442                	ld	s0,16(sp)
    80006e08:	6105                	addi	sp,sp,32
    80006e0a:	8082                	ret

0000000080006e0c <sys_fstat>:
{
    80006e0c:	1101                	addi	sp,sp,-32
    80006e0e:	ec06                	sd	ra,24(sp)
    80006e10:	e822                	sd	s0,16(sp)
    80006e12:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006e14:	fe840613          	addi	a2,s0,-24
    80006e18:	4581                	li	a1,0
    80006e1a:	4501                	li	a0,0
    80006e1c:	00000097          	auipc	ra,0x0
    80006e20:	c74080e7          	jalr	-908(ra) # 80006a90 <argfd>
    return -1;
    80006e24:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006e26:	02054563          	bltz	a0,80006e50 <sys_fstat+0x44>
    80006e2a:	fe040593          	addi	a1,s0,-32
    80006e2e:	4505                	li	a0,1
    80006e30:	ffffd097          	auipc	ra,0xffffd
    80006e34:	f98080e7          	jalr	-104(ra) # 80003dc8 <argaddr>
    return -1;
    80006e38:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006e3a:	00054b63          	bltz	a0,80006e50 <sys_fstat+0x44>
  return filestat(f, st);
    80006e3e:	fe043583          	ld	a1,-32(s0)
    80006e42:	fe843503          	ld	a0,-24(s0)
    80006e46:	fffff097          	auipc	ra,0xfffff
    80006e4a:	316080e7          	jalr	790(ra) # 8000615c <filestat>
    80006e4e:	87aa                	mv	a5,a0
}
    80006e50:	853e                	mv	a0,a5
    80006e52:	60e2                	ld	ra,24(sp)
    80006e54:	6442                	ld	s0,16(sp)
    80006e56:	6105                	addi	sp,sp,32
    80006e58:	8082                	ret

0000000080006e5a <sys_link>:
{
    80006e5a:	7169                	addi	sp,sp,-304
    80006e5c:	f606                	sd	ra,296(sp)
    80006e5e:	f222                	sd	s0,288(sp)
    80006e60:	ee26                	sd	s1,280(sp)
    80006e62:	ea4a                	sd	s2,272(sp)
    80006e64:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006e66:	08000613          	li	a2,128
    80006e6a:	ed040593          	addi	a1,s0,-304
    80006e6e:	4501                	li	a0,0
    80006e70:	ffffd097          	auipc	ra,0xffffd
    80006e74:	f7a080e7          	jalr	-134(ra) # 80003dea <argstr>
    return -1;
    80006e78:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006e7a:	10054e63          	bltz	a0,80006f96 <sys_link+0x13c>
    80006e7e:	08000613          	li	a2,128
    80006e82:	f5040593          	addi	a1,s0,-176
    80006e86:	4505                	li	a0,1
    80006e88:	ffffd097          	auipc	ra,0xffffd
    80006e8c:	f62080e7          	jalr	-158(ra) # 80003dea <argstr>
    return -1;
    80006e90:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006e92:	10054263          	bltz	a0,80006f96 <sys_link+0x13c>
  begin_op();
    80006e96:	fffff097          	auipc	ra,0xfffff
    80006e9a:	d36080e7          	jalr	-714(ra) # 80005bcc <begin_op>
  if((ip = namei(old)) == 0){
    80006e9e:	ed040513          	addi	a0,s0,-304
    80006ea2:	fffff097          	auipc	ra,0xfffff
    80006ea6:	b0a080e7          	jalr	-1270(ra) # 800059ac <namei>
    80006eaa:	84aa                	mv	s1,a0
    80006eac:	c551                	beqz	a0,80006f38 <sys_link+0xde>
  ilock(ip);
    80006eae:	ffffe097          	auipc	ra,0xffffe
    80006eb2:	342080e7          	jalr	834(ra) # 800051f0 <ilock>
  if(ip->type == T_DIR){
    80006eb6:	04449703          	lh	a4,68(s1)
    80006eba:	4785                	li	a5,1
    80006ebc:	08f70463          	beq	a4,a5,80006f44 <sys_link+0xea>
  ip->nlink++;
    80006ec0:	04a4d783          	lhu	a5,74(s1)
    80006ec4:	2785                	addiw	a5,a5,1
    80006ec6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006eca:	8526                	mv	a0,s1
    80006ecc:	ffffe097          	auipc	ra,0xffffe
    80006ed0:	258080e7          	jalr	600(ra) # 80005124 <iupdate>
  iunlock(ip);
    80006ed4:	8526                	mv	a0,s1
    80006ed6:	ffffe097          	auipc	ra,0xffffe
    80006eda:	3dc080e7          	jalr	988(ra) # 800052b2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006ede:	fd040593          	addi	a1,s0,-48
    80006ee2:	f5040513          	addi	a0,s0,-176
    80006ee6:	fffff097          	auipc	ra,0xfffff
    80006eea:	ae4080e7          	jalr	-1308(ra) # 800059ca <nameiparent>
    80006eee:	892a                	mv	s2,a0
    80006ef0:	c935                	beqz	a0,80006f64 <sys_link+0x10a>
  ilock(dp);
    80006ef2:	ffffe097          	auipc	ra,0xffffe
    80006ef6:	2fe080e7          	jalr	766(ra) # 800051f0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006efa:	00092703          	lw	a4,0(s2)
    80006efe:	409c                	lw	a5,0(s1)
    80006f00:	04f71d63          	bne	a4,a5,80006f5a <sys_link+0x100>
    80006f04:	40d0                	lw	a2,4(s1)
    80006f06:	fd040593          	addi	a1,s0,-48
    80006f0a:	854a                	mv	a0,s2
    80006f0c:	fffff097          	auipc	ra,0xfffff
    80006f10:	9de080e7          	jalr	-1570(ra) # 800058ea <dirlink>
    80006f14:	04054363          	bltz	a0,80006f5a <sys_link+0x100>
  iunlockput(dp);
    80006f18:	854a                	mv	a0,s2
    80006f1a:	ffffe097          	auipc	ra,0xffffe
    80006f1e:	538080e7          	jalr	1336(ra) # 80005452 <iunlockput>
  iput(ip);
    80006f22:	8526                	mv	a0,s1
    80006f24:	ffffe097          	auipc	ra,0xffffe
    80006f28:	486080e7          	jalr	1158(ra) # 800053aa <iput>
  end_op();
    80006f2c:	fffff097          	auipc	ra,0xfffff
    80006f30:	d1e080e7          	jalr	-738(ra) # 80005c4a <end_op>
  return 0;
    80006f34:	4781                	li	a5,0
    80006f36:	a085                	j	80006f96 <sys_link+0x13c>
    end_op();
    80006f38:	fffff097          	auipc	ra,0xfffff
    80006f3c:	d12080e7          	jalr	-750(ra) # 80005c4a <end_op>
    return -1;
    80006f40:	57fd                	li	a5,-1
    80006f42:	a891                	j	80006f96 <sys_link+0x13c>
    iunlockput(ip);
    80006f44:	8526                	mv	a0,s1
    80006f46:	ffffe097          	auipc	ra,0xffffe
    80006f4a:	50c080e7          	jalr	1292(ra) # 80005452 <iunlockput>
    end_op();
    80006f4e:	fffff097          	auipc	ra,0xfffff
    80006f52:	cfc080e7          	jalr	-772(ra) # 80005c4a <end_op>
    return -1;
    80006f56:	57fd                	li	a5,-1
    80006f58:	a83d                	j	80006f96 <sys_link+0x13c>
    iunlockput(dp);
    80006f5a:	854a                	mv	a0,s2
    80006f5c:	ffffe097          	auipc	ra,0xffffe
    80006f60:	4f6080e7          	jalr	1270(ra) # 80005452 <iunlockput>
  ilock(ip);
    80006f64:	8526                	mv	a0,s1
    80006f66:	ffffe097          	auipc	ra,0xffffe
    80006f6a:	28a080e7          	jalr	650(ra) # 800051f0 <ilock>
  ip->nlink--;
    80006f6e:	04a4d783          	lhu	a5,74(s1)
    80006f72:	37fd                	addiw	a5,a5,-1
    80006f74:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006f78:	8526                	mv	a0,s1
    80006f7a:	ffffe097          	auipc	ra,0xffffe
    80006f7e:	1aa080e7          	jalr	426(ra) # 80005124 <iupdate>
  iunlockput(ip);
    80006f82:	8526                	mv	a0,s1
    80006f84:	ffffe097          	auipc	ra,0xffffe
    80006f88:	4ce080e7          	jalr	1230(ra) # 80005452 <iunlockput>
  end_op();
    80006f8c:	fffff097          	auipc	ra,0xfffff
    80006f90:	cbe080e7          	jalr	-834(ra) # 80005c4a <end_op>
  return -1;
    80006f94:	57fd                	li	a5,-1
}
    80006f96:	853e                	mv	a0,a5
    80006f98:	70b2                	ld	ra,296(sp)
    80006f9a:	7412                	ld	s0,288(sp)
    80006f9c:	64f2                	ld	s1,280(sp)
    80006f9e:	6952                	ld	s2,272(sp)
    80006fa0:	6155                	addi	sp,sp,304
    80006fa2:	8082                	ret

0000000080006fa4 <sys_unlink>:
{
    80006fa4:	7151                	addi	sp,sp,-240
    80006fa6:	f586                	sd	ra,232(sp)
    80006fa8:	f1a2                	sd	s0,224(sp)
    80006faa:	eda6                	sd	s1,216(sp)
    80006fac:	e9ca                	sd	s2,208(sp)
    80006fae:	e5ce                	sd	s3,200(sp)
    80006fb0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006fb2:	08000613          	li	a2,128
    80006fb6:	f3040593          	addi	a1,s0,-208
    80006fba:	4501                	li	a0,0
    80006fbc:	ffffd097          	auipc	ra,0xffffd
    80006fc0:	e2e080e7          	jalr	-466(ra) # 80003dea <argstr>
    80006fc4:	18054163          	bltz	a0,80007146 <sys_unlink+0x1a2>
  begin_op();
    80006fc8:	fffff097          	auipc	ra,0xfffff
    80006fcc:	c04080e7          	jalr	-1020(ra) # 80005bcc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006fd0:	fb040593          	addi	a1,s0,-80
    80006fd4:	f3040513          	addi	a0,s0,-208
    80006fd8:	fffff097          	auipc	ra,0xfffff
    80006fdc:	9f2080e7          	jalr	-1550(ra) # 800059ca <nameiparent>
    80006fe0:	84aa                	mv	s1,a0
    80006fe2:	c979                	beqz	a0,800070b8 <sys_unlink+0x114>
  ilock(dp);
    80006fe4:	ffffe097          	auipc	ra,0xffffe
    80006fe8:	20c080e7          	jalr	524(ra) # 800051f0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006fec:	00003597          	auipc	a1,0x3
    80006ff0:	a9c58593          	addi	a1,a1,-1380 # 80009a88 <syscalls+0x428>
    80006ff4:	fb040513          	addi	a0,s0,-80
    80006ff8:	ffffe097          	auipc	ra,0xffffe
    80006ffc:	6c2080e7          	jalr	1730(ra) # 800056ba <namecmp>
    80007000:	14050a63          	beqz	a0,80007154 <sys_unlink+0x1b0>
    80007004:	00003597          	auipc	a1,0x3
    80007008:	a8c58593          	addi	a1,a1,-1396 # 80009a90 <syscalls+0x430>
    8000700c:	fb040513          	addi	a0,s0,-80
    80007010:	ffffe097          	auipc	ra,0xffffe
    80007014:	6aa080e7          	jalr	1706(ra) # 800056ba <namecmp>
    80007018:	12050e63          	beqz	a0,80007154 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000701c:	f2c40613          	addi	a2,s0,-212
    80007020:	fb040593          	addi	a1,s0,-80
    80007024:	8526                	mv	a0,s1
    80007026:	ffffe097          	auipc	ra,0xffffe
    8000702a:	6ae080e7          	jalr	1710(ra) # 800056d4 <dirlookup>
    8000702e:	892a                	mv	s2,a0
    80007030:	12050263          	beqz	a0,80007154 <sys_unlink+0x1b0>
  ilock(ip);
    80007034:	ffffe097          	auipc	ra,0xffffe
    80007038:	1bc080e7          	jalr	444(ra) # 800051f0 <ilock>
  if(ip->nlink < 1)
    8000703c:	04a91783          	lh	a5,74(s2)
    80007040:	08f05263          	blez	a5,800070c4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80007044:	04491703          	lh	a4,68(s2)
    80007048:	4785                	li	a5,1
    8000704a:	08f70563          	beq	a4,a5,800070d4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000704e:	4641                	li	a2,16
    80007050:	4581                	li	a1,0
    80007052:	fc040513          	addi	a0,s0,-64
    80007056:	ffffa097          	auipc	ra,0xffffa
    8000705a:	c74080e7          	jalr	-908(ra) # 80000cca <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000705e:	4741                	li	a4,16
    80007060:	f2c42683          	lw	a3,-212(s0)
    80007064:	fc040613          	addi	a2,s0,-64
    80007068:	4581                	li	a1,0
    8000706a:	8526                	mv	a0,s1
    8000706c:	ffffe097          	auipc	ra,0xffffe
    80007070:	530080e7          	jalr	1328(ra) # 8000559c <writei>
    80007074:	47c1                	li	a5,16
    80007076:	0af51563          	bne	a0,a5,80007120 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000707a:	04491703          	lh	a4,68(s2)
    8000707e:	4785                	li	a5,1
    80007080:	0af70863          	beq	a4,a5,80007130 <sys_unlink+0x18c>
  iunlockput(dp);
    80007084:	8526                	mv	a0,s1
    80007086:	ffffe097          	auipc	ra,0xffffe
    8000708a:	3cc080e7          	jalr	972(ra) # 80005452 <iunlockput>
  ip->nlink--;
    8000708e:	04a95783          	lhu	a5,74(s2)
    80007092:	37fd                	addiw	a5,a5,-1
    80007094:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80007098:	854a                	mv	a0,s2
    8000709a:	ffffe097          	auipc	ra,0xffffe
    8000709e:	08a080e7          	jalr	138(ra) # 80005124 <iupdate>
  iunlockput(ip);
    800070a2:	854a                	mv	a0,s2
    800070a4:	ffffe097          	auipc	ra,0xffffe
    800070a8:	3ae080e7          	jalr	942(ra) # 80005452 <iunlockput>
  end_op();
    800070ac:	fffff097          	auipc	ra,0xfffff
    800070b0:	b9e080e7          	jalr	-1122(ra) # 80005c4a <end_op>
  return 0;
    800070b4:	4501                	li	a0,0
    800070b6:	a84d                	j	80007168 <sys_unlink+0x1c4>
    end_op();
    800070b8:	fffff097          	auipc	ra,0xfffff
    800070bc:	b92080e7          	jalr	-1134(ra) # 80005c4a <end_op>
    return -1;
    800070c0:	557d                	li	a0,-1
    800070c2:	a05d                	j	80007168 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800070c4:	00003517          	auipc	a0,0x3
    800070c8:	9f450513          	addi	a0,a0,-1548 # 80009ab8 <syscalls+0x458>
    800070cc:	ffff9097          	auipc	ra,0xffff9
    800070d0:	46c080e7          	jalr	1132(ra) # 80000538 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800070d4:	04c92703          	lw	a4,76(s2)
    800070d8:	02000793          	li	a5,32
    800070dc:	f6e7f9e3          	bgeu	a5,a4,8000704e <sys_unlink+0xaa>
    800070e0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800070e4:	4741                	li	a4,16
    800070e6:	86ce                	mv	a3,s3
    800070e8:	f1840613          	addi	a2,s0,-232
    800070ec:	4581                	li	a1,0
    800070ee:	854a                	mv	a0,s2
    800070f0:	ffffe097          	auipc	ra,0xffffe
    800070f4:	3b4080e7          	jalr	948(ra) # 800054a4 <readi>
    800070f8:	47c1                	li	a5,16
    800070fa:	00f51b63          	bne	a0,a5,80007110 <sys_unlink+0x16c>
    if(de.inum != 0)
    800070fe:	f1845783          	lhu	a5,-232(s0)
    80007102:	e7a1                	bnez	a5,8000714a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80007104:	29c1                	addiw	s3,s3,16
    80007106:	04c92783          	lw	a5,76(s2)
    8000710a:	fcf9ede3          	bltu	s3,a5,800070e4 <sys_unlink+0x140>
    8000710e:	b781                	j	8000704e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80007110:	00003517          	auipc	a0,0x3
    80007114:	9c050513          	addi	a0,a0,-1600 # 80009ad0 <syscalls+0x470>
    80007118:	ffff9097          	auipc	ra,0xffff9
    8000711c:	420080e7          	jalr	1056(ra) # 80000538 <panic>
    panic("unlink: writei");
    80007120:	00003517          	auipc	a0,0x3
    80007124:	9c850513          	addi	a0,a0,-1592 # 80009ae8 <syscalls+0x488>
    80007128:	ffff9097          	auipc	ra,0xffff9
    8000712c:	410080e7          	jalr	1040(ra) # 80000538 <panic>
    dp->nlink--;
    80007130:	04a4d783          	lhu	a5,74(s1)
    80007134:	37fd                	addiw	a5,a5,-1
    80007136:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000713a:	8526                	mv	a0,s1
    8000713c:	ffffe097          	auipc	ra,0xffffe
    80007140:	fe8080e7          	jalr	-24(ra) # 80005124 <iupdate>
    80007144:	b781                	j	80007084 <sys_unlink+0xe0>
    return -1;
    80007146:	557d                	li	a0,-1
    80007148:	a005                	j	80007168 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000714a:	854a                	mv	a0,s2
    8000714c:	ffffe097          	auipc	ra,0xffffe
    80007150:	306080e7          	jalr	774(ra) # 80005452 <iunlockput>
  iunlockput(dp);
    80007154:	8526                	mv	a0,s1
    80007156:	ffffe097          	auipc	ra,0xffffe
    8000715a:	2fc080e7          	jalr	764(ra) # 80005452 <iunlockput>
  end_op();
    8000715e:	fffff097          	auipc	ra,0xfffff
    80007162:	aec080e7          	jalr	-1300(ra) # 80005c4a <end_op>
  return -1;
    80007166:	557d                	li	a0,-1
}
    80007168:	70ae                	ld	ra,232(sp)
    8000716a:	740e                	ld	s0,224(sp)
    8000716c:	64ee                	ld	s1,216(sp)
    8000716e:	694e                	ld	s2,208(sp)
    80007170:	69ae                	ld	s3,200(sp)
    80007172:	616d                	addi	sp,sp,240
    80007174:	8082                	ret

0000000080007176 <sys_open>:

uint64
sys_open(void)
{
    80007176:	7131                	addi	sp,sp,-192
    80007178:	fd06                	sd	ra,184(sp)
    8000717a:	f922                	sd	s0,176(sp)
    8000717c:	f526                	sd	s1,168(sp)
    8000717e:	f14a                	sd	s2,160(sp)
    80007180:	ed4e                	sd	s3,152(sp)
    80007182:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80007184:	08000613          	li	a2,128
    80007188:	f5040593          	addi	a1,s0,-176
    8000718c:	4501                	li	a0,0
    8000718e:	ffffd097          	auipc	ra,0xffffd
    80007192:	c5c080e7          	jalr	-932(ra) # 80003dea <argstr>
    return -1;
    80007196:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80007198:	0c054163          	bltz	a0,8000725a <sys_open+0xe4>
    8000719c:	f4c40593          	addi	a1,s0,-180
    800071a0:	4505                	li	a0,1
    800071a2:	ffffd097          	auipc	ra,0xffffd
    800071a6:	c04080e7          	jalr	-1020(ra) # 80003da6 <argint>
    800071aa:	0a054863          	bltz	a0,8000725a <sys_open+0xe4>

  begin_op();
    800071ae:	fffff097          	auipc	ra,0xfffff
    800071b2:	a1e080e7          	jalr	-1506(ra) # 80005bcc <begin_op>

  if(omode & O_CREATE){
    800071b6:	f4c42783          	lw	a5,-180(s0)
    800071ba:	2007f793          	andi	a5,a5,512
    800071be:	cbdd                	beqz	a5,80007274 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800071c0:	4681                	li	a3,0
    800071c2:	4601                	li	a2,0
    800071c4:	4589                	li	a1,2
    800071c6:	f5040513          	addi	a0,s0,-176
    800071ca:	00000097          	auipc	ra,0x0
    800071ce:	970080e7          	jalr	-1680(ra) # 80006b3a <create>
    800071d2:	892a                	mv	s2,a0
    if(ip == 0){
    800071d4:	c959                	beqz	a0,8000726a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800071d6:	04491703          	lh	a4,68(s2)
    800071da:	478d                	li	a5,3
    800071dc:	00f71763          	bne	a4,a5,800071ea <sys_open+0x74>
    800071e0:	04695703          	lhu	a4,70(s2)
    800071e4:	47a5                	li	a5,9
    800071e6:	0ce7ec63          	bltu	a5,a4,800072be <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800071ea:	fffff097          	auipc	ra,0xfffff
    800071ee:	dee080e7          	jalr	-530(ra) # 80005fd8 <filealloc>
    800071f2:	89aa                	mv	s3,a0
    800071f4:	10050263          	beqz	a0,800072f8 <sys_open+0x182>
    800071f8:	00000097          	auipc	ra,0x0
    800071fc:	900080e7          	jalr	-1792(ra) # 80006af8 <fdalloc>
    80007200:	84aa                	mv	s1,a0
    80007202:	0e054663          	bltz	a0,800072ee <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80007206:	04491703          	lh	a4,68(s2)
    8000720a:	478d                	li	a5,3
    8000720c:	0cf70463          	beq	a4,a5,800072d4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80007210:	4789                	li	a5,2
    80007212:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80007216:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000721a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000721e:	f4c42783          	lw	a5,-180(s0)
    80007222:	0017c713          	xori	a4,a5,1
    80007226:	8b05                	andi	a4,a4,1
    80007228:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000722c:	0037f713          	andi	a4,a5,3
    80007230:	00e03733          	snez	a4,a4
    80007234:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80007238:	4007f793          	andi	a5,a5,1024
    8000723c:	c791                	beqz	a5,80007248 <sys_open+0xd2>
    8000723e:	04491703          	lh	a4,68(s2)
    80007242:	4789                	li	a5,2
    80007244:	08f70f63          	beq	a4,a5,800072e2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80007248:	854a                	mv	a0,s2
    8000724a:	ffffe097          	auipc	ra,0xffffe
    8000724e:	068080e7          	jalr	104(ra) # 800052b2 <iunlock>
  end_op();
    80007252:	fffff097          	auipc	ra,0xfffff
    80007256:	9f8080e7          	jalr	-1544(ra) # 80005c4a <end_op>

  return fd;
}
    8000725a:	8526                	mv	a0,s1
    8000725c:	70ea                	ld	ra,184(sp)
    8000725e:	744a                	ld	s0,176(sp)
    80007260:	74aa                	ld	s1,168(sp)
    80007262:	790a                	ld	s2,160(sp)
    80007264:	69ea                	ld	s3,152(sp)
    80007266:	6129                	addi	sp,sp,192
    80007268:	8082                	ret
      end_op();
    8000726a:	fffff097          	auipc	ra,0xfffff
    8000726e:	9e0080e7          	jalr	-1568(ra) # 80005c4a <end_op>
      return -1;
    80007272:	b7e5                	j	8000725a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80007274:	f5040513          	addi	a0,s0,-176
    80007278:	ffffe097          	auipc	ra,0xffffe
    8000727c:	734080e7          	jalr	1844(ra) # 800059ac <namei>
    80007280:	892a                	mv	s2,a0
    80007282:	c905                	beqz	a0,800072b2 <sys_open+0x13c>
    ilock(ip);
    80007284:	ffffe097          	auipc	ra,0xffffe
    80007288:	f6c080e7          	jalr	-148(ra) # 800051f0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000728c:	04491703          	lh	a4,68(s2)
    80007290:	4785                	li	a5,1
    80007292:	f4f712e3          	bne	a4,a5,800071d6 <sys_open+0x60>
    80007296:	f4c42783          	lw	a5,-180(s0)
    8000729a:	dba1                	beqz	a5,800071ea <sys_open+0x74>
      iunlockput(ip);
    8000729c:	854a                	mv	a0,s2
    8000729e:	ffffe097          	auipc	ra,0xffffe
    800072a2:	1b4080e7          	jalr	436(ra) # 80005452 <iunlockput>
      end_op();
    800072a6:	fffff097          	auipc	ra,0xfffff
    800072aa:	9a4080e7          	jalr	-1628(ra) # 80005c4a <end_op>
      return -1;
    800072ae:	54fd                	li	s1,-1
    800072b0:	b76d                	j	8000725a <sys_open+0xe4>
      end_op();
    800072b2:	fffff097          	auipc	ra,0xfffff
    800072b6:	998080e7          	jalr	-1640(ra) # 80005c4a <end_op>
      return -1;
    800072ba:	54fd                	li	s1,-1
    800072bc:	bf79                	j	8000725a <sys_open+0xe4>
    iunlockput(ip);
    800072be:	854a                	mv	a0,s2
    800072c0:	ffffe097          	auipc	ra,0xffffe
    800072c4:	192080e7          	jalr	402(ra) # 80005452 <iunlockput>
    end_op();
    800072c8:	fffff097          	auipc	ra,0xfffff
    800072cc:	982080e7          	jalr	-1662(ra) # 80005c4a <end_op>
    return -1;
    800072d0:	54fd                	li	s1,-1
    800072d2:	b761                	j	8000725a <sys_open+0xe4>
    f->type = FD_DEVICE;
    800072d4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800072d8:	04691783          	lh	a5,70(s2)
    800072dc:	02f99223          	sh	a5,36(s3)
    800072e0:	bf2d                	j	8000721a <sys_open+0xa4>
    itrunc(ip);
    800072e2:	854a                	mv	a0,s2
    800072e4:	ffffe097          	auipc	ra,0xffffe
    800072e8:	01a080e7          	jalr	26(ra) # 800052fe <itrunc>
    800072ec:	bfb1                	j	80007248 <sys_open+0xd2>
      fileclose(f);
    800072ee:	854e                	mv	a0,s3
    800072f0:	fffff097          	auipc	ra,0xfffff
    800072f4:	da4080e7          	jalr	-604(ra) # 80006094 <fileclose>
    iunlockput(ip);
    800072f8:	854a                	mv	a0,s2
    800072fa:	ffffe097          	auipc	ra,0xffffe
    800072fe:	158080e7          	jalr	344(ra) # 80005452 <iunlockput>
    end_op();
    80007302:	fffff097          	auipc	ra,0xfffff
    80007306:	948080e7          	jalr	-1720(ra) # 80005c4a <end_op>
    return -1;
    8000730a:	54fd                	li	s1,-1
    8000730c:	b7b9                	j	8000725a <sys_open+0xe4>

000000008000730e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000730e:	7175                	addi	sp,sp,-144
    80007310:	e506                	sd	ra,136(sp)
    80007312:	e122                	sd	s0,128(sp)
    80007314:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80007316:	fffff097          	auipc	ra,0xfffff
    8000731a:	8b6080e7          	jalr	-1866(ra) # 80005bcc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000731e:	08000613          	li	a2,128
    80007322:	f7040593          	addi	a1,s0,-144
    80007326:	4501                	li	a0,0
    80007328:	ffffd097          	auipc	ra,0xffffd
    8000732c:	ac2080e7          	jalr	-1342(ra) # 80003dea <argstr>
    80007330:	02054963          	bltz	a0,80007362 <sys_mkdir+0x54>
    80007334:	4681                	li	a3,0
    80007336:	4601                	li	a2,0
    80007338:	4585                	li	a1,1
    8000733a:	f7040513          	addi	a0,s0,-144
    8000733e:	fffff097          	auipc	ra,0xfffff
    80007342:	7fc080e7          	jalr	2044(ra) # 80006b3a <create>
    80007346:	cd11                	beqz	a0,80007362 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80007348:	ffffe097          	auipc	ra,0xffffe
    8000734c:	10a080e7          	jalr	266(ra) # 80005452 <iunlockput>
  end_op();
    80007350:	fffff097          	auipc	ra,0xfffff
    80007354:	8fa080e7          	jalr	-1798(ra) # 80005c4a <end_op>
  return 0;
    80007358:	4501                	li	a0,0
}
    8000735a:	60aa                	ld	ra,136(sp)
    8000735c:	640a                	ld	s0,128(sp)
    8000735e:	6149                	addi	sp,sp,144
    80007360:	8082                	ret
    end_op();
    80007362:	fffff097          	auipc	ra,0xfffff
    80007366:	8e8080e7          	jalr	-1816(ra) # 80005c4a <end_op>
    return -1;
    8000736a:	557d                	li	a0,-1
    8000736c:	b7fd                	j	8000735a <sys_mkdir+0x4c>

000000008000736e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000736e:	7135                	addi	sp,sp,-160
    80007370:	ed06                	sd	ra,152(sp)
    80007372:	e922                	sd	s0,144(sp)
    80007374:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80007376:	fffff097          	auipc	ra,0xfffff
    8000737a:	856080e7          	jalr	-1962(ra) # 80005bcc <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000737e:	08000613          	li	a2,128
    80007382:	f7040593          	addi	a1,s0,-144
    80007386:	4501                	li	a0,0
    80007388:	ffffd097          	auipc	ra,0xffffd
    8000738c:	a62080e7          	jalr	-1438(ra) # 80003dea <argstr>
    80007390:	04054a63          	bltz	a0,800073e4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80007394:	f6c40593          	addi	a1,s0,-148
    80007398:	4505                	li	a0,1
    8000739a:	ffffd097          	auipc	ra,0xffffd
    8000739e:	a0c080e7          	jalr	-1524(ra) # 80003da6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800073a2:	04054163          	bltz	a0,800073e4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800073a6:	f6840593          	addi	a1,s0,-152
    800073aa:	4509                	li	a0,2
    800073ac:	ffffd097          	auipc	ra,0xffffd
    800073b0:	9fa080e7          	jalr	-1542(ra) # 80003da6 <argint>
     argint(1, &major) < 0 ||
    800073b4:	02054863          	bltz	a0,800073e4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800073b8:	f6841683          	lh	a3,-152(s0)
    800073bc:	f6c41603          	lh	a2,-148(s0)
    800073c0:	458d                	li	a1,3
    800073c2:	f7040513          	addi	a0,s0,-144
    800073c6:	fffff097          	auipc	ra,0xfffff
    800073ca:	774080e7          	jalr	1908(ra) # 80006b3a <create>
     argint(2, &minor) < 0 ||
    800073ce:	c919                	beqz	a0,800073e4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800073d0:	ffffe097          	auipc	ra,0xffffe
    800073d4:	082080e7          	jalr	130(ra) # 80005452 <iunlockput>
  end_op();
    800073d8:	fffff097          	auipc	ra,0xfffff
    800073dc:	872080e7          	jalr	-1934(ra) # 80005c4a <end_op>
  return 0;
    800073e0:	4501                	li	a0,0
    800073e2:	a031                	j	800073ee <sys_mknod+0x80>
    end_op();
    800073e4:	fffff097          	auipc	ra,0xfffff
    800073e8:	866080e7          	jalr	-1946(ra) # 80005c4a <end_op>
    return -1;
    800073ec:	557d                	li	a0,-1
}
    800073ee:	60ea                	ld	ra,152(sp)
    800073f0:	644a                	ld	s0,144(sp)
    800073f2:	610d                	addi	sp,sp,160
    800073f4:	8082                	ret

00000000800073f6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800073f6:	7135                	addi	sp,sp,-160
    800073f8:	ed06                	sd	ra,152(sp)
    800073fa:	e922                	sd	s0,144(sp)
    800073fc:	e526                	sd	s1,136(sp)
    800073fe:	e14a                	sd	s2,128(sp)
    80007400:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80007402:	ffffa097          	auipc	ra,0xffffa
    80007406:	5ee080e7          	jalr	1518(ra) # 800019f0 <myproc>
    8000740a:	892a                	mv	s2,a0
  
  begin_op();
    8000740c:	ffffe097          	auipc	ra,0xffffe
    80007410:	7c0080e7          	jalr	1984(ra) # 80005bcc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80007414:	08000613          	li	a2,128
    80007418:	f6040593          	addi	a1,s0,-160
    8000741c:	4501                	li	a0,0
    8000741e:	ffffd097          	auipc	ra,0xffffd
    80007422:	9cc080e7          	jalr	-1588(ra) # 80003dea <argstr>
    80007426:	04054b63          	bltz	a0,8000747c <sys_chdir+0x86>
    8000742a:	f6040513          	addi	a0,s0,-160
    8000742e:	ffffe097          	auipc	ra,0xffffe
    80007432:	57e080e7          	jalr	1406(ra) # 800059ac <namei>
    80007436:	84aa                	mv	s1,a0
    80007438:	c131                	beqz	a0,8000747c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000743a:	ffffe097          	auipc	ra,0xffffe
    8000743e:	db6080e7          	jalr	-586(ra) # 800051f0 <ilock>
  if(ip->type != T_DIR){
    80007442:	04449703          	lh	a4,68(s1)
    80007446:	4785                	li	a5,1
    80007448:	04f71063          	bne	a4,a5,80007488 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000744c:	8526                	mv	a0,s1
    8000744e:	ffffe097          	auipc	ra,0xffffe
    80007452:	e64080e7          	jalr	-412(ra) # 800052b2 <iunlock>
  iput(p->cwd);
    80007456:	15893503          	ld	a0,344(s2)
    8000745a:	ffffe097          	auipc	ra,0xffffe
    8000745e:	f50080e7          	jalr	-176(ra) # 800053aa <iput>
  end_op();
    80007462:	ffffe097          	auipc	ra,0xffffe
    80007466:	7e8080e7          	jalr	2024(ra) # 80005c4a <end_op>
  p->cwd = ip;
    8000746a:	14993c23          	sd	s1,344(s2)
  return 0;
    8000746e:	4501                	li	a0,0
}
    80007470:	60ea                	ld	ra,152(sp)
    80007472:	644a                	ld	s0,144(sp)
    80007474:	64aa                	ld	s1,136(sp)
    80007476:	690a                	ld	s2,128(sp)
    80007478:	610d                	addi	sp,sp,160
    8000747a:	8082                	ret
    end_op();
    8000747c:	ffffe097          	auipc	ra,0xffffe
    80007480:	7ce080e7          	jalr	1998(ra) # 80005c4a <end_op>
    return -1;
    80007484:	557d                	li	a0,-1
    80007486:	b7ed                	j	80007470 <sys_chdir+0x7a>
    iunlockput(ip);
    80007488:	8526                	mv	a0,s1
    8000748a:	ffffe097          	auipc	ra,0xffffe
    8000748e:	fc8080e7          	jalr	-56(ra) # 80005452 <iunlockput>
    end_op();
    80007492:	ffffe097          	auipc	ra,0xffffe
    80007496:	7b8080e7          	jalr	1976(ra) # 80005c4a <end_op>
    return -1;
    8000749a:	557d                	li	a0,-1
    8000749c:	bfd1                	j	80007470 <sys_chdir+0x7a>

000000008000749e <sys_exec>:

uint64
sys_exec(void)
{
    8000749e:	7145                	addi	sp,sp,-464
    800074a0:	e786                	sd	ra,456(sp)
    800074a2:	e3a2                	sd	s0,448(sp)
    800074a4:	ff26                	sd	s1,440(sp)
    800074a6:	fb4a                	sd	s2,432(sp)
    800074a8:	f74e                	sd	s3,424(sp)
    800074aa:	f352                	sd	s4,416(sp)
    800074ac:	ef56                	sd	s5,408(sp)
    800074ae:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800074b0:	08000613          	li	a2,128
    800074b4:	f4040593          	addi	a1,s0,-192
    800074b8:	4501                	li	a0,0
    800074ba:	ffffd097          	auipc	ra,0xffffd
    800074be:	930080e7          	jalr	-1744(ra) # 80003dea <argstr>
    return -1;
    800074c2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800074c4:	0c054b63          	bltz	a0,8000759a <sys_exec+0xfc>
    800074c8:	e3840593          	addi	a1,s0,-456
    800074cc:	4505                	li	a0,1
    800074ce:	ffffd097          	auipc	ra,0xffffd
    800074d2:	8fa080e7          	jalr	-1798(ra) # 80003dc8 <argaddr>
    800074d6:	0c054263          	bltz	a0,8000759a <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800074da:	10000613          	li	a2,256
    800074de:	4581                	li	a1,0
    800074e0:	e4040513          	addi	a0,s0,-448
    800074e4:	ffff9097          	auipc	ra,0xffff9
    800074e8:	7e6080e7          	jalr	2022(ra) # 80000cca <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800074ec:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800074f0:	89a6                	mv	s3,s1
    800074f2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800074f4:	02000a13          	li	s4,32
    800074f8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800074fc:	00391513          	slli	a0,s2,0x3
    80007500:	e3040593          	addi	a1,s0,-464
    80007504:	e3843783          	ld	a5,-456(s0)
    80007508:	953e                	add	a0,a0,a5
    8000750a:	ffffd097          	auipc	ra,0xffffd
    8000750e:	802080e7          	jalr	-2046(ra) # 80003d0c <fetchaddr>
    80007512:	02054a63          	bltz	a0,80007546 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80007516:	e3043783          	ld	a5,-464(s0)
    8000751a:	c3b9                	beqz	a5,80007560 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000751c:	ffff9097          	auipc	ra,0xffff9
    80007520:	5c2080e7          	jalr	1474(ra) # 80000ade <kalloc>
    80007524:	85aa                	mv	a1,a0
    80007526:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000752a:	cd11                	beqz	a0,80007546 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000752c:	6605                	lui	a2,0x1
    8000752e:	e3043503          	ld	a0,-464(s0)
    80007532:	ffffd097          	auipc	ra,0xffffd
    80007536:	82c080e7          	jalr	-2004(ra) # 80003d5e <fetchstr>
    8000753a:	00054663          	bltz	a0,80007546 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000753e:	0905                	addi	s2,s2,1
    80007540:	09a1                	addi	s3,s3,8
    80007542:	fb491be3          	bne	s2,s4,800074f8 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80007546:	f4040913          	addi	s2,s0,-192
    8000754a:	6088                	ld	a0,0(s1)
    8000754c:	c531                	beqz	a0,80007598 <sys_exec+0xfa>
    kfree(argv[i]);
    8000754e:	ffff9097          	auipc	ra,0xffff9
    80007552:	492080e7          	jalr	1170(ra) # 800009e0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80007556:	04a1                	addi	s1,s1,8
    80007558:	ff2499e3          	bne	s1,s2,8000754a <sys_exec+0xac>
  return -1;
    8000755c:	597d                	li	s2,-1
    8000755e:	a835                	j	8000759a <sys_exec+0xfc>
      argv[i] = 0;
    80007560:	0a8e                	slli	s5,s5,0x3
    80007562:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd5fc0>
    80007566:	00878ab3          	add	s5,a5,s0
    8000756a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000756e:	e4040593          	addi	a1,s0,-448
    80007572:	f4040513          	addi	a0,s0,-192
    80007576:	fffff097          	auipc	ra,0xfffff
    8000757a:	172080e7          	jalr	370(ra) # 800066e8 <exec>
    8000757e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80007580:	f4040993          	addi	s3,s0,-192
    80007584:	6088                	ld	a0,0(s1)
    80007586:	c911                	beqz	a0,8000759a <sys_exec+0xfc>
    kfree(argv[i]);
    80007588:	ffff9097          	auipc	ra,0xffff9
    8000758c:	458080e7          	jalr	1112(ra) # 800009e0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80007590:	04a1                	addi	s1,s1,8
    80007592:	ff3499e3          	bne	s1,s3,80007584 <sys_exec+0xe6>
    80007596:	a011                	j	8000759a <sys_exec+0xfc>
  return -1;
    80007598:	597d                	li	s2,-1
}
    8000759a:	854a                	mv	a0,s2
    8000759c:	60be                	ld	ra,456(sp)
    8000759e:	641e                	ld	s0,448(sp)
    800075a0:	74fa                	ld	s1,440(sp)
    800075a2:	795a                	ld	s2,432(sp)
    800075a4:	79ba                	ld	s3,424(sp)
    800075a6:	7a1a                	ld	s4,416(sp)
    800075a8:	6afa                	ld	s5,408(sp)
    800075aa:	6179                	addi	sp,sp,464
    800075ac:	8082                	ret

00000000800075ae <sys_pipe>:

uint64
sys_pipe(void)
{
    800075ae:	7139                	addi	sp,sp,-64
    800075b0:	fc06                	sd	ra,56(sp)
    800075b2:	f822                	sd	s0,48(sp)
    800075b4:	f426                	sd	s1,40(sp)
    800075b6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800075b8:	ffffa097          	auipc	ra,0xffffa
    800075bc:	438080e7          	jalr	1080(ra) # 800019f0 <myproc>
    800075c0:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800075c2:	fd840593          	addi	a1,s0,-40
    800075c6:	4501                	li	a0,0
    800075c8:	ffffd097          	auipc	ra,0xffffd
    800075cc:	800080e7          	jalr	-2048(ra) # 80003dc8 <argaddr>
    return -1;
    800075d0:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800075d2:	0e054063          	bltz	a0,800076b2 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800075d6:	fc840593          	addi	a1,s0,-56
    800075da:	fd040513          	addi	a0,s0,-48
    800075de:	fffff097          	auipc	ra,0xfffff
    800075e2:	de6080e7          	jalr	-538(ra) # 800063c4 <pipealloc>
    return -1;
    800075e6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800075e8:	0c054563          	bltz	a0,800076b2 <sys_pipe+0x104>
  fd0 = -1;
    800075ec:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800075f0:	fd043503          	ld	a0,-48(s0)
    800075f4:	fffff097          	auipc	ra,0xfffff
    800075f8:	504080e7          	jalr	1284(ra) # 80006af8 <fdalloc>
    800075fc:	fca42223          	sw	a0,-60(s0)
    80007600:	08054c63          	bltz	a0,80007698 <sys_pipe+0xea>
    80007604:	fc843503          	ld	a0,-56(s0)
    80007608:	fffff097          	auipc	ra,0xfffff
    8000760c:	4f0080e7          	jalr	1264(ra) # 80006af8 <fdalloc>
    80007610:	fca42023          	sw	a0,-64(s0)
    80007614:	06054963          	bltz	a0,80007686 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80007618:	4691                	li	a3,4
    8000761a:	fc440613          	addi	a2,s0,-60
    8000761e:	fd843583          	ld	a1,-40(s0)
    80007622:	6ca8                	ld	a0,88(s1)
    80007624:	ffffa097          	auipc	ra,0xffffa
    80007628:	090080e7          	jalr	144(ra) # 800016b4 <copyout>
    8000762c:	02054063          	bltz	a0,8000764c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80007630:	4691                	li	a3,4
    80007632:	fc040613          	addi	a2,s0,-64
    80007636:	fd843583          	ld	a1,-40(s0)
    8000763a:	0591                	addi	a1,a1,4
    8000763c:	6ca8                	ld	a0,88(s1)
    8000763e:	ffffa097          	auipc	ra,0xffffa
    80007642:	076080e7          	jalr	118(ra) # 800016b4 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80007646:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80007648:	06055563          	bgez	a0,800076b2 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    8000764c:	fc442783          	lw	a5,-60(s0)
    80007650:	07e9                	addi	a5,a5,26
    80007652:	078e                	slli	a5,a5,0x3
    80007654:	97a6                	add	a5,a5,s1
    80007656:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000765a:	fc042783          	lw	a5,-64(s0)
    8000765e:	07e9                	addi	a5,a5,26
    80007660:	078e                	slli	a5,a5,0x3
    80007662:	00f48533          	add	a0,s1,a5
    80007666:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000766a:	fd043503          	ld	a0,-48(s0)
    8000766e:	fffff097          	auipc	ra,0xfffff
    80007672:	a26080e7          	jalr	-1498(ra) # 80006094 <fileclose>
    fileclose(wf);
    80007676:	fc843503          	ld	a0,-56(s0)
    8000767a:	fffff097          	auipc	ra,0xfffff
    8000767e:	a1a080e7          	jalr	-1510(ra) # 80006094 <fileclose>
    return -1;
    80007682:	57fd                	li	a5,-1
    80007684:	a03d                	j	800076b2 <sys_pipe+0x104>
    if(fd0 >= 0)
    80007686:	fc442783          	lw	a5,-60(s0)
    8000768a:	0007c763          	bltz	a5,80007698 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000768e:	07e9                	addi	a5,a5,26
    80007690:	078e                	slli	a5,a5,0x3
    80007692:	97a6                	add	a5,a5,s1
    80007694:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80007698:	fd043503          	ld	a0,-48(s0)
    8000769c:	fffff097          	auipc	ra,0xfffff
    800076a0:	9f8080e7          	jalr	-1544(ra) # 80006094 <fileclose>
    fileclose(wf);
    800076a4:	fc843503          	ld	a0,-56(s0)
    800076a8:	fffff097          	auipc	ra,0xfffff
    800076ac:	9ec080e7          	jalr	-1556(ra) # 80006094 <fileclose>
    return -1;
    800076b0:	57fd                	li	a5,-1
}
    800076b2:	853e                	mv	a0,a5
    800076b4:	70e2                	ld	ra,56(sp)
    800076b6:	7442                	ld	s0,48(sp)
    800076b8:	74a2                	ld	s1,40(sp)
    800076ba:	6121                	addi	sp,sp,64
    800076bc:	8082                	ret
	...

00000000800076c0 <kernelvec>:
    800076c0:	7111                	addi	sp,sp,-256
    800076c2:	e006                	sd	ra,0(sp)
    800076c4:	e40a                	sd	sp,8(sp)
    800076c6:	e80e                	sd	gp,16(sp)
    800076c8:	ec12                	sd	tp,24(sp)
    800076ca:	f016                	sd	t0,32(sp)
    800076cc:	f41a                	sd	t1,40(sp)
    800076ce:	f81e                	sd	t2,48(sp)
    800076d0:	fc22                	sd	s0,56(sp)
    800076d2:	e0a6                	sd	s1,64(sp)
    800076d4:	e4aa                	sd	a0,72(sp)
    800076d6:	e8ae                	sd	a1,80(sp)
    800076d8:	ecb2                	sd	a2,88(sp)
    800076da:	f0b6                	sd	a3,96(sp)
    800076dc:	f4ba                	sd	a4,104(sp)
    800076de:	f8be                	sd	a5,112(sp)
    800076e0:	fcc2                	sd	a6,120(sp)
    800076e2:	e146                	sd	a7,128(sp)
    800076e4:	e54a                	sd	s2,136(sp)
    800076e6:	e94e                	sd	s3,144(sp)
    800076e8:	ed52                	sd	s4,152(sp)
    800076ea:	f156                	sd	s5,160(sp)
    800076ec:	f55a                	sd	s6,168(sp)
    800076ee:	f95e                	sd	s7,176(sp)
    800076f0:	fd62                	sd	s8,184(sp)
    800076f2:	e1e6                	sd	s9,192(sp)
    800076f4:	e5ea                	sd	s10,200(sp)
    800076f6:	e9ee                	sd	s11,208(sp)
    800076f8:	edf2                	sd	t3,216(sp)
    800076fa:	f1f6                	sd	t4,224(sp)
    800076fc:	f5fa                	sd	t5,232(sp)
    800076fe:	f9fe                	sd	t6,240(sp)
    80007700:	ccafc0ef          	jal	ra,80003bca <kerneltrap>
    80007704:	6082                	ld	ra,0(sp)
    80007706:	6122                	ld	sp,8(sp)
    80007708:	61c2                	ld	gp,16(sp)
    8000770a:	7282                	ld	t0,32(sp)
    8000770c:	7322                	ld	t1,40(sp)
    8000770e:	73c2                	ld	t2,48(sp)
    80007710:	7462                	ld	s0,56(sp)
    80007712:	6486                	ld	s1,64(sp)
    80007714:	6526                	ld	a0,72(sp)
    80007716:	65c6                	ld	a1,80(sp)
    80007718:	6666                	ld	a2,88(sp)
    8000771a:	7686                	ld	a3,96(sp)
    8000771c:	7726                	ld	a4,104(sp)
    8000771e:	77c6                	ld	a5,112(sp)
    80007720:	7866                	ld	a6,120(sp)
    80007722:	688a                	ld	a7,128(sp)
    80007724:	692a                	ld	s2,136(sp)
    80007726:	69ca                	ld	s3,144(sp)
    80007728:	6a6a                	ld	s4,152(sp)
    8000772a:	7a8a                	ld	s5,160(sp)
    8000772c:	7b2a                	ld	s6,168(sp)
    8000772e:	7bca                	ld	s7,176(sp)
    80007730:	7c6a                	ld	s8,184(sp)
    80007732:	6c8e                	ld	s9,192(sp)
    80007734:	6d2e                	ld	s10,200(sp)
    80007736:	6dce                	ld	s11,208(sp)
    80007738:	6e6e                	ld	t3,216(sp)
    8000773a:	7e8e                	ld	t4,224(sp)
    8000773c:	7f2e                	ld	t5,232(sp)
    8000773e:	7fce                	ld	t6,240(sp)
    80007740:	6111                	addi	sp,sp,256
    80007742:	10200073          	sret
    80007746:	00000013          	nop
    8000774a:	00000013          	nop
    8000774e:	0001                	nop

0000000080007750 <timervec>:
    80007750:	34051573          	csrrw	a0,mscratch,a0
    80007754:	e10c                	sd	a1,0(a0)
    80007756:	e510                	sd	a2,8(a0)
    80007758:	e914                	sd	a3,16(a0)
    8000775a:	6d0c                	ld	a1,24(a0)
    8000775c:	7110                	ld	a2,32(a0)
    8000775e:	6194                	ld	a3,0(a1)
    80007760:	96b2                	add	a3,a3,a2
    80007762:	e194                	sd	a3,0(a1)
    80007764:	4589                	li	a1,2
    80007766:	14459073          	csrw	sip,a1
    8000776a:	6914                	ld	a3,16(a0)
    8000776c:	6510                	ld	a2,8(a0)
    8000776e:	610c                	ld	a1,0(a0)
    80007770:	34051573          	csrrw	a0,mscratch,a0
    80007774:	30200073          	mret
	...

000000008000777a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000777a:	1141                	addi	sp,sp,-16
    8000777c:	e422                	sd	s0,8(sp)
    8000777e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80007780:	0c0007b7          	lui	a5,0xc000
    80007784:	4705                	li	a4,1
    80007786:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80007788:	c3d8                	sw	a4,4(a5)
}
    8000778a:	6422                	ld	s0,8(sp)
    8000778c:	0141                	addi	sp,sp,16
    8000778e:	8082                	ret

0000000080007790 <plicinithart>:

void
plicinithart(void)
{
    80007790:	1141                	addi	sp,sp,-16
    80007792:	e406                	sd	ra,8(sp)
    80007794:	e022                	sd	s0,0(sp)
    80007796:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80007798:	ffffa097          	auipc	ra,0xffffa
    8000779c:	22c080e7          	jalr	556(ra) # 800019c4 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800077a0:	0085171b          	slliw	a4,a0,0x8
    800077a4:	0c0027b7          	lui	a5,0xc002
    800077a8:	97ba                	add	a5,a5,a4
    800077aa:	40200713          	li	a4,1026
    800077ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800077b2:	00d5151b          	slliw	a0,a0,0xd
    800077b6:	0c2017b7          	lui	a5,0xc201
    800077ba:	97aa                	add	a5,a5,a0
    800077bc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800077c0:	60a2                	ld	ra,8(sp)
    800077c2:	6402                	ld	s0,0(sp)
    800077c4:	0141                	addi	sp,sp,16
    800077c6:	8082                	ret

00000000800077c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800077c8:	1141                	addi	sp,sp,-16
    800077ca:	e406                	sd	ra,8(sp)
    800077cc:	e022                	sd	s0,0(sp)
    800077ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800077d0:	ffffa097          	auipc	ra,0xffffa
    800077d4:	1f4080e7          	jalr	500(ra) # 800019c4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800077d8:	00d5151b          	slliw	a0,a0,0xd
    800077dc:	0c2017b7          	lui	a5,0xc201
    800077e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800077e2:	43c8                	lw	a0,4(a5)
    800077e4:	60a2                	ld	ra,8(sp)
    800077e6:	6402                	ld	s0,0(sp)
    800077e8:	0141                	addi	sp,sp,16
    800077ea:	8082                	ret

00000000800077ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800077ec:	1101                	addi	sp,sp,-32
    800077ee:	ec06                	sd	ra,24(sp)
    800077f0:	e822                	sd	s0,16(sp)
    800077f2:	e426                	sd	s1,8(sp)
    800077f4:	1000                	addi	s0,sp,32
    800077f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800077f8:	ffffa097          	auipc	ra,0xffffa
    800077fc:	1cc080e7          	jalr	460(ra) # 800019c4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80007800:	00d5151b          	slliw	a0,a0,0xd
    80007804:	0c2017b7          	lui	a5,0xc201
    80007808:	97aa                	add	a5,a5,a0
    8000780a:	c3c4                	sw	s1,4(a5)
}
    8000780c:	60e2                	ld	ra,24(sp)
    8000780e:	6442                	ld	s0,16(sp)
    80007810:	64a2                	ld	s1,8(sp)
    80007812:	6105                	addi	sp,sp,32
    80007814:	8082                	ret

0000000080007816 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80007816:	1141                	addi	sp,sp,-16
    80007818:	e406                	sd	ra,8(sp)
    8000781a:	e022                	sd	s0,0(sp)
    8000781c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000781e:	479d                	li	a5,7
    80007820:	06a7c863          	blt	a5,a0,80007890 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80007824:	0001e717          	auipc	a4,0x1e
    80007828:	7dc70713          	addi	a4,a4,2012 # 80026000 <disk>
    8000782c:	972a                	add	a4,a4,a0
    8000782e:	6789                	lui	a5,0x2
    80007830:	97ba                	add	a5,a5,a4
    80007832:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80007836:	e7ad                	bnez	a5,800078a0 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80007838:	00451793          	slli	a5,a0,0x4
    8000783c:	00020717          	auipc	a4,0x20
    80007840:	7c470713          	addi	a4,a4,1988 # 80028000 <disk+0x2000>
    80007844:	6314                	ld	a3,0(a4)
    80007846:	96be                	add	a3,a3,a5
    80007848:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000784c:	6314                	ld	a3,0(a4)
    8000784e:	96be                	add	a3,a3,a5
    80007850:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80007854:	6314                	ld	a3,0(a4)
    80007856:	96be                	add	a3,a3,a5
    80007858:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000785c:	6318                	ld	a4,0(a4)
    8000785e:	97ba                	add	a5,a5,a4
    80007860:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80007864:	0001e717          	auipc	a4,0x1e
    80007868:	79c70713          	addi	a4,a4,1948 # 80026000 <disk>
    8000786c:	972a                	add	a4,a4,a0
    8000786e:	6789                	lui	a5,0x2
    80007870:	97ba                	add	a5,a5,a4
    80007872:	4705                	li	a4,1
    80007874:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80007878:	00020517          	auipc	a0,0x20
    8000787c:	7a050513          	addi	a0,a0,1952 # 80028018 <disk+0x2018>
    80007880:	ffffb097          	auipc	ra,0xffffb
    80007884:	4d4080e7          	jalr	1236(ra) # 80002d54 <wakeup>
}
    80007888:	60a2                	ld	ra,8(sp)
    8000788a:	6402                	ld	s0,0(sp)
    8000788c:	0141                	addi	sp,sp,16
    8000788e:	8082                	ret
    panic("free_desc 1");
    80007890:	00002517          	auipc	a0,0x2
    80007894:	26850513          	addi	a0,a0,616 # 80009af8 <syscalls+0x498>
    80007898:	ffff9097          	auipc	ra,0xffff9
    8000789c:	ca0080e7          	jalr	-864(ra) # 80000538 <panic>
    panic("free_desc 2");
    800078a0:	00002517          	auipc	a0,0x2
    800078a4:	26850513          	addi	a0,a0,616 # 80009b08 <syscalls+0x4a8>
    800078a8:	ffff9097          	auipc	ra,0xffff9
    800078ac:	c90080e7          	jalr	-880(ra) # 80000538 <panic>

00000000800078b0 <virtio_disk_init>:
{
    800078b0:	1101                	addi	sp,sp,-32
    800078b2:	ec06                	sd	ra,24(sp)
    800078b4:	e822                	sd	s0,16(sp)
    800078b6:	e426                	sd	s1,8(sp)
    800078b8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800078ba:	00002597          	auipc	a1,0x2
    800078be:	25e58593          	addi	a1,a1,606 # 80009b18 <syscalls+0x4b8>
    800078c2:	00021517          	auipc	a0,0x21
    800078c6:	86650513          	addi	a0,a0,-1946 # 80028128 <disk+0x2128>
    800078ca:	ffff9097          	auipc	ra,0xffff9
    800078ce:	274080e7          	jalr	628(ra) # 80000b3e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800078d2:	100017b7          	lui	a5,0x10001
    800078d6:	4398                	lw	a4,0(a5)
    800078d8:	2701                	sext.w	a4,a4
    800078da:	747277b7          	lui	a5,0x74727
    800078de:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800078e2:	0ef71063          	bne	a4,a5,800079c2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800078e6:	100017b7          	lui	a5,0x10001
    800078ea:	43dc                	lw	a5,4(a5)
    800078ec:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800078ee:	4705                	li	a4,1
    800078f0:	0ce79963          	bne	a5,a4,800079c2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800078f4:	100017b7          	lui	a5,0x10001
    800078f8:	479c                	lw	a5,8(a5)
    800078fa:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800078fc:	4709                	li	a4,2
    800078fe:	0ce79263          	bne	a5,a4,800079c2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80007902:	100017b7          	lui	a5,0x10001
    80007906:	47d8                	lw	a4,12(a5)
    80007908:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000790a:	554d47b7          	lui	a5,0x554d4
    8000790e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80007912:	0af71863          	bne	a4,a5,800079c2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80007916:	100017b7          	lui	a5,0x10001
    8000791a:	4705                	li	a4,1
    8000791c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000791e:	470d                	li	a4,3
    80007920:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80007922:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80007924:	c7ffe6b7          	lui	a3,0xc7ffe
    80007928:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd575f>
    8000792c:	8f75                	and	a4,a4,a3
    8000792e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007930:	472d                	li	a4,11
    80007932:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007934:	473d                	li	a4,15
    80007936:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80007938:	6705                	lui	a4,0x1
    8000793a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000793c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007940:	5bdc                	lw	a5,52(a5)
    80007942:	2781                	sext.w	a5,a5
  if(max == 0)
    80007944:	c7d9                	beqz	a5,800079d2 <virtio_disk_init+0x122>
  if(max < NUM)
    80007946:	471d                	li	a4,7
    80007948:	08f77d63          	bgeu	a4,a5,800079e2 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000794c:	100014b7          	lui	s1,0x10001
    80007950:	47a1                	li	a5,8
    80007952:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80007954:	6609                	lui	a2,0x2
    80007956:	4581                	li	a1,0
    80007958:	0001e517          	auipc	a0,0x1e
    8000795c:	6a850513          	addi	a0,a0,1704 # 80026000 <disk>
    80007960:	ffff9097          	auipc	ra,0xffff9
    80007964:	36a080e7          	jalr	874(ra) # 80000cca <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80007968:	0001e717          	auipc	a4,0x1e
    8000796c:	69870713          	addi	a4,a4,1688 # 80026000 <disk>
    80007970:	00c75793          	srli	a5,a4,0xc
    80007974:	2781                	sext.w	a5,a5
    80007976:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80007978:	00020797          	auipc	a5,0x20
    8000797c:	68878793          	addi	a5,a5,1672 # 80028000 <disk+0x2000>
    80007980:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007982:	0001e717          	auipc	a4,0x1e
    80007986:	6fe70713          	addi	a4,a4,1790 # 80026080 <disk+0x80>
    8000798a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000798c:	0001f717          	auipc	a4,0x1f
    80007990:	67470713          	addi	a4,a4,1652 # 80027000 <disk+0x1000>
    80007994:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80007996:	4705                	li	a4,1
    80007998:	00e78c23          	sb	a4,24(a5)
    8000799c:	00e78ca3          	sb	a4,25(a5)
    800079a0:	00e78d23          	sb	a4,26(a5)
    800079a4:	00e78da3          	sb	a4,27(a5)
    800079a8:	00e78e23          	sb	a4,28(a5)
    800079ac:	00e78ea3          	sb	a4,29(a5)
    800079b0:	00e78f23          	sb	a4,30(a5)
    800079b4:	00e78fa3          	sb	a4,31(a5)
}
    800079b8:	60e2                	ld	ra,24(sp)
    800079ba:	6442                	ld	s0,16(sp)
    800079bc:	64a2                	ld	s1,8(sp)
    800079be:	6105                	addi	sp,sp,32
    800079c0:	8082                	ret
    panic("could not find virtio disk");
    800079c2:	00002517          	auipc	a0,0x2
    800079c6:	16650513          	addi	a0,a0,358 # 80009b28 <syscalls+0x4c8>
    800079ca:	ffff9097          	auipc	ra,0xffff9
    800079ce:	b6e080e7          	jalr	-1170(ra) # 80000538 <panic>
    panic("virtio disk has no queue 0");
    800079d2:	00002517          	auipc	a0,0x2
    800079d6:	17650513          	addi	a0,a0,374 # 80009b48 <syscalls+0x4e8>
    800079da:	ffff9097          	auipc	ra,0xffff9
    800079de:	b5e080e7          	jalr	-1186(ra) # 80000538 <panic>
    panic("virtio disk max queue too short");
    800079e2:	00002517          	auipc	a0,0x2
    800079e6:	18650513          	addi	a0,a0,390 # 80009b68 <syscalls+0x508>
    800079ea:	ffff9097          	auipc	ra,0xffff9
    800079ee:	b4e080e7          	jalr	-1202(ra) # 80000538 <panic>

00000000800079f2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800079f2:	7119                	addi	sp,sp,-128
    800079f4:	fc86                	sd	ra,120(sp)
    800079f6:	f8a2                	sd	s0,112(sp)
    800079f8:	f4a6                	sd	s1,104(sp)
    800079fa:	f0ca                	sd	s2,96(sp)
    800079fc:	ecce                	sd	s3,88(sp)
    800079fe:	e8d2                	sd	s4,80(sp)
    80007a00:	e4d6                	sd	s5,72(sp)
    80007a02:	e0da                	sd	s6,64(sp)
    80007a04:	fc5e                	sd	s7,56(sp)
    80007a06:	f862                	sd	s8,48(sp)
    80007a08:	f466                	sd	s9,40(sp)
    80007a0a:	f06a                	sd	s10,32(sp)
    80007a0c:	ec6e                	sd	s11,24(sp)
    80007a0e:	0100                	addi	s0,sp,128
    80007a10:	8aaa                	mv	s5,a0
    80007a12:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80007a14:	00c52c83          	lw	s9,12(a0)
    80007a18:	001c9c9b          	slliw	s9,s9,0x1
    80007a1c:	1c82                	slli	s9,s9,0x20
    80007a1e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80007a22:	00020517          	auipc	a0,0x20
    80007a26:	70650513          	addi	a0,a0,1798 # 80028128 <disk+0x2128>
    80007a2a:	ffff9097          	auipc	ra,0xffff9
    80007a2e:	1a4080e7          	jalr	420(ra) # 80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80007a32:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007a34:	44a1                	li	s1,8
      disk.free[i] = 0;
    80007a36:	0001ec17          	auipc	s8,0x1e
    80007a3a:	5cac0c13          	addi	s8,s8,1482 # 80026000 <disk>
    80007a3e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007a40:	4b0d                	li	s6,3
    80007a42:	a0ad                	j	80007aac <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007a44:	00fc0733          	add	a4,s8,a5
    80007a48:	975e                	add	a4,a4,s7
    80007a4a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80007a4e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007a50:	0207c563          	bltz	a5,80007a7a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007a54:	2905                	addiw	s2,s2,1
    80007a56:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80007a58:	19690c63          	beq	s2,s6,80007bf0 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80007a5c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007a5e:	00020717          	auipc	a4,0x20
    80007a62:	5ba70713          	addi	a4,a4,1466 # 80028018 <disk+0x2018>
    80007a66:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80007a68:	00074683          	lbu	a3,0(a4)
    80007a6c:	fee1                	bnez	a3,80007a44 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007a6e:	2785                	addiw	a5,a5,1
    80007a70:	0705                	addi	a4,a4,1
    80007a72:	fe979be3          	bne	a5,s1,80007a68 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80007a76:	57fd                	li	a5,-1
    80007a78:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80007a7a:	01205d63          	blez	s2,80007a94 <virtio_disk_rw+0xa2>
    80007a7e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007a80:	000a2503          	lw	a0,0(s4)
    80007a84:	00000097          	auipc	ra,0x0
    80007a88:	d92080e7          	jalr	-622(ra) # 80007816 <free_desc>
      for(int j = 0; j < i; j++)
    80007a8c:	2d85                	addiw	s11,s11,1
    80007a8e:	0a11                	addi	s4,s4,4
    80007a90:	ff2d98e3          	bne	s11,s2,80007a80 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007a94:	00020597          	auipc	a1,0x20
    80007a98:	69458593          	addi	a1,a1,1684 # 80028128 <disk+0x2128>
    80007a9c:	00020517          	auipc	a0,0x20
    80007aa0:	57c50513          	addi	a0,a0,1404 # 80028018 <disk+0x2018>
    80007aa4:	ffffb097          	auipc	ra,0xffffb
    80007aa8:	cfe080e7          	jalr	-770(ra) # 800027a2 <sleep>
  for(int i = 0; i < 3; i++){
    80007aac:	f8040a13          	addi	s4,s0,-128
{
    80007ab0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007ab2:	894e                	mv	s2,s3
    80007ab4:	b765                	j	80007a5c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80007ab6:	00020697          	auipc	a3,0x20
    80007aba:	54a6b683          	ld	a3,1354(a3) # 80028000 <disk+0x2000>
    80007abe:	96ba                	add	a3,a3,a4
    80007ac0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007ac4:	0001e817          	auipc	a6,0x1e
    80007ac8:	53c80813          	addi	a6,a6,1340 # 80026000 <disk>
    80007acc:	00020697          	auipc	a3,0x20
    80007ad0:	53468693          	addi	a3,a3,1332 # 80028000 <disk+0x2000>
    80007ad4:	6290                	ld	a2,0(a3)
    80007ad6:	963a                	add	a2,a2,a4
    80007ad8:	00c65583          	lhu	a1,12(a2)
    80007adc:	0015e593          	ori	a1,a1,1
    80007ae0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007ae4:	f8842603          	lw	a2,-120(s0)
    80007ae8:	628c                	ld	a1,0(a3)
    80007aea:	972e                	add	a4,a4,a1
    80007aec:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007af0:	20050593          	addi	a1,a0,512
    80007af4:	0592                	slli	a1,a1,0x4
    80007af6:	95c2                	add	a1,a1,a6
    80007af8:	577d                	li	a4,-1
    80007afa:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80007afe:	00461713          	slli	a4,a2,0x4
    80007b02:	6290                	ld	a2,0(a3)
    80007b04:	963a                	add	a2,a2,a4
    80007b06:	03078793          	addi	a5,a5,48
    80007b0a:	97c2                	add	a5,a5,a6
    80007b0c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80007b0e:	629c                	ld	a5,0(a3)
    80007b10:	97ba                	add	a5,a5,a4
    80007b12:	4605                	li	a2,1
    80007b14:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80007b16:	629c                	ld	a5,0(a3)
    80007b18:	97ba                	add	a5,a5,a4
    80007b1a:	4809                	li	a6,2
    80007b1c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007b20:	629c                	ld	a5,0(a3)
    80007b22:	97ba                	add	a5,a5,a4
    80007b24:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80007b28:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007b2c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007b30:	6698                	ld	a4,8(a3)
    80007b32:	00275783          	lhu	a5,2(a4)
    80007b36:	8b9d                	andi	a5,a5,7
    80007b38:	0786                	slli	a5,a5,0x1
    80007b3a:	973e                	add	a4,a4,a5
    80007b3c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80007b40:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007b44:	6698                	ld	a4,8(a3)
    80007b46:	00275783          	lhu	a5,2(a4)
    80007b4a:	2785                	addiw	a5,a5,1
    80007b4c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007b50:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007b54:	100017b7          	lui	a5,0x10001
    80007b58:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007b5c:	004aa783          	lw	a5,4(s5)
    80007b60:	02c79163          	bne	a5,a2,80007b82 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007b64:	00020917          	auipc	s2,0x20
    80007b68:	5c490913          	addi	s2,s2,1476 # 80028128 <disk+0x2128>
  while(b->disk == 1) {
    80007b6c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007b6e:	85ca                	mv	a1,s2
    80007b70:	8556                	mv	a0,s5
    80007b72:	ffffb097          	auipc	ra,0xffffb
    80007b76:	c30080e7          	jalr	-976(ra) # 800027a2 <sleep>
  while(b->disk == 1) {
    80007b7a:	004aa783          	lw	a5,4(s5)
    80007b7e:	fe9788e3          	beq	a5,s1,80007b6e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007b82:	f8042903          	lw	s2,-128(s0)
    80007b86:	20090713          	addi	a4,s2,512
    80007b8a:	0712                	slli	a4,a4,0x4
    80007b8c:	0001e797          	auipc	a5,0x1e
    80007b90:	47478793          	addi	a5,a5,1140 # 80026000 <disk>
    80007b94:	97ba                	add	a5,a5,a4
    80007b96:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007b9a:	00020997          	auipc	s3,0x20
    80007b9e:	46698993          	addi	s3,s3,1126 # 80028000 <disk+0x2000>
    80007ba2:	00491713          	slli	a4,s2,0x4
    80007ba6:	0009b783          	ld	a5,0(s3)
    80007baa:	97ba                	add	a5,a5,a4
    80007bac:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007bb0:	854a                	mv	a0,s2
    80007bb2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80007bb6:	00000097          	auipc	ra,0x0
    80007bba:	c60080e7          	jalr	-928(ra) # 80007816 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007bbe:	8885                	andi	s1,s1,1
    80007bc0:	f0ed                	bnez	s1,80007ba2 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007bc2:	00020517          	auipc	a0,0x20
    80007bc6:	56650513          	addi	a0,a0,1382 # 80028128 <disk+0x2128>
    80007bca:	ffff9097          	auipc	ra,0xffff9
    80007bce:	0b8080e7          	jalr	184(ra) # 80000c82 <release>
}
    80007bd2:	70e6                	ld	ra,120(sp)
    80007bd4:	7446                	ld	s0,112(sp)
    80007bd6:	74a6                	ld	s1,104(sp)
    80007bd8:	7906                	ld	s2,96(sp)
    80007bda:	69e6                	ld	s3,88(sp)
    80007bdc:	6a46                	ld	s4,80(sp)
    80007bde:	6aa6                	ld	s5,72(sp)
    80007be0:	6b06                	ld	s6,64(sp)
    80007be2:	7be2                	ld	s7,56(sp)
    80007be4:	7c42                	ld	s8,48(sp)
    80007be6:	7ca2                	ld	s9,40(sp)
    80007be8:	7d02                	ld	s10,32(sp)
    80007bea:	6de2                	ld	s11,24(sp)
    80007bec:	6109                	addi	sp,sp,128
    80007bee:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007bf0:	f8042503          	lw	a0,-128(s0)
    80007bf4:	20050793          	addi	a5,a0,512
    80007bf8:	0792                	slli	a5,a5,0x4
  if(write)
    80007bfa:	0001e817          	auipc	a6,0x1e
    80007bfe:	40680813          	addi	a6,a6,1030 # 80026000 <disk>
    80007c02:	00f80733          	add	a4,a6,a5
    80007c06:	01a036b3          	snez	a3,s10
    80007c0a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007c0e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007c12:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007c16:	7679                	lui	a2,0xffffe
    80007c18:	963e                	add	a2,a2,a5
    80007c1a:	00020697          	auipc	a3,0x20
    80007c1e:	3e668693          	addi	a3,a3,998 # 80028000 <disk+0x2000>
    80007c22:	6298                	ld	a4,0(a3)
    80007c24:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007c26:	0a878593          	addi	a1,a5,168
    80007c2a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007c2c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007c2e:	6298                	ld	a4,0(a3)
    80007c30:	9732                	add	a4,a4,a2
    80007c32:	45c1                	li	a1,16
    80007c34:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80007c36:	6298                	ld	a4,0(a3)
    80007c38:	9732                	add	a4,a4,a2
    80007c3a:	4585                	li	a1,1
    80007c3c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007c40:	f8442703          	lw	a4,-124(s0)
    80007c44:	628c                	ld	a1,0(a3)
    80007c46:	962e                	add	a2,a2,a1
    80007c48:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd500e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007c4c:	0712                	slli	a4,a4,0x4
    80007c4e:	6290                	ld	a2,0(a3)
    80007c50:	963a                	add	a2,a2,a4
    80007c52:	058a8593          	addi	a1,s5,88
    80007c56:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80007c58:	6294                	ld	a3,0(a3)
    80007c5a:	96ba                	add	a3,a3,a4
    80007c5c:	40000613          	li	a2,1024
    80007c60:	c690                	sw	a2,8(a3)
  if(write)
    80007c62:	e40d1ae3          	bnez	s10,80007ab6 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80007c66:	00020697          	auipc	a3,0x20
    80007c6a:	39a6b683          	ld	a3,922(a3) # 80028000 <disk+0x2000>
    80007c6e:	96ba                	add	a3,a3,a4
    80007c70:	4609                	li	a2,2
    80007c72:	00c69623          	sh	a2,12(a3)
    80007c76:	b5b9                	j	80007ac4 <virtio_disk_rw+0xd2>

0000000080007c78 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80007c78:	1101                	addi	sp,sp,-32
    80007c7a:	ec06                	sd	ra,24(sp)
    80007c7c:	e822                	sd	s0,16(sp)
    80007c7e:	e426                	sd	s1,8(sp)
    80007c80:	e04a                	sd	s2,0(sp)
    80007c82:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80007c84:	00020517          	auipc	a0,0x20
    80007c88:	4a450513          	addi	a0,a0,1188 # 80028128 <disk+0x2128>
    80007c8c:	ffff9097          	auipc	ra,0xffff9
    80007c90:	f42080e7          	jalr	-190(ra) # 80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80007c94:	10001737          	lui	a4,0x10001
    80007c98:	533c                	lw	a5,96(a4)
    80007c9a:	8b8d                	andi	a5,a5,3
    80007c9c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007c9e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007ca2:	00020797          	auipc	a5,0x20
    80007ca6:	35e78793          	addi	a5,a5,862 # 80028000 <disk+0x2000>
    80007caa:	6b94                	ld	a3,16(a5)
    80007cac:	0207d703          	lhu	a4,32(a5)
    80007cb0:	0026d783          	lhu	a5,2(a3)
    80007cb4:	06f70163          	beq	a4,a5,80007d16 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007cb8:	0001e917          	auipc	s2,0x1e
    80007cbc:	34890913          	addi	s2,s2,840 # 80026000 <disk>
    80007cc0:	00020497          	auipc	s1,0x20
    80007cc4:	34048493          	addi	s1,s1,832 # 80028000 <disk+0x2000>
    __sync_synchronize();
    80007cc8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007ccc:	6898                	ld	a4,16(s1)
    80007cce:	0204d783          	lhu	a5,32(s1)
    80007cd2:	8b9d                	andi	a5,a5,7
    80007cd4:	078e                	slli	a5,a5,0x3
    80007cd6:	97ba                	add	a5,a5,a4
    80007cd8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007cda:	20078713          	addi	a4,a5,512
    80007cde:	0712                	slli	a4,a4,0x4
    80007ce0:	974a                	add	a4,a4,s2
    80007ce2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80007ce6:	e731                	bnez	a4,80007d32 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80007ce8:	20078793          	addi	a5,a5,512
    80007cec:	0792                	slli	a5,a5,0x4
    80007cee:	97ca                	add	a5,a5,s2
    80007cf0:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007cf2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80007cf6:	ffffb097          	auipc	ra,0xffffb
    80007cfa:	05e080e7          	jalr	94(ra) # 80002d54 <wakeup>

    disk.used_idx += 1;
    80007cfe:	0204d783          	lhu	a5,32(s1)
    80007d02:	2785                	addiw	a5,a5,1
    80007d04:	17c2                	slli	a5,a5,0x30
    80007d06:	93c1                	srli	a5,a5,0x30
    80007d08:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007d0c:	6898                	ld	a4,16(s1)
    80007d0e:	00275703          	lhu	a4,2(a4)
    80007d12:	faf71be3          	bne	a4,a5,80007cc8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80007d16:	00020517          	auipc	a0,0x20
    80007d1a:	41250513          	addi	a0,a0,1042 # 80028128 <disk+0x2128>
    80007d1e:	ffff9097          	auipc	ra,0xffff9
    80007d22:	f64080e7          	jalr	-156(ra) # 80000c82 <release>
}
    80007d26:	60e2                	ld	ra,24(sp)
    80007d28:	6442                	ld	s0,16(sp)
    80007d2a:	64a2                	ld	s1,8(sp)
    80007d2c:	6902                	ld	s2,0(sp)
    80007d2e:	6105                	addi	sp,sp,32
    80007d30:	8082                	ret
      panic("virtio_disk_intr status");
    80007d32:	00002517          	auipc	a0,0x2
    80007d36:	e5650513          	addi	a0,a0,-426 # 80009b88 <syscalls+0x528>
    80007d3a:	ffff8097          	auipc	ra,0xffff8
    80007d3e:	7fe080e7          	jalr	2046(ra) # 80000538 <panic>

0000000080007d42 <cond_wait>:
#include "spinlock.h"
#include "condvar.h"
#include "riscv.h"
#include "defs.h"

void cond_wait (struct cond_t *cv, struct sleeplock *lock) {
    80007d42:	1141                	addi	sp,sp,-16
    80007d44:	e406                	sd	ra,8(sp)
    80007d46:	e022                	sd	s0,0(sp)
    80007d48:	0800                	addi	s0,sp,16
    condsleep(cv, lock);
    80007d4a:	ffffb097          	auipc	ra,0xffffb
    80007d4e:	e5c080e7          	jalr	-420(ra) # 80002ba6 <condsleep>
}
    80007d52:	60a2                	ld	ra,8(sp)
    80007d54:	6402                	ld	s0,0(sp)
    80007d56:	0141                	addi	sp,sp,16
    80007d58:	8082                	ret

0000000080007d5a <cond_signal>:
void cond_signal (struct cond_t *cv) {
    80007d5a:	1141                	addi	sp,sp,-16
    80007d5c:	e406                	sd	ra,8(sp)
    80007d5e:	e022                	sd	s0,0(sp)
    80007d60:	0800                	addi	s0,sp,16
    wakeupone(cv);
    80007d62:	ffffb097          	auipc	ra,0xffffb
    80007d66:	548080e7          	jalr	1352(ra) # 800032aa <wakeupone>
}
    80007d6a:	60a2                	ld	ra,8(sp)
    80007d6c:	6402                	ld	s0,0(sp)
    80007d6e:	0141                	addi	sp,sp,16
    80007d70:	8082                	ret

0000000080007d72 <cond_broadcast>:
void cond_broadcast (struct cond_t *cv) {
    80007d72:	1141                	addi	sp,sp,-16
    80007d74:	e406                	sd	ra,8(sp)
    80007d76:	e022                	sd	s0,0(sp)
    80007d78:	0800                	addi	s0,sp,16
    wakeup(cv);
    80007d7a:	ffffb097          	auipc	ra,0xffffb
    80007d7e:	fda080e7          	jalr	-38(ra) # 80002d54 <wakeup>
    80007d82:	60a2                	ld	ra,8(sp)
    80007d84:	6402                	ld	s0,0(sp)
    80007d86:	0141                	addi	sp,sp,16
    80007d88:	8082                	ret

0000000080007d8a <sem_init>:
#include "semaphore.h"
#include "riscv.h"
#include "defs.h"

void sem_init (struct sem_t *z, int value) {
    80007d8a:	1101                	addi	sp,sp,-32
    80007d8c:	ec06                	sd	ra,24(sp)
    80007d8e:	e822                	sd	s0,16(sp)
    80007d90:	e426                	sd	s1,8(sp)
    80007d92:	1000                	addi	s0,sp,32
    80007d94:	84aa                	mv	s1,a0
    z->value = value;
    80007d96:	c10c                	sw	a1,0(a0)
    initsleeplock(&z->cv.lk, "semaphore_cv_lock");
    80007d98:	00002597          	auipc	a1,0x2
    80007d9c:	e0858593          	addi	a1,a1,-504 # 80009ba0 <syscalls+0x540>
    80007da0:	03850513          	addi	a0,a0,56
    80007da4:	ffffe097          	auipc	ra,0xffffe
    80007da8:	0e2080e7          	jalr	226(ra) # 80005e86 <initsleeplock>
    initsleeplock(&z->lock, "semaphore_lock");
    80007dac:	00002597          	auipc	a1,0x2
    80007db0:	e0c58593          	addi	a1,a1,-500 # 80009bb8 <syscalls+0x558>
    80007db4:	00848513          	addi	a0,s1,8
    80007db8:	ffffe097          	auipc	ra,0xffffe
    80007dbc:	0ce080e7          	jalr	206(ra) # 80005e86 <initsleeplock>
}
    80007dc0:	60e2                	ld	ra,24(sp)
    80007dc2:	6442                	ld	s0,16(sp)
    80007dc4:	64a2                	ld	s1,8(sp)
    80007dc6:	6105                	addi	sp,sp,32
    80007dc8:	8082                	ret

0000000080007dca <sem_wait>:

void sem_wait (struct sem_t *z) {
    80007dca:	7179                	addi	sp,sp,-48
    80007dcc:	f406                	sd	ra,40(sp)
    80007dce:	f022                	sd	s0,32(sp)
    80007dd0:	ec26                	sd	s1,24(sp)
    80007dd2:	e84a                	sd	s2,16(sp)
    80007dd4:	e44e                	sd	s3,8(sp)
    80007dd6:	1800                	addi	s0,sp,48
    80007dd8:	84aa                	mv	s1,a0
acquiresleep (&z->lock);
    80007dda:	00850913          	addi	s2,a0,8
    80007dde:	854a                	mv	a0,s2
    80007de0:	ffffe097          	auipc	ra,0xffffe
    80007de4:	0e0080e7          	jalr	224(ra) # 80005ec0 <acquiresleep>
while (z->value == 0) cond_wait (&z->cv, &z->lock);
    80007de8:	409c                	lw	a5,0(s1)
    80007dea:	eb99                	bnez	a5,80007e00 <sem_wait+0x36>
    80007dec:	03848993          	addi	s3,s1,56
    80007df0:	85ca                	mv	a1,s2
    80007df2:	854e                	mv	a0,s3
    80007df4:	00000097          	auipc	ra,0x0
    80007df8:	f4e080e7          	jalr	-178(ra) # 80007d42 <cond_wait>
    80007dfc:	409c                	lw	a5,0(s1)
    80007dfe:	dbed                	beqz	a5,80007df0 <sem_wait+0x26>
z->value--;
    80007e00:	37fd                	addiw	a5,a5,-1
    80007e02:	c09c                	sw	a5,0(s1)
releasesleep (&z->lock);
    80007e04:	854a                	mv	a0,s2
    80007e06:	ffffe097          	auipc	ra,0xffffe
    80007e0a:	110080e7          	jalr	272(ra) # 80005f16 <releasesleep>
}
    80007e0e:	70a2                	ld	ra,40(sp)
    80007e10:	7402                	ld	s0,32(sp)
    80007e12:	64e2                	ld	s1,24(sp)
    80007e14:	6942                	ld	s2,16(sp)
    80007e16:	69a2                	ld	s3,8(sp)
    80007e18:	6145                	addi	sp,sp,48
    80007e1a:	8082                	ret

0000000080007e1c <sem_post>:

void sem_post (struct sem_t *z) {
    80007e1c:	1101                	addi	sp,sp,-32
    80007e1e:	ec06                	sd	ra,24(sp)
    80007e20:	e822                	sd	s0,16(sp)
    80007e22:	e426                	sd	s1,8(sp)
    80007e24:	e04a                	sd	s2,0(sp)
    80007e26:	1000                	addi	s0,sp,32
    80007e28:	84aa                	mv	s1,a0
acquiresleep (&z->lock);
    80007e2a:	00850913          	addi	s2,a0,8
    80007e2e:	854a                	mv	a0,s2
    80007e30:	ffffe097          	auipc	ra,0xffffe
    80007e34:	090080e7          	jalr	144(ra) # 80005ec0 <acquiresleep>
z->value++;
    80007e38:	409c                	lw	a5,0(s1)
    80007e3a:	2785                	addiw	a5,a5,1
    80007e3c:	c09c                	sw	a5,0(s1)
cond_signal (&z->cv);
    80007e3e:	03848513          	addi	a0,s1,56
    80007e42:	00000097          	auipc	ra,0x0
    80007e46:	f18080e7          	jalr	-232(ra) # 80007d5a <cond_signal>
releasesleep (&z->lock);
    80007e4a:	854a                	mv	a0,s2
    80007e4c:	ffffe097          	auipc	ra,0xffffe
    80007e50:	0ca080e7          	jalr	202(ra) # 80005f16 <releasesleep>
}
    80007e54:	60e2                	ld	ra,24(sp)
    80007e56:	6442                	ld	s0,16(sp)
    80007e58:	64a2                	ld	s1,8(sp)
    80007e5a:	6902                	ld	s2,0(sp)
    80007e5c:	6105                	addi	sp,sp,32
    80007e5e:	8082                	ret
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
