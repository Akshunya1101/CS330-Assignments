
user/_testForkfSleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <f>:
{
   return x*x;
}

int f (void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
   int x = 10;

   fprintf(2, "Hello world! %d\n", g(x));
   8:	06400613          	li	a2,100
   c:	00001597          	auipc	a1,0x1
  10:	97c58593          	addi	a1,a1,-1668 # 988 <malloc+0xe6>
  14:	4509                	li	a0,2
  16:	00000097          	auipc	ra,0x0
  1a:	7a6080e7          	jalr	1958(ra) # 7bc <fprintf>
   return 0;
}
  1e:	4501                	li	a0,0
  20:	60a2                	ld	ra,8(sp)
  22:	6402                	ld	s0,0(sp)
  24:	0141                	addi	sp,sp,16
  26:	8082                	ret

0000000000000028 <g>:
{
  28:	1141                	addi	sp,sp,-16
  2a:	e422                	sd	s0,8(sp)
  2c:	0800                	addi	s0,sp,16
}
  2e:	02a5053b          	mulw	a0,a0,a0
  32:	6422                	ld	s0,8(sp)
  34:	0141                	addi	sp,sp,16
  36:	8082                	ret

0000000000000038 <main>:

int
main(int argc, char *argv[])
{
  38:	1101                	addi	sp,sp,-32
  3a:	ec06                	sd	ra,24(sp)
  3c:	e822                	sd	s0,16(sp)
  3e:	e426                	sd	s1,8(sp)
  40:	e04a                	sd	s2,0(sp)
  42:	1000                	addi	s0,sp,32
  int m, n, x;

  if (argc != 3) {
  44:	478d                	li	a5,3
  46:	02f50063          	beq	a0,a5,66 <main+0x2e>
     fprintf(2, "syntax: testForkfSleep m n\nAborting...\n");
  4a:	00001597          	auipc	a1,0x1
  4e:	95658593          	addi	a1,a1,-1706 # 9a0 <malloc+0xfe>
  52:	4509                	li	a0,2
  54:	00000097          	auipc	ra,0x0
  58:	768080e7          	jalr	1896(ra) # 7bc <fprintf>
     exit(0);
  5c:	4501                	li	a0,0
  5e:	00000097          	auipc	ra,0x0
  62:	372080e7          	jalr	882(ra) # 3d0 <exit>
  66:	84ae                	mv	s1,a1
  }

  m = atoi(argv[1]);
  68:	6588                	ld	a0,8(a1)
  6a:	00000097          	auipc	ra,0x0
  6e:	26c080e7          	jalr	620(ra) # 2d6 <atoi>
  72:	892a                	mv	s2,a0
  if (m <= 0) {
  74:	02a05b63          	blez	a0,aa <main+0x72>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  n = atoi(argv[2]);
  78:	6888                	ld	a0,16(s1)
  7a:	00000097          	auipc	ra,0x0
  7e:	25c080e7          	jalr	604(ra) # 2d6 <atoi>
  82:	84aa                	mv	s1,a0
  if ((n != 0) && (n != 1)) {
  84:	0005071b          	sext.w	a4,a0
  88:	4785                	li	a5,1
  8a:	02e7fe63          	bgeu	a5,a4,c6 <main+0x8e>
     fprintf(2, "Invalid input\nAborting...\n");
  8e:	00001597          	auipc	a1,0x1
  92:	93a58593          	addi	a1,a1,-1734 # 9c8 <malloc+0x126>
  96:	4509                	li	a0,2
  98:	00000097          	auipc	ra,0x0
  9c:	724080e7          	jalr	1828(ra) # 7bc <fprintf>
     exit(0);
  a0:	4501                	li	a0,0
  a2:	00000097          	auipc	ra,0x0
  a6:	32e080e7          	jalr	814(ra) # 3d0 <exit>
     fprintf(2, "Invalid input\nAborting...\n");
  aa:	00001597          	auipc	a1,0x1
  ae:	91e58593          	addi	a1,a1,-1762 # 9c8 <malloc+0x126>
  b2:	4509                	li	a0,2
  b4:	00000097          	auipc	ra,0x0
  b8:	708080e7          	jalr	1800(ra) # 7bc <fprintf>
     exit(0);
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	312080e7          	jalr	786(ra) # 3d0 <exit>
  }

  x = forkf(f);
  c6:	00000517          	auipc	a0,0x0
  ca:	f3a50513          	addi	a0,a0,-198 # 0 <f>
  ce:	00000097          	auipc	ra,0x0
  d2:	3ba080e7          	jalr	954(ra) # 488 <forkf>
  if (x < 0) {
  d6:	02054d63          	bltz	a0,110 <main+0xd8>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  da:	04a05f63          	blez	a0,138 <main+0x100>
     if (n) sleep(m);
  de:	e4b9                	bnez	s1,12c <main+0xf4>
     fprintf(1, "%d: Parent.\n", getpid());
  e0:	00000097          	auipc	ra,0x0
  e4:	370080e7          	jalr	880(ra) # 450 <getpid>
  e8:	862a                	mv	a2,a0
  ea:	00001597          	auipc	a1,0x1
  ee:	91e58593          	addi	a1,a1,-1762 # a08 <malloc+0x166>
  f2:	4505                	li	a0,1
  f4:	00000097          	auipc	ra,0x0
  f8:	6c8080e7          	jalr	1736(ra) # 7bc <fprintf>
     wait(0);
  fc:	4501                	li	a0,0
  fe:	00000097          	auipc	ra,0x0
 102:	2da080e7          	jalr	730(ra) # 3d8 <wait>
  else {
     if (!n) sleep(m);
     fprintf(1, "%d: Child.\n", getpid());
  }

  exit(0);
 106:	4501                	li	a0,0
 108:	00000097          	auipc	ra,0x0
 10c:	2c8080e7          	jalr	712(ra) # 3d0 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
 110:	00001597          	auipc	a1,0x1
 114:	8d858593          	addi	a1,a1,-1832 # 9e8 <malloc+0x146>
 118:	4509                	li	a0,2
 11a:	00000097          	auipc	ra,0x0
 11e:	6a2080e7          	jalr	1698(ra) # 7bc <fprintf>
     exit(0);
 122:	4501                	li	a0,0
 124:	00000097          	auipc	ra,0x0
 128:	2ac080e7          	jalr	684(ra) # 3d0 <exit>
     if (n) sleep(m);
 12c:	854a                	mv	a0,s2
 12e:	00000097          	auipc	ra,0x0
 132:	332080e7          	jalr	818(ra) # 460 <sleep>
 136:	b76d                	j	e0 <main+0xa8>
     if (!n) sleep(m);
 138:	c085                	beqz	s1,158 <main+0x120>
     fprintf(1, "%d: Child.\n", getpid());
 13a:	00000097          	auipc	ra,0x0
 13e:	316080e7          	jalr	790(ra) # 450 <getpid>
 142:	862a                	mv	a2,a0
 144:	00001597          	auipc	a1,0x1
 148:	8d458593          	addi	a1,a1,-1836 # a18 <malloc+0x176>
 14c:	4505                	li	a0,1
 14e:	00000097          	auipc	ra,0x0
 152:	66e080e7          	jalr	1646(ra) # 7bc <fprintf>
 156:	bf45                	j	106 <main+0xce>
     if (!n) sleep(m);
 158:	854a                	mv	a0,s2
 15a:	00000097          	auipc	ra,0x0
 15e:	306080e7          	jalr	774(ra) # 460 <sleep>
 162:	bfe1                	j	13a <main+0x102>

0000000000000164 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 16a:	87aa                	mv	a5,a0
 16c:	0585                	addi	a1,a1,1
 16e:	0785                	addi	a5,a5,1
 170:	fff5c703          	lbu	a4,-1(a1)
 174:	fee78fa3          	sb	a4,-1(a5)
 178:	fb75                	bnez	a4,16c <strcpy+0x8>
    ;
  return os;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cb91                	beqz	a5,19e <strcmp+0x1e>
 18c:	0005c703          	lbu	a4,0(a1)
 190:	00f71763          	bne	a4,a5,19e <strcmp+0x1e>
    p++, q++;
 194:	0505                	addi	a0,a0,1
 196:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 198:	00054783          	lbu	a5,0(a0)
 19c:	fbe5                	bnez	a5,18c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 19e:	0005c503          	lbu	a0,0(a1)
}
 1a2:	40a7853b          	subw	a0,a5,a0
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	addi	sp,sp,16
 1aa:	8082                	ret

00000000000001ac <strlen>:

uint
strlen(const char *s)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cf91                	beqz	a5,1d2 <strlen+0x26>
 1b8:	0505                	addi	a0,a0,1
 1ba:	87aa                	mv	a5,a0
 1bc:	4685                	li	a3,1
 1be:	9e89                	subw	a3,a3,a0
 1c0:	00f6853b          	addw	a0,a3,a5
 1c4:	0785                	addi	a5,a5,1
 1c6:	fff7c703          	lbu	a4,-1(a5)
 1ca:	fb7d                	bnez	a4,1c0 <strlen+0x14>
    ;
  return n;
}
 1cc:	6422                	ld	s0,8(sp)
 1ce:	0141                	addi	sp,sp,16
 1d0:	8082                	ret
  for(n = 0; s[n]; n++)
 1d2:	4501                	li	a0,0
 1d4:	bfe5                	j	1cc <strlen+0x20>

00000000000001d6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1dc:	ca19                	beqz	a2,1f2 <memset+0x1c>
 1de:	87aa                	mv	a5,a0
 1e0:	1602                	slli	a2,a2,0x20
 1e2:	9201                	srli	a2,a2,0x20
 1e4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ec:	0785                	addi	a5,a5,1
 1ee:	fee79de3          	bne	a5,a4,1e8 <memset+0x12>
  }
  return dst;
}
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret

