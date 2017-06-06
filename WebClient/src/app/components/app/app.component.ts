import {Component, OnInit, ViewChild} from '@angular/core';
import {AuthService} from "../../auth/services/auth.service";
import {UserMe} from "../../models/user";
import {MdSidenav} from "@angular/material";
import {SidenavService} from "../../layout/sidenav/sidenav.service";

@Component({
	selector: 'app-root',
	templateUrl: 'app.component.html',
	styleUrls: ['app.component.css']
})
export class AppComponent implements OnInit{
	@ViewChild('sidenav') public sidenav: MdSidenav;

	isAuthenticated = false;
	user: UserMe;

	constructor(private authService: AuthService,
	            private sidenavService: SidenavService) {
		authService.authenticatedSubject.subscribe(isAuthenticated => {
			this.isAuthenticated = isAuthenticated;
		});

		authService.authenticatedUserSubject.subscribe(user => {
			this.user = user;
			console.log(this.user);
		});
	}

	ngOnInit(): void {
		// Store sidenav to service
		this.sidenavService.setSidenav(this.sidenav);

		this.authService.getUserData();
	}

	logout(){
		this.authService.logout();
	}

	public toggleSidenav() {

		this.sidenavService
			.toggle()
			.then(() => { });
	}
}
