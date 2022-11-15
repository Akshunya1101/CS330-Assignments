
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
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
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i;

  for(i = 1; i < argc; i++){
  10:	4785                	li	a5,1
  12:	06a7d463          	bge	a5,a0,7a <main+0x7a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	02099793          	slli	a5,s3,0x20
  22:	01d7d993          	srli	s3,a5,0x1d
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  2a:	00001a17          	auipc	s4,0x1
  2e:	87ea0a13          	addi	s4,s4,-1922 # 8a8 <malloc+0xe6>
    write(1, argv[i], strlen(argv[i]));
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	00000097          	auipc	ra,0x0
  3c:	094080e7          	jalr	148(ra) # cc <strlen>
  40:	0005061b          	sext.w	a2,a0
  44:	85ca                	mv	a1,s2
  46:	4505                	li	a0,1
  48:	00000097          	auipc	ra,0x0
  4c:	2c8080e7          	jalr	712(ra) # 310 <write>
    if(i + 1 < argc){
  50:	04a1                	addi	s1,s1,8
  52:	01348a63          	beq	s1,s3,66 <main+0x66>
      write(1, " ", 1);
  56:	4605                	li	a2,1
  58:	85d2                	mv	a1,s4
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2b4080e7          	jalr	692(ra) # 310 <write>
  for(i = 1; i < argc; i++){
  64:	b7f9                	j	32 <main+0x32>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00001597          	auipc	a1,0x1
  6c:	84858593          	addi	a1,a1,-1976 # 8b0 <malloc+0xee>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	29e080e7          	jalr	670(ra) # 310 <write>
    }
  }
  exit(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	274080e7          	jalr	628(ra) # 2f0 <exit>

0000000000000084 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8a:	87aa                	mv	a5,a0
  8c:	0585                	addi	a1,a1,1
  8e:	0785                	addi	a5,a5,1
  90:	fff5c703          	lbu	a4,-1(a1)
  94:	fee78fa3          	sb	a4,-1(a5)
  98:	fb75                	bnez	a4,8c <strcpy+0x8>
    ;
  return os;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cb91                	beqz	a5,be <strcmp+0x1e>
  ac:	0005c703          	lbu	a4,0(a1)
  b0:	00f71763          	bne	a4,a5,be <strcmp+0x1e>
    p++, q++;
  b4:	0505                	addi	a0,a0,1
  b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	fbe5                	bnez	a5,ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  be:	0005c503          	lbu	a0,0(a1)
}
  c2:	40a7853b          	subw	a0,a5,a0
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	cf91                	beqz	a5,f2 <strlen+0x26>
  d8:	0505                	addi	a0,a0,1
  da:	87aa                	mv	a5,a0
  dc:	4685                	li	a3,1
  de:	9e89                	subw	a3,a3,a0
  e0:	00f6853b          	addw	a0,a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	fb7d                	bnez	a4,e0 <strlen+0x14>
    ;
  return n;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  for(n = 0; s[n]; n++)
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strlen+0x20>

00000000000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fc:	ca19                	beqz	a2,112 <memset+0x1c>
  fe:	87aa                	mv	a5,a0
 100:	1602                	slli	a2,a2,0x20
 102:	9201                	srli	a2,a2,0x20
 104:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 108:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 10c:	0785                	addi	a5,a5,1
 10e:	fee79de3          	bne	a5,a4,108 <memset+0x12>
  }
  return dst;
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strchr>:

