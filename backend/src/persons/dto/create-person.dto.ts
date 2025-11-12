// src/persons/dto/create-person.dto.ts
import { IsString, IsEmail, IsOptional, IsDateString } from 'class-validator';

export class CreatePersonDto {
  @IsString()
  firstname: string;

  @IsString()
  lastname: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsEmail()
  email: string;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsString()
  civilStatus?: string;

  @IsOptional()
  @IsDateString()
  birthday?: Date;

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsString()
  place_of_work?: string;

  @IsOptional()
  @IsString()
  age_group?: string;

  @IsOptional()
  @IsString()
  country?: string;

  @IsOptional()
  @IsString()
  district?: string;
}