00000000000001f8 <strchr>:

char*
strchr(const char *s, char c)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1fe:	00054783          	lbu	a5,0(a0)
 202:	cb99                	beqz	a5,218 <strchr+0x20>
    if(*s == c)
 204:	00f58763          	beq	a1,a5,212 <strchr+0x1a>
  for(; *s; s++)
 208:	0505                	addi	a0,a0,1
 20a:	00054783          	lbu	a5,0(a0)
 20e:	fbfd                	bnez	a5,204 <strchr+0xc>
      return (char*)s;
  return 0;
 210:	4501                	li	a0,0
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret
  return 0;
 218:	4501                	li	a0,0
 21a:	bfe5                	j	212 <strchr+0x1a>

000000000000021c <gets>:

char*
gets(char *buf, int max)
{
 21c:	711d                	addi	sp,sp,-96
 21e:	ec86                	sd	ra,88(sp)
 220:	e8a2                	sd	s0,80(sp)
 222:	e4a6                	sd	s1,72(sp)
 224:	e0ca                	sd	s2,64(sp)
 226:	fc4e                	sd	s3,56(sp)
 228:	f852                	sd	s4,48(sp)
 22a:	f456                	sd	s5,40(sp)
 22c:	f05a                	sd	s6,32(sp)
 22e:	ec5e                	sd	s7,24(sp)
 230:	1080                	addi	s0,sp,96
 232:	8baa                	mv	s7,a0
 234:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 236:	892a                	mv	s2,a0
 238:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 23a:	4aa9                	li	s5,10
 23c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 23e:	89a6                	mv	s3,s1
 240:	2485                	addiw	s1,s1,1
 242:	0344d863          	bge	s1,s4,272 <gets+0x56>
    cc = read(0, &c, 1);
 246:	4605                	li	a2,1
 248:	faf40593          	addi	a1,s0,-81
 24c:	4501                	li	a0,0
 24e:	00000097          	auipc	ra,0x0
 252:	19a080e7          	jalr	410(ra) # 3e8 <read>
    if(cc < 1)
 256:	00a05e63          	blez	a0,272 <gets+0x56>
    buf[i++] = c;
 25a:	faf44783          	lbu	a5,-81(s0)
 25e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 262:	01578763          	beq	a5,s5,270 <gets+0x54>
 266:	0905                	addi	s2,s2,1
 268:	fd679be3          	bne	a5,s6,23e <gets+0x22>
  for(i=0; i+1 < max; ){
 26c:	89a6                	mv	s3,s1
 26e:	a011                	j	272 <gets+0x56>
 270:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 272:	99de                	add	s3,s3,s7
 274:	00098023          	sb	zero,0(s3)
  return buf;
}
 278:	855e                	mv	a0,s7
 27a:	60e6                	ld	ra,88(sp)
 27c:	6446                	ld	s0,80(sp)
 27e:	64a6                	ld	s1,72(sp)
 280:	6906                	ld	s2,64(sp)
 282:	79e2                	ld	s3,56(sp)
 284:	7a42                	ld	s4,48(sp)
 286:	7aa2                	ld	s5,40(sp)
 288:	7b02                	ld	s6,32(sp)
 28a:	6be2                	ld	s7,24(sp)
 28c:	6125                	addi	sp,sp,96
 28e:	8082                	ret

0000000000000290 <stat>:

int
stat(const char *n, struct stat *st)
{
 290:	1101                	addi	sp,sp,-32
 292:	ec06                	sd	ra,24(sp)
 294:	e822                	sd	s0,16(sp)
 296:	e426                	sd	s1,8(sp)
 298:	e04a                	sd	s2,0(sp)
 29a:	1000                	addi	s0,sp,32
 29c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29e:	4581                	li	a1,0
 2a0:	00000097          	auipc	ra,0x0
 2a4:	170080e7          	jalr	368(ra) # 410 <open>
  if(fd < 0)
 2a8:	02054563          	bltz	a0,2d2 <stat+0x42>
 2ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ae:	85ca                	mv	a1,s2
 2b0:	00000097          	auipc	ra,0x0
 2b4:	178080e7          	jalr	376(ra) # 428 <fstat>
 2b8:	892a                	mv	s2,a0
  close(fd);
 2ba:	8526                	mv	a0,s1
 2bc:	00000097          	auipc	ra,0x0
 2c0:	13c080e7          	jalr	316(ra) # 3f8 <close>
  return r;
}
 2c4:	854a                	mv	a0,s2
 2c6:	60e2                	ld	ra,24(sp)
 2c8:	6442                	ld	s0,16(sp)
 2ca:	64a2                	ld	s1,8(sp)
 2cc:	6902                	ld	s2,0(sp)
 2ce:	6105                	addi	sp,sp,32
 2d0:	8082                	ret
    return -1;
 2d2:	597d                	li	s2,-1
 2d4:	bfc5                	j	2c4 <stat+0x34>

00000000000002d6 <atoi>:

int
atoi(const char *s)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2dc:	00054683          	lbu	a3,0(a0)
 2e0:	fd06879b          	addiw	a5,a3,-48
 2e4:	0ff7f793          	zext.b	a5,a5
 2e8:	4625                	li	a2,9
 2ea:	02f66863          	bltu	a2,a5,31a <atoi+0x44>
 2ee:	872a                	mv	a4,a0
  n = 0;
 2f0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2f2:	0705                	addi	a4,a4,1
 2f4:	0025179b          	slliw	a5,a0,0x2
 2f8:	9fa9                	addw	a5,a5,a0
 2fa:	0017979b          	slliw	a5,a5,0x1
 2fe:	9fb5                	addw	a5,a5,a3
 300:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 304:	00074683          	lbu	a3,0(a4)
 308:	fd06879b          	addiw	a5,a3,-48
 30c:	0ff7f793          	zext.b	a5,a5
 310:	fef671e3          	bgeu	a2,a5,2f2 <atoi+0x1c>
  return n;
}
 314:	6422                	ld	s0,8(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret
  n = 0;
 31a:	4501                	li	a0,0
 31c:	bfe5                	j	314 <atoi+0x3e>

000000000000031e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e422                	sd	s0,8(sp)
 322:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 324:	02b57463          	bgeu	a0,a1,34c <memmove+0x2e>
    while(n-- > 0)
 328:	00c05f63          	blez	a2,346 <memmove+0x28>
 32c:	1602                	slli	a2,a2,0x20
 32e:	9201                	srli	a2,a2,0x20
 330:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 334:	872a                	mv	a4,a0
      *dst++ = *src++;
 336:	0585                	addi	a1,a1,1
 338:	0705                	addi	a4,a4,1
 33a:	fff5c683          	lbu	a3,-1(a1)
 33e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 342:	fee79ae3          	bne	a5,a4,336 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
    dst += n;
 34c:	00c50733          	add	a4,a0,a2
    src += n;
 350:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 352:	fec05ae3          	blez	a2,346 <memmove+0x28>
 356:	fff6079b          	addiw	a5,a2,-1
 35a:	1782                	slli	a5,a5,0x20
 35c:	9381                	srli	a5,a5,0x20
 35e:	fff7c793          	not	a5,a5
 362:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 364:	15fd                	addi	a1,a1,-1
 366:	177d                	addi	a4,a4,-1
 368:	0005c683          	lbu	a3,0(a1)
 36c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 370:	fee79ae3          	bne	a5,a4,364 <memmove+0x46>
 374:	bfc9                	j	346 <memmove+0x28>

0000000000000376 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 376:	1141                	addi	sp,sp,-16
 378:	e422                	sd	s0,8(sp)
 37a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 37c:	ca05                	beqz	a2,3ac <memcmp+0x36>
 37e:	fff6069b          	addiw	a3,a2,-1
 382:	1682                	slli	a3,a3,0x20
 384:	9281                	srli	a3,a3,0x20
 386:	0685                	addi	a3,a3,1
 388:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 38a:	00054783          	lbu	a5,0(a0)
 38e:	0005c703          	lbu	a4,0(a1)
 392:	00e79863          	bne	a5,a4,3a2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 396:	0505                	addi	a0,a0,1
    p2++;
 398:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 39a:	fed518e3          	bne	a0,a3,38a <memcmp+0x14>
  }
  return 0;
 39e:	4501                	li	a0,0
 3a0:	a019                	j	3a6 <memcmp+0x30>
      return *p1 - *p2;
 3a2:	40e7853b          	subw	a0,a5,a4
}
 3a6:	6422                	ld	s0,8(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
  return 0;
 3ac:	4501                	li	a0,0
 3ae:	bfe5                	j	3a6 <memcmp+0x30>

00000000000003b0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e406                	sd	ra,8(sp)
 3b4:	e022                	sd	s0,0(sp)
 3b6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b8:	00000097          	auipc	ra,0x0
 3bc:	f66080e7          	jalr	-154(ra) # 31e <memmove>
}
 3c0:	60a2                	ld	ra,8(sp)
 3c2:	6402                	ld	s0,0(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret

00000000000003c8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c8:	4885                	li	a7,1
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d0:	4889                	li	a7,2
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d8:	488d                	li	a7,3
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e0:	4891                	li	a7,4
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <read>:
.global read
read:
 li a7, SYS_read
 3e8:	4895                	li	a7,5
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <write>:
.global write
write:
 li a7, SYS_write
 3f0:	48c1                	li	a7,16
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <close>:
.global close
close:
 li a7, SYS_close
 3f8:	48d5                	li	a7,21
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <kill>:
.global kill
kill:
 li a7, SYS_kill
 400:	4899                	li	a7,6
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <exec>:
.global exec
exec:
 li a7, SYS_exec
 408:	489d                	li	a7,7
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <open>:
.global open
open:
 li a7, SYS_open
 410:	48bd                	li	a7,15
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 418:	48c5                	li	a7,17
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 420:	48c9                	li	a7,18
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 428:	48a1                	li	a7,8
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <link>:
.global link
link:
 li a7, SYS_link
 430:	48cd                	li	a7,19
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 438:	48d1                	li	a7,20
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 440:	48a5                	li	a7,9
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <dup>:
.global dup
dup:
 li a7, SYS_dup
 448:	48a9                	li	a7,10
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 450:	48ad                	li	a7,11
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 458:	48b1                	li	a7,12
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 460:	48b5                	li	a7,13
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 468:	48b9                	li	a7,14
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 470:	48d9                	li	a7,22
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <yield>:
.global yield
yield:
 li a7, SYS_yield
 478:	48dd                	li	a7,23
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 480:	48e1                	li	a7,24
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 488:	48e5                	li	a7,25
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 490:	48e9                	li	a7,26
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <ps>:
.global ps
ps:
 li a7, SYS_ps
 498:	48ed                	li	a7,27
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 4a0:	48f1                	li	a7,28
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 4a8:	48f5                	li	a7,29
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 4b0:	48f9                	li	a7,30
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 4b8:	02100893          	li	a7,33
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 4c2:	48fd                	li	a7,31
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 4ca:	02000893          	li	a7,32
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 4d4:	02200893          	li	a7,34
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 4de:	02300893          	li	a7,35
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 4e8:	02400893          	li	a7,36
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 4f2:	02500893          	li	a7,37
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 4fc:	02700893          	li	a7,39
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 506:	02600893          	li	a7,38
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 510:	1101                	addi	sp,sp,-32
 512:	ec06                	sd	ra,24(sp)
 514:	e822                	sd	s0,16(sp)
 516:	1000                	addi	s0,sp,32
 518:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 51c:	4605                	li	a2,1
 51e:	fef40593          	addi	a1,s0,-17
 522:	00000097          	auipc	ra,0x0
 526:	ece080e7          	jalr	-306(ra) # 3f0 <write>
}
 52a:	60e2                	ld	ra,24(sp)
 52c:	6442                	ld	s0,16(sp)
 52e:	6105                	addi	sp,sp,32
 530:	8082                	ret

