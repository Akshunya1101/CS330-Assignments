
user/_barriertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	0880                	addi	s0,sp,80
  int i, j, n, r, barrier_id;

  if (argc != 3) {
  16:	478d                	li	a5,3
  18:	02f50063          	beq	a0,a5,38 <main+0x38>
     fprintf(2, "syntax: barriertest numprocs numrounds\nAborting...\n");
  1c:	00001597          	auipc	a1,0x1
  20:	90c58593          	addi	a1,a1,-1780 # 928 <malloc+0xe6>
  24:	4509                	li	a0,2
  26:	00000097          	auipc	ra,0x0
  2a:	736080e7          	jalr	1846(ra) # 75c <fprintf>
     exit(0);
  2e:	4501                	li	a0,0
  30:	00000097          	auipc	ra,0x0
  34:	340080e7          	jalr	832(ra) # 370 <exit>
  38:	84ae                	mv	s1,a1
  }

  n = atoi(argv[1]);
  3a:	6588                	ld	a0,8(a1)
  3c:	00000097          	auipc	ra,0x0
  40:	23a080e7          	jalr	570(ra) # 276 <atoi>
  44:	89aa                	mv	s3,a0
  r = atoi(argv[2]);
  46:	6888                	ld	a0,16(s1)
  48:	00000097          	auipc	ra,0x0
  4c:	22e080e7          	jalr	558(ra) # 276 <atoi>
  50:	8aaa                	mv	s5,a0
  barrier_id = barrier_alloc();
  52:	00000097          	auipc	ra,0x0
  56:	406080e7          	jalr	1030(ra) # 458 <barrier_alloc>
  5a:	8a2a                	mv	s4,a0
  fprintf(1, "%d: got barrier array id %d\n\n", getpid(), barrier_id);
  5c:	00000097          	auipc	ra,0x0
  60:	394080e7          	jalr	916(ra) # 3f0 <getpid>
  64:	862a                	mv	a2,a0
  66:	86d2                	mv	a3,s4
  68:	00001597          	auipc	a1,0x1
  6c:	8f858593          	addi	a1,a1,-1800 # 960 <malloc+0x11e>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	6ea080e7          	jalr	1770(ra) # 75c <fprintf>

  for (i=0; i<n-1; i++) {
  7a:	fff98b9b          	addiw	s7,s3,-1
  7e:	09705063          	blez	s7,fe <main+0xfe>
  82:	8b5e                	mv	s6,s7
  84:	4901                	li	s2,0
     if (fork() == 0) {
  86:	00000097          	auipc	ra,0x0
  8a:	2e2080e7          	jalr	738(ra) # 368 <fork>
  8e:	84aa                	mv	s1,a0
  90:	c531                	beqz	a0,dc <main+0xdc>
  for (i=0; i<n-1; i++) {
  92:	2905                	addiw	s2,s2,1
  94:	ff2b19e3          	bne	s6,s2,86 <main+0x86>
	   barrier(j, barrier_id, n);
	}
	exit(0);
     }
  }
  for (j=0; j<r; j++) {
  98:	01505f63          	blez	s5,b6 <main+0xb6>
  9c:	4481                	li	s1,0
     barrier(j, barrier_id, n);
  9e:	864e                	mv	a2,s3
  a0:	85d2                	mv	a1,s4
  a2:	8526                	mv	a0,s1
  a4:	00000097          	auipc	ra,0x0
  a8:	3be080e7          	jalr	958(ra) # 462 <barrier>
  for (j=0; j<r; j++) {
  ac:	2485                	addiw	s1,s1,1
  ae:	ff54c8e3          	blt	s1,s5,9e <main+0x9e>
  }
  for (i=0; i<n-1; i++) wait(0);
  b2:	01705b63          	blez	s7,c8 <main+0xc8>
  for (j=0; j<r; j++) {
  b6:	4481                	li	s1,0
  for (i=0; i<n-1; i++) wait(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	2be080e7          	jalr	702(ra) # 378 <wait>
  c2:	2485                	addiw	s1,s1,1
  c4:	ff74cae3          	blt	s1,s7,b8 <main+0xb8>
  barrier_free(barrier_id);
  c8:	8552                	mv	a0,s4
  ca:	00000097          	auipc	ra,0x0
  ce:	3a0080e7          	jalr	928(ra) # 46a <barrier_free>
  exit(0);
  d2:	4501                	li	a0,0
  d4:	00000097          	auipc	ra,0x0
  d8:	29c080e7          	jalr	668(ra) # 370 <exit>
        for (j=0; j<r; j++) {
  dc:	01505c63          	blez	s5,f4 <main+0xf4>
	   barrier(j, barrier_id, n);
  e0:	864e                	mv	a2,s3
  e2:	85d2                	mv	a1,s4
  e4:	8526                	mv	a0,s1
  e6:	00000097          	auipc	ra,0x0
  ea:	37c080e7          	jalr	892(ra) # 462 <barrier>
        for (j=0; j<r; j++) {
  ee:	2485                	addiw	s1,s1,1
  f0:	fe9a98e3          	bne	s5,s1,e0 <main+0xe0>
	exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	27a080e7          	jalr	634(ra) # 370 <exit>
  for (j=0; j<r; j++) {
  fe:	f9504fe3          	bgtz	s5,9c <main+0x9c>
 102:	b7d9                	j	c8 <main+0xc8>

0000000000000104 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10a:	87aa                	mv	a5,a0
 10c:	0585                	addi	a1,a1,1
 10e:	0785                	addi	a5,a5,1
 110:	fff5c703          	lbu	a4,-1(a1)
 114:	fee78fa3          	sb	a4,-1(a5)
 118:	fb75                	bnez	a4,10c <strcpy+0x8>
    ;
  return os;
}
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cb91                	beqz	a5,13e <strcmp+0x1e>
 12c:	0005c703          	lbu	a4,0(a1)
 130:	00f71763          	bne	a4,a5,13e <strcmp+0x1e>
    p++, q++;
 134:	0505                	addi	a0,a0,1
 136:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 138:	00054783          	lbu	a5,0(a0)
 13c:	fbe5                	bnez	a5,12c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 13e:	0005c503          	lbu	a0,0(a1)
}
 142:	40a7853b          	subw	a0,a5,a0
 146:	6422                	ld	s0,8(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret

000000000000014c <strlen>:

uint
strlen(const char *s)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 152:	00054783          	lbu	a5,0(a0)
 156:	cf91                	beqz	a5,172 <strlen+0x26>
 158:	0505                	addi	a0,a0,1
 15a:	87aa                	mv	a5,a0
 15c:	4685                	li	a3,1
 15e:	9e89                	subw	a3,a3,a0
 160:	00f6853b          	addw	a0,a3,a5
 164:	0785                	addi	a5,a5,1
 166:	fff7c703          	lbu	a4,-1(a5)
 16a:	fb7d                	bnez	a4,160 <strlen+0x14>
    ;
  return n;
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret
  for(n = 0; s[n]; n++)
 172:	4501                	li	a0,0
 174:	bfe5                	j	16c <strlen+0x20>

0000000000000176 <memset>:

void*
memset(void *dst, int c, uint n)
{
 176:	1141                	addi	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17c:	ca19                	beqz	a2,192 <memset+0x1c>
 17e:	87aa                	mv	a5,a0
 180:	1602                	slli	a2,a2,0x20
 182:	9201                	srli	a2,a2,0x20
 184:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 188:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 18c:	0785                	addi	a5,a5,1
 18e:	fee79de3          	bne	a5,a4,188 <memset+0x12>
  }
  return dst;
}
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strchr>:

char*
strchr(const char *s, char c)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cb99                	beqz	a5,1b8 <strchr+0x20>
    if(*s == c)
 1a4:	00f58763          	beq	a1,a5,1b2 <strchr+0x1a>
  for(; *s; s++)
 1a8:	0505                	addi	a0,a0,1
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	fbfd                	bnez	a5,1a4 <strchr+0xc>
      return (char*)s;
  return 0;
 1b0:	4501                	li	a0,0
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  return 0;
 1b8:	4501                	li	a0,0
 1ba:	bfe5                	j	1b2 <strchr+0x1a>

00000000000001bc <gets>:

char*
gets(char *buf, int max)
{
 1bc:	711d                	addi	sp,sp,-96
 1be:	ec86                	sd	ra,88(sp)
 1c0:	e8a2                	sd	s0,80(sp)
 1c2:	e4a6                	sd	s1,72(sp)
 1c4:	e0ca                	sd	s2,64(sp)
 1c6:	fc4e                	sd	s3,56(sp)
 1c8:	f852                	sd	s4,48(sp)
 1ca:	f456                	sd	s5,40(sp)
 1cc:	f05a                	sd	s6,32(sp)
 1ce:	ec5e                	sd	s7,24(sp)
 1d0:	1080                	addi	s0,sp,96
 1d2:	8baa                	mv	s7,a0
 1d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d6:	892a                	mv	s2,a0
 1d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1da:	4aa9                	li	s5,10
 1dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1de:	89a6                	mv	s3,s1
 1e0:	2485                	addiw	s1,s1,1
 1e2:	0344d863          	bge	s1,s4,212 <gets+0x56>
    cc = read(0, &c, 1);
 1e6:	4605                	li	a2,1
 1e8:	faf40593          	addi	a1,s0,-81
 1ec:	4501                	li	a0,0
 1ee:	00000097          	auipc	ra,0x0
 1f2:	19a080e7          	jalr	410(ra) # 388 <read>
    if(cc < 1)
 1f6:	00a05e63          	blez	a0,212 <gets+0x56>
    buf[i++] = c;
 1fa:	faf44783          	lbu	a5,-81(s0)
 1fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 202:	01578763          	beq	a5,s5,210 <gets+0x54>
 206:	0905                	addi	s2,s2,1
 208:	fd679be3          	bne	a5,s6,1de <gets+0x22>
  for(i=0; i+1 < max; ){
 20c:	89a6                	mv	s3,s1
 20e:	a011                	j	212 <gets+0x56>
 210:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 212:	99de                	add	s3,s3,s7
 214:	00098023          	sb	zero,0(s3)
  return buf;
}
 218:	855e                	mv	a0,s7
 21a:	60e6                	ld	ra,88(sp)
 21c:	6446                	ld	s0,80(sp)
 21e:	64a6                	ld	s1,72(sp)
 220:	6906                	ld	s2,64(sp)
 222:	79e2                	ld	s3,56(sp)
 224:	7a42                	ld	s4,48(sp)
 226:	7aa2                	ld	s5,40(sp)
 228:	7b02                	ld	s6,32(sp)
 22a:	6be2                	ld	s7,24(sp)
 22c:	6125                	addi	sp,sp,96
 22e:	8082                	ret

0000000000000230 <stat>:

int
stat(const char *n, struct stat *st)
{
 230:	1101                	addi	sp,sp,-32
 232:	ec06                	sd	ra,24(sp)
 234:	e822                	sd	s0,16(sp)
 236:	e426                	sd	s1,8(sp)
 238:	e04a                	sd	s2,0(sp)
 23a:	1000                	addi	s0,sp,32
 23c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23e:	4581                	li	a1,0
 240:	00000097          	auipc	ra,0x0
 244:	170080e7          	jalr	368(ra) # 3b0 <open>
  if(fd < 0)
 248:	02054563          	bltz	a0,272 <stat+0x42>
 24c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 24e:	85ca                	mv	a1,s2
 250:	00000097          	auipc	ra,0x0
 254:	178080e7          	jalr	376(ra) # 3c8 <fstat>
 258:	892a                	mv	s2,a0
  close(fd);
 25a:	8526                	mv	a0,s1
 25c:	00000097          	auipc	ra,0x0
 260:	13c080e7          	jalr	316(ra) # 398 <close>
  return r;
}
 264:	854a                	mv	a0,s2
 266:	60e2                	ld	ra,24(sp)
 268:	6442                	ld	s0,16(sp)
 26a:	64a2                	ld	s1,8(sp)
 26c:	6902                	ld	s2,0(sp)
 26e:	6105                	addi	sp,sp,32
 270:	8082                	ret
    return -1;
 272:	597d                	li	s2,-1
 274:	bfc5                	j	264 <stat+0x34>

0000000000000276 <atoi>:

int
atoi(const char *s)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 27c:	00054683          	lbu	a3,0(a0)
 280:	fd06879b          	addiw	a5,a3,-48
 284:	0ff7f793          	zext.b	a5,a5
 288:	4625                	li	a2,9
 28a:	02f66863          	bltu	a2,a5,2ba <atoi+0x44>
 28e:	872a                	mv	a4,a0
  n = 0;
 290:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 292:	0705                	addi	a4,a4,1
 294:	0025179b          	slliw	a5,a0,0x2
 298:	9fa9                	addw	a5,a5,a0
 29a:	0017979b          	slliw	a5,a5,0x1
 29e:	9fb5                	addw	a5,a5,a3
 2a0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a4:	00074683          	lbu	a3,0(a4)
 2a8:	fd06879b          	addiw	a5,a3,-48
 2ac:	0ff7f793          	zext.b	a5,a5
 2b0:	fef671e3          	bgeu	a2,a5,292 <atoi+0x1c>
  return n;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret
  n = 0;
 2ba:	4501                	li	a0,0
 2bc:	bfe5                	j	2b4 <atoi+0x3e>

00000000000002be <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c4:	02b57463          	bgeu	a0,a1,2ec <memmove+0x2e>
    while(n-- > 0)
 2c8:	00c05f63          	blez	a2,2e6 <memmove+0x28>
 2cc:	1602                	slli	a2,a2,0x20
 2ce:	9201                	srli	a2,a2,0x20
 2d0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d6:	0585                	addi	a1,a1,1
 2d8:	0705                	addi	a4,a4,1
 2da:	fff5c683          	lbu	a3,-1(a1)
 2de:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e2:	fee79ae3          	bne	a5,a4,2d6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
    dst += n;
 2ec:	00c50733          	add	a4,a0,a2
    src += n;
 2f0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f2:	fec05ae3          	blez	a2,2e6 <memmove+0x28>
 2f6:	fff6079b          	addiw	a5,a2,-1
 2fa:	1782                	slli	a5,a5,0x20
 2fc:	9381                	srli	a5,a5,0x20
 2fe:	fff7c793          	not	a5,a5
 302:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 304:	15fd                	addi	a1,a1,-1
 306:	177d                	addi	a4,a4,-1
 308:	0005c683          	lbu	a3,0(a1)
 30c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 310:	fee79ae3          	bne	a5,a4,304 <memmove+0x46>
 314:	bfc9                	j	2e6 <memmove+0x28>

0000000000000316 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 31c:	ca05                	beqz	a2,34c <memcmp+0x36>
 31e:	fff6069b          	addiw	a3,a2,-1
 322:	1682                	slli	a3,a3,0x20
 324:	9281                	srli	a3,a3,0x20
 326:	0685                	addi	a3,a3,1
 328:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 32a:	00054783          	lbu	a5,0(a0)
 32e:	0005c703          	lbu	a4,0(a1)
 332:	00e79863          	bne	a5,a4,342 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 336:	0505                	addi	a0,a0,1
    p2++;
 338:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 33a:	fed518e3          	bne	a0,a3,32a <memcmp+0x14>
  }
  return 0;
 33e:	4501                	li	a0,0
 340:	a019                	j	346 <memcmp+0x30>
      return *p1 - *p2;
 342:	40e7853b          	subw	a0,a5,a4
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
  return 0;
 34c:	4501                	li	a0,0
 34e:	bfe5                	j	346 <memcmp+0x30>

0000000000000350 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e406                	sd	ra,8(sp)
 354:	e022                	sd	s0,0(sp)
 356:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 358:	00000097          	auipc	ra,0x0
 35c:	f66080e7          	jalr	-154(ra) # 2be <memmove>
}
 360:	60a2                	ld	ra,8(sp)
 362:	6402                	ld	s0,0(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret

0000000000000368 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 368:	4885                	li	a7,1
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <exit>:
.global exit
exit:
 li a7, SYS_exit
 370:	4889                	li	a7,2
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <wait>:
.global wait
wait:
 li a7, SYS_wait
 378:	488d                	li	a7,3
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 380:	4891                	li	a7,4
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <read>:
.global read
read:
 li a7, SYS_read
 388:	4895                	li	a7,5
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <write>:
.global write
write:
 li a7, SYS_write
 390:	48c1                	li	a7,16
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <close>:
.global close
close:
 li a7, SYS_close
 398:	48d5                	li	a7,21
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a0:	4899                	li	a7,6
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a8:	489d                	li	a7,7
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <open>:
.global open
open:
 li a7, SYS_open
 3b0:	48bd                	li	a7,15
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b8:	48c5                	li	a7,17
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c0:	48c9                	li	a7,18
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c8:	48a1                	li	a7,8
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <link>:
.global link
link:
 li a7, SYS_link
 3d0:	48cd                	li	a7,19
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d8:	48d1                	li	a7,20
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e0:	48a5                	li	a7,9
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e8:	48a9                	li	a7,10
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f0:	48ad                	li	a7,11
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f8:	48b1                	li	a7,12
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 400:	48b5                	li	a7,13
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 408:	48b9                	li	a7,14
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 410:	48d9                	li	a7,22
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <yield>:
.global yield
yield:
 li a7, SYS_yield
 418:	48dd                	li	a7,23
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 420:	48e1                	li	a7,24
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 428:	48e5                	li	a7,25
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 430:	48e9                	li	a7,26
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <ps>:
.global ps
ps:
 li a7, SYS_ps
 438:	48ed                	li	a7,27
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 440:	48f1                	li	a7,28
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 448:	48f5                	li	a7,29
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 450:	48f9                	li	a7,30
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 458:	02100893          	li	a7,33
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 462:	48fd                	li	a7,31
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 46a:	02000893          	li	a7,32
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 474:	02200893          	li	a7,34
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 47e:	02300893          	li	a7,35
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 488:	02400893          	li	a7,36
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 492:	02500893          	li	a7,37
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 49c:	02700893          	li	a7,39
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 4a6:	02600893          	li	a7,38
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b0:	1101                	addi	sp,sp,-32
 4b2:	ec06                	sd	ra,24(sp)
 4b4:	e822                	sd	s0,16(sp)
 4b6:	1000                	addi	s0,sp,32
 4b8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4bc:	4605                	li	a2,1
 4be:	fef40593          	addi	a1,s0,-17
 4c2:	00000097          	auipc	ra,0x0
 4c6:	ece080e7          	jalr	-306(ra) # 390 <write>
}
 4ca:	60e2                	ld	ra,24(sp)
 4cc:	6442                	ld	s0,16(sp)
 4ce:	6105                	addi	sp,sp,32
 4d0:	8082                	ret

00000000000004d2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d2:	7139                	addi	sp,sp,-64
 4d4:	fc06                	sd	ra,56(sp)
 4d6:	f822                	sd	s0,48(sp)
 4d8:	f426                	sd	s1,40(sp)
 4da:	f04a                	sd	s2,32(sp)
 4dc:	ec4e                	sd	s3,24(sp)
 4de:	0080                	addi	s0,sp,64
 4e0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e2:	c299                	beqz	a3,4e8 <printint+0x16>
 4e4:	0805c963          	bltz	a1,576 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e8:	2581                	sext.w	a1,a1
  neg = 0;
 4ea:	4881                	li	a7,0
 4ec:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f2:	2601                	sext.w	a2,a2
 4f4:	00000517          	auipc	a0,0x0
 4f8:	4ec50513          	addi	a0,a0,1260 # 9e0 <digits>
 4fc:	883a                	mv	a6,a4
 4fe:	2705                	addiw	a4,a4,1
 500:	02c5f7bb          	remuw	a5,a1,a2
 504:	1782                	slli	a5,a5,0x20
 506:	9381                	srli	a5,a5,0x20
 508:	97aa                	add	a5,a5,a0
 50a:	0007c783          	lbu	a5,0(a5)
 50e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 512:	0005879b          	sext.w	a5,a1
 516:	02c5d5bb          	divuw	a1,a1,a2
 51a:	0685                	addi	a3,a3,1
 51c:	fec7f0e3          	bgeu	a5,a2,4fc <printint+0x2a>
  if(neg)
 520:	00088c63          	beqz	a7,538 <printint+0x66>
    buf[i++] = '-';
 524:	fd070793          	addi	a5,a4,-48
 528:	00878733          	add	a4,a5,s0
 52c:	02d00793          	li	a5,45
 530:	fef70823          	sb	a5,-16(a4)
 534:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 538:	02e05863          	blez	a4,568 <printint+0x96>
 53c:	fc040793          	addi	a5,s0,-64
 540:	00e78933          	add	s2,a5,a4
 544:	fff78993          	addi	s3,a5,-1
 548:	99ba                	add	s3,s3,a4
 54a:	377d                	addiw	a4,a4,-1
 54c:	1702                	slli	a4,a4,0x20
 54e:	9301                	srli	a4,a4,0x20
 550:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 554:	fff94583          	lbu	a1,-1(s2)
 558:	8526                	mv	a0,s1
 55a:	00000097          	auipc	ra,0x0
 55e:	f56080e7          	jalr	-170(ra) # 4b0 <putc>
  while(--i >= 0)
 562:	197d                	addi	s2,s2,-1
 564:	ff3918e3          	bne	s2,s3,554 <printint+0x82>
}
 568:	70e2                	ld	ra,56(sp)
 56a:	7442                	ld	s0,48(sp)
 56c:	74a2                	ld	s1,40(sp)
 56e:	7902                	ld	s2,32(sp)
 570:	69e2                	ld	s3,24(sp)
 572:	6121                	addi	sp,sp,64
 574:	8082                	ret
    x = -xx;
 576:	40b005bb          	negw	a1,a1
    neg = 1;
 57a:	4885                	li	a7,1
    x = -xx;
 57c:	bf85                	j	4ec <printint+0x1a>

000000000000057e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57e:	7119                	addi	sp,sp,-128
 580:	fc86                	sd	ra,120(sp)
 582:	f8a2                	sd	s0,112(sp)
 584:	f4a6                	sd	s1,104(sp)
 586:	f0ca                	sd	s2,96(sp)
 588:	ecce                	sd	s3,88(sp)
 58a:	e8d2                	sd	s4,80(sp)
 58c:	e4d6                	sd	s5,72(sp)
 58e:	e0da                	sd	s6,64(sp)
 590:	fc5e                	sd	s7,56(sp)
 592:	f862                	sd	s8,48(sp)
 594:	f466                	sd	s9,40(sp)
 596:	f06a                	sd	s10,32(sp)
 598:	ec6e                	sd	s11,24(sp)
 59a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 59c:	0005c903          	lbu	s2,0(a1)
 5a0:	18090f63          	beqz	s2,73e <vprintf+0x1c0>
 5a4:	8aaa                	mv	s5,a0
 5a6:	8b32                	mv	s6,a2
 5a8:	00158493          	addi	s1,a1,1
  state = 0;
 5ac:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ae:	02500a13          	li	s4,37
 5b2:	4c55                	li	s8,21
 5b4:	00000c97          	auipc	s9,0x0
 5b8:	3d4c8c93          	addi	s9,s9,980 # 988 <malloc+0x146>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5bc:	02800d93          	li	s11,40
  putc(fd, 'x');
 5c0:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5c2:	00000b97          	auipc	s7,0x0
 5c6:	41eb8b93          	addi	s7,s7,1054 # 9e0 <digits>
 5ca:	a839                	j	5e8 <vprintf+0x6a>
        putc(fd, c);
 5cc:	85ca                	mv	a1,s2
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	ee0080e7          	jalr	-288(ra) # 4b0 <putc>
 5d8:	a019                	j	5de <vprintf+0x60>
    } else if(state == '%'){
 5da:	01498d63          	beq	s3,s4,5f4 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5de:	0485                	addi	s1,s1,1
 5e0:	fff4c903          	lbu	s2,-1(s1)
 5e4:	14090d63          	beqz	s2,73e <vprintf+0x1c0>
    if(state == 0){
 5e8:	fe0999e3          	bnez	s3,5da <vprintf+0x5c>
      if(c == '%'){
 5ec:	ff4910e3          	bne	s2,s4,5cc <vprintf+0x4e>
        state = '%';
 5f0:	89d2                	mv	s3,s4
 5f2:	b7f5                	j	5de <vprintf+0x60>
      if(c == 'd'){
 5f4:	11490c63          	beq	s2,s4,70c <vprintf+0x18e>
 5f8:	f9d9079b          	addiw	a5,s2,-99
 5fc:	0ff7f793          	zext.b	a5,a5
 600:	10fc6e63          	bltu	s8,a5,71c <vprintf+0x19e>
 604:	f9d9079b          	addiw	a5,s2,-99
 608:	0ff7f713          	zext.b	a4,a5
 60c:	10ec6863          	bltu	s8,a4,71c <vprintf+0x19e>
 610:	00271793          	slli	a5,a4,0x2
 614:	97e6                	add	a5,a5,s9
 616:	439c                	lw	a5,0(a5)
 618:	97e6                	add	a5,a5,s9
 61a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 61c:	008b0913          	addi	s2,s6,8
 620:	4685                	li	a3,1
 622:	4629                	li	a2,10
 624:	000b2583          	lw	a1,0(s6)
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	ea8080e7          	jalr	-344(ra) # 4d2 <printint>
 632:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 634:	4981                	li	s3,0
 636:	b765                	j	5de <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	008b0913          	addi	s2,s6,8
 63c:	4681                	li	a3,0
 63e:	4629                	li	a2,10
 640:	000b2583          	lw	a1,0(s6)
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e8c080e7          	jalr	-372(ra) # 4d2 <printint>
 64e:	8b4a                	mv	s6,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	b771                	j	5de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 654:	008b0913          	addi	s2,s6,8
 658:	4681                	li	a3,0
 65a:	866a                	mv	a2,s10
 65c:	000b2583          	lw	a1,0(s6)
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	e70080e7          	jalr	-400(ra) # 4d2 <printint>
 66a:	8b4a                	mv	s6,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bf85                	j	5de <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 670:	008b0793          	addi	a5,s6,8
 674:	f8f43423          	sd	a5,-120(s0)
 678:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 67c:	03000593          	li	a1,48
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e2e080e7          	jalr	-466(ra) # 4b0 <putc>
  putc(fd, 'x');
 68a:	07800593          	li	a1,120
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e20080e7          	jalr	-480(ra) # 4b0 <putc>
 698:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 69a:	03c9d793          	srli	a5,s3,0x3c
 69e:	97de                	add	a5,a5,s7
 6a0:	0007c583          	lbu	a1,0(a5)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e0a080e7          	jalr	-502(ra) # 4b0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ae:	0992                	slli	s3,s3,0x4
 6b0:	397d                	addiw	s2,s2,-1
 6b2:	fe0914e3          	bnez	s2,69a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6b6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b70d                	j	5de <vprintf+0x60>
        s = va_arg(ap, char*);
 6be:	008b0913          	addi	s2,s6,8
 6c2:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6c6:	02098163          	beqz	s3,6e8 <vprintf+0x16a>
        while(*s != 0){
 6ca:	0009c583          	lbu	a1,0(s3)
 6ce:	c5ad                	beqz	a1,738 <vprintf+0x1ba>
          putc(fd, *s);
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	dde080e7          	jalr	-546(ra) # 4b0 <putc>
          s++;
 6da:	0985                	addi	s3,s3,1
        while(*s != 0){
 6dc:	0009c583          	lbu	a1,0(s3)
 6e0:	f9e5                	bnez	a1,6d0 <vprintf+0x152>
        s = va_arg(ap, char*);
 6e2:	8b4a                	mv	s6,s2
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	bde5                	j	5de <vprintf+0x60>
          s = "(null)";
 6e8:	00000997          	auipc	s3,0x0
 6ec:	29898993          	addi	s3,s3,664 # 980 <malloc+0x13e>
        while(*s != 0){
 6f0:	85ee                	mv	a1,s11
 6f2:	bff9                	j	6d0 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6f4:	008b0913          	addi	s2,s6,8
 6f8:	000b4583          	lbu	a1,0(s6)
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	db2080e7          	jalr	-590(ra) # 4b0 <putc>
 706:	8b4a                	mv	s6,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bdd1                	j	5de <vprintf+0x60>
        putc(fd, c);
 70c:	85d2                	mv	a1,s4
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	da0080e7          	jalr	-608(ra) # 4b0 <putc>
      state = 0;
 718:	4981                	li	s3,0
 71a:	b5d1                	j	5de <vprintf+0x60>
        putc(fd, '%');
 71c:	85d2                	mv	a1,s4
 71e:	8556                	mv	a0,s5
 720:	00000097          	auipc	ra,0x0
 724:	d90080e7          	jalr	-624(ra) # 4b0 <putc>
        putc(fd, c);
 728:	85ca                	mv	a1,s2
 72a:	8556                	mv	a0,s5
 72c:	00000097          	auipc	ra,0x0
 730:	d84080e7          	jalr	-636(ra) # 4b0 <putc>
      state = 0;
 734:	4981                	li	s3,0
 736:	b565                	j	5de <vprintf+0x60>
        s = va_arg(ap, char*);
 738:	8b4a                	mv	s6,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	b54d                	j	5de <vprintf+0x60>
    }
  }
}
 73e:	70e6                	ld	ra,120(sp)
 740:	7446                	ld	s0,112(sp)
 742:	74a6                	ld	s1,104(sp)
 744:	7906                	ld	s2,96(sp)
 746:	69e6                	ld	s3,88(sp)
 748:	6a46                	ld	s4,80(sp)
 74a:	6aa6                	ld	s5,72(sp)
 74c:	6b06                	ld	s6,64(sp)
 74e:	7be2                	ld	s7,56(sp)
 750:	7c42                	ld	s8,48(sp)
 752:	7ca2                	ld	s9,40(sp)
 754:	7d02                	ld	s10,32(sp)
 756:	6de2                	ld	s11,24(sp)
 758:	6109                	addi	sp,sp,128
 75a:	8082                	ret

000000000000075c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 75c:	715d                	addi	sp,sp,-80
 75e:	ec06                	sd	ra,24(sp)
 760:	e822                	sd	s0,16(sp)
 762:	1000                	addi	s0,sp,32
 764:	e010                	sd	a2,0(s0)
 766:	e414                	sd	a3,8(s0)
 768:	e818                	sd	a4,16(s0)
 76a:	ec1c                	sd	a5,24(s0)
 76c:	03043023          	sd	a6,32(s0)
 770:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 774:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 778:	8622                	mv	a2,s0
 77a:	00000097          	auipc	ra,0x0
 77e:	e04080e7          	jalr	-508(ra) # 57e <vprintf>
}
 782:	60e2                	ld	ra,24(sp)
 784:	6442                	ld	s0,16(sp)
 786:	6161                	addi	sp,sp,80
 788:	8082                	ret

000000000000078a <printf>:

void
printf(const char *fmt, ...)
{
 78a:	711d                	addi	sp,sp,-96
 78c:	ec06                	sd	ra,24(sp)
 78e:	e822                	sd	s0,16(sp)
 790:	1000                	addi	s0,sp,32
 792:	e40c                	sd	a1,8(s0)
 794:	e810                	sd	a2,16(s0)
 796:	ec14                	sd	a3,24(s0)
 798:	f018                	sd	a4,32(s0)
 79a:	f41c                	sd	a5,40(s0)
 79c:	03043823          	sd	a6,48(s0)
 7a0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a4:	00840613          	addi	a2,s0,8
 7a8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ac:	85aa                	mv	a1,a0
 7ae:	4505                	li	a0,1
 7b0:	00000097          	auipc	ra,0x0
 7b4:	dce080e7          	jalr	-562(ra) # 57e <vprintf>
}
 7b8:	60e2                	ld	ra,24(sp)
 7ba:	6442                	ld	s0,16(sp)
 7bc:	6125                	addi	sp,sp,96
 7be:	8082                	ret

00000000000007c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c0:	1141                	addi	sp,sp,-16
 7c2:	e422                	sd	s0,8(sp)
 7c4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ca:	00000797          	auipc	a5,0x0
 7ce:	22e7b783          	ld	a5,558(a5) # 9f8 <freep>
 7d2:	a02d                	j	7fc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d4:	4618                	lw	a4,8(a2)
 7d6:	9f2d                	addw	a4,a4,a1
 7d8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7dc:	6398                	ld	a4,0(a5)
 7de:	6310                	ld	a2,0(a4)
 7e0:	a83d                	j	81e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e2:	ff852703          	lw	a4,-8(a0)
 7e6:	9f31                	addw	a4,a4,a2
 7e8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ea:	ff053683          	ld	a3,-16(a0)
 7ee:	a091                	j	832 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f0:	6398                	ld	a4,0(a5)
 7f2:	00e7e463          	bltu	a5,a4,7fa <free+0x3a>
 7f6:	00e6ea63          	bltu	a3,a4,80a <free+0x4a>
{
 7fa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fc:	fed7fae3          	bgeu	a5,a3,7f0 <free+0x30>
 800:	6398                	ld	a4,0(a5)
 802:	00e6e463          	bltu	a3,a4,80a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 806:	fee7eae3          	bltu	a5,a4,7fa <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 80a:	ff852583          	lw	a1,-8(a0)
 80e:	6390                	ld	a2,0(a5)
 810:	02059813          	slli	a6,a1,0x20
 814:	01c85713          	srli	a4,a6,0x1c
 818:	9736                	add	a4,a4,a3
 81a:	fae60de3          	beq	a2,a4,7d4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 81e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 822:	4790                	lw	a2,8(a5)
 824:	02061593          	slli	a1,a2,0x20
 828:	01c5d713          	srli	a4,a1,0x1c
 82c:	973e                	add	a4,a4,a5
 82e:	fae68ae3          	beq	a3,a4,7e2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 832:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 834:	00000717          	auipc	a4,0x0
 838:	1cf73223          	sd	a5,452(a4) # 9f8 <freep>
}
 83c:	6422                	ld	s0,8(sp)
 83e:	0141                	addi	sp,sp,16
 840:	8082                	ret

0000000000000842 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 842:	7139                	addi	sp,sp,-64
 844:	fc06                	sd	ra,56(sp)
 846:	f822                	sd	s0,48(sp)
 848:	f426                	sd	s1,40(sp)
 84a:	f04a                	sd	s2,32(sp)
 84c:	ec4e                	sd	s3,24(sp)
 84e:	e852                	sd	s4,16(sp)
 850:	e456                	sd	s5,8(sp)
 852:	e05a                	sd	s6,0(sp)
 854:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 856:	02051493          	slli	s1,a0,0x20
 85a:	9081                	srli	s1,s1,0x20
 85c:	04bd                	addi	s1,s1,15
 85e:	8091                	srli	s1,s1,0x4
 860:	0014899b          	addiw	s3,s1,1
 864:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 866:	00000517          	auipc	a0,0x0
 86a:	19253503          	ld	a0,402(a0) # 9f8 <freep>
 86e:	c515                	beqz	a0,89a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 872:	4798                	lw	a4,8(a5)
 874:	02977f63          	bgeu	a4,s1,8b2 <malloc+0x70>
 878:	8a4e                	mv	s4,s3
 87a:	0009871b          	sext.w	a4,s3
 87e:	6685                	lui	a3,0x1
 880:	00d77363          	bgeu	a4,a3,886 <malloc+0x44>
 884:	6a05                	lui	s4,0x1
 886:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 88a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 88e:	00000917          	auipc	s2,0x0
 892:	16a90913          	addi	s2,s2,362 # 9f8 <freep>
  if(p == (char*)-1)
 896:	5afd                	li	s5,-1
 898:	a895                	j	90c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 89a:	00000797          	auipc	a5,0x0
 89e:	16678793          	addi	a5,a5,358 # a00 <base>
 8a2:	00000717          	auipc	a4,0x0
 8a6:	14f73b23          	sd	a5,342(a4) # 9f8 <freep>
 8aa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b0:	b7e1                	j	878 <malloc+0x36>
      if(p->s.size == nunits)
 8b2:	02e48c63          	beq	s1,a4,8ea <malloc+0xa8>
        p->s.size -= nunits;
 8b6:	4137073b          	subw	a4,a4,s3
 8ba:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8bc:	02071693          	slli	a3,a4,0x20
 8c0:	01c6d713          	srli	a4,a3,0x1c
 8c4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	12a73723          	sd	a0,302(a4) # 9f8 <freep>
      return (void*)(p + 1);
 8d2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d6:	70e2                	ld	ra,56(sp)
 8d8:	7442                	ld	s0,48(sp)
 8da:	74a2                	ld	s1,40(sp)
 8dc:	7902                	ld	s2,32(sp)
 8de:	69e2                	ld	s3,24(sp)
 8e0:	6a42                	ld	s4,16(sp)
 8e2:	6aa2                	ld	s5,8(sp)
 8e4:	6b02                	ld	s6,0(sp)
 8e6:	6121                	addi	sp,sp,64
 8e8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ea:	6398                	ld	a4,0(a5)
 8ec:	e118                	sd	a4,0(a0)
 8ee:	bff1                	j	8ca <malloc+0x88>
  hp->s.size = nu;
 8f0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f4:	0541                	addi	a0,a0,16
 8f6:	00000097          	auipc	ra,0x0
 8fa:	eca080e7          	jalr	-310(ra) # 7c0 <free>
  return freep;
 8fe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 902:	d971                	beqz	a0,8d6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 904:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 906:	4798                	lw	a4,8(a5)
 908:	fa9775e3          	bgeu	a4,s1,8b2 <malloc+0x70>
    if(p == freep)
 90c:	00093703          	ld	a4,0(s2)
 910:	853e                	mv	a0,a5
 912:	fef719e3          	bne	a4,a5,904 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 916:	8552                	mv	a0,s4
 918:	00000097          	auipc	ra,0x0
 91c:	ae0080e7          	jalr	-1312(ra) # 3f8 <sbrk>
  if(p == (char*)-1)
 920:	fd5518e3          	bne	a0,s5,8f0 <malloc+0xae>
        return 0;
 924:	4501                	li	a0,0
 926:	bf45                	j	8d6 <malloc+0x94>
