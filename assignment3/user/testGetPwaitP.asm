
user/_testGetPwaitP:     file format elf64-littleriscv


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
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  int m, n, x;

  if (argc != 3) {
   e:	478d                	li	a5,3
  10:	02f50063          	beq	a0,a5,30 <main+0x30>
     fprintf(2, "syntax: testGetPwaitP m n\nAborting...\n");
  14:	00001597          	auipc	a1,0x1
  18:	95c58593          	addi	a1,a1,-1700 # 970 <malloc+0xe8>
  1c:	4509                	li	a0,2
  1e:	00000097          	auipc	ra,0x0
  22:	784080e7          	jalr	1924(ra) # 7a2 <fprintf>
     exit(0);
  26:	4501                	li	a0,0
  28:	00000097          	auipc	ra,0x0
  2c:	38e080e7          	jalr	910(ra) # 3b6 <exit>
  30:	84ae                	mv	s1,a1
  }

  m = atoi(argv[1]);
  32:	6588                	ld	a0,8(a1)
  34:	00000097          	auipc	ra,0x0
  38:	288080e7          	jalr	648(ra) # 2bc <atoi>
  3c:	892a                	mv	s2,a0
  if (m <= 0) {
  3e:	02a05b63          	blez	a0,74 <main+0x74>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  n = atoi(argv[2]);
  42:	6888                	ld	a0,16(s1)
  44:	00000097          	auipc	ra,0x0
  48:	278080e7          	jalr	632(ra) # 2bc <atoi>
  4c:	84aa                	mv	s1,a0
  if ((n != 0) && (n != 1)) {
  4e:	0005071b          	sext.w	a4,a0
  52:	4785                	li	a5,1
  54:	02e7fe63          	bgeu	a5,a4,90 <main+0x90>
     fprintf(2, "Invalid input\nAborting...\n");
  58:	00001597          	auipc	a1,0x1
  5c:	94058593          	addi	a1,a1,-1728 # 998 <malloc+0x110>
  60:	4509                	li	a0,2
  62:	00000097          	auipc	ra,0x0
  66:	740080e7          	jalr	1856(ra) # 7a2 <fprintf>
     exit(0);
  6a:	4501                	li	a0,0
  6c:	00000097          	auipc	ra,0x0
  70:	34a080e7          	jalr	842(ra) # 3b6 <exit>
     fprintf(2, "Invalid input\nAborting...\n");
  74:	00001597          	auipc	a1,0x1
  78:	92458593          	addi	a1,a1,-1756 # 998 <malloc+0x110>
  7c:	4509                	li	a0,2
  7e:	00000097          	auipc	ra,0x0
  82:	724080e7          	jalr	1828(ra) # 7a2 <fprintf>
     exit(0);
  86:	4501                	li	a0,0
  88:	00000097          	auipc	ra,0x0
  8c:	32e080e7          	jalr	814(ra) # 3b6 <exit>
  }

  x = fork();
  90:	00000097          	auipc	ra,0x0
  94:	31e080e7          	jalr	798(ra) # 3ae <fork>
  98:	89aa                	mv	s3,a0
  if (x < 0) {
  9a:	04054863          	bltz	a0,ea <main+0xea>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  9e:	06a05a63          	blez	a0,112 <main+0x112>
     if (n) sleep(m);
  a2:	e0b5                	bnez	s1,106 <main+0x106>
     fprintf(1, "%d: Parent.\n", getpid());
  a4:	00000097          	auipc	ra,0x0
  a8:	392080e7          	jalr	914(ra) # 436 <getpid>
  ac:	862a                	mv	a2,a0
  ae:	00001597          	auipc	a1,0x1
  b2:	92a58593          	addi	a1,a1,-1750 # 9d8 <malloc+0x150>
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	6ea080e7          	jalr	1770(ra) # 7a2 <fprintf>
     fprintf(1, "Return value of waitpid=%d\n", waitpid(x, 0));
  c0:	4581                	li	a1,0
  c2:	854e                	mv	a0,s3
  c4:	00000097          	auipc	ra,0x0
  c8:	3b2080e7          	jalr	946(ra) # 476 <waitpid>
  cc:	862a                	mv	a2,a0
  ce:	00001597          	auipc	a1,0x1
  d2:	91a58593          	addi	a1,a1,-1766 # 9e8 <malloc+0x160>
  d6:	4505                	li	a0,1
  d8:	00000097          	auipc	ra,0x0
  dc:	6ca080e7          	jalr	1738(ra) # 7a2 <fprintf>
  else {
     if (!n) sleep(m);
     fprintf(1, "%d: Child with parent %d.\n", getpid(), getppid());
  }

  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2d4080e7          	jalr	724(ra) # 3b6 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
  ea:	00001597          	auipc	a1,0x1
  ee:	8ce58593          	addi	a1,a1,-1842 # 9b8 <malloc+0x130>
  f2:	4509                	li	a0,2
  f4:	00000097          	auipc	ra,0x0
  f8:	6ae080e7          	jalr	1710(ra) # 7a2 <fprintf>
     exit(0);
  fc:	4501                	li	a0,0
  fe:	00000097          	auipc	ra,0x0
 102:	2b8080e7          	jalr	696(ra) # 3b6 <exit>
     if (n) sleep(m);
 106:	854a                	mv	a0,s2
 108:	00000097          	auipc	ra,0x0
 10c:	33e080e7          	jalr	830(ra) # 446 <sleep>
 110:	bf51                	j	a4 <main+0xa4>
     if (!n) sleep(m);
 112:	c495                	beqz	s1,13e <main+0x13e>
     fprintf(1, "%d: Child with parent %d.\n", getpid(), getppid());
 114:	00000097          	auipc	ra,0x0
 118:	322080e7          	jalr	802(ra) # 436 <getpid>
 11c:	84aa                	mv	s1,a0
 11e:	00000097          	auipc	ra,0x0
 122:	338080e7          	jalr	824(ra) # 456 <getppid>
 126:	86aa                	mv	a3,a0
 128:	8626                	mv	a2,s1
 12a:	00001597          	auipc	a1,0x1
 12e:	8de58593          	addi	a1,a1,-1826 # a08 <malloc+0x180>
 132:	4505                	li	a0,1
 134:	00000097          	auipc	ra,0x0
 138:	66e080e7          	jalr	1646(ra) # 7a2 <fprintf>
 13c:	b755                	j	e0 <main+0xe0>
     if (!n) sleep(m);
 13e:	854a                	mv	a0,s2
 140:	00000097          	auipc	ra,0x0
 144:	306080e7          	jalr	774(ra) # 446 <sleep>
 148:	b7f1                	j	114 <main+0x114>

000000000000014a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 150:	87aa                	mv	a5,a0
 152:	0585                	addi	a1,a1,1
 154:	0785                	addi	a5,a5,1
 156:	fff5c703          	lbu	a4,-1(a1)
 15a:	fee78fa3          	sb	a4,-1(a5)
 15e:	fb75                	bnez	a4,152 <strcpy+0x8>
    ;
  return os;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cb91                	beqz	a5,184 <strcmp+0x1e>
 172:	0005c703          	lbu	a4,0(a1)
 176:	00f71763          	bne	a4,a5,184 <strcmp+0x1e>
    p++, q++;
 17a:	0505                	addi	a0,a0,1
 17c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 17e:	00054783          	lbu	a5,0(a0)
 182:	fbe5                	bnez	a5,172 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 184:	0005c503          	lbu	a0,0(a1)
}
 188:	40a7853b          	subw	a0,a5,a0
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret

0000000000000192 <strlen>:

uint
strlen(const char *s)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 198:	00054783          	lbu	a5,0(a0)
 19c:	cf91                	beqz	a5,1b8 <strlen+0x26>
 19e:	0505                	addi	a0,a0,1
 1a0:	87aa                	mv	a5,a0
 1a2:	4685                	li	a3,1
 1a4:	9e89                	subw	a3,a3,a0
 1a6:	00f6853b          	addw	a0,a3,a5
 1aa:	0785                	addi	a5,a5,1
 1ac:	fff7c703          	lbu	a4,-1(a5)
 1b0:	fb7d                	bnez	a4,1a6 <strlen+0x14>
    ;
  return n;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  for(n = 0; s[n]; n++)
 1b8:	4501                	li	a0,0
 1ba:	bfe5                	j	1b2 <strlen+0x20>

00000000000001bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c2:	ca19                	beqz	a2,1d8 <memset+0x1c>
 1c4:	87aa                	mv	a5,a0
 1c6:	1602                	slli	a2,a2,0x20
 1c8:	9201                	srli	a2,a2,0x20
 1ca:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ce:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d2:	0785                	addi	a5,a5,1
 1d4:	fee79de3          	bne	a5,a4,1ce <memset+0x12>
  }
  return dst;
}
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret

00000000000001de <strchr>:

char*
strchr(const char *s, char c)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	cb99                	beqz	a5,1fe <strchr+0x20>
    if(*s == c)
 1ea:	00f58763          	beq	a1,a5,1f8 <strchr+0x1a>
  for(; *s; s++)
 1ee:	0505                	addi	a0,a0,1
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	fbfd                	bnez	a5,1ea <strchr+0xc>
      return (char*)s;
  return 0;
 1f6:	4501                	li	a0,0
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  return 0;
 1fe:	4501                	li	a0,0
 200:	bfe5                	j	1f8 <strchr+0x1a>

0000000000000202 <gets>:

char*
gets(char *buf, int max)
{
 202:	711d                	addi	sp,sp,-96
 204:	ec86                	sd	ra,88(sp)
 206:	e8a2                	sd	s0,80(sp)
 208:	e4a6                	sd	s1,72(sp)
 20a:	e0ca                	sd	s2,64(sp)
 20c:	fc4e                	sd	s3,56(sp)
 20e:	f852                	sd	s4,48(sp)
 210:	f456                	sd	s5,40(sp)
 212:	f05a                	sd	s6,32(sp)
 214:	ec5e                	sd	s7,24(sp)
 216:	1080                	addi	s0,sp,96
 218:	8baa                	mv	s7,a0
 21a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21c:	892a                	mv	s2,a0
 21e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 220:	4aa9                	li	s5,10
 222:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 224:	89a6                	mv	s3,s1
 226:	2485                	addiw	s1,s1,1
 228:	0344d863          	bge	s1,s4,258 <gets+0x56>
    cc = read(0, &c, 1);
 22c:	4605                	li	a2,1
 22e:	faf40593          	addi	a1,s0,-81
 232:	4501                	li	a0,0
 234:	00000097          	auipc	ra,0x0
 238:	19a080e7          	jalr	410(ra) # 3ce <read>
    if(cc < 1)
 23c:	00a05e63          	blez	a0,258 <gets+0x56>
    buf[i++] = c;
 240:	faf44783          	lbu	a5,-81(s0)
 244:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 248:	01578763          	beq	a5,s5,256 <gets+0x54>
 24c:	0905                	addi	s2,s2,1
 24e:	fd679be3          	bne	a5,s6,224 <gets+0x22>
  for(i=0; i+1 < max; ){
 252:	89a6                	mv	s3,s1
 254:	a011                	j	258 <gets+0x56>
 256:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 258:	99de                	add	s3,s3,s7
 25a:	00098023          	sb	zero,0(s3)
  return buf;
}
 25e:	855e                	mv	a0,s7
 260:	60e6                	ld	ra,88(sp)
 262:	6446                	ld	s0,80(sp)
 264:	64a6                	ld	s1,72(sp)
 266:	6906                	ld	s2,64(sp)
 268:	79e2                	ld	s3,56(sp)
 26a:	7a42                	ld	s4,48(sp)
 26c:	7aa2                	ld	s5,40(sp)
 26e:	7b02                	ld	s6,32(sp)
 270:	6be2                	ld	s7,24(sp)
 272:	6125                	addi	sp,sp,96
 274:	8082                	ret

0000000000000276 <stat>:

int
stat(const char *n, struct stat *st)
{
 276:	1101                	addi	sp,sp,-32
 278:	ec06                	sd	ra,24(sp)
 27a:	e822                	sd	s0,16(sp)
 27c:	e426                	sd	s1,8(sp)
 27e:	e04a                	sd	s2,0(sp)
 280:	1000                	addi	s0,sp,32
 282:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 284:	4581                	li	a1,0
 286:	00000097          	auipc	ra,0x0
 28a:	170080e7          	jalr	368(ra) # 3f6 <open>
  if(fd < 0)
 28e:	02054563          	bltz	a0,2b8 <stat+0x42>
 292:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 294:	85ca                	mv	a1,s2
 296:	00000097          	auipc	ra,0x0
 29a:	178080e7          	jalr	376(ra) # 40e <fstat>
 29e:	892a                	mv	s2,a0
  close(fd);
 2a0:	8526                	mv	a0,s1
 2a2:	00000097          	auipc	ra,0x0
 2a6:	13c080e7          	jalr	316(ra) # 3de <close>
  return r;
}
 2aa:	854a                	mv	a0,s2
 2ac:	60e2                	ld	ra,24(sp)
 2ae:	6442                	ld	s0,16(sp)
 2b0:	64a2                	ld	s1,8(sp)
 2b2:	6902                	ld	s2,0(sp)
 2b4:	6105                	addi	sp,sp,32
 2b6:	8082                	ret
    return -1;
 2b8:	597d                	li	s2,-1
 2ba:	bfc5                	j	2aa <stat+0x34>

00000000000002bc <atoi>:

int
atoi(const char *s)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e422                	sd	s0,8(sp)
 2c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c2:	00054683          	lbu	a3,0(a0)
 2c6:	fd06879b          	addiw	a5,a3,-48
 2ca:	0ff7f793          	zext.b	a5,a5
 2ce:	4625                	li	a2,9
 2d0:	02f66863          	bltu	a2,a5,300 <atoi+0x44>
 2d4:	872a                	mv	a4,a0
  n = 0;
 2d6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2d8:	0705                	addi	a4,a4,1
 2da:	0025179b          	slliw	a5,a0,0x2
 2de:	9fa9                	addw	a5,a5,a0
 2e0:	0017979b          	slliw	a5,a5,0x1
 2e4:	9fb5                	addw	a5,a5,a3
 2e6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ea:	00074683          	lbu	a3,0(a4)
 2ee:	fd06879b          	addiw	a5,a3,-48
 2f2:	0ff7f793          	zext.b	a5,a5
 2f6:	fef671e3          	bgeu	a2,a5,2d8 <atoi+0x1c>
  return n;
}
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
  n = 0;
 300:	4501                	li	a0,0
 302:	bfe5                	j	2fa <atoi+0x3e>