char*
strchr(const char *s, char c)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cb99                	beqz	a5,138 <strchr+0x20>
    if(*s == c)
 124:	00f58763          	beq	a1,a5,132 <strchr+0x1a>
  for(; *s; s++)
 128:	0505                	addi	a0,a0,1
 12a:	00054783          	lbu	a5,0(a0)
 12e:	fbfd                	bnez	a5,124 <strchr+0xc>
      return (char*)s;
  return 0;
 130:	4501                	li	a0,0
}
 132:	6422                	ld	s0,8(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret
  return 0;
 138:	4501                	li	a0,0
 13a:	bfe5                	j	132 <strchr+0x1a>

000000000000013c <gets>:

char*
gets(char *buf, int max)
{
 13c:	711d                	addi	sp,sp,-96
 13e:	ec86                	sd	ra,88(sp)
 140:	e8a2                	sd	s0,80(sp)
 142:	e4a6                	sd	s1,72(sp)
 144:	e0ca                	sd	s2,64(sp)
 146:	fc4e                	sd	s3,56(sp)
 148:	f852                	sd	s4,48(sp)
 14a:	f456                	sd	s5,40(sp)
 14c:	f05a                	sd	s6,32(sp)
 14e:	ec5e                	sd	s7,24(sp)
 150:	1080                	addi	s0,sp,96
 152:	8baa                	mv	s7,a0
 154:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 156:	892a                	mv	s2,a0
 158:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15a:	4aa9                	li	s5,10
 15c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15e:	89a6                	mv	s3,s1
 160:	2485                	addiw	s1,s1,1
 162:	0344d863          	bge	s1,s4,192 <gets+0x56>
    cc = read(0, &c, 1);
 166:	4605                	li	a2,1
 168:	faf40593          	addi	a1,s0,-81
 16c:	4501                	li	a0,0
 16e:	00000097          	auipc	ra,0x0
 172:	19a080e7          	jalr	410(ra) # 308 <read>
    if(cc < 1)
 176:	00a05e63          	blez	a0,192 <gets+0x56>
    buf[i++] = c;
 17a:	faf44783          	lbu	a5,-81(s0)
 17e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 182:	01578763          	beq	a5,s5,190 <gets+0x54>
 186:	0905                	addi	s2,s2,1
 188:	fd679be3          	bne	a5,s6,15e <gets+0x22>
  for(i=0; i+1 < max; ){
 18c:	89a6                	mv	s3,s1
 18e:	a011                	j	192 <gets+0x56>
 190:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 192:	99de                	add	s3,s3,s7
 194:	00098023          	sb	zero,0(s3)
  return buf;
}
 198:	855e                	mv	a0,s7
 19a:	60e6                	ld	ra,88(sp)
 19c:	6446                	ld	s0,80(sp)
 19e:	64a6                	ld	s1,72(sp)
 1a0:	6906                	ld	s2,64(sp)
 1a2:	79e2                	ld	s3,56(sp)
 1a4:	7a42                	ld	s4,48(sp)
 1a6:	7aa2                	ld	s5,40(sp)
 1a8:	7b02                	ld	s6,32(sp)
 1aa:	6be2                	ld	s7,24(sp)
 1ac:	6125                	addi	sp,sp,96
 1ae:	8082                	ret

00000000000001b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b0:	1101                	addi	sp,sp,-32
 1b2:	ec06                	sd	ra,24(sp)
 1b4:	e822                	sd	s0,16(sp)
 1b6:	e426                	sd	s1,8(sp)
 1b8:	e04a                	sd	s2,0(sp)
 1ba:	1000                	addi	s0,sp,32
 1bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1be:	4581                	li	a1,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	170080e7          	jalr	368(ra) # 330 <open>
  if(fd < 0)
 1c8:	02054563          	bltz	a0,1f2 <stat+0x42>
 1cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ce:	85ca                	mv	a1,s2
 1d0:	00000097          	auipc	ra,0x0
 1d4:	178080e7          	jalr	376(ra) # 348 <fstat>
 1d8:	892a                	mv	s2,a0
  close(fd);
 1da:	8526                	mv	a0,s1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	13c080e7          	jalr	316(ra) # 318 <close>
  return r;
}
 1e4:	854a                	mv	a0,s2
 1e6:	60e2                	ld	ra,24(sp)
 1e8:	6442                	ld	s0,16(sp)
 1ea:	64a2                	ld	s1,8(sp)
 1ec:	6902                	ld	s2,0(sp)
 1ee:	6105                	addi	sp,sp,32
 1f0:	8082                	ret
    return -1;
 1f2:	597d                	li	s2,-1
 1f4:	bfc5                	j	1e4 <stat+0x34>

00000000000001f6 <atoi>:

int
atoi(const char *s)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fc:	00054683          	lbu	a3,0(a0)
 200:	fd06879b          	addiw	a5,a3,-48
 204:	0ff7f793          	zext.b	a5,a5
 208:	4625                	li	a2,9
 20a:	02f66863          	bltu	a2,a5,23a <atoi+0x44>
 20e:	872a                	mv	a4,a0
  n = 0;
 210:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 212:	0705                	addi	a4,a4,1
 214:	0025179b          	slliw	a5,a0,0x2
 218:	9fa9                	addw	a5,a5,a0
 21a:	0017979b          	slliw	a5,a5,0x1
 21e:	9fb5                	addw	a5,a5,a3
 220:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 224:	00074683          	lbu	a3,0(a4)
 228:	fd06879b          	addiw	a5,a3,-48
 22c:	0ff7f793          	zext.b	a5,a5
 230:	fef671e3          	bgeu	a2,a5,212 <atoi+0x1c>
  return n;
}
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret
  n = 0;
 23a:	4501                	li	a0,0
 23c:	bfe5                	j	234 <atoi+0x3e>

