
user/_testloop1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define INNER_BOUND 10000000
#define SIZE 100

int
main(int argc, char *argv[])
{
   0:	7105                	addi	sp,sp,-480
   2:	ef86                	sd	ra,472(sp)
   4:	eba2                	sd	s0,464(sp)
   6:	e7a6                	sd	s1,456(sp)
   8:	e3ca                	sd	s2,448(sp)
   a:	ff4e                	sd	s3,440(sp)
   c:	fb52                	sd	s4,432(sp)
   e:	f756                	sd	s5,424(sp)
  10:	f35a                	sd	s6,416(sp)
  12:	ef5e                	sd	s7,408(sp)
  14:	1380                	addi	s0,sp,480
    int array[SIZE], i, j, k, sum=0, pid=getpid();
  16:	00000097          	auipc	ra,0x0
  1a:	38c080e7          	jalr	908(ra) # 3a2 <getpid>
  1e:	8baa                	mv	s7,a0
    unsigned start_time, end_time;

    start_time = uptime();
  20:	00000097          	auipc	ra,0x0
  24:	39a080e7          	jalr	922(ra) # 3ba <uptime>
  28:	0005099b          	sext.w	s3,a0
  2c:	4a15                	li	s4,5
    int array[SIZE], i, j, k, sum=0, pid=getpid();
  2e:	4481                	li	s1,0
{
  30:	009897b7          	lui	a5,0x989
  34:	68078b13          	addi	s6,a5,1664 # 989680 <__global_pointer$+0x9884e7>
  38:	fb040913          	addi	s2,s0,-80
    for (k=0; k<OUTER_BOUND; k++) {
       for (j=0; j<INNER_BOUND; j++) for (i=0; i<SIZE; i++) sum += array[i];
       fprintf(1, "%d", pid);
  3c:	00001a97          	auipc	s5,0x1
  40:	8a4a8a93          	addi	s5,s5,-1884 # 8e0 <malloc+0xec>
{
  44:	86da                	mv	a3,s6
       for (j=0; j<INNER_BOUND; j++) for (i=0; i<SIZE; i++) sum += array[i];
  46:	e2040793          	addi	a5,s0,-480
  4a:	4398                	lw	a4,0(a5)
  4c:	9cb9                	addw	s1,s1,a4
  4e:	0791                	addi	a5,a5,4
  50:	ff279de3          	bne	a5,s2,4a <main+0x4a>
  54:	36fd                	addiw	a3,a3,-1
  56:	fae5                	bnez	a3,46 <main+0x46>
       fprintf(1, "%d", pid);
  58:	865e                	mv	a2,s7
  5a:	85d6                	mv	a1,s5
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	6b0080e7          	jalr	1712(ra) # 70e <fprintf>
       sleep(1);
  66:	4505                	li	a0,1
  68:	00000097          	auipc	ra,0x0
  6c:	34a080e7          	jalr	842(ra) # 3b2 <sleep>
    for (k=0; k<OUTER_BOUND; k++) {
  70:	3a7d                	addiw	s4,s4,-1
  72:	fc0a19e3          	bnez	s4,44 <main+0x44>
    }
    end_time = uptime();
  76:	00000097          	auipc	ra,0x0
  7a:	344080e7          	jalr	836(ra) # 3ba <uptime>
  7e:	0005091b          	sext.w	s2,a0
    printf("\nTotal sum: %d\n", sum);
  82:	85a6                	mv	a1,s1
  84:	00001517          	auipc	a0,0x1
  88:	86450513          	addi	a0,a0,-1948 # 8e8 <malloc+0xf4>
  8c:	00000097          	auipc	ra,0x0
  90:	6b0080e7          	jalr	1712(ra) # 73c <printf>
    printf("Start time: %d, End time: %d, Total time: %d\n", start_time, end_time, end_time-start_time);
  94:	413906bb          	subw	a3,s2,s3
  98:	864a                	mv	a2,s2
  9a:	85ce                	mv	a1,s3
  9c:	00001517          	auipc	a0,0x1
  a0:	85c50513          	addi	a0,a0,-1956 # 8f8 <malloc+0x104>
  a4:	00000097          	auipc	ra,0x0
  a8:	698080e7          	jalr	1688(ra) # 73c <printf>
    exit(0);
  ac:	4501                	li	a0,0
  ae:	00000097          	auipc	ra,0x0
  b2:	274080e7          	jalr	628(ra) # 322 <exit>

00000000000000b6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  bc:	87aa                	mv	a5,a0
  be:	0585                	addi	a1,a1,1
  c0:	0785                	addi	a5,a5,1
  c2:	fff5c703          	lbu	a4,-1(a1)
  c6:	fee78fa3          	sb	a4,-1(a5)
  ca:	fb75                	bnez	a4,be <strcpy+0x8>
    ;
  return os;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret

00000000000000d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	cb91                	beqz	a5,f0 <strcmp+0x1e>
  de:	0005c703          	lbu	a4,0(a1)
  e2:	00f71763          	bne	a4,a5,f0 <strcmp+0x1e>
    p++, q++;
  e6:	0505                	addi	a0,a0,1
  e8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	fbe5                	bnez	a5,de <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f0:	0005c503          	lbu	a0,0(a1)
}
  f4:	40a7853b          	subw	a0,a5,a0
  f8:	6422                	ld	s0,8(sp)
  fa:	0141                	addi	sp,sp,16
  fc:	8082                	ret

00000000000000fe <strlen>:

uint
strlen(const char *s)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 104:	00054783          	lbu	a5,0(a0)
 108:	cf91                	beqz	a5,124 <strlen+0x26>
 10a:	0505                	addi	a0,a0,1
 10c:	87aa                	mv	a5,a0
 10e:	4685                	li	a3,1
 110:	9e89                	subw	a3,a3,a0
 112:	00f6853b          	addw	a0,a3,a5
 116:	0785                	addi	a5,a5,1
 118:	fff7c703          	lbu	a4,-1(a5)
 11c:	fb7d                	bnez	a4,112 <strlen+0x14>
    ;
  return n;
}
 11e:	6422                	ld	s0,8(sp)
 120:	0141                	addi	sp,sp,16
 122:	8082                	ret
  for(n = 0; s[n]; n++)
 124:	4501                	li	a0,0
 126:	bfe5                	j	11e <strlen+0x20>

0000000000000128 <memset>:

void*
memset(void *dst, int c, uint n)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e422                	sd	s0,8(sp)
 12c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12e:	ca19                	beqz	a2,144 <memset+0x1c>
 130:	87aa                	mv	a5,a0
 132:	1602                	slli	a2,a2,0x20
 134:	9201                	srli	a2,a2,0x20
 136:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 13a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13e:	0785                	addi	a5,a5,1
 140:	fee79de3          	bne	a5,a4,13a <memset+0x12>
  }
  return dst;
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strchr>:

char*
strchr(const char *s, char c)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 150:	00054783          	lbu	a5,0(a0)
 154:	cb99                	beqz	a5,16a <strchr+0x20>
    if(*s == c)
 156:	00f58763          	beq	a1,a5,164 <strchr+0x1a>
  for(; *s; s++)
 15a:	0505                	addi	a0,a0,1
 15c:	00054783          	lbu	a5,0(a0)
 160:	fbfd                	bnez	a5,156 <strchr+0xc>
      return (char*)s;
  return 0;
 162:	4501                	li	a0,0
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret
  return 0;
 16a:	4501                	li	a0,0
 16c:	bfe5                	j	164 <strchr+0x1a>

000000000000016e <gets>:

char*
gets(char *buf, int max)
{
 16e:	711d                	addi	sp,sp,-96
 170:	ec86                	sd	ra,88(sp)
 172:	e8a2                	sd	s0,80(sp)
 174:	e4a6                	sd	s1,72(sp)
 176:	e0ca                	sd	s2,64(sp)
 178:	fc4e                	sd	s3,56(sp)
 17a:	f852                	sd	s4,48(sp)
 17c:	f456                	sd	s5,40(sp)
 17e:	f05a                	sd	s6,32(sp)
 180:	ec5e                	sd	s7,24(sp)
 182:	1080                	addi	s0,sp,96
 184:	8baa                	mv	s7,a0
 186:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 188:	892a                	mv	s2,a0
 18a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18c:	4aa9                	li	s5,10
 18e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 190:	89a6                	mv	s3,s1
 192:	2485                	addiw	s1,s1,1
 194:	0344d863          	bge	s1,s4,1c4 <gets+0x56>
    cc = read(0, &c, 1);
 198:	4605                	li	a2,1
 19a:	faf40593          	addi	a1,s0,-81
 19e:	4501                	li	a0,0
 1a0:	00000097          	auipc	ra,0x0
 1a4:	19a080e7          	jalr	410(ra) # 33a <read>
    if(cc < 1)
 1a8:	00a05e63          	blez	a0,1c4 <gets+0x56>
    buf[i++] = c;
 1ac:	faf44783          	lbu	a5,-81(s0)
 1b0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b4:	01578763          	beq	a5,s5,1c2 <gets+0x54>
 1b8:	0905                	addi	s2,s2,1
 1ba:	fd679be3          	bne	a5,s6,190 <gets+0x22>
  for(i=0; i+1 < max; ){
 1be:	89a6                	mv	s3,s1
 1c0:	a011                	j	1c4 <gets+0x56>
 1c2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c4:	99de                	add	s3,s3,s7
 1c6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ca:	855e                	mv	a0,s7
 1cc:	60e6                	ld	ra,88(sp)
 1ce:	6446                	ld	s0,80(sp)
 1d0:	64a6                	ld	s1,72(sp)
 1d2:	6906                	ld	s2,64(sp)
 1d4:	79e2                	ld	s3,56(sp)
 1d6:	7a42                	ld	s4,48(sp)
 1d8:	7aa2                	ld	s5,40(sp)
 1da:	7b02                	ld	s6,32(sp)
 1dc:	6be2                	ld	s7,24(sp)
 1de:	6125                	addi	sp,sp,96
 1e0:	8082                	ret

00000000000001e2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e2:	1101                	addi	sp,sp,-32
 1e4:	ec06                	sd	ra,24(sp)
 1e6:	e822                	sd	s0,16(sp)
 1e8:	e426                	sd	s1,8(sp)
 1ea:	e04a                	sd	s2,0(sp)
 1ec:	1000                	addi	s0,sp,32
 1ee:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f0:	4581                	li	a1,0
 1f2:	00000097          	auipc	ra,0x0
 1f6:	170080e7          	jalr	368(ra) # 362 <open>
  if(fd < 0)
 1fa:	02054563          	bltz	a0,224 <stat+0x42>
 1fe:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 200:	85ca                	mv	a1,s2
 202:	00000097          	auipc	ra,0x0
 206:	178080e7          	jalr	376(ra) # 37a <fstat>
 20a:	892a                	mv	s2,a0
  close(fd);
 20c:	8526                	mv	a0,s1
 20e:	00000097          	auipc	ra,0x0
 212:	13c080e7          	jalr	316(ra) # 34a <close>
  return r;
}
 216:	854a                	mv	a0,s2
 218:	60e2                	ld	ra,24(sp)
 21a:	6442                	ld	s0,16(sp)
 21c:	64a2                	ld	s1,8(sp)
 21e:	6902                	ld	s2,0(sp)
 220:	6105                	addi	sp,sp,32
 222:	8082                	ret
    return -1;
 224:	597d                	li	s2,-1
 226:	bfc5                	j	216 <stat+0x34>

0000000000000228 <atoi>:

int
atoi(const char *s)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 22e:	00054683          	lbu	a3,0(a0)
 232:	fd06879b          	addiw	a5,a3,-48
 236:	0ff7f793          	zext.b	a5,a5
 23a:	4625                	li	a2,9
 23c:	02f66863          	bltu	a2,a5,26c <atoi+0x44>
 240:	872a                	mv	a4,a0
  n = 0;
 242:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 244:	0705                	addi	a4,a4,1
 246:	0025179b          	slliw	a5,a0,0x2
 24a:	9fa9                	addw	a5,a5,a0
 24c:	0017979b          	slliw	a5,a5,0x1
 250:	9fb5                	addw	a5,a5,a3
 252:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 256:	00074683          	lbu	a3,0(a4)
 25a:	fd06879b          	addiw	a5,a3,-48
 25e:	0ff7f793          	zext.b	a5,a5
 262:	fef671e3          	bgeu	a2,a5,244 <atoi+0x1c>
  return n;
}
 266:	6422                	ld	s0,8(sp)
 268:	0141                	addi	sp,sp,16
 26a:	8082                	ret
  n = 0;
 26c:	4501                	li	a0,0
 26e:	bfe5                	j	266 <atoi+0x3e>

0000000000000270 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 276:	02b57463          	bgeu	a0,a1,29e <memmove+0x2e>
    while(n-- > 0)
 27a:	00c05f63          	blez	a2,298 <memmove+0x28>
 27e:	1602                	slli	a2,a2,0x20
 280:	9201                	srli	a2,a2,0x20
 282:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 286:	872a                	mv	a4,a0
      *dst++ = *src++;
 288:	0585                	addi	a1,a1,1
 28a:	0705                	addi	a4,a4,1
 28c:	fff5c683          	lbu	a3,-1(a1)
 290:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 294:	fee79ae3          	bne	a5,a4,288 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret
    dst += n;
 29e:	00c50733          	add	a4,a0,a2
    src += n;
 2a2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a4:	fec05ae3          	blez	a2,298 <memmove+0x28>
 2a8:	fff6079b          	addiw	a5,a2,-1
 2ac:	1782                	slli	a5,a5,0x20
 2ae:	9381                	srli	a5,a5,0x20
 2b0:	fff7c793          	not	a5,a5
 2b4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b6:	15fd                	addi	a1,a1,-1
 2b8:	177d                	addi	a4,a4,-1
 2ba:	0005c683          	lbu	a3,0(a1)
 2be:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c2:	fee79ae3          	bne	a5,a4,2b6 <memmove+0x46>
 2c6:	bfc9                	j	298 <memmove+0x28>

00000000000002c8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ce:	ca05                	beqz	a2,2fe <memcmp+0x36>
 2d0:	fff6069b          	addiw	a3,a2,-1
 2d4:	1682                	slli	a3,a3,0x20
 2d6:	9281                	srli	a3,a3,0x20
 2d8:	0685                	addi	a3,a3,1
 2da:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2dc:	00054783          	lbu	a5,0(a0)
 2e0:	0005c703          	lbu	a4,0(a1)
 2e4:	00e79863          	bne	a5,a4,2f4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2e8:	0505                	addi	a0,a0,1
    p2++;
 2ea:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ec:	fed518e3          	bne	a0,a3,2dc <memcmp+0x14>
  }
  return 0;
 2f0:	4501                	li	a0,0
 2f2:	a019                	j	2f8 <memcmp+0x30>
      return *p1 - *p2;
 2f4:	40e7853b          	subw	a0,a5,a4
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
  return 0;
 2fe:	4501                	li	a0,0
 300:	bfe5                	j	2f8 <memcmp+0x30>

