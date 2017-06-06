import { Injectable } from '@angular/core';
import {ReplaySubject, Subject} from "rxjs";
import {Http, Response} from "@angular/http";
import {tokenNotExpired, AuthHttp} from "angular2-jwt";
import {Credentials, LoginMessage, UserMe} from "../../models/user";
import {headers, URLS} from "../../consts";

@Injectable()
export class AuthService {

	authenticatedSubject: Subject<boolean> = new Subject<boolean>();
	authenticatedUserSubject: Subject<UserMe> = new Subject<UserMe>();

	authenticated:boolean = false;

	constructor(private http: Http,
	            private authHttp: AuthHttp) {

		this.validateToken();

		this.authenticatedSubject.subscribe((authenticated:boolean) =>{
			if(authenticated) {
				this.getUserData();
			}
		});
	}

	validateToken(){
		this.authHttp.get(URLS.validate)
			.map(res => res.json())
			.subscribe(
				(message: LoginMessage) => {
					this.authenticatedSubject.next(true);
				},
				error => {
					this.authenticatedSubject.next(false);
				}
			);
	}

	getUserData(){
		this.authHttp.get(URLS.me)
			.map(res => res.json())
			.subscribe(
				(userMe: UserMe) => {
					this.authenticatedUserSubject.next(userMe);
					// console.log(this.user);
				},
				(error) => {
					this.authenticatedSubject.next(false);
				}
			);
	}

    doLogin(credentials: Credentials){

	    let body = JSON.stringify(credentials);

	    this.http.post(URLS.login, body, {headers: headers()})
		    .map(
			    (response: Response) => {
				    return response.json();
			    },
			    error => {
				    this.authenticatedSubject.next(false);
			    }
		    )
		    .subscribe((message: LoginMessage) => {
			    console.log(message.token);

			    localStorage.setItem("token" , message.token);

			    this.authenticatedSubject.next(true);
			    // this.getThing();
		    });
    }

    doRegister(credentials: Credentials){
	    let body = JSON.stringify(credentials);
		console.log(body);
	    this.http.post(URLS.register, body, {headers: headers()})
		    .map(
			    (response: Response) => {
				    return response.json();
			    },
			    error => {
				    this.authenticatedSubject.next(false);
			    }
		    )
		    .subscribe((message: LoginMessage) => {
			    console.log(message.token);

			    localStorage.setItem("token" , message.token);

			    this.authenticatedSubject.next(true);
			    // this.getThing();
		    },);
    }

	loggedIn() : boolean {
		console.log(tokenNotExpired());
		return tokenNotExpired();
	}

	logout() : void {
		this.authenticatedSubject.next(false);
		localStorage.removeItem('token');
		console.log("logout")
	}
}
