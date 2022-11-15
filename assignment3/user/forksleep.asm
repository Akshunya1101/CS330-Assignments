
user/_forksleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int m, n, x;

  if (argc != 3) {
   c:	478d                	li	a5,3
   e:	02f50063          	beq	a0,a5,2e <main+0x2e>
     fprintf(2, "syntax: forksleep m n\nAborting...\n");
  12:	00001597          	auipc	a1,0x1
  16:	93658593          	addi	a1,a1,-1738 # 948 <malloc+0xe6>
  1a:	4509                	li	a0,2
  1c:	00000097          	auipc	ra,0x0
  20:	760080e7          	jalr	1888(ra) # 77c <fprintf>
     exit(0);
  24:	4501                	li	a0,0
  26:	00000097          	auipc	ra,0x0
  2a:	36a080e7          	jalr	874(ra) # 390 <exit>
  2e:	84ae                	mv	s1,a1
  }

  m = atoi(argv[1]);
  30:	6588                	ld	a0,8(a1)
  32:	00000097          	auipc	ra,0x0
  36:	264080e7          	jalr	612(ra) # 296 <atoi>
  3a:	892a                	mv	s2,a0
  if (m <= 0) {
  3c:	02a05b63          	blez	a0,72 <main+0x72>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  n = atoi(argv[2]);
  40:	6888                	ld	a0,16(s1)
  42:	00000097          	auipc	ra,0x0
  46:	254080e7          	jalr	596(ra) # 296 <atoi>
  4a:	84aa                	mv	s1,a0
  if ((n != 0) && (n != 1)) {
  4c:	0005071b          	sext.w	a4,a0
  50:	4785                	li	a5,1
  52:	02e7fe63          	bgeu	a5,a4,8e <main+0x8e>
     fprintf(2, "Invalid input\nAborting...\n");
  56:	00001597          	auipc	a1,0x1
  5a:	91a58593          	addi	a1,a1,-1766 # 970 <malloc+0x10e>
  5e:	4509                	li	a0,2
  60:	00000097          	auipc	ra,0x0
  64:	71c080e7          	jalr	1820(ra) # 77c <fprintf>
     exit(0);
  68:	4501                	li	a0,0
  6a:	00000097          	auipc	ra,0x0
  6e:	326080e7          	jalr	806(ra) # 390 <exit>
     fprintf(2, "Invalid input\nAborting...\n");
  72:	00001597          	auipc	a1,0x1
  76:	8fe58593          	addi	a1,a1,-1794 # 970 <malloc+0x10e>
  7a:	4509                	li	a0,2
  7c:	00000097          	auipc	ra,0x0
  80:	700080e7          	jalr	1792(ra) # 77c <fprintf>
     exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	30a080e7          	jalr	778(ra) # 390 <exit>
  }

  x = fork();
  8e:	00000097          	auipc	ra,0x0
  92:	2fa080e7          	jalr	762(ra) # 388 <fork>
  if (x < 0) {
  96:	02054d63          	bltz	a0,d0 <main+0xd0>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  9a:	04a05f63          	blez	a0,f8 <main+0xf8>
     if (n) sleep(m);
  9e:	e4b9                	bnez	s1,ec <main+0xec>
     fprintf(1, "%d: Parent.\n", getpid());
  a0:	00000097          	auipc	ra,0x0
  a4:	370080e7          	jalr	880(ra) # 410 <getpid>
  a8:	862a                	mv	a2,a0
  aa:	00001597          	auipc	a1,0x1
  ae:	90658593          	addi	a1,a1,-1786 # 9b0 <malloc+0x14e>
  b2:	4505                	li	a0,1
  b4:	00000097          	auipc	ra,0x0
  b8:	6c8080e7          	jalr	1736(ra) # 77c <fprintf>
     wait(0);
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	2da080e7          	jalr	730(ra) # 398 <wait>
  else {
     if (!n) sleep(m);
     fprintf(1, "%d: Child.\n", getpid());
  }

  exit(0);
  c6:	4501                	li	a0,0
  c8:	00000097          	auipc	ra,0x0
  cc:	2c8080e7          	jalr	712(ra) # 390 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
  d0:	00001597          	auipc	a1,0x1
  d4:	8c058593          	addi	a1,a1,-1856 # 990 <malloc+0x12e>
  d8:	4509                	li	a0,2
  da:	00000097          	auipc	ra,0x0
  de:	6a2080e7          	jalr	1698(ra) # 77c <fprintf>
     exit(0);
  e2:	4501                	li	a0,0
  e4:	00000097          	auipc	ra,0x0
  e8:	2ac080e7          	jalr	684(ra) # 390 <exit>
     if (n) sleep(m);
  ec:	854a                	mv	a0,s2
  ee:	00000097          	auipc	ra,0x0
  f2:	332080e7          	jalr	818(ra) # 420 <sleep>
  f6:	b76d                	j	a0 <main+0xa0>
     if (!n) sleep(m);
  f8:	c085                	beqz	s1,118 <main+0x118>
     fprintf(1, "%d: Child.\n", getpid());
  fa:	00000097          	auipc	ra,0x0
  fe:	316080e7          	jalr	790(ra) # 410 <getpid>
 102:	862a                	mv	a2,a0
 104:	00001597          	auipc	a1,0x1
 108:	8bc58593          	addi	a1,a1,-1860 # 9c0 <malloc+0x15e>
 10c:	4505                	li	a0,1
 10e:	00000097          	auipc	ra,0x0
 112:	66e080e7          	jalr	1646(ra) # 77c <fprintf>
 116:	bf45                	j	c6 <main+0xc6>
     if (!n) sleep(m);
 118:	854a                	mv	a0,s2
 11a:	00000097          	auipc	ra,0x0
 11e:	306080e7          	jalr	774(ra) # 420 <sleep>
 122:	bfe1                	j	fa <main+0xfa>

0000000000000124 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12a:	87aa                	mv	a5,a0
 12c:	0585                	addi	a1,a1,1
 12e:	0785                	addi	a5,a5,1
 130:	fff5c703          	lbu	a4,-1(a1)
 134:	fee78fa3          	sb	a4,-1(a5)
 138:	fb75                	bnez	a4,12c <strcpy+0x8>
    ;
  return os;
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 140:	1141                	addi	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	cb91                	beqz	a5,15e <strcmp+0x1e>
 14c:	0005c703          	lbu	a4,0(a1)
 150:	00f71763          	bne	a4,a5,15e <strcmp+0x1e>
    p++, q++;
 154:	0505                	addi	a0,a0,1
 156:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	fbe5                	bnez	a5,14c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 15e:	0005c503          	lbu	a0,0(a1)
}
 162:	40a7853b          	subw	a0,a5,a0
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret

000000000000016c <strlen>:

uint
strlen(const char *s)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 172:	00054783          	lbu	a5,0(a0)
 176:	cf91                	beqz	a5,192 <strlen+0x26>
 178:	0505                	addi	a0,a0,1
 17a:	87aa                	mv	a5,a0
 17c:	4685                	li	a3,1
 17e:	9e89                	subw	a3,a3,a0
 180:	00f6853b          	addw	a0,a3,a5
 184:	0785                	addi	a5,a5,1
 186:	fff7c703          	lbu	a4,-1(a5)
 18a:	fb7d                	bnez	a4,180 <strlen+0x14>
    ;
  return n;
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret
  for(n = 0; s[n]; n++)
 192:	4501                	li	a0,0
 194:	bfe5                	j	18c <strlen+0x20>

0000000000000196 <memset>:

void*
memset(void *dst, int c, uint n)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19c:	ca19                	beqz	a2,1b2 <memset+0x1c>
 19e:	87aa                	mv	a5,a0
 1a0:	1602                	slli	a2,a2,0x20
 1a2:	9201                	srli	a2,a2,0x20
 1a4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1a8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ac:	0785                	addi	a5,a5,1
 1ae:	fee79de3          	bne	a5,a4,1a8 <memset+0x12>
  }
  return dst;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret

00000000000001b8 <strchr>:

char*
strchr(const char *s, char c)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e422                	sd	s0,8(sp)
 1bc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	cb99                	beqz	a5,1d8 <strchr+0x20>
    if(*s == c)
 1c4:	00f58763          	beq	a1,a5,1d2 <strchr+0x1a>
  for(; *s; s++)
 1c8:	0505                	addi	a0,a0,1
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbfd                	bnez	a5,1c4 <strchr+0xc>
      return (char*)s;
  return 0;
 1d0:	4501                	li	a0,0
}
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret
  return 0;
 1d8:	4501                	li	a0,0
 1da:	bfe5                	j	1d2 <strchr+0x1a>

00000000000001dc <gets>:

char*
gets(char *buf, int max)
{
 1dc:	711d                	addi	sp,sp,-96
 1de:	ec86                	sd	ra,88(sp)
 1e0:	e8a2                	sd	s0,80(sp)
 1e2:	e4a6                	sd	s1,72(sp)
 1e4:	e0ca                	sd	s2,64(sp)
 1e6:	fc4e                	sd	s3,56(sp)
 1e8:	f852                	sd	s4,48(sp)
 1ea:	f456                	sd	s5,40(sp)
 1ec:	f05a                	sd	s6,32(sp)
 1ee:	ec5e                	sd	s7,24(sp)
 1f0:	1080                	addi	s0,sp,96
 1f2:	8baa                	mv	s7,a0
 1f4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f6:	892a                	mv	s2,a0
 1f8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fa:	4aa9                	li	s5,10
 1fc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1fe:	89a6                	mv	s3,s1
 200:	2485                	addiw	s1,s1,1
 202:	0344d863          	bge	s1,s4,232 <gets+0x56>
    cc = read(0, &c, 1);
 206:	4605                	li	a2,1
 208:	faf40593          	addi	a1,s0,-81
 20c:	4501                	li	a0,0
 20e:	00000097          	auipc	ra,0x0
 212:	19a080e7          	jalr	410(ra) # 3a8 <read>
    if(cc < 1)
 216:	00a05e63          	blez	a0,232 <gets+0x56>
    buf[i++] = c;
 21a:	faf44783          	lbu	a5,-81(s0)
 21e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 222:	01578763          	beq	a5,s5,230 <gets+0x54>
 226:	0905                	addi	s2,s2,1
 228:	fd679be3          	bne	a5,s6,1fe <gets+0x22>
  for(i=0; i+1 < max; ){
 22c:	89a6                	mv	s3,s1
 22e:	a011                	j	232 <gets+0x56>
 230:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 232:	99de                	add	s3,s3,s7
 234:	00098023          	sb	zero,0(s3)
  return buf;
}
 238:	855e                	mv	a0,s7
 23a:	60e6                	ld	ra,88(sp)
 23c:	6446                	ld	s0,80(sp)
 23e:	64a6                	ld	s1,72(sp)
 240:	6906                	ld	s2,64(sp)
 242:	79e2                	ld	s3,56(sp)
 244:	7a42                	ld	s4,48(sp)
 246:	7aa2                	ld	s5,40(sp)
 248:	7b02                	ld	s6,32(sp)
 24a:	6be2                	ld	s7,24(sp)
 24c:	6125                	addi	sp,sp,96
 24e:	8082                	ret

0000000000000250 <stat>:

int
stat(const char *n, struct stat *st)
{
 250:	1101                	addi	sp,sp,-32
 252:	ec06                	sd	ra,24(sp)
 254:	e822                	sd	s0,16(sp)
 256:	e426                	sd	s1,8(sp)
 258:	e04a                	sd	s2,0(sp)
 25a:	1000                	addi	s0,sp,32
 25c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25e:	4581                	li	a1,0
 260:	00000097          	auipc	ra,0x0
 264:	170080e7          	jalr	368(ra) # 3d0 <open>
  if(fd < 0)
 268:	02054563          	bltz	a0,292 <stat+0x42>
 26c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26e:	85ca                	mv	a1,s2
 270:	00000097          	auipc	ra,0x0
 274:	178080e7          	jalr	376(ra) # 3e8 <fstat>
 278:	892a                	mv	s2,a0
  close(fd);
 27a:	8526                	mv	a0,s1
 27c:	00000097          	auipc	ra,0x0
 280:	13c080e7          	jalr	316(ra) # 3b8 <close>
  return r;
}
 284:	854a                	mv	a0,s2
 286:	60e2                	ld	ra,24(sp)
 288:	6442                	ld	s0,16(sp)
 28a:	64a2                	ld	s1,8(sp)
 28c:	6902                	ld	s2,0(sp)
 28e:	6105                	addi	sp,sp,32
 290:	8082                	ret
    return -1;
 292:	597d                	li	s2,-1
 294:	bfc5                	j	284 <stat+0x34>

0000000000000296 <atoi>:

int
atoi(const char *s)
{
 296:	1141                	addi	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29c:	00054683          	lbu	a3,0(a0)
 2a0:	fd06879b          	addiw	a5,a3,-48
 2a4:	0ff7f793          	zext.b	a5,a5
 2a8:	4625                	li	a2,9
 2aa:	02f66863          	bltu	a2,a5,2da <atoi+0x44>
 2ae:	872a                	mv	a4,a0
  n = 0;
 2b0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b2:	0705                	addi	a4,a4,1
 2b4:	0025179b          	slliw	a5,a0,0x2
 2b8:	9fa9                	addw	a5,a5,a0
 2ba:	0017979b          	slliw	a5,a5,0x1
 2be:	9fb5                	addw	a5,a5,a3
 2c0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c4:	00074683          	lbu	a3,0(a4)
 2c8:	fd06879b          	addiw	a5,a3,-48
 2cc:	0ff7f793          	zext.b	a5,a5
 2d0:	fef671e3          	bgeu	a2,a5,2b2 <atoi+0x1c>
  return n;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
  n = 0;
 2da:	4501                	li	a0,0
 2dc:	bfe5                	j	2d4 <atoi+0x3e>

00000000000002de <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e4:	02b57463          	bgeu	a0,a1,30c <memmove+0x2e>
    while(n-- > 0)
 2e8:	00c05f63          	blez	a2,306 <memmove+0x28>
 2ec:	1602                	slli	a2,a2,0x20
 2ee:	9201                	srli	a2,a2,0x20
 2f0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f6:	0585                	addi	a1,a1,1
 2f8:	0705                	addi	a4,a4,1
 2fa:	fff5c683          	lbu	a3,-1(a1)
 2fe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 302:	fee79ae3          	bne	a5,a4,2f6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
    dst += n;
 30c:	00c50733          	add	a4,a0,a2
    src += n;
 310:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 312:	fec05ae3          	blez	a2,306 <memmove+0x28>
 316:	fff6079b          	addiw	a5,a2,-1
 31a:	1782                	slli	a5,a5,0x20
 31c:	9381                	srli	a5,a5,0x20
 31e:	fff7c793          	not	a5,a5
 322:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 324:	15fd                	addi	a1,a1,-1
 326:	177d                	addi	a4,a4,-1
 328:	0005c683          	lbu	a3,0(a1)
 32c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 330:	fee79ae3          	bne	a5,a4,324 <memmove+0x46>
 334:	bfc9                	j	306 <memmove+0x28>

0000000000000336 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33c:	ca05                	beqz	a2,36c <memcmp+0x36>
 33e:	fff6069b          	addiw	a3,a2,-1
 342:	1682                	slli	a3,a3,0x20
 344:	9281                	srli	a3,a3,0x20
 346:	0685                	addi	a3,a3,1
 348:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 34a:	00054783          	lbu	a5,0(a0)
 34e:	0005c703          	lbu	a4,0(a1)
 352:	00e79863          	bne	a5,a4,362 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 356:	0505                	addi	a0,a0,1
    p2++;
 358:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 35a:	fed518e3          	bne	a0,a3,34a <memcmp+0x14>
  }
  return 0;
 35e:	4501                	li	a0,0
 360:	a019                	j	366 <memcmp+0x30>
      return *p1 - *p2;
 362:	40e7853b          	subw	a0,a5,a4
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret
  return 0;
 36c:	4501                	li	a0,0
 36e:	bfe5                	j	366 <memcmp+0x30>

0000000000000370 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 378:	00000097          	auipc	ra,0x0
 37c:	f66080e7          	jalr	-154(ra) # 2de <memmove>
}
 380:	60a2                	ld	ra,8(sp)
 382:	6402                	ld	s0,0(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 388:	4885                	li	a7,1
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exit>:
.global exit
exit:
 li a7, SYS_exit
 390:	4889                	li	a7,2
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <wait>:
.global wait
wait:
 li a7, SYS_wait
 398:	488d                	li	a7,3
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a0:	4891                	li	a7,4
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <read>:
.global read
read:
 li a7, SYS_read
 3a8:	4895                	li	a7,5
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <write>:
.global write
write:
 li a7, SYS_write
 3b0:	48c1                	li	a7,16
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <close>:
.global close
close:
 li a7, SYS_close
 3b8:	48d5                	li	a7,21
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c0:	4899                	li	a7,6
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c8:	489d                	li	a7,7
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <open>:
.global open
open:
 li a7, SYS_open
 3d0:	48bd                	li	a7,15
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d8:	48c5                	li	a7,17
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e0:	48c9                	li	a7,18
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e8:	48a1                	li	a7,8
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <link>:
.global link
link:
 li a7, SYS_link
 3f0:	48cd                	li	a7,19
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f8:	48d1                	li	a7,20
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 400:	48a5                	li	a7,9
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <dup>:
.global dup
dup:
 li a7, SYS_dup
 408:	48a9                	li	a7,10
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 410:	48ad                	li	a7,11
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 418:	48b1                	li	a7,12
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 420:	48b5                	li	a7,13
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 428:	48b9                	li	a7,14
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 430:	48d9                	li	a7,22
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <yield>:
.global yield
yield:
 li a7, SYS_yield
 438:	48dd                	li	a7,23
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 440:	48e1                	li	a7,24
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 448:	48e5                	li	a7,25
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 450:	48e9                	li	a7,26
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <ps>:
.global ps
ps:
 li a7, SYS_ps
 458:	48ed                	li	a7,27
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 460:	48f1                	li	a7,28
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 468:	48f5                	li	a7,29
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 470:	48f9                	li	a7,30
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 478:	02100893          	li	a7,33
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 482:	48fd                	li	a7,31
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 48a:	02000893          	li	a7,32
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 494:	02200893          	li	a7,34
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 49e:	02300893          	li	a7,35
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 4a8:	02400893          	li	a7,36
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 4b2:	02500893          	li	a7,37
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 4bc:	02700893          	li	a7,39
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 4c6:	02600893          	li	a7,38
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d0:	1101                	addi	sp,sp,-32
 4d2:	ec06                	sd	ra,24(sp)
 4d4:	e822                	sd	s0,16(sp)
 4d6:	1000                	addi	s0,sp,32
 4d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4dc:	4605                	li	a2,1
 4de:	fef40593          	addi	a1,s0,-17
 4e2:	00000097          	auipc	ra,0x0
 4e6:	ece080e7          	jalr	-306(ra) # 3b0 <write>
}
 4ea:	60e2                	ld	ra,24(sp)
 4ec:	6442                	ld	s0,16(sp)
 4ee:	6105                	addi	sp,sp,32
 4f0:	8082                	ret

