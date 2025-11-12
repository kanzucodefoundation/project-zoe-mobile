import { IsString, IsNotEmpty } from 'class-validator';

export class CreateChurchDto {
  @IsString()
  @IsNotEmpty()
  name: string;
}