// src/users/users.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';
// Note: We don't include CreateUserDto because the Auth module will handle creation.

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  findAll() {
    // Include the person's name and role!
    return this.prisma.user.findMany({
      select: { // 👈 Use select to avoid sending password_hash
        user_id: true,
        username: true,
        person: {
          select: { firstname: true, lastname: true, email: true },
        },
        role: {
          select: { name: true },
        },
      },
    });
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { user_id: id },
      include: { person: true, role: true }, // 👈 Include related data
    });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    const { password_hash, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }
  
  // This is for the Auth module, not a public controller
  findByUsername(username: string) {
    return this.prisma.user.findUnique({
      where: { username },
      include: { church: true }, // 👈 Include church for login logic 
    });
  }

  update(id: string, updateUserDto: UpdateUserDto) {
    // Admin can update a user's role, etc.
    return this.prisma.user.update({
      where: { user_id: id },
      data: updateUserDto,
    });
  }

  remove(id: string) {
    return this.prisma.user.delete({ where: { user_id: id } });
  }
}