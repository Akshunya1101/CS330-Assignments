
user/_primefactors:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	0080                	addi	s0,sp,64
  int pipefd[2], x, y, n, i=0;

  if (argc != 2) {
  10:	4789                	li	a5,2
  12:	02f50063          	beq	a0,a5,32 <main+0x32>
     fprintf(2, "syntax: factors n\nAborting...\n");
  16:	00001597          	auipc	a1,0x1
  1a:	9da58593          	addi	a1,a1,-1574 # 9f0 <malloc+0xea>
  1e:	4509                	li	a0,2
  20:	00001097          	auipc	ra,0x1
  24:	800080e7          	jalr	-2048(ra) # 820 <fprintf>
     exit(0);
  28:	4501                	li	a0,0
  2a:	00000097          	auipc	ra,0x0
  2e:	40a080e7          	jalr	1034(ra) # 434 <exit>
  }
  n = atoi(argv[1]);
  32:	6588                	ld	a0,8(a1)
  34:	00000097          	auipc	ra,0x0
  38:	306080e7          	jalr	774(ra) # 33a <atoi>
  3c:	fca42223          	sw	a0,-60(s0)
  if ((n <= 1) || (n > 100)) {
  40:	3579                	addiw	a0,a0,-2
  42:	06200793          	li	a5,98
  46:	00a7ef63          	bltu	a5,a0,64 <main+0x64>
  4a:	00001997          	auipc	s3,0x1
  4e:	b1698993          	addi	s3,s3,-1258 # b60 <primes>

  while (1) {
     x=0;
     while ((n % primes[i]) == 0) {
        n = n / primes[i];
	fprintf(1, "%d, ", primes[i]);
  52:	00001917          	auipc	s2,0x1
  56:	9de90913          	addi	s2,s2,-1570 # a30 <malloc+0x12a>
	x=1;
     }
     if (x) fprintf(1, "[%d]\n", getpid());
  5a:	00001a17          	auipc	s4,0x1
  5e:	a86a0a13          	addi	s4,s4,-1402 # ae0 <malloc+0x1da>
  62:	a079                	j	f0 <main+0xf0>
     fprintf(2, "Invalid input\nAborting...\n");
  64:	00001597          	auipc	a1,0x1
  68:	9ac58593          	addi	a1,a1,-1620 # a10 <malloc+0x10a>
  6c:	4509                	li	a0,2
  6e:	00000097          	auipc	ra,0x0
  72:	7b2080e7          	jalr	1970(ra) # 820 <fprintf>
     exit(0);
  76:	4501                	li	a0,0
  78:	00000097          	auipc	ra,0x0
  7c:	3bc080e7          	jalr	956(ra) # 434 <exit>
     if (n == 1) break;
  80:	fc442703          	lw	a4,-60(s0)
  84:	4785                	li	a5,1
  86:	10f70e63          	beq	a4,a5,1a2 <main+0x1a2>
     i++;
     if (pipe(pipefd) < 0) {
  8a:	fc840513          	addi	a0,s0,-56
  8e:	00000097          	auipc	ra,0x0
  92:	3b6080e7          	jalr	950(ra) # 444 <pipe>
  96:	0a054163          	bltz	a0,138 <main+0x138>
        fprintf(2, "Error: cannot create pipe\nAborting...\n");
        exit(0);
     }
     if (write(pipefd[1], &n, sizeof(int)) < 0) {
  9a:	4611                	li	a2,4
  9c:	fc440593          	addi	a1,s0,-60
  a0:	fcc42503          	lw	a0,-52(s0)
  a4:	00000097          	auipc	ra,0x0
  a8:	3b0080e7          	jalr	944(ra) # 454 <write>
  ac:	0a054463          	bltz	a0,154 <main+0x154>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
        exit(0);
     }
     close(pipefd[1]);
  b0:	fcc42503          	lw	a0,-52(s0)
  b4:	00000097          	auipc	ra,0x0
  b8:	3a8080e7          	jalr	936(ra) # 45c <close>
     y = fork();
  bc:	00000097          	auipc	ra,0x0
  c0:	370080e7          	jalr	880(ra) # 42c <fork>
     if (y < 0) {
  c4:	0a054663          	bltz	a0,170 <main+0x170>
        fprintf(2, "Error: cannot fork\nAborting...\n");
	exit(0);
     }
     else if (y > 0) {
  c8:	0ca04263          	bgtz	a0,18c <main+0x18c>
	close(pipefd[0]);
        wait(0);
	break;
     }
     else {
        if (read(pipefd[0], &n, sizeof(int)) < 0) {
  cc:	4611                	li	a2,4
  ce:	fc440593          	addi	a1,s0,-60
  d2:	fc842503          	lw	a0,-56(s0)
  d6:	00000097          	auipc	ra,0x0
  da:	376080e7          	jalr	886(ra) # 44c <read>
  de:	0991                	addi	s3,s3,4
  e0:	0c054663          	bltz	a0,1ac <main+0x1ac>
           fprintf(2, "Error: cannot read from pipe\nAborting...\n");
           exit(0);
        }
	close(pipefd[0]);
  e4:	fc842503          	lw	a0,-56(s0)
  e8:	00000097          	auipc	ra,0x0
  ec:	374080e7          	jalr	884(ra) # 45c <close>
     while ((n % primes[i]) == 0) {
  f0:	fc442783          	lw	a5,-60(s0)
  f4:	84ce                	mv	s1,s3
  f6:	0009a603          	lw	a2,0(s3)
  fa:	02c7e73b          	remw	a4,a5,a2
  fe:	f349                	bnez	a4,80 <main+0x80>
        n = n / primes[i];
 100:	02c7c7bb          	divw	a5,a5,a2
 104:	fcf42223          	sw	a5,-60(s0)
	fprintf(1, "%d, ", primes[i]);
 108:	85ca                	mv	a1,s2
 10a:	4505                	li	a0,1
 10c:	00000097          	auipc	ra,0x0
 110:	714080e7          	jalr	1812(ra) # 820 <fprintf>
     while ((n % primes[i]) == 0) {
 114:	fc442783          	lw	a5,-60(s0)
 118:	4090                	lw	a2,0(s1)
 11a:	02c7e73b          	remw	a4,a5,a2
 11e:	d36d                	beqz	a4,100 <main+0x100>
     if (x) fprintf(1, "[%d]\n", getpid());
 120:	00000097          	auipc	ra,0x0
 124:	394080e7          	jalr	916(ra) # 4b4 <getpid>
 128:	862a                	mv	a2,a0
 12a:	85d2                	mv	a1,s4
 12c:	4505                	li	a0,1
 12e:	00000097          	auipc	ra,0x0
 132:	6f2080e7          	jalr	1778(ra) # 820 <fprintf>
 136:	b7a9                	j	80 <main+0x80>
        fprintf(2, "Error: cannot create pipe\nAborting...\n");
 138:	00001597          	auipc	a1,0x1
 13c:	90058593          	addi	a1,a1,-1792 # a38 <malloc+0x132>
 140:	4509                	li	a0,2
 142:	00000097          	auipc	ra,0x0
 146:	6de080e7          	jalr	1758(ra) # 820 <fprintf>
        exit(0);
 14a:	4501                	li	a0,0
 14c:	00000097          	auipc	ra,0x0
 150:	2e8080e7          	jalr	744(ra) # 434 <exit>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 154:	00001597          	auipc	a1,0x1
 158:	90c58593          	addi	a1,a1,-1780 # a60 <malloc+0x15a>
 15c:	4509                	li	a0,2
 15e:	00000097          	auipc	ra,0x0
 162:	6c2080e7          	jalr	1730(ra) # 820 <fprintf>
        exit(0);
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	2cc080e7          	jalr	716(ra) # 434 <exit>
        fprintf(2, "Error: cannot fork\nAborting...\n");
 170:	00001597          	auipc	a1,0x1
 174:	92058593          	addi	a1,a1,-1760 # a90 <malloc+0x18a>
 178:	4509                	li	a0,2
 17a:	00000097          	auipc	ra,0x0
 17e:	6a6080e7          	jalr	1702(ra) # 820 <fprintf>
	exit(0);
 182:	4501                	li	a0,0
 184:	00000097          	auipc	ra,0x0
 188:	2b0080e7          	jalr	688(ra) # 434 <exit>
	close(pipefd[0]);
 18c:	fc842503          	lw	a0,-56(s0)
 190:	00000097          	auipc	ra,0x0
 194:	2cc080e7          	jalr	716(ra) # 45c <close>
        wait(0);
 198:	4501                	li	a0,0
 19a:	00000097          	auipc	ra,0x0
 19e:	2a2080e7          	jalr	674(ra) # 43c <wait>
     }
  }

  exit(0);
 1a2:	4501                	li	a0,0
 1a4:	00000097          	auipc	ra,0x0
 1a8:	290080e7          	jalr	656(ra) # 434 <exit>
           fprintf(2, "Error: cannot read from pipe\nAborting...\n");
 1ac:	00001597          	auipc	a1,0x1
 1b0:	90458593          	addi	a1,a1,-1788 # ab0 <malloc+0x1aa>
 1b4:	4509                	li	a0,2
 1b6:	00000097          	auipc	ra,0x0
 1ba:	66a080e7          	jalr	1642(ra) # 820 <fprintf>
           exit(0);
 1be:	4501                	li	a0,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	274080e7          	jalr	628(ra) # 434 <exit>

00000000000001c8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ce:	87aa                	mv	a5,a0
 1d0:	0585                	addi	a1,a1,1
 1d2:	0785                	addi	a5,a5,1
 1d4:	fff5c703          	lbu	a4,-1(a1)
 1d8:	fee78fa3          	sb	a4,-1(a5)
 1dc:	fb75                	bnez	a4,1d0 <strcpy+0x8>
    ;
  return os;
}
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret

00000000000001e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1ea:	00054783          	lbu	a5,0(a0)
 1ee:	cb91                	beqz	a5,202 <strcmp+0x1e>
 1f0:	0005c703          	lbu	a4,0(a1)
 1f4:	00f71763          	bne	a4,a5,202 <strcmp+0x1e>
    p++, q++;
 1f8:	0505                	addi	a0,a0,1
 1fa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1fc:	00054783          	lbu	a5,0(a0)
 200:	fbe5                	bnez	a5,1f0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 202:	0005c503          	lbu	a0,0(a1)
}
 206:	40a7853b          	subw	a0,a5,a0
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret

0000000000000210 <strlen>:

uint
strlen(const char *s)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cf91                	beqz	a5,236 <strlen+0x26>
 21c:	0505                	addi	a0,a0,1
 21e:	87aa                	mv	a5,a0
 220:	4685                	li	a3,1
 222:	9e89                	subw	a3,a3,a0
 224:	00f6853b          	addw	a0,a3,a5
 228:	0785                	addi	a5,a5,1
 22a:	fff7c703          	lbu	a4,-1(a5)
 22e:	fb7d                	bnez	a4,224 <strlen+0x14>
    ;
  return n;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
  for(n = 0; s[n]; n++)
 236:	4501                	li	a0,0
 238:	bfe5                	j	230 <strlen+0x20>

000000000000023a <memset>:

void*
memset(void *dst, int c, uint n)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 240:	ca19                	beqz	a2,256 <memset+0x1c>
 242:	87aa                	mv	a5,a0
 244:	1602                	slli	a2,a2,0x20
 246:	9201                	srli	a2,a2,0x20
 248:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 24c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 250:	0785                	addi	a5,a5,1
 252:	fee79de3          	bne	a5,a4,24c <memset+0x12>
  }
  return dst;
}
 256:	6422                	ld	s0,8(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret

000000000000025c <strchr>:

char*
strchr(const char *s, char c)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  for(; *s; s++)
 262:	00054783          	lbu	a5,0(a0)
 266:	cb99                	beqz	a5,27c <strchr+0x20>
    if(*s == c)
 268:	00f58763          	beq	a1,a5,276 <strchr+0x1a>
  for(; *s; s++)
 26c:	0505                	addi	a0,a0,1
 26e:	00054783          	lbu	a5,0(a0)
 272:	fbfd                	bnez	a5,268 <strchr+0xc>
      return (char*)s;
  return 0;
 274:	4501                	li	a0,0
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret
  return 0;
 27c:	4501                	li	a0,0
 27e:	bfe5                	j	276 <strchr+0x1a>

0000000000000280 <gets>:

char*
gets(char *buf, int max)
{
 280:	711d                	addi	sp,sp,-96
 282:	ec86                	sd	ra,88(sp)
 284:	e8a2                	sd	s0,80(sp)
 286:	e4a6                	sd	s1,72(sp)
 288:	e0ca                	sd	s2,64(sp)
 28a:	fc4e                	sd	s3,56(sp)
 28c:	f852                	sd	s4,48(sp)
 28e:	f456                	sd	s5,40(sp)
 290:	f05a                	sd	s6,32(sp)
 292:	ec5e                	sd	s7,24(sp)
 294:	1080                	addi	s0,sp,96
 296:	8baa                	mv	s7,a0
 298:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 29a:	892a                	mv	s2,a0
 29c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 29e:	4aa9                	li	s5,10
 2a0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2a2:	89a6                	mv	s3,s1
 2a4:	2485                	addiw	s1,s1,1
 2a6:	0344d863          	bge	s1,s4,2d6 <gets+0x56>
    cc = read(0, &c, 1);
 2aa:	4605                	li	a2,1
 2ac:	faf40593          	addi	a1,s0,-81
 2b0:	4501                	li	a0,0
 2b2:	00000097          	auipc	ra,0x0
 2b6:	19a080e7          	jalr	410(ra) # 44c <read>
    if(cc < 1)
 2ba:	00a05e63          	blez	a0,2d6 <gets+0x56>
    buf[i++] = c;
 2be:	faf44783          	lbu	a5,-81(s0)
 2c2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2c6:	01578763          	beq	a5,s5,2d4 <gets+0x54>
 2ca:	0905                	addi	s2,s2,1
 2cc:	fd679be3          	bne	a5,s6,2a2 <gets+0x22>
  for(i=0; i+1 < max; ){
 2d0:	89a6                	mv	s3,s1
 2d2:	a011                	j	2d6 <gets+0x56>
 2d4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2d6:	99de                	add	s3,s3,s7
 2d8:	00098023          	sb	zero,0(s3)
  return buf;
}
 2dc:	855e                	mv	a0,s7
 2de:	60e6                	ld	ra,88(sp)
 2e0:	6446                	ld	s0,80(sp)
 2e2:	64a6                	ld	s1,72(sp)
 2e4:	6906                	ld	s2,64(sp)
 2e6:	79e2                	ld	s3,56(sp)
 2e8:	7a42                	ld	s4,48(sp)
 2ea:	7aa2                	ld	s5,40(sp)
 2ec:	7b02                	ld	s6,32(sp)
 2ee:	6be2                	ld	s7,24(sp)
 2f0:	6125                	addi	sp,sp,96
 2f2:	8082                	ret

00000000000002f4 <stat>:

int
stat(const char *n, struct stat *st)
{
 2f4:	1101                	addi	sp,sp,-32
 2f6:	ec06                	sd	ra,24(sp)
 2f8:	e822                	sd	s0,16(sp)
 2fa:	e426                	sd	s1,8(sp)
 2fc:	e04a                	sd	s2,0(sp)
 2fe:	1000                	addi	s0,sp,32
 300:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 302:	4581                	li	a1,0
 304:	00000097          	auipc	ra,0x0
 308:	170080e7          	jalr	368(ra) # 474 <open>
  if(fd < 0)
 30c:	02054563          	bltz	a0,336 <stat+0x42>
 310:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 312:	85ca                	mv	a1,s2
 314:	00000097          	auipc	ra,0x0
 318:	178080e7          	jalr	376(ra) # 48c <fstat>
 31c:	892a                	mv	s2,a0
  close(fd);
 31e:	8526                	mv	a0,s1
 320:	00000097          	auipc	ra,0x0
 324:	13c080e7          	jalr	316(ra) # 45c <close>
  return r;
}
 328:	854a                	mv	a0,s2
 32a:	60e2                	ld	ra,24(sp)
 32c:	6442                	ld	s0,16(sp)
 32e:	64a2                	ld	s1,8(sp)
 330:	6902                	ld	s2,0(sp)
 332:	6105                	addi	sp,sp,32
 334:	8082                	ret
    return -1;
 336:	597d                	li	s2,-1
 338:	bfc5                	j	328 <stat+0x34>

000000000000033a <atoi>:

int
atoi(const char *s)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 340:	00054683          	lbu	a3,0(a0)
 344:	fd06879b          	addiw	a5,a3,-48
 348:	0ff7f793          	zext.b	a5,a5
 34c:	4625                	li	a2,9
 34e:	02f66863          	bltu	a2,a5,37e <atoi+0x44>
 352:	872a                	mv	a4,a0
  n = 0;
 354:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 356:	0705                	addi	a4,a4,1
 358:	0025179b          	slliw	a5,a0,0x2
 35c:	9fa9                	addw	a5,a5,a0
 35e:	0017979b          	slliw	a5,a5,0x1
 362:	9fb5                	addw	a5,a5,a3
 364:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 368:	00074683          	lbu	a3,0(a4)
 36c:	fd06879b          	addiw	a5,a3,-48
 370:	0ff7f793          	zext.b	a5,a5
 374:	fef671e3          	bgeu	a2,a5,356 <atoi+0x1c>
  return n;
}
 378:	6422                	ld	s0,8(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret
  n = 0;
 37e:	4501                	li	a0,0
 380:	bfe5                	j	378 <atoi+0x3e>

0000000000000382 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 382:	1141                	addi	sp,sp,-16
 384:	e422                	sd	s0,8(sp)
 386:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 388:	02b57463          	bgeu	a0,a1,3b0 <memmove+0x2e>
    while(n-- > 0)
 38c:	00c05f63          	blez	a2,3aa <memmove+0x28>
 390:	1602                	slli	a2,a2,0x20
 392:	9201                	srli	a2,a2,0x20
 394:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 398:	872a                	mv	a4,a0
      *dst++ = *src++;
 39a:	0585                	addi	a1,a1,1
 39c:	0705                	addi	a4,a4,1
 39e:	fff5c683          	lbu	a3,-1(a1)
 3a2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a6:	fee79ae3          	bne	a5,a4,39a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
    dst += n;
 3b0:	00c50733          	add	a4,a0,a2
    src += n;
 3b4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3b6:	fec05ae3          	blez	a2,3aa <memmove+0x28>
 3ba:	fff6079b          	addiw	a5,a2,-1
 3be:	1782                	slli	a5,a5,0x20
 3c0:	9381                	srli	a5,a5,0x20
 3c2:	fff7c793          	not	a5,a5
 3c6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3c8:	15fd                	addi	a1,a1,-1
 3ca:	177d                	addi	a4,a4,-1
 3cc:	0005c683          	lbu	a3,0(a1)
 3d0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d4:	fee79ae3          	bne	a5,a4,3c8 <memmove+0x46>
 3d8:	bfc9                	j	3aa <memmove+0x28>

00000000000003da <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e422                	sd	s0,8(sp)
 3de:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3e0:	ca05                	beqz	a2,410 <memcmp+0x36>
 3e2:	fff6069b          	addiw	a3,a2,-1
 3e6:	1682                	slli	a3,a3,0x20
 3e8:	9281                	srli	a3,a3,0x20
 3ea:	0685                	addi	a3,a3,1
 3ec:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ee:	00054783          	lbu	a5,0(a0)
 3f2:	0005c703          	lbu	a4,0(a1)
 3f6:	00e79863          	bne	a5,a4,406 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3fa:	0505                	addi	a0,a0,1
    p2++;
 3fc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3fe:	fed518e3          	bne	a0,a3,3ee <memcmp+0x14>
  }
  return 0;
 402:	4501                	li	a0,0
 404:	a019                	j	40a <memcmp+0x30>
      return *p1 - *p2;
 406:	40e7853b          	subw	a0,a5,a4
}
 40a:	6422                	ld	s0,8(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret
  return 0;
 410:	4501                	li	a0,0
 412:	bfe5                	j	40a <memcmp+0x30>

0000000000000414 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 414:	1141                	addi	sp,sp,-16
 416:	e406                	sd	ra,8(sp)
 418:	e022                	sd	s0,0(sp)
 41a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 41c:	00000097          	auipc	ra,0x0
 420:	f66080e7          	jalr	-154(ra) # 382 <memmove>
}
 424:	60a2                	ld	ra,8(sp)
 426:	6402                	ld	s0,0(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret

000000000000042c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 42c:	4885                	li	a7,1
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <exit>:
.global exit
exit:
 li a7, SYS_exit
 434:	4889                	li	a7,2
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <wait>:
.global wait
wait:
 li a7, SYS_wait
 43c:	488d                	li	a7,3
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 444:	4891                	li	a7,4
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <read>:
.global read
read:
 li a7, SYS_read
 44c:	4895                	li	a7,5
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <write>:
.global write
write:
 li a7, SYS_write
 454:	48c1                	li	a7,16
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <close>:
.global close
close:
 li a7, SYS_close
 45c:	48d5                	li	a7,21
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <kill>:
.global kill
kill:
 li a7, SYS_kill
 464:	4899                	li	a7,6
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <exec>:
.global exec
exec:
 li a7, SYS_exec
 46c:	489d                	li	a7,7
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <open>:
.global open
open:
 li a7, SYS_open
 474:	48bd                	li	a7,15
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 47c:	48c5                	li	a7,17
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 484:	48c9                	li	a7,18
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 48c:	48a1                	li	a7,8
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <link>:
.global link
link:
 li a7, SYS_link
 494:	48cd                	li	a7,19
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 49c:	48d1                	li	a7,20
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a4:	48a5                	li	a7,9
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ac:	48a9                	li	a7,10
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b4:	48ad                	li	a7,11
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4bc:	48b1                	li	a7,12
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4c4:	48b5                	li	a7,13
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4cc:	48b9                	li	a7,14
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4d4:	48d9                	li	a7,22
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <yield>:
.global yield
yield:
 li a7, SYS_yield
 4dc:	48dd                	li	a7,23
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 4e4:	48e1                	li	a7,24
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 4ec:	48e5                	li	a7,25
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 4f4:	48e9                	li	a7,26
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <ps>:
.global ps
ps:
 li a7, SYS_ps
 4fc:	48ed                	li	a7,27
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 504:	48f1                	li	a7,28
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 50c:	48f5                	li	a7,29
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 514:	48f9                	li	a7,30
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 51c:	02100893          	li	a7,33
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 526:	48fd                	li	a7,31
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 52e:	02000893          	li	a7,32
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 538:	02200893          	li	a7,34
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 542:	02300893          	li	a7,35
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 54c:	02400893          	li	a7,36
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 556:	02500893          	li	a7,37
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 560:	02700893          	li	a7,39
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 56a:	02600893          	li	a7,38
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 574:	1101                	addi	sp,sp,-32
 576:	ec06                	sd	ra,24(sp)
 578:	e822                	sd	s0,16(sp)
 57a:	1000                	addi	s0,sp,32
 57c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 580:	4605                	li	a2,1
 582:	fef40593          	addi	a1,s0,-17
 586:	00000097          	auipc	ra,0x0
 58a:	ece080e7          	jalr	-306(ra) # 454 <write>
}
 58e:	60e2                	ld	ra,24(sp)
 590:	6442                	ld	s0,16(sp)
 592:	6105                	addi	sp,sp,32
 594:	8082                	ret

