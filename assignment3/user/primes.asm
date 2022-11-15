
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <primes>:
#include "kernel/types.h"
#include "user/user.h"

void primes (int rfd, int primecount)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
   e:	84aa                	mv	s1,a0
  10:	892e                	mv	s2,a1
   int x, y, z, pipefd[2];
   int count = 0;

   if (pipe(pipefd) < 0) {
  12:	fc040513          	addi	a0,s0,-64
  16:	00000097          	auipc	ra,0x0
  1a:	546080e7          	jalr	1350(ra) # 55c <pipe>
  1e:	06054863          	bltz	a0,8e <primes+0x8e>
      fprintf(2, "Error: cannot create pipe\nAborting...\n");
      exit(0);
   }

   if (read(rfd, &x, sizeof(int)) <= 0) {
  22:	4611                	li	a2,4
  24:	fcc40593          	addi	a1,s0,-52
  28:	8526                	mv	a0,s1
  2a:	00000097          	auipc	ra,0x0
  2e:	53a080e7          	jalr	1338(ra) # 564 <read>
  32:	06a05c63          	blez	a0,aa <primes+0xaa>
      fprintf(2, "Error: cannot read from pipe\nAborting...\n");
      exit(0);
   }
   primecount++;
  36:	2905                	addiw	s2,s2,1
   fprintf(1, "%d: prime %d\n", primecount, x);
  38:	fcc42683          	lw	a3,-52(s0)
  3c:	864a                	mv	a2,s2
  3e:	00001597          	auipc	a1,0x1
  42:	b2258593          	addi	a1,a1,-1246 # b60 <malloc+0x142>
  46:	4505                	li	a0,1
  48:	00001097          	auipc	ra,0x1
  4c:	8f0080e7          	jalr	-1808(ra) # 938 <fprintf>
   int count = 0;
  50:	4981                	li	s3,0
   while (read(rfd, &y, sizeof(int)) > 0) {
  52:	4611                	li	a2,4
  54:	fc840593          	addi	a1,s0,-56
  58:	8526                	mv	a0,s1
  5a:	00000097          	auipc	ra,0x0
  5e:	50a080e7          	jalr	1290(ra) # 564 <read>
  62:	08a05063          	blez	a0,e2 <primes+0xe2>
      if ((y % x) != 0) {
  66:	fc842783          	lw	a5,-56(s0)
  6a:	fcc42703          	lw	a4,-52(s0)
  6e:	02e7e7bb          	remw	a5,a5,a4
  72:	d3e5                	beqz	a5,52 <primes+0x52>
         if (write(pipefd[1], &y, sizeof(int)) <= 0) {
  74:	4611                	li	a2,4
  76:	fc840593          	addi	a1,s0,-56
  7a:	fc442503          	lw	a0,-60(s0)
  7e:	00000097          	auipc	ra,0x0
  82:	4ee080e7          	jalr	1262(ra) # 56c <write>
  86:	04a05063          	blez	a0,c6 <primes+0xc6>
            fprintf(2, "Error: cannot write to pipe\nAborting...\n");
            exit(0);
         }
	 count++;
  8a:	2985                	addiw	s3,s3,1
  8c:	b7d9                	j	52 <primes+0x52>
      fprintf(2, "Error: cannot create pipe\nAborting...\n");
  8e:	00001597          	auipc	a1,0x1
  92:	a7a58593          	addi	a1,a1,-1414 # b08 <malloc+0xea>
  96:	4509                	li	a0,2
  98:	00001097          	auipc	ra,0x1
  9c:	8a0080e7          	jalr	-1888(ra) # 938 <fprintf>
      exit(0);
  a0:	4501                	li	a0,0
  a2:	00000097          	auipc	ra,0x0
  a6:	4aa080e7          	jalr	1194(ra) # 54c <exit>
      fprintf(2, "Error: cannot read from pipe\nAborting...\n");
  aa:	00001597          	auipc	a1,0x1
  ae:	a8658593          	addi	a1,a1,-1402 # b30 <malloc+0x112>
  b2:	4509                	li	a0,2
  b4:	00001097          	auipc	ra,0x1
  b8:	884080e7          	jalr	-1916(ra) # 938 <fprintf>
      exit(0);
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	48e080e7          	jalr	1166(ra) # 54c <exit>
            fprintf(2, "Error: cannot write to pipe\nAborting...\n");
  c6:	00001597          	auipc	a1,0x1
  ca:	aaa58593          	addi	a1,a1,-1366 # b70 <malloc+0x152>
  ce:	4509                	li	a0,2
  d0:	00001097          	auipc	ra,0x1
  d4:	868080e7          	jalr	-1944(ra) # 938 <fprintf>
            exit(0);
  d8:	4501                	li	a0,0
  da:	00000097          	auipc	ra,0x0
  de:	472080e7          	jalr	1138(ra) # 54c <exit>
      }
   }
   close(rfd);
  e2:	8526                	mv	a0,s1
  e4:	00000097          	auipc	ra,0x0
  e8:	490080e7          	jalr	1168(ra) # 574 <close>
   close(pipefd[1]);
  ec:	fc442503          	lw	a0,-60(s0)
  f0:	00000097          	auipc	ra,0x0
  f4:	484080e7          	jalr	1156(ra) # 574 <close>
   if (count) {
  f8:	04098b63          	beqz	s3,14e <primes+0x14e>
      z = fork();
  fc:	00000097          	auipc	ra,0x0
 100:	448080e7          	jalr	1096(ra) # 544 <fork>
      if (z < 0) {
 104:	02054063          	bltz	a0,124 <primes+0x124>
         fprintf(2, "Error: cannot fork\nAborting...\n");
         exit(0);
      }
      else if (z > 0) {
 108:	02a05c63          	blez	a0,140 <primes+0x140>
	 close(pipefd[0]);
 10c:	fc042503          	lw	a0,-64(s0)
 110:	00000097          	auipc	ra,0x0
 114:	464080e7          	jalr	1124(ra) # 574 <close>
         wait(0);
 118:	4501                	li	a0,0
 11a:	00000097          	auipc	ra,0x0
 11e:	43a080e7          	jalr	1082(ra) # 554 <wait>
 122:	a825                	j	15a <primes+0x15a>
         fprintf(2, "Error: cannot fork\nAborting...\n");
 124:	00001597          	auipc	a1,0x1
 128:	a7c58593          	addi	a1,a1,-1412 # ba0 <malloc+0x182>
 12c:	4509                	li	a0,2
 12e:	00001097          	auipc	ra,0x1
 132:	80a080e7          	jalr	-2038(ra) # 938 <fprintf>
         exit(0);
 136:	4501                	li	a0,0
 138:	00000097          	auipc	ra,0x0
 13c:	414080e7          	jalr	1044(ra) # 54c <exit>
      }
      else primes(pipefd[0], primecount);
 140:	85ca                	mv	a1,s2
 142:	fc042503          	lw	a0,-64(s0)
 146:	00000097          	auipc	ra,0x0
 14a:	eba080e7          	jalr	-326(ra) # 0 <primes>
   }
   else close(pipefd[0]);
 14e:	fc042503          	lw	a0,-64(s0)
 152:	00000097          	auipc	ra,0x0
 156:	422080e7          	jalr	1058(ra) # 574 <close>
   exit(0);
 15a:	4501                	li	a0,0
 15c:	00000097          	auipc	ra,0x0
 160:	3f0080e7          	jalr	1008(ra) # 54c <exit>

