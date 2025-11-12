// src/persons/persons.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { CreatePersonDto } from './dto/create-person.dto';
import { UpdatePersonDto } from './dto/update-person.dto';
import { PrismaService } from '../prisma/prisma.service'; // 👈 Import Prisma

@Injectable()
export class PersonsService {
  constructor(private prisma: PrismaService) {} // 👈 Inject Prisma

  create(createPersonDto: CreatePersonDto) {
    return this.prisma.person.create({ data: createPersonDto });
  }

  findAll() {
    return this.prisma.person.findMany();
  }

  async findOne(id: string) {
    const person = await this.prisma.person.findUnique({
      where: { person_id: id },
    });
    if (!person) {
      throw new NotFoundException(`Person with ID ${id} not found`);
    }
    return person;
  }

  update(id: string, updatePersonDto: UpdatePersonDto) {
    return this.prisma.person.update({
      where: { person_id: id },
      data: updatePersonDto,
    });
  }

  remove(id: string) {
    return this.prisma.person.delete({ where: { person_id: id } });
  }
}