
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	c1013103          	ld	sp,-1008(sp) # 80009c10 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000064:	58078793          	addi	a5,a5,1408 # 800075e0 <timervec>
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
    80000098:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd67ff>
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
    80000474:	96878793          	addi	a5,a5,-1688 # 80023dd8 <devsw>
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
    800009f4:	00027797          	auipc	a5,0x27
    800009f8:	60c78793          	addi	a5,a5,1548 # 80028000 <end>
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
    80000ac6:	00027517          	auipc	a0,0x27
    80000aca:	53a50513          	addi	a0,a0,1338 # 80028000 <end>
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
    80000d3e:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd7001>
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
extern struct buffer_elem buffer[20];

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
    80000ec8:	00006097          	auipc	ra,0x6
    80000ecc:	758080e7          	jalr	1880(ra) # 80007620 <plicinithart>
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
    80000f08:	e06080e7          	jalr	-506(ra) # 80005d0a <initsleeplock>
    initsleeplock(&barr[i].cv.lk, "barrier_cv_lock");
    80000f0c:	85ca                	mv	a1,s2
    80000f0e:	03048513          	addi	a0,s1,48
    80000f12:	00005097          	auipc	ra,0x5
    80000f16:	df8080e7          	jalr	-520(ra) # 80005d0a <initsleeplock>
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
    80000f9e:	670080e7          	jalr	1648(ra) # 8000760a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa2:	00006097          	auipc	ra,0x6
    80000fa6:	67e080e7          	jalr	1662(ra) # 80007620 <plicinithart>
    binit();         // buffer cache
    80000faa:	00004097          	auipc	ra,0x4
    80000fae:	83a080e7          	jalr	-1990(ra) # 800047e4 <binit>
    iinit();         // inode table
    80000fb2:	00004097          	auipc	ra,0x4
    80000fb6:	ec8080e7          	jalr	-312(ra) # 80004e7a <iinit>
    fileinit();      // file table
    80000fba:	00005097          	auipc	ra,0x5
    80000fbe:	e7a080e7          	jalr	-390(ra) # 80005e34 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc2:	00006097          	auipc	ra,0x6
    80000fc6:	77e080e7          	jalr	1918(ra) # 80007740 <virtio_disk_init>
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
    80001066:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd6ff7>
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
    80001854:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd7000>
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
    80001a7a:	13a7a783          	lw	a5,314(a5) # 80009bb0 <first.3>
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
    80001a96:	1007af23          	sw	zero,286(a5) # 80009bb0 <first.3>
    fsinit(ROOTDEV);
    80001a9a:	4505                	li	a0,1
    80001a9c:	00003097          	auipc	ra,0x3
    80001aa0:	35e080e7          	jalr	862(ra) # 80004dfa <fsinit>
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
    80001ac8:	10078793          	addi	a5,a5,256 # 80009bc4 <nextpid>
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
    80001d62:	e7258593          	addi	a1,a1,-398 # 80009bd0 <initcode>
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
    80001da0:	a94080e7          	jalr	-1388(ra) # 80005830 <namei>
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
    80001eec:	fde080e7          	jalr	-34(ra) # 80005ec6 <filedup>
    80001ef0:	00a93023          	sd	a0,0(s2)
    80001ef4:	b7e5                	j	80001edc <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ef6:	158ab503          	ld	a0,344(s5)
    80001efa:	00003097          	auipc	ra,0x3
    80001efe:	13c080e7          	jalr	316(ra) # 80005036 <idup>
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
    80002038:	e92080e7          	jalr	-366(ra) # 80005ec6 <filedup>
    8000203c:	00a93023          	sd	a0,0(s2)
    80002040:	b7e5                	j	80002028 <forkf+0xb0>
  np->cwd = idup(p->cwd);
    80002042:	158ab503          	ld	a0,344(s5)
    80002046:	00003097          	auipc	ra,0x3
    8000204a:	ff0080e7          	jalr	-16(ra) # 80005036 <idup>
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
    8000217c:	d4e080e7          	jalr	-690(ra) # 80005ec6 <filedup>
    80002180:	00a93023          	sd	a0,0(s2)
    80002184:	b7e5                	j	8000216c <forkp+0xa8>
  np->cwd = idup(p->cwd);
    80002186:	158ab503          	ld	a0,344(s5)
    8000218a:	00003097          	auipc	ra,0x3
    8000218e:	eac080e7          	jalr	-340(ra) # 80005036 <idup>
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
    800024ea:	000ba783          	lw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffd7000>
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
    800026da:	4e26a683          	lw	a3,1250(a3) # 80009bb8 <cpubursts_min>
    800026de:	00d67663          	bgeu	a2,a3,800026ea <yield+0xb4>
    800026e2:	00007697          	auipc	a3,0x7
    800026e6:	4ce6ab23          	sw	a4,1238(a3) # 80009bb8 <cpubursts_min>
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
    8000276e:	44a6a683          	lw	a3,1098(a3) # 80009bb4 <cpubursts_est_min>
    80002772:	00d75663          	bge	a4,a3,8000277e <yield+0x148>
    80002776:	00007717          	auipc	a4,0x7
    8000277a:	42f72f23          	sw	a5,1086(a4) # 80009bb4 <cpubursts_est_min>
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
    8000284c:	3706a683          	lw	a3,880(a3) # 80009bb8 <cpubursts_min>
    80002850:	00d67663          	bgeu	a2,a3,8000285c <sleep+0xba>
    80002854:	00007697          	auipc	a3,0x7
    80002858:	36e6a223          	sw	a4,868(a3) # 80009bb8 <cpubursts_min>
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
    800028e0:	2d86a683          	lw	a3,728(a3) # 80009bb4 <cpubursts_est_min>
    800028e4:	00d75663          	bge	a4,a3,800028f0 <sleep+0x14e>
    800028e8:	00007717          	auipc	a4,0x7
    800028ec:	2cf72623          	sw	a5,716(a4) # 80009bb4 <cpubursts_est_min>
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
    80002bf0:	1ae080e7          	jalr	430(ra) # 80005d9a <releasesleep>

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
    80002c50:	f6c6a683          	lw	a3,-148(a3) # 80009bb8 <cpubursts_min>
    80002c54:	00d67663          	bgeu	a2,a3,80002c60 <condsleep+0xba>
    80002c58:	00007697          	auipc	a3,0x7
    80002c5c:	f6e6a023          	sw	a4,-160(a3) # 80009bb8 <cpubursts_min>
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
    80002ce4:	ed46a683          	lw	a3,-300(a3) # 80009bb4 <cpubursts_est_min>
    80002ce8:	00d75663          	bge	a4,a3,80002cf4 <condsleep+0x14e>
    80002cec:	00007717          	auipc	a4,0x7
    80002cf0:	ecf72423          	sw	a5,-312(a4) # 80009bb4 <cpubursts_est_min>
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
    80002d10:	038080e7          	jalr	56(ra) # 80005d44 <acquiresleep>
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
    80002eb4:	068080e7          	jalr	104(ra) # 80005f18 <fileclose>
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
    80002ecc:	b88080e7          	jalr	-1144(ra) # 80005a50 <begin_op>
  iput(p->cwd);
    80002ed0:	15893503          	ld	a0,344(s2)
    80002ed4:	00002097          	auipc	ra,0x2
    80002ed8:	35a080e7          	jalr	858(ra) # 8000522e <iput>
  end_op();
    80002edc:	00003097          	auipc	ra,0x3
    80002ee0:	bf2080e7          	jalr	-1038(ra) # 80005ace <end_op>
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
    80002faa:	c1272703          	lw	a4,-1006(a4) # 80009bb8 <cpubursts_min>
    80002fae:	00e5f663          	bgeu	a1,a4,80002fba <exit+0x14a>
    80002fb2:	00007717          	auipc	a4,0x7
    80002fb6:	c0d72323          	sw	a3,-1018(a4) # 80009bb8 <cpubursts_min>
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
    8000303a:	b7e62603          	lw	a2,-1154(a2) # 80009bb4 <cpubursts_est_min>
    8000303e:	00c6d663          	bge	a3,a2,8000304a <exit+0x1da>
    80003042:	00007697          	auipc	a3,0x7
    80003046:	b6e6a923          	sw	a4,-1166(a3) # 80009bb4 <cpubursts_est_min>
     if (p->stime < batch_start) batch_start = p->stime;
    8000304a:	17492703          	lw	a4,372(s2)
    8000304e:	00007697          	auipc	a3,0x7
    80003052:	b726a683          	lw	a3,-1166(a3) # 80009bc0 <batch_start>
    80003056:	00d75663          	bge	a4,a3,80003062 <exit+0x1f2>
    8000305a:	00007697          	auipc	a3,0x7
    8000305e:	b6e6a323          	sw	a4,-1178(a3) # 80009bc0 <batch_start>
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
    800030be:	b0272703          	lw	a4,-1278(a4) # 80009bbc <completion_min>
    800030c2:	00e7d663          	bge	a5,a4,800030ce <exit+0x25e>
    800030c6:	00007717          	auipc	a4,0x7
    800030ca:	aef72b23          	sw	a5,-1290(a4) # 80009bbc <completion_min>
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
    800030f2:	ad25a583          	lw	a1,-1326(a1) # 80009bc0 <batch_start>
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
    8000315c:	a646a683          	lw	a3,-1436(a3) # 80009bbc <completion_min>
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
    8000319e:	a2f72323          	sw	a5,-1498(a4) # 80009bc0 <batch_start>
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
    800031c6:	9ef72d23          	sw	a5,-1542(a4) # 80009bbc <completion_min>
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
    800031e6:	9cf72b23          	sw	a5,-1578(a4) # 80009bb8 <cpubursts_min>
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
    80003206:	9af72923          	sw	a5,-1614(a4) # 80009bb4 <cpubursts_est_min>
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
    80003230:	98c72703          	lw	a4,-1652(a4) # 80009bb8 <cpubursts_min>
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
    80003264:	95472703          	lw	a4,-1708(a4) # 80009bb4 <cpubursts_est_min>
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
  uint waken=0;

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
        waken = 1;
	p->waitstart = xticks;
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
    80003934:	c2078793          	addi	a5,a5,-992 # 80007550 <kernelvec>
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
    80003a5c:	c00080e7          	jalr	-1024(ra) # 80007658 <plic_claim>
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
    80003a8a:	bf6080e7          	jalr	-1034(ra) # 8000767c <plic_complete>
    return 1;
    80003a8e:	4505                	li	a0,1
    80003a90:	bf55                	j	80003a44 <devintr+0x1e>
      uartintr();
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	efe080e7          	jalr	-258(ra) # 80000990 <uartintr>
    80003a9a:	b7ed                	j	80003a84 <devintr+0x5e>
      virtio_disk_intr();
    80003a9c:	00004097          	auipc	ra,0x4
    80003aa0:	06c080e7          	jalr	108(ra) # 80007b08 <virtio_disk_intr>
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
    80003ae2:	a7278793          	addi	a5,a5,-1422 # 80007550 <kernelvec>
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
int tail, head;
struct sleeplock lock_delete, lock_insert, lock_print;

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
    return -1;;
    800042b8:	57fd                	li	a5,-1
  if(argint(0, &barr_inst) < 0){
    800042ba:	0c054a63          	bltz	a0,8000438e <sys_barrier+0xf0>
  }

  if(argint(1, &barr_id) < 0){
    800042be:	fd840593          	addi	a1,s0,-40
    800042c2:	4505                	li	a0,1
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	ae2080e7          	jalr	-1310(ra) # 80003da6 <argint>
    return -1;;
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
    return -1;;
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
    printf("Barrier array id not allocated\n");
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
    8000432e:	4ae50513          	addi	a0,a0,1198 # 800097d8 <syscalls+0x178>
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
    80004366:	870080e7          	jalr	-1936(ra) # 80007bd2 <cond_wait>
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
    80004380:	48c50513          	addi	a0,a0,1164 # 80009808 <syscalls+0x1a8>
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
    printf("Barrier array id not allocated\n");
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
    800043d2:	834080e7          	jalr	-1996(ra) # 80007c02 <cond_broadcast>
    800043d6:	bf51                	j	8000436a <sys_barrier+0xcc>
    return -1;;
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
    80004402:	946080e7          	jalr	-1722(ra) # 80005d44 <acquiresleep>
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
    80004414:	98a080e7          	jalr	-1654(ra) # 80005d9a <releasesleep>
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
    80004452:	94c080e7          	jalr	-1716(ra) # 80005d9a <releasesleep>
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
    800044a6:	868080e7          	jalr	-1944(ra) # 80005d0a <initsleeplock>
   initsleeplock(&barr[barr_id].cv.lk, "barrier_cv_lock");
    800044aa:	fdc42503          	lw	a0,-36(s0)
    800044ae:	03250533          	mul	a0,a0,s2
    800044b2:	03850513          	addi	a0,a0,56
    800044b6:	00005597          	auipc	a1,0x5
    800044ba:	c2a58593          	addi	a1,a1,-982 # 800090e0 <digits+0xa0>
    800044be:	9526                	add	a0,a0,s1
    800044c0:	00002097          	auipc	ra,0x2
    800044c4:	84a080e7          	jalr	-1974(ra) # 80005d0a <initsleeplock>

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
    800044f0:	b807a423          	sw	zero,-1144(a5) # 8000a074 <tail>
  head = 0;
    800044f4:	00006797          	auipc	a5,0x6
    800044f8:	b607ae23          	sw	zero,-1156(a5) # 8000a070 <head>
  initsleeplock(&lock_delete, "delete");
    800044fc:	00005597          	auipc	a1,0x5
    80004500:	34458593          	addi	a1,a1,836 # 80009840 <syscalls+0x1e0>
    80004504:	00015517          	auipc	a0,0x15
    80004508:	a3450513          	addi	a0,a0,-1484 # 80018f38 <lock_delete>
    8000450c:	00001097          	auipc	ra,0x1
    80004510:	7fe080e7          	jalr	2046(ra) # 80005d0a <initsleeplock>
  initsleeplock(&lock_insert, "insert");
    80004514:	00005597          	auipc	a1,0x5
    80004518:	33458593          	addi	a1,a1,820 # 80009848 <syscalls+0x1e8>
    8000451c:	00015517          	auipc	a0,0x15
    80004520:	a4c50513          	addi	a0,a0,-1460 # 80018f68 <lock_insert>
    80004524:	00001097          	auipc	ra,0x1
    80004528:	7e6080e7          	jalr	2022(ra) # 80005d0a <initsleeplock>
  initsleeplock(&lock_print, "print");
    8000452c:	00005597          	auipc	a1,0x5
    80004530:	32458593          	addi	a1,a1,804 # 80009850 <syscalls+0x1f0>
    80004534:	00015517          	auipc	a0,0x15
    80004538:	a6450513          	addi	a0,a0,-1436 # 80018f98 <lock_print>
    8000453c:	00001097          	auipc	ra,0x1
    80004540:	7ce080e7          	jalr	1998(ra) # 80005d0a <initsleeplock>
  for (int i = 0; i < SIZE; i++) {
    80004544:	00015497          	auipc	s1,0x15
    80004548:	a8c48493          	addi	s1,s1,-1396 # 80018fd0 <buffer+0x8>
    8000454c:	00015b17          	auipc	s6,0x15
    80004550:	664b0b13          	addi	s6,s6,1636 # 80019bb0 <bcache+0x8>
    buffer[i].x = -1;
    80004554:	5afd                	li	s5,-1
    buffer[i].full = 0;
    initsleeplock(&buffer[i].lock, "buffer_lock");
    80004556:	00005a17          	auipc	s4,0x5
    8000455a:	302a0a13          	addi	s4,s4,770 # 80009858 <syscalls+0x1f8>
    initsleeplock(&buffer[i].inserted.lk, "insert");
    8000455e:	00005997          	auipc	s3,0x5
    80004562:	2ea98993          	addi	s3,s3,746 # 80009848 <syscalls+0x1e8>
    initsleeplock(&buffer[i].deleted.lk, "delete");
    80004566:	00005917          	auipc	s2,0x5
    8000456a:	2da90913          	addi	s2,s2,730 # 80009840 <syscalls+0x1e0>
    buffer[i].x = -1;
    8000456e:	ff54ac23          	sw	s5,-8(s1)
    buffer[i].full = 0;
    80004572:	fe04ae23          	sw	zero,-4(s1)
    initsleeplock(&buffer[i].lock, "buffer_lock");
    80004576:	85d2                	mv	a1,s4
    80004578:	8526                	mv	a0,s1
    8000457a:	00001097          	auipc	ra,0x1
    8000457e:	790080e7          	jalr	1936(ra) # 80005d0a <initsleeplock>
    initsleeplock(&buffer[i].inserted.lk, "insert");
    80004582:	85ce                	mv	a1,s3
    80004584:	03048513          	addi	a0,s1,48
    80004588:	00001097          	auipc	ra,0x1
    8000458c:	782080e7          	jalr	1922(ra) # 80005d0a <initsleeplock>
    initsleeplock(&buffer[i].deleted.lk, "delete");
    80004590:	85ca                	mv	a1,s2
    80004592:	06048513          	addi	a0,s1,96
    80004596:	00001097          	auipc	ra,0x1
    8000459a:	774080e7          	jalr	1908(ra) # 80005d0a <initsleeplock>
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
    800045ec:	00001097          	auipc	ra,0x1
    800045f0:	758080e7          	jalr	1880(ra) # 80005d44 <acquiresleep>
  index = tail;
    800045f4:	00006717          	auipc	a4,0x6
    800045f8:	a8070713          	addi	a4,a4,-1408 # 8000a074 <tail>
    800045fc:	00072a03          	lw	s4,0(a4)
  tail = (tail + 1) % SIZE;
    80004600:	001a079b          	addiw	a5,s4,1
    80004604:	46d1                	li	a3,20
    80004606:	02d7e7bb          	remw	a5,a5,a3
    8000460a:	c31c                	sw	a5,0(a4)
  releasesleep(&lock_insert);
    8000460c:	8526                	mv	a0,s1
    8000460e:	00001097          	auipc	ra,0x1
    80004612:	78c080e7          	jalr	1932(ra) # 80005d9a <releasesleep>
  acquiresleep(&buffer[index].lock);
    80004616:	09800a93          	li	s5,152
    8000461a:	035a0ab3          	mul	s5,s4,s5
    8000461e:	008a8493          	addi	s1,s5,8
    80004622:	00015917          	auipc	s2,0x15
    80004626:	9a690913          	addi	s2,s2,-1626 # 80018fc8 <buffer>
    8000462a:	94ca                	add	s1,s1,s2
    8000462c:	8526                	mv	a0,s1
    8000462e:	00001097          	auipc	ra,0x1
    80004632:	716080e7          	jalr	1814(ra) # 80005d44 <acquiresleep>
  while(buffer[index].full)
    80004636:	9956                	add	s2,s2,s5
    80004638:	00492783          	lw	a5,4(s2)
    8000463c:	c785                	beqz	a5,80004664 <sys_cond_produce+0xa8>
    cond_wait(&buffer[index].deleted, &buffer[index].lock);
    8000463e:	00015997          	auipc	s3,0x15
    80004642:	9f298993          	addi	s3,s3,-1550 # 80019030 <buffer+0x68>
    80004646:	99d6                	add	s3,s3,s5
  while(buffer[index].full)
    80004648:	00015917          	auipc	s2,0x15
    8000464c:	98090913          	addi	s2,s2,-1664 # 80018fc8 <buffer>
    80004650:	9956                	add	s2,s2,s5
    cond_wait(&buffer[index].deleted, &buffer[index].lock);
    80004652:	85a6                	mv	a1,s1
    80004654:	854e                	mv	a0,s3
    80004656:	00003097          	auipc	ra,0x3
    8000465a:	57c080e7          	jalr	1404(ra) # 80007bd2 <cond_wait>
  while(buffer[index].full)
    8000465e:	00492783          	lw	a5,4(s2)
    80004662:	fbe5                	bnez	a5,80004652 <sys_cond_produce+0x96>
  buffer[index].x = val;
    80004664:	00015517          	auipc	a0,0x15
    80004668:	96450513          	addi	a0,a0,-1692 # 80018fc8 <buffer>
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
    8000468e:	560080e7          	jalr	1376(ra) # 80007bea <cond_signal>
  releasesleep(&buffer[index].lock);
    80004692:	8526                	mv	a0,s1
    80004694:	00001097          	auipc	ra,0x1
    80004698:	706080e7          	jalr	1798(ra) # 80005d9a <releasesleep>
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
    800046d2:	676080e7          	jalr	1654(ra) # 80005d44 <acquiresleep>
  index = head;
    800046d6:	00006717          	auipc	a4,0x6
    800046da:	99a70713          	addi	a4,a4,-1638 # 8000a070 <head>
    800046de:	00072a03          	lw	s4,0(a4)
  head = (head + 1) % SIZE;
    800046e2:	001a079b          	addiw	a5,s4,1
    800046e6:	46d1                	li	a3,20
    800046e8:	02d7e7bb          	remw	a5,a5,a3
    800046ec:	c31c                	sw	a5,0(a4)
  releasesleep(&lock_delete);
    800046ee:	8526                	mv	a0,s1
    800046f0:	00001097          	auipc	ra,0x1
    800046f4:	6aa080e7          	jalr	1706(ra) # 80005d9a <releasesleep>
  acquiresleep(&buffer[index].lock);
    800046f8:	09800a93          	li	s5,152
    800046fc:	035a0ab3          	mul	s5,s4,s5
    80004700:	008a8493          	addi	s1,s5,8
    80004704:	00015917          	auipc	s2,0x15
    80004708:	8c490913          	addi	s2,s2,-1852 # 80018fc8 <buffer>
    8000470c:	94ca                	add	s1,s1,s2
    8000470e:	8526                	mv	a0,s1
    80004710:	00001097          	auipc	ra,0x1
    80004714:	634080e7          	jalr	1588(ra) # 80005d44 <acquiresleep>
  while (!buffer[index].full)
    80004718:	9956                	add	s2,s2,s5
    8000471a:	00492783          	lw	a5,4(s2)
    8000471e:	e785                	bnez	a5,80004746 <sys_cond_consume+0x94>
    cond_wait(&buffer[index].inserted, &buffer[index].lock);
    80004720:	00015997          	auipc	s3,0x15
    80004724:	8e098993          	addi	s3,s3,-1824 # 80019000 <buffer+0x38>
    80004728:	99d6                	add	s3,s3,s5
  while (!buffer[index].full)
    8000472a:	00015917          	auipc	s2,0x15
    8000472e:	89e90913          	addi	s2,s2,-1890 # 80018fc8 <buffer>
    80004732:	9956                	add	s2,s2,s5
    cond_wait(&buffer[index].inserted, &buffer[index].lock);
    80004734:	85a6                	mv	a1,s1
    80004736:	854e                	mv	a0,s3
    80004738:	00003097          	auipc	ra,0x3
    8000473c:	49a080e7          	jalr	1178(ra) # 80007bd2 <cond_wait>
  while (!buffer[index].full)
    80004740:	00492783          	lw	a5,4(s2)
    80004744:	dbe5                	beqz	a5,80004734 <sys_cond_consume+0x82>
  v = buffer[index].x;
    80004746:	00015517          	auipc	a0,0x15
    8000474a:	88250513          	addi	a0,a0,-1918 # 80018fc8 <buffer>
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
    8000476a:	484080e7          	jalr	1156(ra) # 80007bea <cond_signal>
  releasesleep(&buffer[index].lock);
    8000476e:	8526                	mv	a0,s1
    80004770:	00001097          	auipc	ra,0x1
    80004774:	62a080e7          	jalr	1578(ra) # 80005d9a <releasesleep>
  acquiresleep(&lock_print);
    80004778:	00015497          	auipc	s1,0x15
    8000477c:	82048493          	addi	s1,s1,-2016 # 80018f98 <lock_print>
    80004780:	8526                	mv	a0,s1
    80004782:	00001097          	auipc	ra,0x1
    80004786:	5c2080e7          	jalr	1474(ra) # 80005d44 <acquiresleep>
  printf("%d ", v);
    8000478a:	85ca                	mv	a1,s2
    8000478c:	00005517          	auipc	a0,0x5
    80004790:	0dc50513          	addi	a0,a0,220 # 80009868 <syscalls+0x208>
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	dee080e7          	jalr	-530(ra) # 80000582 <printf>
  releasesleep(&lock_print);
    8000479c:	8526                	mv	a0,s1
    8000479e:	00001097          	auipc	ra,0x1
    800047a2:	5fc080e7          	jalr	1532(ra) # 80005d9a <releasesleep>
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
    800047bc:	e422                	sd	s0,8(sp)
    800047be:	0800                	addi	s0,sp,16
  return 0;
}
    800047c0:	4501                	li	a0,0
    800047c2:	6422                	ld	s0,8(sp)
    800047c4:	0141                	addi	sp,sp,16
    800047c6:	8082                	ret

00000000800047c8 <sys_sem_produce>:

uint64
sys_sem_produce(void)
{
    800047c8:	1141                	addi	sp,sp,-16
    800047ca:	e422                	sd	s0,8(sp)
    800047cc:	0800                	addi	s0,sp,16
  return 0;
}
    800047ce:	4501                	li	a0,0
    800047d0:	6422                	ld	s0,8(sp)
    800047d2:	0141                	addi	sp,sp,16
    800047d4:	8082                	ret

00000000800047d6 <sys_sem_consume>:

uint64
sys_sem_consume(void)
{
    800047d6:	1141                	addi	sp,sp,-16
    800047d8:	e422                	sd	s0,8(sp)
    800047da:	0800                	addi	s0,sp,16
  return 0;
    800047dc:	4501                	li	a0,0
    800047de:	6422                	ld	s0,8(sp)
    800047e0:	0141                	addi	sp,sp,16
    800047e2:	8082                	ret

00000000800047e4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800047e4:	7179                	addi	sp,sp,-48
    800047e6:	f406                	sd	ra,40(sp)
    800047e8:	f022                	sd	s0,32(sp)
    800047ea:	ec26                	sd	s1,24(sp)
    800047ec:	e84a                	sd	s2,16(sp)
    800047ee:	e44e                	sd	s3,8(sp)
    800047f0:	e052                	sd	s4,0(sp)
    800047f2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800047f4:	00005597          	auipc	a1,0x5
    800047f8:	07c58593          	addi	a1,a1,124 # 80009870 <syscalls+0x210>
    800047fc:	00015517          	auipc	a0,0x15
    80004800:	3ac50513          	addi	a0,a0,940 # 80019ba8 <bcache>
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	33a080e7          	jalr	826(ra) # 80000b3e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000480c:	0001d797          	auipc	a5,0x1d
    80004810:	39c78793          	addi	a5,a5,924 # 80021ba8 <bcache+0x8000>
    80004814:	0001d717          	auipc	a4,0x1d
    80004818:	5fc70713          	addi	a4,a4,1532 # 80021e10 <bcache+0x8268>
    8000481c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80004820:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004824:	00015497          	auipc	s1,0x15
    80004828:	39c48493          	addi	s1,s1,924 # 80019bc0 <bcache+0x18>
    b->next = bcache.head.next;
    8000482c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000482e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80004830:	00005a17          	auipc	s4,0x5
    80004834:	048a0a13          	addi	s4,s4,72 # 80009878 <syscalls+0x218>
    b->next = bcache.head.next;
    80004838:	2b893783          	ld	a5,696(s2)
    8000483c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000483e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80004842:	85d2                	mv	a1,s4
    80004844:	01048513          	addi	a0,s1,16
    80004848:	00001097          	auipc	ra,0x1
    8000484c:	4c2080e7          	jalr	1218(ra) # 80005d0a <initsleeplock>
    bcache.head.next->prev = b;
    80004850:	2b893783          	ld	a5,696(s2)
    80004854:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80004856:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000485a:	45848493          	addi	s1,s1,1112
    8000485e:	fd349de3          	bne	s1,s3,80004838 <binit+0x54>
  }
}
    80004862:	70a2                	ld	ra,40(sp)
    80004864:	7402                	ld	s0,32(sp)
    80004866:	64e2                	ld	s1,24(sp)
    80004868:	6942                	ld	s2,16(sp)
    8000486a:	69a2                	ld	s3,8(sp)
    8000486c:	6a02                	ld	s4,0(sp)
    8000486e:	6145                	addi	sp,sp,48
    80004870:	8082                	ret

0000000080004872 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80004872:	7179                	addi	sp,sp,-48
    80004874:	f406                	sd	ra,40(sp)
    80004876:	f022                	sd	s0,32(sp)
    80004878:	ec26                	sd	s1,24(sp)
    8000487a:	e84a                	sd	s2,16(sp)
    8000487c:	e44e                	sd	s3,8(sp)
    8000487e:	1800                	addi	s0,sp,48
    80004880:	892a                	mv	s2,a0
    80004882:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80004884:	00015517          	auipc	a0,0x15
    80004888:	32450513          	addi	a0,a0,804 # 80019ba8 <bcache>
    8000488c:	ffffc097          	auipc	ra,0xffffc
    80004890:	342080e7          	jalr	834(ra) # 80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004894:	0001d497          	auipc	s1,0x1d
    80004898:	5cc4b483          	ld	s1,1484(s1) # 80021e60 <bcache+0x82b8>
    8000489c:	0001d797          	auipc	a5,0x1d
    800048a0:	57478793          	addi	a5,a5,1396 # 80021e10 <bcache+0x8268>
    800048a4:	02f48f63          	beq	s1,a5,800048e2 <bread+0x70>
    800048a8:	873e                	mv	a4,a5
    800048aa:	a021                	j	800048b2 <bread+0x40>
    800048ac:	68a4                	ld	s1,80(s1)
    800048ae:	02e48a63          	beq	s1,a4,800048e2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800048b2:	449c                	lw	a5,8(s1)
    800048b4:	ff279ce3          	bne	a5,s2,800048ac <bread+0x3a>
    800048b8:	44dc                	lw	a5,12(s1)
    800048ba:	ff3799e3          	bne	a5,s3,800048ac <bread+0x3a>
      b->refcnt++;
    800048be:	40bc                	lw	a5,64(s1)
    800048c0:	2785                	addiw	a5,a5,1
    800048c2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800048c4:	00015517          	auipc	a0,0x15
    800048c8:	2e450513          	addi	a0,a0,740 # 80019ba8 <bcache>
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	3b6080e7          	jalr	950(ra) # 80000c82 <release>
      acquiresleep(&b->lock);
    800048d4:	01048513          	addi	a0,s1,16
    800048d8:	00001097          	auipc	ra,0x1
    800048dc:	46c080e7          	jalr	1132(ra) # 80005d44 <acquiresleep>
      return b;
    800048e0:	a8b9                	j	8000493e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800048e2:	0001d497          	auipc	s1,0x1d
    800048e6:	5764b483          	ld	s1,1398(s1) # 80021e58 <bcache+0x82b0>
    800048ea:	0001d797          	auipc	a5,0x1d
    800048ee:	52678793          	addi	a5,a5,1318 # 80021e10 <bcache+0x8268>
    800048f2:	00f48863          	beq	s1,a5,80004902 <bread+0x90>
    800048f6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800048f8:	40bc                	lw	a5,64(s1)
    800048fa:	cf81                	beqz	a5,80004912 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800048fc:	64a4                	ld	s1,72(s1)
    800048fe:	fee49de3          	bne	s1,a4,800048f8 <bread+0x86>
  panic("bget: no buffers");
    80004902:	00005517          	auipc	a0,0x5
    80004906:	f7e50513          	addi	a0,a0,-130 # 80009880 <syscalls+0x220>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	c2e080e7          	jalr	-978(ra) # 80000538 <panic>
      b->dev = dev;
    80004912:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80004916:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000491a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000491e:	4785                	li	a5,1
    80004920:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004922:	00015517          	auipc	a0,0x15
    80004926:	28650513          	addi	a0,a0,646 # 80019ba8 <bcache>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	358080e7          	jalr	856(ra) # 80000c82 <release>
      acquiresleep(&b->lock);
    80004932:	01048513          	addi	a0,s1,16
    80004936:	00001097          	auipc	ra,0x1
    8000493a:	40e080e7          	jalr	1038(ra) # 80005d44 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000493e:	409c                	lw	a5,0(s1)
    80004940:	cb89                	beqz	a5,80004952 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004942:	8526                	mv	a0,s1
    80004944:	70a2                	ld	ra,40(sp)
    80004946:	7402                	ld	s0,32(sp)
    80004948:	64e2                	ld	s1,24(sp)
    8000494a:	6942                	ld	s2,16(sp)
    8000494c:	69a2                	ld	s3,8(sp)
    8000494e:	6145                	addi	sp,sp,48
    80004950:	8082                	ret
    virtio_disk_rw(b, 0);
    80004952:	4581                	li	a1,0
    80004954:	8526                	mv	a0,s1
    80004956:	00003097          	auipc	ra,0x3
    8000495a:	f2c080e7          	jalr	-212(ra) # 80007882 <virtio_disk_rw>
    b->valid = 1;
    8000495e:	4785                	li	a5,1
    80004960:	c09c                	sw	a5,0(s1)
  return b;
    80004962:	b7c5                	j	80004942 <bread+0xd0>

0000000080004964 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004964:	1101                	addi	sp,sp,-32
    80004966:	ec06                	sd	ra,24(sp)
    80004968:	e822                	sd	s0,16(sp)
    8000496a:	e426                	sd	s1,8(sp)
    8000496c:	1000                	addi	s0,sp,32
    8000496e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004970:	0541                	addi	a0,a0,16
    80004972:	00001097          	auipc	ra,0x1
    80004976:	46c080e7          	jalr	1132(ra) # 80005dde <holdingsleep>
    8000497a:	cd01                	beqz	a0,80004992 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000497c:	4585                	li	a1,1
    8000497e:	8526                	mv	a0,s1
    80004980:	00003097          	auipc	ra,0x3
    80004984:	f02080e7          	jalr	-254(ra) # 80007882 <virtio_disk_rw>
}
    80004988:	60e2                	ld	ra,24(sp)
    8000498a:	6442                	ld	s0,16(sp)
    8000498c:	64a2                	ld	s1,8(sp)
    8000498e:	6105                	addi	sp,sp,32
    80004990:	8082                	ret
    panic("bwrite");
    80004992:	00005517          	auipc	a0,0x5
    80004996:	f0650513          	addi	a0,a0,-250 # 80009898 <syscalls+0x238>
    8000499a:	ffffc097          	auipc	ra,0xffffc
    8000499e:	b9e080e7          	jalr	-1122(ra) # 80000538 <panic>

00000000800049a2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800049a2:	1101                	addi	sp,sp,-32
    800049a4:	ec06                	sd	ra,24(sp)
    800049a6:	e822                	sd	s0,16(sp)
    800049a8:	e426                	sd	s1,8(sp)
    800049aa:	e04a                	sd	s2,0(sp)
    800049ac:	1000                	addi	s0,sp,32
    800049ae:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800049b0:	01050913          	addi	s2,a0,16
    800049b4:	854a                	mv	a0,s2
    800049b6:	00001097          	auipc	ra,0x1
    800049ba:	428080e7          	jalr	1064(ra) # 80005dde <holdingsleep>
    800049be:	c92d                	beqz	a0,80004a30 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800049c0:	854a                	mv	a0,s2
    800049c2:	00001097          	auipc	ra,0x1
    800049c6:	3d8080e7          	jalr	984(ra) # 80005d9a <releasesleep>

  acquire(&bcache.lock);
    800049ca:	00015517          	auipc	a0,0x15
    800049ce:	1de50513          	addi	a0,a0,478 # 80019ba8 <bcache>
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	1fc080e7          	jalr	508(ra) # 80000bce <acquire>
  b->refcnt--;
    800049da:	40bc                	lw	a5,64(s1)
    800049dc:	37fd                	addiw	a5,a5,-1
    800049de:	0007871b          	sext.w	a4,a5
    800049e2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800049e4:	eb05                	bnez	a4,80004a14 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800049e6:	68bc                	ld	a5,80(s1)
    800049e8:	64b8                	ld	a4,72(s1)
    800049ea:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800049ec:	64bc                	ld	a5,72(s1)
    800049ee:	68b8                	ld	a4,80(s1)
    800049f0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800049f2:	0001d797          	auipc	a5,0x1d
    800049f6:	1b678793          	addi	a5,a5,438 # 80021ba8 <bcache+0x8000>
    800049fa:	2b87b703          	ld	a4,696(a5)
    800049fe:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80004a00:	0001d717          	auipc	a4,0x1d
    80004a04:	41070713          	addi	a4,a4,1040 # 80021e10 <bcache+0x8268>
    80004a08:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80004a0a:	2b87b703          	ld	a4,696(a5)
    80004a0e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004a10:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004a14:	00015517          	auipc	a0,0x15
    80004a18:	19450513          	addi	a0,a0,404 # 80019ba8 <bcache>
    80004a1c:	ffffc097          	auipc	ra,0xffffc
    80004a20:	266080e7          	jalr	614(ra) # 80000c82 <release>
}
    80004a24:	60e2                	ld	ra,24(sp)
    80004a26:	6442                	ld	s0,16(sp)
    80004a28:	64a2                	ld	s1,8(sp)
    80004a2a:	6902                	ld	s2,0(sp)
    80004a2c:	6105                	addi	sp,sp,32
    80004a2e:	8082                	ret
    panic("brelse");
    80004a30:	00005517          	auipc	a0,0x5
    80004a34:	e7050513          	addi	a0,a0,-400 # 800098a0 <syscalls+0x240>
    80004a38:	ffffc097          	auipc	ra,0xffffc
    80004a3c:	b00080e7          	jalr	-1280(ra) # 80000538 <panic>

0000000080004a40 <bpin>:

void
bpin(struct buf *b) {
    80004a40:	1101                	addi	sp,sp,-32
    80004a42:	ec06                	sd	ra,24(sp)
    80004a44:	e822                	sd	s0,16(sp)
    80004a46:	e426                	sd	s1,8(sp)
    80004a48:	1000                	addi	s0,sp,32
    80004a4a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004a4c:	00015517          	auipc	a0,0x15
    80004a50:	15c50513          	addi	a0,a0,348 # 80019ba8 <bcache>
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	17a080e7          	jalr	378(ra) # 80000bce <acquire>
  b->refcnt++;
    80004a5c:	40bc                	lw	a5,64(s1)
    80004a5e:	2785                	addiw	a5,a5,1
    80004a60:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004a62:	00015517          	auipc	a0,0x15
    80004a66:	14650513          	addi	a0,a0,326 # 80019ba8 <bcache>
    80004a6a:	ffffc097          	auipc	ra,0xffffc
    80004a6e:	218080e7          	jalr	536(ra) # 80000c82 <release>
}
    80004a72:	60e2                	ld	ra,24(sp)
    80004a74:	6442                	ld	s0,16(sp)
    80004a76:	64a2                	ld	s1,8(sp)
    80004a78:	6105                	addi	sp,sp,32
    80004a7a:	8082                	ret

0000000080004a7c <bunpin>:

void
bunpin(struct buf *b) {
    80004a7c:	1101                	addi	sp,sp,-32
    80004a7e:	ec06                	sd	ra,24(sp)
    80004a80:	e822                	sd	s0,16(sp)
    80004a82:	e426                	sd	s1,8(sp)
    80004a84:	1000                	addi	s0,sp,32
    80004a86:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004a88:	00015517          	auipc	a0,0x15
    80004a8c:	12050513          	addi	a0,a0,288 # 80019ba8 <bcache>
    80004a90:	ffffc097          	auipc	ra,0xffffc
    80004a94:	13e080e7          	jalr	318(ra) # 80000bce <acquire>
  b->refcnt--;
    80004a98:	40bc                	lw	a5,64(s1)
    80004a9a:	37fd                	addiw	a5,a5,-1
    80004a9c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004a9e:	00015517          	auipc	a0,0x15
    80004aa2:	10a50513          	addi	a0,a0,266 # 80019ba8 <bcache>
    80004aa6:	ffffc097          	auipc	ra,0xffffc
    80004aaa:	1dc080e7          	jalr	476(ra) # 80000c82 <release>
}
    80004aae:	60e2                	ld	ra,24(sp)
    80004ab0:	6442                	ld	s0,16(sp)
    80004ab2:	64a2                	ld	s1,8(sp)
    80004ab4:	6105                	addi	sp,sp,32
    80004ab6:	8082                	ret

0000000080004ab8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004ab8:	1101                	addi	sp,sp,-32
    80004aba:	ec06                	sd	ra,24(sp)
    80004abc:	e822                	sd	s0,16(sp)
    80004abe:	e426                	sd	s1,8(sp)
    80004ac0:	e04a                	sd	s2,0(sp)
    80004ac2:	1000                	addi	s0,sp,32
    80004ac4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004ac6:	00d5d59b          	srliw	a1,a1,0xd
    80004aca:	0001d797          	auipc	a5,0x1d
    80004ace:	7ba7a783          	lw	a5,1978(a5) # 80022284 <sb+0x1c>
    80004ad2:	9dbd                	addw	a1,a1,a5
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	d9e080e7          	jalr	-610(ra) # 80004872 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80004adc:	0074f713          	andi	a4,s1,7
    80004ae0:	4785                	li	a5,1
    80004ae2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004ae6:	14ce                	slli	s1,s1,0x33
    80004ae8:	90d9                	srli	s1,s1,0x36
    80004aea:	00950733          	add	a4,a0,s1
    80004aee:	05874703          	lbu	a4,88(a4)
    80004af2:	00e7f6b3          	and	a3,a5,a4
    80004af6:	c69d                	beqz	a3,80004b24 <bfree+0x6c>
    80004af8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80004afa:	94aa                	add	s1,s1,a0
    80004afc:	fff7c793          	not	a5,a5
    80004b00:	8f7d                	and	a4,a4,a5
    80004b02:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80004b06:	00001097          	auipc	ra,0x1
    80004b0a:	120080e7          	jalr	288(ra) # 80005c26 <log_write>
  brelse(bp);
    80004b0e:	854a                	mv	a0,s2
    80004b10:	00000097          	auipc	ra,0x0
    80004b14:	e92080e7          	jalr	-366(ra) # 800049a2 <brelse>
}
    80004b18:	60e2                	ld	ra,24(sp)
    80004b1a:	6442                	ld	s0,16(sp)
    80004b1c:	64a2                	ld	s1,8(sp)
    80004b1e:	6902                	ld	s2,0(sp)
    80004b20:	6105                	addi	sp,sp,32
    80004b22:	8082                	ret
    panic("freeing free block");
    80004b24:	00005517          	auipc	a0,0x5
    80004b28:	d8450513          	addi	a0,a0,-636 # 800098a8 <syscalls+0x248>
    80004b2c:	ffffc097          	auipc	ra,0xffffc
    80004b30:	a0c080e7          	jalr	-1524(ra) # 80000538 <panic>

0000000080004b34 <balloc>:
{
    80004b34:	711d                	addi	sp,sp,-96
    80004b36:	ec86                	sd	ra,88(sp)
    80004b38:	e8a2                	sd	s0,80(sp)
    80004b3a:	e4a6                	sd	s1,72(sp)
    80004b3c:	e0ca                	sd	s2,64(sp)
    80004b3e:	fc4e                	sd	s3,56(sp)
    80004b40:	f852                	sd	s4,48(sp)
    80004b42:	f456                	sd	s5,40(sp)
    80004b44:	f05a                	sd	s6,32(sp)
    80004b46:	ec5e                	sd	s7,24(sp)
    80004b48:	e862                	sd	s8,16(sp)
    80004b4a:	e466                	sd	s9,8(sp)
    80004b4c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80004b4e:	0001d797          	auipc	a5,0x1d
    80004b52:	71e7a783          	lw	a5,1822(a5) # 8002226c <sb+0x4>
    80004b56:	cbc1                	beqz	a5,80004be6 <balloc+0xb2>
    80004b58:	8baa                	mv	s7,a0
    80004b5a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004b5c:	0001db17          	auipc	s6,0x1d
    80004b60:	70cb0b13          	addi	s6,s6,1804 # 80022268 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004b64:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004b66:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004b68:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004b6a:	6c89                	lui	s9,0x2
    80004b6c:	a831                	j	80004b88 <balloc+0x54>
    brelse(bp);
    80004b6e:	854a                	mv	a0,s2
    80004b70:	00000097          	auipc	ra,0x0
    80004b74:	e32080e7          	jalr	-462(ra) # 800049a2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004b78:	015c87bb          	addw	a5,s9,s5
    80004b7c:	00078a9b          	sext.w	s5,a5
    80004b80:	004b2703          	lw	a4,4(s6)
    80004b84:	06eaf163          	bgeu	s5,a4,80004be6 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80004b88:	41fad79b          	sraiw	a5,s5,0x1f
    80004b8c:	0137d79b          	srliw	a5,a5,0x13
    80004b90:	015787bb          	addw	a5,a5,s5
    80004b94:	40d7d79b          	sraiw	a5,a5,0xd
    80004b98:	01cb2583          	lw	a1,28(s6)
    80004b9c:	9dbd                	addw	a1,a1,a5
    80004b9e:	855e                	mv	a0,s7
    80004ba0:	00000097          	auipc	ra,0x0
    80004ba4:	cd2080e7          	jalr	-814(ra) # 80004872 <bread>
    80004ba8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004baa:	004b2503          	lw	a0,4(s6)
    80004bae:	000a849b          	sext.w	s1,s5
    80004bb2:	8762                	mv	a4,s8
    80004bb4:	faa4fde3          	bgeu	s1,a0,80004b6e <balloc+0x3a>
      m = 1 << (bi % 8);
    80004bb8:	00777693          	andi	a3,a4,7
    80004bbc:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004bc0:	41f7579b          	sraiw	a5,a4,0x1f
    80004bc4:	01d7d79b          	srliw	a5,a5,0x1d
    80004bc8:	9fb9                	addw	a5,a5,a4
    80004bca:	4037d79b          	sraiw	a5,a5,0x3
    80004bce:	00f90633          	add	a2,s2,a5
    80004bd2:	05864603          	lbu	a2,88(a2)
    80004bd6:	00c6f5b3          	and	a1,a3,a2
    80004bda:	cd91                	beqz	a1,80004bf6 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004bdc:	2705                	addiw	a4,a4,1
    80004bde:	2485                	addiw	s1,s1,1
    80004be0:	fd471ae3          	bne	a4,s4,80004bb4 <balloc+0x80>
    80004be4:	b769                	j	80004b6e <balloc+0x3a>
  panic("balloc: out of blocks");
    80004be6:	00005517          	auipc	a0,0x5
    80004bea:	cda50513          	addi	a0,a0,-806 # 800098c0 <syscalls+0x260>
    80004bee:	ffffc097          	auipc	ra,0xffffc
    80004bf2:	94a080e7          	jalr	-1718(ra) # 80000538 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80004bf6:	97ca                	add	a5,a5,s2
    80004bf8:	8e55                	or	a2,a2,a3
    80004bfa:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80004bfe:	854a                	mv	a0,s2
    80004c00:	00001097          	auipc	ra,0x1
    80004c04:	026080e7          	jalr	38(ra) # 80005c26 <log_write>
        brelse(bp);
    80004c08:	854a                	mv	a0,s2
    80004c0a:	00000097          	auipc	ra,0x0
    80004c0e:	d98080e7          	jalr	-616(ra) # 800049a2 <brelse>
  bp = bread(dev, bno);
    80004c12:	85a6                	mv	a1,s1
    80004c14:	855e                	mv	a0,s7
    80004c16:	00000097          	auipc	ra,0x0
    80004c1a:	c5c080e7          	jalr	-932(ra) # 80004872 <bread>
    80004c1e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004c20:	40000613          	li	a2,1024
    80004c24:	4581                	li	a1,0
    80004c26:	05850513          	addi	a0,a0,88
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	0a0080e7          	jalr	160(ra) # 80000cca <memset>
  log_write(bp);
    80004c32:	854a                	mv	a0,s2
    80004c34:	00001097          	auipc	ra,0x1
    80004c38:	ff2080e7          	jalr	-14(ra) # 80005c26 <log_write>
  brelse(bp);
    80004c3c:	854a                	mv	a0,s2
    80004c3e:	00000097          	auipc	ra,0x0
    80004c42:	d64080e7          	jalr	-668(ra) # 800049a2 <brelse>
}
    80004c46:	8526                	mv	a0,s1
    80004c48:	60e6                	ld	ra,88(sp)
    80004c4a:	6446                	ld	s0,80(sp)
    80004c4c:	64a6                	ld	s1,72(sp)
    80004c4e:	6906                	ld	s2,64(sp)
    80004c50:	79e2                	ld	s3,56(sp)
    80004c52:	7a42                	ld	s4,48(sp)
    80004c54:	7aa2                	ld	s5,40(sp)
    80004c56:	7b02                	ld	s6,32(sp)
    80004c58:	6be2                	ld	s7,24(sp)
    80004c5a:	6c42                	ld	s8,16(sp)
    80004c5c:	6ca2                	ld	s9,8(sp)
    80004c5e:	6125                	addi	sp,sp,96
    80004c60:	8082                	ret

0000000080004c62 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004c62:	7179                	addi	sp,sp,-48
    80004c64:	f406                	sd	ra,40(sp)
    80004c66:	f022                	sd	s0,32(sp)
    80004c68:	ec26                	sd	s1,24(sp)
    80004c6a:	e84a                	sd	s2,16(sp)
    80004c6c:	e44e                	sd	s3,8(sp)
    80004c6e:	e052                	sd	s4,0(sp)
    80004c70:	1800                	addi	s0,sp,48
    80004c72:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004c74:	47ad                	li	a5,11
    80004c76:	04b7fe63          	bgeu	a5,a1,80004cd2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80004c7a:	ff45849b          	addiw	s1,a1,-12
    80004c7e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004c82:	0ff00793          	li	a5,255
    80004c86:	0ae7e463          	bltu	a5,a4,80004d2e <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004c8a:	08052583          	lw	a1,128(a0)
    80004c8e:	c5b5                	beqz	a1,80004cfa <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004c90:	00092503          	lw	a0,0(s2)
    80004c94:	00000097          	auipc	ra,0x0
    80004c98:	bde080e7          	jalr	-1058(ra) # 80004872 <bread>
    80004c9c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004c9e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004ca2:	02049713          	slli	a4,s1,0x20
    80004ca6:	01e75593          	srli	a1,a4,0x1e
    80004caa:	00b784b3          	add	s1,a5,a1
    80004cae:	0004a983          	lw	s3,0(s1)
    80004cb2:	04098e63          	beqz	s3,80004d0e <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004cb6:	8552                	mv	a0,s4
    80004cb8:	00000097          	auipc	ra,0x0
    80004cbc:	cea080e7          	jalr	-790(ra) # 800049a2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004cc0:	854e                	mv	a0,s3
    80004cc2:	70a2                	ld	ra,40(sp)
    80004cc4:	7402                	ld	s0,32(sp)
    80004cc6:	64e2                	ld	s1,24(sp)
    80004cc8:	6942                	ld	s2,16(sp)
    80004cca:	69a2                	ld	s3,8(sp)
    80004ccc:	6a02                	ld	s4,0(sp)
    80004cce:	6145                	addi	sp,sp,48
    80004cd0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004cd2:	02059793          	slli	a5,a1,0x20
    80004cd6:	01e7d593          	srli	a1,a5,0x1e
    80004cda:	00b504b3          	add	s1,a0,a1
    80004cde:	0504a983          	lw	s3,80(s1)
    80004ce2:	fc099fe3          	bnez	s3,80004cc0 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80004ce6:	4108                	lw	a0,0(a0)
    80004ce8:	00000097          	auipc	ra,0x0
    80004cec:	e4c080e7          	jalr	-436(ra) # 80004b34 <balloc>
    80004cf0:	0005099b          	sext.w	s3,a0
    80004cf4:	0534a823          	sw	s3,80(s1)
    80004cf8:	b7e1                	j	80004cc0 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80004cfa:	4108                	lw	a0,0(a0)
    80004cfc:	00000097          	auipc	ra,0x0
    80004d00:	e38080e7          	jalr	-456(ra) # 80004b34 <balloc>
    80004d04:	0005059b          	sext.w	a1,a0
    80004d08:	08b92023          	sw	a1,128(s2)
    80004d0c:	b751                	j	80004c90 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004d0e:	00092503          	lw	a0,0(s2)
    80004d12:	00000097          	auipc	ra,0x0
    80004d16:	e22080e7          	jalr	-478(ra) # 80004b34 <balloc>
    80004d1a:	0005099b          	sext.w	s3,a0
    80004d1e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004d22:	8552                	mv	a0,s4
    80004d24:	00001097          	auipc	ra,0x1
    80004d28:	f02080e7          	jalr	-254(ra) # 80005c26 <log_write>
    80004d2c:	b769                	j	80004cb6 <bmap+0x54>
  panic("bmap: out of range");
    80004d2e:	00005517          	auipc	a0,0x5
    80004d32:	baa50513          	addi	a0,a0,-1110 # 800098d8 <syscalls+0x278>
    80004d36:	ffffc097          	auipc	ra,0xffffc
    80004d3a:	802080e7          	jalr	-2046(ra) # 80000538 <panic>

0000000080004d3e <iget>:
{
    80004d3e:	7179                	addi	sp,sp,-48
    80004d40:	f406                	sd	ra,40(sp)
    80004d42:	f022                	sd	s0,32(sp)
    80004d44:	ec26                	sd	s1,24(sp)
    80004d46:	e84a                	sd	s2,16(sp)
    80004d48:	e44e                	sd	s3,8(sp)
    80004d4a:	e052                	sd	s4,0(sp)
    80004d4c:	1800                	addi	s0,sp,48
    80004d4e:	89aa                	mv	s3,a0
    80004d50:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004d52:	0001d517          	auipc	a0,0x1d
    80004d56:	53650513          	addi	a0,a0,1334 # 80022288 <itable>
    80004d5a:	ffffc097          	auipc	ra,0xffffc
    80004d5e:	e74080e7          	jalr	-396(ra) # 80000bce <acquire>
  empty = 0;
    80004d62:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004d64:	0001d497          	auipc	s1,0x1d
    80004d68:	53c48493          	addi	s1,s1,1340 # 800222a0 <itable+0x18>
    80004d6c:	0001f697          	auipc	a3,0x1f
    80004d70:	fc468693          	addi	a3,a3,-60 # 80023d30 <log>
    80004d74:	a039                	j	80004d82 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004d76:	02090b63          	beqz	s2,80004dac <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004d7a:	08848493          	addi	s1,s1,136
    80004d7e:	02d48a63          	beq	s1,a3,80004db2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004d82:	449c                	lw	a5,8(s1)
    80004d84:	fef059e3          	blez	a5,80004d76 <iget+0x38>
    80004d88:	4098                	lw	a4,0(s1)
    80004d8a:	ff3716e3          	bne	a4,s3,80004d76 <iget+0x38>
    80004d8e:	40d8                	lw	a4,4(s1)
    80004d90:	ff4713e3          	bne	a4,s4,80004d76 <iget+0x38>
      ip->ref++;
    80004d94:	2785                	addiw	a5,a5,1
    80004d96:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004d98:	0001d517          	auipc	a0,0x1d
    80004d9c:	4f050513          	addi	a0,a0,1264 # 80022288 <itable>
    80004da0:	ffffc097          	auipc	ra,0xffffc
    80004da4:	ee2080e7          	jalr	-286(ra) # 80000c82 <release>
      return ip;
    80004da8:	8926                	mv	s2,s1
    80004daa:	a03d                	j	80004dd8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004dac:	f7f9                	bnez	a5,80004d7a <iget+0x3c>
    80004dae:	8926                	mv	s2,s1
    80004db0:	b7e9                	j	80004d7a <iget+0x3c>
  if(empty == 0)
    80004db2:	02090c63          	beqz	s2,80004dea <iget+0xac>
  ip->dev = dev;
    80004db6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004dba:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004dbe:	4785                	li	a5,1
    80004dc0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004dc4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004dc8:	0001d517          	auipc	a0,0x1d
    80004dcc:	4c050513          	addi	a0,a0,1216 # 80022288 <itable>
    80004dd0:	ffffc097          	auipc	ra,0xffffc
    80004dd4:	eb2080e7          	jalr	-334(ra) # 80000c82 <release>
}
    80004dd8:	854a                	mv	a0,s2
    80004dda:	70a2                	ld	ra,40(sp)
    80004ddc:	7402                	ld	s0,32(sp)
    80004dde:	64e2                	ld	s1,24(sp)
    80004de0:	6942                	ld	s2,16(sp)
    80004de2:	69a2                	ld	s3,8(sp)
    80004de4:	6a02                	ld	s4,0(sp)
    80004de6:	6145                	addi	sp,sp,48
    80004de8:	8082                	ret
    panic("iget: no inodes");
    80004dea:	00005517          	auipc	a0,0x5
    80004dee:	b0650513          	addi	a0,a0,-1274 # 800098f0 <syscalls+0x290>
    80004df2:	ffffb097          	auipc	ra,0xffffb
    80004df6:	746080e7          	jalr	1862(ra) # 80000538 <panic>

0000000080004dfa <fsinit>:
fsinit(int dev) {
    80004dfa:	7179                	addi	sp,sp,-48
    80004dfc:	f406                	sd	ra,40(sp)
    80004dfe:	f022                	sd	s0,32(sp)
    80004e00:	ec26                	sd	s1,24(sp)
    80004e02:	e84a                	sd	s2,16(sp)
    80004e04:	e44e                	sd	s3,8(sp)
    80004e06:	1800                	addi	s0,sp,48
    80004e08:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80004e0a:	4585                	li	a1,1
    80004e0c:	00000097          	auipc	ra,0x0
    80004e10:	a66080e7          	jalr	-1434(ra) # 80004872 <bread>
    80004e14:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80004e16:	0001d997          	auipc	s3,0x1d
    80004e1a:	45298993          	addi	s3,s3,1106 # 80022268 <sb>
    80004e1e:	02000613          	li	a2,32
    80004e22:	05850593          	addi	a1,a0,88
    80004e26:	854e                	mv	a0,s3
    80004e28:	ffffc097          	auipc	ra,0xffffc
    80004e2c:	efe080e7          	jalr	-258(ra) # 80000d26 <memmove>
  brelse(bp);
    80004e30:	8526                	mv	a0,s1
    80004e32:	00000097          	auipc	ra,0x0
    80004e36:	b70080e7          	jalr	-1168(ra) # 800049a2 <brelse>
  if(sb.magic != FSMAGIC)
    80004e3a:	0009a703          	lw	a4,0(s3)
    80004e3e:	102037b7          	lui	a5,0x10203
    80004e42:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004e46:	02f71263          	bne	a4,a5,80004e6a <fsinit+0x70>
  initlog(dev, &sb);
    80004e4a:	0001d597          	auipc	a1,0x1d
    80004e4e:	41e58593          	addi	a1,a1,1054 # 80022268 <sb>
    80004e52:	854a                	mv	a0,s2
    80004e54:	00001097          	auipc	ra,0x1
    80004e58:	b56080e7          	jalr	-1194(ra) # 800059aa <initlog>
}
    80004e5c:	70a2                	ld	ra,40(sp)
    80004e5e:	7402                	ld	s0,32(sp)
    80004e60:	64e2                	ld	s1,24(sp)
    80004e62:	6942                	ld	s2,16(sp)
    80004e64:	69a2                	ld	s3,8(sp)
    80004e66:	6145                	addi	sp,sp,48
    80004e68:	8082                	ret
    panic("invalid file system");
    80004e6a:	00005517          	auipc	a0,0x5
    80004e6e:	a9650513          	addi	a0,a0,-1386 # 80009900 <syscalls+0x2a0>
    80004e72:	ffffb097          	auipc	ra,0xffffb
    80004e76:	6c6080e7          	jalr	1734(ra) # 80000538 <panic>

0000000080004e7a <iinit>:
{
    80004e7a:	7179                	addi	sp,sp,-48
    80004e7c:	f406                	sd	ra,40(sp)
    80004e7e:	f022                	sd	s0,32(sp)
    80004e80:	ec26                	sd	s1,24(sp)
    80004e82:	e84a                	sd	s2,16(sp)
    80004e84:	e44e                	sd	s3,8(sp)
    80004e86:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004e88:	00005597          	auipc	a1,0x5
    80004e8c:	a9058593          	addi	a1,a1,-1392 # 80009918 <syscalls+0x2b8>
    80004e90:	0001d517          	auipc	a0,0x1d
    80004e94:	3f850513          	addi	a0,a0,1016 # 80022288 <itable>
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	ca6080e7          	jalr	-858(ra) # 80000b3e <initlock>
  for(i = 0; i < NINODE; i++) {
    80004ea0:	0001d497          	auipc	s1,0x1d
    80004ea4:	41048493          	addi	s1,s1,1040 # 800222b0 <itable+0x28>
    80004ea8:	0001f997          	auipc	s3,0x1f
    80004eac:	e9898993          	addi	s3,s3,-360 # 80023d40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004eb0:	00005917          	auipc	s2,0x5
    80004eb4:	a7090913          	addi	s2,s2,-1424 # 80009920 <syscalls+0x2c0>
    80004eb8:	85ca                	mv	a1,s2
    80004eba:	8526                	mv	a0,s1
    80004ebc:	00001097          	auipc	ra,0x1
    80004ec0:	e4e080e7          	jalr	-434(ra) # 80005d0a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004ec4:	08848493          	addi	s1,s1,136
    80004ec8:	ff3498e3          	bne	s1,s3,80004eb8 <iinit+0x3e>
}
    80004ecc:	70a2                	ld	ra,40(sp)
    80004ece:	7402                	ld	s0,32(sp)
    80004ed0:	64e2                	ld	s1,24(sp)
    80004ed2:	6942                	ld	s2,16(sp)
    80004ed4:	69a2                	ld	s3,8(sp)
    80004ed6:	6145                	addi	sp,sp,48
    80004ed8:	8082                	ret

0000000080004eda <ialloc>:
{
    80004eda:	715d                	addi	sp,sp,-80
    80004edc:	e486                	sd	ra,72(sp)
    80004ede:	e0a2                	sd	s0,64(sp)
    80004ee0:	fc26                	sd	s1,56(sp)
    80004ee2:	f84a                	sd	s2,48(sp)
    80004ee4:	f44e                	sd	s3,40(sp)
    80004ee6:	f052                	sd	s4,32(sp)
    80004ee8:	ec56                	sd	s5,24(sp)
    80004eea:	e85a                	sd	s6,16(sp)
    80004eec:	e45e                	sd	s7,8(sp)
    80004eee:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004ef0:	0001d717          	auipc	a4,0x1d
    80004ef4:	38472703          	lw	a4,900(a4) # 80022274 <sb+0xc>
    80004ef8:	4785                	li	a5,1
    80004efa:	04e7fa63          	bgeu	a5,a4,80004f4e <ialloc+0x74>
    80004efe:	8aaa                	mv	s5,a0
    80004f00:	8bae                	mv	s7,a1
    80004f02:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004f04:	0001da17          	auipc	s4,0x1d
    80004f08:	364a0a13          	addi	s4,s4,868 # 80022268 <sb>
    80004f0c:	00048b1b          	sext.w	s6,s1
    80004f10:	0044d593          	srli	a1,s1,0x4
    80004f14:	018a2783          	lw	a5,24(s4)
    80004f18:	9dbd                	addw	a1,a1,a5
    80004f1a:	8556                	mv	a0,s5
    80004f1c:	00000097          	auipc	ra,0x0
    80004f20:	956080e7          	jalr	-1706(ra) # 80004872 <bread>
    80004f24:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80004f26:	05850993          	addi	s3,a0,88
    80004f2a:	00f4f793          	andi	a5,s1,15
    80004f2e:	079a                	slli	a5,a5,0x6
    80004f30:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004f32:	00099783          	lh	a5,0(s3)
    80004f36:	c785                	beqz	a5,80004f5e <ialloc+0x84>
    brelse(bp);
    80004f38:	00000097          	auipc	ra,0x0
    80004f3c:	a6a080e7          	jalr	-1430(ra) # 800049a2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004f40:	0485                	addi	s1,s1,1
    80004f42:	00ca2703          	lw	a4,12(s4)
    80004f46:	0004879b          	sext.w	a5,s1
    80004f4a:	fce7e1e3          	bltu	a5,a4,80004f0c <ialloc+0x32>
  panic("ialloc: no inodes");
    80004f4e:	00005517          	auipc	a0,0x5
    80004f52:	9da50513          	addi	a0,a0,-1574 # 80009928 <syscalls+0x2c8>
    80004f56:	ffffb097          	auipc	ra,0xffffb
    80004f5a:	5e2080e7          	jalr	1506(ra) # 80000538 <panic>
      memset(dip, 0, sizeof(*dip));
    80004f5e:	04000613          	li	a2,64
    80004f62:	4581                	li	a1,0
    80004f64:	854e                	mv	a0,s3
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	d64080e7          	jalr	-668(ra) # 80000cca <memset>
      dip->type = type;
    80004f6e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004f72:	854a                	mv	a0,s2
    80004f74:	00001097          	auipc	ra,0x1
    80004f78:	cb2080e7          	jalr	-846(ra) # 80005c26 <log_write>
      brelse(bp);
    80004f7c:	854a                	mv	a0,s2
    80004f7e:	00000097          	auipc	ra,0x0
    80004f82:	a24080e7          	jalr	-1500(ra) # 800049a2 <brelse>
      return iget(dev, inum);
    80004f86:	85da                	mv	a1,s6
    80004f88:	8556                	mv	a0,s5
    80004f8a:	00000097          	auipc	ra,0x0
    80004f8e:	db4080e7          	jalr	-588(ra) # 80004d3e <iget>
}
    80004f92:	60a6                	ld	ra,72(sp)
    80004f94:	6406                	ld	s0,64(sp)
    80004f96:	74e2                	ld	s1,56(sp)
    80004f98:	7942                	ld	s2,48(sp)
    80004f9a:	79a2                	ld	s3,40(sp)
    80004f9c:	7a02                	ld	s4,32(sp)
    80004f9e:	6ae2                	ld	s5,24(sp)
    80004fa0:	6b42                	ld	s6,16(sp)
    80004fa2:	6ba2                	ld	s7,8(sp)
    80004fa4:	6161                	addi	sp,sp,80
    80004fa6:	8082                	ret

0000000080004fa8 <iupdate>:
{
    80004fa8:	1101                	addi	sp,sp,-32
    80004faa:	ec06                	sd	ra,24(sp)
    80004fac:	e822                	sd	s0,16(sp)
    80004fae:	e426                	sd	s1,8(sp)
    80004fb0:	e04a                	sd	s2,0(sp)
    80004fb2:	1000                	addi	s0,sp,32
    80004fb4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004fb6:	415c                	lw	a5,4(a0)
    80004fb8:	0047d79b          	srliw	a5,a5,0x4
    80004fbc:	0001d597          	auipc	a1,0x1d
    80004fc0:	2c45a583          	lw	a1,708(a1) # 80022280 <sb+0x18>
    80004fc4:	9dbd                	addw	a1,a1,a5
    80004fc6:	4108                	lw	a0,0(a0)
    80004fc8:	00000097          	auipc	ra,0x0
    80004fcc:	8aa080e7          	jalr	-1878(ra) # 80004872 <bread>
    80004fd0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004fd2:	05850793          	addi	a5,a0,88
    80004fd6:	40d8                	lw	a4,4(s1)
    80004fd8:	8b3d                	andi	a4,a4,15
    80004fda:	071a                	slli	a4,a4,0x6
    80004fdc:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80004fde:	04449703          	lh	a4,68(s1)
    80004fe2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004fe6:	04649703          	lh	a4,70(s1)
    80004fea:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80004fee:	04849703          	lh	a4,72(s1)
    80004ff2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004ff6:	04a49703          	lh	a4,74(s1)
    80004ffa:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80004ffe:	44f8                	lw	a4,76(s1)
    80005000:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80005002:	03400613          	li	a2,52
    80005006:	05048593          	addi	a1,s1,80
    8000500a:	00c78513          	addi	a0,a5,12
    8000500e:	ffffc097          	auipc	ra,0xffffc
    80005012:	d18080e7          	jalr	-744(ra) # 80000d26 <memmove>
  log_write(bp);
    80005016:	854a                	mv	a0,s2
    80005018:	00001097          	auipc	ra,0x1
    8000501c:	c0e080e7          	jalr	-1010(ra) # 80005c26 <log_write>
  brelse(bp);
    80005020:	854a                	mv	a0,s2
    80005022:	00000097          	auipc	ra,0x0
    80005026:	980080e7          	jalr	-1664(ra) # 800049a2 <brelse>
}
    8000502a:	60e2                	ld	ra,24(sp)
    8000502c:	6442                	ld	s0,16(sp)
    8000502e:	64a2                	ld	s1,8(sp)
    80005030:	6902                	ld	s2,0(sp)
    80005032:	6105                	addi	sp,sp,32
    80005034:	8082                	ret

0000000080005036 <idup>:
{
    80005036:	1101                	addi	sp,sp,-32
    80005038:	ec06                	sd	ra,24(sp)
    8000503a:	e822                	sd	s0,16(sp)
    8000503c:	e426                	sd	s1,8(sp)
    8000503e:	1000                	addi	s0,sp,32
    80005040:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80005042:	0001d517          	auipc	a0,0x1d
    80005046:	24650513          	addi	a0,a0,582 # 80022288 <itable>
    8000504a:	ffffc097          	auipc	ra,0xffffc
    8000504e:	b84080e7          	jalr	-1148(ra) # 80000bce <acquire>
  ip->ref++;
    80005052:	449c                	lw	a5,8(s1)
    80005054:	2785                	addiw	a5,a5,1
    80005056:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80005058:	0001d517          	auipc	a0,0x1d
    8000505c:	23050513          	addi	a0,a0,560 # 80022288 <itable>
    80005060:	ffffc097          	auipc	ra,0xffffc
    80005064:	c22080e7          	jalr	-990(ra) # 80000c82 <release>
}
    80005068:	8526                	mv	a0,s1
    8000506a:	60e2                	ld	ra,24(sp)
    8000506c:	6442                	ld	s0,16(sp)
    8000506e:	64a2                	ld	s1,8(sp)
    80005070:	6105                	addi	sp,sp,32
    80005072:	8082                	ret

0000000080005074 <ilock>:
{
    80005074:	1101                	addi	sp,sp,-32
    80005076:	ec06                	sd	ra,24(sp)
    80005078:	e822                	sd	s0,16(sp)
    8000507a:	e426                	sd	s1,8(sp)
    8000507c:	e04a                	sd	s2,0(sp)
    8000507e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80005080:	c115                	beqz	a0,800050a4 <ilock+0x30>
    80005082:	84aa                	mv	s1,a0
    80005084:	451c                	lw	a5,8(a0)
    80005086:	00f05f63          	blez	a5,800050a4 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000508a:	0541                	addi	a0,a0,16
    8000508c:	00001097          	auipc	ra,0x1
    80005090:	cb8080e7          	jalr	-840(ra) # 80005d44 <acquiresleep>
  if(ip->valid == 0){
    80005094:	40bc                	lw	a5,64(s1)
    80005096:	cf99                	beqz	a5,800050b4 <ilock+0x40>
}
    80005098:	60e2                	ld	ra,24(sp)
    8000509a:	6442                	ld	s0,16(sp)
    8000509c:	64a2                	ld	s1,8(sp)
    8000509e:	6902                	ld	s2,0(sp)
    800050a0:	6105                	addi	sp,sp,32
    800050a2:	8082                	ret
    panic("ilock");
    800050a4:	00005517          	auipc	a0,0x5
    800050a8:	89c50513          	addi	a0,a0,-1892 # 80009940 <syscalls+0x2e0>
    800050ac:	ffffb097          	auipc	ra,0xffffb
    800050b0:	48c080e7          	jalr	1164(ra) # 80000538 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800050b4:	40dc                	lw	a5,4(s1)
    800050b6:	0047d79b          	srliw	a5,a5,0x4
    800050ba:	0001d597          	auipc	a1,0x1d
    800050be:	1c65a583          	lw	a1,454(a1) # 80022280 <sb+0x18>
    800050c2:	9dbd                	addw	a1,a1,a5
    800050c4:	4088                	lw	a0,0(s1)
    800050c6:	fffff097          	auipc	ra,0xfffff
    800050ca:	7ac080e7          	jalr	1964(ra) # 80004872 <bread>
    800050ce:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800050d0:	05850593          	addi	a1,a0,88
    800050d4:	40dc                	lw	a5,4(s1)
    800050d6:	8bbd                	andi	a5,a5,15
    800050d8:	079a                	slli	a5,a5,0x6
    800050da:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800050dc:	00059783          	lh	a5,0(a1)
    800050e0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800050e4:	00259783          	lh	a5,2(a1)
    800050e8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800050ec:	00459783          	lh	a5,4(a1)
    800050f0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800050f4:	00659783          	lh	a5,6(a1)
    800050f8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800050fc:	459c                	lw	a5,8(a1)
    800050fe:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80005100:	03400613          	li	a2,52
    80005104:	05b1                	addi	a1,a1,12
    80005106:	05048513          	addi	a0,s1,80
    8000510a:	ffffc097          	auipc	ra,0xffffc
    8000510e:	c1c080e7          	jalr	-996(ra) # 80000d26 <memmove>
    brelse(bp);
    80005112:	854a                	mv	a0,s2
    80005114:	00000097          	auipc	ra,0x0
    80005118:	88e080e7          	jalr	-1906(ra) # 800049a2 <brelse>
    ip->valid = 1;
    8000511c:	4785                	li	a5,1
    8000511e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80005120:	04449783          	lh	a5,68(s1)
    80005124:	fbb5                	bnez	a5,80005098 <ilock+0x24>
      panic("ilock: no type");
    80005126:	00005517          	auipc	a0,0x5
    8000512a:	82250513          	addi	a0,a0,-2014 # 80009948 <syscalls+0x2e8>
    8000512e:	ffffb097          	auipc	ra,0xffffb
    80005132:	40a080e7          	jalr	1034(ra) # 80000538 <panic>

0000000080005136 <iunlock>:
{
    80005136:	1101                	addi	sp,sp,-32
    80005138:	ec06                	sd	ra,24(sp)
    8000513a:	e822                	sd	s0,16(sp)
    8000513c:	e426                	sd	s1,8(sp)
    8000513e:	e04a                	sd	s2,0(sp)
    80005140:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80005142:	c905                	beqz	a0,80005172 <iunlock+0x3c>
    80005144:	84aa                	mv	s1,a0
    80005146:	01050913          	addi	s2,a0,16
    8000514a:	854a                	mv	a0,s2
    8000514c:	00001097          	auipc	ra,0x1
    80005150:	c92080e7          	jalr	-878(ra) # 80005dde <holdingsleep>
    80005154:	cd19                	beqz	a0,80005172 <iunlock+0x3c>
    80005156:	449c                	lw	a5,8(s1)
    80005158:	00f05d63          	blez	a5,80005172 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000515c:	854a                	mv	a0,s2
    8000515e:	00001097          	auipc	ra,0x1
    80005162:	c3c080e7          	jalr	-964(ra) # 80005d9a <releasesleep>
}
    80005166:	60e2                	ld	ra,24(sp)
    80005168:	6442                	ld	s0,16(sp)
    8000516a:	64a2                	ld	s1,8(sp)
    8000516c:	6902                	ld	s2,0(sp)
    8000516e:	6105                	addi	sp,sp,32
    80005170:	8082                	ret
    panic("iunlock");
    80005172:	00004517          	auipc	a0,0x4
    80005176:	7e650513          	addi	a0,a0,2022 # 80009958 <syscalls+0x2f8>
    8000517a:	ffffb097          	auipc	ra,0xffffb
    8000517e:	3be080e7          	jalr	958(ra) # 80000538 <panic>

0000000080005182 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80005182:	7179                	addi	sp,sp,-48
    80005184:	f406                	sd	ra,40(sp)
    80005186:	f022                	sd	s0,32(sp)
    80005188:	ec26                	sd	s1,24(sp)
    8000518a:	e84a                	sd	s2,16(sp)
    8000518c:	e44e                	sd	s3,8(sp)
    8000518e:	e052                	sd	s4,0(sp)
    80005190:	1800                	addi	s0,sp,48
    80005192:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80005194:	05050493          	addi	s1,a0,80
    80005198:	08050913          	addi	s2,a0,128
    8000519c:	a021                	j	800051a4 <itrunc+0x22>
    8000519e:	0491                	addi	s1,s1,4
    800051a0:	01248d63          	beq	s1,s2,800051ba <itrunc+0x38>
    if(ip->addrs[i]){
    800051a4:	408c                	lw	a1,0(s1)
    800051a6:	dde5                	beqz	a1,8000519e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800051a8:	0009a503          	lw	a0,0(s3)
    800051ac:	00000097          	auipc	ra,0x0
    800051b0:	90c080e7          	jalr	-1780(ra) # 80004ab8 <bfree>
      ip->addrs[i] = 0;
    800051b4:	0004a023          	sw	zero,0(s1)
    800051b8:	b7dd                	j	8000519e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800051ba:	0809a583          	lw	a1,128(s3)
    800051be:	e185                	bnez	a1,800051de <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800051c0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800051c4:	854e                	mv	a0,s3
    800051c6:	00000097          	auipc	ra,0x0
    800051ca:	de2080e7          	jalr	-542(ra) # 80004fa8 <iupdate>
}
    800051ce:	70a2                	ld	ra,40(sp)
    800051d0:	7402                	ld	s0,32(sp)
    800051d2:	64e2                	ld	s1,24(sp)
    800051d4:	6942                	ld	s2,16(sp)
    800051d6:	69a2                	ld	s3,8(sp)
    800051d8:	6a02                	ld	s4,0(sp)
    800051da:	6145                	addi	sp,sp,48
    800051dc:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800051de:	0009a503          	lw	a0,0(s3)
    800051e2:	fffff097          	auipc	ra,0xfffff
    800051e6:	690080e7          	jalr	1680(ra) # 80004872 <bread>
    800051ea:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800051ec:	05850493          	addi	s1,a0,88
    800051f0:	45850913          	addi	s2,a0,1112
    800051f4:	a021                	j	800051fc <itrunc+0x7a>
    800051f6:	0491                	addi	s1,s1,4
    800051f8:	01248b63          	beq	s1,s2,8000520e <itrunc+0x8c>
      if(a[j])
    800051fc:	408c                	lw	a1,0(s1)
    800051fe:	dde5                	beqz	a1,800051f6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80005200:	0009a503          	lw	a0,0(s3)
    80005204:	00000097          	auipc	ra,0x0
    80005208:	8b4080e7          	jalr	-1868(ra) # 80004ab8 <bfree>
    8000520c:	b7ed                	j	800051f6 <itrunc+0x74>
    brelse(bp);
    8000520e:	8552                	mv	a0,s4
    80005210:	fffff097          	auipc	ra,0xfffff
    80005214:	792080e7          	jalr	1938(ra) # 800049a2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80005218:	0809a583          	lw	a1,128(s3)
    8000521c:	0009a503          	lw	a0,0(s3)
    80005220:	00000097          	auipc	ra,0x0
    80005224:	898080e7          	jalr	-1896(ra) # 80004ab8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80005228:	0809a023          	sw	zero,128(s3)
    8000522c:	bf51                	j	800051c0 <itrunc+0x3e>

000000008000522e <iput>:
{
    8000522e:	1101                	addi	sp,sp,-32
    80005230:	ec06                	sd	ra,24(sp)
    80005232:	e822                	sd	s0,16(sp)
    80005234:	e426                	sd	s1,8(sp)
    80005236:	e04a                	sd	s2,0(sp)
    80005238:	1000                	addi	s0,sp,32
    8000523a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000523c:	0001d517          	auipc	a0,0x1d
    80005240:	04c50513          	addi	a0,a0,76 # 80022288 <itable>
    80005244:	ffffc097          	auipc	ra,0xffffc
    80005248:	98a080e7          	jalr	-1654(ra) # 80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000524c:	4498                	lw	a4,8(s1)
    8000524e:	4785                	li	a5,1
    80005250:	02f70363          	beq	a4,a5,80005276 <iput+0x48>
  ip->ref--;
    80005254:	449c                	lw	a5,8(s1)
    80005256:	37fd                	addiw	a5,a5,-1
    80005258:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000525a:	0001d517          	auipc	a0,0x1d
    8000525e:	02e50513          	addi	a0,a0,46 # 80022288 <itable>
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	a20080e7          	jalr	-1504(ra) # 80000c82 <release>
}
    8000526a:	60e2                	ld	ra,24(sp)
    8000526c:	6442                	ld	s0,16(sp)
    8000526e:	64a2                	ld	s1,8(sp)
    80005270:	6902                	ld	s2,0(sp)
    80005272:	6105                	addi	sp,sp,32
    80005274:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80005276:	40bc                	lw	a5,64(s1)
    80005278:	dff1                	beqz	a5,80005254 <iput+0x26>
    8000527a:	04a49783          	lh	a5,74(s1)
    8000527e:	fbf9                	bnez	a5,80005254 <iput+0x26>
    acquiresleep(&ip->lock);
    80005280:	01048913          	addi	s2,s1,16
    80005284:	854a                	mv	a0,s2
    80005286:	00001097          	auipc	ra,0x1
    8000528a:	abe080e7          	jalr	-1346(ra) # 80005d44 <acquiresleep>
    release(&itable.lock);
    8000528e:	0001d517          	auipc	a0,0x1d
    80005292:	ffa50513          	addi	a0,a0,-6 # 80022288 <itable>
    80005296:	ffffc097          	auipc	ra,0xffffc
    8000529a:	9ec080e7          	jalr	-1556(ra) # 80000c82 <release>
    itrunc(ip);
    8000529e:	8526                	mv	a0,s1
    800052a0:	00000097          	auipc	ra,0x0
    800052a4:	ee2080e7          	jalr	-286(ra) # 80005182 <itrunc>
    ip->type = 0;
    800052a8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800052ac:	8526                	mv	a0,s1
    800052ae:	00000097          	auipc	ra,0x0
    800052b2:	cfa080e7          	jalr	-774(ra) # 80004fa8 <iupdate>
    ip->valid = 0;
    800052b6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800052ba:	854a                	mv	a0,s2
    800052bc:	00001097          	auipc	ra,0x1
    800052c0:	ade080e7          	jalr	-1314(ra) # 80005d9a <releasesleep>
    acquire(&itable.lock);
    800052c4:	0001d517          	auipc	a0,0x1d
    800052c8:	fc450513          	addi	a0,a0,-60 # 80022288 <itable>
    800052cc:	ffffc097          	auipc	ra,0xffffc
    800052d0:	902080e7          	jalr	-1790(ra) # 80000bce <acquire>
    800052d4:	b741                	j	80005254 <iput+0x26>

00000000800052d6 <iunlockput>:
{
    800052d6:	1101                	addi	sp,sp,-32
    800052d8:	ec06                	sd	ra,24(sp)
    800052da:	e822                	sd	s0,16(sp)
    800052dc:	e426                	sd	s1,8(sp)
    800052de:	1000                	addi	s0,sp,32
    800052e0:	84aa                	mv	s1,a0
  iunlock(ip);
    800052e2:	00000097          	auipc	ra,0x0
    800052e6:	e54080e7          	jalr	-428(ra) # 80005136 <iunlock>
  iput(ip);
    800052ea:	8526                	mv	a0,s1
    800052ec:	00000097          	auipc	ra,0x0
    800052f0:	f42080e7          	jalr	-190(ra) # 8000522e <iput>
}
    800052f4:	60e2                	ld	ra,24(sp)
    800052f6:	6442                	ld	s0,16(sp)
    800052f8:	64a2                	ld	s1,8(sp)
    800052fa:	6105                	addi	sp,sp,32
    800052fc:	8082                	ret

00000000800052fe <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800052fe:	1141                	addi	sp,sp,-16
    80005300:	e422                	sd	s0,8(sp)
    80005302:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80005304:	411c                	lw	a5,0(a0)
    80005306:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80005308:	415c                	lw	a5,4(a0)
    8000530a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000530c:	04451783          	lh	a5,68(a0)
    80005310:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80005314:	04a51783          	lh	a5,74(a0)
    80005318:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000531c:	04c56783          	lwu	a5,76(a0)
    80005320:	e99c                	sd	a5,16(a1)
}
    80005322:	6422                	ld	s0,8(sp)
    80005324:	0141                	addi	sp,sp,16
    80005326:	8082                	ret

0000000080005328 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80005328:	457c                	lw	a5,76(a0)
    8000532a:	0ed7e963          	bltu	a5,a3,8000541c <readi+0xf4>
{
    8000532e:	7159                	addi	sp,sp,-112
    80005330:	f486                	sd	ra,104(sp)
    80005332:	f0a2                	sd	s0,96(sp)
    80005334:	eca6                	sd	s1,88(sp)
    80005336:	e8ca                	sd	s2,80(sp)
    80005338:	e4ce                	sd	s3,72(sp)
    8000533a:	e0d2                	sd	s4,64(sp)
    8000533c:	fc56                	sd	s5,56(sp)
    8000533e:	f85a                	sd	s6,48(sp)
    80005340:	f45e                	sd	s7,40(sp)
    80005342:	f062                	sd	s8,32(sp)
    80005344:	ec66                	sd	s9,24(sp)
    80005346:	e86a                	sd	s10,16(sp)
    80005348:	e46e                	sd	s11,8(sp)
    8000534a:	1880                	addi	s0,sp,112
    8000534c:	8baa                	mv	s7,a0
    8000534e:	8c2e                	mv	s8,a1
    80005350:	8ab2                	mv	s5,a2
    80005352:	84b6                	mv	s1,a3
    80005354:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80005356:	9f35                	addw	a4,a4,a3
    return 0;
    80005358:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000535a:	0ad76063          	bltu	a4,a3,800053fa <readi+0xd2>
  if(off + n > ip->size)
    8000535e:	00e7f463          	bgeu	a5,a4,80005366 <readi+0x3e>
    n = ip->size - off;
    80005362:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005366:	0a0b0963          	beqz	s6,80005418 <readi+0xf0>
    8000536a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000536c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80005370:	5cfd                	li	s9,-1
    80005372:	a82d                	j	800053ac <readi+0x84>
    80005374:	020a1d93          	slli	s11,s4,0x20
    80005378:	020ddd93          	srli	s11,s11,0x20
    8000537c:	05890613          	addi	a2,s2,88
    80005380:	86ee                	mv	a3,s11
    80005382:	963a                	add	a2,a2,a4
    80005384:	85d6                	mv	a1,s5
    80005386:	8562                	mv	a0,s8
    80005388:	ffffe097          	auipc	ra,0xffffe
    8000538c:	088080e7          	jalr	136(ra) # 80003410 <either_copyout>
    80005390:	05950d63          	beq	a0,s9,800053ea <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80005394:	854a                	mv	a0,s2
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	60c080e7          	jalr	1548(ra) # 800049a2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000539e:	013a09bb          	addw	s3,s4,s3
    800053a2:	009a04bb          	addw	s1,s4,s1
    800053a6:	9aee                	add	s5,s5,s11
    800053a8:	0569f763          	bgeu	s3,s6,800053f6 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800053ac:	000ba903          	lw	s2,0(s7)
    800053b0:	00a4d59b          	srliw	a1,s1,0xa
    800053b4:	855e                	mv	a0,s7
    800053b6:	00000097          	auipc	ra,0x0
    800053ba:	8ac080e7          	jalr	-1876(ra) # 80004c62 <bmap>
    800053be:	0005059b          	sext.w	a1,a0
    800053c2:	854a                	mv	a0,s2
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	4ae080e7          	jalr	1198(ra) # 80004872 <bread>
    800053cc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800053ce:	3ff4f713          	andi	a4,s1,1023
    800053d2:	40ed07bb          	subw	a5,s10,a4
    800053d6:	413b06bb          	subw	a3,s6,s3
    800053da:	8a3e                	mv	s4,a5
    800053dc:	2781                	sext.w	a5,a5
    800053de:	0006861b          	sext.w	a2,a3
    800053e2:	f8f679e3          	bgeu	a2,a5,80005374 <readi+0x4c>
    800053e6:	8a36                	mv	s4,a3
    800053e8:	b771                	j	80005374 <readi+0x4c>
      brelse(bp);
    800053ea:	854a                	mv	a0,s2
    800053ec:	fffff097          	auipc	ra,0xfffff
    800053f0:	5b6080e7          	jalr	1462(ra) # 800049a2 <brelse>
      tot = -1;
    800053f4:	59fd                	li	s3,-1
  }
  return tot;
    800053f6:	0009851b          	sext.w	a0,s3
}
    800053fa:	70a6                	ld	ra,104(sp)
    800053fc:	7406                	ld	s0,96(sp)
    800053fe:	64e6                	ld	s1,88(sp)
    80005400:	6946                	ld	s2,80(sp)
    80005402:	69a6                	ld	s3,72(sp)
    80005404:	6a06                	ld	s4,64(sp)
    80005406:	7ae2                	ld	s5,56(sp)
    80005408:	7b42                	ld	s6,48(sp)
    8000540a:	7ba2                	ld	s7,40(sp)
    8000540c:	7c02                	ld	s8,32(sp)
    8000540e:	6ce2                	ld	s9,24(sp)
    80005410:	6d42                	ld	s10,16(sp)
    80005412:	6da2                	ld	s11,8(sp)
    80005414:	6165                	addi	sp,sp,112
    80005416:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005418:	89da                	mv	s3,s6
    8000541a:	bff1                	j	800053f6 <readi+0xce>
    return 0;
    8000541c:	4501                	li	a0,0
}
    8000541e:	8082                	ret