0000000000000302 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 302:	1141                	addi	sp,sp,-16
 304:	e406                	sd	ra,8(sp)
 306:	e022                	sd	s0,0(sp)
 308:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 30a:	00000097          	auipc	ra,0x0
 30e:	f66080e7          	jalr	-154(ra) # 270 <memmove>
}
 312:	60a2                	ld	ra,8(sp)
 314:	6402                	ld	s0,0(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret

000000000000031a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 31a:	4885                	li	a7,1
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <exit>:
.global exit
exit:
 li a7, SYS_exit
 322:	4889                	li	a7,2
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <wait>:
.global wait
wait:
 li a7, SYS_wait
 32a:	488d                	li	a7,3
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 332:	4891                	li	a7,4
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <read>:
.global read
read:
 li a7, SYS_read
 33a:	4895                	li	a7,5
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <write>:
.global write
write:
 li a7, SYS_write
 342:	48c1                	li	a7,16
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <close>:
.global close
close:
 li a7, SYS_close
 34a:	48d5                	li	a7,21
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <kill>:
.global kill
kill:
 li a7, SYS_kill
 352:	4899                	li	a7,6
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <exec>:
.global exec
exec:
 li a7, SYS_exec
 35a:	489d                	li	a7,7
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <open>:
.global open
open:
 li a7, SYS_open
 362:	48bd                	li	a7,15
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 36a:	48c5                	li	a7,17
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 372:	48c9                	li	a7,18
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 37a:	48a1                	li	a7,8
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <link>:
.global link
link:
 li a7, SYS_link
 382:	48cd                	li	a7,19
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 38a:	48d1                	li	a7,20
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 392:	48a5                	li	a7,9
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <dup>:
.global dup
dup:
 li a7, SYS_dup
 39a:	48a9                	li	a7,10
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a2:	48ad                	li	a7,11
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3aa:	48b1                	li	a7,12
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b2:	48b5                	li	a7,13
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ba:	48b9                	li	a7,14
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3c2:	48d9                	li	a7,22
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <yield>:
.global yield
yield:
 li a7, SYS_yield
 3ca:	48dd                	li	a7,23
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3d2:	48e1                	li	a7,24
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3da:	48e5                	li	a7,25
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3e2:	48e9                	li	a7,26
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <ps>:
.global ps
ps:
 li a7, SYS_ps
 3ea:	48ed                	li	a7,27
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 3f2:	48f1                	li	a7,28
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 3fa:	48f5                	li	a7,29
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 402:	48f9                	li	a7,30
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 40a:	02100893          	li	a7,33
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 414:	48fd                	li	a7,31
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 41c:	02000893          	li	a7,32
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 426:	02200893          	li	a7,34
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 430:	02300893          	li	a7,35
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 43a:	02400893          	li	a7,36
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 444:	02500893          	li	a7,37
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 44e:	02700893          	li	a7,39
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 458:	02600893          	li	a7,38
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 462:	1101                	addi	sp,sp,-32
 464:	ec06                	sd	ra,24(sp)
 466:	e822                	sd	s0,16(sp)
 468:	1000                	addi	s0,sp,32
 46a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 46e:	4605                	li	a2,1
 470:	fef40593          	addi	a1,s0,-17
 474:	00000097          	auipc	ra,0x0
 478:	ece080e7          	jalr	-306(ra) # 342 <write>
}
 47c:	60e2                	ld	ra,24(sp)
 47e:	6442                	ld	s0,16(sp)
 480:	6105                	addi	sp,sp,32
 482:	8082                	ret

