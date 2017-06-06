import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { Routes, RouterModule } from '@angular/router';
import {HomeComponent} from "./components/home/home.component";
import {LoginComponent} from "./auth/login/login.component";
import {AuthGuard} from "./auth/services/auth-guard.service";
import {UploadComponent} from "./components/upload/upload.component";
import {VideoListComponent} from "./video/video-list/video-list.component";
import {VideoPageComponent} from "./video/video-page/video-page.component";
import {ProfileComponent} from "./components/profile/profile.component";


const routes: Routes = [

	{
		path: '',
		component: HomeComponent,
		canActivate: [AuthGuard]
	},
	{
		path: 'profile',
		component: ProfileComponent,
		canActivate: [AuthGuard]
	},
	{
		path: 'upload',
		component: UploadComponent,
		canActivate: [AuthGuard]
	},
	{
		path: 'videos',
		component: VideoListComponent,
		canActivate: [AuthGuard]
	},
	{
		path: 'videos/:id',
		component: VideoPageComponent,
		// canActivate: [AuthGuard]
	}
];


@NgModule({
	imports: [
		BrowserModule,
		RouterModule.forRoot( routes, { useHash: true } ),
	],
	providers: [
	],
	declarations: [
	],
	exports: [
		RouterModule
	],
})

export class AppRoutingModule {}