0000000080005420 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80005420:	457c                	lw	a5,76(a0)
    80005422:	10d7e863          	bltu	a5,a3,80005532 <writei+0x112>
{
    80005426:	7159                	addi	sp,sp,-112
    80005428:	f486                	sd	ra,104(sp)
    8000542a:	f0a2                	sd	s0,96(sp)
    8000542c:	eca6                	sd	s1,88(sp)
    8000542e:	e8ca                	sd	s2,80(sp)
    80005430:	e4ce                	sd	s3,72(sp)
    80005432:	e0d2                	sd	s4,64(sp)
    80005434:	fc56                	sd	s5,56(sp)
    80005436:	f85a                	sd	s6,48(sp)
    80005438:	f45e                	sd	s7,40(sp)
    8000543a:	f062                	sd	s8,32(sp)
    8000543c:	ec66                	sd	s9,24(sp)
    8000543e:	e86a                	sd	s10,16(sp)
    80005440:	e46e                	sd	s11,8(sp)
    80005442:	1880                	addi	s0,sp,112
    80005444:	8b2a                	mv	s6,a0
    80005446:	8c2e                	mv	s8,a1
    80005448:	8ab2                	mv	s5,a2
    8000544a:	8936                	mv	s2,a3
    8000544c:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000544e:	00e687bb          	addw	a5,a3,a4
    80005452:	0ed7e263          	bltu	a5,a3,80005536 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80005456:	00043737          	lui	a4,0x43
    8000545a:	0ef76063          	bltu	a4,a5,8000553a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000545e:	0c0b8863          	beqz	s7,8000552e <writei+0x10e>
    80005462:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80005464:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80005468:	5cfd                	li	s9,-1
    8000546a:	a091                	j	800054ae <writei+0x8e>
    8000546c:	02099d93          	slli	s11,s3,0x20
    80005470:	020ddd93          	srli	s11,s11,0x20
    80005474:	05848513          	addi	a0,s1,88
    80005478:	86ee                	mv	a3,s11
    8000547a:	8656                	mv	a2,s5
    8000547c:	85e2                	mv	a1,s8
    8000547e:	953a                	add	a0,a0,a4
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	fe6080e7          	jalr	-26(ra) # 80003466 <either_copyin>
    80005488:	07950263          	beq	a0,s9,800054ec <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000548c:	8526                	mv	a0,s1
    8000548e:	00000097          	auipc	ra,0x0
    80005492:	798080e7          	jalr	1944(ra) # 80005c26 <log_write>
    brelse(bp);
    80005496:	8526                	mv	a0,s1
    80005498:	fffff097          	auipc	ra,0xfffff
    8000549c:	50a080e7          	jalr	1290(ra) # 800049a2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800054a0:	01498a3b          	addw	s4,s3,s4
    800054a4:	0129893b          	addw	s2,s3,s2
    800054a8:	9aee                	add	s5,s5,s11
    800054aa:	057a7663          	bgeu	s4,s7,800054f6 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800054ae:	000b2483          	lw	s1,0(s6)
    800054b2:	00a9559b          	srliw	a1,s2,0xa
    800054b6:	855a                	mv	a0,s6
    800054b8:	fffff097          	auipc	ra,0xfffff
    800054bc:	7aa080e7          	jalr	1962(ra) # 80004c62 <bmap>
    800054c0:	0005059b          	sext.w	a1,a0
    800054c4:	8526                	mv	a0,s1
    800054c6:	fffff097          	auipc	ra,0xfffff
    800054ca:	3ac080e7          	jalr	940(ra) # 80004872 <bread>
    800054ce:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800054d0:	3ff97713          	andi	a4,s2,1023
    800054d4:	40ed07bb          	subw	a5,s10,a4
    800054d8:	414b86bb          	subw	a3,s7,s4
    800054dc:	89be                	mv	s3,a5
    800054de:	2781                	sext.w	a5,a5
    800054e0:	0006861b          	sext.w	a2,a3
    800054e4:	f8f674e3          	bgeu	a2,a5,8000546c <writei+0x4c>
    800054e8:	89b6                	mv	s3,a3
    800054ea:	b749                	j	8000546c <writei+0x4c>
      brelse(bp);
    800054ec:	8526                	mv	a0,s1
    800054ee:	fffff097          	auipc	ra,0xfffff
    800054f2:	4b4080e7          	jalr	1204(ra) # 800049a2 <brelse>
  }

  if(off > ip->size)
    800054f6:	04cb2783          	lw	a5,76(s6)
    800054fa:	0127f463          	bgeu	a5,s2,80005502 <writei+0xe2>
    ip->size = off;
    800054fe:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80005502:	855a                	mv	a0,s6
    80005504:	00000097          	auipc	ra,0x0
    80005508:	aa4080e7          	jalr	-1372(ra) # 80004fa8 <iupdate>

  return tot;
    8000550c:	000a051b          	sext.w	a0,s4
}
    80005510:	70a6                	ld	ra,104(sp)
    80005512:	7406                	ld	s0,96(sp)
    80005514:	64e6                	ld	s1,88(sp)
    80005516:	6946                	ld	s2,80(sp)
    80005518:	69a6                	ld	s3,72(sp)
    8000551a:	6a06                	ld	s4,64(sp)
    8000551c:	7ae2                	ld	s5,56(sp)
    8000551e:	7b42                	ld	s6,48(sp)
    80005520:	7ba2                	ld	s7,40(sp)
    80005522:	7c02                	ld	s8,32(sp)
    80005524:	6ce2                	ld	s9,24(sp)
    80005526:	6d42                	ld	s10,16(sp)
    80005528:	6da2                	ld	s11,8(sp)
    8000552a:	6165                	addi	sp,sp,112
    8000552c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000552e:	8a5e                	mv	s4,s7
    80005530:	bfc9                	j	80005502 <writei+0xe2>
    return -1;
    80005532:	557d                	li	a0,-1
}
    80005534:	8082                	ret
    return -1;
    80005536:	557d                	li	a0,-1
    80005538:	bfe1                	j	80005510 <writei+0xf0>
    return -1;
    8000553a:	557d                	li	a0,-1
    8000553c:	bfd1                	j	80005510 <writei+0xf0>

000000008000553e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000553e:	1141                	addi	sp,sp,-16
    80005540:	e406                	sd	ra,8(sp)
    80005542:	e022                	sd	s0,0(sp)
    80005544:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80005546:	4639                	li	a2,14
    80005548:	ffffc097          	auipc	ra,0xffffc
    8000554c:	852080e7          	jalr	-1966(ra) # 80000d9a <strncmp>
}
    80005550:	60a2                	ld	ra,8(sp)
    80005552:	6402                	ld	s0,0(sp)
    80005554:	0141                	addi	sp,sp,16
    80005556:	8082                	ret

0000000080005558 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80005558:	7139                	addi	sp,sp,-64
    8000555a:	fc06                	sd	ra,56(sp)
    8000555c:	f822                	sd	s0,48(sp)
    8000555e:	f426                	sd	s1,40(sp)
    80005560:	f04a                	sd	s2,32(sp)
    80005562:	ec4e                	sd	s3,24(sp)
    80005564:	e852                	sd	s4,16(sp)
    80005566:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80005568:	04451703          	lh	a4,68(a0)
    8000556c:	4785                	li	a5,1
    8000556e:	00f71a63          	bne	a4,a5,80005582 <dirlookup+0x2a>
    80005572:	892a                	mv	s2,a0
    80005574:	89ae                	mv	s3,a1
    80005576:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80005578:	457c                	lw	a5,76(a0)
    8000557a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000557c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000557e:	e79d                	bnez	a5,800055ac <dirlookup+0x54>
    80005580:	a8a5                	j	800055f8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80005582:	00004517          	auipc	a0,0x4
    80005586:	3de50513          	addi	a0,a0,990 # 80009960 <syscalls+0x300>
    8000558a:	ffffb097          	auipc	ra,0xffffb
    8000558e:	fae080e7          	jalr	-82(ra) # 80000538 <panic>
      panic("dirlookup read");
    80005592:	00004517          	auipc	a0,0x4
    80005596:	3e650513          	addi	a0,a0,998 # 80009978 <syscalls+0x318>
    8000559a:	ffffb097          	auipc	ra,0xffffb
    8000559e:	f9e080e7          	jalr	-98(ra) # 80000538 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800055a2:	24c1                	addiw	s1,s1,16
    800055a4:	04c92783          	lw	a5,76(s2)
    800055a8:	04f4f763          	bgeu	s1,a5,800055f6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055ac:	4741                	li	a4,16
    800055ae:	86a6                	mv	a3,s1
    800055b0:	fc040613          	addi	a2,s0,-64
    800055b4:	4581                	li	a1,0
    800055b6:	854a                	mv	a0,s2
    800055b8:	00000097          	auipc	ra,0x0
    800055bc:	d70080e7          	jalr	-656(ra) # 80005328 <readi>
    800055c0:	47c1                	li	a5,16
    800055c2:	fcf518e3          	bne	a0,a5,80005592 <dirlookup+0x3a>
    if(de.inum == 0)
    800055c6:	fc045783          	lhu	a5,-64(s0)
    800055ca:	dfe1                	beqz	a5,800055a2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800055cc:	fc240593          	addi	a1,s0,-62
    800055d0:	854e                	mv	a0,s3
    800055d2:	00000097          	auipc	ra,0x0
    800055d6:	f6c080e7          	jalr	-148(ra) # 8000553e <namecmp>
    800055da:	f561                	bnez	a0,800055a2 <dirlookup+0x4a>
      if(poff)
    800055dc:	000a0463          	beqz	s4,800055e4 <dirlookup+0x8c>
        *poff = off;
    800055e0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800055e4:	fc045583          	lhu	a1,-64(s0)
    800055e8:	00092503          	lw	a0,0(s2)
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	752080e7          	jalr	1874(ra) # 80004d3e <iget>
    800055f4:	a011                	j	800055f8 <dirlookup+0xa0>
  return 0;
    800055f6:	4501                	li	a0,0
}
    800055f8:	70e2                	ld	ra,56(sp)
    800055fa:	7442                	ld	s0,48(sp)
    800055fc:	74a2                	ld	s1,40(sp)
    800055fe:	7902                	ld	s2,32(sp)
    80005600:	69e2                	ld	s3,24(sp)
    80005602:	6a42                	ld	s4,16(sp)
    80005604:	6121                	addi	sp,sp,64
    80005606:	8082                	ret

0000000080005608 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80005608:	711d                	addi	sp,sp,-96
    8000560a:	ec86                	sd	ra,88(sp)
    8000560c:	e8a2                	sd	s0,80(sp)
    8000560e:	e4a6                	sd	s1,72(sp)
    80005610:	e0ca                	sd	s2,64(sp)
    80005612:	fc4e                	sd	s3,56(sp)
    80005614:	f852                	sd	s4,48(sp)
    80005616:	f456                	sd	s5,40(sp)
    80005618:	f05a                	sd	s6,32(sp)
    8000561a:	ec5e                	sd	s7,24(sp)
    8000561c:	e862                	sd	s8,16(sp)
    8000561e:	e466                	sd	s9,8(sp)
    80005620:	e06a                	sd	s10,0(sp)
    80005622:	1080                	addi	s0,sp,96
    80005624:	84aa                	mv	s1,a0
    80005626:	8b2e                	mv	s6,a1
    80005628:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000562a:	00054703          	lbu	a4,0(a0)
    8000562e:	02f00793          	li	a5,47
    80005632:	02f70363          	beq	a4,a5,80005658 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80005636:	ffffc097          	auipc	ra,0xffffc
    8000563a:	3ba080e7          	jalr	954(ra) # 800019f0 <myproc>
    8000563e:	15853503          	ld	a0,344(a0)
    80005642:	00000097          	auipc	ra,0x0
    80005646:	9f4080e7          	jalr	-1548(ra) # 80005036 <idup>
    8000564a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000564c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80005650:	4cb5                	li	s9,13
  len = path - s;
    80005652:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80005654:	4c05                	li	s8,1
    80005656:	a87d                	j	80005714 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80005658:	4585                	li	a1,1
    8000565a:	4505                	li	a0,1
    8000565c:	fffff097          	auipc	ra,0xfffff
    80005660:	6e2080e7          	jalr	1762(ra) # 80004d3e <iget>
    80005664:	8a2a                	mv	s4,a0
    80005666:	b7dd                	j	8000564c <namex+0x44>
      iunlockput(ip);
    80005668:	8552                	mv	a0,s4
    8000566a:	00000097          	auipc	ra,0x0
    8000566e:	c6c080e7          	jalr	-916(ra) # 800052d6 <iunlockput>
      return 0;
    80005672:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80005674:	8552                	mv	a0,s4
    80005676:	60e6                	ld	ra,88(sp)
    80005678:	6446                	ld	s0,80(sp)
    8000567a:	64a6                	ld	s1,72(sp)
    8000567c:	6906                	ld	s2,64(sp)
    8000567e:	79e2                	ld	s3,56(sp)
    80005680:	7a42                	ld	s4,48(sp)
    80005682:	7aa2                	ld	s5,40(sp)
    80005684:	7b02                	ld	s6,32(sp)
    80005686:	6be2                	ld	s7,24(sp)
    80005688:	6c42                	ld	s8,16(sp)
    8000568a:	6ca2                	ld	s9,8(sp)
    8000568c:	6d02                	ld	s10,0(sp)
    8000568e:	6125                	addi	sp,sp,96
    80005690:	8082                	ret
      iunlock(ip);
    80005692:	8552                	mv	a0,s4
    80005694:	00000097          	auipc	ra,0x0
    80005698:	aa2080e7          	jalr	-1374(ra) # 80005136 <iunlock>
      return ip;
    8000569c:	bfe1                	j	80005674 <namex+0x6c>
      iunlockput(ip);
    8000569e:	8552                	mv	a0,s4
    800056a0:	00000097          	auipc	ra,0x0
    800056a4:	c36080e7          	jalr	-970(ra) # 800052d6 <iunlockput>
      return 0;
    800056a8:	8a4e                	mv	s4,s3
    800056aa:	b7e9                	j	80005674 <namex+0x6c>
  len = path - s;
    800056ac:	40998633          	sub	a2,s3,s1
    800056b0:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800056b4:	09acd863          	bge	s9,s10,80005744 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800056b8:	4639                	li	a2,14
    800056ba:	85a6                	mv	a1,s1
    800056bc:	8556                	mv	a0,s5
    800056be:	ffffb097          	auipc	ra,0xffffb
    800056c2:	668080e7          	jalr	1640(ra) # 80000d26 <memmove>
    800056c6:	84ce                	mv	s1,s3
  while(*path == '/')
    800056c8:	0004c783          	lbu	a5,0(s1)
    800056cc:	01279763          	bne	a5,s2,800056da <namex+0xd2>
    path++;
    800056d0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800056d2:	0004c783          	lbu	a5,0(s1)
    800056d6:	ff278de3          	beq	a5,s2,800056d0 <namex+0xc8>
    ilock(ip);
    800056da:	8552                	mv	a0,s4
    800056dc:	00000097          	auipc	ra,0x0
    800056e0:	998080e7          	jalr	-1640(ra) # 80005074 <ilock>
    if(ip->type != T_DIR){
    800056e4:	044a1783          	lh	a5,68(s4)
    800056e8:	f98790e3          	bne	a5,s8,80005668 <namex+0x60>
    if(nameiparent && *path == '\0'){
    800056ec:	000b0563          	beqz	s6,800056f6 <namex+0xee>
    800056f0:	0004c783          	lbu	a5,0(s1)
    800056f4:	dfd9                	beqz	a5,80005692 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800056f6:	865e                	mv	a2,s7
    800056f8:	85d6                	mv	a1,s5
    800056fa:	8552                	mv	a0,s4
    800056fc:	00000097          	auipc	ra,0x0
    80005700:	e5c080e7          	jalr	-420(ra) # 80005558 <dirlookup>
    80005704:	89aa                	mv	s3,a0
    80005706:	dd41                	beqz	a0,8000569e <namex+0x96>
    iunlockput(ip);
    80005708:	8552                	mv	a0,s4
    8000570a:	00000097          	auipc	ra,0x0
    8000570e:	bcc080e7          	jalr	-1076(ra) # 800052d6 <iunlockput>
    ip = next;
    80005712:	8a4e                	mv	s4,s3
  while(*path == '/')
    80005714:	0004c783          	lbu	a5,0(s1)
    80005718:	01279763          	bne	a5,s2,80005726 <namex+0x11e>
    path++;
    8000571c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000571e:	0004c783          	lbu	a5,0(s1)
    80005722:	ff278de3          	beq	a5,s2,8000571c <namex+0x114>
  if(*path == 0)
    80005726:	cb9d                	beqz	a5,8000575c <namex+0x154>
  while(*path != '/' && *path != 0)
    80005728:	0004c783          	lbu	a5,0(s1)
    8000572c:	89a6                	mv	s3,s1
  len = path - s;
    8000572e:	8d5e                	mv	s10,s7
    80005730:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80005732:	01278963          	beq	a5,s2,80005744 <namex+0x13c>
    80005736:	dbbd                	beqz	a5,800056ac <namex+0xa4>
    path++;
    80005738:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000573a:	0009c783          	lbu	a5,0(s3)
    8000573e:	ff279ce3          	bne	a5,s2,80005736 <namex+0x12e>
    80005742:	b7ad                	j	800056ac <namex+0xa4>
    memmove(name, s, len);
    80005744:	2601                	sext.w	a2,a2
    80005746:	85a6                	mv	a1,s1
    80005748:	8556                	mv	a0,s5
    8000574a:	ffffb097          	auipc	ra,0xffffb
    8000574e:	5dc080e7          	jalr	1500(ra) # 80000d26 <memmove>
    name[len] = 0;
    80005752:	9d56                	add	s10,s10,s5
    80005754:	000d0023          	sb	zero,0(s10)
    80005758:	84ce                	mv	s1,s3
    8000575a:	b7bd                	j	800056c8 <namex+0xc0>
  if(nameiparent){
    8000575c:	f00b0ce3          	beqz	s6,80005674 <namex+0x6c>
    iput(ip);
    80005760:	8552                	mv	a0,s4
    80005762:	00000097          	auipc	ra,0x0
    80005766:	acc080e7          	jalr	-1332(ra) # 8000522e <iput>
    return 0;
    8000576a:	4a01                	li	s4,0
    8000576c:	b721                	j	80005674 <namex+0x6c>

000000008000576e <dirlink>:
{
    8000576e:	7139                	addi	sp,sp,-64
    80005770:	fc06                	sd	ra,56(sp)
    80005772:	f822                	sd	s0,48(sp)
    80005774:	f426                	sd	s1,40(sp)
    80005776:	f04a                	sd	s2,32(sp)
    80005778:	ec4e                	sd	s3,24(sp)
    8000577a:	e852                	sd	s4,16(sp)
    8000577c:	0080                	addi	s0,sp,64
    8000577e:	892a                	mv	s2,a0
    80005780:	8a2e                	mv	s4,a1
    80005782:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80005784:	4601                	li	a2,0
    80005786:	00000097          	auipc	ra,0x0
    8000578a:	dd2080e7          	jalr	-558(ra) # 80005558 <dirlookup>
    8000578e:	e93d                	bnez	a0,80005804 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005790:	04c92483          	lw	s1,76(s2)
    80005794:	c49d                	beqz	s1,800057c2 <dirlink+0x54>
    80005796:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005798:	4741                	li	a4,16
    8000579a:	86a6                	mv	a3,s1
    8000579c:	fc040613          	addi	a2,s0,-64
    800057a0:	4581                	li	a1,0
    800057a2:	854a                	mv	a0,s2
    800057a4:	00000097          	auipc	ra,0x0
    800057a8:	b84080e7          	jalr	-1148(ra) # 80005328 <readi>
    800057ac:	47c1                	li	a5,16
    800057ae:	06f51163          	bne	a0,a5,80005810 <dirlink+0xa2>
    if(de.inum == 0)
    800057b2:	fc045783          	lhu	a5,-64(s0)
    800057b6:	c791                	beqz	a5,800057c2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800057b8:	24c1                	addiw	s1,s1,16
    800057ba:	04c92783          	lw	a5,76(s2)
    800057be:	fcf4ede3          	bltu	s1,a5,80005798 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800057c2:	4639                	li	a2,14
    800057c4:	85d2                	mv	a1,s4
    800057c6:	fc240513          	addi	a0,s0,-62
    800057ca:	ffffb097          	auipc	ra,0xffffb
    800057ce:	60c080e7          	jalr	1548(ra) # 80000dd6 <strncpy>
  de.inum = inum;
    800057d2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057d6:	4741                	li	a4,16
    800057d8:	86a6                	mv	a3,s1
    800057da:	fc040613          	addi	a2,s0,-64
    800057de:	4581                	li	a1,0
    800057e0:	854a                	mv	a0,s2
    800057e2:	00000097          	auipc	ra,0x0
    800057e6:	c3e080e7          	jalr	-962(ra) # 80005420 <writei>
    800057ea:	872a                	mv	a4,a0
    800057ec:	47c1                	li	a5,16
  return 0;
    800057ee:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057f0:	02f71863          	bne	a4,a5,80005820 <dirlink+0xb2>
}
    800057f4:	70e2                	ld	ra,56(sp)
    800057f6:	7442                	ld	s0,48(sp)
    800057f8:	74a2                	ld	s1,40(sp)
    800057fa:	7902                	ld	s2,32(sp)
    800057fc:	69e2                	ld	s3,24(sp)
    800057fe:	6a42                	ld	s4,16(sp)
    80005800:	6121                	addi	sp,sp,64
    80005802:	8082                	ret
    iput(ip);
    80005804:	00000097          	auipc	ra,0x0
    80005808:	a2a080e7          	jalr	-1494(ra) # 8000522e <iput>
    return -1;
    8000580c:	557d                	li	a0,-1
    8000580e:	b7dd                	j	800057f4 <dirlink+0x86>
      panic("dirlink read");
    80005810:	00004517          	auipc	a0,0x4
    80005814:	17850513          	addi	a0,a0,376 # 80009988 <syscalls+0x328>
    80005818:	ffffb097          	auipc	ra,0xffffb
    8000581c:	d20080e7          	jalr	-736(ra) # 80000538 <panic>
    panic("dirlink");
    80005820:	00004517          	auipc	a0,0x4
    80005824:	27850513          	addi	a0,a0,632 # 80009a98 <syscalls+0x438>
    80005828:	ffffb097          	auipc	ra,0xffffb
    8000582c:	d10080e7          	jalr	-752(ra) # 80000538 <panic>

0000000080005830 <namei>:

struct inode*
namei(char *path)
{
    80005830:	1101                	addi	sp,sp,-32
    80005832:	ec06                	sd	ra,24(sp)
    80005834:	e822                	sd	s0,16(sp)
    80005836:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80005838:	fe040613          	addi	a2,s0,-32
    8000583c:	4581                	li	a1,0
    8000583e:	00000097          	auipc	ra,0x0
    80005842:	dca080e7          	jalr	-566(ra) # 80005608 <namex>
}
    80005846:	60e2                	ld	ra,24(sp)
    80005848:	6442                	ld	s0,16(sp)
    8000584a:	6105                	addi	sp,sp,32
    8000584c:	8082                	ret

000000008000584e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000584e:	1141                	addi	sp,sp,-16
    80005850:	e406                	sd	ra,8(sp)
    80005852:	e022                	sd	s0,0(sp)
    80005854:	0800                	addi	s0,sp,16
    80005856:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80005858:	4585                	li	a1,1
    8000585a:	00000097          	auipc	ra,0x0
    8000585e:	dae080e7          	jalr	-594(ra) # 80005608 <namex>
}
    80005862:	60a2                	ld	ra,8(sp)
    80005864:	6402                	ld	s0,0(sp)
    80005866:	0141                	addi	sp,sp,16
    80005868:	8082                	ret

000000008000586a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000586a:	1101                	addi	sp,sp,-32
    8000586c:	ec06                	sd	ra,24(sp)
    8000586e:	e822                	sd	s0,16(sp)
    80005870:	e426                	sd	s1,8(sp)
    80005872:	e04a                	sd	s2,0(sp)
    80005874:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80005876:	0001e917          	auipc	s2,0x1e
    8000587a:	4ba90913          	addi	s2,s2,1210 # 80023d30 <log>
    8000587e:	01892583          	lw	a1,24(s2)
    80005882:	02892503          	lw	a0,40(s2)
    80005886:	fffff097          	auipc	ra,0xfffff
    8000588a:	fec080e7          	jalr	-20(ra) # 80004872 <bread>
    8000588e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005890:	02c92683          	lw	a3,44(s2)
    80005894:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80005896:	02d05863          	blez	a3,800058c6 <write_head+0x5c>
    8000589a:	0001e797          	auipc	a5,0x1e
    8000589e:	4c678793          	addi	a5,a5,1222 # 80023d60 <log+0x30>
    800058a2:	05c50713          	addi	a4,a0,92
    800058a6:	36fd                	addiw	a3,a3,-1
    800058a8:	02069613          	slli	a2,a3,0x20
    800058ac:	01e65693          	srli	a3,a2,0x1e
    800058b0:	0001e617          	auipc	a2,0x1e
    800058b4:	4b460613          	addi	a2,a2,1204 # 80023d64 <log+0x34>
    800058b8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800058ba:	4390                	lw	a2,0(a5)
    800058bc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800058be:	0791                	addi	a5,a5,4
    800058c0:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800058c2:	fed79ce3          	bne	a5,a3,800058ba <write_head+0x50>
  }
  bwrite(buf);
    800058c6:	8526                	mv	a0,s1
    800058c8:	fffff097          	auipc	ra,0xfffff
    800058cc:	09c080e7          	jalr	156(ra) # 80004964 <bwrite>
  brelse(buf);
    800058d0:	8526                	mv	a0,s1
    800058d2:	fffff097          	auipc	ra,0xfffff
    800058d6:	0d0080e7          	jalr	208(ra) # 800049a2 <brelse>
}
    800058da:	60e2                	ld	ra,24(sp)
    800058dc:	6442                	ld	s0,16(sp)
    800058de:	64a2                	ld	s1,8(sp)
    800058e0:	6902                	ld	s2,0(sp)
    800058e2:	6105                	addi	sp,sp,32
    800058e4:	8082                	ret