0000000000000484 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 484:	7139                	addi	sp,sp,-64
 486:	fc06                	sd	ra,56(sp)
 488:	f822                	sd	s0,48(sp)
 48a:	f426                	sd	s1,40(sp)
 48c:	f04a                	sd	s2,32(sp)
 48e:	ec4e                	sd	s3,24(sp)
 490:	0080                	addi	s0,sp,64
 492:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 494:	c299                	beqz	a3,49a <printint+0x16>
 496:	0805c963          	bltz	a1,528 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 49a:	2581                	sext.w	a1,a1
  neg = 0;
 49c:	4881                	li	a7,0
 49e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4a2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a4:	2601                	sext.w	a2,a2
 4a6:	00000517          	auipc	a0,0x0
 4aa:	4e250513          	addi	a0,a0,1250 # 988 <digits>
 4ae:	883a                	mv	a6,a4
 4b0:	2705                	addiw	a4,a4,1
 4b2:	02c5f7bb          	remuw	a5,a1,a2
 4b6:	1782                	slli	a5,a5,0x20
 4b8:	9381                	srli	a5,a5,0x20
 4ba:	97aa                	add	a5,a5,a0
 4bc:	0007c783          	lbu	a5,0(a5)
 4c0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c4:	0005879b          	sext.w	a5,a1
 4c8:	02c5d5bb          	divuw	a1,a1,a2
 4cc:	0685                	addi	a3,a3,1
 4ce:	fec7f0e3          	bgeu	a5,a2,4ae <printint+0x2a>
  if(neg)
 4d2:	00088c63          	beqz	a7,4ea <printint+0x66>
    buf[i++] = '-';
 4d6:	fd070793          	addi	a5,a4,-48
 4da:	00878733          	add	a4,a5,s0
 4de:	02d00793          	li	a5,45
 4e2:	fef70823          	sb	a5,-16(a4)
 4e6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ea:	02e05863          	blez	a4,51a <printint+0x96>
 4ee:	fc040793          	addi	a5,s0,-64
 4f2:	00e78933          	add	s2,a5,a4
 4f6:	fff78993          	addi	s3,a5,-1
 4fa:	99ba                	add	s3,s3,a4
 4fc:	377d                	addiw	a4,a4,-1
 4fe:	1702                	slli	a4,a4,0x20
 500:	9301                	srli	a4,a4,0x20
 502:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 506:	fff94583          	lbu	a1,-1(s2)
 50a:	8526                	mv	a0,s1
 50c:	00000097          	auipc	ra,0x0
 510:	f56080e7          	jalr	-170(ra) # 462 <putc>
  while(--i >= 0)
 514:	197d                	addi	s2,s2,-1
 516:	ff3918e3          	bne	s2,s3,506 <printint+0x82>
}
 51a:	70e2                	ld	ra,56(sp)
 51c:	7442                	ld	s0,48(sp)
 51e:	74a2                	ld	s1,40(sp)
 520:	7902                	ld	s2,32(sp)
 522:	69e2                	ld	s3,24(sp)
 524:	6121                	addi	sp,sp,64
 526:	8082                	ret
    x = -xx;
 528:	40b005bb          	negw	a1,a1
    neg = 1;
 52c:	4885                	li	a7,1
    x = -xx;
 52e:	bf85                	j	49e <printint+0x1a>