00000000000004f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f2:	7139                	addi	sp,sp,-64
 4f4:	fc06                	sd	ra,56(sp)
 4f6:	f822                	sd	s0,48(sp)
 4f8:	f426                	sd	s1,40(sp)
 4fa:	f04a                	sd	s2,32(sp)
 4fc:	ec4e                	sd	s3,24(sp)
 4fe:	0080                	addi	s0,sp,64
 500:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 502:	c299                	beqz	a3,508 <printint+0x16>
 504:	0805c963          	bltz	a1,596 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 508:	2581                	sext.w	a1,a1
  neg = 0;
 50a:	4881                	li	a7,0
 50c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 510:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 512:	2601                	sext.w	a2,a2
 514:	00000517          	auipc	a0,0x0
 518:	51c50513          	addi	a0,a0,1308 # a30 <digits>
 51c:	883a                	mv	a6,a4
 51e:	2705                	addiw	a4,a4,1
 520:	02c5f7bb          	remuw	a5,a1,a2
 524:	1782                	slli	a5,a5,0x20
 526:	9381                	srli	a5,a5,0x20
 528:	97aa                	add	a5,a5,a0
 52a:	0007c783          	lbu	a5,0(a5)
 52e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 532:	0005879b          	sext.w	a5,a1
 536:	02c5d5bb          	divuw	a1,a1,a2
 53a:	0685                	addi	a3,a3,1
 53c:	fec7f0e3          	bgeu	a5,a2,51c <printint+0x2a>
  if(neg)
 540:	00088c63          	beqz	a7,558 <printint+0x66>
    buf[i++] = '-';
 544:	fd070793          	addi	a5,a4,-48
 548:	00878733          	add	a4,a5,s0
 54c:	02d00793          	li	a5,45
 550:	fef70823          	sb	a5,-16(a4)
 554:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 558:	02e05863          	blez	a4,588 <printint+0x96>
 55c:	fc040793          	addi	a5,s0,-64
 560:	00e78933          	add	s2,a5,a4
 564:	fff78993          	addi	s3,a5,-1
 568:	99ba                	add	s3,s3,a4
 56a:	377d                	addiw	a4,a4,-1
 56c:	1702                	slli	a4,a4,0x20
 56e:	9301                	srli	a4,a4,0x20
 570:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 574:	fff94583          	lbu	a1,-1(s2)
 578:	8526                	mv	a0,s1
 57a:	00000097          	auipc	ra,0x0
 57e:	f56080e7          	jalr	-170(ra) # 4d0 <putc>
  while(--i >= 0)
 582:	197d                	addi	s2,s2,-1
 584:	ff3918e3          	bne	s2,s3,574 <printint+0x82>
}
 588:	70e2                	ld	ra,56(sp)
 58a:	7442                	ld	s0,48(sp)
 58c:	74a2                	ld	s1,40(sp)
 58e:	7902                	ld	s2,32(sp)
 590:	69e2                	ld	s3,24(sp)
 592:	6121                	addi	sp,sp,64
 594:	8082                	ret
    x = -xx;
 596:	40b005bb          	negw	a1,a1
    neg = 1;
 59a:	4885                	li	a7,1
    x = -xx;
 59c:	bf85                	j	50c <printint+0x1a>

