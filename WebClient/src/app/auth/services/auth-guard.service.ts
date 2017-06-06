import {Router, CanActivate} from "@angular/router";
import {Injectable} from "@angular/core";
import {AuthService} from "./auth.service";


@Injectable()
export class AuthGuard implements CanActivate {

	constructor(private auth: AuthService, private router: Router) {}

	canActivate() {
		if(this.auth.loggedIn()) {
			return true;
		} else {
			this.router.navigateByUrl('/login');
			return false;
		}
	}
}