0000000000000530 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 530:	7119                	addi	sp,sp,-128
 532:	fc86                	sd	ra,120(sp)
 534:	f8a2                	sd	s0,112(sp)
 536:	f4a6                	sd	s1,104(sp)
 538:	f0ca                	sd	s2,96(sp)
 53a:	ecce                	sd	s3,88(sp)
 53c:	e8d2                	sd	s4,80(sp)
 53e:	e4d6                	sd	s5,72(sp)
 540:	e0da                	sd	s6,64(sp)
 542:	fc5e                	sd	s7,56(sp)
 544:	f862                	sd	s8,48(sp)
 546:	f466                	sd	s9,40(sp)
 548:	f06a                	sd	s10,32(sp)
 54a:	ec6e                	sd	s11,24(sp)
 54c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 54e:	0005c903          	lbu	s2,0(a1)
 552:	18090f63          	beqz	s2,6f0 <vprintf+0x1c0>
 556:	8aaa                	mv	s5,a0
 558:	8b32                	mv	s6,a2
 55a:	00158493          	addi	s1,a1,1
  state = 0;
 55e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 560:	02500a13          	li	s4,37
 564:	4c55                	li	s8,21
 566:	00000c97          	auipc	s9,0x0
 56a:	3cac8c93          	addi	s9,s9,970 # 930 <malloc+0x13c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 56e:	02800d93          	li	s11,40
  putc(fd, 'x');
 572:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 574:	00000b97          	auipc	s7,0x0
 578:	414b8b93          	addi	s7,s7,1044 # 988 <digits>
 57c:	a839                	j	59a <vprintf+0x6a>
        putc(fd, c);
 57e:	85ca                	mv	a1,s2
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	ee0080e7          	jalr	-288(ra) # 462 <putc>
 58a:	a019                	j	590 <vprintf+0x60>
    } else if(state == '%'){
 58c:	01498d63          	beq	s3,s4,5a6 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 590:	0485                	addi	s1,s1,1
 592:	fff4c903          	lbu	s2,-1(s1)
 596:	14090d63          	beqz	s2,6f0 <vprintf+0x1c0>
    if(state == 0){
 59a:	fe0999e3          	bnez	s3,58c <vprintf+0x5c>
      if(c == '%'){
 59e:	ff4910e3          	bne	s2,s4,57e <vprintf+0x4e>
        state = '%';
 5a2:	89d2                	mv	s3,s4
 5a4:	b7f5                	j	590 <vprintf+0x60>
      if(c == 'd'){
 5a6:	11490c63          	beq	s2,s4,6be <vprintf+0x18e>
 5aa:	f9d9079b          	addiw	a5,s2,-99
 5ae:	0ff7f793          	zext.b	a5,a5
 5b2:	10fc6e63          	bltu	s8,a5,6ce <vprintf+0x19e>
 5b6:	f9d9079b          	addiw	a5,s2,-99
 5ba:	0ff7f713          	zext.b	a4,a5
 5be:	10ec6863          	bltu	s8,a4,6ce <vprintf+0x19e>
 5c2:	00271793          	slli	a5,a4,0x2
 5c6:	97e6                	add	a5,a5,s9
 5c8:	439c                	lw	a5,0(a5)
 5ca:	97e6                	add	a5,a5,s9
 5cc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5ce:	008b0913          	addi	s2,s6,8
 5d2:	4685                	li	a3,1
 5d4:	4629                	li	a2,10
 5d6:	000b2583          	lw	a1,0(s6)
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	ea8080e7          	jalr	-344(ra) # 484 <printint>
 5e4:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b765                	j	590 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ea:	008b0913          	addi	s2,s6,8
 5ee:	4681                	li	a3,0
 5f0:	4629                	li	a2,10
 5f2:	000b2583          	lw	a1,0(s6)
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e8c080e7          	jalr	-372(ra) # 484 <printint>
 600:	8b4a                	mv	s6,s2
      state = 0;
 602:	4981                	li	s3,0
 604:	b771                	j	590 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 606:	008b0913          	addi	s2,s6,8
 60a:	4681                	li	a3,0
 60c:	866a                	mv	a2,s10
 60e:	000b2583          	lw	a1,0(s6)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	e70080e7          	jalr	-400(ra) # 484 <printint>
 61c:	8b4a                	mv	s6,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	bf85                	j	590 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 622:	008b0793          	addi	a5,s6,8
 626:	f8f43423          	sd	a5,-120(s0)
 62a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 62e:	03000593          	li	a1,48
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	e2e080e7          	jalr	-466(ra) # 462 <putc>
  putc(fd, 'x');
 63c:	07800593          	li	a1,120
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e20080e7          	jalr	-480(ra) # 462 <putc>
 64a:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64c:	03c9d793          	srli	a5,s3,0x3c
 650:	97de                	add	a5,a5,s7
 652:	0007c583          	lbu	a1,0(a5)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e0a080e7          	jalr	-502(ra) # 462 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 660:	0992                	slli	s3,s3,0x4
 662:	397d                	addiw	s2,s2,-1
 664:	fe0914e3          	bnez	s2,64c <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 668:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b70d                	j	590 <vprintf+0x60>
        s = va_arg(ap, char*);
 670:	008b0913          	addi	s2,s6,8
 674:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 678:	02098163          	beqz	s3,69a <vprintf+0x16a>
        while(*s != 0){
 67c:	0009c583          	lbu	a1,0(s3)
 680:	c5ad                	beqz	a1,6ea <vprintf+0x1ba>
          putc(fd, *s);
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	dde080e7          	jalr	-546(ra) # 462 <putc>
          s++;
 68c:	0985                	addi	s3,s3,1
        while(*s != 0){
 68e:	0009c583          	lbu	a1,0(s3)
 692:	f9e5                	bnez	a1,682 <vprintf+0x152>
        s = va_arg(ap, char*);
 694:	8b4a                	mv	s6,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	bde5                	j	590 <vprintf+0x60>
          s = "(null)";
 69a:	00000997          	auipc	s3,0x0
 69e:	28e98993          	addi	s3,s3,654 # 928 <malloc+0x134>
        while(*s != 0){
 6a2:	85ee                	mv	a1,s11
 6a4:	bff9                	j	682 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6a6:	008b0913          	addi	s2,s6,8
 6aa:	000b4583          	lbu	a1,0(s6)
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	db2080e7          	jalr	-590(ra) # 462 <putc>
 6b8:	8b4a                	mv	s6,s2
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	bdd1                	j	590 <vprintf+0x60>
        putc(fd, c);
 6be:	85d2                	mv	a1,s4
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	da0080e7          	jalr	-608(ra) # 462 <putc>
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b5d1                	j	590 <vprintf+0x60>
        putc(fd, '%');
 6ce:	85d2                	mv	a1,s4
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	d90080e7          	jalr	-624(ra) # 462 <putc>
        putc(fd, c);
 6da:	85ca                	mv	a1,s2
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	d84080e7          	jalr	-636(ra) # 462 <putc>
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b565                	j	590 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ea:	8b4a                	mv	s6,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b54d                	j	590 <vprintf+0x60>
    }
  }
}
 6f0:	70e6                	ld	ra,120(sp)
 6f2:	7446                	ld	s0,112(sp)
 6f4:	74a6                	ld	s1,104(sp)
 6f6:	7906                	ld	s2,96(sp)
 6f8:	69e6                	ld	s3,88(sp)
 6fa:	6a46                	ld	s4,80(sp)
 6fc:	6aa6                	ld	s5,72(sp)
 6fe:	6b06                	ld	s6,64(sp)
 700:	7be2                	ld	s7,56(sp)
 702:	7c42                	ld	s8,48(sp)
 704:	7ca2                	ld	s9,40(sp)
 706:	7d02                	ld	s10,32(sp)
 708:	6de2                	ld	s11,24(sp)
 70a:	6109                	addi	sp,sp,128
 70c:	8082                	ret

000000000000070e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 70e:	715d                	addi	sp,sp,-80
 710:	ec06                	sd	ra,24(sp)
 712:	e822                	sd	s0,16(sp)
 714:	1000                	addi	s0,sp,32
 716:	e010                	sd	a2,0(s0)
 718:	e414                	sd	a3,8(s0)
 71a:	e818                	sd	a4,16(s0)
 71c:	ec1c                	sd	a5,24(s0)
 71e:	03043023          	sd	a6,32(s0)
 722:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 726:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72a:	8622                	mv	a2,s0
 72c:	00000097          	auipc	ra,0x0
 730:	e04080e7          	jalr	-508(ra) # 530 <vprintf>
}
 734:	60e2                	ld	ra,24(sp)
 736:	6442                	ld	s0,16(sp)
 738:	6161                	addi	sp,sp,80
 73a:	8082                	ret

000000000000073c <printf>:

void
printf(const char *fmt, ...)
{
 73c:	711d                	addi	sp,sp,-96
 73e:	ec06                	sd	ra,24(sp)
 740:	e822                	sd	s0,16(sp)
 742:	1000                	addi	s0,sp,32
 744:	e40c                	sd	a1,8(s0)
 746:	e810                	sd	a2,16(s0)
 748:	ec14                	sd	a3,24(s0)
 74a:	f018                	sd	a4,32(s0)
 74c:	f41c                	sd	a5,40(s0)
 74e:	03043823          	sd	a6,48(s0)
 752:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 756:	00840613          	addi	a2,s0,8
 75a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 75e:	85aa                	mv	a1,a0
 760:	4505                	li	a0,1
 762:	00000097          	auipc	ra,0x0
 766:	dce080e7          	jalr	-562(ra) # 530 <vprintf>
}
 76a:	60e2                	ld	ra,24(sp)
 76c:	6442                	ld	s0,16(sp)
 76e:	6125                	addi	sp,sp,96
 770:	8082                	ret

0000000000000772 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 772:	1141                	addi	sp,sp,-16
 774:	e422                	sd	s0,8(sp)
 776:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 778:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77c:	00000797          	auipc	a5,0x0
 780:	2247b783          	ld	a5,548(a5) # 9a0 <freep>
 784:	a02d                	j	7ae <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 786:	4618                	lw	a4,8(a2)
 788:	9f2d                	addw	a4,a4,a1
 78a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 78e:	6398                	ld	a4,0(a5)
 790:	6310                	ld	a2,0(a4)
 792:	a83d                	j	7d0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 794:	ff852703          	lw	a4,-8(a0)
 798:	9f31                	addw	a4,a4,a2
 79a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 79c:	ff053683          	ld	a3,-16(a0)
 7a0:	a091                	j	7e4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a2:	6398                	ld	a4,0(a5)
 7a4:	00e7e463          	bltu	a5,a4,7ac <free+0x3a>
 7a8:	00e6ea63          	bltu	a3,a4,7bc <free+0x4a>
{
 7ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	fed7fae3          	bgeu	a5,a3,7a2 <free+0x30>
 7b2:	6398                	ld	a4,0(a5)
 7b4:	00e6e463          	bltu	a3,a4,7bc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b8:	fee7eae3          	bltu	a5,a4,7ac <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7bc:	ff852583          	lw	a1,-8(a0)
 7c0:	6390                	ld	a2,0(a5)
 7c2:	02059813          	slli	a6,a1,0x20
 7c6:	01c85713          	srli	a4,a6,0x1c
 7ca:	9736                	add	a4,a4,a3
 7cc:	fae60de3          	beq	a2,a4,786 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d4:	4790                	lw	a2,8(a5)
 7d6:	02061593          	slli	a1,a2,0x20
 7da:	01c5d713          	srli	a4,a1,0x1c
 7de:	973e                	add	a4,a4,a5
 7e0:	fae68ae3          	beq	a3,a4,794 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7e4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e6:	00000717          	auipc	a4,0x0
 7ea:	1af73d23          	sd	a5,442(a4) # 9a0 <freep>
}
 7ee:	6422                	ld	s0,8(sp)
 7f0:	0141                	addi	sp,sp,16
 7f2:	8082                	ret

00000000000007f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f4:	7139                	addi	sp,sp,-64
 7f6:	fc06                	sd	ra,56(sp)
 7f8:	f822                	sd	s0,48(sp)
 7fa:	f426                	sd	s1,40(sp)
 7fc:	f04a                	sd	s2,32(sp)
 7fe:	ec4e                	sd	s3,24(sp)
 800:	e852                	sd	s4,16(sp)
 802:	e456                	sd	s5,8(sp)
 804:	e05a                	sd	s6,0(sp)
 806:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 808:	02051493          	slli	s1,a0,0x20
 80c:	9081                	srli	s1,s1,0x20
 80e:	04bd                	addi	s1,s1,15
 810:	8091                	srli	s1,s1,0x4
 812:	0014899b          	addiw	s3,s1,1
 816:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 818:	00000517          	auipc	a0,0x0
 81c:	18853503          	ld	a0,392(a0) # 9a0 <freep>
 820:	c515                	beqz	a0,84c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 822:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 824:	4798                	lw	a4,8(a5)
 826:	02977f63          	bgeu	a4,s1,864 <malloc+0x70>
 82a:	8a4e                	mv	s4,s3
 82c:	0009871b          	sext.w	a4,s3
 830:	6685                	lui	a3,0x1
 832:	00d77363          	bgeu	a4,a3,838 <malloc+0x44>
 836:	6a05                	lui	s4,0x1
 838:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 840:	00000917          	auipc	s2,0x0
 844:	16090913          	addi	s2,s2,352 # 9a0 <freep>
  if(p == (char*)-1)
 848:	5afd                	li	s5,-1
 84a:	a895                	j	8be <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 84c:	00000797          	auipc	a5,0x0
 850:	15c78793          	addi	a5,a5,348 # 9a8 <base>
 854:	00000717          	auipc	a4,0x0
 858:	14f73623          	sd	a5,332(a4) # 9a0 <freep>
 85c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 862:	b7e1                	j	82a <malloc+0x36>
      if(p->s.size == nunits)
 864:	02e48c63          	beq	s1,a4,89c <malloc+0xa8>
        p->s.size -= nunits;
 868:	4137073b          	subw	a4,a4,s3
 86c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 86e:	02071693          	slli	a3,a4,0x20
 872:	01c6d713          	srli	a4,a3,0x1c
 876:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 878:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 87c:	00000717          	auipc	a4,0x0
 880:	12a73223          	sd	a0,292(a4) # 9a0 <freep>
      return (void*)(p + 1);
 884:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 888:	70e2                	ld	ra,56(sp)
 88a:	7442                	ld	s0,48(sp)
 88c:	74a2                	ld	s1,40(sp)
 88e:	7902                	ld	s2,32(sp)
 890:	69e2                	ld	s3,24(sp)
 892:	6a42                	ld	s4,16(sp)
 894:	6aa2                	ld	s5,8(sp)
 896:	6b02                	ld	s6,0(sp)
 898:	6121                	addi	sp,sp,64
 89a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 89c:	6398                	ld	a4,0(a5)
 89e:	e118                	sd	a4,0(a0)
 8a0:	bff1                	j	87c <malloc+0x88>
  hp->s.size = nu;
 8a2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a6:	0541                	addi	a0,a0,16
 8a8:	00000097          	auipc	ra,0x0
 8ac:	eca080e7          	jalr	-310(ra) # 772 <free>
  return freep;
 8b0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8b4:	d971                	beqz	a0,888 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b8:	4798                	lw	a4,8(a5)
 8ba:	fa9775e3          	bgeu	a4,s1,864 <malloc+0x70>
    if(p == freep)
 8be:	00093703          	ld	a4,0(s2)
 8c2:	853e                	mv	a0,a5
 8c4:	fef719e3          	bne	a4,a5,8b6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8c8:	8552                	mv	a0,s4
 8ca:	00000097          	auipc	ra,0x0
 8ce:	ae0080e7          	jalr	-1312(ra) # 3aa <sbrk>
  if(p == (char*)-1)
 8d2:	fd5518e3          	bne	a0,s5,8a2 <malloc+0xae>
        return 0;
 8d6:	4501                	li	a0,0
 8d8:	bf45                	j	888 <malloc+0x94>
