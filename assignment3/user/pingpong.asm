
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  int pipefd1[2], pipefd2[2], x;
  char y = '0';
   8:	03000793          	li	a5,48
   c:	fcf40fa3          	sb	a5,-33(s0)

  if (pipe(pipefd1) < 0) {
  10:	fe840513          	addi	a0,s0,-24
  14:	00000097          	auipc	ra,0x0
  18:	472080e7          	jalr	1138(ra) # 486 <pipe>
  1c:	0a054863          	bltz	a0,cc <main+0xcc>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
     exit(0);
  }

  if (pipe(pipefd2) < 0) {
  20:	fe040513          	addi	a0,s0,-32
  24:	00000097          	auipc	ra,0x0
  28:	462080e7          	jalr	1122(ra) # 486 <pipe>
  2c:	0a054e63          	bltz	a0,e8 <main+0xe8>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
     exit(0);
  }

  x = fork();
  30:	00000097          	auipc	ra,0x0
  34:	43e080e7          	jalr	1086(ra) # 46e <fork>
  if (x < 0) {
  38:	0c054663          	bltz	a0,104 <main+0x104>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  3c:	10a05e63          	blez	a0,158 <main+0x158>
     if (write(pipefd1[1], &y, 1) < 0) {
  40:	4605                	li	a2,1
  42:	fdf40593          	addi	a1,s0,-33
  46:	fec42503          	lw	a0,-20(s0)
  4a:	00000097          	auipc	ra,0x0
  4e:	44c080e7          	jalr	1100(ra) # 496 <write>
  52:	0c054763          	bltz	a0,120 <main+0x120>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
	exit(0);
     }
     if (read(pipefd2[0], &y, 1) < 0) {
  56:	4605                	li	a2,1
  58:	fdf40593          	addi	a1,s0,-33
  5c:	fe042503          	lw	a0,-32(s0)
  60:	00000097          	auipc	ra,0x0
  64:	42e080e7          	jalr	1070(ra) # 48e <read>
  68:	0c054a63          	bltz	a0,13c <main+0x13c>
        fprintf(2, "Error: cannot read from pipe\nAborting...\n");
        exit(0);
     }
     fprintf(1, "%d: received pong\n", getpid());
  6c:	00000097          	auipc	ra,0x0
  70:	48a080e7          	jalr	1162(ra) # 4f6 <getpid>
  74:	862a                	mv	a2,a0
  76:	00001597          	auipc	a1,0x1
  7a:	a6258593          	addi	a1,a1,-1438 # ad8 <malloc+0x190>
  7e:	4505                	li	a0,1
  80:	00000097          	auipc	ra,0x0
  84:	7e2080e7          	jalr	2018(ra) # 862 <fprintf>
     close(pipefd1[0]);
  88:	fe842503          	lw	a0,-24(s0)
  8c:	00000097          	auipc	ra,0x0
  90:	412080e7          	jalr	1042(ra) # 49e <close>
     close(pipefd1[1]);
  94:	fec42503          	lw	a0,-20(s0)
  98:	00000097          	auipc	ra,0x0
  9c:	406080e7          	jalr	1030(ra) # 49e <close>
     close(pipefd2[0]);
  a0:	fe042503          	lw	a0,-32(s0)
  a4:	00000097          	auipc	ra,0x0
  a8:	3fa080e7          	jalr	1018(ra) # 49e <close>
     close(pipefd2[1]);
  ac:	fe442503          	lw	a0,-28(s0)
  b0:	00000097          	auipc	ra,0x0
  b4:	3ee080e7          	jalr	1006(ra) # 49e <close>
     wait(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	3c4080e7          	jalr	964(ra) # 47e <wait>
     close(pipefd1[1]);
     close(pipefd2[0]);
     close(pipefd2[1]);
  }

  exit(0);
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	3b2080e7          	jalr	946(ra) # 476 <exit>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
  cc:	00001597          	auipc	a1,0x1
  d0:	96458593          	addi	a1,a1,-1692 # a30 <malloc+0xe8>
  d4:	4509                	li	a0,2
  d6:	00000097          	auipc	ra,0x0
  da:	78c080e7          	jalr	1932(ra) # 862 <fprintf>
     exit(0);
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	396080e7          	jalr	918(ra) # 476 <exit>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
  e8:	00001597          	auipc	a1,0x1
  ec:	94858593          	addi	a1,a1,-1720 # a30 <malloc+0xe8>
  f0:	4509                	li	a0,2
  f2:	00000097          	auipc	ra,0x0
  f6:	770080e7          	jalr	1904(ra) # 862 <fprintf>
     exit(0);
  fa:	4501                	li	a0,0
  fc:	00000097          	auipc	ra,0x0
 100:	37a080e7          	jalr	890(ra) # 476 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
 104:	00001597          	auipc	a1,0x1
 108:	95458593          	addi	a1,a1,-1708 # a58 <malloc+0x110>
 10c:	4509                	li	a0,2
 10e:	00000097          	auipc	ra,0x0
 112:	754080e7          	jalr	1876(ra) # 862 <fprintf>
     exit(0);
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	35e080e7          	jalr	862(ra) # 476 <exit>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 120:	00001597          	auipc	a1,0x1
 124:	95858593          	addi	a1,a1,-1704 # a78 <malloc+0x130>
 128:	4509                	li	a0,2
 12a:	00000097          	auipc	ra,0x0
 12e:	738080e7          	jalr	1848(ra) # 862 <fprintf>
	exit(0);
 132:	4501                	li	a0,0
 134:	00000097          	auipc	ra,0x0
 138:	342080e7          	jalr	834(ra) # 476 <exit>
        fprintf(2, "Error: cannot read from pipe\nAborting...\n");
 13c:	00001597          	auipc	a1,0x1
 140:	96c58593          	addi	a1,a1,-1684 # aa8 <malloc+0x160>
 144:	4509                	li	a0,2
 146:	00000097          	auipc	ra,0x0
 14a:	71c080e7          	jalr	1820(ra) # 862 <fprintf>
        exit(0);
 14e:	4501                	li	a0,0
 150:	00000097          	auipc	ra,0x0
 154:	326080e7          	jalr	806(ra) # 476 <exit>
     if (read(pipefd1[0], &y, 1) < 0) {
 158:	4605                	li	a2,1
 15a:	fdf40593          	addi	a1,s0,-33
 15e:	fe842503          	lw	a0,-24(s0)
 162:	00000097          	auipc	ra,0x0
 166:	32c080e7          	jalr	812(ra) # 48e <read>
 16a:	06054463          	bltz	a0,1d2 <main+0x1d2>
     fprintf(1, "%d: received ping\n", getpid());
 16e:	00000097          	auipc	ra,0x0
 172:	388080e7          	jalr	904(ra) # 4f6 <getpid>
 176:	862a                	mv	a2,a0
 178:	00001597          	auipc	a1,0x1
 17c:	97858593          	addi	a1,a1,-1672 # af0 <malloc+0x1a8>
 180:	4505                	li	a0,1
 182:	00000097          	auipc	ra,0x0
 186:	6e0080e7          	jalr	1760(ra) # 862 <fprintf>
     if (write(pipefd2[1], &y, 1) < 0) {
 18a:	4605                	li	a2,1
 18c:	fdf40593          	addi	a1,s0,-33
 190:	fe442503          	lw	a0,-28(s0)
 194:	00000097          	auipc	ra,0x0
 198:	302080e7          	jalr	770(ra) # 496 <write>
 19c:	04054963          	bltz	a0,1ee <main+0x1ee>
     close(pipefd1[0]);
 1a0:	fe842503          	lw	a0,-24(s0)
 1a4:	00000097          	auipc	ra,0x0
 1a8:	2fa080e7          	jalr	762(ra) # 49e <close>
     close(pipefd1[1]);
 1ac:	fec42503          	lw	a0,-20(s0)
 1b0:	00000097          	auipc	ra,0x0
 1b4:	2ee080e7          	jalr	750(ra) # 49e <close>
     close(pipefd2[0]);
 1b8:	fe042503          	lw	a0,-32(s0)
 1bc:	00000097          	auipc	ra,0x0
 1c0:	2e2080e7          	jalr	738(ra) # 49e <close>
     close(pipefd2[1]);
 1c4:	fe442503          	lw	a0,-28(s0)
 1c8:	00000097          	auipc	ra,0x0
 1cc:	2d6080e7          	jalr	726(ra) # 49e <close>
 1d0:	bdcd                	j	c2 <main+0xc2>
        fprintf(2, "Error: cannot read from pipe\nAborting...\n");
 1d2:	00001597          	auipc	a1,0x1
 1d6:	8d658593          	addi	a1,a1,-1834 # aa8 <malloc+0x160>
 1da:	4509                	li	a0,2
 1dc:	00000097          	auipc	ra,0x0
 1e0:	686080e7          	jalr	1670(ra) # 862 <fprintf>
        exit(0);
 1e4:	4501                	li	a0,0
 1e6:	00000097          	auipc	ra,0x0
 1ea:	290080e7          	jalr	656(ra) # 476 <exit>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 1ee:	00001597          	auipc	a1,0x1
 1f2:	88a58593          	addi	a1,a1,-1910 # a78 <malloc+0x130>
 1f6:	4509                	li	a0,2
 1f8:	00000097          	auipc	ra,0x0
 1fc:	66a080e7          	jalr	1642(ra) # 862 <fprintf>
        exit(0);
 200:	4501                	li	a0,0
 202:	00000097          	auipc	ra,0x0
 206:	274080e7          	jalr	628(ra) # 476 <exit>

000000000000020a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 210:	87aa                	mv	a5,a0
 212:	0585                	addi	a1,a1,1
 214:	0785                	addi	a5,a5,1
 216:	fff5c703          	lbu	a4,-1(a1)
 21a:	fee78fa3          	sb	a4,-1(a5)
 21e:	fb75                	bnez	a4,212 <strcpy+0x8>
    ;
  return os;
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret

0000000000000226 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 226:	1141                	addi	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 22c:	00054783          	lbu	a5,0(a0)
 230:	cb91                	beqz	a5,244 <strcmp+0x1e>
 232:	0005c703          	lbu	a4,0(a1)
 236:	00f71763          	bne	a4,a5,244 <strcmp+0x1e>
    p++, q++;
 23a:	0505                	addi	a0,a0,1
 23c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 23e:	00054783          	lbu	a5,0(a0)
 242:	fbe5                	bnez	a5,232 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 244:	0005c503          	lbu	a0,0(a1)
}
 248:	40a7853b          	subw	a0,a5,a0
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret

0000000000000252 <strlen>:

uint
strlen(const char *s)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 258:	00054783          	lbu	a5,0(a0)
 25c:	cf91                	beqz	a5,278 <strlen+0x26>
 25e:	0505                	addi	a0,a0,1
 260:	87aa                	mv	a5,a0
 262:	4685                	li	a3,1
 264:	9e89                	subw	a3,a3,a0
 266:	00f6853b          	addw	a0,a3,a5
 26a:	0785                	addi	a5,a5,1
 26c:	fff7c703          	lbu	a4,-1(a5)
 270:	fb7d                	bnez	a4,266 <strlen+0x14>
    ;
  return n;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  for(n = 0; s[n]; n++)
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <strlen+0x20>

000000000000027c <memset>:

void*
memset(void *dst, int c, uint n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 282:	ca19                	beqz	a2,298 <memset+0x1c>
 284:	87aa                	mv	a5,a0
 286:	1602                	slli	a2,a2,0x20
 288:	9201                	srli	a2,a2,0x20
 28a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 28e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 292:	0785                	addi	a5,a5,1
 294:	fee79de3          	bne	a5,a4,28e <memset+0x12>
  }
  return dst;
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret

000000000000029e <strchr>:

char*
strchr(const char *s, char c)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	cb99                	beqz	a5,2be <strchr+0x20>
    if(*s == c)
 2aa:	00f58763          	beq	a1,a5,2b8 <strchr+0x1a>
  for(; *s; s++)
 2ae:	0505                	addi	a0,a0,1
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	fbfd                	bnez	a5,2aa <strchr+0xc>
      return (char*)s;
  return 0;
 2b6:	4501                	li	a0,0
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
  return 0;
 2be:	4501                	li	a0,0
 2c0:	bfe5                	j	2b8 <strchr+0x1a>

00000000000002c2 <gets>:

char*
gets(char *buf, int max)
{
 2c2:	711d                	addi	sp,sp,-96
 2c4:	ec86                	sd	ra,88(sp)
 2c6:	e8a2                	sd	s0,80(sp)
 2c8:	e4a6                	sd	s1,72(sp)
 2ca:	e0ca                	sd	s2,64(sp)
 2cc:	fc4e                	sd	s3,56(sp)
 2ce:	f852                	sd	s4,48(sp)
 2d0:	f456                	sd	s5,40(sp)
 2d2:	f05a                	sd	s6,32(sp)
 2d4:	ec5e                	sd	s7,24(sp)
 2d6:	1080                	addi	s0,sp,96
 2d8:	8baa                	mv	s7,a0
 2da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2dc:	892a                	mv	s2,a0
 2de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2e0:	4aa9                	li	s5,10
 2e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2e4:	89a6                	mv	s3,s1
 2e6:	2485                	addiw	s1,s1,1
 2e8:	0344d863          	bge	s1,s4,318 <gets+0x56>
    cc = read(0, &c, 1);
 2ec:	4605                	li	a2,1
 2ee:	faf40593          	addi	a1,s0,-81
 2f2:	4501                	li	a0,0
 2f4:	00000097          	auipc	ra,0x0
 2f8:	19a080e7          	jalr	410(ra) # 48e <read>
    if(cc < 1)
 2fc:	00a05e63          	blez	a0,318 <gets+0x56>
    buf[i++] = c;
 300:	faf44783          	lbu	a5,-81(s0)
 304:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 308:	01578763          	beq	a5,s5,316 <gets+0x54>
 30c:	0905                	addi	s2,s2,1
 30e:	fd679be3          	bne	a5,s6,2e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 312:	89a6                	mv	s3,s1
 314:	a011                	j	318 <gets+0x56>
 316:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 318:	99de                	add	s3,s3,s7
 31a:	00098023          	sb	zero,0(s3)
  return buf;
}
 31e:	855e                	mv	a0,s7
 320:	60e6                	ld	ra,88(sp)
 322:	6446                	ld	s0,80(sp)
 324:	64a6                	ld	s1,72(sp)
 326:	6906                	ld	s2,64(sp)
 328:	79e2                	ld	s3,56(sp)
 32a:	7a42                	ld	s4,48(sp)
 32c:	7aa2                	ld	s5,40(sp)
 32e:	7b02                	ld	s6,32(sp)
 330:	6be2                	ld	s7,24(sp)
 332:	6125                	addi	sp,sp,96
 334:	8082                	ret

0000000000000336 <stat>:

int
stat(const char *n, struct stat *st)
{
 336:	1101                	addi	sp,sp,-32
 338:	ec06                	sd	ra,24(sp)
 33a:	e822                	sd	s0,16(sp)
 33c:	e426                	sd	s1,8(sp)
 33e:	e04a                	sd	s2,0(sp)
 340:	1000                	addi	s0,sp,32
 342:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 344:	4581                	li	a1,0
 346:	00000097          	auipc	ra,0x0
 34a:	170080e7          	jalr	368(ra) # 4b6 <open>
  if(fd < 0)
 34e:	02054563          	bltz	a0,378 <stat+0x42>
 352:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 354:	85ca                	mv	a1,s2
 356:	00000097          	auipc	ra,0x0
 35a:	178080e7          	jalr	376(ra) # 4ce <fstat>
 35e:	892a                	mv	s2,a0
  close(fd);
 360:	8526                	mv	a0,s1
 362:	00000097          	auipc	ra,0x0
 366:	13c080e7          	jalr	316(ra) # 49e <close>
  return r;
}
 36a:	854a                	mv	a0,s2
 36c:	60e2                	ld	ra,24(sp)
 36e:	6442                	ld	s0,16(sp)
 370:	64a2                	ld	s1,8(sp)
 372:	6902                	ld	s2,0(sp)
 374:	6105                	addi	sp,sp,32
 376:	8082                	ret
    return -1;
 378:	597d                	li	s2,-1
 37a:	bfc5                	j	36a <stat+0x34>

000000000000037c <atoi>:

int
atoi(const char *s)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e422                	sd	s0,8(sp)
 380:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 382:	00054683          	lbu	a3,0(a0)
 386:	fd06879b          	addiw	a5,a3,-48
 38a:	0ff7f793          	zext.b	a5,a5
 38e:	4625                	li	a2,9
 390:	02f66863          	bltu	a2,a5,3c0 <atoi+0x44>
 394:	872a                	mv	a4,a0
  n = 0;
 396:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 398:	0705                	addi	a4,a4,1
 39a:	0025179b          	slliw	a5,a0,0x2
 39e:	9fa9                	addw	a5,a5,a0
 3a0:	0017979b          	slliw	a5,a5,0x1
 3a4:	9fb5                	addw	a5,a5,a3
 3a6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3aa:	00074683          	lbu	a3,0(a4)
 3ae:	fd06879b          	addiw	a5,a3,-48
 3b2:	0ff7f793          	zext.b	a5,a5
 3b6:	fef671e3          	bgeu	a2,a5,398 <atoi+0x1c>
  return n;
}
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret
  n = 0;
 3c0:	4501                	li	a0,0
 3c2:	bfe5                	j	3ba <atoi+0x3e>

00000000000003c4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e422                	sd	s0,8(sp)
 3c8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ca:	02b57463          	bgeu	a0,a1,3f2 <memmove+0x2e>
    while(n-- > 0)
 3ce:	00c05f63          	blez	a2,3ec <memmove+0x28>
 3d2:	1602                	slli	a2,a2,0x20
 3d4:	9201                	srli	a2,a2,0x20
 3d6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3da:	872a                	mv	a4,a0
      *dst++ = *src++;
 3dc:	0585                	addi	a1,a1,1
 3de:	0705                	addi	a4,a4,1
 3e0:	fff5c683          	lbu	a3,-1(a1)
 3e4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3e8:	fee79ae3          	bne	a5,a4,3dc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ec:	6422                	ld	s0,8(sp)
 3ee:	0141                	addi	sp,sp,16
 3f0:	8082                	ret
    dst += n;
 3f2:	00c50733          	add	a4,a0,a2
    src += n;
 3f6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3f8:	fec05ae3          	blez	a2,3ec <memmove+0x28>
 3fc:	fff6079b          	addiw	a5,a2,-1
 400:	1782                	slli	a5,a5,0x20
 402:	9381                	srli	a5,a5,0x20
 404:	fff7c793          	not	a5,a5
 408:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 40a:	15fd                	addi	a1,a1,-1
 40c:	177d                	addi	a4,a4,-1
 40e:	0005c683          	lbu	a3,0(a1)
 412:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 416:	fee79ae3          	bne	a5,a4,40a <memmove+0x46>
 41a:	bfc9                	j	3ec <memmove+0x28>

000000000000041c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 41c:	1141                	addi	sp,sp,-16
 41e:	e422                	sd	s0,8(sp)
 420:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 422:	ca05                	beqz	a2,452 <memcmp+0x36>
 424:	fff6069b          	addiw	a3,a2,-1
 428:	1682                	slli	a3,a3,0x20
 42a:	9281                	srli	a3,a3,0x20
 42c:	0685                	addi	a3,a3,1
 42e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 430:	00054783          	lbu	a5,0(a0)
 434:	0005c703          	lbu	a4,0(a1)
 438:	00e79863          	bne	a5,a4,448 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 43c:	0505                	addi	a0,a0,1
    p2++;
 43e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 440:	fed518e3          	bne	a0,a3,430 <memcmp+0x14>
  }
  return 0;
 444:	4501                	li	a0,0
 446:	a019                	j	44c <memcmp+0x30>
      return *p1 - *p2;
 448:	40e7853b          	subw	a0,a5,a4
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
  return 0;
 452:	4501                	li	a0,0
 454:	bfe5                	j	44c <memcmp+0x30>

