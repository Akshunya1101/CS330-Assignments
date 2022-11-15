
user/_testGetPA:     file format elf64-littleriscv


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
  int x = 3;
   e:	478d                	li	a5,3
  10:	fcf42623          	sw	a5,-52(s0)
  int y = 4;
  14:	4791                	li	a5,4
  16:	fcf42423          	sw	a5,-56(s0)
  int *a = (int*)malloc(1025*sizeof(int));
  1a:	6905                	lui	s2,0x1
  1c:	00490513          	addi	a0,s2,4 # 1004 <__BSS_END__+0x604>
  20:	00000097          	auipc	ra,0x0
  24:	7f4080e7          	jalr	2036(ra) # 814 <malloc>
  28:	84aa                	mv	s1,a0
  fprintf(1, "x=%d, &x=%p, pa=%p\n", x, &x, getpa(&x));
  2a:	fcc42983          	lw	s3,-52(s0)
  2e:	fcc40513          	addi	a0,s0,-52
  32:	00000097          	auipc	ra,0x0
  36:	3c0080e7          	jalr	960(ra) # 3f2 <getpa>
  3a:	872a                	mv	a4,a0
  3c:	fcc40693          	addi	a3,s0,-52
  40:	864e                	mv	a2,s3
  42:	00001597          	auipc	a1,0x1
  46:	8be58593          	addi	a1,a1,-1858 # 900 <malloc+0xec>
  4a:	4505                	li	a0,1
  4c:	00000097          	auipc	ra,0x0
  50:	6e2080e7          	jalr	1762(ra) # 72e <fprintf>
  fprintf(1, "y=%d, &y=%p, pa=%p\n", y, &y, getpa(&y));
  54:	fc842983          	lw	s3,-56(s0)
  58:	fc840513          	addi	a0,s0,-56
  5c:	00000097          	auipc	ra,0x0
  60:	396080e7          	jalr	918(ra) # 3f2 <getpa>
  64:	872a                	mv	a4,a0
  66:	fc840693          	addi	a3,s0,-56
  6a:	864e                	mv	a2,s3
  6c:	00001597          	auipc	a1,0x1
  70:	8ac58593          	addi	a1,a1,-1876 # 918 <malloc+0x104>
  74:	4505                	li	a0,1
  76:	00000097          	auipc	ra,0x0
  7a:	6b8080e7          	jalr	1720(ra) # 72e <fprintf>
  fprintf(1, "a[0]=%d, &a[0]=%p, pa=%p\n", a[0], &a[0], getpa(&a[0]));
  7e:	0004a983          	lw	s3,0(s1)
  82:	8526                	mv	a0,s1
  84:	00000097          	auipc	ra,0x0
  88:	36e080e7          	jalr	878(ra) # 3f2 <getpa>
  8c:	872a                	mv	a4,a0
  8e:	86a6                	mv	a3,s1
  90:	864e                	mv	a2,s3
  92:	00001597          	auipc	a1,0x1
  96:	89e58593          	addi	a1,a1,-1890 # 930 <malloc+0x11c>
  9a:	4505                	li	a0,1
  9c:	00000097          	auipc	ra,0x0
  a0:	692080e7          	jalr	1682(ra) # 72e <fprintf>
  fprintf(1, "a[1024]=%d, &a[1024]=%p, pa=%p\n", a[1024], &a[1024], getpa(&a[1024]));
  a4:	94ca                	add	s1,s1,s2
  a6:	0004a903          	lw	s2,0(s1)
  aa:	8526                	mv	a0,s1
  ac:	00000097          	auipc	ra,0x0
  b0:	346080e7          	jalr	838(ra) # 3f2 <getpa>
  b4:	872a                	mv	a4,a0
  b6:	86a6                	mv	a3,s1
  b8:	864a                	mv	a2,s2
  ba:	00001597          	auipc	a1,0x1
  be:	89658593          	addi	a1,a1,-1898 # 950 <malloc+0x13c>
  c2:	4505                	li	a0,1
  c4:	00000097          	auipc	ra,0x0
  c8:	66a080e7          	jalr	1642(ra) # 72e <fprintf>

  exit(0);
  cc:	4501                	li	a0,0
  ce:	00000097          	auipc	ra,0x0
  d2:	274080e7          	jalr	628(ra) # 342 <exit>

00000000000000d6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  dc:	87aa                	mv	a5,a0
  de:	0585                	addi	a1,a1,1
  e0:	0785                	addi	a5,a5,1
  e2:	fff5c703          	lbu	a4,-1(a1)
  e6:	fee78fa3          	sb	a4,-1(a5)
  ea:	fb75                	bnez	a4,de <strcpy+0x8>
    ;
  return os;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb91                	beqz	a5,110 <strcmp+0x1e>
  fe:	0005c703          	lbu	a4,0(a1)
 102:	00f71763          	bne	a4,a5,110 <strcmp+0x1e>
    p++, q++;
 106:	0505                	addi	a0,a0,1
 108:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbe5                	bnez	a5,fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 110:	0005c503          	lbu	a0,0(a1)
}
 114:	40a7853b          	subw	a0,a5,a0
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strlen>:

