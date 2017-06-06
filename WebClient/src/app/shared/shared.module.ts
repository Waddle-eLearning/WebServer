import { CommonModule } from '@angular/common';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RouterModule } from '@angular/router';
import {FormsModule, ReactiveFormsModule} from '@angular/forms';
import { HttpModule } from '@angular/http';
import { NgModule } from '@angular/core';
import { FlexLayoutModule } from '@angular/flex-layout';
import { MomentModule } from 'angular2-moment';
import { Ng2Webstorage } from 'ng2-webstorage';

// import 'hammerjs';

import { Services } from './services/';
import { MaterialModule } from './material.module';

@NgModule({
	declarations: [
		// ...Directives,
	],
	imports: [
		BrowserAnimationsModule,
		CommonModule,
		BrowserModule,
		BrowserAnimationsModule,
		FormsModule,
		HttpModule,
		ReactiveFormsModule,
		RouterModule,
		MaterialModule,
		FlexLayoutModule,
		MomentModule,
		Ng2Webstorage
	],
	providers: [
		{
			provide: 'Window',
			useValue: window,
		},
		...Services,
	],
	exports: [
		BrowserAnimationsModule,
		CommonModule,
		BrowserModule,
		BrowserAnimationsModule,
		FormsModule,
		HttpModule,
		ReactiveFormsModule,
		RouterModule,
		MaterialModule,
		FlexLayoutModule,
		MomentModule,
		Ng2Webstorage
		// ...Directives,
	],
})

export class SharedModule { }