000000000000059e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 59e:	7119                	addi	sp,sp,-128
 5a0:	fc86                	sd	ra,120(sp)
 5a2:	f8a2                	sd	s0,112(sp)
 5a4:	f4a6                	sd	s1,104(sp)
 5a6:	f0ca                	sd	s2,96(sp)
 5a8:	ecce                	sd	s3,88(sp)
 5aa:	e8d2                	sd	s4,80(sp)
 5ac:	e4d6                	sd	s5,72(sp)
 5ae:	e0da                	sd	s6,64(sp)
 5b0:	fc5e                	sd	s7,56(sp)
 5b2:	f862                	sd	s8,48(sp)
 5b4:	f466                	sd	s9,40(sp)
 5b6:	f06a                	sd	s10,32(sp)
 5b8:	ec6e                	sd	s11,24(sp)
 5ba:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5bc:	0005c903          	lbu	s2,0(a1)
 5c0:	18090f63          	beqz	s2,75e <vprintf+0x1c0>
 5c4:	8aaa                	mv	s5,a0
 5c6:	8b32                	mv	s6,a2
 5c8:	00158493          	addi	s1,a1,1
  state = 0;
 5cc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ce:	02500a13          	li	s4,37
 5d2:	4c55                	li	s8,21
 5d4:	00000c97          	auipc	s9,0x0
 5d8:	404c8c93          	addi	s9,s9,1028 # 9d8 <malloc+0x176>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5dc:	02800d93          	li	s11,40
  putc(fd, 'x');
 5e0:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e2:	00000b97          	auipc	s7,0x0
 5e6:	44eb8b93          	addi	s7,s7,1102 # a30 <digits>
 5ea:	a839                	j	608 <vprintf+0x6a>
        putc(fd, c);
 5ec:	85ca                	mv	a1,s2
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	ee0080e7          	jalr	-288(ra) # 4d0 <putc>
 5f8:	a019                	j	5fe <vprintf+0x60>
    } else if(state == '%'){
 5fa:	01498d63          	beq	s3,s4,614 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5fe:	0485                	addi	s1,s1,1
 600:	fff4c903          	lbu	s2,-1(s1)
 604:	14090d63          	beqz	s2,75e <vprintf+0x1c0>
    if(state == 0){
 608:	fe0999e3          	bnez	s3,5fa <vprintf+0x5c>
      if(c == '%'){
 60c:	ff4910e3          	bne	s2,s4,5ec <vprintf+0x4e>
        state = '%';
 610:	89d2                	mv	s3,s4
 612:	b7f5                	j	5fe <vprintf+0x60>
      if(c == 'd'){
 614:	11490c63          	beq	s2,s4,72c <vprintf+0x18e>
 618:	f9d9079b          	addiw	a5,s2,-99
 61c:	0ff7f793          	zext.b	a5,a5
 620:	10fc6e63          	bltu	s8,a5,73c <vprintf+0x19e>
 624:	f9d9079b          	addiw	a5,s2,-99
 628:	0ff7f713          	zext.b	a4,a5
 62c:	10ec6863          	bltu	s8,a4,73c <vprintf+0x19e>
 630:	00271793          	slli	a5,a4,0x2
 634:	97e6                	add	a5,a5,s9
 636:	439c                	lw	a5,0(a5)
 638:	97e6                	add	a5,a5,s9
 63a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 63c:	008b0913          	addi	s2,s6,8
 640:	4685                	li	a3,1
 642:	4629                	li	a2,10
 644:	000b2583          	lw	a1,0(s6)
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	ea8080e7          	jalr	-344(ra) # 4f2 <printint>
 652:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 654:	4981                	li	s3,0
 656:	b765                	j	5fe <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	008b0913          	addi	s2,s6,8
 65c:	4681                	li	a3,0
 65e:	4629                	li	a2,10
 660:	000b2583          	lw	a1,0(s6)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e8c080e7          	jalr	-372(ra) # 4f2 <printint>
 66e:	8b4a                	mv	s6,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	b771                	j	5fe <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 674:	008b0913          	addi	s2,s6,8
 678:	4681                	li	a3,0
 67a:	866a                	mv	a2,s10
 67c:	000b2583          	lw	a1,0(s6)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e70080e7          	jalr	-400(ra) # 4f2 <printint>
 68a:	8b4a                	mv	s6,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bf85                	j	5fe <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 690:	008b0793          	addi	a5,s6,8
 694:	f8f43423          	sd	a5,-120(s0)
 698:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 69c:	03000593          	li	a1,48
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e2e080e7          	jalr	-466(ra) # 4d0 <putc>
  putc(fd, 'x');
 6aa:	07800593          	li	a1,120
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e20080e7          	jalr	-480(ra) # 4d0 <putc>
 6b8:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ba:	03c9d793          	srli	a5,s3,0x3c
 6be:	97de                	add	a5,a5,s7
 6c0:	0007c583          	lbu	a1,0(a5)
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	e0a080e7          	jalr	-502(ra) # 4d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ce:	0992                	slli	s3,s3,0x4
 6d0:	397d                	addiw	s2,s2,-1
 6d2:	fe0914e3          	bnez	s2,6ba <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6d6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b70d                	j	5fe <vprintf+0x60>
        s = va_arg(ap, char*);
 6de:	008b0913          	addi	s2,s6,8
 6e2:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6e6:	02098163          	beqz	s3,708 <vprintf+0x16a>
        while(*s != 0){
 6ea:	0009c583          	lbu	a1,0(s3)
 6ee:	c5ad                	beqz	a1,758 <vprintf+0x1ba>
          putc(fd, *s);
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	dde080e7          	jalr	-546(ra) # 4d0 <putc>
          s++;
 6fa:	0985                	addi	s3,s3,1
        while(*s != 0){
 6fc:	0009c583          	lbu	a1,0(s3)
 700:	f9e5                	bnez	a1,6f0 <vprintf+0x152>
        s = va_arg(ap, char*);
 702:	8b4a                	mv	s6,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	bde5                	j	5fe <vprintf+0x60>
          s = "(null)";
 708:	00000997          	auipc	s3,0x0
 70c:	2c898993          	addi	s3,s3,712 # 9d0 <malloc+0x16e>
        while(*s != 0){
 710:	85ee                	mv	a1,s11
 712:	bff9                	j	6f0 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 714:	008b0913          	addi	s2,s6,8
 718:	000b4583          	lbu	a1,0(s6)
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	db2080e7          	jalr	-590(ra) # 4d0 <putc>
 726:	8b4a                	mv	s6,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	bdd1                	j	5fe <vprintf+0x60>
        putc(fd, c);
 72c:	85d2                	mv	a1,s4
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	da0080e7          	jalr	-608(ra) # 4d0 <putc>
      state = 0;
 738:	4981                	li	s3,0
 73a:	b5d1                	j	5fe <vprintf+0x60>
        putc(fd, '%');
 73c:	85d2                	mv	a1,s4
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	d90080e7          	jalr	-624(ra) # 4d0 <putc>
        putc(fd, c);
 748:	85ca                	mv	a1,s2
 74a:	8556                	mv	a0,s5
 74c:	00000097          	auipc	ra,0x0
 750:	d84080e7          	jalr	-636(ra) # 4d0 <putc>
      state = 0;
 754:	4981                	li	s3,0
 756:	b565                	j	5fe <vprintf+0x60>
        s = va_arg(ap, char*);
 758:	8b4a                	mv	s6,s2
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b54d                	j	5fe <vprintf+0x60>
    }
  }
}
 75e:	70e6                	ld	ra,120(sp)
 760:	7446                	ld	s0,112(sp)
 762:	74a6                	ld	s1,104(sp)
 764:	7906                	ld	s2,96(sp)
 766:	69e6                	ld	s3,88(sp)
 768:	6a46                	ld	s4,80(sp)
 76a:	6aa6                	ld	s5,72(sp)
 76c:	6b06                	ld	s6,64(sp)
 76e:	7be2                	ld	s7,56(sp)
 770:	7c42                	ld	s8,48(sp)
 772:	7ca2                	ld	s9,40(sp)
 774:	7d02                	ld	s10,32(sp)
 776:	6de2                	ld	s11,24(sp)
 778:	6109                	addi	sp,sp,128
 77a:	8082                	ret

000000000000077c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 77c:	715d                	addi	sp,sp,-80
 77e:	ec06                	sd	ra,24(sp)
 780:	e822                	sd	s0,16(sp)
 782:	1000                	addi	s0,sp,32
 784:	e010                	sd	a2,0(s0)
 786:	e414                	sd	a3,8(s0)
 788:	e818                	sd	a4,16(s0)
 78a:	ec1c                	sd	a5,24(s0)
 78c:	03043023          	sd	a6,32(s0)
 790:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 794:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 798:	8622                	mv	a2,s0
 79a:	00000097          	auipc	ra,0x0
 79e:	e04080e7          	jalr	-508(ra) # 59e <vprintf>
}
 7a2:	60e2                	ld	ra,24(sp)
 7a4:	6442                	ld	s0,16(sp)
 7a6:	6161                	addi	sp,sp,80
 7a8:	8082                	ret

00000000000007aa <printf>:

void
printf(const char *fmt, ...)
{
 7aa:	711d                	addi	sp,sp,-96
 7ac:	ec06                	sd	ra,24(sp)
 7ae:	e822                	sd	s0,16(sp)
 7b0:	1000                	addi	s0,sp,32
 7b2:	e40c                	sd	a1,8(s0)
 7b4:	e810                	sd	a2,16(s0)
 7b6:	ec14                	sd	a3,24(s0)
 7b8:	f018                	sd	a4,32(s0)
 7ba:	f41c                	sd	a5,40(s0)
 7bc:	03043823          	sd	a6,48(s0)
 7c0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c4:	00840613          	addi	a2,s0,8
 7c8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7cc:	85aa                	mv	a1,a0
 7ce:	4505                	li	a0,1
 7d0:	00000097          	auipc	ra,0x0
 7d4:	dce080e7          	jalr	-562(ra) # 59e <vprintf>
}
 7d8:	60e2                	ld	ra,24(sp)
 7da:	6442                	ld	s0,16(sp)
 7dc:	6125                	addi	sp,sp,96
 7de:	8082                	ret

00000000000007e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e0:	1141                	addi	sp,sp,-16
 7e2:	e422                	sd	s0,8(sp)
 7e4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ea:	00000797          	auipc	a5,0x0
 7ee:	25e7b783          	ld	a5,606(a5) # a48 <freep>
 7f2:	a02d                	j	81c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f4:	4618                	lw	a4,8(a2)
 7f6:	9f2d                	addw	a4,a4,a1
 7f8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fc:	6398                	ld	a4,0(a5)
 7fe:	6310                	ld	a2,0(a4)
 800:	a83d                	j	83e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 802:	ff852703          	lw	a4,-8(a0)
 806:	9f31                	addw	a4,a4,a2
 808:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 80a:	ff053683          	ld	a3,-16(a0)
 80e:	a091                	j	852 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	6398                	ld	a4,0(a5)
 812:	00e7e463          	bltu	a5,a4,81a <free+0x3a>
 816:	00e6ea63          	bltu	a3,a4,82a <free+0x4a>
{
 81a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81c:	fed7fae3          	bgeu	a5,a3,810 <free+0x30>
 820:	6398                	ld	a4,0(a5)
 822:	00e6e463          	bltu	a3,a4,82a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 826:	fee7eae3          	bltu	a5,a4,81a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 82a:	ff852583          	lw	a1,-8(a0)
 82e:	6390                	ld	a2,0(a5)
 830:	02059813          	slli	a6,a1,0x20
 834:	01c85713          	srli	a4,a6,0x1c
 838:	9736                	add	a4,a4,a3
 83a:	fae60de3          	beq	a2,a4,7f4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 83e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 842:	4790                	lw	a2,8(a5)
 844:	02061593          	slli	a1,a2,0x20
 848:	01c5d713          	srli	a4,a1,0x1c
 84c:	973e                	add	a4,a4,a5
 84e:	fae68ae3          	beq	a3,a4,802 <free+0x22>
    p->s.ptr = bp->s.ptr;
 852:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 854:	00000717          	auipc	a4,0x0
 858:	1ef73a23          	sd	a5,500(a4) # a48 <freep>
}
 85c:	6422                	ld	s0,8(sp)
 85e:	0141                	addi	sp,sp,16
 860:	8082                	ret

0000000000000862 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 862:	7139                	addi	sp,sp,-64
 864:	fc06                	sd	ra,56(sp)
 866:	f822                	sd	s0,48(sp)
 868:	f426                	sd	s1,40(sp)
 86a:	f04a                	sd	s2,32(sp)
 86c:	ec4e                	sd	s3,24(sp)
 86e:	e852                	sd	s4,16(sp)
 870:	e456                	sd	s5,8(sp)
 872:	e05a                	sd	s6,0(sp)
 874:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 876:	02051493          	slli	s1,a0,0x20
 87a:	9081                	srli	s1,s1,0x20
 87c:	04bd                	addi	s1,s1,15
 87e:	8091                	srli	s1,s1,0x4
 880:	0014899b          	addiw	s3,s1,1
 884:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 886:	00000517          	auipc	a0,0x0
 88a:	1c253503          	ld	a0,450(a0) # a48 <freep>
 88e:	c515                	beqz	a0,8ba <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 890:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 892:	4798                	lw	a4,8(a5)
 894:	02977f63          	bgeu	a4,s1,8d2 <malloc+0x70>
 898:	8a4e                	mv	s4,s3
 89a:	0009871b          	sext.w	a4,s3
 89e:	6685                	lui	a3,0x1
 8a0:	00d77363          	bgeu	a4,a3,8a6 <malloc+0x44>
 8a4:	6a05                	lui	s4,0x1
 8a6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8aa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ae:	00000917          	auipc	s2,0x0
 8b2:	19a90913          	addi	s2,s2,410 # a48 <freep>
  if(p == (char*)-1)
 8b6:	5afd                	li	s5,-1
 8b8:	a895                	j	92c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8ba:	00000797          	auipc	a5,0x0
 8be:	19678793          	addi	a5,a5,406 # a50 <base>
 8c2:	00000717          	auipc	a4,0x0
 8c6:	18f73323          	sd	a5,390(a4) # a48 <freep>
 8ca:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8cc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d0:	b7e1                	j	898 <malloc+0x36>
      if(p->s.size == nunits)
 8d2:	02e48c63          	beq	s1,a4,90a <malloc+0xa8>
        p->s.size -= nunits;
 8d6:	4137073b          	subw	a4,a4,s3
 8da:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8dc:	02071693          	slli	a3,a4,0x20
 8e0:	01c6d713          	srli	a4,a3,0x1c
 8e4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ea:	00000717          	auipc	a4,0x0
 8ee:	14a73f23          	sd	a0,350(a4) # a48 <freep>
      return (void*)(p + 1);
 8f2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f6:	70e2                	ld	ra,56(sp)
 8f8:	7442                	ld	s0,48(sp)
 8fa:	74a2                	ld	s1,40(sp)
 8fc:	7902                	ld	s2,32(sp)
 8fe:	69e2                	ld	s3,24(sp)
 900:	6a42                	ld	s4,16(sp)
 902:	6aa2                	ld	s5,8(sp)
 904:	6b02                	ld	s6,0(sp)
 906:	6121                	addi	sp,sp,64
 908:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 90a:	6398                	ld	a4,0(a5)
 90c:	e118                	sd	a4,0(a0)
 90e:	bff1                	j	8ea <malloc+0x88>
  hp->s.size = nu;
 910:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 914:	0541                	addi	a0,a0,16
 916:	00000097          	auipc	ra,0x0
 91a:	eca080e7          	jalr	-310(ra) # 7e0 <free>
  return freep;
 91e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 922:	d971                	beqz	a0,8f6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 924:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 926:	4798                	lw	a4,8(a5)
 928:	fa9775e3          	bgeu	a4,s1,8d2 <malloc+0x70>
    if(p == freep)
 92c:	00093703          	ld	a4,0(s2)
 930:	853e                	mv	a0,a5
 932:	fef719e3          	bne	a4,a5,924 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 936:	8552                	mv	a0,s4
 938:	00000097          	auipc	ra,0x0
 93c:	ae0080e7          	jalr	-1312(ra) # 418 <sbrk>
  if(p == (char*)-1)
 940:	fd5518e3          	bne	a0,s5,910 <malloc+0xae>
        return 0;
 944:	4501                	li	a0,0
 946:	bf45                	j	8f6 <malloc+0x94>
