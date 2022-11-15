
user/_semprodconstest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <produce>:
#include "user/user.h"

int num_items, num_prods, num_cons;

int produce (int index, int tid)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
   return index+(num_items*tid);
   6:	00001797          	auipc	a5,0x1
   a:	bba7a783          	lw	a5,-1094(a5) # bc0 <num_items>
   e:	02b787bb          	mulw	a5,a5,a1
}
  12:	9d3d                	addw	a0,a0,a5
  14:	6422                	ld	s0,8(sp)
  16:	0141                	addi	sp,sp,16
  18:	8082                	ret

000000000000001a <main>:

int
main(int argc, char *argv[])
{
  1a:	7179                	addi	sp,sp,-48
  1c:	f406                	sd	ra,40(sp)
  1e:	f022                	sd	s0,32(sp)
  20:	ec26                	sd	s1,24(sp)
  22:	e84a                	sd	s2,16(sp)
  24:	e44e                	sd	s3,8(sp)
  26:	e052                	sd	s4,0(sp)
  28:	1800                	addi	s0,sp,48
  int i, j;

  if (argc != 4) {
  2a:	4791                	li	a5,4
  2c:	02f50063          	beq	a0,a5,4c <main+0x32>
     fprintf(2, "syntax: semprodconstest number of items to be produced by each producer, number of producers, number of consumers.\nAborting...\n");
  30:	00001597          	auipc	a1,0x1
  34:	a6858593          	addi	a1,a1,-1432 # a98 <malloc+0xec>
  38:	4509                	li	a0,2
  3a:	00001097          	auipc	ra,0x1
  3e:	88c080e7          	jalr	-1908(ra) # 8c6 <fprintf>
     exit(0);
  42:	4501                	li	a0,0
  44:	00000097          	auipc	ra,0x0
  48:	496080e7          	jalr	1174(ra) # 4da <exit>
  4c:	84ae                	mv	s1,a1
  }

  num_items = atoi(argv[1]);
  4e:	6588                	ld	a0,8(a1)
  50:	00000097          	auipc	ra,0x0
  54:	390080e7          	jalr	912(ra) # 3e0 <atoi>
  58:	00001797          	auipc	a5,0x1
  5c:	b6a7a423          	sw	a0,-1176(a5) # bc0 <num_items>
  num_prods = atoi(argv[2]);
  60:	6888                	ld	a0,16(s1)
  62:	00000097          	auipc	ra,0x0
  66:	37e080e7          	jalr	894(ra) # 3e0 <atoi>
  6a:	00001917          	auipc	s2,0x1
  6e:	b5290913          	addi	s2,s2,-1198 # bbc <num_prods>
  72:	00a92023          	sw	a0,0(s2)
  num_cons = atoi(argv[3]);
  76:	6c88                	ld	a0,24(s1)
  78:	00000097          	auipc	ra,0x0
  7c:	368080e7          	jalr	872(ra) # 3e0 <atoi>
  80:	00001797          	auipc	a5,0x1
  84:	b2a7ac23          	sw	a0,-1224(a5) # bb8 <num_cons>
  buffer_sem_init();
  88:	00000097          	auipc	ra,0x0
  8c:	574080e7          	jalr	1396(ra) # 5fc <buffer_sem_init>

  printf("Start time: %d\n\n", uptime());
  90:	00000097          	auipc	ra,0x0
  94:	4e2080e7          	jalr	1250(ra) # 572 <uptime>
  98:	85aa                	mv	a1,a0
  9a:	00001517          	auipc	a0,0x1
  9e:	a7e50513          	addi	a0,a0,-1410 # b18 <malloc+0x16c>
  a2:	00001097          	auipc	ra,0x1
  a6:	852080e7          	jalr	-1966(ra) # 8f4 <printf>
  for (i=0; i<num_prods; i++) {
  aa:	00092783          	lw	a5,0(s2)
  ae:	02f05363          	blez	a5,d4 <main+0xba>
  b2:	4901                	li	s2,0
  b4:	00001997          	auipc	s3,0x1
  b8:	b0898993          	addi	s3,s3,-1272 # bbc <num_prods>
     if (fork() == 0) {
  bc:	00000097          	auipc	ra,0x0
  c0:	416080e7          	jalr	1046(ra) # 4d2 <fork>
  c4:	84aa                	mv	s1,a0
  c6:	10050563          	beqz	a0,1d0 <main+0x1b6>
  for (i=0; i<num_prods; i++) {
  ca:	2905                	addiw	s2,s2,1
  cc:	0009a783          	lw	a5,0(s3)
  d0:	fef946e3          	blt	s2,a5,bc <main+0xa2>
	for (j=0; j<num_items; j++) sem_produce(produce(j, i));
	exit(0);
     }
  }
  for (i=0; i<num_cons-1; i++) {
  d4:	00001717          	auipc	a4,0x1
  d8:	ae472703          	lw	a4,-1308(a4) # bb8 <num_cons>
  dc:	4785                	li	a5,1
  de:	02e7d463          	bge	a5,a4,106 <main+0xec>
  e2:	4901                	li	s2,0
  e4:	00001997          	auipc	s3,0x1
  e8:	ad498993          	addi	s3,s3,-1324 # bb8 <num_cons>
     if (fork() == 0) {
  ec:	00000097          	auipc	ra,0x0
  f0:	3e6080e7          	jalr	998(ra) # 4d2 <fork>
  f4:	84aa                	mv	s1,a0
  f6:	10050863          	beqz	a0,206 <main+0x1ec>
  for (i=0; i<num_cons-1; i++) {
  fa:	2905                	addiw	s2,s2,1
  fc:	0009a783          	lw	a5,0(s3)
 100:	37fd                	addiw	a5,a5,-1
 102:	fef945e3          	blt	s2,a5,ec <main+0xd2>
        for (j=0; j<(num_items*num_prods)/num_cons; j++) sem_consume();
        exit(0);
     }
  }
  for (j=0; j<(num_items*num_prods)/num_cons; j++) sem_consume();
 106:	00001717          	auipc	a4,0x1
 10a:	aba72703          	lw	a4,-1350(a4) # bc0 <num_items>
 10e:	00001797          	auipc	a5,0x1
 112:	aae7a783          	lw	a5,-1362(a5) # bbc <num_prods>
 116:	02e787bb          	mulw	a5,a5,a4
 11a:	00001717          	auipc	a4,0x1
 11e:	a9e72703          	lw	a4,-1378(a4) # bb8 <num_cons>
 122:	02e7c7bb          	divw	a5,a5,a4
 126:	04f05063          	blez	a5,166 <main+0x14c>
 12a:	4481                	li	s1,0
 12c:	00001a17          	auipc	s4,0x1
 130:	a94a0a13          	addi	s4,s4,-1388 # bc0 <num_items>
 134:	00001997          	auipc	s3,0x1
 138:	a8898993          	addi	s3,s3,-1400 # bbc <num_prods>
 13c:	00001917          	auipc	s2,0x1
 140:	a7c90913          	addi	s2,s2,-1412 # bb8 <num_cons>
 144:	00000097          	auipc	ra,0x0
 148:	4cc080e7          	jalr	1228(ra) # 610 <sem_consume>
 14c:	2485                	addiw	s1,s1,1
 14e:	000a2703          	lw	a4,0(s4)
 152:	0009a783          	lw	a5,0(s3)
 156:	02e787bb          	mulw	a5,a5,a4
 15a:	00092703          	lw	a4,0(s2)
 15e:	02e7c7bb          	divw	a5,a5,a4
 162:	fef4c1e3          	blt	s1,a5,144 <main+0x12a>
  for (i=0; i<num_prods+num_cons-1; i++) wait(0);
 166:	00001717          	auipc	a4,0x1
 16a:	a5672703          	lw	a4,-1450(a4) # bbc <num_prods>
 16e:	00001797          	auipc	a5,0x1
 172:	a4a7a783          	lw	a5,-1462(a5) # bb8 <num_cons>
 176:	9fb9                	addw	a5,a5,a4
 178:	4705                	li	a4,1
 17a:	02f75963          	bge	a4,a5,1ac <main+0x192>
 17e:	4481                	li	s1,0
 180:	00001997          	auipc	s3,0x1
 184:	a3c98993          	addi	s3,s3,-1476 # bbc <num_prods>
 188:	00001917          	auipc	s2,0x1
 18c:	a3090913          	addi	s2,s2,-1488 # bb8 <num_cons>
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	350080e7          	jalr	848(ra) # 4e2 <wait>
 19a:	2485                	addiw	s1,s1,1
 19c:	0009a703          	lw	a4,0(s3)
 1a0:	00092783          	lw	a5,0(s2)
 1a4:	9fb9                	addw	a5,a5,a4
 1a6:	37fd                	addiw	a5,a5,-1
 1a8:	fef4c4e3          	blt	s1,a5,190 <main+0x176>
  printf("\n\nEnd time: %d\n", uptime());
 1ac:	00000097          	auipc	ra,0x0
 1b0:	3c6080e7          	jalr	966(ra) # 572 <uptime>
 1b4:	85aa                	mv	a1,a0
 1b6:	00001517          	auipc	a0,0x1
 1ba:	97a50513          	addi	a0,a0,-1670 # b30 <malloc+0x184>
 1be:	00000097          	auipc	ra,0x0
 1c2:	736080e7          	jalr	1846(ra) # 8f4 <printf>
  exit(0);
 1c6:	4501                	li	a0,0
 1c8:	00000097          	auipc	ra,0x0
 1cc:	312080e7          	jalr	786(ra) # 4da <exit>
	for (j=0; j<num_items; j++) sem_produce(produce(j, i));
 1d0:	00001517          	auipc	a0,0x1
 1d4:	9f052503          	lw	a0,-1552(a0) # bc0 <num_items>
 1d8:	02a05263          	blez	a0,1fc <main+0x1e2>
 1dc:	00001997          	auipc	s3,0x1
 1e0:	9e498993          	addi	s3,s3,-1564 # bc0 <num_items>
   return index+(num_items*tid);
 1e4:	0325053b          	mulw	a0,a0,s2
	for (j=0; j<num_items; j++) sem_produce(produce(j, i));
 1e8:	9d25                	addw	a0,a0,s1
 1ea:	00000097          	auipc	ra,0x0
 1ee:	41c080e7          	jalr	1052(ra) # 606 <sem_produce>
 1f2:	2485                	addiw	s1,s1,1
 1f4:	0009a503          	lw	a0,0(s3)
 1f8:	fea4c6e3          	blt	s1,a0,1e4 <main+0x1ca>
	exit(0);
 1fc:	4501                	li	a0,0
 1fe:	00000097          	auipc	ra,0x0
 202:	2dc080e7          	jalr	732(ra) # 4da <exit>
        for (j=0; j<(num_items*num_prods)/num_cons; j++) sem_consume();
 206:	00001717          	auipc	a4,0x1
 20a:	9ba72703          	lw	a4,-1606(a4) # bc0 <num_items>
 20e:	00001797          	auipc	a5,0x1
 212:	9ae7a783          	lw	a5,-1618(a5) # bbc <num_prods>
 216:	02e787bb          	mulw	a5,a5,a4
 21a:	00001717          	auipc	a4,0x1
 21e:	99e72703          	lw	a4,-1634(a4) # bb8 <num_cons>
 222:	02e7c7bb          	divw	a5,a5,a4
 226:	02f05f63          	blez	a5,264 <main+0x24a>
 22a:	00001a17          	auipc	s4,0x1
 22e:	996a0a13          	addi	s4,s4,-1642 # bc0 <num_items>
 232:	00001997          	auipc	s3,0x1
 236:	98a98993          	addi	s3,s3,-1654 # bbc <num_prods>
 23a:	00001917          	auipc	s2,0x1
 23e:	97e90913          	addi	s2,s2,-1666 # bb8 <num_cons>
 242:	00000097          	auipc	ra,0x0
 246:	3ce080e7          	jalr	974(ra) # 610 <sem_consume>
 24a:	2485                	addiw	s1,s1,1
 24c:	000a2703          	lw	a4,0(s4)
 250:	0009a783          	lw	a5,0(s3)
 254:	02e787bb          	mulw	a5,a5,a4
 258:	00092703          	lw	a4,0(s2)
 25c:	02e7c7bb          	divw	a5,a5,a4
 260:	fef4c1e3          	blt	s1,a5,242 <main+0x228>
        exit(0);
 264:	4501                	li	a0,0
 266:	00000097          	auipc	ra,0x0
 26a:	274080e7          	jalr	628(ra) # 4da <exit>

000000000000026e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 274:	87aa                	mv	a5,a0
 276:	0585                	addi	a1,a1,1
 278:	0785                	addi	a5,a5,1
 27a:	fff5c703          	lbu	a4,-1(a1)
 27e:	fee78fa3          	sb	a4,-1(a5)
 282:	fb75                	bnez	a4,276 <strcpy+0x8>
    ;
  return os;
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret

000000000000028a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 290:	00054783          	lbu	a5,0(a0)
 294:	cb91                	beqz	a5,2a8 <strcmp+0x1e>
 296:	0005c703          	lbu	a4,0(a1)
 29a:	00f71763          	bne	a4,a5,2a8 <strcmp+0x1e>
    p++, q++;
 29e:	0505                	addi	a0,a0,1
 2a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2a2:	00054783          	lbu	a5,0(a0)
 2a6:	fbe5                	bnez	a5,296 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2a8:	0005c503          	lbu	a0,0(a1)
}
 2ac:	40a7853b          	subw	a0,a5,a0
 2b0:	6422                	ld	s0,8(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret

00000000000002b6 <strlen>:

uint
strlen(const char *s)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2bc:	00054783          	lbu	a5,0(a0)
 2c0:	cf91                	beqz	a5,2dc <strlen+0x26>
 2c2:	0505                	addi	a0,a0,1
 2c4:	87aa                	mv	a5,a0
 2c6:	4685                	li	a3,1
 2c8:	9e89                	subw	a3,a3,a0
 2ca:	00f6853b          	addw	a0,a3,a5
 2ce:	0785                	addi	a5,a5,1
 2d0:	fff7c703          	lbu	a4,-1(a5)
 2d4:	fb7d                	bnez	a4,2ca <strlen+0x14>
    ;
  return n;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
  for(n = 0; s[n]; n++)
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <strlen+0x20>

00000000000002e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2e6:	ca19                	beqz	a2,2fc <memset+0x1c>
 2e8:	87aa                	mv	a5,a0
 2ea:	1602                	slli	a2,a2,0x20
 2ec:	9201                	srli	a2,a2,0x20
 2ee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2f6:	0785                	addi	a5,a5,1
 2f8:	fee79de3          	bne	a5,a4,2f2 <memset+0x12>
  }
  return dst;
}
 2fc:	6422                	ld	s0,8(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret

0000000000000302 <strchr>:

char*
strchr(const char *s, char c)
{
 302:	1141                	addi	sp,sp,-16
 304:	e422                	sd	s0,8(sp)
 306:	0800                	addi	s0,sp,16
  for(; *s; s++)
 308:	00054783          	lbu	a5,0(a0)
 30c:	cb99                	beqz	a5,322 <strchr+0x20>
    if(*s == c)
 30e:	00f58763          	beq	a1,a5,31c <strchr+0x1a>
  for(; *s; s++)
 312:	0505                	addi	a0,a0,1
 314:	00054783          	lbu	a5,0(a0)
 318:	fbfd                	bnez	a5,30e <strchr+0xc>
      return (char*)s;
  return 0;
 31a:	4501                	li	a0,0
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
  return 0;
 322:	4501                	li	a0,0
 324:	bfe5                	j	31c <strchr+0x1a>

0000000000000326 <gets>:

char*
gets(char *buf, int max)
{
 326:	711d                	addi	sp,sp,-96
 328:	ec86                	sd	ra,88(sp)
 32a:	e8a2                	sd	s0,80(sp)
 32c:	e4a6                	sd	s1,72(sp)
 32e:	e0ca                	sd	s2,64(sp)
 330:	fc4e                	sd	s3,56(sp)
 332:	f852                	sd	s4,48(sp)
 334:	f456                	sd	s5,40(sp)
 336:	f05a                	sd	s6,32(sp)
 338:	ec5e                	sd	s7,24(sp)
 33a:	1080                	addi	s0,sp,96
 33c:	8baa                	mv	s7,a0
 33e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 340:	892a                	mv	s2,a0
 342:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 344:	4aa9                	li	s5,10
 346:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 348:	89a6                	mv	s3,s1
 34a:	2485                	addiw	s1,s1,1
 34c:	0344d863          	bge	s1,s4,37c <gets+0x56>
    cc = read(0, &c, 1);
 350:	4605                	li	a2,1
 352:	faf40593          	addi	a1,s0,-81
 356:	4501                	li	a0,0
 358:	00000097          	auipc	ra,0x0
 35c:	19a080e7          	jalr	410(ra) # 4f2 <read>
    if(cc < 1)
 360:	00a05e63          	blez	a0,37c <gets+0x56>
    buf[i++] = c;
 364:	faf44783          	lbu	a5,-81(s0)
 368:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 36c:	01578763          	beq	a5,s5,37a <gets+0x54>
 370:	0905                	addi	s2,s2,1
 372:	fd679be3          	bne	a5,s6,348 <gets+0x22>
  for(i=0; i+1 < max; ){
 376:	89a6                	mv	s3,s1
 378:	a011                	j	37c <gets+0x56>
 37a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 37c:	99de                	add	s3,s3,s7
 37e:	00098023          	sb	zero,0(s3)
  return buf;
}
 382:	855e                	mv	a0,s7
 384:	60e6                	ld	ra,88(sp)
 386:	6446                	ld	s0,80(sp)
 388:	64a6                	ld	s1,72(sp)
 38a:	6906                	ld	s2,64(sp)
 38c:	79e2                	ld	s3,56(sp)
 38e:	7a42                	ld	s4,48(sp)
 390:	7aa2                	ld	s5,40(sp)
 392:	7b02                	ld	s6,32(sp)
 394:	6be2                	ld	s7,24(sp)
 396:	6125                	addi	sp,sp,96
 398:	8082                	ret

000000000000039a <stat>:

int
stat(const char *n, struct stat *st)
{
 39a:	1101                	addi	sp,sp,-32
 39c:	ec06                	sd	ra,24(sp)
 39e:	e822                	sd	s0,16(sp)
 3a0:	e426                	sd	s1,8(sp)
 3a2:	e04a                	sd	s2,0(sp)
 3a4:	1000                	addi	s0,sp,32
 3a6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a8:	4581                	li	a1,0
 3aa:	00000097          	auipc	ra,0x0
 3ae:	170080e7          	jalr	368(ra) # 51a <open>
  if(fd < 0)
 3b2:	02054563          	bltz	a0,3dc <stat+0x42>
 3b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3b8:	85ca                	mv	a1,s2
 3ba:	00000097          	auipc	ra,0x0
 3be:	178080e7          	jalr	376(ra) # 532 <fstat>
 3c2:	892a                	mv	s2,a0
  close(fd);
 3c4:	8526                	mv	a0,s1
 3c6:	00000097          	auipc	ra,0x0
 3ca:	13c080e7          	jalr	316(ra) # 502 <close>
  return r;
}
 3ce:	854a                	mv	a0,s2
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	64a2                	ld	s1,8(sp)
 3d6:	6902                	ld	s2,0(sp)
 3d8:	6105                	addi	sp,sp,32
 3da:	8082                	ret
    return -1;
 3dc:	597d                	li	s2,-1
 3de:	bfc5                	j	3ce <stat+0x34>

00000000000003e0 <atoi>:

int
atoi(const char *s)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e6:	00054683          	lbu	a3,0(a0)
 3ea:	fd06879b          	addiw	a5,a3,-48
 3ee:	0ff7f793          	zext.b	a5,a5
 3f2:	4625                	li	a2,9
 3f4:	02f66863          	bltu	a2,a5,424 <atoi+0x44>
 3f8:	872a                	mv	a4,a0
  n = 0;
 3fa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3fc:	0705                	addi	a4,a4,1
 3fe:	0025179b          	slliw	a5,a0,0x2
 402:	9fa9                	addw	a5,a5,a0
 404:	0017979b          	slliw	a5,a5,0x1
 408:	9fb5                	addw	a5,a5,a3
 40a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40e:	00074683          	lbu	a3,0(a4)
 412:	fd06879b          	addiw	a5,a3,-48
 416:	0ff7f793          	zext.b	a5,a5
 41a:	fef671e3          	bgeu	a2,a5,3fc <atoi+0x1c>
  return n;
}
 41e:	6422                	ld	s0,8(sp)
 420:	0141                	addi	sp,sp,16
 422:	8082                	ret
  n = 0;
 424:	4501                	li	a0,0
 426:	bfe5                	j	41e <atoi+0x3e>

0000000000000428 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 428:	1141                	addi	sp,sp,-16
 42a:	e422                	sd	s0,8(sp)
 42c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42e:	02b57463          	bgeu	a0,a1,456 <memmove+0x2e>
    while(n-- > 0)
 432:	00c05f63          	blez	a2,450 <memmove+0x28>
 436:	1602                	slli	a2,a2,0x20
 438:	9201                	srli	a2,a2,0x20
 43a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43e:	872a                	mv	a4,a0
      *dst++ = *src++;
 440:	0585                	addi	a1,a1,1
 442:	0705                	addi	a4,a4,1
 444:	fff5c683          	lbu	a3,-1(a1)
 448:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 44c:	fee79ae3          	bne	a5,a4,440 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 450:	6422                	ld	s0,8(sp)
 452:	0141                	addi	sp,sp,16
 454:	8082                	ret
    dst += n;
 456:	00c50733          	add	a4,a0,a2
    src += n;
 45a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 45c:	fec05ae3          	blez	a2,450 <memmove+0x28>
 460:	fff6079b          	addiw	a5,a2,-1
 464:	1782                	slli	a5,a5,0x20
 466:	9381                	srli	a5,a5,0x20
 468:	fff7c793          	not	a5,a5
 46c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46e:	15fd                	addi	a1,a1,-1
 470:	177d                	addi	a4,a4,-1
 472:	0005c683          	lbu	a3,0(a1)
 476:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 47a:	fee79ae3          	bne	a5,a4,46e <memmove+0x46>
 47e:	bfc9                	j	450 <memmove+0x28>

0000000000000480 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 480:	1141                	addi	sp,sp,-16
 482:	e422                	sd	s0,8(sp)
 484:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 486:	ca05                	beqz	a2,4b6 <memcmp+0x36>
 488:	fff6069b          	addiw	a3,a2,-1
 48c:	1682                	slli	a3,a3,0x20
 48e:	9281                	srli	a3,a3,0x20
 490:	0685                	addi	a3,a3,1
 492:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 494:	00054783          	lbu	a5,0(a0)
 498:	0005c703          	lbu	a4,0(a1)
 49c:	00e79863          	bne	a5,a4,4ac <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4a0:	0505                	addi	a0,a0,1
    p2++;
 4a2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a4:	fed518e3          	bne	a0,a3,494 <memcmp+0x14>
  }
  return 0;
 4a8:	4501                	li	a0,0
 4aa:	a019                	j	4b0 <memcmp+0x30>
      return *p1 - *p2;
 4ac:	40e7853b          	subw	a0,a5,a4
}
 4b0:	6422                	ld	s0,8(sp)
 4b2:	0141                	addi	sp,sp,16
 4b4:	8082                	ret
  return 0;
 4b6:	4501                	li	a0,0
 4b8:	bfe5                	j	4b0 <memcmp+0x30>

00000000000004ba <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e406                	sd	ra,8(sp)
 4be:	e022                	sd	s0,0(sp)
 4c0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c2:	00000097          	auipc	ra,0x0
 4c6:	f66080e7          	jalr	-154(ra) # 428 <memmove>
}
 4ca:	60a2                	ld	ra,8(sp)
 4cc:	6402                	ld	s0,0(sp)
 4ce:	0141                	addi	sp,sp,16
 4d0:	8082                	ret