0000000000000164 <main>:
}
     
int
main(int argc, char *argv[])
{
 164:	7179                	addi	sp,sp,-48
 166:	f406                	sd	ra,40(sp)
 168:	f022                	sd	s0,32(sp)
 16a:	ec26                	sd	s1,24(sp)
 16c:	e84a                	sd	s2,16(sp)
 16e:	1800                	addi	s0,sp,48
  int pipefd[2], x, y, i, count=0, primecount=1;

  if (argc != 2) {
 170:	4789                	li	a5,2
 172:	02f50063          	beq	a0,a5,192 <main+0x2e>
     fprintf(2, "syntax: primes n\nAborting...\n");
 176:	00001597          	auipc	a1,0x1
 17a:	a4a58593          	addi	a1,a1,-1462 # bc0 <malloc+0x1a2>
 17e:	4509                	li	a0,2
 180:	00000097          	auipc	ra,0x0
 184:	7b8080e7          	jalr	1976(ra) # 938 <fprintf>
     exit(0);
 188:	4501                	li	a0,0
 18a:	00000097          	auipc	ra,0x0
 18e:	3c2080e7          	jalr	962(ra) # 54c <exit>
  }
  y = atoi(argv[1]);
 192:	6588                	ld	a0,8(a1)
 194:	00000097          	auipc	ra,0x0
 198:	2be080e7          	jalr	702(ra) # 452 <atoi>
 19c:	84aa                	mv	s1,a0
  if (y < 2) {
 19e:	4785                	li	a5,1
 1a0:	02a7dc63          	bge	a5,a0,1d8 <main+0x74>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }

  if (pipe(pipefd) < 0) {
 1a4:	fd840513          	addi	a0,s0,-40
 1a8:	00000097          	auipc	ra,0x0
 1ac:	3b4080e7          	jalr	948(ra) # 55c <pipe>
 1b0:	04054263          	bltz	a0,1f4 <main+0x90>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
     exit(0);
  }

  fprintf(1, "1: prime 2\n");
 1b4:	00001597          	auipc	a1,0x1
 1b8:	a4c58593          	addi	a1,a1,-1460 # c00 <malloc+0x1e2>
 1bc:	4505                	li	a0,1
 1be:	00000097          	auipc	ra,0x0
 1c2:	77a080e7          	jalr	1914(ra) # 938 <fprintf>
  for (i=3; i<=y; i++) {
 1c6:	478d                	li	a5,3
 1c8:	fcf42a23          	sw	a5,-44(s0)
 1cc:	4789                	li	a5,2
 1ce:	0e97d863          	bge	a5,s1,2be <main+0x15a>
  int pipefd[2], x, y, i, count=0, primecount=1;
 1d2:	4901                	li	s2,0
  for (i=3; i<=y; i++) {
 1d4:	478d                	li	a5,3
 1d6:	a0a5                	j	23e <main+0xda>
     fprintf(2, "Invalid input\nAborting...\n");
 1d8:	00001597          	auipc	a1,0x1
 1dc:	a0858593          	addi	a1,a1,-1528 # be0 <malloc+0x1c2>
 1e0:	4509                	li	a0,2
 1e2:	00000097          	auipc	ra,0x0
 1e6:	756080e7          	jalr	1878(ra) # 938 <fprintf>
     exit(0);
 1ea:	4501                	li	a0,0
 1ec:	00000097          	auipc	ra,0x0
 1f0:	360080e7          	jalr	864(ra) # 54c <exit>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
 1f4:	00001597          	auipc	a1,0x1
 1f8:	91458593          	addi	a1,a1,-1772 # b08 <malloc+0xea>
 1fc:	4509                	li	a0,2
 1fe:	00000097          	auipc	ra,0x0
 202:	73a080e7          	jalr	1850(ra) # 938 <fprintf>
     exit(0);
 206:	4501                	li	a0,0
 208:	00000097          	auipc	ra,0x0
 20c:	344080e7          	jalr	836(ra) # 54c <exit>
     if ((i%2) != 0) {
        if (write(pipefd[1], &i, sizeof(int)) <= 0) {
           fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 210:	00001597          	auipc	a1,0x1
 214:	96058593          	addi	a1,a1,-1696 # b70 <malloc+0x152>
 218:	4509                	li	a0,2
 21a:	00000097          	auipc	ra,0x0
 21e:	71e080e7          	jalr	1822(ra) # 938 <fprintf>
           exit(0);
 222:	4501                	li	a0,0
 224:	00000097          	auipc	ra,0x0
 228:	328080e7          	jalr	808(ra) # 54c <exit>
  for (i=3; i<=y; i++) {
 22c:	fd442703          	lw	a4,-44(s0)
 230:	2705                	addiw	a4,a4,1
 232:	0007079b          	sext.w	a5,a4
 236:	fce42a23          	sw	a4,-44(s0)
 23a:	02f4c163          	blt	s1,a5,25c <main+0xf8>
     if ((i%2) != 0) {
 23e:	8b85                	andi	a5,a5,1
 240:	d7f5                	beqz	a5,22c <main+0xc8>
        if (write(pipefd[1], &i, sizeof(int)) <= 0) {
 242:	4611                	li	a2,4
 244:	fd440593          	addi	a1,s0,-44
 248:	fdc42503          	lw	a0,-36(s0)
 24c:	00000097          	auipc	ra,0x0
 250:	320080e7          	jalr	800(ra) # 56c <write>
 254:	faa05ee3          	blez	a0,210 <main+0xac>
        }
	count++;
 258:	2905                	addiw	s2,s2,1
 25a:	bfc9                	j	22c <main+0xc8>
     }
  }
  close(pipefd[1]);
 25c:	fdc42503          	lw	a0,-36(s0)
 260:	00000097          	auipc	ra,0x0
 264:	314080e7          	jalr	788(ra) # 574 <close>
  if (count) {
 268:	06090163          	beqz	s2,2ca <main+0x166>
     x = fork();
 26c:	00000097          	auipc	ra,0x0
 270:	2d8080e7          	jalr	728(ra) # 544 <fork>
     if (x < 0) {
 274:	02054063          	bltz	a0,294 <main+0x130>
        fprintf(2, "Error: cannot fork\nAborting...\n");
        exit(0);
     }
     else if (x > 0) {
 278:	02a05c63          	blez	a0,2b0 <main+0x14c>
	close(pipefd[0]);
 27c:	fd842503          	lw	a0,-40(s0)
 280:	00000097          	auipc	ra,0x0
 284:	2f4080e7          	jalr	756(ra) # 574 <close>
        wait(0);
 288:	4501                	li	a0,0
 28a:	00000097          	auipc	ra,0x0
 28e:	2ca080e7          	jalr	714(ra) # 554 <wait>
 292:	a091                	j	2d6 <main+0x172>
        fprintf(2, "Error: cannot fork\nAborting...\n");
 294:	00001597          	auipc	a1,0x1
 298:	90c58593          	addi	a1,a1,-1780 # ba0 <malloc+0x182>
 29c:	4509                	li	a0,2
 29e:	00000097          	auipc	ra,0x0
 2a2:	69a080e7          	jalr	1690(ra) # 938 <fprintf>
        exit(0);
 2a6:	4501                	li	a0,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	2a4080e7          	jalr	676(ra) # 54c <exit>
     }
     else primes(pipefd[0], primecount);
 2b0:	4585                	li	a1,1
 2b2:	fd842503          	lw	a0,-40(s0)
 2b6:	00000097          	auipc	ra,0x0
 2ba:	d4a080e7          	jalr	-694(ra) # 0 <primes>
  close(pipefd[1]);
 2be:	fdc42503          	lw	a0,-36(s0)
 2c2:	00000097          	auipc	ra,0x0
 2c6:	2b2080e7          	jalr	690(ra) # 574 <close>
  }
  else close(pipefd[0]);
 2ca:	fd842503          	lw	a0,-40(s0)
 2ce:	00000097          	auipc	ra,0x0
 2d2:	2a6080e7          	jalr	678(ra) # 574 <close>

  exit(0);
 2d6:	4501                	li	a0,0
 2d8:	00000097          	auipc	ra,0x0
 2dc:	274080e7          	jalr	628(ra) # 54c <exit>

00000000000002e0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2e6:	87aa                	mv	a5,a0
 2e8:	0585                	addi	a1,a1,1
 2ea:	0785                	addi	a5,a5,1
 2ec:	fff5c703          	lbu	a4,-1(a1)
 2f0:	fee78fa3          	sb	a4,-1(a5)
 2f4:	fb75                	bnez	a4,2e8 <strcpy+0x8>
    ;
  return os;
}
 2f6:	6422                	ld	s0,8(sp)
 2f8:	0141                	addi	sp,sp,16
 2fa:	8082                	ret

00000000000002fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e422                	sd	s0,8(sp)
 300:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 302:	00054783          	lbu	a5,0(a0)
 306:	cb91                	beqz	a5,31a <strcmp+0x1e>
 308:	0005c703          	lbu	a4,0(a1)
 30c:	00f71763          	bne	a4,a5,31a <strcmp+0x1e>
    p++, q++;
 310:	0505                	addi	a0,a0,1
 312:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 314:	00054783          	lbu	a5,0(a0)
 318:	fbe5                	bnez	a5,308 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 31a:	0005c503          	lbu	a0,0(a1)
}
 31e:	40a7853b          	subw	a0,a5,a0
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret

0000000000000328 <strlen>:

uint
strlen(const char *s)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 32e:	00054783          	lbu	a5,0(a0)
 332:	cf91                	beqz	a5,34e <strlen+0x26>
 334:	0505                	addi	a0,a0,1
 336:	87aa                	mv	a5,a0
 338:	4685                	li	a3,1
 33a:	9e89                	subw	a3,a3,a0
 33c:	00f6853b          	addw	a0,a3,a5
 340:	0785                	addi	a5,a5,1
 342:	fff7c703          	lbu	a4,-1(a5)
 346:	fb7d                	bnez	a4,33c <strlen+0x14>
    ;
  return n;
}
 348:	6422                	ld	s0,8(sp)
 34a:	0141                	addi	sp,sp,16
 34c:	8082                	ret
  for(n = 0; s[n]; n++)
 34e:	4501                	li	a0,0
 350:	bfe5                	j	348 <strlen+0x20>

0000000000000352 <memset>:

void*
memset(void *dst, int c, uint n)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 358:	ca19                	beqz	a2,36e <memset+0x1c>
 35a:	87aa                	mv	a5,a0
 35c:	1602                	slli	a2,a2,0x20
 35e:	9201                	srli	a2,a2,0x20
 360:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 364:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 368:	0785                	addi	a5,a5,1
 36a:	fee79de3          	bne	a5,a4,364 <memset+0x12>
  }
  return dst;
}
 36e:	6422                	ld	s0,8(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <strchr>:

char*
strchr(const char *s, char c)
{
 374:	1141                	addi	sp,sp,-16
 376:	e422                	sd	s0,8(sp)
 378:	0800                	addi	s0,sp,16
  for(; *s; s++)
 37a:	00054783          	lbu	a5,0(a0)
 37e:	cb99                	beqz	a5,394 <strchr+0x20>
    if(*s == c)
 380:	00f58763          	beq	a1,a5,38e <strchr+0x1a>
  for(; *s; s++)
 384:	0505                	addi	a0,a0,1
 386:	00054783          	lbu	a5,0(a0)
 38a:	fbfd                	bnez	a5,380 <strchr+0xc>
      return (char*)s;
  return 0;
 38c:	4501                	li	a0,0
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret
  return 0;
 394:	4501                	li	a0,0
 396:	bfe5                	j	38e <strchr+0x1a>

0000000000000398 <gets>:

char*
gets(char *buf, int max)
{
 398:	711d                	addi	sp,sp,-96
 39a:	ec86                	sd	ra,88(sp)
 39c:	e8a2                	sd	s0,80(sp)
 39e:	e4a6                	sd	s1,72(sp)
 3a0:	e0ca                	sd	s2,64(sp)
 3a2:	fc4e                	sd	s3,56(sp)
 3a4:	f852                	sd	s4,48(sp)
 3a6:	f456                	sd	s5,40(sp)
 3a8:	f05a                	sd	s6,32(sp)
 3aa:	ec5e                	sd	s7,24(sp)
 3ac:	1080                	addi	s0,sp,96
 3ae:	8baa                	mv	s7,a0
 3b0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b2:	892a                	mv	s2,a0
 3b4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3b6:	4aa9                	li	s5,10
 3b8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3ba:	89a6                	mv	s3,s1
 3bc:	2485                	addiw	s1,s1,1
 3be:	0344d863          	bge	s1,s4,3ee <gets+0x56>
    cc = read(0, &c, 1);
 3c2:	4605                	li	a2,1
 3c4:	faf40593          	addi	a1,s0,-81
 3c8:	4501                	li	a0,0
 3ca:	00000097          	auipc	ra,0x0
 3ce:	19a080e7          	jalr	410(ra) # 564 <read>
    if(cc < 1)
 3d2:	00a05e63          	blez	a0,3ee <gets+0x56>
    buf[i++] = c;
 3d6:	faf44783          	lbu	a5,-81(s0)
 3da:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3de:	01578763          	beq	a5,s5,3ec <gets+0x54>
 3e2:	0905                	addi	s2,s2,1
 3e4:	fd679be3          	bne	a5,s6,3ba <gets+0x22>
  for(i=0; i+1 < max; ){
 3e8:	89a6                	mv	s3,s1
 3ea:	a011                	j	3ee <gets+0x56>
 3ec:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3ee:	99de                	add	s3,s3,s7
 3f0:	00098023          	sb	zero,0(s3)
  return buf;
}
 3f4:	855e                	mv	a0,s7
 3f6:	60e6                	ld	ra,88(sp)
 3f8:	6446                	ld	s0,80(sp)
 3fa:	64a6                	ld	s1,72(sp)
 3fc:	6906                	ld	s2,64(sp)
 3fe:	79e2                	ld	s3,56(sp)
 400:	7a42                	ld	s4,48(sp)
 402:	7aa2                	ld	s5,40(sp)
 404:	7b02                	ld	s6,32(sp)
 406:	6be2                	ld	s7,24(sp)
 408:	6125                	addi	sp,sp,96
 40a:	8082                	ret

000000000000040c <stat>:

int
stat(const char *n, struct stat *st)
{
 40c:	1101                	addi	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	e426                	sd	s1,8(sp)
 414:	e04a                	sd	s2,0(sp)
 416:	1000                	addi	s0,sp,32
 418:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 41a:	4581                	li	a1,0
 41c:	00000097          	auipc	ra,0x0
 420:	170080e7          	jalr	368(ra) # 58c <open>
  if(fd < 0)
 424:	02054563          	bltz	a0,44e <stat+0x42>
 428:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 42a:	85ca                	mv	a1,s2
 42c:	00000097          	auipc	ra,0x0
 430:	178080e7          	jalr	376(ra) # 5a4 <fstat>
 434:	892a                	mv	s2,a0
  close(fd);
 436:	8526                	mv	a0,s1
 438:	00000097          	auipc	ra,0x0
 43c:	13c080e7          	jalr	316(ra) # 574 <close>
  return r;
}
 440:	854a                	mv	a0,s2
 442:	60e2                	ld	ra,24(sp)
 444:	6442                	ld	s0,16(sp)
 446:	64a2                	ld	s1,8(sp)
 448:	6902                	ld	s2,0(sp)
 44a:	6105                	addi	sp,sp,32
 44c:	8082                	ret
    return -1;
 44e:	597d                	li	s2,-1
 450:	bfc5                	j	440 <stat+0x34>

0000000000000452 <atoi>:

int
atoi(const char *s)
{
 452:	1141                	addi	sp,sp,-16
 454:	e422                	sd	s0,8(sp)
 456:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 458:	00054683          	lbu	a3,0(a0)
 45c:	fd06879b          	addiw	a5,a3,-48
 460:	0ff7f793          	zext.b	a5,a5
 464:	4625                	li	a2,9
 466:	02f66863          	bltu	a2,a5,496 <atoi+0x44>
 46a:	872a                	mv	a4,a0
  n = 0;
 46c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 46e:	0705                	addi	a4,a4,1
 470:	0025179b          	slliw	a5,a0,0x2
 474:	9fa9                	addw	a5,a5,a0
 476:	0017979b          	slliw	a5,a5,0x1
 47a:	9fb5                	addw	a5,a5,a3
 47c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 480:	00074683          	lbu	a3,0(a4)
 484:	fd06879b          	addiw	a5,a3,-48
 488:	0ff7f793          	zext.b	a5,a5
 48c:	fef671e3          	bgeu	a2,a5,46e <atoi+0x1c>
  return n;
}
 490:	6422                	ld	s0,8(sp)
 492:	0141                	addi	sp,sp,16
 494:	8082                	ret
  n = 0;
 496:	4501                	li	a0,0
 498:	bfe5                	j	490 <atoi+0x3e>

000000000000049a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 49a:	1141                	addi	sp,sp,-16
 49c:	e422                	sd	s0,8(sp)
 49e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4a0:	02b57463          	bgeu	a0,a1,4c8 <memmove+0x2e>
    while(n-- > 0)
 4a4:	00c05f63          	blez	a2,4c2 <memmove+0x28>
 4a8:	1602                	slli	a2,a2,0x20
 4aa:	9201                	srli	a2,a2,0x20
 4ac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 4b2:	0585                	addi	a1,a1,1
 4b4:	0705                	addi	a4,a4,1
 4b6:	fff5c683          	lbu	a3,-1(a1)
 4ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4be:	fee79ae3          	bne	a5,a4,4b2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4c2:	6422                	ld	s0,8(sp)
 4c4:	0141                	addi	sp,sp,16
 4c6:	8082                	ret
    dst += n;
 4c8:	00c50733          	add	a4,a0,a2
    src += n;
 4cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4ce:	fec05ae3          	blez	a2,4c2 <memmove+0x28>
 4d2:	fff6079b          	addiw	a5,a2,-1
 4d6:	1782                	slli	a5,a5,0x20
 4d8:	9381                	srli	a5,a5,0x20
 4da:	fff7c793          	not	a5,a5
 4de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4e0:	15fd                	addi	a1,a1,-1
 4e2:	177d                	addi	a4,a4,-1
 4e4:	0005c683          	lbu	a3,0(a1)
 4e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4ec:	fee79ae3          	bne	a5,a4,4e0 <memmove+0x46>
 4f0:	bfc9                	j	4c2 <memmove+0x28>

00000000000004f2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4f2:	1141                	addi	sp,sp,-16
 4f4:	e422                	sd	s0,8(sp)
 4f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4f8:	ca05                	beqz	a2,528 <memcmp+0x36>
 4fa:	fff6069b          	addiw	a3,a2,-1
 4fe:	1682                	slli	a3,a3,0x20
 500:	9281                	srli	a3,a3,0x20
 502:	0685                	addi	a3,a3,1
 504:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 506:	00054783          	lbu	a5,0(a0)
 50a:	0005c703          	lbu	a4,0(a1)
 50e:	00e79863          	bne	a5,a4,51e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 512:	0505                	addi	a0,a0,1
    p2++;
 514:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 516:	fed518e3          	bne	a0,a3,506 <memcmp+0x14>
  }
  return 0;
 51a:	4501                	li	a0,0
 51c:	a019                	j	522 <memcmp+0x30>
      return *p1 - *p2;
 51e:	40e7853b          	subw	a0,a5,a4
}
 522:	6422                	ld	s0,8(sp)
 524:	0141                	addi	sp,sp,16
 526:	8082                	ret
  return 0;
 528:	4501                	li	a0,0
 52a:	bfe5                	j	522 <memcmp+0x30>

000000000000052c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 52c:	1141                	addi	sp,sp,-16
 52e:	e406                	sd	ra,8(sp)
 530:	e022                	sd	s0,0(sp)
 532:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 534:	00000097          	auipc	ra,0x0
 538:	f66080e7          	jalr	-154(ra) # 49a <memmove>
}
 53c:	60a2                	ld	ra,8(sp)
 53e:	6402                	ld	s0,0(sp)
 540:	0141                	addi	sp,sp,16
 542:	8082                	ret