00000000800058e6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800058e6:	0001e797          	auipc	a5,0x1e
    800058ea:	4767a783          	lw	a5,1142(a5) # 80023d5c <log+0x2c>
    800058ee:	0af05d63          	blez	a5,800059a8 <install_trans+0xc2>
{
    800058f2:	7139                	addi	sp,sp,-64
    800058f4:	fc06                	sd	ra,56(sp)
    800058f6:	f822                	sd	s0,48(sp)
    800058f8:	f426                	sd	s1,40(sp)
    800058fa:	f04a                	sd	s2,32(sp)
    800058fc:	ec4e                	sd	s3,24(sp)
    800058fe:	e852                	sd	s4,16(sp)
    80005900:	e456                	sd	s5,8(sp)
    80005902:	e05a                	sd	s6,0(sp)
    80005904:	0080                	addi	s0,sp,64
    80005906:	8b2a                	mv	s6,a0
    80005908:	0001ea97          	auipc	s5,0x1e
    8000590c:	458a8a93          	addi	s5,s5,1112 # 80023d60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005910:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005912:	0001e997          	auipc	s3,0x1e
    80005916:	41e98993          	addi	s3,s3,1054 # 80023d30 <log>
    8000591a:	a00d                	j	8000593c <install_trans+0x56>
    brelse(lbuf);
    8000591c:	854a                	mv	a0,s2
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	084080e7          	jalr	132(ra) # 800049a2 <brelse>
    brelse(dbuf);
    80005926:	8526                	mv	a0,s1
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	07a080e7          	jalr	122(ra) # 800049a2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005930:	2a05                	addiw	s4,s4,1
    80005932:	0a91                	addi	s5,s5,4
    80005934:	02c9a783          	lw	a5,44(s3)
    80005938:	04fa5e63          	bge	s4,a5,80005994 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000593c:	0189a583          	lw	a1,24(s3)
    80005940:	014585bb          	addw	a1,a1,s4
    80005944:	2585                	addiw	a1,a1,1
    80005946:	0289a503          	lw	a0,40(s3)
    8000594a:	fffff097          	auipc	ra,0xfffff
    8000594e:	f28080e7          	jalr	-216(ra) # 80004872 <bread>
    80005952:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80005954:	000aa583          	lw	a1,0(s5)
    80005958:	0289a503          	lw	a0,40(s3)
    8000595c:	fffff097          	auipc	ra,0xfffff
    80005960:	f16080e7          	jalr	-234(ra) # 80004872 <bread>
    80005964:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005966:	40000613          	li	a2,1024
    8000596a:	05890593          	addi	a1,s2,88
    8000596e:	05850513          	addi	a0,a0,88
    80005972:	ffffb097          	auipc	ra,0xffffb
    80005976:	3b4080e7          	jalr	948(ra) # 80000d26 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000597a:	8526                	mv	a0,s1
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	fe8080e7          	jalr	-24(ra) # 80004964 <bwrite>
    if(recovering == 0)
    80005984:	f80b1ce3          	bnez	s6,8000591c <install_trans+0x36>
      bunpin(dbuf);
    80005988:	8526                	mv	a0,s1
    8000598a:	fffff097          	auipc	ra,0xfffff
    8000598e:	0f2080e7          	jalr	242(ra) # 80004a7c <bunpin>
    80005992:	b769                	j	8000591c <install_trans+0x36>
}
    80005994:	70e2                	ld	ra,56(sp)
    80005996:	7442                	ld	s0,48(sp)
    80005998:	74a2                	ld	s1,40(sp)
    8000599a:	7902                	ld	s2,32(sp)
    8000599c:	69e2                	ld	s3,24(sp)
    8000599e:	6a42                	ld	s4,16(sp)
    800059a0:	6aa2                	ld	s5,8(sp)
    800059a2:	6b02                	ld	s6,0(sp)
    800059a4:	6121                	addi	sp,sp,64
    800059a6:	8082                	ret
    800059a8:	8082                	ret

00000000800059aa <initlog>:
{
    800059aa:	7179                	addi	sp,sp,-48
    800059ac:	f406                	sd	ra,40(sp)
    800059ae:	f022                	sd	s0,32(sp)
    800059b0:	ec26                	sd	s1,24(sp)
    800059b2:	e84a                	sd	s2,16(sp)
    800059b4:	e44e                	sd	s3,8(sp)
    800059b6:	1800                	addi	s0,sp,48
    800059b8:	892a                	mv	s2,a0
    800059ba:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800059bc:	0001e497          	auipc	s1,0x1e
    800059c0:	37448493          	addi	s1,s1,884 # 80023d30 <log>
    800059c4:	00004597          	auipc	a1,0x4
    800059c8:	fd458593          	addi	a1,a1,-44 # 80009998 <syscalls+0x338>
    800059cc:	8526                	mv	a0,s1
    800059ce:	ffffb097          	auipc	ra,0xffffb
    800059d2:	170080e7          	jalr	368(ra) # 80000b3e <initlock>
  log.start = sb->logstart;
    800059d6:	0149a583          	lw	a1,20(s3)
    800059da:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800059dc:	0109a783          	lw	a5,16(s3)
    800059e0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800059e2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800059e6:	854a                	mv	a0,s2
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	e8a080e7          	jalr	-374(ra) # 80004872 <bread>
  log.lh.n = lh->n;
    800059f0:	4d34                	lw	a3,88(a0)
    800059f2:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800059f4:	02d05663          	blez	a3,80005a20 <initlog+0x76>
    800059f8:	05c50793          	addi	a5,a0,92
    800059fc:	0001e717          	auipc	a4,0x1e
    80005a00:	36470713          	addi	a4,a4,868 # 80023d60 <log+0x30>
    80005a04:	36fd                	addiw	a3,a3,-1
    80005a06:	02069613          	slli	a2,a3,0x20
    80005a0a:	01e65693          	srli	a3,a2,0x1e
    80005a0e:	06050613          	addi	a2,a0,96
    80005a12:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80005a14:	4390                	lw	a2,0(a5)
    80005a16:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005a18:	0791                	addi	a5,a5,4
    80005a1a:	0711                	addi	a4,a4,4
    80005a1c:	fed79ce3          	bne	a5,a3,80005a14 <initlog+0x6a>
  brelse(buf);
    80005a20:	fffff097          	auipc	ra,0xfffff
    80005a24:	f82080e7          	jalr	-126(ra) # 800049a2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005a28:	4505                	li	a0,1
    80005a2a:	00000097          	auipc	ra,0x0
    80005a2e:	ebc080e7          	jalr	-324(ra) # 800058e6 <install_trans>
  log.lh.n = 0;
    80005a32:	0001e797          	auipc	a5,0x1e
    80005a36:	3207a523          	sw	zero,810(a5) # 80023d5c <log+0x2c>
  write_head(); // clear the log
    80005a3a:	00000097          	auipc	ra,0x0
    80005a3e:	e30080e7          	jalr	-464(ra) # 8000586a <write_head>
}
    80005a42:	70a2                	ld	ra,40(sp)
    80005a44:	7402                	ld	s0,32(sp)
    80005a46:	64e2                	ld	s1,24(sp)
    80005a48:	6942                	ld	s2,16(sp)
    80005a4a:	69a2                	ld	s3,8(sp)
    80005a4c:	6145                	addi	sp,sp,48
    80005a4e:	8082                	ret

0000000080005a50 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005a50:	1101                	addi	sp,sp,-32
    80005a52:	ec06                	sd	ra,24(sp)
    80005a54:	e822                	sd	s0,16(sp)
    80005a56:	e426                	sd	s1,8(sp)
    80005a58:	e04a                	sd	s2,0(sp)
    80005a5a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005a5c:	0001e517          	auipc	a0,0x1e
    80005a60:	2d450513          	addi	a0,a0,724 # 80023d30 <log>
    80005a64:	ffffb097          	auipc	ra,0xffffb
    80005a68:	16a080e7          	jalr	362(ra) # 80000bce <acquire>
  while(1){
    if(log.committing){
    80005a6c:	0001e497          	auipc	s1,0x1e
    80005a70:	2c448493          	addi	s1,s1,708 # 80023d30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005a74:	4979                	li	s2,30
    80005a76:	a039                	j	80005a84 <begin_op+0x34>
      sleep(&log, &log.lock);
    80005a78:	85a6                	mv	a1,s1
    80005a7a:	8526                	mv	a0,s1
    80005a7c:	ffffd097          	auipc	ra,0xffffd
    80005a80:	d26080e7          	jalr	-730(ra) # 800027a2 <sleep>
    if(log.committing){
    80005a84:	50dc                	lw	a5,36(s1)
    80005a86:	fbed                	bnez	a5,80005a78 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005a88:	5098                	lw	a4,32(s1)
    80005a8a:	2705                	addiw	a4,a4,1
    80005a8c:	0007069b          	sext.w	a3,a4
    80005a90:	0027179b          	slliw	a5,a4,0x2
    80005a94:	9fb9                	addw	a5,a5,a4
    80005a96:	0017979b          	slliw	a5,a5,0x1
    80005a9a:	54d8                	lw	a4,44(s1)
    80005a9c:	9fb9                	addw	a5,a5,a4
    80005a9e:	00f95963          	bge	s2,a5,80005ab0 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005aa2:	85a6                	mv	a1,s1
    80005aa4:	8526                	mv	a0,s1
    80005aa6:	ffffd097          	auipc	ra,0xffffd
    80005aaa:	cfc080e7          	jalr	-772(ra) # 800027a2 <sleep>
    80005aae:	bfd9                	j	80005a84 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80005ab0:	0001e517          	auipc	a0,0x1e
    80005ab4:	28050513          	addi	a0,a0,640 # 80023d30 <log>
    80005ab8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005aba:	ffffb097          	auipc	ra,0xffffb
    80005abe:	1c8080e7          	jalr	456(ra) # 80000c82 <release>
      break;
    }
  }
}
    80005ac2:	60e2                	ld	ra,24(sp)
    80005ac4:	6442                	ld	s0,16(sp)
    80005ac6:	64a2                	ld	s1,8(sp)
    80005ac8:	6902                	ld	s2,0(sp)
    80005aca:	6105                	addi	sp,sp,32
    80005acc:	8082                	ret

0000000080005ace <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005ace:	7139                	addi	sp,sp,-64
    80005ad0:	fc06                	sd	ra,56(sp)
    80005ad2:	f822                	sd	s0,48(sp)
    80005ad4:	f426                	sd	s1,40(sp)
    80005ad6:	f04a                	sd	s2,32(sp)
    80005ad8:	ec4e                	sd	s3,24(sp)
    80005ada:	e852                	sd	s4,16(sp)
    80005adc:	e456                	sd	s5,8(sp)
    80005ade:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005ae0:	0001e497          	auipc	s1,0x1e
    80005ae4:	25048493          	addi	s1,s1,592 # 80023d30 <log>
    80005ae8:	8526                	mv	a0,s1
    80005aea:	ffffb097          	auipc	ra,0xffffb
    80005aee:	0e4080e7          	jalr	228(ra) # 80000bce <acquire>
  log.outstanding -= 1;
    80005af2:	509c                	lw	a5,32(s1)
    80005af4:	37fd                	addiw	a5,a5,-1
    80005af6:	0007891b          	sext.w	s2,a5
    80005afa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80005afc:	50dc                	lw	a5,36(s1)
    80005afe:	e7b9                	bnez	a5,80005b4c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80005b00:	04091e63          	bnez	s2,80005b5c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80005b04:	0001e497          	auipc	s1,0x1e
    80005b08:	22c48493          	addi	s1,s1,556 # 80023d30 <log>
    80005b0c:	4785                	li	a5,1
    80005b0e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80005b10:	8526                	mv	a0,s1
    80005b12:	ffffb097          	auipc	ra,0xffffb
    80005b16:	170080e7          	jalr	368(ra) # 80000c82 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005b1a:	54dc                	lw	a5,44(s1)
    80005b1c:	06f04763          	bgtz	a5,80005b8a <end_op+0xbc>
    acquire(&log.lock);
    80005b20:	0001e497          	auipc	s1,0x1e
    80005b24:	21048493          	addi	s1,s1,528 # 80023d30 <log>
    80005b28:	8526                	mv	a0,s1
    80005b2a:	ffffb097          	auipc	ra,0xffffb
    80005b2e:	0a4080e7          	jalr	164(ra) # 80000bce <acquire>
    log.committing = 0;
    80005b32:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80005b36:	8526                	mv	a0,s1
    80005b38:	ffffd097          	auipc	ra,0xffffd
    80005b3c:	21c080e7          	jalr	540(ra) # 80002d54 <wakeup>
    release(&log.lock);
    80005b40:	8526                	mv	a0,s1
    80005b42:	ffffb097          	auipc	ra,0xffffb
    80005b46:	140080e7          	jalr	320(ra) # 80000c82 <release>
}
    80005b4a:	a03d                	j	80005b78 <end_op+0xaa>
    panic("log.committing");
    80005b4c:	00004517          	auipc	a0,0x4
    80005b50:	e5450513          	addi	a0,a0,-428 # 800099a0 <syscalls+0x340>
    80005b54:	ffffb097          	auipc	ra,0xffffb
    80005b58:	9e4080e7          	jalr	-1564(ra) # 80000538 <panic>
    wakeup(&log);
    80005b5c:	0001e497          	auipc	s1,0x1e
    80005b60:	1d448493          	addi	s1,s1,468 # 80023d30 <log>
    80005b64:	8526                	mv	a0,s1
    80005b66:	ffffd097          	auipc	ra,0xffffd
    80005b6a:	1ee080e7          	jalr	494(ra) # 80002d54 <wakeup>
  release(&log.lock);
    80005b6e:	8526                	mv	a0,s1
    80005b70:	ffffb097          	auipc	ra,0xffffb
    80005b74:	112080e7          	jalr	274(ra) # 80000c82 <release>
}
    80005b78:	70e2                	ld	ra,56(sp)
    80005b7a:	7442                	ld	s0,48(sp)
    80005b7c:	74a2                	ld	s1,40(sp)
    80005b7e:	7902                	ld	s2,32(sp)
    80005b80:	69e2                	ld	s3,24(sp)
    80005b82:	6a42                	ld	s4,16(sp)
    80005b84:	6aa2                	ld	s5,8(sp)
    80005b86:	6121                	addi	sp,sp,64
    80005b88:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005b8a:	0001ea97          	auipc	s5,0x1e
    80005b8e:	1d6a8a93          	addi	s5,s5,470 # 80023d60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005b92:	0001ea17          	auipc	s4,0x1e
    80005b96:	19ea0a13          	addi	s4,s4,414 # 80023d30 <log>
    80005b9a:	018a2583          	lw	a1,24(s4)
    80005b9e:	012585bb          	addw	a1,a1,s2
    80005ba2:	2585                	addiw	a1,a1,1
    80005ba4:	028a2503          	lw	a0,40(s4)
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	cca080e7          	jalr	-822(ra) # 80004872 <bread>
    80005bb0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005bb2:	000aa583          	lw	a1,0(s5)
    80005bb6:	028a2503          	lw	a0,40(s4)
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	cb8080e7          	jalr	-840(ra) # 80004872 <bread>
    80005bc2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005bc4:	40000613          	li	a2,1024
    80005bc8:	05850593          	addi	a1,a0,88
    80005bcc:	05848513          	addi	a0,s1,88
    80005bd0:	ffffb097          	auipc	ra,0xffffb
    80005bd4:	156080e7          	jalr	342(ra) # 80000d26 <memmove>
    bwrite(to);  // write the log
    80005bd8:	8526                	mv	a0,s1
    80005bda:	fffff097          	auipc	ra,0xfffff
    80005bde:	d8a080e7          	jalr	-630(ra) # 80004964 <bwrite>
    brelse(from);
    80005be2:	854e                	mv	a0,s3
    80005be4:	fffff097          	auipc	ra,0xfffff
    80005be8:	dbe080e7          	jalr	-578(ra) # 800049a2 <brelse>
    brelse(to);
    80005bec:	8526                	mv	a0,s1
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	db4080e7          	jalr	-588(ra) # 800049a2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005bf6:	2905                	addiw	s2,s2,1
    80005bf8:	0a91                	addi	s5,s5,4
    80005bfa:	02ca2783          	lw	a5,44(s4)
    80005bfe:	f8f94ee3          	blt	s2,a5,80005b9a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80005c02:	00000097          	auipc	ra,0x0
    80005c06:	c68080e7          	jalr	-920(ra) # 8000586a <write_head>
    install_trans(0); // Now install writes to home locations
    80005c0a:	4501                	li	a0,0
    80005c0c:	00000097          	auipc	ra,0x0
    80005c10:	cda080e7          	jalr	-806(ra) # 800058e6 <install_trans>
    log.lh.n = 0;
    80005c14:	0001e797          	auipc	a5,0x1e
    80005c18:	1407a423          	sw	zero,328(a5) # 80023d5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005c1c:	00000097          	auipc	ra,0x0
    80005c20:	c4e080e7          	jalr	-946(ra) # 8000586a <write_head>
    80005c24:	bdf5                	j	80005b20 <end_op+0x52>

0000000080005c26 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005c26:	1101                	addi	sp,sp,-32
    80005c28:	ec06                	sd	ra,24(sp)
    80005c2a:	e822                	sd	s0,16(sp)
    80005c2c:	e426                	sd	s1,8(sp)
    80005c2e:	e04a                	sd	s2,0(sp)
    80005c30:	1000                	addi	s0,sp,32
    80005c32:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80005c34:	0001e917          	auipc	s2,0x1e
    80005c38:	0fc90913          	addi	s2,s2,252 # 80023d30 <log>
    80005c3c:	854a                	mv	a0,s2
    80005c3e:	ffffb097          	auipc	ra,0xffffb
    80005c42:	f90080e7          	jalr	-112(ra) # 80000bce <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80005c46:	02c92603          	lw	a2,44(s2)
    80005c4a:	47f5                	li	a5,29
    80005c4c:	06c7c563          	blt	a5,a2,80005cb6 <log_write+0x90>
    80005c50:	0001e797          	auipc	a5,0x1e
    80005c54:	0fc7a783          	lw	a5,252(a5) # 80023d4c <log+0x1c>
    80005c58:	37fd                	addiw	a5,a5,-1
    80005c5a:	04f65e63          	bge	a2,a5,80005cb6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005c5e:	0001e797          	auipc	a5,0x1e
    80005c62:	0f27a783          	lw	a5,242(a5) # 80023d50 <log+0x20>
    80005c66:	06f05063          	blez	a5,80005cc6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005c6a:	4781                	li	a5,0
    80005c6c:	06c05563          	blez	a2,80005cd6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005c70:	44cc                	lw	a1,12(s1)
    80005c72:	0001e717          	auipc	a4,0x1e
    80005c76:	0ee70713          	addi	a4,a4,238 # 80023d60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005c7a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005c7c:	4314                	lw	a3,0(a4)
    80005c7e:	04b68c63          	beq	a3,a1,80005cd6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005c82:	2785                	addiw	a5,a5,1
    80005c84:	0711                	addi	a4,a4,4
    80005c86:	fef61be3          	bne	a2,a5,80005c7c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005c8a:	0621                	addi	a2,a2,8
    80005c8c:	060a                	slli	a2,a2,0x2
    80005c8e:	0001e797          	auipc	a5,0x1e
    80005c92:	0a278793          	addi	a5,a5,162 # 80023d30 <log>
    80005c96:	97b2                	add	a5,a5,a2
    80005c98:	44d8                	lw	a4,12(s1)
    80005c9a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005c9c:	8526                	mv	a0,s1
    80005c9e:	fffff097          	auipc	ra,0xfffff
    80005ca2:	da2080e7          	jalr	-606(ra) # 80004a40 <bpin>
    log.lh.n++;
    80005ca6:	0001e717          	auipc	a4,0x1e
    80005caa:	08a70713          	addi	a4,a4,138 # 80023d30 <log>
    80005cae:	575c                	lw	a5,44(a4)
    80005cb0:	2785                	addiw	a5,a5,1
    80005cb2:	d75c                	sw	a5,44(a4)
    80005cb4:	a82d                	j	80005cee <log_write+0xc8>
    panic("too big a transaction");
    80005cb6:	00004517          	auipc	a0,0x4
    80005cba:	cfa50513          	addi	a0,a0,-774 # 800099b0 <syscalls+0x350>
    80005cbe:	ffffb097          	auipc	ra,0xffffb
    80005cc2:	87a080e7          	jalr	-1926(ra) # 80000538 <panic>
    panic("log_write outside of trans");
    80005cc6:	00004517          	auipc	a0,0x4
    80005cca:	d0250513          	addi	a0,a0,-766 # 800099c8 <syscalls+0x368>
    80005cce:	ffffb097          	auipc	ra,0xffffb
    80005cd2:	86a080e7          	jalr	-1942(ra) # 80000538 <panic>
  log.lh.block[i] = b->blockno;
    80005cd6:	00878693          	addi	a3,a5,8
    80005cda:	068a                	slli	a3,a3,0x2
    80005cdc:	0001e717          	auipc	a4,0x1e
    80005ce0:	05470713          	addi	a4,a4,84 # 80023d30 <log>
    80005ce4:	9736                	add	a4,a4,a3
    80005ce6:	44d4                	lw	a3,12(s1)
    80005ce8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005cea:	faf609e3          	beq	a2,a5,80005c9c <log_write+0x76>
  }
  release(&log.lock);
    80005cee:	0001e517          	auipc	a0,0x1e
    80005cf2:	04250513          	addi	a0,a0,66 # 80023d30 <log>
    80005cf6:	ffffb097          	auipc	ra,0xffffb
    80005cfa:	f8c080e7          	jalr	-116(ra) # 80000c82 <release>
}
    80005cfe:	60e2                	ld	ra,24(sp)
    80005d00:	6442                	ld	s0,16(sp)
    80005d02:	64a2                	ld	s1,8(sp)
    80005d04:	6902                	ld	s2,0(sp)
    80005d06:	6105                	addi	sp,sp,32
    80005d08:	8082                	ret

0000000080005d0a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005d0a:	1101                	addi	sp,sp,-32
    80005d0c:	ec06                	sd	ra,24(sp)
    80005d0e:	e822                	sd	s0,16(sp)
    80005d10:	e426                	sd	s1,8(sp)
    80005d12:	e04a                	sd	s2,0(sp)
    80005d14:	1000                	addi	s0,sp,32
    80005d16:	84aa                	mv	s1,a0
    80005d18:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005d1a:	00004597          	auipc	a1,0x4
    80005d1e:	cce58593          	addi	a1,a1,-818 # 800099e8 <syscalls+0x388>
    80005d22:	0521                	addi	a0,a0,8
    80005d24:	ffffb097          	auipc	ra,0xffffb
    80005d28:	e1a080e7          	jalr	-486(ra) # 80000b3e <initlock>
  lk->name = name;
    80005d2c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005d30:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005d34:	0204a423          	sw	zero,40(s1)
}
    80005d38:	60e2                	ld	ra,24(sp)
    80005d3a:	6442                	ld	s0,16(sp)
    80005d3c:	64a2                	ld	s1,8(sp)
    80005d3e:	6902                	ld	s2,0(sp)
    80005d40:	6105                	addi	sp,sp,32
    80005d42:	8082                	ret

0000000080005d44 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005d44:	1101                	addi	sp,sp,-32
    80005d46:	ec06                	sd	ra,24(sp)
    80005d48:	e822                	sd	s0,16(sp)
    80005d4a:	e426                	sd	s1,8(sp)
    80005d4c:	e04a                	sd	s2,0(sp)
    80005d4e:	1000                	addi	s0,sp,32
    80005d50:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005d52:	00850913          	addi	s2,a0,8
    80005d56:	854a                	mv	a0,s2
    80005d58:	ffffb097          	auipc	ra,0xffffb
    80005d5c:	e76080e7          	jalr	-394(ra) # 80000bce <acquire>
  while (lk->locked) {
    80005d60:	409c                	lw	a5,0(s1)
    80005d62:	cb89                	beqz	a5,80005d74 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005d64:	85ca                	mv	a1,s2
    80005d66:	8526                	mv	a0,s1
    80005d68:	ffffd097          	auipc	ra,0xffffd
    80005d6c:	a3a080e7          	jalr	-1478(ra) # 800027a2 <sleep>
  while (lk->locked) {
    80005d70:	409c                	lw	a5,0(s1)
    80005d72:	fbed                	bnez	a5,80005d64 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005d74:	4785                	li	a5,1
    80005d76:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005d78:	ffffc097          	auipc	ra,0xffffc
    80005d7c:	c78080e7          	jalr	-904(ra) # 800019f0 <myproc>
    80005d80:	591c                	lw	a5,48(a0)
    80005d82:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005d84:	854a                	mv	a0,s2
    80005d86:	ffffb097          	auipc	ra,0xffffb
    80005d8a:	efc080e7          	jalr	-260(ra) # 80000c82 <release>
}
    80005d8e:	60e2                	ld	ra,24(sp)
    80005d90:	6442                	ld	s0,16(sp)
    80005d92:	64a2                	ld	s1,8(sp)
    80005d94:	6902                	ld	s2,0(sp)
    80005d96:	6105                	addi	sp,sp,32
    80005d98:	8082                	ret

0000000080005d9a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005d9a:	1101                	addi	sp,sp,-32
    80005d9c:	ec06                	sd	ra,24(sp)
    80005d9e:	e822                	sd	s0,16(sp)
    80005da0:	e426                	sd	s1,8(sp)
    80005da2:	e04a                	sd	s2,0(sp)
    80005da4:	1000                	addi	s0,sp,32
    80005da6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005da8:	00850913          	addi	s2,a0,8
    80005dac:	854a                	mv	a0,s2
    80005dae:	ffffb097          	auipc	ra,0xffffb
    80005db2:	e20080e7          	jalr	-480(ra) # 80000bce <acquire>
  lk->locked = 0;
    80005db6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005dba:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005dbe:	8526                	mv	a0,s1
    80005dc0:	ffffd097          	auipc	ra,0xffffd
    80005dc4:	f94080e7          	jalr	-108(ra) # 80002d54 <wakeup>
  release(&lk->lk);
    80005dc8:	854a                	mv	a0,s2
    80005dca:	ffffb097          	auipc	ra,0xffffb
    80005dce:	eb8080e7          	jalr	-328(ra) # 80000c82 <release>
}
    80005dd2:	60e2                	ld	ra,24(sp)
    80005dd4:	6442                	ld	s0,16(sp)
    80005dd6:	64a2                	ld	s1,8(sp)
    80005dd8:	6902                	ld	s2,0(sp)
    80005dda:	6105                	addi	sp,sp,32
    80005ddc:	8082                	ret

0000000080005dde <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005dde:	7179                	addi	sp,sp,-48
    80005de0:	f406                	sd	ra,40(sp)
    80005de2:	f022                	sd	s0,32(sp)
    80005de4:	ec26                	sd	s1,24(sp)
    80005de6:	e84a                	sd	s2,16(sp)
    80005de8:	e44e                	sd	s3,8(sp)
    80005dea:	1800                	addi	s0,sp,48
    80005dec:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005dee:	00850913          	addi	s2,a0,8
    80005df2:	854a                	mv	a0,s2
    80005df4:	ffffb097          	auipc	ra,0xffffb
    80005df8:	dda080e7          	jalr	-550(ra) # 80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80005dfc:	409c                	lw	a5,0(s1)
    80005dfe:	ef99                	bnez	a5,80005e1c <holdingsleep+0x3e>
    80005e00:	4481                	li	s1,0
  release(&lk->lk);
    80005e02:	854a                	mv	a0,s2
    80005e04:	ffffb097          	auipc	ra,0xffffb
    80005e08:	e7e080e7          	jalr	-386(ra) # 80000c82 <release>
  return r;
}
    80005e0c:	8526                	mv	a0,s1
    80005e0e:	70a2                	ld	ra,40(sp)
    80005e10:	7402                	ld	s0,32(sp)
    80005e12:	64e2                	ld	s1,24(sp)
    80005e14:	6942                	ld	s2,16(sp)
    80005e16:	69a2                	ld	s3,8(sp)
    80005e18:	6145                	addi	sp,sp,48
    80005e1a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005e1c:	0284a983          	lw	s3,40(s1)
    80005e20:	ffffc097          	auipc	ra,0xffffc
    80005e24:	bd0080e7          	jalr	-1072(ra) # 800019f0 <myproc>
    80005e28:	5904                	lw	s1,48(a0)
    80005e2a:	413484b3          	sub	s1,s1,s3
    80005e2e:	0014b493          	seqz	s1,s1
    80005e32:	bfc1                	j	80005e02 <holdingsleep+0x24>

0000000080005e34 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005e34:	1141                	addi	sp,sp,-16
    80005e36:	e406                	sd	ra,8(sp)
    80005e38:	e022                	sd	s0,0(sp)
    80005e3a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005e3c:	00004597          	auipc	a1,0x4
    80005e40:	bbc58593          	addi	a1,a1,-1092 # 800099f8 <syscalls+0x398>
    80005e44:	0001e517          	auipc	a0,0x1e
    80005e48:	03450513          	addi	a0,a0,52 # 80023e78 <ftable>
    80005e4c:	ffffb097          	auipc	ra,0xffffb
    80005e50:	cf2080e7          	jalr	-782(ra) # 80000b3e <initlock>
}
    80005e54:	60a2                	ld	ra,8(sp)
    80005e56:	6402                	ld	s0,0(sp)
    80005e58:	0141                	addi	sp,sp,16
    80005e5a:	8082                	ret

0000000080005e5c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005e5c:	1101                	addi	sp,sp,-32
    80005e5e:	ec06                	sd	ra,24(sp)
    80005e60:	e822                	sd	s0,16(sp)
    80005e62:	e426                	sd	s1,8(sp)
    80005e64:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005e66:	0001e517          	auipc	a0,0x1e
    80005e6a:	01250513          	addi	a0,a0,18 # 80023e78 <ftable>
    80005e6e:	ffffb097          	auipc	ra,0xffffb
    80005e72:	d60080e7          	jalr	-672(ra) # 80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005e76:	0001e497          	auipc	s1,0x1e
    80005e7a:	01a48493          	addi	s1,s1,26 # 80023e90 <ftable+0x18>
    80005e7e:	0001f717          	auipc	a4,0x1f
    80005e82:	fb270713          	addi	a4,a4,-78 # 80024e30 <ftable+0xfb8>
    if(f->ref == 0){
    80005e86:	40dc                	lw	a5,4(s1)
    80005e88:	cf99                	beqz	a5,80005ea6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005e8a:	02848493          	addi	s1,s1,40
    80005e8e:	fee49ce3          	bne	s1,a4,80005e86 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005e92:	0001e517          	auipc	a0,0x1e
    80005e96:	fe650513          	addi	a0,a0,-26 # 80023e78 <ftable>
    80005e9a:	ffffb097          	auipc	ra,0xffffb
    80005e9e:	de8080e7          	jalr	-536(ra) # 80000c82 <release>
  return 0;
    80005ea2:	4481                	li	s1,0
    80005ea4:	a819                	j	80005eba <filealloc+0x5e>
      f->ref = 1;
    80005ea6:	4785                	li	a5,1
    80005ea8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005eaa:	0001e517          	auipc	a0,0x1e
    80005eae:	fce50513          	addi	a0,a0,-50 # 80023e78 <ftable>
    80005eb2:	ffffb097          	auipc	ra,0xffffb
    80005eb6:	dd0080e7          	jalr	-560(ra) # 80000c82 <release>
}
    80005eba:	8526                	mv	a0,s1
    80005ebc:	60e2                	ld	ra,24(sp)
    80005ebe:	6442                	ld	s0,16(sp)
    80005ec0:	64a2                	ld	s1,8(sp)
    80005ec2:	6105                	addi	sp,sp,32
    80005ec4:	8082                	ret

0000000080005ec6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005ec6:	1101                	addi	sp,sp,-32
    80005ec8:	ec06                	sd	ra,24(sp)
    80005eca:	e822                	sd	s0,16(sp)
    80005ecc:	e426                	sd	s1,8(sp)
    80005ece:	1000                	addi	s0,sp,32
    80005ed0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005ed2:	0001e517          	auipc	a0,0x1e
    80005ed6:	fa650513          	addi	a0,a0,-90 # 80023e78 <ftable>
    80005eda:	ffffb097          	auipc	ra,0xffffb
    80005ede:	cf4080e7          	jalr	-780(ra) # 80000bce <acquire>
  if(f->ref < 1)
    80005ee2:	40dc                	lw	a5,4(s1)
    80005ee4:	02f05263          	blez	a5,80005f08 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005ee8:	2785                	addiw	a5,a5,1
    80005eea:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005eec:	0001e517          	auipc	a0,0x1e
    80005ef0:	f8c50513          	addi	a0,a0,-116 # 80023e78 <ftable>
    80005ef4:	ffffb097          	auipc	ra,0xffffb
    80005ef8:	d8e080e7          	jalr	-626(ra) # 80000c82 <release>
  return f;
}
    80005efc:	8526                	mv	a0,s1
    80005efe:	60e2                	ld	ra,24(sp)
    80005f00:	6442                	ld	s0,16(sp)
    80005f02:	64a2                	ld	s1,8(sp)
    80005f04:	6105                	addi	sp,sp,32
    80005f06:	8082                	ret
    panic("filedup");
    80005f08:	00004517          	auipc	a0,0x4
    80005f0c:	af850513          	addi	a0,a0,-1288 # 80009a00 <syscalls+0x3a0>
    80005f10:	ffffa097          	auipc	ra,0xffffa
    80005f14:	628080e7          	jalr	1576(ra) # 80000538 <panic>

0000000080005f18 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005f18:	7139                	addi	sp,sp,-64
    80005f1a:	fc06                	sd	ra,56(sp)
    80005f1c:	f822                	sd	s0,48(sp)
    80005f1e:	f426                	sd	s1,40(sp)
    80005f20:	f04a                	sd	s2,32(sp)
    80005f22:	ec4e                	sd	s3,24(sp)
    80005f24:	e852                	sd	s4,16(sp)
    80005f26:	e456                	sd	s5,8(sp)
    80005f28:	0080                	addi	s0,sp,64
    80005f2a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005f2c:	0001e517          	auipc	a0,0x1e
    80005f30:	f4c50513          	addi	a0,a0,-180 # 80023e78 <ftable>
    80005f34:	ffffb097          	auipc	ra,0xffffb
    80005f38:	c9a080e7          	jalr	-870(ra) # 80000bce <acquire>
  if(f->ref < 1)
    80005f3c:	40dc                	lw	a5,4(s1)
    80005f3e:	06f05163          	blez	a5,80005fa0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005f42:	37fd                	addiw	a5,a5,-1
    80005f44:	0007871b          	sext.w	a4,a5
    80005f48:	c0dc                	sw	a5,4(s1)
    80005f4a:	06e04363          	bgtz	a4,80005fb0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005f4e:	0004a903          	lw	s2,0(s1)
    80005f52:	0094ca83          	lbu	s5,9(s1)
    80005f56:	0104ba03          	ld	s4,16(s1)
    80005f5a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005f5e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005f62:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005f66:	0001e517          	auipc	a0,0x1e
    80005f6a:	f1250513          	addi	a0,a0,-238 # 80023e78 <ftable>
    80005f6e:	ffffb097          	auipc	ra,0xffffb
    80005f72:	d14080e7          	jalr	-748(ra) # 80000c82 <release>

  if(ff.type == FD_PIPE){
    80005f76:	4785                	li	a5,1
    80005f78:	04f90d63          	beq	s2,a5,80005fd2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005f7c:	3979                	addiw	s2,s2,-2
    80005f7e:	4785                	li	a5,1
    80005f80:	0527e063          	bltu	a5,s2,80005fc0 <fileclose+0xa8>
    begin_op();
    80005f84:	00000097          	auipc	ra,0x0
    80005f88:	acc080e7          	jalr	-1332(ra) # 80005a50 <begin_op>
    iput(ff.ip);
    80005f8c:	854e                	mv	a0,s3
    80005f8e:	fffff097          	auipc	ra,0xfffff
    80005f92:	2a0080e7          	jalr	672(ra) # 8000522e <iput>
    end_op();
    80005f96:	00000097          	auipc	ra,0x0
    80005f9a:	b38080e7          	jalr	-1224(ra) # 80005ace <end_op>
    80005f9e:	a00d                	j	80005fc0 <fileclose+0xa8>
    panic("fileclose");
    80005fa0:	00004517          	auipc	a0,0x4
    80005fa4:	a6850513          	addi	a0,a0,-1432 # 80009a08 <syscalls+0x3a8>
    80005fa8:	ffffa097          	auipc	ra,0xffffa
    80005fac:	590080e7          	jalr	1424(ra) # 80000538 <panic>
    release(&ftable.lock);
    80005fb0:	0001e517          	auipc	a0,0x1e
    80005fb4:	ec850513          	addi	a0,a0,-312 # 80023e78 <ftable>
    80005fb8:	ffffb097          	auipc	ra,0xffffb
    80005fbc:	cca080e7          	jalr	-822(ra) # 80000c82 <release>
  }
}
    80005fc0:	70e2                	ld	ra,56(sp)
    80005fc2:	7442                	ld	s0,48(sp)
    80005fc4:	74a2                	ld	s1,40(sp)
    80005fc6:	7902                	ld	s2,32(sp)
    80005fc8:	69e2                	ld	s3,24(sp)
    80005fca:	6a42                	ld	s4,16(sp)
    80005fcc:	6aa2                	ld	s5,8(sp)
    80005fce:	6121                	addi	sp,sp,64
    80005fd0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005fd2:	85d6                	mv	a1,s5
    80005fd4:	8552                	mv	a0,s4
    80005fd6:	00000097          	auipc	ra,0x0
    80005fda:	34c080e7          	jalr	844(ra) # 80006322 <pipeclose>
    80005fde:	b7cd                	j	80005fc0 <fileclose+0xa8>