uint
strlen(const char *s)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cf91                	beqz	a5,144 <strlen+0x26>
 12a:	0505                	addi	a0,a0,1
 12c:	87aa                	mv	a5,a0
 12e:	4685                	li	a3,1
 130:	9e89                	subw	a3,a3,a0
 132:	00f6853b          	addw	a0,a3,a5
 136:	0785                	addi	a5,a5,1
 138:	fff7c703          	lbu	a4,-1(a5)
 13c:	fb7d                	bnez	a4,132 <strlen+0x14>
    ;
  return n;
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
  for(n = 0; s[n]; n++)
 144:	4501                	li	a0,0
 146:	bfe5                	j	13e <strlen+0x20>

0000000000000148 <memset>:

void*
memset(void *dst, int c, uint n)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14e:	ca19                	beqz	a2,164 <memset+0x1c>
 150:	87aa                	mv	a5,a0
 152:	1602                	slli	a2,a2,0x20
 154:	9201                	srli	a2,a2,0x20
 156:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15e:	0785                	addi	a5,a5,1
 160:	fee79de3          	bne	a5,a4,15a <memset+0x12>
  }
  return dst;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strchr>:

char*
strchr(const char *s, char c)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 170:	00054783          	lbu	a5,0(a0)
 174:	cb99                	beqz	a5,18a <strchr+0x20>
    if(*s == c)
 176:	00f58763          	beq	a1,a5,184 <strchr+0x1a>
  for(; *s; s++)
 17a:	0505                	addi	a0,a0,1
 17c:	00054783          	lbu	a5,0(a0)
 180:	fbfd                	bnez	a5,176 <strchr+0xc>
      return (char*)s;
  return 0;
 182:	4501                	li	a0,0
}
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret
  return 0;
 18a:	4501                	li	a0,0
 18c:	bfe5                	j	184 <strchr+0x1a>

000000000000018e <gets>:

char*
gets(char *buf, int max)
{
 18e:	711d                	addi	sp,sp,-96
 190:	ec86                	sd	ra,88(sp)
 192:	e8a2                	sd	s0,80(sp)
 194:	e4a6                	sd	s1,72(sp)
 196:	e0ca                	sd	s2,64(sp)
 198:	fc4e                	sd	s3,56(sp)
 19a:	f852                	sd	s4,48(sp)
 19c:	f456                	sd	s5,40(sp)
 19e:	f05a                	sd	s6,32(sp)
 1a0:	ec5e                	sd	s7,24(sp)
 1a2:	1080                	addi	s0,sp,96
 1a4:	8baa                	mv	s7,a0
 1a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a8:	892a                	mv	s2,a0
 1aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ac:	4aa9                	li	s5,10
 1ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b0:	89a6                	mv	s3,s1
 1b2:	2485                	addiw	s1,s1,1
 1b4:	0344d863          	bge	s1,s4,1e4 <gets+0x56>
    cc = read(0, &c, 1);
 1b8:	4605                	li	a2,1
 1ba:	faf40593          	addi	a1,s0,-81
 1be:	4501                	li	a0,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	19a080e7          	jalr	410(ra) # 35a <read>
    if(cc < 1)
 1c8:	00a05e63          	blez	a0,1e4 <gets+0x56>
    buf[i++] = c;
 1cc:	faf44783          	lbu	a5,-81(s0)
 1d0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d4:	01578763          	beq	a5,s5,1e2 <gets+0x54>
 1d8:	0905                	addi	s2,s2,1
 1da:	fd679be3          	bne	a5,s6,1b0 <gets+0x22>
  for(i=0; i+1 < max; ){
 1de:	89a6                	mv	s3,s1
 1e0:	a011                	j	1e4 <gets+0x56>
 1e2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e4:	99de                	add	s3,s3,s7
 1e6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ea:	855e                	mv	a0,s7
 1ec:	60e6                	ld	ra,88(sp)
 1ee:	6446                	ld	s0,80(sp)
 1f0:	64a6                	ld	s1,72(sp)
 1f2:	6906                	ld	s2,64(sp)
 1f4:	79e2                	ld	s3,56(sp)
 1f6:	7a42                	ld	s4,48(sp)
 1f8:	7aa2                	ld	s5,40(sp)
 1fa:	7b02                	ld	s6,32(sp)
 1fc:	6be2                	ld	s7,24(sp)
 1fe:	6125                	addi	sp,sp,96
 200:	8082                	ret

0000000000000202 <stat>:

int
stat(const char *n, struct stat *st)
{
 202:	1101                	addi	sp,sp,-32
 204:	ec06                	sd	ra,24(sp)
 206:	e822                	sd	s0,16(sp)
 208:	e426                	sd	s1,8(sp)
 20a:	e04a                	sd	s2,0(sp)
 20c:	1000                	addi	s0,sp,32
 20e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 210:	4581                	li	a1,0
 212:	00000097          	auipc	ra,0x0
 216:	170080e7          	jalr	368(ra) # 382 <open>
  if(fd < 0)
 21a:	02054563          	bltz	a0,244 <stat+0x42>
 21e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 220:	85ca                	mv	a1,s2
 222:	00000097          	auipc	ra,0x0
 226:	178080e7          	jalr	376(ra) # 39a <fstat>
 22a:	892a                	mv	s2,a0
  close(fd);
 22c:	8526                	mv	a0,s1
 22e:	00000097          	auipc	ra,0x0
 232:	13c080e7          	jalr	316(ra) # 36a <close>
  return r;
}
 236:	854a                	mv	a0,s2
 238:	60e2                	ld	ra,24(sp)
 23a:	6442                	ld	s0,16(sp)
 23c:	64a2                	ld	s1,8(sp)
 23e:	6902                	ld	s2,0(sp)
 240:	6105                	addi	sp,sp,32
 242:	8082                	ret
    return -1;
 244:	597d                	li	s2,-1
 246:	bfc5                	j	236 <stat+0x34>

0000000000000248 <atoi>:

int
atoi(const char *s)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24e:	00054683          	lbu	a3,0(a0)
 252:	fd06879b          	addiw	a5,a3,-48
 256:	0ff7f793          	zext.b	a5,a5
 25a:	4625                	li	a2,9
 25c:	02f66863          	bltu	a2,a5,28c <atoi+0x44>
 260:	872a                	mv	a4,a0
  n = 0;
 262:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 264:	0705                	addi	a4,a4,1
 266:	0025179b          	slliw	a5,a0,0x2
 26a:	9fa9                	addw	a5,a5,a0
 26c:	0017979b          	slliw	a5,a5,0x1
 270:	9fb5                	addw	a5,a5,a3
 272:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 276:	00074683          	lbu	a3,0(a4)
 27a:	fd06879b          	addiw	a5,a3,-48
 27e:	0ff7f793          	zext.b	a5,a5
 282:	fef671e3          	bgeu	a2,a5,264 <atoi+0x1c>
  return n;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
  n = 0;
 28c:	4501                	li	a0,0
 28e:	bfe5                	j	286 <atoi+0x3e>

0000000000000290 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e422                	sd	s0,8(sp)
 294:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 296:	02b57463          	bgeu	a0,a1,2be <memmove+0x2e>
    while(n-- > 0)
 29a:	00c05f63          	blez	a2,2b8 <memmove+0x28>
 29e:	1602                	slli	a2,a2,0x20
 2a0:	9201                	srli	a2,a2,0x20
 2a2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a8:	0585                	addi	a1,a1,1
 2aa:	0705                	addi	a4,a4,1
 2ac:	fff5c683          	lbu	a3,-1(a1)
 2b0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
    dst += n;
 2be:	00c50733          	add	a4,a0,a2
    src += n;
 2c2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c4:	fec05ae3          	blez	a2,2b8 <memmove+0x28>
 2c8:	fff6079b          	addiw	a5,a2,-1
 2cc:	1782                	slli	a5,a5,0x20
 2ce:	9381                	srli	a5,a5,0x20
 2d0:	fff7c793          	not	a5,a5
 2d4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d6:	15fd                	addi	a1,a1,-1
 2d8:	177d                	addi	a4,a4,-1
 2da:	0005c683          	lbu	a3,0(a1)
 2de:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e2:	fee79ae3          	bne	a5,a4,2d6 <memmove+0x46>
 2e6:	bfc9                	j	2b8 <memmove+0x28>

00000000000002e8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ee:	ca05                	beqz	a2,31e <memcmp+0x36>
 2f0:	fff6069b          	addiw	a3,a2,-1
 2f4:	1682                	slli	a3,a3,0x20
 2f6:	9281                	srli	a3,a3,0x20
 2f8:	0685                	addi	a3,a3,1
 2fa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fc:	00054783          	lbu	a5,0(a0)
 300:	0005c703          	lbu	a4,0(a1)
 304:	00e79863          	bne	a5,a4,314 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 308:	0505                	addi	a0,a0,1
    p2++;
 30a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30c:	fed518e3          	bne	a0,a3,2fc <memcmp+0x14>
  }
  return 0;
 310:	4501                	li	a0,0
 312:	a019                	j	318 <memcmp+0x30>
      return *p1 - *p2;
 314:	40e7853b          	subw	a0,a5,a4
}
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
  return 0;
 31e:	4501                	li	a0,0
 320:	bfe5                	j	318 <memcmp+0x30>