0000000000000544 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 544:	4885                	li	a7,1
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <exit>:
.global exit
exit:
 li a7, SYS_exit
 54c:	4889                	li	a7,2
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <wait>:
.global wait
wait:
 li a7, SYS_wait
 554:	488d                	li	a7,3
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 55c:	4891                	li	a7,4
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <read>:
.global read
read:
 li a7, SYS_read
 564:	4895                	li	a7,5
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <write>:
.global write
write:
 li a7, SYS_write
 56c:	48c1                	li	a7,16
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <close>:
.global close
close:
 li a7, SYS_close
 574:	48d5                	li	a7,21
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <kill>:
.global kill
kill:
 li a7, SYS_kill
 57c:	4899                	li	a7,6
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <exec>:
.global exec
exec:
 li a7, SYS_exec
 584:	489d                	li	a7,7
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <open>:
.global open
open:
 li a7, SYS_open
 58c:	48bd                	li	a7,15
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 594:	48c5                	li	a7,17
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 59c:	48c9                	li	a7,18
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5a4:	48a1                	li	a7,8
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <link>:
.global link
link:
 li a7, SYS_link
 5ac:	48cd                	li	a7,19
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5b4:	48d1                	li	a7,20
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5bc:	48a5                	li	a7,9
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5c4:	48a9                	li	a7,10
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5cc:	48ad                	li	a7,11
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5d4:	48b1                	li	a7,12
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5dc:	48b5                	li	a7,13
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5e4:	48b9                	li	a7,14
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 5ec:	48d9                	li	a7,22
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <yield>:
.global yield
yield:
 li a7, SYS_yield
 5f4:	48dd                	li	a7,23
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 5fc:	48e1                	li	a7,24
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 604:	48e5                	li	a7,25
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 60c:	48e9                	li	a7,26
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <ps>:
.global ps
ps:
 li a7, SYS_ps
 614:	48ed                	li	a7,27
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 61c:	48f1                	li	a7,28
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 624:	48f5                	li	a7,29
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 62c:	48f9                	li	a7,30
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 634:	02100893          	li	a7,33
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 63e:	48fd                	li	a7,31
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 646:	02000893          	li	a7,32
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 650:	02200893          	li	a7,34
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 65a:	02300893          	li	a7,35
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 664:	02400893          	li	a7,36
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 66e:	02500893          	li	a7,37
 ecall
 672:	00000073          	ecall
 ret
 676:	8082                	ret