000000000000023e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 244:	02b57463          	bgeu	a0,a1,26c <memmove+0x2e>
    while(n-- > 0)
 248:	00c05f63          	blez	a2,266 <memmove+0x28>
 24c:	1602                	slli	a2,a2,0x20
 24e:	9201                	srli	a2,a2,0x20
 250:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 254:	872a                	mv	a4,a0
      *dst++ = *src++;
 256:	0585                	addi	a1,a1,1
 258:	0705                	addi	a4,a4,1
 25a:	fff5c683          	lbu	a3,-1(a1)
 25e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 262:	fee79ae3          	bne	a5,a4,256 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 266:	6422                	ld	s0,8(sp)
 268:	0141                	addi	sp,sp,16
 26a:	8082                	ret
    dst += n;
 26c:	00c50733          	add	a4,a0,a2
    src += n;
 270:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 272:	fec05ae3          	blez	a2,266 <memmove+0x28>
 276:	fff6079b          	addiw	a5,a2,-1
 27a:	1782                	slli	a5,a5,0x20
 27c:	9381                	srli	a5,a5,0x20
 27e:	fff7c793          	not	a5,a5
 282:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 284:	15fd                	addi	a1,a1,-1
 286:	177d                	addi	a4,a4,-1
 288:	0005c683          	lbu	a3,0(a1)
 28c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 290:	fee79ae3          	bne	a5,a4,284 <memmove+0x46>
 294:	bfc9                	j	266 <memmove+0x28>

0000000000000296 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 296:	1141                	addi	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 29c:	ca05                	beqz	a2,2cc <memcmp+0x36>
 29e:	fff6069b          	addiw	a3,a2,-1
 2a2:	1682                	slli	a3,a3,0x20
 2a4:	9281                	srli	a3,a3,0x20
 2a6:	0685                	addi	a3,a3,1
 2a8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2aa:	00054783          	lbu	a5,0(a0)
 2ae:	0005c703          	lbu	a4,0(a1)
 2b2:	00e79863          	bne	a5,a4,2c2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b6:	0505                	addi	a0,a0,1
    p2++;
 2b8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ba:	fed518e3          	bne	a0,a3,2aa <memcmp+0x14>
  }
  return 0;
 2be:	4501                	li	a0,0
 2c0:	a019                	j	2c6 <memcmp+0x30>
      return *p1 - *p2;
 2c2:	40e7853b          	subw	a0,a5,a4
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  return 0;
 2cc:	4501                	li	a0,0
 2ce:	bfe5                	j	2c6 <memcmp+0x30>