00000000000004d2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4d2:	4885                	li	a7,1
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <exit>:
.global exit
exit:
 li a7, SYS_exit
 4da:	4889                	li	a7,2
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4e2:	488d                	li	a7,3
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4ea:	4891                	li	a7,4
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <read>:
.global read
read:
 li a7, SYS_read
 4f2:	4895                	li	a7,5
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <write>:
.global write
write:
 li a7, SYS_write
 4fa:	48c1                	li	a7,16
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <close>:
.global close
close:
 li a7, SYS_close
 502:	48d5                	li	a7,21
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <kill>:
.global kill
kill:
 li a7, SYS_kill
 50a:	4899                	li	a7,6
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <exec>:
.global exec
exec:
 li a7, SYS_exec
 512:	489d                	li	a7,7
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <open>:
.global open
open:
 li a7, SYS_open
 51a:	48bd                	li	a7,15
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 522:	48c5                	li	a7,17
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 52a:	48c9                	li	a7,18
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 532:	48a1                	li	a7,8
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <link>:
.global link
link:
 li a7, SYS_link
 53a:	48cd                	li	a7,19
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 542:	48d1                	li	a7,20
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 54a:	48a5                	li	a7,9
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <dup>:
.global dup
dup:
 li a7, SYS_dup
 552:	48a9                	li	a7,10
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 55a:	48ad                	li	a7,11
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 562:	48b1                	li	a7,12
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 56a:	48b5                	li	a7,13
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 572:	48b9                	li	a7,14
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 57a:	48d9                	li	a7,22
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <yield>:
.global yield
yield:
 li a7, SYS_yield
 582:	48dd                	li	a7,23
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 58a:	48e1                	li	a7,24
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 592:	48e5                	li	a7,25
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 59a:	48e9                	li	a7,26
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <ps>:
.global ps
ps:
 li a7, SYS_ps
 5a2:	48ed                	li	a7,27
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 5aa:	48f1                	li	a7,28
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 5b2:	48f5                	li	a7,29
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 5ba:	48f9                	li	a7,30
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 5c2:	02100893          	li	a7,33
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 5cc:	48fd                	li	a7,31
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 5d4:	02000893          	li	a7,32
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 5de:	02200893          	li	a7,34
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 5e8:	02300893          	li	a7,35
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 5f2:	02400893          	li	a7,36
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 5fc:	02500893          	li	a7,37
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 606:	02700893          	li	a7,39
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 610:	02600893          	li	a7,38
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 61a:	1101                	addi	sp,sp,-32
 61c:	ec06                	sd	ra,24(sp)
 61e:	e822                	sd	s0,16(sp)
 620:	1000                	addi	s0,sp,32
 622:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 626:	4605                	li	a2,1
 628:	fef40593          	addi	a1,s0,-17
 62c:	00000097          	auipc	ra,0x0
 630:	ece080e7          	jalr	-306(ra) # 4fa <write>
}
 634:	60e2                	ld	ra,24(sp)
 636:	6442                	ld	s0,16(sp)
 638:	6105                	addi	sp,sp,32
 63a:	8082                	ret