0000000000000678 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 678:	02700893          	li	a7,39
 ecall
 67c:	00000073          	ecall
 ret
 680:	8082                	ret

0000000000000682 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 682:	02600893          	li	a7,38
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 68c:	1101                	addi	sp,sp,-32
 68e:	ec06                	sd	ra,24(sp)
 690:	e822                	sd	s0,16(sp)
 692:	1000                	addi	s0,sp,32
 694:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 698:	4605                	li	a2,1
 69a:	fef40593          	addi	a1,s0,-17
 69e:	00000097          	auipc	ra,0x0
 6a2:	ece080e7          	jalr	-306(ra) # 56c <write>
}
 6a6:	60e2                	ld	ra,24(sp)
 6a8:	6442                	ld	s0,16(sp)
 6aa:	6105                	addi	sp,sp,32
 6ac:	8082                	ret

00000000000006ae <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6ae:	7139                	addi	sp,sp,-64
 6b0:	fc06                	sd	ra,56(sp)
 6b2:	f822                	sd	s0,48(sp)
 6b4:	f426                	sd	s1,40(sp)
 6b6:	f04a                	sd	s2,32(sp)
 6b8:	ec4e                	sd	s3,24(sp)
 6ba:	0080                	addi	s0,sp,64
 6bc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6be:	c299                	beqz	a3,6c4 <printint+0x16>
 6c0:	0805c963          	bltz	a1,752 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6c4:	2581                	sext.w	a1,a1
  neg = 0;
 6c6:	4881                	li	a7,0
 6c8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6cc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6ce:	2601                	sext.w	a2,a2
 6d0:	00000517          	auipc	a0,0x0
 6d4:	5a050513          	addi	a0,a0,1440 # c70 <digits>
 6d8:	883a                	mv	a6,a4
 6da:	2705                	addiw	a4,a4,1
 6dc:	02c5f7bb          	remuw	a5,a1,a2
 6e0:	1782                	slli	a5,a5,0x20
 6e2:	9381                	srli	a5,a5,0x20
 6e4:	97aa                	add	a5,a5,a0
 6e6:	0007c783          	lbu	a5,0(a5)
 6ea:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6ee:	0005879b          	sext.w	a5,a1
 6f2:	02c5d5bb          	divuw	a1,a1,a2
 6f6:	0685                	addi	a3,a3,1
 6f8:	fec7f0e3          	bgeu	a5,a2,6d8 <printint+0x2a>
  if(neg)
 6fc:	00088c63          	beqz	a7,714 <printint+0x66>
    buf[i++] = '-';
 700:	fd070793          	addi	a5,a4,-48
 704:	00878733          	add	a4,a5,s0
 708:	02d00793          	li	a5,45
 70c:	fef70823          	sb	a5,-16(a4)
 710:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 714:	02e05863          	blez	a4,744 <printint+0x96>
 718:	fc040793          	addi	a5,s0,-64
 71c:	00e78933          	add	s2,a5,a4
 720:	fff78993          	addi	s3,a5,-1
 724:	99ba                	add	s3,s3,a4
 726:	377d                	addiw	a4,a4,-1
 728:	1702                	slli	a4,a4,0x20
 72a:	9301                	srli	a4,a4,0x20
 72c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 730:	fff94583          	lbu	a1,-1(s2)
 734:	8526                	mv	a0,s1
 736:	00000097          	auipc	ra,0x0
 73a:	f56080e7          	jalr	-170(ra) # 68c <putc>
  while(--i >= 0)
 73e:	197d                	addi	s2,s2,-1
 740:	ff3918e3          	bne	s2,s3,730 <printint+0x82>
}
 744:	70e2                	ld	ra,56(sp)
 746:	7442                	ld	s0,48(sp)
 748:	74a2                	ld	s1,40(sp)
 74a:	7902                	ld	s2,32(sp)
 74c:	69e2                	ld	s3,24(sp)
 74e:	6121                	addi	sp,sp,64
 750:	8082                	ret
    x = -xx;
 752:	40b005bb          	negw	a1,a1
    neg = 1;
 756:	4885                	li	a7,1
    x = -xx;
 758:	bf85                	j	6c8 <printint+0x1a>