0000000000000304 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 304:	1141                	addi	sp,sp,-16
 306:	e422                	sd	s0,8(sp)
 308:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30a:	02b57463          	bgeu	a0,a1,332 <memmove+0x2e>
    while(n-- > 0)
 30e:	00c05f63          	blez	a2,32c <memmove+0x28>
 312:	1602                	slli	a2,a2,0x20
 314:	9201                	srli	a2,a2,0x20
 316:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31a:	872a                	mv	a4,a0
      *dst++ = *src++;
 31c:	0585                	addi	a1,a1,1
 31e:	0705                	addi	a4,a4,1
 320:	fff5c683          	lbu	a3,-1(a1)
 324:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 328:	fee79ae3          	bne	a5,a4,31c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
    dst += n;
 332:	00c50733          	add	a4,a0,a2
    src += n;
 336:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 338:	fec05ae3          	blez	a2,32c <memmove+0x28>
 33c:	fff6079b          	addiw	a5,a2,-1
 340:	1782                	slli	a5,a5,0x20
 342:	9381                	srli	a5,a5,0x20
 344:	fff7c793          	not	a5,a5
 348:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 34a:	15fd                	addi	a1,a1,-1
 34c:	177d                	addi	a4,a4,-1
 34e:	0005c683          	lbu	a3,0(a1)
 352:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 356:	fee79ae3          	bne	a5,a4,34a <memmove+0x46>
 35a:	bfc9                	j	32c <memmove+0x28>