00000000000002d0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d8:	00000097          	auipc	ra,0x0
 2dc:	f66080e7          	jalr	-154(ra) # 23e <memmove>
}
 2e0:	60a2                	ld	ra,8(sp)
 2e2:	6402                	ld	s0,0(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret

00000000000002e8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e8:	4885                	li	a7,1
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f0:	4889                	li	a7,2
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f8:	488d                	li	a7,3
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 300:	4891                	li	a7,4
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <read>:
.global read
read:
 li a7, SYS_read
 308:	4895                	li	a7,5
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <write>:
.global write
write:
 li a7, SYS_write
 310:	48c1                	li	a7,16
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <close>:
.global close
close:
 li a7, SYS_close
 318:	48d5                	li	a7,21
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <kill>:
.global kill
kill:
 li a7, SYS_kill
 320:	4899                	li	a7,6
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <exec>:
.global exec
exec:
 li a7, SYS_exec
 328:	489d                	li	a7,7
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <open>:
.global open
open:
 li a7, SYS_open
 330:	48bd                	li	a7,15
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 338:	48c5                	li	a7,17
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 340:	48c9                	li	a7,18
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 348:	48a1                	li	a7,8
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <link>:
.global link
link:
 li a7, SYS_link
 350:	48cd                	li	a7,19
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 358:	48d1                	li	a7,20
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 360:	48a5                	li	a7,9
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <dup>:
.global dup
dup:
 li a7, SYS_dup
 368:	48a9                	li	a7,10
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 370:	48ad                	li	a7,11
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 378:	48b1                	li	a7,12
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 380:	48b5                	li	a7,13
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 388:	48b9                	li	a7,14
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 390:	48d9                	li	a7,22
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <yield>:
.global yield
yield:
 li a7, SYS_yield
 398:	48dd                	li	a7,23
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3a0:	48e1                	li	a7,24
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3a8:	48e5                	li	a7,25
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3b0:	48e9                	li	a7,26
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3b8:	48ed                	li	a7,27
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 3c0:	48f1                	li	a7,28
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 3c8:	48f5                	li	a7,29
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 3d0:	48f9                	li	a7,30
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 3d8:	02100893          	li	a7,33
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 3e2:	48fd                	li	a7,31
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 3ea:	02000893          	li	a7,32
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 3f4:	02200893          	li	a7,34
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 3fe:	02300893          	li	a7,35
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 408:	02400893          	li	a7,36
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 412:	02500893          	li	a7,37
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 41c:	02700893          	li	a7,39
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 426:	02600893          	li	a7,38
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 430:	1101                	addi	sp,sp,-32
 432:	ec06                	sd	ra,24(sp)
 434:	e822                	sd	s0,16(sp)
 436:	1000                	addi	s0,sp,32
 438:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43c:	4605                	li	a2,1
 43e:	fef40593          	addi	a1,s0,-17
 442:	00000097          	auipc	ra,0x0
 446:	ece080e7          	jalr	-306(ra) # 310 <write>
}
 44a:	60e2                	ld	ra,24(sp)
 44c:	6442                	ld	s0,16(sp)
 44e:	6105                	addi	sp,sp,32
 450:	8082                	ret

0000000000000452 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 452:	7139                	addi	sp,sp,-64
 454:	fc06                	sd	ra,56(sp)
 456:	f822                	sd	s0,48(sp)
 458:	f426                	sd	s1,40(sp)
 45a:	f04a                	sd	s2,32(sp)
 45c:	ec4e                	sd	s3,24(sp)
 45e:	0080                	addi	s0,sp,64
 460:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 462:	c299                	beqz	a3,468 <printint+0x16>
 464:	0805c963          	bltz	a1,4f6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 468:	2581                	sext.w	a1,a1
  neg = 0;
 46a:	4881                	li	a7,0
 46c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 470:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 472:	2601                	sext.w	a2,a2
 474:	00000517          	auipc	a0,0x0
 478:	4a450513          	addi	a0,a0,1188 # 918 <digits>
 47c:	883a                	mv	a6,a4
 47e:	2705                	addiw	a4,a4,1
 480:	02c5f7bb          	remuw	a5,a1,a2
 484:	1782                	slli	a5,a5,0x20
 486:	9381                	srli	a5,a5,0x20
 488:	97aa                	add	a5,a5,a0
 48a:	0007c783          	lbu	a5,0(a5)
 48e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 492:	0005879b          	sext.w	a5,a1
 496:	02c5d5bb          	divuw	a1,a1,a2
 49a:	0685                	addi	a3,a3,1
 49c:	fec7f0e3          	bgeu	a5,a2,47c <printint+0x2a>
  if(neg)
 4a0:	00088c63          	beqz	a7,4b8 <printint+0x66>
    buf[i++] = '-';
 4a4:	fd070793          	addi	a5,a4,-48
 4a8:	00878733          	add	a4,a5,s0
 4ac:	02d00793          	li	a5,45
 4b0:	fef70823          	sb	a5,-16(a4)
 4b4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4b8:	02e05863          	blez	a4,4e8 <printint+0x96>
 4bc:	fc040793          	addi	a5,s0,-64
 4c0:	00e78933          	add	s2,a5,a4
 4c4:	fff78993          	addi	s3,a5,-1
 4c8:	99ba                	add	s3,s3,a4
 4ca:	377d                	addiw	a4,a4,-1
 4cc:	1702                	slli	a4,a4,0x20
 4ce:	9301                	srli	a4,a4,0x20
 4d0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4d4:	fff94583          	lbu	a1,-1(s2)
 4d8:	8526                	mv	a0,s1
 4da:	00000097          	auipc	ra,0x0
 4de:	f56080e7          	jalr	-170(ra) # 430 <putc>
  while(--i >= 0)
 4e2:	197d                	addi	s2,s2,-1
 4e4:	ff3918e3          	bne	s2,s3,4d4 <printint+0x82>
}
 4e8:	70e2                	ld	ra,56(sp)
 4ea:	7442                	ld	s0,48(sp)
 4ec:	74a2                	ld	s1,40(sp)
 4ee:	7902                	ld	s2,32(sp)
 4f0:	69e2                	ld	s3,24(sp)
 4f2:	6121                	addi	sp,sp,64
 4f4:	8082                	ret
    x = -xx;
 4f6:	40b005bb          	negw	a1,a1
    neg = 1;
 4fa:	4885                	li	a7,1
    x = -xx;
 4fc:	bf85                	j	46c <printint+0x1a>