0000000000000456 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 456:	1141                	addi	sp,sp,-16
 458:	e406                	sd	ra,8(sp)
 45a:	e022                	sd	s0,0(sp)
 45c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 45e:	00000097          	auipc	ra,0x0
 462:	f66080e7          	jalr	-154(ra) # 3c4 <memmove>
}
 466:	60a2                	ld	ra,8(sp)
 468:	6402                	ld	s0,0(sp)
 46a:	0141                	addi	sp,sp,16
 46c:	8082                	ret

000000000000046e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 46e:	4885                	li	a7,1
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <exit>:
.global exit
exit:
 li a7, SYS_exit
 476:	4889                	li	a7,2
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <wait>:
.global wait
wait:
 li a7, SYS_wait
 47e:	488d                	li	a7,3
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 486:	4891                	li	a7,4
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <read>:
.global read
read:
 li a7, SYS_read
 48e:	4895                	li	a7,5
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <write>:
.global write
write:
 li a7, SYS_write
 496:	48c1                	li	a7,16
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <close>:
.global close
close:
 li a7, SYS_close
 49e:	48d5                	li	a7,21
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a6:	4899                	li	a7,6
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ae:	489d                	li	a7,7
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <open>:
.global open
open:
 li a7, SYS_open
 4b6:	48bd                	li	a7,15
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4be:	48c5                	li	a7,17
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c6:	48c9                	li	a7,18
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ce:	48a1                	li	a7,8
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <link>:
.global link
link:
 li a7, SYS_link
 4d6:	48cd                	li	a7,19
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4de:	48d1                	li	a7,20
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e6:	48a5                	li	a7,9
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ee:	48a9                	li	a7,10
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f6:	48ad                	li	a7,11
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4fe:	48b1                	li	a7,12
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 506:	48b5                	li	a7,13
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 50e:	48b9                	li	a7,14
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 516:	48d9                	li	a7,22
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <yield>:
.global yield
yield:
 li a7, SYS_yield
 51e:	48dd                	li	a7,23
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 526:	48e1                	li	a7,24
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 52e:	48e5                	li	a7,25
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 536:	48e9                	li	a7,26
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <ps>:
.global ps
ps:
 li a7, SYS_ps
 53e:	48ed                	li	a7,27
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 546:	48f1                	li	a7,28
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 54e:	48f5                	li	a7,29
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 556:	48f9                	li	a7,30
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 55e:	02100893          	li	a7,33
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 568:	48fd                	li	a7,31
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 570:	02000893          	li	a7,32
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 57a:	02200893          	li	a7,34
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 584:	02300893          	li	a7,35
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 58e:	02400893          	li	a7,36
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 598:	02500893          	li	a7,37
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 5a2:	02700893          	li	a7,39
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 5ac:	02600893          	li	a7,38
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5b6:	1101                	addi	sp,sp,-32
 5b8:	ec06                	sd	ra,24(sp)
 5ba:	e822                	sd	s0,16(sp)
 5bc:	1000                	addi	s0,sp,32
 5be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5c2:	4605                	li	a2,1
 5c4:	fef40593          	addi	a1,s0,-17
 5c8:	00000097          	auipc	ra,0x0
 5cc:	ece080e7          	jalr	-306(ra) # 496 <write>
}
 5d0:	60e2                	ld	ra,24(sp)
 5d2:	6442                	ld	s0,16(sp)
 5d4:	6105                	addi	sp,sp,32
 5d6:	8082                	ret