0000000000000532 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 532:	7139                	addi	sp,sp,-64
 534:	fc06                	sd	ra,56(sp)
 536:	f822                	sd	s0,48(sp)
 538:	f426                	sd	s1,40(sp)
 53a:	f04a                	sd	s2,32(sp)
 53c:	ec4e                	sd	s3,24(sp)
 53e:	0080                	addi	s0,sp,64
 540:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 542:	c299                	beqz	a3,548 <printint+0x16>
 544:	0805c963          	bltz	a1,5d6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 548:	2581                	sext.w	a1,a1
  neg = 0;
 54a:	4881                	li	a7,0
 54c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 550:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 552:	2601                	sext.w	a2,a2
 554:	00000517          	auipc	a0,0x0
 558:	53450513          	addi	a0,a0,1332 # a88 <digits>
 55c:	883a                	mv	a6,a4
 55e:	2705                	addiw	a4,a4,1
 560:	02c5f7bb          	remuw	a5,a1,a2
 564:	1782                	slli	a5,a5,0x20
 566:	9381                	srli	a5,a5,0x20
 568:	97aa                	add	a5,a5,a0
 56a:	0007c783          	lbu	a5,0(a5)
 56e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 572:	0005879b          	sext.w	a5,a1
 576:	02c5d5bb          	divuw	a1,a1,a2
 57a:	0685                	addi	a3,a3,1
 57c:	fec7f0e3          	bgeu	a5,a2,55c <printint+0x2a>
  if(neg)
 580:	00088c63          	beqz	a7,598 <printint+0x66>
    buf[i++] = '-';
 584:	fd070793          	addi	a5,a4,-48
 588:	00878733          	add	a4,a5,s0
 58c:	02d00793          	li	a5,45
 590:	fef70823          	sb	a5,-16(a4)
 594:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 598:	02e05863          	blez	a4,5c8 <printint+0x96>
 59c:	fc040793          	addi	a5,s0,-64
 5a0:	00e78933          	add	s2,a5,a4
 5a4:	fff78993          	addi	s3,a5,-1
 5a8:	99ba                	add	s3,s3,a4
 5aa:	377d                	addiw	a4,a4,-1
 5ac:	1702                	slli	a4,a4,0x20
 5ae:	9301                	srli	a4,a4,0x20
 5b0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5b4:	fff94583          	lbu	a1,-1(s2)
 5b8:	8526                	mv	a0,s1
 5ba:	00000097          	auipc	ra,0x0
 5be:	f56080e7          	jalr	-170(ra) # 510 <putc>
  while(--i >= 0)
 5c2:	197d                	addi	s2,s2,-1
 5c4:	ff3918e3          	bne	s2,s3,5b4 <printint+0x82>
}
 5c8:	70e2                	ld	ra,56(sp)
 5ca:	7442                	ld	s0,48(sp)
 5cc:	74a2                	ld	s1,40(sp)
 5ce:	7902                	ld	s2,32(sp)
 5d0:	69e2                	ld	s3,24(sp)
 5d2:	6121                	addi	sp,sp,64
 5d4:	8082                	ret
    x = -xx;
 5d6:	40b005bb          	negw	a1,a1
    neg = 1;
 5da:	4885                	li	a7,1
    x = -xx;
 5dc:	bf85                	j	54c <printint+0x1a>

