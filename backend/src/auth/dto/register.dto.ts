// src/auth/dto/register.dto.ts
import { IsString, IsNotEmpty, IsEmail, IsOptional, IsUUID } from 'class-validator';

export class RegisterDto {
  @IsString()
  @IsNotEmpty()
  username: string;

  @IsString()
  @IsNotEmpty()
  password;

  @IsString()
  @IsNotEmpty()
  church_name: string; // From AC 1.0.1 

  @IsUUID()
  @IsNotEmpty()
  role_id: string;

  // --- Person Fields ---
  @IsString()
  @IsNotEmpty()
  firstname: string;

  @IsString()
  @IsNotEmpty()
  lastname: string;

  @IsEmail()
  email: string;

  @IsString()
  @IsOptional()
  phone?: string;
}