0000000000000322 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 322:	1141                	addi	sp,sp,-16
 324:	e406                	sd	ra,8(sp)
 326:	e022                	sd	s0,0(sp)
 328:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 32a:	00000097          	auipc	ra,0x0
 32e:	f66080e7          	jalr	-154(ra) # 290 <memmove>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 33a:	4885                	li	a7,1
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <exit>:
.global exit
exit:
 li a7, SYS_exit
 342:	4889                	li	a7,2
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <wait>:
.global wait
wait:
 li a7, SYS_wait
 34a:	488d                	li	a7,3
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 352:	4891                	li	a7,4
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <read>:
.global read
read:
 li a7, SYS_read
 35a:	4895                	li	a7,5
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <write>:
.global write
write:
 li a7, SYS_write
 362:	48c1                	li	a7,16
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <close>:
.global close
close:
 li a7, SYS_close
 36a:	48d5                	li	a7,21
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <kill>:
.global kill
kill:
 li a7, SYS_kill
 372:	4899                	li	a7,6
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <exec>:
.global exec
exec:
 li a7, SYS_exec
 37a:	489d                	li	a7,7
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <open>:
.global open
open:
 li a7, SYS_open
 382:	48bd                	li	a7,15
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 38a:	48c5                	li	a7,17
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 392:	48c9                	li	a7,18
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 39a:	48a1                	li	a7,8
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <link>:
.global link
link:
 li a7, SYS_link
 3a2:	48cd                	li	a7,19
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3aa:	48d1                	li	a7,20
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b2:	48a5                	li	a7,9
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ba:	48a9                	li	a7,10
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c2:	48ad                	li	a7,11
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ca:	48b1                	li	a7,12
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d2:	48b5                	li	a7,13
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3da:	48b9                	li	a7,14
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3e2:	48d9                	li	a7,22
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <yield>:
.global yield
yield:
 li a7, SYS_yield
 3ea:	48dd                	li	a7,23
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3f2:	48e1                	li	a7,24
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3fa:	48e5                	li	a7,25
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 402:	48e9                	li	a7,26
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <ps>:
.global ps
ps:
 li a7, SYS_ps
 40a:	48ed                	li	a7,27
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 412:	48f1                	li	a7,28
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 41a:	48f5                	li	a7,29
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 422:	48f9                	li	a7,30
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 42a:	02100893          	li	a7,33
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 434:	48fd                	li	a7,31
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 43c:	02000893          	li	a7,32
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 446:	02200893          	li	a7,34
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 450:	02300893          	li	a7,35
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 45a:	02400893          	li	a7,36
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 464:	02500893          	li	a7,37
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 46e:	02700893          	li	a7,39
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 478:	02600893          	li	a7,38
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 482:	1101                	addi	sp,sp,-32
 484:	ec06                	sd	ra,24(sp)
 486:	e822                	sd	s0,16(sp)
 488:	1000                	addi	s0,sp,32
 48a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48e:	4605                	li	a2,1
 490:	fef40593          	addi	a1,s0,-17
 494:	00000097          	auipc	ra,0x0
 498:	ece080e7          	jalr	-306(ra) # 362 <write>
}
 49c:	60e2                	ld	ra,24(sp)
 49e:	6442                	ld	s0,16(sp)
 4a0:	6105                	addi	sp,sp,32
 4a2:	8082                	ret

