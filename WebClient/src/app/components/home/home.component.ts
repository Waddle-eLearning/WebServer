import {Component} from '@angular/core';
import {AuthHttp} from "angular2-jwt";
import {UserMe} from "../../models/user";
import {URLS} from "../../consts";
import {Progress, UploadService} from "../../shared/services/upload.service";

@Component({
	selector: 'app-home',
	templateUrl: 'home.component.html',
	styleUrls: ['home.component.css']
})
export class HomeComponent {

	constructor(private _authHttp: AuthHttp) {

	}

}
