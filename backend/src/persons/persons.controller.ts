import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ValidationPipe,
  ParseUUIDPipe,
  UseGuards, // 1. Import UseGuards
} from '@nestjs/common';
import { PersonsService } from './persons.service';
import { CreatePersonDto } from './dto/create-person.dto';
import { UpdatePersonDto } from './dto/update-person.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard'; //  2. Import your Guard

@UseGuards(JwtAuthGuard) //  3. Protect ALL routes in this controller
@Controller('persons')
export class PersonsController {
  constructor(private readonly personsService: PersonsService) {}

  @Post()
  create(@Body(new ValidationPipe()) createPersonDto: CreatePersonDto) {
    // ...
  }
  // ... all other routes are now protected
}