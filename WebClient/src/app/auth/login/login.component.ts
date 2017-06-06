import { Component, OnInit } from '@angular/core';
import {Validators, FormBuilder, FormControl, FormGroup} from "@angular/forms";

import {Router} from "@angular/router";
import {AuthService} from "../services/auth.service";
import {Credentials} from "../../models/user";


@Component({
  selector: 'app-login',
  templateUrl: 'login.component.html',
  styleUrls: ['login.component.css']
})
export class LoginComponent{

	loginForm: FormGroup;
	registerForm: FormGroup;


  constructor(private _authService: AuthService,
              public _router: Router,
              public fb: FormBuilder) {

  	_authService.authenticatedSubject.subscribe(isAuth => {
	    console.log(isAuth);
		this._router.navigateByUrl("/");
    });


	  this.loginForm = fb.group({
		  "username": ["", Validators.required],
		  "password":["", Validators.required]
	  });

	  this.loginForm.valueChanges
		  .map((value) => {
			  // value.username = value.username.toUpperCase();
			  return value;
		  })
		  .filter((value) => this.loginForm.valid)
		  .subscribe((value) => {
			  console.log("Model Driven Form valid value: vm = ",JSON.stringify(value));
		  });



	  this.registerForm = fb.group({
		  "username": ["", Validators.required],
		  "password":["", Validators.required]
	  });

	  this.registerForm.valueChanges
		  .map((value) => {
			  // value.username = value.username.toUpperCase();
			  return value;
		  })
		  .filter((value) => this.registerForm.valid)
		  .subscribe((value) => {
			  console.log("Model Driven Form valid value: vm = ",JSON.stringify(value));
		  });
  }

	onLogin() {
		console.log("model-based form submitted");
		console.log(this.loginForm);
		let cred = new Credentials();

		cred.password = this.loginForm.value.password;
		cred.username = this.loginForm.value.username;

		this._authService.doLogin(cred);
	}

	onRegister() {
		console.log("model-based form submitted");
		console.log(this.registerForm);

		let cred = new Credentials();

		cred.password = this.registerForm.value.password;
		cred.username = this.registerForm.value.username;

		this._authService.doRegister(cred);
	}
}