000000000000063c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 63c:	7139                	addi	sp,sp,-64
 63e:	fc06                	sd	ra,56(sp)
 640:	f822                	sd	s0,48(sp)
 642:	f426                	sd	s1,40(sp)
 644:	f04a                	sd	s2,32(sp)
 646:	ec4e                	sd	s3,24(sp)
 648:	0080                	addi	s0,sp,64
 64a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 64c:	c299                	beqz	a3,652 <printint+0x16>
 64e:	0805c963          	bltz	a1,6e0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 652:	2581                	sext.w	a1,a1
  neg = 0;
 654:	4881                	li	a7,0
 656:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 65a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 65c:	2601                	sext.w	a2,a2
 65e:	00000517          	auipc	a0,0x0
 662:	54250513          	addi	a0,a0,1346 # ba0 <digits>
 666:	883a                	mv	a6,a4
 668:	2705                	addiw	a4,a4,1
 66a:	02c5f7bb          	remuw	a5,a1,a2
 66e:	1782                	slli	a5,a5,0x20
 670:	9381                	srli	a5,a5,0x20
 672:	97aa                	add	a5,a5,a0
 674:	0007c783          	lbu	a5,0(a5)
 678:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 67c:	0005879b          	sext.w	a5,a1
 680:	02c5d5bb          	divuw	a1,a1,a2
 684:	0685                	addi	a3,a3,1
 686:	fec7f0e3          	bgeu	a5,a2,666 <printint+0x2a>
  if(neg)
 68a:	00088c63          	beqz	a7,6a2 <printint+0x66>
    buf[i++] = '-';
 68e:	fd070793          	addi	a5,a4,-48
 692:	00878733          	add	a4,a5,s0
 696:	02d00793          	li	a5,45
 69a:	fef70823          	sb	a5,-16(a4)
 69e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6a2:	02e05863          	blez	a4,6d2 <printint+0x96>
 6a6:	fc040793          	addi	a5,s0,-64
 6aa:	00e78933          	add	s2,a5,a4
 6ae:	fff78993          	addi	s3,a5,-1
 6b2:	99ba                	add	s3,s3,a4
 6b4:	377d                	addiw	a4,a4,-1
 6b6:	1702                	slli	a4,a4,0x20
 6b8:	9301                	srli	a4,a4,0x20
 6ba:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6be:	fff94583          	lbu	a1,-1(s2)
 6c2:	8526                	mv	a0,s1
 6c4:	00000097          	auipc	ra,0x0
 6c8:	f56080e7          	jalr	-170(ra) # 61a <putc>
  while(--i >= 0)
 6cc:	197d                	addi	s2,s2,-1
 6ce:	ff3918e3          	bne	s2,s3,6be <printint+0x82>
}
 6d2:	70e2                	ld	ra,56(sp)
 6d4:	7442                	ld	s0,48(sp)
 6d6:	74a2                	ld	s1,40(sp)
 6d8:	7902                	ld	s2,32(sp)
 6da:	69e2                	ld	s3,24(sp)
 6dc:	6121                	addi	sp,sp,64
 6de:	8082                	ret
    x = -xx;
 6e0:	40b005bb          	negw	a1,a1
    neg = 1;
 6e4:	4885                	li	a7,1
    x = -xx;
 6e6:	bf85                	j	656 <printint+0x1a>