0000000080005fe0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005fe0:	715d                	addi	sp,sp,-80
    80005fe2:	e486                	sd	ra,72(sp)
    80005fe4:	e0a2                	sd	s0,64(sp)
    80005fe6:	fc26                	sd	s1,56(sp)
    80005fe8:	f84a                	sd	s2,48(sp)
    80005fea:	f44e                	sd	s3,40(sp)
    80005fec:	0880                	addi	s0,sp,80
    80005fee:	84aa                	mv	s1,a0
    80005ff0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005ff2:	ffffc097          	auipc	ra,0xffffc
    80005ff6:	9fe080e7          	jalr	-1538(ra) # 800019f0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005ffa:	409c                	lw	a5,0(s1)
    80005ffc:	37f9                	addiw	a5,a5,-2
    80005ffe:	4705                	li	a4,1
    80006000:	04f76763          	bltu	a4,a5,8000604e <filestat+0x6e>
    80006004:	892a                	mv	s2,a0
    ilock(f->ip);
    80006006:	6c88                	ld	a0,24(s1)
    80006008:	fffff097          	auipc	ra,0xfffff
    8000600c:	06c080e7          	jalr	108(ra) # 80005074 <ilock>
    stati(f->ip, &st);
    80006010:	fb840593          	addi	a1,s0,-72
    80006014:	6c88                	ld	a0,24(s1)
    80006016:	fffff097          	auipc	ra,0xfffff
    8000601a:	2e8080e7          	jalr	744(ra) # 800052fe <stati>
    iunlock(f->ip);
    8000601e:	6c88                	ld	a0,24(s1)
    80006020:	fffff097          	auipc	ra,0xfffff
    80006024:	116080e7          	jalr	278(ra) # 80005136 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80006028:	46e1                	li	a3,24
    8000602a:	fb840613          	addi	a2,s0,-72
    8000602e:	85ce                	mv	a1,s3
    80006030:	05893503          	ld	a0,88(s2)
    80006034:	ffffb097          	auipc	ra,0xffffb
    80006038:	680080e7          	jalr	1664(ra) # 800016b4 <copyout>
    8000603c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80006040:	60a6                	ld	ra,72(sp)
    80006042:	6406                	ld	s0,64(sp)
    80006044:	74e2                	ld	s1,56(sp)
    80006046:	7942                	ld	s2,48(sp)
    80006048:	79a2                	ld	s3,40(sp)
    8000604a:	6161                	addi	sp,sp,80
    8000604c:	8082                	ret
  return -1;
    8000604e:	557d                	li	a0,-1
    80006050:	bfc5                	j	80006040 <filestat+0x60>

0000000080006052 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80006052:	7179                	addi	sp,sp,-48
    80006054:	f406                	sd	ra,40(sp)
    80006056:	f022                	sd	s0,32(sp)
    80006058:	ec26                	sd	s1,24(sp)
    8000605a:	e84a                	sd	s2,16(sp)
    8000605c:	e44e                	sd	s3,8(sp)
    8000605e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80006060:	00854783          	lbu	a5,8(a0)
    80006064:	c3d5                	beqz	a5,80006108 <fileread+0xb6>
    80006066:	84aa                	mv	s1,a0
    80006068:	89ae                	mv	s3,a1
    8000606a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000606c:	411c                	lw	a5,0(a0)
    8000606e:	4705                	li	a4,1
    80006070:	04e78963          	beq	a5,a4,800060c2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80006074:	470d                	li	a4,3
    80006076:	04e78d63          	beq	a5,a4,800060d0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000607a:	4709                	li	a4,2
    8000607c:	06e79e63          	bne	a5,a4,800060f8 <fileread+0xa6>
    ilock(f->ip);
    80006080:	6d08                	ld	a0,24(a0)
    80006082:	fffff097          	auipc	ra,0xfffff
    80006086:	ff2080e7          	jalr	-14(ra) # 80005074 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000608a:	874a                	mv	a4,s2
    8000608c:	5094                	lw	a3,32(s1)
    8000608e:	864e                	mv	a2,s3
    80006090:	4585                	li	a1,1
    80006092:	6c88                	ld	a0,24(s1)
    80006094:	fffff097          	auipc	ra,0xfffff
    80006098:	294080e7          	jalr	660(ra) # 80005328 <readi>
    8000609c:	892a                	mv	s2,a0
    8000609e:	00a05563          	blez	a0,800060a8 <fileread+0x56>
      f->off += r;
    800060a2:	509c                	lw	a5,32(s1)
    800060a4:	9fa9                	addw	a5,a5,a0
    800060a6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800060a8:	6c88                	ld	a0,24(s1)
    800060aa:	fffff097          	auipc	ra,0xfffff
    800060ae:	08c080e7          	jalr	140(ra) # 80005136 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800060b2:	854a                	mv	a0,s2
    800060b4:	70a2                	ld	ra,40(sp)
    800060b6:	7402                	ld	s0,32(sp)
    800060b8:	64e2                	ld	s1,24(sp)
    800060ba:	6942                	ld	s2,16(sp)
    800060bc:	69a2                	ld	s3,8(sp)
    800060be:	6145                	addi	sp,sp,48
    800060c0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800060c2:	6908                	ld	a0,16(a0)
    800060c4:	00000097          	auipc	ra,0x0
    800060c8:	3c0080e7          	jalr	960(ra) # 80006484 <piperead>
    800060cc:	892a                	mv	s2,a0
    800060ce:	b7d5                	j	800060b2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800060d0:	02451783          	lh	a5,36(a0)
    800060d4:	03079693          	slli	a3,a5,0x30
    800060d8:	92c1                	srli	a3,a3,0x30
    800060da:	4725                	li	a4,9
    800060dc:	02d76863          	bltu	a4,a3,8000610c <fileread+0xba>
    800060e0:	0792                	slli	a5,a5,0x4
    800060e2:	0001e717          	auipc	a4,0x1e
    800060e6:	cf670713          	addi	a4,a4,-778 # 80023dd8 <devsw>
    800060ea:	97ba                	add	a5,a5,a4
    800060ec:	639c                	ld	a5,0(a5)
    800060ee:	c38d                	beqz	a5,80006110 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800060f0:	4505                	li	a0,1
    800060f2:	9782                	jalr	a5
    800060f4:	892a                	mv	s2,a0
    800060f6:	bf75                	j	800060b2 <fileread+0x60>
    panic("fileread");
    800060f8:	00004517          	auipc	a0,0x4
    800060fc:	92050513          	addi	a0,a0,-1760 # 80009a18 <syscalls+0x3b8>
    80006100:	ffffa097          	auipc	ra,0xffffa
    80006104:	438080e7          	jalr	1080(ra) # 80000538 <panic>
    return -1;
    80006108:	597d                	li	s2,-1
    8000610a:	b765                	j	800060b2 <fileread+0x60>
      return -1;
    8000610c:	597d                	li	s2,-1
    8000610e:	b755                	j	800060b2 <fileread+0x60>
    80006110:	597d                	li	s2,-1
    80006112:	b745                	j	800060b2 <fileread+0x60>

0000000080006114 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80006114:	715d                	addi	sp,sp,-80
    80006116:	e486                	sd	ra,72(sp)
    80006118:	e0a2                	sd	s0,64(sp)
    8000611a:	fc26                	sd	s1,56(sp)
    8000611c:	f84a                	sd	s2,48(sp)
    8000611e:	f44e                	sd	s3,40(sp)
    80006120:	f052                	sd	s4,32(sp)
    80006122:	ec56                	sd	s5,24(sp)
    80006124:	e85a                	sd	s6,16(sp)
    80006126:	e45e                	sd	s7,8(sp)
    80006128:	e062                	sd	s8,0(sp)
    8000612a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000612c:	00954783          	lbu	a5,9(a0)
    80006130:	10078663          	beqz	a5,8000623c <filewrite+0x128>
    80006134:	892a                	mv	s2,a0
    80006136:	8b2e                	mv	s6,a1
    80006138:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000613a:	411c                	lw	a5,0(a0)
    8000613c:	4705                	li	a4,1
    8000613e:	02e78263          	beq	a5,a4,80006162 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80006142:	470d                	li	a4,3
    80006144:	02e78663          	beq	a5,a4,80006170 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80006148:	4709                	li	a4,2
    8000614a:	0ee79163          	bne	a5,a4,8000622c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000614e:	0ac05d63          	blez	a2,80006208 <filewrite+0xf4>
    int i = 0;
    80006152:	4981                	li	s3,0
    80006154:	6b85                	lui	s7,0x1
    80006156:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000615a:	6c05                	lui	s8,0x1
    8000615c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80006160:	a861                	j	800061f8 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80006162:	6908                	ld	a0,16(a0)
    80006164:	00000097          	auipc	ra,0x0
    80006168:	22e080e7          	jalr	558(ra) # 80006392 <pipewrite>
    8000616c:	8a2a                	mv	s4,a0
    8000616e:	a045                	j	8000620e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80006170:	02451783          	lh	a5,36(a0)
    80006174:	03079693          	slli	a3,a5,0x30
    80006178:	92c1                	srli	a3,a3,0x30
    8000617a:	4725                	li	a4,9
    8000617c:	0cd76263          	bltu	a4,a3,80006240 <filewrite+0x12c>
    80006180:	0792                	slli	a5,a5,0x4
    80006182:	0001e717          	auipc	a4,0x1e
    80006186:	c5670713          	addi	a4,a4,-938 # 80023dd8 <devsw>
    8000618a:	97ba                	add	a5,a5,a4
    8000618c:	679c                	ld	a5,8(a5)
    8000618e:	cbdd                	beqz	a5,80006244 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80006190:	4505                	li	a0,1
    80006192:	9782                	jalr	a5
    80006194:	8a2a                	mv	s4,a0
    80006196:	a8a5                	j	8000620e <filewrite+0xfa>
    80006198:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000619c:	00000097          	auipc	ra,0x0
    800061a0:	8b4080e7          	jalr	-1868(ra) # 80005a50 <begin_op>
      ilock(f->ip);
    800061a4:	01893503          	ld	a0,24(s2)
    800061a8:	fffff097          	auipc	ra,0xfffff
    800061ac:	ecc080e7          	jalr	-308(ra) # 80005074 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800061b0:	8756                	mv	a4,s5
    800061b2:	02092683          	lw	a3,32(s2)
    800061b6:	01698633          	add	a2,s3,s6
    800061ba:	4585                	li	a1,1
    800061bc:	01893503          	ld	a0,24(s2)
    800061c0:	fffff097          	auipc	ra,0xfffff
    800061c4:	260080e7          	jalr	608(ra) # 80005420 <writei>
    800061c8:	84aa                	mv	s1,a0
    800061ca:	00a05763          	blez	a0,800061d8 <filewrite+0xc4>
        f->off += r;
    800061ce:	02092783          	lw	a5,32(s2)
    800061d2:	9fa9                	addw	a5,a5,a0
    800061d4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800061d8:	01893503          	ld	a0,24(s2)
    800061dc:	fffff097          	auipc	ra,0xfffff
    800061e0:	f5a080e7          	jalr	-166(ra) # 80005136 <iunlock>
      end_op();
    800061e4:	00000097          	auipc	ra,0x0
    800061e8:	8ea080e7          	jalr	-1814(ra) # 80005ace <end_op>

      if(r != n1){
    800061ec:	009a9f63          	bne	s5,s1,8000620a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800061f0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800061f4:	0149db63          	bge	s3,s4,8000620a <filewrite+0xf6>
      int n1 = n - i;
    800061f8:	413a04bb          	subw	s1,s4,s3
    800061fc:	0004879b          	sext.w	a5,s1
    80006200:	f8fbdce3          	bge	s7,a5,80006198 <filewrite+0x84>
    80006204:	84e2                	mv	s1,s8
    80006206:	bf49                	j	80006198 <filewrite+0x84>
    int i = 0;
    80006208:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000620a:	013a1f63          	bne	s4,s3,80006228 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000620e:	8552                	mv	a0,s4
    80006210:	60a6                	ld	ra,72(sp)
    80006212:	6406                	ld	s0,64(sp)
    80006214:	74e2                	ld	s1,56(sp)
    80006216:	7942                	ld	s2,48(sp)
    80006218:	79a2                	ld	s3,40(sp)
    8000621a:	7a02                	ld	s4,32(sp)
    8000621c:	6ae2                	ld	s5,24(sp)
    8000621e:	6b42                	ld	s6,16(sp)
    80006220:	6ba2                	ld	s7,8(sp)
    80006222:	6c02                	ld	s8,0(sp)
    80006224:	6161                	addi	sp,sp,80
    80006226:	8082                	ret
    ret = (i == n ? n : -1);
    80006228:	5a7d                	li	s4,-1
    8000622a:	b7d5                	j	8000620e <filewrite+0xfa>
    panic("filewrite");
    8000622c:	00003517          	auipc	a0,0x3
    80006230:	7fc50513          	addi	a0,a0,2044 # 80009a28 <syscalls+0x3c8>
    80006234:	ffffa097          	auipc	ra,0xffffa
    80006238:	304080e7          	jalr	772(ra) # 80000538 <panic>
    return -1;
    8000623c:	5a7d                	li	s4,-1
    8000623e:	bfc1                	j	8000620e <filewrite+0xfa>
      return -1;
    80006240:	5a7d                	li	s4,-1
    80006242:	b7f1                	j	8000620e <filewrite+0xfa>
    80006244:	5a7d                	li	s4,-1
    80006246:	b7e1                	j	8000620e <filewrite+0xfa>

0000000080006248 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80006248:	7179                	addi	sp,sp,-48
    8000624a:	f406                	sd	ra,40(sp)
    8000624c:	f022                	sd	s0,32(sp)
    8000624e:	ec26                	sd	s1,24(sp)
    80006250:	e84a                	sd	s2,16(sp)
    80006252:	e44e                	sd	s3,8(sp)
    80006254:	e052                	sd	s4,0(sp)
    80006256:	1800                	addi	s0,sp,48
    80006258:	84aa                	mv	s1,a0
    8000625a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000625c:	0005b023          	sd	zero,0(a1)
    80006260:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80006264:	00000097          	auipc	ra,0x0
    80006268:	bf8080e7          	jalr	-1032(ra) # 80005e5c <filealloc>
    8000626c:	e088                	sd	a0,0(s1)
    8000626e:	c551                	beqz	a0,800062fa <pipealloc+0xb2>
    80006270:	00000097          	auipc	ra,0x0
    80006274:	bec080e7          	jalr	-1044(ra) # 80005e5c <filealloc>
    80006278:	00aa3023          	sd	a0,0(s4)
    8000627c:	c92d                	beqz	a0,800062ee <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000627e:	ffffb097          	auipc	ra,0xffffb
    80006282:	860080e7          	jalr	-1952(ra) # 80000ade <kalloc>
    80006286:	892a                	mv	s2,a0
    80006288:	c125                	beqz	a0,800062e8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000628a:	4985                	li	s3,1
    8000628c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80006290:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80006294:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80006298:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000629c:	00003597          	auipc	a1,0x3
    800062a0:	79c58593          	addi	a1,a1,1948 # 80009a38 <syscalls+0x3d8>
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	89a080e7          	jalr	-1894(ra) # 80000b3e <initlock>
  (*f0)->type = FD_PIPE;
    800062ac:	609c                	ld	a5,0(s1)
    800062ae:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800062b2:	609c                	ld	a5,0(s1)
    800062b4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800062b8:	609c                	ld	a5,0(s1)
    800062ba:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800062be:	609c                	ld	a5,0(s1)
    800062c0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800062c4:	000a3783          	ld	a5,0(s4)
    800062c8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800062cc:	000a3783          	ld	a5,0(s4)
    800062d0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800062d4:	000a3783          	ld	a5,0(s4)
    800062d8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800062dc:	000a3783          	ld	a5,0(s4)
    800062e0:	0127b823          	sd	s2,16(a5)
  return 0;
    800062e4:	4501                	li	a0,0
    800062e6:	a025                	j	8000630e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800062e8:	6088                	ld	a0,0(s1)
    800062ea:	e501                	bnez	a0,800062f2 <pipealloc+0xaa>
    800062ec:	a039                	j	800062fa <pipealloc+0xb2>
    800062ee:	6088                	ld	a0,0(s1)
    800062f0:	c51d                	beqz	a0,8000631e <pipealloc+0xd6>
    fileclose(*f0);
    800062f2:	00000097          	auipc	ra,0x0
    800062f6:	c26080e7          	jalr	-986(ra) # 80005f18 <fileclose>
  if(*f1)
    800062fa:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800062fe:	557d                	li	a0,-1
  if(*f1)
    80006300:	c799                	beqz	a5,8000630e <pipealloc+0xc6>
    fileclose(*f1);
    80006302:	853e                	mv	a0,a5
    80006304:	00000097          	auipc	ra,0x0
    80006308:	c14080e7          	jalr	-1004(ra) # 80005f18 <fileclose>
  return -1;
    8000630c:	557d                	li	a0,-1
}
    8000630e:	70a2                	ld	ra,40(sp)
    80006310:	7402                	ld	s0,32(sp)
    80006312:	64e2                	ld	s1,24(sp)
    80006314:	6942                	ld	s2,16(sp)
    80006316:	69a2                	ld	s3,8(sp)
    80006318:	6a02                	ld	s4,0(sp)
    8000631a:	6145                	addi	sp,sp,48
    8000631c:	8082                	ret
  return -1;
    8000631e:	557d                	li	a0,-1
    80006320:	b7fd                	j	8000630e <pipealloc+0xc6>

0000000080006322 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80006322:	1101                	addi	sp,sp,-32
    80006324:	ec06                	sd	ra,24(sp)
    80006326:	e822                	sd	s0,16(sp)
    80006328:	e426                	sd	s1,8(sp)
    8000632a:	e04a                	sd	s2,0(sp)
    8000632c:	1000                	addi	s0,sp,32
    8000632e:	84aa                	mv	s1,a0
    80006330:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80006332:	ffffb097          	auipc	ra,0xffffb
    80006336:	89c080e7          	jalr	-1892(ra) # 80000bce <acquire>
  if(writable){
    8000633a:	02090d63          	beqz	s2,80006374 <pipeclose+0x52>
    pi->writeopen = 0;
    8000633e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80006342:	21848513          	addi	a0,s1,536
    80006346:	ffffd097          	auipc	ra,0xffffd
    8000634a:	a0e080e7          	jalr	-1522(ra) # 80002d54 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000634e:	2204b783          	ld	a5,544(s1)
    80006352:	eb95                	bnez	a5,80006386 <pipeclose+0x64>
    release(&pi->lock);
    80006354:	8526                	mv	a0,s1
    80006356:	ffffb097          	auipc	ra,0xffffb
    8000635a:	92c080e7          	jalr	-1748(ra) # 80000c82 <release>
    kfree((char*)pi);
    8000635e:	8526                	mv	a0,s1
    80006360:	ffffa097          	auipc	ra,0xffffa
    80006364:	680080e7          	jalr	1664(ra) # 800009e0 <kfree>
  } else
    release(&pi->lock);
}
    80006368:	60e2                	ld	ra,24(sp)
    8000636a:	6442                	ld	s0,16(sp)
    8000636c:	64a2                	ld	s1,8(sp)
    8000636e:	6902                	ld	s2,0(sp)
    80006370:	6105                	addi	sp,sp,32
    80006372:	8082                	ret
    pi->readopen = 0;
    80006374:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80006378:	21c48513          	addi	a0,s1,540
    8000637c:	ffffd097          	auipc	ra,0xffffd
    80006380:	9d8080e7          	jalr	-1576(ra) # 80002d54 <wakeup>
    80006384:	b7e9                	j	8000634e <pipeclose+0x2c>
    release(&pi->lock);
    80006386:	8526                	mv	a0,s1
    80006388:	ffffb097          	auipc	ra,0xffffb
    8000638c:	8fa080e7          	jalr	-1798(ra) # 80000c82 <release>
}
    80006390:	bfe1                	j	80006368 <pipeclose+0x46>

0000000080006392 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80006392:	711d                	addi	sp,sp,-96
    80006394:	ec86                	sd	ra,88(sp)
    80006396:	e8a2                	sd	s0,80(sp)
    80006398:	e4a6                	sd	s1,72(sp)
    8000639a:	e0ca                	sd	s2,64(sp)
    8000639c:	fc4e                	sd	s3,56(sp)
    8000639e:	f852                	sd	s4,48(sp)
    800063a0:	f456                	sd	s5,40(sp)
    800063a2:	f05a                	sd	s6,32(sp)
    800063a4:	ec5e                	sd	s7,24(sp)
    800063a6:	e862                	sd	s8,16(sp)
    800063a8:	1080                	addi	s0,sp,96
    800063aa:	84aa                	mv	s1,a0
    800063ac:	8aae                	mv	s5,a1
    800063ae:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800063b0:	ffffb097          	auipc	ra,0xffffb
    800063b4:	640080e7          	jalr	1600(ra) # 800019f0 <myproc>
    800063b8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800063ba:	8526                	mv	a0,s1
    800063bc:	ffffb097          	auipc	ra,0xffffb
    800063c0:	812080e7          	jalr	-2030(ra) # 80000bce <acquire>
  while(i < n){
    800063c4:	0b405363          	blez	s4,8000646a <pipewrite+0xd8>
  int i = 0;
    800063c8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800063ca:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800063cc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800063d0:	21c48b93          	addi	s7,s1,540
    800063d4:	a089                	j	80006416 <pipewrite+0x84>
      release(&pi->lock);
    800063d6:	8526                	mv	a0,s1
    800063d8:	ffffb097          	auipc	ra,0xffffb
    800063dc:	8aa080e7          	jalr	-1878(ra) # 80000c82 <release>
      return -1;
    800063e0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800063e2:	854a                	mv	a0,s2
    800063e4:	60e6                	ld	ra,88(sp)
    800063e6:	6446                	ld	s0,80(sp)
    800063e8:	64a6                	ld	s1,72(sp)
    800063ea:	6906                	ld	s2,64(sp)
    800063ec:	79e2                	ld	s3,56(sp)
    800063ee:	7a42                	ld	s4,48(sp)
    800063f0:	7aa2                	ld	s5,40(sp)
    800063f2:	7b02                	ld	s6,32(sp)
    800063f4:	6be2                	ld	s7,24(sp)
    800063f6:	6c42                	ld	s8,16(sp)
    800063f8:	6125                	addi	sp,sp,96
    800063fa:	8082                	ret
      wakeup(&pi->nread);
    800063fc:	8562                	mv	a0,s8
    800063fe:	ffffd097          	auipc	ra,0xffffd
    80006402:	956080e7          	jalr	-1706(ra) # 80002d54 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80006406:	85a6                	mv	a1,s1
    80006408:	855e                	mv	a0,s7
    8000640a:	ffffc097          	auipc	ra,0xffffc
    8000640e:	398080e7          	jalr	920(ra) # 800027a2 <sleep>
  while(i < n){
    80006412:	05495d63          	bge	s2,s4,8000646c <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80006416:	2204a783          	lw	a5,544(s1)
    8000641a:	dfd5                	beqz	a5,800063d6 <pipewrite+0x44>
    8000641c:	0289a783          	lw	a5,40(s3)
    80006420:	fbdd                	bnez	a5,800063d6 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80006422:	2184a783          	lw	a5,536(s1)
    80006426:	21c4a703          	lw	a4,540(s1)
    8000642a:	2007879b          	addiw	a5,a5,512
    8000642e:	fcf707e3          	beq	a4,a5,800063fc <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80006432:	4685                	li	a3,1
    80006434:	01590633          	add	a2,s2,s5
    80006438:	faf40593          	addi	a1,s0,-81
    8000643c:	0589b503          	ld	a0,88(s3)
    80006440:	ffffb097          	auipc	ra,0xffffb
    80006444:	300080e7          	jalr	768(ra) # 80001740 <copyin>
    80006448:	03650263          	beq	a0,s6,8000646c <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000644c:	21c4a783          	lw	a5,540(s1)
    80006450:	0017871b          	addiw	a4,a5,1
    80006454:	20e4ae23          	sw	a4,540(s1)
    80006458:	1ff7f793          	andi	a5,a5,511
    8000645c:	97a6                	add	a5,a5,s1
    8000645e:	faf44703          	lbu	a4,-81(s0)
    80006462:	00e78c23          	sb	a4,24(a5)
      i++;
    80006466:	2905                	addiw	s2,s2,1
    80006468:	b76d                	j	80006412 <pipewrite+0x80>
  int i = 0;
    8000646a:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000646c:	21848513          	addi	a0,s1,536
    80006470:	ffffd097          	auipc	ra,0xffffd
    80006474:	8e4080e7          	jalr	-1820(ra) # 80002d54 <wakeup>
  release(&pi->lock);
    80006478:	8526                	mv	a0,s1
    8000647a:	ffffb097          	auipc	ra,0xffffb
    8000647e:	808080e7          	jalr	-2040(ra) # 80000c82 <release>
  return i;
    80006482:	b785                	j	800063e2 <pipewrite+0x50>

0000000080006484 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80006484:	715d                	addi	sp,sp,-80
    80006486:	e486                	sd	ra,72(sp)
    80006488:	e0a2                	sd	s0,64(sp)
    8000648a:	fc26                	sd	s1,56(sp)
    8000648c:	f84a                	sd	s2,48(sp)
    8000648e:	f44e                	sd	s3,40(sp)
    80006490:	f052                	sd	s4,32(sp)
    80006492:	ec56                	sd	s5,24(sp)
    80006494:	e85a                	sd	s6,16(sp)
    80006496:	0880                	addi	s0,sp,80
    80006498:	84aa                	mv	s1,a0
    8000649a:	892e                	mv	s2,a1
    8000649c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000649e:	ffffb097          	auipc	ra,0xffffb
    800064a2:	552080e7          	jalr	1362(ra) # 800019f0 <myproc>
    800064a6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800064a8:	8526                	mv	a0,s1
    800064aa:	ffffa097          	auipc	ra,0xffffa
    800064ae:	724080e7          	jalr	1828(ra) # 80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800064b2:	2184a703          	lw	a4,536(s1)
    800064b6:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800064ba:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800064be:	02f71463          	bne	a4,a5,800064e6 <piperead+0x62>
    800064c2:	2244a783          	lw	a5,548(s1)
    800064c6:	c385                	beqz	a5,800064e6 <piperead+0x62>
    if(pr->killed){
    800064c8:	028a2783          	lw	a5,40(s4)
    800064cc:	ebc9                	bnez	a5,8000655e <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800064ce:	85a6                	mv	a1,s1
    800064d0:	854e                	mv	a0,s3
    800064d2:	ffffc097          	auipc	ra,0xffffc
    800064d6:	2d0080e7          	jalr	720(ra) # 800027a2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800064da:	2184a703          	lw	a4,536(s1)
    800064de:	21c4a783          	lw	a5,540(s1)
    800064e2:	fef700e3          	beq	a4,a5,800064c2 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800064e6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800064e8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800064ea:	05505463          	blez	s5,80006532 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    800064ee:	2184a783          	lw	a5,536(s1)
    800064f2:	21c4a703          	lw	a4,540(s1)
    800064f6:	02f70e63          	beq	a4,a5,80006532 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800064fa:	0017871b          	addiw	a4,a5,1
    800064fe:	20e4ac23          	sw	a4,536(s1)
    80006502:	1ff7f793          	andi	a5,a5,511
    80006506:	97a6                	add	a5,a5,s1
    80006508:	0187c783          	lbu	a5,24(a5)
    8000650c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80006510:	4685                	li	a3,1
    80006512:	fbf40613          	addi	a2,s0,-65
    80006516:	85ca                	mv	a1,s2
    80006518:	058a3503          	ld	a0,88(s4)
    8000651c:	ffffb097          	auipc	ra,0xffffb
    80006520:	198080e7          	jalr	408(ra) # 800016b4 <copyout>
    80006524:	01650763          	beq	a0,s6,80006532 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006528:	2985                	addiw	s3,s3,1
    8000652a:	0905                	addi	s2,s2,1
    8000652c:	fd3a91e3          	bne	s5,s3,800064ee <piperead+0x6a>
    80006530:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80006532:	21c48513          	addi	a0,s1,540
    80006536:	ffffd097          	auipc	ra,0xffffd
    8000653a:	81e080e7          	jalr	-2018(ra) # 80002d54 <wakeup>
  release(&pi->lock);
    8000653e:	8526                	mv	a0,s1
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	742080e7          	jalr	1858(ra) # 80000c82 <release>
  return i;
}
    80006548:	854e                	mv	a0,s3
    8000654a:	60a6                	ld	ra,72(sp)
    8000654c:	6406                	ld	s0,64(sp)
    8000654e:	74e2                	ld	s1,56(sp)
    80006550:	7942                	ld	s2,48(sp)
    80006552:	79a2                	ld	s3,40(sp)
    80006554:	7a02                	ld	s4,32(sp)
    80006556:	6ae2                	ld	s5,24(sp)
    80006558:	6b42                	ld	s6,16(sp)
    8000655a:	6161                	addi	sp,sp,80
    8000655c:	8082                	ret
      release(&pi->lock);
    8000655e:	8526                	mv	a0,s1
    80006560:	ffffa097          	auipc	ra,0xffffa
    80006564:	722080e7          	jalr	1826(ra) # 80000c82 <release>
      return -1;
    80006568:	59fd                	li	s3,-1
    8000656a:	bff9                	j	80006548 <piperead+0xc4>

000000008000656c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    8000656c:	de010113          	addi	sp,sp,-544
    80006570:	20113c23          	sd	ra,536(sp)
    80006574:	20813823          	sd	s0,528(sp)
    80006578:	20913423          	sd	s1,520(sp)
    8000657c:	21213023          	sd	s2,512(sp)
    80006580:	ffce                	sd	s3,504(sp)
    80006582:	fbd2                	sd	s4,496(sp)
    80006584:	f7d6                	sd	s5,488(sp)
    80006586:	f3da                	sd	s6,480(sp)
    80006588:	efde                	sd	s7,472(sp)
    8000658a:	ebe2                	sd	s8,464(sp)
    8000658c:	e7e6                	sd	s9,456(sp)
    8000658e:	e3ea                	sd	s10,448(sp)
    80006590:	ff6e                	sd	s11,440(sp)
    80006592:	1400                	addi	s0,sp,544
    80006594:	892a                	mv	s2,a0
    80006596:	dea43423          	sd	a0,-536(s0)
    8000659a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000659e:	ffffb097          	auipc	ra,0xffffb
    800065a2:	452080e7          	jalr	1106(ra) # 800019f0 <myproc>
    800065a6:	84aa                	mv	s1,a0

  begin_op();
    800065a8:	fffff097          	auipc	ra,0xfffff
    800065ac:	4a8080e7          	jalr	1192(ra) # 80005a50 <begin_op>

  if((ip = namei(path)) == 0){
    800065b0:	854a                	mv	a0,s2
    800065b2:	fffff097          	auipc	ra,0xfffff
    800065b6:	27e080e7          	jalr	638(ra) # 80005830 <namei>
    800065ba:	c93d                	beqz	a0,80006630 <exec+0xc4>
    800065bc:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800065be:	fffff097          	auipc	ra,0xfffff
    800065c2:	ab6080e7          	jalr	-1354(ra) # 80005074 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800065c6:	04000713          	li	a4,64
    800065ca:	4681                	li	a3,0
    800065cc:	e5040613          	addi	a2,s0,-432
    800065d0:	4581                	li	a1,0
    800065d2:	8556                	mv	a0,s5
    800065d4:	fffff097          	auipc	ra,0xfffff
    800065d8:	d54080e7          	jalr	-684(ra) # 80005328 <readi>
    800065dc:	04000793          	li	a5,64
    800065e0:	00f51a63          	bne	a0,a5,800065f4 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800065e4:	e5042703          	lw	a4,-432(s0)
    800065e8:	464c47b7          	lui	a5,0x464c4
    800065ec:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800065f0:	04f70663          	beq	a4,a5,8000663c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800065f4:	8556                	mv	a0,s5
    800065f6:	fffff097          	auipc	ra,0xfffff
    800065fa:	ce0080e7          	jalr	-800(ra) # 800052d6 <iunlockput>
    end_op();
    800065fe:	fffff097          	auipc	ra,0xfffff
    80006602:	4d0080e7          	jalr	1232(ra) # 80005ace <end_op>
  }
  return -1;
    80006606:	557d                	li	a0,-1
}
    80006608:	21813083          	ld	ra,536(sp)
    8000660c:	21013403          	ld	s0,528(sp)
    80006610:	20813483          	ld	s1,520(sp)
    80006614:	20013903          	ld	s2,512(sp)
    80006618:	79fe                	ld	s3,504(sp)
    8000661a:	7a5e                	ld	s4,496(sp)
    8000661c:	7abe                	ld	s5,488(sp)
    8000661e:	7b1e                	ld	s6,480(sp)
    80006620:	6bfe                	ld	s7,472(sp)
    80006622:	6c5e                	ld	s8,464(sp)
    80006624:	6cbe                	ld	s9,456(sp)
    80006626:	6d1e                	ld	s10,448(sp)
    80006628:	7dfa                	ld	s11,440(sp)
    8000662a:	22010113          	addi	sp,sp,544
    8000662e:	8082                	ret
    end_op();
    80006630:	fffff097          	auipc	ra,0xfffff
    80006634:	49e080e7          	jalr	1182(ra) # 80005ace <end_op>
    return -1;
    80006638:	557d                	li	a0,-1
    8000663a:	b7f9                	j	80006608 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000663c:	8526                	mv	a0,s1
    8000663e:	ffffb097          	auipc	ra,0xffffb
    80006642:	4ae080e7          	jalr	1198(ra) # 80001aec <proc_pagetable>
    80006646:	8b2a                	mv	s6,a0
    80006648:	d555                	beqz	a0,800065f4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000664a:	e7042783          	lw	a5,-400(s0)
    8000664e:	e8845703          	lhu	a4,-376(s0)
    80006652:	c735                	beqz	a4,800066be <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80006654:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006656:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    8000665a:	6a05                	lui	s4,0x1
    8000665c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80006660:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80006664:	6d85                	lui	s11,0x1
    80006666:	7d7d                	lui	s10,0xfffff
    80006668:	ac1d                	j	8000689e <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000666a:	00003517          	auipc	a0,0x3
    8000666e:	3d650513          	addi	a0,a0,982 # 80009a40 <syscalls+0x3e0>
    80006672:	ffffa097          	auipc	ra,0xffffa
    80006676:	ec6080e7          	jalr	-314(ra) # 80000538 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000667a:	874a                	mv	a4,s2
    8000667c:	009c86bb          	addw	a3,s9,s1
    80006680:	4581                	li	a1,0
    80006682:	8556                	mv	a0,s5
    80006684:	fffff097          	auipc	ra,0xfffff
    80006688:	ca4080e7          	jalr	-860(ra) # 80005328 <readi>
    8000668c:	2501                	sext.w	a0,a0
    8000668e:	1aa91863          	bne	s2,a0,8000683e <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80006692:	009d84bb          	addw	s1,s11,s1
    80006696:	013d09bb          	addw	s3,s10,s3
    8000669a:	1f74f263          	bgeu	s1,s7,8000687e <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    8000669e:	02049593          	slli	a1,s1,0x20
    800066a2:	9181                	srli	a1,a1,0x20
    800066a4:	95e2                	add	a1,a1,s8
    800066a6:	855a                	mv	a0,s6
    800066a8:	ffffb097          	auipc	ra,0xffffb
    800066ac:	a04080e7          	jalr	-1532(ra) # 800010ac <walkaddr>
    800066b0:	862a                	mv	a2,a0
    if(pa == 0)
    800066b2:	dd45                	beqz	a0,8000666a <exec+0xfe>
      n = PGSIZE;
    800066b4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800066b6:	fd49f2e3          	bgeu	s3,s4,8000667a <exec+0x10e>
      n = sz - i;
    800066ba:	894e                	mv	s2,s3
    800066bc:	bf7d                	j	8000667a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800066be:	4481                	li	s1,0
  iunlockput(ip);
    800066c0:	8556                	mv	a0,s5
    800066c2:	fffff097          	auipc	ra,0xfffff
    800066c6:	c14080e7          	jalr	-1004(ra) # 800052d6 <iunlockput>
  end_op();
    800066ca:	fffff097          	auipc	ra,0xfffff
    800066ce:	404080e7          	jalr	1028(ra) # 80005ace <end_op>
  p = myproc();
    800066d2:	ffffb097          	auipc	ra,0xffffb
    800066d6:	31e080e7          	jalr	798(ra) # 800019f0 <myproc>
    800066da:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800066dc:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800066e0:	6785                	lui	a5,0x1
    800066e2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800066e4:	97a6                	add	a5,a5,s1
    800066e6:	777d                	lui	a4,0xfffff
    800066e8:	8ff9                	and	a5,a5,a4
    800066ea:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800066ee:	6609                	lui	a2,0x2
    800066f0:	963e                	add	a2,a2,a5
    800066f2:	85be                	mv	a1,a5
    800066f4:	855a                	mv	a0,s6
    800066f6:	ffffb097          	auipc	ra,0xffffb
    800066fa:	d6a080e7          	jalr	-662(ra) # 80001460 <uvmalloc>
    800066fe:	8c2a                	mv	s8,a0
  ip = 0;
    80006700:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80006702:	12050e63          	beqz	a0,8000683e <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80006706:	75f9                	lui	a1,0xffffe
    80006708:	95aa                	add	a1,a1,a0
    8000670a:	855a                	mv	a0,s6
    8000670c:	ffffb097          	auipc	ra,0xffffb
    80006710:	f76080e7          	jalr	-138(ra) # 80001682 <uvmclear>
  stackbase = sp - PGSIZE;
    80006714:	7afd                	lui	s5,0xfffff
    80006716:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80006718:	df043783          	ld	a5,-528(s0)
    8000671c:	6388                	ld	a0,0(a5)
    8000671e:	c925                	beqz	a0,8000678e <exec+0x222>
    80006720:	e9040993          	addi	s3,s0,-368
    80006724:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80006728:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000672a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000672c:	ffffa097          	auipc	ra,0xffffa
    80006730:	71a080e7          	jalr	1818(ra) # 80000e46 <strlen>
    80006734:	0015079b          	addiw	a5,a0,1
    80006738:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000673c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80006740:	13596363          	bltu	s2,s5,80006866 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80006744:	df043d83          	ld	s11,-528(s0)
    80006748:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000674c:	8552                	mv	a0,s4
    8000674e:	ffffa097          	auipc	ra,0xffffa
    80006752:	6f8080e7          	jalr	1784(ra) # 80000e46 <strlen>
    80006756:	0015069b          	addiw	a3,a0,1
    8000675a:	8652                	mv	a2,s4
    8000675c:	85ca                	mv	a1,s2
    8000675e:	855a                	mv	a0,s6
    80006760:	ffffb097          	auipc	ra,0xffffb
    80006764:	f54080e7          	jalr	-172(ra) # 800016b4 <copyout>
    80006768:	10054363          	bltz	a0,8000686e <exec+0x302>
    ustack[argc] = sp;
    8000676c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80006770:	0485                	addi	s1,s1,1
    80006772:	008d8793          	addi	a5,s11,8
    80006776:	def43823          	sd	a5,-528(s0)
    8000677a:	008db503          	ld	a0,8(s11)
    8000677e:	c911                	beqz	a0,80006792 <exec+0x226>
    if(argc >= MAXARG)
    80006780:	09a1                	addi	s3,s3,8
    80006782:	fb3c95e3          	bne	s9,s3,8000672c <exec+0x1c0>
  sz = sz1;
    80006786:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000678a:	4a81                	li	s5,0
    8000678c:	a84d                	j	8000683e <exec+0x2d2>
  sp = sz;
    8000678e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80006790:	4481                	li	s1,0
  ustack[argc] = 0;
    80006792:	00349793          	slli	a5,s1,0x3
    80006796:	f9078793          	addi	a5,a5,-112
    8000679a:	97a2                	add	a5,a5,s0
    8000679c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800067a0:	00148693          	addi	a3,s1,1
    800067a4:	068e                	slli	a3,a3,0x3
    800067a6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800067aa:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800067ae:	01597663          	bgeu	s2,s5,800067ba <exec+0x24e>
  sz = sz1;
    800067b2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800067b6:	4a81                	li	s5,0
    800067b8:	a059                	j	8000683e <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800067ba:	e9040613          	addi	a2,s0,-368
    800067be:	85ca                	mv	a1,s2
    800067c0:	855a                	mv	a0,s6
    800067c2:	ffffb097          	auipc	ra,0xffffb
    800067c6:	ef2080e7          	jalr	-270(ra) # 800016b4 <copyout>
    800067ca:	0a054663          	bltz	a0,80006876 <exec+0x30a>
  p->trapframe->a1 = sp;
    800067ce:	060bb783          	ld	a5,96(s7)
    800067d2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800067d6:	de843783          	ld	a5,-536(s0)
    800067da:	0007c703          	lbu	a4,0(a5)
    800067de:	cf11                	beqz	a4,800067fa <exec+0x28e>
    800067e0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800067e2:	02f00693          	li	a3,47
    800067e6:	a039                	j	800067f4 <exec+0x288>
      last = s+1;
    800067e8:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800067ec:	0785                	addi	a5,a5,1
    800067ee:	fff7c703          	lbu	a4,-1(a5)
    800067f2:	c701                	beqz	a4,800067fa <exec+0x28e>
    if(*s == '/')
    800067f4:	fed71ce3          	bne	a4,a3,800067ec <exec+0x280>
    800067f8:	bfc5                	j	800067e8 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800067fa:	4641                	li	a2,16
    800067fc:	de843583          	ld	a1,-536(s0)
    80006800:	160b8513          	addi	a0,s7,352
    80006804:	ffffa097          	auipc	ra,0xffffa
    80006808:	610080e7          	jalr	1552(ra) # 80000e14 <safestrcpy>
  oldpagetable = p->pagetable;
    8000680c:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80006810:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80006814:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80006818:	060bb783          	ld	a5,96(s7)
    8000681c:	e6843703          	ld	a4,-408(s0)
    80006820:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80006822:	060bb783          	ld	a5,96(s7)
    80006826:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000682a:	85ea                	mv	a1,s10
    8000682c:	ffffb097          	auipc	ra,0xffffb
    80006830:	35c080e7          	jalr	860(ra) # 80001b88 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80006834:	0004851b          	sext.w	a0,s1
    80006838:	bbc1                	j	80006608 <exec+0x9c>
    8000683a:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000683e:	df843583          	ld	a1,-520(s0)
    80006842:	855a                	mv	a0,s6
    80006844:	ffffb097          	auipc	ra,0xffffb
    80006848:	344080e7          	jalr	836(ra) # 80001b88 <proc_freepagetable>
  if(ip){
    8000684c:	da0a94e3          	bnez	s5,800065f4 <exec+0x88>
  return -1;
    80006850:	557d                	li	a0,-1
    80006852:	bb5d                	j	80006608 <exec+0x9c>
    80006854:	de943c23          	sd	s1,-520(s0)
    80006858:	b7dd                	j	8000683e <exec+0x2d2>
    8000685a:	de943c23          	sd	s1,-520(s0)
    8000685e:	b7c5                	j	8000683e <exec+0x2d2>
    80006860:	de943c23          	sd	s1,-520(s0)
    80006864:	bfe9                	j	8000683e <exec+0x2d2>
  sz = sz1;
    80006866:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000686a:	4a81                	li	s5,0
    8000686c:	bfc9                	j	8000683e <exec+0x2d2>
  sz = sz1;
    8000686e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80006872:	4a81                	li	s5,0
    80006874:	b7e9                	j	8000683e <exec+0x2d2>
  sz = sz1;
    80006876:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000687a:	4a81                	li	s5,0
    8000687c:	b7c9                	j	8000683e <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000687e:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006882:	e0843783          	ld	a5,-504(s0)
    80006886:	0017869b          	addiw	a3,a5,1
    8000688a:	e0d43423          	sd	a3,-504(s0)
    8000688e:	e0043783          	ld	a5,-512(s0)
    80006892:	0387879b          	addiw	a5,a5,56
    80006896:	e8845703          	lhu	a4,-376(s0)
    8000689a:	e2e6d3e3          	bge	a3,a4,800066c0 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000689e:	2781                	sext.w	a5,a5
    800068a0:	e0f43023          	sd	a5,-512(s0)
    800068a4:	03800713          	li	a4,56
    800068a8:	86be                	mv	a3,a5
    800068aa:	e1840613          	addi	a2,s0,-488
    800068ae:	4581                	li	a1,0
    800068b0:	8556                	mv	a0,s5
    800068b2:	fffff097          	auipc	ra,0xfffff
    800068b6:	a76080e7          	jalr	-1418(ra) # 80005328 <readi>
    800068ba:	03800793          	li	a5,56
    800068be:	f6f51ee3          	bne	a0,a5,8000683a <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800068c2:	e1842783          	lw	a5,-488(s0)
    800068c6:	4705                	li	a4,1
    800068c8:	fae79de3          	bne	a5,a4,80006882 <exec+0x316>
    if(ph.memsz < ph.filesz)
    800068cc:	e4043603          	ld	a2,-448(s0)
    800068d0:	e3843783          	ld	a5,-456(s0)
    800068d4:	f8f660e3          	bltu	a2,a5,80006854 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800068d8:	e2843783          	ld	a5,-472(s0)
    800068dc:	963e                	add	a2,a2,a5
    800068de:	f6f66ee3          	bltu	a2,a5,8000685a <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800068e2:	85a6                	mv	a1,s1
    800068e4:	855a                	mv	a0,s6
    800068e6:	ffffb097          	auipc	ra,0xffffb
    800068ea:	b7a080e7          	jalr	-1158(ra) # 80001460 <uvmalloc>
    800068ee:	dea43c23          	sd	a0,-520(s0)
    800068f2:	d53d                	beqz	a0,80006860 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    800068f4:	e2843c03          	ld	s8,-472(s0)
    800068f8:	de043783          	ld	a5,-544(s0)
    800068fc:	00fc77b3          	and	a5,s8,a5
    80006900:	ff9d                	bnez	a5,8000683e <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80006902:	e2042c83          	lw	s9,-480(s0)
    80006906:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000690a:	f60b8ae3          	beqz	s7,8000687e <exec+0x312>
    8000690e:	89de                	mv	s3,s7
    80006910:	4481                	li	s1,0
    80006912:	b371                	j	8000669e <exec+0x132>

0000000080006914 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006914:	7179                	addi	sp,sp,-48
    80006916:	f406                	sd	ra,40(sp)
    80006918:	f022                	sd	s0,32(sp)
    8000691a:	ec26                	sd	s1,24(sp)
    8000691c:	e84a                	sd	s2,16(sp)
    8000691e:	1800                	addi	s0,sp,48
    80006920:	892e                	mv	s2,a1
    80006922:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80006924:	fdc40593          	addi	a1,s0,-36
    80006928:	ffffd097          	auipc	ra,0xffffd
    8000692c:	47e080e7          	jalr	1150(ra) # 80003da6 <argint>
    80006930:	04054063          	bltz	a0,80006970 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006934:	fdc42703          	lw	a4,-36(s0)
    80006938:	47bd                	li	a5,15
    8000693a:	02e7ed63          	bltu	a5,a4,80006974 <argfd+0x60>
    8000693e:	ffffb097          	auipc	ra,0xffffb
    80006942:	0b2080e7          	jalr	178(ra) # 800019f0 <myproc>
    80006946:	fdc42703          	lw	a4,-36(s0)
    8000694a:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd701a>
    8000694e:	078e                	slli	a5,a5,0x3
    80006950:	953e                	add	a0,a0,a5
    80006952:	651c                	ld	a5,8(a0)
    80006954:	c395                	beqz	a5,80006978 <argfd+0x64>
    return -1;
  if(pfd)
    80006956:	00090463          	beqz	s2,8000695e <argfd+0x4a>
    *pfd = fd;
    8000695a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000695e:	4501                	li	a0,0
  if(pf)
    80006960:	c091                	beqz	s1,80006964 <argfd+0x50>
    *pf = f;
    80006962:	e09c                	sd	a5,0(s1)
}
    80006964:	70a2                	ld	ra,40(sp)
    80006966:	7402                	ld	s0,32(sp)
    80006968:	64e2                	ld	s1,24(sp)
    8000696a:	6942                	ld	s2,16(sp)
    8000696c:	6145                	addi	sp,sp,48
    8000696e:	8082                	ret
    return -1;
    80006970:	557d                	li	a0,-1
    80006972:	bfcd                	j	80006964 <argfd+0x50>
    return -1;
    80006974:	557d                	li	a0,-1
    80006976:	b7fd                	j	80006964 <argfd+0x50>
    80006978:	557d                	li	a0,-1
    8000697a:	b7ed                	j	80006964 <argfd+0x50>

000000008000697c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000697c:	1101                	addi	sp,sp,-32
    8000697e:	ec06                	sd	ra,24(sp)
    80006980:	e822                	sd	s0,16(sp)
    80006982:	e426                	sd	s1,8(sp)
    80006984:	1000                	addi	s0,sp,32
    80006986:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80006988:	ffffb097          	auipc	ra,0xffffb
    8000698c:	068080e7          	jalr	104(ra) # 800019f0 <myproc>
    80006990:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006992:	0d850793          	addi	a5,a0,216
    80006996:	4501                	li	a0,0
    80006998:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000699a:	6398                	ld	a4,0(a5)
    8000699c:	cb19                	beqz	a4,800069b2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000699e:	2505                	addiw	a0,a0,1
    800069a0:	07a1                	addi	a5,a5,8
    800069a2:	fed51ce3          	bne	a0,a3,8000699a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800069a6:	557d                	li	a0,-1
}
    800069a8:	60e2                	ld	ra,24(sp)
    800069aa:	6442                	ld	s0,16(sp)
    800069ac:	64a2                	ld	s1,8(sp)
    800069ae:	6105                	addi	sp,sp,32
    800069b0:	8082                	ret
      p->ofile[fd] = f;
    800069b2:	01a50793          	addi	a5,a0,26
    800069b6:	078e                	slli	a5,a5,0x3
    800069b8:	963e                	add	a2,a2,a5
    800069ba:	e604                	sd	s1,8(a2)
      return fd;
    800069bc:	b7f5                	j	800069a8 <fdalloc+0x2c>