000000000000075a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 75a:	7119                	addi	sp,sp,-128
 75c:	fc86                	sd	ra,120(sp)
 75e:	f8a2                	sd	s0,112(sp)
 760:	f4a6                	sd	s1,104(sp)
 762:	f0ca                	sd	s2,96(sp)
 764:	ecce                	sd	s3,88(sp)
 766:	e8d2                	sd	s4,80(sp)
 768:	e4d6                	sd	s5,72(sp)
 76a:	e0da                	sd	s6,64(sp)
 76c:	fc5e                	sd	s7,56(sp)
 76e:	f862                	sd	s8,48(sp)
 770:	f466                	sd	s9,40(sp)
 772:	f06a                	sd	s10,32(sp)
 774:	ec6e                	sd	s11,24(sp)
 776:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 778:	0005c903          	lbu	s2,0(a1)
 77c:	18090f63          	beqz	s2,91a <vprintf+0x1c0>
 780:	8aaa                	mv	s5,a0
 782:	8b32                	mv	s6,a2
 784:	00158493          	addi	s1,a1,1
  state = 0;
 788:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 78a:	02500a13          	li	s4,37
 78e:	4c55                	li	s8,21
 790:	00000c97          	auipc	s9,0x0
 794:	488c8c93          	addi	s9,s9,1160 # c18 <malloc+0x1fa>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 798:	02800d93          	li	s11,40
  putc(fd, 'x');
 79c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79e:	00000b97          	auipc	s7,0x0
 7a2:	4d2b8b93          	addi	s7,s7,1234 # c70 <digits>
 7a6:	a839                	j	7c4 <vprintf+0x6a>
        putc(fd, c);
 7a8:	85ca                	mv	a1,s2
 7aa:	8556                	mv	a0,s5
 7ac:	00000097          	auipc	ra,0x0
 7b0:	ee0080e7          	jalr	-288(ra) # 68c <putc>
 7b4:	a019                	j	7ba <vprintf+0x60>
    } else if(state == '%'){
 7b6:	01498d63          	beq	s3,s4,7d0 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 7ba:	0485                	addi	s1,s1,1
 7bc:	fff4c903          	lbu	s2,-1(s1)
 7c0:	14090d63          	beqz	s2,91a <vprintf+0x1c0>
    if(state == 0){
 7c4:	fe0999e3          	bnez	s3,7b6 <vprintf+0x5c>
      if(c == '%'){
 7c8:	ff4910e3          	bne	s2,s4,7a8 <vprintf+0x4e>
        state = '%';
 7cc:	89d2                	mv	s3,s4
 7ce:	b7f5                	j	7ba <vprintf+0x60>
      if(c == 'd'){
 7d0:	11490c63          	beq	s2,s4,8e8 <vprintf+0x18e>
 7d4:	f9d9079b          	addiw	a5,s2,-99
 7d8:	0ff7f793          	zext.b	a5,a5
 7dc:	10fc6e63          	bltu	s8,a5,8f8 <vprintf+0x19e>
 7e0:	f9d9079b          	addiw	a5,s2,-99
 7e4:	0ff7f713          	zext.b	a4,a5
 7e8:	10ec6863          	bltu	s8,a4,8f8 <vprintf+0x19e>
 7ec:	00271793          	slli	a5,a4,0x2
 7f0:	97e6                	add	a5,a5,s9
 7f2:	439c                	lw	a5,0(a5)
 7f4:	97e6                	add	a5,a5,s9
 7f6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 7f8:	008b0913          	addi	s2,s6,8
 7fc:	4685                	li	a3,1
 7fe:	4629                	li	a2,10
 800:	000b2583          	lw	a1,0(s6)
 804:	8556                	mv	a0,s5
 806:	00000097          	auipc	ra,0x0
 80a:	ea8080e7          	jalr	-344(ra) # 6ae <printint>
 80e:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 810:	4981                	li	s3,0
 812:	b765                	j	7ba <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 814:	008b0913          	addi	s2,s6,8
 818:	4681                	li	a3,0
 81a:	4629                	li	a2,10
 81c:	000b2583          	lw	a1,0(s6)
 820:	8556                	mv	a0,s5
 822:	00000097          	auipc	ra,0x0
 826:	e8c080e7          	jalr	-372(ra) # 6ae <printint>
 82a:	8b4a                	mv	s6,s2
      state = 0;
 82c:	4981                	li	s3,0
 82e:	b771                	j	7ba <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 830:	008b0913          	addi	s2,s6,8
 834:	4681                	li	a3,0
 836:	866a                	mv	a2,s10
 838:	000b2583          	lw	a1,0(s6)
 83c:	8556                	mv	a0,s5
 83e:	00000097          	auipc	ra,0x0
 842:	e70080e7          	jalr	-400(ra) # 6ae <printint>
 846:	8b4a                	mv	s6,s2
      state = 0;
 848:	4981                	li	s3,0
 84a:	bf85                	j	7ba <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 84c:	008b0793          	addi	a5,s6,8
 850:	f8f43423          	sd	a5,-120(s0)
 854:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 858:	03000593          	li	a1,48
 85c:	8556                	mv	a0,s5
 85e:	00000097          	auipc	ra,0x0
 862:	e2e080e7          	jalr	-466(ra) # 68c <putc>
  putc(fd, 'x');
 866:	07800593          	li	a1,120
 86a:	8556                	mv	a0,s5
 86c:	00000097          	auipc	ra,0x0
 870:	e20080e7          	jalr	-480(ra) # 68c <putc>
 874:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 876:	03c9d793          	srli	a5,s3,0x3c
 87a:	97de                	add	a5,a5,s7
 87c:	0007c583          	lbu	a1,0(a5)
 880:	8556                	mv	a0,s5
 882:	00000097          	auipc	ra,0x0
 886:	e0a080e7          	jalr	-502(ra) # 68c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 88a:	0992                	slli	s3,s3,0x4
 88c:	397d                	addiw	s2,s2,-1
 88e:	fe0914e3          	bnez	s2,876 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 892:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 896:	4981                	li	s3,0
 898:	b70d                	j	7ba <vprintf+0x60>
        s = va_arg(ap, char*);
 89a:	008b0913          	addi	s2,s6,8
 89e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 8a2:	02098163          	beqz	s3,8c4 <vprintf+0x16a>
        while(*s != 0){
 8a6:	0009c583          	lbu	a1,0(s3)
 8aa:	c5ad                	beqz	a1,914 <vprintf+0x1ba>
          putc(fd, *s);
 8ac:	8556                	mv	a0,s5
 8ae:	00000097          	auipc	ra,0x0
 8b2:	dde080e7          	jalr	-546(ra) # 68c <putc>
          s++;
 8b6:	0985                	addi	s3,s3,1
        while(*s != 0){
 8b8:	0009c583          	lbu	a1,0(s3)
 8bc:	f9e5                	bnez	a1,8ac <vprintf+0x152>
        s = va_arg(ap, char*);
 8be:	8b4a                	mv	s6,s2
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	bde5                	j	7ba <vprintf+0x60>
          s = "(null)";
 8c4:	00000997          	auipc	s3,0x0
 8c8:	34c98993          	addi	s3,s3,844 # c10 <malloc+0x1f2>
        while(*s != 0){
 8cc:	85ee                	mv	a1,s11
 8ce:	bff9                	j	8ac <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 8d0:	008b0913          	addi	s2,s6,8
 8d4:	000b4583          	lbu	a1,0(s6)
 8d8:	8556                	mv	a0,s5
 8da:	00000097          	auipc	ra,0x0
 8de:	db2080e7          	jalr	-590(ra) # 68c <putc>
 8e2:	8b4a                	mv	s6,s2
      state = 0;
 8e4:	4981                	li	s3,0
 8e6:	bdd1                	j	7ba <vprintf+0x60>
        putc(fd, c);
 8e8:	85d2                	mv	a1,s4
 8ea:	8556                	mv	a0,s5
 8ec:	00000097          	auipc	ra,0x0
 8f0:	da0080e7          	jalr	-608(ra) # 68c <putc>
      state = 0;
 8f4:	4981                	li	s3,0
 8f6:	b5d1                	j	7ba <vprintf+0x60>
        putc(fd, '%');
 8f8:	85d2                	mv	a1,s4
 8fa:	8556                	mv	a0,s5
 8fc:	00000097          	auipc	ra,0x0
 900:	d90080e7          	jalr	-624(ra) # 68c <putc>
        putc(fd, c);
 904:	85ca                	mv	a1,s2
 906:	8556                	mv	a0,s5
 908:	00000097          	auipc	ra,0x0
 90c:	d84080e7          	jalr	-636(ra) # 68c <putc>
      state = 0;
 910:	4981                	li	s3,0
 912:	b565                	j	7ba <vprintf+0x60>
        s = va_arg(ap, char*);
 914:	8b4a                	mv	s6,s2
      state = 0;
 916:	4981                	li	s3,0
 918:	b54d                	j	7ba <vprintf+0x60>
    }
  }
}
 91a:	70e6                	ld	ra,120(sp)
 91c:	7446                	ld	s0,112(sp)
 91e:	74a6                	ld	s1,104(sp)
 920:	7906                	ld	s2,96(sp)
 922:	69e6                	ld	s3,88(sp)
 924:	6a46                	ld	s4,80(sp)
 926:	6aa6                	ld	s5,72(sp)
 928:	6b06                	ld	s6,64(sp)
 92a:	7be2                	ld	s7,56(sp)
 92c:	7c42                	ld	s8,48(sp)
 92e:	7ca2                	ld	s9,40(sp)
 930:	7d02                	ld	s10,32(sp)
 932:	6de2                	ld	s11,24(sp)
 934:	6109                	addi	sp,sp,128
 936:	8082                	ret

0000000000000938 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 938:	715d                	addi	sp,sp,-80
 93a:	ec06                	sd	ra,24(sp)
 93c:	e822                	sd	s0,16(sp)
 93e:	1000                	addi	s0,sp,32
 940:	e010                	sd	a2,0(s0)
 942:	e414                	sd	a3,8(s0)
 944:	e818                	sd	a4,16(s0)
 946:	ec1c                	sd	a5,24(s0)
 948:	03043023          	sd	a6,32(s0)
 94c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 950:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 954:	8622                	mv	a2,s0
 956:	00000097          	auipc	ra,0x0
 95a:	e04080e7          	jalr	-508(ra) # 75a <vprintf>
}
 95e:	60e2                	ld	ra,24(sp)
 960:	6442                	ld	s0,16(sp)
 962:	6161                	addi	sp,sp,80
 964:	8082                	ret

0000000000000966 <printf>:

void
printf(const char *fmt, ...)
{
 966:	711d                	addi	sp,sp,-96
 968:	ec06                	sd	ra,24(sp)
 96a:	e822                	sd	s0,16(sp)
 96c:	1000                	addi	s0,sp,32
 96e:	e40c                	sd	a1,8(s0)
 970:	e810                	sd	a2,16(s0)
 972:	ec14                	sd	a3,24(s0)
 974:	f018                	sd	a4,32(s0)
 976:	f41c                	sd	a5,40(s0)
 978:	03043823          	sd	a6,48(s0)
 97c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 980:	00840613          	addi	a2,s0,8
 984:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 988:	85aa                	mv	a1,a0
 98a:	4505                	li	a0,1
 98c:	00000097          	auipc	ra,0x0
 990:	dce080e7          	jalr	-562(ra) # 75a <vprintf>
}
 994:	60e2                	ld	ra,24(sp)
 996:	6442                	ld	s0,16(sp)
 998:	6125                	addi	sp,sp,96
 99a:	8082                	ret

000000000000099c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 99c:	1141                	addi	sp,sp,-16
 99e:	e422                	sd	s0,8(sp)
 9a0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9a2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a6:	00000797          	auipc	a5,0x0
 9aa:	2e27b783          	ld	a5,738(a5) # c88 <freep>
 9ae:	a02d                	j	9d8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9b0:	4618                	lw	a4,8(a2)
 9b2:	9f2d                	addw	a4,a4,a1
 9b4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9b8:	6398                	ld	a4,0(a5)
 9ba:	6310                	ld	a2,0(a4)
 9bc:	a83d                	j	9fa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9be:	ff852703          	lw	a4,-8(a0)
 9c2:	9f31                	addw	a4,a4,a2
 9c4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9c6:	ff053683          	ld	a3,-16(a0)
 9ca:	a091                	j	a0e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9cc:	6398                	ld	a4,0(a5)
 9ce:	00e7e463          	bltu	a5,a4,9d6 <free+0x3a>
 9d2:	00e6ea63          	bltu	a3,a4,9e6 <free+0x4a>
{
 9d6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d8:	fed7fae3          	bgeu	a5,a3,9cc <free+0x30>
 9dc:	6398                	ld	a4,0(a5)
 9de:	00e6e463          	bltu	a3,a4,9e6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e2:	fee7eae3          	bltu	a5,a4,9d6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9e6:	ff852583          	lw	a1,-8(a0)
 9ea:	6390                	ld	a2,0(a5)
 9ec:	02059813          	slli	a6,a1,0x20
 9f0:	01c85713          	srli	a4,a6,0x1c
 9f4:	9736                	add	a4,a4,a3
 9f6:	fae60de3          	beq	a2,a4,9b0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9fa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9fe:	4790                	lw	a2,8(a5)
 a00:	02061593          	slli	a1,a2,0x20
 a04:	01c5d713          	srli	a4,a1,0x1c
 a08:	973e                	add	a4,a4,a5
 a0a:	fae68ae3          	beq	a3,a4,9be <free+0x22>
    p->s.ptr = bp->s.ptr;
 a0e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a10:	00000717          	auipc	a4,0x0
 a14:	26f73c23          	sd	a5,632(a4) # c88 <freep>
}
 a18:	6422                	ld	s0,8(sp)
 a1a:	0141                	addi	sp,sp,16
 a1c:	8082                	ret

0000000000000a1e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a1e:	7139                	addi	sp,sp,-64
 a20:	fc06                	sd	ra,56(sp)
 a22:	f822                	sd	s0,48(sp)
 a24:	f426                	sd	s1,40(sp)
 a26:	f04a                	sd	s2,32(sp)
 a28:	ec4e                	sd	s3,24(sp)
 a2a:	e852                	sd	s4,16(sp)
 a2c:	e456                	sd	s5,8(sp)
 a2e:	e05a                	sd	s6,0(sp)
 a30:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a32:	02051493          	slli	s1,a0,0x20
 a36:	9081                	srli	s1,s1,0x20
 a38:	04bd                	addi	s1,s1,15
 a3a:	8091                	srli	s1,s1,0x4
 a3c:	0014899b          	addiw	s3,s1,1
 a40:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a42:	00000517          	auipc	a0,0x0
 a46:	24653503          	ld	a0,582(a0) # c88 <freep>
 a4a:	c515                	beqz	a0,a76 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a4e:	4798                	lw	a4,8(a5)
 a50:	02977f63          	bgeu	a4,s1,a8e <malloc+0x70>
 a54:	8a4e                	mv	s4,s3
 a56:	0009871b          	sext.w	a4,s3
 a5a:	6685                	lui	a3,0x1
 a5c:	00d77363          	bgeu	a4,a3,a62 <malloc+0x44>
 a60:	6a05                	lui	s4,0x1
 a62:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a66:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a6a:	00000917          	auipc	s2,0x0
 a6e:	21e90913          	addi	s2,s2,542 # c88 <freep>
  if(p == (char*)-1)
 a72:	5afd                	li	s5,-1
 a74:	a895                	j	ae8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a76:	00000797          	auipc	a5,0x0
 a7a:	21a78793          	addi	a5,a5,538 # c90 <base>
 a7e:	00000717          	auipc	a4,0x0
 a82:	20f73523          	sd	a5,522(a4) # c88 <freep>
 a86:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a88:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a8c:	b7e1                	j	a54 <malloc+0x36>
      if(p->s.size == nunits)
 a8e:	02e48c63          	beq	s1,a4,ac6 <malloc+0xa8>
        p->s.size -= nunits;
 a92:	4137073b          	subw	a4,a4,s3
 a96:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a98:	02071693          	slli	a3,a4,0x20
 a9c:	01c6d713          	srli	a4,a3,0x1c
 aa0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 aa2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 aa6:	00000717          	auipc	a4,0x0
 aaa:	1ea73123          	sd	a0,482(a4) # c88 <freep>
      return (void*)(p + 1);
 aae:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 ab2:	70e2                	ld	ra,56(sp)
 ab4:	7442                	ld	s0,48(sp)
 ab6:	74a2                	ld	s1,40(sp)
 ab8:	7902                	ld	s2,32(sp)
 aba:	69e2                	ld	s3,24(sp)
 abc:	6a42                	ld	s4,16(sp)
 abe:	6aa2                	ld	s5,8(sp)
 ac0:	6b02                	ld	s6,0(sp)
 ac2:	6121                	addi	sp,sp,64
 ac4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ac6:	6398                	ld	a4,0(a5)
 ac8:	e118                	sd	a4,0(a0)
 aca:	bff1                	j	aa6 <malloc+0x88>
  hp->s.size = nu;
 acc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ad0:	0541                	addi	a0,a0,16
 ad2:	00000097          	auipc	ra,0x0
 ad6:	eca080e7          	jalr	-310(ra) # 99c <free>
  return freep;
 ada:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ade:	d971                	beqz	a0,ab2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ae2:	4798                	lw	a4,8(a5)
 ae4:	fa9775e3          	bgeu	a4,s1,a8e <malloc+0x70>
    if(p == freep)
 ae8:	00093703          	ld	a4,0(s2)
 aec:	853e                	mv	a0,a5
 aee:	fef719e3          	bne	a4,a5,ae0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 af2:	8552                	mv	a0,s4
 af4:	00000097          	auipc	ra,0x0
 af8:	ae0080e7          	jalr	-1312(ra) # 5d4 <sbrk>
  if(p == (char*)-1)
 afc:	fd5518e3          	bne	a0,s5,acc <malloc+0xae>
        return 0;
 b00:	4501                	li	a0,0
 b02:	bf45                	j	ab2 <malloc+0x94>
