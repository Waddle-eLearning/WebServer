import {NgModule} from '@angular/core';
import { AppRoutingModule } from "./app-routing.module";
import { HomeComponent } from "./components/home/home.component";
import { AppComponent } from "./components/app/app.component";

import { UploadService } from "./shared/services/upload.service";
import { UriDecodePipe } from "./pipes/uriEncode.pipe";
import { UploadComponent } from './components/upload/upload.component';
import { VideoService } from "./shared/services/video.service";
import { SharedModule } from "./shared/shared.module";
import { LayoutModule } from "./layout/layout.module";
import {VideoModule} from "./video/video.mudule";
import {ProfileComponent} from "./components/profile/profile.component";
import {AuthModule} from "./auth/auth.module";


@NgModule({
	declarations: [
		AppComponent,
		HomeComponent,
		UriDecodePipe,
		UploadComponent,
		ProfileComponent
	],
	imports: [
		AppRoutingModule,

		AuthModule,

		SharedModule,
		LayoutModule,
		VideoModule,
	],
	providers: [
		UploadService,
		VideoService
	],
	bootstrap: [AppComponent]
})
export class AppModule {
}
