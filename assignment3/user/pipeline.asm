
user/_pipeline:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
  int pipefd[2], x, y, n, i;

  if (argc != 3) {
   e:	478d                	li	a5,3
  10:	02f50063          	beq	a0,a5,30 <main+0x30>
     fprintf(2, "syntax: pipeline n x\nAborting...\n");
  14:	00001597          	auipc	a1,0x1
  18:	9ec58593          	addi	a1,a1,-1556 # a00 <malloc+0xec>
  1c:	4509                	li	a0,2
  1e:	00001097          	auipc	ra,0x1
  22:	810080e7          	jalr	-2032(ra) # 82e <fprintf>
     exit(0);
  26:	4501                	li	a0,0
  28:	00000097          	auipc	ra,0x0
  2c:	41a080e7          	jalr	1050(ra) # 442 <exit>
  30:	84ae                	mv	s1,a1
  }
  n = atoi(argv[1]);
  32:	6588                	ld	a0,8(a1)
  34:	00000097          	auipc	ra,0x0
  38:	314080e7          	jalr	788(ra) # 348 <atoi>
  3c:	892a                	mv	s2,a0
  if (n <= 0) {
  3e:	0ea05663          	blez	a0,12a <main+0x12a>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  x = atoi(argv[2]);
  42:	6888                	ld	a0,16(s1)
  44:	00000097          	auipc	ra,0x0
  48:	304080e7          	jalr	772(ra) # 348 <atoi>
  4c:	fca42223          	sw	a0,-60(s0)

  x += getpid();
  50:	00000097          	auipc	ra,0x0
  54:	472080e7          	jalr	1138(ra) # 4c2 <getpid>
  58:	fc442783          	lw	a5,-60(s0)
  5c:	9fa9                	addw	a5,a5,a0
  5e:	fcf42223          	sw	a5,-60(s0)
  fprintf(1, "%d: %d\n", getpid(), x);
  62:	00000097          	auipc	ra,0x0
  66:	460080e7          	jalr	1120(ra) # 4c2 <getpid>
  6a:	862a                	mv	a2,a0
  6c:	fc442683          	lw	a3,-60(s0)
  70:	00001597          	auipc	a1,0x1
  74:	9d858593          	addi	a1,a1,-1576 # a48 <malloc+0x134>
  78:	4505                	li	a0,1
  7a:	00000097          	auipc	ra,0x0
  7e:	7b4080e7          	jalr	1972(ra) # 82e <fprintf>

  for (i=2; i<=n; i++) {
  82:	4785                	li	a5,1
  84:	1327d663          	bge	a5,s2,1b0 <main+0x1b0>
  88:	4489                	li	s1,2
        if (read(pipefd[0], &x, sizeof(int)) < 0) {
           fprintf(2, "Error: cannot read from pipe\nAborting...\n");
           exit(0);
        }
	x += getpid();
	fprintf(1, "%d: %d\n", getpid(), x);
  8a:	00001997          	auipc	s3,0x1
  8e:	9be98993          	addi	s3,s3,-1602 # a48 <malloc+0x134>
     if (pipe(pipefd) < 0) {
  92:	fc840513          	addi	a0,s0,-56
  96:	00000097          	auipc	ra,0x0
  9a:	3bc080e7          	jalr	956(ra) # 452 <pipe>
  9e:	0a054463          	bltz	a0,146 <main+0x146>
     if (write(pipefd[1], &x, sizeof(int)) < 0) {
  a2:	4611                	li	a2,4
  a4:	fc440593          	addi	a1,s0,-60
  a8:	fcc42503          	lw	a0,-52(s0)
  ac:	00000097          	auipc	ra,0x0
  b0:	3b6080e7          	jalr	950(ra) # 462 <write>
  b4:	0a054763          	bltz	a0,162 <main+0x162>
     close(pipefd[1]);
  b8:	fcc42503          	lw	a0,-52(s0)
  bc:	00000097          	auipc	ra,0x0
  c0:	3ae080e7          	jalr	942(ra) # 46a <close>
     y = fork();
  c4:	00000097          	auipc	ra,0x0
  c8:	376080e7          	jalr	886(ra) # 43a <fork>
     if (y < 0) {
  cc:	0a054963          	bltz	a0,17e <main+0x17e>
     else if (y > 0) {
  d0:	0ca04563          	bgtz	a0,19a <main+0x19a>
        if (read(pipefd[0], &x, sizeof(int)) < 0) {
  d4:	4611                	li	a2,4
  d6:	fc440593          	addi	a1,s0,-60
  da:	fc842503          	lw	a0,-56(s0)
  de:	00000097          	auipc	ra,0x0
  e2:	37c080e7          	jalr	892(ra) # 45a <read>
  e6:	0c054a63          	bltz	a0,1ba <main+0x1ba>
	x += getpid();
  ea:	00000097          	auipc	ra,0x0
  ee:	3d8080e7          	jalr	984(ra) # 4c2 <getpid>
  f2:	fc442783          	lw	a5,-60(s0)
  f6:	9fa9                	addw	a5,a5,a0
  f8:	fcf42223          	sw	a5,-60(s0)
	fprintf(1, "%d: %d\n", getpid(), x);
  fc:	00000097          	auipc	ra,0x0
 100:	3c6080e7          	jalr	966(ra) # 4c2 <getpid>
 104:	862a                	mv	a2,a0
 106:	fc442683          	lw	a3,-60(s0)
 10a:	85ce                	mv	a1,s3
 10c:	4505                	li	a0,1
 10e:	00000097          	auipc	ra,0x0
 112:	720080e7          	jalr	1824(ra) # 82e <fprintf>
	close(pipefd[0]);
 116:	fc842503          	lw	a0,-56(s0)
 11a:	00000097          	auipc	ra,0x0
 11e:	350080e7          	jalr	848(ra) # 46a <close>
  for (i=2; i<=n; i++) {
 122:	2485                	addiw	s1,s1,1
 124:	f69957e3          	bge	s2,s1,92 <main+0x92>
 128:	a061                	j	1b0 <main+0x1b0>
     fprintf(2, "Invalid input\nAborting...\n");
 12a:	00001597          	auipc	a1,0x1
 12e:	8fe58593          	addi	a1,a1,-1794 # a28 <malloc+0x114>
 132:	4509                	li	a0,2
 134:	00000097          	auipc	ra,0x0
 138:	6fa080e7          	jalr	1786(ra) # 82e <fprintf>
     exit(0);
 13c:	4501                	li	a0,0
 13e:	00000097          	auipc	ra,0x0
 142:	304080e7          	jalr	772(ra) # 442 <exit>
        fprintf(2, "Error: cannot create pipe\nAborting...\n");
 146:	00001597          	auipc	a1,0x1
 14a:	90a58593          	addi	a1,a1,-1782 # a50 <malloc+0x13c>
 14e:	4509                	li	a0,2
 150:	00000097          	auipc	ra,0x0
 154:	6de080e7          	jalr	1758(ra) # 82e <fprintf>
        exit(0);
 158:	4501                	li	a0,0
 15a:	00000097          	auipc	ra,0x0
 15e:	2e8080e7          	jalr	744(ra) # 442 <exit>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 162:	00001597          	auipc	a1,0x1
 166:	91658593          	addi	a1,a1,-1770 # a78 <malloc+0x164>
 16a:	4509                	li	a0,2
 16c:	00000097          	auipc	ra,0x0
 170:	6c2080e7          	jalr	1730(ra) # 82e <fprintf>
        exit(0);
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	2cc080e7          	jalr	716(ra) # 442 <exit>
        fprintf(2, "Error: cannot fork\nAborting...\n");
 17e:	00001597          	auipc	a1,0x1
 182:	92a58593          	addi	a1,a1,-1750 # aa8 <malloc+0x194>
 186:	4509                	li	a0,2
 188:	00000097          	auipc	ra,0x0
 18c:	6a6080e7          	jalr	1702(ra) # 82e <fprintf>
	exit(0);
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	2b0080e7          	jalr	688(ra) # 442 <exit>
	close(pipefd[0]);
 19a:	fc842503          	lw	a0,-56(s0)
 19e:	00000097          	auipc	ra,0x0
 1a2:	2cc080e7          	jalr	716(ra) # 46a <close>
        wait(0);
 1a6:	4501                	li	a0,0
 1a8:	00000097          	auipc	ra,0x0
 1ac:	2a2080e7          	jalr	674(ra) # 44a <wait>
     }
  }

  exit(0);
 1b0:	4501                	li	a0,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	290080e7          	jalr	656(ra) # 442 <exit>
           fprintf(2, "Error: cannot read from pipe\nAborting...\n");
 1ba:	00001597          	auipc	a1,0x1
 1be:	90e58593          	addi	a1,a1,-1778 # ac8 <malloc+0x1b4>
 1c2:	4509                	li	a0,2
 1c4:	00000097          	auipc	ra,0x0
 1c8:	66a080e7          	jalr	1642(ra) # 82e <fprintf>
           exit(0);
 1cc:	4501                	li	a0,0
 1ce:	00000097          	auipc	ra,0x0
 1d2:	274080e7          	jalr	628(ra) # 442 <exit>

00000000000001d6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1dc:	87aa                	mv	a5,a0
 1de:	0585                	addi	a1,a1,1
 1e0:	0785                	addi	a5,a5,1
 1e2:	fff5c703          	lbu	a4,-1(a1)
 1e6:	fee78fa3          	sb	a4,-1(a5)
 1ea:	fb75                	bnez	a4,1de <strcpy+0x8>
    ;
  return os;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret

00000000000001f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	cb91                	beqz	a5,210 <strcmp+0x1e>
 1fe:	0005c703          	lbu	a4,0(a1)
 202:	00f71763          	bne	a4,a5,210 <strcmp+0x1e>
    p++, q++;
 206:	0505                	addi	a0,a0,1
 208:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	fbe5                	bnez	a5,1fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 210:	0005c503          	lbu	a0,0(a1)
}
 214:	40a7853b          	subw	a0,a5,a0
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret

000000000000021e <strlen>:

uint
strlen(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 224:	00054783          	lbu	a5,0(a0)
 228:	cf91                	beqz	a5,244 <strlen+0x26>
 22a:	0505                	addi	a0,a0,1
 22c:	87aa                	mv	a5,a0
 22e:	4685                	li	a3,1
 230:	9e89                	subw	a3,a3,a0
 232:	00f6853b          	addw	a0,a3,a5
 236:	0785                	addi	a5,a5,1
 238:	fff7c703          	lbu	a4,-1(a5)
 23c:	fb7d                	bnez	a4,232 <strlen+0x14>
    ;
  return n;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret
  for(n = 0; s[n]; n++)
 244:	4501                	li	a0,0
 246:	bfe5                	j	23e <strlen+0x20>

0000000000000248 <memset>:

void*
memset(void *dst, int c, uint n)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 24e:	ca19                	beqz	a2,264 <memset+0x1c>
 250:	87aa                	mv	a5,a0
 252:	1602                	slli	a2,a2,0x20
 254:	9201                	srli	a2,a2,0x20
 256:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 25a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 25e:	0785                	addi	a5,a5,1
 260:	fee79de3          	bne	a5,a4,25a <memset+0x12>
  }
  return dst;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret

000000000000026a <strchr>:

char*
strchr(const char *s, char c)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 270:	00054783          	lbu	a5,0(a0)
 274:	cb99                	beqz	a5,28a <strchr+0x20>
    if(*s == c)
 276:	00f58763          	beq	a1,a5,284 <strchr+0x1a>
  for(; *s; s++)
 27a:	0505                	addi	a0,a0,1
 27c:	00054783          	lbu	a5,0(a0)
 280:	fbfd                	bnez	a5,276 <strchr+0xc>
      return (char*)s;
  return 0;
 282:	4501                	li	a0,0
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  return 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <strchr+0x1a>

000000000000028e <gets>:

char*
gets(char *buf, int max)
{
 28e:	711d                	addi	sp,sp,-96
 290:	ec86                	sd	ra,88(sp)
 292:	e8a2                	sd	s0,80(sp)
 294:	e4a6                	sd	s1,72(sp)
 296:	e0ca                	sd	s2,64(sp)
 298:	fc4e                	sd	s3,56(sp)
 29a:	f852                	sd	s4,48(sp)
 29c:	f456                	sd	s5,40(sp)
 29e:	f05a                	sd	s6,32(sp)
 2a0:	ec5e                	sd	s7,24(sp)
 2a2:	1080                	addi	s0,sp,96
 2a4:	8baa                	mv	s7,a0
 2a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a8:	892a                	mv	s2,a0
 2aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ac:	4aa9                	li	s5,10
 2ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2b0:	89a6                	mv	s3,s1
 2b2:	2485                	addiw	s1,s1,1
 2b4:	0344d863          	bge	s1,s4,2e4 <gets+0x56>
    cc = read(0, &c, 1);
 2b8:	4605                	li	a2,1
 2ba:	faf40593          	addi	a1,s0,-81
 2be:	4501                	li	a0,0
 2c0:	00000097          	auipc	ra,0x0
 2c4:	19a080e7          	jalr	410(ra) # 45a <read>
    if(cc < 1)
 2c8:	00a05e63          	blez	a0,2e4 <gets+0x56>
    buf[i++] = c;
 2cc:	faf44783          	lbu	a5,-81(s0)
 2d0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2d4:	01578763          	beq	a5,s5,2e2 <gets+0x54>
 2d8:	0905                	addi	s2,s2,1
 2da:	fd679be3          	bne	a5,s6,2b0 <gets+0x22>
  for(i=0; i+1 < max; ){
 2de:	89a6                	mv	s3,s1
 2e0:	a011                	j	2e4 <gets+0x56>
 2e2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2e4:	99de                	add	s3,s3,s7
 2e6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ea:	855e                	mv	a0,s7
 2ec:	60e6                	ld	ra,88(sp)
 2ee:	6446                	ld	s0,80(sp)
 2f0:	64a6                	ld	s1,72(sp)
 2f2:	6906                	ld	s2,64(sp)
 2f4:	79e2                	ld	s3,56(sp)
 2f6:	7a42                	ld	s4,48(sp)
 2f8:	7aa2                	ld	s5,40(sp)
 2fa:	7b02                	ld	s6,32(sp)
 2fc:	6be2                	ld	s7,24(sp)
 2fe:	6125                	addi	sp,sp,96
 300:	8082                	ret

0000000000000302 <stat>:

int
stat(const char *n, struct stat *st)
{
 302:	1101                	addi	sp,sp,-32
 304:	ec06                	sd	ra,24(sp)
 306:	e822                	sd	s0,16(sp)
 308:	e426                	sd	s1,8(sp)
 30a:	e04a                	sd	s2,0(sp)
 30c:	1000                	addi	s0,sp,32
 30e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 310:	4581                	li	a1,0
 312:	00000097          	auipc	ra,0x0
 316:	170080e7          	jalr	368(ra) # 482 <open>
  if(fd < 0)
 31a:	02054563          	bltz	a0,344 <stat+0x42>
 31e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 320:	85ca                	mv	a1,s2
 322:	00000097          	auipc	ra,0x0
 326:	178080e7          	jalr	376(ra) # 49a <fstat>
 32a:	892a                	mv	s2,a0
  close(fd);
 32c:	8526                	mv	a0,s1
 32e:	00000097          	auipc	ra,0x0
 332:	13c080e7          	jalr	316(ra) # 46a <close>
  return r;
}
 336:	854a                	mv	a0,s2
 338:	60e2                	ld	ra,24(sp)
 33a:	6442                	ld	s0,16(sp)
 33c:	64a2                	ld	s1,8(sp)
 33e:	6902                	ld	s2,0(sp)
 340:	6105                	addi	sp,sp,32
 342:	8082                	ret
    return -1;
 344:	597d                	li	s2,-1
 346:	bfc5                	j	336 <stat+0x34>

0000000000000348 <atoi>:

int
atoi(const char *s)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e422                	sd	s0,8(sp)
 34c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34e:	00054683          	lbu	a3,0(a0)
 352:	fd06879b          	addiw	a5,a3,-48
 356:	0ff7f793          	zext.b	a5,a5
 35a:	4625                	li	a2,9
 35c:	02f66863          	bltu	a2,a5,38c <atoi+0x44>
 360:	872a                	mv	a4,a0
  n = 0;
 362:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 364:	0705                	addi	a4,a4,1
 366:	0025179b          	slliw	a5,a0,0x2
 36a:	9fa9                	addw	a5,a5,a0
 36c:	0017979b          	slliw	a5,a5,0x1
 370:	9fb5                	addw	a5,a5,a3
 372:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 376:	00074683          	lbu	a3,0(a4)
 37a:	fd06879b          	addiw	a5,a3,-48
 37e:	0ff7f793          	zext.b	a5,a5
 382:	fef671e3          	bgeu	a2,a5,364 <atoi+0x1c>
  return n;
}
 386:	6422                	ld	s0,8(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret
  n = 0;
 38c:	4501                	li	a0,0
 38e:	bfe5                	j	386 <atoi+0x3e>

0000000000000390 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 390:	1141                	addi	sp,sp,-16
 392:	e422                	sd	s0,8(sp)
 394:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 396:	02b57463          	bgeu	a0,a1,3be <memmove+0x2e>
    while(n-- > 0)
 39a:	00c05f63          	blez	a2,3b8 <memmove+0x28>
 39e:	1602                	slli	a2,a2,0x20
 3a0:	9201                	srli	a2,a2,0x20
 3a2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3a6:	872a                	mv	a4,a0
      *dst++ = *src++;
 3a8:	0585                	addi	a1,a1,1
 3aa:	0705                	addi	a4,a4,1
 3ac:	fff5c683          	lbu	a3,-1(a1)
 3b0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3b4:	fee79ae3          	bne	a5,a4,3a8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3b8:	6422                	ld	s0,8(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret
    dst += n;
 3be:	00c50733          	add	a4,a0,a2
    src += n;
 3c2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c4:	fec05ae3          	blez	a2,3b8 <memmove+0x28>
 3c8:	fff6079b          	addiw	a5,a2,-1
 3cc:	1782                	slli	a5,a5,0x20
 3ce:	9381                	srli	a5,a5,0x20
 3d0:	fff7c793          	not	a5,a5
 3d4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3d6:	15fd                	addi	a1,a1,-1
 3d8:	177d                	addi	a4,a4,-1
 3da:	0005c683          	lbu	a3,0(a1)
 3de:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e2:	fee79ae3          	bne	a5,a4,3d6 <memmove+0x46>
 3e6:	bfc9                	j	3b8 <memmove+0x28>

00000000000003e8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e422                	sd	s0,8(sp)
 3ec:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ee:	ca05                	beqz	a2,41e <memcmp+0x36>
 3f0:	fff6069b          	addiw	a3,a2,-1
 3f4:	1682                	slli	a3,a3,0x20
 3f6:	9281                	srli	a3,a3,0x20
 3f8:	0685                	addi	a3,a3,1
 3fa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3fc:	00054783          	lbu	a5,0(a0)
 400:	0005c703          	lbu	a4,0(a1)
 404:	00e79863          	bne	a5,a4,414 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 408:	0505                	addi	a0,a0,1
    p2++;
 40a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 40c:	fed518e3          	bne	a0,a3,3fc <memcmp+0x14>
  }
  return 0;
 410:	4501                	li	a0,0
 412:	a019                	j	418 <memcmp+0x30>
      return *p1 - *p2;
 414:	40e7853b          	subw	a0,a5,a4
}
 418:	6422                	ld	s0,8(sp)
 41a:	0141                	addi	sp,sp,16
 41c:	8082                	ret
  return 0;
 41e:	4501                	li	a0,0
 420:	bfe5                	j	418 <memcmp+0x30>

0000000000000422 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 422:	1141                	addi	sp,sp,-16
 424:	e406                	sd	ra,8(sp)
 426:	e022                	sd	s0,0(sp)
 428:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 42a:	00000097          	auipc	ra,0x0
 42e:	f66080e7          	jalr	-154(ra) # 390 <memmove>
}
 432:	60a2                	ld	ra,8(sp)
 434:	6402                	ld	s0,0(sp)
 436:	0141                	addi	sp,sp,16
 438:	8082                	ret

000000000000043a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 43a:	4885                	li	a7,1
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <exit>:
.global exit
exit:
 li a7, SYS_exit
 442:	4889                	li	a7,2
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <wait>:
.global wait
wait:
 li a7, SYS_wait
 44a:	488d                	li	a7,3
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 452:	4891                	li	a7,4
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <read>:
.global read
read:
 li a7, SYS_read
 45a:	4895                	li	a7,5
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <write>:
.global write
write:
 li a7, SYS_write
 462:	48c1                	li	a7,16
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <close>:
.global close
close:
 li a7, SYS_close
 46a:	48d5                	li	a7,21
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <kill>:
.global kill
kill:
 li a7, SYS_kill
 472:	4899                	li	a7,6
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <exec>:
.global exec
exec:
 li a7, SYS_exec
 47a:	489d                	li	a7,7
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <open>:
.global open
open:
 li a7, SYS_open
 482:	48bd                	li	a7,15
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 48a:	48c5                	li	a7,17
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 492:	48c9                	li	a7,18
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49a:	48a1                	li	a7,8
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <link>:
.global link
link:
 li a7, SYS_link
 4a2:	48cd                	li	a7,19
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4aa:	48d1                	li	a7,20
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b2:	48a5                	li	a7,9
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ba:	48a9                	li	a7,10
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c2:	48ad                	li	a7,11
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ca:	48b1                	li	a7,12
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4d2:	48b5                	li	a7,13
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4da:	48b9                	li	a7,14
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4e2:	48d9                	li	a7,22
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <yield>:
.global yield
yield:
 li a7, SYS_yield
 4ea:	48dd                	li	a7,23
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 4f2:	48e1                	li	a7,24
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 4fa:	48e5                	li	a7,25
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 502:	48e9                	li	a7,26
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <ps>:
.global ps
ps:
 li a7, SYS_ps
 50a:	48ed                	li	a7,27
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 512:	48f1                	li	a7,28
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 51a:	48f5                	li	a7,29
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 522:	48f9                	li	a7,30
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 52a:	02100893          	li	a7,33
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 534:	48fd                	li	a7,31
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 53c:	02000893          	li	a7,32
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 546:	02200893          	li	a7,34
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 550:	02300893          	li	a7,35
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 55a:	02400893          	li	a7,36
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 564:	02500893          	li	a7,37
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 56e:	02700893          	li	a7,39
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 578:	02600893          	li	a7,38
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 582:	1101                	addi	sp,sp,-32
 584:	ec06                	sd	ra,24(sp)
 586:	e822                	sd	s0,16(sp)
 588:	1000                	addi	s0,sp,32
 58a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 58e:	4605                	li	a2,1
 590:	fef40593          	addi	a1,s0,-17
 594:	00000097          	auipc	ra,0x0
 598:	ece080e7          	jalr	-306(ra) # 462 <write>
}
 59c:	60e2                	ld	ra,24(sp)
 59e:	6442                	ld	s0,16(sp)
 5a0:	6105                	addi	sp,sp,32
 5a2:	8082                	ret

00000000000005a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a4:	7139                	addi	sp,sp,-64
 5a6:	fc06                	sd	ra,56(sp)
 5a8:	f822                	sd	s0,48(sp)
 5aa:	f426                	sd	s1,40(sp)
 5ac:	f04a                	sd	s2,32(sp)
 5ae:	ec4e                	sd	s3,24(sp)
 5b0:	0080                	addi	s0,sp,64
 5b2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5b4:	c299                	beqz	a3,5ba <printint+0x16>
 5b6:	0805c963          	bltz	a1,648 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ba:	2581                	sext.w	a1,a1
  neg = 0;
 5bc:	4881                	li	a7,0
 5be:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5c4:	2601                	sext.w	a2,a2
 5c6:	00000517          	auipc	a0,0x0
 5ca:	59250513          	addi	a0,a0,1426 # b58 <digits>
 5ce:	883a                	mv	a6,a4
 5d0:	2705                	addiw	a4,a4,1
 5d2:	02c5f7bb          	remuw	a5,a1,a2
 5d6:	1782                	slli	a5,a5,0x20
 5d8:	9381                	srli	a5,a5,0x20
 5da:	97aa                	add	a5,a5,a0
 5dc:	0007c783          	lbu	a5,0(a5)
 5e0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5e4:	0005879b          	sext.w	a5,a1
 5e8:	02c5d5bb          	divuw	a1,a1,a2
 5ec:	0685                	addi	a3,a3,1
 5ee:	fec7f0e3          	bgeu	a5,a2,5ce <printint+0x2a>
  if(neg)
 5f2:	00088c63          	beqz	a7,60a <printint+0x66>
    buf[i++] = '-';
 5f6:	fd070793          	addi	a5,a4,-48
 5fa:	00878733          	add	a4,a5,s0
 5fe:	02d00793          	li	a5,45
 602:	fef70823          	sb	a5,-16(a4)
 606:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 60a:	02e05863          	blez	a4,63a <printint+0x96>
 60e:	fc040793          	addi	a5,s0,-64
 612:	00e78933          	add	s2,a5,a4
 616:	fff78993          	addi	s3,a5,-1
 61a:	99ba                	add	s3,s3,a4
 61c:	377d                	addiw	a4,a4,-1
 61e:	1702                	slli	a4,a4,0x20
 620:	9301                	srli	a4,a4,0x20
 622:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 626:	fff94583          	lbu	a1,-1(s2)
 62a:	8526                	mv	a0,s1
 62c:	00000097          	auipc	ra,0x0
 630:	f56080e7          	jalr	-170(ra) # 582 <putc>
  while(--i >= 0)
 634:	197d                	addi	s2,s2,-1
 636:	ff3918e3          	bne	s2,s3,626 <printint+0x82>
}
 63a:	70e2                	ld	ra,56(sp)
 63c:	7442                	ld	s0,48(sp)
 63e:	74a2                	ld	s1,40(sp)
 640:	7902                	ld	s2,32(sp)
 642:	69e2                	ld	s3,24(sp)
 644:	6121                	addi	sp,sp,64
 646:	8082                	ret
    x = -xx;
 648:	40b005bb          	negw	a1,a1
    neg = 1;
 64c:	4885                	li	a7,1
    x = -xx;
 64e:	bf85                	j	5be <printint+0x1a>

0000000000000650 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 650:	7119                	addi	sp,sp,-128
 652:	fc86                	sd	ra,120(sp)
 654:	f8a2                	sd	s0,112(sp)
 656:	f4a6                	sd	s1,104(sp)
 658:	f0ca                	sd	s2,96(sp)
 65a:	ecce                	sd	s3,88(sp)
 65c:	e8d2                	sd	s4,80(sp)
 65e:	e4d6                	sd	s5,72(sp)
 660:	e0da                	sd	s6,64(sp)
 662:	fc5e                	sd	s7,56(sp)
 664:	f862                	sd	s8,48(sp)
 666:	f466                	sd	s9,40(sp)
 668:	f06a                	sd	s10,32(sp)
 66a:	ec6e                	sd	s11,24(sp)
 66c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 66e:	0005c903          	lbu	s2,0(a1)
 672:	18090f63          	beqz	s2,810 <vprintf+0x1c0>
 676:	8aaa                	mv	s5,a0
 678:	8b32                	mv	s6,a2
 67a:	00158493          	addi	s1,a1,1
  state = 0;
 67e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 680:	02500a13          	li	s4,37
 684:	4c55                	li	s8,21
 686:	00000c97          	auipc	s9,0x0
 68a:	47ac8c93          	addi	s9,s9,1146 # b00 <malloc+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 68e:	02800d93          	li	s11,40
  putc(fd, 'x');
 692:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 694:	00000b97          	auipc	s7,0x0
 698:	4c4b8b93          	addi	s7,s7,1220 # b58 <digits>
 69c:	a839                	j	6ba <vprintf+0x6a>
        putc(fd, c);
 69e:	85ca                	mv	a1,s2
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	ee0080e7          	jalr	-288(ra) # 582 <putc>
 6aa:	a019                	j	6b0 <vprintf+0x60>
    } else if(state == '%'){
 6ac:	01498d63          	beq	s3,s4,6c6 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 6b0:	0485                	addi	s1,s1,1
 6b2:	fff4c903          	lbu	s2,-1(s1)
 6b6:	14090d63          	beqz	s2,810 <vprintf+0x1c0>
    if(state == 0){
 6ba:	fe0999e3          	bnez	s3,6ac <vprintf+0x5c>
      if(c == '%'){
 6be:	ff4910e3          	bne	s2,s4,69e <vprintf+0x4e>
        state = '%';
 6c2:	89d2                	mv	s3,s4
 6c4:	b7f5                	j	6b0 <vprintf+0x60>
      if(c == 'd'){
 6c6:	11490c63          	beq	s2,s4,7de <vprintf+0x18e>
 6ca:	f9d9079b          	addiw	a5,s2,-99
 6ce:	0ff7f793          	zext.b	a5,a5
 6d2:	10fc6e63          	bltu	s8,a5,7ee <vprintf+0x19e>
 6d6:	f9d9079b          	addiw	a5,s2,-99
 6da:	0ff7f713          	zext.b	a4,a5
 6de:	10ec6863          	bltu	s8,a4,7ee <vprintf+0x19e>
 6e2:	00271793          	slli	a5,a4,0x2
 6e6:	97e6                	add	a5,a5,s9
 6e8:	439c                	lw	a5,0(a5)
 6ea:	97e6                	add	a5,a5,s9
 6ec:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6ee:	008b0913          	addi	s2,s6,8
 6f2:	4685                	li	a3,1
 6f4:	4629                	li	a2,10
 6f6:	000b2583          	lw	a1,0(s6)
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	ea8080e7          	jalr	-344(ra) # 5a4 <printint>
 704:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 706:	4981                	li	s3,0
 708:	b765                	j	6b0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	008b0913          	addi	s2,s6,8
 70e:	4681                	li	a3,0
 710:	4629                	li	a2,10
 712:	000b2583          	lw	a1,0(s6)
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	e8c080e7          	jalr	-372(ra) # 5a4 <printint>
 720:	8b4a                	mv	s6,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	b771                	j	6b0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 726:	008b0913          	addi	s2,s6,8
 72a:	4681                	li	a3,0
 72c:	866a                	mv	a2,s10
 72e:	000b2583          	lw	a1,0(s6)
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	e70080e7          	jalr	-400(ra) # 5a4 <printint>
 73c:	8b4a                	mv	s6,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	bf85                	j	6b0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 742:	008b0793          	addi	a5,s6,8
 746:	f8f43423          	sd	a5,-120(s0)
 74a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 74e:	03000593          	li	a1,48
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	e2e080e7          	jalr	-466(ra) # 582 <putc>
  putc(fd, 'x');
 75c:	07800593          	li	a1,120
 760:	8556                	mv	a0,s5
 762:	00000097          	auipc	ra,0x0
 766:	e20080e7          	jalr	-480(ra) # 582 <putc>
 76a:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76c:	03c9d793          	srli	a5,s3,0x3c
 770:	97de                	add	a5,a5,s7
 772:	0007c583          	lbu	a1,0(a5)
 776:	8556                	mv	a0,s5
 778:	00000097          	auipc	ra,0x0
 77c:	e0a080e7          	jalr	-502(ra) # 582 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 780:	0992                	slli	s3,s3,0x4
 782:	397d                	addiw	s2,s2,-1
 784:	fe0914e3          	bnez	s2,76c <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 788:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b70d                	j	6b0 <vprintf+0x60>
        s = va_arg(ap, char*);
 790:	008b0913          	addi	s2,s6,8
 794:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 798:	02098163          	beqz	s3,7ba <vprintf+0x16a>
        while(*s != 0){
 79c:	0009c583          	lbu	a1,0(s3)
 7a0:	c5ad                	beqz	a1,80a <vprintf+0x1ba>
          putc(fd, *s);
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	dde080e7          	jalr	-546(ra) # 582 <putc>
          s++;
 7ac:	0985                	addi	s3,s3,1
        while(*s != 0){
 7ae:	0009c583          	lbu	a1,0(s3)
 7b2:	f9e5                	bnez	a1,7a2 <vprintf+0x152>
        s = va_arg(ap, char*);
 7b4:	8b4a                	mv	s6,s2
      state = 0;
 7b6:	4981                	li	s3,0
 7b8:	bde5                	j	6b0 <vprintf+0x60>
          s = "(null)";
 7ba:	00000997          	auipc	s3,0x0
 7be:	33e98993          	addi	s3,s3,830 # af8 <malloc+0x1e4>
        while(*s != 0){
 7c2:	85ee                	mv	a1,s11
 7c4:	bff9                	j	7a2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7c6:	008b0913          	addi	s2,s6,8
 7ca:	000b4583          	lbu	a1,0(s6)
 7ce:	8556                	mv	a0,s5
 7d0:	00000097          	auipc	ra,0x0
 7d4:	db2080e7          	jalr	-590(ra) # 582 <putc>
 7d8:	8b4a                	mv	s6,s2
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	bdd1                	j	6b0 <vprintf+0x60>
        putc(fd, c);
 7de:	85d2                	mv	a1,s4
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	da0080e7          	jalr	-608(ra) # 582 <putc>
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	b5d1                	j	6b0 <vprintf+0x60>
        putc(fd, '%');
 7ee:	85d2                	mv	a1,s4
 7f0:	8556                	mv	a0,s5
 7f2:	00000097          	auipc	ra,0x0
 7f6:	d90080e7          	jalr	-624(ra) # 582 <putc>
        putc(fd, c);
 7fa:	85ca                	mv	a1,s2
 7fc:	8556                	mv	a0,s5
 7fe:	00000097          	auipc	ra,0x0
 802:	d84080e7          	jalr	-636(ra) # 582 <putc>
      state = 0;
 806:	4981                	li	s3,0
 808:	b565                	j	6b0 <vprintf+0x60>
        s = va_arg(ap, char*);
 80a:	8b4a                	mv	s6,s2
      state = 0;
 80c:	4981                	li	s3,0
 80e:	b54d                	j	6b0 <vprintf+0x60>
    }
  }
}
 810:	70e6                	ld	ra,120(sp)
 812:	7446                	ld	s0,112(sp)
 814:	74a6                	ld	s1,104(sp)
 816:	7906                	ld	s2,96(sp)
 818:	69e6                	ld	s3,88(sp)
 81a:	6a46                	ld	s4,80(sp)
 81c:	6aa6                	ld	s5,72(sp)
 81e:	6b06                	ld	s6,64(sp)
 820:	7be2                	ld	s7,56(sp)
 822:	7c42                	ld	s8,48(sp)
 824:	7ca2                	ld	s9,40(sp)
 826:	7d02                	ld	s10,32(sp)
 828:	6de2                	ld	s11,24(sp)
 82a:	6109                	addi	sp,sp,128
 82c:	8082                	ret

000000000000082e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 82e:	715d                	addi	sp,sp,-80
 830:	ec06                	sd	ra,24(sp)
 832:	e822                	sd	s0,16(sp)
 834:	1000                	addi	s0,sp,32
 836:	e010                	sd	a2,0(s0)
 838:	e414                	sd	a3,8(s0)
 83a:	e818                	sd	a4,16(s0)
 83c:	ec1c                	sd	a5,24(s0)
 83e:	03043023          	sd	a6,32(s0)
 842:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 846:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 84a:	8622                	mv	a2,s0
 84c:	00000097          	auipc	ra,0x0
 850:	e04080e7          	jalr	-508(ra) # 650 <vprintf>
}
 854:	60e2                	ld	ra,24(sp)
 856:	6442                	ld	s0,16(sp)
 858:	6161                	addi	sp,sp,80
 85a:	8082                	ret

000000000000085c <printf>:

void
printf(const char *fmt, ...)
{
 85c:	711d                	addi	sp,sp,-96
 85e:	ec06                	sd	ra,24(sp)
 860:	e822                	sd	s0,16(sp)
 862:	1000                	addi	s0,sp,32
 864:	e40c                	sd	a1,8(s0)
 866:	e810                	sd	a2,16(s0)
 868:	ec14                	sd	a3,24(s0)
 86a:	f018                	sd	a4,32(s0)
 86c:	f41c                	sd	a5,40(s0)
 86e:	03043823          	sd	a6,48(s0)
 872:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 876:	00840613          	addi	a2,s0,8
 87a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 87e:	85aa                	mv	a1,a0
 880:	4505                	li	a0,1
 882:	00000097          	auipc	ra,0x0
 886:	dce080e7          	jalr	-562(ra) # 650 <vprintf>
}
 88a:	60e2                	ld	ra,24(sp)
 88c:	6442                	ld	s0,16(sp)
 88e:	6125                	addi	sp,sp,96
 890:	8082                	ret

0000000000000892 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 892:	1141                	addi	sp,sp,-16
 894:	e422                	sd	s0,8(sp)
 896:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 898:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89c:	00000797          	auipc	a5,0x0
 8a0:	2d47b783          	ld	a5,724(a5) # b70 <freep>
 8a4:	a02d                	j	8ce <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8a6:	4618                	lw	a4,8(a2)
 8a8:	9f2d                	addw	a4,a4,a1
 8aa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ae:	6398                	ld	a4,0(a5)
 8b0:	6310                	ld	a2,0(a4)
 8b2:	a83d                	j	8f0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8b4:	ff852703          	lw	a4,-8(a0)
 8b8:	9f31                	addw	a4,a4,a2
 8ba:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8bc:	ff053683          	ld	a3,-16(a0)
 8c0:	a091                	j	904 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c2:	6398                	ld	a4,0(a5)
 8c4:	00e7e463          	bltu	a5,a4,8cc <free+0x3a>
 8c8:	00e6ea63          	bltu	a3,a4,8dc <free+0x4a>
{
 8cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ce:	fed7fae3          	bgeu	a5,a3,8c2 <free+0x30>
 8d2:	6398                	ld	a4,0(a5)
 8d4:	00e6e463          	bltu	a3,a4,8dc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d8:	fee7eae3          	bltu	a5,a4,8cc <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8dc:	ff852583          	lw	a1,-8(a0)
 8e0:	6390                	ld	a2,0(a5)
 8e2:	02059813          	slli	a6,a1,0x20
 8e6:	01c85713          	srli	a4,a6,0x1c
 8ea:	9736                	add	a4,a4,a3
 8ec:	fae60de3          	beq	a2,a4,8a6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8f0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8f4:	4790                	lw	a2,8(a5)
 8f6:	02061593          	slli	a1,a2,0x20
 8fa:	01c5d713          	srli	a4,a1,0x1c
 8fe:	973e                	add	a4,a4,a5
 900:	fae68ae3          	beq	a3,a4,8b4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 904:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 906:	00000717          	auipc	a4,0x0
 90a:	26f73523          	sd	a5,618(a4) # b70 <freep>
}
 90e:	6422                	ld	s0,8(sp)
 910:	0141                	addi	sp,sp,16
 912:	8082                	ret

0000000000000914 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 914:	7139                	addi	sp,sp,-64
 916:	fc06                	sd	ra,56(sp)
 918:	f822                	sd	s0,48(sp)
 91a:	f426                	sd	s1,40(sp)
 91c:	f04a                	sd	s2,32(sp)
 91e:	ec4e                	sd	s3,24(sp)
 920:	e852                	sd	s4,16(sp)
 922:	e456                	sd	s5,8(sp)
 924:	e05a                	sd	s6,0(sp)
 926:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 928:	02051493          	slli	s1,a0,0x20
 92c:	9081                	srli	s1,s1,0x20
 92e:	04bd                	addi	s1,s1,15
 930:	8091                	srli	s1,s1,0x4
 932:	0014899b          	addiw	s3,s1,1
 936:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 938:	00000517          	auipc	a0,0x0
 93c:	23853503          	ld	a0,568(a0) # b70 <freep>
 940:	c515                	beqz	a0,96c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 942:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 944:	4798                	lw	a4,8(a5)
 946:	02977f63          	bgeu	a4,s1,984 <malloc+0x70>
 94a:	8a4e                	mv	s4,s3
 94c:	0009871b          	sext.w	a4,s3
 950:	6685                	lui	a3,0x1
 952:	00d77363          	bgeu	a4,a3,958 <malloc+0x44>
 956:	6a05                	lui	s4,0x1
 958:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 95c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 960:	00000917          	auipc	s2,0x0
 964:	21090913          	addi	s2,s2,528 # b70 <freep>
  if(p == (char*)-1)
 968:	5afd                	li	s5,-1
 96a:	a895                	j	9de <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 96c:	00000797          	auipc	a5,0x0
 970:	20c78793          	addi	a5,a5,524 # b78 <base>
 974:	00000717          	auipc	a4,0x0
 978:	1ef73e23          	sd	a5,508(a4) # b70 <freep>
 97c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 97e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 982:	b7e1                	j	94a <malloc+0x36>
      if(p->s.size == nunits)
 984:	02e48c63          	beq	s1,a4,9bc <malloc+0xa8>
        p->s.size -= nunits;
 988:	4137073b          	subw	a4,a4,s3
 98c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 98e:	02071693          	slli	a3,a4,0x20
 992:	01c6d713          	srli	a4,a3,0x1c
 996:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 998:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 99c:	00000717          	auipc	a4,0x0
 9a0:	1ca73a23          	sd	a0,468(a4) # b70 <freep>
      return (void*)(p + 1);
 9a4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9a8:	70e2                	ld	ra,56(sp)
 9aa:	7442                	ld	s0,48(sp)
 9ac:	74a2                	ld	s1,40(sp)
 9ae:	7902                	ld	s2,32(sp)
 9b0:	69e2                	ld	s3,24(sp)
 9b2:	6a42                	ld	s4,16(sp)
 9b4:	6aa2                	ld	s5,8(sp)
 9b6:	6b02                	ld	s6,0(sp)
 9b8:	6121                	addi	sp,sp,64
 9ba:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9bc:	6398                	ld	a4,0(a5)
 9be:	e118                	sd	a4,0(a0)
 9c0:	bff1                	j	99c <malloc+0x88>
  hp->s.size = nu;
 9c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9c6:	0541                	addi	a0,a0,16
 9c8:	00000097          	auipc	ra,0x0
 9cc:	eca080e7          	jalr	-310(ra) # 892 <free>
  return freep;
 9d0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9d4:	d971                	beqz	a0,9a8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d8:	4798                	lw	a4,8(a5)
 9da:	fa9775e3          	bgeu	a4,s1,984 <malloc+0x70>
    if(p == freep)
 9de:	00093703          	ld	a4,0(s2)
 9e2:	853e                	mv	a0,a5
 9e4:	fef719e3          	bne	a4,a5,9d6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9e8:	8552                	mv	a0,s4
 9ea:	00000097          	auipc	ra,0x0
 9ee:	ae0080e7          	jalr	-1312(ra) # 4ca <sbrk>
  if(p == (char*)-1)
 9f2:	fd5518e3          	bne	a0,s5,9c2 <malloc+0xae>
        return 0;
 9f6:	4501                	li	a0,0
 9f8:	bf45                	j	9a8 <malloc+0x94>