00000000000004a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a4:	7139                	addi	sp,sp,-64
 4a6:	fc06                	sd	ra,56(sp)
 4a8:	f822                	sd	s0,48(sp)
 4aa:	f426                	sd	s1,40(sp)
 4ac:	f04a                	sd	s2,32(sp)
 4ae:	ec4e                	sd	s3,24(sp)
 4b0:	0080                	addi	s0,sp,64
 4b2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b4:	c299                	beqz	a3,4ba <printint+0x16>
 4b6:	0805c963          	bltz	a1,548 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ba:	2581                	sext.w	a1,a1
  neg = 0;
 4bc:	4881                	li	a7,0
 4be:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c4:	2601                	sext.w	a2,a2
 4c6:	00000517          	auipc	a0,0x0
 4ca:	50a50513          	addi	a0,a0,1290 # 9d0 <digits>
 4ce:	883a                	mv	a6,a4
 4d0:	2705                	addiw	a4,a4,1
 4d2:	02c5f7bb          	remuw	a5,a1,a2
 4d6:	1782                	slli	a5,a5,0x20
 4d8:	9381                	srli	a5,a5,0x20
 4da:	97aa                	add	a5,a5,a0
 4dc:	0007c783          	lbu	a5,0(a5)
 4e0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e4:	0005879b          	sext.w	a5,a1
 4e8:	02c5d5bb          	divuw	a1,a1,a2
 4ec:	0685                	addi	a3,a3,1
 4ee:	fec7f0e3          	bgeu	a5,a2,4ce <printint+0x2a>
  if(neg)
 4f2:	00088c63          	beqz	a7,50a <printint+0x66>
    buf[i++] = '-';
 4f6:	fd070793          	addi	a5,a4,-48
 4fa:	00878733          	add	a4,a5,s0
 4fe:	02d00793          	li	a5,45
 502:	fef70823          	sb	a5,-16(a4)
 506:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 50a:	02e05863          	blez	a4,53a <printint+0x96>
 50e:	fc040793          	addi	a5,s0,-64
 512:	00e78933          	add	s2,a5,a4
 516:	fff78993          	addi	s3,a5,-1
 51a:	99ba                	add	s3,s3,a4
 51c:	377d                	addiw	a4,a4,-1
 51e:	1702                	slli	a4,a4,0x20
 520:	9301                	srli	a4,a4,0x20
 522:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 526:	fff94583          	lbu	a1,-1(s2)
 52a:	8526                	mv	a0,s1
 52c:	00000097          	auipc	ra,0x0
 530:	f56080e7          	jalr	-170(ra) # 482 <putc>
  while(--i >= 0)
 534:	197d                	addi	s2,s2,-1
 536:	ff3918e3          	bne	s2,s3,526 <printint+0x82>
}
 53a:	70e2                	ld	ra,56(sp)
 53c:	7442                	ld	s0,48(sp)
 53e:	74a2                	ld	s1,40(sp)
 540:	7902                	ld	s2,32(sp)
 542:	69e2                	ld	s3,24(sp)
 544:	6121                	addi	sp,sp,64
 546:	8082                	ret
    x = -xx;
 548:	40b005bb          	negw	a1,a1
    neg = 1;
 54c:	4885                	li	a7,1
    x = -xx;
 54e:	bf85                	j	4be <printint+0x1a>