000000000000035c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e422                	sd	s0,8(sp)
 360:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 362:	ca05                	beqz	a2,392 <memcmp+0x36>
 364:	fff6069b          	addiw	a3,a2,-1
 368:	1682                	slli	a3,a3,0x20
 36a:	9281                	srli	a3,a3,0x20
 36c:	0685                	addi	a3,a3,1
 36e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 370:	00054783          	lbu	a5,0(a0)
 374:	0005c703          	lbu	a4,0(a1)
 378:	00e79863          	bne	a5,a4,388 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 37c:	0505                	addi	a0,a0,1
    p2++;
 37e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 380:	fed518e3          	bne	a0,a3,370 <memcmp+0x14>
  }
  return 0;
 384:	4501                	li	a0,0
 386:	a019                	j	38c <memcmp+0x30>
      return *p1 - *p2;
 388:	40e7853b          	subw	a0,a5,a4
}
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret
  return 0;
 392:	4501                	li	a0,0
 394:	bfe5                	j	38c <memcmp+0x30>

0000000000000396 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 396:	1141                	addi	sp,sp,-16
 398:	e406                	sd	ra,8(sp)
 39a:	e022                	sd	s0,0(sp)
 39c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 39e:	00000097          	auipc	ra,0x0
 3a2:	f66080e7          	jalr	-154(ra) # 304 <memmove>
}
 3a6:	60a2                	ld	ra,8(sp)
 3a8:	6402                	ld	s0,0(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret

00000000000003ae <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ae:	4885                	li	a7,1
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3b6:	4889                	li	a7,2
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <wait>:
.global wait
wait:
 li a7, SYS_wait
 3be:	488d                	li	a7,3
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3c6:	4891                	li	a7,4
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <read>:
.global read
read:
 li a7, SYS_read
 3ce:	4895                	li	a7,5
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <write>:
.global write
write:
 li a7, SYS_write
 3d6:	48c1                	li	a7,16
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <close>:
.global close
close:
 li a7, SYS_close
 3de:	48d5                	li	a7,21
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3e6:	4899                	li	a7,6
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ee:	489d                	li	a7,7
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <open>:
.global open
open:
 li a7, SYS_open
 3f6:	48bd                	li	a7,15
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3fe:	48c5                	li	a7,17
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 406:	48c9                	li	a7,18
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 40e:	48a1                	li	a7,8
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <link>:
.global link
link:
 li a7, SYS_link
 416:	48cd                	li	a7,19
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 41e:	48d1                	li	a7,20
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 426:	48a5                	li	a7,9
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <dup>:
.global dup
dup:
 li a7, SYS_dup
 42e:	48a9                	li	a7,10
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 436:	48ad                	li	a7,11
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 43e:	48b1                	li	a7,12
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 446:	48b5                	li	a7,13
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 44e:	48b9                	li	a7,14
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 456:	48d9                	li	a7,22
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <yield>:
.global yield
yield:
 li a7, SYS_yield
 45e:	48dd                	li	a7,23
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 466:	48e1                	li	a7,24
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 46e:	48e5                	li	a7,25
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 476:	48e9                	li	a7,26
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <ps>:
.global ps
ps:
 li a7, SYS_ps
 47e:	48ed                	li	a7,27
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 486:	48f1                	li	a7,28
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 48e:	48f5                	li	a7,29
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 496:	48f9                	li	a7,30
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 49e:	02100893          	li	a7,33
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 4a8:	48fd                	li	a7,31
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 4b0:	02000893          	li	a7,32
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 4ba:	02200893          	li	a7,34
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 4c4:	02300893          	li	a7,35
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 4ce:	02400893          	li	a7,36
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 4d8:	02500893          	li	a7,37
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 4e2:	02700893          	li	a7,39
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 4ec:	02600893          	li	a7,38
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4f6:	1101                	addi	sp,sp,-32
 4f8:	ec06                	sd	ra,24(sp)
 4fa:	e822                	sd	s0,16(sp)
 4fc:	1000                	addi	s0,sp,32
 4fe:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 502:	4605                	li	a2,1
 504:	fef40593          	addi	a1,s0,-17
 508:	00000097          	auipc	ra,0x0
 50c:	ece080e7          	jalr	-306(ra) # 3d6 <write>
}
 510:	60e2                	ld	ra,24(sp)
 512:	6442                	ld	s0,16(sp)
 514:	6105                	addi	sp,sp,32
 516:	8082                	ret