00000000000005d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5d8:	7139                	addi	sp,sp,-64
 5da:	fc06                	sd	ra,56(sp)
 5dc:	f822                	sd	s0,48(sp)
 5de:	f426                	sd	s1,40(sp)
 5e0:	f04a                	sd	s2,32(sp)
 5e2:	ec4e                	sd	s3,24(sp)
 5e4:	0080                	addi	s0,sp,64
 5e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5e8:	c299                	beqz	a3,5ee <printint+0x16>
 5ea:	0805c963          	bltz	a1,67c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ee:	2581                	sext.w	a1,a1
  neg = 0;
 5f0:	4881                	li	a7,0
 5f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5f8:	2601                	sext.w	a2,a2
 5fa:	00000517          	auipc	a0,0x0
 5fe:	56e50513          	addi	a0,a0,1390 # b68 <digits>
 602:	883a                	mv	a6,a4
 604:	2705                	addiw	a4,a4,1
 606:	02c5f7bb          	remuw	a5,a1,a2
 60a:	1782                	slli	a5,a5,0x20
 60c:	9381                	srli	a5,a5,0x20
 60e:	97aa                	add	a5,a5,a0
 610:	0007c783          	lbu	a5,0(a5)
 614:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 618:	0005879b          	sext.w	a5,a1
 61c:	02c5d5bb          	divuw	a1,a1,a2
 620:	0685                	addi	a3,a3,1
 622:	fec7f0e3          	bgeu	a5,a2,602 <printint+0x2a>
  if(neg)
 626:	00088c63          	beqz	a7,63e <printint+0x66>
    buf[i++] = '-';
 62a:	fd070793          	addi	a5,a4,-48
 62e:	00878733          	add	a4,a5,s0
 632:	02d00793          	li	a5,45
 636:	fef70823          	sb	a5,-16(a4)
 63a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 63e:	02e05863          	blez	a4,66e <printint+0x96>
 642:	fc040793          	addi	a5,s0,-64
 646:	00e78933          	add	s2,a5,a4
 64a:	fff78993          	addi	s3,a5,-1
 64e:	99ba                	add	s3,s3,a4
 650:	377d                	addiw	a4,a4,-1
 652:	1702                	slli	a4,a4,0x20
 654:	9301                	srli	a4,a4,0x20
 656:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 65a:	fff94583          	lbu	a1,-1(s2)
 65e:	8526                	mv	a0,s1
 660:	00000097          	auipc	ra,0x0
 664:	f56080e7          	jalr	-170(ra) # 5b6 <putc>
  while(--i >= 0)
 668:	197d                	addi	s2,s2,-1
 66a:	ff3918e3          	bne	s2,s3,65a <printint+0x82>
}
 66e:	70e2                	ld	ra,56(sp)
 670:	7442                	ld	s0,48(sp)
 672:	74a2                	ld	s1,40(sp)
 674:	7902                	ld	s2,32(sp)
 676:	69e2                	ld	s3,24(sp)
 678:	6121                	addi	sp,sp,64
 67a:	8082                	ret
    x = -xx;
 67c:	40b005bb          	negw	a1,a1
    neg = 1;
 680:	4885                	li	a7,1
    x = -xx;
 682:	bf85                	j	5f2 <printint+0x1a>