00000000000005de <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5de:	7119                	addi	sp,sp,-128
 5e0:	fc86                	sd	ra,120(sp)
 5e2:	f8a2                	sd	s0,112(sp)
 5e4:	f4a6                	sd	s1,104(sp)
 5e6:	f0ca                	sd	s2,96(sp)
 5e8:	ecce                	sd	s3,88(sp)
 5ea:	e8d2                	sd	s4,80(sp)
 5ec:	e4d6                	sd	s5,72(sp)
 5ee:	e0da                	sd	s6,64(sp)
 5f0:	fc5e                	sd	s7,56(sp)
 5f2:	f862                	sd	s8,48(sp)
 5f4:	f466                	sd	s9,40(sp)
 5f6:	f06a                	sd	s10,32(sp)
 5f8:	ec6e                	sd	s11,24(sp)
 5fa:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5fc:	0005c903          	lbu	s2,0(a1)
 600:	18090f63          	beqz	s2,79e <vprintf+0x1c0>
 604:	8aaa                	mv	s5,a0
 606:	8b32                	mv	s6,a2
 608:	00158493          	addi	s1,a1,1
  state = 0;
 60c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 60e:	02500a13          	li	s4,37
 612:	4c55                	li	s8,21
 614:	00000c97          	auipc	s9,0x0
 618:	41cc8c93          	addi	s9,s9,1052 # a30 <malloc+0x18e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 61c:	02800d93          	li	s11,40
  putc(fd, 'x');
 620:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 622:	00000b97          	auipc	s7,0x0
 626:	466b8b93          	addi	s7,s7,1126 # a88 <digits>
 62a:	a839                	j	648 <vprintf+0x6a>
        putc(fd, c);
 62c:	85ca                	mv	a1,s2
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	ee0080e7          	jalr	-288(ra) # 510 <putc>
 638:	a019                	j	63e <vprintf+0x60>
    } else if(state == '%'){
 63a:	01498d63          	beq	s3,s4,654 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 63e:	0485                	addi	s1,s1,1
 640:	fff4c903          	lbu	s2,-1(s1)
 644:	14090d63          	beqz	s2,79e <vprintf+0x1c0>
    if(state == 0){
 648:	fe0999e3          	bnez	s3,63a <vprintf+0x5c>
      if(c == '%'){
 64c:	ff4910e3          	bne	s2,s4,62c <vprintf+0x4e>
        state = '%';
 650:	89d2                	mv	s3,s4
 652:	b7f5                	j	63e <vprintf+0x60>
      if(c == 'd'){
 654:	11490c63          	beq	s2,s4,76c <vprintf+0x18e>
 658:	f9d9079b          	addiw	a5,s2,-99
 65c:	0ff7f793          	zext.b	a5,a5
 660:	10fc6e63          	bltu	s8,a5,77c <vprintf+0x19e>
 664:	f9d9079b          	addiw	a5,s2,-99
 668:	0ff7f713          	zext.b	a4,a5
 66c:	10ec6863          	bltu	s8,a4,77c <vprintf+0x19e>
 670:	00271793          	slli	a5,a4,0x2
 674:	97e6                	add	a5,a5,s9
 676:	439c                	lw	a5,0(a5)
 678:	97e6                	add	a5,a5,s9
 67a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 67c:	008b0913          	addi	s2,s6,8
 680:	4685                	li	a3,1
 682:	4629                	li	a2,10
 684:	000b2583          	lw	a1,0(s6)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	ea8080e7          	jalr	-344(ra) # 532 <printint>
 692:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 694:	4981                	li	s3,0
 696:	b765                	j	63e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 698:	008b0913          	addi	s2,s6,8
 69c:	4681                	li	a3,0
 69e:	4629                	li	a2,10
 6a0:	000b2583          	lw	a1,0(s6)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e8c080e7          	jalr	-372(ra) # 532 <printint>
 6ae:	8b4a                	mv	s6,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b771                	j	63e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6b4:	008b0913          	addi	s2,s6,8
 6b8:	4681                	li	a3,0
 6ba:	866a                	mv	a2,s10
 6bc:	000b2583          	lw	a1,0(s6)
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e70080e7          	jalr	-400(ra) # 532 <printint>
 6ca:	8b4a                	mv	s6,s2
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	bf85                	j	63e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6d0:	008b0793          	addi	a5,s6,8
 6d4:	f8f43423          	sd	a5,-120(s0)
 6d8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6dc:	03000593          	li	a1,48
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	e2e080e7          	jalr	-466(ra) # 510 <putc>
  putc(fd, 'x');
 6ea:	07800593          	li	a1,120
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	e20080e7          	jalr	-480(ra) # 510 <putc>
 6f8:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fa:	03c9d793          	srli	a5,s3,0x3c
 6fe:	97de                	add	a5,a5,s7
 700:	0007c583          	lbu	a1,0(a5)
 704:	8556                	mv	a0,s5
 706:	00000097          	auipc	ra,0x0
 70a:	e0a080e7          	jalr	-502(ra) # 510 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70e:	0992                	slli	s3,s3,0x4
 710:	397d                	addiw	s2,s2,-1
 712:	fe0914e3          	bnez	s2,6fa <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 716:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b70d                	j	63e <vprintf+0x60>
        s = va_arg(ap, char*);
 71e:	008b0913          	addi	s2,s6,8
 722:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 726:	02098163          	beqz	s3,748 <vprintf+0x16a>
        while(*s != 0){
 72a:	0009c583          	lbu	a1,0(s3)
 72e:	c5ad                	beqz	a1,798 <vprintf+0x1ba>
          putc(fd, *s);
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	dde080e7          	jalr	-546(ra) # 510 <putc>
          s++;
 73a:	0985                	addi	s3,s3,1
        while(*s != 0){
 73c:	0009c583          	lbu	a1,0(s3)
 740:	f9e5                	bnez	a1,730 <vprintf+0x152>
        s = va_arg(ap, char*);
 742:	8b4a                	mv	s6,s2
      state = 0;
 744:	4981                	li	s3,0
 746:	bde5                	j	63e <vprintf+0x60>
          s = "(null)";
 748:	00000997          	auipc	s3,0x0
 74c:	2e098993          	addi	s3,s3,736 # a28 <malloc+0x186>
        while(*s != 0){
 750:	85ee                	mv	a1,s11
 752:	bff9                	j	730 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 754:	008b0913          	addi	s2,s6,8
 758:	000b4583          	lbu	a1,0(s6)
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	db2080e7          	jalr	-590(ra) # 510 <putc>
 766:	8b4a                	mv	s6,s2
      state = 0;
 768:	4981                	li	s3,0
 76a:	bdd1                	j	63e <vprintf+0x60>
        putc(fd, c);
 76c:	85d2                	mv	a1,s4
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	da0080e7          	jalr	-608(ra) # 510 <putc>
      state = 0;
 778:	4981                	li	s3,0
 77a:	b5d1                	j	63e <vprintf+0x60>
        putc(fd, '%');
 77c:	85d2                	mv	a1,s4
 77e:	8556                	mv	a0,s5
 780:	00000097          	auipc	ra,0x0
 784:	d90080e7          	jalr	-624(ra) # 510 <putc>
        putc(fd, c);
 788:	85ca                	mv	a1,s2
 78a:	8556                	mv	a0,s5
 78c:	00000097          	auipc	ra,0x0
 790:	d84080e7          	jalr	-636(ra) # 510 <putc>
      state = 0;
 794:	4981                	li	s3,0
 796:	b565                	j	63e <vprintf+0x60>
        s = va_arg(ap, char*);
 798:	8b4a                	mv	s6,s2
      state = 0;
 79a:	4981                	li	s3,0
 79c:	b54d                	j	63e <vprintf+0x60>
    }
  }
}
 79e:	70e6                	ld	ra,120(sp)
 7a0:	7446                	ld	s0,112(sp)
 7a2:	74a6                	ld	s1,104(sp)
 7a4:	7906                	ld	s2,96(sp)
 7a6:	69e6                	ld	s3,88(sp)
 7a8:	6a46                	ld	s4,80(sp)
 7aa:	6aa6                	ld	s5,72(sp)
 7ac:	6b06                	ld	s6,64(sp)
 7ae:	7be2                	ld	s7,56(sp)
 7b0:	7c42                	ld	s8,48(sp)
 7b2:	7ca2                	ld	s9,40(sp)
 7b4:	7d02                	ld	s10,32(sp)
 7b6:	6de2                	ld	s11,24(sp)
 7b8:	6109                	addi	sp,sp,128
 7ba:	8082                	ret

00000000000007bc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7bc:	715d                	addi	sp,sp,-80
 7be:	ec06                	sd	ra,24(sp)
 7c0:	e822                	sd	s0,16(sp)
 7c2:	1000                	addi	s0,sp,32
 7c4:	e010                	sd	a2,0(s0)
 7c6:	e414                	sd	a3,8(s0)
 7c8:	e818                	sd	a4,16(s0)
 7ca:	ec1c                	sd	a5,24(s0)
 7cc:	03043023          	sd	a6,32(s0)
 7d0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d8:	8622                	mv	a2,s0
 7da:	00000097          	auipc	ra,0x0
 7de:	e04080e7          	jalr	-508(ra) # 5de <vprintf>
}
 7e2:	60e2                	ld	ra,24(sp)
 7e4:	6442                	ld	s0,16(sp)
 7e6:	6161                	addi	sp,sp,80
 7e8:	8082                	ret

00000000000007ea <printf>:

void
printf(const char *fmt, ...)
{
 7ea:	711d                	addi	sp,sp,-96
 7ec:	ec06                	sd	ra,24(sp)
 7ee:	e822                	sd	s0,16(sp)
 7f0:	1000                	addi	s0,sp,32
 7f2:	e40c                	sd	a1,8(s0)
 7f4:	e810                	sd	a2,16(s0)
 7f6:	ec14                	sd	a3,24(s0)
 7f8:	f018                	sd	a4,32(s0)
 7fa:	f41c                	sd	a5,40(s0)
 7fc:	03043823          	sd	a6,48(s0)
 800:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 804:	00840613          	addi	a2,s0,8
 808:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 80c:	85aa                	mv	a1,a0
 80e:	4505                	li	a0,1
 810:	00000097          	auipc	ra,0x0
 814:	dce080e7          	jalr	-562(ra) # 5de <vprintf>
}
 818:	60e2                	ld	ra,24(sp)
 81a:	6442                	ld	s0,16(sp)
 81c:	6125                	addi	sp,sp,96
 81e:	8082                	ret

0000000000000820 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 820:	1141                	addi	sp,sp,-16
 822:	e422                	sd	s0,8(sp)
 824:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 826:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82a:	00000797          	auipc	a5,0x0
 82e:	2767b783          	ld	a5,630(a5) # aa0 <freep>
 832:	a02d                	j	85c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 834:	4618                	lw	a4,8(a2)
 836:	9f2d                	addw	a4,a4,a1
 838:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83c:	6398                	ld	a4,0(a5)
 83e:	6310                	ld	a2,0(a4)
 840:	a83d                	j	87e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 842:	ff852703          	lw	a4,-8(a0)
 846:	9f31                	addw	a4,a4,a2
 848:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 84a:	ff053683          	ld	a3,-16(a0)
 84e:	a091                	j	892 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 850:	6398                	ld	a4,0(a5)
 852:	00e7e463          	bltu	a5,a4,85a <free+0x3a>
 856:	00e6ea63          	bltu	a3,a4,86a <free+0x4a>
{
 85a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85c:	fed7fae3          	bgeu	a5,a3,850 <free+0x30>
 860:	6398                	ld	a4,0(a5)
 862:	00e6e463          	bltu	a3,a4,86a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 866:	fee7eae3          	bltu	a5,a4,85a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 86a:	ff852583          	lw	a1,-8(a0)
 86e:	6390                	ld	a2,0(a5)
 870:	02059813          	slli	a6,a1,0x20
 874:	01c85713          	srli	a4,a6,0x1c
 878:	9736                	add	a4,a4,a3
 87a:	fae60de3          	beq	a2,a4,834 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 87e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 882:	4790                	lw	a2,8(a5)
 884:	02061593          	slli	a1,a2,0x20
 888:	01c5d713          	srli	a4,a1,0x1c
 88c:	973e                	add	a4,a4,a5
 88e:	fae68ae3          	beq	a3,a4,842 <free+0x22>
    p->s.ptr = bp->s.ptr;
 892:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 894:	00000717          	auipc	a4,0x0
 898:	20f73623          	sd	a5,524(a4) # aa0 <freep>
}
 89c:	6422                	ld	s0,8(sp)
 89e:	0141                	addi	sp,sp,16
 8a0:	8082                	ret

00000000000008a2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a2:	7139                	addi	sp,sp,-64
 8a4:	fc06                	sd	ra,56(sp)
 8a6:	f822                	sd	s0,48(sp)
 8a8:	f426                	sd	s1,40(sp)
 8aa:	f04a                	sd	s2,32(sp)
 8ac:	ec4e                	sd	s3,24(sp)
 8ae:	e852                	sd	s4,16(sp)
 8b0:	e456                	sd	s5,8(sp)
 8b2:	e05a                	sd	s6,0(sp)
 8b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b6:	02051493          	slli	s1,a0,0x20
 8ba:	9081                	srli	s1,s1,0x20
 8bc:	04bd                	addi	s1,s1,15
 8be:	8091                	srli	s1,s1,0x4
 8c0:	0014899b          	addiw	s3,s1,1
 8c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c6:	00000517          	auipc	a0,0x0
 8ca:	1da53503          	ld	a0,474(a0) # aa0 <freep>
 8ce:	c515                	beqz	a0,8fa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	02977f63          	bgeu	a4,s1,912 <malloc+0x70>
 8d8:	8a4e                	mv	s4,s3
 8da:	0009871b          	sext.w	a4,s3
 8de:	6685                	lui	a3,0x1
 8e0:	00d77363          	bgeu	a4,a3,8e6 <malloc+0x44>
 8e4:	6a05                	lui	s4,0x1
 8e6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ea:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ee:	00000917          	auipc	s2,0x0
 8f2:	1b290913          	addi	s2,s2,434 # aa0 <freep>
  if(p == (char*)-1)
 8f6:	5afd                	li	s5,-1
 8f8:	a895                	j	96c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8fa:	00000797          	auipc	a5,0x0
 8fe:	1ae78793          	addi	a5,a5,430 # aa8 <base>
 902:	00000717          	auipc	a4,0x0
 906:	18f73f23          	sd	a5,414(a4) # aa0 <freep>
 90a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 90c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 910:	b7e1                	j	8d8 <malloc+0x36>
      if(p->s.size == nunits)
 912:	02e48c63          	beq	s1,a4,94a <malloc+0xa8>
        p->s.size -= nunits;
 916:	4137073b          	subw	a4,a4,s3
 91a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91c:	02071693          	slli	a3,a4,0x20
 920:	01c6d713          	srli	a4,a3,0x1c
 924:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 926:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92a:	00000717          	auipc	a4,0x0
 92e:	16a73b23          	sd	a0,374(a4) # aa0 <freep>
      return (void*)(p + 1);
 932:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 936:	70e2                	ld	ra,56(sp)
 938:	7442                	ld	s0,48(sp)
 93a:	74a2                	ld	s1,40(sp)
 93c:	7902                	ld	s2,32(sp)
 93e:	69e2                	ld	s3,24(sp)
 940:	6a42                	ld	s4,16(sp)
 942:	6aa2                	ld	s5,8(sp)
 944:	6b02                	ld	s6,0(sp)
 946:	6121                	addi	sp,sp,64
 948:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 94a:	6398                	ld	a4,0(a5)
 94c:	e118                	sd	a4,0(a0)
 94e:	bff1                	j	92a <malloc+0x88>
  hp->s.size = nu;
 950:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 954:	0541                	addi	a0,a0,16
 956:	00000097          	auipc	ra,0x0
 95a:	eca080e7          	jalr	-310(ra) # 820 <free>
  return freep;
 95e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 962:	d971                	beqz	a0,936 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 964:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 966:	4798                	lw	a4,8(a5)
 968:	fa9775e3          	bgeu	a4,s1,912 <malloc+0x70>
    if(p == freep)
 96c:	00093703          	ld	a4,0(s2)
 970:	853e                	mv	a0,a5
 972:	fef719e3          	bne	a4,a5,964 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 976:	8552                	mv	a0,s4
 978:	00000097          	auipc	ra,0x0
 97c:	ae0080e7          	jalr	-1312(ra) # 458 <sbrk>
  if(p == (char*)-1)
 980:	fd5518e3          	bne	a0,s5,950 <malloc+0xae>
        return 0;
 984:	4501                	li	a0,0
 986:	bf45                	j	936 <malloc+0x94>