00000000800069be <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800069be:	715d                	addi	sp,sp,-80
    800069c0:	e486                	sd	ra,72(sp)
    800069c2:	e0a2                	sd	s0,64(sp)
    800069c4:	fc26                	sd	s1,56(sp)
    800069c6:	f84a                	sd	s2,48(sp)
    800069c8:	f44e                	sd	s3,40(sp)
    800069ca:	f052                	sd	s4,32(sp)
    800069cc:	ec56                	sd	s5,24(sp)
    800069ce:	0880                	addi	s0,sp,80
    800069d0:	89ae                	mv	s3,a1
    800069d2:	8ab2                	mv	s5,a2
    800069d4:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800069d6:	fb040593          	addi	a1,s0,-80
    800069da:	fffff097          	auipc	ra,0xfffff
    800069de:	e74080e7          	jalr	-396(ra) # 8000584e <nameiparent>
    800069e2:	892a                	mv	s2,a0
    800069e4:	12050e63          	beqz	a0,80006b20 <create+0x162>
    return 0;

  ilock(dp);
    800069e8:	ffffe097          	auipc	ra,0xffffe
    800069ec:	68c080e7          	jalr	1676(ra) # 80005074 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800069f0:	4601                	li	a2,0
    800069f2:	fb040593          	addi	a1,s0,-80
    800069f6:	854a                	mv	a0,s2
    800069f8:	fffff097          	auipc	ra,0xfffff
    800069fc:	b60080e7          	jalr	-1184(ra) # 80005558 <dirlookup>
    80006a00:	84aa                	mv	s1,a0
    80006a02:	c921                	beqz	a0,80006a52 <create+0x94>
    iunlockput(dp);
    80006a04:	854a                	mv	a0,s2
    80006a06:	fffff097          	auipc	ra,0xfffff
    80006a0a:	8d0080e7          	jalr	-1840(ra) # 800052d6 <iunlockput>
    ilock(ip);
    80006a0e:	8526                	mv	a0,s1
    80006a10:	ffffe097          	auipc	ra,0xffffe
    80006a14:	664080e7          	jalr	1636(ra) # 80005074 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006a18:	2981                	sext.w	s3,s3
    80006a1a:	4789                	li	a5,2
    80006a1c:	02f99463          	bne	s3,a5,80006a44 <create+0x86>
    80006a20:	0444d783          	lhu	a5,68(s1)
    80006a24:	37f9                	addiw	a5,a5,-2
    80006a26:	17c2                	slli	a5,a5,0x30
    80006a28:	93c1                	srli	a5,a5,0x30
    80006a2a:	4705                	li	a4,1
    80006a2c:	00f76c63          	bltu	a4,a5,80006a44 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006a30:	8526                	mv	a0,s1
    80006a32:	60a6                	ld	ra,72(sp)
    80006a34:	6406                	ld	s0,64(sp)
    80006a36:	74e2                	ld	s1,56(sp)
    80006a38:	7942                	ld	s2,48(sp)
    80006a3a:	79a2                	ld	s3,40(sp)
    80006a3c:	7a02                	ld	s4,32(sp)
    80006a3e:	6ae2                	ld	s5,24(sp)
    80006a40:	6161                	addi	sp,sp,80
    80006a42:	8082                	ret
    iunlockput(ip);
    80006a44:	8526                	mv	a0,s1
    80006a46:	fffff097          	auipc	ra,0xfffff
    80006a4a:	890080e7          	jalr	-1904(ra) # 800052d6 <iunlockput>
    return 0;
    80006a4e:	4481                	li	s1,0
    80006a50:	b7c5                	j	80006a30 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006a52:	85ce                	mv	a1,s3
    80006a54:	00092503          	lw	a0,0(s2)
    80006a58:	ffffe097          	auipc	ra,0xffffe
    80006a5c:	482080e7          	jalr	1154(ra) # 80004eda <ialloc>
    80006a60:	84aa                	mv	s1,a0
    80006a62:	c521                	beqz	a0,80006aaa <create+0xec>
  ilock(ip);
    80006a64:	ffffe097          	auipc	ra,0xffffe
    80006a68:	610080e7          	jalr	1552(ra) # 80005074 <ilock>
  ip->major = major;
    80006a6c:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006a70:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006a74:	4a05                	li	s4,1
    80006a76:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006a7a:	8526                	mv	a0,s1
    80006a7c:	ffffe097          	auipc	ra,0xffffe
    80006a80:	52c080e7          	jalr	1324(ra) # 80004fa8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006a84:	2981                	sext.w	s3,s3
    80006a86:	03498a63          	beq	s3,s4,80006aba <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006a8a:	40d0                	lw	a2,4(s1)
    80006a8c:	fb040593          	addi	a1,s0,-80
    80006a90:	854a                	mv	a0,s2
    80006a92:	fffff097          	auipc	ra,0xfffff
    80006a96:	cdc080e7          	jalr	-804(ra) # 8000576e <dirlink>
    80006a9a:	06054b63          	bltz	a0,80006b10 <create+0x152>
  iunlockput(dp);
    80006a9e:	854a                	mv	a0,s2
    80006aa0:	fffff097          	auipc	ra,0xfffff
    80006aa4:	836080e7          	jalr	-1994(ra) # 800052d6 <iunlockput>
  return ip;
    80006aa8:	b761                	j	80006a30 <create+0x72>
    panic("create: ialloc");
    80006aaa:	00003517          	auipc	a0,0x3
    80006aae:	fb650513          	addi	a0,a0,-74 # 80009a60 <syscalls+0x400>
    80006ab2:	ffffa097          	auipc	ra,0xffffa
    80006ab6:	a86080e7          	jalr	-1402(ra) # 80000538 <panic>
    dp->nlink++;  // for ".."
    80006aba:	04a95783          	lhu	a5,74(s2)
    80006abe:	2785                	addiw	a5,a5,1
    80006ac0:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006ac4:	854a                	mv	a0,s2
    80006ac6:	ffffe097          	auipc	ra,0xffffe
    80006aca:	4e2080e7          	jalr	1250(ra) # 80004fa8 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006ace:	40d0                	lw	a2,4(s1)
    80006ad0:	00003597          	auipc	a1,0x3
    80006ad4:	fa058593          	addi	a1,a1,-96 # 80009a70 <syscalls+0x410>
    80006ad8:	8526                	mv	a0,s1
    80006ada:	fffff097          	auipc	ra,0xfffff
    80006ade:	c94080e7          	jalr	-876(ra) # 8000576e <dirlink>
    80006ae2:	00054f63          	bltz	a0,80006b00 <create+0x142>
    80006ae6:	00492603          	lw	a2,4(s2)
    80006aea:	00003597          	auipc	a1,0x3
    80006aee:	f8e58593          	addi	a1,a1,-114 # 80009a78 <syscalls+0x418>
    80006af2:	8526                	mv	a0,s1
    80006af4:	fffff097          	auipc	ra,0xfffff
    80006af8:	c7a080e7          	jalr	-902(ra) # 8000576e <dirlink>
    80006afc:	f80557e3          	bgez	a0,80006a8a <create+0xcc>
      panic("create dots");
    80006b00:	00003517          	auipc	a0,0x3
    80006b04:	f8050513          	addi	a0,a0,-128 # 80009a80 <syscalls+0x420>
    80006b08:	ffffa097          	auipc	ra,0xffffa
    80006b0c:	a30080e7          	jalr	-1488(ra) # 80000538 <panic>
    panic("create: dirlink");
    80006b10:	00003517          	auipc	a0,0x3
    80006b14:	f8050513          	addi	a0,a0,-128 # 80009a90 <syscalls+0x430>
    80006b18:	ffffa097          	auipc	ra,0xffffa
    80006b1c:	a20080e7          	jalr	-1504(ra) # 80000538 <panic>
    return 0;
    80006b20:	84aa                	mv	s1,a0
    80006b22:	b739                	j	80006a30 <create+0x72>

0000000080006b24 <sys_dup>:
{
    80006b24:	7179                	addi	sp,sp,-48
    80006b26:	f406                	sd	ra,40(sp)
    80006b28:	f022                	sd	s0,32(sp)
    80006b2a:	ec26                	sd	s1,24(sp)
    80006b2c:	e84a                	sd	s2,16(sp)
    80006b2e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006b30:	fd840613          	addi	a2,s0,-40
    80006b34:	4581                	li	a1,0
    80006b36:	4501                	li	a0,0
    80006b38:	00000097          	auipc	ra,0x0
    80006b3c:	ddc080e7          	jalr	-548(ra) # 80006914 <argfd>
    return -1;
    80006b40:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006b42:	02054363          	bltz	a0,80006b68 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80006b46:	fd843903          	ld	s2,-40(s0)
    80006b4a:	854a                	mv	a0,s2
    80006b4c:	00000097          	auipc	ra,0x0
    80006b50:	e30080e7          	jalr	-464(ra) # 8000697c <fdalloc>
    80006b54:	84aa                	mv	s1,a0
    return -1;
    80006b56:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006b58:	00054863          	bltz	a0,80006b68 <sys_dup+0x44>
  filedup(f);
    80006b5c:	854a                	mv	a0,s2
    80006b5e:	fffff097          	auipc	ra,0xfffff
    80006b62:	368080e7          	jalr	872(ra) # 80005ec6 <filedup>
  return fd;
    80006b66:	87a6                	mv	a5,s1
}
    80006b68:	853e                	mv	a0,a5
    80006b6a:	70a2                	ld	ra,40(sp)
    80006b6c:	7402                	ld	s0,32(sp)
    80006b6e:	64e2                	ld	s1,24(sp)
    80006b70:	6942                	ld	s2,16(sp)
    80006b72:	6145                	addi	sp,sp,48
    80006b74:	8082                	ret

0000000080006b76 <sys_read>:
{
    80006b76:	7179                	addi	sp,sp,-48
    80006b78:	f406                	sd	ra,40(sp)
    80006b7a:	f022                	sd	s0,32(sp)
    80006b7c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006b7e:	fe840613          	addi	a2,s0,-24
    80006b82:	4581                	li	a1,0
    80006b84:	4501                	li	a0,0
    80006b86:	00000097          	auipc	ra,0x0
    80006b8a:	d8e080e7          	jalr	-626(ra) # 80006914 <argfd>
    return -1;
    80006b8e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006b90:	04054163          	bltz	a0,80006bd2 <sys_read+0x5c>
    80006b94:	fe440593          	addi	a1,s0,-28
    80006b98:	4509                	li	a0,2
    80006b9a:	ffffd097          	auipc	ra,0xffffd
    80006b9e:	20c080e7          	jalr	524(ra) # 80003da6 <argint>
    return -1;
    80006ba2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006ba4:	02054763          	bltz	a0,80006bd2 <sys_read+0x5c>
    80006ba8:	fd840593          	addi	a1,s0,-40
    80006bac:	4505                	li	a0,1
    80006bae:	ffffd097          	auipc	ra,0xffffd
    80006bb2:	21a080e7          	jalr	538(ra) # 80003dc8 <argaddr>
    return -1;
    80006bb6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006bb8:	00054d63          	bltz	a0,80006bd2 <sys_read+0x5c>
  return fileread(f, p, n);
    80006bbc:	fe442603          	lw	a2,-28(s0)
    80006bc0:	fd843583          	ld	a1,-40(s0)
    80006bc4:	fe843503          	ld	a0,-24(s0)
    80006bc8:	fffff097          	auipc	ra,0xfffff
    80006bcc:	48a080e7          	jalr	1162(ra) # 80006052 <fileread>
    80006bd0:	87aa                	mv	a5,a0
}
    80006bd2:	853e                	mv	a0,a5
    80006bd4:	70a2                	ld	ra,40(sp)
    80006bd6:	7402                	ld	s0,32(sp)
    80006bd8:	6145                	addi	sp,sp,48
    80006bda:	8082                	ret

0000000080006bdc <sys_write>:
{
    80006bdc:	7179                	addi	sp,sp,-48
    80006bde:	f406                	sd	ra,40(sp)
    80006be0:	f022                	sd	s0,32(sp)
    80006be2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006be4:	fe840613          	addi	a2,s0,-24
    80006be8:	4581                	li	a1,0
    80006bea:	4501                	li	a0,0
    80006bec:	00000097          	auipc	ra,0x0
    80006bf0:	d28080e7          	jalr	-728(ra) # 80006914 <argfd>
    return -1;
    80006bf4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006bf6:	04054163          	bltz	a0,80006c38 <sys_write+0x5c>
    80006bfa:	fe440593          	addi	a1,s0,-28
    80006bfe:	4509                	li	a0,2
    80006c00:	ffffd097          	auipc	ra,0xffffd
    80006c04:	1a6080e7          	jalr	422(ra) # 80003da6 <argint>
    return -1;
    80006c08:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006c0a:	02054763          	bltz	a0,80006c38 <sys_write+0x5c>
    80006c0e:	fd840593          	addi	a1,s0,-40
    80006c12:	4505                	li	a0,1
    80006c14:	ffffd097          	auipc	ra,0xffffd
    80006c18:	1b4080e7          	jalr	436(ra) # 80003dc8 <argaddr>
    return -1;
    80006c1c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006c1e:	00054d63          	bltz	a0,80006c38 <sys_write+0x5c>
  return filewrite(f, p, n);
    80006c22:	fe442603          	lw	a2,-28(s0)
    80006c26:	fd843583          	ld	a1,-40(s0)
    80006c2a:	fe843503          	ld	a0,-24(s0)
    80006c2e:	fffff097          	auipc	ra,0xfffff
    80006c32:	4e6080e7          	jalr	1254(ra) # 80006114 <filewrite>
    80006c36:	87aa                	mv	a5,a0
}
    80006c38:	853e                	mv	a0,a5
    80006c3a:	70a2                	ld	ra,40(sp)
    80006c3c:	7402                	ld	s0,32(sp)
    80006c3e:	6145                	addi	sp,sp,48
    80006c40:	8082                	ret

0000000080006c42 <sys_close>:
{
    80006c42:	1101                	addi	sp,sp,-32
    80006c44:	ec06                	sd	ra,24(sp)
    80006c46:	e822                	sd	s0,16(sp)
    80006c48:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80006c4a:	fe040613          	addi	a2,s0,-32
    80006c4e:	fec40593          	addi	a1,s0,-20
    80006c52:	4501                	li	a0,0
    80006c54:	00000097          	auipc	ra,0x0
    80006c58:	cc0080e7          	jalr	-832(ra) # 80006914 <argfd>
    return -1;
    80006c5c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006c5e:	02054463          	bltz	a0,80006c86 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006c62:	ffffb097          	auipc	ra,0xffffb
    80006c66:	d8e080e7          	jalr	-626(ra) # 800019f0 <myproc>
    80006c6a:	fec42783          	lw	a5,-20(s0)
    80006c6e:	07e9                	addi	a5,a5,26
    80006c70:	078e                	slli	a5,a5,0x3
    80006c72:	953e                	add	a0,a0,a5
    80006c74:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80006c78:	fe043503          	ld	a0,-32(s0)
    80006c7c:	fffff097          	auipc	ra,0xfffff
    80006c80:	29c080e7          	jalr	668(ra) # 80005f18 <fileclose>
  return 0;
    80006c84:	4781                	li	a5,0
}
    80006c86:	853e                	mv	a0,a5
    80006c88:	60e2                	ld	ra,24(sp)
    80006c8a:	6442                	ld	s0,16(sp)
    80006c8c:	6105                	addi	sp,sp,32
    80006c8e:	8082                	ret

0000000080006c90 <sys_fstat>:
{
    80006c90:	1101                	addi	sp,sp,-32
    80006c92:	ec06                	sd	ra,24(sp)
    80006c94:	e822                	sd	s0,16(sp)
    80006c96:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006c98:	fe840613          	addi	a2,s0,-24
    80006c9c:	4581                	li	a1,0
    80006c9e:	4501                	li	a0,0
    80006ca0:	00000097          	auipc	ra,0x0
    80006ca4:	c74080e7          	jalr	-908(ra) # 80006914 <argfd>
    return -1;
    80006ca8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006caa:	02054563          	bltz	a0,80006cd4 <sys_fstat+0x44>
    80006cae:	fe040593          	addi	a1,s0,-32
    80006cb2:	4505                	li	a0,1
    80006cb4:	ffffd097          	auipc	ra,0xffffd
    80006cb8:	114080e7          	jalr	276(ra) # 80003dc8 <argaddr>
    return -1;
    80006cbc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006cbe:	00054b63          	bltz	a0,80006cd4 <sys_fstat+0x44>
  return filestat(f, st);
    80006cc2:	fe043583          	ld	a1,-32(s0)
    80006cc6:	fe843503          	ld	a0,-24(s0)
    80006cca:	fffff097          	auipc	ra,0xfffff
    80006cce:	316080e7          	jalr	790(ra) # 80005fe0 <filestat>
    80006cd2:	87aa                	mv	a5,a0
}
    80006cd4:	853e                	mv	a0,a5
    80006cd6:	60e2                	ld	ra,24(sp)
    80006cd8:	6442                	ld	s0,16(sp)
    80006cda:	6105                	addi	sp,sp,32
    80006cdc:	8082                	ret

