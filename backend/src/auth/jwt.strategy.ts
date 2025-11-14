// src/auth/jwt.strategy.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UsersService } from '../users/users.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private usersService: UsersService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: 'YOUR_VERY_SECRET_KEY', // 👈 Must match the secret in auth.module
    });
  }

  // This runs after the token is verified
  async validate(payload: { sub: string; username: string }) {
    // 'payload.sub' is the user_id (we set this in the login service)
    const user = await this.usersService.findOne(payload.sub);
    if (!user) {
      throw new UnauthorizedException();
    }
    // This 'user' object is attached to the request (req.user)
    return user;
  }
}
export default JwtStrategy;