00000000000004fe <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4fe:	7119                	addi	sp,sp,-128
 500:	fc86                	sd	ra,120(sp)
 502:	f8a2                	sd	s0,112(sp)
 504:	f4a6                	sd	s1,104(sp)
 506:	f0ca                	sd	s2,96(sp)
 508:	ecce                	sd	s3,88(sp)
 50a:	e8d2                	sd	s4,80(sp)
 50c:	e4d6                	sd	s5,72(sp)
 50e:	e0da                	sd	s6,64(sp)
 510:	fc5e                	sd	s7,56(sp)
 512:	f862                	sd	s8,48(sp)
 514:	f466                	sd	s9,40(sp)
 516:	f06a                	sd	s10,32(sp)
 518:	ec6e                	sd	s11,24(sp)
 51a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51c:	0005c903          	lbu	s2,0(a1)
 520:	18090f63          	beqz	s2,6be <vprintf+0x1c0>
 524:	8aaa                	mv	s5,a0
 526:	8b32                	mv	s6,a2
 528:	00158493          	addi	s1,a1,1
  state = 0;
 52c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 52e:	02500a13          	li	s4,37
 532:	4c55                	li	s8,21
 534:	00000c97          	auipc	s9,0x0
 538:	38cc8c93          	addi	s9,s9,908 # 8c0 <malloc+0xfe>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 53c:	02800d93          	li	s11,40
  putc(fd, 'x');
 540:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 542:	00000b97          	auipc	s7,0x0
 546:	3d6b8b93          	addi	s7,s7,982 # 918 <digits>
 54a:	a839                	j	568 <vprintf+0x6a>
        putc(fd, c);
 54c:	85ca                	mv	a1,s2
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	ee0080e7          	jalr	-288(ra) # 430 <putc>
 558:	a019                	j	55e <vprintf+0x60>
    } else if(state == '%'){
 55a:	01498d63          	beq	s3,s4,574 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 55e:	0485                	addi	s1,s1,1
 560:	fff4c903          	lbu	s2,-1(s1)
 564:	14090d63          	beqz	s2,6be <vprintf+0x1c0>
    if(state == 0){
 568:	fe0999e3          	bnez	s3,55a <vprintf+0x5c>
      if(c == '%'){
 56c:	ff4910e3          	bne	s2,s4,54c <vprintf+0x4e>
        state = '%';
 570:	89d2                	mv	s3,s4
 572:	b7f5                	j	55e <vprintf+0x60>
      if(c == 'd'){
 574:	11490c63          	beq	s2,s4,68c <vprintf+0x18e>
 578:	f9d9079b          	addiw	a5,s2,-99
 57c:	0ff7f793          	zext.b	a5,a5
 580:	10fc6e63          	bltu	s8,a5,69c <vprintf+0x19e>
 584:	f9d9079b          	addiw	a5,s2,-99
 588:	0ff7f713          	zext.b	a4,a5
 58c:	10ec6863          	bltu	s8,a4,69c <vprintf+0x19e>
 590:	00271793          	slli	a5,a4,0x2
 594:	97e6                	add	a5,a5,s9
 596:	439c                	lw	a5,0(a5)
 598:	97e6                	add	a5,a5,s9
 59a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 59c:	008b0913          	addi	s2,s6,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000b2583          	lw	a1,0(s6)
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	ea8080e7          	jalr	-344(ra) # 452 <printint>
 5b2:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	b765                	j	55e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b8:	008b0913          	addi	s2,s6,8
 5bc:	4681                	li	a3,0
 5be:	4629                	li	a2,10
 5c0:	000b2583          	lw	a1,0(s6)
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e8c080e7          	jalr	-372(ra) # 452 <printint>
 5ce:	8b4a                	mv	s6,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	b771                	j	55e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5d4:	008b0913          	addi	s2,s6,8
 5d8:	4681                	li	a3,0
 5da:	866a                	mv	a2,s10
 5dc:	000b2583          	lw	a1,0(s6)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	e70080e7          	jalr	-400(ra) # 452 <printint>
 5ea:	8b4a                	mv	s6,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bf85                	j	55e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5f0:	008b0793          	addi	a5,s6,8
 5f4:	f8f43423          	sd	a5,-120(s0)
 5f8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5fc:	03000593          	li	a1,48
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e2e080e7          	jalr	-466(ra) # 430 <putc>
  putc(fd, 'x');
 60a:	07800593          	li	a1,120
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e20080e7          	jalr	-480(ra) # 430 <putc>
 618:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61a:	03c9d793          	srli	a5,s3,0x3c
 61e:	97de                	add	a5,a5,s7
 620:	0007c583          	lbu	a1,0(a5)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	e0a080e7          	jalr	-502(ra) # 430 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62e:	0992                	slli	s3,s3,0x4
 630:	397d                	addiw	s2,s2,-1
 632:	fe0914e3          	bnez	s2,61a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 636:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b70d                	j	55e <vprintf+0x60>
        s = va_arg(ap, char*);
 63e:	008b0913          	addi	s2,s6,8
 642:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 646:	02098163          	beqz	s3,668 <vprintf+0x16a>
        while(*s != 0){
 64a:	0009c583          	lbu	a1,0(s3)
 64e:	c5ad                	beqz	a1,6b8 <vprintf+0x1ba>
          putc(fd, *s);
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	dde080e7          	jalr	-546(ra) # 430 <putc>
          s++;
 65a:	0985                	addi	s3,s3,1
        while(*s != 0){
 65c:	0009c583          	lbu	a1,0(s3)
 660:	f9e5                	bnez	a1,650 <vprintf+0x152>
        s = va_arg(ap, char*);
 662:	8b4a                	mv	s6,s2
      state = 0;
 664:	4981                	li	s3,0
 666:	bde5                	j	55e <vprintf+0x60>
          s = "(null)";
 668:	00000997          	auipc	s3,0x0
 66c:	25098993          	addi	s3,s3,592 # 8b8 <malloc+0xf6>
        while(*s != 0){
 670:	85ee                	mv	a1,s11
 672:	bff9                	j	650 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 674:	008b0913          	addi	s2,s6,8
 678:	000b4583          	lbu	a1,0(s6)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	db2080e7          	jalr	-590(ra) # 430 <putc>
 686:	8b4a                	mv	s6,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bdd1                	j	55e <vprintf+0x60>
        putc(fd, c);
 68c:	85d2                	mv	a1,s4
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	da0080e7          	jalr	-608(ra) # 430 <putc>
      state = 0;
 698:	4981                	li	s3,0
 69a:	b5d1                	j	55e <vprintf+0x60>
        putc(fd, '%');
 69c:	85d2                	mv	a1,s4
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	d90080e7          	jalr	-624(ra) # 430 <putc>
        putc(fd, c);
 6a8:	85ca                	mv	a1,s2
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	d84080e7          	jalr	-636(ra) # 430 <putc>
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b565                	j	55e <vprintf+0x60>
        s = va_arg(ap, char*);
 6b8:	8b4a                	mv	s6,s2
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b54d                	j	55e <vprintf+0x60>
    }
  }
}
 6be:	70e6                	ld	ra,120(sp)
 6c0:	7446                	ld	s0,112(sp)
 6c2:	74a6                	ld	s1,104(sp)
 6c4:	7906                	ld	s2,96(sp)
 6c6:	69e6                	ld	s3,88(sp)
 6c8:	6a46                	ld	s4,80(sp)
 6ca:	6aa6                	ld	s5,72(sp)
 6cc:	6b06                	ld	s6,64(sp)
 6ce:	7be2                	ld	s7,56(sp)
 6d0:	7c42                	ld	s8,48(sp)
 6d2:	7ca2                	ld	s9,40(sp)
 6d4:	7d02                	ld	s10,32(sp)
 6d6:	6de2                	ld	s11,24(sp)
 6d8:	6109                	addi	sp,sp,128
 6da:	8082                	ret

00000000000006dc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6dc:	715d                	addi	sp,sp,-80
 6de:	ec06                	sd	ra,24(sp)
 6e0:	e822                	sd	s0,16(sp)
 6e2:	1000                	addi	s0,sp,32
 6e4:	e010                	sd	a2,0(s0)
 6e6:	e414                	sd	a3,8(s0)
 6e8:	e818                	sd	a4,16(s0)
 6ea:	ec1c                	sd	a5,24(s0)
 6ec:	03043023          	sd	a6,32(s0)
 6f0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f8:	8622                	mv	a2,s0
 6fa:	00000097          	auipc	ra,0x0
 6fe:	e04080e7          	jalr	-508(ra) # 4fe <vprintf>
}
 702:	60e2                	ld	ra,24(sp)
 704:	6442                	ld	s0,16(sp)
 706:	6161                	addi	sp,sp,80
 708:	8082                	ret

000000000000070a <printf>:

void
printf(const char *fmt, ...)
{
 70a:	711d                	addi	sp,sp,-96
 70c:	ec06                	sd	ra,24(sp)
 70e:	e822                	sd	s0,16(sp)
 710:	1000                	addi	s0,sp,32
 712:	e40c                	sd	a1,8(s0)
 714:	e810                	sd	a2,16(s0)
 716:	ec14                	sd	a3,24(s0)
 718:	f018                	sd	a4,32(s0)
 71a:	f41c                	sd	a5,40(s0)
 71c:	03043823          	sd	a6,48(s0)
 720:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 724:	00840613          	addi	a2,s0,8
 728:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 72c:	85aa                	mv	a1,a0
 72e:	4505                	li	a0,1
 730:	00000097          	auipc	ra,0x0
 734:	dce080e7          	jalr	-562(ra) # 4fe <vprintf>
}
 738:	60e2                	ld	ra,24(sp)
 73a:	6442                	ld	s0,16(sp)
 73c:	6125                	addi	sp,sp,96
 73e:	8082                	ret

0000000000000740 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 740:	1141                	addi	sp,sp,-16
 742:	e422                	sd	s0,8(sp)
 744:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 746:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74a:	00000797          	auipc	a5,0x0
 74e:	1e67b783          	ld	a5,486(a5) # 930 <freep>
 752:	a02d                	j	77c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 754:	4618                	lw	a4,8(a2)
 756:	9f2d                	addw	a4,a4,a1
 758:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 75c:	6398                	ld	a4,0(a5)
 75e:	6310                	ld	a2,0(a4)
 760:	a83d                	j	79e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 762:	ff852703          	lw	a4,-8(a0)
 766:	9f31                	addw	a4,a4,a2
 768:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 76a:	ff053683          	ld	a3,-16(a0)
 76e:	a091                	j	7b2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 770:	6398                	ld	a4,0(a5)
 772:	00e7e463          	bltu	a5,a4,77a <free+0x3a>
 776:	00e6ea63          	bltu	a3,a4,78a <free+0x4a>
{
 77a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77c:	fed7fae3          	bgeu	a5,a3,770 <free+0x30>
 780:	6398                	ld	a4,0(a5)
 782:	00e6e463          	bltu	a3,a4,78a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 786:	fee7eae3          	bltu	a5,a4,77a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 78a:	ff852583          	lw	a1,-8(a0)
 78e:	6390                	ld	a2,0(a5)
 790:	02059813          	slli	a6,a1,0x20
 794:	01c85713          	srli	a4,a6,0x1c
 798:	9736                	add	a4,a4,a3
 79a:	fae60de3          	beq	a2,a4,754 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 79e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a2:	4790                	lw	a2,8(a5)
 7a4:	02061593          	slli	a1,a2,0x20
 7a8:	01c5d713          	srli	a4,a1,0x1c
 7ac:	973e                	add	a4,a4,a5
 7ae:	fae68ae3          	beq	a3,a4,762 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b4:	00000717          	auipc	a4,0x0
 7b8:	16f73e23          	sd	a5,380(a4) # 930 <freep>
}
 7bc:	6422                	ld	s0,8(sp)
 7be:	0141                	addi	sp,sp,16
 7c0:	8082                	ret

00000000000007c2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c2:	7139                	addi	sp,sp,-64
 7c4:	fc06                	sd	ra,56(sp)
 7c6:	f822                	sd	s0,48(sp)
 7c8:	f426                	sd	s1,40(sp)
 7ca:	f04a                	sd	s2,32(sp)
 7cc:	ec4e                	sd	s3,24(sp)
 7ce:	e852                	sd	s4,16(sp)
 7d0:	e456                	sd	s5,8(sp)
 7d2:	e05a                	sd	s6,0(sp)
 7d4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d6:	02051493          	slli	s1,a0,0x20
 7da:	9081                	srli	s1,s1,0x20
 7dc:	04bd                	addi	s1,s1,15
 7de:	8091                	srli	s1,s1,0x4
 7e0:	0014899b          	addiw	s3,s1,1
 7e4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7e6:	00000517          	auipc	a0,0x0
 7ea:	14a53503          	ld	a0,330(a0) # 930 <freep>
 7ee:	c515                	beqz	a0,81a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f2:	4798                	lw	a4,8(a5)
 7f4:	02977f63          	bgeu	a4,s1,832 <malloc+0x70>
 7f8:	8a4e                	mv	s4,s3
 7fa:	0009871b          	sext.w	a4,s3
 7fe:	6685                	lui	a3,0x1
 800:	00d77363          	bgeu	a4,a3,806 <malloc+0x44>
 804:	6a05                	lui	s4,0x1
 806:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 80a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 80e:	00000917          	auipc	s2,0x0
 812:	12290913          	addi	s2,s2,290 # 930 <freep>
  if(p == (char*)-1)
 816:	5afd                	li	s5,-1
 818:	a895                	j	88c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 81a:	00000797          	auipc	a5,0x0
 81e:	11e78793          	addi	a5,a5,286 # 938 <base>
 822:	00000717          	auipc	a4,0x0
 826:	10f73723          	sd	a5,270(a4) # 930 <freep>
 82a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 82c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 830:	b7e1                	j	7f8 <malloc+0x36>
      if(p->s.size == nunits)
 832:	02e48c63          	beq	s1,a4,86a <malloc+0xa8>
        p->s.size -= nunits;
 836:	4137073b          	subw	a4,a4,s3
 83a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 83c:	02071693          	slli	a3,a4,0x20
 840:	01c6d713          	srli	a4,a3,0x1c
 844:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 846:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 84a:	00000717          	auipc	a4,0x0
 84e:	0ea73323          	sd	a0,230(a4) # 930 <freep>
      return (void*)(p + 1);
 852:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 856:	70e2                	ld	ra,56(sp)
 858:	7442                	ld	s0,48(sp)
 85a:	74a2                	ld	s1,40(sp)
 85c:	7902                	ld	s2,32(sp)
 85e:	69e2                	ld	s3,24(sp)
 860:	6a42                	ld	s4,16(sp)
 862:	6aa2                	ld	s5,8(sp)
 864:	6b02                	ld	s6,0(sp)
 866:	6121                	addi	sp,sp,64
 868:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 86a:	6398                	ld	a4,0(a5)
 86c:	e118                	sd	a4,0(a0)
 86e:	bff1                	j	84a <malloc+0x88>
  hp->s.size = nu;
 870:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 874:	0541                	addi	a0,a0,16
 876:	00000097          	auipc	ra,0x0
 87a:	eca080e7          	jalr	-310(ra) # 740 <free>
  return freep;
 87e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 882:	d971                	beqz	a0,856 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 884:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 886:	4798                	lw	a4,8(a5)
 888:	fa9775e3          	bgeu	a4,s1,832 <malloc+0x70>
    if(p == freep)
 88c:	00093703          	ld	a4,0(s2)
 890:	853e                	mv	a0,a5
 892:	fef719e3          	bne	a4,a5,884 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 896:	8552                	mv	a0,s4
 898:	00000097          	auipc	ra,0x0
 89c:	ae0080e7          	jalr	-1312(ra) # 378 <sbrk>
  if(p == (char*)-1)
 8a0:	fd5518e3          	bne	a0,s5,870 <malloc+0xae>
        return 0;
 8a4:	4501                	li	a0,0
 8a6:	bf45                	j	856 <malloc+0x94>