00000000000006e8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6e8:	7119                	addi	sp,sp,-128
 6ea:	fc86                	sd	ra,120(sp)
 6ec:	f8a2                	sd	s0,112(sp)
 6ee:	f4a6                	sd	s1,104(sp)
 6f0:	f0ca                	sd	s2,96(sp)
 6f2:	ecce                	sd	s3,88(sp)
 6f4:	e8d2                	sd	s4,80(sp)
 6f6:	e4d6                	sd	s5,72(sp)
 6f8:	e0da                	sd	s6,64(sp)
 6fa:	fc5e                	sd	s7,56(sp)
 6fc:	f862                	sd	s8,48(sp)
 6fe:	f466                	sd	s9,40(sp)
 700:	f06a                	sd	s10,32(sp)
 702:	ec6e                	sd	s11,24(sp)
 704:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 706:	0005c903          	lbu	s2,0(a1)
 70a:	18090f63          	beqz	s2,8a8 <vprintf+0x1c0>
 70e:	8aaa                	mv	s5,a0
 710:	8b32                	mv	s6,a2
 712:	00158493          	addi	s1,a1,1
  state = 0;
 716:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 718:	02500a13          	li	s4,37
 71c:	4c55                	li	s8,21
 71e:	00000c97          	auipc	s9,0x0
 722:	42ac8c93          	addi	s9,s9,1066 # b48 <malloc+0x19c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 726:	02800d93          	li	s11,40
  putc(fd, 'x');
 72a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72c:	00000b97          	auipc	s7,0x0
 730:	474b8b93          	addi	s7,s7,1140 # ba0 <digits>
 734:	a839                	j	752 <vprintf+0x6a>
        putc(fd, c);
 736:	85ca                	mv	a1,s2
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	ee0080e7          	jalr	-288(ra) # 61a <putc>
 742:	a019                	j	748 <vprintf+0x60>
    } else if(state == '%'){
 744:	01498d63          	beq	s3,s4,75e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 748:	0485                	addi	s1,s1,1
 74a:	fff4c903          	lbu	s2,-1(s1)
 74e:	14090d63          	beqz	s2,8a8 <vprintf+0x1c0>
    if(state == 0){
 752:	fe0999e3          	bnez	s3,744 <vprintf+0x5c>
      if(c == '%'){
 756:	ff4910e3          	bne	s2,s4,736 <vprintf+0x4e>
        state = '%';
 75a:	89d2                	mv	s3,s4
 75c:	b7f5                	j	748 <vprintf+0x60>
      if(c == 'd'){
 75e:	11490c63          	beq	s2,s4,876 <vprintf+0x18e>
 762:	f9d9079b          	addiw	a5,s2,-99
 766:	0ff7f793          	zext.b	a5,a5
 76a:	10fc6e63          	bltu	s8,a5,886 <vprintf+0x19e>
 76e:	f9d9079b          	addiw	a5,s2,-99
 772:	0ff7f713          	zext.b	a4,a5
 776:	10ec6863          	bltu	s8,a4,886 <vprintf+0x19e>
 77a:	00271793          	slli	a5,a4,0x2
 77e:	97e6                	add	a5,a5,s9
 780:	439c                	lw	a5,0(a5)
 782:	97e6                	add	a5,a5,s9
 784:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 786:	008b0913          	addi	s2,s6,8
 78a:	4685                	li	a3,1
 78c:	4629                	li	a2,10
 78e:	000b2583          	lw	a1,0(s6)
 792:	8556                	mv	a0,s5
 794:	00000097          	auipc	ra,0x0
 798:	ea8080e7          	jalr	-344(ra) # 63c <printint>
 79c:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b765                	j	748 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a2:	008b0913          	addi	s2,s6,8
 7a6:	4681                	li	a3,0
 7a8:	4629                	li	a2,10
 7aa:	000b2583          	lw	a1,0(s6)
 7ae:	8556                	mv	a0,s5
 7b0:	00000097          	auipc	ra,0x0
 7b4:	e8c080e7          	jalr	-372(ra) # 63c <printint>
 7b8:	8b4a                	mv	s6,s2
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b771                	j	748 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7be:	008b0913          	addi	s2,s6,8
 7c2:	4681                	li	a3,0
 7c4:	866a                	mv	a2,s10
 7c6:	000b2583          	lw	a1,0(s6)
 7ca:	8556                	mv	a0,s5
 7cc:	00000097          	auipc	ra,0x0
 7d0:	e70080e7          	jalr	-400(ra) # 63c <printint>
 7d4:	8b4a                	mv	s6,s2
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bf85                	j	748 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7da:	008b0793          	addi	a5,s6,8
 7de:	f8f43423          	sd	a5,-120(s0)
 7e2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7e6:	03000593          	li	a1,48
 7ea:	8556                	mv	a0,s5
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e2e080e7          	jalr	-466(ra) # 61a <putc>
  putc(fd, 'x');
 7f4:	07800593          	li	a1,120
 7f8:	8556                	mv	a0,s5
 7fa:	00000097          	auipc	ra,0x0
 7fe:	e20080e7          	jalr	-480(ra) # 61a <putc>
 802:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 804:	03c9d793          	srli	a5,s3,0x3c
 808:	97de                	add	a5,a5,s7
 80a:	0007c583          	lbu	a1,0(a5)
 80e:	8556                	mv	a0,s5
 810:	00000097          	auipc	ra,0x0
 814:	e0a080e7          	jalr	-502(ra) # 61a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 818:	0992                	slli	s3,s3,0x4
 81a:	397d                	addiw	s2,s2,-1
 81c:	fe0914e3          	bnez	s2,804 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 820:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 824:	4981                	li	s3,0
 826:	b70d                	j	748 <vprintf+0x60>
        s = va_arg(ap, char*);
 828:	008b0913          	addi	s2,s6,8
 82c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 830:	02098163          	beqz	s3,852 <vprintf+0x16a>
        while(*s != 0){
 834:	0009c583          	lbu	a1,0(s3)
 838:	c5ad                	beqz	a1,8a2 <vprintf+0x1ba>
          putc(fd, *s);
 83a:	8556                	mv	a0,s5
 83c:	00000097          	auipc	ra,0x0
 840:	dde080e7          	jalr	-546(ra) # 61a <putc>
          s++;
 844:	0985                	addi	s3,s3,1
        while(*s != 0){
 846:	0009c583          	lbu	a1,0(s3)
 84a:	f9e5                	bnez	a1,83a <vprintf+0x152>
        s = va_arg(ap, char*);
 84c:	8b4a                	mv	s6,s2
      state = 0;
 84e:	4981                	li	s3,0
 850:	bde5                	j	748 <vprintf+0x60>
          s = "(null)";
 852:	00000997          	auipc	s3,0x0
 856:	2ee98993          	addi	s3,s3,750 # b40 <malloc+0x194>
        while(*s != 0){
 85a:	85ee                	mv	a1,s11
 85c:	bff9                	j	83a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 85e:	008b0913          	addi	s2,s6,8
 862:	000b4583          	lbu	a1,0(s6)
 866:	8556                	mv	a0,s5
 868:	00000097          	auipc	ra,0x0
 86c:	db2080e7          	jalr	-590(ra) # 61a <putc>
 870:	8b4a                	mv	s6,s2
      state = 0;
 872:	4981                	li	s3,0
 874:	bdd1                	j	748 <vprintf+0x60>
        putc(fd, c);
 876:	85d2                	mv	a1,s4
 878:	8556                	mv	a0,s5
 87a:	00000097          	auipc	ra,0x0
 87e:	da0080e7          	jalr	-608(ra) # 61a <putc>
      state = 0;
 882:	4981                	li	s3,0
 884:	b5d1                	j	748 <vprintf+0x60>
        putc(fd, '%');
 886:	85d2                	mv	a1,s4
 888:	8556                	mv	a0,s5
 88a:	00000097          	auipc	ra,0x0
 88e:	d90080e7          	jalr	-624(ra) # 61a <putc>
        putc(fd, c);
 892:	85ca                	mv	a1,s2
 894:	8556                	mv	a0,s5
 896:	00000097          	auipc	ra,0x0
 89a:	d84080e7          	jalr	-636(ra) # 61a <putc>
      state = 0;
 89e:	4981                	li	s3,0
 8a0:	b565                	j	748 <vprintf+0x60>
        s = va_arg(ap, char*);
 8a2:	8b4a                	mv	s6,s2
      state = 0;
 8a4:	4981                	li	s3,0
 8a6:	b54d                	j	748 <vprintf+0x60>
    }
  }
}
 8a8:	70e6                	ld	ra,120(sp)
 8aa:	7446                	ld	s0,112(sp)
 8ac:	74a6                	ld	s1,104(sp)
 8ae:	7906                	ld	s2,96(sp)
 8b0:	69e6                	ld	s3,88(sp)
 8b2:	6a46                	ld	s4,80(sp)
 8b4:	6aa6                	ld	s5,72(sp)
 8b6:	6b06                	ld	s6,64(sp)
 8b8:	7be2                	ld	s7,56(sp)
 8ba:	7c42                	ld	s8,48(sp)
 8bc:	7ca2                	ld	s9,40(sp)
 8be:	7d02                	ld	s10,32(sp)
 8c0:	6de2                	ld	s11,24(sp)
 8c2:	6109                	addi	sp,sp,128
 8c4:	8082                	ret

00000000000008c6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8c6:	715d                	addi	sp,sp,-80
 8c8:	ec06                	sd	ra,24(sp)
 8ca:	e822                	sd	s0,16(sp)
 8cc:	1000                	addi	s0,sp,32
 8ce:	e010                	sd	a2,0(s0)
 8d0:	e414                	sd	a3,8(s0)
 8d2:	e818                	sd	a4,16(s0)
 8d4:	ec1c                	sd	a5,24(s0)
 8d6:	03043023          	sd	a6,32(s0)
 8da:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8de:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8e2:	8622                	mv	a2,s0
 8e4:	00000097          	auipc	ra,0x0
 8e8:	e04080e7          	jalr	-508(ra) # 6e8 <vprintf>
}
 8ec:	60e2                	ld	ra,24(sp)
 8ee:	6442                	ld	s0,16(sp)
 8f0:	6161                	addi	sp,sp,80
 8f2:	8082                	ret

00000000000008f4 <printf>:

void
printf(const char *fmt, ...)
{
 8f4:	711d                	addi	sp,sp,-96
 8f6:	ec06                	sd	ra,24(sp)
 8f8:	e822                	sd	s0,16(sp)
 8fa:	1000                	addi	s0,sp,32
 8fc:	e40c                	sd	a1,8(s0)
 8fe:	e810                	sd	a2,16(s0)
 900:	ec14                	sd	a3,24(s0)
 902:	f018                	sd	a4,32(s0)
 904:	f41c                	sd	a5,40(s0)
 906:	03043823          	sd	a6,48(s0)
 90a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 90e:	00840613          	addi	a2,s0,8
 912:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 916:	85aa                	mv	a1,a0
 918:	4505                	li	a0,1
 91a:	00000097          	auipc	ra,0x0
 91e:	dce080e7          	jalr	-562(ra) # 6e8 <vprintf>
}
 922:	60e2                	ld	ra,24(sp)
 924:	6442                	ld	s0,16(sp)
 926:	6125                	addi	sp,sp,96
 928:	8082                	ret

000000000000092a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 92a:	1141                	addi	sp,sp,-16
 92c:	e422                	sd	s0,8(sp)
 92e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 930:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 934:	00000797          	auipc	a5,0x0
 938:	2947b783          	ld	a5,660(a5) # bc8 <freep>
 93c:	a02d                	j	966 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 93e:	4618                	lw	a4,8(a2)
 940:	9f2d                	addw	a4,a4,a1
 942:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 946:	6398                	ld	a4,0(a5)
 948:	6310                	ld	a2,0(a4)
 94a:	a83d                	j	988 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 94c:	ff852703          	lw	a4,-8(a0)
 950:	9f31                	addw	a4,a4,a2
 952:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 954:	ff053683          	ld	a3,-16(a0)
 958:	a091                	j	99c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 95a:	6398                	ld	a4,0(a5)
 95c:	00e7e463          	bltu	a5,a4,964 <free+0x3a>
 960:	00e6ea63          	bltu	a3,a4,974 <free+0x4a>
{
 964:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 966:	fed7fae3          	bgeu	a5,a3,95a <free+0x30>
 96a:	6398                	ld	a4,0(a5)
 96c:	00e6e463          	bltu	a3,a4,974 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 970:	fee7eae3          	bltu	a5,a4,964 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 974:	ff852583          	lw	a1,-8(a0)
 978:	6390                	ld	a2,0(a5)
 97a:	02059813          	slli	a6,a1,0x20
 97e:	01c85713          	srli	a4,a6,0x1c
 982:	9736                	add	a4,a4,a3
 984:	fae60de3          	beq	a2,a4,93e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 988:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 98c:	4790                	lw	a2,8(a5)
 98e:	02061593          	slli	a1,a2,0x20
 992:	01c5d713          	srli	a4,a1,0x1c
 996:	973e                	add	a4,a4,a5
 998:	fae68ae3          	beq	a3,a4,94c <free+0x22>
    p->s.ptr = bp->s.ptr;
 99c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 99e:	00000717          	auipc	a4,0x0
 9a2:	22f73523          	sd	a5,554(a4) # bc8 <freep>
}
 9a6:	6422                	ld	s0,8(sp)
 9a8:	0141                	addi	sp,sp,16
 9aa:	8082                	ret

00000000000009ac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ac:	7139                	addi	sp,sp,-64
 9ae:	fc06                	sd	ra,56(sp)
 9b0:	f822                	sd	s0,48(sp)
 9b2:	f426                	sd	s1,40(sp)
 9b4:	f04a                	sd	s2,32(sp)
 9b6:	ec4e                	sd	s3,24(sp)
 9b8:	e852                	sd	s4,16(sp)
 9ba:	e456                	sd	s5,8(sp)
 9bc:	e05a                	sd	s6,0(sp)
 9be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c0:	02051493          	slli	s1,a0,0x20
 9c4:	9081                	srli	s1,s1,0x20
 9c6:	04bd                	addi	s1,s1,15
 9c8:	8091                	srli	s1,s1,0x4
 9ca:	0014899b          	addiw	s3,s1,1
 9ce:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9d0:	00000517          	auipc	a0,0x0
 9d4:	1f853503          	ld	a0,504(a0) # bc8 <freep>
 9d8:	c515                	beqz	a0,a04 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9dc:	4798                	lw	a4,8(a5)
 9de:	02977f63          	bgeu	a4,s1,a1c <malloc+0x70>
 9e2:	8a4e                	mv	s4,s3
 9e4:	0009871b          	sext.w	a4,s3
 9e8:	6685                	lui	a3,0x1
 9ea:	00d77363          	bgeu	a4,a3,9f0 <malloc+0x44>
 9ee:	6a05                	lui	s4,0x1
 9f0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9f4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9f8:	00000917          	auipc	s2,0x0
 9fc:	1d090913          	addi	s2,s2,464 # bc8 <freep>
  if(p == (char*)-1)
 a00:	5afd                	li	s5,-1
 a02:	a895                	j	a76 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a04:	00000797          	auipc	a5,0x0
 a08:	1cc78793          	addi	a5,a5,460 # bd0 <base>
 a0c:	00000717          	auipc	a4,0x0
 a10:	1af73e23          	sd	a5,444(a4) # bc8 <freep>
 a14:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a16:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a1a:	b7e1                	j	9e2 <malloc+0x36>
      if(p->s.size == nunits)
 a1c:	02e48c63          	beq	s1,a4,a54 <malloc+0xa8>
        p->s.size -= nunits;
 a20:	4137073b          	subw	a4,a4,s3
 a24:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a26:	02071693          	slli	a3,a4,0x20
 a2a:	01c6d713          	srli	a4,a3,0x1c
 a2e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a30:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a34:	00000717          	auipc	a4,0x0
 a38:	18a73a23          	sd	a0,404(a4) # bc8 <freep>
      return (void*)(p + 1);
 a3c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a40:	70e2                	ld	ra,56(sp)
 a42:	7442                	ld	s0,48(sp)
 a44:	74a2                	ld	s1,40(sp)
 a46:	7902                	ld	s2,32(sp)
 a48:	69e2                	ld	s3,24(sp)
 a4a:	6a42                	ld	s4,16(sp)
 a4c:	6aa2                	ld	s5,8(sp)
 a4e:	6b02                	ld	s6,0(sp)
 a50:	6121                	addi	sp,sp,64
 a52:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a54:	6398                	ld	a4,0(a5)
 a56:	e118                	sd	a4,0(a0)
 a58:	bff1                	j	a34 <malloc+0x88>
  hp->s.size = nu;
 a5a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a5e:	0541                	addi	a0,a0,16
 a60:	00000097          	auipc	ra,0x0
 a64:	eca080e7          	jalr	-310(ra) # 92a <free>
  return freep;
 a68:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a6c:	d971                	beqz	a0,a40 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a6e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a70:	4798                	lw	a4,8(a5)
 a72:	fa9775e3          	bgeu	a4,s1,a1c <malloc+0x70>
    if(p == freep)
 a76:	00093703          	ld	a4,0(s2)
 a7a:	853e                	mv	a0,a5
 a7c:	fef719e3          	bne	a4,a5,a6e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a80:	8552                	mv	a0,s4
 a82:	00000097          	auipc	ra,0x0
 a86:	ae0080e7          	jalr	-1312(ra) # 562 <sbrk>
  if(p == (char*)-1)
 a8a:	fd5518e3          	bne	a0,s5,a5a <malloc+0xae>
        return 0;
 a8e:	4501                	li	a0,0
 a90:	bf45                	j	a40 <malloc+0x94>
