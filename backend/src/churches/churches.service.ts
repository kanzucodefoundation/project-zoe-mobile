import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateChurchDto } from './dto/create-church.dto';
import { UpdateChurchDto } from './dto/update-church.dto';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChurchesService {
  constructor(private prisma: PrismaService) {}

  create(createChurchDto: CreateChurchDto) {
    return this.prisma.church.create({ data: createChurchDto });
  }

  findAll() {
    return this.prisma.church.findMany();
  }

  async findOne(id: string) {
    const church = await this.prisma.church.findUnique({
      where: { church_id: id },
    });
    if (!church) {
      throw new NotFoundException(`Church with ID ${id} not found`);
    }
    return church;
  }

  update(id: string, updateChurchDto: UpdateChurchDto) {
    return this.prisma.church.update({
      where: { church_id: id },
      data: updateChurchDto,
    });
  }

  remove(id: string) {
    return this.prisma.church.delete({ where: { church_id: id } });
  }
}