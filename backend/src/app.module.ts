import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module'; //  1. IMPORT THIS
import { RolesModule } from './roles/roles.module';
import { ChurchesModule } from './churches/churches.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [PrismaModule, RolesModule, ChurchesModule, UsersModule, AuthModule], //  2. ADD THIS
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
