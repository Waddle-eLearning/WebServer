import { NgModule } from '@angular/core';
import {VideoPageModule} from "./video-page/video-page.module";
import {VideoListModule} from "./video-list/video-list.module";

@NgModule({
	imports: [
		VideoPageModule
	],
	exports: [
		VideoPageModule,
		VideoListModule
	],
})

export class VideoModule { }