0000000000000596 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 596:	7139                	addi	sp,sp,-64
 598:	fc06                	sd	ra,56(sp)
 59a:	f822                	sd	s0,48(sp)
 59c:	f426                	sd	s1,40(sp)
 59e:	f04a                	sd	s2,32(sp)
 5a0:	ec4e                	sd	s3,24(sp)
 5a2:	0080                	addi	s0,sp,64
 5a4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5a6:	c299                	beqz	a3,5ac <printint+0x16>
 5a8:	0805c963          	bltz	a1,63a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ac:	2581                	sext.w	a1,a1
  neg = 0;
 5ae:	4881                	li	a7,0
 5b0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5b4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5b6:	2601                	sext.w	a2,a2
 5b8:	00000517          	auipc	a0,0x0
 5bc:	59050513          	addi	a0,a0,1424 # b48 <digits>
 5c0:	883a                	mv	a6,a4
 5c2:	2705                	addiw	a4,a4,1
 5c4:	02c5f7bb          	remuw	a5,a1,a2
 5c8:	1782                	slli	a5,a5,0x20
 5ca:	9381                	srli	a5,a5,0x20
 5cc:	97aa                	add	a5,a5,a0
 5ce:	0007c783          	lbu	a5,0(a5)
 5d2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5d6:	0005879b          	sext.w	a5,a1
 5da:	02c5d5bb          	divuw	a1,a1,a2
 5de:	0685                	addi	a3,a3,1
 5e0:	fec7f0e3          	bgeu	a5,a2,5c0 <printint+0x2a>
  if(neg)
 5e4:	00088c63          	beqz	a7,5fc <printint+0x66>
    buf[i++] = '-';
 5e8:	fd070793          	addi	a5,a4,-48
 5ec:	00878733          	add	a4,a5,s0
 5f0:	02d00793          	li	a5,45
 5f4:	fef70823          	sb	a5,-16(a4)
 5f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5fc:	02e05863          	blez	a4,62c <printint+0x96>
 600:	fc040793          	addi	a5,s0,-64
 604:	00e78933          	add	s2,a5,a4
 608:	fff78993          	addi	s3,a5,-1
 60c:	99ba                	add	s3,s3,a4
 60e:	377d                	addiw	a4,a4,-1
 610:	1702                	slli	a4,a4,0x20
 612:	9301                	srli	a4,a4,0x20
 614:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 618:	fff94583          	lbu	a1,-1(s2)
 61c:	8526                	mv	a0,s1
 61e:	00000097          	auipc	ra,0x0
 622:	f56080e7          	jalr	-170(ra) # 574 <putc>
  while(--i >= 0)
 626:	197d                	addi	s2,s2,-1
 628:	ff3918e3          	bne	s2,s3,618 <printint+0x82>
}
 62c:	70e2                	ld	ra,56(sp)
 62e:	7442                	ld	s0,48(sp)
 630:	74a2                	ld	s1,40(sp)
 632:	7902                	ld	s2,32(sp)
 634:	69e2                	ld	s3,24(sp)
 636:	6121                	addi	sp,sp,64
 638:	8082                	ret
    x = -xx;
 63a:	40b005bb          	negw	a1,a1
    neg = 1;
 63e:	4885                	li	a7,1
    x = -xx;
 640:	bf85                	j	5b0 <printint+0x1a>