0000000000000518 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 518:	7139                	addi	sp,sp,-64
 51a:	fc06                	sd	ra,56(sp)
 51c:	f822                	sd	s0,48(sp)
 51e:	f426                	sd	s1,40(sp)
 520:	f04a                	sd	s2,32(sp)
 522:	ec4e                	sd	s3,24(sp)
 524:	0080                	addi	s0,sp,64
 526:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 528:	c299                	beqz	a3,52e <printint+0x16>
 52a:	0805c963          	bltz	a1,5bc <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 52e:	2581                	sext.w	a1,a1
  neg = 0;
 530:	4881                	li	a7,0
 532:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 536:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 538:	2601                	sext.w	a2,a2
 53a:	00000517          	auipc	a0,0x0
 53e:	54e50513          	addi	a0,a0,1358 # a88 <digits>
 542:	883a                	mv	a6,a4
 544:	2705                	addiw	a4,a4,1
 546:	02c5f7bb          	remuw	a5,a1,a2
 54a:	1782                	slli	a5,a5,0x20
 54c:	9381                	srli	a5,a5,0x20
 54e:	97aa                	add	a5,a5,a0
 550:	0007c783          	lbu	a5,0(a5)
 554:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 558:	0005879b          	sext.w	a5,a1
 55c:	02c5d5bb          	divuw	a1,a1,a2
 560:	0685                	addi	a3,a3,1
 562:	fec7f0e3          	bgeu	a5,a2,542 <printint+0x2a>
  if(neg)
 566:	00088c63          	beqz	a7,57e <printint+0x66>
    buf[i++] = '-';
 56a:	fd070793          	addi	a5,a4,-48
 56e:	00878733          	add	a4,a5,s0
 572:	02d00793          	li	a5,45
 576:	fef70823          	sb	a5,-16(a4)
 57a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 57e:	02e05863          	blez	a4,5ae <printint+0x96>
 582:	fc040793          	addi	a5,s0,-64
 586:	00e78933          	add	s2,a5,a4
 58a:	fff78993          	addi	s3,a5,-1
 58e:	99ba                	add	s3,s3,a4
 590:	377d                	addiw	a4,a4,-1
 592:	1702                	slli	a4,a4,0x20
 594:	9301                	srli	a4,a4,0x20
 596:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 59a:	fff94583          	lbu	a1,-1(s2)
 59e:	8526                	mv	a0,s1
 5a0:	00000097          	auipc	ra,0x0
 5a4:	f56080e7          	jalr	-170(ra) # 4f6 <putc>
  while(--i >= 0)
 5a8:	197d                	addi	s2,s2,-1
 5aa:	ff3918e3          	bne	s2,s3,59a <printint+0x82>
}
 5ae:	70e2                	ld	ra,56(sp)
 5b0:	7442                	ld	s0,48(sp)
 5b2:	74a2                	ld	s1,40(sp)
 5b4:	7902                	ld	s2,32(sp)
 5b6:	69e2                	ld	s3,24(sp)
 5b8:	6121                	addi	sp,sp,64
 5ba:	8082                	ret
    x = -xx;
 5bc:	40b005bb          	negw	a1,a1
    neg = 1;
 5c0:	4885                	li	a7,1
    x = -xx;
 5c2:	bf85                	j	532 <printint+0x1a>

