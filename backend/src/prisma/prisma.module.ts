import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global() // 👈 This makes the PrismaService available everywhere
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}