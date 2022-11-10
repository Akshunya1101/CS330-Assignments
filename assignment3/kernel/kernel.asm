
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	ad013103          	ld	sp,-1328(sp) # 80009ad0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000052:	02270713          	addi	a4,a4,34 # 8000a070 <timer_scratch>
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
    80000064:	d7078793          	addi	a5,a5,-656 # 80006dd0 <timervec>
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
    80000098:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77ff>
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
    8000012c:	07a080e7          	jalr	122(ra) # 800031a2 <either_copyin>
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
    8000018c:	02850513          	addi	a0,a0,40 # 800121b0 <cons>
    80000190:	00001097          	auipc	ra,0x1
    80000194:	a3e080e7          	jalr	-1474(ra) # 80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	01848493          	addi	s1,s1,24 # 800121b0 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	0a890913          	addi	s2,s2,168 # 80012248 <cons+0x98>
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
    800001be:	00001097          	auipc	ra,0x1
    800001c2:	7e0080e7          	jalr	2016(ra) # 8000199e <myproc>
    800001c6:	551c                	lw	a5,40(a0)
    800001c8:	e7b5                	bnez	a5,80000234 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001ca:	85a6                	mv	a1,s1
    800001cc:	854a                	mv	a0,s2
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	582080e7          	jalr	1410(ra) # 80002750 <sleep>
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
    8000020e:	f42080e7          	jalr	-190(ra) # 8000314c <either_copyout>
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
    80000222:	f9250513          	addi	a0,a0,-110 # 800121b0 <cons>
    80000226:	00001097          	auipc	ra,0x1
    8000022a:	a5c080e7          	jalr	-1444(ra) # 80000c82 <release>

  return target - n;
    8000022e:	413b053b          	subw	a0,s6,s3
    80000232:	a811                	j	80000246 <consoleread+0xe4>
        release(&cons.lock);
    80000234:	00012517          	auipc	a0,0x12
    80000238:	f7c50513          	addi	a0,a0,-132 # 800121b0 <cons>
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
    8000026e:	fcf72f23          	sw	a5,-34(a4) # 80012248 <cons+0x98>
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
    800002c8:	eec50513          	addi	a0,a0,-276 # 800121b0 <cons>
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
    800002ee:	f0e080e7          	jalr	-242(ra) # 800031f8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f2:	00012517          	auipc	a0,0x12
    800002f6:	ebe50513          	addi	a0,a0,-322 # 800121b0 <cons>
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
    8000031a:	e9a70713          	addi	a4,a4,-358 # 800121b0 <cons>
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
    80000344:	e7078793          	addi	a5,a5,-400 # 800121b0 <cons>
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
    80000372:	eda7a783          	lw	a5,-294(a5) # 80012248 <cons+0x98>
    80000376:	0807879b          	addiw	a5,a5,128
    8000037a:	f6f61ce3          	bne	a2,a5,800002f2 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000037e:	863e                	mv	a2,a5
    80000380:	a07d                	j	8000042e <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000382:	00012717          	auipc	a4,0x12
    80000386:	e2e70713          	addi	a4,a4,-466 # 800121b0 <cons>
    8000038a:	0a072783          	lw	a5,160(a4)
    8000038e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000392:	00012497          	auipc	s1,0x12
    80000396:	e1e48493          	addi	s1,s1,-482 # 800121b0 <cons>
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
    800003d2:	de270713          	addi	a4,a4,-542 # 800121b0 <cons>
    800003d6:	0a072783          	lw	a5,160(a4)
    800003da:	09c72703          	lw	a4,156(a4)
    800003de:	f0f70ae3          	beq	a4,a5,800002f2 <consoleintr+0x3c>
      cons.e--;
    800003e2:	37fd                	addiw	a5,a5,-1
    800003e4:	00012717          	auipc	a4,0x12
    800003e8:	e6f72623          	sw	a5,-404(a4) # 80012250 <cons+0xa0>
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
    8000040e:	da678793          	addi	a5,a5,-602 # 800121b0 <cons>
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
    80000432:	e0c7af23          	sw	a2,-482(a5) # 8001224c <cons+0x9c>
        wakeup(&cons.r);
    80000436:	00012517          	auipc	a0,0x12
    8000043a:	e1250513          	addi	a0,a0,-494 # 80012248 <cons+0x98>
    8000043e:	00002097          	auipc	ra,0x2
    80000442:	716080e7          	jalr	1814(ra) # 80002b54 <wakeup>
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
    8000045c:	d5850513          	addi	a0,a0,-680 # 800121b0 <cons>
    80000460:	00000097          	auipc	ra,0x0
    80000464:	6de080e7          	jalr	1758(ra) # 80000b3e <initlock>

  uartinit();
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	32c080e7          	jalr	812(ra) # 80000794 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000470:	00023797          	auipc	a5,0x23
    80000474:	8d878793          	addi	a5,a5,-1832 # 80022d48 <devsw>
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
    80000548:	d207a623          	sw	zero,-724(a5) # 80012270 <pr+0x18>
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
    8000056a:	1e250513          	addi	a0,a0,482 # 80009748 <syscalls+0x108>
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
    800005b8:	cbcdad83          	lw	s11,-836(s11) # 80012270 <pr+0x18>
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
    800005f6:	c6650513          	addi	a0,a0,-922 # 80012258 <pr>
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
    80000754:	b0850513          	addi	a0,a0,-1272 # 80012258 <pr>
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
    80000770:	aec48493          	addi	s1,s1,-1300 # 80012258 <pr>
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
    800007d0:	aac50513          	addi	a0,a0,-1364 # 80012278 <uart_tx_lock>
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
    8000085e:	a1ea0a13          	addi	s4,s4,-1506 # 80012278 <uart_tx_lock>
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
    80000890:	2c8080e7          	jalr	712(ra) # 80002b54 <wakeup>
    
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
    800008cc:	9b050513          	addi	a0,a0,-1616 # 80012278 <uart_tx_lock>
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
    80000900:	97c98993          	addi	s3,s3,-1668 # 80012278 <uart_tx_lock>
    80000904:	00009497          	auipc	s1,0x9
    80000908:	70448493          	addi	s1,s1,1796 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00009917          	auipc	s2,0x9
    80000910:	70490913          	addi	s2,s2,1796 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000914:	85ce                	mv	a1,s3
    80000916:	8526                	mv	a0,s1
    80000918:	00002097          	auipc	ra,0x2
    8000091c:	e38080e7          	jalr	-456(ra) # 80002750 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00093703          	ld	a4,0(s2)
    80000924:	609c                	ld	a5,0(s1)
    80000926:	02078793          	addi	a5,a5,32
    8000092a:	fee785e3          	beq	a5,a4,80000914 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000092e:	00012497          	auipc	s1,0x12
    80000932:	94a48493          	addi	s1,s1,-1718 # 80012278 <uart_tx_lock>
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
    800009b6:	8c648493          	addi	s1,s1,-1850 # 80012278 <uart_tx_lock>
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
    800009f4:	00026797          	auipc	a5,0x26
    800009f8:	60c78793          	addi	a5,a5,1548 # 80027000 <end>
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
    80000a18:	89c90913          	addi	s2,s2,-1892 # 800122b0 <kmem>
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
    80000ab2:	00011517          	auipc	a0,0x11
    80000ab6:	7fe50513          	addi	a0,a0,2046 # 800122b0 <kmem>
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	084080e7          	jalr	132(ra) # 80000b3e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac2:	45c5                	li	a1,17
    80000ac4:	05ee                	slli	a1,a1,0x1b
    80000ac6:	00026517          	auipc	a0,0x26
    80000aca:	53a50513          	addi	a0,a0,1338 # 80027000 <end>
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
    80000aec:	7c848493          	addi	s1,s1,1992 # 800122b0 <kmem>
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
    80000b04:	7b050513          	addi	a0,a0,1968 # 800122b0 <kmem>
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
    80000b30:	78450513          	addi	a0,a0,1924 # 800122b0 <kmem>
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
    80000b6c:	e1a080e7          	jalr	-486(ra) # 80001982 <mycpu>
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
    80000b9e:	de8080e7          	jalr	-536(ra) # 80001982 <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	cf89                	beqz	a5,80000bbe <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba6:	00001097          	auipc	ra,0x1
    80000baa:	ddc080e7          	jalr	-548(ra) # 80001982 <mycpu>
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
    80000bc2:	dc4080e7          	jalr	-572(ra) # 80001982 <mycpu>
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
    80000c02:	d84080e7          	jalr	-636(ra) # 80001982 <mycpu>
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
    80000c2e:	d58080e7          	jalr	-680(ra) # 80001982 <mycpu>
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
    80000d3e:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd8001>
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
extern int sched_policy;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e70:	1141                	addi	sp,sp,-16
    80000e72:	e406                	sd	ra,8(sp)
    80000e74:	e022                	sd	s0,0(sp)
    80000e76:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e78:	00001097          	auipc	ra,0x1
    80000e7c:	afa080e7          	jalr	-1286(ra) # 80001972 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e80:	00009717          	auipc	a4,0x9
    80000e84:	19870713          	addi	a4,a4,408 # 8000a018 <started>
  if(cpuid() == 0){
    80000e88:	c921                	beqz	a0,80000ed8 <main+0x68>
    while(started == 0)
    80000e8a:	431c                	lw	a5,0(a4)
    80000e8c:	2781                	sext.w	a5,a5
    80000e8e:	dff5                	beqz	a5,80000e8a <main+0x1a>
      ;
    __sync_synchronize();
    80000e90:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e94:	00001097          	auipc	ra,0x1
    80000e98:	ade080e7          	jalr	-1314(ra) # 80001972 <cpuid>
    80000e9c:	85aa                	mv	a1,a0
    80000e9e:	00008517          	auipc	a0,0x8
    80000ea2:	21a50513          	addi	a0,a0,538 # 800090b8 <digits+0x78>
    80000ea6:	fffff097          	auipc	ra,0xfffff
    80000eaa:	6dc080e7          	jalr	1756(ra) # 80000582 <printf>
    kvminithart();    // turn on paging
    80000eae:	00000097          	auipc	ra,0x0
    80000eb2:	0e2080e7          	jalr	226(ra) # 80000f90 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb6:	00002097          	auipc	ra,0x2
    80000eba:	7b0080e7          	jalr	1968(ra) # 80003666 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	00006097          	auipc	ra,0x6
    80000ec2:	f52080e7          	jalr	-174(ra) # 80006e10 <plicinithart>
  }

  sched_policy = SCHED_PREEMPT_RR;
    80000ec6:	4789                	li	a5,2
    80000ec8:	00009717          	auipc	a4,0x9
    80000ecc:	1af72023          	sw	a5,416(a4) # 8000a068 <sched_policy>

  scheduler();        
    80000ed0:	00001097          	auipc	ra,0x1
    80000ed4:	31e080e7          	jalr	798(ra) # 800021ee <scheduler>
    consoleinit();
    80000ed8:	fffff097          	auipc	ra,0xfffff
    80000edc:	570080e7          	jalr	1392(ra) # 80000448 <consoleinit>
    printfinit();
    80000ee0:	00000097          	auipc	ra,0x0
    80000ee4:	882080e7          	jalr	-1918(ra) # 80000762 <printfinit>
    printf("\n");
    80000ee8:	00009517          	auipc	a0,0x9
    80000eec:	86050513          	addi	a0,a0,-1952 # 80009748 <syscalls+0x108>
    80000ef0:	fffff097          	auipc	ra,0xfffff
    80000ef4:	692080e7          	jalr	1682(ra) # 80000582 <printf>
    printf("xv6 kernel is booting\n");
    80000ef8:	00008517          	auipc	a0,0x8
    80000efc:	1a850513          	addi	a0,a0,424 # 800090a0 <digits+0x60>
    80000f00:	fffff097          	auipc	ra,0xfffff
    80000f04:	682080e7          	jalr	1666(ra) # 80000582 <printf>
    printf("\n");
    80000f08:	00009517          	auipc	a0,0x9
    80000f0c:	84050513          	addi	a0,a0,-1984 # 80009748 <syscalls+0x108>
    80000f10:	fffff097          	auipc	ra,0xfffff
    80000f14:	672080e7          	jalr	1650(ra) # 80000582 <printf>
    kinit();         // physical page allocator
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	b8a080e7          	jalr	-1142(ra) # 80000aa2 <kinit>
    kvminit();       // create kernel page table
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	322080e7          	jalr	802(ra) # 80001242 <kvminit>
    kvminithart();   // turn on paging
    80000f28:	00000097          	auipc	ra,0x0
    80000f2c:	068080e7          	jalr	104(ra) # 80000f90 <kvminithart>
    procinit();      // process table
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	992080e7          	jalr	-1646(ra) # 800018c2 <procinit>
    trapinit();      // trap vectors
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	706080e7          	jalr	1798(ra) # 8000363e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f40:	00002097          	auipc	ra,0x2
    80000f44:	726080e7          	jalr	1830(ra) # 80003666 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f48:	00006097          	auipc	ra,0x6
    80000f4c:	eb2080e7          	jalr	-334(ra) # 80006dfa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f50:	00006097          	auipc	ra,0x6
    80000f54:	ec0080e7          	jalr	-320(ra) # 80006e10 <plicinithart>
    binit();         // buffer cache
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	080080e7          	jalr	128(ra) # 80003fd8 <binit>
    iinit();         // inode table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	70e080e7          	jalr	1806(ra) # 8000466e <iinit>
    fileinit();      // file table
    80000f68:	00004097          	auipc	ra,0x4
    80000f6c:	6c0080e7          	jalr	1728(ra) # 80005628 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f70:	00006097          	auipc	ra,0x6
    80000f74:	fc0080e7          	jalr	-64(ra) # 80006f30 <virtio_disk_init>
    userinit();      // first user process
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	d74080e7          	jalr	-652(ra) # 80001cec <userinit>
    __sync_synchronize();
    80000f80:	0ff0000f          	fence
    started = 1;
    80000f84:	4785                	li	a5,1
    80000f86:	00009717          	auipc	a4,0x9
    80000f8a:	08f72923          	sw	a5,146(a4) # 8000a018 <started>
    80000f8e:	bf25                	j	80000ec6 <main+0x56>

0000000080000f90 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f90:	1141                	addi	sp,sp,-16
    80000f92:	e422                	sd	s0,8(sp)
    80000f94:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f96:	00009797          	auipc	a5,0x9
    80000f9a:	08a7b783          	ld	a5,138(a5) # 8000a020 <kernel_pagetable>
    80000f9e:	83b1                	srli	a5,a5,0xc
    80000fa0:	577d                	li	a4,-1
    80000fa2:	177e                	slli	a4,a4,0x3f
    80000fa4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa6:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000faa:	12000073          	sfence.vma
  sfence_vma();
}
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret

0000000080000fb4 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb4:	7139                	addi	sp,sp,-64
    80000fb6:	fc06                	sd	ra,56(sp)
    80000fb8:	f822                	sd	s0,48(sp)
    80000fba:	f426                	sd	s1,40(sp)
    80000fbc:	f04a                	sd	s2,32(sp)
    80000fbe:	ec4e                	sd	s3,24(sp)
    80000fc0:	e852                	sd	s4,16(sp)
    80000fc2:	e456                	sd	s5,8(sp)
    80000fc4:	e05a                	sd	s6,0(sp)
    80000fc6:	0080                	addi	s0,sp,64
    80000fc8:	84aa                	mv	s1,a0
    80000fca:	89ae                	mv	s3,a1
    80000fcc:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fce:	57fd                	li	a5,-1
    80000fd0:	83e9                	srli	a5,a5,0x1a
    80000fd2:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd4:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd6:	04b7f263          	bgeu	a5,a1,8000101a <walk+0x66>
    panic("walk");
    80000fda:	00008517          	auipc	a0,0x8
    80000fde:	0f650513          	addi	a0,a0,246 # 800090d0 <digits+0x90>
    80000fe2:	fffff097          	auipc	ra,0xfffff
    80000fe6:	556080e7          	jalr	1366(ra) # 80000538 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fea:	060a8663          	beqz	s5,80001056 <walk+0xa2>
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	af0080e7          	jalr	-1296(ra) # 80000ade <kalloc>
    80000ff6:	84aa                	mv	s1,a0
    80000ff8:	c529                	beqz	a0,80001042 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffa:	6605                	lui	a2,0x1
    80000ffc:	4581                	li	a1,0
    80000ffe:	00000097          	auipc	ra,0x0
    80001002:	ccc080e7          	jalr	-820(ra) # 80000cca <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001006:	00c4d793          	srli	a5,s1,0xc
    8000100a:	07aa                	slli	a5,a5,0xa
    8000100c:	0017e793          	ori	a5,a5,1
    80001010:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001014:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd7ff7>
    80001016:	036a0063          	beq	s4,s6,80001036 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101a:	0149d933          	srl	s2,s3,s4
    8000101e:	1ff97913          	andi	s2,s2,511
    80001022:	090e                	slli	s2,s2,0x3
    80001024:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001026:	00093483          	ld	s1,0(s2)
    8000102a:	0014f793          	andi	a5,s1,1
    8000102e:	dfd5                	beqz	a5,80000fea <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001030:	80a9                	srli	s1,s1,0xa
    80001032:	04b2                	slli	s1,s1,0xc
    80001034:	b7c5                	j	80001014 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001036:	00c9d513          	srli	a0,s3,0xc
    8000103a:	1ff57513          	andi	a0,a0,511
    8000103e:	050e                	slli	a0,a0,0x3
    80001040:	9526                	add	a0,a0,s1
}
    80001042:	70e2                	ld	ra,56(sp)
    80001044:	7442                	ld	s0,48(sp)
    80001046:	74a2                	ld	s1,40(sp)
    80001048:	7902                	ld	s2,32(sp)
    8000104a:	69e2                	ld	s3,24(sp)
    8000104c:	6a42                	ld	s4,16(sp)
    8000104e:	6aa2                	ld	s5,8(sp)
    80001050:	6b02                	ld	s6,0(sp)
    80001052:	6121                	addi	sp,sp,64
    80001054:	8082                	ret
        return 0;
    80001056:	4501                	li	a0,0
    80001058:	b7ed                	j	80001042 <walk+0x8e>

000000008000105a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105a:	57fd                	li	a5,-1
    8000105c:	83e9                	srli	a5,a5,0x1a
    8000105e:	00b7f463          	bgeu	a5,a1,80001066 <walkaddr+0xc>
    return 0;
    80001062:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001064:	8082                	ret
{
    80001066:	1141                	addi	sp,sp,-16
    80001068:	e406                	sd	ra,8(sp)
    8000106a:	e022                	sd	s0,0(sp)
    8000106c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106e:	4601                	li	a2,0
    80001070:	00000097          	auipc	ra,0x0
    80001074:	f44080e7          	jalr	-188(ra) # 80000fb4 <walk>
  if(pte == 0)
    80001078:	c105                	beqz	a0,80001098 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107c:	0117f693          	andi	a3,a5,17
    80001080:	4745                	li	a4,17
    return 0;
    80001082:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001084:	00e68663          	beq	a3,a4,80001090 <walkaddr+0x36>
}
    80001088:	60a2                	ld	ra,8(sp)
    8000108a:	6402                	ld	s0,0(sp)
    8000108c:	0141                	addi	sp,sp,16
    8000108e:	8082                	ret
  pa = PTE2PA(*pte);
    80001090:	83a9                	srli	a5,a5,0xa
    80001092:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001096:	bfcd                	j	80001088 <walkaddr+0x2e>
    return 0;
    80001098:	4501                	li	a0,0
    8000109a:	b7fd                	j	80001088 <walkaddr+0x2e>

000000008000109c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109c:	715d                	addi	sp,sp,-80
    8000109e:	e486                	sd	ra,72(sp)
    800010a0:	e0a2                	sd	s0,64(sp)
    800010a2:	fc26                	sd	s1,56(sp)
    800010a4:	f84a                	sd	s2,48(sp)
    800010a6:	f44e                	sd	s3,40(sp)
    800010a8:	f052                	sd	s4,32(sp)
    800010aa:	ec56                	sd	s5,24(sp)
    800010ac:	e85a                	sd	s6,16(sp)
    800010ae:	e45e                	sd	s7,8(sp)
    800010b0:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b2:	c639                	beqz	a2,80001100 <mappages+0x64>
    800010b4:	8aaa                	mv	s5,a0
    800010b6:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b8:	777d                	lui	a4,0xfffff
    800010ba:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010be:	fff58993          	addi	s3,a1,-1
    800010c2:	99b2                	add	s3,s3,a2
    800010c4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c8:	893e                	mv	s2,a5
    800010ca:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ce:	6b85                	lui	s7,0x1
    800010d0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d4:	4605                	li	a2,1
    800010d6:	85ca                	mv	a1,s2
    800010d8:	8556                	mv	a0,s5
    800010da:	00000097          	auipc	ra,0x0
    800010de:	eda080e7          	jalr	-294(ra) # 80000fb4 <walk>
    800010e2:	cd1d                	beqz	a0,80001120 <mappages+0x84>
    if(*pte & PTE_V)
    800010e4:	611c                	ld	a5,0(a0)
    800010e6:	8b85                	andi	a5,a5,1
    800010e8:	e785                	bnez	a5,80001110 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ea:	80b1                	srli	s1,s1,0xc
    800010ec:	04aa                	slli	s1,s1,0xa
    800010ee:	0164e4b3          	or	s1,s1,s6
    800010f2:	0014e493          	ori	s1,s1,1
    800010f6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f8:	05390063          	beq	s2,s3,80001138 <mappages+0x9c>
    a += PGSIZE;
    800010fc:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fe:	bfc9                	j	800010d0 <mappages+0x34>
    panic("mappages: size");
    80001100:	00008517          	auipc	a0,0x8
    80001104:	fd850513          	addi	a0,a0,-40 # 800090d8 <digits+0x98>
    80001108:	fffff097          	auipc	ra,0xfffff
    8000110c:	430080e7          	jalr	1072(ra) # 80000538 <panic>
      panic("mappages: remap");
    80001110:	00008517          	auipc	a0,0x8
    80001114:	fd850513          	addi	a0,a0,-40 # 800090e8 <digits+0xa8>
    80001118:	fffff097          	auipc	ra,0xfffff
    8000111c:	420080e7          	jalr	1056(ra) # 80000538 <panic>
      return -1;
    80001120:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001122:	60a6                	ld	ra,72(sp)
    80001124:	6406                	ld	s0,64(sp)
    80001126:	74e2                	ld	s1,56(sp)
    80001128:	7942                	ld	s2,48(sp)
    8000112a:	79a2                	ld	s3,40(sp)
    8000112c:	7a02                	ld	s4,32(sp)
    8000112e:	6ae2                	ld	s5,24(sp)
    80001130:	6b42                	ld	s6,16(sp)
    80001132:	6ba2                	ld	s7,8(sp)
    80001134:	6161                	addi	sp,sp,80
    80001136:	8082                	ret
  return 0;
    80001138:	4501                	li	a0,0
    8000113a:	b7e5                	j	80001122 <mappages+0x86>

000000008000113c <kvmmap>:
{
    8000113c:	1141                	addi	sp,sp,-16
    8000113e:	e406                	sd	ra,8(sp)
    80001140:	e022                	sd	s0,0(sp)
    80001142:	0800                	addi	s0,sp,16
    80001144:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001146:	86b2                	mv	a3,a2
    80001148:	863e                	mv	a2,a5
    8000114a:	00000097          	auipc	ra,0x0
    8000114e:	f52080e7          	jalr	-174(ra) # 8000109c <mappages>
    80001152:	e509                	bnez	a0,8000115c <kvmmap+0x20>
}
    80001154:	60a2                	ld	ra,8(sp)
    80001156:	6402                	ld	s0,0(sp)
    80001158:	0141                	addi	sp,sp,16
    8000115a:	8082                	ret
    panic("kvmmap");
    8000115c:	00008517          	auipc	a0,0x8
    80001160:	f9c50513          	addi	a0,a0,-100 # 800090f8 <digits+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3d4080e7          	jalr	980(ra) # 80000538 <panic>

000000008000116c <kvmmake>:
{
    8000116c:	1101                	addi	sp,sp,-32
    8000116e:	ec06                	sd	ra,24(sp)
    80001170:	e822                	sd	s0,16(sp)
    80001172:	e426                	sd	s1,8(sp)
    80001174:	e04a                	sd	s2,0(sp)
    80001176:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	966080e7          	jalr	-1690(ra) # 80000ade <kalloc>
    80001180:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001182:	6605                	lui	a2,0x1
    80001184:	4581                	li	a1,0
    80001186:	00000097          	auipc	ra,0x0
    8000118a:	b44080e7          	jalr	-1212(ra) # 80000cca <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118e:	4719                	li	a4,6
    80001190:	6685                	lui	a3,0x1
    80001192:	10000637          	lui	a2,0x10000
    80001196:	100005b7          	lui	a1,0x10000
    8000119a:	8526                	mv	a0,s1
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	fa0080e7          	jalr	-96(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a4:	4719                	li	a4,6
    800011a6:	6685                	lui	a3,0x1
    800011a8:	10001637          	lui	a2,0x10001
    800011ac:	100015b7          	lui	a1,0x10001
    800011b0:	8526                	mv	a0,s1
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	f8a080e7          	jalr	-118(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ba:	4719                	li	a4,6
    800011bc:	004006b7          	lui	a3,0x400
    800011c0:	0c000637          	lui	a2,0xc000
    800011c4:	0c0005b7          	lui	a1,0xc000
    800011c8:	8526                	mv	a0,s1
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	f72080e7          	jalr	-142(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d2:	00008917          	auipc	s2,0x8
    800011d6:	e2e90913          	addi	s2,s2,-466 # 80009000 <etext>
    800011da:	4729                	li	a4,10
    800011dc:	80008697          	auipc	a3,0x80008
    800011e0:	e2468693          	addi	a3,a3,-476 # 9000 <_entry-0x7fff7000>
    800011e4:	4605                	li	a2,1
    800011e6:	067e                	slli	a2,a2,0x1f
    800011e8:	85b2                	mv	a1,a2
    800011ea:	8526                	mv	a0,s1
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	f50080e7          	jalr	-176(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f4:	4719                	li	a4,6
    800011f6:	46c5                	li	a3,17
    800011f8:	06ee                	slli	a3,a3,0x1b
    800011fa:	412686b3          	sub	a3,a3,s2
    800011fe:	864a                	mv	a2,s2
    80001200:	85ca                	mv	a1,s2
    80001202:	8526                	mv	a0,s1
    80001204:	00000097          	auipc	ra,0x0
    80001208:	f38080e7          	jalr	-200(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120c:	4729                	li	a4,10
    8000120e:	6685                	lui	a3,0x1
    80001210:	00007617          	auipc	a2,0x7
    80001214:	df060613          	addi	a2,a2,-528 # 80008000 <_trampoline>
    80001218:	040005b7          	lui	a1,0x4000
    8000121c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121e:	05b2                	slli	a1,a1,0xc
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f1a080e7          	jalr	-230(ra) # 8000113c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122a:	8526                	mv	a0,s1
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	600080e7          	jalr	1536(ra) # 8000182c <proc_mapstacks>
}
    80001234:	8526                	mv	a0,s1
    80001236:	60e2                	ld	ra,24(sp)
    80001238:	6442                	ld	s0,16(sp)
    8000123a:	64a2                	ld	s1,8(sp)
    8000123c:	6902                	ld	s2,0(sp)
    8000123e:	6105                	addi	sp,sp,32
    80001240:	8082                	ret

0000000080001242 <kvminit>:
{
    80001242:	1141                	addi	sp,sp,-16
    80001244:	e406                	sd	ra,8(sp)
    80001246:	e022                	sd	s0,0(sp)
    80001248:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	f22080e7          	jalr	-222(ra) # 8000116c <kvmmake>
    80001252:	00009797          	auipc	a5,0x9
    80001256:	dca7b723          	sd	a0,-562(a5) # 8000a020 <kernel_pagetable>
}
    8000125a:	60a2                	ld	ra,8(sp)
    8000125c:	6402                	ld	s0,0(sp)
    8000125e:	0141                	addi	sp,sp,16
    80001260:	8082                	ret

0000000080001262 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001262:	715d                	addi	sp,sp,-80
    80001264:	e486                	sd	ra,72(sp)
    80001266:	e0a2                	sd	s0,64(sp)
    80001268:	fc26                	sd	s1,56(sp)
    8000126a:	f84a                	sd	s2,48(sp)
    8000126c:	f44e                	sd	s3,40(sp)
    8000126e:	f052                	sd	s4,32(sp)
    80001270:	ec56                	sd	s5,24(sp)
    80001272:	e85a                	sd	s6,16(sp)
    80001274:	e45e                	sd	s7,8(sp)
    80001276:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001278:	03459793          	slli	a5,a1,0x34
    8000127c:	e795                	bnez	a5,800012a8 <uvmunmap+0x46>
    8000127e:	8a2a                	mv	s4,a0
    80001280:	892e                	mv	s2,a1
    80001282:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001284:	0632                	slli	a2,a2,0xc
    80001286:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128c:	6b05                	lui	s6,0x1
    8000128e:	0735e263          	bltu	a1,s3,800012f2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001292:	60a6                	ld	ra,72(sp)
    80001294:	6406                	ld	s0,64(sp)
    80001296:	74e2                	ld	s1,56(sp)
    80001298:	7942                	ld	s2,48(sp)
    8000129a:	79a2                	ld	s3,40(sp)
    8000129c:	7a02                	ld	s4,32(sp)
    8000129e:	6ae2                	ld	s5,24(sp)
    800012a0:	6b42                	ld	s6,16(sp)
    800012a2:	6ba2                	ld	s7,8(sp)
    800012a4:	6161                	addi	sp,sp,80
    800012a6:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a8:	00008517          	auipc	a0,0x8
    800012ac:	e5850513          	addi	a0,a0,-424 # 80009100 <digits+0xc0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	288080e7          	jalr	648(ra) # 80000538 <panic>
      panic("uvmunmap: walk");
    800012b8:	00008517          	auipc	a0,0x8
    800012bc:	e6050513          	addi	a0,a0,-416 # 80009118 <digits+0xd8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	278080e7          	jalr	632(ra) # 80000538 <panic>
      panic("uvmunmap: not mapped");
    800012c8:	00008517          	auipc	a0,0x8
    800012cc:	e6050513          	addi	a0,a0,-416 # 80009128 <digits+0xe8>
    800012d0:	fffff097          	auipc	ra,0xfffff
    800012d4:	268080e7          	jalr	616(ra) # 80000538 <panic>
      panic("uvmunmap: not a leaf");
    800012d8:	00008517          	auipc	a0,0x8
    800012dc:	e6850513          	addi	a0,a0,-408 # 80009140 <digits+0x100>
    800012e0:	fffff097          	auipc	ra,0xfffff
    800012e4:	258080e7          	jalr	600(ra) # 80000538 <panic>
    *pte = 0;
    800012e8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ec:	995a                	add	s2,s2,s6
    800012ee:	fb3972e3          	bgeu	s2,s3,80001292 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f2:	4601                	li	a2,0
    800012f4:	85ca                	mv	a1,s2
    800012f6:	8552                	mv	a0,s4
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	cbc080e7          	jalr	-836(ra) # 80000fb4 <walk>
    80001300:	84aa                	mv	s1,a0
    80001302:	d95d                	beqz	a0,800012b8 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001304:	6108                	ld	a0,0(a0)
    80001306:	00157793          	andi	a5,a0,1
    8000130a:	dfdd                	beqz	a5,800012c8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130c:	3ff57793          	andi	a5,a0,1023
    80001310:	fd7784e3          	beq	a5,s7,800012d8 <uvmunmap+0x76>
    if(do_free){
    80001314:	fc0a8ae3          	beqz	s5,800012e8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001318:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131a:	0532                	slli	a0,a0,0xc
    8000131c:	fffff097          	auipc	ra,0xfffff
    80001320:	6c4080e7          	jalr	1732(ra) # 800009e0 <kfree>
    80001324:	b7d1                	j	800012e8 <uvmunmap+0x86>

0000000080001326 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001326:	1101                	addi	sp,sp,-32
    80001328:	ec06                	sd	ra,24(sp)
    8000132a:	e822                	sd	s0,16(sp)
    8000132c:	e426                	sd	s1,8(sp)
    8000132e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001330:	fffff097          	auipc	ra,0xfffff
    80001334:	7ae080e7          	jalr	1966(ra) # 80000ade <kalloc>
    80001338:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133a:	c519                	beqz	a0,80001348 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133c:	6605                	lui	a2,0x1
    8000133e:	4581                	li	a1,0
    80001340:	00000097          	auipc	ra,0x0
    80001344:	98a080e7          	jalr	-1654(ra) # 80000cca <memset>
  return pagetable;
}
    80001348:	8526                	mv	a0,s1
    8000134a:	60e2                	ld	ra,24(sp)
    8000134c:	6442                	ld	s0,16(sp)
    8000134e:	64a2                	ld	s1,8(sp)
    80001350:	6105                	addi	sp,sp,32
    80001352:	8082                	ret

0000000080001354 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001354:	7179                	addi	sp,sp,-48
    80001356:	f406                	sd	ra,40(sp)
    80001358:	f022                	sd	s0,32(sp)
    8000135a:	ec26                	sd	s1,24(sp)
    8000135c:	e84a                	sd	s2,16(sp)
    8000135e:	e44e                	sd	s3,8(sp)
    80001360:	e052                	sd	s4,0(sp)
    80001362:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001364:	6785                	lui	a5,0x1
    80001366:	04f67863          	bgeu	a2,a5,800013b6 <uvminit+0x62>
    8000136a:	8a2a                	mv	s4,a0
    8000136c:	89ae                	mv	s3,a1
    8000136e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	76e080e7          	jalr	1902(ra) # 80000ade <kalloc>
    80001378:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137a:	6605                	lui	a2,0x1
    8000137c:	4581                	li	a1,0
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	94c080e7          	jalr	-1716(ra) # 80000cca <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001386:	4779                	li	a4,30
    80001388:	86ca                	mv	a3,s2
    8000138a:	6605                	lui	a2,0x1
    8000138c:	4581                	li	a1,0
    8000138e:	8552                	mv	a0,s4
    80001390:	00000097          	auipc	ra,0x0
    80001394:	d0c080e7          	jalr	-756(ra) # 8000109c <mappages>
  memmove(mem, src, sz);
    80001398:	8626                	mv	a2,s1
    8000139a:	85ce                	mv	a1,s3
    8000139c:	854a                	mv	a0,s2
    8000139e:	00000097          	auipc	ra,0x0
    800013a2:	988080e7          	jalr	-1656(ra) # 80000d26 <memmove>
}
    800013a6:	70a2                	ld	ra,40(sp)
    800013a8:	7402                	ld	s0,32(sp)
    800013aa:	64e2                	ld	s1,24(sp)
    800013ac:	6942                	ld	s2,16(sp)
    800013ae:	69a2                	ld	s3,8(sp)
    800013b0:	6a02                	ld	s4,0(sp)
    800013b2:	6145                	addi	sp,sp,48
    800013b4:	8082                	ret
    panic("inituvm: more than a page");
    800013b6:	00008517          	auipc	a0,0x8
    800013ba:	da250513          	addi	a0,a0,-606 # 80009158 <digits+0x118>
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	17a080e7          	jalr	378(ra) # 80000538 <panic>

00000000800013c6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c6:	1101                	addi	sp,sp,-32
    800013c8:	ec06                	sd	ra,24(sp)
    800013ca:	e822                	sd	s0,16(sp)
    800013cc:	e426                	sd	s1,8(sp)
    800013ce:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d2:	00b67d63          	bgeu	a2,a1,800013ec <uvmdealloc+0x26>
    800013d6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d8:	6785                	lui	a5,0x1
    800013da:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013dc:	00f60733          	add	a4,a2,a5
    800013e0:	76fd                	lui	a3,0xfffff
    800013e2:	8f75                	and	a4,a4,a3
    800013e4:	97ae                	add	a5,a5,a1
    800013e6:	8ff5                	and	a5,a5,a3
    800013e8:	00f76863          	bltu	a4,a5,800013f8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ec:	8526                	mv	a0,s1
    800013ee:	60e2                	ld	ra,24(sp)
    800013f0:	6442                	ld	s0,16(sp)
    800013f2:	64a2                	ld	s1,8(sp)
    800013f4:	6105                	addi	sp,sp,32
    800013f6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f8:	8f99                	sub	a5,a5,a4
    800013fa:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fc:	4685                	li	a3,1
    800013fe:	0007861b          	sext.w	a2,a5
    80001402:	85ba                	mv	a1,a4
    80001404:	00000097          	auipc	ra,0x0
    80001408:	e5e080e7          	jalr	-418(ra) # 80001262 <uvmunmap>
    8000140c:	b7c5                	j	800013ec <uvmdealloc+0x26>

000000008000140e <uvmalloc>:
  if(newsz < oldsz)
    8000140e:	0ab66163          	bltu	a2,a1,800014b0 <uvmalloc+0xa2>
{
    80001412:	7139                	addi	sp,sp,-64
    80001414:	fc06                	sd	ra,56(sp)
    80001416:	f822                	sd	s0,48(sp)
    80001418:	f426                	sd	s1,40(sp)
    8000141a:	f04a                	sd	s2,32(sp)
    8000141c:	ec4e                	sd	s3,24(sp)
    8000141e:	e852                	sd	s4,16(sp)
    80001420:	e456                	sd	s5,8(sp)
    80001422:	0080                	addi	s0,sp,64
    80001424:	8aaa                	mv	s5,a0
    80001426:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001428:	6785                	lui	a5,0x1
    8000142a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142c:	95be                	add	a1,a1,a5
    8000142e:	77fd                	lui	a5,0xfffff
    80001430:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001434:	08c9f063          	bgeu	s3,a2,800014b4 <uvmalloc+0xa6>
    80001438:	894e                	mv	s2,s3
    mem = kalloc();
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	6a4080e7          	jalr	1700(ra) # 80000ade <kalloc>
    80001442:	84aa                	mv	s1,a0
    if(mem == 0){
    80001444:	c51d                	beqz	a0,80001472 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001446:	6605                	lui	a2,0x1
    80001448:	4581                	li	a1,0
    8000144a:	00000097          	auipc	ra,0x0
    8000144e:	880080e7          	jalr	-1920(ra) # 80000cca <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001452:	4779                	li	a4,30
    80001454:	86a6                	mv	a3,s1
    80001456:	6605                	lui	a2,0x1
    80001458:	85ca                	mv	a1,s2
    8000145a:	8556                	mv	a0,s5
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	c40080e7          	jalr	-960(ra) # 8000109c <mappages>
    80001464:	e905                	bnez	a0,80001494 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001466:	6785                	lui	a5,0x1
    80001468:	993e                	add	s2,s2,a5
    8000146a:	fd4968e3          	bltu	s2,s4,8000143a <uvmalloc+0x2c>
  return newsz;
    8000146e:	8552                	mv	a0,s4
    80001470:	a809                	j	80001482 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001472:	864e                	mv	a2,s3
    80001474:	85ca                	mv	a1,s2
    80001476:	8556                	mv	a0,s5
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	f4e080e7          	jalr	-178(ra) # 800013c6 <uvmdealloc>
      return 0;
    80001480:	4501                	li	a0,0
}
    80001482:	70e2                	ld	ra,56(sp)
    80001484:	7442                	ld	s0,48(sp)
    80001486:	74a2                	ld	s1,40(sp)
    80001488:	7902                	ld	s2,32(sp)
    8000148a:	69e2                	ld	s3,24(sp)
    8000148c:	6a42                	ld	s4,16(sp)
    8000148e:	6aa2                	ld	s5,8(sp)
    80001490:	6121                	addi	sp,sp,64
    80001492:	8082                	ret
      kfree(mem);
    80001494:	8526                	mv	a0,s1
    80001496:	fffff097          	auipc	ra,0xfffff
    8000149a:	54a080e7          	jalr	1354(ra) # 800009e0 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000149e:	864e                	mv	a2,s3
    800014a0:	85ca                	mv	a1,s2
    800014a2:	8556                	mv	a0,s5
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	f22080e7          	jalr	-222(ra) # 800013c6 <uvmdealloc>
      return 0;
    800014ac:	4501                	li	a0,0
    800014ae:	bfd1                	j	80001482 <uvmalloc+0x74>
    return oldsz;
    800014b0:	852e                	mv	a0,a1
}
    800014b2:	8082                	ret
  return newsz;
    800014b4:	8532                	mv	a0,a2
    800014b6:	b7f1                	j	80001482 <uvmalloc+0x74>

00000000800014b8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b8:	7179                	addi	sp,sp,-48
    800014ba:	f406                	sd	ra,40(sp)
    800014bc:	f022                	sd	s0,32(sp)
    800014be:	ec26                	sd	s1,24(sp)
    800014c0:	e84a                	sd	s2,16(sp)
    800014c2:	e44e                	sd	s3,8(sp)
    800014c4:	e052                	sd	s4,0(sp)
    800014c6:	1800                	addi	s0,sp,48
    800014c8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ca:	84aa                	mv	s1,a0
    800014cc:	6905                	lui	s2,0x1
    800014ce:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d0:	4985                	li	s3,1
    800014d2:	a829                	j	800014ec <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014d6:	00c79513          	slli	a0,a5,0xc
    800014da:	00000097          	auipc	ra,0x0
    800014de:	fde080e7          	jalr	-34(ra) # 800014b8 <freewalk>
      pagetable[i] = 0;
    800014e2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014e6:	04a1                	addi	s1,s1,8
    800014e8:	03248163          	beq	s1,s2,8000150a <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014ec:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ee:	00f7f713          	andi	a4,a5,15
    800014f2:	ff3701e3          	beq	a4,s3,800014d4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014f6:	8b85                	andi	a5,a5,1
    800014f8:	d7fd                	beqz	a5,800014e6 <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fa:	00008517          	auipc	a0,0x8
    800014fe:	c7e50513          	addi	a0,a0,-898 # 80009178 <digits+0x138>
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	036080e7          	jalr	54(ra) # 80000538 <panic>
    }
  }
  kfree((void*)pagetable);
    8000150a:	8552                	mv	a0,s4
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	4d4080e7          	jalr	1236(ra) # 800009e0 <kfree>
}
    80001514:	70a2                	ld	ra,40(sp)
    80001516:	7402                	ld	s0,32(sp)
    80001518:	64e2                	ld	s1,24(sp)
    8000151a:	6942                	ld	s2,16(sp)
    8000151c:	69a2                	ld	s3,8(sp)
    8000151e:	6a02                	ld	s4,0(sp)
    80001520:	6145                	addi	sp,sp,48
    80001522:	8082                	ret

0000000080001524 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001524:	1101                	addi	sp,sp,-32
    80001526:	ec06                	sd	ra,24(sp)
    80001528:	e822                	sd	s0,16(sp)
    8000152a:	e426                	sd	s1,8(sp)
    8000152c:	1000                	addi	s0,sp,32
    8000152e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001530:	e999                	bnez	a1,80001546 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001532:	8526                	mv	a0,s1
    80001534:	00000097          	auipc	ra,0x0
    80001538:	f84080e7          	jalr	-124(ra) # 800014b8 <freewalk>
}
    8000153c:	60e2                	ld	ra,24(sp)
    8000153e:	6442                	ld	s0,16(sp)
    80001540:	64a2                	ld	s1,8(sp)
    80001542:	6105                	addi	sp,sp,32
    80001544:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001546:	6785                	lui	a5,0x1
    80001548:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154a:	95be                	add	a1,a1,a5
    8000154c:	4685                	li	a3,1
    8000154e:	00c5d613          	srli	a2,a1,0xc
    80001552:	4581                	li	a1,0
    80001554:	00000097          	auipc	ra,0x0
    80001558:	d0e080e7          	jalr	-754(ra) # 80001262 <uvmunmap>
    8000155c:	bfd9                	j	80001532 <uvmfree+0xe>

000000008000155e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000155e:	c679                	beqz	a2,8000162c <uvmcopy+0xce>
{
    80001560:	715d                	addi	sp,sp,-80
    80001562:	e486                	sd	ra,72(sp)
    80001564:	e0a2                	sd	s0,64(sp)
    80001566:	fc26                	sd	s1,56(sp)
    80001568:	f84a                	sd	s2,48(sp)
    8000156a:	f44e                	sd	s3,40(sp)
    8000156c:	f052                	sd	s4,32(sp)
    8000156e:	ec56                	sd	s5,24(sp)
    80001570:	e85a                	sd	s6,16(sp)
    80001572:	e45e                	sd	s7,8(sp)
    80001574:	0880                	addi	s0,sp,80
    80001576:	8b2a                	mv	s6,a0
    80001578:	8aae                	mv	s5,a1
    8000157a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000157e:	4601                	li	a2,0
    80001580:	85ce                	mv	a1,s3
    80001582:	855a                	mv	a0,s6
    80001584:	00000097          	auipc	ra,0x0
    80001588:	a30080e7          	jalr	-1488(ra) # 80000fb4 <walk>
    8000158c:	c531                	beqz	a0,800015d8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000158e:	6118                	ld	a4,0(a0)
    80001590:	00177793          	andi	a5,a4,1
    80001594:	cbb1                	beqz	a5,800015e8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001596:	00a75593          	srli	a1,a4,0xa
    8000159a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000159e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a2:	fffff097          	auipc	ra,0xfffff
    800015a6:	53c080e7          	jalr	1340(ra) # 80000ade <kalloc>
    800015aa:	892a                	mv	s2,a0
    800015ac:	c939                	beqz	a0,80001602 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	85de                	mv	a1,s7
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	774080e7          	jalr	1908(ra) # 80000d26 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ba:	8726                	mv	a4,s1
    800015bc:	86ca                	mv	a3,s2
    800015be:	6605                	lui	a2,0x1
    800015c0:	85ce                	mv	a1,s3
    800015c2:	8556                	mv	a0,s5
    800015c4:	00000097          	auipc	ra,0x0
    800015c8:	ad8080e7          	jalr	-1320(ra) # 8000109c <mappages>
    800015cc:	e515                	bnez	a0,800015f8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015ce:	6785                	lui	a5,0x1
    800015d0:	99be                	add	s3,s3,a5
    800015d2:	fb49e6e3          	bltu	s3,s4,8000157e <uvmcopy+0x20>
    800015d6:	a081                	j	80001616 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015d8:	00008517          	auipc	a0,0x8
    800015dc:	bb050513          	addi	a0,a0,-1104 # 80009188 <digits+0x148>
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	f58080e7          	jalr	-168(ra) # 80000538 <panic>
      panic("uvmcopy: page not present");
    800015e8:	00008517          	auipc	a0,0x8
    800015ec:	bc050513          	addi	a0,a0,-1088 # 800091a8 <digits+0x168>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f48080e7          	jalr	-184(ra) # 80000538 <panic>
      kfree(mem);
    800015f8:	854a                	mv	a0,s2
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	3e6080e7          	jalr	998(ra) # 800009e0 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001602:	4685                	li	a3,1
    80001604:	00c9d613          	srli	a2,s3,0xc
    80001608:	4581                	li	a1,0
    8000160a:	8556                	mv	a0,s5
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	c56080e7          	jalr	-938(ra) # 80001262 <uvmunmap>
  return -1;
    80001614:	557d                	li	a0,-1
}
    80001616:	60a6                	ld	ra,72(sp)
    80001618:	6406                	ld	s0,64(sp)
    8000161a:	74e2                	ld	s1,56(sp)
    8000161c:	7942                	ld	s2,48(sp)
    8000161e:	79a2                	ld	s3,40(sp)
    80001620:	7a02                	ld	s4,32(sp)
    80001622:	6ae2                	ld	s5,24(sp)
    80001624:	6b42                	ld	s6,16(sp)
    80001626:	6ba2                	ld	s7,8(sp)
    80001628:	6161                	addi	sp,sp,80
    8000162a:	8082                	ret
  return 0;
    8000162c:	4501                	li	a0,0
}
    8000162e:	8082                	ret

0000000080001630 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001630:	1141                	addi	sp,sp,-16
    80001632:	e406                	sd	ra,8(sp)
    80001634:	e022                	sd	s0,0(sp)
    80001636:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001638:	4601                	li	a2,0
    8000163a:	00000097          	auipc	ra,0x0
    8000163e:	97a080e7          	jalr	-1670(ra) # 80000fb4 <walk>
  if(pte == 0)
    80001642:	c901                	beqz	a0,80001652 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001644:	611c                	ld	a5,0(a0)
    80001646:	9bbd                	andi	a5,a5,-17
    80001648:	e11c                	sd	a5,0(a0)
}
    8000164a:	60a2                	ld	ra,8(sp)
    8000164c:	6402                	ld	s0,0(sp)
    8000164e:	0141                	addi	sp,sp,16
    80001650:	8082                	ret
    panic("uvmclear");
    80001652:	00008517          	auipc	a0,0x8
    80001656:	b7650513          	addi	a0,a0,-1162 # 800091c8 <digits+0x188>
    8000165a:	fffff097          	auipc	ra,0xfffff
    8000165e:	ede080e7          	jalr	-290(ra) # 80000538 <panic>

0000000080001662 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001662:	c6bd                	beqz	a3,800016d0 <copyout+0x6e>
{
    80001664:	715d                	addi	sp,sp,-80
    80001666:	e486                	sd	ra,72(sp)
    80001668:	e0a2                	sd	s0,64(sp)
    8000166a:	fc26                	sd	s1,56(sp)
    8000166c:	f84a                	sd	s2,48(sp)
    8000166e:	f44e                	sd	s3,40(sp)
    80001670:	f052                	sd	s4,32(sp)
    80001672:	ec56                	sd	s5,24(sp)
    80001674:	e85a                	sd	s6,16(sp)
    80001676:	e45e                	sd	s7,8(sp)
    80001678:	e062                	sd	s8,0(sp)
    8000167a:	0880                	addi	s0,sp,80
    8000167c:	8b2a                	mv	s6,a0
    8000167e:	8c2e                	mv	s8,a1
    80001680:	8a32                	mv	s4,a2
    80001682:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001684:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001686:	6a85                	lui	s5,0x1
    80001688:	a015                	j	800016ac <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168a:	9562                	add	a0,a0,s8
    8000168c:	0004861b          	sext.w	a2,s1
    80001690:	85d2                	mv	a1,s4
    80001692:	41250533          	sub	a0,a0,s2
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	690080e7          	jalr	1680(ra) # 80000d26 <memmove>

    len -= n;
    8000169e:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016a8:	02098263          	beqz	s3,800016cc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ac:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b0:	85ca                	mv	a1,s2
    800016b2:	855a                	mv	a0,s6
    800016b4:	00000097          	auipc	ra,0x0
    800016b8:	9a6080e7          	jalr	-1626(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    800016bc:	cd01                	beqz	a0,800016d4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016be:	418904b3          	sub	s1,s2,s8
    800016c2:	94d6                	add	s1,s1,s5
    800016c4:	fc99f3e3          	bgeu	s3,s1,8000168a <copyout+0x28>
    800016c8:	84ce                	mv	s1,s3
    800016ca:	b7c1                	j	8000168a <copyout+0x28>
  }
  return 0;
    800016cc:	4501                	li	a0,0
    800016ce:	a021                	j	800016d6 <copyout+0x74>
    800016d0:	4501                	li	a0,0
}
    800016d2:	8082                	ret
      return -1;
    800016d4:	557d                	li	a0,-1
}
    800016d6:	60a6                	ld	ra,72(sp)
    800016d8:	6406                	ld	s0,64(sp)
    800016da:	74e2                	ld	s1,56(sp)
    800016dc:	7942                	ld	s2,48(sp)
    800016de:	79a2                	ld	s3,40(sp)
    800016e0:	7a02                	ld	s4,32(sp)
    800016e2:	6ae2                	ld	s5,24(sp)
    800016e4:	6b42                	ld	s6,16(sp)
    800016e6:	6ba2                	ld	s7,8(sp)
    800016e8:	6c02                	ld	s8,0(sp)
    800016ea:	6161                	addi	sp,sp,80
    800016ec:	8082                	ret

00000000800016ee <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ee:	caa5                	beqz	a3,8000175e <copyin+0x70>
{
    800016f0:	715d                	addi	sp,sp,-80
    800016f2:	e486                	sd	ra,72(sp)
    800016f4:	e0a2                	sd	s0,64(sp)
    800016f6:	fc26                	sd	s1,56(sp)
    800016f8:	f84a                	sd	s2,48(sp)
    800016fa:	f44e                	sd	s3,40(sp)
    800016fc:	f052                	sd	s4,32(sp)
    800016fe:	ec56                	sd	s5,24(sp)
    80001700:	e85a                	sd	s6,16(sp)
    80001702:	e45e                	sd	s7,8(sp)
    80001704:	e062                	sd	s8,0(sp)
    80001706:	0880                	addi	s0,sp,80
    80001708:	8b2a                	mv	s6,a0
    8000170a:	8a2e                	mv	s4,a1
    8000170c:	8c32                	mv	s8,a2
    8000170e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001710:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001712:	6a85                	lui	s5,0x1
    80001714:	a01d                	j	8000173a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001716:	018505b3          	add	a1,a0,s8
    8000171a:	0004861b          	sext.w	a2,s1
    8000171e:	412585b3          	sub	a1,a1,s2
    80001722:	8552                	mv	a0,s4
    80001724:	fffff097          	auipc	ra,0xfffff
    80001728:	602080e7          	jalr	1538(ra) # 80000d26 <memmove>

    len -= n;
    8000172c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001730:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001732:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001736:	02098263          	beqz	s3,8000175a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000173e:	85ca                	mv	a1,s2
    80001740:	855a                	mv	a0,s6
    80001742:	00000097          	auipc	ra,0x0
    80001746:	918080e7          	jalr	-1768(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    8000174a:	cd01                	beqz	a0,80001762 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000174c:	418904b3          	sub	s1,s2,s8
    80001750:	94d6                	add	s1,s1,s5
    80001752:	fc99f2e3          	bgeu	s3,s1,80001716 <copyin+0x28>
    80001756:	84ce                	mv	s1,s3
    80001758:	bf7d                	j	80001716 <copyin+0x28>
  }
  return 0;
    8000175a:	4501                	li	a0,0
    8000175c:	a021                	j	80001764 <copyin+0x76>
    8000175e:	4501                	li	a0,0
}
    80001760:	8082                	ret
      return -1;
    80001762:	557d                	li	a0,-1
}
    80001764:	60a6                	ld	ra,72(sp)
    80001766:	6406                	ld	s0,64(sp)
    80001768:	74e2                	ld	s1,56(sp)
    8000176a:	7942                	ld	s2,48(sp)
    8000176c:	79a2                	ld	s3,40(sp)
    8000176e:	7a02                	ld	s4,32(sp)
    80001770:	6ae2                	ld	s5,24(sp)
    80001772:	6b42                	ld	s6,16(sp)
    80001774:	6ba2                	ld	s7,8(sp)
    80001776:	6c02                	ld	s8,0(sp)
    80001778:	6161                	addi	sp,sp,80
    8000177a:	8082                	ret

000000008000177c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000177c:	c2dd                	beqz	a3,80001822 <copyinstr+0xa6>
{
    8000177e:	715d                	addi	sp,sp,-80
    80001780:	e486                	sd	ra,72(sp)
    80001782:	e0a2                	sd	s0,64(sp)
    80001784:	fc26                	sd	s1,56(sp)
    80001786:	f84a                	sd	s2,48(sp)
    80001788:	f44e                	sd	s3,40(sp)
    8000178a:	f052                	sd	s4,32(sp)
    8000178c:	ec56                	sd	s5,24(sp)
    8000178e:	e85a                	sd	s6,16(sp)
    80001790:	e45e                	sd	s7,8(sp)
    80001792:	0880                	addi	s0,sp,80
    80001794:	8a2a                	mv	s4,a0
    80001796:	8b2e                	mv	s6,a1
    80001798:	8bb2                	mv	s7,a2
    8000179a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000179c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000179e:	6985                	lui	s3,0x1
    800017a0:	a02d                	j	800017ca <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017a6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017a8:	37fd                	addiw	a5,a5,-1
    800017aa:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017ae:	60a6                	ld	ra,72(sp)
    800017b0:	6406                	ld	s0,64(sp)
    800017b2:	74e2                	ld	s1,56(sp)
    800017b4:	7942                	ld	s2,48(sp)
    800017b6:	79a2                	ld	s3,40(sp)
    800017b8:	7a02                	ld	s4,32(sp)
    800017ba:	6ae2                	ld	s5,24(sp)
    800017bc:	6b42                	ld	s6,16(sp)
    800017be:	6ba2                	ld	s7,8(sp)
    800017c0:	6161                	addi	sp,sp,80
    800017c2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017c8:	c8a9                	beqz	s1,8000181a <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ca:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ce:	85ca                	mv	a1,s2
    800017d0:	8552                	mv	a0,s4
    800017d2:	00000097          	auipc	ra,0x0
    800017d6:	888080e7          	jalr	-1912(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    800017da:	c131                	beqz	a0,8000181e <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017dc:	417906b3          	sub	a3,s2,s7
    800017e0:	96ce                	add	a3,a3,s3
    800017e2:	00d4f363          	bgeu	s1,a3,800017e8 <copyinstr+0x6c>
    800017e6:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017e8:	955e                	add	a0,a0,s7
    800017ea:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017ee:	daf9                	beqz	a3,800017c4 <copyinstr+0x48>
    800017f0:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017f2:	41650633          	sub	a2,a0,s6
    800017f6:	fff48593          	addi	a1,s1,-1
    800017fa:	95da                	add	a1,a1,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800017fe:	00f60733          	add	a4,a2,a5
    80001802:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8000>
    80001806:	df51                	beqz	a4,800017a2 <copyinstr+0x26>
        *dst = *p;
    80001808:	00e78023          	sb	a4,0(a5)
      --max;
    8000180c:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001810:	0785                	addi	a5,a5,1
    while(n > 0){
    80001812:	fed796e3          	bne	a5,a3,800017fe <copyinstr+0x82>
      dst++;
    80001816:	8b3e                	mv	s6,a5
    80001818:	b775                	j	800017c4 <copyinstr+0x48>
    8000181a:	4781                	li	a5,0
    8000181c:	b771                	j	800017a8 <copyinstr+0x2c>
      return -1;
    8000181e:	557d                	li	a0,-1
    80001820:	b779                	j	800017ae <copyinstr+0x32>
  int got_null = 0;
    80001822:	4781                	li	a5,0
  if(got_null){
    80001824:	37fd                	addiw	a5,a5,-1
    80001826:	0007851b          	sext.w	a0,a5
}
    8000182a:	8082                	ret

000000008000182c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000182c:	7139                	addi	sp,sp,-64
    8000182e:	fc06                	sd	ra,56(sp)
    80001830:	f822                	sd	s0,48(sp)
    80001832:	f426                	sd	s1,40(sp)
    80001834:	f04a                	sd	s2,32(sp)
    80001836:	ec4e                	sd	s3,24(sp)
    80001838:	e852                	sd	s4,16(sp)
    8000183a:	e456                	sd	s5,8(sp)
    8000183c:	e05a                	sd	s6,0(sp)
    8000183e:	0080                	addi	s0,sp,64
    80001840:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001842:	00011497          	auipc	s1,0x11
    80001846:	ebe48493          	addi	s1,s1,-322 # 80012700 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184a:	8b26                	mv	s6,s1
    8000184c:	00007a97          	auipc	s5,0x7
    80001850:	7b4a8a93          	addi	s5,s5,1972 # 80009000 <etext>
    80001854:	04000937          	lui	s2,0x4000
    80001858:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00017a17          	auipc	s4,0x17
    80001860:	2a4a0a13          	addi	s4,s4,676 # 80018b00 <tickslock>
    char *pa = kalloc();
    80001864:	fffff097          	auipc	ra,0xfffff
    80001868:	27a080e7          	jalr	634(ra) # 80000ade <kalloc>
    8000186c:	862a                	mv	a2,a0
    if(pa == 0)
    8000186e:	c131                	beqz	a0,800018b2 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001870:	416485b3          	sub	a1,s1,s6
    80001874:	8591                	srai	a1,a1,0x4
    80001876:	000ab783          	ld	a5,0(s5)
    8000187a:	02f585b3          	mul	a1,a1,a5
    8000187e:	2585                	addiw	a1,a1,1
    80001880:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001884:	4719                	li	a4,6
    80001886:	6685                	lui	a3,0x1
    80001888:	40b905b3          	sub	a1,s2,a1
    8000188c:	854e                	mv	a0,s3
    8000188e:	00000097          	auipc	ra,0x0
    80001892:	8ae080e7          	jalr	-1874(ra) # 8000113c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001896:	19048493          	addi	s1,s1,400
    8000189a:	fd4495e3          	bne	s1,s4,80001864 <proc_mapstacks+0x38>
  }
}
    8000189e:	70e2                	ld	ra,56(sp)
    800018a0:	7442                	ld	s0,48(sp)
    800018a2:	74a2                	ld	s1,40(sp)
    800018a4:	7902                	ld	s2,32(sp)
    800018a6:	69e2                	ld	s3,24(sp)
    800018a8:	6a42                	ld	s4,16(sp)
    800018aa:	6aa2                	ld	s5,8(sp)
    800018ac:	6b02                	ld	s6,0(sp)
    800018ae:	6121                	addi	sp,sp,64
    800018b0:	8082                	ret
      panic("kalloc");
    800018b2:	00008517          	auipc	a0,0x8
    800018b6:	92650513          	addi	a0,a0,-1754 # 800091d8 <digits+0x198>
    800018ba:	fffff097          	auipc	ra,0xfffff
    800018be:	c7e080e7          	jalr	-898(ra) # 80000538 <panic>

00000000800018c2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018c2:	7139                	addi	sp,sp,-64
    800018c4:	fc06                	sd	ra,56(sp)
    800018c6:	f822                	sd	s0,48(sp)
    800018c8:	f426                	sd	s1,40(sp)
    800018ca:	f04a                	sd	s2,32(sp)
    800018cc:	ec4e                	sd	s3,24(sp)
    800018ce:	e852                	sd	s4,16(sp)
    800018d0:	e456                	sd	s5,8(sp)
    800018d2:	e05a                	sd	s6,0(sp)
    800018d4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018d6:	00008597          	auipc	a1,0x8
    800018da:	90a58593          	addi	a1,a1,-1782 # 800091e0 <digits+0x1a0>
    800018de:	00011517          	auipc	a0,0x11
    800018e2:	9f250513          	addi	a0,a0,-1550 # 800122d0 <pid_lock>
    800018e6:	fffff097          	auipc	ra,0xfffff
    800018ea:	258080e7          	jalr	600(ra) # 80000b3e <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ee:	00008597          	auipc	a1,0x8
    800018f2:	8fa58593          	addi	a1,a1,-1798 # 800091e8 <digits+0x1a8>
    800018f6:	00011517          	auipc	a0,0x11
    800018fa:	9f250513          	addi	a0,a0,-1550 # 800122e8 <wait_lock>
    800018fe:	fffff097          	auipc	ra,0xfffff
    80001902:	240080e7          	jalr	576(ra) # 80000b3e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001906:	00011497          	auipc	s1,0x11
    8000190a:	dfa48493          	addi	s1,s1,-518 # 80012700 <proc>
      initlock(&p->lock, "proc");
    8000190e:	00008b17          	auipc	s6,0x8
    80001912:	8eab0b13          	addi	s6,s6,-1814 # 800091f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001916:	8aa6                	mv	s5,s1
    80001918:	00007a17          	auipc	s4,0x7
    8000191c:	6e8a0a13          	addi	s4,s4,1768 # 80009000 <etext>
    80001920:	04000937          	lui	s2,0x4000
    80001924:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001926:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001928:	00017997          	auipc	s3,0x17
    8000192c:	1d898993          	addi	s3,s3,472 # 80018b00 <tickslock>
      initlock(&p->lock, "proc");
    80001930:	85da                	mv	a1,s6
    80001932:	8526                	mv	a0,s1
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	20a080e7          	jalr	522(ra) # 80000b3e <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000193c:	415487b3          	sub	a5,s1,s5
    80001940:	8791                	srai	a5,a5,0x4
    80001942:	000a3703          	ld	a4,0(s4)
    80001946:	02e787b3          	mul	a5,a5,a4
    8000194a:	2785                	addiw	a5,a5,1
    8000194c:	00d7979b          	slliw	a5,a5,0xd
    80001950:	40f907b3          	sub	a5,s2,a5
    80001954:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001956:	19048493          	addi	s1,s1,400
    8000195a:	fd349be3          	bne	s1,s3,80001930 <procinit+0x6e>
  }
}
    8000195e:	70e2                	ld	ra,56(sp)
    80001960:	7442                	ld	s0,48(sp)
    80001962:	74a2                	ld	s1,40(sp)
    80001964:	7902                	ld	s2,32(sp)
    80001966:	69e2                	ld	s3,24(sp)
    80001968:	6a42                	ld	s4,16(sp)
    8000196a:	6aa2                	ld	s5,8(sp)
    8000196c:	6b02                	ld	s6,0(sp)
    8000196e:	6121                	addi	sp,sp,64
    80001970:	8082                	ret

0000000080001972 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001972:	1141                	addi	sp,sp,-16
    80001974:	e422                	sd	s0,8(sp)
    80001976:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001978:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000197a:	2501                	sext.w	a0,a0
    8000197c:	6422                	ld	s0,8(sp)
    8000197e:	0141                	addi	sp,sp,16
    80001980:	8082                	ret

0000000080001982 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001982:	1141                	addi	sp,sp,-16
    80001984:	e422                	sd	s0,8(sp)
    80001986:	0800                	addi	s0,sp,16
    80001988:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000198a:	2781                	sext.w	a5,a5
    8000198c:	079e                	slli	a5,a5,0x7
  return c;
}
    8000198e:	00011517          	auipc	a0,0x11
    80001992:	97250513          	addi	a0,a0,-1678 # 80012300 <cpus>
    80001996:	953e                	add	a0,a0,a5
    80001998:	6422                	ld	s0,8(sp)
    8000199a:	0141                	addi	sp,sp,16
    8000199c:	8082                	ret

000000008000199e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    8000199e:	1101                	addi	sp,sp,-32
    800019a0:	ec06                	sd	ra,24(sp)
    800019a2:	e822                	sd	s0,16(sp)
    800019a4:	e426                	sd	s1,8(sp)
    800019a6:	1000                	addi	s0,sp,32
  push_off();
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	1da080e7          	jalr	474(ra) # 80000b82 <push_off>
    800019b0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019b2:	2781                	sext.w	a5,a5
    800019b4:	079e                	slli	a5,a5,0x7
    800019b6:	00011717          	auipc	a4,0x11
    800019ba:	91a70713          	addi	a4,a4,-1766 # 800122d0 <pid_lock>
    800019be:	97ba                	add	a5,a5,a4
    800019c0:	7b84                	ld	s1,48(a5)
  pop_off();
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	260080e7          	jalr	608(ra) # 80000c22 <pop_off>
  return p;
}
    800019ca:	8526                	mv	a0,s1
    800019cc:	60e2                	ld	ra,24(sp)
    800019ce:	6442                	ld	s0,16(sp)
    800019d0:	64a2                	ld	s1,8(sp)
    800019d2:	6105                	addi	sp,sp,32
    800019d4:	8082                	ret

00000000800019d6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019d6:	1101                	addi	sp,sp,-32
    800019d8:	ec06                	sd	ra,24(sp)
    800019da:	e822                	sd	s0,16(sp)
    800019dc:	e426                	sd	s1,8(sp)
    800019de:	1000                	addi	s0,sp,32
  static int first = 1;
  uint xticks;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e0:	00000097          	auipc	ra,0x0
    800019e4:	fbe080e7          	jalr	-66(ra) # 8000199e <myproc>
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	29a080e7          	jalr	666(ra) # 80000c82 <release>

  acquire(&tickslock);
    800019f0:	00017517          	auipc	a0,0x17
    800019f4:	11050513          	addi	a0,a0,272 # 80018b00 <tickslock>
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	1d6080e7          	jalr	470(ra) # 80000bce <acquire>
  xticks = ticks;
    80001a00:	00008497          	auipc	s1,0x8
    80001a04:	66c4a483          	lw	s1,1644(s1) # 8000a06c <ticks>
  release(&tickslock);
    80001a08:	00017517          	auipc	a0,0x17
    80001a0c:	0f850513          	addi	a0,a0,248 # 80018b00 <tickslock>
    80001a10:	fffff097          	auipc	ra,0xfffff
    80001a14:	272080e7          	jalr	626(ra) # 80000c82 <release>

  myproc()->stime = xticks;
    80001a18:	00000097          	auipc	ra,0x0
    80001a1c:	f86080e7          	jalr	-122(ra) # 8000199e <myproc>
    80001a20:	16952a23          	sw	s1,372(a0)

  if (first) {
    80001a24:	00008797          	auipc	a5,0x8
    80001a28:	04c7a783          	lw	a5,76(a5) # 80009a70 <first.3>
    80001a2c:	eb91                	bnez	a5,80001a40 <forkret+0x6a>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a2e:	00002097          	auipc	ra,0x2
    80001a32:	c50080e7          	jalr	-944(ra) # 8000367e <usertrapret>
}
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6105                	addi	sp,sp,32
    80001a3e:	8082                	ret
    first = 0;
    80001a40:	00008797          	auipc	a5,0x8
    80001a44:	0207a823          	sw	zero,48(a5) # 80009a70 <first.3>
    fsinit(ROOTDEV);
    80001a48:	4505                	li	a0,1
    80001a4a:	00003097          	auipc	ra,0x3
    80001a4e:	ba4080e7          	jalr	-1116(ra) # 800045ee <fsinit>
    80001a52:	bff1                	j	80001a2e <forkret+0x58>

0000000080001a54 <allocpid>:
allocpid() {
    80001a54:	1101                	addi	sp,sp,-32
    80001a56:	ec06                	sd	ra,24(sp)
    80001a58:	e822                	sd	s0,16(sp)
    80001a5a:	e426                	sd	s1,8(sp)
    80001a5c:	e04a                	sd	s2,0(sp)
    80001a5e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a60:	00011917          	auipc	s2,0x11
    80001a64:	87090913          	addi	s2,s2,-1936 # 800122d0 <pid_lock>
    80001a68:	854a                	mv	a0,s2
    80001a6a:	fffff097          	auipc	ra,0xfffff
    80001a6e:	164080e7          	jalr	356(ra) # 80000bce <acquire>
  pid = nextpid;
    80001a72:	00008797          	auipc	a5,0x8
    80001a76:	01278793          	addi	a5,a5,18 # 80009a84 <nextpid>
    80001a7a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a7c:	0014871b          	addiw	a4,s1,1
    80001a80:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a82:	854a                	mv	a0,s2
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	1fe080e7          	jalr	510(ra) # 80000c82 <release>
}
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	60e2                	ld	ra,24(sp)
    80001a90:	6442                	ld	s0,16(sp)
    80001a92:	64a2                	ld	s1,8(sp)
    80001a94:	6902                	ld	s2,0(sp)
    80001a96:	6105                	addi	sp,sp,32
    80001a98:	8082                	ret

0000000080001a9a <proc_pagetable>:
{
    80001a9a:	1101                	addi	sp,sp,-32
    80001a9c:	ec06                	sd	ra,24(sp)
    80001a9e:	e822                	sd	s0,16(sp)
    80001aa0:	e426                	sd	s1,8(sp)
    80001aa2:	e04a                	sd	s2,0(sp)
    80001aa4:	1000                	addi	s0,sp,32
    80001aa6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aa8:	00000097          	auipc	ra,0x0
    80001aac:	87e080e7          	jalr	-1922(ra) # 80001326 <uvmcreate>
    80001ab0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ab2:	c121                	beqz	a0,80001af2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ab4:	4729                	li	a4,10
    80001ab6:	00006697          	auipc	a3,0x6
    80001aba:	54a68693          	addi	a3,a3,1354 # 80008000 <_trampoline>
    80001abe:	6605                	lui	a2,0x1
    80001ac0:	040005b7          	lui	a1,0x4000
    80001ac4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ac6:	05b2                	slli	a1,a1,0xc
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	5d4080e7          	jalr	1492(ra) # 8000109c <mappages>
    80001ad0:	02054863          	bltz	a0,80001b00 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ad4:	4719                	li	a4,6
    80001ad6:	06093683          	ld	a3,96(s2)
    80001ada:	6605                	lui	a2,0x1
    80001adc:	020005b7          	lui	a1,0x2000
    80001ae0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ae2:	05b6                	slli	a1,a1,0xd
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	fffff097          	auipc	ra,0xfffff
    80001aea:	5b6080e7          	jalr	1462(ra) # 8000109c <mappages>
    80001aee:	02054163          	bltz	a0,80001b10 <proc_pagetable+0x76>
}
    80001af2:	8526                	mv	a0,s1
    80001af4:	60e2                	ld	ra,24(sp)
    80001af6:	6442                	ld	s0,16(sp)
    80001af8:	64a2                	ld	s1,8(sp)
    80001afa:	6902                	ld	s2,0(sp)
    80001afc:	6105                	addi	sp,sp,32
    80001afe:	8082                	ret
    uvmfree(pagetable, 0);
    80001b00:	4581                	li	a1,0
    80001b02:	8526                	mv	a0,s1
    80001b04:	00000097          	auipc	ra,0x0
    80001b08:	a20080e7          	jalr	-1504(ra) # 80001524 <uvmfree>
    return 0;
    80001b0c:	4481                	li	s1,0
    80001b0e:	b7d5                	j	80001af2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b10:	4681                	li	a3,0
    80001b12:	4605                	li	a2,1
    80001b14:	040005b7          	lui	a1,0x4000
    80001b18:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b1a:	05b2                	slli	a1,a1,0xc
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	fffff097          	auipc	ra,0xfffff
    80001b22:	744080e7          	jalr	1860(ra) # 80001262 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b26:	4581                	li	a1,0
    80001b28:	8526                	mv	a0,s1
    80001b2a:	00000097          	auipc	ra,0x0
    80001b2e:	9fa080e7          	jalr	-1542(ra) # 80001524 <uvmfree>
    return 0;
    80001b32:	4481                	li	s1,0
    80001b34:	bf7d                	j	80001af2 <proc_pagetable+0x58>

0000000080001b36 <proc_freepagetable>:
{
    80001b36:	1101                	addi	sp,sp,-32
    80001b38:	ec06                	sd	ra,24(sp)
    80001b3a:	e822                	sd	s0,16(sp)
    80001b3c:	e426                	sd	s1,8(sp)
    80001b3e:	e04a                	sd	s2,0(sp)
    80001b40:	1000                	addi	s0,sp,32
    80001b42:	84aa                	mv	s1,a0
    80001b44:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b46:	4681                	li	a3,0
    80001b48:	4605                	li	a2,1
    80001b4a:	040005b7          	lui	a1,0x4000
    80001b4e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b50:	05b2                	slli	a1,a1,0xc
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	710080e7          	jalr	1808(ra) # 80001262 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b5a:	4681                	li	a3,0
    80001b5c:	4605                	li	a2,1
    80001b5e:	020005b7          	lui	a1,0x2000
    80001b62:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b64:	05b6                	slli	a1,a1,0xd
    80001b66:	8526                	mv	a0,s1
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	6fa080e7          	jalr	1786(ra) # 80001262 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b70:	85ca                	mv	a1,s2
    80001b72:	8526                	mv	a0,s1
    80001b74:	00000097          	auipc	ra,0x0
    80001b78:	9b0080e7          	jalr	-1616(ra) # 80001524 <uvmfree>
}
    80001b7c:	60e2                	ld	ra,24(sp)
    80001b7e:	6442                	ld	s0,16(sp)
    80001b80:	64a2                	ld	s1,8(sp)
    80001b82:	6902                	ld	s2,0(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <freeproc>:
{
    80001b88:	1101                	addi	sp,sp,-32
    80001b8a:	ec06                	sd	ra,24(sp)
    80001b8c:	e822                	sd	s0,16(sp)
    80001b8e:	e426                	sd	s1,8(sp)
    80001b90:	1000                	addi	s0,sp,32
    80001b92:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b94:	7128                	ld	a0,96(a0)
    80001b96:	c509                	beqz	a0,80001ba0 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	e48080e7          	jalr	-440(ra) # 800009e0 <kfree>
  p->trapframe = 0;
    80001ba0:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001ba4:	6ca8                	ld	a0,88(s1)
    80001ba6:	c511                	beqz	a0,80001bb2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ba8:	68ac                	ld	a1,80(s1)
    80001baa:	00000097          	auipc	ra,0x0
    80001bae:	f8c080e7          	jalr	-116(ra) # 80001b36 <proc_freepagetable>
  p->pagetable = 0;
    80001bb2:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001bb6:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001bba:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bbe:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001bc2:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001bc6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bca:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bce:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bd2:	0004ac23          	sw	zero,24(s1)
}
    80001bd6:	60e2                	ld	ra,24(sp)
    80001bd8:	6442                	ld	s0,16(sp)
    80001bda:	64a2                	ld	s1,8(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret

0000000080001be0 <allocproc>:
{
    80001be0:	1101                	addi	sp,sp,-32
    80001be2:	ec06                	sd	ra,24(sp)
    80001be4:	e822                	sd	s0,16(sp)
    80001be6:	e426                	sd	s1,8(sp)
    80001be8:	e04a                	sd	s2,0(sp)
    80001bea:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bec:	00011497          	auipc	s1,0x11
    80001bf0:	b1448493          	addi	s1,s1,-1260 # 80012700 <proc>
    80001bf4:	00017917          	auipc	s2,0x17
    80001bf8:	f0c90913          	addi	s2,s2,-244 # 80018b00 <tickslock>
    acquire(&p->lock);
    80001bfc:	8526                	mv	a0,s1
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	fd0080e7          	jalr	-48(ra) # 80000bce <acquire>
    if(p->state == UNUSED) {
    80001c06:	4c9c                	lw	a5,24(s1)
    80001c08:	cf81                	beqz	a5,80001c20 <allocproc+0x40>
      release(&p->lock);
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	076080e7          	jalr	118(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c14:	19048493          	addi	s1,s1,400
    80001c18:	ff2492e3          	bne	s1,s2,80001bfc <allocproc+0x1c>
  return 0;
    80001c1c:	4481                	li	s1,0
    80001c1e:	a841                	j	80001cae <allocproc+0xce>
  p->pid = allocpid();
    80001c20:	00000097          	auipc	ra,0x0
    80001c24:	e34080e7          	jalr	-460(ra) # 80001a54 <allocpid>
    80001c28:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c2a:	4785                	li	a5,1
    80001c2c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	eb0080e7          	jalr	-336(ra) # 80000ade <kalloc>
    80001c36:	892a                	mv	s2,a0
    80001c38:	f0a8                	sd	a0,96(s1)
    80001c3a:	c149                	beqz	a0,80001cbc <allocproc+0xdc>
  p->pagetable = proc_pagetable(p);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	00000097          	auipc	ra,0x0
    80001c42:	e5c080e7          	jalr	-420(ra) # 80001a9a <proc_pagetable>
    80001c46:	892a                	mv	s2,a0
    80001c48:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001c4a:	c549                	beqz	a0,80001cd4 <allocproc+0xf4>
  memset(&p->context, 0, sizeof(p->context));
    80001c4c:	07000613          	li	a2,112
    80001c50:	4581                	li	a1,0
    80001c52:	06848513          	addi	a0,s1,104
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	074080e7          	jalr	116(ra) # 80000cca <memset>
  p->context.ra = (uint64)forkret;
    80001c5e:	00000797          	auipc	a5,0x0
    80001c62:	d7878793          	addi	a5,a5,-648 # 800019d6 <forkret>
    80001c66:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c68:	64bc                	ld	a5,72(s1)
    80001c6a:	6705                	lui	a4,0x1
    80001c6c:	97ba                	add	a5,a5,a4
    80001c6e:	f8bc                	sd	a5,112(s1)
  acquire(&tickslock);
    80001c70:	00017517          	auipc	a0,0x17
    80001c74:	e9050513          	addi	a0,a0,-368 # 80018b00 <tickslock>
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	f56080e7          	jalr	-170(ra) # 80000bce <acquire>
  xticks = ticks;
    80001c80:	00008917          	auipc	s2,0x8
    80001c84:	3ec92903          	lw	s2,1004(s2) # 8000a06c <ticks>
  release(&tickslock);
    80001c88:	00017517          	auipc	a0,0x17
    80001c8c:	e7850513          	addi	a0,a0,-392 # 80018b00 <tickslock>
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	ff2080e7          	jalr	-14(ra) # 80000c82 <release>
  p->ctime = xticks;
    80001c98:	1724a823          	sw	s2,368(s1)
  p->stime = -1;
    80001c9c:	57fd                	li	a5,-1
    80001c9e:	16f4aa23          	sw	a5,372(s1)
  p->endtime = -1;
    80001ca2:	16f4ac23          	sw	a5,376(s1)
  p->is_batchproc = 0;
    80001ca6:	0204ae23          	sw	zero,60(s1)
  p->cpu_usage = 0;
    80001caa:	1804a623          	sw	zero,396(s1)
}
    80001cae:	8526                	mv	a0,s1
    80001cb0:	60e2                	ld	ra,24(sp)
    80001cb2:	6442                	ld	s0,16(sp)
    80001cb4:	64a2                	ld	s1,8(sp)
    80001cb6:	6902                	ld	s2,0(sp)
    80001cb8:	6105                	addi	sp,sp,32
    80001cba:	8082                	ret
    freeproc(p);
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	00000097          	auipc	ra,0x0
    80001cc2:	eca080e7          	jalr	-310(ra) # 80001b88 <freeproc>
    release(&p->lock);
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	fba080e7          	jalr	-70(ra) # 80000c82 <release>
    return 0;
    80001cd0:	84ca                	mv	s1,s2
    80001cd2:	bff1                	j	80001cae <allocproc+0xce>
    freeproc(p);
    80001cd4:	8526                	mv	a0,s1
    80001cd6:	00000097          	auipc	ra,0x0
    80001cda:	eb2080e7          	jalr	-334(ra) # 80001b88 <freeproc>
    release(&p->lock);
    80001cde:	8526                	mv	a0,s1
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	fa2080e7          	jalr	-94(ra) # 80000c82 <release>
    return 0;
    80001ce8:	84ca                	mv	s1,s2
    80001cea:	b7d1                	j	80001cae <allocproc+0xce>

0000000080001cec <userinit>:
{
    80001cec:	1101                	addi	sp,sp,-32
    80001cee:	ec06                	sd	ra,24(sp)
    80001cf0:	e822                	sd	s0,16(sp)
    80001cf2:	e426                	sd	s1,8(sp)
    80001cf4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cf6:	00000097          	auipc	ra,0x0
    80001cfa:	eea080e7          	jalr	-278(ra) # 80001be0 <allocproc>
    80001cfe:	84aa                	mv	s1,a0
  initproc = p;
    80001d00:	00008797          	auipc	a5,0x8
    80001d04:	36a7b023          	sd	a0,864(a5) # 8000a060 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d08:	03400613          	li	a2,52
    80001d0c:	00008597          	auipc	a1,0x8
    80001d10:	d8458593          	addi	a1,a1,-636 # 80009a90 <initcode>
    80001d14:	6d28                	ld	a0,88(a0)
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	63e080e7          	jalr	1598(ra) # 80001354 <uvminit>
  p->sz = PGSIZE;
    80001d1e:	6785                	lui	a5,0x1
    80001d20:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d22:	70b8                	ld	a4,96(s1)
    80001d24:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d28:	70b8                	ld	a4,96(s1)
    80001d2a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d2c:	4641                	li	a2,16
    80001d2e:	00007597          	auipc	a1,0x7
    80001d32:	4d258593          	addi	a1,a1,1234 # 80009200 <digits+0x1c0>
    80001d36:	16048513          	addi	a0,s1,352
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	0da080e7          	jalr	218(ra) # 80000e14 <safestrcpy>
  p->cwd = namei("/");
    80001d42:	00007517          	auipc	a0,0x7
    80001d46:	4ce50513          	addi	a0,a0,1230 # 80009210 <digits+0x1d0>
    80001d4a:	00003097          	auipc	ra,0x3
    80001d4e:	2da080e7          	jalr	730(ra) # 80005024 <namei>
    80001d52:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d56:	478d                	li	a5,3
    80001d58:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d5a:	8526                	mv	a0,s1
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	f26080e7          	jalr	-218(ra) # 80000c82 <release>
}
    80001d64:	60e2                	ld	ra,24(sp)
    80001d66:	6442                	ld	s0,16(sp)
    80001d68:	64a2                	ld	s1,8(sp)
    80001d6a:	6105                	addi	sp,sp,32
    80001d6c:	8082                	ret

0000000080001d6e <growproc>:
{
    80001d6e:	1101                	addi	sp,sp,-32
    80001d70:	ec06                	sd	ra,24(sp)
    80001d72:	e822                	sd	s0,16(sp)
    80001d74:	e426                	sd	s1,8(sp)
    80001d76:	e04a                	sd	s2,0(sp)
    80001d78:	1000                	addi	s0,sp,32
    80001d7a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	c22080e7          	jalr	-990(ra) # 8000199e <myproc>
    80001d84:	892a                	mv	s2,a0
  sz = p->sz;
    80001d86:	692c                	ld	a1,80(a0)
    80001d88:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d8c:	00904f63          	bgtz	s1,80001daa <growproc+0x3c>
  } else if(n < 0){
    80001d90:	0204cd63          	bltz	s1,80001dca <growproc+0x5c>
  p->sz = sz;
    80001d94:	1782                	slli	a5,a5,0x20
    80001d96:	9381                	srli	a5,a5,0x20
    80001d98:	04f93823          	sd	a5,80(s2)
  return 0;
    80001d9c:	4501                	li	a0,0
}
    80001d9e:	60e2                	ld	ra,24(sp)
    80001da0:	6442                	ld	s0,16(sp)
    80001da2:	64a2                	ld	s1,8(sp)
    80001da4:	6902                	ld	s2,0(sp)
    80001da6:	6105                	addi	sp,sp,32
    80001da8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001daa:	00f4863b          	addw	a2,s1,a5
    80001dae:	1602                	slli	a2,a2,0x20
    80001db0:	9201                	srli	a2,a2,0x20
    80001db2:	1582                	slli	a1,a1,0x20
    80001db4:	9181                	srli	a1,a1,0x20
    80001db6:	6d28                	ld	a0,88(a0)
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	656080e7          	jalr	1622(ra) # 8000140e <uvmalloc>
    80001dc0:	0005079b          	sext.w	a5,a0
    80001dc4:	fbe1                	bnez	a5,80001d94 <growproc+0x26>
      return -1;
    80001dc6:	557d                	li	a0,-1
    80001dc8:	bfd9                	j	80001d9e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dca:	00f4863b          	addw	a2,s1,a5
    80001dce:	1602                	slli	a2,a2,0x20
    80001dd0:	9201                	srli	a2,a2,0x20
    80001dd2:	1582                	slli	a1,a1,0x20
    80001dd4:	9181                	srli	a1,a1,0x20
    80001dd6:	6d28                	ld	a0,88(a0)
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	5ee080e7          	jalr	1518(ra) # 800013c6 <uvmdealloc>
    80001de0:	0005079b          	sext.w	a5,a0
    80001de4:	bf45                	j	80001d94 <growproc+0x26>

0000000080001de6 <fork>:
{
    80001de6:	7139                	addi	sp,sp,-64
    80001de8:	fc06                	sd	ra,56(sp)
    80001dea:	f822                	sd	s0,48(sp)
    80001dec:	f426                	sd	s1,40(sp)
    80001dee:	f04a                	sd	s2,32(sp)
    80001df0:	ec4e                	sd	s3,24(sp)
    80001df2:	e852                	sd	s4,16(sp)
    80001df4:	e456                	sd	s5,8(sp)
    80001df6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	ba6080e7          	jalr	-1114(ra) # 8000199e <myproc>
    80001e00:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	dde080e7          	jalr	-546(ra) # 80001be0 <allocproc>
    80001e0a:	10050c63          	beqz	a0,80001f22 <fork+0x13c>
    80001e0e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e10:	050ab603          	ld	a2,80(s5)
    80001e14:	6d2c                	ld	a1,88(a0)
    80001e16:	058ab503          	ld	a0,88(s5)
    80001e1a:	fffff097          	auipc	ra,0xfffff
    80001e1e:	744080e7          	jalr	1860(ra) # 8000155e <uvmcopy>
    80001e22:	04054863          	bltz	a0,80001e72 <fork+0x8c>
  np->sz = p->sz;
    80001e26:	050ab783          	ld	a5,80(s5)
    80001e2a:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e2e:	060ab683          	ld	a3,96(s5)
    80001e32:	87b6                	mv	a5,a3
    80001e34:	060a3703          	ld	a4,96(s4)
    80001e38:	12068693          	addi	a3,a3,288
    80001e3c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e40:	6788                	ld	a0,8(a5)
    80001e42:	6b8c                	ld	a1,16(a5)
    80001e44:	6f90                	ld	a2,24(a5)
    80001e46:	01073023          	sd	a6,0(a4)
    80001e4a:	e708                	sd	a0,8(a4)
    80001e4c:	eb0c                	sd	a1,16(a4)
    80001e4e:	ef10                	sd	a2,24(a4)
    80001e50:	02078793          	addi	a5,a5,32
    80001e54:	02070713          	addi	a4,a4,32
    80001e58:	fed792e3          	bne	a5,a3,80001e3c <fork+0x56>
  np->trapframe->a0 = 0;
    80001e5c:	060a3783          	ld	a5,96(s4)
    80001e60:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e64:	0d8a8493          	addi	s1,s5,216
    80001e68:	0d8a0913          	addi	s2,s4,216
    80001e6c:	158a8993          	addi	s3,s5,344
    80001e70:	a00d                	j	80001e92 <fork+0xac>
    freeproc(np);
    80001e72:	8552                	mv	a0,s4
    80001e74:	00000097          	auipc	ra,0x0
    80001e78:	d14080e7          	jalr	-748(ra) # 80001b88 <freeproc>
    release(&np->lock);
    80001e7c:	8552                	mv	a0,s4
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	e04080e7          	jalr	-508(ra) # 80000c82 <release>
    return -1;
    80001e86:	597d                	li	s2,-1
    80001e88:	a059                	j	80001f0e <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e8a:	04a1                	addi	s1,s1,8
    80001e8c:	0921                	addi	s2,s2,8
    80001e8e:	01348b63          	beq	s1,s3,80001ea4 <fork+0xbe>
    if(p->ofile[i])
    80001e92:	6088                	ld	a0,0(s1)
    80001e94:	d97d                	beqz	a0,80001e8a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e96:	00004097          	auipc	ra,0x4
    80001e9a:	824080e7          	jalr	-2012(ra) # 800056ba <filedup>
    80001e9e:	00a93023          	sd	a0,0(s2)
    80001ea2:	b7e5                	j	80001e8a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ea4:	158ab503          	ld	a0,344(s5)
    80001ea8:	00003097          	auipc	ra,0x3
    80001eac:	982080e7          	jalr	-1662(ra) # 8000482a <idup>
    80001eb0:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eb4:	4641                	li	a2,16
    80001eb6:	160a8593          	addi	a1,s5,352
    80001eba:	160a0513          	addi	a0,s4,352
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	f56080e7          	jalr	-170(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    80001ec6:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001eca:	8552                	mv	a0,s4
    80001ecc:	fffff097          	auipc	ra,0xfffff
    80001ed0:	db6080e7          	jalr	-586(ra) # 80000c82 <release>
  acquire(&wait_lock);
    80001ed4:	00010497          	auipc	s1,0x10
    80001ed8:	41448493          	addi	s1,s1,1044 # 800122e8 <wait_lock>
    80001edc:	8526                	mv	a0,s1
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	cf0080e7          	jalr	-784(ra) # 80000bce <acquire>
  np->parent = p;
    80001ee6:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001eea:	8526                	mv	a0,s1
    80001eec:	fffff097          	auipc	ra,0xfffff
    80001ef0:	d96080e7          	jalr	-618(ra) # 80000c82 <release>
  acquire(&np->lock);
    80001ef4:	8552                	mv	a0,s4
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	cd8080e7          	jalr	-808(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    80001efe:	478d                	li	a5,3
    80001f00:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f04:	8552                	mv	a0,s4
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d7c080e7          	jalr	-644(ra) # 80000c82 <release>
}
    80001f0e:	854a                	mv	a0,s2
    80001f10:	70e2                	ld	ra,56(sp)
    80001f12:	7442                	ld	s0,48(sp)
    80001f14:	74a2                	ld	s1,40(sp)
    80001f16:	7902                	ld	s2,32(sp)
    80001f18:	69e2                	ld	s3,24(sp)
    80001f1a:	6a42                	ld	s4,16(sp)
    80001f1c:	6aa2                	ld	s5,8(sp)
    80001f1e:	6121                	addi	sp,sp,64
    80001f20:	8082                	ret
    return -1;
    80001f22:	597d                	li	s2,-1
    80001f24:	b7ed                	j	80001f0e <fork+0x128>

0000000080001f26 <forkf>:
{
    80001f26:	7139                	addi	sp,sp,-64
    80001f28:	fc06                	sd	ra,56(sp)
    80001f2a:	f822                	sd	s0,48(sp)
    80001f2c:	f426                	sd	s1,40(sp)
    80001f2e:	f04a                	sd	s2,32(sp)
    80001f30:	ec4e                	sd	s3,24(sp)
    80001f32:	e852                	sd	s4,16(sp)
    80001f34:	e456                	sd	s5,8(sp)
    80001f36:	0080                	addi	s0,sp,64
    80001f38:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f3a:	00000097          	auipc	ra,0x0
    80001f3e:	a64080e7          	jalr	-1436(ra) # 8000199e <myproc>
    80001f42:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f44:	00000097          	auipc	ra,0x0
    80001f48:	c9c080e7          	jalr	-868(ra) # 80001be0 <allocproc>
    80001f4c:	12050163          	beqz	a0,8000206e <forkf+0x148>
    80001f50:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f52:	050ab603          	ld	a2,80(s5)
    80001f56:	6d2c                	ld	a1,88(a0)
    80001f58:	058ab503          	ld	a0,88(s5)
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	602080e7          	jalr	1538(ra) # 8000155e <uvmcopy>
    80001f64:	04054d63          	bltz	a0,80001fbe <forkf+0x98>
  np->sz = p->sz;
    80001f68:	050ab783          	ld	a5,80(s5)
    80001f6c:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f70:	060ab683          	ld	a3,96(s5)
    80001f74:	87b6                	mv	a5,a3
    80001f76:	0609b703          	ld	a4,96(s3)
    80001f7a:	12068693          	addi	a3,a3,288
    80001f7e:	0007b883          	ld	a7,0(a5)
    80001f82:	0087b803          	ld	a6,8(a5)
    80001f86:	6b8c                	ld	a1,16(a5)
    80001f88:	6f90                	ld	a2,24(a5)
    80001f8a:	01173023          	sd	a7,0(a4)
    80001f8e:	01073423          	sd	a6,8(a4)
    80001f92:	eb0c                	sd	a1,16(a4)
    80001f94:	ef10                	sd	a2,24(a4)
    80001f96:	02078793          	addi	a5,a5,32
    80001f9a:	02070713          	addi	a4,a4,32
    80001f9e:	fed790e3          	bne	a5,a3,80001f7e <forkf+0x58>
  np->trapframe->a0 = 0;
    80001fa2:	0609b783          	ld	a5,96(s3)
    80001fa6:	0607b823          	sd	zero,112(a5)
  np->trapframe->epc = faddr;
    80001faa:	0609b783          	ld	a5,96(s3)
    80001fae:	ef84                	sd	s1,24(a5)
  for(i = 0; i < NOFILE; i++)
    80001fb0:	0d8a8493          	addi	s1,s5,216
    80001fb4:	0d898913          	addi	s2,s3,216
    80001fb8:	158a8a13          	addi	s4,s5,344
    80001fbc:	a00d                	j	80001fde <forkf+0xb8>
    freeproc(np);
    80001fbe:	854e                	mv	a0,s3
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	bc8080e7          	jalr	-1080(ra) # 80001b88 <freeproc>
    release(&np->lock);
    80001fc8:	854e                	mv	a0,s3
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	cb8080e7          	jalr	-840(ra) # 80000c82 <release>
    return -1;
    80001fd2:	597d                	li	s2,-1
    80001fd4:	a059                	j	8000205a <forkf+0x134>
  for(i = 0; i < NOFILE; i++)
    80001fd6:	04a1                	addi	s1,s1,8
    80001fd8:	0921                	addi	s2,s2,8
    80001fda:	01448b63          	beq	s1,s4,80001ff0 <forkf+0xca>
    if(p->ofile[i])
    80001fde:	6088                	ld	a0,0(s1)
    80001fe0:	d97d                	beqz	a0,80001fd6 <forkf+0xb0>
      np->ofile[i] = filedup(p->ofile[i]);
    80001fe2:	00003097          	auipc	ra,0x3
    80001fe6:	6d8080e7          	jalr	1752(ra) # 800056ba <filedup>
    80001fea:	00a93023          	sd	a0,0(s2)
    80001fee:	b7e5                	j	80001fd6 <forkf+0xb0>
  np->cwd = idup(p->cwd);
    80001ff0:	158ab503          	ld	a0,344(s5)
    80001ff4:	00003097          	auipc	ra,0x3
    80001ff8:	836080e7          	jalr	-1994(ra) # 8000482a <idup>
    80001ffc:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002000:	4641                	li	a2,16
    80002002:	160a8593          	addi	a1,s5,352
    80002006:	16098513          	addi	a0,s3,352
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	e0a080e7          	jalr	-502(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    80002012:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002016:	854e                	mv	a0,s3
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	c6a080e7          	jalr	-918(ra) # 80000c82 <release>
  acquire(&wait_lock);
    80002020:	00010497          	auipc	s1,0x10
    80002024:	2c848493          	addi	s1,s1,712 # 800122e8 <wait_lock>
    80002028:	8526                	mv	a0,s1
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	ba4080e7          	jalr	-1116(ra) # 80000bce <acquire>
  np->parent = p;
    80002032:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    80002036:	8526                	mv	a0,s1
    80002038:	fffff097          	auipc	ra,0xfffff
    8000203c:	c4a080e7          	jalr	-950(ra) # 80000c82 <release>
  acquire(&np->lock);
    80002040:	854e                	mv	a0,s3
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	b8c080e7          	jalr	-1140(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    8000204a:	478d                	li	a5,3
    8000204c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002050:	854e                	mv	a0,s3
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	c30080e7          	jalr	-976(ra) # 80000c82 <release>
}
    8000205a:	854a                	mv	a0,s2
    8000205c:	70e2                	ld	ra,56(sp)
    8000205e:	7442                	ld	s0,48(sp)
    80002060:	74a2                	ld	s1,40(sp)
    80002062:	7902                	ld	s2,32(sp)
    80002064:	69e2                	ld	s3,24(sp)
    80002066:	6a42                	ld	s4,16(sp)
    80002068:	6aa2                	ld	s5,8(sp)
    8000206a:	6121                	addi	sp,sp,64
    8000206c:	8082                	ret
    return -1;
    8000206e:	597d                	li	s2,-1
    80002070:	b7ed                	j	8000205a <forkf+0x134>

0000000080002072 <forkp>:
{
    80002072:	7139                	addi	sp,sp,-64
    80002074:	fc06                	sd	ra,56(sp)
    80002076:	f822                	sd	s0,48(sp)
    80002078:	f426                	sd	s1,40(sp)
    8000207a:	f04a                	sd	s2,32(sp)
    8000207c:	ec4e                	sd	s3,24(sp)
    8000207e:	e852                	sd	s4,16(sp)
    80002080:	e456                	sd	s5,8(sp)
    80002082:	e05a                	sd	s6,0(sp)
    80002084:	0080                	addi	s0,sp,64
    80002086:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002088:	00000097          	auipc	ra,0x0
    8000208c:	916080e7          	jalr	-1770(ra) # 8000199e <myproc>
    80002090:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002092:	00000097          	auipc	ra,0x0
    80002096:	b4e080e7          	jalr	-1202(ra) # 80001be0 <allocproc>
    8000209a:	14050863          	beqz	a0,800021ea <forkp+0x178>
    8000209e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020a0:	050ab603          	ld	a2,80(s5)
    800020a4:	6d2c                	ld	a1,88(a0)
    800020a6:	058ab503          	ld	a0,88(s5)
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	4b4080e7          	jalr	1204(ra) # 8000155e <uvmcopy>
    800020b2:	04054863          	bltz	a0,80002102 <forkp+0x90>
  np->sz = p->sz;
    800020b6:	050ab783          	ld	a5,80(s5)
    800020ba:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    800020be:	060ab683          	ld	a3,96(s5)
    800020c2:	87b6                	mv	a5,a3
    800020c4:	0609b703          	ld	a4,96(s3)
    800020c8:	12068693          	addi	a3,a3,288
    800020cc:	0007b803          	ld	a6,0(a5)
    800020d0:	6788                	ld	a0,8(a5)
    800020d2:	6b8c                	ld	a1,16(a5)
    800020d4:	6f90                	ld	a2,24(a5)
    800020d6:	01073023          	sd	a6,0(a4)
    800020da:	e708                	sd	a0,8(a4)
    800020dc:	eb0c                	sd	a1,16(a4)
    800020de:	ef10                	sd	a2,24(a4)
    800020e0:	02078793          	addi	a5,a5,32
    800020e4:	02070713          	addi	a4,a4,32
    800020e8:	fed792e3          	bne	a5,a3,800020cc <forkp+0x5a>
  np->trapframe->a0 = 0;
    800020ec:	0609b783          	ld	a5,96(s3)
    800020f0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800020f4:	0d8a8493          	addi	s1,s5,216
    800020f8:	0d898913          	addi	s2,s3,216
    800020fc:	158a8a13          	addi	s4,s5,344
    80002100:	a00d                	j	80002122 <forkp+0xb0>
    freeproc(np);
    80002102:	854e                	mv	a0,s3
    80002104:	00000097          	auipc	ra,0x0
    80002108:	a84080e7          	jalr	-1404(ra) # 80001b88 <freeproc>
    release(&np->lock);
    8000210c:	854e                	mv	a0,s3
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	b74080e7          	jalr	-1164(ra) # 80000c82 <release>
    return -1;
    80002116:	597d                	li	s2,-1
    80002118:	a875                	j	800021d4 <forkp+0x162>
  for(i = 0; i < NOFILE; i++)
    8000211a:	04a1                	addi	s1,s1,8
    8000211c:	0921                	addi	s2,s2,8
    8000211e:	01448b63          	beq	s1,s4,80002134 <forkp+0xc2>
    if(p->ofile[i])
    80002122:	6088                	ld	a0,0(s1)
    80002124:	d97d                	beqz	a0,8000211a <forkp+0xa8>
      np->ofile[i] = filedup(p->ofile[i]);
    80002126:	00003097          	auipc	ra,0x3
    8000212a:	594080e7          	jalr	1428(ra) # 800056ba <filedup>
    8000212e:	00a93023          	sd	a0,0(s2)
    80002132:	b7e5                	j	8000211a <forkp+0xa8>
  np->cwd = idup(p->cwd);
    80002134:	158ab503          	ld	a0,344(s5)
    80002138:	00002097          	auipc	ra,0x2
    8000213c:	6f2080e7          	jalr	1778(ra) # 8000482a <idup>
    80002140:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002144:	4641                	li	a2,16
    80002146:	160a8593          	addi	a1,s5,352
    8000214a:	16098513          	addi	a0,s3,352
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	cc6080e7          	jalr	-826(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    80002156:	0309a903          	lw	s2,48(s3)
  np->base_priority = priority;
    8000215a:	0369aa23          	sw	s6,52(s3)
  np->is_batchproc = 1;
    8000215e:	4785                	li	a5,1
    80002160:	02f9ae23          	sw	a5,60(s3)
  np->nextburst_estimate = 0;
    80002164:	1809a423          	sw	zero,392(s3)
  np->waittime = 0;
    80002168:	1609ae23          	sw	zero,380(s3)
  release(&np->lock);
    8000216c:	854e                	mv	a0,s3
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	b14080e7          	jalr	-1260(ra) # 80000c82 <release>
  batchsize++;
    80002176:	00008717          	auipc	a4,0x8
    8000217a:	ee670713          	addi	a4,a4,-282 # 8000a05c <batchsize>
    8000217e:	431c                	lw	a5,0(a4)
    80002180:	2785                	addiw	a5,a5,1
    80002182:	c31c                	sw	a5,0(a4)
  batchsize2++;
    80002184:	00008717          	auipc	a4,0x8
    80002188:	ed470713          	addi	a4,a4,-300 # 8000a058 <batchsize2>
    8000218c:	431c                	lw	a5,0(a4)
    8000218e:	2785                	addiw	a5,a5,1
    80002190:	c31c                	sw	a5,0(a4)
  acquire(&wait_lock);
    80002192:	00010497          	auipc	s1,0x10
    80002196:	15648493          	addi	s1,s1,342 # 800122e8 <wait_lock>
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	a32080e7          	jalr	-1486(ra) # 80000bce <acquire>
  np->parent = p;
    800021a4:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	ad8080e7          	jalr	-1320(ra) # 80000c82 <release>
  acquire(&np->lock);
    800021b2:	854e                	mv	a0,s3
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	a1a080e7          	jalr	-1510(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    800021bc:	478d                	li	a5,3
    800021be:	00f9ac23          	sw	a5,24(s3)
  np->waitstart = np->ctime;
    800021c2:	1709a783          	lw	a5,368(s3)
    800021c6:	18f9a023          	sw	a5,384(s3)
  release(&np->lock);
    800021ca:	854e                	mv	a0,s3
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	ab6080e7          	jalr	-1354(ra) # 80000c82 <release>
}
    800021d4:	854a                	mv	a0,s2
    800021d6:	70e2                	ld	ra,56(sp)
    800021d8:	7442                	ld	s0,48(sp)
    800021da:	74a2                	ld	s1,40(sp)
    800021dc:	7902                	ld	s2,32(sp)
    800021de:	69e2                	ld	s3,24(sp)
    800021e0:	6a42                	ld	s4,16(sp)
    800021e2:	6aa2                	ld	s5,8(sp)
    800021e4:	6b02                	ld	s6,0(sp)
    800021e6:	6121                	addi	sp,sp,64
    800021e8:	8082                	ret
    return -1;
    800021ea:	597d                	li	s2,-1
    800021ec:	b7e5                	j	800021d4 <forkp+0x162>

00000000800021ee <scheduler>:
{
    800021ee:	711d                	addi	sp,sp,-96
    800021f0:	ec86                	sd	ra,88(sp)
    800021f2:	e8a2                	sd	s0,80(sp)
    800021f4:	e4a6                	sd	s1,72(sp)
    800021f6:	e0ca                	sd	s2,64(sp)
    800021f8:	fc4e                	sd	s3,56(sp)
    800021fa:	f852                	sd	s4,48(sp)
    800021fc:	f456                	sd	s5,40(sp)
    800021fe:	f05a                	sd	s6,32(sp)
    80002200:	ec5e                	sd	s7,24(sp)
    80002202:	e862                	sd	s8,16(sp)
    80002204:	e466                	sd	s9,8(sp)
    80002206:	e06a                	sd	s10,0(sp)
    80002208:	1080                	addi	s0,sp,96
    8000220a:	8792                	mv	a5,tp
  int id = r_tp();
    8000220c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000220e:	00779a93          	slli	s5,a5,0x7
    80002212:	00010717          	auipc	a4,0x10
    80002216:	0be70713          	addi	a4,a4,190 # 800122d0 <pid_lock>
    8000221a:	9756                	add	a4,a4,s5
    8000221c:	02073823          	sd	zero,48(a4)
            swtch(&c->context, &p->context);
    80002220:	00010717          	auipc	a4,0x10
    80002224:	0e870713          	addi	a4,a4,232 # 80012308 <cpus+0x8>
    80002228:	9aba                	add	s5,s5,a4
          xticks = ticks;
    8000222a:	00008997          	auipc	s3,0x8
    8000222e:	e4298993          	addi	s3,s3,-446 # 8000a06c <ticks>
            c->proc = p;
    80002232:	079e                	slli	a5,a5,0x7
    80002234:	00010a17          	auipc	s4,0x10
    80002238:	09ca0a13          	addi	s4,s4,156 # 800122d0 <pid_lock>
    8000223c:	9a3e                	add	s4,s4,a5
       for(p = proc; p < &proc[NPROC]; p++) {
    8000223e:	00017917          	auipc	s2,0x17
    80002242:	8c290913          	addi	s2,s2,-1854 # 80018b00 <tickslock>
    80002246:	aca9                	j	800024a0 <scheduler+0x2b2>
       acquire(&tickslock);
    80002248:	00017517          	auipc	a0,0x17
    8000224c:	8b850513          	addi	a0,a0,-1864 # 80018b00 <tickslock>
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	97e080e7          	jalr	-1666(ra) # 80000bce <acquire>
       xticks = ticks;
    80002258:	0009ad03          	lw	s10,0(s3)
       release(&tickslock);
    8000225c:	00017517          	auipc	a0,0x17
    80002260:	8a450513          	addi	a0,a0,-1884 # 80018b00 <tickslock>
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	a1e080e7          	jalr	-1506(ra) # 80000c82 <release>
       min_burst = 0x7FFFFFFF;
    8000226c:	80000c37          	lui	s8,0x80000
    80002270:	fffc4c13          	not	s8,s8
       q = 0;
    80002274:	4c81                	li	s9,0
       for(p = proc; p < &proc[NPROC]; p++) {
    80002276:	00010497          	auipc	s1,0x10
    8000227a:	48a48493          	addi	s1,s1,1162 # 80012700 <proc>
	  if(p->state == RUNNABLE) {
    8000227e:	4b8d                	li	s7,3
    80002280:	a0ad                	j	800022ea <scheduler+0xfc>
                if (q) release(&q->lock);
    80002282:	000c8763          	beqz	s9,80002290 <scheduler+0xa2>
    80002286:	8566                	mv	a0,s9
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	9fa080e7          	jalr	-1542(ra) # 80000c82 <release>
          q->state = RUNNING;
    80002290:	4791                	li	a5,4
    80002292:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    80002294:	17c4a783          	lw	a5,380(s1)
    80002298:	01a787bb          	addw	a5,a5,s10
    8000229c:	1804a703          	lw	a4,384(s1)
    800022a0:	9f99                	subw	a5,a5,a4
    800022a2:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    800022a6:	19a4a223          	sw	s10,388(s1)
          c->proc = q;
    800022aa:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &q->context);
    800022ae:	06848593          	addi	a1,s1,104
    800022b2:	8556                	mv	a0,s5
    800022b4:	00001097          	auipc	ra,0x1
    800022b8:	320080e7          	jalr	800(ra) # 800035d4 <swtch>
          c->proc = 0;
    800022bc:	020a3823          	sd	zero,48(s4)
	  release(&q->lock);
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	9c0080e7          	jalr	-1600(ra) # 80000c82 <release>
    800022ca:	aad9                	j	800024a0 <scheduler+0x2b2>
             else release(&p->lock);
    800022cc:	8526                	mv	a0,s1
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	9b4080e7          	jalr	-1612(ra) # 80000c82 <release>
    800022d6:	a031                	j	800022e2 <scheduler+0xf4>
	  else release(&p->lock);
    800022d8:	8526                	mv	a0,s1
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	9a8080e7          	jalr	-1624(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800022e2:	19048493          	addi	s1,s1,400
    800022e6:	03248d63          	beq	s1,s2,80002320 <scheduler+0x132>
          acquire(&p->lock);
    800022ea:	8526                	mv	a0,s1
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	8e2080e7          	jalr	-1822(ra) # 80000bce <acquire>
	  if(p->state == RUNNABLE) {
    800022f4:	4c9c                	lw	a5,24(s1)
    800022f6:	ff7791e3          	bne	a5,s7,800022d8 <scheduler+0xea>
	     if (!p->is_batchproc) {
    800022fa:	5cdc                	lw	a5,60(s1)
    800022fc:	d3d9                	beqz	a5,80002282 <scheduler+0x94>
             else if (p->nextburst_estimate < min_burst) {
    800022fe:	1884ab03          	lw	s6,392(s1)
    80002302:	fd8b55e3          	bge	s6,s8,800022cc <scheduler+0xde>
		if (q) release(&q->lock);
    80002306:	000c8a63          	beqz	s9,8000231a <scheduler+0x12c>
    8000230a:	8566                	mv	a0,s9
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	976080e7          	jalr	-1674(ra) # 80000c82 <release>
	        min_burst = p->nextburst_estimate;
    80002314:	8c5a                	mv	s8,s6
		if (q) release(&q->lock);
    80002316:	8ca6                	mv	s9,s1
    80002318:	b7e9                	j	800022e2 <scheduler+0xf4>
	        min_burst = p->nextburst_estimate;
    8000231a:	8c5a                	mv	s8,s6
    8000231c:	8ca6                	mv	s9,s1
    8000231e:	b7d1                	j	800022e2 <scheduler+0xf4>
       if (q) {
    80002320:	180c8063          	beqz	s9,800024a0 <scheduler+0x2b2>
    80002324:	84e6                	mv	s1,s9
    80002326:	b7ad                	j	80002290 <scheduler+0xa2>
       acquire(&tickslock);
    80002328:	00016517          	auipc	a0,0x16
    8000232c:	7d850513          	addi	a0,a0,2008 # 80018b00 <tickslock>
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	89e080e7          	jalr	-1890(ra) # 80000bce <acquire>
       xticks = ticks;
    80002338:	0009ab83          	lw	s7,0(s3)
       release(&tickslock);
    8000233c:	00016517          	auipc	a0,0x16
    80002340:	7c450513          	addi	a0,a0,1988 # 80018b00 <tickslock>
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	93e080e7          	jalr	-1730(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    8000234c:	00010497          	auipc	s1,0x10
    80002350:	3b448493          	addi	s1,s1,948 # 80012700 <proc>
	  if(p->state == RUNNABLE) {
    80002354:	4b0d                	li	s6,3
    80002356:	a811                	j	8000236a <scheduler+0x17c>
	  release(&p->lock);
    80002358:	8526                	mv	a0,s1
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	928080e7          	jalr	-1752(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002362:	19048493          	addi	s1,s1,400
    80002366:	03248e63          	beq	s1,s2,800023a2 <scheduler+0x1b4>
          acquire(&p->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	862080e7          	jalr	-1950(ra) # 80000bce <acquire>
	  if(p->state == RUNNABLE) {
    80002374:	4c9c                	lw	a5,24(s1)
    80002376:	ff6791e3          	bne	a5,s6,80002358 <scheduler+0x16a>
	     p->cpu_usage = p->cpu_usage/2;
    8000237a:	18c4a703          	lw	a4,396(s1)
    8000237e:	01f7579b          	srliw	a5,a4,0x1f
    80002382:	9fb9                	addw	a5,a5,a4
    80002384:	4017d79b          	sraiw	a5,a5,0x1
    80002388:	18f4a623          	sw	a5,396(s1)
	     p->priority = p->base_priority + (p->cpu_usage/2);
    8000238c:	41f7579b          	sraiw	a5,a4,0x1f
    80002390:	01e7d79b          	srliw	a5,a5,0x1e
    80002394:	9fb9                	addw	a5,a5,a4
    80002396:	4027d79b          	sraiw	a5,a5,0x2
    8000239a:	58d8                	lw	a4,52(s1)
    8000239c:	9fb9                	addw	a5,a5,a4
    8000239e:	dc9c                	sw	a5,56(s1)
    800023a0:	bf65                	j	80002358 <scheduler+0x16a>
       min_prio = 0x7FFFFFFF;
    800023a2:	80000cb7          	lui	s9,0x80000
    800023a6:	fffccc93          	not	s9,s9
       q = 0;
    800023aa:	4d01                	li	s10,0
       for(p = proc; p < &proc[NPROC]; p++) {
    800023ac:	00010497          	auipc	s1,0x10
    800023b0:	35448493          	addi	s1,s1,852 # 80012700 <proc>
          if(p->state == RUNNABLE) {
    800023b4:	4c0d                	li	s8,3
    800023b6:	a0ad                	j	80002420 <scheduler+0x232>
                if (q) release(&q->lock);
    800023b8:	000d0763          	beqz	s10,800023c6 <scheduler+0x1d8>
    800023bc:	856a                	mv	a0,s10
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	8c4080e7          	jalr	-1852(ra) # 80000c82 <release>
          q->state = RUNNING;
    800023c6:	4791                	li	a5,4
    800023c8:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    800023ca:	17c4a783          	lw	a5,380(s1)
    800023ce:	017787bb          	addw	a5,a5,s7
    800023d2:	1804a703          	lw	a4,384(s1)
    800023d6:	9f99                	subw	a5,a5,a4
    800023d8:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    800023dc:	1974a223          	sw	s7,388(s1)
          c->proc = q;
    800023e0:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &q->context);
    800023e4:	06848593          	addi	a1,s1,104
    800023e8:	8556                	mv	a0,s5
    800023ea:	00001097          	auipc	ra,0x1
    800023ee:	1ea080e7          	jalr	490(ra) # 800035d4 <swtch>
          c->proc = 0;
    800023f2:	020a3823          	sd	zero,48(s4)
          release(&q->lock);
    800023f6:	8526                	mv	a0,s1
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	88a080e7          	jalr	-1910(ra) # 80000c82 <release>
    80002400:	a045                	j	800024a0 <scheduler+0x2b2>
             else release(&p->lock);
    80002402:	8526                	mv	a0,s1
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	87e080e7          	jalr	-1922(ra) # 80000c82 <release>
    8000240c:	a031                	j	80002418 <scheduler+0x22a>
          else release(&p->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	872080e7          	jalr	-1934(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002418:	19048493          	addi	s1,s1,400
    8000241c:	03248d63          	beq	s1,s2,80002456 <scheduler+0x268>
          acquire(&p->lock);
    80002420:	8526                	mv	a0,s1
    80002422:	ffffe097          	auipc	ra,0xffffe
    80002426:	7ac080e7          	jalr	1964(ra) # 80000bce <acquire>
          if(p->state == RUNNABLE) {
    8000242a:	4c9c                	lw	a5,24(s1)
    8000242c:	ff8791e3          	bne	a5,s8,8000240e <scheduler+0x220>
             if (!p->is_batchproc) {
    80002430:	5cdc                	lw	a5,60(s1)
    80002432:	d3d9                	beqz	a5,800023b8 <scheduler+0x1ca>
             else if (p->priority < min_prio) {
    80002434:	0384ab03          	lw	s6,56(s1)
    80002438:	fd9b55e3          	bge	s6,s9,80002402 <scheduler+0x214>
                if (q) release(&q->lock);
    8000243c:	000d0a63          	beqz	s10,80002450 <scheduler+0x262>
    80002440:	856a                	mv	a0,s10
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	840080e7          	jalr	-1984(ra) # 80000c82 <release>
                min_prio = p->priority;
    8000244a:	8cda                	mv	s9,s6
                if (q) release(&q->lock);
    8000244c:	8d26                	mv	s10,s1
    8000244e:	b7e9                	j	80002418 <scheduler+0x22a>
                min_prio = p->priority;
    80002450:	8cda                	mv	s9,s6
    80002452:	8d26                	mv	s10,s1
    80002454:	b7d1                	j	80002418 <scheduler+0x22a>
       if (q) {
    80002456:	040d0563          	beqz	s10,800024a0 <scheduler+0x2b2>
    8000245a:	84ea                	mv	s1,s10
    8000245c:	b7ad                	j	800023c6 <scheduler+0x1d8>
          acquire(&tickslock);
    8000245e:	855a                	mv	a0,s6
    80002460:	ffffe097          	auipc	ra,0xffffe
    80002464:	76e080e7          	jalr	1902(ra) # 80000bce <acquire>
          xticks = ticks;
    80002468:	0009ac83          	lw	s9,0(s3)
          release(&tickslock);
    8000246c:	855a                	mv	a0,s6
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	814080e7          	jalr	-2028(ra) # 80000c82 <release>
          acquire(&p->lock);
    80002476:	8526                	mv	a0,s1
    80002478:	ffffe097          	auipc	ra,0xffffe
    8000247c:	756080e7          	jalr	1878(ra) # 80000bce <acquire>
          if(p->state == RUNNABLE) {
    80002480:	4c9c                	lw	a5,24(s1)
    80002482:	05878d63          	beq	a5,s8,800024dc <scheduler+0x2ee>
          release(&p->lock);
    80002486:	8526                	mv	a0,s1
    80002488:	ffffe097          	auipc	ra,0xffffe
    8000248c:	7fa080e7          	jalr	2042(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002490:	19048493          	addi	s1,s1,400
    80002494:	01248663          	beq	s1,s2,800024a0 <scheduler+0x2b2>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    80002498:	000ba783          	lw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffd8000>
    8000249c:	9bf5                	andi	a5,a5,-3
    8000249e:	d3e1                	beqz	a5,8000245e <scheduler+0x270>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024a0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024a4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024a8:	10079073          	csrw	sstatus,a5
    if (sched_policy == SCHED_NPREEMPT_SJF) {
    800024ac:	00008797          	auipc	a5,0x8
    800024b0:	bbc7a783          	lw	a5,-1092(a5) # 8000a068 <sched_policy>
    800024b4:	4705                	li	a4,1
    800024b6:	d8e789e3          	beq	a5,a4,80002248 <scheduler+0x5a>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    800024ba:	470d                	li	a4,3
       for(p = proc; p < &proc[NPROC]; p++) {
    800024bc:	00010497          	auipc	s1,0x10
    800024c0:	24448493          	addi	s1,s1,580 # 80012700 <proc>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    800024c4:	e6e782e3          	beq	a5,a4,80002328 <scheduler+0x13a>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    800024c8:	00008b97          	auipc	s7,0x8
    800024cc:	ba0b8b93          	addi	s7,s7,-1120 # 8000a068 <sched_policy>
          acquire(&tickslock);
    800024d0:	00016b17          	auipc	s6,0x16
    800024d4:	630b0b13          	addi	s6,s6,1584 # 80018b00 <tickslock>
          if(p->state == RUNNABLE) {
    800024d8:	4c0d                	li	s8,3
    800024da:	bf7d                	j	80002498 <scheduler+0x2aa>
            p->state = RUNNING;
    800024dc:	4791                	li	a5,4
    800024de:	cc9c                	sw	a5,24(s1)
	    p->waittime += (xticks - p->waitstart);
    800024e0:	17c4a783          	lw	a5,380(s1)
    800024e4:	019787bb          	addw	a5,a5,s9
    800024e8:	1804a703          	lw	a4,384(s1)
    800024ec:	9f99                	subw	a5,a5,a4
    800024ee:	16f4ae23          	sw	a5,380(s1)
	    p->burst_start = xticks;
    800024f2:	1994a223          	sw	s9,388(s1)
            c->proc = p;
    800024f6:	029a3823          	sd	s1,48(s4)
            swtch(&c->context, &p->context);
    800024fa:	06848593          	addi	a1,s1,104
    800024fe:	8556                	mv	a0,s5
    80002500:	00001097          	auipc	ra,0x1
    80002504:	0d4080e7          	jalr	212(ra) # 800035d4 <swtch>
            c->proc = 0;
    80002508:	020a3823          	sd	zero,48(s4)
    8000250c:	bfad                	j	80002486 <scheduler+0x298>

000000008000250e <sched>:
{
    8000250e:	7179                	addi	sp,sp,-48
    80002510:	f406                	sd	ra,40(sp)
    80002512:	f022                	sd	s0,32(sp)
    80002514:	ec26                	sd	s1,24(sp)
    80002516:	e84a                	sd	s2,16(sp)
    80002518:	e44e                	sd	s3,8(sp)
    8000251a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	482080e7          	jalr	1154(ra) # 8000199e <myproc>
    80002524:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002526:	ffffe097          	auipc	ra,0xffffe
    8000252a:	62e080e7          	jalr	1582(ra) # 80000b54 <holding>
    8000252e:	c93d                	beqz	a0,800025a4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002530:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002532:	2781                	sext.w	a5,a5
    80002534:	079e                	slli	a5,a5,0x7
    80002536:	00010717          	auipc	a4,0x10
    8000253a:	d9a70713          	addi	a4,a4,-614 # 800122d0 <pid_lock>
    8000253e:	97ba                	add	a5,a5,a4
    80002540:	0a87a703          	lw	a4,168(a5)
    80002544:	4785                	li	a5,1
    80002546:	06f71763          	bne	a4,a5,800025b4 <sched+0xa6>
  if(p->state == RUNNING)
    8000254a:	4c98                	lw	a4,24(s1)
    8000254c:	4791                	li	a5,4
    8000254e:	06f70b63          	beq	a4,a5,800025c4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002552:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002556:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002558:	efb5                	bnez	a5,800025d4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000255a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000255c:	00010917          	auipc	s2,0x10
    80002560:	d7490913          	addi	s2,s2,-652 # 800122d0 <pid_lock>
    80002564:	2781                	sext.w	a5,a5
    80002566:	079e                	slli	a5,a5,0x7
    80002568:	97ca                	add	a5,a5,s2
    8000256a:	0ac7a983          	lw	s3,172(a5)
    8000256e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002570:	2781                	sext.w	a5,a5
    80002572:	079e                	slli	a5,a5,0x7
    80002574:	00010597          	auipc	a1,0x10
    80002578:	d9458593          	addi	a1,a1,-620 # 80012308 <cpus+0x8>
    8000257c:	95be                	add	a1,a1,a5
    8000257e:	06848513          	addi	a0,s1,104
    80002582:	00001097          	auipc	ra,0x1
    80002586:	052080e7          	jalr	82(ra) # 800035d4 <swtch>
    8000258a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000258c:	2781                	sext.w	a5,a5
    8000258e:	079e                	slli	a5,a5,0x7
    80002590:	993e                	add	s2,s2,a5
    80002592:	0b392623          	sw	s3,172(s2)
}
    80002596:	70a2                	ld	ra,40(sp)
    80002598:	7402                	ld	s0,32(sp)
    8000259a:	64e2                	ld	s1,24(sp)
    8000259c:	6942                	ld	s2,16(sp)
    8000259e:	69a2                	ld	s3,8(sp)
    800025a0:	6145                	addi	sp,sp,48
    800025a2:	8082                	ret
    panic("sched p->lock");
    800025a4:	00007517          	auipc	a0,0x7
    800025a8:	c7450513          	addi	a0,a0,-908 # 80009218 <digits+0x1d8>
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	f8c080e7          	jalr	-116(ra) # 80000538 <panic>
    panic("sched locks");
    800025b4:	00007517          	auipc	a0,0x7
    800025b8:	c7450513          	addi	a0,a0,-908 # 80009228 <digits+0x1e8>
    800025bc:	ffffe097          	auipc	ra,0xffffe
    800025c0:	f7c080e7          	jalr	-132(ra) # 80000538 <panic>
    panic("sched running");
    800025c4:	00007517          	auipc	a0,0x7
    800025c8:	c7450513          	addi	a0,a0,-908 # 80009238 <digits+0x1f8>
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	f6c080e7          	jalr	-148(ra) # 80000538 <panic>
    panic("sched interruptible");
    800025d4:	00007517          	auipc	a0,0x7
    800025d8:	c7450513          	addi	a0,a0,-908 # 80009248 <digits+0x208>
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	f5c080e7          	jalr	-164(ra) # 80000538 <panic>

00000000800025e4 <yield>:
{
    800025e4:	1101                	addi	sp,sp,-32
    800025e6:	ec06                	sd	ra,24(sp)
    800025e8:	e822                	sd	s0,16(sp)
    800025ea:	e426                	sd	s1,8(sp)
    800025ec:	e04a                	sd	s2,0(sp)
    800025ee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800025f0:	fffff097          	auipc	ra,0xfffff
    800025f4:	3ae080e7          	jalr	942(ra) # 8000199e <myproc>
    800025f8:	84aa                	mv	s1,a0
  acquire(&tickslock);
    800025fa:	00016517          	auipc	a0,0x16
    800025fe:	50650513          	addi	a0,a0,1286 # 80018b00 <tickslock>
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	5cc080e7          	jalr	1484(ra) # 80000bce <acquire>
  xticks = ticks;
    8000260a:	00008917          	auipc	s2,0x8
    8000260e:	a6292903          	lw	s2,-1438(s2) # 8000a06c <ticks>
  release(&tickslock);
    80002612:	00016517          	auipc	a0,0x16
    80002616:	4ee50513          	addi	a0,a0,1262 # 80018b00 <tickslock>
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	668080e7          	jalr	1640(ra) # 80000c82 <release>
  acquire(&p->lock);
    80002622:	8526                	mv	a0,s1
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	5aa080e7          	jalr	1450(ra) # 80000bce <acquire>
  p->state = RUNNABLE;
    8000262c:	478d                	li	a5,3
    8000262e:	cc9c                	sw	a5,24(s1)
  p->waitstart = xticks;
    80002630:	1924a023          	sw	s2,384(s1)
  p->cpu_usage += SCHED_PARAM_CPU_USAGE;
    80002634:	18c4a783          	lw	a5,396(s1)
    80002638:	0c87879b          	addiw	a5,a5,200
    8000263c:	18f4a623          	sw	a5,396(s1)
  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    80002640:	5cdc                	lw	a5,60(s1)
    80002642:	c7ed                	beqz	a5,8000272c <yield+0x148>
    80002644:	1844a783          	lw	a5,388(s1)
    80002648:	0f278263          	beq	a5,s2,8000272c <yield+0x148>
     num_cpubursts++;
    8000264c:	00008697          	auipc	a3,0x8
    80002650:	9f868693          	addi	a3,a3,-1544 # 8000a044 <num_cpubursts>
    80002654:	4298                	lw	a4,0(a3)
    80002656:	2705                	addiw	a4,a4,1
    80002658:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    8000265a:	40f9073b          	subw	a4,s2,a5
    8000265e:	0007061b          	sext.w	a2,a4
    80002662:	00008597          	auipc	a1,0x8
    80002666:	9de58593          	addi	a1,a1,-1570 # 8000a040 <cpubursts_tot>
    8000266a:	4194                	lw	a3,0(a1)
    8000266c:	9eb9                	addw	a3,a3,a4
    8000266e:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002670:	00008697          	auipc	a3,0x8
    80002674:	9cc6a683          	lw	a3,-1588(a3) # 8000a03c <cpubursts_max>
    80002678:	00c6f663          	bgeu	a3,a2,80002684 <yield+0xa0>
    8000267c:	00008697          	auipc	a3,0x8
    80002680:	9ce6a023          	sw	a4,-1600(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002684:	00007697          	auipc	a3,0x7
    80002688:	3f46a683          	lw	a3,1012(a3) # 80009a78 <cpubursts_min>
    8000268c:	00d67663          	bgeu	a2,a3,80002698 <yield+0xb4>
    80002690:	00007697          	auipc	a3,0x7
    80002694:	3ee6a423          	sw	a4,1000(a3) # 80009a78 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    80002698:	1884a683          	lw	a3,392(s1)
    8000269c:	02d05763          	blez	a3,800026ca <yield+0xe6>
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    800026a0:	0006859b          	sext.w	a1,a3
    800026a4:	0ac5e363          	bltu	a1,a2,8000274a <yield+0x166>
    800026a8:	9fad                	addw	a5,a5,a1
    800026aa:	412785bb          	subw	a1,a5,s2
    800026ae:	00008617          	auipc	a2,0x8
    800026b2:	97e60613          	addi	a2,a2,-1666 # 8000a02c <estimation_error>
    800026b6:	421c                	lw	a5,0(a2)
    800026b8:	9fad                	addw	a5,a5,a1
    800026ba:	c21c                	sw	a5,0(a2)
	estimation_error_instance++;
    800026bc:	00008617          	auipc	a2,0x8
    800026c0:	96c60613          	addi	a2,a2,-1684 # 8000a028 <estimation_error_instance>
    800026c4:	421c                	lw	a5,0(a2)
    800026c6:	2785                	addiw	a5,a5,1
    800026c8:	c21c                	sw	a5,0(a2)
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    800026ca:	01f6d79b          	srliw	a5,a3,0x1f
    800026ce:	9fb5                	addw	a5,a5,a3
    800026d0:	4017d79b          	sraiw	a5,a5,0x1
    800026d4:	9fb9                	addw	a5,a5,a4
    800026d6:	0017571b          	srliw	a4,a4,0x1
    800026da:	9f99                	subw	a5,a5,a4
    800026dc:	0007871b          	sext.w	a4,a5
    800026e0:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    800026e4:	04e05463          	blez	a4,8000272c <yield+0x148>
        num_cpubursts_est++;
    800026e8:	00008617          	auipc	a2,0x8
    800026ec:	95060613          	addi	a2,a2,-1712 # 8000a038 <num_cpubursts_est>
    800026f0:	4214                	lw	a3,0(a2)
    800026f2:	2685                	addiw	a3,a3,1
    800026f4:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    800026f6:	00008617          	auipc	a2,0x8
    800026fa:	93e60613          	addi	a2,a2,-1730 # 8000a034 <cpubursts_est_tot>
    800026fe:	4214                	lw	a3,0(a2)
    80002700:	9ebd                	addw	a3,a3,a5
    80002702:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002704:	00008697          	auipc	a3,0x8
    80002708:	92c6a683          	lw	a3,-1748(a3) # 8000a030 <cpubursts_est_max>
    8000270c:	00e6d663          	bge	a3,a4,80002718 <yield+0x134>
    80002710:	00008697          	auipc	a3,0x8
    80002714:	92f6a023          	sw	a5,-1760(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80002718:	00007697          	auipc	a3,0x7
    8000271c:	35c6a683          	lw	a3,860(a3) # 80009a74 <cpubursts_est_min>
    80002720:	00d75663          	bge	a4,a3,8000272c <yield+0x148>
    80002724:	00007717          	auipc	a4,0x7
    80002728:	34f72823          	sw	a5,848(a4) # 80009a74 <cpubursts_est_min>
  sched();
    8000272c:	00000097          	auipc	ra,0x0
    80002730:	de2080e7          	jalr	-542(ra) # 8000250e <sched>
  release(&p->lock);
    80002734:	8526                	mv	a0,s1
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	54c080e7          	jalr	1356(ra) # 80000c82 <release>
}
    8000273e:	60e2                	ld	ra,24(sp)
    80002740:	6442                	ld	s0,16(sp)
    80002742:	64a2                	ld	s1,8(sp)
    80002744:	6902                	ld	s2,0(sp)
    80002746:	6105                	addi	sp,sp,32
    80002748:	8082                	ret
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    8000274a:	40b705bb          	subw	a1,a4,a1
    8000274e:	b785                	j	800026ae <yield+0xca>

0000000080002750 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002750:	7179                	addi	sp,sp,-48
    80002752:	f406                	sd	ra,40(sp)
    80002754:	f022                	sd	s0,32(sp)
    80002756:	ec26                	sd	s1,24(sp)
    80002758:	e84a                	sd	s2,16(sp)
    8000275a:	e44e                	sd	s3,8(sp)
    8000275c:	e052                	sd	s4,0(sp)
    8000275e:	1800                	addi	s0,sp,48
    80002760:	89aa                	mv	s3,a0
    80002762:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002764:	fffff097          	auipc	ra,0xfffff
    80002768:	23a080e7          	jalr	570(ra) # 8000199e <myproc>
    8000276c:	84aa                	mv	s1,a0
  uint xticks;

  if (!holding(&tickslock)) {
    8000276e:	00016517          	auipc	a0,0x16
    80002772:	39250513          	addi	a0,a0,914 # 80018b00 <tickslock>
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	3de080e7          	jalr	990(ra) # 80000b54 <holding>
    8000277e:	14050863          	beqz	a0,800028ce <sleep+0x17e>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    80002782:	00008a17          	auipc	s4,0x8
    80002786:	8eaa2a03          	lw	s4,-1814(s4) # 8000a06c <ticks>
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000278a:	8526                	mv	a0,s1
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	442080e7          	jalr	1090(ra) # 80000bce <acquire>
  release(lk);
    80002794:	854a                	mv	a0,s2
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	4ec080e7          	jalr	1260(ra) # 80000c82 <release>

  // Go to sleep.
  p->chan = chan;
    8000279e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800027a2:	4789                	li	a5,2
    800027a4:	cc9c                	sw	a5,24(s1)

  p->cpu_usage += (SCHED_PARAM_CPU_USAGE/2);
    800027a6:	18c4a783          	lw	a5,396(s1)
    800027aa:	0647879b          	addiw	a5,a5,100
    800027ae:	18f4a623          	sw	a5,396(s1)

  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    800027b2:	5cdc                	lw	a5,60(s1)
    800027b4:	c7ed                	beqz	a5,8000289e <sleep+0x14e>
    800027b6:	1844a783          	lw	a5,388(s1)
    800027ba:	0f478263          	beq	a5,s4,8000289e <sleep+0x14e>
     num_cpubursts++;
    800027be:	00008697          	auipc	a3,0x8
    800027c2:	88668693          	addi	a3,a3,-1914 # 8000a044 <num_cpubursts>
    800027c6:	4298                	lw	a4,0(a3)
    800027c8:	2705                	addiw	a4,a4,1
    800027ca:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    800027cc:	40fa073b          	subw	a4,s4,a5
    800027d0:	0007061b          	sext.w	a2,a4
    800027d4:	00008597          	auipc	a1,0x8
    800027d8:	86c58593          	addi	a1,a1,-1940 # 8000a040 <cpubursts_tot>
    800027dc:	4194                	lw	a3,0(a1)
    800027de:	9eb9                	addw	a3,a3,a4
    800027e0:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    800027e2:	00008697          	auipc	a3,0x8
    800027e6:	85a6a683          	lw	a3,-1958(a3) # 8000a03c <cpubursts_max>
    800027ea:	00c6f663          	bgeu	a3,a2,800027f6 <sleep+0xa6>
    800027ee:	00008697          	auipc	a3,0x8
    800027f2:	84e6a723          	sw	a4,-1970(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    800027f6:	00007697          	auipc	a3,0x7
    800027fa:	2826a683          	lw	a3,642(a3) # 80009a78 <cpubursts_min>
    800027fe:	00d67663          	bgeu	a2,a3,8000280a <sleep+0xba>
    80002802:	00007697          	auipc	a3,0x7
    80002806:	26e6ab23          	sw	a4,630(a3) # 80009a78 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    8000280a:	1884a683          	lw	a3,392(s1)
    8000280e:	02d05763          	blez	a3,8000283c <sleep+0xec>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002812:	0006859b          	sext.w	a1,a3
    80002816:	0ec5e163          	bltu	a1,a2,800028f8 <sleep+0x1a8>
    8000281a:	9fad                	addw	a5,a5,a1
    8000281c:	414785bb          	subw	a1,a5,s4
    80002820:	00008617          	auipc	a2,0x8
    80002824:	80c60613          	addi	a2,a2,-2036 # 8000a02c <estimation_error>
    80002828:	421c                	lw	a5,0(a2)
    8000282a:	9fad                	addw	a5,a5,a1
    8000282c:	c21c                	sw	a5,0(a2)
        estimation_error_instance++;
    8000282e:	00007617          	auipc	a2,0x7
    80002832:	7fa60613          	addi	a2,a2,2042 # 8000a028 <estimation_error_instance>
    80002836:	421c                	lw	a5,0(a2)
    80002838:	2785                	addiw	a5,a5,1
    8000283a:	c21c                	sw	a5,0(a2)
     }
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    8000283c:	01f6d79b          	srliw	a5,a3,0x1f
    80002840:	9fb5                	addw	a5,a5,a3
    80002842:	4017d79b          	sraiw	a5,a5,0x1
    80002846:	9fb9                	addw	a5,a5,a4
    80002848:	0017571b          	srliw	a4,a4,0x1
    8000284c:	9f99                	subw	a5,a5,a4
    8000284e:	0007871b          	sext.w	a4,a5
    80002852:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    80002856:	04e05463          	blez	a4,8000289e <sleep+0x14e>
        num_cpubursts_est++;
    8000285a:	00007617          	auipc	a2,0x7
    8000285e:	7de60613          	addi	a2,a2,2014 # 8000a038 <num_cpubursts_est>
    80002862:	4214                	lw	a3,0(a2)
    80002864:	2685                	addiw	a3,a3,1
    80002866:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    80002868:	00007617          	auipc	a2,0x7
    8000286c:	7cc60613          	addi	a2,a2,1996 # 8000a034 <cpubursts_est_tot>
    80002870:	4214                	lw	a3,0(a2)
    80002872:	9ebd                	addw	a3,a3,a5
    80002874:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002876:	00007697          	auipc	a3,0x7
    8000287a:	7ba6a683          	lw	a3,1978(a3) # 8000a030 <cpubursts_est_max>
    8000287e:	00e6d663          	bge	a3,a4,8000288a <sleep+0x13a>
    80002882:	00007697          	auipc	a3,0x7
    80002886:	7af6a723          	sw	a5,1966(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    8000288a:	00007697          	auipc	a3,0x7
    8000288e:	1ea6a683          	lw	a3,490(a3) # 80009a74 <cpubursts_est_min>
    80002892:	00d75663          	bge	a4,a3,8000289e <sleep+0x14e>
    80002896:	00007717          	auipc	a4,0x7
    8000289a:	1cf72f23          	sw	a5,478(a4) # 80009a74 <cpubursts_est_min>
     }
  }

  sched();
    8000289e:	00000097          	auipc	ra,0x0
    800028a2:	c70080e7          	jalr	-912(ra) # 8000250e <sched>

  // Tidy up.
  p->chan = 0;
    800028a6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800028aa:	8526                	mv	a0,s1
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	3d6080e7          	jalr	982(ra) # 80000c82 <release>
  acquire(lk);
    800028b4:	854a                	mv	a0,s2
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	318080e7          	jalr	792(ra) # 80000bce <acquire>
}
    800028be:	70a2                	ld	ra,40(sp)
    800028c0:	7402                	ld	s0,32(sp)
    800028c2:	64e2                	ld	s1,24(sp)
    800028c4:	6942                	ld	s2,16(sp)
    800028c6:	69a2                	ld	s3,8(sp)
    800028c8:	6a02                	ld	s4,0(sp)
    800028ca:	6145                	addi	sp,sp,48
    800028cc:	8082                	ret
     acquire(&tickslock);
    800028ce:	00016517          	auipc	a0,0x16
    800028d2:	23250513          	addi	a0,a0,562 # 80018b00 <tickslock>
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	2f8080e7          	jalr	760(ra) # 80000bce <acquire>
     xticks = ticks;
    800028de:	00007a17          	auipc	s4,0x7
    800028e2:	78ea2a03          	lw	s4,1934(s4) # 8000a06c <ticks>
     release(&tickslock);
    800028e6:	00016517          	auipc	a0,0x16
    800028ea:	21a50513          	addi	a0,a0,538 # 80018b00 <tickslock>
    800028ee:	ffffe097          	auipc	ra,0xffffe
    800028f2:	394080e7          	jalr	916(ra) # 80000c82 <release>
    800028f6:	bd51                	j	8000278a <sleep+0x3a>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    800028f8:	40b705bb          	subw	a1,a4,a1
    800028fc:	b715                	j	80002820 <sleep+0xd0>

00000000800028fe <wait>:
{
    800028fe:	715d                	addi	sp,sp,-80
    80002900:	e486                	sd	ra,72(sp)
    80002902:	e0a2                	sd	s0,64(sp)
    80002904:	fc26                	sd	s1,56(sp)
    80002906:	f84a                	sd	s2,48(sp)
    80002908:	f44e                	sd	s3,40(sp)
    8000290a:	f052                	sd	s4,32(sp)
    8000290c:	ec56                	sd	s5,24(sp)
    8000290e:	e85a                	sd	s6,16(sp)
    80002910:	e45e                	sd	s7,8(sp)
    80002912:	e062                	sd	s8,0(sp)
    80002914:	0880                	addi	s0,sp,80
    80002916:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002918:	fffff097          	auipc	ra,0xfffff
    8000291c:	086080e7          	jalr	134(ra) # 8000199e <myproc>
    80002920:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002922:	00010517          	auipc	a0,0x10
    80002926:	9c650513          	addi	a0,a0,-1594 # 800122e8 <wait_lock>
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	2a4080e7          	jalr	676(ra) # 80000bce <acquire>
    havekids = 0;
    80002932:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002934:	4a15                	li	s4,5
        havekids = 1;
    80002936:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002938:	00016997          	auipc	s3,0x16
    8000293c:	1c898993          	addi	s3,s3,456 # 80018b00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002940:	00010c17          	auipc	s8,0x10
    80002944:	9a8c0c13          	addi	s8,s8,-1624 # 800122e8 <wait_lock>
    havekids = 0;
    80002948:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000294a:	00010497          	auipc	s1,0x10
    8000294e:	db648493          	addi	s1,s1,-586 # 80012700 <proc>
    80002952:	a0bd                	j	800029c0 <wait+0xc2>
          pid = np->pid;
    80002954:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002958:	000b0e63          	beqz	s6,80002974 <wait+0x76>
    8000295c:	4691                	li	a3,4
    8000295e:	02c48613          	addi	a2,s1,44
    80002962:	85da                	mv	a1,s6
    80002964:	05893503          	ld	a0,88(s2)
    80002968:	fffff097          	auipc	ra,0xfffff
    8000296c:	cfa080e7          	jalr	-774(ra) # 80001662 <copyout>
    80002970:	02054563          	bltz	a0,8000299a <wait+0x9c>
          freeproc(np);
    80002974:	8526                	mv	a0,s1
    80002976:	fffff097          	auipc	ra,0xfffff
    8000297a:	212080e7          	jalr	530(ra) # 80001b88 <freeproc>
          release(&np->lock);
    8000297e:	8526                	mv	a0,s1
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	302080e7          	jalr	770(ra) # 80000c82 <release>
          release(&wait_lock);
    80002988:	00010517          	auipc	a0,0x10
    8000298c:	96050513          	addi	a0,a0,-1696 # 800122e8 <wait_lock>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	2f2080e7          	jalr	754(ra) # 80000c82 <release>
          return pid;
    80002998:	a09d                	j	800029fe <wait+0x100>
            release(&np->lock);
    8000299a:	8526                	mv	a0,s1
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	2e6080e7          	jalr	742(ra) # 80000c82 <release>
            release(&wait_lock);
    800029a4:	00010517          	auipc	a0,0x10
    800029a8:	94450513          	addi	a0,a0,-1724 # 800122e8 <wait_lock>
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	2d6080e7          	jalr	726(ra) # 80000c82 <release>
            return -1;
    800029b4:	59fd                	li	s3,-1
    800029b6:	a0a1                	j	800029fe <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800029b8:	19048493          	addi	s1,s1,400
    800029bc:	03348463          	beq	s1,s3,800029e4 <wait+0xe6>
      if(np->parent == p){
    800029c0:	60bc                	ld	a5,64(s1)
    800029c2:	ff279be3          	bne	a5,s2,800029b8 <wait+0xba>
        acquire(&np->lock);
    800029c6:	8526                	mv	a0,s1
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	206080e7          	jalr	518(ra) # 80000bce <acquire>
        if(np->state == ZOMBIE){
    800029d0:	4c9c                	lw	a5,24(s1)
    800029d2:	f94781e3          	beq	a5,s4,80002954 <wait+0x56>
        release(&np->lock);
    800029d6:	8526                	mv	a0,s1
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	2aa080e7          	jalr	682(ra) # 80000c82 <release>
        havekids = 1;
    800029e0:	8756                	mv	a4,s5
    800029e2:	bfd9                	j	800029b8 <wait+0xba>
    if(!havekids || p->killed){
    800029e4:	c701                	beqz	a4,800029ec <wait+0xee>
    800029e6:	02892783          	lw	a5,40(s2)
    800029ea:	c79d                	beqz	a5,80002a18 <wait+0x11a>
      release(&wait_lock);
    800029ec:	00010517          	auipc	a0,0x10
    800029f0:	8fc50513          	addi	a0,a0,-1796 # 800122e8 <wait_lock>
    800029f4:	ffffe097          	auipc	ra,0xffffe
    800029f8:	28e080e7          	jalr	654(ra) # 80000c82 <release>
      return -1;
    800029fc:	59fd                	li	s3,-1
}
    800029fe:	854e                	mv	a0,s3
    80002a00:	60a6                	ld	ra,72(sp)
    80002a02:	6406                	ld	s0,64(sp)
    80002a04:	74e2                	ld	s1,56(sp)
    80002a06:	7942                	ld	s2,48(sp)
    80002a08:	79a2                	ld	s3,40(sp)
    80002a0a:	7a02                	ld	s4,32(sp)
    80002a0c:	6ae2                	ld	s5,24(sp)
    80002a0e:	6b42                	ld	s6,16(sp)
    80002a10:	6ba2                	ld	s7,8(sp)
    80002a12:	6c02                	ld	s8,0(sp)
    80002a14:	6161                	addi	sp,sp,80
    80002a16:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a18:	85e2                	mv	a1,s8
    80002a1a:	854a                	mv	a0,s2
    80002a1c:	00000097          	auipc	ra,0x0
    80002a20:	d34080e7          	jalr	-716(ra) # 80002750 <sleep>
    havekids = 0;
    80002a24:	b715                	j	80002948 <wait+0x4a>

0000000080002a26 <waitpid>:
{
    80002a26:	711d                	addi	sp,sp,-96
    80002a28:	ec86                	sd	ra,88(sp)
    80002a2a:	e8a2                	sd	s0,80(sp)
    80002a2c:	e4a6                	sd	s1,72(sp)
    80002a2e:	e0ca                	sd	s2,64(sp)
    80002a30:	fc4e                	sd	s3,56(sp)
    80002a32:	f852                	sd	s4,48(sp)
    80002a34:	f456                	sd	s5,40(sp)
    80002a36:	f05a                	sd	s6,32(sp)
    80002a38:	ec5e                	sd	s7,24(sp)
    80002a3a:	e862                	sd	s8,16(sp)
    80002a3c:	e466                	sd	s9,8(sp)
    80002a3e:	1080                	addi	s0,sp,96
    80002a40:	8a2a                	mv	s4,a0
    80002a42:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    80002a44:	fffff097          	auipc	ra,0xfffff
    80002a48:	f5a080e7          	jalr	-166(ra) # 8000199e <myproc>
    80002a4c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002a4e:	00010517          	auipc	a0,0x10
    80002a52:	89a50513          	addi	a0,a0,-1894 # 800122e8 <wait_lock>
    80002a56:	ffffe097          	auipc	ra,0xffffe
    80002a5a:	178080e7          	jalr	376(ra) # 80000bce <acquire>
  int found=0;
    80002a5e:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    80002a60:	4a95                	li	s5,5
	found = 1;
    80002a62:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002a64:	00016997          	auipc	s3,0x16
    80002a68:	09c98993          	addi	s3,s3,156 # 80018b00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a6c:	00010b97          	auipc	s7,0x10
    80002a70:	87cb8b93          	addi	s7,s7,-1924 # 800122e8 <wait_lock>
    80002a74:	a0c9                	j	80002b36 <waitpid+0x110>
             release(&np->lock);
    80002a76:	8526                	mv	a0,s1
    80002a78:	ffffe097          	auipc	ra,0xffffe
    80002a7c:	20a080e7          	jalr	522(ra) # 80000c82 <release>
             release(&wait_lock);
    80002a80:	00010517          	auipc	a0,0x10
    80002a84:	86850513          	addi	a0,a0,-1944 # 800122e8 <wait_lock>
    80002a88:	ffffe097          	auipc	ra,0xffffe
    80002a8c:	1fa080e7          	jalr	506(ra) # 80000c82 <release>
             return -1;
    80002a90:	557d                	li	a0,-1
    80002a92:	a895                	j	80002b06 <waitpid+0xe0>
        release(&np->lock);
    80002a94:	8526                	mv	a0,s1
    80002a96:	ffffe097          	auipc	ra,0xffffe
    80002a9a:	1ec080e7          	jalr	492(ra) # 80000c82 <release>
	found = 1;
    80002a9e:	8cda                	mv	s9,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002aa0:	19048493          	addi	s1,s1,400
    80002aa4:	07348e63          	beq	s1,s3,80002b20 <waitpid+0xfa>
      if((np->parent == p) && (np->pid == pid)){
    80002aa8:	60bc                	ld	a5,64(s1)
    80002aaa:	ff279be3          	bne	a5,s2,80002aa0 <waitpid+0x7a>
    80002aae:	589c                	lw	a5,48(s1)
    80002ab0:	ff4798e3          	bne	a5,s4,80002aa0 <waitpid+0x7a>
        acquire(&np->lock);
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	118080e7          	jalr	280(ra) # 80000bce <acquire>
        if(np->state == ZOMBIE){
    80002abe:	4c9c                	lw	a5,24(s1)
    80002ac0:	fd579ae3          	bne	a5,s5,80002a94 <waitpid+0x6e>
           if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002ac4:	000c0e63          	beqz	s8,80002ae0 <waitpid+0xba>
    80002ac8:	4691                	li	a3,4
    80002aca:	02c48613          	addi	a2,s1,44
    80002ace:	85e2                	mv	a1,s8
    80002ad0:	05893503          	ld	a0,88(s2)
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	b8e080e7          	jalr	-1138(ra) # 80001662 <copyout>
    80002adc:	f8054de3          	bltz	a0,80002a76 <waitpid+0x50>
           freeproc(np);
    80002ae0:	8526                	mv	a0,s1
    80002ae2:	fffff097          	auipc	ra,0xfffff
    80002ae6:	0a6080e7          	jalr	166(ra) # 80001b88 <freeproc>
           release(&np->lock);
    80002aea:	8526                	mv	a0,s1
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	196080e7          	jalr	406(ra) # 80000c82 <release>
           release(&wait_lock);
    80002af4:	0000f517          	auipc	a0,0xf
    80002af8:	7f450513          	addi	a0,a0,2036 # 800122e8 <wait_lock>
    80002afc:	ffffe097          	auipc	ra,0xffffe
    80002b00:	186080e7          	jalr	390(ra) # 80000c82 <release>
           return pid;
    80002b04:	8552                	mv	a0,s4
}
    80002b06:	60e6                	ld	ra,88(sp)
    80002b08:	6446                	ld	s0,80(sp)
    80002b0a:	64a6                	ld	s1,72(sp)
    80002b0c:	6906                	ld	s2,64(sp)
    80002b0e:	79e2                	ld	s3,56(sp)
    80002b10:	7a42                	ld	s4,48(sp)
    80002b12:	7aa2                	ld	s5,40(sp)
    80002b14:	7b02                	ld	s6,32(sp)
    80002b16:	6be2                	ld	s7,24(sp)
    80002b18:	6c42                	ld	s8,16(sp)
    80002b1a:	6ca2                	ld	s9,8(sp)
    80002b1c:	6125                	addi	sp,sp,96
    80002b1e:	8082                	ret
    if(!found || p->killed){
    80002b20:	020c8063          	beqz	s9,80002b40 <waitpid+0x11a>
    80002b24:	02892783          	lw	a5,40(s2)
    80002b28:	ef81                	bnez	a5,80002b40 <waitpid+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002b2a:	85de                	mv	a1,s7
    80002b2c:	854a                	mv	a0,s2
    80002b2e:	00000097          	auipc	ra,0x0
    80002b32:	c22080e7          	jalr	-990(ra) # 80002750 <sleep>
    for(np = proc; np < &proc[NPROC]; np++){
    80002b36:	00010497          	auipc	s1,0x10
    80002b3a:	bca48493          	addi	s1,s1,-1078 # 80012700 <proc>
    80002b3e:	b7ad                	j	80002aa8 <waitpid+0x82>
      release(&wait_lock);
    80002b40:	0000f517          	auipc	a0,0xf
    80002b44:	7a850513          	addi	a0,a0,1960 # 800122e8 <wait_lock>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	13a080e7          	jalr	314(ra) # 80000c82 <release>
      return -1;
    80002b50:	557d                	li	a0,-1
    80002b52:	bf55                	j	80002b06 <waitpid+0xe0>

0000000080002b54 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002b54:	7139                	addi	sp,sp,-64
    80002b56:	fc06                	sd	ra,56(sp)
    80002b58:	f822                	sd	s0,48(sp)
    80002b5a:	f426                	sd	s1,40(sp)
    80002b5c:	f04a                	sd	s2,32(sp)
    80002b5e:	ec4e                	sd	s3,24(sp)
    80002b60:	e852                	sd	s4,16(sp)
    80002b62:	e456                	sd	s5,8(sp)
    80002b64:	e05a                	sd	s6,0(sp)
    80002b66:	0080                	addi	s0,sp,64
    80002b68:	8a2a                	mv	s4,a0
  struct proc *p;
  uint xticks;

  if (!holding(&tickslock)) {
    80002b6a:	00016517          	auipc	a0,0x16
    80002b6e:	f9650513          	addi	a0,a0,-106 # 80018b00 <tickslock>
    80002b72:	ffffe097          	auipc	ra,0xffffe
    80002b76:	fe2080e7          	jalr	-30(ra) # 80000b54 <holding>
    80002b7a:	c105                	beqz	a0,80002b9a <wakeup+0x46>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    80002b7c:	00007b17          	auipc	s6,0x7
    80002b80:	4f0b2b03          	lw	s6,1264(s6) # 8000a06c <ticks>

  for(p = proc; p < &proc[NPROC]; p++) {
    80002b84:	00010497          	auipc	s1,0x10
    80002b88:	b7c48493          	addi	s1,s1,-1156 # 80012700 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002b8c:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002b8e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002b90:	00016917          	auipc	s2,0x16
    80002b94:	f7090913          	addi	s2,s2,-144 # 80018b00 <tickslock>
    80002b98:	a83d                	j	80002bd6 <wakeup+0x82>
     acquire(&tickslock);
    80002b9a:	00016517          	auipc	a0,0x16
    80002b9e:	f6650513          	addi	a0,a0,-154 # 80018b00 <tickslock>
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	02c080e7          	jalr	44(ra) # 80000bce <acquire>
     xticks = ticks;
    80002baa:	00007b17          	auipc	s6,0x7
    80002bae:	4c2b2b03          	lw	s6,1218(s6) # 8000a06c <ticks>
     release(&tickslock);
    80002bb2:	00016517          	auipc	a0,0x16
    80002bb6:	f4e50513          	addi	a0,a0,-178 # 80018b00 <tickslock>
    80002bba:	ffffe097          	auipc	ra,0xffffe
    80002bbe:	0c8080e7          	jalr	200(ra) # 80000c82 <release>
    80002bc2:	b7c9                	j	80002b84 <wakeup+0x30>
	p->waitstart = xticks;
      }
      release(&p->lock);
    80002bc4:	8526                	mv	a0,s1
    80002bc6:	ffffe097          	auipc	ra,0xffffe
    80002bca:	0bc080e7          	jalr	188(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002bce:	19048493          	addi	s1,s1,400
    80002bd2:	03248863          	beq	s1,s2,80002c02 <wakeup+0xae>
    if(p != myproc()){
    80002bd6:	fffff097          	auipc	ra,0xfffff
    80002bda:	dc8080e7          	jalr	-568(ra) # 8000199e <myproc>
    80002bde:	fea488e3          	beq	s1,a0,80002bce <wakeup+0x7a>
      acquire(&p->lock);
    80002be2:	8526                	mv	a0,s1
    80002be4:	ffffe097          	auipc	ra,0xffffe
    80002be8:	fea080e7          	jalr	-22(ra) # 80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002bec:	4c9c                	lw	a5,24(s1)
    80002bee:	fd379be3          	bne	a5,s3,80002bc4 <wakeup+0x70>
    80002bf2:	709c                	ld	a5,32(s1)
    80002bf4:	fd4798e3          	bne	a5,s4,80002bc4 <wakeup+0x70>
        p->state = RUNNABLE;
    80002bf8:	0154ac23          	sw	s5,24(s1)
	p->waitstart = xticks;
    80002bfc:	1964a023          	sw	s6,384(s1)
    80002c00:	b7d1                	j	80002bc4 <wakeup+0x70>
    }
  }
}
    80002c02:	70e2                	ld	ra,56(sp)
    80002c04:	7442                	ld	s0,48(sp)
    80002c06:	74a2                	ld	s1,40(sp)
    80002c08:	7902                	ld	s2,32(sp)
    80002c0a:	69e2                	ld	s3,24(sp)
    80002c0c:	6a42                	ld	s4,16(sp)
    80002c0e:	6aa2                	ld	s5,8(sp)
    80002c10:	6b02                	ld	s6,0(sp)
    80002c12:	6121                	addi	sp,sp,64
    80002c14:	8082                	ret

0000000080002c16 <reparent>:
{
    80002c16:	7179                	addi	sp,sp,-48
    80002c18:	f406                	sd	ra,40(sp)
    80002c1a:	f022                	sd	s0,32(sp)
    80002c1c:	ec26                	sd	s1,24(sp)
    80002c1e:	e84a                	sd	s2,16(sp)
    80002c20:	e44e                	sd	s3,8(sp)
    80002c22:	e052                	sd	s4,0(sp)
    80002c24:	1800                	addi	s0,sp,48
    80002c26:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c28:	00010497          	auipc	s1,0x10
    80002c2c:	ad848493          	addi	s1,s1,-1320 # 80012700 <proc>
      pp->parent = initproc;
    80002c30:	00007a17          	auipc	s4,0x7
    80002c34:	430a0a13          	addi	s4,s4,1072 # 8000a060 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c38:	00016997          	auipc	s3,0x16
    80002c3c:	ec898993          	addi	s3,s3,-312 # 80018b00 <tickslock>
    80002c40:	a029                	j	80002c4a <reparent+0x34>
    80002c42:	19048493          	addi	s1,s1,400
    80002c46:	01348d63          	beq	s1,s3,80002c60 <reparent+0x4a>
    if(pp->parent == p){
    80002c4a:	60bc                	ld	a5,64(s1)
    80002c4c:	ff279be3          	bne	a5,s2,80002c42 <reparent+0x2c>
      pp->parent = initproc;
    80002c50:	000a3503          	ld	a0,0(s4)
    80002c54:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	efe080e7          	jalr	-258(ra) # 80002b54 <wakeup>
    80002c5e:	b7d5                	j	80002c42 <reparent+0x2c>
}
    80002c60:	70a2                	ld	ra,40(sp)
    80002c62:	7402                	ld	s0,32(sp)
    80002c64:	64e2                	ld	s1,24(sp)
    80002c66:	6942                	ld	s2,16(sp)
    80002c68:	69a2                	ld	s3,8(sp)
    80002c6a:	6a02                	ld	s4,0(sp)
    80002c6c:	6145                	addi	sp,sp,48
    80002c6e:	8082                	ret

0000000080002c70 <exit>:
{
    80002c70:	7179                	addi	sp,sp,-48
    80002c72:	f406                	sd	ra,40(sp)
    80002c74:	f022                	sd	s0,32(sp)
    80002c76:	ec26                	sd	s1,24(sp)
    80002c78:	e84a                	sd	s2,16(sp)
    80002c7a:	e44e                	sd	s3,8(sp)
    80002c7c:	e052                	sd	s4,0(sp)
    80002c7e:	1800                	addi	s0,sp,48
    80002c80:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	d1c080e7          	jalr	-740(ra) # 8000199e <myproc>
    80002c8a:	892a                	mv	s2,a0
  if(p == initproc)
    80002c8c:	00007797          	auipc	a5,0x7
    80002c90:	3d47b783          	ld	a5,980(a5) # 8000a060 <initproc>
    80002c94:	0d850493          	addi	s1,a0,216
    80002c98:	15850993          	addi	s3,a0,344
    80002c9c:	02a79363          	bne	a5,a0,80002cc2 <exit+0x52>
    panic("init exiting");
    80002ca0:	00006517          	auipc	a0,0x6
    80002ca4:	5c050513          	addi	a0,a0,1472 # 80009260 <digits+0x220>
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	890080e7          	jalr	-1904(ra) # 80000538 <panic>
      fileclose(f);
    80002cb0:	00003097          	auipc	ra,0x3
    80002cb4:	a5c080e7          	jalr	-1444(ra) # 8000570c <fileclose>
      p->ofile[fd] = 0;
    80002cb8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002cbc:	04a1                	addi	s1,s1,8
    80002cbe:	01348563          	beq	s1,s3,80002cc8 <exit+0x58>
    if(p->ofile[fd]){
    80002cc2:	6088                	ld	a0,0(s1)
    80002cc4:	f575                	bnez	a0,80002cb0 <exit+0x40>
    80002cc6:	bfdd                	j	80002cbc <exit+0x4c>
  begin_op();
    80002cc8:	00002097          	auipc	ra,0x2
    80002ccc:	57c080e7          	jalr	1404(ra) # 80005244 <begin_op>
  iput(p->cwd);
    80002cd0:	15893503          	ld	a0,344(s2)
    80002cd4:	00002097          	auipc	ra,0x2
    80002cd8:	d4e080e7          	jalr	-690(ra) # 80004a22 <iput>
  end_op();
    80002cdc:	00002097          	auipc	ra,0x2
    80002ce0:	5e6080e7          	jalr	1510(ra) # 800052c2 <end_op>
  p->cwd = 0;
    80002ce4:	14093c23          	sd	zero,344(s2)
  acquire(&wait_lock);
    80002ce8:	0000f497          	auipc	s1,0xf
    80002cec:	60048493          	addi	s1,s1,1536 # 800122e8 <wait_lock>
    80002cf0:	8526                	mv	a0,s1
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	edc080e7          	jalr	-292(ra) # 80000bce <acquire>
  reparent(p);
    80002cfa:	854a                	mv	a0,s2
    80002cfc:	00000097          	auipc	ra,0x0
    80002d00:	f1a080e7          	jalr	-230(ra) # 80002c16 <reparent>
  wakeup(p->parent);
    80002d04:	04093503          	ld	a0,64(s2)
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	e4c080e7          	jalr	-436(ra) # 80002b54 <wakeup>
  acquire(&p->lock);
    80002d10:	854a                	mv	a0,s2
    80002d12:	ffffe097          	auipc	ra,0xffffe
    80002d16:	ebc080e7          	jalr	-324(ra) # 80000bce <acquire>
  p->xstate = status;
    80002d1a:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80002d1e:	4795                	li	a5,5
    80002d20:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002d24:	8526                	mv	a0,s1
    80002d26:	ffffe097          	auipc	ra,0xffffe
    80002d2a:	f5c080e7          	jalr	-164(ra) # 80000c82 <release>
  acquire(&tickslock);
    80002d2e:	00016517          	auipc	a0,0x16
    80002d32:	dd250513          	addi	a0,a0,-558 # 80018b00 <tickslock>
    80002d36:	ffffe097          	auipc	ra,0xffffe
    80002d3a:	e98080e7          	jalr	-360(ra) # 80000bce <acquire>
  xticks = ticks;
    80002d3e:	00007497          	auipc	s1,0x7
    80002d42:	32e4a483          	lw	s1,814(s1) # 8000a06c <ticks>
  release(&tickslock);
    80002d46:	00016517          	auipc	a0,0x16
    80002d4a:	dba50513          	addi	a0,a0,-582 # 80018b00 <tickslock>
    80002d4e:	ffffe097          	auipc	ra,0xffffe
    80002d52:	f34080e7          	jalr	-204(ra) # 80000c82 <release>
  p->endtime = xticks;
    80002d56:	0004879b          	sext.w	a5,s1
    80002d5a:	16f92c23          	sw	a5,376(s2)
  if (p->is_batchproc) {
    80002d5e:	03c92703          	lw	a4,60(s2)
    80002d62:	16070763          	beqz	a4,80002ed0 <exit+0x260>
     if ((xticks - p->burst_start) > 0) {
    80002d66:	18492603          	lw	a2,388(s2)
    80002d6a:	0e960063          	beq	a2,s1,80002e4a <exit+0x1da>
        num_cpubursts++;
    80002d6e:	00007697          	auipc	a3,0x7
    80002d72:	2d668693          	addi	a3,a3,726 # 8000a044 <num_cpubursts>
    80002d76:	4298                	lw	a4,0(a3)
    80002d78:	2705                	addiw	a4,a4,1
    80002d7a:	c298                	sw	a4,0(a3)
        cpubursts_tot += (xticks - p->burst_start);
    80002d7c:	40c486bb          	subw	a3,s1,a2
    80002d80:	0006859b          	sext.w	a1,a3
    80002d84:	00007517          	auipc	a0,0x7
    80002d88:	2bc50513          	addi	a0,a0,700 # 8000a040 <cpubursts_tot>
    80002d8c:	4118                	lw	a4,0(a0)
    80002d8e:	9f35                	addw	a4,a4,a3
    80002d90:	c118                	sw	a4,0(a0)
        if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002d92:	00007717          	auipc	a4,0x7
    80002d96:	2aa72703          	lw	a4,682(a4) # 8000a03c <cpubursts_max>
    80002d9a:	00b77663          	bgeu	a4,a1,80002da6 <exit+0x136>
    80002d9e:	00007717          	auipc	a4,0x7
    80002da2:	28d72f23          	sw	a3,670(a4) # 8000a03c <cpubursts_max>
        if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002da6:	00007717          	auipc	a4,0x7
    80002daa:	cd272703          	lw	a4,-814(a4) # 80009a78 <cpubursts_min>
    80002dae:	00e5f663          	bgeu	a1,a4,80002dba <exit+0x14a>
    80002db2:	00007717          	auipc	a4,0x7
    80002db6:	ccd72323          	sw	a3,-826(a4) # 80009a78 <cpubursts_min>
        if (p->nextburst_estimate > 0) {
    80002dba:	18892703          	lw	a4,392(s2)
    80002dbe:	02e05763          	blez	a4,80002dec <exit+0x17c>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002dc2:	0007051b          	sext.w	a0,a4
    80002dc6:	12b56163          	bltu	a0,a1,80002ee8 <exit+0x278>
    80002dca:	9e29                	addw	a2,a2,a0
    80002dcc:	4096053b          	subw	a0,a2,s1
    80002dd0:	00007597          	auipc	a1,0x7
    80002dd4:	25c58593          	addi	a1,a1,604 # 8000a02c <estimation_error>
    80002dd8:	4190                	lw	a2,0(a1)
    80002dda:	9e29                	addw	a2,a2,a0
    80002ddc:	c190                	sw	a2,0(a1)
           estimation_error_instance++;
    80002dde:	00007597          	auipc	a1,0x7
    80002de2:	24a58593          	addi	a1,a1,586 # 8000a028 <estimation_error_instance>
    80002de6:	4190                	lw	a2,0(a1)
    80002de8:	2605                	addiw	a2,a2,1
    80002dea:	c190                	sw	a2,0(a1)
        p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    80002dec:	4609                	li	a2,2
    80002dee:	02c7473b          	divw	a4,a4,a2
    80002df2:	9f35                	addw	a4,a4,a3
    80002df4:	0016d69b          	srliw	a3,a3,0x1
    80002df8:	9f15                	subw	a4,a4,a3
    80002dfa:	0007069b          	sext.w	a3,a4
    80002dfe:	18e92423          	sw	a4,392(s2)
        if (p->nextburst_estimate > 0) {
    80002e02:	04d05463          	blez	a3,80002e4a <exit+0x1da>
           num_cpubursts_est++;
    80002e06:	00007597          	auipc	a1,0x7
    80002e0a:	23258593          	addi	a1,a1,562 # 8000a038 <num_cpubursts_est>
    80002e0e:	4190                	lw	a2,0(a1)
    80002e10:	2605                	addiw	a2,a2,1
    80002e12:	c190                	sw	a2,0(a1)
           cpubursts_est_tot += p->nextburst_estimate;
    80002e14:	00007597          	auipc	a1,0x7
    80002e18:	22058593          	addi	a1,a1,544 # 8000a034 <cpubursts_est_tot>
    80002e1c:	4190                	lw	a2,0(a1)
    80002e1e:	9e39                	addw	a2,a2,a4
    80002e20:	c190                	sw	a2,0(a1)
           if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002e22:	00007617          	auipc	a2,0x7
    80002e26:	20e62603          	lw	a2,526(a2) # 8000a030 <cpubursts_est_max>
    80002e2a:	00d65663          	bge	a2,a3,80002e36 <exit+0x1c6>
    80002e2e:	00007617          	auipc	a2,0x7
    80002e32:	20e62123          	sw	a4,514(a2) # 8000a030 <cpubursts_est_max>
           if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80002e36:	00007617          	auipc	a2,0x7
    80002e3a:	c3e62603          	lw	a2,-962(a2) # 80009a74 <cpubursts_est_min>
    80002e3e:	00c6d663          	bge	a3,a2,80002e4a <exit+0x1da>
    80002e42:	00007697          	auipc	a3,0x7
    80002e46:	c2e6a923          	sw	a4,-974(a3) # 80009a74 <cpubursts_est_min>
     if (p->stime < batch_start) batch_start = p->stime;
    80002e4a:	17492703          	lw	a4,372(s2)
    80002e4e:	00007697          	auipc	a3,0x7
    80002e52:	c326a683          	lw	a3,-974(a3) # 80009a80 <batch_start>
    80002e56:	00d75663          	bge	a4,a3,80002e62 <exit+0x1f2>
    80002e5a:	00007697          	auipc	a3,0x7
    80002e5e:	c2e6a323          	sw	a4,-986(a3) # 80009a80 <batch_start>
     batchsize--;
    80002e62:	00007617          	auipc	a2,0x7
    80002e66:	1fa60613          	addi	a2,a2,506 # 8000a05c <batchsize>
    80002e6a:	4214                	lw	a3,0(a2)
    80002e6c:	36fd                	addiw	a3,a3,-1
    80002e6e:	0006859b          	sext.w	a1,a3
    80002e72:	c214                	sw	a3,0(a2)
     turnaround += (p->endtime - p->stime);
    80002e74:	00007697          	auipc	a3,0x7
    80002e78:	1e068693          	addi	a3,a3,480 # 8000a054 <turnaround>
    80002e7c:	40e7873b          	subw	a4,a5,a4
    80002e80:	4290                	lw	a2,0(a3)
    80002e82:	9f31                	addw	a4,a4,a2
    80002e84:	c298                	sw	a4,0(a3)
     waiting_tot += p->waittime;
    80002e86:	00007697          	auipc	a3,0x7
    80002e8a:	1c668693          	addi	a3,a3,454 # 8000a04c <waiting_tot>
    80002e8e:	17c92603          	lw	a2,380(s2)
    80002e92:	4298                	lw	a4,0(a3)
    80002e94:	9f31                	addw	a4,a4,a2
    80002e96:	c298                	sw	a4,0(a3)
     completion_tot += p->endtime;
    80002e98:	00007697          	auipc	a3,0x7
    80002e9c:	1b868693          	addi	a3,a3,440 # 8000a050 <completion_tot>
    80002ea0:	4298                	lw	a4,0(a3)
    80002ea2:	9f3d                	addw	a4,a4,a5
    80002ea4:	c298                	sw	a4,0(a3)
     if (p->endtime > completion_max) completion_max = p->endtime;
    80002ea6:	00007717          	auipc	a4,0x7
    80002eaa:	1a272703          	lw	a4,418(a4) # 8000a048 <completion_max>
    80002eae:	00f75663          	bge	a4,a5,80002eba <exit+0x24a>
    80002eb2:	00007717          	auipc	a4,0x7
    80002eb6:	18f72b23          	sw	a5,406(a4) # 8000a048 <completion_max>
     if (p->endtime < completion_min) completion_min = p->endtime;
    80002eba:	00007717          	auipc	a4,0x7
    80002ebe:	bc272703          	lw	a4,-1086(a4) # 80009a7c <completion_min>
    80002ec2:	00e7d663          	bge	a5,a4,80002ece <exit+0x25e>
    80002ec6:	00007717          	auipc	a4,0x7
    80002eca:	baf72b23          	sw	a5,-1098(a4) # 80009a7c <completion_min>
     if (batchsize == 0) {
    80002ece:	c185                	beqz	a1,80002eee <exit+0x27e>
  sched();
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	63e080e7          	jalr	1598(ra) # 8000250e <sched>
  panic("zombie exit");
    80002ed8:	00006517          	auipc	a0,0x6
    80002edc:	4d050513          	addi	a0,a0,1232 # 800093a8 <digits+0x368>
    80002ee0:	ffffd097          	auipc	ra,0xffffd
    80002ee4:	658080e7          	jalr	1624(ra) # 80000538 <panic>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002ee8:	40a6853b          	subw	a0,a3,a0
    80002eec:	b5d5                	j	80002dd0 <exit+0x160>
        printf("\nBatch execution time: %d\n", p->endtime - batch_start);
    80002eee:	00007597          	auipc	a1,0x7
    80002ef2:	b925a583          	lw	a1,-1134(a1) # 80009a80 <batch_start>
    80002ef6:	40b785bb          	subw	a1,a5,a1
    80002efa:	00006517          	auipc	a0,0x6
    80002efe:	37650513          	addi	a0,a0,886 # 80009270 <digits+0x230>
    80002f02:	ffffd097          	auipc	ra,0xffffd
    80002f06:	680080e7          	jalr	1664(ra) # 80000582 <printf>
	printf("Average turn-around time: %d\n", turnaround/batchsize2);
    80002f0a:	00007497          	auipc	s1,0x7
    80002f0e:	14e48493          	addi	s1,s1,334 # 8000a058 <batchsize2>
    80002f12:	00007597          	auipc	a1,0x7
    80002f16:	1425a583          	lw	a1,322(a1) # 8000a054 <turnaround>
    80002f1a:	409c                	lw	a5,0(s1)
    80002f1c:	02f5c5bb          	divw	a1,a1,a5
    80002f20:	00006517          	auipc	a0,0x6
    80002f24:	37050513          	addi	a0,a0,880 # 80009290 <digits+0x250>
    80002f28:	ffffd097          	auipc	ra,0xffffd
    80002f2c:	65a080e7          	jalr	1626(ra) # 80000582 <printf>
	printf("Average waiting time: %d\n", waiting_tot/batchsize2);
    80002f30:	00007597          	auipc	a1,0x7
    80002f34:	11c5a583          	lw	a1,284(a1) # 8000a04c <waiting_tot>
    80002f38:	409c                	lw	a5,0(s1)
    80002f3a:	02f5c5bb          	divw	a1,a1,a5
    80002f3e:	00006517          	auipc	a0,0x6
    80002f42:	37250513          	addi	a0,a0,882 # 800092b0 <digits+0x270>
    80002f46:	ffffd097          	auipc	ra,0xffffd
    80002f4a:	63c080e7          	jalr	1596(ra) # 80000582 <printf>
	printf("Completion time: avg: %d, max: %d, min: %d\n", completion_tot/batchsize2, completion_max, completion_min);
    80002f4e:	00007597          	auipc	a1,0x7
    80002f52:	1025a583          	lw	a1,258(a1) # 8000a050 <completion_tot>
    80002f56:	409c                	lw	a5,0(s1)
    80002f58:	00007697          	auipc	a3,0x7
    80002f5c:	b246a683          	lw	a3,-1244(a3) # 80009a7c <completion_min>
    80002f60:	00007617          	auipc	a2,0x7
    80002f64:	0e862603          	lw	a2,232(a2) # 8000a048 <completion_max>
    80002f68:	02f5c5bb          	divw	a1,a1,a5
    80002f6c:	00006517          	auipc	a0,0x6
    80002f70:	36450513          	addi	a0,a0,868 # 800092d0 <digits+0x290>
    80002f74:	ffffd097          	auipc	ra,0xffffd
    80002f78:	60e080e7          	jalr	1550(ra) # 80000582 <printf>
	if ((sched_policy == SCHED_NPREEMPT_FCFS) || (sched_policy == SCHED_NPREEMPT_SJF)) {
    80002f7c:	00007717          	auipc	a4,0x7
    80002f80:	0ec72703          	lw	a4,236(a4) # 8000a068 <sched_policy>
    80002f84:	4785                	li	a5,1
    80002f86:	08e7fb63          	bgeu	a5,a4,8000301c <exit+0x3ac>
	batchsize2 = 0;
    80002f8a:	00007797          	auipc	a5,0x7
    80002f8e:	0c07a723          	sw	zero,206(a5) # 8000a058 <batchsize2>
	batch_start = 0x7FFFFFFF;
    80002f92:	800007b7          	lui	a5,0x80000
    80002f96:	fff7c793          	not	a5,a5
    80002f9a:	00007717          	auipc	a4,0x7
    80002f9e:	aef72323          	sw	a5,-1306(a4) # 80009a80 <batch_start>
	turnaround = 0;
    80002fa2:	00007717          	auipc	a4,0x7
    80002fa6:	0a072923          	sw	zero,178(a4) # 8000a054 <turnaround>
	waiting_tot = 0;
    80002faa:	00007717          	auipc	a4,0x7
    80002fae:	0a072123          	sw	zero,162(a4) # 8000a04c <waiting_tot>
	completion_tot = 0;
    80002fb2:	00007717          	auipc	a4,0x7
    80002fb6:	08072f23          	sw	zero,158(a4) # 8000a050 <completion_tot>
	completion_max = 0;
    80002fba:	00007717          	auipc	a4,0x7
    80002fbe:	08072723          	sw	zero,142(a4) # 8000a048 <completion_max>
	completion_min = 0x7FFFFFFF;
    80002fc2:	00007717          	auipc	a4,0x7
    80002fc6:	aaf72d23          	sw	a5,-1350(a4) # 80009a7c <completion_min>
	num_cpubursts = 0;
    80002fca:	00007717          	auipc	a4,0x7
    80002fce:	06072d23          	sw	zero,122(a4) # 8000a044 <num_cpubursts>
        cpubursts_tot = 0;
    80002fd2:	00007717          	auipc	a4,0x7
    80002fd6:	06072723          	sw	zero,110(a4) # 8000a040 <cpubursts_tot>
        cpubursts_max = 0;
    80002fda:	00007717          	auipc	a4,0x7
    80002fde:	06072123          	sw	zero,98(a4) # 8000a03c <cpubursts_max>
        cpubursts_min = 0x7FFFFFFF;
    80002fe2:	00007717          	auipc	a4,0x7
    80002fe6:	a8f72b23          	sw	a5,-1386(a4) # 80009a78 <cpubursts_min>
	num_cpubursts_est = 0;
    80002fea:	00007717          	auipc	a4,0x7
    80002fee:	04072723          	sw	zero,78(a4) # 8000a038 <num_cpubursts_est>
        cpubursts_est_tot = 0;
    80002ff2:	00007717          	auipc	a4,0x7
    80002ff6:	04072123          	sw	zero,66(a4) # 8000a034 <cpubursts_est_tot>
        cpubursts_est_max = 0;
    80002ffa:	00007717          	auipc	a4,0x7
    80002ffe:	02072b23          	sw	zero,54(a4) # 8000a030 <cpubursts_est_max>
        cpubursts_est_min = 0x7FFFFFFF;
    80003002:	00007717          	auipc	a4,0x7
    80003006:	a6f72923          	sw	a5,-1422(a4) # 80009a74 <cpubursts_est_min>
	estimation_error = 0;
    8000300a:	00007797          	auipc	a5,0x7
    8000300e:	0207a123          	sw	zero,34(a5) # 8000a02c <estimation_error>
        estimation_error_instance = 0;
    80003012:	00007797          	auipc	a5,0x7
    80003016:	0007ab23          	sw	zero,22(a5) # 8000a028 <estimation_error_instance>
    8000301a:	bd5d                	j	80002ed0 <exit+0x260>
	   printf("CPU bursts: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts, cpubursts_tot/num_cpubursts, cpubursts_max, cpubursts_min);
    8000301c:	00007597          	auipc	a1,0x7
    80003020:	0285a583          	lw	a1,40(a1) # 8000a044 <num_cpubursts>
    80003024:	00007617          	auipc	a2,0x7
    80003028:	01c62603          	lw	a2,28(a2) # 8000a040 <cpubursts_tot>
    8000302c:	00007717          	auipc	a4,0x7
    80003030:	a4c72703          	lw	a4,-1460(a4) # 80009a78 <cpubursts_min>
    80003034:	00007697          	auipc	a3,0x7
    80003038:	0086a683          	lw	a3,8(a3) # 8000a03c <cpubursts_max>
    8000303c:	02b6463b          	divw	a2,a2,a1
    80003040:	00006517          	auipc	a0,0x6
    80003044:	2c050513          	addi	a0,a0,704 # 80009300 <digits+0x2c0>
    80003048:	ffffd097          	auipc	ra,0xffffd
    8000304c:	53a080e7          	jalr	1338(ra) # 80000582 <printf>
	   printf("CPU burst estimates: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts_est, cpubursts_est_tot/num_cpubursts_est, cpubursts_est_max, cpubursts_est_min);
    80003050:	00007597          	auipc	a1,0x7
    80003054:	fe85a583          	lw	a1,-24(a1) # 8000a038 <num_cpubursts_est>
    80003058:	00007617          	auipc	a2,0x7
    8000305c:	fdc62603          	lw	a2,-36(a2) # 8000a034 <cpubursts_est_tot>
    80003060:	00007717          	auipc	a4,0x7
    80003064:	a1472703          	lw	a4,-1516(a4) # 80009a74 <cpubursts_est_min>
    80003068:	00007697          	auipc	a3,0x7
    8000306c:	fc86a683          	lw	a3,-56(a3) # 8000a030 <cpubursts_est_max>
    80003070:	02b6463b          	divw	a2,a2,a1
    80003074:	00006517          	auipc	a0,0x6
    80003078:	2c450513          	addi	a0,a0,708 # 80009338 <digits+0x2f8>
    8000307c:	ffffd097          	auipc	ra,0xffffd
    80003080:	506080e7          	jalr	1286(ra) # 80000582 <printf>
	   printf("CPU burst estimation error: count: %d, avg: %d\n", estimation_error_instance, estimation_error/estimation_error_instance);
    80003084:	00007597          	auipc	a1,0x7
    80003088:	fa45a583          	lw	a1,-92(a1) # 8000a028 <estimation_error_instance>
    8000308c:	00007617          	auipc	a2,0x7
    80003090:	fa062603          	lw	a2,-96(a2) # 8000a02c <estimation_error>
    80003094:	02b6463b          	divw	a2,a2,a1
    80003098:	00006517          	auipc	a0,0x6
    8000309c:	2e050513          	addi	a0,a0,736 # 80009378 <digits+0x338>
    800030a0:	ffffd097          	auipc	ra,0xffffd
    800030a4:	4e2080e7          	jalr	1250(ra) # 80000582 <printf>
    800030a8:	b5cd                	j	80002f8a <exit+0x31a>

00000000800030aa <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800030aa:	7179                	addi	sp,sp,-48
    800030ac:	f406                	sd	ra,40(sp)
    800030ae:	f022                	sd	s0,32(sp)
    800030b0:	ec26                	sd	s1,24(sp)
    800030b2:	e84a                	sd	s2,16(sp)
    800030b4:	e44e                	sd	s3,8(sp)
    800030b6:	e052                	sd	s4,0(sp)
    800030b8:	1800                	addi	s0,sp,48
    800030ba:	892a                	mv	s2,a0
  struct proc *p;
  uint xticks;

  acquire(&tickslock);
    800030bc:	00016517          	auipc	a0,0x16
    800030c0:	a4450513          	addi	a0,a0,-1468 # 80018b00 <tickslock>
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	b0a080e7          	jalr	-1270(ra) # 80000bce <acquire>
  xticks = ticks;
    800030cc:	00007a17          	auipc	s4,0x7
    800030d0:	fa0a2a03          	lw	s4,-96(s4) # 8000a06c <ticks>
  release(&tickslock);
    800030d4:	00016517          	auipc	a0,0x16
    800030d8:	a2c50513          	addi	a0,a0,-1492 # 80018b00 <tickslock>
    800030dc:	ffffe097          	auipc	ra,0xffffe
    800030e0:	ba6080e7          	jalr	-1114(ra) # 80000c82 <release>

  for(p = proc; p < &proc[NPROC]; p++){
    800030e4:	0000f497          	auipc	s1,0xf
    800030e8:	61c48493          	addi	s1,s1,1564 # 80012700 <proc>
    800030ec:	00016997          	auipc	s3,0x16
    800030f0:	a1498993          	addi	s3,s3,-1516 # 80018b00 <tickslock>
    acquire(&p->lock);
    800030f4:	8526                	mv	a0,s1
    800030f6:	ffffe097          	auipc	ra,0xffffe
    800030fa:	ad8080e7          	jalr	-1320(ra) # 80000bce <acquire>
    if(p->pid == pid){
    800030fe:	589c                	lw	a5,48(s1)
    80003100:	01278d63          	beq	a5,s2,8000311a <kill+0x70>
	p->waitstart = xticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80003104:	8526                	mv	a0,s1
    80003106:	ffffe097          	auipc	ra,0xffffe
    8000310a:	b7c080e7          	jalr	-1156(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000310e:	19048493          	addi	s1,s1,400
    80003112:	ff3491e3          	bne	s1,s3,800030f4 <kill+0x4a>
  }
  return -1;
    80003116:	557d                	li	a0,-1
    80003118:	a829                	j	80003132 <kill+0x88>
      p->killed = 1;
    8000311a:	4785                	li	a5,1
    8000311c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000311e:	4c98                	lw	a4,24(s1)
    80003120:	4789                	li	a5,2
    80003122:	02f70063          	beq	a4,a5,80003142 <kill+0x98>
      release(&p->lock);
    80003126:	8526                	mv	a0,s1
    80003128:	ffffe097          	auipc	ra,0xffffe
    8000312c:	b5a080e7          	jalr	-1190(ra) # 80000c82 <release>
      return 0;
    80003130:	4501                	li	a0,0
}
    80003132:	70a2                	ld	ra,40(sp)
    80003134:	7402                	ld	s0,32(sp)
    80003136:	64e2                	ld	s1,24(sp)
    80003138:	6942                	ld	s2,16(sp)
    8000313a:	69a2                	ld	s3,8(sp)
    8000313c:	6a02                	ld	s4,0(sp)
    8000313e:	6145                	addi	sp,sp,48
    80003140:	8082                	ret
        p->state = RUNNABLE;
    80003142:	478d                	li	a5,3
    80003144:	cc9c                	sw	a5,24(s1)
	p->waitstart = xticks;
    80003146:	1944a023          	sw	s4,384(s1)
    8000314a:	bff1                	j	80003126 <kill+0x7c>

000000008000314c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000314c:	7179                	addi	sp,sp,-48
    8000314e:	f406                	sd	ra,40(sp)
    80003150:	f022                	sd	s0,32(sp)
    80003152:	ec26                	sd	s1,24(sp)
    80003154:	e84a                	sd	s2,16(sp)
    80003156:	e44e                	sd	s3,8(sp)
    80003158:	e052                	sd	s4,0(sp)
    8000315a:	1800                	addi	s0,sp,48
    8000315c:	84aa                	mv	s1,a0
    8000315e:	892e                	mv	s2,a1
    80003160:	89b2                	mv	s3,a2
    80003162:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80003164:	fffff097          	auipc	ra,0xfffff
    80003168:	83a080e7          	jalr	-1990(ra) # 8000199e <myproc>
  if(user_dst){
    8000316c:	c08d                	beqz	s1,8000318e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000316e:	86d2                	mv	a3,s4
    80003170:	864e                	mv	a2,s3
    80003172:	85ca                	mv	a1,s2
    80003174:	6d28                	ld	a0,88(a0)
    80003176:	ffffe097          	auipc	ra,0xffffe
    8000317a:	4ec080e7          	jalr	1260(ra) # 80001662 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000317e:	70a2                	ld	ra,40(sp)
    80003180:	7402                	ld	s0,32(sp)
    80003182:	64e2                	ld	s1,24(sp)
    80003184:	6942                	ld	s2,16(sp)
    80003186:	69a2                	ld	s3,8(sp)
    80003188:	6a02                	ld	s4,0(sp)
    8000318a:	6145                	addi	sp,sp,48
    8000318c:	8082                	ret
    memmove((char *)dst, src, len);
    8000318e:	000a061b          	sext.w	a2,s4
    80003192:	85ce                	mv	a1,s3
    80003194:	854a                	mv	a0,s2
    80003196:	ffffe097          	auipc	ra,0xffffe
    8000319a:	b90080e7          	jalr	-1136(ra) # 80000d26 <memmove>
    return 0;
    8000319e:	8526                	mv	a0,s1
    800031a0:	bff9                	j	8000317e <either_copyout+0x32>

00000000800031a2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800031a2:	7179                	addi	sp,sp,-48
    800031a4:	f406                	sd	ra,40(sp)
    800031a6:	f022                	sd	s0,32(sp)
    800031a8:	ec26                	sd	s1,24(sp)
    800031aa:	e84a                	sd	s2,16(sp)
    800031ac:	e44e                	sd	s3,8(sp)
    800031ae:	e052                	sd	s4,0(sp)
    800031b0:	1800                	addi	s0,sp,48
    800031b2:	892a                	mv	s2,a0
    800031b4:	84ae                	mv	s1,a1
    800031b6:	89b2                	mv	s3,a2
    800031b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800031ba:	ffffe097          	auipc	ra,0xffffe
    800031be:	7e4080e7          	jalr	2020(ra) # 8000199e <myproc>
  if(user_src){
    800031c2:	c08d                	beqz	s1,800031e4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800031c4:	86d2                	mv	a3,s4
    800031c6:	864e                	mv	a2,s3
    800031c8:	85ca                	mv	a1,s2
    800031ca:	6d28                	ld	a0,88(a0)
    800031cc:	ffffe097          	auipc	ra,0xffffe
    800031d0:	522080e7          	jalr	1314(ra) # 800016ee <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800031d4:	70a2                	ld	ra,40(sp)
    800031d6:	7402                	ld	s0,32(sp)
    800031d8:	64e2                	ld	s1,24(sp)
    800031da:	6942                	ld	s2,16(sp)
    800031dc:	69a2                	ld	s3,8(sp)
    800031de:	6a02                	ld	s4,0(sp)
    800031e0:	6145                	addi	sp,sp,48
    800031e2:	8082                	ret
    memmove(dst, (char*)src, len);
    800031e4:	000a061b          	sext.w	a2,s4
    800031e8:	85ce                	mv	a1,s3
    800031ea:	854a                	mv	a0,s2
    800031ec:	ffffe097          	auipc	ra,0xffffe
    800031f0:	b3a080e7          	jalr	-1222(ra) # 80000d26 <memmove>
    return 0;
    800031f4:	8526                	mv	a0,s1
    800031f6:	bff9                	j	800031d4 <either_copyin+0x32>

00000000800031f8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800031f8:	715d                	addi	sp,sp,-80
    800031fa:	e486                	sd	ra,72(sp)
    800031fc:	e0a2                	sd	s0,64(sp)
    800031fe:	fc26                	sd	s1,56(sp)
    80003200:	f84a                	sd	s2,48(sp)
    80003202:	f44e                	sd	s3,40(sp)
    80003204:	f052                	sd	s4,32(sp)
    80003206:	ec56                	sd	s5,24(sp)
    80003208:	e85a                	sd	s6,16(sp)
    8000320a:	e45e                	sd	s7,8(sp)
    8000320c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000320e:	00006517          	auipc	a0,0x6
    80003212:	53a50513          	addi	a0,a0,1338 # 80009748 <syscalls+0x108>
    80003216:	ffffd097          	auipc	ra,0xffffd
    8000321a:	36c080e7          	jalr	876(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000321e:	0000f497          	auipc	s1,0xf
    80003222:	64248493          	addi	s1,s1,1602 # 80012860 <proc+0x160>
    80003226:	00016917          	auipc	s2,0x16
    8000322a:	a3a90913          	addi	s2,s2,-1478 # 80018c60 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000322e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80003230:	00006997          	auipc	s3,0x6
    80003234:	18898993          	addi	s3,s3,392 # 800093b8 <digits+0x378>
    printf("%d %s %s", p->pid, state, p->name);
    80003238:	00006a97          	auipc	s5,0x6
    8000323c:	188a8a93          	addi	s5,s5,392 # 800093c0 <digits+0x380>
    printf("\n");
    80003240:	00006a17          	auipc	s4,0x6
    80003244:	508a0a13          	addi	s4,s4,1288 # 80009748 <syscalls+0x108>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003248:	00006b97          	auipc	s7,0x6
    8000324c:	210b8b93          	addi	s7,s7,528 # 80009458 <states.2>
    80003250:	a00d                	j	80003272 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80003252:	ed06a583          	lw	a1,-304(a3)
    80003256:	8556                	mv	a0,s5
    80003258:	ffffd097          	auipc	ra,0xffffd
    8000325c:	32a080e7          	jalr	810(ra) # 80000582 <printf>
    printf("\n");
    80003260:	8552                	mv	a0,s4
    80003262:	ffffd097          	auipc	ra,0xffffd
    80003266:	320080e7          	jalr	800(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000326a:	19048493          	addi	s1,s1,400
    8000326e:	03248263          	beq	s1,s2,80003292 <procdump+0x9a>
    if(p->state == UNUSED)
    80003272:	86a6                	mv	a3,s1
    80003274:	eb84a783          	lw	a5,-328(s1)
    80003278:	dbed                	beqz	a5,8000326a <procdump+0x72>
      state = "???";
    8000327a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000327c:	fcfb6be3          	bltu	s6,a5,80003252 <procdump+0x5a>
    80003280:	02079713          	slli	a4,a5,0x20
    80003284:	01d75793          	srli	a5,a4,0x1d
    80003288:	97de                	add	a5,a5,s7
    8000328a:	6390                	ld	a2,0(a5)
    8000328c:	f279                	bnez	a2,80003252 <procdump+0x5a>
      state = "???";
    8000328e:	864e                	mv	a2,s3
    80003290:	b7c9                	j	80003252 <procdump+0x5a>
  }
}
    80003292:	60a6                	ld	ra,72(sp)
    80003294:	6406                	ld	s0,64(sp)
    80003296:	74e2                	ld	s1,56(sp)
    80003298:	7942                	ld	s2,48(sp)
    8000329a:	79a2                	ld	s3,40(sp)
    8000329c:	7a02                	ld	s4,32(sp)
    8000329e:	6ae2                	ld	s5,24(sp)
    800032a0:	6b42                	ld	s6,16(sp)
    800032a2:	6ba2                	ld	s7,8(sp)
    800032a4:	6161                	addi	sp,sp,80
    800032a6:	8082                	ret

00000000800032a8 <ps>:

// Print a process listing to console with proper locks held.
// Caution: don't invoke too often; can slow down the machine.
int
ps(void)
{
    800032a8:	7119                	addi	sp,sp,-128
    800032aa:	fc86                	sd	ra,120(sp)
    800032ac:	f8a2                	sd	s0,112(sp)
    800032ae:	f4a6                	sd	s1,104(sp)
    800032b0:	f0ca                	sd	s2,96(sp)
    800032b2:	ecce                	sd	s3,88(sp)
    800032b4:	e8d2                	sd	s4,80(sp)
    800032b6:	e4d6                	sd	s5,72(sp)
    800032b8:	e0da                	sd	s6,64(sp)
    800032ba:	fc5e                	sd	s7,56(sp)
    800032bc:	f862                	sd	s8,48(sp)
    800032be:	f466                	sd	s9,40(sp)
    800032c0:	f06a                	sd	s10,32(sp)
    800032c2:	ec6e                	sd	s11,24(sp)
    800032c4:	0100                	addi	s0,sp,128
  struct proc *p;
  char *state;
  int ppid, pid;
  uint xticks;

  printf("\n");
    800032c6:	00006517          	auipc	a0,0x6
    800032ca:	48250513          	addi	a0,a0,1154 # 80009748 <syscalls+0x108>
    800032ce:	ffffd097          	auipc	ra,0xffffd
    800032d2:	2b4080e7          	jalr	692(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800032d6:	0000f497          	auipc	s1,0xf
    800032da:	42a48493          	addi	s1,s1,1066 # 80012700 <proc>
    acquire(&p->lock);
    if(p->state == UNUSED) {
      release(&p->lock);
      continue;
    }
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800032de:	4d95                	li	s11,5
    else
      state = "???";

    pid = p->pid;
    release(&p->lock);
    acquire(&wait_lock);
    800032e0:	0000fb97          	auipc	s7,0xf
    800032e4:	008b8b93          	addi	s7,s7,8 # 800122e8 <wait_lock>
    if (p->parent) {
       acquire(&p->parent->lock);
       ppid = p->parent->pid;
       release(&p->parent->lock);
    }
    else ppid = -1;
    800032e8:	5b7d                	li	s6,-1
    release(&wait_lock);

    acquire(&tickslock);
    800032ea:	00016a97          	auipc	s5,0x16
    800032ee:	816a8a93          	addi	s5,s5,-2026 # 80018b00 <tickslock>
  for(p = proc; p < &proc[NPROC]; p++){
    800032f2:	00016d17          	auipc	s10,0x16
    800032f6:	80ed0d13          	addi	s10,s10,-2034 # 80018b00 <tickslock>
    800032fa:	a85d                	j	800033b0 <ps+0x108>
      release(&p->lock);
    800032fc:	8526                	mv	a0,s1
    800032fe:	ffffe097          	auipc	ra,0xffffe
    80003302:	984080e7          	jalr	-1660(ra) # 80000c82 <release>
      continue;
    80003306:	a04d                	j	800033a8 <ps+0x100>
    pid = p->pid;
    80003308:	0304ac03          	lw	s8,48(s1)
    release(&p->lock);
    8000330c:	8526                	mv	a0,s1
    8000330e:	ffffe097          	auipc	ra,0xffffe
    80003312:	974080e7          	jalr	-1676(ra) # 80000c82 <release>
    acquire(&wait_lock);
    80003316:	855e                	mv	a0,s7
    80003318:	ffffe097          	auipc	ra,0xffffe
    8000331c:	8b6080e7          	jalr	-1866(ra) # 80000bce <acquire>
    if (p->parent) {
    80003320:	60a8                	ld	a0,64(s1)
    else ppid = -1;
    80003322:	8a5a                	mv	s4,s6
    if (p->parent) {
    80003324:	cd01                	beqz	a0,8000333c <ps+0x94>
       acquire(&p->parent->lock);
    80003326:	ffffe097          	auipc	ra,0xffffe
    8000332a:	8a8080e7          	jalr	-1880(ra) # 80000bce <acquire>
       ppid = p->parent->pid;
    8000332e:	60a8                	ld	a0,64(s1)
    80003330:	03052a03          	lw	s4,48(a0)
       release(&p->parent->lock);
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	94e080e7          	jalr	-1714(ra) # 80000c82 <release>
    release(&wait_lock);
    8000333c:	855e                	mv	a0,s7
    8000333e:	ffffe097          	auipc	ra,0xffffe
    80003342:	944080e7          	jalr	-1724(ra) # 80000c82 <release>
    acquire(&tickslock);
    80003346:	8556                	mv	a0,s5
    80003348:	ffffe097          	auipc	ra,0xffffe
    8000334c:	886080e7          	jalr	-1914(ra) # 80000bce <acquire>
    xticks = ticks;
    80003350:	00007797          	auipc	a5,0x7
    80003354:	d1c78793          	addi	a5,a5,-740 # 8000a06c <ticks>
    80003358:	0007ac83          	lw	s9,0(a5)
    release(&tickslock);
    8000335c:	8556                	mv	a0,s5
    8000335e:	ffffe097          	auipc	ra,0xffffe
    80003362:	924080e7          	jalr	-1756(ra) # 80000c82 <release>

    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    80003366:	16090713          	addi	a4,s2,352
    8000336a:	1704a783          	lw	a5,368(s1)
    8000336e:	1744a803          	lw	a6,372(s1)
    80003372:	1784a683          	lw	a3,376(s1)
    80003376:	410688bb          	subw	a7,a3,a6
    8000337a:	07668b63          	beq	a3,s6,800033f0 <ps+0x148>
    8000337e:	68b4                	ld	a3,80(s1)
    80003380:	e036                	sd	a3,0(sp)
    80003382:	86ce                	mv	a3,s3
    80003384:	8652                	mv	a2,s4
    80003386:	85e2                	mv	a1,s8
    80003388:	00006517          	auipc	a0,0x6
    8000338c:	04850513          	addi	a0,a0,72 # 800093d0 <digits+0x390>
    80003390:	ffffd097          	auipc	ra,0xffffd
    80003394:	1f2080e7          	jalr	498(ra) # 80000582 <printf>
    printf("\n");
    80003398:	00006517          	auipc	a0,0x6
    8000339c:	3b050513          	addi	a0,a0,944 # 80009748 <syscalls+0x108>
    800033a0:	ffffd097          	auipc	ra,0xffffd
    800033a4:	1e2080e7          	jalr	482(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800033a8:	19048493          	addi	s1,s1,400
    800033ac:	05a48563          	beq	s1,s10,800033f6 <ps+0x14e>
    acquire(&p->lock);
    800033b0:	8926                	mv	s2,s1
    800033b2:	8526                	mv	a0,s1
    800033b4:	ffffe097          	auipc	ra,0xffffe
    800033b8:	81a080e7          	jalr	-2022(ra) # 80000bce <acquire>
    if(p->state == UNUSED) {
    800033bc:	4c9c                	lw	a5,24(s1)
    800033be:	df9d                	beqz	a5,800032fc <ps+0x54>
      state = "???";
    800033c0:	00006997          	auipc	s3,0x6
    800033c4:	ff898993          	addi	s3,s3,-8 # 800093b8 <digits+0x378>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800033c8:	f4fde0e3          	bltu	s11,a5,80003308 <ps+0x60>
    800033cc:	02079713          	slli	a4,a5,0x20
    800033d0:	01d75793          	srli	a5,a4,0x1d
    800033d4:	00006717          	auipc	a4,0x6
    800033d8:	08470713          	addi	a4,a4,132 # 80009458 <states.2>
    800033dc:	97ba                	add	a5,a5,a4
    800033de:	0307b983          	ld	s3,48(a5)
    800033e2:	f20993e3          	bnez	s3,80003308 <ps+0x60>
      state = "???";
    800033e6:	00006997          	auipc	s3,0x6
    800033ea:	fd298993          	addi	s3,s3,-46 # 800093b8 <digits+0x378>
    800033ee:	bf29                	j	80003308 <ps+0x60>
    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    800033f0:	410c88bb          	subw	a7,s9,a6
    800033f4:	b769                	j	8000337e <ps+0xd6>
  }
  return 0;
}
    800033f6:	4501                	li	a0,0
    800033f8:	70e6                	ld	ra,120(sp)
    800033fa:	7446                	ld	s0,112(sp)
    800033fc:	74a6                	ld	s1,104(sp)
    800033fe:	7906                	ld	s2,96(sp)
    80003400:	69e6                	ld	s3,88(sp)
    80003402:	6a46                	ld	s4,80(sp)
    80003404:	6aa6                	ld	s5,72(sp)
    80003406:	6b06                	ld	s6,64(sp)
    80003408:	7be2                	ld	s7,56(sp)
    8000340a:	7c42                	ld	s8,48(sp)
    8000340c:	7ca2                	ld	s9,40(sp)
    8000340e:	7d02                	ld	s10,32(sp)
    80003410:	6de2                	ld	s11,24(sp)
    80003412:	6109                	addi	sp,sp,128
    80003414:	8082                	ret

0000000080003416 <pinfo>:

int
pinfo(int pid, uint64 addr)
{
    80003416:	7159                	addi	sp,sp,-112
    80003418:	f486                	sd	ra,104(sp)
    8000341a:	f0a2                	sd	s0,96(sp)
    8000341c:	eca6                	sd	s1,88(sp)
    8000341e:	e8ca                	sd	s2,80(sp)
    80003420:	e4ce                	sd	s3,72(sp)
    80003422:	e0d2                	sd	s4,64(sp)
    80003424:	1880                	addi	s0,sp,112
    80003426:	892a                	mv	s2,a0
    80003428:	89ae                	mv	s3,a1
  struct proc *p;
  char *state;
  uint xticks;
  int found=0;

  if (pid == -1) {
    8000342a:	57fd                	li	a5,-1
     p = myproc();
     acquire(&p->lock);
     found=1;
  }
  else {
     for(p = proc; p < &proc[NPROC]; p++){
    8000342c:	0000f497          	auipc	s1,0xf
    80003430:	2d448493          	addi	s1,s1,724 # 80012700 <proc>
    80003434:	00015a17          	auipc	s4,0x15
    80003438:	6cca0a13          	addi	s4,s4,1740 # 80018b00 <tickslock>
  if (pid == -1) {
    8000343c:	02f51563          	bne	a0,a5,80003466 <pinfo+0x50>
     p = myproc();
    80003440:	ffffe097          	auipc	ra,0xffffe
    80003444:	55e080e7          	jalr	1374(ra) # 8000199e <myproc>
    80003448:	84aa                	mv	s1,a0
     acquire(&p->lock);
    8000344a:	ffffd097          	auipc	ra,0xffffd
    8000344e:	784080e7          	jalr	1924(ra) # 80000bce <acquire>
         found=1;
         break;
       }
     }
  }
  if (found) {
    80003452:	a025                	j	8000347a <pinfo+0x64>
         release(&p->lock);
    80003454:	8526                	mv	a0,s1
    80003456:	ffffe097          	auipc	ra,0xffffe
    8000345a:	82c080e7          	jalr	-2004(ra) # 80000c82 <release>
     for(p = proc; p < &proc[NPROC]; p++){
    8000345e:	19048493          	addi	s1,s1,400
    80003462:	13448e63          	beq	s1,s4,8000359e <pinfo+0x188>
       acquire(&p->lock);
    80003466:	8526                	mv	a0,s1
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	766080e7          	jalr	1894(ra) # 80000bce <acquire>
       if((p->state == UNUSED) || (p->pid != pid)) {
    80003470:	4c9c                	lw	a5,24(s1)
    80003472:	d3ed                	beqz	a5,80003454 <pinfo+0x3e>
    80003474:	589c                	lw	a5,48(s1)
    80003476:	fd279fe3          	bne	a5,s2,80003454 <pinfo+0x3e>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000347a:	4c9c                	lw	a5,24(s1)
    8000347c:	4715                	li	a4,5
         state = states[p->state];
     else
         state = "???";
    8000347e:	00006917          	auipc	s2,0x6
    80003482:	f3a90913          	addi	s2,s2,-198 # 800093b8 <digits+0x378>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003486:	00f76f63          	bltu	a4,a5,800034a4 <pinfo+0x8e>
    8000348a:	02079713          	slli	a4,a5,0x20
    8000348e:	01d75793          	srli	a5,a4,0x1d
    80003492:	00006717          	auipc	a4,0x6
    80003496:	fc670713          	addi	a4,a4,-58 # 80009458 <states.2>
    8000349a:	97ba                	add	a5,a5,a4
    8000349c:	0607b903          	ld	s2,96(a5)
    800034a0:	10090163          	beqz	s2,800035a2 <pinfo+0x18c>

     pstat.pid = p->pid;
    800034a4:	589c                	lw	a5,48(s1)
    800034a6:	f8f42c23          	sw	a5,-104(s0)
     release(&p->lock);
    800034aa:	8526                	mv	a0,s1
    800034ac:	ffffd097          	auipc	ra,0xffffd
    800034b0:	7d6080e7          	jalr	2006(ra) # 80000c82 <release>
     acquire(&wait_lock);
    800034b4:	0000f517          	auipc	a0,0xf
    800034b8:	e3450513          	addi	a0,a0,-460 # 800122e8 <wait_lock>
    800034bc:	ffffd097          	auipc	ra,0xffffd
    800034c0:	712080e7          	jalr	1810(ra) # 80000bce <acquire>
     if (p->parent) {
    800034c4:	60a8                	ld	a0,64(s1)
    800034c6:	c17d                	beqz	a0,800035ac <pinfo+0x196>
        acquire(&p->parent->lock);
    800034c8:	ffffd097          	auipc	ra,0xffffd
    800034cc:	706080e7          	jalr	1798(ra) # 80000bce <acquire>
        pstat.ppid = p->parent->pid;
    800034d0:	60a8                	ld	a0,64(s1)
    800034d2:	591c                	lw	a5,48(a0)
    800034d4:	f8f42e23          	sw	a5,-100(s0)
        release(&p->parent->lock);
    800034d8:	ffffd097          	auipc	ra,0xffffd
    800034dc:	7aa080e7          	jalr	1962(ra) # 80000c82 <release>
     }
     else pstat.ppid = -1;
     release(&wait_lock);
    800034e0:	0000f517          	auipc	a0,0xf
    800034e4:	e0850513          	addi	a0,a0,-504 # 800122e8 <wait_lock>
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	79a080e7          	jalr	1946(ra) # 80000c82 <release>

     acquire(&tickslock);
    800034f0:	00015517          	auipc	a0,0x15
    800034f4:	61050513          	addi	a0,a0,1552 # 80018b00 <tickslock>
    800034f8:	ffffd097          	auipc	ra,0xffffd
    800034fc:	6d6080e7          	jalr	1750(ra) # 80000bce <acquire>
     xticks = ticks;
    80003500:	00007a17          	auipc	s4,0x7
    80003504:	b6ca2a03          	lw	s4,-1172(s4) # 8000a06c <ticks>
     release(&tickslock);
    80003508:	00015517          	auipc	a0,0x15
    8000350c:	5f850513          	addi	a0,a0,1528 # 80018b00 <tickslock>
    80003510:	ffffd097          	auipc	ra,0xffffd
    80003514:	772080e7          	jalr	1906(ra) # 80000c82 <release>

     safestrcpy(&pstat.state[0], state, strlen(state)+1);
    80003518:	854a                	mv	a0,s2
    8000351a:	ffffe097          	auipc	ra,0xffffe
    8000351e:	92c080e7          	jalr	-1748(ra) # 80000e46 <strlen>
    80003522:	0015061b          	addiw	a2,a0,1
    80003526:	85ca                	mv	a1,s2
    80003528:	fa040513          	addi	a0,s0,-96
    8000352c:	ffffe097          	auipc	ra,0xffffe
    80003530:	8e8080e7          	jalr	-1816(ra) # 80000e14 <safestrcpy>
     safestrcpy(&pstat.command[0], &p->name[0], sizeof(p->name));
    80003534:	4641                	li	a2,16
    80003536:	16048593          	addi	a1,s1,352
    8000353a:	fa840513          	addi	a0,s0,-88
    8000353e:	ffffe097          	auipc	ra,0xffffe
    80003542:	8d6080e7          	jalr	-1834(ra) # 80000e14 <safestrcpy>
     pstat.ctime = p->ctime;
    80003546:	1704a783          	lw	a5,368(s1)
    8000354a:	faf42c23          	sw	a5,-72(s0)
     pstat.stime = p->stime;
    8000354e:	1744a783          	lw	a5,372(s1)
    80003552:	faf42e23          	sw	a5,-68(s0)
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    80003556:	1784a703          	lw	a4,376(s1)
    8000355a:	567d                	li	a2,-1
    8000355c:	40f706bb          	subw	a3,a4,a5
    80003560:	04c70a63          	beq	a4,a2,800035b4 <pinfo+0x19e>
    80003564:	fcd42023          	sw	a3,-64(s0)
     pstat.size = p->sz;
    80003568:	68bc                	ld	a5,80(s1)
    8000356a:	fcf43423          	sd	a5,-56(s0)
     if(copyout(myproc()->pagetable, addr, (char *)&pstat, sizeof(pstat)) < 0) return -1;
    8000356e:	ffffe097          	auipc	ra,0xffffe
    80003572:	430080e7          	jalr	1072(ra) # 8000199e <myproc>
    80003576:	03800693          	li	a3,56
    8000357a:	f9840613          	addi	a2,s0,-104
    8000357e:	85ce                	mv	a1,s3
    80003580:	6d28                	ld	a0,88(a0)
    80003582:	ffffe097          	auipc	ra,0xffffe
    80003586:	0e0080e7          	jalr	224(ra) # 80001662 <copyout>
    8000358a:	41f5551b          	sraiw	a0,a0,0x1f
     return 0;
  }
  else return -1;
}
    8000358e:	70a6                	ld	ra,104(sp)
    80003590:	7406                	ld	s0,96(sp)
    80003592:	64e6                	ld	s1,88(sp)
    80003594:	6946                	ld	s2,80(sp)
    80003596:	69a6                	ld	s3,72(sp)
    80003598:	6a06                	ld	s4,64(sp)
    8000359a:	6165                	addi	sp,sp,112
    8000359c:	8082                	ret
  else return -1;
    8000359e:	557d                	li	a0,-1
    800035a0:	b7fd                	j	8000358e <pinfo+0x178>
         state = "???";
    800035a2:	00006917          	auipc	s2,0x6
    800035a6:	e1690913          	addi	s2,s2,-490 # 800093b8 <digits+0x378>
    800035aa:	bded                	j	800034a4 <pinfo+0x8e>
     else pstat.ppid = -1;
    800035ac:	57fd                	li	a5,-1
    800035ae:	f8f42e23          	sw	a5,-100(s0)
    800035b2:	b73d                	j	800034e0 <pinfo+0xca>
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    800035b4:	40fa06bb          	subw	a3,s4,a5
    800035b8:	b775                	j	80003564 <pinfo+0x14e>

00000000800035ba <schedpolicy>:

int
schedpolicy(int x)
{
    800035ba:	1141                	addi	sp,sp,-16
    800035bc:	e422                	sd	s0,8(sp)
    800035be:	0800                	addi	s0,sp,16
   int y = sched_policy;
    800035c0:	00007797          	auipc	a5,0x7
    800035c4:	aa878793          	addi	a5,a5,-1368 # 8000a068 <sched_policy>
    800035c8:	4398                	lw	a4,0(a5)
   sched_policy = x;
    800035ca:	c388                	sw	a0,0(a5)
   return y;
}
    800035cc:	853a                	mv	a0,a4
    800035ce:	6422                	ld	s0,8(sp)
    800035d0:	0141                	addi	sp,sp,16
    800035d2:	8082                	ret

00000000800035d4 <swtch>:
    800035d4:	00153023          	sd	ra,0(a0)
    800035d8:	00253423          	sd	sp,8(a0)
    800035dc:	e900                	sd	s0,16(a0)
    800035de:	ed04                	sd	s1,24(a0)
    800035e0:	03253023          	sd	s2,32(a0)
    800035e4:	03353423          	sd	s3,40(a0)
    800035e8:	03453823          	sd	s4,48(a0)
    800035ec:	03553c23          	sd	s5,56(a0)
    800035f0:	05653023          	sd	s6,64(a0)
    800035f4:	05753423          	sd	s7,72(a0)
    800035f8:	05853823          	sd	s8,80(a0)
    800035fc:	05953c23          	sd	s9,88(a0)
    80003600:	07a53023          	sd	s10,96(a0)
    80003604:	07b53423          	sd	s11,104(a0)
    80003608:	0005b083          	ld	ra,0(a1)
    8000360c:	0085b103          	ld	sp,8(a1)
    80003610:	6980                	ld	s0,16(a1)
    80003612:	6d84                	ld	s1,24(a1)
    80003614:	0205b903          	ld	s2,32(a1)
    80003618:	0285b983          	ld	s3,40(a1)
    8000361c:	0305ba03          	ld	s4,48(a1)
    80003620:	0385ba83          	ld	s5,56(a1)
    80003624:	0405bb03          	ld	s6,64(a1)
    80003628:	0485bb83          	ld	s7,72(a1)
    8000362c:	0505bc03          	ld	s8,80(a1)
    80003630:	0585bc83          	ld	s9,88(a1)
    80003634:	0605bd03          	ld	s10,96(a1)
    80003638:	0685bd83          	ld	s11,104(a1)
    8000363c:	8082                	ret

000000008000363e <trapinit>:

extern int sched_policy;

void
trapinit(void)
{
    8000363e:	1141                	addi	sp,sp,-16
    80003640:	e406                	sd	ra,8(sp)
    80003642:	e022                	sd	s0,0(sp)
    80003644:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003646:	00006597          	auipc	a1,0x6
    8000364a:	ea258593          	addi	a1,a1,-350 # 800094e8 <states.0+0x30>
    8000364e:	00015517          	auipc	a0,0x15
    80003652:	4b250513          	addi	a0,a0,1202 # 80018b00 <tickslock>
    80003656:	ffffd097          	auipc	ra,0xffffd
    8000365a:	4e8080e7          	jalr	1256(ra) # 80000b3e <initlock>
}
    8000365e:	60a2                	ld	ra,8(sp)
    80003660:	6402                	ld	s0,0(sp)
    80003662:	0141                	addi	sp,sp,16
    80003664:	8082                	ret

0000000080003666 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003666:	1141                	addi	sp,sp,-16
    80003668:	e422                	sd	s0,8(sp)
    8000366a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000366c:	00003797          	auipc	a5,0x3
    80003670:	6d478793          	addi	a5,a5,1748 # 80006d40 <kernelvec>
    80003674:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003678:	6422                	ld	s0,8(sp)
    8000367a:	0141                	addi	sp,sp,16
    8000367c:	8082                	ret

000000008000367e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000367e:	1141                	addi	sp,sp,-16
    80003680:	e406                	sd	ra,8(sp)
    80003682:	e022                	sd	s0,0(sp)
    80003684:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003686:	ffffe097          	auipc	ra,0xffffe
    8000368a:	318080e7          	jalr	792(ra) # 8000199e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000368e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003692:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003694:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003698:	00005697          	auipc	a3,0x5
    8000369c:	96868693          	addi	a3,a3,-1688 # 80008000 <_trampoline>
    800036a0:	00005717          	auipc	a4,0x5
    800036a4:	96070713          	addi	a4,a4,-1696 # 80008000 <_trampoline>
    800036a8:	8f15                	sub	a4,a4,a3
    800036aa:	040007b7          	lui	a5,0x4000
    800036ae:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800036b0:	07b2                	slli	a5,a5,0xc
    800036b2:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800036b4:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800036b8:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800036ba:	18002673          	csrr	a2,satp
    800036be:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800036c0:	7130                	ld	a2,96(a0)
    800036c2:	6538                	ld	a4,72(a0)
    800036c4:	6585                	lui	a1,0x1
    800036c6:	972e                	add	a4,a4,a1
    800036c8:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800036ca:	7138                	ld	a4,96(a0)
    800036cc:	00000617          	auipc	a2,0x0
    800036d0:	13860613          	addi	a2,a2,312 # 80003804 <usertrap>
    800036d4:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800036d6:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800036d8:	8612                	mv	a2,tp
    800036da:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800036dc:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800036e0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800036e4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800036e8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800036ec:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800036ee:	6f18                	ld	a4,24(a4)
    800036f0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800036f4:	6d2c                	ld	a1,88(a0)
    800036f6:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800036f8:	00005717          	auipc	a4,0x5
    800036fc:	99870713          	addi	a4,a4,-1640 # 80008090 <userret>
    80003700:	8f15                	sub	a4,a4,a3
    80003702:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80003704:	577d                	li	a4,-1
    80003706:	177e                	slli	a4,a4,0x3f
    80003708:	8dd9                	or	a1,a1,a4
    8000370a:	02000537          	lui	a0,0x2000
    8000370e:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80003710:	0536                	slli	a0,a0,0xd
    80003712:	9782                	jalr	a5
}
    80003714:	60a2                	ld	ra,8(sp)
    80003716:	6402                	ld	s0,0(sp)
    80003718:	0141                	addi	sp,sp,16
    8000371a:	8082                	ret

000000008000371c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000371c:	1101                	addi	sp,sp,-32
    8000371e:	ec06                	sd	ra,24(sp)
    80003720:	e822                	sd	s0,16(sp)
    80003722:	e426                	sd	s1,8(sp)
    80003724:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003726:	00015497          	auipc	s1,0x15
    8000372a:	3da48493          	addi	s1,s1,986 # 80018b00 <tickslock>
    8000372e:	8526                	mv	a0,s1
    80003730:	ffffd097          	auipc	ra,0xffffd
    80003734:	49e080e7          	jalr	1182(ra) # 80000bce <acquire>
  ticks++;
    80003738:	00007517          	auipc	a0,0x7
    8000373c:	93450513          	addi	a0,a0,-1740 # 8000a06c <ticks>
    80003740:	411c                	lw	a5,0(a0)
    80003742:	2785                	addiw	a5,a5,1
    80003744:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003746:	fffff097          	auipc	ra,0xfffff
    8000374a:	40e080e7          	jalr	1038(ra) # 80002b54 <wakeup>
  release(&tickslock);
    8000374e:	8526                	mv	a0,s1
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	532080e7          	jalr	1330(ra) # 80000c82 <release>
}
    80003758:	60e2                	ld	ra,24(sp)
    8000375a:	6442                	ld	s0,16(sp)
    8000375c:	64a2                	ld	s1,8(sp)
    8000375e:	6105                	addi	sp,sp,32
    80003760:	8082                	ret

0000000080003762 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003762:	1101                	addi	sp,sp,-32
    80003764:	ec06                	sd	ra,24(sp)
    80003766:	e822                	sd	s0,16(sp)
    80003768:	e426                	sd	s1,8(sp)
    8000376a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000376c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80003770:	00074d63          	bltz	a4,8000378a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003774:	57fd                	li	a5,-1
    80003776:	17fe                	slli	a5,a5,0x3f
    80003778:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000377a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000377c:	06f70363          	beq	a4,a5,800037e2 <devintr+0x80>
  }
}
    80003780:	60e2                	ld	ra,24(sp)
    80003782:	6442                	ld	s0,16(sp)
    80003784:	64a2                	ld	s1,8(sp)
    80003786:	6105                	addi	sp,sp,32
    80003788:	8082                	ret
     (scause & 0xff) == 9){
    8000378a:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    8000378e:	46a5                	li	a3,9
    80003790:	fed792e3          	bne	a5,a3,80003774 <devintr+0x12>
    int irq = plic_claim();
    80003794:	00003097          	auipc	ra,0x3
    80003798:	6b4080e7          	jalr	1716(ra) # 80006e48 <plic_claim>
    8000379c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000379e:	47a9                	li	a5,10
    800037a0:	02f50763          	beq	a0,a5,800037ce <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800037a4:	4785                	li	a5,1
    800037a6:	02f50963          	beq	a0,a5,800037d8 <devintr+0x76>
    return 1;
    800037aa:	4505                	li	a0,1
    } else if(irq){
    800037ac:	d8f1                	beqz	s1,80003780 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800037ae:	85a6                	mv	a1,s1
    800037b0:	00006517          	auipc	a0,0x6
    800037b4:	d4050513          	addi	a0,a0,-704 # 800094f0 <states.0+0x38>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	dca080e7          	jalr	-566(ra) # 80000582 <printf>
      plic_complete(irq);
    800037c0:	8526                	mv	a0,s1
    800037c2:	00003097          	auipc	ra,0x3
    800037c6:	6aa080e7          	jalr	1706(ra) # 80006e6c <plic_complete>
    return 1;
    800037ca:	4505                	li	a0,1
    800037cc:	bf55                	j	80003780 <devintr+0x1e>
      uartintr();
    800037ce:	ffffd097          	auipc	ra,0xffffd
    800037d2:	1c2080e7          	jalr	450(ra) # 80000990 <uartintr>
    800037d6:	b7ed                	j	800037c0 <devintr+0x5e>
      virtio_disk_intr();
    800037d8:	00004097          	auipc	ra,0x4
    800037dc:	b20080e7          	jalr	-1248(ra) # 800072f8 <virtio_disk_intr>
    800037e0:	b7c5                	j	800037c0 <devintr+0x5e>
    if(cpuid() == 0){
    800037e2:	ffffe097          	auipc	ra,0xffffe
    800037e6:	190080e7          	jalr	400(ra) # 80001972 <cpuid>
    800037ea:	c901                	beqz	a0,800037fa <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800037ec:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800037f0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800037f2:	14479073          	csrw	sip,a5
    return 2;
    800037f6:	4509                	li	a0,2
    800037f8:	b761                	j	80003780 <devintr+0x1e>
      clockintr();
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	f22080e7          	jalr	-222(ra) # 8000371c <clockintr>
    80003802:	b7ed                	j	800037ec <devintr+0x8a>

0000000080003804 <usertrap>:
{
    80003804:	1101                	addi	sp,sp,-32
    80003806:	ec06                	sd	ra,24(sp)
    80003808:	e822                	sd	s0,16(sp)
    8000380a:	e426                	sd	s1,8(sp)
    8000380c:	e04a                	sd	s2,0(sp)
    8000380e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003810:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003814:	1007f793          	andi	a5,a5,256
    80003818:	e3ad                	bnez	a5,8000387a <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000381a:	00003797          	auipc	a5,0x3
    8000381e:	52678793          	addi	a5,a5,1318 # 80006d40 <kernelvec>
    80003822:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003826:	ffffe097          	auipc	ra,0xffffe
    8000382a:	178080e7          	jalr	376(ra) # 8000199e <myproc>
    8000382e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003830:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003832:	14102773          	csrr	a4,sepc
    80003836:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003838:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000383c:	47a1                	li	a5,8
    8000383e:	04f71c63          	bne	a4,a5,80003896 <usertrap+0x92>
    if(p->killed)
    80003842:	551c                	lw	a5,40(a0)
    80003844:	e3b9                	bnez	a5,8000388a <usertrap+0x86>
    p->trapframe->epc += 4;
    80003846:	70b8                	ld	a4,96(s1)
    80003848:	6f1c                	ld	a5,24(a4)
    8000384a:	0791                	addi	a5,a5,4
    8000384c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000384e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003852:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003856:	10079073          	csrw	sstatus,a5
    syscall();
    8000385a:	00000097          	auipc	ra,0x0
    8000385e:	2fc080e7          	jalr	764(ra) # 80003b56 <syscall>
  if(p->killed)
    80003862:	549c                	lw	a5,40(s1)
    80003864:	efd9                	bnez	a5,80003902 <usertrap+0xfe>
  usertrapret();
    80003866:	00000097          	auipc	ra,0x0
    8000386a:	e18080e7          	jalr	-488(ra) # 8000367e <usertrapret>
}
    8000386e:	60e2                	ld	ra,24(sp)
    80003870:	6442                	ld	s0,16(sp)
    80003872:	64a2                	ld	s1,8(sp)
    80003874:	6902                	ld	s2,0(sp)
    80003876:	6105                	addi	sp,sp,32
    80003878:	8082                	ret
    panic("usertrap: not from user mode");
    8000387a:	00006517          	auipc	a0,0x6
    8000387e:	c9650513          	addi	a0,a0,-874 # 80009510 <states.0+0x58>
    80003882:	ffffd097          	auipc	ra,0xffffd
    80003886:	cb6080e7          	jalr	-842(ra) # 80000538 <panic>
      exit(-1);
    8000388a:	557d                	li	a0,-1
    8000388c:	fffff097          	auipc	ra,0xfffff
    80003890:	3e4080e7          	jalr	996(ra) # 80002c70 <exit>
    80003894:	bf4d                	j	80003846 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	ecc080e7          	jalr	-308(ra) # 80003762 <devintr>
    8000389e:	892a                	mv	s2,a0
    800038a0:	c501                	beqz	a0,800038a8 <usertrap+0xa4>
  if(p->killed)
    800038a2:	549c                	lw	a5,40(s1)
    800038a4:	c3a1                	beqz	a5,800038e4 <usertrap+0xe0>
    800038a6:	a815                	j	800038da <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800038a8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800038ac:	5890                	lw	a2,48(s1)
    800038ae:	00006517          	auipc	a0,0x6
    800038b2:	c8250513          	addi	a0,a0,-894 # 80009530 <states.0+0x78>
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	ccc080e7          	jalr	-820(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800038be:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800038c2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800038c6:	00006517          	auipc	a0,0x6
    800038ca:	c9a50513          	addi	a0,a0,-870 # 80009560 <states.0+0xa8>
    800038ce:	ffffd097          	auipc	ra,0xffffd
    800038d2:	cb4080e7          	jalr	-844(ra) # 80000582 <printf>
    p->killed = 1;
    800038d6:	4785                	li	a5,1
    800038d8:	d49c                	sw	a5,40(s1)
    exit(-1);
    800038da:	557d                	li	a0,-1
    800038dc:	fffff097          	auipc	ra,0xfffff
    800038e0:	394080e7          	jalr	916(ra) # 80002c70 <exit>
  if(which_dev == 2) {
    800038e4:	4789                	li	a5,2
    800038e6:	f8f910e3          	bne	s2,a5,80003866 <usertrap+0x62>
    if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    800038ea:	00006717          	auipc	a4,0x6
    800038ee:	77e72703          	lw	a4,1918(a4) # 8000a068 <sched_policy>
    800038f2:	4785                	li	a5,1
    800038f4:	f6e7f9e3          	bgeu	a5,a4,80003866 <usertrap+0x62>
    800038f8:	fffff097          	auipc	ra,0xfffff
    800038fc:	cec080e7          	jalr	-788(ra) # 800025e4 <yield>
    80003900:	b79d                	j	80003866 <usertrap+0x62>
  int which_dev = 0;
    80003902:	4901                	li	s2,0
    80003904:	bfd9                	j	800038da <usertrap+0xd6>

0000000080003906 <kerneltrap>:
{
    80003906:	7179                	addi	sp,sp,-48
    80003908:	f406                	sd	ra,40(sp)
    8000390a:	f022                	sd	s0,32(sp)
    8000390c:	ec26                	sd	s1,24(sp)
    8000390e:	e84a                	sd	s2,16(sp)
    80003910:	e44e                	sd	s3,8(sp)
    80003912:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003914:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003918:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000391c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003920:	1004f793          	andi	a5,s1,256
    80003924:	cb85                	beqz	a5,80003954 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003926:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000392a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000392c:	ef85                	bnez	a5,80003964 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000392e:	00000097          	auipc	ra,0x0
    80003932:	e34080e7          	jalr	-460(ra) # 80003762 <devintr>
    80003936:	cd1d                	beqz	a0,80003974 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003938:	4789                	li	a5,2
    8000393a:	06f50a63          	beq	a0,a5,800039ae <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000393e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003942:	10049073          	csrw	sstatus,s1
}
    80003946:	70a2                	ld	ra,40(sp)
    80003948:	7402                	ld	s0,32(sp)
    8000394a:	64e2                	ld	s1,24(sp)
    8000394c:	6942                	ld	s2,16(sp)
    8000394e:	69a2                	ld	s3,8(sp)
    80003950:	6145                	addi	sp,sp,48
    80003952:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003954:	00006517          	auipc	a0,0x6
    80003958:	c2c50513          	addi	a0,a0,-980 # 80009580 <states.0+0xc8>
    8000395c:	ffffd097          	auipc	ra,0xffffd
    80003960:	bdc080e7          	jalr	-1060(ra) # 80000538 <panic>
    panic("kerneltrap: interrupts enabled");
    80003964:	00006517          	auipc	a0,0x6
    80003968:	c4450513          	addi	a0,a0,-956 # 800095a8 <states.0+0xf0>
    8000396c:	ffffd097          	auipc	ra,0xffffd
    80003970:	bcc080e7          	jalr	-1076(ra) # 80000538 <panic>
    printf("scause %p\n", scause);
    80003974:	85ce                	mv	a1,s3
    80003976:	00006517          	auipc	a0,0x6
    8000397a:	c5250513          	addi	a0,a0,-942 # 800095c8 <states.0+0x110>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	c04080e7          	jalr	-1020(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003986:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000398a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000398e:	00006517          	auipc	a0,0x6
    80003992:	c4a50513          	addi	a0,a0,-950 # 800095d8 <states.0+0x120>
    80003996:	ffffd097          	auipc	ra,0xffffd
    8000399a:	bec080e7          	jalr	-1044(ra) # 80000582 <printf>
    panic("kerneltrap");
    8000399e:	00006517          	auipc	a0,0x6
    800039a2:	c5250513          	addi	a0,a0,-942 # 800095f0 <states.0+0x138>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	b92080e7          	jalr	-1134(ra) # 80000538 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    800039ae:	ffffe097          	auipc	ra,0xffffe
    800039b2:	ff0080e7          	jalr	-16(ra) # 8000199e <myproc>
    800039b6:	d541                	beqz	a0,8000393e <kerneltrap+0x38>
    800039b8:	ffffe097          	auipc	ra,0xffffe
    800039bc:	fe6080e7          	jalr	-26(ra) # 8000199e <myproc>
    800039c0:	4d18                	lw	a4,24(a0)
    800039c2:	4791                	li	a5,4
    800039c4:	f6f71de3          	bne	a4,a5,8000393e <kerneltrap+0x38>
     if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    800039c8:	00006717          	auipc	a4,0x6
    800039cc:	6a072703          	lw	a4,1696(a4) # 8000a068 <sched_policy>
    800039d0:	4785                	li	a5,1
    800039d2:	f6e7f6e3          	bgeu	a5,a4,8000393e <kerneltrap+0x38>
    800039d6:	fffff097          	auipc	ra,0xfffff
    800039da:	c0e080e7          	jalr	-1010(ra) # 800025e4 <yield>
    800039de:	b785                	j	8000393e <kerneltrap+0x38>

00000000800039e0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800039e0:	1101                	addi	sp,sp,-32
    800039e2:	ec06                	sd	ra,24(sp)
    800039e4:	e822                	sd	s0,16(sp)
    800039e6:	e426                	sd	s1,8(sp)
    800039e8:	1000                	addi	s0,sp,32
    800039ea:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800039ec:	ffffe097          	auipc	ra,0xffffe
    800039f0:	fb2080e7          	jalr	-78(ra) # 8000199e <myproc>
  switch (n) {
    800039f4:	4795                	li	a5,5
    800039f6:	0497e163          	bltu	a5,s1,80003a38 <argraw+0x58>
    800039fa:	048a                	slli	s1,s1,0x2
    800039fc:	00006717          	auipc	a4,0x6
    80003a00:	c2c70713          	addi	a4,a4,-980 # 80009628 <states.0+0x170>
    80003a04:	94ba                	add	s1,s1,a4
    80003a06:	409c                	lw	a5,0(s1)
    80003a08:	97ba                	add	a5,a5,a4
    80003a0a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003a0c:	713c                	ld	a5,96(a0)
    80003a0e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003a10:	60e2                	ld	ra,24(sp)
    80003a12:	6442                	ld	s0,16(sp)
    80003a14:	64a2                	ld	s1,8(sp)
    80003a16:	6105                	addi	sp,sp,32
    80003a18:	8082                	ret
    return p->trapframe->a1;
    80003a1a:	713c                	ld	a5,96(a0)
    80003a1c:	7fa8                	ld	a0,120(a5)
    80003a1e:	bfcd                	j	80003a10 <argraw+0x30>
    return p->trapframe->a2;
    80003a20:	713c                	ld	a5,96(a0)
    80003a22:	63c8                	ld	a0,128(a5)
    80003a24:	b7f5                	j	80003a10 <argraw+0x30>
    return p->trapframe->a3;
    80003a26:	713c                	ld	a5,96(a0)
    80003a28:	67c8                	ld	a0,136(a5)
    80003a2a:	b7dd                	j	80003a10 <argraw+0x30>
    return p->trapframe->a4;
    80003a2c:	713c                	ld	a5,96(a0)
    80003a2e:	6bc8                	ld	a0,144(a5)
    80003a30:	b7c5                	j	80003a10 <argraw+0x30>
    return p->trapframe->a5;
    80003a32:	713c                	ld	a5,96(a0)
    80003a34:	6fc8                	ld	a0,152(a5)
    80003a36:	bfe9                	j	80003a10 <argraw+0x30>
  panic("argraw");
    80003a38:	00006517          	auipc	a0,0x6
    80003a3c:	bc850513          	addi	a0,a0,-1080 # 80009600 <states.0+0x148>
    80003a40:	ffffd097          	auipc	ra,0xffffd
    80003a44:	af8080e7          	jalr	-1288(ra) # 80000538 <panic>

0000000080003a48 <fetchaddr>:
{
    80003a48:	1101                	addi	sp,sp,-32
    80003a4a:	ec06                	sd	ra,24(sp)
    80003a4c:	e822                	sd	s0,16(sp)
    80003a4e:	e426                	sd	s1,8(sp)
    80003a50:	e04a                	sd	s2,0(sp)
    80003a52:	1000                	addi	s0,sp,32
    80003a54:	84aa                	mv	s1,a0
    80003a56:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003a58:	ffffe097          	auipc	ra,0xffffe
    80003a5c:	f46080e7          	jalr	-186(ra) # 8000199e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003a60:	693c                	ld	a5,80(a0)
    80003a62:	02f4f863          	bgeu	s1,a5,80003a92 <fetchaddr+0x4a>
    80003a66:	00848713          	addi	a4,s1,8
    80003a6a:	02e7e663          	bltu	a5,a4,80003a96 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003a6e:	46a1                	li	a3,8
    80003a70:	8626                	mv	a2,s1
    80003a72:	85ca                	mv	a1,s2
    80003a74:	6d28                	ld	a0,88(a0)
    80003a76:	ffffe097          	auipc	ra,0xffffe
    80003a7a:	c78080e7          	jalr	-904(ra) # 800016ee <copyin>
    80003a7e:	00a03533          	snez	a0,a0
    80003a82:	40a00533          	neg	a0,a0
}
    80003a86:	60e2                	ld	ra,24(sp)
    80003a88:	6442                	ld	s0,16(sp)
    80003a8a:	64a2                	ld	s1,8(sp)
    80003a8c:	6902                	ld	s2,0(sp)
    80003a8e:	6105                	addi	sp,sp,32
    80003a90:	8082                	ret
    return -1;
    80003a92:	557d                	li	a0,-1
    80003a94:	bfcd                	j	80003a86 <fetchaddr+0x3e>
    80003a96:	557d                	li	a0,-1
    80003a98:	b7fd                	j	80003a86 <fetchaddr+0x3e>

0000000080003a9a <fetchstr>:
{
    80003a9a:	7179                	addi	sp,sp,-48
    80003a9c:	f406                	sd	ra,40(sp)
    80003a9e:	f022                	sd	s0,32(sp)
    80003aa0:	ec26                	sd	s1,24(sp)
    80003aa2:	e84a                	sd	s2,16(sp)
    80003aa4:	e44e                	sd	s3,8(sp)
    80003aa6:	1800                	addi	s0,sp,48
    80003aa8:	892a                	mv	s2,a0
    80003aaa:	84ae                	mv	s1,a1
    80003aac:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003aae:	ffffe097          	auipc	ra,0xffffe
    80003ab2:	ef0080e7          	jalr	-272(ra) # 8000199e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003ab6:	86ce                	mv	a3,s3
    80003ab8:	864a                	mv	a2,s2
    80003aba:	85a6                	mv	a1,s1
    80003abc:	6d28                	ld	a0,88(a0)
    80003abe:	ffffe097          	auipc	ra,0xffffe
    80003ac2:	cbe080e7          	jalr	-834(ra) # 8000177c <copyinstr>
  if(err < 0)
    80003ac6:	00054763          	bltz	a0,80003ad4 <fetchstr+0x3a>
  return strlen(buf);
    80003aca:	8526                	mv	a0,s1
    80003acc:	ffffd097          	auipc	ra,0xffffd
    80003ad0:	37a080e7          	jalr	890(ra) # 80000e46 <strlen>
}
    80003ad4:	70a2                	ld	ra,40(sp)
    80003ad6:	7402                	ld	s0,32(sp)
    80003ad8:	64e2                	ld	s1,24(sp)
    80003ada:	6942                	ld	s2,16(sp)
    80003adc:	69a2                	ld	s3,8(sp)
    80003ade:	6145                	addi	sp,sp,48
    80003ae0:	8082                	ret

0000000080003ae2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003ae2:	1101                	addi	sp,sp,-32
    80003ae4:	ec06                	sd	ra,24(sp)
    80003ae6:	e822                	sd	s0,16(sp)
    80003ae8:	e426                	sd	s1,8(sp)
    80003aea:	1000                	addi	s0,sp,32
    80003aec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003aee:	00000097          	auipc	ra,0x0
    80003af2:	ef2080e7          	jalr	-270(ra) # 800039e0 <argraw>
    80003af6:	c088                	sw	a0,0(s1)
  return 0;
}
    80003af8:	4501                	li	a0,0
    80003afa:	60e2                	ld	ra,24(sp)
    80003afc:	6442                	ld	s0,16(sp)
    80003afe:	64a2                	ld	s1,8(sp)
    80003b00:	6105                	addi	sp,sp,32
    80003b02:	8082                	ret

0000000080003b04 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003b04:	1101                	addi	sp,sp,-32
    80003b06:	ec06                	sd	ra,24(sp)
    80003b08:	e822                	sd	s0,16(sp)
    80003b0a:	e426                	sd	s1,8(sp)
    80003b0c:	1000                	addi	s0,sp,32
    80003b0e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003b10:	00000097          	auipc	ra,0x0
    80003b14:	ed0080e7          	jalr	-304(ra) # 800039e0 <argraw>
    80003b18:	e088                	sd	a0,0(s1)
  return 0;
}
    80003b1a:	4501                	li	a0,0
    80003b1c:	60e2                	ld	ra,24(sp)
    80003b1e:	6442                	ld	s0,16(sp)
    80003b20:	64a2                	ld	s1,8(sp)
    80003b22:	6105                	addi	sp,sp,32
    80003b24:	8082                	ret

0000000080003b26 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003b26:	1101                	addi	sp,sp,-32
    80003b28:	ec06                	sd	ra,24(sp)
    80003b2a:	e822                	sd	s0,16(sp)
    80003b2c:	e426                	sd	s1,8(sp)
    80003b2e:	e04a                	sd	s2,0(sp)
    80003b30:	1000                	addi	s0,sp,32
    80003b32:	84ae                	mv	s1,a1
    80003b34:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003b36:	00000097          	auipc	ra,0x0
    80003b3a:	eaa080e7          	jalr	-342(ra) # 800039e0 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003b3e:	864a                	mv	a2,s2
    80003b40:	85a6                	mv	a1,s1
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	f58080e7          	jalr	-168(ra) # 80003a9a <fetchstr>
}
    80003b4a:	60e2                	ld	ra,24(sp)
    80003b4c:	6442                	ld	s0,16(sp)
    80003b4e:	64a2                	ld	s1,8(sp)
    80003b50:	6902                	ld	s2,0(sp)
    80003b52:	6105                	addi	sp,sp,32
    80003b54:	8082                	ret

0000000080003b56 <syscall>:
[SYS_schedpolicy] sys_schedpolicy,
};

void
syscall(void)
{
    80003b56:	1101                	addi	sp,sp,-32
    80003b58:	ec06                	sd	ra,24(sp)
    80003b5a:	e822                	sd	s0,16(sp)
    80003b5c:	e426                	sd	s1,8(sp)
    80003b5e:	e04a                	sd	s2,0(sp)
    80003b60:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003b62:	ffffe097          	auipc	ra,0xffffe
    80003b66:	e3c080e7          	jalr	-452(ra) # 8000199e <myproc>
    80003b6a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003b6c:	06053903          	ld	s2,96(a0)
    80003b70:	0a893783          	ld	a5,168(s2)
    80003b74:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003b78:	37fd                	addiw	a5,a5,-1
    80003b7a:	4775                	li	a4,29
    80003b7c:	00f76f63          	bltu	a4,a5,80003b9a <syscall+0x44>
    80003b80:	00369713          	slli	a4,a3,0x3
    80003b84:	00006797          	auipc	a5,0x6
    80003b88:	abc78793          	addi	a5,a5,-1348 # 80009640 <syscalls>
    80003b8c:	97ba                	add	a5,a5,a4
    80003b8e:	639c                	ld	a5,0(a5)
    80003b90:	c789                	beqz	a5,80003b9a <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003b92:	9782                	jalr	a5
    80003b94:	06a93823          	sd	a0,112(s2)
    80003b98:	a839                	j	80003bb6 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003b9a:	16048613          	addi	a2,s1,352
    80003b9e:	588c                	lw	a1,48(s1)
    80003ba0:	00006517          	auipc	a0,0x6
    80003ba4:	a6850513          	addi	a0,a0,-1432 # 80009608 <states.0+0x150>
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	9da080e7          	jalr	-1574(ra) # 80000582 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003bb0:	70bc                	ld	a5,96(s1)
    80003bb2:	577d                	li	a4,-1
    80003bb4:	fbb8                	sd	a4,112(a5)
  }
}
    80003bb6:	60e2                	ld	ra,24(sp)
    80003bb8:	6442                	ld	s0,16(sp)
    80003bba:	64a2                	ld	s1,8(sp)
    80003bbc:	6902                	ld	s2,0(sp)
    80003bbe:	6105                	addi	sp,sp,32
    80003bc0:	8082                	ret

0000000080003bc2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003bc2:	1101                	addi	sp,sp,-32
    80003bc4:	ec06                	sd	ra,24(sp)
    80003bc6:	e822                	sd	s0,16(sp)
    80003bc8:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003bca:	fec40593          	addi	a1,s0,-20
    80003bce:	4501                	li	a0,0
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	f12080e7          	jalr	-238(ra) # 80003ae2 <argint>
    return -1;
    80003bd8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003bda:	00054963          	bltz	a0,80003bec <sys_exit+0x2a>
  exit(n);
    80003bde:	fec42503          	lw	a0,-20(s0)
    80003be2:	fffff097          	auipc	ra,0xfffff
    80003be6:	08e080e7          	jalr	142(ra) # 80002c70 <exit>
  return 0;  // not reached
    80003bea:	4781                	li	a5,0
}
    80003bec:	853e                	mv	a0,a5
    80003bee:	60e2                	ld	ra,24(sp)
    80003bf0:	6442                	ld	s0,16(sp)
    80003bf2:	6105                	addi	sp,sp,32
    80003bf4:	8082                	ret

0000000080003bf6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003bf6:	1141                	addi	sp,sp,-16
    80003bf8:	e406                	sd	ra,8(sp)
    80003bfa:	e022                	sd	s0,0(sp)
    80003bfc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003bfe:	ffffe097          	auipc	ra,0xffffe
    80003c02:	da0080e7          	jalr	-608(ra) # 8000199e <myproc>
}
    80003c06:	5908                	lw	a0,48(a0)
    80003c08:	60a2                	ld	ra,8(sp)
    80003c0a:	6402                	ld	s0,0(sp)
    80003c0c:	0141                	addi	sp,sp,16
    80003c0e:	8082                	ret

0000000080003c10 <sys_fork>:

uint64
sys_fork(void)
{
    80003c10:	1141                	addi	sp,sp,-16
    80003c12:	e406                	sd	ra,8(sp)
    80003c14:	e022                	sd	s0,0(sp)
    80003c16:	0800                	addi	s0,sp,16
  return fork();
    80003c18:	ffffe097          	auipc	ra,0xffffe
    80003c1c:	1ce080e7          	jalr	462(ra) # 80001de6 <fork>
}
    80003c20:	60a2                	ld	ra,8(sp)
    80003c22:	6402                	ld	s0,0(sp)
    80003c24:	0141                	addi	sp,sp,16
    80003c26:	8082                	ret

0000000080003c28 <sys_wait>:

uint64
sys_wait(void)
{
    80003c28:	1101                	addi	sp,sp,-32
    80003c2a:	ec06                	sd	ra,24(sp)
    80003c2c:	e822                	sd	s0,16(sp)
    80003c2e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003c30:	fe840593          	addi	a1,s0,-24
    80003c34:	4501                	li	a0,0
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	ece080e7          	jalr	-306(ra) # 80003b04 <argaddr>
    80003c3e:	87aa                	mv	a5,a0
    return -1;
    80003c40:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003c42:	0007c863          	bltz	a5,80003c52 <sys_wait+0x2a>
  return wait(p);
    80003c46:	fe843503          	ld	a0,-24(s0)
    80003c4a:	fffff097          	auipc	ra,0xfffff
    80003c4e:	cb4080e7          	jalr	-844(ra) # 800028fe <wait>
}
    80003c52:	60e2                	ld	ra,24(sp)
    80003c54:	6442                	ld	s0,16(sp)
    80003c56:	6105                	addi	sp,sp,32
    80003c58:	8082                	ret

0000000080003c5a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003c5a:	7179                	addi	sp,sp,-48
    80003c5c:	f406                	sd	ra,40(sp)
    80003c5e:	f022                	sd	s0,32(sp)
    80003c60:	ec26                	sd	s1,24(sp)
    80003c62:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003c64:	fdc40593          	addi	a1,s0,-36
    80003c68:	4501                	li	a0,0
    80003c6a:	00000097          	auipc	ra,0x0
    80003c6e:	e78080e7          	jalr	-392(ra) # 80003ae2 <argint>
    80003c72:	87aa                	mv	a5,a0
    return -1;
    80003c74:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003c76:	0207c063          	bltz	a5,80003c96 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003c7a:	ffffe097          	auipc	ra,0xffffe
    80003c7e:	d24080e7          	jalr	-732(ra) # 8000199e <myproc>
    80003c82:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80003c84:	fdc42503          	lw	a0,-36(s0)
    80003c88:	ffffe097          	auipc	ra,0xffffe
    80003c8c:	0e6080e7          	jalr	230(ra) # 80001d6e <growproc>
    80003c90:	00054863          	bltz	a0,80003ca0 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003c94:	8526                	mv	a0,s1
}
    80003c96:	70a2                	ld	ra,40(sp)
    80003c98:	7402                	ld	s0,32(sp)
    80003c9a:	64e2                	ld	s1,24(sp)
    80003c9c:	6145                	addi	sp,sp,48
    80003c9e:	8082                	ret
    return -1;
    80003ca0:	557d                	li	a0,-1
    80003ca2:	bfd5                	j	80003c96 <sys_sbrk+0x3c>

0000000080003ca4 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003ca4:	7139                	addi	sp,sp,-64
    80003ca6:	fc06                	sd	ra,56(sp)
    80003ca8:	f822                	sd	s0,48(sp)
    80003caa:	f426                	sd	s1,40(sp)
    80003cac:	f04a                	sd	s2,32(sp)
    80003cae:	ec4e                	sd	s3,24(sp)
    80003cb0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003cb2:	fcc40593          	addi	a1,s0,-52
    80003cb6:	4501                	li	a0,0
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	e2a080e7          	jalr	-470(ra) # 80003ae2 <argint>
    return -1;
    80003cc0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003cc2:	06054563          	bltz	a0,80003d2c <sys_sleep+0x88>
  acquire(&tickslock);
    80003cc6:	00015517          	auipc	a0,0x15
    80003cca:	e3a50513          	addi	a0,a0,-454 # 80018b00 <tickslock>
    80003cce:	ffffd097          	auipc	ra,0xffffd
    80003cd2:	f00080e7          	jalr	-256(ra) # 80000bce <acquire>
  ticks0 = ticks;
    80003cd6:	00006917          	auipc	s2,0x6
    80003cda:	39692903          	lw	s2,918(s2) # 8000a06c <ticks>
  while(ticks - ticks0 < n){
    80003cde:	fcc42783          	lw	a5,-52(s0)
    80003ce2:	cf85                	beqz	a5,80003d1a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003ce4:	00015997          	auipc	s3,0x15
    80003ce8:	e1c98993          	addi	s3,s3,-484 # 80018b00 <tickslock>
    80003cec:	00006497          	auipc	s1,0x6
    80003cf0:	38048493          	addi	s1,s1,896 # 8000a06c <ticks>
    if(myproc()->killed){
    80003cf4:	ffffe097          	auipc	ra,0xffffe
    80003cf8:	caa080e7          	jalr	-854(ra) # 8000199e <myproc>
    80003cfc:	551c                	lw	a5,40(a0)
    80003cfe:	ef9d                	bnez	a5,80003d3c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003d00:	85ce                	mv	a1,s3
    80003d02:	8526                	mv	a0,s1
    80003d04:	fffff097          	auipc	ra,0xfffff
    80003d08:	a4c080e7          	jalr	-1460(ra) # 80002750 <sleep>
  while(ticks - ticks0 < n){
    80003d0c:	409c                	lw	a5,0(s1)
    80003d0e:	412787bb          	subw	a5,a5,s2
    80003d12:	fcc42703          	lw	a4,-52(s0)
    80003d16:	fce7efe3          	bltu	a5,a4,80003cf4 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003d1a:	00015517          	auipc	a0,0x15
    80003d1e:	de650513          	addi	a0,a0,-538 # 80018b00 <tickslock>
    80003d22:	ffffd097          	auipc	ra,0xffffd
    80003d26:	f60080e7          	jalr	-160(ra) # 80000c82 <release>
  return 0;
    80003d2a:	4781                	li	a5,0
}
    80003d2c:	853e                	mv	a0,a5
    80003d2e:	70e2                	ld	ra,56(sp)
    80003d30:	7442                	ld	s0,48(sp)
    80003d32:	74a2                	ld	s1,40(sp)
    80003d34:	7902                	ld	s2,32(sp)
    80003d36:	69e2                	ld	s3,24(sp)
    80003d38:	6121                	addi	sp,sp,64
    80003d3a:	8082                	ret
      release(&tickslock);
    80003d3c:	00015517          	auipc	a0,0x15
    80003d40:	dc450513          	addi	a0,a0,-572 # 80018b00 <tickslock>
    80003d44:	ffffd097          	auipc	ra,0xffffd
    80003d48:	f3e080e7          	jalr	-194(ra) # 80000c82 <release>
      return -1;
    80003d4c:	57fd                	li	a5,-1
    80003d4e:	bff9                	j	80003d2c <sys_sleep+0x88>

0000000080003d50 <sys_kill>:

uint64
sys_kill(void)
{
    80003d50:	1101                	addi	sp,sp,-32
    80003d52:	ec06                	sd	ra,24(sp)
    80003d54:	e822                	sd	s0,16(sp)
    80003d56:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003d58:	fec40593          	addi	a1,s0,-20
    80003d5c:	4501                	li	a0,0
    80003d5e:	00000097          	auipc	ra,0x0
    80003d62:	d84080e7          	jalr	-636(ra) # 80003ae2 <argint>
    80003d66:	87aa                	mv	a5,a0
    return -1;
    80003d68:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003d6a:	0007c863          	bltz	a5,80003d7a <sys_kill+0x2a>
  return kill(pid);
    80003d6e:	fec42503          	lw	a0,-20(s0)
    80003d72:	fffff097          	auipc	ra,0xfffff
    80003d76:	338080e7          	jalr	824(ra) # 800030aa <kill>
}
    80003d7a:	60e2                	ld	ra,24(sp)
    80003d7c:	6442                	ld	s0,16(sp)
    80003d7e:	6105                	addi	sp,sp,32
    80003d80:	8082                	ret

0000000080003d82 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003d82:	1101                	addi	sp,sp,-32
    80003d84:	ec06                	sd	ra,24(sp)
    80003d86:	e822                	sd	s0,16(sp)
    80003d88:	e426                	sd	s1,8(sp)
    80003d8a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003d8c:	00015517          	auipc	a0,0x15
    80003d90:	d7450513          	addi	a0,a0,-652 # 80018b00 <tickslock>
    80003d94:	ffffd097          	auipc	ra,0xffffd
    80003d98:	e3a080e7          	jalr	-454(ra) # 80000bce <acquire>
  xticks = ticks;
    80003d9c:	00006497          	auipc	s1,0x6
    80003da0:	2d04a483          	lw	s1,720(s1) # 8000a06c <ticks>
  release(&tickslock);
    80003da4:	00015517          	auipc	a0,0x15
    80003da8:	d5c50513          	addi	a0,a0,-676 # 80018b00 <tickslock>
    80003dac:	ffffd097          	auipc	ra,0xffffd
    80003db0:	ed6080e7          	jalr	-298(ra) # 80000c82 <release>
  return xticks;
}
    80003db4:	02049513          	slli	a0,s1,0x20
    80003db8:	9101                	srli	a0,a0,0x20
    80003dba:	60e2                	ld	ra,24(sp)
    80003dbc:	6442                	ld	s0,16(sp)
    80003dbe:	64a2                	ld	s1,8(sp)
    80003dc0:	6105                	addi	sp,sp,32
    80003dc2:	8082                	ret

0000000080003dc4 <sys_getppid>:

uint64
sys_getppid(void)
{
    80003dc4:	1141                	addi	sp,sp,-16
    80003dc6:	e406                	sd	ra,8(sp)
    80003dc8:	e022                	sd	s0,0(sp)
    80003dca:	0800                	addi	s0,sp,16
  if (myproc()->parent) return myproc()->parent->pid;
    80003dcc:	ffffe097          	auipc	ra,0xffffe
    80003dd0:	bd2080e7          	jalr	-1070(ra) # 8000199e <myproc>
    80003dd4:	613c                	ld	a5,64(a0)
    80003dd6:	cb99                	beqz	a5,80003dec <sys_getppid+0x28>
    80003dd8:	ffffe097          	auipc	ra,0xffffe
    80003ddc:	bc6080e7          	jalr	-1082(ra) # 8000199e <myproc>
    80003de0:	613c                	ld	a5,64(a0)
    80003de2:	5b88                	lw	a0,48(a5)
  else {
     printf("No parent found.\n");
     return 0;
  }
}
    80003de4:	60a2                	ld	ra,8(sp)
    80003de6:	6402                	ld	s0,0(sp)
    80003de8:	0141                	addi	sp,sp,16
    80003dea:	8082                	ret
     printf("No parent found.\n");
    80003dec:	00006517          	auipc	a0,0x6
    80003df0:	94c50513          	addi	a0,a0,-1716 # 80009738 <syscalls+0xf8>
    80003df4:	ffffc097          	auipc	ra,0xffffc
    80003df8:	78e080e7          	jalr	1934(ra) # 80000582 <printf>
     return 0;
    80003dfc:	4501                	li	a0,0
    80003dfe:	b7dd                	j	80003de4 <sys_getppid+0x20>

0000000080003e00 <sys_yield>:

uint64
sys_yield(void)
{
    80003e00:	1141                	addi	sp,sp,-16
    80003e02:	e406                	sd	ra,8(sp)
    80003e04:	e022                	sd	s0,0(sp)
    80003e06:	0800                	addi	s0,sp,16
  yield();
    80003e08:	ffffe097          	auipc	ra,0xffffe
    80003e0c:	7dc080e7          	jalr	2012(ra) # 800025e4 <yield>
  return 0;
}
    80003e10:	4501                	li	a0,0
    80003e12:	60a2                	ld	ra,8(sp)
    80003e14:	6402                	ld	s0,0(sp)
    80003e16:	0141                	addi	sp,sp,16
    80003e18:	8082                	ret

0000000080003e1a <sys_getpa>:

uint64
sys_getpa(void)
{
    80003e1a:	1101                	addi	sp,sp,-32
    80003e1c:	ec06                	sd	ra,24(sp)
    80003e1e:	e822                	sd	s0,16(sp)
    80003e20:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    80003e22:	fe840593          	addi	a1,s0,-24
    80003e26:	4501                	li	a0,0
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	cdc080e7          	jalr	-804(ra) # 80003b04 <argaddr>
    80003e30:	87aa                	mv	a5,a0
    80003e32:	557d                	li	a0,-1
    80003e34:	0207c263          	bltz	a5,80003e58 <sys_getpa+0x3e>
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
    80003e38:	ffffe097          	auipc	ra,0xffffe
    80003e3c:	b66080e7          	jalr	-1178(ra) # 8000199e <myproc>
    80003e40:	fe843583          	ld	a1,-24(s0)
    80003e44:	6d28                	ld	a0,88(a0)
    80003e46:	ffffd097          	auipc	ra,0xffffd
    80003e4a:	214080e7          	jalr	532(ra) # 8000105a <walkaddr>
    80003e4e:	fe843783          	ld	a5,-24(s0)
    80003e52:	17d2                	slli	a5,a5,0x34
    80003e54:	93d1                	srli	a5,a5,0x34
    80003e56:	953e                	add	a0,a0,a5
}
    80003e58:	60e2                	ld	ra,24(sp)
    80003e5a:	6442                	ld	s0,16(sp)
    80003e5c:	6105                	addi	sp,sp,32
    80003e5e:	8082                	ret

0000000080003e60 <sys_forkf>:

uint64
sys_forkf(void)
{
    80003e60:	1101                	addi	sp,sp,-32
    80003e62:	ec06                	sd	ra,24(sp)
    80003e64:	e822                	sd	s0,16(sp)
    80003e66:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    80003e68:	fe840593          	addi	a1,s0,-24
    80003e6c:	4501                	li	a0,0
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	c96080e7          	jalr	-874(ra) # 80003b04 <argaddr>
    80003e76:	87aa                	mv	a5,a0
    80003e78:	557d                	li	a0,-1
    80003e7a:	0007c863          	bltz	a5,80003e8a <sys_forkf+0x2a>
  return forkf(x);
    80003e7e:	fe843503          	ld	a0,-24(s0)
    80003e82:	ffffe097          	auipc	ra,0xffffe
    80003e86:	0a4080e7          	jalr	164(ra) # 80001f26 <forkf>
}
    80003e8a:	60e2                	ld	ra,24(sp)
    80003e8c:	6442                	ld	s0,16(sp)
    80003e8e:	6105                	addi	sp,sp,32
    80003e90:	8082                	ret

0000000080003e92 <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80003e92:	1101                	addi	sp,sp,-32
    80003e94:	ec06                	sd	ra,24(sp)
    80003e96:	e822                	sd	s0,16(sp)
    80003e98:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    80003e9a:	fe440593          	addi	a1,s0,-28
    80003e9e:	4501                	li	a0,0
    80003ea0:	00000097          	auipc	ra,0x0
    80003ea4:	c42080e7          	jalr	-958(ra) # 80003ae2 <argint>
    return -1;
    80003ea8:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    80003eaa:	02054c63          	bltz	a0,80003ee2 <sys_waitpid+0x50>
  if(argaddr(1, &p) < 0)
    80003eae:	fe840593          	addi	a1,s0,-24
    80003eb2:	4505                	li	a0,1
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	c50080e7          	jalr	-944(ra) # 80003b04 <argaddr>
    80003ebc:	04054063          	bltz	a0,80003efc <sys_waitpid+0x6a>
    return -1;

  if (x == -1) return wait(p);
    80003ec0:	fe442503          	lw	a0,-28(s0)
    80003ec4:	57fd                	li	a5,-1
    80003ec6:	02f50363          	beq	a0,a5,80003eec <sys_waitpid+0x5a>
  if ((x == 0) || (x < -1)) return -1;
    80003eca:	57fd                	li	a5,-1
    80003ecc:	c919                	beqz	a0,80003ee2 <sys_waitpid+0x50>
    80003ece:	577d                	li	a4,-1
    80003ed0:	00e54963          	blt	a0,a4,80003ee2 <sys_waitpid+0x50>
  return waitpid(x, p);
    80003ed4:	fe843583          	ld	a1,-24(s0)
    80003ed8:	fffff097          	auipc	ra,0xfffff
    80003edc:	b4e080e7          	jalr	-1202(ra) # 80002a26 <waitpid>
    80003ee0:	87aa                	mv	a5,a0
}
    80003ee2:	853e                	mv	a0,a5
    80003ee4:	60e2                	ld	ra,24(sp)
    80003ee6:	6442                	ld	s0,16(sp)
    80003ee8:	6105                	addi	sp,sp,32
    80003eea:	8082                	ret
  if (x == -1) return wait(p);
    80003eec:	fe843503          	ld	a0,-24(s0)
    80003ef0:	fffff097          	auipc	ra,0xfffff
    80003ef4:	a0e080e7          	jalr	-1522(ra) # 800028fe <wait>
    80003ef8:	87aa                	mv	a5,a0
    80003efa:	b7e5                	j	80003ee2 <sys_waitpid+0x50>
    return -1;
    80003efc:	57fd                	li	a5,-1
    80003efe:	b7d5                	j	80003ee2 <sys_waitpid+0x50>

0000000080003f00 <sys_ps>:

uint64
sys_ps(void)
{
    80003f00:	1141                	addi	sp,sp,-16
    80003f02:	e406                	sd	ra,8(sp)
    80003f04:	e022                	sd	s0,0(sp)
    80003f06:	0800                	addi	s0,sp,16
   return ps();
    80003f08:	fffff097          	auipc	ra,0xfffff
    80003f0c:	3a0080e7          	jalr	928(ra) # 800032a8 <ps>
}
    80003f10:	60a2                	ld	ra,8(sp)
    80003f12:	6402                	ld	s0,0(sp)
    80003f14:	0141                	addi	sp,sp,16
    80003f16:	8082                	ret

0000000080003f18 <sys_pinfo>:

uint64
sys_pinfo(void)
{
    80003f18:	1101                	addi	sp,sp,-32
    80003f1a:	ec06                	sd	ra,24(sp)
    80003f1c:	e822                	sd	s0,16(sp)
    80003f1e:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    80003f20:	fe440593          	addi	a1,s0,-28
    80003f24:	4501                	li	a0,0
    80003f26:	00000097          	auipc	ra,0x0
    80003f2a:	bbc080e7          	jalr	-1092(ra) # 80003ae2 <argint>
    return -1;
    80003f2e:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    80003f30:	02054963          	bltz	a0,80003f62 <sys_pinfo+0x4a>
  if(argaddr(1, &p) < 0)
    80003f34:	fe840593          	addi	a1,s0,-24
    80003f38:	4505                	li	a0,1
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	bca080e7          	jalr	-1078(ra) # 80003b04 <argaddr>
    80003f42:	02054563          	bltz	a0,80003f6c <sys_pinfo+0x54>
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    80003f46:	fe442503          	lw	a0,-28(s0)
    80003f4a:	57fd                	li	a5,-1
    80003f4c:	c919                	beqz	a0,80003f62 <sys_pinfo+0x4a>
    80003f4e:	02f54163          	blt	a0,a5,80003f70 <sys_pinfo+0x58>
    80003f52:	fe843583          	ld	a1,-24(s0)
    80003f56:	c591                	beqz	a1,80003f62 <sys_pinfo+0x4a>
  return pinfo(x, p);
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	4be080e7          	jalr	1214(ra) # 80003416 <pinfo>
    80003f60:	87aa                	mv	a5,a0
}
    80003f62:	853e                	mv	a0,a5
    80003f64:	60e2                	ld	ra,24(sp)
    80003f66:	6442                	ld	s0,16(sp)
    80003f68:	6105                	addi	sp,sp,32
    80003f6a:	8082                	ret
    return -1;
    80003f6c:	57fd                	li	a5,-1
    80003f6e:	bfd5                	j	80003f62 <sys_pinfo+0x4a>
  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    80003f70:	57fd                	li	a5,-1
    80003f72:	bfc5                	j	80003f62 <sys_pinfo+0x4a>

0000000080003f74 <sys_forkp>:

uint64
sys_forkp(void)
{
    80003f74:	1101                	addi	sp,sp,-32
    80003f76:	ec06                	sd	ra,24(sp)
    80003f78:	e822                	sd	s0,16(sp)
    80003f7a:	1000                	addi	s0,sp,32
  int x;
  if(argint(0, &x) < 0) return -1;
    80003f7c:	fec40593          	addi	a1,s0,-20
    80003f80:	4501                	li	a0,0
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	b60080e7          	jalr	-1184(ra) # 80003ae2 <argint>
    80003f8a:	87aa                	mv	a5,a0
    80003f8c:	557d                	li	a0,-1
    80003f8e:	0007c863          	bltz	a5,80003f9e <sys_forkp+0x2a>
  return forkp(x);
    80003f92:	fec42503          	lw	a0,-20(s0)
    80003f96:	ffffe097          	auipc	ra,0xffffe
    80003f9a:	0dc080e7          	jalr	220(ra) # 80002072 <forkp>
}
    80003f9e:	60e2                	ld	ra,24(sp)
    80003fa0:	6442                	ld	s0,16(sp)
    80003fa2:	6105                	addi	sp,sp,32
    80003fa4:	8082                	ret

0000000080003fa6 <sys_schedpolicy>:

uint64
sys_schedpolicy(void)
{
    80003fa6:	1101                	addi	sp,sp,-32
    80003fa8:	ec06                	sd	ra,24(sp)
    80003faa:	e822                	sd	s0,16(sp)
    80003fac:	1000                	addi	s0,sp,32
  int x;
  if(argint(0, &x) < 0) return -1;
    80003fae:	fec40593          	addi	a1,s0,-20
    80003fb2:	4501                	li	a0,0
    80003fb4:	00000097          	auipc	ra,0x0
    80003fb8:	b2e080e7          	jalr	-1234(ra) # 80003ae2 <argint>
    80003fbc:	87aa                	mv	a5,a0
    80003fbe:	557d                	li	a0,-1
    80003fc0:	0007c863          	bltz	a5,80003fd0 <sys_schedpolicy+0x2a>
  return schedpolicy(x);
    80003fc4:	fec42503          	lw	a0,-20(s0)
    80003fc8:	fffff097          	auipc	ra,0xfffff
    80003fcc:	5f2080e7          	jalr	1522(ra) # 800035ba <schedpolicy>
}
    80003fd0:	60e2                	ld	ra,24(sp)
    80003fd2:	6442                	ld	s0,16(sp)
    80003fd4:	6105                	addi	sp,sp,32
    80003fd6:	8082                	ret

0000000080003fd8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003fd8:	7179                	addi	sp,sp,-48
    80003fda:	f406                	sd	ra,40(sp)
    80003fdc:	f022                	sd	s0,32(sp)
    80003fde:	ec26                	sd	s1,24(sp)
    80003fe0:	e84a                	sd	s2,16(sp)
    80003fe2:	e44e                	sd	s3,8(sp)
    80003fe4:	e052                	sd	s4,0(sp)
    80003fe6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003fe8:	00005597          	auipc	a1,0x5
    80003fec:	76858593          	addi	a1,a1,1896 # 80009750 <syscalls+0x110>
    80003ff0:	00015517          	auipc	a0,0x15
    80003ff4:	b2850513          	addi	a0,a0,-1240 # 80018b18 <bcache>
    80003ff8:	ffffd097          	auipc	ra,0xffffd
    80003ffc:	b46080e7          	jalr	-1210(ra) # 80000b3e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80004000:	0001d797          	auipc	a5,0x1d
    80004004:	b1878793          	addi	a5,a5,-1256 # 80020b18 <bcache+0x8000>
    80004008:	0001d717          	auipc	a4,0x1d
    8000400c:	d7870713          	addi	a4,a4,-648 # 80020d80 <bcache+0x8268>
    80004010:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80004014:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004018:	00015497          	auipc	s1,0x15
    8000401c:	b1848493          	addi	s1,s1,-1256 # 80018b30 <bcache+0x18>
    b->next = bcache.head.next;
    80004020:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80004022:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80004024:	00005a17          	auipc	s4,0x5
    80004028:	734a0a13          	addi	s4,s4,1844 # 80009758 <syscalls+0x118>
    b->next = bcache.head.next;
    8000402c:	2b893783          	ld	a5,696(s2)
    80004030:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80004032:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80004036:	85d2                	mv	a1,s4
    80004038:	01048513          	addi	a0,s1,16
    8000403c:	00001097          	auipc	ra,0x1
    80004040:	4c2080e7          	jalr	1218(ra) # 800054fe <initsleeplock>
    bcache.head.next->prev = b;
    80004044:	2b893783          	ld	a5,696(s2)
    80004048:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000404a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000404e:	45848493          	addi	s1,s1,1112
    80004052:	fd349de3          	bne	s1,s3,8000402c <binit+0x54>
  }
}
    80004056:	70a2                	ld	ra,40(sp)
    80004058:	7402                	ld	s0,32(sp)
    8000405a:	64e2                	ld	s1,24(sp)
    8000405c:	6942                	ld	s2,16(sp)
    8000405e:	69a2                	ld	s3,8(sp)
    80004060:	6a02                	ld	s4,0(sp)
    80004062:	6145                	addi	sp,sp,48
    80004064:	8082                	ret

0000000080004066 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80004066:	7179                	addi	sp,sp,-48
    80004068:	f406                	sd	ra,40(sp)
    8000406a:	f022                	sd	s0,32(sp)
    8000406c:	ec26                	sd	s1,24(sp)
    8000406e:	e84a                	sd	s2,16(sp)
    80004070:	e44e                	sd	s3,8(sp)
    80004072:	1800                	addi	s0,sp,48
    80004074:	892a                	mv	s2,a0
    80004076:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80004078:	00015517          	auipc	a0,0x15
    8000407c:	aa050513          	addi	a0,a0,-1376 # 80018b18 <bcache>
    80004080:	ffffd097          	auipc	ra,0xffffd
    80004084:	b4e080e7          	jalr	-1202(ra) # 80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004088:	0001d497          	auipc	s1,0x1d
    8000408c:	d484b483          	ld	s1,-696(s1) # 80020dd0 <bcache+0x82b8>
    80004090:	0001d797          	auipc	a5,0x1d
    80004094:	cf078793          	addi	a5,a5,-784 # 80020d80 <bcache+0x8268>
    80004098:	02f48f63          	beq	s1,a5,800040d6 <bread+0x70>
    8000409c:	873e                	mv	a4,a5
    8000409e:	a021                	j	800040a6 <bread+0x40>
    800040a0:	68a4                	ld	s1,80(s1)
    800040a2:	02e48a63          	beq	s1,a4,800040d6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800040a6:	449c                	lw	a5,8(s1)
    800040a8:	ff279ce3          	bne	a5,s2,800040a0 <bread+0x3a>
    800040ac:	44dc                	lw	a5,12(s1)
    800040ae:	ff3799e3          	bne	a5,s3,800040a0 <bread+0x3a>
      b->refcnt++;
    800040b2:	40bc                	lw	a5,64(s1)
    800040b4:	2785                	addiw	a5,a5,1
    800040b6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800040b8:	00015517          	auipc	a0,0x15
    800040bc:	a6050513          	addi	a0,a0,-1440 # 80018b18 <bcache>
    800040c0:	ffffd097          	auipc	ra,0xffffd
    800040c4:	bc2080e7          	jalr	-1086(ra) # 80000c82 <release>
      acquiresleep(&b->lock);
    800040c8:	01048513          	addi	a0,s1,16
    800040cc:	00001097          	auipc	ra,0x1
    800040d0:	46c080e7          	jalr	1132(ra) # 80005538 <acquiresleep>
      return b;
    800040d4:	a8b9                	j	80004132 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800040d6:	0001d497          	auipc	s1,0x1d
    800040da:	cf24b483          	ld	s1,-782(s1) # 80020dc8 <bcache+0x82b0>
    800040de:	0001d797          	auipc	a5,0x1d
    800040e2:	ca278793          	addi	a5,a5,-862 # 80020d80 <bcache+0x8268>
    800040e6:	00f48863          	beq	s1,a5,800040f6 <bread+0x90>
    800040ea:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800040ec:	40bc                	lw	a5,64(s1)
    800040ee:	cf81                	beqz	a5,80004106 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800040f0:	64a4                	ld	s1,72(s1)
    800040f2:	fee49de3          	bne	s1,a4,800040ec <bread+0x86>
  panic("bget: no buffers");
    800040f6:	00005517          	auipc	a0,0x5
    800040fa:	66a50513          	addi	a0,a0,1642 # 80009760 <syscalls+0x120>
    800040fe:	ffffc097          	auipc	ra,0xffffc
    80004102:	43a080e7          	jalr	1082(ra) # 80000538 <panic>
      b->dev = dev;
    80004106:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000410a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000410e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80004112:	4785                	li	a5,1
    80004114:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004116:	00015517          	auipc	a0,0x15
    8000411a:	a0250513          	addi	a0,a0,-1534 # 80018b18 <bcache>
    8000411e:	ffffd097          	auipc	ra,0xffffd
    80004122:	b64080e7          	jalr	-1180(ra) # 80000c82 <release>
      acquiresleep(&b->lock);
    80004126:	01048513          	addi	a0,s1,16
    8000412a:	00001097          	auipc	ra,0x1
    8000412e:	40e080e7          	jalr	1038(ra) # 80005538 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80004132:	409c                	lw	a5,0(s1)
    80004134:	cb89                	beqz	a5,80004146 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004136:	8526                	mv	a0,s1
    80004138:	70a2                	ld	ra,40(sp)
    8000413a:	7402                	ld	s0,32(sp)
    8000413c:	64e2                	ld	s1,24(sp)
    8000413e:	6942                	ld	s2,16(sp)
    80004140:	69a2                	ld	s3,8(sp)
    80004142:	6145                	addi	sp,sp,48
    80004144:	8082                	ret
    virtio_disk_rw(b, 0);
    80004146:	4581                	li	a1,0
    80004148:	8526                	mv	a0,s1
    8000414a:	00003097          	auipc	ra,0x3
    8000414e:	f28080e7          	jalr	-216(ra) # 80007072 <virtio_disk_rw>
    b->valid = 1;
    80004152:	4785                	li	a5,1
    80004154:	c09c                	sw	a5,0(s1)
  return b;
    80004156:	b7c5                	j	80004136 <bread+0xd0>

0000000080004158 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004158:	1101                	addi	sp,sp,-32
    8000415a:	ec06                	sd	ra,24(sp)
    8000415c:	e822                	sd	s0,16(sp)
    8000415e:	e426                	sd	s1,8(sp)
    80004160:	1000                	addi	s0,sp,32
    80004162:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004164:	0541                	addi	a0,a0,16
    80004166:	00001097          	auipc	ra,0x1
    8000416a:	46c080e7          	jalr	1132(ra) # 800055d2 <holdingsleep>
    8000416e:	cd01                	beqz	a0,80004186 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80004170:	4585                	li	a1,1
    80004172:	8526                	mv	a0,s1
    80004174:	00003097          	auipc	ra,0x3
    80004178:	efe080e7          	jalr	-258(ra) # 80007072 <virtio_disk_rw>
}
    8000417c:	60e2                	ld	ra,24(sp)
    8000417e:	6442                	ld	s0,16(sp)
    80004180:	64a2                	ld	s1,8(sp)
    80004182:	6105                	addi	sp,sp,32
    80004184:	8082                	ret
    panic("bwrite");
    80004186:	00005517          	auipc	a0,0x5
    8000418a:	5f250513          	addi	a0,a0,1522 # 80009778 <syscalls+0x138>
    8000418e:	ffffc097          	auipc	ra,0xffffc
    80004192:	3aa080e7          	jalr	938(ra) # 80000538 <panic>

0000000080004196 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004196:	1101                	addi	sp,sp,-32
    80004198:	ec06                	sd	ra,24(sp)
    8000419a:	e822                	sd	s0,16(sp)
    8000419c:	e426                	sd	s1,8(sp)
    8000419e:	e04a                	sd	s2,0(sp)
    800041a0:	1000                	addi	s0,sp,32
    800041a2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800041a4:	01050913          	addi	s2,a0,16
    800041a8:	854a                	mv	a0,s2
    800041aa:	00001097          	auipc	ra,0x1
    800041ae:	428080e7          	jalr	1064(ra) # 800055d2 <holdingsleep>
    800041b2:	c92d                	beqz	a0,80004224 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800041b4:	854a                	mv	a0,s2
    800041b6:	00001097          	auipc	ra,0x1
    800041ba:	3d8080e7          	jalr	984(ra) # 8000558e <releasesleep>

  acquire(&bcache.lock);
    800041be:	00015517          	auipc	a0,0x15
    800041c2:	95a50513          	addi	a0,a0,-1702 # 80018b18 <bcache>
    800041c6:	ffffd097          	auipc	ra,0xffffd
    800041ca:	a08080e7          	jalr	-1528(ra) # 80000bce <acquire>
  b->refcnt--;
    800041ce:	40bc                	lw	a5,64(s1)
    800041d0:	37fd                	addiw	a5,a5,-1
    800041d2:	0007871b          	sext.w	a4,a5
    800041d6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800041d8:	eb05                	bnez	a4,80004208 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800041da:	68bc                	ld	a5,80(s1)
    800041dc:	64b8                	ld	a4,72(s1)
    800041de:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800041e0:	64bc                	ld	a5,72(s1)
    800041e2:	68b8                	ld	a4,80(s1)
    800041e4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800041e6:	0001d797          	auipc	a5,0x1d
    800041ea:	93278793          	addi	a5,a5,-1742 # 80020b18 <bcache+0x8000>
    800041ee:	2b87b703          	ld	a4,696(a5)
    800041f2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800041f4:	0001d717          	auipc	a4,0x1d
    800041f8:	b8c70713          	addi	a4,a4,-1140 # 80020d80 <bcache+0x8268>
    800041fc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800041fe:	2b87b703          	ld	a4,696(a5)
    80004202:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004204:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004208:	00015517          	auipc	a0,0x15
    8000420c:	91050513          	addi	a0,a0,-1776 # 80018b18 <bcache>
    80004210:	ffffd097          	auipc	ra,0xffffd
    80004214:	a72080e7          	jalr	-1422(ra) # 80000c82 <release>
}
    80004218:	60e2                	ld	ra,24(sp)
    8000421a:	6442                	ld	s0,16(sp)
    8000421c:	64a2                	ld	s1,8(sp)
    8000421e:	6902                	ld	s2,0(sp)
    80004220:	6105                	addi	sp,sp,32
    80004222:	8082                	ret
    panic("brelse");
    80004224:	00005517          	auipc	a0,0x5
    80004228:	55c50513          	addi	a0,a0,1372 # 80009780 <syscalls+0x140>
    8000422c:	ffffc097          	auipc	ra,0xffffc
    80004230:	30c080e7          	jalr	780(ra) # 80000538 <panic>

0000000080004234 <bpin>:

void
bpin(struct buf *b) {
    80004234:	1101                	addi	sp,sp,-32
    80004236:	ec06                	sd	ra,24(sp)
    80004238:	e822                	sd	s0,16(sp)
    8000423a:	e426                	sd	s1,8(sp)
    8000423c:	1000                	addi	s0,sp,32
    8000423e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004240:	00015517          	auipc	a0,0x15
    80004244:	8d850513          	addi	a0,a0,-1832 # 80018b18 <bcache>
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	986080e7          	jalr	-1658(ra) # 80000bce <acquire>
  b->refcnt++;
    80004250:	40bc                	lw	a5,64(s1)
    80004252:	2785                	addiw	a5,a5,1
    80004254:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004256:	00015517          	auipc	a0,0x15
    8000425a:	8c250513          	addi	a0,a0,-1854 # 80018b18 <bcache>
    8000425e:	ffffd097          	auipc	ra,0xffffd
    80004262:	a24080e7          	jalr	-1500(ra) # 80000c82 <release>
}
    80004266:	60e2                	ld	ra,24(sp)
    80004268:	6442                	ld	s0,16(sp)
    8000426a:	64a2                	ld	s1,8(sp)
    8000426c:	6105                	addi	sp,sp,32
    8000426e:	8082                	ret

0000000080004270 <bunpin>:

void
bunpin(struct buf *b) {
    80004270:	1101                	addi	sp,sp,-32
    80004272:	ec06                	sd	ra,24(sp)
    80004274:	e822                	sd	s0,16(sp)
    80004276:	e426                	sd	s1,8(sp)
    80004278:	1000                	addi	s0,sp,32
    8000427a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000427c:	00015517          	auipc	a0,0x15
    80004280:	89c50513          	addi	a0,a0,-1892 # 80018b18 <bcache>
    80004284:	ffffd097          	auipc	ra,0xffffd
    80004288:	94a080e7          	jalr	-1718(ra) # 80000bce <acquire>
  b->refcnt--;
    8000428c:	40bc                	lw	a5,64(s1)
    8000428e:	37fd                	addiw	a5,a5,-1
    80004290:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004292:	00015517          	auipc	a0,0x15
    80004296:	88650513          	addi	a0,a0,-1914 # 80018b18 <bcache>
    8000429a:	ffffd097          	auipc	ra,0xffffd
    8000429e:	9e8080e7          	jalr	-1560(ra) # 80000c82 <release>
}
    800042a2:	60e2                	ld	ra,24(sp)
    800042a4:	6442                	ld	s0,16(sp)
    800042a6:	64a2                	ld	s1,8(sp)
    800042a8:	6105                	addi	sp,sp,32
    800042aa:	8082                	ret

00000000800042ac <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800042ac:	1101                	addi	sp,sp,-32
    800042ae:	ec06                	sd	ra,24(sp)
    800042b0:	e822                	sd	s0,16(sp)
    800042b2:	e426                	sd	s1,8(sp)
    800042b4:	e04a                	sd	s2,0(sp)
    800042b6:	1000                	addi	s0,sp,32
    800042b8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800042ba:	00d5d59b          	srliw	a1,a1,0xd
    800042be:	0001d797          	auipc	a5,0x1d
    800042c2:	f367a783          	lw	a5,-202(a5) # 800211f4 <sb+0x1c>
    800042c6:	9dbd                	addw	a1,a1,a5
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	d9e080e7          	jalr	-610(ra) # 80004066 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800042d0:	0074f713          	andi	a4,s1,7
    800042d4:	4785                	li	a5,1
    800042d6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800042da:	14ce                	slli	s1,s1,0x33
    800042dc:	90d9                	srli	s1,s1,0x36
    800042de:	00950733          	add	a4,a0,s1
    800042e2:	05874703          	lbu	a4,88(a4)
    800042e6:	00e7f6b3          	and	a3,a5,a4
    800042ea:	c69d                	beqz	a3,80004318 <bfree+0x6c>
    800042ec:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800042ee:	94aa                	add	s1,s1,a0
    800042f0:	fff7c793          	not	a5,a5
    800042f4:	8f7d                	and	a4,a4,a5
    800042f6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800042fa:	00001097          	auipc	ra,0x1
    800042fe:	120080e7          	jalr	288(ra) # 8000541a <log_write>
  brelse(bp);
    80004302:	854a                	mv	a0,s2
    80004304:	00000097          	auipc	ra,0x0
    80004308:	e92080e7          	jalr	-366(ra) # 80004196 <brelse>
}
    8000430c:	60e2                	ld	ra,24(sp)
    8000430e:	6442                	ld	s0,16(sp)
    80004310:	64a2                	ld	s1,8(sp)
    80004312:	6902                	ld	s2,0(sp)
    80004314:	6105                	addi	sp,sp,32
    80004316:	8082                	ret
    panic("freeing free block");
    80004318:	00005517          	auipc	a0,0x5
    8000431c:	47050513          	addi	a0,a0,1136 # 80009788 <syscalls+0x148>
    80004320:	ffffc097          	auipc	ra,0xffffc
    80004324:	218080e7          	jalr	536(ra) # 80000538 <panic>

0000000080004328 <balloc>:
{
    80004328:	711d                	addi	sp,sp,-96
    8000432a:	ec86                	sd	ra,88(sp)
    8000432c:	e8a2                	sd	s0,80(sp)
    8000432e:	e4a6                	sd	s1,72(sp)
    80004330:	e0ca                	sd	s2,64(sp)
    80004332:	fc4e                	sd	s3,56(sp)
    80004334:	f852                	sd	s4,48(sp)
    80004336:	f456                	sd	s5,40(sp)
    80004338:	f05a                	sd	s6,32(sp)
    8000433a:	ec5e                	sd	s7,24(sp)
    8000433c:	e862                	sd	s8,16(sp)
    8000433e:	e466                	sd	s9,8(sp)
    80004340:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80004342:	0001d797          	auipc	a5,0x1d
    80004346:	e9a7a783          	lw	a5,-358(a5) # 800211dc <sb+0x4>
    8000434a:	cbc1                	beqz	a5,800043da <balloc+0xb2>
    8000434c:	8baa                	mv	s7,a0
    8000434e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004350:	0001db17          	auipc	s6,0x1d
    80004354:	e88b0b13          	addi	s6,s6,-376 # 800211d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004358:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000435a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000435c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000435e:	6c89                	lui	s9,0x2
    80004360:	a831                	j	8000437c <balloc+0x54>
    brelse(bp);
    80004362:	854a                	mv	a0,s2
    80004364:	00000097          	auipc	ra,0x0
    80004368:	e32080e7          	jalr	-462(ra) # 80004196 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000436c:	015c87bb          	addw	a5,s9,s5
    80004370:	00078a9b          	sext.w	s5,a5
    80004374:	004b2703          	lw	a4,4(s6)
    80004378:	06eaf163          	bgeu	s5,a4,800043da <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    8000437c:	41fad79b          	sraiw	a5,s5,0x1f
    80004380:	0137d79b          	srliw	a5,a5,0x13
    80004384:	015787bb          	addw	a5,a5,s5
    80004388:	40d7d79b          	sraiw	a5,a5,0xd
    8000438c:	01cb2583          	lw	a1,28(s6)
    80004390:	9dbd                	addw	a1,a1,a5
    80004392:	855e                	mv	a0,s7
    80004394:	00000097          	auipc	ra,0x0
    80004398:	cd2080e7          	jalr	-814(ra) # 80004066 <bread>
    8000439c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000439e:	004b2503          	lw	a0,4(s6)
    800043a2:	000a849b          	sext.w	s1,s5
    800043a6:	8762                	mv	a4,s8
    800043a8:	faa4fde3          	bgeu	s1,a0,80004362 <balloc+0x3a>
      m = 1 << (bi % 8);
    800043ac:	00777693          	andi	a3,a4,7
    800043b0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800043b4:	41f7579b          	sraiw	a5,a4,0x1f
    800043b8:	01d7d79b          	srliw	a5,a5,0x1d
    800043bc:	9fb9                	addw	a5,a5,a4
    800043be:	4037d79b          	sraiw	a5,a5,0x3
    800043c2:	00f90633          	add	a2,s2,a5
    800043c6:	05864603          	lbu	a2,88(a2)
    800043ca:	00c6f5b3          	and	a1,a3,a2
    800043ce:	cd91                	beqz	a1,800043ea <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800043d0:	2705                	addiw	a4,a4,1
    800043d2:	2485                	addiw	s1,s1,1
    800043d4:	fd471ae3          	bne	a4,s4,800043a8 <balloc+0x80>
    800043d8:	b769                	j	80004362 <balloc+0x3a>
  panic("balloc: out of blocks");
    800043da:	00005517          	auipc	a0,0x5
    800043de:	3c650513          	addi	a0,a0,966 # 800097a0 <syscalls+0x160>
    800043e2:	ffffc097          	auipc	ra,0xffffc
    800043e6:	156080e7          	jalr	342(ra) # 80000538 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800043ea:	97ca                	add	a5,a5,s2
    800043ec:	8e55                	or	a2,a2,a3
    800043ee:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800043f2:	854a                	mv	a0,s2
    800043f4:	00001097          	auipc	ra,0x1
    800043f8:	026080e7          	jalr	38(ra) # 8000541a <log_write>
        brelse(bp);
    800043fc:	854a                	mv	a0,s2
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	d98080e7          	jalr	-616(ra) # 80004196 <brelse>
  bp = bread(dev, bno);
    80004406:	85a6                	mv	a1,s1
    80004408:	855e                	mv	a0,s7
    8000440a:	00000097          	auipc	ra,0x0
    8000440e:	c5c080e7          	jalr	-932(ra) # 80004066 <bread>
    80004412:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004414:	40000613          	li	a2,1024
    80004418:	4581                	li	a1,0
    8000441a:	05850513          	addi	a0,a0,88
    8000441e:	ffffd097          	auipc	ra,0xffffd
    80004422:	8ac080e7          	jalr	-1876(ra) # 80000cca <memset>
  log_write(bp);
    80004426:	854a                	mv	a0,s2
    80004428:	00001097          	auipc	ra,0x1
    8000442c:	ff2080e7          	jalr	-14(ra) # 8000541a <log_write>
  brelse(bp);
    80004430:	854a                	mv	a0,s2
    80004432:	00000097          	auipc	ra,0x0
    80004436:	d64080e7          	jalr	-668(ra) # 80004196 <brelse>
}
    8000443a:	8526                	mv	a0,s1
    8000443c:	60e6                	ld	ra,88(sp)
    8000443e:	6446                	ld	s0,80(sp)
    80004440:	64a6                	ld	s1,72(sp)
    80004442:	6906                	ld	s2,64(sp)
    80004444:	79e2                	ld	s3,56(sp)
    80004446:	7a42                	ld	s4,48(sp)
    80004448:	7aa2                	ld	s5,40(sp)
    8000444a:	7b02                	ld	s6,32(sp)
    8000444c:	6be2                	ld	s7,24(sp)
    8000444e:	6c42                	ld	s8,16(sp)
    80004450:	6ca2                	ld	s9,8(sp)
    80004452:	6125                	addi	sp,sp,96
    80004454:	8082                	ret

0000000080004456 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004456:	7179                	addi	sp,sp,-48
    80004458:	f406                	sd	ra,40(sp)
    8000445a:	f022                	sd	s0,32(sp)
    8000445c:	ec26                	sd	s1,24(sp)
    8000445e:	e84a                	sd	s2,16(sp)
    80004460:	e44e                	sd	s3,8(sp)
    80004462:	e052                	sd	s4,0(sp)
    80004464:	1800                	addi	s0,sp,48
    80004466:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004468:	47ad                	li	a5,11
    8000446a:	04b7fe63          	bgeu	a5,a1,800044c6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000446e:	ff45849b          	addiw	s1,a1,-12
    80004472:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004476:	0ff00793          	li	a5,255
    8000447a:	0ae7e463          	bltu	a5,a4,80004522 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000447e:	08052583          	lw	a1,128(a0)
    80004482:	c5b5                	beqz	a1,800044ee <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004484:	00092503          	lw	a0,0(s2)
    80004488:	00000097          	auipc	ra,0x0
    8000448c:	bde080e7          	jalr	-1058(ra) # 80004066 <bread>
    80004490:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004492:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004496:	02049713          	slli	a4,s1,0x20
    8000449a:	01e75593          	srli	a1,a4,0x1e
    8000449e:	00b784b3          	add	s1,a5,a1
    800044a2:	0004a983          	lw	s3,0(s1)
    800044a6:	04098e63          	beqz	s3,80004502 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800044aa:	8552                	mv	a0,s4
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	cea080e7          	jalr	-790(ra) # 80004196 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800044b4:	854e                	mv	a0,s3
    800044b6:	70a2                	ld	ra,40(sp)
    800044b8:	7402                	ld	s0,32(sp)
    800044ba:	64e2                	ld	s1,24(sp)
    800044bc:	6942                	ld	s2,16(sp)
    800044be:	69a2                	ld	s3,8(sp)
    800044c0:	6a02                	ld	s4,0(sp)
    800044c2:	6145                	addi	sp,sp,48
    800044c4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800044c6:	02059793          	slli	a5,a1,0x20
    800044ca:	01e7d593          	srli	a1,a5,0x1e
    800044ce:	00b504b3          	add	s1,a0,a1
    800044d2:	0504a983          	lw	s3,80(s1)
    800044d6:	fc099fe3          	bnez	s3,800044b4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800044da:	4108                	lw	a0,0(a0)
    800044dc:	00000097          	auipc	ra,0x0
    800044e0:	e4c080e7          	jalr	-436(ra) # 80004328 <balloc>
    800044e4:	0005099b          	sext.w	s3,a0
    800044e8:	0534a823          	sw	s3,80(s1)
    800044ec:	b7e1                	j	800044b4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800044ee:	4108                	lw	a0,0(a0)
    800044f0:	00000097          	auipc	ra,0x0
    800044f4:	e38080e7          	jalr	-456(ra) # 80004328 <balloc>
    800044f8:	0005059b          	sext.w	a1,a0
    800044fc:	08b92023          	sw	a1,128(s2)
    80004500:	b751                	j	80004484 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004502:	00092503          	lw	a0,0(s2)
    80004506:	00000097          	auipc	ra,0x0
    8000450a:	e22080e7          	jalr	-478(ra) # 80004328 <balloc>
    8000450e:	0005099b          	sext.w	s3,a0
    80004512:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004516:	8552                	mv	a0,s4
    80004518:	00001097          	auipc	ra,0x1
    8000451c:	f02080e7          	jalr	-254(ra) # 8000541a <log_write>
    80004520:	b769                	j	800044aa <bmap+0x54>
  panic("bmap: out of range");
    80004522:	00005517          	auipc	a0,0x5
    80004526:	29650513          	addi	a0,a0,662 # 800097b8 <syscalls+0x178>
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	00e080e7          	jalr	14(ra) # 80000538 <panic>

0000000080004532 <iget>:
{
    80004532:	7179                	addi	sp,sp,-48
    80004534:	f406                	sd	ra,40(sp)
    80004536:	f022                	sd	s0,32(sp)
    80004538:	ec26                	sd	s1,24(sp)
    8000453a:	e84a                	sd	s2,16(sp)
    8000453c:	e44e                	sd	s3,8(sp)
    8000453e:	e052                	sd	s4,0(sp)
    80004540:	1800                	addi	s0,sp,48
    80004542:	89aa                	mv	s3,a0
    80004544:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004546:	0001d517          	auipc	a0,0x1d
    8000454a:	cb250513          	addi	a0,a0,-846 # 800211f8 <itable>
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	680080e7          	jalr	1664(ra) # 80000bce <acquire>
  empty = 0;
    80004556:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004558:	0001d497          	auipc	s1,0x1d
    8000455c:	cb848493          	addi	s1,s1,-840 # 80021210 <itable+0x18>
    80004560:	0001e697          	auipc	a3,0x1e
    80004564:	74068693          	addi	a3,a3,1856 # 80022ca0 <log>
    80004568:	a039                	j	80004576 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000456a:	02090b63          	beqz	s2,800045a0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000456e:	08848493          	addi	s1,s1,136
    80004572:	02d48a63          	beq	s1,a3,800045a6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004576:	449c                	lw	a5,8(s1)
    80004578:	fef059e3          	blez	a5,8000456a <iget+0x38>
    8000457c:	4098                	lw	a4,0(s1)
    8000457e:	ff3716e3          	bne	a4,s3,8000456a <iget+0x38>
    80004582:	40d8                	lw	a4,4(s1)
    80004584:	ff4713e3          	bne	a4,s4,8000456a <iget+0x38>
      ip->ref++;
    80004588:	2785                	addiw	a5,a5,1
    8000458a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000458c:	0001d517          	auipc	a0,0x1d
    80004590:	c6c50513          	addi	a0,a0,-916 # 800211f8 <itable>
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	6ee080e7          	jalr	1774(ra) # 80000c82 <release>
      return ip;
    8000459c:	8926                	mv	s2,s1
    8000459e:	a03d                	j	800045cc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800045a0:	f7f9                	bnez	a5,8000456e <iget+0x3c>
    800045a2:	8926                	mv	s2,s1
    800045a4:	b7e9                	j	8000456e <iget+0x3c>
  if(empty == 0)
    800045a6:	02090c63          	beqz	s2,800045de <iget+0xac>
  ip->dev = dev;
    800045aa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800045ae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800045b2:	4785                	li	a5,1
    800045b4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800045b8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800045bc:	0001d517          	auipc	a0,0x1d
    800045c0:	c3c50513          	addi	a0,a0,-964 # 800211f8 <itable>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	6be080e7          	jalr	1726(ra) # 80000c82 <release>
}
    800045cc:	854a                	mv	a0,s2
    800045ce:	70a2                	ld	ra,40(sp)
    800045d0:	7402                	ld	s0,32(sp)
    800045d2:	64e2                	ld	s1,24(sp)
    800045d4:	6942                	ld	s2,16(sp)
    800045d6:	69a2                	ld	s3,8(sp)
    800045d8:	6a02                	ld	s4,0(sp)
    800045da:	6145                	addi	sp,sp,48
    800045dc:	8082                	ret
    panic("iget: no inodes");
    800045de:	00005517          	auipc	a0,0x5
    800045e2:	1f250513          	addi	a0,a0,498 # 800097d0 <syscalls+0x190>
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	f52080e7          	jalr	-174(ra) # 80000538 <panic>

00000000800045ee <fsinit>:
fsinit(int dev) {
    800045ee:	7179                	addi	sp,sp,-48
    800045f0:	f406                	sd	ra,40(sp)
    800045f2:	f022                	sd	s0,32(sp)
    800045f4:	ec26                	sd	s1,24(sp)
    800045f6:	e84a                	sd	s2,16(sp)
    800045f8:	e44e                	sd	s3,8(sp)
    800045fa:	1800                	addi	s0,sp,48
    800045fc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800045fe:	4585                	li	a1,1
    80004600:	00000097          	auipc	ra,0x0
    80004604:	a66080e7          	jalr	-1434(ra) # 80004066 <bread>
    80004608:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000460a:	0001d997          	auipc	s3,0x1d
    8000460e:	bce98993          	addi	s3,s3,-1074 # 800211d8 <sb>
    80004612:	02000613          	li	a2,32
    80004616:	05850593          	addi	a1,a0,88
    8000461a:	854e                	mv	a0,s3
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	70a080e7          	jalr	1802(ra) # 80000d26 <memmove>
  brelse(bp);
    80004624:	8526                	mv	a0,s1
    80004626:	00000097          	auipc	ra,0x0
    8000462a:	b70080e7          	jalr	-1168(ra) # 80004196 <brelse>
  if(sb.magic != FSMAGIC)
    8000462e:	0009a703          	lw	a4,0(s3)
    80004632:	102037b7          	lui	a5,0x10203
    80004636:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000463a:	02f71263          	bne	a4,a5,8000465e <fsinit+0x70>
  initlog(dev, &sb);
    8000463e:	0001d597          	auipc	a1,0x1d
    80004642:	b9a58593          	addi	a1,a1,-1126 # 800211d8 <sb>
    80004646:	854a                	mv	a0,s2
    80004648:	00001097          	auipc	ra,0x1
    8000464c:	b56080e7          	jalr	-1194(ra) # 8000519e <initlog>
}
    80004650:	70a2                	ld	ra,40(sp)
    80004652:	7402                	ld	s0,32(sp)
    80004654:	64e2                	ld	s1,24(sp)
    80004656:	6942                	ld	s2,16(sp)
    80004658:	69a2                	ld	s3,8(sp)
    8000465a:	6145                	addi	sp,sp,48
    8000465c:	8082                	ret
    panic("invalid file system");
    8000465e:	00005517          	auipc	a0,0x5
    80004662:	18250513          	addi	a0,a0,386 # 800097e0 <syscalls+0x1a0>
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	ed2080e7          	jalr	-302(ra) # 80000538 <panic>

000000008000466e <iinit>:
{
    8000466e:	7179                	addi	sp,sp,-48
    80004670:	f406                	sd	ra,40(sp)
    80004672:	f022                	sd	s0,32(sp)
    80004674:	ec26                	sd	s1,24(sp)
    80004676:	e84a                	sd	s2,16(sp)
    80004678:	e44e                	sd	s3,8(sp)
    8000467a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000467c:	00005597          	auipc	a1,0x5
    80004680:	17c58593          	addi	a1,a1,380 # 800097f8 <syscalls+0x1b8>
    80004684:	0001d517          	auipc	a0,0x1d
    80004688:	b7450513          	addi	a0,a0,-1164 # 800211f8 <itable>
    8000468c:	ffffc097          	auipc	ra,0xffffc
    80004690:	4b2080e7          	jalr	1202(ra) # 80000b3e <initlock>
  for(i = 0; i < NINODE; i++) {
    80004694:	0001d497          	auipc	s1,0x1d
    80004698:	b8c48493          	addi	s1,s1,-1140 # 80021220 <itable+0x28>
    8000469c:	0001e997          	auipc	s3,0x1e
    800046a0:	61498993          	addi	s3,s3,1556 # 80022cb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800046a4:	00005917          	auipc	s2,0x5
    800046a8:	15c90913          	addi	s2,s2,348 # 80009800 <syscalls+0x1c0>
    800046ac:	85ca                	mv	a1,s2
    800046ae:	8526                	mv	a0,s1
    800046b0:	00001097          	auipc	ra,0x1
    800046b4:	e4e080e7          	jalr	-434(ra) # 800054fe <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800046b8:	08848493          	addi	s1,s1,136
    800046bc:	ff3498e3          	bne	s1,s3,800046ac <iinit+0x3e>
}
    800046c0:	70a2                	ld	ra,40(sp)
    800046c2:	7402                	ld	s0,32(sp)
    800046c4:	64e2                	ld	s1,24(sp)
    800046c6:	6942                	ld	s2,16(sp)
    800046c8:	69a2                	ld	s3,8(sp)
    800046ca:	6145                	addi	sp,sp,48
    800046cc:	8082                	ret

00000000800046ce <ialloc>:
{
    800046ce:	715d                	addi	sp,sp,-80
    800046d0:	e486                	sd	ra,72(sp)
    800046d2:	e0a2                	sd	s0,64(sp)
    800046d4:	fc26                	sd	s1,56(sp)
    800046d6:	f84a                	sd	s2,48(sp)
    800046d8:	f44e                	sd	s3,40(sp)
    800046da:	f052                	sd	s4,32(sp)
    800046dc:	ec56                	sd	s5,24(sp)
    800046de:	e85a                	sd	s6,16(sp)
    800046e0:	e45e                	sd	s7,8(sp)
    800046e2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800046e4:	0001d717          	auipc	a4,0x1d
    800046e8:	b0072703          	lw	a4,-1280(a4) # 800211e4 <sb+0xc>
    800046ec:	4785                	li	a5,1
    800046ee:	04e7fa63          	bgeu	a5,a4,80004742 <ialloc+0x74>
    800046f2:	8aaa                	mv	s5,a0
    800046f4:	8bae                	mv	s7,a1
    800046f6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800046f8:	0001da17          	auipc	s4,0x1d
    800046fc:	ae0a0a13          	addi	s4,s4,-1312 # 800211d8 <sb>
    80004700:	00048b1b          	sext.w	s6,s1
    80004704:	0044d593          	srli	a1,s1,0x4
    80004708:	018a2783          	lw	a5,24(s4)
    8000470c:	9dbd                	addw	a1,a1,a5
    8000470e:	8556                	mv	a0,s5
    80004710:	00000097          	auipc	ra,0x0
    80004714:	956080e7          	jalr	-1706(ra) # 80004066 <bread>
    80004718:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000471a:	05850993          	addi	s3,a0,88
    8000471e:	00f4f793          	andi	a5,s1,15
    80004722:	079a                	slli	a5,a5,0x6
    80004724:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004726:	00099783          	lh	a5,0(s3)
    8000472a:	c785                	beqz	a5,80004752 <ialloc+0x84>
    brelse(bp);
    8000472c:	00000097          	auipc	ra,0x0
    80004730:	a6a080e7          	jalr	-1430(ra) # 80004196 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004734:	0485                	addi	s1,s1,1
    80004736:	00ca2703          	lw	a4,12(s4)
    8000473a:	0004879b          	sext.w	a5,s1
    8000473e:	fce7e1e3          	bltu	a5,a4,80004700 <ialloc+0x32>
  panic("ialloc: no inodes");
    80004742:	00005517          	auipc	a0,0x5
    80004746:	0c650513          	addi	a0,a0,198 # 80009808 <syscalls+0x1c8>
    8000474a:	ffffc097          	auipc	ra,0xffffc
    8000474e:	dee080e7          	jalr	-530(ra) # 80000538 <panic>
      memset(dip, 0, sizeof(*dip));
    80004752:	04000613          	li	a2,64
    80004756:	4581                	li	a1,0
    80004758:	854e                	mv	a0,s3
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	570080e7          	jalr	1392(ra) # 80000cca <memset>
      dip->type = type;
    80004762:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004766:	854a                	mv	a0,s2
    80004768:	00001097          	auipc	ra,0x1
    8000476c:	cb2080e7          	jalr	-846(ra) # 8000541a <log_write>
      brelse(bp);
    80004770:	854a                	mv	a0,s2
    80004772:	00000097          	auipc	ra,0x0
    80004776:	a24080e7          	jalr	-1500(ra) # 80004196 <brelse>
      return iget(dev, inum);
    8000477a:	85da                	mv	a1,s6
    8000477c:	8556                	mv	a0,s5
    8000477e:	00000097          	auipc	ra,0x0
    80004782:	db4080e7          	jalr	-588(ra) # 80004532 <iget>
}
    80004786:	60a6                	ld	ra,72(sp)
    80004788:	6406                	ld	s0,64(sp)
    8000478a:	74e2                	ld	s1,56(sp)
    8000478c:	7942                	ld	s2,48(sp)
    8000478e:	79a2                	ld	s3,40(sp)
    80004790:	7a02                	ld	s4,32(sp)
    80004792:	6ae2                	ld	s5,24(sp)
    80004794:	6b42                	ld	s6,16(sp)
    80004796:	6ba2                	ld	s7,8(sp)
    80004798:	6161                	addi	sp,sp,80
    8000479a:	8082                	ret

000000008000479c <iupdate>:
{
    8000479c:	1101                	addi	sp,sp,-32
    8000479e:	ec06                	sd	ra,24(sp)
    800047a0:	e822                	sd	s0,16(sp)
    800047a2:	e426                	sd	s1,8(sp)
    800047a4:	e04a                	sd	s2,0(sp)
    800047a6:	1000                	addi	s0,sp,32
    800047a8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800047aa:	415c                	lw	a5,4(a0)
    800047ac:	0047d79b          	srliw	a5,a5,0x4
    800047b0:	0001d597          	auipc	a1,0x1d
    800047b4:	a405a583          	lw	a1,-1472(a1) # 800211f0 <sb+0x18>
    800047b8:	9dbd                	addw	a1,a1,a5
    800047ba:	4108                	lw	a0,0(a0)
    800047bc:	00000097          	auipc	ra,0x0
    800047c0:	8aa080e7          	jalr	-1878(ra) # 80004066 <bread>
    800047c4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800047c6:	05850793          	addi	a5,a0,88
    800047ca:	40d8                	lw	a4,4(s1)
    800047cc:	8b3d                	andi	a4,a4,15
    800047ce:	071a                	slli	a4,a4,0x6
    800047d0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800047d2:	04449703          	lh	a4,68(s1)
    800047d6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800047da:	04649703          	lh	a4,70(s1)
    800047de:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800047e2:	04849703          	lh	a4,72(s1)
    800047e6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800047ea:	04a49703          	lh	a4,74(s1)
    800047ee:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800047f2:	44f8                	lw	a4,76(s1)
    800047f4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800047f6:	03400613          	li	a2,52
    800047fa:	05048593          	addi	a1,s1,80
    800047fe:	00c78513          	addi	a0,a5,12
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	524080e7          	jalr	1316(ra) # 80000d26 <memmove>
  log_write(bp);
    8000480a:	854a                	mv	a0,s2
    8000480c:	00001097          	auipc	ra,0x1
    80004810:	c0e080e7          	jalr	-1010(ra) # 8000541a <log_write>
  brelse(bp);
    80004814:	854a                	mv	a0,s2
    80004816:	00000097          	auipc	ra,0x0
    8000481a:	980080e7          	jalr	-1664(ra) # 80004196 <brelse>
}
    8000481e:	60e2                	ld	ra,24(sp)
    80004820:	6442                	ld	s0,16(sp)
    80004822:	64a2                	ld	s1,8(sp)
    80004824:	6902                	ld	s2,0(sp)
    80004826:	6105                	addi	sp,sp,32
    80004828:	8082                	ret

000000008000482a <idup>:
{
    8000482a:	1101                	addi	sp,sp,-32
    8000482c:	ec06                	sd	ra,24(sp)
    8000482e:	e822                	sd	s0,16(sp)
    80004830:	e426                	sd	s1,8(sp)
    80004832:	1000                	addi	s0,sp,32
    80004834:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004836:	0001d517          	auipc	a0,0x1d
    8000483a:	9c250513          	addi	a0,a0,-1598 # 800211f8 <itable>
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	390080e7          	jalr	912(ra) # 80000bce <acquire>
  ip->ref++;
    80004846:	449c                	lw	a5,8(s1)
    80004848:	2785                	addiw	a5,a5,1
    8000484a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000484c:	0001d517          	auipc	a0,0x1d
    80004850:	9ac50513          	addi	a0,a0,-1620 # 800211f8 <itable>
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	42e080e7          	jalr	1070(ra) # 80000c82 <release>
}
    8000485c:	8526                	mv	a0,s1
    8000485e:	60e2                	ld	ra,24(sp)
    80004860:	6442                	ld	s0,16(sp)
    80004862:	64a2                	ld	s1,8(sp)
    80004864:	6105                	addi	sp,sp,32
    80004866:	8082                	ret

0000000080004868 <ilock>:
{
    80004868:	1101                	addi	sp,sp,-32
    8000486a:	ec06                	sd	ra,24(sp)
    8000486c:	e822                	sd	s0,16(sp)
    8000486e:	e426                	sd	s1,8(sp)
    80004870:	e04a                	sd	s2,0(sp)
    80004872:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004874:	c115                	beqz	a0,80004898 <ilock+0x30>
    80004876:	84aa                	mv	s1,a0
    80004878:	451c                	lw	a5,8(a0)
    8000487a:	00f05f63          	blez	a5,80004898 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000487e:	0541                	addi	a0,a0,16
    80004880:	00001097          	auipc	ra,0x1
    80004884:	cb8080e7          	jalr	-840(ra) # 80005538 <acquiresleep>
  if(ip->valid == 0){
    80004888:	40bc                	lw	a5,64(s1)
    8000488a:	cf99                	beqz	a5,800048a8 <ilock+0x40>
}
    8000488c:	60e2                	ld	ra,24(sp)
    8000488e:	6442                	ld	s0,16(sp)
    80004890:	64a2                	ld	s1,8(sp)
    80004892:	6902                	ld	s2,0(sp)
    80004894:	6105                	addi	sp,sp,32
    80004896:	8082                	ret
    panic("ilock");
    80004898:	00005517          	auipc	a0,0x5
    8000489c:	f8850513          	addi	a0,a0,-120 # 80009820 <syscalls+0x1e0>
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	c98080e7          	jalr	-872(ra) # 80000538 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800048a8:	40dc                	lw	a5,4(s1)
    800048aa:	0047d79b          	srliw	a5,a5,0x4
    800048ae:	0001d597          	auipc	a1,0x1d
    800048b2:	9425a583          	lw	a1,-1726(a1) # 800211f0 <sb+0x18>
    800048b6:	9dbd                	addw	a1,a1,a5
    800048b8:	4088                	lw	a0,0(s1)
    800048ba:	fffff097          	auipc	ra,0xfffff
    800048be:	7ac080e7          	jalr	1964(ra) # 80004066 <bread>
    800048c2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800048c4:	05850593          	addi	a1,a0,88
    800048c8:	40dc                	lw	a5,4(s1)
    800048ca:	8bbd                	andi	a5,a5,15
    800048cc:	079a                	slli	a5,a5,0x6
    800048ce:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800048d0:	00059783          	lh	a5,0(a1)
    800048d4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800048d8:	00259783          	lh	a5,2(a1)
    800048dc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800048e0:	00459783          	lh	a5,4(a1)
    800048e4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800048e8:	00659783          	lh	a5,6(a1)
    800048ec:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800048f0:	459c                	lw	a5,8(a1)
    800048f2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800048f4:	03400613          	li	a2,52
    800048f8:	05b1                	addi	a1,a1,12
    800048fa:	05048513          	addi	a0,s1,80
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	428080e7          	jalr	1064(ra) # 80000d26 <memmove>
    brelse(bp);
    80004906:	854a                	mv	a0,s2
    80004908:	00000097          	auipc	ra,0x0
    8000490c:	88e080e7          	jalr	-1906(ra) # 80004196 <brelse>
    ip->valid = 1;
    80004910:	4785                	li	a5,1
    80004912:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004914:	04449783          	lh	a5,68(s1)
    80004918:	fbb5                	bnez	a5,8000488c <ilock+0x24>
      panic("ilock: no type");
    8000491a:	00005517          	auipc	a0,0x5
    8000491e:	f0e50513          	addi	a0,a0,-242 # 80009828 <syscalls+0x1e8>
    80004922:	ffffc097          	auipc	ra,0xffffc
    80004926:	c16080e7          	jalr	-1002(ra) # 80000538 <panic>

000000008000492a <iunlock>:
{
    8000492a:	1101                	addi	sp,sp,-32
    8000492c:	ec06                	sd	ra,24(sp)
    8000492e:	e822                	sd	s0,16(sp)
    80004930:	e426                	sd	s1,8(sp)
    80004932:	e04a                	sd	s2,0(sp)
    80004934:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004936:	c905                	beqz	a0,80004966 <iunlock+0x3c>
    80004938:	84aa                	mv	s1,a0
    8000493a:	01050913          	addi	s2,a0,16
    8000493e:	854a                	mv	a0,s2
    80004940:	00001097          	auipc	ra,0x1
    80004944:	c92080e7          	jalr	-878(ra) # 800055d2 <holdingsleep>
    80004948:	cd19                	beqz	a0,80004966 <iunlock+0x3c>
    8000494a:	449c                	lw	a5,8(s1)
    8000494c:	00f05d63          	blez	a5,80004966 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004950:	854a                	mv	a0,s2
    80004952:	00001097          	auipc	ra,0x1
    80004956:	c3c080e7          	jalr	-964(ra) # 8000558e <releasesleep>
}
    8000495a:	60e2                	ld	ra,24(sp)
    8000495c:	6442                	ld	s0,16(sp)
    8000495e:	64a2                	ld	s1,8(sp)
    80004960:	6902                	ld	s2,0(sp)
    80004962:	6105                	addi	sp,sp,32
    80004964:	8082                	ret
    panic("iunlock");
    80004966:	00005517          	auipc	a0,0x5
    8000496a:	ed250513          	addi	a0,a0,-302 # 80009838 <syscalls+0x1f8>
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	bca080e7          	jalr	-1078(ra) # 80000538 <panic>

0000000080004976 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004976:	7179                	addi	sp,sp,-48
    80004978:	f406                	sd	ra,40(sp)
    8000497a:	f022                	sd	s0,32(sp)
    8000497c:	ec26                	sd	s1,24(sp)
    8000497e:	e84a                	sd	s2,16(sp)
    80004980:	e44e                	sd	s3,8(sp)
    80004982:	e052                	sd	s4,0(sp)
    80004984:	1800                	addi	s0,sp,48
    80004986:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004988:	05050493          	addi	s1,a0,80
    8000498c:	08050913          	addi	s2,a0,128
    80004990:	a021                	j	80004998 <itrunc+0x22>
    80004992:	0491                	addi	s1,s1,4
    80004994:	01248d63          	beq	s1,s2,800049ae <itrunc+0x38>
    if(ip->addrs[i]){
    80004998:	408c                	lw	a1,0(s1)
    8000499a:	dde5                	beqz	a1,80004992 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000499c:	0009a503          	lw	a0,0(s3)
    800049a0:	00000097          	auipc	ra,0x0
    800049a4:	90c080e7          	jalr	-1780(ra) # 800042ac <bfree>
      ip->addrs[i] = 0;
    800049a8:	0004a023          	sw	zero,0(s1)
    800049ac:	b7dd                	j	80004992 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800049ae:	0809a583          	lw	a1,128(s3)
    800049b2:	e185                	bnez	a1,800049d2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800049b4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800049b8:	854e                	mv	a0,s3
    800049ba:	00000097          	auipc	ra,0x0
    800049be:	de2080e7          	jalr	-542(ra) # 8000479c <iupdate>
}
    800049c2:	70a2                	ld	ra,40(sp)
    800049c4:	7402                	ld	s0,32(sp)
    800049c6:	64e2                	ld	s1,24(sp)
    800049c8:	6942                	ld	s2,16(sp)
    800049ca:	69a2                	ld	s3,8(sp)
    800049cc:	6a02                	ld	s4,0(sp)
    800049ce:	6145                	addi	sp,sp,48
    800049d0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800049d2:	0009a503          	lw	a0,0(s3)
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	690080e7          	jalr	1680(ra) # 80004066 <bread>
    800049de:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800049e0:	05850493          	addi	s1,a0,88
    800049e4:	45850913          	addi	s2,a0,1112
    800049e8:	a021                	j	800049f0 <itrunc+0x7a>
    800049ea:	0491                	addi	s1,s1,4
    800049ec:	01248b63          	beq	s1,s2,80004a02 <itrunc+0x8c>
      if(a[j])
    800049f0:	408c                	lw	a1,0(s1)
    800049f2:	dde5                	beqz	a1,800049ea <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800049f4:	0009a503          	lw	a0,0(s3)
    800049f8:	00000097          	auipc	ra,0x0
    800049fc:	8b4080e7          	jalr	-1868(ra) # 800042ac <bfree>
    80004a00:	b7ed                	j	800049ea <itrunc+0x74>
    brelse(bp);
    80004a02:	8552                	mv	a0,s4
    80004a04:	fffff097          	auipc	ra,0xfffff
    80004a08:	792080e7          	jalr	1938(ra) # 80004196 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004a0c:	0809a583          	lw	a1,128(s3)
    80004a10:	0009a503          	lw	a0,0(s3)
    80004a14:	00000097          	auipc	ra,0x0
    80004a18:	898080e7          	jalr	-1896(ra) # 800042ac <bfree>
    ip->addrs[NDIRECT] = 0;
    80004a1c:	0809a023          	sw	zero,128(s3)
    80004a20:	bf51                	j	800049b4 <itrunc+0x3e>

0000000080004a22 <iput>:
{
    80004a22:	1101                	addi	sp,sp,-32
    80004a24:	ec06                	sd	ra,24(sp)
    80004a26:	e822                	sd	s0,16(sp)
    80004a28:	e426                	sd	s1,8(sp)
    80004a2a:	e04a                	sd	s2,0(sp)
    80004a2c:	1000                	addi	s0,sp,32
    80004a2e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004a30:	0001c517          	auipc	a0,0x1c
    80004a34:	7c850513          	addi	a0,a0,1992 # 800211f8 <itable>
    80004a38:	ffffc097          	auipc	ra,0xffffc
    80004a3c:	196080e7          	jalr	406(ra) # 80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004a40:	4498                	lw	a4,8(s1)
    80004a42:	4785                	li	a5,1
    80004a44:	02f70363          	beq	a4,a5,80004a6a <iput+0x48>
  ip->ref--;
    80004a48:	449c                	lw	a5,8(s1)
    80004a4a:	37fd                	addiw	a5,a5,-1
    80004a4c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004a4e:	0001c517          	auipc	a0,0x1c
    80004a52:	7aa50513          	addi	a0,a0,1962 # 800211f8 <itable>
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	22c080e7          	jalr	556(ra) # 80000c82 <release>
}
    80004a5e:	60e2                	ld	ra,24(sp)
    80004a60:	6442                	ld	s0,16(sp)
    80004a62:	64a2                	ld	s1,8(sp)
    80004a64:	6902                	ld	s2,0(sp)
    80004a66:	6105                	addi	sp,sp,32
    80004a68:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004a6a:	40bc                	lw	a5,64(s1)
    80004a6c:	dff1                	beqz	a5,80004a48 <iput+0x26>
    80004a6e:	04a49783          	lh	a5,74(s1)
    80004a72:	fbf9                	bnez	a5,80004a48 <iput+0x26>
    acquiresleep(&ip->lock);
    80004a74:	01048913          	addi	s2,s1,16
    80004a78:	854a                	mv	a0,s2
    80004a7a:	00001097          	auipc	ra,0x1
    80004a7e:	abe080e7          	jalr	-1346(ra) # 80005538 <acquiresleep>
    release(&itable.lock);
    80004a82:	0001c517          	auipc	a0,0x1c
    80004a86:	77650513          	addi	a0,a0,1910 # 800211f8 <itable>
    80004a8a:	ffffc097          	auipc	ra,0xffffc
    80004a8e:	1f8080e7          	jalr	504(ra) # 80000c82 <release>
    itrunc(ip);
    80004a92:	8526                	mv	a0,s1
    80004a94:	00000097          	auipc	ra,0x0
    80004a98:	ee2080e7          	jalr	-286(ra) # 80004976 <itrunc>
    ip->type = 0;
    80004a9c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	00000097          	auipc	ra,0x0
    80004aa6:	cfa080e7          	jalr	-774(ra) # 8000479c <iupdate>
    ip->valid = 0;
    80004aaa:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004aae:	854a                	mv	a0,s2
    80004ab0:	00001097          	auipc	ra,0x1
    80004ab4:	ade080e7          	jalr	-1314(ra) # 8000558e <releasesleep>
    acquire(&itable.lock);
    80004ab8:	0001c517          	auipc	a0,0x1c
    80004abc:	74050513          	addi	a0,a0,1856 # 800211f8 <itable>
    80004ac0:	ffffc097          	auipc	ra,0xffffc
    80004ac4:	10e080e7          	jalr	270(ra) # 80000bce <acquire>
    80004ac8:	b741                	j	80004a48 <iput+0x26>

0000000080004aca <iunlockput>:
{
    80004aca:	1101                	addi	sp,sp,-32
    80004acc:	ec06                	sd	ra,24(sp)
    80004ace:	e822                	sd	s0,16(sp)
    80004ad0:	e426                	sd	s1,8(sp)
    80004ad2:	1000                	addi	s0,sp,32
    80004ad4:	84aa                	mv	s1,a0
  iunlock(ip);
    80004ad6:	00000097          	auipc	ra,0x0
    80004ada:	e54080e7          	jalr	-428(ra) # 8000492a <iunlock>
  iput(ip);
    80004ade:	8526                	mv	a0,s1
    80004ae0:	00000097          	auipc	ra,0x0
    80004ae4:	f42080e7          	jalr	-190(ra) # 80004a22 <iput>
}
    80004ae8:	60e2                	ld	ra,24(sp)
    80004aea:	6442                	ld	s0,16(sp)
    80004aec:	64a2                	ld	s1,8(sp)
    80004aee:	6105                	addi	sp,sp,32
    80004af0:	8082                	ret

0000000080004af2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004af2:	1141                	addi	sp,sp,-16
    80004af4:	e422                	sd	s0,8(sp)
    80004af6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004af8:	411c                	lw	a5,0(a0)
    80004afa:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004afc:	415c                	lw	a5,4(a0)
    80004afe:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004b00:	04451783          	lh	a5,68(a0)
    80004b04:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004b08:	04a51783          	lh	a5,74(a0)
    80004b0c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004b10:	04c56783          	lwu	a5,76(a0)
    80004b14:	e99c                	sd	a5,16(a1)
}
    80004b16:	6422                	ld	s0,8(sp)
    80004b18:	0141                	addi	sp,sp,16
    80004b1a:	8082                	ret

0000000080004b1c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004b1c:	457c                	lw	a5,76(a0)
    80004b1e:	0ed7e963          	bltu	a5,a3,80004c10 <readi+0xf4>
{
    80004b22:	7159                	addi	sp,sp,-112
    80004b24:	f486                	sd	ra,104(sp)
    80004b26:	f0a2                	sd	s0,96(sp)
    80004b28:	eca6                	sd	s1,88(sp)
    80004b2a:	e8ca                	sd	s2,80(sp)
    80004b2c:	e4ce                	sd	s3,72(sp)
    80004b2e:	e0d2                	sd	s4,64(sp)
    80004b30:	fc56                	sd	s5,56(sp)
    80004b32:	f85a                	sd	s6,48(sp)
    80004b34:	f45e                	sd	s7,40(sp)
    80004b36:	f062                	sd	s8,32(sp)
    80004b38:	ec66                	sd	s9,24(sp)
    80004b3a:	e86a                	sd	s10,16(sp)
    80004b3c:	e46e                	sd	s11,8(sp)
    80004b3e:	1880                	addi	s0,sp,112
    80004b40:	8baa                	mv	s7,a0
    80004b42:	8c2e                	mv	s8,a1
    80004b44:	8ab2                	mv	s5,a2
    80004b46:	84b6                	mv	s1,a3
    80004b48:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004b4a:	9f35                	addw	a4,a4,a3
    return 0;
    80004b4c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004b4e:	0ad76063          	bltu	a4,a3,80004bee <readi+0xd2>
  if(off + n > ip->size)
    80004b52:	00e7f463          	bgeu	a5,a4,80004b5a <readi+0x3e>
    n = ip->size - off;
    80004b56:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b5a:	0a0b0963          	beqz	s6,80004c0c <readi+0xf0>
    80004b5e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b60:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004b64:	5cfd                	li	s9,-1
    80004b66:	a82d                	j	80004ba0 <readi+0x84>
    80004b68:	020a1d93          	slli	s11,s4,0x20
    80004b6c:	020ddd93          	srli	s11,s11,0x20
    80004b70:	05890613          	addi	a2,s2,88
    80004b74:	86ee                	mv	a3,s11
    80004b76:	963a                	add	a2,a2,a4
    80004b78:	85d6                	mv	a1,s5
    80004b7a:	8562                	mv	a0,s8
    80004b7c:	ffffe097          	auipc	ra,0xffffe
    80004b80:	5d0080e7          	jalr	1488(ra) # 8000314c <either_copyout>
    80004b84:	05950d63          	beq	a0,s9,80004bde <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004b88:	854a                	mv	a0,s2
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	60c080e7          	jalr	1548(ra) # 80004196 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b92:	013a09bb          	addw	s3,s4,s3
    80004b96:	009a04bb          	addw	s1,s4,s1
    80004b9a:	9aee                	add	s5,s5,s11
    80004b9c:	0569f763          	bgeu	s3,s6,80004bea <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004ba0:	000ba903          	lw	s2,0(s7)
    80004ba4:	00a4d59b          	srliw	a1,s1,0xa
    80004ba8:	855e                	mv	a0,s7
    80004baa:	00000097          	auipc	ra,0x0
    80004bae:	8ac080e7          	jalr	-1876(ra) # 80004456 <bmap>
    80004bb2:	0005059b          	sext.w	a1,a0
    80004bb6:	854a                	mv	a0,s2
    80004bb8:	fffff097          	auipc	ra,0xfffff
    80004bbc:	4ae080e7          	jalr	1198(ra) # 80004066 <bread>
    80004bc0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004bc2:	3ff4f713          	andi	a4,s1,1023
    80004bc6:	40ed07bb          	subw	a5,s10,a4
    80004bca:	413b06bb          	subw	a3,s6,s3
    80004bce:	8a3e                	mv	s4,a5
    80004bd0:	2781                	sext.w	a5,a5
    80004bd2:	0006861b          	sext.w	a2,a3
    80004bd6:	f8f679e3          	bgeu	a2,a5,80004b68 <readi+0x4c>
    80004bda:	8a36                	mv	s4,a3
    80004bdc:	b771                	j	80004b68 <readi+0x4c>
      brelse(bp);
    80004bde:	854a                	mv	a0,s2
    80004be0:	fffff097          	auipc	ra,0xfffff
    80004be4:	5b6080e7          	jalr	1462(ra) # 80004196 <brelse>
      tot = -1;
    80004be8:	59fd                	li	s3,-1
  }
  return tot;
    80004bea:	0009851b          	sext.w	a0,s3
}
    80004bee:	70a6                	ld	ra,104(sp)
    80004bf0:	7406                	ld	s0,96(sp)
    80004bf2:	64e6                	ld	s1,88(sp)
    80004bf4:	6946                	ld	s2,80(sp)
    80004bf6:	69a6                	ld	s3,72(sp)
    80004bf8:	6a06                	ld	s4,64(sp)
    80004bfa:	7ae2                	ld	s5,56(sp)
    80004bfc:	7b42                	ld	s6,48(sp)
    80004bfe:	7ba2                	ld	s7,40(sp)
    80004c00:	7c02                	ld	s8,32(sp)
    80004c02:	6ce2                	ld	s9,24(sp)
    80004c04:	6d42                	ld	s10,16(sp)
    80004c06:	6da2                	ld	s11,8(sp)
    80004c08:	6165                	addi	sp,sp,112
    80004c0a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004c0c:	89da                	mv	s3,s6
    80004c0e:	bff1                	j	80004bea <readi+0xce>
    return 0;
    80004c10:	4501                	li	a0,0
}
    80004c12:	8082                	ret

0000000080004c14 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004c14:	457c                	lw	a5,76(a0)
    80004c16:	10d7e863          	bltu	a5,a3,80004d26 <writei+0x112>
{
    80004c1a:	7159                	addi	sp,sp,-112
    80004c1c:	f486                	sd	ra,104(sp)
    80004c1e:	f0a2                	sd	s0,96(sp)
    80004c20:	eca6                	sd	s1,88(sp)
    80004c22:	e8ca                	sd	s2,80(sp)
    80004c24:	e4ce                	sd	s3,72(sp)
    80004c26:	e0d2                	sd	s4,64(sp)
    80004c28:	fc56                	sd	s5,56(sp)
    80004c2a:	f85a                	sd	s6,48(sp)
    80004c2c:	f45e                	sd	s7,40(sp)
    80004c2e:	f062                	sd	s8,32(sp)
    80004c30:	ec66                	sd	s9,24(sp)
    80004c32:	e86a                	sd	s10,16(sp)
    80004c34:	e46e                	sd	s11,8(sp)
    80004c36:	1880                	addi	s0,sp,112
    80004c38:	8b2a                	mv	s6,a0
    80004c3a:	8c2e                	mv	s8,a1
    80004c3c:	8ab2                	mv	s5,a2
    80004c3e:	8936                	mv	s2,a3
    80004c40:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004c42:	00e687bb          	addw	a5,a3,a4
    80004c46:	0ed7e263          	bltu	a5,a3,80004d2a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004c4a:	00043737          	lui	a4,0x43
    80004c4e:	0ef76063          	bltu	a4,a5,80004d2e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c52:	0c0b8863          	beqz	s7,80004d22 <writei+0x10e>
    80004c56:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c58:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004c5c:	5cfd                	li	s9,-1
    80004c5e:	a091                	j	80004ca2 <writei+0x8e>
    80004c60:	02099d93          	slli	s11,s3,0x20
    80004c64:	020ddd93          	srli	s11,s11,0x20
    80004c68:	05848513          	addi	a0,s1,88
    80004c6c:	86ee                	mv	a3,s11
    80004c6e:	8656                	mv	a2,s5
    80004c70:	85e2                	mv	a1,s8
    80004c72:	953a                	add	a0,a0,a4
    80004c74:	ffffe097          	auipc	ra,0xffffe
    80004c78:	52e080e7          	jalr	1326(ra) # 800031a2 <either_copyin>
    80004c7c:	07950263          	beq	a0,s9,80004ce0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004c80:	8526                	mv	a0,s1
    80004c82:	00000097          	auipc	ra,0x0
    80004c86:	798080e7          	jalr	1944(ra) # 8000541a <log_write>
    brelse(bp);
    80004c8a:	8526                	mv	a0,s1
    80004c8c:	fffff097          	auipc	ra,0xfffff
    80004c90:	50a080e7          	jalr	1290(ra) # 80004196 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c94:	01498a3b          	addw	s4,s3,s4
    80004c98:	0129893b          	addw	s2,s3,s2
    80004c9c:	9aee                	add	s5,s5,s11
    80004c9e:	057a7663          	bgeu	s4,s7,80004cea <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004ca2:	000b2483          	lw	s1,0(s6)
    80004ca6:	00a9559b          	srliw	a1,s2,0xa
    80004caa:	855a                	mv	a0,s6
    80004cac:	fffff097          	auipc	ra,0xfffff
    80004cb0:	7aa080e7          	jalr	1962(ra) # 80004456 <bmap>
    80004cb4:	0005059b          	sext.w	a1,a0
    80004cb8:	8526                	mv	a0,s1
    80004cba:	fffff097          	auipc	ra,0xfffff
    80004cbe:	3ac080e7          	jalr	940(ra) # 80004066 <bread>
    80004cc2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004cc4:	3ff97713          	andi	a4,s2,1023
    80004cc8:	40ed07bb          	subw	a5,s10,a4
    80004ccc:	414b86bb          	subw	a3,s7,s4
    80004cd0:	89be                	mv	s3,a5
    80004cd2:	2781                	sext.w	a5,a5
    80004cd4:	0006861b          	sext.w	a2,a3
    80004cd8:	f8f674e3          	bgeu	a2,a5,80004c60 <writei+0x4c>
    80004cdc:	89b6                	mv	s3,a3
    80004cde:	b749                	j	80004c60 <writei+0x4c>
      brelse(bp);
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	fffff097          	auipc	ra,0xfffff
    80004ce6:	4b4080e7          	jalr	1204(ra) # 80004196 <brelse>
  }

  if(off > ip->size)
    80004cea:	04cb2783          	lw	a5,76(s6)
    80004cee:	0127f463          	bgeu	a5,s2,80004cf6 <writei+0xe2>
    ip->size = off;
    80004cf2:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004cf6:	855a                	mv	a0,s6
    80004cf8:	00000097          	auipc	ra,0x0
    80004cfc:	aa4080e7          	jalr	-1372(ra) # 8000479c <iupdate>

  return tot;
    80004d00:	000a051b          	sext.w	a0,s4
}
    80004d04:	70a6                	ld	ra,104(sp)
    80004d06:	7406                	ld	s0,96(sp)
    80004d08:	64e6                	ld	s1,88(sp)
    80004d0a:	6946                	ld	s2,80(sp)
    80004d0c:	69a6                	ld	s3,72(sp)
    80004d0e:	6a06                	ld	s4,64(sp)
    80004d10:	7ae2                	ld	s5,56(sp)
    80004d12:	7b42                	ld	s6,48(sp)
    80004d14:	7ba2                	ld	s7,40(sp)
    80004d16:	7c02                	ld	s8,32(sp)
    80004d18:	6ce2                	ld	s9,24(sp)
    80004d1a:	6d42                	ld	s10,16(sp)
    80004d1c:	6da2                	ld	s11,8(sp)
    80004d1e:	6165                	addi	sp,sp,112
    80004d20:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004d22:	8a5e                	mv	s4,s7
    80004d24:	bfc9                	j	80004cf6 <writei+0xe2>
    return -1;
    80004d26:	557d                	li	a0,-1
}
    80004d28:	8082                	ret
    return -1;
    80004d2a:	557d                	li	a0,-1
    80004d2c:	bfe1                	j	80004d04 <writei+0xf0>
    return -1;
    80004d2e:	557d                	li	a0,-1
    80004d30:	bfd1                	j	80004d04 <writei+0xf0>

0000000080004d32 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004d32:	1141                	addi	sp,sp,-16
    80004d34:	e406                	sd	ra,8(sp)
    80004d36:	e022                	sd	s0,0(sp)
    80004d38:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004d3a:	4639                	li	a2,14
    80004d3c:	ffffc097          	auipc	ra,0xffffc
    80004d40:	05e080e7          	jalr	94(ra) # 80000d9a <strncmp>
}
    80004d44:	60a2                	ld	ra,8(sp)
    80004d46:	6402                	ld	s0,0(sp)
    80004d48:	0141                	addi	sp,sp,16
    80004d4a:	8082                	ret

0000000080004d4c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004d4c:	7139                	addi	sp,sp,-64
    80004d4e:	fc06                	sd	ra,56(sp)
    80004d50:	f822                	sd	s0,48(sp)
    80004d52:	f426                	sd	s1,40(sp)
    80004d54:	f04a                	sd	s2,32(sp)
    80004d56:	ec4e                	sd	s3,24(sp)
    80004d58:	e852                	sd	s4,16(sp)
    80004d5a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004d5c:	04451703          	lh	a4,68(a0)
    80004d60:	4785                	li	a5,1
    80004d62:	00f71a63          	bne	a4,a5,80004d76 <dirlookup+0x2a>
    80004d66:	892a                	mv	s2,a0
    80004d68:	89ae                	mv	s3,a1
    80004d6a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d6c:	457c                	lw	a5,76(a0)
    80004d6e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004d70:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d72:	e79d                	bnez	a5,80004da0 <dirlookup+0x54>
    80004d74:	a8a5                	j	80004dec <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004d76:	00005517          	auipc	a0,0x5
    80004d7a:	aca50513          	addi	a0,a0,-1334 # 80009840 <syscalls+0x200>
    80004d7e:	ffffb097          	auipc	ra,0xffffb
    80004d82:	7ba080e7          	jalr	1978(ra) # 80000538 <panic>
      panic("dirlookup read");
    80004d86:	00005517          	auipc	a0,0x5
    80004d8a:	ad250513          	addi	a0,a0,-1326 # 80009858 <syscalls+0x218>
    80004d8e:	ffffb097          	auipc	ra,0xffffb
    80004d92:	7aa080e7          	jalr	1962(ra) # 80000538 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d96:	24c1                	addiw	s1,s1,16
    80004d98:	04c92783          	lw	a5,76(s2)
    80004d9c:	04f4f763          	bgeu	s1,a5,80004dea <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004da0:	4741                	li	a4,16
    80004da2:	86a6                	mv	a3,s1
    80004da4:	fc040613          	addi	a2,s0,-64
    80004da8:	4581                	li	a1,0
    80004daa:	854a                	mv	a0,s2
    80004dac:	00000097          	auipc	ra,0x0
    80004db0:	d70080e7          	jalr	-656(ra) # 80004b1c <readi>
    80004db4:	47c1                	li	a5,16
    80004db6:	fcf518e3          	bne	a0,a5,80004d86 <dirlookup+0x3a>
    if(de.inum == 0)
    80004dba:	fc045783          	lhu	a5,-64(s0)
    80004dbe:	dfe1                	beqz	a5,80004d96 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004dc0:	fc240593          	addi	a1,s0,-62
    80004dc4:	854e                	mv	a0,s3
    80004dc6:	00000097          	auipc	ra,0x0
    80004dca:	f6c080e7          	jalr	-148(ra) # 80004d32 <namecmp>
    80004dce:	f561                	bnez	a0,80004d96 <dirlookup+0x4a>
      if(poff)
    80004dd0:	000a0463          	beqz	s4,80004dd8 <dirlookup+0x8c>
        *poff = off;
    80004dd4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004dd8:	fc045583          	lhu	a1,-64(s0)
    80004ddc:	00092503          	lw	a0,0(s2)
    80004de0:	fffff097          	auipc	ra,0xfffff
    80004de4:	752080e7          	jalr	1874(ra) # 80004532 <iget>
    80004de8:	a011                	j	80004dec <dirlookup+0xa0>
  return 0;
    80004dea:	4501                	li	a0,0
}
    80004dec:	70e2                	ld	ra,56(sp)
    80004dee:	7442                	ld	s0,48(sp)
    80004df0:	74a2                	ld	s1,40(sp)
    80004df2:	7902                	ld	s2,32(sp)
    80004df4:	69e2                	ld	s3,24(sp)
    80004df6:	6a42                	ld	s4,16(sp)
    80004df8:	6121                	addi	sp,sp,64
    80004dfa:	8082                	ret

0000000080004dfc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004dfc:	711d                	addi	sp,sp,-96
    80004dfe:	ec86                	sd	ra,88(sp)
    80004e00:	e8a2                	sd	s0,80(sp)
    80004e02:	e4a6                	sd	s1,72(sp)
    80004e04:	e0ca                	sd	s2,64(sp)
    80004e06:	fc4e                	sd	s3,56(sp)
    80004e08:	f852                	sd	s4,48(sp)
    80004e0a:	f456                	sd	s5,40(sp)
    80004e0c:	f05a                	sd	s6,32(sp)
    80004e0e:	ec5e                	sd	s7,24(sp)
    80004e10:	e862                	sd	s8,16(sp)
    80004e12:	e466                	sd	s9,8(sp)
    80004e14:	e06a                	sd	s10,0(sp)
    80004e16:	1080                	addi	s0,sp,96
    80004e18:	84aa                	mv	s1,a0
    80004e1a:	8b2e                	mv	s6,a1
    80004e1c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004e1e:	00054703          	lbu	a4,0(a0)
    80004e22:	02f00793          	li	a5,47
    80004e26:	02f70363          	beq	a4,a5,80004e4c <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004e2a:	ffffd097          	auipc	ra,0xffffd
    80004e2e:	b74080e7          	jalr	-1164(ra) # 8000199e <myproc>
    80004e32:	15853503          	ld	a0,344(a0)
    80004e36:	00000097          	auipc	ra,0x0
    80004e3a:	9f4080e7          	jalr	-1548(ra) # 8000482a <idup>
    80004e3e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004e40:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004e44:	4cb5                	li	s9,13
  len = path - s;
    80004e46:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004e48:	4c05                	li	s8,1
    80004e4a:	a87d                	j	80004f08 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004e4c:	4585                	li	a1,1
    80004e4e:	4505                	li	a0,1
    80004e50:	fffff097          	auipc	ra,0xfffff
    80004e54:	6e2080e7          	jalr	1762(ra) # 80004532 <iget>
    80004e58:	8a2a                	mv	s4,a0
    80004e5a:	b7dd                	j	80004e40 <namex+0x44>
      iunlockput(ip);
    80004e5c:	8552                	mv	a0,s4
    80004e5e:	00000097          	auipc	ra,0x0
    80004e62:	c6c080e7          	jalr	-916(ra) # 80004aca <iunlockput>
      return 0;
    80004e66:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004e68:	8552                	mv	a0,s4
    80004e6a:	60e6                	ld	ra,88(sp)
    80004e6c:	6446                	ld	s0,80(sp)
    80004e6e:	64a6                	ld	s1,72(sp)
    80004e70:	6906                	ld	s2,64(sp)
    80004e72:	79e2                	ld	s3,56(sp)
    80004e74:	7a42                	ld	s4,48(sp)
    80004e76:	7aa2                	ld	s5,40(sp)
    80004e78:	7b02                	ld	s6,32(sp)
    80004e7a:	6be2                	ld	s7,24(sp)
    80004e7c:	6c42                	ld	s8,16(sp)
    80004e7e:	6ca2                	ld	s9,8(sp)
    80004e80:	6d02                	ld	s10,0(sp)
    80004e82:	6125                	addi	sp,sp,96
    80004e84:	8082                	ret
      iunlock(ip);
    80004e86:	8552                	mv	a0,s4
    80004e88:	00000097          	auipc	ra,0x0
    80004e8c:	aa2080e7          	jalr	-1374(ra) # 8000492a <iunlock>
      return ip;
    80004e90:	bfe1                	j	80004e68 <namex+0x6c>
      iunlockput(ip);
    80004e92:	8552                	mv	a0,s4
    80004e94:	00000097          	auipc	ra,0x0
    80004e98:	c36080e7          	jalr	-970(ra) # 80004aca <iunlockput>
      return 0;
    80004e9c:	8a4e                	mv	s4,s3
    80004e9e:	b7e9                	j	80004e68 <namex+0x6c>
  len = path - s;
    80004ea0:	40998633          	sub	a2,s3,s1
    80004ea4:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004ea8:	09acd863          	bge	s9,s10,80004f38 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004eac:	4639                	li	a2,14
    80004eae:	85a6                	mv	a1,s1
    80004eb0:	8556                	mv	a0,s5
    80004eb2:	ffffc097          	auipc	ra,0xffffc
    80004eb6:	e74080e7          	jalr	-396(ra) # 80000d26 <memmove>
    80004eba:	84ce                	mv	s1,s3
  while(*path == '/')
    80004ebc:	0004c783          	lbu	a5,0(s1)
    80004ec0:	01279763          	bne	a5,s2,80004ece <namex+0xd2>
    path++;
    80004ec4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004ec6:	0004c783          	lbu	a5,0(s1)
    80004eca:	ff278de3          	beq	a5,s2,80004ec4 <namex+0xc8>
    ilock(ip);
    80004ece:	8552                	mv	a0,s4
    80004ed0:	00000097          	auipc	ra,0x0
    80004ed4:	998080e7          	jalr	-1640(ra) # 80004868 <ilock>
    if(ip->type != T_DIR){
    80004ed8:	044a1783          	lh	a5,68(s4)
    80004edc:	f98790e3          	bne	a5,s8,80004e5c <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004ee0:	000b0563          	beqz	s6,80004eea <namex+0xee>
    80004ee4:	0004c783          	lbu	a5,0(s1)
    80004ee8:	dfd9                	beqz	a5,80004e86 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004eea:	865e                	mv	a2,s7
    80004eec:	85d6                	mv	a1,s5
    80004eee:	8552                	mv	a0,s4
    80004ef0:	00000097          	auipc	ra,0x0
    80004ef4:	e5c080e7          	jalr	-420(ra) # 80004d4c <dirlookup>
    80004ef8:	89aa                	mv	s3,a0
    80004efa:	dd41                	beqz	a0,80004e92 <namex+0x96>
    iunlockput(ip);
    80004efc:	8552                	mv	a0,s4
    80004efe:	00000097          	auipc	ra,0x0
    80004f02:	bcc080e7          	jalr	-1076(ra) # 80004aca <iunlockput>
    ip = next;
    80004f06:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004f08:	0004c783          	lbu	a5,0(s1)
    80004f0c:	01279763          	bne	a5,s2,80004f1a <namex+0x11e>
    path++;
    80004f10:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004f12:	0004c783          	lbu	a5,0(s1)
    80004f16:	ff278de3          	beq	a5,s2,80004f10 <namex+0x114>
  if(*path == 0)
    80004f1a:	cb9d                	beqz	a5,80004f50 <namex+0x154>
  while(*path != '/' && *path != 0)
    80004f1c:	0004c783          	lbu	a5,0(s1)
    80004f20:	89a6                	mv	s3,s1
  len = path - s;
    80004f22:	8d5e                	mv	s10,s7
    80004f24:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004f26:	01278963          	beq	a5,s2,80004f38 <namex+0x13c>
    80004f2a:	dbbd                	beqz	a5,80004ea0 <namex+0xa4>
    path++;
    80004f2c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004f2e:	0009c783          	lbu	a5,0(s3)
    80004f32:	ff279ce3          	bne	a5,s2,80004f2a <namex+0x12e>
    80004f36:	b7ad                	j	80004ea0 <namex+0xa4>
    memmove(name, s, len);
    80004f38:	2601                	sext.w	a2,a2
    80004f3a:	85a6                	mv	a1,s1
    80004f3c:	8556                	mv	a0,s5
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	de8080e7          	jalr	-536(ra) # 80000d26 <memmove>
    name[len] = 0;
    80004f46:	9d56                	add	s10,s10,s5
    80004f48:	000d0023          	sb	zero,0(s10)
    80004f4c:	84ce                	mv	s1,s3
    80004f4e:	b7bd                	j	80004ebc <namex+0xc0>
  if(nameiparent){
    80004f50:	f00b0ce3          	beqz	s6,80004e68 <namex+0x6c>
    iput(ip);
    80004f54:	8552                	mv	a0,s4
    80004f56:	00000097          	auipc	ra,0x0
    80004f5a:	acc080e7          	jalr	-1332(ra) # 80004a22 <iput>
    return 0;
    80004f5e:	4a01                	li	s4,0
    80004f60:	b721                	j	80004e68 <namex+0x6c>

0000000080004f62 <dirlink>:
{
    80004f62:	7139                	addi	sp,sp,-64
    80004f64:	fc06                	sd	ra,56(sp)
    80004f66:	f822                	sd	s0,48(sp)
    80004f68:	f426                	sd	s1,40(sp)
    80004f6a:	f04a                	sd	s2,32(sp)
    80004f6c:	ec4e                	sd	s3,24(sp)
    80004f6e:	e852                	sd	s4,16(sp)
    80004f70:	0080                	addi	s0,sp,64
    80004f72:	892a                	mv	s2,a0
    80004f74:	8a2e                	mv	s4,a1
    80004f76:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f78:	4601                	li	a2,0
    80004f7a:	00000097          	auipc	ra,0x0
    80004f7e:	dd2080e7          	jalr	-558(ra) # 80004d4c <dirlookup>
    80004f82:	e93d                	bnez	a0,80004ff8 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004f84:	04c92483          	lw	s1,76(s2)
    80004f88:	c49d                	beqz	s1,80004fb6 <dirlink+0x54>
    80004f8a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f8c:	4741                	li	a4,16
    80004f8e:	86a6                	mv	a3,s1
    80004f90:	fc040613          	addi	a2,s0,-64
    80004f94:	4581                	li	a1,0
    80004f96:	854a                	mv	a0,s2
    80004f98:	00000097          	auipc	ra,0x0
    80004f9c:	b84080e7          	jalr	-1148(ra) # 80004b1c <readi>
    80004fa0:	47c1                	li	a5,16
    80004fa2:	06f51163          	bne	a0,a5,80005004 <dirlink+0xa2>
    if(de.inum == 0)
    80004fa6:	fc045783          	lhu	a5,-64(s0)
    80004faa:	c791                	beqz	a5,80004fb6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004fac:	24c1                	addiw	s1,s1,16
    80004fae:	04c92783          	lw	a5,76(s2)
    80004fb2:	fcf4ede3          	bltu	s1,a5,80004f8c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004fb6:	4639                	li	a2,14
    80004fb8:	85d2                	mv	a1,s4
    80004fba:	fc240513          	addi	a0,s0,-62
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	e18080e7          	jalr	-488(ra) # 80000dd6 <strncpy>
  de.inum = inum;
    80004fc6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fca:	4741                	li	a4,16
    80004fcc:	86a6                	mv	a3,s1
    80004fce:	fc040613          	addi	a2,s0,-64
    80004fd2:	4581                	li	a1,0
    80004fd4:	854a                	mv	a0,s2
    80004fd6:	00000097          	auipc	ra,0x0
    80004fda:	c3e080e7          	jalr	-962(ra) # 80004c14 <writei>
    80004fde:	872a                	mv	a4,a0
    80004fe0:	47c1                	li	a5,16
  return 0;
    80004fe2:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fe4:	02f71863          	bne	a4,a5,80005014 <dirlink+0xb2>
}
    80004fe8:	70e2                	ld	ra,56(sp)
    80004fea:	7442                	ld	s0,48(sp)
    80004fec:	74a2                	ld	s1,40(sp)
    80004fee:	7902                	ld	s2,32(sp)
    80004ff0:	69e2                	ld	s3,24(sp)
    80004ff2:	6a42                	ld	s4,16(sp)
    80004ff4:	6121                	addi	sp,sp,64
    80004ff6:	8082                	ret
    iput(ip);
    80004ff8:	00000097          	auipc	ra,0x0
    80004ffc:	a2a080e7          	jalr	-1494(ra) # 80004a22 <iput>
    return -1;
    80005000:	557d                	li	a0,-1
    80005002:	b7dd                	j	80004fe8 <dirlink+0x86>
      panic("dirlink read");
    80005004:	00005517          	auipc	a0,0x5
    80005008:	86450513          	addi	a0,a0,-1948 # 80009868 <syscalls+0x228>
    8000500c:	ffffb097          	auipc	ra,0xffffb
    80005010:	52c080e7          	jalr	1324(ra) # 80000538 <panic>
    panic("dirlink");
    80005014:	00005517          	auipc	a0,0x5
    80005018:	96450513          	addi	a0,a0,-1692 # 80009978 <syscalls+0x338>
    8000501c:	ffffb097          	auipc	ra,0xffffb
    80005020:	51c080e7          	jalr	1308(ra) # 80000538 <panic>

0000000080005024 <namei>:

struct inode*
namei(char *path)
{
    80005024:	1101                	addi	sp,sp,-32
    80005026:	ec06                	sd	ra,24(sp)
    80005028:	e822                	sd	s0,16(sp)
    8000502a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000502c:	fe040613          	addi	a2,s0,-32
    80005030:	4581                	li	a1,0
    80005032:	00000097          	auipc	ra,0x0
    80005036:	dca080e7          	jalr	-566(ra) # 80004dfc <namex>
}
    8000503a:	60e2                	ld	ra,24(sp)
    8000503c:	6442                	ld	s0,16(sp)
    8000503e:	6105                	addi	sp,sp,32
    80005040:	8082                	ret

0000000080005042 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80005042:	1141                	addi	sp,sp,-16
    80005044:	e406                	sd	ra,8(sp)
    80005046:	e022                	sd	s0,0(sp)
    80005048:	0800                	addi	s0,sp,16
    8000504a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000504c:	4585                	li	a1,1
    8000504e:	00000097          	auipc	ra,0x0
    80005052:	dae080e7          	jalr	-594(ra) # 80004dfc <namex>
}
    80005056:	60a2                	ld	ra,8(sp)
    80005058:	6402                	ld	s0,0(sp)
    8000505a:	0141                	addi	sp,sp,16
    8000505c:	8082                	ret

000000008000505e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000505e:	1101                	addi	sp,sp,-32
    80005060:	ec06                	sd	ra,24(sp)
    80005062:	e822                	sd	s0,16(sp)
    80005064:	e426                	sd	s1,8(sp)
    80005066:	e04a                	sd	s2,0(sp)
    80005068:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000506a:	0001e917          	auipc	s2,0x1e
    8000506e:	c3690913          	addi	s2,s2,-970 # 80022ca0 <log>
    80005072:	01892583          	lw	a1,24(s2)
    80005076:	02892503          	lw	a0,40(s2)
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	fec080e7          	jalr	-20(ra) # 80004066 <bread>
    80005082:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005084:	02c92683          	lw	a3,44(s2)
    80005088:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000508a:	02d05863          	blez	a3,800050ba <write_head+0x5c>
    8000508e:	0001e797          	auipc	a5,0x1e
    80005092:	c4278793          	addi	a5,a5,-958 # 80022cd0 <log+0x30>
    80005096:	05c50713          	addi	a4,a0,92
    8000509a:	36fd                	addiw	a3,a3,-1
    8000509c:	02069613          	slli	a2,a3,0x20
    800050a0:	01e65693          	srli	a3,a2,0x1e
    800050a4:	0001e617          	auipc	a2,0x1e
    800050a8:	c3060613          	addi	a2,a2,-976 # 80022cd4 <log+0x34>
    800050ac:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800050ae:	4390                	lw	a2,0(a5)
    800050b0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800050b2:	0791                	addi	a5,a5,4
    800050b4:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800050b6:	fed79ce3          	bne	a5,a3,800050ae <write_head+0x50>
  }
  bwrite(buf);
    800050ba:	8526                	mv	a0,s1
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	09c080e7          	jalr	156(ra) # 80004158 <bwrite>
  brelse(buf);
    800050c4:	8526                	mv	a0,s1
    800050c6:	fffff097          	auipc	ra,0xfffff
    800050ca:	0d0080e7          	jalr	208(ra) # 80004196 <brelse>
}
    800050ce:	60e2                	ld	ra,24(sp)
    800050d0:	6442                	ld	s0,16(sp)
    800050d2:	64a2                	ld	s1,8(sp)
    800050d4:	6902                	ld	s2,0(sp)
    800050d6:	6105                	addi	sp,sp,32
    800050d8:	8082                	ret

00000000800050da <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800050da:	0001e797          	auipc	a5,0x1e
    800050de:	bf27a783          	lw	a5,-1038(a5) # 80022ccc <log+0x2c>
    800050e2:	0af05d63          	blez	a5,8000519c <install_trans+0xc2>
{
    800050e6:	7139                	addi	sp,sp,-64
    800050e8:	fc06                	sd	ra,56(sp)
    800050ea:	f822                	sd	s0,48(sp)
    800050ec:	f426                	sd	s1,40(sp)
    800050ee:	f04a                	sd	s2,32(sp)
    800050f0:	ec4e                	sd	s3,24(sp)
    800050f2:	e852                	sd	s4,16(sp)
    800050f4:	e456                	sd	s5,8(sp)
    800050f6:	e05a                	sd	s6,0(sp)
    800050f8:	0080                	addi	s0,sp,64
    800050fa:	8b2a                	mv	s6,a0
    800050fc:	0001ea97          	auipc	s5,0x1e
    80005100:	bd4a8a93          	addi	s5,s5,-1068 # 80022cd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005104:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005106:	0001e997          	auipc	s3,0x1e
    8000510a:	b9a98993          	addi	s3,s3,-1126 # 80022ca0 <log>
    8000510e:	a00d                	j	80005130 <install_trans+0x56>
    brelse(lbuf);
    80005110:	854a                	mv	a0,s2
    80005112:	fffff097          	auipc	ra,0xfffff
    80005116:	084080e7          	jalr	132(ra) # 80004196 <brelse>
    brelse(dbuf);
    8000511a:	8526                	mv	a0,s1
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	07a080e7          	jalr	122(ra) # 80004196 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005124:	2a05                	addiw	s4,s4,1
    80005126:	0a91                	addi	s5,s5,4
    80005128:	02c9a783          	lw	a5,44(s3)
    8000512c:	04fa5e63          	bge	s4,a5,80005188 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005130:	0189a583          	lw	a1,24(s3)
    80005134:	014585bb          	addw	a1,a1,s4
    80005138:	2585                	addiw	a1,a1,1
    8000513a:	0289a503          	lw	a0,40(s3)
    8000513e:	fffff097          	auipc	ra,0xfffff
    80005142:	f28080e7          	jalr	-216(ra) # 80004066 <bread>
    80005146:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80005148:	000aa583          	lw	a1,0(s5)
    8000514c:	0289a503          	lw	a0,40(s3)
    80005150:	fffff097          	auipc	ra,0xfffff
    80005154:	f16080e7          	jalr	-234(ra) # 80004066 <bread>
    80005158:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000515a:	40000613          	li	a2,1024
    8000515e:	05890593          	addi	a1,s2,88
    80005162:	05850513          	addi	a0,a0,88
    80005166:	ffffc097          	auipc	ra,0xffffc
    8000516a:	bc0080e7          	jalr	-1088(ra) # 80000d26 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000516e:	8526                	mv	a0,s1
    80005170:	fffff097          	auipc	ra,0xfffff
    80005174:	fe8080e7          	jalr	-24(ra) # 80004158 <bwrite>
    if(recovering == 0)
    80005178:	f80b1ce3          	bnez	s6,80005110 <install_trans+0x36>
      bunpin(dbuf);
    8000517c:	8526                	mv	a0,s1
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	0f2080e7          	jalr	242(ra) # 80004270 <bunpin>
    80005186:	b769                	j	80005110 <install_trans+0x36>
}
    80005188:	70e2                	ld	ra,56(sp)
    8000518a:	7442                	ld	s0,48(sp)
    8000518c:	74a2                	ld	s1,40(sp)
    8000518e:	7902                	ld	s2,32(sp)
    80005190:	69e2                	ld	s3,24(sp)
    80005192:	6a42                	ld	s4,16(sp)
    80005194:	6aa2                	ld	s5,8(sp)
    80005196:	6b02                	ld	s6,0(sp)
    80005198:	6121                	addi	sp,sp,64
    8000519a:	8082                	ret
    8000519c:	8082                	ret

000000008000519e <initlog>:
{
    8000519e:	7179                	addi	sp,sp,-48
    800051a0:	f406                	sd	ra,40(sp)
    800051a2:	f022                	sd	s0,32(sp)
    800051a4:	ec26                	sd	s1,24(sp)
    800051a6:	e84a                	sd	s2,16(sp)
    800051a8:	e44e                	sd	s3,8(sp)
    800051aa:	1800                	addi	s0,sp,48
    800051ac:	892a                	mv	s2,a0
    800051ae:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800051b0:	0001e497          	auipc	s1,0x1e
    800051b4:	af048493          	addi	s1,s1,-1296 # 80022ca0 <log>
    800051b8:	00004597          	auipc	a1,0x4
    800051bc:	6c058593          	addi	a1,a1,1728 # 80009878 <syscalls+0x238>
    800051c0:	8526                	mv	a0,s1
    800051c2:	ffffc097          	auipc	ra,0xffffc
    800051c6:	97c080e7          	jalr	-1668(ra) # 80000b3e <initlock>
  log.start = sb->logstart;
    800051ca:	0149a583          	lw	a1,20(s3)
    800051ce:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800051d0:	0109a783          	lw	a5,16(s3)
    800051d4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800051d6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800051da:	854a                	mv	a0,s2
    800051dc:	fffff097          	auipc	ra,0xfffff
    800051e0:	e8a080e7          	jalr	-374(ra) # 80004066 <bread>
  log.lh.n = lh->n;
    800051e4:	4d34                	lw	a3,88(a0)
    800051e6:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800051e8:	02d05663          	blez	a3,80005214 <initlog+0x76>
    800051ec:	05c50793          	addi	a5,a0,92
    800051f0:	0001e717          	auipc	a4,0x1e
    800051f4:	ae070713          	addi	a4,a4,-1312 # 80022cd0 <log+0x30>
    800051f8:	36fd                	addiw	a3,a3,-1
    800051fa:	02069613          	slli	a2,a3,0x20
    800051fe:	01e65693          	srli	a3,a2,0x1e
    80005202:	06050613          	addi	a2,a0,96
    80005206:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80005208:	4390                	lw	a2,0(a5)
    8000520a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000520c:	0791                	addi	a5,a5,4
    8000520e:	0711                	addi	a4,a4,4
    80005210:	fed79ce3          	bne	a5,a3,80005208 <initlog+0x6a>
  brelse(buf);
    80005214:	fffff097          	auipc	ra,0xfffff
    80005218:	f82080e7          	jalr	-126(ra) # 80004196 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000521c:	4505                	li	a0,1
    8000521e:	00000097          	auipc	ra,0x0
    80005222:	ebc080e7          	jalr	-324(ra) # 800050da <install_trans>
  log.lh.n = 0;
    80005226:	0001e797          	auipc	a5,0x1e
    8000522a:	aa07a323          	sw	zero,-1370(a5) # 80022ccc <log+0x2c>
  write_head(); // clear the log
    8000522e:	00000097          	auipc	ra,0x0
    80005232:	e30080e7          	jalr	-464(ra) # 8000505e <write_head>
}
    80005236:	70a2                	ld	ra,40(sp)
    80005238:	7402                	ld	s0,32(sp)
    8000523a:	64e2                	ld	s1,24(sp)
    8000523c:	6942                	ld	s2,16(sp)
    8000523e:	69a2                	ld	s3,8(sp)
    80005240:	6145                	addi	sp,sp,48
    80005242:	8082                	ret

0000000080005244 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005244:	1101                	addi	sp,sp,-32
    80005246:	ec06                	sd	ra,24(sp)
    80005248:	e822                	sd	s0,16(sp)
    8000524a:	e426                	sd	s1,8(sp)
    8000524c:	e04a                	sd	s2,0(sp)
    8000524e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005250:	0001e517          	auipc	a0,0x1e
    80005254:	a5050513          	addi	a0,a0,-1456 # 80022ca0 <log>
    80005258:	ffffc097          	auipc	ra,0xffffc
    8000525c:	976080e7          	jalr	-1674(ra) # 80000bce <acquire>
  while(1){
    if(log.committing){
    80005260:	0001e497          	auipc	s1,0x1e
    80005264:	a4048493          	addi	s1,s1,-1472 # 80022ca0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005268:	4979                	li	s2,30
    8000526a:	a039                	j	80005278 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000526c:	85a6                	mv	a1,s1
    8000526e:	8526                	mv	a0,s1
    80005270:	ffffd097          	auipc	ra,0xffffd
    80005274:	4e0080e7          	jalr	1248(ra) # 80002750 <sleep>
    if(log.committing){
    80005278:	50dc                	lw	a5,36(s1)
    8000527a:	fbed                	bnez	a5,8000526c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000527c:	5098                	lw	a4,32(s1)
    8000527e:	2705                	addiw	a4,a4,1
    80005280:	0007069b          	sext.w	a3,a4
    80005284:	0027179b          	slliw	a5,a4,0x2
    80005288:	9fb9                	addw	a5,a5,a4
    8000528a:	0017979b          	slliw	a5,a5,0x1
    8000528e:	54d8                	lw	a4,44(s1)
    80005290:	9fb9                	addw	a5,a5,a4
    80005292:	00f95963          	bge	s2,a5,800052a4 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005296:	85a6                	mv	a1,s1
    80005298:	8526                	mv	a0,s1
    8000529a:	ffffd097          	auipc	ra,0xffffd
    8000529e:	4b6080e7          	jalr	1206(ra) # 80002750 <sleep>
    800052a2:	bfd9                	j	80005278 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800052a4:	0001e517          	auipc	a0,0x1e
    800052a8:	9fc50513          	addi	a0,a0,-1540 # 80022ca0 <log>
    800052ac:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	9d4080e7          	jalr	-1580(ra) # 80000c82 <release>
      break;
    }
  }
}
    800052b6:	60e2                	ld	ra,24(sp)
    800052b8:	6442                	ld	s0,16(sp)
    800052ba:	64a2                	ld	s1,8(sp)
    800052bc:	6902                	ld	s2,0(sp)
    800052be:	6105                	addi	sp,sp,32
    800052c0:	8082                	ret

00000000800052c2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800052c2:	7139                	addi	sp,sp,-64
    800052c4:	fc06                	sd	ra,56(sp)
    800052c6:	f822                	sd	s0,48(sp)
    800052c8:	f426                	sd	s1,40(sp)
    800052ca:	f04a                	sd	s2,32(sp)
    800052cc:	ec4e                	sd	s3,24(sp)
    800052ce:	e852                	sd	s4,16(sp)
    800052d0:	e456                	sd	s5,8(sp)
    800052d2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800052d4:	0001e497          	auipc	s1,0x1e
    800052d8:	9cc48493          	addi	s1,s1,-1588 # 80022ca0 <log>
    800052dc:	8526                	mv	a0,s1
    800052de:	ffffc097          	auipc	ra,0xffffc
    800052e2:	8f0080e7          	jalr	-1808(ra) # 80000bce <acquire>
  log.outstanding -= 1;
    800052e6:	509c                	lw	a5,32(s1)
    800052e8:	37fd                	addiw	a5,a5,-1
    800052ea:	0007891b          	sext.w	s2,a5
    800052ee:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800052f0:	50dc                	lw	a5,36(s1)
    800052f2:	e7b9                	bnez	a5,80005340 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800052f4:	04091e63          	bnez	s2,80005350 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800052f8:	0001e497          	auipc	s1,0x1e
    800052fc:	9a848493          	addi	s1,s1,-1624 # 80022ca0 <log>
    80005300:	4785                	li	a5,1
    80005302:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80005304:	8526                	mv	a0,s1
    80005306:	ffffc097          	auipc	ra,0xffffc
    8000530a:	97c080e7          	jalr	-1668(ra) # 80000c82 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000530e:	54dc                	lw	a5,44(s1)
    80005310:	06f04763          	bgtz	a5,8000537e <end_op+0xbc>
    acquire(&log.lock);
    80005314:	0001e497          	auipc	s1,0x1e
    80005318:	98c48493          	addi	s1,s1,-1652 # 80022ca0 <log>
    8000531c:	8526                	mv	a0,s1
    8000531e:	ffffc097          	auipc	ra,0xffffc
    80005322:	8b0080e7          	jalr	-1872(ra) # 80000bce <acquire>
    log.committing = 0;
    80005326:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000532a:	8526                	mv	a0,s1
    8000532c:	ffffe097          	auipc	ra,0xffffe
    80005330:	828080e7          	jalr	-2008(ra) # 80002b54 <wakeup>
    release(&log.lock);
    80005334:	8526                	mv	a0,s1
    80005336:	ffffc097          	auipc	ra,0xffffc
    8000533a:	94c080e7          	jalr	-1716(ra) # 80000c82 <release>
}
    8000533e:	a03d                	j	8000536c <end_op+0xaa>
    panic("log.committing");
    80005340:	00004517          	auipc	a0,0x4
    80005344:	54050513          	addi	a0,a0,1344 # 80009880 <syscalls+0x240>
    80005348:	ffffb097          	auipc	ra,0xffffb
    8000534c:	1f0080e7          	jalr	496(ra) # 80000538 <panic>
    wakeup(&log);
    80005350:	0001e497          	auipc	s1,0x1e
    80005354:	95048493          	addi	s1,s1,-1712 # 80022ca0 <log>
    80005358:	8526                	mv	a0,s1
    8000535a:	ffffd097          	auipc	ra,0xffffd
    8000535e:	7fa080e7          	jalr	2042(ra) # 80002b54 <wakeup>
  release(&log.lock);
    80005362:	8526                	mv	a0,s1
    80005364:	ffffc097          	auipc	ra,0xffffc
    80005368:	91e080e7          	jalr	-1762(ra) # 80000c82 <release>
}
    8000536c:	70e2                	ld	ra,56(sp)
    8000536e:	7442                	ld	s0,48(sp)
    80005370:	74a2                	ld	s1,40(sp)
    80005372:	7902                	ld	s2,32(sp)
    80005374:	69e2                	ld	s3,24(sp)
    80005376:	6a42                	ld	s4,16(sp)
    80005378:	6aa2                	ld	s5,8(sp)
    8000537a:	6121                	addi	sp,sp,64
    8000537c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000537e:	0001ea97          	auipc	s5,0x1e
    80005382:	952a8a93          	addi	s5,s5,-1710 # 80022cd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005386:	0001ea17          	auipc	s4,0x1e
    8000538a:	91aa0a13          	addi	s4,s4,-1766 # 80022ca0 <log>
    8000538e:	018a2583          	lw	a1,24(s4)
    80005392:	012585bb          	addw	a1,a1,s2
    80005396:	2585                	addiw	a1,a1,1
    80005398:	028a2503          	lw	a0,40(s4)
    8000539c:	fffff097          	auipc	ra,0xfffff
    800053a0:	cca080e7          	jalr	-822(ra) # 80004066 <bread>
    800053a4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800053a6:	000aa583          	lw	a1,0(s5)
    800053aa:	028a2503          	lw	a0,40(s4)
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	cb8080e7          	jalr	-840(ra) # 80004066 <bread>
    800053b6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800053b8:	40000613          	li	a2,1024
    800053bc:	05850593          	addi	a1,a0,88
    800053c0:	05848513          	addi	a0,s1,88
    800053c4:	ffffc097          	auipc	ra,0xffffc
    800053c8:	962080e7          	jalr	-1694(ra) # 80000d26 <memmove>
    bwrite(to);  // write the log
    800053cc:	8526                	mv	a0,s1
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	d8a080e7          	jalr	-630(ra) # 80004158 <bwrite>
    brelse(from);
    800053d6:	854e                	mv	a0,s3
    800053d8:	fffff097          	auipc	ra,0xfffff
    800053dc:	dbe080e7          	jalr	-578(ra) # 80004196 <brelse>
    brelse(to);
    800053e0:	8526                	mv	a0,s1
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	db4080e7          	jalr	-588(ra) # 80004196 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800053ea:	2905                	addiw	s2,s2,1
    800053ec:	0a91                	addi	s5,s5,4
    800053ee:	02ca2783          	lw	a5,44(s4)
    800053f2:	f8f94ee3          	blt	s2,a5,8000538e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800053f6:	00000097          	auipc	ra,0x0
    800053fa:	c68080e7          	jalr	-920(ra) # 8000505e <write_head>
    install_trans(0); // Now install writes to home locations
    800053fe:	4501                	li	a0,0
    80005400:	00000097          	auipc	ra,0x0
    80005404:	cda080e7          	jalr	-806(ra) # 800050da <install_trans>
    log.lh.n = 0;
    80005408:	0001e797          	auipc	a5,0x1e
    8000540c:	8c07a223          	sw	zero,-1852(a5) # 80022ccc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005410:	00000097          	auipc	ra,0x0
    80005414:	c4e080e7          	jalr	-946(ra) # 8000505e <write_head>
    80005418:	bdf5                	j	80005314 <end_op+0x52>

000000008000541a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000541a:	1101                	addi	sp,sp,-32
    8000541c:	ec06                	sd	ra,24(sp)
    8000541e:	e822                	sd	s0,16(sp)
    80005420:	e426                	sd	s1,8(sp)
    80005422:	e04a                	sd	s2,0(sp)
    80005424:	1000                	addi	s0,sp,32
    80005426:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80005428:	0001e917          	auipc	s2,0x1e
    8000542c:	87890913          	addi	s2,s2,-1928 # 80022ca0 <log>
    80005430:	854a                	mv	a0,s2
    80005432:	ffffb097          	auipc	ra,0xffffb
    80005436:	79c080e7          	jalr	1948(ra) # 80000bce <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000543a:	02c92603          	lw	a2,44(s2)
    8000543e:	47f5                	li	a5,29
    80005440:	06c7c563          	blt	a5,a2,800054aa <log_write+0x90>
    80005444:	0001e797          	auipc	a5,0x1e
    80005448:	8787a783          	lw	a5,-1928(a5) # 80022cbc <log+0x1c>
    8000544c:	37fd                	addiw	a5,a5,-1
    8000544e:	04f65e63          	bge	a2,a5,800054aa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005452:	0001e797          	auipc	a5,0x1e
    80005456:	86e7a783          	lw	a5,-1938(a5) # 80022cc0 <log+0x20>
    8000545a:	06f05063          	blez	a5,800054ba <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000545e:	4781                	li	a5,0
    80005460:	06c05563          	blez	a2,800054ca <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005464:	44cc                	lw	a1,12(s1)
    80005466:	0001e717          	auipc	a4,0x1e
    8000546a:	86a70713          	addi	a4,a4,-1942 # 80022cd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000546e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005470:	4314                	lw	a3,0(a4)
    80005472:	04b68c63          	beq	a3,a1,800054ca <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005476:	2785                	addiw	a5,a5,1
    80005478:	0711                	addi	a4,a4,4
    8000547a:	fef61be3          	bne	a2,a5,80005470 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000547e:	0621                	addi	a2,a2,8
    80005480:	060a                	slli	a2,a2,0x2
    80005482:	0001e797          	auipc	a5,0x1e
    80005486:	81e78793          	addi	a5,a5,-2018 # 80022ca0 <log>
    8000548a:	97b2                	add	a5,a5,a2
    8000548c:	44d8                	lw	a4,12(s1)
    8000548e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005490:	8526                	mv	a0,s1
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	da2080e7          	jalr	-606(ra) # 80004234 <bpin>
    log.lh.n++;
    8000549a:	0001e717          	auipc	a4,0x1e
    8000549e:	80670713          	addi	a4,a4,-2042 # 80022ca0 <log>
    800054a2:	575c                	lw	a5,44(a4)
    800054a4:	2785                	addiw	a5,a5,1
    800054a6:	d75c                	sw	a5,44(a4)
    800054a8:	a82d                	j	800054e2 <log_write+0xc8>
    panic("too big a transaction");
    800054aa:	00004517          	auipc	a0,0x4
    800054ae:	3e650513          	addi	a0,a0,998 # 80009890 <syscalls+0x250>
    800054b2:	ffffb097          	auipc	ra,0xffffb
    800054b6:	086080e7          	jalr	134(ra) # 80000538 <panic>
    panic("log_write outside of trans");
    800054ba:	00004517          	auipc	a0,0x4
    800054be:	3ee50513          	addi	a0,a0,1006 # 800098a8 <syscalls+0x268>
    800054c2:	ffffb097          	auipc	ra,0xffffb
    800054c6:	076080e7          	jalr	118(ra) # 80000538 <panic>
  log.lh.block[i] = b->blockno;
    800054ca:	00878693          	addi	a3,a5,8
    800054ce:	068a                	slli	a3,a3,0x2
    800054d0:	0001d717          	auipc	a4,0x1d
    800054d4:	7d070713          	addi	a4,a4,2000 # 80022ca0 <log>
    800054d8:	9736                	add	a4,a4,a3
    800054da:	44d4                	lw	a3,12(s1)
    800054dc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800054de:	faf609e3          	beq	a2,a5,80005490 <log_write+0x76>
  }
  release(&log.lock);
    800054e2:	0001d517          	auipc	a0,0x1d
    800054e6:	7be50513          	addi	a0,a0,1982 # 80022ca0 <log>
    800054ea:	ffffb097          	auipc	ra,0xffffb
    800054ee:	798080e7          	jalr	1944(ra) # 80000c82 <release>
}
    800054f2:	60e2                	ld	ra,24(sp)
    800054f4:	6442                	ld	s0,16(sp)
    800054f6:	64a2                	ld	s1,8(sp)
    800054f8:	6902                	ld	s2,0(sp)
    800054fa:	6105                	addi	sp,sp,32
    800054fc:	8082                	ret

00000000800054fe <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800054fe:	1101                	addi	sp,sp,-32
    80005500:	ec06                	sd	ra,24(sp)
    80005502:	e822                	sd	s0,16(sp)
    80005504:	e426                	sd	s1,8(sp)
    80005506:	e04a                	sd	s2,0(sp)
    80005508:	1000                	addi	s0,sp,32
    8000550a:	84aa                	mv	s1,a0
    8000550c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000550e:	00004597          	auipc	a1,0x4
    80005512:	3ba58593          	addi	a1,a1,954 # 800098c8 <syscalls+0x288>
    80005516:	0521                	addi	a0,a0,8
    80005518:	ffffb097          	auipc	ra,0xffffb
    8000551c:	626080e7          	jalr	1574(ra) # 80000b3e <initlock>
  lk->name = name;
    80005520:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005524:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005528:	0204a423          	sw	zero,40(s1)
}
    8000552c:	60e2                	ld	ra,24(sp)
    8000552e:	6442                	ld	s0,16(sp)
    80005530:	64a2                	ld	s1,8(sp)
    80005532:	6902                	ld	s2,0(sp)
    80005534:	6105                	addi	sp,sp,32
    80005536:	8082                	ret

0000000080005538 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005538:	1101                	addi	sp,sp,-32
    8000553a:	ec06                	sd	ra,24(sp)
    8000553c:	e822                	sd	s0,16(sp)
    8000553e:	e426                	sd	s1,8(sp)
    80005540:	e04a                	sd	s2,0(sp)
    80005542:	1000                	addi	s0,sp,32
    80005544:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005546:	00850913          	addi	s2,a0,8
    8000554a:	854a                	mv	a0,s2
    8000554c:	ffffb097          	auipc	ra,0xffffb
    80005550:	682080e7          	jalr	1666(ra) # 80000bce <acquire>
  while (lk->locked) {
    80005554:	409c                	lw	a5,0(s1)
    80005556:	cb89                	beqz	a5,80005568 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005558:	85ca                	mv	a1,s2
    8000555a:	8526                	mv	a0,s1
    8000555c:	ffffd097          	auipc	ra,0xffffd
    80005560:	1f4080e7          	jalr	500(ra) # 80002750 <sleep>
  while (lk->locked) {
    80005564:	409c                	lw	a5,0(s1)
    80005566:	fbed                	bnez	a5,80005558 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005568:	4785                	li	a5,1
    8000556a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000556c:	ffffc097          	auipc	ra,0xffffc
    80005570:	432080e7          	jalr	1074(ra) # 8000199e <myproc>
    80005574:	591c                	lw	a5,48(a0)
    80005576:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005578:	854a                	mv	a0,s2
    8000557a:	ffffb097          	auipc	ra,0xffffb
    8000557e:	708080e7          	jalr	1800(ra) # 80000c82 <release>
}
    80005582:	60e2                	ld	ra,24(sp)
    80005584:	6442                	ld	s0,16(sp)
    80005586:	64a2                	ld	s1,8(sp)
    80005588:	6902                	ld	s2,0(sp)
    8000558a:	6105                	addi	sp,sp,32
    8000558c:	8082                	ret

000000008000558e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000558e:	1101                	addi	sp,sp,-32
    80005590:	ec06                	sd	ra,24(sp)
    80005592:	e822                	sd	s0,16(sp)
    80005594:	e426                	sd	s1,8(sp)
    80005596:	e04a                	sd	s2,0(sp)
    80005598:	1000                	addi	s0,sp,32
    8000559a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000559c:	00850913          	addi	s2,a0,8
    800055a0:	854a                	mv	a0,s2
    800055a2:	ffffb097          	auipc	ra,0xffffb
    800055a6:	62c080e7          	jalr	1580(ra) # 80000bce <acquire>
  lk->locked = 0;
    800055aa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800055ae:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800055b2:	8526                	mv	a0,s1
    800055b4:	ffffd097          	auipc	ra,0xffffd
    800055b8:	5a0080e7          	jalr	1440(ra) # 80002b54 <wakeup>
  release(&lk->lk);
    800055bc:	854a                	mv	a0,s2
    800055be:	ffffb097          	auipc	ra,0xffffb
    800055c2:	6c4080e7          	jalr	1732(ra) # 80000c82 <release>
}
    800055c6:	60e2                	ld	ra,24(sp)
    800055c8:	6442                	ld	s0,16(sp)
    800055ca:	64a2                	ld	s1,8(sp)
    800055cc:	6902                	ld	s2,0(sp)
    800055ce:	6105                	addi	sp,sp,32
    800055d0:	8082                	ret

00000000800055d2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800055d2:	7179                	addi	sp,sp,-48
    800055d4:	f406                	sd	ra,40(sp)
    800055d6:	f022                	sd	s0,32(sp)
    800055d8:	ec26                	sd	s1,24(sp)
    800055da:	e84a                	sd	s2,16(sp)
    800055dc:	e44e                	sd	s3,8(sp)
    800055de:	1800                	addi	s0,sp,48
    800055e0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800055e2:	00850913          	addi	s2,a0,8
    800055e6:	854a                	mv	a0,s2
    800055e8:	ffffb097          	auipc	ra,0xffffb
    800055ec:	5e6080e7          	jalr	1510(ra) # 80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800055f0:	409c                	lw	a5,0(s1)
    800055f2:	ef99                	bnez	a5,80005610 <holdingsleep+0x3e>
    800055f4:	4481                	li	s1,0
  release(&lk->lk);
    800055f6:	854a                	mv	a0,s2
    800055f8:	ffffb097          	auipc	ra,0xffffb
    800055fc:	68a080e7          	jalr	1674(ra) # 80000c82 <release>
  return r;
}
    80005600:	8526                	mv	a0,s1
    80005602:	70a2                	ld	ra,40(sp)
    80005604:	7402                	ld	s0,32(sp)
    80005606:	64e2                	ld	s1,24(sp)
    80005608:	6942                	ld	s2,16(sp)
    8000560a:	69a2                	ld	s3,8(sp)
    8000560c:	6145                	addi	sp,sp,48
    8000560e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005610:	0284a983          	lw	s3,40(s1)
    80005614:	ffffc097          	auipc	ra,0xffffc
    80005618:	38a080e7          	jalr	906(ra) # 8000199e <myproc>
    8000561c:	5904                	lw	s1,48(a0)
    8000561e:	413484b3          	sub	s1,s1,s3
    80005622:	0014b493          	seqz	s1,s1
    80005626:	bfc1                	j	800055f6 <holdingsleep+0x24>

0000000080005628 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005628:	1141                	addi	sp,sp,-16
    8000562a:	e406                	sd	ra,8(sp)
    8000562c:	e022                	sd	s0,0(sp)
    8000562e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005630:	00004597          	auipc	a1,0x4
    80005634:	2a858593          	addi	a1,a1,680 # 800098d8 <syscalls+0x298>
    80005638:	0001d517          	auipc	a0,0x1d
    8000563c:	7b050513          	addi	a0,a0,1968 # 80022de8 <ftable>
    80005640:	ffffb097          	auipc	ra,0xffffb
    80005644:	4fe080e7          	jalr	1278(ra) # 80000b3e <initlock>
}
    80005648:	60a2                	ld	ra,8(sp)
    8000564a:	6402                	ld	s0,0(sp)
    8000564c:	0141                	addi	sp,sp,16
    8000564e:	8082                	ret

0000000080005650 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005650:	1101                	addi	sp,sp,-32
    80005652:	ec06                	sd	ra,24(sp)
    80005654:	e822                	sd	s0,16(sp)
    80005656:	e426                	sd	s1,8(sp)
    80005658:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000565a:	0001d517          	auipc	a0,0x1d
    8000565e:	78e50513          	addi	a0,a0,1934 # 80022de8 <ftable>
    80005662:	ffffb097          	auipc	ra,0xffffb
    80005666:	56c080e7          	jalr	1388(ra) # 80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000566a:	0001d497          	auipc	s1,0x1d
    8000566e:	79648493          	addi	s1,s1,1942 # 80022e00 <ftable+0x18>
    80005672:	0001e717          	auipc	a4,0x1e
    80005676:	72e70713          	addi	a4,a4,1838 # 80023da0 <ftable+0xfb8>
    if(f->ref == 0){
    8000567a:	40dc                	lw	a5,4(s1)
    8000567c:	cf99                	beqz	a5,8000569a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000567e:	02848493          	addi	s1,s1,40
    80005682:	fee49ce3          	bne	s1,a4,8000567a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005686:	0001d517          	auipc	a0,0x1d
    8000568a:	76250513          	addi	a0,a0,1890 # 80022de8 <ftable>
    8000568e:	ffffb097          	auipc	ra,0xffffb
    80005692:	5f4080e7          	jalr	1524(ra) # 80000c82 <release>
  return 0;
    80005696:	4481                	li	s1,0
    80005698:	a819                	j	800056ae <filealloc+0x5e>
      f->ref = 1;
    8000569a:	4785                	li	a5,1
    8000569c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000569e:	0001d517          	auipc	a0,0x1d
    800056a2:	74a50513          	addi	a0,a0,1866 # 80022de8 <ftable>
    800056a6:	ffffb097          	auipc	ra,0xffffb
    800056aa:	5dc080e7          	jalr	1500(ra) # 80000c82 <release>
}
    800056ae:	8526                	mv	a0,s1
    800056b0:	60e2                	ld	ra,24(sp)
    800056b2:	6442                	ld	s0,16(sp)
    800056b4:	64a2                	ld	s1,8(sp)
    800056b6:	6105                	addi	sp,sp,32
    800056b8:	8082                	ret

00000000800056ba <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800056ba:	1101                	addi	sp,sp,-32
    800056bc:	ec06                	sd	ra,24(sp)
    800056be:	e822                	sd	s0,16(sp)
    800056c0:	e426                	sd	s1,8(sp)
    800056c2:	1000                	addi	s0,sp,32
    800056c4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800056c6:	0001d517          	auipc	a0,0x1d
    800056ca:	72250513          	addi	a0,a0,1826 # 80022de8 <ftable>
    800056ce:	ffffb097          	auipc	ra,0xffffb
    800056d2:	500080e7          	jalr	1280(ra) # 80000bce <acquire>
  if(f->ref < 1)
    800056d6:	40dc                	lw	a5,4(s1)
    800056d8:	02f05263          	blez	a5,800056fc <filedup+0x42>
    panic("filedup");
  f->ref++;
    800056dc:	2785                	addiw	a5,a5,1
    800056de:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800056e0:	0001d517          	auipc	a0,0x1d
    800056e4:	70850513          	addi	a0,a0,1800 # 80022de8 <ftable>
    800056e8:	ffffb097          	auipc	ra,0xffffb
    800056ec:	59a080e7          	jalr	1434(ra) # 80000c82 <release>
  return f;
}
    800056f0:	8526                	mv	a0,s1
    800056f2:	60e2                	ld	ra,24(sp)
    800056f4:	6442                	ld	s0,16(sp)
    800056f6:	64a2                	ld	s1,8(sp)
    800056f8:	6105                	addi	sp,sp,32
    800056fa:	8082                	ret
    panic("filedup");
    800056fc:	00004517          	auipc	a0,0x4
    80005700:	1e450513          	addi	a0,a0,484 # 800098e0 <syscalls+0x2a0>
    80005704:	ffffb097          	auipc	ra,0xffffb
    80005708:	e34080e7          	jalr	-460(ra) # 80000538 <panic>

000000008000570c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000570c:	7139                	addi	sp,sp,-64
    8000570e:	fc06                	sd	ra,56(sp)
    80005710:	f822                	sd	s0,48(sp)
    80005712:	f426                	sd	s1,40(sp)
    80005714:	f04a                	sd	s2,32(sp)
    80005716:	ec4e                	sd	s3,24(sp)
    80005718:	e852                	sd	s4,16(sp)
    8000571a:	e456                	sd	s5,8(sp)
    8000571c:	0080                	addi	s0,sp,64
    8000571e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005720:	0001d517          	auipc	a0,0x1d
    80005724:	6c850513          	addi	a0,a0,1736 # 80022de8 <ftable>
    80005728:	ffffb097          	auipc	ra,0xffffb
    8000572c:	4a6080e7          	jalr	1190(ra) # 80000bce <acquire>
  if(f->ref < 1)
    80005730:	40dc                	lw	a5,4(s1)
    80005732:	06f05163          	blez	a5,80005794 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005736:	37fd                	addiw	a5,a5,-1
    80005738:	0007871b          	sext.w	a4,a5
    8000573c:	c0dc                	sw	a5,4(s1)
    8000573e:	06e04363          	bgtz	a4,800057a4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005742:	0004a903          	lw	s2,0(s1)
    80005746:	0094ca83          	lbu	s5,9(s1)
    8000574a:	0104ba03          	ld	s4,16(s1)
    8000574e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005752:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005756:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000575a:	0001d517          	auipc	a0,0x1d
    8000575e:	68e50513          	addi	a0,a0,1678 # 80022de8 <ftable>
    80005762:	ffffb097          	auipc	ra,0xffffb
    80005766:	520080e7          	jalr	1312(ra) # 80000c82 <release>

  if(ff.type == FD_PIPE){
    8000576a:	4785                	li	a5,1
    8000576c:	04f90d63          	beq	s2,a5,800057c6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005770:	3979                	addiw	s2,s2,-2
    80005772:	4785                	li	a5,1
    80005774:	0527e063          	bltu	a5,s2,800057b4 <fileclose+0xa8>
    begin_op();
    80005778:	00000097          	auipc	ra,0x0
    8000577c:	acc080e7          	jalr	-1332(ra) # 80005244 <begin_op>
    iput(ff.ip);
    80005780:	854e                	mv	a0,s3
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	2a0080e7          	jalr	672(ra) # 80004a22 <iput>
    end_op();
    8000578a:	00000097          	auipc	ra,0x0
    8000578e:	b38080e7          	jalr	-1224(ra) # 800052c2 <end_op>
    80005792:	a00d                	j	800057b4 <fileclose+0xa8>
    panic("fileclose");
    80005794:	00004517          	auipc	a0,0x4
    80005798:	15450513          	addi	a0,a0,340 # 800098e8 <syscalls+0x2a8>
    8000579c:	ffffb097          	auipc	ra,0xffffb
    800057a0:	d9c080e7          	jalr	-612(ra) # 80000538 <panic>
    release(&ftable.lock);
    800057a4:	0001d517          	auipc	a0,0x1d
    800057a8:	64450513          	addi	a0,a0,1604 # 80022de8 <ftable>
    800057ac:	ffffb097          	auipc	ra,0xffffb
    800057b0:	4d6080e7          	jalr	1238(ra) # 80000c82 <release>
  }
}
    800057b4:	70e2                	ld	ra,56(sp)
    800057b6:	7442                	ld	s0,48(sp)
    800057b8:	74a2                	ld	s1,40(sp)
    800057ba:	7902                	ld	s2,32(sp)
    800057bc:	69e2                	ld	s3,24(sp)
    800057be:	6a42                	ld	s4,16(sp)
    800057c0:	6aa2                	ld	s5,8(sp)
    800057c2:	6121                	addi	sp,sp,64
    800057c4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800057c6:	85d6                	mv	a1,s5
    800057c8:	8552                	mv	a0,s4
    800057ca:	00000097          	auipc	ra,0x0
    800057ce:	34c080e7          	jalr	844(ra) # 80005b16 <pipeclose>
    800057d2:	b7cd                	j	800057b4 <fileclose+0xa8>

00000000800057d4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800057d4:	715d                	addi	sp,sp,-80
    800057d6:	e486                	sd	ra,72(sp)
    800057d8:	e0a2                	sd	s0,64(sp)
    800057da:	fc26                	sd	s1,56(sp)
    800057dc:	f84a                	sd	s2,48(sp)
    800057de:	f44e                	sd	s3,40(sp)
    800057e0:	0880                	addi	s0,sp,80
    800057e2:	84aa                	mv	s1,a0
    800057e4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800057e6:	ffffc097          	auipc	ra,0xffffc
    800057ea:	1b8080e7          	jalr	440(ra) # 8000199e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800057ee:	409c                	lw	a5,0(s1)
    800057f0:	37f9                	addiw	a5,a5,-2
    800057f2:	4705                	li	a4,1
    800057f4:	04f76763          	bltu	a4,a5,80005842 <filestat+0x6e>
    800057f8:	892a                	mv	s2,a0
    ilock(f->ip);
    800057fa:	6c88                	ld	a0,24(s1)
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	06c080e7          	jalr	108(ra) # 80004868 <ilock>
    stati(f->ip, &st);
    80005804:	fb840593          	addi	a1,s0,-72
    80005808:	6c88                	ld	a0,24(s1)
    8000580a:	fffff097          	auipc	ra,0xfffff
    8000580e:	2e8080e7          	jalr	744(ra) # 80004af2 <stati>
    iunlock(f->ip);
    80005812:	6c88                	ld	a0,24(s1)
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	116080e7          	jalr	278(ra) # 8000492a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000581c:	46e1                	li	a3,24
    8000581e:	fb840613          	addi	a2,s0,-72
    80005822:	85ce                	mv	a1,s3
    80005824:	05893503          	ld	a0,88(s2)
    80005828:	ffffc097          	auipc	ra,0xffffc
    8000582c:	e3a080e7          	jalr	-454(ra) # 80001662 <copyout>
    80005830:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005834:	60a6                	ld	ra,72(sp)
    80005836:	6406                	ld	s0,64(sp)
    80005838:	74e2                	ld	s1,56(sp)
    8000583a:	7942                	ld	s2,48(sp)
    8000583c:	79a2                	ld	s3,40(sp)
    8000583e:	6161                	addi	sp,sp,80
    80005840:	8082                	ret
  return -1;
    80005842:	557d                	li	a0,-1
    80005844:	bfc5                	j	80005834 <filestat+0x60>

0000000080005846 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005846:	7179                	addi	sp,sp,-48
    80005848:	f406                	sd	ra,40(sp)
    8000584a:	f022                	sd	s0,32(sp)
    8000584c:	ec26                	sd	s1,24(sp)
    8000584e:	e84a                	sd	s2,16(sp)
    80005850:	e44e                	sd	s3,8(sp)
    80005852:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005854:	00854783          	lbu	a5,8(a0)
    80005858:	c3d5                	beqz	a5,800058fc <fileread+0xb6>
    8000585a:	84aa                	mv	s1,a0
    8000585c:	89ae                	mv	s3,a1
    8000585e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005860:	411c                	lw	a5,0(a0)
    80005862:	4705                	li	a4,1
    80005864:	04e78963          	beq	a5,a4,800058b6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005868:	470d                	li	a4,3
    8000586a:	04e78d63          	beq	a5,a4,800058c4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000586e:	4709                	li	a4,2
    80005870:	06e79e63          	bne	a5,a4,800058ec <fileread+0xa6>
    ilock(f->ip);
    80005874:	6d08                	ld	a0,24(a0)
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	ff2080e7          	jalr	-14(ra) # 80004868 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000587e:	874a                	mv	a4,s2
    80005880:	5094                	lw	a3,32(s1)
    80005882:	864e                	mv	a2,s3
    80005884:	4585                	li	a1,1
    80005886:	6c88                	ld	a0,24(s1)
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	294080e7          	jalr	660(ra) # 80004b1c <readi>
    80005890:	892a                	mv	s2,a0
    80005892:	00a05563          	blez	a0,8000589c <fileread+0x56>
      f->off += r;
    80005896:	509c                	lw	a5,32(s1)
    80005898:	9fa9                	addw	a5,a5,a0
    8000589a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000589c:	6c88                	ld	a0,24(s1)
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	08c080e7          	jalr	140(ra) # 8000492a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800058a6:	854a                	mv	a0,s2
    800058a8:	70a2                	ld	ra,40(sp)
    800058aa:	7402                	ld	s0,32(sp)
    800058ac:	64e2                	ld	s1,24(sp)
    800058ae:	6942                	ld	s2,16(sp)
    800058b0:	69a2                	ld	s3,8(sp)
    800058b2:	6145                	addi	sp,sp,48
    800058b4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800058b6:	6908                	ld	a0,16(a0)
    800058b8:	00000097          	auipc	ra,0x0
    800058bc:	3c0080e7          	jalr	960(ra) # 80005c78 <piperead>
    800058c0:	892a                	mv	s2,a0
    800058c2:	b7d5                	j	800058a6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800058c4:	02451783          	lh	a5,36(a0)
    800058c8:	03079693          	slli	a3,a5,0x30
    800058cc:	92c1                	srli	a3,a3,0x30
    800058ce:	4725                	li	a4,9
    800058d0:	02d76863          	bltu	a4,a3,80005900 <fileread+0xba>
    800058d4:	0792                	slli	a5,a5,0x4
    800058d6:	0001d717          	auipc	a4,0x1d
    800058da:	47270713          	addi	a4,a4,1138 # 80022d48 <devsw>
    800058de:	97ba                	add	a5,a5,a4
    800058e0:	639c                	ld	a5,0(a5)
    800058e2:	c38d                	beqz	a5,80005904 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800058e4:	4505                	li	a0,1
    800058e6:	9782                	jalr	a5
    800058e8:	892a                	mv	s2,a0
    800058ea:	bf75                	j	800058a6 <fileread+0x60>
    panic("fileread");
    800058ec:	00004517          	auipc	a0,0x4
    800058f0:	00c50513          	addi	a0,a0,12 # 800098f8 <syscalls+0x2b8>
    800058f4:	ffffb097          	auipc	ra,0xffffb
    800058f8:	c44080e7          	jalr	-956(ra) # 80000538 <panic>
    return -1;
    800058fc:	597d                	li	s2,-1
    800058fe:	b765                	j	800058a6 <fileread+0x60>
      return -1;
    80005900:	597d                	li	s2,-1
    80005902:	b755                	j	800058a6 <fileread+0x60>
    80005904:	597d                	li	s2,-1
    80005906:	b745                	j	800058a6 <fileread+0x60>

0000000080005908 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005908:	715d                	addi	sp,sp,-80
    8000590a:	e486                	sd	ra,72(sp)
    8000590c:	e0a2                	sd	s0,64(sp)
    8000590e:	fc26                	sd	s1,56(sp)
    80005910:	f84a                	sd	s2,48(sp)
    80005912:	f44e                	sd	s3,40(sp)
    80005914:	f052                	sd	s4,32(sp)
    80005916:	ec56                	sd	s5,24(sp)
    80005918:	e85a                	sd	s6,16(sp)
    8000591a:	e45e                	sd	s7,8(sp)
    8000591c:	e062                	sd	s8,0(sp)
    8000591e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005920:	00954783          	lbu	a5,9(a0)
    80005924:	10078663          	beqz	a5,80005a30 <filewrite+0x128>
    80005928:	892a                	mv	s2,a0
    8000592a:	8b2e                	mv	s6,a1
    8000592c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000592e:	411c                	lw	a5,0(a0)
    80005930:	4705                	li	a4,1
    80005932:	02e78263          	beq	a5,a4,80005956 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005936:	470d                	li	a4,3
    80005938:	02e78663          	beq	a5,a4,80005964 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000593c:	4709                	li	a4,2
    8000593e:	0ee79163          	bne	a5,a4,80005a20 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005942:	0ac05d63          	blez	a2,800059fc <filewrite+0xf4>
    int i = 0;
    80005946:	4981                	li	s3,0
    80005948:	6b85                	lui	s7,0x1
    8000594a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000594e:	6c05                	lui	s8,0x1
    80005950:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005954:	a861                	j	800059ec <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005956:	6908                	ld	a0,16(a0)
    80005958:	00000097          	auipc	ra,0x0
    8000595c:	22e080e7          	jalr	558(ra) # 80005b86 <pipewrite>
    80005960:	8a2a                	mv	s4,a0
    80005962:	a045                	j	80005a02 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005964:	02451783          	lh	a5,36(a0)
    80005968:	03079693          	slli	a3,a5,0x30
    8000596c:	92c1                	srli	a3,a3,0x30
    8000596e:	4725                	li	a4,9
    80005970:	0cd76263          	bltu	a4,a3,80005a34 <filewrite+0x12c>
    80005974:	0792                	slli	a5,a5,0x4
    80005976:	0001d717          	auipc	a4,0x1d
    8000597a:	3d270713          	addi	a4,a4,978 # 80022d48 <devsw>
    8000597e:	97ba                	add	a5,a5,a4
    80005980:	679c                	ld	a5,8(a5)
    80005982:	cbdd                	beqz	a5,80005a38 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005984:	4505                	li	a0,1
    80005986:	9782                	jalr	a5
    80005988:	8a2a                	mv	s4,a0
    8000598a:	a8a5                	j	80005a02 <filewrite+0xfa>
    8000598c:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005990:	00000097          	auipc	ra,0x0
    80005994:	8b4080e7          	jalr	-1868(ra) # 80005244 <begin_op>
      ilock(f->ip);
    80005998:	01893503          	ld	a0,24(s2)
    8000599c:	fffff097          	auipc	ra,0xfffff
    800059a0:	ecc080e7          	jalr	-308(ra) # 80004868 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800059a4:	8756                	mv	a4,s5
    800059a6:	02092683          	lw	a3,32(s2)
    800059aa:	01698633          	add	a2,s3,s6
    800059ae:	4585                	li	a1,1
    800059b0:	01893503          	ld	a0,24(s2)
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	260080e7          	jalr	608(ra) # 80004c14 <writei>
    800059bc:	84aa                	mv	s1,a0
    800059be:	00a05763          	blez	a0,800059cc <filewrite+0xc4>
        f->off += r;
    800059c2:	02092783          	lw	a5,32(s2)
    800059c6:	9fa9                	addw	a5,a5,a0
    800059c8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800059cc:	01893503          	ld	a0,24(s2)
    800059d0:	fffff097          	auipc	ra,0xfffff
    800059d4:	f5a080e7          	jalr	-166(ra) # 8000492a <iunlock>
      end_op();
    800059d8:	00000097          	auipc	ra,0x0
    800059dc:	8ea080e7          	jalr	-1814(ra) # 800052c2 <end_op>

      if(r != n1){
    800059e0:	009a9f63          	bne	s5,s1,800059fe <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800059e4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800059e8:	0149db63          	bge	s3,s4,800059fe <filewrite+0xf6>
      int n1 = n - i;
    800059ec:	413a04bb          	subw	s1,s4,s3
    800059f0:	0004879b          	sext.w	a5,s1
    800059f4:	f8fbdce3          	bge	s7,a5,8000598c <filewrite+0x84>
    800059f8:	84e2                	mv	s1,s8
    800059fa:	bf49                	j	8000598c <filewrite+0x84>
    int i = 0;
    800059fc:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800059fe:	013a1f63          	bne	s4,s3,80005a1c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005a02:	8552                	mv	a0,s4
    80005a04:	60a6                	ld	ra,72(sp)
    80005a06:	6406                	ld	s0,64(sp)
    80005a08:	74e2                	ld	s1,56(sp)
    80005a0a:	7942                	ld	s2,48(sp)
    80005a0c:	79a2                	ld	s3,40(sp)
    80005a0e:	7a02                	ld	s4,32(sp)
    80005a10:	6ae2                	ld	s5,24(sp)
    80005a12:	6b42                	ld	s6,16(sp)
    80005a14:	6ba2                	ld	s7,8(sp)
    80005a16:	6c02                	ld	s8,0(sp)
    80005a18:	6161                	addi	sp,sp,80
    80005a1a:	8082                	ret
    ret = (i == n ? n : -1);
    80005a1c:	5a7d                	li	s4,-1
    80005a1e:	b7d5                	j	80005a02 <filewrite+0xfa>
    panic("filewrite");
    80005a20:	00004517          	auipc	a0,0x4
    80005a24:	ee850513          	addi	a0,a0,-280 # 80009908 <syscalls+0x2c8>
    80005a28:	ffffb097          	auipc	ra,0xffffb
    80005a2c:	b10080e7          	jalr	-1264(ra) # 80000538 <panic>
    return -1;
    80005a30:	5a7d                	li	s4,-1
    80005a32:	bfc1                	j	80005a02 <filewrite+0xfa>
      return -1;
    80005a34:	5a7d                	li	s4,-1
    80005a36:	b7f1                	j	80005a02 <filewrite+0xfa>
    80005a38:	5a7d                	li	s4,-1
    80005a3a:	b7e1                	j	80005a02 <filewrite+0xfa>

0000000080005a3c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005a3c:	7179                	addi	sp,sp,-48
    80005a3e:	f406                	sd	ra,40(sp)
    80005a40:	f022                	sd	s0,32(sp)
    80005a42:	ec26                	sd	s1,24(sp)
    80005a44:	e84a                	sd	s2,16(sp)
    80005a46:	e44e                	sd	s3,8(sp)
    80005a48:	e052                	sd	s4,0(sp)
    80005a4a:	1800                	addi	s0,sp,48
    80005a4c:	84aa                	mv	s1,a0
    80005a4e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005a50:	0005b023          	sd	zero,0(a1)
    80005a54:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005a58:	00000097          	auipc	ra,0x0
    80005a5c:	bf8080e7          	jalr	-1032(ra) # 80005650 <filealloc>
    80005a60:	e088                	sd	a0,0(s1)
    80005a62:	c551                	beqz	a0,80005aee <pipealloc+0xb2>
    80005a64:	00000097          	auipc	ra,0x0
    80005a68:	bec080e7          	jalr	-1044(ra) # 80005650 <filealloc>
    80005a6c:	00aa3023          	sd	a0,0(s4)
    80005a70:	c92d                	beqz	a0,80005ae2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005a72:	ffffb097          	auipc	ra,0xffffb
    80005a76:	06c080e7          	jalr	108(ra) # 80000ade <kalloc>
    80005a7a:	892a                	mv	s2,a0
    80005a7c:	c125                	beqz	a0,80005adc <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005a7e:	4985                	li	s3,1
    80005a80:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005a84:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005a88:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005a8c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005a90:	00004597          	auipc	a1,0x4
    80005a94:	e8858593          	addi	a1,a1,-376 # 80009918 <syscalls+0x2d8>
    80005a98:	ffffb097          	auipc	ra,0xffffb
    80005a9c:	0a6080e7          	jalr	166(ra) # 80000b3e <initlock>
  (*f0)->type = FD_PIPE;
    80005aa0:	609c                	ld	a5,0(s1)
    80005aa2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005aa6:	609c                	ld	a5,0(s1)
    80005aa8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005aac:	609c                	ld	a5,0(s1)
    80005aae:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005ab2:	609c                	ld	a5,0(s1)
    80005ab4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005ab8:	000a3783          	ld	a5,0(s4)
    80005abc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005ac0:	000a3783          	ld	a5,0(s4)
    80005ac4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005ac8:	000a3783          	ld	a5,0(s4)
    80005acc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005ad0:	000a3783          	ld	a5,0(s4)
    80005ad4:	0127b823          	sd	s2,16(a5)
  return 0;
    80005ad8:	4501                	li	a0,0
    80005ada:	a025                	j	80005b02 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005adc:	6088                	ld	a0,0(s1)
    80005ade:	e501                	bnez	a0,80005ae6 <pipealloc+0xaa>
    80005ae0:	a039                	j	80005aee <pipealloc+0xb2>
    80005ae2:	6088                	ld	a0,0(s1)
    80005ae4:	c51d                	beqz	a0,80005b12 <pipealloc+0xd6>
    fileclose(*f0);
    80005ae6:	00000097          	auipc	ra,0x0
    80005aea:	c26080e7          	jalr	-986(ra) # 8000570c <fileclose>
  if(*f1)
    80005aee:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005af2:	557d                	li	a0,-1
  if(*f1)
    80005af4:	c799                	beqz	a5,80005b02 <pipealloc+0xc6>
    fileclose(*f1);
    80005af6:	853e                	mv	a0,a5
    80005af8:	00000097          	auipc	ra,0x0
    80005afc:	c14080e7          	jalr	-1004(ra) # 8000570c <fileclose>
  return -1;
    80005b00:	557d                	li	a0,-1
}
    80005b02:	70a2                	ld	ra,40(sp)
    80005b04:	7402                	ld	s0,32(sp)
    80005b06:	64e2                	ld	s1,24(sp)
    80005b08:	6942                	ld	s2,16(sp)
    80005b0a:	69a2                	ld	s3,8(sp)
    80005b0c:	6a02                	ld	s4,0(sp)
    80005b0e:	6145                	addi	sp,sp,48
    80005b10:	8082                	ret
  return -1;
    80005b12:	557d                	li	a0,-1
    80005b14:	b7fd                	j	80005b02 <pipealloc+0xc6>

0000000080005b16 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005b16:	1101                	addi	sp,sp,-32
    80005b18:	ec06                	sd	ra,24(sp)
    80005b1a:	e822                	sd	s0,16(sp)
    80005b1c:	e426                	sd	s1,8(sp)
    80005b1e:	e04a                	sd	s2,0(sp)
    80005b20:	1000                	addi	s0,sp,32
    80005b22:	84aa                	mv	s1,a0
    80005b24:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005b26:	ffffb097          	auipc	ra,0xffffb
    80005b2a:	0a8080e7          	jalr	168(ra) # 80000bce <acquire>
  if(writable){
    80005b2e:	02090d63          	beqz	s2,80005b68 <pipeclose+0x52>
    pi->writeopen = 0;
    80005b32:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005b36:	21848513          	addi	a0,s1,536
    80005b3a:	ffffd097          	auipc	ra,0xffffd
    80005b3e:	01a080e7          	jalr	26(ra) # 80002b54 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005b42:	2204b783          	ld	a5,544(s1)
    80005b46:	eb95                	bnez	a5,80005b7a <pipeclose+0x64>
    release(&pi->lock);
    80005b48:	8526                	mv	a0,s1
    80005b4a:	ffffb097          	auipc	ra,0xffffb
    80005b4e:	138080e7          	jalr	312(ra) # 80000c82 <release>
    kfree((char*)pi);
    80005b52:	8526                	mv	a0,s1
    80005b54:	ffffb097          	auipc	ra,0xffffb
    80005b58:	e8c080e7          	jalr	-372(ra) # 800009e0 <kfree>
  } else
    release(&pi->lock);
}
    80005b5c:	60e2                	ld	ra,24(sp)
    80005b5e:	6442                	ld	s0,16(sp)
    80005b60:	64a2                	ld	s1,8(sp)
    80005b62:	6902                	ld	s2,0(sp)
    80005b64:	6105                	addi	sp,sp,32
    80005b66:	8082                	ret
    pi->readopen = 0;
    80005b68:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005b6c:	21c48513          	addi	a0,s1,540
    80005b70:	ffffd097          	auipc	ra,0xffffd
    80005b74:	fe4080e7          	jalr	-28(ra) # 80002b54 <wakeup>
    80005b78:	b7e9                	j	80005b42 <pipeclose+0x2c>
    release(&pi->lock);
    80005b7a:	8526                	mv	a0,s1
    80005b7c:	ffffb097          	auipc	ra,0xffffb
    80005b80:	106080e7          	jalr	262(ra) # 80000c82 <release>
}
    80005b84:	bfe1                	j	80005b5c <pipeclose+0x46>

0000000080005b86 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005b86:	711d                	addi	sp,sp,-96
    80005b88:	ec86                	sd	ra,88(sp)
    80005b8a:	e8a2                	sd	s0,80(sp)
    80005b8c:	e4a6                	sd	s1,72(sp)
    80005b8e:	e0ca                	sd	s2,64(sp)
    80005b90:	fc4e                	sd	s3,56(sp)
    80005b92:	f852                	sd	s4,48(sp)
    80005b94:	f456                	sd	s5,40(sp)
    80005b96:	f05a                	sd	s6,32(sp)
    80005b98:	ec5e                	sd	s7,24(sp)
    80005b9a:	e862                	sd	s8,16(sp)
    80005b9c:	1080                	addi	s0,sp,96
    80005b9e:	84aa                	mv	s1,a0
    80005ba0:	8aae                	mv	s5,a1
    80005ba2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005ba4:	ffffc097          	auipc	ra,0xffffc
    80005ba8:	dfa080e7          	jalr	-518(ra) # 8000199e <myproc>
    80005bac:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005bae:	8526                	mv	a0,s1
    80005bb0:	ffffb097          	auipc	ra,0xffffb
    80005bb4:	01e080e7          	jalr	30(ra) # 80000bce <acquire>
  while(i < n){
    80005bb8:	0b405363          	blez	s4,80005c5e <pipewrite+0xd8>
  int i = 0;
    80005bbc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005bbe:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005bc0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005bc4:	21c48b93          	addi	s7,s1,540
    80005bc8:	a089                	j	80005c0a <pipewrite+0x84>
      release(&pi->lock);
    80005bca:	8526                	mv	a0,s1
    80005bcc:	ffffb097          	auipc	ra,0xffffb
    80005bd0:	0b6080e7          	jalr	182(ra) # 80000c82 <release>
      return -1;
    80005bd4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005bd6:	854a                	mv	a0,s2
    80005bd8:	60e6                	ld	ra,88(sp)
    80005bda:	6446                	ld	s0,80(sp)
    80005bdc:	64a6                	ld	s1,72(sp)
    80005bde:	6906                	ld	s2,64(sp)
    80005be0:	79e2                	ld	s3,56(sp)
    80005be2:	7a42                	ld	s4,48(sp)
    80005be4:	7aa2                	ld	s5,40(sp)
    80005be6:	7b02                	ld	s6,32(sp)
    80005be8:	6be2                	ld	s7,24(sp)
    80005bea:	6c42                	ld	s8,16(sp)
    80005bec:	6125                	addi	sp,sp,96
    80005bee:	8082                	ret
      wakeup(&pi->nread);
    80005bf0:	8562                	mv	a0,s8
    80005bf2:	ffffd097          	auipc	ra,0xffffd
    80005bf6:	f62080e7          	jalr	-158(ra) # 80002b54 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005bfa:	85a6                	mv	a1,s1
    80005bfc:	855e                	mv	a0,s7
    80005bfe:	ffffd097          	auipc	ra,0xffffd
    80005c02:	b52080e7          	jalr	-1198(ra) # 80002750 <sleep>
  while(i < n){
    80005c06:	05495d63          	bge	s2,s4,80005c60 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005c0a:	2204a783          	lw	a5,544(s1)
    80005c0e:	dfd5                	beqz	a5,80005bca <pipewrite+0x44>
    80005c10:	0289a783          	lw	a5,40(s3)
    80005c14:	fbdd                	bnez	a5,80005bca <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005c16:	2184a783          	lw	a5,536(s1)
    80005c1a:	21c4a703          	lw	a4,540(s1)
    80005c1e:	2007879b          	addiw	a5,a5,512
    80005c22:	fcf707e3          	beq	a4,a5,80005bf0 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005c26:	4685                	li	a3,1
    80005c28:	01590633          	add	a2,s2,s5
    80005c2c:	faf40593          	addi	a1,s0,-81
    80005c30:	0589b503          	ld	a0,88(s3)
    80005c34:	ffffc097          	auipc	ra,0xffffc
    80005c38:	aba080e7          	jalr	-1350(ra) # 800016ee <copyin>
    80005c3c:	03650263          	beq	a0,s6,80005c60 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005c40:	21c4a783          	lw	a5,540(s1)
    80005c44:	0017871b          	addiw	a4,a5,1
    80005c48:	20e4ae23          	sw	a4,540(s1)
    80005c4c:	1ff7f793          	andi	a5,a5,511
    80005c50:	97a6                	add	a5,a5,s1
    80005c52:	faf44703          	lbu	a4,-81(s0)
    80005c56:	00e78c23          	sb	a4,24(a5)
      i++;
    80005c5a:	2905                	addiw	s2,s2,1
    80005c5c:	b76d                	j	80005c06 <pipewrite+0x80>
  int i = 0;
    80005c5e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005c60:	21848513          	addi	a0,s1,536
    80005c64:	ffffd097          	auipc	ra,0xffffd
    80005c68:	ef0080e7          	jalr	-272(ra) # 80002b54 <wakeup>
  release(&pi->lock);
    80005c6c:	8526                	mv	a0,s1
    80005c6e:	ffffb097          	auipc	ra,0xffffb
    80005c72:	014080e7          	jalr	20(ra) # 80000c82 <release>
  return i;
    80005c76:	b785                	j	80005bd6 <pipewrite+0x50>

0000000080005c78 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005c78:	715d                	addi	sp,sp,-80
    80005c7a:	e486                	sd	ra,72(sp)
    80005c7c:	e0a2                	sd	s0,64(sp)
    80005c7e:	fc26                	sd	s1,56(sp)
    80005c80:	f84a                	sd	s2,48(sp)
    80005c82:	f44e                	sd	s3,40(sp)
    80005c84:	f052                	sd	s4,32(sp)
    80005c86:	ec56                	sd	s5,24(sp)
    80005c88:	e85a                	sd	s6,16(sp)
    80005c8a:	0880                	addi	s0,sp,80
    80005c8c:	84aa                	mv	s1,a0
    80005c8e:	892e                	mv	s2,a1
    80005c90:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005c92:	ffffc097          	auipc	ra,0xffffc
    80005c96:	d0c080e7          	jalr	-756(ra) # 8000199e <myproc>
    80005c9a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005c9c:	8526                	mv	a0,s1
    80005c9e:	ffffb097          	auipc	ra,0xffffb
    80005ca2:	f30080e7          	jalr	-208(ra) # 80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005ca6:	2184a703          	lw	a4,536(s1)
    80005caa:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005cae:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005cb2:	02f71463          	bne	a4,a5,80005cda <piperead+0x62>
    80005cb6:	2244a783          	lw	a5,548(s1)
    80005cba:	c385                	beqz	a5,80005cda <piperead+0x62>
    if(pr->killed){
    80005cbc:	028a2783          	lw	a5,40(s4)
    80005cc0:	ebc9                	bnez	a5,80005d52 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005cc2:	85a6                	mv	a1,s1
    80005cc4:	854e                	mv	a0,s3
    80005cc6:	ffffd097          	auipc	ra,0xffffd
    80005cca:	a8a080e7          	jalr	-1398(ra) # 80002750 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005cce:	2184a703          	lw	a4,536(s1)
    80005cd2:	21c4a783          	lw	a5,540(s1)
    80005cd6:	fef700e3          	beq	a4,a5,80005cb6 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005cda:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005cdc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005cde:	05505463          	blez	s5,80005d26 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80005ce2:	2184a783          	lw	a5,536(s1)
    80005ce6:	21c4a703          	lw	a4,540(s1)
    80005cea:	02f70e63          	beq	a4,a5,80005d26 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005cee:	0017871b          	addiw	a4,a5,1
    80005cf2:	20e4ac23          	sw	a4,536(s1)
    80005cf6:	1ff7f793          	andi	a5,a5,511
    80005cfa:	97a6                	add	a5,a5,s1
    80005cfc:	0187c783          	lbu	a5,24(a5)
    80005d00:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005d04:	4685                	li	a3,1
    80005d06:	fbf40613          	addi	a2,s0,-65
    80005d0a:	85ca                	mv	a1,s2
    80005d0c:	058a3503          	ld	a0,88(s4)
    80005d10:	ffffc097          	auipc	ra,0xffffc
    80005d14:	952080e7          	jalr	-1710(ra) # 80001662 <copyout>
    80005d18:	01650763          	beq	a0,s6,80005d26 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005d1c:	2985                	addiw	s3,s3,1
    80005d1e:	0905                	addi	s2,s2,1
    80005d20:	fd3a91e3          	bne	s5,s3,80005ce2 <piperead+0x6a>
    80005d24:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005d26:	21c48513          	addi	a0,s1,540
    80005d2a:	ffffd097          	auipc	ra,0xffffd
    80005d2e:	e2a080e7          	jalr	-470(ra) # 80002b54 <wakeup>
  release(&pi->lock);
    80005d32:	8526                	mv	a0,s1
    80005d34:	ffffb097          	auipc	ra,0xffffb
    80005d38:	f4e080e7          	jalr	-178(ra) # 80000c82 <release>
  return i;
}
    80005d3c:	854e                	mv	a0,s3
    80005d3e:	60a6                	ld	ra,72(sp)
    80005d40:	6406                	ld	s0,64(sp)
    80005d42:	74e2                	ld	s1,56(sp)
    80005d44:	7942                	ld	s2,48(sp)
    80005d46:	79a2                	ld	s3,40(sp)
    80005d48:	7a02                	ld	s4,32(sp)
    80005d4a:	6ae2                	ld	s5,24(sp)
    80005d4c:	6b42                	ld	s6,16(sp)
    80005d4e:	6161                	addi	sp,sp,80
    80005d50:	8082                	ret
      release(&pi->lock);
    80005d52:	8526                	mv	a0,s1
    80005d54:	ffffb097          	auipc	ra,0xffffb
    80005d58:	f2e080e7          	jalr	-210(ra) # 80000c82 <release>
      return -1;
    80005d5c:	59fd                	li	s3,-1
    80005d5e:	bff9                	j	80005d3c <piperead+0xc4>

0000000080005d60 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005d60:	de010113          	addi	sp,sp,-544
    80005d64:	20113c23          	sd	ra,536(sp)
    80005d68:	20813823          	sd	s0,528(sp)
    80005d6c:	20913423          	sd	s1,520(sp)
    80005d70:	21213023          	sd	s2,512(sp)
    80005d74:	ffce                	sd	s3,504(sp)
    80005d76:	fbd2                	sd	s4,496(sp)
    80005d78:	f7d6                	sd	s5,488(sp)
    80005d7a:	f3da                	sd	s6,480(sp)
    80005d7c:	efde                	sd	s7,472(sp)
    80005d7e:	ebe2                	sd	s8,464(sp)
    80005d80:	e7e6                	sd	s9,456(sp)
    80005d82:	e3ea                	sd	s10,448(sp)
    80005d84:	ff6e                	sd	s11,440(sp)
    80005d86:	1400                	addi	s0,sp,544
    80005d88:	892a                	mv	s2,a0
    80005d8a:	dea43423          	sd	a0,-536(s0)
    80005d8e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005d92:	ffffc097          	auipc	ra,0xffffc
    80005d96:	c0c080e7          	jalr	-1012(ra) # 8000199e <myproc>
    80005d9a:	84aa                	mv	s1,a0

  begin_op();
    80005d9c:	fffff097          	auipc	ra,0xfffff
    80005da0:	4a8080e7          	jalr	1192(ra) # 80005244 <begin_op>

  if((ip = namei(path)) == 0){
    80005da4:	854a                	mv	a0,s2
    80005da6:	fffff097          	auipc	ra,0xfffff
    80005daa:	27e080e7          	jalr	638(ra) # 80005024 <namei>
    80005dae:	c93d                	beqz	a0,80005e24 <exec+0xc4>
    80005db0:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	ab6080e7          	jalr	-1354(ra) # 80004868 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005dba:	04000713          	li	a4,64
    80005dbe:	4681                	li	a3,0
    80005dc0:	e5040613          	addi	a2,s0,-432
    80005dc4:	4581                	li	a1,0
    80005dc6:	8556                	mv	a0,s5
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	d54080e7          	jalr	-684(ra) # 80004b1c <readi>
    80005dd0:	04000793          	li	a5,64
    80005dd4:	00f51a63          	bne	a0,a5,80005de8 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005dd8:	e5042703          	lw	a4,-432(s0)
    80005ddc:	464c47b7          	lui	a5,0x464c4
    80005de0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005de4:	04f70663          	beq	a4,a5,80005e30 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005de8:	8556                	mv	a0,s5
    80005dea:	fffff097          	auipc	ra,0xfffff
    80005dee:	ce0080e7          	jalr	-800(ra) # 80004aca <iunlockput>
    end_op();
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	4d0080e7          	jalr	1232(ra) # 800052c2 <end_op>
  }
  return -1;
    80005dfa:	557d                	li	a0,-1
}
    80005dfc:	21813083          	ld	ra,536(sp)
    80005e00:	21013403          	ld	s0,528(sp)
    80005e04:	20813483          	ld	s1,520(sp)
    80005e08:	20013903          	ld	s2,512(sp)
    80005e0c:	79fe                	ld	s3,504(sp)
    80005e0e:	7a5e                	ld	s4,496(sp)
    80005e10:	7abe                	ld	s5,488(sp)
    80005e12:	7b1e                	ld	s6,480(sp)
    80005e14:	6bfe                	ld	s7,472(sp)
    80005e16:	6c5e                	ld	s8,464(sp)
    80005e18:	6cbe                	ld	s9,456(sp)
    80005e1a:	6d1e                	ld	s10,448(sp)
    80005e1c:	7dfa                	ld	s11,440(sp)
    80005e1e:	22010113          	addi	sp,sp,544
    80005e22:	8082                	ret
    end_op();
    80005e24:	fffff097          	auipc	ra,0xfffff
    80005e28:	49e080e7          	jalr	1182(ra) # 800052c2 <end_op>
    return -1;
    80005e2c:	557d                	li	a0,-1
    80005e2e:	b7f9                	j	80005dfc <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005e30:	8526                	mv	a0,s1
    80005e32:	ffffc097          	auipc	ra,0xffffc
    80005e36:	c68080e7          	jalr	-920(ra) # 80001a9a <proc_pagetable>
    80005e3a:	8b2a                	mv	s6,a0
    80005e3c:	d555                	beqz	a0,80005de8 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005e3e:	e7042783          	lw	a5,-400(s0)
    80005e42:	e8845703          	lhu	a4,-376(s0)
    80005e46:	c735                	beqz	a4,80005eb2 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005e48:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005e4a:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80005e4e:	6a05                	lui	s4,0x1
    80005e50:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005e54:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005e58:	6d85                	lui	s11,0x1
    80005e5a:	7d7d                	lui	s10,0xfffff
    80005e5c:	ac1d                	j	80006092 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005e5e:	00004517          	auipc	a0,0x4
    80005e62:	ac250513          	addi	a0,a0,-1342 # 80009920 <syscalls+0x2e0>
    80005e66:	ffffa097          	auipc	ra,0xffffa
    80005e6a:	6d2080e7          	jalr	1746(ra) # 80000538 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005e6e:	874a                	mv	a4,s2
    80005e70:	009c86bb          	addw	a3,s9,s1
    80005e74:	4581                	li	a1,0
    80005e76:	8556                	mv	a0,s5
    80005e78:	fffff097          	auipc	ra,0xfffff
    80005e7c:	ca4080e7          	jalr	-860(ra) # 80004b1c <readi>
    80005e80:	2501                	sext.w	a0,a0
    80005e82:	1aa91863          	bne	s2,a0,80006032 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80005e86:	009d84bb          	addw	s1,s11,s1
    80005e8a:	013d09bb          	addw	s3,s10,s3
    80005e8e:	1f74f263          	bgeu	s1,s7,80006072 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80005e92:	02049593          	slli	a1,s1,0x20
    80005e96:	9181                	srli	a1,a1,0x20
    80005e98:	95e2                	add	a1,a1,s8
    80005e9a:	855a                	mv	a0,s6
    80005e9c:	ffffb097          	auipc	ra,0xffffb
    80005ea0:	1be080e7          	jalr	446(ra) # 8000105a <walkaddr>
    80005ea4:	862a                	mv	a2,a0
    if(pa == 0)
    80005ea6:	dd45                	beqz	a0,80005e5e <exec+0xfe>
      n = PGSIZE;
    80005ea8:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005eaa:	fd49f2e3          	bgeu	s3,s4,80005e6e <exec+0x10e>
      n = sz - i;
    80005eae:	894e                	mv	s2,s3
    80005eb0:	bf7d                	j	80005e6e <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005eb2:	4481                	li	s1,0
  iunlockput(ip);
    80005eb4:	8556                	mv	a0,s5
    80005eb6:	fffff097          	auipc	ra,0xfffff
    80005eba:	c14080e7          	jalr	-1004(ra) # 80004aca <iunlockput>
  end_op();
    80005ebe:	fffff097          	auipc	ra,0xfffff
    80005ec2:	404080e7          	jalr	1028(ra) # 800052c2 <end_op>
  p = myproc();
    80005ec6:	ffffc097          	auipc	ra,0xffffc
    80005eca:	ad8080e7          	jalr	-1320(ra) # 8000199e <myproc>
    80005ece:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005ed0:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005ed4:	6785                	lui	a5,0x1
    80005ed6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005ed8:	97a6                	add	a5,a5,s1
    80005eda:	777d                	lui	a4,0xfffff
    80005edc:	8ff9                	and	a5,a5,a4
    80005ede:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005ee2:	6609                	lui	a2,0x2
    80005ee4:	963e                	add	a2,a2,a5
    80005ee6:	85be                	mv	a1,a5
    80005ee8:	855a                	mv	a0,s6
    80005eea:	ffffb097          	auipc	ra,0xffffb
    80005eee:	524080e7          	jalr	1316(ra) # 8000140e <uvmalloc>
    80005ef2:	8c2a                	mv	s8,a0
  ip = 0;
    80005ef4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005ef6:	12050e63          	beqz	a0,80006032 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005efa:	75f9                	lui	a1,0xffffe
    80005efc:	95aa                	add	a1,a1,a0
    80005efe:	855a                	mv	a0,s6
    80005f00:	ffffb097          	auipc	ra,0xffffb
    80005f04:	730080e7          	jalr	1840(ra) # 80001630 <uvmclear>
  stackbase = sp - PGSIZE;
    80005f08:	7afd                	lui	s5,0xfffff
    80005f0a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005f0c:	df043783          	ld	a5,-528(s0)
    80005f10:	6388                	ld	a0,0(a5)
    80005f12:	c925                	beqz	a0,80005f82 <exec+0x222>
    80005f14:	e9040993          	addi	s3,s0,-368
    80005f18:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005f1c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005f1e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005f20:	ffffb097          	auipc	ra,0xffffb
    80005f24:	f26080e7          	jalr	-218(ra) # 80000e46 <strlen>
    80005f28:	0015079b          	addiw	a5,a0,1
    80005f2c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005f30:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005f34:	13596363          	bltu	s2,s5,8000605a <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005f38:	df043d83          	ld	s11,-528(s0)
    80005f3c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005f40:	8552                	mv	a0,s4
    80005f42:	ffffb097          	auipc	ra,0xffffb
    80005f46:	f04080e7          	jalr	-252(ra) # 80000e46 <strlen>
    80005f4a:	0015069b          	addiw	a3,a0,1
    80005f4e:	8652                	mv	a2,s4
    80005f50:	85ca                	mv	a1,s2
    80005f52:	855a                	mv	a0,s6
    80005f54:	ffffb097          	auipc	ra,0xffffb
    80005f58:	70e080e7          	jalr	1806(ra) # 80001662 <copyout>
    80005f5c:	10054363          	bltz	a0,80006062 <exec+0x302>
    ustack[argc] = sp;
    80005f60:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005f64:	0485                	addi	s1,s1,1
    80005f66:	008d8793          	addi	a5,s11,8
    80005f6a:	def43823          	sd	a5,-528(s0)
    80005f6e:	008db503          	ld	a0,8(s11)
    80005f72:	c911                	beqz	a0,80005f86 <exec+0x226>
    if(argc >= MAXARG)
    80005f74:	09a1                	addi	s3,s3,8
    80005f76:	fb3c95e3          	bne	s9,s3,80005f20 <exec+0x1c0>
  sz = sz1;
    80005f7a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005f7e:	4a81                	li	s5,0
    80005f80:	a84d                	j	80006032 <exec+0x2d2>
  sp = sz;
    80005f82:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005f84:	4481                	li	s1,0
  ustack[argc] = 0;
    80005f86:	00349793          	slli	a5,s1,0x3
    80005f8a:	f9078793          	addi	a5,a5,-112
    80005f8e:	97a2                	add	a5,a5,s0
    80005f90:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005f94:	00148693          	addi	a3,s1,1
    80005f98:	068e                	slli	a3,a3,0x3
    80005f9a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005f9e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005fa2:	01597663          	bgeu	s2,s5,80005fae <exec+0x24e>
  sz = sz1;
    80005fa6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005faa:	4a81                	li	s5,0
    80005fac:	a059                	j	80006032 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005fae:	e9040613          	addi	a2,s0,-368
    80005fb2:	85ca                	mv	a1,s2
    80005fb4:	855a                	mv	a0,s6
    80005fb6:	ffffb097          	auipc	ra,0xffffb
    80005fba:	6ac080e7          	jalr	1708(ra) # 80001662 <copyout>
    80005fbe:	0a054663          	bltz	a0,8000606a <exec+0x30a>
  p->trapframe->a1 = sp;
    80005fc2:	060bb783          	ld	a5,96(s7)
    80005fc6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005fca:	de843783          	ld	a5,-536(s0)
    80005fce:	0007c703          	lbu	a4,0(a5)
    80005fd2:	cf11                	beqz	a4,80005fee <exec+0x28e>
    80005fd4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005fd6:	02f00693          	li	a3,47
    80005fda:	a039                	j	80005fe8 <exec+0x288>
      last = s+1;
    80005fdc:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005fe0:	0785                	addi	a5,a5,1
    80005fe2:	fff7c703          	lbu	a4,-1(a5)
    80005fe6:	c701                	beqz	a4,80005fee <exec+0x28e>
    if(*s == '/')
    80005fe8:	fed71ce3          	bne	a4,a3,80005fe0 <exec+0x280>
    80005fec:	bfc5                	j	80005fdc <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005fee:	4641                	li	a2,16
    80005ff0:	de843583          	ld	a1,-536(s0)
    80005ff4:	160b8513          	addi	a0,s7,352
    80005ff8:	ffffb097          	auipc	ra,0xffffb
    80005ffc:	e1c080e7          	jalr	-484(ra) # 80000e14 <safestrcpy>
  oldpagetable = p->pagetable;
    80006000:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80006004:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80006008:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000600c:	060bb783          	ld	a5,96(s7)
    80006010:	e6843703          	ld	a4,-408(s0)
    80006014:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80006016:	060bb783          	ld	a5,96(s7)
    8000601a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000601e:	85ea                	mv	a1,s10
    80006020:	ffffc097          	auipc	ra,0xffffc
    80006024:	b16080e7          	jalr	-1258(ra) # 80001b36 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80006028:	0004851b          	sext.w	a0,s1
    8000602c:	bbc1                	j	80005dfc <exec+0x9c>
    8000602e:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80006032:	df843583          	ld	a1,-520(s0)
    80006036:	855a                	mv	a0,s6
    80006038:	ffffc097          	auipc	ra,0xffffc
    8000603c:	afe080e7          	jalr	-1282(ra) # 80001b36 <proc_freepagetable>
  if(ip){
    80006040:	da0a94e3          	bnez	s5,80005de8 <exec+0x88>
  return -1;
    80006044:	557d                	li	a0,-1
    80006046:	bb5d                	j	80005dfc <exec+0x9c>
    80006048:	de943c23          	sd	s1,-520(s0)
    8000604c:	b7dd                	j	80006032 <exec+0x2d2>
    8000604e:	de943c23          	sd	s1,-520(s0)
    80006052:	b7c5                	j	80006032 <exec+0x2d2>
    80006054:	de943c23          	sd	s1,-520(s0)
    80006058:	bfe9                	j	80006032 <exec+0x2d2>
  sz = sz1;
    8000605a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000605e:	4a81                	li	s5,0
    80006060:	bfc9                	j	80006032 <exec+0x2d2>
  sz = sz1;
    80006062:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80006066:	4a81                	li	s5,0
    80006068:	b7e9                	j	80006032 <exec+0x2d2>
  sz = sz1;
    8000606a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000606e:	4a81                	li	s5,0
    80006070:	b7c9                	j	80006032 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006072:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006076:	e0843783          	ld	a5,-504(s0)
    8000607a:	0017869b          	addiw	a3,a5,1
    8000607e:	e0d43423          	sd	a3,-504(s0)
    80006082:	e0043783          	ld	a5,-512(s0)
    80006086:	0387879b          	addiw	a5,a5,56
    8000608a:	e8845703          	lhu	a4,-376(s0)
    8000608e:	e2e6d3e3          	bge	a3,a4,80005eb4 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006092:	2781                	sext.w	a5,a5
    80006094:	e0f43023          	sd	a5,-512(s0)
    80006098:	03800713          	li	a4,56
    8000609c:	86be                	mv	a3,a5
    8000609e:	e1840613          	addi	a2,s0,-488
    800060a2:	4581                	li	a1,0
    800060a4:	8556                	mv	a0,s5
    800060a6:	fffff097          	auipc	ra,0xfffff
    800060aa:	a76080e7          	jalr	-1418(ra) # 80004b1c <readi>
    800060ae:	03800793          	li	a5,56
    800060b2:	f6f51ee3          	bne	a0,a5,8000602e <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800060b6:	e1842783          	lw	a5,-488(s0)
    800060ba:	4705                	li	a4,1
    800060bc:	fae79de3          	bne	a5,a4,80006076 <exec+0x316>
    if(ph.memsz < ph.filesz)
    800060c0:	e4043603          	ld	a2,-448(s0)
    800060c4:	e3843783          	ld	a5,-456(s0)
    800060c8:	f8f660e3          	bltu	a2,a5,80006048 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800060cc:	e2843783          	ld	a5,-472(s0)
    800060d0:	963e                	add	a2,a2,a5
    800060d2:	f6f66ee3          	bltu	a2,a5,8000604e <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800060d6:	85a6                	mv	a1,s1
    800060d8:	855a                	mv	a0,s6
    800060da:	ffffb097          	auipc	ra,0xffffb
    800060de:	334080e7          	jalr	820(ra) # 8000140e <uvmalloc>
    800060e2:	dea43c23          	sd	a0,-520(s0)
    800060e6:	d53d                	beqz	a0,80006054 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    800060e8:	e2843c03          	ld	s8,-472(s0)
    800060ec:	de043783          	ld	a5,-544(s0)
    800060f0:	00fc77b3          	and	a5,s8,a5
    800060f4:	ff9d                	bnez	a5,80006032 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800060f6:	e2042c83          	lw	s9,-480(s0)
    800060fa:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800060fe:	f60b8ae3          	beqz	s7,80006072 <exec+0x312>
    80006102:	89de                	mv	s3,s7
    80006104:	4481                	li	s1,0
    80006106:	b371                	j	80005e92 <exec+0x132>

0000000080006108 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006108:	7179                	addi	sp,sp,-48
    8000610a:	f406                	sd	ra,40(sp)
    8000610c:	f022                	sd	s0,32(sp)
    8000610e:	ec26                	sd	s1,24(sp)
    80006110:	e84a                	sd	s2,16(sp)
    80006112:	1800                	addi	s0,sp,48
    80006114:	892e                	mv	s2,a1
    80006116:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80006118:	fdc40593          	addi	a1,s0,-36
    8000611c:	ffffe097          	auipc	ra,0xffffe
    80006120:	9c6080e7          	jalr	-1594(ra) # 80003ae2 <argint>
    80006124:	04054063          	bltz	a0,80006164 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006128:	fdc42703          	lw	a4,-36(s0)
    8000612c:	47bd                	li	a5,15
    8000612e:	02e7ed63          	bltu	a5,a4,80006168 <argfd+0x60>
    80006132:	ffffc097          	auipc	ra,0xffffc
    80006136:	86c080e7          	jalr	-1940(ra) # 8000199e <myproc>
    8000613a:	fdc42703          	lw	a4,-36(s0)
    8000613e:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd801a>
    80006142:	078e                	slli	a5,a5,0x3
    80006144:	953e                	add	a0,a0,a5
    80006146:	651c                	ld	a5,8(a0)
    80006148:	c395                	beqz	a5,8000616c <argfd+0x64>
    return -1;
  if(pfd)
    8000614a:	00090463          	beqz	s2,80006152 <argfd+0x4a>
    *pfd = fd;
    8000614e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80006152:	4501                	li	a0,0
  if(pf)
    80006154:	c091                	beqz	s1,80006158 <argfd+0x50>
    *pf = f;
    80006156:	e09c                	sd	a5,0(s1)
}
    80006158:	70a2                	ld	ra,40(sp)
    8000615a:	7402                	ld	s0,32(sp)
    8000615c:	64e2                	ld	s1,24(sp)
    8000615e:	6942                	ld	s2,16(sp)
    80006160:	6145                	addi	sp,sp,48
    80006162:	8082                	ret
    return -1;
    80006164:	557d                	li	a0,-1
    80006166:	bfcd                	j	80006158 <argfd+0x50>
    return -1;
    80006168:	557d                	li	a0,-1
    8000616a:	b7fd                	j	80006158 <argfd+0x50>
    8000616c:	557d                	li	a0,-1
    8000616e:	b7ed                	j	80006158 <argfd+0x50>

0000000080006170 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006170:	1101                	addi	sp,sp,-32
    80006172:	ec06                	sd	ra,24(sp)
    80006174:	e822                	sd	s0,16(sp)
    80006176:	e426                	sd	s1,8(sp)
    80006178:	1000                	addi	s0,sp,32
    8000617a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000617c:	ffffc097          	auipc	ra,0xffffc
    80006180:	822080e7          	jalr	-2014(ra) # 8000199e <myproc>
    80006184:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006186:	0d850793          	addi	a5,a0,216
    8000618a:	4501                	li	a0,0
    8000618c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000618e:	6398                	ld	a4,0(a5)
    80006190:	cb19                	beqz	a4,800061a6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006192:	2505                	addiw	a0,a0,1
    80006194:	07a1                	addi	a5,a5,8
    80006196:	fed51ce3          	bne	a0,a3,8000618e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000619a:	557d                	li	a0,-1
}
    8000619c:	60e2                	ld	ra,24(sp)
    8000619e:	6442                	ld	s0,16(sp)
    800061a0:	64a2                	ld	s1,8(sp)
    800061a2:	6105                	addi	sp,sp,32
    800061a4:	8082                	ret
      p->ofile[fd] = f;
    800061a6:	01a50793          	addi	a5,a0,26
    800061aa:	078e                	slli	a5,a5,0x3
    800061ac:	963e                	add	a2,a2,a5
    800061ae:	e604                	sd	s1,8(a2)
      return fd;
    800061b0:	b7f5                	j	8000619c <fdalloc+0x2c>

00000000800061b2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800061b2:	715d                	addi	sp,sp,-80
    800061b4:	e486                	sd	ra,72(sp)
    800061b6:	e0a2                	sd	s0,64(sp)
    800061b8:	fc26                	sd	s1,56(sp)
    800061ba:	f84a                	sd	s2,48(sp)
    800061bc:	f44e                	sd	s3,40(sp)
    800061be:	f052                	sd	s4,32(sp)
    800061c0:	ec56                	sd	s5,24(sp)
    800061c2:	0880                	addi	s0,sp,80
    800061c4:	89ae                	mv	s3,a1
    800061c6:	8ab2                	mv	s5,a2
    800061c8:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800061ca:	fb040593          	addi	a1,s0,-80
    800061ce:	fffff097          	auipc	ra,0xfffff
    800061d2:	e74080e7          	jalr	-396(ra) # 80005042 <nameiparent>
    800061d6:	892a                	mv	s2,a0
    800061d8:	12050e63          	beqz	a0,80006314 <create+0x162>
    return 0;

  ilock(dp);
    800061dc:	ffffe097          	auipc	ra,0xffffe
    800061e0:	68c080e7          	jalr	1676(ra) # 80004868 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800061e4:	4601                	li	a2,0
    800061e6:	fb040593          	addi	a1,s0,-80
    800061ea:	854a                	mv	a0,s2
    800061ec:	fffff097          	auipc	ra,0xfffff
    800061f0:	b60080e7          	jalr	-1184(ra) # 80004d4c <dirlookup>
    800061f4:	84aa                	mv	s1,a0
    800061f6:	c921                	beqz	a0,80006246 <create+0x94>
    iunlockput(dp);
    800061f8:	854a                	mv	a0,s2
    800061fa:	fffff097          	auipc	ra,0xfffff
    800061fe:	8d0080e7          	jalr	-1840(ra) # 80004aca <iunlockput>
    ilock(ip);
    80006202:	8526                	mv	a0,s1
    80006204:	ffffe097          	auipc	ra,0xffffe
    80006208:	664080e7          	jalr	1636(ra) # 80004868 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000620c:	2981                	sext.w	s3,s3
    8000620e:	4789                	li	a5,2
    80006210:	02f99463          	bne	s3,a5,80006238 <create+0x86>
    80006214:	0444d783          	lhu	a5,68(s1)
    80006218:	37f9                	addiw	a5,a5,-2
    8000621a:	17c2                	slli	a5,a5,0x30
    8000621c:	93c1                	srli	a5,a5,0x30
    8000621e:	4705                	li	a4,1
    80006220:	00f76c63          	bltu	a4,a5,80006238 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006224:	8526                	mv	a0,s1
    80006226:	60a6                	ld	ra,72(sp)
    80006228:	6406                	ld	s0,64(sp)
    8000622a:	74e2                	ld	s1,56(sp)
    8000622c:	7942                	ld	s2,48(sp)
    8000622e:	79a2                	ld	s3,40(sp)
    80006230:	7a02                	ld	s4,32(sp)
    80006232:	6ae2                	ld	s5,24(sp)
    80006234:	6161                	addi	sp,sp,80
    80006236:	8082                	ret
    iunlockput(ip);
    80006238:	8526                	mv	a0,s1
    8000623a:	fffff097          	auipc	ra,0xfffff
    8000623e:	890080e7          	jalr	-1904(ra) # 80004aca <iunlockput>
    return 0;
    80006242:	4481                	li	s1,0
    80006244:	b7c5                	j	80006224 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80006246:	85ce                	mv	a1,s3
    80006248:	00092503          	lw	a0,0(s2)
    8000624c:	ffffe097          	auipc	ra,0xffffe
    80006250:	482080e7          	jalr	1154(ra) # 800046ce <ialloc>
    80006254:	84aa                	mv	s1,a0
    80006256:	c521                	beqz	a0,8000629e <create+0xec>
  ilock(ip);
    80006258:	ffffe097          	auipc	ra,0xffffe
    8000625c:	610080e7          	jalr	1552(ra) # 80004868 <ilock>
  ip->major = major;
    80006260:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006264:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006268:	4a05                	li	s4,1
    8000626a:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000626e:	8526                	mv	a0,s1
    80006270:	ffffe097          	auipc	ra,0xffffe
    80006274:	52c080e7          	jalr	1324(ra) # 8000479c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006278:	2981                	sext.w	s3,s3
    8000627a:	03498a63          	beq	s3,s4,800062ae <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000627e:	40d0                	lw	a2,4(s1)
    80006280:	fb040593          	addi	a1,s0,-80
    80006284:	854a                	mv	a0,s2
    80006286:	fffff097          	auipc	ra,0xfffff
    8000628a:	cdc080e7          	jalr	-804(ra) # 80004f62 <dirlink>
    8000628e:	06054b63          	bltz	a0,80006304 <create+0x152>
  iunlockput(dp);
    80006292:	854a                	mv	a0,s2
    80006294:	fffff097          	auipc	ra,0xfffff
    80006298:	836080e7          	jalr	-1994(ra) # 80004aca <iunlockput>
  return ip;
    8000629c:	b761                	j	80006224 <create+0x72>
    panic("create: ialloc");
    8000629e:	00003517          	auipc	a0,0x3
    800062a2:	6a250513          	addi	a0,a0,1698 # 80009940 <syscalls+0x300>
    800062a6:	ffffa097          	auipc	ra,0xffffa
    800062aa:	292080e7          	jalr	658(ra) # 80000538 <panic>
    dp->nlink++;  // for ".."
    800062ae:	04a95783          	lhu	a5,74(s2)
    800062b2:	2785                	addiw	a5,a5,1
    800062b4:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800062b8:	854a                	mv	a0,s2
    800062ba:	ffffe097          	auipc	ra,0xffffe
    800062be:	4e2080e7          	jalr	1250(ra) # 8000479c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800062c2:	40d0                	lw	a2,4(s1)
    800062c4:	00003597          	auipc	a1,0x3
    800062c8:	68c58593          	addi	a1,a1,1676 # 80009950 <syscalls+0x310>
    800062cc:	8526                	mv	a0,s1
    800062ce:	fffff097          	auipc	ra,0xfffff
    800062d2:	c94080e7          	jalr	-876(ra) # 80004f62 <dirlink>
    800062d6:	00054f63          	bltz	a0,800062f4 <create+0x142>
    800062da:	00492603          	lw	a2,4(s2)
    800062de:	00003597          	auipc	a1,0x3
    800062e2:	67a58593          	addi	a1,a1,1658 # 80009958 <syscalls+0x318>
    800062e6:	8526                	mv	a0,s1
    800062e8:	fffff097          	auipc	ra,0xfffff
    800062ec:	c7a080e7          	jalr	-902(ra) # 80004f62 <dirlink>
    800062f0:	f80557e3          	bgez	a0,8000627e <create+0xcc>
      panic("create dots");
    800062f4:	00003517          	auipc	a0,0x3
    800062f8:	66c50513          	addi	a0,a0,1644 # 80009960 <syscalls+0x320>
    800062fc:	ffffa097          	auipc	ra,0xffffa
    80006300:	23c080e7          	jalr	572(ra) # 80000538 <panic>
    panic("create: dirlink");
    80006304:	00003517          	auipc	a0,0x3
    80006308:	66c50513          	addi	a0,a0,1644 # 80009970 <syscalls+0x330>
    8000630c:	ffffa097          	auipc	ra,0xffffa
    80006310:	22c080e7          	jalr	556(ra) # 80000538 <panic>
    return 0;
    80006314:	84aa                	mv	s1,a0
    80006316:	b739                	j	80006224 <create+0x72>

0000000080006318 <sys_dup>:
{
    80006318:	7179                	addi	sp,sp,-48
    8000631a:	f406                	sd	ra,40(sp)
    8000631c:	f022                	sd	s0,32(sp)
    8000631e:	ec26                	sd	s1,24(sp)
    80006320:	e84a                	sd	s2,16(sp)
    80006322:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006324:	fd840613          	addi	a2,s0,-40
    80006328:	4581                	li	a1,0
    8000632a:	4501                	li	a0,0
    8000632c:	00000097          	auipc	ra,0x0
    80006330:	ddc080e7          	jalr	-548(ra) # 80006108 <argfd>
    return -1;
    80006334:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006336:	02054363          	bltz	a0,8000635c <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000633a:	fd843903          	ld	s2,-40(s0)
    8000633e:	854a                	mv	a0,s2
    80006340:	00000097          	auipc	ra,0x0
    80006344:	e30080e7          	jalr	-464(ra) # 80006170 <fdalloc>
    80006348:	84aa                	mv	s1,a0
    return -1;
    8000634a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000634c:	00054863          	bltz	a0,8000635c <sys_dup+0x44>
  filedup(f);
    80006350:	854a                	mv	a0,s2
    80006352:	fffff097          	auipc	ra,0xfffff
    80006356:	368080e7          	jalr	872(ra) # 800056ba <filedup>
  return fd;
    8000635a:	87a6                	mv	a5,s1
}
    8000635c:	853e                	mv	a0,a5
    8000635e:	70a2                	ld	ra,40(sp)
    80006360:	7402                	ld	s0,32(sp)
    80006362:	64e2                	ld	s1,24(sp)
    80006364:	6942                	ld	s2,16(sp)
    80006366:	6145                	addi	sp,sp,48
    80006368:	8082                	ret

000000008000636a <sys_read>:
{
    8000636a:	7179                	addi	sp,sp,-48
    8000636c:	f406                	sd	ra,40(sp)
    8000636e:	f022                	sd	s0,32(sp)
    80006370:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006372:	fe840613          	addi	a2,s0,-24
    80006376:	4581                	li	a1,0
    80006378:	4501                	li	a0,0
    8000637a:	00000097          	auipc	ra,0x0
    8000637e:	d8e080e7          	jalr	-626(ra) # 80006108 <argfd>
    return -1;
    80006382:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006384:	04054163          	bltz	a0,800063c6 <sys_read+0x5c>
    80006388:	fe440593          	addi	a1,s0,-28
    8000638c:	4509                	li	a0,2
    8000638e:	ffffd097          	auipc	ra,0xffffd
    80006392:	754080e7          	jalr	1876(ra) # 80003ae2 <argint>
    return -1;
    80006396:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006398:	02054763          	bltz	a0,800063c6 <sys_read+0x5c>
    8000639c:	fd840593          	addi	a1,s0,-40
    800063a0:	4505                	li	a0,1
    800063a2:	ffffd097          	auipc	ra,0xffffd
    800063a6:	762080e7          	jalr	1890(ra) # 80003b04 <argaddr>
    return -1;
    800063aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063ac:	00054d63          	bltz	a0,800063c6 <sys_read+0x5c>
  return fileread(f, p, n);
    800063b0:	fe442603          	lw	a2,-28(s0)
    800063b4:	fd843583          	ld	a1,-40(s0)
    800063b8:	fe843503          	ld	a0,-24(s0)
    800063bc:	fffff097          	auipc	ra,0xfffff
    800063c0:	48a080e7          	jalr	1162(ra) # 80005846 <fileread>
    800063c4:	87aa                	mv	a5,a0
}
    800063c6:	853e                	mv	a0,a5
    800063c8:	70a2                	ld	ra,40(sp)
    800063ca:	7402                	ld	s0,32(sp)
    800063cc:	6145                	addi	sp,sp,48
    800063ce:	8082                	ret

00000000800063d0 <sys_write>:
{
    800063d0:	7179                	addi	sp,sp,-48
    800063d2:	f406                	sd	ra,40(sp)
    800063d4:	f022                	sd	s0,32(sp)
    800063d6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063d8:	fe840613          	addi	a2,s0,-24
    800063dc:	4581                	li	a1,0
    800063de:	4501                	li	a0,0
    800063e0:	00000097          	auipc	ra,0x0
    800063e4:	d28080e7          	jalr	-728(ra) # 80006108 <argfd>
    return -1;
    800063e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063ea:	04054163          	bltz	a0,8000642c <sys_write+0x5c>
    800063ee:	fe440593          	addi	a1,s0,-28
    800063f2:	4509                	li	a0,2
    800063f4:	ffffd097          	auipc	ra,0xffffd
    800063f8:	6ee080e7          	jalr	1774(ra) # 80003ae2 <argint>
    return -1;
    800063fc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063fe:	02054763          	bltz	a0,8000642c <sys_write+0x5c>
    80006402:	fd840593          	addi	a1,s0,-40
    80006406:	4505                	li	a0,1
    80006408:	ffffd097          	auipc	ra,0xffffd
    8000640c:	6fc080e7          	jalr	1788(ra) # 80003b04 <argaddr>
    return -1;
    80006410:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006412:	00054d63          	bltz	a0,8000642c <sys_write+0x5c>
  return filewrite(f, p, n);
    80006416:	fe442603          	lw	a2,-28(s0)
    8000641a:	fd843583          	ld	a1,-40(s0)
    8000641e:	fe843503          	ld	a0,-24(s0)
    80006422:	fffff097          	auipc	ra,0xfffff
    80006426:	4e6080e7          	jalr	1254(ra) # 80005908 <filewrite>
    8000642a:	87aa                	mv	a5,a0
}
    8000642c:	853e                	mv	a0,a5
    8000642e:	70a2                	ld	ra,40(sp)
    80006430:	7402                	ld	s0,32(sp)
    80006432:	6145                	addi	sp,sp,48
    80006434:	8082                	ret

0000000080006436 <sys_close>:
{
    80006436:	1101                	addi	sp,sp,-32
    80006438:	ec06                	sd	ra,24(sp)
    8000643a:	e822                	sd	s0,16(sp)
    8000643c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000643e:	fe040613          	addi	a2,s0,-32
    80006442:	fec40593          	addi	a1,s0,-20
    80006446:	4501                	li	a0,0
    80006448:	00000097          	auipc	ra,0x0
    8000644c:	cc0080e7          	jalr	-832(ra) # 80006108 <argfd>
    return -1;
    80006450:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006452:	02054463          	bltz	a0,8000647a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006456:	ffffb097          	auipc	ra,0xffffb
    8000645a:	548080e7          	jalr	1352(ra) # 8000199e <myproc>
    8000645e:	fec42783          	lw	a5,-20(s0)
    80006462:	07e9                	addi	a5,a5,26
    80006464:	078e                	slli	a5,a5,0x3
    80006466:	953e                	add	a0,a0,a5
    80006468:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000646c:	fe043503          	ld	a0,-32(s0)
    80006470:	fffff097          	auipc	ra,0xfffff
    80006474:	29c080e7          	jalr	668(ra) # 8000570c <fileclose>
  return 0;
    80006478:	4781                	li	a5,0
}
    8000647a:	853e                	mv	a0,a5
    8000647c:	60e2                	ld	ra,24(sp)
    8000647e:	6442                	ld	s0,16(sp)
    80006480:	6105                	addi	sp,sp,32
    80006482:	8082                	ret

0000000080006484 <sys_fstat>:
{
    80006484:	1101                	addi	sp,sp,-32
    80006486:	ec06                	sd	ra,24(sp)
    80006488:	e822                	sd	s0,16(sp)
    8000648a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000648c:	fe840613          	addi	a2,s0,-24
    80006490:	4581                	li	a1,0
    80006492:	4501                	li	a0,0
    80006494:	00000097          	auipc	ra,0x0
    80006498:	c74080e7          	jalr	-908(ra) # 80006108 <argfd>
    return -1;
    8000649c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000649e:	02054563          	bltz	a0,800064c8 <sys_fstat+0x44>
    800064a2:	fe040593          	addi	a1,s0,-32
    800064a6:	4505                	li	a0,1
    800064a8:	ffffd097          	auipc	ra,0xffffd
    800064ac:	65c080e7          	jalr	1628(ra) # 80003b04 <argaddr>
    return -1;
    800064b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800064b2:	00054b63          	bltz	a0,800064c8 <sys_fstat+0x44>
  return filestat(f, st);
    800064b6:	fe043583          	ld	a1,-32(s0)
    800064ba:	fe843503          	ld	a0,-24(s0)
    800064be:	fffff097          	auipc	ra,0xfffff
    800064c2:	316080e7          	jalr	790(ra) # 800057d4 <filestat>
    800064c6:	87aa                	mv	a5,a0
}
    800064c8:	853e                	mv	a0,a5
    800064ca:	60e2                	ld	ra,24(sp)
    800064cc:	6442                	ld	s0,16(sp)
    800064ce:	6105                	addi	sp,sp,32
    800064d0:	8082                	ret

00000000800064d2 <sys_link>:
{
    800064d2:	7169                	addi	sp,sp,-304
    800064d4:	f606                	sd	ra,296(sp)
    800064d6:	f222                	sd	s0,288(sp)
    800064d8:	ee26                	sd	s1,280(sp)
    800064da:	ea4a                	sd	s2,272(sp)
    800064dc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800064de:	08000613          	li	a2,128
    800064e2:	ed040593          	addi	a1,s0,-304
    800064e6:	4501                	li	a0,0
    800064e8:	ffffd097          	auipc	ra,0xffffd
    800064ec:	63e080e7          	jalr	1598(ra) # 80003b26 <argstr>
    return -1;
    800064f0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800064f2:	10054e63          	bltz	a0,8000660e <sys_link+0x13c>
    800064f6:	08000613          	li	a2,128
    800064fa:	f5040593          	addi	a1,s0,-176
    800064fe:	4505                	li	a0,1
    80006500:	ffffd097          	auipc	ra,0xffffd
    80006504:	626080e7          	jalr	1574(ra) # 80003b26 <argstr>
    return -1;
    80006508:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000650a:	10054263          	bltz	a0,8000660e <sys_link+0x13c>
  begin_op();
    8000650e:	fffff097          	auipc	ra,0xfffff
    80006512:	d36080e7          	jalr	-714(ra) # 80005244 <begin_op>
  if((ip = namei(old)) == 0){
    80006516:	ed040513          	addi	a0,s0,-304
    8000651a:	fffff097          	auipc	ra,0xfffff
    8000651e:	b0a080e7          	jalr	-1270(ra) # 80005024 <namei>
    80006522:	84aa                	mv	s1,a0
    80006524:	c551                	beqz	a0,800065b0 <sys_link+0xde>
  ilock(ip);
    80006526:	ffffe097          	auipc	ra,0xffffe
    8000652a:	342080e7          	jalr	834(ra) # 80004868 <ilock>
  if(ip->type == T_DIR){
    8000652e:	04449703          	lh	a4,68(s1)
    80006532:	4785                	li	a5,1
    80006534:	08f70463          	beq	a4,a5,800065bc <sys_link+0xea>
  ip->nlink++;
    80006538:	04a4d783          	lhu	a5,74(s1)
    8000653c:	2785                	addiw	a5,a5,1
    8000653e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006542:	8526                	mv	a0,s1
    80006544:	ffffe097          	auipc	ra,0xffffe
    80006548:	258080e7          	jalr	600(ra) # 8000479c <iupdate>
  iunlock(ip);
    8000654c:	8526                	mv	a0,s1
    8000654e:	ffffe097          	auipc	ra,0xffffe
    80006552:	3dc080e7          	jalr	988(ra) # 8000492a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006556:	fd040593          	addi	a1,s0,-48
    8000655a:	f5040513          	addi	a0,s0,-176
    8000655e:	fffff097          	auipc	ra,0xfffff
    80006562:	ae4080e7          	jalr	-1308(ra) # 80005042 <nameiparent>
    80006566:	892a                	mv	s2,a0
    80006568:	c935                	beqz	a0,800065dc <sys_link+0x10a>
  ilock(dp);
    8000656a:	ffffe097          	auipc	ra,0xffffe
    8000656e:	2fe080e7          	jalr	766(ra) # 80004868 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006572:	00092703          	lw	a4,0(s2)
    80006576:	409c                	lw	a5,0(s1)
    80006578:	04f71d63          	bne	a4,a5,800065d2 <sys_link+0x100>
    8000657c:	40d0                	lw	a2,4(s1)
    8000657e:	fd040593          	addi	a1,s0,-48
    80006582:	854a                	mv	a0,s2
    80006584:	fffff097          	auipc	ra,0xfffff
    80006588:	9de080e7          	jalr	-1570(ra) # 80004f62 <dirlink>
    8000658c:	04054363          	bltz	a0,800065d2 <sys_link+0x100>
  iunlockput(dp);
    80006590:	854a                	mv	a0,s2
    80006592:	ffffe097          	auipc	ra,0xffffe
    80006596:	538080e7          	jalr	1336(ra) # 80004aca <iunlockput>
  iput(ip);
    8000659a:	8526                	mv	a0,s1
    8000659c:	ffffe097          	auipc	ra,0xffffe
    800065a0:	486080e7          	jalr	1158(ra) # 80004a22 <iput>
  end_op();
    800065a4:	fffff097          	auipc	ra,0xfffff
    800065a8:	d1e080e7          	jalr	-738(ra) # 800052c2 <end_op>
  return 0;
    800065ac:	4781                	li	a5,0
    800065ae:	a085                	j	8000660e <sys_link+0x13c>
    end_op();
    800065b0:	fffff097          	auipc	ra,0xfffff
    800065b4:	d12080e7          	jalr	-750(ra) # 800052c2 <end_op>
    return -1;
    800065b8:	57fd                	li	a5,-1
    800065ba:	a891                	j	8000660e <sys_link+0x13c>
    iunlockput(ip);
    800065bc:	8526                	mv	a0,s1
    800065be:	ffffe097          	auipc	ra,0xffffe
    800065c2:	50c080e7          	jalr	1292(ra) # 80004aca <iunlockput>
    end_op();
    800065c6:	fffff097          	auipc	ra,0xfffff
    800065ca:	cfc080e7          	jalr	-772(ra) # 800052c2 <end_op>
    return -1;
    800065ce:	57fd                	li	a5,-1
    800065d0:	a83d                	j	8000660e <sys_link+0x13c>
    iunlockput(dp);
    800065d2:	854a                	mv	a0,s2
    800065d4:	ffffe097          	auipc	ra,0xffffe
    800065d8:	4f6080e7          	jalr	1270(ra) # 80004aca <iunlockput>
  ilock(ip);
    800065dc:	8526                	mv	a0,s1
    800065de:	ffffe097          	auipc	ra,0xffffe
    800065e2:	28a080e7          	jalr	650(ra) # 80004868 <ilock>
  ip->nlink--;
    800065e6:	04a4d783          	lhu	a5,74(s1)
    800065ea:	37fd                	addiw	a5,a5,-1
    800065ec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800065f0:	8526                	mv	a0,s1
    800065f2:	ffffe097          	auipc	ra,0xffffe
    800065f6:	1aa080e7          	jalr	426(ra) # 8000479c <iupdate>
  iunlockput(ip);
    800065fa:	8526                	mv	a0,s1
    800065fc:	ffffe097          	auipc	ra,0xffffe
    80006600:	4ce080e7          	jalr	1230(ra) # 80004aca <iunlockput>
  end_op();
    80006604:	fffff097          	auipc	ra,0xfffff
    80006608:	cbe080e7          	jalr	-834(ra) # 800052c2 <end_op>
  return -1;
    8000660c:	57fd                	li	a5,-1
}
    8000660e:	853e                	mv	a0,a5
    80006610:	70b2                	ld	ra,296(sp)
    80006612:	7412                	ld	s0,288(sp)
    80006614:	64f2                	ld	s1,280(sp)
    80006616:	6952                	ld	s2,272(sp)
    80006618:	6155                	addi	sp,sp,304
    8000661a:	8082                	ret

000000008000661c <sys_unlink>:
{
    8000661c:	7151                	addi	sp,sp,-240
    8000661e:	f586                	sd	ra,232(sp)
    80006620:	f1a2                	sd	s0,224(sp)
    80006622:	eda6                	sd	s1,216(sp)
    80006624:	e9ca                	sd	s2,208(sp)
    80006626:	e5ce                	sd	s3,200(sp)
    80006628:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000662a:	08000613          	li	a2,128
    8000662e:	f3040593          	addi	a1,s0,-208
    80006632:	4501                	li	a0,0
    80006634:	ffffd097          	auipc	ra,0xffffd
    80006638:	4f2080e7          	jalr	1266(ra) # 80003b26 <argstr>
    8000663c:	18054163          	bltz	a0,800067be <sys_unlink+0x1a2>
  begin_op();
    80006640:	fffff097          	auipc	ra,0xfffff
    80006644:	c04080e7          	jalr	-1020(ra) # 80005244 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006648:	fb040593          	addi	a1,s0,-80
    8000664c:	f3040513          	addi	a0,s0,-208
    80006650:	fffff097          	auipc	ra,0xfffff
    80006654:	9f2080e7          	jalr	-1550(ra) # 80005042 <nameiparent>
    80006658:	84aa                	mv	s1,a0
    8000665a:	c979                	beqz	a0,80006730 <sys_unlink+0x114>
  ilock(dp);
    8000665c:	ffffe097          	auipc	ra,0xffffe
    80006660:	20c080e7          	jalr	524(ra) # 80004868 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006664:	00003597          	auipc	a1,0x3
    80006668:	2ec58593          	addi	a1,a1,748 # 80009950 <syscalls+0x310>
    8000666c:	fb040513          	addi	a0,s0,-80
    80006670:	ffffe097          	auipc	ra,0xffffe
    80006674:	6c2080e7          	jalr	1730(ra) # 80004d32 <namecmp>
    80006678:	14050a63          	beqz	a0,800067cc <sys_unlink+0x1b0>
    8000667c:	00003597          	auipc	a1,0x3
    80006680:	2dc58593          	addi	a1,a1,732 # 80009958 <syscalls+0x318>
    80006684:	fb040513          	addi	a0,s0,-80
    80006688:	ffffe097          	auipc	ra,0xffffe
    8000668c:	6aa080e7          	jalr	1706(ra) # 80004d32 <namecmp>
    80006690:	12050e63          	beqz	a0,800067cc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006694:	f2c40613          	addi	a2,s0,-212
    80006698:	fb040593          	addi	a1,s0,-80
    8000669c:	8526                	mv	a0,s1
    8000669e:	ffffe097          	auipc	ra,0xffffe
    800066a2:	6ae080e7          	jalr	1710(ra) # 80004d4c <dirlookup>
    800066a6:	892a                	mv	s2,a0
    800066a8:	12050263          	beqz	a0,800067cc <sys_unlink+0x1b0>
  ilock(ip);
    800066ac:	ffffe097          	auipc	ra,0xffffe
    800066b0:	1bc080e7          	jalr	444(ra) # 80004868 <ilock>
  if(ip->nlink < 1)
    800066b4:	04a91783          	lh	a5,74(s2)
    800066b8:	08f05263          	blez	a5,8000673c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800066bc:	04491703          	lh	a4,68(s2)
    800066c0:	4785                	li	a5,1
    800066c2:	08f70563          	beq	a4,a5,8000674c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800066c6:	4641                	li	a2,16
    800066c8:	4581                	li	a1,0
    800066ca:	fc040513          	addi	a0,s0,-64
    800066ce:	ffffa097          	auipc	ra,0xffffa
    800066d2:	5fc080e7          	jalr	1532(ra) # 80000cca <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800066d6:	4741                	li	a4,16
    800066d8:	f2c42683          	lw	a3,-212(s0)
    800066dc:	fc040613          	addi	a2,s0,-64
    800066e0:	4581                	li	a1,0
    800066e2:	8526                	mv	a0,s1
    800066e4:	ffffe097          	auipc	ra,0xffffe
    800066e8:	530080e7          	jalr	1328(ra) # 80004c14 <writei>
    800066ec:	47c1                	li	a5,16
    800066ee:	0af51563          	bne	a0,a5,80006798 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800066f2:	04491703          	lh	a4,68(s2)
    800066f6:	4785                	li	a5,1
    800066f8:	0af70863          	beq	a4,a5,800067a8 <sys_unlink+0x18c>
  iunlockput(dp);
    800066fc:	8526                	mv	a0,s1
    800066fe:	ffffe097          	auipc	ra,0xffffe
    80006702:	3cc080e7          	jalr	972(ra) # 80004aca <iunlockput>
  ip->nlink--;
    80006706:	04a95783          	lhu	a5,74(s2)
    8000670a:	37fd                	addiw	a5,a5,-1
    8000670c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006710:	854a                	mv	a0,s2
    80006712:	ffffe097          	auipc	ra,0xffffe
    80006716:	08a080e7          	jalr	138(ra) # 8000479c <iupdate>
  iunlockput(ip);
    8000671a:	854a                	mv	a0,s2
    8000671c:	ffffe097          	auipc	ra,0xffffe
    80006720:	3ae080e7          	jalr	942(ra) # 80004aca <iunlockput>
  end_op();
    80006724:	fffff097          	auipc	ra,0xfffff
    80006728:	b9e080e7          	jalr	-1122(ra) # 800052c2 <end_op>
  return 0;
    8000672c:	4501                	li	a0,0
    8000672e:	a84d                	j	800067e0 <sys_unlink+0x1c4>
    end_op();
    80006730:	fffff097          	auipc	ra,0xfffff
    80006734:	b92080e7          	jalr	-1134(ra) # 800052c2 <end_op>
    return -1;
    80006738:	557d                	li	a0,-1
    8000673a:	a05d                	j	800067e0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000673c:	00003517          	auipc	a0,0x3
    80006740:	24450513          	addi	a0,a0,580 # 80009980 <syscalls+0x340>
    80006744:	ffffa097          	auipc	ra,0xffffa
    80006748:	df4080e7          	jalr	-524(ra) # 80000538 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000674c:	04c92703          	lw	a4,76(s2)
    80006750:	02000793          	li	a5,32
    80006754:	f6e7f9e3          	bgeu	a5,a4,800066c6 <sys_unlink+0xaa>
    80006758:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000675c:	4741                	li	a4,16
    8000675e:	86ce                	mv	a3,s3
    80006760:	f1840613          	addi	a2,s0,-232
    80006764:	4581                	li	a1,0
    80006766:	854a                	mv	a0,s2
    80006768:	ffffe097          	auipc	ra,0xffffe
    8000676c:	3b4080e7          	jalr	948(ra) # 80004b1c <readi>
    80006770:	47c1                	li	a5,16
    80006772:	00f51b63          	bne	a0,a5,80006788 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006776:	f1845783          	lhu	a5,-232(s0)
    8000677a:	e7a1                	bnez	a5,800067c2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000677c:	29c1                	addiw	s3,s3,16
    8000677e:	04c92783          	lw	a5,76(s2)
    80006782:	fcf9ede3          	bltu	s3,a5,8000675c <sys_unlink+0x140>
    80006786:	b781                	j	800066c6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006788:	00003517          	auipc	a0,0x3
    8000678c:	21050513          	addi	a0,a0,528 # 80009998 <syscalls+0x358>
    80006790:	ffffa097          	auipc	ra,0xffffa
    80006794:	da8080e7          	jalr	-600(ra) # 80000538 <panic>
    panic("unlink: writei");
    80006798:	00003517          	auipc	a0,0x3
    8000679c:	21850513          	addi	a0,a0,536 # 800099b0 <syscalls+0x370>
    800067a0:	ffffa097          	auipc	ra,0xffffa
    800067a4:	d98080e7          	jalr	-616(ra) # 80000538 <panic>
    dp->nlink--;
    800067a8:	04a4d783          	lhu	a5,74(s1)
    800067ac:	37fd                	addiw	a5,a5,-1
    800067ae:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800067b2:	8526                	mv	a0,s1
    800067b4:	ffffe097          	auipc	ra,0xffffe
    800067b8:	fe8080e7          	jalr	-24(ra) # 8000479c <iupdate>
    800067bc:	b781                	j	800066fc <sys_unlink+0xe0>
    return -1;
    800067be:	557d                	li	a0,-1
    800067c0:	a005                	j	800067e0 <sys_unlink+0x1c4>
    iunlockput(ip);
    800067c2:	854a                	mv	a0,s2
    800067c4:	ffffe097          	auipc	ra,0xffffe
    800067c8:	306080e7          	jalr	774(ra) # 80004aca <iunlockput>
  iunlockput(dp);
    800067cc:	8526                	mv	a0,s1
    800067ce:	ffffe097          	auipc	ra,0xffffe
    800067d2:	2fc080e7          	jalr	764(ra) # 80004aca <iunlockput>
  end_op();
    800067d6:	fffff097          	auipc	ra,0xfffff
    800067da:	aec080e7          	jalr	-1300(ra) # 800052c2 <end_op>
  return -1;
    800067de:	557d                	li	a0,-1
}
    800067e0:	70ae                	ld	ra,232(sp)
    800067e2:	740e                	ld	s0,224(sp)
    800067e4:	64ee                	ld	s1,216(sp)
    800067e6:	694e                	ld	s2,208(sp)
    800067e8:	69ae                	ld	s3,200(sp)
    800067ea:	616d                	addi	sp,sp,240
    800067ec:	8082                	ret

00000000800067ee <sys_open>:

uint64
sys_open(void)
{
    800067ee:	7131                	addi	sp,sp,-192
    800067f0:	fd06                	sd	ra,184(sp)
    800067f2:	f922                	sd	s0,176(sp)
    800067f4:	f526                	sd	s1,168(sp)
    800067f6:	f14a                	sd	s2,160(sp)
    800067f8:	ed4e                	sd	s3,152(sp)
    800067fa:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800067fc:	08000613          	li	a2,128
    80006800:	f5040593          	addi	a1,s0,-176
    80006804:	4501                	li	a0,0
    80006806:	ffffd097          	auipc	ra,0xffffd
    8000680a:	320080e7          	jalr	800(ra) # 80003b26 <argstr>
    return -1;
    8000680e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006810:	0c054163          	bltz	a0,800068d2 <sys_open+0xe4>
    80006814:	f4c40593          	addi	a1,s0,-180
    80006818:	4505                	li	a0,1
    8000681a:	ffffd097          	auipc	ra,0xffffd
    8000681e:	2c8080e7          	jalr	712(ra) # 80003ae2 <argint>
    80006822:	0a054863          	bltz	a0,800068d2 <sys_open+0xe4>

  begin_op();
    80006826:	fffff097          	auipc	ra,0xfffff
    8000682a:	a1e080e7          	jalr	-1506(ra) # 80005244 <begin_op>

  if(omode & O_CREATE){
    8000682e:	f4c42783          	lw	a5,-180(s0)
    80006832:	2007f793          	andi	a5,a5,512
    80006836:	cbdd                	beqz	a5,800068ec <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006838:	4681                	li	a3,0
    8000683a:	4601                	li	a2,0
    8000683c:	4589                	li	a1,2
    8000683e:	f5040513          	addi	a0,s0,-176
    80006842:	00000097          	auipc	ra,0x0
    80006846:	970080e7          	jalr	-1680(ra) # 800061b2 <create>
    8000684a:	892a                	mv	s2,a0
    if(ip == 0){
    8000684c:	c959                	beqz	a0,800068e2 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000684e:	04491703          	lh	a4,68(s2)
    80006852:	478d                	li	a5,3
    80006854:	00f71763          	bne	a4,a5,80006862 <sys_open+0x74>
    80006858:	04695703          	lhu	a4,70(s2)
    8000685c:	47a5                	li	a5,9
    8000685e:	0ce7ec63          	bltu	a5,a4,80006936 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006862:	fffff097          	auipc	ra,0xfffff
    80006866:	dee080e7          	jalr	-530(ra) # 80005650 <filealloc>
    8000686a:	89aa                	mv	s3,a0
    8000686c:	10050263          	beqz	a0,80006970 <sys_open+0x182>
    80006870:	00000097          	auipc	ra,0x0
    80006874:	900080e7          	jalr	-1792(ra) # 80006170 <fdalloc>
    80006878:	84aa                	mv	s1,a0
    8000687a:	0e054663          	bltz	a0,80006966 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000687e:	04491703          	lh	a4,68(s2)
    80006882:	478d                	li	a5,3
    80006884:	0cf70463          	beq	a4,a5,8000694c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006888:	4789                	li	a5,2
    8000688a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000688e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006892:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006896:	f4c42783          	lw	a5,-180(s0)
    8000689a:	0017c713          	xori	a4,a5,1
    8000689e:	8b05                	andi	a4,a4,1
    800068a0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800068a4:	0037f713          	andi	a4,a5,3
    800068a8:	00e03733          	snez	a4,a4
    800068ac:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800068b0:	4007f793          	andi	a5,a5,1024
    800068b4:	c791                	beqz	a5,800068c0 <sys_open+0xd2>
    800068b6:	04491703          	lh	a4,68(s2)
    800068ba:	4789                	li	a5,2
    800068bc:	08f70f63          	beq	a4,a5,8000695a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800068c0:	854a                	mv	a0,s2
    800068c2:	ffffe097          	auipc	ra,0xffffe
    800068c6:	068080e7          	jalr	104(ra) # 8000492a <iunlock>
  end_op();
    800068ca:	fffff097          	auipc	ra,0xfffff
    800068ce:	9f8080e7          	jalr	-1544(ra) # 800052c2 <end_op>

  return fd;
}
    800068d2:	8526                	mv	a0,s1
    800068d4:	70ea                	ld	ra,184(sp)
    800068d6:	744a                	ld	s0,176(sp)
    800068d8:	74aa                	ld	s1,168(sp)
    800068da:	790a                	ld	s2,160(sp)
    800068dc:	69ea                	ld	s3,152(sp)
    800068de:	6129                	addi	sp,sp,192
    800068e0:	8082                	ret
      end_op();
    800068e2:	fffff097          	auipc	ra,0xfffff
    800068e6:	9e0080e7          	jalr	-1568(ra) # 800052c2 <end_op>
      return -1;
    800068ea:	b7e5                	j	800068d2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800068ec:	f5040513          	addi	a0,s0,-176
    800068f0:	ffffe097          	auipc	ra,0xffffe
    800068f4:	734080e7          	jalr	1844(ra) # 80005024 <namei>
    800068f8:	892a                	mv	s2,a0
    800068fa:	c905                	beqz	a0,8000692a <sys_open+0x13c>
    ilock(ip);
    800068fc:	ffffe097          	auipc	ra,0xffffe
    80006900:	f6c080e7          	jalr	-148(ra) # 80004868 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006904:	04491703          	lh	a4,68(s2)
    80006908:	4785                	li	a5,1
    8000690a:	f4f712e3          	bne	a4,a5,8000684e <sys_open+0x60>
    8000690e:	f4c42783          	lw	a5,-180(s0)
    80006912:	dba1                	beqz	a5,80006862 <sys_open+0x74>
      iunlockput(ip);
    80006914:	854a                	mv	a0,s2
    80006916:	ffffe097          	auipc	ra,0xffffe
    8000691a:	1b4080e7          	jalr	436(ra) # 80004aca <iunlockput>
      end_op();
    8000691e:	fffff097          	auipc	ra,0xfffff
    80006922:	9a4080e7          	jalr	-1628(ra) # 800052c2 <end_op>
      return -1;
    80006926:	54fd                	li	s1,-1
    80006928:	b76d                	j	800068d2 <sys_open+0xe4>
      end_op();
    8000692a:	fffff097          	auipc	ra,0xfffff
    8000692e:	998080e7          	jalr	-1640(ra) # 800052c2 <end_op>
      return -1;
    80006932:	54fd                	li	s1,-1
    80006934:	bf79                	j	800068d2 <sys_open+0xe4>
    iunlockput(ip);
    80006936:	854a                	mv	a0,s2
    80006938:	ffffe097          	auipc	ra,0xffffe
    8000693c:	192080e7          	jalr	402(ra) # 80004aca <iunlockput>
    end_op();
    80006940:	fffff097          	auipc	ra,0xfffff
    80006944:	982080e7          	jalr	-1662(ra) # 800052c2 <end_op>
    return -1;
    80006948:	54fd                	li	s1,-1
    8000694a:	b761                	j	800068d2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000694c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006950:	04691783          	lh	a5,70(s2)
    80006954:	02f99223          	sh	a5,36(s3)
    80006958:	bf2d                	j	80006892 <sys_open+0xa4>
    itrunc(ip);
    8000695a:	854a                	mv	a0,s2
    8000695c:	ffffe097          	auipc	ra,0xffffe
    80006960:	01a080e7          	jalr	26(ra) # 80004976 <itrunc>
    80006964:	bfb1                	j	800068c0 <sys_open+0xd2>
      fileclose(f);
    80006966:	854e                	mv	a0,s3
    80006968:	fffff097          	auipc	ra,0xfffff
    8000696c:	da4080e7          	jalr	-604(ra) # 8000570c <fileclose>
    iunlockput(ip);
    80006970:	854a                	mv	a0,s2
    80006972:	ffffe097          	auipc	ra,0xffffe
    80006976:	158080e7          	jalr	344(ra) # 80004aca <iunlockput>
    end_op();
    8000697a:	fffff097          	auipc	ra,0xfffff
    8000697e:	948080e7          	jalr	-1720(ra) # 800052c2 <end_op>
    return -1;
    80006982:	54fd                	li	s1,-1
    80006984:	b7b9                	j	800068d2 <sys_open+0xe4>

0000000080006986 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006986:	7175                	addi	sp,sp,-144
    80006988:	e506                	sd	ra,136(sp)
    8000698a:	e122                	sd	s0,128(sp)
    8000698c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000698e:	fffff097          	auipc	ra,0xfffff
    80006992:	8b6080e7          	jalr	-1866(ra) # 80005244 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006996:	08000613          	li	a2,128
    8000699a:	f7040593          	addi	a1,s0,-144
    8000699e:	4501                	li	a0,0
    800069a0:	ffffd097          	auipc	ra,0xffffd
    800069a4:	186080e7          	jalr	390(ra) # 80003b26 <argstr>
    800069a8:	02054963          	bltz	a0,800069da <sys_mkdir+0x54>
    800069ac:	4681                	li	a3,0
    800069ae:	4601                	li	a2,0
    800069b0:	4585                	li	a1,1
    800069b2:	f7040513          	addi	a0,s0,-144
    800069b6:	fffff097          	auipc	ra,0xfffff
    800069ba:	7fc080e7          	jalr	2044(ra) # 800061b2 <create>
    800069be:	cd11                	beqz	a0,800069da <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800069c0:	ffffe097          	auipc	ra,0xffffe
    800069c4:	10a080e7          	jalr	266(ra) # 80004aca <iunlockput>
  end_op();
    800069c8:	fffff097          	auipc	ra,0xfffff
    800069cc:	8fa080e7          	jalr	-1798(ra) # 800052c2 <end_op>
  return 0;
    800069d0:	4501                	li	a0,0
}
    800069d2:	60aa                	ld	ra,136(sp)
    800069d4:	640a                	ld	s0,128(sp)
    800069d6:	6149                	addi	sp,sp,144
    800069d8:	8082                	ret
    end_op();
    800069da:	fffff097          	auipc	ra,0xfffff
    800069de:	8e8080e7          	jalr	-1816(ra) # 800052c2 <end_op>
    return -1;
    800069e2:	557d                	li	a0,-1
    800069e4:	b7fd                	j	800069d2 <sys_mkdir+0x4c>

00000000800069e6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800069e6:	7135                	addi	sp,sp,-160
    800069e8:	ed06                	sd	ra,152(sp)
    800069ea:	e922                	sd	s0,144(sp)
    800069ec:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800069ee:	fffff097          	auipc	ra,0xfffff
    800069f2:	856080e7          	jalr	-1962(ra) # 80005244 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800069f6:	08000613          	li	a2,128
    800069fa:	f7040593          	addi	a1,s0,-144
    800069fe:	4501                	li	a0,0
    80006a00:	ffffd097          	auipc	ra,0xffffd
    80006a04:	126080e7          	jalr	294(ra) # 80003b26 <argstr>
    80006a08:	04054a63          	bltz	a0,80006a5c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006a0c:	f6c40593          	addi	a1,s0,-148
    80006a10:	4505                	li	a0,1
    80006a12:	ffffd097          	auipc	ra,0xffffd
    80006a16:	0d0080e7          	jalr	208(ra) # 80003ae2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006a1a:	04054163          	bltz	a0,80006a5c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006a1e:	f6840593          	addi	a1,s0,-152
    80006a22:	4509                	li	a0,2
    80006a24:	ffffd097          	auipc	ra,0xffffd
    80006a28:	0be080e7          	jalr	190(ra) # 80003ae2 <argint>
     argint(1, &major) < 0 ||
    80006a2c:	02054863          	bltz	a0,80006a5c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006a30:	f6841683          	lh	a3,-152(s0)
    80006a34:	f6c41603          	lh	a2,-148(s0)
    80006a38:	458d                	li	a1,3
    80006a3a:	f7040513          	addi	a0,s0,-144
    80006a3e:	fffff097          	auipc	ra,0xfffff
    80006a42:	774080e7          	jalr	1908(ra) # 800061b2 <create>
     argint(2, &minor) < 0 ||
    80006a46:	c919                	beqz	a0,80006a5c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006a48:	ffffe097          	auipc	ra,0xffffe
    80006a4c:	082080e7          	jalr	130(ra) # 80004aca <iunlockput>
  end_op();
    80006a50:	fffff097          	auipc	ra,0xfffff
    80006a54:	872080e7          	jalr	-1934(ra) # 800052c2 <end_op>
  return 0;
    80006a58:	4501                	li	a0,0
    80006a5a:	a031                	j	80006a66 <sys_mknod+0x80>
    end_op();
    80006a5c:	fffff097          	auipc	ra,0xfffff
    80006a60:	866080e7          	jalr	-1946(ra) # 800052c2 <end_op>
    return -1;
    80006a64:	557d                	li	a0,-1
}
    80006a66:	60ea                	ld	ra,152(sp)
    80006a68:	644a                	ld	s0,144(sp)
    80006a6a:	610d                	addi	sp,sp,160
    80006a6c:	8082                	ret

0000000080006a6e <sys_chdir>:

uint64
sys_chdir(void)
{
    80006a6e:	7135                	addi	sp,sp,-160
    80006a70:	ed06                	sd	ra,152(sp)
    80006a72:	e922                	sd	s0,144(sp)
    80006a74:	e526                	sd	s1,136(sp)
    80006a76:	e14a                	sd	s2,128(sp)
    80006a78:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006a7a:	ffffb097          	auipc	ra,0xffffb
    80006a7e:	f24080e7          	jalr	-220(ra) # 8000199e <myproc>
    80006a82:	892a                	mv	s2,a0
  
  begin_op();
    80006a84:	ffffe097          	auipc	ra,0xffffe
    80006a88:	7c0080e7          	jalr	1984(ra) # 80005244 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006a8c:	08000613          	li	a2,128
    80006a90:	f6040593          	addi	a1,s0,-160
    80006a94:	4501                	li	a0,0
    80006a96:	ffffd097          	auipc	ra,0xffffd
    80006a9a:	090080e7          	jalr	144(ra) # 80003b26 <argstr>
    80006a9e:	04054b63          	bltz	a0,80006af4 <sys_chdir+0x86>
    80006aa2:	f6040513          	addi	a0,s0,-160
    80006aa6:	ffffe097          	auipc	ra,0xffffe
    80006aaa:	57e080e7          	jalr	1406(ra) # 80005024 <namei>
    80006aae:	84aa                	mv	s1,a0
    80006ab0:	c131                	beqz	a0,80006af4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006ab2:	ffffe097          	auipc	ra,0xffffe
    80006ab6:	db6080e7          	jalr	-586(ra) # 80004868 <ilock>
  if(ip->type != T_DIR){
    80006aba:	04449703          	lh	a4,68(s1)
    80006abe:	4785                	li	a5,1
    80006ac0:	04f71063          	bne	a4,a5,80006b00 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006ac4:	8526                	mv	a0,s1
    80006ac6:	ffffe097          	auipc	ra,0xffffe
    80006aca:	e64080e7          	jalr	-412(ra) # 8000492a <iunlock>
  iput(p->cwd);
    80006ace:	15893503          	ld	a0,344(s2)
    80006ad2:	ffffe097          	auipc	ra,0xffffe
    80006ad6:	f50080e7          	jalr	-176(ra) # 80004a22 <iput>
  end_op();
    80006ada:	ffffe097          	auipc	ra,0xffffe
    80006ade:	7e8080e7          	jalr	2024(ra) # 800052c2 <end_op>
  p->cwd = ip;
    80006ae2:	14993c23          	sd	s1,344(s2)
  return 0;
    80006ae6:	4501                	li	a0,0
}
    80006ae8:	60ea                	ld	ra,152(sp)
    80006aea:	644a                	ld	s0,144(sp)
    80006aec:	64aa                	ld	s1,136(sp)
    80006aee:	690a                	ld	s2,128(sp)
    80006af0:	610d                	addi	sp,sp,160
    80006af2:	8082                	ret
    end_op();
    80006af4:	ffffe097          	auipc	ra,0xffffe
    80006af8:	7ce080e7          	jalr	1998(ra) # 800052c2 <end_op>
    return -1;
    80006afc:	557d                	li	a0,-1
    80006afe:	b7ed                	j	80006ae8 <sys_chdir+0x7a>
    iunlockput(ip);
    80006b00:	8526                	mv	a0,s1
    80006b02:	ffffe097          	auipc	ra,0xffffe
    80006b06:	fc8080e7          	jalr	-56(ra) # 80004aca <iunlockput>
    end_op();
    80006b0a:	ffffe097          	auipc	ra,0xffffe
    80006b0e:	7b8080e7          	jalr	1976(ra) # 800052c2 <end_op>
    return -1;
    80006b12:	557d                	li	a0,-1
    80006b14:	bfd1                	j	80006ae8 <sys_chdir+0x7a>

0000000080006b16 <sys_exec>:

uint64
sys_exec(void)
{
    80006b16:	7145                	addi	sp,sp,-464
    80006b18:	e786                	sd	ra,456(sp)
    80006b1a:	e3a2                	sd	s0,448(sp)
    80006b1c:	ff26                	sd	s1,440(sp)
    80006b1e:	fb4a                	sd	s2,432(sp)
    80006b20:	f74e                	sd	s3,424(sp)
    80006b22:	f352                	sd	s4,416(sp)
    80006b24:	ef56                	sd	s5,408(sp)
    80006b26:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006b28:	08000613          	li	a2,128
    80006b2c:	f4040593          	addi	a1,s0,-192
    80006b30:	4501                	li	a0,0
    80006b32:	ffffd097          	auipc	ra,0xffffd
    80006b36:	ff4080e7          	jalr	-12(ra) # 80003b26 <argstr>
    return -1;
    80006b3a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006b3c:	0c054b63          	bltz	a0,80006c12 <sys_exec+0xfc>
    80006b40:	e3840593          	addi	a1,s0,-456
    80006b44:	4505                	li	a0,1
    80006b46:	ffffd097          	auipc	ra,0xffffd
    80006b4a:	fbe080e7          	jalr	-66(ra) # 80003b04 <argaddr>
    80006b4e:	0c054263          	bltz	a0,80006c12 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80006b52:	10000613          	li	a2,256
    80006b56:	4581                	li	a1,0
    80006b58:	e4040513          	addi	a0,s0,-448
    80006b5c:	ffffa097          	auipc	ra,0xffffa
    80006b60:	16e080e7          	jalr	366(ra) # 80000cca <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006b64:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006b68:	89a6                	mv	s3,s1
    80006b6a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006b6c:	02000a13          	li	s4,32
    80006b70:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006b74:	00391513          	slli	a0,s2,0x3
    80006b78:	e3040593          	addi	a1,s0,-464
    80006b7c:	e3843783          	ld	a5,-456(s0)
    80006b80:	953e                	add	a0,a0,a5
    80006b82:	ffffd097          	auipc	ra,0xffffd
    80006b86:	ec6080e7          	jalr	-314(ra) # 80003a48 <fetchaddr>
    80006b8a:	02054a63          	bltz	a0,80006bbe <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006b8e:	e3043783          	ld	a5,-464(s0)
    80006b92:	c3b9                	beqz	a5,80006bd8 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006b94:	ffffa097          	auipc	ra,0xffffa
    80006b98:	f4a080e7          	jalr	-182(ra) # 80000ade <kalloc>
    80006b9c:	85aa                	mv	a1,a0
    80006b9e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006ba2:	cd11                	beqz	a0,80006bbe <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006ba4:	6605                	lui	a2,0x1
    80006ba6:	e3043503          	ld	a0,-464(s0)
    80006baa:	ffffd097          	auipc	ra,0xffffd
    80006bae:	ef0080e7          	jalr	-272(ra) # 80003a9a <fetchstr>
    80006bb2:	00054663          	bltz	a0,80006bbe <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006bb6:	0905                	addi	s2,s2,1
    80006bb8:	09a1                	addi	s3,s3,8
    80006bba:	fb491be3          	bne	s2,s4,80006b70 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006bbe:	f4040913          	addi	s2,s0,-192
    80006bc2:	6088                	ld	a0,0(s1)
    80006bc4:	c531                	beqz	a0,80006c10 <sys_exec+0xfa>
    kfree(argv[i]);
    80006bc6:	ffffa097          	auipc	ra,0xffffa
    80006bca:	e1a080e7          	jalr	-486(ra) # 800009e0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006bce:	04a1                	addi	s1,s1,8
    80006bd0:	ff2499e3          	bne	s1,s2,80006bc2 <sys_exec+0xac>
  return -1;
    80006bd4:	597d                	li	s2,-1
    80006bd6:	a835                	j	80006c12 <sys_exec+0xfc>
      argv[i] = 0;
    80006bd8:	0a8e                	slli	s5,s5,0x3
    80006bda:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd7fc0>
    80006bde:	00878ab3          	add	s5,a5,s0
    80006be2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006be6:	e4040593          	addi	a1,s0,-448
    80006bea:	f4040513          	addi	a0,s0,-192
    80006bee:	fffff097          	auipc	ra,0xfffff
    80006bf2:	172080e7          	jalr	370(ra) # 80005d60 <exec>
    80006bf6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006bf8:	f4040993          	addi	s3,s0,-192
    80006bfc:	6088                	ld	a0,0(s1)
    80006bfe:	c911                	beqz	a0,80006c12 <sys_exec+0xfc>
    kfree(argv[i]);
    80006c00:	ffffa097          	auipc	ra,0xffffa
    80006c04:	de0080e7          	jalr	-544(ra) # 800009e0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006c08:	04a1                	addi	s1,s1,8
    80006c0a:	ff3499e3          	bne	s1,s3,80006bfc <sys_exec+0xe6>
    80006c0e:	a011                	j	80006c12 <sys_exec+0xfc>
  return -1;
    80006c10:	597d                	li	s2,-1
}
    80006c12:	854a                	mv	a0,s2
    80006c14:	60be                	ld	ra,456(sp)
    80006c16:	641e                	ld	s0,448(sp)
    80006c18:	74fa                	ld	s1,440(sp)
    80006c1a:	795a                	ld	s2,432(sp)
    80006c1c:	79ba                	ld	s3,424(sp)
    80006c1e:	7a1a                	ld	s4,416(sp)
    80006c20:	6afa                	ld	s5,408(sp)
    80006c22:	6179                	addi	sp,sp,464
    80006c24:	8082                	ret

0000000080006c26 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006c26:	7139                	addi	sp,sp,-64
    80006c28:	fc06                	sd	ra,56(sp)
    80006c2a:	f822                	sd	s0,48(sp)
    80006c2c:	f426                	sd	s1,40(sp)
    80006c2e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006c30:	ffffb097          	auipc	ra,0xffffb
    80006c34:	d6e080e7          	jalr	-658(ra) # 8000199e <myproc>
    80006c38:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006c3a:	fd840593          	addi	a1,s0,-40
    80006c3e:	4501                	li	a0,0
    80006c40:	ffffd097          	auipc	ra,0xffffd
    80006c44:	ec4080e7          	jalr	-316(ra) # 80003b04 <argaddr>
    return -1;
    80006c48:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006c4a:	0e054063          	bltz	a0,80006d2a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006c4e:	fc840593          	addi	a1,s0,-56
    80006c52:	fd040513          	addi	a0,s0,-48
    80006c56:	fffff097          	auipc	ra,0xfffff
    80006c5a:	de6080e7          	jalr	-538(ra) # 80005a3c <pipealloc>
    return -1;
    80006c5e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006c60:	0c054563          	bltz	a0,80006d2a <sys_pipe+0x104>
  fd0 = -1;
    80006c64:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006c68:	fd043503          	ld	a0,-48(s0)
    80006c6c:	fffff097          	auipc	ra,0xfffff
    80006c70:	504080e7          	jalr	1284(ra) # 80006170 <fdalloc>
    80006c74:	fca42223          	sw	a0,-60(s0)
    80006c78:	08054c63          	bltz	a0,80006d10 <sys_pipe+0xea>
    80006c7c:	fc843503          	ld	a0,-56(s0)
    80006c80:	fffff097          	auipc	ra,0xfffff
    80006c84:	4f0080e7          	jalr	1264(ra) # 80006170 <fdalloc>
    80006c88:	fca42023          	sw	a0,-64(s0)
    80006c8c:	06054963          	bltz	a0,80006cfe <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006c90:	4691                	li	a3,4
    80006c92:	fc440613          	addi	a2,s0,-60
    80006c96:	fd843583          	ld	a1,-40(s0)
    80006c9a:	6ca8                	ld	a0,88(s1)
    80006c9c:	ffffb097          	auipc	ra,0xffffb
    80006ca0:	9c6080e7          	jalr	-1594(ra) # 80001662 <copyout>
    80006ca4:	02054063          	bltz	a0,80006cc4 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006ca8:	4691                	li	a3,4
    80006caa:	fc040613          	addi	a2,s0,-64
    80006cae:	fd843583          	ld	a1,-40(s0)
    80006cb2:	0591                	addi	a1,a1,4
    80006cb4:	6ca8                	ld	a0,88(s1)
    80006cb6:	ffffb097          	auipc	ra,0xffffb
    80006cba:	9ac080e7          	jalr	-1620(ra) # 80001662 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006cbe:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006cc0:	06055563          	bgez	a0,80006d2a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006cc4:	fc442783          	lw	a5,-60(s0)
    80006cc8:	07e9                	addi	a5,a5,26
    80006cca:	078e                	slli	a5,a5,0x3
    80006ccc:	97a6                	add	a5,a5,s1
    80006cce:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006cd2:	fc042783          	lw	a5,-64(s0)
    80006cd6:	07e9                	addi	a5,a5,26
    80006cd8:	078e                	slli	a5,a5,0x3
    80006cda:	00f48533          	add	a0,s1,a5
    80006cde:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006ce2:	fd043503          	ld	a0,-48(s0)
    80006ce6:	fffff097          	auipc	ra,0xfffff
    80006cea:	a26080e7          	jalr	-1498(ra) # 8000570c <fileclose>
    fileclose(wf);
    80006cee:	fc843503          	ld	a0,-56(s0)
    80006cf2:	fffff097          	auipc	ra,0xfffff
    80006cf6:	a1a080e7          	jalr	-1510(ra) # 8000570c <fileclose>
    return -1;
    80006cfa:	57fd                	li	a5,-1
    80006cfc:	a03d                	j	80006d2a <sys_pipe+0x104>
    if(fd0 >= 0)
    80006cfe:	fc442783          	lw	a5,-60(s0)
    80006d02:	0007c763          	bltz	a5,80006d10 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006d06:	07e9                	addi	a5,a5,26
    80006d08:	078e                	slli	a5,a5,0x3
    80006d0a:	97a6                	add	a5,a5,s1
    80006d0c:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80006d10:	fd043503          	ld	a0,-48(s0)
    80006d14:	fffff097          	auipc	ra,0xfffff
    80006d18:	9f8080e7          	jalr	-1544(ra) # 8000570c <fileclose>
    fileclose(wf);
    80006d1c:	fc843503          	ld	a0,-56(s0)
    80006d20:	fffff097          	auipc	ra,0xfffff
    80006d24:	9ec080e7          	jalr	-1556(ra) # 8000570c <fileclose>
    return -1;
    80006d28:	57fd                	li	a5,-1
}
    80006d2a:	853e                	mv	a0,a5
    80006d2c:	70e2                	ld	ra,56(sp)
    80006d2e:	7442                	ld	s0,48(sp)
    80006d30:	74a2                	ld	s1,40(sp)
    80006d32:	6121                	addi	sp,sp,64
    80006d34:	8082                	ret
	...

0000000080006d40 <kernelvec>:
    80006d40:	7111                	addi	sp,sp,-256
    80006d42:	e006                	sd	ra,0(sp)
    80006d44:	e40a                	sd	sp,8(sp)
    80006d46:	e80e                	sd	gp,16(sp)
    80006d48:	ec12                	sd	tp,24(sp)
    80006d4a:	f016                	sd	t0,32(sp)
    80006d4c:	f41a                	sd	t1,40(sp)
    80006d4e:	f81e                	sd	t2,48(sp)
    80006d50:	fc22                	sd	s0,56(sp)
    80006d52:	e0a6                	sd	s1,64(sp)
    80006d54:	e4aa                	sd	a0,72(sp)
    80006d56:	e8ae                	sd	a1,80(sp)
    80006d58:	ecb2                	sd	a2,88(sp)
    80006d5a:	f0b6                	sd	a3,96(sp)
    80006d5c:	f4ba                	sd	a4,104(sp)
    80006d5e:	f8be                	sd	a5,112(sp)
    80006d60:	fcc2                	sd	a6,120(sp)
    80006d62:	e146                	sd	a7,128(sp)
    80006d64:	e54a                	sd	s2,136(sp)
    80006d66:	e94e                	sd	s3,144(sp)
    80006d68:	ed52                	sd	s4,152(sp)
    80006d6a:	f156                	sd	s5,160(sp)
    80006d6c:	f55a                	sd	s6,168(sp)
    80006d6e:	f95e                	sd	s7,176(sp)
    80006d70:	fd62                	sd	s8,184(sp)
    80006d72:	e1e6                	sd	s9,192(sp)
    80006d74:	e5ea                	sd	s10,200(sp)
    80006d76:	e9ee                	sd	s11,208(sp)
    80006d78:	edf2                	sd	t3,216(sp)
    80006d7a:	f1f6                	sd	t4,224(sp)
    80006d7c:	f5fa                	sd	t5,232(sp)
    80006d7e:	f9fe                	sd	t6,240(sp)
    80006d80:	b87fc0ef          	jal	ra,80003906 <kerneltrap>
    80006d84:	6082                	ld	ra,0(sp)
    80006d86:	6122                	ld	sp,8(sp)
    80006d88:	61c2                	ld	gp,16(sp)
    80006d8a:	7282                	ld	t0,32(sp)
    80006d8c:	7322                	ld	t1,40(sp)
    80006d8e:	73c2                	ld	t2,48(sp)
    80006d90:	7462                	ld	s0,56(sp)
    80006d92:	6486                	ld	s1,64(sp)
    80006d94:	6526                	ld	a0,72(sp)
    80006d96:	65c6                	ld	a1,80(sp)
    80006d98:	6666                	ld	a2,88(sp)
    80006d9a:	7686                	ld	a3,96(sp)
    80006d9c:	7726                	ld	a4,104(sp)
    80006d9e:	77c6                	ld	a5,112(sp)
    80006da0:	7866                	ld	a6,120(sp)
    80006da2:	688a                	ld	a7,128(sp)
    80006da4:	692a                	ld	s2,136(sp)
    80006da6:	69ca                	ld	s3,144(sp)
    80006da8:	6a6a                	ld	s4,152(sp)
    80006daa:	7a8a                	ld	s5,160(sp)
    80006dac:	7b2a                	ld	s6,168(sp)
    80006dae:	7bca                	ld	s7,176(sp)
    80006db0:	7c6a                	ld	s8,184(sp)
    80006db2:	6c8e                	ld	s9,192(sp)
    80006db4:	6d2e                	ld	s10,200(sp)
    80006db6:	6dce                	ld	s11,208(sp)
    80006db8:	6e6e                	ld	t3,216(sp)
    80006dba:	7e8e                	ld	t4,224(sp)
    80006dbc:	7f2e                	ld	t5,232(sp)
    80006dbe:	7fce                	ld	t6,240(sp)
    80006dc0:	6111                	addi	sp,sp,256
    80006dc2:	10200073          	sret
    80006dc6:	00000013          	nop
    80006dca:	00000013          	nop
    80006dce:	0001                	nop

0000000080006dd0 <timervec>:
    80006dd0:	34051573          	csrrw	a0,mscratch,a0
    80006dd4:	e10c                	sd	a1,0(a0)
    80006dd6:	e510                	sd	a2,8(a0)
    80006dd8:	e914                	sd	a3,16(a0)
    80006dda:	6d0c                	ld	a1,24(a0)
    80006ddc:	7110                	ld	a2,32(a0)
    80006dde:	6194                	ld	a3,0(a1)
    80006de0:	96b2                	add	a3,a3,a2
    80006de2:	e194                	sd	a3,0(a1)
    80006de4:	4589                	li	a1,2
    80006de6:	14459073          	csrw	sip,a1
    80006dea:	6914                	ld	a3,16(a0)
    80006dec:	6510                	ld	a2,8(a0)
    80006dee:	610c                	ld	a1,0(a0)
    80006df0:	34051573          	csrrw	a0,mscratch,a0
    80006df4:	30200073          	mret
	...

0000000080006dfa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006dfa:	1141                	addi	sp,sp,-16
    80006dfc:	e422                	sd	s0,8(sp)
    80006dfe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006e00:	0c0007b7          	lui	a5,0xc000
    80006e04:	4705                	li	a4,1
    80006e06:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006e08:	c3d8                	sw	a4,4(a5)
}
    80006e0a:	6422                	ld	s0,8(sp)
    80006e0c:	0141                	addi	sp,sp,16
    80006e0e:	8082                	ret

0000000080006e10 <plicinithart>:

void
plicinithart(void)
{
    80006e10:	1141                	addi	sp,sp,-16
    80006e12:	e406                	sd	ra,8(sp)
    80006e14:	e022                	sd	s0,0(sp)
    80006e16:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006e18:	ffffb097          	auipc	ra,0xffffb
    80006e1c:	b5a080e7          	jalr	-1190(ra) # 80001972 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006e20:	0085171b          	slliw	a4,a0,0x8
    80006e24:	0c0027b7          	lui	a5,0xc002
    80006e28:	97ba                	add	a5,a5,a4
    80006e2a:	40200713          	li	a4,1026
    80006e2e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006e32:	00d5151b          	slliw	a0,a0,0xd
    80006e36:	0c2017b7          	lui	a5,0xc201
    80006e3a:	97aa                	add	a5,a5,a0
    80006e3c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006e40:	60a2                	ld	ra,8(sp)
    80006e42:	6402                	ld	s0,0(sp)
    80006e44:	0141                	addi	sp,sp,16
    80006e46:	8082                	ret

0000000080006e48 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006e48:	1141                	addi	sp,sp,-16
    80006e4a:	e406                	sd	ra,8(sp)
    80006e4c:	e022                	sd	s0,0(sp)
    80006e4e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006e50:	ffffb097          	auipc	ra,0xffffb
    80006e54:	b22080e7          	jalr	-1246(ra) # 80001972 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006e58:	00d5151b          	slliw	a0,a0,0xd
    80006e5c:	0c2017b7          	lui	a5,0xc201
    80006e60:	97aa                	add	a5,a5,a0
  return irq;
}
    80006e62:	43c8                	lw	a0,4(a5)
    80006e64:	60a2                	ld	ra,8(sp)
    80006e66:	6402                	ld	s0,0(sp)
    80006e68:	0141                	addi	sp,sp,16
    80006e6a:	8082                	ret

0000000080006e6c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006e6c:	1101                	addi	sp,sp,-32
    80006e6e:	ec06                	sd	ra,24(sp)
    80006e70:	e822                	sd	s0,16(sp)
    80006e72:	e426                	sd	s1,8(sp)
    80006e74:	1000                	addi	s0,sp,32
    80006e76:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006e78:	ffffb097          	auipc	ra,0xffffb
    80006e7c:	afa080e7          	jalr	-1286(ra) # 80001972 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006e80:	00d5151b          	slliw	a0,a0,0xd
    80006e84:	0c2017b7          	lui	a5,0xc201
    80006e88:	97aa                	add	a5,a5,a0
    80006e8a:	c3c4                	sw	s1,4(a5)
}
    80006e8c:	60e2                	ld	ra,24(sp)
    80006e8e:	6442                	ld	s0,16(sp)
    80006e90:	64a2                	ld	s1,8(sp)
    80006e92:	6105                	addi	sp,sp,32
    80006e94:	8082                	ret

0000000080006e96 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006e96:	1141                	addi	sp,sp,-16
    80006e98:	e406                	sd	ra,8(sp)
    80006e9a:	e022                	sd	s0,0(sp)
    80006e9c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006e9e:	479d                	li	a5,7
    80006ea0:	06a7c863          	blt	a5,a0,80006f10 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80006ea4:	0001d717          	auipc	a4,0x1d
    80006ea8:	15c70713          	addi	a4,a4,348 # 80024000 <disk>
    80006eac:	972a                	add	a4,a4,a0
    80006eae:	6789                	lui	a5,0x2
    80006eb0:	97ba                	add	a5,a5,a4
    80006eb2:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006eb6:	e7ad                	bnez	a5,80006f20 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006eb8:	00451793          	slli	a5,a0,0x4
    80006ebc:	0001f717          	auipc	a4,0x1f
    80006ec0:	14470713          	addi	a4,a4,324 # 80026000 <disk+0x2000>
    80006ec4:	6314                	ld	a3,0(a4)
    80006ec6:	96be                	add	a3,a3,a5
    80006ec8:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006ecc:	6314                	ld	a3,0(a4)
    80006ece:	96be                	add	a3,a3,a5
    80006ed0:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006ed4:	6314                	ld	a3,0(a4)
    80006ed6:	96be                	add	a3,a3,a5
    80006ed8:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006edc:	6318                	ld	a4,0(a4)
    80006ede:	97ba                	add	a5,a5,a4
    80006ee0:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006ee4:	0001d717          	auipc	a4,0x1d
    80006ee8:	11c70713          	addi	a4,a4,284 # 80024000 <disk>
    80006eec:	972a                	add	a4,a4,a0
    80006eee:	6789                	lui	a5,0x2
    80006ef0:	97ba                	add	a5,a5,a4
    80006ef2:	4705                	li	a4,1
    80006ef4:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006ef8:	0001f517          	auipc	a0,0x1f
    80006efc:	12050513          	addi	a0,a0,288 # 80026018 <disk+0x2018>
    80006f00:	ffffc097          	auipc	ra,0xffffc
    80006f04:	c54080e7          	jalr	-940(ra) # 80002b54 <wakeup>
}
    80006f08:	60a2                	ld	ra,8(sp)
    80006f0a:	6402                	ld	s0,0(sp)
    80006f0c:	0141                	addi	sp,sp,16
    80006f0e:	8082                	ret
    panic("free_desc 1");
    80006f10:	00003517          	auipc	a0,0x3
    80006f14:	ab050513          	addi	a0,a0,-1360 # 800099c0 <syscalls+0x380>
    80006f18:	ffff9097          	auipc	ra,0xffff9
    80006f1c:	620080e7          	jalr	1568(ra) # 80000538 <panic>
    panic("free_desc 2");
    80006f20:	00003517          	auipc	a0,0x3
    80006f24:	ab050513          	addi	a0,a0,-1360 # 800099d0 <syscalls+0x390>
    80006f28:	ffff9097          	auipc	ra,0xffff9
    80006f2c:	610080e7          	jalr	1552(ra) # 80000538 <panic>

0000000080006f30 <virtio_disk_init>:
{
    80006f30:	1101                	addi	sp,sp,-32
    80006f32:	ec06                	sd	ra,24(sp)
    80006f34:	e822                	sd	s0,16(sp)
    80006f36:	e426                	sd	s1,8(sp)
    80006f38:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006f3a:	00003597          	auipc	a1,0x3
    80006f3e:	aa658593          	addi	a1,a1,-1370 # 800099e0 <syscalls+0x3a0>
    80006f42:	0001f517          	auipc	a0,0x1f
    80006f46:	1e650513          	addi	a0,a0,486 # 80026128 <disk+0x2128>
    80006f4a:	ffffa097          	auipc	ra,0xffffa
    80006f4e:	bf4080e7          	jalr	-1036(ra) # 80000b3e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006f52:	100017b7          	lui	a5,0x10001
    80006f56:	4398                	lw	a4,0(a5)
    80006f58:	2701                	sext.w	a4,a4
    80006f5a:	747277b7          	lui	a5,0x74727
    80006f5e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006f62:	0ef71063          	bne	a4,a5,80007042 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006f66:	100017b7          	lui	a5,0x10001
    80006f6a:	43dc                	lw	a5,4(a5)
    80006f6c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006f6e:	4705                	li	a4,1
    80006f70:	0ce79963          	bne	a5,a4,80007042 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006f74:	100017b7          	lui	a5,0x10001
    80006f78:	479c                	lw	a5,8(a5)
    80006f7a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006f7c:	4709                	li	a4,2
    80006f7e:	0ce79263          	bne	a5,a4,80007042 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006f82:	100017b7          	lui	a5,0x10001
    80006f86:	47d8                	lw	a4,12(a5)
    80006f88:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006f8a:	554d47b7          	lui	a5,0x554d4
    80006f8e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006f92:	0af71863          	bne	a4,a5,80007042 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f96:	100017b7          	lui	a5,0x10001
    80006f9a:	4705                	li	a4,1
    80006f9c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f9e:	470d                	li	a4,3
    80006fa0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006fa2:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006fa4:	c7ffe6b7          	lui	a3,0xc7ffe
    80006fa8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
    80006fac:	8f75                	and	a4,a4,a3
    80006fae:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006fb0:	472d                	li	a4,11
    80006fb2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006fb4:	473d                	li	a4,15
    80006fb6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006fb8:	6705                	lui	a4,0x1
    80006fba:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006fbc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006fc0:	5bdc                	lw	a5,52(a5)
    80006fc2:	2781                	sext.w	a5,a5
  if(max == 0)
    80006fc4:	c7d9                	beqz	a5,80007052 <virtio_disk_init+0x122>
  if(max < NUM)
    80006fc6:	471d                	li	a4,7
    80006fc8:	08f77d63          	bgeu	a4,a5,80007062 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006fcc:	100014b7          	lui	s1,0x10001
    80006fd0:	47a1                	li	a5,8
    80006fd2:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006fd4:	6609                	lui	a2,0x2
    80006fd6:	4581                	li	a1,0
    80006fd8:	0001d517          	auipc	a0,0x1d
    80006fdc:	02850513          	addi	a0,a0,40 # 80024000 <disk>
    80006fe0:	ffffa097          	auipc	ra,0xffffa
    80006fe4:	cea080e7          	jalr	-790(ra) # 80000cca <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006fe8:	0001d717          	auipc	a4,0x1d
    80006fec:	01870713          	addi	a4,a4,24 # 80024000 <disk>
    80006ff0:	00c75793          	srli	a5,a4,0xc
    80006ff4:	2781                	sext.w	a5,a5
    80006ff6:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006ff8:	0001f797          	auipc	a5,0x1f
    80006ffc:	00878793          	addi	a5,a5,8 # 80026000 <disk+0x2000>
    80007000:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007002:	0001d717          	auipc	a4,0x1d
    80007006:	07e70713          	addi	a4,a4,126 # 80024080 <disk+0x80>
    8000700a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000700c:	0001e717          	auipc	a4,0x1e
    80007010:	ff470713          	addi	a4,a4,-12 # 80025000 <disk+0x1000>
    80007014:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80007016:	4705                	li	a4,1
    80007018:	00e78c23          	sb	a4,24(a5)
    8000701c:	00e78ca3          	sb	a4,25(a5)
    80007020:	00e78d23          	sb	a4,26(a5)
    80007024:	00e78da3          	sb	a4,27(a5)
    80007028:	00e78e23          	sb	a4,28(a5)
    8000702c:	00e78ea3          	sb	a4,29(a5)
    80007030:	00e78f23          	sb	a4,30(a5)
    80007034:	00e78fa3          	sb	a4,31(a5)
}
    80007038:	60e2                	ld	ra,24(sp)
    8000703a:	6442                	ld	s0,16(sp)
    8000703c:	64a2                	ld	s1,8(sp)
    8000703e:	6105                	addi	sp,sp,32
    80007040:	8082                	ret
    panic("could not find virtio disk");
    80007042:	00003517          	auipc	a0,0x3
    80007046:	9ae50513          	addi	a0,a0,-1618 # 800099f0 <syscalls+0x3b0>
    8000704a:	ffff9097          	auipc	ra,0xffff9
    8000704e:	4ee080e7          	jalr	1262(ra) # 80000538 <panic>
    panic("virtio disk has no queue 0");
    80007052:	00003517          	auipc	a0,0x3
    80007056:	9be50513          	addi	a0,a0,-1602 # 80009a10 <syscalls+0x3d0>
    8000705a:	ffff9097          	auipc	ra,0xffff9
    8000705e:	4de080e7          	jalr	1246(ra) # 80000538 <panic>
    panic("virtio disk max queue too short");
    80007062:	00003517          	auipc	a0,0x3
    80007066:	9ce50513          	addi	a0,a0,-1586 # 80009a30 <syscalls+0x3f0>
    8000706a:	ffff9097          	auipc	ra,0xffff9
    8000706e:	4ce080e7          	jalr	1230(ra) # 80000538 <panic>

0000000080007072 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80007072:	7119                	addi	sp,sp,-128
    80007074:	fc86                	sd	ra,120(sp)
    80007076:	f8a2                	sd	s0,112(sp)
    80007078:	f4a6                	sd	s1,104(sp)
    8000707a:	f0ca                	sd	s2,96(sp)
    8000707c:	ecce                	sd	s3,88(sp)
    8000707e:	e8d2                	sd	s4,80(sp)
    80007080:	e4d6                	sd	s5,72(sp)
    80007082:	e0da                	sd	s6,64(sp)
    80007084:	fc5e                	sd	s7,56(sp)
    80007086:	f862                	sd	s8,48(sp)
    80007088:	f466                	sd	s9,40(sp)
    8000708a:	f06a                	sd	s10,32(sp)
    8000708c:	ec6e                	sd	s11,24(sp)
    8000708e:	0100                	addi	s0,sp,128
    80007090:	8aaa                	mv	s5,a0
    80007092:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80007094:	00c52c83          	lw	s9,12(a0)
    80007098:	001c9c9b          	slliw	s9,s9,0x1
    8000709c:	1c82                	slli	s9,s9,0x20
    8000709e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800070a2:	0001f517          	auipc	a0,0x1f
    800070a6:	08650513          	addi	a0,a0,134 # 80026128 <disk+0x2128>
    800070aa:	ffffa097          	auipc	ra,0xffffa
    800070ae:	b24080e7          	jalr	-1244(ra) # 80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800070b2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800070b4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800070b6:	0001dc17          	auipc	s8,0x1d
    800070ba:	f4ac0c13          	addi	s8,s8,-182 # 80024000 <disk>
    800070be:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800070c0:	4b0d                	li	s6,3
    800070c2:	a0ad                	j	8000712c <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800070c4:	00fc0733          	add	a4,s8,a5
    800070c8:	975e                	add	a4,a4,s7
    800070ca:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800070ce:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800070d0:	0207c563          	bltz	a5,800070fa <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800070d4:	2905                	addiw	s2,s2,1
    800070d6:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    800070d8:	19690c63          	beq	s2,s6,80007270 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    800070dc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800070de:	0001f717          	auipc	a4,0x1f
    800070e2:	f3a70713          	addi	a4,a4,-198 # 80026018 <disk+0x2018>
    800070e6:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800070e8:	00074683          	lbu	a3,0(a4)
    800070ec:	fee1                	bnez	a3,800070c4 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800070ee:	2785                	addiw	a5,a5,1
    800070f0:	0705                	addi	a4,a4,1
    800070f2:	fe979be3          	bne	a5,s1,800070e8 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800070f6:	57fd                	li	a5,-1
    800070f8:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800070fa:	01205d63          	blez	s2,80007114 <virtio_disk_rw+0xa2>
    800070fe:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007100:	000a2503          	lw	a0,0(s4)
    80007104:	00000097          	auipc	ra,0x0
    80007108:	d92080e7          	jalr	-622(ra) # 80006e96 <free_desc>
      for(int j = 0; j < i; j++)
    8000710c:	2d85                	addiw	s11,s11,1
    8000710e:	0a11                	addi	s4,s4,4
    80007110:	ff2d98e3          	bne	s11,s2,80007100 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007114:	0001f597          	auipc	a1,0x1f
    80007118:	01458593          	addi	a1,a1,20 # 80026128 <disk+0x2128>
    8000711c:	0001f517          	auipc	a0,0x1f
    80007120:	efc50513          	addi	a0,a0,-260 # 80026018 <disk+0x2018>
    80007124:	ffffb097          	auipc	ra,0xffffb
    80007128:	62c080e7          	jalr	1580(ra) # 80002750 <sleep>
  for(int i = 0; i < 3; i++){
    8000712c:	f8040a13          	addi	s4,s0,-128
{
    80007130:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007132:	894e                	mv	s2,s3
    80007134:	b765                	j	800070dc <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80007136:	0001f697          	auipc	a3,0x1f
    8000713a:	eca6b683          	ld	a3,-310(a3) # 80026000 <disk+0x2000>
    8000713e:	96ba                	add	a3,a3,a4
    80007140:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007144:	0001d817          	auipc	a6,0x1d
    80007148:	ebc80813          	addi	a6,a6,-324 # 80024000 <disk>
    8000714c:	0001f697          	auipc	a3,0x1f
    80007150:	eb468693          	addi	a3,a3,-332 # 80026000 <disk+0x2000>
    80007154:	6290                	ld	a2,0(a3)
    80007156:	963a                	add	a2,a2,a4
    80007158:	00c65583          	lhu	a1,12(a2)
    8000715c:	0015e593          	ori	a1,a1,1
    80007160:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007164:	f8842603          	lw	a2,-120(s0)
    80007168:	628c                	ld	a1,0(a3)
    8000716a:	972e                	add	a4,a4,a1
    8000716c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007170:	20050593          	addi	a1,a0,512
    80007174:	0592                	slli	a1,a1,0x4
    80007176:	95c2                	add	a1,a1,a6
    80007178:	577d                	li	a4,-1
    8000717a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000717e:	00461713          	slli	a4,a2,0x4
    80007182:	6290                	ld	a2,0(a3)
    80007184:	963a                	add	a2,a2,a4
    80007186:	03078793          	addi	a5,a5,48
    8000718a:	97c2                	add	a5,a5,a6
    8000718c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000718e:	629c                	ld	a5,0(a3)
    80007190:	97ba                	add	a5,a5,a4
    80007192:	4605                	li	a2,1
    80007194:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80007196:	629c                	ld	a5,0(a3)
    80007198:	97ba                	add	a5,a5,a4
    8000719a:	4809                	li	a6,2
    8000719c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800071a0:	629c                	ld	a5,0(a3)
    800071a2:	97ba                	add	a5,a5,a4
    800071a4:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800071a8:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800071ac:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800071b0:	6698                	ld	a4,8(a3)
    800071b2:	00275783          	lhu	a5,2(a4)
    800071b6:	8b9d                	andi	a5,a5,7
    800071b8:	0786                	slli	a5,a5,0x1
    800071ba:	973e                	add	a4,a4,a5
    800071bc:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    800071c0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800071c4:	6698                	ld	a4,8(a3)
    800071c6:	00275783          	lhu	a5,2(a4)
    800071ca:	2785                	addiw	a5,a5,1
    800071cc:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800071d0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800071d4:	100017b7          	lui	a5,0x10001
    800071d8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800071dc:	004aa783          	lw	a5,4(s5)
    800071e0:	02c79163          	bne	a5,a2,80007202 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800071e4:	0001f917          	auipc	s2,0x1f
    800071e8:	f4490913          	addi	s2,s2,-188 # 80026128 <disk+0x2128>
  while(b->disk == 1) {
    800071ec:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800071ee:	85ca                	mv	a1,s2
    800071f0:	8556                	mv	a0,s5
    800071f2:	ffffb097          	auipc	ra,0xffffb
    800071f6:	55e080e7          	jalr	1374(ra) # 80002750 <sleep>
  while(b->disk == 1) {
    800071fa:	004aa783          	lw	a5,4(s5)
    800071fe:	fe9788e3          	beq	a5,s1,800071ee <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007202:	f8042903          	lw	s2,-128(s0)
    80007206:	20090713          	addi	a4,s2,512
    8000720a:	0712                	slli	a4,a4,0x4
    8000720c:	0001d797          	auipc	a5,0x1d
    80007210:	df478793          	addi	a5,a5,-524 # 80024000 <disk>
    80007214:	97ba                	add	a5,a5,a4
    80007216:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000721a:	0001f997          	auipc	s3,0x1f
    8000721e:	de698993          	addi	s3,s3,-538 # 80026000 <disk+0x2000>
    80007222:	00491713          	slli	a4,s2,0x4
    80007226:	0009b783          	ld	a5,0(s3)
    8000722a:	97ba                	add	a5,a5,a4
    8000722c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007230:	854a                	mv	a0,s2
    80007232:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80007236:	00000097          	auipc	ra,0x0
    8000723a:	c60080e7          	jalr	-928(ra) # 80006e96 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000723e:	8885                	andi	s1,s1,1
    80007240:	f0ed                	bnez	s1,80007222 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007242:	0001f517          	auipc	a0,0x1f
    80007246:	ee650513          	addi	a0,a0,-282 # 80026128 <disk+0x2128>
    8000724a:	ffffa097          	auipc	ra,0xffffa
    8000724e:	a38080e7          	jalr	-1480(ra) # 80000c82 <release>
}
    80007252:	70e6                	ld	ra,120(sp)
    80007254:	7446                	ld	s0,112(sp)
    80007256:	74a6                	ld	s1,104(sp)
    80007258:	7906                	ld	s2,96(sp)
    8000725a:	69e6                	ld	s3,88(sp)
    8000725c:	6a46                	ld	s4,80(sp)
    8000725e:	6aa6                	ld	s5,72(sp)
    80007260:	6b06                	ld	s6,64(sp)
    80007262:	7be2                	ld	s7,56(sp)
    80007264:	7c42                	ld	s8,48(sp)
    80007266:	7ca2                	ld	s9,40(sp)
    80007268:	7d02                	ld	s10,32(sp)
    8000726a:	6de2                	ld	s11,24(sp)
    8000726c:	6109                	addi	sp,sp,128
    8000726e:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007270:	f8042503          	lw	a0,-128(s0)
    80007274:	20050793          	addi	a5,a0,512
    80007278:	0792                	slli	a5,a5,0x4
  if(write)
    8000727a:	0001d817          	auipc	a6,0x1d
    8000727e:	d8680813          	addi	a6,a6,-634 # 80024000 <disk>
    80007282:	00f80733          	add	a4,a6,a5
    80007286:	01a036b3          	snez	a3,s10
    8000728a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000728e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007292:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007296:	7679                	lui	a2,0xffffe
    80007298:	963e                	add	a2,a2,a5
    8000729a:	0001f697          	auipc	a3,0x1f
    8000729e:	d6668693          	addi	a3,a3,-666 # 80026000 <disk+0x2000>
    800072a2:	6298                	ld	a4,0(a3)
    800072a4:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800072a6:	0a878593          	addi	a1,a5,168
    800072aa:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800072ac:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800072ae:	6298                	ld	a4,0(a3)
    800072b0:	9732                	add	a4,a4,a2
    800072b2:	45c1                	li	a1,16
    800072b4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800072b6:	6298                	ld	a4,0(a3)
    800072b8:	9732                	add	a4,a4,a2
    800072ba:	4585                	li	a1,1
    800072bc:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800072c0:	f8442703          	lw	a4,-124(s0)
    800072c4:	628c                	ld	a1,0(a3)
    800072c6:	962e                	add	a2,a2,a1
    800072c8:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd700e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800072cc:	0712                	slli	a4,a4,0x4
    800072ce:	6290                	ld	a2,0(a3)
    800072d0:	963a                	add	a2,a2,a4
    800072d2:	058a8593          	addi	a1,s5,88
    800072d6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800072d8:	6294                	ld	a3,0(a3)
    800072da:	96ba                	add	a3,a3,a4
    800072dc:	40000613          	li	a2,1024
    800072e0:	c690                	sw	a2,8(a3)
  if(write)
    800072e2:	e40d1ae3          	bnez	s10,80007136 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800072e6:	0001f697          	auipc	a3,0x1f
    800072ea:	d1a6b683          	ld	a3,-742(a3) # 80026000 <disk+0x2000>
    800072ee:	96ba                	add	a3,a3,a4
    800072f0:	4609                	li	a2,2
    800072f2:	00c69623          	sh	a2,12(a3)
    800072f6:	b5b9                	j	80007144 <virtio_disk_rw+0xd2>

00000000800072f8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800072f8:	1101                	addi	sp,sp,-32
    800072fa:	ec06                	sd	ra,24(sp)
    800072fc:	e822                	sd	s0,16(sp)
    800072fe:	e426                	sd	s1,8(sp)
    80007300:	e04a                	sd	s2,0(sp)
    80007302:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80007304:	0001f517          	auipc	a0,0x1f
    80007308:	e2450513          	addi	a0,a0,-476 # 80026128 <disk+0x2128>
    8000730c:	ffffa097          	auipc	ra,0xffffa
    80007310:	8c2080e7          	jalr	-1854(ra) # 80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80007314:	10001737          	lui	a4,0x10001
    80007318:	533c                	lw	a5,96(a4)
    8000731a:	8b8d                	andi	a5,a5,3
    8000731c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000731e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007322:	0001f797          	auipc	a5,0x1f
    80007326:	cde78793          	addi	a5,a5,-802 # 80026000 <disk+0x2000>
    8000732a:	6b94                	ld	a3,16(a5)
    8000732c:	0207d703          	lhu	a4,32(a5)
    80007330:	0026d783          	lhu	a5,2(a3)
    80007334:	06f70163          	beq	a4,a5,80007396 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007338:	0001d917          	auipc	s2,0x1d
    8000733c:	cc890913          	addi	s2,s2,-824 # 80024000 <disk>
    80007340:	0001f497          	auipc	s1,0x1f
    80007344:	cc048493          	addi	s1,s1,-832 # 80026000 <disk+0x2000>
    __sync_synchronize();
    80007348:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000734c:	6898                	ld	a4,16(s1)
    8000734e:	0204d783          	lhu	a5,32(s1)
    80007352:	8b9d                	andi	a5,a5,7
    80007354:	078e                	slli	a5,a5,0x3
    80007356:	97ba                	add	a5,a5,a4
    80007358:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000735a:	20078713          	addi	a4,a5,512
    8000735e:	0712                	slli	a4,a4,0x4
    80007360:	974a                	add	a4,a4,s2
    80007362:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80007366:	e731                	bnez	a4,800073b2 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80007368:	20078793          	addi	a5,a5,512
    8000736c:	0792                	slli	a5,a5,0x4
    8000736e:	97ca                	add	a5,a5,s2
    80007370:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007372:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80007376:	ffffb097          	auipc	ra,0xffffb
    8000737a:	7de080e7          	jalr	2014(ra) # 80002b54 <wakeup>

    disk.used_idx += 1;
    8000737e:	0204d783          	lhu	a5,32(s1)
    80007382:	2785                	addiw	a5,a5,1
    80007384:	17c2                	slli	a5,a5,0x30
    80007386:	93c1                	srli	a5,a5,0x30
    80007388:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000738c:	6898                	ld	a4,16(s1)
    8000738e:	00275703          	lhu	a4,2(a4)
    80007392:	faf71be3          	bne	a4,a5,80007348 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80007396:	0001f517          	auipc	a0,0x1f
    8000739a:	d9250513          	addi	a0,a0,-622 # 80026128 <disk+0x2128>
    8000739e:	ffffa097          	auipc	ra,0xffffa
    800073a2:	8e4080e7          	jalr	-1820(ra) # 80000c82 <release>
}
    800073a6:	60e2                	ld	ra,24(sp)
    800073a8:	6442                	ld	s0,16(sp)
    800073aa:	64a2                	ld	s1,8(sp)
    800073ac:	6902                	ld	s2,0(sp)
    800073ae:	6105                	addi	sp,sp,32
    800073b0:	8082                	ret
      panic("virtio_disk_intr status");
    800073b2:	00002517          	auipc	a0,0x2
    800073b6:	69e50513          	addi	a0,a0,1694 # 80009a50 <syscalls+0x410>
    800073ba:	ffff9097          	auipc	ra,0xffff9
    800073be:	17e080e7          	jalr	382(ra) # 80000538 <panic>
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