00000000000005c4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c4:	7119                	addi	sp,sp,-128
 5c6:	fc86                	sd	ra,120(sp)
 5c8:	f8a2                	sd	s0,112(sp)
 5ca:	f4a6                	sd	s1,104(sp)
 5cc:	f0ca                	sd	s2,96(sp)
 5ce:	ecce                	sd	s3,88(sp)
 5d0:	e8d2                	sd	s4,80(sp)
 5d2:	e4d6                	sd	s5,72(sp)
 5d4:	e0da                	sd	s6,64(sp)
 5d6:	fc5e                	sd	s7,56(sp)
 5d8:	f862                	sd	s8,48(sp)
 5da:	f466                	sd	s9,40(sp)
 5dc:	f06a                	sd	s10,32(sp)
 5de:	ec6e                	sd	s11,24(sp)
 5e0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e2:	0005c903          	lbu	s2,0(a1)
 5e6:	18090f63          	beqz	s2,784 <vprintf+0x1c0>
 5ea:	8aaa                	mv	s5,a0
 5ec:	8b32                	mv	s6,a2
 5ee:	00158493          	addi	s1,a1,1
  state = 0;
 5f2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5f4:	02500a13          	li	s4,37
 5f8:	4c55                	li	s8,21
 5fa:	00000c97          	auipc	s9,0x0
 5fe:	436c8c93          	addi	s9,s9,1078 # a30 <malloc+0x1a8>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 602:	02800d93          	li	s11,40
  putc(fd, 'x');
 606:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 608:	00000b97          	auipc	s7,0x0
 60c:	480b8b93          	addi	s7,s7,1152 # a88 <digits>
 610:	a839                	j	62e <vprintf+0x6a>
        putc(fd, c);
 612:	85ca                	mv	a1,s2
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	ee0080e7          	jalr	-288(ra) # 4f6 <putc>
 61e:	a019                	j	624 <vprintf+0x60>
    } else if(state == '%'){
 620:	01498d63          	beq	s3,s4,63a <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 624:	0485                	addi	s1,s1,1
 626:	fff4c903          	lbu	s2,-1(s1)
 62a:	14090d63          	beqz	s2,784 <vprintf+0x1c0>
    if(state == 0){
 62e:	fe0999e3          	bnez	s3,620 <vprintf+0x5c>
      if(c == '%'){
 632:	ff4910e3          	bne	s2,s4,612 <vprintf+0x4e>
        state = '%';
 636:	89d2                	mv	s3,s4
 638:	b7f5                	j	624 <vprintf+0x60>
      if(c == 'd'){
 63a:	11490c63          	beq	s2,s4,752 <vprintf+0x18e>
 63e:	f9d9079b          	addiw	a5,s2,-99
 642:	0ff7f793          	zext.b	a5,a5
 646:	10fc6e63          	bltu	s8,a5,762 <vprintf+0x19e>
 64a:	f9d9079b          	addiw	a5,s2,-99
 64e:	0ff7f713          	zext.b	a4,a5
 652:	10ec6863          	bltu	s8,a4,762 <vprintf+0x19e>
 656:	00271793          	slli	a5,a4,0x2
 65a:	97e6                	add	a5,a5,s9
 65c:	439c                	lw	a5,0(a5)
 65e:	97e6                	add	a5,a5,s9
 660:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 662:	008b0913          	addi	s2,s6,8
 666:	4685                	li	a3,1
 668:	4629                	li	a2,10
 66a:	000b2583          	lw	a1,0(s6)
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	ea8080e7          	jalr	-344(ra) # 518 <printint>
 678:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b765                	j	624 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	008b0913          	addi	s2,s6,8
 682:	4681                	li	a3,0
 684:	4629                	li	a2,10
 686:	000b2583          	lw	a1,0(s6)
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	e8c080e7          	jalr	-372(ra) # 518 <printint>
 694:	8b4a                	mv	s6,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	b771                	j	624 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 69a:	008b0913          	addi	s2,s6,8
 69e:	4681                	li	a3,0
 6a0:	866a                	mv	a2,s10
 6a2:	000b2583          	lw	a1,0(s6)
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	e70080e7          	jalr	-400(ra) # 518 <printint>
 6b0:	8b4a                	mv	s6,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bf85                	j	624 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6b6:	008b0793          	addi	a5,s6,8
 6ba:	f8f43423          	sd	a5,-120(s0)
 6be:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6c2:	03000593          	li	a1,48
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e2e080e7          	jalr	-466(ra) # 4f6 <putc>
  putc(fd, 'x');
 6d0:	07800593          	li	a1,120
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e20080e7          	jalr	-480(ra) # 4f6 <putc>
 6de:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e0:	03c9d793          	srli	a5,s3,0x3c
 6e4:	97de                	add	a5,a5,s7
 6e6:	0007c583          	lbu	a1,0(a5)
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	e0a080e7          	jalr	-502(ra) # 4f6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f4:	0992                	slli	s3,s3,0x4
 6f6:	397d                	addiw	s2,s2,-1
 6f8:	fe0914e3          	bnez	s2,6e0 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6fc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 700:	4981                	li	s3,0
 702:	b70d                	j	624 <vprintf+0x60>
        s = va_arg(ap, char*);
 704:	008b0913          	addi	s2,s6,8
 708:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 70c:	02098163          	beqz	s3,72e <vprintf+0x16a>
        while(*s != 0){
 710:	0009c583          	lbu	a1,0(s3)
 714:	c5ad                	beqz	a1,77e <vprintf+0x1ba>
          putc(fd, *s);
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	dde080e7          	jalr	-546(ra) # 4f6 <putc>
          s++;
 720:	0985                	addi	s3,s3,1
        while(*s != 0){
 722:	0009c583          	lbu	a1,0(s3)
 726:	f9e5                	bnez	a1,716 <vprintf+0x152>
        s = va_arg(ap, char*);
 728:	8b4a                	mv	s6,s2
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bde5                	j	624 <vprintf+0x60>
          s = "(null)";
 72e:	00000997          	auipc	s3,0x0
 732:	2fa98993          	addi	s3,s3,762 # a28 <malloc+0x1a0>
        while(*s != 0){
 736:	85ee                	mv	a1,s11
 738:	bff9                	j	716 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 73a:	008b0913          	addi	s2,s6,8
 73e:	000b4583          	lbu	a1,0(s6)
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	db2080e7          	jalr	-590(ra) # 4f6 <putc>
 74c:	8b4a                	mv	s6,s2
      state = 0;
 74e:	4981                	li	s3,0
 750:	bdd1                	j	624 <vprintf+0x60>
        putc(fd, c);
 752:	85d2                	mv	a1,s4
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	da0080e7          	jalr	-608(ra) # 4f6 <putc>
      state = 0;
 75e:	4981                	li	s3,0
 760:	b5d1                	j	624 <vprintf+0x60>
        putc(fd, '%');
 762:	85d2                	mv	a1,s4
 764:	8556                	mv	a0,s5
 766:	00000097          	auipc	ra,0x0
 76a:	d90080e7          	jalr	-624(ra) # 4f6 <putc>
        putc(fd, c);
 76e:	85ca                	mv	a1,s2
 770:	8556                	mv	a0,s5
 772:	00000097          	auipc	ra,0x0
 776:	d84080e7          	jalr	-636(ra) # 4f6 <putc>
      state = 0;
 77a:	4981                	li	s3,0
 77c:	b565                	j	624 <vprintf+0x60>
        s = va_arg(ap, char*);
 77e:	8b4a                	mv	s6,s2
      state = 0;
 780:	4981                	li	s3,0
 782:	b54d                	j	624 <vprintf+0x60>
    }
  }
}
 784:	70e6                	ld	ra,120(sp)
 786:	7446                	ld	s0,112(sp)
 788:	74a6                	ld	s1,104(sp)
 78a:	7906                	ld	s2,96(sp)
 78c:	69e6                	ld	s3,88(sp)
 78e:	6a46                	ld	s4,80(sp)
 790:	6aa6                	ld	s5,72(sp)
 792:	6b06                	ld	s6,64(sp)
 794:	7be2                	ld	s7,56(sp)
 796:	7c42                	ld	s8,48(sp)
 798:	7ca2                	ld	s9,40(sp)
 79a:	7d02                	ld	s10,32(sp)
 79c:	6de2                	ld	s11,24(sp)
 79e:	6109                	addi	sp,sp,128
 7a0:	8082                	ret

00000000000007a2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a2:	715d                	addi	sp,sp,-80
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e010                	sd	a2,0(s0)
 7ac:	e414                	sd	a3,8(s0)
 7ae:	e818                	sd	a4,16(s0)
 7b0:	ec1c                	sd	a5,24(s0)
 7b2:	03043023          	sd	a6,32(s0)
 7b6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ba:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7be:	8622                	mv	a2,s0
 7c0:	00000097          	auipc	ra,0x0
 7c4:	e04080e7          	jalr	-508(ra) # 5c4 <vprintf>
}
 7c8:	60e2                	ld	ra,24(sp)
 7ca:	6442                	ld	s0,16(sp)
 7cc:	6161                	addi	sp,sp,80
 7ce:	8082                	ret

00000000000007d0 <printf>:

void
printf(const char *fmt, ...)
{
 7d0:	711d                	addi	sp,sp,-96
 7d2:	ec06                	sd	ra,24(sp)
 7d4:	e822                	sd	s0,16(sp)
 7d6:	1000                	addi	s0,sp,32
 7d8:	e40c                	sd	a1,8(s0)
 7da:	e810                	sd	a2,16(s0)
 7dc:	ec14                	sd	a3,24(s0)
 7de:	f018                	sd	a4,32(s0)
 7e0:	f41c                	sd	a5,40(s0)
 7e2:	03043823          	sd	a6,48(s0)
 7e6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ea:	00840613          	addi	a2,s0,8
 7ee:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f2:	85aa                	mv	a1,a0
 7f4:	4505                	li	a0,1
 7f6:	00000097          	auipc	ra,0x0
 7fa:	dce080e7          	jalr	-562(ra) # 5c4 <vprintf>
}
 7fe:	60e2                	ld	ra,24(sp)
 800:	6442                	ld	s0,16(sp)
 802:	6125                	addi	sp,sp,96
 804:	8082                	ret

0000000000000806 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 806:	1141                	addi	sp,sp,-16
 808:	e422                	sd	s0,8(sp)
 80a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 810:	00000797          	auipc	a5,0x0
 814:	2907b783          	ld	a5,656(a5) # aa0 <freep>
 818:	a02d                	j	842 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 81a:	4618                	lw	a4,8(a2)
 81c:	9f2d                	addw	a4,a4,a1
 81e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 822:	6398                	ld	a4,0(a5)
 824:	6310                	ld	a2,0(a4)
 826:	a83d                	j	864 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 828:	ff852703          	lw	a4,-8(a0)
 82c:	9f31                	addw	a4,a4,a2
 82e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 830:	ff053683          	ld	a3,-16(a0)
 834:	a091                	j	878 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 836:	6398                	ld	a4,0(a5)
 838:	00e7e463          	bltu	a5,a4,840 <free+0x3a>
 83c:	00e6ea63          	bltu	a3,a4,850 <free+0x4a>
{
 840:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 842:	fed7fae3          	bgeu	a5,a3,836 <free+0x30>
 846:	6398                	ld	a4,0(a5)
 848:	00e6e463          	bltu	a3,a4,850 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84c:	fee7eae3          	bltu	a5,a4,840 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 850:	ff852583          	lw	a1,-8(a0)
 854:	6390                	ld	a2,0(a5)
 856:	02059813          	slli	a6,a1,0x20
 85a:	01c85713          	srli	a4,a6,0x1c
 85e:	9736                	add	a4,a4,a3
 860:	fae60de3          	beq	a2,a4,81a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 864:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 868:	4790                	lw	a2,8(a5)
 86a:	02061593          	slli	a1,a2,0x20
 86e:	01c5d713          	srli	a4,a1,0x1c
 872:	973e                	add	a4,a4,a5
 874:	fae68ae3          	beq	a3,a4,828 <free+0x22>
    p->s.ptr = bp->s.ptr;
 878:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 87a:	00000717          	auipc	a4,0x0
 87e:	22f73323          	sd	a5,550(a4) # aa0 <freep>
}
 882:	6422                	ld	s0,8(sp)
 884:	0141                	addi	sp,sp,16
 886:	8082                	ret

0000000000000888 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 888:	7139                	addi	sp,sp,-64
 88a:	fc06                	sd	ra,56(sp)
 88c:	f822                	sd	s0,48(sp)
 88e:	f426                	sd	s1,40(sp)
 890:	f04a                	sd	s2,32(sp)
 892:	ec4e                	sd	s3,24(sp)
 894:	e852                	sd	s4,16(sp)
 896:	e456                	sd	s5,8(sp)
 898:	e05a                	sd	s6,0(sp)
 89a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89c:	02051493          	slli	s1,a0,0x20
 8a0:	9081                	srli	s1,s1,0x20
 8a2:	04bd                	addi	s1,s1,15
 8a4:	8091                	srli	s1,s1,0x4
 8a6:	0014899b          	addiw	s3,s1,1
 8aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ac:	00000517          	auipc	a0,0x0
 8b0:	1f453503          	ld	a0,500(a0) # aa0 <freep>
 8b4:	c515                	beqz	a0,8e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b8:	4798                	lw	a4,8(a5)
 8ba:	02977f63          	bgeu	a4,s1,8f8 <malloc+0x70>
 8be:	8a4e                	mv	s4,s3
 8c0:	0009871b          	sext.w	a4,s3
 8c4:	6685                	lui	a3,0x1
 8c6:	00d77363          	bgeu	a4,a3,8cc <malloc+0x44>
 8ca:	6a05                	lui	s4,0x1
 8cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d4:	00000917          	auipc	s2,0x0
 8d8:	1cc90913          	addi	s2,s2,460 # aa0 <freep>
  if(p == (char*)-1)
 8dc:	5afd                	li	s5,-1
 8de:	a895                	j	952 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8e0:	00000797          	auipc	a5,0x0
 8e4:	1c878793          	addi	a5,a5,456 # aa8 <base>
 8e8:	00000717          	auipc	a4,0x0
 8ec:	1af73c23          	sd	a5,440(a4) # aa0 <freep>
 8f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f6:	b7e1                	j	8be <malloc+0x36>
      if(p->s.size == nunits)
 8f8:	02e48c63          	beq	s1,a4,930 <malloc+0xa8>
        p->s.size -= nunits;
 8fc:	4137073b          	subw	a4,a4,s3
 900:	c798                	sw	a4,8(a5)
        p += p->s.size;
 902:	02071693          	slli	a3,a4,0x20
 906:	01c6d713          	srli	a4,a3,0x1c
 90a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 910:	00000717          	auipc	a4,0x0
 914:	18a73823          	sd	a0,400(a4) # aa0 <freep>
      return (void*)(p + 1);
 918:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 91c:	70e2                	ld	ra,56(sp)
 91e:	7442                	ld	s0,48(sp)
 920:	74a2                	ld	s1,40(sp)
 922:	7902                	ld	s2,32(sp)
 924:	69e2                	ld	s3,24(sp)
 926:	6a42                	ld	s4,16(sp)
 928:	6aa2                	ld	s5,8(sp)
 92a:	6b02                	ld	s6,0(sp)
 92c:	6121                	addi	sp,sp,64
 92e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 930:	6398                	ld	a4,0(a5)
 932:	e118                	sd	a4,0(a0)
 934:	bff1                	j	910 <malloc+0x88>
  hp->s.size = nu;
 936:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 93a:	0541                	addi	a0,a0,16
 93c:	00000097          	auipc	ra,0x0
 940:	eca080e7          	jalr	-310(ra) # 806 <free>
  return freep;
 944:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 948:	d971                	beqz	a0,91c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94c:	4798                	lw	a4,8(a5)
 94e:	fa9775e3          	bgeu	a4,s1,8f8 <malloc+0x70>
    if(p == freep)
 952:	00093703          	ld	a4,0(s2)
 956:	853e                	mv	a0,a5
 958:	fef719e3          	bne	a4,a5,94a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 95c:	8552                	mv	a0,s4
 95e:	00000097          	auipc	ra,0x0
 962:	ae0080e7          	jalr	-1312(ra) # 43e <sbrk>
  if(p == (char*)-1)
 966:	fd5518e3          	bne	a0,s5,936 <malloc+0xae>
        return 0;
 96a:	4501                	li	a0,0
 96c:	bf45                	j	91c <malloc+0x94>