0000000000000684 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 684:	7119                	addi	sp,sp,-128
 686:	fc86                	sd	ra,120(sp)
 688:	f8a2                	sd	s0,112(sp)
 68a:	f4a6                	sd	s1,104(sp)
 68c:	f0ca                	sd	s2,96(sp)
 68e:	ecce                	sd	s3,88(sp)
 690:	e8d2                	sd	s4,80(sp)
 692:	e4d6                	sd	s5,72(sp)
 694:	e0da                	sd	s6,64(sp)
 696:	fc5e                	sd	s7,56(sp)
 698:	f862                	sd	s8,48(sp)
 69a:	f466                	sd	s9,40(sp)
 69c:	f06a                	sd	s10,32(sp)
 69e:	ec6e                	sd	s11,24(sp)
 6a0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6a2:	0005c903          	lbu	s2,0(a1)
 6a6:	18090f63          	beqz	s2,844 <vprintf+0x1c0>
 6aa:	8aaa                	mv	s5,a0
 6ac:	8b32                	mv	s6,a2
 6ae:	00158493          	addi	s1,a1,1
  state = 0;
 6b2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6b4:	02500a13          	li	s4,37
 6b8:	4c55                	li	s8,21
 6ba:	00000c97          	auipc	s9,0x0
 6be:	456c8c93          	addi	s9,s9,1110 # b10 <malloc+0x1c8>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6c2:	02800d93          	li	s11,40
  putc(fd, 'x');
 6c6:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c8:	00000b97          	auipc	s7,0x0
 6cc:	4a0b8b93          	addi	s7,s7,1184 # b68 <digits>
 6d0:	a839                	j	6ee <vprintf+0x6a>
        putc(fd, c);
 6d2:	85ca                	mv	a1,s2
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	ee0080e7          	jalr	-288(ra) # 5b6 <putc>
 6de:	a019                	j	6e4 <vprintf+0x60>
    } else if(state == '%'){
 6e0:	01498d63          	beq	s3,s4,6fa <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 6e4:	0485                	addi	s1,s1,1
 6e6:	fff4c903          	lbu	s2,-1(s1)
 6ea:	14090d63          	beqz	s2,844 <vprintf+0x1c0>
    if(state == 0){
 6ee:	fe0999e3          	bnez	s3,6e0 <vprintf+0x5c>
      if(c == '%'){
 6f2:	ff4910e3          	bne	s2,s4,6d2 <vprintf+0x4e>
        state = '%';
 6f6:	89d2                	mv	s3,s4
 6f8:	b7f5                	j	6e4 <vprintf+0x60>
      if(c == 'd'){
 6fa:	11490c63          	beq	s2,s4,812 <vprintf+0x18e>
 6fe:	f9d9079b          	addiw	a5,s2,-99
 702:	0ff7f793          	zext.b	a5,a5
 706:	10fc6e63          	bltu	s8,a5,822 <vprintf+0x19e>
 70a:	f9d9079b          	addiw	a5,s2,-99
 70e:	0ff7f713          	zext.b	a4,a5
 712:	10ec6863          	bltu	s8,a4,822 <vprintf+0x19e>
 716:	00271793          	slli	a5,a4,0x2
 71a:	97e6                	add	a5,a5,s9
 71c:	439c                	lw	a5,0(a5)
 71e:	97e6                	add	a5,a5,s9
 720:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 722:	008b0913          	addi	s2,s6,8
 726:	4685                	li	a3,1
 728:	4629                	li	a2,10
 72a:	000b2583          	lw	a1,0(s6)
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	ea8080e7          	jalr	-344(ra) # 5d8 <printint>
 738:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 73a:	4981                	li	s3,0
 73c:	b765                	j	6e4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 73e:	008b0913          	addi	s2,s6,8
 742:	4681                	li	a3,0
 744:	4629                	li	a2,10
 746:	000b2583          	lw	a1,0(s6)
 74a:	8556                	mv	a0,s5
 74c:	00000097          	auipc	ra,0x0
 750:	e8c080e7          	jalr	-372(ra) # 5d8 <printint>
 754:	8b4a                	mv	s6,s2
      state = 0;
 756:	4981                	li	s3,0
 758:	b771                	j	6e4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 75a:	008b0913          	addi	s2,s6,8
 75e:	4681                	li	a3,0
 760:	866a                	mv	a2,s10
 762:	000b2583          	lw	a1,0(s6)
 766:	8556                	mv	a0,s5
 768:	00000097          	auipc	ra,0x0
 76c:	e70080e7          	jalr	-400(ra) # 5d8 <printint>
 770:	8b4a                	mv	s6,s2
      state = 0;
 772:	4981                	li	s3,0
 774:	bf85                	j	6e4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 776:	008b0793          	addi	a5,s6,8
 77a:	f8f43423          	sd	a5,-120(s0)
 77e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 782:	03000593          	li	a1,48
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	e2e080e7          	jalr	-466(ra) # 5b6 <putc>
  putc(fd, 'x');
 790:	07800593          	li	a1,120
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	e20080e7          	jalr	-480(ra) # 5b6 <putc>
 79e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a0:	03c9d793          	srli	a5,s3,0x3c
 7a4:	97de                	add	a5,a5,s7
 7a6:	0007c583          	lbu	a1,0(a5)
 7aa:	8556                	mv	a0,s5
 7ac:	00000097          	auipc	ra,0x0
 7b0:	e0a080e7          	jalr	-502(ra) # 5b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b4:	0992                	slli	s3,s3,0x4
 7b6:	397d                	addiw	s2,s2,-1
 7b8:	fe0914e3          	bnez	s2,7a0 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 7bc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	b70d                	j	6e4 <vprintf+0x60>
        s = va_arg(ap, char*);
 7c4:	008b0913          	addi	s2,s6,8
 7c8:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 7cc:	02098163          	beqz	s3,7ee <vprintf+0x16a>
        while(*s != 0){
 7d0:	0009c583          	lbu	a1,0(s3)
 7d4:	c5ad                	beqz	a1,83e <vprintf+0x1ba>
          putc(fd, *s);
 7d6:	8556                	mv	a0,s5
 7d8:	00000097          	auipc	ra,0x0
 7dc:	dde080e7          	jalr	-546(ra) # 5b6 <putc>
          s++;
 7e0:	0985                	addi	s3,s3,1
        while(*s != 0){
 7e2:	0009c583          	lbu	a1,0(s3)
 7e6:	f9e5                	bnez	a1,7d6 <vprintf+0x152>
        s = va_arg(ap, char*);
 7e8:	8b4a                	mv	s6,s2
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bde5                	j	6e4 <vprintf+0x60>
          s = "(null)";
 7ee:	00000997          	auipc	s3,0x0
 7f2:	31a98993          	addi	s3,s3,794 # b08 <malloc+0x1c0>
        while(*s != 0){
 7f6:	85ee                	mv	a1,s11
 7f8:	bff9                	j	7d6 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7fa:	008b0913          	addi	s2,s6,8
 7fe:	000b4583          	lbu	a1,0(s6)
 802:	8556                	mv	a0,s5
 804:	00000097          	auipc	ra,0x0
 808:	db2080e7          	jalr	-590(ra) # 5b6 <putc>
 80c:	8b4a                	mv	s6,s2
      state = 0;
 80e:	4981                	li	s3,0
 810:	bdd1                	j	6e4 <vprintf+0x60>
        putc(fd, c);
 812:	85d2                	mv	a1,s4
 814:	8556                	mv	a0,s5
 816:	00000097          	auipc	ra,0x0
 81a:	da0080e7          	jalr	-608(ra) # 5b6 <putc>
      state = 0;
 81e:	4981                	li	s3,0
 820:	b5d1                	j	6e4 <vprintf+0x60>
        putc(fd, '%');
 822:	85d2                	mv	a1,s4
 824:	8556                	mv	a0,s5
 826:	00000097          	auipc	ra,0x0
 82a:	d90080e7          	jalr	-624(ra) # 5b6 <putc>
        putc(fd, c);
 82e:	85ca                	mv	a1,s2
 830:	8556                	mv	a0,s5
 832:	00000097          	auipc	ra,0x0
 836:	d84080e7          	jalr	-636(ra) # 5b6 <putc>
      state = 0;
 83a:	4981                	li	s3,0
 83c:	b565                	j	6e4 <vprintf+0x60>
        s = va_arg(ap, char*);
 83e:	8b4a                	mv	s6,s2
      state = 0;
 840:	4981                	li	s3,0
 842:	b54d                	j	6e4 <vprintf+0x60>
    }
  }
}
 844:	70e6                	ld	ra,120(sp)
 846:	7446                	ld	s0,112(sp)
 848:	74a6                	ld	s1,104(sp)
 84a:	7906                	ld	s2,96(sp)
 84c:	69e6                	ld	s3,88(sp)
 84e:	6a46                	ld	s4,80(sp)
 850:	6aa6                	ld	s5,72(sp)
 852:	6b06                	ld	s6,64(sp)
 854:	7be2                	ld	s7,56(sp)
 856:	7c42                	ld	s8,48(sp)
 858:	7ca2                	ld	s9,40(sp)
 85a:	7d02                	ld	s10,32(sp)
 85c:	6de2                	ld	s11,24(sp)
 85e:	6109                	addi	sp,sp,128
 860:	8082                	ret

0000000000000862 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 862:	715d                	addi	sp,sp,-80
 864:	ec06                	sd	ra,24(sp)
 866:	e822                	sd	s0,16(sp)
 868:	1000                	addi	s0,sp,32
 86a:	e010                	sd	a2,0(s0)
 86c:	e414                	sd	a3,8(s0)
 86e:	e818                	sd	a4,16(s0)
 870:	ec1c                	sd	a5,24(s0)
 872:	03043023          	sd	a6,32(s0)
 876:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 87a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 87e:	8622                	mv	a2,s0
 880:	00000097          	auipc	ra,0x0
 884:	e04080e7          	jalr	-508(ra) # 684 <vprintf>
}
 888:	60e2                	ld	ra,24(sp)
 88a:	6442                	ld	s0,16(sp)
 88c:	6161                	addi	sp,sp,80
 88e:	8082                	ret

0000000000000890 <printf>:

void
printf(const char *fmt, ...)
{
 890:	711d                	addi	sp,sp,-96
 892:	ec06                	sd	ra,24(sp)
 894:	e822                	sd	s0,16(sp)
 896:	1000                	addi	s0,sp,32
 898:	e40c                	sd	a1,8(s0)
 89a:	e810                	sd	a2,16(s0)
 89c:	ec14                	sd	a3,24(s0)
 89e:	f018                	sd	a4,32(s0)
 8a0:	f41c                	sd	a5,40(s0)
 8a2:	03043823          	sd	a6,48(s0)
 8a6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8aa:	00840613          	addi	a2,s0,8
 8ae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8b2:	85aa                	mv	a1,a0
 8b4:	4505                	li	a0,1
 8b6:	00000097          	auipc	ra,0x0
 8ba:	dce080e7          	jalr	-562(ra) # 684 <vprintf>
}
 8be:	60e2                	ld	ra,24(sp)
 8c0:	6442                	ld	s0,16(sp)
 8c2:	6125                	addi	sp,sp,96
 8c4:	8082                	ret

00000000000008c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c6:	1141                	addi	sp,sp,-16
 8c8:	e422                	sd	s0,8(sp)
 8ca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8cc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d0:	00000797          	auipc	a5,0x0
 8d4:	2b07b783          	ld	a5,688(a5) # b80 <freep>
 8d8:	a02d                	j	902 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8da:	4618                	lw	a4,8(a2)
 8dc:	9f2d                	addw	a4,a4,a1
 8de:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e2:	6398                	ld	a4,0(a5)
 8e4:	6310                	ld	a2,0(a4)
 8e6:	a83d                	j	924 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8e8:	ff852703          	lw	a4,-8(a0)
 8ec:	9f31                	addw	a4,a4,a2
 8ee:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8f0:	ff053683          	ld	a3,-16(a0)
 8f4:	a091                	j	938 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f6:	6398                	ld	a4,0(a5)
 8f8:	00e7e463          	bltu	a5,a4,900 <free+0x3a>
 8fc:	00e6ea63          	bltu	a3,a4,910 <free+0x4a>
{
 900:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 902:	fed7fae3          	bgeu	a5,a3,8f6 <free+0x30>
 906:	6398                	ld	a4,0(a5)
 908:	00e6e463          	bltu	a3,a4,910 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90c:	fee7eae3          	bltu	a5,a4,900 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 910:	ff852583          	lw	a1,-8(a0)
 914:	6390                	ld	a2,0(a5)
 916:	02059813          	slli	a6,a1,0x20
 91a:	01c85713          	srli	a4,a6,0x1c
 91e:	9736                	add	a4,a4,a3
 920:	fae60de3          	beq	a2,a4,8da <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 924:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 928:	4790                	lw	a2,8(a5)
 92a:	02061593          	slli	a1,a2,0x20
 92e:	01c5d713          	srli	a4,a1,0x1c
 932:	973e                	add	a4,a4,a5
 934:	fae68ae3          	beq	a3,a4,8e8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 938:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 93a:	00000717          	auipc	a4,0x0
 93e:	24f73323          	sd	a5,582(a4) # b80 <freep>
}
 942:	6422                	ld	s0,8(sp)
 944:	0141                	addi	sp,sp,16
 946:	8082                	ret

0000000000000948 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 948:	7139                	addi	sp,sp,-64
 94a:	fc06                	sd	ra,56(sp)
 94c:	f822                	sd	s0,48(sp)
 94e:	f426                	sd	s1,40(sp)
 950:	f04a                	sd	s2,32(sp)
 952:	ec4e                	sd	s3,24(sp)
 954:	e852                	sd	s4,16(sp)
 956:	e456                	sd	s5,8(sp)
 958:	e05a                	sd	s6,0(sp)
 95a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95c:	02051493          	slli	s1,a0,0x20
 960:	9081                	srli	s1,s1,0x20
 962:	04bd                	addi	s1,s1,15
 964:	8091                	srli	s1,s1,0x4
 966:	0014899b          	addiw	s3,s1,1
 96a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 96c:	00000517          	auipc	a0,0x0
 970:	21453503          	ld	a0,532(a0) # b80 <freep>
 974:	c515                	beqz	a0,9a0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 976:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 978:	4798                	lw	a4,8(a5)
 97a:	02977f63          	bgeu	a4,s1,9b8 <malloc+0x70>
 97e:	8a4e                	mv	s4,s3
 980:	0009871b          	sext.w	a4,s3
 984:	6685                	lui	a3,0x1
 986:	00d77363          	bgeu	a4,a3,98c <malloc+0x44>
 98a:	6a05                	lui	s4,0x1
 98c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 990:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 994:	00000917          	auipc	s2,0x0
 998:	1ec90913          	addi	s2,s2,492 # b80 <freep>
  if(p == (char*)-1)
 99c:	5afd                	li	s5,-1
 99e:	a895                	j	a12 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9a0:	00000797          	auipc	a5,0x0
 9a4:	1e878793          	addi	a5,a5,488 # b88 <base>
 9a8:	00000717          	auipc	a4,0x0
 9ac:	1cf73c23          	sd	a5,472(a4) # b80 <freep>
 9b0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9b2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9b6:	b7e1                	j	97e <malloc+0x36>
      if(p->s.size == nunits)
 9b8:	02e48c63          	beq	s1,a4,9f0 <malloc+0xa8>
        p->s.size -= nunits;
 9bc:	4137073b          	subw	a4,a4,s3
 9c0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9c2:	02071693          	slli	a3,a4,0x20
 9c6:	01c6d713          	srli	a4,a3,0x1c
 9ca:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9cc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9d0:	00000717          	auipc	a4,0x0
 9d4:	1aa73823          	sd	a0,432(a4) # b80 <freep>
      return (void*)(p + 1);
 9d8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9dc:	70e2                	ld	ra,56(sp)
 9de:	7442                	ld	s0,48(sp)
 9e0:	74a2                	ld	s1,40(sp)
 9e2:	7902                	ld	s2,32(sp)
 9e4:	69e2                	ld	s3,24(sp)
 9e6:	6a42                	ld	s4,16(sp)
 9e8:	6aa2                	ld	s5,8(sp)
 9ea:	6b02                	ld	s6,0(sp)
 9ec:	6121                	addi	sp,sp,64
 9ee:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9f0:	6398                	ld	a4,0(a5)
 9f2:	e118                	sd	a4,0(a0)
 9f4:	bff1                	j	9d0 <malloc+0x88>
  hp->s.size = nu;
 9f6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9fa:	0541                	addi	a0,a0,16
 9fc:	00000097          	auipc	ra,0x0
 a00:	eca080e7          	jalr	-310(ra) # 8c6 <free>
  return freep;
 a04:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a08:	d971                	beqz	a0,9dc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a0c:	4798                	lw	a4,8(a5)
 a0e:	fa9775e3          	bgeu	a4,s1,9b8 <malloc+0x70>
    if(p == freep)
 a12:	00093703          	ld	a4,0(s2)
 a16:	853e                	mv	a0,a5
 a18:	fef719e3          	bne	a4,a5,a0a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a1c:	8552                	mv	a0,s4
 a1e:	00000097          	auipc	ra,0x0
 a22:	ae0080e7          	jalr	-1312(ra) # 4fe <sbrk>
  if(p == (char*)-1)
 a26:	fd5518e3          	bne	a0,s5,9f6 <malloc+0xae>
        return 0;
 a2a:	4501                	li	a0,0
 a2c:	bf45                	j	9dc <malloc+0x94>