0000000080006cde <sys_link>:
{
    80006cde:	7169                	addi	sp,sp,-304
    80006ce0:	f606                	sd	ra,296(sp)
    80006ce2:	f222                	sd	s0,288(sp)
    80006ce4:	ee26                	sd	s1,280(sp)
    80006ce6:	ea4a                	sd	s2,272(sp)
    80006ce8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006cea:	08000613          	li	a2,128
    80006cee:	ed040593          	addi	a1,s0,-304
    80006cf2:	4501                	li	a0,0
    80006cf4:	ffffd097          	auipc	ra,0xffffd
    80006cf8:	0f6080e7          	jalr	246(ra) # 80003dea <argstr>
    return -1;
    80006cfc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006cfe:	10054e63          	bltz	a0,80006e1a <sys_link+0x13c>
    80006d02:	08000613          	li	a2,128
    80006d06:	f5040593          	addi	a1,s0,-176
    80006d0a:	4505                	li	a0,1
    80006d0c:	ffffd097          	auipc	ra,0xffffd
    80006d10:	0de080e7          	jalr	222(ra) # 80003dea <argstr>
    return -1;
    80006d14:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006d16:	10054263          	bltz	a0,80006e1a <sys_link+0x13c>
  begin_op();
    80006d1a:	fffff097          	auipc	ra,0xfffff
    80006d1e:	d36080e7          	jalr	-714(ra) # 80005a50 <begin_op>
  if((ip = namei(old)) == 0){
    80006d22:	ed040513          	addi	a0,s0,-304
    80006d26:	fffff097          	auipc	ra,0xfffff
    80006d2a:	b0a080e7          	jalr	-1270(ra) # 80005830 <namei>
    80006d2e:	84aa                	mv	s1,a0
    80006d30:	c551                	beqz	a0,80006dbc <sys_link+0xde>
  ilock(ip);
    80006d32:	ffffe097          	auipc	ra,0xffffe
    80006d36:	342080e7          	jalr	834(ra) # 80005074 <ilock>
  if(ip->type == T_DIR){
    80006d3a:	04449703          	lh	a4,68(s1)
    80006d3e:	4785                	li	a5,1
    80006d40:	08f70463          	beq	a4,a5,80006dc8 <sys_link+0xea>
  ip->nlink++;
    80006d44:	04a4d783          	lhu	a5,74(s1)
    80006d48:	2785                	addiw	a5,a5,1
    80006d4a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006d4e:	8526                	mv	a0,s1
    80006d50:	ffffe097          	auipc	ra,0xffffe
    80006d54:	258080e7          	jalr	600(ra) # 80004fa8 <iupdate>
  iunlock(ip);
    80006d58:	8526                	mv	a0,s1
    80006d5a:	ffffe097          	auipc	ra,0xffffe
    80006d5e:	3dc080e7          	jalr	988(ra) # 80005136 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006d62:	fd040593          	addi	a1,s0,-48
    80006d66:	f5040513          	addi	a0,s0,-176
    80006d6a:	fffff097          	auipc	ra,0xfffff
    80006d6e:	ae4080e7          	jalr	-1308(ra) # 8000584e <nameiparent>
    80006d72:	892a                	mv	s2,a0
    80006d74:	c935                	beqz	a0,80006de8 <sys_link+0x10a>
  ilock(dp);
    80006d76:	ffffe097          	auipc	ra,0xffffe
    80006d7a:	2fe080e7          	jalr	766(ra) # 80005074 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006d7e:	00092703          	lw	a4,0(s2)
    80006d82:	409c                	lw	a5,0(s1)
    80006d84:	04f71d63          	bne	a4,a5,80006dde <sys_link+0x100>
    80006d88:	40d0                	lw	a2,4(s1)
    80006d8a:	fd040593          	addi	a1,s0,-48
    80006d8e:	854a                	mv	a0,s2
    80006d90:	fffff097          	auipc	ra,0xfffff
    80006d94:	9de080e7          	jalr	-1570(ra) # 8000576e <dirlink>
    80006d98:	04054363          	bltz	a0,80006dde <sys_link+0x100>
  iunlockput(dp);
    80006d9c:	854a                	mv	a0,s2
    80006d9e:	ffffe097          	auipc	ra,0xffffe
    80006da2:	538080e7          	jalr	1336(ra) # 800052d6 <iunlockput>
  iput(ip);
    80006da6:	8526                	mv	a0,s1
    80006da8:	ffffe097          	auipc	ra,0xffffe
    80006dac:	486080e7          	jalr	1158(ra) # 8000522e <iput>
  end_op();
    80006db0:	fffff097          	auipc	ra,0xfffff
    80006db4:	d1e080e7          	jalr	-738(ra) # 80005ace <end_op>
  return 0;
    80006db8:	4781                	li	a5,0
    80006dba:	a085                	j	80006e1a <sys_link+0x13c>
    end_op();
    80006dbc:	fffff097          	auipc	ra,0xfffff
    80006dc0:	d12080e7          	jalr	-750(ra) # 80005ace <end_op>
    return -1;
    80006dc4:	57fd                	li	a5,-1
    80006dc6:	a891                	j	80006e1a <sys_link+0x13c>
    iunlockput(ip);
    80006dc8:	8526                	mv	a0,s1
    80006dca:	ffffe097          	auipc	ra,0xffffe
    80006dce:	50c080e7          	jalr	1292(ra) # 800052d6 <iunlockput>
    end_op();
    80006dd2:	fffff097          	auipc	ra,0xfffff
    80006dd6:	cfc080e7          	jalr	-772(ra) # 80005ace <end_op>
    return -1;
    80006dda:	57fd                	li	a5,-1
    80006ddc:	a83d                	j	80006e1a <sys_link+0x13c>
    iunlockput(dp);
    80006dde:	854a                	mv	a0,s2
    80006de0:	ffffe097          	auipc	ra,0xffffe
    80006de4:	4f6080e7          	jalr	1270(ra) # 800052d6 <iunlockput>
  ilock(ip);
    80006de8:	8526                	mv	a0,s1
    80006dea:	ffffe097          	auipc	ra,0xffffe
    80006dee:	28a080e7          	jalr	650(ra) # 80005074 <ilock>
  ip->nlink--;
    80006df2:	04a4d783          	lhu	a5,74(s1)
    80006df6:	37fd                	addiw	a5,a5,-1
    80006df8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006dfc:	8526                	mv	a0,s1
    80006dfe:	ffffe097          	auipc	ra,0xffffe
    80006e02:	1aa080e7          	jalr	426(ra) # 80004fa8 <iupdate>
  iunlockput(ip);
    80006e06:	8526                	mv	a0,s1
    80006e08:	ffffe097          	auipc	ra,0xffffe
    80006e0c:	4ce080e7          	jalr	1230(ra) # 800052d6 <iunlockput>
  end_op();
    80006e10:	fffff097          	auipc	ra,0xfffff
    80006e14:	cbe080e7          	jalr	-834(ra) # 80005ace <end_op>
  return -1;
    80006e18:	57fd                	li	a5,-1
}
    80006e1a:	853e                	mv	a0,a5
    80006e1c:	70b2                	ld	ra,296(sp)
    80006e1e:	7412                	ld	s0,288(sp)
    80006e20:	64f2                	ld	s1,280(sp)
    80006e22:	6952                	ld	s2,272(sp)
    80006e24:	6155                	addi	sp,sp,304
    80006e26:	8082                	ret

0000000080006e28 <sys_unlink>:
{
    80006e28:	7151                	addi	sp,sp,-240
    80006e2a:	f586                	sd	ra,232(sp)
    80006e2c:	f1a2                	sd	s0,224(sp)
    80006e2e:	eda6                	sd	s1,216(sp)
    80006e30:	e9ca                	sd	s2,208(sp)
    80006e32:	e5ce                	sd	s3,200(sp)
    80006e34:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006e36:	08000613          	li	a2,128
    80006e3a:	f3040593          	addi	a1,s0,-208
    80006e3e:	4501                	li	a0,0
    80006e40:	ffffd097          	auipc	ra,0xffffd
    80006e44:	faa080e7          	jalr	-86(ra) # 80003dea <argstr>
    80006e48:	18054163          	bltz	a0,80006fca <sys_unlink+0x1a2>
  begin_op();
    80006e4c:	fffff097          	auipc	ra,0xfffff
    80006e50:	c04080e7          	jalr	-1020(ra) # 80005a50 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006e54:	fb040593          	addi	a1,s0,-80
    80006e58:	f3040513          	addi	a0,s0,-208
    80006e5c:	fffff097          	auipc	ra,0xfffff
    80006e60:	9f2080e7          	jalr	-1550(ra) # 8000584e <nameiparent>
    80006e64:	84aa                	mv	s1,a0
    80006e66:	c979                	beqz	a0,80006f3c <sys_unlink+0x114>
  ilock(dp);
    80006e68:	ffffe097          	auipc	ra,0xffffe
    80006e6c:	20c080e7          	jalr	524(ra) # 80005074 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006e70:	00003597          	auipc	a1,0x3
    80006e74:	c0058593          	addi	a1,a1,-1024 # 80009a70 <syscalls+0x410>
    80006e78:	fb040513          	addi	a0,s0,-80
    80006e7c:	ffffe097          	auipc	ra,0xffffe
    80006e80:	6c2080e7          	jalr	1730(ra) # 8000553e <namecmp>
    80006e84:	14050a63          	beqz	a0,80006fd8 <sys_unlink+0x1b0>
    80006e88:	00003597          	auipc	a1,0x3
    80006e8c:	bf058593          	addi	a1,a1,-1040 # 80009a78 <syscalls+0x418>
    80006e90:	fb040513          	addi	a0,s0,-80
    80006e94:	ffffe097          	auipc	ra,0xffffe
    80006e98:	6aa080e7          	jalr	1706(ra) # 8000553e <namecmp>
    80006e9c:	12050e63          	beqz	a0,80006fd8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006ea0:	f2c40613          	addi	a2,s0,-212
    80006ea4:	fb040593          	addi	a1,s0,-80
    80006ea8:	8526                	mv	a0,s1
    80006eaa:	ffffe097          	auipc	ra,0xffffe
    80006eae:	6ae080e7          	jalr	1710(ra) # 80005558 <dirlookup>
    80006eb2:	892a                	mv	s2,a0
    80006eb4:	12050263          	beqz	a0,80006fd8 <sys_unlink+0x1b0>
  ilock(ip);
    80006eb8:	ffffe097          	auipc	ra,0xffffe
    80006ebc:	1bc080e7          	jalr	444(ra) # 80005074 <ilock>
  if(ip->nlink < 1)
    80006ec0:	04a91783          	lh	a5,74(s2)
    80006ec4:	08f05263          	blez	a5,80006f48 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006ec8:	04491703          	lh	a4,68(s2)
    80006ecc:	4785                	li	a5,1
    80006ece:	08f70563          	beq	a4,a5,80006f58 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006ed2:	4641                	li	a2,16
    80006ed4:	4581                	li	a1,0
    80006ed6:	fc040513          	addi	a0,s0,-64
    80006eda:	ffffa097          	auipc	ra,0xffffa
    80006ede:	df0080e7          	jalr	-528(ra) # 80000cca <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006ee2:	4741                	li	a4,16
    80006ee4:	f2c42683          	lw	a3,-212(s0)
    80006ee8:	fc040613          	addi	a2,s0,-64
    80006eec:	4581                	li	a1,0
    80006eee:	8526                	mv	a0,s1
    80006ef0:	ffffe097          	auipc	ra,0xffffe
    80006ef4:	530080e7          	jalr	1328(ra) # 80005420 <writei>
    80006ef8:	47c1                	li	a5,16
    80006efa:	0af51563          	bne	a0,a5,80006fa4 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006efe:	04491703          	lh	a4,68(s2)
    80006f02:	4785                	li	a5,1
    80006f04:	0af70863          	beq	a4,a5,80006fb4 <sys_unlink+0x18c>
  iunlockput(dp);
    80006f08:	8526                	mv	a0,s1
    80006f0a:	ffffe097          	auipc	ra,0xffffe
    80006f0e:	3cc080e7          	jalr	972(ra) # 800052d6 <iunlockput>
  ip->nlink--;
    80006f12:	04a95783          	lhu	a5,74(s2)
    80006f16:	37fd                	addiw	a5,a5,-1
    80006f18:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006f1c:	854a                	mv	a0,s2
    80006f1e:	ffffe097          	auipc	ra,0xffffe
    80006f22:	08a080e7          	jalr	138(ra) # 80004fa8 <iupdate>
  iunlockput(ip);
    80006f26:	854a                	mv	a0,s2
    80006f28:	ffffe097          	auipc	ra,0xffffe
    80006f2c:	3ae080e7          	jalr	942(ra) # 800052d6 <iunlockput>
  end_op();
    80006f30:	fffff097          	auipc	ra,0xfffff
    80006f34:	b9e080e7          	jalr	-1122(ra) # 80005ace <end_op>
  return 0;
    80006f38:	4501                	li	a0,0
    80006f3a:	a84d                	j	80006fec <sys_unlink+0x1c4>
    end_op();
    80006f3c:	fffff097          	auipc	ra,0xfffff
    80006f40:	b92080e7          	jalr	-1134(ra) # 80005ace <end_op>
    return -1;
    80006f44:	557d                	li	a0,-1
    80006f46:	a05d                	j	80006fec <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80006f48:	00003517          	auipc	a0,0x3
    80006f4c:	b5850513          	addi	a0,a0,-1192 # 80009aa0 <syscalls+0x440>
    80006f50:	ffff9097          	auipc	ra,0xffff9
    80006f54:	5e8080e7          	jalr	1512(ra) # 80000538 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006f58:	04c92703          	lw	a4,76(s2)
    80006f5c:	02000793          	li	a5,32
    80006f60:	f6e7f9e3          	bgeu	a5,a4,80006ed2 <sys_unlink+0xaa>
    80006f64:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006f68:	4741                	li	a4,16
    80006f6a:	86ce                	mv	a3,s3
    80006f6c:	f1840613          	addi	a2,s0,-232
    80006f70:	4581                	li	a1,0
    80006f72:	854a                	mv	a0,s2
    80006f74:	ffffe097          	auipc	ra,0xffffe
    80006f78:	3b4080e7          	jalr	948(ra) # 80005328 <readi>
    80006f7c:	47c1                	li	a5,16
    80006f7e:	00f51b63          	bne	a0,a5,80006f94 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006f82:	f1845783          	lhu	a5,-232(s0)
    80006f86:	e7a1                	bnez	a5,80006fce <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006f88:	29c1                	addiw	s3,s3,16
    80006f8a:	04c92783          	lw	a5,76(s2)
    80006f8e:	fcf9ede3          	bltu	s3,a5,80006f68 <sys_unlink+0x140>
    80006f92:	b781                	j	80006ed2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006f94:	00003517          	auipc	a0,0x3
    80006f98:	b2450513          	addi	a0,a0,-1244 # 80009ab8 <syscalls+0x458>
    80006f9c:	ffff9097          	auipc	ra,0xffff9
    80006fa0:	59c080e7          	jalr	1436(ra) # 80000538 <panic>
    panic("unlink: writei");
    80006fa4:	00003517          	auipc	a0,0x3
    80006fa8:	b2c50513          	addi	a0,a0,-1236 # 80009ad0 <syscalls+0x470>
    80006fac:	ffff9097          	auipc	ra,0xffff9
    80006fb0:	58c080e7          	jalr	1420(ra) # 80000538 <panic>
    dp->nlink--;
    80006fb4:	04a4d783          	lhu	a5,74(s1)
    80006fb8:	37fd                	addiw	a5,a5,-1
    80006fba:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006fbe:	8526                	mv	a0,s1
    80006fc0:	ffffe097          	auipc	ra,0xffffe
    80006fc4:	fe8080e7          	jalr	-24(ra) # 80004fa8 <iupdate>
    80006fc8:	b781                	j	80006f08 <sys_unlink+0xe0>
    return -1;
    80006fca:	557d                	li	a0,-1
    80006fcc:	a005                	j	80006fec <sys_unlink+0x1c4>
    iunlockput(ip);
    80006fce:	854a                	mv	a0,s2
    80006fd0:	ffffe097          	auipc	ra,0xffffe
    80006fd4:	306080e7          	jalr	774(ra) # 800052d6 <iunlockput>
  iunlockput(dp);
    80006fd8:	8526                	mv	a0,s1
    80006fda:	ffffe097          	auipc	ra,0xffffe
    80006fde:	2fc080e7          	jalr	764(ra) # 800052d6 <iunlockput>
  end_op();
    80006fe2:	fffff097          	auipc	ra,0xfffff
    80006fe6:	aec080e7          	jalr	-1300(ra) # 80005ace <end_op>
  return -1;
    80006fea:	557d                	li	a0,-1
}
    80006fec:	70ae                	ld	ra,232(sp)
    80006fee:	740e                	ld	s0,224(sp)
    80006ff0:	64ee                	ld	s1,216(sp)
    80006ff2:	694e                	ld	s2,208(sp)
    80006ff4:	69ae                	ld	s3,200(sp)
    80006ff6:	616d                	addi	sp,sp,240
    80006ff8:	8082                	ret

0000000080006ffa <sys_open>:

uint64
sys_open(void)
{
    80006ffa:	7131                	addi	sp,sp,-192
    80006ffc:	fd06                	sd	ra,184(sp)
    80006ffe:	f922                	sd	s0,176(sp)
    80007000:	f526                	sd	s1,168(sp)
    80007002:	f14a                	sd	s2,160(sp)
    80007004:	ed4e                	sd	s3,152(sp)
    80007006:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80007008:	08000613          	li	a2,128
    8000700c:	f5040593          	addi	a1,s0,-176
    80007010:	4501                	li	a0,0
    80007012:	ffffd097          	auipc	ra,0xffffd
    80007016:	dd8080e7          	jalr	-552(ra) # 80003dea <argstr>
    return -1;
    8000701a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000701c:	0c054163          	bltz	a0,800070de <sys_open+0xe4>
    80007020:	f4c40593          	addi	a1,s0,-180
    80007024:	4505                	li	a0,1
    80007026:	ffffd097          	auipc	ra,0xffffd
    8000702a:	d80080e7          	jalr	-640(ra) # 80003da6 <argint>
    8000702e:	0a054863          	bltz	a0,800070de <sys_open+0xe4>

  begin_op();
    80007032:	fffff097          	auipc	ra,0xfffff
    80007036:	a1e080e7          	jalr	-1506(ra) # 80005a50 <begin_op>

  if(omode & O_CREATE){
    8000703a:	f4c42783          	lw	a5,-180(s0)
    8000703e:	2007f793          	andi	a5,a5,512
    80007042:	cbdd                	beqz	a5,800070f8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80007044:	4681                	li	a3,0
    80007046:	4601                	li	a2,0
    80007048:	4589                	li	a1,2
    8000704a:	f5040513          	addi	a0,s0,-176
    8000704e:	00000097          	auipc	ra,0x0
    80007052:	970080e7          	jalr	-1680(ra) # 800069be <create>
    80007056:	892a                	mv	s2,a0
    if(ip == 0){
    80007058:	c959                	beqz	a0,800070ee <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000705a:	04491703          	lh	a4,68(s2)
    8000705e:	478d                	li	a5,3
    80007060:	00f71763          	bne	a4,a5,8000706e <sys_open+0x74>
    80007064:	04695703          	lhu	a4,70(s2)
    80007068:	47a5                	li	a5,9
    8000706a:	0ce7ec63          	bltu	a5,a4,80007142 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000706e:	fffff097          	auipc	ra,0xfffff
    80007072:	dee080e7          	jalr	-530(ra) # 80005e5c <filealloc>
    80007076:	89aa                	mv	s3,a0
    80007078:	10050263          	beqz	a0,8000717c <sys_open+0x182>
    8000707c:	00000097          	auipc	ra,0x0
    80007080:	900080e7          	jalr	-1792(ra) # 8000697c <fdalloc>
    80007084:	84aa                	mv	s1,a0
    80007086:	0e054663          	bltz	a0,80007172 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000708a:	04491703          	lh	a4,68(s2)
    8000708e:	478d                	li	a5,3
    80007090:	0cf70463          	beq	a4,a5,80007158 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80007094:	4789                	li	a5,2
    80007096:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000709a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000709e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800070a2:	f4c42783          	lw	a5,-180(s0)
    800070a6:	0017c713          	xori	a4,a5,1
    800070aa:	8b05                	andi	a4,a4,1
    800070ac:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800070b0:	0037f713          	andi	a4,a5,3
    800070b4:	00e03733          	snez	a4,a4
    800070b8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800070bc:	4007f793          	andi	a5,a5,1024
    800070c0:	c791                	beqz	a5,800070cc <sys_open+0xd2>
    800070c2:	04491703          	lh	a4,68(s2)
    800070c6:	4789                	li	a5,2
    800070c8:	08f70f63          	beq	a4,a5,80007166 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800070cc:	854a                	mv	a0,s2
    800070ce:	ffffe097          	auipc	ra,0xffffe
    800070d2:	068080e7          	jalr	104(ra) # 80005136 <iunlock>
  end_op();
    800070d6:	fffff097          	auipc	ra,0xfffff
    800070da:	9f8080e7          	jalr	-1544(ra) # 80005ace <end_op>

  return fd;
}
    800070de:	8526                	mv	a0,s1
    800070e0:	70ea                	ld	ra,184(sp)
    800070e2:	744a                	ld	s0,176(sp)
    800070e4:	74aa                	ld	s1,168(sp)
    800070e6:	790a                	ld	s2,160(sp)
    800070e8:	69ea                	ld	s3,152(sp)
    800070ea:	6129                	addi	sp,sp,192
    800070ec:	8082                	ret
      end_op();
    800070ee:	fffff097          	auipc	ra,0xfffff
    800070f2:	9e0080e7          	jalr	-1568(ra) # 80005ace <end_op>
      return -1;
    800070f6:	b7e5                	j	800070de <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800070f8:	f5040513          	addi	a0,s0,-176
    800070fc:	ffffe097          	auipc	ra,0xffffe
    80007100:	734080e7          	jalr	1844(ra) # 80005830 <namei>
    80007104:	892a                	mv	s2,a0
    80007106:	c905                	beqz	a0,80007136 <sys_open+0x13c>
    ilock(ip);
    80007108:	ffffe097          	auipc	ra,0xffffe
    8000710c:	f6c080e7          	jalr	-148(ra) # 80005074 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80007110:	04491703          	lh	a4,68(s2)
    80007114:	4785                	li	a5,1
    80007116:	f4f712e3          	bne	a4,a5,8000705a <sys_open+0x60>
    8000711a:	f4c42783          	lw	a5,-180(s0)
    8000711e:	dba1                	beqz	a5,8000706e <sys_open+0x74>
      iunlockput(ip);
    80007120:	854a                	mv	a0,s2
    80007122:	ffffe097          	auipc	ra,0xffffe
    80007126:	1b4080e7          	jalr	436(ra) # 800052d6 <iunlockput>
      end_op();
    8000712a:	fffff097          	auipc	ra,0xfffff
    8000712e:	9a4080e7          	jalr	-1628(ra) # 80005ace <end_op>
      return -1;
    80007132:	54fd                	li	s1,-1
    80007134:	b76d                	j	800070de <sys_open+0xe4>
      end_op();
    80007136:	fffff097          	auipc	ra,0xfffff
    8000713a:	998080e7          	jalr	-1640(ra) # 80005ace <end_op>
      return -1;
    8000713e:	54fd                	li	s1,-1
    80007140:	bf79                	j	800070de <sys_open+0xe4>
    iunlockput(ip);
    80007142:	854a                	mv	a0,s2
    80007144:	ffffe097          	auipc	ra,0xffffe
    80007148:	192080e7          	jalr	402(ra) # 800052d6 <iunlockput>
    end_op();
    8000714c:	fffff097          	auipc	ra,0xfffff
    80007150:	982080e7          	jalr	-1662(ra) # 80005ace <end_op>
    return -1;
    80007154:	54fd                	li	s1,-1
    80007156:	b761                	j	800070de <sys_open+0xe4>
    f->type = FD_DEVICE;
    80007158:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000715c:	04691783          	lh	a5,70(s2)
    80007160:	02f99223          	sh	a5,36(s3)
    80007164:	bf2d                	j	8000709e <sys_open+0xa4>
    itrunc(ip);
    80007166:	854a                	mv	a0,s2
    80007168:	ffffe097          	auipc	ra,0xffffe
    8000716c:	01a080e7          	jalr	26(ra) # 80005182 <itrunc>
    80007170:	bfb1                	j	800070cc <sys_open+0xd2>
      fileclose(f);
    80007172:	854e                	mv	a0,s3
    80007174:	fffff097          	auipc	ra,0xfffff
    80007178:	da4080e7          	jalr	-604(ra) # 80005f18 <fileclose>
    iunlockput(ip);
    8000717c:	854a                	mv	a0,s2
    8000717e:	ffffe097          	auipc	ra,0xffffe
    80007182:	158080e7          	jalr	344(ra) # 800052d6 <iunlockput>
    end_op();
    80007186:	fffff097          	auipc	ra,0xfffff
    8000718a:	948080e7          	jalr	-1720(ra) # 80005ace <end_op>
    return -1;
    8000718e:	54fd                	li	s1,-1
    80007190:	b7b9                	j	800070de <sys_open+0xe4>

0000000080007192 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80007192:	7175                	addi	sp,sp,-144
    80007194:	e506                	sd	ra,136(sp)
    80007196:	e122                	sd	s0,128(sp)
    80007198:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000719a:	fffff097          	auipc	ra,0xfffff
    8000719e:	8b6080e7          	jalr	-1866(ra) # 80005a50 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800071a2:	08000613          	li	a2,128
    800071a6:	f7040593          	addi	a1,s0,-144
    800071aa:	4501                	li	a0,0
    800071ac:	ffffd097          	auipc	ra,0xffffd
    800071b0:	c3e080e7          	jalr	-962(ra) # 80003dea <argstr>
    800071b4:	02054963          	bltz	a0,800071e6 <sys_mkdir+0x54>
    800071b8:	4681                	li	a3,0
    800071ba:	4601                	li	a2,0
    800071bc:	4585                	li	a1,1
    800071be:	f7040513          	addi	a0,s0,-144
    800071c2:	fffff097          	auipc	ra,0xfffff
    800071c6:	7fc080e7          	jalr	2044(ra) # 800069be <create>
    800071ca:	cd11                	beqz	a0,800071e6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800071cc:	ffffe097          	auipc	ra,0xffffe
    800071d0:	10a080e7          	jalr	266(ra) # 800052d6 <iunlockput>
  end_op();
    800071d4:	fffff097          	auipc	ra,0xfffff
    800071d8:	8fa080e7          	jalr	-1798(ra) # 80005ace <end_op>
  return 0;
    800071dc:	4501                	li	a0,0
}
    800071de:	60aa                	ld	ra,136(sp)
    800071e0:	640a                	ld	s0,128(sp)
    800071e2:	6149                	addi	sp,sp,144
    800071e4:	8082                	ret
    end_op();
    800071e6:	fffff097          	auipc	ra,0xfffff
    800071ea:	8e8080e7          	jalr	-1816(ra) # 80005ace <end_op>
    return -1;
    800071ee:	557d                	li	a0,-1
    800071f0:	b7fd                	j	800071de <sys_mkdir+0x4c>

00000000800071f2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800071f2:	7135                	addi	sp,sp,-160
    800071f4:	ed06                	sd	ra,152(sp)
    800071f6:	e922                	sd	s0,144(sp)
    800071f8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800071fa:	fffff097          	auipc	ra,0xfffff
    800071fe:	856080e7          	jalr	-1962(ra) # 80005a50 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80007202:	08000613          	li	a2,128
    80007206:	f7040593          	addi	a1,s0,-144
    8000720a:	4501                	li	a0,0
    8000720c:	ffffd097          	auipc	ra,0xffffd
    80007210:	bde080e7          	jalr	-1058(ra) # 80003dea <argstr>
    80007214:	04054a63          	bltz	a0,80007268 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80007218:	f6c40593          	addi	a1,s0,-148
    8000721c:	4505                	li	a0,1
    8000721e:	ffffd097          	auipc	ra,0xffffd
    80007222:	b88080e7          	jalr	-1144(ra) # 80003da6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80007226:	04054163          	bltz	a0,80007268 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000722a:	f6840593          	addi	a1,s0,-152
    8000722e:	4509                	li	a0,2
    80007230:	ffffd097          	auipc	ra,0xffffd
    80007234:	b76080e7          	jalr	-1162(ra) # 80003da6 <argint>
     argint(1, &major) < 0 ||
    80007238:	02054863          	bltz	a0,80007268 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000723c:	f6841683          	lh	a3,-152(s0)
    80007240:	f6c41603          	lh	a2,-148(s0)
    80007244:	458d                	li	a1,3
    80007246:	f7040513          	addi	a0,s0,-144
    8000724a:	fffff097          	auipc	ra,0xfffff
    8000724e:	774080e7          	jalr	1908(ra) # 800069be <create>
     argint(2, &minor) < 0 ||
    80007252:	c919                	beqz	a0,80007268 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80007254:	ffffe097          	auipc	ra,0xffffe
    80007258:	082080e7          	jalr	130(ra) # 800052d6 <iunlockput>
  end_op();
    8000725c:	fffff097          	auipc	ra,0xfffff
    80007260:	872080e7          	jalr	-1934(ra) # 80005ace <end_op>
  return 0;
    80007264:	4501                	li	a0,0
    80007266:	a031                	j	80007272 <sys_mknod+0x80>
    end_op();
    80007268:	fffff097          	auipc	ra,0xfffff
    8000726c:	866080e7          	jalr	-1946(ra) # 80005ace <end_op>
    return -1;
    80007270:	557d                	li	a0,-1
}
    80007272:	60ea                	ld	ra,152(sp)
    80007274:	644a                	ld	s0,144(sp)
    80007276:	610d                	addi	sp,sp,160
    80007278:	8082                	ret

000000008000727a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000727a:	7135                	addi	sp,sp,-160
    8000727c:	ed06                	sd	ra,152(sp)
    8000727e:	e922                	sd	s0,144(sp)
    80007280:	e526                	sd	s1,136(sp)
    80007282:	e14a                	sd	s2,128(sp)
    80007284:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80007286:	ffffa097          	auipc	ra,0xffffa
    8000728a:	76a080e7          	jalr	1898(ra) # 800019f0 <myproc>
    8000728e:	892a                	mv	s2,a0
  
  begin_op();
    80007290:	ffffe097          	auipc	ra,0xffffe
    80007294:	7c0080e7          	jalr	1984(ra) # 80005a50 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80007298:	08000613          	li	a2,128
    8000729c:	f6040593          	addi	a1,s0,-160
    800072a0:	4501                	li	a0,0
    800072a2:	ffffd097          	auipc	ra,0xffffd
    800072a6:	b48080e7          	jalr	-1208(ra) # 80003dea <argstr>
    800072aa:	04054b63          	bltz	a0,80007300 <sys_chdir+0x86>
    800072ae:	f6040513          	addi	a0,s0,-160
    800072b2:	ffffe097          	auipc	ra,0xffffe
    800072b6:	57e080e7          	jalr	1406(ra) # 80005830 <namei>
    800072ba:	84aa                	mv	s1,a0
    800072bc:	c131                	beqz	a0,80007300 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800072be:	ffffe097          	auipc	ra,0xffffe
    800072c2:	db6080e7          	jalr	-586(ra) # 80005074 <ilock>
  if(ip->type != T_DIR){
    800072c6:	04449703          	lh	a4,68(s1)
    800072ca:	4785                	li	a5,1
    800072cc:	04f71063          	bne	a4,a5,8000730c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800072d0:	8526                	mv	a0,s1
    800072d2:	ffffe097          	auipc	ra,0xffffe
    800072d6:	e64080e7          	jalr	-412(ra) # 80005136 <iunlock>
  iput(p->cwd);
    800072da:	15893503          	ld	a0,344(s2)
    800072de:	ffffe097          	auipc	ra,0xffffe
    800072e2:	f50080e7          	jalr	-176(ra) # 8000522e <iput>
  end_op();
    800072e6:	ffffe097          	auipc	ra,0xffffe
    800072ea:	7e8080e7          	jalr	2024(ra) # 80005ace <end_op>
  p->cwd = ip;
    800072ee:	14993c23          	sd	s1,344(s2)
  return 0;
    800072f2:	4501                	li	a0,0
}
    800072f4:	60ea                	ld	ra,152(sp)
    800072f6:	644a                	ld	s0,144(sp)
    800072f8:	64aa                	ld	s1,136(sp)
    800072fa:	690a                	ld	s2,128(sp)
    800072fc:	610d                	addi	sp,sp,160
    800072fe:	8082                	ret
    end_op();
    80007300:	ffffe097          	auipc	ra,0xffffe
    80007304:	7ce080e7          	jalr	1998(ra) # 80005ace <end_op>
    return -1;
    80007308:	557d                	li	a0,-1
    8000730a:	b7ed                	j	800072f4 <sys_chdir+0x7a>
    iunlockput(ip);
    8000730c:	8526                	mv	a0,s1
    8000730e:	ffffe097          	auipc	ra,0xffffe
    80007312:	fc8080e7          	jalr	-56(ra) # 800052d6 <iunlockput>
    end_op();
    80007316:	ffffe097          	auipc	ra,0xffffe
    8000731a:	7b8080e7          	jalr	1976(ra) # 80005ace <end_op>
    return -1;
    8000731e:	557d                	li	a0,-1
    80007320:	bfd1                	j	800072f4 <sys_chdir+0x7a>

0000000080007322 <sys_exec>:

uint64
sys_exec(void)
{
    80007322:	7145                	addi	sp,sp,-464
    80007324:	e786                	sd	ra,456(sp)
    80007326:	e3a2                	sd	s0,448(sp)
    80007328:	ff26                	sd	s1,440(sp)
    8000732a:	fb4a                	sd	s2,432(sp)
    8000732c:	f74e                	sd	s3,424(sp)
    8000732e:	f352                	sd	s4,416(sp)
    80007330:	ef56                	sd	s5,408(sp)
    80007332:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80007334:	08000613          	li	a2,128
    80007338:	f4040593          	addi	a1,s0,-192
    8000733c:	4501                	li	a0,0
    8000733e:	ffffd097          	auipc	ra,0xffffd
    80007342:	aac080e7          	jalr	-1364(ra) # 80003dea <argstr>
    return -1;
    80007346:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80007348:	0c054b63          	bltz	a0,8000741e <sys_exec+0xfc>
    8000734c:	e3840593          	addi	a1,s0,-456
    80007350:	4505                	li	a0,1
    80007352:	ffffd097          	auipc	ra,0xffffd
    80007356:	a76080e7          	jalr	-1418(ra) # 80003dc8 <argaddr>
    8000735a:	0c054263          	bltz	a0,8000741e <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    8000735e:	10000613          	li	a2,256
    80007362:	4581                	li	a1,0
    80007364:	e4040513          	addi	a0,s0,-448
    80007368:	ffffa097          	auipc	ra,0xffffa
    8000736c:	962080e7          	jalr	-1694(ra) # 80000cca <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80007370:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80007374:	89a6                	mv	s3,s1
    80007376:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80007378:	02000a13          	li	s4,32
    8000737c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80007380:	00391513          	slli	a0,s2,0x3
    80007384:	e3040593          	addi	a1,s0,-464
    80007388:	e3843783          	ld	a5,-456(s0)
    8000738c:	953e                	add	a0,a0,a5
    8000738e:	ffffd097          	auipc	ra,0xffffd
    80007392:	97e080e7          	jalr	-1666(ra) # 80003d0c <fetchaddr>
    80007396:	02054a63          	bltz	a0,800073ca <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000739a:	e3043783          	ld	a5,-464(s0)
    8000739e:	c3b9                	beqz	a5,800073e4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800073a0:	ffff9097          	auipc	ra,0xffff9
    800073a4:	73e080e7          	jalr	1854(ra) # 80000ade <kalloc>
    800073a8:	85aa                	mv	a1,a0
    800073aa:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800073ae:	cd11                	beqz	a0,800073ca <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800073b0:	6605                	lui	a2,0x1
    800073b2:	e3043503          	ld	a0,-464(s0)
    800073b6:	ffffd097          	auipc	ra,0xffffd
    800073ba:	9a8080e7          	jalr	-1624(ra) # 80003d5e <fetchstr>
    800073be:	00054663          	bltz	a0,800073ca <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800073c2:	0905                	addi	s2,s2,1
    800073c4:	09a1                	addi	s3,s3,8
    800073c6:	fb491be3          	bne	s2,s4,8000737c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800073ca:	f4040913          	addi	s2,s0,-192
    800073ce:	6088                	ld	a0,0(s1)
    800073d0:	c531                	beqz	a0,8000741c <sys_exec+0xfa>
    kfree(argv[i]);
    800073d2:	ffff9097          	auipc	ra,0xffff9
    800073d6:	60e080e7          	jalr	1550(ra) # 800009e0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800073da:	04a1                	addi	s1,s1,8
    800073dc:	ff2499e3          	bne	s1,s2,800073ce <sys_exec+0xac>
  return -1;
    800073e0:	597d                	li	s2,-1
    800073e2:	a835                	j	8000741e <sys_exec+0xfc>
      argv[i] = 0;
    800073e4:	0a8e                	slli	s5,s5,0x3
    800073e6:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd6fc0>
    800073ea:	00878ab3          	add	s5,a5,s0
    800073ee:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800073f2:	e4040593          	addi	a1,s0,-448
    800073f6:	f4040513          	addi	a0,s0,-192
    800073fa:	fffff097          	auipc	ra,0xfffff
    800073fe:	172080e7          	jalr	370(ra) # 8000656c <exec>
    80007402:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80007404:	f4040993          	addi	s3,s0,-192
    80007408:	6088                	ld	a0,0(s1)
    8000740a:	c911                	beqz	a0,8000741e <sys_exec+0xfc>
    kfree(argv[i]);
    8000740c:	ffff9097          	auipc	ra,0xffff9
    80007410:	5d4080e7          	jalr	1492(ra) # 800009e0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80007414:	04a1                	addi	s1,s1,8
    80007416:	ff3499e3          	bne	s1,s3,80007408 <sys_exec+0xe6>
    8000741a:	a011                	j	8000741e <sys_exec+0xfc>
  return -1;
    8000741c:	597d                	li	s2,-1
}
    8000741e:	854a                	mv	a0,s2
    80007420:	60be                	ld	ra,456(sp)
    80007422:	641e                	ld	s0,448(sp)
    80007424:	74fa                	ld	s1,440(sp)
    80007426:	795a                	ld	s2,432(sp)
    80007428:	79ba                	ld	s3,424(sp)
    8000742a:	7a1a                	ld	s4,416(sp)
    8000742c:	6afa                	ld	s5,408(sp)
    8000742e:	6179                	addi	sp,sp,464
    80007430:	8082                	ret

0000000080007432 <sys_pipe>:

uint64
sys_pipe(void)
{
    80007432:	7139                	addi	sp,sp,-64
    80007434:	fc06                	sd	ra,56(sp)
    80007436:	f822                	sd	s0,48(sp)
    80007438:	f426                	sd	s1,40(sp)
    8000743a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000743c:	ffffa097          	auipc	ra,0xffffa
    80007440:	5b4080e7          	jalr	1460(ra) # 800019f0 <myproc>
    80007444:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80007446:	fd840593          	addi	a1,s0,-40
    8000744a:	4501                	li	a0,0
    8000744c:	ffffd097          	auipc	ra,0xffffd
    80007450:	97c080e7          	jalr	-1668(ra) # 80003dc8 <argaddr>
    return -1;
    80007454:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80007456:	0e054063          	bltz	a0,80007536 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000745a:	fc840593          	addi	a1,s0,-56
    8000745e:	fd040513          	addi	a0,s0,-48
    80007462:	fffff097          	auipc	ra,0xfffff
    80007466:	de6080e7          	jalr	-538(ra) # 80006248 <pipealloc>
    return -1;
    8000746a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000746c:	0c054563          	bltz	a0,80007536 <sys_pipe+0x104>
  fd0 = -1;
    80007470:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80007474:	fd043503          	ld	a0,-48(s0)
    80007478:	fffff097          	auipc	ra,0xfffff
    8000747c:	504080e7          	jalr	1284(ra) # 8000697c <fdalloc>
    80007480:	fca42223          	sw	a0,-60(s0)
    80007484:	08054c63          	bltz	a0,8000751c <sys_pipe+0xea>
    80007488:	fc843503          	ld	a0,-56(s0)
    8000748c:	fffff097          	auipc	ra,0xfffff
    80007490:	4f0080e7          	jalr	1264(ra) # 8000697c <fdalloc>
    80007494:	fca42023          	sw	a0,-64(s0)
    80007498:	06054963          	bltz	a0,8000750a <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000749c:	4691                	li	a3,4
    8000749e:	fc440613          	addi	a2,s0,-60
    800074a2:	fd843583          	ld	a1,-40(s0)
    800074a6:	6ca8                	ld	a0,88(s1)
    800074a8:	ffffa097          	auipc	ra,0xffffa
    800074ac:	20c080e7          	jalr	524(ra) # 800016b4 <copyout>
    800074b0:	02054063          	bltz	a0,800074d0 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800074b4:	4691                	li	a3,4
    800074b6:	fc040613          	addi	a2,s0,-64
    800074ba:	fd843583          	ld	a1,-40(s0)
    800074be:	0591                	addi	a1,a1,4
    800074c0:	6ca8                	ld	a0,88(s1)
    800074c2:	ffffa097          	auipc	ra,0xffffa
    800074c6:	1f2080e7          	jalr	498(ra) # 800016b4 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800074ca:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800074cc:	06055563          	bgez	a0,80007536 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800074d0:	fc442783          	lw	a5,-60(s0)
    800074d4:	07e9                	addi	a5,a5,26
    800074d6:	078e                	slli	a5,a5,0x3
    800074d8:	97a6                	add	a5,a5,s1
    800074da:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800074de:	fc042783          	lw	a5,-64(s0)
    800074e2:	07e9                	addi	a5,a5,26
    800074e4:	078e                	slli	a5,a5,0x3
    800074e6:	00f48533          	add	a0,s1,a5
    800074ea:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800074ee:	fd043503          	ld	a0,-48(s0)
    800074f2:	fffff097          	auipc	ra,0xfffff
    800074f6:	a26080e7          	jalr	-1498(ra) # 80005f18 <fileclose>
    fileclose(wf);
    800074fa:	fc843503          	ld	a0,-56(s0)
    800074fe:	fffff097          	auipc	ra,0xfffff
    80007502:	a1a080e7          	jalr	-1510(ra) # 80005f18 <fileclose>
    return -1;
    80007506:	57fd                	li	a5,-1
    80007508:	a03d                	j	80007536 <sys_pipe+0x104>
    if(fd0 >= 0)
    8000750a:	fc442783          	lw	a5,-60(s0)
    8000750e:	0007c763          	bltz	a5,8000751c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80007512:	07e9                	addi	a5,a5,26
    80007514:	078e                	slli	a5,a5,0x3
    80007516:	97a6                	add	a5,a5,s1
    80007518:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    8000751c:	fd043503          	ld	a0,-48(s0)
    80007520:	fffff097          	auipc	ra,0xfffff
    80007524:	9f8080e7          	jalr	-1544(ra) # 80005f18 <fileclose>
    fileclose(wf);
    80007528:	fc843503          	ld	a0,-56(s0)
    8000752c:	fffff097          	auipc	ra,0xfffff
    80007530:	9ec080e7          	jalr	-1556(ra) # 80005f18 <fileclose>
    return -1;
    80007534:	57fd                	li	a5,-1
}
    80007536:	853e                	mv	a0,a5
    80007538:	70e2                	ld	ra,56(sp)
    8000753a:	7442                	ld	s0,48(sp)
    8000753c:	74a2                	ld	s1,40(sp)
    8000753e:	6121                	addi	sp,sp,64
    80007540:	8082                	ret
	...

0000000080007550 <kernelvec>:
    80007550:	7111                	addi	sp,sp,-256
    80007552:	e006                	sd	ra,0(sp)
    80007554:	e40a                	sd	sp,8(sp)
    80007556:	e80e                	sd	gp,16(sp)
    80007558:	ec12                	sd	tp,24(sp)
    8000755a:	f016                	sd	t0,32(sp)
    8000755c:	f41a                	sd	t1,40(sp)
    8000755e:	f81e                	sd	t2,48(sp)
    80007560:	fc22                	sd	s0,56(sp)
    80007562:	e0a6                	sd	s1,64(sp)
    80007564:	e4aa                	sd	a0,72(sp)
    80007566:	e8ae                	sd	a1,80(sp)
    80007568:	ecb2                	sd	a2,88(sp)
    8000756a:	f0b6                	sd	a3,96(sp)
    8000756c:	f4ba                	sd	a4,104(sp)
    8000756e:	f8be                	sd	a5,112(sp)
    80007570:	fcc2                	sd	a6,120(sp)
    80007572:	e146                	sd	a7,128(sp)
    80007574:	e54a                	sd	s2,136(sp)
    80007576:	e94e                	sd	s3,144(sp)
    80007578:	ed52                	sd	s4,152(sp)
    8000757a:	f156                	sd	s5,160(sp)
    8000757c:	f55a                	sd	s6,168(sp)
    8000757e:	f95e                	sd	s7,176(sp)
    80007580:	fd62                	sd	s8,184(sp)
    80007582:	e1e6                	sd	s9,192(sp)
    80007584:	e5ea                	sd	s10,200(sp)
    80007586:	e9ee                	sd	s11,208(sp)
    80007588:	edf2                	sd	t3,216(sp)
    8000758a:	f1f6                	sd	t4,224(sp)
    8000758c:	f5fa                	sd	t5,232(sp)
    8000758e:	f9fe                	sd	t6,240(sp)
    80007590:	e3afc0ef          	jal	ra,80003bca <kerneltrap>
    80007594:	6082                	ld	ra,0(sp)
    80007596:	6122                	ld	sp,8(sp)
    80007598:	61c2                	ld	gp,16(sp)
    8000759a:	7282                	ld	t0,32(sp)
    8000759c:	7322                	ld	t1,40(sp)
    8000759e:	73c2                	ld	t2,48(sp)
    800075a0:	7462                	ld	s0,56(sp)
    800075a2:	6486                	ld	s1,64(sp)
    800075a4:	6526                	ld	a0,72(sp)
    800075a6:	65c6                	ld	a1,80(sp)
    800075a8:	6666                	ld	a2,88(sp)
    800075aa:	7686                	ld	a3,96(sp)
    800075ac:	7726                	ld	a4,104(sp)
    800075ae:	77c6                	ld	a5,112(sp)
    800075b0:	7866                	ld	a6,120(sp)
    800075b2:	688a                	ld	a7,128(sp)
    800075b4:	692a                	ld	s2,136(sp)
    800075b6:	69ca                	ld	s3,144(sp)
    800075b8:	6a6a                	ld	s4,152(sp)
    800075ba:	7a8a                	ld	s5,160(sp)
    800075bc:	7b2a                	ld	s6,168(sp)
    800075be:	7bca                	ld	s7,176(sp)
    800075c0:	7c6a                	ld	s8,184(sp)
    800075c2:	6c8e                	ld	s9,192(sp)
    800075c4:	6d2e                	ld	s10,200(sp)
    800075c6:	6dce                	ld	s11,208(sp)
    800075c8:	6e6e                	ld	t3,216(sp)
    800075ca:	7e8e                	ld	t4,224(sp)
    800075cc:	7f2e                	ld	t5,232(sp)
    800075ce:	7fce                	ld	t6,240(sp)
    800075d0:	6111                	addi	sp,sp,256
    800075d2:	10200073          	sret
    800075d6:	00000013          	nop
    800075da:	00000013          	nop
    800075de:	0001                	nop

00000000800075e0 <timervec>:
    800075e0:	34051573          	csrrw	a0,mscratch,a0
    800075e4:	e10c                	sd	a1,0(a0)
    800075e6:	e510                	sd	a2,8(a0)
    800075e8:	e914                	sd	a3,16(a0)
    800075ea:	6d0c                	ld	a1,24(a0)
    800075ec:	7110                	ld	a2,32(a0)
    800075ee:	6194                	ld	a3,0(a1)
    800075f0:	96b2                	add	a3,a3,a2
    800075f2:	e194                	sd	a3,0(a1)
    800075f4:	4589                	li	a1,2
    800075f6:	14459073          	csrw	sip,a1
    800075fa:	6914                	ld	a3,16(a0)
    800075fc:	6510                	ld	a2,8(a0)
    800075fe:	610c                	ld	a1,0(a0)
    80007600:	34051573          	csrrw	a0,mscratch,a0
    80007604:	30200073          	mret
	...

000000008000760a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000760a:	1141                	addi	sp,sp,-16
    8000760c:	e422                	sd	s0,8(sp)
    8000760e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80007610:	0c0007b7          	lui	a5,0xc000
    80007614:	4705                	li	a4,1
    80007616:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80007618:	c3d8                	sw	a4,4(a5)
}
    8000761a:	6422                	ld	s0,8(sp)
    8000761c:	0141                	addi	sp,sp,16
    8000761e:	8082                	ret

0000000080007620 <plicinithart>:

void
plicinithart(void)
{
    80007620:	1141                	addi	sp,sp,-16
    80007622:	e406                	sd	ra,8(sp)
    80007624:	e022                	sd	s0,0(sp)
    80007626:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80007628:	ffffa097          	auipc	ra,0xffffa
    8000762c:	39c080e7          	jalr	924(ra) # 800019c4 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80007630:	0085171b          	slliw	a4,a0,0x8
    80007634:	0c0027b7          	lui	a5,0xc002
    80007638:	97ba                	add	a5,a5,a4
    8000763a:	40200713          	li	a4,1026
    8000763e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80007642:	00d5151b          	slliw	a0,a0,0xd
    80007646:	0c2017b7          	lui	a5,0xc201
    8000764a:	97aa                	add	a5,a5,a0
    8000764c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80007650:	60a2                	ld	ra,8(sp)
    80007652:	6402                	ld	s0,0(sp)
    80007654:	0141                	addi	sp,sp,16
    80007656:	8082                	ret

0000000080007658 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80007658:	1141                	addi	sp,sp,-16
    8000765a:	e406                	sd	ra,8(sp)
    8000765c:	e022                	sd	s0,0(sp)
    8000765e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80007660:	ffffa097          	auipc	ra,0xffffa
    80007664:	364080e7          	jalr	868(ra) # 800019c4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80007668:	00d5151b          	slliw	a0,a0,0xd
    8000766c:	0c2017b7          	lui	a5,0xc201
    80007670:	97aa                	add	a5,a5,a0
  return irq;
}
    80007672:	43c8                	lw	a0,4(a5)
    80007674:	60a2                	ld	ra,8(sp)
    80007676:	6402                	ld	s0,0(sp)
    80007678:	0141                	addi	sp,sp,16
    8000767a:	8082                	ret

000000008000767c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000767c:	1101                	addi	sp,sp,-32
    8000767e:	ec06                	sd	ra,24(sp)
    80007680:	e822                	sd	s0,16(sp)
    80007682:	e426                	sd	s1,8(sp)
    80007684:	1000                	addi	s0,sp,32
    80007686:	84aa                	mv	s1,a0
  int hart = cpuid();
    80007688:	ffffa097          	auipc	ra,0xffffa
    8000768c:	33c080e7          	jalr	828(ra) # 800019c4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80007690:	00d5151b          	slliw	a0,a0,0xd
    80007694:	0c2017b7          	lui	a5,0xc201
    80007698:	97aa                	add	a5,a5,a0
    8000769a:	c3c4                	sw	s1,4(a5)
}
    8000769c:	60e2                	ld	ra,24(sp)
    8000769e:	6442                	ld	s0,16(sp)
    800076a0:	64a2                	ld	s1,8(sp)
    800076a2:	6105                	addi	sp,sp,32
    800076a4:	8082                	ret