0000000000000642 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 642:	7119                	addi	sp,sp,-128
 644:	fc86                	sd	ra,120(sp)
 646:	f8a2                	sd	s0,112(sp)
 648:	f4a6                	sd	s1,104(sp)
 64a:	f0ca                	sd	s2,96(sp)
 64c:	ecce                	sd	s3,88(sp)
 64e:	e8d2                	sd	s4,80(sp)
 650:	e4d6                	sd	s5,72(sp)
 652:	e0da                	sd	s6,64(sp)
 654:	fc5e                	sd	s7,56(sp)
 656:	f862                	sd	s8,48(sp)
 658:	f466                	sd	s9,40(sp)
 65a:	f06a                	sd	s10,32(sp)
 65c:	ec6e                	sd	s11,24(sp)
 65e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 660:	0005c903          	lbu	s2,0(a1)
 664:	18090f63          	beqz	s2,802 <vprintf+0x1c0>
 668:	8aaa                	mv	s5,a0
 66a:	8b32                	mv	s6,a2
 66c:	00158493          	addi	s1,a1,1
  state = 0;
 670:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 672:	02500a13          	li	s4,37
 676:	4c55                	li	s8,21
 678:	00000c97          	auipc	s9,0x0
 67c:	478c8c93          	addi	s9,s9,1144 # af0 <malloc+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 680:	02800d93          	li	s11,40
  putc(fd, 'x');
 684:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 686:	00000b97          	auipc	s7,0x0
 68a:	4c2b8b93          	addi	s7,s7,1218 # b48 <digits>
 68e:	a839                	j	6ac <vprintf+0x6a>
        putc(fd, c);
 690:	85ca                	mv	a1,s2
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	ee0080e7          	jalr	-288(ra) # 574 <putc>
 69c:	a019                	j	6a2 <vprintf+0x60>
    } else if(state == '%'){
 69e:	01498d63          	beq	s3,s4,6b8 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 6a2:	0485                	addi	s1,s1,1
 6a4:	fff4c903          	lbu	s2,-1(s1)
 6a8:	14090d63          	beqz	s2,802 <vprintf+0x1c0>
    if(state == 0){
 6ac:	fe0999e3          	bnez	s3,69e <vprintf+0x5c>
      if(c == '%'){
 6b0:	ff4910e3          	bne	s2,s4,690 <vprintf+0x4e>
        state = '%';
 6b4:	89d2                	mv	s3,s4
 6b6:	b7f5                	j	6a2 <vprintf+0x60>
      if(c == 'd'){
 6b8:	11490c63          	beq	s2,s4,7d0 <vprintf+0x18e>
 6bc:	f9d9079b          	addiw	a5,s2,-99
 6c0:	0ff7f793          	zext.b	a5,a5
 6c4:	10fc6e63          	bltu	s8,a5,7e0 <vprintf+0x19e>
 6c8:	f9d9079b          	addiw	a5,s2,-99
 6cc:	0ff7f713          	zext.b	a4,a5
 6d0:	10ec6863          	bltu	s8,a4,7e0 <vprintf+0x19e>
 6d4:	00271793          	slli	a5,a4,0x2
 6d8:	97e6                	add	a5,a5,s9
 6da:	439c                	lw	a5,0(a5)
 6dc:	97e6                	add	a5,a5,s9
 6de:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6e0:	008b0913          	addi	s2,s6,8
 6e4:	4685                	li	a3,1
 6e6:	4629                	li	a2,10
 6e8:	000b2583          	lw	a1,0(s6)
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	ea8080e7          	jalr	-344(ra) # 596 <printint>
 6f6:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b765                	j	6a2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fc:	008b0913          	addi	s2,s6,8
 700:	4681                	li	a3,0
 702:	4629                	li	a2,10
 704:	000b2583          	lw	a1,0(s6)
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	e8c080e7          	jalr	-372(ra) # 596 <printint>
 712:	8b4a                	mv	s6,s2
      state = 0;
 714:	4981                	li	s3,0
 716:	b771                	j	6a2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 718:	008b0913          	addi	s2,s6,8
 71c:	4681                	li	a3,0
 71e:	866a                	mv	a2,s10
 720:	000b2583          	lw	a1,0(s6)
 724:	8556                	mv	a0,s5
 726:	00000097          	auipc	ra,0x0
 72a:	e70080e7          	jalr	-400(ra) # 596 <printint>
 72e:	8b4a                	mv	s6,s2
      state = 0;
 730:	4981                	li	s3,0
 732:	bf85                	j	6a2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 734:	008b0793          	addi	a5,s6,8
 738:	f8f43423          	sd	a5,-120(s0)
 73c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 740:	03000593          	li	a1,48
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	e2e080e7          	jalr	-466(ra) # 574 <putc>
  putc(fd, 'x');
 74e:	07800593          	li	a1,120
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	e20080e7          	jalr	-480(ra) # 574 <putc>
 75c:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 75e:	03c9d793          	srli	a5,s3,0x3c
 762:	97de                	add	a5,a5,s7
 764:	0007c583          	lbu	a1,0(a5)
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	e0a080e7          	jalr	-502(ra) # 574 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 772:	0992                	slli	s3,s3,0x4
 774:	397d                	addiw	s2,s2,-1
 776:	fe0914e3          	bnez	s2,75e <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 77a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 77e:	4981                	li	s3,0
 780:	b70d                	j	6a2 <vprintf+0x60>
        s = va_arg(ap, char*);
 782:	008b0913          	addi	s2,s6,8
 786:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 78a:	02098163          	beqz	s3,7ac <vprintf+0x16a>
        while(*s != 0){
 78e:	0009c583          	lbu	a1,0(s3)
 792:	c5ad                	beqz	a1,7fc <vprintf+0x1ba>
          putc(fd, *s);
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	dde080e7          	jalr	-546(ra) # 574 <putc>
          s++;
 79e:	0985                	addi	s3,s3,1
        while(*s != 0){
 7a0:	0009c583          	lbu	a1,0(s3)
 7a4:	f9e5                	bnez	a1,794 <vprintf+0x152>
        s = va_arg(ap, char*);
 7a6:	8b4a                	mv	s6,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bde5                	j	6a2 <vprintf+0x60>
          s = "(null)";
 7ac:	00000997          	auipc	s3,0x0
 7b0:	33c98993          	addi	s3,s3,828 # ae8 <malloc+0x1e2>
        while(*s != 0){
 7b4:	85ee                	mv	a1,s11
 7b6:	bff9                	j	794 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7b8:	008b0913          	addi	s2,s6,8
 7bc:	000b4583          	lbu	a1,0(s6)
 7c0:	8556                	mv	a0,s5
 7c2:	00000097          	auipc	ra,0x0
 7c6:	db2080e7          	jalr	-590(ra) # 574 <putc>
 7ca:	8b4a                	mv	s6,s2
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	bdd1                	j	6a2 <vprintf+0x60>
        putc(fd, c);
 7d0:	85d2                	mv	a1,s4
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	da0080e7          	jalr	-608(ra) # 574 <putc>
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	b5d1                	j	6a2 <vprintf+0x60>
        putc(fd, '%');
 7e0:	85d2                	mv	a1,s4
 7e2:	8556                	mv	a0,s5
 7e4:	00000097          	auipc	ra,0x0
 7e8:	d90080e7          	jalr	-624(ra) # 574 <putc>
        putc(fd, c);
 7ec:	85ca                	mv	a1,s2
 7ee:	8556                	mv	a0,s5
 7f0:	00000097          	auipc	ra,0x0
 7f4:	d84080e7          	jalr	-636(ra) # 574 <putc>
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	b565                	j	6a2 <vprintf+0x60>
        s = va_arg(ap, char*);
 7fc:	8b4a                	mv	s6,s2
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b54d                	j	6a2 <vprintf+0x60>
    }
  }
}
 802:	70e6                	ld	ra,120(sp)
 804:	7446                	ld	s0,112(sp)
 806:	74a6                	ld	s1,104(sp)
 808:	7906                	ld	s2,96(sp)
 80a:	69e6                	ld	s3,88(sp)
 80c:	6a46                	ld	s4,80(sp)
 80e:	6aa6                	ld	s5,72(sp)
 810:	6b06                	ld	s6,64(sp)
 812:	7be2                	ld	s7,56(sp)
 814:	7c42                	ld	s8,48(sp)
 816:	7ca2                	ld	s9,40(sp)
 818:	7d02                	ld	s10,32(sp)
 81a:	6de2                	ld	s11,24(sp)
 81c:	6109                	addi	sp,sp,128
 81e:	8082                	ret

0000000000000820 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 820:	715d                	addi	sp,sp,-80
 822:	ec06                	sd	ra,24(sp)
 824:	e822                	sd	s0,16(sp)
 826:	1000                	addi	s0,sp,32
 828:	e010                	sd	a2,0(s0)
 82a:	e414                	sd	a3,8(s0)
 82c:	e818                	sd	a4,16(s0)
 82e:	ec1c                	sd	a5,24(s0)
 830:	03043023          	sd	a6,32(s0)
 834:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 838:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83c:	8622                	mv	a2,s0
 83e:	00000097          	auipc	ra,0x0
 842:	e04080e7          	jalr	-508(ra) # 642 <vprintf>
}
 846:	60e2                	ld	ra,24(sp)
 848:	6442                	ld	s0,16(sp)
 84a:	6161                	addi	sp,sp,80
 84c:	8082                	ret

000000000000084e <printf>:

void
printf(const char *fmt, ...)
{
 84e:	711d                	addi	sp,sp,-96
 850:	ec06                	sd	ra,24(sp)
 852:	e822                	sd	s0,16(sp)
 854:	1000                	addi	s0,sp,32
 856:	e40c                	sd	a1,8(s0)
 858:	e810                	sd	a2,16(s0)
 85a:	ec14                	sd	a3,24(s0)
 85c:	f018                	sd	a4,32(s0)
 85e:	f41c                	sd	a5,40(s0)
 860:	03043823          	sd	a6,48(s0)
 864:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 868:	00840613          	addi	a2,s0,8
 86c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 870:	85aa                	mv	a1,a0
 872:	4505                	li	a0,1
 874:	00000097          	auipc	ra,0x0
 878:	dce080e7          	jalr	-562(ra) # 642 <vprintf>
}
 87c:	60e2                	ld	ra,24(sp)
 87e:	6442                	ld	s0,16(sp)
 880:	6125                	addi	sp,sp,96
 882:	8082                	ret

0000000000000884 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 884:	1141                	addi	sp,sp,-16
 886:	e422                	sd	s0,8(sp)
 888:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88e:	00000797          	auipc	a5,0x0
 892:	33a7b783          	ld	a5,826(a5) # bc8 <freep>
 896:	a02d                	j	8c0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 898:	4618                	lw	a4,8(a2)
 89a:	9f2d                	addw	a4,a4,a1
 89c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a0:	6398                	ld	a4,0(a5)
 8a2:	6310                	ld	a2,0(a4)
 8a4:	a83d                	j	8e2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a6:	ff852703          	lw	a4,-8(a0)
 8aa:	9f31                	addw	a4,a4,a2
 8ac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ae:	ff053683          	ld	a3,-16(a0)
 8b2:	a091                	j	8f6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b4:	6398                	ld	a4,0(a5)
 8b6:	00e7e463          	bltu	a5,a4,8be <free+0x3a>
 8ba:	00e6ea63          	bltu	a3,a4,8ce <free+0x4a>
{
 8be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c0:	fed7fae3          	bgeu	a5,a3,8b4 <free+0x30>
 8c4:	6398                	ld	a4,0(a5)
 8c6:	00e6e463          	bltu	a3,a4,8ce <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ca:	fee7eae3          	bltu	a5,a4,8be <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ce:	ff852583          	lw	a1,-8(a0)
 8d2:	6390                	ld	a2,0(a5)
 8d4:	02059813          	slli	a6,a1,0x20
 8d8:	01c85713          	srli	a4,a6,0x1c
 8dc:	9736                	add	a4,a4,a3
 8de:	fae60de3          	beq	a2,a4,898 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e6:	4790                	lw	a2,8(a5)
 8e8:	02061593          	slli	a1,a2,0x20
 8ec:	01c5d713          	srli	a4,a1,0x1c
 8f0:	973e                	add	a4,a4,a5
 8f2:	fae68ae3          	beq	a3,a4,8a6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8f6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8f8:	00000717          	auipc	a4,0x0
 8fc:	2cf73823          	sd	a5,720(a4) # bc8 <freep>
}
 900:	6422                	ld	s0,8(sp)
 902:	0141                	addi	sp,sp,16
 904:	8082                	ret

0000000000000906 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 906:	7139                	addi	sp,sp,-64
 908:	fc06                	sd	ra,56(sp)
 90a:	f822                	sd	s0,48(sp)
 90c:	f426                	sd	s1,40(sp)
 90e:	f04a                	sd	s2,32(sp)
 910:	ec4e                	sd	s3,24(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
 918:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91a:	02051493          	slli	s1,a0,0x20
 91e:	9081                	srli	s1,s1,0x20
 920:	04bd                	addi	s1,s1,15
 922:	8091                	srli	s1,s1,0x4
 924:	0014899b          	addiw	s3,s1,1
 928:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 92a:	00000517          	auipc	a0,0x0
 92e:	29e53503          	ld	a0,670(a0) # bc8 <freep>
 932:	c515                	beqz	a0,95e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 936:	4798                	lw	a4,8(a5)
 938:	02977f63          	bgeu	a4,s1,976 <malloc+0x70>
 93c:	8a4e                	mv	s4,s3
 93e:	0009871b          	sext.w	a4,s3
 942:	6685                	lui	a3,0x1
 944:	00d77363          	bgeu	a4,a3,94a <malloc+0x44>
 948:	6a05                	lui	s4,0x1
 94a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 94e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 952:	00000917          	auipc	s2,0x0
 956:	27690913          	addi	s2,s2,630 # bc8 <freep>
  if(p == (char*)-1)
 95a:	5afd                	li	s5,-1
 95c:	a895                	j	9d0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 95e:	00000797          	auipc	a5,0x0
 962:	27278793          	addi	a5,a5,626 # bd0 <base>
 966:	00000717          	auipc	a4,0x0
 96a:	26f73123          	sd	a5,610(a4) # bc8 <freep>
 96e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 970:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 974:	b7e1                	j	93c <malloc+0x36>
      if(p->s.size == nunits)
 976:	02e48c63          	beq	s1,a4,9ae <malloc+0xa8>
        p->s.size -= nunits;
 97a:	4137073b          	subw	a4,a4,s3
 97e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 980:	02071693          	slli	a3,a4,0x20
 984:	01c6d713          	srli	a4,a3,0x1c
 988:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98e:	00000717          	auipc	a4,0x0
 992:	22a73d23          	sd	a0,570(a4) # bc8 <freep>
      return (void*)(p + 1);
 996:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 99a:	70e2                	ld	ra,56(sp)
 99c:	7442                	ld	s0,48(sp)
 99e:	74a2                	ld	s1,40(sp)
 9a0:	7902                	ld	s2,32(sp)
 9a2:	69e2                	ld	s3,24(sp)
 9a4:	6a42                	ld	s4,16(sp)
 9a6:	6aa2                	ld	s5,8(sp)
 9a8:	6b02                	ld	s6,0(sp)
 9aa:	6121                	addi	sp,sp,64
 9ac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9ae:	6398                	ld	a4,0(a5)
 9b0:	e118                	sd	a4,0(a0)
 9b2:	bff1                	j	98e <malloc+0x88>
  hp->s.size = nu;
 9b4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b8:	0541                	addi	a0,a0,16
 9ba:	00000097          	auipc	ra,0x0
 9be:	eca080e7          	jalr	-310(ra) # 884 <free>
  return freep;
 9c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9c6:	d971                	beqz	a0,99a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ca:	4798                	lw	a4,8(a5)
 9cc:	fa9775e3          	bgeu	a4,s1,976 <malloc+0x70>
    if(p == freep)
 9d0:	00093703          	ld	a4,0(s2)
 9d4:	853e                	mv	a0,a5
 9d6:	fef719e3          	bne	a4,a5,9c8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9da:	8552                	mv	a0,s4
 9dc:	00000097          	auipc	ra,0x0
 9e0:	ae0080e7          	jalr	-1312(ra) # 4bc <sbrk>
  if(p == (char*)-1)
 9e4:	fd5518e3          	bne	a0,s5,9b4 <malloc+0xae>
        return 0;
 9e8:	4501                	li	a0,0
 9ea:	bf45                	j	99a <malloc+0x94>
