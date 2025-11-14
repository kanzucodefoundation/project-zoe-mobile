// src/auth/auth.service.ts
import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private prisma: PrismaService, // 👈 Inject Prisma for transactions
  ) {}

  async register(registerDto: RegisterDto) {
    const {
      username,
      password,
      church_name,
      role_id,
      firstname,
      lastname,
      email,
      phone,
    } = registerDto;

    // --- 1. Check for conflicts ---
    if (await this.usersService.findByUsername(username)) {
      throw new ConflictException('Username already exists');
    }
    if (await this.prisma.person.findUnique({ where: { email } })) {
      throw new ConflictException('Email already in use');
    }

    // --- 2. Find the Church  ---
    const church = await this.prisma.church.findUnique({
      where: { name: church_name },
    });
    if (!church) {
      throw new BadRequestException('Church not found');
    }

    // --- 3. Hash the password ---
    const salt = await bcrypt.genSalt();
    const password_hash = await bcrypt.hash(password, salt);

    // --- 4. Create Person and User in a Transaction ---
    try {
      // Create the person first
      const newPerson = await this.prisma.person.create({
        data: {
          firstname,
          lastname,
          email,
          phone,
        },
      });

      // Then create the user and connect to the person
      const newUser = await this.prisma.user.create({
        data: {
          username,
          password_hash,
          role_id,
          church_id: church.church_id,
          person_id: newPerson.person_id, // assuming user has a person_id foreign key
        },
        include: { person: true },
      });

      // Don't return the hash
      return newUser;
    } catch (error) {
      throw new BadRequestException('Failed to create user', error.message);
    }
  }

  async login(loginDto: LoginDto) {
    const { username, password, church_name } = loginDto;

    // --- 1. Find the user and their church  ---
    const user = await this.usersService.findByUsername(username);

    // --- 2. Check church and password ---
    if (!user || user.church.name !== church_name) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // --- 3. Generate JWT Payload ---
    const payload = {
      username: user.username,
      sub: user.user_id, // 'sub' (subject) is standard for the user ID
    };

    // --- 4. Sign and return the token ---
    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}