00000000800076a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800076a6:	1141                	addi	sp,sp,-16
    800076a8:	e406                	sd	ra,8(sp)
    800076aa:	e022                	sd	s0,0(sp)
    800076ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800076ae:	479d                	li	a5,7
    800076b0:	06a7c863          	blt	a5,a0,80007720 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    800076b4:	0001e717          	auipc	a4,0x1e
    800076b8:	94c70713          	addi	a4,a4,-1716 # 80025000 <disk>
    800076bc:	972a                	add	a4,a4,a0
    800076be:	6789                	lui	a5,0x2
    800076c0:	97ba                	add	a5,a5,a4
    800076c2:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800076c6:	e7ad                	bnez	a5,80007730 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800076c8:	00451793          	slli	a5,a0,0x4
    800076cc:	00020717          	auipc	a4,0x20
    800076d0:	93470713          	addi	a4,a4,-1740 # 80027000 <disk+0x2000>
    800076d4:	6314                	ld	a3,0(a4)
    800076d6:	96be                	add	a3,a3,a5
    800076d8:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800076dc:	6314                	ld	a3,0(a4)
    800076de:	96be                	add	a3,a3,a5
    800076e0:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800076e4:	6314                	ld	a3,0(a4)
    800076e6:	96be                	add	a3,a3,a5
    800076e8:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800076ec:	6318                	ld	a4,0(a4)
    800076ee:	97ba                	add	a5,a5,a4
    800076f0:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800076f4:	0001e717          	auipc	a4,0x1e
    800076f8:	90c70713          	addi	a4,a4,-1780 # 80025000 <disk>
    800076fc:	972a                	add	a4,a4,a0
    800076fe:	6789                	lui	a5,0x2
    80007700:	97ba                	add	a5,a5,a4
    80007702:	4705                	li	a4,1
    80007704:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80007708:	00020517          	auipc	a0,0x20
    8000770c:	91050513          	addi	a0,a0,-1776 # 80027018 <disk+0x2018>
    80007710:	ffffb097          	auipc	ra,0xffffb
    80007714:	644080e7          	jalr	1604(ra) # 80002d54 <wakeup>
}
    80007718:	60a2                	ld	ra,8(sp)
    8000771a:	6402                	ld	s0,0(sp)
    8000771c:	0141                	addi	sp,sp,16
    8000771e:	8082                	ret
    panic("free_desc 1");
    80007720:	00002517          	auipc	a0,0x2
    80007724:	3c050513          	addi	a0,a0,960 # 80009ae0 <syscalls+0x480>
    80007728:	ffff9097          	auipc	ra,0xffff9
    8000772c:	e10080e7          	jalr	-496(ra) # 80000538 <panic>
    panic("free_desc 2");
    80007730:	00002517          	auipc	a0,0x2
    80007734:	3c050513          	addi	a0,a0,960 # 80009af0 <syscalls+0x490>
    80007738:	ffff9097          	auipc	ra,0xffff9
    8000773c:	e00080e7          	jalr	-512(ra) # 80000538 <panic>

0000000080007740 <virtio_disk_init>:
{
    80007740:	1101                	addi	sp,sp,-32
    80007742:	ec06                	sd	ra,24(sp)
    80007744:	e822                	sd	s0,16(sp)
    80007746:	e426                	sd	s1,8(sp)
    80007748:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000774a:	00002597          	auipc	a1,0x2
    8000774e:	3b658593          	addi	a1,a1,950 # 80009b00 <syscalls+0x4a0>
    80007752:	00020517          	auipc	a0,0x20
    80007756:	9d650513          	addi	a0,a0,-1578 # 80027128 <disk+0x2128>
    8000775a:	ffff9097          	auipc	ra,0xffff9
    8000775e:	3e4080e7          	jalr	996(ra) # 80000b3e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80007762:	100017b7          	lui	a5,0x10001
    80007766:	4398                	lw	a4,0(a5)
    80007768:	2701                	sext.w	a4,a4
    8000776a:	747277b7          	lui	a5,0x74727
    8000776e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80007772:	0ef71063          	bne	a4,a5,80007852 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80007776:	100017b7          	lui	a5,0x10001
    8000777a:	43dc                	lw	a5,4(a5)
    8000777c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000777e:	4705                	li	a4,1
    80007780:	0ce79963          	bne	a5,a4,80007852 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80007784:	100017b7          	lui	a5,0x10001
    80007788:	479c                	lw	a5,8(a5)
    8000778a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000778c:	4709                	li	a4,2
    8000778e:	0ce79263          	bne	a5,a4,80007852 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80007792:	100017b7          	lui	a5,0x10001
    80007796:	47d8                	lw	a4,12(a5)
    80007798:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000779a:	554d47b7          	lui	a5,0x554d4
    8000779e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800077a2:	0af71863          	bne	a4,a5,80007852 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    800077a6:	100017b7          	lui	a5,0x10001
    800077aa:	4705                	li	a4,1
    800077ac:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800077ae:	470d                	li	a4,3
    800077b0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800077b2:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800077b4:	c7ffe6b7          	lui	a3,0xc7ffe
    800077b8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd675f>
    800077bc:	8f75                	and	a4,a4,a3
    800077be:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800077c0:	472d                	li	a4,11
    800077c2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800077c4:	473d                	li	a4,15
    800077c6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800077c8:	6705                	lui	a4,0x1
    800077ca:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800077cc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800077d0:	5bdc                	lw	a5,52(a5)
    800077d2:	2781                	sext.w	a5,a5
  if(max == 0)
    800077d4:	c7d9                	beqz	a5,80007862 <virtio_disk_init+0x122>
  if(max < NUM)
    800077d6:	471d                	li	a4,7
    800077d8:	08f77d63          	bgeu	a4,a5,80007872 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800077dc:	100014b7          	lui	s1,0x10001
    800077e0:	47a1                	li	a5,8
    800077e2:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800077e4:	6609                	lui	a2,0x2
    800077e6:	4581                	li	a1,0
    800077e8:	0001e517          	auipc	a0,0x1e
    800077ec:	81850513          	addi	a0,a0,-2024 # 80025000 <disk>
    800077f0:	ffff9097          	auipc	ra,0xffff9
    800077f4:	4da080e7          	jalr	1242(ra) # 80000cca <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800077f8:	0001e717          	auipc	a4,0x1e
    800077fc:	80870713          	addi	a4,a4,-2040 # 80025000 <disk>
    80007800:	00c75793          	srli	a5,a4,0xc
    80007804:	2781                	sext.w	a5,a5
    80007806:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80007808:	0001f797          	auipc	a5,0x1f
    8000780c:	7f878793          	addi	a5,a5,2040 # 80027000 <disk+0x2000>
    80007810:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007812:	0001e717          	auipc	a4,0x1e
    80007816:	86e70713          	addi	a4,a4,-1938 # 80025080 <disk+0x80>
    8000781a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000781c:	0001e717          	auipc	a4,0x1e
    80007820:	7e470713          	addi	a4,a4,2020 # 80026000 <disk+0x1000>
    80007824:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80007826:	4705                	li	a4,1
    80007828:	00e78c23          	sb	a4,24(a5)
    8000782c:	00e78ca3          	sb	a4,25(a5)
    80007830:	00e78d23          	sb	a4,26(a5)
    80007834:	00e78da3          	sb	a4,27(a5)
    80007838:	00e78e23          	sb	a4,28(a5)
    8000783c:	00e78ea3          	sb	a4,29(a5)
    80007840:	00e78f23          	sb	a4,30(a5)
    80007844:	00e78fa3          	sb	a4,31(a5)
}
    80007848:	60e2                	ld	ra,24(sp)
    8000784a:	6442                	ld	s0,16(sp)
    8000784c:	64a2                	ld	s1,8(sp)
    8000784e:	6105                	addi	sp,sp,32
    80007850:	8082                	ret
    panic("could not find virtio disk");
    80007852:	00002517          	auipc	a0,0x2
    80007856:	2be50513          	addi	a0,a0,702 # 80009b10 <syscalls+0x4b0>
    8000785a:	ffff9097          	auipc	ra,0xffff9
    8000785e:	cde080e7          	jalr	-802(ra) # 80000538 <panic>
    panic("virtio disk has no queue 0");
    80007862:	00002517          	auipc	a0,0x2
    80007866:	2ce50513          	addi	a0,a0,718 # 80009b30 <syscalls+0x4d0>
    8000786a:	ffff9097          	auipc	ra,0xffff9
    8000786e:	cce080e7          	jalr	-818(ra) # 80000538 <panic>
    panic("virtio disk max queue too short");
    80007872:	00002517          	auipc	a0,0x2
    80007876:	2de50513          	addi	a0,a0,734 # 80009b50 <syscalls+0x4f0>
    8000787a:	ffff9097          	auipc	ra,0xffff9
    8000787e:	cbe080e7          	jalr	-834(ra) # 80000538 <panic>

0000000080007882 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80007882:	7119                	addi	sp,sp,-128
    80007884:	fc86                	sd	ra,120(sp)
    80007886:	f8a2                	sd	s0,112(sp)
    80007888:	f4a6                	sd	s1,104(sp)
    8000788a:	f0ca                	sd	s2,96(sp)
    8000788c:	ecce                	sd	s3,88(sp)
    8000788e:	e8d2                	sd	s4,80(sp)
    80007890:	e4d6                	sd	s5,72(sp)
    80007892:	e0da                	sd	s6,64(sp)
    80007894:	fc5e                	sd	s7,56(sp)
    80007896:	f862                	sd	s8,48(sp)
    80007898:	f466                	sd	s9,40(sp)
    8000789a:	f06a                	sd	s10,32(sp)
    8000789c:	ec6e                	sd	s11,24(sp)
    8000789e:	0100                	addi	s0,sp,128
    800078a0:	8aaa                	mv	s5,a0
    800078a2:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800078a4:	00c52c83          	lw	s9,12(a0)
    800078a8:	001c9c9b          	slliw	s9,s9,0x1
    800078ac:	1c82                	slli	s9,s9,0x20
    800078ae:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800078b2:	00020517          	auipc	a0,0x20
    800078b6:	87650513          	addi	a0,a0,-1930 # 80027128 <disk+0x2128>
    800078ba:	ffff9097          	auipc	ra,0xffff9
    800078be:	314080e7          	jalr	788(ra) # 80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800078c2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800078c4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800078c6:	0001dc17          	auipc	s8,0x1d
    800078ca:	73ac0c13          	addi	s8,s8,1850 # 80025000 <disk>
    800078ce:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800078d0:	4b0d                	li	s6,3
    800078d2:	a0ad                	j	8000793c <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800078d4:	00fc0733          	add	a4,s8,a5
    800078d8:	975e                	add	a4,a4,s7
    800078da:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800078de:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800078e0:	0207c563          	bltz	a5,8000790a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800078e4:	2905                	addiw	s2,s2,1
    800078e6:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    800078e8:	19690c63          	beq	s2,s6,80007a80 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    800078ec:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800078ee:	0001f717          	auipc	a4,0x1f
    800078f2:	72a70713          	addi	a4,a4,1834 # 80027018 <disk+0x2018>
    800078f6:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800078f8:	00074683          	lbu	a3,0(a4)
    800078fc:	fee1                	bnez	a3,800078d4 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800078fe:	2785                	addiw	a5,a5,1
    80007900:	0705                	addi	a4,a4,1
    80007902:	fe979be3          	bne	a5,s1,800078f8 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80007906:	57fd                	li	a5,-1
    80007908:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000790a:	01205d63          	blez	s2,80007924 <virtio_disk_rw+0xa2>
    8000790e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007910:	000a2503          	lw	a0,0(s4)
    80007914:	00000097          	auipc	ra,0x0
    80007918:	d92080e7          	jalr	-622(ra) # 800076a6 <free_desc>
      for(int j = 0; j < i; j++)
    8000791c:	2d85                	addiw	s11,s11,1
    8000791e:	0a11                	addi	s4,s4,4
    80007920:	ff2d98e3          	bne	s11,s2,80007910 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007924:	00020597          	auipc	a1,0x20
    80007928:	80458593          	addi	a1,a1,-2044 # 80027128 <disk+0x2128>
    8000792c:	0001f517          	auipc	a0,0x1f
    80007930:	6ec50513          	addi	a0,a0,1772 # 80027018 <disk+0x2018>
    80007934:	ffffb097          	auipc	ra,0xffffb
    80007938:	e6e080e7          	jalr	-402(ra) # 800027a2 <sleep>
  for(int i = 0; i < 3; i++){
    8000793c:	f8040a13          	addi	s4,s0,-128
{
    80007940:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007942:	894e                	mv	s2,s3
    80007944:	b765                	j	800078ec <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80007946:	0001f697          	auipc	a3,0x1f
    8000794a:	6ba6b683          	ld	a3,1722(a3) # 80027000 <disk+0x2000>
    8000794e:	96ba                	add	a3,a3,a4
    80007950:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007954:	0001d817          	auipc	a6,0x1d
    80007958:	6ac80813          	addi	a6,a6,1708 # 80025000 <disk>
    8000795c:	0001f697          	auipc	a3,0x1f
    80007960:	6a468693          	addi	a3,a3,1700 # 80027000 <disk+0x2000>
    80007964:	6290                	ld	a2,0(a3)
    80007966:	963a                	add	a2,a2,a4
    80007968:	00c65583          	lhu	a1,12(a2)
    8000796c:	0015e593          	ori	a1,a1,1
    80007970:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007974:	f8842603          	lw	a2,-120(s0)
    80007978:	628c                	ld	a1,0(a3)
    8000797a:	972e                	add	a4,a4,a1
    8000797c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007980:	20050593          	addi	a1,a0,512
    80007984:	0592                	slli	a1,a1,0x4
    80007986:	95c2                	add	a1,a1,a6
    80007988:	577d                	li	a4,-1
    8000798a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000798e:	00461713          	slli	a4,a2,0x4
    80007992:	6290                	ld	a2,0(a3)
    80007994:	963a                	add	a2,a2,a4
    80007996:	03078793          	addi	a5,a5,48
    8000799a:	97c2                	add	a5,a5,a6
    8000799c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000799e:	629c                	ld	a5,0(a3)
    800079a0:	97ba                	add	a5,a5,a4
    800079a2:	4605                	li	a2,1
    800079a4:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800079a6:	629c                	ld	a5,0(a3)
    800079a8:	97ba                	add	a5,a5,a4
    800079aa:	4809                	li	a6,2
    800079ac:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800079b0:	629c                	ld	a5,0(a3)
    800079b2:	97ba                	add	a5,a5,a4
    800079b4:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800079b8:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800079bc:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800079c0:	6698                	ld	a4,8(a3)
    800079c2:	00275783          	lhu	a5,2(a4)
    800079c6:	8b9d                	andi	a5,a5,7
    800079c8:	0786                	slli	a5,a5,0x1
    800079ca:	973e                	add	a4,a4,a5
    800079cc:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    800079d0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800079d4:	6698                	ld	a4,8(a3)
    800079d6:	00275783          	lhu	a5,2(a4)
    800079da:	2785                	addiw	a5,a5,1
    800079dc:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800079e0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800079e4:	100017b7          	lui	a5,0x10001
    800079e8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800079ec:	004aa783          	lw	a5,4(s5)
    800079f0:	02c79163          	bne	a5,a2,80007a12 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800079f4:	0001f917          	auipc	s2,0x1f
    800079f8:	73490913          	addi	s2,s2,1844 # 80027128 <disk+0x2128>
  while(b->disk == 1) {
    800079fc:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800079fe:	85ca                	mv	a1,s2
    80007a00:	8556                	mv	a0,s5
    80007a02:	ffffb097          	auipc	ra,0xffffb
    80007a06:	da0080e7          	jalr	-608(ra) # 800027a2 <sleep>
  while(b->disk == 1) {
    80007a0a:	004aa783          	lw	a5,4(s5)
    80007a0e:	fe9788e3          	beq	a5,s1,800079fe <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007a12:	f8042903          	lw	s2,-128(s0)
    80007a16:	20090713          	addi	a4,s2,512
    80007a1a:	0712                	slli	a4,a4,0x4
    80007a1c:	0001d797          	auipc	a5,0x1d
    80007a20:	5e478793          	addi	a5,a5,1508 # 80025000 <disk>
    80007a24:	97ba                	add	a5,a5,a4
    80007a26:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007a2a:	0001f997          	auipc	s3,0x1f
    80007a2e:	5d698993          	addi	s3,s3,1494 # 80027000 <disk+0x2000>
    80007a32:	00491713          	slli	a4,s2,0x4
    80007a36:	0009b783          	ld	a5,0(s3)
    80007a3a:	97ba                	add	a5,a5,a4
    80007a3c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007a40:	854a                	mv	a0,s2
    80007a42:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80007a46:	00000097          	auipc	ra,0x0
    80007a4a:	c60080e7          	jalr	-928(ra) # 800076a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007a4e:	8885                	andi	s1,s1,1
    80007a50:	f0ed                	bnez	s1,80007a32 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007a52:	0001f517          	auipc	a0,0x1f
    80007a56:	6d650513          	addi	a0,a0,1750 # 80027128 <disk+0x2128>
    80007a5a:	ffff9097          	auipc	ra,0xffff9
    80007a5e:	228080e7          	jalr	552(ra) # 80000c82 <release>
}
    80007a62:	70e6                	ld	ra,120(sp)
    80007a64:	7446                	ld	s0,112(sp)
    80007a66:	74a6                	ld	s1,104(sp)
    80007a68:	7906                	ld	s2,96(sp)
    80007a6a:	69e6                	ld	s3,88(sp)
    80007a6c:	6a46                	ld	s4,80(sp)
    80007a6e:	6aa6                	ld	s5,72(sp)
    80007a70:	6b06                	ld	s6,64(sp)
    80007a72:	7be2                	ld	s7,56(sp)
    80007a74:	7c42                	ld	s8,48(sp)
    80007a76:	7ca2                	ld	s9,40(sp)
    80007a78:	7d02                	ld	s10,32(sp)
    80007a7a:	6de2                	ld	s11,24(sp)
    80007a7c:	6109                	addi	sp,sp,128
    80007a7e:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007a80:	f8042503          	lw	a0,-128(s0)
    80007a84:	20050793          	addi	a5,a0,512
    80007a88:	0792                	slli	a5,a5,0x4
  if(write)
    80007a8a:	0001d817          	auipc	a6,0x1d
    80007a8e:	57680813          	addi	a6,a6,1398 # 80025000 <disk>
    80007a92:	00f80733          	add	a4,a6,a5
    80007a96:	01a036b3          	snez	a3,s10
    80007a9a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007a9e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007aa2:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007aa6:	7679                	lui	a2,0xffffe
    80007aa8:	963e                	add	a2,a2,a5
    80007aaa:	0001f697          	auipc	a3,0x1f
    80007aae:	55668693          	addi	a3,a3,1366 # 80027000 <disk+0x2000>
    80007ab2:	6298                	ld	a4,0(a3)
    80007ab4:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007ab6:	0a878593          	addi	a1,a5,168
    80007aba:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007abc:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007abe:	6298                	ld	a4,0(a3)
    80007ac0:	9732                	add	a4,a4,a2
    80007ac2:	45c1                	li	a1,16
    80007ac4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80007ac6:	6298                	ld	a4,0(a3)
    80007ac8:	9732                	add	a4,a4,a2
    80007aca:	4585                	li	a1,1
    80007acc:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007ad0:	f8442703          	lw	a4,-124(s0)
    80007ad4:	628c                	ld	a1,0(a3)
    80007ad6:	962e                	add	a2,a2,a1
    80007ad8:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd600e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007adc:	0712                	slli	a4,a4,0x4
    80007ade:	6290                	ld	a2,0(a3)
    80007ae0:	963a                	add	a2,a2,a4
    80007ae2:	058a8593          	addi	a1,s5,88
    80007ae6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80007ae8:	6294                	ld	a3,0(a3)
    80007aea:	96ba                	add	a3,a3,a4
    80007aec:	40000613          	li	a2,1024
    80007af0:	c690                	sw	a2,8(a3)
  if(write)
    80007af2:	e40d1ae3          	bnez	s10,80007946 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80007af6:	0001f697          	auipc	a3,0x1f
    80007afa:	50a6b683          	ld	a3,1290(a3) # 80027000 <disk+0x2000>
    80007afe:	96ba                	add	a3,a3,a4
    80007b00:	4609                	li	a2,2
    80007b02:	00c69623          	sh	a2,12(a3)
    80007b06:	b5b9                	j	80007954 <virtio_disk_rw+0xd2>

0000000080007b08 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80007b08:	1101                	addi	sp,sp,-32
    80007b0a:	ec06                	sd	ra,24(sp)
    80007b0c:	e822                	sd	s0,16(sp)
    80007b0e:	e426                	sd	s1,8(sp)
    80007b10:	e04a                	sd	s2,0(sp)
    80007b12:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80007b14:	0001f517          	auipc	a0,0x1f
    80007b18:	61450513          	addi	a0,a0,1556 # 80027128 <disk+0x2128>
    80007b1c:	ffff9097          	auipc	ra,0xffff9
    80007b20:	0b2080e7          	jalr	178(ra) # 80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80007b24:	10001737          	lui	a4,0x10001
    80007b28:	533c                	lw	a5,96(a4)
    80007b2a:	8b8d                	andi	a5,a5,3
    80007b2c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007b2e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007b32:	0001f797          	auipc	a5,0x1f
    80007b36:	4ce78793          	addi	a5,a5,1230 # 80027000 <disk+0x2000>
    80007b3a:	6b94                	ld	a3,16(a5)
    80007b3c:	0207d703          	lhu	a4,32(a5)
    80007b40:	0026d783          	lhu	a5,2(a3)
    80007b44:	06f70163          	beq	a4,a5,80007ba6 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007b48:	0001d917          	auipc	s2,0x1d
    80007b4c:	4b890913          	addi	s2,s2,1208 # 80025000 <disk>
    80007b50:	0001f497          	auipc	s1,0x1f
    80007b54:	4b048493          	addi	s1,s1,1200 # 80027000 <disk+0x2000>
    __sync_synchronize();
    80007b58:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007b5c:	6898                	ld	a4,16(s1)
    80007b5e:	0204d783          	lhu	a5,32(s1)
    80007b62:	8b9d                	andi	a5,a5,7
    80007b64:	078e                	slli	a5,a5,0x3
    80007b66:	97ba                	add	a5,a5,a4
    80007b68:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007b6a:	20078713          	addi	a4,a5,512
    80007b6e:	0712                	slli	a4,a4,0x4
    80007b70:	974a                	add	a4,a4,s2
    80007b72:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80007b76:	e731                	bnez	a4,80007bc2 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80007b78:	20078793          	addi	a5,a5,512
    80007b7c:	0792                	slli	a5,a5,0x4
    80007b7e:	97ca                	add	a5,a5,s2
    80007b80:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007b82:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80007b86:	ffffb097          	auipc	ra,0xffffb
    80007b8a:	1ce080e7          	jalr	462(ra) # 80002d54 <wakeup>

    disk.used_idx += 1;
    80007b8e:	0204d783          	lhu	a5,32(s1)
    80007b92:	2785                	addiw	a5,a5,1
    80007b94:	17c2                	slli	a5,a5,0x30
    80007b96:	93c1                	srli	a5,a5,0x30
    80007b98:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007b9c:	6898                	ld	a4,16(s1)
    80007b9e:	00275703          	lhu	a4,2(a4)
    80007ba2:	faf71be3          	bne	a4,a5,80007b58 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80007ba6:	0001f517          	auipc	a0,0x1f
    80007baa:	58250513          	addi	a0,a0,1410 # 80027128 <disk+0x2128>
    80007bae:	ffff9097          	auipc	ra,0xffff9
    80007bb2:	0d4080e7          	jalr	212(ra) # 80000c82 <release>
}
    80007bb6:	60e2                	ld	ra,24(sp)
    80007bb8:	6442                	ld	s0,16(sp)
    80007bba:	64a2                	ld	s1,8(sp)
    80007bbc:	6902                	ld	s2,0(sp)
    80007bbe:	6105                	addi	sp,sp,32
    80007bc0:	8082                	ret
      panic("virtio_disk_intr status");
    80007bc2:	00002517          	auipc	a0,0x2
    80007bc6:	fae50513          	addi	a0,a0,-82 # 80009b70 <syscalls+0x510>
    80007bca:	ffff9097          	auipc	ra,0xffff9
    80007bce:	96e080e7          	jalr	-1682(ra) # 80000538 <panic>

0000000080007bd2 <cond_wait>:
#include "spinlock.h"
#include "condvar.h"
#include "riscv.h"
#include "defs.h"

void cond_wait (struct cond_t *cv, struct sleeplock *lock) {
    80007bd2:	1141                	addi	sp,sp,-16
    80007bd4:	e406                	sd	ra,8(sp)
    80007bd6:	e022                	sd	s0,0(sp)
    80007bd8:	0800                	addi	s0,sp,16
    condsleep(cv, lock);
    80007bda:	ffffb097          	auipc	ra,0xffffb
    80007bde:	fcc080e7          	jalr	-52(ra) # 80002ba6 <condsleep>
    return;
}
    80007be2:	60a2                	ld	ra,8(sp)
    80007be4:	6402                	ld	s0,0(sp)
    80007be6:	0141                	addi	sp,sp,16
    80007be8:	8082                	ret

0000000080007bea <cond_signal>:
void cond_signal (struct cond_t *cv) {
    80007bea:	1141                	addi	sp,sp,-16
    80007bec:	e406                	sd	ra,8(sp)
    80007bee:	e022                	sd	s0,0(sp)
    80007bf0:	0800                	addi	s0,sp,16
    wakeupone(cv);
    80007bf2:	ffffb097          	auipc	ra,0xffffb
    80007bf6:	6b8080e7          	jalr	1720(ra) # 800032aa <wakeupone>
    return;
}
    80007bfa:	60a2                	ld	ra,8(sp)
    80007bfc:	6402                	ld	s0,0(sp)
    80007bfe:	0141                	addi	sp,sp,16
    80007c00:	8082                	ret

0000000080007c02 <cond_broadcast>:
void cond_broadcast (struct cond_t *cv) {
    80007c02:	1141                	addi	sp,sp,-16
    80007c04:	e406                	sd	ra,8(sp)
    80007c06:	e022                	sd	s0,0(sp)
    80007c08:	0800                	addi	s0,sp,16
    wakeup(cv);
    80007c0a:	ffffb097          	auipc	ra,0xffffb
    80007c0e:	14a080e7          	jalr	330(ra) # 80002d54 <wakeup>
    return;
    80007c12:	60a2                	ld	ra,8(sp)
    80007c14:	6402                	ld	s0,0(sp)
    80007c16:	0141                	addi	sp,sp,16
    80007c18:	8082                	ret

0000000080007c1a <sem_init>:
#include "semaphore.h"
#include "riscv.h"
#include "defs.h"

void sem_init (struct sem_t *z, int value) {
    80007c1a:	1101                	addi	sp,sp,-32
    80007c1c:	ec06                	sd	ra,24(sp)
    80007c1e:	e822                	sd	s0,16(sp)
    80007c20:	e426                	sd	s1,8(sp)
    80007c22:	1000                	addi	s0,sp,32
    80007c24:	84aa                	mv	s1,a0
    z->value = value;
    80007c26:	c10c                	sw	a1,0(a0)
    initsleeplock(&z->cv.lk, "semaphore_cv_lock");
    80007c28:	00002597          	auipc	a1,0x2
    80007c2c:	f6058593          	addi	a1,a1,-160 # 80009b88 <syscalls+0x528>
    80007c30:	03850513          	addi	a0,a0,56
    80007c34:	ffffe097          	auipc	ra,0xffffe
    80007c38:	0d6080e7          	jalr	214(ra) # 80005d0a <initsleeplock>
    initsleeplock(&z->lock, "semaphore_lock");
    80007c3c:	00002597          	auipc	a1,0x2
    80007c40:	f6458593          	addi	a1,a1,-156 # 80009ba0 <syscalls+0x540>
    80007c44:	00848513          	addi	a0,s1,8
    80007c48:	ffffe097          	auipc	ra,0xffffe
    80007c4c:	0c2080e7          	jalr	194(ra) # 80005d0a <initsleeplock>
}
    80007c50:	60e2                	ld	ra,24(sp)
    80007c52:	6442                	ld	s0,16(sp)
    80007c54:	64a2                	ld	s1,8(sp)
    80007c56:	6105                	addi	sp,sp,32
    80007c58:	8082                	ret

0000000080007c5a <sem_wait>:

void sem_wait (struct sem_t *z) {
    80007c5a:	7179                	addi	sp,sp,-48
    80007c5c:	f406                	sd	ra,40(sp)
    80007c5e:	f022                	sd	s0,32(sp)
    80007c60:	ec26                	sd	s1,24(sp)
    80007c62:	e84a                	sd	s2,16(sp)
    80007c64:	e44e                	sd	s3,8(sp)
    80007c66:	1800                	addi	s0,sp,48
    80007c68:	84aa                	mv	s1,a0
acquiresleep (&z->lock);
    80007c6a:	00850913          	addi	s2,a0,8
    80007c6e:	854a                	mv	a0,s2
    80007c70:	ffffe097          	auipc	ra,0xffffe
    80007c74:	0d4080e7          	jalr	212(ra) # 80005d44 <acquiresleep>
while (z->value == 0) cond_wait (&z->cv, &z->lock);
    80007c78:	409c                	lw	a5,0(s1)
    80007c7a:	eb99                	bnez	a5,80007c90 <sem_wait+0x36>
    80007c7c:	03848993          	addi	s3,s1,56
    80007c80:	85ca                	mv	a1,s2
    80007c82:	854e                	mv	a0,s3
    80007c84:	00000097          	auipc	ra,0x0
    80007c88:	f4e080e7          	jalr	-178(ra) # 80007bd2 <cond_wait>
    80007c8c:	409c                	lw	a5,0(s1)
    80007c8e:	dbed                	beqz	a5,80007c80 <sem_wait+0x26>
z->value--;
    80007c90:	37fd                	addiw	a5,a5,-1
    80007c92:	c09c                	sw	a5,0(s1)
releasesleep (&z->lock);
    80007c94:	854a                	mv	a0,s2
    80007c96:	ffffe097          	auipc	ra,0xffffe
    80007c9a:	104080e7          	jalr	260(ra) # 80005d9a <releasesleep>
}
    80007c9e:	70a2                	ld	ra,40(sp)
    80007ca0:	7402                	ld	s0,32(sp)
    80007ca2:	64e2                	ld	s1,24(sp)
    80007ca4:	6942                	ld	s2,16(sp)
    80007ca6:	69a2                	ld	s3,8(sp)
    80007ca8:	6145                	addi	sp,sp,48
    80007caa:	8082                	ret

0000000080007cac <sem_post>:

void sem_post (struct sem_t *z) {
    80007cac:	1101                	addi	sp,sp,-32
    80007cae:	ec06                	sd	ra,24(sp)
    80007cb0:	e822                	sd	s0,16(sp)
    80007cb2:	e426                	sd	s1,8(sp)
    80007cb4:	e04a                	sd	s2,0(sp)
    80007cb6:	1000                	addi	s0,sp,32
    80007cb8:	84aa                	mv	s1,a0
acquiresleep (&z->lock);
    80007cba:	00850913          	addi	s2,a0,8
    80007cbe:	854a                	mv	a0,s2
    80007cc0:	ffffe097          	auipc	ra,0xffffe
    80007cc4:	084080e7          	jalr	132(ra) # 80005d44 <acquiresleep>
z->value++;
    80007cc8:	409c                	lw	a5,0(s1)
    80007cca:	2785                	addiw	a5,a5,1
    80007ccc:	c09c                	sw	a5,0(s1)
cond_signal (&z->cv);
    80007cce:	03848513          	addi	a0,s1,56
    80007cd2:	00000097          	auipc	ra,0x0
    80007cd6:	f18080e7          	jalr	-232(ra) # 80007bea <cond_signal>
releasesleep (&z->lock);
    80007cda:	854a                	mv	a0,s2
    80007cdc:	ffffe097          	auipc	ra,0xffffe
    80007ce0:	0be080e7          	jalr	190(ra) # 80005d9a <releasesleep>
}
    80007ce4:	60e2                	ld	ra,24(sp)
    80007ce6:	6442                	ld	s0,16(sp)
    80007ce8:	64a2                	ld	s1,8(sp)
    80007cea:	6902                	ld	s2,0(sp)
    80007cec:	6105                	addi	sp,sp,32
    80007cee:	8082                	ret
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
