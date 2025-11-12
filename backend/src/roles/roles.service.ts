import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateRoleDto } from './dto/create-role.dto';
import { UpdateRoleDto } from './dto/update-role.dto';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class RolesService {
  constructor(private prisma: PrismaService) {}

  create(createRoleDto: CreateRoleDto) {
    return this.prisma.roles.create({ data: createRoleDto });
  }

  findAll() {
    return this.prisma.roles.findMany();
  }

  async findOne(id: string) {
    const role = await this.prisma.roles.findUnique({
      where: { role_id: id },
    });
    if (!role) {
      throw new NotFoundException(`Role with ID ${id} not found`);
    }
    return role;
  }

  update(id: string, updateRoleDto: UpdateRoleDto) {
    return this.prisma.roles.update({
      where: { role_id: id },
      data: updateRoleDto,
    });
  }

  remove(id: string) {
    return this.prisma.roles.delete({ where: { role_id: id } });
  }
}