0000000000000550 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 550:	7119                	addi	sp,sp,-128
 552:	fc86                	sd	ra,120(sp)
 554:	f8a2                	sd	s0,112(sp)
 556:	f4a6                	sd	s1,104(sp)
 558:	f0ca                	sd	s2,96(sp)
 55a:	ecce                	sd	s3,88(sp)
 55c:	e8d2                	sd	s4,80(sp)
 55e:	e4d6                	sd	s5,72(sp)
 560:	e0da                	sd	s6,64(sp)
 562:	fc5e                	sd	s7,56(sp)
 564:	f862                	sd	s8,48(sp)
 566:	f466                	sd	s9,40(sp)
 568:	f06a                	sd	s10,32(sp)
 56a:	ec6e                	sd	s11,24(sp)
 56c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 56e:	0005c903          	lbu	s2,0(a1)
 572:	18090f63          	beqz	s2,710 <vprintf+0x1c0>
 576:	8aaa                	mv	s5,a0
 578:	8b32                	mv	s6,a2
 57a:	00158493          	addi	s1,a1,1
  state = 0;
 57e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 580:	02500a13          	li	s4,37
 584:	4c55                	li	s8,21
 586:	00000c97          	auipc	s9,0x0
 58a:	3f2c8c93          	addi	s9,s9,1010 # 978 <malloc+0x164>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 58e:	02800d93          	li	s11,40
  putc(fd, 'x');
 592:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 594:	00000b97          	auipc	s7,0x0
 598:	43cb8b93          	addi	s7,s7,1084 # 9d0 <digits>
 59c:	a839                	j	5ba <vprintf+0x6a>
        putc(fd, c);
 59e:	85ca                	mv	a1,s2
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	ee0080e7          	jalr	-288(ra) # 482 <putc>
 5aa:	a019                	j	5b0 <vprintf+0x60>
    } else if(state == '%'){
 5ac:	01498d63          	beq	s3,s4,5c6 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5b0:	0485                	addi	s1,s1,1
 5b2:	fff4c903          	lbu	s2,-1(s1)
 5b6:	14090d63          	beqz	s2,710 <vprintf+0x1c0>
    if(state == 0){
 5ba:	fe0999e3          	bnez	s3,5ac <vprintf+0x5c>
      if(c == '%'){
 5be:	ff4910e3          	bne	s2,s4,59e <vprintf+0x4e>
        state = '%';
 5c2:	89d2                	mv	s3,s4
 5c4:	b7f5                	j	5b0 <vprintf+0x60>
      if(c == 'd'){
 5c6:	11490c63          	beq	s2,s4,6de <vprintf+0x18e>
 5ca:	f9d9079b          	addiw	a5,s2,-99
 5ce:	0ff7f793          	zext.b	a5,a5
 5d2:	10fc6e63          	bltu	s8,a5,6ee <vprintf+0x19e>
 5d6:	f9d9079b          	addiw	a5,s2,-99
 5da:	0ff7f713          	zext.b	a4,a5
 5de:	10ec6863          	bltu	s8,a4,6ee <vprintf+0x19e>
 5e2:	00271793          	slli	a5,a4,0x2
 5e6:	97e6                	add	a5,a5,s9
 5e8:	439c                	lw	a5,0(a5)
 5ea:	97e6                	add	a5,a5,s9
 5ec:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5ee:	008b0913          	addi	s2,s6,8
 5f2:	4685                	li	a3,1
 5f4:	4629                	li	a2,10
 5f6:	000b2583          	lw	a1,0(s6)
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	ea8080e7          	jalr	-344(ra) # 4a4 <printint>
 604:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 606:	4981                	li	s3,0
 608:	b765                	j	5b0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60a:	008b0913          	addi	s2,s6,8
 60e:	4681                	li	a3,0
 610:	4629                	li	a2,10
 612:	000b2583          	lw	a1,0(s6)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	e8c080e7          	jalr	-372(ra) # 4a4 <printint>
 620:	8b4a                	mv	s6,s2
      state = 0;
 622:	4981                	li	s3,0
 624:	b771                	j	5b0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 626:	008b0913          	addi	s2,s6,8
 62a:	4681                	li	a3,0
 62c:	866a                	mv	a2,s10
 62e:	000b2583          	lw	a1,0(s6)
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	e70080e7          	jalr	-400(ra) # 4a4 <printint>
 63c:	8b4a                	mv	s6,s2
      state = 0;
 63e:	4981                	li	s3,0
 640:	bf85                	j	5b0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 642:	008b0793          	addi	a5,s6,8
 646:	f8f43423          	sd	a5,-120(s0)
 64a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 64e:	03000593          	li	a1,48
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	e2e080e7          	jalr	-466(ra) # 482 <putc>
  putc(fd, 'x');
 65c:	07800593          	li	a1,120
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	e20080e7          	jalr	-480(ra) # 482 <putc>
 66a:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66c:	03c9d793          	srli	a5,s3,0x3c
 670:	97de                	add	a5,a5,s7
 672:	0007c583          	lbu	a1,0(a5)
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	e0a080e7          	jalr	-502(ra) # 482 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 680:	0992                	slli	s3,s3,0x4
 682:	397d                	addiw	s2,s2,-1
 684:	fe0914e3          	bnez	s2,66c <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 688:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b70d                	j	5b0 <vprintf+0x60>
        s = va_arg(ap, char*);
 690:	008b0913          	addi	s2,s6,8
 694:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 698:	02098163          	beqz	s3,6ba <vprintf+0x16a>
        while(*s != 0){
 69c:	0009c583          	lbu	a1,0(s3)
 6a0:	c5ad                	beqz	a1,70a <vprintf+0x1ba>
          putc(fd, *s);
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	dde080e7          	jalr	-546(ra) # 482 <putc>
          s++;
 6ac:	0985                	addi	s3,s3,1
        while(*s != 0){
 6ae:	0009c583          	lbu	a1,0(s3)
 6b2:	f9e5                	bnez	a1,6a2 <vprintf+0x152>
        s = va_arg(ap, char*);
 6b4:	8b4a                	mv	s6,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bde5                	j	5b0 <vprintf+0x60>
          s = "(null)";
 6ba:	00000997          	auipc	s3,0x0
 6be:	2b698993          	addi	s3,s3,694 # 970 <malloc+0x15c>
        while(*s != 0){
 6c2:	85ee                	mv	a1,s11
 6c4:	bff9                	j	6a2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6c6:	008b0913          	addi	s2,s6,8
 6ca:	000b4583          	lbu	a1,0(s6)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	db2080e7          	jalr	-590(ra) # 482 <putc>
 6d8:	8b4a                	mv	s6,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bdd1                	j	5b0 <vprintf+0x60>
        putc(fd, c);
 6de:	85d2                	mv	a1,s4
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	da0080e7          	jalr	-608(ra) # 482 <putc>
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b5d1                	j	5b0 <vprintf+0x60>
        putc(fd, '%');
 6ee:	85d2                	mv	a1,s4
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	d90080e7          	jalr	-624(ra) # 482 <putc>
        putc(fd, c);
 6fa:	85ca                	mv	a1,s2
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	d84080e7          	jalr	-636(ra) # 482 <putc>
      state = 0;
 706:	4981                	li	s3,0
 708:	b565                	j	5b0 <vprintf+0x60>
        s = va_arg(ap, char*);
 70a:	8b4a                	mv	s6,s2
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b54d                	j	5b0 <vprintf+0x60>
    }
  }
}
 710:	70e6                	ld	ra,120(sp)
 712:	7446                	ld	s0,112(sp)
 714:	74a6                	ld	s1,104(sp)
 716:	7906                	ld	s2,96(sp)
 718:	69e6                	ld	s3,88(sp)
 71a:	6a46                	ld	s4,80(sp)
 71c:	6aa6                	ld	s5,72(sp)
 71e:	6b06                	ld	s6,64(sp)
 720:	7be2                	ld	s7,56(sp)
 722:	7c42                	ld	s8,48(sp)
 724:	7ca2                	ld	s9,40(sp)
 726:	7d02                	ld	s10,32(sp)
 728:	6de2                	ld	s11,24(sp)
 72a:	6109                	addi	sp,sp,128
 72c:	8082                	ret

000000000000072e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 72e:	715d                	addi	sp,sp,-80
 730:	ec06                	sd	ra,24(sp)
 732:	e822                	sd	s0,16(sp)
 734:	1000                	addi	s0,sp,32
 736:	e010                	sd	a2,0(s0)
 738:	e414                	sd	a3,8(s0)
 73a:	e818                	sd	a4,16(s0)
 73c:	ec1c                	sd	a5,24(s0)
 73e:	03043023          	sd	a6,32(s0)
 742:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 746:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 74a:	8622                	mv	a2,s0
 74c:	00000097          	auipc	ra,0x0
 750:	e04080e7          	jalr	-508(ra) # 550 <vprintf>
}
 754:	60e2                	ld	ra,24(sp)
 756:	6442                	ld	s0,16(sp)
 758:	6161                	addi	sp,sp,80
 75a:	8082                	ret

000000000000075c <printf>:

void
printf(const char *fmt, ...)
{
 75c:	711d                	addi	sp,sp,-96
 75e:	ec06                	sd	ra,24(sp)
 760:	e822                	sd	s0,16(sp)
 762:	1000                	addi	s0,sp,32
 764:	e40c                	sd	a1,8(s0)
 766:	e810                	sd	a2,16(s0)
 768:	ec14                	sd	a3,24(s0)
 76a:	f018                	sd	a4,32(s0)
 76c:	f41c                	sd	a5,40(s0)
 76e:	03043823          	sd	a6,48(s0)
 772:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 776:	00840613          	addi	a2,s0,8
 77a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 77e:	85aa                	mv	a1,a0
 780:	4505                	li	a0,1
 782:	00000097          	auipc	ra,0x0
 786:	dce080e7          	jalr	-562(ra) # 550 <vprintf>
}
 78a:	60e2                	ld	ra,24(sp)
 78c:	6442                	ld	s0,16(sp)
 78e:	6125                	addi	sp,sp,96
 790:	8082                	ret

0000000000000792 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 792:	1141                	addi	sp,sp,-16
 794:	e422                	sd	s0,8(sp)
 796:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 798:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79c:	00000797          	auipc	a5,0x0
 7a0:	24c7b783          	ld	a5,588(a5) # 9e8 <freep>
 7a4:	a02d                	j	7ce <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a6:	4618                	lw	a4,8(a2)
 7a8:	9f2d                	addw	a4,a4,a1
 7aa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ae:	6398                	ld	a4,0(a5)
 7b0:	6310                	ld	a2,0(a4)
 7b2:	a83d                	j	7f0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b4:	ff852703          	lw	a4,-8(a0)
 7b8:	9f31                	addw	a4,a4,a2
 7ba:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7bc:	ff053683          	ld	a3,-16(a0)
 7c0:	a091                	j	804 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c2:	6398                	ld	a4,0(a5)
 7c4:	00e7e463          	bltu	a5,a4,7cc <free+0x3a>
 7c8:	00e6ea63          	bltu	a3,a4,7dc <free+0x4a>
{
 7cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ce:	fed7fae3          	bgeu	a5,a3,7c2 <free+0x30>
 7d2:	6398                	ld	a4,0(a5)
 7d4:	00e6e463          	bltu	a3,a4,7dc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d8:	fee7eae3          	bltu	a5,a4,7cc <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7dc:	ff852583          	lw	a1,-8(a0)
 7e0:	6390                	ld	a2,0(a5)
 7e2:	02059813          	slli	a6,a1,0x20
 7e6:	01c85713          	srli	a4,a6,0x1c
 7ea:	9736                	add	a4,a4,a3
 7ec:	fae60de3          	beq	a2,a4,7a6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7f0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f4:	4790                	lw	a2,8(a5)
 7f6:	02061593          	slli	a1,a2,0x20
 7fa:	01c5d713          	srli	a4,a1,0x1c
 7fe:	973e                	add	a4,a4,a5
 800:	fae68ae3          	beq	a3,a4,7b4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 804:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 806:	00000717          	auipc	a4,0x0
 80a:	1ef73123          	sd	a5,482(a4) # 9e8 <freep>
}
 80e:	6422                	ld	s0,8(sp)
 810:	0141                	addi	sp,sp,16
 812:	8082                	ret

0000000000000814 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 814:	7139                	addi	sp,sp,-64
 816:	fc06                	sd	ra,56(sp)
 818:	f822                	sd	s0,48(sp)
 81a:	f426                	sd	s1,40(sp)
 81c:	f04a                	sd	s2,32(sp)
 81e:	ec4e                	sd	s3,24(sp)
 820:	e852                	sd	s4,16(sp)
 822:	e456                	sd	s5,8(sp)
 824:	e05a                	sd	s6,0(sp)
 826:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 828:	02051493          	slli	s1,a0,0x20
 82c:	9081                	srli	s1,s1,0x20
 82e:	04bd                	addi	s1,s1,15
 830:	8091                	srli	s1,s1,0x4
 832:	0014899b          	addiw	s3,s1,1
 836:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 838:	00000517          	auipc	a0,0x0
 83c:	1b053503          	ld	a0,432(a0) # 9e8 <freep>
 840:	c515                	beqz	a0,86c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 842:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 844:	4798                	lw	a4,8(a5)
 846:	02977f63          	bgeu	a4,s1,884 <malloc+0x70>
 84a:	8a4e                	mv	s4,s3
 84c:	0009871b          	sext.w	a4,s3
 850:	6685                	lui	a3,0x1
 852:	00d77363          	bgeu	a4,a3,858 <malloc+0x44>
 856:	6a05                	lui	s4,0x1
 858:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 85c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 860:	00000917          	auipc	s2,0x0
 864:	18890913          	addi	s2,s2,392 # 9e8 <freep>
  if(p == (char*)-1)
 868:	5afd                	li	s5,-1
 86a:	a895                	j	8de <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 86c:	00000797          	auipc	a5,0x0
 870:	18478793          	addi	a5,a5,388 # 9f0 <base>
 874:	00000717          	auipc	a4,0x0
 878:	16f73a23          	sd	a5,372(a4) # 9e8 <freep>
 87c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 87e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 882:	b7e1                	j	84a <malloc+0x36>
      if(p->s.size == nunits)
 884:	02e48c63          	beq	s1,a4,8bc <malloc+0xa8>
        p->s.size -= nunits;
 888:	4137073b          	subw	a4,a4,s3
 88c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 88e:	02071693          	slli	a3,a4,0x20
 892:	01c6d713          	srli	a4,a3,0x1c
 896:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 898:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 89c:	00000717          	auipc	a4,0x0
 8a0:	14a73623          	sd	a0,332(a4) # 9e8 <freep>
      return (void*)(p + 1);
 8a4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a8:	70e2                	ld	ra,56(sp)
 8aa:	7442                	ld	s0,48(sp)
 8ac:	74a2                	ld	s1,40(sp)
 8ae:	7902                	ld	s2,32(sp)
 8b0:	69e2                	ld	s3,24(sp)
 8b2:	6a42                	ld	s4,16(sp)
 8b4:	6aa2                	ld	s5,8(sp)
 8b6:	6b02                	ld	s6,0(sp)
 8b8:	6121                	addi	sp,sp,64
 8ba:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8bc:	6398                	ld	a4,0(a5)
 8be:	e118                	sd	a4,0(a0)
 8c0:	bff1                	j	89c <malloc+0x88>
  hp->s.size = nu;
 8c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c6:	0541                	addi	a0,a0,16
 8c8:	00000097          	auipc	ra,0x0
 8cc:	eca080e7          	jalr	-310(ra) # 792 <free>
  return freep;
 8d0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d4:	d971                	beqz	a0,8a8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d8:	4798                	lw	a4,8(a5)
 8da:	fa9775e3          	bgeu	a4,s1,884 <malloc+0x70>
    if(p == freep)
 8de:	00093703          	ld	a4,0(s2)
 8e2:	853e                	mv	a0,a5
 8e4:	fef719e3          	bne	a4,a5,8d6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8e8:	8552                	mv	a0,s4
 8ea:	00000097          	auipc	ra,0x0
 8ee:	ae0080e7          	jalr	-1312(ra) # 3ca <sbrk>
  if(p == (char*)-1)
 8f2:	fd5518e3          	bne	a0,s5,8c2 <malloc+0xae>
        return 0;
 8f6:	4501                	li	a0,0
 8f8:	bf45                	j	8a8 <malloc+0x94>
