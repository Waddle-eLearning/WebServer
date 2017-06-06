import { NgModule } from '@angular/core';
import { Http, RequestOptions } from '@angular/http';
import { JwtHelper, AuthHttp, AuthConfig } from 'angular2-jwt';
import { LocalStorageService } from 'ng2-webstorage';
import {LoginModule} from "./login/login.module";
import {AuthRoutingModule} from "./auth-routing.module";
import {AuthService} from "./services/auth.service";
import {AuthGuard} from "./services/auth-guard.service";


/**
 * AuthHttp service factory to override some config values.
 *
 * @param {Http}            http
 * @param {RequestOptions}  options
 *
 * @returns {AuthHttp}
 */
export function authHttpServiceFactory(http: Http, options: RequestOptions) {
	return new AuthHttp(
		new AuthConfig({
			tokenName: 'token',
			tokenGetter: (() => {
				// const storage = new LocalStorageService();
				return localStorage.getItem('token');
			}),
			globalHeaders: [{
				'Content-Type': 'application/json'
			}],
		}),
		http,
		options
	);
}

@NgModule({
	imports: [
		LoginModule,
		AuthRoutingModule,
	],
	providers: [
		{
			provide: AuthHttp,
			useFactory: authHttpServiceFactory,
			deps: [
				Http,
				RequestOptions,
			],
		},
		JwtHelper,
		AuthService,
		AuthGuard
	],
	exports: [
		LoginModule,
	],
	declarations: [],
})

export class AuthModule { }
